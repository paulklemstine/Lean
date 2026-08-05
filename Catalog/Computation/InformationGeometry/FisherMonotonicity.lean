import Mathlib
import Bridges.InformationGeometry.FisherMetric
import Computation.InformationGeometry.FisherInnerProduct

/-!
# Monotonicity of the Fisher form under stochastic maps (Chentsov / data processing)

This file continues the information-geometry thread built on
`Bridges/InformationGeometry/FisherMetric.lean` (which defines `fisherForm`,
`klDiv`, `chiSquared`) and `Computation/InformationGeometry/FisherInnerProduct.lean`
(which packages the Fisher form as a Mathlib `InnerProductSpace` on the tangent
hyperplane `FisherTangent p` of the open simplex).

A *row stochastic matrix* `K : ι → κ → ℝ` is a Markov kernel between finite
sample spaces.  It acts on measures by push-forward,
`pushforward K v j = ∑ i, v i * K i j`.  The main result is the finite Chentsov
(data-processing) inequality

`fisherForm (K∗p) (K∗v) (K∗v) ≤ fisherForm p v v`,

proved by Cauchy--Schwarz (Engel form) column by column.  Consequences recorded
here:

* `chiSquared_pushforward_le` — data processing for Pearson's `χ²`;
* `pushforwardTangent` — the induced linear map of Fisher tangent spaces, and
  `norm_pushforwardTangent_le`, saying it is a contraction for the Fisher inner
  product norms, i.e. push-forward is `1`-Lipschitz in the Fisher geometry;
* `fisherForm_pushforward_eq_iff` and `fisherForm_pushforward_eq_iff_exists_score`
  — the equality case: the Fisher form is preserved exactly when the channel is
  sufficient for the direction `v`, i.e. the score `v i / p i` is constant on
  the support of each column;
* `fisherForm_pushforward_of_injective` — equality for deterministic injective
  (i.e. lossless) channels;
* `fisherForm_pushforward_lt_merge` — an explicit two-point channel for which
  the inequality is strict, so the hypothesis-free converse fails;
* `log_sum_inequality` and `klDiv_pushforward_le` — the log-sum inequality and
  the resulting data-processing inequality for relative entropy, the global
  counterpart of the infinitesimal Chentsov bound.
-/

noncomputable section

open Finset

namespace InformationGeometry

variable {ι κ : Type*} [Fintype ι] [Fintype κ]

/-! ## Row stochastic matrices and push-forward -/

/-- A row stochastic matrix (a Markov kernel between finite sample spaces). -/
structure RowStochastic (ι κ : Type*) [Fintype ι] [Fintype κ] where
  /-- The transition matrix. -/
  mat : ι → κ → ℝ
  /-- Transition probabilities are nonnegative. -/
  mat_nonneg : ∀ i j, 0 ≤ mat i j
  /-- Each row is a probability vector. -/
  row_sum : ∀ i, ∑ j, mat i j = 1

/-- Push-forward of a (signed) measure along a stochastic matrix. -/
def pushforward (K : RowStochastic ι κ) (v : ι → ℝ) : κ → ℝ :=
  fun j => ∑ i, v i * K.mat i j

@[simp] theorem pushforward_apply (K : RowStochastic ι κ) (v : ι → ℝ) (j : κ) :
    pushforward K v j = ∑ i, v i * K.mat i j := rfl

theorem pushforward_add (K : RowStochastic ι κ) (v w : ι → ℝ) :
    pushforward K (v + w) = pushforward K v + pushforward K w := by
  funext j
  simp [pushforward, add_mul, Finset.sum_add_distrib]

theorem pushforward_smul (K : RowStochastic ι κ) (c : ℝ) (v : ι → ℝ) :
    pushforward K (c • v) = c • pushforward K v := by
  funext j
  simp [pushforward, mul_assoc, Finset.mul_sum]

theorem pushforward_sub (K : RowStochastic ι κ) (v w : ι → ℝ) :
    pushforward K (v - w) = pushforward K v - pushforward K w := by
  funext j
  simp [pushforward, sub_mul, Finset.sum_sub_distrib]

