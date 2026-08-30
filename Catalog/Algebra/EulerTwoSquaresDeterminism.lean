import Algebra.EulerTwoSquaresCount

/-!
# Which prime does Euler's step extract?

`EulerTwoSquaresCore.euler_gcd_pair_factors` shows that the two gcd's produced by Euler's
combination step multiply to `p * q`.  It does **not** say which of the two gcd's is `p` and
which is `q`.  This file settles that question completely for the Brahmagupta pair.

Write `p = e² + f²`, `q = g² + h²` and form the two representations of `N = p*q`

`A = e*g + f*h`, `B = e*h - f*g`,  `C = e*g - f*h`, `D = e*h + f*g`,

so that `A² + B² = C² + D² = N`.  Then the two cross terms factor *exactly*:

`A*D - B*C = 2*e*f*q`  and  `A*D + B*C = 2*g*h*p`   (`cross_sub_factors`, `cross_add_factors`).

Since an odd prime `p = e²+f²` divides neither `2`, nor `e`, nor `f`, these identities pin the
gcd's down on the nose:

`gcd(A*D - B*C, N) = q`  and  `gcd(A*D + B*C, N) = p`   (`gcd_cross_sub_eq_q`,
`gcd_cross_add_eq_p`).

So the extraction is *deterministic*, not merely proper: the signed cross term of the
Brahmagupta pair always yields the prime whose representation was **not** used in the "twist".
Working with normalised (non-negative) parts, `|B|·|C| = |B*C|`, so which prime comes out is
governed purely by the sign of `B*C = (e*h - f*g)(e*g - f*h)`
(`gcd_cross_abs_eq_q_of_pos`, `gcd_cross_abs_eq_p_of_neg`).  This is the sharpest possible
form of the "extraction always works" face of the Euler campaign.
-/

namespace EulerTwoSquares

variable {p q : ℕ}

/-! ## An odd prime that is a sum of two squares divides neither part -/

/-- If `p` is an odd prime and `p = e² + f²`, then `p` divides neither `e` nor `f`. -/
theorem prime_not_dvd_of_sq_add_sq (hp : p.Prime) {e f : ℤ} (hef : e ^ 2 + f ^ 2 = (p : ℤ)) :
    ¬ ((p : ℤ) ∣ e ∧ (p : ℤ) ∣ f) := by
  rintro ⟨⟨x, hx⟩, ⟨y, hy⟩⟩
  have hone : (p : ℤ) * (p * (x ^ 2 + y ^ 2)) = (p : ℤ) * 1 := by
    subst hx; subst hy; linear_combination hef
  have hp0 : (0 : ℤ) < p := by exact_mod_cast hp.pos
  have h1 : (p : ℤ) * (x ^ 2 + y ^ 2) = 1 := mul_left_cancel₀ (by omega) hone
  have hdvd : (p : ℤ) ∣ 1 := ⟨_, h1.symm⟩
  have : (p : ℤ) ≤ 1 := Int.le_of_dvd one_pos hdvd
  have := hp.two_le
  omega

/-- An odd prime `p = e² + f²` does not divide `2 * e * f`. -/
theorem prime_not_dvd_two_mul_parts (hp : p.Prime) (hp2 : p ≠ 2) {e f : ℤ}
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) : ¬ ((p : ℤ) ∣ 2 * e * f) := by
  intro hdvd
  have hpZ : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hfe : (p : ℤ) ∣ e ∨ (p : ℤ) ∣ f := by
    rcases hpZ.2.2 _ _ hdvd with h | h
    · rcases hpZ.2.2 _ _ h with h2 | he
      · exfalso
        have : p ∣ 2 := by exact_mod_cast h2
        exact hp2 ((Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).1 this)
      · exact Or.inl he
    · exact Or.inr h
  -- dividing one part forces dividing the other
  refine prime_not_dvd_of_sq_add_sq hp hef ?_
  rcases hfe with he | hf
  · refine ⟨he, hpZ.dvd_of_dvd_pow (n := 2) ?_⟩
    have hf2 : f ^ 2 = (p : ℤ) - e ^ 2 := by linarith
    rw [hf2]
    exact dvd_sub dvd_rfl (he.pow (by norm_num))
  · refine ⟨hpZ.dvd_of_dvd_pow (n := 2) ?_, hf⟩
    have he2 : e ^ 2 = (p : ℤ) - f ^ 2 := by linarith
    rw [he2]
    exact dvd_sub dvd_rfl (hf.pow (by norm_num))

