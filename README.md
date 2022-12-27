
# ghapp

<!-- badges: start -->
<!-- badges: end -->

The goal of ghapp is to facilitate the use of GitHub Apps for authenticating with the GitHub API within R.

## Installation

You can install the development version of ghapp from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ian-flores/ghapp")
```

## Example

This is an example which shows you how to generate a GitHub App Installation Token.

``` r
library(ghapp)

app_id <- "12345"
private_key_path <- "~/Downloads/gh-app-key.pem"

token <- get_github_app_token(app_id, private_key_path)
```

**The `get_github_app_token()` function returns the token as a value, but will not print it.**

You can obtain both the App ID and the Private Key from the settings page of the GitHub App: https://docs.github.com/en/developers/apps/building-github-apps/authenticating-with-github-apps#generating-a-private-key

## License

Copyright [2022] [Voltron Data]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