/-- Push-forward preserves total mass. -/
theorem sum_pushforward (K : RowStochastic ι κ) (v : ι → ℝ) :
    ∑ j, pushforward K v j = ∑ i, v i := by
  simp only [pushforward]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [← Finset.mul_sum, K.row_sum i, mul_one]

/-- Push-forward preserves nonnegativity. -/
theorem pushforward_nonneg (K : RowStochastic ι κ) {v : ι → ℝ} (hv : ∀ i, 0 ≤ v i)
    (j : κ) : 0 ≤ pushforward K v j :=
  Finset.sum_nonneg fun i _ => mul_nonneg (hv i) (K.mat_nonneg i j)

/-! ## The Chentsov (data-processing) inequality for the Fisher form -/

/-- Column-wise Cauchy--Schwarz: the `j`-th term of the pushed-forward Fisher
form is dominated by the `K`-average of the original ones. -/
theorem fisher_column_bound (K : RowStochastic ι κ) (p v : ι → ℝ)
    (hp : ∀ i, 0 < p i) (j : κ) :
    pushforward K v j * pushforward K v j / pushforward K p j
      ≤ ∑ i, v i * v i / p i * K.mat i j := by
  classical
  set S : Finset ι := {i | 0 < K.mat i j} with hS
  have hzero : ∀ i ∈ (Finset.univ : Finset ι), i ∉ S → K.mat i j = 0 := by
    intro i _ hi
    have : ¬ 0 < K.mat i j := by simpa [hS] using hi
    exact le_antisymm (not_lt.mp this) (K.mat_nonneg i j)
  have hv : pushforward K v j = ∑ i ∈ S, v i * K.mat i j := by
    rw [pushforward_apply]
    refine (Finset.sum_subset (Finset.subset_univ S) ?_).symm
    intro i hi hiS
    rw [hzero i hi hiS, mul_zero]
  have hpj : pushforward K p j = ∑ i ∈ S, p i * K.mat i j := by
    rw [pushforward_apply]
    refine (Finset.sum_subset (Finset.subset_univ S) ?_).symm
    intro i hi hiS
    rw [hzero i hi hiS, mul_zero]
  have hgpos : ∀ i ∈ S, 0 < p i * K.mat i j := by
    intro i hi
    have : 0 < K.mat i j := by simpa [hS] using hi
    exact mul_pos (hp i) this
  have hCS := Finset.sq_sum_div_le_sum_sq_div S (fun i => v i * K.mat i j) hgpos
  have hrewrite : ∀ i ∈ S, (v i * K.mat i j) ^ 2 / (p i * K.mat i j)
      = v i * v i / p i * K.mat i j := by
    intro i hi
    have hK : 0 < K.mat i j := by simpa [hS] using hi
    field_simp
  rw [Finset.sum_congr rfl hrewrite] at hCS
  have hle : ∑ i ∈ S, v i * v i / p i * K.mat i j
      ≤ ∑ i, v i * v i / p i * K.mat i j := by
    refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S) ?_
    intro i _ _
    exact mul_nonneg (div_nonneg (mul_self_nonneg _) (hp i).le) (K.mat_nonneg i j)
  calc pushforward K v j * pushforward K v j / pushforward K p j
      = (∑ i ∈ S, v i * K.mat i j) ^ 2 / ∑ i ∈ S, p i * K.mat i j := by
        rw [hv, hpj, sq]
    _ ≤ ∑ i ∈ S, v i * v i / p i * K.mat i j := hCS
    _ ≤ ∑ i, v i * v i / p i * K.mat i j := hle

/-- **Chentsov monotonicity / data processing for the Fisher form.**  Coarse
graining along a stochastic matrix can only decrease Fisher squared length. -/
theorem fisherForm_pushforward_le (K : RowStochastic ι κ) (p v : ι → ℝ)
    (hp : ∀ i, 0 < p i) :
    fisherForm (pushforward K p) (pushforward K v) (pushforward K v)
      ≤ fisherForm p v v := by
  have h1 : fisherForm (pushforward K p) (pushforward K v) (pushforward K v)
      ≤ ∑ j, ∑ i, v i * v i / p i * K.mat i j :=
    Finset.sum_le_sum fun j _ => fisher_column_bound K p v hp j
  refine h1.trans_eq ?_
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [← Finset.mul_sum, K.row_sum i, mul_one]

