# Computational Evidence — Unified Erdős–Straus Two-Term Solver

All checks below were run in Lean (`#eval` over `ℚ`) and confirm the exact rational
identities that the formal proofs in `Catalog/Physics/ErdosStrausUnified.lean` and
`Catalog/Physics/ErdosStrausObstruction.lean` establish in general.

## 1. The single engine reproduces every family

The unified solver is

```
es_two_term : 4·a = n + r  →  r·(y·z) = a·n·(y+z)  →  4/n = 1/a + 1/y + 1/z .
```

Each classical family is one choice of the quadruple `(a, r, y, z)`. Sample instances,
all verified `true` by `(4:ℚ)/n == 1/x + 1/y + 1/z`:

| residue / family       | `n`  | `(a, y, z)`      | identity                                   | check |
|------------------------|------|------------------|--------------------------------------------|-------|
| even `n = 2m`          | 10   | `(5, 10, 10)`    | `4/10 = 1/5 + 1/10 + 1/10`                 | ✅ |
| `3 ∣ n`, `n = 3m`      | 21   | `(8, 56, 21)`    | `4/21 = 1/8 + 1/56 + 1/21`                 | ✅ |
| `n ≡ 3 [4]`            | 23   | `(6, 276, 276)`  | `4/23 = 1/6 + 1/276 + 1/276`               | ✅ |
| `n ≡ 5 [8]`            | 13   | `(4, 52, 26)`    | `4/13 = 1/4 + 1/52 + 1/26`                 | ✅ |
| **`5 ∣ n` (new)**      | 35   | `(14, 28, 140)`  | `4/35 = 1/14 + 1/28 + 1/140`               | ✅ |

The `5 ∣ n` family (closed form `4/(5m) = 1/(2m) + 1/(4m) + 1/(20m)`) is **not** among the
four families of `Physics/ErdosStraus.lean`; it is produced here through the same engine with
`(a, r, y, z) = (2m, 3m, 4m, 20m)`.

## 2. The `n ≡ 1 [MOD 8]` parity obstruction

For `n ≡ 1 [MOD 4]` put `b = (n+3)/4`, so `4/n = 1/b + 3/(b·n)`. The halving split
`3/(b·n) = 1/(b·n) + 1/((b·n)/2)` needs `b·n` even. Parity of `b·n` (since `n` is odd this
equals parity of `b`):

| `n`  | `n mod 8` | `b = (n+3)/4` | `(b·n) mod 2` | halving available? |
|------|-----------|---------------|---------------|--------------------|
| 13   | 5         | 4             | 0 (even)      | yes → `4/13 = 1/4 + 1/52 + 1/26` |
| 17   | 1         | 5             | 1 (odd)       | **no** |
| 41   | 1         | 11            | 1 (odd)       | **no** |

This matches the formal theorem `one_mod_eight_is_residual`: the elementary `r = 3` halving
fails for *every* `n ≡ 1 [MOD 8]`, while `halving_iff` proves the precondition is equivalent to
`n ≡ 5 [MOD 8]`.

## 3. The open core is genuinely *prime*, not all `n ≡ 1 [MOD 8]`

A useful sanity check on the reduction: not every `n ≡ 1 [MOD 8]` is hard. For instance
`25 ≡ 1 [MOD 8]` but `5 ∣ 25`, so the new `5 ∣ n` family solves it:

```
4/25 = 1/10 + 1/20 + 1/100      (check: true)
```

So composites with a small "good" prime factor fall to the divisor families; only **primes**
`p ≡ 1 [MOD 8]` resist, consistent with `erdosStraus_reduction`.

## 4. Counterexample hunt

No counterexample is possible to the proved statements (they are theorems). As a stress test of
the *engine* hypotheses, `es_two_term` was instantiated on all five families above and on the
halving scheme; every instantiation produced a `true` rational identity. No instantiation
satisfying `4·a = n + r` and `r·(y·z) = a·n·(y+z)` failed to give a valid decomposition — as it
must, since that is exactly the content of the proved lemma.
