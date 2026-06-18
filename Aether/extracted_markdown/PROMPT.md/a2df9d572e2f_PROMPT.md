
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

**Title**: **Entropy-Bounded Computation (EBC)** framew
**Domain**: Computation
**Mathematical framing**: # Future Directions: Computational Complexity as Physical Law

## Synthesis

This research cycle established the **Entropy-Bounded Computation (EBC)** framework, which formalizes the connection between computational complexity and thermodynamics through Landauer's principle. The central result is the **entropy gap theorem**: the thermodynamic cost gap between polynomial and exponential search grows without bound, providing a physical interpretation of the P ≠ NP conjecture. The framework consists of five interconnected structures (EntropyBudgetSystem, MaxwellDemon, ReversibleComputation, IrreversibleStep, ComplexityEntropyDuality) with 13 formally verified theorems.

The most promising cross-domain connection is between the **Maxwell's demon bound** (from the Shared/CryptoEntropyBridges catalog) and **computational search complexity**. Our demon composition theorem shows that thermodynamic irreversibility composes additively across computational agents, which connects to both cryptographic security (breaking keys requires entropy proportional to key length) and the polynomial hierarchy (each level requires strictly more entropy). The entropy gap theorem provides the mathematical foundation for a physically-grounded complexity theory.

The highest breakthrough potential lies in **Direction 1 (Quantum Entropy Budget)**: quantum computation is fundamentally reversible except for measurement, suggesting that the EBC framework should yield tighter bounds for quantum complexity classes. If the quantum extension shows that BQP has a different entropy profile than P, it would provide a new approach to the BQP vs. P question — one grounded in physics rather than pure combinatorics.

---

### Direction 1: Quantum Entropy Budget and the Measurement Bottleneck

**Conjecture**: In a quantum extension of the EBC framework, the entropy cost of a quantum computation is determined entirely by the number of measurements, not the number of unitary gates. Formally: for a quantum circuit with U unitary gates and M measurements, the total Landauer cost is exactly M · kT · ln(2), independent of U. This implies that BQP computations with polynomially many measurements have polynomial entropy cost, while QMA-hard problems require exponentially many measurements under standard complexity assumptions.

**Test**: 
1. Formalize a `QuantumEntropyBudgetSystem` where steps are either unitary (cost 0) or measurement (cost kT·ln(2)).
2. Prove that the total cost equals the measurement count times the Landauer unit.
3. Implement Grover's algorithm and Shor's algorithm in the framework and compute their entropy costs.
4. Compare: Grover uses O(√N) measurements, Shor uses O(n²) measurements. Check whether these match empirical predictions.

**Impact**: If true, this gives a clean physical characterization of quantum advantage: quantum computers are powerful not because they compute differently, but because they defer entropy production until measurement. This would connect BQP to a physical resource (measurement budget) rather than an abstract computational model. If false, it reveals that quantum coherence has hidden entropy costs, challenging the deferred measurement principle.

**Catalog References**: `Shared/CryptoEntropyBridges.lean` (maxwell_demon_bound), `Speculative/ComplexityPhysics/Theorems.lean` (step_count_bounded_by_budget, reversible_comp_is_id)

**Proof Strategy**: 
1. Define `QuantumStep` as either `Unitary (cost = 0)` or `Measurement (cost = kT·ln(2))`.
2. Prove cost additivity via the existing demon_composition_cost pattern.
3. For the measurement bottleneck theorem, show that any quantum circuit can be rearranged (by the deferred measurement principle) to have all measurements at the end, concentrating all entropy cost.
4. Connect to BQP by bounding the measurement count for polynomial-time quantum algorithms.

**Domain Bridges**: Computation (entropy budget) ↔ Physics (quantum measurement) ↔ Cryptography (post-quantum security)

**Lineage**: Builds on entropy_gap_unbounded, step_count_bounded_by_budget, reversible_comp_is_id from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Entropy Complexity Classes and the Thermodynamic Polynomial Hierarchy

**Conjecture**: Define ENTROPY(f(n)) as the class of problems solvable with total Landauer cost at most f(n) · kT · ln(2). Then:
1. P ⊆ ENTROPY(n^c) for some constant c depending on the problem.
2. NP ⊆ ENTROPY(2^n) but NP ⊄ ENTROPY(n^c) for any c (assuming P ≠ NP).
3. The entropy hierarchy ENTROPY(n) ⊊ ENTROPY(n²) ⊊ ENTROPY(n³) ⊊ ... is strict.
4. ENTROPY(log n) = L (logarithmic space).

Part (3) is the most surprising claim: it asserts that entropy complexity has no "speed-up" theorem — you cannot simulate n² entropy with n entropy, even approximately.

**Test**:
1. Formalize ENTROPY(f) as a complexity class within the EBC framework.
2. Prove the containments P ⊆ ENTROPY(n^c) by analyzing standard algorithms.
3. For part (3), attempt to prove a hierarchy theorem using diagonalization.
4. Test computationally: implement sorting algorithms (merge sort vs. bubble sort) and measure their actual Landauer costs. Merge sort should use O(n log n) entropy; bubble sort O(n²).

