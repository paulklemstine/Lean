/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Chip-Firing Correspondence — Tropical Hodge Theory Meets Baker-Norine

This file establishes the foundational algebraic theory connecting chip-firing
on graphs to the Laplacian kernel structure, providing the combinatorial
backbone for the tropical Hodge theory correspondence.

## Main Definitions

* `GraphDivisor` — a divisor on a graph with integer coefficients
* `GraphDivisor.degree` — sum of all coefficients
* `GraphDivisor.chipFire` — chip-firing at a vertex (Laplacian action)
* `principalDivisor` — the image of a function under the Laplacian
* `graphGenus` — the genus (cyclomatic number) of a graph: |E| - |V| + 1

## Main Results

* `chipFire_degree_preserved` — chip-firing preserves divisor degree
* `chipFire_eq_laplacian_action` — chip-firing is the Laplacian action
* `principalDivisor_degree_zero` — principal divisors have degree zero
* `laplacian_kernel_contains_constants` — constants are in the kernel
* `genus_nonneg_of_connected` — genus ≥ 0 for connected graphs
* `degree_add` — degree is additive
* `graphLaplacian_row_sum_zero` — Laplacian rows sum to zero
* `graphLaplacian_symmetric` — Laplacian is symmetric
* `graphLaplacian_diagonal_nonneg` — diagonal entries nonneg

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a
  finite graph" (2007)
* Gathmann, A. and Kerber, M. "A Riemann-Roch theorem in tropical geometry" (2008)
-/

import Mathlib

open Finset BigOperators SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Graph Laplacian -/

/-- The combinatorial graph Laplacian matrix `L(G)` with entries:
    `L(v,v) = deg(v)`, `L(v,w) = -1` if `v ~ w`, `L(v,w) = 0` otherwise. -/
def graphLap
    (G : SimpleGraph V) [DecidableRel G.Adj] : Matrix V V ℤ :=
  fun i j =>
    if i = j then (G.degree i : ℤ)
    else if G.Adj i j then -1
    else 0

/-! ### Core Divisor Definitions -/

/-- A divisor on a graph: assigns an integer to each vertex. -/
@[ext]
structure GraphDivisor (V : Type*) where
  coeff : V → ℤ

namespace GraphDivisor

instance : Zero (GraphDivisor V) := ⟨⟨fun _ => 0⟩⟩

instance : Add (GraphDivisor V) := ⟨fun D E => ⟨fun v => D.coeff v + E.coeff v⟩⟩

instance : Neg (GraphDivisor V) := ⟨fun D => ⟨fun v => -D.coeff v⟩⟩

@[simp] lemma zero_coeff (v : V) : (0 : GraphDivisor V).coeff v = 0 := rfl
@[simp] lemma add_coeff (D₁ D₂ : GraphDivisor V) (v : V) :
    (D₁ + D₂).coeff v = D₁.coeff v + D₂.coeff v := rfl
@[simp] lemma neg_coeff (D : GraphDivisor V) (v : V) :
    (-D).coeff v = -D.coeff v := rfl

/-- Degree of a divisor: sum of all coefficients. -/
def degree [Fintype V] (D : GraphDivisor V) : ℤ := ∑ v : V, D.coeff v

/-- A divisor is effective if all coefficients are nonnegative. -/
def effective (D : GraphDivisor V) : Prop := ∀ v, D.coeff v ≥ 0

/-- Chip-firing at vertex `q` on graph `G`: vertex `q` sends one chip
    along each edge to its neighbors. -/
def chipFire
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (D : GraphDivisor V) (q : V) : GraphDivisor V :=
  ⟨fun v =>
    if v = q then D.coeff v - (G.degree q : ℤ)
    else if G.Adj q v then D.coeff v + 1
    else D.coeff v⟩

end GraphDivisor

/-- The genus (cyclomatic number / first Betti number) of a simple graph. -/
noncomputable def graphGenus (G : SimpleGraph V) [DecidableRel G.Adj] : ℤ :=
  (G.edgeFinset.card : ℤ) - (Fintype.card V : ℤ) + 1

/-- A principal divisor: the image of a function f under the Laplacian. -/
def principalDivisor
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : V → ℤ) : GraphDivisor V :=
  ⟨fun v => ∑ w : V, graphLap G v w * f w⟩

/-! ### Laplacian Properties -/

/-
**Row-sum zero property.** Each row of the graph Laplacian sums to zero.
-/
theorem graphLap_row_sum_zero
    (G : SimpleGraph V) [DecidableRel G.Adj] (i : V) :
    ∑ j : V, graphLap G i j = 0 := by
  simp +decide only [graphLap];
  simp +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne, SimpleGraph.degree, SimpleGraph.neighborFinset ];
  simp +decide [ Finset.filter_erase, SimpleGraph.adj_comm ]

/-
**Symmetry.** The graph Laplacian is symmetric.
-/
theorem graphLap_symmetric
    (G : SimpleGraph V) [DecidableRel G.Adj] (i j : V) :
    graphLap G i j = graphLap G j i := by
  unfold graphLap;
  simp +decide [ eq_comm, SimpleGraph.adj_comm ];
  grind

