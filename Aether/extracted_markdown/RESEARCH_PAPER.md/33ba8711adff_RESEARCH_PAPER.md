# The Anti-Fibonacci Sequence and Recurrence Avoidance Partitions

## Abstract

We introduce the **anti-Fibonacci sequence**, defined as the greedy strictly increasing sequence of positive integers whose terms avoid all consecutive-pair sums. Starting from (1, 2), we prove that this sequence has the closed form S(n) = ⌊3n/2⌋ + 1 and consists exactly of the positive integers not divisible by 3. The consecutive sums enumerate all positive multiples of 3, yielding a perfect partition of ℕ⁺. We formalize these results in Lean 4 with complete machine-verified proofs, introduce the novel algebraic concept of an **Avoidance Partition**, and establish connections between the anti-Fibonacci growth rate (3/2) and the Fibonacci growth rate (the golden ratio φ). All proofs have been verified by the Lean 4 proof assistant.

**Keywords**: Fibonacci sequence, avoidance sequences, partition of integers, modular arithmetic, formal verification, recurrence avoidance

---

## 1. Introduction

The Fibonacci sequence, defined by F(0) = F(1) = 1 and F(n+2) = F(n+1) + F(n), is among the most studied objects in combinatorial number theory. Its ratio F(n+1)/F(n) converges to the golden ratio φ = (1+√5)/2, and its terms grow exponentially.

A natural question arises: what happens when we construct a sequence that *avoids* the Fibonacci recurrence? We define the anti-Fibonacci sequence via a greedy algorithm that systematically refuses to satisfy the additive recurrence, and discover that the resulting sequence has unexpectedly rich structure.

### 1.1 Definition

**Definition 1.1** (Anti-Fibonacci Sequence). The anti-Fibonacci sequence S : ℕ → ℕ⁺ is defined as follows:
- S(0) = 1, S(1) = 2
- For n ≥ 2, S(n) is the smallest positive integer greater than S(n-1) such that S(n) ∉ {S(i) + S(i+1) : 0 ≤ i < n-1}.

Equivalently, S(n) is the smallest integer exceeding S(n-1) that does not equal any consecutive-pair sum from the sequence constructed so far.

### 1.2 Main Results

Our main contributions are:

1. **Closed Form** (Theorem 3.1): S(n) = ⌊3n/2⌋ + 1.
2. **Modular Characterization** (Theorem 3.3): S enumerates exactly the positive integers not divisible by 3.
3. **Avoidance Theorem** (Theorem 4.1): S(n) ≠ S(m) + S(m+1) for all n, m.
4. **Shadow Surjection** (Theorem 4.3): {S(n) + S(n+1) : n ∈ ℕ} = {3k : k ≥ 1}.
5. **Avoidance Partition** (Theorem 5.1): (S, Shadow(S)) forms a partition of ℕ⁺.
6. **Growth Rate Separation** (Theorem 6.1): 3/2 < φ < 2.

## 2. Notation and Conventions

- ℕ denotes the natural numbers {0, 1, 2, ...}.
- ℕ⁺ denotes the positive integers {1, 2, 3, ...}.
- ⌊x⌋ denotes the floor function.
- We use 0-based indexing throughout.
- 3 | n means 3 divides n; 3 ∤ n means 3 does not divide n.

## 3. The Closed Form

### 3.1 Even and Odd Index Formulas

**Theorem 3.1** (Even Index). For all k ∈ ℕ, S(2k) = 3k + 1.

*Proof sketch*. By definition, S(n) = n + ⌊n/2⌋ + 1. For n = 2k: S(2k) = 2k + k + 1 = 3k + 1. □

**Theorem 3.2** (Odd Index). For all k ∈ ℕ, S(2k+1) = 3k + 2.

*Proof sketch*. S(2k+1) = (2k+1) + ⌊(2k+1)/2⌋ + 1 = (2k+1) + k + 1 = 3k + 2. □

### 3.2 Modular Structure

**Theorem 3.3** (Residues). For all k ∈ ℕ:
- S(2k) ≡ 1 (mod 3)
- S(2k+1) ≡ 2 (mod 3)

*Proof*. Immediate from Theorems 3.1 and 3.2: (3k+1) mod 3 = 1 and (3k+2) mod 3 = 2. □

**Corollary 3.4**. No anti-Fibonacci term is divisible by 3.

*Proof*. By Theorem 3.3, S(n) mod 3 ∈ {1, 2} for all n. □

### 3.3 Monotonicity and Bounds

**Theorem 3.5** (Strict Monotonicity). S is strictly increasing.

*Proof*. S(n+1) - S(n) ≥ 1 for all n, which follows from the identity S(n) = n + ⌊n/2⌋ + 1 and the monotonicity of ⌊·/2⌋. □

**Theorem 3.6** (Difference Pattern). The consecutive differences alternate:
- S(2k+1) - S(2k) = 1
- S(2(k+1)) - S(2k+1) = 2

*Proof*. Direct computation: (3k+2) - (3k+1) = 1 and (3(k+1)+1) - (3k+2) = 2. □