/-- `gcd(2*e*f, p) = 1` for an odd prime `p = e² + f²`. -/
theorem gcd_two_mul_parts_eq_one (hp : p.Prime) (hp2 : p ≠ 2) {e f : ℤ}
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) : Int.gcd (2 * e * f) (p : ℤ) = 1 := by
  have hdvd : Int.gcd (2 * e * f) (p : ℤ) ∣ p := by
    exact_mod_cast Int.gcd_dvd_right (2 * e * f) (p : ℤ)
  rcases (Nat.Prime.eq_one_or_self_of_dvd hp _ hdvd) with h | h
  · exact h
  · exfalso
    refine prime_not_dvd_two_mul_parts hp hp2 hef ?_
    have := Int.gcd_dvd_left (2 * e * f) (p : ℤ)
    rwa [h] at this

/-! ## The two cross terms factor exactly -/

/-- **The subtractive cross term of the Brahmagupta pair is `2*e*f*q`.** -/
theorem cross_sub_factors (e f g h : ℤ) :
    (e * g + f * h) * (e * h + f * g) - (e * h - f * g) * (e * g - f * h)
      = 2 * e * f * (g ^ 2 + h ^ 2) := by ring

/-- **The additive cross term of the Brahmagupta pair is `2*g*h*p`.** -/
theorem cross_add_factors (e f g h : ℤ) :
    (e * g + f * h) * (e * h + f * g) + (e * h - f * g) * (e * g - f * h)
      = 2 * g * h * (e ^ 2 + f ^ 2) := by ring

/-! ## Deterministic extraction -/

/-- **Euler's subtractive step extracts exactly `q`.** -/
theorem gcd_cross_sub_eq_q (hp : p.Prime) (hp2 : p ≠ 2) {e f g h : ℤ}
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hgh : g ^ 2 + h ^ 2 = (q : ℤ)) :
    Int.gcd ((e * g + f * h) * (e * h + f * g) - (e * h - f * g) * (e * g - f * h))
      ((p : ℤ) * q) = q := by
  have hrw : (e * g + f * h) * (e * h + f * g) - (e * h - f * g) * (e * g - f * h)
      = (q : ℤ) * (2 * e * f) := by
    rw [cross_sub_factors, hgh]; ring
  have hN : ((p : ℤ) * q) = (q : ℤ) * p := mul_comm _ _
  rw [hrw, hN, Int.gcd_mul_left, gcd_two_mul_parts_eq_one hp hp2 hef, mul_one,
    Int.natAbs_natCast]

/-- **Euler's additive step extracts exactly `p`.** -/
theorem gcd_cross_add_eq_p (hq : q.Prime) (hq2 : q ≠ 2) {e f g h : ℤ}
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hgh : g ^ 2 + h ^ 2 = (q : ℤ)) :
    Int.gcd ((e * g + f * h) * (e * h + f * g) + (e * h - f * g) * (e * g - f * h))
      ((p : ℤ) * q) = p := by
  have hrw : (e * g + f * h) * (e * h + f * g) + (e * h - f * g) * (e * g - f * h)
      = (p : ℤ) * (2 * g * h) := by
    rw [cross_add_factors, hef]; ring
  rw [hrw, Int.gcd_mul_left, gcd_two_mul_parts_eq_one hq hq2 hgh, mul_one, Int.natAbs_natCast]

