.PHONY: briefing print-seed help

briefing print-seed:
	@$(MAKE) -C build $@

help:
	@echo "Targets:"
	@echo "  make briefing      first-time setup; prompts for your handle"
	@echo "  make print-seed    show your seed fingerprint"
	@echo
	@echo "See 'man mainframe' for the full briefing."
