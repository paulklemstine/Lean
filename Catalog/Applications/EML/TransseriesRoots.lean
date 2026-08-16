import Applications.EML.TransseriesEMLBase

/-!
# Root extraction in the field of EML transseries

The transseries field `EMLTS.TS` is a non-Archimedean ordered field.  Here we prove the
two "root axioms" of a real closed field for it:

* every nonnegative transseries is a square (`EMLTS.isSquare_iff_nonneg`), so the
  transseries field is *Euclidean* and its ordering is the unique field ordering;
* every positive transseries has an `n`-th root for every `n ≠ 0`
  (`EMLTS.exists_pow_eq_of_pos`), and every transseries has an `n`-th root for odd `n`
  (`EMLTS.exists_pow_eq_of_odd`).

The proof combines three ingredients:

* divisibility of the rank group (`EMLTS.exists_rank_nsmul`), giving roots of
  transmonomials;
* real closedness of the coefficient field `ℝ`, giving roots of the leading coefficient;
* the binomial expansion of `(1 + ε) ^ r` for infinitesimal `ε`
  (`HahnSeries.binomialFamily`), giving roots of `1`-units.

The last ingredient is where the infinite formal sums of transseries theory really enter:
`(1+ε)^(1/n)` is a genuinely infinite transseries even when `ε` is a single monomial.
-/

noncomputable section

open HahnSeries

namespace EMLTS

/-! ## Real powers of `1`-units in a Hahn series field -/

section OneUnits

variable {Γ : Type*} [LinearOrder Γ] [AddCommMonoid Γ] [IsOrderedCancelAddMonoid Γ]
variable {R : Type*} [CommRing R] [BinomialRing R]

/-- The zeroth binomial power of a `1`-unit is `1`. -/
theorem oneUnit_rpow_zero (x : orderTopSubOnePos Γ R) : x ^ (0 : R) = 1 := by
  have h : x ^ ((0 : R) + 0) = x ^ (0 : R) * x ^ (0 : R) := HahnSeries.pow_add
  rw [add_zero] at h
  have h2 : x ^ (0 : R) * x ^ (0 : R) = x ^ (0 : R) * 1 := by rw [mul_one, ← h]
  exact mul_left_cancel h2

/-- The first binomial power of a `1`-unit is the unit itself. -/
theorem oneUnit_rpow_one (x : orderTopSubOnePos Γ R) : x ^ (1 : R) = x := by
  suffices h : (x ^ (1 : R)).val.val = x.val.val by
    exact SetLike.coe_eq_coe.mp (Units.val_inj.mp h)
  have hx : 0 < ((x : R⟦Γ⟧ˣ).val - 1).orderTop := x.2
  have hb : PowerSeries.binomialSeries R (1 : R) = 1 + PowerSeries.X := by
    have := PowerSeries.binomialSeries_nat (R := R) (A := R) 1
    simpa using this
  simp only [binomial_power, val_toOrderTopSubOnePos_coe,
    SummableFamily.binomialFamily, ← PowerSeries.heval_apply, hb, map_add, map_one,
    PowerSeries.heval_X _ hx]
  ring

/-- Binomial powers turn multiplication of exponents by a natural number into iterated
multiplication. -/
theorem oneUnit_rpow_natCast_mul (x : orderTopSubOnePos Γ R) (r : R) (n : ℕ) :
    x ^ ((n : R) * r) = (x ^ r) ^ n := by
  induction n with
  | zero => simpa using oneUnit_rpow_zero x
  | succ k ih =>
      have : ((k : R) + 1) * r = (k : R) * r + r := by ring
      push_cast
      rw [this, HahnSeries.pow_add, ih, pow_succ]

/-- Every `1`-unit has an `n`-th root, for every `n ≠ 0`, when the coefficients form a
`ℚ`-algebra (here `R` is a binomial ring in which `n` is invertible). -/
theorem oneUnit_exists_pow (x : orderTopSubOnePos Γ ℝ) {n : ℕ} (hn : n ≠ 0) :
    ∃ y : orderTopSubOnePos Γ ℝ, y ^ n = x := by
  refine ⟨x ^ ((n : ℝ)⁻¹), ?_⟩
  rw [← oneUnit_rpow_natCast_mul, mul_inv_cancel₀ (Nat.cast_ne_zero.mpr hn),
    oneUnit_rpow_one]

end OneUnits

/-! ## Normalising a nonzero transseries -/

/-- The leading data of a nonzero transseries: a rank, a nonzero real coefficient and a
`1`-unit factor. -/
theorem exists_leading_decomposition (f : TS) (hf : f ≠ 0) :
    ∃ (g : Rank) (r : ℝ) (u : orderTopSubOnePos Rank ℝ),
      r = (ofLex f).leadingCoeff ∧ ofLex f = single g r * (u : ℝ⟦Rank⟧ˣ).val := by
  have hf' : ofLex f ≠ 0 := by simpa using hf
  have hlc : (ofLex f).leadingCoeff ≠ 0 := leadingCoeff_ne_zero.mpr hf'
  have htop : (ofLex f).orderTop ≠ ⊤ := orderTop_ne_top.2 hf'
  set g : Rank := (ofLex f).orderTop.untop htop with hg
  set r : ℝ := (ofLex f).leadingCoeff with hr
  set y : ℝ⟦Rank⟧ := single (-g) r⁻¹ * ofLex f with hy
  have hsingle_ne : (single (-g) r⁻¹ : ℝ⟦Rank⟧) ≠ 0 := by
    simp [hlc]
  have hylc : y.leadingCoeff = 1 := by
    rw [hy, leadingCoeff_mul, leadingCoeff_of_single, ← hr, inv_mul_cancel₀ hlc]
  have hgtop : (ofLex f).orderTop = (g : WithTop Rank) := (WithTop.coe_untop _ htop).symm
  have hytop : y.orderTop = 0 := by
    rw [hy, orderTop_mul_of_ne_zero, orderTop_single (inv_ne_zero hlc), hgtop,
      ← WithTop.coe_add, neg_add_cancel]
    · rfl
    · rw [leadingCoeff_of_single]
      exact mul_ne_zero (inv_ne_zero hlc) hlc
  have hypos : 0 < (y - 1).orderTop := (orderTop_self_sub_one_pos_iff y).mpr ⟨hytop, hylc⟩
  refine ⟨g, r, toOrderTopSubOnePos hypos, rfl, ?_⟩
  rw [val_toOrderTopSubOnePos_coe, hy, ← mul_assoc, single_mul_single, add_neg_cancel,
    mul_inv_cancel₀ hlc]
  simp

