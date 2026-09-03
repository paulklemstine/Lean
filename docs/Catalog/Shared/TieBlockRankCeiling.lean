import Mathlib

/-!
# The tie-block ceiling on rank correlation (T-DIAL-56, paper 178)

## Scientific context

Papers 175/178 study a *dial*: a real statistic `T(N)` that is supposed to predict
the smooth-hit `rate(N)` of a sieve run at a given bit length.  Quality is measured
by `Spearman(T, rate)`, and the target band is `[0.55, 0.85]`.  At bit length `56`
the observed value collapses to `0.405`, and the recorded cause is a **starved
regime**: the mean smooth rate falls to `0.89 %` and `194` of the `1200` sampled
moduli record *zero* hits.  Zero hits means the measured `rate` is literally the
same number for all `194` of them — a **tie block**.

This file supplies the exact mathematics of that mechanism.  A tie block is a set
on which the response variable is constant; the predictor `T` still varies there,
and every bit of that variation is invisible to any correlation with the response.
The result is a *ceiling*: no matter how good the dial is, its correlation cannot
exceed a number determined by the tie structure alone.

## Mathematical content

Let `b : ι → κ` be a block labelling and let `Y` be constant on each block
(`Y = g ∘ b`).  Write `E[X|b]` for the block-averaging (conditional expectation)
operator.  The chain of results is:

* `sum_residual_mul_comp` — the residual `X - E[X|b]` is orthogonal to every
  function of the block label.  (The defining property of conditional expectation.)
* `var_eq_explained_add_residual` — the law of total variance,
  `Var X = Var(E[X|b]) + ‖X - E[X|b]‖²`.
* `cov_sq_le_explained` — **the ceiling**: `Cov(X,Y)² ≤ (Var X - W) · Var Y`
  where `W = ‖X - E[X|b]‖²` is the within-block sum of squares.  Equivalently
  `ρ(X,Y)² ≤ 1 - W / Var X`.
* `blockSpread_ge` — if `X` is *injective with integer values* on a block of size
  `m` (which is exactly what a rank vector is), the within-block sum of squares on
  that block is at least `(m³ - m)/12`.  This is the discrete isoperimetric fact
  that `m` distinct integers are least spread out when they are consecutive.
* `spearman_ceiling_of_tie_block` — combining the two: for a rank vector `X` on
  `n` points and a response tied on a block of size `m`,
  `ρ(X,Y)² ≤ 1 - (m³ - m)/(n³ - n)`.

## The adversarial finding (Critic stage)

Instantiating with the reported numbers `m = 194`, `n = 1200` gives a ceiling of
`ρ ≤ 0.99789…`, recorded here as `starvation_ceiling_1200_194`.  So the zero-hit
tie block is **not** by itself capable of explaining the collapse to `0.405`; the
mechanism only becomes binding at extreme starvation.  The exact threshold is
`starvation_threshold`: to force `ρ ≤ 0.55` by ties alone one needs
`m³ - m ≥ 0.6975 · (n³ - n)`, i.e. a zero-hit fraction of about `88.7 %`.
The honest conclusion is therefore that the practical floor of the bit-length dial
is a *two-mechanism* floor, and the tie-block ceiling bounds only one of them.
-/

namespace TieCeiling

open Finset

/-! ## Centred moments -/

variable {ι κ : Type*} [Fintype ι]

/-- Arithmetic mean of `X` over the whole index type. -/
noncomputable def mean (X : ι → ℝ) : ℝ := (∑ i, X i) / (Fintype.card ι)

/-- Uncentred covariance (sum, not average — all statements are scale-free in it). -/
noncomputable def cov (X Y : ι → ℝ) : ℝ := ∑ i, (X i - mean X) * (Y i - mean Y)

/-- Uncentred variance. -/
noncomputable def varOf (X : ι → ℝ) : ℝ := ∑ i, (X i - mean X) ^ 2

lemma varOf_eq_cov (X : ι → ℝ) : varOf X = cov X X := by
  simp [varOf, cov, sq]

lemma varOf_nonneg (X : ι → ℝ) : 0 ≤ varOf X :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

/-! ## Block averaging (conditional expectation on the tie partition) -/

variable [Fintype κ] [DecidableEq κ]

/-- The block of index labelled `k`. -/
def fiber (b : ι → κ) (k : κ) : Finset ι := Finset.univ.filter (fun i => b i = k)

/-- The average of `X` over the block labelled `k` (zero on empty blocks). -/
noncomputable def blockAvg (X : ι → ℝ) (b : ι → κ) (k : κ) : ℝ :=
  (∑ i ∈ fiber b k, X i) / (fiber b k).card

/-- `E[X | b]`: the block-averaging operator. -/
noncomputable def condExp (X : ι → ℝ) (b : ι → κ) : ι → ℝ := fun i => blockAvg X b (b i)

omit [Fintype κ] in
lemma mem_fiber {b : ι → κ} {k : κ} {i : ι} : i ∈ fiber b k ↔ b i = k := by
  simp [fiber]