/-- **Data processing for Pearson's chi-squared divergence.** -/
theorem chiSquared_pushforward_le (K : RowStochastic ι κ) (p q : ι → ℝ)
    (hq : ∀ i, 0 < q i) :
    chiSquared (pushforward K p) (pushforward K q) ≤ chiSquared p q := by
  rw [chiSquared_eq_fisher, chiSquared_eq_fisher, ← pushforward_sub]
  exact fisherForm_pushforward_le K q (p - q) hq

/-! ## The equality case: sufficiency of the channel -/

omit [Fintype ι] [Fintype κ] in
/-- **Equality case of the Engel (Cauchy--Schwarz) form.**  For strictly
positive `g`, `(∑ f)²/(∑ g) = ∑ fᵢ²/gᵢ` exactly when `f` is a constant multiple
of `g` on `s`. -/
theorem sq_sum_div_eq_iff (s : Finset ι) (f g : ι → ℝ) (hg : ∀ i ∈ s, 0 < g i) :
    (∑ i ∈ s, f i) ^ 2 / (∑ i ∈ s, g i) = ∑ i ∈ s, f i ^ 2 / g i ↔
      ∃ c : ℝ, ∀ i ∈ s, f i = c * g i := by
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp
  have hG : 0 < ∑ i ∈ s, g i := Finset.sum_pos hg hs
  set G := ∑ i ∈ s, g i with hGdef
  set M := (∑ i ∈ s, f i) / G with hMdef
  have hexp : ∀ i ∈ s, g i * (f i / g i - M) ^ 2
      = f i ^ 2 / g i - 2 * M * f i + M ^ 2 * g i := by
    intro i hi
    have hgi := (hg i hi).ne'
    field_simp
    ring
  have hsum : ∑ i ∈ s, g i * (f i / g i - M) ^ 2
      = (∑ i ∈ s, f i ^ 2 / g i) - (∑ i ∈ s, f i) ^ 2 / G := by
    rw [Finset.sum_congr rfl hexp, Finset.sum_add_distrib, Finset.sum_sub_distrib,
      ← Finset.mul_sum, ← Finset.mul_sum, ← hGdef, hMdef]
    field_simp
    ring
  constructor
  · intro h
    have hz : ∑ i ∈ s, g i * (f i / g i - M) ^ 2 = 0 := by rw [hsum, ← h]; ring
    have hterm := (Finset.sum_eq_zero_iff_of_nonneg
      (fun i hi => mul_nonneg (hg i hi).le (sq_nonneg _))).mp hz
    refine ⟨M, fun i hi => ?_⟩
    rcases mul_eq_zero.mp (hterm i hi) with h0 | h0
    · exact absurd h0 (hg i hi).ne'
    · have hzz : f i / g i - M = 0 := by
        simpa using pow_eq_zero_iff (n := 2) (by norm_num) |>.mp h0
      have hgi := (hg i hi).ne'
      field_simp at hzz
      linarith [hzz]
  · rintro ⟨c, hc⟩
    have hM : M = c := by
      rw [hMdef, Finset.sum_congr rfl hc, ← Finset.mul_sum, ← hGdef]
      field_simp
    have hz : ∑ i ∈ s, g i * (f i / g i - M) ^ 2 = 0 := by
      refine Finset.sum_eq_zero fun i hi => ?_
      have hgi := (hg i hi).ne'
      rw [hc i hi, hM]
      field_simp
      ring
    rw [hsum] at hz
    linarith

