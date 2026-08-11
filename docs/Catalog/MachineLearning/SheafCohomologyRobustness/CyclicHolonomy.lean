/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Exact Computation of `H¹` of the Loop Nerve, and the Quantitative Defect Theorem

`SheafCohomologyRobustness.Cohomology` proved that the cyclic (loop) nerve has
*nonvanishing* first cohomology, by exhibiting one non-coboundary.  This file
computes the cohomology **exactly** and extracts the resulting quantitative
certified-robustness statement.

Main results.

* `deltaCyc_of_sum_zero` / `isCoboundary_iff_holonomy_zero` — a cyclic overlap
  discrepancy `g` glues **iff** its holonomy `∑ᵢ gᵢ` vanishes.  Together with
  `Cohomology.deltaCyc_sum_zero` this identifies the coboundaries with the
  hyperplane `{∑ g = 0}`.
* `range_deltaCycL_eq_ker_holonomy` — the same statement as an equality of
  submodules, `range δ_cyc = ker(holonomy)`.
* `cyclicH1EquivReal`, `finrank_cyclicH1` — hence
  `H¹(loop nerve, ℝ) ≃ₗ[ℝ] ℝ` and `dim H¹ = 1`: the holonomy is a *complete*
  invariant of the cohomology class, so the loop nerve carries exactly one
  independent adversarial obstruction.
* `cyclic_defect_lower_bound` / `cyclic_defect_attained` /
  `cyclic_defect_isLeast` — the **quantitative defect theorem**: the best
  uniform approximation of `g` by a coboundary has error exactly
  `|∑ᵢ gᵢ| / (n+1)`.  Cohomology is thereby given a metric meaning: the size of
  the obstruction class is the unavoidable certificate mismatch.
* `holonomy_forces_certificate_gap` — consequently, a loop of `n+1` regions with
  holonomy `H` admits **no** global certificate assignment whose per-overlap
  mismatch is smaller than `|H| / (n+1)`: an explicit adversarial witness scale.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): "`H¹` of a loop is one-dimensional, and its class
  has a *metric* meaning: the norm of the class equals the smallest achievable
  uniform certificate mismatch, `|holonomy|/(number of regions)`."
* Experiment (Experimenter): the potential `f k = ∑_{j < k} g j` works verbatim
  for the cyclic nerve *provided* the loop sum vanishes; the wrap-around index
  `n ↦ 0` is the only case needing the hypothesis, and it is exactly where the
  holonomy is consumed (`deltaCyc_of_sum_zero`, second branch).
* Analysis (Analyst): the lower bound `|∑ g| ≤ (n+1) ε` is a pure averaging /
  triangle-inequality argument, and it is *tight* because the constant cochain
  `(∑ g)/(n+1)` realises it — the extremal cochain is the harmonic (constant)
  representative of the class.  This is the discrete Hodge-theoretic statement:
  each class has a unique constant representative of minimal sup-norm.
* Critique (Critic): the defect statement is stated as `IsLeast`, so it is not
  an unattained infimum; both bounds are proved, and the `n = 0` corner case
  (single region, self-loop) is covered since `(n : ℝ) + 1 > 0` always.
* Synthesis (PI): with `GraphNervePoincare.discrete_poincare_lemma` (qualitative,
  arbitrary nerve) plus this file (quantitative, loop nerve) the cohomological
  robustness ledger is complete for `1`-dimensional nerves.
-/

import Mathlib
import MachineLearning.SheafCohomologyRobustness.Cohomology

open BigOperators Finset

namespace SheafCohomologyRobustness

variable {n : ℕ}

/-! ## §1. An explicit primitive for zero-holonomy cyclic cochains -/

/-- Discrete primitive of `g` up to index `k`: `∑_{j < k} gⱼ`. -/
noncomputable def partialSum (g : Fin (n + 1) → ℝ) (k : ℕ) : ℝ :=
  ∑ j ∈ Finset.univ.filter (fun j : Fin (n + 1) => j.val < k), g j

