import Tropical.EtaQuotientHeadCoeff

/-!
# Stability of the truncated eta quotient: the infinite product is well defined

The head-coefficient theorems of `Catalog/Tropical/EtaQuotientHeadCoeff.lean` are stated
for the truncated products `F_N = ∏_{m=1}^{N} (1 - X^m)^{-b m}`.  This file proves the
general fact that makes those statements statements about the *infinite* product
`∏_{m ≥ 1} (1 - X^m)^{-b m}`:

  `coeff n F_N = coeff n F_M` whenever `n ≤ N` and `n ≤ M`   (`coeff_etaQuotientProd_stable`)

so that

  `etaCoeff a n := coeff n F_n`

is the well-defined `n`-th coefficient of the infinite product, computed by *any*
sufficiently long truncation (`coeff_etaQuotientProd_eq_etaCoeff`).

The mechanism is the `X`-adic congruence calculus `OneMod k f ↔ X^k ∣ f - 1`, which is
closed under products, inverses of units and integer powers.  Specialised to degrees
`2` and `3` this upgrades the earlier results to `etaCoeff a 1 = a₁`,
`etaCoeff a 2 = headCoeff a`.
-/

namespace EtaHead

open PowerSeries Finset

/-! ## The `X`-adic congruence `f ≡ 1 mod X^k` -/

/-- `OneMod k f` means `f ≡ 1` modulo `X^k`. -/
def OneMod (k : ℕ) (f : PowerSeries ℤ) : Prop := (X : PowerSeries ℤ) ^ k ∣ (f - 1)

lemma OneMod.one (k : ℕ) : OneMod k 1 := by
  simp [OneMod]

lemma OneMod.mono {k l : ℕ} (hkl : k ≤ l) {f : PowerSeries ℤ} (h : OneMod l f) :
    OneMod k f :=
  dvd_trans (pow_dvd_pow _ hkl) h

lemma OneMod.mul {k : ℕ} {f g : PowerSeries ℤ} (hf : OneMod k f) (hg : OneMod k g) :
    OneMod k (f * g) := by
  have e : f * g - 1 = (f - 1) * g + (g - 1) := by ring
  rw [OneMod, e]
  exact dvd_add (hf.mul_right g) hg

