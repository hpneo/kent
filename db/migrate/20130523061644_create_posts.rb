class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :feed_id
      t.string :title
      t.string :author
      t.string :link
      t.string :guid
      t.string :original_link
      t.text :description
      t.datetime :published_at
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
