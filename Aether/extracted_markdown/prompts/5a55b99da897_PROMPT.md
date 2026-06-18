
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

**Title**: Deepening: Information-Geometric Bridge: Fisher Metric on Statistical Manifolds
**Domain**: Applications
**Mathematical framing**: Building on cycle 8d1c1869 (Q=0.758), which proved 135 theorems in Novelty. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: Prove that the Fisher information metric on a statistical manifold satisfies the axioms of a Riemannian metric. Construct explicit connections between the Fisher metric and the Kullback-Leibler divergence. Bridge statistical inference to differential geometry.
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/FisherCramerRao.lean
/-
  # Going Deeper on the Information-Geometric Bridge:
  #   Tensorization, the Cramér–Rao bound, and the tensorial law of the Fisher metric

  This module *extends and generalizes* `Bridges.FisherInformationRiemannian`
  (the construction of the Fisher information metric `fisher` on a finite-sample
  statistical model and the proof that it satisfies the Riemannian metric axioms,
  together with the KL bridge).  Here we:

  * **Generalize the sample space** from `Fin n` to an arbitrary finite type `S`
    (`GenStatModel`), and re-derive the metric axioms (`gfisher_symm`,
    `gfisher_posSemidef`, `gfisher_posDef`) in this generality.

  * **Tensorization / additivity of Fisher information** (`gfisher_prod_eq`): the
    Fisher metric of a product of two *independent* models with a shared parameter
    is the *sum* of the two Fisher metrics.  In particular, two i.i.d. observations
    carry twice the single-observation information (`gfisher_iid_two`).  This is the
    precise sense in which Fisher information is *additive over independent data* —
    the statistical foundation of estimator consistency.

  * **The Cramér–Rao lower bound** (`cramer_rao`): for any (regular) statistic `T`
    the variance is bounded below by `ψ'(θ)² / G(θ)`, where `ψ = E_θ[T]`.  This is
    the deepest classical bridge between the Fisher metric and statistical
    inference: the inverse Fisher metric is the intrinsic lower bound on estimator
    variance.  The proof is a weighted Cauchy–Schwarz inequality
    (`expect_mul_sq_le`) for the score inner product, exactly the inner product
    whose Gram matrix is `gfisher`.

  * **The tensorial transformation law** (`gfisher_reparam`): under a smooth
    reparametrization with Jacobian `J`, the Fisher matrix transforms by the
    congruence `G' = Jᵀ G J`.  This is the statement that `gfisher` is a genuine
    `(0,2)`-tensor — the differential-geometric content of "Riemannian metric".

  Together these promote the catalog's "Fisher is a metric" result to the full
  package a working information geometer needs: additivity, the Cramér–Rao
  inference bound, and tensoriality.
-/
import Mathlib

open Finset BigOperators Real

noncomputable section

namespace FisherCramerRao

/-! ## I. Statistical models on an arbitrary finite sample space

    This generalizes `FisherRiemannian.StatModel` (whose sample space is `Fin n`)
    to an arbitrary finite type `S`, which is exactly what is needed to form
    *product* sample spaces `S × S'` for the tensorization theorem. -/

/-- A statistical model on a finite sample space `S`, parametrized by `Fin d → ℝ`. -/
structure GenStatModel (S : Type*) [Fintype S] (d : ℕ) where
  p : (Fin d → ℝ) → S → ℝ
  p_pos : ∀ θ x, 0 < p θ x
  p_sum : ∀ θ, ∑ x, p θ x = 1
  score : (Fin d → ℝ) → S → Fin d → ℝ
  score_mean_zero : ∀ θ i, ∑ x, p θ x * score θ x i = 0

variable {S S' : Type*} [Fintype S] [Fintype S'] {d : ℕ}

/-- The Fisher information matrix of a `GenStatModel`. -/
def gfisher (M : GenStatModel S d) (θ : Fin d → ℝ) (i j : Fin d) : ℝ :=
  ∑ x, M.p θ x * M.score θ x i * M.score θ x j

/-- Expectation of a real statistic under the model at `θ`. -/
def expect (M : GenStatModel S d) (θ : Fin d → ℝ) (f : S → ℝ) : ℝ :=
  ∑ x, M.p θ x * f x

/-- Variance of a real statistic under the model at `θ`. -/
def variance (M : GenStatModel S d) (θ : Fin d → ℝ) (f : S → ℝ) : ℝ :=
  expect M θ (fun x => (f x - expect M θ f) ^ 2)

/-! ## II. The metric axioms in full generality -/

