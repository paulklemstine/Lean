/-
Copyright (c) 2025. All rights reserved.

# Hadwiger's Conjecture: Graph Minors and Chromatic Number

Hadwiger's conjecture (1943) is one of the deepest open problems in graph theory:
every graph with chromatic number ≥ k contains the complete graph K_k as a minor.

We formalize:
1. **Graph minors** via the branch-set (model) characterization — new to Mathlib
2. **Hadwiger number** — a novel graph invariant definition
3. **Structural properties**: reflexivity, subgraph-implies-minor, clique-gives-minor
4. **Hadwiger's conjecture** for k ≤ 2
5. **Wagner's theorem**: Hadwiger(5) ⟹ Four Color Theorem
6. **Mader-type density bounds** (statements)

Note: Edge contraction can INCREASE chromatic number (e.g., K_{3,3} → K_3),
so the relationship between minors and chromatic number is subtle.
Hadwiger's conjecture captures the deep fact that high chromatic number
*forces* large complete minors.
-/
import Mathlib

open SimpleGraph Set Function

namespace Hadwiger

/-! ## Graph Minor via Branch Sets (Model)

A *minor model* of H in G is a family of pairwise-disjoint nonempty connected
subsets of V(G), one for each vertex of H, such that for each edge of H there
is at least one edge of G between the corresponding branch sets.
-/

/-- A minor model of `H` in `G`: to each vertex of `H` we assign a nonempty
    connected subset of `V(G)` (the *branch set*), with pairwise disjoint
    branch sets, and for each edge `{u,v}` of `H`, an edge of `G` crossing
    from the branch set of `u` to that of `v`. -/
structure MinorModel {V : Type*} {W : Type*} (G : SimpleGraph V) (H : SimpleGraph W) where
  branchSet : W → Set V
  nonempty : ∀ w, (branchSet w).Nonempty
  disjoint : Pairwise fun a b => Disjoint (branchSet a) (branchSet b)
  connected : ∀ w, (G.induce (branchSet w)).Connected
  adj : ∀ u v, H.Adj u v → ∃ x ∈ branchSet u, ∃ y ∈ branchSet v, G.Adj x y

/-- Graph `H` is a *minor* of graph `G` if there exists a minor model of `H` in `G`. -/
def IsMinor {V : Type*} {W : Type*} (G : SimpleGraph V) (H : SimpleGraph W) : Prop :=
  Nonempty (MinorModel G H)

/-- The **Hadwiger number** of a graph: the supremum of `n` such that `K_n`
    (i.e., `completeGraph (Fin n)`) is a minor. -/
noncomputable def hadwigerNumber {V : Type*} (G : SimpleGraph V) : ℕ∞ :=
  ⨆ n : {m : ℕ | IsMinor G (completeGraph (Fin m))}, (n : ℕ∞)

/-! ## Hadwiger's Conjecture — Formal Statement -/

/-- **Hadwiger's Conjecture** (1943): For every finite graph `G`,
    `chromaticNumber G ≤ hadwigerNumber G`. -/
def HadwigerConj : Prop :=
  ∀ (V : Type*) [Fintype V] [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj],
    G.chromaticNumber ≤ hadwigerNumber G

/-! ## Basic Structural Properties of Minors -/

/-- Singleton branch sets always give connected induced subgraphs. -/
private theorem singleton_connected (G : SimpleGraph V) (w : V) :
    (G.induce ({w} : Set V)).Connected := by
  haveI : Nonempty ({w} : Set V) := ⟨⟨w, rfl⟩⟩
  exact Connected.mk fun ⟨a, ha⟩ ⟨b, hb⟩ => by
    simp at ha hb; subst ha; subst hb; exact Reachable.refl _

/-- Singleton sets are pairwise disjoint when indexed by distinct elements. -/
private theorem singleton_pairwise_disjoint :
    Pairwise fun (a b : V) => Disjoint ({a} : Set V) {b} := by
  intro a b hab
  simp only [Set.disjoint_left, Set.mem_singleton_iff]
  exact fun x hx1 hx2 => hab (hx1 ▸ hx2)

