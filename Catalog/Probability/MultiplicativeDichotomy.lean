/-
# The multiplicative dichotomy

A sharpening of the structural-orthogonality thesis for the classical
multiplicative invariants of a semiprime `N = p*q` (`p ≠ q` prime).  Each such
invariant falls on exactly one of two sides:

* **Constant side (no information).**  The number of divisors, the number of
  distinct prime factors and the Möbius value are *literally constant* on the
  set of semiprimes: `4`, `2`, `1`.  They cannot distinguish any two
  semiprimes, let alone their factors
  (`FactoringLab.constant_invariants_carry_no_information`).
* **Circular side (as hard as factoring).**  The sum of divisors `σ₁` and
  Euler's totient `φ` both reveal `p + q` from `N`, and `(N, p+q)` recovers the
  factorization in closed form
  (`FactoringLab.factor_recovery_from_sigma`).  An invariant on this side does
  not help: computing it is already a factoring algorithm.

There is no third option among these classical invariants — which is exactly
the empirical "N-only or circular" pattern of the lab experiments.
-/
import Mathlib
import Probability.SymmetryCircularity

namespace FactoringLab

open ArithmeticFunction

/-! ### The constant side -/

/-- A semiprime has exactly four divisors. -/
theorem tau_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    (p * q).divisors.card = 4 := by
  rw [Nat.Coprime.card_divisors_mul ((Nat.coprime_primes hp hq).2 hne), hp.divisors, hq.divisors,
    Finset.card_pair hp.one_lt.ne, Finset.card_pair hq.one_lt.ne]

/-- A semiprime has exactly two distinct prime factors. -/
theorem omega_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    (p * q).primeFactors.card = 2 := by
  rw [Nat.primeFactors_mul hp.ne_zero hq.ne_zero, hp.primeFactors, hq.primeFactors,
    Finset.card_union_of_disjoint (by simp [hne])]
  simp

/-- The Möbius value of a semiprime is `1`. -/
theorem moebius_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    moebius (p * q) = 1 := by
  have hsq : Squarefree (p * q) := (Nat.squarefree_mul_iff).2
    ⟨(Nat.coprime_primes hp hq).2 hne, hp.squarefree, hq.squarefree⟩
  rw [moebius_apply_of_squarefree hsq, cardFactors_mul hp.ne_zero hq.ne_zero,
    cardFactors_apply_prime hp, cardFactors_apply_prime hq]
  norm_num

