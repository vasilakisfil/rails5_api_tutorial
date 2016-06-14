# Ruby on Rails Tutorial sample application

This is the reference implementation of the sample application for the 4th edition of [*Ruby on Rails Tutorial: Learn Web Development with Rails*](http://www.railstutorial.org/) by [Michael Hartl](http://www.michaelhartl.com/).

## Getting started

To get started with the app, clone the repo and then install the needed gems:

```
$ git clone https://bitbucket.org/railstutorial/sample_app_4th_ed.git
$ cd sample_app_4th_ed
$ bundle install --without production
```

Next, migrate the database:

```
$ rails db:migrate
```

Finally, run the test suite to verify that everything is working correctly:

```
$ rails test
```

If the test suite passes, you'll be ready to run the app in a local server:

```
$ rails server
```

On Cloud9, this command should be

```
$ rails server -b $IP -p $PORT
```

instead.

To check out the code for a particular chapter, use

```
$ git checkout chapter-branch-name
```

where you can find the branch name using

```
$ git branch -a
```

A branch called `remotes/orgin/foo-bar` can be checked out using `git checkout foo-bar`.

For more information, see the
[*Ruby on Rails Tutorial* book](http://www.railstutorial.org/book).