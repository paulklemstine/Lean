/-
# The negation involution `X ↦ -X` on ±-frames

For an odd order `n > 1` the ±-frame of order `2n` is the reflection of the frame of order `n`:
`Φ_{2n}(X) = Φ_n(-X)`.  Together with the prime-inflation identity `Φ_{np}(X) = Φ_n(X^p)`
(`p ∣ n`) this is the second of the two structural symmetries that generate the whole flat class.
-/
import Mathlib
import Shared.PMFrameTwoParameter

namespace PMFrameNeg

open Polynomial Finset PMFrame

/-! ## 1. The reflection on coefficients -/

/-- Composing with `-X` multiplies the `k`-th coefficient by `(-1)^k`. -/
theorem coeff_comp_neg_X (f : ℤ[X]) (k : ℕ) : (f.comp (-X)).coeff k = (-1) ^ k * f.coeff k := by
  induction f using Polynomial.induction_on' with
  | add p q hp hq => simp [add_comp, hp, hq, mul_add]
  | monomial n a =>
      have hx : (-X : ℤ[X]) = C (-1) * X := by simp
      have h : (Polynomial.monomial n a).comp (-X : ℤ[X]) = C ((-1) ^ n * a) * X ^ n := by
        rw [hx, Polynomial.monomial_comp, mul_pow, ← C_pow, C_mul]
        ring
      rw [h, Polynomial.coeff_C_mul, Polynomial.coeff_X_pow, Polynomial.coeff_monomial]
      by_cases hk : n = k
      · subst hk; simp
      · rw [if_neg (by omega), if_neg (by omega)]; ring

/-- Reflection preserves non-vanishing. -/
theorem comp_neg_X_ne_zero (f : ℤ[X]) (hf : f ≠ 0) : f.comp (-X) ≠ 0 := by
  intro h0
  refine hf ?_
  ext k
  have hk := coeff_comp_neg_X f k
  rw [h0, Polynomial.coeff_zero] at hk
  have hpow : ((-1 : ℤ)) ^ k ≠ 0 := pow_ne_zero _ (by norm_num)
  rcases mul_eq_zero.mp hk.symm with h | h
  · exact absurd h hpow
  · simpa using h

/-! ## 2. Divisors of `2n` for odd `n` -/

