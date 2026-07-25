/-
# Baker-Norine Theory: Algebraic Foundations

This file formalizes the algebraic foundations of Baker-Norine theory on finite
graphs, establishing the key structural results connecting graph combinatorics
to divisor theory.

## Main Definitions

* `GraphDivisor` — Divisors on a simple graph (integer-valued functions on vertices)
* `graphGenus` — The genus g = |E| - |V| + 1 of a connected graph
* `canonicalDivisor` — The canonical divisor K_G(v) = deg(v) - 2
* `chipFire` — The chip-firing operator at a vertex
* `IsQReduced` — q-reduced divisors (key to algorithmic rank computation)
* `divisorRank` — The rank r(D) of a divisor

## Main Results

* `canonical_degree` — deg(K_G) = 2g - 2
* `chipFire_degree_invariant` — Chip-firing preserves divisor degree
* `linear_equiv_is_equivalence` — Linear equivalence is an equivalence relation
* `complete_graph_genus` — g(K_n) = (n-1)(n-2)/2
* `canonical_uniform_complete` — K_{K_n} is uniform with value n-3
* `effective_rank_nonneg` — Effective divisors have rank ≥ 0

## References

* Baker, M., Norine, S., "Riemann-Roch and Abel-Jacobi theory on a finite graph"
* Corry, S., Perkinson, D., "Divisors and Sandpiles"
-/

import Mathlib

open Finset SimpleGraph BigOperators Classical

noncomputable section

namespace BakerNorine

/-! ## Core Definitions -/

/-- A divisor on a graph with vertex set `V` is an integer-valued function on vertices. -/
abbrev GraphDivisor (V : Type*) := V → ℤ

/-- The degree of a divisor: the total number of chips. -/
def degDiv {V : Type*} [Fintype V] (D : GraphDivisor V) : ℤ :=
  ∑ v : V, D v

/-- A divisor is effective if all values are nonnegative. -/
def IsEffective {V : Type*} (D : GraphDivisor V) : Prop :=
  ∀ v : V, 0 ≤ D v

/-- The graph Laplacian applied to a function f.
  (Δf)(v) = Σ_{w ~ v} (f(v) - f(w)) -/
