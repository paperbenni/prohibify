export PREFIX := /usr

.PHONY: all
all:
	$(info Usage: make install [PREFIX=/usr/])
	true

.PHONY: install
install: prohibify.sh stock.txt
	$(info INFO: install PREFIX: $(PREFIX))
	install -Dm 755 prohibify.sh $(DESTDIR)$(PREFIX)/bin/prohibify
	install -Dm 755 stock.txt $(DESTDIR)$(PREFIX)/share/prohibify/stock.txt

.PHONY: uninstall
uninstall:
	rm $(DESTDIR)$(PREFIX)/bin/instantpacman
	rm -rf $(DESTDIR)$(PREFIX)/share/prohibify

