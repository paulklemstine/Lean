import Mathlib
import Computation.HammingBallDiscrepancy

/-!
# Coset Structure of the Hamming-Ball Discrepancy for Linear Codes

This file isolates the feature that distinguishes *linear* codes from arbitrary subsets in
the discrepancy conjecture: the counting function `z ↦ |C ∩ B_r(z)|` is **constant on the
cosets of `C`**.  Consequently it takes at most `|G| / |C|` distinct values, so verifying
the conjecture "for every centre `z`" reduces to verifying it on a transversal of cosets.

We model a linear code by a `Finset` `C` that contains `0` and is closed under subtraction
(an additive subgroup), which is exactly what is needed for the translation bijection.

* `inter_ball_coset_invariant` — `|C ∩ B_r(z + c₀)| = |C ∩ B_r(z)|` for every `c₀ ∈ C`.
* `inter_ball_eq_of_sub_mem` — the count agrees at `z` and `z'` whenever `z' - z ∈ C`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): For a linear code the discrepancy at a centre depends only on
the coset `z + C`, dramatically shrinking the family of independent tests from `q^n` to
`q^n / |C|`.

Experiment (Experimenter): Translation by an element `c₀ ∈ C` gives a bijection of
`C ∩ B_r(z + c₀)` with `C ∩ B_r(z)` via `x ↦ x - c₀`, since `C` is closed under
subtraction and Hamming distance is translation invariant (`hammingDist_add_right` from
`HammingBallDiscrepancy`).  Formalized with `Finset.card_bij'`.

Analysis (Analyst): The proof uses *only* the additive-subgroup axioms (`0 ∈ C` and
closure under subtraction); no field structure is needed, so the statement holds for any
abelian group code.  This is the precise sense in which "linear" buys structure over a
generic set: the discrepancy is a class function on `G / C`.

Critique (Critic): The closure hypotheses are load-bearing — drop `hsub` and the
forward map leaves `C`.  The result is not vacuous: it is an exact cardinality identity,
proved by an explicit two-sided bijection rather than `decide`.
-/

namespace HammingBallDiscrepancy

open Finset

variable {ι : Type*} {α : Type*} [Fintype ι] [DecidableEq ι] [DecidableEq α] [Fintype α]
variable [AddCommGroup α]

/-- **Coset invariance of the discrepancy.** If `C` contains `0` and is closed under
subtraction (a linear code / additive subgroup), then for any code element `c₀ ∈ C` the
ball-intersection count at `z + c₀` equals the count at `z`. -/
theorem inter_ball_coset_invariant (C : Finset (ι → α))
    (hzero : (0 : ι → α) ∈ C) (hsub : ∀ x ∈ C, ∀ c ∈ C, x - c ∈ C)
    (r : ℕ) (z c0 : ι → α) (hc0 : c0 ∈ C) :
    (C ∩ ball r (z + c0)).card = (C ∩ ball r z).card := by
  -- `-c0 ∈ C`
  have hneg : -c0 ∈ C := by
    have := hsub 0 hzero c0 hc0
    simpa using this
  apply Finset.card_bij' (fun x _ => x - c0) (fun y _ => y + c0)
  · -- forward maps into target
    intro x hx
    rw [Finset.mem_inter] at hx ⊢
    obtain ⟨hxC, hxB⟩ := hx
    refine ⟨hsub x hxC c0 hc0, ?_⟩
    rw [mem_ball] at hxB ⊢
    have h := hammingDist_add_right (x - c0) z c0
    rw [sub_add_cancel] at h
    rw [← h]; exact hxB
  · -- backward maps into target
    intro y hy
    rw [Finset.mem_inter] at hy ⊢
    obtain ⟨hyC, hyB⟩ := hy
    have hyc : y + c0 ∈ C := by
      have := hsub y hyC (-c0) hneg
      simpa [sub_neg_eq_add] using this
    refine ⟨hyc, ?_⟩
    rw [mem_ball] at hyB ⊢
    have h := hammingDist_add_right y z c0
    rw [h]; exact hyB
  · -- left inverse
    intro x _
    simp
  · -- right inverse
    intro y _
    simp

/-- The discrepancy counts agree at two centres lying in the same coset of `C`. -/
theorem inter_ball_eq_of_sub_mem (C : Finset (ι → α))
    (hzero : (0 : ι → α) ∈ C) (hsub : ∀ x ∈ C, ∀ c ∈ C, x - c ∈ C)
    (r : ℕ) (z z' : ι → α) (hzz : z' - z ∈ C) :
    (C ∩ ball r z').card = (C ∩ ball r z).card := by
  have hz' : z' = z + (z' - z) := by abel
  rw [hz']
  exact inter_ball_coset_invariant C hzero hsub r z (z' - z) hzz

end HammingBallDiscrepancy