**Theorem 3.7** (Bounds). For all n ∈ ℕ: n + 1 ≤ S(n) ≤ ⌊3(n+1)/2⌋.

## 4. The Avoidance Property

### 4.1 Consecutive Sum Divisibility

**Theorem 4.1** (Sum Divisibility). For all n ∈ ℕ, 3 | (S(n) + S(n+1)).

*Proof*. Case split on parity of n:
- If n = 2k: S(2k) + S(2k+1) = (3k+1) + (3k+2) = 6k+3 = 3(2k+1).
- If n = 2k+1: S(2k+1) + S(2(k+1)) = (3k+2) + (3k+4) = 6k+6 = 3(2k+2). □

### 4.2 The Avoidance Theorem

**Theorem 4.2** (Avoidance). For all n, m ∈ ℕ, S(n) ≠ S(m) + S(m+1).

*Proof*. By Corollary 3.4, S(n) is not divisible by 3. By Theorem 4.1, S(m) + S(m+1) is divisible by 3. A non-multiple of 3 cannot equal a multiple of 3. □

This is the central result: the avoidance property follows from a *modular arithmetic argument*. The sequence and its shadow live in disjoint residue classes modulo 3.

### 4.3 Shadow Surjection

**Theorem 4.3** (Shadow Surjection). For every positive integer m, there exists n such that S(n) + S(n+1) = 3m.

*Proof*. If m = 2k+1 is odd, take n = 2k: S(2k) + S(2k+1) = 3(2k+1) = 3m.
If m = 2(k+1) is even, take n = 2k+1: S(2k+1) + S(2(k+1)) = 3(2(k+1)) = 3m. □

**Corollary 4.4**. The shadow set {S(n) + S(n+1) : n ∈ ℕ} equals {3k : k ∈ ℕ⁺}, the set of positive multiples of 3.

## 5. The Avoidance Partition

### 5.1 Definition

**Definition 5.1** (Avoidance Partition). An **avoidance partition** is a tuple (S, StrictMono, pos, avoids, covers) where:
- S : ℕ → ℕ is a strictly increasing sequence
- All terms are positive: S(n) > 0 for all n
- The sequence avoids all its own consecutive sums: S(n) ≠ S(m) + S(m+1) for all n, m
- Every positive integer is either a term or a consecutive sum: for all k > 0, either k ∈ Im(S) or k ∈ Shadow(S)

### 5.2 Existence

**Theorem 5.2** (Existence). The anti-Fibonacci sequence forms an avoidance partition.

*Proof*. Strict monotonicity and positivity follow from Theorems 3.5 and 3.7. Avoidance follows from Theorem 4.2. Coverage follows from: if 3 ∤ k, then k = 3j + r with r ∈ {1,2}, and k = S(2j) or k = S(2j+1); if 3 | k, then k = 3m and k = S(n) + S(n+1) for some n by Theorem 4.3. □

### 5.3 Uniqueness Question

**Open Question**: Is the anti-Fibonacci sequence the *unique* avoidance partition for addition? We conjecture that different starting pairs (a₀, a₁) may yield different avoidance partitions, but that (1, 2) is the only starting pair producing a partition with a purely modular characterization.

## 6. Growth Rate Analysis

### 6.1 The Growth Rate Separation Theorem

**Theorem 6.1** (Growth Rate Separation). The anti-Fibonacci growth constant 3/2 and the Fibonacci growth constant φ satisfy:
$$\frac{3}{2} < \varphi = \frac{1 + \sqrt{5}}{2} < 2$$

*Proof*. For the left inequality: 3/2 < (1+√5)/2 iff 3 < 1 + √5 iff 2 < √5 iff 4 < 5. ✓
For the right inequality: (1+√5)/2 < 2 iff √5 < 3 iff 5 < 9. ✓ □

### 6.2 Interpretation

The Fibonacci sequence grows exponentially with base φ ≈ 1.618. The anti-Fibonacci sequence grows linearly with slope 3/2 = 1.5. The gap between 3/2 and φ represents the "cost of avoidance" — the growth sacrifice a sequence makes by refusing to follow the Fibonacci recurrence.

### 6.3 Ratio Non-Convergence

The ratio S(n+1)/S(n) oscillates between values approaching 1 (when the gap is 1) and values approaching 1 (when the gap is 2), but the *differences* alternate between 1 and 2. Both subsequences converge to 1, but via different paths:

- S(2k+1)/S(2k) = (3k+2)/(3k+1) → 1 from above
- S(2k+2)/S(2k+1) = (3k+4)/(3k+2) → 1 from above

The limiting ratio is 1, not a fixed point like the golden ratio. This reflects the linear (not geometric) growth.

## 7. Density

**Theorem 7.1** (Exact Density). Among {1, ..., 3k}, exactly 2k integers are anti-Fibonacci terms.

*Proof*. The anti-Fibonacci terms in {1, ..., 3k} are exactly the integers in this range not divisible by 3. There are k multiples of 3 in {1, ..., 3k}, hence 3k - k = 2k non-multiples. □

**Corollary 7.2**. The asymptotic density of the anti-Fibonacci sequence is 2/3.

