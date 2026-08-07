/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Combinatorics.BipartiteExtremalTreesFixedParts

/-! # A linear Erdős–Sós type upper bound for *every* tree, bipartite and not

This file settles, up to a factor of two in the slope, Conjecture 2 of the research thread
started in `Catalog/Combinatorics/BipartiteExtremalTrees.lean`: the bipartite extremal number of
a tree is linear in the order of the host, with a slope depending only on the tree.

The engine is the classical *greedy embedding lemma*, formalised here in full:

* `tree_isContained_of_forall_le_degree`: **every** graph whose minimum degree is at least the
  number of edges of a tree `T` contains a copy of `T`.  The proof is an induction on the order
  of `T` in which a leaf is removed (`SimpleGraph.IsTree.exists_vert_degree_one_of_nontrivial`),
  the smaller tree is embedded by the inductive hypothesis, and the leaf is placed on a neighbour
  of the image of its parent that has not been used yet — such a neighbour exists precisely
  because the degree bound exceeds the number of already embedded vertices.

Its consequences, obtained by deleting a vertex of small degree and inducting on the order of the
host (so that a `T`-free graph is exhibited as `(k-1)`-degenerate):

* `exists_degree_le_of_isTree_free`: a `T`-free graph has a vertex of degree at most `k - 1`.
* `card_edgeFinset_le_of_isTree_free`: a `T`-free graph on `N` vertices has at most `(k-1)·N`
  edges, `k` being the number of edges of the tree `T`.
* `exBip_le_of_isTree`, `exBipParts_le_of_isTree`, `extremalNumber_le_of_isTree`: the same bound
  for the three extremal functions, i.e. **a linear bipartite Erdős–Sós bound for all trees**.
* `two_mul_exBip_le_of_isTree`: the bound in the normalisation of the Erdős–Sós conjecture,
  `2·exBip n T ≤ 2(k-1)·n`, so the conjectural slope `k-1` is missed by at most a factor of two.

Two families are then fed into the general theorem.

* `starGraph_isTree` and `star_greedy_bound_factor_two_sharp`: for stars the greedy bound is
  *exactly* a factor two off the truth `exBip n K_{1,k+1} = k⌊n/2⌋`, so no strengthening of the
  degeneracy argument alone can beat the factor two in general.
* `pathGraph_isAcyclic`, `pathGraph_isTree` (the acyclicity proof — a bridge/side-invariant
  argument — appears to be missing from Mathlib) and `exBip_pathGraph_bounds`:
  `(⌊p/2⌋-1)(n-⌊p/2⌋+1) ≤ exBip n P_p ≤ (p-2)·n`, sandwiching the bipartite extremal number of
  every path between two explicit linear functions of `n`.  For `p = 4` the two sides are
  `n - 1` and `2n`, and the exact answer `n - 1` (`exBip_pathGraph_four`) sits at the lower end.
-/

namespace Catalog.Combinatorics.BipartiteExtremalTrees

open Finset Fintype SimpleGraph

universe u v

/-! ### The greedy embedding lemma -/

