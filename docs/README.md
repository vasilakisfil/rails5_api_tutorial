# Ruby on Rails API tutorial Readme

[ ![Codeship Status for vasilakisfil/rails5_api_tutorial](https://app.codeship.com/projects/05259880-c6b4-0134-9508-6e9b40f38dec/status?branch=master)](https://app.codeship.com/projects/198686)

This is the sample application for the
[*Ruby on Rails Tutorial:
Learn Web Development with Rails*](http://www.railstutorial.org/)
by [Michael Hartl](http://www.michaelhartl.com/) **but with an API for the [Ember version](https://github.com/vasilakisfil/ember_on_rails5)**,
used by the [api tutorial](https://github.com/vasilakisfil/rails5_api_tutorial).

It's deployed [here](https://rails-tutorial-api.herokuapp.com/).
Ember version is deployed [here](https://ember-on-rails-tutorial.herokuapp.com) based on this [repo](https://github.com/vasilakisfil/ember_on_rails5)

If you are looking the Rails 4 version there is a [blog post](https://labs.kollegorna.se/blog/2015/04/build-an-api-now/)

## License

All code added by me (vasilakisfil) is availabe under the MIT License.
The rest is available jointly under the MIT License and the Beerware License. See [LICENSE.md](LICENSE.md) for details.

## Getting started

To get started with the app, clone the repo and then install the needed gems:

```
cd ~/tmp
git clone https://github.com/vasilakisfil/rails5_api_tutorial.git
cd rails5_api_tutorial
bundle install
bundle exec rake db:create #we use postgresql instead of sqlite3
bundle exec rake db:migrate
bundle exec rails s
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vasilakisfil/rails5_api_tutorial.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
