import Mathlib
import Physics.WilsonEpsilonExpansion

/-!
# Perturbation theory on theory-space: the wrongness series

This file sets up the analytic core of the "unreasonable effectiveness of wrong
theories" programme.  The objects are *theories*: assignments of a real-valued
prediction to each phenomenon.  A *perturbative family* of theories is a
one-parameter deformation

`predict T ε p = truth p + ∑' n, coeff n p * ε ^ (n + 1)`

of the (generally unknowable) true prediction function.  The **wrongness** of a
theory at coupling `ε` is the difference `predict T ε p - truth p`, i.e. exactly
the tail of the perturbative series.

Main results:

* `WrongTheory.summable_wrongTerm` — geometric domination makes the wrongness
  series absolutely convergent inside the disc `ratio * |ε| < 1`;
* `WrongTheory.abs_wrongness_le` — a quantitative Cauchy-type bound
  `|W ε p| ≤ bound * |ε| / (1 - ratio * |ε|)`, uniform in the phenomenon `p`;
* `WrongTheory.wrongness_small` / `wrongness_tendsto_zero` — the wrongness series
  converges to truth as the coupling is switched off, uniformly over phenomena;
* `WrongTheory.truncation_isOrder` — the wrongness of the `N`-th order truncated
  theory is `O(ε^(N+1))` at zero, generalising `WilsonEpsilon.IsOrderThreeAtZero`
  from the catalog (see `WrongTheory.isOrderThreeAtZero_iff`).
-/

namespace WrongTheory

/-- A **theory** on a space of phenomena `Φ` is a real-valued prediction for
each phenomenon. -/
abbrev Theory (Φ : Type*) := Φ → ℝ

/-- A **perturbative family of theories** over the phenomenon space `Φ`:
a true prediction function together with correction coefficients satisfying a
uniform geometric (Cauchy-estimate) bound.  This is the theory-space analogue of
a germ of an analytic function, with the phenomenon `p` as a spectator
parameter. -/
structure Perturbative (Φ : Type*) where
  /-- The (in general unknowable) exact prediction. -/
  truth : Φ → ℝ
  /-- `coeff n p` is the coefficient of `ε ^ (n+1)` in the wrongness series. -/
  coeff : ℕ → Φ → ℝ
  /-- Uniform Cauchy bound constant. -/
  bound : ℝ
  /-- Uniform Cauchy bound ratio (inverse radius of convergence). -/
  ratio : ℝ
  bound_nonneg : 0 ≤ bound
  ratio_nonneg : 0 ≤ ratio
  coeff_le : ∀ n p, |coeff n p| ≤ bound * ratio ^ n

variable {Φ : Type*}

/-- The `n`-th term of the wrongness series. -/
noncomputable def wrongTerm (T : Perturbative Φ) (ε : ℝ) (p : Φ) (n : ℕ) : ℝ :=
  T.coeff n p * ε ^ (n + 1)

/-- The **wrongness** of the theory at coupling `ε`: the total perturbative
correction to the truth. -/
noncomputable def wrongness (T : Perturbative Φ) (ε : ℝ) (p : Φ) : ℝ :=
  ∑' n, wrongTerm T ε p n

/-- The prediction made by the deformed theory. -/
noncomputable def predict (T : Perturbative Φ) (ε : ℝ) (p : Φ) : ℝ :=
  T.truth p + wrongness T ε p

/-- The `N`-th order truncation of the theory: a *deliberately wrong* theory
that keeps only finitely many corrections. -/
noncomputable def truncate (T : Perturbative Φ) (N : ℕ) (ε : ℝ) (p : Φ) : ℝ :=
  T.truth p + ∑ n ∈ Finset.range N, wrongTerm T ε p n

@[simp] lemma predict_sub_truth (T : Perturbative Φ) (ε : ℝ) (p : Φ) :
    predict T ε p - T.truth p = wrongness T ε p := by
  simp [predict]

/-- Termwise geometric domination of the wrongness series. -/
lemma abs_wrongTerm_le (T : Perturbative Φ) (ε : ℝ) (p : Φ) (n : ℕ) :
    |wrongTerm T ε p n| ≤ (T.bound * |ε|) * (T.ratio * |ε|) ^ n := by
  have h1 : |wrongTerm T ε p n| = |T.coeff n p| * |ε| ^ (n + 1) := by
    simp [wrongTerm, abs_mul, abs_pow]
  have h2 : |T.coeff n p| * |ε| ^ (n + 1) ≤ (T.bound * T.ratio ^ n) * |ε| ^ (n + 1) := by
    apply mul_le_mul_of_nonneg_right (T.coeff_le n p)
    positivity
  refine h1 ▸ h2.trans (le_of_eq ?_)
  rw [mul_pow]
  ring

