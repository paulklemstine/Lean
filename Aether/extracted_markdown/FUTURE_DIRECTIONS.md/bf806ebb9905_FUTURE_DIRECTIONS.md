# Future Directions: Proof Strategy Mining

## Overview

The formalization of finite-verification-plus-descent schemas opens several concrete research directions. Each is stated as a falsifiable conjecture with a clear validation path.

---

### 1. Well-Founded Classification Schema

**Conjecture**: Every theorem in a formal mathematics catalog whose proof combines a finite verified region with a dominance/reduction step can be refactored as a direct instance of `global_of_base_and_wf_descent` — that is, the theorem follows by instantiating the schema with appropriate choices of `r`, `B`, and `P`.

**Test**: For each candidate theorem (e.g., `goldbach_from_finite_check_and_cover`, `finite_classification_from_dominance`), extract the implicit well-founded relation `r`, base predicate `B`, and target property `P`. Attempt to restate the theorem as `global_of_base_and_wf_descent r P B hB hstep hwf`. Success means the original proof factors through the schema; failure identifies structural features not captured by single-step descent.

**Impact**: If true, this would demonstrate that a single reusable theorem can replace dozens of bespoke induction arguments across different mathematical domains, dramatically reducing proof maintenance costs and enabling compositional proof engineering.

---

### 2. Finite Branching Search-to-Proof Compiler

**Conjecture**: A finitely branching reduction relation with decidable terminal certificates admits a generic theorem converting exhaustive bounded search plus well-foundedness into a universal correctness certificate. Specifically, there exists a theorem of the form:

```
theorem search_to_proof
  {α : Type*} [DecidableEq α]
  (r : α → Finset α)    -- finitely branching reduction
  (terminal : α → Bool)  -- decidable base check
  (P : α → Prop)
  (hterm : ∀ a, terminal a = true → P a)
  (hstep : ∀ a, terminal a = false → ∀ b ∈ r a, P b → P a)
  (hwf : WellFounded (fun b a => b ∈ r a)) :
  ∀ a, P a
```

**Test**: Formalize finite branching trees in the proof assistant and attempt to prove the generic compiler theorem. If it succeeds, instantiate it on at least two concrete examples (e.g., game solving and constraint propagation). If it fails, identify whether the obstruction is a missing compactness condition, a decidability gap, or a structural limitation of well-founded induction.

**Impact**: If true, this would provide an automated bridge between computational search (SAT solving, model checking, exhaustive enumeration) and formal mathematical proof, enabling a new class of "computation-backed" theorems.

---

### 3. Minimal Counterexample API

**Conjecture**: A reusable API for minimal counterexample arguments — providing standard combinators for "assume a minimal bad object, derive contradiction" — can reduce the proof term size of descent-style theorems by at least 30% compared with direct strong induction proofs, across a benchmark of at least 10 theorems.

**Test**: Implement both proof styles (direct induction and minimal-counterexample API) for a suite of theorems including:
- Infinite pigeonhole principle
- König's lemma
- Every finite DAG has a topological ordering
- Dickson's lemma
- Kruskal's tree theorem (finite case)

Measure proof term size (character count of the proof term after elaboration) and dependency graph depth for both styles. The conjecture is confirmed if the API style is ≥30% shorter on average.

**Impact**: If true, this would establish minimal counterexample reasoning as a superior proof methodology for a broad class of combinatorial and algebraic results, justifying investment in API development.

---

### 4. Local-to-Global Transfer Beyond Arithmetic

**Conjecture**: The finite-check/descent schema instantiates nontrivially in quantum information theory, yielding a generic theorem that bounded local correlation constraints on measurement operators imply a global Bell-type inequality. Specifically, there exists a complexity measure μ on quantum correlation scenarios such that:
- For μ ≤ N (small systems), the Bell inequality can be verified by direct matrix computation.
- For μ > N, any scenario can be decomposed into simpler sub-scenarios with μ strictly decreasing.

**Test**: Define an abstract correlation complexity measure (e.g., number of measurement settings × dimension of Hilbert space). Formalize the decomposition lemma showing that high-complexity scenarios reduce to lower-complexity ones via partial trace or marginalization. Attempt to recover a CHSH-type bound as an instance of `global_of_finite_check_and_strict_descent`. The conjecture is refuted if the decomposition necessarily increases complexity in some coordinate.

**Impact**: If true, this would unify Bell inequality proofs across different scenarios (CHSH, Mermin, GHZ) under a single descent framework, and provide a systematic method for discovering new Bell inequalities.

---

### 5. Dominance Schemas for Tropical and Additive Structures

**Conjecture**: The dominance relations used in tropical algebraic classification theorems and additive combinatorics covering theorems can both be encoded as well-founded rank descents, allowing theorems like `finite_classification_from_dominance` and `goldbach_from_finite_check_and_cover` to share a common abstract proof via `global_of_base_and_wf_descent`.

**Test**: For each theorem:
1. Extract the implicit ordering relation on the objects being classified/covered.
2. Define a rank function μ that is strictly decreasing under the dominance/covering relation.
3. Verify that the base regime (μ ≤ N) corresponds to the finite verification component of the original proof.
4. Instantiate `global_of_base_and_wf_descent` and verify that the original theorem follows.

The conjecture is refuted if the dominance relation in either development fails to be well-founded, or if the backward transport condition `P b → P a` cannot be established from the existing proof structure.

**Impact**: If true, this would demonstrate that tropical algebra and additive combinatorics — two apparently unrelated fields — share a common proof-theoretic substrate, opening the possibility of cross-domain proof transfer: insights about descent in one domain could be mechanically translated to the other.