/-- The divisors of `2n` are the divisors of `n` together with their doubles. -/
theorem divisors_two_mul {n : ℕ} (hpos : 0 < n) :
    (2 * n).divisors = n.divisors ∪ n.divisors.image (fun d => 2 * d) := by
  have hn0 : n ≠ 0 := hpos.ne'
  ext d
  simp only [Nat.mem_divisors, Finset.mem_union, Finset.mem_image]
  constructor
  · rintro ⟨hdvd, -⟩
    rcases Nat.even_or_odd d with he | ho
    · obtain ⟨e, he⟩ := he
      have hde : d = 2 * e := by omega
      subst hde
      have h2 : 2 * e ∣ 2 * n := hdvd
      have : e ∣ n := (mul_dvd_mul_iff_left (by norm_num : (2 : ℕ) ≠ 0)).mp h2
      exact Or.inr ⟨e, ⟨this, hn0⟩, rfl⟩
    · have h2nd : ¬ (2 ∣ d) := by rw [Nat.odd_iff] at ho; omega
      have hcop : Nat.Coprime d 2 := (Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr h2nd |>.symm
      exact Or.inl ⟨hcop.dvd_of_dvd_mul_left hdvd, hn0⟩
  · rintro (⟨hdvd, -⟩ | ⟨e, ⟨hdvd, -⟩, rfl⟩)
    · exact ⟨hdvd.mul_left 2, by positivity⟩
    · exact ⟨mul_dvd_mul_left 2 hdvd, by positivity⟩

theorem disjoint_divisors_image_two_mul {n : ℕ} (hn : Odd n) :
    Disjoint n.divisors (n.divisors.image (fun d => 2 * d)) := by
  rw [Finset.disjoint_left]
  rintro a ha hb
  obtain ⟨e, -, rfl⟩ := Finset.mem_image.mp hb
  have hdvd : 2 * e ∣ n := (Nat.mem_divisors.mp ha).1
  have h2 : (2 : ℕ) ∣ n := dvd_trans ⟨e, rfl⟩ hdvd
  rw [Nat.odd_iff] at hn
  omega

/-- **The odd half-frame product.**  For odd `n > 0`, `∏_{d ∣ n} Φ_{2d} = X^n + 1`. -/
theorem prod_cyclotomic_two_mul {n : ℕ} (hn : Odd n) (hpos : 0 < n) :
    (∏ d ∈ n.divisors, cyclotomic (2 * d) ℤ) = X ^ n + 1 := by
  have h2n := prod_cyclotomic_eq_X_pow_sub_one (n := 2 * n) (by omega) ℤ
  rw [divisors_two_mul hpos,
    Finset.prod_union (disjoint_divisors_image_two_mul hn),
    Finset.prod_image (by intro a _ b _ h; have h2 : 2 * a = 2 * b := h; omega),
    prod_cyclotomic_eq_X_pow_sub_one hpos ℤ] at h2n
  have hfac : (X ^ n - 1 : ℤ[X]) * (X ^ n + 1) = X ^ (2 * n) - 1 := by
    rw [two_mul, pow_add]; ring
  have hne : (X ^ n - 1 : ℤ[X]) ≠ 0 := by
    intro h
    have := congrArg (Polynomial.eval (0 : ℤ)) h
    simp [zero_pow hpos.ne'] at this
  exact mul_left_cancel₀ hne (h2n.trans hfac.symm)

/-- The reflected divisor product: `∏_{d ∣ n} Φ_d(-X) = -(X^n + 1)` for odd `n`. -/
theorem prod_cyclotomic_comp_neg {n : ℕ} (hn : Odd n) (hpos : 0 < n) :
    (∏ d ∈ n.divisors, (cyclotomic d ℤ).comp (-X)) = -(X ^ n + 1) := by
  have h := prod_cyclotomic_eq_X_pow_sub_one hpos ℤ
  have h' : (∏ d ∈ n.divisors, cyclotomic d ℤ).comp (-X) = (X ^ n - 1 : ℤ[X]).comp (-X) := by
    rw [h]
  rw [Polynomial.prod_comp] at h'
  refine h'.trans ?_
  simp only [Polynomial.sub_comp, Polynomial.one_comp, Polynomial.pow_comp, Polynomial.X_comp]
  rw [hn.neg_pow]
  ring

/-! ## 3. `Φ_{2n}(X) = Φ_n(-X)` for odd `n > 1` -/

theorem cyclotomic_two_mul_eq_comp_neg :
    ∀ n : ℕ, Odd n → 1 < n → cyclotomic (2 * n) ℤ = (cyclotomic n ℤ).comp (-X) := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro hodd hn1
    have hpos : 0 < n := by omega
    have hA := prod_cyclotomic_two_mul hodd hpos
    have hB := prod_cyclotomic_comp_neg hodd hpos
    have hnotmem : n ∉ n.properDivisors := by
      simp [Nat.mem_properDivisors]
    rw [← Nat.insert_self_properDivisors hpos.ne', Finset.prod_insert hnotmem] at hA hB
    have h1mem : 1 ∈ n.properDivisors := Nat.one_mem_properDivisors_iff_one_lt.mpr hn1
    rw [← Finset.insert_erase h1mem,
      Finset.prod_insert (Finset.notMem_erase _ _)] at hA hB
    -- the tails agree, by the induction hypothesis
    have hcongr : (∏ d ∈ n.properDivisors.erase 1, cyclotomic (2 * d) ℤ)
        = ∏ d ∈ n.properDivisors.erase 1, (cyclotomic d ℤ).comp (-X) := by
      refine Finset.prod_congr rfl ?_
      intro d hd
      have hd1 : d ≠ 1 := Finset.ne_of_mem_erase hd
      have hdp := Nat.mem_properDivisors.mp (Finset.mem_of_mem_erase hd)
      have hdpos : 0 < d := Nat.pos_of_mem_properDivisors (Finset.mem_of_mem_erase hd)
      have hdodd : Odd d := by
        rcases Nat.even_or_odd d with he | ho
        · exfalso
          have h2d : (2 : ℕ) ∣ d := he.two_dvd
          have : (2 : ℕ) ∣ n := h2d.trans hdp.1
          rw [Nat.odd_iff] at hodd
          omega
        · exact ho
      exact ih d hdp.2 hdodd (by omega)
    rw [hcongr] at hA
    -- identify the `d = 1` factors
    have hc2 : cyclotomic (2 * 1) ℤ = X + 1 := by
      norm_num [Polynomial.cyclotomic_two]
    have hc1 : (cyclotomic 1 ℤ).comp (-X : ℤ[X]) = -(X + 1) := by
      rw [Polynomial.cyclotomic_one]
      simp
      ring
    rw [hc2] at hA
    rw [hc1] at hB
    -- both sides equal `X^n + 1` after clearing the sign
    have hB' : (cyclotomic n ℤ).comp (-X) *
        ((X + 1) * ∏ d ∈ n.properDivisors.erase 1, (cyclotomic d ℤ).comp (-X)) = X ^ n + 1 := by
      linear_combination -hB
    have hprodne : ((X : ℤ[X]) + 1) *
        (∏ d ∈ n.properDivisors.erase 1, (cyclotomic d ℤ).comp (-X)) ≠ 0 := by
      refine mul_ne_zero ?_ ?_
      · intro h
        have := congrArg (Polynomial.eval (0 : ℤ)) h
        simp at this
      · rw [Finset.prod_ne_zero_iff]
        intro d _
        exact comp_neg_X_ne_zero _ (Polynomial.cyclotomic_ne_zero d ℤ)
    exact mul_right_cancel₀ hprodne (hA.trans hB'.symm)

/-! ## 4. Consequences for the ±-frame -/

/-- **Reflection law for ±-frames.**  For odd `n > 1`, `Φ_{2n}` and `Φ_n` have the same
coefficients up to the alternating sign `(-1)^k`. -/
theorem coeff_pmFrame_two_mul {n : ℕ} (hodd : Odd n) (hn1 : 1 < n) (k : ℕ) :
    (pmFrame (2 * n)).coeff k = (-1) ^ k * (pmFrame n).coeff k := by
  unfold pmFrame
  rw [cyclotomic_two_mul_eq_comp_neg n hodd hn1, coeff_comp_neg_X]

/-- Reflection preserves the absolute values of the coefficients. -/
theorem abs_coeff_pmFrame_two_mul {n : ℕ} (hodd : Odd n) (hn1 : 1 < n) (k : ℕ) :
    |(pmFrame (2 * n)).coeff k| = |(pmFrame n).coeff k| := by
  rw [coeff_pmFrame_two_mul hodd hn1 k, abs_mul, abs_pow, abs_neg, abs_one, one_pow, one_mul]

end PMFrameNeg