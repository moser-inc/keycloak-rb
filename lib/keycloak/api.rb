module Keycloak
  class Api

    def initialize(realm: Realm.new)
      @realm = realm
    end

    def search_users(params = nil)
      @realm.get('users', params:)
    end

    def get_user(id)
      @realm.get("users/#{id}")
    end

    def update_user(id, params)
      @realm.post("users/#{id}", params:)
    end

  end
end
