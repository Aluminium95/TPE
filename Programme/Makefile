### --- VARIABLES --- ###
PROGRAM = CellTPE

# Sources du programme 
SRC = 	"src"/*.vala \
	"src/Menu"/*.vala \
	"src/Admin"/*.vala \
	"src/Elements"/*.vala

# Paquets requis 
PKGS = 	--pkg gee-1.0 \
	--pkg sdl \
	--pkg sdl-gfx \
	--pkg sdl-mixer \
	--pkg sdl-image \
	--pkg json-glib-1.0 \
	--pkg config \

# Variables à configurer
CONFIG = 	-X -DDATA=\"`pwd`/Install/Data\" \
		-X -DUI=\"`pwd`/Install/UI\" \
		-X -DSPRITE=\"`pwd`/Install/Sprites\" 

# Variables à configurer avec les valeurs pour l'installation
CONFIG_INSTALL = 	-X -DDATA=\"/usr/share/CellTPE/Data\" \
			-X -DUI=\"/usr/share/CellTPE/UI\" \
			-X -DSPRITE=\"/usr/share/CellTPE/Sprites\" 
					

# Options de debug
VALACOPTS = -D DEBUG -g --save-temps --enable-mem-profiler

# Inclusion du VAPI + config.h
VAPI = -X -I\"`pwd`/config.h\" --vapidir Vapi/ 

# Commande compilateur
VALAC = valac --enable-experimental --thread

LINK = 	-X -lSDL -X -lSDL_gfx -X -lSDL_mixer -X -lSDL_image

# Pour valencia
BUILD_ROOT = 1

### --- EXECUTIONS --- ###

all:
	@$(VALAC) $(VALACOPTS) $(SRC) -o Build/$(PROGRAM) $(VAPI) $(PKGS) $(LINK) $(CONFIG)
	
config:
	@$(VALAC) $(VALACOPTS) src/Config/*.vala -o Build/Config $(VAPI) --pkg gtk+-3.0 --pkg config $(CONFIG)
	
release: clean
	@$(VALAC) --disable-assert -X -O2 $(SRC) -o $(PROGRAM) $(VAPI) $(PKGS) $(LINK) $(CONFIG)
	
.PHONY: clean
clean: 
	@rm -v -fr 	src/*.c src/*.o src/*~ \
			src/{Menu,Admin,Elements}/*.c src/{Menu,Admin,Elements}/*.o src/{Menu,Admin,Elements}/*~
	
.PHONY: install
install: clean
	@echo "Compile …"
	@$(VALAC) --disable-assert -X -O2 $(SRC) -o $(PROGRAM) $(VAPI) $(PKGS) $(LINK) $(CONFIG_INSTALL)
	@echo "Crée le répertoire … "
	@mkdir -p "/usr/share/$(PROGRAM)"
	@echo "Copie les données … "
	@cp -R .Install/Data/ "/usr/share/$(PROGRAM)/Data"
	@cp -R .Install/UI/ "/usr/share/$(PROGRAM)/UI"
	@cp -R .Install/Sprites/ "/usr/share/$(PROGRAM)/Sprites"
	@chmod -R u+rw "/usr/share/$(PROGRAM)"
	@mv $(PROGRAM) "/usr/bin/"$(PROGRAM)
	@echo "Installation terminée avec succès !"
	
.PHONY : uninstall
uninstall: clean
	@rm -v -fr -r "/usr/share/$(PROGRAM)"
	@rm -v -fr "/usr/bin/"$(PROGRAM)
	@echo "Désinstallé avec succès"
	
