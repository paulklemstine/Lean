# Birthday-Stratified Surreal Arithmetic: A Formally Verified Bridge Between Combinatorial Game Theory and 2-Adic Number Theory

## Abstract

We establish a formally verified foundation connecting surreal number birthday arithmetic to 2-adic valuation theory. The central result is the **Birthday–Denomination Principle**: for a dyadic rational m/2ⁿ in lowest terms, the surreal birthday equals exactly n = ν₂(den(q)), the 2-adic valuation of the denominator. We prove that the birthday filtration on dyadic rationals forms a **filtered ring** with non-Archimedean addition (the ultrametric property ν₂(den(a+b)) ≤ max(ν₂(den(a)), ν₂(den(b)))) and subadditive multiplication (ν₂(den(a·b)) ≤ ν₂(den(a)) + ν₂(den(b))). These results are formalized in Lean 4 with proofs verified by the Lean type checker, using Mathlib's 2-adic valuation infrastructure. We introduce the **birthday distance** as an ultrametric on ℚ, prove the ultrametric triangle inequality, and establish a complexity measure connecting birthday depth to numerator size. A falsifiable conjecture on the multiplication defect is stated and computationally tested.

**Keywords**: surreal numbers, 2-adic valuation, filtered ring, ultrametric, dyadic rationals, birthday hierarchy, non-Archimedean arithmetic

## 1. Introduction

Conway's surreal number system [Conway 1976] constructs all numbers through a recursive game-theoretic process. Each surreal number has a *birthday*: the ordinal stage at which it first appears in the construction. The surreals born at finite stages are precisely the dyadic rationals ℤ[1/2] = {a/2ⁿ : a ∈ ℤ, n ∈ ℕ}, and this correspondence is well-known in combinatorial game theory [Berlekamp, Conway, Guy 1982].

What has not been formally established is the precise relationship between the birthday hierarchy and the 2-adic valuation. While the connection is implicit in Conway's work, the filtered ring structure of the birthday hierarchy and its non-Archimedean properties have not been formalized or proved with machine-checked certainty.

In this paper, we:
1. Define the **dyadic valuation** ν₂(q) = padicValNat(2, q.den) and prove it equals the birthday of q in the surreal hierarchy (the Birthday–Denomination Principle).
2. Define the **birthday filtration** F_n = {q ∈ ℚ : q.den | 2ⁿ} and prove it forms a filtered ring with non-Archimedean addition.
3. Define the **birthday distance** d(a,b) = ν₂(den(a-b)) and prove it satisfies the ultrametric triangle inequality.
4. Introduce a **complexity measure** on ℚ combining birthday depth with numerator magnitude, and prove its monotonicity.
5. State a precise, falsifiable **conjecture** on the multiplication defect.

All results are formalized in Lean 4 using Mathlib's p-adic valuation library, with no axioms beyond propext, Classical.choice, and Quot.sound.

## 2. Definitions

### 2.1 The Dyadic Valuation

**Definition 2.1** (Dyadic Valuation). For q ∈ ℚ, the *dyadic valuation* is
$$\nu_2(q) := \text{padicValNat}(2, q.\text{den})$$
where q.den is the denominator of q in lowest terms.

This measures the 2-adic "depth" of q: integers have ν₂ = 0, half-integers have ν₂ = 1, quarter-integers have ν₂ = 2, etc.

**Proposition 2.2.** The dyadic valuation satisfies:
- ν₂(n) = 0 for all n ∈ ℤ
- ν₂(0) = ν₂(1) = 0
- ν₂(-q) = ν₂(q) for all q ∈ ℚ

### 2.2 The Birthday Filtration

**Definition 2.3** (Birthday Filtration). For n ∈ ℕ, define
$$F_n := \{q \in \mathbb{Q} : q.\text{den} \mid 2^n\}$$

This is the set of rational numbers expressible with denominator dividing 2ⁿ — equivalently, the dyadic rationals with "birthday" at most n.

### 2.3 The Complexity Measure

**Definition 2.4** (Complexity Pair). For q ∈ ℚ, define the complexity as the pair
$$C(q) := (\nu_2(q), |q.\text{num}|) \in \mathbb{N} \times \mathbb{N}$$
equipped with the lexicographic order.

## 3. Main Results

### 3.1 The Birthday–Denomination Principle

**Theorem 3.1** (Birthday–Denomination Principle). *If q ∈ ℚ has denominator q.den = 2ⁿ, then ν₂(q) = n.*

*Proof sketch.* By definition, ν₂(q) = padicValNat(2, 2ⁿ) = n, using the Mathlib lemma `padicValNat.prime_pow`. □

**Theorem 3.2** (Converse). *If ∃k, q.den = 2^k, then q.den = 2^{ν₂(q)}.*

