
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   Reference the specific theorems proved in Phase A using @file references.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work,
   references to catalog results. Use @file references for theorems.
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
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
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
Use the @file references above to point readers to specific theorems.


## Concept

**Title**: The Poincare Conjecture for Data: Manifold Detection via Persistent Homology
**Domain**: Applications
**Mathematical framing**: The Poincare conjecture (proved by Perelman) states that every simply connected closed 3-manifold is homeomorphic to the 3-sphere. For data: a point cloud X = {x_1, ..., x_n} in R^d may or may not lie on a manifold. Conjecture: the Poincare conjecture for data states that if the persistent homology of X satisfies H_0(X) = Z, H_1(X) = 0, H_2(X) = 0, ..., H_{d-1}(X) = 0, then X lies on (or near) a d-sphere. More precisely, if the Vietoris-Rips complex of X at scale epsilon has the homology of S^d (trivial homology except H_0 = Z and H_d = Z), then X is epsilon-close to a subset of S^d. Conjecture: the smallest epsilon such that VR_epsilon(X) has the homology of S^d is the 'Poincare threshold' of X, and it satisfies epsilon_star = C * d^{1/2} * n^{-1/d} for some constant C, where n is the number of points. This is the manifold detection threshold: below epsilon_star, X looks like a d-sphere; above epsilon_star, X looks like something else. Test: generate point clouds on S^d for d = 1, 2, 3 and compute the Poincare threshold. Impact: the Poincare conjecture for data says that manifold detection is a topological problem, and the detection threshold scales as n^{-1/d}.
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/AlgebraicCircuitComplexity.lean
/-
  # Algebraic Circuit Complexity — Core Definitions and Foundational Lemmas

  Bridge: connects Algebra (polynomial rings, ideals) to Computation (circuit complexity).

  This file introduces algebraic circuits as an inductive type over commutative semirings,
  defines evaluation semantics, structural invariants (depth, size, degree bound),
  and proves foundational bounds relating these invariants.

  Key results:
  - Degree of a circuit-computed polynomial ≤ 2^depth (exponential degree-depth tradeoff)
  - Size ≥ depth + 1 (work ≥ span)
  - Evaluation semantics agree with MvPolynomial interpretation
  - Circuit addition/multiplication preserve structural bounds
  - Zero-function circuits form an ideal (closure under add/mul)
-/

import Mathlib

namespace AlgebraicCircuitComplexity

/-! ## Core Circuit Definition

An `AlgCircuit R n` represents a straight-line program over a commutative semiring `R`
with variables indexed by `Fin n`. This is the standard model in algebraic complexity theory.

Bridge: connects Algebra (polynomial ring `R[x₁,...,xₙ]`) to Computation (straight-line programs). -/

/-- An algebraic circuit over a commutative semiring `R` with `n` input variables.
    Each gate computes either a constant, a variable, or an addition/multiplication
    of two sub-circuits. This is the standard algebraic circuit model (Valiant 1979).

    Bridge: connects Algebra (polynomial evaluation) to Computation (circuit complexity). -/
inductive AlgCircuit (R : Type*) [CommSemiring R] (n : ℕ) : Type _ where
  | const : R → AlgCircuit R n
  | var : Fin n → AlgCircuit R n
  | add : AlgCircuit R n → AlgCircuit R n → AlgCircuit R n
  | mul : AlgCircuit R n → AlgCircuit R n → AlgCircuit R n
  deriving Inhabited

variable {R : Type*} [CommSemiring R] {n : ℕ}

/-! ## Evaluation Semantics -/

/-- Evaluate an algebraic circuit on an assignment of values to variables.
    This is the semantic function mapping circuits to the functions they compute.

    Bridge: connects Computation (circuit execution) to Algebra (polynomial evaluation). -/
def AlgCircuit.eval (C : AlgCircuit R n) (v : Fin n → R) : R :=
  match C with
  | .const r => r
  | .var i => v i
  | .add C₁ C₂ => C₁.eval v + C₂.eval v
  | .mul C₁ C₂ => C₁.eval v * C₂.eval v

/-! ## Structural Invariants -/

/-- The depth of an algebraic circuit — the length of the longest root-to-leaf path.
    Depth corresponds to parallel time complexity.

    Bridge: connects Computation (parallel complexity) to Machine Learning
    (neural network depth ↔ expressivity). -/
def AlgCircuit.depth : AlgCircuit R n → ℕ
  | .const _ => 0
  | .var _ => 0
  | .add C₁ C₂ => 1 + max C₁.depth C₂.depth
  | .mul C₁ C₂ => 1 + max C₁.depth C₂.depth

