# Changelog

## [1.1.0](https://github.com/cloudandthings/terraform-aws-open-metadata/compare/v1.0.0...v1.1.0) (2026-04-24)


### Features

* Added var.eks_node_iam_role_policy_json and var.eks_node_startup_script ([3579394](https://github.com/cloudandthings/terraform-aws-open-metadata/commit/3579394d8a825d0f07a8792df889ac2f92f2630b))

## 1.0.0 (2026-03-31)


### Features

* Standardise module ([9da24ac](https://github.com/cloudandthings/terraform-aws-open-metadata/commit/9da24ac077ec3109172331ea1000c53222ddf183))


### Bug Fixes

* devcontainers ([a5307b7](https://github.com/cloudandthings/terraform-aws-open-metadata/commit/a5307b73a24355cf2cad7ac97f5b619bbee6c93e))

## [1.4.0](https://github.com/cloudandthings/terraform-aws-module-template/compare/v1.3.0...v1.4.0) (2026-03-27)


### Features

* Version 2 ([43d0258](https://github.com/cloudandthings/terraform-aws-module-template/commit/43d0258f1124c0f59af0598107d59a19e6e9d8bb))

## [1.3.0](https://github.com/cloudandthings/terraform-aws-module-template/compare/v1.2.0...v1.3.0) (2025-10-03)


### Features

* add comprehensive repository improvements ([8fab0df](https://github.com/cloudandthings/terraform-aws-module-template/commit/8fab0df2c1df843362855ee71c2ce9920831ed3c))
* add copilot-setup-steps.yml with mise installation ([d9f0cf3](https://github.com/cloudandthings/terraform-aws-module-template/commit/d9f0cf3836a241d3671b2d0432cd6b6e56e9724c))
* Use mise and trivy ([6c963c5](https://github.com/cloudandthings/terraform-aws-module-template/commit/6c963c5d2f6fcd5000ed3b2352fbea0f9bc74b14))
* Use mise and trivy ([#26](https://github.com/cloudandthings/terraform-aws-module-template/issues/26)) ([22fe396](https://github.com/cloudandthings/terraform-aws-module-template/commit/22fe3964d120838451ec08d4a8d2becdccef9da3))


### Bug Fixes

* correct indentation in dev-bootstrap.sh (use spaces instead of tab) ([7dc740b](https://github.com/cloudandthings/terraform-aws-module-template/commit/7dc740bb4cae884b765576395d855916597d4941))
* **release:** Add release-please-config.json ([e4e13e5](https://github.com/cloudandthings/terraform-aws-module-template/commit/e4e13e564f41612ed0f2c0a35f1dec93de763853))
* **release:** Add release-please-config.json ([#27](https://github.com/cloudandthings/terraform-aws-module-template/issues/27)) ([eb709d8](https://github.com/cloudandthings/terraform-aws-module-template/commit/eb709d80fd8f61581630a401ad3008f76fc03073))
* remove trailing whitespace from markdown files ([e2e0229](https://github.com/cloudandthings/terraform-aws-module-template/commit/e2e022940d4b9d950cb34020806cc8958990d72d))
* Update settings and extensions ([bec1af7](https://github.com/cloudandthings/terraform-aws-module-template/commit/bec1af7633d02672d00304705af8e231aaa3010b))
* Update settings and extensions ([#29](https://github.com/cloudandthings/terraform-aws-module-template/issues/29)) ([5df7e01](https://github.com/cloudandthings/terraform-aws-module-template/commit/5df7e01d05bb6e273032208531e2579cb52dbbdf))
* Updates ([be3807a](https://github.com/cloudandthings/terraform-aws-module-template/commit/be3807a111f7ec99ae16675524f257699cb1aeb1))

## [1.2.0](https://github.com/cloudandthings/terraform-aws-template/compare/v1.1.0...v1.2.0) (2023-05-05)


### Features

* Add shell script pre-commits ([#24](https://github.com/cloudandthings/terraform-aws-template/issues/24)) ([9b55002](https://github.com/cloudandthings/terraform-aws-template/commit/9b55002520bf0757470f90a2ff694ddca5581bc7))


### Bug Fixes

* Exclude external modules from tf min-max workflow ([5923e84](https://github.com/cloudandthings/terraform-aws-template/commit/5923e842eb639b1d58abf200f22ec04b9d6e0108))
* **pre-commit:** Correct README update check ([9bfeb61](https://github.com/cloudandthings/terraform-aws-template/commit/9bfeb613cc9f83f4f4f88ae1f558b14237f3b37b))

## [1.1.0](https://github.com/cloudandthings/terraform-aws-template/compare/v1.0.1...v1.1.0) (2023-03-06)


### Features

* Add random naming to example ([#20](https://github.com/cloudandthings/terraform-aws-template/issues/20)) ([0677cd1](https://github.com/cloudandthings/terraform-aws-template/commit/0677cd149337082923186ad40292baacba038224))
* **ci:** Add `concurrency` to github workflows ([#21](https://github.com/cloudandthings/terraform-aws-template/issues/21)) ([2c73dc9](https://github.com/cloudandthings/terraform-aws-template/commit/2c73dc9d52482d027ae6a47f4f6397e3c1b70faa))


### Bug Fixes

* `tftest` was hanging waiting for user input ([fdd614a](https://github.com/cloudandthings/terraform-aws-template/commit/fdd614aa8dc10377e4470a907ca365d56af767f3))
* Example naming ([6b50612](https://github.com/cloudandthings/terraform-aws-template/commit/6b5061244fce9baa83003eb40003543fdf4f8475))
* Minor improvements ([#18](https://github.com/cloudandthings/terraform-aws-template/issues/18)) ([e3a0b43](https://github.com/cloudandthings/terraform-aws-template/commit/e3a0b4387d99da6f7495d3fa053603467c37320d))
* The `tftest` was hanging waiting for user input ([#22](https://github.com/cloudandthings/terraform-aws-template/issues/22)) ([fdd614a](https://github.com/cloudandthings/terraform-aws-template/commit/fdd614aa8dc10377e4470a907ca365d56af767f3))

## [1.0.1](https://github.com/cloudandthings/terraform-aws-template/compare/v1.0.0...v1.0.1) (2022-12-22)


### Bug Fixes

* **simplify:** Cleanup tests and docs ([#8](https://github.com/cloudandthings/terraform-aws-template/issues/8)) ([92b1297](https://github.com/cloudandthings/terraform-aws-template/commit/92b1297fe8f9f202ba6fc80875f4f64c090c32e1))

## 1.0.0 (2022-12-21)


### Features

* Module tests and standardisation  ([#1](https://github.com/cloudandthings/terraform-aws-template/issues/1)) ([cfbc665](https://github.com/cloudandthings/terraform-aws-template/commit/cfbc6653f103118764e99bc98a0f70ea42098338))


### Bug Fixes

* **ci:** Terraform min-max ([#7](https://github.com/cloudandthings/terraform-aws-template/issues/7)) ([71acf4a](https://github.com/cloudandthings/terraform-aws-template/commit/71acf4a932b5a210217279265bc707e29711620d))
* **ci:** Update workflow triggers ([#6](https://github.com/cloudandthings/terraform-aws-template/issues/6)) ([a37afcb](https://github.com/cloudandthings/terraform-aws-template/commit/a37afcbaa54e3c6918d5206694844eb25f87930c))