/-- Inside the disc of convergence the wrongness series converges absolutely. -/
lemma summable_wrongTerm (T : Perturbative Φ) (ε : ℝ) (p : Φ)
    (h : T.ratio * |ε| < 1) : Summable (wrongTerm T ε p) := by
  have hq : 0 ≤ T.ratio * |ε| := mul_nonneg T.ratio_nonneg (abs_nonneg ε)
  refine Summable.of_norm_bounded
    ((summable_geometric_of_lt_one hq h).mul_left (T.bound * |ε|)) ?_
  intro n
  simpa [Real.norm_eq_abs] using abs_wrongTerm_le T ε p n

lemma summable_abs_wrongTerm (T : Perturbative Φ) (ε : ℝ) (p : Φ)
    (h : T.ratio * |ε| < 1) : Summable (fun n => |wrongTerm T ε p n|) := by
  have hq : 0 ≤ T.ratio * |ε| := mul_nonneg T.ratio_nonneg (abs_nonneg ε)
  exact Summable.of_nonneg_of_le (fun n => abs_nonneg _) (abs_wrongTerm_le T ε p)
    ((summable_geometric_of_lt_one hq h).mul_left (T.bound * |ε|))

/-- **Quantitative convergence of wrongness.**  A Cauchy-type estimate for the
total error of a perturbative theory, uniform in the phenomenon. -/
theorem abs_wrongness_le (T : Perturbative Φ) (ε : ℝ) (p : Φ)
    (h : T.ratio * |ε| < 1) :
    |wrongness T ε p| ≤ (T.bound * |ε|) / (1 - T.ratio * |ε|) := by
  have hq : 0 ≤ T.ratio * |ε| := mul_nonneg T.ratio_nonneg (abs_nonneg ε)
  have hstep : |wrongness T ε p| ≤ ∑' n, |wrongTerm T ε p n| := by
    simpa [wrongness, Real.norm_eq_abs] using
      norm_tsum_le_tsum_norm (f := wrongTerm T ε p)
        (by simpa [Real.norm_eq_abs] using summable_abs_wrongTerm T ε p h)
  refine hstep.trans ?_
  have hle : ∑' n, |wrongTerm T ε p n| ≤ ∑' n, (T.bound * |ε|) * (T.ratio * |ε|) ^ n :=
    Summable.tsum_le_tsum (abs_wrongTerm_le T ε p) (summable_abs_wrongTerm T ε p h)
      ((summable_geometric_of_lt_one hq h).mul_left _)
  refine hle.trans (le_of_eq ?_)
  rw [tsum_mul_left, tsum_geometric_of_lt_one hq h]
  field_simp

