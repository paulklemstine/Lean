# Computational Evidence — Isomorphisms of Meaning

The central quantitative claim is that the number of self-identifications
(automorphisms) of the cyclic group `ZMod n` equals Euler's totient `φ(n)`, and
that this is the exact "measure of ambiguity" of any identification with a cyclic
group of order `n`.

## 1. Small-case calculations: `#(ZMod n ≃+ ZMod n) = φ(n)`

| n  | automorphisms of ℤ/n (units of ℤ/n) | φ(n) |
|----|-------------------------------------|------|
| 1  | {0}                                 | 1    |
| 2  | {1}                                 | 1    |
| 3  | {1, 2}                              | 2    |
| 4  | {1, 3}                              | 2    |
| 5  | {1, 2, 3, 4}                        | 4    |
| 6  | {1, 5}                              | 2    |
| 7  | {1,…,6}                             | 6    |
| 8  | {1, 3, 5, 7}                        | 4    |
| 9  | {1,2,4,5,7,8}                       | 6    |
| 12 | {1, 5, 7, 11}                       | 4    |

Each additive automorphism of `ZMod n` is `x ↦ u·x` for a unit `u`, matching
`(ZMod n)ˣ`.  This is formalized as `card_aut_zmod` using
`ZMod.AddAutEquivUnits` and `ZMod.card_units_eq_totient`.

## 2. OEIS

The totient sequence φ(n): 1, 1, 2, 2, 4, 2, 6, 4, 6, 4, 10, 4, … is
**OEIS A000010**.  The count of automorphisms of the cyclic group C_n coincides
with it.

## 3. The negation automorphism

For `n ≥ 3`, negation `x ↦ -x` is a nontrivial automorphism (it moves `1` to
`n-1 ≠ 1`).  Check: `-1 = 1` in `ZMod n` would force `2 ≡ 0 (mod n)`, i.e.
`n ∣ 2`, impossible for `n ≥ 3`.  For `n ∈ {1, 2}` negation is the identity,
consistent with `φ(1) = φ(2) = 1` (only one automorphism, so the identification
is unique there — no ambiguity).  Formalized as `negAut_ne_refl`.

## 4. Collision vs. non-collision (same cardinality, order-4 test)

Groups of order 4, tested by the element-order spectrum (a preserved invariant):

| group            | order spectrum (multiset of `addOrderOf`) | cyclic? |
|------------------|-------------------------------------------|---------|
| ℤ/4              | {1, 4, 2, 4}                              | yes     |
| ℤ/2 × ℤ/2 (Klein)| {1, 2, 2, 2}                              | no      |

The spectra differ, so the two groups are **not** isomorphic
(`no_iso_klein`).  In contrast, `ℤ/6` and `ℤ/2 × ℤ/3` share the spectrum
{1,6,3,2,3,6} and are isomorphic by CRT (`crtCollision`).

## 5. Counterexample hunt

- "Every two groups of equal cardinality are isomorphic" — FALSE, witnessed by
  ℤ/4 vs. ℤ/2×ℤ/2 above; formalized as `no_iso_klein`.
- "The identification of a cyclic group with ℤ/n is unique" — FALSE for `n ≥ 3`;
  formalized as `two_distinct_self_isos` (identity vs. negation), quantified by
  `card_iso_to_zmod` (there are φ(n) of them).

All computed facts are discharged formally in `IsomorphismsOfMeaning.lean`.
