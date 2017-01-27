# Sessions

## Create a Session
```http
POST /api/v1/sessions HTTP/1.1
User-Agent: MyClient/1.0.0
Accept: application/vnd.api+json

{  
  "data":{  
    "type":"users",
    "attributes":{  
      "email":"filippos@email.com",
      "password":"123123123",
    }
  }
}
```
```http
HTTP/1.1 201 OK
{  
  "data":{  
    "id":"8",
    "type":"session",
    "attributes":{  
      "email":"filippos@email.com",
      "token":"3137ace44910cabf79fbbf8823869d72",
      "user-id":8
    },
    "relationships":{  
      "user":{  
        "data":{  
          "id":"8",
          "type":"users"
        },
        "links":{  
          "self":"/api/v1/users/8",
          "related":"/api/v1/users/8"
        }
      }
    }
  },
  "included":[  
    {  
      "id":"8",
      "type":"users",
      "attributes":{  
        "name":"Filippos Vasilakis",
        "email":"filippos@email.com",
        "created-at":"2016-11-05T10:15:27Z",
        "microposts-count":0,
        "followers-count":0,
        "followings-count":0,
        "following-state":false,
        "follower-state":false
      },
      "relationships":{  
        "microposts":{  
          "links":{  
            "related":"/api/v1/microposts?user_id=8"
          }
        },
        "followers":{  
          "links":{  
            "related":"/api/v1/users/8/followers"
          }
        },
        "followings":{  
          "links":{  
            "related":"/api/v1/users/8/followings"
          }
        }
      }
    }
  ]
}
```

Creates a new session by creating a new user token to be used for any authenticated request.

## Show a Session
Shows the current session.


```http
GET /api/v1/session/1 HTTP/1.1
User-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
```
```http
HTTP/1.1 200 OK
{  
  "data":{  
    "id":"8",
    "type":"session",
    "attributes":{  
      "email":"filippos@email.com",
      "token":"3137ace44910cabf79fbbf8823869d72",
      "user-id":8
    },
    "relationships":{  
      "user":{  
        "data":{  
          "id":"8",
          "type":"users"
        },
        "links":{  
          "self":"/api/v1/users/8",
          "related":"/api/v1/users/8"
        }
      }
    }
  },
  "included":[  
    {  
      "id":"8",
      "type":"users",
      "attributes":{  
        "name":"Filippos Vasilakis",
        "email":"filippos@email.com",
        "created-at":"2016-11-05T10:15:27Z",
        "microposts-count":0,
        "followers-count":0,
        "followings-count":0,
        "following-state":false,
        "follower-state":false
      },
      "relationships":{  
        "microposts":{  
          "links":{  
            "related":"/api/v1/microposts?user_id=8"
          }
        },
        "followers":{  
          "links":{  
            "related":"/api/v1/users/8/followers"
          }
        },
        "followings":{  
          "links":{  
            "related":"/api/v1/users/8/followings"
          }
        }
      }
    }
  ]
}
```
