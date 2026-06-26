/-
# Extremal Graph Theory: foundations of graph saturation

This file develops, from scratch, the basic theory of **saturation numbers** that underlies the
Cameron–Puleo / Kászonyi–Tuza circle of results on `sat(n, H)`.

For a finite host vertex type, a graph `G` is **`H`-saturated** when it contains no copy of `H` but
adding *any* missing edge creates one.  The **saturation number** `satNum H n` is the minimum number
of edges of an `H`-saturated graph on `n` vertices; the **extremal/Turán number** `exNum H n` is the
maximum number of edges of an `H`-free graph.

We prove three genuine, fully formal results:

* `exists_isSaturated`: whenever `H` has at least one edge, an `H`-saturated graph exists on `Fin n`
  (a *maximum*-edge `H`-free graph is automatically `H`-saturated).  This is the structural fact that
  makes `satNum` well defined and is the seed of every saturation argument.
* `satNum_le_exNum`: the classical inequality `sat(n, H) ≤ ex(n, H)` — the minimum saturated graph
  never has more edges than the maximum free graph.
* `edgeCount_cone`: joining a single apex vertex to a graph `H` on `m` vertices adds exactly `m`
  edges, i.e. `e(K₁ ∨ H) = m + e(H)`.  This is the source of the `n - 1` term in the
  Cameron–Puleo recurrence `sat(n, K₁ ∨ F) = (n-1) + sat(n-1, F)`.

The headline *equality* `sat(n, K₁ ∨ F) = (n-1) + sat(n-1, F)` for `F = tK₂ ∪ qK₁` (all `t ≥ 1`)
is, at the time of writing, an open extremal problem (the paper proves `t = 1, 2`).  We state the two
graph families exactly and record the conjecture as a `Prop`; see `FUTURE_DIRECTIONS.md`.
-/
import Mathlib

open Finset SimpleGraph

namespace Saturation

/-! ## Edge count, saturation, and the two extremal parameters -/

/-- Number of edges of a graph on a finite vertex type. -/
noncomputable def edgeCount {V : Type*} (G : SimpleGraph V) : ℕ := G.edgeSet.ncard

/-- `G` is `H`-**saturated**: it is `H`-free, yet adding any missing (non-loop) edge creates a copy
of `H`. -/
def IsSaturated {W V : Type*} (H : SimpleGraph W) (G : SimpleGraph V) : Prop :=
  H.Free G ∧ ∀ a b : V, a ≠ b → ¬ G.Adj a b → H ⊑ (G ⊔ fromEdgeSet {s(a, b)})

open Classical in
/-- Maximum number of edges of an `H`-free graph on `Fin n` (the extremal/Turán number). -/
noncomputable def exNum {W : Type*} (H : SimpleGraph W) (n : ℕ) : ℕ :=
  (univ.filter (fun G : SimpleGraph (Fin n) => H.Free G)).sup edgeCount

open Classical in
/-- Minimum number of edges of an `H`-saturated graph on `Fin n` (the saturation number).  If no
`H`-saturated graph exists the value is `0` by convention; `exists_isSaturated` shows this case does
not occur when `H` has an edge. -/
noncomputable def satNum {W : Type*} (H : SimpleGraph W) (n : ℕ) : ℕ :=
  sInf {m | ∃ G : SimpleGraph (Fin n), IsSaturated H G ∧ edgeCount G = m}

/-! ## Basic edge-count lemmas -/

/-
A graph that contains an edge cannot embed into the empty graph.
-/
theorem free_bot_of_adj {V : Type*} {H : SimpleGraph V} {a b : V} (h : H.Adj a b) :
    H.Free (⊥ : SimpleGraph V) := by
  convert fun f => ?_;
  obtain ⟨ f, hf ⟩ := f;
  exact absurd ( f.map_adj h ) ( by simp +decide )

/-
Adding a genuinely new edge strictly increases the edge count.
-/
theorem edgeCount_lt_addEdge {V : Type*} [Fintype V] (G : SimpleGraph V) {a b : V}
    (hab : a ≠ b) (hadj : ¬ G.Adj a b) :
    edgeCount G < edgeCount (G ⊔ fromEdgeSet {s(a, b)}) := by
  refine' Set.ncard_lt_ncard _ _;
  · simp +decide [ Set.not_subset, hab, hadj ];
  · exact Set.toFinite _

/-! ## Existence of saturated graphs (well-definedness of `satNum`) -/

/-- **Maximal-free is saturated.** If `H` has an edge, then on any `Fin n` there is an `H`-saturated
graph: take an `H`-free graph with the maximum number of edges. -/
theorem exists_isSaturated {m : ℕ} (H : SimpleGraph (Fin m)) {a b : Fin m} (hab : H.Adj a b)
    (n : ℕ) : ∃ G : SimpleGraph (Fin n), IsSaturated H G := by
  obtain ⟨G, hG⟩ : ∃ G : SimpleGraph (Fin n), H.Free G ∧ ∀ G' : SimpleGraph (Fin n), H.Free G' → edgeCount G' ≤ edgeCount G := by
    apply_rules [ Set.exists_max_image ];
    · exact Set.toFinite _;
    · use ⊥; simp;
      constructor;
      rintro ⟨ f, hf ⟩;
      exact absurd ( f.map_adj hab ) ( by simp +decide );
  refine' ⟨ G, hG.1, _ ⟩;
  intro a b hab hadj;
  contrapose! hG;
  exact fun _ => ⟨ G ⊔ fromEdgeSet { s(a, b) }, hG, edgeCount_lt_addEdge G hab hadj ⟩

/-! ## The classical bound `sat(n, H) ≤ ex(n, H)` -/

