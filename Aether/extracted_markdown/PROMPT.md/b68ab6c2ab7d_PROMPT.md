
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

**Title**: Valuation-depth descent on Berggren words for certified Pythagorean lattice reduction
**Domain**: Bridges
**Mathematical framing**: Define a score `S(t)` for a primitive triple `t` by `S(t) = euclidNormSq(t) + λ * vdepth(f(t))` or a lexicographic pair built from norm and valuation depth of an associated integer quantity `f(t)` such as one leg, perimeter, or `c-a`. Formal goals: (1) define Berggren predecessor candidates induced by the inverse matrices of `berggrenMatA`, `berggrenMatB`, `berggrenMatC`; (2) prove a descent theorem: every non-root primitive triple has at least one valid predecessor with strictly smaller `S`; (3) package this as an `InfoEfficientAlgorithm` whose potential is `S`, using `terminates_within_potential`; (4) prove reconstruction correctness: iterating predecessors from any primitive triple terminates at `rootTriple`, and the accumulated word re-evaluates to the original triple via `evalWord`; (5) optionally prove a normal-form uniqueness theorem for score-minimizing descent. This is a bridge result because primitive-triple generation lives in Geometry/Pythagorean/Cryptography while the termination certificate and valuation estimates live in Computation.
**Concept description**: The key insight is that the existing Berggren-tree formalism in Pythagorean/Geometry and the valuation-depth machinery in Computation can be fused into a strictly decreasing descent invariant on words in the Berggren generators, yielding an explicit lattice-reduction style algorithm on primitive Pythagorean triples with a machine-checkable termination and complexity certificate. Why now: the catalog already contains the exact ingredients needed for a nontrivial bridge theorem—primitive-triple dynamics in `FINAL/Geometry/BerggrenRamanujan.lean`, cryptographic/lattice encodings in `Cryptography/BerggrenDiophantineLattice.lean` and `Cryptography/BerggrenFingerprintRigidity.lean`, and a general potential-based framework in `Computation/InfoEfficientAlgorithms.lean` together with valuation inequalities in `Computation/PadicValuationDepth.lean`. The concrete program is to define a descent score on primitive triples, or equivalently on Berggren words evaluating from `rootTriple`, by combining Euclidean size (`euclidNormSq` or `lorentzQ`) with a valuation-depth penalty. Then prove that for every non-root primitive triple there exists a certified inverse Berggren step that weakly decreases norm and strictly decreases the new score, so iteration reaches the root. A stronger theorem would identify a canonical predecessor selected by minimizing the score and prove uniqueness on a suitable normal-form subclass. This matters because it upgrades static rigidity results about Berggren generation into an algorithmic reconstruction pipeline: given a primitive triple or Pythagorean lattice vector, recover a reduction path and hence a canonical fingerprint. That gives a new cross-domain bridge Algebra/Geometry/Cryptography/Computation without repeating the in-flight closure-probe or KW work, and it produces falsifiable statements about monotonicity, termination, and uniqueness rather than a mere reformulation of the tree.
**Novelty estimate**: 0.86
**Breakthrough potential**: 0.89
Research domain: Bridges
Research mode: prove


### Lean 4 Sketch
Create `Bridges/PythagoreanValuationDescent.lean`. Import `FINAL/Geometry/BerggrenRamanujan`, `Cryptography/BerggrenDiophantineLattice`, `Cryptography/BerggrenFingerprintRigidity`, `Computation/PadicValuationDepth`, and `Computation/InfoEfficientAlgorithms`. Define a structure for primitive triples compatible with `rootTriple` and `evalWord`, define predecessor relation and score, then prove monotonicity lemmas and an `InfoEfficientAlgorithm` instance for reduction.


### Catalog Context
@FINAL/Geometry/BerggrenRamanujan.lean
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