/-- Every graph is a minor of itself (reflexivity). -/
theorem isMinor_refl (G : SimpleGraph V) : IsMinor G G :=
  ⟨⟨fun v => {v}, fun v => ⟨v, rfl⟩,
    singleton_pairwise_disjoint,
    singleton_connected G,
    fun u v hadj => ⟨u, rfl, v, rfl, hadj⟩⟩⟩

/-- If `H ≤ G` (subgraph relation on the same vertex set), then `H` is a minor of `G`. -/
theorem isMinor_of_le {G H : SimpleGraph V} (h : H ≤ G) : IsMinor G H :=
  ⟨⟨fun v => {v}, fun v => ⟨v, rfl⟩,
    singleton_pairwise_disjoint,
    singleton_connected G,
    fun u v hadj => ⟨u, rfl, v, rfl, h hadj⟩⟩⟩

/-- The empty graph ⊥ is a minor of any graph. -/
theorem bot_isMinor (G : SimpleGraph V) : IsMinor G (⊥ : SimpleGraph V) :=
  isMinor_of_le bot_le

/-! ## K_0, K_1, K_2 as Minors (Hadwiger for k ≤ 2) -/

/-- `K_0` is (vacuously) a minor of any graph. -/
theorem hadwiger_case_zero (G : SimpleGraph V) :
    IsMinor G (completeGraph (Fin 0)) :=
  ⟨⟨Fin.elim0, fun w => Fin.elim0 w, fun {x} => Fin.elim0 x,
    fun w => Fin.elim0 w, fun u => Fin.elim0 u⟩⟩

/-
`K_1` is a minor of any graph on a nonempty vertex type.
-/
theorem hadwiger_case_one [Nonempty V] (G : SimpleGraph V) :
    IsMinor G (completeGraph (Fin 1)) := by
  refine' ⟨ fun _ => { Classical.arbitrary V }, _, _, _, _ ⟩ <;> simp +decide

/-
A graph with an edge contains `K_2` as a minor.
-/
theorem hadwiger_of_adj {G : SimpleGraph V} {u v : V} (h : G.Adj u v) :
    IsMinor G (completeGraph (Fin 2)) := by
  refine' ⟨ _, _, _, _, _ ⟩;
  refine' fun i => if i = 0 then { u } else { v };
  · exact fun w => by split_ifs <;> simp +decide ;
  · simp +decide [ Pairwise, h.ne ];
    exact h.ne.symm;
  · simp +decide [ SimpleGraph.connected_iff_exists_forall_reachable, SimpleGraph.induce ];
    aesop;
  · simp +decide [ Fin.forall_fin_two, h ];
    exact h.symm

/-! ## Clique gives Complete Minor

Every clique of size `n` in `G` directly gives a `K_n` minor via singleton
branch sets at the clique vertices. This is the "easy direction" that shows
large cliques witness large Hadwiger numbers.
-/

/-
A clique of size `n` in `G` gives a `K_n` minor.
-/
theorem completeGraph_minor_of_clique {G : SimpleGraph V}
    {s : Finset V} (hs : G.IsClique (s : Set V)) (f : Fin s.card ≃ s) :
    IsMinor G (completeGraph (Fin s.card)) := by
  use fun i => { f i |>.1 };
  · exact fun _ => Set.singleton_nonempty _;
  · simp +decide [ Pairwise, Set.disjoint_left ];
  · grind +suggestions;
  · aesop

/-! ## Hadwiger Number Monotonicity

The Hadwiger number is monotone with respect to the subgraph relation:
if `H ≤ G`, then `hadwigerNumber H ≤ hadwigerNumber G`.
-/

/-
Minor relation is monotone: if `H ≤ G` and `K` is a minor of `H`,
    then `K` is a minor of `G`.
