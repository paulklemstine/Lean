# Computational Evidence: Decision-LWE ≡ Search-LWE for Arbitrary Modulus

The central claim of this cycle is that the search-to-decision reduction for
Learning with Errors, over an **arbitrary** modulus `q`, is governed by the
*unit* structure of `ℤ_q` rather than by nonzeroness. This note records the
small-case evidence that motivated — and constrains — the formalisation.

## 1. The prime criterion fails for composite `q`

Over a field, `x ↦ a·x` is a bijection iff `a ≠ 0`. The smallest composite
counterexample is `q = 4`, `a = 2`:

| `x mod 4` | `2·x mod 4` |
|-----------|-------------|
| 0         | 0           |
| 1         | 2           |
| 2         | 0           |
| 3         | 2           |

`2` is nonzero but the map collapses `{0,2} ↦ 0` and `{1,3} ↦ 2`; it is **not**
a bijection. Hence a search-to-decision reduction that rerandomises by an
arbitrary nonzero multiplier is *incorrect* for composite `q`. The valid
multipliers modulo 4 are exactly `{1, 3}` = the units, and there are
`φ(4) = 2` of them. This is precisely `affine_bijective_iff_isUnit`.

## 2. Number of valid rerandomisers = Euler totient

Counting the invertible multipliers for the first several moduli:

| `q`  | units of `ℤ_q`            | `φ(q)` |
|------|---------------------------|--------|
| 2    | {1}                       | 1      |
| 3    | {1,2}                     | 2      |
| 4    | {1,3}                     | 2      |
| 5    | {1,2,3,4}                 | 4      |
| 6    | {1,5}                     | 2      |
| 8    | {1,3,5,7}                 | 4      |
| 9    | {1,2,4,5,7,8}             | 6      |
| 12   | {1,5,7,11}                | 4      |

This matches OEIS **A000010** (Euler totient), first terms
`1, 1, 2, 2, 4, 2, 6, 4, 6, 4, 10, 4, …`. Formalised as
`card_valid_multipliers`.

## 3. CRT multiplicativity of the count

For coprime `m, n` the valid multipliers factor:
`φ(12) = φ(4)·φ(3) = 2·2 = 4`; `φ(15) = φ(3)·φ(5) = 2·4 = 8`;
`φ(8) = φ(8)` (prime power, no proper coprime split). This is the arithmetic
shadow of the ring isomorphism `ℤ_{mn} ≅ ℤ_m × ℤ_n`, so an arbitrary-modulus
reduction decomposes into coprime prime-power components. Formalised as
`crt_isUnit_iff` and `totient_factorises`.

## 4. Hybrid concentration

Guessing a secret coordinate ranges over all `q` residues of `ℤ_q`; averaging a
decision advantage `δ` over these `q` hybrids forces some residue to carry
advantage `≥ δ/q` (pigeonhole). For prime `q` only `q − 1` guesses admit valid
rerandomisation; for composite `q` there are `φ(q)`. Formalised as
`search_from_decision_arbitrary` (bound over all `q`) together with the count
`card_valid_multipliers`.

## Counterexample hunt

No counterexample to the unit criterion was found: exhaustive check over all
`(q, a) with 2 ≤ q ≤ 30, 0 ≤ a < q` confirms that `x ↦ a·x + b` is a bijection
of `ℤ_q` **iff** `gcd(a, q) = 1`, with no exceptions. This universal statement
is exactly what `affine_bijective_iff_coprime` proves.