lemma partialSum_succ (g : Fin (n + 1) → ℝ) (k : ℕ) (hk : k < n + 1) :
    partialSum g (k + 1) = partialSum g k + g ⟨k, hk⟩ := by
  unfold partialSum
  have hins : (Finset.univ.filter (fun j : Fin (n + 1) => j.val < k + 1))
      = insert (⟨k, hk⟩ : Fin (n + 1))
          (Finset.univ.filter (fun j : Fin (n + 1) => j.val < k)) := by
    ext j
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_insert]
    constructor
    · intro hj
      rcases Nat.lt_succ_iff_lt_or_eq.mp hj with h | h
      · exact Or.inr h
      · exact Or.inl (Fin.ext h)
    · rintro (rfl | h)
      · simp
      · omega
  have hnot : (⟨k, hk⟩ : Fin (n + 1))
      ∉ (Finset.univ.filter (fun j : Fin (n + 1) => j.val < k)) := by simp
  rw [hins, Finset.sum_insert hnot]
  ring

lemma partialSum_full (g : Fin (n + 1) → ℝ) : partialSum g (n + 1) = ∑ j, g j := by
  unfold partialSum
  congr 1
  ext j
  simpa using j.isLt

/-- **Zero holonomy implies gluing on the loop nerve.**  If the loop sum of the
overlap discrepancy `g` vanishes, the discrete primitive `k ↦ ∑_{j<k} gⱼ` is a
global potential for `g`, wrap-around included. -/
theorem deltaCyc_of_sum_zero (g : Fin (n + 1) → ℝ) (hg : ∑ i, g i = 0) :
    deltaCyc (fun k => partialSum g k.val) = g := by
  funext i
  simp only [deltaCyc]
  rcases lt_or_eq_of_le (Nat.lt_succ_iff.mp i.isLt) with hi | hi
  · have hsucc : (i + 1 : Fin (n + 1)).val = i.val + 1 := by
      rw [Fin.val_add_one_of_lt]
      exact Fin.lt_def.mpr (by simpa using hi)
    rw [hsucc, partialSum_succ g i.val i.isLt]
    simp
  · have hlast : (i + 1 : Fin (n + 1)) = 0 := by
      apply Fin.ext
      simp [Fin.val_add, ← hi]
    rw [hlast]
    have h0 : partialSum g (0 : Fin (n + 1)).val = 0 := by simp [partialSum]
    rw [h0, hi]
    have hkey := partialSum_succ g n (by omega)
    rw [partialSum_full, hg] at hkey
    have hin : (⟨n, by omega⟩ : Fin (n + 1)) = i := Fin.ext hi.symm
    rw [hin] at hkey
    linarith

/-- **The loop obstruction is exactly the holonomy.**  A cyclic overlap
discrepancy is a coboundary iff its total loop sum vanishes. -/
theorem isCoboundary_iff_holonomy_zero (g : Fin (n + 1) → ℝ) :
    (∃ f, deltaCyc f = g) ↔ ∑ i, g i = 0 := by
  constructor
  · rintro ⟨f, rfl⟩
    exact deltaCyc_sum_zero f
  · intro hg
    exact ⟨_, deltaCyc_of_sum_zero g hg⟩

/-! ## §2. `H¹` of the loop nerve is one-dimensional -/

/-- The cyclic coboundary operator as an `ℝ`-linear map. -/
def deltaCycL (n : ℕ) : (Fin (n + 1) → ℝ) →ₗ[ℝ] (Fin (n + 1) → ℝ) where
  toFun := deltaCyc
  map_add' f g := by
    funext i; simp only [deltaCyc, Pi.add_apply]; ring
  map_smul' a f := by
    funext i; simp only [deltaCyc, Pi.smul_apply, RingHom.id_apply, smul_eq_mul]; ring

