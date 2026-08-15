import Mathlib
import Combinatorics.PowerSumFactorReveal

/-!
# Carmichael periodicity of the power-sum gcd, and robustness against bad bases

Building on `Combinatorics.PowerSumFactorReveal`, we study the *reveal function*
`g(k) = gcd (F(N,k), N)` of a semiprime `N = p q`, where `F(N,k) = ∑_{a=1}^N a^k`.

By the exact evaluation `gcd_powerSum_semiprime`, `g` only depends on the two
divisibility bits `(p-1) ∣ k` and `(q-1) ∣ k`.  Consequently:

* `revealGcd_periodic` — `g` is periodic with period `λ = lcm (p-1) (q-1)`;
* `period_iff_lcm_dvd` — `d` is a period of `g` **iff** `λ ∣ d`, so `λ` is exactly the
  minimal period: it is readable off the graph of `g`;
* `first_reveal` — the least exponent producing a *proper* factor is `k = min (p-1, q-1)`,
  confirming the `O(N^{3/2})` cost heuristic;
* `sum_eq_of_totient` / `factors_from_period` — the factors are recovered from the period,
  but through `φ(N) = λ(N) · gcd (p-1, q-1)`, **not** through `λ(N)` alone;
* `paper_period_formula_fails` — for distinct odd primes the naive recovery formula
  `p + q = N - λ(N) + 1` is always false (a corrected, guarded version is proved);
* `pollard_bad_base_useless` / `powerSum_beats_bad_base` — a Pollard `p-1` computation with
  the (perfectly legitimate, `N`-coprime) base `N - 1` returns `N` for every even exponent
  and therefore never factors, while the power sum reveals a proper factor at the very same
  exponent: the aggregated power sum has no bad bases.

The final section records machine-checked instances (Lab Notes).
-/

namespace PowerSumReveal

open Finset

/-- The reveal function `g(k) = gcd (F(N,k), N)`. -/
def revealGcd (N k : ℕ) : ℕ := Nat.gcd (powerSum N k) N

/-- The Carmichael exponent of a semiprime: `λ(pq) = lcm (p-1) (q-1)`. -/
def semiLam (p q : ℕ) : ℕ := Nat.lcm (p - 1) (q - 1)

theorem semiLam_pos {p q : ℕ} (hp : p.Prime) (hq : q.Prime) : 0 < semiLam p q := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  exact Nat.lcm_pos (by omega) (by omega)

