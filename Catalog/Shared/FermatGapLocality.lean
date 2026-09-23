import Mathlib

/-!
# Fermat's factorisation method is *gap-local*

This file completes the "locality taxonomy" of classical factoring methods by
giving a fully formal account of the cost of **Fermat's method** on a semiprime
`N = p * q`.

Recall the method: starting from `a = ⌊√N⌋ + 1`, one increments `a` until
`a² - N` is a perfect square; then `N = (a-b)(a+b)` splits.  Empirically the
number of iterations is *exactly* `(p+q)/2 - ⌊√N⌋ - 1`, i.e. a function of the
arithmetic-mean/geometric-mean **gap** of the two factors alone.  The results
below prove this, and use it to separate the locality classes.

| method          | class         | cost                  |
|-----------------|---------------|-----------------------|
| trial division  | `p`-linear    | `p` (`minFac_semiprime`) |
| Fermat          | **gap-local** | `(p+q)/2 - ⌊√N⌋ - 1` (`fermatSteps_eq`) |

## Main results

* `fermatSteps_add_start` / `fermatSteps_eq` : the exact iteration count for odd
  primes `p < q`: `⌊√(pq)⌋ + 1 + fermatSteps (p*q) = (p+q)/2` — the *gap-local
  identity*.
* `fermatSteps_eq_zero_of_small_gap` : if the gap `g = q - p` satisfies
  `(g-2)² ≤ 8p`, Fermat terminates in **zero** iterations, however large `p` is.
  Together with `minFac_semiprime` (trial division costs exactly `p`) this
  separates the *gap-local* class from the *p-linear* class;
  `separation_twin_10007` is an explicit instance.
* `fermatSteps_prime_sq` : on `N = p²` the true target `a = p` lies *below* the
  starting point (`target_below_start_sq`), and the method only exits at the
  unrelated square `a = (p²+1)/2`; the cost is quadratic
  (`fermatSteps_prime_sq_lower`).
* `am_gm_gap_real` : the real-analytic shape of the cost,
  `(p+q)/2 - √(pq) = (√q - √p)²/2`, and `fermat_cost_le_gap_sq`, the
  `(q-p)²/(8p)` upper bound that makes "gap-local" quantitative.
-/

namespace FermatGapLocality

/-! ### The method -/

/-- Fermat's scan starts at `⌊√N⌋ + 1`, the least `a` with `a² > N`. -/
def fermatStart (N : ℕ) : ℕ := Nat.sqrt N + 1

/-- The set of iteration counts at which Fermat's scan on `N` succeeds:
`k ∈ fermatHits N` iff `(start + k)² - N` is a perfect square. -/
def fermatHits (N : ℕ) : Set ℕ :=
  {k | ∃ b, (fermatStart N + k) * (fermatStart N + k) = N + b * b}

/-- The number of iterations Fermat's method performs on `N`
(`0` if the scan never succeeds). -/
noncomputable def fermatSteps (N : ℕ) : ℕ := sInf (fermatHits N)

/-! ### Divisor analysis of a Fermat hit -/

