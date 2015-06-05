CC=gcc
CONVERT=convert
XXD=xxd
BINEXT=
TARGET=$(shell uname|tr '[A-Z]' '[a-z]')$(shell getconf LONG_BIT)
BUILDDIR=build/$(TARGET)
INCLUDE=-I$(BUILDDIR)
COMMON_CFLAGS=-Wall -Werror -Wextra -std=gnu11 $(INCLUDE) -O2
POSIX_CFLAGS=$(COMMON_CFLAGS) -pedantic -fdiagnostics-color
CFLAGS=$(COMMON_CFLAGS)
STEAMDIR=~/.steam/steam
CSD_DIR=$(STEAMDIR)/SteamApps/common/CookServeDelicious
ARCH_FLAGS=

QP_OBJ=$(BUILDDIR)/quick_patch.o\
       $(BUILDDIR)/game_maker.o \
       $(BUILDDIR)/png_info.o

CSH_OBJ=$(BUILDDIR)/cook_serve_hoomans.o \
        $(BUILDDIR)/game_maker.o \
        $(BUILDDIR)/png_info.o \
        $(BUILDDIR)/hoomans_png.o \
        $(BUILDDIR)/icons_png.o

DMP_OBJ=$(BUILDDIR)/gmdump.o \
        $(BUILDDIR)/game_maker.o \
        $(BUILDDIR)/png_info.o
        
UPD_OBJ=$(BUILDDIR)/gmupdate.o \
        $(BUILDDIR)/game_maker.o \
        $(BUILDDIR)/png_info.o

RES_OBJ=$(BUILDDIR)/make_resource.o \
        $(BUILDDIR)/png_info.o

ifeq ($(TARGET),win32)
	CC=i686-w64-mingw32-gcc
	ARCH_FLAGS=-m32
	BINEXT=.exe
else
ifeq ($(TARGET),win64)
	CC=x86_64-w64-mingw32-gcc
	ARCH_FLAGS=-m64
	BINEXT=.exe
else
ifeq ($(TARGET),linux32)
	CFLAGS=$(POSIX_CFLAGS)
	ARCH_FLAGS=-m32
else
ifeq ($(TARGET),linux64)
	CFLAGS=$(POSIX_CFLAGS)
	ARCH_FLAGS=-m64
endif
endif
endif
endif

.PHONY: all clean cook_serve_hoomans quick_patch gmdump gmupdate make_resource patch setup

all: cook_serve_hoomans quick_patch gmdump gmupdate

cook_serve_hoomans: $(BUILDDIR)/cook_serve_hoomans$(BINEXT)

quick_patch: $(BUILDDIR)/quick_patch$(BINEXT)

gmdump: $(BUILDDIR)/gmdump$(BINEXT)

gmupdate: $(BUILDDIR)/gmupdate$(BINEXT)

make_resource: $(BUILDDIR)/make_resource$(BINEXT)

setup:
	mkdir -p $(BUILDDIR)

patch: $(BUILDDIR)/cook_serve_hoomans$(BINEXT)
	$<

$(BUILDDIR)/%_png.c: %.png
	$(XXD) -i $< > $@

$(BUILDDIR)/%_png.h: %.png ./mkheader.sh
	./mkheader.sh $< $@

$(BUILDDIR)/%.o: src/%.c
	$(CC) $(ARCH_FLAGS) $(CFLAGS) -c $< -o $@

$(BUILDDIR)/%.o: $(BUILDDIR)/%.c
	$(CC) $(ARCH_FLAGS) $(CFLAGS) -c $< -o $@

$(BUILDDIR)/cook_serve_hoomans.o: src/cook_serve_hoomans.c $(BUILDDIR)/hoomans_png.h $(BUILDDIR)/icons_png.h
	$(CC) $(ARCH_FLAGS) $(CFLAGS) -c $< -o $@

$(BUILDDIR)/cook_serve_hoomans$(BINEXT): $(CSH_OBJ)
	$(CC) $(ARCH_FLAGS) $(CSH_OBJ) -o $@

$(BUILDDIR)/quick_patch$(BINEXT): $(QP_OBJ)
	$(CC) $(ARCH_FLAGS) $(QP_OBJ) -o $@

$(BUILDDIR)/gmdump$(BINEXT): $(DMP_OBJ)
	$(CC) $(ARCH_FLAGS) $(DMP_OBJ) -o $@

$(BUILDDIR)/gmupdate$(BINEXT): $(UPD_OBJ)
	$(CC) $(ARCH_FLAGS) $(UPD_OBJ) -o $@

$(BUILDDIR)/make_resource$(BINEXT): $(RES_OBJ)
	$(CC) $(ARCH_FLAGS) $(RES_OBJ) -o $@

clean:
	rm -f \
		$(BUILDDIR)/hoomans_png.h \
		$(BUILDDIR)/hoomans_png.c \
		$(BUILDDIR)/icons_png.h \
		$(BUILDDIR)/icons_png.c \
		$(BUILDDIR)/patch_game.o \
		$(BUILDDIR)/cook_serve_hoomans.o \
		$(BUILDDIR)/quick_patch.o \
		$(BUILDDIR)/gmdump.o \
		$(BUILDDIR)/gmupdate.o \
		$(BUILDDIR)/hoomans_png.o \
		$(BUILDDIR)/icons_png.o \
		$(BUILDDIR)/game_maker.o \
		$(BUILDDIR)/png_info.o \
		$(BUILDDIR)/cook_serve_hoomans$(BINEXT) \
		$(BUILDDIR)/quick_patch$(BINEXT) \
		$(BUILDDIR)/gmdump$(BINEXT) \
		$(BUILDDIR)/gmupdate$(BINEXT)
