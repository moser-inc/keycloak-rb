module Keycloak
  class Api

    def initialize(realm: Realm.new)
      @realm = realm
    end

    def search_users(params = nil)
      @realm.get('users', params)
    end

    def get_user(id)
      @realm.get("users/#{id}")
    end

    def get_user_by_idp(idp_alias, idp_user_id)
      result = @realm.get('users', {
        'idpAlias' => idp_alias,
        'idpUserId' => idp_user_id
      })

      result.is_a?(Array) ? result.first : result
    end

    def update_user(id, params)
      @realm.put("users/#{id}", params:)
    end

    def update_user_attribute(id, attribute_name, attribute_value)
      user = get_user(id)

      attributes = user['attributes'] || {}
      attributes[attribute_name] = [attribute_value]

      @realm.put("users/#{id}", { attributes: })
    end

  end
end
