
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


## Concept

**Title**: Karchmer–Wigderson games for closure-stable probe systems
**Domain**: Bridges
**Mathematical framing**: Let `α` be a state space equipped with a closure operator `cl : Set α → Set α` coming from a `SetClosureOperator`, and let probes be observables from a `ProbeFamily` inside a `ClosureSemimoduleSystem`. Fix a monotone target property `P : α → Prop` presented by membership in a closed set `C` or by a closure-derived score. Define the Karchmer–Wigderson relation `KW_P x y` for `x` with `P x` and `y` with `¬ P y` to be the type of probes witnessing separation, e.g. a probe `p` such that the probe response on `x` certifies membership while the response on `y` violates it. Main theorem target: for closure-stable probe families satisfying a finite reconstruction hypothesis, every `(x,y)` with opposite labels admits a separating probe, and recursive selection of such probes yields a valid KW tree/protocol. Secondary theorem: the protocol depth is bounded by the potential/round complexity of an associated `InfoEfficientAlgorithm`. Tertiary theorem: if reconstruction is exact on closed sets, leaf labels of the protocol correspond to minimal separating probes, giving a correctness theorem for `run`, `depth`, and `leafLabels` in `Bridges/KarchmerWigderson.lean`. This is falsifiable: failure can occur if closure stability does not imply existence of a separating probe, or if potential decrease is insufficient to control protocol depth.
**Concept description**: The key insight is that the existing Algebra↔EML closure/reconstruction framework already contains the combinatorial ingredients needed to build a genuine communication-complexity game, where a disagreement witness between two probe states plays the role of a Karchmer–Wigderson separating index. Rather than introducing a new speculative formalism, the project should connect `Bridges/AlgebraEMLClosureComputation.lean` and `Bridges/AlgebraEMLReconstruction.lean` to the unfinished `Bridges/KarchmerWigderson.lean`, proving that closure-stable probe semimodules induce finite decision trees whose leaves certify separating probes and whose depth is bounded by reconstruction complexity. Why now: the catalog already has `ClosureSemimoduleSystem`, `ProbeFamily`, `ClosureStableProbe`, `SetClosureOperator`, and `ClosedSet`, while recent work on information-efficient reconstruction gives an algorithmic notion of bounded interrogation complexity; the missing bridge is to show that these same objects generate Karchmer–Wigderson protocols. Concretely, define a monotone predicate on states by closed-set membership or closure-threshold attainment, formalize the associated KW relation on positive/negative instances, and prove existence of a protocol extracting a separating probe from any pair of opposite-labeled states. Then prove a depth upper bound in terms of the number of reconstruction rounds or potential decrease from `InfoEfficientAlgorithm.terminates_within_potential`. This would matter because it turns the closure/reconstruction pipeline into a lower/upper-bound interface: algebraic closure structure yields explicit communication protocols, and conversely protocol depth measures informational complexity of probe-based recovery.
**Novelty estimate**: 0.91
**Breakthrough potential**: 0.88
Research domain: Bridges
Research mode: sorry_fill


### Lean 4 Sketch
Bridge the sorry target `Bridges/KarchmerWigderson.lean` to the existing closure/reconstruction API. Define a protocol state parameterized by remaining candidate closed sets; prove `run_mem_leafLabels`, `isValid`, and depth lemmas by induction on reconstruction steps/potential. Use finite probe families first.


### Catalog Context
@Bridges/KarchmerWigderson.lean
```lean
/-
# Karchmer–Wigderson Pipeline for Monotone st-Connectivity

This file formalizes the Karchmer–Wigderson (KW) communication game framework,
proves a generic transfer theorem from monotone formulas to KW protocols,
establishes a communication lower bound for st-connectivity, and packages
the result as a circuit depth lower bound via the existing catalog witness interface.

## Main Results

1. **Generic KW Transfer**: Any monotone formula of depth d yields a valid KW protocol
   of depth d. Contrapositive: formula depth ≥ KW communication complexity.
2. **STConn Monotonicity**: The st-connectivity predicate is monotone on edge sets.
3. **KW Communication Lower Bound**: The monotone KW communication complexity of
   st-connectivity on n-vertex path graphs is at least ⌊log₂(n-1)⌋.
4. **Circuit Depth Transfer**: Via the FormulaDepthLowerBoundWitness interface,
   the communication lower bound transfers to a monotone circuit depth lower bound.

## Architecture

The pipeline is:
  hard combinatorial object → communication lower bound → formula depth witness → circuit lower bound

This demonstrates a reusable formal methodology for certified lower-bound engineering.
-/
import Mathlib
import Catalog.Pythagorean.MonotoneCircuitComplexity

open Finset

/-! ## Part 1: KW Protocol Definitions -/

/-- A deterministic communication protocol for the monotone Karchmer–Wigderson game.
    - `leaf i`: output variable index `i` with no communication.
    - `aliceNode strat l r`: Alice sends one bit (strat applied to her input x).
      If `strat x = false`, proceed to `l`; if `true`, proceed to `r`.
    - `bobNode strat l r`: Bob sends one bit (strat applied to his input y).
      If `strat y = false`, proceed to `l`; if `true`, proceed to `r`. -/
inductive KWProtocol (α : Type) where
  | leaf (i : α) : KWProtocol α
  | aliceNode (strat : (α → Bool) → Bool) (left right : KWProtocol α) : KWProtocol α
  | bobNode (strat : (α → Bool) → Bool) (left right : KWProtocol α) : KWProtocol α

namespace KWProtocol

variable {α : Type}

/-- Run the protocol given Alice's input `x` and Bob's input `y`. Returns the
    variable index at the reached leaf. -/
def run : KWProtocol α → (α → Bool) → (α → Bool) → α
  | leaf i, _, _ => i
  | aliceNode strat l r, x, y => if strat x then r.run x y else l.run x y
  | bobNode strat l r, x, y => if strat y then r.run x y else l.run x y

/-- Communication depth of the protocol (longest root-to-leaf path). -/
def depth : KWProtocol α → ℕ
  | leaf _ => 0
  | aliceNode _ l r => 1 + max l.depth r.depth
  | bobNode _ l r => 1 + max l.depth r.depth

-- ... (truncated, full file has 327 lines)
```

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
