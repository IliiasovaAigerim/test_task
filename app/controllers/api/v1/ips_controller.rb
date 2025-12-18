class Api::V1::IpsController < ApplicationController
  def multiple_authors
    ips = Post.group(:ip).having("COUNT(DISTINCT(user_id)) > 1").select(:ip)
    users_with_ips = User.joins(:posts)
                         .where('posts.ip': ips)
                         .pluck("posts.ip", "users.login")
    ips_with_logins = users_with_ips.each_with_object(Hash.new { |h, k| h[k] = [] }) do |ip_and_login, hash|
      ip, login = ip_and_login
      hash[ip] << login
    end
    serializer = MultipleAuthorsIpsSerializer.new(ips_with_logins)
    render json: serializer.as_json
  end
end
