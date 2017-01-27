# Users

## List Users
```http
GET /api/v1/users HTTP/1.1
User-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
```
```http
HTTP/1.1 200 OK
{  
  "data":[  
    {  
      "id":"108",
      "type":"users",
      "attributes":{  
        "name":"Filippos Vasilakis",
        "email":"filippos@email.com",
        "created-at":"2017-02-19T15:14:40Z",
        "microposts-count":0,
        "followers-count":0,
        "followings-count":0,
        "following-state":false,
        "follower-state":false
      },
      "relationships":{  
        "microposts":{  
          "links":{  
            "related":"/api/v1/microposts?user_id=7"
          }
        },
        "followers":{  
          "links":{  
            "related":"/api/v1/users/7/followers"
          }
        },
        "followings":{  
          "links":{  
            "related":"/api/v1/users/7/followings"
          }
        }
      }
    }
  ],
  "links":{  
    "self":"http://localhost:3000/api/v1/users?page%5Bnumber%5D=1\u0026page%5Bsize%5D=1\u0026per_page=1",
    "next":"http://localhost:3000/api/v1/users?page%5Bnumber%5D=2\u0026page%5Bsize%5D=1\u0026per_page=1",
    "last":"http://localhost:3000/api/v1/users?page%5Bnumber%5D=105\u0026page%5Bsize%5D=1\u0026per_page=1"
  },
  "meta":{  
    "current-page":1,
    "next-page":2,
    "prev-page":null,
    "total-pages":105,
    "total-count":105
  }
}
```

You can GET all users in `/api/v1/users`.
You can filter the records using a micro-API based on [ActiveHashRelation gem](https://github.com/kollegorna/active_hash_relation).

If you do not authenticate then you only get the `name` attribute of the resource.


## Create a User
```http
POST /api/v1/users HTTP/1.1
User-Agent: MyClient/1.0.0
Accept: application/vnd.api+json

{  
  "data":{  
    "type":"users",
    "attributes":{  
      "password":"123123123",
      "email":"filippos@email.com",
      "name":"Filippos Vasilakis",
    }
  }
}
```
```http
HTTP/1.1 201 OK
{  
  "data":{  
    "id":"108",
    "type":"users",
    "attributes":{  
      "name":"Filippos Vasilakis",
      "email":"filippos@email.com",
      "created-at":"2017-02-19T15:14:40Z",
      "microposts-count":0,
      "followers-count":0,
      "followings-count":0,
      "following-state":false,
      "follower-state":false
    },
    "relationships":{  
      "microposts":{  
        "links":{  
          "related":"/api/v1/microposts?user_id=108"
        }
      },
      "followers":{  
        "links":{  
          "related":"/api/v1/users/108/followers"
        }
      },
      "followings":{  
        "links":{  
          "related":"/api/v1/users/108/followings"
        }
      }
    }
  }
}
```

You can create a new user sending a POST to `/api/v1/users` with the necessary attributes.
A user object should at least include, an email, a password
It doesn't require authentication.


## Show a User
```http
GET /api/v1/users/1 HTTP/1.1
User-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
```
```http
HTTP/1.1 200 OK
{  
  "data":{  
    "id":"108",
    "type":"users",
    "attributes":{  
      "name":"Filippos Vasilakis",
      "email":"filippos@email.com",
      "created-at":"2017-02-19T15:14:40Z",
      "microposts-count":0,
      "followers-count":0,
      "followings-count":0,
      "following-state":false,
      "follower-state":false
    },
    "relationships":{  
      "microposts":{  
        "links":{  
          "related":"/api/v1/microposts?user_id=108"
        }
      },
      "followers":{  
        "links":{  
          "related":"/api/v1/users/108/followers"
        }
      },
      "followings":{  
        "links":{  
          "related":"/api/v1/users/108/followings"
        }
      }
    }
  }
}
```

You can retrieve a user's info by sending a GET request to `/api/v1/users/{id}`.


## Update a User
```http
PUT /api/v1/users/1 HTTP/1.1
User-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
{
  "user": {
    "name":"Philipp",
  }
}
```
```http
HTTP/1.1 200 OK
{  
  "data":{  
    "id":"108",
    "type":"users",
    "attributes":{  
      "name":"Philipp Vasilakis",
      "email":"filippos@email.com",
      "created-at":"2017-02-19T15:14:40Z",
      "microposts-count":0,
      "followers-count":0,
      "followings-count":0,
      "following-state":false,
      "follower-state":false
    },
    "relationships":{  
      "microposts":{  
        "links":{  
          "related":"/api/v1/microposts?user_id=108"
        }
      },
      "followers":{  
        "links":{  
          "related":"/api/v1/users/108/followers"
        }
      },
      "followings":{  
        "links":{  
          "related":"/api/v1/users/108/followings"
        }
      }
    }
  }
}
```
You can update a user's attributes by sending a PUT request to `/api/v1/users/{id}` with the necessary attributes.


## Destroy a User
```http
DELETE /api/v1/users/1 HTTP/1.1
User-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
```
```http
HTTP/1.1 200 OK
{  
  "data":{  
    "id":"108",
    "type":"users",
    "attributes":{  
      "name":"Philipp Vasilakis",
      "email":"filippos@email.com",
      "created-at":"2017-02-19T15:14:40Z",
      "microposts-count":0,
      "followers-count":0,
      "followings-count":0,
      "following-state":false,
      "follower-state":false
    },
    "relationships":{  
      "microposts":{  
        "links":{  
          "related":"/api/v1/microposts?user_id=108"
        }
      },
      "followers":{  
        "links":{  
          "related":"/api/v1/users/108/followers"
        }
      },
      "followings":{  
        "links":{  
          "related":"/api/v1/users/108/followings"
        }
      }
    }
  }
}
```

You get back the deleted user.


## Activate

```http
DELETE /api/v1/users/activate?token=0123 HTTP/1.1
User-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
```
```http
HTTP/1.1 200 OK
{  
  "data":{  
    "id":"108",
    "type":"users",
    "attributes":{  
      "name":"Philipp Vasilakis",
      "email":"filippos@email.com",
      "created-at":"2017-02-19T15:14:40Z",
      "microposts-count":0,
      "followers-count":0,
      "followings-count":0,
      "following-state":false,
      "follower-state":false
    },
    "relationships":{  
      "microposts":{  
        "links":{  
          "related":"/api/v1/microposts?user_id=108"
        }
      },
      "followers":{  
        "links":{  
          "related":"/api/v1/users/108/followers"
        }
      },
      "followings":{  
        "links":{  
          "related":"/api/v1/users/108/followings"
        }
      }
    }
  }
}
```

To activate a user you will need the unique token sent in the activation email, after the user signs up.

You get back the activated user.