/-- The size of an algebraic circuit — the total number of gates.
    Size corresponds to sequential time complexity / total work.

    Bridge: connects Computation (sequential complexity) to Cryptography
    (circuit size bounds for post-quantum hardness assumptions). -/
def AlgCircuit.size : AlgCircuit R n → ℕ
  | .const _ => 1
  | .var _ => 1
  | .add C₁ C₂ => 1 + C₁.size + C₂.size
  | .mul C₁ C₂ => 1 + C₁.size + C₂.size

/-- Upper bound on the degree of the polynomial computed by a circuit.
    For addition gates: max of sub-degrees. For multiplication: sum.
    This is the syntactic degree bound used in complexity analysis.

    Bridge: connects Algebra (polynomial degree) to Computation (degree as
    complexity measure, Strassen's degree bound). -/
def AlgCircuit.degreeBound : AlgCircuit R n → ℕ
  | .const _ => 0
  | .var _ => 1
  | .add C₁ C₂ => max C₁.degreeBound C₂.degreeBound
  | .mul C₁ C₂ => C₁.degreeBound + C₂.degreeBound

/-- Number of multiplication gates in a circuit.
    The multiplicative complexity is a key measure in algebraic complexity,
    e.g., matrix multiplication lower bounds.

    Bridge: connects Computation (multiplicative complexity) to Cryptography
    (bilinear complexity of lattice operations). -/
def AlgCircuit.mulGates : AlgCircuit R n → ℕ
  | .const _ => 0
  | .var _ => 0
  | .add C₁ C₂ => C₁.mulGates + C₂.mulGates
  | .mul C₁ C₂ => 1 + C₁.mulGates + C₂.mulGates

/-- Number of addition gates in a circuit. -/
def AlgCircuit.addGates : AlgCircuit R n → ℕ
  | .const _ => 0
  | .var _ => 0
  | .add C₁ C₂ => 1 + C₁.addGates + C₂.addGates
  | .mul C₁ C₂ => C₁.addGates + C₂.addGates

/-! ## Mapping Circuits to MvPolynomial

This section bridges the computational (circuit) and algebraic (polynomial) worlds. -/

/-- Map an algebraic circuit to the multivariate polynomial it computes.
    This is the canonical homomorphism from circuits to the polynomial ring.

    Bridge: connects Computation (circuit semantics) to Algebra (polynomial ring `MvPolynomial`). -/
noncomputable def AlgCircuit.toMvPolynomial (C : AlgCircuit R n) : MvPolynomial (Fin n) R :=
  match C with
  | .const r => MvPolynomial.C r
  | .var i => MvPolynomial.X i
  | .add C₁ C₂ => C₁.toMvPolynomial + C₂.toMvPolynomial
  | .mul C₁ C₂ => C₁.toMvPolynomial * C₂.toMvPolynomial

/-! ## Foundational Theorems -/

/-- Evaluation of a circuit agrees with evaluation of its polynomial representation.
    This is the fundamental soundness theorem connecting the computational and algebraic models.

    Bridge: connects Computation (circuit evaluation) to Algebra (polynomial evaluation).
    Uses: structural induction, ring homomorphism properties. -/
theorem eval_eq_mvpolynomial_eval (C : AlgCircuit R n) (v : Fin n → R) :
    C.eval v = MvPolynomial.eval v C.toMvPolynomial := by
  induction C with
  | const r => simp [AlgCircuit.eval, AlgCircuit.toMvPolynomial, MvPolynomial.eval_C]
  | var i => simp [AlgCircuit.eval, AlgCircuit.toMvPolynomial, MvPolynomial.eval_X]
  | add C₁ C₂ ih₁ ih₂ =>
    simp only [AlgCircuit.eval, AlgCircuit.toMvPolynomial, map_add]
    rw [ih₁, ih₂]
  | mul C₁ C₂ ih₁ ih₂ =>
    simp only [AlgCircuit.eval, AlgCircuit.toMvPolynomial, map_mul]
    rw [ih₁, ih₂]

/-- Two circuits computing the same polynomial are semantically equivalent:
    they produce the same output on every input.

    Bridge: connects Computation (circuit equivalence) to Algebra (polynomial equality). -/
theorem circuits_with_same_poly_agree (C₁ C₂ : AlgCircuit R n)
    (h : C₁.toMvPolynomial = C₂.toMvPolynomial) (v : Fin n → R) :
    C₁.eval v = C₂.eval v := by
  rw [eval_eq_mvpolynomial_eval, eval_eq_mvpolynomial_eval, h]

/-- Size of a circuit is always positive. Every circuit has at least one gate. -/
theorem AlgCircuit.size_pos (C : AlgCircuit R n) : 0 < C.size := by
  cases C <;> simp [AlgCircuit.size] <;> omega

/-- Size of a circuit is at least its depth plus one.
    This encodes the fact that sequential computation subsumes parallel computation.

    Bridge: connects Computation (work ≥ span) to Machine Learning
    (total parameters ≥ network depth in neural architectures). -/
theorem size_ge_depth_succ (C : AlgCircuit R n) : C.depth + 1 ≤ C.size := by
  induction C with
  | const _ => simp [AlgCircuit.depth, AlgCircuit.size]
  | var _ => simp [AlgCircuit.depth, AlgCircuit.size]
  | add _ _ ih₁ ih₂ =>
    simp only [AlgCircuit.depth, AlgCircuit.size]; omega
  | mul _ _ ih₁ ih₂ =>
    simp only [AlgCircuit.depth, AlgCircuit.size]; omega

/-- The degree bound of a circuit is at most 2^depth.
    This is the fundamental degree-depth tradeoff: depth-d circuits compute
    polynomials of degree at most 2^d. The bound is tight (iterated squaring).

    Bridge: connects Computation (circuit depth) to Algebra (polynomial degree).
    Impact: This is the algebraic analogue of the depth-width tradeoff in
    neural networks — shallow circuits can only compute low-degree polynomials.

    Proof uses: induction, omega, Nat.pow monotonicity. -/
theorem degreeBound_le_two_pow_depth (C : AlgCircuit R n) :
    C.degreeBound ≤ 2 ^ C.depth := by
  induction C with
  | const _ => simp [AlgCircuit.degreeBound, AlgCircuit.depth]
  | var _ => simp [AlgCircuit.d
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Metric Filtrations and the Poincaré Threshold

## 1. Connectivity Threshold Scaling Law

The **connectivity threshold** ε*(X) of a finite point cloud X ⊂ ℝᵈ is the infimum of ε such that the Rips graph at scale ε is connected (i.e., has exactly one connected component). For n points sampled uniformly on the unit d-sphere Sᵈ, we conjecture:

> **Conjecture**: ε*(X) ~ C · d^{1/2} · n^{-1/d} as n → ∞, where C depends only on d.

The key insight is that the connectivity threshold is controlled by the maximum nearest-neighbor distance, which for uniform samples on Sᵈ scales as n^{-1/d} by volumetric arguments — the surface area of a geodesic cap of radius ε on Sᵈ scales as εᵈ.

**Why now?** Our `MetricFiltration` structure and `ripsGraph_mono` theorem provide the algebraic foundation. The `coveringNumber_antitone` result shows the covering number's monotonicity, which is the dual of the connectivity threshold. The next step is to formalize the probabilistic bound using measure-theoretic arguments about uniform distributions on Sᵈ, which Mathlib's measure theory library now supports.

**Computational test**: Sample n = 100, 1000, 10000 points on S¹, S², S³ and compute ε* by binary search on the Rips graph connectivity. Plot log(ε*) vs log(n) — the slope should be -1/d.

## 2. Persistent Betti Numbers via Chain Complexes

Our current formalization captures the π₀ (connected components) level of the Vietoris-Rips filtration via SimpleGraph. The full persistent homology requires chain complexes over the Rips simplicial complex.

> **Conjecture**: For X uniformly sampled from Sᵈ with n sufficiently large, the Rips complex VR_ε(X) has β₀ = 1, β₁ = β₂ = ... = β_{d-1} = 0, β_d = 1 for ε in an interval [ε_low, ε_high] whose width grows as n^{1/(d+1)}.

The key insight is that the "persistence" (length of the interval where the homology matches Sᵈ) is a quantitative measure of how well the point cloud approximates the sphere, and its scaling law encodes the dimension.

**Why now?** Mathlib has basic homological algebra (chain complexes, homology functors). Our `AbstractSimplicialComplex` in `SimplicialComplex.lean` provides the combinatorial input. The gap is formalizing the boundary operator and proving that the Rips complex of a dense enough sample has the same homology as the underlying manifold (the Nerve Lemma / Niyogi-Smale-Weinberger theorem).

**Computational test**: Compute the full persistent homology barcode of 1000 points on S² using standard TDA software. The longest bar in H₂ should appear at scale ≈ C · n^{-1/2}.

## 3. Packing-Covering Duality and Metric Entropy

Our `maximal_packing_is_cover` theorem establishes the fundamental duality between packings and coverings. This should extend to a full metric entropy theory.

> **Conjecture**: For a compact Riemannian manifold M of dimension d and volume V, the covering number satisfies N(M, ε) = V · ωd⁻¹ · ε⁻ᵈ · (1 + O(ε · κ)) where ωd is the volume of the d-ball and κ is related
```

## Your task

Produce the deliverables listed above. Reference the specific theorems and
results in the Lean code by their @file path and statement. The Lean file is
the source of truth — your prose must accurately explain it.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
