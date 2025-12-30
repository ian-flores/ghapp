test_that("cache_set() stores tokens correctly", {
  clear_test_cache()

  key <- "123456_789012"
  token <- "ghs_test_token"
  expires_at <- Sys.time() + 3600  # 1 hour from now

  result <- cache_set(key, token, expires_at)

  expect_equal(result, token)
})

test_that("cache_get() retrieves valid tokens", {
  clear_test_cache()

  key <- "123456_789012"
  token <- "ghs_test_token"
  expires_at <- Sys.time() + 3600

  cache_set(key, token, expires_at)
  retrieved <- cache_get(key)

  expect_equal(retrieved, token)
})

test_that("cache_get() returns NULL for expired tokens", {
  clear_test_cache()

  key <- "123456_789012"
  token <- "ghs_expired_token"
  expires_at <- Sys.time() - 60  # Expired 1 minute ago

  cache_set(key, token, expires_at)
  retrieved <- cache_get(key)

  expect_null(retrieved)
})

test_that("cache_get() returns NULL for missing keys", {
  clear_test_cache()

  retrieved <- cache_get("nonexistent_key")

  expect_null(retrieved)
})

test_that("cache_clear() clears specific key", {
  clear_test_cache()

  key1 <- "123456_111111"
  key2 <- "123456_222222"
  expires_at <- Sys.time() + 3600

  cache_set(key1, "token1", expires_at)
  cache_set(key2, "token2", expires_at)

  cache_clear(key1)

  expect_null(cache_get(key1))
  expect_equal(cache_get(key2), "token2")
})

test_that("cache_clear(NULL) clears all keys", {
  clear_test_cache()

  key1 <- "123456_111111"
  key2 <- "123456_222222"
  expires_at <- Sys.time() + 3600

  cache_set(key1, "token1", expires_at)
  cache_set(key2, "token2", expires_at)

  cache_clear(NULL)

  expect_null(cache_get(key1))
  expect_null(cache_get(key2))
})
