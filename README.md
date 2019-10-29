# draft-oauth-par

This repository contains the IETF draft on OAuth Pushed Authorization Requests.

`main.md` is the source in markdown format. 

To build the xml2rfc file and transform it into html and txt run `make-v2.sh` or `make`.
You need to have installed https://github.com/mmarkdown/mmark and https://pypi.org/project/xml2rfc/
as prerequisites.

### Set up

Install the `mmark` command if you don't have it.

```
$ make mmark
    # Equivalent to: go get github.com/mmarkdown/mmark
```

Install the `xml2rfc` command if you don't have it.

```
$ make xml2rfc
    # Equivalent to: pip install xml2rfc
```

### Build

Build all output files (XML, HTML and TEXT).

```
$ make
    # Or ./make-v2.sh
```

`xml`, `html` and `txt` are goals to build each file independently.
However, because the HTML file and the text file depend on the XML
file, the XML file is generated in any case.

```
$ make xml
$ make html
$ make txt
```

### Help

`make help` shows avaiable make targets with output file names.

```
$ make help
```

