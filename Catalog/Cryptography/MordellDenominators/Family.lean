import Cryptography.MordellDenominators.Basic

/-!
# An infinite family of counterexamples

The failure of the "only bad primes" conjecture is not an accident of
`N = 55`.  For every prime `ℓ ≥ 5` put

  `N = ℓ² - 1`,  `P = (1, ℓ) ∈ E_N(ℚ)`.

Then `x(2P) = (9 - 8ℓ²)/(4ℓ²)` in lowest terms, so `ℓ` divides the denominator
of `x(2P)`, while `ℓ ∤ 6N` — that is, `ℓ` is a prime of **good** reduction.

* `MordellDenominators.Family.onCurve` : `P` is on the curve;
* `MordellDenominators.Family.dblX_eq`, `den_dblX` : the exact denominator;
* `MordellDenominators.Family.good` : `ℓ` is a good prime;
* `MordellDenominators.Family.not_onlyBadPrimes` : the conjecture fails;
* `MordellDenominators.Family.infinite_counterexamples` : the set of `N` for
  which the conjecture fails is infinite.
-/

namespace MordellDenominators
namespace Family

variable {l : ℕ}

/-- The family parameter `N = ℓ² - 1`. -/
def NN (l : ℕ) : ℤ := (l : ℤ) ^ 2 - 1

/-- `P = (1, ℓ)` lies on `E_{ℓ²-1}`. -/
theorem onCurve (l : ℕ) : OnCurve (NN l) 1 (l : ℚ) := by
  unfold OnCurve NN
  push_cast
  ring

/-- Duplication of `(1, ℓ)`: `x(2P) = (9 - 8ℓ²)/(4ℓ²)`. -/
theorem dblX_eq (hl : l.Prime) :
    dblX (NN l) 1 = ((9 - 8 * (l : ℤ) ^ 2 : ℤ) : ℚ) / (((4 * (l : ℤ) ^ 2 : ℤ)) : ℚ) := by
  have hl0 : (l : ℚ) ≠ 0 := by
    exact_mod_cast hl.pos.ne'
  unfold dblX NN
  push_cast
  have h : (4 : ℚ) * (1 ^ 3 + ((l : ℚ) ^ 2 - 1)) = 4 * (l : ℚ) ^ 2 := by ring
  rw [h]
  field_simp
  ring

/-- The denominator of `x(2P)` is exactly `4ℓ²`; in particular the good prime
`ℓ` occurs in it. -/
theorem den_dblX (hl : l.Prime) (h5 : 5 ≤ l) : (dblX (NN l) 1).den = 4 * l ^ 2 := by
  rw [dblX_eq hl]
  set A : ℤ := 9 - 8 * (l : ℤ) ^ 2 with hA
  set B : ℤ := 4 * (l : ℤ) ^ 2 with hB
  have hbpos : (0 : ℤ) < B := by rw [hB]; positivity
  have hBnat : B.natAbs = 4 * l ^ 2 := by
    rw [hB]; simp [Int.natAbs_mul, Int.natAbs_pow]
  have hcop : A.natAbs.Coprime B.natAbs := by
    by_contra hcon
    obtain ⟨r, hr, hrA, hrB⟩ := Nat.Prime.not_coprime_iff_dvd.mp hcon
    have hrA' : (r : ℤ) ∣ A := Int.ofNat_dvd_left.mpr hrA
    have hrB' : (r : ℤ) ∣ B := Int.ofNat_dvd_left.mpr hrB
    have h9 : (r : ℤ) ∣ 9 := by
      have hsum := dvd_add hrA' (Dvd.dvd.mul_left hrB' 2)
      have heq : A + 2 * B = 9 := by rw [hA, hB]; ring
      rwa [heq] at hsum
    have h9n : r ∣ 9 := by exact_mod_cast h9
    have hr3 : r = 3 := by
      have h32 : r ∣ 3 ^ 2 := by norm_num; exact h9n
      exact (Nat.prime_dvd_prime_iff_eq hr (by norm_num)).mp (hr.dvd_of_dvd_pow h32)
    subst hr3
    rw [hBnat] at hrB
    have h3l : (3 : ℕ) ∣ l := by
      rcases (Nat.Prime.dvd_mul (by norm_num)).mp hrB with h | h
      · exact absurd h (by norm_num)
      · exact Nat.Prime.dvd_of_dvd_pow (by norm_num) h
    have := (Nat.prime_dvd_prime_iff_eq (by norm_num) hl).mp h3l
    omega
  have hden : (((A : ℚ) / (B : ℚ)).den : ℤ) = B := Rat.den_div_eq_of_coprime hbpos hcop
  have hcast : ((4 * l ^ 2 : ℕ) : ℤ) = B := by rw [hB]; push_cast; ring
  exact_mod_cast hden.trans hcast.symm

/-- `ℓ` divides the denominator of `x(2P)`. -/
theorem dvd_den_dblX (hl : l.Prime) (h5 : 5 ≤ l) : l ∣ (dblX (NN l) 1).den := by
  rw [den_dblX hl h5]
  exact Dvd.dvd.mul_left (dvd_pow_self l (by norm_num)) 4

