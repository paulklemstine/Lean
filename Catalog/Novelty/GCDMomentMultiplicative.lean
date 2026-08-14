import Mathlib
import Novelty.GCDMomentTraceWitness
import Novelty.GCDMomentPairInversion

/-!
# The gcd moments are a multiplicative family: beyond semiprimes

`Novelty.GCDMomentTraceWitness` computes `M_k(N) = ∑_{x < N} gcd(N,x)^k` for a *semiprime*
`N = pq` and reads off the trace-witness structure.  This file removes the semiprime
restriction: `M_k` is the Dirichlet convolution `(n ↦ n^k) * φ`, hence multiplicative, so its
value at an arbitrary modulus is a product over the prime-power part of the factorisation.

The consequence for the trace-witness picture is sharp.  For a *squarefree* modulus

`M_k(n) = ∏_{p ∣ n} (p^k + p − 1)`,

so the moment is an Euler product over the prime factors: it is not just a symmetric function
of the factors, it is a **completely split** one, with one local factor per prime.  Specialising
to `n = pq` reproduces the semiprime four-term formula, and shows that the four terms of the
closed form are nothing but the expansion of a two-factor Euler product.

## Main results

* `gcdMomentAF` — the gcd moment as an arithmetic function, `pow k * phiAF`.
* `gcdMomentAF_isMultiplicative` — multiplicativity.
* `gcdMomentAF_apply_eq` — the arithmetic function agrees with `gcdMoment` on `n > 0`.
* `gcdMoment_mul_of_coprime` — `M_k(mn) = M_k(m) M_k(n)` for coprime `m, n > 0`.
* `gcdMoment_prime` — the local factor `M_k(p) = p^k + p − 1`.
* `gcdMoment_prime_pow`, `gcdMoment_prime_pow_closed` — the local factor at a prime power,
  `∑_{i ≤ e} p^{ik} φ(p^{e−i}) = p^{ek} + (p−1)∑_{i<e} p^{ik} p^{e−1−i}`.
* `gcdMoment_squarefree` — **the Euler product** `M_k(n) = ∏_{p ∣ n} (p^k + p − 1)`.
* `gcdMoment_ge_local`, `gcdMoment_gt_local_of_not_prime`, `gcdMoment_eq_local_iff_prime` —
  **the moment detects primality**: `M_k(n) ≥ n^k + n − 1` always, with equality iff `n` is
  prime.
* `gcdMoment_semiprime_euler` — the semiprime case as a two-factor product, and
  `gcdMoment_semiprime_euler_eq_four_terms` — its agreement with the closed form of the
  companion file.
* `gcdMoment_factorization` — the general modulus: a product over the prime factorisation.
* `pairMoment_eq_euler` — the predicted moment of a *candidate* factorisation is the same
  two-factor Euler product, which is what makes the inversion analysis of the companion files
  a statement about local factors.
* `euler_local_factor_refine`, `pairMoment_gt_trivial` — the local factor `t ↦ t^k + t − 1` is
  strictly submultiplicative on `t ≥ 2`: refining a factorisation strictly raises the moment.
* `eulerProd_ge_eulerLocal`, `eulerProd_gt_eulerLocal` — the same for an arbitrary number of
  factors: any splitting into `r ≥ 2` parts strictly raises the predicted moment.
-/

namespace GCDMoment

open Finset ArithmeticFunction

/-- Euler's totient packaged as an arithmetic function. -/
def phiAF : ArithmeticFunction ℕ := ⟨fun n => n.totient, Nat.totient_zero⟩

@[simp] lemma phiAF_apply (n : ℕ) : phiAF n = n.totient := rfl

lemma phiAF_isMultiplicative : phiAF.IsMultiplicative := by
  constructor
  · simp
  · intro m n h
    simp [Nat.totient_mul h]

/-- The `k`-th gcd moment as an arithmetic function: the Dirichlet convolution of `n ↦ n^k`
with Euler's totient. -/
def gcdMomentAF (k : ℕ) : ArithmeticFunction ℕ := ArithmeticFunction.pow k * phiAF

