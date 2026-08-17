import Novelty.Basic

/-!
# The Anti-Fibonacci Sequence — Exact Modular Period Structure

The Fibonacci sequence reduced modulo `m` is periodic with the (highly irregular)
Pisano period `π(m)`, a quantity with no known closed form.  This file establishes the
sharp *counterpoint* for the anti-Fibonacci sequence
`antiFib 0 = 1`, `antiFib (n+1) = antiFib n + n` of `Novelty.Basic`
(values `1, 1, 2, 4, 7, 11, 16, 22, …`, closed form `2·antiFib n + n = n² + 2`):

**its period modulo `m` is completely determined and equals `m` for odd `m` and
`2m` for even `m`.**

## Main results

* `AntiFibonacciPeriod.isPeriodMod_iff` — a *complete arithmetic characterisation*:
  for a positive `p`, `p` is a period of `antiFib` mod `m` **iff** `m ∣ p` and
  `antiFib p ≡ 1 [MOD m]`.  (Only two of the infinitely many congruences matter.)
* `AntiFibonacciPeriod.isPeriodMod_two_mul` — `2m` is always a period.
* `AntiFibonacciPeriod.isPeriodMod_self_of_odd` — for odd `m`, already `m` is a period.
* `AntiFibonacciPeriod.not_isPeriodMod_self_of_even` — for even `m > 0`, `m` is **not**
  a period: the obstruction is exactly the parity of `m - 1`.
* `AntiFibonacciPeriod.isLeast_period` — the punchline: the *minimal* period is
  `pisanoAnti m = if m % 2 = 1 then m else 2 * m`, proved as an `IsLeast` statement.
* `AntiFibonacciPeriod.zmod_periodic` — the same statement transported into `ZMod m`.
* `AntiFibonacciPeriod.pisanoAnti_multiplicative_of_coprime` — the minimal period is
  multiplicative on coprime moduli, mirroring the Pisano period; and
  `pisanoAnti_not_multiplicative_two_two` shows coprimality cannot be dropped.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Fibonacci mod `m` has an erratic period; a quadratic
sequence should instead have a period governed only by the parity of `m`, because
`antiFib (n+p) - antiFib n = n·p + p(p-1)/2` is *linear* in `n`.

Experiment (Experimenter): the residue streams (recomputed by the `#eval`s below) are
mod 2 : `1,1,0,0,1,1,0,0,…`      → period 4  = 2·2
mod 3 : `1,1,2,1,1,2,…`          → period 3  = 3
mod 4 : `1,1,2,0,3,3,0,2,1,1,…`  → period 8  = 2·4
mod 5 : `1,1,2,4,2,1,1,2,4,2,…`  → period 5  = 5
mod 6 : `1,1,2,4,1,5,4,4,5,1,…`  → period 12 = 2·6
mod 7 : `1,1,2,4,0,4,2,1,1,…`    → period 7  = 7
So the data say: period `= m` for odd `m`, `= 2m` for even `m`.

Analysis (Analyst): writing `D n = antiFib (n+p) - antiFib n` over `ℤ`, the closed form
gives `2·D n = 2np + p² - p`, hence `D (n+1) - D n = p`.  Therefore `p` is a period iff
`m ∣ D 0` and `m ∣ D 1 - D 0 = p`; i.e. iff `m ∣ p` and `antiFib p ≡ 1 [MOD m]`.
Substituting `p = m·s` and using `2(antiFib p - 1) = p(p-1)` turns the second condition
into `2m ∣ m·s·(ms-1)`, i.e. `2 ∣ s(ms-1)`, which for odd `m` holds at `s = 1` and for
even `m` first holds at `s = 2`.

Critique (Critic): the tempting slogan "`m` is a period iff `m` is odd" needs the
positivity guard `0 < m`; for `m = 1` everything is a period, and this is consistent
with `pisanoAnti 1 = 1`.  We therefore prove `IsLeast`, which pins the minimum exactly.
All arithmetic is kept subtraction-free on `ℕ` (or moved to `ℤ`) to avoid truncation
traps; the two even/odd value computations are isolated in
`antiFib_two_mul_succ` and `antiFib_two_mul_add_one`.
-- !-- Lab Notes -- !--
-/

