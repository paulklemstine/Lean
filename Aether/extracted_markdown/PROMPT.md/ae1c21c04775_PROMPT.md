
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   Reference the specific theorems proved in Phase A using @file references.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work,
   references to catalog results. Use @file references for theorems.
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
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
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
Use the @file references above to point readers to specific theorems.


## Concept

**Title**: Spectral Universality of Theorem Spaces: Random-Matrix Statistics in Formal Proo
**Domain**: Novelty
**Mathematical framing**: Conjecture: For sufficiently large formalized mathematics corpora, the normalized local eigenvalue spacing distribution of the directed proof-dependency graph Laplacian (or symmetrized adjacency operator) converges, after degree-corrected null-model normalization, to a universal random-matrix ensemble law (GOE/GUE-like) within mature theorem domains, while genuinely novel or foundationally incomplete domains exhibit statistically significant deviations from that law. Test: Build proof graphs from large theorem libraries (e.g. Lean, Coq, Isabelle), compute spectra of dependency operators on domain-specific subgraphs, compare unfolded spacing statistics and eigenvector localization against random-matrix and null-model predictions, and check whether newly developing areas systematically show out-of-universality deviations that later disappear as the area matures. The conjecture is refuted if no cross-library universality appears, or if deviations fail to correlate with independent measures of mathematical novelty or incompleteness. Impact: This would create a quantitative physics-style order parameter for the maturity, coherence, and frontier status of mathematical theories, enabling automated discovery of under-axiomatized regions, prediction of fruitful theorem-generation targets, and a new bridge between random matrix theory, knowledge representation, and automated reasoning.
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/ClosureCircuitDuality.lean
/-
Copyright (c) 2025 Closure-Circuit Duality Project. All rights reserved.

# Closure-Circuit Duality: Certified Monotone Circuit Reconstruction

This file formalizes a duality between finite closure systems and monotone Boolean
circuits, establishing that every closure operator on a finite type admits a unique
canonical residual basis of minimal generators, and that this basis yields a
monotone DNF circuit that correctly computes the closure.

## Main Results

* `generatedClosure_isClosureOperator` — Implication-generated closures are closure operators
* `minimal_support_exists` — Every element in a closure has a minimal support set
* `closure_iff_contains_minimal_support` — Closure membership ↔ existence of a minimal support
* `canonical_basis_is_basis` — The canonical basis satisfies the basis property
* `canonical_basis_unique` — The canonical residual basis is unique
* `reconstructed_circuit_correct` — The reconstructed DNF circuit correctly computes closure
* `finite_closure_duality` — Main duality theorem packaging all results
* `closure_basis_canonical` — Existence and uniqueness of the canonical basis (`∃!`)

## Overview

The central idea is a **Myhill–Nerode-type minimization principle for monotone closure
computation**: bounded dependency rank forces a canonical finite residual basis, and this
basis is exactly the algebraic shadow of a minimal monotone circuit.
-/

import Mathlib

namespace ClosureCircuitDuality

open Set Finset

noncomputable section

/-! ## Part 1: Core Definitions -/

/-- A closure operator on `Set α`: extensive, monotone, and idempotent. -/
structure IsClosureOperator {α : Type*} (cl : Set α → Set α) : Prop where
  extensive : ∀ s, s ⊆ cl s
  monotone : ∀ ⦃s t⦄, s ⊆ t → cl s ⊆ cl t
  idempotent : ∀ s, cl (cl s) = cl s

/-! ## Part 2: Implication Presentations -/

/-- A closure presentation: a finite set of rules `(premises, conclusion)`. -/
abbrev ClosurePresentation (α : Type*) [DecidableEq α] := Finset (Finset α × α)

/-- A set `s` is closed under a presentation `P`. -/
def ClosedUnder {α : Type*} [DecidableEq α]
    (P : ClosurePresentation α) (s : Set α) : Prop :=
  ∀ rule ∈ P, (↑rule.1 : Set α) ⊆ s → rule.2 ∈ s

/-- The closure of `s` under presentation `P`: intersection of all closed supersets. -/
def GeneratedClosure {α : Type*} [DecidableEq α]
    (P : ClosurePresentation α) (s : Set α) : Set α :=
  ⋂₀ {t : Set α | s ⊆ t ∧ ClosedUnder P t}

/-- A closure operator has rank bounded by `r`. -/
def ClosureRankBounded {α : Type*} [DecidableEq α]
    (cl : Set α → Set α) (r : ℕ) : Prop :=
  ∃ P : ClosurePresentation α,
    (∀ rule ∈ P, rule.1.card ≤ r) ∧
    ∀ s, GeneratedClosure P s = cl s

/-! ## Part 3: Residual Equivalence and Generators -/

/-- Residual equivalence: `x` and `y` have the same closure profile. -/
def ResidualEquivalent {α : Type*} (cl : Set α → Set α) (x y : α) : Prop :=
  ∀ s : Set α, x ∈ cl s ↔ y ∈ cl s

