class MultipleAuthorsIpsSerializer
  def initialize(object)
    @object = object
  end
  def as_json
    @object.map do |ip, logins|
      {
        ip: ip,
        login: logins
      }
    end
  end
end
