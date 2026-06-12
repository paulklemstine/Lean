/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Concrete d-Separation via Reachability:
# Undirected Vertex Separation is a Compositional Graphoid

This file realizes **Future Direction #1** of the do-calculus formalization:
replacing the *abstract* graphoid oracle by a **concrete, combinatorial**
separation relation, and proving from first principles that it satisfies the
graphoid axioms.

The key conceptual move (Grothendieck-style unification) is that *conditional
independence* — an axiomatic relation in probability — is here realized as a
**reachability problem in a vertex-deleted graph**. d-separation in a DAG is
classically reduced (via *moralization* of the ancestral graph) to ordinary
undirected vertex separation; we formalize the undirected separation core, which
is the combinatorial heart of d-separation.

## Bridge

* **Graph theory**     reachability / `Relation.ReflTransGen` in a deleted subgraph
* **Causal inference** the graphoid axioms (Pearl, Lauritzen) for d-separation
* **Catalog**          extends `CechCausalComplex.CausalDAG` via its undirected skeleton

## Main Results

* `separation_symmetry`      — `A ⊥ B | Z  →  B ⊥ A | Z`
* `separation_decomposition` — `A ⊥ (B ∪ W) | Z  →  A ⊥ B | Z`
* `separation_weak_union`    — `A ⊥ (B ∪ W) | Z  →  A ⊥ B | (Z ∪ W)`
* `separation_contraction`   — `A ⊥ B | Z  ∧  A ⊥ W | (Z ∪ B)  →  A ⊥ (B ∪ W) | Z`
* `separation_composition`   — `A ⊥ B | Z  ∧  A ⊥ W | Z  →  A ⊥ (B ∪ W) | Z`
                               (graph separation is *compositional*, unlike
                                generic probabilistic independence)
* `graphSeparation_semigraphoid` — bundles the first four into a `SemiGraphoid`.

The decisive technical lemma is `reflTransGen_firstHit`, a general
"first-hitting decomposition" of a reflexive-transitive-closure walk relative to
a predicate `P`: every walk from a `¬P` vertex either avoids `P` entirely or
first meets `P` after a `P`-free prefix. This single lemma powers the
contraction axiom.
-/

import Mathlib
import Catalog.MachineLearning.CechComplex

-- !-- Lab Notebook -- !--
-- !-- Hypothesis : The graphoid axioms (symmetry, decomposition, weak union,
--     contraction) — usually *postulated* of an abstract independence oracle —
--     are *theorems* once conditional independence is concretely interpreted as
--     vertex separation (non-reachability in a vertex-deleted graph). Moreover
--     graph separation should additionally satisfy *composition*, which generic
--     probabilistic independence does NOT, marking graph separation as a
--     strictly stronger "compositional graphoid". -- !--
-- !-- Result : All five axioms proved with `sorry = 0`, and the four semi-graphoid
--     axioms bundled into the instance `graphSeparation_semigraphoid`. The
--     contraction axiom turned out to need only `Disjoint A B` (not
--     `Disjoint A Z`), yielding a sharper statement. -- !--
-- !-- Insight : The semi-graphoid structure of separation is a *shadow* of the
--     monotonicity and reversibility of reachability. Symmetry = reversibility
--     of walks in an undirected graph; weak union = anti-monotonicity of
--     reachability in the conditioning set; contraction = a first-hitting
--     decomposition of a walk. The probabilistic axiom system collapses to
--     elementary facts about `Relation.ReflTransGen`. -- !--
-- !-- Failure analysis : Global reasoning about explicit paths is awkward in
--     Lean. The breakthrough was isolating `reflTransGen_firstHit`, a
--     self-contained, domain-agnostic lemma about `ReflTransGen` and an
--     arbitrary predicate. Phrasing the first-hit witness as a single
--     `ReflTransGen` *reaching* the `P`-vertex fails, since the final edge into
--     a `P`-vertex cannot satisfy a `¬P`-on-target restriction; splitting off
--     the last edge (`w' → w`) fixes it. -- !--

noncomputable section

open Relation

namespace ConcreteDSeparation

/-! ## §1. Undirected graphs and reachability in a deleted subgraph -/

/-- A finite **undirected graph** on `Fin n`: a symmetric adjacency relation. -/
structure UndirectedGraph (n : ℕ) where
  adj : Fin n → Fin n → Prop
  symm : ∀ {i j : Fin n}, adj i j → adj j i

variable {n : ℕ}

/-- One step of a walk that **avoids** the conditioning set `Z`: an edge both of
whose endpoints lie outside `Z`. (Both endpoints because the graph is
undirected, which makes the step relation symmetric.) -/
def stepZ (G : UndirectedGraph n) (Z : Finset (Fin n)) (x y : Fin n) : Prop :=
  G.adj x y ∧ x ∉ Z ∧ y ∉ Z

/-- `ConnAvoid G Z u v`: there is a walk from `u` to `v` that never enters `Z`.
This is the reflexive-transitive closure of `stepZ`. -/
def ConnAvoid (G : UndirectedGraph n) (Z : Finset (Fin n)) (u v : Fin n) : Prop :=
  Relation.ReflTransGen (stepZ G Z) u v

