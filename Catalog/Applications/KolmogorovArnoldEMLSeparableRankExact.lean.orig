/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Structural calculus of separable rank (EML Kolmogorov–Arnold outer count)

Building on `Catalog/Applications/KolmogorovArnoldEMLSeparableRank.lean`, which
introduces the *separable rank* `SepRankLE f r` — the number of outer terms in a
sum-of-products Kolmogorov–Arnold superposition `f x y = ∑_{k<r} a_k(x)·b_k(y)`
— this file develops its structural calculus and pins down exact ranks.

## Main results

* `SepRankLE.mono` — separable rank is upward closed (`r ≤ s` extends a rank-`r`
  representation by zero terms).
* `SepRankLE.add` — **subadditivity**: a rank-`≤ r` plus a rank-`≤ s` target has
  rank `≤ r + s` (concatenate the term lists).
* `powerSum_sepRank_exact` — the power-sum family `∑_{k<N} xᵏ yᵏ` has separable
  rank **exactly `N`**: it has rank `≤ N`, but *not* rank `≤ N-1`.  Combined with
  `SepRankLE.mono` this fixes the rank precisely.
* `powerSum_continuous_slices` — each coordinate slice of `powerSum N` is
  continuous, so its EML sum-of-products representation meets the continuity
  demanded by the Kolmogorov–Arnold theorem.

## Lab Notes — see `-- !-- Lab Notes -- !--` block below.
-/
import Mathlib
import Catalog.Applications.KolmogorovArnoldEMLSeparableRank

open Real Matrix Finset

namespace KolmogorovArnoldEMLSepRank

/-! ### Monotonicity -/

/-
Separable rank is **upward closed**: a rank-`≤ r` target also has rank `≤ s`
for any `s ≥ r`, by padding with zero terms.
-/
theorem SepRankLE.mono {f : ℝ → ℝ → ℝ} {r s : ℕ} (hrs : r ≤ s)
    (h : SepRankLE f r) : SepRankLE f s := by
  -- Define a' and b' such that for k < r, a' k x = a k x and b' k y = b k y, and for k ≥ r, a' k x = 0 and b' k y = 0.
  obtain ⟨a, b, hab⟩ := h;
  use fun k x => if hk : k.val < r then a ⟨k.val, hk⟩ x else 0, fun k y => if hk : k.val < r then b ⟨k.val, hk⟩ y else 0;
  intro x y; rw [ hab ] ; rw [ ← Finset.sum_subset ( Finset.subset_univ { k : Fin s | k.val < r } ) ] <;> simp +decide ;
  · refine' Finset.sum_bij ( fun k hk => ⟨ k, by linarith [ Fin.is_lt k ] ⟩ ) _ _ _ _ <;> simp +decide [ Fin.ext_iff ];
    exact fun b hb => ⟨ ⟨ b, hb ⟩, rfl ⟩;
  · grind

/-! ### Subadditivity under sums -/

/-
**Subadditivity.** If `f` has separable rank `≤ r` and `g` has separable rank
`≤ s`, then `f + g` has separable rank `≤ r + s`: concatenate the two term
lists.
-/
theorem SepRankLE.add {f g : ℝ → ℝ → ℝ} {r s : ℕ}
    (hf : SepRankLE f r) (hg : SepRankLE g s) :
    SepRankLE (fun x y => f x y + g x y) (r + s) := by
  obtain ⟨a₁, b₁, h₁⟩ := hf
  obtain ⟨a₂, b₂, h₂⟩ := hg

  use Fin.addCases a₁ a₂, Fin.addCases b₁ b₂;
  simp +decide [ Fin.sum_univ_add, h₁, h₂ ]

/-! ### Exact rank of the power-sum family -/

/-- **Exact separable rank.** The power-sum target `∑_{k<N} xᵏ yᵏ` has separable
rank `≤ N` but not `≤ N-1`; together with `SepRankLE.mono` this means its
separable rank is exactly `N`. -/
theorem powerSum_sepRank_exact (N : ℕ) (hN : 0 < N) :
    SepRankLE (powerSum N) N ∧ ¬ SepRankLE (powerSum N) (N - 1) := by
  refine ⟨powerSum_sepRankLE N, ?_⟩
  intro h
  have := powerSum_rank_ge N h
  omega

/-! ### Continuity of the slices (Kolmogorov–Arnold continuity) -/

/-
Each coordinate slice `x ↦ powerSum N x c` is continuous, matching the
continuity required of a Kolmogorov–Arnold representation.
-/
theorem powerSum_continuous_slices (N : ℕ) (c : ℝ) :
    Continuous (fun x => powerSum N x c) := by
  exact continuous_finset_sum _ fun _ _ => Continuous.mul ( continuous_pow _ ) ( continuous_const.pow _ )

/-
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).** If separable rank is a true invariant, it should
behave like a rank: monotone, subadditive under sums, and exactly computable on
a structured family.  Conjecture: `sepRank(f+g) ≤ sepRank f + sepRank g`, and the
power-sum family realizes every value `N`.

**Experiment (Experimenter).** `SepRankLE.mono` pads a representation with zero
terms; `SepRankLE.add` concatenates term lists across `Fin (r+s)` (via the
`Fin.sum_univ_add`/`Sum` split).  `powerSum_sepRank_exact` combines the upper
bound `powerSum_sepRankLE` with the Vandermonde lower bound `powerSum_rank_ge`
from the companion file, giving exact rank `N`.  `powerSum_continuous_slices`
discharges Kolmogorov–Arnold continuity.

**Analysis (Analyst).** SURVIVED with 0 sorries.  Subadditivity is the formal
reason polarization-style decompositions (`x·y = ¼(x+y)² − ¼(x−y)²`) keep the
outer count small: a sum of two rank-low pieces stays low.  Exactness shows the
invariant is *sharp*, not just an upper estimate.

**Critique (Critic).** No theorem is trivial: `mono`/`add` manipulate real
families and finite sums; exactness depends on the genuine determinant lower
bound.  Corner case: `N = 0` is excluded in exactness (the empty target is the
zero function, rank 0); `hN : 0 < N` records this boundary.

**Synthesis (PI).** Separable rank obeys a clean rank calculus (monotone,
subadditive) and is exactly computable on the power-sum family, confirming it is
a faithful complexity measure for EML Kolmogorov–Arnold outer terms.
-/

end KolmogorovArnoldEMLSepRank