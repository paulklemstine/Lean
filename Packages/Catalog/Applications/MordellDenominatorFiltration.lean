import Applications.MordellDenominatorSquares

/-!
# The `ℓ`-adic filtration of denominators is preserved by doubling — at good *and* bad primes

The previous cycles studied `den x(2P)` for an **integral** point `P` and proved that a prime
`ℓ ≥ 5` of good reduction enters the denominator exactly when `ℓ ∣ y` (refuting the
"only bad primes" conjecture).  This file removes the integrality hypothesis and asks the
opposite question: once a prime *has* entered the denominator, what happens to it under
further doublings?

The answer is a clean invariance law, which holds at **every odd prime**, whether of good or
of bad reduction, and needs no hypothesis relating `ℓ` to `N`:

> if `ℓ` is odd and `ℓ ∣ den x(P)`, then the `ℓ`-part of `den x(2P)` equals the `ℓ`-part of
> `den x(P)`;

while at `ℓ = 2` the level jumps by exactly two:

> if `2 ∣ den x(P)` then the `2`-part of `den x(2P)` is `4 ×` the `2`-part of `den x(P)`.

This is the affine, elementary-arithmetic form of the statement that multiplication by `2`
acts on the formal group `Ê(ℓℤ_ℓ)` as an isomorphism onto its image of index `|2|_ℓ`, i.e. as
a bijection when `ℓ` is odd.

## Main results

* `mordell_param` : the coprime parametrisation `x = a/e²`, `y = b/e³` with `ℓ ∤ a`, `ℓ ∤ b`
  whenever `ℓ ∣ e`, extracted from the square-denominator law.
* `den_double_eq_int_frac` : in that parametrisation `x(2P) = (a⁴ − 8Nae⁶)/(4b²e²)`.
* `pow_dvd_den_double_iff_of_dvd_den` : **the invariance law** — for odd `ℓ` with `ℓ ∣ den x`,
  `ℓ^m ∣ den x(2P) ↔ ℓ^m ∣ den x` for all `m`.
* `factorization_den_double_eq` : the same statement as an equality of `ℓ`-adic valuations.
* `pow_dvd_den_double_two_iff` : the `ℓ = 2` law, `2^m ∣ den x(2P) ↔ 2^m ∣ 4 · den x`.
* `kernel_stable_double`, `kernel_stable_two_pow` : transported to Mathlib's group law — the
  set of points whose `x`-denominator is divisible by an odd `ℓ` is stable under doubling, and
  hence under all `2`-power multiples.
* `seven_dvd_den_two_pow_55` : the counterexample of cycle 1 becomes an infinite family —
  the good prime `7` divides the denominator of `x(2^k P)` for **every** `k ≥ 1` on
  `E_55 : y² = x³ + 55`, `P = (9,28)`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 3): the previous cycles saw `v_7(den x(2P)) = 2` for `N = 55`.
  Conjecture: `v_7` is *constant* along the sub-orbit `{2^k P}` — a prime, once in the
  denominator, never leaves and never grows, provided it is odd.
Experiment (Experimenter): rational arithmetic on `E_55`, `P = (9,28)` gives
  `v_7(den x(nP)) = 2` for `n = 2, 4, 6, 8` and `0` for `n = 1, 3, 5`, while
  `v_13(den x(nP)) = 2` for `n = 3, 6` — constant along the multiples where it is nonzero.
  `v_2(den x(nP)) = 6, 8, 10` for `n = 2, 4, 8`: growth by two per doubling, exactly as
  `pow_dvd_den_double_two_iff` predicts.
Analysis (Analyst): in the coprime parametrisation the numerator of `x(2P)` is
  `a⁴ − 8Nae⁶ ≡ a⁴ (mod ℓ)` whenever `ℓ ∣ e`; since `gcd(a,e) = 1` the numerator is a unit at
  `ℓ`, so *no* cancellation is possible and the denominator's `ℓ`-part is that of `4b²e²`.
  For odd `ℓ` this is `e²`; for `ℓ = 2` the constant `4` contributes the extra two levels.
  Note that no hypothesis `ℓ ∤ N` is used: bad primes obey the same law.
