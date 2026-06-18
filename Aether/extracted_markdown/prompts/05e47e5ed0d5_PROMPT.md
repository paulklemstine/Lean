
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

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

**Title**: Berggren-tree lattice potentials as closure kernels for an info-efficient factorization pipeline
**Domain**: Bridges
**Mathematical framing**: Define a finite state space of Berggren words or generated primitive triples, with evaluation map from words to triples using existing Berggren generators. Introduce a predicate `Admissible` based on Lorentz form, Euclidean norm, congruence class, or valuation depth. For a finite set `S`, define `cl(S)` as the union of `S` with all admissible one-step Berggren descendants of elements of `S`; then prove extensivity, monotonicity, and idempotence under a saturation hypothesis, yielding a finite closure operator. Use `ClosureKernel`/`ClosurePotential` style abstractions to package the dynamics. Main theorem family: (1) closure stability of Berggren generation; (2) existence of a potential `Φ` on finite candidate families such that each certified pruning or reconstruction step weakly decreases `Φ`; (3) termination and explicit complexity bound for the induced `InfoEfficientAlgorithm`; (4) probe-rigidity theorem: Berggren fingerprints define closure-stable probes, and equal probe data implies equality in a reduced kernel quotient or equality of evaluated states under additional injectivity hypotheses. This bridges Bridges, Computation, Cryptography, and Pythagorean without duplicating current in-flight tropical closure work.
**Concept description**: The key insight is that the Berggren/Lorentz structures already formalized in Pythagorean and Cryptography can be recast as a finite closure-kernel dynamics in Bridges, turning geometric descent on Pythagorean triples into a provable information-efficient search scheme rather than just a static encoding. Why now: the catalog already contains the exact ingredients needed for a nontrivial cross-domain theorem stack — Lorentz/Pythagorean invariants in `Cryptography/BerggrenDiophantineLattice.lean` and `Cryptography/BerggrenLatticeCryptography.lean`, explicit Berggren dynamics in `Geometry/BerggrenRamanujan.lean`, closure and kernel machinery in `Bridges/AlgebraEMLClosureComputation.lean` and `Bridges/AlgebraicEMLThermodynamicFormalism.lean`, and algorithmic potential bounds in `Computation/InfoEfficientAlgorithms.lean`. The proposed program is to define a closure system on finite Berggren-generated candidate sets where the closure operator adds all one-step descendants satisfying a Lorentz-norm or congruence filter, then prove that the associated closure potential is monotone under expansion and decreases along a suitably chosen pruning/backtracking map. A concrete target theorem is that for any finite seed family of primitive Pythagorean vectors, the induced closure kernel is stable under Berggren generators and yields a terminating info-efficient algorithm whose step bound is controlled by a potential derived from valuation depth or Euclidean/Lorentz size. A second target is a bridge theorem identifying cryptographic fingerprint rigidity on Berggren words with closure-stable probes, so that equality of evaluated words can be certified by kernel invariants rather than exhaustive search. This is falsifiable: the closure operator may fail monotonicity or the potential may not decrease; if it succeeds, it produces an algorithmic pipeline connecting geometric generation, closure reconstruction, and complexity certificates.
**Novelty estimate**: 0.88
**Breakthrough potential**: 0.91
Research domain: Bridges
Research mode: prove


### Lean 4 Sketch
Build a new file near `Bridges/BerggrenClosureAlgorithm.lean`. Reuse `berggrenMatA/B/C` or `berggrenGen`/`evalWord` for state transitions; instantiate `SetClosureOperator` or `ClosureKernel` on finite sets of triples/words; define a potential by cardinality, max norm, or imported `ValuationDepthMeasure`; prove monotonicity lemmas and termination via `InfoEfficientAlgorithm.terminates_within_potential`. Likely manageable with finite sets and simple integer inequalities before attempting stronger 


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

@Computation/PadicValuationDepth.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.

# p-adic Valuation Depth: Algebraic Foundations for Non-Archimedean Computation