/-- **The wrongness series converges to truth.**  For every tolerance `η > 0`
there is a coupling window inside which *every* prediction of the perturbative
theory is within `η` of the truth, simultaneously for all phenomena. -/
theorem wrongness_small (T : Perturbative Φ) {η : ℝ} (hη : 0 < η) :
    ∃ δ > 0, ∀ ε : ℝ, |ε| < δ → ∀ p : Φ, |wrongness T ε p| < η := by
  have hb : 0 < T.bound + 1 := by linarith [T.bound_nonneg]
  have hr : 0 < T.ratio + 1 := by linarith [T.ratio_nonneg]
  set δ : ℝ := min (1 / (2 * (T.ratio + 1))) (η / (2 * (T.bound + 1))) with hδ
  have hδpos : 0 < δ := lt_min (by positivity) (by positivity)
  refine ⟨δ, hδpos, ?_⟩
  intro ε hε p
  have hεabs : 0 ≤ |ε| := abs_nonneg ε
  have h1 : |ε| < 1 / (2 * (T.ratio + 1)) := lt_of_lt_of_le hε (min_le_left _ _)
  have h2 : |ε| < η / (2 * (T.bound + 1)) := lt_of_lt_of_le hε (min_le_right _ _)
  have hq : T.ratio * |ε| ≤ 1 / 2 := by
    have hA : T.ratio * |ε| ≤ (T.ratio + 1) * |ε| := by nlinarith [T.ratio_nonneg]
    have h3 : (T.ratio + 1) * |ε| < (T.ratio + 1) * (1 / (2 * (T.ratio + 1))) :=
      mul_lt_mul_of_pos_left h1 hr
    have h4 : (T.ratio + 1) * (1 / (2 * (T.ratio + 1))) = 1 / 2 := by field_simp
    linarith
  have hqlt : T.ratio * |ε| < 1 := by linarith
  have hmain := abs_wrongness_le T ε p hqlt
  have hden : (1 : ℝ) / 2 ≤ 1 - T.ratio * |ε| := by linarith
  have hnum : T.bound * |ε| ≤ (T.bound + 1) * |ε| := by nlinarith [T.bound_nonneg]
  have hlt : (T.bound + 1) * |ε| < η / 2 := by
    have h6 := mul_lt_mul_of_pos_left h2 hb
    have heq : (T.bound + 1) * (η / (2 * (T.bound + 1))) = η / 2 := by
      field_simp
    linarith [heq ▸ h6]
  have hnn : 0 ≤ T.bound * |ε| := mul_nonneg T.bound_nonneg hεabs
  have hcomp : (T.bound * |ε|) / (1 - T.ratio * |ε|) ≤ (T.bound * |ε|) / (1 / 2) :=
    div_le_div_of_nonneg_left hnn (by norm_num) hden
  have h5 : (T.bound * |ε|) / (1 / 2) = 2 * (T.bound * |ε|) := by ring
  linarith

/-- Filter form of `wrongness_small` at a fixed phenomenon. -/
theorem wrongness_tendsto_zero (T : Perturbative Φ) (p : Φ) :
    Filter.Tendsto (fun ε => wrongness T ε p) (nhds 0) (nhds 0) := by
  rw [Metric.tendsto_nhds_nhds]
  intro η hη
  obtain ⟨δ, hδ, h⟩ := wrongness_small T hη
  refine ⟨δ, hδ, fun {ε} hε => ?_⟩
  have hlt : |ε| < δ := by simpa [Real.dist_eq] using hε
  simpa [Real.dist_eq] using h ε hlt p

/-! ### Asymptotic orders and the catalog's `IsOrderThreeAtZero` -/

/-- `f` vanishes to order `k` at zero, in the elementary sense used by
`WilsonEpsilon.IsOrderThreeAtZero`. -/
def IsOrderAtZero (k : ℕ) (f : ℝ → ℝ) : Prop :=
  ∃ C > 0, ∃ δ > 0, ∀ ε, |ε| < δ → |f ε| ≤ C * |ε| ^ k

/-- The generalised order predicate specialises to the catalog definition. -/
theorem isOrderThreeAtZero_iff (f : ℝ → ℝ) :
    IsOrderAtZero 3 f ↔ WilsonEpsilon.IsOrderThreeAtZero f := Iff.rfl

/-- Tail bound: the wrongness beyond order `N` is geometrically small. -/
lemma abs_tail_le (T : Perturbative Φ) (ε : ℝ) (p : Φ) (N : ℕ)
    (h : T.ratio * |ε| < 1) :
    |wrongness T ε p - ∑ n ∈ Finset.range N, wrongTerm T ε p n| ≤
      (T.bound * |ε| ^ (N + 1) * T.ratio ^ N) / (1 - T.ratio * |ε|) := by
  have hq : 0 ≤ T.ratio * |ε| := mul_nonneg T.ratio_nonneg (abs_nonneg ε)
  have hsum := summable_wrongTerm T ε p h
  have hsplit : wrongness T ε p - ∑ n ∈ Finset.range N, wrongTerm T ε p n
      = ∑' n, wrongTerm T ε p (n + N) := by
    have hs := Summable.sum_add_tsum_nat_add (f := wrongTerm T ε p) N hsum
    simp [wrongness, ← hs]
  rw [hsplit]
  have hbd : ∀ n : ℕ, |wrongTerm T ε p (n + N)| ≤
      (T.bound * |ε| ^ (N + 1) * T.ratio ^ N) * (T.ratio * |ε|) ^ n := by
    intro n
    refine (abs_wrongTerm_le T ε p (n + N)).trans (le_of_eq ?_)
    rw [pow_add, mul_pow, mul_pow]
    ring
  have hsummable_shift : Summable (fun n => |wrongTerm T ε p (n + N)|) :=
    Summable.of_nonneg_of_le (fun n => abs_nonneg _) hbd
      ((summable_geometric_of_lt_one hq h).mul_left _)
  have hstep : |∑' n, wrongTerm T ε p (n + N)| ≤ ∑' n, |wrongTerm T ε p (n + N)| := by
    simpa [Real.norm_eq_abs] using
      norm_tsum_le_tsum_norm (f := fun n => wrongTerm T ε p (n + N))
        (by simpa [Real.norm_eq_abs] using hsummable_shift)
  refine hstep.trans ?_
  have hle : ∑' n, |wrongTerm T ε p (n + N)| ≤
      ∑' n, (T.bound * |ε| ^ (N + 1) * T.ratio ^ N) * (T.ratio * |ε|) ^ n :=
    Summable.tsum_le_tsum hbd hsummable_shift ((summable_geometric_of_lt_one hq h).mul_left _)
  refine hle.trans (le_of_eq ?_)
  rw [tsum_mul_left, tsum_geometric_of_lt_one hq h]
  field_simp

