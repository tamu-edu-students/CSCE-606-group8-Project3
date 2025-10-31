class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket, only: %i[show edit update destroy assign close approve reject]

  def index
    @tickets = policy_scope(Ticket)
    @tickets = @tickets.where(status: params[:status]) if params[:status].present?
    @tickets = @tickets.where(category: params[:category]) if params[:category].present?
    @tickets = @tickets.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
  end

  def show
    authorize @ticket
    @comments = @ticket.comments.includes(:author).chronological
    unless current_user&.agent? || current_user&.admin?
      if current_user == @ticket.requester
        @comments = @comments.where(visibility: Comment.visibilities[:public])
      else
        @comments = Comment.none
      end
    end
    @comment  = @ticket.comments.build(author: current_user, visibility: :public)
  end

  def new
    @ticket = Ticket.new(status: "open") # default status
    authorize @ticket
  end

  def create
    @ticket = Ticket.new
    authorize @ticket
    @ticket.assign_attributes(ticket_params)
    @ticket.requester = current_user

    if Setting.auto_round_robin?
      @ticket.assignee = next_agent_in_rotation
    end

    if @ticket.save
      redirect_to @ticket, notice: "Ticket was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @ticket
  end

  def update
    authorize @ticket
    # If current user is staff/admin and approval params are present, handle approval flow
    if (current_user&.agent? || current_user&.admin?) && params.dig(:ticket, :approval_status).present?
      approval_param = params.dig(:ticket, :approval_status).to_s
      case approval_param
      when 'approved'
        begin
          @ticket.approve!(current_user)
          redirect_to @ticket, notice: "Ticket was successfully updated." and return
        rescue => e
          @ticket.errors.add(:base, "Could not approve ticket: #{e.message}")
          render :edit, status: :unprocessable_content and return
        end
      when 'rejected'
        reason = params.dig(:ticket, :approval_reason)
        if reason.blank?
          # Provide a clearer, user-friendly message when staff attempt to reject without a reason
          # Add as a base error so the message is shown verbatim (not prefixed by the attribute name).
          @ticket.errors.add(:base, "Reject reason cannot be blank")
          render :edit, status: :unprocessable_content and return
        end
        begin
          @ticket.reject!(current_user, reason)
          redirect_to @ticket, notice: "Ticket was successfully updated." and return
        rescue => e
          @ticket.errors.add(:base, "Could not reject ticket: #{e.message}")
          render :edit, status: :unprocessable_content and return
        end
      when 'pending'
        # reset approval fields
        @ticket.update(approval_status: :pending, approver: nil, approval_reason: nil, approved_at: nil)
        redirect_to @ticket, notice: "Ticket was successfully updated." and return
      end
    end

    if @ticket.update(ticket_params)
      redirect_to @ticket, notice: "Ticket was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @ticket
    @ticket.destroy
    redirect_to tickets_url, notice: "Ticket deleted successfully."
  end

  def close
    authorize @ticket, :close?

    if @ticket.update(status: :resolved)
      redirect_to @ticket, notice: "Ticket resolved successfully."
    else
      redirect_to @ticket, alert: @ticket.errors.full_messages.to_sentence
    end
  end

  def approve
    authorize @ticket, :approve?
    begin
      @ticket.approve!(current_user)
      redirect_to tickets_path, notice: "Ticket approved."
    rescue => e
      redirect_to @ticket, alert: "Could not approve ticket: #{e.message}"
    end
  end

  def reject
    authorize @ticket, :reject?
    reason = params.dig(:ticket, :approval_reason) || params[:approval_reason]
    if reason.blank?
      redirect_to @ticket, alert: "Rejection reason is required."
      return
    end

    begin
      @ticket.reject!(current_user, reason)
      redirect_to tickets_path, notice: "Ticket rejected."
    rescue => e
      redirect_to @ticket, alert: "Could not reject ticket: #{e.message}"
    end
  end

  def assign
    authorize @ticket, :assign?
    agent = User.find(params[:ticket][:assignee_id])
    @ticket.update(assignee: agent)
    redirect_to @ticket, notice: "Ticket assigned to #{agent.display_name}."
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def ticket_params
    permitted = policy(@ticket).permitted_attributes
    params.require(:ticket).permit(permitted)
  end

  def next_agent_in_rotation
    agents = User.where(role: :staff).order(:id)
    return agents.first if agents.empty?

    last_assigned_index = Setting.get("last_assigned_index")
    if last_assigned_index.nil?
      index = 0
    else
      index = (last_assigned_index.to_i + 1) % agents.size
    end
    Setting.set("last_assigned_index", index.to_s)
    agents[index]
  end
end
