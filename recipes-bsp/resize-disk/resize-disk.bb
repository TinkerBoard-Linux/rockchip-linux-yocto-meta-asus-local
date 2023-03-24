DESCRIPTION = "Resize all internal mounted partitions"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${WORKDIR}/COPYING;md5=d32239bcb673463ab874e80d47fae504"

RDEPENDS:${PN} = "bash"

SRC_URI = " \
	file://resize-disk.sh \
	file://resize-helper \
	file://COPYING \
"

do_install() {
	install -d ${D}${bindir}
	install -m 0755 ${WORKDIR}/resize-helper ${D}${bindir}

	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/resize-disk.sh ${D}${sysconfdir}/init.d/
}

inherit update-rc.d

INITSCRIPT_NAME = "resize-disk.sh"
INITSCRIPT_PARAMS = "start 20 S ."

FILES:${PN} = " \
	${bindir} \
	${sysconfdir}/init.d \
"
