# Future Directions: Perfect Numbers and Multiplicative Divisor-Mass Theory

This document outlines five concrete breakthrough research opportunities opened by our formal theory of perfect numbers. Each direction includes a precise theorem target, expected Lean signature, proof strategy, and explanation of why it opens a new research frontier.

---

## Direction 1: Euler's Odd Perfect Number Shape Theorem

### Theorem Statement
Every odd perfect number has the form n = q^(4k+1) · m² where q is a prime with q ≡ 1 (mod 4) and gcd(q, m) = 1. The prime q is called the *special* or *Euler* prime.

### Expected Lean Signature
```lean
theorem odd_perfect_euler_shape {n : ℕ}
    (hperf : Perfect n) (hodd : Odd n) :
    ∃ q k m : ℕ,
      Nat.Prime q ∧
      q % 4 = 1 ∧
      n = q ^ (4 * k + 1) * m ^ 2 ∧
      Nat.Coprime q m := by sorry
```

### Proof Strategy
1. Show that for an odd perfect n, σ(n) = 2n implies σ(n) is even.
2. For each prime power p^a ∥ n with p odd, σ(p^a) = 1 + p + ... + p^a has parity depending on a mod 2. If a is even, σ(p^a) has an odd number of odd terms.
3. Use multiplicativity of σ: exactly one prime power factor must make σ contribute an "extra" factor of 2, which requires that prime power to have an odd exponent.
4. Show this special prime q must satisfy q ≡ 1 (mod 4) by analyzing σ(q^(2j+1)) modulo 4.

### Helper Lemmas Needed
```lean
theorem sigma_prime_pow_odd_exp_parity {p a : ℕ} (hp : Nat.Prime p) (hodd_p : Odd p) :
    Even (sigma (p ^ a)) ↔ Odd a := by sorry

theorem odd_perfect_exactly_one_odd_exp {n : ℕ}
    (hperf : Perfect n) (hodd : Odd n) :
    ∃! p, p ∈ n.primeFactors ∧ Odd (n.factorization p) := by sorry
```

### Why This Opens a New Field-Line
Euler's shape theorem is the gateway to all deeper odd perfect number results. It constrains the factorization structure so severely that it enables:
- Bounds on the number of prime factors (since most must appear with even exponent)
- Modular constraints on the special prime q
- Branch-and-bound exclusion algorithms over the shape parameters

This theorem has never been formally verified and would be a significant contribution to the formal mathematics community.

---

## Direction 2: Abundancy Optimization and Local Factor Bounds

### Theorem Statement
For an odd perfect number n with prime factorization n = ∏ pᵢ^aᵢ, the abundancy constraint ∏ I(pᵢ^aᵢ) = 2 imposes strict inequalities. In particular:
- The smallest prime factor of n is at most ⌊(2ω(n) - 1)^(1/(ω(n)-1))⌋
- If all prime factors exceed B, then ω(n) ≥ ⌈log₂(2) / log₂(B/(B-1))⌉

### Expected Lean Signature
```lean
theorem odd_perfect_smallest_prime_bound {n : ℕ}
    (hperf : Perfect n) (hodd : Odd n) (p : ℕ) 
    (hp : Nat.Prime p) (hdvd : p ∣ n) 
    (hmin : ∀ q, Nat.Prime q → q ∣ n → p ≤ q) :
    (p : ℚ) / (p - 1) ≥ 2 ^ (1 / (littleOmega n : ℚ)) := by sorry

theorem odd_perfect_omega_lower_bound_from_smallest_prime {n : ℕ}
    (hperf : Perfect n) (hodd : Odd n)
    (B : ℕ) (hB : ∀ p, Nat.Prime p → p ∣ n → B ≤ p) :
    littleOmega n ≥ Nat.ceil (Real.log 2 / Real.log (B / (B - 1))) := by sorry
```

### Proof Strategy
1. Use abundancy multiplicativity: 2 = ∏ I(pᵢ^aᵢ) ≤ ∏ pᵢ/(pᵢ-1)
2. If all primes exceed B, each factor ≤ B/(B-1), so 2 ≤ (B/(B-1))^ω(n)
3. Taking logarithms yields the bound on ω(n).
4. The smallest prime bound follows from the AM-GM-type analysis of the product constraint.

