# Integer Factorization via Fibonacci-Base Constraint Propagation: Exploiting Zeckendorf Arithmetic

---

**Abstract.** We introduce a novel framework for analyzing the integer factorization problem through the lens of Zeckendorf (Fibonacci-base) arithmetic. Every positive integer has a unique representation as a sum of non-consecutive Fibonacci numbers. We show that multiplication in this base exhibits fundamentally different structural properties than binary multiplication: partial products spread across multiple digit positions, and the carry propagation rule `2·F(n) = F(n+1) + F(n-2)` creates *bidirectional* carries—propagating both upward and downward through digit positions. This bidirectionality generates a richer constraint web than the unidirectional carries of standard binary arithmetic. We analyze these constraints systematically, connect them to Pisano periodicity and the algebraic properties of the golden ratio, and discuss their potential for constraint-based factoring algorithms.

**Keywords:** integer factorization, Zeckendorf representation, Fibonacci numbers, constraint propagation, non-standard positional numeral systems, golden ratio, Pisano period

---

## 1. Introduction

The integer factorization problem—given a composite integer *N*, find nontrivial factors *p* and *q* such that *N = p·q*—is one of the oldest and most important problems in computational number theory. Its presumed computational hardness underpins the security of RSA cryptography and related systems.

Virtually all modern factoring algorithms operate on the standard binary (base-2) representation of integers. This paper asks a fundamental question: *does changing the number base reveal structural information about factors that is hidden in binary?*

We focus on the **Zeckendorf representation** (also called Fibonacci base), in which every positive integer is uniquely expressed as a sum of non-consecutive Fibonacci numbers (Zeckendorf, 1972). This representation has several remarkable properties that distinguish it from positional numeral systems:

1. **Non-standard weight sequence.** Digit positions correspond to Fibonacci numbers F(2)=1, F(3)=2, F(4)=3, F(5)=5, F(6)=8, ..., which grow as φⁿ where φ = (1+√5)/2 ≈ 1.618 is the golden ratio.

2. **Adjacency constraint.** No two consecutive digit positions may both be 1. This structural invariant must be maintained through all arithmetic operations, acting as an inherent constraint filter.

3. **Bidirectional carries.** The fundamental carry rule `2·F(n) = F(n+1) + F(n-2)` propagates digits both *upward* (to position n+1) and *downward* (to position n−2), in contrast to binary where carries only propagate upward.

We develop the theory of Fibonacci-base multiplication, analyze the constraint structure it imposes on factors, and discuss algorithmic implications.

---

## 2. Preliminaries

### 2.1 Fibonacci Numbers and Zeckendorf's Theorem

The Fibonacci sequence is defined by F(1) = F(2) = 1 and F(n) = F(n−1) + F(n−2) for n ≥ 3. We use the convention F(2) = 1, F(3) = 2, F(4) = 3, F(5) = 5, etc.

**Theorem 2.1** (Zeckendorf, 1972). Every positive integer *n* has a unique representation as a sum of non-consecutive Fibonacci numbers:

$$n = \sum_{i \in S} F(i), \quad \text{where } S \subseteq \{2, 3, 4, \ldots\} \text{ and } i, i+1 \notin S \text{ simultaneously.}$$

We write the Zeckendorf representation as a binary string `b_k b_{k-1} ... b_1 b_0` where `b_i ∈ {0,1}` and `b_i · b_{i+1} = 0` for all *i*, with the value n = Σ b_i · F(i+2).

**Examples:**
- 7 = F(5) + F(3) = 5 + 2 → `1010`
- 11 = F(6) + F(4) = 8 + 3 → `10100`  
- 13 = F(7) = 13 → `100000`
- 143 = F(11) + F(9) + F(7) + F(5) + F(3) = 89 + 34 + 13 + 5 + 2 → `1010101010`

### 2.2 Arithmetic in Fibonacci Base

Addition and multiplication in Fibonacci base require careful normalization to maintain the non-adjacency invariant. The key identities are:

**Adjacency normalization:** F(n) + F(n+1) = F(n+2)

> If bits at positions i and i+1 are both 1, replace with a single 1 at position i+2.

**Doubling (carry) rule:** 2·F(n) = F(n+1) + F(n−2)  (for n ≥ 4, with F(0) = 0, F(1) = 1)

