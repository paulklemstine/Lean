/-
# Baker-Norine Theory: Algebraic Foundations of Chip-Firing on Graphs

This file establishes the algebraic foundations of Baker-Norine theory on finite
graphs: divisors, chip-firing, the Laplacian, linear equivalence, the canonical
divisor, genus, q-reduced divisors, and divisor rank.

## Main definitions

* `GraphDivisor` — integer-valued function on vertices (divisor on a graph)
* `graphGenus` — genus g = |E| - |V| + 1 for a connected graph
* `canonicalDivisor` — K_G(v) = deg(v) - 2
* `chipFire` — the chip-firing operation at a vertex
* `laplacianDiv` — the Laplacian Δf as a principal divisor
* `linEquiv` — linear equivalence of divisors
* `isEffective` — a divisor with all non-negative values
* `isQReduced` — q-reduced divisor satisfying Dhar's burning condition
* `divRank` — rank r(D): the largest k such that D - E ~ effective for all
  effective E of degree k, or -1 if D is not equivalent to any effective divisor

## Main results

* `canonical_degree` — deg(K_G) = 2g - 2
* `chipFire_preserves_degree` — chip-firing preserves divisor degree
* `laplacian_degree_zero` — principal divisors have degree zero
* `linEquiv_preserves_degree` — linear equivalence preserves degree
* `genus_complete_graph` — g(K_n) = (n-1)(n-2)/2
* `not_effective_of_neg_degree` — divisors of negative degree have rank -1
* `chipFire_eq_laplacian` — chip-firing equals adding a Laplacian

## References

* M. Baker, S. Norine, "Riemann-Roch and Abel-Jacobi theory on a finite graph"
-/

import Mathlib

open Finset SimpleGraph BigOperators

namespace BakerNorine

/-! ## Core Definitions -/

/-- A divisor on a graph with vertex set `V` is an integer-valued function on vertices. -/
def GraphDivisor (V : Type*) := V → ℤ

instance {V : Type*} : Add (GraphDivisor V) := ⟨fun D₁ D₂ v => D₁ v + D₂ v⟩
instance {V : Type*} : Sub (GraphDivisor V) := ⟨fun D₁ D₂ v => D₁ v - D₂ v⟩
instance {V : Type*} : Neg (GraphDivisor V) := ⟨fun D v => -D v⟩
instance {V : Type*} : Zero (GraphDivisor V) := ⟨fun _ => 0⟩

@[simp] lemma GraphDivisor.add_apply {V : Type*} (D₁ D₂ : GraphDivisor V) (v : V) :
    (D₁ + D₂) v = D₁ v + D₂ v := rfl
@[simp] lemma GraphDivisor.sub_apply {V : Type*} (D₁ D₂ : GraphDivisor V) (v : V) :
    (D₁ - D₂) v = D₁ v - D₂ v := rfl
@[simp] lemma GraphDivisor.neg_apply {V : Type*} (D : GraphDivisor V) (v : V) :
    (-D) v = -(D v) := rfl
@[simp] lemma GraphDivisor.zero_apply {V : Type*} (v : V) :
    (0 : GraphDivisor V) v = 0 := rfl

/-- The degree of a divisor is the sum of its values over all vertices. -/
def degDiv {V : Type*} [Fintype V] (D : GraphDivisor V) : ℤ :=
  ∑ v : V, D v

/-- A divisor is effective if all values are non-negative. -/
def isEffective {V : Type*} (D : GraphDivisor V) : Prop := ∀ v, 0 ≤ D v

/-- The genus of a graph: g = |E| - |V| + 1.
    For a connected graph, this equals the first Betti number (cycle rank). -/
