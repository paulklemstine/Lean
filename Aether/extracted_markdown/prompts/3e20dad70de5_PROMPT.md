
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: Algebraic closure operators as finite idempotent semimodules with reconstruction from probe-stable generators
**Domain**: Bridges
**Mathematical framing**: Work over a finite type `α` with a closure operator `cl : Set α → Set α` satisfying extensivity, monotonicity, and idempotence. Define the closed-set lattice `Closed(cl) := {s | cl s = s}`. The project should formulate a semiring/semimodule-flavored action on predicates or characteristic functions of subsets so that closure becomes an idempotent endomorphism and closed sets become its fixed points. Main theorem A: every finite closure system induces a canonical algebraic object `S_cl` with a fixed-point poset order-isomorphic to `Closed(cl)`. Main theorem B: if `P` is a finite separating `ProbeFamily` whose probes are `ClosureStableProbe`, then for every `A : Set α`, `cl A` can be reconstructed as the intersection of all probe-kernels consistent with the probe evaluations of `A`; prove uniqueness and correctness. Main theorem C: define a closure potential decreasing under reconstruction steps and prove termination/complexity bounds for the reconstruction algorithm on finite systems. The proofs should lean on finite lattice arguments, extensionality of sets, and transport between closure-fixed points and semimodule fixed points. The outcome should be a pipeline: finite closure system -> semimodule presentation -> probe reconstruction theorem -> executable closure computation guarantees.
**Concept description**: The key insight is that a finite closure system can be upgraded from a purely order-theoretic object to an algebraic semimodule-like structure in which closed sets are exactly fixed points of an idempotent action, and then reconstructed from a small family of probe-stable generators. This is not just a renaming of existing closure language: the new content is a representation theorem and an algorithmic reconstruction pipeline linking closure operators, probe families, and finite potentials. Why now: the catalog already contains the exact ingredients in vetted bridge files — `ClosureSemimoduleSystem`, `ProbeFamily`, `ClosureStableProbe` in `Bridges/AlgebraEMLClosureComputation.lean`, `SetClosureOperator` and closed-set infrastructure in `Bridges/AlgebraEMLReconstruction.lean`, and `ClosurePotential`, `ClosureKernel`, `FiniteClosureSystem` in `Bridges/AlgebraicEMLThermodynamicFormalism.lean`. The promising direction is to prove that under finiteness and monotone/idempotent hypotheses, every finite closure operator admits a canonical semimodule presentation whose fixed-point lattice is isomorphic to the lattice of closed sets, and that a separating probe family reconstructs the closure of any subset as the meet/intersection of probe-detected kernels. A concrete target is a pair of theorems: (1) representation — from a `FiniteClosureSystem`, construct a `ClosureSemimoduleSystem` and prove equivalence between closure-fixed points and semimodule fixed points; (2) reconstruction — if a `ProbeFamily` is closure-stable and separating, then the closure operator is uniquely determined by probe responses, yielding an explicit finite algorithm for computing closures. This bridges Algebra and EML through Bridges, exploits an under-developed high-value area, and yields falsifiable statements with computational payoff rather than another abstract reformulation.
**Novelty estimate**: 0.89
**Breakthrough potential**: 0.86
Research domain: Bridges
Research mode: prove


### Lean 4 Sketch
Create a new bridge file proving an order isomorphism between `ClosedSet`-style objects from `SetClosureOperator` and fixed points of `ClosureSemimoduleSystem`; define a `SeparatesClosedSets` predicate on `ProbeFamily`; prove `cl_eq_iInter_probe_kernels` under finite hypotheses; then package an algorithmic theorem using `ClosurePotential` for termination on finite carriers.


### Catalog Context
@Bridges/AlgebraEMLClosureComputation.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Algebra–EML Turing–Myhill Reconstruction via Closure Semimodule Dynamics

This file formalizes a Myhill–Nerode-style minimal quotient reconstruction from
semiring-valued closure observables.

## Central Bridge

- **Automata theory / intrinsic computation**: closure-driven weighted transition semantics
- **Semiring-linear dynamics / Koopman-style closure evolution**: probe observables
- **Thermodynamic / quantum / cryptographic interpretations**: indistinguishability
-/

import Mathlib

universe u v w

