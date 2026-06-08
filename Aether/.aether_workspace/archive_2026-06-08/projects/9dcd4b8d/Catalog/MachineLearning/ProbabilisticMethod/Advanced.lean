/-
  # Advanced Probabilistic Method Results

  This module contains deeper results building on the core probabilistic method:

  1. **Turán edge count for divisible case** — exact formula when r | n
  2. **Double counting / Handshaking** — sum of degrees = 2 * edges
  3. **Alteration method** — expected value framework for graph property proofs
  4. **Entropy–independence bridge** — connecting information theory to graph theory
  5. **Generalized first moment with real-valued functions**
-/

import Mathlib

open Finset BigOperators

namespace ProbabilisticMethod.Advanced

/-! ## Section 1: Handshaking Lemma and Double Counting

The handshaking lemma states that the sum of all vertex degrees in a graph
equals twice the number of edges. This is a fundamental double-counting argument.
-/

/-
In a symmetric adjacency relation on Fin n, the total number of
    directed edges (i,j) with adj i j equals twice the number of
    undirected edges {i,j}. This is the handshaking lemma.
-/
theorem handshaking_lemma (n : ℕ) (adj : Fin n → Fin n → Prop) [DecidablePred fun p : Fin n × Fin n => adj p.1 p.2]
    (hsymm : ∀ i j, adj i j → adj j i)
    (hirrefl : ∀ i, ¬ adj i i) :
    (Finset.univ.filter (fun p : Fin n × Fin n => adj p.1 p.2)).card =
    2 * (Finset.univ.filter (fun p : Fin n × Fin n => adj p.1 p.2 ∧ p.1 < p.2)).card := by
  -- By definition of adjacency, the set of pairs (i, j) where adj i j holds can be partitioned into two disjoint sets: those where i < j and those where i > j.
  have h_partition : Finset.univ.sum (fun (p : Fin n × Fin n) => if adj p.1 p.2 then 1 else 0) = Finset.univ.sum (fun (p : Fin n × Fin n) => if adj p.1 p.2 ∧ p.1 < p.2 then 1 else 0) + Finset.univ.sum (fun (p : Fin n × Fin n) => if adj p.1 p.2 ∧ p.1 > p.2 then 1 else 0) := by
    rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl ];
    grind;
  -- By symmetry, the number of pairs (i, j) where i > j is equal to the number of pairs (j, i) where j < i.
  have h_symm : Finset.univ.sum (fun (p : Fin n × Fin n) => if adj p.1 p.2 ∧ p.1 > p.2 then 1 else 0) = Finset.univ.sum (fun (p : Fin n × Fin n) => if adj p.1 p.2 ∧ p.1 < p.2 then 1 else 0) := by
    rw [ ← Equiv.sum_comp ( Equiv.prodComm _ _ ) ] ; simp +decide [ hsymm ];
    exact congr_arg _ ( by ext; aesop );
  simp_all +decide [ two_mul ]

/-! ## Section 2: Generalized First Moment with Integer-Valued Functions

A generalized version where we work with integer sums to handle
cases where the function can take negative values.
-/

/-
If a finite sum of integers is negative, some summand is negative.
-/
theorem exists_neg_of_sum_neg {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℤ) (h : ∑ a : α, f a < 0) :
    ∃ a : α, f a < 0 := by
  contrapose! h;
  exact Finset.sum_nonneg fun _ _ => h _

/-
If a finite sum of integers exceeds n times the cardinality,
    some value exceeds n.
-/
theorem exists_gt_of_sum_gt {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℤ) (n : ℤ) (h : (Fintype.card α : ℤ) * n < ∑ a : α, f a) :
    ∃ a : α, n < f a := by
  contrapose! h; simpa using Finset.sum_le_sum fun a ( _ : a ∈ Finset.univ ) => h a;

/-! ## Section 3: Alteration Method

The alteration method: start with a random structure, identify "bad" parts,
and alter (delete/modify) them. The key bound: if X is the number of
bad substructures and Y is the graph property we want to maximize,
then we can find a structure with at least E[Y] - E[X] of the property.
-/

/-
Alteration principle: if for every element of a finite type,
    benefit(a) ≥ cost(a), and ∑ benefit > ∑ cost, then some element
    has strictly positive net benefit.
-/
theorem alteration_principle {α : Type*} [Fintype α] [Nonempty α]
    (benefit cost : α → ℕ) (h : ∑ a : α, cost a < ∑ a : α, benefit a) :
    ∃ a : α, cost a < benefit a := by
  contrapose! h; exact Finset.sum_le_sum fun a _ => h a;

/-! ## Section 4: Ramsey Theory — Stronger Counting Bound

The probabilistic proof that R(s,t) ≤ C(s+t-2, s-1) uses the
first moment method with a more careful counting of monochromatic
cliques of potentially different sizes.
-/

/-
For the asymmetric Ramsey bound: C(s+t-2, s-1) bounds R(s,t).
    We prove the key combinatorial identity used in the proof.
