# Feed

The feed of a user is a list of microposts of users she follows order by `created_at` in a descending order.

## Show Feed
```http
GET /api/v1/users/1/followings HTTP/1.1
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

If you want to filter the microposts, use the [microposts](#microposts) API.
