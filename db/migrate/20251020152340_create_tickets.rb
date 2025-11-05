class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.string :subject
      t.text :description
      t.integer :status
      t.integer :priority
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :assignee, foreign_key: { to_table: :users }
      t.string :category
      t.datetime :closed_at

      t.timestamps
    end
  end
end
