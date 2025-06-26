DESCRIPTION = "LTE init service"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${WORKDIR}/COPYING;md5=d32239bcb673463ab874e80d47fae504"

SRC_URI = " \
	file://lte-init.sh \
	file://COPYING \
"

do_install() {
	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/lte-init.sh ${D}${sysconfdir}/init.d/
}

inherit update-rc.d

INITSCRIPT_NAME = "lte-init.sh"
INITSCRIPT_PARAMS = "stop 20 0 6 ."

FILES:${PN} = " \
	${sysconfdir}/init.d \
"
