
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
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
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

**Title**: Deepening: This cycle laid the missing foundation for the "proof phase transition" program.
**Domain**: Applications
**Mathematical framing**: Building on cycle bdd5cb68 (Q=0.765), which proved 727 theorems in Novelty. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: # Future Directions: Proof Phase Transitions in Random Implicational Theories

## Synthesis

This cycle laid the missing foundation for the "proof phase transition" program. The
concept brief referenced an infrastructure (`ImplTheory`, `Derivable`,
`theory_extension_monotone`, `chain_derivable`, the
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/EML/LogAffineNormal.lean
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import EML.CategoryDefs

/-!
# Log-Affine Normal Form and Normalization

This file defines a syntactic representation of the multiplicative positive EML fragment
and proves a semantic normalization theorem: every expression in the multiplicative
positive fragment evaluates to a log-affine function.

## Main definitions

* `PosEMLExpr n` — Inductive syntax for the multiplicative positive fragment of EML:
  coordinate projections, positive constants, multiplication, and real powers `x^r`.

* `evalPosEML` — Semantic evaluation of `PosEMLExpr n` on positive vectors.

* `toLogAffineForm` — Syntactic normalization: every `PosEMLExpr` normalizes to
  weights `w : Fin n → ℝ` and a constant `c : ℝ`.

## Main results

* `evalPosEML_eq_logAffine` — Semantic correctness: the evaluation of any multiplicative
  positive EML expression equals its log-affine normal form `exp(∑ wᵢ log xᵢ + c)`.

* `posEML_is_logAffine` — Every multiplicative positive EML expression is `LogAffine`.

## Significance

This establishes a **normal form theorem** for the multiplicative positive fragment:
every expression built from coordinate projections, positive constants, multiplication,
and real powers is equivalent to a weighted geometric monomial. This is the algebraic
content of "log-linearization" — the multiplicative fragment secretly lives in the
affine geometry of logarithmic coordinates.
-/

noncomputable section

open Finset Real

/-! ## Syntax for the multiplicative positive fragment -/

/-- Syntactic expressions for the multiplicative positive EML fragment.
These expressions are guaranteed to evaluate to positive values on positive inputs. -/
inductive PosEMLExpr (n : ℕ) : Type where
  /-- Coordinate projection `xᵢ`. -/
  | coord (i : Fin n) : PosEMLExpr n
  /-- A positive constant `c > 0`. -/
  | posConst (c : ℝ) (hc : 0 < c) : PosEMLExpr n
  /-- Multiplication `e₁ · e₂`. -/
  | mul (e₁ e₂ : PosEMLExpr n) : PosEMLExpr n
  /-- Real power `e^r` for `r : ℝ`. -/
  | rpow (e : PosEMLExpr n) (r : ℝ) : PosEMLExpr n

/-- Semantic evaluation of a multiplicative positive EML expression on a positive vector. -/
def evalPosEML {n : ℕ} : PosEMLExpr n → PosVec n → ℝ
  | .coord i, x => x.val i
  | .posConst c _, _ => c
  | .mul e₁ e₂, x => evalPosEML e₁ x * evalPosEML e₂ x
  | .rpow e r, x => (evalPosEML e x) ^ r

/-
Evaluation of positive EML expressions is strictly positive on positive inputs.
-/
theorem evalPosEML_pos {n : ℕ} (e : PosEMLExpr n) (x : PosVec n) :
    0 < evalPosEML e x := by
  induction' e with e₁ e₂ ih₁ ih₂ e ih;
  · exact x.pos e₁;
  · exact ih₁;
  · exact mul_pos ih ‹_›;
  · exact Real.rpow_pos_of_pos ‹_› _

/-! ## Syntactic normalization to log-affine form -/

/-- Normalize a multiplicative positive EML expression to log-affine form:
returns weights `w : Fin n → ℝ` and a constant `c : ℝ` such that the expression
evaluates to `exp(∑ᵢ wᵢ · log(xᵢ) + c)`. -/
def toLogAffineForm {n : ℕ} : PosEMLExpr n → (Fin n → ℝ) × ℝ
  | .coord i => (Pi.single i 1, 0)
  | .posConst c _ => (0, Real.log c)
  | .mul e₁ e₂ =>
    let (w₁, c₁) := toLogAffineForm e₁
    let (w₂, c₂) := toLogAffineForm e₂
    (w₁ + w₂, c₁ + c₂)
  | .rpow e r =>
    let (w, c) := toLogAffineForm e
    (r • w, r * c)

/-
**Semantic correctness of normalization.** The evaluation of any multiplicative
positive EML expression equals its log-affine normal form.

For any expression `e` and positive input `x`:
  `eval(e)(x) = exp(∑ᵢ wᵢ · log(xᵢ) + c)`
where `(w, c) = toLogAffineForm(e)`.

This is the core normalization theorem: it says the syntactic normalization procedure
correctly computes the log-affine representation.
-/
theorem evalPosEML_eq_logAffine {n : ℕ} (e : PosEMLExpr n) (x : PosVec n) :
    evalPosEML e x =
      Real.exp (∑ i, (toLogAffineForm e).1 i * Real.log (x.val i) + (toLogAffineForm e).2) := by
  induction' e with e₁ e₂ ih₁ ih₂;
  · simp +decide [ evalPosEML, toLogAffineForm ];
    rw [ Finset.sum_eq_single e₁ ] <;> simp +decide [ Real.exp_log ( x.pos _ ) ];
    exact fun i hi => Or.inl <| Pi.single_eq_of_ne hi _;
  · unfold evalPosEML toLogAffineForm; norm_num [ Real.exp_log ih₁ ] ;
  · erw [ show evalPosEML ( ih₂.mul _ ) x = evalPosEML ih₂ x * evalPosEML _ x from rfl ] ; simp_all +decide [ Real.exp_add, Finset.sum_add_distrib ];
    erw [ show toLogAffineForm ( ih₂.mul _ ) = ( ( toLogAffineForm ih₂ ).1 + ( toLogAffineForm _ ).1, ( toLogAffineForm ih₂ ).2 + ( toLogAffineForm _ ).2 ) from rfl ] ; simp +decide [ Finset.sum_add_distrib, mul_assoc, ← Real.exp_add ] ; ring;
    rw [ Finset.sum_add_distrib ] ; ring;
  · simp_all +decide [ evalPosEML, toLogAffineForm ];
    rw [ ← Real.exp_mul ] ; simp +decide [ mul_add, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ;

/-- Every multiplicative positive EML expression is `LogAffine`. -/
theorem posEML_is_logAffine {n : ℕ} (e : PosEMLExpr n) :
    LogAffine n (evalPosEML e) := by
  exact ⟨(toLogAffineForm e).1, (toLogAffineForm e).2,
    fun x => evalPosEML_eq_logAffine e x⟩

end


-- NEW_FILE: Catalog/EML/StratifiedCakeTheory.lean
/-
# Stratified Cake Theory: Algebraic Geometry of Layered Structures

This module formalizes the mathematics of "cakes" — stratified combinatorial objects
that encode the topology of compact surfaces with boundary, marked points (cherries),
and layer decompositions. The key results are:

1. **Euler Characteristic Formula**: For a surface of genus g with b boundary components,
   χ = 2 - 2g - b.

2. **Moduli Dimension Theorem**: The moduli space of conformal structures on a genus-g
   surface with n marked points has (real) dimension 6g - 6 + 2n when this is positive.

3. **Layer Stratification Dimension**: A complete flag stratification of a d-dimensional
   cake (variety) has exactly d+1 layers with strictly decreasing dimensions.

4. **Cherry-Genus Duality**: The relationship between boundary components and
   topological genus constrains the space of valid cake configurations.
-/

import Mathlib

open Finset BigOperators

/-! ## Core Definitions -/

/-- A `CakeData` encodes the combinatorial topology of a "cake":
  a compact orientable surface with genus `g`, `b` boundary components (frosting edges),
  `n` marked points (cherries), and `k` layers in a stratification. -/
structure CakeData where
  genus : ℕ          -- topological genus of the base surface
  boundary : ℕ       -- number of boundary components (frosting edges)
  cherries : ℕ       -- number of marked points on the surface
  layers : ℕ         -- number of layers in the stratification (excluding top)
  deriving Repr, DecidableEq

/-- The Euler characteristic of the base surface of a cake.
    For an orientable surface of genus g with b boundary components: χ = 2 - 2g - b -/
def CakeData.eulerChar (C : CakeData) : ℤ :=
  2 - 2 * (C.genus : ℤ) - (C.boundary : ℤ)

/-- A cake is "valid" if it represents a realizable surface:
    the Euler characteristic constraint is satisfiable and the stratification
    has at least one layer. -/
def CakeData.isValid (C : CakeData) : Prop :=
  C.layers ≥ 1 ∧ (C.genus ≥ 1 ∨ C.boundary ≥ 1)

/-- The real dimension of the moduli space of conformal structures on the base surface
    with marked cherry positions. For genus g with n marked points:
    dim = 6g - 6 + 2n (real dimension of Teichmüller space with marked points) -/
def CakeData.moduliDimFormula (C : CakeData) : ℤ :=
  6 * (C.genus : ℤ) - 6 + 2 * (C.cherries : ℤ)

/-- The "complex moduli dimension" — half the real dimension when the surface
    admits a complex structure. This gives 3g - 3 + n. -/
def CakeData.complexModuliDim (C : CakeData) : ℤ :=
  3 * (C.genus : ℤ) - 3 + (C.cherries : ℤ)

/-- A `LayerStratification d` represents a complete flag of subvarieties
    in a d-dimensional ambient space. It is a strictly decreasing sequence
    of natural numbers starting at d and ending at 0. -/
structure LayerStratification 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Proof Metric and the Proof-Length Phase Transition

## Synthesis

This cycle deepened the *proof phase transition* program by supplying the one structural
fact the earlier infrastructure was missing: **proof length composes additively**. The
catalog files `ProofPhaseTransitions`, `ProofPhaseTransitionsCompleteness`,
`ImplicationalThreshold`, and `HypergraphThreshold` had already established that
derivability is reflexive–transitive-closure reachability (a *preorder*), that the barrier
method is sound and complete, that derivability is a Kuratowski closure operator, and that
the length-graded predicate `DerivOfLen T a b k` pins the diameter of the chain theory to
`n`. What was absent was the *algebra of lengths*. The new file `ProofMetric.lean` closes
this gap with `derivOfLen_comp` (graded transitivity: an `m`-step derivation followed by an
`n`-step derivation is an `(m+n)`-step derivation) and harvests three consequences that
upgrade derivability from a preorder to a **geometry**: `minDerivLen` is a reflexive,
triangle-obeying ℕ-valued quasi-metric (`minDerivLen_self`, `minDerivLen_triangle`); the
chain theory realizes geodesics with *zero proof slack* (`minDerivLen_chain_eq`,
`minDerivLen_chain_geodesic`); and the lengths of closed derivations `a ⊢ a` form an
additive submonoid of ℕ (`loopLengths_add`, `loopLengths_zero`), opening a bridge to
numerical-semigroup structure.

## Results Summary

All results are fully proved (no `sorry`, axiom-clean) in `ProofMetric.lean`:

1. `derivOfLen_comp` — additive composition of length-graded derivations.
2. `minDerivLen_self` — the proof metric is reflexive (`d(a,a) = 0`).
3. `minDerivLen_triangle` — the directed triangle inequality `d(a,c) ≤ d(a,b) + d(b,c)`.
4. `minDerivLen_chain_eq` — on the chain, `d(a,b) = b - a`, sharpening the catalog diameter.
5. `minDerivLen_chain_geodesic` — on the chain the triangle inequality is an *equality*.
6. `loopLengths_add` / `loopLengths_zero` — loop lengths form an additive submonoid of ℕ.

Together these exhibit `minDerivLen T` as an asymmetric premetric on the atoms of *any*
implicational theory, with the chain as its zero-slack extremal geodesic.

---

## Direction 1 — The Frobenius signature of a proof-length phase transition

The loop-length submonoid `L(T,a) = {k | DerivOfLen T a a k}` is now known to be an
additive submonoid of ℕ. For the chain, `L = {0}` (no nontrivial loops); but in a theory
with two cycles through `a` of coprime lengths `p, q`, `L` becomes a numerical semigroup
with a finite **Frobenius number** `g(p,q) = pq - p - q`. The conjecture: in a random
implicational theory on `n` atoms with edge density `c/n`, the typical loop-length submonoid
through a fixed atom undergoes a sharp transition — below threshold `L = {0}` (a tree-like,
loop-free neighborhood), above threshold `L` is cofinite with Frobenius number `Θ(log n)`.
**The key insight is** that loop lengths are not an arbitrary set but a numerical semigroup,
so the *e
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
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
