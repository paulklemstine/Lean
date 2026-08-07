/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Schubert calculus I: complete flags, jump sequences and the cell decomposition

This file provides rigorous foundations for the combinatorial skeleton of the Grassmannian
that underlies Schubert's enumerative calculus.

Given a complete flag `0 = F₀ ⊂ F₁ ⊂ ⋯ ⊂ Fₙ = V` in an `n`-dimensional vector space and a
`k`-dimensional subspace `W ≤ V`, the *jump set*
`J(W) = {i < n | dim (W ⊓ Fᵢ₊₁) = dim (W ⊓ Fᵢ) + 1}` is the fundamental discrete invariant.

Main results:

* `SchubertCalculus.CompleteFlag.finrank_inf_step_le` : the dimension of `W ⊓ Fᵢ` grows by at
  most one at each step (a rank–nullity argument through the one dimensional quotient
  `Fᵢ₊₁ / Fᵢ`);
* `SchubertCalculus.CompleteFlag.finrank_inf_eq_card_jumpSet` : `dim (W ⊓ F_j)` equals the
  number of jumps below `j` — the exact "Schubert dimension datum" of `W`;
* `SchubertCalculus.CompleteFlag.card_jumpSet` : the jump set has exactly `k = dim W` elements,
  so that jump sets are indexed by `k`-element subsets of `{0, …, n-1}`;
* `SchubertCalculus.CompleteFlag.cell_pairwise_disjoint` /
  `SchubertCalculus.CompleteFlag.mem_cell_jumpSet` : the Schubert cells partition the
  Grassmannian.

Everything is stated for an arbitrary field and an arbitrary complete flag.
-/

namespace SchubertCalculus

open Module Submodule

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V]

/-- A complete flag of length `n`: an increasing chain of subspaces of dimensions
`0, 1, …, n` whose top member is the whole space. -/
structure CompleteFlag (K V : Type*) [Field K] [AddCommGroup V] [Module K V] (n : ℕ) where
  /-- The `i`-th member of the flag. -/
  part : ℕ → Submodule K V
  /-- The chain is increasing. -/
  mono : Monotone part
  /-- `part i` has dimension `i` for `i ≤ n`. -/
  finrank_part : ∀ i ≤ n, finrank K (part i) = i
  /-- The flag exhausts the space. -/
  part_top : part n = ⊤

namespace CompleteFlag

variable {n : ℕ} (Fl : CompleteFlag K V n)

lemma part_zero [FiniteDimensional K V] : Fl.part 0 = ⊥ := by
  have h := Fl.finrank_part 0 (Nat.zero_le _)
  exact Submodule.finrank_eq_zero.mp h

section

variable [FiniteDimensional K V] (W : Submodule K V)

/-- One step of the flag increases `dim (W ⊓ Fᵢ)` by at most one. -/
theorem finrank_inf_step_le {i : ℕ} (hi : i < n) :
    finrank K ((W ⊓ Fl.part (i + 1) : Submodule K V)) ≤
      finrank K ((W ⊓ Fl.part i : Submodule K V)) + 1 := by
  set A : Submodule K V := W ⊓ Fl.part (i + 1) with hA
  have hAi : A ⊓ Fl.part i = W ⊓ Fl.part i := by
    rw [hA, inf_assoc, inf_eq_right.2 (Fl.mono (Nat.le_succ i))]
  have hsup : A ⊔ Fl.part i ≤ Fl.part (i + 1) :=
    sup_le inf_le_right (Fl.mono (Nat.le_succ i))
  have key := Submodule.finrank_sup_add_finrank_inf_eq A (Fl.part i)
  have h1 : finrank K (Fl.part i) = i := Fl.finrank_part i hi.le
  have h2 : finrank K (Fl.part (i + 1)) = i + 1 := Fl.finrank_part (i + 1) hi
  have h3 : finrank K ((A ⊔ Fl.part i : Submodule K V)) ≤ i + 1 := by
    rw [← h2]; exact Submodule.finrank_mono hsup
  rw [hAi, h1] at key
  omega

/-- `dim (W ⊓ Fᵢ)` is monotone in `i`. -/
theorem finrank_inf_mono {i j : ℕ} (hij : i ≤ j) :
    finrank K ((W ⊓ Fl.part i : Submodule K V)) ≤ finrank K ((W ⊓ Fl.part j : Submodule K V)) :=
  Submodule.finrank_mono (inf_le_inf_left _ (Fl.mono hij))

/-- The *jump set* of `W` relative to the flag: the set of indices at which
`dim (W ⊓ F_•)` increases. -/
noncomputable def jumpSet (W : Submodule K V) : Finset ℕ :=
  (Finset.range n).filter fun i =>
    finrank K ((W ⊓ Fl.part (i + 1) : Submodule K V)) =
      finrank K ((W ⊓ Fl.part i : Submodule K V)) + 1

