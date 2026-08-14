import MachineLearning.FreeWitnessClassification

/-!
# SIGK: the predicted free witness `σ_k`, and the polynomial barrier for it

The classification of `16_FreeWitness_Classification.md` makes a falsifiable prediction:
*any* non-polynomial CRT-multiplicative local weight yields a free witness, and the
divisor power sum `σ_k(N) = ∑_{d ∣ N} d^k`, whose local weight is `1 + p^k`, should be
one.  This file proves the prediction, in the strong form that the paper only reports as
"verified computationally":

* `sigma_prime`, `sigma_semiprime` — the local weight and the CRT factorisation
  `σ_k(pq) = (1 + p^k)(1 + q^k)` for distinct primes.

* `sigmaWitness` — `σ_k` as a `FreeWitness.SemiprimeWitness` with power-shaped local
  weight `x ^ k + 1`, so the abstract trace lemma of `FreeWitnessTraceLemma.lean`
  applies verbatim.

* `sigma_power_sum`, `sigma_one_trace`, `sigma_two_trace_sq`, `sigma_two_trace_nat` —
  the recovery formulas: `p^k + q^k = σ_k(N) - N^k - 1`; for `k = 1` the trace itself,
  for `k = 2` the identity `(p+q)^2 + 1 + N^2 = σ_2(N) + 2N` and the explicit square
  root `p + q = √(σ_2(N) + 2N - 1 - N²)`.

* `sigma_two_recovers_factors` — the full factorisation is determined: any positive pair
  with the same product and the same witness-derived trace *is* `{p, q}`.

* `sigma_not_polynomial` — **the hard half.**  For every `k ≥ 1` there is *no* integer
  polynomial `P` with `σ_k(pq) = P(pq)` for all pairs of distinct primes.  This is the
  instance `c = 1` of the general rigidity theorem
  `FreeWitness.powerWeight_not_polynomial` of `FreeWitnessClassification.lean`: fixing
  one prime `r` and letting the other run over the infinitely many primes forces the
  polynomial identity `P(r X) = (1 + r^k)(1 + X^k)`; the `r = 3` identity at `10` and the
  `r = 5` identity at `6` give two values for `P(30)` whose equality would force
  `10^k + 3^k = 6^k + 5^k`, which fails for every `k ≥ 1`.

* `sigma_two_not_polynomial_witness` — the same conclusion by the cheap congruence
  route of `FreeWitness.not_polynomial_of_not_dvd`: `33 - 15 = 18` does not divide
  `σ_2(33) - σ_2(15) = 960`.

Together with `FreeWitnessTraceLemma.lean` this makes the two structural claims of the
classification precise for the SIGK family: the witness is *factoring-complete*
(it hands over the trace) and *non-polynomial* in the modulus.
-/

namespace FreeWitness

open ArithmeticFunction Polynomial

/-! ## The local weight and the CRT factorisation -/

/-- The local weight of `σ_k` at a prime: `σ_k(p) = 1 + p ^ k`. -/
theorem sigma_prime {k p : ℕ} (hp : p.Prime) : (sigma k) p = 1 + p ^ k := by
  rw [sigma_apply, hp.divisors, Finset.sum_pair hp.one_lt.ne]
  simp

