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

In OAuth RFC6749 authorization request parameter are sent as URI query 
parameters. This is simple but also yields challenges:

* integrity
* authenticity
* confidentiality of parameter values
* size

JAR provides solutions for those challenges by allowing OAuth clients 
to wrap authorization request parameters in a signed, and optionally encrypted, 
JWT, the so-called "request object". 

In order cope with the size restrictions, JAR introduces the `request_uri`
parameter that allows clients to send a reference to a request object 
instead of the request object itself.    

This draft complements JAR by providing an interoperable way to push 
the payload of a request object to the AS in exchange for a `request_uri`.

And it goes one step further by also allowing clients to push the conventional 
authorization request parameters to the AS and turn them (internally in the AS)
into a request object that the client can refer to in an authorization request. 

This means existing OAuth clients can use this extension to get integrity, 
confidentiality and authenticity just by sending the request data to a different
location. 

For example, the authorization request

```
GET /authorize?response_type=code&client_id=s6BhdRkqt3&state= af0ifjsldkj
       &redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb&code_challenge=K2-ltc83acc4h0c9w6ESC_rEMTJ3bww-uCHaoeK1t8U&code_challenge_method= S256&scope=ais
       
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
redirect_uri=https%3A%2F%2Fclient%2Eexample%2Ecom%2Fcb&
code_challenge=K2-ltc83acc4h0c9w6ESC_rEMTJ3bww-uCHaoeK1t8U&
code_challenge_method= S256&
scope=ais
```

Note: the request to the pushed authorization endpoint is authenticated in the same way as token endpoint requests. This means the AS can establish confidence
in the identity of a confidential client before the actual authorization process is conducted. 

AS responds to the request above with a request URI as shown in the following 

```
HTTP/1.1 201 Created
Date: Tue, 2 May 2017 15:22:31 GMT
Content-Type: application/json

{

   "request_uri": "urn:example:GkurKxf5T0Y-mnPFCHqWOMiZi4VS138cQO_V7PZHAdM",
   "expires_in": 3600
}
```

This request URI in turn would be used by the client in the authorization request as shown in the following

```
GET /authorize?request_uri=urn:example:GkurKxf5T0Y-mnPFCHqWOMiZi4VS138cQO_V7PZHAdM
```

The pushed authorization request endpoint fosters OAuth security be providing all clients a simple migration path to integrity protected authorization request, but it als also allows clients requiring an even higher secrity level, especially cryptographially confirmed non-repudiation, to explitely adopt JWT-based request objects.   

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

# TBD

# Security Considerations

...

# Privacy Considerations

...

# Acknowledgements {#Acknowledgements}
      
We would would like to thank the FAPI WG of the OpenID Foundation and namely Brian Campbell, Daniel Fett, for their valuable feedback during the preparation of this draft.

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
   