/-- **The constant side of the dichotomy.**  The divisor count, the number of
distinct prime factors, and the Möbius value take the same values on *every*
semiprime, so they carry no information whatsoever about the factors. -/
theorem constant_invariants_carry_no_information
    {p q p' q' : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (hp' : p'.Prime) (hq' : q'.Prime) (hne' : p' ≠ q') :
    (p * q).divisors.card = (p' * q').divisors.card ∧
      (p * q).primeFactors.card = (p' * q').primeFactors.card ∧
        moebius (p * q) = moebius (p' * q') := by
  refine ⟨?_, ?_, ?_⟩
  · rw [tau_semiprime hp hq hne, tau_semiprime hp' hq' hne']
  · rw [omega_semiprime hp hq hne, omega_semiprime hp' hq' hne']
  · rw [moebius_semiprime hp hq hne, moebius_semiprime hp' hq' hne']

/-! ### The circular side -/

/-- The sum of divisors of a semiprime. -/
theorem sigma_one_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    sigma 1 (p * q) = (1 + p) * (1 + q) := by
  have hs : ∀ r : ℕ, r.Prime → ∑ d ∈ r.divisors, d = 1 + r := by
    intro r hr
    rw [hr.divisors, Finset.sum_pair hr.one_lt.ne]
  rw [isMultiplicative_sigma.map_mul_of_coprime ((Nat.coprime_primes hp hq).2 hne),
    sigma_one_apply, sigma_one_apply, hs p hp, hs q hq]

/-- The sum of the prime factors of a semiprime is read off from `N` and
`σ₁(N)`. -/
theorem sum_factors_from_sigma {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    (sigma 1 (p * q) : ℤ) - (p * q : ℕ) - 1 = (p : ℤ) + q := by
  rw [sigma_one_semiprime hp hq hne]
  push_cast
  ring

/-- **The circular side of the dichotomy (σ version).**  From `N = p*q` and the
sum of divisors `S = σ₁(N)`, the two prime factors are recovered in closed
form.  Hence any invariant that determines `σ₁(N)` is already a factoring
algorithm. -/
theorem factor_recovery_from_sigma {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (hpq : p ≤ q) :
    let N : ℤ := (p * q : ℕ)
    let s : ℤ := (sigma 1 (p * q) : ℤ) - N - 1
    ((s - (Int.sqrt (s ^ 2 - 4 * N) : ℤ)) / 2 = (p : ℤ)) ∧
      ((s + (Int.sqrt (s ^ 2 - 4 * N) : ℤ)) / 2 = (q : ℤ)) := by
  intro N s
  have hs : s = (p : ℤ) + q := by
    simp only [s, N]
    exact sum_factors_from_sigma hp hq hne
  have hN : N = (p : ℤ) * q := by simp [N]
  obtain ⟨_, h1, h2⟩ :=
    recovery_from_sum (p := (p : ℤ)) (q := (q : ℤ)) (by exact_mod_cast hpq) hN hs
  exact ⟨h1, h2⟩

/-- **The circular side of the dichotomy (φ version).**  The same closed-form
recovery from `N` and Euler's totient value. -/
theorem factor_recovery_from_totient_nat {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hne : p ≠ q) (hpq : p ≤ q) :
    let N : ℤ := (p * q : ℕ)
    let s : ℤ := N + 1 - (Nat.totient (p * q) : ℤ)
    ((s - (Int.sqrt (s ^ 2 - 4 * N) : ℤ)) / 2 = (p : ℤ)) ∧
      ((s + (Int.sqrt (s ^ 2 - 4 * N) : ℤ)) / 2 = (q : ℤ)) := by
  intro N s
  have htot : Nat.totient (p * q) = (p - 1) * (q - 1) := totient_semiprime hp hq hne
  have hp1 : 1 ≤ p := hp.one_lt.le.trans' (by norm_num)
  have hq1 : 1 ≤ q := hq.one_lt.le.trans' (by norm_num)
  have hcast : ((Nat.totient (p * q) : ℕ) : ℤ) = ((p : ℤ) - 1) * ((q : ℤ) - 1) := by
    rw [htot]
    push_cast [Nat.cast_sub hp1, Nat.cast_sub hq1]
    ring
  have hs : s = (p : ℤ) + q := by
    simp only [s, N, hcast]
    push_cast
    ring
  have hN : N = (p : ℤ) * q := by simp [N]
  obtain ⟨_, h1, h2⟩ :=
    recovery_from_sum (p := (p : ℤ)) (q := (q : ℤ)) (by exact_mod_cast hpq) hN hs
  exact ⟨h1, h2⟩


/-! ### The dichotomy for the whole affine family -/

/-- **The affine multiplicative dichotomy.**  Consider the family of
multiplicative invariants whose value at a prime `r` is `r + c` — it contains
`φ` (`c = -1`), `σ₁` (`c = 1`) and the identity `N` itself (`c = 0`).  Then:

* for `c = 0` the invariant equals `N` and carries no extra information;
* for `c ≠ 0` the invariant reveals `p + q` and hence, by `recovery_from_sum`,
  the complete factorization in closed form.

There is no intermediate behaviour in this family: an invariant is either `N`
in disguise or a factoring algorithm in disguise. -/
theorem affine_invariant_dichotomy {p q c : ℤ} (hpq : p ≤ q) :
    (c = 0 → (p + c) * (q + c) = p * q) ∧
      (c ≠ 0 →
        let N := p * q
        let T := (p + c) * (q + c)
        let s := (T - N - c ^ 2) / c
        s = p + q ∧
          (s - (Int.sqrt (s ^ 2 - 4 * N) : ℤ)) / 2 = p ∧
          (s + (Int.sqrt (s ^ 2 - 4 * N) : ℤ)) / 2 = q) := by
  constructor
  · rintro rfl; ring
  · intro hc N T s
    have hTN : T - N - c ^ 2 = c * (p + q) := by simp only [T, N]; ring
    have hs : s = p + q := by
      simp only [s, hTN]
      exact Int.mul_ediv_cancel_left _ hc
    obtain ⟨_, h1, h2⟩ := recovery_from_sum hpq (rfl : N = p * q) hs
    exact ⟨hs, h1, h2⟩

end FactoringLab