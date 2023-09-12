.PHONY: check-env build deploy

build:
# 明示的に x86_64-unknown-linux-gnu を指定しないと M1 Mac では Arm バイナリができたりする...
	docker run -v .:/app --rm ghcr.io/cargo-lambda/cargo-lambda \
		bash -c 'cd /app && cargo lambda build --release --target x86_64-unknown-linux-gnu'

deploy: check-env build
	docker run -v .:/app -v ~/.aws:/root/.aws --rm ghcr.io/cargo-lambda/cargo-lambda \
		bash -c '\
			cd app && \
			cargo lambda deploy \
			--profile $(AWS_PROFILE) \
			--binary-name actual_lambda \
			example-aws-terraform-rust \
		'

check-env:
ifndef AWS_PROFILE
	$(error AWS_PROFILE is not defined)
endif
