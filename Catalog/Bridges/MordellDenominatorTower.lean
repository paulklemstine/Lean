/-
# The doubling tower: extraneous denominator primes never disappear

This file continues `Bridges.MordellDenominatorBadPrimes` (refutation of the
"only bad primes" conjecture at `n = 2`) and `Bridges.MordellDenominatorTriplication`
(the same at `n = 3`) for the Mordell curve `E_N : y² = x³ + N`.

The previous files showed that good-reduction primes *do* occur in the denominator of
`x(2P)`.  Here we show that such a prime, once it has appeared, is **permanent and
rigid** along the doubling tower `P, 2P, 4P, 8P, …`:

* `Bridges.MordellDenominator.padicValRat_dblX`: for a prime `ℓ ≠ 2` and `N ≠ 0`, if the
  `ℓ`-adic valuation of `x` is negative then
  `v_ℓ(x(2P)) = v_ℓ(x(P))` — *exactly*, with no loss and no gain.  This is the formal
  group statement `E₁(ℚ_ℓ) → E₁(ℚ_ℓ)`, `Q ↦ 2Q` preserving the filtration level when
  `ℓ ∤ 2`, proved here by hand from the duplication formula.
* `Bridges.MordellDenominator.dvd_den_dblIter` and
  `Bridges.MordellDenominator.padicValNat_den_dblIter`: consequently the prime and its
  exact exponent in the denominator persist through every doubling.
* `Bridges.MordellDenominator.extraneous_prime_persists`: combining with the mechanism
  theorem, for an integral point with `ℓ ∣ y` and `ℓ ∤ 6N`, the *good-reduction* prime
  `ℓ` divides the denominator of the `x`-coordinate of `2^k P` for **every** `k ≥ 1`.
* `Bridges.MordellDenominator.xCoord_dblPt_iterate`: the arithmetic tower `dblIter` really
  computes the `x`-coordinates of `2^k P` in mathlib's group law.
* `Bridges.MordellDenominator.level_four_55`: the numerics for `N = 55`, `P = (9,28)`:
  `x(4P)` has denominator `2⁸ · 7² · 827² · 1583²`.  The extraneous prime `7` of level 2
  survives with the *same* exponent `2`, and two brand-new good-reduction primes
  `827, 1583` appear.  `onlyBadPrimesTower_false` refutes the tower form of the
  conjecture.
-/

import Mathlib
import Bridges.MordellDenominatorBadPrimes

namespace Bridges.MordellDenominator

open WeierstrassCurve

/-! ## A `ℓ`-adic valuation toolkit -/

/-- A rational number has negative `p`-adic valuation exactly when `p` divides its
denominator. -/
theorem padicValRat_neg_iff_dvd_den (p : ℕ) [Fact p.Prime] (q : ℚ) :
    padicValRat p q < 0 ↔ (p : ℤ) ∣ (q.den : ℤ) := by
  rw [padicValRat]
  constructor
  · intro h
    have h2 : 1 ≤ padicValNat p q.den := by omega
    exact_mod_cast dvd_of_one_le_padicValNat h2
  · intro h
    have hd : p ∣ q.den := by exact_mod_cast h
    have h2 : 1 ≤ padicValNat p q.den := one_le_padicValNat_of_dvd q.den_nz hd
    have hnum : ¬ (p ∣ q.num.natAbs) := fun hc =>
      (Fact.out : p.Prime).ne_one
        (Nat.Coprime.eq_one_of_dvd (Nat.Coprime.coprime_dvd_left hc q.reduced) hd)
    have h0 : padicValInt p q.num = 0 := by
      simp [padicValInt, padicValNat.eq_zero_of_not_dvd hnum]
    rw [h0]
    omega

/-- If the valuation of `q` is negative, it is exactly minus the valuation of the
denominator (the numerator contributes nothing, by coprimality). -/
theorem padicValRat_eq_neg_den (p : ℕ) [Fact p.Prime] (q : ℚ) (hq : padicValRat p q < 0) :
    padicValRat p q = -(padicValNat p q.den : ℤ) := by
  have hd : (p : ℤ) ∣ (q.den : ℤ) := (padicValRat_neg_iff_dvd_den p q).1 hq
  have hdn : p ∣ q.den := by exact_mod_cast hd
  have hnum : ¬ (p ∣ q.num.natAbs) := fun hc =>
    (Fact.out : p.Prime).ne_one
      (Nat.Coprime.eq_one_of_dvd (Nat.Coprime.coprime_dvd_left hc q.reduced) hdn)
  have h0 : padicValInt p q.num = 0 := by
    simp [padicValInt, padicValNat.eq_zero_of_not_dvd hnum]
  rw [padicValRat, h0]
  simp

/-- The `p`-adic valuation of an integer is nonnegative. -/
theorem padicValRat_int_nonneg (p : ℕ) [Fact p.Prime] (z : ℤ) : 0 ≤ padicValRat p (z : ℚ) := by
  rw [padicValRat.of_int]; positivity