open AntiFibonacci

namespace AntiFibonacciPeriod

/-- `p` is a period of the anti-Fibonacci sequence modulo `m`. -/
def IsPeriodMod (m p : ℕ) : Prop :=
  0 < p ∧ ∀ n, antiFib (n + p) ≡ antiFib n [MOD m]

/-- The conjectured minimal period: `m` for odd `m`, `2m` for even `m`. -/
def pisanoAnti (m : ℕ) : ℕ := if m % 2 = 1 then m else 2 * m

@[simp] theorem pisanoAnti_of_odd {m : ℕ} (hm : m % 2 = 1) : pisanoAnti m = m := by
  simp [pisanoAnti, hm]

@[simp] theorem pisanoAnti_of_even {m : ℕ} (hm : m % 2 = 0) : pisanoAnti m = 2 * m := by
  simp [pisanoAnti, hm]

-- Experimental data behind the Lab Notes above.
section Evidence

/-- The first `k` residues of `antiFib` modulo `m`. -/
def residues (m k : ℕ) : List ℕ := (List.range k).map fun n => antiFib n % m

/-- info: [1, 1, 0, 0, 1, 1, 0, 0, 1, 1] -/
#guard_msgs in #eval residues 2 10
/-- info: [1, 1, 2, 1, 1, 2, 1, 1, 2, 1] -/
#guard_msgs in #eval residues 3 10
/-- info: [1, 1, 2, 0, 3, 3, 0, 2, 1, 1] -/
#guard_msgs in #eval residues 4 10
/-- info: [1, 1, 2, 4, 2, 1, 1, 2, 4, 2] -/
#guard_msgs in #eval residues 5 10
/-- info: [1, 1, 2, 4, 1, 5, 4, 4, 5, 1, 4, 2, 1, 1] -/
#guard_msgs in #eval residues 6 14
/-- info: [1, 1, 2, 4, 0, 4, 2, 1, 1, 2] -/
#guard_msgs in #eval residues 7 10

end Evidence

/-! ### The difference calculus of a quadratic sequence -/

/-- Integer form of the workhorse closed form `2·antiFib n + n = n² + 2`. -/
theorem antiFib_closed_int (n : ℕ) : 2 * (antiFib n : ℤ) + n = (n : ℤ) ^ 2 + 2 := by
  have h : ((2 * antiFib n + n : ℕ) : ℤ) = ((n * n + 2 : ℕ) : ℤ) := by
    exact_mod_cast congrArg (fun x : ℕ => (x : ℤ)) (antiFib_closed n)
  push_cast at h
  linarith [h]

/-- The *shift difference* `antiFib (n+p) - antiFib n`, doubled, is `2np + p² - p`. -/
theorem two_mul_shift_diff (n p : ℕ) :
    2 * ((antiFib (n + p) : ℤ) - antiFib n) = 2 * n * p + (p : ℤ) ^ 2 - p := by
  have h1 := antiFib_closed_int (n + p)
  have h2 := antiFib_closed_int n
  push_cast at h1
  nlinarith [h1, h2]

/-- The shift difference is *linear* in `n` with slope `p`. -/
theorem shift_diff_succ (n p : ℕ) :
    ((antiFib (n + 1 + p) : ℤ) - antiFib (n + 1)) - ((antiFib (n + p) : ℤ) - antiFib n)
      = p := by
  have h1 := two_mul_shift_diff (n + 1) p
  have h2 := two_mul_shift_diff n p
  push_cast at h1 h2
  linarith [h1, h2]