/-- **`sat(n, H) ≤ ex(n, H)`.** The minimum-edge saturated graph never exceeds the maximum-edge free
graph.  A maximum-free graph is saturated (`exists_isSaturated`'s witness), so it simultaneously
realises `ex` and is an upper bound for `sat`. -/
theorem satNum_le_exNum {m : ℕ} (H : SimpleGraph (Fin m)) {a b : Fin m} (hab : H.Adj a b)
    (n : ℕ) : satNum H n ≤ exNum H n := by
  -- By definition of `satNum`, there exists a graph `G₀` such that `IsSaturated H G₀` and `edgeCount G₀ = satNum H n`.
  obtain ⟨G₀, hG₀⟩ : ∃ G₀ : SimpleGraph (Fin n), IsSaturated H G₀ := by
    exact exists_isSaturated H hab n;
  refine' le_trans ( Nat.sInf_le _ ) _;
  exact edgeCount G₀;
  · use G₀;
  · convert Finset.le_sup ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hG₀.1 ⟩ )

/-! ## The apex join and the `n - 1` term -/

/-- The **cone** (apex join) `K₁ ∨ H`: a fresh apex vertex `none` adjacent to every vertex of `H`,
with `H` sitting on the `some _` vertices. -/
def cone {V : Type*} (H : SimpleGraph V) : SimpleGraph (Option V) where
  Adj x y :=
    match x, y with
    | none, some _ => True
    | some _, none => True
    | some a, some b => H.Adj a b
    | none, none => False
  symm := by
    rintro (_ | a) (_ | b) h <;> simp_all [SimpleGraph.adj_comm]
  loopless := ⟨by rintro (_ | a) h <;> simp_all⟩

/-- **Edge count of the apex join.** Joining one apex vertex to a graph `H` on `m` vertices adds
exactly `m` edges: `e(K₁ ∨ H) = m + e(H)`.  This is the origin of the `n - 1` term in the
Cameron–Puleo recurrence. -/
theorem edgeCount_cone {V : Type*} [Fintype V] (H : SimpleGraph V) :
    edgeCount (cone H) = Fintype.card V + edgeCount H := by
  convert Set.ncard_eq_toFinset_card' _ using 1;
  all_goals try infer_instance;
  unfold edgeCount; simp +decide [ SimpleGraph.edgeSet ] ;
  convert Set.ncard_eq_toFinset_card' _ using 1;
  rw [ ← Set.ncard_image_of_injective _ ( show Function.Injective ( fun x : Sym2 V => Sym2.map Option.some x ) from ?_ ) ];
  · rw [ show ( cone H ).edgeSet = ( Set.image ( fun x : V => Sym2.mk ( none, some x ) ) Set.univ ) ∪ ( Set.image ( fun x : Sym2 V => Sym2.map some x ) ( edgeSetEmbedding V H ) ) from ?_, Set.ncard_union_eq ];
    · rw [ Set.InjOn.ncard_image ];
      · rw [ Set.ncard_image_of_injective _ fun x y hxy => by simpa using hxy, Set.ncard_univ ] ; aesop;
      · intro x hx y hy; simp_all +decide ;
        induction x using Sym2.inductionOn ; induction y using Sym2.inductionOn ; aesop;
    · simp +decide [ Set.disjoint_left ];
      rintro a x hx; rcases x with ⟨ u, v ⟩ ; simp +decide ;
    · ext ⟨ x, y ⟩ ; cases x <;> cases y <;> simp +decide [ cone ] ;
      · rintro ⟨ a, b ⟩ h; simp +decide ;
      · constructor;
        · exact fun h => ⟨ Sym2.mk ( _, _ ), h, rfl ⟩;
        · rintro ⟨ x, hx, hx' ⟩;
          rcases x with ⟨ a, b ⟩ ; simp_all +decide ;
          cases hx' <;> simp_all +decide [ SimpleGraph.adj_comm ];
  · intro x y; induction x using Sym2.inductionOn ; induction y using Sym2.inductionOn ; aesop;

/-! ## The mission's graph families and the Cameron–Puleo equality (conjecture) -/

/-- `tK₂ ∪ qK₁`: a perfect matching of size `t` on the first `2t` vertices, together with `q`
isolated vertices, living on `Fin (2*t + q)`.  Vertices `2k` and `2k+1` (for `k < t`) form the `k`-th
matching edge; vertices `≥ 2t` are isolated. -/
def matchingPlusIsolated (t q : ℕ) : SimpleGraph (Fin (2 * t + q)) where
  Adj i j := i.val < 2 * t ∧ j.val < 2 * t ∧ i.val / 2 = j.val / 2 ∧ i ≠ j
  symm := by
    rintro i j ⟨hi, hj, he, hne⟩
    exact ⟨hj, hi, he.symm, hne.symm⟩
  loopless := ⟨by rintro i ⟨-, -, -, hne⟩; exact hne rfl⟩

/-- **Cameron–Puleo equality (conjecture).** For `t ≥ 1`, `q ≥ 1`, and `n > 2t + q`, the saturation
number of `K₁ ∨ (tK₂ ∪ qK₁)` equals `(n-1) + sat(n-1, tK₂ ∪ qK₁)`.  Proved in the source paper for
`t = 1, 2`; open in general.  Stated here as a `Prop`; not asserted as a theorem. -/
def CameronPuleoEquality (t q : ℕ) : Prop :=
  1 ≤ t → 1 ≤ q → ∀ n, 2 * t + q < n →
    satNum (cone (matchingPlusIsolated t q)) n
      = (n - 1) + satNum (matchingPlusIsolated t q) (n - 1)

end Saturation