/-- The reveal function, evaluated. -/
theorem revealGcd_eq {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {k : ℕ} (hk : k ≠ 0) :
    revealGcd (p * q) k = (if (p - 1) ∣ k then 1 else p) * (if (q - 1) ∣ k then 1 else q) :=
  gcd_powerSum_semiprime hp hq hpq hk

/-- **Necessity of the side condition.**  If `(q-1) ∣ (p-1)` — which for primes forces `q < p`
— then the exponent `k = p - 1` reveals nothing at all: the gcd collapses to `1`.  So the
hypothesis `(q-1) ∤ (p-1)` of `powerSum_reveal` cannot be dropped. -/
theorem powerSum_reveal_fails {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hdvd : (q - 1) ∣ (p - 1)) : revealGcd (p * q) (p - 1) = 1 := by
  have hp2 := hp.two_le
  rw [revealGcd_eq hp hq hpq (by omega : p - 1 ≠ 0)]
  simp [hdvd]

/-! ## Theorem 3: periodicity -/

/-- **Periodicity.**  `g(k + λ) = g(k)` for every `k ≥ 1`, where `λ = lcm (p-1) (q-1)`. -/
theorem revealGcd_periodic {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) {k : ℕ}
    (hk : k ≠ 0) : revealGcd (p * q) (k + semiLam p q) = revealGcd (p * q) k := by
  have hdp : (p - 1) ∣ semiLam p q := Nat.dvd_lcm_left _ _
  have hdq : (q - 1) ∣ semiLam p q := Nat.dvd_lcm_right _ _
  rw [revealGcd_eq hp hq hpq (by omega), revealGcd_eq hp hq hpq hk]
  simp only [Nat.dvd_add_left hdp, Nat.dvd_add_left hdq]

/-- Any period of `g` (as a function on exponents `≥ 1`) is a multiple of `λ`. -/
theorem lcm_dvd_of_period {p q d : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hper : ∀ k, k ≠ 0 → revealGcd (p * q) (k + d) = revealGcd (p * q) k) :
    semiLam p q ∣ d := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hL : semiLam p q ≠ 0 := (semiLam_pos hp hq).ne'
  have hdp : (p - 1) ∣ semiLam p q := Nat.dvd_lcm_left _ _
  have hdq : (q - 1) ∣ semiLam p q := Nat.dvd_lcm_right _ _
  have h1 : revealGcd (p * q) (semiLam p q) = 1 := by
    rw [revealGcd_eq hp hq hpq hL]
    simp [hdp, hdq]
  have h2 : revealGcd (p * q) (semiLam p q + d) = 1 := by
    rw [hper _ hL, h1]
  rw [revealGcd_eq hp hq hpq (by omega)] at h2
  have hb1 : (p - 1) ∣ (semiLam p q + d) := by
    by_contra hb
    rw [if_neg hb] at h2
    have hpd : p ∣ 1 := ⟨_, h2.symm⟩
    have := Nat.le_of_dvd one_pos hpd
    omega
  have hb2 : (q - 1) ∣ (semiLam p q + d) := by
    by_contra hb
    rw [if_neg hb] at h2
    have hqd : q ∣ 1 := ⟨_, by rw [← h2]; ring⟩
    have := Nat.le_of_dvd one_pos hqd
    omega
  refine Nat.lcm_dvd ?_ ?_
  · exact (Nat.dvd_add_right hdp).mp ((add_comm (semiLam p q) d) ▸ hb1)
  · exact (Nat.dvd_add_right hdq).mp ((add_comm (semiLam p q) d) ▸ hb2)

/-- **Exact period.**  `d` is a period of the reveal function iff `λ(N) = lcm (p-1) (q-1)`
divides `d`.  In particular `λ(N)` is the minimal period and is therefore readable from the
sequence `k ↦ gcd (F(N,k), N)`. -/
theorem period_iff_lcm_dvd {p q d : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    (∀ k, k ≠ 0 → revealGcd (p * q) (k + d) = revealGcd (p * q) k) ↔ semiLam p q ∣ d := by
  constructor
  · exact lcm_dvd_of_period hp hq hpq
  · intro ⟨c, hc⟩ k hk
    have hdp : (p - 1) ∣ d := hc ▸ Dvd.dvd.mul_right (Nat.dvd_lcm_left _ _) c
    have hdq : (q - 1) ∣ d := hc ▸ Dvd.dvd.mul_right (Nat.dvd_lcm_right _ _) c
    rw [revealGcd_eq hp hq hpq (by omega), revealGcd_eq hp hq hpq hk]
    simp only [Nat.dvd_add_left hdp, Nat.dvd_add_left hdq]

/-! ## First reveal and the complexity heuristic -/

/-- **First hit.**  For `p < q` the least exponent at which the power-sum gcd is a *proper*
nontrivial divisor of `N = pq` is exactly `k = p - 1 = min (p-1, q-1)`. -/
theorem first_reveal {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hlt : p < q) :
    IsLeast {k : ℕ | k ≠ 0 ∧ 1 < revealGcd (p * q) k ∧ revealGcd (p * q) k < p * q} (p - 1) := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hpq : p ≠ q := by omega
  constructor
  · refine ⟨by omega, ?_, ?_⟩ <;>
    · have hne : ¬ (q - 1) ∣ (p - 1) := by
        intro h
        have := Nat.le_of_dvd (by omega) h
        omega
      rw [revealGcd_eq hp hq hpq (by omega : p - 1 ≠ 0)]
      simp only [dvd_refl, if_true, hne, if_false, one_mul]
      nlinarith
  · intro k hk
    obtain ⟨hk0, hk1, hk2⟩ := hk
    by_contra hlt'
    push_neg at hlt'
    have hnp : ¬ (p - 1) ∣ k := by
      intro h
      have := Nat.le_of_dvd (Nat.pos_of_ne_zero hk0) h
      omega
    have hnq : ¬ (q - 1) ∣ k := by
      intro h
      have := Nat.le_of_dvd (Nat.pos_of_ne_zero hk0) h
      omega
    rw [revealGcd_eq hp hq hpq hk0] at hk2
    simp only [hnp, hnq, if_false] at hk2
    omega

/-! ## Recovering the factors from the period -/

/-- The classical identity `p + q = N + 1 - φ(N)` for a semiprime. -/
theorem sum_eq_of_totient {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    p + q = p * q + 1 - (p - 1) * (q - 1) := by
  obtain ⟨a, ha⟩ : ∃ a, p = a + 2 := ⟨p - 2, by have := hp.two_le; omega⟩
  obtain ⟨b, hb⟩ : ∃ b, q = b + 2 := ⟨q - 2, by have := hq.two_le; omega⟩
  subst ha; subst hb
  have h : (a + 2) * (b + 2) = a * b + 2 * a + 2 * b + 4 := by ring
  have h2 : (a + 2 - 1) * (b + 2 - 1) = a * b + a + b + 1 := by
    show (a + 1) * (b + 1) = a * b + a + b + 1
    ring
  omega

/-- `φ(N) = λ(N) · gcd (p-1, q-1)` for a semiprime `N = pq`. -/
theorem totient_eq_lam_mul_gcd (p q : ℕ) :
    (p - 1) * (q - 1) = semiLam p q * Nat.gcd (p - 1) (q - 1) := by
  rw [semiLam, mul_comm (Nat.lcm (p - 1) (q - 1)), Nat.gcd_mul_lcm]

/-- **Corrected factor recovery.**  Knowing `N` and the period `λ(N)` together with
`G = gcd (p-1, q-1)` determines `p + q`, hence `p` and `q` as the roots of
`X² - (p+q) X + N`. -/
theorem factors_from_period {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    p + q = p * q + 1 - semiLam p q * Nat.gcd (p - 1) (q - 1) := by
  rw [← totient_eq_lam_mul_gcd]
  exact sum_eq_of_totient hp hq

/-- **The uncorrected formula is false.**  For *odd* primes `p, q`,
`p + q < N - λ(N) + 1`: the recovery formula `p + q = N - λ(N) + 1` from the informal
write-up never holds, because `gcd (p-1, q-1) ≥ 2` makes `φ(N)` strictly larger than
`λ(N)`.  (Distinctness of `p` and `q` is not needed for the failure.) -/
theorem paper_period_formula_fails {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpo : Odd p) (hqo : Odd q) : p + q + semiLam p q < p * q + 1 := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hL : 0 < semiLam p q := semiLam_pos hp hq
  have h2p : 2 ∣ (p - 1) := by
    obtain ⟨m, hm⟩ := hpo; exact ⟨m, by omega⟩
  have h2q : 2 ∣ (q - 1) := by
    obtain ⟨m, hm⟩ := hqo; exact ⟨m, by omega⟩
  have h2G : 2 ∣ Nat.gcd (p - 1) (q - 1) := Nat.dvd_gcd h2p h2q
  have hG2 : 2 ≤ Nat.gcd (p - 1) (q - 1) :=
    Nat.le_of_dvd (Nat.gcd_pos_of_pos_left _ (by omega)) h2G
  have hphi : (p - 1) * (q - 1) = semiLam p q * Nat.gcd (p - 1) (q - 1) :=
    totient_eq_lam_mul_gcd p q
  have hbig : 2 * semiLam p q ≤ (p - 1) * (q - 1) := by
    rw [hphi, mul_comm 2 (semiLam p q)]
    exact Nat.mul_le_mul_left _ hG2
  have hsum : p + q = p * q + 1 - (p - 1) * (q - 1) := sum_eq_of_totient hp hq
  have hle : (p - 1) * (q - 1) ≤ p * q + 1 := by nlinarith [Nat.sub_le p 1, Nat.sub_le q 1]
  omega

/-- A concrete instance of the failure: `p = 3, q = 5` gives `p + q = 8` but
`N - λ(N) + 1 = 12`. -/
theorem paper_period_formula_counterexample :
    (3 : ℕ) + 5 ≠ 3 * 5 - semiLam 3 5 + 1 := by
  norm_num [semiLam, Nat.lcm]

/-! ## Theorem 2: no bad bases -/

/-- The base `N - 1` is coprime to `N`, hence a legitimate Pollard `p-1` base. -/
theorem coprime_sub_one (N : ℕ) (hN : 1 ≤ N) : Nat.Coprime (N - 1) N := by
  have : N = (N - 1) + 1 := by omega
  rw [this]
  simp

/-- **A genuinely bad base for Pollard `p-1`.**  For every even exponent `k` the classical
Pollard quantity `gcd (a^k - 1, N)` with the coprime base `a = N - 1` equals `N`: the
computation fails to produce any factor, for every even `k` at once. -/
theorem pollard_bad_base_useless {N k : ℕ} (hN : 2 ≤ N) (hk : Even k) :
    Nat.gcd ((N - 1) ^ k - 1) N = N := by
  haveI : NeZero N := ⟨by omega⟩
  have hpow : 1 ≤ (N - 1) ^ k := Nat.one_le_pow _ _ (by omega)
  have hcast : (((N - 1) ^ k - 1 : ℕ) : ZMod N) = 0 := by
    rw [Nat.cast_sub hpow]
    push_cast [Nat.cast_sub (show 1 ≤ N by omega)]
    rw [show ((N : ZMod N) - 1) = -1 by simp]
    rw [hk.neg_one_pow]
    ring
  have hdvd : N ∣ (N - 1) ^ k - 1 := (ZMod.natCast_eq_zero_iff _ N).mp hcast
  exact Nat.gcd_eq_right hdvd

/-- **Theorem 2 (robustness).**  At the exponent `k = p - 1` (even, since `p` is an odd prime)
the Pollard computation with the coprime base `N - 1` returns the useless value `N`, while the
aggregated power sum returns the proper factor `q`.  The power sum has no bad base because it
sums over *all* bases simultaneously. -/
theorem powerSum_beats_bad_base {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hpo : Odd p) (hdvd : ¬ (q - 1) ∣ (p - 1)) :
    Nat.gcd ((p * q - 1) ^ (p - 1) - 1) (p * q) = p * q ∧
      revealGcd (p * q) (p - 1) = q ∧ 1 < q ∧ q < p * q := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hN : 2 ≤ p * q := by nlinarith
  have heven : Even (p - 1) := by
    obtain ⟨m, hm⟩ := hpo
    exact ⟨m, by omega⟩
  refine ⟨pollard_bad_base_useless hN heven, powerSum_reveal hp hq hpq hdvd, by omega, ?_⟩
  nlinarith

/-! ## Lab Notes: machine-checked instances

The following instances are *derived from the general theorems*, not computed by
decision procedures on the (astronomically large) power sums themselves.
They match the numerical experiment recorded in `ComputationalEvidence.md`.
-/

/-- `N = 143 = 11·13`, `k = p - 1 = 10`: the gcd reveals `13`. -/
example : revealGcd 143 10 = 13 := by
  have h := powerSum_reveal (p := 11) (q := 13) (by norm_num) (by norm_num) (by norm_num)
    (by decide)
  simpa [revealGcd] using h

/-- `N = 161 = 7·23`, `k = 6`: the gcd reveals `23`. -/
example : revealGcd 161 6 = 23 := by
  have h := powerSum_reveal (p := 7) (q := 23) (by norm_num) (by norm_num) (by norm_num)
    (by decide)
  simpa [revealGcd] using h

/-- `N = 10057 = 89·113`, `k = 88`: the gcd reveals `113`. -/
example : revealGcd 10057 88 = 113 := by
  have h := powerSum_reveal (p := 89) (q := 113) (by norm_num) (by norm_num) (by norm_num)
    (by decide)
  simpa [revealGcd] using h

/-- `N = 15 = 3·5`: the reveal function has minimal period `λ = 4`. -/
example : (∀ k, k ≠ 0 → revealGcd 15 (k + 4) = revealGcd 15 k) ∧
    ¬ (∀ k, k ≠ 0 → revealGcd 15 (k + 2) = revealGcd 15 k) := by
  have hiff := fun d => period_iff_lcm_dvd (p := 3) (q := 5) (d := d)
    (by norm_num) (by norm_num) (by norm_num)
  refine ⟨?_, ?_⟩
  · have := (hiff 4).mpr (by decide)
    simpa using this
  · intro h
    have := (hiff 2).mp (by simpa using h)
    revert this
    decide

/-- `N = 143`: the first exponent yielding a proper factor is `k = 10 = min (p-1, q-1)`. -/
example : IsLeast {k : ℕ | k ≠ 0 ∧ 1 < revealGcd 143 k ∧ revealGcd 143 k < 143} 10 := by
  have h := first_reveal (p := 11) (q := 13) (by norm_num) (by norm_num) (by norm_num)
  simpa using h

end PowerSumReveal