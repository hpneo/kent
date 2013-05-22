class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.integer :user_id
      t.string :title
      t.string :description
      t.string :url
      t.string :home_url
      t.string :format

      t.timestamps
    end
  end
end