/-- A residual generator pairs a target element with a support set. -/
@[ext]
structure ResidualGenerator (α : Type*) where
  target : α
  support : Finset α

instance {α : Type*} [DecidableEq α] : DecidableEq (ResidualGenerator α) :=
  fun a b =>
    if ht : a.target = b.target then
      if hs : a.support = b.support then
        isTrue (ResidualGenerator.ext ht hs)
      else isFalse (fun h => hs (h ▸ rfl))
    else isFalse (fun h => ht (h ▸ rfl))

/-- A minimal support for `x` under `cl`: `A` generates `x` and no proper subset does. -/
def IsMinimalSupport {α : Type*} [DecidableEq α]
    (cl : Set α → Set α) (x : α) (A : Finset α) : Prop :=
  x ∈ cl (↑A : Set α) ∧ ∀ B : Finset α, B ⊂ A → x ∉ cl (↑B : Set α)

/-- The set of all minimal supports for a given target `x`. -/
def minimalSupports {α : Type*} [DecidableEq α] [Fintype α]
    (cl : Set α → Set α) (x : α) : Finset (Finset α) :=
  @Finset.filter _ (fun A' => IsMinimalSupport cl x A')
    (fun _ => Classical.propDecidable _) Finset.univ

/-! ## Part 4: Canonical Residual Basis -/

/-- The canonical residual basis: the set of all minimal residual generators. -/
def canonicalBasis {α : Type*} [DecidableEq α] [Fintype α]
    (cl : Set α → Set α) : Finset (ResidualGenerator α) :=
  Finset.univ.biUnion fun x =>
    (minimalSupports cl x).image fun A => ⟨x, A⟩

/-- A set of residual generators forms a canonical basis:
    1. Every generator is minimal.
    2. Closure membership ↔ containing some generator's support. -/
def IsCanonicalBasis {α : Type*} [DecidableEq α] [Fintype α]
    (cl : Set α → Set α) (B : Finset (ResidualGenerator α)) : Prop :=
  (∀ g ∈ B, IsMinimalSupport cl g.target g.support) ∧
  (∀ x : α, ∀ s : Set α,
    x ∈ cl s ↔ ∃ g ∈ B, g.target = x ∧ (↑g.support : Set α) ⊆ s)

/-! ## Part 5: Monotone Circuits -/

/-- A monotone Boolean circuit over inputs from `α`. -/
inductive MonotoneCircuit (α : Type*)
  | input : α → MonotoneCircuit α
  | top : MonotoneCircuit α
  | bot : MonotoneCircuit α
  | conj : MonotoneCircuit α → MonotoneCircuit α → MonotoneCircuit α
  | disj : MonotoneCircuit α → MonotoneCircuit α → MonotoneCircuit α

namespace MonotoneCircuit

/-- Evaluate a monotone circuit on a set `s`. -/
def eval {α : Type*} : MonotoneCircuit α → Set α → Prop
  | input a, s => a ∈ s
  | top, _ => True
  | bot, _ => False
  | conj c₁ c₂, s => c₁.eval s ∧ c₂.eval s
  | disj c₁ c₂, s => c₁.eval s ∨ c₂.eval s

/-- The size (number of gates) of a circuit. -/
def size {α : Type*} : MonotoneCircuit α → ℕ
  | input _ => 1
  | top => 1
  | bot => 1
  | conj c₁ c₂ => 1 + c₁.size + c₂.size
  | disj c₁ c₂ => 1 + c₁.size + c₂.size

/-- Circuit evaluation is monotone. -/
theorem eval_mono {α : Type*} (c : MonotoneCircuit α) {s t : Set α} (h : s ⊆ t) :
    c.eval s → c.eval t := by
  induction c with
  | input a => exact fun ha => h ha
  | top => exact id
  | bot => exact id
  | conj c₁ c₂ ih₁ ih₂ => exact fun ⟨h₁, h₂⟩ => ⟨ih₁ h₁, ih₂ h₂⟩
  | disj c₁ c₂ ih₁ ih₂ => exact fun h' => h'.elim (Or.inl ∘ ih₁) (Or.inr ∘ ih₂)

end MonotoneCircuit

/-- Build a conjunction circuit from a list of inputs. -/
def conjOfList {α : Type*} : List α → MonotoneCircuit α
  | [] => .top
  | a :: as => .conj (.input a) (conjOfList as)

/-- Build a disjunction of circuits from a list. -/
def disjOfList {α : Type*} : List (MonotoneCircuit α) → MonotoneCircuit α
  | [] => .bot
  | c :: cs => .disj c (disjOfList cs)

