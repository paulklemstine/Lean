import Mathlib

/-!
# Denominator primes of doubled points on Mordell curves: the "only bad primes" conjecture is false

For `N : ℤ` let `E_N : y² = x³ + N` be the Mordell curve, whose discriminant is
`Δ = -432 N²`, so that the primes of bad reduction are exactly the primes dividing `6N`.

A conjecture arising in "elliptic curve factoring" folklore claims that if `N = p q` is a
semiprime and `P ∈ E_N(ℚ)` is an integral point, then the denominators of the `x`-coordinates
of the multiples `nP` are divisible only by the *bad* primes `{2, 3, p, q}`.  This file proves
that this conjecture is **false**, and isolates the exact arithmetic mechanism.

## Main results

* `mordell_double_xCoord` : the doubling formula
  `x(2P) = (x⁴ - 8Nx) / (4y²)` for `P = (x, y)` on `E_N`, derived from Mathlib's
  group law on `WeierstrassCurve.Affine.Point` (not postulated).
* `dvd_den_double_iff` : for an integral point `(x,y)` with `y ≠ 0` on `E_N` and a prime
  `ℓ ≥ 5` with `ℓ ∤ N` (i.e. a prime of **good reduction**),
  `ℓ ∣ den x(2P) ↔ ℓ ∣ y`.  So good primes routinely occur in denominators.
* `reduction_double_eq_zero` : the conceptual reason — over `𝔽_ℓ` the reduced point is
  `2`-torsion, i.e. `2 P̄ = O` in `E_N(𝔽_ℓ)`, so `2P` reduces to the point at infinity.
* `not_onlyBadPrimesConj` : the conjecture, stated in full generality over semiprime `N`,
  is false.  Explicit counterexample: `N = 55 = 5·11`, `P = (9, 28)`,
  `x(2P) = 2601/3136` with `3136 = 2⁶·7²` and `7 ∤ Δ = -432·55²`.
* `good_denominator_primes_infinite` : *every* prime `ℓ ≥ 5` occurs as a good-reduction
  denominator prime for some Mordell curve, so the set of such primes is infinite.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the "only bad primes" heuristic confuses two different facts:
  that `ℓ ∣ den x(nP)` forces `nP` to reduce to `O` mod `ℓ`, and that `ℓ` be a bad prime.
  Only the first is true; reduction to `O` happens at *good* primes as soon as the reduced
  point is torsion in `E(𝔽_ℓ)`.
Experiment (Experimenter): starting from Mathlib's affine group law we computed `x(2P)` and
  found `den x(2P) = 4y² / gcd(x⁴-8Nx, 4y²)`.  For `N = 55`, `P = (9,28)` we get
  `2601/3136` with `3136 = 2^6·7^2`, and `7 ∤ 6·55`.  A `python` sweep over 11 semiprimes
  (see `ComputationalEvidence.md`) found the "only `{2,3,p,q}`" property failing in 11/11
  cases already at `n = 2` or `n = 3`.
Analysis (Analyst): the failure is *structural*, not accidental: `ℓ ∣ y` is a codimension-one
  condition satisfied by roughly `|E(𝔽_ℓ)[2]|/ℓ` of the primes, and for every prime `ℓ ≥ 5`
  one can produce `(N, P)` realising it (`good_prime_realised`).  Hence the denominators are
  a function of `N` and `P` only, and contain no distinguished information about `p` and `q`.
Critique (Critic): the counterexample is a single numeric fact, so we strengthened it to the
  `iff` criterion `dvd_den_double_iff` (both directions proved), to the `𝔽_ℓ` group-law
  statement `reduction_double_eq_zero`, and to an infinitude statement.  Edge cases `y = 0`
  (2-torsion, where `x(2P)` is undefined) and `ℓ ∈ {2,3}` are excluded by hypothesis and are
  genuinely necessary: for `ℓ = 3`, `ℓ ∣ y` no longer forces `ℓ ∤ x⁴ - 8Nx`.
-/

namespace MordellDenominators

open WeierstrassCurve WeierstrassCurve.Affine

/-! ## The Mordell curve and its basic invariants -/

/-- The Mordell curve `y² = x³ + N` as a Weierstrass curve over any commutative ring. -/
def mordell {R : Type*} [CommRing R] (N : R) : WeierstrassCurve R := ⟨0, 0, 0, 0, N⟩

