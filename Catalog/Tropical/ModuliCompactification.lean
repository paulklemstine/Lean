/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Tropical Algebra Foundations for Moduli Space Compactification

This file develops foundational results in tropical algebra connecting:
- The tropical (min-plus) semiring to shortest path combinatorics
- Tropical matrix algebra to weighted graph theory
- Tropical determinants to optimal assignment problems
- Graph genus (first Betti number) to tropical curve invariants

These results formalize the algebraic infrastructure underlying the
tropical compactification approach to moduli spaces of curves.

## Main results

* `tropical_nsmul_eq` — Tropical addition is idempotent: n • a = a for n ≥ 1
* `tropical_matrix_mul_minPlus` — Tropical matrix multiplication equals min-plus composition
* `tropicalDet_eq_untrop_tropicalDetAlg` — Two equivalent formulations of tropical determinant
* `tree_genus_zero` — Trees have tropical genus zero (first Betti number = 0)
-/

import Mathlib

open Tropical Matrix Finset

namespace TropicalModuli

/-! ## Section 1: Tropical Idempotent Semiring

The tropical semiring (ℝ_trop, ⊕, ⊙) where ⊕ = min and ⊙ = + has the
distinctive property that addition is idempotent: a ⊕ a = min(a, a) = a.
This makes it fundamentally different from classical rings and is the
algebraic origin of the piecewise-linear geometry in tropical mathematics.
-/

-- !-- The key property distinguishing tropical from classical algebra:
-- tropical addition (= min) is idempotent, so n-fold addition equals identity. --!--
theorem tropical_nsmul_eq {R : Type*} [LinearOrder R] [OrderTop R]
    (a : Tropical R) (n : ℕ) (hn : 0 < n) : n • a = a := by
  induction n with
  | zero => omega
  | succ k ih =>
    exact Tropical.succ_nsmul a k

-- Corollary: tropical addition is idempotent
theorem tropical_add_self {R : Type*} [LinearOrder R] [OrderTop R]
    (a : Tropical R) : a + a = a := by
  have h := Tropical.succ_nsmul a 1
  rw [show (1 + 1 : ℕ) = 2 from rfl] at h
  rw [show (2 : ℕ) • a = a + a from two_nsmul a] at h
  exact h

/-
The tropical semiring absorbs repeated addition into identity
-/
theorem tropical_sum_const {R : Type*} [LinearOrder R] [OrderTop R]
    {ι : Type*} [Fintype ι] [Nonempty ι] (a : Tropical R) :
    ∑ _ : ι, a = a := by
  convert tropical_nsmul_eq a ( Fintype.card ι ) ( Fintype.card_pos );
  simp +decide [Finset.sum_const]

/-! ## Section 2: Tropical Matrix Algebra and Min-Plus Interpretation

Tropical matrix multiplication over Tropical(WithTop ℕ) computes min-plus
composition: (A·B)_{ij} = min_k (A_{ik} + B_{kj}). This is the algebraic
foundation of shortest-path algorithms: the tropical matrix product
automatically computes optimal routing through intermediate nodes.
-/

-- !-- Tropical matrix multiplication equals min-plus composition: the (i,j) entry of A·B
-- is the infimum over k of (A_{ik} + B_{kj}), connecting matrix algebra to shortest paths. --!--
theorem tropical_matrix_mul_minPlus {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) (Tropical (WithTop ℕ))) (i j : Fin n) :
    Tropical.untrop ((A * B) i j) =
      ⨅ k : Fin n, (Tropical.untrop (A i k) + Tropical.untrop (B k j)) := by
  rw [Matrix.mul_apply, _root_.untrop_sum]
  simp [Tropical.untrop_mul]

/-! ## Section 3: Tropical Determinant and Optimal Assignment

The tropical determinant of an n×n matrix A is defined as:
  trop_det(A) = ⊕_{σ ∈ S_n} ⊗_i A_{i,σ(i)}
              = min_{σ ∈ S_n} Σ_i A_{i,σ(i)}

This is precisely the optimal assignment problem: find the permutation σ
that minimizes the total cost of assigning row i to column σ(i).

