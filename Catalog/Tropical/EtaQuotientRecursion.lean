import Tropical.EtaQuotientHeadCoeff

/-!
# All coefficients of a normalised eta quotient: the logarithmic-derivative recursion

`Tropical.EtaQuotientHeadCoeff` computes the coefficient of `q²` of
`F = ∏_{m=1}^{N} (1 - X^m)^{-b m}` (the head coefficient `c(1)` of the eta quotient)
by a hands-on `2`-jet calculus, and `Tropical.EtaQuotientSecondCoeff` does the same
in degree `3`.  Those arguments are degree-by-degree and do not scale.

This file replaces them by a *uniform* statement valid in **every** degree.  Writing
`d⁄dX` for the formal derivative and

  `logD u = X · u' · u⁻¹`   (`u` a unit of `ℤ⟦X⟧`),

the map `logD` is a homomorphism from the (multiplicative) group of units of `ℤ⟦X⟧`
to its (additive) group.  Applied to the eta quotient it gives

  `logD F = ∑_{m=1}^{N} (m · b m) · X^m/(1 - X^m)`,

whose `j`-th coefficient is the *twisted divisor sum*

  `σ_b(j) = ∑_{m ∣ j, m ≤ N} m · b m`.

Comparing coefficients in `F · logD F = X · F'` yields the main theorem
`coeff_recursion`,

  `n · [q^n] F = ∑_{i < n} [q^i] F · σ_b(n - i)`,

a complete recursion determining every coefficient of the eta quotient from the
divisor data `b`.  As independent cross-checks we re-derive `c(0) = a₁`
(`coeff_one_via_recursion`) and the head coefficient `c(1) = a₁(a₁+3)/2 + a₂`
(`coeff_two_via_recursion`) by a route sharing no lemma with the jet calculus,
and we deduce the classical `324` for `1/Δ`.

The recursion also produces new structural information: `sigmaB_add` shows that
`σ_b` is *additive* in `a`, in contrast with the Heisenberg cocycle satisfied by the
head coefficient itself; this additivity is the linearisation that underlies the
whole tower of head coefficients.
-/

namespace EtaHead

open PowerSeries Finset

/-! ## The logarithmic derivative on units of `ℤ⟦X⟧` -/

