
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

**Title**: Tropicalization of Berggren word evaluation as a valuation-monoid bridge
**Domain**: Bridges
**Mathematical framing**: Start from the Berggren generators acting on the root triple and the existing word-evaluation map. Define a numeric invariant on triples, such as a coordinatewise logarithmic height, max-coordinate height, or p-adic depth profile, and pull it back along `evalWord` to an invariant on words. The first target is a theorem of the form `μ (evalWord (u ++ v)) ≤ μ (evalWord u) ⊗ μ (evalWord v)` for a suitable tropical operation `⊗`, together with explicit formulas or sharp inequalities for the three generators. A stronger target is a monotonicity theorem for action on the root triple: each nonempty word strictly increases a chosen tropical height, yielding a no-short-collision certificate for distinct words with incompatible valuation signatures. A bridge-level theorem would package this as a semiring homomorphism or sub-homomorphism from the Berggren word monoid into an ordered tropical semiring of certificates. Algorithmically, this gives computable lower bounds on output size and a pruning criterion for search in Berggren-based cryptographic constructions. The concept is distinct from current in-flight tropical Berggren projects because it focuses on valuation/certificate extraction from existing algebraic evaluation maps, not tropicalizing the dynamics itself, lattice reduction, or halfspace separation.
**Concept description**: The key insight is that the existing Berggren word-evaluation machinery in Cryptography and Computation should admit a nontrivial tropical shadow: a valuation or length profile on words and triples that turns matrix-word composition into a max-plus or order-theoretic subadditive calculus, giving provable certificate bounds on growth and distinguishability without redoing the in-flight lattice-reduction or semigroup-action projects. Why now: the catalog already contains mature Berggren evaluation infrastructure (`evalWord`, `berggrenGen`, `actGen`, `rootTriple`) and valuation-style computational tools (`ValuationDepthMeasure`, `vdepth_sum_le`), while the breakthrough analysis explicitly flags Algebra–Tropical and Algebra–Bridges as structurally aligned but under-bridged. The proposed theorem family is to define a concrete tropical/valuation invariant of Berggren words or generated triples, prove functorial inequalities under concatenation and generator action, and then show that equality or strictness criteria yield an algorithmic lower-bound pipeline for word growth or collision separation. This is a genuine bridge theorem: from algebraic matrix generation of Pythagorean triples to tropical/order-theoretic certificates. It is falsifiable because the valuation invariant may fail to be additive, fail to separate generators, or collapse on nontrivial words; if it succeeds, it creates a new cross-domain bridge with computational content.
**Novelty estimate**: 0.86
**Breakthrough potential**: 0.84
Research domain: Bridges
Research mode: prove


### Lean 4 Sketch
Define a structure of certificate invariants on Berggren triples/words; prove concatenation inequalities by induction on words using existing `evalWord` recursion and matrix-action lemmas; instantiate with max-coordinate height and possibly p-adic valuation depth. Then derive corollaries on strict growth from the root triple and noncollision of words with distinct certificate profiles.


### Catalog Context
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

@Cryptography/BerggrenLatticeReduction.lean
```lean
import Mathlib

/-!
# Berggren-Tree Lattice Reduction and Shortest-Word Rigidity

## Overview

We formalize prefix-rigidity theorems for the positive Berggren semigroup
acting on primitive Pythagorean triples. The Berggren tree is viewed as a
**noncommutative geometric code**: words whose images are close must share structure.

## Word convention

A word `[g₁, g₂, ..., gₙ]` evaluates as `g₁(g₂(...(gₙ(root))...))`.
The **suffix** of a word (tail end) represents generators applied first (near root).
The **prefix** (head) represents the outermost generators.
Extending a tree path deeper means **prepending** to the word.

## Main Results

* `evalWord_append` — prefix factorization of evaluation
* `height_lower_bound_length` — height grows linearly with word length
* `evalAtRoot_injective` — evaluation is injective (freeness)
* `first_letter_divergence` — distinct first letters ⟹ positive distance
* `prefix_rigidity_exact` — geoDist = 0 ⟺ same word
* `candidateWordSet_finite` — candidate sets are finite
* `prune_prepend_sound` — sound branch-and-bound pruning
* `finite_nearby_words` — finite ambiguity at bounded distance
-/

set_option linter.unusedVariables false
set_option linter.unusedTactic false

/-! ## Section 1: Core Definitions -/

/-- The three Berggren generators. -/
inductive BerggrenGen : Type
  | A  -- Left branch (B₁)
  | B  -- Middle branch (B₂)
  | C  -- Right branch (B₃)
  deriving DecidableEq, Repr

instance : Fintype BerggrenGen where
  elems := {.A, .B, .C}
  complete x := by cases x <;> simp

/-- A Berggren word is a list of generators. -/
abbrev BerggrenWord := List BerggrenGen

/-- A triple of integers. -/
abbrev Triple := ℤ × ℤ × ℤ

/-- Action of a single Berggren generator on a triple. -/
def actGen (g : BerggrenGen) (t : Triple) : Triple :=
  match g, t with
  | .A, (a, b, c) => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .B, (a, b, c) => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .C, (a, b, c) => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The root triple (3, 4, 5). -/
-- ... (truncated, full file has 511 lines)
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