Bridge: Algebra/valuation_theory ↔ Computation/complexity_measures

The ultrametric inequality |a+b| ≤ max(|a|,|b|) eliminates carry propagation,
making p-adic arithmetic fundamentally cheaper than classical arithmetic.

## Main definitions
* `ValuationDepthMeasure` — typeclass for valuation depth of functions
* `ValDepthBounded` — predicate for bounded valuation depth
* `ValDepthClassSet` — complexity classes VAL_k
* `UltrametricCompositionLaw` — composition uses max not sum
* `HenselConvergenceData` — certified exponential convergence
* `HenselIterationComplexity` — O(log n) certified complexity
* `UltrametricLipschitzData` — Lipschitz data with ultrametric composition
* `StratifiedComputation` — abstract strict hierarchy model
* `DepthWitness` — hierarchy separation witnesses
* `ClassicalArithDepth` / `UltrametricArithDepth` — depth comparison
-/

import Mathlib

/-! ## Section 1: Valuation Depth Measure — Core Typeclass -/

/-- `ValuationDepthMeasure α β`: the minimum number of valuation queries to compute
a function `f : α → β` over a semiring. Non-Archimedean analogue of circuit depth.
Bridge: connects Algebra/valuation_theory to Computation/complexity_classes. -/
class ValuationDepthMeasure (α : Type*) (β : Type*) [Semiring α] [Semiring β] where
  vdepth : (α → β) → ℕ
  vdepth_zero : vdepth (fun _ => 0) = 0
  vdepth_add : ∀ f g : α → β, vdepth (fun x => f x + g x) ≤ max (vdepth f) (vdepth g) + 1
  vdepth_mul : ∀ f g : α → β, vdepth (fun x => f x * g x) ≤ max (vdepth f) (vdepth g) + 1

namespace ValuationDepthMeasure
variable {α β : Type*} [Semiring α] [Semiring β] [ValuationDepthMeasure α β]

theorem vdepth_const_eq_zero : vdepth (fun (_ : α) => (0 : β)) = 0 := vdepth_zero

theorem vdepth_sum_le (f g : α → β) :
    vdepth (fun x => f x + g x) ≤ max (vdepth f) (vdepth g) + 1 := vdepth_add f g

theorem vdepth_prod_le (f g : α → β) :
    vdepth (fun x => f x * g x) ≤ max (vdepth f) (vdepth g) + 1 := vdepth_mul f g

/-- Squaring: depth ≤ vdepth(f) + 1. Bridge: Computation/squaring ↔ Algebra/quadratics. -/
theorem vdepth_square_bound (f : α → β) :
    vdepth (fun x => f x * f x) ≤ vdepth f + 1 := by
  have := vdepth_mul f f; simp [max_self] at this; exact this

/-- Doubling: depth ≤ vdepth(f) + 1. -/
theorem vdepth_double_bound (f : α → β) :
    vdepth (fun x => f x + f x) ≤ vdepth f + 1 := by
  have := vdepth_add f f; simp [max_self] at this; exact this

/-- Triple sum: depth ≤ max₃ + 2. -/
theorem vdepth_triple_sum_bound (f g h : α → β) :
    vdepth (fun x => f x + g x + h x) ≤
-- ... (truncated, full file has 459 lines)
```

@Computation/QuantumBerggrenWalk.lean
```lean
import Mathlib

/-!
# Quantum Walk on the Berggren Tree: Algebraic and Spectral Foundations

This module formalizes the algebraic infrastructure for quantum walks on the Berggren
tree of primitive Pythagorean triples. The Berggren tree is the infinite ternary tree
rooted at (3,4,5) with branching given by three integer matrices A, B, C ∈ O(2,1;ℤ).

## Main results

### Pillar I: Lorentzian Matrix Algebra
- Berggren matrices preserve the Minkowski quadratic form x² + y² - z²
- Determinant structure: det(A) = det(C) = 1, det(B) = -1
- Trace computations and spectral moment analysis
- Complete inverse relations and tree well-foundedness