/-- A difference-of-squares representation of `N` yields an ordered
factorisation of `N` whose factor sum is `2a`. -/
lemma hit_factorization {N a : ℕ} (h : ∃ b, a * a = N + b * b) :
    ∃ d e : ℕ, d * e = N ∧ d ≤ e ∧ d + e = 2 * a := by
  obtain ⟨b, hb⟩ := h
  have hba : b ≤ a := by
    have : b * b ≤ a * a := by omega
    exact Nat.mul_self_le_mul_self_iff.mp this
  refine ⟨a - b, a + b, ?_, by omega, by omega⟩
  have hb' : b + (a - b) = a := by omega
  have : (a - b) * (a + b) + b * b = a * a := by nlinarith [hb']
  omega

/-- Ordered factorisations of a product of two primes: only the trivial one and
the prime one. -/
lemma prime_mul_factor_cases {p q d e : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q)
    (h : d * e = p * q) (hde : d ≤ e) :
    (d = 1 ∧ e = p * q) ∨ (d = p ∧ e = q) := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hp0 : 0 < p := by omega
  have hq0 : 0 < q := by omega
  have hpde : p ∣ d * e := ⟨q, h⟩
  rcases (Nat.Prime.dvd_mul hp).mp hpde with hd | he
  · -- `p ∣ d`, say `d = p * m`, and then `m * e = q`
    obtain ⟨m, hm⟩ := hd
    have hme : m * e = q := by
      have h2 : p * (m * e) = p * q := by rw [← h, hm]; ring
      exact Nat.eq_of_mul_eq_mul_left hp0 h2
    rcases hq.eq_one_or_self_of_dvd m ⟨e, hme.symm⟩ with hm1 | hmq
    · right
      refine ⟨by rw [hm, hm1, mul_one], ?_⟩
      rw [hm1, one_mul] at hme
      exact hme
    · -- `m = q` forces `e = 1`, contradicting `d ≤ e`
      exfalso
      have he1 : e = 1 := by
        rw [hmq] at hme
        have h3 : q * e = q * 1 := by rw [mul_one]; exact hme
        exact Nat.eq_of_mul_eq_mul_left hq0 h3
      have hdq : d = p * q := by rw [hm, hmq]
      have : p * q ≤ 1 := by omega
      nlinarith
  · -- `p ∣ e`, say `e = p * m`, and then `d * m = q`
    obtain ⟨m, hm⟩ := he
    have hdm : d * m = q := by
      have h2 : p * (d * m) = p * q := by rw [← h, hm]; ring
      exact Nat.eq_of_mul_eq_mul_left hp0 h2
    rcases hq.eq_one_or_self_of_dvd d ⟨m, hdm.symm⟩ with hd1 | hdq
    · left
      refine ⟨hd1, ?_⟩
      have hmq : m = q := by rw [hd1, one_mul] at hdm; exact hdm
      rw [hm, hmq]
    · -- `d = q ≤ e = p * m` together with `d * m = q` forces `p = q`
      have hm1 : m = 1 := by
        rw [hdq] at hdm
        have h3 : q * m = q * 1 := by rw [mul_one]; exact hdm
        exact Nat.eq_of_mul_eq_mul_left hq0 h3
      have hep : e = p := by rw [hm, hm1, mul_one]
      have hpq' : p = q := by omega
      right
      constructor <;> omega

/-- The only `a` at which Fermat's scan on a semiprime `p*q` can succeed are
`a = (1 + pq)/2` (the trivial factorisation) and `a = (p+q)/2` (the real one). -/
lemma hit_two_mul_cases {p q a : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q)
    (h : ∃ b, a * a = p * q + b * b) :
    2 * a = 1 + p * q ∨ 2 * a = p + q := by
  obtain ⟨d, e, hde, hle, hsum⟩ := hit_factorization h
  rcases prime_mul_factor_cases hp hq hpq hde hle with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · left; omega
  · right; omega

/-! ### The gap-local identity -/

section Semiprime

variable {p q : ℕ}

/-- The Fermat target `s = (p+q)/2` really is a hit, with witness `t = (q-p)/2`. -/
lemma target_is_hit (hpq : p < q) {s t : ℕ}
    (hs : p + q = 2 * s) (ht : q - p = 2 * t) :
    s * s = p * q + t * t := by
  have hqp : p + 2 * t = q := by omega
  nlinarith [hs, hqp]

/-- The target lies strictly above `⌊√(pq)⌋`, i.e. at or after the start. -/
lemma start_le_target (hpq : p < q) {s t : ℕ} (hs : p + q = 2 * s) (ht : q - p = 2 * t)
    (hsq : s * s = p * q + t * t) : fermatStart (p * q) ≤ s := by
  have ht0 : 0 < t := by omega
  have hlt : p * q < s * s := by nlinarith
  have hsqrt : Nat.sqrt (p * q) < s := by
    by_contra hcon
    push_neg at hcon
    have h1 : s * s ≤ Nat.sqrt (p * q) * Nat.sqrt (p * q) := Nat.mul_le_mul hcon hcon
    have h2 : Nat.sqrt (p * q) * Nat.sqrt (p * q) ≤ p * q := Nat.sqrt_le (p * q)
    omega
  simpa [fermatStart] using hsqrt

/-- **Gap-local identity.**  For odd primes `p < q`, Fermat's method on `N = p*q`
performs exactly `(p+q)/2 - ⌊√N⌋ - 1` iterations: the cost is a function of the
AM–GM gap of the factor pair, not of the size of the factors. -/
theorem fermatSteps_add_start (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2) (hpq : p < q) :
    fermatStart (p * q) + fermatSteps (p * q) = (p + q) / 2 := by
  have hp2le := hp.two_le
  have hpodd : Odd p := hp.odd_of_ne_two hp2
  have hqodd : Odd q := hq.odd_of_ne_two (by rintro rfl; omega)
  obtain ⟨s, hs⟩ : ∃ s, p + q = 2 * s := by
    obtain ⟨k, hk⟩ := hpodd; obtain ⟨l, hl⟩ := hqodd; exact ⟨k + l + 1, by omega⟩
  obtain ⟨t, ht⟩ : ∃ t, q - p = 2 * t := by
    obtain ⟨k, hk⟩ := hpodd; obtain ⟨l, hl⟩ := hqodd; exact ⟨l - k, by omega⟩
  have hsq : s * s = p * q + t * t := target_is_hit hpq hs ht
  have hstart : fermatStart (p * q) ≤ s := start_le_target hpq hs ht hsq
  have hmem : (s - fermatStart (p * q)) ∈ fermatHits (p * q) := by
    refine ⟨t, ?_⟩
    have hrw : fermatStart (p * q) + (s - fermatStart (p * q)) = s := by omega
    rw [hrw]; exact hsq
  have hne : (fermatHits (p * q)).Nonempty := ⟨_, hmem⟩
  have hlb : ∀ k ∈ fermatHits (p * q), s - fermatStart (p * q) ≤ k := by
    rintro k ⟨b, hb⟩
    have hcases : 2 * (fermatStart (p * q) + k) = 1 + p * q ∨
        2 * (fermatStart (p * q) + k) = p + q :=
      hit_two_mul_cases hp hq (le_of_lt hpq) ⟨b, hb⟩
    have hbig : p + q ≤ 1 + p * q := by nlinarith [hp.two_le, hq.two_le]
    have hge : s ≤ fermatStart (p * q) + k := by rcases hcases with h | h <;> omega
    omega
  have hle : fermatSteps (p * q) ≤ s - fermatStart (p * q) := Nat.sInf_le hmem
  have hge : s - fermatStart (p * q) ≤ fermatSteps (p * q) := hlb _ (Nat.sInf_mem hne)
  have hEq : fermatSteps (p * q) = s - fermatStart (p * q) := le_antisymm hle hge
  omega

/-- The same identity in subtraction form: `steps = (p+q)/2 - (⌊√N⌋+1)`. -/
theorem fermatSteps_eq (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2) (hpq : p < q) :
    fermatSteps (p * q) = (p + q) / 2 - (Nat.sqrt (p * q) + 1) := by
  have h := fermatSteps_add_start hp hq hp2 hpq
  simp only [fermatStart] at h ⊢
  omega

end Semiprime

/-! ### Gap-locality versus the p-linear class -/

/-- Trial division on a semiprime costs exactly `p`: its smallest prime factor. -/
theorem minFac_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q) :
    Nat.minFac (p * q) = p := by
  have hle : Nat.minFac (p * q) ≤ p :=
    Nat.minFac_le_of_dvd hp.two_le ⟨q, rfl⟩
  have hprime : (Nat.minFac (p * q)).Prime := by
    refine Nat.minFac_prime ?_
    have h1 := hp.two_le; have h2 := hq.two_le
    nlinarith
  have hdvd : Nat.minFac (p * q) ∣ p * q := Nat.minFac_dvd _
  rcases (Nat.Prime.dvd_mul hprime).mp hdvd with h | h
  · exact (Nat.prime_dvd_prime_iff_eq hprime hp).mp h
  · have := (Nat.prime_dvd_prime_iff_eq hprime hq).mp h
    omega

