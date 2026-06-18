Soli Deo Gloria

## Assignment: Pathwidth-Guided SAT Solving as a New Structural Complexity Theory for Clause Learning

You are not being asked to tweak CDCL heuristics. You are being asked to formalize a structural theory explaining **when memory in SAT solving is inherently compressible** and how **path decompositions of evolving clause-interaction graphs** can drive principled forgetting without catastrophic loss of proof power.

The target is a field-opening bridge between:

- **structural graph theory**: pathwidth, interval-like decompositions, separators,
- **proof complexity**: width/space tradeoffs in resolution,
- **algorithm design**: memory-aware clause database management,
- **finite model theory / CSP**: bounded-width tractability phenomena,
- **systems/optimization**: online resource-bounded search.

The central vision is this:

> Clause learning should not be treated as a flat multiset of lemmas. It should be treated as a dynamically evolving graph-structured proof state whose memory footprint is governed by a hidden one-dimensional separator geometry. If that geometry has small pathwidth, then bounded-memory solving should be possible without exponential proof degradation.

Your task is to make this mathematically precise in Lean 4 and push it far enough that it becomes a genuine research blueprint, not just a coding exercise.

---

## Mode: prove

## Core New Definitions to Introduce

You must define at least one genuinely new structure absent from the catalog. The following package is the recommended backbone.

### 1. Clause interaction graph
For a CNF formula represented as a finite family of clauses over variables `α`, define a graph whose vertices are clauses and where two clauses are adjacent if they share a variable.

Suggested Lean-level skeleton:

```lean
import Mathlib.Data.Finset.Basic
import Mathlib.Data.SetLike.Basic
import Mathlib.Combinatorics.SimpleGraph.Basic
import Mathlib.Combinatorics.SimpleGraph.Subgraph
import Mathlib.Order.Interval.Set.Defs

open Finset

variable {α : Type} [DecidableEq α]

abbrev Literal (α : Type) := α × Bool
abbrev Clause (α : Type) := Finset (Literal α)
abbrev CNF (α : Type) := Finset (Clause α)

def clauseVars (C : Clause α) : Finset α :=
  C.image Prod.fst

def clausesAdjacent (C D : Clause α) : Prop :=
  ∃ x : α, x ∈ clauseVars C ∧ x ∈ clauseVars D

def confGraph (F : CNF α) : SimpleGraph (Clause α) where
  Adj C D := C ∈ F ∧ D ∈ F ∧ C ≠ D ∧ clausesAdjacent C D
  symm := by
    intro C D h
    rcases h with ⟨hC, hD, hne, x, hxC, hxD⟩
    exact ⟨hD, hC, Ne.symm hne, x, hxD, hxC⟩
  loopless := by
    intro C h
    exact h.2.1 rfl
```

This graph is the mathematical shadow of the “estimated configuration graph” in the systems conjecture.

### 2. Path decomposition of a finite graph
If Mathlib already contains an appropriate notion, build on it. Otherwise define a finite path decomposition as a list of bags satisfying vertex coverage, edge coverage, and interval connectedness.

Suggested structure:

```lean
structure PathDecomposition {V : Type} [DecidableEq V] (G : SimpleGraph V) where
  bags : List (Finset V)
  nonempty : bags ≠ []
  vertex_covered : ∀ v, ∀ hv : ∃ w, G.Adj v w ∨ G.Adj w v ∨ True, ∃ i, i < bags.length ∧ v ∈ bags.get ⟨i, by simpa using ‹_›⟩
  edge_covered : ∀ ⦃u v⦄, G.Adj u v → ∃ i, i < bags.length ∧ u ∈ bags.get ⟨i, by simpa using ‹_›⟩ ∧ v ∈ bags.get ⟨i, by simpa using ‹_›⟩
  running_intersection :
    ∀ v i j,
      i < j → j < bags.length →
      v ∈ bags.get ⟨i, by assumption⟩ →
      v ∈ bags.get ⟨j, by assumption⟩ →
      ∀ k, i ≤ k → k ≤ j → v ∈ bags.get ⟨k, by omega⟩

def PathDecomposition.width {V : Type} [DecidableEq V]
    {G : SimpleGraph V} (P : PathDecomposition G) : Nat :=
  ((P.bags.map Finset.card).foldr max 0) - 1
```

If this exact signature is inconvenient, refine it. But preserve the mathematical content.

### 3. Path-respecting clause retention policy
Define a new concept formalizing clause forgetting controlled by bags of a path decomposition.

