class MultipleAuthorsIpsSerializer < ActiveModel::Serializer
  def initialize(object, options = {})
    @object = object
  end
  def as_json(options = {})
    @object.map do |ip, logins|
      {
        ip: ip,
        login: logins
      }
    end
  end
end