/-- **Separation**: `Separated G A B Z` (written `A ⊥ B | Z`) means no vertex of
`A` can reach a vertex of `B` while avoiding `Z`. -/
def Separated (G : UndirectedGraph n) (A B Z : Finset (Fin n)) : Prop :=
  ∀ a ∈ A, ∀ b ∈ B, ¬ ConnAvoid G Z a b

/-! ## §2. Basic properties of reachability -/

-- !-- The step relation is symmetric: the graph is undirected and the two
--     endpoint conditions are themselves symmetric. -- !--
/-- The `Z`-avoiding step relation is symmetric. -/
theorem stepZ_symm (G : UndirectedGraph n) (Z : Finset (Fin n)) :
    Symmetric (stepZ G Z) :=
  fun _ _ h => ⟨G.symm h.1, h.2.2, h.2.1⟩

-- !-- Reversibility of undirected walks: every edge reverses, then prepend it
--     via `ReflTransGen.head` along the inductively reversed tail. -- !--
/-- Reachability avoiding `Z` is symmetric. -/
theorem connAvoid_symm (G : UndirectedGraph n) (Z : Finset (Fin n)) {u v : Fin n}
    (h : ConnAvoid G Z u v) : ConnAvoid G Z v u := by
  rw [ConnAvoid] at *
  induction h with
  | refl => rfl
  | tail _ h₂ h₃ => exact h₃.head (stepZ_symm G Z h₂)

-- !-- A larger deleted set can only destroy walks: each `stepZ G Z'` edge is a
--     `stepZ G Z` edge when `Z ⊆ Z'`, so push through `ReflTransGen.mono`. -- !--
/-- Reachability is **anti-monotone** in the conditioning set: deleting more
vertices can only remove connections. -/
theorem connAvoid_mono (G : UndirectedGraph n) {Z Z' : Finset (Fin n)}
    (hZ : Z ⊆ Z') {u v : Fin n} (h : ConnAvoid G Z' u v) : ConnAvoid G Z u v :=
  Relation.ReflTransGen.mono
    (fun _ _ hxy => ⟨hxy.1, fun hx => hxy.2.1 (hZ hx), fun hy => hxy.2.2 (hZ hy)⟩) h

/-! ## §3. The first-hitting decomposition (engine for contraction) -/

-- !-- General fact about reflexive-transitive closure, by tail-induction:
--     either the walk never hits `P` (strengthen each edge with `¬P` on both
--     endpoints), or it first reaches a `P`-vertex `w` from a `P`-free prefix
--     ending at `w'` via a single edge `w' → w`. -- !--
/-- **First-hitting decomposition.** Any `ReflTransGen step`-walk from a vertex
with `¬ P u` either stays entirely within `{x | ¬ P x}`, or decomposes as a
`P`-free prefix `u ⇝ w'` followed by a single edge `w' → w` into a `P`-vertex. -/
theorem reflTransGen_firstHit {α : Type*} {step : α → α → Prop} {P : α → Prop}
    {u v : α} (h : Relation.ReflTransGen step u v) (hu : ¬ P u) :
    Relation.ReflTransGen (fun x y => step x y ∧ ¬ P x ∧ ¬ P y) u v ∨
      ∃ w', Relation.ReflTransGen (fun x y => step x y ∧ ¬ P x ∧ ¬ P y) u w' ∧
        ∃ w, step w' w ∧ ¬ P w' ∧ P w := by
  induction h with
  | refl => exact Or.inl ReflTransGen.refl
  | tail _ _ _ => grind

/-! ## §4. The graphoid axioms for graph separation -/

-- !-- Reverse the witnessing walk via `connAvoid_symm`. -- !--
/-- **Symmetry axiom.** -/
theorem separation_symmetry (G : UndirectedGraph n) (A B Z : Finset (Fin n))
    (h : Separated G A B Z) : Separated G B A Z :=
  fun a ha b hb h' => h b hb a ha (connAvoid_symm G Z h')

-- !-- `B ⊆ B ∪ W`, so any `A`–`B` connection is an `A`–`(B ∪ W)` connection. -- !--
/-- **Decomposition axiom.** -/
theorem separation_decomposition (G : UndirectedGraph n) (A B W Z : Finset (Fin n))
    (h : Separated G A (B ∪ W) Z) : Separated G A B Z :=
  fun a ha b hb => h a ha b (Finset.mem_union_left _ hb)

-- !-- Enlarging the conditioning set from `Z` to `Z ∪ W` only removes walks
--     (`connAvoid_mono`); `B ⊆ B ∪ W` handles the target side. -- !--
/-- **Weak union axiom.** -/
theorem separation_weak_union (G : UndirectedGraph n) (A B W Z : Finset (Fin n))
    (h : Separated G A (B ∪ W) Z) : Separated G A B (Z ∪ W) := by
  intro a ha b hb hcon
  exact h a ha b (Finset.mem_union_left _ hb)
    (connAvoid_mono G Finset.subset_union_left hcon)