```lean
def clauseBagSupport (P : PathDecomposition (confGraph F)) (C : Clause α) : Finset Nat := ...
def pathRespecting (P : PathDecomposition (confGraph F)) (S : Finset (Clause α)) : Prop := ...
```

Intuition: the active clause set at time/bag `i` should be concentrated in bag `i` plus a bounded separator inherited from neighboring bags.

This is the novel object that turns a systems heuristic into mathematics.

---

## Precise Theorem Targets

You must prove at least 3 substantial theorems. The following are the right targets.

---

### Theorem 1: Separator theorem for path decompositions of clause interaction graphs

**Mathematical statement**

For any finite CNF formula `F` and any path decomposition `P` of `confGraph F`, every cut of the bag sequence yields a separator: clauses appearing strictly before the cut and strictly after the cut can only interact through clauses in the cut bag.

This is the structural fact that justifies bounded-memory clause retention.

**Lean-style statement**

```lean
theorem path_bag_separates
  {α : Type} [DecidableEq α]
  (F : CNF α)
  (P : PathDecomposition (confGraph F))
  (i : Nat)
  (hi : i < P.bags.length) :
  let B := P.bags.get ⟨i, hi⟩
  ∀ {C D : Clause α},
    C ∈ F →
    D ∈ F →
    (∃ j, j < i ∧ C ∈ P.bags.get ⟨j, by omega⟩) →
    (∃ k, i < k ∧ k < P.bags.length ∧ D ∈ P.bags.get ⟨k, by omega⟩) →
    clausesAdjacent C D →
    C ∈ B ∨ D ∈ B := by
  ...
```

**Why this is a breakthrough**

This theorem identifies the exact graph-theoretic reason pathwidth can control SAT memory: learned clauses that mediate between “past” and “future” search regions must pass through a small separator bag. That is the formal kernel of a new structural memory theory for CDCL.

---

### Theorem 2: Uniform active-memory bound from pathwidth

Define an “active frontier” at cut `i` to be the set of clauses whose support intersects both sides of the cut. Prove it is bounded by the bag size, hence by pathwidth plus one.

**Lean-style statement**

```lean
def activeFrontier
  {α : Type} [DecidableEq α]
  (F : CNF α)
  (P : PathDecomposition (confGraph F))
  (i : Nat) : Finset (Clause α) :=
  F.filter (fun C =>
    (∃ j, j ≤ i ∧ j < P.bags.length ∧ C ∈ P.bags.get ⟨j, by omega⟩) ∧
    (∃ k, i ≤ k ∧ k < P.bags.length ∧ C ∈ P.bags.get ⟨k, by omega⟩))

theorem activeFrontier_card_le_bag_card
  {α : Type} [DecidableEq α]
  (F : CNF α)
  (P : PathDecomposition (confGraph F))
  (i : Nat)
  (hi : i < P.bags.length) :
  (activeFrontier F P i).card ≤ (P.bags.get ⟨i, hi⟩).card := by
  ...
```

A sharper variant is even better:

```lean
theorem activeFrontier_card_le_width_succ
  {α : Type} [DecidableEq α]
  (F : CNF α)
  (P : PathDecomposition (confGraph F))
  (i : Nat)
  (hi : i < P.bags.length) :
  (activeFrontier F P i).card ≤ P.width + 1 := by
  ...
```

**Why this matters**

This is the first mathematically rigorous expression of the slogan:

> bounded pathwidth implies bounded live clause memory.

That is not a heuristic claim; it is a structural theorem. It transforms “pathwidth-guided forgetting” from an engineering intuition into a certified memory principle.

---

### Theorem 3: Soundness of path-respecting forgetting for local interaction preservation

You likely cannot fully formalize CDCL correctness in one cycle. But you can formalize a deep surrogate theorem: forgetting clauses outside the current bag preserves all interactions internal to the current separator neighborhood.

Define a retained subformula `retainAtCut F P i` consisting of clauses in the cut bag or in the active frontier. Then prove that the induced interaction graph on retained clauses contains every edge touching the cut bag.

**Lean-style statement**

