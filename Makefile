# PTT KEP E-İmza — native Apple Silicon (arm64) build
# Asıl mantık scripts/build.sh içinde. Bu Makefile ince bir sarmalayıcıdır.

SH := bash scripts/build.sh

.PHONY: all check-deps jdk jpackage-jdk download icns package sign run assets dmg clean distclean help sign-devid notarize-app notarize-dmg notary-setup

all: ## ARM64 .app'i üret (varsayılan)
	@$(SH) all

check-deps: ## Araçları, arm64 Java 11 ve jpackage'ı denetle
	@$(SH) check-deps

jdk: ## Gömülecek arm64 Java 11 yoksa Azul Zulu 11 kur
	@$(SH) jdk

jpackage-jdk: ## jpackage'lı 17+ JDK yoksa Azul Zulu 21 kur
	@$(SH) jpackage-jdk

download: ## elektronik-imza.jar indir + doğrula + ikonu jar'dan çıkar
	@$(SH) download

icns: ## .icns ikon üret
	@$(SH) icns

package: ## jpackage ile .app üret (Java 11 gömülü)
	@$(SH) package

sign: ## ad-hoc codesign
	@$(SH) sign

run: ## üretilen .app'i aç
	@$(SH) run

assets: ## DMG arka planını assets/dmg-background.svg'den üret
	@$(SH) assets

dmg: ## sürükle-bırak yerleşimli .dmg üret (create-dmg gerekir)
	@$(SH) dmg

clean: ## build/ sil (indirilenleri korur)
	@$(SH) clean

distclean: ## build/ + indirilenler sil
	@$(SH) distclean

help: ## Bu yardım
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | sed -E 's/:.*## /\t/' | sort

# ---------- Developer ID imzası + Apple notarizasyonu ----------
IDENTITY ?= Developer ID Application: ADEM YUCE (99QB736768)
APP := build/PTT KEP E-İmza.app
ENT := scripts/entitlements-jvm.plist
NOTARY_PROFILE ?= eimza-notch
DMG_FILE ?= build/PTTKEPEImza-arm64.dmg

ifeq ($(strip $(APPLE_API_KEY_ID)$(APPLE_API_ISSUER_ID)),)
NOTARY_ARGS := --keychain-profile "$(NOTARY_PROFILE)"
else
NOTARY_ARGS := --key "$(HOME)/private_keys/AuthKey_$(APPLE_API_KEY_ID).p8" --key-id "$(APPLE_API_KEY_ID)" --issuer "$(APPLE_API_ISSUER_ID)"
endif

sign-devid: ## Developer ID + hardened runtime imzala (önce: make all)
	@test -d "$(APP)" || { echo ">> .app yok — önce: make all"; exit 1; }
	@[ "build/.signed" -nt "$(APP)" ] && echo ">> Developer ID zaten imzalı (stamp güncel) — atlandı" && exit 0 || true
	@abs=$$(cd "$(APP)/Contents/app" && pwd); tmp=$$(mktemp -d); for jar in "$$abs"/*.jar; do [ -e "$$jar" ] || continue; rm -rf "$$tmp/jc"; unzip -q "$$jar" -d "$$tmp/jc"; (cd "$$tmp/jc" && find . -type f \( -name '*.dylib' -o -name '*.jnilib' \) | while IFS= read -r f; do file "$$f" | grep -q 'Mach-O' || continue; codesign --force --options runtime --timestamp --sign "$(IDENTITY)" "$$f" || exit 9; done); rm -f "$$jar"; (cd "$$tmp/jc" && zip -qr "$$jar" .) || exit 11; done; rm -rf "$$tmp"; echo ">> jar-içi native imzalandı"
	@find "$(APP)/Contents" -type f \( -name '*.dylib' -o -name '*.jnilib' -o -name '*.jspawnhelper' -o -path '*/MacOS/*' -o -path '*/Home/bin/*' \) > build/.macho-list
	@N2=0; NM=$$(wc -l < build/.macho-list | tr -d ' '); while IFS= read -r f; do file "$$f" | grep -q 'Mach-O' || continue; codesign --force --options runtime --timestamp --sign "$(IDENTITY)" "$$f" || exit 9; N2=$$((N2+1)); done < build/.macho-list; rm -f build/.macho-list; echo ">> iç Mach-O imza: $$N2/$$NM"
	@find "$(APP)" \( -path '*/Home/bin/*' -o -name jspawnhelper \) -type f -print0 | xargs -0 -I{} codesign --force --options runtime --timestamp --entitlements "$(ENT)" --sign "$(IDENTITY)" "{}" || exit 3
	@codesign --force --sign "$(IDENTITY)" --options runtime --timestamp --entitlements "$(ENT)" "$(APP)" || exit 3
	@codesign --verify --deep --strict "$(APP)" || exit 4 ; echo ">> Developer ID imzası geçerli"
	@touch build/.signed

notarize-app: sign-devid ## notarytool submit + wait + staple (.app)
	@ditto -c -k --keepParent "$(APP)" build/notary-upload.zip
	@xcrun notarytool submit build/notary-upload.zip $(NOTARY_ARGS) --wait; st=$$?; rm -f build/notary-upload.zip; exit $$st
	@xcrun stapler staple "$(APP)"
	@xcrun stapler validate "$(APP)"

notarize-dmg: ## DMG'yi notarize et + staple (DMG_FILE=... set edilmeli)
	@test -n "$(DMG_FILE)" && test -f "$(DMG_FILE)" || { echo ">> DMG yok: DMG_FILE=... verin (önce: make dmg)"; exit 1; }
	@xcrun notarytool submit "$(DMG_FILE)" $(NOTARY_ARGS) --wait
	@xcrun stapler staple "$(DMG_FILE)"
	@xcrun stapler validate "$(DMG_FILE)"

notary-setup: ## yerel keychain notarytool profili (interaktif, bir kez)
	@echo "örnek: xcrun notarytool store-credentials $(NOTARY_PROFILE) --apple-id <ADRES> --team-id 99QB736768"
	@echo "(şifre: account.apple.com -> Uygulamaya Ozel Sifre)"
