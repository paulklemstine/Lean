import EML.KolmogorovComplexityBound

/-!
# Quantitative universal approximation for finite-description EML functions

This file builds on the catalog's constant-free EML syntax and Kolmogorov complexity.
It makes the quantitative statement precise: every function having a finite EML
description is approximated at every nonnegative tolerance, and its minimum
approximation depth is bounded by its Kolmogorov description length.  Consequently,
for `0 < ε ≤ 1` the depth is bounded by
`K(f) * ⌈1 / ε⌉`, an explicit `O(K(f)/ε)` estimate.

The domain is an arbitrary set `S`; in particular the theorem applies to compact
intervals.  Since the witness computes the target exactly, no topological assumptions
on `S` are needed.
-/

noncomputable section

open Set
open EMLKolmogorov

namespace EMLUniversalApproximation

/-- Uniform approximation on a set, with a non-strict error bound. -/
def UniformApproxOn (f : ℝ → ℝ) (t : ETerm) (S : Set ℝ) (ε : ℝ) : Prop :=
  ∀ x ∈ S, |f x - t.eval x| ≤ ε

/-- The least EML tree depth attaining tolerance `ε` on `S`.
It is `0` when no approximating term exists, following `Nat.sInf`'s convention. -/
def minimumDepth (f : ℝ → ℝ) (S : Set ℝ) (ε : ℝ) : ℕ :=
  sInf {d : ℕ | ∃ t : ETerm, t.depth = d ∧ UniformApproxOn f t S ε}

/-- Syntactic EML depth is strictly smaller than node-count description length. -/
theorem depth_lt_size (t : ETerm) : t.depth < t.size := by
  induction t with
  | var => decide
  | add a b ha hb => simp only [ETerm.depth, ETerm.size]; omega
  | mul a b ha hb => simp only [ETerm.depth, ETerm.size]; omega
  | expOf a ha => simp only [ETerm.depth, ETerm.size]; omega
  | logOf a ha => simp only [ETerm.depth, ETerm.size]; omega

/-- Any particular approximating term bounds the minimum approximation depth. -/
theorem minimumDepth_le_of_term {f : ℝ → ℝ} {S : Set ℝ} {ε : ℝ}
    (t : ETerm) (ht : UniformApproxOn f t S ε) :
    minimumDepth f S ε ≤ t.depth := by
  apply Nat.sInf_le
  exact ⟨t, rfl, ht⟩

/-- Exact EML descriptions are universal approximants at every nonnegative tolerance. -/
theorem universal_approximation_of_computable
    {f : ℝ → ℝ} (hf : IsEMLComputable f) (S : Set ℝ) {ε : ℝ} (hε : 0 ≤ ε) :
    ∃ t : ETerm, UniformApproxOn f t S ε ∧ t.depth ≤ K f := by
  obtain ⟨t, heval, hsize⟩ := K_mem f hf
  refine ⟨t, ?_, ?_⟩
  · intro x hx
    rw [← heval]
    simpa using hε
  · have hdepth := depth_lt_size t
    omega

/-- Minimum approximation depth is bounded directly by EML Kolmogorov complexity. -/
theorem minimumDepth_le_K
    {f : ℝ → ℝ} (hf : IsEMLComputable f) (S : Set ℝ) {ε : ℝ} (hε : 0 ≤ ε) :
    minimumDepth f S ε ≤ K f := by
  obtain ⟨t, ht, hdepth⟩ := universal_approximation_of_computable hf S hε
  exact (minimumDepth_le_of_term t ht).trans hdepth

/-- For `0 < ε ≤ 1`, reciprocal tolerance has ceiling at least one. -/
theorem one_le_ceil_inv {ε : ℝ} (hε : 0 < ε) (hε1 : ε ≤ 1) :
    1 ≤ ⌈(1 / ε : ℝ)⌉₊ := by
  have hinv : (1 : ℝ) ≤ 1 / ε := by
    rw [le_div_iff₀ hε]
    simpa using hε1
  have hc := Nat.le_ceil (1 / ε : ℝ)
  exact_mod_cast hinv.trans hc

/-- Explicit quantitative EML approximation bound.

For every finite-description EML function and every `0 < ε ≤ 1`, the minimum EML
approximation depth on any set is at most `K(f) * ⌈1/ε⌉`.  This is the requested
integer-valued `O(K(f)/ε)` complexity estimate, with multiplicative constant one
(up to the unavoidable ceiling). -/
theorem minimumDepth_le_K_mul_ceil_inv
    {f : ℝ → ℝ} (hf : IsEMLComputable f) (S : Set ℝ)
    {ε : ℝ} (hε : 0 < ε) (hε1 : ε ≤ 1) :
    minimumDepth f S ε ≤ K f * ⌈(1 / ε : ℝ)⌉₊ := by
  calc
    minimumDepth f S ε ≤ K f := minimumDepth_le_K hf S hε.le
    _ ≤ K f * ⌈(1 / ε : ℝ)⌉₊ := by
      simpa using Nat.mul_le_mul_left (K f) (one_le_ceil_inv hε hε1)

/-- A single theorem packaging universality and the quantitative depth bound. -/
theorem eml_universal_with_complexity_bound
    {f : ℝ → ℝ} (hf : IsEMLComputable f) (S : Set ℝ)
    {ε : ℝ} (hε : 0 < ε) (hε1 : ε ≤ 1) :
    (∃ t : ETerm, UniformApproxOn f t S ε ∧ t.depth ≤ K f) ∧
      minimumDepth f S ε ≤ K f * ⌈(1 / ε : ℝ)⌉₊ := by
  exact ⟨universal_approximation_of_computable hf S hε.le,
    minimumDepth_le_K_mul_ceil_inv hf S hε hε1⟩

end EMLUniversalApproximation