/-- **Multiplicativity.**  The gcd moment is a Dirichlet convolution of two multiplicative
functions, hence multiplicative. -/
theorem gcdMomentAF_isMultiplicative (k : ℕ) : (gcdMomentAF k).IsMultiplicative :=
  ArithmeticFunction.isMultiplicative_pow.mul phiAF_isMultiplicative

lemma gcdMomentAF_apply (k n : ℕ) :
    gcdMomentAF k n = ∑ d ∈ n.divisors, d ^ k * (n / d).totient := by
  rw [gcdMomentAF, ArithmeticFunction.mul_apply,
    Nat.sum_divisorsAntidiagonal (fun x y => ArithmeticFunction.pow k x * phiAF y)]
  refine Finset.sum_congr rfl fun d hd => ?_
  have hd0 : d ≠ 0 := by
    rcases Nat.mem_divisors.1 hd with ⟨hdvd, hn⟩
    rintro rfl
    exact hn (Nat.eq_zero_of_zero_dvd hdvd)
  simp [ArithmeticFunction.pow_apply, hd0]

/-- The arithmetic function computes the gcd moment. -/
theorem gcdMomentAF_apply_eq (k n : ℕ) (hn : 0 < n) : gcdMomentAF k n = gcdMoment k n := by
  rw [gcdMomentAF_apply, gcdMoment_eq_sum_divisors k n hn]

/-- **The gcd moment is multiplicative**, in elementary terms. -/
theorem gcdMoment_mul_of_coprime {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : Nat.Coprime m n)
    (k : ℕ) : gcdMoment k (m * n) = gcdMoment k m * gcdMoment k n := by
  have := (gcdMomentAF_isMultiplicative k).2 h
  rw [gcdMomentAF_apply_eq k _ (Nat.mul_pos hm hn), gcdMomentAF_apply_eq k m hm,
    gcdMomentAF_apply_eq k n hn] at this
  exact this

/-- **The local factor at a prime**: `M_k(p) = p^k + p − 1`. -/
theorem gcdMoment_prime {p : ℕ} (hp : p.Prime) (k : ℕ) : gcdMoment k p = p ^ k + p - 1 := by
  rw [← gcdMomentAF_apply_eq k p hp.pos, gcdMomentAF_apply, hp.divisors]
  rw [Finset.sum_pair hp.one_lt.ne]
  rw [Nat.div_self hp.pos, Nat.div_one, Nat.totient_prime hp]
  have : 1 ≤ p := hp.pos
  simp only [one_pow, one_mul, Nat.totient_one, mul_one]
  omega

/-- **The local factor at a prime power.** -/
theorem gcdMoment_prime_pow {p : ℕ} (hp : p.Prime) (e k : ℕ) :
    gcdMoment k (p ^ e) = ∑ i ∈ Finset.range (e + 1), p ^ (i * k) * (p ^ (e - i)).totient := by
  rw [← gcdMomentAF_apply_eq k _ (pow_pos hp.pos e), gcdMomentAF_apply,
    Nat.sum_divisors_prime_pow hp]
  refine Finset.sum_congr rfl fun i hi => ?_
  have hile : i ≤ e := by simpa [Nat.lt_succ_iff] using hi
  rw [Nat.pow_div hile hp.pos, ← pow_mul]

/-- **Closed form of the local factor at a prime power.**  `M_k(p^e) = p^{ek} + (p−1)·∑_{i<e}
p^{ik}·p^{e−1−i}`, which for `e = 1` is the prime factor `p^k + p − 1`. -/
theorem gcdMoment_prime_pow_closed {p : ℕ} (hp : p.Prime) (e k : ℕ) :
    gcdMoment k (p ^ e)
      = p ^ (e * k) + (p - 1) * ∑ i ∈ Finset.range e, p ^ (i * k) * p ^ (e - 1 - i) := by
  rw [gcdMoment_prime_pow hp e k, Finset.sum_range_succ, Nat.sub_self, pow_zero,
    Nat.totient_one, mul_one, Finset.mul_sum, add_comm]
  congr 1
  refine Finset.sum_congr rfl fun i hi => ?_
  have hie : i < e := Finset.mem_range.1 hi
  have hpos : 0 < e - i := by omega
  rw [Nat.totient_prime_pow hp hpos]
  have hidx : e - i - 1 = e - 1 - i := by omega
  rw [hidx]
  ring

