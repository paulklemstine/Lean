
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
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Formally verified framework (`Computation/SpectralChain/`)
**Domain**: Applications
**Mathematical framing**: # Future Directions: Spectral Chain Framework

## What Was Established

This cycle produced a formally verified framework (`Computation/SpectralChain/`) connecting spectral gaps, conductance, mixing times, and phase transitions in finite reversible Markov chains. All 17 theorems compile without `sorry` and use only standard axioms. The framework spans four mathematical domains:

- **Spectral graph theory**: Dirichlet forms, variance, spectral gaps (Poincaré inequality)
- **Probability**: Total variation distance, mixing time bounds, variance contraction
- **Geometry**: Conductance (Cheeger constant), flow symmetry, weight complement identity
- **Combinatorics**: Phase classification (fast/critical/frozen), monotonicity

The key structural result is the **mixing-divergence bridge** (`mixing_diverges_at_zero_gap`): as the spectral gap approaches zero, the mixing time can be made arbitrarily large. Combined with the mixing time monotonicity theorems and phase classification, this gives a rigorous foundation for studying phase transitions through spectral gaps.

---

## Direction 1: Cheeger's Inequality from First Principles

The discrete Cheeger inequality—`h²/2 ≤ γ ≤ 2h` where h is the conductance and γ the spectral gap—is the most important missing result in the framework. The key insight is that the proof requires constructing a specific "level set" test function from the optimal Cheeger cut, then bounding its Rayleigh quotient. This is fundamentally different from the abstract certification approach used here. Why now? The framework already has `flowOut`, `weight`, `DirichletForm`, `Var`, and the Poincaré inequality structure. The missing piece is the "co-area formula" for finite graphs that relates the Dirichlet form of a function to the flows across its level sets. Formalizing this inequality would complete the conductance → spectral gap link in the chain.

## Direction 2: Geometric Convergence of Markov Chains

The variance contraction theorem—`Var(P^t f) ≤ (1-γ)^{2t} · Var(f)`—quantifies how the spectral gap controls the rate of convergence. The key insight is that this follows from the spectral decomposition of the transition operator in L²(π): the Poincaré inequality implies `‖Pf - E[f]‖² ≤ (1-γ)² ‖f - E[f]‖²`, and iterating gives geometric decay. Why now? The current framework has `applyP`, `Var`, `DirichletForm`, and `poincare_weakening`. Formalizing the L²(π) inner product space structure for reversible chains would unlock the contraction theorem and, more broadly, the full spectral theory of self-adjoint operators on finite-dimensional Hilbert spaces.

## Direction 3: Log-Sobolev Strengthening of Mixing Bounds

The log-Sobolev constant α gives the improved bound `t_mix(ε) ≤ (1/2α) · log log(1/ε)` versus the spectral gap bound `t_mix(ε) ≤ (1/γ) · log(n/ε)`. The key insight is that the relationship α ≤ γ ≤ 2α (for product chains) means the log-Sobolev constant interpolates between spectral and entropic mixing. Why now? The `mixingBound` function and `mixing_bound_scaling` theorem provide the infrastructure for comparing mixing time formulas. A `LogSobolevBound` structure parallel to `SpectralGapCert` could encode the modified log-Sobolev inequality `Ent(f² dμ) ≤ (2/α) E(f,f)`, and the analog of `mixing_diverges_at_zero_gap` for the log-Sobolev constant would quantify the improvement.

## Direction 4: Spectral Gap of Explicit CSP Chains

Computing the spectral gap of the swap Markov chain on small grid puzzles (3×3 Latin squares, 4×4 Shidoku) would provide the first concrete numerical values in the framework. The key insight is that for n ≤ 4, the state space is small enough (≤ 288 solutions for Shidoku) that the transition matrix can be explicitly constructed and its eigenvalues computed via `native_decide` or rational arithmetic. Why now? The `ReversibleChain` and `SpectralGapCert` structures are ready to receive concrete instances. Formalizing even one explicit chain (e.g., the 2-state chain with known gap) would test the framework's usability and provide a template for larger computations.

## Direction 5: Tropical Spectral Gap Bounds

