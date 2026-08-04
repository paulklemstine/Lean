/-
# A character-theoretic bridge for Cayley graph walk statistics

Finite abelian groups carry two very different kinds of "observables":

* **harmonic ones** — sums of additive characters `ψ : AddChar G ℂ` over a subset `S`;
* **graph-theoretic ones** — counts of closed walks in the Cayley graph `Cay(G,S)`.

This file proves that the two coincide, and that both are governed by a purely
enumerative group-theoretic quantity: the number of length-`k` *relations*
`s₁ + ⋯ + s_k = 0` with all `sᵢ ∈ S`.

The main results are

* `adjMatrix_mulVec_char` — each character is an eigenvector of the Cayley
  adjacency matrix, with eigenvalue the character sum `∑ s ∈ S, ψ s`;
* `trace_pow_eq_charEigen_sum` — the trace of the `k`-th power of the adjacency
  matrix is the `k`-th power sum of the character eigenvalues (proved by
  diagonalisation in the Pontryagin dual basis of `G → ℂ`);
* `charEigen_pow_sum_eq_card_mul_relationCount` — that power sum equals
  `|G| ⬝ #{(s₁,…,s_k) ∈ Sᵏ : ∑ sᵢ = 0}`;
* `closedWalk_count_eq_card_mul_relationCount` — hence the total number of
  closed `k`-walks in the Cayley graph equals `|G|` times the number of
  length-`k` relations in `S`.

This is an exact mechanism behind the cycle-count regularities recorded in the
Cayley graph census of *Learning the Graphical Nature of Symmetries*: cycle-type
statistics of a Cayley graph are not extra data, they are the additive
combinatorics of the connection set, read through Fourier analysis on the group.
-/

import Mathlib.Tactic
import Mathlib.Analysis.Fourier.FiniteAbelian.PontryaginDuality
import Mathlib.Analysis.Fourier.FiniteAbelian.Orthogonality
import Mathlib.Combinatorics.SimpleGraph.AdjMatrix
import Mathlib.LinearAlgebra.Matrix.ToLin
import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.LinearAlgebra.Trace

open Finset
open scoped Matrix

namespace CayleyCharacterSpectra

noncomputable section

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## The Cayley graph -/

/-- The Cayley graph of the finite abelian group `G` with respect to a symmetric
connection set `S` that does not contain `0`. -/
def cayleyGraph (S : Finset G) (hsymm : ∀ s ∈ S, -s ∈ S) (h0 : (0 : G) ∉ S) :
    SimpleGraph G where
  Adj x y := y - x ∈ S
  symm := by
    intro x y h
    have := hsymm _ h
    simpa [neg_sub] using this
  loopless := ⟨fun x h => h0 (by simpa using h)⟩

instance instDecidableAdj (S : Finset G) (hsymm : ∀ s ∈ S, -s ∈ S) (h0 : (0 : G) ∉ S) :
    DecidableRel (cayleyGraph S hsymm h0).Adj :=
  fun x y => decidable_of_iff (y - x ∈ S) Iff.rfl

omit [Fintype G] [DecidableEq G] in
@[simp] lemma cayleyGraph_adj (S : Finset G) (hsymm : ∀ s ∈ S, -s ∈ S) (h0 : (0 : G) ∉ S)
    (x y : G) : (cayleyGraph S hsymm h0).Adj x y ↔ y - x ∈ S := Iff.rfl

omit [Fintype G] in
lemma cayleyAdjMatrix_apply (S : Finset G) (hsymm : ∀ s ∈ S, -s ∈ S) (h0 : (0 : G) ∉ S)
    (x y : G) :
    (cayleyGraph S hsymm h0).adjMatrix ℂ x y = if y - x ∈ S then 1 else 0 := by
  simp [SimpleGraph.adjMatrix]

/-! ## Character eigenvalues -/

/-- The character sum attached to a connection set: the eigenvalue of the Cayley
adjacency matrix on the eigenvector `ψ`. -/
def charEigen (S : Finset G) (psi : AddChar G ℂ) : ℂ := ∑ s ∈ S, psi s

omit [Fintype G] [DecidableEq G] in
/-- The trivial character has eigenvalue the degree `|S|` of the Cayley graph. -/
lemma charEigen_zero (S : Finset G) : charEigen S (0 : AddChar G ℂ) = S.card := by
  simp [charEigen]

