/-
# Structural Orthogonality (Factoring Lab, Phase A v19c)

The *core* pattern of the eight-barrier framework, stated and proved as a
theorem of elementary probability on a finite sample space.

Setting.  A finite population `Ω` of semiprimes (or of any objects), each
carrying a *band label* `n i` (in the lab: the size band `N / 40`, or simply
`N` itself), and a *target* `Y i` (in the lab: the smaller prime factor `p`).
An *invariant computable from `N` alone* is exactly a random variable of the
form `g ∘ n`.

Main results.

* `FactoringLab.structural_orthogonality`: every invariant `g ∘ n` computable
  from the band label alone is orthogonal to the *residual* `Y - E[Y | n]`.
  This is the exact sense in which "any computable function of `N` alone is
  `N`-only": it carries no information about `Y` beyond the band mean.
* `FactoringLab.cov_eq_cov_bandMean`: consequently the covariance of any such
  invariant with `Y` equals its covariance with the band means, i.e. *all*
  observed correlation is explained by the band.
* `FactoringLab.nearEqualN_test`: the formal near-equal-`N` test.  If the band
  means of `Y` are constant across the population, then **every** invariant
  computable from `n` alone has exactly zero covariance with `Y`.
* `FactoringLab.corr_zero_of_bandMean_const`: the same conclusion for the
  Pearson correlation coefficient.
-/
import Mathlib

namespace FactoringLab

open Finset

variable {ι κ : Type*} [DecidableEq κ]

/-- The fiber (`band`) of the population `Ω` containing `i`, i.e. all members
of the population sharing the band label of `i`. -/
def band (Ω : Finset ι) (n : ι → κ) (i : ι) : Finset ι :=
  Ω.filter (fun j => n j = n i)

/-- The conditional expectation `E[Y | n]` on a finite uniform population:
the average of `Y` over the band of `i`. -/
noncomputable def bandMean (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) (i : ι) : ℝ :=
  (∑ j ∈ band Ω n i, Y j) / (band Ω n i).card

/-- Uniform expectation over the finite population `Ω`. -/
noncomputable def expect (Ω : Finset ι) (Y : ι → ℝ) : ℝ :=
  (∑ i ∈ Ω, Y i) / Ω.card

/-- Covariance of two random variables under the uniform law on `Ω`. -/
noncomputable def cov (Ω : Finset ι) (X Y : ι → ℝ) : ℝ :=
  expect Ω (fun i => X i * Y i) - expect Ω X * expect Ω Y

/-- Variance under the uniform law on `Ω`. -/
noncomputable def variance (Ω : Finset ι) (X : ι → ℝ) : ℝ := cov Ω X X

/-- Pearson correlation under the uniform law on `Ω`. -/
noncomputable def corr (Ω : Finset ι) (X Y : ι → ℝ) : ℝ :=
  cov Ω X Y / (Real.sqrt (variance Ω X) * Real.sqrt (variance Ω Y))

section Fibers

/-- Members of the same band have the same band mean. -/
theorem bandMean_congr (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) {i j : ι}
    (h : n j = n i) : bandMean Ω n Y j = bandMean Ω n Y i := by
  unfold bandMean band
  simp [h]

/-- Summing a function over `Ω` can be done band by band. -/
theorem sum_by_band (Ω : Finset ι) (n : ι → κ) (F : ι → ℝ) :
    ∑ k ∈ Ω.image n, ∑ i ∈ Ω.filter (fun i => n i = k), F i = ∑ i ∈ Ω, F i :=
  Finset.sum_fiberwise_of_maps_to (fun _ hi => Finset.mem_image_of_mem n hi) F