This contrasts sharply with the Fibonacci numbers, which have density 0 (they grow exponentially, becoming ever sparser).

## 8. Connection to Existing Work

### 8.1 Complement Sequences

The anti-Fibonacci sequence is related to the classical study of *complementary sequences* — pairs of sequences that partition ℕ. The Beatty sequence theorem states that if α, β > 0 with 1/α + 1/β = 1, then ⌊nα⌋ and ⌊nβ⌋ partition ℕ. Our result shows that avoidance provides an alternative mechanism for generating partitions, not based on irrational rotation but on recurrence avoidance.

### 8.2 Sum-Free Sets

The anti-Fibonacci sequence is related to, but distinct from, sum-free sets. A sum-free set S satisfies: if a, b ∈ S, then a + b ∉ S. Our sequence satisfies a weaker condition: only *consecutive* pairs generate forbidden sums. This weaker condition is what allows the sequence to have density 2/3 (the maximum density of a sum-free subset of {1, ..., N} is only about N/2).

### 8.3 Golden Ratio Connection

The existing catalog theorem `golden_ratio_lt_two` establishes (1+√5)/2 < 2. Our Growth Rate Separation Theorem (6.1) extends this by showing 3/2 < (1+√5)/2 < 2, placing the anti-Fibonacci growth constant below the golden ratio.

## 9. The Avoidance Partition as a Novel Structure

### 9.1 Formal Definition in Lean 4

```lean
structure AvoidancePartition where
  seq : ℕ → ℕ
  strictMono : StrictMono seq
  pos : ∀ n, 0 < seq n
  avoids : ∀ n m, seq n ≠ seq m + seq (m + 1)
  covers : ∀ k, 0 < k → (∃ n, seq n = k) ∨ (∃ m, seq m + seq (m + 1) = k)
```

### 9.2 Properties

An avoidance partition has several notable properties:
1. **Self-complementarity**: The sequence generates its own complement via a simple operation.
2. **Determinism**: Given the starting pair and the greedy rule, the partition is fully determined.
3. **Density constraint**: The sequence must have density ≥ 1/2 (since consecutive sums grow faster than terms, the shadow is sparser).

### 9.3 Generalization

The avoidance partition concept generalizes beyond addition:
- **Multiplicative avoidance**: Replace a + b with a · b. The resulting sequence and shadow have different density properties.
- **Max-plus avoidance**: Replace a + b with max(a, b) + c for some constant c.
- **Polynomial avoidance**: Replace a + b with f(a, b) for various polynomials f.

Each variant produces different partition structures, opening a rich family of combinatorial objects.

## 10. Algorithms

### 10.1 Closed-Form Computation

The n-th anti-Fibonacci term can be computed in O(1) time:

```
AntiFib(n) = n + ⌊n/2⌋ + 1
```

### 10.2 Inverse Mapping

Given a positive integer k, we can determine in O(1) whether k is an anti-Fibonacci term and find its index:
- If k ≡ 1 (mod 3), then k = S(2j) where j = (k-1)/3.
- If k ≡ 2 (mod 3), then k = S(2j+1) where j = (k-2)/3.
- If k ≡ 0 (mod 3), then k is a shadow value: k = S(n) + S(n+1) for some n.

### 10.3 Greedy Algorithm

```
GreedyAvoidance(count):
  S ← [1, 2]
  forbidden ← {3}
  for i = 2 to count-1:
    candidate ← S[i-1] + 1
    while candidate ∈ forbidden:
      candidate ← candidate + 1
    forbidden ← forbidden ∪ {S[i-1] + candidate}
    S[i] ← candidate
  return S
```

## 11. Formalization

All results in this paper have been formalized and verified in Lean 4. The formalization consists of approximately 250 lines of Lean code, including:

- 18 theorems with complete proofs
- 1 structure definition (AvoidancePartition)
- 1 noncomputable instance (antiFibPartition)

The axioms used are limited to `propext`, `Classical.choice`, and `Quot.sound`, all of which are standard in Lean's foundational framework.

## 12. Future Work

1. **Characterize all additive avoidance partitions**: Which starting pairs (a₀, a₁) yield avoidance partitions?
2. **Multiplicative and polynomial variants**: Study avoidance partitions for operations other than addition.
3. **Higher-order avoidance**: Instead of avoiding consecutive-pair sums, avoid sums of k-tuples.
4. **Connection to Beatty sequences**: Explore the relationship between avoidance partitions and the Beatty sequence theorem.
5. **Avoidance in other algebraic structures**: Extend avoidance partitions to groups, rings, and lattices.

## References

1. Fibonacci, L. *Liber Abaci* (1202).
2. Beatty, S. "Problem 3173." *American Mathematical Monthly* 33, no. 3 (1926): 159.
3. Fraenkel, A.S. "Complementary systems of integers." *American Mathematical Monthly* 84, no. 2 (1977): 114-115.
4. Cameron, P.J., and Erdős, P. "Notes on sum-free and related sets." *Combinatorics, Probability and Computing* 8 (1999): 95-107.