-- !-- Each summand is symmetric in `i, j`. -- !--
theorem gfisher_symm (M : GenStatModel S d) (θ : Fin d → ℝ) (i j : Fin d) :
    gfisher M θ i j = gfisher M θ j i := by
  simp [gfisher, mul_assoc, mul_comm, mul_left_comm]

-- !-- The quadratic form collapses to `∑_x p·(∑_i v_i score_i)²` after swapping
--     the order of summation (`Finset.sum_comm`) and factoring out `p`. -- !--
theorem gfisher_quadForm_eq (M : GenStatModel S d) (θ v : Fin d → ℝ) :
    (∑ i, ∑ j, v i * gfisher M θ i j * v j)
      = ∑ x, M.p θ x * (∑ i, v i * M.score θ x i) ^ 2 := by
  simp +decide [ gfisher, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _,
    Finset.sum_mul, pow_two ]
  exact Eq.symm ( Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_comm ) )

-- !-- Positive semidefiniteness: the quadratic form is a sum of `p·(·)² ≥ 0`. -- !--
theorem gfisher_posSemidef (M : GenStatModel S d) (θ v : Fin d → ℝ) :
    0 ≤ ∑ i, ∑ j, v i * gfisher M θ i j * v j := by
  rw [gfisher_quadForm_eq]
  exact Finset.sum_nonneg fun _ _ => mul_nonneg (le_of_lt (M.p_pos _ _)) (sq_nonneg _)

/-- Score nondegeneracy (first-order identifiability) at `θ`: no nonzero tangent
    direction is annihilated by every outcome's score. -/
def ScoreNondegenerate (M : GenStatModel S d) (θ : Fin d → ℝ) : Prop :=
  ∀ v : Fin d → ℝ, (∀ x, (∑ i, v i * M.score θ x i) = 0) → v = 0

-- !-- Positive definiteness: vanishing of `∑ p·(·)²` with `p > 0` forces every
--     weighted score to vanish, so nondegeneracy gives `v = 0`. -- !--
theorem gfisher_posDef (M : GenStatModel S d) (θ : Fin d → ℝ)
    (hnd : ScoreNondegenerate M θ) (v : Fin d → ℝ) (hv : v ≠ 0) :
    0 < ∑ i, ∑ j, v i * gfisher M θ i j * v j := by
  by_contra h_contra
  obtain ⟨x, hx⟩ : ∃ x : S, M.p θ x * (∑ i, v i * M.score θ x i) ^ 2 ≠ 0 := by
    exact not_forall.mp fun h => hv <| hnd v fun x => by simpa [ ne_of_gt ( M.p_pos θ x ) ] using h x
  exact h_contra <| lt_of_lt_of_le ( lt_of_le_of_ne ( mul_nonneg ( le_of_lt ( M.p_pos θ x ) )
    ( sq_nonneg _ ) ) hx.symm ) <| Finset.single_le_sum ( fun x _ => mul_nonneg
    ( le_of_lt ( M.p_pos θ x ) ) ( sq_nonneg ( ∑ i, v i * M.score θ x i ) ) )
    ( Finset.mem_univ x ) |> le_trans <| by rw [ gfisher_quadForm_eq ]

/-! ## III. Tensorization: Fisher information is additive over independent data -/

/-- The **independent product** of two models on `S`, `S'` sharing the parameter
    `θ`.  The likelihood factorizes, so the score is the *sum* of the two scores
    (the log-likelihood being a sum). -/