/-- For an odd prime, `v_p(4) = 0`. -/
theorem padicValRat_four (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) : padicValRat p (4 : ℚ) = 0 := by
  have hp := (Fact.out : p.Prime)
  have h : ¬ p ∣ 4 := by
    intro hc
    have : p ∣ 2 := hp.dvd_of_dvd_pow (n := 2) (by simpa [pow_two] using hc)
    exact hp2 ((Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).1 this)
  have h4 : ((4 : ℚ)) = ((4 : ℕ) : ℚ) := by norm_num
  rw [h4, padicValRat.of_nat, padicValNat.eq_zero_of_not_dvd h]
  simp

/-! ## The persistence (formal group) theorem -/

/-- **Persistence theorem.**  Let `ℓ ≠ 2` be a prime, `N ≠ 0` an integer, and `x` a rational
number with negative `ℓ`-adic valuation (i.e. `ℓ` divides the denominator of `x`).  Then the
duplication value `x(2P) = (x⁴ - 8Nx)/(4(x³+N))` is nonzero and has **exactly the same**
`ℓ`-adic valuation as `x`.

This is the arithmetic heart of the doubling tower: the `ℓ`-part of the denominator is
neither created nor destroyed by doubling at an odd good prime — it is a formal-group
invariant. -/
theorem padicValRat_dblX (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) (N : ℤ) (hN : N ≠ 0) (x : ℚ)
    (hv : padicValRat p x < 0) :
    dblX (N : ℚ) x ≠ 0 ∧ padicValRat p (dblX (N : ℚ) x) = padicValRat p x := by
  have hx0 : x ≠ 0 := by rintro rfl; simp [padicValRat.zero] at hv
  have hNQ : ((N : ℚ)) ≠ 0 := Int.cast_ne_zero.mpr hN
  have hvpow : padicValRat p (x ^ 3) = 3 * padicValRat p x := by
    simpa using padicValRat.pow (p := p) hx0 (k := 3)
  have hvpow4 : padicValRat p (x ^ 4) = 4 * padicValRat p x := by
    simpa using padicValRat.pow (p := p) hx0 (k := 4)
  have hvN : 0 ≤ padicValRat p ((N : ℤ) : ℚ) := padicValRat_int_nonneg p N
  have hv8N : 0 ≤ padicValRat p ((8 * N : ℤ) : ℚ) := padicValRat_int_nonneg p (8 * N)
  have h8Ncast : ((8 * N : ℤ) : ℚ) = 8 * (N : ℚ) := by push_cast; ring
  have h8NQ : (8 : ℚ) * (N : ℚ) ≠ 0 := by
    rw [← h8Ncast]; exact_mod_cast mul_ne_zero (by norm_num) hN
  have hnum0 : x ^ 4 - 8 * (N : ℚ) * x ≠ 0 := by
    intro hc
    have hfac : x * (x ^ 3 - 8 * (N : ℚ)) = 0 := by linear_combination hc
    have hx3 : x ^ 3 = ((8 * N : ℤ) : ℚ) := by
      rcases mul_eq_zero.1 hfac with h | h
      · exact absurd h hx0
      · rw [h8Ncast]; linarith
    rw [hx3] at hvpow
    omega
  have hden0 : x ^ 3 + (N : ℚ) ≠ 0 := by
    intro hc
    have hx3 : x ^ 3 = -((N : ℤ) : ℚ) := by linarith
    rw [hx3, padicValRat.neg] at hvpow
    omega
  have hvnum : padicValRat p (x ^ 4 - 8 * (N : ℚ) * x) = 4 * padicValRat p x := by
    have hsum : x ^ 4 - 8 * (N : ℚ) * x = x ^ 4 + (-(8 * (N : ℚ) * x)) := by ring
    have hr0 : -(8 * (N : ℚ) * x) ≠ 0 := by simpa using mul_ne_zero h8NQ hx0
    have hrval : padicValRat p (-(8 * (N : ℚ) * x))
        = padicValRat p ((8 * N : ℤ) : ℚ) + padicValRat p x := by
      rw [padicValRat.neg, ← h8Ncast]
      exact padicValRat.mul (by rw [h8Ncast]; exact h8NQ) hx0
    rw [hsum, padicValRat.add_eq_of_lt (by rw [← hsum]; exact hnum0) (pow_ne_zero 4 hx0) hr0
      (by rw [hvpow4, hrval]; omega), hvpow4]
  have hvden : padicValRat p (4 * (x ^ 3 + (N : ℚ))) = 3 * padicValRat p x := by
    rw [padicValRat.mul (by norm_num) hden0, padicValRat_four p hp2, zero_add,
      padicValRat.add_eq_of_lt hden0 (pow_ne_zero 3 hx0) hNQ (by rw [hvpow]; omega), hvpow]
  have hdblne : dblX (N : ℚ) x ≠ 0 := by
    unfold dblX
    exact div_ne_zero hnum0 (mul_ne_zero (by norm_num) hden0)
  refine ⟨hdblne, ?_⟩
  unfold dblX
  rw [padicValRat.div hnum0 (mul_ne_zero (by norm_num) hden0), hvnum, hvden]
  ring