/-- `conjOfList l` evaluates to true on `s` iff all elements of `l` are in `s`. -/
theorem conjOfList_eval {α : Type*} (l : List α) (s : Set α) :
    (conjOfList l).eval s ↔ ∀ a ∈ l, a ∈ s := by
  induction l with
  | nil => simp [conjOfList, MonotoneCircuit.eval]
  | cons a as ih =>
    simp only [conjOfList, MonotoneCircuit.eval, ih, List.forall_mem_cons]

/-- `disjOfList cs` evaluates to true on `s` iff some circuit in `cs` does. -/
theorem disjOfList_eval {α : Type*} (l : List (MonotoneCircuit α)) (s : Set α) :
    (disjOfList l).eval s ↔ ∃ c ∈ l, MonotoneCircuit.eval c s := by
  induction l with
  | nil => simp [disjOfList, MonotoneCircuit.eval]
  | cons c cs ih =>
    simp only [disjOfList, MonotoneCircuit.eval, ih]
    constructor
    · rintro (h | ⟨c', hc', heval⟩)
      · exact ⟨c, List.mem_cons_self .., h⟩
      · exact ⟨c', List.mem_cons_of_mem _ hc', heval⟩
    · rintro ⟨c', hc', heval⟩
      rcases List.mem_cons.mp hc' with rfl | hc'
      · exact Or.inl heval
      · exact Or.inr ⟨c', hc', heval⟩

/-! ## Part 6: Closure Circuit and Reconstruction -/

/-- A closure circuit: one monotone circuit per output element. -/
structure ClosureCircuit (α : Type*) where
  output : α → MonotoneCircuit α

/-- A closure circuit correctly computes a closure operator. -/
def CircuitComputesClosure {α : Type*}
    (C : ClosureCircuit α) (cl : Set α → Set α) : Prop :=
  ∀ x s, (C.output x).eval s ↔ x ∈ cl s

/-- Reconstruct a closure circuit from a closure operator using its minimal
    supports: for each `x`, build `⋁_{A ∈ minSupp(x)} ⋀_{a ∈ A} input(a)`. -/
def reconstructClosureCircuit {α : Type*} [Deci
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Spectral Dependency Theory

## 1. Eigenvalue Interlacing for Subgraph Coherence

When a mathematical domain D is a subgraph of a larger proof dependency graph G, the coherence matrix C_D is a principal submatrix of C_G (after appropriate embedding). The Cauchy interlacing theorem then constrains the eigenvalues of C_D relative to C_G. The key insight is that this interlacing provides a *spectral monotonicity* principle: as a mathematical domain matures and accumulates more cross-references, its coherence eigenvalues must interleave with those of the ambient library, providing a quantitative measure of integration. Why now? We have formalized the coherence matrix and its PSD property; interlacing for real symmetric matrices is available in Mathlib via eigenvalue theory, making the bridge theorem provable.

## 2. Spectral Gap of Coherence as Connectivity Invariant

For the coherence matrix C = AᵀA of a DAG, the smallest eigenvalue is always 0 (corresponding to the kernel of A). The multiplicity of the zero eigenvalue equals dim(ker A), which for a DAG adjacency matrix equals the number of "source" vertices (theorems with no dependencies). The key insight is that the *spectral gap* — the smallest nonzero eigenvalue — measures the weakest co-dependency link in the graph, analogous to algebraic connectivity for undirected graphs. A vanishing spectral gap as the library grows would indicate that the domain is fragmenting into disconnected clusters, while a growing gap indicates increasing coherence. Why now? The quadratic form characterization (vᵀCv = ‖Av‖²) we proved gives a variational characterization of the spectral gap that can be exploited for bounds.

## 3. Moment-Cumulant Relations for Spectral Density

The trace formula tr(Cᵏ) computes the k-th spectral moment of the coherence matrix. For k=1 we proved this equals the number of edges; for k=2 it counts the number of "co-dependency quadrilaterals" (pairs of theorems that share two common dependents). The key insight is that the moment sequence {tr(Cᵏ)/n} determines the empirical spectral distribution, and its convergence to a Marchenko-Pastur or semicircle law would constitute evidence for the random-matrix universality conjecture. Computing these moments is purely combinatorial — each moment counts a specific class of subgraph pattern. Why now? With the trace formula formalized, extending to higher moments (k=2,3,4) is a concrete, incremental computation that tests the universality conjecture without requiring the full machinery of random matrix theory.

## 4. Graded Decomposition of DAG Coherence

Every DAG admits a topological ordering that partitions vertices into "levels" (by longest-path depth). The coherence matrix C then has a natural block structure: C_{ij} = 0 whenever vertices i and j are at the same level and share no common dependent. The key insight is that this block structure decomposes the spectrum of C into contributions from inter-level connectivity, yiel
```

## Your task

Produce the deliverables listed above. Reference the specific theorems and
results in the Lean code by their @file path and statement. The Lean file is
the source of truth — your prose must accurately explain it.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