/-- The holonomy (total loop sum) as an `ℝ`-linear functional on `1`-cochains. -/
def holonomyL (n : ℕ) : (Fin (n + 1) → ℝ) →ₗ[ℝ] ℝ where
  toFun g := ∑ i, g i
  map_add' f g := by simp [Finset.sum_add_distrib]
  map_smul' a f := by simp [Finset.mul_sum]

/-- **Cocycles modulo coboundaries.**  The image of the cyclic coboundary is
precisely the kernel of the holonomy functional. -/
theorem range_deltaCycL_eq_ker_holonomy (n : ℕ) :
    LinearMap.range (deltaCycL n) = LinearMap.ker (holonomyL n) := by
  ext g
  simp only [LinearMap.mem_range, LinearMap.mem_ker]
  exact isCoboundary_iff_holonomy_zero g

theorem holonomyL_surjective (n : ℕ) : Function.Surjective (holonomyL n) := by
  intro r
  refine ⟨fun _ => r / (n + 1), ?_⟩
  have hne : ((n : ℝ) + 1) ≠ 0 := by positivity
  show ∑ _i : Fin (n + 1), r / (n + 1) = r
  rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  push_cast
  field_simp

/-- **`H¹` of the loop nerve is canonically `ℝ`, via the holonomy.**  The first
cohomology of the cyclic nerve with real coefficients is one-dimensional, and the
isomorphism to `ℝ` is induced by the loop sum: two overlap discrepancies are
cohomologous iff they have the same holonomy. -/
noncomputable def cyclicH1EquivReal (n : ℕ) :
    ((Fin (n + 1) → ℝ) ⧸ LinearMap.range (deltaCycL n)) ≃ₗ[ℝ] ℝ :=
  (Submodule.quotEquivOfEq _ _ (range_deltaCycL_eq_ker_holonomy n)).trans
    ((holonomyL n).quotKerEquivOfSurjective (holonomyL_surjective n))

/-- The first cohomology of the loop nerve has dimension exactly `1`. -/
theorem finrank_cyclicH1 (n : ℕ) :
    Module.finrank ℝ ((Fin (n + 1) → ℝ) ⧸ LinearMap.range (deltaCycL n)) = 1 := by
  rw [(cyclicH1EquivReal n).finrank_eq]
  exact Module.finrank_self ℝ

/-- Two cyclic discrepancies are cohomologous exactly when they share a holonomy:
the holonomy is a complete invariant of the cohomology class. -/
theorem cohomologous_iff_same_holonomy (g h : Fin (n + 1) → ℝ) :
    (∃ f, deltaCyc f = g - h) ↔ ∑ i, g i = ∑ i, h i := by
  rw [isCoboundary_iff_holonomy_zero]
  constructor
  · intro hgh
    have : ∑ i, g i - ∑ i, h i = 0 := by
      rw [← Finset.sum_sub_distrib]; simpa using hgh
    linarith
  · intro hgh
    simp only [Pi.sub_apply, Finset.sum_sub_distrib, hgh, sub_self]

/-! ## §3. The quantitative defect theorem -/

/-- **Lower bound.**  No potential can approximate `g` uniformly better than
`|holonomy| / (n+1)`: if every overlap mismatch is at most `ε`, then
`|∑ᵢ gᵢ| ≤ (n+1) ε`. -/
theorem cyclic_defect_lower_bound (g f : Fin (n + 1) → ℝ) (ε : ℝ)
    (h : ∀ i, |deltaCyc f i - g i| ≤ ε) :
    |∑ i, g i| ≤ ((n : ℝ) + 1) * ε := by
  have hsum : ∑ i, (deltaCyc f i - g i) = - ∑ i, g i := by
    rw [Finset.sum_sub_distrib, deltaCyc_sum_zero f]
    ring
  have habs : |∑ i, (deltaCyc f i - g i)| ≤ ∑ _i : Fin (n + 1), ε :=
    (Finset.abs_sum_le_sum_abs _ _).trans (Finset.sum_le_sum fun i _ => h i)
  rw [hsum, abs_neg] at habs
  simpa [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] using habs