```lean
def retainAtCut
  {α : Type} [DecidableEq α]
  (F : CNF α)
  (P : PathDecomposition (confGraph F))
  (i : Nat) : Finset (Clause α) :=
  (P.bags.get ⟨i, by sorry⟩) ∪ activeFrontier F P i

theorem retainAtCut_preserves_local_edges
  {α : Type} [DecidableEq α]
  (F : CNF α)
  (P : PathDecomposition (confGraph F))
  (i : Nat)
  (hi : i < P.bags.length) :
  ∀ ⦃C D : Clause α⦄,
    C ∈ F →
    D ∈ F →
    C ∈ P.bags.get ⟨i, hi⟩ →
    (confGraph F).Adj C D →
    C ∈ retainAtCut F P i ∧ D ∈ retainAtCut F P i := by
  ...
```

**Why this matters**

This theorem says a path-guided forgetting policy can be **locally lossless** where it matters most: around the current separator that mediates information flow. This is the correct mathematical precursor to a future full theorem about clause-learning with bounded memory.

---

## Optional but Highly Desirable Fourth Theorem

### Theorem 4: Width-1 characterization yields interval behavior
Prove that if `P.width = 1`, then every connected component of `confGraph F` is path-like in a strong sense, or at minimum that every clause appears on a contiguous interval of singleton/doubleton bags and edge interactions are linearly local.

This is valuable because width-1 is where the theory becomes visually transparent and experimentally testable.

A possible target:

```lean
theorem width_one_forces_linear_locality
  {α : Type} [DecidableEq α]
  (F : CNF α)
  (P : PathDecomposition (confGraph F))
  (hP : P.width ≤ 1) :
  ∀ ⦃C D E : Clause α⦄,
    (confGraph F).Adj C D →
    (confGraph F).Adj D E →
    C ≠ E →
    -- some linear locality conclusion
    True := by
  ...
```

If this exact statement is too weak or too awkward, sharpen it into a clean graph-theoretic corollary.

---

## Cross-Domain Connection Theorem

You are required to connect this domain to another mathematical domain. Do not make this decorative. Make it structural.

### Recommended connection: finite automata / dynamic programming on path decompositions

Formalize a theorem showing that any clause-evaluation statistic depending only on variables in the current bag can be updated incrementally along the path decomposition. This is the SAT analogue of dynamic programming over bounded pathwidth, linking proof search to automata-like state compression.

For example, define partial assignments restricted to bag variables and prove a transition theorem.

**Lean-style target**

```lean
def bagVars
  {α : Type} [DecidableEq α]
  (B : Finset (Clause α)) : Finset α :=
  B.biUnion clauseVars

def localAssignment := α → Option Bool

def agreesOn (σ τ : localAssignment) (S : Finset α) : Prop :=
  ∀ x ∈ S, σ x = τ x

theorem bag_locality_of_clause_evaluation
  {α : Type} [DecidableEq α]
  (C : Clause α)
  (σ τ : localAssignment)
  (hagree : agreesOn σ τ (clauseVars C)) :
  clauseEval σ C = clauseEval τ C := by
  ...
```

Then derive a decomposition-level corollary:

```lean
theorem cut_locality
  {α : Type} [DecidableEq α]
  (F : CNF α)
  (P : PathDecomposition (confGraph F))
  (i : Nat)
  (σ τ : localAssignment)
  (hagree : agreesOn σ τ (bagVars (P.bags.get ⟨i, by sorry⟩))) :
  -- all retained clauses evaluate identically under σ and τ
  ∀ C ∈ retainAtCut F P i, clauseEval σ C = clauseEval τ C := by
  ...
```

**Cross-domain significance**

This connects SAT solving to:
- automata theory,
- CSP dynamic programming,
- database join-width ideas,
- statistical physics transfer-matrix methods.

It says bounded pathwidth does not just limit memory; it limits the **information content** that must be propagated. That is a much deeper insight.

---

## Proof Strategy Architecture

You must not rely on trivial automation. Use induction, `rcases`, `by_contra`, `field_simp` where appropriate, and multi-step `calc`. Here are three proof routes.

### Strategy A: Interval-of-occurrence method for each clause vertex
Most promising.

1. For each clause `C`, define the set of indices of bags containing `C`.
2. Use the running intersection axiom to prove this index set is an interval.
3. Derive separator facts by contradiction:
   - if `C` occurs before cut `i`,
   - `D` occurs after cut `i`,
   - and `C,D` share an edge,
   - then edge coverage gives a common bag,
   - interval connectedness forces one endpoint to appear in the cut bag.

Why this is strongest:
- It directly exploits the path decomposition axioms.
- It naturally yields both separator and active-frontier cardinality bounds.
- It produces reusable lemmas like `mem_between_of_mem_endpoints`.