/-- Equality in the column-wise bound `fisher_column_bound` holds exactly when
the score `v i / p i` is constant on the support of the `j`-th column. -/
theorem fisher_column_eq_iff (K : RowStochastic ι κ) (p v : ι → ℝ)
    (hp : ∀ i, 0 < p i) (j : κ) :
    pushforward K v j * pushforward K v j / pushforward K p j
        = ∑ i, v i * v i / p i * K.mat i j
      ↔ ∃ c : ℝ, ∀ i, 0 < K.mat i j → v i = c * p i := by
  classical
  set S : Finset ι := {i | 0 < K.mat i j} with hS
  have hmemS : ∀ i, i ∈ S ↔ 0 < K.mat i j := by
    intro i; simp [hS]
  have hzero : ∀ i ∈ (Finset.univ : Finset ι), i ∉ S → K.mat i j = 0 := by
    intro i _ hi
    have hni : ¬ 0 < K.mat i j := fun h => hi ((hmemS i).mpr h)
    exact le_antisymm (not_lt.mp hni) (K.mat_nonneg i j)
  have hv : pushforward K v j = ∑ i ∈ S, v i * K.mat i j := by
    rw [pushforward_apply]
    refine (Finset.sum_subset (Finset.subset_univ S) ?_).symm
    intro i hi hiS
    rw [hzero i hi hiS, mul_zero]
  have hpj : pushforward K p j = ∑ i ∈ S, p i * K.mat i j := by
    rw [pushforward_apply]
    refine (Finset.sum_subset (Finset.subset_univ S) ?_).symm
    intro i hi hiS
    rw [hzero i hi hiS, mul_zero]
  have hgpos : ∀ i ∈ S, 0 < p i * K.mat i j := fun i hi =>
    mul_pos (hp i) ((hmemS i).mp hi)
  have hR : ∑ i, v i * v i / p i * K.mat i j
      = ∑ i ∈ S, (v i * K.mat i j) ^ 2 / (p i * K.mat i j) := by
    refine (Finset.sum_subset (Finset.subset_univ S) ?_).symm.trans ?_
    · intro i hi hiS
      rw [hzero i hi hiS, mul_zero]
    · refine Finset.sum_congr rfl fun i hi => ?_
      have hK := (hmemS i).mp hi
      field_simp
  rw [hv, hpj, hR, ← sq, sq_sum_div_eq_iff S _ _ hgpos]
  constructor
  · rintro ⟨c, hc⟩
    refine ⟨c, fun i hi => ?_⟩
    have h := hc i ((hmemS i).mpr hi)
    have h' : v i * K.mat i j = c * p i * K.mat i j := by rw [h]; ring
    exact mul_right_cancel₀ (ne_of_gt hi) h'
  · rintro ⟨c, hc⟩
    refine ⟨c, fun i hi => ?_⟩
    rw [hc i ((hmemS i).mp hi)]
    ring

/-- **The equality case of Chentsov monotonicity.**  Push-forward preserves the
Fisher squared length of `v` at `p` exactly when, for each output symbol `j`,
the score `v i / p i` is constant over the inputs `i` that can produce `j`; that
is, exactly when the channel is sufficient for the direction `v`. -/
theorem fisherForm_pushforward_eq_iff (K : RowStochastic ι κ) (p v : ι → ℝ)
    (hp : ∀ i, 0 < p i) :
    fisherForm (pushforward K p) (pushforward K v) (pushforward K v) = fisherForm p v v
      ↔ ∀ j : κ, ∃ c : ℝ, ∀ i, 0 < K.mat i j → v i = c * p i := by
  have hsum : ∑ j : κ, ∑ i, v i * v i / p i * K.mat i j = fisherForm p v v := by
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [← Finset.mul_sum, K.row_sum i, mul_one]
  have hle : ∀ j ∈ (Finset.univ : Finset κ),
      pushforward K v j * pushforward K v j / pushforward K p j
        ≤ ∑ i, v i * v i / p i * K.mat i j :=
    fun j _ => fisher_column_bound K p v hp j
  constructor
  · intro h
    have heq : ∑ j : κ, pushforward K v j * pushforward K v j / pushforward K p j
        = ∑ j : κ, ∑ i, v i * v i / p i * K.mat i j := by
      rw [hsum]
      exact h
    intro j
    exact (fisher_column_eq_iff K p v hp j).mp
      ((Finset.sum_eq_sum_iff_of_le hle).mp heq j (Finset.mem_univ j))
  · intro h
    have hcols : ∀ j : κ, pushforward K v j * pushforward K v j / pushforward K p j
        = ∑ i, v i * v i / p i * K.mat i j :=
      fun j => (fisher_column_eq_iff K p v hp j).mpr (h j)
    calc fisherForm (pushforward K p) (pushforward K v) (pushforward K v)
        = ∑ j : κ, ∑ i, v i * v i / p i * K.mat i j :=
          Finset.sum_congr rfl fun j _ => hcols j
      _ = fisherForm p v v := hsum

