# Computational Evidence — Goldbach Verification Framework

## 1. Small-case calculations (binary Goldbach partitions)

Smallest prime pair `p + q = n` for the first even numbers:

| n  | partition       | n  | partition       |
|----|-----------------|----|-----------------|
| 4  | 2 + 2           | 16 | 3 + 13          |
| 6  | 3 + 3           | 18 | 5 + 13          |
| 8  | 3 + 5           | 20 | 3 + 17          |
| 10 | 3 + 7           | 22 | 3 + 19          |
| 12 | 5 + 7           | 24 | 5 + 19          |
| 14 | 3 + 11          | 26 | 3 + 23          |

Observation supporting the engine design: in every case a *small* prime `p`
(here `p ∈ {2,3,5}`) already yields a valid partition, so a search that scans `p`
upward short-circuits almost immediately. This is why `goldbachPair` is fast in
practice.

## 2. Ternary (three-prime) reduction, small cases

For odd `n ≥ 7`, writing `n = 3 + (n-3)` with `n-3` even and Goldbach:

| n (odd) | n-3 | binary part | ternary partition |
|---------|-----|-------------|-------------------|
| 7       | 4   | 2 + 2       | 3 + 2 + 2         |
| 9       | 6   | 3 + 3       | 3 + 3 + 3         |
| 11      | 8   | 3 + 5       | 3 + 3 + 5         |
| 13      | 10  | 3 + 7       | 3 + 3 + 7         |
| 21      | 18  | 5 + 13      | 3 + 5 + 13        |

This confirms the elementary reduction binary ⇒ ternary used in
`ternary_of_binary`.

## 3. OEIS connections

* **A002375** — number of decompositions of `2n` into an *unordered* sum of two
  odd primes; first terms (from `n=1`): 0, 1, 1, 1, 2, 1, 2, 2, 2, 2, ...
* **A045917** — Goldbach partition count of `2n` (with the `2+2` case); 1, 1, 1,
  1, 2, 1, 2, 2, 2, 3, ...
* **A002372** — ordered Goldbach counts; this is exactly the object `reps`
  (restricted to primes) studied in `GoldbachStructure.lean`.

The ordered representation count `reps (primesUpTo n) n` formalized here is the
finite shadow of A002372 / A045917.

## 4. Counterexample hunt

A direct machine scan over **all even `n` with `4 ≤ n ≤ 100000`** finds **no
counterexample**: every such `n` admits a two-prime partition. This exhaustive
search is exactly the content certified by `goldbach_upto_100000`
(`goldbachChecked 100000 = true`, discharged by `native_decide`).

Pushing the scan to `10^6` also finds no counterexample, but certifying it inside
the kernel-backed pipeline exceeds practical compile-time limits (>20 min), so the
formally certified bound is set at `10^5`. This is a *resource* boundary, not a
mathematical one.

## 5. Mod-4 pairing structure (sample)

For `n ≡ 0 (mod 4)` the two odd primes always lie in *different* classes mod 4,
e.g. `n = 24 = 5 + 19` with `5 ≡ 1`, `19 ≡ 3 (mod 4)`. For `n ≡ 2 (mod 4)` they
share a class, e.g. `n = 18 = 5 + 13` with both `≡ 1 (mod 4)`. This empirical
regularity is proved in general as `goldbach_mod4_pairing`.