/-- **The Euler product for a squarefree modulus.**  Every gcd moment splits completely into
one local factor per prime divisor. -/
theorem gcdMoment_squarefree {n : ℕ} (hn : Squarefree n) (k : ℕ) :
    gcdMoment k n = ∏ p ∈ n.primeFactors, (p ^ k + p - 1) := by
  have hn0 : 0 < n := hn.ne_zero.bot_lt
  rw [← gcdMomentAF_apply_eq k n hn0]
  conv_lhs => rw [← Nat.prod_primeFactors_of_squarefree hn]
  rw [(gcdMomentAF_isMultiplicative k).map_prod _ n.primeFactors
      (fun p hp q hq hpq => (Nat.coprime_primes (Nat.prime_of_mem_primeFactors hp)
        (Nat.prime_of_mem_primeFactors hq)).2 hpq)]
  refine Finset.prod_congr rfl fun p hp => ?_
  have hpp := Nat.prime_of_mem_primeFactors hp
  rw [gcdMomentAF_apply_eq k p hpp.pos, gcdMoment_prime hpp]

/-! ### The moment detects primality exactly

Gauss's identity `∑_{d ∣ n} φ(d) = n` gives a universal lower bound `M_k(n) ≥ n^k + n − 1`,
attained precisely at the primes.  So the local Euler factor is not merely the value of the
moment at a prime: it is the *minimum* of the moment over all moduli of a given size, and the
excess `M_k(n) − (n^k + n − 1)` is a strictly positive measure of how composite `n` is. -/

/-- **The universal lower bound.**  `M_k(n) ≥ n^k + n − 1` for every `n > 0`, by Gauss's
totient identity. -/
theorem gcdMoment_ge_local {n : ℕ} (hn : 0 < n) (k : ℕ) : n ^ k + n - 1 ≤ gcdMoment k n := by
  classical
  rw [gcdMoment_eq_sum_divisors k n hn]
  have hmem : n ∈ n.divisors := Nat.mem_divisors_self n hn.ne'
  have hg : ∑ d ∈ n.divisors, Nat.totient (n / d) = n := by
    rw [Nat.sum_div_divisors]; exact Nat.sum_totient n
  have hgsplit := Finset.add_sum_erase n.divisors (fun d => Nat.totient (n / d)) hmem
  rw [hg] at hgsplit
  simp only [Nat.div_self hn, Nat.totient_one] at hgsplit
  have hle : ∑ d ∈ n.divisors.erase n, Nat.totient (n / d)
      ≤ ∑ d ∈ n.divisors.erase n, d ^ k * Nat.totient (n / d) := by
    refine Finset.sum_le_sum fun d hd => ?_
    have hd0 : 0 < d := Nat.pos_of_mem_divisors (Finset.mem_of_mem_erase hd)
    exact Nat.le_mul_of_pos_left _ (by positivity)
  have hsplit := Finset.add_sum_erase n.divisors (fun d => d ^ k * Nat.totient (n / d)) hmem
  simp only [Nat.div_self hn, Nat.totient_one, mul_one] at hsplit
  omega