/-- Auxiliary form of the greedy embedding lemma, phrased so that it can be proved by induction
on the number `n` of edges of the tree. -/
private theorem tree_isContained_aux : ∀ (n : ℕ) {W : Type u} [Fintype W] [DecidableEq W]
    {T : SimpleGraph W} [DecidableRel T.Adj], T.IsTree → Fintype.card W = n + 1 →
    ∀ {V : Type v} [Fintype V] [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj],
      Nonempty V → (∀ x, n ≤ G.degree x) → T ⊑ G := by
  intro n
  induction n with
  | zero =>
      intro W _ _ T _ _ hcard V _ _ G _ _ _
      have hsub : Subsingleton W := Fintype.card_le_one_iff_subsingleton.mp (by omega)
      refine ⟨⟨⟨fun _ => Classical.arbitrary V, ?_⟩, ?_⟩⟩
      · intro a b hab
        exact absurd (Subsingleton.elim a b) hab.ne
      · intro a b _
        exact Subsingleton.elim a b
  | succ n ih =>
      intro W _ _ T _ hT hcard V _ _ G _ hne hdeg
      have hnt : Nontrivial W := Fintype.one_lt_card_iff_nontrivial.mp (by omega)
      obtain ⟨v, hv⟩ := hT.exists_vert_degree_one_of_nontrivial
      set S : Set W := {v}ᶜ with hS
      haveI : DecidableRel (T.induce S).Adj := Classical.decRel _
      have hTS : (T.induce S).IsTree :=
        ⟨hT.isConnected.induce_compl_singleton_of_degree_eq_one hv, hT.IsAcyclic.induce S⟩
      have hcardS : Fintype.card S = n + 1 := by
        have he : Finset.filter (Membership.mem ({v}ᶜ : Set W)) Finset.univ
            = Finset.univ.erase v := by
          ext x; simp [eq_comm]
        have h : #(Finset.filter (Membership.mem ({v}ᶜ : Set W)) Finset.univ) = n + 1 := by
          rw [he, Finset.card_erase_of_mem (Finset.mem_univ v), Finset.card_univ, hcard]
          omega
        simpa [hS] using h
      obtain ⟨f⟩ := ih hTS hcardS hne (fun x => le_trans (Nat.le_succ n) (hdeg x))
      obtain ⟨u, huv, huniq⟩ := degree_eq_one_iff_existsUnique_adj.mp hv
      have hu : u ∈ S := by simp [hS, huv.ne']
      set F : S → V := fun x => f x with hF
      have hfinj : Function.Injective F := f.injective
      have himg : #(Finset.image F Finset.univ) = n + 1 := by
        rw [Finset.card_image_of_injective _ hfinj, Finset.card_univ, hcardS]
      -- the image of the smaller tree misses a neighbour of the image of the parent of the leaf
      have hex : ∃ w ∈ G.neighborFinset (F ⟨u, hu⟩), w ∉ Finset.image F Finset.univ := by
        by_contra hcon
        push_neg at hcon
        have hsub : G.neighborFinset (F ⟨u, hu⟩)
            ⊆ (Finset.image F Finset.univ).erase (F ⟨u, hu⟩) := by
          intro z hz
          refine Finset.mem_erase.mpr ⟨?_, hcon z hz⟩
          exact (G.ne_of_adj (SimpleGraph.mem_neighborFinset .. |>.mp hz)).symm
        have h1 : n + 1 ≤ #((Finset.image F Finset.univ).erase (F ⟨u, hu⟩)) := by
          calc n + 1 ≤ G.degree (F ⟨u, hu⟩) := hdeg _
            _ = #(G.neighborFinset (F ⟨u, hu⟩)) := rfl
            _ ≤ _ := Finset.card_le_card hsub
        have h2 : #((Finset.image F Finset.univ).erase (F ⟨u, hu⟩)) = n := by
          rw [Finset.card_erase_of_mem (Finset.mem_image_of_mem _ (Finset.mem_univ _)), himg]
          omega
        omega
      obtain ⟨w, hw, hwnot⟩ := hex
      have hadjw : G.Adj (F ⟨u, hu⟩) w := (SimpleGraph.mem_neighborFinset ..).mp hw
      have hginj : Function.Injective
          (fun x : W => if h : x = v then w else F ⟨x, by simp [hS, h]⟩) := by
        intro a b hab
        dsimp only at hab
        by_cases ha : a = v <;> by_cases hb : b = v
        · rw [ha, hb]
        · exfalso
          subst ha
          rw [dif_pos rfl, dif_neg hb] at hab
          exact hwnot
            (hab ▸ Finset.mem_image_of_mem F (Finset.mem_univ (⟨b, by simp [hS, hb]⟩ : S)))
        · exfalso
          subst hb
          rw [dif_pos rfl, dif_neg ha] at hab
          exact hwnot
            (hab ▸ Finset.mem_image_of_mem F (Finset.mem_univ (⟨a, by simp [hS, ha]⟩ : S)))
        · rw [dif_neg ha, dif_neg hb] at hab
          exact congrArg Subtype.val (hfinj hab)
      refine ⟨⟨⟨fun x => if h : x = v then w else F ⟨x, by simp [hS, h]⟩, ?_⟩, hginj⟩⟩
      intro a b hab
      by_cases ha : a = v
      · subst ha
        have hb : b = u := huniq b hab
        subst hb
        simp only [dif_neg huv.ne']
        exact hadjw.symm
      · by_cases hb : b = v
        · subst hb
          have hau : a = u := huniq a hab.symm
          subst hau
          simp only [dif_neg huv.ne']
          exact hadjw
        · simp only [dif_neg ha, dif_neg hb]
          exact f.toHom.map_adj hab

/-- **Greedy embedding lemma.**  A graph on a nonempty vertex set whose minimum degree is at
least the number of edges `card W - 1` of the tree `T` contains a copy of `T`. -/
theorem tree_isContained_of_forall_le_degree {W : Type u} [Fintype W] [DecidableEq W]
    {T : SimpleGraph W} [DecidableRel T.Adj] (hT : T.IsTree)
    {V : Type v} [Fintype V] [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj]
    [Nonempty V] (hdeg : ∀ x, Fintype.card W - 1 ≤ G.degree x) : T ⊑ G := by
  have hW : 0 < Fintype.card W := Fintype.card_pos_iff.mpr hT.isConnected.nonempty
  exact tree_isContained_aux (Fintype.card W - 1) hT (by omega) ‹Nonempty V› hdeg

/-- Contrapositive of the greedy embedding lemma: a `T`-free graph on a nonempty vertex set has a
vertex of degree at most `card W - 2`; that is, `T`-free graphs are `(k-1)`-degenerate, `k` being
the number of edges of the tree `T`. -/
theorem exists_degree_le_of_isTree_free {W : Type u} [Fintype W] [DecidableEq W]
    {T : SimpleGraph W} [DecidableRel T.Adj] (hT : T.IsTree)
    {V : Type v} [Fintype V] [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj]
    [Nonempty V] (hfree : T.Free G) : ∃ x, G.degree x ≤ Fintype.card W - 2 := by
  by_contra hcon
  push_neg at hcon
  exact hfree (tree_isContained_of_forall_le_degree hT fun x => by have := hcon x; omega)

/-! ### The linear upper bound -/

/-- Auxiliary form of the linear bound, phrased so that it can be proved by strong induction on
the order `N` of the host graph. -/
private theorem free_tree_card_edgeFinset_aux : ∀ (N : ℕ) {W : Type u} [Fintype W] [DecidableEq W]
    {T : SimpleGraph W} [DecidableRel T.Adj], T.IsTree →
    ∀ {V : Type v} [Fintype V] [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj],
      Fintype.card V = N → T.Free G → #G.edgeFinset ≤ (Fintype.card W - 2) * N := by
  intro N
  induction N using Nat.strong_induction_on with
  | _ N ih =>
    intro W _ _ T _ hT V _ _ G _ hcard hfree
    rcases isEmpty_or_nonempty V with hV | hV
    · have hemp : G.edgeFinset = ∅ := by
        rw [Finset.eq_empty_iff_forall_notMem]
        intro e _
        induction e with
        | h a b => exact IsEmpty.elim hV a
      simp [hemp]
    · obtain ⟨x, hdegx⟩ := exists_degree_le_of_isTree_free hT hfree
      have hcardS : Fintype.card ({x}ᶜ : Set V) = N - 1 := by
        have he : Finset.filter (Membership.mem ({x}ᶜ : Set V)) Finset.univ
            = Finset.univ.erase x := by
          ext y; simp [eq_comm]
        have h : #(Finset.filter (Membership.mem ({x}ᶜ : Set V)) Finset.univ) = N - 1 := by
          rw [he, Finset.card_erase_of_mem (Finset.mem_univ x), Finset.card_univ, hcard]
        simpa using h
      have hfree' : T.Free (SimpleGraph.induce ({x}ᶜ : Set V) G) := fun hc =>
        hfree (hc.trans ⟨(SimpleGraph.Embedding.induce ({x}ᶜ : Set V)).toCopy⟩)
      have hNpos : 1 ≤ N := by
        rw [← hcard]; exact Fintype.card_pos
      have hIH := ih (N - 1) (by omega) hT hcardS hfree'
      have hEq : #(SimpleGraph.induce ({x}ᶜ : Set V) G).edgeFinset
          = #G.edgeFinset - G.degree x := by
        rw [SimpleGraph.card_edgeFinset_induce_compl_singleton,
          SimpleGraph.card_edgeFinset_deleteIncidenceSet]
      have hmul : (Fintype.card W - 2) * N = (Fintype.card W - 2) * (N - 1)
          + (Fintype.card W - 2) := by
        obtain ⟨M, rfl⟩ : ∃ M, N = M + 1 := ⟨N - 1, by omega⟩
        simp [Nat.mul_succ]
      omega

/-- **Linear bound for `T`-free graphs.**  If `T` is a tree with `k = card W - 1` edges then every
`T`-free graph has at most `(k-1)·N` edges, `N` being its order.  (For `k = 0`, i.e. `T` a single
vertex, the bound reads `0`, which is correct: a `T`-free graph is then empty.) -/
theorem card_edgeFinset_le_of_isTree_free {W : Type u} [Fintype W] [DecidableEq W]
    {T : SimpleGraph W} [DecidableRel T.Adj] (hT : T.IsTree)
    {V : Type v} [Fintype V] [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj]
    (hfree : T.Free G) : #G.edgeFinset ≤ (Fintype.card W - 2) * Fintype.card V :=
  free_tree_card_edgeFinset_aux _ hT rfl hfree

/-- **Bipartite Erdős–Sós, up to a factor of two, for every tree.**  For a tree `T` with
`k = card W - 1` edges, `exBip n T ≤ (k-1)·n`. -/
theorem exBip_le_of_isTree {W : Type u} [Fintype W] [DecidableEq W]
    {T : SimpleGraph W} [DecidableRel T.Adj] (hT : T.IsTree) (n : ℕ) :
    exBip n T ≤ (Fintype.card W - 2) * n := by
  classical
  rw [exBip_le_iff]
  intro G hfree _
  have h := card_edgeFinset_le_of_isTree_free (V := Fin n) hT hfree
  simpa using h

/-- The same bound for the ordinary (not necessarily bipartite) extremal number. -/
theorem extremalNumber_le_of_isTree {W : Type u} [Fintype W] [DecidableEq W]
    {T : SimpleGraph W} [DecidableRel T.Adj] (hT : T.IsTree) (n : ℕ) :
    extremalNumber n T ≤ (Fintype.card W - 2) * n := by
  classical
  have h := extremalNumber_le_iff (V := Fin n) T ((Fintype.card W - 2) * n)
  rw [Fintype.card_fin] at h
  refine h.mpr fun G _ hfree => ?_
  have h' := card_edgeFinset_le_of_isTree_free (V := Fin n) hT hfree
  simpa using h'

/-- The fixed-part version: a `T`-free graph with parts of sizes `m` and `n` has at most
`(k-1)(m+n)` edges. -/
theorem exBipParts_le_of_isTree {W : Type u} [Fintype W] [DecidableEq W]
    {T : SimpleGraph W} [DecidableRel T.Adj] (hT : T.IsTree) (m n : ℕ) :
    exBipParts m n T ≤ (Fintype.card W - 2) * (m + n) :=
  le_trans (exBipParts_le_exBip m n T) (exBip_le_of_isTree hT (m + n))

/-- **The Erdős–Sós normalisation.**  The Erdős–Sós conjecture predicts `2·ex(n, T) ≤ (k-1)·n`
for a tree with `k` edges; the greedy bound gives this with an extra factor of two,
simultaneously for the bipartite and for the unrestricted extremal function. -/
theorem two_mul_exBip_le_of_isTree {W : Type u} [Fintype W] [DecidableEq W]
    {T : SimpleGraph W} [DecidableRel T.Adj] (hT : T.IsTree) (n : ℕ) :
    2 * exBip n T ≤ 2 * ((Fintype.card W - 2) * n) ∧
      2 * extremalNumber n T ≤ 2 * ((Fintype.card W - 2) * n) :=
  ⟨by have := exBip_le_of_isTree hT n; omega,
   by have := extremalNumber_le_of_isTree hT n; omega⟩

/-! ### Stars: the greedy bound is off by exactly a factor of two -/

/-- A vertex with no incident edges is unreachable from any other vertex. -/
theorem not_reachable_of_isolated {V : Type*} {H : SimpleGraph V} {x y : V}
    (hiso : ∀ z, ¬ H.Adj z y) (hxy : x ≠ y) : ¬ H.Reachable x y := by
  rintro ⟨p⟩
  have key : ∀ {a b : V} (_ : H.Walk a b), a ≠ y → b ≠ y := by
    intro a b q
    induction q with
    | nil => exact id
    | cons h _ ih =>
        intro _
        exact ih (fun hz => hiso _ (hz ▸ h))
  exact key p hxy rfl

/-- **The star `K_{1,k}` is a tree.** -/
theorem starGraph_isTree (k : ℕ) : (starGraph k).IsTree := by
  constructor
  · rw [connected_iff]
    refine ⟨?_, ⟨Sum.inl ()⟩⟩
    have hstar : ∀ c : Unit ⊕ Fin k, (starGraph k).Reachable (Sum.inl ()) c := by
      rintro (⟨⟩ | c)
      · rfl
      · exact SimpleGraph.Adj.reachable (by simp [starGraph])
    exact fun a b => (hstar a).symm.trans (hstar b)
  · rw [isAcyclic_iff_forall_adj_isBridge]
    intro a b hab
    rw [isBridge_iff]
    refine ⟨hab, ?_⟩
    rcases a with ⟨⟩ | i <;> rcases b with ⟨⟩ | j
    · simp [starGraph] at hab
    · -- deleting the edge isolates the leaf `inr j`
      refine not_reachable_of_isolated ?_ (by simp)
      rintro (⟨⟩ | z) hz
      · exact hz.2 (by rw [fromEdgeSet_adj]; exact ⟨by simp, hz.1.ne⟩)
      · simp [starGraph] at hz
    · intro hreach
      refine not_reachable_of_isolated (y := Sum.inr i) ?_ (by simp) hreach.symm
      rintro (⟨⟩ | z) hz
      · exact hz.2 (by rw [fromEdgeSet_adj]; exact ⟨by simp [Sym2.eq_swap], hz.1.ne⟩)
      · simp [starGraph] at hz
    · simp [starGraph] at hab

/-- The greedy bound specialised to the star `K_{1,k+1}` (which has `k+1` edges). -/
theorem exBip_starGraph_le_greedy (n k : ℕ) : exBip n (starGraph (k + 1)) ≤ k * n := by
  classical
  have h := exBip_le_of_isTree (T := starGraph (k + 1)) (starGraph_isTree (k + 1)) n
  have hc : Fintype.card (Unit ⊕ Fin (k + 1)) - 2 = k := by simp; omega
  rwa [hc] at h

/-- **The factor of two in the greedy bound is sharp.**  In the sparse regime `2k ≤ n` the exact
value of the bipartite extremal number of the star is `k⌊n/2⌋`, so the greedy bound `k·n` exceeds
it by a factor tending to two: `k·n ≤ 2·exBip n K_{1,k+1} + k`.  Hence no improvement of
`card_edgeFinset_le_of_isTree_free` below half of the greedy slope is possible. -/
theorem star_greedy_bound_factor_two_sharp {n k : ℕ} (h : 2 * k ≤ n) :
    k * n ≤ 2 * exBip n (starGraph (k + 1)) + k ∧
      exBip n (starGraph (k + 1)) ≤ k * n := by
  refine ⟨?_, exBip_starGraph_le_greedy n k⟩
  rw [exBip_starGraph_of_two_mul_le h]
  have hn : n ≤ 2 * (n / 2) + 1 := by omega
  calc k * n ≤ k * (2 * (n / 2) + 1) := Nat.mul_le_mul_left k hn
    _ = 2 * (k * (n / 2)) + k := by ring

/-! ### Paths: a two-sided linear estimate -/

/-- **The path graph is acyclic.**  Deleting the edge `{a, b}` disconnects the vertices of value
at most `min a b` from the rest, so every edge of `pathGraph n` is a bridge. -/
theorem pathGraph_isAcyclic (n : ℕ) : (pathGraph n).IsAcyclic := by
  rw [isAcyclic_iff_forall_adj_isBridge]
  intro a b hab
  rw [isBridge_iff]
  refine ⟨hab, ?_⟩
  intro hreach
  set t : ℕ := min a.val b.val with ht
  set G' := pathGraph n \ fromEdgeSet {s(a, b)} with hG'
  have hstep : ∀ {z y : Fin n}, G'.Adj z y → (z.val ≤ t ↔ y.val ≤ t) := by
    intro z y hzy
    have h1 : (pathGraph n).Adj z y := hzy.1
    have h2 : ¬ (s(z, y) = s(a, b)) := by
      intro hcon
      exact hzy.2 (by rw [fromEdgeSet_adj]; exact ⟨by simp [hcon], h1.ne⟩)
    rw [pathGraph_adj] at h1
    rw [pathGraph_adj] at hab
    have hne : ¬ ((z = a ∧ y = b) ∨ (z = b ∧ y = a)) := by
      intro hcon
      apply h2
      rcases hcon with ⟨h, h'⟩ | ⟨h, h'⟩ <;> subst h <;> subst h' <;> simp [Sym2.eq_swap]
    simp only [Fin.ext_iff, not_or, not_and] at hne
    omega
  have hinv : ∀ {z y : Fin n} (_ : G'.Walk z y), (z.val ≤ t ↔ y.val ≤ t) := by
    intro z y p
    induction p with
    | nil => exact Iff.rfl
    | cons h _ ih => exact (hstep h).trans ih
  obtain ⟨p⟩ := hreach
  have hp := hinv p
  rw [pathGraph_adj] at hab
  omega

/-- **The path graph on `p + 1` vertices is a tree.** -/
theorem pathGraph_isTree (p : ℕ) : (pathGraph (p + 1)).IsTree :=
  ⟨pathGraph_connected p, pathGraph_isAcyclic (p + 1)⟩

/-- **Linear upper bound for paths.**  `exBip n P_p ≤ (p-2)·n` for every `p ≥ 1`. -/
theorem exBip_pathGraph_le {p n : ℕ} (hp : 1 ≤ p) : exBip n (pathGraph p) ≤ (p - 2) * n := by
  classical
  obtain ⟨q, rfl⟩ : ∃ q, p = q + 1 := ⟨p - 1, by omega⟩
  have h := exBip_le_of_isTree (T := pathGraph (q + 1)) (pathGraph_isTree q) n
  simpa using h

/-- **Two-sided linear estimate for the bipartite extremal number of a path.**  Both bounds are
linear in `n` with slopes depending only on `p`:
`(⌊p/2⌋-1)·(n-⌊p/2⌋+1) ≤ exBip n P_p ≤ (p-2)·n`. -/
theorem exBip_pathGraph_bounds {p n : ℕ} (hp : 2 ≤ p) (hn : p / 2 - 1 ≤ n) :
    (p / 2 - 1) * (n - (p / 2 - 1)) ≤ exBip n (pathGraph p) ∧
      exBip n (pathGraph p) ≤ (p - 2) * n :=
  ⟨exBip_pathGraph_lower_bound hp hn, exBip_pathGraph_le (by omega)⟩

/-- Consistency check with the exact value for `P₄`: the general bound gives `2n`, the exact
answer `n - 1` (`exBip_pathGraph_four`) lies strictly below it, and the lower-bound construction
`K_{1,n-1}` matches the exact answer. -/
theorem exBip_pathGraph_four_between {n : ℕ} (hn : 2 ≤ n) :
    n - 1 ≤ exBip n (pathGraph 4) ∧ exBip n (pathGraph 4) ≤ 2 * n := by
  refine ⟨(exBip_pathGraph_four hn).ge, ?_⟩
  have h := exBip_pathGraph_le (p := 4) (n := n) (by norm_num)
  simpa using h

end Catalog.Combinatorics.BipartiteExtremalTrees