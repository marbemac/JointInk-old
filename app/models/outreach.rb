# == Schema Information
#
# Table name: outreaches
#
#  content :text
#  id      :integer          not null, primary key
#  url     :string(255)
#


class Outreach < ActiveRecord::Base
  validates_presence_of :url
end
