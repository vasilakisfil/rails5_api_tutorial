# Build an API in your Rails app now! (Rails 5 version)

_Note 1: If you are looking for the regular readme, it's [here](docs/README.md)._

_Note 2: You can contribute to this tutorial by opening an issue or even sending a pull request!_

_Note 3: With the API I built, I went on and created the [same app](https://github.com/vasilakisfil/ember_on_rails5) in Ember._

I will show how you can extend your Rails app and build an API without
changing a single line of code from your existing app.
We will be using [Michael Hartl's Rails tutorial](https://www.railstutorial.org/)
(I actually started learning Rails and subsequently Ruby from that tutorial, I really owe a
beer to that guy) which is a classic [Rails app](https://bitbucket.org/railstutorial/sample_app_4th_ed)
and extend it by building an API for the app.


## Designing our API
Designing an API is not an easy process.
Usually it's very difficult to know beforehand what the client will need.
However we will make our best to support most clients needs:

  * have a resty approach using the popular JSONAPI spec
  * use hypermedia for related resources instead of embedding them
  * have in the same response data that otherwise would require many requests in the client

By the way, there is a long discussion about what REST means. Is just JSONAPI as REST as Joy Fielding's defined it?
Definitely not. However, it's more resty than regular JSON response, plus it has a wide support in terms of libraries.

Moving forward, let's add our first resource, let it be a user. But before adding the controller let's add the routes first:

``` ruby
  #api
  namespace :api do
    namespace :v1 do
      resources :sessions, only: [:create, :show]
      resources :users, only: [:index, :create, :show, :update, :destroy] do
        post :activate, on: :collection
        resources :followers, only: [:index, :destroy]
        resources :followings, only: [:index, :destroy] do
          post :create, on: :member
        end
        resource :feed, only: [:show]
      end
      resources :microposts, only: [:index, :create, :show, :update, :destroy]
    end
  end
```

All REST routes for each record, only GET method for collections (Rails muddles up collection REST routes with
element REST routes in the same controllers) and a couple custom routes.


As you can see we have many routes. The idea is that the tutorial will mostly touch
and show you a couple of them and you will manage to understand and see the rest from
the code inside the repo. I think extended tutorials are boring :).
However, if you find something weird or you don't understand something you are always welcomed to
open an issue and ask :)

Let's create the users API controller and add support for the GET method on a single record:

## Adding our first API resource

The first thing we need to do is to separate our API from the rest of the app.
In order to do that we will create a new Controller under a different namespace.
Given that it's good to have versioned API let's go and create our first controller
under `app/controllers/api/v1/`

``` ruby
class Api::V1::BaseController < ActionController::API
end
```

As you can see we inherit from `ActionController::API` instead of `ActionController::Base`.
The former cuts down some features not needed making it a bit faster and less memory hungry :)

Now let's add the `users#show` action:

``` ruby
class Api::V1::UsersController < Api::V1::BaseController
  def show
    user = User.find(params[:id])

    render jsonapi: user, serializer: Api::V1::UserSerializer
  end
end
```

One thing that I like building APIs in Rails is that controllers are super clean _by default_.
We just request the user from the database and render it in JSON using AMS.