We prove the equivalence between the algebraic formulation (using tropical
semiring operations) and the combinatorial formulation (min over permutations).
-/

/-- The tropical determinant as minimum over permutations of sum of entries.
    This is the combinatorial/optimization formulation. -/
noncomputable def tropicalDet {n : ℕ}
    (A : Matrix (Fin n) (Fin n) (Tropical (WithTop ℕ))) : WithTop ℕ :=
  ⨅ σ : Equiv.Perm (Fin n), ∑ i : Fin n, Tropical.untrop (A i (σ i))

/-- The tropical determinant using tropical semiring operations directly.
    This is the algebraic formulation: tropical sum of tropical products. -/
noncomputable def tropicalDetAlg {n : ℕ}
    (A : Matrix (Fin n) (Fin n) (Tropical (WithTop ℕ))) : Tropical (WithTop ℕ) :=
  ∑ σ : Equiv.Perm (Fin n), ∏ i : Fin n, A i (σ i)

-- !-- The algebraic tropical determinant (∑_σ ∏_i A_{iσ(i)} in tropical ops)
-- equals the combinatorial one (min_σ Σ_i untrop(A_{iσ(i)})). This bridges
-- tropical algebra and combinatorial optimization. --!--
theorem tropicalDet_eq_untrop_tropicalDetAlg {n : ℕ}
    (A : Matrix (Fin n) (Fin n) (Tropical (WithTop ℕ))) :
    tropicalDet A = Tropical.untrop (tropicalDetAlg A) := by
  simp only [tropicalDet, tropicalDetAlg]
  rw [_root_.untrop_sum]
  congr 1
  ext σ
  rw [_root_.untrop_prod]

-- The tropical determinant is at most any single permutation's cost
theorem tropicalDet_le_perm {n : ℕ}
    (A : Matrix (Fin n) (Fin n) (Tropical (WithTop ℕ)))
    (σ : Equiv.Perm (Fin n)) :
    tropicalDet A ≤ ∑ i : Fin n, Tropical.untrop (A i (σ i)) := by
  exact iInf_le _ σ

/-! ## Section 4: Graph Genus and Tropical Curves

In tropical geometry, a tropical curve of genus g is a metric graph with
first Betti number g. The genus formula for a connected graph is:
  g = |E| - |V| + 1

This connects the moduli space M_g^trop to the combinatorics of graphs.
Trees have genus 0, and each independent cycle adds 1 to the genus.
-/

/-- The first Betti number (cycle rank) of a finite graph, interpreted as
    the genus of the corresponding tropical curve. For a graph with v vertices,
    e edges, and c connected components: genus = e - v + c.
    We use ℤ to avoid natural number subtraction issues. -/
noncomputable def graphGenus {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] [Fintype G.edgeSet] : ℤ :=
  (Fintype.card G.edgeSet : ℤ) - (Fintype.card V : ℤ) +
    (Fintype.card G.ConnectedComponent : ℤ)

/-
!-- Trees have genus zero: a tree on n vertices has exactly n-1 edges and
1 connected component, so genus = (n-1) - n + 1 = 0. This formalizes
the fact that trees are the genus-0 tropical curves. --!--
-/
theorem tree_genus_zero {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] [Fintype G.edgeSet]
    (hT : G.IsTree) :
    graphGenus G = 0 := by
  -- Since the graph is a tree, it has exactly one connected component.
  have h_connected_components : Fintype.card G.ConnectedComponent = 1 := by
    convert Fintype.card_eq_one_iff.mpr _;
    obtain ⟨x, hx⟩ : ∃ x : V, ∀ y : V, G.Reachable x y := by
      cases isEmpty_or_nonempty V <;> have := hT.1 <;> simp_all +decide [ SimpleGraph.connected_iff_exists_forall_reachable ];
    use G.connectedComponentMk x;
    rintro ⟨ y ⟩;
    exact Quot.sound ( hx y |> fun h => h.symm );
  have h_edges : Fintype.card G.edgeSet + 1 = Fintype.card V := by
    convert hT.card_edgeFinset;
    rw [ Fintype.card_of_subtype ] ; aesop;
  unfold graphGenus; linarith;

