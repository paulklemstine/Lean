/-
# Graph Riemann-Roch: Chip-Firing and the Canonical Divisor

Baker-Norine (2007) established a graph-theoretic analogue of the classical
Riemann-Roch theorem. This file formalizes:
- Divisors on finite graphs (chip configurations)
- The canonical divisor K_G and graph genus
- Chip-firing (the graph Laplacian action)
- Key structural theorems: degree conservation, canonical degree = 2g-2,
  complete graph genus formula, and the Riemann-Roch degree identity.
-/

import Mathlib

open Finset BigOperators

namespace GraphRiemannRoch

/-! ## Core Definitions -/

/-- A divisor on a graph with vertex type `V` is a function assigning
    an integer (number of chips) to each vertex. -/
abbrev Divisor (V : Type*) := V → ℤ

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The degree of a divisor is the total number of chips. -/
def divisorDeg (D : Divisor V) : ℤ :=
  ∑ v : V, D v

/-- A divisor is effective if every vertex has a nonneg number of chips. -/
def Divisor.effective (D : Divisor V) : Prop :=
  ∀ v, 0 ≤ D v

instance : Add (Divisor V) := ⟨fun D E v => D v + E v⟩
instance : Sub (Divisor V) := ⟨fun D E v => D v - E v⟩
instance : Neg (Divisor V) := ⟨fun D v => -D v⟩
instance : Zero (Divisor V) := ⟨fun _ => 0⟩

@[simp] lemma divisor_add_apply (D E : Divisor V) (v : V) : (D + E) v = D v + E v := rfl
@[simp] lemma divisor_sub_apply (D E : Divisor V) (v : V) : (D - E) v = D v - E v := rfl
@[simp] lemma divisor_neg_apply (D : Divisor V) (v : V) : (-D) v = -D v := rfl
@[simp] lemma divisor_zero_apply (v : V) : (0 : Divisor V) v = 0 := rfl

omit [DecidableEq V] in
/-- Degree is additive. -/
theorem divisorDeg_add (D E : Divisor V) :
    divisorDeg (D + E) = divisorDeg D + divisorDeg E := by
  simp [divisorDeg, Finset.sum_add_distrib]

omit [DecidableEq V] in
@[simp] theorem divisorDeg_zero : divisorDeg (0 : Divisor V) = 0 := by
  simp [divisorDeg]

omit [DecidableEq V] in
/-- Degree of the negative of a divisor. -/
theorem divisorDeg_neg (D : Divisor V) : divisorDeg (-D) = -divisorDeg D := by
  simp [divisorDeg, Finset.sum_neg_distrib]

/-- Degree of difference of divisors. -/
theorem divisorDeg_sub (D E : Divisor V) :
    divisorDeg (D - E) = divisorDeg D - divisorDeg E := by
  simp [divisorDeg, Finset.sum_sub_distrib]

/-! ## Graph genus and canonical divisor -/

variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The genus (cyclomatic number) of a finite graph: g(G) = |E| - |V| + 1. -/
def graphGenus : ℤ :=
  (G.edgeFinset.card : ℤ) - (Fintype.card V : ℤ) + 1

/-- The canonical divisor K_G assigns (deg(v) - 2) chips to each vertex v. -/
def canonicalDivisor : Divisor V :=
  fun v => (G.degree v : ℤ) - 2

/-! ## Chip-firing -/

/-- Edge weight: 1 if adjacent, 0 otherwise. -/
def edgeWeight (u w : V) : ℤ :=
  if G.Adj u w then 1 else 0

/-- Chip-firing at vertex `v`: sends one chip along each incident edge. -/
def chipFire (D : Divisor V) (v : V) : Divisor V :=
  fun w =>
    if w = v then D v - (G.degree v : ℤ)
    else D w + edgeWeight G v w

