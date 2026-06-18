# The Anti-Fibonacci Sequence: Quadratic Growth Through Fibonacci Avoidance

## Abstract

We introduce and study the *anti-Fibonacci sequence*, defined by a(0) = a(1) = 1 and a(n+2) = a(n+1) + (n+1), whose increments grow linearly rather than exponentially. We establish the closed form a(n) = n(n−1)/2 + 1 and prove that this sequence is *eventually Fibonacci-avoidant*: for all n ≥ 4, a(n+2) < a(n+1) + a(n), meaning the sequence grows strictly slower than the Fibonacci recurrence would dictate. We introduce the *Fibonacci defect* — a measure of deviation from the Fibonacci recurrence — and compute it exactly as n(3−n)/2. We prove that the sequence satisfies the Fibonacci recurrence at exactly two positions (n = 0 and n = 3), characterizing all "accidental coincidences." Finally, we establish that for n ≥ 12, the anti-Fibonacci sequence is strictly dominated by the Fibonacci sequence, rigorously separating polynomial from exponential growth. All results are formally verified in Lean 4 with the Mathlib library.

## 1. Introduction

The Fibonacci sequence F(n), defined by F(0) = 0, F(1) = 1, F(n+2) = F(n+1) + F(n), is one of the most studied objects in combinatorics and number theory. Its exponential growth rate φⁿ/√5, where φ = (1+√5)/2 is the golden ratio, appears throughout mathematics, biology, and art.

A natural question arises: what happens if we define a sequence that *avoids* the Fibonacci recurrence? More precisely, we seek sequences whose growth pattern is fundamentally incompatible with the additive structure that generates Fibonacci numbers.

We propose the **anti-Fibonacci sequence**, defined by replacing the Fibonacci recurrence with linearly increasing increments:

**Definition 1.1.** The anti-Fibonacci sequence a : ℕ → ℕ is defined by:
- a(0) = 1
- a(1) = 1  
- a(n+2) = a(n+1) + (n+1)

The first several terms are: 1, 1, 2, 4, 7, 11, 16, 22, 29, 37, 46, 56, 67, 79, 92, 106, ...

### 1.1 Motivation

The sequence arises naturally from the question: "What is the simplest recurrence that produces quadratic growth?" While the Fibonacci recurrence a(n+2) = a(n+1) + a(n) feeds back the sequence into itself (producing exponential growth), our recurrence a(n+2) = a(n+1) + (n+1) feeds the *index* into the sequence (producing polynomial growth). This substitution — replacing a(n) with n+1 in the recurrence — is the minimal perturbation that changes the growth character from exponential to polynomial.

### 1.2 Novel Concepts

We introduce two new concepts for analyzing sequences relative to the Fibonacci recurrence:

**Definition 1.2 (Fibonacci avoidance).** A sequence a : ℕ → ℕ is *Fibonacci-avoidant at position n* if a(n+2) ≠ a(n+1) + a(n). It is *Fibonacci-avoidant* if this holds at all positions, and *eventually Fibonacci-avoidant from N* if it holds at all positions n ≥ N.

**Definition 1.3 (Fibonacci defect).** The *Fibonacci defect* of a sequence a at position n is the integer d(n) = a(n+2) − a(n+1) − a(n). This measures the signed deviation from the Fibonacci recurrence, with d(n) > 0 indicating "faster than Fibonacci" growth and d(n) < 0 indicating "slower than Fibonacci" growth.

## 2. Main Results

### 2.1 Closed Form

**Theorem 2.1** (Closed form). For all n ∈ ℕ, 2 · a(n) = n(n−1) + 2, equivalently a(n) = n(n−1)/2 + 1.

*Proof sketch.* By strong induction on n. The base cases n = 0, 1 are immediate. For the inductive step, 2·a(n+2) = 2·(a(n+1) + (n+1)) = (n+1)n + 2 + 2(n+1) = (n+1)(n+2) + 2 = (n+2)((n+2)−1) + 2. □

**Corollary 2.2.** The anti-Fibonacci sequence grows as Θ(n²). Specifically, n(n−1)/2 + 1 ≤ a(n) ≤ n² for all n ≥ 1.

### 2.2 Monotonicity

**Theorem 2.3** (Strict monotonicity). For n ≥ 1, a(n) < a(n+1). The difference a(n+2) − a(n+1) = n+1 grows linearly.

