class AddApprovalFieldsToTickets < ActiveRecord::Migration[8.0]
  def change
    add_column :tickets, :approval_status, :integer, default: 0, null: false
    add_column :tickets, :approval_reason, :text
    add_reference :tickets, :approver, foreign_key: { to_table: :users }
    add_column :tickets, :approved_at, :datetime
  end
end