/-
The genus formula for connected graphs: genus = |E| - |V| + 1
-/
theorem genus_connected {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] [Fintype G.edgeSet]
    (hc : G.Connected) :
    graphGenus G = (Fintype.card G.edgeSet : ℤ) - (Fintype.card V : ℤ) + 1 := by
  have h_connected : Nonempty (V) := by
    grind +suggestions
  have h_connected_components : Fintype.card G.ConnectedComponent = 1 := by
    convert Fintype.card_eq_one_iff.mpr ?_;
    obtain ⟨ x ⟩ := h_connected; use G.connectedComponentMk x; intro y; exact (by
    obtain ⟨ z, rfl ⟩ := y.exists_rep; exact (by
      have h_path : G.Reachable x z := by
        exact hc x z
      exact Quot.sound h_path.symm
    ));
  unfold graphGenus
  simp [h_connected_components]

/-! ## Section 5: Tropical Matrix Powers and Shortest Paths -/

-- Tropical matrix power: 2nd power computes 2-step optimal paths
theorem tropical_matrix_sq_interpretation {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) (Tropical (WithTop ℕ))) (i j : Fin n) :
    Tropical.untrop ((A ^ 2) i j) =
      ⨅ k : Fin n, (Tropical.untrop (A i k) + Tropical.untrop (A k j)) := by
  have : A ^ 2 = A * A := sq A
  rw [this]
  exact tropical_matrix_mul_minPlus A A i j

/-
Three-step paths through tropical cube
-/
theorem tropical_matrix_cube_interpretation {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) (Tropical (WithTop ℕ))) (i j : Fin n) :
    Tropical.untrop ((A ^ 3) i j) =
      ⨅ k : Fin n, ⨅ l : Fin n,
        (Tropical.untrop (A i k) + Tropical.untrop (A k l) + Tropical.untrop (A l j)) := by
  rw [ show A ^ 3 = A ^ 2 * A by rw [ pow_succ ], Matrix.mul_apply ];
  rw [ show ( ∑ j_1, ( A ^ 2 ) i j_1 * A j_1 j ) = ( ∑ j_1, ∑ k, A i k * A k j_1 * A j_1 j ) by
        simp +decide only [pow_two, mul_apply, sum_mul] ];
  have h_min : ∀ (s : Finset (Fin n × Fin n)), s.Nonempty → untrop (∑ p ∈ s, A i p.1 * A p.1 p.2 * A p.2 j) = ⨅ p ∈ s, untrop (A i p.1) + untrop (A p.1 p.2) + untrop (A p.2 j) := by
    intros s hs_nonempty
    induction' s using Finset.induction with p s ih;
    · exact False.elim <| Finset.not_nonempty_empty hs_nonempty;
    · by_cases hs : s.Nonempty <;> simp_all +decide [ Finset.sum_insert ih ];
      refine' le_antisymm _ _ <;> simp +decide [ ciInf_eq_ite ];
      · intro a b; split_ifs <;> simp_all +decide [ ciInf_eq_ite ] ;
        exact Classical.or_iff_not_imp_left.2 fun h => le_trans ( ciInf_le ( Finite.bddBelow_range _ ) ( a, b ) ) ( by aesop );
      · refine' ⟨ _, _ ⟩;
        · exact ciInf_le ⟨ 0, Set.forall_mem_range.mpr fun _ => by positivity ⟩ p |> le_trans <| by aesop;
        · intro a b; exact ciInf_le_of_le ⟨ 0, Set.forall_mem_range.mpr fun _ => by aesop ⟩ ( a, b ) ( by aesop ) ;
  convert h_min ( Finset.univ : Finset ( Fin n × Fin n ) ) ( Finset.univ_nonempty ) using 1;
  · rw [ ← Finset.sum_product' ];
    refine' congr_arg _ ( Finset.sum_bij ( fun x _ => ( x.2, x.1 ) ) _ _ _ _ ) <;> simp +decide;
  · simp +decide;
    rw [ @iInf_prod ]

end TropicalModuli