The tropical (min-plus) spectral radius of a non-negative matrix provides combinatorial lower bounds on the classical spectral gap that bypass the worst-case nature of Cheeger's inequality. The key insight is that for structured matrices arising from CSP transition graphs, the tropical eigenvalue (= minimum cycle mean) can be computed in polynomial time via Howard's algorithm, while Cheeger's inequality requires optimizing over exponentially many cuts. Why now? The project already has tropical algebra infrastructure in `Tropical/`. Connecting the `ReversibleChain` type to tropical matrix representations would bridge two existing parts of the codebase and could yield tighter spectral gap lower bounds for specific CSP instances.

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/ClosureExtractorDuality.lean
/-
# Closure–Extractor Duality

## Semantic Dictionary
- **Closed sets** ↔ entropy carriers (subsets with maximal dependency structure)
- **Closure-stable functionals** ↔ seed tests (predicates respecting dependency equivalence)
- **Evaluation matrix rows** ↔ extractor coordinates (binary encoding of functional evaluations)
- **Rank defect** ↔ entropy loss (gap between functional count and separation capacity)
- **Reconstruction** ↔ certified seed synthesis from matrix factorization data

## Overview
We formalize a finite duality between closure-generated dependency structures and
seeded extractor families. The main results:

1. **Closure invariance of deficiency**: The deficiency `|cl(A)| - |A|` depends only on
   the closure of A, not on A itself (for closed sets).
2. **Encoding–separation equivalence**: A family of closure-stable predicates separates
   elements in large closed sets iff the induced encoding map is injective on those sets.
3. **Main duality theorem**: Existence of a seed-indexed separating family ↔ existence of
   a closure-stable functional family with bounded rank defect.
4. **Certified reconstruction**: From a separating evaluation matrix, one can explicitly
   construct a seed family with certified entropy-loss bounds.
-/

import Mathlib

open Finset Function

set_option linter.unusedSectionVars false

/-! ## §1. Closure Operators on Finite Types -/

/-- A closure operator on `Finset X` satisfying extensivity, monotonicity, and idempotence. -/
structure FinsetClosureOp (X : Type*) [DecidableEq X] where
  cl : Finset X → Finset X
  extensive : ∀ A : Finset X, A ⊆ cl A
  monotone : ∀ {A B : Finset X}, A ⊆ B → cl A ⊆ cl B
  idempotent : ∀ A : Finset X, cl (cl A) = cl A

variable {X : Type*} [DecidableEq X] [Fintype X]

namespace FinsetClosureOp

/-- A set is closed if it is a fixed point of the closure operator. -/
def IsClosed (op : FinsetClosureOp X) (C : Finset X) : Prop :=
  op.cl C = C

instance (op : FinsetClosureOp X) : DecidablePred op.IsClosed :=
  fun C => decEq (op.cl C) C

/-- The closure of any set is closed. -/
theorem cl_isClosed (op : FinsetClosureOp X) (A : Finset X) :
    op.IsClosed (op.cl A) := op.idempotent A

/-- Deficiency of a set A: `|cl(A)| - |A|`. -/
def deficiency (op : FinsetClosureOp X) (A : Finset X) : ℕ :=
  (op.cl A).card - A.card

/-- Entropy surrogate: `|X| - deficiency(A)`. -/
def entropySurrogate (op : FinsetClosureOp X) (A : Finset X) : ℕ :=
  Fintype.card X - op.deficiency A

/-- Deficiency of a closed set is zero. -/
theorem deficiency_of_closed (op : FinsetClosureOp X) (C : Finset X)
    (hC : op.IsClosed C) : op.deficiency C = 0 := by
  unfold deficiency IsClosed at *
  rw [hC]
  omega

/-- Entropy surrogate of a closed set equals `|X|`. -/
theorem entropySurrogate_of_closed (op : FinsetClosureOp X) (C : Finset X)
    (hC : op.IsClosed C) : op.entropySurrogate C = Fintype.card X := by
  simp [entropySurrogate, deficiency_of_closed op C hC]

end FinsetClosureOp

/-! ## §2. Closure-Stable Predicates and Functionals -/

/-- Two elements are closure-equivalent if their singleton closures are equal. -/
def closureEquiv (op : FinsetClosureOp X) (x y : X) : Prop :=
  op.cl {x} = op.cl {y}

/-- A closure-stable predicate: a Boolean predicate on elements of X that is
    constant on closure-equivalence classes. These are the "seed tests" in the
    cryptographic dictionary. -/
structure ClosureStablePred (op : FinsetClosureOp X) where
  test : X → Bool
  stable : ∀ x y : X, closureEquiv op x y → test x = test y

/-- The encoding map induced by a family of closure-stable predicates.
    Maps each element to its vector of predicate values. -/
