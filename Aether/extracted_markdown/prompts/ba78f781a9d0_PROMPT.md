
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

**Title**: Information-Geometric Bridge: Fisher Metric on Statistical Manifolds
**Domain**: Novelty
**Mathematical framing**: Prove that the Fisher information metric on a statistical manifold satisfies the axioms of a Riemannian metric. Construct explicit connections between the Fisher metric and the Kullback-Leibler divergence. Bridge statistical inference to differential geometry.
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/FisherInformationRiemannian.lean
/-
  # Information-Geometric Bridge: the Fisher Metric on Statistical Manifolds

  This module formalizes, for a finite-sample-space statistical model parametrized
  by `ℝ^d`, the **Fisher information matrix** as an explicit expectation of the
  outer product of score functions, and proves that it satisfies the axioms of a
  Riemannian metric tensor:

  * `fisher_symm`        — the Fisher matrix is symmetric;
  * `fisher_quadForm_eq` — its quadratic form is an expectation of squares;
  * `fisher_posSemidef`  — it is positive semidefinite (metric nonnegativity);
  * `fisher_posDef`      — it is positive definite under score nondegeneracy.

  We then build the bridge to statistical inference / differential geometry:

  * `fisher_eq_score_cov`           — Fisher = covariance of the (zero-mean) score;
  * `fisher_eq_neg_expected_hessian`— Fisher = −E[Hessian of the log-likelihood],
        the *two forms of Fisher information* identity, i.e. the statement that the
        Fisher metric is the curvature (Hessian) of the Kullback–Leibler divergence;
  * `KL_self_zero`, `KL_nonneg`     — the Kullback–Leibler divergence vanishes on
        the diagonal and is nonnegative (Gibbs' inequality), the global companion of
        the local curvature statement above.

  Finally `bernoulliModel` is a concrete worked instance whose Fisher information is
  computed in closed form (`bernoulli_fisher`).

  This EXTENDS the abstract `MetricTensor` / Bregman picture of
  `Bridges.InformationGeometryOptimization`: there the Fisher metric is taken as a
  positive-definite tensor axiomatically; here we *construct* it from a probability
  model and *derive* the metric axioms and the KL connection.
-/
import Mathlib

open Finset BigOperators Real

noncomputable section

namespace FisherRiemannian

/-! ## I. Statistical models on a finite sample space -/

/-- A statistical model on the finite sample space `Fin n`, parametrized by
    `Fin d → ℝ`.  `p θ x` is the probability of outcome `x` under parameter `θ`,
    and `score θ x i` is the `i`-th component of the score vector
    `∂_i log p(x; θ)`.  The regularity condition `score_mean_zero` (`E_θ[score] = 0`)
    holds for every smooth model since `∑_x p = 1` is constant. -/
structure StatModel (n d : ℕ) where
  p : (Fin d → ℝ) → Fin n → ℝ
  p_pos : ∀ θ x, 0 < p θ x
  p_sum : ∀ θ, ∑ x, p θ x = 1
  score : (Fin d → ℝ) → Fin n → Fin d → ℝ
  score_mean_zero : ∀ θ i, ∑ x, p θ x * score θ x i = 0

variable {n d : ℕ}

/-- The Fisher information matrix
    `G_{ij}(θ) = E_θ[ ∂_i log p · ∂_j log p ] = ∑_x p(x;θ) · score_i · score_j`. -/
def fisher (M : StatModel n d) (θ : Fin d → ℝ) (i j : Fin d) : ℝ :=
  ∑ x, M.p θ x * M.score θ x i * M.score θ x j

/-! ## II. The Fisher matrix is a Riemannian metric tensor -/

-- !-- The Fisher matrix is symmetric because each summand is symmetric in i,j. -- !--
theorem fisher_symm (M : StatModel n d) (θ : Fin d → ℝ) (i j : Fin d) :
    fisher M θ i j = fisher M θ j i := by
  simp [fisher, mul_assoc, mul_comm, mul_left_comm]

-- !-- Expanding the double sum and pulling p out, the quadratic form collapses to
--     ∑_x p(x;θ) · (∑_i v i · score_i)², a manifestly nonnegative quantity. -- !--
theorem fisher_quadForm_eq (M : StatModel n d) (θ v : Fin d → ℝ) :
    (∑ i, ∑ j, v i * fisher M θ i j * v j)
      = ∑ x, M.p θ x * (∑ i, v i * M.score θ x i) ^ 2 := by
  simp +decide [ fisher, pow_two, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
  exact Eq.symm ( by rw [ Finset.sum_comm ] ; exact Finset.sum_congr rfl fun _ _ => Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring ) )

-- !-- Positive semidefiniteness: the quadratic form equals a sum of p·(·)² ≥ 0. -- !--
theorem fisher_posSemidef (M : StatModel n d) (θ v : Fin d → ℝ) :
    0 ≤ ∑ i, ∑ j, v i * fisher M θ i j * v j := by
  rw [ fisher_quadForm_eq ] ; exact Finset.sum_nonneg fun _ _ => mul_nonneg ( le_of_lt ( M.p_pos _ _ ) ) ( sq_nonneg _ ) ;

/-- Score nondegeneracy at `θ`: the scores of the distinct outcomes span enough of
    `ℝ^d` that no nonzero direction is annihilated by every outcome's score.  This is
    the statistical-manifold rank condition (the model is *identifiable* to first
    order). -/
def ScoreNondegenerate (M : StatModel n d) (θ : Fin d → ℝ) : Prop :=
  ∀ v : Fin d → ℝ, (∀ x, (∑ i, v i * M.score θ x i) = 0) → v = 0

-- !-- Positive definiteness: if the quadratic form vanishes then, since every
--     p(x;θ) > 0, each weighted score ∑_i v i score_i vanishes, so nondegeneracy
--     forces v = 0. -- !--
theorem fisher_posDef (M : StatModel n d) (θ : Fin d → ℝ)
    (hnd : ScoreNondegenerate M θ) (v : Fin d → ℝ) (hv : v ≠ 0) :
    0 < ∑ i, ∑ j, v i * fisher M θ i j * v j := by
  -- By fisher_posSemidef the quadratic form is ≥ 0; suppose for contradiction it is not > 0, so it equals 0.
  by_contra h_contra
  have h_zero : ∑ x, M.p θ x * (∑ i, v i * M.score θ x i) ^ 2 = 0 := by
    rw [ ← fisher_quadForm_eq ];
    exact le_antisymm ( le_of_not_gt h_contra ) ( fisher_posSemidef M θ v );
  rw [ Finset.sum_eq_zero_iff_of_nonneg fun x _ => mul_nonneg ( le_of_lt ( M.p_pos θ x ) ) ( sq_nonneg _ ) ] at h_zero;
  exact hv <| hnd v fun x => by simpa [ ne_of_gt ( M.p_pos θ x ) ] using h_zero x ( Finset.mem_univ x ) ;

/-! ## III. Bridge to inference: Fisher = covariance of the score -/

-- !-- Since the score has zero mean, its covariance E[s_i s_j] − E[s_i]E[s_j] is
--     just E[s_i s_j], which is the Fisher matrix by definition. -- !--
theorem fisher_eq_score_cov (M : StatModel n d) (θ : Fin d → ℝ) (i j : Fin d) :
    fisher M θ i j
      = (∑ x, M.p θ x * M.score θ x i * M.score θ x j)
        - (∑ x, M.p θ x * M.score θ x i) * (∑ x, M.p θ x * M.score θ x j) := by
  unfold fisher; norm_num [ M.score_mean_zero ] ;

/-! ## IV. Bridge to geometry: Fisher = −E[Hessian of the log-likelihood]

    This is the *two forms of Fisher information* identity.  Writing
    `score = ∂ log p` and `hess = ∂² log p`, the chain rule gives
    `∂_i∂_j log p = (∂_i∂_j p)/p − score_i · score_j`.  Combined with the
    regularity condition `∑_x ∂_i∂_j p = 0` (constancy of `∑_x p = 1`), encoded as
    `secondReg`, this yields `G_{ij} = −E_θ[∂_i∂_j log p]`.  Geometrically, the
    right-hand side is the Hessian of the Kullback–Leibler divergence `θ' ↦ KL(θ‖θ')`
    at `θ' = θ`, so the Fisher metric is exactly the curvature of KL. -/

-- !-- Multiply the chain rule `hess = secondScore − score⊗score` by p and sum:
--     ∑ p·hess = ∑ p·secondScore − ∑ p·score⊗score = 0 − fisher = −fisher. -- !--
theorem fisher_eq_neg_expected_hessian (M : StatModel n d) (θ : Fin d → ℝ)
    (i j : Fin d)
    (hess secondScore : Fin n → ℝ)
    (chain : ∀ x, hess x = secondScore x - M.score θ x i * M.score θ x j)
    (secondReg : ∑ x, M.p θ x * secondScore x = 0) :
    fisher M θ i j = - ∑ x, M.p θ x * hess x := by
  simp_all +decide [ mul_sub, mul_comm ]
  exact Finset.sum_congr rfl fun _ _ => by ring

/-! ## V. The global companion: Kullback–Leibler divergence -/

/-- Kullback–Leibler divergence `KL(p‖q) = ∑_x p x · log (p x / q x)`. -/
def KL (p q : Fin n → ℝ) : ℝ := ∑ x, p x * Real.log (p x / q x)

-- !-- KL(p‖p) = ∑ p · log 1 = 0. -- !--
theorem KL_self_zero (p : Fin n → ℝ) (hp : ∀ x, p x ≠ 0) : KL p p = 0 := by
  exact Finset.sum_eq_zero fun x _ => by simp +decide [ hp x ] ;

-- !-- Gibbs' inequality.  Using log t ≤ t − 1 with t = q/p:
--     −KL = ∑ p·log(q/p) ≤ ∑ p·(q/p − 1) = ∑ q − ∑ p = 1 − 1 = 0. -- !--
theorem KL_nonneg (p q : Fin n → ℝ) (hp : ∀ x, 0 < p x) (hq : ∀ x, 0 < q x)
    (hps : ∑ x, p x = 1) (hqs : ∑ x, q x = 1) :
    0 ≤ KL p q := by
  -- Apply the inequality $\log(t) \geq 1 - \frac{1}{t}$ to each term in the sum.
  have h_ineq : ∀ x, p x * Real.log (p x / q x) ≥ p x * (1 - q x / p x) := by
    intro x; have := Real.log_le_sub_one_of_pos ( div_pos ( hq x ) ( hp x ) ) ; simp_all +decide
    rw [ Real.log_div ] at * <;> linarith [ hp x, hq x ]
  re
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Information-Geometric Bridge: Fisher Metric on Statistical Manifolds

The module `Catalog/Bridges/FisherInformationRiemannian.lean` constructs the Fisher
information matrix of a finite-sample-space statistical model *from* its probability
densities and *derives* the Riemannian-metric axioms (symmetry, positive
semidefiniteness, and positive definiteness under score nondegeneracy). It then bridges
to statistical inference and differential geometry: Fisher equals the covariance of the
zero-mean score, Fisher equals the negative expected Hessian of the log-likelihood (the
"two forms of Fisher information"), and the Kullback–Leibler divergence is shown to be
nonnegative (Gibbs) and to vanish on the diagonal. The worked Bernoulli instance pins
the abstraction to a closed-form computation `G(θ) = dσ²/(σ(1−σ))`. This extends the
axiomatic `MetricTensor`/Bregman picture of `Bridges.InformationGeometryOptimization`,
which *assumes* a positive-definite Fisher tensor rather than building one.

Below are five testable, falsifiable directions that the next cycle should pursue.

## 1. The Fisher metric is exactly the local Hessian of KL (analytic, not just algebraic)

Our `fisher_eq_neg_expected_hessian` encodes the curvature–information identity through
hypothesized first- and second-order score fields. The natural strengthening is to
replace those hypotheses by genuine Mathlib `deriv`/`fderiv` objects: take a model
`p : ℝ → Fin n → ℝ` smooth in θ, define `KL θ θ' = ∑ x, p θ x * log (p θ x / p θ' x)`,
and prove `deriv (deriv (fun s => KL θ s)) θ = ∑ x, p θ x * (∂ log p)²`, i.e. the second
derivative of `θ' ↦ KL(θ‖θ')` at the diagonal equals the Fisher quadratic form.
**The key insight is** that the two regularity hypotheses we currently *assume*
(`chain` and `secondReg`) are precisely the statements `∂² log p = ∂²p/p − (∂ log p)²`
and `∑_x ∂² p = 0`, both of which are *theorems* once `∑_x p = 1` is differentiated twice
under the finite sum — so the analytic version is fully within reach of Mathlib's
`deriv_sum` and `Real.deriv_log`. **Why now?** Mathlib v4.28 has mature one-variable
calculus (`deriv`, `HasDerivAt`, chain rule, `deriv_log`), and the sample space is finite,
so no measure-theoretic dominated-convergence machinery is needed — the entire argument is
a finite sum of elementary derivatives.

## 2. Cramér–Rao from positive definiteness: the variance lower bound

We have proved `fisher_posDef`; the canonical payoff is the Cramér–Rao inequality:
for any unbiased estimator `T : Fin n → ℝ` of a scalar functional, the variance is bounded
below by the inverse Fisher information, `Var_θ(T) ≥ 1 / G(θ)`. **The key insight is** that
Cramér–Rao is nothing more than the Cauchy–Schwarz inequality between the centered
estimator `T − E_θ[T]` and the score `s` in the `p θ`-weighted inner product, combined with
the unbiasedness identity `E_θ[(T − E[T])·s] = 1`; both factors already live in our
`StatModel` vocabulary. **Why now?** This connects d
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
