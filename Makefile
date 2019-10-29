#==================================================
# V A R I A B L E S
#==================================================

#--------------------------------------------------
# COMMANDS
#--------------------------------------------------
GO      := go
PIP     := pip
MMARK   := mmark
XML2RFC := xml2rfc


#--------------------------------------------------
# FILES
#--------------------------------------------------
SRC_FILE  := main.md
BASENAME  := $(shell sed -n -e '1,/^value/ s/^value = "\(.*\)"/\1/p' $(SRC_FILE))
XML_FILE  := $(BASENAME).xml
HTML_FILE := $(BASENAME).html
TEXT_FILE := $(BASENAME).txt
OUT_FILES := $(XML_FILE) $(HTML_FILE) $(TEXT_FILE)


#--------------------------------------------------
# INSTALL OPERATIONS
#--------------------------------------------------
MMARK_LOC := github.com/mmarkdown/mmark


#==================================================
# T A R G E T S
#==================================================

#--------------------------------------------------
# PHONY TARGETS
#--------------------------------------------------

.PHONY: all clean help xml html txt mmark xml2rfc

# Build all output files
all: $(OUT_FILES)

# Remove all output files
clean:
	@rm -f $(OUT_FILES)

# Print the help message
help:
	@printf "%s\n\n" \
		"all     - builds output files." \
		"          => $(OUT_FILES)" \
		"clean   - removes output files." \
		"help    - shows this help message." \
		"xml     - builds an XML file." \
		"          => $(XML_FILE)" \
		"html    - builds an HTML file." \
		"          => $(HTML_FILE)" \
		"txt     - builds a TEXT file." \
		"          => $(TEXT_FILE)" \
		"mmark   - installs 'mmark' command." \
		"xml2rfc - installs 'xml2rfc' command."

# Build an XML file
xml: $(XML_FILE)

# Build an HTML file
html: $(HTML_FILE)

# Build a TEXT file
txt: $(TEXT_FILE)


#--------------------------------------------------
# OUTPUT FILES
#--------------------------------------------------

$(XML_FILE): $(SRC_FILE)
	$(MMARK) -2 $< > $@

$(HTML_FILE): $(XML_FILE)
	$(XML2RFC) --legacy --html $<

$(TEXT_FILE): $(XML_FILE)
	$(XML2RFC) --legacy --text $<


#--------------------------------------------------
# INSTALL OPERATIONS
#--------------------------------------------------

# Install the 'mmark' command
mmark:
	$(GO) get $(MMARK_LOC)

# Install the 'xml2rfc' command
xml2rfc:
	$(PIP) install xml2rfc

