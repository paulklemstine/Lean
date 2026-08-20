import Mathlib
import NumberTheory.MoonshineHeadTable
import NumberTheory.MoonshineSecondHead

/-!
# A complete Newton recursion for eta-quotient head coefficients

This file is cycle 7 of the research thread.  Cycles 3 and 6
(`NumberTheory.MoonshineHeadTable`, `NumberTheory.MoonshineSecondHead`) computed the
first two head coefficients `c_g(1)` and `c_g(2)` of an eta-quotient McKay–Thompson
series from its frame shape by explicit `2`- and `3`-jet calculus.  Each new degree
cost a new, longer hand computation, and it was not clear that the pattern
continues.

Here we replace the jet calculus by a *single* structural theorem valid in **all**
degrees.  The tool is the logarithmic derivative
`X · F' = F · ℓ`, formalized as the relation `MoonshineNewtonRecursion.HasLogDeriv`.
It is additive on products, negates on inverses, and therefore scales on arbitrary
*integer* powers of units — which is exactly what an eta *quotient* needs.

Applying this to `F = ∏_{m ≤ M} (1 - qᵐ)^(-b m)` gives the log-derivative series
`ℓ = ∑_{m ≤ M} m · b m · qᵐ/(1 - qᵐ)`, whose `r`-th coefficient is the
frame-shape divisor sum

`σ_a(r) = ∑_{d ∣ r} d · b d`,  `b d = ∑_{k ∣ d} a k`,

and hence the recursion

`r · c_r = ∑_{k < r} c_k · σ_a(r - k)`   (`MoonshineNewtonRecursion.newton_recursion`).

This determines *every* coefficient of the eta quotient from the finitely many
frame-shape exponents `a k`, uniformly in `r`.

As an adversarial cross-check (Stage 4 of the research loop) we re-derive the two
previously proved closed formulas from the recursion, by two completely independent
routes:

* `MoonshineNewtonRecursion.two_mul_coeff_two_recursion` recovers
  `MoonshineHeadTable.headCoeff`;
* `MoonshineNewtonRecursion.six_mul_coeff_three_recursion` recovers
  `MoonshineSecondHead.secondHeadCoeff`.

Both agree, which is a genuine consistency test of the earlier jet computations.

## Contents

* `HasLogDeriv`, `HasLogDeriv.mul`, `HasLogDeriv.inv`, `HasLogDeriv.zpow`,
  `hasLogDeriv_prod` — the logarithmic-derivative calculus for units of `R⟦X⟧`.
* `geomPow`, `oneSub_mul_geomPow` — the series `∑_{j ≥ 1} q^{jk}` and its defining
  identity `(1 - q^k) · geomPow k = q^k`.
* `sigmaFrame` — the frame-shape divisor sum `σ_a(r) = ∑_{d ∣ r} d · b d`.
* `hasLogDeriv_etaPartial`, `coeff_logDerivEta` — the log-derivative of a truncated
  eta quotient and its coefficients.
* `newton_recursion` — the main theorem.
* `coeff_one_recursion`, `two_mul_coeff_two_recursion`,
  `six_mul_coeff_three_recursion` — the first three instances, cross-checked against
  cycles 3 and 6.
-/

namespace MoonshineNewtonRecursion

open PowerSeries Finset MoonshineHeadTable MoonshineSecondHead MoonshineFiniteReduction

variable {R : Type*} [CommRing R] {ι : Type*}

/-! ## 1. The logarithmic-derivative calculus -/

/-- `HasLogDeriv u l` says that `l` is the logarithmic derivative `X · u' / u` of the
unit power series `u`, written multiplicatively so as never to divide. -/
def HasLogDeriv (u : (R⟦X⟧)ˣ) (l : R⟦X⟧) : Prop :=
  X * (d⁄dX R) (u : R⟦X⟧) = (u : R⟦X⟧) * l

theorem hasLogDeriv_one : HasLogDeriv (1 : (R⟦X⟧)ˣ) 0 := by
  simp [HasLogDeriv]