### Pillar II: Tree Combinatorics
- Level cardinality: exactly 3^d vertices at depth d
- Total cardinality: (3^{d+1} - 1)/2 vertices through depth d
- Quantum search step count bounds

### Pillar III: Quantum Walk Framework
- Novel typeclasses: `LorentzPreserver`, `QuantumWalkConfig`, `SpectralFilterConfig`
- Pell equation connection via B-branch hypotenuse recurrence
- Spectral divisibility filter framework

## Cross-domain bridges
- **Number theory ↔ Lorentzian geometry**: Berggren matrices in O(2,1;ℤ)
- **Quantum computing ↔ Diophantine equations**: walk operators on arithmetic trees
- **Spectral theory ↔ Pell equations**: eigenvalue phases in quadratic fields
-/

open Matrix Finset BigOperators

noncomputable section

/-! ## Section 1: Berggren Matrix Definitions -/

/-- Berggren matrix A: maps (a,b,c) ↦ (a-2b+2c, 2a-b+2c, 2a-2b+3c). -/
def berggrenMatA : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B: maps (a,b,c) ↦ (a+2b+2c, 2a+b+2c, 2a+2b+3c). -/
def berggrenMatB : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix C: maps (a,b,c) ↦ (-a+2b+2c, -2a+b+2c, -2a+2b+3c). -/
def berggrenMatC : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The Minkowski metric η = diag(1,1,-1), defining the form x²+y²-z²
    preserved by the integer Lorentz group O(2,1;ℤ). -/
def minkowskiEta : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- The Pythagorean root triple (3,4,5). -/
def pythRoot : Fin 3 → ℤ := ![3, 4, 5]

/-! ## Section 2: Novel Typeclasses for Quantum Diophantine Dynamics -/
-- ... (truncated, full file has 692 lines)
```

@Cryptography/BerggrenDiophantineLattice.lean
```lean
import Mathlib

/-!
# Berggren Diophantine Lattice Cryptography

## Bridge: Pythagorean Number Theory ⟶ Lattice-Based Post-Quantum Cryptography

This module establishes the mathematical foundations for **Diophantine lattice
cryptography** — a new paradigm where the algebraic structure of primitive
Pythagorean triples, generated by the Berggren ternary tree, provides
cryptographically hard lattice problems suitable for post-quantum key exchange.

### Central Construction

The three Berggren matrices A₁, A₂, A₃ ∈ SL(3,ℤ) ∪ {det = −1} act on ℤ³
preserving the Lorentzian quadratic form Q(v) = v₀² + v₁² − v₂². This places
them in the integral orthogonal group O(2,1;ℤ). The lattice generated by their
iterated action on the root triple (3,4,5) has shortest vector problems whose
hardness grows exponentially with tree depth.

### Main Results

1. **Berggren Determinant Induction**: Every path product has |det| = 1.
2. **Lorentz Form Path Preservation**: Arbitrary-depth paths preserve Q.
3. **Lipschitz Depth Composition**: ‖M_path · v‖² ≤ 35^d · ‖v‖².
4. **Hypotenuse Monotonicity**: The c-component strictly increases at each step.
5. **SVP Gap Amplification**: Norm gap grows exponentially with tree depth.
6. **Post-Quantum Security Certification**: 3^d ≥ 2^λ for explicit d,λ pairs.
7. **Non-Abelian Key Exchange**: Distinct paths yield distinct lattice points.

### Cross-Domain Bridges

- **Number Theory → Cryptography**: Pythagorean structure → lattice hardness
- **Hyperbolic Geometry → Post-Quantum Security**: Lorentz group → SVP bounds
- **Spectral Theory → Certified Robustness**: Frobenius norm → Lipschitz constant
- **Combinatorics → Key Space**: Ternary tree → exponential key space
-/

