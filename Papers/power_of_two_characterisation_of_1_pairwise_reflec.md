# Computational Evidence

**Claim under study.** A generalized `n × n` Latin square with `λ = 1` that is *pairwise
reflection symmetric* (PRS) — on every pair of columns each ordered symbol pair `(p,q)`
occurs on as many rows as its reversal `(q,p)` — exists **iff** `n` is a power of two.

All computations below were run inside Lean 4 / Mathlib with `#eval` (exact arithmetic on
`Fin n`), so the numbers are reproducible from the definitions in
`Bridges/PowerTwoReflectionLatin.lean`.

## 1. Cayley tables of cyclic groups `ℤ/n`

We tested the additive Cayley table `L i j = i + j` on `ℤ/n` for the PRS property
(`isPRSb`, a decidable Boolean version of `IsPRS`):

| n        | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|----------|---|---|---|---|---|---|---|---|---|
| PRS?     | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ | ✗ |

So the *cyclic* table is PRS only for `n ≤ 2`. In particular `ℤ/4` (order a power of two,
but **not** of exponent two) is **not** PRS — this is exactly why the correct algebraic
invariant is *exponent two*, not merely *order a power of two*, at the level of a single
group. This is proved in general by `isPRS_cayley_iff_involutive`.

## 2. Cayley tables of elementary abelian 2-groups `(ℤ/2)^k`

We tested the bitwise-XOR table (the Cayley table of `(ℤ/2)^k` realised on `Fin (2^k)`):

| order `2^k` | 1 | 2 | 4 | 8 |
|-------------|---|---|---|---|
| PRS?        | ✓ | ✓ | ✓ | ✓ |

Every elementary abelian 2-group table is PRS, matching the construction
`prs_latin_exists_of_pow_two`. Together with the cyclic data this shows the PRS property
genuinely separates exponent-two groups from other groups of the same order.

## 3. Counterexample hunt

We searched for a PRS *Cayley table* of a non-power-of-two order. None exists: by
`card_pow_two_of_cayley_isPRS` a PRS Cayley table forces the order to be a power of two,
and the table above at `n = 3,5,6,7` confirms no small cyclic example. No counterexample to
the constructive direction (`2^k ⇒ exists`) was found either — the XOR construction always
works.

## 4. OEIS

The sequence "orders `n` admitting a group of exponent two" is exactly the powers of two
`1, 2, 4, 8, 16, …` (OEIS A000079). This is the number-theoretic side of the bridge.

## Summary

The evidence is fully consistent with the proved results:

* PRS Cayley table ⟺ exponent-two group (`isPRS_cayley_iff_involutive`),
* exponent-two group ⟹ order a power of two (`card_pow_two_of_involutive`),
* every power of two is realised by `(ℤ/2)^k` (`prs_latin_exists_of_pow_two`).

The only part not settled computationally or formally is whether a PRS `λ = 1` Latin square
that is **not** a group table can have non-power-of-two order; see `FUTURE_DIRECTIONS.md`.
