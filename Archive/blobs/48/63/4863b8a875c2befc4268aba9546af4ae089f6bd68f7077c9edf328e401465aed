/-
# Causal Integration Algebra — Composition, Symmetrization, and the Φ = 0 Characterization

This file extends `Shared.CausalIntegration.Core` with three new strands of theory:

* **Exact characterization of Φ = 0** (`phi_eq_zero_iff`): a causal system has
  vanishing integrated information *if and only if* it is disconnected (some
  nontrivial bipartition has zero cross-information). This is the converse of the
  catalog result `phi_zero_of_disconnected`, and it pins down the boundary of the
  "integrated" regime exactly. The key tool is that a finite minimum over the
  nonempty lattice of nontrivial bipartitions is *attained*.

* **Symmetrization** (`symmetrize`, `symmetrize_crossInfo`): the undirected
  weight `w i j + w j i` has a cut value that splits exactly into the two
  opposite directed cuts of the original system, `crossInfo S + crossInfo Sᶜ`.

* **Compositional Φ for direct sums** (`directSum`, `phi_directSum_eq_zero`):
  the block-diagonal direct sum of two causal systems (with zero cross-weights)
  is always disconnected and hence has Φ = 0 — the algebraic incarnation of
  IIT's exclusion postulate that independent subsystems carry no joint
  integration.

All proofs build on the catalog API: `crossInfo`, `phi`, `phi_le_crossInfo`,
`phi_zero_of_disconnected`, `nontrivialBipartitions`, and `IsDisconnected`.
-/

import Shared.CausalIntegration.Core

open Finset BigOperators

namespace CausalSystem

variable {n n₁ n₂ : ℕ}

/-! ## Exact characterization of Φ = 0 -/

/-
!-- The finite minimum defining `phi` is attained at some nontrivial bipartition `S`
(`Finset.exists_mem_eq_inf'`); if Φ = 0 then that `S` is a zero-weight cut, giving
disconnectedness. The reverse implication is the catalog's `phi_zero_of_disconnected`. -- !--

**Exact Φ = 0 characterization.** A causal system has zero integrated information
iff it is disconnected.
-/
theorem phi_eq_zero_iff (C : CausalSystem n) (hn : 2 ≤ n) :
    C.phi hn = 0 ↔ C.IsDisconnected := by
  constructor;
  · intro h;
    obtain ⟨ S, hS₁, hS₂ ⟩ := Finset.exists_mem_eq_inf' ( nontrivialBipartitions_nonempty hn ) ( C.crossInfo · );
    exact ⟨ S, Finset.mem_filter.mp hS₁ |>.2.1, Finset.mem_filter.mp hS₁ |>.2.2, hS₂.symm.trans h ⟩;
  · exact phi_zero_of_disconnected C hn

/-! ## Symmetrization -/

/-- Symmetrize a causal system: replace each directed weight by `w i j + w j i`. -/
noncomputable def symmetrize (C : CausalSystem n) : CausalSystem n where
  weight i j := C.weight i j + C.weight j i
  weight_nonneg i j := add_nonneg (C.weight_nonneg i j) (C.weight_nonneg j i)

/-
!-- Expand the symmetrized cut as a double sum of `w i j + w j i`, split the sum, and
swap the order of summation in the second piece to recognize it as the opposite
directed cut `crossInfo (univ \ S)`. -- !--

The symmetrized cut value decomposes into the two opposite directed cuts.
-/
theorem symmetrize_crossInfo (C : CausalSystem n) (S : Finset (Fin n)) :
    (symmetrize C).crossInfo S = C.crossInfo S + C.crossInfo (Finset.univ \ S) := by
  unfold CausalSystem.crossInfo;
  simp +decide [ CausalSystem.symmetrize, Finset.sum_add_distrib ];
  exact congrArg₂ _ ( Finset.sum_comm ) ( Finset.sum_comm )

/-! ## Direct sums -/

/-- Block-diagonal direct sum of two causal systems on `Fin (n₁ + n₂)`: the original
weights on each block and zero cross-weights between blocks. -/
noncomputable def directSum (C₁ : CausalSystem n₁) (C₂ : CausalSystem n₂) :
    CausalSystem (n₁ + n₂) where
  weight i j :=
    Fin.addCases
      (fun a => Fin.addCases (fun b => C₁.weight a b) (fun _ => 0) j)
      (fun a => Fin.addCases (fun _ => 0) (fun b => C₂.weight a b) j) i
  weight_nonneg i j := by
    refine Fin.addCases ?_ ?_ i <;> intro a <;>
      refine Fin.addCases ?_ ?_ j <;> intro b <;>
      simp [Fin.addCases_left, Fin.addCases_right, C₁.weight_nonneg, C₂.weight_nonneg]

