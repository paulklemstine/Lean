import Mathlib

/-!
# GCD moments of a semiprime: a closed trace-witness family

For a positive integer `n` and an exponent `k` put

`M_k(n) = ∑_{x < n} gcd(n, x) ^ k`

(the sum over a full residue system; the term `x = 0` contributes `n ^ k`, which is the same
as the term `x = n` in the more usual range `1 ≤ x ≤ n`).

This file develops the arithmetic of these *gcd moments* for a **semiprime** `N = p * q`
(`p`, `q` distinct primes), the setting of the factoring-barrier catalog.  Writing
`s = p + q` for the *trace*, the results are as follows.

## Main results

* `gcdMoment_eq_sum_divisors` — the classical gcd-sum / Jordan-totient identity
  `M_k(n) = ∑_{d ∣ n} d^k φ(n/d)`, valid for every `n > 0`.
* `newtonP_eq` — the Newton recursion `P_{j+2} = s P_{j+1} − N P_j` computes the power sums
  `P_j = p^j + q^j` from the pair `(N, s)` alone.
* `gcdMoment_semiprime_four_terms` and `gcdMoment_eq_momentPoly` — **the closed form**: for
  `k ≥ 1`, `M_k(N) = N^k + N·P_{k−1} − P_k + N − s + 1 = F_k(N, s)`, an explicit integer
  polynomial in the *public* modulus `N` and the trace `s`.  This is the symmetry barrier:
  the individual factors never appear, only their elementary symmetric functions.
* `gcdMoment_one`, `gcdMoment_two`, `gcdMoment_three`, `gcdMoment_four` — the explicit
  low-order polynomials, e.g. `M_1 = 4N − 2s + 1` and `M_2 = N² + 3N + 1 + (N−1)s − s²`.
* `trace_of_gcdMoment_one` — the first moment recovers the trace exactly: `2 s = 4N + 1 − M_1`.
* `higher_moments_from_first` — **closure of the family**: every higher moment is an explicit
  function of `N` and `M_1`.  No moment carries information beyond the trace.
* `sum_prod_determines_pair`, `discriminant_eq` and `factorization_of_gcdMoment_one` — the
  trace *does* split `N`: the pair `(p,q)` is the unique ordered pair of naturals with the
  observed product and trace, and the discriminant `s² − 4N = (q−p)²` is a perfect square.
  So `M_1` is a complete witness — but computing it costs `Θ(N)` gcds.
* `momentPoly_two_symm`, `momentPoly_two_root_dichotomy`, `trace_unique_of_small` — the
  `k = 2` moment polynomial has exactly the two roots `s` and `N − 1 − s`, and the size cut
  `2s < N − 1` picks out the true trace.  (The second root is not a phantom: the companion file
  `Novelty.GCDMomentPairInversion` exhibits moduli where it is realised by a genuine second
  factorisation, and shows there are exactly two such moduli.)
* `gcdMoment_ge`, `gcdMoment_le`, `gcdVariance_lower_bound`, `gcdVariance_upper_bound`,
  `gcdVariance_theta`, `gcdVariance_one_le`, `gcdVariance_separation` — the *cost* hierarchy.  The variance of `gcd(N,U)^k` for uniform
  `U` is at least `N^{2k−1} − 16 N^{2k−2}`, while for `k = 1` it is at most `4N`; hence
  Chebyshev sampling at level `k` needs `Ω(N^{2k−1})` samples and `k = 1` is optimal.
* `card_nontrivial_gcd` — the witness-density law `#{x < N : gcd(N,x) ≠ 1} = p + q − 1`:
  a uniform probe hits a nontrivial gcd with probability exactly `(p+q−1)/N`, the `Θ(p+q)`
  query threshold.

Nothing here breaks the factoring barrier: every statement is either an identity in `(N, s)`
or an `Ω(N)`-cost computation.
-/

namespace GCDMoment

open Finset Nat

/-! ### Definition and the divisor form -/

/-- `gcdMoment k n = ∑_{x < n} gcd(n,x)^k`, the `k`-th gcd moment of `n`. -/
def gcdMoment (k n : ℕ) : ℕ := ∑ x ∈ Finset.range n, (n.gcd x) ^ k

@[simp] lemma gcdMoment_zero_right (k : ℕ) : gcdMoment k 0 = 0 := by simp [gcdMoment]

/-- Sanity checks against the closed forms below (`N = 6`, `s = 5`; `N = 15`, `s = 8`). -/
example : gcdMoment 1 6 = 15 := by decide
example : gcdMoment 2 6 = 55 := by decide
example : gcdMoment 1 15 = 4 * 15 - 2 * 8 + 1 := by decide

