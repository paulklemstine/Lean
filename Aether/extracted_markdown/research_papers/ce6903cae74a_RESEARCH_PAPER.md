# The Collatz Affine Map Algebra: Parity Vectors, Trajectory Reconstruction, and Orbit Density Bounds

## Abstract

We introduce the **Collatz Affine Map** (CAM) algebra, a novel algebraic framework for studying the Collatz (3n+1) dynamical system. Each step of the Collatz iteration — division by 2 for even numbers, tripling and adding 1 for odd numbers — is encoded as an affine transformation. The composition of k consecutive steps yields a single affine map x ↦ (a·x + b)/d where a = 3^s, d = 2^t, and s,t count the odd and even steps respectively. We establish the **Affine Reconstruction Theorem**: given a starting value n and its parity vector (the sequence of parities of the trajectory), the k-th iterate satisfies T^k(n)·d = a·n + b exactly. We prove structure theorems for the coefficients, exact stopping times for powers of 2, the Mersenne step formula, and a rigorous bound showing that at most ⌈k/2⌉ of any k consecutive Collatz steps can be odd. All results are fully machine-verified.

**Keywords**: Collatz conjecture, 3n+1 problem, parity vector, affine map, trajectory reconstruction, orbit density

---

## 1. Introduction

The Collatz conjecture states that iterating the map T(n) = n/2 (n even) or T(n) = 3n+1 (n odd) starting from any positive integer eventually reaches 1. Despite extensive computational verification (to 2^68 by Barina [1]) and deep theoretical work connecting the problem to ergodic theory, fractal geometry, and computability, the conjecture remains open.

The **parity vector** approach — encoding a trajectory as a binary sequence of even (0) and odd (1) steps — has been studied since Terras [2] and Everett [3]. Our contribution is to develop the full algebraic theory of affine map composition along parity vectors, proving the reconstruction theorem and deriving structural consequences.

### 1.1 Novel Structure: The Collatz Affine Map

**Definition** (CollatzAffineMap). A Collatz Affine Map is a triple (a, b, d) ∈ ℕ³ with d > 0, representing the affine function x ↦ (a·x + b)/d. The key operations are:

- **compEven**: (a, b, d) ↦ (a, b, 2d) — composing with x ↦ x/2
- **compOdd**: (a, b, d) ↦ (3a, 3b + d, d) — composing with x ↦ 3x+1

The identity is (1, 0, 1). Building the map from a parity vector p₀, ..., p_{k-1} proceeds left to right: start with id, and for each pᵢ, apply compEven (if pᵢ = 0) or compOdd (if pᵢ = 1).

This structure differs from prior work (e.g., Lagarias [4]) in that we track the affine map over ℕ rather than ℤ, maintain the unreduced fraction a/d, and prove the exact reconstruction identity.

---

## 2. Main Results

### 2.1 Fundamental Properties (PEGB)

**Theorem 2.1** (collatzStep_odd_gives_even). *If n is odd, then T(n) = 3n+1 is even.*