/-- **Optimal-truncation theorem.**  The `N`-th order truncation — a theory that
is *knowingly wrong*, since it discards infinitely many corrections — has an
error of order `ε ^ (N+1)` at zero coupling. -/
theorem truncation_isOrder (T : Perturbative Φ) (p : Φ) (N : ℕ) :
    IsOrderAtZero (N + 1) (fun ε => predict T ε p - truncate T N ε p) := by
  have hr : 0 < T.ratio + 1 := by linarith [T.ratio_nonneg]
  have hb : 0 < T.bound + 1 := by linarith [T.bound_nonneg]
  refine ⟨2 * (T.bound + 1) * (T.ratio + 1) ^ N,
    by positivity, 1 / (2 * (T.ratio + 1)), by positivity, ?_⟩
  intro ε hε
  have hεabs : 0 ≤ |ε| := abs_nonneg ε
  have hq : T.ratio * |ε| ≤ 1 / 2 := by
    have h1 : T.ratio * |ε| ≤ (T.ratio + 1) * |ε| := by nlinarith [T.ratio_nonneg]
    have h3 : (T.ratio + 1) * |ε| < (T.ratio + 1) * (1 / (2 * (T.ratio + 1))) :=
      mul_lt_mul_of_pos_left hε hr
    have h4 : (T.ratio + 1) * (1 / (2 * (T.ratio + 1))) = 1 / 2 := by field_simp
    linarith
  have hqlt : T.ratio * |ε| < 1 := by linarith
  have hmain := abs_tail_le T ε p N hqlt
  have hrewrite : predict T ε p - truncate T N ε p
      = wrongness T ε p - ∑ n ∈ Finset.range N, wrongTerm T ε p n := by
    simp [predict, truncate]
  simp only []
  rw [hrewrite]
  refine hmain.trans ?_
  have hden : (1 : ℝ) / 2 ≤ 1 - T.ratio * |ε| := by linarith
  have hnumnn : 0 ≤ T.bound * |ε| ^ (N + 1) * T.ratio ^ N :=
    mul_nonneg (mul_nonneg T.bound_nonneg (by positivity)) (pow_nonneg T.ratio_nonneg N)
  have step1 : (T.bound * |ε| ^ (N + 1) * T.ratio ^ N) / (1 - T.ratio * |ε|)
      ≤ (T.bound * |ε| ^ (N + 1) * T.ratio ^ N) / (1 / 2) :=
    div_le_div_of_nonneg_left hnumnn (by norm_num) hden
  refine step1.trans ?_
  have heq : (T.bound * |ε| ^ (N + 1) * T.ratio ^ N) / (1 / 2)
      = 2 * (T.bound * T.ratio ^ N) * |ε| ^ (N + 1) := by ring
  rw [heq]
  have hεpow : (0:ℝ) ≤ |ε| ^ (N + 1) := by positivity
  have hcoef : T.bound * T.ratio ^ N ≤ (T.bound + 1) * (T.ratio + 1) ^ N := by
    have h0 : (0:ℝ) ≤ T.ratio ^ N := pow_nonneg T.ratio_nonneg N
    have hratio : T.ratio ^ N ≤ (T.ratio + 1) ^ N :=
      pow_le_pow_left₀ T.ratio_nonneg (by linarith) N
    nlinarith [T.bound_nonneg]
  nlinarith [hεpow]

end WrongTheory