open Matrix Finset BigOperators

noncomputable section

namespace BerggrenDiophantine

/-! ## Section 1: Core Algebraic Definitions -/

/-- The Lorentzian quadratic form Q(a,b,c) = a² + b² − c².
Bridge: connects Minkowski spacetime geometry to Pythagorean number theory. -/
def lorentzForm (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- The Euclidean norm squared ‖v‖² = v₀² + v₁² + v₂². -/
def euclidNormSq (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2

/-- A vector is Pythagorean iff it lies on the Lorentz light cone Q(v) = 0. -/
def IsPythagoreanVec (v : Fin 3 → ℤ) : Prop := lorentzForm v = 0

/-- The Lorentz metric matrix Q = diag(1,1,−1). -/
def lorentzMetric : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- Berggren matrix A₁: maps (3,4,5) → (5,12,13). det = 1.
-- ... (truncated, full file has 796 lines)
```

@Cryptography/BerggrenFingerprintRigidity.lean
```lean
import Mathlib

/-!
# Berggren Fingerprint Rigidity: Geodesic Length Fingerprints and Collision-Resistant Key Extraction

## Overview

We prove that the truncated "fingerprint" — the set of transformed triple data over a
bounded set of primitive Pythagorean triples — determines the abelianized generator profile
of a Berggren word. This establishes a rigidity theorem for the positive Berggren semigroup:
the action on even a single primitive triple carries enough information to distinguish words
up to abelianization.

## Mathematical Setup

The Berggren tree generates all primitive Pythagorean triples from the root (3,4,5) using
three 3×3 integer matrix generators U, A, D. A *word* `w : List (Fin 3)` represents a
sequence of generator applications. The *abelianized profile* `abelianCount w` records
how many times each generator appears, discarding order.

The key insight is that the three generators produce **pairwise distinct** full triples
when applied to any positive Pythagorean triple. Combined with the freeness of the Berggren
semigroup (proved herein), this gives a complete fingerprint rigidity result.

## Main Results

* `berggren_gen_hyp_increases` — each generator strictly increases hypotenuse
* `berggren_word_action_injective` — freeness of the Berggren semigroup
* `gen_hyp_pairwise_distinct` — distinct generators produce distinct hypotenuses
* `evalWord_append` — word evaluation is a homomorphism
* `abelianCount_append` — abelianized counts are additive
* `fingerprint_root_determines_word` — fingerprint over root determines the word
* `fingerprint_injective_abelianized` — fingerprint equality implies equal abelian counts
* `fingerprintSeparates_distinct_abelianizations` — collision obstruction
* `compareFingerprint_sound` — certified computable collision detection
* `exists_certified_radius` — explicit radius R₀ = 5 suffices
-/

open Matrix Finset

set_option maxHeartbeats 800000

/-! ## Core Berggren Definitions -/

/-- The three positive Berggren generators as 3×3 integer matrices.
    Generator 0 = U (left), 1 = A (middle), 2 = D (right). -/
def berggrenGen : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | ⟨0, _⟩ => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | ⟨1, _⟩ => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | ⟨2, _⟩ => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- A word in the Berggren generators: a list of indices into {0,1,2}. -/
abbrev BerggrenWord := List (Fin 3)

/-- Word evaluation by left-multiplication: product of generator matrices. -/
def evalWord : BerggrenWord → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | g :: w => berggrenGen g * evalWord w

/-- The root Pythagorean triple (3, 4, 5). -/
-- ... (truncated, full file has 425 lines)
```

@Cryptography/BerggrenLatticeCryptography.lean
```lean
import Mathlib

/-!
# Berggren Lattice Cryptography

## Bridge: Hyperbolic Geometry ⟶ Lattice Cryptography ⟶ Post-Quantum Security

This module develops the mathematical foundations connecting the Berggren tree of
primitive Pythagorean triples to lattice-based cryptographic structures. The key
insight is that the Berggren matrices live in O⁺(2,1; ℤ), the integral orthogonal
group of the Lorentz form Q(a,b,c) = a² + b² - c², and this group's action
on ℤ³ produces lattice structures with cryptographically relevant hardness properties.

### Main Results

1. **Lorentz Preservation**: Each Berggren matrix M satisfies MᵀQM = Q where
   Q = diag(1,1,-1) is the Lorentz form.
2. **Light Cone Classification**: Pythagorean triples lie exactly on the
   integer light cone {v ∈ ℤ³ : Q(v) = 0}.
3. **Berggren Group Structure**: The Berggren matrices generate a non-abelian
   subgroup of O(2,1; ℤ), with explicit determinant and trace bounds.
4. **Lattice SVP Bounds**: The shortest vector in Berggren-generated lattices
   satisfies explicit lower bounds tied to the Pythagorean structure.
5. **Key Exchange Foundations**: A matrix-path protocol with provable correctness.
6. **Lipschitz Bound**: Universal norm expansion bound ‖Mv‖² ≤ 35·‖v‖².

### Cross-Domain Connections

- **Number Theory → Cryptography**: Pythagorean triples generate lattices.
- **Hyperbolic Geometry → Post-Quantum Security**: The Lorentz group O(2,1)
  defines lattices resistant to quantum attacks.
- **Algebraic Number Theory → Key Exchange**: The Brahmagupta-Fibonacci
  identity (Gaussian integer norm multiplicativity) connects factoring to SVP.
- **Tropical Geometry → Certified Robustness**: The tropical light cone
  provides margin bounds for tropical neural network classifiers.
-/

open Matrix Finset

noncomputable section

namespace BerggrenCrypto

/-! ## Section 1: Core Definitions -/

/-- The Lorentz quadratic form Q(a,b,c) = a² + b² - c².
    Bridge: connects Minkowski spacetime to Pythagorean number theory. -/
def lorentzQ (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

/-- The Lorentz bilinear form matrix Q = diag(1, 1, -1). -/
def lorentzMatrix : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- A triple (a,b,c) is Pythagorean if a² + b² = c². -/
def IsPythagorean (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- A Pythagorean triple is primitive if gcd(a,b) = 1. -/
def IsPrimitivePythagorean (a b c : ℤ) : Prop :=
  IsPythagorean a b c ∧ Int.gcd a b = 1

/-- The Lorentz norm of a vector in ℤ³: v₀² + v₁² - v₂². -/
-- ... (truncated, full file has 684 lines)
```

@Geometry/BerggrenRamanujan.lean
```lean
import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.BerggrenRamanujan

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 59
-/

noncomputable section

/-- A direction in the ternary Berggren tree. -/
inductive BDir where
  | left  : BDir   -- B₁ branch
  | mid   : BDir   -- B₂ branch
  | right : BDir   -- B₃ branch
  deriving DecidableEq, Repr, Inhabited

/-- A position in the Berggren tree is a finite word over {left, mid, right}. -/
abbrev BPos := List BDir

/-- Apply a single Berggren step. -/
def berggrenStep (d : BDir) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  let (a, b, c) := t
  match d with
  | .left  => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .mid   => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .right => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The Pythagorean triple at a given position (path applied left-to-right from root). -/
def berggrenAt (path : BPos) : ℤ × ℤ × ℤ :=
  path.foldl (fun t d => berggrenStep d t) (3, 4, 5)

/-- Each Berggren step preserves the Pythagorean equation. -/
theorem berggrenStep_preserves_pyth (d : BDir) (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let (a', b', c') := berggrenStep d (a, b, c)
    a' ^ 2 + b' ^ 2 = c' ^ 2 := by
  cases d <;> simp [berggrenStep] <;> nlinarith [sq_nonneg (a - b), sq_nonneg (a + b)]

/-- Every position in the Berggren tree yields a Pythagorean triple. -/
theorem berggrenAt_pyth (path : BPos) :
    let (a, b, c) := berggrenAt path
    a ^ 2 + b ^ 2 = c ^ 2 := by
  simp only [berggrenAt]
  suffices h : ∀ (t : ℤ × ℤ × ℤ), t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 →
    let r := path.foldl (fun t d => berggrenStep d t) t
    r.1 ^ 2 + r.2.1 ^ 2 = r.2.2 ^ 2 from
    h (3, 4, 5) (by norm_num)
  intro t ht
  induction path generalizing t with
  | nil => exact ht
  | cons d ds ih =>
    simp only [List.foldl]
    apply ih
    exact berggrenStep_preserves_pyth d t.1 t.2.1 t.2.2 ht

/-- Berggren matrix B₁. -/
def berggrenB₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]
-- ... (truncated, full file has 316 lines)
```

@Algebra/BerggrenLorentz/Core.lean
```lean
import Mathlib

/-!
# Berggren-Lorentz Monoid: Discrete Lorentz Symmetry of Pythagorean Triples

This file develops the theory of the **Berggren monoid** — the three-generator
submonoid of GL₃(ℤ) that acts on primitive Pythagorean triples via the
Berggren tree. We establish:

1. All three generators preserve the Lorentzian quadratic form Q(a,b,c) = a²+b²-c²,
   placing them in the integer orthogonal group O(2,1;ℤ).
2. Determinant computations showing orientation structure (two proper, one improper).
3. Pythagorean preservation: children of Pythagorean triples are Pythagorean.
4. Hypotenuse growth bounds giving O(log c) tree depth.
5. Trace structure, inverse matrices, and non-commutativity of generators.
6. Quadratic form identities and bilinear form theory.

## Bridge: Number Theory (Pythagorean triples) ↔ Physics (Lorentz group O(2,1;ℤ))
↔ Cryptography (monoid action hardness) ↔ ML (Lipschitz bounds via matrix norms)
-/

set_option maxHeartbeats 1600000

namespace BerggrenLorentz

/-! ## Section 1: Core Definitions -/

/-- The Lorentzian quadratic form Q(a,b,c) = a² + b² - c² on ℤ³.
    The light cone Q = 0 parametrizes Pythagorean triples.
    Bridge: connects number theory to physics (Minkowski metric). -/
def lorentzForm (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- Scalar version of the Lorentz form for convenience. -/
def lorentzQ (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

/-- A triple (a,b,c) is Pythagorean iff it lies on the light cone Q = 0. -/
def IsPythag (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- The Berggren matrix A (first generator). -/
def matA : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- The Berggren matrix B (second generator). -/
def matB : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- The Berggren matrix C (third generator). -/
def matC : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The Lorentz metric matrix Q_L = diag(1, 1, -1). -/
def metricQ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- Berggren child A: explicit coordinate formulas. -/
def childA (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren child B: explicit coordinate formulas. -/
def childB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren child C: explicit coordinate formulas. -/
def childC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- A word in the Berggren monoid: a finite sequence of generator indices. -/
-- ... (truncated, full file has 505 lines)
```


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Research Team Protocol

You are leading a research team. Your team has different roles:
- The **Hypothesizer** generates bold, falsifiable conjectures
- The **Experimenter** proves or disproves them in Lean 4
- The **Analyst** examines what survived, what failed, and WHY
- The **Critic** searches for weaknesses, constructs counterexamples,
  and identifies where proofs might break down. A well-constructed
  counterexample is as valuable as a proof.
- The **Synthesist** upgrades the knowledge base and writes the
  FUTURE_DIRECTIONS.md that seeds the next cycle

You run this loop: **Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate**.
Each cycle is not a one-shot task. It is one iteration of an infinite
research process. Your notes (FUTURE_DIRECTIONS.md, Lab Notebooks,
proof sketches) determine whether the next team builds on your work
or starts over.

**Take good notes.** A cycle without useful notes is a wasted cycle.

### STEP 1: THEOREM DECLARATIONS (required -- before any code)

List every theorem you intend to prove or investigate. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `hypothesis` | `conjecture` | `proved` | `proved_with_lemma_sorry` | `disproved`
- **Why it matters**: One sentence on what this result would mean if true,
  and what it would teach us if false

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective -- proved -- constructive inverse -- confirms decidability of Nat x Nat
2. `cantorPairing_injective`: Cantor pairing is injective -- proved -- diagonal argument -- confirms invertibility
3. `cantorPairing_bijection`: Cantor pairing is a bijection -- proved_with_lemma_sorry -- follows from 1+2 -- completing the characterization

Use `hypothesis` for statements you are not yet sure you can prove but
want to investigate. Use `conjecture` for statements you believe are true
but cannot prove in this cycle. Use `disproved` for statements where you
found a counterexample. Use `proved` for statements with complete Lean
proofs. Use `proved_with_lemma_sorry` when the main proof is complete but
one or more supporting lemmas use `sorry`.

### STEP 2: EXPERIMENT (prove or disprove in Lean 4)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its
status to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it is deferred

**Disproofs count.** If a hypothesis is false, prove its negation or
construct an explicit counterexample. A well-constructed counterexample
is as valuable as a proof. Change the status to `disproved` and state
the counterexample clearly.

### STEP 3: CRITIQUE (find the weaknesses)

For your best theorem, the Critic must:
- Identify the strongest assumption that could be weakened
- Construct a boundary case: where does the result break down?
- If possible, state a `conjecture` for the generalized version and
  explain what would need to change in the proof

This is NOT optional. A theorem without a critique is incomplete.

### STEP 4: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` -- unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures, generalizations, and boundary cases.

### STEP 5: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### STEP 6: TAKE GOOD NOTES (first-class deliverables)

Your notes determine what the next research team investigates. They are NOT
an afterthought. They are your most important output after the proofs themselves.

**6a. Lab Notebook** (in each .lean file, as `-- !-- Lab Notebook -- !--` blocks):

For each major theorem, include a Lab Notebook comment block:
```lean
-- !-- Lab Notebook: cantorPairing_bijection -- !--
-- !-- Hypothesis: Cantor pairing is bijective because both surjective and injective -- !--
-- !-- Result: Proved via composition of surjective and injective proofs -- !--
-- !-- Insight: The constructive inverse of surjectivity is key; diagonal argument handles injectivity -- !--
-- !-- Failure analysis: Initial attempt to prove bijection directly failed; decomposition into surjective+injective was necessary -- !--
-- !-- End Lab Notebook -- !--
```

**6b. FUTURE_DIRECTIONS.md** (MANDATORY — your output WILL BE REJECTED if missing):

You MUST produce a FUTURE_DIRECTIONS.md file with this EXACT structure.
Copy the section headers below verbatim. Do NOT use freeform prose.

## Synthesis

[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary

[For EACH theorem: name, status (proved/conjecture/disproved), one-sentence
significance. Format as a bullet list:]

- `theoremName`: status — one-sentence significance

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

IMPORTANT: The ## Synthesis and ## Results Summary sections are NOT optional.
If your FUTURE_DIRECTIONS.md is missing either section, it will be treated as
incomplete and the next research team will have no context to build on your work.

### STEP 7: Generalization loop

For your BEST theorem, attempt one level of generalization:
- State a stronger version (can use sorry if proving would take too long)
- Identify the boundary: where does the result break down?
- If the generalization is itself interesting, mark it as a `conjecture`
  in your theorem declarations and explain it in FUTURE_DIRECTIONS.md

### Output format

Your output must include:
1. `.lean` files with proofs and Lab Notebook blocks (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with Synthesis, Results Summary, and 3-5 research
   directions (structured as in Step 6b)

Both are required. A cycle with proofs but no Lab Notebook or
FUTURE_DIRECTIONS.md is a cycle where the next team starts from scratch.
Take good notes.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
