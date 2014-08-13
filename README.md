# SinatraAdmin

Sinatra application that allow us to have an admin dashboard with the
minimal effort.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sinatra-admin'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sinatra-admin

## Usage

By default SinatraAdmin assumes that it's mounted over an "admin"
namespace. This is how SinatraAdmin should be configured:

1. Define your project namespace and your Sinatra applications.
```ruby
module MyApp
  class API < Sinatra::Base
  end

  class Admin < Sinatra::Base
  end
end
```

2. Add SinatraAdmin::App middleware to your admin application.
```ruby
class MyApp::Admin < Sinatra::Base
  use SinatraAdmin::App
end
```

3. Register model resources(let's assume that we have User and Comment
   models). It created the 7 REST actions to /create/update/remove
   records.
```ruby
class MyApp::Admin < Sinatra::Base
  SinatraAdmin.register 'User'
  SinatraAdmin.register 'Comment'
end
```

4. Define your root resource(optional). This is going to be the first
   page where the application is going to redirect you after the login.
   SinatraAdmin defines the first registered resource as the default root. 
   In this case it will get 'User'(according to pint number 3). Anyway, 
   if you want to set a different resource as the default one you can 
   do it.
```ruby
class MyApp::Admin < Sinatra::Base
  SinatraAdmin.root 'Comment'
end
```

5. Define your custom resources. Having model resources sometimes is not
   enough and we might want to see some stats about our application. An
   example could be: "As an admin I want to see how many user accounts has
   been registered". Let's take a look how to define custom resources.
```ruby
class MyApp::Admin < Sinatra::Base
  SinatraAdmin.register 'Stats' do
    get '/?' do
      @message = 'Welcome to SinatraAdmin custom pages!'
      @accounts_counter = User.count
      haml 'stats/index'.to_sym
    end
  end
end
```
If you try to access that custom page you are going to see an exception
saying something like: "Errno::ENOENT at /admin/stats No such file or
directory - /path/to/the/gem/sinatra-admin/views/stats/index.haml"
It's because SinatraAdmin tries to find the template in the views
folder of sinatra-admin. Obviously that custom template does not exist in the gem.
SinatraAdmin has a method to extend the views path and it allows us to
find the template that we are looking for. It takes us to the next
point.

6. Extend your views path(Only for custom resources). SinatraAdmin has
   the method :extend_views_from. This method receives a value that
   should be either a String instance with the path to views folder or a Sinatra application.
   SinatraAdmin expects to be mounted over an "admin" namespace, that's why it's going to look the view in: the/extented/path/admin
```ruby
class MyApp::Admin < Sinatra::Base
  SinatraAdmin.extend_views_from(MyApp::API) #It'll look at path/to/my_app/api/views/admin/stats/index.haml
  SinatraAdmin.extend_views_from('path/to/views/folder') #It'll look at path/to/views/folder/admin/stats/index.haml
end
```

7. Wrapping it up.
```ruby
class MyApp::Admin < Sinatra::Base
  use SinatraAmin::App
  SinatraAdmin.root 'Post'
  SinatraAdmin.resource 'User'
  SinatraAdmin.resource 'Comment'
  SinatraAdmin.resource 'Post'
  SinatraAdmin.register 'Stats' do
    get '/?' do
      @message = 'Welcome to SinatraAdmin custom pages!'
      @accounts_counter = User.count
      haml 'stats/index'.to_sym
    end
  end
  SinatraAdmin.extend_views_from(MyApp::API)
end
```

8. Run it. We assume you're using a config.ru file to run your Sinatra
   application. This is how it should look like:
```ruby
require 'path/to/my_app/api'
require 'path/to/my_app/admin'

map "/api"
  run MyApp::API
end

map "/admin" do #mounted over "/admin" namespace(mandatory)
  run MyApp::Admin
end
```

## Constraints

* SinatraAdmin only works if you mount it over "admin" namespace like in
the example(Point 8).

* Even when you can pass a block with get/post/put/patch/delete when you
register a model resource(like User) SinatraAdmin does not have any way to access
them(only the URL). This is a TODO feature.

* Even when you can pass a block with post/put/patch/delete when you
register a custom resource(Like MyStats) SinatraAdmin does not have any way to
access them(only the URL). This is a TODO feature.

## Notes

* SinatraAdmin uses Mongoid by default. TODO: Add activeRecord support.
 
* SinatraAdmin uses Warden for authentication.

* SinatraAdmin comes with an Admin model by default. The constant is
SinatraAdmin::Admin. It has :first_name, :last_name, :email and
:password fields. Password is encrypted and stored in :password_hash
field. :email and :password are required fields and :email should have a correct format.

* You can contribute to this Project. Contributing means not only adding features but also writing documentation, adding issues, refactoring code or jut sending us either a <3 if you liked the project or a </3 if you do not like it ;)

* Current version: 0.0.1

## Contributing

1. Fork it ( https://github.com/[my-github-username]/sinatra-admin/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