-- !-- Take an `A`–`(B ∪ W)` walk avoiding `Z` to a vertex `c`. If `c ∈ B`, done
--     by `hB`. If `c ∈ W`, first-hit on membership in `B`: either the walk
--     avoids `B` entirely (an `A`–`W` walk avoiding `Z ∪ B`, contra `hW`) or it
--     first meets some `w ∈ B` (an `A`–`B` walk avoiding `Z`, contra `hB`). -- !--
/-- **Contraction axiom.** Only `Disjoint A B` is needed (not `Disjoint A Z`). -/
theorem separation_contraction (G : UndirectedGraph n) (A B W Z : Finset (Fin n))
    (hAB : Disjoint A B)
    (hB : Separated G A B Z) (hW : Separated G A W (Z ∪ B)) :
    Separated G A (B ∪ W) Z := by
  intro a ha c hc hcanotZ
  refine (hB a ha c ?_ hcanotZ).elim
  obtain ⟨w', hw', w, hstep, _hw'B, hwB⟩ :
      ∃ w', Relation.ReflTransGen (fun x y => stepZ G Z x y ∧ x ∉ B ∧ y ∉ B) a w' ∧
        ∃ w, stepZ G Z w' w ∧ w' ∉ B ∧ w ∈ B := by
    have := @reflTransGen_firstHit (Fin n) (fun x y => stepZ G Z x y)
      (fun x => x ∈ B) a c hcanotZ (fun h => Finset.disjoint_left.mp hAB ha h)
    refine this.resolve_left (fun h => ?_)
    exact hW a ha c (Finset.mem_union.mp hc |> Or.resolve_left <| by aesop)
      (Relation.ReflTransGen.mono (fun x y hxy => by unfold stepZ at *; aesop) h)
  contrapose! hB
  exact fun h => h a ha w hwB ((hw'.mono (fun _ _ hxy => hxy.1)).tail hstep)

-- !-- Pure case split on `c ∈ B ∪ W`: `c ∈ B` contradicts `hB`, `c ∈ W`
--     contradicts `hW`. This *composition* axiom fails for generic probabilistic
--     independence, so graph separation is a strictly stronger object. -- !--
/-- **Composition axiom** (graph separation is a *compositional* graphoid). -/
theorem separation_composition (G : UndirectedGraph n) (A B W Z : Finset (Fin n))
    (hB : Separated G A B Z) (hW : Separated G A W Z) :
    Separated G A (B ∪ W) Z := by
  intro a ha c hc hpath
  rcases Finset.mem_union.mp hc with hcB | hcW
  · exact hB a ha c hcB hpath
  · exact hW a ha c hcW hpath

/-! ## §5. Bundling: graph separation is a semi-graphoid -/

/-- An abstract **semi-graphoid**: a conditional-independence relation on subsets
of `Fin n` satisfying Pearl's four core axioms (with the standard disjointness
side-condition for contraction). This is the concrete counterpart of the
abstract `DSepOracle` envisioned in the do-calculus roadmap. -/
structure SemiGraphoid (n : ℕ) where
  CI : Finset (Fin n) → Finset (Fin n) → Finset (Fin n) → Prop
  symmetry : ∀ A B Z, CI A B Z → CI B A Z
  decomposition : ∀ A B W Z, CI A (B ∪ W) Z → CI A B Z
  weak_union : ∀ A B W Z, CI A (B ∪ W) Z → CI A B (Z ∪ W)
  contraction : ∀ A B W Z, Disjoint A B →
    CI A B Z → CI A W (Z ∪ B) → CI A (B ∪ W) Z

-- !-- Bundle the four proved axiom theorems into one structure. -- !--
/-- **Graph separation is a semi-graphoid.** This concretely instantiates the
abstract graphoid oracle by a combinatorial reachability relation. -/
def graphSeparation_semigraphoid (G : UndirectedGraph n) : SemiGraphoid n where
  CI := Separated G
  symmetry := separation_symmetry G
  decomposition := separation_decomposition G
  weak_union := separation_weak_union G
  contraction := separation_contraction G

/-! ## §6. Bridge to the catalog: skeleton of a `CausalDAG` -/

open CechCausalComplex in
-- !-- Forget edge orientation to get the undirected skeleton; symmetry is the
--     disjunction swap. -- !--
/-- The **undirected skeleton** of a directed `CausalDAG` from the catalog:
forget edge orientation. Moralized d-separation is undirected separation in (a
super-graph of) this skeleton, so the graphoid theorems above apply to the
catalog's causal DAGs. -/
def CausalDAG.skeleton (D : CechCausalComplex.CausalDAG n) : UndirectedGraph n where
  adj i j := D.adj i j = true ∨ D.adj j i = true
  symm := by
    intro i j h
    rcases h with h | h
    · exact Or.inr h
    · exact Or.inl h

end ConcreteDSeparation

end