/-! ## §1 Core Definitions -/

/-- A closure semimodule system: a deterministic transition system equipped with
a closure operator on state sets and a semiring-valued output function.

Bridge: connects automata theory to Koopman dynamics and semiring-linear algebra
via closure-enriched observational semantics. -/
structure ClosureSemimoduleSystem
    (σ : Type u) (α : Type v) (K : Type w)
    [Semiring K] where
  step : σ → α → σ
  output : σ → K
  closure : Set σ → Set σ
  closure_extensive : ∀ S : Set σ, S ⊆ closure S
  closure_mono : ∀ ⦃S T : Set σ⦄, S ⊆ T → closure S ⊆ closure T
  closure_idem : ∀ S : Set σ, closure (closure S) ⊆ closure S

/-- Bridge: a family of semiring-valued probes on states, connecting to quantum
observables and Koopman eigenfunctions. -/
structure ProbeFamily (σ : Type u) (K : Type w) [Semiring K] where
  probes : Set (σ → K)

/-- Bridge: a closure-stable probe is an observable invariant under closure expansion,
connecting to Koopman eigenfunctions and quantum coarse-grained observables. -/
def ClosureStableProbe
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (p : σ → K) : Prop :=
  ∀ S : Set σ, ∀ x ∈ M.closure S, ∃ y ∈ S, p x = p y

/-- Bridge: a Koopman-style observable pairs a probe with its spectral weight,
connecting Koopman operator theory to closure automata semantics and
thermodynamic partition functions. -/
structure ThermoKoopmanObservable (σ : Type u) (K : Type w) [Semiring K] where
  observable : σ → K
  spectralWeight : K

/-- Bridge: post-quantum indistinguishability captures the property that no
probe family can distinguish two states, connecting automata quotients to
post-quantum security via observational completeness. -/
def PostQuantumIndistinguishability
-- ... (truncated, full file has 758 lines)
```

@Bridges/AlgebraEMLReconstruction.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Algebraic–EML Tannaka Reconstruction via Closure Endomorphism Monoids

This file formalizes a reconstruction principle: a finitary closure operator on a
set is completely determined by its closed-set lattice, and hence by any
data (such as an endomorphism monoid) that determines that lattice. This bridges:
- **Algebraic lattice theory** / closure operators
- **Semiring and endomorphism algebra**
- **EML / Lawvere-style fixed-point semantics**
- **Post-quantum lattice cryptography** (separator hardness)

## Main results

* `closure_subset_closed_of_subset` — closed sets absorb closures of subsets
* `compactClosed_closed` — compact-closed sets are closed
* `algebraicLike_finite_witness` — finitary closures have finite witnesses
* `closure_eq_sInf_closed_eq` — closure = infimum of closed supersets
* `reconstructsClosure_empty` — reconstruction from closed sets (empty monoid)
* `closure_eq_of_sameClosedSets` — **Tannaka uniqueness**: closures with
  the same closed-set lattice must be equal
* `closure_eq_of_endMonoid_eq` — endomorphism monoid + separator → equal closures
* `closure_pointwise_quantum_reconstruction` — pointwise membership corollary
* `lipschitz_certified_robustness_identity` — identity is 1-Lipschitz on set distance
* `post_quantum_lattice_separator_bound` — finite separator orbit bound

## References

Inspired by Tannakian reconstruction in representation theory, adapted to
closure dynamics in the spirit of Lawvere's fixed-point semantics.
-/

import Mathlib

open Function Set Classical

noncomputable section

namespace Bridges.AlgebraEMLReconstruction

/-! ## Section 1: Basic Closure Operator -/
section BasicClosure

/-- A set-level closure operator: extensive, monotone, idempotent. -/
structure SetClosureOperator (α : Type*) where
  toFun : Set α → Set α
  extensive : ∀ s, s ⊆ toFun s
  monotone : Monotone toFun
  idempotent : ∀ s, toFun (toFun s) = toFun s

instance {α : Type*} : CoeFun (SetClosureOperator α) (fun _ => Set α → Set α) :=
  ⟨SetClosureOperator.toFun⟩

@[simp] theorem SetClosureOperator.coe_apply {α : Type*} (cl : SetClosureOperator α)
    (s : Set α) : cl.toFun s = cl s := rfl

/-- A set is closed under `cl` if applying `cl` leaves it unchanged. -/
def ClosedSet {α : Type*} (cl : SetClosureOperator α) (s : Set α) : Prop :=
-- ... (truncated, full file has 575 lines)
```