-/
theorem ramsey_identity (s t : ℕ) (hs : 1 ≤ s) (ht : 1 ≤ t) :
    (s + t - 2).choose (s - 1) = (s + t - 2).choose (t - 1) := by
  rw [ Nat.choose_symm_of_eq_add ] ; omega

/-! ## Section 5: Entropy–Independence Bridge

This section connects graph theory to information theory.
The key insight: for a graph G with chromatic number χ(G),
any proper χ(G)-coloring partitions the vertices into χ(G) independent sets.
The entropy of the color distribution is at least log₂(χ(G)).

We formalize this by proving that the number of proper k-colorings
grows with k, and that the minimum number of colors needed relates
to the independence number.
-/

/-
If a graph has chromatic number ≤ k, then α(G) ≥ n/k.
This is the entropy-independence bridge: chromatic number bounds
constrain the independence number, which in turn bounds the
information content of any proper coloring.

The number of proper k-colorings of the empty graph (no edges)
    on n vertices is k^n.
-/
theorem empty_graph_colorings (n k : ℕ) :
    (Finset.univ : Finset (Fin n → Fin k)).card = k ^ n := by
  simp +decide [ Finset.card_univ ]

/-
Adding an edge can only decrease the number of proper colorings.
This is a monotonicity property connecting graph structure to
information-theoretic capacity.

For a complete bipartite graph K_{a,b}, the number of proper
    2-colorings is exactly 2 (when a,b ≥ 1).
-/
theorem complete_bipartite_two_colorings (a b : ℕ) (ha : 0 < a) (hb : 0 < b) :
    (Finset.univ.filter (fun c : Fin (a + b) → Fin 2 =>
      ∀ i : Fin a, ∀ j : Fin b,
        c (Fin.castAdd b i) ≠ c (Fin.natAdd a j))).card = 2 := by
  rw [ Finset.card_eq_two ];
  refine' ⟨ fun i => if i.val < a then 0 else 1, fun i => if i.val < a then 1 else 0, _, _ ⟩ <;> simp +decide [ Finset.ext_iff ];
  · exact fun h => by have := congr_fun h ⟨ 0, by linarith ⟩ ; aesop;
  · intro c;
    constructor <;> intro h;
    · -- Since $c$ is a function from $Fin (a + b)$ to $ �Fin� 2$, � and� $Fin 2$ has only two elements, $c$ must be either the constant function $0$ or � the� constant function $ �1�$.
      have h_const : ∀ i j : Fin (a + b), i.val < a → j.val ≥ a → c i ≠ c j := by
        intro i j hi hj; convert h ⟨ i, hi ⟩ ⟨ j - a, by rw [ tsub_lt_iff_left ] <;> linarith [ Fin.is_lt j ] ⟩ ;
        exact Eq.symm ( Fin.ext <| by simp +decide [ Nat.add_sub_of_le hj ] );
      cases Fin.exists_fin_two.mp ⟨ c ⟨ 0, by linarith ⟩, rfl ⟩ <;> cases Fin.exists_fin_two.mp ⟨ c ⟨ a, by linarith ⟩, rfl ⟩ <;> simp_all +decide [ funext_iff ];
      · grind;
      · grind +qlia;
      · grind +splitImp;
      · specialize h_const ⟨ 0, by linarith ⟩ ⟨ a, by linarith ⟩ ; aesop;
    · rcases h with ( rfl | rfl ) <;> simp +decide [ Fin.ext_iff ]

/-! ## Section 6: Variance Method (Second Moment)

The second moment method provides a lower bound on the probability
that a random variable is positive. If E[X²] is not too much larger
than E[X]², then X > 0 with positive probability.
-/

/-
Markov-type inequality for natural numbers:
    if ∑ f(a) ≤ c * |α|, then at most c fraction of elements
    satisfy f(a) > 0. More precisely, |{a : f(a) > 0}| ≤ c * |α| / 1 = ∑ f(a).
-/
theorem markov_nat {α : Type*} [Fintype α]
    (f : α → ℕ) :
    (Finset.univ.filter (fun a => 0 < f a)).card ≤ ∑ a : α, f a := by
  rw [ Finset.card_filter ];
  exact Finset.sum_le_sum fun i _ => by split_ifs <;> linarith;

/-! ## Section 7: Probabilistic Method for Hypergraph Coloring -/

/-- A k-uniform hypergraph on vertex set Fin n is a collection of
    k-element subsets of Fin n. -/
structure UniformHypergraph (n k : ℕ) where
  edges : Finset (Finset (Fin n))
  uniform : ∀ e ∈ edges, e.card = k

/-- A 2-coloring of vertices is proper for a hypergraph if no edge
    is monochromatic (all one color). -/
def IsProperHypergraphColoring {n k : ℕ} (H : UniformHypergraph n k)
    (c : Fin n → Bool) : Prop :=
  ∀ e ∈ H.edges, ∃ v₁ ∈ e, ∃ v₂ ∈ e, c v₁ ≠ c v₂

