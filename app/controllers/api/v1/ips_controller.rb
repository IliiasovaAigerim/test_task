class Api::V1::IpsController < ApplicationController
  def multiple_authors
    ips = Post.group(:ip).having("COUNT(DISTINCT(user_id)) > 1").pluck(:ip)
    users_with_ips = User.joins(:posts)
                         .where('posts.ip': ips)
                         .select("users.login", "posts.ip")
    ips_with_logins = users_with_ips.each_with_object({}) do |record, hash|
      ip = record.ip
      login = record.login

      hash[ip] ||= []
      hash[ip] << login
    end
    serializer = MultipleAuthorsIpsSerializer.new(ips_with_logins)
    render json: serializer.as_json
  end
end