Critique (Critic): the theorem could be vacuous if no point had `ℓ ∣ den x`; the explicit
  family `seven_dvd_den_two_pow_55` rules this out, and shows the counterexample to the
  "only bad primes" conjecture propagates to infinitely many multiples of a single point on a
  single curve.  The hypothesis `ℓ ∣ den x` is genuinely needed: for an integral point the
  criterion is the different one proved in `Shared.MordellDenominatorValuations`.
-/

namespace MordellDenominators

open WeierstrassCurve WeierstrassCurve.Affine

/-! ## The coprime parametrisation at a prime dividing the denominator -/

/-- **Parametrisation.**  Let `(x, y)` be a rational point of `E_N`, `N ∈ ℤ`, and let `ℓ` be a
prime dividing `den x`.  Then `x = a/e²`, `y = b/e³` with `e ≠ 0`, `ℓ ∣ e`, `ℓ ∤ a`, `ℓ ∤ b`,
and `den x = e²`. -/
lemma mordell_param {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ)) {ℓ : ℕ} (hl : ℓ.Prime)
    (hdvd : ℓ ∣ x.den) :
    ∃ (a b : ℤ) (e : ℕ), 0 < e ∧ (ℓ : ℤ) ∣ (e : ℤ) ∧ ¬(ℓ : ℤ) ∣ a ∧ ¬(ℓ : ℤ) ∣ b ∧
      x.den = e ^ 2 ∧ x = (a : ℚ) / ((e : ℚ)) ^ 2 ∧ y = (b : ℚ) / ((e : ℚ)) ^ 3 := by
  obtain ⟨e, hxe, hye⟩ := mordell_den_pow_structure h
  have he0 : 0 < e := by
    rcases Nat.eq_zero_or_pos e with rfl | he
    · exfalso
      have hd := x.den_nz
      rw [hxe] at hd
      simp at hd
    · exact he
  have hle : ℓ ∣ e := by
    rw [hxe] at hdvd
    exact hl.dvd_of_dvd_pow hdvd
  have hea : ¬(ℓ : ℤ) ∣ x.num := by
    intro hc
    have h1 : ℓ ∣ x.num.natAbs := by
      simpa using Int.natAbs_dvd_natAbs.mpr hc
    have h2 : ℓ ∣ x.den := hdvd
    have := Nat.Coprime.eq_one_of_dvd (Nat.Coprime.coprime_dvd_left h1 x.reduced) h2
    exact hl.one_lt.ne' this
  have heb : ¬(ℓ : ℤ) ∣ y.num := by
    intro hc
    have h1 : ℓ ∣ y.num.natAbs := by
      simpa using Int.natAbs_dvd_natAbs.mpr hc
    have h2 : ℓ ∣ y.den := by
      rw [hye]; exact dvd_pow hle (by norm_num)
    have := Nat.Coprime.eq_one_of_dvd (Nat.Coprime.coprime_dvd_left h1 y.reduced) h2
    exact hl.one_lt.ne' this
  refine ⟨x.num, y.num, e, he0, Int.natCast_dvd_natCast.mpr hle, hea, heb, hxe, ?_, ?_⟩
  · rw [show ((e : ℚ)) ^ 2 = ((x.den : ℚ)) by rw [hxe]; push_cast; ring]
    exact (Rat.num_div_den x).symm
  · rw [show ((e : ℚ)) ^ 3 = ((y.den : ℚ)) by rw [hye]; push_cast; ring]
    exact (Rat.num_div_den y).symm