noncomputable def graphGenus {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : ℤ :=
  G.edgeFinset.card - Fintype.card V + 1

/-- The canonical divisor K_G, where K_G(v) = deg(v) - 2.
    This is the graph-theoretic analogue of the canonical class on a curve. -/
def canonicalDivisor {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : GraphDivisor V :=
  fun v => (G.degree v : ℤ) - 2

/-- The Laplacian operator applied to a function f, giving a principal divisor.
    (Δf)(v) = Σ_{w ~ v} (f(v) - f(w)) = deg(v)·f(v) - Σ_{w~v} f(w)
    Note: sign convention where firing sends chips away from v. -/
def laplacianDiv {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (f : V → ℤ) : GraphDivisor V :=
  fun v => ∑ w ∈ G.neighborFinset v, (f v - f w)

/-- Chip-firing at vertex v: v sends one chip to each neighbor.
    D'(v) = D(v) - deg(v), D'(w) = D(w) + 1 for w ~ v, D'(w) = D(w) otherwise. -/
def chipFire {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V) (v : V) : GraphDivisor V :=
  fun w => if w = v then D v - G.degree v
           else if G.Adj v w then D w + 1
           else D w

/-- Two divisors are linearly equivalent if they differ by a Laplacian (principal divisor). -/
def linEquiv {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D₁ D₂ : GraphDivisor V) : Prop :=
  ∃ f : V → ℤ, ∀ v, D₂ v = D₁ v + laplacianDiv G f v

/-- A divisor D is q-reduced (with respect to a distinguished vertex q) if:
    1. D(v) ≥ 0 for all v ≠ q
    2. For every non-empty subset S ⊆ V \ {q}, there exists v ∈ S such that
       D(v) < outdeg_S(v), where outdeg_S(v) = |{w ∉ S : w ~ v}|. -/
def isQReduced {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (q : V) (D : GraphDivisor V) : Prop :=
  (∀ v, v ≠ q → 0 ≤ D v) ∧
  (∀ S : Finset V, q ∉ S → S.Nonempty →
    ∃ v ∈ S, D v < ↑((G.neighborFinset v \ S).card))

open Classical in
/-- The rank of a divisor D. We define it as -1 if D is not equivalent to any
    effective divisor, otherwise as the largest k ≤ deg(D) such that for every
    effective E of degree k, D - E is equivalent to an effective divisor. -/
noncomputable def divRank {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V) : ℤ :=
  if ¬ ∃ E : GraphDivisor V, linEquiv G D E ∧ isEffective E then -1
  else sSup {k : ℤ | k ≤ degDiv D ∧
    ∀ E : GraphDivisor V, isEffective E → degDiv E = k →
      ∃ F : GraphDivisor V, linEquiv G (D - E) F ∧ isEffective F}

/-! ## Fundamental Theorems -/

/-
**Laplacian has degree zero**: The sum of the Laplacian over all vertices is zero.
    This is the graph-theoretic analogue of ∫ Δf = 0.
-/
theorem laplacian_degree_zero {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (f : V → ℤ) :
    degDiv (laplacianDiv G f) = 0 := by
  have h_decomp : ∑ v : V, ∑ w ∈ G.neighborFinset v, (f v - f w) = ∑ v : V, (G.degree v : ℤ) * f v - ∑ w : V, f w * ∑ v ∈ G.neighborFinset w, 1 := by
    have h_neighbor_sum : ∀ v, ∑ w ∈ G.neighborFinset v, f w = ∑ w ∈ Finset.univ, f w * (if w ∈ G.neighborFinset v then 1 else 0) := by
      simp +decide [ Finset.sum_ite ];
      exact fun v => by congr; ext w; simp +decide [ SimpleGraph.adj_comm ] ;
    simp_all +decide [ Finset.sum_ite ];
    simp +decide [ Finset.sum_filter, SimpleGraph.degree, SimpleGraph.neighborFinset ];
    rw [ Finset.sum_comm ] ; simp +decide [ Finset.sum_ite, mul_comm ] ;
    simp +decide only [adj_comm];
  convert h_decomp using 3 ; simp +decide [ mul_comm ]

/-
**Chip-firing preserves degree**: The total number of chips is conserved
    under chip-firing. This is the discrete conservation law.
-/
theorem chipFire_preserves_degree {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V) (v : V) :
    degDiv (chipFire G D v) = degDiv D := by
  unfold degDiv chipFire; simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ] ;
  simp +decide [ Finset.filter_erase, Finset.filter_not, Finset.sum_add_distrib, SimpleGraph.degree, SimpleGraph.neighborFinset ];
  ring!

/-
**Linear equivalence preserves degree**: If D₁ ~ D₂ then deg(D₁) = deg(D₂).
-/
theorem linEquiv_preserves_degree {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] {D₁ D₂ : GraphDivisor V}
    (h : linEquiv G D₁ D₂) :
    degDiv D₁ = degDiv D₂ := by
  -- Unfold the definition of `linEquiv`, yielding a function `f` such that `D₂ = D₁ + laplacianDiv G f`.
  rcases h with ⟨f, hf⟩;
  have h_deg : degDiv D₂ = degDiv D₁ + degDiv (laplacianDiv G f) := by
    unfold degDiv;
    rw [ ← Finset.sum_add_distrib, funext hf ];
  rw [ h_deg, laplacian_degree_zero, add_zero ]

/-
**Riemann-Roch degree identity**: The degree of the canonical divisor
    equals 2g - 2, where g is the genus. This is the discrete Gauss-Bonnet
    identity and the starting point of Baker-Norine theory.
-/
theorem canonical_degree {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    degDiv (canonicalDivisor G) = 2 * graphGenus G - 2 := by
  unfold degDiv graphGenus canonicalDivisor;
  rw [ Finset.sum_sub_distrib, ← Nat.cast_sum, SimpleGraph.sum_degrees_eq_twice_card_edges ] ; norm_num ; ring

/-
**Genus of the complete graph**: g(K_n) = (n-1)(n-2)/2 for n ≥ 2.
    Since K_n has n(n-1)/2 edges and n vertices, g = n(n-1)/2 - n + 1 = (n-1)(n-2)/2.
-/
theorem genus_complete_graph (n : ℕ) (hn : 2 ≤ n) :
    graphGenus (⊤ : SimpleGraph (Fin n)) = ((n : ℤ) - 1) * ((n : ℤ) - 2) / 2 := by
  -- The cardinality of the edge set of the complete graph on n vertices is given by the binomial coefficient n choose 2.
  have h_card_edges : (⊤ : SimpleGraph (Fin n)).edgeFinset.card = Nat.choose n 2 := by
    simp +decide [ Finset.card_compl, Sym2.card, Nat.choose_two_right ];
    rw [ show ( Finset.filter ( Membership.mem Sym2.diagSet ) Finset.univ : Finset ( Sym2 ( Fin n ) ) ) = Finset.image ( fun x => Sym2.mk ( x, x ) ) Finset.univ from ?_, Finset.card_image_of_injective ];
    · cases n <;> norm_num [ Nat.mul_succ, Nat.add_mul_div_left ] ; ring_nf ; omega;
    · exact fun x y h => by simpa using h;
    · ext ⟨ x, y ⟩ ; aesop;
  unfold graphGenus; simp_all +decide [ Nat.choose_two_right ] ; ring;
  rcases n with ( _ | _ | n ) <;> norm_num at *;
  exact Eq.symm ( Int.ediv_eq_of_eq_mul_left ( by norm_num ) ( by linarith [ Int.ediv_mul_cancel ( show 2 ∣ ( n + 1 + 1 : ℤ ) * ( n + 1 ) from even_iff_two_dvd.mp ( by simp +arith +decide [ mul_add, parity_simps ] ) ) ] ) )

/-
**Chip-firing is adding a negative Laplacian indicator**.
    Firing vertex v is D - Δ(1_v), equivalently D + Δ(-1_v).
-/
theorem chipFire_eq_laplacian {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V) (v : V) :
    chipFire G D v = D + laplacianDiv G (fun w => if w = v then -1 else 0) := by
  funext w; simp +decide [ chipFire, laplacianDiv ] ;
  split_ifs <;> simp_all +decide [ SimpleGraph.adj_comm ];
  rw [ ‹w = v›, sub_eq_add_neg ]

/-
**Negative degree implies no effective representative**: If deg(D) < 0,
    then D cannot be linearly equivalent to any effective divisor.
-/
theorem not_effective_of_neg_degree {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V)
    (hdeg : degDiv D < 0) :
    ¬ ∃ E : GraphDivisor V, linEquiv G D E ∧ isEffective E := by
  rintro ⟨ E, hE₁, hE₂ ⟩;
  exact hdeg.not_ge ( linEquiv_preserves_degree G hE₁ ▸ Finset.sum_nonneg fun _ _ => hE₂ _ )

/-
**Linear equivalence is reflexive**.
-/
theorem linEquiv_refl {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V) :
    linEquiv G D D := by
  use 0; intro v; simp [laplacianDiv]

/-
**Linear equivalence is symmetric**.
-/
theorem linEquiv_symm {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] {D₁ D₂ : GraphDivisor V}
    (h : linEquiv G D₁ D₂) :
    linEquiv G D₂ D₁ := by
  obtain ⟨f, hf⟩ := h
  use -f
  intro v
  simp [hf, laplacianDiv];
  simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, SimpleGraph.degree, SimpleGraph.neighborFinset ] ; ring

/-
**Linear equivalence is transitive**.
-/
theorem linEquiv_trans {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] {D₁ D₂ D₃ : GraphDivisor V}
    (h₁ : linEquiv G D₁ D₂) (h₂ : linEquiv G D₂ D₃) :
    linEquiv G D₁ D₃ := by
  obtain ⟨ f, hf ⟩ := h₁
  obtain ⟨ g, hg ⟩ := h₂
  use fun v => f v + g v;
  simp +decide [ hf, hg, laplacianDiv ];
  simp +decide [ mul_add, Finset.sum_add_distrib ] ; intros ; ring

/-
**Canonical divisor of K_n**: On the complete graph K_n with n ≥ 2,
    the canonical divisor is constant: K(v) = n - 3 for all v.
-/
theorem canonical_complete {n : ℕ} (hn : 2 ≤ n) (v : Fin n) :
    canonicalDivisor (⊤ : SimpleGraph (Fin n)) v = (n : ℤ) - 3 := by
  unfold canonicalDivisor;
  simp +decide [Finset.card_erase_of_mem]
  omega

/-
**Effective divisor has non-negative degree**.
-/
theorem effective_degree_nonneg {V : Type*} [Fintype V] [DecidableEq V]
    (D : GraphDivisor V) (hD : isEffective D) :
    0 ≤ degDiv D := by
  exact Finset.sum_nonneg fun v _ => hD v

/-
**Chip-firing produces linearly equivalent divisors**.
-/
theorem chipFire_linEquiv {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V) (v : V) :
    linEquiv G D (chipFire G D v) := by
  unfold linEquiv chipFire ;
  refine' ⟨ fun w => if w = v then -1 else 0, fun w => _ ⟩ ; simp +decide [ laplacianDiv ];
  grind +suggestions

/-
**Laplacian of constant function is zero**.
-/
theorem laplacianDiv_const {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (c : ℤ) :
    laplacianDiv G (fun _ => c) = 0 := by
  unfold laplacianDiv; aesop

/-
**Laplacian is additive**: Δ(f + g) = Δf + Δg.
-/
theorem laplacianDiv_add {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (f g : V → ℤ) :
    laplacianDiv G (f + g) = laplacianDiv G f + laplacianDiv G g := by
  funext v; simp +decide [ laplacianDiv ] ; ring;
  rw [ Finset.sum_add_distrib ] ; ring;

end BakerNorine