/-- `ℓ` is a prime of **good** reduction for `E_{ℓ²-1}`: it divides neither
`6` nor `N = ℓ² - 1`. -/
theorem good (hl : l.Prime) (h5 : 5 ≤ l) : GoodPrime (NN l) l := by
  refine ⟨hl, ?_⟩
  intro hdvd
  have hlp : Prime (l : ℤ) := Nat.prime_iff_prime_int.mp hl
  rcases hlp.dvd_mul.mp hdvd with h | h
  · -- `ℓ ∣ 6` is impossible for `ℓ ≥ 5` prime
    have hl6 : l ∣ 6 := by exact_mod_cast h
    have hle : l ≤ 6 := Nat.le_of_dvd (by norm_num) hl6
    interval_cases l <;> first | omega | exact absurd hl (by norm_num)
  · -- `ℓ ∣ ℓ² - 1` would force `ℓ ∣ 1`
    have h1 : (l : ℤ) ∣ (l : ℤ) ^ 2 := dvd_pow_self _ (by norm_num)
    have : (l : ℤ) ∣ 1 := by
      have := dvd_sub h1 h
      unfold NN at this
      simpa using this
    have : l ∣ 1 := by exact_mod_cast this
    exact hl.one_lt.ne' (Nat.dvd_one.mp this)

/-- **The conjecture fails for every member of the family.** -/
theorem not_onlyBadPrimes (hl : l.Prime) (h5 : 5 ≤ l) :
    ¬ OnlyBadPrimes (NN l) (1, (l : ℚ)) := by
  intro hcon
  refine (good hl h5).2 (hcon 1 l hl ?_)
  rw [dblIter_one_fst]
  exact dvd_den_dblX hl h5

/-- **The denominator hides the factorisation of `N`.**  For the family curve
`E_{ℓ²-1}` no odd prime divisor of `N = ℓ² - 1 = (ℓ-1)(ℓ+1)` divides the
denominator of `x(2P)`: the only primes there are `2` and the good prime `ℓ`. -/
theorem odd_prime_factor_not_dvd_den (hl : l.Prime) (h5 : 5 ≤ l) {r : ℕ}
    (hr : r.Prime) (hr2 : r ≠ 2) (hrN : (r : ℤ) ∣ NN l) :
    ¬ r ∣ (dblX (NN l) 1).den := by
  rw [den_dblX hl h5]
  intro hdvd
  rcases (Nat.Prime.dvd_mul hr).mp hdvd with h4 | hpow
  · have : r ∣ 2 ^ 2 := by simpa using h4
    exact hr2 ((Nat.prime_dvd_prime_iff_eq hr Nat.prime_two).mp (hr.dvd_of_dvd_pow this))
  · have hrl : r = l := (Nat.prime_dvd_prime_iff_eq hr hl).mp (hr.dvd_of_dvd_pow hpow)
    subst hrl
    exact (good hr h5).2 (Dvd.dvd.mul_left hrN 6)

/-- The good prime `ℓ` occurs in the denominator with exponent exactly `2`. -/
theorem cube_not_dvd_den (hl : l.Prime) (h5 : 5 ≤ l) :
    l ^ 2 ∣ (dblX (NN l) 1).den ∧ ¬ (l ^ 3 ∣ (dblX (NN l) 1).den) := by
  rw [den_dblX hl h5]
  refine ⟨Dvd.dvd.mul_left dvd_rfl 4, ?_⟩
  intro hdvd
  -- `l³ ∣ 4 l²` forces `l ∣ 4`, impossible for `l ≥ 5`
  have hl0 : 0 < l := by omega
  have hkey : l ∣ 4 := by
    have h1 : l ^ 2 * l ∣ l ^ 2 * 4 := by
      have hcube : l ^ 3 = l ^ 2 * l := by ring
      have hfour : (4 : ℕ) * l ^ 2 = l ^ 2 * 4 := by ring
      rwa [hcube, hfour] at hdvd
    exact (mul_dvd_mul_iff_left (by positivity : (l : ℕ) ^ 2 ≠ 0)).mp h1
  have := Nat.le_of_dvd (by norm_num) hkey
  omega

/-- The `N` produced by the family are pairwise distinct. -/
theorem NN_injOn : Set.InjOn NN {l : ℕ | l.Prime ∧ 5 ≤ l} := by
  intro a _ b _ hab
  unfold NN at hab
  have h2 : (a : ℤ) ^ 2 = (b : ℤ) ^ 2 := by linarith
  have h3 : a ^ 2 = b ^ 2 := by exact_mod_cast h2
  exact Nat.pow_left_injective (by norm_num) h3

/-- The set of primes `≥ 5` is infinite. -/
theorem infinite_primes_ge_five : {l : ℕ | l.Prime ∧ 5 ≤ l}.Infinite := by
  have h : ({l : ℕ | l.Prime} \ Set.Iio 5).Infinite :=
    Nat.infinite_setOf_prime.diff (Set.finite_Iio 5)
  refine h.mono ?_
  intro l hl
  exact ⟨hl.1, by simpa using hl.2⟩

/-- **There are infinitely many `N` for which the only-bad-primes conjecture
fails**: for each prime `ℓ ≥ 5` the curve `E_{ℓ²-1}` with the point `(1, ℓ)`
has a good prime, namely `ℓ` itself, in a denominator of its doubling orbit. -/
theorem infinite_counterexamples :
    {N : ℤ | ∃ P : ℚ × ℚ, OnCurve N P.1 P.2 ∧ ¬ OnlyBadPrimes N P}.Infinite := by
  refine Set.Infinite.mono ?_ (infinite_primes_ge_five.image NN_injOn)
  rintro N ⟨l, ⟨hl, h5⟩, rfl⟩
  exact ⟨(1, (l : ℚ)), onCurve l, not_onlyBadPrimes hl h5⟩

end Family
end MordellDenominators