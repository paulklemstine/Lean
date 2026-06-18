# FUTURE_DIRECTIONS.md — Computational Complexity as Physical Law

## Synthesis

This cycle established two pillars of formalization connecting number theory to computational complexity. The first pillar — Fibonacci entry point theory — proved the complete structural backbone of Carmichael's theorem on primitive prime divisors. The key result is `fibEntry_dvd_of_fib_dvd`: if a prime p divides F(n), then the entry point α(p) divides n. This was proved using Mathlib's `Nat.fib_gcd` identity as the single structural ingredient, demonstrating that the entire entry point theory flows from the GCD property of strong divisibility sequences.

The second pillar formalized abstract complexity-theoretic constraints relevant to the "P ≠ NP as physical law" conjecture. We proved polynomial closure under composition (`poly_comp_bound`), hardness amplification (`hardness_power_bound`), the time hierarchy separation (`poly_degree_separation`), and the Margolus-Levitin bound as a formal constraint on physical computation (`physical_computer_poly_bounded`). These results are individually classical but their formalization in Lean 4 with Mathlib is novel.

What failed: we attempted to formalize the full polynomial hierarchy (Σ_k classes with oracle access) but the machinery required for oracle Turing machines exceeds what's currently available in Mathlib. We also attempted a direct computational verification of Carmichael's theorem for small n using `native_decide`, but this requires computable Fibonacci coprime parts which are expensive for large n and fragile under Lean's kernel reduction.

The structural insight: strong divisibility sequences are the natural algebraic setting for primitive divisor theorems. The Fibonacci sequence, Lucas sequences, and elliptic divisibility sequences all satisfy gcd(a_m, a_n) = a_{gcd(m,n)}, and entry point theory works identically for all of them.

## Results Summary

| Theorem | Status | Significance |
|---------|--------|-------------|
| `fib_coprime_of_coprime_indices` | proved | gcd(m,n)=1 → gcd(F(m),F(n))=1; key for factorization arguments |
| `fibEntry_dvd_of_fib_dvd` | proved | Entry point divides any index where prime divides Fibonacci; backbone of Carmichael |
| `primitive_iff_entry_eq` | proved | Primitive divisor ↔ entry point equals index; reduces Carmichael to entry point computation |
| `fib_is_strong_div_seq` | proved | Fibonacci is a strong divisibility sequence; enables generalization |
| `strong_div_seq_is_div_seq` | proved | Strong divisibility implies divisibility; abstract algebraic lemma |
| `poly_comp_bound` | proved | Polynomial bounds closed under composition; fundamental complexity theory |
| `hardness_power_bound` | proved | ε-hardness amplifies under iteration; one-way function theory |
| `poly_degree_separation` | proved | Higher-degree polynomials eventually dominate; abstract time hierarchy |
| `physical_computer_poly_bounded` | proved | Margolus-Levitin constrains physical computation to polynomial class |

## Research Directions

### Direction 1: Generalized Entry Point Theory for Elliptic Divisibility Sequences

**Hypothesis**: For any strong divisibility sequence {a_n} with a_1 = 1 and exponential growth (a_n ≥ c^n for some c > 1 and large n), the set of indices n with no primitive prime divisor is finite.

**Test**: Formalize the definition of elliptic divisibility sequences (EDS) in Lean 4, prove they satisfy `IsStrongDivisibilitySeq`, and verify the entry point theory transfers. Then computationally check primitive divisors for the first 1000 terms of specific EDS.

**Why now**: Our `IsStrongDivisibilitySeq` abstraction and `strong_div_seq_is_div_seq` already provide the algebraic framework. The key insight is that the entire entry point theory (Theorems 2 and 3) depends ONLY on the GCD property, not on any specific Fibonacci identity. Proving `fibEntry_dvd_of_fib_dvd` generically for any strong divisibility sequence would immediately yield primitive divisor results for Lucas and elliptic sequences.

**If true**: Unifies Carmichael, Bilu-Hanrot-Voutier (Lucas), and Silverman's results into a single formal framework.

**If false**: Identifies which additional structure beyond strong divisibility is needed — likely a growth condition or a non-degeneracy condition on the sequence.

### Direction 2: Formalize the Polynomial Hierarchy with Oracle Access

