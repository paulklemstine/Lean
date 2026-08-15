import Applications.MordellDenominatorLocalLaw
import Applications.MordellDenominatorOrbits

/-!
# The denominator kernel is a subgroup: `ℓ ∣ den x(P)` propagates to every multiple

Cycle 3 showed that a prime dividing the denominator of `x(P)` still divides the denominator of
`x(2P)`, with the same exponent when `ℓ` is odd.  The natural completion — and the first
conjecture of `FUTURE_DIRECTIONS.md` — is that the set

`E_ℓ(ℚ) = {P : ℓ ∣ den x(P)} ∪ {O}`

is closed under the *chord* as well as the tangent, i.e. that it is a subgroup of `E_N(ℚ)`.
This file proves it, by an elementary argument that avoids the formal group entirely.

The mechanism: if `P + Q = S` with `P, Q` in the kernel but `S` outside it, then `S` is
`ℓ`-integral, and writing `P = S - Q` through the chord formula

`x(S - Q) = (x_S x_Q (x_S + x_Q) + 2N + 2 y_S y_Q) / (x_S - x_Q)²`

(the numerator identity uses the curve equation twice) exhibits `x(P)` as a fraction whose
denominator is prime to `ℓ` — contradicting `ℓ ∣ den x(P)`.  Note that the argument works at
**every** prime, including `ℓ = 2` and primes of bad reduction.

## Main results

* `chord_x_eq` : the chord formula in the shape `x₃ = (x₁x₂(x₁+x₂) + 2N − 2y₁y₂)/(x₁−x₂)²`,
  derived from the two curve equations.
* `chord_den_not_dvd_of_kernel` : the arithmetic core — subtracting a kernel point from an
  `ℓ`-integral point yields an `ℓ`-integral `x`-coordinate.
* `kernel_stable_add` : **the kernel is closed under addition**, at every prime.
* `dvd_den_nsmul` : consequently `ℓ ∣ den x(nP)` for every `n ≥ 1` once `ℓ ∣ den x(P)`.
* `seven_dvd_den_nsmul_double_55` : on `E_55` with `P = (9,28)`, the good prime `7` divides the
  denominator of `x(2nP)` for every `n ≥ 1` — an infinite family of counterexamples to the
  "only bad primes" conjecture inside a single orbit.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 6): the `2`-power stability of cycle 3 is a shadow of full
  subgroup-closure; the chord case should follow from the same coprime parametrisation.
Experiment (Experimenter): the naive estimate fails — in the chord formula the terms `s²` and
  `x₁` have the same `ℓ`-adic size when the two points have equal denominator valuation, so no
  direct valuation count settles the case.  Reversing the implication (assume the sum leaves
  the kernel and subtract) removes the cancellation: every term of the resulting numerator is
  divisible by the same power of `e`, and the denominator `(m₁e² − a n₁)² n₂` is a unit at `ℓ`.
Analysis (Analyst): the identity `x₃(x₁−x₂)² = x₁x₂(x₁+x₂) + 2N − 2y₁y₂` is what makes this
  elementary: it eliminates the slope and leaves a polynomial expression in which the curve
  parameters enter only through `N`.
Critique (Critic): the theorem is not vacuous (`seven_dvd_den_nsmul_double_55` exhibits an
  infinite family), it needs no hypothesis on the reduction type of `ℓ`, and the degenerate
  cases (`P = ±Q`, sums equal to `O`) are handled explicitly rather than excluded.
-/

namespace MordellDenominators

open WeierstrassCurve WeierstrassCurve.Affine

/-! ## Local integrality toolkit -/

/-- If a prime misses the denominator of an integer fraction, it misses the reduced
denominator. -/
lemma not_dvd_den_of_frac {ℓ : ℕ} {A B : ℤ} (hB : ¬(ℓ : ℤ) ∣ B) :
    ¬ ℓ ∣ (((A : ℚ)) / ((B : ℚ))).den := fun h =>
  hB (dvd_trans (by exact_mod_cast h) (den_dvd_denom A B))

/-- `ℓ`-integrality of the `x`-coordinate transfers to the `y`-coordinate. -/
lemma not_dvd_den_y {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + (N : ℚ)) {ℓ : ℕ} (hl : ℓ.Prime)
    (hx : ¬ ℓ ∣ x.den) : ¬ ℓ ∣ y.den := by
  obtain ⟨e, hxe, hye⟩ := mordell_den_pow_structure h
  intro hy
  rw [hye] at hy
  exact hx (by rw [hxe]; exact dvd_pow (hl.dvd_of_dvd_pow hy) two_ne_zero)