/-- Denominator form of the persistence theorem for a single doubling. -/
theorem dvd_den_dblX_of_dvd_den (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) (N : ℤ) (hN : N ≠ 0)
    (x : ℚ) (hd : (p : ℤ) ∣ (x.den : ℤ)) : (p : ℤ) ∣ ((dblX (N : ℚ) x).den : ℤ) := by
  have hv : padicValRat p x < 0 := (padicValRat_neg_iff_dvd_den p x).2 hd
  exact (padicValRat_neg_iff_dvd_den p _).1
    (by rw [(padicValRat_dblX p hp2 N hN x hv).2]; exact hv)

/-! ## The doubling tower -/

/-- The `k`-fold iterated duplication value: `dblIter N k x = x(2^k P)` for `P` with
`x(P) = x`. -/
def dblIter (N : ℚ) : ℕ → ℚ → ℚ
  | 0, x => x
  | (k + 1), x => dblX N (dblIter N k x)

@[simp] lemma dblIter_zero (N x : ℚ) : dblIter N 0 x = x := rfl

@[simp] lemma dblIter_succ (N : ℚ) (k : ℕ) (x : ℚ) :
    dblIter N (k + 1) x = dblX N (dblIter N k x) := rfl

/-- **Rigidity along the tower.**  If `ℓ ≠ 2` is a prime dividing the denominator of `x`,
then for every `k` the iterated duplication value is nonzero and has the *same* `ℓ`-adic
valuation as `x`. -/
theorem padicValRat_dblIter (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) (N : ℤ) (hN : N ≠ 0)
    (x : ℚ) (hv : padicValRat p x < 0) (k : ℕ) :
    dblIter (N : ℚ) k x ≠ 0 ∧ padicValRat p (dblIter (N : ℚ) k x) = padicValRat p x := by
  induction k with
  | zero =>
      refine ⟨?_, rfl⟩
      rintro h0
      rw [dblIter_zero] at h0
      rw [h0] at hv
      simp [padicValRat.zero] at hv
  | succ k ih =>
      obtain ⟨_, hval⟩ := ih
      have hvk : padicValRat p (dblIter (N : ℚ) k x) < 0 := by rw [hval]; exact hv
      obtain ⟨hne, heq⟩ := padicValRat_dblX p hp2 N hN _ hvk
      exact ⟨by rw [dblIter_succ]; exact hne, by rw [dblIter_succ, heq, hval]⟩

/-- A prime `ℓ ≠ 2` in the denominator of `x` stays in the denominator of every iterated
double. -/
theorem dvd_den_dblIter (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) (N : ℤ) (hN : N ≠ 0) (x : ℚ)
    (hd : (p : ℤ) ∣ (x.den : ℤ)) (k : ℕ) :
    (p : ℤ) ∣ ((dblIter (N : ℚ) k x).den : ℤ) := by
  have hv : padicValRat p x < 0 := (padicValRat_neg_iff_dvd_den p x).2 hd
  exact (padicValRat_neg_iff_dvd_den p _).1
    (by rw [(padicValRat_dblIter p hp2 N hN x hv k).2]; exact hv)

/-- **The exponent is constant, too.**  The exact power of `ℓ` in the denominator is the same
at every level of the doubling tower. -/
theorem padicValNat_den_dblIter (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) (N : ℤ) (hN : N ≠ 0)
    (x : ℚ) (hd : (p : ℤ) ∣ (x.den : ℤ)) (k : ℕ) :
    padicValNat p (dblIter (N : ℚ) k x).den = padicValNat p x.den := by
  have hv : padicValRat p x < 0 := (padicValRat_neg_iff_dvd_den p x).2 hd
  have hvk : padicValRat p (dblIter (N : ℚ) k x) < 0 := by
    rw [(padicValRat_dblIter p hp2 N hN x hv k).2]; exact hv
  have h1 := padicValRat_eq_neg_den p _ hvk
  have h2 := padicValRat_eq_neg_den p x hv
  have h3 := (padicValRat_dblIter p hp2 N hN x hv k).2
  rw [h1, h2] at h3
  omega

/-! ## The tower in mathlib's group law -/

/-- Doubling a point of the Mordell curve. -/
noncomputable def dblPt {N : ℚ} (Q : (mordell N).Point) : (mordell N).Point := Q + Q

/-- The `x`-coordinate of `2Q`, for any nonzero rational point `Q` which is not `2`-torsion,
is the classical duplication value. -/
lemma xCoord_dblPt (N x : ℚ) (Q : (mordell N).Point) (hx : xCoord Q = some x)
    (hQ : dblPt Q ≠ 0) : xCoord (dblPt Q) = some (dblX N x) := by
  classical
  match Q with
  | .zero => simp [xCoord] at hx
  | @Affine.Point.some _ _ _ x' y' hns =>
      have hxx : x' = x := by simpa [xCoord] using hx
      subst hxx
      have heq : y' ^ 2 = x' ^ 3 + N := (mordellC_equation_iff N x' y').1 hns.left
      have hy : y' ≠ 0 := by
        intro h0
        refine hQ ?_
        rw [dblPt]
        subst h0
        exact Affine.Point.add_self_of_Y_eq (by rw [mordellC_negY]; ring)
      exact xCoord_add_self N x' y' hns heq hy