/-- The classical gcd-sum / Jordan-totient identity `∑_{x<n} gcd(n,x)^k = ∑_{d ∣ n} d^k φ(n/d)`. -/
theorem gcdMoment_eq_sum_divisors (k n : ℕ) (hn : 0 < n) :
    gcdMoment k n = ∑ d ∈ n.divisors, d ^ k * φ (n / d) := by
  unfold gcdMoment
  rw [← Finset.sum_fiberwise_of_maps_to (g := fun x => n.gcd x) (t := n.divisors)
      (fun x _ => Nat.mem_divisors.2 ⟨Nat.gcd_dvd_left _ _, hn.ne'⟩)]
  refine Finset.sum_congr rfl fun d hd => ?_
  rw [Nat.totient_div_of_dvd (Nat.dvd_of_mem_divisors hd)]
  rw [Finset.sum_congr rfl (fun x hx => by rw [(Finset.mem_filter.1 hx).2])]
  simp [mul_comm]

/-- The divisors of a semiprime are `1, p, q, pq`. -/
theorem divisors_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) :
    (p * q).divisors = {1, p, q, p * q} := by
  ext d
  simp only [Nat.mem_divisors, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨hd, -⟩
    by_cases hpd : p ∣ d
    · obtain ⟨e, rfl⟩ := hpd
      rcases (Nat.dvd_prime hq).1 ((mul_dvd_mul_iff_left hp.pos.ne').1 hd) with rfl | rfl
      · simp
      · simp
    · have hcop : Nat.Coprime d p := Nat.coprime_comm.1 ((Nat.Prime.coprime_iff_not_dvd hp).2 hpd)
      rcases (Nat.dvd_prime hq).1 (hcop.dvd_of_dvd_mul_left hd) with rfl | rfl
      · simp
      · simp
  · rintro (rfl | rfl | rfl | rfl) <;>
      simp [Dvd.intro, hp.ne_zero, Nat.mul_ne_zero hp.ne_zero hq.ne_zero]

/-- The four-term expansion of the gcd moment of a semiprime, over `ℤ`. -/
theorem gcdMoment_semiprime_four_terms {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (k : ℕ) :
    (gcdMoment k (p * q) : ℤ) =
      ((p : ℤ) - 1) * ((q : ℤ) - 1) + (p : ℤ) ^ k * ((q : ℤ) - 1)
        + (q : ℤ) ^ k * ((p : ℤ) - 1) + ((p : ℤ) * (q : ℤ)) ^ k := by
  have hN : 0 < p * q := Nat.mul_pos hp.pos hq.pos
  rw [gcdMoment_eq_sum_divisors k _ hN]
  have h1p : (1 : ℕ) ≠ p := hp.one_lt.ne
  have h1q : (1 : ℕ) ≠ q := hq.one_lt.ne
  have h1pq : (1 : ℕ) ≠ p * q := by nlinarith [hp.one_lt, hq.one_lt]
  have hppq : p ≠ p * q := by nlinarith [hp.one_lt, hq.one_lt]
  have hqpq : q ≠ p * q := by nlinarith [hp.one_lt, hq.one_lt]
  rw [divisors_semiprime hp hq, Finset.sum_insert (by simp [h1p, h1q, h1pq]),
    Finset.sum_insert (by simp [hpq, hppq]), Finset.sum_insert (by simp [hqpq]),
    Finset.sum_singleton]
  have e2 : (p * q) / p = q := Nat.mul_div_cancel_left q hp.pos
  have e3 : (p * q) / q = p := by rw [mul_comm]; exact Nat.mul_div_cancel_left p hq.pos
  have e4 : (p * q) / (p * q) = 1 := Nat.div_self hN
  rw [Nat.div_one, e2, e3, e4, Nat.totient_mul ((Nat.coprime_primes hp hq).2 hpq),
    Nat.totient_prime hp, Nat.totient_prime hq, Nat.totient_one]
  push_cast [Nat.cast_sub hp.one_lt.le, Nat.cast_sub hq.one_lt.le]
  ring

/-! ### Newton power sums and the moment polynomial -/

/-- The Newton power sums `P_j` as a polynomial recursion in the public data `(N, s)`:
`P_0 = 2`, `P_1 = s`, `P_{j+2} = s P_{j+1} − N P_j`. -/
def newtonP (N s : ℤ) : ℕ → ℤ
  | 0 => 2
  | 1 => s
  | (j + 2) => s * newtonP N s (j + 1) - N * newtonP N s j

@[simp] lemma newtonP_zero (N s : ℤ) : newtonP N s 0 = 2 := rfl
@[simp] lemma newtonP_one (N s : ℤ) : newtonP N s 1 = s := rfl
lemma newtonP_succ_succ (N s : ℤ) (j : ℕ) :
    newtonP N s (j + 2) = s * newtonP N s (j + 1) - N * newtonP N s j := rfl

/-- The recursion really computes the power sums `p^j + q^j` from `(pq, p+q)` alone. -/
theorem newtonP_eq (p q : ℤ) (j : ℕ) : newtonP (p * q) (p + q) j = p ^ j + q ^ j := by
  induction j using Nat.twoStepInduction with
  | zero => simp
  | one => simp
  | more j ih1 ih2 => rw [newtonP_succ_succ, ih1, ih2]; ring

/-- `momentPoly N s k = F_{k+1}(N,s)`, the closed form of the `(k+1)`-st gcd moment. -/
def momentPoly (N s : ℤ) (k : ℕ) : ℤ :=
  N ^ (k + 1) + N * newtonP N s k - newtonP N s (k + 1) + N - s + 1

/-- **Closed form / symmetry barrier.**  Every gcd moment of a semiprime is the value of an
explicit integer polynomial in the modulus `N = pq` and the trace `s = p + q`; the factors
themselves never appear. -/
theorem gcdMoment_eq_momentPoly {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (k : ℕ) :
    (gcdMoment (k + 1) (p * q) : ℤ) = momentPoly ((p : ℤ) * q) ((p : ℤ) + q) k := by
  rw [gcdMoment_semiprime_four_terms hp hq hpq, momentPoly, newtonP_eq, newtonP_eq]
  ring

/-- Barrier 2 in its bare form: the moments are invariant under any change of the hidden pair
that preserves the product and the trace. -/
theorem gcdMoment_eq_of_same_trace {p q p' q' : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hp' : p'.Prime) (hq' : q'.Prime) (hpq' : p' ≠ q')
    (hprod : (p : ℤ) * q = (p' : ℤ) * q') (htr : (p : ℤ) + q = (p' : ℤ) + q') (k : ℕ) :
    (gcdMoment (k + 1) (p * q) : ℤ) = (gcdMoment (k + 1) (p' * q') : ℤ) := by
  rw [gcdMoment_eq_momentPoly hp hq hpq, gcdMoment_eq_momentPoly hp' hq' hpq', hprod, htr]

/-! ### The explicit low moments -/

theorem momentPoly_zero (N s : ℤ) : momentPoly N s 0 = 4 * N - 2 * s + 1 := by
  simp [momentPoly]; ring

theorem momentPoly_one (N s : ℤ) : momentPoly N s 1 = N ^ 2 + 3 * N + 1 + (N - 1) * s - s ^ 2 := by
  simp [momentPoly, newtonP_succ_succ]; ring

theorem momentPoly_two (N s : ℤ) :
    momentPoly N s 2 = N ^ 3 - 2 * N ^ 2 + N * s ^ 2 + 3 * N * s + N - s ^ 3 - s + 1 := by
  simp [momentPoly, newtonP_succ_succ]; ring

theorem momentPoly_three (N s : ℤ) :
    momentPoly N s 3 =
      N ^ 4 - 3 * N ^ 2 * s - 2 * N ^ 2 + N * s ^ 3 + 4 * N * s ^ 2 + N - s ^ 4 - s + 1 := by
  simp [momentPoly, newtonP_succ_succ]; ring

variable {p q : ℕ}

theorem gcdMoment_one (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    (gcdMoment 1 (p * q) : ℤ) = 4 * ((p : ℤ) * q) - 2 * ((p : ℤ) + q) + 1 := by
  rw [show (1 : ℕ) = 0 + 1 from rfl, gcdMoment_eq_momentPoly hp hq hpq, momentPoly_zero]

theorem gcdMoment_two (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    (gcdMoment 2 (p * q) : ℤ) =
      ((p : ℤ) * q) ^ 2 + 3 * ((p : ℤ) * q) + 1 + ((p : ℤ) * q - 1) * ((p : ℤ) + q)
        - ((p : ℤ) + q) ^ 2 := by
  rw [show (2 : ℕ) = 1 + 1 from rfl, gcdMoment_eq_momentPoly hp hq hpq, momentPoly_one]

theorem gcdMoment_three (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    (gcdMoment 3 (p * q) : ℤ) =
      ((p : ℤ) * q) ^ 3 - 2 * ((p : ℤ) * q) ^ 2 + ((p : ℤ) * q) * ((p : ℤ) + q) ^ 2
        + 3 * ((p : ℤ) * q) * ((p : ℤ) + q) + ((p : ℤ) * q) - ((p : ℤ) + q) ^ 3
        - ((p : ℤ) + q) + 1 := by
  rw [show (3 : ℕ) = 2 + 1 from rfl, gcdMoment_eq_momentPoly hp hq hpq, momentPoly_two]

theorem gcdMoment_four (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    (gcdMoment 4 (p * q) : ℤ) =
      ((p : ℤ) * q) ^ 4 - 3 * ((p : ℤ) * q) ^ 2 * ((p : ℤ) + q) - 2 * ((p : ℤ) * q) ^ 2
        + ((p : ℤ) * q) * ((p : ℤ) + q) ^ 3 + 4 * ((p : ℤ) * q) * ((p : ℤ) + q) ^ 2
        + ((p : ℤ) * q) - ((p : ℤ) + q) ^ 4 - ((p : ℤ) + q) + 1 := by
  rw [show (4 : ℕ) = 3 + 1 from rfl, gcdMoment_eq_momentPoly hp hq hpq, momentPoly_three]

/-! ### Trace recovery and closure of the family -/

/-- **Trace recovery.**  The first gcd moment determines the trace `s = p + q` exactly. -/
theorem trace_of_gcdMoment_one (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    2 * ((p : ℤ) + q) = 4 * ((p : ℤ) * q) + 1 - gcdMoment 1 (p * q) := by
  rw [gcdMoment_one hp hq hpq]; ring

/-- **Closure of the moment family (barriers 6 and 8).**  Every higher gcd moment is an explicit
polynomial function of the modulus and of the *first* moment: the family carries exactly one
bit of hidden information, the trace, and higher `k` adds nothing. -/
theorem higher_moments_from_first (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (k : ℕ) {s : ℤ}
    (hs : 2 * s = 4 * ((p : ℤ) * q) + 1 - gcdMoment 1 (p * q)) :
    (gcdMoment (k + 1) (p * q) : ℤ) = momentPoly ((p : ℤ) * q) s k := by
  have : s = (p : ℤ) + q := by
    have := trace_of_gcdMoment_one hp hq hpq
    omega
  rw [this, gcdMoment_eq_momentPoly hp hq hpq]

/-! ### The `k = 2` root structure -/

/-- The second moment polynomial is symmetric about `s ↦ N − 1 − s`. -/
theorem momentPoly_two_symm (N s : ℤ) : momentPoly N (N - 1 - s) 1 = momentPoly N s 1 := by
  rw [momentPoly_one, momentPoly_one]; ring

/-- The second moment pins the trace down to exactly two candidates. -/
theorem momentPoly_two_root_dichotomy {N s t : ℤ} (h : momentPoly N t 1 = momentPoly N s 1) :
    t = s ∨ t = N - 1 - s := by
  rw [momentPoly_one, momentPoly_one] at h
  have h' : (t - s) * (N - 1 - t - s) = 0 := by linarith [h, sq_nonneg (t - s)]
  rcases mul_eq_zero.1 h' with h1 | h1
  · left; linarith
  · right; linarith

/-- **The size cut disambiguates.**  Among candidate traces below `(N−1)/2` the second moment
determines the trace uniquely. -/
theorem trace_unique_of_small {N s t : ℤ} (hs : 2 * s < N - 1) (ht : 2 * t < N - 1)
    (h : momentPoly N t 1 = momentPoly N s 1) : t = s := by
  rcases momentPoly_two_root_dichotomy h with h1 | h1
  · exact h1
  · exfalso; omega

/-! ### The trace splits `N` -/

/-- A pair of naturals is determined by its sum and product (up to order). -/
theorem sum_prod_determines_pair {a b c d : ℕ} (hprod : a * b = c * d) (hsum : a + b = c + d)
    (hab : a ≤ b) (hcd : c ≤ d) : a = c ∧ b = d := by
  have hprodZ : (a : ℤ) * b = (c : ℤ) * d := by exact_mod_cast hprod
  have hsumZ : (a : ℤ) + b = (c : ℤ) + d := by exact_mod_cast hsum
  have key : ((a : ℤ) - c) * ((a : ℤ) - d) = 0 := by nlinarith [hprodZ, hsumZ]
  rcases mul_eq_zero.1 key with h | h
  · have hac : a = c := by exact_mod_cast sub_eq_zero.1 h
    exact ⟨hac, by omega⟩
  · have had : a = d := by exact_mod_cast sub_eq_zero.1 h
    have : c = d := by omega
    exact ⟨by omega, by omega⟩

/-- The discriminant of the trace quadratic is the square of the gap between the factors. -/
theorem discriminant_eq (p q : ℕ) :
    ((p : ℤ) + q) ^ 2 - 4 * ((p : ℤ) * q) = ((q : ℤ) - p) ^ 2 := by ring

/-- **The gcd-sum witness is complete.**  Any ordered pair `(a,b)` of naturals whose product is
`N` and whose sum is the trace read off from the first gcd moment *is* the factorisation.
Thus an `O(N)` gcd scan factors `N` — the witness is genuine, but its cost is `Θ(N)`. -/
theorem factorization_of_gcdMoment_one (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (hle : p ≤ q)
    {a b : ℕ} (hab : a ≤ b) (hprod : a * b = p * q)
    (hsum : 2 * ((a : ℤ) + b) = 4 * ((p : ℤ) * q) + 1 - gcdMoment 1 (p * q)) :
    a = p ∧ b = q := by
  have htr := trace_of_gcdMoment_one hp hq hpq
  have hsum' : a + b = p + q := by
    have : ((a : ℤ) + b) = (p : ℤ) + q := by omega
    exact_mod_cast this
  exact sum_prod_determines_pair hprod hsum' hab hle

/-! ### The cost hierarchy: variance of the `k`-th gcd power -/

/-- Every gcd moment is at least `N^k`: the single probe `x ≡ 0` already contributes `N^k`. -/
theorem gcdMoment_ge (k n : ℕ) (hn : 0 < n) : n ^ k ≤ gcdMoment k n := by
  have h0 : (0 : ℕ) ∈ Finset.range n := Finset.mem_range.2 hn
  have := Finset.single_le_sum (f := fun x => (n.gcd x) ^ k) (fun i _ => Nat.zero_le _) h0
  simpa using this

/-- Conversely every gcd moment of a semiprime is at most `4 N^k` (`k ≥ 1`). -/
theorem gcdMoment_le (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (j : ℕ) :
    (gcdMoment (j + 1) (p * q) : ℤ) ≤ 4 * ((p : ℤ) * q) ^ (j + 1) := by
  have hp2 : (2 : ℤ) ≤ p := by exact_mod_cast hp.two_le
  have hq2 : (2 : ℤ) ≤ q := by exact_mod_cast hq.two_le
  have hpN : (p : ℤ) ≤ (p : ℤ) * q := by nlinarith
  have hqN : (q : ℤ) ≤ (p : ℤ) * q := by nlinarith
  have hp0 : (0 : ℤ) ≤ p := by linarith
  have hq0 : (0 : ℤ) ≤ q := by linarith
  have hpj : (p : ℤ) ^ j ≤ ((p : ℤ) * q) ^ j := pow_le_pow_left₀ hp0 hpN j
  have hqj : (q : ℤ) ^ j ≤ ((p : ℤ) * q) ^ j := pow_le_pow_left₀ hq0 hqN j
  have hNj : (0 : ℤ) < ((p : ℤ) * q) ^ j := by positivity
  rw [gcdMoment_semiprime_four_terms hp hq hpq]
  have e1 : (p : ℤ) ^ (j + 1) * ((q : ℤ) - 1) ≤ ((p : ℤ) * q) ^ (j + 1) := by
    have : (p : ℤ) ^ (j + 1) * ((q : ℤ) - 1) ≤ (p : ℤ) ^ j * ((p : ℤ) * q) := by
      rw [pow_succ]; nlinarith [pow_nonneg hp0 j]
    calc (p : ℤ) ^ (j + 1) * ((q : ℤ) - 1) ≤ (p : ℤ) ^ j * ((p : ℤ) * q) := this
      _ ≤ ((p : ℤ) * q) ^ j * ((p : ℤ) * q) := by nlinarith
      _ = ((p : ℤ) * q) ^ (j + 1) := by rw [pow_succ]
  have e2 : (q : ℤ) ^ (j + 1) * ((p : ℤ) - 1) ≤ ((p : ℤ) * q) ^ (j + 1) := by
    have : (q : ℤ) ^ (j + 1) * ((p : ℤ) - 1) ≤ (q : ℤ) ^ j * ((p : ℤ) * q) := by
      rw [pow_succ]; nlinarith [pow_nonneg hq0 j]
    calc (q : ℤ) ^ (j + 1) * ((p : ℤ) - 1) ≤ (q : ℤ) ^ j * ((p : ℤ) * q) := this
      _ ≤ ((p : ℤ) * q) ^ j * ((p : ℤ) * q) := by nlinarith
      _ = ((p : ℤ) * q) ^ (j + 1) := by rw [pow_succ]
  have e3 : ((p : ℤ) - 1) * ((q : ℤ) - 1) ≤ ((p : ℤ) * q) ^ (j + 1) := by
    have h1 : ((p : ℤ) - 1) * ((q : ℤ) - 1) ≤ (p : ℤ) * q := by nlinarith
    have h2 : ((p : ℤ) * q) ≤ ((p : ℤ) * q) ^ (j + 1) := by
      rw [pow_succ]; nlinarith
    linarith
  linarith

/-- The natural-number form of the upper bound. -/
theorem gcdMoment_le_nat (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (j : ℕ) :
    gcdMoment (j + 1) (p * q) ≤ 4 * (p * q) ^ (j + 1) := by
  have h := gcdMoment_le hp hq hpq j
  have : ((gcdMoment (j + 1) (p * q) : ℕ) : ℤ) ≤ ((4 * (p * q) ^ (j + 1) : ℕ) : ℤ) := by
    push_cast; push_cast at h; linarith
  exact_mod_cast this

/-- The variance of `gcd(N, U)^k` for `U` uniform on the residues mod `N`. -/
noncomputable def gcdVariance (k n : ℕ) : ℚ :=
  (gcdMoment (2 * k) n : ℚ) / n - ((gcdMoment k n : ℚ) / n) ^ 2

/-- **Sampling cost (barrier 4).**  The variance of the `k`-th gcd power is at least
`N^{2k−1} − 16 N^{2k−2}`, so Chebyshev estimation of the trace from `k`-th powers needs
`Ω(N^{2k−1})` samples: the moment hierarchy is a *cost* hierarchy. -/
theorem gcdVariance_lower_bound (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (j : ℕ) :
    ((p * q : ℕ) : ℚ) ^ (2 * j + 1) - 16 * ((p * q : ℕ) : ℚ) ^ (2 * j)
      ≤ gcdVariance (j + 1) (p * q) := by
  have hNpos : 0 < p * q := Nat.mul_pos hp.pos hq.pos
  have hN : (0 : ℚ) < ((p * q : ℕ) : ℚ) := by exact_mod_cast hNpos
  have h1 : ((p * q : ℕ) : ℚ) ^ (2 * j + 2) ≤ (gcdMoment (2 * (j + 1)) (p * q) : ℚ) := by
    have h := gcdMoment_ge (2 * (j + 1)) (p * q) hNpos
    have h' : (((p * q) ^ (2 * (j + 1)) : ℕ) : ℚ) ≤ (gcdMoment (2 * (j + 1)) (p * q) : ℚ) := by
      exact_mod_cast h
    calc ((p * q : ℕ) : ℚ) ^ (2 * j + 2) = (((p * q) ^ (2 * (j + 1)) : ℕ) : ℚ) := by
          push_cast; ring_nf
      _ ≤ _ := h'
  have h2 : (gcdMoment (j + 1) (p * q) : ℚ) ≤ 4 * ((p * q : ℕ) : ℚ) ^ (j + 1) := by
    have h := gcdMoment_le_nat hp hq hpq j
    have h' : ((gcdMoment (j + 1) (p * q) : ℕ) : ℚ) ≤ ((4 * (p * q) ^ (j + 1) : ℕ) : ℚ) := by
      exact_mod_cast h
    calc (gcdMoment (j + 1) (p * q) : ℚ) ≤ ((4 * (p * q) ^ (j + 1) : ℕ) : ℚ) := h'
      _ = 4 * ((p * q : ℕ) : ℚ) ^ (j + 1) := by push_cast; ring
  unfold gcdVariance
  have e1 : ((p * q : ℕ) : ℚ) ^ (2 * j + 1)
      ≤ (gcdMoment (2 * (j + 1)) (p * q) : ℚ) / ((p * q : ℕ) : ℚ) := by
    rw [le_div_iff₀ hN]
    calc ((p * q : ℕ) : ℚ) ^ (2 * j + 1) * ((p * q : ℕ) : ℚ)
        = ((p * q : ℕ) : ℚ) ^ (2 * j + 2) := by ring
      _ ≤ _ := h1
  have e2 : ((gcdMoment (j + 1) (p * q) : ℚ) / ((p * q : ℕ) : ℚ)) ^ 2
      ≤ 16 * ((p * q : ℕ) : ℚ) ^ (2 * j) := by
    have hdiv : (gcdMoment (j + 1) (p * q) : ℚ) / ((p * q : ℕ) : ℚ)
        ≤ 4 * ((p * q : ℕ) : ℚ) ^ j := by
      rw [div_le_iff₀ hN]
      calc (gcdMoment (j + 1) (p * q) : ℚ) ≤ 4 * ((p * q : ℕ) : ℚ) ^ (j + 1) := h2
        _ = 4 * ((p * q : ℕ) : ℚ) ^ j * ((p * q : ℕ) : ℚ) := by ring
    have hnn : (0 : ℚ) ≤ (gcdMoment (j + 1) (p * q) : ℚ) / ((p * q : ℕ) : ℚ) := by positivity
    calc ((gcdMoment (j + 1) (p * q) : ℚ) / ((p * q : ℕ) : ℚ)) ^ 2
        ≤ (4 * ((p * q : ℕ) : ℚ) ^ j) ^ 2 := by nlinarith
      _ = 16 * ((p * q : ℕ) : ℚ) ^ (2 * j) := by rw [mul_pow, ← pow_mul]; ring_nf
  linarith

/-- For `k = 1` the variance is at most `4N`: the first moment is the cheap end of the
hierarchy, an `Θ(N)`-sample estimator rather than `Θ(N^{2k−1})`. -/
theorem gcdVariance_one_le (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    gcdVariance 1 (p * q) ≤ 4 * ((p * q : ℕ) : ℚ) := by
  have hNpos : 0 < p * q := Nat.mul_pos hp.pos hq.pos
  have hN : (0 : ℚ) < ((p * q : ℕ) : ℚ) := by exact_mod_cast hNpos
  have h2 : (gcdMoment 2 (p * q) : ℚ) ≤ 4 * ((p * q : ℕ) : ℚ) ^ 2 := by
    have h := gcdMoment_le_nat hp hq hpq 1
    have h' : ((gcdMoment 2 (p * q) : ℕ) : ℚ) ≤ ((4 * (p * q) ^ 2 : ℕ) : ℚ) := by
      exact_mod_cast h
    calc (gcdMoment 2 (p * q) : ℚ) ≤ ((4 * (p * q) ^ 2 : ℕ) : ℚ) := h'
      _ = 4 * ((p * q : ℕ) : ℚ) ^ 2 := by push_cast; ring
  unfold gcdVariance
  have hsq : (0 : ℚ) ≤ ((gcdMoment 1 (p * q) : ℚ) / ((p * q : ℕ) : ℚ)) ^ 2 := sq_nonneg _
  have hfirst : (gcdMoment (2 * 1) (p * q) : ℚ) / ((p * q : ℕ) : ℚ)
      ≤ 4 * ((p * q : ℕ) : ℚ) := by
    rw [div_le_iff₀ hN]
    calc (gcdMoment (2 * 1) (p * q) : ℚ) = (gcdMoment 2 (p * q) : ℚ) := by norm_num
      _ ≤ 4 * ((p * q : ℕ) : ℚ) ^ 2 := h2
      _ = 4 * ((p * q : ℕ) : ℚ) * ((p * q : ℕ) : ℚ) := by ring
  linarith

/-- **The cost separation.**  For `N ≥ 32` the second-moment estimator has variance at least
`N²/8` times the first-moment variance: higher moments are exponentially worse, so the
`O(N)` gcd scan at `k = 1` is the optimal member of the family. -/
theorem gcdVariance_separation (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hbig : (32 : ℚ) ≤ ((p * q : ℕ) : ℚ)) :
    ((p * q : ℕ) : ℚ) ^ 2 / 8 * gcdVariance 1 (p * q) ≤ gcdVariance 2 (p * q) := by
  have hlow := gcdVariance_lower_bound hp hq hpq 1
  have hup := gcdVariance_one_le hp hq hpq
  norm_num at hlow
  have hpos : (0 : ℚ) ≤ ((p * q : ℕ) : ℚ) ^ 2 / 8 := by positivity
  have h1 : ((p * q : ℕ) : ℚ) ^ 2 / 8 * gcdVariance 1 (p * q)
      ≤ ((p * q : ℕ) : ℚ) ^ 2 / 8 * (4 * ((p * q : ℕ) : ℚ)) :=
    mul_le_mul_of_nonneg_left hup hpos
  push_cast at hlow hup hbig hpos h1 ⊢
  nlinarith [hlow, h1, hbig]

/-! ### Witness density -/

/-- **The matching upper bound for the variance.**  Together with `gcdVariance_lower_bound`
this pins the variance of `gcd(N,U)^{j+1}` to the window `[N^{2j+1} − 16N^{2j}, 4N^{2j+1}]`,
so it is `Θ(N^{2k−1})` and the sampling cost hierarchy is tight in order. -/
theorem gcdVariance_upper_bound (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (j : ℕ) :
    gcdVariance (j + 1) (p * q) ≤ 4 * ((p * q : ℕ) : ℚ) ^ (2 * j + 1) := by
  have hNpos : 0 < p * q := Nat.mul_pos hp.pos hq.pos
  have hN : (0 : ℚ) < ((p * q : ℕ) : ℚ) := by exact_mod_cast hNpos
  have h2 : (gcdMoment (2 * (j + 1)) (p * q) : ℚ) ≤ 4 * ((p * q : ℕ) : ℚ) ^ (2 * j + 2) := by
    have h := gcdMoment_le_nat hp hq hpq (2 * j + 1)
    have h' : ((gcdMoment (2 * j + 2) (p * q) : ℕ) : ℚ)
        ≤ ((4 * (p * q) ^ (2 * j + 2) : ℕ) : ℚ) := by exact_mod_cast h
    have hidx : 2 * (j + 1) = 2 * j + 2 := by ring
    rw [hidx]
    calc (gcdMoment (2 * j + 2) (p * q) : ℚ) ≤ ((4 * (p * q) ^ (2 * j + 2) : ℕ) : ℚ) := h'
      _ = 4 * ((p * q : ℕ) : ℚ) ^ (2 * j + 2) := by push_cast; ring
  have hsq : (0 : ℚ) ≤ ((gcdMoment (j + 1) (p * q) : ℚ) / ((p * q : ℕ) : ℚ)) ^ 2 := sq_nonneg _
  have hdiv : (gcdMoment (2 * (j + 1)) (p * q) : ℚ) / ((p * q : ℕ) : ℚ)
      ≤ 4 * ((p * q : ℕ) : ℚ) ^ (2 * j + 1) := by
    rw [div_le_iff₀ hN]
    calc (gcdMoment (2 * (j + 1)) (p * q) : ℚ)
        ≤ 4 * ((p * q : ℕ) : ℚ) ^ (2 * j + 2) := h2
      _ = 4 * ((p * q : ℕ) : ℚ) ^ (2 * j + 1) * ((p * q : ℕ) : ℚ) := by ring
  unfold gcdVariance
  linarith

/-- The variance is `Θ(N^{2k−1})`: both bounds at once. -/
theorem gcdVariance_theta (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (j : ℕ) :
    ((p * q : ℕ) : ℚ) ^ (2 * j + 1) - 16 * ((p * q : ℕ) : ℚ) ^ (2 * j)
        ≤ gcdVariance (j + 1) (p * q) ∧
      gcdVariance (j + 1) (p * q) ≤ 4 * ((p * q : ℕ) : ℚ) ^ (2 * j + 1) :=
  ⟨gcdVariance_lower_bound hp hq hpq j, gcdVariance_upper_bound hp hq hpq j⟩

/-- **The `Θ(p+q)` query threshold.**  Exactly `p + q − 1` of the `N` probes `x < N` have a
nontrivial gcd with `N`; a uniform probe therefore succeeds with probability `(p+q−1)/N`. -/
theorem card_nontrivial_gcd (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    #{x ∈ Finset.range (p * q) | (p * q).gcd x ≠ 1} = p + q - 1 := by
  classical
  have hcard := Finset.card_filter_add_card_filter_not
    (s := Finset.range (p * q)) (p := fun x => (p * q).gcd x = 1)
  have hphi : φ (p * q) = #{x ∈ Finset.range (p * q) | (p * q).gcd x = 1} := rfl
  have htot : φ (p * q) = (p - 1) * (q - 1) := by
    rw [Nat.totient_mul ((Nat.coprime_primes hp hq).2 hpq), Nat.totient_prime hp,
      Nat.totient_prime hq]
  rw [Finset.card_range, ← hphi, htot] at hcard
  have h2p := hp.two_le
  have h2q := hq.two_le
  have hexp : (p - 1) * (q - 1) + p + q - 1 = p * q := by
    obtain ⟨a, rfl⟩ : ∃ a, p = a + 2 := ⟨p - 2, by omega⟩
    obtain ⟨b, rfl⟩ : ∃ b, q = b + 2 := ⟨q - 2, by omega⟩
    have e1 : (a + 2 - 1) * (b + 2 - 1) = a * b + a + b + 1 := by
      rw [show a + 2 - 1 = a + 1 from rfl, show b + 2 - 1 = b + 1 from rfl]; ring
    have e2 : (a + 2) * (b + 2) = a * b + 2 * a + 2 * b + 4 := by ring
    omega
  have hne : #{x ∈ Finset.range (p * q) | ¬((p * q).gcd x = 1)}
      = #{x ∈ Finset.range (p * q) | (p * q).gcd x ≠ 1} := rfl
  rw [hne] at hcard
  omega

end GCDMoment