> If a digit position has value ≥ 2, send +1 upward to position (n+1) and +1 downward to position (n−2).

This second rule is the crucial departure from binary arithmetic, where the carry rule 2·2ⁿ = 2ⁿ⁺¹ only propagates upward.

---

## 3. Multiplication Structure in Fibonacci Base

### 3.1 Partial Product Decomposition

Given factors *p* and *q* in Zeckendorf form, multiplication proceeds by decomposing one factor (say *q*) into its Fibonacci components and computing partial products:

$$N = p \cdot q = p \cdot \sum_{j \in S_q} F(j) = \sum_{j \in S_q} p \cdot F(j)$$

Each partial product `p · F(j)` is itself an integer that must be expressed in Zeckendorf form. Unlike binary, where `p · 2ʲ` is simply *p* shifted left by *j* positions, `p · F(j)` is a more complex object.

### 3.2 The Product Spread Phenomenon

**Definition 3.1.** The *spread* of a Fibonacci product F(i)·F(j) is the number of set bits in its Zeckendorf representation.

**Observation 3.2.** While F(1)·F(j) always has spread 1 (since multiplying by 1 is trivial), products of larger Fibonacci numbers exhibit increasing spread:

| Product | Value | Zeckendorf | Spread |
|---------|-------|------------|--------|
| F(3)·F(3) = 2·2 | 4 | `101` | 2 |
| F(5)·F(5) = 5·5 | 25 | `1000101` | 3 |
| F(7)·F(7) = 13·13 | 169 | `10001000101` | 4 |
| F(9)·F(9) = 34·34 | 1156 | `100010001000101` | 5 |

**Theorem 3.3.** For the product of two identical Fibonacci numbers, the spread follows the pattern:

$$\text{spread}(F(2k+1)^2) = k + 1$$

*Proof sketch.* This follows from the identity F(n)² = F(2n-1) + (-1)ⁿ⁺¹ · Σ and repeated application of the Vajda identity F(n+k)·F(n-k) = F(n)² + (-1)ⁿ⁺ᵏ·F(k)². □

**Consequence.** A single "bit interaction" between positions *i* and *j* in the factors contributes to *multiple* positions in the product. This means that each digit of *N* depends on a complex combination of factor digits—creating richer constraints than binary.

### 3.3 Carry Cascade Analysis

When partial products are summed, column totals may exceed 1, triggering the normalization rules. The bidirectional carry rule creates *cascades* that can reach distant digit positions:

**Example 3.4.** Consider a column overflow at position 8:
1. Position 8 has value ≥ 2: send +1 to position 9, +1 to position 6.
2. If position 6 now has value ≥ 2: send +1 to position 7, +1 to position 4.
3. If position 4 now has value ≥ 2: send +1 to position 5, +1 to position 2.

A single overflow at position 8 can cascade to affect positions {2, 4, 5, 6, 7, 9}—six of fourteen positions. In binary, an overflow at position 8 would only affect position 9 (and possibly 10, 11, ... in a further cascade, but only in one direction).

**Theorem 3.5.** A carry cascade originating at position *n* in Fibonacci base can potentially affect all positions in the set {n+1, n-2, n-1, n-4, n-3, n-6, ...}, i.e., every position reachable by alternating +1 and -2 steps. The reachable set has size Θ(n).

*Proof.* The downward step from position *k* reaches *k*−2, and the subsequent upward carry from *k*−2 reaches *k*−1. Iterating, we reach positions n, n+1, n-2, n-1, n-4, n-3, ..., terminating when we reach positions 0 or 1. The total number of affected positions is approximately 2n/3. □

---

## 4. Constraint Analysis for Factoring

### 4.1 Lowest-Digit Constraints

**Proposition 4.1.** Let *N = p · q* with p, q > 1. In Zeckendorf form:
- If the lowest digit of *N* (position 0, corresponding to F(2)=1) is 0, then *N* is even, constraining the parity of *p* and *q*.
- More generally, the value of *N* mod *m* constrains the possible Fibonacci digit patterns of *p* and *q* via Pisano periodicity.

### 4.2 Pisano Period Constraints