/-- In the parametrisation `x = a/e²`, `y = b/e³` the doubled `x`-coordinate is the fraction of
integers `(a⁴ − 8Nae⁶)/(4b²e²)`. -/
lemma den_double_eq_int_frac {N : ℤ} {x y : ℚ} {a b : ℤ} {e : ℕ} (he : 0 < e) (hb : b ≠ 0)
    (hx : x = (a : ℚ) / ((e : ℚ)) ^ 2) (hy : y = (b : ℚ) / ((e : ℚ)) ^ 3) :
    (x ^ 4 - 8 * (N : ℚ) * x) / (4 * y ^ 2)
      = ((a ^ 4 - 8 * N * a * (e : ℤ) ^ 6 : ℤ) : ℚ) / ((4 * b ^ 2 * (e : ℤ) ^ 2 : ℤ) : ℚ) := by
  have he' : ((e : ℚ)) ≠ 0 := by
    have : (0 : ℚ) < (e : ℚ) := by exact_mod_cast he
    exact ne_of_gt this
  have hb' : ((b : ℚ)) ≠ 0 := Int.cast_ne_zero.mpr hb
  subst hx hy
  push_cast
  field_simp

/-! ## The invariance law at odd primes -/

/-- **Filtration invariance under doubling.**  Let `(x, y)` be a rational point of
`E_N : y² = x³ + N` with `N ∈ ℤ` and `y ≠ 0`, and let `ℓ` be an **odd** prime dividing the
denominator of `x`.  Then for every exponent `m`,
`ℓ^m ∣ den x(2P) ↔ ℓ^m ∣ den x(P)`.