-/
theorem isMinor_of_isMinor_of_le {G H : SimpleGraph V} {W : Type*}
    {K : SimpleGraph W} (hKH : IsMinor H K) (hHG : H ≤ G) : IsMinor G K := by
  obtain ⟨M, hM⟩ := hKH;
  use M;
  · intro w;
    rename_i h₁ h₂ h;
    have := h₂ w;
    exact this.mono ( by aesop_cat );
  · exact fun u v huv => by obtain ⟨ x, hx, y, hy, hxy ⟩ := ‹∀ u v : W, K.Adj u v → ∃ x ∈ M u, ∃ y ∈ M v, H.Adj x y› u v huv; exact ⟨ x, hx, y, hy, hHG hxy ⟩ ;

/-! ## Wagner's Equivalence

Wagner (1937) proved: Hadwiger's conjecture for k = 5 (every graph with χ ≥ 5
has a K₅ minor) is equivalent to the Four Color Theorem. We formalize the
forward direction: Hadwiger(5) ⟹ 4CT.
-/

/-- A graph is **planar** (in Wagner's combinatorial sense) if it has
    no `K₅` or `K₃,₃` minor. -/
def IsPlanar (G : SimpleGraph V) : Prop :=
  ¬ IsMinor G (completeGraph (Fin 5)) ∧
  ¬ IsMinor G (completeBipartiteGraph (Fin 3) (Fin 3))

/-- The **Four Color Theorem**: every planar graph is 4-colorable. -/
def FourColorTheorem : Prop :=
  ∀ (V : Type) [Fintype V] [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj],
    IsPlanar G → G.Colorable 4

/-- **Hadwiger(5)**: every graph not 4-colorable has a `K₅` minor. -/
def HadwigerFive : Prop :=
  ∀ (V : Type) [Fintype V] [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj],
    ¬G.Colorable 4 → IsMinor G (completeGraph (Fin 5))

/-- **Wagner's Theorem (forward direction)**: Hadwiger(5) implies the Four Color
    Theorem. Every K₅-minor-free graph (hence every planar graph) is 4-colorable.

    The proof is by contraposition: if G is planar but not 4-colorable, then
    by Hadwiger(5), G has a K₅ minor, contradicting planarity. -/
theorem wagner_forward : HadwigerFive → FourColorTheorem := by
  intro h5 V _ _ G _ hplanar
  by_contra hc
  exact hplanar.1 (h5 V G hc)

/-! ## Degeneracy and Coloring -/

/-- A graph is **k-degenerate** if every nonempty subset has a vertex with
    at most k neighbors in that subset. -/
def IsDegenerate [Fintype V] (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) : Prop :=
  ∀ (S : Finset V), S.Nonempty →
    ∃ v ∈ S, (S.filter (G.Adj v)).card ≤ k

/-
A k-degenerate graph is (k+1)-colorable (greedy coloring argument).
-/
theorem colorable_of_degenerate [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] {k : ℕ}
    (hd : IsDegenerate G k) : G.Colorable (k + 1) := by
  -- By induction on the number of vertices.
  induction' h : Fintype.card V using Nat.strong_induction_on with n ih generalizing V;
  rcases n with ( _ | n );
  · simp_all +decide [ Fintype.card_eq_zero_iff ];
    grind +suggestions;
  · -- By the induction hypothesis, the � sub�graph induced by $V \setminus \{v\}$ is $(k+1)$-colorable.
    obtain ⟨v, hv⟩ : ∃ v : V, (Finset.filter (G.Adj v) Finset.univ).card ≤ k := by
      simpa using hd Finset.univ ( Finset.card_pos.mp ( by simp +decide [ h ] ) );
    have h_ind : (G.induce {w : V | w ≠ v}).Colorable (k + 1) := by
      convert ih ( n : ℕ ) ( Nat.lt_succ_self n ) ( G.induce { w | w ≠ v } ) ( fun S hS => ?_ ) ?_;
      · convert hd ( Finset.image Subtype.val S ) ?_ using 1;
        · simp +decide [ Finset.filter_image, SimpleGraph.induce ];
          simp +decide [ Finset.card_image_of_injective, Function.Injective, SimpleGraph.comap ];
          exact ⟨ fun ⟨ a, ha, ha', ha'' ⟩ => ⟨ a, ⟨ ha, ha' ⟩, ha'' ⟩, fun ⟨ a, ⟨ ha, ha' ⟩, ha'' ⟩ => ⟨ a, ha, ha', ha'' ⟩ ⟩;
        · exact ⟨ _, Finset.mem_image_of_mem _ hS.choose_spec ⟩;
      · simp +decide [ Finset.filter_ne', h ];
    obtain ⟨f, hf⟩ := h_ind;
    -- Extend the coloring $f$ to include $v$.
    obtain ⟨c, hc⟩ : ∃ c : Fin (k + 1), ∀ w : {w : V | w ≠ v}, G.Adj v w → f w ≠ c := by
      have h_card : Finset.card (Finset.image f (Finset.filter (fun w : {w : V | w ≠ v} => G.Adj v w) Finset.univ)) ≤ k := by
        refine' le_trans ( Finset.card_image_le ) _;
        convert hv using 1;
        rw [ ← Finset.card_image_of_injective _ Subtype.coe_injective ] ; congr ; ext ; aesop;
      contrapose! h_card;
      rw [ show ( Finset.image f { w : { w : V | w ≠ v } | G.Adj v ↑w } ) = Finset.univ from Finset.eq_univ_of_forall fun c => by obtain ⟨ w, hw₁, hw₂ ⟩ := h_card c; aesop ] ; simp +decide;
    refine' ⟨ fun w => if hw : w = v then c else f ⟨ w, hw ⟩, _ ⟩;
    intro a b hab; by_cases ha : a = v <;> by_cases hb : b = v <;> simp_all +decide [ SimpleGraph.adj_comm ] ;
    · exact Ne.symm ( hc b hb hab );
    · exact Ne.symm ( hc a ha hab )

/-! ## Hadwiger Number Bounds -/

/-
The Hadwiger number of `K_n` is at least `n`.
-/
theorem hadwigerNumber_completeGraph_ge (n : ℕ) :
    n ≤ hadwigerNumber (completeGraph (Fin n)) := by
  -- Since $K_n$ is a minor of itself, it follows that $n \leq \text{hadwigerNumber}(K_n)$.
  have h_self_minor : IsMinor (completeGraph (Fin n)) (completeGraph (Fin n)) := by
    exact isMinor_refl _;
  exact le_ciSup ( show BddAbove ( Set.range fun x : { m : ℕ // IsMinor ( completeGraph ( Fin n ) ) ( completeGraph ( Fin m ) ) } => ( x : ℕ∞ ) ) from by by_contra! h; exact h_self_minor.elim fun x => by aesop ) ⟨ n, h_self_minor ⟩

/-! ## Average Degree -/

/-- Average degree of a finite graph (as a rational number). -/
noncomputable def avgDegree [Fintype V] (G : SimpleGraph V) [DecidableRel G.Adj] : ℚ :=
  if Fintype.card V = 0 then 0
  else (∑ v : V, G.degree v : ℚ) / Fintype.card V

/-! ## Kostochka-Thomason Bound (Statement) -/

/-- **Kostochka-Thomason theorem** (statement): there exists a universal constant
    `c > 0` such that every graph with average degree ≥ c·k·√(ln k) contains
    `K_k` as a minor. This gives the best known general bound relating edge density
    to Hadwiger number. -/
def KostochkaThomason : Prop :=
  ∃ c : ℝ, c > 0 ∧ ∀ (k : ℕ) (V : Type*) [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj],
    (avgDegree G : ℝ) ≥ c * k * Real.sqrt (Real.log k) →
    IsMinor G (completeGraph (Fin k))

/-! ## Testable Prediction -/

/-- **Conjecture (testable)**: Hadwiger holds for all graphs on `Fin n`.
    For `n ≤ 6` this is computationally verifiable by exhaustive enumeration
    over all `2^(n(n-1)/2)` graphs on `n` vertices. -/
def HadwigerSmall (n : ℕ) : Prop :=
  ∀ (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] (k : ℕ),
    G.chromaticNumber = k → IsMinor G (completeGraph (Fin k))

end Hadwiger