omit [FiniteDimensional K V] in
lemma mem_jumpSet {i : ℕ} :
    i ∈ Fl.jumpSet W ↔ i < n ∧
      finrank K ((W ⊓ Fl.part (i + 1) : Submodule K V)) =
        finrank K ((W ⊓ Fl.part i : Submodule K V)) + 1 := by
  simp [jumpSet]

omit [FiniteDimensional K V] in
lemma jumpSet_subset : Fl.jumpSet W ⊆ Finset.range n := Finset.filter_subset _ _

/-- Abstract counting lemma: a function increasing by steps of `0` or `1` from `0` is
recovered by counting its jumps. -/
private lemma card_filter_step (d : ℕ → ℕ) (N : ℕ) (h₀ : d 0 = 0)
    (hmono : ∀ i < N, d i ≤ d (i + 1)) (hstep : ∀ i < N, d (i + 1) ≤ d i + 1) :
    ∀ j ≤ N, (((Finset.range j).filter fun i => d (i + 1) = d i + 1)).card = d j := by
  intro j
  induction j with
  | zero => intro _; simp [h₀]
  | succ j ih =>
      intro hj
      have hjN : j < N := hj
      have hprev := ih (Nat.le_of_succ_le hj)
      rw [Finset.range_add_one, Finset.filter_insert]
      by_cases hc : d (j + 1) = d j + 1
      · rw [if_pos hc, Finset.card_insert_of_notMem (by simp), hprev, hc]
      · rw [if_neg hc, hprev]
        have := hmono j hjN
        have := hstep j hjN
        omega

/-- **Schubert dimension datum.** For every `j ≤ n`, the dimension of `W ⊓ F_j` equals the
number of jumps of `W` strictly below `j`. -/
theorem finrank_inf_eq_card_jumpSet {j : ℕ} (hj : j ≤ n) :
    finrank K ((W ⊓ Fl.part j : Submodule K V)) =
      ((Fl.jumpSet W).filter fun i => i < j).card := by
  have hzero : finrank K ((W ⊓ Fl.part 0 : Submodule K V)) = 0 := by
    rw [Fl.part_zero, inf_bot_eq]
    simp
  have key := card_filter_step
      (fun i => finrank K ((W ⊓ Fl.part i : Submodule K V))) n hzero
      (fun i _ => Fl.finrank_inf_mono W (Nat.le_succ i))
      (fun i hi => Fl.finrank_inf_step_le W hi) j hj
  have key2 : finrank K ((W ⊓ Fl.part j : Submodule K V)) =
      ((Finset.range j).filter fun i =>
        finrank K ((W ⊓ Fl.part (i + 1) : Submodule K V)) =
          finrank K ((W ⊓ Fl.part i : Submodule K V)) + 1).card := key.symm
  rw [key2]
  congr 1
  ext i
  simp only [Finset.mem_filter, Finset.mem_range, jumpSet]
  constructor
  · rintro ⟨hi, hstep⟩
    exact ⟨⟨hi.trans_le hj, hstep⟩, hi⟩
  · rintro ⟨⟨_, hstep⟩, hi⟩
    exact ⟨hi, hstep⟩

/-- The jump set has exactly `dim W` elements. -/
theorem card_jumpSet : (Fl.jumpSet W).card = finrank K W := by
  have h := Fl.finrank_inf_eq_card_jumpSet W (le_refl n)
  rw [Fl.part_top, inf_top_eq] at h
  rw [h]
  congr 1
  refine (Finset.filter_true_of_mem ?_).symm
  intro i hi
  exact Finset.mem_range.mp (Fl.jumpSet_subset W hi)

end

section Cells

variable [FiniteDimensional K V]

/-- The Schubert cell of the flag associated with a set `S` of jump positions: the set of
subspaces whose jump set is exactly `S`. -/
def cell (S : Finset ℕ) : Set (Submodule K V) := {W | Fl.jumpSet W = S}

omit [FiniteDimensional K V] in
lemma mem_cell_jumpSet (W : Submodule K V) : W ∈ Fl.cell (Fl.jumpSet W) := rfl

omit [FiniteDimensional K V] in
/-- The Schubert cells are pairwise disjoint: every subspace lies in exactly one cell. -/
theorem cell_pairwise_disjoint {S T : Finset ℕ} (hST : S ≠ T) :
    Disjoint (Fl.cell S) (Fl.cell T) := by
  rw [Set.disjoint_left]
  intro W hS hT
  exact hST (hS ▸ hT ▸ rfl)

/-- Cells are indexed by `k`-element subsets of `{0, …, n-1}`: a cell indexed by a set of the
wrong size, or not contained in `range n`, is empty. -/
theorem cell_eq_empty_of_card_ne {S : Finset ℕ} {k : ℕ}
    (h : S.card ≠ k) :
    Fl.cell S ∩ {W : Submodule K V | finrank K W = k} = ∅ := by
  ext W
  simp only [Set.mem_inter_iff, Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false]
  rintro ⟨hW, hk⟩
  exact h (by rw [← hW, Fl.card_jumpSet W, hk])

end Cells

end CompleteFlag

end SchubertCalculus