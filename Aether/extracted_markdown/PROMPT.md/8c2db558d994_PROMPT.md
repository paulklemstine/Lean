
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

**Title**: Tropical Helly certificates from finite closure systems
**Domain**: Bridges
**Mathematical framing**: Work in finite-dimensional tropical affine space over max-plus. Use the existing notions `TropHalfspace`, `IsTropConvex`, and `tropConvexHull` as the geometric layer. On the combinatorial side, use `SetClosureOperator`, `ClosedSet`, `FiniteClosureSystem`, `ClosureSemimoduleSystem`, `ProbeFamily`, and `ClosureStableProbe` to build a finite closure operator attached to a family of tropical halfspaces. The main theorem should be a bridge theorem: for a finite indexed family H of tropical halfspaces, emptiness of `⋂ i, H i` implies existence of a finite closure-stable subfamily S with `⋂ i∈S, H i = ∅`, ideally with a Helly-style cardinality bound depending only on ambient dimension. A realistic first milestone is weaker but still substantial: prove monotonicity and idempotence of the obstruction closure, characterize minimal infeasible subfamilies as closed irredundant sets, and derive an extraction theorem producing a finite infeasibility certificate from any proof of emptiness. If dimension bounds are hard, prove instead a finite certificate theorem and relate minimal certificate size to closure rank. This is falsifiable, algorithmic, and genuinely bridges Tropical geometry with the Bridges/EML closure formalism.
**Concept description**: The key insight is that tropical halfspace feasibility can be recast as a finite closure-system obstruction problem, yielding Helly-type infeasibility certificates that are algorithmic and formally checkable. Why now: the catalog already contains the algebra–EML closure infrastructure in `Bridges/AlgebraEMLClosureComputation.lean`, reconstruction tools in `Bridges/AlgebraEMLReconstruction.lean`, and a nearly-complete tropical convexity target in `Speculative/AutoResearch/TropicalHelly.lean`; combining these makes a nontrivial cross-domain bridge tractable without repeating the in-flight Galois-correspondence projects. Concretely, define for a finite family of tropical halfspaces a closure operator on witness points or active constraints whose closed sets encode subsets with the same tropical feasible region. Then prove a certificate theorem of the form: if the intersection of a finite family of tropical halfspaces is empty, there exists a closed subfamily of bounded size whose intersection is already empty. A stronger version should show that minimal infeasible subfamilies correspond to closure-minimal obstructions, giving an extraction pipeline from geometric infeasibility to finite combinatorial certificates. This matters because it turns tropical convexity from a purely geometric existence statement into an algorithmic certification framework compatible with existing closure computation machinery.
**Novelty estimate**: 0.92
**Breakthrough potential**: 0.89
Research domain: Bridges
Research mode: prove


### Lean 4 Sketch
Create a bridge file proving that a finite family of tropical halfspaces induces a `FiniteClosureSystem` on constraint indices or witness patterns; then connect closed obstruction sets to infeasible intersections. Likely needs finishing `Speculative/AutoResearch/TropicalHelly.lean` definitions first, but the target theorem should live in Bridges and import the tropical file rather than duplicate it.


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

@Speculative/AutoResearch/TropicalHelly.lean
```lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Helly's Theorem — From Convexity to Optimization Duality

This file formalizes the foundations of tropical convexity in the max-plus semiring
and proves the tropical Helly theorem along with related results including
tropical Farkas-type lemmas and cross-domain connections.

## Main Definitions

* `IsTropConvex` — Tropical convexity in the max-plus semiring.
* `tropConvexHull` — The tropical convex hull: smallest tropically convex superset.
* `TropHalfspace` — A tropical halfspace: the max-plus analogue of a linear inequality.
* `TropicalNerve` — The nerve complex of a family of tropical convex sets.
* `TropicalFractionalHellyProp` — Falsifiable conjecture for tropical fractional Helly.

## Main Results

* `IsTropConvex.univ`, `.empty`, `.singleton` — Basic examples.
* `IsTropConvex.inter`, `.sInter`, `.iInter` — Closure under intersections.
* `tropConvexHull_isTropConvex`, `tropConvexHull_eq_self` — Hull properties.
* `tropHalfspace_isTropConvex` — Halfspaces are tropically convex.
* `tropConvex_dim1_interval` — Tropical convex sets in ℝ¹ are intervals.
* `tropLift_injective`, `tropLift_combination_bound` — Lifting to classical geometry.
* `tropical_farkas_weak` — Tropical Farkas lemma (weak form).
* `TropicalNerve.downward_closed` — Nerve is a simplicial complex.
* `tropical_helly` — The tropical Helly theorem (the main result).

## References

* Develin, M. and Sturmfels, B., "Tropical Convexity", 2004.
* Gaubert, S. and Katz, R.D., "The tropical analogue of polar cones", 2009.
-/

noncomputable section

open Set Finset BigOperators Classical

/-! ## Part 1: Tropical Convexity Foundations -/

/-- **Tropical convexity in the max-plus semiring.**
    A set S ⊆ ℝⁿ is tropically convex if for all x, y ∈ S and
    all coefficients s, t with max(s, t) = 0, the tropical combination
    i ↦ max(s + xᵢ, t + yᵢ) lies in S.

    The condition max(s, t) = 0 normalizes the tropical coefficients,
    analogous to requiring s + t = 1 in classical convex combinations. -/
def IsTropConvex {n : ℕ} (S : Set (Fin n → ℝ)) : Prop :=
  ∀ ⦃x y : Fin n → ℝ⦄, x ∈ S → y ∈ S →
    ∀ s t : ℝ, max s t = 0 → (fun i => max (s + x i) (t + y i)) ∈ S

/-- **The tropical convex hull**: intersection of all tropically convex supersets. -/
def tropConvexHull {n : ℕ} (T : Set (Fin n → ℝ)) : Set (Fin n → ℝ) :=
  ⋂₀ {S : Set (Fin n → ℝ) | IsTropConvex S ∧ T ⊆ S}

-- ... (truncated, full file has 431 lines)
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