/-- **The arithmetic tower computes the geometric tower.**  If no intermediate multiple
`2^j P` vanishes, then the `x`-coordinate of `2^k P` is the `k`-fold iterated duplication
value `dblIter N k x`. -/
theorem xCoord_dblPt_iterate (N x : ℚ) (P : (mordell N).Point) (hx : xCoord P = some x)
    (k : ℕ) (hne : ∀ j ≤ k, (dblPt^[j] P) ≠ 0) :
    xCoord (dblPt^[k] P) = some (dblIter N k x) := by
  induction k with
  | zero => simpa using hx
  | succ k ih =>
      have ihx : xCoord (dblPt^[k] P) = some (dblIter N k x) :=
        ih (fun j hj => hne j (by omega))
      have hnext : dblPt (dblPt^[k] P) ≠ 0 := by
        have := hne (k + 1) le_rfl
        rwa [Function.iterate_succ_apply'] at this
      rw [Function.iterate_succ_apply', dblIter_succ]
      exact xCoord_dblPt N _ _ ihx hnext

/-! ## Extraneous good-reduction primes are permanent -/

/-- **Permanence of extraneous primes.**  Let `(x,y)` be an integral point of `E_N` with
`y ≠ 0`, and let `ℓ` be a prime of good reduction (`ℓ ∤ 6N`) with `ℓ ∣ y`, so that by the
mechanism theorem `ℓ` divides the denominator of `x(2P)`.  Then `ℓ` divides the denominator
of the `x`-coordinate of `2^{k+1} P` for **every** `k`, always with the same exponent.

So the failure of the "only bad primes" conjecture is not a level-2 accident: once a
good-reduction prime enters the denominator it never leaves, and its exponent is frozen. -/
theorem extraneous_prime_persists (N x y : ℤ) (hN : N ≠ 0) (h : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0)
    (l : ℕ) [Fact l.Prime] (hl6N : ¬(l : ℤ) ∣ 6 * N) (hly : (l : ℤ) ∣ y) (k : ℕ) :
    (l : ℤ) ∣ ((dblIter (N : ℚ) (k + 1) (x : ℚ)).den : ℤ) ∧
      padicValNat l (dblIter (N : ℚ) (k + 1) (x : ℚ)).den
        = padicValNat l (dblX (N : ℚ) (x : ℚ)).den := by
  have hl2 : l ≠ 2 := by
    rintro rfl
    exact hl6N (dvd_mul_of_dvd_left ⟨3, by norm_num⟩ N)
  have hd2 : (l : ℤ) ∣ ((dblX (N : ℚ) (x : ℚ)).den : ℤ) :=
    (prime_dvd_den_dblX_iff N x y h hy l Fact.out hl6N).2 hly
  have hstep : ∀ m : ℕ, dblIter (N : ℚ) (m + 1) (x : ℚ)
      = dblIter (N : ℚ) m (dblX (N : ℚ) (x : ℚ)) := by
    intro m
    induction m with
    | zero => rfl
    | succ m ih => rw [dblIter_succ, ih, dblIter_succ]
  rw [hstep k]
  exact ⟨dvd_den_dblIter l hl2 N hN _ hd2 k, padicValNat_den_dblIter l hl2 N hN _ hd2 k⟩

/-! ## Level four for `N = 55`, `P = (9,28)` -/

/-- The level-two value, recalled: `x(2P) = 2601/3136`. -/
lemma dblIter_one_55 : dblIter 55 1 9 = 2601 / 3136 := by
  rw [dblIter_succ, dblIter_zero]; exact dblX_55

/-- `x(4P) = -35249882584054239 / 21498536380459264` for `P = (9,28)` on `y² = x³ + 55`. -/
lemma dblIter_two_55 :
    dblIter 55 2 9 = -35249882584054239 / 21498536380459264 := by
  rw [dblIter_succ, dblIter_one_55]
  unfold dblX
  norm_num

/-- The denominator of `x(4P)` is `21498536380459264 = 2⁸ · 7² · 827² · 1583²`. -/
lemma den_dblIter_two_55 : (dblIter 55 2 9).den = 21498536380459264 := by
  rw [dblIter_two_55]; norm_num

lemma factor_den_level_four : (21498536380459264 : ℕ) = 2 ^ 8 * 7 ^ 2 * 827 ^ 2 * 1583 ^ 2 := by
  norm_num

/-- **Level four for `N = 55`.**  The extraneous prime `7` of level two survives into level
four with the *same* exponent `2` (as predicted by `padicValNat_den_dblIter`), and two brand
new good-reduction primes `827` and `1583` appear.  None of `7, 827, 1583` is a bad prime of
`E_55`. -/
theorem level_four_55 :
    (dblIter 55 2 9).den = 2 ^ 8 * 7 ^ 2 * 827 ^ 2 * 1583 ^ 2 ∧
      (7 : ℤ) ∣ ((dblIter 55 2 9).den : ℤ) ∧
      (827 : ℤ) ∣ ((dblIter 55 2 9).den : ℤ) ∧ (1583 : ℤ) ∣ ((dblIter 55 2 9).den : ℤ) ∧
      Nat.Prime 827 ∧ Nat.Prime 1583 ∧
      (827 : ℕ) ∉ badPrimes 55 ∧ (1583 : ℕ) ∉ badPrimes 55 ∧
      ¬((827 : ℤ) ∣ 6 * 55) ∧ ¬((1583 : ℤ) ∣ 6 * 55) := by
  have hden : (dblIter 55 2 9).den = 21498536380459264 := den_dblIter_two_55
  refine ⟨by rw [hden, factor_den_level_four], ?_, ?_, ?_, by norm_num, by norm_num, ?_, ?_,
    by decide, by decide⟩
  · rw [hden]; norm_num
  · rw [hden]; norm_num
  · rw [hden]; norm_num
  · intro hm
    simp only [badPrimes, Finset.mem_insert, Nat.mem_primeFactors] at hm
    rcases hm with h | h | ⟨-, hd, -⟩ <;> omega
  · intro hm
    simp only [badPrimes, Finset.mem_insert, Nat.mem_primeFactors] at hm
    rcases hm with h | h | ⟨-, hd, -⟩ <;> omega

/-- The exponent of `7` in the denominator of `x(2P)` and of `x(4P)` is the same, namely `2`:
the persistence theorem, checked numerically. -/
theorem seven_exponent_stable_55 :
    padicValNat 7 (dblIter 55 1 9).den = 2 ∧ padicValNat 7 (dblIter 55 2 9).den = 2 := by
  haveI : Fact (Nat.Prime 7) := ⟨by norm_num⟩
  constructor
  · rw [dblIter_one_55, show (2601 / 3136 : ℚ).den = 3136 by norm_num,
      show (3136 : ℕ) = 7 ^ 2 * 64 by norm_num, padicValNat.mul (by norm_num) (by norm_num),
      padicValNat.prime_pow, padicValNat.eq_zero_of_not_dvd (by norm_num)]
  · rw [den_dblIter_two_55,
      show (21498536380459264 : ℕ) = 7 ^ 2 * 438745640417536 by norm_num,
      padicValNat.mul (by norm_num) (by norm_num), padicValNat.prime_pow,
      padicValNat.eq_zero_of_not_dvd (by norm_num)]

/-! ## The exact exponent at a good prime -/

/-- If `ℓ ∤ 6N` is a prime dividing `y`, then `ℓ` does **not** divide the numerator
`x⁴ - 8Nx` of the duplication formula.  (This is the numerator half of the mechanism
theorem, isolated so that exact exponents can be computed.) -/
lemma not_dvd_num_dblX_of_dvd_y (N x y : ℤ) (h : y ^ 2 = x ^ 3 + N) (l : ℕ) (hl : l.Prime)
    (hl6N : ¬(l : ℤ) ∣ 6 * N) (hly : (l : ℤ) ∣ y) : ¬(l : ℤ) ∣ (x ^ 4 - 8 * N * x) := by
  have hlp : Prime (l : ℤ) := Nat.prime_iff_prime_int.mp hl
  have hl3 : ¬(l : ℤ) ∣ 3 := fun hc => hl6N (dvd_mul_of_dvd_left (hc.trans ⟨2, by ring⟩) N)
  have hlN : ¬(l : ℤ) ∣ N := fun hc => hl6N (Dvd.dvd.mul_left hc 6)
  have hy2 : (l : ℤ) ∣ y ^ 2 := hly.trans (dvd_pow_self y two_ne_zero)
  intro hc
  rcases hlp.dvd_mul.1 (show (l : ℤ) ∣ x * (x ^ 3 - 8 * N) by
    rw [show x * (x ^ 3 - 8 * N) = x ^ 4 - 8 * N * x by ring]; exact hc) with hx | h8
  · refine hlN ?_
    have hx3 : (l : ℤ) ∣ x ^ 3 := hx.trans (dvd_pow_self x three_ne_zero)
    have hNe : N = y ^ 2 - x ^ 3 := by linarith
    rw [hNe]
    exact dvd_sub hy2 hx3
  · have h9 : (l : ℤ) ∣ 9 * N := by
      have h9e : (9 : ℤ) * N = y ^ 2 - (x ^ 3 - 8 * N) := by linarith
      rw [h9e]
      exact dvd_sub hy2 h8
    rcases hlp.dvd_mul.1 h9 with h9' | hN
    · exact hl3 (hlp.dvd_of_dvd_pow (n := 2) (by simpa [pow_two] using h9'))
    · exact hlN hN

lemma padicValInt_sq (l : ℕ) [Fact l.Prime] (y : ℤ) (hy : y ≠ 0) :
    padicValInt l (y ^ 2) = 2 * padicValInt l y := by
  have hy' : y.natAbs ≠ 0 := Int.natAbs_ne_zero.mpr hy
  simp only [padicValInt, Int.natAbs_pow]
  rw [padicValNat.pow 2 hy']

/-- **The exact exponent at a good prime.**  For an integral point `(x,y)` of `E_N` and a prime
`ℓ ∤ 6N`, the exponent of `ℓ` in the denominator of `x(2P)` is exactly `2 v_ℓ(y)`.  Together with
`padicValNat_den_dblIter` this pins down the whole `ℓ`-part of the denominator at every level of
the doubling tower. -/
theorem padicValNat_den_dblX (N x y : ℤ) (h : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0) (l : ℕ)
    [hFl : Fact l.Prime] (hl6N : ¬(l : ℤ) ∣ 6 * N) :
    padicValNat l (dblX (N : ℚ) (x : ℚ)).den = 2 * padicValInt l y := by
  have hl := hFl.out
  have hlp : Prime (l : ℤ) := Nat.prime_iff_prime_int.mp hl
  have hl2 : ¬(l : ℤ) ∣ 2 := fun hc => hl6N (dvd_mul_of_dvd_left (hc.trans ⟨3, by ring⟩) N)
  have hl4 : ¬(l : ℤ) ∣ 4 := fun hc =>
    hl2 (hlp.dvd_of_dvd_pow (n := 2) (by simpa [pow_two] using hc))
  by_cases hly : (l : ℤ) ∣ y
  · have hnum : ¬(l : ℤ) ∣ (x ^ 4 - 8 * N * x) := not_dvd_num_dblX_of_dvd_y N x y h l hl hl6N hly
    have hA0 : (x ^ 4 - 8 * N * x) ≠ 0 := fun h0 => hnum (h0 ▸ dvd_zero _)
    have hB : (4 * (x ^ 3 + N) : ℤ) = 4 * y ^ 2 := by rw [← h]
    have hB0 : (4 * (x ^ 3 + N) : ℤ) ≠ 0 := by
      rw [hB]; exact mul_ne_zero four_ne_zero (pow_ne_zero 2 hy)
    have hval : padicValRat l (dblX (N : ℚ) (x : ℚ))
        = (padicValInt l (x ^ 4 - 8 * N * x) : ℤ) - (padicValInt l (4 * (x ^ 3 + N)) : ℤ) := by
      rw [dblX_intCast, padicValRat.div (Int.cast_ne_zero.mpr hA0) (Int.cast_ne_zero.mpr hB0),
        padicValRat.of_int, padicValRat.of_int]
    have hnumval : padicValInt l (x ^ 4 - 8 * N * x) = 0 := padicValInt.eq_zero_of_not_dvd hnum
    have hdenval : padicValInt l (4 * (x ^ 3 + N)) = 2 * padicValInt l y := by
      rw [hB, padicValInt.mul (by norm_num) (pow_ne_zero 2 hy),
        padicValInt.eq_zero_of_not_dvd hl4, padicValInt_sq l y hy, zero_add]
    have hvy : 1 ≤ padicValInt l y := by
      have := one_le_padicValNat_of_dvd (n := y.natAbs) (Int.natAbs_ne_zero.mpr hy)
        (by exact_mod_cast Int.natAbs_dvd_natAbs.mpr hly)
      simpa [padicValInt] using this
    have hneg : padicValRat l (dblX (N : ℚ) (x : ℚ)) < 0 := by
      rw [hval, hnumval, hdenval]; omega
    have := padicValRat_eq_neg_den l _ hneg
    rw [hval, hnumval, hdenval] at this
    omega
  · have hnd : ¬(l : ℤ) ∣ ((dblX (N : ℚ) (x : ℚ)).den : ℤ) := fun hc =>
      hly ((prime_dvd_den_dblX_iff N x y h hy l hl hl6N).1 hc)
    rw [padicValNat.eq_zero_of_not_dvd (by exact_mod_cast hnd),
      padicValInt.eq_zero_of_not_dvd hly]

/-- **The `ℓ`-part of the denominator at every level.**  For an integral point and a good prime
`ℓ ∤ 6N` with `ℓ ≠ 2`, the exponent of `ℓ` in the denominator of `x(2^{k+1} P)` is `2 v_ℓ(y)` for
*every* `k`. -/
theorem padicValNat_den_dblIter_eq (N x y : ℤ) (hN : N ≠ 0) (h : y ^ 2 = x ^ 3 + N) (hy : y ≠ 0)
    (l : ℕ) [hFl : Fact l.Prime] (hl6N : ¬(l : ℤ) ∣ 6 * N) (hly : (l : ℤ) ∣ y) (k : ℕ) :
    padicValNat l (dblIter (N : ℚ) (k + 1) (x : ℚ)).den = 2 * padicValInt l y := by
  obtain ⟨-, hstep⟩ := extraneous_prime_persists N x y hN h hy l hl6N hly k
  rw [hstep, padicValNat_den_dblX N x y h hy l hl6N]

/-! ## The dichotomy at the bad prime `2`: linear growth instead of rigidity -/

lemma padicValRat_two_four : padicValRat 2 (4 : ℚ) = 2 := by
  rw [show ((4 : ℚ)) = ((4 : ℕ) : ℚ) by norm_num, padicValRat.of_nat,
    show (4 : ℕ) = 2 ^ 2 by norm_num, padicValNat.prime_pow]
  norm_num

lemma padicValRat_two_eight (N : ℤ) (hN : N ≠ 0) :
    padicValRat 2 ((8 * N : ℤ) : ℚ) = 3 + padicValRat 2 ((N : ℤ) : ℚ) := by
  have h8 : ((8 * N : ℤ) : ℚ) = ((8 : ℕ) : ℚ) * ((N : ℤ) : ℚ) := by push_cast; ring
  rw [h8, padicValRat.mul (by norm_num) (Int.cast_ne_zero.mpr hN), padicValRat.of_nat,
    show (8 : ℕ) = 2 ^ 3 by norm_num, padicValNat.prime_pow]
  norm_num

/-- **The bad prime `2` behaves in the opposite way.**  If `2` divides the denominator of `x`,
then doubling *increases* the `2`-adic denominator exponent by exactly `2`:
`v_2(x(2P)) = v_2(x) - 2`.  Together with `padicValRat_dblX` this is a sharp dichotomy: along the
doubling tower the good-reduction primes are frozen while the bad prime `2` grows linearly. -/
theorem padicValRat_dblX_two (N : ℤ) (hN : N ≠ 0) (x : ℚ) (hv : padicValRat 2 x < 0) :
    dblX (N : ℚ) x ≠ 0 ∧ padicValRat 2 (dblX (N : ℚ) x) = padicValRat 2 x - 2 := by
  have hx0 : x ≠ 0 := by rintro rfl; simp [padicValRat.zero] at hv
  have hNQ : ((N : ℚ)) ≠ 0 := Int.cast_ne_zero.mpr hN
  have hvpow : padicValRat 2 (x ^ 3) = 3 * padicValRat 2 x := by
    simpa using padicValRat.pow (p := 2) hx0 (k := 3)
  have hvpow4 : padicValRat 2 (x ^ 4) = 4 * padicValRat 2 x := by
    simpa using padicValRat.pow (p := 2) hx0 (k := 4)
  have hvN : 0 ≤ padicValRat 2 ((N : ℤ) : ℚ) := padicValRat_int_nonneg 2 N
  have hv8N : padicValRat 2 ((8 * N : ℤ) : ℚ) = 3 + padicValRat 2 ((N : ℤ) : ℚ) :=
    padicValRat_two_eight N hN
  have h8Ncast : ((8 * N : ℤ) : ℚ) = 8 * (N : ℚ) := by push_cast; ring
  have h8NQ : (8 : ℚ) * (N : ℚ) ≠ 0 := by
    rw [← h8Ncast]; exact_mod_cast mul_ne_zero (by norm_num) hN
  have hnum0 : x ^ 4 - 8 * (N : ℚ) * x ≠ 0 := by
    intro hc
    have hfac : x * (x ^ 3 - 8 * (N : ℚ)) = 0 := by linear_combination hc
    have hx3 : x ^ 3 = ((8 * N : ℤ) : ℚ) := by
      rcases mul_eq_zero.1 hfac with h | h
      · exact absurd h hx0
      · rw [h8Ncast]; linarith
    rw [hx3, hv8N] at hvpow
    omega
  have hden0 : x ^ 3 + (N : ℚ) ≠ 0 := by
    intro hc
    have hx3 : x ^ 3 = -((N : ℤ) : ℚ) := by linarith
    rw [hx3, padicValRat.neg] at hvpow
    omega
  have hvnum : padicValRat 2 (x ^ 4 - 8 * (N : ℚ) * x) = 4 * padicValRat 2 x := by
    have hsum : x ^ 4 - 8 * (N : ℚ) * x = x ^ 4 + (-(8 * (N : ℚ) * x)) := by ring
    have hr0 : -(8 * (N : ℚ) * x) ≠ 0 := by simpa using mul_ne_zero h8NQ hx0
    have hrval : padicValRat 2 (-(8 * (N : ℚ) * x))
        = padicValRat 2 ((8 * N : ℤ) : ℚ) + padicValRat 2 x := by
      rw [padicValRat.neg, ← h8Ncast]
      exact padicValRat.mul (by rw [h8Ncast]; exact h8NQ) hx0
    rw [hsum, padicValRat.add_eq_of_lt (by rw [← hsum]; exact hnum0) (pow_ne_zero 4 hx0) hr0
      (by rw [hvpow4, hrval, hv8N]; omega), hvpow4]
  have hvden : padicValRat 2 (4 * (x ^ 3 + (N : ℚ))) = 3 * padicValRat 2 x + 2 := by
    rw [padicValRat.mul (by norm_num) hden0, padicValRat_two_four,
      padicValRat.add_eq_of_lt hden0 (pow_ne_zero 3 hx0) hNQ (by rw [hvpow]; omega), hvpow]
    ring
  have hdblne : dblX (N : ℚ) x ≠ 0 := by
    unfold dblX
    exact div_ne_zero hnum0 (mul_ne_zero (by norm_num) hden0)
  refine ⟨hdblne, ?_⟩
  unfold dblX
  rw [padicValRat.div hnum0 (mul_ne_zero (by norm_num) hden0), hvnum, hvden]
  ring

/-- Along the doubling tower, the `2`-adic valuation drops by exactly `2` at each step. -/
theorem padicValRat_dblIter_two (N : ℤ) (hN : N ≠ 0) (x : ℚ) (hv : padicValRat 2 x < 0) (k : ℕ) :
    dblIter (N : ℚ) k x ≠ 0 ∧
      padicValRat 2 (dblIter (N : ℚ) k x) = padicValRat 2 x - 2 * k := by
  induction k with
  | zero =>
      refine ⟨?_, by simp⟩
      rintro h0
      rw [dblIter_zero] at h0
      rw [h0] at hv
      simp [padicValRat.zero] at hv
  | succ k ih =>
      obtain ⟨_, hval⟩ := ih
      have hvk : padicValRat 2 (dblIter (N : ℚ) k x) < 0 := by rw [hval]; omega
      obtain ⟨hne, heq⟩ := padicValRat_dblX_two N hN _ hvk
      refine ⟨by rw [dblIter_succ]; exact hne, ?_⟩
      rw [dblIter_succ, heq, hval]
      push_cast
      ring

/-- **Linear growth of the `2`-part of the denominator.**  If `2` divides the denominator of `x`,
the exponent of `2` in the denominator of `x(2^k P)` is `v_2(den x) + 2k`. -/
theorem padicValNat_den_dblIter_two (N : ℤ) (hN : N ≠ 0) (x : ℚ) (hd : (2 : ℤ) ∣ (x.den : ℤ))
    (k : ℕ) :
    (padicValNat 2 (dblIter (N : ℚ) k x).den : ℤ) = (padicValNat 2 x.den : ℤ) + 2 * k := by
  have hv : padicValRat 2 x < 0 := (padicValRat_neg_iff_dvd_den 2 x).2 (by exact_mod_cast hd)
  obtain ⟨-, hval⟩ := padicValRat_dblIter_two N hN x hv k
  have hvk : padicValRat 2 (dblIter (N : ℚ) k x) < 0 := by rw [hval]; omega
  have h1 := padicValRat_eq_neg_den 2 _ hvk
  have h2 := padicValRat_eq_neg_den 2 x hv
  rw [h1, h2] at hval
  omega

/-- **The dichotomy, checked on `N = 55`, `P = (9,28)`.**  Between level `2` and level `4` the
good-reduction prime `7` keeps its exponent `2`, while the bad prime `2` gains exactly `2`
(`2⁶ → 2⁸`), exactly as the two theorems above predict. -/
theorem dichotomy_55 :
    padicValNat 7 (dblIter 55 1 9).den = padicValNat 7 (dblIter 55 2 9).den ∧
      padicValNat 2 (dblIter 55 1 9).den = 6 ∧ padicValNat 2 (dblIter 55 2 9).den = 8 := by
  refine ⟨by rw [seven_exponent_stable_55.1, seven_exponent_stable_55.2], ?_, ?_⟩
  · rw [dblIter_one_55, show (2601 / 3136 : ℚ).den = 3136 by norm_num,
      show (3136 : ℕ) = 2 ^ 6 * 49 by norm_num, padicValNat.mul (by norm_num) (by norm_num),
      padicValNat.prime_pow, padicValNat.eq_zero_of_not_dvd (by norm_num)]
  · rw [den_dblIter_two_55,
      show (21498536380459264 : ℕ) = 2 ^ 8 * 83978657736169 by norm_num,
      padicValNat.mul (by norm_num) (by norm_num), padicValNat.prime_pow,
      padicValNat.eq_zero_of_not_dvd (by norm_num)]

/-! ## Refutation of the tower form of the conjecture -/

/-- The "only bad primes" conjecture for the whole doubling tower: for `N = pq` a semiprime
and `(x,y)` an integral point of `E_N`, every prime dividing the denominator of the
`x`-coordinate of `2^k P` lies in `{2,3,p,q}`. -/
def OnlyBadPrimesTowerConj : Prop :=
  ∀ (p q : ℕ), p.Prime → q.Prime → ∀ (x y : ℤ), y ^ 2 = x ^ 3 + (p * q : ℕ) → ∀ k : ℕ,
    ∀ l : ℕ, l.Prime → (l : ℤ) ∣ ((dblIter ((p * q : ℕ) : ℚ) k (x : ℚ)).den : ℤ) →
      l ∈ badPrimes (p * q)

/-- **The tower conjecture is false**, witnessed at level `k = 2` by `N = 55 = 5·11`,
`P = (9,28)` and the good-reduction prime `ℓ = 827`. -/
theorem onlyBadPrimesTower_false : ¬ OnlyBadPrimesTowerConj := by
  intro hconj
  have h55 : ((5 * 11 : ℕ) : ℚ) = (55 : ℚ) := by norm_num
  have hpt : (28 : ℤ) ^ 2 = (9 : ℤ) ^ 3 + ((5 * 11 : ℕ) : ℤ) := by norm_num
  have hmem := hconj 5 11 (by norm_num) (by norm_num) 9 28 hpt 2 827 (by norm_num) (by
    rw [show (((9 : ℤ)) : ℚ) = (9 : ℚ) by norm_num, h55]
    exact level_four_55.2.2.1)
  exact level_four_55.2.2.2.2.2.2.1 hmem

end Bridges.MordellDenominator