@[simp] lemma mordell_a₁ {R : Type*} [CommRing R] (N : R) : (mordell N).a₁ = 0 := rfl
@[simp] lemma mordell_a₂ {R : Type*} [CommRing R] (N : R) : (mordell N).a₂ = 0 := rfl
@[simp] lemma mordell_a₃ {R : Type*} [CommRing R] (N : R) : (mordell N).a₃ = 0 := rfl
@[simp] lemma mordell_a₄ {R : Type*} [CommRing R] (N : R) : (mordell N).a₄ = 0 := rfl
@[simp] lemma mordell_a₆ {R : Type*} [CommRing R] (N : R) : (mordell N).a₆ = N := rfl

/-- The discriminant of the Mordell curve is `-432 N²`. -/
lemma mordell_Δ {R : Type*} [CommRing R] (N : R) : (mordell N).Δ = -432 * N ^ 2 := by
  simp only [WeierstrassCurve.Δ, WeierstrassCurve.b₂, WeierstrassCurve.b₄,
    WeierstrassCurve.b₆, WeierstrassCurve.b₈, mordell_a₁, mordell_a₂, mordell_a₃,
    mordell_a₄, mordell_a₆]
  ring

/-- The affine Weierstrass equation of `mordell N` is `y² = x³ + N`. -/
lemma mordell_equation_iff {R : Type*} [CommRing R] (N x y : R) :
    (mordell N).toAffine.Equation x y ↔ y ^ 2 = x ^ 3 + N := by
  rw [WeierstrassCurve.Affine.equation_iff]
  simp only [mordell_a₁, mordell_a₂, mordell_a₃, mordell_a₄, mordell_a₆]
  constructor <;> intro h <;> linear_combination h

/-- The `x`-coordinate of an affine point, `none` at the point at infinity. -/
def xCoord {R : Type*} [CommRing R] {W : Affine R} : W.Point → Option R
  | .zero => none
  | @WeierstrassCurve.Affine.Point.some _ _ _ x _ _ => some x

/-! ## The doubling formula, derived from Mathlib's group law -/

/-- **Doubling formula.**  For a nonsingular point `P = (x, y)` with `y ≠ 0` on the Mordell
curve `y² = x³ + N` over `ℚ`, the `x`-coordinate of `2P` — computed with Mathlib's group law
on `WeierstrassCurve.Affine.Point` — equals `(x⁴ - 8Nx) / (4y²)`. -/
theorem mordell_double_xCoord (N x y : ℚ)
    (h : (mordell N).toAffine.Nonsingular x y) (hy : y ≠ 0) :
    xCoord (Point.some h + Point.some h) = some ((x ^ 4 - 8 * N * x) / (4 * y ^ 2)) := by
  have hne : y ≠ (mordell N).toAffine.negY x y := by
    simp only [WeierstrassCurve.Affine.negY, mordell_a₁, mordell_a₃, ne_eq]
    intro hc
    exact hy (by linarith)
  have heq : y ^ 2 = x ^ 3 + N := (mordell_equation_iff N x y).1 h.1
  rw [WeierstrassCurve.Affine.Point.add_self_of_Y_ne hne]
  simp only [xCoord, Option.some.injEq]
  rw [WeierstrassCurve.Affine.slope_of_Y_ne rfl hne]
  simp only [WeierstrassCurve.Affine.addX, WeierstrassCurve.Affine.negY,
    mordell_a₁, mordell_a₂, mordell_a₃, mordell_a₄]
  have h2 : y - (-y - 0 * x - 0) = 2 * y := by ring
  rw [h2, div_pow]
  field_simp
  linear_combination (-32 * x) * heq

/-! ## Denominators of rationals written as a quotient of integers -/