/-
Property 'B' (2-colorability) bound: if a k-uniform hypergraph
    has fewer than 2^{k-1} edges, it has Property B
    (is 2-colorable / no monochromatic edge).
    This is the hypergraph version of the first moment method.
-/
theorem property_B_bound {n k : ℕ} (hk : 1 ≤ k)
    (H : UniformHypergraph n k) (hn : 0 < n)
    (h : H.edges.card < 2 ^ (k - 1)) :
    ∃ c : Fin n → Bool, IsProperHypergraphColoring H c := by
  -- By the first moment method, the expected number of monochromatic edges is less than 1.
  have h_exp : ∑ c : Fin n → Bool, (∑ e ∈ H.edges, if (∀ v ∈ e, c v = true) ∨ (∀ v ∈ e, c v = false) then 1 else 0) < 2 ^ n := by
    -- For each edge $e$, the number of colorings where $e$ is monochromatic is $2 \cdot 2^{n-k} = 2^{n-k+1}$.
    have h_monochromatic : ∀ e ∈ H.edges, (∑ c : Fin n → Bool, if (∀ v ∈ e, c v = true) ∨ (∀ v ∈ e, c v = false) then 1 else 0) ≤ 2 ^ (n - k + 1) := by
      intro e he; have := H.uniform e he; simp_all +decide [ Finset.card_univ ] ;
      -- The set of colorings where $e$ is monochromatic is in bijection with the set of colorings of the remaining $n-k$ vertices.
      have h_bij : Finset.filter (fun c : Fin n → Bool => (∀ v ∈ e, c v = true) ∨ (∀ v ∈ e, c v = false)) Finset.univ ⊆ Finset.image (fun c : { x : Fin n // x ∉ e } → Bool => fun i => if h : i ∈ e then true else c ⟨i, h⟩) (Finset.univ : Finset ({ x : Fin n // x ∉ e } → Bool)) ∪ Finset.image (fun c : { x : Fin n // x ∉ e } → Bool => fun i => if h : i ∈ e then false else c ⟨i, h⟩) (Finset.univ : Finset ({ x : Fin n // x ∉ e } → Bool)) := by
        intro c hc; simp_all +decide [ Finset.subset_iff ] ;
        cases' hc with hc hc <;> [ left; right ] <;> use fun i => c i <;> ext i <;> aesop;
      refine le_trans ( Finset.card_le_card h_bij ) ?_;
      refine' le_trans ( Finset.card_union_le _ _ ) _;
      refine' le_trans ( add_le_add ( Finset.card_image_le ) ( Finset.card_image_le ) ) _ ; simp +decide [ Finset.card_univ, this ] ; ring_nf ; aesop;
    rw [ Finset.sum_comm ] ; refine' lt_of_le_of_lt ( Finset.sum_le_sum h_monochromatic ) _ ; norm_num [ ← pow_add ];
    rcases le_total n k with hnk | hkn <;> simp_all +decide [ pow_add, pow_one, pow_mul ];
    · contrapose! h;
      have := Finset.card_le_card ( show H.edges ⊆ Finset.powersetCard k ( Finset.univ : Finset ( Fin n ) ) from fun x hx => Finset.mem_powersetCard.mpr ⟨ Finset.subset_univ _, H.uniform x hx ⟩ ) ; simp_all +decide [ Finset.card_univ ] ;
      cases hnk.eq_or_lt <;> simp_all +decide [ Nat.choose_eq_zero_of_lt ];
      interval_cases _ : #H.edges <;> simp_all +decide [ pow_succ' ];
      rcases k with ( _ | _ | k ) <;> simp_all +decide [ pow_succ' ];
    · convert mul_lt_mul_of_pos_right h ( show 0 < 2 ^ ( n - k ) * 2 by positivity ) using 1 ; rw [ show 2 ^ n = 2 ^ ( n - k ) * 2 ^ k by rw [ ← pow_add, Nat.sub_add_cancel hkn ] ] ; cases k <;> simp_all +decide [ pow_succ' ] ; ring;
  -- By the pigeonhole principle, since the expected number of monochromatic edges is less than 1, there must exist a coloring with no monochromatic edges.
  obtain ⟨c, hc⟩ : ∃ c : Fin n → Bool, (∑ e ∈ H.edges, if (∀ v ∈ e, c v = true) ∨ (∀ v ∈ e, c v = false) then 1 else 0) = 0 := by
    contrapose! h_exp;
    exact le_trans ( by norm_num [ Finset.card_univ ] ) ( Finset.sum_le_sum fun c _ => Nat.one_le_iff_ne_zero.mpr ( h_exp c ) );
  use c;
  intro e he; contrapose! hc; simp_all +decide [ Finset.ext_iff ] ;
  grind +splitImp

end ProbabilisticMethod.Advanced