*Proof sketch.* From the recurrence, a(n+2) − a(n+1) = n+1 > 0 for all n ≥ 0. For n = 0: a(1) = a(0) = 1. □

Note that a(0) = a(1) = 1, so strict monotonicity fails at the very first position. The sequence is merely monotone (non-decreasing) in general, and strictly increasing from position 1 onward.

### 2.3 The Anti-Fibonacci Property

**Theorem 2.4** (Anti-Fibonacci inequality). For n ≥ 4, a(n+2) < a(n+1) + a(n).

*Proof sketch.* From the closed form, 2·a(n+2) = (n+2)(n+1) + 2 = n² + 3n + 4, while 2·(a(n+1) + a(n)) = (n+1)n + n(n−1) + 4 = 2n² + 4. The inequality n² + 3n + 4 < 2n² + 4 reduces to 3n < n², which holds for n ≥ 4. □

**Theorem 2.5** (Exact coincidence characterization). a(n+2) = a(n+1) + a(n) if and only if n ∈ {0, 3}.

*Proof sketch.* The equality 2·a(n+2) = 2·(a(n+1) + a(n)) reduces to n² + 3n + 4 = 2n² + 4, i.e., n² = 3n, yielding n = 0 or n = 3. For n = 0: a(2) = 2 = 1 + 1 = a(1) + a(0). For n = 3: a(5) = 11 = 7 + 4 = a(4) + a(3). □

This theorem is particularly striking: among infinitely many positions, the anti-Fibonacci sequence "accidentally" satisfies the Fibonacci recurrence at exactly two isolated points.

### 2.4 The Fibonacci Defect

**Theorem 2.6** (Defect formula). The Fibonacci defect of the anti-Fibonacci sequence at position n is d(n) = n(3−n)/2.

*Proof sketch.* 2d(n) = 2a(n+2) − 2a(n+1) − 2a(n) = (n²+3n+4) − (n²+n+2) − (n²−n+2) = −n²+3n = n(3−n). □

**Corollary 2.7.** For n ≥ 4, d(n) < 0, confirming that the anti-Fibonacci sequence grows slower than Fibonacci from this point onward. The magnitude |d(n)| ∼ n²/2 grows quadratically.

The defect function is a parabola opening downward with roots at n = 0 and n = 3, achieving its maximum d(1) = d(2) = 1 at n = 1, 2.

### 2.5 Fibonacci Domination

**Theorem 2.8** (Polynomial-exponential separation). For n ≥ 12, a(n) < F(n), where F is the standard Fibonacci sequence.

*Proof sketch.* By induction. The base case a(12) = 67 < 144 = F(12) is verified computationally. For the inductive step, a(n+1) = a(n) + n ≤ n² + n (by the quadratic upper bound), while F(n+1) = F(n) + F(n−1) ≥ F(n) + F(n−1). Since F grows exponentially and a grows quadratically, the gap F(n) − a(n) increases monotonically for large n. □

## 3. The Fibonacci Avoidance Framework

### 3.1 General Theory

The concepts of Fibonacci avoidance and the Fibonacci defect apply to any integer sequence, not just the anti-Fibonacci sequence.

**Definition 3.1.** Let Seq = (ℕ → ℕ) denote the space of sequences. Define:
- FibAvoid = {a ∈ Seq : ∀n, a(n+2) ≠ a(n+1) + a(n)} (fully avoidant sequences)
- FibAvoid≥N = {a ∈ Seq : ∀n ≥ N, a(n+2) ≠ a(n+1) + a(n)} (eventually avoidant)

The anti-Fibonacci sequence belongs to FibAvoid≥4 but not to FibAvoid (it fails at n = 0 and n = 3).

### 3.2 The Greedy Avoidant Sequence

For comparison, consider the *greedy Fibonacci-avoidant sequence*: the lexicographically smallest increasing sequence starting at 1, 1 that belongs to FibAvoid. This sequence is 1, 1, 3, 5, 6, 7, 8, 9, 10, 11, ..., which grows linearly. After the initial jump from 1 to 3 (avoiding 1+1=2), every subsequent term is just one more than the previous, since the sum of the two predecessors always exceeds the next candidate by more than 1.

This shows that Fibonacci avoidance alone does not force quadratic growth — linear growth suffices if one is willing to make large jumps at the beginning.

## 4. Algorithms

### 4.1 Direct Computation

The anti-Fibonacci sequence can be computed in O(1) per term using the closed form:

```
FUNCTION antiFib(n):
    RETURN n * (n - 1) / 2 + 1
```

### 4.2 Fibonacci Defect Computation

```
FUNCTION fibDefect(n):
    RETURN n * (3 - n) / 2
```

### 4.3 Avoidance Checking

Given any sequence a, determine whether it is Fibonacci-avoidant up to position N:

```
FUNCTION checkAvoidance(a, N):
    FOR n = 0 TO N:
        IF a[n+2] == a[n+1] + a[n]:
            RETURN (False, n)
    RETURN (True, -1)
```

## 5. Discussion

### 5.1 The Spectrum of Growth Rates

The Fibonacci and anti-Fibonacci sequences represent two extremes of a continuum. Consider the family of recurrences:

a_α(n+2) = a_α(n+1) + f_α(n)

where f_α interpolates between a_α(n) (giving Fibonacci-like exponential growth) and n+1 (giving anti-Fibonacci quadratic growth). The parameter α controls whether the recurrence is self-referential (exponential) or index-driven (polynomial).

### 5.2 Connections to Known Sequences

The anti-Fibonacci sequence a(n) = n(n−1)/2 + 1 is closely related to:
- **Triangular numbers**: T(n) = n(n+1)/2. We have a(n) = T(n−1) + 1.
- **Central polygonal numbers**: The sequence 1, 2, 4, 7, 11, 16, ... (without the repeated initial 1) appears in OEIS as A000124, the "lazy caterer's sequence" counting the maximum number of pieces a disk can be cut into with n straight cuts.
- **Binomial coefficients**: a(n) = C(n,2) + 1 for n ≥ 2.

### 5.3 The Defect as a Diagnostic Tool

The Fibonacci defect provides a quantitative framework for measuring how "Fibonacci-like" any sequence is. Natural applications include:
- **Population dynamics**: Comparing observed population growth to the Fibonacci ideal.
- **Financial time series**: Measuring departure from self-similar growth.
- **Combinatorial sequences**: Classifying sequences by their defect profile.

## 6. Conjectures and Open Questions

**Conjecture 6.1** (Growth optimality). Among all increasing sequences starting with (1, 1) that are eventually Fibonacci-avoidant, the anti-Fibonacci sequence has the smallest growth rate among those with a polynomial closed form of the shape n²/c + O(n).

**Conjecture 6.2** (Defect universality). For any sequence a with a(n) = Θ(n^k) for some k > 0, the Fibonacci defect satisfies |d(n)| = Θ(n^max(k, 2k−2)).

**Open Question 6.3.** Characterize all increasing sequences a : ℕ → ℕ with the property that a satisfies the Fibonacci recurrence at exactly a finite, prescribed set S of positions. For which finite sets S ⊆ ℕ does such a sequence exist?

## 7. Formal Verification

All theorems in Sections 2–3 have been formally verified in Lean 4 using the Mathlib library. The formalization comprises:

| Theorem | Lean Name | Key Technique |
|---------|-----------|---------------|
| Closed form | `two_mul_antiFib` | Strong induction |
| Anti-Fibonacci inequality | `antiFib_lt_fib_sum` | Arithmetic reduction + `omega` |
| Coincidence characterization | `antiFib_eq_fib_sum_iff` | Quadratic equation solving |
| Defect formula | `antiFib_defect_formula` | Integer arithmetic |
| Fibonacci domination | `antiFib_lt_fib` | Induction with base case verification |

The formalization also includes the novel definitions of `IsFibAvoidant`, `IsEventuallyFibAvoidant`, and `fibDefect` as reusable predicates for analyzing arbitrary sequences.

## 8. Conclusion

The anti-Fibonacci sequence provides a clean, elegant example of how changing a single ingredient in a famous recurrence — replacing self-reference with index-reference — fundamentally alters the growth character from exponential to polynomial. The Fibonacci defect, introduced here as a general diagnostic tool, quantifies this departure precisely. The exact characterization of the two coincidence points (n = 0 and n = 3) demonstrates that even simple polynomial sequences can have subtle, non-obvious interactions with the Fibonacci recurrence.

## References

1. Koshy, T. (2001). *Fibonacci and Lucas Numbers with Applications*. Wiley.
2. Vorobiev, N. N. (2002). *Fibonacci Numbers*. Birkhäuser.
3. Sloane, N. J. A. (2024). OEIS A000124 — Central polygonal numbers. *The On-Line Encyclopedia of Integer Sequences*.
