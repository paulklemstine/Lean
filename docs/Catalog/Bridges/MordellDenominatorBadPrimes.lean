/-
# The "Only Bad Primes" conjecture for Mordell-curve denominators is false

Consider the Mordell curve `E_N : y² = x³ + N` over `ℚ`, whose discriminant is
`Δ = -432 N²`, so that the primes of bad reduction are contained in
`{2, 3} ∪ {primes dividing N}`.  For `N = p q` a semiprime the *"only bad primes"
conjecture* asserts that the denominator of the `x`-coordinate of `nP`, for `P` a
rational (indeed integral) point, is divisible only by the primes `2, 3, p, q`.

This file **refutes** that conjecture, already for `n = 2`, and explains the
mechanism:

* `Bridges.MordellDenominator.dblX_eq_addX` bridges the elementary duplication
  formula `x(2P) = (x⁴ - 8Nx) / (4(x³+N))` with mathlib's group law on
  `WeierstrassCurve.Affine.Point`.
* `Bridges.MordellDenominator.prime_dvd_den_dblX_iff` is the **mechanism theorem**:
  for an integral point `(x,y)` with `y ≠ 0` and a prime `ℓ ∤ 6N` (i.e. a prime of
  good reduction, `ℓ ∤ Δ`), one has `ℓ ∣ den(x(2P)) ↔ ℓ ∣ y`.
* `Bridges.MordellDenominator.den_dvd_iff_reduction_two_torsion` upgrades this to a
  statement about the reduced curve over `ZMod ℓ`: `ℓ` divides the denominator iff
  the reduction of `P` is a point of order dividing 2 (`P̄ + P̄ = 0`).
* `Bridges.MordellDenominator.onlyBadPrimes_false` refutes the conjecture using the
  explicit semiprime counterexample `N = 55 = 5·11`, `P = (9, 28)`,
  `x(2P) = 2601/3136` with `3136 = 2⁶·7²` and `7 ∤ Δ`.
* `Bridges.MordellDenominator.counterexample_899` gives a second semiprime
  counterexample `N = 899 = 29·31`, `P = (1,30)`, produced by the twin-prime
  mechanism `25m² - 1 = (5m-1)(5m+1)`.
* `Bridges.MordellDenominator.badSet_infinite` shows the failure is not sporadic:
  infinitely many `N` admit an integral point whose duplicate has a good-reduction
  prime in its denominator.
* `Bridges.MordellDenominator.prime_dvd_den_dblX_dvd_two_mul` is the *repaired*
  (true) statement: every prime dividing `den(x(2P))` divides `2y`.
-/
import Mathlib

namespace Bridges.MordellDenominator

open WeierstrassCurve

/-! ## The Mordell curve and its discriminant -/

/-- The Mordell curve `y² = x³ + N` in affine Weierstrass form, over any commutative ring. -/
def mordellC {R : Type*} [CommRing R] (N : R) : Affine R := ⟨0, 0, 0, 0, N⟩

/-- The Mordell curve over `ℚ`. -/
abbrev mordell (N : ℚ) : Affine ℚ := mordellC N

lemma mordellC_equation_iff {R : Type*} [CommRing R] (N x y : R) :
    (mordellC N).Equation x y ↔ y ^ 2 = x ^ 3 + N := by
  rw [Affine.equation_iff]; simp [mordellC]

lemma mordellC_negY {R : Type*} [CommRing R] (N x y : R) : (mordellC N).negY x y = -y := by
  simp [mordellC]

/-- The discriminant of the Mordell curve `y² = x³ + N` is `-432 N²`. -/
lemma mordellC_Δ {R : Type*} [CommRing R] (N : R) : (mordellC N).Δ = -432 * N ^ 2 := by
  simp [mordellC, WeierstrassCurve.Δ, WeierstrassCurve.b₂, WeierstrassCurve.b₄,
    WeierstrassCurve.b₆, WeierstrassCurve.b₈]
  ring

