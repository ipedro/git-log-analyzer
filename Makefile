PREFIX?=/usr/local

build:
	@swift build --disable-sandbox -c release

clean_build:
	@rm -rf .build
	@make build

portable_zip: clean_build
	@rm -rf portable_git-log-analyzer
	@mkdir portable_git-log-analyzer
	@mkdir portable_git-log-analyzer/bin
	@cp -f .build/release/git-log-analyzer portable_git-log-analyzer/bin/git-log-analyzer
	@cp -f .build/release/libSwiftToolsSupport.dylib portable_git-log-analyzer/bin
	@cd portable_git-log-analyzer
	@(cd portable_git-log-analyzer; zip -yr - "bin") > "./portable_git-log-analyzer.zip"
	@rm -rf portable_git-log-analyzer

install: build
	@mkdir -p "$(PREFIX)/bin"
	@cp -f ".build/release/libSwiftToolsSupport.dylib" "$(PREFIX)/bin"
	@cp -f ".build/release/git-log-analyzer" "$(PREFIX)/bin/git-log-analyzer"
