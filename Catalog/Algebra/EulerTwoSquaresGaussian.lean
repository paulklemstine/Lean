import Algebra.EulerTwoSquaresCount

/-!
# The class bit is a Gaussian divisibility, and the two bits split `N` in `ℤ[i]`

The counting theorem of `EulerTwoSquaresCount` attaches to every representation
`a² + b² = p*q` a pair of bits

`(⟦p ∣ a*f - b*e⟧, ⟦q ∣ a*h - b*g⟧) ∈ Bool × Bool`,

where `p = e²+f²` and `q = g²+h²`.  That bit looks like an ad-hoc congruence.  This file
identifies it with a statement in the Gaussian integers `ℤ[i] = GaussianInt`:

`EulerTwoSquares.gaussianInt_dvd_iff_cross`:  `⟨e,f⟩ ∣ ⟨a,b⟩  ↔  (p : ℤ) ∣ a*f - b*e`.

So the bit records **which of the two conjugate Gaussian primes above `p` divides `a + b·i`**
— a Frobenius-style choice — and `EulerTwoSquares.gaussianInt_dvd_exactly_one` says exactly
one of `⟨e,f⟩`, `⟨e,-f⟩` does.  Finally `EulerTwoSquares.gaussianInt_split` exhibits the
resulting factorisation of `a + b·i` into a Gaussian prime above `p` and a Gaussian integer of
norm `q`, which is the structural reason the representation count is a power of two.

Everything here is elementary: the only inputs from `EulerTwoSquaresCount` are
`prime_dvd_cross_or` and `prime_not_dvd_cross_both`.
-/

namespace EulerTwoSquares

variable {p q : ℕ}

/-- Multiplication of Gaussian integers in coordinates. -/
theorem gaussianInt_mk_mul (e f u v : ℤ) :
    (⟨e, f⟩ : GaussianInt) * ⟨u, v⟩ = ⟨e * u - f * v, e * v + f * u⟩ := by
  ext
  · simp; ring
  · simp

/-! ## From one divisibility to the other -/

/-- If `p` divides the cross term `a*f - b*e`, it also divides the dot term `a*e + b*f`.
Both are needed to build the Gaussian quotient. -/
theorem dvd_dot_of_dvd_cross (hp : p.Prime) {e f a b : ℤ}
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hab : a ^ 2 + b ^ 2 = (p : ℤ) * q)
    (hcross : (p : ℤ) ∣ a * f - b * e) : (p : ℤ) ∣ a * e + b * f := by
  obtain ⟨k, hk⟩ := hcross
  have hpZ : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hsq : (a * e + b * f) ^ 2 = (p : ℤ) ^ 2 * ((q : ℤ) - k ^ 2) := by
    have hid : (a * e + b * f) ^ 2 + (a * f - b * e) ^ 2 = (a ^ 2 + b ^ 2) * (e ^ 2 + f ^ 2) := by
      ring
    rw [hk, hab, hef] at hid
    linear_combination hid
  refine hpZ.dvd_of_dvd_pow (n := 2) ⟨(p : ℤ) * ((q : ℤ) - k ^ 2), ?_⟩
  rw [hsq]; ring

/-- The conjugate statement: `p ∣ a*f + b*e` forces `p ∣ a*e - b*f`. -/
theorem dvd_dot_sub_of_dvd_cross_add (hp : p.Prime) {e f a b : ℤ}
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hab : a ^ 2 + b ^ 2 = (p : ℤ) * q)
    (hcross : (p : ℤ) ∣ a * f + b * e) : (p : ℤ) ∣ a * e - b * f := by
  obtain ⟨k, hk⟩ := hcross
  obtain ⟨m, hm⟩ := dvd_dot_of_dvd_cross (q := q) hp (e := e) (f := -f) (a := a) (b := b)
    (by linarith) hab ⟨-k, by linarith⟩
  exact ⟨m, by linarith⟩

/-! ## The bridge -/