### Why This Opens a New Field-Line
This connects perfect number theory to formal optimization and provides a template for certified lower bounds. It demonstrates that the abundancy framework can produce quantitative results, not just structural ones. The machinery generalizes to superabundant numbers, highly composite numbers, and Robin-type inequalities — all of which are connected to the Riemann Hypothesis.

---

## Direction 3: Certified Odd Perfect Number Exclusion Framework

### Theorem Statement
Build a verified framework that can certify "no odd perfect number exists below N" for computationally reachable N, or more subtly, "no odd perfect number exists with prime factors in the set S and exponent pattern E."

### Expected Lean Signature
```lean
/-- A certified exclusion certificate for odd perfects with restricted factorization. -/
structure OddPerfectExclusion where
  prime_lower_bound : ℕ
  max_distinct_primes : ℕ
  excluded : Bool
  proof : excluded = true → ∀ n : ℕ, Perfect n → Odd n →
    (∀ p, Nat.Prime p → p ∣ n → prime_lower_bound ≤ p) →
    littleOmega n ≤ max_distinct_primes → False

/-- Framework theorem: exclusion by abundancy product bound. -/
theorem odd_perfect_exclusion_by_abundancy {primes : Finset ℕ} {exps : ℕ → ℕ}
    (hall_prime : ∀ p ∈ primes, Nat.Prime p)
    (hprod_lt : ∏ p ∈ primes, AbundancyIndex (p ^ exps p) < 2) :
    ¬∃ n : ℕ, Perfect n ∧ Odd n ∧ 
      (∀ p, Nat.Prime p → p ∣ n → p ∈ primes) ∧
      (∀ p ∈ primes, n.factorization p = exps p) := by sorry
```

### Proof Strategy
1. For a fixed set of candidate primes and exponent assignments, compute ∏ I(pᵢ^kᵢ) exactly in ℚ.
2. If the product < 2, no perfect number with that factorization pattern exists.
3. Systematically enumerate factorization patterns using Euler's shape theorem to prune.
4. Use `native_decide` or `norm_num` extensions for the computational steps.

### Why This Opens a New Field-Line
This bridges formal mathematics and verified computation. Unlike informal searches, each exclusion is machine-checked. The framework could eventually absorb the computational results of Brent, Cohen, and te Riele (1991) and Nielsen (2015), providing the first formally certified lower bounds on odd perfect numbers beyond trivial cases.

---

## Direction 4: Multiperfect Numbers and Generalized Abundancy

### Theorem Statement
Extend the theory to k-perfect numbers (σ(n) = kn for k ≥ 3). Prove structural constraints analogous to perfect numbers.

### Expected Lean Signature
```lean
/-- A number is k-perfect if σ(n) = k·n. -/
def kPerfect (k n : ℕ) : Prop := 0 < n ∧ sigma n = k * n

/-- k-perfectness in terms of abundancy. -/
theorem kPerfect_iff_abundancy {k n : ℕ} (hn : 0 < n) :
    kPerfect k n ↔ AbundancyIndex n = k := by sorry

/-- A 1-perfect number must be 1. -/
theorem one_perfect_iff {n : ℕ} :
    kPerfect 1 n ↔ n = 1 := by sorry

/-- If n is k-perfect with k ≥ 2, then n has at least two distinct prime factors. -/
theorem kPerfect_has_multiple_prime_factors {k n : ℕ} (hk : 2 ≤ k) 
    (hperf : kPerfect k n) :
    2 ≤ littleOmega n := by sorry

/-- Upper bound on abundancy for prime powers. -/
theorem abundancy_prime_pow_lt {p k : ℕ} (hp : Nat.Prime p) (hk : 0 < k) :
    AbundancyIndex (p ^ k) < (p : ℚ) / (p - 1) := by sorry
```

### Proof Strategy
1. Extend the abundancy framework: kPerfect k n ↔ I(n) = k.
2. Use multiplicativity and local bounds to constrain factorizations.
3. For k = 3: the smallest triperfect number is 120 = 2³ × 3 × 5. Only six are known.
4. Prove that large k requires many prime factors, using ∏ p/(p-1) estimates.