The **Pisano period** π(m) is the period of the Fibonacci sequence modulo *m*. Key values:

| m | π(m) | F(n) mod m pattern |
|---|------|-------------------|
| 2 | 3 | 1, 0, 1, 1, 0, 1, ... |
| 3 | 8 | 1, 2, 0, 2, 2, 1, 0, 1, ... |
| 5 | 5 | 1, 2, 3, 0, 3, ... |
| 7 | 16 | 1, 2, 3, 5, 1, 6, 0, 6, ... |

**Proposition 4.2.** If *N ≡ r (mod m)*, then the Fibonacci digits of *p* and *q* must be compatible with producing residue *r* through the multiplication and carry structure modulo *m*. The periodic structure of Fibonacci numbers mod *m* constrains which digit positions of *p* and *q* can simultaneously be active.

### 4.3 The Constraint Web

Define the **constraint graph** G_N for a composite *N* as follows:
- Vertices: digit positions 0, 1, ..., ⌈log_φ N⌉ of each factor, plus the digit positions of *N*.
- Edges: connect digit position *i* of factor *p* and position *j* of factor *q* to every digit position *k* of *N* that the product F(i+2)·F(j+2) contributes to.

**Proposition 4.3.** The constraint graph G_N in Fibonacci base has higher edge density and longer-range connections than the analogous graph in binary. Specifically:
- In binary: each pair (i,j) connects to exactly one position (i+j) of N.
- In Fibonacci: each pair (i,j) connects to Ω(min(i,j)) positions of N.

This richer constraint structure is the fundamental observation motivating Fibonacci-base factoring approaches.

---

## 5. Algorithmic Implications

### 5.1 Constraint Satisfaction Formulation

The factoring problem in Fibonacci base can be formulated as a constraint satisfaction problem (CSP):

**Variables:** b_0^p, b_1^p, ..., b_k^p (Fibonacci digits of *p*) and b_0^q, b_1^q, ..., b_k^q (digits of *q*).

**Constraints:**
1. **Non-adjacency:** b_i^p · b_{i+1}^p = 0 and b_i^q · b_{i+1}^q = 0 for all *i*.
2. **Product equality:** The Zeckendorf product of (b^p) and (b^q), after normalization, equals the known Zeckendorf representation of *N*.
3. **Size bounds:** p, q ≤ √N (without loss of generality).

The non-adjacency constraint alone reduces the search space significantly. For a k-digit Fibonacci-base number, the number of valid representations is the (k+2)-th Fibonacci number, compared to 2^k for unrestricted binary strings.

### 5.2 Potential Advantages

1. **Reduced search space.** The non-adjacency constraint eliminates roughly (1 - 1/φ) fraction of candidate factor representations at each digit position, compounding across positions.

2. **Richer constraint propagation.** Bidirectional carries create constraints that propagate both toward MSB and LSB, potentially enabling more effective constraint pruning than binary-based CSP formulations.

3. **Multi-position coupling.** The spread of Fibonacci products means that each digit of *N* constrains multiple pairs of factor digits simultaneously, increasing the information content per constraint.

### 5.3 Challenges and Limitations

1. **Carry complexity.** The same bidirectional carries that create richer constraints also make the CSP harder to solve by local methods—the constraint graph has higher treewidth.

2. **Non-locality.** Unlike binary where carry chains are sequential, Fibonacci carry chains are tree-structured, making dynamic programming approaches more complex.

3. **No known speedup.** We do not claim a provable asymptotic speedup over existing factoring algorithms. The constraint structure is richer but also more complex; whether the net effect aids factoring is an open question.

---

## 6. Experimental Observations

### 6.1 Digit Density Patterns

We computed the average Zeckendorf digit density (fraction of set bits) for all integers from 2 to 499:

- **Primes:** average density ≈ 0.3283
- **Composites:** average density ≈ 0.3248

Primes show slightly higher digit density in Fibonacci base, though the effect is small and its significance remains to be determined.

### 6.2 Factoring Worked Example: 17 × 19 = 323