/-- The equality case of Chentsov monotonicity, with the per-column constants
collected into a single function `c : κ → ℝ` (the posterior score). -/
theorem fisherForm_pushforward_eq_iff_exists_score (K : RowStochastic ι κ) (p v : ι → ℝ)
    (hp : ∀ i, 0 < p i) :
    fisherForm (pushforward K p) (pushforward K v) (pushforward K v) = fisherForm p v v
      ↔ ∃ c : κ → ℝ, ∀ i j, 0 < K.mat i j → v i = c j * p i := by
  rw [fisherForm_pushforward_eq_iff K p v hp]
  constructor
  · intro h
    exact ⟨fun j => (h j).choose, fun i j hij => (h j).choose_spec i hij⟩
  · rintro ⟨c, hc⟩ j
    exact ⟨c j, fun i hij => hc i j hij⟩

/-! ## Push-forward as a contraction of Fisher tangent spaces -/

/-- If every column of `K` receives some mass, the push-forward of a point of the
open simplex is again a point of the open simplex. -/
def pushforwardSimplex (K : RowStochastic ι κ) (p : OpenSimplex ι)
    (hcol : ∀ j, ∃ i, 0 < K.mat i j) : OpenSimplex κ where
  prob := pushforward K p.prob
  prob_pos := by
    intro j
    obtain ⟨i, hi⟩ := hcol j
    refine Finset.sum_pos' (fun k _ => mul_nonneg (p.prob_pos k).le (K.mat_nonneg k j))
      ⟨i, Finset.mem_univ i, mul_pos (p.prob_pos i) hi⟩
  prob_sum := by rw [sum_pushforward, p.prob_sum]

@[simp] theorem pushforwardSimplex_prob (K : RowStochastic ι κ) (p : OpenSimplex ι)
    (hcol : ∀ j, ∃ i, 0 < K.mat i j) :
    (pushforwardSimplex K p hcol).prob = pushforward K p.prob := rfl

/-- The induced map on Fisher tangent spaces. -/
def pushforwardTangent (K : RowStochastic ι κ) (p : OpenSimplex ι)
    (hcol : ∀ j, ∃ i, 0 < K.mat i j) (v : FisherTangent p) :
    FisherTangent (pushforwardSimplex K p hcol) :=
  ⟨pushforward K v.vec, by
    show ∑ j, pushforward K v.vec j = 0
    rw [sum_pushforward]
    exact v.2⟩

@[simp] theorem vec_pushforwardTangent (K : RowStochastic ι κ) (p : OpenSimplex ι)
    (hcol : ∀ j, ∃ i, 0 < K.mat i j) (v : FisherTangent p) :
    (pushforwardTangent K p hcol v).vec = pushforward K v.vec := rfl

theorem pushforwardTangent_add (K : RowStochastic ι κ) (p : OpenSimplex ι)
    (hcol : ∀ j, ∃ i, 0 < K.mat i j) (v w : FisherTangent p) :
    pushforwardTangent K p hcol (v + w)
      = pushforwardTangent K p hcol v + pushforwardTangent K p hcol w :=
  FisherTangent.ext (by simp [pushforward_add])

theorem pushforwardTangent_smul (K : RowStochastic ι κ) (p : OpenSimplex ι)
    (hcol : ∀ j, ∃ i, 0 < K.mat i j) (c : ℝ) (v : FisherTangent p) :
    pushforwardTangent K p hcol (c • v) = c • pushforwardTangent K p hcol v :=
  FisherTangent.ext (by simp [pushforward_smul])