@Algebra/Berggren.lean
```lean
/- Original: BerggrenABranchForAll.lean -/



/-- B₁ applied to a triple -/
def applyB₁ (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (t.1 - 2*t.2.1 + 2*t.2.2, 2*t.1 - t.2.1 + 2*t.2.2, 2*t.1 - 2*t.2.1 + 3*t.2.2)

/-- B₁ⁿ · (3,4,5) by iteration -/
def A_iter : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 => applyB₁ (A_iter n)

/-- The A-branch closed form -/
def A_closed (n : ℕ) : ℤ × ℤ × ℤ :=
  (2 * ↑n + 3, 2 * (↑n + 1) * (↑n + 2), 2 * (↑n : ℤ)^2 + 6 * ↑n + 5)

/-- B₁ applied to the closed form gives the next closed form -/
theorem A_closed_recurrence (n : ℕ) :
    applyB₁ ((A_closed n).1, (A_closed n).2.1, (A_closed n).2.2) =
    ((A_closed (n + 1)).1, (A_closed (n + 1)).2.1, (A_closed (n + 1)).2.2) := by
  simp only [A_closed, applyB₁]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> push_cast <;> ring

/-- **The closed form matches iteration for ALL n** -/
theorem A_iter_eq_A_closed : ∀ n : ℕ, A_iter n = ((A_closed n).1, (A_closed n).2) := by
  intro n
  induction n with
  | zero => native_decide
  | succ n ih =>
    simp only [A_iter, ih]
    exact A_closed_recurrence n

/-- [Section: ## A-Branch Gap: c - b = 1 for all n] -/
theorem A_branch_gap_all (n : ℕ) : (A_closed n).2.2 - (A_closed n).2.1 = 1 := by
  simp only [A_closed]; ring

/-- [Section: ## A-Branch GCD: always coprime] -/
theorem A_branch_coprime (n : ℕ) :
    Int.gcd (A_closed n).1 (A_closed n).2.1 = 1 := by
  unfold A_closed; norm_num;
  norm_num [ Int.gcd, Int.natAbs_mul, Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
  norm_cast ; norm_num [ ( by ring : 2 * n + 3 = n + 1 + ( n + 2 ) ) ];
  norm_num [ ( by ring : n + 2 = n + 1 + 1 ) ]

/-- Verification for small values -/
theorem A_branch_coprime_vals :
    Int.gcd (A_closed 0).1 (A_closed 0).2.1 = 1 ∧
    Int.gcd (A_closed 1).1 (A_closed 1).2.1 = 1 ∧
    Int.gcd (A_closed 2).1 (A_closed 2).2.1 = 1 ∧
    Int.gcd (A_closed 3).1 (A_closed 3).2.1 = 1 ∧
    Int.gcd (A_closed 4).1 (A_closed 4).2.1 = 1 := by native_decide

/-- [Section: ## A-Branch Pythagorean] -/
theorem A_closed_pythagorean (n : ℕ) :
    (A_closed n).1 ^ 2 + (A_closed n).2.1 ^ 2 = (A_closed n).2.2 ^ 2 := by
  simp only [A_closed]; ring

/- Original: BerggrenB2Entries.lean -/

-- ... (truncated, full file has 2704 lines)
```

@Bridges/AlgebraPythagoreanCryptography/BerggrenLatticeReductionDuality.lean
```lean
import Mathlib

/-!
# Berggren Lattice-Reduction Duality via Triple-Tree Semimodules and Certified Reconstruction

This module establishes a rigorous bridge between **primitive Pythagorean triple dynamics**
(the Berggren tree) and **certified lattice trapdoor structure**. The central insight is that
Berggren ancestry constitutes a new arithmetic trapdoor: finitely generated Berggren-stable
collections of primitive triples admit canonical positive-definite lattice realizations with
certified short-basis witnesses, and the hidden minimal generating structure can be
reconstructed from sufficiently rich lattice certificates.

## Main Results

1. **Positive-Definite Gram Construction** (`gramPD`, `gramPD_det`, `gramPD_posDef`):
   The rank-2 matrix `G⁺(a,b,c) = [[c, a], [a, c]]` with `det = b²` is positive definite
   for any primitive Pythagorean triple, and the rank-3 lift adds a canonical third component.

2. **Injectivity / Reconstruction** (`gramPD_injective`, `cert_determines_triple`):
   The Gram map is injective on primitive triples, enabling unique reconstruction.

3. **Realization Theorem** (`realization_of_finite_berggren_family`):
   Every finite set of primitive triples admits a canonical family of positive-definite
   lattice certificates with explicit short-basis bounds.

4. **Rigidity / Uniqueness** (`rigidity_of_gramPD_family`):
   The Gram realization is faithful: distinct finite sets of primitive triples produce
   distinct lattice certificate families.

5. **Certified Reconstruction** (`reconstructTriple_spec`):
   Certificate data uniquely determines the source triple.

6. **Degenerate Boundary** (`gramDegenerate_det_zero`):
   The naive Gram matrix `[[c+a, b], [b, c-a]]` is correctly identified as degenerate
   (det = 0), motivating the positive-definite lift.

## Mathematical Significance

This formalization inaugurates **Pythagorean arithmetic cryptography**: trapdoors as
arithmetic provenance in the Berggren tree, where hidden combinatorial ancestry becomes
a formal cryptographic primitive backed by certified lattice-theoretic witnesses.
-/

set_option maxHeartbeats 800000

open Matrix

/-! ## Section 1: Primitive Pythagorean Triples -/

/-- A primitive Pythagorean triple `(a, b, c)` with:
    - `a² + b² = c²`
    - all components positive
    - `gcd(a, b) = 1`
    - `a` odd, `b` even (canonical normalization) -/
@[ext]
structure PrimTriple where
  a : ℤ
  b : ℤ
  c : ℤ
  pos_a : 0 < a
-- ... (truncated, full file has 472 lines)
```


### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v5 Depth Requirements (MANDATORY — WORLD-CLASS STANDARD)

You are working on the frontier of mathematics. The Catalog has 100+ research
packages already. Each new cycle must contribute something genuinely new —
not a rephrasing, not a textbook exercise, not a "mathematics of X" parlor trick.

### STEP 1: PLAN (REQUIRED — before any Lean code)

Before writing any `.lean` file, you MUST output a `## Plan` section that
states, in plain prose:

- **Strategy**: Grothendieck path (define a new structure, prove its properties)
  OR Cauchy path (extend an existing catalog result). Choose the one that fits
  the concept. Do BOTH only if the concept genuinely demands it.
- **Files**: What `.lean` files you will create and what each contains.
  Use sensible names. No fixed count.
- **Theorems**: A list of the theorems you will prove, with one-sentence statements.
- **Why this is non-trivial**: A paragraph explaining the structural insight
  that makes this work world-class. If you cannot write this paragraph, the
  work is not world-class. Pick a different concept.

The Plan is not optional. Cycles that skip the Plan are rejected.

### STEP 2: PEGB for EVERY theorem (strict)

For EACH theorem you prove, you MUST provide all four of:

- **P**roof: A complete, non-trivial Lean 4 proof.
- **E**xample: A concrete worked example (an `example` block or a specific instance).
- **G**eneralization: A one-level-up generalization (a stronger statement, a
  broader class, a higher categorical level). State it as a `theorem` or `lemma`
  with `sorry` if proving it would take the cycle too far — but STATE it.
- **B**oundary: A counterexample or limit-case analysis. When does the result
  fail? What assumptions are essential?

"Top 3-5 theorems" is no longer accepted. EVERY theorem you produce must have
full PEGB. If you produce 2 theorems with full PEGB, that's better than 5 theorems
with PEGB on only 2.

### STEP 3: Anti-patterns (REJECTED outright)

The following tactics are BLACKLISTED for the primary proof of any non-trivial theorem:

- `native_decide`, `decide`, `norm_num`, `rfl` — unless the statement is genuinely
  a numeric/equality fact and the tactic is doing real work (not papering over
  a structural insight).
- `Aesop` — unless the goal is provably trivial (≤ 3 hypotheses, no arithmetic).
- `omega`, `linarith` on quantified goals — these are not "proofs" of structural
  statements.
- `simp only []` with no explicit simp set — this is "let the lemma solver figure it out."

If your only proof of a non-trivial theorem uses one of these, the theorem is not
worth proving. Find a structural proof, or drop the theorem.

### STEP 4: Novelty check

A theorem is "novel" only if a working mathematician in the area would say
"I haven't seen that before." Test yourself:

- Is the statement in a textbook? If yes, find a non-trivial generalization.
- Is the statement a rephrasing of a known result? If yes, the cycle is not novel.
- Is the proof essentially the same as a known proof? If yes, the contribution
  is the statement, not the proof — make sure the statement is genuinely new.

"Mathematics of X" where X is a real-world phenomenon (memes, dreams, consciousness,
art, music, social networks) is NOT a mathematical contribution unless you formalize
X as a precise mathematical object first. If you cannot formalize X rigorously, pick
a different topic.

### STEP 5: Either path (Aristotle's choice)

You are NOT required to follow a specific path. Choose the one that fits the concept:

**Grothendieck path** (define a new structure):
- Invent a new operator, category, algebraic variety, or combinatorial object.
- State its defining properties as axioms or definitions.
- Prove 2-4 non-obvious theorems about it.
- Best for: novel concepts, unexplored territory, "what if we defined X this way?".

**Cauchy path** (extend an existing result):
- Pick a specific catalog theorem (cite it by name).
- Generalize, strengthen, or bridge it.
- Prove the new version is strictly stronger or more general.
- Best for: deepening the catalog, building on existing strength.

You may do BOTH if the concept requires it. But the Plan must justify why both paths
are needed in a single cycle.

### STEP 6: Theorem count

No fixed count. Some concepts deserve 2 deep theorems. Some deserve 6. The Plan
must justify the count. The quality bar is "every theorem has full PEGB" — not
"produce a specific number".

### STEP 7: Cite your sources

Your `## Plan` and any prose must reference specific catalog results by name or path
when you build on them. The catalog is the substrate; you are growing new math on it.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
