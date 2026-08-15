import Mathlib
import Combinatorics.PowerSumFactorReveal
import Combinatorics.PowerSumCarmichaelPeriod
import Shared.ThreeSumFactorReveal

/-!
# The power-sum reveal for arbitrary moduli: obstructions and structure

`Combinatorics.PowerSumFactorReveal` evaluates `gcd (F(N,k), N)` for *squarefree* `N`.
Here we remove the squarefreeness hypothesis and expose the resulting obstructions, and we
describe the structure of the reveal function inside one period.

* `prime_dvd_powerSum_iff_general` — for any `N` and any prime `p ∣ N`,
  `p ∣ F(N,k) ↔ ((p-1) ∤ k ∨ p ∣ N/p)`.
* `sq_dvd_always_dvd_powerSum` — if `p² ∣ N` then `p ∣ F(N,k)` for **every** `k ≥ 1`:
  repeated prime factors are permanently stuck inside the gcd, so the method can never
  separate them.  This is a genuine limitation, not a corner case.
* `powerSum_one_two_mul` / `dvd_powerSum_one_of_odd` — `k = 1` is always useless for odd `N`
  (`F(N,1) = N(N+1)/2`).
* `always_reveals_iff_even` — for squarefree `N > 1`, the reveal function is *everywhere*
  nontrivial iff `N` is even; for odd `N` the exponent `k = 1` always fails.  The underlying
  combinatorial statement is that the congruence classes `0 mod (p-1)`, `p ∣ N`, cover all of
  `ℕ⁺` iff one of them is the full class `0 mod 1`.
* `card_trivial_in_period` — inside one period `1 ≤ k ≤ λ(N)` there is exactly one exponent
  with trivial gcd, namely `k = λ(N)`.
-/

namespace PowerSumReveal

open Finset

/-! ## Arbitrary moduli -/