@Bridges/AlgebraicEMLThermodynamicFormalism.lean
```lean
/-
  Algebraic–EML Thermodynamic Formalism via Closure Pressure and Gibbs Fixed-Point States

  Bridge: connects algebraic closure dynamics to thermodynamic equilibrium,
  quantum free-energy normalization, certified robustness, and post-quantum
  cryptographic semantics via finite Gibbs states on closure systems.

  This file develops a two-layer finite thermodynamic formalism:
  - State-space Gibbs theory on a finite type α
  - Closure-space Gibbs theory on Finset α via algebraic closure operators
-/

import Mathlib

open scoped BigOperators
open Finset Real

noncomputable section

/-! ## Section 1: Basic Definitions -/

/-- Bridge: connects algebraic closure dynamics to thermodynamic and certified robustness semantics.
A closure potential assigns a real-valued energy to each state in a finite type. -/
structure ClosurePotential (α : Type*) [Fintype α] where
  toFun : α → ℝ

/-- Bridge: finite closure kernel encoding EML/thermodynamic transitions.
Models a stochastic or sub-stochastic transition matrix on a finite state space. -/
structure ClosureKernel (α : Type*) [Fintype α] where
  step : α → α → ℝ
  nonneg : ∀ a b, 0 ≤ step a b

/-- Bridge: algebraic closure operator on a finite universe, connecting
lattice-theoretic closure to thermodynamic coarse-graining. -/
structure FiniteClosureSystem (α : Type*) [Fintype α] [DecidableEq α] where
  cl : Finset α → Finset α
  extensive : ∀ s, s ⊆ cl s
  monotone : ∀ {s t}, s ⊆ t → cl s ⊆ cl t
  idempotent : ∀ s, cl (cl s) = cl s

/-- Bridge: connects thermodynamic weight to Boltzmann-Gibbs formalism.
Weight of a state under inverse temperature β and potential φ. -/
def closureWeight {α : Type*} [Fintype α] (β : ℝ) (φ : α → ℝ) (a : α) : ℝ :=
  Real.exp (β * φ a)

/-- Bridge: connects partition function to algebraic closure normalization.
Partition function of a closure potential on a finite state space. -/
def closurePartitionFunction {α : Type*} [Fintype α] (β : ℝ) (φ : α → ℝ) : ℝ :=
  ∑ a : α, closureWeight β φ a

/-- Bridge: connects pressure to thermodynamic free energy and certified robustness.
Pressure = log of the partition function. -/
def closurePressure {α : Type*} [Fintype α] (β : ℝ) (φ : α → ℝ) : ℝ :=
  Real.log (closurePartitionFunction β φ)

/-- Bridge: normalized Gibbs weight connecting thermodynamic probability to algebraic state. -/
def closureGibbsWeight {α : Type*} [Fintype α] (β : ℝ) (φ : α → ℝ) (a : α) : ℝ :=
  closureWeight β φ a / closurePartitionFunction β φ

/-- Bridge: Gibbs state as a finite probability distribution on the closure state space.
-- ... (truncated, full file has 432 lines)
```