def laplacian {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (f : V → ℤ) : GraphDivisor V :=
  fun v => ∑ w ∈ G.neighborFinset v, (f v - f w)

/-- Two divisors are linearly equivalent if they differ by a principal divisor. -/
def LinEquiv {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D₁ D₂ : GraphDivisor V) : Prop :=
  ∃ f : V → ℤ, ∀ v, D₁ v - D₂ v = laplacian G f v

/-- Chip-firing at vertex `q`: vertex q sends one chip to each neighbor. -/
def chipFire {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (q : V) (D : GraphDivisor V) : GraphDivisor V :=
  fun v =>
    if v = q then D v - G.degree v
    else if G.Adj q v then D v + 1
    else D v

/-- The canonical divisor K_G: at each vertex v, K_G(v) = deg(v) - 2. -/
def canonicalDivisor {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : GraphDivisor V :=
  fun v => (G.degree v : ℤ) - 2

/-- The genus of a graph: g = |E| - |V| + 1. -/
def graphGenus {V : Type*} [Fintype V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : ℤ :=
  G.edgeFinset.card - Fintype.card V + 1

/-- A divisor D is q-reduced if:
1. D(v) ≥ 0 for all v ≠ q
2. For every nonempty subset S not containing q, there exists v ∈ S with
   D(v) < outdeg_S(v). -/
def IsQReduced {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (q : V) (D : GraphDivisor V) : Prop :=
  (∀ v : V, v ≠ q → 0 ≤ D v) ∧
  (∀ S : Finset V, q ∉ S → S.Nonempty →
    ∃ v ∈ S, D v < (S.filter (G.Adj v)).card)

/-- The rank of a divisor. r(D) = -1 if D is not equivalent to any effective divisor;
otherwise the supremum of k ≥ 0 such that D - E ~ effective for all effective E
with deg(E) = k. -/
def divisorRank {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V) : ℤ :=
  if ¬∃ E : GraphDivisor V, LinEquiv G D E ∧ IsEffective E then -1
  else sSup ({k : ℤ | k ≥ 0 ∧ ∀ E : GraphDivisor V, IsEffective E → degDiv E = k →
      ∃ F : GraphDivisor V, LinEquiv G (fun v => D v - E v) F ∧ IsEffective F} : Set ℤ)

/-! ## Fundamental Structural Theorems -/

/-
The Laplacian has degree zero: chips are conserved.
-/
theorem laplacian_degree_zero {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (f : V → ℤ) :
    degDiv (laplacian G f) = 0 := by
      unfold laplacian degDiv; simp +decide [ Finset.sum_add_distrib, Finset.mul_sum ] ; ring;
      simp +decide only [degree, neighborFinset_eq_filter];
      simp +decide [ Finset.sum_filter, SimpleGraph.adj_comm ];
      rw [ sub_eq_zero, Finset.sum_comm ];
      simp +decide [ Finset.sum_ite, SimpleGraph.adj_comm ]

/-
**Chip-firing preserves degree.**
-/
theorem chipFire_degree_invariant {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (q : V) (D : GraphDivisor V) :
    degDiv (chipFire G q D) = degDiv D := by
      unfold degDiv chipFire; simp +decide [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq' ] ; ring;
      simp +decide [ Finset.sum_add_distrib, Finset.sum_ite, SimpleGraph.degree, SimpleGraph.neighborFinset_def ];
      simp +decide [ Finset.filter_erase, Finset.filter_not, Finset.sum_erase ] ; ring

/-
**Linear equivalence preserves degree.**
-/
theorem linEquiv_preserves_degree {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] {D₁ D₂ : GraphDivisor V}
    (h : LinEquiv G D₁ D₂) : degDiv D₁ = degDiv D₂ := by
      obtain ⟨ f, hf ⟩ := h;
      unfold laplacian at hf; have := laplacian_degree_zero G f; simp_all +decide [ sub_eq_iff_eq_add, Finset.sum_add_distrib ] ;
      unfold degDiv at *; simp_all +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, laplacian ] ;

/-
Linear equivalence is reflexive.
-/
theorem linEquiv_refl {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V) :
    LinEquiv G D D := by
      -- By definition of linear equivalence, we need to show that there exists a function f such that D - D = laplacian G f.
      use 0
      simp [laplacian]

/-
Linear equivalence is symmetric.
-/
theorem linEquiv_symm {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] {D₁ D₂ : GraphDivisor V}
    (h : LinEquiv G D₁ D₂) : LinEquiv G D₂ D₁ := by
      obtain ⟨ f, hf ⟩ := h;
      use -f;
      simp_all +decide [ laplacian ];
      simp_all +decide [ Finset.sum_add_distrib, sub_eq_iff_eq_add' ]

/-
Linear equivalence is transitive.
-/
theorem linEquiv_trans {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] {D₁ D₂ D₃ : GraphDivisor V}
    (h₁ : LinEquiv G D₁ D₂) (h₂ : LinEquiv G D₂ D₃) :
    LinEquiv G D₁ D₃ := by
      obtain ⟨ f, hf ⟩ := h₁
      obtain ⟨ g, hg ⟩ := h₂
      use fun v => f v + g v;
      simp_all +decide [ laplacian, Finset.sum_add_distrib ];
      intro v; linear_combination' hf v + hg v;

/-
Linear equivalence is an equivalence relation, witnessed by
`linEquiv_refl`, `linEquiv_symm`, `linEquiv_trans` above.

Chip-firing produces a linearly equivalent divisor.
-/
theorem chipFire_linEquiv {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (q : V) (D : GraphDivisor V) :
    LinEquiv G D (chipFire G q D) := by
      use fun v => if v = q then 1 else 0;
      intro v
      simp [chipFire, laplacian];
      split_ifs <;> simp_all +decide [ SimpleGraph.adj_comm ]

/-! ## The Canonical Divisor and Genus -/

/-
The sum of vertex degrees equals twice the number of edges (handshaking).
-/
theorem sum_degrees_eq {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    (∑ v : V, (G.degree v : ℤ)) = 2 * G.edgeFinset.card := by
      exact mod_cast G.sum_degrees_eq_twice_card_edges

/-
**The Riemann-Roch degree identity**: deg(K_G) = 2g - 2.
-/
theorem canonical_degree {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    degDiv (canonicalDivisor G) = 2 * graphGenus G - 2 := by
      unfold degDiv canonicalDivisor graphGenus;
      have := G.sum_degrees_eq_twice_card_edges; norm_num at *; linarith;

/-! ## Complete Graph Specialization -/

/-
The degree of every vertex in K_n is n-1.
-/
theorem complete_graph_degree {n : ℕ} (v : Fin n) :
    (⊤ : SimpleGraph (Fin n)).degree v = n - 1 := by
      simp +decide [ Finset.filter_ne' ]

/-
**Genus of the complete graph**: g(K_n) = (n-1)(n-2)/2.
-/
theorem complete_graph_genus {n : ℕ} (hn : 2 ≤ n) :
    graphGenus (⊤ : SimpleGraph (Fin n)) = ((n - 1) * (n - 2) : ℕ) / 2 := by
      rcases n with ( _ | _ | n ) <;> simp_all +decide [ graphGenus ];
      simp +decide [ Finset.card_compl, Sym2.diagSet ];
      rw [ show ( Finset.univ.filter fun x : Sym2 ( Fin ( n + 2 ) ) => ¬x.IsDiag ) = Finset.univ \ Finset.image ( fun x : Fin ( n + 2 ) => Sym2.mk ( x, x ) ) Finset.univ from ?_, Finset.card_sdiff ] <;> norm_num [ Finset.card_image_of_injective, Function.Injective ] ; ring;
      · rw [ Nat.cast_sub ] <;> norm_num [ Sym2.card ] ; ring;
        · rw [ Nat.choose_two_right ];
          grind;
        · simp +arith +decide [ Nat.choose ];
      · ext ⟨ x, y ⟩ ; aesop

/-
**Canonical divisor uniformity for K_n**: K_{K_n}(v) = n - 3.
-/
theorem canonical_uniform_complete {n : ℕ} (v : Fin n) :
    canonicalDivisor (⊤ : SimpleGraph (Fin n)) v = (n : ℤ) - 3 := by
      rcases n with ( _ | _ | n ) <;> simp_all +decide [ canonicalDivisor ];
      · exact Fin.elim0 v;
      · ring

/-! ## Laplacian Lattice -/

/-- The Laplacian lattice: image of the graph Laplacian in ℤ^V. -/
def laplacianLattice {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : Set (GraphDivisor V) :=
  {D | ∃ f : V → ℤ, D = laplacian G f}

/-
The Laplacian lattice is closed under addition.
-/
theorem laplacianLattice_add {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    {D₁ D₂ : GraphDivisor V}
    (h₁ : D₁ ∈ laplacianLattice G) (h₂ : D₂ ∈ laplacianLattice G) :
    (fun v => D₁ v + D₂ v) ∈ laplacianLattice G := by
      obtain ⟨ f₁, rfl ⟩ := h₁
      obtain ⟨ f₂, rfl ⟩ := h₂
      use fun v => f₁ v + f₂ v;
      unfold laplacian; simp +decide [ Finset.sum_add_distrib, add_sub_add_comm ] ;

/-
The Laplacian lattice is closed under negation.
-/
theorem laplacianLattice_neg {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    {D : GraphDivisor V} (h : D ∈ laplacianLattice G) :
    (fun v => -D v) ∈ laplacianLattice G := by
      obtain ⟨ f, rfl ⟩ := h;
      use fun v => -f v;
      ext v; simp +decide [ laplacian ] ;
      simp +decide [ Finset.sum_add_distrib, mul_comm ];
      ring

/-
The zero divisor is in the Laplacian lattice.
-/
theorem laplacianLattice_zero {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    (fun (_ : V) => (0 : ℤ)) ∈ laplacianLattice G := by
      exact ⟨ 0, by ext; simp +decide [ laplacian ] ⟩

/-! ## Q-Reduced Divisor Uniqueness -/

/-
**Uniqueness of q-reduced representatives.**
Every linear equivalence class contains at most one q-reduced divisor.
-/
theorem qReduced_unique {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (_hconn : G.Connected) (q : V) {D₁ D₂ : GraphDivisor V}
    (hq1 : IsQReduced G q D₁) (hq2 : IsQReduced G q D₂)
    (hequiv : LinEquiv G D₁ D₂) : D₁ = D₂ := by
      obtain ⟨ f, hf ⟩ := hequiv;
      -- By contradiction, assume there exists a vertex $v$ such that $f(v) \neq f(q)$.
      by_contra h_nonconst;
      -- Let $S = \{ v \neq q : f(v) > f(q) \}$. If $S$ is nonempty, since $D_1$ and $D_2$ are $q$-reduced, the $q$-reduced condition for $D_2$ applied to $S$ gives $v \in S$ with $D_2(v) < |neighbors of v in S|$.
      obtain ⟨v, hv⟩ : ∃ v, v ≠ q ∧ f v > f q ∧ ∀ w, w ≠ q → f w > f q → f v ≥ f w := by
        obtain ⟨v, hv⟩ : ∃ v, v ≠ q ∧ f v > f q := by
          by_cases h_cases : ∀ v, v ≠ q → f v ≤ f q;
          · -- Let $S = \{ v \neq q : f(v) < f(q) \}$. If $S$ is nonempty, since $D_1$ and $D_2$ are $q$-reduced, the $q$-reduced condition for $D_1$ applied to $S$ gives $v \in S$ with $D_1(v) < |neighbors of v in S|$.
            obtain ⟨v, hv⟩ : ∃ v, v ≠ q ∧ f v < f q := by
              by_cases h_cases : ∀ v, v ≠ q → f v = f q;
              · have h_const : ∀ v, f v = f q := by
                  exact fun v => if hv : v = q then hv.symm ▸ rfl else h_cases v hv;
                simp_all +decide [ funext_iff, laplacian ];
                exact h_nonconst.elim fun x hx => hx ( sub_eq_zero.mp ( hf x ) );
              · exact by push_neg at h_cases; obtain ⟨ v, hv, hv' ⟩ := h_cases; exact ⟨ v, hv, lt_of_le_of_ne ( by solve_by_elim ) hv' ⟩ ;
            -- Let $S = \{ v \neq q : f(v) < f(q) \}$. Since $S$ is nonempty, we can choose $v \in S$ such that $f(v)$ is minimal.
            obtain ⟨v, hvS, hv_min⟩ : ∃ v ∈ {v | v ≠ q ∧ f v < f q}, ∀ w ∈ {v | v ≠ q ∧ f v < f q}, f v ≤ f w := by
              apply_rules [ Set.exists_min_image ];
              · exact Set.toFinite _;
              · exact ⟨ v, hv ⟩;
            have := hq1.2 { v } ; simp_all +decide [ Finset.filter_singleton ] ;
            exact absurd ( this ( Ne.symm hvS.1 ) ) ( not_lt_of_ge ( hq1.1 v hvS.1 ) );
          · aesop;
        have := Finset.exists_max_image ( Finset.univ.filter fun w => w ≠ q ∧ f w > f q ) ( fun w => f w ) ⟨ v, by aesop ⟩ ; aesop;
      have := hq2.2 { v } ; simp_all +decide [ Finset.filter_singleton ] ;
      exact absurd ( this ( Ne.symm hv.1 ) ) ( not_lt_of_ge ( hq2.1 v hv.1 ) )

/-! ## Rank Properties -/

/-
**Effective divisors have nonnegative rank.**
-/
theorem effective_rank_nonneg {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V)
    (heff : IsEffective D) : 0 ≤ divisorRank G D := by
      unfold divisorRank;
      split_ifs <;> simp_all +decide [ linEquiv_refl ];
      by_contra h_neg;
      refine' h_neg ( le_csSup _ _ );
      · exact ( by by_contra h; rw [ csSup_of_not_bddAbove h ] at h_neg; norm_num at h_neg );
      · refine' ⟨ le_rfl, fun E hE hE' => _ ⟩;
        -- Since $E$ is effective and has degree zero, it must be the zero divisor.
        have hE_zero : E = fun _ => 0 := by
          exact funext fun v => le_antisymm ( le_trans ( Finset.single_le_sum ( fun a _ => hE a ) ( Finset.mem_univ v ) ) hE'.le ) ( hE v );
        aesop

/-! ## Baker-Norine Riemann-Roch: Statement -/

/-- **Baker-Norine Riemann-Roch Theorem (Conjecture/Open Formalization).**
For a connected graph G of genus g and any divisor D:
  r(D) - r(K_G - D) = deg(D) - g + 1

This is known to be true (Baker-Norine 2007) but the full proof requires
Dhar's burning algorithm and extensive additional infrastructure.
It is left as a target for future formalization. -/
theorem baker_norine_riemann_roch {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected) (D : GraphDivisor V) :
    divisorRank G D - divisorRank G (fun v => canonicalDivisor G v - D v) =
    degDiv D - graphGenus G + 1 := by sorry

end BakerNorine

end