Let's add the user serializer under `app/serializers/api/v1/user_serializer.rb`.
We will use [ActiveModelSerializers](https://github.com/rails-api/active_model_serializers) for the JSON serialization.

``` ruby
class Api::V1::UserSerializer < ActiveModel::Serializer
  attributes(*User.attribute_names.map(&:to_sym))

  has_many :followers, serializer: Api::V1::UserSerializer

  has_many :followings, key: :followings, serializer: Api::V1::UserSerializer
end
```

If we now request a single user it will also render all followers and followings (users that the user follows).
Usually we don't want that but instead we probably want AMS to render only the url for the client to fetch the data
asynchronously. Let's change that and also add a link for Microposts (more info you can find on `active_model_serializers` wiki):

``` ruby
class Api::V1::UserSerializer < ActiveModel::Serializer
  attributes(*User.attribute_names.map(&:to_sym))

  has_many :microposts, serializer: Api::V1::MicropostSerializer do
    include_data(false)
    link(:related) {api_v1_microposts_path(user_id: object.id)}
  end

  has_many :followers, serializer: Api::V1::UserSerializer do
    include_data(false)
    link(:related) {api_v1_user_followers_path(user_id: object.id)}
  end

  has_many :followings, key: :followings, serializer: Api::V1::UserSerializer do
    include_data(false)
    link(:related) {api_v1_user_followings_path(user_id: object.id)}
  end
end
```

There is one more thing that needs to be fixed.
If a client asks for a user that does not exist in our database, `find` will raise a `ActiveRecord::RecordNotFound`
exception and Rails will return a 500 error.
But what we actually want here is to return a 404 error.
We can catch the exception in the `Api::V1::BaseController` and make Rails return 404.
Just add in `Api::V1::BaseController`:

``` ruby
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def not_found
    return api_error(status: 404, errors: 'Not found')
  end
```

A "Not found" in the body section is enough since the client can figure out the error from the 404 status code.

_Tip: Exceptions in Ruby are quite slow. A faster way is to request the user from the db using find_by and render 404 if find_by returned a nil._

**Important! [yuki24](https://github.com/yuki24) opened [an issue](https://github.com/vasilakisfil/rails5_api_tutorial/issues/15) to clarify that "rescue_from is possibly one of the worst Rails patterns of all time". Please take a look in [the issue](https://github.com/vasilakisfil/rails5_api_tutorial/issues/15) for more information until we have something better :)**

If we now send a request `api/v1/users/1` we get the following json response:

``` http
{
  "data": {
    "id": "1",
    "type": "users",
    "attributes": {
      "name": "Example User",
      "email": "example@railstutorial.org",
      "created-at": "2016-11-05T10:15:26Z",
      "updated-at": "2016-11-19T21:30:10Z",
      "password-digest": "$2a$10$or7HFYm/H07/uE79wDae3uXMmHOX3BvRKdgedPJ1SPceiMA40V25O",
      "remember-digest": null,
      "admin": true,
      "activation-digest": "$2a$10$X5IeDtGZPuZQEVQ.ZiUP4eUzfw9M9Pag/nR.0ONiXwAAp3w98iAuC",
      "activated": true,
      "activated-at": "2016-11-05T10:15:26.300Z",
      "reset-digest": null,
      "reset-sent-at": null,
    },
    "relationships": {
      "microposts": {
        "links": {
          "related": "/api/v1/microposts?user_id=1"
        }
      },
      "followers": {
        "links": {
          "related": "/api/v1/users/1/followers"
        }
      },
      "followings": {
        "links": {
          "related": "/api/v1/users/1/followings"
        }
      }
    }
  }
}
```

Of course we need to add Authentication and Authorization on our API but we will take
a look on that later :)

## Adding the index method
Now let's add a method to retrieve all users. Rails names that method index, in terms of REST it's a GET method that acts on the `users` collection.

``` ruby
class Api::V1::UsersController < Api::V1::BaseController
  def index
    users = User.all

    render jsonapi: users, each_serializer: Api::V1::UserSerializer,
  end
end
```

Pretty easy right?


## Adding Authentication
For authentication, the Rails app by Michael uses a custom implementation.
That shouldn't be a problem because we build an API and we need to re-implement the authentication endpoint anyway.
In APIs we don't use cookies and we don't have sessions.
Instead, when a user wants to sign in she sends an HTTP POST request with her username and password to our API (in our
case it's the `sessions` endpoint) which sends back a token.
This token is user's proof of who she is.
In each API request, rails finds the user based on the token sent.
If no user found with the received token, or no token is sent, the API should return a 401 (Unauthorized) error.

Let's add the token to the user.

First we add a callback that adds a token to every new user is created.

``` ruby
  before_validation :ensure_token

  def ensure_token
    self.token = generate_hex(:token) unless token.present?
  end

  def generate_hex(column)
    loop do
      hex = SecureRandom.hex
      break hex unless self.class.where(column => hex).any?
    end
  end
```

and exactly after that we create the migration:

```ruby
class AddTokenToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :token, :string

    User.find_each{|user| user.save!}

    change_column_null :users, :token, false
  end

  def down
    remove_column :users, :token, :string
  end
end
```

and run `bundle exec rails db:migrate`. Now every user, new and old, has a
valid unique non-null token.

Then let's add the `sessions` endpoint:

```ruby
class Api::V1::SessionsController < Api::V1::BaseController
  def create
    if @user
      render(
        jsonapi: @user,
        serializer: Api::V1::SessionSerializer,
        status: 201,
        include: [:user],
        scope: @user
      )
    else
      return api_error(status: 401, errors: 'Wrong password or username')
    end
  end

  private
    def create_params
      normalized_params.permit(:email, :password)
    end

    def load_resource
      @user = User.find_by(
        email: create_params[:email]
      )&.authenticate(create_params[:password])
    end

    def normalized_params
      ActionController::Parameters.new(
         ActiveModelSerializers::Deserialization.jsonapi_parse(params)
      )
    end
end
```

And the sessions serializer:

``` ruby
class Api::V1::SessionSerializer < Api::V1::BaseSerializer
  type :session

  attributes :email, :token, :user_id

  has_one :user, serializer: Api::V1::UserSerializer do
    link(:self) {api_v1_user_path(object.id)}
    link(:related) {api_v1_user_path(object.id)}

    object
  end

  def user
    object
  end

  def user_id
    object.id
  end

  def token
    object.token
  end

  def email
    object.email
  end
end

```

The client probably needs only user's id, email and token but it's good to return some more data for better optimization.
We might save us from an extra request to the users endpoint :)


```http
{
  "data": {
    "id": "1",
    "type": "session",
    "attributes": {
      "email": "example@railstutorial.org",
      "token": "f42f5ccee3689209e7ca8e4f9bd830e2",
      "user-id": 1
    },
    "relationships": {
      "user": {
        "data": {
          "id": "1",
          "type": "users"
        },
        "links": {
          "self": "/api/v1/users/1",
          "related": "/api/v1/users/1"
        }
      }
    }
  },
  "included": [
    {
      "id": "1",
      "type": "users",
      "attributes": {
        "name": "Example User",
        "email": "example@railstutorial.org",
        "created-at": "2016-11-05T10:15:26Z",
        "updated-at": "2016-11-19T21:30:10Z",
        "password-digest": "$2a$10$or7HFYm/H07/uE79wDae3uXMmHOX3BvRKdgedPJ1SPceiMA40V25O",
        "remember-digest": null,
        "admin": true,
        "activation-digest": "$2a$10$X5IeDtGZPuZQEVQ.ZiUP4eUzfw9M9Pag/nR.0ONiXwAAp3w98iAuC",
        "activated": true,
        "activated-at": "2016-11-05T10:15:26.300Z",
        "reset-digest": null,
        "reset-sent-at": null,
        "token": "f42f5ccee3689209e7ca8e4f9bd830e2",
        "microposts-count": 99,
        "followers-count": 37,
        "followings-count": 48,
        "following-state": false,
        "follower-state": false
      },
      "relationships": {
        "microposts": {
          "links": {
            "related": "/api/v1/microposts?user_id=1"
          }
        },
        "followers": {
          "links": {
            "related": "/api/v1/users/1/followers"
          }
        },
        "followings": {
          "links": {
            "related": "/api/v1/users/1/followings"
          }
        }
      }
    }
  ]
}

```
_Tip: Yes we need to add proper authorization: return only the attributes that the client is allowed to see, we will deal with that a bit later :)_