/-
**Nonnegative diagonal.** Diagonal entries of the Laplacian are nonneg.
-/
theorem graphLap_diagonal_nonneg
    (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    0 ≤ graphLap G v v := by
  grind +locals

/-
**Diagonal equals degree.**
-/
theorem graphLap_diagonal_eq_degree
    (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    graphLap G v v = (G.degree v : ℤ) := by
  unfold graphLap; aesop;

/-
**Off-diagonal entries are ≤ 0.**
-/
theorem graphLap_off_diagonal_nonpos
    (G : SimpleGraph V) [DecidableRel G.Adj] (i j : V) (hij : i ≠ j) :
    graphLap G i j ≤ 0 := by
  by_cases h : G.Adj i j <;> simp +decide [ *, graphLap ]

/-
**Column-sum zero** (follows from symmetry + row-sum zero).
-/
theorem graphLap_col_sum_zero
    (G : SimpleGraph V) [DecidableRel G.Adj] (j : V) :
    ∑ i : V, graphLap G i j = 0 := by
  convert graphLap_row_sum_zero G j using 1;
  exact Finset.sum_congr rfl fun _ _ => graphLap_symmetric G _ _

/-! ### Degree Properties -/

/-- The degree of the zero divisor is zero. -/
theorem degree_zero_eq_zero : (0 : GraphDivisor V).degree = 0 := by
  simp [GraphDivisor.degree]

/-
The degree of a sum equals the sum of degrees.
-/
theorem degree_add (D₁ D₂ : GraphDivisor V) :
    (D₁ + D₂).degree = D₁.degree + D₂.degree := by
  exact Finset.sum_add_distrib

/-
The degree of a negated divisor.
-/
theorem degree_neg (D : GraphDivisor V) :
    (-D).degree = -D.degree := by
  convert Finset.sum_neg_distrib;
  convert Iff.rfl;
  rotate_left;
  exact V;
  exact ℤ;
  exact Finset.univ;
  exact inferInstance;
  exact iff_of_true ( fun f => by rw [ Finset.sum_neg_distrib ] ) ( by rw [ GraphDivisor.degree, GraphDivisor.degree ] ; simp +decide [ Finset.sum_neg_distrib ] )

/-! ### Chip-Firing Theorems -/

/-
**Chip-firing preserves degree.** The total number of chips is conserved.
-/
theorem chipFire_degree_preserved
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (D : GraphDivisor V) (q : V) :
    (D.chipFire G q).degree = D.degree := by
  nontriviality;
  unfold GraphDivisor.degree GraphDivisor.chipFire;
  simp +decide [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq', SimpleGraph.degree, SimpleGraph.neighborFinset_def ];
  simp +decide [ Finset.filter_erase, Finset.sum_add_distrib ];
  rw [ ← Finset.sum_filter_add_sum_filter_not Finset.univ ( fun x => G.Adj q x ) ] ; ring

/-
**The Laplacian encodes chip-firing.**
-/
theorem chipFire_eq_laplacian_action
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (D : GraphDivisor V) (q v : V) :
    (D.chipFire G q).coeff v - D.coeff v = -graphLap G q v := by
  -- By definition of chipFire, we have:
  simp [GraphDivisor.chipFire, graphLap];
  grind

/-! ### Principal Divisor Properties -/

/-
**Principal divisors have degree zero** (discrete divergence theorem).
-/
theorem principalDivisor_degree_zero
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : V → ℤ) :
    (principalDivisor G f).degree = 0 := by
  convert Finset.sum_comm using 1 ; simp +decide [ graphLap_col_sum_zero, mul_comm ];
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, graphLap_col_sum_zero ]

/-
**Constants are in the Laplacian kernel.**
-/
theorem laplacian_kernel_contains_constants
    (G : SimpleGraph V) [DecidableRel G.Adj] (c : ℤ) (v : V) :
    ∑ w : V, graphLap G v w * c = 0 := by
  rw [ ← Finset.sum_mul _ _ _, graphLap_row_sum_zero, MulZeroClass.zero_mul ]

/-
**Genus is nonneg for connected graphs.**
-/
theorem genus_nonneg_of_connected
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected) :
    0 ≤ graphGenus G := by
  contrapose! hconn;
  intro h;
  have := h.exists_isTree_le;
  obtain ⟨ T, hT₁, hT₂ ⟩ := this; have := hT₂.card_edgeFinset; simp_all +decide [ graphGenus ] ;
  linarith [ show #T.edgeFinset ≤ #G.edgeFinset from Finset.card_mono <| by aesop ]

/-! ### Linear Equivalence -/

/-- Two divisors are linearly equivalent if their difference is a principal divisor. -/
def GraphDivisor.linearEquiv
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (D₁ D₂ : GraphDivisor V) : Prop :=
  ∃ f : V → ℤ, ∀ v, D₂.coeff v - D₁.coeff v =
    ∑ w : V, f w * graphLap G w v

/-
**Linear equivalence preserves degree.**
-/
theorem linearEquiv_degree_invariant
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (D₁ D₂ : GraphDivisor V) (h : D₁.linearEquiv G D₂) :
    D₁.degree = D₂.degree := by
  -- By definition of linear equivalence, we have that for all v, D₂.coeff v - D₁.coeff v = ∑ w, f w * graphLap G w v.
  obtain ⟨f, hf⟩ := h;
  have h_sum : ∑ v, (D₂.coeff v - D₁.coeff v) = 0 := by
    rw [ Finset.sum_congr rfl fun v _ => hf v, Finset.sum_comm ];
    simp +decide [ ← Finset.mul_sum _ _ _, graphLap_row_sum_zero ];
  simp_all +decide [ GraphDivisor.degree ];
  simp_all +decide [ sub_eq_iff_eq_add, Finset.sum_add_distrib ]

/-
**Linear equivalence is reflexive.**
-/
theorem linearEquiv_refl
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (D : GraphDivisor V) :
    D.linearEquiv G D := by
  exact ⟨ fun _ => 0, fun _ => by simp +decide ⟩

/-
**Linear equivalence is symmetric.**
-/
theorem linearEquiv_symm
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (D₁ D₂ : GraphDivisor V) (h : D₁.linearEquiv G D₂) :
    D₂.linearEquiv G D₁ := by
  obtain ⟨f, hf⟩ := h
  use -f
  intro v
  simp [hf];
  grind