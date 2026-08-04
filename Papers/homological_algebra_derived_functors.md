# Computational Evidence

This note records the small-case calculations that guided the formalisation in
`Catalog/Algebra/DerivedFunctors/`. Everything asserted here as *proved* is proved in Lean in
that directory; the tables below are classical hand computations used to choose the statements,
and are **not** themselves machine-checked unless explicitly marked.

## 1. Ext and Tor for cyclic groups over `ℤ`

Using the free resolution `0 → ℤ --(·k)--> ℤ → ℤ/k → 0` one computes, for an abelian group `G`:

| group | value |
|---|---|
| `Hom(ℤ/k, G)` | `G[k] = {g : k·g = 0}` |
| `Ext¹(ℤ/k, G)` | `G/kG` |
| `Extⁿ(ℤ/k, G)`, `n ≥ 2` | `0` |
| `Tor₀(ℤ/k, G)` | `G/kG` |
| `Tor₁(ℤ/k, G)` | `G[k]` |
| `Torₙ(ℤ/k, G)`, `n ≥ 2` | `0` |

Specialising `G = ℤ/m` gives the classical table `Ext¹(ℤ/k, ℤ/m) ≅ Tor₁(ℤ/k, ℤ/m) ≅ ℤ/gcd(k,m)`:

| `k \ m` | 2 | 3 | 4 | 6 |
|---|---|---|---|---|
| **2** | 2 | 1 | 2 | 2 |
| **3** | 1 | 3 | 1 | 3 |
| **4** | 2 | 1 | 4 | 2 |
| **6** | 2 | 3 | 2 | 6 |

The entries are the orders `gcd(k,m)`; the doubly-indexed sequence of gcds is OEIS **A050873**
(the gcd triangle, first terms 1, 1, 2, 1, 1, 3, 1, 2, 1, 4, …).

Two extreme cases visible in this table drove the two Lean statements about `Ext¹`:

* `G = ℚ` is divisible, so `G/kG = 0` for every `k`: `Ext¹(ℤ/k, ℚ) = 0`.
* `G = ℤ` is not `k`-divisible for `k ≥ 2` (`k·z = 1` has no integer solution), so
  `Ext¹(ℤ/k, ℤ) ≅ ℤ/k ≠ 0`.

Both are proved in `Catalog/Algebra/DerivedFunctors/Ext.lean`, as instances of the general
criterion `ext_one_zmod_eq_zero_iff`: `Ext¹(ℤ/k, Y) = 0 ↔ Y is k-divisible`.

## 2. Counterexample hunt: does homology commute with `⊗ G`?

Testing the two-term complex `C : ℤ --(·k)--> ℤ` against several coefficient modules `G`:

| `G` | `H₁(C)` | `H₁(C ⊗ G)` | equal? |
|---|---|---|---|
| `ℤ` | `0` | `0` | yes |
| `ℚ` (flat) | `0` | `0` | yes |
| `ℤ/k`, `k ≥ 2` (not flat) | `0` | `ℤ/k` | **no** |

So the naive statement "`H(C ⊗ G) ≅ H(C) ⊗ G`" fails exactly when `G` is not flat, the discrepancy
being the `Tor₁` term of the universal coefficient sequence. This dichotomy is what
`Catalog/Algebra/DerivedFunctors/UniversalCoefficients.lean` formalises: the isomorphism
`homologyTensorFlatIso` for flat `G`, and the failure `tensor_zmod_not_exact` for `G = ℤ/k`,
`k ≥ 2` (a nonzero class `1 ⊗ 1` survives).

## 3. Divisibility checks (machine-checkable arithmetic)

The arithmetic facts underlying the examples are elementary and are discharged inside the Lean
proofs themselves rather than in scratch computations:

* `ℚ` is `k`-divisible for `k ≠ 0` (witness `y/k`), used in `ext_one_zmod_rat_eq_zero`;
* `ℤ` is not `k`-divisible for `k ≥ 2` (from `(k : ℤ) ∣ 1 → k ≤ 1`), used in
  `ext_one_zmod_int_ne_zero`;
* `k • (1 : ℤ/k) = 0` while `1 ≠ 0` in `ℤ/k` for `k ≥ 2`, used in `tensor_zmod_not_exact`.

No counterexample to any of the formalised statements was found during this exploration.

## 4. Update: which rows are now machine-checked

Since the tables above were written, the following entries have been upgraded from hand
computation to Lean theorems in `Catalog/Algebra/DerivedFunctors/`:

* `Tor₁(ℤ/k, G) ≅ G[k]` — `torOneZModIso` (`TorZMod.lean`), obtained from the bundled
  projective resolution `zmodProjectiveResolution` of `ℤ/k`;
* `Torₙ(ℤ/k, G) = 0` for `n ≥ 2` — `isZero_Tor_two_le_zmod` (`ZModResolution.lean`);
* `Tor₀(ℤ/k, G) = G ⊗ ℤ/k ≅ G/kG` — `tensorZModIso` (`TorZMod.lean`);
* `Ext¹(ℤ/k, G) ≅ G/kG` — `extOneZModEquiv` (`ExtZMod.lean`);
* the row `G = ℤ/k` of the counterexample table: `H₁(C ⊗ ℤ/k) ≅ Tor₁(ℤ/k, ℤ/k) ≅ ℤ/k ≠ 0` —
  `torOneZModSelfIso` and `torOneZMod_self_ne_zero` (`TorZMod.lean`), together with
  `not_exactAt_tensor_resComplex`;
* `Extⁿ(ℤ/k, G) = 0` for `n ≥ 2` and `Extⁿ(X, ℤ) = 0` for `n ≥ 2` — `ext_zmod_eq_zero`,
  `ext_int_eq_zero` (`Ext.lean`); the second is complemented by the bundled injective resolution
  `intInjectiveResolution` and the vanishing `isZero_rightDerived_of_two_le`
  (`IntInjectiveResolution.lean`).

The remaining entries of the tables (`Hom(ℤ/k, G) ≅ G[k]` and the `gcd` table) are still hand
computations only; the open questions raised by this material are collected in
`FUTURE_DIRECTIONS.md`.

## 5. Second update

Two further items from the tables are now machine-checked:

* the "`Tor₁` detects torsion" row: `Flat ℤ G ↔ ∀ k ≠ 0, Tor₁(G, ℤ/k) = 0` —
  `flat_iff_isZero_torOne_zmod`, with the auxiliary equivalences `flat_iff_torsionFree`,
  `isZero_kernel_mulBy_iff` and the strengthening `flat_iff_isZero_tor_succ`
  (`FlatCriterion.lean`); in particular `ℤ/k` is not flat for `k ≥ 2` (`not_flat_zmod`);
* the "projective dimension one" row beyond the cyclic case: `Extⁿ⁺²(X, Y) = 0` for every
  finitely generated `ℤ`-module `X` — `ext_fg_eq_zero` (`ExtFinitelyGenerated.lean`).