def prodModel (M : GenStatModel S d) (N : GenStatModel S' d) :
    GenStatModel (S × S') d where
  p := fun θ x => M.p θ x.1 * N.p θ x.2
  p_pos := fun θ x => mul_pos (M.p_pos θ x.1) (N.p_pos θ x.2)
  p_sum := by
    intro θ
    rw [Fintype.sum_prod_type]
    simp_rw [← Finset.mul_sum, ← Finset.sum_mul, M.p_sum, N.p_sum, one_mul]
  score := fun θ x i => M.score θ x.1 i + N.score θ x.2 i
  score_mean_zero := by
    intro θ i
    simp +decide only [mul_add]
    rw [ Finset.sum_add_distrib, Fintype.sum_prod_type, Fintype.sum_prod_type ]
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm,
      M.p_sum, N.p_sum, M.score_mean_zero, N.score_mean_zero ]

-- !-- Expand `(s^M + s^N)(s^M + s^N)` over the product space into four terms.  The
--     two diagonal terms reproduce `gfisher M` and `gfisher N` (using `∑ p = 1` in
--     the other factor); the two cross terms factor as products of mean-zero scores
--     and so vanish by `score_mean_zero`. -- !--
theorem gfisher_prod_eq (M : GenStatModel S d) (N : GenStatModel S' d)
    (θ : Fin d → ℝ) (i j : Fin d) :
    gfisher (prodModel M N) θ i j = gfisher M θ i j + gfisher N θ i j := by
  simp +decide [ gfisher, prodModel ]
  have h_split : ∑ x : S, ∑ y : S', M.p θ x * N.p θ y * (M.score θ x i + N.score θ y i) * (M.score θ x j + N.score θ y j) =
    (∑ x : S, M.p θ x * M.score θ x i * M.score θ x j) * (∑ y : S', N.p θ y) +
    (∑ y : S', N.p θ y * N.score θ y i * N.score θ y j) * (∑ x : S, M.p θ x) +
    (∑ x : S, M.p θ x * M.score θ x i) * (∑ y : S', N.p θ y * N.score θ y j) +
    (∑ x : S, M.p θ x * M.score θ x j) * (∑ y : S', N.p θ y * N.score θ y i) := by
      simp +decide only [mul_add, mul_assoc, add_mul, sum_add_distrib, sum_mul _ _ _]
      simp +decide only [mul_comm, mul_left_comm, Finset.mul_sum _ _ _] ; ring
      simp +decide only [mul_assoc, Finset.mul_sum _ _ _, sum_mul] ; ring
      exact congr rfl ( Finset.sum_comm.trans ( 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Information-Geometric Bridge (Fisher metric, deepened)

This cycle deepened the catalog's `Bridges.FisherInformationRiemannian` (Fisher
metric = Riemannian metric + KL bridge) and `FisherInformationMetric` (categorical
Fisher form + KL sandwich) into a full inference-geometry package in
`Catalog/Bridges/FisherCramerRao.lean`:

- generalized the statistical model from sample space `Fin n` to an arbitrary finite
  type `S` (`GenStatModel`), re-deriving the metric axioms (`gfisher_symm`,
  `gfisher_posSemidef`, `gfisher_posDef`);
- proved **tensorization / additivity** of Fisher information over independent data
  (`gfisher_prod_eq`, `gfisher_iid_two`);
- proved the **Cramér–Rao lower bound** (`cramer_rao`, `cramer_rao_unbiased`) via a
  weighted Cauchy–Schwarz inequality (`expect_mul_sq_le`);
- proved the **tensorial transformation law** `G' = Jᵀ G J` (`gfisher_reparam`),
  certifying `gfisher` is a genuine `(0,2)`-tensor;
- proved the **attainment / efficiency** equality case (`cramer_rao_equality_iff`):
  equality holds iff the centered statistic is proportional to the score.

The following conjectures extend this work. Each is stated so it can be written down
as a Lean theorem and either proved or refuted.

## 1. The multiparameter matrix Cramér–Rao bound

For a `GenStatModel S d` and a vector statistic `T : S → ℝ` with gradient-of-mean
`b : Fin d → ℝ` satisfying the regularity identities `b i = E_θ[T · score_i]`, the
scalar bound should upgrade to the **matrix inequality** `Var_θ(T) ≥ bᵀ G⁻¹ b`
whenever `G = gfisher M θ` is positive definite, with equality characterized exactly
as in `cramer_rao_equality_iff` but with the proportionality constant replaced by the
vector `G⁻¹ b`.

The key insight is that the single-parameter proof is just the rank-1 shadow of the
positive-semidefiniteness of the `(d+1)×(d+1)` Gram matrix of the family
`{T − E[T], score_1, …, score_d}` under the inner product `⟨f, g⟩ = E_θ[f g]`; the
matrix bound is the Schur-complement nonnegativity of that Gram matrix, so the whole
result reduces to `gfisher_posSemidef` applied to an augmented model. Why now?
`gfisher_posSemidef` and `expect_mul_sq_le` are already proved in full generality over
arbitrary finite `S`, and Mathlib's `Matrix.PosSemidef` plus Schur-complement API give
exactly the linear-algebra layer needed to glue them together.

## 2. Chain rule / monotonicity of Fisher information under coarse-graining

Let `κ : S → S'` be a deterministic statistic (data-processing map) and let `N` be
the pushforward model `N.p θ y = ∑_{x : κ x = y} M.p θ x`. Then the Fisher matrices
should satisfy the **monotonicity** `gfisher N θ ⪯ gfisher M θ` (Loewner order), with
equality iff `κ` is sufficient. This is the information-geometric form of the
data-processing inequality and the converse half of the Fisher–Rao characterization
of sufficiency.

The key insight is that the pushforward score is the conditional expectation of the
original score, `score_N(κ x) = E
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
