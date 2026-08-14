import Mathlib
import Tropical.FactorLocationBarriers

/-!
# The trace lemma and its exhaustiveness for power-weight aggregates

This file attacks the declared frontier of the *free-witness* programme: turning
the **trace lemma** ("every recoverable counting witness collapses to a single
factor-secret coordinate, and knowing the coordinate is knowing the
factorisation") from a classification slogan into a theorem, for the
CRT-multiplicative *power weights* `d ↦ d ^ k`, whose aggregates are the
divisor-power sums `σ_k`.

The results are:

* **Spread monotonicity** (`sum_gt_of_spread`, `powerSum_strict_of_spread`): among
  all factorisations `a · b = N` with `a ≤ b`, the power sum `a ^ k + b ^ k`
  (`k ≥ 1`) is *strictly* decreasing as the pair gets balanced. This is the
  analytic heart, proved through the `geom_sum₂` factorisation of `x ^ k - y ^ k`.
* **Trace lemma** (`trace_lemma_powerSum`): consequently, for `k ≥ 1` the value
  `a ^ k + b ^ k` determines the ordered pair `(a, b)` *among all factorisations of
  `N`*, not merely among prime ones. So a `σ_k`-witness is a factor-secret
  coordinate.
* **Exhaustive dichotomy** (`sigma_trace_dichotomy`): for every exponent `k`,
  either the aggregate is factorisation-insensitive (`k = 0`: `σ_0` is the constant
  `4` on semiprimes — barrier 5) or it is a free witness that pins the
  factorisation uniquely (`k ≥ 1`). There is no third behaviour in the family.
* **Explicit poly-time recovery** (`recoverSmallFactor_sigma_one`,
  `recoverSmallFactor_sigma_two`): the SIGK prediction, formalised. From `σ₁(N)`,
  resp. from `σ₂(N)` (i.e. from `p² + q²`), the smaller prime is returned by a
  closed-form `O(1)`-arithmetic-operations formula built from `Nat.sqrt`.
* **Characters-only boundary** (`power_weight_crt_multiplicative`,
  `exp_phase_not_crt_multiplicative`): power weights *are* CRT-multiplicative,
  while exponential phase weights `x ↦ z ^ x` are not, unless `z = 1`. This is the
  WIGNER-CUBIC boundary lemma, delimiting the class the dichotomy applies to.
* **Aggregation barrier / noise floor** (`noise_floor_below_corner`,
  `finite_probe_set_fails`): in the tropical window `[2, √N]` cut out by the corner
  of the divisor hyperbola there is exactly **one** useful probe, so the hit
  density is `1/(√N - 1)`; and no fixed finite probe set works for all semiprimes.

Everything below the `σ`-level reuses the catalog file
`Tropical.FactorLocationBarriers` (divisor structure of a semiprime, the tropical
corner) rather than reproving it.
-/

namespace TraceLemma

open Finset FactorLocationBarriers

/-! ## 1. Spread monotonicity of power sums along a hyperbola -/

/-- **Sum increases with spread.** If `a·b = a'·b'` and the pair `(a, b)` is more
spread out than `(a', b')` on the low side, then it has the strictly larger sum.
Tropically: moving away from the corner of the hyperbola `x ⊙ y = N` strictly
increases the classical trace. -/
theorem sum_gt_of_spread {a b a' b' : ℕ} (h1 : a < a') (h2 : a' ≤ b')
    (h : a * b = a' * b') : a' + b' < a + b := by
  nlinarith

/-- The pair further from the corner also has the strictly larger *power* sum, for
every exponent `k ≥ 1`. Proved via `x ^ k - y ^ k = (∑ …) · (x - y)`: the difference
factor is larger (`sum_gt_of_spread`) and the geometric cofactor is termwise larger. -/
theorem powerSum_strict_of_spread {k : ℕ} (hk : 1 ≤ k) {a b a' b' : ℕ} (ha : 0 < a)
    (h1 : a < a') (h2 : a' ≤ b') (h3 : b' < b) (h : a * b = a' * b') :
    a' ^ k + b' ^ k < a ^ k + b ^ k := by
  have hsum : a' + b' < a + b := sum_gt_of_spread h1 h2 h
  have key : ((a' : ℤ) ^ k - (a : ℤ) ^ k) < ((b : ℤ) ^ k - (b' : ℤ) ^ k) := by
    have hA : ((b : ℤ) ^ k - (b' : ℤ) ^ k)
        = (∑ i ∈ range k, (b : ℤ) ^ i * (b' : ℤ) ^ (k - 1 - i)) * ((b : ℤ) - b') :=
      (geom_sum₂_mul _ _ _).symm
    have hB : ((a' : ℤ) ^ k - (a : ℤ) ^ k)
        = (∑ i ∈ range k, (a' : ℤ) ^ i * (a : ℤ) ^ (k - 1 - i)) * ((a' : ℤ) - a) :=
      (geom_sum₂_mul _ _ _).symm
    rw [hA, hB]
    have hBA : (∑ i ∈ range k, (a' : ℤ) ^ i * (a : ℤ) ^ (k - 1 - i))
        ≤ ∑ i ∈ range k, (b : ℤ) ^ i * (b' : ℤ) ^ (k - 1 - i) := by
      refine Finset.sum_le_sum ?_
      intro i _
      have h4 : (a' : ℤ) ≤ (b : ℤ) := by exact_mod_cast le_of_lt (lt_of_le_of_lt h2 h3)
      have h5 : (a : ℤ) ≤ (b' : ℤ) := by exact_mod_cast le_of_lt (lt_of_lt_of_le h1 h2)
      have e1 := pow_le_pow_left₀ (show (0 : ℤ) ≤ (a' : ℤ) by positivity) h4 i
      have e2 := pow_le_pow_left₀ (show (0 : ℤ) ≤ (a : ℤ) by positivity) h5 (k - 1 - i)
      have hpp : (0 : ℤ) ≤ (a' : ℤ) ^ i := by positivity
      nlinarith [pow_nonneg (show (0 : ℤ) ≤ (b' : ℤ) by positivity) (k - 1 - i),
        pow_nonneg (show (0 : ℤ) ≤ (a : ℤ) by positivity) (k - 1 - i)]
    have hBpos : (0 : ℤ) < ∑ i ∈ range k, (a' : ℤ) ^ i * (a : ℤ) ^ (k - 1 - i) := by
      apply Finset.sum_pos
      · intro i _
        have hz : (0 : ℤ) < (a : ℤ) := by exact_mod_cast ha
        have hz' : (0 : ℤ) < (a' : ℤ) := by exact_mod_cast lt_trans ha h1
        positivity
      · exact ⟨0, mem_range.mpr hk⟩
    have hd1 : (0 : ℤ) < (a' : ℤ) - a := by
      have : (a : ℤ) < (a' : ℤ) := by exact_mod_cast h1
      linarith
    have hd2 : ((a' : ℤ) - a) < ((b : ℤ) - b') := by
      have : ((a' : ℤ) + b') < (a : ℤ) + b := by exact_mod_cast hsum
      linarith
    nlinarith
  have h6 : ((a' : ℤ) ^ k + (b' : ℤ) ^ k) < ((a : ℤ) ^ k + (b : ℤ) ^ k) := by linarith
  exact_mod_cast h6

/-! ## 2. The trace lemma: a power-sum witness determines the factorisation -/

/-- **Trace lemma for power weights.** For `k ≥ 1`, the witness value `a ^ k + b ^ k`
determines the ordered factorisation `(a, b)` of `N = a·b` uniquely — among *all*
factorisations, not just the prime one. Hence a `σ_k` witness is a factor-secret
coordinate: knowing it is knowing the factorisation. -/
theorem trace_lemma_powerSum {k : ℕ} (hk : 1 ≤ k) {N a b a' b' : ℕ} (ha : 0 < a)
    (ha' : 0 < a') (hab : a ≤ b) (hab' : a' ≤ b') (h : a * b = N) (h' : a' * b' = N)
    (hw : a ^ k + b ^ k = a' ^ k + b' ^ k) : a = a' ∧ b = b' := by
  have hprod : a * b = a' * b' := by rw [h, h']
  have haa' : a = a' := by
    rcases lt_trichotomy a a' with hlt | heq | hgt
    · exfalso
      have hb' : b' < b := by nlinarith
      have := powerSum_strict_of_spread hk ha hlt hab' hb' hprod
      omega
    · exact heq
    · exfalso
      have hb : b < b' := by nlinarith
      have := powerSum_strict_of_spread hk ha' hgt hab hb hprod.symm
      omega
  refine ⟨haa', ?_⟩
  subst haa'
  exact Nat.eq_of_mul_eq_mul_left ha hprod

/-! ## 3. The `σ_k` aggregate of a semiprime, and the two branches -/

/-- **CRT-multiplicative aggregate.** For distinct primes the divisor-power sum
factors through the CRT splitting: `σ_k(pq) = (1 + p^k)(1 + q^k)`. -/
theorem sigma_semiprime (k p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    ArithmeticFunction.sigma k (p * q) = (1 + p ^ k) * (1 + q ^ k) := by
  rw [ArithmeticFunction.sigma_apply, divisors_semiprime p q hp hq]
  have h1p : (1 : ℕ) ≠ p := hp.one_lt.ne
  have h1q : (1 : ℕ) ≠ q := hq.one_lt.ne
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have h1pq : (1 : ℕ) ≠ p * q := by nlinarith
  have hppq : p ≠ p * q := by nlinarith
  have hqpq : q ≠ p * q := by nlinarith
  rw [Finset.sum_insert (by simp [h1p, h1q, h1pq]),
    Finset.sum_insert (by simp [hpq, hppq]),
    Finset.sum_insert (by simp [hqpq]), Finset.sum_singleton]
  rw [mul_pow]
  ring

/-- The **free-witness extraction**: from the aggregate and `N` one reads off the
power-sum coordinate `p ^ k + q ^ k` by a single subtraction. -/
theorem powerSum_of_sigma (k p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    p ^ k + q ^ k = ArithmeticFunction.sigma k (p * q) - 1 - (p * q) ^ k := by
  rw [sigma_semiprime k p q hp hq hpq, mul_pow]
  have : (1 + p ^ k) * (1 + q ^ k) = 1 + (p ^ k + q ^ k) + p ^ k * q ^ k := by ring
  omega

/-- **Barrier 5 branch (`k = 0`): the aggregate is factorisation-insensitive.**
`σ_0` is the constant `4` on all semiprimes, so it separates no two of them. -/
theorem sigma_zero_semiprime_const (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    ArithmeticFunction.sigma 0 (p * q) = 4 := by
  rw [ArithmeticFunction.sigma_apply]
  simp only [pow_zero, Finset.sum_const, smul_eq_mul, mul_one]
  exact card_divisors_semiprime p q hp hq hpq

/-- **The exhaustive dichotomy for power weights.** For every exponent `k`, exactly
one of the two behaviours predicted by the classification occurs:

* `k = 0`: the aggregate is constant on semiprimes — factorisation-insensitive;
* `k ≥ 1`: the aggregate is a *free witness* — its value together with `N` pins the
  factorisation of `N` uniquely, among **all** factorisations.

There is no intermediate ("partially informative") member of the family. -/
theorem sigma_trace_dichotomy (k : ℕ) :
    (∀ p q p' q' : ℕ, p.Prime → q.Prime → p ≠ q → p'.Prime → q'.Prime → p' ≠ q' →
        ArithmeticFunction.sigma k (p * q) = ArithmeticFunction.sigma k (p' * q'))
      ∨ (∀ N a b a' b' : ℕ, 0 < a → 0 < a' → a ≤ b → a' ≤ b' → a * b = N → a' * b' = N →
        a ^ k + b ^ k = a' ^ k + b' ^ k → a = a' ∧ b = b') := by
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · left
    intro p q p' q' hp hq hpq hp' hq' hpq'
    rw [sigma_zero_semiprime_const p q hp hq hpq, sigma_zero_semiprime_const p' q' hp' hq' hpq']
  · right
    intro N a b a' b' ha ha' hab hab' h h' hw
    exact trace_lemma_powerSum hk ha ha' hab hab' h h' hw

/-! ## 4. Explicit recovery: the SIGK prediction, formalised -/

/-- Closed-form recovery of the smaller factor from the trace `s = a + b` and the
norm `N = a·b`: the classical `(s - √(s² - 4N))/2`, in `ℕ`. -/
def recoverSmallFactor (N s : ℕ) : ℕ := (s - Nat.sqrt (s * s - 4 * N)) / 2

/-- **Trace coordinate ⇒ factorisation, explicitly.** Given the trace `a + b` and the
product `a·b`, the formula returns the smaller factor. This is the poly-time half of
the trace lemma. -/
theorem recoverSmallFactor_eq {a b : ℕ} (hab : a ≤ b) :
    recoverSmallFactor (a * b) (a + b) = a := by
  obtain ⟨c, rfl⟩ : ∃ c, b = a + c := ⟨b - a, by omega⟩
  have hd : (a + (a + c)) * (a + (a + c)) - 4 * (a * (a + c)) = c * c := by
    have h : (a + (a + c)) * (a + (a + c)) = c * c + 4 * (a * (a + c)) := by ring
    omega
  rw [recoverSmallFactor, hd, Nat.sqrt_eq]
  omega

/-- **SIGK, `k = 1`.** From the divisor sum `σ₁(N)` of a semiprime one recovers the
smaller prime factor in closed form. -/
theorem recoverSmallFactor_sigma_one {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hlt : p < q) :
    recoverSmallFactor (p * q) (ArithmeticFunction.sigma 1 (p * q) - 1 - p * q) = p := by
  have hw := powerSum_of_sigma 1 p q hp hq hlt.ne
  simp only [pow_one] at hw
  rw [← hw]
  exact recoverSmallFactor_eq hlt.le

/-- **SIGK, `k = 2` — the predicted free witness.** From `σ₂(N) = (1+p²)(1+q²)`, i.e.
from the power sum `p² + q²`, the smaller prime factor is recovered in closed form:
first the trace `p + q = √(p² + q² + 2N)`, then the quadratic formula. -/
theorem recoverSmallFactor_sigma_two {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hlt : p < q) :
    recoverSmallFactor (p * q)
        (Nat.sqrt (ArithmeticFunction.sigma 2 (p * q) - 1 - (p * q) ^ 2 + 2 * (p * q))) = p := by
  have hw := powerSum_of_sigma 2 p q hp hq hlt.ne
  rw [← hw]
  have hsq : p ^ 2 + q ^ 2 + 2 * (p * q) = (p + q) * (p + q) := by ring
  rw [hsq, Nat.sqrt_eq]
  exact recoverSmallFactor_eq hlt.le

/-- The other trace coordinate: the max. If the witness collapses to `max(p, q)`
instead of the trace, recovery is a single division. -/
theorem recover_from_max {p q : ℕ} (hp : 0 < p) (hlt : p ≤ q) :
    (p * q) / max p q = min p q := by
  rw [max_eq_right hlt, min_eq_left hlt]
  exact Nat.mul_div_cancel _ (lt_of_lt_of_le hp hlt)

/-! ## 5. The characters-only boundary (WIGNER-CUBIC) -/

/-- Power weights are CRT-multiplicative — they are exactly the multiplicative
characters that the classification allows. -/
theorem power_weight_crt_multiplicative (k m n : ℕ) :
    (m * n) ^ k = m ^ k * n ^ k := mul_pow m n k

/-- **Characters-only boundary lemma.** An exponential phase weight `x ↦ z ^ x` is
never CRT-multiplicative unless it is trivial: multiplicativity on the coprime pair
`(2, 3)` already forces `z = 1`. So exponential phases do not decompose through the
CRT splitting, and fall outside the free-witness class. -/
theorem exp_phase_not_crt_multiplicative {z : ℂ} (hz : z ≠ 0)
    (h : ∀ m n : ℕ, Nat.Coprime m n → z ^ (m * n) = z ^ m * z ^ n) : z = 1 := by
  have h23 := h 2 3 (by decide)
  have h6 : z ^ 6 = z ^ 5 := by
    rw [show (2 * 3 : ℕ) = 6 from rfl] at h23
    rw [h23]; ring
  have : z ^ 5 * z = z ^ 5 * 1 := by rw [mul_one]; rw [← pow_succ] at *; simpa using h6
  exact mul_left_cancel₀ (pow_ne_zero 5 hz) this

/-- The natural-number shadow of the boundary lemma: an integer exponential weight
`x ↦ c ^ x` with `c ≥ 2` is not CRT-multiplicative. -/
theorem nat_exp_weight_not_crt_multiplicative {c : ℕ} (hc : 2 ≤ c) :
    ¬ (∀ m n : ℕ, Nat.Coprime m n → c ^ (m * n) = c ^ m * c ^ n) := by
  intro h
  have h23 := h 2 3 (by decide)
  rw [show (2 * 3 : ℕ) = 6 from rfl, ← pow_add] at h23
  norm_num at h23
  have : c ^ 5 < c ^ 6 := Nat.pow_lt_pow_right hc (by norm_num)
  omega

/-! ## 6. The aggregation barrier: the noise floor in the tropical window -/

/-- **Noise floor below the tropical corner.** In the window `[2, √N]` cut out by the
corner of the divisor hyperbola there is exactly one useful probe, namely `p`, while
the window has `√N - 1` candidates: the hit density is exactly `1/(√N - 1)`, the
birthday-bound scale. -/
theorem noise_floor_below_corner {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hlt : p < q) :
    ((Finset.Icc 2 (Nat.sqrt (p * q))).filter (fun d => d ∣ p * q)) = {p}
      ∧ (Finset.Icc 2 (Nat.sqrt (p * q))).card = Nat.sqrt (p * q) - 1 := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hpq : 0 < p * q := by positivity
  have hpsqrt : p ≤ Nat.sqrt (p * q) := Nat.le_sqrt.mpr (by nlinarith)
  constructor
  · ext d
    simp only [Finset.mem_filter, Finset.mem_Icc, Finset.mem_singleton]
    constructor
    · rintro ⟨⟨hd2, hdle⟩, hdvd⟩
      have hmem : d ∈ (p * q).divisors := Nat.mem_divisors.mpr ⟨hdvd, hpq.ne'⟩
      rw [divisors_semiprime p q hp hq] at hmem
      simp only [Finset.mem_insert, Finset.mem_singleton] at hmem
      have hsq : d * d ≤ p * q := le_trans (Nat.mul_le_mul hdle hdle) (Nat.sqrt_le _)
      rcases hmem with rfl | rfl | rfl | rfl
      · omega
      · rfl
      · exact absurd hsq (by nlinarith)
      · exact absurd hsq (by nlinarith)
    · rintro rfl
      exact ⟨⟨hp2, hpsqrt⟩, ⟨q, rfl⟩⟩
  · rw [Nat.card_Icc]
    omega

/-- **Barrier 4 (aggregation), adversarial form.** No fixed finite probe set can
locate factors: for every finite set `S` of probes there is a semiprime `N = pq`
none of whose nontrivial divisors is probed. Aggregation over a window that grows
with `N` is unavoidable. -/
theorem finite_probe_set_fails (S : Finset ℕ) :
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p < q ∧
      ∀ s ∈ S, ¬ (s ∣ p * q ∧ 1 < s ∧ s < p * q) := by
  obtain ⟨M, hM⟩ : ∃ M : ℕ, ∀ s ∈ S, s ≤ M := ⟨S.sup id, fun s hs => Finset.le_sup (f := id) hs⟩
  obtain ⟨p, hpM, hp⟩ := Nat.exists_infinite_primes (M + 1)
  obtain ⟨q, hqp, hq⟩ := Nat.exists_infinite_primes (p + 1)
  refine ⟨p, q, hp, hq, hqp, ?_⟩
  rintro s hs ⟨hdvd, hs1, hsN⟩
  have hsM := hM s hs
  have hmem : s ∈ (p * q).divisors :=
    Nat.mem_divisors.mpr ⟨hdvd, Nat.mul_ne_zero hp.pos.ne' hq.pos.ne'⟩
  rw [divisors_semiprime p q hp hq] at hmem
  simp only [Finset.mem_insert, Finset.mem_singleton] at hmem
  rcases hmem with rfl | rfl | rfl | rfl <;> omega

end TraceLemma