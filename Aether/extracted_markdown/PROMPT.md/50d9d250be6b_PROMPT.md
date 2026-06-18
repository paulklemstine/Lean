
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

**Title**: Close Proofs: Topological Quantum Computing: Braiding Universality
**Domain**: Applications
**Mathematical framing**: Cycle 4471cf7c (Q=0.557) proved 456 theorems in Bridges but left 13 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Prove that any quantum circuit can be approximated by braiding anyons. Formalize the Jones polynomial as a universal topological quantum invariant and prove density in SU(2).
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Speculative/AutoResearch/BraidingUniversalityExt.lean
/-
# Topological Quantum Computing: Braiding Universality — Extensions

This module **extends** `Catalog.Speculative.AutoResearch.BraidingUniversality`
(Cycle 4471cf7c) with new, fully-proved structural results about the algebraic
and number-theoretic kernel of anyon-braiding universality. The parent file
established:
* `BraidingUniversality.burau_braid_relation` — the reduced Burau matrices of
  `B₃` satisfy the Yang–Baxter braid relation;
* `BraidingUniversality.burau_det₁`/`burau_det₂` — both generators have
  determinant `-t`;
* `BraidingUniversality.phaseGate_orbit_dense` /
  `BraidingUniversality.fibonacci_phase_not_dense` — the irrationality
  dichotomy for density of a single phase gate on the torus;
* `BraidingUniversality.su2_braiding_dense` — the full `SU(2)` density
  *conjecture* (still open, left as `sorry`, requires the classification of
  closed subgroups of `SU(2)`).

Here we add four genuinely new theorems that strengthen this foundation into a
*group-representation* statement and a *sharp order dichotomy*:

1. **Burau invertibility, witnessed (`burauSigma₁_mul_inv`, `burau_isUnit₁`).**
   We exhibit the explicit inverse matrix of `σ₁` and prove it is a two-sided
   inverse for `t ≠ 0`, upgrading `burau_det₁` from "determinant `≠ 0`" to a
   constructive unit witness in `GL₂(ℂ)`.

2. **The full twist is central and scalar (`burau_fullTwist_scalar`,
   `burau_fullTwist_central`).** The Burau image of the full twist `(σ₁σ₂)³`
   — the generator of the center `Z(B₃)` — is exactly the scalar matrix
   `t³ · I`. This is the linear shadow of the *framing anomaly / topological
   spin* of the anyon, and it implies the full twist commutes with every gate.

3. **Markov-trace value of the full twist (`burau_fullTwist_trace`).** Its
   (unnormalized Markov) trace is `2t³`, the elementary input to the Jones
   polynomial of the closure of `(σ₁σ₂)³` (a torus link).

4. **Sharp order dichotomy on the torus (`rational_phase_finite_order`,
   `irrational_phase_injective`).** A phase gate has *finite order* exactly
   when its phase is rational, and its orbit map is *injective* (infinite
   order) exactly when the phase is irrational. This converts the parent file's
   density dichotomy into the corresponding subgroup-order dichotomy, making the
   Fibonacci `4/5` obstruction precise: order dividing `5`.

We also re-derive, as a corollary of the parent's `phaseGate_orbit_dense`, that
the irrational phase `√2` yields a dense braiding gate (`sqrt2_phase_dense`),
illustrating cross-use of the catalog result.
-/
import Mathlib
import Catalog.Speculative.AutoResearch.BraidingUniversality

open Matrix

namespace BraidingUniversality

noncomputable section

/-! ## I. Burau invertibility, witnessed

`burau_det₁` only says `det = -t ≠ 0`. Here we produce the explicit inverse and
prove it is two-sided, so the Burau map provably lands in the unit group of the
matrix ring (i.e. `GL₂(ℂ)`) — the precise sense in which braiding gives a
*group* representation of `B₃`. -/

/-- The explicit inverse matrix of the first Burau generator `σ₁` (valid for
`t ≠ 0`). -/
def burauSigma₁Inv (t : ℂ) : Matrix (Fin 2) (Fin 2) ℂ := !![-t⁻¹, t⁻¹; 0, 1]