/-! ## Root extraction -/

/-- The leading coefficient of a `1`-unit is `1`. -/
theorem oneUnit_leadingCoeff (u : orderTopSubOnePos Rank ℝ) :
    ((u : ℝ⟦Rank⟧ˣ).val).leadingCoeff = 1 :=
  ((orderTop_self_sub_one_pos_iff _).mp u.2).2

/-- **Root extraction for positive transseries.**  Every positive transseries has a
positive `n`-th root, for every `n ≠ 0`.  This uses divisibility of the rank group,
real closedness of the coefficient field and the binomial expansion of `(1+ε)^(1/n)`. -/
theorem exists_pow_eq_of_pos {f : TS} (hf : 0 < f) {n : ℕ} (hn : n ≠ 0) :
    ∃ h : TS, 0 < h ∧ h ^ n = f := by
  have hf0 : f ≠ 0 := hf.ne'
  have hlc : 0 < (ofLex f).leadingCoeff := leadingCoeff_pos_iff.mpr hf
  obtain ⟨g, r, u, hr, hfac⟩ := exists_leading_decomposition f hf0
  obtain ⟨y, hy⟩ := oneUnit_exists_pow u hn
  obtain ⟨g0, hg0⟩ := exists_rank_nsmul n hn g
  have hrpos : 0 < r := hr ▸ hlc
  set s : ℝ := r ^ ((n : ℝ)⁻¹) with hs
  have hspos : 0 < s := Real.rpow_pos_of_pos hrpos _
  have hsn : s ^ n = r := by
    rw [hs, ← Real.rpow_natCast (r ^ ((n : ℝ)⁻¹)) n, ← Real.rpow_mul hrpos.le,
      inv_mul_cancel₀ (Nat.cast_ne_zero.mpr hn), Real.rpow_one]
  refine ⟨toLex (single g0 s * ((y : ℝ⟦Rank⟧ˣ).val)), ?_, ?_⟩
  · rw [← leadingCoeff_pos_iff, ofLex_toLex, leadingCoeff_mul, leadingCoeff_of_single,
      oneUnit_leadingCoeff, mul_one]
    exact hspos
  · have hpow : ofLex ((toLex (single g0 s * ((y : ℝ⟦Rank⟧ˣ).val)) : TS) ^ n)
        = (single g0 s * ((y : ℝ⟦Rank⟧ˣ).val)) ^ n := rfl
    have hyn : ((y ^ n : orderTopSubOnePos Rank ℝ) : ℝ⟦Rank⟧ˣ).val
        = ((y : ℝ⟦Rank⟧ˣ).val) ^ n := by
      push_cast
      rfl
    refine ofLex.injective ?_
    rw [hpow, hfac, mul_pow, single_pow, hg0, hsn, ← hyn, hy]

/-- **Every nonnegative transseries is a square**: the transseries field is Euclidean. -/
theorem exists_sq_of_nonneg {f : TS} (hf : 0 ≤ f) : ∃ h : TS, h ^ 2 = f := by
  rcases hf.eq_or_lt with rfl | hpos
  · exact ⟨0, by simp⟩
  · obtain ⟨h, _, hh⟩ := exists_pow_eq_of_pos hpos (n := 2) two_ne_zero
    exact ⟨h, hh⟩

/-- The nonnegative transseries are exactly the squares.  Consequently the asymptotic
ordering is the *unique* field ordering of the transseries field. -/
theorem isSquare_iff_nonneg {f : TS} : IsSquare f ↔ 0 ≤ f := by
  constructor
  · rintro ⟨h, rfl⟩
    exact mul_self_nonneg h
  · intro hf
    obtain ⟨h, rfl⟩ := exists_sq_of_nonneg hf
    exact ⟨h, sq h⟩

/-- **Odd roots always exist**: for odd `n`, every transseries (of any sign) has an
`n`-th root. -/
theorem exists_pow_eq_of_odd {n : ℕ} (hn : Odd n) (f : TS) : ∃ h : TS, h ^ n = f := by
  have hn0 : n ≠ 0 := by rintro rfl; simp [Nat.odd_iff] at hn
  rcases lt_trichotomy f 0 with hneg | rfl | hpos
  · obtain ⟨h, _, hh⟩ := exists_pow_eq_of_pos (neg_pos.mpr hneg) hn0
    exact ⟨-h, by rw [hn.neg_pow, hh, neg_neg]⟩
  · exact ⟨0, by simp [hn0]⟩
  · obtain ⟨h, _, hh⟩ := exists_pow_eq_of_pos hpos hn0
    exact ⟨h, hh⟩

/-- The transseries field is formally real: `-1` is not a sum of squares.  (Together with
`isSquare_iff_nonneg` and `exists_pow_eq_of_odd` this is the "root half" of real
closedness.) -/
theorem neg_one_not_isSumSq : ¬ IsSumSq (-1 : TS) := by
  intro h
  have := h.nonneg
  linarith

end EMLTS