/-- Away from characteristics `2` and `3`, every point of `y² = x³ + N` with `N ≠ 0`
(equivalently `Δ ≠ 0`) is nonsingular. -/
lemma mordellC_nonsingular {F : Type*} [Field F] (N x y : F) (h2 : (2 : F) ≠ 0) (h3 : (3 : F) ≠ 0)
    (hN : N ≠ 0) (h : y ^ 2 = x ^ 3 + N) : (mordellC N).Nonsingular x y := by
  rw [Affine.nonsingular_iff]
  refine ⟨(mordellC_equation_iff N x y).2 h, ?_⟩
  simp only [mordellC]
  by_cases hy : y = 0
  · left
    subst hy
    have hx : x ≠ 0 := by
      intro hx0
      apply hN
      rw [hx0] at h
      linear_combination -h
    simp only [zero_mul, mul_zero, add_zero]
    exact fun hc => h3 (by
      have : (3 : F) * x ^ 2 = 0 := hc.symm
      rcases mul_eq_zero.1 this with h' | h'
      · exact h'
      · exact absurd (pow_eq_zero_iff (n := 2) (by norm_num) |>.1 h') hx)
  · right
    simp only [sub_zero, zero_mul]
    intro hc
    apply hy
    have : (2 : F) * y = 0 := by linear_combination hc
    rcases mul_eq_zero.1 this with h' | h'
    · exact absurd h' h2
    · exact h'

/-- The `Q`-points of `y² = x³+N` with `N ≠ 0` are nonsingular. -/
lemma mordell_nonsingular (N x y : ℚ) (hN : N ≠ 0) (h : y ^ 2 = x ^ 3 + N) :
    (mordell N).Nonsingular x y :=
  mordellC_nonsingular N x y (by norm_num) (by norm_num) hN h

/-! ## The duplication formula, bridged with mathlib's group law -/

/-- The `x`-coordinate of `2P` for `P = (x,y)` on `y² = x³ + N`, in its classical closed form
`(x⁴ - 8Nx) / (4(x³+N))`. -/
def dblX (N x : ℚ) : ℚ := (x ^ 4 - 8 * N * x) / (4 * (x ^ 3 + N))

/-- The `x`-coordinate of an affine point, as an `Option`. -/
noncomputable def xCoord {N : ℚ} : (mordell N).Point → Option ℚ
  | .zero => none
  | @Affine.Point.some _ _ _ x _ _ => some x

/-- The tangent slope at a point of the Mordell curve is `3x²/(2y)`. -/
lemma mordell_slope (N x y : ℚ) (hy : y ≠ 0) :
    (mordell N).slope x x y y = 3 * x ^ 2 / (2 * y) := by
  rw [Affine.slope, if_pos rfl,
    if_neg (by simp [mordellC]; intro hc; exact hy (by linarith))]
  simp [mordellC]
  ring_nf

/-- Mathlib's `addX` for the doubling of `(x,y)` agrees with the classical duplication
formula `dblX`. -/
lemma dblX_eq_addX (N x y : ℚ) (h : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0) :
    (mordell N).addX x x ((mordell N).slope x x y y) = dblX N x := by
  rw [mordell_slope N x y hy, Affine.addX, dblX]
  have h3 : x ^ 3 + N = y ^ 2 := h.symm
  rw [h3]
  simp only [mordellC]
  field_simp
  linear_combination (-32 * x) * h

/-- **Bridge theorem.** For a nonsingular point `P = (x,y)` with `y ≠ 0` on the Mordell curve,
the `x`-coordinate of `P + P` computed by mathlib's group law is exactly the classical
duplication value `dblX N x`. -/
theorem xCoord_add_self (N x y : ℚ) (hns : (mordell N).Nonsingular x y) (h : y ^ 2 = x ^ 3 + N)
    (hy : y ≠ 0) :
    xCoord (Affine.Point.some hns + Affine.Point.some hns) = some (dblX N x) := by
  classical
  rw [Affine.Point.add_self_of_Y_ne (h₁ := hns)
    (by simp [mordellC]; intro hc; exact hy (by linarith))]
  rw [← dblX_eq_addX N x y h hy]
  rfl

/-! ## A denominator toolkit for `ℚ` -/

/-- The denominator of `a/b` divides `b`. -/
lemma den_dvd_den (a b : ℤ) : (((a : ℚ) / (b : ℚ)).den : ℤ) ∣ b := by
  rw [← Rat.divInt_eq_div]; exact Rat.den_dvd a b

/-- If a prime divides the (integral) denominator of a fraction but not its numerator, then it
divides the denominator of the reduced fraction. -/
lemma prime_dvd_den (a b : ℤ) (hb : b ≠ 0) (l : ℕ) (hl : l.Prime) (h1 : (l : ℤ) ∣ b)
    (h2 : ¬(l : ℤ) ∣ a) : (l : ℤ) ∣ (((a : ℚ) / (b : ℚ)).den : ℤ) := by
  set q : ℚ := (a : ℚ) / (b : ℚ) with hq
  have hbq : (b : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hb
  have hqb : q * (b : ℚ) = a := by rw [hq]; field_simp
  have key : (a : ℚ) * (q.den : ℚ) = (q.num : ℚ) * (b : ℚ) := by
    calc (a : ℚ) * q.den = (q * b) * q.den := by rw [hqb]
      _ = (q * q.den) * b := by ring
      _ = (q.num : ℚ) * b := by rw [Rat.mul_den_eq_num]
  have keyz : a * (q.den : ℤ) = q.num * b := by exact_mod_cast key
  have hd : (l : ℤ) ∣ a * (q.den : ℤ) := by rw [keyz]; exact Dvd.dvd.mul_left h1 _
  rcases (Int.Prime.dvd_mul' (by exact_mod_cast hl) hd) with h | h
  · exact absurd h h2
  · exact h

/-! ## The mechanism theorem -/

/-- The classical duplication value, written as an explicit fraction of integers. -/
lemma dblX_intCast (N x : ℤ) :
    dblX (N : ℚ) (x : ℚ) = (((x ^ 4 - 8 * N * x : ℤ) : ℚ)) / (((4 * (x ^ 3 + N) : ℤ) : ℚ)) := by
  unfold dblX; push_cast; ring

/-- **Mechanism theorem.**  Let `(x,y)` be an integral point on `y² = x³ + N` with `y ≠ 0`, and
let `ℓ` be a prime of good reduction in the strong sense `ℓ ∤ 6N` (equivalently `ℓ ∤ Δ = -432N²`).
Then `ℓ` divides the denominator of `x(2P)` **iff** `ℓ ∣ y`, i.e. iff `P` reduces mod `ℓ` to a
point of order dividing `2`.  In particular good-reduction primes do occur in denominators. -/
theorem prime_dvd_den_dblX_iff (N x y : ℤ) (h : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0) (l : ℕ)
    (hl : l.Prime) (hl6N : ¬(l : ℤ) ∣ 6 * N) :
    (l : ℤ) ∣ ((dblX (N : ℚ) (x : ℚ)).den : ℤ) ↔ (l : ℤ) ∣ y := by
  have hb : (4 * (x ^ 3 + N)) = 4 * y ^ 2 := by rw [← h]
  have hbne : (4 * (x ^ 3 + N)) ≠ 0 := by
    rw [hb]; exact mul_ne_zero four_ne_zero (pow_ne_zero 2 hy)
  have hl2 : ¬(l : ℤ) ∣ 2 := fun hc => hl6N (dvd_mul_of_dvd_left (hc.trans ⟨3, by ring⟩) N)
  have hl3 : ¬(l : ℤ) ∣ 3 := fun hc => hl6N (dvd_mul_of_dvd_left (hc.trans ⟨2, by ring⟩) N)
  have hlN : ¬(l : ℤ) ∣ N := fun hc => hl6N (Dvd.dvd.mul_left hc 6)
  have hlp : Prime (l : ℤ) := Nat.prime_iff_prime_int.mp hl
  rw [dblX_intCast]
  constructor
  · intro hd
    have h1 : (l : ℤ) ∣ 4 * y ^ 2 := hb ▸ (hd.trans (den_dvd_den _ _))
    rcases hlp.dvd_mul.1 h1 with h4 | hy2
    · exact absurd (hlp.dvd_of_dvd_pow (n := 2) (by simpa [pow_two] using h4)) hl2
    · exact hlp.dvd_of_dvd_pow hy2
  · intro hdy
    refine prime_dvd_den _ _ hbne l hl ?_ ?_
    · rw [hb]; exact Dvd.dvd.mul_left (hdy.trans (dvd_pow_self y two_ne_zero)) 4
    · intro hc
      rcases hlp.dvd_mul.1 (show (l : ℤ) ∣ x * (x ^ 3 - 8 * N) by
        rw [show x * (x ^ 3 - 8 * N) = x ^ 4 - 8 * N * x by ring]; exact hc) with hx | h8
      · refine hlN ?_
        have hx3 : (l : ℤ) ∣ x ^ 3 := hx.trans (dvd_pow_self x three_ne_zero)
        have hy2 : (l : ℤ) ∣ y ^ 2 := hdy.trans (dvd_pow_self y two_ne_zero)
        have hNe : N = y ^ 2 - x ^ 3 := by linarith
        rw [hNe]; exact dvd_sub hy2 hx3
      · have hy2 : (l : ℤ) ∣ y ^ 2 := hdy.trans (dvd_pow_self y two_ne_zero)
        have h9 : (l : ℤ) ∣ 9 * N := by
          have h9e : (9 : ℤ) * N = y ^ 2 - (x ^ 3 - 8 * N) := by linarith
          rw [h9e]; exact dvd_sub hy2 h8
        rcases hlp.dvd_mul.1 h9 with h9' | hN
        · exact hl3 (hlp.dvd_of_dvd_pow (n := 2) (by simpa [pow_two] using h9'))
        · exact hlN hN

/-! ## The repaired (true) statement -/

/-- The denominator of `x(2P)` always divides `4y²`. -/
theorem den_dblX_dvd (N x y : ℤ) (h : y ^ 2 = x ^ 3 + N) :
    ((dblX (N : ℚ) (x : ℚ)).den : ℤ) ∣ 4 * y ^ 2 := by
  rw [dblX_intCast, show (4 * (x ^ 3 + N)) = 4 * y ^ 2 by rw [← h]]
  exact den_dvd_den _ _

/-- **Repaired conjecture.**  The correct statement is not about the bad primes of `E_N` but
about the point: every prime dividing the denominator of `x(2P)` divides `2y`. -/
theorem prime_dvd_den_dblX_dvd_two_mul (N x y : ℤ) (h : y ^ 2 = x ^ 3 + N) (l : ℕ) (hl : l.Prime)
    (hd : (l : ℤ) ∣ ((dblX (N : ℚ) (x : ℚ)).den : ℤ)) : (l : ℤ) ∣ 2 * y := by
  have hlp : Prime (l : ℤ) := Nat.prime_iff_prime_int.mp hl
  have h1 : (l : ℤ) ∣ 4 * y ^ 2 := hd.trans (den_dblX_dvd N x y h)
  rcases hlp.dvd_mul.1 h1 with h4 | hy2
  · exact Dvd.dvd.mul_right (hlp.dvd_of_dvd_pow (n := 2) (by simpa [pow_two] using h4)) y
  · exact Dvd.dvd.mul_left (hlp.dvd_of_dvd_pow hy2) 2

/-! ## Bad primes and the discriminant -/

/-- The set of primes of bad reduction of `E_N`, i.e. the primes dividing `Δ = -432N²`. -/
def badPrimes (N : ℕ) : Finset ℕ := insert 2 (insert 3 N.primeFactors)

/-- `badPrimes N` really is the set of primes dividing the discriminant `-432 N²`. -/
theorem mem_badPrimes_iff (N : ℕ) (hN : N ≠ 0) (l : ℕ) (hl : l.Prime) :
    l ∈ badPrimes N ↔ l ∣ 432 * N ^ 2 := by
  constructor
  · intro hm
    simp only [badPrimes, Finset.mem_insert, Nat.mem_primeFactors] at hm
    rcases hm with rfl | rfl | ⟨_, hdvd, _⟩
    · exact Dvd.dvd.mul_right ⟨216, by norm_num⟩ _
    · exact Dvd.dvd.mul_right ⟨144, by norm_num⟩ _
    · exact Dvd.dvd.mul_left (hdvd.trans (dvd_pow_self N two_ne_zero)) 432
  · intro hd
    simp only [badPrimes, Finset.mem_insert, Nat.mem_primeFactors]
    rcases (Nat.Prime.dvd_mul hl).1 hd with h432 | hN2
    · have : l ∣ 2 ^ 4 * 3 ^ 3 := by norm_num at h432 ⊢; exact h432
      rcases (Nat.Prime.dvd_mul hl).1 this with h2 | h3
      · exact Or.inl ((Nat.prime_dvd_prime_iff_eq hl Nat.prime_two).1
          (hl.dvd_of_dvd_pow h2))
      · exact Or.inr (Or.inl ((Nat.prime_dvd_prime_iff_eq hl Nat.prime_three).1
          (hl.dvd_of_dvd_pow h3)))
    · exact Or.inr (Or.inr ⟨hl, hl.dvd_of_dvd_pow hN2, hN⟩)

/-! ## The explicit counterexample `N = 55 = 5·11`, `P = (9,28)` -/

lemma point_55_on_curve : (28 : ℚ) ^ 2 = (9 : ℚ) ^ 3 + 55 := by norm_num

/-- `x(2P) = 2601/3136` for `P = (9,28)` on `y² = x³ + 55`. -/
lemma dblX_55 : dblX 55 9 = 2601 / 3136 := by
  unfold dblX; norm_num

/-- The denominator `3136 = 2⁶ · 7²` of `x(2P)`. -/
lemma den_dblX_55 : (dblX (55 : ℚ) (9 : ℚ)).den = 3136 := by
  rw [dblX_55]; norm_num

/-- `7` divides the denominator of `x(2P)` although `7` is a prime of **good** reduction:
`7 ∤ Δ = -432 · 55²`. -/
theorem good_prime_seven_divides_den :
    (7 : ℤ) ∣ ((dblX (55 : ℚ) (9 : ℚ)).den : ℤ) ∧ ¬(7 : ℤ) ∣ (-432 * 55 ^ 2 : ℤ) ∧
      (7 : ℕ) ∉ badPrimes 55 := by
  refine ⟨?_, ?_, ?_⟩
  · rw [den_dblX_55]; norm_num
  · decide
  · intro hm
    simp only [badPrimes, Finset.mem_insert, Nat.mem_primeFactors] at hm
    rcases hm with h | h | ⟨-, hd, -⟩ <;> omega

/-! ## Refutation of the conjecture -/

/-- The "only bad primes" conjecture for `n = 2`: for `N = pq` a semiprime and `(x,y)` an
integral point of `E_N`, the primes dividing the denominator of `x(2P)` lie in `{2,3,p,q}`. -/
def OnlyBadPrimesConj : Prop :=
  ∀ (p q : ℕ), p.Prime → q.Prime → ∀ (x y : ℤ), y ^ 2 = x ^ 3 + (p * q : ℕ) →
    ∀ l : ℕ, l.Prime → (l : ℤ) ∣ ((dblX ((p * q : ℕ) : ℚ) (x : ℚ)).den : ℤ) →
      l ∈ badPrimes (p * q)

/-- **The conjecture is false**, witnessed by `N = 55 = 5·11`, `P = (9,28)`, `ℓ = 7`. -/
theorem onlyBadPrimes_false : ¬ OnlyBadPrimesConj := by
  intro hconj
  have h55 : ((5 * 11 : ℕ) : ℚ) = (55 : ℚ) := by norm_num
  have hpt : (28 : ℤ) ^ 2 = (9 : ℤ) ^ 3 + ((5 * 11 : ℕ) : ℤ) := by norm_num
  have := hconj 5 11 (by norm_num) (by norm_num) 9 28 hpt 7 (by norm_num) (by
    rw [show (((9 : ℤ)) : ℚ) = (9 : ℚ) by norm_num, h55, den_dblX_55]; norm_num)
  have h7 : (7 : ℕ) ∉ badPrimes (5 * 11) := good_prime_seven_divides_den.2.2
  exact h7 this

/-! ## A second semiprime counterexample, and infinitely many failures -/

lemma dblX_899 : dblX 899 1 = -799 / 400 := by
  unfold dblX; norm_num

/-- `N = 899 = 29 · 31` (twin primes), `P = (1, 30)`, `x(2P) = -799/400` and `5 ∣ 400`, while
`5 ∉ {2,3,29,31}`. -/
theorem counterexample_899 :
    (30 : ℤ) ^ 2 = (1 : ℤ) ^ 3 + 899 ∧ (dblX (899 : ℚ) (1 : ℚ)).den = 400 ∧
      (5 : ℤ) ∣ ((dblX (899 : ℚ) (1 : ℚ)).den : ℤ) ∧ (5 : ℕ) ∉ badPrimes 899 := by
  have hden : (dblX (899 : ℚ) (1 : ℚ)).den = 400 := by rw [dblX_899]; norm_num
  refine ⟨by norm_num, hden, by rw [hden]; norm_num, ?_⟩
  intro hm
  simp only [badPrimes, Finset.mem_insert, Nat.mem_primeFactors] at hm
  rcases hm with h | h | ⟨-, hd, -⟩ <;> omega

/-- The set of `N` for which some integral point of `E_N` has a **good-reduction** prime in the
denominator of the `x`-coordinate of its double. -/
def badSet : Set ℤ :=
  {N | ∃ x y : ℤ, y ^ 2 = x ^ 3 + N ∧ ∃ l : ℕ, l.Prime ∧ ¬(l : ℤ) ∣ 6 * N ∧
    (l : ℤ) ∣ ((dblX (N : ℚ) (x : ℚ)).den : ℤ)}

private lemma five_not_dvd_six_mul (m : ℕ) : ¬((5 : ℕ) : ℤ) ∣ 6 * (25 * (m : ℤ) ^ 2 - 1) := by
  intro hc
  have h5 : (5 : ℤ) ∣ 6 := by
    have h6 : (6 : ℤ) = 5 * (30 * (m : ℤ) ^ 2) - 6 * (25 * (m : ℤ) ^ 2 - 1) := by ring
    rw [h6]
    exact dvd_sub ⟨30 * (m : ℤ) ^ 2, by ring⟩ (by exact_mod_cast hc)
  omega

/-- The family `N = 25m² - 1` (with the point `(1, 5m)`) always fails the conjecture at `ℓ = 5`. -/
theorem family_mem_badSet (m : ℕ) (hm : m ≠ 0) : (25 * (m : ℤ) ^ 2 - 1) ∈ badSet := by
  refine ⟨1, 5 * (m : ℤ), by ring, 5, by norm_num, ?_, ?_⟩
  · exact five_not_dvd_six_mul m
  · refine (prime_dvd_den_dblX_iff (25 * (m : ℤ) ^ 2 - 1) 1 (5 * (m : ℤ)) (by ring) ?_ 5
      (by norm_num) ?_).2 ⟨(m : ℤ), rfl⟩
    · simp only [ne_eq, mul_eq_zero]
      push_neg
      exact ⟨by norm_num, by exact_mod_cast hm⟩
    · exact five_not_dvd_six_mul m

/-- **Infinitely many failures.**  The conjecture fails for infinitely many `N`: good-reduction
primes in denominators are the rule, not an accident of `N = 55`. -/
theorem badSet_infinite : badSet.Infinite := by
  refine Set.infinite_of_injective_forall_mem
    (f := fun m : ℕ => 25 * ((m : ℤ) + 1) ^ 2 - 1) ?_ ?_
  · intro a b hab
    simp only at hab
    have h1 : ((a : ℤ) + 1) ^ 2 = ((b : ℤ) + 1) ^ 2 := by linarith
    have ha : (0 : ℤ) ≤ (a : ℤ) := Int.natCast_nonneg a
    have hb : (0 : ℤ) ≤ (b : ℤ) := Int.natCast_nonneg b
    have : (a : ℤ) = (b : ℤ) := by nlinarith [h1]
    exact_mod_cast this
  · intro m
    have hmem := family_mem_badSet (m + 1) (by omega)
    have hcast : ((m + 1 : ℕ) : ℤ) = ((m : ℤ) + 1) := by push_cast; ring
    rw [hcast] at hmem
    exact hmem

/-! ## Good reduction and torsion: the conceptual mechanism -/

/-- Under `ℓ ∤ 6N`, the reduction mod `ℓ` of an integral point is a nonsingular point of the
reduced Mordell curve. -/
lemma reduction_nonsingular (N x y : ℤ) (h : y ^ 2 = x ^ 3 + N) (l : ℕ) [hFl : Fact l.Prime]
    (hl6N : ¬(l : ℤ) ∣ 6 * N) :
    (mordellC ((N : ZMod l))).Nonsingular ((x : ZMod l)) ((y : ZMod l)) := by
  have hlN : ¬(l : ℤ) ∣ N := fun hc => hl6N (Dvd.dvd.mul_left hc 6)
  have hl2 : ¬(l : ℤ) ∣ 2 := fun hc => hl6N (dvd_mul_of_dvd_left (hc.trans ⟨3, by ring⟩) N)
  have hl3 : ¬(l : ℤ) ∣ 3 := fun hc => hl6N (dvd_mul_of_dvd_left (hc.trans ⟨2, by ring⟩) N)
  refine mordellC_nonsingular _ _ _ ?_ ?_ ?_ ?_
  · intro hc
    exact hl2 ((ZMod.intCast_zmod_eq_zero_iff_dvd 2 l).1 (by exact_mod_cast hc))
  · intro hc
    exact hl3 ((ZMod.intCast_zmod_eq_zero_iff_dvd 3 l).1 (by exact_mod_cast hc))
  · intro hc
    exact hlN ((ZMod.intCast_zmod_eq_zero_iff_dvd N l).1 hc)
  · have : ((y ^ 2 : ℤ) : ZMod l) = ((x ^ 3 + N : ℤ) : ZMod l) := by rw [h]
    push_cast at this
    exact this

/-- **Reduction/torsion bridge.**  For a good-reduction prime `ℓ ∤ 6N`, the prime `ℓ` divides the
denominator of `x(2P)` **iff** the reduction `P̄` of `P` satisfies `P̄ + P̄ = 0` in `E_N(𝔽_ℓ)`.
This is the conceptual reason the "only bad primes" conjecture fails: nothing prevents a point of
good reduction from reducing into the 2-torsion. -/
theorem den_dvd_iff_reduction_two_torsion (N x y : ℤ) (h : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0)
    (l : ℕ) [hFl : Fact l.Prime] (hl6N : ¬(l : ℤ) ∣ 6 * N)
    (hns : (mordellC ((N : ZMod l))).Nonsingular ((x : ZMod l)) ((y : ZMod l))) :
    (l : ℤ) ∣ ((dblX (N : ℚ) (x : ℚ)).den : ℤ) ↔
      Affine.Point.some hns + Affine.Point.some hns = 0 := by
  classical
  have hl2 : ¬(l : ℤ) ∣ 2 := fun hc => hl6N (dvd_mul_of_dvd_left (hc.trans ⟨3, by ring⟩) N)
  rw [prime_dvd_den_dblX_iff N x y h hy l hFl.out hl6N]
  constructor
  · intro hdy
    refine Affine.Point.add_self_of_Y_eq ?_
    rw [mordellC_negY]
    have : ((y : ZMod l)) = 0 := (ZMod.intCast_zmod_eq_zero_iff_dvd y l).2 hdy
    rw [this, neg_zero]
  · intro hzero
    by_contra hdy
    have hyne : ((y : ZMod l)) ≠ 0 := fun hc =>
      hdy ((ZMod.intCast_zmod_eq_zero_iff_dvd y l).1 hc)
    have h2ne : ((y : ZMod l)) ≠ (mordellC ((N : ZMod l))).negY ((x : ZMod l)) ((y : ZMod l)) := by
      rw [mordellC_negY]
      intro hc
      have h2y : (2 : ZMod l) * (y : ZMod l) = 0 := by linear_combination hc
      rcases mul_eq_zero.1 h2y with h' | h'
      · exact hl2 ((ZMod.intCast_zmod_eq_zero_iff_dvd 2 l).1 (by exact_mod_cast h'))
      · exact hyne h'
    rw [Affine.Point.add_self_of_Y_ne h2ne] at hzero
    exact Affine.Point.some_ne_zero _ hzero

/-! ## Second cycle: no prime is excluded, and arbitrarily many extraneous primes at once -/

/-- A prime `≥ 5` does not divide `6`. -/
lemma prime_ge_five_not_dvd_six (l : ℕ) (hl : l.Prime) (h5 : 5 ≤ l) : ¬((l : ℤ) ∣ 6) := by
  intro hc
  have hn : l ∣ 6 := by exact_mod_cast hc
  rcases (Nat.Prime.dvd_mul hl).1 (show l ∣ 2 * 3 by norm_num at hn ⊢; exact hn) with h | h
  · have := Nat.le_of_dvd (by norm_num) h; omega
  · have := Nat.le_of_dvd (by norm_num) h; omega

/-- If a prime `ℓ ≥ 5` divides `K`, then `ℓ ∤ 6(K²m² - 1)`, i.e. `ℓ` is a prime of good reduction
for the Mordell curve `E_N` with `N = K²m² - 1`. -/
lemma good_reduction_of_dvd (l : ℕ) (hl : l.Prime) (h5 : 5 ≤ l) (K m : ℤ) (hK : (l : ℤ) ∣ K) :
    ¬((l : ℤ) ∣ 6 * (K ^ 2 * m ^ 2 - 1)) := by
  intro hc
  refine prime_ge_five_not_dvd_six l hl h5 ?_
  have h6 : (6 : ℤ) = 6 * (K ^ 2 * m ^ 2) - 6 * (K ^ 2 * m ^ 2 - 1) := by ring
  rw [h6]
  exact dvd_sub (Dvd.dvd.mul_left (Dvd.dvd.mul_right
    (hK.trans (dvd_pow_self K two_ne_zero)) (m ^ 2)) 6) hc

/-- **No prime is excluded.**  For every prime `ℓ ≥ 5` and every `m ≠ 0`, the Mordell curve with
`N = ℓ²m² - 1` has the integral point `(1, ℓm)` whose double has `ℓ` in the denominator of its
`x`-coordinate, while `ℓ` is a prime of good reduction (`ℓ ∤ 6N`, hence `ℓ ∤ Δ`).  Thus *every*
prime `≥ 5` violates the "only bad primes" heuristic for suitable `N`. -/
theorem every_prime_ge_five_is_extraneous (l : ℕ) (hl : l.Prime) (h5 : 5 ≤ l) (m : ℕ)
    (hm : m ≠ 0) :
    ¬((l : ℤ) ∣ 6 * ((l : ℤ) ^ 2 * (m : ℤ) ^ 2 - 1)) ∧
      (l : ℤ) ∣ ((dblX (((l : ℤ) ^ 2 * (m : ℤ) ^ 2 - 1 : ℤ) : ℚ) ((1 : ℤ) : ℚ)).den : ℤ) := by
  have hgood := good_reduction_of_dvd l hl h5 (l : ℤ) (m : ℤ) dvd_rfl
  refine ⟨hgood, ?_⟩
  refine (prime_dvd_den_dblX_iff ((l : ℤ) ^ 2 * (m : ℤ) ^ 2 - 1) 1 ((l : ℤ) * (m : ℤ))
    (by ring) ?_ l hl hgood).2 ⟨(m : ℤ), rfl⟩
  simp only [ne_eq, mul_eq_zero]
  push_neg
  exact ⟨by exact_mod_cast hl.ne_zero, by exact_mod_cast hm⟩

/-- **Arbitrarily many extraneous primes at once.**  Given any finite set `S` of primes `≥ 5`,
put `K = ∏_{ℓ ∈ S} ℓ` and `N = K²m² - 1`.  The integral point `(1, Km)` of `E_N` has the property
that *every* `ℓ ∈ S` is a prime of good reduction dividing the denominator of `x(2P)`.  Hence the
number of "extraneous" primes in a single denominator is unbounded. -/
theorem many_extraneous_primes (S : Finset ℕ) (hS : ∀ l ∈ S, l.Prime ∧ 5 ≤ l) (m : ℕ)
    (hm : m ≠ 0) :
    ∀ l ∈ S, ¬((l : ℤ) ∣ 6 * ((∏ p ∈ S, (p : ℤ)) ^ 2 * (m : ℤ) ^ 2 - 1)) ∧
      (l : ℤ) ∣ ((dblX ((((∏ p ∈ S, (p : ℤ)) ^ 2 * (m : ℤ) ^ 2 - 1 : ℤ)) : ℚ)
        ((1 : ℤ) : ℚ)).den : ℤ) := by
  intro l hlS
  obtain ⟨hl, h5⟩ := hS l hlS
  set K : ℤ := ∏ p ∈ S, (p : ℤ) with hKdef
  have hKpos : K ≠ 0 := by
    rw [hKdef]
    refine Finset.prod_ne_zero_iff.2 fun p hp => ?_
    exact_mod_cast (hS p hp).1.ne_zero
  have hlK : (l : ℤ) ∣ K := hKdef ▸ Finset.dvd_prod_of_mem _ hlS
  have hgood := good_reduction_of_dvd l hl h5 K (m : ℤ) hlK
  refine ⟨hgood, ?_⟩
  refine (prime_dvd_den_dblX_iff (K ^ 2 * (m : ℤ) ^ 2 - 1) 1 (K * (m : ℤ)) (by ring) ?_ l hl
    hgood).2 (hlK.mul_right _)
  simp only [ne_eq, mul_eq_zero]
  push_neg
  exact ⟨hKpos, by exact_mod_cast hm⟩

end Bridges.MordellDenominator