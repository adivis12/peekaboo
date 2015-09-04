NAME=peekaboo
SRCDIR=src/github.com/mickep76/${NAME}
TMPDIR=.build
RESDIR=/var/lib/${NAME}
VERSION:=$(shell awk -F '"' '/Version/ {print $$2}' ${SRCDIR}/version.go)
RELEASE:=$(shell date -u +%Y%m%d%H%M)
ARCH:=$(shell uname -p)

all: build

clean:
	rm -f *.rpm
	rm -rf pkg bin ${TMPDIR}

test: clean
	gb test

build: test
	gb build all

update:
	gb vendor update --all

install:
	cp bin/peekaboo /usr/bin
	mkdir -p ${RESDIR}
	cp -r ${SRCDIR}/static ${RESDIR}
	cp -r ${SRCDIR}/templates ${RESDIR}

rpm:	build
	mkdir -p ${TMPDIR}/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
	cp -r bin files ${SRCDIR}/templates ${SRCDIR}/static ${TMPDIR}/SOURCES
	sed -e "s/%NAME%/${NAME}/g" -e "s/%VERSION%/${VERSION}/g" -e "s/%RELEASE%/${RELEASE}/g" \
		${NAME}.spec >${TMPDIR}/SPECS/${NAME}.spec
	rpmbuild -vv -bb --target="${ARCH}" --clean --define "_topdir $$(pwd)/${TMPDIR}" ${TMPDIR}/SPECS/${NAME}.spec
	mv ${TMPDIR}/RPMS/${ARCH}/*.rpm .