def predicateEncoding {n : ℕ} (op : FinsetClosureOp X)
    (Φ : Fin n → ClosureStablePred op) (x : X) : Fin n → Bool :=
  fun i => (Φ i).test x

/-! ## §3. Separation Definitions -/

/-- A family of closure-stable predicates *k-separates* if for every closed set C
    with |C| ≥ k, and every pair of distinct elements in C, some predicate
    distinguishes them. -/
def PredicateFamilySeparates (op : FinsetClosureOp X) {n : ℕ}
    (Φ : Fin n → ClosureStablePred op) (k : ℕ) : Prop :=
  ∀ C : Finset X, op.IsClosed C → k ≤ C.card →
    ∀ x y : X, x ∈ C → y ∈ C → x ≠ y →
      ∃ i : Fin n, (Φ i).test x ≠ (Φ i).test y

/-- A seed-indexed family of maps *k-separates on closed sets* if for every closed set C
    with |C| ≥ k, and every pair of distinct elements in C, some seed gives different
    outputs. -/
def SeedFamilySeparates (op : FinsetClosureOp X) {Y Seed : Type*}
    [DecidableEq Y]
    (f : Seed → X → Y) (k : ℕ) : Prop :=
  ∀ C : Finset X, op.IsClosed C → k ≤ C.card →
    ∀ x y : X, x ∈ C → y ∈ C → x ≠ y →
      ∃ s : Seed, f s x ≠ f s y

/-- A seed-indexed family is *closure-compatible* if elements with the same
    singleton closure always receive the same output for each seed. -/
def ClosureCompatible (op : FinsetClosureOp X) {Y Seed : Type*}
    (f : Seed → X → Y) : Prop :=
  ∀ (s : Seed) (x y : X), closureEquiv op x y → f s x = f s y

/-! ## §4. Entropy Loss and Rank Defect -/

/-- Entropy loss bound for a seed family: a simple combinatorial bound stating
    the seed-output space is large enough. -/
def EntropyLossBound {Seed Y : Type*} [Fintype Seed] [Fintype Y]
    (_f : Seed → X → Y) (e : ℕ) : Prop :=
  e ≤ Fintype.card Seed * Fintype.card Y

/-! ## §5. Evaluation Matrix -/

/-- A matrix k-separates closed sets if for each large closed set, distinct
    elements produce distinct column vectors. -/
def MatrixSeparatesClosedSets (op : FinsetClosureOp X) {n : ℕ}
    (M : Fin n → X → Bool) (k : ℕ) : Prop :=
  ∀ C : Finset X, op.IsClosed C → k ≤ C.card →
    ∀ x y : X, x ∈ C → y ∈ C → x ≠ y →
      ∃ i : Fin n, M i x ≠ M i y

/-! ## §6. Core Theorems -/

/-- **Encoding–Separation Equivalence**: A predicate family k-separates iff
    the induced encoding map is injective on every large closed set. -/
theorem encoding_separates_iff (op : FinsetClosureOp X) {n : ℕ}
    (Φ : Fin n → ClosureStablePred op) (k : ℕ) :
    PredicateFamilySeparates op Φ k ↔
    (∀ C : Finset X, op.IsClosed C → k ≤ C.card →
      ∀ x y : X, x ∈ C → y ∈ C → x ≠ y →
        predicateEncoding op Φ x ≠ predicateEncoding op Φ y) := by
  constructor
  · intro h C hC hk x y hx hy hne
    obtain ⟨i, hi⟩ := h C hC hk x y hx hy hne
    intro heq
    exact hi (congr_fun heq i)
  · intro h C hC hk x y hx hy hne
    have hneq := h C hC hk x y hx hy hne
    by_contra hall
    push_neg at hall
    exact hneq (funext (fun i => by simpa using hall i))

/-
**Backward Direction**: A family of closure-stable predicates that k-separates
    gives rise to a seed family that k-separates on closed sets.
    Construction: use a single "seed" and set `f () x := predicateEncoding Φ x`.
-/
theorem duality_backward
    (op : FinsetClosureOp X)
    {n : ℕ}
    (Φ : Fin n → ClosureStablePred op)
    (k : ℕ)
    (hsep : PredicateFamilySeparates op Φ k) :
    SeedFamilySeparates (Y := Fin n → Bool) op
      (fun (_ : Unit) x => predicateEncoding op Φ x) k := by
  exact fun C hC hk x y hx hy hxy => ⟨ ⟨ ⟩, fun h => hxy <| by simpa using encoding_separates_iff op Φ k |>.1 hsep C hC hk x y hx hy hxy h ⟩