/-- If `q = A / B` in lowest terms then `q.num * B = A * q.den`. -/
lemma num_mul_den {A B : ℤ} (hB : B ≠ 0) :
    ((A : ℚ) / (B : ℚ)).num * B = A * (((A : ℚ) / (B : ℚ)).den : ℤ) := by
  set q : ℚ := (A : ℚ) / (B : ℚ) with hq
  have h1 : (q.num : ℚ) / (q.den : ℚ) = (A : ℚ) / (B : ℚ) := by rw [Rat.num_div_den]
  have hd : (q.den : ℚ) ≠ 0 := by exact_mod_cast q.den_ne_zero
  have hB' : (B : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hB
  rw [div_eq_div_iff hd hB'] at h1
  exact_mod_cast h1

/-- The reduced denominator of `A / B` divides `B`. -/
lemma den_dvd_denom (A B : ℤ) : (((A : ℚ) / (B : ℚ)).den : ℤ) ∣ B := by
  rw [← Rat.divInt_eq_div]
  exact Rat.den_dvd A B

/-- A prime dividing the denominator `B` but not the numerator `A` survives in the reduced
denominator of `A / B`. -/
lemma prime_dvd_den {A B : ℤ} (hB : B ≠ 0) {ℓ : ℕ} (hl : ℓ.Prime)
    (hlB : (ℓ : ℤ) ∣ B) (hlA : ¬(ℓ : ℤ) ∣ A) : ℓ ∣ ((A : ℚ) / (B : ℚ)).den := by
  have hp : Prime (ℓ : ℤ) := Nat.prime_iff_prime_int.mp hl
  have key := num_mul_den (A := A) (B := B) hB
  have h1 : (ℓ : ℤ) ∣ A * ((((A : ℚ) / (B : ℚ)).den : ℤ)) := key ▸ hlB.mul_left _
  rcases hp.dvd_mul.mp h1 with h | h
  · exact absurd h hlA
  · exact_mod_cast h

/-! ## Small primes do not divide the relevant constants -/

/-- A prime `ℓ ≥ 5` does not divide `2`. -/
lemma not_dvd_two {ℓ : ℕ} (hl5 : 5 ≤ ℓ) : ¬(ℓ : ℤ) ∣ 2 := fun h => by
  have := Int.le_of_dvd (by norm_num) h; omega

/-- A prime `ℓ ≥ 5` does not divide the discriminant constant `432 = 2⁴·3³`. -/
lemma not_dvd_432 {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) : ¬(ℓ : ℤ) ∣ 432 := by
  have hp : Prime (ℓ : ℤ) := Nat.prime_iff_prime_int.mp hl
  intro h
  have h2 : (ℓ : ℤ) ∣ (2 : ℤ) ^ 4 * 3 ^ 3 := by norm_num at h ⊢; exact h
  rcases hp.dvd_mul.mp h2 with h | h
  · have := Int.le_of_dvd (by norm_num) (hp.dvd_of_dvd_pow h); omega
  · have := Int.le_of_dvd (by norm_num) (hp.dvd_of_dvd_pow h); omega

/-! ## The arithmetic core: which primes divide `den x(2P)` -/

/-- **Key non-cancellation lemma.**  If `(x, y)` is an integral point of `E_N`, and `ℓ ≥ 5` is a
prime of good reduction (`ℓ ∤ N`) dividing `y`, then `ℓ` does *not* divide the numerator
`x⁴ - 8Nx` of `x(2P)`, so no cancellation can remove `ℓ` from the denominator. -/
lemma not_dvd_double_num {N x y : ℤ} (heq : y ^ 2 = x ^ 3 + N) {ℓ : ℕ} (hl : ℓ.Prime)
    (hl5 : 5 ≤ ℓ) (hlN : ¬(ℓ : ℤ) ∣ N) (hly : (ℓ : ℤ) ∣ y) : ¬(ℓ : ℤ) ∣ (x ^ 4 - 8 * N * x) := by
  have hp : Prime (ℓ : ℤ) := Nat.prime_iff_prime_int.mp hl
  have h3 : (ℓ : ℤ) ∣ x ^ 3 + N := by rw [← heq, sq]; exact hly.mul_left y
  intro hdvd
  have hfac : (ℓ : ℤ) ∣ x * (x ^ 3 - 8 * N) := by
    have hx4 : x ^ 4 - 8 * N * x = x * (x ^ 3 - 8 * N) := by ring
    rwa [hx4] at hdvd
  rcases hp.dvd_mul.mp hfac with hx | hc
  · refine hlN ?_
    have hx3 : (ℓ : ℤ) ∣ x ^ 3 := hx.pow (by norm_num)
    simpa using dvd_sub h3 hx3
  · have h9 : (ℓ : ℤ) ∣ 9 * N := by
      have h9' : 9 * N = (x ^ 3 + N) - (x ^ 3 - 8 * N) := by ring
      rw [h9']; exact dvd_sub h3 hc
    rcases hp.dvd_mul.mp h9 with h9' | hN
    · have h3' : (ℓ : ℤ) ∣ 3 := hp.dvd_of_dvd_pow (n := 2) (by norm_num at h9' ⊢; exact h9')
      have := Int.le_of_dvd (by norm_num) h3'
      omega
    · exact hlN hN

/-- **Denominator criterion at good primes.**  Let `(x, y)` be an integral point with `y ≠ 0`
on the Mordell curve `y² = x³ + N`, and let `ℓ ≥ 5` be a prime with `ℓ ∤ N`, i.e. a prime of
good reduction.  Then `ℓ` divides the denominator of `x(2P)` **iff** `ℓ ∣ y`.

This is the precise mechanism behind the failure of the "only bad primes" conjecture: the
condition `ℓ ∣ y` has nothing to do with `ℓ` dividing the discriminant. -/
theorem dvd_den_double_iff {N x y : ℤ} (heq : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0) {ℓ : ℕ}
    (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) (hlN : ¬(ℓ : ℤ) ∣ N) :
    ℓ ∣ (((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)).den ↔ (ℓ : ℤ) ∣ y := by
  have hp : Prime (ℓ : ℤ) := Nat.prime_iff_prime_int.mp hl
  have hB : (4 * y ^ 2 : ℤ) ≠ 0 := by positivity
  have hcast : ((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)
      = ((x ^ 4 - 8 * N * x : ℤ) : ℚ) / ((4 * y ^ 2 : ℤ) : ℚ) := by push_cast; ring
  rw [hcast]
  constructor
  · intro h
    have h1 : (ℓ : ℤ) ∣ (4 * y ^ 2 : ℤ) :=
      dvd_trans (by exact_mod_cast h) (den_dvd_denom _ _)
    rcases hp.dvd_mul.mp h1 with h4 | hy2
    · exact absurd (hp.dvd_of_dvd_pow (n := 2) (by norm_num at h4 ⊢; exact h4))
        (not_dvd_two hl5)
    · exact hp.dvd_of_dvd_pow hy2
  · intro hly
    refine prime_dvd_den hB hl ?_ (not_dvd_double_num heq hl hl5 hlN hly)
    exact Dvd.dvd.mul_left ((hly.mul_right y).trans (by rw [sq])) 4

/-- **Good reduction criterion.**  A prime `ℓ ≥ 5` not dividing `N` does not divide the
discriminant `Δ = -432 N²` of `E_N`; i.e. `E_N` has good reduction at `ℓ`. -/
lemma not_dvd_Δ {N : ℤ} {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) (hlN : ¬(ℓ : ℤ) ∣ N) :
    ¬(ℓ : ℤ) ∣ (mordell N).Δ := by
  have hp : Prime (ℓ : ℤ) := Nat.prime_iff_prime_int.mp hl
  rw [mordell_Δ]
  intro h
  rcases hp.dvd_mul.mp h with h1 | h2
  · exact not_dvd_432 hl hl5 (dvd_neg.mp h1)
  · exact hlN (hp.dvd_of_dvd_pow h2)

/-! ## The counterexample `N = 55 = 5 · 11`, `P = (9, 28)` -/

/-- `(9, 28)` is a nonsingular point of `E_55 : y² = x³ + 55` (indeed `28² = 784 = 9³ + 55`). -/
lemma nonsingular_55_9_28 : (mordell (((5 * 11 : ℕ) : ℚ))).toAffine.Nonsingular 9 28 := by
  have hΔ : (mordell (((5 * 11 : ℕ) : ℚ))).Δ ≠ 0 := by rw [mordell_Δ]; norm_num
  exact (WeierstrassCurve.Affine.equation_iff_nonsingular_of_Δ_ne_zero hΔ).mp
    ((mordell_equation_iff _ _ _).mpr (by norm_num))

/-- **The explicit counterexample.**  On `E_55 : y² = x³ + 55` with `55 = 5 · 11`, doubling the
integral point `P = (9, 28)` gives `x(2P) = 2601/3136` with `3136 = 2⁶ · 7²`.  The prime `7`
divides this denominator, yet `7` is a prime of **good** reduction: `7 ∤ Δ = -432 · 55²`. -/
theorem counterexample_N55 :
    xCoord (Point.some nonsingular_55_9_28 + Point.some nonsingular_55_9_28)
        = some (2601 / 3136 : ℚ) ∧
      ((2601 / 3136 : ℚ)).den = 2 ^ 6 * 7 ^ 2 ∧ (7 : ℕ).Prime ∧
      7 ∣ ((2601 / 3136 : ℚ)).den ∧ ¬(7 : ℤ) ∣ (mordell (55 : ℤ)).Δ := by
  refine ⟨?_, by norm_num, by norm_num, by norm_num, ?_⟩
  · rw [mordell_double_xCoord _ _ _ nonsingular_55_9_28 (by norm_num)]
    norm_num
  · exact not_dvd_Δ (ℓ := 7) (by norm_num) (by norm_num) (by decide)

/-! ## The "only bad primes" conjecture and its refutation -/

/-- `DvdXDen ℓ Q` says that `Q` is an affine point whose `x`-coordinate has a denominator
divisible by `ℓ`. -/
def DvdXDen (ℓ : ℕ) {W : Affine ℚ} (Q : W.Point) : Prop :=
  ∃ X : ℚ, xCoord Q = some X ∧ ℓ ∣ X.den

/-- **The "only bad primes" conjecture.**  For `N = p q` a semiprime and `P` a nonsingular
rational point of `E_N` which is not `2`-torsion, every prime dividing the denominator of
`x(2P)` lies in `{2, 3, p, q}`, i.e. divides the discriminant `Δ = -432 N²`. -/
def OnlyBadPrimesConj : Prop :=
  ∀ p q : ℕ, p.Prime → q.Prime → p ≠ q →
    ∀ (x y : ℚ) (h : (mordell (((p * q : ℕ) : ℚ))).toAffine.Nonsingular x y), y ≠ 0 →
      ∀ ℓ : ℕ, ℓ.Prime → DvdXDen ℓ (Point.some h + Point.some h) →
        ℓ = 2 ∨ ℓ = 3 ∨ ℓ = p ∨ ℓ = q

/-- **Main theorem: the conjecture is false.**  Witness: `N = 55 = 5 · 11`, `P = (9, 28)`,
`x(2P) = 2601/3136 = 2601/(2⁶ · 7²)`, and `ℓ = 7 ∉ {2, 3, 5, 11}`. -/
theorem not_onlyBadPrimesConj : ¬OnlyBadPrimesConj := by
  intro hconj
  have hx := (counterexample_N55).1
  have h7 : DvdXDen 7 (Point.some nonsingular_55_9_28 + Point.some nonsingular_55_9_28) :=
    ⟨2601 / 3136, hx, by norm_num⟩
  have := hconj 5 11 (by norm_num) (by norm_num) (by norm_num) 9 28
    nonsingular_55_9_28 (by norm_num) 7 (by norm_num) h7
  omega

/-! ## The conceptual mechanism: reduction to the point at infinity mod `ℓ` -/

/-- **Reduction is `2`-torsion.**  Let `(x, y)` be an integral point of `E_N` and `ℓ ≥ 5` a prime
of good reduction (`ℓ ∤ N`) with `ℓ ∣ y`.  Then the reduced point `(x̄, ȳ)` is a nonsingular
point of `E_N` over `𝔽_ℓ` and `2 · (x̄, ȳ) = O` in the group `E_N(𝔽_ℓ)`.

Combined with `dvd_den_double_iff`, this shows the equivalence
`ℓ ∣ den x(2P)  ↔  ℓ ∣ y  ↔  2P ≡ O (mod ℓ)`:
denominators are governed by reduction to the identity, not by bad reduction. -/
theorem reduction_double_eq_zero {N x y : ℤ} {ℓ : ℕ} [hF : Fact ℓ.Prime] (hl5 : 5 ≤ ℓ)
    (hlN : ¬(ℓ : ℤ) ∣ N) (heq : y ^ 2 = x ^ 3 + N) (hly : (ℓ : ℤ) ∣ y) :
    ∃ h : (mordell ((N : ZMod ℓ))).toAffine.Nonsingular ((x : ZMod ℓ)) ((y : ZMod ℓ)),
      Point.some h + Point.some h = 0 := by
  have hl := hF.out
  have hN0 : (N : ZMod ℓ) ≠ 0 := by
    rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]; exact hlN
  have h432 : (432 : ZMod ℓ) ≠ 0 := by
    have h : ((432 : ℤ) : ZMod ℓ) ≠ 0 := by
      rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
      exact not_dvd_432 hl hl5
    simpa using h
  have hΔ : (mordell ((N : ZMod ℓ))).Δ ≠ 0 := by
    rw [mordell_Δ]; simp [h432, hN0]
  have heq' : ((y : ZMod ℓ)) ^ 2 = ((x : ZMod ℓ)) ^ 3 + (N : ZMod ℓ) := by
    exact_mod_cast congrArg (fun t : ℤ => (t : ZMod ℓ)) heq
  refine ⟨(WeierstrassCurve.Affine.equation_iff_nonsingular_of_Δ_ne_zero hΔ).mp
    ((mordell_equation_iff _ _ _).mpr heq'), ?_⟩
  have hy0 : ((y : ZMod ℓ)) = 0 := by
    rw [ZMod.intCast_zmod_eq_zero_iff_dvd]; exact hly
  refine WeierstrassCurve.Affine.Point.add_self_of_Y_eq ?_
  simp [WeierstrassCurve.Affine.negY, mordell, hy0]

/-! ## Every prime `ℓ ≥ 5` is a good-reduction denominator prime -/

/-- **Realisation theorem.**  For *every* prime `ℓ ≥ 5` there is a Mordell curve `E_N` and an
integral point `P = (x, y)` on it such that `ℓ` divides the denominator of `x(2P)` while `E_N`
has good reduction at `ℓ`.  Witness: `N = ℓ² - 1`, `P = (1, ℓ)`, where
`x(2P) = (9 - 8ℓ²)/(4ℓ²)`. -/
theorem good_prime_realised {ℓ : ℕ} (hl : ℓ.Prime) (hl5 : 5 ≤ ℓ) :
    ∃ N x y : ℤ, N ≠ 0 ∧ y ≠ 0 ∧ y ^ 2 = x ^ 3 + N ∧ ¬(ℓ : ℤ) ∣ (mordell N).Δ ∧
      ℓ ∣ (((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)).den := by
  have hl0 : (5 : ℤ) ≤ (ℓ : ℤ) := by exact_mod_cast hl5
  refine ⟨(ℓ : ℤ) ^ 2 - 1, 1, (ℓ : ℤ), by nlinarith, by omega, by ring, ?_, ?_⟩ <;>
    have hlN : ¬(ℓ : ℤ) ∣ ((ℓ : ℤ) ^ 2 - 1) := by
      intro h
      have h1 : (ℓ : ℤ) ∣ 1 := by
        have h2 : (ℓ : ℤ) ∣ (ℓ : ℤ) ^ 2 := dvd_pow_self _ (by norm_num)
        simpa using dvd_sub h2 h
      have := Int.le_of_dvd (by norm_num) h1
      omega
  · exact not_dvd_Δ hl hl5 hlN
  · exact (dvd_den_double_iff (by ring) (by omega) hl hl5 hlN).mpr dvd_rfl

/-- The set of primes that occur as *good-reduction* denominator primes of a doubled integral
point on some Mordell curve. -/
def GoodDenominatorPrimes : Set ℕ :=
  {ℓ | ℓ.Prime ∧ ∃ N x y : ℤ, N ≠ 0 ∧ y ≠ 0 ∧ y ^ 2 = x ^ 3 + N ∧
    ¬(ℓ : ℤ) ∣ (mordell N).Δ ∧
    ℓ ∣ (((x : ℚ) ^ 4 - 8 * (N : ℚ) * (x : ℚ)) / (4 * (y : ℚ) ^ 2)).den}

/-- **Infinitude.**  Infinitely many primes occur as good-reduction denominator primes, so the
failure of the "only bad primes" conjecture is not an isolated numerical accident: no finite
set of primes (in particular no set determined by the factorisation of `N`) can contain all
denominator primes across Mordell curves. -/
theorem good_denominator_primes_infinite : GoodDenominatorPrimes.Infinite := by
  have hsub : {ℓ : ℕ | ℓ.Prime} \ {2, 3} ⊆ GoodDenominatorPrimes := by
    rintro m ⟨hp, hn⟩
    have hp' : m.Prime := hp
    have h5 : 5 ≤ m := by
      by_contra hlt
      push_neg at hlt
      interval_cases m <;> simp_all (config := { decide := true })
    exact ⟨hp', good_prime_realised hp' h5⟩
  refine Set.Infinite.mono hsub ?_
  exact Set.Infinite.diff Nat.infinite_setOf_prime (Set.toFinite _)

end MordellDenominators