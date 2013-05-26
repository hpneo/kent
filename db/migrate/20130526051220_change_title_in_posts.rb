class ChangeTitleInPosts < ActiveRecord::Migration
  def up
    change_column(:posts, :title, :text)
  end

  def down
  end
end