/-- **The SIGK prediction.**  For distinct primes, `σ_k(pq) = (1 + p^k)(1 + q^k)`:
the divisor power sum is CRT-multiplicative with non-polynomial local weight. -/
theorem sigma_semiprime {k p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    (sigma k) (p * q) = (1 + p ^ k) * (1 + q ^ k) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  rw [isMultiplicative_sigma.map_mul_of_coprime hcop, sigma_prime hp, sigma_prime hq]

/-- `σ_k` as a CRT-multiplicative semiprime witness with power-shaped local weight. -/
def sigmaWitness (k : ℕ) : SemiprimeWitness where
  W N := ((sigma k N : ℕ) : ℤ)
  w x := (x : ℤ) ^ k + 1
  factorizes := by
    intro p q hp hq _ _ hpq
    rw [sigma_semiprime hp hq hpq]
    push_cast
    ring

@[simp] lemma sigmaWitness_W (k N : ℕ) : (sigmaWitness k).W N = ((sigma k N : ℕ) : ℤ) := rfl

@[simp] lemma sigmaWitness_w (k x : ℕ) : (sigmaWitness k).w x = (x : ℤ) ^ k + 1 := rfl

/-! ## Recovery: the trace lemma for `σ_k` -/

/-- **The power-sum recovery for `σ_k`**: `p^k + q^k = σ_k(N) - N^k - 1`. -/
theorem sigma_power_sum {k p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2)
    (hq2 : q ≠ 2) (hpq : p ≠ q) :
    (p : ℤ) ^ k + (q : ℤ) ^ k = ((sigma k (p * q) : ℕ) : ℤ) - ((p : ℤ) * q) ^ k - 1 :=
  (sigmaWitness k).powerSum_recovery_one hp hq hp2 hq2 hpq (by simp) (by simp)

/-- `k = 1`: the classical divisor sum returns the trace, `p + q = σ(N) - N - 1`. -/
theorem sigma_one_trace {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2)
    (hq2 : q ≠ 2) (hpq : p ≠ q) :
    (p : ℤ) + q = ((sigma 1 (p * q) : ℕ) : ℤ) - ((p : ℤ) * q) - 1 :=
  (sigmaWitness 1).trace_recovery hp hq hp2 hq2 hpq (by simp) (by simp)

/-- `k = 2`: the square of the trace, `(p + q)^2 = σ_2(N) - N^2 + 2N - 1`. -/
theorem sigma_two_trace_sq {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2)
    (hq2 : q ≠ 2) (hpq : p ≠ q) :
    ((p : ℤ) + q) ^ 2 = ((sigma 2 (p * q) : ℕ) : ℤ) - ((p : ℤ) * q) ^ 2 + 2 * ((p : ℤ) * q) - 1 :=
  (sigmaWitness 2).trace_sq_recovery hp hq hp2 hq2 hpq (by simp) (by simp)

/-- Subtraction-free natural-number form of the `k = 2` recovery. -/
theorem sigma_two_trace_nat {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2)
    (hq2 : q ≠ 2) (hpq : p ≠ q) :
    (p + q) ^ 2 + 1 + (p * q) ^ 2 = sigma 2 (p * q) + 2 * (p * q) := by
  have h := sigma_two_trace_sq hp hq hp2 hq2 hpq
  have : (((p + q) ^ 2 + 1 + (p * q) ^ 2 : ℕ) : ℤ) = ((sigma 2 (p * q) + 2 * (p * q) : ℕ) : ℤ) := by
    push_cast
    linarith
  exact_mod_cast this

/-- **The trace is an explicit square root of witness data.**  For odd distinct primes,
`p + q = √(σ_2(N) + 2N - 1 - N²)`, a formula in `N` and the witness value only. -/
theorem sigma_two_trace_sqrt {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2)
    (hq2 : q ≠ 2) (hpq : p ≠ q) :
    p + q = Nat.sqrt (sigma 2 (p * q) + 2 * (p * q) - 1 - (p * q) ^ 2) := by
  have h := sigma_two_trace_nat hp hq hp2 hq2 hpq
  have hsub : sigma 2 (p * q) + 2 * (p * q) - 1 - (p * q) ^ 2 = (p + q) ^ 2 := by omega
  rw [hsub, Nat.sqrt_eq']

/-- **`σ_2` determines the factorisation.**  Any pair of positive integers with the same
product `N` and with the trace predicted by the witness is the pair `{p, q}` itself.
This is the "information content of every witness is one factor-secret coordinate"
statement, for SIGK. -/
theorem sigma_two_recovers_factors {p q p' q' : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) (hp'0 : p' ≠ 0)
    (hprod : p' * q' = p * q)
    (htrace : ((p' : ℤ) + q') ^ 2
      = ((sigma 2 (p * q) : ℕ) : ℤ) - ((p : ℤ) * q) ^ 2 + 2 * ((p : ℤ) * q) - 1) :
    (p' = p ∧ q' = q) ∨ (p' = q ∧ q' = p) := by
  have h := sigma_two_trace_sq hp hq hp2 hq2 hpq
  have hsq : ((p' : ℤ) + q') ^ 2 = ((p : ℤ) + q) ^ 2 := by rw [htrace, h]
  have hnn1 : (0 : ℤ) ≤ (p' : ℤ) + q' := by positivity
  have hnn2 : (0 : ℤ) ≤ (p : ℤ) + q := by positivity
  have hsum : (p' : ℤ) + q' = (p : ℤ) + q := by nlinarith [hsq, hnn1, hnn2]
  have hsumN : p' + q' = p + q := by exact_mod_cast hsum
  exact pair_determined_of_sum_prod hp'0 hprod.symm hsumN.symm

/-! ## The polynomial barrier for `σ_k` -/

/-- **The polynomial barrier for SIGK, unconditionally and for every `k ≥ 1`.**
There is no integer polynomial `P` with `σ_k(pq) = P(pq)` for all distinct primes
`p, q`.  This is the instance `a = 1`, `c = 1` of the general rigidity theorem
`FreeWitness.powerWeight_not_polynomial`: the witness value is genuinely a function of
`p` and `q` separately, not of the modulus `N`. -/
theorem sigma_not_polynomial {k : ℕ} (hk : 1 ≤ k) :
    ∀ P : Polynomial ℤ, ¬ (∀ p q : ℕ, p.Prime → q.Prime → p ≠ q →
      ((sigma k (p * q) : ℕ) : ℤ) = P.eval ((p : ℤ) * q)) := by
  intro P hP
  refine powerWeight_not_polynomial (sigmaWitness k) hk one_ne_zero (fun s _ _ => by simp) P ?_
  intro p q hp hq _ _ hpq
  simpa using hP p q hp hq hpq

/-- The same conclusion for `k = 2` by the cheap congruence route: `33 - 15 = 18` does
not divide `σ_2(33) - σ_2(15) = 1220 - 260 = 960`.  (A single pair of moduli suffices,
which is exactly the "mod `2^k` separation" strategy of §5 of the paper.) -/
theorem sigma_two_not_polynomial_witness :
    ∀ P : Polynomial ℤ, ¬ (∀ n ∈ ({15, 33} : Set ℕ),
      ((sigma 2 n : ℕ) : ℤ) = P.eval (n : ℤ)) := by
  have h33 : sigma 2 33 = 1220 := by
    have : (33 : ℕ) = 3 * 11 := by norm_num
    rw [this, sigma_semiprime (by norm_num) (by norm_num) (by norm_num)]
    norm_num
  have h15 : sigma 2 15 = 260 := by
    have : (15 : ℕ) = 3 * 5 := by norm_num
    rw [this, sigma_semiprime (by norm_num) (by norm_num) (by norm_num)]
    norm_num
  refine not_polynomial_of_not_dvd (W := fun n => ((sigma 2 n : ℕ) : ℤ))
    (S := ({15, 33} : Set ℕ)) (N₁ := 33) (N₂ := 15) (by simp) (by simp) ?_
  simp only [h33, h15]
  norm_num

/-! ### Lab notes (cycle 2: SIGK)

```
N = p·q   σ₂(N)   (1+p²)(1+q²)   p²+q² = σ₂-1-N²   trace √(σ₂+2N-1-N²)
15 = 3·5    260   10·26 = 260          34                8 = 3+5
21 = 3·7    500   10·50 = 500          58               10 = 3+7
33 = 3·11  1220   10·122 = 1220       130               14 = 3+11
35 = 5·7   1300   26·50 = 1300          74              12 = 5+7
77 = 7·11  6100   50·122 = 6100        170              18 = 7+11
```
Difference test for the polynomial barrier: `33 - 15 = 18`, `σ₂(33) - σ₂(15) = 960`,
and `18 ∤ 960`.  The rigidity proof upgrades this from one pair to all `k ≥ 1`.
-/

example : sigma 2 15 = 260 := by decide
example : sigma 2 21 = 500 := by decide
example : sigma 1 33 = 48 := by decide

end FreeWitness