/-- The Laplacian vector for firing vertex `v`. -/
def laplacianVec (v : V) : Divisor V :=
  fun w =>
    if w = v then -(G.degree v : ℤ)
    else edgeWeight G v w

/-- Two divisors are linearly equivalent if their difference is in the
    image of the Laplacian. -/
def linearEquiv (D D' : Divisor V) : Prop :=
  ∃ f : V → ℤ, ∀ w, D' w - D w = ∑ v, f v * laplacianVec G v w

/-! ## Main Theorems -/

/-
**Laplacian row sum is zero**: The sum of the Laplacian vector for any
    vertex is zero. This encodes chip conservation.
-/
theorem laplacianVec_sum (v : V) :
    ∑ w : V, laplacianVec G v w = 0 := by
      unfold laplacianVec;
      simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ];
      simp +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset_def, edgeWeight ]

/-
**Chip-firing preserves degree**: The fundamental conservation law.
-/
theorem chipFire_preserves_degree (D : Divisor V) (v : V) :
    divisorDeg (chipFire G D v) = divisorDeg D := by
      unfold divisorDeg chipFire;
      simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', edgeWeight ];
      simp +decide [ Finset.sum_add_distrib, SimpleGraph.degree, SimpleGraph.neighborFinset_def ]

/-
**Canonical divisor degree theorem**: deg(K_G) = 2g(G) − 2.
    Uses the handshaking lemma: ∑_v deg(v) = 2|E|.
-/
theorem canonical_divisor_degree :
    divisorDeg (canonicalDivisor G) = 2 * graphGenus G - 2 := by
      unfold divisorDeg canonicalDivisor graphGenus;
      simp +decide [ mul_add, mul_sub, Finset.sum_sub_distrib, SimpleGraph.sum_degrees_eq_twice_card_edges ] ; ring;
      rw [ ← Nat.cast_sum, SimpleGraph.sum_degrees_eq_twice_card_edges ] ; ring;
      grobner

/-
**Riemann-Roch degree identity for K_G**: When D = K_G,
    deg(K_G) + 1 - g(G) = g(G) - 1.
-/
theorem riemannRoch_canonical_degree_identity :
    divisorDeg (canonicalDivisor G) + 1 - graphGenus G = graphGenus G - 1 := by
      rw [ GraphRiemannRoch.canonical_divisor_degree ] ; ring

/-
**Complementary divisor degree**: deg(K_G - D) = 2g - 2 - deg(D).
-/
theorem complementary_divisor_degree (D : Divisor V) :
    divisorDeg (canonicalDivisor G - D) = 2 * graphGenus G - 2 - divisorDeg D := by
      rw [ ← canonical_divisor_degree, divisorDeg_sub ]