/-- **Characters are eigenvectors of the Cayley adjacency matrix.**  This is the
first half of the bridge: a purely harmonic object (the character sum over `S`)
is an eigenvalue of a purely combinatorial object (the adjacency operator). -/
theorem adjMatrix_mulVec_char (S : Finset G) (hsymm : ∀ s ∈ S, -s ∈ S) (h0 : (0 : G) ∉ S)
    (psi : AddChar G ℂ) :
    (cayleyGraph S hsymm h0).adjMatrix ℂ *ᵥ (fun x => psi x) =
      charEigen S psi • (fun x => psi x) := by
  ext x
  simp [charEigen, Matrix.mulVec, dotProduct]
  have h : (∑ y, if y - x ∈ S then psi y else 0) = ∑ s ∈ S, psi (x + s) := by
    rw [← Finset.sum_filter]
    have heq : Finset.filter (fun a => a - x ∈ S) Finset.univ = Finset.image (fun s => x + s) S := by
      ext a
      simp [sub_eq_add_neg, add_comm]
    rw [heq, Finset.sum_image]
    intro a _ b _ hab
    exact add_left_cancel hab
  rw [h, Finset.sum_mul]
  refine Finset.sum_congr rfl fun s _ => ?_
  simp [mul_comm]
  rw [add_comm]
  show (psi (s + x) : ℂ) = (psi x : ℂ) * (psi s : ℂ)
  rw [add_comm s x]
  exact AddChar.map_add_eq_mul psi x s