/-- Push-forward along a stochastic matrix, viewed as a map of Fisher tangent
spaces, is a linear map. -/
def pushforwardTangentₗ (K : RowStochastic ι κ) (p : OpenSimplex ι)
    (hcol : ∀ j, ∃ i, 0 < K.mat i j) :
    FisherTangent p →ₗ[ℝ] FisherTangent (pushforwardSimplex K p hcol) where
  toFun := pushforwardTangent K p hcol
  map_add' := pushforwardTangent_add K p hcol
  map_smul' := pushforwardTangent_smul K p hcol

/-- **Push-forward is a contraction for the Fisher inner-product norms.**  This
is the Chentsov inequality expressed inside the `InnerProductSpace` packaging. -/
theorem norm_pushforwardTangent_le (K : RowStochastic ι κ) (p : OpenSimplex ι)
    (hcol : ∀ j, ∃ i, 0 < K.mat i j) (v : FisherTangent p) :
    ‖pushforwardTangent K p hcol v‖ ≤ ‖v‖ := by
  have h := fisherForm_pushforward_le K p.prob v.vec p.prob_pos
  have hsq : ‖pushforwardTangent K p hcol v‖ ^ 2 ≤ ‖v‖ ^ 2 := by
    rw [norm_sq_fisherTangent, norm_sq_fisherTangent]
    simpa using h
  nlinarith [norm_nonneg (pushforwardTangent K p hcol v), norm_nonneg v]

/-! ## Sharpness: equality for lossless channels, strictness for merging -/

/-- The deterministic channel attached to a function `f : ι → κ`. -/
def detChannel [DecidableEq κ] (f : ι → κ) : RowStochastic ι κ where
  mat i j := if f i = j then 1 else 0
  mat_nonneg i j := by split <;> norm_num
  row_sum i := by simp

@[simp] theorem pushforward_detChannel [DecidableEq κ] (f : ι → κ) (v : ι → ℝ) (j : κ) :
    pushforward (detChannel f) v j = ∑ i ∈ {i | f i = j}, v i := by
  classical
  rw [pushforward_apply]
  rw [Finset.sum_filter]
  refine Finset.sum_congr rfl fun i _ => ?_
  by_cases h : f i = j <;> simp [detChannel, h]

/-- **Lossless channels preserve the Fisher form.**  For an injective
deterministic channel the data-processing inequality is an equality. -/
theorem fisherForm_pushforward_of_injective [DecidableEq κ] (f : ι → κ)
    (hf : Function.Injective f) (p v : ι → ℝ) :
    fisherForm (pushforward (detChannel f) p) (pushforward (detChannel f) v)
        (pushforward (detChannel f) v) = fisherForm p v v := by
  classical
  have hfib : ∀ j : κ, ∀ u : ι → ℝ,
      pushforward (detChannel f) u j = if h : ∃ i, f i = j then u h.choose else 0 := by
    intro j u
    rw [pushforward_detChannel]
    by_cases h : ∃ i, f i = j
    · have hmem : ({i | f i = j} : Finset ι) = {h.choose} := by
        ext i
        simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
        constructor
        · intro hi; exact hf (hi.trans h.choose_spec.symm)
        · rintro rfl; exact h.choose_spec
      rw [hmem, dif_pos h, Finset.sum_singleton]
    · have hmem : ({i | f i = j} : Finset ι) = ∅ := by
        ext i
        simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.notMem_empty,
          iff_false]
        exact fun hi => h ⟨i, hi⟩
      rw [hmem, dif_neg h, Finset.sum_empty]
  have key : fisherForm (pushforward (detChannel f) p) (pushforward (detChannel f) v)
      (pushforward (detChannel f) v)
      = ∑ j : κ, if h : ∃ i, f i = j then v h.choose * v h.choose / p h.choose else 0 := by
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [hfib j p, hfib j v]
    by_cases h : ∃ i, f i = j <;> simp [h]
  rw [key, fisherForm]
  have himg : ∑ j ∈ Finset.univ.image f,
      (if h : ∃ i, f i = j then v h.choose * v h.choose / p h.choose else 0)
      = ∑ i, v i * v i / p i := by
    rw [Finset.sum_image (fun x _ y _ h => hf h)]
    refine Finset.sum_congr rfl fun i _ => ?_
    have h : ∃ k, f k = f i := ⟨i, rfl⟩
    have hk : h.choose = i := hf h.choose_spec
    rw [dif_pos h, hk]
  rw [← himg]
  refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
  intro j _ hj
  have h : ¬ ∃ i, f i = j := by
    rintro ⟨i, rfl⟩
    exact hj (Finset.mem_image_of_mem f (Finset.mem_univ i))
  rw [dif_neg h]