-- !-- Both indices land in opposite blocks, so `Fin.addCases` reduces through a left then
--    a right branch to the literal `0`. -- !--
/-- Cross-block weights of a direct sum vanish. -/
theorem directSum_weight_cross_eq_zero (C₁ : CausalSystem n₁) (C₂ : CausalSystem n₂)
    (a : Fin n₁) (b : Fin n₂) :
    (C₁.directSum C₂).weight (Fin.castAdd n₂ a) (Fin.natAdd n₁ b) = 0 := by
  simp [directSum, Fin.addCases_left, Fin.addCases_right]

/-
!-- The natural cut is the first block `castAddEmb '' univ`; its complement is the
second block, where every node has the form `natAdd b`, so each cross weight is
zero by `directSum_weight_cross_eq_zero` and the whole double sum vanishes. -- !--

The natural first-block cut of a direct sum carries zero cross-information.
-/
theorem crossInfo_natural_cut_eq_zero (C₁ : CausalSystem n₁) (C₂ : CausalSystem n₂) :
    (C₁.directSum C₂).crossInfo (Finset.univ.map (Fin.castAddEmb n₂)) = 0 := by
  refine' Finset.sum_eq_zero fun i hi => Finset.sum_eq_zero fun j hj => _;
  simp_all +decide;
  cases' hi with a ha;
  cases' j with b hb;
  cases lt_or_ge b n₁ <;> simp_all +decide [ Fin.ext_iff ];
  · exact False.elim <| hj ⟨ b, by linarith ⟩ rfl;
  · convert directSum_weight_cross_eq_zero C₁ C₂ a ⟨ b - n₁, by omega ⟩;
    · exact Fin.ext ha.symm;
    · simp +decide [ Fin.natAdd, Nat.add_sub_of_le ‹_› ]

/-
!-- The first block is nonempty (`n₁ ≥ 1`) and proper (`n₂ ≥ 1`), and has zero cross-info
by `crossInfo_natural_cut_eq_zero`, hence the system is disconnected. -- !--

A direct sum of two nonempty systems is disconnected.
-/
theorem directSum_isDisconnected (C₁ : CausalSystem n₁) (C₂ : CausalSystem n₂)
    (h₁ : 1 ≤ n₁) (h₂ : 1 ≤ n₂) :
    (C₁.directSum C₂).IsDisconnected := by
  refine' ⟨ Finset.univ.map ( Fin.castAddEmb n₂ ), _, _, _ ⟩;
  · exact ⟨ _, Finset.mem_map_of_mem _ ( Finset.mem_univ ⟨ 0, h₁ ⟩ ) ⟩;
  · simp +decide [ Finset.ext_iff ];
    exact ⟨ ⟨ n₁, by linarith ⟩, fun i => ne_of_lt ( Fin.castSucc_lt_last i ) ⟩;
  · convert crossInfo_natural_cut_eq_zero C₁ C₂

-- !-- Direct corollary: disconnected systems have Φ = 0 (`phi_zero_of_disconnected`). -- !--
/-- **Compositional Φ.** The direct sum of two nonempty causal systems has Φ = 0. -/
theorem phi_directSum_eq_zero (C₁ : CausalSystem n₁) (C₂ : CausalSystem n₂)
    (h₁ : 1 ≤ n₁) (h₂ : 1 ≤ n₂) (hn : 2 ≤ n₁ + n₂) :
    (C₁.directSum C₂).phi hn = 0 :=
  phi_zero_of_disconnected _ hn (directSum_isDisconnected C₁ C₂ h₁ h₂)

/-! ## Demonstration -/

-- !-- A worked instance: the direct sum of two single-node systems is a two-node system
--    whose integrated information vanishes, since the two nodes are causally independent. -- !--
/-- The direct sum of any two single-node causal systems has Φ = 0. -/
example (C₁ C₂ : CausalSystem 1) : (C₁.directSum C₂).phi (by norm_num) = 0 :=
  phi_directSum_eq_zero C₁ C₂ le_rfl le_rfl (by norm_num)

/-- Φ = 0 is *equivalent* to disconnectedness, so any system that fails to be
disconnected has strictly positive integrated information. -/
example (C : CausalSystem n) (hn : 2 ≤ n) (h : ¬ C.IsDisconnected) : 0 < C.phi hn :=
  lt_of_le_of_ne (phi_nonneg C hn) (fun heq => h ((phi_eq_zero_iff C hn).1 heq.symm))

end CausalSystem