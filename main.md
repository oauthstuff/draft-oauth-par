%%%
title = "OAuth 2.0 Pushed Authorization Requests"
abbrev = "oauth-par"
ipr = "trust200902"
area = "Security"
workgroup = "Web Authorization Protocol"
keyword = ["security", "oauth2"]

date = 2019-09-10T12:00:00Z

[seriesInfo]
name = "Internet-Draft"
value = "draft-lodderstedt-oauth-par-00"
stream = "IETF"
status = "standard"

[[author]]
initials="T."
surname="Lodderstedt"
fullname="Torsten Lodderstedt"
organization="yes.com"
    [author.address]
    email = "torsten@lodderstedt.net"

[[author]]
initials="B."
surname="Campbell"
fullname="Brian Campbell"
organization="Ping Identity"
    [author.address]
    email = "bcampbell@pingidentity.com"
    
 [[author]]
initials="N."
surname="Nat"
fullname="Nat Sakimura"
organization="Nomura Research Institute"
    [author.address]
    email = "nat@sakimura.org"
 
 [[author]]
initials="D."
surname="Tonge"
fullname="Dave Tonge"
organization="Momentum Financial Technology"
    [author.address]
    email = "dave.tonge@momentumft.co.uk"    
    
%%%

.# Abstract 

This document defines the pushed authorization request endpoint. It allows
clients to push the payoad of an OAuth 2.0 authorization request to the
authorization server via a direct server to server request and provides them
wih a request URI that is used as reference to this data in a sub-sequent authorization request.   

{mainmatter}

# Introduction {#Introduction}

In OAuth [@!RFC6749] authorization request parameter are sent as URI query 
parameters. This is simple but also yields challenges:

* integrity
* authenticity
* confidentiality of parameter values
* size

JAR provides solutions for those challenges by allowing OAuth clients 
to wrap authorization request parameters in a signed, and optionally encrypted, 
JWT, the so-called "request object". 

In order to cope with the size restrictions, JAR introduces the `request_uri`
parameter that allows clients to send a reference to a request object 
instead of the request object itself.    

This draft complements JAR by providing an interoperable way to push 
the payload of a request object to the AS in exchange for a `request_uri`.

And it goes one step further by also allowing clients to push the  
format encoded authorization request parameters to the AS and  
turn them into a request URI that the client can refer to in an authorization request. 

For example, the authorization request

```
GET /authorize?response_type=code&client_id=s6BhdRkqt3&state= af0ifjsldkj
       &redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb
       
```

could be send by the client as

```
POST https://as.example.com/ros/ HTTP/1.1
Host: as.example.com
Content-Type: application/x-www-form-urlencoded
Authorization: Basic czZCaGRSa3F0Mzo3RmpmcDBaQnIxS3REUmJuZlZkbUl3

response_type=code&
client_id=s6BhdRkqt3&
state= af0ifjsldkj&
redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb
```

The AS responds with a request URI,  

```
HTTP/1.1 201 Created
Date: Tue, 2 May 2017 15:22:31 GMT
Content-Type: application/json

{

   "request_uri": "urn:example:GkurKxf5T0Y-mnPFCHqWOMiZi4VS138cQO_V7PZHAdM",
   "expires_in": 3600
}
```

which is used by the client in the authorization request as shown in the following

```
GET /authorize?request_uri=urn:example:GkurKxf5T0Y-mnPFCHqWOMiZi4VS138cQO_V7PZHAdM
```

This way the pushed authorization request endpoint fosters OAuth security by providing all clients a simple migration path to integrity protected authorization request, but it als also allows clients requiring an even higher secrity level, especially cryptographially confirmed non-repudiation, to explitely adopt JWT-based request objects.   

## Conventions and Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED",
"MAY", and "OPTIONAL" in this document are to be interpreted as
described in BCP 14 [@!RFC2119] [@!RFC8174] when, and only when, they
appear in all capitals, as shown here.

This specification uses the terms "access token", "refresh token",
"authorization server", "resource server", "authorization endpoint",
"authorization request", "authorization response", "token endpoint",
"grant type", "access token request", "access token response", and
"client" defined by The OAuth 2.0 Authorization Framework [@!RFC6749].

# Pushed Authorization Request Endpoint

The request object endpoint shall be a RESTful API at the authorization server that accepts `x-www-form-urlencoded` POST request.

The endpoint accepts the parameters defined in [@!RFC6749] for the authorization endpoint as well as all extensions defined for the authorization endpoint. Examples include PKCE, JAR, ...., OpenID Connect.

The rules for client authentication as defined in [@!RFC6749] for token endpoint requests, including the applicable authentication methods, apply for the pushed authorization request endpoint as well. If applicable, the `token_endpoint_auth_method` client metadata parameter indicates the registered authentication method for the client to use when making direct requests to the authorization server, including requests to the pushed authorization endpoint. 

