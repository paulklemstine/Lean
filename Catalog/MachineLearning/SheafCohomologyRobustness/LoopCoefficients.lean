/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# `H¹` of the Loop Nerve with Arbitrary Coefficients, and the `ℤ/2` Decision Obstruction

`CyclicHolonomy` computed the first cohomology of the loop nerve with **real**
coefficients.  The same computation holds with coefficients in an **arbitrary
abelian group** `M`, and this generality is not idle: the obstruction carried by
a decision boundary is not a real number but a *label*, i.e. a class with
coefficients in `ZMod 2`.

Main results.

* `deltaLoop_of_sum_zero`, `isCoboundary_iff_holonomy_zero_M` — for any abelian
  group `M`, a cyclic `M`-valued overlap discrepancy glues iff its holonomy
  `∑ᵢ gᵢ` vanishes in `M`.
* `range_deltaLoopHom_eq_ker_holonomyHom`, `loopH1EquivCoeff` — hence
  `H¹(loop nerve, M) ≃+ M` for every abelian group `M`: the loop nerve carries
  exactly one independent obstruction, with values in the coefficient group.
* `parity_obstruction` — specialised to `M = ZMod 2`: a loop of regions across
  which the predicted label flips an **odd** number of times admits no globally
  consistent labelling.  This is the `ℤ/2` Čech class of an adversarial loop,
  the algebraic shadow of the sign holonomy of `CertifiedRadiusGluing`.
* `flip_pattern_nontrivial` — an explicit odd flip pattern (a single flip around
  the loop) realises the nontrivial class, so the `ZMod 2` cohomology is not
  merely abstractly nonzero but has an exhibited generator.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): "the loop obstruction is coefficient-agnostic; the
  robustness-relevant instance is `ZMod 2`, where the class is the parity of
  label flips around a loop of overlapping activation regions."
* Experiment (Experimenter): the real-coefficient proof transports verbatim once
  `ring`/`linarith` are replaced by `abel`; the only genuinely arithmetic step,
  the wrap-around index `n ↦ 0`, is group-theoretic and needs no field
  structure.  Surjectivity of the holonomy uses the indicator cochain
  `i ↦ if i = 0 then m else 0`.
* Analysis (Analyst): passing from `ℝ` to `ZMod 2` changes the *meaning* of the
  invariant from a magnitude to a parity, and the parity version is the one that
  is invariant under reparametrising the score; this explains why the metric
  defect theorem of `CyclicHolonomy` and the sign obstruction of
  `CertifiedRadiusGluing` are two faces of one class.
* Critique (Critic): `parity_obstruction` is not vacuous: `flip_pattern_nontrivial`
  exhibits an explicit cochain with holonomy `1`, and the theorem's conclusion is
  a strict non-existence statement.
* Synthesis (PI): `H¹(loop, M) ≃+ M` unifies the whole cycle: real coefficients
  give quantitative certificate defects, `ZMod 2` coefficients give qualitative
  adversarial label obstructions.
-/

import Mathlib

open BigOperators Finset

namespace SheafCohomologyRobustness
namespace LoopCoefficients

variable {n : ℕ} {M : Type*} [AddCommGroup M]

/-! ## §1. The loop coboundary with coefficients in an abelian group -/

/-- Cyclic coboundary with coefficients in an abelian group `M`. -/
def deltaLoop (f : Fin (n + 1) → M) : Fin (n + 1) → M := fun i => f (i + 1) - f i

/-- Discrete primitive of `g` up to index `k`, with coefficients in `M`. -/
def partialSumM (g : Fin (n + 1) → M) (k : ℕ) : M :=
  ∑ j ∈ Finset.univ.filter (fun j : Fin (n + 1) => j.val < k), g j

/-- Holonomy of a coboundary vanishes, for any coefficient group. -/
theorem deltaLoop_sum_zero (f : Fin (n + 1) → M) : ∑ i, deltaLoop f i = 0 := by
  unfold deltaLoop
  rw [Finset.sum_sub_distrib]
  have : ∑ i : Fin (n + 1), f (i + 1) = ∑ i : Fin (n + 1), f i :=
    Equiv.sum_comp (Equiv.addRight (1 : Fin (n + 1))) f
  rw [this, sub_self]

lemma partialSumM_succ (g : Fin (n + 1) → M) (k : ℕ) (hk : k < n + 1) :
    partialSumM g (k + 1) = partialSumM g k + g ⟨k, hk⟩ := by
  unfold partialSumM
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
  abel

lemma partialSumM_full (g : Fin (n + 1) → M) : partialSumM g (n + 1) = ∑ j, g j := by
  unfold partialSumM
  congr 1
  ext j
  simpa using j.isLt

/-- **Zero holonomy implies gluing, over any abelian group.** -/
theorem deltaLoop_of_sum_zero (g : Fin (n + 1) → M) (hg : ∑ i, g i = 0) :
    deltaLoop (fun k => partialSumM g k.val) = g := by
  funext i
  simp only [deltaLoop]
  rcases lt_or_eq_of_le (Nat.lt_succ_iff.mp i.isLt) with hi | hi
  · have hsucc : (i + 1 : Fin (n + 1)).val = i.val + 1 := by
      rw [Fin.val_add_one_of_lt]
      exact Fin.lt_def.mpr (by simpa using hi)
    rw [hsucc, partialSumM_succ g i.val i.isLt]
    abel
  · have hlast : (i + 1 : Fin (n + 1)) = 0 := by
      apply Fin.ext
      simp [Fin.val_add, ← hi]
    rw [hlast]
    have h0 : partialSumM g (0 : Fin (n + 1)).val = 0 := by simp [partialSumM]
    rw [h0, hi]
    have hkey := partialSumM_succ g n (by omega)
    rw [partialSumM_full, hg] at hkey
    have hin : (⟨n, by omega⟩ : Fin (n + 1)) = i := Fin.ext hi.symm
    rw [hin] at hkey
    have hgi : g i = - partialSumM g n := by
      rw [eq_neg_iff_add_eq_zero, add_comm]
      exact hkey.symm
    rw [hgi]
    abel