/-- The shift difference in closed form: `antiFib (n+p) - antiFib n = n·p + (antiFib p - 1)`. -/
theorem shift_diff_eq (n p : ℕ) :
    ((antiFib (n + p) : ℤ) - antiFib n) = n * p + ((antiFib p : ℤ) - 1) := by
  have h1 := two_mul_shift_diff n p
  have h2 := two_mul_shift_diff 0 p
  simp only [Nat.zero_add, Nat.cast_zero, antiFib_zero, Nat.cast_one] at h2
  linarith [h1, h2]

/-! ### Complete characterisation of the periods -/

/-- **Complete characterisation of the periods.**  A positive `p` is a period of
`antiFib` modulo `m` iff `m ∣ p` and `antiFib p ≡ 1 [MOD m]`.  Infinitely many
congruences collapse to just two arithmetic conditions. -/
theorem isPeriodMod_iff {m p : ℕ} (hp : 0 < p) :
    IsPeriodMod m p ↔ (m ∣ p ∧ antiFib p ≡ 1 [MOD m]) := by
  constructor
  · rintro ⟨-, h⟩
    have h0 : (m : ℤ) ∣ (antiFib (0 + p) : ℤ) - (antiFib 0 : ℤ) := by
      have := Nat.modEq_iff_dvd.1 (h 0)
      simpa using (dvd_neg.2 this)
    have h1 : (m : ℤ) ∣ (antiFib (1 + p) : ℤ) - (antiFib 1 : ℤ) := by
      have := Nat.modEq_iff_dvd.1 (h 1)
      simpa using (dvd_neg.2 this)
    have hp1 : (m : ℤ) ∣ (p : ℤ) := by
      have hsub := dvd_sub h1 h0
      rwa [show (1 : ℕ) + p = 0 + 1 + p by ring, show (1 : ℕ) = 0 + 1 by ring,
        shift_diff_succ 0 p] at hsub
    refine ⟨by exact_mod_cast hp1, ?_⟩
    have hval : (m : ℤ) ∣ (antiFib p : ℤ) - 1 := by
      simpa using h0
    exact Nat.ModEq.symm (Nat.modEq_iff_dvd.2 (by simpa using hval))
  · rintro ⟨hdvd, hval⟩
    refine ⟨hp, fun n => ?_⟩
    have hpz : (m : ℤ) ∣ (p : ℤ) := by exact_mod_cast hdvd
    have hvz : (m : ℤ) ∣ (antiFib p : ℤ) - 1 := by
      simpa using Nat.modEq_iff_dvd.1 (Nat.ModEq.symm hval)
    have hd : (m : ℤ) ∣ (antiFib (n + p) : ℤ) - antiFib n := by
      rw [shift_diff_eq n p]
      exact dvd_add (Dvd.dvd.mul_left hpz _) hvz
    exact Nat.modEq_iff_dvd.2 (by simpa using (dvd_neg.2 hd))

/-! ### The two explicit value computations -/

/-- `antiFib (2(k+1)) = (k+1)(2k+1) + 1`. -/
theorem antiFib_two_mul_succ (k : ℕ) : antiFib (2 * (k + 1)) = (k + 1) * (2 * k + 1) + 1 := by
  have hc := antiFib_closed (2 * (k + 1))
  nlinarith [hc]

/-- `antiFib (2t+1) = (2t+1)·t + 1`. -/
theorem antiFib_two_mul_add_one (t : ℕ) : antiFib (2 * t + 1) = (2 * t + 1) * t + 1 := by
  have hc := antiFib_closed (2 * t + 1)
  nlinarith [hc]