/-- **The class bit is a Gaussian divisibility.**  For a representation `a² + b² = p*q` and a
representation `p = e² + f²` of the prime `p`, the Gaussian integer `e + f·i` divides
`a + b·i` if and only if `p` divides the cross term `a*f - b*e`. -/
theorem gaussianInt_dvd_iff_cross (hp : p.Prime) {e f a b : ℤ}
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hab : a ^ 2 + b ^ 2 = (p : ℤ) * q) :
    (⟨e, f⟩ : GaussianInt) ∣ ⟨a, b⟩ ↔ (p : ℤ) ∣ a * f - b * e := by
  constructor
  · rintro ⟨⟨u, v⟩, huv⟩
    rw [gaussianInt_mk_mul] at huv
    have hre : a = e * u - f * v := congrArg Zsqrtd.re huv
    have him : b = e * v + f * u := congrArg Zsqrtd.im huv
    exact ⟨-v, by rw [hre, him, ← hef]; ring⟩
  · intro hcross
    obtain ⟨v', hv'⟩ := hcross
    obtain ⟨u, hu⟩ := dvd_dot_of_dvd_cross (q := q) hp hef hab ⟨v', hv'⟩
    refine ⟨⟨u, -v'⟩, ?_⟩
    rw [gaussianInt_mk_mul]
    have hp0 : (p : ℤ) ≠ 0 := Int.natCast_ne_zero.2 hp.ne_zero
    have hre : (p : ℤ) * a = (p : ℤ) * (e * u - f * -v') := by
      calc (p : ℤ) * a = a * (e ^ 2 + f ^ 2) := by rw [hef]; ring
        _ = e * (a * e + b * f) + f * (a * f - b * e) := by ring
        _ = e * ((p : ℤ) * u) + f * ((p : ℤ) * v') := by rw [hu, hv']
        _ = (p : ℤ) * (e * u - f * -v') := by ring
    have him : (p : ℤ) * b = (p : ℤ) * (e * -v' + f * u) := by
      calc (p : ℤ) * b = b * (e ^ 2 + f ^ 2) := by rw [hef]; ring
        _ = f * (a * e + b * f) - e * (a * f - b * e) := by ring
        _ = f * ((p : ℤ) * u) - e * ((p : ℤ) * v') := by rw [hu, hv']
        _ = (p : ℤ) * (e * -v' + f * u) := by ring
    exact congrArg₂ Zsqrtd.mk (mul_left_cancel₀ hp0 hre) (mul_left_cancel₀ hp0 him)

/-- The conjugate form of the bridge: `e - f·i` divides `a + b·i` iff `p ∣ a*f + b*e`. -/
theorem gaussianInt_conj_dvd_iff_cross_add (hp : p.Prime) {e f a b : ℤ}
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hab : a ^ 2 + b ^ 2 = (p : ℤ) * q) :
    (⟨e, -f⟩ : GaussianInt) ∣ ⟨a, b⟩ ↔ (p : ℤ) ∣ a * f + b * e := by
  rw [gaussianInt_dvd_iff_cross (q := q) hp (e := e) (f := -f) (by linarith) hab]
  constructor
  · rintro ⟨k, hk⟩; exact ⟨-k, by linarith⟩
  · rintro ⟨k, hk⟩; exact ⟨-k, by linarith⟩

/-! ## Exactly one Gaussian prime above `p` divides a given representation -/

/-- **Frobenius dichotomy.**  For distinct primes `p ≡ 1 [MOD 4]` and `q`, and a
representation `a² + b² = p*q`, exactly one of the two conjugate Gaussian primes `e ± f·i`
above `p` divides `a + b·i`. -/
theorem gaussianInt_dvd_exactly_one (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp4 : p % 4 = 1) {e f a b : ℤ} (he : 0 < e) (hf : 0 < f)
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hab : a ^ 2 + b ^ 2 = (p : ℤ) * q) :
    ((⟨e, f⟩ : GaussianInt) ∣ ⟨a, b⟩ ∧ ¬ ((⟨e, -f⟩ : GaussianInt) ∣ ⟨a, b⟩)) ∨
      (¬ ((⟨e, f⟩ : GaussianInt) ∣ ⟨a, b⟩) ∧ (⟨e, -f⟩ : GaussianInt) ∣ ⟨a, b⟩) := by
  have hiff1 := gaussianInt_dvd_iff_cross (q := q) hp hef hab
  have hiff2 := gaussianInt_conj_dvd_iff_cross_add (q := q) hp hef hab
  have hor := prime_dvd_cross_or (q := q) hp hef hab
  have hnot := prime_not_dvd_cross_both hp hq hpq hp4 he hf hef hab
  rcases hor with hd | hd
  · exact Or.inl ⟨hiff1.2 hd, fun hc => hnot ⟨hd, hiff2.1 hc⟩⟩
  · exact Or.inr ⟨fun hc => hnot ⟨hiff1.1 hc, hd⟩, hiff2.2 hd⟩

/-- **The Gaussian splitting behind the count.**  A representation of `p*q` whose `p`-bit is
set factors in `ℤ[i]` as the Gaussian prime `e + f·i` above `p` times a Gaussian integer of
norm `q`; the two choices of conjugate are exactly the two class bits. -/
theorem gaussianInt_split (hp : p.Prime) {e f a b : ℤ}
    (hef : e ^ 2 + f ^ 2 = (p : ℤ)) (hab : a ^ 2 + b ^ 2 = (p : ℤ) * q)
    (hdvd : (p : ℤ) ∣ a * f - b * e) :
    ∃ w : GaussianInt, (⟨a, b⟩ : GaussianInt) = ⟨e, f⟩ * w ∧ Zsqrtd.norm w = (q : ℤ) := by
  obtain ⟨w, hw⟩ := (gaussianInt_dvd_iff_cross (q := q) hp hef hab).2 hdvd
  refine ⟨w, hw, ?_⟩
  have hnorm : Zsqrtd.norm (⟨a, b⟩ : GaussianInt) =
      Zsqrtd.norm (⟨e, f⟩ : GaussianInt) * Zsqrtd.norm w := by
    rw [hw, Zsqrtd.norm_mul]
  have hab' : Zsqrtd.norm (⟨a, b⟩ : GaussianInt) = (p : ℤ) * q := by
    simp only [Zsqrtd.norm_def]; linear_combination hab
  have hef' : Zsqrtd.norm (⟨e, f⟩ : GaussianInt) = (p : ℤ) := by
    simp only [Zsqrtd.norm_def]; linear_combination hef
  rw [hab', hef'] at hnorm
  have hp0 : (p : ℤ) ≠ 0 := Int.natCast_ne_zero.2 hp.ne_zero
  exact (mul_left_cancel₀ hp0 hnorm).symm

end EulerTwoSquares