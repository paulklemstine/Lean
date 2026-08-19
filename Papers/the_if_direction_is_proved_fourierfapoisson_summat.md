# Computational evidence

Companion to the Lean development in `Catalog/Probability/Fourier*.lean`. Every number below was
produced by the machine-checked file `Catalog/Probability/FourierExtremalEvidence.lean`, which is
part of the build (all figures are `#eval` outputs of that file; the coset check is additionally a
kernel-verified `decide` theorem).

## 1. Exact model

On `G = ℤ/4` every character takes values in `{1, i, -1, -i} ⊆ ℤ[i]`, so the discrete Fourier
transform

`f̂(k) = ∑_x conj(i^{kx}) f(x)`

can be evaluated with *exact* integer arithmetic (Gaussian integers as pairs of integers). We
enumerate all `5^4 = 625` functions `ℤ/4 → {0, 1, -1, i, -i}`.

## 2. Small-case calculations

| experiment | result |
|---|---|
| functions tested / nonzero | 625 / 624 |
| Donoho–Stark bound `|supp f| · |supp f̂| ≥ 4` holds for all nonzero `f` | `true` |
| extremals (`|supp f| · |supp f̂| = 4`) in the sample | 48 |
| extremal support-size distribution, sizes `0,1,2,3,4` | `0, 16, 16, 0, 16` |
| every extremal support is closed under `x - y + z` (coset test) | `true` |
| every extremal has constant modulus on its support | `true` |
| every extremal *frequency* support is a coset | `true` |
| pointwise products of extremals: zero or extremal | `true` |
| convolutions of extremals: zero or extremal | `true` |
| `supp f = {0,1}` (not a coset): `(|supp f|, |supp f̂|) = (2,3)`, product `6 > 4` | not extremal |

## 3. Comparison with the proved theorems

* The **absence of extremals with support size 3** is the prediction of
  `FourierFA.isExtremal_iff_coset_modulation`: 3 is not the order of a subgroup of `ℤ/4`.
* The three counts `16, 16, 16` match the classification exactly:
  * size 1: `4` positions × `4` admissible unit values;
  * size 2: `2` cosets of `{0,2}` × `4` values × `2` characters modulo the annihilator;
  * size 4: `4` characters × `4` values.
* Constant modulus on the support is `FourierFA.isExtremal_flat`.
* Closure under products and convolutions is `FourierFA.isExtremal_mul` and
  `FourierFA.isExtremal_conv`.
* The coset shape of the *frequency* support is `FourierFA.isExtremal_supports`.

## 4. Counterexample hunt

We searched for a **non-coset extremal support** (which would refute the classification) across
the whole 625-function sample: none exists. We also checked the smallest suspicious support
`{0,1}` explicitly: its transform has full support, giving `2 · 3 = 6 > 4`, so the uncertainty
inequality is strict, exactly as the classification demands.

Two further conjectures were *tested and refuted before formalisation*, which is why the theorems
are stated as disjunctions:

* "the product of two extremals is extremal" is false — take indicators of disjoint cosets, the
  product is `0`; hence `FourierFA.isExtremal_mul` reads *zero or extremal*;
* "the convolution of two extremals is extremal" is false for the same reason on the frequency
  side (disjoint frequency cosets), hence the disjunction in `FourierFA.isExtremal_conv`.

## 5. OEIS

The observed sequence of extremal counts is an artefact of the restricted value alphabet
(`16, 16, 16`), so no OEIS identification is claimed.

## 6. Scope

`ℤ/4` was chosen because it is the largest cyclic group whose character values stay inside a
*computable* ring with decidable equality (`ℤ[i]`); groups such as `ℤ/3` or `ℤ/6` would require
cyclotomic arithmetic and were therefore analysed by hand rather than by machine. All general
statements in this project are proved for an arbitrary finite abelian group, so the computations
serve as sanity checks rather than as the basis of the results.

## 7. Cycle 2: the divisor prediction, and its confirmation

The classification of the extremals predicts an arithmetic constraint that the `ℤ/4` enumeration
above already displays: the observed extremal support-size distribution over sizes `0,1,2,3,4` is
`0, 16, 16, 0, 16` — every size that occurs (`1, 2, 4`) divides `|G| = 4`, and the size `3`, which
does not divide `4`, never occurs.

This is no longer only experimental. `FourierFA.card_supp_dvd_card` proves that the support size
of an extremal function always divides `|G|`, `FourierFA.card_supp_isExtremal_iff` proves that the
achievable sizes are exactly the subgroup orders, and `FourierFA.zmod_card_supp_isExtremal_iff`
specialises this to `ℤ/n`, where the achievable sizes are exactly the divisors of `n`. The
`ℤ/4` table is the instance `n = 4` of that theorem.

The same computation is the source of the *gap* statement `FourierFA.uncertainty_gap_of_not_dvd`:
in the enumeration, no nonzero function with a `3`-element support ever attains the value `4` for
`|supp f| · |supp f̂|`; the smallest value observed for such functions is `6 ≥ 4 + 1`, consistent
with (and now implied by) the theorem.

## 8. Cycle 3: the residue gap is exactly the observed one

The `ℤ/4` enumeration also pins down the *size* of the gap, not just its existence. For a
support of size `s = 3` in a group of order `n = 4` the sharpened bound
`FourierFA.uncertainty_gap_mod` predicts

`|supp f| · |supp f̂| ≥ n + (s - n mod s) = 4 + (3 - 1) = 6`,

whereas the earlier `FourierFA.uncertainty_gap_of_not_dvd` only gave `≥ 5`. The exhaustive
enumeration reports `6` as the smallest value actually attained by a `3`-element support, so on
this instance the sharpened bound is attained and the weaker bound is not. This is what
motivated proving the rounded-up form `FourierFA.uncertainty_ceil`
(`|supp f̂| ≥ ⌈|G| / |supp f|⌉`), from which the residue gap follows.

The same table is the `n = 4` instance of the group-independent extremal spectrum theorem
`FourierFA.card_supp_isExtremal_iff_dvd`: sizes `1, 2, 4` occur and `3` does not, because the
occurring sizes are exactly the divisors of `|G|` — for *every* finite abelian group, not only
the cyclic ones, the cyclic restriction having been removed by the converse of Lagrange's
theorem `FourierFA.exists_addSubgroup_card_eq_of_dvd`.

## 9. Cycle 3: a machine-checked separation of the two groups of order 4

The reduction of extremality of a *support* to closure under `(x, y, z) ↦ x - y + z`
(`FourierFA.exists_isExtremal_supp_eq_iff_parallelogram`) makes the family of extremal supports
a decidable finite object, so it can be enumerated by the kernel rather than by an external
script. Enumerating all `2^4 = 16` subsets of each group of order `4` gives

| group | extremal supports of size 2 |
|---|---|
| `ℤ/4` | 2 (the cosets of `{0, 2}`) |
| `ℤ/2 × ℤ/2` | 6 (two cosets for each of the three subgroups of order 2) |

both proved by `decide` in `FourierFA.card_extremalSupports_two_zmod4` and
`FourierFA.card_extremalSupports_two_klein` (kernel reduction, not `native_decide`). Since the
two groups have the same extremal *spectrum* by `FourierFA.extremal_spectrum_eq_of_card_eq`,
this is a proof that the spectrum is a strictly coarser invariant than the family of supports:
`FourierFA.extremalSupports_separates_order_four`.
