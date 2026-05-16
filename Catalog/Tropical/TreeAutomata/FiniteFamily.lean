/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Finite Family Closure for Tropical Tree Automata

This file proves that the pointwise infimum (min) over a finite nonempty family
of weighted tree automata evaluations is expressible as an infimum over the
disjoint union of state spaces.

## Main Results

- `eval_finset_inf'`: The infimum of a finite family of WTA evaluations equals
  the infimum over the sigma-type state space.

## Mathematical Significance

This is the true compositional theorem: automata form a verified algebra of tree
cost functions. Given a family of recognizers, the ensemble minimum is again
recognizable (semantically).
-/

import Tropical.TreeAutomata.Basic

namespace TropicalTreeAutomata

/-! ## Finite Family Semantic Closure -/

/-- Sigma-type of a finset and univ is nonempty when the finset is nonempty and all fibers are nonempty. -/
theorem sigma_univ_nonempty
    {ι : Type*} [DecidableEq ι]
    {Q : ι → Type*} [∀ i, DecidableEq (Q i)] [∀ i, Fintype (Q i)] [∀ i, Nonempty (Q i)]
    (I : Finset ι) (hI : I.Nonempty) :
    (I.sigma (fun i => (Finset.univ : Finset (Q i)))).Nonempty := by
  obtain ⟨i, hi⟩ := hI
  exact ⟨⟨i, Classical.arbitrary _⟩, Finset.mem_sigma.mpr ⟨hi, Finset.mem_univ _⟩⟩

/-
**Finite-family tropical closure (Core Theorem C).**

For a nonempty finite family of WTAs indexed by `I`:
  `inf_{i ∈ I} eval (A i) t = inf_{⟨i,q⟩ ∈ Σ_{i ∈ I} Q_i} (evalState (A i) t q + f_i q)`

This shows that the ensemble minimum of any finite collection of tropical-recognizable
tree cost functions is again expressible as a tropical evaluation over the combined
state space `Σ i, Q i`. This is the foundational theorem for compositional dynamic
programming and verified parser combination.
-/
theorem eval_finset_inf'
    {σ : Type*} {ar : σ → ℕ}
    {ι : Type*} [DecidableEq ι]
    {Q : ι → Type*} [∀ i, Fintype (Q i)] [∀ i, DecidableEq (Q i)] [∀ i, Nonempty (Q i)]
    (I : Finset ι) (hI : I.Nonempty)
    (A : ∀ i, WTA σ ar (Q i))
    (t : RankedTree σ ar) :
    I.inf' hI (fun i => (A i).eval t) =
    (I.sigma (fun i => Finset.univ)).inf'
      (sigma_univ_nonempty I hI)
      (fun ⟨i, q⟩ => (A i).evalState t q + (A i).f q) := by
  refine' le_antisymm _ _;
  · simp +decide [ Finset.inf'_le_iff ];
    exact fun b hb => ⟨ b.fst, hb, Finset.inf'_le _ ( Finset.mem_univ _ ) ⟩;
  · simp +decide [ WTA.eval ];
    exact fun i hi q => ⟨ i, hi, q, le_rfl ⟩

end TropicalTreeAutomata