
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

**Title**: Spectral Gap Lower Bounds for Quantum Walks on Berggren Trees
**Domain**: Computation
**Mathematical framing**: Let T be the infinite ternary Berggren tree where each node (a,b,c) with a² + b² = c² has children A(a,b,c), B(a,b,c), C(a,b,c) via the three Berggren matrices. Define the quantum walk operator W on ℓ²(T) by (Wψ)(v) = (1/3) Σ_{u: u→v} ψ(u) where the sum is over parents and children. The Lorentz form Q(v) = a² + b² - c² is preserved by each Berggren matrix: Q(Mv) = Q(v) for M ∈ {A,B,C}. Theorem (Berggren Walk Spectral Gap): For the restriction W_d of W to depth-d subtrees of the Berggren tree, the spectral gap γ(W_d) = 1 - λ₂(W_d) satisfies γ(W_d) ≥ C/d² for an absolute constant C > 0. Corollary: The quantum walk on depth-d Berggren subtrees mixes in O(d² log(1/ε)) steps, yielding a quantum algorithm for Pythagorean triple enumeration with quadratic speedup over classical breadth-first search.
**Concept description**: The key insight is that the Berggren matrices A, B, C define a unitary quantum walk on the ternary tree of Pythagorean triples, and their Lorentz-preserving property forces the walk operator to have a spectral gap bounded below by Ω(1/d²) where d is the depth—establishing rapid mixing of quantum search on Diophantine structures. Why now: the catalog already contains the walk definition in Computation/QuantumBerggrenWalk.lean and the Lorentz form preservation in Algebra/BerggrenLorentz/Core.lean, providing the verified algebraic infrastructure needed for the spectral analysis. The proof strategy: (1) define the Berggren walk operator W = (A + B + C)/3 as a unitary on the Hilbert space of square-summable functions on the Berggren tree; (2) use the Lorentz form Q(x,y,z) = x² + y² - z² to construct a comparison function that bounds the Rayleigh quotient; (3) prove that the Lorentz-preserving property of each Berggren matrix implies that W's second eigenvalue is bounded away from 1 by at least c/d², yielding a mixing time of O(d² log(1/ε)). This bridges Computation (quantum walk algorithms), Physics (spectral theory of unitary operators), Pythagorean (Berggren tree structure), and Algebra (Lorentz form as invariant), creating the first verified rapid-mixing result for quantum walks on algebraically-defined graphs.
**Novelty estimate**: 0.78
**Breakthrough potential**: 0.72
Research domain: Computation
Research mode: prove


### Lean 4 Sketch
theorem berggren_walk_spectral_gap_lower_bound (d : ℕ) (hd : 0 < d) :
    spectralGap (berggrenWalkOperator d) ≥ C / (d * d : ℝ) := by
  -- Use Lorentz form preservation to bound Rayleigh quotient
  sorry

theorem berggren_walk_mixing_time (d : ℕ) (ε : ℝ) (hd : 0 < d) (hε : 0 < ε) :
    mixingTime (berggrenWalk d) ε ≤ C' * d * d * Real.log (1/ε) := by
  -- Follows from spectral gap bound
  sorry


### Catalog Context
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