### Strategy B: Finite-set injection from frontier clauses into cut bag
Best for the memory bound theorem.

1. Show every frontier clause must occur in the cut bag by interval connectedness.
2. Build an explicit injection from `activeFrontier F P i` into `P.bags.get ⟨i, hi⟩`.
3. Conclude cardinality bound via `Finset.card_le_card_of_injOn`.

Why useful:
- Gives a concrete combinatorial proof of memory boundedness.
- Produces algorithmic content: active clauses can be represented by the cut bag itself.

### Strategy C: Induction on the bag index for locality preservation
Best for the cross-domain dynamic-programming theorem.

1. Define retained clauses and retained variables at cut `i`.
2. Induct on `i` or reason by local transitions `i → i+1`.
3. Show all clause evaluations depend only on bag-local variables.
4. Use `rcases` on membership in union/frontier and finish by locality lemmas.

Why useful:
- Closest to eventual verified algorithms.
- Bridges abstract graph width to executable state compression.

---

## Building Blocks from Mathlib / Catalog to Exploit

Search for and build on the strongest available finite combinatorics lemmas rather than reproving them manually. In particular, leverage:

- `Finset.card_le_card` style injection lemmas,
- `List.get` and index arithmetic lemmas,
- `SimpleGraph` adjacency and induced subgraph APIs,
- `Finset.biUnion` and image lemmas for variable support,
- interval/order lemmas on naturals,
- if available, existing graph-width or tree/path decomposition infrastructure.

If the live catalog contains any vetted results on:
- separators in path decompositions,
- interval lemmas for running intersection,
- cardinality bounds from injections,
- CSP dynamic programming over path decompositions,

then build explicitly on them and cite the exact theorem/file names in comments and in `RESEARCH_PAPER.md`. Do not ignore catalog structure if it exists.

---

## Computational Method / Verified Algorithm

You must produce not only theorems, but a verified computational method.

### Required algorithm
Implement a pathwidth-guided retention heuristic over a finite CNF:

1. Build `confGraph F`.
2. Construct a simple approximate path decomposition:
   - acceptable first prototype: order clauses by a score such as variable overlap or insertion order and take sliding-window bags,
   - better: greedy minimum-separator ordering.
3. Define `retainAtCut`.
4. Compute the maximum active frontier size along the decomposition.
5. Prove a theorem stating the computed maximum is bounded by `P.width + 1` whenever `P` is a valid path decomposition.

Suggested Lean target:

```lean
def maxFrontierSize
  {α : Type} [DecidableEq α]
  (F : CNF α)
  (P : PathDecomposition (confGraph F)) : Nat := ...

theorem maxFrontierSize_le_width_succ
  {α : Type} [DecidableEq α]
  (F : CNF α)
  (P : PathDecomposition (confGraph F)) :
  maxFrontierSize F P ≤ P.width + 1 := by
  ...
```

This is your verified algorithmic payoff.

---

## Falsifiable Conjectures for FUTURE_DIRECTIONS.md

You must include 3–5 testable scientific hypotheses. At minimum include these.

### Conjecture A: Memory-pathwidth correlation
For industrial SAT benchmark families with strong modular structure, the estimated pathwidth of the evolving clause interaction graph is positively correlated with peak clause-database memory under CDCL.

**Test:** compute estimated pathwidth traces during solving; measure Spearman correlation with peak memory.

### Conjecture B: Separator-aware forgetting dominates activity-only forgetting on structured instances
On instances whose primal or clause-interaction graphs have low empirical pathwidth, path-respecting forgetting achieves strictly lower peak memory than LBD/activity-only forgetting with at most constant-factor slowdown.

**Test:** benchmark against MiniSat/CaDiCaL on bounded-model-checking, hardware verification, and planning families.

### Conjecture C: Width predicts learnability regime
There exists a threshold function `T(k)` such that formulas with clause interaction pathwidth at most `k` admit a clause-learning strategy whose retained database size never exceeds `T(k)` times the original formula size while preserving practical solvability.

**Test:** simulate retention policies on synthetic bounded-pathwidth CNFs and measure success/failure phase transition.

### Conjecture D: Dynamic-programming equivalence
For CNFs with bounded clause interaction pathwidth, a path-guided solver and a bag-state dynamic program have asymptotically equivalent memory requirements.

**Test:** compare state counts and retained clause counts on random bounded-pathwidth generators.

These are falsifiable. Make them sharp in the deliverable.

---

## Application Keywords

Include these explicitly in your writeup and metadata:

