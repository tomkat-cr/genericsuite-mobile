.DEFAULT_GOAL := help
.PHONY: help install update qa build build_local run clean clean_rm clean_temp_dir clean_logs clean_build fresh
SHELL := /bin/bash

## General Commands

help:
	cat Makefile

## Install dependecies

install:
	flutter pub get

update:
	flutter pub upgrade

## Cleaning

clean: clean_pub_cache clean_rm clean_temp_dir clean_logs clean_build

clean_rm:
	rm -rf build
	mkdir build

clean_temp_dir:
	rm -rf .dart_tool

clean_logs:
	rm -rf logs/

clean_pub_cache:
	flutter pub cache clean

clean_build:
	flutter clean && cd android && ./gradlew clean && cd -

clean_ios:
	flutter clean
	rm -rf ios/Pods ios/.symlinks ios/Flutter/Flutter.framework ios/Flutter/Flutter.podspec
	rm -rf ~/Library/Developer/Xcode/DerivedData
	rm -rf build/ios
	flutter pub get
	pod repo update
	cd ios && \
	pod deintegrate && \
	pod install && \
	sudo xcode-select -s /Applications/Xcode.app && \
	sudo gem install cocoapods && \
	pod repo update && \
	pod install --repo-update && \
	cd - && \
	flutter build ios --simulator

fresh: clean install

## CLI Utilities

install_tools:
	xcode-select --install
	brew install --cask android-sdk
	cd /tmp && curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.38.6-stable.zip
	mkdir -p "${HOME}/flutter"
	unzip flutter_macos_arm64_3.38.6-stable.zip -d "${HOME}/flutter"
	export PATH=$PATH:"${HOME}/flutter/bin"
	flutter pub global activate

## Automated Testing

test:
	flutter test

## Build

qa: test

# Config directories

copy_root_env:
# 	cp ../.env .env

link_config_dirs: copy_root_env
	@echo "Uncomment this Makefile block to copy the config_dbdef and images to the assets directory in a monorepo project."
	# if [ -d ./assets/config_dbdef ]; then rm -rf ./assets/config_dbdef; fi
	# if [ -f ./assets/images/app_logo_circle.png ]; then rm -rf ./assets/images/app_logo_circle.png; fi
	# if [ -f ./assets/images/app_logo_horizontal.png ]; then rm -rf ./assets/images/app_logo_horizontal.png; fi
	# if [ -f ./assets/images/app_logo_emblem.png ]; then rm -rf ./assets/images/app_logo_emblem.png; fi
	# if [ -f ./assets/images/app_icon_emblem-250.png ]; then rm -rf ./assets/images/app_icon_emblem-250.png; fi
	# if [ -f ./assets/images/app_icon_emblem-500.png ]; then rm -rf ./assets/images/app_icon_emblem-500.png; fi
	# if [ -f ./web/icons/app_icon_emblem.svg ]; then rm -rf ./web/icons/app_icon_emblem.svg; fi
	# if [ -f ./web/icons/app_icon_emblem-250.png ]; then rm -rf ./web/icons/app_icon_emblem-250.png; fi
	# if [ -f ./web/icons/app_icon_emblem-500.png ]; then rm -rf ./web/icons/app_icon_emblem-500.png; fi
	# cp -R ../config_dbdef ./assets/config_dbdef
	# cp ../ui/src/images/prico_logo_circle.png ./assets/images/app_logo_circle.png
	# cp ../ui/src/images/prico_logo_horizontal.png ./assets/images/app_logo_horizontal.png
	# cp ../ui/src/images/prico_logo_emblem.png ./assets/images/app_logo_emblem.png
	# cp ../ui/src/images/prico_icon_emblem-250.png ./assets/images/app_icon_emblem-250.png
	# cp ../ui/src/images/prico_icon_emblem-500.png ./assets/images/app_icon_emblem-500.png
	# cp ../ui/src/images/prico_icon_emblem.svg ./web/icons/app_icon_emblem.svg
	# cp ../ui/src/images/prico_icon_emblem-250.png ./web/icons/app_icon_emblem-250.png
	# cp ../ui/src/images/prico_icon_emblem-500.png ./web/icons/app_icon_emblem-500.png

unlink_config_dirs:
	@echo "Uncomment this Makefile block to remove the config_dbdef from the assets directory."
	# if [ -d ./assets/config_dbdef ]; then rm -rf ./assets/config_dbdef; fi

