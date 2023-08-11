# Keycloak

Use this gem to communicate with a Keycloak server from your ruby or rails application.

## Installation

Add keycloak to your gemfile and run `bundle install`.

```
gem 'keycloak', git: 'https://github.com/moser-inc/keycloak-rb.git'
```

## Configuration

```
Keycloak.host = 'https://auth.yourhost.com'
Keycloak.realm = 'Your Realm Name'
Keycloak.client = 'service client id'
Keycloak.secret = 'service client secret' # Optional
```

## Decoding Tokens

The most common use case is decoding an access token that you have obtained from keycloak.

```
# you have a token from the Authorization header
access_token = request.headers['Authorization']&.split('Bearer ')&.last

# decode it into a JWT
realm = Keycloak::Realm.new
realm.decode(access_token)
# >> { "exp" => 1690568249, "sub" => ... }

# refresh a token
realm.refresh(refresh_token)
```

## Calling the REST API

More advanced applications may want to interface with the Keycloak admin [REST API](https://www.keycloak.org/docs-api/18.0/rest-api/). In order to use this you will need to configure a working service client and secret.

```
realm = Keycloak::Realm.new
realm.get("users/#{user_id}")
# >> { user info here }
```
