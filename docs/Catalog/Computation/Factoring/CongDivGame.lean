import Mathlib

/-!
# CONG-DIV: the divisor congestion game and its Nash equilibrium

Round-3 closure #5 of the factoring-barrier program.  The *divisor congestion
game* on a modulus `N` lets each player bid a number `d ∈ {2, …, N-1}` with
payoff

* `w(d) = N / d`  if `d ∣ N`,
* `w(d) = -N`     otherwise.

The paper claims (experiment 308) that the unique Nash equilibrium of this game
is "everybody bids the smallest proper divisor", and that this equilibrium *is*
the factorization, so the game is a restatement of factoring rather than an
algorithm for it.

This file proves that claim for semiprimes `N = p * q`:

* `CongDiv.payoff_nonneg_iff_dvd` — a single payoff query is exactly a
  divisibility test (barrier-6 circularity: the oracle is trial division).
* `CongDiv.payoff_le_of_semiprime` — `p` (the smaller prime) is a best response.
* `CongDiv.best_response_unique` — for `p < q` it is the *only* best response,
  so the equilibrium bid literally is a nontrivial factor of `N`.
* `CongDiv.equilibrium_factors` — reading off the equilibrium yields the full
  factorization `N = d * (payoff N d)`.
* `CongDiv.payoff_constant_off_divisors` — the payoff landscape is flat away
  from the divisors: no local search can find the equilibrium by hill climbing.
-/

namespace CongDiv

open Finset

/-- Payoff of the bid `d` in the divisor congestion game on `N`. -/
def payoff (N d : ℕ) : ℤ := if d ∣ N then ((N / d : ℕ) : ℤ) else -(N : ℤ)

/-- A payoff query is exactly a divisibility test: this is the circularity at
the heart of the game (barrier 6). -/
theorem payoff_nonneg_iff_dvd {N d : ℕ} (hN : 0 < N) :
    0 ≤ payoff N d ↔ d ∣ N := by
  unfold payoff
  split_ifs with h
  · simp only [h, iff_true]
    exact Int.natCast_nonneg _
  · simp only [h, iff_false, not_le, neg_neg_iff_pos]
    exact_mod_cast hN

/-- Off the divisors the payoff is constant, so the game gives no gradient
information: a best-response search must enumerate candidates. -/
theorem payoff_constant_off_divisors {N d e : ℕ} (hd : ¬ d ∣ N) (he : ¬ e ∣ N) :
    payoff N d = payoff N e := by
  simp [payoff, hd, he]

/-- The payoff of a divisor is its cofactor. -/
theorem payoff_of_dvd {N d : ℕ} (h : d ∣ N) : payoff N d = ((N / d : ℕ) : ℤ) := by
  simp [payoff, h]

/-- The payoff of a non-divisor. -/
theorem payoff_of_not_dvd {N d : ℕ} (h : ¬ d ∣ N) : payoff N d = -(N : ℤ) := by
  simp [payoff, h]

section Semiprime

variable {p q : ℕ}

/-- The bids in `{2, …, N-1}` that divide `N = p*q` are exactly `p` and `q`. -/
theorem mem_divisor_bids (hp : p.Prime) (hq : q.Prime) {d : ℕ}
    (hd2 : 2 ≤ d) (hdlt : d < p * q) (hdvd : d ∣ p * q) : d = p ∨ d = q := by
  have hdmem : d ∈ (p * q).divisors :=
    Nat.mem_divisors.mpr ⟨hdvd, Nat.mul_ne_zero hp.ne_zero hq.ne_zero⟩
  rw [Nat.divisors_mul, hp.divisors, hq.divisors, Finset.mem_mul] at hdmem
  obtain ⟨a, ha, b, hb, hab⟩ := hdmem
  simp only [Finset.mem_insert, Finset.mem_singleton] at ha hb
  rcases ha with rfl | rfl <;> rcases hb with rfl | rfl
  · omega
  · exact Or.inr (by omega)
  · exact Or.inl (by omega)
  · omega

