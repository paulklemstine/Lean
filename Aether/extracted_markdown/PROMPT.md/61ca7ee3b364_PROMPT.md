
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

**Title**: Berggren Lattice Spectral Gap: Exponential Growth and Worst-Case Hardness
**Domain**: Cryptography
**Mathematical framing**: Define the Berggren matrix group G_B = ⟨A, B, C⟩ ⊂ SL(3,Z) where A = [[1,-2,2],[2,-1,2],[2,-2,3]], B = [[1,2,2],[2,1,2],[2,2,3]], C = [[-1,2,2],[-2,1,2],[-2,2,3]]. Define the Berggren lattice Λ_B = {w·v₀ : w ∈ G_B} where v₀ = (3,4,5)^T. Under the Euclidean norm ‖·‖₂, prove: (1) G_B is free on generators {A,B,C} (no non-trivial relations), giving exponential growth |B_n| ∼ 3·2^(n-1) for the ball of radius n; (2) Each generator has spectral radius ρ(A) = ρ(B) = ρ(C) = 2+√3 > 1 (the largest eigenvalue of the Berggren matrices), so ‖w‖ ≥ (2+√3)^(n/2) for words of length n; (3) The successive minima of Λ_B satisfy λ₂(Λ_B)/λ₁(Λ_B) ≥ φ where φ is the golden ratio, derived from the ternary branching structure of the Berggren tree; (4) There exists a polynomial-time reduction from SVP to CVP on Λ_B using this spectral gap. The proof of (1) uses the action on the Lorentz cone: distinct words send v₀ to distinct primitive triples. The proof of (3) uses the tree structure: the three children of any node have norms growing by factors bounded below by φ.
**Concept description**: The key insight is that the three Berggren matrices A, B, C ∈ SL(3,Z) generate a group with exponential word growth, and this growth rate directly controls the spectral gap of the associated Berggren lattice Λ_B = ⟨A,B,C⟩·v₀ under the Euclidean norm. Specifically, one can prove that for any non-identity word w of length n in the Berggren generators, the operator norm ‖w‖ ≥ φ^(n/2) where φ = (1+√5)/2 is the golden ratio, yielding a provable spectral gap λ₂/λ₁ ≥ φ for the lattice. This gap implies that the Shortest Vector Problem on Berggren lattices reduces to the Closest Vector Problem, establishing worst-case to average-case hardness for a new class of post-quantum cryptographic primitives built from Pythagorean triple geometry. Why now: the catalog already contains Berggren matrices (Computation/QuantumBerggrenWalk.lean), Lorentz form preservation (Algebra/BerggrenLorentz/Core.lean), group generation and word evaluation (Cryptography/BerggrenFingerprintRigidity.lean with berggrenGen, evalWord), and lattice cryptography foundations (Cryptography/BerggrenLatticeCryptography.lean). The spectral analysis connecting these pieces to hardness guarantees is the precise missing link.
**Novelty estimate**: 0.88
**Breakthrough potential**: 0.78
Research domain: Cryptography
Research mode: prove



### Catalog Context
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


## v7 Depth Requirements — Structured Proofs with Completeness Gates

You are producing Lean 4 code on the mathematical frontier. Your output must
be COMPILABLE and your proofs must be COMPLETE. A single correct proof of a
non-trivial result is worth more than 5 theorems with `sorry`.

### STEP 1: THEOREM DECLARATIONS (required — before any code)

List every theorem you intend to prove. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `proved` | `conjecture` | `proved_with_lemma_sorry`
- **Why non-trivial**: One sentence on the key mathematical insight

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective — proved — constructive inverse
2. `cantorPairing_injective`: Cantor pairing is injective — proved — diagonal argument
3. `cantorPairing_bijection`: Cantor pairing is a bijection — proved_with_lemma_sorry — follows from 1+2

### STEP 2: PROVE THEOREMS (completeness gate)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its status
to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it's deferred

For your BEST theorem, also provide:
- A generalization or strengthening (can use sorry if proving would take too long)
- A boundary case or counterexample showing where the result fails

### STEP 3: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures and generalizations.

### STEP 4: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include:
1. `.lean` files with the proofs (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with 3-5 research conjectures extending the work

Both are required. Missing FUTURE_DIRECTIONS.md = automatic quality penalty.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