/-- A convenient form of "`antiFib p ≡ 1 [MOD m]`". -/
theorem antiFib_modEq_one_iff {m p c : ℕ} (h : antiFib p = c + 1) :
    antiFib p ≡ 1 [MOD m] ↔ m ∣ c := by
  rw [h]
  constructor
  · intro hmod
    have := (Nat.modEq_iff_dvd' (Nat.le_add_left 1 c)).1 (Nat.ModEq.symm hmod)
    simpa using this
  · intro hdvd
    exact Nat.ModEq.symm ((Nat.modEq_iff_dvd' (Nat.le_add_left 1 c)).2 (by simpa using hdvd))

/-! ### Which multiples of `m` are periods -/

/-- **`2m` is always a period** (for `m > 0`). -/
theorem isPeriodMod_two_mul {m : ℕ} (hm : 0 < m) : IsPeriodMod m (2 * m) := by
  obtain ⟨k, rfl⟩ : ∃ k, m = k + 1 := ⟨m - 1, by omega⟩
  refine (isPeriodMod_iff (by omega)).2 ⟨⟨2, by ring⟩, ?_⟩
  rw [antiFib_modEq_one_iff (antiFib_two_mul_succ k)]
  exact ⟨2 * k + 1, rfl⟩

/-- **For odd `m`, already `m` is a period.** -/
theorem isPeriodMod_self_of_odd {m : ℕ} (hm : 0 < m) (hodd : m % 2 = 1) :
    IsPeriodMod m m := by
  obtain ⟨t, rfl⟩ : ∃ t, m = 2 * t + 1 := ⟨m / 2, by omega⟩
  refine (isPeriodMod_iff hm).2 ⟨dvd_rfl, ?_⟩
  rw [antiFib_modEq_one_iff (antiFib_two_mul_add_one t)]
  exact ⟨t, rfl⟩

/-- **For even positive `m`, `m` itself is not a period.**  The obstruction is exactly
that `m - 1` is odd. -/
theorem not_isPeriodMod_self_of_even {m : ℕ} (hm : 0 < m) (heven : m % 2 = 0) :
    ¬ IsPeriodMod m m := by
  obtain ⟨s, rfl⟩ : ∃ s, m = 2 * (s + 1) := ⟨m / 2 - 1, by omega⟩
  intro h
  obtain ⟨-, hval⟩ := (isPeriodMod_iff hm).1 h
  rw [antiFib_modEq_one_iff (antiFib_two_mul_succ s)] at hval
  obtain ⟨c, hc⟩ := hval
  -- `2(s+1) * c = (s+1)(2s+1)` forces `2c = 2s+1`, impossible by parity.
  have hcancel : (s + 1) * (2 * c) = (s + 1) * (2 * s + 1) := by
    rw [hc]; ring
  have := Nat.eq_of_mul_eq_mul_left (by omega : 0 < s + 1) hcancel
  omega

/-! ### The minimal period -/

/-- **Main theorem: the exact minimal period.**  For `0 < m` the least period of the
anti-Fibonacci sequence modulo `m` is `m` when `m` is odd and `2m` when `m` is even.
This is the sharp counterpoint to the Pisano period of the Fibonacci sequence, which
has no such closed form. -/
theorem isLeast_period {m : ℕ} (hm : 0 < m) :
    IsLeast {p : ℕ | IsPeriodMod m p} (pisanoAnti m) := by
  rcases Nat.even_or_odd m with hev | hod
  · have heven : m % 2 = 0 := Nat.even_iff.1 hev
    rw [pisanoAnti_of_even heven]
    refine ⟨isPeriodMod_two_mul hm, ?_⟩
    rintro p hp
    have hpos : 0 < p := hp.1
    have hdvd : m ∣ p := ((isPeriodMod_iff hpos).1 hp).1
    by_contra hlt
    push_neg at hlt
    -- `m ∣ p`, `0 < p < 2m` forces `p = m`, contradicting `not_isPeriodMod_self_of_even`.
    obtain ⟨c, rfl⟩ := hdvd
    have hcne : c ≠ 0 := by rintro rfl; simp at hpos
    have hc1 : c = 1 := by
      rcases Nat.lt_or_ge c 2 with h2 | h2
      · omega
      · have hle : m * 2 ≤ m * c := Nat.mul_le_mul_left m h2
        linarith [hle, hlt]
    subst hc1
    exact absurd (by simpa using hp) (not_isPeriodMod_self_of_even hm heven)
  · have hodd : m % 2 = 1 := Nat.odd_iff.1 hod
    rw [pisanoAnti_of_odd hodd]
    refine ⟨isPeriodMod_self_of_odd hm hodd, ?_⟩
    rintro p hp
    have hpos : 0 < p := hp.1
    exact Nat.le_of_dvd hpos ((isPeriodMod_iff hpos).1 hp).1

/-- Transport of the main theorem into `ZMod m`: the reduction of `antiFib` is periodic
with period `pisanoAnti m`. -/
theorem zmod_periodic {m : ℕ} (hm : 0 < m) (n : ℕ) :
    ((antiFib (n + pisanoAnti m) : ℕ) : ZMod m) = ((antiFib n : ℕ) : ZMod m) :=
  (ZMod.natCast_eq_natCast_iff _ _ _).2 ((isLeast_period hm).1.2 n)

/-- No positive period is smaller than the predicted one. -/
theorem lt_pisanoAnti_not_period {m p : ℕ} (hm : 0 < m) (hp : p < pisanoAnti m) :
    ¬ IsPeriodMod m p := fun h => absurd ((isLeast_period hm).2 h) (by omega)

/-- **Multiplicativity on coprime moduli.**  Just like the Pisano period, the
anti-Fibonacci period is multiplicative on coprime arguments — here provably so,
with a two-line parity proof rather than a case analysis on prime powers. -/
theorem pisanoAnti_multiplicative_of_coprime {m₁ m₂ : ℕ} (h : Nat.Coprime m₁ m₂) :
    pisanoAnti (m₁ * m₂) = pisanoAnti m₁ * pisanoAnti m₂ := by
  have hnot : ¬ (m₁ % 2 = 0 ∧ m₂ % 2 = 0) := by
    rintro ⟨h1, h2⟩
    have hdvd : 2 ∣ Nat.gcd m₁ m₂ := Nat.dvd_gcd (by omega) (by omega)
    rw [Nat.Coprime] at h
    rw [h] at hdvd
    omega
  have e1 : m₁ % 2 = 0 ∨ m₁ % 2 = 1 := by omega
  have e2 : m₂ % 2 = 0 ∨ m₂ % 2 = 1 := by omega
  rcases e1 with h1 | h1 <;> rcases e2 with h2 | h2
  · exact absurd ⟨h1, h2⟩ hnot
  · have hprod : (m₁ * m₂) % 2 = 0 := by rw [Nat.mul_mod, h1, h2]
    rw [pisanoAnti_of_even hprod, pisanoAnti_of_even h1, pisanoAnti_of_odd h2]
    ring
  · have hprod : (m₁ * m₂) % 2 = 0 := by rw [Nat.mul_mod, h1, h2]
    rw [pisanoAnti_of_even hprod, pisanoAnti_of_odd h1, pisanoAnti_of_even h2]
    ring
  · have hprod : (m₁ * m₂) % 2 = 1 := by rw [Nat.mul_mod, h1, h2]
    rw [pisanoAnti_of_odd hprod, pisanoAnti_of_odd h1, pisanoAnti_of_odd h2]

/-- **Sharpness of coprimality.**  Multiplicativity genuinely fails for non-coprime
even moduli: the minimal period mod `4` is `8`, not `pisanoAnti 2 * pisanoAnti 2 = 16`. -/
theorem pisanoAnti_not_multiplicative_two_two :
    pisanoAnti (2 * 2) ≠ pisanoAnti 2 * pisanoAnti 2 := by
  rw [pisanoAnti_of_even (by norm_num), pisanoAnti_of_even (by norm_num)]
  norm_num

/-- The minimal period mod `4` really is `8`: an `IsLeast` instance of the main theorem. -/
theorem isLeast_period_four : IsLeast {p : ℕ | IsPeriodMod 4 p} 8 := by
  have h := isLeast_period (m := 4) (by norm_num)
  rwa [pisanoAnti_of_even (by norm_num)] at h

end AntiFibonacciPeriod