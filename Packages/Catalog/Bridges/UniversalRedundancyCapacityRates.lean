/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality VII: uniqueness of the optimal code, and smoothed rates

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

Two loose ends of the capacity theory are tied here.

**Uniqueness.**  The redundancy–capacity theorem produces *a* capacity-achieving
prior; different priors could conceivably give different optimal codes.  They
cannot: `mix_eq_of_capacity_priors` shows the optimal Bayes mixture is unique.
The optimal universal decompressor is therefore a canonical object attached to
the source class, not an artefact of the optimisation.  The proof is three lines
of the compensation identity plus the strict Gibbs inequality — an illustration
of how much the saddle point buys.

**Rates.**  The capacity theory requires strictly positive sources, whereas the
richest classes in the catalog (types, deterministic files) are mutually
singular.  Smoothing repairs this: `smoothClass` mixes `ε` of the uniform law
into every source, which keeps the class distinguishable and makes it strictly
positive.  The price of universality of the smoothed class is still
`log₂ N` up to `ε log₂ N + 4` bits (`capacity_smoothClass_sandwich`), and for the
constant-composition class of `n`-bit files this gives an *`n`-dependent*
average-case bound: `(1 − ε) log₂ (n+1) − 4 ≤ C ≤ log₂ (n+1)`.

## Main results

* `mix_eq_of_capacity_priors` — the capacity-achieving mixture is unique
* `smoothClass`, `smoothClass_pos`, `smoothClass_mass_ge` — `ε`-smoothing
* `capacity_smoothClass_sandwich` — the price of a smoothed distinguishable class
* `capacity_smoothed_compositionClass_sandwich` — `log₂(n+1) ± (ε log₂(n+1) + 4)`
  for the constant-composition class of `n`-bit files

## Application keywords

universal compression, minimax redundancy, capacity, uniqueness of the Bayes
mixture, smoothing, constant-composition sources, price of universality
-/

import Bridges.UniversalRedundancyCapacityStructure
import NumberTheory.UniversalRedundancyTypeClass

open Finset Real

namespace UniversalRedundancy

variable {X : Type*} [Fintype X] {Θ : Type*} [Fintype Θ]

namespace SourceClass

variable (S : SourceClass X Θ)

/-! ## Uniqueness of the optimal universal code -/

/-- **The capacity-achieving mixture is unique.**  Two capacity-achieving priors
induce the same Bayes mixture, so the optimal universal coding distribution is a
canonical invariant of the source class. -/
theorem mix_eq_of_capacity_priors [Nonempty Θ] (hpos : ∀ θ x, 0 < S.prob θ x)
    {w₁ w₂ : Θ → ℝ} (hw₁ : w₁ ∈ stdSimplex ℝ Θ) (hw₂ : w₂ ∈ stdSimplex ℝ Θ)
    (he₁ : S.mutualInfo w₁ = S.capacity) (he₂ : S.mutualInfo w₂ = S.capacity) :
    S.mix w₁ = S.mix w₂ := by
  have hm₁ := S.mix_pos_of_mem_stdSimplex hpos hw₁
  have hm₂ := S.mix_pos_of_mem_stdSimplex hpos hw₂
  have hm₁1 : ∑ x, S.mix w₁ x = 1 := S.mix_sum_one hw₁.2
  have hm₂1 : ∑ x, S.mix w₂ x = 1 := S.mix_sum_one hw₂.2
  -- the saddle point at `w₂`
  have hmax₂ : ∀ w ∈ stdSimplex ℝ Θ, S.mutualInfo w ≤ S.mutualInfo w₂ := by
    intro w hw
    rw [he₂]
    exact S.mutualInfo_le_capacity hpos hw
  have hsaddle : ∀ θ, klDiv (S.prob θ) (S.mix w₂) ≤ S.capacity := fun θ => by
    rw [← he₂]
    exact S.klDiv_le_mutualInfo_of_isMaxOn hpos hw₂ hmax₂ θ
  -- compensation with prior `w₁` and coding distribution `m₂`
  have hcomp := S.bayes_compensation (w := w₁) (q := S.mix w₂) hm₂ hm₁
  have hupper : ∑ θ, w₁ θ * klDiv (S.prob θ) (S.mix w₂) ≤ S.capacity := by
    calc ∑ θ, w₁ θ * klDiv (S.prob θ) (S.mix w₂) ≤ ∑ θ, w₁ θ * S.capacity :=
          Finset.sum_le_sum fun θ _ => mul_le_mul_of_nonneg_left (hsaddle θ) (hw₁.1 θ)
      _ = S.capacity := by rw [← Finset.sum_mul, hw₁.2, one_mul]
  have hzero : klDiv (S.mix w₁) (S.mix w₂) ≤ 0 := by
    rw [he₁] at hcomp
    linarith
  by_contra hne
  have hpos' : 0 < klDiv (S.mix w₁) (S.mix w₂) :=
    klDiv_pos_of_ne (fun x => (hm₁ x).le) hm₂ hm₁1 hm₂1 hne
  linarith

/-! ## Smoothing a mutually singular class -/

variable [Nonempty X]

