import Mathlib

/-!
# Strongly regular signed graphs of higher girth

Algebraic and combinatorial core results from Iqbal--Zaslavsky,
*On strongly regular signed graphs of higher girth* (2026).

A bipartite signed adjacency matrix is represented by its square off-diagonal
block. Its signed common-neighbour counts are the row Gram products below.
The final theorem formalizes the sign argument on a pentagon used in the
classification at girth five.
-/

namespace StronglyRegularSignedGraphs

open Finset

/-- Signed common-neighbour count of two vertices in the same color class. -/
def signedGram {n : ℕ} (B : Fin n → Fin n → ℤ) (i j : Fin n) : ℤ :=
  ∑ x, B i x * B j x

/-- The signed `0, ±1` matrices whose rows have Gram matrix `rI`.
This is the row formulation of a weighing matrix. -/
def IsWeighingMatrix {n : ℕ} (B : Fin n → Fin n → ℤ) (r : ℤ) : Prop :=
  (∀ i j, B i j = 0 ∨ B i j = 1 ∨ B i j = -1) ∧
  ∀ i j, signedGram B i j = if i = j then r else 0

/-- A square binary incidence matrix with constant row size and constant
intersection size. These are the incidence equations for a symmetric
`2`-design in the orientation used for bipartite signed graphs. -/
def HasSymmetricDesignEquations {n : ℕ} (S : Fin n → Fin n → ℤ)
    (k lam : ℤ) : Prop :=
  (∀ i x, S i x = 0 ∨ S i x = 1) ∧
  (∀ i, ∑ x, S i x = k) ∧
  ∀ i j, i ≠ j → ∑ x, S i x * S j x = lam

/-- Replace `0/1` incidence entries by the signs `+1` and `-1`. -/
def designSignMatrix {n : ℕ} (S : Fin n → Fin n → ℤ) : Fin n → Fin n → ℤ :=
  fun i x ↦ 1 - 2 * S i x

/-- The Gram equation for the signed adjacency matrix arising from a
symmetric design: diagonal entries are `n`, while every off-diagonal entry is
`n - 4(k-λ)`. -/
theorem design_sign_gram {n : ℕ} {S : Fin n → Fin n → ℤ} {k lam : ℤ}
    (hS : HasSymmetricDesignEquations S k lam) (i j : Fin n) :
    signedGram (designSignMatrix S) i j =
      if i = j then (n : ℤ) else (n : ℤ) - 4 * (k - lam) := by
  by_cases h : i = j <;> simp +decide [ *, signedGram, designSignMatrix ];
  · ring_nf;
    rw [ Finset.sum_congr rfl fun x hx => by rw [ show S j x ^ 2 = S j x by cases hS.1 j x <;> aesop ] ] ; norm_num;
  · have := hS.2.2 i j h; simp_all +decide [ mul_sub, sub_mul ] ; ring;
    simp_all +decide [ ← Finset.sum_mul _ _ _, hS.2.1 ] ; ring

/-- Multiplying rows by vertex-switching signs multiplies each signed Gram
entry by the product of the two switching signs. -/
theorem signedGram_switch_rows {n : ℕ} (B : Fin n → Fin n → ℤ)
    (s : Fin n → ℤ) (i j : Fin n) :
    signedGram (fun u x ↦ s u * B u x) i j =
      s i * s j * signedGram B i j := by
  unfold signedGram; simp +decide [ mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ;

/-- Consequently, the zero off-diagonal Gram condition of weighing matrices
is invariant under arbitrary sign switching of rows. -/
theorem weighing_switch_rows {n : ℕ} {B : Fin n → Fin n → ℤ} {r : ℤ}
    (hB : IsWeighingMatrix B r) (s : Fin n → ℤ)
    (hs : ∀ i, s i = 1 ∨ s i = -1) :
    IsWeighingMatrix (fun u x ↦ s u * B u x) r := by
  refine' ⟨ fun i j => _, _ ⟩;
  · cases hs i <;> cases hB.1 i j <;> aesop;
  · intro i j; rw [ signedGram_switch_rows ] ; simp +decide [ hB.2 ] ;
    cases hs i <;> cases hs j <;> aesop

/-- Rigidity behind the switching lemma: on an index set with a third point
away from every pair, a nonzero constant off-diagonal Gram entry can remain
constant after switching only when all switching signs are equal. -/
theorem nonzero_switching_rigidity {V : Type*} (third : ∀ i j : V, ∃ k, k ≠ i ∧ k ≠ j)
    (s : V → ℤ) (hs : ∀ i, s i = 1 ∨ s i = -1)
    {c c' : ℤ} (hc : c ≠ 0)
    (hconstant : ∀ i j, i ≠ j → c * s i * s j = c') :
    ∀ i j, s i = s j := by
  intro i j
  obtain ⟨k, hk₁, hk₂⟩ : ∃ k, k ≠ i ∧ k ≠ j := third i j;
  cases hs i <;> cases hs j <;> cases hs k <;> have := hconstant i k ( by tauto ) <;> have := hconstant j k ( by tauto ) <;> simp_all +decide;
  · exact hc ( by linarith );
  · bv_omega;
  · grobner;
  · grind

/-- Finite form of switching rigidity for either color class of a bipartite
signed graph of order at least three. -/
theorem nonzero_switching_rigidity_fin {n : ℕ} (hn : 3 ≤ n)
    (s : Fin n → ℤ) (hs : ∀ i, s i = 1 ∨ s i = -1)
    {c c' : ℤ} (hc : c ≠ 0)
    (hconstant : ∀ i j, i ≠ j → c * s i * s j = c') :
    ∀ i j, s i = s j := by
  convert nonzero_switching_rigidity ( fun i j => ?_ ) s hs hc hconstant using 1;
  exact Exists.imp ( by aesop ) ( Finset.exists_mem_ne ( show 1 < Finset.card ( Finset.univ.erase i ) from by rw [ Finset.card_erase_of_mem ( Finset.mem_univ i ), Finset.card_fin ] ; exact Nat.lt_pred_iff.mpr hn ) j )

/-- If all signed two-paths around a pentagon have one common sign, then the
five edge signs are equal. Moreover that common two-path sign is positive.
This is the algebraic heart of the paper's girth-five homogeneity lemma. -/
theorem pentagon_two_path_signs_force_homogeneous
    (e : Fin 5 → ℤ) (he : ∀ i, e i = 1 ∨ e i = -1) (alpha : ℤ)
    (hpath : ∀ i : Fin 5, e i * e (i + 1) = alpha) :
    alpha = 1 ∧ ∃ eps : ℤ, (eps = 1 ∨ eps = -1) ∧ ∀ i, e i = eps := by
  simp_all +decide [ Fin.forall_fin_succ ];
  grind +qlia

end StronglyRegularSignedGraphs