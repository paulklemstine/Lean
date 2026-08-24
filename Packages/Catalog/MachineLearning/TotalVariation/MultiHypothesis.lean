/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Shtarkov sum *is* the multi-hypothesis testing optimum

`Testing` identified the binary optimum: the least average error of a Boolean
test for `p` versus `q` is `(1 − d_TV(p, q))/2`.  The catalog's universal-coding
thread knows a different quantity for the same pair — the **Shtarkov sum**
`Cₛ = ∑ₓ max_θ p_θ x`, with `Cₛ = 1 + d_TV(p, q)` for two sources.

Those two facts are not a coincidence.  This file proves the general identity:
for a class of `m` sources under a uniform prior, the least average error of an
`m`-ary decision rule is

`1 − Cₛ / m`,

attained by the maximum-likelihood rule.  The universal-coding price and the
statistical testing optimum are literally the same sum, viewed twice.  The
binary case reproduces `isLeast_bayesError` on the nose
(`isLeast_mAryError_bool`), which is a nontrivial cross-check of the two
independent developments.

Two rigidity corollaries come for free from the catalog's endpoint analysis:

* mutually singular sources give error `0` (perfect identification);
* identical sources give error `1 − 1/m` (pure guessing);
* and quantitatively, sources within `ε` of a common reference force error at
  least `(m − 1)/m − ε` (`mAryError_ge_of_tvDist`), the multi-hypothesis Le Cam
  bound.

## Main results

* `SourceClass.mAryError`, `SourceClass.mAryError_eq` — the error functional;
* `SourceClass.isLeast_mAryError` — the optimum is `1 − Cₛ/m`;
* `SourceClass.isLeast_mAryError_bool` — binary consistency with `Testing`;
* `SourceClass.mAryError_ge_of_tvDist` — the multi-hypothesis Le Cam bound;
* `SourceClass.mAryError_eq_zero_iff_mutuallySingular` — the rigid endpoint.

## Application keywords

multi-hypothesis testing, Bayes risk, maximum likelihood, Shtarkov sum,
universal coding, Le Cam method
-/

import MachineLearning.TotalVariation.Testing

open Finset

namespace UniversalRedundancy

namespace SourceClass

variable {X : Type*} [Fintype X] {Θ : Type*} [Fintype Θ] [Nonempty Θ] [DecidableEq Θ]

/-- Average (uniform-prior) error probability of the `m`-ary decision rule `T`,
which reads the sample `x` and outputs the hypothesis `T x`. -/
noncomputable def mAryError (S : SourceClass X Θ) (T : X → Θ) : ℝ :=
  (∑ θ, ∑ x ∈ univ.filter fun x => T x ≠ θ, S.prob θ x) / Fintype.card Θ

omit [Nonempty Θ] in
/-- Regrouping the fibers of a decision rule. -/
lemma sum_fiber_prob (S : SourceClass X Θ) (T : X → Θ) :
    ∑ θ, ∑ x ∈ univ.filter fun x => T x = θ, S.prob θ x = ∑ x, S.prob (T x) x := by
  classical
  have h1 : ∀ θ : Θ, ∑ x ∈ univ.filter fun x => T x = θ, S.prob θ x
      = ∑ x, if T x = θ then S.prob θ x else 0 := fun θ => Finset.sum_filter _ _
  rw [Finset.sum_congr rfl fun θ _ => h1 θ, Finset.sum_comm]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [Finset.sum_ite_eq univ (T x) fun θ => S.prob θ x]
  simp

/-- The error of a rule is one minus its average likelihood score. -/
lemma mAryError_eq (S : SourceClass X Θ) (T : X → Θ) :
    S.mAryError T = 1 - (∑ x, S.prob (T x) x) / Fintype.card Θ := by
  classical
  have hm : (Fintype.card Θ : ℝ) ≠ 0 := by
    have := Fintype.card_pos (α := Θ)
    positivity
  have hrow : ∀ θ : Θ, ∑ x ∈ univ.filter (fun x => T x ≠ θ), S.prob θ x
      = 1 - ∑ x ∈ univ.filter (fun x => T x = θ), S.prob θ x := by
    intro θ
    have hsplit := Finset.sum_filter_add_sum_filter_not univ (fun x => T x = θ) (S.prob θ)
    rw [S.sum_one θ] at hsplit
    have hfil : (univ.filter fun x => T x ≠ θ) = univ.filter fun x => ¬ (T x = θ) := by
      simp [ne_eq]
    rw [hfil]
    linarith
  rw [mAryError, Finset.sum_congr rfl fun θ _ => hrow θ, Finset.sum_sub_distrib,
    sum_fiber_prob, Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]
  field_simp

/-- The maximum-likelihood decision rule. -/
noncomputable def mlRule (S : SourceClass X Θ) (x : X) : Θ :=
  (Finite.exists_max fun θ => S.prob θ x).choose

omit [DecidableEq Θ] in
lemma prob_mlRule (S : SourceClass X Θ) (x : X) : S.prob (S.mlRule x) x = S.maxLik x := by
  have hspec := (Finite.exists_max fun θ => S.prob θ x).choose_spec
  exact le_antisymm (S.le_maxLik _ x) (S.maxLik_le hspec)

