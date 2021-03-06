#include "game_maker.h"
#include "png_info.h"
#include "cook_serve_hoomans.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <strings.h>
#include <errno.h>

#define CSH_CATERING_INDEX 17
#define CSH_ICONS_INDEX    42
#define CSH_HOOMANS_INDEX  47

static const char *filename(const char *path) {
	const char *ptr = path + strlen(path) - 1;

	for (; ptr != path; -- ptr) {
#ifdef GM_WINDOWS
		if (*ptr == '\\' || *ptr == '/') return ptr + 1;
#else
		if (*ptr == '/') return ptr + 1;
#endif
	}

	return path;
}

static int load_txtr_info(const char *filename, size_t index, struct gm_patch *patch) {
	struct png_info info;
	FILE *fp = fopen(filename, "rb");

	if (!fp) {
		return -1;
	}

	int status = parse_png_info(fp, &info);
	int errnum = errno;

	fclose(fp);
	errno = errnum;

	if (status != 0) {
		return -1;
	}

	patch->section      = GM_TXTR;
	patch->index        = index;
	patch->type         = GM_PNG;
	patch->patch_src    = GM_SRC_FILE;
	patch->src.filename = filename;
	patch->size         = info.filesize;
	patch->meta.txtr.width  = info.width;
	patch->meta.txtr.height = info.height;

	return 0;
}

int main(int argc, char *argv[]) {
	int status = EXIT_SUCCESS;
	const char *game_filename     = NULL;
	const char *catering_filename = NULL;
	const char *icons_filename    = NULL;
	const char *hoomans_filename  = NULL;

	struct gm_patch patches[] = {
		GM_PATCH_END,
		GM_PATCH_END,
		GM_PATCH_END,
		GM_PATCH_END
	};
	struct gm_patch *patch = patches;

	if (argc < 3) {
		fprintf(stderr, "*** ERROR: Please pass %s, hoomans.png, catering.png, and/or icons.png to this program.\n", CSH_GAME_ARCHIVE);
		goto error;
	}

	for (int i = 1; i < argc; ++ i) {
		const char *path = argv[i];
		const char *name = filename(path);

		if (strcasecmp(name, "game.unx") == 0 || strcasecmp(name, "data.win") == 0) {
			game_filename = path;
		}
		else if (strcasecmp(name, "catering.png") == 0) {
			catering_filename = path;
		}
		else if (strcasecmp(name, "hoomans.png") == 0) {
			hoomans_filename = path;
		}
		else if (strcasecmp(name, "icons.png") == 0) {
			icons_filename = path;
		}
		else {
			fprintf(stderr, "*** ERROR: Don't know what to do with a file named '%s'.\n"
							"           Please pass files named %s, hoomans.png and/or icons.png to this program.\n",
							name, CSH_GAME_ARCHIVE);
			goto error;
		}
	}

	if (!game_filename || (!catering_filename && !icons_filename && !hoomans_filename)) {
		fprintf(stderr, "*** ERROR: please pass %s, hoomans.png and/or icons.png to this program.\n", CSH_GAME_ARCHIVE);
		goto error;
	}

	if (catering_filename) {
		if (load_txtr_info(catering_filename, CSH_CATERING_INDEX, patch) != 0) {
			perror(catering_filename);
			goto error;
		}
		patch ++;
	}

	if (icons_filename) {
		if (load_txtr_info(icons_filename, CSH_ICONS_INDEX, patch) != 0) {
			perror(icons_filename);
			goto error;
		}
		patch ++;
	}

	if (hoomans_filename) {
		if (load_txtr_info(hoomans_filename, CSH_HOOMANS_INDEX, patch) != 0) {
			perror(hoomans_filename);
			goto error;
		}
		patch ++;
	}

	if (gm_patch_archive(game_filename, patches) != 0) {
		fprintf(stderr, "*** ERROR: Error patching archive: %s\n", strerror(errno));
		goto error;
	}

	printf("Successfully patched game.\n");

	goto end;

error:
	status = EXIT_FAILURE;

end:

#ifdef GM_WINDOWS
	printf("Press ENTER to continue...");
	getchar();
#endif

	return status;
}
