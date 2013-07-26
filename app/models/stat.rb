# == Schema Information
#
# Table name: stats
#
#  channel_created   :datetime
#  channel_id        :integer
#  channel_privacy   :string(255)
#  channel_status    :string(255)
#  channel_user_id   :integer
#  created_at        :datetime         not null
#  event             :string(255)
#  id                :integer          not null, primary key
#  ip_address        :string(255)
#  post_id           :integer
#  post_published_at :datetime
#  post_status       :string(255)
#  post_style        :string(255)
#  post_subtype      :string(255)
#  post_type         :string(255)
#  post_user_id      :integer
#  post_with_photo   :boolean
#  referer           :string(255)
#  referer_host      :string(255)
#  updated_at        :datetime         not null
#  user_birthday     :datetime
#  user_created_at   :datetime
#  user_gender       :string(255)
#  user_id           :integer
#

class Stat < ActiveRecord::Base

  def self.create_from_page_analytics(event, current_user, page_entities, referer, ip_address)
    stat = Stat.new
    stat.event = event
    stat.ip_address = ip_address

    if referer
      stat.referer = referer

      # if it's a jointink channel, store it as the host so we can group by channel url's in stats
      if referer =~ /http:\/\/jointink.com\/[a-z\-A-Z_0-9]*$/
        stat.referer_host = URI(referer).host + URI(referer).path
      else
        stat.referer_host = URI(referer).host
      end
    end

    if page_entities
      page_entities.each do |entity|
        if entity.class.name == 'Post'
          stat.post_id = entity.id
          stat.post_published_at = entity.published_at
          stat.post_status = entity.status
          stat.post_style = entity.style
          stat.post_subtype = entity.post_subtype
          stat.post_type = entity.post_type
          stat.post_user_id = entity.user_id
          stat.post_with_photo = entity.photo.present? ? true : false
        end

        if entity.class.name == 'Channel'
          stat.channel_created = entity.created_at
          stat.channel_id = entity.id
          stat.channel_privacy = entity.privacy
          stat.channel_status = entity.status
          stat.channel_user_id = entity.user_id
        end
      end
    end

    if current_user
      stat.user_id = current_user.id
      stat.user_gender = current_user.gender
      stat.user_created_at = current_user.created_at
      stat.user_birthday = current_user.birthday
    end

    stat.save
    stat
  end

  def self.retrieve_count(event, timeframe=nil, interval=nil, filters=nil)
    query = Stat.select("COUNT(id) AS value")
    query = query.where(:event => event) if event
    query = query.where('created_at > ?', timeframe.days.ago) if timeframe
    query = query.where(filters) if filters
    query = query.select("to_char(created_at + interval '#{Time.zone.utc_offset} seconds', 'MM/DD/YYYY') AS time").group("time").order('time ASC') if interval
    query = query.to_a

    fill_date_gaps(query, timeframe)
  end

  def self.referal_data(limit=10, timeframe=nil, filters=nil)
    query = Stat.select("COUNT(id) AS value, referer_host AS name").limit(limit).order('value DESC')
    query = query.where('created_at > ?', timeframe.days.ago) if timeframe
    query = query.where(filters) if filters
    query = query.group("referer_host")

    data = []
    total = query.inject(0) {|sum, hash| sum + hash['value'].to_i}
    query.each do |q|
      if q['name'] =~ /jointink.com\/[a-z\-A-Z_0-9]*$/
        channel = Channel.where(:slug => q['name'].split('/').last).first
        name = channel ? channel.name : 'Unknown Channel'
      elsif q['name']
        name = q['name'].gsub(/\.com/, '').capitalize
      else
        name = 'Direct'
      end
      data << {
          :value => ((q['value'].to_f / total.to_f) * 100).round(2),
          :name => name
      }
    end
    data
  end

  private

  def self.fill_date_gaps(data, timeframe, value=0)
    return data if data.length == timeframe

    (timeframe+1).times do |i|
      time = (timeframe-i).days.ago.strftime('%m/%d/%Y')
      if !data[i] || data[i]['time'] != time
        data.insert(i, {
            'stat' => {
                'time' => time,
                'value' => value
            }
        })
      end
    end

    data
  end

end