Note that there's some potential ambiguity around the appropriate audience 
value to use when JWT client assertion based authentication is employed. To address that ambiguity the issuer URL of the AS according to [RFC8414] MUST be used as the value of the audience. 

## Request {#request}

A client can send all parameter that usually comprise an authorization request to the pushed authorization request endpoint. A basic parameter set will typical include:

* `response_type`
* `redirect_uri`
* `scope`
* `state` 
* `code_challenge`  
* `code_challenge_method`  

Depending on client type and authentication method, the request might also include the `client_id`. The client adds these parameters in `x-www-form-urlencoded` format to the body of a HTTP POST request. If applicable, the client also adds client credentials to the request header or the request body using the same rules as for token requests.

This is illustrated by the following example

```
POST https://as.example.com/ros/ HTTP/1.1
Host: as.example.com
Content-Type: application/x-www-form-urlencoded
Authorization: Basic czZCaGRSa3F0Mzo3RmpmcDBaQnIxS3REUmJuZlZkbUl3

response_type=code&
client_id=s6BhdRkqt3&
state=af0ifjsldkj&
redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb&
code_challenge=K2-ltc83acc4h0c9w6ESC_rEMTJ3bww-uCHaoeK1t8U&
code_challenge_method=S256&
scope=ais
```

The AS MUST process the request as follows:

1. The AS MUST authenticate the client in same way as at the token endpoint.
2. The AS MUST validate the request the same way as at the authorization endpoint. For example, the authorization server checks, whether the redirect URI matches one of the redirect URIs configured for the `client_id`. It may also check whether the client is authorized for the `scope` for which it requested access. This validation allows the authorization server to refuse unauthorized or fraudulent requests early. 

## Successful Response

If the verification is successful, the server shall generate a request URI and return a JSON payload that contains `request_uri` and `expires_in` claims at the top level with `201 Created` HTTP response code.

* `request_uri` : The request URI corresponding to the request object posted. This URI is used as reference to the respective request object in subsequent authorization requests only. The way the authorization process obtains the request object data is at the discretion of the authorization server and out of scope of this specification. There is no need to make the request object data available to other parties via this URI.
* `expires_in` : A JSON number that represents the lifetime of the request URI in seconds. The request URI lifetime is at the discretion of the AS.

The `request_uri` value MUST be generated using a cryptographically strong pseudorandom algorithm such that it is computationally infeasible to predict or guess a valid value.   

The `request URI` MUST be bound to the `client_id` of the client that posted the authorization request.

Since the request URI can be replayed, its lifetime SHOULD be short and preferably limited to one-time use.

The following is an example of such a response:

```
HTTP/1.1 201 Created
Date: Tue, 2 May 2017 15:22:31 GMT
Content-Type: application/json

{
    "request_uri": "urn:example:GkurKxf5T0Y-mnPFCHqWOMiZi4VS138cQO_V7PZHAdM",
    "expires_in": 3600
}
``` 

## Error Response {#error_response}

### Error responses

#### Authentication required
If the client authentication fails, the authorization server shall return `401 Unauthorized` HTTP error response.

#### Authorization required
If the client is not authorized to perform the authorization request it wanted to post, the authorization server shall return `403 Forbidden` HTTP error response.

#### Invalid request
If the request object received is invalid, the authorization server shall return `400 Bad Request` HTTP error response.

#### Method not allowed
If the request did not use POST, the authorization server shall return `405 Method Not Allowed` HTTP error response.

#### Request entity too large
If the request size was beyond the upper bound that the authorization server allows, the authorization server shall return a `413 Request Entity Too Large` HTTP error response.

#### Too many requests
If the request from the client per a time period goes beyond the number the authorization server allows, the authorization server shall return a `429 Too Many Requests` HTTP error response.

# "request" Parameter

Clients MAY use the `request` parameter as defined in JAR to push a request object to the AS. The rules for signing and encryption of the request object as defined in [JAR] apply.  

The following is an example of a request using a signed request object. The client is authenticated using its client secret `BASIC` authorization:

```
POST https://as.example.com/ros/ HTTP/1.1
Host: as.example.com
Content-Type: application/x-www-form-urlencoded
Authorization: Basic czZCaGRSa3F0Mzo3RmpmcDBaQnIxS3REUmJuZlZkbUl3

request=eyJraWQiOiJrMmJkYyIsImFsZyI6IlJTMjU2In0.eyJpc3MiOiJzNkJoZ
FJrcXQzIiwiYXVkIjoiaHR0cHM6Ly9zZXJ2ZXIuZXhhbXBsZS5jb20iLCJyZXNwb2
5zZV90eXBlIjoiY29kZSIsImNsaWVudF9pZCI6InM2QmhkUmtxdDMiLCJyZWRpcmV
jdF91cmkiOiJodHRwczovL2NsaWVudC5leGFtcGxlLm9yZy9jYiIsInNjb3BlIjoi
YWlzIiwic3RhdGUiOiJhZjBpZmpzbGRraiIsImNvZGVfY2hhbGxlbmdlIjoiSzItb
HRjODNhY2M0aDBjOXc2RVNDX3JFTVRKM2J3dy11Q0hhb2VLMXQ4VSIsImNvZGVfY2
hhbGxlbmdlX21ldGhvZCI6IlMyNTYifQ.O49ffUxRPdNkN3TRYDvbEYVr1CeAL64u
W4FenV3n9WlaFIRHeFblzv-wlEtMm8-tusGxeE9z3ek6FxkhvvLEqEpjthXnyXqqy
Jfq3k9GSf5ay74ml_0D6lHE1hy-kVWg7SgoPQ-GB1xQ9NRhF3EKS7UZIrUHbFUCF0
MsRLbmtIvaLYbQH_Ef3UkDLOGiU7exhVFTPeyQUTM9FF-u3K-zX-FO05_brYxNGLh
VkO1G8MjqQnn2HpAzlBd5179WTzTYhKmhTiwzH-qlBBI_9GLJmE3KOipko9TfSpa2
6H4JOlMyfZFl0PCJwkByS0xZFJ2sTo3Gkk488RQohhgt1I0onw
```

Tthe AS needs to take the following steps beyond the processing rules defined in (#request):

1. If applicable, the AS decrypts the request object as specified in [JAR], section 6.1.
1. The AS validates the request object signature as specified in [JAR], section 6.2.
1. If the client is a confidential client, the authorization server MUST check whether the authenticated `client_id` matches the `client_id` claim in the request objects. If they do not match, the authorization server MUST refuse to process the request. It is at the authorization server's discretion to require the `iss` claim to match the `client_id` as well.

## Error responses for Request Object
This section gives the error responses that go beyond the basic (#error_response).

### Authentication Required
If the signature validation fails, the authorization server shall return `401 Unauthorized` HTTP error response. The same applies if the `client_id` or, if applicable, the `iss` claims in the request object do not match the authenticated `client_id`.

# Authorization Request

The client uses the `request_uri` value as returned by the authorization server as authorization request parameter `request_uri`.

```
https://as.example.com/authorize?
request_uri=urn:example:GkurKxf5T0Y-mnPFCHqWOMiZi4VS138cQO_V7PZHAdM
```
Clients are encouraged to use the request URI as the only parameter in order to use the integrity and authenticity provided by the pushed request object.

# Authorization Server Metadata

If the authorization server has a pushed authorization request endpoint, it SHOULD include the following OAuth/OpenID Provider Metadata parameter in discovery responses:

`pushed_authorization_request_endpoint` : The url of the request object endpoint at which the client can exchange a request object for a request URI.


# Security Considerations

## Request URI Guessing
An attacker could attempt to guess and replay a valid request URI value and 
try to impersonat the respective client. The AS MUST consider the considerations
given in [JAR], section 10.2, clause d on request URI entropy.

## Request Object Replay
An attacker could replay a request URI captured from a legit authorization request. In order to cope with such attacks, the AS SHOULD make the request URIs one-time use.

## Client Policy Change
The client policy might change between the lodging of the request object and the 
authorization request using a particular request object. It is therefore recommended that the AS checks the request parameter against the client policy when processing the authorization request.

# Privacy Considerations

TBD

# Acknowledgements {#Acknowledgements}
      
This specification is based on the work towards [Pushed Request Objects](https://bitbucket.org/openid/fapi/src/master/Financial_API_Pushed_Request_Object.md)
conducted at the Financial Grade API working group at the OpenID Foundation. We would would like to thank the members of this WG for their valuable work.

We would like to thank ... for their valuable feedback on this draft.

# IANA Considerations {#iana_considerations}

...

<reference anchor="PRO" target="https://bitbucket.org/openid/fapi/src/master/Financial_API_Pushed_Request_Object.md">
  <front>
    <title>Financial-grade API: Pushed Request Object</title>
    <author initials="T." surname="Lodderstedt" fullname="Torsten Lodderstedt">
      <organization>yes.com</organization>
    </author>
    <author initials="B." surname="Campbell" fullname="Brian Campbell">
      <organization>Ping Identity</organization>
    </author>
   <date day="28" month="08" year="2019"/>
  </front>
</reference>

{backmatter}

# Document History

   [[ To be removed from the final specification ]]

   -00 

   *  first draft
   