/-
**Forward Direction**: A closure-compatible seed family that k-separates gives rise
    to closure-stable predicates that k-separate.

    Construction: for each `(s, y)` pair define `φ(x) := (f s x == y)`.
    Closure-compatibility ensures stability.
-/
theorem duality_forward
    (op : FinsetClosureOp X)
    {Y Seed : Type*} [DecidableEq Y] [Fintype Y] [Fintype Seed]
    (f : Seed → X → Y)
    (hcompat : ClosureCompatible op f)
    (k : ℕ)
    (hsep : SeedFamilySeparates op f k) :
    ∃ (m : ℕ) (Φ : Fin m → ClosureStablePred op),
      PredicateFamilySeparates op Φ k := by
  refine' ⟨ _, _, _ ⟩;
  exact Fintype.card ( Seed × Y );
  refine' fun i => ⟨ fun x => ( f ( Fintype.equivFin ( Seed × Y ) |>.symm i |>.1 ) x ) = ( Fintype.equivFin ( Seed × Y ) |>.symm
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Spectral Chain Framework

## What was established (this cycle)

The file `Computation/SpectralChain/Core.lean` builds, from first principles, a
formally verified bridge across four mathematical domains for **finite reversible
Markov chains**. Every main theorem compiles with `sorry = 0` and depends only on
the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

The cornerstone object is `ReversibleChain`: a stationary distribution `π`, a
stochastic kernel `P`, and detailed balance `π_i P_ij = π_j P_ji`. On top of it we
define the edge weight `weight i j = π_i P_ij`, the stationary `mean`, the `Var`iance,
the `DirichletForm` (energy), the cut flow `flowOut`, the set measure `piSet`, and a
`SpectralGapCert` (a Poincaré certificate `γ · Var(f) ≤ E(f)`).

The proven results form a genuine geometry → spectral → probability chain:

- **`weight_symm`** — detailed balance is exactly symmetry of the edge weight.
- **`Var_eq_double_sum`** — the variance double-sum identity
  `Var(f) = ½ ∑_{i,j} π_i π_j (f_i − f_j)²`.
- **`flowOut_symm`** — the flow out of a cut equals the flow into it.
- **`DirichletForm_indicator` / `Var_indicator`** — for a set indicator the energy is
  the cut flow `flowOut(S)` and the variance collapses to `π(S)(1 − π(S))`.
- **`cheeger_easy_inequality`** — the *easy* direction of the discrete Cheeger
  inequality: any Poincaré gap obeys `γ ≤ 2 · flowOut(S)/π(S)`. This is the key
  cross-domain bridge (geometry controls spectrum).
- **`mixingBound_antitone` / `mixing_diverges_at_zero_gap`** — the spectral-gap mixing
  bound `(1/γ)·log(n/ε)` is antitone in `γ`, and diverges to `+∞` as `γ → 0⁺`: the
  structural phase-transition statement.

A concrete `twoState` chain (`π = (½,½)`, `P ≡ ½`) instantiates the framework with
real numbers, and `cheeger_hard_direction_conjecture` records the shape of the open
hard half of Cheeger's inequality as a `sorry`ed target.

---

## Direction 1: The hard direction of Cheeger's inequality

The framework proves `γ ≤ 2h` (where `h` is the conductance); the missing companion
is `h²/2 ≤ γ`, already stubbed as `cheeger_hard_direction_conjecture`. **The key
insight is** that the proof is not a certificate manipulation at all but a
*construction*: from the eigenfunction realizing the gap one extracts an ordered
level-set sweep, and a discrete co-area identity rewrites `DirichletForm(f)` as an
integral of the cut flows `flowOut({f ≥ t})` over the threshold `t`. Bounding each
level-set conductance below by `h` and applying Cauchy–Schwarz yields the quadratic
loss `h²/2`. **Why now?** The pieces it consumes — `flowOut`, `piSet`,
`DirichletForm`, `Var`, and the `SpectralGapCert` interface — are all in place and
already proven mutually compatible by `DirichletForm_indicator` and `Var_indicator`;
the only genuinely new lemma needed is the finite co-area formula
`DirichletForm(f) = ∑_t flowOut({f ≥ t}) · Δt`, which is a finite telescoping sum.

## Direction 2: Geometric (variance) cont
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
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
