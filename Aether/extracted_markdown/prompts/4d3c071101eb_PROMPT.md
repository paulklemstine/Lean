
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
**Domain**: Bridges
**Mathematical framing**: Prove that the Fisher information metric on a statistical manifold satisfies the axioms of a Riemannian metric. Construct explicit connections between the Fisher metric and the Kullback-Leibler divergence. Bridge statistical inference to differential geometry.
Research domain: Bridges
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Bridges/FisherInformationMetric.lean
import Mathlib

/-!
# Information-Geometric Bridge: Fisher Metric on Statistical Manifolds

This file bridges **statistical inference** and **differential geometry** by treating
the finite categorical model (the open probability simplex over a finite index `ι`)
as a statistical manifold and proving that its **Fisher information form** satisfies
the axioms of a Riemannian metric (symmetric, bilinear, positive-definite inner
product on each tangent space), and then *connecting that metric to the
Kullback–Leibler divergence* via an exact two-sided sandwich.

For the categorical model `p : ι → ℝ` with positive weights, the Fisher information
metric acting on tangent vectors `v, w : ι → ℝ` is the Gram form
`g_p(v, w) = ∑ i, v i * w i / p i`.
This is exactly `∑ x p(x) ∂ᵥ log p(x) ∂_w log p(x)` specialised to the categorical
family `p(x; θ) = θ_x`, where the score is `∂ᵢ log p = δ / p`.

The **bridge to KL** is the chain (for probability vectors `p`, `q` with positive
entries):

  `0 ≤ KL(p ‖ q) ≤ g_q(p − q, p − q)`

The left inequality is Gibbs' inequality; the right inequality says the Fisher
quadratic form (equivalently the χ²-divergence) is a global upper bound for KL,
realising the classical *infinitesimal* fact "Fisher metric = Hessian of KL" as a
genuine non-infinitesimal sandwich.

-- !-- Lab Notebook (file-level) -- !--
-- !-- Hypothesis: The categorical-model Fisher information form is a bona fide -- !--
-- !-- Riemannian metric, and KL divergence is controlled above by its quadratic form. -- !--
-- !-- Result: Proved symmetry, bilinearity, positive-definiteness of `fisherForm`, -- !--
-- !-- Gibbs' inequality `klDiv_nonneg`, and the bridge `klDiv_le_fisher`. -- !--
-- !-- Insight: The single lemma `Real.log_le_sub_one_of_pos` powers BOTH directions -- !--
-- !-- of the KL sandwich (Gibbs via `log(q/p)`, the upper bound via `log(p/q)`); -- !--
-- !-- the normalisation `∑ p = ∑ q = 1` converts the term-wise log bound into a -- !--
-- !-- clean χ² = Fisher upper bound. -- !--
-- !-- Failure analysis: A naive term-wise comparison `KL ≤ χ²` fails without the -- !--
-- !-- normalisation constraints; the `−1` only cancels after summing. -- !--
-- !-- End Lab Notebook -- !--
-/

noncomputable section

open Finset

namespace FisherInformationMetric

variable {ι : Type*} [Fintype ι]

/-- The **Fisher information bilinear form** of the categorical model with weights
`p`, evaluated on tangent vectors `v, w`. For positive `p` this is the Gram form of
the score vectors `∂ᵢ log p = δ / p`. -/
def fisherForm (p v w : ι → ℝ) : ℝ := ∑ i, v i * w i / p i

/-- The **Kullback–Leibler divergence** of `p` from `q`. -/
def klDiv (p q : ι → ℝ) : ℝ := ∑ i, p i * Real.log (p i / q i)

/-- The **Pearson χ²-divergence** of `p` from `q`. -/
def chiSquared (p q : ι → ℝ) : ℝ := ∑ i, (p i - q i) ^ 2 / q i

/-! ## Section 1 — The Fisher form is a Riemannian metric -/

-- !-- Symmetry of the metric: `g(v,w) = g(w,v)` proved termwise via `mul_comm`. -- !--
theorem fisherForm_symm (p v w : ι → ℝ) : fisherForm p v w = fisherForm p w v :=
  Finset.sum_congr rfl fun _ _ => by ring

-- !-- Additivity in the first slot (bilinearity, part 1): distribute the sum. -- !--
theorem fisherForm_add_left (p u v w : ι → ℝ) :
    fisherForm p (u + v) w = fisherForm p u w + fisherForm p v w := by
  simp only [fisherForm, Pi.add_apply, add_mul, add_div, sum_add_distrib]

-- !-- Homogeneity in the first slot (bilinearity, part 2): pull out the scalar. -- !--
theorem fisherForm_smul_left (c : ℝ) (p v w : ι → ℝ) :
    fisherForm p (c • v) w = c * fisherForm p v w := by
  simp only [fisherForm, Pi.smul_apply, smul_eq_mul, mul_assoc, mul_div_assoc,
    Finset.mul_sum]