Once the client has the token it sends both token and email to the API for each subsequent request.
Now let's add the `authenticate_user!` filter inside the `Api::V1::BaseController`:

``` ruby
  def authenticate_user!
    token, _ = ActionController::HttpAuthentication::Token.token_and_options(
      request
    )

    user = User.find_by(token: token)

    if user
      @current_user = user
    else
      raise UnauthenticatedError
    end
  end
```
`ActionController::HttpAuthentication::Token` parses Authorization header which holds the token.
Actually, an Authorization header looks like that:

``` http
Authorization: Token token="f42f5ccee3689209e7ca8e4f9bd830e2"
```

Now that we have set the `current_user` it's time to move on to authorization.


## Adding Authorization
For authorization we will use [Pundit](https://github.com/elabs/pundit), a minimalistic yet wonderful gem based on policies.
It's worth mentioning that authorization should be the same regardless of the API version, so no namespacing here.
The original Rails app doesn't have an authorization gem but uses a custom one (nothing wrong with that!)

After we add the gem and run the generators for default policy we create the user policy:

``` ruby
class UserPolicy < ApplicationPolicy
  def show?
    return true
  end

  def create?
    return true
  end

  def update?
    return true if user.admin?
    return true if record.id == user.id
  end

  def destroy?
    return true if user.admin?
    return true if record.id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
```
The problem with `Pundit` is that it has a black-white kind of policy.
Either you are allowed to see the resource or not allowed at all.
We would like to have a mixed-policy (the grey one): you are allowed but only to specific resource attributes.

In our app we will have 3 roles:
* a `Guest` who is asking API data without authenticating at all
* a `Regular` user
* an `Admin`, think it like God which has access to everything

For that we will use [FlexiblePermissions](https://github.com/vasilakisfil/flexible-permissions) a gem that works
on top of `Pundit`. Basically the idea is that apart from telling controller if this
user is allowed to have access or not, you also embed the type of access: which attributes
the user has access. You can also specify the defaults (which is a subset of the permitted attributes)
if the user is not requesting specific fields. So, first let's specify the permission classes for `User` roles:

```ruby
class UserPolicy < ApplicationPolicy
  class Admin < FlexiblePermissions::Base
    class Fields < self::Fields
      def permitted
        super + [
          :links
        ]
      end
    end
  end

  class Regular < Admin
    class Fields < self::Fields
      def permitted
        super - [
          :activated, :activated_at, :activation_digest, :admin,
          :password_digest, :remember_digest, :reset_digest, :reset_sent_at,
          :token, :updated_at,
        ]
      end
    end
  end

  class Guest < Regular
    class Fields < self::Fields
      def permitted
        super - [:email]
      end
    end
  end
end
```

As you can see `Admin` role (when requesting `User(s)`) has access to everything, plus, the links attributes,
which is a computed property defined inside the Serializer.

Then we have the `Regular` role (when requesting `User(s)`) which inherits from `Admin` but we chop some
private attributes.

Then from `Guest` role we remove even more attributes (namely, the user's email).

Having defined the roles, we can now define the authorization methods for `User` resource:

```ruby
class UserPolicy < ApplicationPolicy
  def create?
    return Regular.new(record)
  end

  def show?
    return Guest.new(record) unless user
    return Admin.new(record) if user.admin?
    return Regular.new(record)
  end
end
```

That's the classic CRUD of a resource. As you can see, for user creation we set
`Regular` permissions no matter what.
For the rest actions though (here showing only `show` action), we alternate between roles depending on the
user. Let's see how our controller becomes now:

```ruby

  def show
    auth_user = authorize_with_permissions(User.find(params[:id]))

    render jsonapi: auth_user.record, serializer: Api::V1::UserSerializer,
      fields: {user: auth_user.fields}
  end
```
From the controller, we specify which attributes the serializer is allowed to return,
based on the `authorize_with_permissions`. So for a guest, the response becomes:

```http
{
  "data": {
    "id": "1",
    "type": "users",
    "attributes": {
      "name": "Example User",
      "created-at": "2016-11-05T10:15:26Z"
    },
    "relationships": {
      "microposts": {
        "links": {
          "related": "/api/v1/microposts?user_id=1"
        }
      },
      "followers": {
        "links": {
          "related": "/api/v1/users/1/followers"
        }
      },
      "followings": {
        "links": {
          "related": "/api/v1/users/1/followings"
        }
      }
    }
  }
}
```


## Adding pagination, rate limit and CORS
Pagination is necessary for 2 reasons.
It adds some very basic hypermedia for the front-end client and it increases the performance since it renders only a
fraction of the total resources.

For pagination we will use the same gem that Michael is already using: [will_paginate](https://github.com/mislav/will_paginate).
we will only need to use it in the following 2 methods:

``` ruby
  def paginate(resource)
    resource = resource.page(params[:page] || 1)
    if params[:per_page]
      resource = resource.per_page(params[:per_page])
    end

    return resource
  end

  #expects paginated resource!
  def meta_attributes(object)
    {
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.previous_page,
      total_pages: object.total_pages,
      total_count: object.total_entries
    }
  end
```

I should note that you can also use [Kaminari](https://github.com/amatsuda/kaminari), they are almost identical.

Rate limit is a good way to filter unwanted bots or users that abuse our API.
It's implemented by [redis-throttle](https://github.com/andreareginato/redis-throttle)
gem and as the name suggests it uses redis to store the limits based on the user's IP.
We only need to add the gem and add a couple of lines lines in a new file in `config/rack_attack.rb`

``` ruby
class Rack::Attack
  redis = ENV['REDISTOGO_URL'] || 'localhost'
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisStore.new(redis)

  throttle('req/ip', limit: 1000, period: 10.minutes) do |req|
    req.ip if req.path.starts_with?('/api/v1')
  end
end
```

and enable it in `config/application.rb`:

``` ruby
  config.middleware.use Rack::Attack
```


[CORS](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing) is a specification that "that enables many resources
(e.g. fonts, JavaScript, etc.) on a web page to be requested from another domain outside the domain from which the
resource originated.
Essentially it allows us to have loaded the javascript client in another domain from our API and allow the js to send
AJAX requests to our API.

For Rails all we have to do is to install the `rack-cors` gem and allow:

``` ruby
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end
```

We allow access from anywhere, as a proper API.
We can set restrictions on which clients are allowed to access the API by specifying the hostnames in origins.

## Tests
Now let's go and write some tests! We will use `Rack::Test` helper methods as described
[here](https://gist.github.com/alex-zige/5795358).
When building APIs it's important to test that the path input -> controller -> model -> controller -> serializer ->
output works ok.
That's why I feel API tests stand between unit tests and integration tests.
Note that since Michael has already added some model tests we don't have to be pedantic about it. We can skip models, and test
only API controllers.

``` ruby
describe Api::V1::UsersController, type: :api do
  context :show do
    before do
      create_and_sign_in_user
      @user = FactoryGirl.create(:user)

      get api_v1_user_path(@user.id), format: :json
    end

    it 'returns the correct status' do
      expect(last_response.status).to eql(200)
    end

    it 'returns the data in the body' do
      body = JSON.parse(last_response.body, symbolize_names: true)
      expect(body.dig(:data, :attributes, :name).to eql(@user.name)
      expect(body.dig(:data, :attributes, :email).to eql(@user.name)
      expect(body.dig(:data, :attributes, :admin).to eql(@user.admin)
      expect(body.dig(:data, :attributes, :updated_at)).to eql(@user.created_at.iso8601)
      expect(body.dig(:data, :attributes, :updated_at)).to eql(@user.updated_at.iso8601)
    end
  end
end
```

`create_and_sign_in_user` method comes from our authentication helper:

``` ruby
module AuthenticationHelper
  def sign_in(user)
    header('Authorization', "Token token=\"#{user.token}\"")
  end

  def create_and_sign_in_user
    user = FactoryGirl.create(:user)
    sign_in(user)
    return user
  end
  alias_method :create_and_sign_in_another_user, :create_and_sign_in_user

  def create_and_sign_in_admin
    admin = FactoryGirl.create(:admin)
    sign_in(admin)
    return admin
  end
  alias_method :create_and_sign_in_admin_user, :create_and_sign_in_admin
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :api
end
```

What do we want to test?

* the path input -> controller -> model -> controller -> serializer -> output actually works ok
* controller returns the correct error statuses
* controller responds to the API attributes based on the user role that makes the request

What we are actually doing here is that I re-implement the RSpecs methods [respond_to](https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/respond-to-matcher)
and rspec-rails' [be_valid](http://www.rubydoc.info/gems/rspec-rails/RSpec/Rails/Matchers#be_valid-instance_method)
method at a higher level.
However, asserting each attribute of the API response to be equal with our initial
object takes too much time and space. And what if I change my serializer and use HAL or JSONAPI instead?

Instead, we can use [rspec-api_helpers](https://github.com/kollegorna/rspec-api_helpers) which automate this process:

```ruby

require 'rails_helper'

describe Api::V1::UsersController, type: :api do
  context :show do
    before do
      create_and_sign_in_user
      FactoryGirl.create(:user)
      @user = User.last!

      get api_v1_user_path(@user.id)
    end

    it_returns_status(200)
    it_returns_attribute_values(
      resource: 'user', model: proc{@user}, attrs: [
        :id, :name, :created_at, :microposts_count, :followers_count,
        :followings_count
      ],
      modifiers: {
        created_at: proc{|i| i.in_time_zone('UTC').iso8601.to_s},
        id: proc{|i| i.to_s}
      }
    )
  end
end
```

This gem adds an automated way to test your JSONAPI (or any other API spec) respone
by proviging you a simple API to test all attributes.

Furthermore, to have more robust tests, we can add [rspec-json_schema](https://github.com/blazed/rspec-json_schema) that
tests if the response follows a pre-defined JSON schema.
For instance, the JSON schema for regular role, is the following:

```
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "properties": {
    "data": {
      "type": "object",
      "properties": {
        "id": {
          "type": "string"
        },
        "type": {
          "type": "string"
        },
        "attributes": {
          "type": "object",
          "properties": {
            "name": {
              "type": "string"
            },
            "email": {
              "type": "string"
            },
            "created-at": {
              "type": "string"
            }
          },
          "required": [
            "name",
            "email",
            "created-at",
          ]
        },
        "relationships": {
          "type": "object",
          "properties": {
            "microposts": {
              "type": "object",
              "properties": {
                "links": {
                  "type": "object",
                  "properties": {
                    "related": {
                      "type": "string"
                    }
                  },
                  "required": [
                    "related"
                  ]
                }
              },
              "required": [
                "links"
              ]
            },
            "followers": {
              "type": "object",
              "properties": {
                "links": {
                  "type": "object",
                  "properties": {
                    "related": {
                      "type": "string"
                    }
                  },
                  "required": [
                    "related"
                  ]
                }
              },
              "required": [
                "links"
              ]
            },
            "followings": {
              "type": "object",
              "properties": {
                "links": {
                  "type": "object",
                  "properties": {
                    "related": {
                      "type": "string"
                    }
                  },
                  "required": [
                    "related"
                  ]
                }
              },
              "required": [
                "links"
              ]
            }
          },
          "required": [
            "microposts",
            "followers",
            "followings"
          ]
        }
      },
      "required": [
        "id",
        "type",
        "attributes",
        "relationships"
      ]
    }
  },
  "required": [
    "data"
  ]
}
```

Notice on the `required` and `additionalProperties` properties which tighten the schema a lot.
Eventually the test spec for `show` action becomes:

```ruby
require 'rails_helper'

describe Api::V1::UsersController, '#show', type: :api do
  describe 'Authorization' do
    context 'when as guest' do
      before do
        FactoryGirl.create(:user)
        @user = User.last!

        get api_v1_user_path(@user.id)
      end

      it_returns_status(401)
      it_follows_json_schema('errors')
    end

    context 'when authenticated as a regular user' do
      before do
        create_and_sign_in_user
        FactoryGirl.create(:user)
        @user = User.last!

        get api_v1_user_path(@user.id)
      end

      it_returns_status(200)
      it_follows_json_schema('regular/user')
      it_returns_attribute_values(
        resource: 'user', model: proc{@user}, attrs: [
          :id, :name, :created_at, :microposts_count, :followers_count,
          :followings_count
        ],
        modifiers: {
          created_at: proc{|i| i.in_time_zone('UTC').iso8601.to_s},
          id: proc{|i| i.to_s}
        }
      )
    end

    context 'when authenticated as an admin' do
      before do
        create_and_sign_in_admin
        FactoryGirl.create(:user)
        @user = User.last!

        get api_v1_user_path(@user.id)
      end

      it_returns_status(200)
      it_follows_json_schema('admin/user')
      it_returns_attribute_values(
        resource: 'user', model: proc{@user}, attrs: User.column_names,
        modifiers: {
          [:created_at, :updated_at] => proc{|i| i.in_time_zone('UTC').iso8601.to_s},
          id: proc{|i| i.to_s}
        }
      )
    end
  end
end
```


Given that JSON schemas can be very verbose and specific regarding the response
attributes I feel all these techniques combined can give us very powerful tests.



## Final API
As you might noticed, we have skipped some stuff like creating or updating a user.
That was intentional as I didn't want to overload you with information.
You can dig in the code and see how everything is implemented :)

Just for reference, this API is used for the [Ember app](https://github.com/vasilakisfil/ember_on_rails5)
that imitates [Rails Tutorial app](https://www.railstutorial.org/).

For authentication and authorization in the ember side we used the
[ember-simple-auth](https://github.com/simplabs/ember-simple-auth) addon
although we haven't used devise in Rails app.
But that's the beauty of APIs: you can hide your implementation details :)

In the following sections I highlight some important aspects you should take into account
when building APIs.
All of them (except UUIDs and model caching) have been implemented in the final API that you will find
in the github repo.
I really think you should take it a drive and try to add model caching (I would
suggests shopify's [identity_cache](https://github.com/Shopify/identity_cache)) if you wanna scale :)

## Bonus: Some Optimizations and tips
### UTC Timestamps
When our resource includes a day, it's good to have it in UTC time and iso8601 format.
In general, we really don't want to include anywhere timezones in our API.
If we clearly state that our datetimes are in utc and we only accept utc datetime, clients are responsible to convert
the utc datetime to their local datetime (for instance, in Ember this is very easy using [moment](http://momentjs.com/)
and [transforms](http://emberjs.com/api/data/classes/DS.Transform.html)).

### Counters
Another thing is that when building an API we should always think from the client perspective.
For instance if the client requests a user, it will probably like to know the number
of microposts, followers or followings (users the user follows) that user has.

At the moment, this can be achieved by sending an extra request to each one of those
resources and check the `total_count` of the meta in the response.
Having the client sending more requests is not good for the client, it's not good
for us either since this means more requests to our API.

Instead we can add (cache) counters to each of the associations and return those
along with the user information.
To achieve that, we first need to create a column for each counter and then tell
rails to cache the counters (by adding `counter_cache: assocation_count` in
each association). Here we go:

First we create a migration:
```ruby
class AddCacheCounters < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :microposts_count, :integer, null: false, default: 0
    add_column :users, :followers_count, :integer, null: false, default: 0
    add_column :users, :followings_count, :integer, null: false, default: 0
  end
end
```
Then inside `Micropost` model:

```ruby
  belongs_to :user, counter_cache: true
```

and inside `Relationship` model:

```ruby
  belongs_to :follower, class_name: "User", counter_cache: :followings_count
  belongs_to :followed, class_name: "User", counter_cache: :followers_count
```

I should note that in regular Rails development these counter cache columns are
added even when not having an API.
It helps a lot to cache them in a database column instead of running the `SQL COUNT(*)`
each time we need it.

### Follower/Following states
Ok let's thing from the client perspective again.
Let's say that the client wants to retrieve a user, so it gets the user information
along with the counters.
However, in most cases you will want to know whether you follow this user or not
and whether this user follows you or not.

In a regular Rails app we can do instantly (even from the view) the query, or use
a helper and figure it out.
Here we need to take a different approach instead.
It will cost us much less if we give this information beforehand instead
of creating a new endpoint just for that and letting the client do the request.

We will add these states in the serializers as computed properties:

```ruby
  attribute :following_state
  attribute :follower_state

  def following_state
    Relationship.where(
      follower_id: current_user.id,
      followed_id: object.id
    ).exists?
  end

  def follower_state
    Relationship.where(
      follower_id: object.id,
      followed_id: current_user.id
    ).exists?
  end
```
We should cache this information (but I leave it up to you how to do it :) )

Even if you feel that this information is rarely used by clients, you should still
have it in the user resource but instead of providing these resource attributes
_by default_, you can provide them only when the user specifies a JSONAPI `fields`
param.
Which brings us to the next topic: help the client by building a modern API. Remember
that you don't build the API for yourself but for the clients.
The better the API for the clients, the more API clients you will have :)

## Bonus: Build a modern API
A modern API, regadless the spec you use, should have _at least_ the following attributes:

1. Sparse fields
2. Granular permissions
3. Associations on demand
4. Defaults (help the client!)
5. Sorting & pagination
6. Filtering collections
7. Aggregation queries

These API attributes will help the client to avoid unessecary data and ask for
exactly what is needed helping us too (since we won't compute unused data).
Ideally we would like to give to the client an ORM on top of HTTP.

### Sparse fields, Granular permissions and Associations on demand
We have already solved the problem of granular permissions by using [flexible_permissions](https://github.com/vasilakisfil/flexible-permissions) roles.
Each role is allowed only specific attributes and associations.
Also the same gems allows us to select only a subset of the allowed fields.

JSONAPI already specified how a client can ask specific fields/associations of a resource.
What we need to do now is to link the user's asked fields/associaions with role's
permitted attributes and associations.

### Defaults, Sorting & pagination, Filtering collections and Aggregation queries
We have already set the defaults using [flexible_permissions](https://github.com/vasilakisfil/flexible-permissions).
We have also added pagination in our response.

Now we need to allow the client to ask for specific sorting, filtering collections by
sending custom queries and ask for aggregated data (for instance the average number of
followers of a user).

For those things we are going to use [active_hash_relation](https://github.com/kollegorna/active_hash_relation) gem which adds a
whole API in our index method for free! Be sure to [check it out](https://github.com/kollegorna/active_hash_relation#the-api)!
It's as simple as adding 2 lines:

``` ruby
class Api::V1::UsersController < Api::V1::BaseController
  include ActiveHashRelation

  def index
    auth_users = policy_scope(@users)

    render jsonapi: auth_users.collection,
      each_serializer: Api::V1::UserSerializer,
      fields: {user: auth_users.fields},
      meta: meta_attributes(auth_users.collection)
  end
end
```

Now, using ActiveHashRelation API we can ask for users that were created after a specific date or users with a specific
email prefix etc. We can also ask for specific sorting and aggregation queries.

_However, it's a good idea in terms of performance and security to first filter the permitted params_



## Bonus: Adding automatic deployment
A new Rails project without automatic deployment is not cool.
Services like [travis](https://travis-ci.org/), [circleci](https://circleci.com/) and [codeship](https://codeship.com) help us build and deploy faster.
In this project we will use [codeship](https://codeship.com/).

Once we create a new project we we need to add the following commands on setup section:
```
rvm use 2.3.3
bundle install
bundle exec rake db:create
bundle exec rake db:migrate
```
In test secion we can run all tests (both Michael's and API tests):

```
rake test
bundle exec rspec spec
```

Then we need to create a heroku app (if heroku is what we want for code hosting) and
get the API key (I am surprised that heroku doesn't provide any permission listing for its API keys :/)
which is required by Codeship (or any other automatic deployment service) to deploy the code.
Once we have it we add a heroku pipeline and we are ready.


Now If we commit to master and our tests are green, it will push and deploy our repo in heroku and run migrations :)

## Bonus: In case of a break change: how to handle Version 2
We build our API, we ship it and everything works as expected.
We can always add more endpoints or enhance current ones and keep our current version as long as we don't have a
breaking changes. However, although rare, we might reach the point where we must have a break change because the
requirements changed.
Don't panic!
All we have to do is define the same routes but for V2 namespace, define the V2 controllers that inherit from V1
controllers and override any method we want.

``` ruby
class Api::V2::UsersController < Api::V1::UsersController

  def index
    #new overriden index here
  end

end
```

In that way we save a lot of time and effort for our V2 API ( although for shifting an API version you will probably
want more changes than a single endpoint).

## Bonus: Add documentation!
Documenting our API is vital even if it supports hypermedia.
Documentation helps users to speed up their app or client development.
There are many documentation tools for rails like [swagger](http://swagger.io/)
 and [slate](https://github.com/tripit/slate).

Here we will use [slate](https://github.com/tripit/slate) as it is easier to start with.

Our app is rather small and we are going to have docs in the same repo with the
rails app but in larger APIs we might want them in a separate repository because
it generates css and html files which are also versioned and there is no point since
they are generated with a bundler command.

Create an `app/docs/` directory and clone the slate repository there and delete
the .git directory (we don't need slate revisions).
In a `app/docs/config.rb` set the build directory to public folder:

``` ruby
set :build_dir, '../public/docs/'
```

and start writing your docs.
You can take some inspiration from [our docs](https://rails-tutorial-api.herokuapp.com/docs/) :)

## Bonus: Looking ahead
As I mentioned there are 2 things that haven't implemented, but you should try to implement them as a test :)

First, it's a good idea is to use uuids instead of ids when we know that our app is going to have an API.
With ids we might unveil sensitive information to an attacker.
There is a slight performance hit on database when using UUIDs but probably the benefits are greater.
You can also check [this](https://www.clever-cloud.com/blog/engineering/2015/05/20/why-auto-increment-is-a-terrible-idea/) blog post for more information.

Secondly we haven't added any caching. In my experience a Rails app _like that_  should stand
around 1000 req/minute in a regular heroku dyno X2 (3 puma processes each having 2 workers,
each having ~10 threads giving us in total 60 fronts) but adding cache should take it to 2500.
However I haven't tested that. Is anyone interested to tell me how much he/she manage to
reach? (with or without cache). I would be happy to add an extra sections just for optimizations
from you folks. Just create a PR :D


## That's all folks
That's all for now. You should really start building your Rails API _today_ and not tomorrow.

I am now going to prepare the [Ember](https://github.com/vasilakisfil/ember_on_rails5) tutorial. Until then take care and have fun!

_Did you know that you can contribute to this tutorial by opening an issue or even sending a pull request?_
