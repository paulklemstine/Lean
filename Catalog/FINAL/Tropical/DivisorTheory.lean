/-
# Tropical Divisor Theory on Trees

This file formalizes the foundations of tropical divisor theory on finite trees,
establishing the combinatorial core of tropical Picard theory.

## Main results

* `principal_degree_zero` : Principal divisors have degree zero.
* `linear_equiv_preserves_degree` : Linear equivalence preserves divisor degree.
* `exists_leaf_of_tree` : Every finite tree with more than one vertex has a leaf.
* `degree_zero_principal_tree` : On a tree, every degree-zero divisor is principal.
* `tree_divisor_equiv_singleton` : Every divisor on a tree is linearly equivalent
  to a divisor concentrated at a single vertex.
* `tree_degree_nonneg_has_effective_representative` : On a tree, every divisor of
  nonneg degree has an effective representative.

## Keywords

tropical geometry, divisors on graphs, chip-firing, graph Laplacian,
Baker–Norine, Riemann–Roch, Jacobian of a graph, critical group,
genus-zero tropical curves, discrete Hodge theory
-/

import Mathlib

open Finset SimpleGraph BigOperators

/-! ## Basic Definitions -/

/-- A divisor on a graph with vertex set `V` is an integer-valued function on vertices. -/
def Divisor (V : Type*) := V → ℤ

instance {V : Type*} : Add (Divisor V) := ⟨fun D₁ D₂ v => D₁ v + D₂ v⟩
instance {V : Type*} : Sub (Divisor V) := ⟨fun D₁ D₂ v => D₁ v - D₂ v⟩
instance {V : Type*} : Neg (Divisor V) := ⟨fun D v => -D v⟩
instance {V : Type*} : Zero (Divisor V) := ⟨fun _ => 0⟩

@[simp] lemma Divisor.add_apply {V : Type*} (D₁ D₂ : Divisor V) (v : V) :
    (D₁ + D₂) v = D₁ v + D₂ v := rfl
@[simp] lemma Divisor.sub_apply {V : Type*} (D₁ D₂ : Divisor V) (v : V) :
    (D₁ - D₂) v = D₁ v - D₂ v := rfl
@[simp] lemma Divisor.neg_apply {V : Type*} (D : Divisor V) (v : V) :
    (-D) v = -(D v) := rfl
@[simp] lemma Divisor.zero_apply {V : Type*} (v : V) :
    (0 : Divisor V) v = 0 := rfl

/-- The degree of a divisor is the sum of its values over all vertices. -/
def divisorDegree {V : Type*} [Fintype V] (D : Divisor V) : ℤ :=
  ∑ v, D v