/-- **The multi-hypothesis optimum is `1 − Cₛ/m`.**  The maximum-likelihood rule
attains it and no rule beats it, so the Shtarkov sum of a source class — an
object from universal *coding* — is exactly its `m`-ary *testing* score. -/
theorem isLeast_mAryError (S : SourceClass X Θ) :
    IsLeast (Set.range S.mAryError) (1 - S.shtarkovSum / Fintype.card Θ) := by
  have hmpos : (0:ℝ) < Fintype.card Θ := by
    have := Fintype.card_pos (α := Θ)
    positivity
  constructor
  · refine ⟨S.mlRule, ?_⟩
    rw [mAryError_eq, shtarkovSum]
    congr 2
    exact Finset.sum_congr rfl fun x _ => S.prob_mlRule x
  · rintro r ⟨T, rfl⟩
    rw [mAryError_eq]
    have hle : ∑ x, S.prob (T x) x ≤ S.shtarkovSum :=
      Finset.sum_le_sum fun x _ => S.le_maxLik (T x) x
    have hdiv : (∑ x, S.prob (T x) x) / (Fintype.card Θ : ℝ)
        ≤ S.shtarkovSum / Fintype.card Θ := (div_le_div_iff_of_pos_right hmpos).mpr hle
    linarith

/-- **Binary consistency.**  For two hypotheses the optimum is
`(1 − d_TV)/2`, exactly the value delivered by `isLeast_bayesError` — the
coding-theoretic and the statistical derivations agree. -/
theorem isLeast_mAryError_bool (S : SourceClass X Bool) :
    IsLeast (Set.range S.mAryError)
      ((1 - tvDist (S.prob true) (S.prob false)) / 2) := by
  have h := isLeast_mAryError S
  have hcard : (Fintype.card Bool : ℝ) = 2 := by simp
  rw [shtarkovSum_pair_eq_one_add_tvDist S, hcard] at h
  have hval : 1 - (1 + tvDist (S.prob true) (S.prob false)) / 2
      = (1 - tvDist (S.prob true) (S.prob false)) / 2 := by ring
  rwa [hval] at h

/-- **Multi-hypothesis Le Cam bound.**  If every source is within `ε` of a
common reference `θ₀` in total variation, then *no* decision rule can beat
`(m − 1)/m − ε`: an `m`-way statistical problem is essentially unsolvable when
the hypotheses cluster. -/
theorem mAryError_ge_of_tvDist (S : SourceClass X Θ) (θ₀ : Θ) {ε : ℝ}
    (hε : ∀ θ, tvDist (S.prob θ) (S.prob θ₀) ≤ ε / Fintype.card Θ) (T : X → Θ) :
    1 - 1 / Fintype.card Θ - ε / Fintype.card Θ ≤ S.mAryError T := by
  have hmpos : (0:ℝ) < Fintype.card Θ := by
    have := Fintype.card_pos (α := Θ)
    positivity
  have hub : S.shtarkovSum ≤ 1 + ε := by
    have h1 := shtarkovSum_le_one_add_sum_tvDist S θ₀
    have h2 : ∑ θ, tvDist (S.prob θ) (S.prob θ₀) ≤ ∑ _θ : Θ, ε / Fintype.card Θ :=
      Finset.sum_le_sum fun θ _ => hε θ
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] at h2
    have h3 : (Fintype.card Θ : ℝ) * (ε / Fintype.card Θ) = ε := by
      field_simp
    linarith [h1, h2, h3.le, h3.ge]
  have hlow := (isLeast_mAryError S).2 ⟨T, rfl⟩
  have hdiv : S.shtarkovSum / Fintype.card Θ ≤ (1 + ε) / Fintype.card Θ :=
    (div_le_div_iff_of_pos_right hmpos).mpr hub
  have hsplit : (1 + ε) / (Fintype.card Θ : ℝ)
      = 1 / Fintype.card Θ + ε / Fintype.card Θ := by ring
  linarith [hlow, hdiv, hsplit.le, hsplit.ge]

omit [DecidableEq Θ] in
/-- **Rigid endpoint.**  The `m`-ary problem is perfectly solvable exactly when
the sources are mutually singular — the testing reading of the catalog's
rigidity theorem `shtarkovSum_eq_card_iff_mutuallySingular`. -/
theorem mAryError_eq_zero_iff_mutuallySingular (S : SourceClass X Θ) :
    (1 - S.shtarkovSum / Fintype.card Θ) = 0 ↔ S.MutuallySingular := by
  have hmpos : (0:ℝ) < Fintype.card Θ := by
    have := Fintype.card_pos (α := Θ)
    positivity
  rw [← shtarkovSum_eq_card_iff_mutuallySingular]
  constructor
  · intro h
    have : S.shtarkovSum / Fintype.card Θ = 1 := by linarith
    field_simp at this
    exact this
  · intro h
    rw [h, div_self (ne_of_gt hmpos)]
    ring

end SourceClass

end UniversalRedundancy