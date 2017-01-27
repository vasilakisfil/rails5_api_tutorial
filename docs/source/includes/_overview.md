# Overview

## General Notes
You are encouraged to always provide a valid `user-agent` string.

## Current Version

The current version of API is V1. The version is defined on the resource, thus reflecting
the resource version and not in the Accept header.

```http
GET /api/v1/resource HTTP/1.1
User-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
Host: rails-tutorial-api.heroku.com
```

## DateTimes representations


All date/time representations are on ISO 8601 format:
```
YYYY-MM-DDTHH:MM:SSZ
```
The returned timezone is UTC.

## Client Errors
```http
HTTP/1.1 400 Bad Request
{  
  "errors":[  
    {  
      "status":400,
      "title":"JSON has wrong syntax",
      "detail":"can't be blank",
      "source":{  
        "pointer":"data"
      }
    }
  ]
}
```
```http
HTTP/1.1 422 Unprocessable Entity
{  
  "errors":[  
    {  
      "status":422,
      "title":"can't be blank",
      "detail":"can't be blank",
      "source":{  
        "pointer":"data/attributes/name"
      }
    },
    {  
      "status":422,
      "title":"can't be blank",
      "detail":"can't be blank",
      "source":{  
        "pointer":"data/attributes/email"
      }
    },
    {  
      "status":422,
      "title":"is invalid",
      "detail":"is invalid",
      "source":{  
        "pointer":"data/attributes/email"
      }
    },
    {  
      "status":422,
      "title":"can't be blank",
      "detail":"can't be blank",
      "source":{  
        "pointer":"data/attributes/password"
      }
    }
  ]
}
```
```http
HTTP/1.1 401 Unprocessable Entity
{  
  "errors":[  
    {  
      "status":401,
      "title":"Not Authenticated",
      "detail":"Not Authenticated",
      "source":{  
        "pointer":"data"
      }
    }
  ]
}
```
```http
HTTP/1.1 403 Unprocessable Entity
{  
  "errors":[  
    {  
      "status":401,
      "title":"Not Authorized for this action",
      "detail":"Not Authorized for this action",
      "source":{  
        "pointer":"data"
      }
    }
  ]
}
```
```http
HTTP/1.1 500 Unprocessable Entity
{  
  "errors":[  
    {  
      "status":401,
      "title":"Something went terribly wrong here. Open a github issue :)",
      "detail":"Something went terribly wrong here. Open a github issue :)",
      "source":{  
        "pointer":"data"
      }
    }
  ]
}
```

The client errors are pretty basic, yet helpful.

Error Code | Meaning
---------- | -------
400 | Bad Request -- You have a critical error on your request, like bad JSON representation
401 | Unauthorized -- You try to access a protected resource without providing authentication credentials or with wrong credentials
403 | Forbidden -- You try to access or act on a protected resource but your credentials that you provide do not authorize your action for that resource.
404 | Not Found -- The specified kitten could not be found
405 | Method Not Allowed -- You tried to access a kitten with an invalid method
406 | Not Acceptable -- You requested a format that isn't json
422 | lalala -- Your request is understood but you miss a required param, or part of your json is in wrong format (like sending an date object in an integer param)
429 | Too Many Requests -- Slown down! Follow the rate limits!
500 | Internal Server Error -- Something went terribly wrong, open a gihub issue :) 


## Authentication

In order to be able to act on behalf of a user, you must first retrieve her token
via the [sessions](#sessions) endpoint.


## Authorization
```http
GET /api/v1/microposts/1 HTTP/1.1
User-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
Host: rails-tutorial-api.heroku.com
Authorization: Token token="TnQfBY1S/aMdO46sUfXx8mkPa4yxawqgaqVlD2YNzj19QlGI02eFIpoj9YaBtXm3efQZt5oXIQ6DpBw9gvuVGA==", user_email="example@railstutorial.org"
```

You can authenticate in the API by providing the user's token and email in the `Authorization` header.




## Pagination
```http
GET /api/v1/resource?page=2&per_page=100 HTTP/1.1
User-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
Host: rails-tutorial-api.heroku.com
```

Requests that return multiple items will be paginated to 30 items by default.
You can specify further pages with the `?page` parameter.
For some resources, you can also set a custom page size up to 100 with the `?per_page` parameter.


## Rate Limiting
```http
HTTP/1.1 200 OK
Date: Mon, 01 Jul 2013 17:27:06 GMT
Status: 200 OK
X-Ratelimit-Limit: 100000
X-Ratelimit-Remaining: 99994
```

You can check the returned HTTP headers of any API request to see your current rate limit status.

It should be noted that the rate limit is variable, depending on the server load. Please stay on the limits.

If you have abused the limits, you will receive a 429 error as described in the [Client Errors](#client-errors)

<aside class="notice">
Although there are no hard limits, you should follow the limits defined on the API response
</aside>



## Cross Origin Resource Sharing
The API supports Cross Origin Resource Sharing (CORS) for AJAX requests from any origin.

## Meta Data
```http
GET /api/v1/resources HTTP/1.1
User-Agent: MyClient/1.0.0
Accept: application/vnd.api+json
```
```http
HTTP/1.1 200 OK
{
  "resources": [
  ],
  "meta":{
    "current_page":45,
    "next_page":46,
    "prev_page":44,
    "total_pages":53,
    "total_count":105
  }
}
```

In each GET request that acts upon resources, there is an extra field in the response under "meta" root element.
It includes, the current requested page, next page, previous page, total pages and the total number of resources under the given params.


## Filtering
In some resource you are allowed to filter the collection based on some predefined query params.
For instance, you might be able to filter based on `user_id`.
That is, sending `GET /api/v1/resources?user_id=1` will ask all resources of type `resource` that have `user_id=1`.
You can also send an array instead of a value: `GET /api/v1/resources?state[]=draft&state[]=failed` which will ask all resources of type `resource` that have `state` `draft` or `failed`.
The filter params that are supported and the available actions on them are described per resource.

## Sparsed fields
Some resources clearly state that they support spared fields, meaning that you can specify which fields the server should send you back regadless if you ask a collection or a single resource using the `fields` param.
Although usually supplying a `fields` param can help API memory as well as performance, for each resource/collection there are default fields in case you don't provide any `fields` param.
You can also use `fields` param to request specific fields on the resource (that are not included on the defaults but you do have permission for them) that take more time to be computed than the rest fields (for instance, fields computed by talking to an external API).

* `GET /api/v1/resources?fields[]=id&fields[]=description`: get only `id` and `description` from collection of type `resource`.

You can't specify fields on associations.
Avaliable/returned fields depend on the session user permissions.


## Other information
When requesting a list of resources, default sorting is descending by creation datetime.

For all collection endpoints, active_hash_relation has been used which means you have plenty
options to filter 
