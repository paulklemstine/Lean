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
    (1 / 2) * (∑ i, |p i - q i|) ^ 2 ≤ klDiv p q := by
  sorry

end FisherInformationMetric

end