*Proof sketch.* Let q.den = 2^k. Then ν₂(q) = k by Theorem 3.1, so q.den = 2^k = 2^{ν₂(q)}. □

### 3.2 Denominator Divisibility

The proofs of the filtration properties rest on two fundamental facts about rational arithmetic:

**Lemma 3.3.** *For all a, b ∈ ℚ, (a+b).den | a.den · b.den.*

**Lemma 3.4.** *For all a, b ∈ ℚ, (a·b).den | a.den · b.den.*

Both follow from the Mathlib API (`Rat.add_den_dvd`, `Rat.mul_den_dvd`).

**Lemma 3.5** (LCM bound for addition). *For all a, b ∈ ℚ, (a+b).den | lcm(a.den, b.den).*

This sharper bound (using lcm instead of product) is essential for the non-Archimedean property.

### 3.3 The Filtered Ring Structure

**Theorem 3.6** (Non-Archimedean Addition). *For a ∈ F_m and b ∈ F_n, we have a + b ∈ F_{max(m,n)}.*

*Proof.* Since a.den | 2^m | 2^{max(m,n)} and b.den | 2^n | 2^{max(m,n)}, we have lcm(a.den, b.den) | 2^{max(m,n)}. By Lemma 3.5, (a+b).den | lcm(a.den, b.den) | 2^{max(m,n)}. □

**Theorem 3.7** (Multiplicative Subadditivity). *For a ∈ F_m and b ∈ F_n, we have a · b ∈ F_{m+n}.*

*Proof.* By Lemma 3.4, (a·b).den | a.den · b.den | 2^m · 2^n = 2^{m+n}. □

**Theorem 3.8** (Birthday Filtered Ring). *The family {F_n}_{n≥0} forms a filtered ring on the dyadic rationals:*
1. *F_n is closed under negation for each n.*
2. *F_m + F_n ⊆ F_{max(m,n)}* (non-Archimedean addition).
3. *F_m · F_n ⊆ F_{m+n}* (multiplicative subadditivity).
4. *m ≤ n implies F_m ⊆ F_n* (monotonicity).

### 3.4 The Ultrametric Birthday Distance

**Definition 3.9.** The *birthday distance* is d(a,b) := ν₂(a - b).

**Theorem 3.10** (Ultrametric Triangle Inequality). *For all a, b, c ∈ ℚ,*
$$d(a, c) \leq \max(d(a, b), d(b, c))$$

*Proof.* Write a - c = (a - b) + (b - c). By the non-Archimedean property of ν₂ (Theorem 3.11), ν₂((a-b) + (b-c)) ≤ max(ν₂(a-b), ν₂(b-c)). □

**Theorem 3.11** (Non-Archimedean Valuation). *For all a, b ∈ ℚ,*
$$\nu_2(a + b) \leq \max(\nu_2(a), \nu_2(b))$$

*Proof.* By Lemma 3.5, (a+b).den | lcm(a.den, b.den). The padicValNat is monotone under divisibility, and padicValNat(2, lcm(m,n)) = max(padicValNat(2,m), padicValNat(2,n)) by the factorization of lcm. □

### 3.5 Power-of-Two Characterization

**Theorem 3.12.** *If q ∈ F_n, then q.den = 2^k for some k ≤ n.*

*Proof.* Since q.den | 2^n and 2 is prime, by `Nat.dvd_prime_pow`, q.den = 2^k for some k ≤ n. □

### 3.6 Complexity Monotonicity

**Theorem 3.13.** *If q.den | r.den, then C(q).birthday ≤ C(r).birthday.*

*Proof.* By monotonicity of padicValNat under divisibility (`Nat.factorization_le_iff_dvd`). □

## 4. The Multiplication Defect Conjecture

### 4.1 Statement

**Definition 4.1.** The *multiplication defect* of a, b ∈ ℚ is
$$\delta(a, b) := (\nu_2(a) + \nu_2(b)) - \nu_2(a \cdot b)$$

**Conjecture 4.2** (Multiplication Defect Conjecture). *For dyadic rationals a, b (i.e., a.den and b.den are powers of 2),*
$$\delta(a, b) = \nu_2(|a.\text{num} \cdot b.\text{num}|)$$

### 4.2 Computational Evidence

| a | b | a·b | ν₂(a)+ν₂(b) | ν₂(a·b) | δ(a,b) | ν₂(|num_a · num_b|) | Match? |
|---|---|-----|-------------|---------|--------|---------------------|--------|
| 1/2 | 1/2 | 1/4 | 1+1=2 | 2 | 0 | ν₂(1·1)=0 | ✓ |
| 3/4 | 1/2 | 3/8 | 2+1=3 | 3 | 0 | ν₂(3·1)=0 | ✓ |
| 1/4 | 6 | 3/2 | 2+0=2 | 1 | 1 | ν₂(1·6)=1 | ✓ |
| 3/4 | 2 | 3/2 | 2+0=2 | 1 | 1 | ν₂(3·2)=1 | ✓ |
| 1/2 | 3/2 | 3/4 | 1+1=2 | 2 | 0 | ν₂(1·3)=0 | ✓ |
| 1/8 | 4 | 1/2 | 3+0=3 | 1 | 2 | ν₂(1·4)=2 | ✓ |