/-- **The pair of gcd's is exactly `(q, p)`** — a sharpening of `euler_gcd_pair_factors`,
which only gave the product. -/
theorem gcd_cross_pair_eq (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2) (hq2 : q ≠ 2)
    {e f g h : ℤ} (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hgh : g ^ 2 + h ^ 2 = (q : ℤ)) :
    Int.gcd ((e * g + f * h) * (e * h + f * g) - (e * h - f * g) * (e * g - f * h))
        ((p : ℤ) * q) = q ∧
      Int.gcd ((e * g + f * h) * (e * h + f * g) + (e * h - f * g) * (e * g - f * h))
        ((p : ℤ) * q) = p :=
  ⟨gcd_cross_sub_eq_q hp hp2 hef hgh, gcd_cross_add_eq_p hq hq2 hef hgh⟩

/-! ## The normalised (non-negative) form: the sign of `B*C` decides -/

/-- With normalised parts `(A,|B|)` and `(|C|,D)`, the subtractive step extracts `q`
precisely when `B * C > 0`. -/
theorem gcd_cross_abs_eq_q_of_pos (hp : p.Prime) (hp2 : p ≠ 2) {e f g h : ℤ}
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hgh : g ^ 2 + h ^ 2 = (q : ℤ))
    (hsign : 0 < (e * h - f * g) * (e * g - f * h)) :
    Int.gcd ((e * g + f * h) * (e * h + f * g) - |e * h - f * g| * |e * g - f * h|)
      ((p : ℤ) * q) = q := by
  have habs : |e * h - f * g| * |e * g - f * h| = (e * h - f * g) * (e * g - f * h) := by
    rw [← abs_mul]; exact abs_of_pos hsign
  rw [habs]
  exact gcd_cross_sub_eq_q hp hp2 hef hgh

/-- With normalised parts `(A,|B|)` and `(|C|,D)`, the subtractive step extracts `p`
precisely when `B * C < 0`. -/
theorem gcd_cross_abs_eq_p_of_neg (hq : q.Prime) (hq2 : q ≠ 2) {e f g h : ℤ}
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hgh : g ^ 2 + h ^ 2 = (q : ℤ))
    (hsign : (e * h - f * g) * (e * g - f * h) < 0) :
    Int.gcd ((e * g + f * h) * (e * h + f * g) - |e * h - f * g| * |e * g - f * h|)
      ((p : ℤ) * q) = p := by
  have habs : |e * h - f * g| * |e * g - f * h| = -((e * h - f * g) * (e * g - f * h)) := by
    rw [← abs_mul]; exact abs_of_neg hsign
  rw [habs, sub_neg_eq_add]
  exact gcd_cross_add_eq_p hq hq2 hef hgh

/-- **Determinism of Euler extraction on the Brahmagupta pair.**  Whatever the signs, the
normalised subtractive step returns one of the two primes — never a trivial divisor and never
a composite. -/
theorem gcd_cross_abs_eq_prime (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2) (hq2 : q ≠ 2)
    {e f g h : ℤ} (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hgh : g ^ 2 + h ^ 2 = (q : ℤ))
    (hB : e * h - f * g ≠ 0) (hC : e * g - f * h ≠ 0) :
    Int.gcd ((e * g + f * h) * (e * h + f * g) - |e * h - f * g| * |e * g - f * h|)
      ((p : ℤ) * q) = p ∨
    Int.gcd ((e * g + f * h) * (e * h + f * g) - |e * h - f * g| * |e * g - f * h|)
      ((p : ℤ) * q) = q := by
  have hne : (e * h - f * g) * (e * g - f * h) ≠ 0 := mul_ne_zero hB hC
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · exact Or.inl (gcd_cross_abs_eq_p_of_neg hq hq2 hef hgh hlt)
  · exact Or.inr (gcd_cross_abs_eq_q_of_pos hp hp2 hef hgh hgt)

/-! ## Where the four parts sit

