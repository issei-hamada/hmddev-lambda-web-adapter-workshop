build-ApiFunction:
	# SAMが自動的にこのターゲットを実行します
	@echo "=== Makefile: Building ApiFunction ==="
	@echo "ARTIFACTS_DIR: $(ARTIFACTS_DIR)"
	
	# Dockerイメージをビルド
	# 重要: イメージ名は「関数名を小文字にしたもの」にする必要があります
	docker build -t apifunction:latest ./app --network sagemaker
	
	# ビルドしたイメージを確認
	@echo "Built image:"
	@docker images | grep apifunction || true