-- !-- σ₁ · σ₁⁻¹ = I -- !--
-- !-- Entrywise expansion; the only nontrivial entry cancels via t·t⁻¹ = 1 (field_simp). -- !--
/-- `burauSigma₁Inv` is a right inverse of `burauSigma₁` for `t ≠ 0`. -/
theorem burauSigma₁_mul_inv (t : ℂ) (ht : t ≠ 0) :
    burauSigma₁ t * burauSigma₁Inv t = (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [burauSigma₁, burauSigma₁Inv, Matrix.mul_apply, Fin.sum_univ_two] <;>
    field_simp <;> ring

-- !-- σ₁⁻¹ · σ₁ = I -- !--
-- !-- Same entrywise expansion on the other side. -- !--
/-- `burauSigma₁Inv` is a left inverse of `burauSigma₁` for `t ≠ 0`. -/
theorem burauSigma₁_inv_mul (t : ℂ) (ht : t ≠ 0) :
    burauSigma₁Inv t * burauSigma₁ t = (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [burauSigma₁, burauSigma₁Inv, Matrix.mul_apply, Fin.sum_univ_two] <;>
    field_simp

-- !-- σ₁ is a unit in the matrix ring -- !--
-- !-- det σ₁ = -t (burau_det₁) is a nonzero scalar, so isUnit_iff_isUnit_det applies. -- !--
/-- The first Burau generator is a **unit** of the matrix ring `M₂(ℂ)` for
`t ≠ 0`, i.e. an element of `GL₂(ℂ)`. Upgrades `burau_det₁`. -/
theorem burau_isUnit₁ (t : ℂ) (ht : t ≠ 0) : IsUnit (burauSigma₁ t) := by
  rw [Matrix.isUnit_iff_isUnit_det, burau_det₁]
  exact (isUnit_iff_ne_zero).2 (by simpa using ht)

/-! ## II. The full twist `(σ₁σ₂)³` is scalar, hence central

The center of `B₃` is the infinite cyclic group generated by the **full twist**
`Δ² = (σ₁σ₂)³`. Under the Burau representation it must therefore map to a matrix
commuting with the whole image; we compute it exactly: it is the scalar `t³ · I`.
Physically `t³` is the linear avatar of the anyon's topological spin / framing
anomaly. -/

-- !-- Full twist is scalar -- !--
-- !-- Expand (σ₁σ₂)³ entrywise; direct computation gives !![t³,0;0,t³] = t³ • I. -- !--
/-- **Full twist is scalar.** The Burau image of the central element
`(σ₁σ₂)³ ∈ Z(B₃)` is exactly `t³ · I`. -/
theorem burau_fullTwist_scalar (t : ℂ) :
    (burauSigma₁ t * burauSigma₂ t) ^ 3
      = (t ^ 3) • (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  simp only [pow_succ, pow_zero, one_mul]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [burauSigma₁, burauSigma₂, Matrix.mul_apply, Fin.sum_univ_two,
      Matrix.smul_apply]

-- !-- Full twist is central -- !--
-- !-- Being a scalar matrix t³•I, it commutes with every M: smul_mul/mul_smul. -- !--
/-- **Full twist is central.** Because its Burau image is scalar, the full twist
commutes with every gate `M` in the representation. This is the linear form of
`(σ₁σ₂)³ ∈ Z(B₃)`. -/
theorem burau_fullTwist_central (t : ℂ) (M : Matrix (Fin 2) (Fin 2) ℂ) :
    (burauSigma₁ t * burauSigma₂ t) ^ 3 * M
      = M * (burauSigma₁ t * burauSigma₂ t) ^ 3 := by
  rw [burau_fullTwist_scalar]
  rw [Matrix.smul_mul, Matrix.mul_smul, one_mul, Matrix.mul_one]

-- !-- Markov trace of the full twist -- !--
-- !-- trace (t³ • I₂) = t³ · trace I₂ = t³ · 2. -- !--
/-- **Markov-trace value.** The (unnormalized) trace of the Burau full twist is
`2t³`; this is the elementary trace input feeding the Jones polynomial of the
closure of `(σ₁σ₂)³` (a torus link). -/
theorem burau_fullTwist_trace (t : ℂ) :
    Matrix.trace ((burauSigma₁ t * burauSigma₂ t) ^ 3) = 2 * t ^ 3 := by
  rw [burau_fullTwist_scalar, Matrix.trace_smul, Matrix.trace_one]
  simp [Fintype.card_fin]
  ring

-- !-- Lab Notebook: burau_fullTwist_scalar / _central / _trace -- !--
-- !-- Hypothesis: the central full twist (σ₁σ₂)³ acts as a scalar in reduced Burau. -- !--
-- !-- Result: it equals t³ • I exactly, hence commutes with all gates; trace = 2t³. -- !--
-- !-- Insight: the center Z(B₃) = ⟨(σ₁σ₂)³⟩ is sent to the SCALARS — the abelian -- !--
-- !--   part of GL₂. This is precisely why the full twist carries no quantum-gate -- !--
-- !--   information beyond a global phase: scalar matrices are global phases, the -- !--
-- !--   framing/topological-spin anomaly of the anyon. -- !--
-- !-- Failure analysis: none; the computation is a polynomial identity closed by -- !--
-- !--   entrywise simp after Fin.sum_univ_two unfolding. -- !--
-- !-- End Lab Notebook -- !--

/-! ## III. Sharp order dichotomy on the maximal torus

The parent file proved *density* of a phase orbit is equivalent to irrationality
of the phase. Here we prove the companion *order* dichotomy at the level of the
group element itself: rational phase ⇒ finite order; irrational phase ⇒ the
orbit map is injective (infinite order). Together these pin down the structure of
the cyclic subgroup generated by a single braiding phase gate. -/

-- !-- Rational phase has finite order -- !--
-- !-- q • (k/q) = k and ↑(k:ℝ) = 0 in AddCircle 1 since k is an integer multiple of 1. -- !--
/-
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Braiding Universality (Extensions)

This cycle extended `BraidingUniversality` with a constructive group-theoretic
upgrade of the reduced Burau representation of `B₃` (explicit inverses, the
scalar/central full twist `t³·I`, its Markov trace `2t³`) and the sharp
*order* dichotomy on the maximal torus (rational phase ⇒ finite order;
irrational phase ⇒ injective orbit), complementing the parent file's *density*
dichotomy. Below are five concrete, falsifiable directions that build on this.

## 1. Burau is a genuine group homomorphism `B₃ → GL₂(ℂ)`

We have the braid relation (`burau_braid_relation`) and two-sided invertibility
(`burauSigma₁_mul_inv`, `burau_isUnit₁`). The missing step is to package these
into an actual monoid/group homomorphism out of a presented `B₃` (e.g. via
`PresentedGroup` or `FreeGroup` quotient) into `GL (Fin 2) ℂ`, and prove the
center generator `(σ₁σ₂)³` maps to the scalars (already proved pointwise as
`burau_fullTwist_scalar`). **The key insight is** that all the *relations* needed
for a well-defined homomorphism are already discharged as matrix identities, so
the only remaining work is the universal-property plumbing, not new mathematics.
**Why now?** Mathlib's `PresentedGroup`/`FreeGroup.lift` API is mature, and the
relation lemma is in hand, so this is a self-contained formalization win that
turns scattered matrix facts into a first-class representation object reusable
by every downstream Jones-polynomial result.

## 2. Faithfulness of reduced Burau on `B₃` (the `n=3` Bigelow regime)

Reduced Burau is known to be faithful for `n ≤ 3` and unfaithful for `n ≥ 5`.
Formalize the positive `n=3` case: the homomorphism of Direction 1 is injective.
**The key insight is** that for three strands the image can be analyzed through
the explicit `2×2` matrices and the ping-pong lemma on the action on the
hyperbolic plane / a suitable tree, reducing faithfulness to a free-product
sub-structure already partly visible in the non-commuting generators. **Why
now?** Mathlib has the ping-pong lemma (`FreeGroup`/`PingPongLemma`) and the
matrices are fully explicit here, making `n=3` faithfulness a realistic target
that would be the first formal faithfulness result for any braid representation.

## 3. Specialization to a unitary representation at a root of unity

The Jones representation becomes unitary when `t = e^{2πi/r}` lies on the unit
circle. Formalize: at such `t`, the Burau generators (suitably normalized) are
unitary, so the image lands in `U(2)` and, after fixing determinants, in
`SU(2)`. **The key insight is** that the eigenphase data computed here
(`burau_det₁ = -t`, full twist `= t³·I`) already pins the determinant and global
phase, so unitarity reduces to a single Gram-matrix positivity condition at
`|t|=1`. **Why now?** This is the precise bridge from the algebra we proved to
the still-open `su2_braiding_dense` conjecture in the parent file: it produces
the *concrete* candidate `SU(2)` generators whose den
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