The same two Brahmagupta identities also locate the parts themselves, which is what feeds the
quartic search barrier of `EulerTwoSquaresBarrier`. -/

/-- The two "twisted" parts satisfy `B² + C² = N - 4efgh`. -/
theorem small_parts_sq_sum (e f g h : ℤ) :
    (e * h - f * g) ^ 2 + (e * g - f * h) ^ 2
      = (e ^ 2 + f ^ 2) * (g ^ 2 + h ^ 2) - 4 * e * f * g * h := by ring

/-- The two "aligned" parts satisfy `A² + D² = N + 4efgh`. -/
theorem large_parts_sq_sum (e f g h : ℤ) :
    (e * g + f * h) ^ 2 + (e * h + f * g) ^ 2
      = (e ^ 2 + f ^ 2) * (g ^ 2 + h ^ 2) + 4 * e * f * g * h := by ring

/-- The aligned parts multiply to `e*f*q + g*h*p`. -/
theorem large_parts_prod {e f g h : ℤ} (hef : e ^ 2 + f ^ 2 = (p : ℤ))
    (hgh : g ^ 2 + h ^ 2 = (q : ℤ)) :
    (e * g + f * h) * (e * h + f * g) = e * f * (q : ℤ) + g * h * (p : ℤ) := by
  linear_combination (e * f) * hgh + (g * h) * hef

/-- The twisted parts multiply to `g*h*p - e*f*q`. -/
theorem small_parts_prod {e f g h : ℤ} (hef : e ^ 2 + f ^ 2 = (p : ℤ))
    (hgh : g ^ 2 + h ^ 2 = (q : ℤ)) :
    (e * h - f * g) * (e * g - f * h) = g * h * (p : ℤ) - e * f * (q : ℤ) := by
  linear_combination (g * h) * hef - (e * f) * hgh

/-- **The twisted parts cannot both be small.**  For representations of two odd primes,
`B² + C² ≥ p + q - 1`, so `max(|B|,|C|) ≥ √((p+q-1)/2)`.  This is the arithmetic source of the
quartic search barrier: the second representation always sits far from the axes. -/
theorem small_parts_sq_sum_ge {e f g h : ℤ} (he : 0 < e) (hf : 0 < f) (hg : 0 < g) (hh : 0 < h)
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hgh : g ^ 2 + h ^ 2 = (q : ℤ)) (hne1 : e ≠ f)
    (hne2 : g ≠ h) :
    (p : ℤ) + (q : ℤ) - 1 ≤ (e * h - f * g) ^ 2 + (e * g - f * h) ^ 2 := by
  have h1 : 1 ≤ (e - f) ^ 2 := by
    have : e - f ≠ 0 := sub_ne_zero.2 hne1
    rcases lt_or_gt_of_ne this with hlt | hgt
    · nlinarith
    · nlinarith
  have h2 : 1 ≤ (g - h) ^ 2 := by
    have : g - h ≠ 0 := sub_ne_zero.2 hne2
    rcases lt_or_gt_of_ne this with hlt | hgt
    · nlinarith
    · nlinarith
  have hef4 : 4 * (e * f) ≤ 2 * (p : ℤ) - 2 := by nlinarith
  have hgh4 : 4 * (g * h) ≤ 2 * (q : ℤ) - 2 := by nlinarith
  have hp1 : (1 : ℤ) ≤ (p : ℤ) := by nlinarith
  have hq1 : (1 : ℤ) ≤ (q : ℤ) := by nlinarith
  have hprod : 4 * (e * f) * (4 * (g * h)) ≤ (2 * (p : ℤ) - 2) * (2 * (q : ℤ) - 2) := by
    have hefpos : (0 : ℤ) ≤ 4 * (e * f) := by positivity
    have hghpos : (0 : ℤ) ≤ 4 * (g * h) := by positivity
    nlinarith
  rw [small_parts_sq_sum, hef, hgh]
  nlinarith

end EulerTwoSquares