#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <sys/statvfs.h>
#ifdef __cplusplus
}
#endif

typedef struct statvfs Statvfs;


MODULE = Filesys::Statvfs	PACKAGE = Filesys::Statvfs


void
statvfs(dir)
	char *dir
	PREINIT:
	Statvfs st;
	PPCODE:
	EXTEND(sp, 10);
	if(statvfs(dir, &st) == 0) {
		/* Push values as doubles because we don't know size */
		PUSHs(sv_2mortal(newSVnv((double)st.f_bsize)));
		PUSHs(sv_2mortal(newSVnv((double)st.f_frsize)));
		PUSHs(sv_2mortal(newSVnv((double)st.f_blocks)));
		PUSHs(sv_2mortal(newSVnv((double)st.f_bfree)));
		PUSHs(sv_2mortal(newSVnv((double)st.f_bavail)));

		PUSHs(sv_2mortal(newSVnv((double)st.f_files)));
		PUSHs(sv_2mortal(newSVnv((double)st.f_ffree)));
		PUSHs(sv_2mortal(newSVnv((double)st.f_favail)));
	
                PUSHs(sv_2mortal(newSVnv((double)st.f_flag)));
                PUSHs(sv_2mortal(newSVnv((double)st.f_namemax)));

	}

	else {
		/* undef */
	}

void
fstatvfs(fd)
	int fd;
	PREINIT:
	Statvfs st;
	PPCODE:
	EXTEND(sp, 10);
	if(fstatvfs(fd, &st) == 0) {
		/* Push values as doubles because we don't know size */
		PUSHs(sv_2mortal(newSVnv((double)st.f_bsize)));
		PUSHs(sv_2mortal(newSVnv((double)st.f_frsize)));
		PUSHs(sv_2mortal(newSVnv((double)st.f_blocks)));
		PUSHs(sv_2mortal(newSVnv((double)st.f_bfree)));
		PUSHs(sv_2mortal(newSVnv((double)st.f_bavail)));

		PUSHs(sv_2mortal(newSVnv((double)st.f_files)));
		PUSHs(sv_2mortal(newSVnv((double)st.f_ffree)));
		PUSHs(sv_2mortal(newSVnv((double)st.f_favail)));

                PUSHs(sv_2mortal(newSVnv((double)st.f_flag)));
                PUSHs(sv_2mortal(newSVnv((double)st.f_namemax)));
	}

	else {
		/* undef */
	}