/-- On a single band, the residual `Y - E[Y | n]` sums to zero. -/
theorem sum_residual_band (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) {k : κ}
    (hk : k ∈ Ω.image n) :
    ∑ i ∈ Ω.filter (fun i => n i = k), (Y i - bandMean Ω n Y i) = 0 := by
  obtain ⟨i₀, hi₀Ω, hi₀⟩ := Finset.mem_image.1 hk
  have hfib : Ω.filter (fun i => n i = k) = band Ω n i₀ := by
    unfold band; rw [hi₀]
  have hne : (band Ω n i₀).Nonempty := ⟨i₀, by simp [band, hi₀Ω]⟩
  have hcard : ((band Ω n i₀).card : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hne.card_pos.ne'
  rw [hfib, Finset.sum_sub_distrib]
  have hconst : ∀ i ∈ band Ω n i₀, bandMean Ω n Y i = bandMean Ω n Y i₀ := by
    intro i hi
    exact bandMean_congr Ω n Y (by simpa [band] using (Finset.mem_filter.1 hi).2)
  rw [Finset.sum_congr rfl hconst, Finset.sum_const, nsmul_eq_mul]
  unfold bandMean
  field_simp
  ring

end Fibers

/-- **Structural orthogonality.**  Every invariant `g ∘ n` that is computable
from the band label alone (in the lab: from `N` alone) is orthogonal to the
residual `Y - E[Y | n]` of the target.  No such invariant carries any linear
information about `Y` beyond what the band label already determines. -/
theorem structural_orthogonality (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) (g : κ → ℝ) :
    ∑ i ∈ Ω, g (n i) * (Y i - bandMean Ω n Y i) = 0 := by
  rw [← sum_by_band Ω n (fun i => g (n i) * (Y i - bandMean Ω n Y i))]
  refine Finset.sum_eq_zero fun k hk => ?_
  have : ∑ i ∈ Ω.filter (fun i => n i = k), g (n i) * (Y i - bandMean Ω n Y i)
      = g k * ∑ i ∈ Ω.filter (fun i => n i = k), (Y i - bandMean Ω n Y i) := by
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun i hi => ?_
    rw [(Finset.mem_filter.1 hi).2]
  rw [this, sum_residual_band Ω n Y hk, mul_zero]

/-- The residuals sum to zero: the band means have the same population mean as
`Y` itself (the tower property). -/
theorem expect_bandMean (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) :
    expect Ω (bandMean Ω n Y) = expect Ω Y := by
  have h := structural_orthogonality Ω n Y (fun _ => 1)
  simp only [one_mul, Finset.sum_sub_distrib, sub_eq_zero] at h
  unfold expect
  rw [h]

/-- **All correlation is band correlation.**  For any invariant computable from
the band label alone, its covariance with the target equals its covariance with
the band means of the target. -/
theorem cov_eq_cov_bandMean (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) (g : κ → ℝ) :
    cov Ω (fun i => g (n i)) Y = cov Ω (fun i => g (n i)) (bandMean Ω n Y) := by
  have h := structural_orthogonality Ω n Y g
  have hsum : ∑ i ∈ Ω, g (n i) * Y i = ∑ i ∈ Ω, g (n i) * bandMean Ω n Y i := by
    have : ∑ i ∈ Ω, (g (n i) * Y i - g (n i) * bandMean Ω n Y i) = 0 := by
      simpa [mul_sub] using h
    rw [Finset.sum_sub_distrib, sub_eq_zero] at this
    exact this
  have h2 : expect Ω (fun i => g (n i) * Y i)
      = expect Ω (fun i => g (n i) * bandMean Ω n Y i) := by
    unfold expect; rw [hsum]
  unfold cov
  rw [h2, expect_bandMean Ω n Y]

/-- **The near-equal-`N` test, formalized.**  If the band means of the target
are constant across the population — the situation engineered by grouping
semiprimes into a narrow size band — then *every* invariant computable from the
band label alone has exactly zero covariance with the target. -/
theorem nearEqualN_test (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) (c : ℝ)
    (hconst : ∀ i ∈ Ω, bandMean Ω n Y i = c) (g : κ → ℝ) :
    cov Ω (fun i => g (n i)) Y = 0 := by
  rw [cov_eq_cov_bandMean Ω n Y g]
  have e1 : ∑ i ∈ Ω, g (n i) * bandMean Ω n Y i = (∑ i ∈ Ω, g (n i)) * c := by
    rw [Finset.sum_mul]
    exact Finset.sum_congr rfl fun i hi => by rw [hconst i hi]
  have e2 : ∑ i ∈ Ω, bandMean Ω n Y i = (Ω.card : ℝ) * c := by
    rw [Finset.sum_congr rfl fun i hi => hconst i hi, Finset.sum_const, nsmul_eq_mul]
  simp only [cov, expect]
  rw [e1, e2]
  rcases Finset.eq_empty_or_nonempty Ω with rfl | hΩ
  · simp
  · have hcard : (Ω.card : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hΩ.card_pos.ne'
    field_simp
    ring

/-- Under the near-equal-`N` hypothesis the Pearson correlation of any
`N`-only invariant with the target is exactly zero. -/
theorem corr_zero_of_bandMean_const (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) (c : ℝ)
    (hconst : ∀ i ∈ Ω, bandMean Ω n Y i = c) (g : κ → ℝ) :
    corr Ω (fun i => g (n i)) Y = 0 := by
  unfold corr
  rw [nearEqualN_test Ω n Y c hconst g, zero_div]


/-! ### Quantitative form: no `N`-only invariant predicts better than the band mean -/

/-- The band mean as a genuine function of the band label alone. -/
noncomputable def bandMeanFn (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) (k : κ) : ℝ :=
  (∑ j ∈ Ω.filter (fun j => n j = k), Y j) / (Ω.filter (fun j => n j = k)).card

theorem bandMeanFn_comp (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) (i : ι) :
    bandMeanFn Ω n Y (n i) = bandMean Ω n Y i := rfl

/-- **Best-predictor barrier.**  Among all invariants computable from the band
label alone, the band mean minimizes the squared prediction error for the
target.  Quantitatively: any `N`-only invariant `g ∘ n` used as a predictor of
the hidden factor incurs at least the irreducible error of the band mean, with
the excess being exactly its squared deviation from the band mean. -/
theorem sq_error_decomposition (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) (g : κ → ℝ) :
    ∑ i ∈ Ω, (g (n i) - Y i) ^ 2
      = ∑ i ∈ Ω, (g (n i) - bandMean Ω n Y i) ^ 2
        + ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2 := by
  have hcross := structural_orthogonality Ω n Y (fun k => g k - bandMeanFn Ω n Y k)
  simp only [bandMeanFn_comp] at hcross
  have hcross' : ∑ i ∈ Ω, (g (n i) - bandMean Ω n Y i) * (bandMean Ω n Y i - Y i) = 0 := by
    have h2 : ∀ i, (g (n i) - bandMean Ω n Y i) * (bandMean Ω n Y i - Y i)
        = -((g (n i) - bandMean Ω n Y i) * (Y i - bandMean Ω n Y i)) := fun i => by ring
    rw [Finset.sum_congr rfl (fun i _ => h2 i), Finset.sum_neg_distrib, hcross, neg_zero]
  have hexp : ∀ i, (g (n i) - Y i) ^ 2
      = (g (n i) - bandMean Ω n Y i) ^ 2 + (bandMean Ω n Y i - Y i) ^ 2
        + 2 * ((g (n i) - bandMean Ω n Y i) * (bandMean Ω n Y i - Y i)) := by
    intro i; ring
  calc ∑ i ∈ Ω, (g (n i) - Y i) ^ 2
      = ∑ i ∈ Ω, ((g (n i) - bandMean Ω n Y i) ^ 2 + (bandMean Ω n Y i - Y i) ^ 2
          + 2 * ((g (n i) - bandMean Ω n Y i) * (bandMean Ω n Y i - Y i))) :=
        Finset.sum_congr rfl fun i _ => hexp i
    _ = ∑ i ∈ Ω, (g (n i) - bandMean Ω n Y i) ^ 2
          + ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2 := by
        rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, hcross',
          mul_zero, add_zero]

/-- No invariant computable from the band label alone beats the band mean as a
predictor of the target. -/
theorem bandMean_is_best_predictor (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) (g : κ → ℝ) :
    ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2 ≤ ∑ i ∈ Ω, (g (n i) - Y i) ^ 2 := by
  rw [sq_error_decomposition Ω n Y g]
  have : 0 ≤ ∑ i ∈ Ω, (g (n i) - bandMean Ω n Y i) ^ 2 :=
    Finset.sum_nonneg fun i _ => sq_nonneg _
  linarith


/-! ### Quantitative near-equal-`N` test: Cauchy–Schwarz against the band spread -/

/-- Covariance in centered form. -/
theorem cov_centered (Ω : Finset ι) (X Y : ι → ℝ) :
    cov Ω X Y
      = (∑ i ∈ Ω, (X i - expect Ω X) * (Y i - expect Ω Y)) / Ω.card := by
  rcases Finset.eq_empty_or_nonempty Ω with rfl | hΩ
  · simp [cov, expect]
  · have hcard : (Ω.card : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hΩ.card_pos.ne'
    have hexp : ∀ i ∈ Ω, (X i - expect Ω X) * (Y i - expect Ω Y)
        = X i * Y i - expect Ω X * Y i - expect Ω Y * X i
          + expect Ω X * expect Ω Y := fun i _ => by ring
    rw [Finset.sum_congr rfl hexp]
    rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_sub_distrib,
      ← Finset.mul_sum, ← Finset.mul_sum, Finset.sum_const, nsmul_eq_mul]
    unfold cov expect
    field_simp
    ring

/-- **Cauchy–Schwarz for the empirical covariance.** -/
theorem cov_sq_le_variance_mul (Ω : Finset ι) (X Y : ι → ℝ) :
    (cov Ω X Y) ^ 2 ≤ variance Ω X * variance Ω Y := by
  have hCS := Finset.sum_mul_sq_le_sq_mul_sq Ω
    (fun i => X i - expect Ω X) (fun i => Y i - expect Ω Y)
  have hc : (0 : ℝ) ≤ (Ω.card : ℝ) ^ 2 := sq_nonneg _
  rw [cov_centered Ω X Y, div_pow]
  have hvx : variance Ω X = (∑ i ∈ Ω, (X i - expect Ω X) ^ 2) / Ω.card := by
    rw [variance, cov_centered Ω X X]
    exact congrArg (· / (Ω.card : ℝ)) (Finset.sum_congr rfl fun i _ => by ring)
  have hvy : variance Ω Y = (∑ i ∈ Ω, (Y i - expect Ω Y) ^ 2) / Ω.card := by
    rw [variance, cov_centered Ω Y Y]
    exact congrArg (· / (Ω.card : ℝ)) (Finset.sum_congr rfl fun i _ => by ring)
  rw [hvx, hvy, div_mul_div_comm, ← sq]
  rcases Finset.eq_empty_or_nonempty Ω with rfl | hΩ
  · simp
  · have hcard : (0 : ℝ) < (Ω.card : ℝ) := by exact_mod_cast hΩ.card_pos
    gcongr

/-- **The quantitative near-equal-`N` test.**  Without any hypothesis, the
covariance of an `N`-only invariant with the target is bounded by the geometric
mean of its own variance and the *variance of the band means*.  In a narrow
size band the latter is tiny, which is precisely why every `N`-only invariant
measures as uncorrelated with the hidden factor. -/
theorem cov_sq_le_variance_mul_variance_bandMean (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (g : κ → ℝ) :
    (cov Ω (fun i => g (n i)) Y) ^ 2
      ≤ variance Ω (fun i => g (n i)) * variance Ω (bandMean Ω n Y) := by
  rw [cov_eq_cov_bandMean Ω n Y g]
  exact cov_sq_le_variance_mul Ω _ _

/-! ### Free-witness aggregation -/

/-- **Free-witness aggregation.**  Combining any finite family of `N`-only
invariants by an arbitrary (possibly nonlinear) aggregation rule `Φ` produces
another `N`-only invariant; under the near-equal-`N` hypothesis the aggregate
still has exactly zero covariance with the target.  Pooling free witnesses
cannot create information that no individual witness has. -/
theorem free_witness_aggregation {m : ℕ} (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ) (c : ℝ)
    (hconst : ∀ i ∈ Ω, bandMean Ω n Y i = c) (g : Fin m → κ → ℝ)
    (Φ : (Fin m → ℝ) → ℝ) :
    cov Ω (fun i => Φ (fun j => g j (n i))) Y = 0 :=
  nearEqualN_test Ω n Y c hconst (fun k => Φ (fun j => g j k))

/-- The same for the squared-error barrier: no aggregate of free witnesses
predicts the target better than the band mean. -/
theorem aggregation_no_better_than_bandMean {m : ℕ} (Ω : Finset ι) (n : ι → κ) (Y : ι → ℝ)
    (g : Fin m → κ → ℝ) (Φ : (Fin m → ℝ) → ℝ) :
    ∑ i ∈ Ω, (bandMean Ω n Y i - Y i) ^ 2
      ≤ ∑ i ∈ Ω, (Φ (fun j => g j (n i)) - Y i) ^ 2 :=
  bandMean_is_best_predictor Ω n Y (fun k => Φ (fun j => g j k))

/-- Sanity check that the framework is not vacuous: an invariant that is *not*
a function of the band label can have nonzero covariance with the target.  Here
the population is `{0, 1} ⊆ ℕ`, all in one band, `X = Y = id`, and the
covariance is `1/4 ≠ 0`. -/
theorem cov_ne_zero_of_non_invariant :
    cov ({0, 1} : Finset ℕ) (fun i => (i : ℝ)) (fun i => (i : ℝ)) = 1 / 4 := by
  unfold cov expect
  norm_num

end FactoringLab