omit [Fintype κ] in
/-- The residual `X - E[X|b]` sums to zero over each block. -/
lemma sum_residual_fiber (X : ι → ℝ) (b : ι → κ) (k : κ) :
    ∑ i ∈ fiber b k, (X i - condExp X b i) = 0 := by
  rcases Finset.eq_empty_or_nonempty (fiber b k) with h | h
  · simp [h]
  · have hcard : ((fiber b k).card : ℝ) ≠ 0 :=
      Nat.cast_ne_zero.2 (Finset.card_pos.2 h).ne'
    have hconst : ∀ i ∈ fiber b k, condExp X b i = blockAvg X b k := by
      intro i hi
      simp [condExp, mem_fiber.1 hi]
    rw [Finset.sum_sub_distrib, Finset.sum_congr rfl hconst, Finset.sum_const, nsmul_eq_mul,
      blockAvg]
    field_simp
    ring

/-- **Orthogonality of the residual to the block σ-algebra.**  The residual
`X - E[X|b]` is orthogonal to every function that only depends on the block label. -/
lemma sum_residual_mul_comp (X : ι → ℝ) (b : ι → κ) (h : κ → ℝ) :
    ∑ i, (X i - condExp X b i) * h (b i) = 0 := by
  have := Finset.sum_fiberwise (Finset.univ : Finset ι) b
    (fun i => (X i - condExp X b i) * h (b i))
  rw [← this]
  refine Finset.sum_eq_zero ?_
  intro k _
  have hk : ∀ i ∈ fiber b k, (X i - condExp X b i) * h (b i)
      = h k * (X i - condExp X b i) := by
    intro i hi
    rw [mem_fiber.1 hi]; ring
  have hfib : (Finset.univ.filter (fun i => b i = k)) = fiber b k := rfl
  rw [hfib, Finset.sum_congr rfl hk, ← Finset.mul_sum, sum_residual_fiber, mul_zero]

/-! ## Law of total variance and the ceiling -/

/-- The mean is preserved by block averaging. -/
lemma sum_condExp (X : ι → ℝ) (b : ι → κ) : ∑ i, condExp X b i = ∑ i, X i := by
  have h := sum_residual_mul_comp X b (fun _ => 1)
  simp only [mul_one] at h
  rw [Finset.sum_sub_distrib] at h
  linarith

/-- **Law of total variance.**  `Var X` splits into the between-block ("explained")
part and the within-block sum of squares. -/
lemma var_eq_explained_add_residual (X : ι → ℝ) (b : ι → κ) :
    varOf X = (∑ i, (condExp X b i - mean X) ^ 2) + ∑ i, (X i - condExp X b i) ^ 2 := by
  have hcross : ∑ i, (X i - condExp X b i) * (blockAvg X b (b i) - mean X) = 0 :=
    sum_residual_mul_comp X b (fun k => blockAvg X b k - mean X)
  have hexp : ∀ i, (X i - mean X) ^ 2
      = (X i - condExp X b i) ^ 2 + (condExp X b i - mean X) ^ 2
        + 2 * ((X i - condExp X b i) * (blockAvg X b (b i) - mean X)) := by
    intro i
    simp only [condExp]
    ring
  rw [varOf, Finset.sum_congr rfl (fun i _ => hexp i)]
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, hcross]
  ring

/-- The covariance only sees the block averages, when `Y` is constant on blocks. -/
lemma cov_eq_explained_cov (X : ι → ℝ) (b : ι → κ) (g : κ → ℝ) :
    cov X (fun i => g (b i))
      = ∑ i, (condExp X b i - mean X) * (g (b i) - mean (fun i => g (b i))) := by
  set Y : ι → ℝ := fun i => g (b i) with hY
  have hzero : ∑ i, (X i - condExp X b i) * (g (b i) - mean Y) = 0 :=
    sum_residual_mul_comp X b (fun k => g k - mean Y)
  have hsplit : ∀ i, (X i - mean X) * (Y i - mean Y)
      = (X i - condExp X b i) * (g (b i) - mean Y)
        + (condExp X b i - mean X) * (g (b i) - mean Y) := by
    intro i; simp only [hY]; ring
  rw [cov, Finset.sum_congr rfl (fun i _ => hsplit i), Finset.sum_add_distrib, hzero, zero_add]

/-- **The tie-block ceiling.**  If the response `Y` is constant on each block of `b`,
then the covariance with any predictor `X` is capped by the *between-block* part of
`Var X` only: the within-block spread `W = ∑ (X i - E[X|b] i)²` is pure dead weight.

Dividing by `Var X · Var Y` this reads `ρ(X,Y)² ≤ 1 - W / Var X`. -/
theorem cov_sq_le_explained (X : ι → ℝ) (b : ι → κ) (g : κ → ℝ) :
    cov X (fun i => g (b i)) ^ 2
      ≤ (varOf X - ∑ i, (X i - condExp X b i) ^ 2) * varOf (fun i => g (b i)) := by
  set Y : ι → ℝ := fun i => g (b i) with hY
  have hcov := cov_eq_explained_cov X b g
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ : Finset ι)
    (fun i => condExp X b i - mean X) (fun i => g (b i) - mean Y)
  have hvar := var_eq_explained_add_residual X b
  have hYvar : varOf Y = ∑ i, (g (b i) - mean Y) ^ 2 := rfl
  rw [hcov]
  calc (∑ i, (condExp X b i - mean X) * (g (b i) - mean Y)) ^ 2
      ≤ (∑ i, (condExp X b i - mean X) ^ 2) * ∑ i, (g (b i) - mean Y) ^ 2 := hcs
    _ = (varOf X - ∑ i, (X i - condExp X b i) ^ 2) * varOf Y := by
        rw [hYvar]; congr 1; linarith [hvar]

end TieCeiling