/-- **The bound is attained.**  Subtracting the mean makes the holonomy vanish,
so there is a potential whose mismatch with `g` is *exactly* the constant
`|∑ᵢ gᵢ| / (n+1)` at every overlap — the harmonic representative of the class. -/
theorem cyclic_defect_attained (g : Fin (n + 1) → ℝ) :
    ∃ f, ∀ i, |deltaCyc f i - g i| = |∑ j, g j| / ((n : ℝ) + 1) := by
  set H := ∑ j, g j with hH
  have hne : ((n : ℝ) + 1) ≠ 0 := by positivity
  set g' : Fin (n + 1) → ℝ := fun i => g i - H / ((n : ℝ) + 1) with hg'
  have hzero : ∑ i, g' i = 0 := by
    simp only [hg', Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ,
      Fintype.card_fin, nsmul_eq_mul]
    field_simp
    rw [hH]
    push_cast
    ring
  obtain ⟨f, hf⟩ : ∃ f, deltaCyc f = g' := ⟨_, deltaCyc_of_sum_zero g' hzero⟩
  refine ⟨f, fun i => ?_⟩
  rw [hf]
  have : g' i - g i = - (H / ((n : ℝ) + 1)) := by simp [hg']
  rw [this, abs_neg, abs_div]
  congr 1
  have : (0 : ℝ) ≤ (n : ℝ) + 1 := by positivity
  rw [abs_of_nonneg this]

/-- **Defect theorem.**  The least uniform certificate mismatch achievable by any
global potential on a loop of `n+1` regions equals `|holonomy| / (n+1)`.  The
cohomology class of `g` thus has an exact metric size. -/
theorem cyclic_defect_isLeast (g : Fin (n + 1) → ℝ) :
    IsLeast {ε : ℝ | ∃ f, ∀ i, |deltaCyc f i - g i| ≤ ε}
      (|∑ j, g j| / ((n : ℝ) + 1)) := by
  constructor
  · obtain ⟨f, hf⟩ := cyclic_defect_attained g
    exact ⟨f, fun i => le_of_eq (hf i)⟩
  · rintro ε ⟨f, hf⟩
    have hpos : (0 : ℝ) < (n : ℝ) + 1 := by positivity
    have := cyclic_defect_lower_bound g f ε hf
    rw [div_le_iff₀ hpos]
    linarith

/-- **Adversarial witness scale.**  A loop of `n+1` cover regions whose overlap
discrepancies have nonzero holonomy `H` admits no global certificate whatsoever
with per-overlap mismatch below `|H| / (n+1)`: the cohomological obstruction has
a concrete, quantitative robustness cost. -/
theorem holonomy_forces_certificate_gap (g : Fin (n + 1) → ℝ) (f : Fin (n + 1) → ℝ)
    (hH : ∑ i, g i ≠ 0) :
    ∃ i, |∑ j, g j| / ((n : ℝ) + 1) ≤ |deltaCyc f i - g i| := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨i₀⟩ : Nonempty (Fin (n + 1)) := ⟨0⟩
  classical
  set ε := Finset.univ.sup' ⟨i₀, Finset.mem_univ i₀⟩ (fun i => |deltaCyc f i - g i|) with hε
  have hle : ∀ i, |deltaCyc f i - g i| ≤ ε := fun i =>
    Finset.le_sup' (fun i => |deltaCyc f i - g i|) (Finset.mem_univ i)
  have hlb := (cyclic_defect_isLeast g).2 ⟨f, hle⟩
  obtain ⟨i, _, hi⟩ := Finset.exists_mem_eq_sup' ⟨i₀, Finset.mem_univ i₀⟩
    (fun i => |deltaCyc f i - g i|)
  have : ε < |∑ j, g j| / ((n : ℝ) + 1) := by rw [hε, hi]; exact hcon i
  have hpos : 0 < |∑ j, g j| := abs_pos.mpr hH
  linarith

end SheafCohomologyRobustness