# Followers

Followings is the users that a user follows.

## List Followers
```http
GET /api/v1/users/1/followers HTTP/1.1
Micropost-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
```
```http
HTTP/1.1 200 OK
{  
  "data":[  
    {  
      "id":"2",
      "type":"users",
      "attributes":{  
        "name":"Lucio Luettgen",
        "email":"example-1@railstutorial.org",
        "created-at":"2016-11-05T10:15:26Z",
        "microposts-count":50,
        "followers-count":1,
        "followings-count":1,
        "following-state":false,
        "follower-state":false
      },
      "relationships":{  
        "microposts":{  
          "links":{  
            "related":"/api/v1/microposts?user_id=2"
          }
        },
        "followers":{  
          "links":{  
            "related":"/api/v1/users/2/followers"
          }
        },
        "followings":{  
          "links":{  
            "related":"/api/v1/users/2/followings"
          }
        }
      }
    }
  ],
  "links":{  
    "self":"http://localhost:3000/api/v1/users/1/followings?page%5Bnumber%5D=1&page%5Bsize%5D=1&per_page=1",
    "next":"http://localhost:3000/api/v1/users/1/followings?page%5Bnumber%5D=2&page%5Bsize%5D=1&per_page=1",
    "last":"http://localhost:3000/api/v1/users/1/followings?page%5Bnumber%5D=48&page%5Bsize%5D=1&per_page=1"
  },
  "meta":{  
    "current-page":1,
    "next-page":2,
    "prev-page":null,
    "total-pages":48,
    "total-count":48
  }
}
```

You can GET all followers of a user in `/api/v1/users/{userId}/followings`.
You can filter the records using a micro-API based on [ActiveHashRelation gem](https://github.com/kollegorna/active_hash_relation).


### Destroy
Remove a follower, e.g. somebody that follows you

```http
DELETE /api/v1/users/1/followers/12 HTTP/1.1
Micropost-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
```
```http
HTTP/1.1 200 OK
{  
  "data":{  
    "id":"12",
    "type":"users",
    "attributes":{  
      "name":"Mckayla Okuneva DDS",
      "email":"example-11@railstutorial.org",
      "created-at":"2016-11-05T10:15:27Z",
      "microposts-count":0,
      "followers-count":1,
      "followings-count":1,
      "following-state":false,
      "follower-state":false
    },
    "relationships":{  
      "microposts":{  
        "links":{  
          "related":"/api/v1/microposts?user_id=12"
        }
      },
      "followers":{  
        "links":{  
          "related":"/api/v1/users/12/followers"
        }
      },
      "followings":{  
        "links":{  
          "related":"/api/v1/users/12/followings"
        }
      }
    }
  }
}
```

Here, user 1 removes follower user 12.