/-- **Strictness.**  The channel merging two symbols into one destroys all Fisher
information in the difference direction, so the data-processing inequality is
strict in general. -/
theorem fisherForm_pushforward_lt_merge :
    fisherForm (pushforward (detChannel (fun _ : Fin 2 => (0 : Fin 1)))
        (fun _ => (1 : ℝ) / 2))
      (pushforward (detChannel (fun _ : Fin 2 => (0 : Fin 1))) ![1, -1])
      (pushforward (detChannel (fun _ : Fin 2 => (0 : Fin 1))) ![1, -1])
    < fisherForm (fun _ : Fin 2 => (1 : ℝ) / 2) ![1, -1] ![1, -1] := by
  have hl : pushforward (detChannel (fun _ : Fin 2 => (0 : Fin 1))) ![1, -1] = fun _ => 0 := by
    funext j
    fin_cases j
    simp [pushforward, detChannel, Fin.sum_univ_two]
  rw [hl]
  simp [fisherForm, Fin.sum_univ_two]

/-! ## Data processing for relative entropy -/

omit [Fintype ι] in
/-- **The log-sum inequality.**  For nonnegative `a` and strictly positive `b`,
`(∑ a) log((∑ a)/(∑ b)) ≤ ∑ aᵢ log(aᵢ/bᵢ)`. -/
theorem log_sum_inequality (s : Finset ι) (a b : ι → ℝ)
    (ha : ∀ i ∈ s, 0 ≤ a i) (hb : ∀ i ∈ s, 0 < b i) :
    (∑ i ∈ s, a i) * Real.log ((∑ i ∈ s, a i) / ∑ i ∈ s, b i)
      ≤ ∑ i ∈ s, a i * Real.log (a i / b i) := by
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp
  set A := ∑ i ∈ s, a i with hAdef
  set B := ∑ i ∈ s, b i with hBdef
  have hA0 : 0 ≤ A := Finset.sum_nonneg ha
  have hB0 : 0 < B := Finset.sum_pos hb hs
  have key : ∀ i ∈ s, a i * Real.log (A / B) + (a i - A * b i / B)
      ≤ a i * Real.log (a i / b i) := by
    intro i hi
    have hbi := hb i hi
    rcases eq_or_lt_of_le (ha i hi) with hai | hai
    · have hnn : 0 ≤ A * b i / B := div_nonneg (mul_nonneg hA0 hbi.le) hB0.le
      rw [← hai]
      simp only [zero_mul, zero_sub, zero_add]
      linarith
    · have hApos : 0 < A := lt_of_lt_of_le hai (Finset.single_le_sum ha hi)
      set t : ℝ := a i * B / (b i * A) with htdef
      have htpos : 0 < t := div_pos (mul_pos hai hB0) (mul_pos hbi hApos)
      have hlogt : Real.log (a i / b i) - Real.log (A / B) = Real.log t := by
        rw [Real.log_div (ne_of_gt hai) (ne_of_gt hbi),
          Real.log_div (ne_of_gt hApos) (ne_of_gt hB0), htdef,
          Real.log_div (by positivity) (by positivity),
          Real.log_mul (ne_of_gt hai) (ne_of_gt hB0),
          Real.log_mul (ne_of_gt hbi) (ne_of_gt hApos)]
        ring
      have hlb : 1 - 1 / t ≤ Real.log t := by
        have h := Real.log_le_sub_one_of_pos (x := 1 / t) (by positivity)
        rw [one_div, Real.log_inv] at h
        rw [one_div]
        linarith
      have hmul : a i * (1 - 1 / t) ≤ a i * Real.log t :=
        mul_le_mul_of_nonneg_left hlb hai.le
      have hcalc : a i * (1 - 1 / t) = a i - A * b i / B := by
        rw [htdef]
        field_simp
      have hfin : a i - A * b i / B ≤ a i * (Real.log (a i / b i) - Real.log (A / B)) := by
        rw [hlogt, ← hcalc]
        exact hmul
      nlinarith [hfin]
  have hsum := Finset.sum_le_sum key
  have hleft : ∑ i ∈ s, (a i * Real.log (A / B) + (a i - A * b i / B))
      = A * Real.log (A / B) := by
    rw [Finset.sum_add_distrib, ← Finset.sum_mul, Finset.sum_sub_distrib, ← hAdef]
    have hab : ∑ i ∈ s, A * b i / B = A := by
      rw [← Finset.sum_div, ← Finset.mul_sum, ← hBdef]
      field_simp
    rw [hab]
    ring
  rw [hleft] at hsum
  exact hsum