/-- The logarithmic derivative is additive on products. -/
theorem HasLogDeriv.mul {u v : (R⟦X⟧)ˣ} {l m : R⟦X⟧}
    (hu : HasLogDeriv u l) (hv : HasLogDeriv v m) : HasLogDeriv (u * v) (l + m) := by
  unfold HasLogDeriv at *
  have hL : (d⁄dX R) ((u : R⟦X⟧) * (v : R⟦X⟧))
      = (u : R⟦X⟧) * (d⁄dX R) (v : R⟦X⟧) + (v : R⟦X⟧) * (d⁄dX R) (u : R⟦X⟧) := by
    simp [Derivation.leibniz, smul_eq_mul]
  rw [Units.val_mul, hL]
  linear_combination (u : R⟦X⟧) * hv + (v : R⟦X⟧) * hu

/-- The logarithmic derivative negates on inverses. -/
theorem HasLogDeriv.inv {u : (R⟦X⟧)ˣ} {l : R⟦X⟧} (hu : HasLogDeriv u l) :
    HasLogDeriv u⁻¹ (-l) := by
  unfold HasLogDeriv at *
  rw [PowerSeries.derivative_inv]
  have h1 : ((u : R⟦X⟧)) * ((u⁻¹ : (R⟦X⟧)ˣ) : R⟦X⟧) = 1 := u.mul_inv
  linear_combination (-(((u⁻¹ : (R⟦X⟧)ˣ) : R⟦X⟧)) ^ 2) * hu
    - (((u⁻¹ : (R⟦X⟧)ˣ) : R⟦X⟧) * l) * h1

/-- **Integer powers.**  The logarithmic derivative of `u ^ z` is `z • l`, for every
integer `z`.  This is the step that makes eta *quotients* accessible. -/
theorem HasLogDeriv.zpow {u : (R⟦X⟧)ˣ} {l : R⟦X⟧} (hu : HasLogDeriv u l) (z : ℤ) :
    HasLogDeriv (u ^ z) ((z : R) • l) := by
  induction z using Int.induction_on with
  | zero => simp [HasLogDeriv]
  | succ n ih =>
      have h := ih.mul hu
      rw [zpow_add_one]
      convert h using 1
      push_cast
      module
  | pred n ih =>
      have h := ih.mul hu.inv
      rw [zpow_sub_one]
      convert h using 1
      push_cast
      module

/-- Finite products. -/
theorem hasLogDeriv_prod (s : Finset ι) (u : ι → (R⟦X⟧)ˣ) (l : ι → R⟦X⟧)
    (h : ∀ i ∈ s, HasLogDeriv (u i) (l i)) :
    HasLogDeriv (∏ i ∈ s, u i) (∑ i ∈ s, l i) := by
  classical
  induction s using Finset.induction with
  | empty => simpa using (hasLogDeriv_one (R := R))
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, Finset.sum_insert ha]
      exact (h a (Finset.mem_insert_self a s)).mul
        (ih (fun i hi => h i (Finset.mem_insert_of_mem hi)))

/-! ## 2. The geometric series `∑_{j ≥ 1} q^{j k}` -/

variable (R) in
/-- The power series `∑_{j ≥ 1} q^{j k} = q^k / (1 - q^k)`. -/
noncomputable def geomPow (k : ℕ) : R⟦X⟧ :=
  PowerSeries.mk fun n => if k ∣ n ∧ 0 < n then (1 : R) else 0

@[simp] theorem coeff_geomPow (k n : ℕ) :
    coeff n (geomPow R k) = if k ∣ n ∧ 0 < n then (1 : R) else 0 := by
  simp [geomPow]