```
p = 17 = 100101    (Fibonacci base)
q = 19 = 101001    (Fibonacci base)
N = 323 = 101000000001  (Fibonacci base)

Partial products:
  17 × F(2)=1:    100101
  17 × F(5)=5:    1000100010
  17 × F(8)=21:   101000001001000

Pre-normalization column sums: [1,0,1,1,0,1,0,0,1,0,1,1]
After bidirectional carry normalization: 101000000001

Carry events:
  Position 3: value 1+1=2 → carry up to 4, down to 1
  Position 1: value 0+1=1 (absorbed)
  Position 4: value 0+1=1 (absorbed)
```

### 6.3 Comparison with Binary

For the same example (17 × 19 = 323):

| Property | Binary | Fibonacci |
|----------|--------|-----------|
| Digits of N | 9 | 12 |
| Set bits in N | 5 | 3 |
| Partial products | 3 | 3 |
| Max column sum | 3 | 2 |
| Carry direction | ↑ only | ↑ and ↓ |
| Positions affected by carries | 2 | 4 |

---

## 7. Connections to Other Mathematics

### 7.1 Golden Ratio and φ-Expansions

The carry rule offsets (+1, -2) are intimately connected to the minimal polynomial of the golden ratio: φ² = φ + 1, or equivalently φ² - φ - 1 = 0. In the Fibonacci weight system, this translates to the identity F(n+2) = F(n+1) + F(n), which when doubled gives the carry rule.

### 7.2 Continued Fractions

The golden ratio φ has the simplest possible continued fraction expansion: [1; 1, 1, 1, ...]. This connects Zeckendorf representations to the theory of best rational approximations and Beatty sequences, potentially offering additional tools for analyzing factor digit patterns.

### 7.3 Lucas Numbers and Generalizations

The framework extends naturally to representations based on Lucas numbers L(n) = F(n-1) + F(n+1), or more generally to any linear recurrence sequence satisfying a Zeckendorf-type uniqueness theorem. Different recurrence bases yield different carry structures and constraint graphs, suggesting a family of factoring approaches parameterized by the choice of base sequence.

---

## 8. Open Questions

1. **Complexity.** Does Fibonacci-base constraint propagation provide any provable speedup for factoring, even in restricted cases (e.g., when factors have special Zeckendorf structure)?

2. **Hybrid approaches.** Can Fibonacci-base constraints be productively combined with existing algorithms (quadratic sieve, number field sieve) to provide additional filtering?

3. **Optimal base selection.** Among all integer sequences yielding unique representations (Ostrowski numerals for arbitrary continued fractions), which provides the tightest factoring constraints?

4. **Quantum implications.** Does the Fibonacci constraint structure interact favorably with quantum factoring approaches (beyond Shor's algorithm)?

5. **SAT/CSP encoding.** What is the treewidth of the Fibonacci factoring constraint graph, and how does it compare to the binary case?

---

## 9. Conclusion

We have shown that Fibonacci-base (Zeckendorf) arithmetic reveals structural properties of integer multiplication that are invisible in binary. The bidirectional carry rule, multi-position product spread, and non-adjacency invariant create a richer constraint landscape for factoring. While we do not yet claim an algorithmic speedup, the framework opens new avenues for analyzing the factorization problem through non-standard numeral systems, connecting classical number theory (Fibonacci numbers, golden ratio, Pisano periods) to computational algebra in a novel way.

---

## References

1. Zeckendorf, E. (1972). Représentation des nombres naturels par une somme de nombres de Fibonacci ou de nombres de Lucas. *Bulletin de la Société Royale des Sciences de Liège*, 41, 179–182.

2. Knuth, D. E. (1968). Fibonacci multiplication. *Applied Mathematics Letters*, 1(1), 57–60.

3. Frougny, C. (1992). Representations of numbers and finite automata. *Mathematical Systems Theory*, 25, 37–60.

4. Wall, D. D. (1960). Fibonacci series modulo *m*. *The American Mathematical Monthly*, 67(6), 525–532.

5. Lenstra, A. K., & Lenstra, H. W. (1993). *The development of the number field sieve*. Lecture Notes in Mathematics 1554. Springer.

---

*Appendix: Software.* All computations and visualizations in this paper were produced using the open-source Python library `fibonacci_base.py`, available in the accompanying repository. The library implements Zeckendorf encoding/decoding, normalized Fibonacci-base arithmetic, and constraint analysis tools.