-- !-- Positive semidefiniteness: each term `v i * v i / p i ≥ 0` for `p i > 0`. -- !--
theorem fisherForm_nonneg (p v : ι → ℝ) (hp : ∀ i, 0 < p i) :
    0 ≤ fisherForm p v v :=
  Finset.sum_nonneg fun i _ => div_nonneg (mul_self_nonneg _) (le_of_lt (hp i))

-- !-- Positive-definiteness: the quadratic form vanishes iff the tangent vector is 0, -- !--
-- !-- so `fisherForm` is a genuine inner product on each tangent space. -- !--
theorem fisherForm_eq_zero_iff (p v : ι → ℝ) (hp : ∀ i, 0 < p i) :
    fisherForm p v v = 0 ↔ v = 0 := by
  rw [fisherForm,
    Finset.sum_eq_zero_iff_of_nonneg
      fun i _ => div_nonneg (mul_self_nonneg _) (le_of_lt (hp i))]
  simp [funext_iff, ne_of_gt (hp _)]

/-! ## Section 2 — Identifying the χ²-divergence with the Fisher quadratic form -/

-- !-- The χ²-divergence is exactly the Fisher quadratic form at the displacement -- !--
-- !-- `p − q`, i.e. `χ²(p‖q) = g_q(p−q, p−q)`. -- !--
theorem chiSquared_eq_fisher (p q : ι → ℝ) :
    chiSquared p q = fisherForm q (p - q) (p - q) := by
  simp only [chiSquared, fisherForm, Pi.sub_apply, sq]

/-! ## Section 3 — The KL bridge -/

-- !-- Gibbs' inequality `KL(p‖q) ≥ 0`: apply `log y ≤ y − 1` to `y = q i / p i`, -- !--
-- !-- multiply by `p i`, sum, and use `∑ p = ∑ q = 1`. -- !--
theorem klDiv_nonneg (p q : ι → ℝ) (hp : ∀ i, 0 < p i) (hq : ∀ i, 0 < q i)
    (hps : ∑ i, p i = 1) (hqs : ∑ i, q i = 1) : 0 ≤ klDiv p q := by
  have h_sum : ∑ i, p i * (1 - q i / p i) ≤ ∑ i, p i * Real.log (p i / q i) := by
    gcongr with i
    · exact le_of_lt (hp i)
    · have := Real.log_le_sub_one_of_pos (div_pos (hq i) (hp i))
      rw [Real.log_div (ne_of_gt (hq i)) (ne_of_gt (hp i))] at *
      rw [Real.log_div (ne_of_gt (hp i)) (ne_of_gt (hq i))]
      linarith
  have hcancel : ∑ i, p i * (1 - q i / p i) = 0 := by
    have : ∀ i, p i * (1 - q i / p i) = p i - q i := fun i => by
      field_simp [ne_of_gt (hp i)]
    simp only [this, Finset.sum_sub_distrib, hps, hqs, sub_self]
  rw [klDiv]
  linarith [h_sum, hcancel]

-- !-- The **bridge** `KL(p‖q) ≤ g_q(p−q, p−q)`: apply `log y ≤ y − 1` to -- !--
-- !-- `y = p i / q i`, multiply by `p i`, sum to get `KL ≤ ∑ p i²/q i − 1`, and -- !--
-- !-- recognise the right side as the χ² = Fisher form via `chiSquared_eq_fisher`. -- !--
theorem klDiv_le_fisher (p q : ι → ℝ) (hp : ∀ i, 0 < p i) (hq : ∀ i, 0 < q i)
    (hps : ∑ i, p i = 1) (hqs : ∑ i, q i = 1) :
    klDiv p q ≤ fisherForm q (p - q) (p - q) := by
  have h_log_le : ∑ i, p i * Real.log (p i / q i)
      ≤ ∑ i, p i * (p i / q i - 1) := by
    gcongr with i
    · exact le_of_lt (hp i)
    · exact Real.log_le_sub_one_of_pos (div_pos (hp i) (hq i))
  have hrhs : ∑ i, p i * (p i / q i - 1) = fisherForm q (p - q) (p - q) := by
    rw [← chiSquared_eq_fisher]
    have hterm : ∀ i, p i * (p i / q i - 1) = (p i - q i) ^ 2 / q i + (p i - q i) :=
      fun i => by field_simp [ne_of_gt (hq i)]; ring
    simp only [chiSquared, hterm, Finset.sum_add_distrib, Finset.sum_sub_distrib,
      hps, hqs, sub_self, add_zero]
  rw [klDiv]
  calc ∑ i, p i * Real.log (p i / q i)
      ≤ ∑ i, p i * (p i / q i - 1) := h_log_le
    _ = fisherForm q (p - q) (p - q) := hrhs