/-- **Data processing for the Kullback--Leibler divergence.**  Coarse graining
along a stochastic matrix can only decrease relative entropy. -/
theorem klDiv_pushforward_le (K : RowStochastic ι κ) (p q : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 < q i) :
    klDiv (pushforward K p) (pushforward K q) ≤ klDiv p q := by
  classical
  have hcol : ∀ j : κ,
      pushforward K p j * Real.log (pushforward K p j / pushforward K q j)
        ≤ ∑ i, p i * Real.log (p i / q i) * K.mat i j := by
    intro j
    set S : Finset ι := {i | 0 < K.mat i j} with hS
    have hzero : ∀ i ∈ (Finset.univ : Finset ι), i ∉ S → K.mat i j = 0 := by
      intro i _ hi
      have hni : ¬ 0 < K.mat i j := by simpa [hS] using hi
      exact le_antisymm (not_lt.mp hni) (K.mat_nonneg i j)
    have hpj : pushforward K p j = ∑ i ∈ S, p i * K.mat i j := by
      rw [pushforward_apply]
      refine (Finset.sum_subset (Finset.subset_univ S) ?_).symm
      intro i hi hiS
      rw [hzero i hi hiS, mul_zero]
    have hqj : pushforward K q j = ∑ i ∈ S, q i * K.mat i j := by
      rw [pushforward_apply]
      refine (Finset.sum_subset (Finset.subset_univ S) ?_).symm
      intro i hi hiS
      rw [hzero i hi hiS, mul_zero]
    have hls := log_sum_inequality S (fun i => p i * K.mat i j) (fun i => q i * K.mat i j)
      (fun i _ => mul_nonneg (hp i) (K.mat_nonneg i j))
      (fun i hi => mul_pos (hq i) (by simpa [hS] using hi))
    have hterm : ∀ i ∈ S, p i * K.mat i j * Real.log (p i * K.mat i j / (q i * K.mat i j))
        = p i * Real.log (p i / q i) * K.mat i j := by
      intro i hi
      have hK : 0 < K.mat i j := by simpa [hS] using hi
      rw [mul_div_mul_right _ _ (ne_of_gt hK)]
      ring
    rw [Finset.sum_congr rfl hterm] at hls
    have hext : ∑ i ∈ S, p i * Real.log (p i / q i) * K.mat i j
        = ∑ i, p i * Real.log (p i / q i) * K.mat i j := by
      refine Finset.sum_subset (Finset.subset_univ S) ?_
      intro i hi hiS
      rw [hzero i hi hiS, mul_zero]
    rw [hext] at hls
    rw [hpj, hqj]
    exact hls
  have h1 : klDiv (pushforward K p) (pushforward K q)
      ≤ ∑ j, ∑ i, p i * Real.log (p i / q i) * K.mat i j :=
    Finset.sum_le_sum fun j _ => hcol j
  refine h1.trans_eq ?_
  rw [Finset.sum_comm, klDiv]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [← Finset.mul_sum, K.row_sum i, mul_one]

end InformationGeometry