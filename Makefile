PREFIX?=/usr/local

build:
	@swift build --disable-sandbox -c release

clean_build:
	@rm -rf .build
	@make build

portable_zip: clean_build
	@rm -rf portable_git-log-analyser
	@mkdir portable_git-log-analyser
	@mkdir portable_git-log-analyser/bin
	@cp -f .build/release/git-log-analyser portable_git-log-analyser/bin/git-log-analyser
	@cp -f .build/release/libSwiftToolsSupport.dylib portable_git-log-analyser/bin
	@cd portable_git-log-analyser
	@(cd portable_git-log-analyser; zip -yr - "bin") > "./portable_git-log-analyser.zip"
	@rm -rf portable_git-log-analyser

install: build
	@mkdir -p "$(PREFIX)/bin"
	@cp -f ".build/release/libSwiftToolsSupport.dylib" "$(PREFIX)/bin"
	@cp -f ".build/release/git-log-analyser" "$(PREFIX)/bin/git-log-analyser"