/-- Iterating the eigenvector relation. -/
theorem adjMatrix_pow_mulVec_char (S : Finset G) (hsymm : ∀ s ∈ S, -s ∈ S) (h0 : (0 : G) ∉ S)
    (psi : AddChar G ℂ) (k : ℕ) :
    ((cayleyGraph S hsymm h0).adjMatrix ℂ) ^ k *ᵥ (fun x => psi x) =
      (charEigen S psi) ^ k • (fun x => psi x) := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [pow_succ, ← Matrix.mulVec_mulVec, adjMatrix_mulVec_char, Matrix.mulVec_smul, ih, smul_smul, pow_succ']

/-! ## Diagonalisation in the Pontryagin dual basis -/

/-- The endomorphism attached to an eigen-matrix acts diagonally on the character
basis of `G → ℂ`. -/
lemma toLin'_complexBasis (A : Matrix G G ℂ) (lam : AddChar G ℂ → ℂ)
    (h : ∀ psi : AddChar G ℂ, A *ᵥ (fun x => psi x) = lam psi • (fun x => psi x))
    (psi : AddChar G ℂ) :
    Matrix.toLin' A (AddChar.complexBasis G psi) = lam psi • (AddChar.complexBasis G psi) := by
  ext x
  simp only [Matrix.toLin'_apply, Pi.smul_apply, smul_eq_mul]
  rw [AddChar.complexBasis_apply]
  exact congr_fun (h psi) x

/-- Diagonal entries of the matrix of the adjacency endomorphism in the character
basis are exactly the character eigenvalues. -/
lemma toMatrix_complexBasis_diag (A : Matrix G G ℂ) (lam : AddChar G ℂ → ℂ)
    (h : ∀ psi : AddChar G ℂ, A *ᵥ (fun x => psi x) = lam psi • (fun x => psi x))
    (psi : AddChar G ℂ) :
    LinearMap.toMatrix (AddChar.complexBasis G) (AddChar.complexBasis G) (Matrix.toLin' A)
      psi psi = lam psi := by
  rw [LinearMap.toMatrix_apply, toLin'_complexBasis A lam h,
    (AddChar.complexBasis G).repr.map_smul]
  show lam psi * ((AddChar.complexBasis G).repr ((AddChar.complexBasis G) psi)) psi = lam psi
  rw [(AddChar.complexBasis G).repr_self_apply psi psi]
  simp

omit [AddCommGroup G] in
/-- The matrix trace is the trace of the associated endomorphism. -/
lemma matrix_trace_eq_linearMap_trace (A : Matrix G G ℂ) :
    A.trace = LinearMap.trace ℂ (G → ℂ) (Matrix.toLin' A) := by
  rw [LinearMap.trace_eq_matrix_trace (R := ℂ) (M := G → ℂ) (ι := G) (Pi.basisFun ℂ G)]
  congr 1
  ext i j
  simp [Matrix.toLin'_apply]

/-- If every additive character is an eigenvector of a matrix `A`, then the trace of
`A` is the sum of the corresponding eigenvalues.  This is the linear-algebraic
heart of the bridge: the Pontryagin dual is a basis of `G → ℂ`. -/
theorem trace_eq_sum_of_char_eigen (A : Matrix G G ℂ) (lam : AddChar G ℂ → ℂ)
    (h : ∀ psi : AddChar G ℂ, A *ᵥ (fun x => psi x) = lam psi • (fun x => psi x)) :
    A.trace = ∑ psi : AddChar G ℂ, lam psi := by
  rw [matrix_trace_eq_linearMap_trace,
    LinearMap.trace_eq_matrix_trace (b := AddChar.complexBasis G)]
  simp [Matrix.trace, toMatrix_complexBasis_diag A lam h]

/-- **Spectral trace formula for Cayley graphs.** -/
theorem trace_pow_eq_charEigen_sum (S : Finset G) (hsymm : ∀ s ∈ S, -s ∈ S) (h0 : (0 : G) ∉ S)
    (k : ℕ) :
    Matrix.trace (((cayleyGraph S hsymm h0).adjMatrix ℂ) ^ k) =
      ∑ psi : AddChar G ℂ, (charEigen S psi) ^ k :=
  trace_eq_sum_of_char_eigen _ _ (fun psi => adjMatrix_pow_mulVec_char S hsymm h0 psi k)

/-! ## The enumerative side -/

/-- The number of length-`k` relations in `S`: tuples `(s₁,…,s_k) ∈ Sᵏ` with
`s₁ + ⋯ + s_k = 0`. -/
def relationCount (S : Finset G) (k : ℕ) : ℕ :=
  ((Fintype.piFinset fun _ : Fin k => S).filter (fun p => ∑ i, p i = 0)).card

omit [Fintype G] [DecidableEq G] in
/-- Expanding the `k`-th power of a character sum over `k`-tuples from `S`. -/
lemma charEigen_pow_eq_sum_tuples (S : Finset G) (psi : AddChar G ℂ) (k : ℕ) :
    (charEigen S psi) ^ k =
      ∑ p ∈ Fintype.piFinset fun _ : Fin k => S, psi (∑ i, p i) := by
  simp [charEigen]
  induction k with
  | zero => simp
  | succ n ih =>
    rw [pow_succ, ih, mul_comm, Finset.sum_mul]
    have hpsi : ∀ i p, psi i * psi (∑ j, p j) = psi (∑ j : Fin (n + 1), Fin.cons i p j) := by
      intro i p
      rw [Fin.sum_univ_succ, AddChar.map_add_eq_mul]
      simp [Fin.cons_zero]
    simp_rw [Finset.mul_sum]
    simp_rw [hpsi]
    rw [Finset.sum_comm, Finset.sum_sigma']
    -- the bijection `(p, y) ↦ Fin.cons y p` between `S^n × S` and `S^(n+1)`
    refine Finset.sum_bij (fun ⟨_p, y⟩ _ => Fin.cons y _p) ?_ ?_ ?_ ?_
    · simp [Fintype.mem_piFinset]
      intro a ha1 ha2 i
      exact Fin.cases ha2 (fun j => ha1 j) i
    · simp only
      intro a₁ ha₁ a₂ ha₂ h
      ext <;> cases a₁ <;> cases a₂ <;> simp_all
    · simp only
      intro b hb
      simp only [Finset.mem_sigma] at hb ⊢
      simp only [Fintype.mem_piFinset] at hb ⊢
      refine ⟨⟨fun i => b (Fin.succ i), b 0⟩, ⟨⟨fun i => hb (Fin.succ i), hb 0⟩, ?_⟩⟩
      ext i
      exact Fin.cases rfl (fun _ => rfl) i
    · simp

/-- **Character power sums count relations.**  Orthogonality of the Pontryagin dual
turns the `k`-th power sum of the Cayley eigenvalues into an enumeration of
additive relations of length `k` inside the connection set. -/
theorem charEigen_pow_sum_eq_card_mul_relationCount (S : Finset G) (k : ℕ) :
    ∑ psi : AddChar G ℂ, (charEigen S psi) ^ k =
      (Fintype.card G : ℂ) * relationCount S k := by
  simp_rw [charEigen_pow_eq_sum_tuples S]
  rw [Finset.sum_comm]
  have hortho : ∀ x : G, ∑ psi : AddChar G ℂ, psi x = if x = 0 then (Fintype.card G : ℂ) else 0 := by
    intro x
    exact AddChar.sum_apply_eq_ite x
  simp_rw [hortho]
  rw [Finset.sum_ite, Finset.sum_const_zero, add_zero]
  simp [relationCount, Finset.sum_const, nsmul_eq_mul, mul_comm]

/-! ## The bridge -/

/-- **Main theorem.**  The `k`-th power sum of the character eigenvalues of a Cayley
graph equals the total number of closed walks of length `k` in that graph. -/
theorem charEigen_pow_sum_eq_closedWalk_count (S : Finset G) (hsymm : ∀ s ∈ S, -s ∈ S)
    (h0 : (0 : G) ∉ S) (k : ℕ) :
    ∑ psi : AddChar G ℂ, (charEigen S psi) ^ k =
      ∑ x : G, (Fintype.card {p : (cayleyGraph S hsymm h0).Walk x x | p.length = k} : ℂ) := by
  rw [← trace_pow_eq_charEigen_sum S hsymm h0 k]
  simp [Matrix.trace]
  exact Finset.sum_congr rfl fun i _ =>
    SimpleGraph.adjMatrix_pow_apply_eq_card_walk (α := ℂ) (G := cayleyGraph S hsymm h0) k i i

/-- **Cross-domain corollary.**  The number of closed `k`-walks in a Cayley graph is
`|G|` times the number of length-`k` additive relations in the connection set: a
graph-theoretic cycle statistic is exactly an additive-combinatorial count. -/
theorem closedWalk_count_eq_card_mul_relationCount (S : Finset G) (hsymm : ∀ s ∈ S, -s ∈ S)
    (h0 : (0 : G) ∉ S) (k : ℕ) :
    ∑ x : G, Fintype.card {p : (cayleyGraph S hsymm h0).Walk x x | p.length = k} =
      Fintype.card G * relationCount S k := by
  have h1 := charEigen_pow_sum_eq_closedWalk_count S hsymm h0 k
  have h2 := charEigen_pow_sum_eq_card_mul_relationCount S k
  rw [← @Nat.cast_inj ℂ]
  simp only [Nat.cast_sum, Nat.cast_mul]
  exact h1.symm.trans h2

/-! ## Consequences and a worked example -/

/-- An additive condition forcing the absence of closed `k`-walks: if the connection
set admits no length-`k` relation, no vertex lies on a closed `k`-walk.  For `k = 3`
this is the sum-free criterion for triangle-freeness of a Cayley graph. -/
theorem isEmpty_closedWalk_of_relationCount_eq_zero (S : Finset G) (hsymm : ∀ s ∈ S, -s ∈ S)
    (h0 : (0 : G) ∉ S) (k : ℕ) (h : relationCount S k = 0) (x : G) :
    IsEmpty {p : (cayleyGraph S hsymm h0).Walk x x | p.length = k} := by
  have hsum := closedWalk_count_eq_card_mul_relationCount S hsymm h0 k
  rw [h] at hsum
  simp at hsum
  exact Fintype.card_eq_zero_iff.mp (hsum x)

/-- The connection set `{1, 3}` of `ZMod 4` is symmetric. -/
lemma zmod4_symm : ∀ s ∈ ({1, 3} : Finset (ZMod 4)), -s ∈ ({1, 3} : Finset (ZMod 4)) := by decide

/-- The connection set `{1, 3}` of `ZMod 4` avoids the identity. -/
lemma zmod4_zero_notMem : (0 : ZMod 4) ∉ ({1, 3} : Finset (ZMod 4)) := by decide

/-- A worked instance: the Cayley graph of `ZMod 4` with connection set `{1,3}` is the
4-cycle, which has `32` closed walks of length `4` in total, matching
`|G| · #{(s₁,s₂,s₃,s₄) ∈ S⁴ : ∑ sᵢ = 0} = 4 · 8`.  Spectrally the same number is
`2⁴ + 0 + (-2)⁴ + 0`. -/
theorem cycle4_closedWalk_count_four :
    ∑ x : ZMod 4,
        Fintype.card {p : (cayleyGraph ({1, 3} : Finset (ZMod 4)) zmod4_symm
          zmod4_zero_notMem).Walk x x | p.length = 4} = 32 := by
  rw [closedWalk_count_eq_card_mul_relationCount _ zmod4_symm zmod4_zero_notMem 4]
  decide

end

end CayleyCharacterSpectra