**Impact**: If the entropy hierarchy is strict, it provides a new complexity hierarchy that is *physically meaningful* — each level corresponds to a different thermodynamic regime. This would be the first complexity hierarchy with a direct physical interpretation. If not strict, it means entropy can be "recycled" in unexpected ways.

**Catalog References**: `Speculative/ComplexityPhysics/Theorems.lean` (entropy_budget_monotone, entropy_gap_unbounded), `Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm)

**Proof Strategy**: 
1. Define ENTROPY(f) formally as `{L | ∃ EBS with budget = f(n) that decides L}`.
2. For P ⊆ ENTROPY(n^c): any P algorithm makes poly(n) steps, each costing at most 1 bit.
3. For hierarchy strictness: adapt the time hierarchy theorem proof, using the entropy gap theorem to show that more entropy budget allows solving strictly more problems.
4. The diagonalization argument: construct a language L_k that can be decided with n^(k+1) entropy but not n^k entropy.

**Domain Bridges**: Computation (complexity classes) ↔ Physics (entropy budget) ↔ Logic (hierarchy theorems)

**Lineage**: Directly extends entropy_budget_monotone and entropy_gap_unbounded.

**Ambition**: grand_challenge

---

### Direction 3: Landauer Cost of Specific Algorithms

**Conjecture**: The Landauer cost of comparison-based sorting of n elements is exactly ⌈log₂(n!)⌉ · kT · ln(2), matching the information-theoretic lower bound. Any sorting algorithm that uses fewer comparisons than ⌈log₂(n!)⌉ must use non-comparison operations that cost additional entropy. In other words, the Landauer cost provides an independent proof of the Ω(n log n) comparison-based sorting lower bound.

**Test**:
1. Formalize comparison-based sorting in the EBC framework, where each comparison is an IrreversibleStep that halves the search space.
2. Prove that ⌈log₂(n!)⌉ comparisons are necessary via the entropy budget.
3. Implement merge sort and quicksort in the framework and verify their entropy costs match the theoretical predictions.
4. Check boundary case: for n = 1, cost should be 0; for n = 2, cost should be kT·ln(2).

**Impact**: This would be the first formally verified proof that the sorting lower bound is a *physical law*, not just an information-theoretic bound. It demonstrates that the EBC framework can recover known complexity bounds from thermodynamic principles.

**Catalog References**: `Speculative/ComplexityPhysics/Foundations.lean` (IrreversibleStep, landauerCost), `Speculative/ComplexityPhysics/Theorems.lean` (one_bit_erasure_cost, step_count_bounded_by_budget)

**Proof Strategy**:
1. Model a comparison as an IrreversibleStep from Fin(n!) (permutation space) to two halves.
2. After k comparisons, the remaining search space has size at most n!/2^k.
3. The search terminates when the space has size 1, requiring k ≥ log₂(n!).
4. Each comparison costs kT·ln(2) by one_bit_erasure_cost, giving total cost ≥ ⌈log₂(n!)⌉ · kT·ln(2).

**Domain Bridges**: Computation (sorting algorithms) ↔ Physics (Landauer cost) ↔ EML (information theory)

**Lineage**: Builds on IrreversibleStep, one_bit_erasure_cost, step_count_bounded_by_budget.

**Ambition**: extension

---

### Direction 4: Reversible Computing and Bennett's Pebble Game

**Conjecture**: In the EBC framework, any irreversible computation of T steps on S space can be made reversible using O(T · S) time and O(S · log T) space (Bennett's result). Formalizing this in the EBC framework gives: the entropy cost of simulating an irreversible computation reversibly is exactly 0, but the time overhead is multiplicative. This creates a time-entropy tradeoff: you can eliminate entropy cost entirely at the price of a polynomial time increase.

**Test**:
1. Formalize Bennett's pebble game in Lean as a ReversibleComputation.
2. Prove that the reversible simulation has zero Landauer cost (using reversible_comp_is_id).
3. Prove the time overhead bound: the reversible simulation takes O(T · S) steps.
4. Test: implement a reversible AND gate using Toffoli gates and verify zero entropy cost.

**Impact**: This direction explores the *escape hatch* from the entropy budget: reversible computing avoids Landauer costs but pays in time. The time-entropy tradeoff is fundamental to understanding whether thermodynamics truly constrains complexity or merely introduces overhead.

**Catalog References**: `Speculative/ComplexityPhysics/Foundations.lean` (ReversibleComputation), `Speculative/ComplexityPhysics/Theorems.lean` (reversible_comp_is_id, reversible_involution)

**Proof Strategy**:
1. Define a `PebbleGame` structure modeling Bennett's construction.
2. Show the pebble game produces a ReversibleComputation.
3. Count the number of pebbling steps to get the time bound.
4. Use reversible_comp_is_id to show zero entropy cost.

**Domain Bridges**: Computation (reversible circuits) ↔ Physics (entropy-free computation) ↔ Cryptography (side-channel resistance)

**Lineage**: Extends reversible_comp_is_id and ReversibleComputation.

**Ambition**: extension

---

### Direction 5: Entropy Production Rate and Computational Speed Limits

**Conjecture**: There exists a fundamental speed limit on computation analogous to the Margolus-Levitin bound: no physical system can perform more than 2E/(πℏ) irreversible operations per second, where E is the system's energy above ground state. Combined with the Landauer cost per operation, this gives a maximum computational throughput of 2E/(πℏ · kT · ln 2) irreversible bits per second. For a 1-watt computer at room temperature, this is approximately 4.4 × 10³¹ bit operations per second.

**Test**:
1. Formalize the Margolus-Levitin bound as an axiom in the EBC framework.
2. Derive the maximum bit rate from the bound and Landauer's principle.
3. Compute the maximum bit rate for realistic parameters (1W, 300K, 1 kg).
4. Compare with actual computer performance (modern CPUs achieve ~10¹⁰ ops/sec, far below the limit).

**Impact**: This connects the EBC framework to quantum mechanics (Margolus-Levitin) and gives absolute physical limits on computation. The gap between current computers and the physical limit (~10²¹ factor) suggests enormous room for improvement in computational efficiency.

**Catalog References**: `Speculative/ComplexityPhysics/Theorems.lean` (step_count_bounded_by_budget), `Shared/CryptoEntropyBridges.lean` (maxwell_demon_bound)

**Proof Strategy**:
1. Introduce the Margolus-Levitin bound as a parameter in EntropyBudgetSystem.
2. Derive budget = (2E · τ) / (πℏ · kT · ln 2) from the bound.
3. Apply step_count_bounded_by_budget with c = kT·ln(2).
4. Compute explicit values for standard physical parameters.

**Domain Bridges**: Physics (quantum speed limits) ↔ Computation (throughput bounds) ↔ EML (information rates)

**Lineage**: Builds on step_count_bounded_by_budget and the full EBC framework.

**Ambition**: extension

Research domain: Computation
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
# Future Directions: Entropy-Bounded Computation

## What We Built

The EBC framework formalizes the connection between computational complexity and thermodynamics through Landauer's principle in Lean 4. The core structures (LandauerParams, EntropyBudgetSystem, IrreversibleStep, StepSequence, ReversibleComputation, MaxwellDemon, SearchProblem) support fully verified theorems about entropy cost additivity, reversible computation, budget constraints, and the entropy gap between polynomial and exponential search.

All 13 declarations (9 theorems, 3 definitions, 4 examples) compile without sorry, using only standard axioms.

---

## Direction 1: Quantum Measurement as the Sole Entropy Source

The EBC framework currently treats all irreversible steps uniformly. In quantum computing, unitary gates are perfectly reversible (zero entropy cost), while measurements collapse superpositions and produce entropy. The key insight is that the EBC framework can be refined to distinguish reversible gates (cost 0) from measurement gates (cost kT·ln 2), giving a resource theory where quantum advantage is characterized by measurement budget rather than gate count.

**Testable conjecture**: Define `QuantumStep` as an inductive type with `Unitary (cost = 0)` and `Measurement (cost = tempFactor)` variants. Prove that the total cost of a quantum circuit equals `(number of measurements) * tempFactor`, independent of the number of unitary gates. Then formalize the deferred measurement principle as a theorem that any mixed circuit can be rearranged to have measurements only at the end, preserving total cost.

**Why now?** The `landauer_cost_additive` and `reversible_is_involution` theorems from this cycle provide the exact compositional structure needed. Unitary gates compose as `ReversibleComputation` (zero cost by `reversible_is_involution`), and measurements compose additively (by `landauer_cost_additive`). The framework is ready for this extension without architectural changes.

---

## Direction 2: Strict Entropy Hierarchy via Diagonalization

The `entropy_budget_monotone` theorem shows that larger budgets permit more computations (containment). But does strictly more budget permit strictly more problems? The key insight is that the entropy gap theorem (`exp_eventually_exceeds_poly`) provides the separation needed for a diagonalization argument: a problem solvable with n^(k+1) entropy budget can simulate and diagonalize against all n^k-bounded computations, because the simulation overhead is polynomial and the gap is superpolynomial.

**Testable conjecture**: Define `ENTROPY(f) := {problems decidable by an EBS with budget f(n) * tempFactor}`. Prove that for k ≥ 1, there exists a problem in ENTROPY(n^(k+1)) \ ENTROPY(n^k). The proof should formalize a universal simulation argument where the simulator uses budget proportional to the simulated computation's budget plus overhead for the diagonalization step.

**Why now?** The `step_count_bounded_by_budget` theorem gives th
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