theorem payoff_at_p (hp : p.Prime) : payoff (p * q) p = (q : ℤ) := by
  rw [payoff_of_dvd ⟨q, rfl⟩, Nat.mul_div_cancel_left _ hp.pos]

theorem payoff_at_q (hq : q.Prime) : payoff (p * q) q = (p : ℤ) := by
  rw [payoff_of_dvd ⟨p, mul_comm p q⟩, Nat.mul_div_cancel _ hq.pos]

/-- `p` is a best response: no admissible bid beats the smallest prime factor. -/
theorem payoff_le_of_semiprime (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q)
    {d : ℕ} (hd2 : 2 ≤ d) (hdlt : d < p * q) :
    payoff (p * q) d ≤ payoff (p * q) p := by
  rw [payoff_at_p hp]
  by_cases hdvd : d ∣ p * q
  · rcases mem_divisor_bids hp hq hd2 hdlt hdvd with hd | hd
    · subst hd; rw [payoff_at_p hp]
    · subst hd
      rw [payoff_at_q hq]
      exact_mod_cast hpq
  · rw [payoff_of_not_dvd hdvd]
    have h1 : (0 : ℤ) ≤ (q : ℤ) := Int.natCast_nonneg q
    have h2 : (0 : ℤ) ≤ ((p * q : ℕ) : ℤ) := Int.natCast_nonneg _
    omega

/-- For `p < q` the smallest prime factor is the *unique* best response: the
equilibrium bid is a nontrivial factor of `N`. -/
theorem best_response_unique (hp : p.Prime) (hq : q.Prime) (hpq : p < q)
    {d : ℕ} (hd2 : 2 ≤ d) (hdlt : d < p * q)
    (hbest : ∀ e, 2 ≤ e → e < p * q → payoff (p * q) e ≤ payoff (p * q) d) :
    d = p := by
  have hplt : p < p * q := by nlinarith [hp.two_le, hq.two_le]
  have hpbest : payoff (p * q) p ≤ payoff (p * q) d := hbest p hp.two_le hplt
  rw [payoff_at_p hp] at hpbest
  by_cases hdvd : d ∣ p * q
  · rcases mem_divisor_bids hp hq hd2 hdlt hdvd with hd | hd
    · exact hd
    · exfalso
      subst hd
      rw [payoff_at_q hq] at hpbest
      have : (p : ℤ) < (d : ℤ) := by exact_mod_cast hpq
      omega
  · exfalso
    rw [payoff_of_not_dvd hdvd] at hpbest
    have h1 : (0 : ℤ) < (q : ℤ) := by exact_mod_cast hq.pos
    have h2 : (0 : ℤ) < ((p * q : ℕ) : ℤ) := by
      have : 0 < p * q := Nat.mul_pos hp.pos hq.pos
      exact_mod_cast this
    omega

/-- The equilibrium *is* the factorization: from the equilibrium bid `d` and its
payoff one reads off `N = d * payoff N d` with `d` a nontrivial prime factor. -/
theorem equilibrium_factors (hp : p.Prime) (hq : q.Prime) (hpq : p < q)
    {d : ℕ} (hd2 : 2 ≤ d) (hdlt : d < p * q)
    (hbest : ∀ e, 2 ≤ e → e < p * q → payoff (p * q) e ≤ payoff (p * q) d) :
    ((p * q : ℕ) : ℤ) = (d : ℤ) * payoff (p * q) d ∧ d.Prime ∧ 1 < d ∧ d < p * q := by
  obtain rfl := best_response_unique hp hq hpq hd2 hdlt hbest
  refine ⟨?_, hp, hp.one_lt, hdlt⟩
  rw [payoff_at_p hp]
  push_cast
  ring

end Semiprime

section General

/-! ### The general composite case