- SAT solving
- CDCL
- proof complexity
- pathwidth
- graph separators
- clause learning
- bounded-memory reasoning
- structural complexity
- dynamic programming
- CSP width
- finite automata
- transfer-matrix methods
- memory-aware algorithms
- industrial verification
- benchmark science

---

## Revolutionary Significance

If successful, this project opens a new program:

1. **Structural proof engineering**  
   Clause databases become objects with geometry, not just scores.

2. **A new memory theory for SAT**  
   Peak memory may be explained by graph width parameters of evolving learned-clause interactions.

3. **A bridge between proof complexity and practical solvers**  
   Width/space phenomena become operationally actionable through decomposition-guided policies.

4. **A path to solver synthesis**  
   Once bag-locality is formalized, one can design hybrid CDCL/DP solvers that switch modes when width collapses.

5. **Cross-pollination with CSP, databases, and statistical physics**  
   Path decompositions govern tractability in all of these areas. SAT clause learning could join that unifying width paradigm.

This is not an incremental SAT heuristic paper. It is the beginning of a theory of **geometric clause memory**.

---

## Mandatory Deliverables

You must produce **all** of the following:

### 1. Lean development
A Lean 4 file proving at least 3 substantial theorems from the targets above, with:
- no trivial enumeration proofs,
- explicit multi-step reasoning,
- at least one genuinely novel definition,
- minimized `sorry`,
- comments explaining the mathematical architecture.

### 2. `FUTURE_DIRECTIONS.md`
A structured document with **3–5 falsifiable hypotheses**, each with:
- precise conjecture,
- rationale,
- computational test,
- what outcome would falsify it.

### 3. `RESEARCH_PAPER.md`
A **standalone scientific paper** that someone can read without the code. It must include:
- introduction and motivation,
- precise definitions,
- theorem statements,
- proof ideas,
- algorithmic implications,
- experiments/prototype design,
- limitations,
- next-step conjectures.

Do not assume access to Lean files.

### 4. `ARTICLE.md`
A Scientific American–style article:
- vivid and accessible,
- about SAT, memory, and hidden graph geometry,
- emphasizing the ideas and why they matter,
- **taboo**: do not focus on formal verification machinery.

### 5. Verified algorithm / computational method
Implement the pathwidth-guided retention computation and prove its core correctness/bound.

### 6. `demo.py`
An interactive demonstration that:
- constructs small CNFs,
- builds the clause interaction graph,
- visualizes a path decomposition or linear bag sequence,
- computes active frontier sizes,
- illustrates the theorem that frontier size is controlled by bag width,
- optionally compares against a naive retention policy.

---

## Concrete Advice on Scope

If full formalization of SAT semantics is too heavy, prioritize this stack:

1. `confGraph`
2. `PathDecomposition`
3. interval lemmas for bag membership
4. separator theorem
5. frontier-size bound
6. local-edge preservation
7. bag-local clause evaluation theorem
8. executable frontier/max-frontier algorithm

That sequence is coherent, deep, and scientifically meaningful.

The crucial standard is this: each theorem should feel like a lemma in a future landmark paper titled something like

**“Geometric Clause Memory: Pathwidth as a Structural Invariant for SAT Solving.”**

Make the mathematics worthy of that title.

### Catalog Reference Files (Catalog/FINAL/ = vetted, high-quality)