/-
**Linear equivalence preserves degree**.
-/
theorem linearEquiv_preserves_degree (D D' : Divisor V)
    (h : linearEquiv G D D') : divisorDeg D = divisorDeg D' := by
      obtain ⟨ f, hf ⟩ := h;
      -- From h, get f such that D' w - D w = ∑_v f v * laplacianVec G v w for all w. Sum over all w: ∑_w (D' w - D w) = ∑_w ∑_v f v * laplacianVec G v w = ∑_v f v * (∑_w laplacianVec G v w) = ∑_v f v * 0 = 0 (using laplacianVec_sum). So divisorDeg D' - divisorDeg D = 0.
      have h_sum : ∑ w : V, (D' w - D w) = 0 := by
        rw [ Finset.sum_congr rfl fun w hw => hf w, Finset.sum_comm ];
        simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, laplacianVec_sum ];
      unfold divisorDeg; simp_all +decide [ sub_eq_iff_eq_add ] ;
      simp +decide [ Finset.sum_add_distrib, h_sum ]

/-! ## Complete graph section -/

section CompleteGraph

variable {n : ℕ}

/-
In K_n, every vertex has degree n - 1.
-/
theorem complete_graph_degree (hn : 1 ≤ n) (v : Fin n) :
    (⊤ : SimpleGraph (Fin n)).degree v = n - 1 := by
      simp +decide [ Finset.filter_ne, Finset.card_sdiff ]

/-
K_n has n(n-1)/2 edges.
-/
theorem complete_graph_edge_count (hn : 1 ≤ n) :
    (⊤ : SimpleGraph (Fin n)).edgeFinset.card = n * (n - 1) / 2 := by
      convert Finset.card_powersetCard 2 ( Finset.univ : Finset ( Fin n ) ) using 1;
      · refine' Finset.card_bij _ _ _ _;
        use fun a ha => Finset.univ.filter fun x => x ∈ a;
        · simp +decide [ Finset.card_eq_two ];
          rintro ⟨ x, y ⟩ hxy; use x, y; aesop;
        · simp +contextual [ Finset.ext_iff, Set.ext_iff ];
          intro a₁ ha₁ a₂ ha₂ h; ext x; specialize h x; aesop;
        · simp +decide [ Finset.mem_powersetCard ];
          intro b hb; obtain ⟨ x, y, hxy ⟩ := Finset.card_eq_two.mp hb; use Sym2.mk ( x, y ) ; aesop;
      · simp +decide [ Nat.choose_two_right ]

/-
**Genus of K_n**: g(K_n) = (n-1)(n-2)/2.
-/
theorem complete_graph_genus (hn : 2 ≤ n) :
    graphGenus (⊤ : SimpleGraph (Fin n)) = ((n - 1 : ℤ) * (n - 2)) / 2 := by
      unfold graphGenus;
      -- The number of edges in a complete graph $K_n$ is given by the combination formula $C(n, 2) = \frac{n(n-1)}{2}$.
      have h_edges : (⊤ : SimpleGraph (Fin n)).edgeFinset.card = n * (n - 1) / 2 := by
        convert complete_graph_edge_count ( by linarith : 1 ≤ n ) using 1;
      rcases n with ( _ | _ | n ) <;> simp_all +decide;
      grind +splitIndPred

/-
The canonical divisor of K_n is uniform: each vertex gets (n-3) chips.
-/
theorem canonical_complete_uniform (v : Fin n) (hn : 1 ≤ n) :
    canonicalDivisor (⊤ : SimpleGraph (Fin n)) v = (n : ℤ) - 3 := by
      rcases n with ( _ | _ | n ) <;> simp_all +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset ];
      · decide +revert;
      · convert congr_arg ( fun x : ℕ => ( x : ℤ ) - 2 ) ( complete_graph_degree ( n := n + 2 ) ( by linarith ) v ) using 1 ; norm_num ; ring!

/-
deg(K_{K_n}) = n(n-3).
-/
theorem canonical_complete_degree (hn : 2 ≤ n) :
    divisorDeg (canonicalDivisor (⊤ : SimpleGraph (Fin n))) = (n : ℤ) * ((n : ℤ) - 3) := by
      unfold divisorDeg; simp +decide [ canonicalDivisor ] ; ring;
      rw [ Nat.cast_sub ] <;> push_cast <;> linarith

/-
On K_n, chip-firing sends one chip to each other vertex.
-/
theorem chipFire_complete_sends_one (hn : 1 ≤ n)
    (D : Divisor (Fin n)) (v w : Fin n) (hvw : v ≠ w) :
    chipFire (⊤ : SimpleGraph (Fin n)) D v w = D w + 1 := by
      unfold chipFire edgeWeight;
      aesop

/-
On K_n, the fired vertex loses (n-1) chips.
-/
theorem chipFire_complete_loses (hn : 1 ≤ n)
    (D : Divisor (Fin n)) (v : Fin n) :
    chipFire (⊤ : SimpleGraph (Fin n)) D v v = D v - (n - 1 : ℤ) := by
      unfold chipFire; aesop;

end CompleteGraph

end GraphRiemannRoch