The semiprime analysis is a special case: for *any* composite `N` the unique
best response is the least prime factor, and its payoff is the cofactor. -/

/-- For any `N` with a proper divisor, the least prime factor is a best
response. -/
theorem payoff_le_minFac {N : ℕ} (hN : 0 < N) {d : ℕ} (hd2 : 2 ≤ d) :
    payoff N d ≤ payoff N N.minFac := by
  have hmf : N.minFac ∣ N := Nat.minFac_dvd N
  rw [payoff_of_dvd hmf]
  by_cases hdvd : d ∣ N
  · rw [payoff_of_dvd hdvd]
    have hle : N.minFac ≤ d := Nat.minFac_le_of_dvd hd2 hdvd
    exact_mod_cast Nat.div_le_div_left hle (Nat.minFac_pos N)
  · rw [payoff_of_not_dvd hdvd]
    have h1 : (0 : ℤ) ≤ ((N / N.minFac : ℕ) : ℤ) := Int.natCast_nonneg _
    have h2 : (0 : ℤ) < (N : ℤ) := by exact_mod_cast hN
    omega

/-- The best response is *unique* among admissible bids, for every composite
`N`: the equilibrium bid is the least prime factor. -/
theorem best_response_unique_general {N : ℕ} (hN : 0 < N) {d : ℕ} (hd2 : 2 ≤ d)
    (hbest : ∀ e, 2 ≤ e → e < N → payoff N e ≤ payoff N d)
    (hmflt : N.minFac < N) : d = N.minFac := by
  have hmf : N.minFac ∣ N := Nat.minFac_dvd N
  have hN1 : N ≠ 1 := by rintro rfl; simp at hmflt
  have hmf2 : 2 ≤ N.minFac := (Nat.minFac_prime hN1).two_le
  have hkey : payoff N N.minFac ≤ payoff N d := hbest _ hmf2 hmflt
  rw [payoff_of_dvd hmf] at hkey
  by_cases hdvd : d ∣ N
  · rw [payoff_of_dvd hdvd] at hkey
    have hle : N.minFac ≤ d := Nat.minFac_le_of_dvd hd2 hdvd
    have hdiv : N / d ≤ N / N.minFac := Nat.div_le_div_left hle (Nat.minFac_pos N)
    have heq : N / d = N / N.minFac := by
      have : ((N / N.minFac : ℕ) : ℤ) ≤ ((N / d : ℕ) : ℤ) := hkey
      have : N / N.minFac ≤ N / d := by exact_mod_cast this
      omega
    -- distinct divisors have distinct cofactors
    have h1 : d * (N / d) = N := Nat.mul_div_cancel' hdvd
    have h2 : N.minFac * (N / N.minFac) = N := Nat.mul_div_cancel' hmf
    have hpos : 0 < N / d := Nat.div_pos (Nat.le_of_dvd hN hdvd) (by omega)
    rw [heq] at h1
    have := h1.trans h2.symm
    exact Nat.eq_of_mul_eq_mul_right (by omega) this
  · exfalso
    rw [payoff_of_not_dvd hdvd] at hkey
    have h1 : (0 : ℤ) ≤ ((N / N.minFac : ℕ) : ℤ) := Int.natCast_nonneg _
    have h2 : (0 : ℤ) < (N : ℤ) := by exact_mod_cast hN
    omega

end General

/-- Concrete instance (experiment 308 data): for `N = 91 = 7 * 13` the bid `7`
has payoff `13` and is a best response. -/
example : payoff 91 7 = 13 ∧ ∀ d, 2 ≤ d → d < 91 → payoff 91 d ≤ payoff 91 7 := by
  refine ⟨by decide, fun d hd2 hdlt => ?_⟩
  have := payoff_le_of_semiprime (p := 7) (q := 13) (by norm_num) (by norm_num)
    (by norm_num) hd2 (show d < 7 * 13 by omega)
  simpa using this

end CongDiv