/-- **Gap-locality, quantitatively.**  If the factor gap `g = q - p` satisfies
`(g-2)² ≤ 8p`, then Fermat's method terminates with *zero* iterations, no
matter how large `p` is — while trial division still needs `p` steps
(`minFac_semiprime`).  This is the formal separation of the *gap-local* class
from the *p-linear* class. -/
theorem fermatSteps_eq_zero_of_small_gap {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp2 : p ≠ 2) (hpq : p < q) (hgap : (q - p - 2) * (q - p - 2) ≤ 8 * p) :
    fermatSteps (p * q) = 0 := by
  have hp2le := hp.two_le
  have hpodd : Odd p := hp.odd_of_ne_two hp2
  have hqodd : Odd q := hq.odd_of_ne_two (by rintro rfl; omega)
  obtain ⟨s, hs⟩ : ∃ s, p + q = 2 * s := by
    obtain ⟨k, hk⟩ := hpodd; obtain ⟨l, hl⟩ := hqodd; exact ⟨k + l + 1, by omega⟩
  obtain ⟨t, ht⟩ : ∃ t, q - p = 2 * t := by
    obtain ⟨k, hk⟩ := hpodd; obtain ⟨l, hl⟩ := hqodd; exact ⟨l - k, by omega⟩
  have ht0 : 0 < t := by omega
  have key := fermatSteps_add_start hp hq hp2 hpq
  -- `(s-1)² ≤ N` is exactly the small-gap hypothesis, so `⌊√N⌋ ≥ s - 1`.
  have hsub : (s - 1) * (s - 1) ≤ p * q := by
    have hq' : q = p + 2 * t := by omega
    have hs' : s = p + t := by omega
    subst hq'
    subst hs'
    obtain ⟨u, rfl⟩ : ∃ u, t = u + 1 := ⟨t - 1, by omega⟩
    have hgap' : (2 * u) * (2 * u) ≤ 8 * p := by
      have hrw : p + 2 * (u + 1) - p - 2 = 2 * u := by omega
      rw [hrw] at hgap; exact hgap
    have h2 : u * u ≤ 2 * p := by nlinarith [hgap']
    have hexp : (p + (u + 1) - 1) * (p + (u + 1) - 1) = p * p + 2 * (p * u) + u * u := by
      have hrw : p + (u + 1) - 1 = p + u := by omega
      rw [hrw]; ring
    have hrhs : p * (p + 2 * (u + 1)) = p * p + 2 * (p * u) + 2 * p := by ring
    omega
  have hsqrt : s - 1 ≤ Nat.sqrt (p * q) := Nat.le_sqrt.mpr hsub
  simp only [fermatStart] at key
  omega

/-- Concrete instance of the separation at the twin prime pair `(10007, 10009)`:
Fermat finishes immediately, while trial division needs `10007` steps. -/
theorem separation_twin_10007 :
    fermatSteps (10007 * 10009) = 0 ∧ Nat.minFac (10007 * 10009) = 10007 := by
  have hp : Nat.Prime 10007 := by norm_num
  have hq : Nat.Prime 10009 := by norm_num
  exact ⟨fermatSteps_eq_zero_of_small_gap hp hq (by norm_num) (by norm_num) (by norm_num),
    minFac_semiprime hp hq (by norm_num)⟩

/-! ### The degenerate square case -/

/-- On `N = n²` the difference-of-squares target `a = n` lies strictly **below**
the starting point `⌊√N⌋ + 1 = n + 1`: plain Fermat has no true stopping point
on a square. -/
theorem target_below_start_sq (n : ℕ) : n < fermatStart (n * n) := by
  simp [fermatStart]

/-- **Degenerate square case.**  On `N = p²` with `p` an odd prime the scan exits
only at the *unrelated* square `a = (p²+1)/2`, so the cost is
`(p²+1)/2 - (p+1)`, in violent contrast with the gap-local value `0` that the
formula `(p+q)/2 - √N` would predict at `q = p`. -/
theorem fermatSteps_prime_sq {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) :
    fermatStart (p * p) + fermatSteps (p * p) = (p * p + 1) / 2 := by
  have hp2le := hp.two_le
  obtain ⟨k, hk⟩ := hp.odd_of_ne_two hp2
  have hk1 : 1 ≤ k := by omega
  have hpp : p * p = 4 * (k * k) + 4 * k + 1 := by subst hk; ring
  have hstart : fermatStart (p * p) = p + 1 := by simp [fermatStart]
  obtain ⟨s, hs⟩ : ∃ s, p * p + 1 = 2 * s := ⟨2 * (k * k) + 2 * k + 1, by omega⟩
  obtain ⟨b, hb⟩ : ∃ b, p * p = 2 * b + 1 := ⟨2 * (k * k) + 2 * k, by omega⟩
  have hsb : s * s = p * p + b * b := by
    have h1 : s = b + 1 := by omega
    subst h1
    nlinarith [hb]
  have hss : p + 1 ≤ s := by nlinarith [hpp, hs, hk1]
  have hmem : (s - fermatStart (p * p)) ∈ fermatHits (p * p) := by
    refine ⟨b, ?_⟩
    have hrw : fermatStart (p * p) + (s - fermatStart (p * p)) = s := by omega
    rw [hrw]; exact hsb
  have hne : (fermatHits (p * p)).Nonempty := ⟨_, hmem⟩
  have hlb : ∀ n ∈ fermatHits (p * p), s - fermatStart (p * p) ≤ n := by
    rintro n ⟨c, hc⟩
    have hcases : 2 * (fermatStart (p * p) + n) = 1 + p * p ∨
        2 * (fermatStart (p * p) + n) = p + p :=
      hit_two_mul_cases hp hp le_rfl ⟨c, hc⟩
    have hge : s ≤ fermatStart (p * p) + n := by
      rcases hcases with h | h <;> omega
    omega
  have hle : fermatSteps (p * p) ≤ s - fermatStart (p * p) := Nat.sInf_le hmem
  have hge : s - fermatStart (p * p) ≤ fermatSteps (p * p) := hlb _ (Nat.sInf_mem hne)
  have hEq : fermatSteps (p * p) = s - fermatStart (p * p) := le_antisymm hle hge
  omega

/-- Explicit quadratic blow-up in the degenerate case: on `N = p²` the number of
iterations satisfies `2·steps + 2p + 3 ≥ p²`, so it grows without bound even
though the two factors are as balanced as possible. -/
theorem fermatSteps_prime_sq_lower {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) :
    p * p ≤ 2 * fermatSteps (p * p) + 2 * p + 3 := by
  have h := fermatSteps_prime_sq hp hp2
  have hstart : fermatStart (p * p) = p + 1 := by simp [fermatStart]
  rw [hstart] at h
  omega

/-! ### The real-analytic shape of the gap -/

/-- The Fermat cost is the AM–GM gap, and the AM–GM gap of `x, y` is exactly
`(√y - √x)²/2`. -/
theorem am_gm_gap_real {x y : ℝ} (hx : 0 ≤ x) (hy : 0 ≤ y) :
    (x + y) / 2 - Real.sqrt (x * y) = (Real.sqrt y - Real.sqrt x) ^ 2 / 2 := by
  have hsx : Real.sqrt x ^ 2 = x := Real.sq_sqrt hx
  have hsy : Real.sqrt y ^ 2 = y := Real.sq_sqrt hy
  have hxy : Real.sqrt (x * y) = Real.sqrt x * Real.sqrt y := Real.sqrt_mul hx y
  rw [hxy]
  nlinarith [hsx, hsy]

/-- **Quantitative gap-locality.**  The AM–GM gap is bounded by `(y-x)²/(8x)`:
for a fixed gap the cost *decreases* as the factors grow, the exact opposite of
the `p`-linear and `√p` classes. -/
theorem fermat_cost_le_gap_sq {x y : ℝ} (hx : 0 < x) (hxy : x ≤ y) :
    (x + y) / 2 - Real.sqrt (x * y) ≤ (y - x) ^ 2 / (8 * x) := by
  have hy : (0:ℝ) < y := lt_of_lt_of_le hx hxy
  have hsx : Real.sqrt x ^ 2 = x := Real.sq_sqrt hx.le
  have hsy : Real.sqrt y ^ 2 = y := Real.sq_sqrt hy.le
  have hsx0 : 0 < Real.sqrt x := Real.sqrt_pos.mpr hx
  have hsy0 : 0 < Real.sqrt y := Real.sqrt_pos.mpr hy
  have hxy' : Real.sqrt (x * y) = Real.sqrt x * Real.sqrt y := Real.sqrt_mul hx.le y
  have hmono : Real.sqrt x ≤ Real.sqrt y := Real.sqrt_le_sqrt hxy
  rw [hxy', le_div_iff₀ (by positivity : (0:ℝ) < 8 * x)]
  nlinarith [hsx, hsy, hsx0, hsy0, hmono, sq_nonneg (Real.sqrt y - Real.sqrt x),
    mul_nonneg (sq_nonneg (Real.sqrt y - Real.sqrt x)) hsx0.le]

end FermatGapLocality