/-- **The loop obstruction with arbitrary coefficients.** -/
theorem isCoboundary_iff_holonomy_zero_M (g : Fin (n + 1) → M) :
    (∃ f, deltaLoop f = g) ↔ ∑ i, g i = 0 := by
  constructor
  · rintro ⟨f, rfl⟩
    exact deltaLoop_sum_zero f
  · intro hg
    exact ⟨_, deltaLoop_of_sum_zero g hg⟩

/-! ## §2. `H¹(loop, M) ≃+ M` -/

/-- The loop coboundary as a group homomorphism. -/
def deltaLoopHom (n : ℕ) (M : Type*) [AddCommGroup M] :
    (Fin (n + 1) → M) →+ (Fin (n + 1) → M) where
  toFun := deltaLoop
  map_zero' := by funext i; simp [deltaLoop]
  map_add' f g := by funext i; simp only [deltaLoop, Pi.add_apply]; abel

/-- The holonomy as a group homomorphism. -/
def holonomyHom (n : ℕ) (M : Type*) [AddCommGroup M] : (Fin (n + 1) → M) →+ M where
  toFun g := ∑ i, g i
  map_zero' := by simp
  map_add' f g := by simp [Finset.sum_add_distrib]

theorem range_deltaLoopHom_eq_ker_holonomyHom (n : ℕ) (M : Type*) [AddCommGroup M] :
    (deltaLoopHom n M).range = (holonomyHom n M).ker := by
  ext g
  simp only [AddMonoidHom.mem_range, AddMonoidHom.mem_ker]
  exact isCoboundary_iff_holonomy_zero_M g

theorem holonomyHom_surjective (n : ℕ) (M : Type*) [AddCommGroup M] :
    Function.Surjective (holonomyHom n M) := by
  intro m
  refine ⟨fun i => if i = 0 then m else 0, ?_⟩
  show ∑ i : Fin (n + 1), (if i = 0 then m else 0) = m
  simp

/-- **`H¹` of the loop nerve is the coefficient group itself.**  For every
abelian group `M`, the first cohomology of the loop nerve with coefficients in
`M` is isomorphic to `M`, via the holonomy. -/
noncomputable def loopH1EquivCoeff (n : ℕ) (M : Type*) [AddCommGroup M] :
    ((Fin (n + 1) → M) ⧸ (deltaLoopHom n M).range) ≃+ M :=
  (QuotientAddGroup.quotientAddEquivOfEq
      (range_deltaLoopHom_eq_ker_holonomyHom n M)).trans
    (QuotientAddGroup.quotientKerEquivOfSurjective _ (holonomyHom_surjective n M))

/-! ## §3. The `ZMod 2` parity obstruction on decision boundaries -/

/-- **Parity obstruction.**  Interpret `g i = 1 : ZMod 2` as "the predicted label
flips across the overlap `Uᵢ ∩ Uᵢ₊₁`".  If the number of flips around the loop is
odd, no consistent global labelling of the regions exists. -/
theorem parity_obstruction (g : Fin (n + 1) → ZMod 2) (hodd : ∑ i, g i = 1) :
    ¬ ∃ f, deltaLoop f = g := by
  rw [isCoboundary_iff_holonomy_zero_M, hodd]
  decide

/-- An explicit generator of the `ZMod 2` obstruction: a single label flip around
the loop is a nontrivial cohomology class. -/
theorem flip_pattern_nontrivial (n : ℕ) :
    ¬ ∃ f, deltaLoop f = (fun i : Fin (n + 1) => if i = 0 then (1 : ZMod 2) else 0) := by
  refine parity_obstruction _ ?_
  show ∑ i : Fin (n + 1), (if i = 0 then (1 : ZMod 2) else 0) = 1
  simp

/-- The `ZMod 2` cohomology of the loop nerve is exactly `ZMod 2`: there is one
binary adversarial obstruction, the flip parity. -/
noncomputable def loopH1Zmod2 (n : ℕ) :
    ((Fin (n + 1) → ZMod 2) ⧸ (deltaLoopHom n (ZMod 2)).range) ≃+ ZMod 2 :=
  loopH1EquivCoeff n (ZMod 2)

/-- The parity class is a complete invariant: two flip patterns are cohomologous
iff they have the same parity of flips. -/
theorem cohomologous_iff_same_parity (g h : Fin (n + 1) → ZMod 2) :
    (∃ f, deltaLoop f = g - h) ↔ ∑ i, g i = ∑ i, h i := by
  rw [isCoboundary_iff_holonomy_zero_M]
  constructor
  · intro hgh
    have : ∑ i, g i - ∑ i, h i = 0 := by
      rw [← Finset.sum_sub_distrib]; simpa using hgh
    exact sub_eq_zero.mp this
  · intro hgh
    simp only [Pi.sub_apply, Finset.sum_sub_distrib, hgh, sub_self]

end LoopCoefficients
end SheafCohomologyRobustness