lemma OneMod.inv {k : ℕ} {u : (PowerSeries ℤ)ˣ} (hu : OneMod k (u : PowerSeries ℤ)) :
    OneMod k ((u⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  have e : ((u⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) - 1
      = ((u⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) * (1 - (u : PowerSeries ℤ)) := by
    have h := u.inv_mul
    rw [mul_sub, mul_one]
    rw [show ((u⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) * (u : PowerSeries ℤ) = 1 from h]
  rw [OneMod, e]
  refine Dvd.dvd.mul_left ?_ _
  have e2 : (1 : PowerSeries ℤ) - (u : PowerSeries ℤ) = -((u : PowerSeries ℤ) - 1) := by ring
  rw [e2]
  exact (hu).neg_right

lemma OneMod.zpow {k : ℕ} {u : (PowerSeries ℤ)ˣ} (hu : OneMod k (u : PowerSeries ℤ)) :
    ∀ n : ℤ, OneMod k ((u ^ n : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  intro n
  induction n using Int.induction_on with
  | zero => simpa using OneMod.one k
  | succ j ih =>
      rw [zpow_add_one, Units.val_mul]
      exact ih.mul hu
  | pred j ih =>
      rw [zpow_sub_one, Units.val_mul]
      exact ih.mul hu.inv

lemma OneMod.prod_units {ι : Type*} {s : Finset ι} {k : ℕ} {u : ι → (PowerSeries ℤ)ˣ}
    (h : ∀ i ∈ s, OneMod k ((u i : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)) :
    OneMod k ((∏ i ∈ s, u i : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  classical
  rw [Units.coe_prod]
  induction s using Finset.induction with
  | empty => simpa using OneMod.one k
  | insert i s hi ih =>
      rw [Finset.prod_insert hi]
      exact (h i (by simp)).mul (ih fun j hj => h j (by simp [hj]))

/-- If `f ≡ 1 mod X^k` then multiplying by `f` does not change the coefficients in
degrees `< k`. -/
lemma coeff_mul_eq_of_OneMod {k : ℕ} {f : PowerSeries ℤ} (hf : OneMod k f)
    (g : PowerSeries ℤ) {j : ℕ} (hj : j < k) : coeff j (g * f) = coeff j g := by
  have hdvd : (X : PowerSeries ℤ) ^ k ∣ (g * f - g) := by
    have e : g * f - g = g * (f - 1) := by ring
    rw [e]
    exact hf.mul_left g
  have h0 : coeff j (g * f - g) = 0 := (PowerSeries.X_pow_dvd_iff.mp hdvd) j hj
  rw [map_sub] at h0
  omega

/-! ## The basic units are congruent to `1` -/

lemma oneSubXPow_OneMod {m : ℕ} (hm : 1 ≤ m) :
    OneMod m ((oneSubXPow m : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  rw [OneMod, coe_oneSubXPow hm]
  have e : (1 - X ^ m : PowerSeries ℤ) - 1 = -(X ^ m) := by ring
  rw [e]
  exact Dvd.dvd.neg_right dvd_rfl

/-! ## Stability of the coefficients -/

lemma etaQuotientProd_split (a : ℕ → ℤ) {N M : ℕ} (hNM : N ≤ M) :
    etaQuotientProd a M
      = etaQuotientProd a N * ∏ m ∈ Ioc N M, (oneSubXPow m) ^ (-(bCoeff a m)) := by
  have h1 : Icc 1 N = Ioc 0 N := rfl
  have h2 : Icc 1 M = Ioc 0 M := rfl
  rw [etaQuotientProd, etaQuotientProd, h1, h2,
    ← Finset.prod_Ioc_consecutive (fun m => (oneSubXPow m) ^ (-(bCoeff a m))) (Nat.zero_le N) hNM]

/-- Monotone form of stability: enlarging the truncation beyond `n` does not change the
coefficient of `X^n`. -/
lemma coeff_etaQuotientProd_mono (a : ℕ → ℤ) {n N M : ℕ} (hn : n ≤ N) (hNM : N ≤ M) :
    coeff n ((etaQuotientProd a M : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
      = coeff n ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  have htail : OneMod (N + 1)
      ((∏ m ∈ Ioc N M, (oneSubXPow m) ^ (-(bCoeff a m)) : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
    refine OneMod.prod_units fun m hm => ?_
    rw [Finset.mem_Ioc] at hm
    exact ((oneSubXPow_OneMod (m := m) (by omega)).mono (by omega)).zpow _
  rw [etaQuotientProd_split a hNM, Units.val_mul]
  exact coeff_mul_eq_of_OneMod htail _ (by omega)

/-- **Coefficientwise stability.**  For `n ≤ N` and `n ≤ M` the two truncations of the
eta quotient have the same coefficient in degree `n`; equivalently the infinite product
`∏_{m ≥ 1} (1 - X^m)^{-b m}` has well-defined coefficients. -/
theorem coeff_etaQuotientProd_stable (a : ℕ → ℤ) {n N M : ℕ} (hN : n ≤ N) (hM : n ≤ M) :
    coeff n ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
      = coeff n ((etaQuotientProd a M : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  rcases Nat.le_total N M with h | h
  · exact (coeff_etaQuotientProd_mono a hN h).symm
  · exact coeff_etaQuotientProd_mono a hM h

/-- The `n`-th coefficient of the (infinite) normalised eta quotient
`q/η_a = ∏_{m ≥ 1} (1 - q^m)^{-b m}`. -/
noncomputable def etaCoeff (a : ℕ → ℤ) (n : ℕ) : ℤ :=
  coeff n ((etaQuotientProd a n : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)

/-- Any truncation of length at least `n` computes `etaCoeff a n`. -/
theorem coeff_etaQuotientProd_eq_etaCoeff (a : ℕ → ℤ) {n N : ℕ} (hN : n ≤ N) :
    coeff n ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = etaCoeff a n :=
  coeff_etaQuotientProd_stable a hN (le_refl n)

/-- `c(-1) = 1`: the eta quotient is normalised. -/
theorem etaCoeff_zero (a : ℕ → ℤ) : etaCoeff a 0 = 1 := by
  have h : coeff 0 ((etaQuotientProd a 2 : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = 1 := by
    rw [coeff_zero_eq_constantCoeff_apply]
    exact constantCoeff_etaQuotientProd a (le_refl 2)
  rw [← coeff_etaQuotientProd_eq_etaCoeff a (n := 0) (N := 2) (by omega)]
  exact h

/-- `c(0) = a₁` for the infinite product. -/
theorem etaCoeff_one (a : ℕ → ℤ) : etaCoeff a 1 = a 1 := by
  rw [← coeff_etaQuotientProd_eq_etaCoeff a (n := 1) (N := 2) (by omega)]
  exact coeff_one_etaQuotientProd a (le_refl 2)

/-- **The head coefficient of the infinite eta quotient.**  `c(1) = a₁(a₁+3)/2 + a₂`. -/
theorem etaCoeff_two (a : ℕ → ℤ) : etaCoeff a 2 = a 1 * (a 1 + 3) / 2 + a 2 := by
  rw [← coeff_etaQuotientProd_eq_etaCoeff a (n := 2) (N := 2) (le_refl 2)]
  exact coeff_two_etaQuotientProd a (le_refl 2)

end EtaHead