/-- The defining identity `(1 - q^k) · geomPow k = q^k`. -/
theorem oneSub_mul_geomPow {k : ℕ} (hk : 0 < k) :
    (1 - X ^ k) * geomPow R k = X ^ k := by
  ext n
  rw [sub_mul, one_mul, map_sub, coeff_X_pow_mul', PowerSeries.coeff_X_pow]
  simp only [geomPow, PowerSeries.coeff_mk]
  by_cases hkn : k ≤ n
  · rw [if_pos hkn]
    by_cases hd : k ∣ n
    · rw [if_pos ⟨hd, by omega⟩]
      by_cases hnk : n = k
      · subst hnk
        rw [if_pos rfl, if_neg (by simp), sub_zero]
      · have hdd : k ∣ n - k := Nat.dvd_sub hd dvd_rfl
        rw [if_neg hnk, if_pos ⟨hdd, by omega⟩, sub_self]
    · have h2 : ¬ (k ∣ n - k ∧ 0 < n - k) := by
        rintro ⟨hd2, _⟩
        exact hd (by simpa [Nat.sub_add_cancel hkn] using Nat.dvd_add hd2 (dvd_refl k))
      rw [if_neg (fun h => hd h.1), if_neg h2, if_neg (fun h : n = k => hd (by rw [h])),
        sub_zero]
  · have h1 : ¬ (k ∣ n ∧ 0 < n) := fun h => hkn (Nat.le_of_dvd h.2 h.1)
    rw [if_neg hkn, if_neg h1, if_neg (fun h : n = k => hkn (by omega)), sub_zero]

/-- The logarithmic derivative of the elementary factor `1 - q^k`. -/
theorem hasLogDeriv_oneSubXPow {k : ℕ} (hk : 0 < k) (u : (R⟦X⟧)ˣ)
    (hu : (u : R⟦X⟧) = 1 - X ^ k) :
    HasLogDeriv u ((-(k : R)) • geomPow R k) := by
  have hd1 : (d⁄dX R) (1 : R⟦X⟧) = 0 := Derivation.map_one_eq_zero _
  have hlhs : X * (d⁄dX R) ((1 : R⟦X⟧) - X ^ k) = (-(k : R)) • (X : R⟦X⟧) ^ k := by
    rw [map_sub, hd1, PowerSeries.derivative_pow, PowerSeries.derivative_X, smul_eq_C_mul,
      show (X : R⟦X⟧) * (0 - (k : R⟦X⟧) * X ^ (k - 1) * 1)
        = -((k : R⟦X⟧) * (X * X ^ (k - 1))) by ring, ← pow_succ', Nat.sub_add_cancel hk]
    simp
  have hrhs : ((1 : R⟦X⟧) - X ^ k) * ((-(k : R)) • geomPow R k)
      = (-(k : R)) • (X : R⟦X⟧) ^ k := by
    rw [mul_smul_comm, oneSub_mul_geomPow hk]
  unfold HasLogDeriv
  rw [hu, hlhs, hrhs]

/-! ## 3. The log-derivative of a truncated eta quotient -/

/-- The frame-shape divisor sum `σ_a(r) = ∑_{d ∣ r} d · b d`, where
`b d = ∑_{k ∣ d} a k` is `MoonshineHeadTable.divSum`.  This is the coefficient
sequence of the logarithmic derivative of the eta quotient. -/
def sigmaFrame (a : ℕ → ℤ) (r : ℕ) : ℤ := ∑ d ∈ r.divisors, (d : ℤ) * divSum a d

theorem sigmaFrame_one (a : ℕ → ℤ) : sigmaFrame a 1 = divSum a 1 := by
  simp [sigmaFrame]

theorem sigmaFrame_two (a : ℕ → ℤ) : sigmaFrame a 2 = divSum a 1 + 2 * divSum a 2 := by
  have h : (2 : ℕ).divisors = {1, 2} := by decide
  simp [sigmaFrame, h]

theorem sigmaFrame_three (a : ℕ → ℤ) : sigmaFrame a 3 = divSum a 1 + 3 * divSum a 3 := by
  have h : (3 : ℕ).divisors = {1, 3} := by decide
  simp [sigmaFrame, h]

variable (R) in
/-- The logarithmic derivative of the truncated eta quotient. -/
noncomputable def logDerivEta (a : ℕ → ℤ) (M : ℕ) : R⟦X⟧ :=
  ∑ m ∈ Finset.range M, ((divSum a (m + 1) * (m + 1) : ℤ) : R) • geomPow R (m + 1)

theorem hasLogDeriv_etaPartial (a : ℕ → ℤ) (M : ℕ) :
    HasLogDeriv (etaPartial R a M) (logDerivEta R a M) := by
  rw [etaPartial, logDerivEta]
  refine hasLogDeriv_prod _ _ _ (fun m _ => ?_)
  have hfac : HasLogDeriv (oneSubXPowUnit R m) ((-((m + 1 : ℕ) : R)) • geomPow R (m + 1)) :=
    hasLogDeriv_oneSubXPow (by omega) _ (val_oneSubXPowUnit m)
  have h := hfac.zpow (-(divSum a (m + 1)))
  convert h using 1
  rw [smul_smul]
  congr 1
  push_cast
  ring

/-- The coefficients of the logarithmic derivative are the frame-shape divisor
sums, as soon as the truncation `M` is at least `r`. -/
theorem coeff_logDerivEta (a : ℕ → ℤ) {r M : ℕ} (hr : 0 < r) (hrM : r ≤ M) :
    coeff r (logDerivEta R a M) = ((sigmaFrame a r : ℤ) : R) := by
  classical
  rw [logDerivEta, map_sum]
  have hterm : ∀ m ∈ Finset.range M,
      coeff r (((divSum a (m + 1) * (m + 1) : ℤ) : R) • geomPow R (m + 1))
        = if (m + 1) ∣ r then (((((m + 1 : ℕ) : ℤ) * divSum a (m + 1) : ℤ)) : R) else 0 := by
    intro m _
    rw [map_smul, coeff_geomPow]
    by_cases hd : (m + 1) ∣ r
    · rw [if_pos ⟨hd, hr⟩, if_pos hd, smul_eq_mul, mul_one]
      push_cast
      ring
    · rw [if_neg (fun h => hd h.1), if_neg hd, smul_zero]
  rw [Finset.sum_congr rfl hterm, sigmaFrame, ← Finset.sum_filter, Int.cast_sum]
  refine Finset.sum_nbij' (i := fun m => m + 1) (j := fun d => d - 1) ?_ ?_ ?_ ?_ ?_
  · intro m hm
    simp only [Finset.mem_filter, Finset.mem_range] at hm
    exact Nat.mem_divisors.mpr ⟨hm.2, by omega⟩
  · intro d hd
    rw [Nat.mem_divisors] at hd
    have hd1 : 1 ≤ d := Nat.one_le_iff_ne_zero.mpr (by rintro rfl; simp at hd)
    have hdr : d ≤ r := Nat.le_of_dvd hr hd.1
    simp only [Finset.mem_filter, Finset.mem_range]
    refine ⟨by omega, ?_⟩
    rw [Nat.sub_add_cancel hd1]
    exact hd.1
  · intro m _
    simp
  · intro d hd
    rw [Nat.mem_divisors] at hd
    have hd1 : 1 ≤ d := Nat.one_le_iff_ne_zero.mpr (by rintro rfl; simp at hd)
    show d - 1 + 1 = d
    omega
  · intro m _
    rfl

@[simp] theorem constantCoeff_logDerivEta (a : ℕ → ℤ) (M : ℕ) :
    constantCoeff (logDerivEta R a M) = 0 := by
  rw [logDerivEta, map_sum]
  refine Finset.sum_eq_zero (fun m _ => ?_)
  rw [← PowerSeries.coeff_zero_eq_constantCoeff_apply, map_smul, coeff_geomPow,
    if_neg (by simp), smul_zero]

/-! ## 4. The Newton recursion -/

/-- **The Newton recursion for eta quotients.**  For every degree `r ≥ 1` and every
truncation `M ≥ r`,

`r · c_r = ∑_{k < r} c_k · σ_a(r - k)`,

where `c_k` is the `k`-th coefficient of the truncated eta quotient attached to the
frame shape `a`.  Together with `c_0 = 1` this determines *all* coefficients from
the frame shape. -/
theorem newton_recursion (a : ℕ → ℤ) {r M : ℕ} (hr : 0 < r) (hrM : r ≤ M) :
    (r : R) * coeff r ((etaPartial R a M : (R⟦X⟧)ˣ) : R⟦X⟧) =
      ∑ k ∈ Finset.range r,
        coeff k ((etaPartial R a M : (R⟦X⟧)ˣ) : R⟦X⟧) * ((sigmaFrame a (r - k) : ℤ) : R) := by
  obtain ⟨s, rfl⟩ : ∃ s, r = s + 1 := ⟨r - 1, by omega⟩
  have hlog := hasLogDeriv_etaPartial (R := R) a M
  unfold HasLogDeriv at hlog
  have hL := congrArg (coeff (s + 1)) hlog
  rw [PowerSeries.coeff_succ_X_mul, PowerSeries.coeff_derivative, PowerSeries.coeff_mul,
    Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk, Finset.sum_range_succ,
    Nat.sub_self] at hL
  rw [PowerSeries.coeff_zero_eq_constantCoeff_apply, constantCoeff_logDerivEta, mul_zero,
    add_zero] at hL
  have hterms : ∀ k ∈ Finset.range (s + 1),
      coeff k ((etaPartial R a M : (R⟦X⟧)ˣ) : R⟦X⟧) * coeff (s + 1 - k) (logDerivEta R a M)
        = coeff k ((etaPartial R a M : (R⟦X⟧)ˣ) : R⟦X⟧)
            * ((sigmaFrame a (s + 1 - k) : ℤ) : R) := by
    intro k hk
    rw [Finset.mem_range] at hk
    rw [coeff_logDerivEta a (by omega) (by omega)]
  rw [Finset.sum_congr rfl hterms] at hL
  rw [← hL]
  push_cast
  ring

/-! ## 5. The first three instances, cross-checked against cycles 3 and 6 -/

@[simp] theorem constantCoeff_etaPartial (a : ℕ → ℤ) (M : ℕ) :
    constantCoeff ((etaPartial R a M : (R⟦X⟧)ˣ) : R⟦X⟧) = 1 := by
  rw [val_etaPartial]
  exact constantCoeff_prod_one _ _ (fun m _ => constantCoeff_etaFactor a m)

/-- Degree `1` instance of the recursion: `c₁ = b₁ = a 1`. -/
theorem coeff_one_recursion (a : ℕ → ℤ) {M : ℕ} (hM : 1 ≤ M) :
    coeff 1 ((etaPartial R a M : (R⟦X⟧)ˣ) : R⟦X⟧) = ((divSum a 1 : ℤ) : R) := by
  have h := newton_recursion (R := R) a (r := 1) one_pos hM
  rw [Finset.sum_range_one, PowerSeries.coeff_zero_eq_constantCoeff_apply,
    constantCoeff_etaPartial, one_mul] at h
  simpa [sigmaFrame_one] using h

/-- Degree `2` instance of the recursion: `2 c₂ = b₁² + b₁ + 2 b₂`. -/
theorem two_mul_coeff_two_recursion (a : ℕ → ℤ) {M : ℕ} (hM : 2 ≤ M) :
    2 * coeff 2 ((etaPartial R a M : (R⟦X⟧)ˣ) : R⟦X⟧)
      = ((divSum a 1 ^ 2 + divSum a 1 + 2 * divSum a 2 : ℤ) : R) := by
  have h := newton_recursion (R := R) a (r := 2) (by norm_num) hM
  rw [Finset.sum_range_succ, Finset.sum_range_one,
    PowerSeries.coeff_zero_eq_constantCoeff_apply, constantCoeff_etaPartial, one_mul,
    coeff_one_recursion a (by omega)] at h
  rw [show (2 : ℕ) - 0 = 2 from rfl, show (2 : ℕ) - 1 = 1 from rfl, sigmaFrame_one,
    sigmaFrame_two] at h
  push_cast at h ⊢
  linear_combination h

/-- **Independent re-derivation of the cycle-3 head formula.**  The degree-`2`
instance of the Newton recursion gives back `MoonshineHeadTable.headCoeff`, by a
proof that shares no step with the original `2`-jet computation. -/
theorem coeff_two_etaPartial_via_recursion (a : ℕ → ℤ) {M : ℕ} (hM : 2 ≤ M) :
    coeff 2 ((etaPartial ℤ a M : (ℤ⟦X⟧)ˣ) : ℤ⟦X⟧) = headCoeff a := by
  have h := two_mul_coeff_two_recursion (R := ℤ) a hM
  rw [Int.cast_id] at h
  have h2 := two_mul_headCoeff a
  have hb2 : divSum a 2 = a 1 + a 2 := divSum_two a
  have hb1 : divSum a 1 = a 1 := divSum_one a
  rw [hb1, hb2] at h
  linarith

/-- Degree `3` instance of the recursion, multiplied by `6`. -/
theorem six_mul_coeff_three_recursion (a : ℕ → ℤ) {M : ℕ} (hM : 3 ≤ M) :
    6 * coeff 3 ((etaPartial R a M : (R⟦X⟧)ˣ) : R⟦X⟧)
      = ((divSum a 1 * (divSum a 1 + 1) * (divSum a 1 + 2)
            + 6 * divSum a 1 * divSum a 2 + 6 * divSum a 3 : ℤ) : R) := by
  have h := newton_recursion (R := R) a (r := 3) (by norm_num) hM
  rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    PowerSeries.coeff_zero_eq_constantCoeff_apply, constantCoeff_etaPartial, one_mul,
    coeff_one_recursion a (by omega)] at h
  rw [show (3 : ℕ) - 0 = 3 from rfl, show (3 : ℕ) - 1 = 2 from rfl,
    show (3 : ℕ) - 2 = 1 from rfl, sigmaFrame_one, sigmaFrame_two, sigmaFrame_three] at h
  have h2 := two_mul_coeff_two_recursion (R := R) (M := M) a (by omega)
  push_cast at h h2 ⊢
  linear_combination 2 * h + ((divSum a 1 : ℤ) : R) * h2

/-- **Independent re-derivation of the cycle-6 second head formula.**  The degree-`3`
instance of the Newton recursion gives back `MoonshineSecondHead.secondHeadCoeff`.
Together with `coeff_two_etaPartial_via_recursion` this is a genuine consistency
check on the two earlier jet computations. -/
theorem coeff_three_etaPartial_via_recursion (a : ℕ → ℤ) {M : ℕ} (hM : 3 ≤ M) :
    coeff 3 ((etaPartial ℤ a M : (ℤ⟦X⟧)ˣ) : ℤ⟦X⟧) = secondHeadCoeff a := by
  have h := six_mul_coeff_three_recursion (R := ℤ) a hM
  rw [Int.cast_id] at h
  have h6 := six_mul_secondHeadCoeff a
  linarith

/-! ## 6. Truncation stability in every degree -/

/-- **All coefficients are truncation-stable.**  Over `ℤ`, the `r`-th coefficient of
the truncated eta quotient does not depend on the truncation `M ≥ r`, so it is an
honest coefficient of the infinite product `∏_{m ≥ 1} (1 - qᵐ)^(-b m)`.  Cycle 3
proved this for `r = 2` by hand; the Newton recursion gives it for all `r` at once,
by strong induction. -/
theorem coeff_etaPartial_stable (a : ℕ → ℤ) (r : ℕ) :
    ∀ M N : ℕ, r ≤ M → r ≤ N →
      coeff r ((etaPartial ℤ a M : (ℤ⟦X⟧)ˣ) : ℤ⟦X⟧)
        = coeff r ((etaPartial ℤ a N : (ℤ⟦X⟧)ˣ) : ℤ⟦X⟧) := by
  induction r using Nat.strong_induction_on with
  | _ r ih =>
    intro M N hM hN
    rcases Nat.eq_zero_or_pos r with rfl | hr
    · rw [PowerSeries.coeff_zero_eq_constantCoeff_apply,
        PowerSeries.coeff_zero_eq_constantCoeff_apply, constantCoeff_etaPartial,
        constantCoeff_etaPartial]
    · have hMrec := newton_recursion (R := ℤ) a hr hM
      have hNrec := newton_recursion (R := ℤ) a hr hN
      simp only [Int.cast_id] at hMrec hNrec
      have hsum : ∀ k ∈ Finset.range r,
          coeff k ((etaPartial ℤ a M : (ℤ⟦X⟧)ˣ) : ℤ⟦X⟧) * sigmaFrame a (r - k)
            = coeff k ((etaPartial ℤ a N : (ℤ⟦X⟧)ˣ) : ℤ⟦X⟧) * sigmaFrame a (r - k) := by
        intro k hk
        rw [Finset.mem_range] at hk
        rw [ih k hk M N (by omega) (by omega)]
      rw [Finset.sum_congr rfl hsum, ← hNrec] at hMrec
      have hr0 : ((r : ℤ)) ≠ 0 := by exact_mod_cast (by omega : r ≠ 0)
      exact mul_left_cancel₀ hr0 hMrec

/-! ## 7. A new column: the third head coefficient `c_g(3)`

The recursion now pays for itself: the *fourth* coefficient, which by the jet method
of cycles 3 and 6 would have required a full `4`-jet of `u ^ z`, is obtained by one
more instance of `newton_recursion`. -/

/-- `24 · c₃` as a polynomial in the frame-shape divisor sums. -/
def thirdHeadCoeff24 (a : ℕ → ℤ) : ℤ :=
  6 * sigmaFrame a 4 + 6 * divSum a 1 * sigmaFrame a 3
    + 3 * (divSum a 1 ^ 2 + divSum a 1 + 2 * divSum a 2) * sigmaFrame a 2
    + divSum a 1 * (divSum a 1 * (divSum a 1 + 1) * (divSum a 1 + 2)
        + 6 * divSum a 1 * divSum a 2 + 6 * divSum a 3)

/-- Degree `4` instance of the recursion, multiplied by `24`. -/
theorem twentyFour_mul_coeff_four_recursion (a : ℕ → ℤ) {M : ℕ} (hM : 4 ≤ M) :
    24 * coeff 4 ((etaPartial R a M : (R⟦X⟧)ˣ) : R⟦X⟧) = ((thirdHeadCoeff24 a : ℤ) : R) := by
  have h := newton_recursion (R := R) a (r := 4) (by norm_num) hM
  rw [Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one,
    PowerSeries.coeff_zero_eq_constantCoeff_apply, constantCoeff_etaPartial, one_mul,
    coeff_one_recursion a (by omega)] at h
  rw [show (4 : ℕ) - 0 = 4 from rfl, show (4 : ℕ) - 1 = 3 from rfl,
    show (4 : ℕ) - 2 = 2 from rfl, show (4 : ℕ) - 3 = 1 from rfl, sigmaFrame_one] at h
  have h2 := two_mul_coeff_two_recursion (R := R) (M := M) a (by omega)
  have h3 := six_mul_coeff_three_recursion (R := R) (M := M) a (by omega)
  rw [thirdHeadCoeff24]
  push_cast at h h2 h3 ⊢
  linear_combination 6 * h + 3 * ((sigmaFrame a 2 : ℤ) : R) * h2 + ((divSum a 1 : ℤ) : R) * h3

/-- **The derived third column** of the head table, for the eight balanced frame
shapes `1^(-e) n^(e)`. -/
def etaThirdHeadTable : Fin 8 → ℤ := ![11202, -243, -62, -30, -5, 0, 1, 0]

/-- Each entry of the third column really is the fourth coefficient of the
corresponding eta quotient. -/
theorem coeff_four_etaPartial_pmFrame (i : Fin 8) {M : ℕ} (hM : 4 ≤ M) :
    coeff 4 ((etaPartial ℤ (pmFrame (pmData i).1 (pmData i).2) M : (ℤ⟦X⟧)ˣ) : ℤ⟦X⟧)
      = etaThirdHeadTable i := by
  have h := twentyFour_mul_coeff_four_recursion (R := ℤ)
    (pmFrame (pmData i).1 (pmData i).2) hM
  rw [Int.cast_id] at h
  have h24 : thirdHeadCoeff24 (pmFrame (pmData i).1 (pmData i).2)
      = 24 * etaThirdHeadTable i := by
    fin_cases i <;>
      (simp only [etaThirdHeadTable, pmData, thirdHeadCoeff24, sigmaFrame, divSum, pmFrame]; decide)
  omega

/-- The sum of the third column is `10863`. -/
theorem sum_etaThirdHeadTable : ∑ i, etaThirdHeadTable i = 10863 := by
  simp only [etaThirdHeadTable]
  decide

/-- The sum of squares of the first head column, needed for the `e₂` correction at
the boundary of the stable range. -/
theorem sum_sq_etaHeadTable : ∑ i, (etaHeadTable i) ^ 2 = 79579 := by
  rw [etaHeadTable_values]
  decide

/-- **A worked instance outside the stable range.**  For eight normalized
McKay–Thompson series whose first and third head coefficients are the derived
columns, the eight-fold product has Laurent coefficient `35514` in degree `-4`.
This is the first degree where the elementary symmetric correction `e₂` of
`NumberTheory.MoonshineFiniteReduction` actually contributes, and the third column
supplied by the Newton recursion is exactly the missing input. -/
theorem two_mul_coeff_prod_mtSeries_head_four (m : ℕ) (c : Fin m → ℕ → ℤ)
    (h0 : ∀ i, c i 0 = 0) :
    2 * (∏ i, mtSeries (c i)).coeff (4 - (m : ℤ)) =
      2 * (∑ i, (mtSeries (c i)).coeff (3 : ℤ)) + (∑ i, (mtSeries (c i)).coeff (1 : ℤ)) ^ 2
        - ∑ i, ((mtSeries (c i)).coeff (1 : ℤ)) ^ 2 := by
  have hcard : (Finset.univ : Finset (Fin m)).card = m := by simp
  have h := two_mul_coeff_prod_normalized_head_four (Finset.univ : Finset (Fin m))
    (fun i => mtSeries (c i)) (fun i _ => isNormalized_mtSeries (c i))
    (fun i _ => by rw [coeff_zero_mtSeries, h0 i]; norm_num)
  rwa [hcard] at h

theorem coeff_prod_etaClasses_third (c : Fin 8 → ℕ → ℤ) (h0 : ∀ i, c i 0 = 0)
    (h1 : ∀ i, c i 1 = etaHeadTable i) (h3 : ∀ i, c i 3 = etaThirdHeadTable i) :
    (∏ i, mtSeries (c i)).coeff (-4 : ℤ) = (35514 : ℂ) := by
  have h := two_mul_coeff_prod_mtSeries_head_four 8 c h0
  rw [show (4 - ((8 : ℕ) : ℤ)) = (-4 : ℤ) by norm_num] at h
  have e3 : ∀ i : Fin 8, (mtSeries (c i)).coeff (3 : ℤ) = ((etaThirdHeadTable i : ℤ) : ℂ) := by
    intro i
    have := coeff_succ_mtSeries (c i) 2
    norm_num at this
    rw [this, h3 i]
  have e1 : ∀ i : Fin 8, (mtSeries (c i)).coeff (1 : ℤ) = ((etaHeadTable i : ℤ) : ℂ) := by
    intro i
    rw [coeff_one_mtSeries, h1 i]
  rw [Finset.sum_congr rfl (fun i _ => e3 i), Finset.sum_congr rfl (fun i _ => e1 i),
    Finset.sum_congr rfl (fun i _ => by rw [e1 i] :
      ∀ i ∈ (Finset.univ : Finset (Fin 8)), ((mtSeries (c i)).coeff (1 : ℤ)) ^ 2
        = (((etaHeadTable i : ℤ) : ℂ)) ^ 2)] at h
  have s3 : ∑ i, ((etaThirdHeadTable i : ℤ) : ℂ) = ((10863 : ℤ) : ℂ) := by
    rw [← Int.cast_sum, sum_etaThirdHeadTable]
  have s1 : ∑ i, ((etaHeadTable i : ℤ) : ℂ) = ((359 : ℤ) : ℂ) := by
    rw [← Int.cast_sum, sum_etaHeadTable]
  have s2 : ∑ i, (((etaHeadTable i : ℤ) : ℂ)) ^ 2 = ((79579 : ℤ) : ℂ) := by
    rw [Finset.sum_congr rfl (fun i _ => by push_cast; ring :
        ∀ i ∈ (Finset.univ : Finset (Fin 8)), (((etaHeadTable i : ℤ) : ℂ)) ^ 2
          = (((etaHeadTable i ^ 2 : ℤ)) : ℂ)), ← Int.cast_sum, sum_sq_etaHeadTable]
  rw [s3, s1, s2] at h
  norm_num at h
  linear_combination h / 2

/-!
## Lab notes (cycle 7)

Running the recursion `r c_r = ∑_{k < r} c_k σ_a(r-k)` on the eight balanced frame
shapes `1^(-e) n^(e)`, `e (n-1) = 24`, produces the following head block
(`c₀, c₁, c₂, c₃, c₄` of `q · (1/η_g) = ∏_m (1 - qᵐ)^(-b m)`):

```
 n    e   c0    c1     c2      c3      c4
 2   24    1   -24    276   -2048   11202
 3   12    1   -12     54     -76    -243
 4    8    1    -8     20       0     -62
 5    6    1    -6      9      10     -30
 7    4    1    -4      2       8      -5
 9    3    1    -3      0       5       0
13    2    1    -2     -1       2       1
25    1    1    -1     -1       0       0
```

Column `c₂` reproduces `MoonshineHeadTable.etaHeadTable_values` (sum `359`) and
column `c₃` reproduces `MoonshineSecondHead.etaSecondHeadTable_values` (sum `-2099`);
both were obtained in cycles 3 and 6 by *independent* jet computations, and the
agreement is now a theorem (`coeff_two_etaPartial_via_recursion`,
`coeff_three_etaPartial_via_recursion`).  Column `c₄` is new
(`etaThirdHeadTable`, sum `10863`, `sum_etaThirdHeadTable`).

Note the two sign patterns: `c₁ = -e` is always negative, while the higher columns
change sign, and for the small-exponent shapes `n = 9, 13, 25` the block is almost
entirely `0, ±1, ±2`.  This is the numerical shadow of the lower bound
`MoonshineHeadTable.headCoeff_pmFrame_ge_neg_one`.
-/

end MoonshineNewtonRecursion