/-- **Strictness at composite moduli.**  Any nontrivial divisor contributes a strict excess. -/
theorem gcdMoment_gt_local_of_not_prime {n : ℕ} (hn : 2 ≤ n) (hnp : ¬ n.Prime) {k : ℕ}
    (hk : 1 ≤ k) : n ^ k + n - 1 < gcdMoment k n := by
  classical
  have hn0 : 0 < n := by omega
  rw [gcdMoment_eq_sum_divisors k n hn0]
  have hmem : n ∈ n.divisors := Nat.mem_divisors_self n hn0.ne'
  have hg : ∑ d ∈ n.divisors, Nat.totient (n / d) = n := by
    rw [Nat.sum_div_divisors]; exact Nat.sum_totient n
  have hgsplit := Finset.add_sum_erase n.divisors (fun d => Nat.totient (n / d)) hmem
  rw [hg] at hgsplit
  simp only [Nat.div_self hn0, Nat.totient_one] at hgsplit
  obtain ⟨m, hmdvd, hm1, hmn⟩ : ∃ m, m ∣ n ∧ m ≠ 1 ∧ m ≠ n := by
    by_contra hc
    push_neg at hc
    exact hnp (Nat.prime_def.2 ⟨hn, fun m hm => by
      rcases eq_or_ne m 1 with rfl | h1
      · exact Or.inl rfl
      · exact Or.inr (hc m hm h1)⟩)
  have hmem' : m ∈ n.divisors.erase n :=
    Finset.mem_erase.2 ⟨hmn, Nat.mem_divisors.2 ⟨hmdvd, hn0.ne'⟩⟩
  have hlt : ∑ d ∈ n.divisors.erase n, Nat.totient (n / d)
      < ∑ d ∈ n.divisors.erase n, d ^ k * Nat.totient (n / d) := by
    refine Finset.sum_lt_sum (fun d hd => ?_) ⟨m, hmem', ?_⟩
    · have hd0 : 0 < d := Nat.pos_of_mem_divisors (Finset.mem_of_mem_erase hd)
      exact Nat.le_mul_of_pos_left _ (by positivity)
    · have hm0 : 0 < m := Nat.pos_of_mem_divisors (Nat.mem_divisors.2 ⟨hmdvd, hn0.ne'⟩)
      have hm2 : 2 ≤ m := by omega
      have hmk : 2 ≤ m ^ k := le_trans hm2 (Nat.le_self_pow (by omega) m)
      have htot : 0 < Nat.totient (n / m) :=
        Nat.totient_pos.2 (Nat.div_pos (Nat.le_of_dvd hn0 hmdvd) hm0)
      calc Nat.totient (n / m) < 2 * Nat.totient (n / m) := by omega
        _ ≤ m ^ k * Nat.totient (n / m) := Nat.mul_le_mul_right _ hmk
  have hsplit := Finset.add_sum_erase n.divisors (fun d => d ^ k * Nat.totient (n / d)) hmem
  simp only [Nat.div_self hn0, Nat.totient_one, mul_one] at hsplit
  omega

/-- **Primality criterion.**  For `n ≥ 2` and `k ≥ 1`, the `k`-th gcd moment attains its
universal lower bound exactly at the primes. -/
theorem gcdMoment_eq_local_iff_prime {n : ℕ} (hn : 2 ≤ n) {k : ℕ} (hk : 1 ≤ k) :
    gcdMoment k n = n ^ k + n - 1 ↔ n.Prime := by
  constructor
  · intro h
    by_contra hnp
    exact absurd h (by have := gcdMoment_gt_local_of_not_prime hn hnp hk; omega)
  · intro hp
    exact gcdMoment_prime hp k

/-- The semiprime case is a two-factor Euler product. -/
theorem gcdMoment_semiprime_euler {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (k : ℕ) : gcdMoment k (p * q) = (p ^ k + p - 1) * (q ^ k + q - 1) := by
  rw [gcdMoment_mul_of_coprime hp.pos hq.pos ((Nat.coprime_primes hp hq).2 hpq) k,
    gcdMoment_prime hp, gcdMoment_prime hq]

/-- Consistency: the Euler product expands to the four-term closed form of the companion file,
so the "four terms" are exactly the four terms of a two-factor Euler product. -/
theorem gcdMoment_semiprime_euler_eq_four_terms {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (k : ℕ) :
    (gcdMoment k (p * q) : ℤ) = ((p : ℤ) ^ k + (p : ℤ) - 1) * ((q : ℤ) ^ k + (q : ℤ) - 1) := by
  rw [gcdMoment_semiprime_four_terms hp hq hpq k]
  ring

/-! ### The predicted moment is itself an Euler product

The inversion analysis of `Novelty.GCDMomentPairInversion` is built on `pairMoment`, the moment
a candidate factorisation `N = ab` predicts.  The multiplicative picture explains its shape: it
is exactly the two-factor Euler product with the *candidate* factors in place of the primes.
Monotonicity in the spread — the engine of the identifiability theorems — is therefore the
statement that the local factor `t ↦ t^k + t − 1` is log-convex enough to make the product
increase as the factors move apart. -/

/-- **`pairMoment` is the two-factor Euler product.** -/
theorem pairMoment_eq_euler (k : ℕ) (a b : ℤ) :
    pairMoment k a b = (a ^ k + a - 1) * (b ^ k + b - 1) := by
  simp only [pairMoment]; ring

/-- The prediction of the true factorisation is the true moment, seen through the Euler
product: this re-derives `gcdMoment_semiprime_euler` from multiplicativity alone. -/
theorem pairMoment_prime_pair_eq_gcdMoment {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (k : ℕ) :
    pairMoment k (p : ℤ) (q : ℤ) = (((p ^ k + p - 1) * (q ^ k + q - 1) : ℕ) : ℤ) := by
  have h1 : 1 ≤ p ^ k + p := le_trans hp.pos (Nat.le_add_left p _)
  have h2 : 1 ≤ q ^ k + q := le_trans hq.pos (Nat.le_add_left q _)
  rw [pairMoment_eq_euler]
  push_cast [Nat.cast_sub h1, Nat.cast_sub h2]
  ring

/-- **Refinement strictly increases the Euler product.**  Splitting a factor `uv` into `u` and
`v` (both `≥ 2`) strictly increases the predicted moment, for every `k ≥ 1`.  Equivalently, the
local factor `L_k(t) = t^k + t − 1` is strictly submultiplicative on `t ≥ 2`. -/
theorem euler_local_factor_refine {u v : ℤ} (hu : 2 ≤ u) (hv : 2 ≤ v) {k : ℕ} (hk : 1 ≤ k) :
    (u * v) ^ k + u * v - 1 < (u ^ k + u - 1) * (v ^ k + v - 1) := by
  have hk0 : k ≠ 0 := by omega
  have hu1 : (1 : ℤ) ≤ u := by linarith
  have hv1 : (1 : ℤ) ≤ v := by linarith
  have hupow : u ≤ u ^ k := le_self_pow₀ hu1 hk0
  have hvpow : v ≤ v ^ k := le_self_pow₀ hv1 hk0
  have hmul : (u * v) ^ k = u ^ k * v ^ k := mul_pow u v k
  have h1 : (0 : ℤ) < (u - 1) * (v - 1) := mul_pos (by linarith) (by linarith)
  nlinarith [mul_nonneg (sub_nonneg.2 hupow) (sub_nonneg.2 hv1),
    mul_nonneg (sub_nonneg.2 hvpow) (sub_nonneg.2 hu1)]

/-- The same statement in `pairMoment` form: any genuine splitting of the modulus predicts a
larger moment than the trivial factorisation. -/
theorem pairMoment_gt_trivial {u v : ℤ} (hu : 2 ≤ u) (hv : 2 ≤ v) {k : ℕ} (hk : 1 ≤ k) :
    (u * v) ^ k + u * v - 1 < pairMoment k u v := by
  rw [pairMoment_eq_euler]
  exact euler_local_factor_refine hu hv hk

/-! ### The `r`-factor refinement law -/

/-- The local Euler factor `L_k(a) = a^k + a − 1`. -/
def eulerLocal (k : ℕ) (a : ℤ) : ℤ := a ^ k + a - 1

/-- The Euler product predicted by a factorisation given as a list of factors. -/
def eulerProd (k : ℕ) (l : List ℤ) : ℤ := (l.map (eulerLocal k)).prod

lemma eulerLocal_refine {u v : ℤ} (hu : 2 ≤ u) (hv : 2 ≤ v) {k : ℕ} (hk : 1 ≤ k) :
    eulerLocal k (u * v) < eulerLocal k u * eulerLocal k v := by
  simpa [eulerLocal] using euler_local_factor_refine hu hv hk

lemma three_le_eulerLocal {a : ℤ} (ha : 2 ≤ a) {k : ℕ} (hk : 1 ≤ k) : 3 ≤ eulerLocal k a := by
  have : a ≤ a ^ k := le_self_pow₀ (by linarith) (by omega)
  simp only [eulerLocal]; linarith

lemma two_le_list_prod : ∀ (l : List ℤ), l ≠ [] → (∀ a ∈ l, 2 ≤ a) → 2 ≤ l.prod
  | [], h, _ => absurd rfl h
  | [a], _, h => by simpa using h a (by simp)
  | (a :: b :: t), _, h => by
      have ha : 2 ≤ a := h a (by simp)
      have hrest : 2 ≤ (b :: t).prod :=
        two_le_list_prod (b :: t) (by simp) (fun x hx => h x (by simp [hx]))
      rw [List.prod_cons]
      nlinarith

/-- **Refinement monotonicity for an arbitrary number of factors.**  The Euler product over any
factorisation into parts `≥ 2` is at least the single local factor of the whole product. -/
theorem eulerProd_ge_eulerLocal {k : ℕ} (hk : 1 ≤ k) : ∀ (l : List ℤ), l ≠ [] →
    (∀ a ∈ l, 2 ≤ a) → eulerLocal k l.prod ≤ eulerProd k l
  | [], h, _ => absurd rfl h
  | [_], _, _ => by simp [eulerProd]
  | (a :: b :: t), _, h => by
      have ha : 2 ≤ a := h a (by simp)
      have hrest : 2 ≤ (b :: t).prod :=
        two_le_list_prod _ (by simp) (fun x hx => h x (by simp [hx]))
      have ih : eulerLocal k (b :: t).prod ≤ eulerProd k (b :: t) :=
        eulerProd_ge_eulerLocal hk (b :: t) (by simp) (fun x hx => h x (by simp [hx]))
      have hla : (0 : ℤ) < eulerLocal k a := by
        have := three_le_eulerLocal ha hk; linarith
      have hstep := eulerLocal_refine ha hrest hk
      have hmul := mul_le_mul_of_nonneg_left ih (le_of_lt hla)
      have hsplit : eulerProd k (a :: b :: t) = eulerLocal k a * eulerProd k (b :: t) := by
        simp [eulerProd]
      rw [hsplit, List.prod_cons]
      linarith

/-- **Strict refinement.**  As soon as the factorisation has at least two parts, the Euler
product strictly exceeds the local factor of the modulus: a genuine splitting is always visible
in the moment. -/
theorem eulerProd_gt_eulerLocal {k : ℕ} (hk : 1 ≤ k) (a : ℤ) (l : List ℤ) (hne : l ≠ [])
    (h : ∀ x ∈ a :: l, 2 ≤ x) : eulerLocal k (a :: l).prod < eulerProd k (a :: l) := by
  have ha : 2 ≤ a := h a (by simp)
  have hrest : 2 ≤ l.prod := two_le_list_prod l hne (fun x hx => h x (by simp [hx]))
  have ih : eulerLocal k l.prod ≤ eulerProd k l :=
    eulerProd_ge_eulerLocal hk l hne (fun x hx => h x (by simp [hx]))
  have hla : (0 : ℤ) < eulerLocal k a := by have := three_le_eulerLocal ha hk; linarith
  have hstep := eulerLocal_refine ha hrest hk
  have hmul := mul_le_mul_of_nonneg_left ih (le_of_lt hla)
  have hsplit : eulerProd k (a :: l) = eulerLocal k a * eulerProd k l := by simp [eulerProd]
  rw [hsplit, List.prod_cons]
  linarith

/-- **The general modulus.**  For any `n > 0` the moment is the product of its local factors. -/
theorem gcdMoment_factorization (k : ℕ) {n : ℕ} (hn : 0 < n) :
    gcdMoment k n = n.factorization.prod fun p e => gcdMoment k (p ^ e) := by
  rw [← gcdMomentAF_apply_eq k n hn,
    (gcdMomentAF_isMultiplicative k).multiplicative_factorization _ hn.ne']
  refine Finsupp.prod_congr fun p hp => ?_
  have hpp : p.Prime := Nat.prime_of_mem_primeFactors (by simpa using hp)
  exact gcdMomentAF_apply_eq k _ (pow_pos hpp.pos _)

/-- Sanity checks of the Euler product against brute-force enumeration:
`M_2(6) = (2²+2−1)(3²+3−1) = 5·11` and `M_3(30) = 9·29·129`. -/
example : gcdMoment 2 6 = (2 ^ 2 + 2 - 1) * (3 ^ 2 + 3 - 1) := by decide
example : gcdMoment 3 30 = (2 ^ 3 + 2 - 1) * (3 ^ 3 + 3 - 1) * (5 ^ 3 + 5 - 1) := by decide
example : gcdMoment 2 12 = gcdMoment 2 4 * gcdMoment 2 3 := by decide

end GCDMoment