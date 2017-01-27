# Microposts

## List Microposts
```http
GET /api/v1/microposts HTTP/1.1
Micropost-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
```
```http
HTTP/1.1 200 OK
{  
  "data":[  
    {  
      "id":"349",
      "type":"microposts",
      "attributes":{  
        "content":"test",
        "user-id":1,
        "created-at":"2016-11-19T18:56:55Z",
        "updated-at":"2016-11-19T18:56:55Z"
      },
      "relationships":{  
        "user":{  
          "links":{  
            "related":"/api/v1/users/1"
          }
        }
      }
    }
  ],
  "links":{  
    "self":"http://localhost:3000/api/v1/microposts?page%5Bnumber%5D=1\u0026page%5Bsize%5D=1\u0026per_page=1",
    "next":"http://localhost:3000/api/v1/microposts?page%5Bnumber%5D=2\u0026page%5Bsize%5D=1\u0026per_page=1",
    "last":"http://localhost:3000/api/v1/microposts?page%5Bnumber%5D=349\u0026page%5Bsize%5D=1\u0026per_page=1"
  },
  "meta":{  
    "current-page":1,
    "next-page":2,
    "prev-page":null,
    "total-pages":349,
    "total-count":349
  }
}
```

You can GET all microposts in /api/v1/microposts.
You can filter the records using a micro-API based on [ActiveHashRelation gem](https://github.com/kollegorna/active_hash_relation).


## Create a Micropost
```http
POST /api/v1/microposts HTTP/1.1
Micropost-Agent: MyClient/1.0.0
Accept: application/vnd.api+json

{  
  "data":{  
    "type":"microposts",
    "attributes":{  
      "micropost": {
        "content":"A simple micropost",
        "user_id":1
      }
    }
  }
}
```
```http
HTTP/1.1 201 OK
{  
  "data":{  
    "id":"1",
    "type":"microposts",
    "attributes":{  
      "content":"A simple micropost",
      "user-id":1,
      "created-at":"2016-11-05T10:15:37Z",
      "updated-at":"2016-11-05T10:15:37Z"
    },
    "relationships":{  
      "user":{  
        "links":{  
          "related":"/api/v1/users/1"
        }
      }
    }
  }
}
```

You can create a new micropost sending a POST to `/api/v1/microposts` with the necessary attributes.
A micropost object should at least include, content and a `user_id`.
A user can create only micropost with her own `user_id`.

## Show a Micropost
```http
GET /api/v1/microposts/1 HTTP/1.1
Micropost-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
```
```http
HTTP/1.1 200 OK
{  
  "data":{  
    "id":"1",
    "type":"microposts",
    "attributes":{  
      "content":"A simple micropost",
      "user-id":1,
      "created-at":"2016-11-05T10:15:37Z",
      "updated-at":"2016-11-05T10:15:37Z"
    },
    "relationships":{  
      "user":{  
        "links":{  
          "related":"/api/v1/users/1"
        }
      }
    }
  }
}
```
You can retrieve a micropost's info by sending a GET request to `/api/v1/microposts/{id}`.


## Update a Micropost
```http
PUT /api/v1/microposts/1 HTTP/1.1
Micropost-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
{  
  "data":{  
    "type":"microposts",
    "attributes":{  
      "micropost": {
        "content":"Another micropost",
      }
    }
  }
}
```
```http
HTTP/1.1 200 OK
{  
  "data":{  
    "id":"1",
    "type":"microposts",
    "attributes":{  
      "content":"Another micropost",
      "user-id":1,
      "created-at":"2016-11-05T10:15:37Z",
      "updated-at":"2016-11-05T10:15:37Z"
    },
    "relationships":{  
      "user":{  
        "links":{  
          "related":"/api/v1/users/1"
        }
      }
    }
  }
}
```
You can update a micropost's attributes by sending a PUT request to `/api/v1/microposts/{id}` with the necessary attributes.


## Destroy a Micropost
```http
DELETE /api/v1/microposts/1 HTTP/1.1
Micropost-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
```
```http
HTTP/1.1 200 OK
{  
  "data":{  
    "id":"1",
    "type":"microposts",
    "attributes":{  
      "content":"Another micropost",
      "user-id":1,
      "created-at":"2016-11-05T10:15:37Z",
      "updated-at":"2016-11-05T10:15:37Z"
    },
    "relationships":{  
      "user":{  
        "links":{  
          "related":"/api/v1/users/1"
        }
      }
    }
  }
}
```

You get back the deleted micropost.