/-- **`ε`-smoothing**: mix a fraction `ε` of the uniform law into every source.
The result is strictly positive, so the capacity theory applies, while the class
stays `ε`-distinguishable. -/
noncomputable def smoothClass (ε : ℝ) (hε0 : 0 ≤ ε) (hε1 : ε ≤ 1) :
    SourceClass X Θ where
  prob θ x := (1 - ε) * S.prob θ x + ε / (Fintype.card X : ℝ)
  nonneg θ x := by
    have hcard : (0 : ℝ) < (Fintype.card X : ℝ) := by exact_mod_cast Fintype.card_pos
    have h1 : 0 ≤ (1 - ε) * S.prob θ x := mul_nonneg (by linarith) (S.nonneg θ x)
    have h2 : 0 ≤ ε / (Fintype.card X : ℝ) := by positivity
    linarith
  sum_one θ := by
    have hcard : (0 : ℝ) < (Fintype.card X : ℝ) := by exact_mod_cast Fintype.card_pos
    rw [Finset.sum_add_distrib, ← Finset.mul_sum, S.sum_one θ, Finset.sum_const,
      Finset.card_univ, nsmul_eq_mul]
    field_simp
    ring

omit [Fintype Θ] in
lemma smoothClass_pos {ε : ℝ} (hε0 : 0 < ε) (hε1 : ε ≤ 1) (θ : Θ) (x : X) :
    0 < (S.smoothClass ε hε0.le hε1).prob θ x := by
  have hcard : (0 : ℝ) < (Fintype.card X : ℝ) := by exact_mod_cast Fintype.card_pos
  have h1 : 0 ≤ (1 - ε) * S.prob θ x := mul_nonneg (by linarith) (S.nonneg θ x)
  have h2 : 0 < ε / (Fintype.card X : ℝ) := by positivity
  show 0 < (1 - ε) * S.prob θ x + ε / (Fintype.card X : ℝ)
  linarith

omit [Fintype Θ] in
/-- Smoothing keeps the concentration sets: a source that lived on `A` still has
mass at least `1 − ε` there. -/
lemma smoothClass_mass_ge {ε : ℝ} (hε0 : 0 ≤ ε) (hε1 : ε ≤ 1) {A : Finset X} {θ : Θ}
    (hA : ∑ x ∈ A, S.prob θ x = 1) :
    1 - ε ≤ ∑ x ∈ A, (S.smoothClass ε hε0 hε1).prob θ x := by
  have hcard : (0 : ℝ) < (Fintype.card X : ℝ) := by exact_mod_cast Fintype.card_pos
  have hterm : ∀ x ∈ A, (1 - ε) * S.prob θ x ≤ (S.smoothClass ε hε0 hε1).prob θ x := by
    intro x _
    have h2 : 0 ≤ ε / (Fintype.card X : ℝ) := by positivity
    show (1 - ε) * S.prob θ x ≤ (1 - ε) * S.prob θ x + ε / (Fintype.card X : ℝ)
    linarith
  calc (1 : ℝ) - ε = ∑ x ∈ A, (1 - ε) * S.prob θ x := by
        rw [← Finset.mul_sum, hA, mul_one]
    _ ≤ ∑ x ∈ A, (S.smoothClass ε hε0 hε1).prob θ x := Finset.sum_le_sum hterm

/-- **The price of universality of a smoothed distinguishable class.**  If `N`
sources live on pairwise disjoint sets, their `ε`-smoothings form a strictly
positive class whose average price of universality is `log₂ N` up to
`ε log₂ N + 4` bits. -/
theorem capacity_smoothClass_sandwich [Nonempty Θ] [DecidableEq X] {ε : ℝ}
    (hε0 : 0 < ε) (hε1 : ε ≤ 1) (A : Θ → Finset X)
    (hdisj : ∀ θ θ', θ ≠ θ' → Disjoint (A θ) (A θ'))
    (hmass : ∀ θ, ∑ x ∈ A θ, S.prob θ x = 1) :
    (1 - ε) * logb 2 (Fintype.card Θ) - 4 ≤ (S.smoothClass ε hε0.le hε1).capacity ∧
      (S.smoothClass ε hε0.le hε1).capacity ≤ logb 2 (Fintype.card Θ) := by
  have hpos := S.smoothClass_pos hε0 hε1
  exact (S.smoothClass ε hε0.le hε1).capacity_approx_disjoint_sandwich hpos A hdisj
    (fun θ => S.smoothClass_mass_ge hε0.le hε1 (hmass θ))

end SourceClass

/-! ## An `n`-dependent average-case rate

The constant-composition class of `n`-bit files: source `c` is uniform on the
strings with exactly `c` ones.  Smoothed, it is a strictly positive class of
`n + 1` sources whose average price of universality is `log₂ (n+1)` up to
`ε log₂ (n+1) + 4` bits — the price of universality of a *rich* class grows
logarithmically in the message length even in the average case. -/
theorem capacity_smoothed_compositionClass_sandwich (n : ℕ) {ε : ℝ}
    (hε0 : 0 < ε) (hε1 : ε ≤ 1) :
    (1 - ε) * logb 2 ((n : ℝ) + 1) - 4
        ≤ ((compositionClass n).smoothClass ε hε0.le hε1).capacity ∧
      ((compositionClass n).smoothClass ε hε0.le hε1).capacity ≤ logb 2 ((n : ℝ) + 1) := by
  classical
  have hcard : ((Fintype.card (Fin (n + 1)) : ℕ) : ℝ) = (n : ℝ) + 1 := by simp
  have h := (compositionClass n).capacity_smoothClass_sandwich hε0 hε1
    (fun c => univ.filter (fun y => typeStat n y = c))
    (fun c c' hcc' => fiberClass_disjoint (typeStat n) c c' hcc')
    (fun c => fiberClass_mass (typeStat n) (typeStat_fiber_nonempty n) c)
  rwa [hcard] at h

end UniversalRedundancy