/-- The principal divisor associated to a function `f`, the graph Laplacian of `f`. -/
def PrincipalDivisor {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (f : V → ℤ) : Divisor V :=
  fun v => ∑ w ∈ G.neighborFinset v, (f w - f v)

/-- Two divisors are linearly equivalent if they differ by a principal divisor. -/
def LinearEquivalent {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D₁ D₂ : Divisor V) : Prop :=
  ∃ f : V → ℤ, ∀ v, D₂ v = D₁ v + PrincipalDivisor G f v

/-- A divisor is effective if all its values are nonneg. -/
def Effective {V : Type*} (D : Divisor V) : Prop := ∀ v, 0 ≤ D v

/-! ## Algebraic properties -/

lemma principal_add {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (f g : V → ℤ) :
    PrincipalDivisor G (f + g) = PrincipalDivisor G f + PrincipalDivisor G g :=
  funext fun v => by simp +decide [ PrincipalDivisor, Finset.sum_add_distrib ] ; ring

lemma principal_const {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (c : ℤ) :
    PrincipalDivisor G (fun _ => c) = 0 := by
  funext v; simp [PrincipalDivisor]

lemma linear_equiv_refl {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : Divisor V) :
    LinearEquivalent G D D :=
  ⟨fun _ => 0, fun _ => by simp +decide [PrincipalDivisor]⟩

lemma linear_equiv_trans {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] {D₁ D₂ D₃ : Divisor V}
    (h₁ : LinearEquivalent G D₁ D₂) (h₂ : LinearEquivalent G D₂ D₃) :
    LinearEquivalent G D₁ D₃ := by
  obtain ⟨f, hf⟩ := h₁; obtain ⟨g, hg⟩ := h₂
  use f + g; intro v; rw [hg, hf]; simp [PrincipalDivisor]; rw [Finset.sum_add_distrib]; ring

/-! ## Principal divisors have degree zero -/

theorem principal_degree_zero
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (f : V → ℤ) :
    divisorDegree (PrincipalDivisor G f) = 0 := by
  unfold divisorDegree PrincipalDivisor
  simp +decide only [neighborFinset_eq_filter, sum_filter]
  simp +decide [Finset.sum_ite, SimpleGraph.adj_comm]
  have h_interchange : ∑ x, ∑ x_1 ∈ Finset.filter (fun x_1 => G.Adj x x_1) Finset.univ, f x_1 =
      ∑ x_1, ∑ x ∈ Finset.filter (fun x => G.Adj x x_1) Finset.univ, f x_1 := by
    rw [Finset.sum_sigma', Finset.sum_sigma']
    refine' Finset.sum_bij (fun x _ => ⟨x.snd, x.fst⟩) _ _ _ _ <;>
      simp +decide [SimpleGraph.adj_comm]
    · grind +qlia
    · exact fun b hb => ⟨_, _, hb.symm, rfl⟩
  simp_all +decide [SimpleGraph.adj_comm]

theorem linear_equiv_preserves_degree
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] {D E : Divisor V}
    (h : LinearEquivalent G D E) :
    divisorDegree D = divisorDegree E := by
  obtain ⟨f, hf⟩ := h
  unfold divisorDegree
  have := principal_degree_zero G f
  simp_all +decide [Finset.sum_add_distrib]
  exact this

/-! ## Tree structure lemmas -/

theorem exists_leaf_of_tree
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected) (htree : G.IsAcyclic)
    (hcard : 1 < Fintype.card V) :
    ∃ v : V, (G.neighborFinset v).card = 1 := by
  have h_edges : G.edgeFinset.card = Fintype.card V - 1 := by
    have := IsTree.card_edgeFinset (show G.IsTree from ⟨hconn, htree⟩)
    exact eq_tsub_of_add_eq this
  have h_sum_deg : ∑ v : V, G.degree v = 2 * (Fintype.card V - 1) := by
    rw [← h_edges, SimpleGraph.sum_degrees_eq_twice_card_edges]
  by_contra h_contra; push_neg at h_contra
  have h_deg_ge_two : ∀ v : V, 2 ≤ G.degree v := by
    intro v
    by_cases hv : G.degree v = 00
    · have := hconn v
      simp_all +decide [SimpleGraph.degree, SimpleGraph.neighborFinset]
      obtain ⟨w, hw⟩ := Fintype.exists_ne_of_one_lt_card hcard v
      specialize this w; rcases this with ⟨p⟩; induction p <;> aesop
    · exact Nat.lt_of_le_of_ne (Nat.pos_of_ne_zero hv) (Ne.symm (h_contra v))
  exact absurd (Finset.sum_le_sum fun v (_ : v ∈ Finset.univ) => h_deg_ge_two v)
    (by norm_num; linarith [Nat.sub_add_cancel hcard.le])

/-! ## Leaf-firing lemmas -/

theorem fire_leaf_moves_mass
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    {ℓ n : V} (hne : ℓ ≠ n)
    (hleaf : G.neighborFinset ℓ = {n}) (k : ℤ) :
    LinearEquivalent G
      (fun w => if w = ℓ then k else 0)
      (fun w => if w = n then k else 0) := by
  refine' ⟨fun w => if w = ℓ then k else 0, _⟩
  unfold PrincipalDivisor; simp +decide [hne, hleaf]
  intro v; split_ifs <;> simp_all +decide [SimpleGraph.adj_comm]
  · rw [Finset.eq_singleton_iff_unique_mem] at hleaf; aesop
  · simp_all +decide [SimpleGraph.neighborFinset, SimpleGraph.degree]
  · replace hleaf := Finset.ext_iff.mp hleaf v; simp_all +decide [SimpleGraph.adj_comm]

theorem move_leaf_chips
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    {ℓ n : V} (hne : ℓ ≠ n)
    (hleaf : G.neighborFinset ℓ = {n})
    (D : Divisor V) :
    LinearEquivalent G D
      (fun w => if w = ℓ then 0 else if w = n then D n + D ℓ else D w) := by
  refine' ⟨fun w => if w = ℓ then D ℓ else 0, _⟩
  intro v; unfold PrincipalDivisor
  by_cases hv₁ : v = ℓ <;> by_cases hv₂ : v = n <;>
    simp_all +decide [SimpleGraph.neighborFinset]
  · replace hleaf := Finset.ext_iff.mp hleaf n; simp_all +decide [SimpleGraph.adj_comm]
  · simp_all +decide [Finset.ext_iff, Set.ext_iff]
    exact fun h => False.elim (hv₂ (hleaf v |>.1 h.symm))

/-! ## Tree deletion lemmas -/

/-
A walk in G that stays within a set S induces reachability in the induced subgraph.
-/
lemma walk_in_set_gives_reachable
    {V : Type*} [DecidableEq V]
    (G : SimpleGraph V)
    {S : Set V} {u v : V} (hu : u ∈ S) (hv : v ∈ S)
    (p : G.Walk u v) (hp : ∀ w ∈ p.support, w ∈ S) :
    (G.induce S).Reachable ⟨u, hu⟩ ⟨v, hv⟩ := by
  induction' p with w p ih;
  · exact SimpleGraph.Reachable.refl _;
  · simp_all +decide [ SimpleGraph.Walk.support_cons ];
    rename_i h₁ h₂ h₃₄;
    exact SimpleGraph.Reachable.trans ( SimpleGraph.Adj.reachable <| by aesop ) h₃₄

/-
In a connected graph where ℓ has exactly one neighbor n, any walk between
    vertices ≠ ℓ can be shortened to avoid ℓ.
-/
lemma walk_avoids_degree_one_vertex
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    {ℓ n : V} (hne : ℓ ≠ n)
    (hleaf : G.neighborFinset ℓ = {n})
    {u v : V} (hu : u ≠ ℓ) (hv : v ≠ ℓ)
    (p : G.Walk u v) :
    ∃ q : G.Walk u v, ∀ w ∈ q.support, w ≠ ℓ := by
  induction' h : p.length using Nat.strongRecOn with m ih generalizing u v p;
  rcases p with ( _ | ⟨ w, hw ⟩ );
  · exact ⟨ SimpleGraph.Walk.nil, by simp +decide [ hu ] ⟩;
  · by_cases hw' : ‹V› = ℓ;
    · simp_all +decide [ Finset.eq_singleton_iff_unique_mem ];
      rcases hw with ( _ | ⟨ w, hw ⟩ ) <;> simp_all +decide;
      contrapose! ih;
      refine' ⟨ hw.length, by linarith, n, v, _, _, _ ⟩ <;> simp_all +decide;
      · tauto;
      · grind +suggestions;
    · exact Exists.elim ( ih _ ( by simp +decide [ h.symm ] ) hw' hv hw rfl ) fun q hq => ⟨ q.cons w, by aesop ⟩

/-
Removing a leaf from a connected tree preserves connectivity.
-/
theorem tree_delete_leaf_connected
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected) (htree : G.IsAcyclic)
    {ℓ : V} (hleaf : (G.neighborFinset ℓ).card = 1)
    (hcard : 1 < Fintype.card V) :
    (G.induce {v : V | v ≠ ℓ}).Connected := by
  -- By definition of $hleaf$, there exists a unique neighbor $n$ of $\ell$.
  obtain ⟨n, hn⟩ : ∃ n : V, G.neighborFinset ℓ = {n} := by
    exact Finset.card_eq_one.mp hleaf;
  -- By definition of $hleaf$, we know that $ℓ ≠ n$.
  have hne : ℓ ≠ n := by
    rw [ Finset.eq_singleton_iff_unique_mem ] at hn ; aesop;
  -- By definition of $hleaf$, we know that $n$ is the unique neighbor of $\ell$.
  have h_unique_neighbor : ∀ w : V, G.Adj ℓ w ↔ w = n := by
    simp_all +decide [ Finset.ext_iff, SimpleGraph.neighborFinset ];
  -- By definition of $hconn$, there exists a walk from $n$ to any vertex $w$ in $G$.
  have h_walk : ∀ w : V, w ≠ ℓ → ∃ p : G.Walk n w, ∀ v ∈ p.support, v ≠ ℓ := by
    intro w hw_ne_ℓ
    obtain ⟨p, hp⟩ : ∃ p : G.Walk n w, True := by
      have := hconn n w; aesop;
    have := walk_avoids_degree_one_vertex G hne hn ( show n ≠ ℓ from Ne.symm hne ) hw_ne_ℓ p; aesop;
  refine' SimpleGraph.connected_iff_exists_forall_reachable _ |>.mpr ⟨ ⟨ n, hne.symm ⟩, _ ⟩;
  rintro ⟨ w, hw ⟩;
  obtain ⟨ p, hp ⟩ := h_walk w hw;
  convert walk_in_set_gives_reachable G _ _ p _;
  exact hp

/-! ## Core algebraic lemma -/

/-
**Triviality of the tree Jacobian.** On a connected tree, every degree-zero
    divisor is a principal divisor. This is the algebraic heart of the genus-zero
    tropical Picard theorem: `Jac(tree) = 0`.
-/
set_option maxHeartbeats 800000 in
theorem degree_zero_principal_tree
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected) (htree : G.IsAcyclic)
    (E : Divisor V) (hdeg : divisorDegree E = 0) :
    ∃ f : V → ℤ, ∀ v, E v = PrincipalDivisor G f v := by
  revert G E hconn htree hdeg;
  intro G _ hG hG' E hE;
  induction' n : Fintype.card V using Nat.strong_induction_on with n ih generalizing V G E;
  by_cases hcard : 1 < Fintype.card V;
  · -- Let ℓ be a leaf of G with unique neighbor n.
    obtain ⟨ℓ, n, hℓn, hleaf⟩ : ∃ ℓ n : V, ℓ ≠ n ∧ G.neighborFinset ℓ = {n} := by
      have := exists_leaf_of_tree G hG hG' hcard;
      obtain ⟨ ℓ, hℓ ⟩ := this;
      obtain ⟨ n, hn ⟩ := Finset.card_eq_one.mp hℓ;
      refine' ⟨ ℓ, n, _, hn ⟩;
      rintro rfl; simp_all +decide [ SimpleGraph.neighborFinset ];
      simp_all +decide [ Finset.eq_singleton_iff_unique_mem ];
    -- Let $E' = E - \text{PrincipalDivisor } G g$ where $g(w) = -E(\ell)$ if $w = \ell$ and $0$ otherwise.
    set g : V → ℤ := fun w => if w = ℓ then -E ℓ else 0
    set E' : Divisor V := fun v => E v - PrincipalDivisor G g v;
    -- By the induction hypothesis, there exists a function f' : {v : V // v ≠ ℓ} → ℤ such that E'(v) = PrincipalDivisor G' f'(v) for all v ≠ ℓ.
    obtain ⟨f', hf'⟩ : ∃ f' : {v : V // v ≠ ℓ} → ℤ, ∀ v : {v : V // v ≠ ℓ}, E' v.val = PrincipalDivisor (G.induce {v : V | v ≠ ℓ}) f' v := by
      have h_ind : divisorDegree (fun v : {v : V // v ≠ ℓ} => E' v.val) = 0 := by
        have h_ind : divisorDegree E' = 0 := by
          unfold divisorDegree at *;
          rw [ Finset.sum_sub_distrib, hE, sub_eq_zero ];
          exact Eq.symm ( principal_degree_zero G g );
        convert h_ind using 1;
        unfold divisorDegree;
        rw [ ← Finset.sum_subset ( Finset.subset_univ ( Finset.image ( fun v : { v : V // v ≠ ℓ } => v.val ) Finset.univ ) ) ];
        · rw [ Finset.sum_image ] ; aesop;
        · simp +decide [ Finset.mem_image ];
          grind +locals;
      have h_ind : (G.induce {v : V | v ≠ ℓ}).Connected ∧ (G.induce {v : V | v ≠ ℓ}).IsAcyclic := by
        exact ⟨ tree_delete_leaf_connected G hG hG' ( by aesop ) hcard, hG'.induce _ ⟩;
      convert ih ( Fintype.card { v : V // v ≠ ℓ } ) _ ( induce { v : V | v ≠ ℓ } G ) h_ind.1 h_ind.2 _ ‹_› rfl using 1;
      simp +decide [ ← ‹Fintype.card V = _›, Finset.filter_ne' ];
      lia;
    -- Normalize f' so that f'(n) = 0.
    obtain ⟨f'_new, hf'_new⟩ : ∃ f'_new : {v : V // v ≠ ℓ} → ℤ, (∀ v : {v : V // v ≠ ℓ}, E' v.val = PrincipalDivisor (G.induce {v : V | v ≠ ℓ}) f'_new v) ∧ f'_new ⟨n, by
      exact hℓn.symm⟩ = 0 := by
      refine' ⟨ fun v => f' v - f' ⟨ n, by tauto ⟩, _, _ ⟩ <;> simp_all +decide [ PrincipalDivisor ]
    generalize_proofs at *;
    -- Extend f'_new to a function f₀ : V → ℤ by setting f₀(ℓ) = 0 and f₀(v) = f'_new(⟨v, hv⟩) for v ≠ ℓ.
    obtain ⟨f₀, hf₀⟩ : ∃ f₀ : V → ℤ, (∀ v : {v : V // v ≠ ℓ}, f₀ v.val = f'_new v) ∧ f₀ ℓ = 0 := by
      exact ⟨ fun v => if hv : v = ℓ then 0 else f'_new ⟨ v, hv ⟩, fun v => by aesop, by aesop ⟩;
    -- Verify that PrincipalDivisor G f₀ = E'.
    have h_principal_f₀ : ∀ v : V, PrincipalDivisor G f₀ v = E' v := by
      intro v; by_cases hv : v = ℓ <;> simp_all +decide [ PrincipalDivisor ] ;
      · grind +locals;
      · by_cases h : G.Adj v ℓ <;> simp_all +decide [ SimpleGraph.neighborFinset ];
        · simp_all +decide [ Finset.ext_iff, Set.ext_iff ];
          simp_all +decide [ SimpleGraph.neighborSet, SimpleGraph.degree, SimpleGraph.neighborFinset ];
          simp_all +decide [ SimpleGraph.adj_comm, Finset.sum_filter ];
          rw [ ← Finset.sum_subset ( Finset.subset_univ ( Finset.image ( fun x : { v : V // v ≠ ℓ } => x.val ) Finset.univ ) ) ] <;> simp_all +decide [ Finset.sum_image, SimpleGraph.adj_comm ];
          grind;
        · convert hf' v hv using 1;
          refine' congr_arg₂ _ ( Finset.sum_bij ( fun x hx => ⟨ x, by aesop ⟩ ) _ _ _ _ ) _;
          · simp +decide [ SimpleGraph.neighborSet, SimpleGraph.adj_comm ];
          · grind;
          · simp +decide [ SimpleGraph.neighborSet ];
          · simp +zetaDelta at *;
            exact fun a ha => hf₀.1 a ( by rintro rfl; exact h ha );
          · simp +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset ];
            refine' Or.inl ( Finset.card_bij ( fun x hx => ⟨ x, by aesop ⟩ ) _ _ _ ) <;> simp +decide [ SimpleGraph.adj_comm ];
    use f₀ + g;
    intro v; specialize h_principal_f₀ v; simp_all +decide [ PrincipalDivisor ] ;
    simp +zetaDelta at *;
    simp_all +decide [ Finset.sum_add_distrib, mul_add, PrincipalDivisor ];
    linarith;
  · interval_cases _ : Fintype.card V <;> simp_all +decide;
    · exact ⟨ fun _ => 0, fun v => False.elim <| Fin.elim0 <| Fintype.equivFinOfCardEq ( by aesop ) v ⟩;
    · have := Fintype.card_eq_one_iff.mp ( by linarith );
      obtain ⟨ x, hx ⟩ := this; use fun _ => 0; simp +decide [ hx, PrincipalDivisor ] ;
      unfold divisorDegree at hE; aesop;

/-! ## Main theorems -/

/-
**Tree Divisor Singleton Theorem.** Every divisor on a finite tree is linearly
    equivalent to a divisor concentrated at a single vertex with the same degree.
    This is the genus-zero tropical Picard theorem: `Pic^d(tree) ≅ {point}`.
-/
theorem tree_divisor_equiv_singleton
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected)
    (htree : G.IsAcyclic)
    (D : Divisor V) :
    ∃ v : V, LinearEquivalent G D (fun w => if w = v then divisorDegree D else 0) := by
  -- By the degree-zero principal tree theorem, there exists a function f such that E is principal.
  obtain ⟨f, hf⟩ : ∃ f : V → ℤ, ∀ v, (D v - (if v = (Classical.choice hconn.nonempty) then divisorDegree D else 0)) = PrincipalDivisor G f v := by
    have h_deg_zero : divisorDegree (fun v => D v - (if v = Classical.choice hconn.nonempty then divisorDegree D else 0)) = 0 := by
      simp +decide [ divisorDegree ]
    exact degree_zero_principal_tree G hconn htree _ h_deg_zero
  refine' ⟨ _, ⟨ -f, _ ⟩ ⟩;
  exact Classical.choice hconn.nonempty;
  intro v; specialize hf v; simp_all +decide [ PrincipalDivisor ] ;
  simp_all +decide [ Finset.sum_add_distrib, SimpleGraph.degree, SimpleGraph.neighborFinset ] ; linarith

/-
**Effective Representative Theorem.** On a tree, every divisor of nonneg
    degree has an effective representative.
-/
theorem tree_degree_nonneg_has_effective_representative
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected)
    (htree : G.IsAcyclic)
    (D : Divisor V)
    (hdeg : 0 ≤ divisorDegree D) :
    ∃ E : Divisor V, LinearEquivalent G D E ∧ Effective E := by
  obtain ⟨ v, hv ⟩ := tree_divisor_equiv_singleton G hconn htree D;
  exact ⟨ _, hv, fun w => by by_cases hw : w = v <;> simp +decide [ hw, hdeg ] ⟩