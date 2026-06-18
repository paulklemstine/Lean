
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
    {
      "name": "descriptive_name",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
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

**Title**: Close Proofs: Proof Phase Transitions: Sharp Thresholds in Random Formal Theories
**Domain**: Tropical
**Mathematical framing**: Cycle 0320765b (Q=0.435) proved 643 theorems in Physics but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Conjecture: For natural families of randomly generated first-order axiom systems with bounded symbol complexity and a fixed theorem schema φ_n, there exists a nontrivial critical clause-density parame
Research domain: Tropical
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/BerggrenLorentz/Core.lean
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
structure BerggrenWord where
  letters : List (Fin 3)
  deriving Repr, DecidableEq

/-- The matrix associated to each generator index. -/
def berggrenGen : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => matA
  | 1 => matB
  | 2 => matC

/-- Product of matrices along a Berggren word. -/
def wordMatrix (w : BerggrenWord) : Matrix (Fin 3) (Fin 3) ℤ :=
  w.letters.foldl (fun acc k => acc * berggrenGen k) 1

/-- The Lorentz bilinear form B(u,v) = u₀v₀ + u₁v₁ - u₂v₂.
    Polarization of the Lorentz quadratic form.
    Bridge: connects inner product geometry to Pythagorean combinatorics. -/
def lorentzBilinear (u v : Fin 3 → ℤ) : ℤ :=
  u 0 * v 0 + u 1 * v 1 - u 2 * v 2

/-- The hypotenuse functions for each branch. -/
def hypA (a b c : ℤ) : ℤ := 2*a - 2*b + 3*c
def hypB (a b c : ℤ) : ℤ := 2*a + 2*b + 3*c
def hypC (a b c : ℤ) : ℤ := -2*a + 2*b + 3*c

/-! ## Section 2: Determinant Structure -/

/-- Berggren matrix A has determinant 1 (proper Lorentz transformation).
    Bridge: orientation-preserving transformation in O(2,1;ℤ). -/
theorem det_matA : matA.det = 1 := by native_decide

/-- Berggren matrix B has determinant -1 (improper Lorentz transformation).
    Impact: post_quantum_security — the B-generator is the unique
    parity-flipping generator, giving a ℤ/2ℤ grading on the monoid. -/
theorem det_matB : matB.det = -1 := by native_decide

/-- Berggren matrix C has determinant 1 (proper Lorentz transformation). -/
theorem det_matC : matC.det = 1 := by native_decide

/-- The determinant signature of the Berggren generators is (+1, -1, +1).
    Bridge: connects algebraic topology (orientation) to number theory. -/
theorem berggren_det_signature :
    matA.det = 1 ∧ matB.det = -1 ∧ matC.det = 1 :=
  ⟨det_matA, det_matB, det_matC⟩

/-- Product determinants respect the homomorphism det: GL₃ → ℤ*.
    Bridge: determinant homomorphism ↔ graded structure on Berggren monoid. -/
theorem det_matAB : (matA * matB).det = -1 := by native_decide
theorem det_matAC : (matA * matC).det = 1 := by native_decide
theorem det_matBC : (matB * matC).det = -1 := by native_decide
theorem det_matABC : (matA * matB * matC).det = -1 := by native_decide

/-- Squared matrices all have det = 1 (even powers are always proper). -/
theorem det_matA_sq : (matA * matA).det = 1 := by native_decide
theorem det_matB_sq : (matB * matB).det = 1 := by native_decide
theorem det_matC_sq : (matC * matC).det = 1 := by native_decide

/-! ## Section 3: Lorentz Form Preservation -/

/-- Matrix A preserves the Lorentz metric: Aᵀ Q A = Q.
    Establishes A ∈ O(2,1;ℤ), the integer Lorentz group.
    Bridge: Pythagorean triple generation ↔ discrete Lorentz symmetry.
    Impact: hamiltonian_simulation — discrete Lorentz boosts preserve Minkowski norm. -/
theorem matA_preserves_lorentz : matA.transpose * metricQ * matA = metricQ := by
  native_decide

/-- Matrix B preserves the Lorentz metric: Bᵀ Q B = Q. -/
theorem matB_preserves_lorentz : matB.transpose * metricQ * matB = metricQ := by
  native_decide

/-- Matrix C preserves the Lorentz metric: Cᵀ Q C = Q. -/
theorem matC_preserves_lorentz : matC.transpose * metricQ * matC = metricQ := by
  native_decide

/-- All three Berggren generators lie in O(2,1;ℤ).
    Bridge: the entire Berggren monoid is a submonoid of the Lorentz group. -/
theorem berggren_all_in_lorentz_group :
    matA.transpose * metricQ * matA = metricQ ∧
    matB.transpose * metricQ * matB = metricQ ∧
    matC.transpose * metricQ * matC = metricQ :=
  ⟨matA_preserves_lorentz, matB_preserves_lorentz, matC_preserves_lorentz⟩

/-- All pairwise products preserve the Lorentz form — closure under multiplication.
    Bridge: submonoid closure in O(2,1;ℤ) ↔ lattice_crypto orbit generation. -/
theorem matAB_preserves_lorentz :
    (matA * matB).transpose * metricQ * (matA * matB) = metricQ := by native_decide
theorem matAC_preserves_lorentz :
    (matA * matC).transpose * metricQ * (matA * matC) = metricQ := by native_decide
theorem matBC_preserves_lorentz :
    (matB * matC).transpose * metricQ * (matB * matC) = metricQ := by native_decide

/-! ## Section 4: Pythagorean Preservation -/

/-- The A-branch preserves Pythagorean triples.
    Bridge: tree generation ↔ Diophantine invariants. -/
theorem childA_preserves_pythag (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (childA a b c).1 (childA a b c).2.1 (childA a b c).2.2 := by
  unfold IsPythag childA at *; nlinarith [h]

/-- The B-branch preserves Pythagorean triples. -/
theorem childB_preserves_pythag (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (childB a b c).1 (childB a b c).2.1 (childB a b c).2.2 := by
  unfold IsPythag childB at *; nlinarith [h]

/-- The C-branch preserves Pythagorean triples. -/
theorem childC_preserves_pythag (a b c : ℤ) (h : IsPythag a b c) :
    IsPythag (childC a b c).1 (childC a b c).2.1 (childC a b c).2.2 := by
  unfold IsPythag childC at *; nlinarith [h]

/-! ## Section 5: Lorentz Form Preservation (Scalar) -/

/-- The A-branch preserves the Lorentz quadratic form exactly.
    Bridge: Q-invariance ↔ gauge invariance in Hopf-algebraic renormalization. -/
theorem childA_preserves_Q (a b c : ℤ) :
    lorentzQ (childA a b c).1 (childA a b c).2.1 (childA a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ childA; ring

theorem childB_preserves_Q (a b c : ℤ) :
    lorentzQ (childB a b c).1 (childB a b c).2.1 (childB a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ childB; ri
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Rank of Apparition and Fibonacci Primitive Divisors

The file `Catalog/Speculative/AutoResearch/FibonacciApparition.lean` establishes, fully
`sorry`-free, the foundational theory of the **Fibonacci entry point** (rank of apparition)
`fibEntry m` — the least `k > 0` with `m ∣ F k` — culminating in the *law of apparition*
`m ∣ F k ↔ fibEntry m ∣ k` and the characterisation of primitive prime divisors of `F n`
as exactly those primes `p` with `fibEntry p = n`. This recasts the catalog's Carmichael
targets (`fib_primitive_divisor`, `fib_carmichael`, `fib_carmichael_composite`) as
statements about a single arithmetic function. The directions below extend that frontier.

## Direction 1 — Closing the infinite tail of Carmichael's theorem via apparition

The catalog's `fib_carmichael_composite` discharges `13 ≤ n ≤ 10000` by `native_decide`
but leaves composite `n > 10000` as a `sorry`. The entry-point framework reduces this to a
single growth inequality: `F n` has a primitive prime divisor iff the *primitive part*
`Φ_n = F n / ∏_{d ∣ n, d < n} F d` exceeds the contribution of "intrinsic" (non-primitive)
factors, and the only possible non-primitive prime divisor of `Φ_n` is the largest prime
factor `q` of `n`, dividing `Φ_n` exactly once. **The key insight is** that
`fibEntry p = n` partitions the prime divisors of `F n` cleanly, so a Zsygmondy-style
bound `Φ_n > q` for `n > 12` (provable from `φ(α^n) ≍ α^{φ(n)}` with `α = (1+√5)/2`)
closes the tail *uniformly*, eliminating the `10000` cutoff entirely.
**Why now?** The law of apparition is now a proved lemma in this project, so the reduction
from "primitive divisor exists" to "one explicit real-analytic inequality" is purely
mechanical — the remaining work is a single growth estimate rather than a full number-theoretic edifice.

## Direction 2 — The apparition bound `fibEntry p ∣ p − (5 ∣ p)`

For an odd prime `p ≠ 5`, the rank of apparition divides `p − (5/p)` where `(5/p)` is the
Legendre symbol; equivalently `fibEntry p ∣ p − 1` when `p ≡ ±1 (mod 5)` and
`fibEntry p ∣ p + 1` when `p ≡ ±2 (mod 5)`. **The key insight is** that this is the
Fibonacci shadow of Fermat's little theorem in `ZMod p[√5]`: `α^p ≡ α^{(5/p)}`, which our
`fibPair`/`ZMod` machinery already models, so the bound becomes
`p ∣ F_{p − (5/p)}` and then `fibEntry p ∣ p − (5/p)` by the *proved* law of apparition.
**Why now?** The hard direction — turning a congruence into a divisibility of indices —
is exactly `fib_dvd_iff_fibEntry_dvd`, which is finished; only the Frobenius congruence in
the quadratic ring `ZMod p[√5]` remains, and Mathlib's `ZMod` and `Polynomial` API now
make that congruence routine.

## Direction 3 — The Wall–Sun–Sun phenomenon: `fibEntry (p²) = p · fibEntry p`

It is conjectured (and verified for all `p < 2^64`) that for every prime `p`,
`fibEntry (p²) = p · fibEntry p`; a prime violating this is a *Wall–Sun–Sun prime*, none of
which are known. **The key insight is** that `fibEntry` lifts thro
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
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a name, a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
