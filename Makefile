
define HELP_TEXT
---------------------------------------------------
		Gitty Makefile Help
---------------------------------------------------

Targets:
  help             Show help
  man              Generate man pages from AsciiDoc sources
  html             Generate and update html man pages from AsciiDoc sources
  update-docs      Update man and html docs from AsciiDoc sources


endef
export HELP_TEXT


help:
	@echo "$$HELP_TEXT"


update-docs: man html
	@echo "Docs updated"


man:
	@asciidoctor \
		-D docs/man/ \
		-b manpage \
		docs/gitty.adoc \
		docs/gitty-config.adoc
	@echo "Man pages generated"


html:
	@asciidoctor \
		-b html5 \
		-a stylesheet=gitty-style.css \
		-a linkcss \
		-a sectanchors \
		-a sectids \
		-a toc=left \
		-a toclevels=3 \
		-a docinfo=shared \
		-D ./docs/web/ \
		-a docdatetime="$(shell date '+%B %-d, %Y')" \
		docs/gitty.adoc \
		docs/gitty-config.adoc
	@echo "Html man pages generated"