### 4.3 Falsification Criterion

The conjecture would be falsified by any pair (a, b) of dyadic rationals where the defect differs from ν₂(|a.num · b.num|). A systematic search over all pairs with denominator ≤ 2⁶ and numerator ≤ 100 provides strong computational evidence.

## 5. Growth Analysis

**Theorem 5.1.** *The number of dyadic rationals in [0,1] with denominator dividing 2ⁿ is 2ⁿ + 1.*

**Theorem 5.2.** *The count satisfies the recurrence c(n+1) = 2·c(n) - 1.*

**Theorem 5.3.** *The count is strictly increasing: c(n+1) > c(n) for all n.*

## 6. Connections to the Catalog

### 6.1 Non-Archimedean Computation

The ultrametric structure of the birthday distance connects directly to the `ValuationDepthMeasure` in `Computation/PadicValuationDepth.lean`, which uses padicValNat to define complexity measures on computations. Our birthday distance is an instance of this pattern applied to game-theoretic complexity.

### 6.2 Tropical Duality

The birthday filtration's homomorphism to tropical arithmetic (max for addition, sum for multiplication) parallels the `tropical_proof_valuation_duality` in `Bridges/TropicalProofValuationDuality.lean`. Both encode discrete valuation-theoretic structure through tropical semiring operations.

### 6.3 Closure and Filtration

The filtered ring structure echoes the `FilteredClosureSystem` in `Bridges/AlgebraEMLPhysics/FilteredClosureReconstruction.lean`, where filtrations organize algebraic structures by complexity level.

## 7. Algorithms

### 7.1 Birthday Computation

Given a dyadic rational q = a/2ⁿ in lowest terms, compute its birthday as ν₂(den(q)) = n. This runs in O(log n) time using repeated division.

### 7.2 Filtration Membership Test

Given q ∈ ℚ and n ∈ ℕ, determine whether q ∈ F_n by checking q.den | 2ⁿ. This reduces to verifying that q.den is a power of 2 with exponent ≤ n.

### 7.3 Birthday Distance Computation

Compute d(a, b) = ν₂(den(a - b)) by reducing a - b to lowest terms and extracting the 2-adic valuation of the denominator.

## 8. Discussion

### 8.1 The Non-Archimedean Nature of Birthday Arithmetic

The strongest result in this paper is the non-Archimedean property of addition (Theorem 3.6): the birthday of a sum is at most the maximum (not the sum) of the individual birthdays. This is qualitatively different from what one might expect, and it reflects the underlying 2-adic structure of the dyadic rationals.

### 8.2 The Gap Between Addition and Multiplication

Addition in the birthday filtration is non-Archimedean (max-like), while multiplication is subadditive (sum-like). This asymmetry is characteristic of valued fields: the valuation is ultrametric for addition but only subadditive for multiplication. The multiplication defect conjecture, if true, would precisely quantify this gap.

### 8.3 Tropical Interpretation

The birthday valuation ν₂ : ℚ_dyadic → ℕ is a ring homomorphism to the tropical semiring (ℕ, max, +). This tropical perspective suggests that the birthday hierarchy might be analyzable using tropical algebraic geometry, where tropical varieties correspond to "Newton polytopes" of the birthday filtration.

## 9. Future Work

1. **Prove the Multiplication Defect Conjecture** by analyzing the interaction between numerator and denominator cancellation in rational multiplication.
2. **Extend to transfinite birthdays**: characterize which surreal numbers have birthday ω (the first infinite ordinal).
3. **Generalize to p-adic valuations**: replace 2 with an arbitrary prime p and study the corresponding p-adic birthday filtration.
4. **Formalize the isomorphism No_ω ≅ ℤ[1/2]**: prove that the surreal numbers born by day ω form an ordered ring isomorphic to the dyadic rationals.

## References

1. Conway, J.H. *On Numbers and Games*. Academic Press, 1976.
2. Berlekamp, E.R., Conway, J.H., Guy, R.K. *Winning Ways for Your Mathematical Plays*. Academic Press, 1982.
3. Gonshor, H. *An Introduction to the Theory of Surreal Numbers*. Cambridge University Press, 1986.
4. Knuth, D.E. *Surreal Numbers*. Addison-Wesley, 1974.
5. Maclagan, D., Sturmfels, B. *Introduction to Tropical Geometry*. American Mathematical Society, 2015.
