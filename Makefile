.PHONY: deploy
deploy:
	git fetch origin
	git reset --hard origin/main
	./deploy.sh
