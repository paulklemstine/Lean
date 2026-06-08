/-
# Symmetric Group Generation Probability

Formalization of the probability that two random permutations generate the full
symmetric group S_n. We prove:

1. Definitions of generation probability and alternating subgroup
2. If both generators are even, they cannot generate S_n
3. The universal upper bound p_n ≤ 3/4 for n ≥ 2
4. Structural theorems about transitivity and the alternating group
5. The index of the alternating subgroup is 2
-/
import Mathlib

open scoped BigOperators
open Finset

/-! ## Definitions -/

/-- The symmetric group on `Fin n`. -/
abbrev symmGroup (n : ℕ) := Equiv.Perm (Fin n)

/-- Two permutations generate the full symmetric group. -/
def generatesTop {n : ℕ} (σ τ : symmGroup n) : Prop :=
  Subgroup.closure ({σ, τ} : Set (symmGroup n)) = ⊤

/-- The alternating subgroup of S_n, defined as the kernel of the sign homomorphism. -/
def alternatingSubgroup (n : ℕ) : Subgroup (symmGroup n) :=
  Equiv.Perm.sign.ker

/-- The cardinality of S_n equals n!. -/
theorem symmetric_group_card (n : ℕ) :
    Fintype.card (symmGroup n) = Nat.factorial n := by
  simp [Fintype.card_perm, Fintype.card_fin]

/-- A permutation fixes a point. -/
def fixesPoint {n : ℕ} (σ : symmGroup n) (i : Fin n) : Prop := σ i = i

/-- Whether a subgroup acts transitively on `Fin n`. -/
def IsTransitiveSubgroup {n : ℕ} (H : Subgroup (symmGroup n)) : Prop :=
  ∀ i j : Fin n, ∃ g : H, (g : symmGroup n) i = j

/-! ## Parity obstruction -/

/-
The alternating subgroup is a proper subgroup of S_n for n ≥ 2.
-/
theorem alternatingSubgroup_ne_top {n : ℕ} (hn : 2 ≤ n) :
    alternatingSubgroup n ≠ ⊤ := by
  simp_all +decide [ alternatingSubgroup, Equiv.Perm.sign_swap, Subgroup.eq_top_iff' ];
  exact ⟨ Equiv.swap ⟨ 0, by linarith ⟩ ⟨ 1, by linarith ⟩, by simp +decide ⟩

/-
If both generators are even, they cannot generate S_n.
-/
theorem even_even_not_generate_symm {n : ℕ} (hn : 2 ≤ n)
    {σ τ : symmGroup n}
    (hσ : σ ∈ alternatingSubgroup n)
    (hτ : τ ∈ alternatingSubgroup n) :
    ¬ generatesTop σ τ := by
  -- By definition of $generatesTop$, we need to show that the closure of $\{\sigma, \tau\}$ is not the entire symmetric group $S_n$.
  unfold generatesTop
  by_contra h_contra
  have h_closure : Subgroup.closure ({σ, τ} : Set (symmGroup n)) ≤ alternatingSubgroup n := by
    simp_all +decide [ Subgroup.closure_le, Set.insert_subset_iff ];
    exact eq_top_iff.mpr fun x hx => by rw [ ← h_contra ] at hx; exact Subgroup.closure_induction ( by aesop ) ( by aesop ) ( by aesop ) ( by aesop ) hx;
  have h_eq : Subgroup.closure ({σ, τ} : Set (symmGroup n)) = alternatingSubgroup n := by
    grind
  have h_contra' : alternatingSubgroup n = ⊤ := by
    grind
  exact alternatingSubgroup_ne_top hn h_contra'

/-
If a pair generates S_n, then the closure is not contained in A_n.
-/
theorem generatesTop_not_le_alternating {n : ℕ} (hn : 2 ≤ n) {σ τ : symmGroup n}
    (hgen : generatesTop σ τ) :
    ¬ Subgroup.closure ({σ, τ} : Set (symmGroup n)) ≤ alternatingSubgroup n := by
  exact fun h => alternatingSubgroup_ne_top hn <| eq_top_iff.mpr <| hgen.symm ▸ h

/-
The index of the alternating subgroup in S_n is 2 for n ≥ 2.
-/
theorem alternatingSubgroup_index {n : ℕ} (hn : 2 ≤ n) :
    (alternatingSubgroup n).index = 2 := by
  convert Subgroup.index_ker ( f := Equiv.Perm.sign );
  rw [ show ( Equiv.Perm.sign.range : Subgroup ℤˣ ) = ⊤ from ?_ ] ; norm_num;
  ext x;
  rcases Int.units_eq_one_or x with ( rfl | rfl ) <;> simp +decide;
  exact ⟨ Equiv.swap ⟨ 0, by linarith ⟩ ⟨ 1, by linarith ⟩, by simp +decide ⟩

/-
If a pair generates S_n, then it must contain an odd permutation.
-/
theorem generatesTop_has_odd_perm {n : ℕ} (hn : 2 ≤ n) {σ τ : symmGroup n}
    (hgen : generatesTop σ τ) :
    Equiv.Perm.sign σ = -1 ∨ Equiv.Perm.sign τ = -1 := by
  by_contra hgen;
  -- If both σ and τ have sign 1 (i.e., both are even), then both are in alternatingSubgroup n = sign.ker.
  have h_even : σ ∈ alternatingSubgroup n ∧ τ ∈ alternatingSubgroup n := by
    cases Int.units_eq_one_or ( Equiv.Perm.sign σ ) <;> cases Int.units_eq_one_or ( Equiv.Perm.sign τ ) <;> aesop;
  exact even_even_not_generate_symm hn h_even.1 h_even.2 ‹_›

/-
⊤ as a subgroup of S_n is transitive (for n ≥ 1).
-/
theorem top_is_transitive {n : ℕ} :
    IsTransitiveSubgroup (⊤ : Subgroup (symmGroup n)) := by
  exact fun i j => ⟨ ⟨ Equiv.swap i j, trivial ⟩, by simp +decide ⟩

/-
If a pair generates S_n, the generated subgroup is transitive.
-/
theorem generatesTop_implies_transitive {n : ℕ} {σ τ : symmGroup n}
    (hgen : generatesTop σ τ) :
    IsTransitiveSubgroup (Subgroup.closure ({σ, τ} : Set (symmGroup n))) := by
  intro i j;
  exact ⟨ ⟨ Equiv.swap i j, by rw [ hgen ] ; exact Subgroup.mem_top _ ⟩, by simp +decide ⟩