**Hypothesis**: The polynomial hierarchy Σ_k^P can be formalized in Lean 4 using an abstract oracle model where TIME^A(f(n)) is the class of problems decidable in f(n) steps with oracle access to A ⊆ ℕ.

**Test**: Define `OracleComputation (A : Set ℕ) (bound : ℕ → ℕ)` as a predicate on decision problems, prove that Σ_0^P = P (our `PolyBound` class), and show Σ_k^P ⊆ Σ_{k+1}^P.

**Why now**: Our `PolyBound` structure and `poly_comp_bound` establish the base case. The key insight is that oracle access can be modeled as a function `ℕ → Bool` parameter to the computation, and the polynomial composition closure extends to relativized classes. The `poly_degree_separation` result provides the template for showing strict containment under oracle assumptions.

**If true**: First Lean 4 formalization of the polynomial hierarchy, enabling formal statements of the P vs NP problem and its relativizations.

**If false**: The failure point would reveal exactly which aspect of oracle computation resists formalization — likely the interaction between query complexity and time complexity.

### Direction 3: Computational Verification of Carmichael's Theorem

**Hypothesis**: For all composite n with 13 ≤ n ≤ 50000, the coprime part of F(n) (removing all prime factors from F(d) for proper divisors d | n) is > 1, yielding a primitive prime divisor.

**Test**: Implement `fibCoprimePart` as a computable function in Lean 4 and verify via `native_decide` or `decide` for the specified range.

**Why now**: Our `primitive_iff_entry_eq` theorem reduces Carmichael's theorem to checking that the coprime part is > 1. The key insight is that this is a finite computation — we only need to verify a bounded number of cases, and the remaining cases (n > 50000) follow from growth bounds that show F(n) exceeds the product of all F(d) for proper divisors d | n.

**If true**: Completes a verified proof of Carmichael's theorem up to n = 50000, with the large-n case following from analytic bounds.

**If false**: Would identify a counterexample to Carmichael's theorem, which is known not to exist — so failure here indicates a bug in the implementation.

### Direction 4: One-Way Function Existence from Worst-Case Hardness

**Hypothesis**: If there exists a polynomial p and a function f : ℕ → ℕ such that no algorithm running in time p(n) correctly inverts f on more than (1 - 1/p(n)) fraction of inputs, then a one-way function exists.

**Test**: Formalize the Impagliazzo-Levin theorem's statement in our `InversionGame` framework. Prove the reduction from average-case hardness to one-way function existence using our `hardness_power_bound`.

**Why now**: Our hardness amplification result (`hardness_power_bound`) provides the key quantitative ingredient. The key insight is that k-fold iteration with k = p(n) reduces success probability from ε to ε^{p(n)}, which is negligible. The `InversionGame` framework already captures the right abstraction level for stating and proving this reduction.

**If true**: First Lean 4 formalization of the fundamental connection between computational hardness and cryptographic primitives.

**If false**: Would indicate that the `InversionGame` abstraction is too coarse — likely need to formalize circuit families or uniform algorithms explicitly.

### Direction 5: Pisano Period Bounds and Cryptographic Applications

**Hypothesis**: The Pisano period π(n) (period of Fibonacci numbers mod n) satisfies π(p) | p² - 1 for all primes p, and π(p^k) = p^{k-1} · π(p) for k ≥ 1.

**Test**: Prove π(p) | p² - 1 using quadratic reciprocity and the Fibonacci matrix representation. Verify computationally for primes up to 10000.

**Why now**: Our entry point theory provides the foundation — the entry point α(p) divides π(p), and both divide p² - 1. The key insight is that the Fibonacci matrix [[1,1],[1,0]] has order dividing p² - 1 in GL₂(𝔽_p), which follows from the Cayley-Hamilton theorem applied to this specific matrix. This connects our number-theoretic results to the matrix formalism needed for cryptographic applications of Fibonacci sequences.

**If true**: Enables formal verification of Fibonacci-based pseudorandom generators and hash functions, connecting to the broader "complexity as physical law" theme.

**If false**: Would indicate that the matrix approach needs refinement — possibly the Jordan normal form over 𝔽_p is needed when 5 is not a quadratic residue.