## Configuration Commands

config: link_config_dirs
	@echo "Uncomment this Makefile block to change the environment endpoint in a monorepo project."
	# cp assets/config/stage-prod.json assets/config/stage.json
	# bash ../node_modules/genericsuite-fe-scripts/scripts/change_env_be_endpoint.sh prod mobile_web

config_dev: link_config_dirs
	@echo "Uncomment this Makefile block to change the environment endpoint in a monorepo project."
	# cp assets/config/stage-dev.json assets/config/stage.json
	# bash ../node_modules/genericsuite-fe-scripts/scripts/change_env_be_endpoint.sh dev mobile_web

config_local: link_config_dirs
	@echo "Uncomment this Makefile block to change the environment endpoint in a monorepo project."
	# cp assets/config/stage-dev.json assets/config/stage.json
	# bash ../node_modules/genericsuite-fe-scripts/scripts/change_env_be_endpoint.sh dev mobile_web

config_qa: link_config_dirs
	@echo "Uncomment this Makefile block to change the environment endpoint in a monorepo project."
	# cp assets/config/stage-qa.json assets/config/stage.json
	# bash ../node_modules/genericsuite-fe-scripts/scripts/change_env_be_endpoint.sh qa mobile_web

config_qa_for_deployment: link_config_dirs
	@echo "Uncomment this Makefile block to change the environment endpoint in a monorepo project."
	# cp assets/config/stage-qa.json assets/config/stage.json
	# bash ../node_modules/genericsuite-fe-scripts/scripts/change_env_be_endpoint.sh qa mobile_web

config_staging: link_config_dirs
	@echo "Uncomment this Makefile block to change the environment endpoint in a monorepo project."
	# cp assets/config/stage-staging.json assets/config/stage.json
	# bash ../node_modules/genericsuite-fe-scripts/scripts/change_env_be_endpoint.sh staging mobile_web

build:
	flutter build apk --release

build_local:
	flutter build apk --debug

build_bundle_rm_init:
	@echo ""
	@echo "Starting bundle creation process... removing previous build"
	@echo ""
	rm -rf build
	mkdir build

build_bundle_flutter_build:
	@echo ""
	@echo "Building bundle to upload to Play Store..."
	@echo ""
	flutter build appbundle --release

build_bundle_zip:
	@echo ""
	@echo "Zipping native libs to upload as debug symbols to Play Store..."
	@echo ""
	zip -r build/app/outputs/bundle/release/native-debug-symbols.zip build/app/intermediates/merged_native_libs/release/mergeReleaseNativeLibs/out/lib/

build_bundle_ls:
	@echo ""
	@echo "Bundle size:"
	@echo ""
	ls -lh build/app/outputs/bundle/release/app-release.aab
	ls -lh build/app/outputs/bundle/release/native-debug-symbols.zip

build_bundle_finished:
	@echo ""
	@echo "Bundle creation finished."
	@echo ""

build_bundle: build_bundle_rm_init build_bundle_flutter_build build_bundle_zip build_bundle_ls build_bundle_finished

publish: build_bundle

generate_keystore:
	keytool -genkey -v -keystore ${HOME}/.ssh/upload-keystore.jks \
        -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
        -alias upload

generate_icons:
	flutter pub get && flutter pub run flutter_launcher_icons:main

create_android_avd:
	 # ${HOME}/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager "system-images;android-27;google_apis_playstore;x86"
	 ${HOME}/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager "system-images;android-34;google_apis_playstore;arm64-v8a"

## Deployment

deploy_web_qa: config_qa build
	flutter build web --release --wasm && \
	export PRESERVE_MODULE_TYPE="1" && \
	export RUN_BUNDLER="none" && \
	export UPDATE_BUILD="0" && \
	export BUILD_DIR="./build/web" && \
	bash ../node_modules/genericsuite-fe-scripts/scripts/aws_deploy_to_s3.sh qa mobile_web

deploy_local: build_local

deploy_prod: build_bundle

deploy: deploy_prod

## Application Specific Commands

flutter_run:
	flutter run

run_local: config_local clean_logs flutter_run

run_qa: config_qa clean_logs flutter_run

run: run_local

## Mobile Web App Commands

flutter_run_webserver:
	flutter clean && flutter run -d chrome

run_web_local: config_local clean_logs flutter_run_webserver

run_web_qa: config_qa clean_logs flutter_run_webserver

run_web: run_web_local