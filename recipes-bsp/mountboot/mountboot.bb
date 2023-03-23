DESCRIPTION = "Mount boot service"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${WORKDIR}/COPYING;md5=d32239bcb673463ab874e80d47fae504"

SRC_URI = " \
	file://mountboot.sh \
	file://COPYING \
"

do_install() {
	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/mountboot.sh ${D}${sysconfdir}/init.d/
}

inherit update-rc.d

INITSCRIPT_NAME = "mountboot.sh"
INITSCRIPT_PARAMS = "start 11 S ."

FILES:${PN} = " \
	${sysconfdir}/init.d \
"
