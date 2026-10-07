-- `optimize_rewrite_array_exists_like_to_or` clones the haystack once per pattern,
-- so it must not rewrite `arrayExists` when the haystack is non-deterministic.

SET enable_analyzer = 1;
SET optimize_rewrite_array_exists_like_to_or = 1;

SELECT '-- deterministic haystack, rewritten';
EXPLAIN SYNTAX run_query_tree_passes = 1 SELECT arrayExists(x -> toString(number) LIKE x, ['%1%', '%2%']) FROM numbers(3);

SELECT '-- non-deterministic haystack, not rewritten';
EXPLAIN SYNTAX run_query_tree_passes = 1 SELECT arrayExists(x -> toString(rand()) LIKE x, ['%1%', '%2%']) FROM numbers(3);
EXPLAIN SYNTAX run_query_tree_passes = 1 SELECT arrayExists(x -> concat('a', randomString(2)) ILIKE x, ['a%', '%b']) FROM numbers(3);
EXPLAIN SYNTAX run_query_tree_passes = 1 SELECT count() FROM numbers(3) WHERE toString(rand() % 2) LIKE SOME(['0', '1']);

SELECT '-- `rand() % 2` is always 0 or 1, so every row matches';
SELECT countIf(NOT arrayExists(x -> toString(rand() % 2) LIKE x, ['0', '1'])) FROM numbers(100000);
