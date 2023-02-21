# frozen_string_literal: true

class CreateAuths < ActiveRecord::Migration[7.0]
  def change
    create_table :auths do |t|
      t.string :token
      t.datetime :expires_at

      t.timestamps
    end
  end
end