/-- The logarithmic derivative `logD u = X · u' · u⁻¹` of a unit of `ℤ⟦X⟧`.
The factor `X` makes it the *Euler operator* `q d/dq`, which is what turns
products of `(1 - q^m)` into divisor sums. -/
noncomputable def logD (u : (PowerSeries ℤ)ˣ) : PowerSeries ℤ :=
  X * (d⁄dX ℤ) (u : PowerSeries ℤ) * ((u⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)

lemma val_mul_logD (u : (PowerSeries ℤ)ˣ) :
    (u : PowerSeries ℤ) * logD u = X * (d⁄dX ℤ) (u : PowerSeries ℤ) := by
  have h : (u : PowerSeries ℤ) * ((u⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = 1 := u.mul_inv
  unfold logD
  linear_combination (X * (d⁄dX ℤ) (u : PowerSeries ℤ)) * h

@[simp] lemma logD_one : logD 1 = 0 := by
  simp [logD]

/-- `logD` turns the multiplicative group of units of `ℤ⟦X⟧` into an additive group. -/
lemma logD_mul (u v : (PowerSeries ℤ)ˣ) : logD (u * v) = logD u + logD v := by
  have hu : (u : PowerSeries ℤ) * ((u⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = 1 := u.mul_inv
  have hv : (v : PowerSeries ℤ) * ((v⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = 1 := v.mul_inv
  have hleib : (d⁄dX ℤ) ((u : PowerSeries ℤ) * (v : PowerSeries ℤ))
      = (u : PowerSeries ℤ) * (d⁄dX ℤ) (v : PowerSeries ℤ)
        + (v : PowerSeries ℤ) * (d⁄dX ℤ) (u : PowerSeries ℤ) := by
    simp
  unfold logD
  rw [mul_inv_rev, Units.val_mul, Units.val_mul, hleib]
  linear_combination
    (X * (d⁄dX ℤ) (v : PowerSeries ℤ) * ((v⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)) * hu
      + (X * (d⁄dX ℤ) (u : PowerSeries ℤ) * ((u⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)) * hv

lemma logD_inv (u : (PowerSeries ℤ)ˣ) : logD u⁻¹ = - logD u := by
  have h := logD_mul u u⁻¹
  rw [mul_inv_cancel, logD_one] at h
  linear_combination -h

lemma logD_zpow (u : (PowerSeries ℤ)ˣ) (n : ℤ) : logD (u ^ n) = n • logD u := by
  induction n using Int.induction_on with
  | zero => simp
  | succ k ih => rw [zpow_add_one, logD_mul, ih]; module
  | pred k ih => rw [zpow_sub_one, logD_mul, logD_inv, ih]; module

lemma logD_prod {ι : Type*} [DecidableEq ι] (s : Finset ι) (f : ι → (PowerSeries ℤ)ˣ) :
    logD (∏ i ∈ s, f i) = ∑ i ∈ s, logD (f i) := by
  induction s using Finset.induction with
  | empty => simp
  | insert i s hi ih => rw [Finset.prod_insert hi, Finset.sum_insert hi, logD_mul, ih]

/-! ## The geometric series `1/(1 - X^m)` -/

/-- The explicit inverse of `1 - X^m`: the series `∑_{k ≥ 0} X^{mk}`. -/
noncomputable def geomSeries (m : ℕ) : PowerSeries ℤ :=
  PowerSeries.mk fun n => if m ∣ n then 1 else 0

lemma one_sub_X_pow_mul_geomSeries {m : ℕ} (hm : 1 ≤ m) :
    (1 - X ^ m : PowerSeries ℤ) * geomSeries m = 1 := by
  ext n
  rw [PowerSeries.coeff_mul, Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk]
  have hterm : ∀ k ∈ range (n + 1),
      coeff k (1 - X ^ m : PowerSeries ℤ) * coeff (n - k) (geomSeries m)
        = (if k = 0 then (if m ∣ n then (1:ℤ) else 0) else 0)
          - (if k = m then (if m ∣ (n - m) then (1:ℤ) else 0) else 0) := by
    intro k _
    rw [coeff_one_sub_X_pow, geomSeries, PowerSeries.coeff_mk]
    rcases eq_or_ne k 0 with rfl | hk0
    · have hm0 : ¬ ((0:ℕ) = m) := by omega
      rw [if_pos rfl, if_neg hm0, if_pos rfl, if_neg hm0]
      simp
    · rcases eq_or_ne k m with rfl | hkm
      · rw [if_neg hk0, if_pos rfl, if_neg hk0, if_pos rfl]
        ring
      · rw [if_neg hk0, if_neg hkm, if_neg hk0, if_neg hkm]
        ring
  rw [Finset.sum_congr rfl hterm, Finset.sum_sub_distrib,
    Finset.sum_ite_eq' (range (n+1)) 0, Finset.sum_ite_eq' (range (n+1)) m]
  simp only [Finset.mem_range]
  rw [if_pos (show 0 < n + 1 by omega)]
  rcases Nat.eq_zero_or_pos n with hn | hn
  · subst hn
    rw [if_neg (show ¬ (m < 0 + 1) by omega)]
    simp
  · have hcoeff : coeff n (1 : PowerSeries ℤ) = 0 := by
      rw [PowerSeries.coeff_one, if_neg (show ¬ (n = 0) by omega)]
    rw [hcoeff]
    by_cases hmn : m < n + 1
    · rw [if_pos hmn]
      have hd : (m ∣ n) ↔ (m ∣ (n - m)) := by
        constructor
        · intro h; exact Nat.dvd_sub h dvd_rfl
        · intro h
          have hback : m ∣ (n - m) + m := Nat.dvd_add h dvd_rfl
          have he : n - m + m = n := by omega
          rwa [he] at hback
      by_cases hdd : m ∣ n
      · rw [if_pos hdd, if_pos (hd.mp hdd)]; ring
      · rw [if_neg hdd, if_neg (fun h => hdd (hd.mpr h))]; ring
    · rw [if_neg hmn, if_neg (show ¬ (m ∣ n) from fun h =>
        absurd (Nat.le_of_dvd hn h) (by omega))]
      ring

lemma inv_oneSubXPow_eq_geomSeries {m : ℕ} (hm : 1 ≤ m) :
    (((oneSubXPow m)⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = geomSeries m := by
  have h : ((oneSubXPow m : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
      * (((oneSubXPow m)⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = 1 := (oneSubXPow m).mul_inv
  rw [coe_oneSubXPow hm] at h
  have h2 := one_sub_X_pow_mul_geomSeries hm
  calc (((oneSubXPow m)⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
      = ((1 - X ^ m : PowerSeries ℤ) * geomSeries m)
          * (((oneSubXPow m)⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by rw [h2]; ring
    _ = geomSeries m * ((1 - X ^ m : PowerSeries ℤ)
          * (((oneSubXPow m)⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)) := by ring
    _ = geomSeries m := by rw [h]; ring

/-- The *geometric tail* `X^m / (1 - X^m) = X^m + X^{2m} + X^{3m} + ⋯`. -/
noncomputable def geomTail (m : ℕ) : PowerSeries ℤ :=
  X ^ m * (((oneSubXPow m)⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)

lemma coeff_geomTail {m : ℕ} (hm : 1 ≤ m) (n : ℕ) :
    coeff n (geomTail m) = if m ∣ n ∧ m ≤ n then 1 else 0 := by
  rw [geomTail, inv_oneSubXPow_eq_geomSeries hm, PowerSeries.coeff_X_pow_mul']
  by_cases hmn : m ≤ n
  · rw [if_pos hmn, geomSeries, PowerSeries.coeff_mk]
    have hd : (m ∣ n - m) ↔ (m ∣ n) := by
      constructor
      · intro h
        have hback : m ∣ (n - m) + m := Nat.dvd_add h dvd_rfl
        have he : n - m + m = n := by omega
        rwa [he] at hback
      · intro h; exact Nat.dvd_sub h dvd_rfl
    by_cases hdd : m ∣ n
    · rw [if_pos (hd.mpr hdd), if_pos ⟨hdd, hmn⟩]
    · rw [if_neg (fun h => hdd (hd.mp h)), if_neg (by tauto)]
  · rw [if_neg hmn, if_neg (by tauto)]

/-- `logD (1 - X^m) = - m · X^m/(1 - X^m)`: the basic input of the recursion. -/
lemma logD_oneSubXPow {m : ℕ} (hm : 1 ≤ m) :
    logD (oneSubXPow m) = -((m : ℤ) • geomTail m) := by
  have hd : (d⁄dX ℤ) ((oneSubXPow m : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
      = -((m : ℤ) • (X : PowerSeries ℤ) ^ (m - 1)) := by
    rw [coe_oneSubXPow hm]
    simp [Derivation.leibniz_pow]
  have hX : (X : PowerSeries ℤ) * (X : PowerSeries ℤ) ^ (m - 1) = (X : PowerSeries ℤ) ^ m := by
    rw [← pow_succ']
    congr 1
    omega
  rw [logD, hd, geomTail]
  simp only [zsmul_eq_mul]
  rw [← hX]
  ring

/-! ## The twisted divisor sum -/

/-- The twisted divisor sum `σ_b(j) = ∑_{m ∣ j, 1 ≤ m ≤ N} m · b m`. -/
def sigmaB (a : ℕ → ℤ) (N j : ℕ) : ℤ :=
  ∑ m ∈ (Icc 1 N).filter (fun m => m ∣ j), (m : ℤ) * bCoeff a m

/-- Unlike the head coefficient (which satisfies a Heisenberg cocycle rule),
the twisted divisor sums are *additive* in the exponent vector `a`. -/
theorem sigmaB_add (a a' : ℕ → ℤ) (N j : ℕ) :
    sigmaB (a + a') N j = sigmaB a N j + sigmaB a' N j := by
  unfold sigmaB
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun m _ => ?_
  have hb : bCoeff (a + a') m = bCoeff a m + bCoeff a' m := by
    unfold bCoeff
    rw [← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun k _ => rfl
  rw [hb]; ring

lemma sigmaB_one (a : ℕ → ℤ) {N : ℕ} (hN : 1 ≤ N) : sigmaB a N 1 = a 1 := by
  unfold sigmaB
  have hfil : (Icc 1 N).filter (fun m => m ∣ 1) = {1} := by
    ext m
    simp only [Finset.mem_filter, Finset.mem_Icc, Finset.mem_singleton]
    constructor
    · rintro ⟨_, hd⟩; exact Nat.dvd_one.mp hd
    · rintro rfl; exact ⟨⟨le_refl 1, hN⟩, dvd_rfl⟩
  rw [hfil, Finset.sum_singleton, bCoeff_one]
  norm_num

lemma sigmaB_two (a : ℕ → ℤ) {N : ℕ} (hN : 2 ≤ N) :
    sigmaB a N 2 = 3 * a 1 + 2 * a 2 := by
  unfold sigmaB
  have hfil : (Icc 1 N).filter (fun m => m ∣ 2) = {1, 2} := by
    ext m
    simp only [Finset.mem_filter, Finset.mem_Icc, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · rintro ⟨⟨hm1, _⟩, hd⟩
      have hle : m ≤ 2 := Nat.le_of_dvd (by norm_num) hd
      interval_cases m
      · exact Or.inl rfl
      · exact Or.inr rfl
    · rintro (rfl | rfl)
      · exact ⟨⟨le_refl 1, by omega⟩, one_dvd 2⟩
      · exact ⟨⟨by omega, hN⟩, dvd_rfl⟩
  rw [hfil, Finset.sum_insert (by decide), Finset.sum_singleton, bCoeff_one, bCoeff_two]
  push_cast
  ring

/-! ## The logarithmic derivative of the eta quotient -/

/-- `logD F = ∑_{m=1}^{N} (m · b m) · X^m/(1 - X^m)`. -/
theorem logD_etaQuotientProd (a : ℕ → ℤ) (N : ℕ) :
    logD (etaQuotientProd a N) = ∑ m ∈ Icc 1 N, ((m : ℤ) * bCoeff a m) • geomTail m := by
  rw [etaQuotientProd, logD_prod]
  refine Finset.sum_congr rfl fun m hm => ?_
  have hm1 : 1 ≤ m := (Finset.mem_Icc.mp hm).1
  rw [logD_zpow, logD_oneSubXPow hm1]
  module

lemma coeff_logD_etaQuotientProd (a : ℕ → ℤ) (N : ℕ) {j : ℕ} (hj : 1 ≤ j) :
    coeff j (logD (etaQuotientProd a N)) = sigmaB a N j := by
  rw [logD_etaQuotientProd, map_sum, sigmaB, Finset.sum_filter]
  refine Finset.sum_congr rfl fun m hm => ?_
  have hm1 : 1 ≤ m := (Finset.mem_Icc.mp hm).1
  rw [map_zsmul, smul_eq_mul, coeff_geomTail hm1]
  by_cases hd : m ∣ j
  · have hle : m ≤ j := Nat.le_of_dvd (by omega) hd
    rw [if_pos ⟨hd, hle⟩, if_pos hd]
    ring
  · rw [if_neg (by tauto), if_neg hd]
    ring

@[simp] lemma coeff_zero_logD_etaQuotientProd (a : ℕ → ℤ) (N : ℕ) :
    constantCoeff (logD (etaQuotientProd a N)) = 0 := by
  rw [← coeff_zero_eq_constantCoeff_apply, logD_etaQuotientProd, map_sum]
  refine Finset.sum_eq_zero fun m hm => ?_
  have hm1 : 1 ≤ m := (Finset.mem_Icc.mp hm).1
  rw [map_zsmul, smul_eq_mul, coeff_geomTail hm1,
    if_neg (show ¬ (m ∣ 0 ∧ m ≤ 0) from fun h => by omega)]
  ring

/-! ## The main recursion -/

/-- **Main theorem (all degrees).**  Writing `F = ∏_{m=1}^{N} (1 - X^m)^{-b m}` for the
normalised eta quotient, its coefficients satisfy, for every `n ≥ 1`,

  `n · [q^n] F = ∑_{i < n} [q^i] F · σ_b(n - i)`,

where `σ_b(j) = ∑_{m ∣ j, m ≤ N} m · b m`.  Together with `[q^0] F = 1` this
determines *every* coefficient of the eta quotient from the divisor data `b`. -/
theorem coeff_recursion (a : ℕ → ℤ) (N : ℕ) {n : ℕ} (hn : 1 ≤ n) :
    (n : ℤ) * coeff n ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
      = ∑ i ∈ range n,
          coeff i ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
            * sigmaB a N (n - i) := by
  set F : PowerSeries ℤ := ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) with hF
  set L : PowerSeries ℤ := logD (etaQuotientProd a N) with hL
  have hkey : F * L = X * (d⁄dX ℤ) F := val_mul_logD _
  obtain ⟨n', rfl⟩ : ∃ n', n = n' + 1 := ⟨n - 1, by omega⟩
  have hlhs : coeff (n' + 1) (X * (d⁄dX ℤ) F) = ((n' : ℤ) + 1) * coeff (n' + 1) F := by
    rw [PowerSeries.coeff_succ_X_mul, PowerSeries.coeff_derivative]
    ring
  have hrhs : coeff (n' + 1) (F * L)
      = ∑ i ∈ range (n' + 1), coeff i F * sigmaB a N (n' + 1 - i) := by
    rw [PowerSeries.coeff_mul, Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk,
      Finset.sum_range_succ]
    have hlast : coeff (n' + 1) F * coeff (n' + 1 - (n' + 1)) L = 0 := by
      rw [show n' + 1 - (n' + 1) = 0 by omega, coeff_zero_eq_constantCoeff_apply, hL,
        coeff_zero_logD_etaQuotientProd]
      ring
    rw [hlast, add_zero]
    refine Finset.sum_congr rfl fun i hi => ?_
    have hi' : i < n' + 1 := Finset.mem_range.mp hi
    rw [hL, coeff_logD_etaQuotientProd a N (show 1 ≤ n' + 1 - i by omega)]
  rw [← hkey] at hlhs
  rw [hrhs] at hlhs
  push_cast
  linarith [hlhs]

/-! ## Cross-checks: re-deriving the head coefficients -/

/-- The normalisation `[q^0] F = 1`, proved directly from the fact that `constantCoeff`
is a ring homomorphism (so induces a group homomorphism on units), without any input
from the jet calculus of `Tropical.EtaQuotientHeadCoeff`.  It also holds for every
truncation `N`, with no lower bound. -/
theorem constantCoeff_etaQuotientProd_direct (a : ℕ → ℤ) (N : ℕ) :
    constantCoeff ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = 1 := by
  set φ : PowerSeries ℤ →* ℤ := (constantCoeff : PowerSeries ℤ →+* ℤ).toMonoidHom with hφ
  have key : Units.map φ (etaQuotientProd a N) = 1 := by
    rw [etaQuotientProd, map_prod]
    refine Finset.prod_eq_one fun m hm => ?_
    have hm1 : 1 ≤ m := (Finset.mem_Icc.mp hm).1
    have hc : Units.map φ (oneSubXPow m) = 1 := by
      refine Units.ext ?_
      rw [Units.coe_map, Units.val_one, hφ]
      show constantCoeff ((oneSubXPow m : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = 1
      rw [coe_oneSubXPow hm1, ← coeff_zero_eq_constantCoeff_apply, coeff_one_sub_X_pow,
        if_pos rfl, if_neg (show ¬ ((0:ℕ) = m) by omega)]
      ring
    rw [map_zpow, hc, one_zpow]
  have hval := congrArg Units.val key
  rw [Units.coe_map, Units.val_one, hφ] at hval
  exact hval

/-- `c(0) = a₁`, re-derived from the recursion (independently of the jet calculus). -/
theorem coeff_one_via_recursion (a : ℕ → ℤ) {N : ℕ} (hN : 1 ≤ N) :
    coeff 1 ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = a 1 := by
  have h := coeff_recursion a N (n := 1) (by omega)
  rw [Finset.sum_range_one, coeff_zero_eq_constantCoeff_apply,
    constantCoeff_etaQuotientProd_direct a N] at h
  rw [show (1:ℕ) - 0 = 1 from rfl, sigmaB_one a hN] at h
  push_cast at h
  linarith [h]

/-- **The head coefficient, re-derived.**  `c(1) = a₁(a₁+3)/2 + a₂`, obtained from the
logarithmic-derivative recursion.  This proof shares no lemma with the `2`-jet
computation of `coeff_two_etaQuotientProd`, so the two together form an independent
double check of the head-coefficient formula. -/
theorem coeff_two_via_recursion (a : ℕ → ℤ) {N : ℕ} (hN : 2 ≤ N) :
    coeff 2 ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = headCoeff a := by
  have h := coeff_recursion a N (n := 2) (by omega)
  rw [Finset.sum_range_succ, Finset.sum_range_one] at h
  rw [show (2:ℕ) - 0 = 2 from rfl, show (2:ℕ) - 1 = 1 from rfl] at h
  rw [coeff_zero_eq_constantCoeff_apply, constantCoeff_etaQuotientProd_direct a N,
    sigmaB_one a (by omega), sigmaB_two a hN, coeff_one_via_recursion a (by omega)] at h
  push_cast at h
  have hh : (2:ℤ) * coeff 2 ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
      = 2 * headCoeff a := by
    rw [two_mul_headCoeff]
    linear_combination h
  linarith [hh]

/-- The classical value `c(1) = 324` for `1/Δ = q^{-1} + 24 + 324 q + ⋯`, obtained
from the recursion. -/
theorem coeff_two_delta_via_recursion {N : ℕ} (hN : 2 ≤ N) :
    coeff 2 ((etaQuotientProd (fun k => if k = 1 then 24 else 0) N :
      (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = 324 := by
  rw [coeff_two_via_recursion _ hN]
  norm_num [headCoeff]

/-! ## Stability of the twisted divisor sums -/

/-- For `N ≥ j` the truncation is invisible: `σ_b(j)` is the full divisor sum. -/
theorem sigmaB_eq_divisors (a : ℕ → ℤ) {N j : ℕ} (hj : 1 ≤ j) (hN : j ≤ N) :
    sigmaB a N j = ∑ m ∈ j.divisors, (m : ℤ) * bCoeff a m := by
  unfold sigmaB
  refine Finset.sum_congr ?_ fun _ _ => rfl
  ext m
  simp only [Finset.mem_filter, Finset.mem_Icc, Nat.mem_divisors]
  constructor
  · rintro ⟨_, hd⟩; exact ⟨hd, by omega⟩
  · rintro ⟨hd, _⟩
    have hm1 : 1 ≤ m := Nat.one_le_iff_ne_zero.mpr (by rintro rfl; omega)
    exact ⟨⟨hm1, le_trans (Nat.le_of_dvd (by omega) hd) hN⟩, hd⟩

/-- Consequently the recursion — hence every coefficient — is independent of the
truncation `N` as soon as `N ≥ n`. -/
theorem sigmaB_stable (a : ℕ → ℤ) {N N' j : ℕ} (hj : 1 ≤ j) (hN : j ≤ N) (hN' : j ≤ N') :
    sigmaB a N j = sigmaB a N' j := by
  rw [sigmaB_eq_divisors a hj hN, sigmaB_eq_divisors a hj hN']

end EtaHead