
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: The current formalization uses an abstract `DSepOracle` satisfying graphoid axio
**Domain**: Algebra
**Mathematical framing**: # Future Directions: Do-Calculus Formalization

## 1. Concrete d-Separation via Path Blocking

The current formalization uses an abstract `DSepOracle` satisfying graphoid axioms. The natural next step is to define d-separation concretely via path blocking (chains, forks, and colliders) and prove it satisfies all graphoid axioms. The key insight is that d-separation can be characterized as a reachability problem in a "moralized ancestral graph," which reduces the problem to ordinary graph connectivity. Why now? The `CausalDAG` infrastructure (topological ordering, reachability, mutilation) is fully in place, and the `DPath` structure already exists — we just need the blocking predicate and the moralization construction.

## 2. Completeness of Do-Calculus for Identifiability

Shpitser and Pearl (2006) proved that do-calculus is complete for identifying causal effects in semi-Markovian models. Formalizing this would require: (a) defining the "hedge" criterion, (b) showing that non-identifiability implies existence of two models agreeing on observational but not interventional distributions, and (c) showing every identifiable effect has a do-calculus derivation. The key insight is that the hedge structure provides a finite witness for non-identifiability, making the completeness proof constructive. Why now? The `DoDerivation` inductive type and `DoCalculusRule.graphCondition` already encode the derivation system — what's missing is the connection to actual probability distributions.

## 3. Algorithmic Identifiability via ID Algorithm

The ID algorithm (Tian and Pearl, 2002) provides a recursive decision procedure for causal effect identifiability. Formalizing this as a verified algorithm in Lean 4 would give us a certified decision procedure with extraction to executable code. The key insight is that the ID algorithm's recursion follows the c-component (confounding component) decomposition of the DAG, which can be defined using the `descendantsSet` and `ancestorsSet` operations already formalized. Why now? The mutilation algebra (composition, commutativity, idempotence) provides the foundation for reasoning about the graph transformations the algorithm performs.

## 4. Structural Causal Models with Measure-Theoretic Semantics

The current formalization captures the syntactic/graph-theoretic side of do-calculus. A deeper formalization would attach measure-theoretic semantics: each vertex carries a measurable space, each structural equation is a measurable function, and the do-operator corresponds to replacing a structural equation with a constant. The key insight is that the `intervention_disconnects` theorem (ancestors become empty after mutilation) is the graph-theoretic shadow of the measure-theoretic fact that intervened variables become independent of their former causes. Why now? Mathlib's measure theory library is mature enough to support this, and the graph-theoretic foundation proven here ensures the combinatorial side is solid.

## 5. Causal Discovery: Faithfulness and the PC Algorithm

Moving from causal inference (given a known DAG) to causal discovery (learning the DAG from data) requires the faithfulness assumption: that d-separation exactly characterizes conditional independence. Formalizing the PC algorithm's correctness under faithfulness would connect the d-separation oracle to statistical testing. The key insight is that under faithfulness, the `DSepOracle.symmetry`, `decomposition`, and `weak_union` axioms are not just sufficient but necessary — they characterize exactly the conditional independence relations that can arise from a DAG. Why now? The abstract `DSepOracle` structure is designed to be instantiated with concrete independence relations, making it the natural bridge between the graph-theoretic and statistical worlds.

Research domain: Algebra
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/MachineLearning/ConcreteDSeparation.lean
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
/-- **Decomposition a
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Concrete d-Separation and the Graphoid Hierarchy

## Synthesis

The catalog already carried two attitudes toward causal independence. The
Čech-cohomological file (`Catalog/MachineLearning/CechComplex.lean`) treats
identifiability *algebraically*: discrepancies are cochains, `d² = 0` makes
cohomology well-defined, and `H¹ = 0` on the total space encodes "all effects
identifiable". The do-calculus roadmap, by contrast, imagined an *abstract*
`DSepOracle` whose graphoid axioms (symmetry, decomposition, weak union,
contraction) are simply *postulated*.

This cycle closes the gap from below. In
`Catalog/MachineLearning/ConcreteDSeparation.lean` we give a fully concrete,
combinatorial model of conditional independence — **undirected vertex
separation**, defined as non-reachability of `A` from `B` in the graph with the
conditioning set `Z` deleted — and *prove* that it satisfies all four
semi-graphoid axioms, plus the **composition** axiom that fails for generic
probabilistic independence. The four axioms are bundled into the structure
`graphSeparation_semigraphoid`, so the abstract oracle now has a witnessed
instance. The bridge `CausalDAG.skeleton` connects this to the catalog's
directed `CausalDAG`, since moralized d-separation is undirected separation in a
super-graph of the skeleton.

The unifying discovery is that the entire graphoid axiom system is a *shadow* of
three elementary facts about reflexive-transitive closure: **reversibility**
(symmetry), **anti-monotonicity in the deleted set** (weak union), and a
**first-hitting decomposition** of a walk relative to a predicate
(`reflTransGen_firstHit`, which powers contraction). The probabilistic axioms
are not deep about probability — they are deep about *reachability*.

## Results Summary

* `separation_symmetry`, `separation_decomposition`, `separation_weak_union`,
  `separation_contraction` — the four semi-graphoid axioms, proved for vertex
  separation.
* `separation_composition` — graph separation is *compositional*, separating it
  strictly from the probabilistic semi-graphoid.
* `graphSeparation_semigraphoid` — the bundled `SemiGraphoid` instance.
* `reflTransGen_firstHit` — a reusable, domain-agnostic first-hitting lemma for
  `Relation.ReflTransGen`.
* Sharper than folklore: contraction needed only `Disjoint A B`, not the usual
  `Disjoint A Z`.

## Falsifiable Research Directions

### 1. The Intersection Axiom and the Compositional-Graphoid Closure

Conjecture: undirected vertex separation also satisfies the **intersection**
axiom — `A ⊥ B | (Z ∪ W)` and `A ⊥ W | (Z ∪ B)` imply `A ⊥ (B ∪ W) | Z` — under
pairwise disjointness, making it a full *compositional graphoid* rather than
merely a semi-graphoid. This is falsifiable: a single finite graph with an
explicit triple `(A, B, W)` violating the implication would refute it. The key
insight is that intersection is again a first-hitting argument, but now the walk
must be split simultaneously against *two* predicates (`∈ 
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