In words: the `ℓ`-part of the denominator is *exactly preserved* by doubling.  No hypothesis
on the reduction type of `ℓ` is required — the law holds at bad primes as well. -/
theorem pow_dvd_den_double_iff_of_dvd_den {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ))
    (hy : y ≠ 0) {ℓ : ℕ} (hl : ℓ.Prime) (hl2 : ℓ ≠ 2) (hdvd : ℓ ∣ x.den) (m : ℕ) :
    ℓ ^ m ∣ ((x ^ 4 - 8 * (N : ℚ) * x) / (4 * y ^ 2)).den ↔ ℓ ^ m ∣ x.den := by
  obtain ⟨a, b, e, he0, hle, hla, hlb, hxden, hx, hy'⟩ := mordell_param h hl hdvd
  have hb0 : b ≠ 0 := by
    rintro rfl
    apply hy
    simp [hy']
  have hE0 : ((e : ℤ)) ≠ 0 := by exact_mod_cast he0.ne'
  have hB0 : (4 * b ^ 2 * (e : ℤ) ^ 2 : ℤ) ≠ 0 := by positivity
  have hl4 : ¬(ℓ : ℤ) ∣ 4 := by
    intro hc
    have hp : Prime (ℓ : ℤ) := Nat.prime_iff_prime_int.mp hl
    have h2 : (ℓ : ℤ) ∣ 2 := hp.dvd_of_dvd_pow (n := 2) (by norm_num at hc ⊢; exact hc)
    have hle2 : (ℓ : ℤ) ≤ 2 := Int.le_of_dvd (by norm_num) h2
    have : ℓ ≤ 2 := by exact_mod_cast hle2
    interval_cases ℓ <;> simp_all (config := { decide := true })
  -- the numerator is a unit at `ℓ`
  have hnum : ¬(ℓ : ℤ) ∣ (a ^ 4 - 8 * N * a * (e : ℤ) ^ 6) := by
    intro hc
    have h6 : (ℓ : ℤ) ∣ 8 * N * a * (e : ℤ) ^ 6 :=
      Dvd.dvd.mul_left (dvd_pow hle (by norm_num)) _
    have : (ℓ : ℤ) ∣ a ^ 4 := by simpa using dvd_add hc h6
    exact hla ((Nat.prime_iff_prime_int.mp hl).dvd_of_dvd_pow this)
  rw [den_double_eq_int_frac (N := N) he0 hb0 hx hy', hxden]
  constructor
  · intro hm
    have h1 : (ℓ : ℤ) ^ m ∣ (4 * b ^ 2 * (e : ℤ) ^ 2 : ℤ) :=
      dvd_trans (by exact_mod_cast hm) (den_dvd_denom _ _)
    have hcop : IsCoprime ((ℓ : ℤ) ^ m) (4 * b ^ 2 : ℤ) := by
      have h4 : IsCoprime ((ℓ : ℤ) ^ m) (4 : ℤ) := isCoprime_pow_of_not_dvd hl hl4 m
      have hbb : IsCoprime ((ℓ : ℤ) ^ m) (b ^ 2 : ℤ) :=
        (isCoprime_pow_of_not_dvd hl hlb m).pow_right
      exact h4.mul_right hbb
    have h2 : (ℓ : ℤ) ^ m ∣ ((e : ℤ)) ^ 2 := by
      refine hcop.dvd_of_dvd_mul_left ?_
      simpa [mul_comm, mul_assoc, mul_left_comm] using h1
    exact_mod_cast h2
  · intro hm
    refine prime_pow_dvd_den hB0 hl ?_ hnum
    have h2 : ((ℓ : ℤ)) ^ m ∣ ((e : ℤ)) ^ 2 := by exact_mod_cast hm
    exact Dvd.dvd.mul_left h2 _

/-- **Valuation form of the invariance law.**  For an odd prime `ℓ` dividing `den x`, the
`ℓ`-adic valuations of `den x(2P)` and of `den x(P)` coincide. -/
theorem factorization_den_double_eq {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ))
    (hy : y ≠ 0) {ℓ : ℕ} (hl : ℓ.Prime) (hl2 : ℓ ≠ 2) (hdvd : ℓ ∣ x.den) :
    (((x ^ 4 - 8 * (N : ℚ) * x) / (4 * y ^ 2)).den).factorization ℓ
      = (x.den).factorization ℓ := by
  have hkey := pow_dvd_den_double_iff_of_dvd_den h hy hl hl2 hdvd
  have hd1 : x.den ≠ 0 := x.den_nz
  have hd2 : ((x ^ 4 - 8 * (N : ℚ) * x) / (4 * y ^ 2)).den ≠ 0 :=
    ((x ^ 4 - 8 * (N : ℚ) * x) / (4 * y ^ 2)).den_nz
  refine le_antisymm ?_ ?_
  · rw [← Nat.Prime.pow_dvd_iff_le_factorization hl hd1]
    exact (hkey _).mp (Nat.ordProj_dvd _ _)
  · rw [← Nat.Prime.pow_dvd_iff_le_factorization hl hd2]
    exact (hkey _).mpr (Nat.ordProj_dvd _ _)

/-! ## The exceptional behaviour at `ℓ = 2` -/

/-- **The `2`-adic law.**  If `2` divides `den x(P)` then the `2`-part of `den x(2P)` is exactly
four times the `2`-part of `den x(P)`: `2^m ∣ den x(2P) ↔ 2^m ∣ 4 · den x(P)`.

So at the even prime the filtration level increases by exactly two at each doubling, in
contrast with the invariance at odd primes.  This is the arithmetic trace of the fact that
`[2]` is not an automorphism of the formal group over `ℤ_2`. -/
theorem pow_dvd_den_double_two_iff {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ))
    (hy : y ≠ 0) (hdvd : 2 ∣ x.den) (m : ℕ) :
    2 ^ m ∣ ((x ^ 4 - 8 * (N : ℚ) * x) / (4 * y ^ 2)).den ↔ 2 ^ m ∣ 4 * x.den := by
  obtain ⟨a, b, e, he0, hle, hla, hlb, hxden, hx, hy'⟩ := mordell_param h Nat.prime_two hdvd
  have hb0 : b ≠ 0 := by
    rintro rfl
    apply hy
    simp [hy']
  have hB0 : (4 * b ^ 2 * (e : ℤ) ^ 2 : ℤ) ≠ 0 := by positivity
  have hnum : ¬(2 : ℤ) ∣ (a ^ 4 - 8 * N * a * (e : ℤ) ^ 6) := by
    intro hc
    have h6 : (2 : ℤ) ∣ 8 * N * a * (e : ℤ) ^ 6 := ⟨4 * N * a * (e : ℤ) ^ 6, by ring⟩
    have : (2 : ℤ) ∣ a ^ 4 := by simpa using dvd_add hc h6
    exact hla (Int.prime_two.dvd_of_dvd_pow this)
  rw [den_double_eq_int_frac (N := N) he0 hb0 hx hy', hxden]
  constructor
  · intro hm
    have h1 : (2 : ℤ) ^ m ∣ (4 * b ^ 2 * (e : ℤ) ^ 2 : ℤ) :=
      dvd_trans (by exact_mod_cast hm) (den_dvd_denom _ _)
    have hcop : IsCoprime ((2 : ℤ) ^ m) (b ^ 2 : ℤ) :=
      ((isCoprime_pow_of_not_dvd (ℓ := 2) Nat.prime_two (by exact_mod_cast hlb) m)).pow_right
    have h2 : (2 : ℤ) ^ m ∣ 4 * ((e : ℤ)) ^ 2 := by
      refine hcop.dvd_of_dvd_mul_right ?_
      calc (2 : ℤ) ^ m ∣ 4 * b ^ 2 * (e : ℤ) ^ 2 := h1
        _ = 4 * (e : ℤ) ^ 2 * b ^ 2 := by ring
    have h3 : ((2 ^ m : ℕ) : ℤ) ∣ ((4 * e ^ 2 : ℕ) : ℤ) := by push_cast; exact_mod_cast h2
    exact_mod_cast h3
  · intro hm
    refine prime_pow_dvd_den hB0 Nat.prime_two ?_ hnum
    have h2 : ((2 : ℤ)) ^ m ∣ 4 * ((e : ℤ)) ^ 2 := by
      have : ((2 ^ m : ℕ) : ℤ) ∣ ((4 * e ^ 2 : ℕ) : ℤ) := Int.natCast_dvd_natCast.mpr hm
      push_cast at this
      exact this
    calc (2 : ℤ) ^ m ∣ 4 * (e : ℤ) ^ 2 := h2
      _ ∣ 4 * b ^ 2 * (e : ℤ) ^ 2 := ⟨b ^ 2, by ring⟩

/-! ## Transport to the group law: stability along `2`-power multiples -/

/-- **The kernel of reduction is stable under doubling.**  If the `x`-coordinate of a point `Q`
of `E_N(ℚ)` (`N ∈ ℤ`) has denominator divisible by an odd prime `ℓ`, then so does the
`x`-coordinate of `Q + Q`, whenever the latter is affine. -/
theorem kernel_stable_double {N : ℤ} {ℓ : ℕ} (hl : ℓ.Prime) (hl2 : ℓ ≠ 2)
    {Q : (mordell ((N : ℤ) : ℚ)).toAffine.Point} {X X₂ : ℚ}
    (hQ : xCoord Q = some X) (hX : ℓ ∣ X.den) (hQ₂ : xCoord (Q + Q) = some X₂) :
    ℓ ∣ X₂.den := by
  cases Q with
  | zero => simp [xCoord] at hQ
  | @some x y hns =>
      have hxX : x = X := by simpa [xCoord] using hQ
      have hXx : ℓ ∣ x.den := by rw [hxX]; exact hX
      have heq : y ^ 2 = x ^ 3 + ((N : ℤ) : ℚ) := (mordell_equation_iff _ _ _).1 hns.1
      by_cases hy : y = 0
      · exfalso
        subst hy
        have hzero : Point.some hns + Point.some hns = 0 := by
          refine WeierstrassCurve.Affine.Point.add_self_of_Y_eq ?_
          simp [WeierstrassCurve.Affine.negY, mordell]
        rw [hzero] at hQ₂
        simp [xCoord] at hQ₂
      · have hdouble := mordell_double_xCoord ((N : ℤ) : ℚ) x y hns hy
        rw [hQ₂] at hdouble
        have hX₂ : X₂ = (x ^ 4 - 8 * ((N : ℤ) : ℚ) * x) / (4 * y ^ 2) := by
          simpa using hdouble
        rw [hX₂]
        have := (pow_dvd_den_double_iff_of_dvd_den (N := N) heq hy hl hl2 hXx 1).mpr
          (by simpa using hXx)
        simpa using this

/-- **Stability along all `2`-power multiples.**  If an odd prime `ℓ` divides the denominator of
the `x`-coordinate of `Q`, then it divides the denominator of the `x`-coordinate of `2^k • Q`
for every `k`. -/
theorem kernel_stable_two_pow {N : ℤ} {ℓ : ℕ} (hl : ℓ.Prime) (hl2 : ℓ ≠ 2)
    {Q : (mordell ((N : ℤ) : ℚ)).toAffine.Point} {X : ℚ}
    (hQ : xCoord Q = some X) (hX : ℓ ∣ X.den) :
    ∀ (k : ℕ) (Y : ℚ), xCoord ((2 ^ k) • Q) = some Y → ℓ ∣ Y.den := by
  intro k
  induction k with
  | zero =>
      intro Y hY
      simp only [pow_zero, one_smul] at hY
      rw [hQ] at hY
      have : X = Y := by simpa using hY
      rwa [← this]
  | succ k ih =>
      intro Y hY
      have hstep : (2 ^ (k + 1)) • Q = (2 ^ k) • Q + (2 ^ k) • Q := by
        rw [pow_succ, mul_comm, mul_smul, two_smul]
      rw [hstep] at hY
      have hex : ∃ z : ℚ, xCoord ((2 ^ k) • Q) = some z := by
        cases hRz : ((2 ^ k) • Q) with
        | zero =>
            exfalso
            rw [hRz, show (Point.zero : (mordell ((N : ℤ) : ℚ)).toAffine.Point) = 0 from rfl,
              add_zero] at hY
            simp [xCoord] at hY
        | @some z w hns => exact ⟨z, rfl⟩
      obtain ⟨z, hz⟩ := hex
      exact kernel_stable_double hl hl2 hz (ih z hz) hY

/-! ## The counterexample propagates: an infinite family on a single curve -/

/-- On `E_55 : y² = x³ + 55` with `P = (9, 28)`, the good-reduction prime `7` divides the
denominator of `x(2P)`. -/
lemma seven_dvd_den_double_55 :
    ∀ X : ℚ, xCoord (Point.some nonsingular_55_9_28 + Point.some nonsingular_55_9_28)
      = some X → 7 ∣ X.den := by
  intro X hX
  rw [counterexample_N55.1] at hX
  have : X = 2601 / 3136 := by simpa using hX.symm
  rw [this]
  norm_num

/-- **The counterexample is not isolated in the orbit.**  For `N = 55 = 5·11` and `P = (9,28)`,
the prime `7` — a prime of *good* reduction, `7 ∤ Δ = -432·55²` — divides the denominator of
the `x`-coordinate of `2^k P` for **every** `k ≥ 1`.  Thus a single curve and a single point
already produce infinitely many multiples violating the "only bad primes" conjecture. -/
theorem seven_dvd_den_two_pow_55 (k : ℕ) :
    ∀ X : ℚ, xCoord ((2 ^ k) • (Point.some nonsingular_55_9_28
      + Point.some nonsingular_55_9_28)) = some X → 7 ∣ X.den := by
  by_cases hz : xCoord (Point.some nonsingular_55_9_28 + Point.some nonsingular_55_9_28)
      = some (2601 / 3136 : ℚ)
  · refine kernel_stable_two_pow (N := 55) (ℓ := 7) (by norm_num) (by norm_num)
      (X := (2601 / 3136 : ℚ)) ?_ (by norm_num) k
    simpa using hz
  · exact absurd counterexample_N55.1 hz

end MordellDenominators