/-- **General local criterion.**  For any modulus `N`, any prime `p ∣ N` and any `k ≥ 1`,
`p` divides the power sum exactly when `(p-1) ∤ k` or `p` divides the cofactor `N / p`. -/
theorem prime_dvd_powerSum_iff_general {N p k : ℕ} (hp : p.Prime) (hpN : p ∣ N) (hk : k ≠ 0) :
    p ∣ powerSum N k ↔ (¬ (p - 1) ∣ k ∨ p ∣ N / p) := by
  haveI : Fact p.Prime := ⟨hp⟩
  rw [← ZMod.natCast_eq_zero_iff (powerSum N k) p, cast_powerSum N p k hp hpN hk]
  by_cases hd : (p - 1) ∣ k
  · simp only [hd, if_true, not_true_eq_false, false_or]
    constructor
    · intro h
      have h' : ((N / p : ℕ) : ZMod p) = 0 := by
        rw [nsmul_eq_mul] at h
        simpa using h
      exact (ZMod.natCast_eq_zero_iff _ p).mp h'
    · intro h
      have h' : ((N / p : ℕ) : ZMod p) = 0 := (ZMod.natCast_eq_zero_iff _ p).mpr h
      rw [nsmul_eq_mul, h']
      ring
  · simp [hd]

/-- **Obstruction from repeated factors.**  If `p² ∣ N` then `p ∣ F(N,k)` for every `k ≥ 1`,
so `p` divides `gcd (F(N,k), N)` for all exponents and can never be split off by varying `k`. -/
theorem sq_dvd_always_dvd_powerSum {N p k : ℕ} (hp : p.Prime) (hsq : p * p ∣ N) (hk : k ≠ 0) :
    p ∣ powerSum N k := by
  obtain ⟨c, hc⟩ := hsq
  have hpN : p ∣ N := ⟨p * c, by rw [hc]; ring⟩
  have hdiv : N / p = p * c := by
    rw [hc, mul_assoc, Nat.mul_div_cancel_left _ hp.pos]
  exact (prime_dvd_powerSum_iff_general hp hpN hk).mpr (Or.inr ⟨c, hdiv⟩)

/-- Consequently the reveal gcd of a non-squarefree modulus is never coprime-free: it is
always divisible by every prime whose square divides `N`. -/
theorem sq_dvd_dvd_revealGcd {N p k : ℕ} (hp : p.Prime) (hsq : p * p ∣ N) (hk : k ≠ 0) :
    p ∣ revealGcd N k :=
  Nat.dvd_gcd (sq_dvd_always_dvd_powerSum hp hsq hk) (dvd_trans ⟨p, rfl⟩ hsq)

/-! ## The exponent `k = 1` -/

/-- Gauss: `2 · F(N,1) = N (N+1)`. -/
theorem powerSum_one_two_mul (N : ℕ) : 2 * powerSum N 1 = N * (N + 1) := by
  induction N with
  | zero => simp [powerSum]
  | succ n ih =>
      have hIcc : Finset.Icc 1 (n + 1) = insert (n + 1) (Finset.Icc 1 n) := by
        ext x; simp [Finset.mem_Icc]; omega
      have hnot : (n + 1) ∉ Finset.Icc 1 n := by simp
      have hstep : powerSum (n + 1) 1 = (n + 1) + powerSum n 1 := by
        rw [powerSum, powerSum, hIcc, Finset.sum_insert hnot]
        simp
      rw [hstep, Nat.mul_add, ih]
      ring

/-- For odd `N`, the exponent `k = 1` reveals nothing: `N ∣ F(N,1)`. -/
theorem dvd_powerSum_one_of_odd {N : ℕ} (hN : Odd N) : N ∣ powerSum N 1 := by
  obtain ⟨m, hm⟩ := hN
  have h2 : 2 * powerSum N 1 = 2 * (N * (m + 1)) := by
    rw [powerSum_one_two_mul N, hm]; ring
  exact ⟨m + 1, Nat.eq_of_mul_eq_mul_left (by norm_num) h2⟩

/-- **The barrier is about complete coverage, not about degree.**  The degree barrier of
`Combinatorics.PowerSumPolynomialBarrier` applies to sums over the *whole* interval
`[1, N]`.  A *partial* sum of the very lowest degree already reveals a factor: for an odd
prime `p < q`, the triangular number `∑_{a=1}^{p-1} a` has gcd exactly `p` with `N = pq`.
The reveal lemma of `Shared.ThreeSumFactorReveal` supplies the last step. -/
theorem partial_sum_reveal {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hodd : Odd p) (hlt : p < q) :
    Nat.gcd (powerSum (p - 1) 1) (p * q) = p := by
  have hp2 := hp.two_le
  obtain ⟨m, hm⟩ := hodd
  have hs : powerSum (p - 1) 1 = m * p := by
    have h2 : 2 * powerSum (p - 1) 1 = (p - 1) * p := by
      have := powerSum_one_two_mul (p - 1)
      have hp1 : p - 1 + 1 = p := by omega
      rwa [hp1] at this
    have hp1 : p - 1 = 2 * m := by omega
    rw [hp1] at h2
    have h3 : 2 * powerSum (p - 1) 1 = 2 * (m * p) := by rw [hp1, h2]; ring
    exact Nat.eq_of_mul_eq_mul_left (by norm_num) h3
  have hm1 : 1 ≤ m := by omega
  have hpos : 0 < powerSum (p - 1) 1 := by
    rw [hs]; positivity
  have hlt' : powerSum (p - 1) 1 < p * q := by
    rw [hs]
    nlinarith [hp.pos, (show m < q by omega)]
  exact ThreeSumReveal.gcd_eq_prime_of_dvd_of_lt hp hq hpos hlt' ⟨m, by rw [hs]; ring⟩

/-! ## Covering-system reformulation -/

/-- **Everywhere-nontrivial reveal ⟺ even modulus.**  For squarefree `N > 1` the reveal
function is a proper divisor of `N` for every exponent `k ≥ 1` if and only if `N` is even.
For odd `N` the exponent `k = 1` returns the whole modulus, i.e. no information.

Combinatorially: the classes `{k : (p-1) ∣ k}` for `p ∣ N` cover `ℕ⁺` iff one of them is
everything, i.e. iff `p = 2` occurs. -/
theorem always_reveals_iff_even {N : ℕ} (hN : 1 < N) (hsq : Squarefree N) :
    (∀ k, k ≠ 0 → revealGcd N k < N) ↔ 2 ∣ N := by
  have hN0 : N ≠ 0 := by omega
  constructor
  · intro h
    by_contra heven
    have hodd : Odd N := Nat.odd_iff.mpr (Nat.two_dvd_ne_zero.mp heven)
    have h1 : revealGcd N 1 = N :=
      Nat.gcd_eq_right (dvd_powerSum_one_of_odd hodd)
    exact absurd h1 (by have := h 1 one_ne_zero; omega)
  · intro heven k hk
    have h2p : (2 : ℕ).Prime := Nat.prime_two
    have h2F : ¬ (2 ∣ powerSum N k) := by
      rw [prime_dvd_powerSum_iff h2p heven hsq hk]
      simp
    have hdvd : revealGcd N k ∣ N := Nat.gcd_dvd_right _ _
    have hne : revealGcd N k ≠ N := by
      intro h
      have hNF : N ∣ powerSum N k := by
        have : revealGcd N k ∣ powerSum N k := Nat.gcd_dvd_left (powerSum N k) N
        rwa [h] at this
      exact h2F (dvd_trans heven hNF)
    exact lt_of_le_of_ne (Nat.le_of_dvd (by omega) hdvd) hne

/-! ## Structure inside one period -/

theorem lam_pos (N : ℕ) : 0 < lam N := by
  rcases Nat.eq_zero_or_pos (lam N) with h | h
  · exfalso
    rw [lam, Finset.lcm_eq_zero_iff] at h
    obtain ⟨p, hp, hp0⟩ := h
    have := (Nat.prime_of_mem_primeFactors hp).two_le
    omega
  · exact h

/-- **One trivial exponent per period.**  For squarefree `N > 1` exactly one exponent in
`{1, …, λ(N)}` has trivial reveal gcd, namely `k = λ(N)` itself.  Together with
`period_iff_lcm_dvd` this pins the reveal function down completely. -/
theorem card_trivial_in_period {N : ℕ} (hN : 1 < N) (hsq : Squarefree N) :
    ((Finset.Icc 1 (lam N)).filter (fun k => revealGcd N k = 1)) = {lam N} := by
  have hL : 0 < lam N := lam_pos N
  ext k
  simp only [Finset.mem_filter, Finset.mem_Icc, Finset.mem_singleton]
  constructor
  · rintro ⟨⟨hk1, hk2⟩, hgcd⟩
    have hdvd : lam N ∣ k :=
      (gcd_powerSum_eq_one_iff hN hsq (by omega)).mp hgcd
    have := Nat.le_of_dvd (by omega) hdvd
    omega
  · rintro rfl
    refine ⟨⟨hL, le_rfl⟩, ?_⟩
    exact (gcd_powerSum_eq_one_iff hN hsq (by omega)).mpr dvd_rfl

end PowerSumReveal