(File paths starting with FINAL/ are vetted, high-quality catalog entries.)
@Pythagorean/ConfigGraph/Defs.lean
```lean
/-
Copyright (c) 2025. All rights reserved.
Configuration Graph Pathwidth — A Graph-Theoretic Theory of Proof Memory

This file defines the core objects for studying resolution proof complexity
through the lens of graph pathwidth. The central insight is that clause space
(the memory required for a resolution refutation) corresponds to a graph
layout parameter of the proof-state transition system.
-/
import Mathlib

open Finset List

/-! ## Path Decompositions

A path decomposition of a finite graph is a sequence of "bags" (finite sets of vertices)
satisfying three axioms: vertex coverage, edge coverage, and the interval property
(bags containing any fixed vertex form a contiguous subsequence).
-/

/-- A `PathDecomposition` of a graph with vertex type `α` is a nonempty list of bags (finite
sets of vertices). Validity conditions are stated separately. -/
structure PathDecomposition (α : Type*) [DecidableEq α] where
  /-- The bags of the decomposition, indexed linearly. -/
  bags : List (Finset α)
  /-- The bag list is nonempty. -/
  bags_nonempty : bags ≠ []

namespace PathDecomposition

variable {α : Type*} [DecidableEq α]

/-- The width of a path decomposition is the maximum bag size minus one. -/
noncomputable def width (P : PathDecomposition α) : ℕ :=
  (P.bags.map Finset.card).foldr max 0 - 1

/-- Maximum bag cardinality. -/
noncomputable def maxBagSize (P : PathDecomposition α) : ℕ :=
  (P.bags.map Finset.card).foldr max 0

theorem width_eq_maxBagSize_sub_one (P : PathDecomposition α) :
    P.width = P.maxBagSize - 1 := rfl

/-- The union of all bags — the vertex set covered by the decomposition. -/
def vertexSet (P : PathDecomposition α) : Finset α :=
  P.bags.foldr (· ∪ ·) ∅

/-- The interval (running intersection) property: for each vertex v, the indices
of bags containing v form a contiguous interval. -/
def HasIntervalProperty (P : PathDecomposition α) : Prop :=
  ∀ (v : α) (i j k : ℕ)
    (_ : i ≤ j) (_ : j ≤ k)
    (hi : i < P.bags.length) (hj : j < P.bags.length) (hk : k < P.bags.length),
    v ∈ P.bags.get ⟨i, hi⟩ → v ∈ P.bags.get ⟨k, hk⟩ → v ∈ P.bags.get ⟨j, hj⟩

/-- Edge coverage: every pair of adjacent vertices (under the given relation)
appears together in some bag. -/
def CoversEdges (P : PathDecomposition α) (adj : α → α → Prop) : Prop :=
  ∀ u v, adj u v →
    ∃ i, ∃ (hi : i < P.bags.length), u ∈ P.bags.get ⟨i, hi⟩ ∧ v ∈ P.bags.get ⟨i, hi⟩
-- ... (truncated, full file has 215 lines)
```

@FINAL/Pythagorean/AbelianizationTorsion.lean
```lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Non-Abelian Arithmetic Phase Classification:
# Abelianization Torsion Completeness and Its Failure

This file establishes the fundamental relationship between abelianization and
torsion detection for finite groups. The central results are:

1. **Completeness at degree 1**: The abelianization G^ab determines the p-torsion
   profile of G at degree 1 (i.e., H₁(G, ℤ/pℤ) depends only on G^ab).

2. **Incompleteness at degree 2**: The quaternion group Q₈ and the Klein four-group
   V₄ provide a concrete counterexample — they have isomorphic abelianizations but
   different higher torsion structure (Schur multipliers).

3. **Structural results**: Abelianization preserves and reflects p-torsion existence,
   providing a functorial "first approximation" to the torsion character of any
   finite group.

## Catalog References

Extends `HasPTorsion_ZMod_iff_dvd` and `torsionProfileUpTo_prod` from
`Catalog/Algebra/TorsionDetection.lean` from abelian to non-abelian groups.

## Main Definitions

* `HasPTorsionMul` — multiplicative p-torsion predicate
* `GroupHasPTorsion` — a group has p-torsion
* `pTorsionSet` — the set of elements killed by p-th power
* `AbelianizationHasPTorsion` — torsion profile derived from abelianization
* `TorsionCompleteAtDeg1` — abelianization captures all degree-1 torsion
* `derivedTorsionProfileDeg1` — count of p-torsion elements in G^ab
* `KleinFour` — the Klein four-group V₄

## Main Results

* `abelianization_of_surjective` — the canonical map G → G^ab is surjective
* `abelianization_torsion_transfer` — isomorphic abelianizations ⟹ same torsion
* `comm_group_abelianization_torsion_complete` — for abelian groups, G^ab captures all
* `product_pTorsion_iff` — torsion in products decomposes
* `grand_classification_summary` — the full degree-1 classification theorem
* `q8_card` / `v4_card` — cardinalities of Q₈ and V₄
* `q8_not_comm` — Q₈ is non-abelian
* `v4_comm` — V₄ is abelian
-/
import Mathlib

open scoped Pointwise

/-! ## Section 1: Core Definitions for Multiplicative Torsion -/

/-- The **Klein four-group** V₄ = ℤ/2ℤ × ℤ/2ℤ, viewed as a multiplicative group. -/
abbrev KleinFour : Type := Multiplicative (ZMod 2 × ZMod 2)

/-- A group element `g` has **multiplicative p-

### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Pythagorean
Research mode: prove
