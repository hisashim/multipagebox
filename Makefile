#!/usr/bin/make -f

## variables

# metadata

PRODUCT = multipagebox
VERSION = $(shell cat VERSION)
PACKAGE = $(shell [ -f debian/changelog ] && \
                  head -n 1 debian/changelog | cut -d' ' -f 1)
DEBREV  = $(shell [ -f debian/changelog ] && \
                  head -n 1 debian/changelog \
                  | cut -d' ' -f 2 | sed 's/(\(.*\)-\(.*\))/\2/')

# programs

LATEX   = latex
DVITOPDF= dvipdfmx
TAR_XVCS= tar --exclude=".svn" --exclude=".git" --exclude=".hg"
DEBUILDOPTS=
PBUILDER = cowbuilder
PBOPTS   = --hookdir=pbuilder-hooks \
           --bindmounts "/var/cache/pbuilder/result"

# directories

DESTDIR =
TEXMF   = /usr/share/texmf
TEXMF_TL= /usr/share/texmf-texlive

# files

TESTDOC = $(PRODUCT).tex

DIST    = Makefile README.md LICENSE VERSION ChangeLog devutils/ \
          $(PRODUCT).sty $(TESTDOC)

RELEASE = $(PRODUCT)-$(VERSION)

DEB     = $(PACKAGE)_$(VERSION)-$(DEBREV)
DEBORIG = $(PACKAGE)_$(VERSION).orig

## targets

all: $(DIST)

.PHONY: all install test dist \
	deb pbuilder-build pbuilder-login pbuilder-test debuild debuild-clean \
	mostlyclean clean maintainer-clean
.SECONDARY:

# installation

install: ChangeLog
	mkdir -p $(DESTDIR)$(TEXMF_TL)/tex/latex/$(PRODUCT)
	cp -r *.sty $(DESTDIR)$(TEXMF_TL)/tex/latex/$(PRODUCT)
	if [ -d $(DESTDIR)$(TEXMF) ]; then \
	  mkdir -p $(DESTDIR)$(TEXMF)/tex/latex/$(PRODUCT); \
	  cp -r *.sty $(DESTDIR)$(TEXMF)/tex/latex/$(PRODUCT); \
	fi
	mkdir -p $(DESTDIR)/usr/share/doc/$(PRODUCT)
	cp -r ChangeLog $(DESTDIR)/usr/share/doc/$(PRODUCT)

# testing

test: $(TESTDOC:.tex=.pdf)

%.pdf:
%.pdf: %.dvi
	$(DVITOPDF) $(DVITOPDFFLAGS) -o $@ $<

%.dvi:
%.dvi: %.tex
	$(LATEX) $<

# source package

dist: $(RELEASE).tar.gz

$(RELEASE): $(DIST)
	mkdir -p $@
	($(TAR_XVCS) -cf - $(DIST)) | (cd $@ && tar xpf -)

ChangeLog:
	devutils/vcslog.sh > $@

%.tar.gz: %
	tar cfz $@ $<

# debian package

deb: pbuilder-build
	cp /var/cache/pbuilder/result/$(DEB).diff.gz ./
	cp /var/cache/pbuilder/result/$(DEB).dsc ./
	cp /var/cache/pbuilder/result/$(DEB)_all.deb ./
	cp /var/cache/pbuilder/result/$(DEBORIG).tar.gz ./

pbuilder-build: $(DEB).dsc
	sudo $(PBUILDER) --build $< -- $(PBOPTS)

pbuilder-login:
	sudo $(PBUILDER) --login $(PBOPTS)

pbuilder-test: $(DEB)_all.deb
	sudo $(PBUILDER) --execute $(PBOPTS) -- pbuilder-hooks/test.sh \
	$(PACKAGE) $(VERSION) $(DEBREV)
	cp /var/cache/pbuilder/result/$(DEB)-test.tar.gz ./

$(DEB).dsc: debuild

debuild: $(RELEASE) $(DEBORIG).tar.gz
	($(TAR_XVCS) -cf - debian) | (cd $(RELEASE) && tar xpf -)
	(cd $(RELEASE) && debuild $(DEBUILDOPTS); cd -)

$(DEBORIG).tar.gz: $(RELEASE).tar.gz
	cp -a $< $@

debuild-clean:
	rm -fr $(DEBORIG)
	rm -f $(DEB)_*.build $(DEB)_*.changes *.cdbs-config_list
	rm -fr debian/$(PACKAGE)
	rm -f $(DEB).dsc $(DEBORIG).tar.gz $(DEB).diff.gz $(DEB)_*.deb
	rm -f $(DEB)-test.tar.gz

# utilities

mostlyclean:
	rm -f $(foreach s,log aux dvi pdf,$(TESTDOC:.tex=.$(s)))
	rm -fr $(RELEASE)

clean: mostlyclean
	rm -f $(RELEASE).tar.gz

maintainer-clean: clean debuild-clean
	rm -f ChangeLog