@Algebra/EMLClosureUnification/Core.lean
```lean
import Mathlib

/-!
# EML Closure Unification: Ideal-Theoretic Instances, Galois Fixed-Point Duality,
  and Noetherian Closure Certification

This file establishes the foundational trinity connecting EML (Extensive-Monotone-
Idempotent) closure operators to algebraic closure operators:

1. **EML-Ideal Mirror**: Ideal/submodule generation is an EML closure operator, and
   every Mathlib `ClosureOperator` satisfies the EML axioms.
2. **Galois Fixed-Point Mirror**: Every Galois connection induces dual EML
   closure/kernel operators whose fixed-point sets are order-isomorphic.
3. **Noetherian Closure Certification**: Noetherian ↔ ascending chain stabilization,
   providing certified ideal membership testing.

Bridge: connects EML closure theory ↔ Ideal theory ↔ Lattice-based Cryptography
-/

noncomputable section

open Set Function

/-! ## Part I: EML Closure Operator Typeclass -/

/-- An EML closure operator on a preordered type: extensive, monotone, idempotent.
    Bridge: connects lattice-theoretic closure to algebraic ideal generation. -/
class IsEMLClosureOn (α : Type*) [Preorder α] (cl : α → α) : Prop where
  /-- Extensivity: every element is below its closure -/
  extensive : ∀ x, x ≤ cl x
  /-- Monotonicity: closure preserves order -/
  mono : ∀ x y, x ≤ y → cl x ≤ cl y
  /-- Idempotence: applying closure twice equals once -/
  idempotent : ∀ x, cl (cl x) = cl x

/-- A dual EML operator (kernel/interior): deflationary, monotone, idempotent.
    Bridge: captures the dual structure in Galois connections. -/
class IsEMLKernelOn (α : Type*) [Preorder α] (kr : α → α) : Prop where
  /-- Deflation: the kernel is below the element -/
  deflationary : ∀ x, kr x ≤ x
  /-- Monotonicity -/
  mono : ∀ x y, x ≤ y → kr x ≤ kr y
  /-- Idempotence -/
  idempotent : ∀ x, kr (kr x) = kr x

/-- The fixed-point set of a closure operator. -/
def EMLClosureFixed {α : Type*} [Preorder α] (cl : α → α) : Set α :=
  {x | cl x = x}

namespace IsEMLClosureOn

variable {α : Type*} [Preorder α] {cl : α → α} [inst : IsEMLClosureOn α cl]

/-- The closure of any element is a fixed point. -/
theorem closure_is_fixed (x : α) : cl (cl x) = cl x := inst.idempotent x

/-- The closure map is monotone as a bundled property. -/
theorem closure_monotone : Monotone cl := fun _ _ h => inst.mono _ _ h

/-- Every image of `cl` lies in the fixed-point set. -/
-- ... (truncated, full file has 503 lines)
```

@Computation/InfoEfficientAlgorithms.lean
```lean
import Mathlib
import Computation.AlgorithmicCertificate

/-!
# Information-Efficient Algorithms: A Unified Theory

This file develops a unified mathematical framework showing that three canonical
algorithms—binary search, Dijkstra's shortest paths, and NTT/FFT—are instances
of a single paradigm: **information-efficient computation**.

## Novel Definitions

- `InfoEfficientAlgorithm`: A certified algorithm with quantitative termination
  and correctness guarantees via invariant preservation and potential descent.

## Main Results

### Binary Search
- `binarySearch_correct`: Binary search finds the least satisfying index.
- `binarySearch_invariant_preserved`: Loop invariant preservation.
- `binarySearch_pow2_bound`: At most k steps for 2^k elements.

### Dijkstra's Algorithm
- `dijkstra_init_settled_optimal`: Initial state satisfies optimality.
- `dijkstra_global_correct`: Upon termination, all distances are optimal.

### NTT/FFT
- `NTT_convolution`: NTT diagonalizes cyclic convolution.
- `ntt_cost_recurrence`: The divide-and-conquer complexity bound.

### Cross-Domain Connections
- `binarySearch_entropy_certificate`: Binary search → entropy bound.
- `binarySearch_entropy_exact_pow2`: Powers of 2 have exact log entropy.
- `exists_principal_root_prime`: Number theory → NTT root existence.

### Conjecture
- `conjecture_binarySearch_trace_optimal`: Binary search is comparison-optimal.
-/

open Function Finset BigOperators

noncomputable section

/-! ## Part 1: The InfoEfficientAlgorithm Structure (Novel Definition) -/

/-- An information-efficient algorithm is a state machine equipped with:
- An initialization function from inputs to states
- A step function advancing computation
- A termination predicate
- An output extraction function
- An invariant relating input to state
- A potential function (natural number) that strictly decreases on each step

Together these certify both correctness and complexity. The potential
provides the complexity bound: at most `potential(init x)` steps are needed.

This structure unifies binary search (ordered elimination),
Dijkstra (monotone relaxation), and FFT (symmetry factorization)
under one roof. -/
structure InfoEfficientAlgorithm (Input State Output : Type*) (Spec : Input → Output → Prop) where
-- ... (truncated, full file has 547 lines)
```


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