/-! ## Section 4 — Critique and generalization (conjectures)

-- !-- Lab Notebook: generalization -- !--
-- !-- Hypothesis: The KL sandwich can be tightened on the lower side to Pinsker's -- !--
-- !-- inequality `KL ≥ ½ ‖p−q‖₁²`, giving two-sided geometric control of KL by -- !--
-- !-- the L¹ and Fisher (χ²) norms simultaneously. -- !--
-- !-- Boundary: `klDiv_le_fisher` is FALSE without the normalisation `∑p=∑q=1` -- !--
-- !-- (drop it and the `−1` no longer cancels). The positive-definiteness result, -- !--
-- !-- by contrast, needs only `p i > 0`, no normalisation. -- !--
-- !-- End Lab Notebook -- !--
-/

-- !-- Conjecture (Pinsker): lower bound of the sandwich by the squared -- !--
-- !-- total-variation distance. Deferred with `sorry` as a next-cycle target. -- !--
/-- **Conjecture (Pinsker).** Lower bound of the KL sandwich by the squared
total-variation distance. Stated with `sorry` as a research direction for the
next cycle. -/
theorem klDiv_ge_half_tv_sq (p q : ι → ℝ) (hp : ∀ i, 0 < p i) (hq : ∀ i, 0 < q i)
    (hps : ∑ i, p i = 1) (hqs : ∑ i, q i = 1) :
    (1 / 2) * (∑ i, |p i -
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# FUTURE_DIRECTIONS — Information-Geometric Bridge (Cycle 1)

## Synthesis

This cycle established a fully formal bridge between statistical inference and
differential geometry on the finite categorical model (the open probability
simplex over a finite index `ι`). We defined the **Fisher information form**
`g_p(v, w) = ∑ i, v i * w i / p i` and proved it satisfies every axiom of a
Riemannian metric: it is symmetric (`fisherForm_symm`), bilinear
(`fisherForm_add_left`, `fisherForm_smul_left`), positive semidefinite
(`fisherForm_nonneg`), and in fact positive definite (`fisherForm_eq_zero_iff`) —
i.e. a genuine inner product on each tangent space whenever the weights are
strictly positive. This is the "differential geometry" half of the bridge,
realised with no manifold/charts machinery: the categorical model lets us expose
the metric as an explicit Gram form of the score vectors `∂ᵢ log p = δ/p`.

The "statistical inference" half is the **KL sandwich**
`0 ≤ KL(p‖q) ≤ g_q(p−q, p−q)`. The lower bound `klDiv_nonneg` is Gibbs'
inequality; the upper bound `klDiv_le_fisher` is the key new result: the Fisher
quadratic form (shown equal to the Pearson χ²-divergence via
`chiSquared_eq_fisher`) is a *global* upper bound for KL, not merely an
infinitesimal Hessian approximation. The structural insight that emerged is that
a single convexity lemma, `Real.log_le_sub_one_of_pos`, drives both ends of the
sandwich — applied to `q/p` it yields Gibbs, applied to `p/q` it yields the χ²
bound — and that the normalisation `∑p = ∑q = 1` is exactly the hypothesis that
makes the term-wise `−1` cancel so the χ² form appears. The naive term-wise
attempt `KL ≤ χ²` fails without normalisation; this was the main failure analysed.

What did not get done: Pinsker's inequality (the sharper lower bound
`KL ≥ ½‖p−q‖₁²`) is stated as a conjecture with `sorry`. It needs a genuinely
different argument (a 2-point reduction plus a scalar inequality) rather than the
term-wise log bound, which is why it is deferred. These results tie together into
a program: pin down the categorical Fisher metric as an honest inner product,
then control every classical divergence (KL, χ², total variation, Hellinger) by
that single quadratic form, building a dictionary between f-divergences and the
one Riemannian metric.

## Results Summary

- `fisherForm_symm`: proved — the Fisher form is symmetric, the first metric axiom.
- `fisherForm_add_left`: proved — additivity in the first slot (bilinearity).
- `fisherForm_smul_left`: proved — scalar homogeneity in the first slot (bilinearity).
- `fisherForm_nonneg`: proved — the Fisher quadratic form is positive semidefinite.
- `fisherForm_eq_zero_iff`: proved — positive definiteness, so the Fisher form is a true inner product on each tangent space.
- `chiSquared_eq_fisher`: proved — the Pearson χ²-divergence equals the Fisher quadratic form at the displacement `p−q`.
- `klDiv_nonneg`: proved — Gibbs' inequality, the lower end of the KL sandwich.
- `klDiv_le_fish
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