### Why This Opens a New Field-Line
Multiperfect numbers generalize perfects in a natural direction that is actively studied. The abundancy framework handles all k uniformly: σ(n) = kn becomes ∏ I(pᵢ^aᵢ) = k. This reveals perfect numbers as the k = 2 case of a broader optimization landscape and opens connections to highly composite numbers and Ramanujan's superior highly composite numbers.

---

## Direction 5: Robin's Inequality and the Riemann Hypothesis Connection

### Theorem Statement
Robin (1984) proved that the Riemann Hypothesis is equivalent to:
σ(n) < e^γ · n · ln(ln(n)) for all n > 5040
where γ is the Euler-Mascheroni constant.

### Expected Lean Signature
```lean
/-- Robin's inequality: σ(n) < e^γ · n · ln(ln(n)) -/
def RobinInequality (n : ℕ) : Prop :=
  5040 < n → (sigma n : ℝ) < Real.exp EulerMascheroni * n * Real.log (Real.log n)

/-- Known verified cases of Robin's inequality. -/
theorem robin_for_small_n {n : ℕ} (hn : 5040 < n) (hn2 : n ≤ 5040 * 10^6) :
    RobinInequality n := by sorry

/-- Superabundant numbers: I(n) > I(m) for all m < n. -/
def Superabundant (n : ℕ) : Prop :=
  ∀ m, 0 < m → m < n → AbundancyIndex m < AbundancyIndex n

/-- The first few superabundant numbers. -/
theorem superabundant_list :
    Superabundant 1 ∧ Superabundant 2 ∧ Superabundant 6 ∧ 
    Superabundant 12 ∧ Superabundant 60 ∧ Superabundant 120 := by sorry

/-- Perfect numbers are not superabundant (for n > 6). -/
theorem perfect_not_superabundant {n : ℕ} (hperf : Perfect n) (hn : 6 < n) :
    ¬Superabundant n := by sorry
```

### Proof Strategy
1. Formalize the Euler-Mascheroni constant and its basic properties.
2. For small cases, use `norm_num` and exact rational bounds.
3. For the connection to superabundant numbers, use the abundancy framework to show that superabundant numbers have "maximally efficient" prime factorizations.
4. The full Robin ↔ RH equivalence requires Gronwall's theorem (lim sup I(n)/ln(ln(n)) = e^γ), which is a deep analytic result.

### Why This Opens a New Field-Line
This is perhaps the most ambitious direction: connecting elementary divisor arithmetic to the deepest open problem in mathematics. The abundancy index framework provides the right language — Robin's inequality is literally a bound on I(n) normalized by ln(ln(n)). Formally verifying even partial cases would constitute a landmark in formal analytic number theory, bridging the gap between Mathlib's number-theoretic infrastructure and its analytic foundations.

---

## Research Team Directives

### Hypotheses to Test
1. The abundancy optimization approach can produce ω(n) ≥ 9 for odd perfects within 6 months.
2. Euler's shape theorem can be formalized using the parity analysis of σ(p^k) within the existing framework.
3. A certified branch-and-bound exclusion can cover all odd perfect candidates with ω(n) ≤ 4.

### Key Dependencies
- Direction 1 (Euler shape) is prerequisite for Directions 2 and 3.
- Direction 4 (multiperfect) is independent and can proceed in parallel.
- Direction 5 (Robin) requires Mathlib analytic infrastructure and is the longest-term goal.

### Cross-Domain Connections to Exploit
- **Formal optimization** (Direction 3): connect to verified linear programming and branch-and-bound.
- **Computational algebra** (Direction 4): use Lean's `norm_num` extensions for large-scale computation.
- **Analytic number theory** (Direction 5): bridge to Mathlib's growing analysis library.
- **Proof automation** (all directions): develop custom tactics for divisor-sum reasoning.

### Iteration Protocol
1. For each direction, formalize the statement and 2-3 key helper lemmas within one cycle.
2. Validate helper lemmas computationally before investing in formal proofs.
3. Use the theorem proving subagent for routine lemmas; reserve human effort for proof architecture.
4. Update this document after each cycle with refined hypotheses and new theorem targets.
