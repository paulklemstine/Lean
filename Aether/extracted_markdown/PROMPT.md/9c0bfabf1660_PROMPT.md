
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

**Title**: Proof Phase Transitions: Sharp Thresholds in Random Formal Theories
**Domain**: Geometry
**Mathematical framing**: Conjecture: For natural families of randomly generated first-order axiom systems with bounded symbol complexity and a fixed theorem schema φ_n, there exists a nontrivial critical clause-density parameter c* such that the probability that φ_n has a proof of length polynomial in n exhibits a sharp threshold at c* as n → ∞. Test: Define an ensemble of random formal theories (for example, random Horn, equational, or bounded-quantifier axiom sets), fix theorem families φ_n, and empirically/theoretically measure whether short-provability transitions from asymptotically unlikely to asymptotically likely within a vanishing-width window around some c*. The conjecture is refuted if no sharp threshold appears across robust ensembles or if the transition width remains extensive. Impact: Establishes a statistical-mechanics theory of provability, giving predictive tools for theorem-prover difficulty, phase diagrams for automated reasoning, and new links between proof complexity, random structures, and computational hardness.
Research domain: Geometry
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
# Future Directions: Proof Phase Transitions

## 1. Quantitative Threshold Width Bounds via the LYM Inequality

The antichain structure of minimal witnesses (proved in `minimal_witnesses_antichain`) immediately suggests that the "width" of the phase transition — the range of densities where a monotone property transitions from rarely to commonly satisfied — can be bounded using the LYM (Lubell–Yamamoto–Meshalkin) inequality. Specifically, for a monotone property P on subsets of [n], the number of distinct cardinalities k at which P is "partially" satisfied (i.e., some but not all k-subsets satisfy P) should be O(√n).

The key insight is that the collection of minimal witnesses forms an antichain in the powerset lattice, and the LYM inequality constrains antichain "spread" across levels of the Boolean lattice, forcing the transition region to be narrow. Why now? We have formalized the antichain structure and the monotone threshold framework; the LYM inequality itself is a purely combinatorial statement amenable to formalization, and combining these two results would yield the first formal proof of a sharp threshold width bound.

## 2. Probabilistic Threshold Sharpness via Margulis–Russo Formula

The Margulis–Russo formula states that for a monotone Boolean function f on {0,1}^n with Bernoulli(p) measure, dp/dp [Pr(f=1)] = Σ_i I_i(f), where I_i is the influence of coordinate i. This formula is the analytic engine behind all sharp threshold results (Friedgut–Kalai, Bourgain). Formalizing it would enable a quantitative phase transition theory within Lean.

The key insight is that the Margulis–Russo formula converts the question "is the threshold sharp?" into a question about total influence, which can be bounded using hypercontractivity or Friedgut's junta theorem. Why now? Mathlib's measure theory and probability infrastructure has matured significantly. The monotone predicate framework we built provides the combinatorial foundation, and the formula itself is a relatively short derivation from the product measure structure on the Boolean cube.

## 3. Resolution Proof Length Thresholds for Random k-CNF

For random k-CNF formulas with n variables and m = cn clauses, it is known that satisfiability undergoes a sharp phase transition at a critical density c_k*. A parallel question — which our framework directly addresses — is whether the *length* of the shortest resolution proof of unsatisfiability also exhibits a threshold. Specifically: is there a density c** > c_k* such that for c < c**, random k-CNF instances (when unsatisfiable) require exponential-length resolution proofs, while for c > c**, polynomial-length proofs exist?

The key insight is that our `Derivable` type and monotonicity theorem (`derivable_mono`) provide the formal backbone for modeling resolution derivations, and the threshold existence theorem (`threshold_upper_set`) already gives the structural skeleton — what remains is instantiating it with resolution-specific combinatorics. Wh
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