- **Proof**: Direct computation: 3n+1 ≡ 3·1+1 ≡ 0 (mod 2) when n ≡ 1 (mod 2).
- **Example**: T(7) = 22, T(3) = 10, T(1) = 4.
- **Generalization**: For the generalized map T_a(n) = an+1 with a odd, T_a maps odd to even.
- **Boundary**: T(0) = 0 (even input, even output — the theorem's hypothesis is essential).

**Theorem 2.2** (syracuse_eq_double_step). *For odd n, the Syracuse map S(n) = (3n+1)/2 equals two Collatz steps: S(n) = T(T(n)).*

- **Proof**: T(n) = 3n+1 (by Theorem 2.1, this is even), then T(3n+1) = (3n+1)/2 = S(n).
- **Example**: S(5) = 8, T(T(5)) = T(16) = 8.
- **Generalization**: For any map where odd→even is guaranteed, the "skip" acceleration works.
- **Boundary**: S(0) is not meaningful (0 is even); S(1) = 2.

### 2.2 The Affine Reconstruction Theorem (PEGB)

**Theorem 2.3** (affineMap_eval_eq_iter). *For any n > 0 and k ≥ 0, let (a, b, d) = buildAffineMap k (parityVec k n). Then:*

$$T^k(n) \cdot d = a \cdot n + b$$

- **Proof**: Induction on k. Base case: T⁰(n)·1 = 1·n + 0. Inductive step: if T^k(n) = v and v·d = a·n + b, then:
  - If v is even: T^{k+1}(n) = v/2, new d' = 2d, and (v/2)·(2d) = v·d = a·n + b.
  - If v is odd: T^{k+1}(n) = 3v+1, new a' = 3a, b' = 3b+d, and (3v+1)·d = 3(v·d)+d = 3(a·n+b)+d = (3a)·n + (3b+d).
- **Example**: n = 5, k = 3. Trajectory: 5→16→8→4. Parities: [1,0,0]. Map: (3,1,4). Check: 4·4 = 3·5+1 = 16. ✓
- **Generalization**: The theorem extends to any dynamical system where steps are affine maps.
- **Boundary**: At n = 0 (excluded), the theorem fails since the parity of 0 doesn't match the expected behavior.

### 2.3 Structure Theorems (PEGB)

**Theorem 2.4** (buildAffineMap_numerator). *The numerator coefficient of buildAffineMap k p equals 3^s where s = |{i : p(i) = 1}|.*

- **Proof**: Induction on k. compOdd multiplies by 3 (adding to the odd count); compEven preserves.
- **Example**: Parity [1,0,1,0] → numerator = 3² = 9.
- **Generalization**: For a generalized map with multiplier m (instead of 3), the coefficient would be m^s.
- **Boundary**: All-zero parity vector → numerator = 1 = 3⁰.

**Theorem 2.5** (buildAffineMap_denom). *The denominator equals 2^t where t = |{i : p(i) = 0}|.*

- **Proof**: Induction on k. compEven multiplies denominator by 2; compOdd preserves.
- **Example**: Parity [1,0,0,0] → denominator = 2³ = 8.
- **Generalization**: For division by d (instead of 2), the denominator would be d^t.
- **Boundary**: All-one parity vector → denominator = 1 = 2⁰.

### 2.4 Orbit Density Bound (PEGB)

**Theorem 2.6** (odd_steps_bounded). *In any k ≥ 2 consecutive Collatz steps starting from n > 0 (with all iterates positive), the number of odd steps s satisfies 2s ≤ k + 1.*

- **Proof**: By Theorem 2.1, every odd step is followed by an even step. So odd-step indices form an independent set in the path graph on {0, ..., k-1}. The maximum independent set in a path of length k has size ⌈k/2⌉. Hence 2s ≤ k + 1.
- **Example**: n = 7, k = 3: parities [1,0,1], s = 2, 2·2 = 4 ≤ 3+1 = 4. ✓ (tight!)
- **Generalization**: For any map where odd→even, the same bound holds.
- **Boundary**: k = 1 is excluded; n = 7, k = 1 has parity [1], s = 1, 2·1 = 2 > 1+0 = 1 — the k ≥ 2 condition is necessary.

### 2.5 Stopping Time for Powers of 2

**Theorem 2.7** (collatzIter_pow2). *T^k(2^k) = 1 for all k ≥ 0.*

- **Proof**: Stronger claim: T^j(2^k) = 2^(k-j) for j ≤ k. By induction: each step halves (2^(k-j) is even for k-j ≥ 1). At j = k: 2^0 = 1.
- **Example**: 2⁴ = 16 → 8 → 4 → 2 → 1 in 4 steps.
- **Generalization**: More generally, T^j(2^k) = 2^(k-j) for j ≤ k, and T^k(m·2^k) = m for any m.
- **Boundary**: T^{k+1}(2^k) = T(1) = 4 ≠ 1 — exactly k steps, no more.

### 2.6 Mersenne Step

**Theorem 2.8** (collatzStep_mersenne). *For k ≥ 1, T(2^k - 1) = 3(2^k - 1) + 1 = 3·2^k - 2.*

- **Example**: T(7) = 22 = 3·8 - 2, T(15) = 46 = 3·16 - 2.
- **Boundary**: k = 0 gives T(0) = 0, not 3·0+1 = 1.

### 2.7 Decrease Condition

**Theorem 2.9** (decrease_condition). *For the parity vector consisting of d ones followed by e zeros, the affine map numerator is 3^d.*

This gives a necessary condition for trajectory decrease: after d odd steps and e even steps (in this specific order), the trajectory decreases iff 3^d < 2^e · T^{d+e}(n) / n, which simplifies (ignoring the offset) to approximately 3^d < 2^e, i.e., d·log(3) < e·log(2).

---

## 3. Algorithms

### 3.1 Affine Map Computation

```python
def build_affine_map(parity_vec):
    a, b, d = 1, 0, 1
    for p in parity_vec:
        if p == 0:  # even step
            d *= 2
        else:       # odd step
            a, b = 3 * a, 3 * b + d
    return a, b, d
```

**Complexity**: O(k) arithmetic operations, where each operation involves numbers of O(k) digits.

### 3.2 Trajectory Reconstruction

Given n and a parity vector, the k-th iterate is:

$$T^k(n) = \frac{a \cdot n + b}{d}$$

This is exact (no rounding) when the parity vector is correct, providing a fast way to compute iterates without stepping through intermediate values.

---

## 4. Conjecture with Testable Prediction

**Conjecture** (Parity Vector Completeness). *For every finite binary sequence w ∈ {0,1}^k with no two consecutive 1s, there exists n > 0 such that parityVec k n = w.*

**Test**: For k ≤ 20, enumerate all valid parity vectors (Fibonacci-many) and for each, solve the linear equation a·n + b ≡ 0 (mod d) to find a candidate n, then verify.

**Current status**: Computationally verified for k ≤ 15 (see demo.py). The linear equation always has solutions, suggesting the conjecture is true, but a proof would require understanding the distribution of Collatz trajectories mod powers of 6.

---

## 5. Connection to Undecidability

The affine map framework illuminates why the Collatz conjecture might resist proof in Peano Arithmetic (PA). The key observation is:

1. The trajectory of n depends on the parities of T^j(n) for all j, which in turn depend on n through a highly nonlinear relationship.
2. The offset term b in the affine map grows exponentially in k, encoding the full combinatorial history of the trajectory.
3. Proving the conjecture requires showing that for all n, there exists k such that 3^s · n + b = 2^t · 1 (reaching 1), where s, t, b all depend on n through the parity vector.

This is a Π₂⁰ statement (for all n, there exists k, ...) in the arithmetic hierarchy. While PA can prove many Π₂⁰ statements, the entanglement between the universally and existentially quantified variables through the parity vector may push this statement beyond PA's reach.

The connection to Con(PA) proposed in the research direction remains speculative. What we can say rigorously is that the algebraic structure of the Collatz map — the interleaving of multiplication by 3 and division by 2 — creates exactly the kind of arithmetic complexity that Gödel's incompleteness theorem exploits.

---

## 6. Discussion

### 6.1 Comparison with Prior Work

The parity vector approach has been studied extensively (Terras 1976, Lagarias 1985, Wirsching 1998). Our contribution is the complete formalization of the affine map algebra, including:
- Exact coefficient formulas (Theorems 2.4, 2.5)
- The reconstruction identity (Theorem 2.3) as a machine-verified theorem
- The density bound (Theorem 2.6) with a tight analysis

### 6.2 Why the Offset Matters

The crucial quantity is the offset b. While a and d depend only on the *counts* of odd/even steps, b depends on their *ordering*. Two parity vectors with the same number of 1s and 0s can produce vastly different offsets. This sensitivity to ordering is what makes the Collatz map behave pseudo-randomly and is the fundamental obstacle to proof.

### 6.3 Implications for Computation

The affine map provides an O(k)-step algorithm for computing T^k(n) without computing intermediate values, given the parity vector. This is useful for studying specific trajectories but doesn't help with the conjecture itself, since determining the parity vector requires knowing the trajectory.

---

## 7. Future Work

1. **Parity Vector Classification**: Which binary sequences (with no consecutive 1s) actually occur as Collatz parity vectors? This is equivalent to understanding the range of the Collatz map modulo increasing powers of 2 and 3.

2. **Offset Growth Rates**: Can one bound the growth of b in terms of k, s, and t? Sharp bounds would imply partial results toward the conjecture.

3. **Tropical Interpretation**: The affine map can be viewed in the tropical (min-plus) semiring, potentially connecting to the existing tropical algebra work in the catalog.

4. **Decidability**: Can the affine map framework formalize the claim that Collatz is Π₂⁰-complete? This would require showing that any Π₂⁰ statement can be reduced to a Collatz-like iteration.

---

## References

[1] E. Barina. "Convergence verification of the Collatz problem." *The Journal of Supercomputing*, 2021.

[2] R. Terras. "A stopping time problem on the positive integers." *Acta Arithmetica*, 30:241–252, 1976.

[3] C.J. Everett. "Iteration of the number-theoretic function f(2n) = n, f(2n+1) = 3n+2." *Advances in Mathematics*, 25(1):42–45, 1977.

[4] J.C. Lagarias. "The 3x+1 problem and its generalizations." *American Mathematical Monthly*, 92(1):3–23, 1985.

[5] G.J. Wirsching. *The Dynamical System Generated by the 3n+1 Function*. Lecture Notes in Mathematics 1681, Springer, 1998.