/-! ## The chord formula without the slope -/

/-- **Chord formula.**  For two rational points of `E_N : y² = x³ + N` with distinct
`x`-coordinates, the `x`-coordinate of the third intersection point of the chord is
`(x₁x₂(x₁+x₂) + 2N − 2y₁y₂)/(x₁−x₂)²`.  The slope has been eliminated using both curve
equations. -/
lemma chord_x_eq {N : ℚ} {x₁ y₁ x₂ y₂ : ℚ} (h₁ : y₁ ^ 2 = x₁ ^ 3 + N)
    (h₂ : y₂ ^ 2 = x₂ ^ 3 + N) (hne : x₁ ≠ x₂) :
    ((y₁ - y₂) / (x₁ - x₂)) ^ 2 - x₁ - x₂
      = (x₁ * x₂ * (x₁ + x₂) + 2 * N - 2 * y₁ * y₂) / (x₁ - x₂) ^ 2 := by
  have hd : x₁ - x₂ ≠ 0 := sub_ne_zero.mpr hne
  field_simp
  linear_combination h₁ + h₂

/-! ## The arithmetic core -/

/-- **Subtracting a kernel point from an `ℓ`-integral point stays `ℓ`-integral.**  Let
`(xs, ys)` and `(xr, yr)` be rational points of `E_N` (`N ∈ ℤ`) with `ℓ ∤ den xs` and
`ℓ ∣ den xr`.  Then the chord expression
`(xs·xr·(xs+xr) + 2N + 2·ys·yr)/(xs − xr)²` — which is the `x`-coordinate of the difference of
the two points — has denominator prime to `ℓ`. -/
lemma chord_den_not_dvd_of_kernel {N : ℤ} {xs ys xr yr : ℚ}
    (hs : ys ^ 2 = xs ^ 3 + ((N : ℤ) : ℚ)) (hr : yr ^ 2 = xr ^ 3 + ((N : ℤ) : ℚ)) {ℓ : ℕ}
    (hl : ℓ.Prime) (hxs : ¬ ℓ ∣ xs.den) (hxr : ℓ ∣ xr.den) :
    ¬ ℓ ∣ ((xs * xr * (xs + xr) + 2 * ((N : ℤ) : ℚ) + 2 * ys * yr) / (xs - xr) ^ 2).den := by
  obtain ⟨a, b, e, he0, hle, hla, hlb, hxrden, hxr', hyr'⟩ := mordell_param hr hl hxr
  have hp : Prime (ℓ : ℤ) := Nat.prime_iff_prime_int.mp hl
  set m₁ : ℤ := xs.num with hm₁
  set n₁ : ℤ := (xs.den : ℤ) with hn₁
  set m₂ : ℤ := ys.num with hm₂
  set n₂ : ℤ := (ys.den : ℤ) with hn₂
  have hn₁0 : (n₁ : ℚ) ≠ 0 := by
    rw [hn₁]; exact_mod_cast (Int.natCast_ne_zero.mpr xs.den_nz)
  have hn₂0 : (n₂ : ℚ) ≠ 0 := by
    rw [hn₂]; exact_mod_cast (Int.natCast_ne_zero.mpr ys.den_nz)
  have hE0 : ((e : ℚ)) ≠ 0 := by
    have : (0 : ℚ) < (e : ℚ) := by exact_mod_cast he0
    exact ne_of_gt this
  have hxs_eq : xs = (m₁ : ℚ) / (n₁ : ℚ) := by
    rw [hm₁, hn₁]; exact_mod_cast (Rat.num_div_den xs).symm
  have hys_eq : ys = (m₂ : ℚ) / (n₂ : ℚ) := by
    rw [hm₂, hn₂]; exact_mod_cast (Rat.num_div_den ys).symm
  have hln₁ : ¬(ℓ : ℤ) ∣ n₁ := by
    intro hc
    exact hxs (by rw [hn₁] at hc; exact_mod_cast hc)
  have hln₂ : ¬(ℓ : ℤ) ∣ n₂ := by
    intro hc
    exact not_dvd_den_y hs hl hxs (by rw [hn₂] at hc; exact_mod_cast hc)
  -- the two `x`-coordinates are distinct
  have hxne : xs ≠ xr := by
    intro hc
    exact hxs (by rw [hc]; exact hxr)
  have hkey0 : m₁ * (e : ℤ) ^ 2 - a * n₁ ≠ 0 := by
    intro hc
    refine hxne ?_
    have hq : (m₁ : ℚ) * ((e : ℚ)) ^ 2 - (a : ℚ) * (n₁ : ℚ) = 0 := by exact_mod_cast hc
    rw [hxs_eq, hxr']
    field_simp
    linarith [hq]
  have hden0 : (xs - xr) ^ 2 ≠ 0 := pow_ne_zero _ (sub_ne_zero.mpr hxne)
  -- rewrite the chord expression as a fraction of integers
  set A : ℤ := m₁ * a * (m₁ * (e : ℤ) ^ 2 + a * n₁) * n₂ + 2 * N * n₁ ^ 2 * (e : ℤ) ^ 4 * n₂
    + 2 * m₂ * b * n₁ ^ 2 * (e : ℤ) with hA
  set B : ℤ := (m₁ * (e : ℤ) ^ 2 - a * n₁) ^ 2 * n₂ with hB
  have hB0 : ((B : ℚ)) ≠ 0 := by
    rw [hB]
    have h1 : ((m₁ * (e : ℤ) ^ 2 - a * n₁ : ℤ) : ℚ) ≠ 0 := by
      exact_mod_cast hkey0
    have h2 : ((n₂ : ℤ) : ℚ) ≠ 0 := by exact_mod_cast hn₂0
    push_cast
    push_cast at h1 h2
    exact mul_ne_zero (pow_ne_zero _ h1) h2
  have hfrac : (xs * xr * (xs + xr) + 2 * ((N : ℤ) : ℚ) + 2 * ys * yr) / (xs - xr) ^ 2
      = ((A : ℤ) : ℚ) / ((B : ℤ) : ℚ) := by
    rw [hxs_eq, hys_eq, hxr', hyr', hA, hB]
    push_cast
    field_simp
  rw [hfrac]
  refine not_dvd_den_of_frac ?_
  rw [hB]
  intro hdvd
  rcases hp.dvd_mul.mp hdvd with h1 | h2
  · have h3 : (ℓ : ℤ) ∣ (m₁ * (e : ℤ) ^ 2 - a * n₁) := hp.dvd_of_dvd_pow h1
    have h4 : (ℓ : ℤ) ∣ m₁ * (e : ℤ) ^ 2 := Dvd.dvd.mul_left (dvd_pow hle (by norm_num)) _
    have h5 : (ℓ : ℤ) ∣ a * n₁ := by
      have := dvd_sub h4 h3
      simpa using this
    rcases hp.dvd_mul.mp h5 with ha | hn
    · exact hla ha
    · exact hln₁ hn
  · exact hln₂ h2

/-! ## The kernel is a subgroup -/

/-- **Closure under addition.**  If a prime `ℓ` divides the denominators of the
`x`-coordinates of two points `Q, R` of `E_N(ℚ)` (`N ∈ ℤ`), then it divides the denominator of
the `x`-coordinate of `Q + R`, whenever the latter is affine.  No hypothesis on `ℓ` beyond
primality is needed. -/
theorem kernel_stable_add {N : ℤ} {ℓ : ℕ} (hl : ℓ.Prime)
    {Q R : (mordell ((N : ℤ) : ℚ)).toAffine.Point} {XQ XR XS : ℚ}
    (hQ : xCoord Q = some XQ) (hR : xCoord R = some XR)
    (hXQ : ℓ ∣ XQ.den) (hXR : ℓ ∣ XR.den)
    (hS : xCoord (Q + R) = some XS) : ℓ ∣ XS.den := by
  by_contra hns
  cases hRc : R with
  | zero => rw [hRc] at hR; simp [xCoord] at hR
  | @some xr yr hnsr =>
      cases hSc : (Q + R) with
      | zero => rw [hSc] at hS; simp [xCoord] at hS
      | @some xt yt hnst =>
          have hxrX : xr = XR := by rw [hRc] at hR; simpa [xCoord] using hR
          have hxtX : xt = XS := by rw [hSc] at hS; simpa [xCoord] using hS
          have heqr : yr ^ 2 = xr ^ 3 + ((N : ℤ) : ℚ) := (mordell_equation_iff _ _ _).1 hnsr.1
          have heqt : yt ^ 2 = xt ^ 3 + ((N : ℤ) : ℚ) := (mordell_equation_iff _ _ _).1 hnst.1
          have hxrden : ℓ ∣ xr.den := by rw [hxrX]; exact hXR
          have hxtden : ¬ ℓ ∣ xt.den := by rw [hxtX]; exact hns
          have hxne : xt ≠ xr := by
            intro hc
            exact hxtden (by rw [hc]; exact hxrden)
          -- `Q = (Q + R) - R`
          have hQeq : Q = Point.some hnst + (-(Point.some hnsr)) := by
            have h1 : Q = (Q + R) - R := by abel
            rw [h1, hSc, hRc]
            rfl
          have hnegr : -(Point.some hnsr)
              = Point.some ((WeierstrassCurve.Affine.nonsingular_neg ..).mpr hnsr) :=
            WeierstrassCurve.Affine.Point.neg_some hnsr
          rw [hnegr, WeierstrassCurve.Affine.Point.add_of_X_ne (by
            simpa [WeierstrassCurve.Affine.negY, mordell] using hxne)] at hQeq
          have hXQval : XQ = ((yt - (-yr)) / (xt - xr)) ^ 2 - xt - xr := by
            have : xCoord Q = some ((mordell ((N : ℤ) : ℚ)).toAffine.addX xt xr
                ((mordell ((N : ℤ) : ℚ)).toAffine.slope xt xr yt
                  ((mordell ((N : ℤ) : ℚ)).toAffine.negY xr yr))) := by
              rw [hQeq]; rfl
            rw [hQ] at this
            have hval := (Option.some.injEq _ _ ▸ this).symm
            rw [WeierstrassCurve.Affine.slope_of_X_ne hxne] at hval
            simp only [WeierstrassCurve.Affine.addX, WeierstrassCurve.Affine.negY,
              mordell] at hval
            rw [← hval]
            ring
          have hnegeq : (-yr) ^ 2 = xr ^ 3 + ((N : ℤ) : ℚ) := by
            rw [neg_pow]; simpa using heqr
          have hchord := chord_x_eq (N := ((N : ℤ) : ℚ)) heqt hnegeq hxne
          rw [hXQval, hchord] at hXQ
          have hform : (xt * xr * (xt + xr) + 2 * ((N : ℤ) : ℚ) - 2 * yt * (-yr))
              / (xt - xr) ^ 2
              = (xt * xr * (xt + xr) + 2 * ((N : ℤ) : ℚ) + 2 * yt * yr) / (xt - xr) ^ 2 := by
            ring_nf
          rw [hform] at hXQ
          exact chord_den_not_dvd_of_kernel heqt heqr hl hxtden hxrden hXQ

/-! ## Every multiple stays in the kernel -/

/-- **All multiples.**  If a prime `ℓ` divides the denominator of the `x`-coordinate of a point
`Q` of `E_N(ℚ)` (`N ∈ ℤ`), then it divides the denominator of the `x`-coordinate of `n • Q` for
every `n`, whenever that multiple is affine. -/
theorem dvd_den_nsmul {N : ℤ} {ℓ : ℕ} (hl : ℓ.Prime)
    {Q : (mordell ((N : ℤ) : ℚ)).toAffine.Point} {X : ℚ}
    (hQ : xCoord Q = some X) (hX : ℓ ∣ X.den) :
    ∀ (n : ℕ) (Y : ℚ), xCoord (n • Q) = some Y → ℓ ∣ Y.den := by
  intro n
  induction n with
  | zero =>
      intro Y hY
      simp [xCoord] at hY
  | succ n ih =>
      intro Y hY
      have hstep : (n + 1) • Q = n • Q + Q := by
        rw [succ_nsmul]
      rw [hstep] at hY
      cases hnc : (n • Q) with
      | zero =>
          rw [hnc] at hY
          rw [show (Point.zero : (mordell ((N : ℤ) : ℚ)).toAffine.Point) = 0 from rfl,
            zero_add] at hY
          rw [hQ] at hY
          have : X = Y := by simpa using hY
          rwa [← this]
      | @some z w hnsz =>
          have hz : xCoord (n • Q) = some z := by rw [hnc]; rfl
          exact kernel_stable_add hl hz hQ (ih z hz) hX hY

/-! ## An infinite family of counterexamples inside one orbit -/

/-- **The good prime `7` divides the denominator of every even multiple of `P = (9,28)` on
`E_55`.**  Combined with `7 ∤ Δ = -432 · 55²`, this exhibits infinitely many multiples of a
single point violating the "only bad primes" conjecture. -/
theorem seven_dvd_den_nsmul_double_55 (n : ℕ) :
    ∀ X : ℚ, xCoord (n • ((Point.some nonsingular_int_55_9_28
      + Point.some nonsingular_int_55_9_28 :
        (mordell (((55 : ℤ)) : ℚ)).toAffine.Point))) = some X → 7 ∣ X.den := by
  refine dvd_den_nsmul (N := 55) (ℓ := 7) (by norm_num)
    (X := (2601 / 3136 : ℚ)) ?_ (by norm_num) n
  rw [mordell_double_xCoord _ _ _ nonsingular_int_55_9_28 (by norm_num)]
  norm_num

end MordellDenominators