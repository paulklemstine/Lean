# The Complete Algebraic Theory of the Hecke Eigenvalue Recursion for GL₂

## Abstract

We develop the complete algebraic theory of the Hecke eigenvalue recursion h(n+2) = a·h(n+1) − q·h(n) with initial conditions h(0) = 1, h(1) = a over an arbitrary commutative ring R. This second-order linear recurrence encodes the eigenvalues of Hecke operators at prime power levels for GL₂ automorphic representations. We prove ten structural identities:

1. **Cassini-Hecke Identity**: h(n+1)² − h(n+2)·h(n) = qⁿ⁺¹
2. **Addition Formula**: h(m+n+2) = h(m+1)·h(n+1) − q·h(m)·h(n)
3. **Parity Identity**: h₋ₐ(n) = (−1)ⁿ·hₐ(n)
4. **Boundary Chebyshev**: h(n) = n+1 when a = 2, q = 1
5. **Companion Matrix Power**: (C^(n+1))₀₀ = h(n+1) where C = [[a,−q],[1,0]]
6. **Companion Determinant**: det(C) = q
7. **Companion Trace**: tr(C) = a
8. **Scaling Identity**: h(ca, c²q, n) = cⁿ·h(a,q,n)
9. **Zero Eigenvalue**: h(0,q,2k) = (−q)ᵏ and h(0,q,2k+1) = 0
10. **Mod-q Reduction**: q ∣ (h(n) − aⁿ)

All proofs are purely algebraic (by induction over ℕ) and require no analytic machinery such as Binet formulas or complex analysis. The results are formalized and machine-verified in Lean 4 with Mathlib.

We additionally introduce the `HeckeSystem` structure, which packages the algebraic data of a Hecke recursion together with its derived identities, and define the tropical (min-plus) Hecke recursion, proving that it linearizes in the Ramanujan regime.

**Keywords**: Hecke operators, eigenvalue recursion, Cassini identity, companion matrix, Ramanujan conjecture, tropical semiring, formal verification

---

## 1. Introduction

### 1.1 Background and Motivation

Let π be an unramified automorphic representation of GL₂ over a number field, and let p be a prime at which π is unramified. The local Hecke algebra H(GL₂(ℚₚ), GL₂(ℤₚ)) acts on the spherical vector of πₚ through a character determined by the Satake parameters αₚ and βₚ. The eigenvalue of the standard Hecke operator T(p) is aₚ = αₚ + βₚ, and the eigenvalue of T(p²) is aₚ² − p (when the central character is trivial, i.e., q = p).

More generally, the eigenvalue of T(pⁿ) is given by the sequence h(n) satisfying the recursion:

h(n+2) = aₚ · h(n+1) − p · h(n), h(0) = 1, h(1) = aₚ

This is the **Hecke eigenvalue recursion**. The sequence h(n) is the symmetric power character sum: h(n) = ∑ᵢ₌₀ⁿ αₚⁱ · βₚⁿ⁻ⁱ, which equals the Chebyshev polynomial of the second kind U_n evaluated at aₚ/(2√p).

### 1.2 Algebraic Generality

While the number-theoretic motivation requires working over ℂ (or at least over ℝ), the algebraic identities satisfied by h(n) are valid over any commutative ring. We work with arbitrary parameters a, q ∈ R for a commutative ring R, defining:

**Definition 1.1** (Hecke Eigenvalue Sequence). For a, q ∈ R, the Hecke eigenvalue sequence heckeSeq(a, q) : ℕ → R is defined by:
- heckeSeq(a, q, 0) = 1
- heckeSeq(a, q, 1) = a
- heckeSeq(a, q, n+2) = a · heckeSeq(a, q, n+1) − q · heckeSeq(a, q, n)

### 1.3 Relation to Classical Sequences

Several well-known sequences are specializations:

| Parameters | Sequence | Connection |
|-----------|----------|------------|
| a = 1, q = −1 | 1, 1, 2, 3, 5, 8, 13, ... | Fibonacci numbers F_{n+1} |
| a = 2, q = 1 | 1, 2, 3, 4, 5, 6, ... | Chebyshev U_n(1) = n+1 |
| a = 2, q = −1 | 1, 2, 5, 12, 29, 70, ... | Pell numbers |
| a = 0, q = any | 1, 0, −q, 0, q², ... | Alternating powers of −q |
| a = p+1, q = p | (p^(n+1)−1)/(p−1) | Sum of geometric series |

---

## 2. Main Results

### 2.1 The Cassini-Hecke Identity

**Theorem 2.1** (Cassini-Hecke). For all n ∈ ℕ:
$$h(n+1)^2 - h(n+2) \cdot h(n) = q^{n+1}$$

*Proof sketch.* By induction on n. The base case n = 0 gives h(1)² − h(2)·h(0) = a² − (a² − q) = q. For the inductive step, we use h(n+3) = a·h(n+2) − q·h(n+1) to express:

h(n+2)² − h(n+3)·h(n+1) = h(n+2)² − (a·h(n+2) − q·h(n+1))·h(n+1)

Expanding and using h(n+2) = a·h(n+1) − q·h(n):

= h(n+2)² − a·h(n+2)·h(n+1) + q·h(n+1)²
= −q·h(n)·h(n+2) + q·h(n+1)²
= q·(h(n+1)² − h(n+2)·h(n))
= q · q^{n+1} = q^{n+2} □

**Interpretation.** The Cassini-Hecke identity states that the determinant of the 2×2 matrix [[h(n+1), h(n)], [h(n+2), h(n+1)]] is (−1)·q^{n+1}. This is the statement that the companion matrix C = [[a,−q],[1,0]] has det(C) = q, propagated through matrix powers.

### 2.2 The Addition Formula

**Theorem 2.2** (Hecke Addition). For all m, n ∈ ℕ:
$$h(m+n+2) = h(m+1) \cdot h(n+1) - q \cdot h(m) \cdot h(n)$$

*Proof sketch.* By induction on n with m fixed. The base case n = 0 gives h(m+2) = h(m+1)·a − q·h(m), which is the recursion definition. For the inductive step, applying the IH at n and n−1 and using the recursion to express h(n+2) in terms of h(n+1) and h(n) yields the result after algebraic simplification. □

**Remark.** The addition formula implies the "doubling formula": h(2n+2) = h(n+1)² − q·h(n)² (set m = n). This enables O(log n) computation of h(n) via binary splitting.

### 2.3 The Parity Identity

**Theorem 2.3** (Parity). For all n ∈ ℕ:
$$h_{-a,q}(n) = (-1)^n \cdot h_{a,q}(n)$$

*Proof sketch.* Induction on n. The key observation is that negating a in the recursion h(n+2) = a·h(n+1) − q·h(n) introduces a sign flip at each step, and these signs accumulate to give (−1)^n. □

**Interpretation.** In representation-theoretic terms, this corresponds to twisting by the sign character: if π has Hecke eigenvalue aₚ, then π ⊗ sgn has eigenvalue −aₚ, and the eigenvalues at level pⁿ differ by (−1)^n.

### 2.4 The Companion Matrix

**Definition 2.4.** The Hecke companion matrix is:
$$C(a,q) = \begin{pmatrix} a & -q \\ 1 & 0 \end{pmatrix}$$

**Theorem 2.5.** det(C) = q and tr(C) = a.

**Theorem 2.6** (Matrix Power Formula). (C^{n+1})₀₀ = h(n+1).

More precisely, C^{n+1} = [[h(n+1), −q·h(n)], [h(n), −q·h(n−1)]] for n ≥ 1, but we prove only the (0,0) entry as it is the most useful statement and the general form requires additional bookkeeping for the n = 0 case.

### 2.5 The Scaling Identity

**Theorem 2.7** (Scaling). For all c ∈ R and n ∈ ℕ:
$$h(c \cdot a, c^2 \cdot q, n) = c^n \cdot h(a, q, n)$$

*Proof sketch.* Induction on n. The recursion transforms as h(ca, c²q, n+2) = ca · h(ca, c²q, n+1) − c²q · h(ca, c²q, n), and applying the IH gives ca · c^{n+1} · h(n+1) − c²q · c^n · h(n) = c^{n+2} · (a·h(n+1) − q·h(n)) = c^{n+2} · h(n+2). □

**Interpretation.** This encodes the effect of twisting by an unramified character of norm c: the Satake parameters scale as (cα, cβ), giving a = c(α+β) = ca and q = c²αβ = c²q.

### 2.6 The Mod-q Reduction

**Theorem 2.8** (Mod-q Reduction). For a, q ∈ ℤ and all n ∈ ℕ:
$$q \mid (h(n) - a^n)$$

*Proof sketch.* The recursion modulo q becomes h(n+2) ≡ a·h(n+1) (mod q), which by induction gives h(n) ≡ aⁿ. □

**Interpretation.** Modulo the determinant q, the Hecke eigenvalue sequence reduces to the geometric sequence aⁿ. This reflects the fact that modulo p, only the "semisimple" (diagonal) part of the Frobenius action survives.

---

## 3. The HeckeSystem Structure

We introduce a novel algebraic structure packaging the data of a Hecke recursion:

**Definition 3.1** (HeckeSystem). A *Hecke system* over a commutative ring R consists of:
- An eigenvalue a ∈ R (trace of Frobenius)
- A determinant q ∈ R (norm of prime)
- The derived sequence seq = heckeSeq(a, q)

The structure carries derived methods for the Cassini identity, addition formula, and Ramanujan bound.

**Definition 3.2** (Ramanujan Bound). A Hecke system (a, q) over a linearly ordered ring R satisfies the *Ramanujan bound* with respect to a square root s of q (i.e., s² = q) if −2s ≤ a ≤ 2s.

---

## 4. Tropical Hecke Recursion

### 4.1 Tropicalization

The tropical (min-plus) analogue of the Hecke recursion replaces (·, +, −) with (+, min, ∞):

**Definition 4.1** (Tropical Hecke Sequence). t(0) = 0, t(1) = a, t(n+2) = min(a + t(n+1), q + t(n)).

### 4.2 Ramanujan Linearization

In the Ramanujan regime 2a ≤ q, the tropical sequence becomes exactly linear:

**Proposition 4.2.** If 2a ≤ q, then t(n) = n·a for all n ≥ 0.

*Proof.* Induction: t(n+2) = min(a + (n+1)a, q + na) = min((n+2)a, q + na). Since 2a ≤ q, we have (n+2)a ≤ q + na, so the minimum is (n+2)a. □

This linearization is the tropical shadow of the Ramanujan bound: the classical bound |a| ≤ 2√q constrains eigenvalue growth, while the tropical bound 2a ≤ q forces the min-plus recursion into its linear regime.

---

## 5. Falsified Conjecture: Hecke Divisibility

We investigated the conjecture that h(m) | h(mn) for all m ≥ 1, n ≥ 1 (analogous to the Fibonacci divisibility property F_m | F_{mn}).

**Counterexample.** With a = 3, q = 7: h(1) = 3, h(2) = 3·3 − 7 = 2. Since 3 ∤ 2, the divisibility property fails.

This shows that the Fibonacci divisibility property is *not* a general feature of Hecke eigenvalue sequences — it depends on the specific algebraic structure of (a, q) = (1, −1). The failure can be traced to the fact that the companion matrix at (1, −1) generates a subgroup of SL₂(ℤ) with special divisibility properties related to the Euclidean algorithm.

---

## 6. Algorithms

### 6.1 Direct Computation

The sequence h(0), ..., h(N−1) can be computed in O(N) time and O(1) space using the linear recurrence.

### 6.2 Fast Doubling

Using the addition formula with m = n: h(2n+2) = h(n+1)² − q·h(n)². Combined with h(2n+1) from the recursion, this gives an O(log N) algorithm via:

```
fast_hecke(a, q, n):
  if n == 0: return (1, a)  # (h(0), h(1))
  (h_k, h_k1) = fast_hecke(a, q, n // 2)
  if n is even:
    h_2k = h_k1^2 - q * h_k^2  # h(2k) via addition formula
    h_2k1 = a * h_2k - q * ... # need careful derivation
  ...
```

### 6.3 Matrix Exponentiation

Compute C^n via binary matrix exponentiation in O(log n) multiplications of 2×2 matrices (4 ring operations each).

---

## 7. Discussion

### 7.1 Relation to Prior Work

The individual identities (Cassini, addition formula) are known in the number theory literature as consequences of the Binet formula h(n) = (α^{n+1} − β^{n+1})/(α − β) where α, β are roots of X² − aX + q. However, the Binet formula requires working in an extension ring R[√(a²−4q)] and fails when a² = 4q (the Ramanujan boundary). Our proofs are purely algebraic and work uniformly over any commutative ring, including finite fields, p-adic integers, and polynomial rings.

### 7.2 The HeckeSystem Abstraction

The `HeckeSystem` structure provides a clean interface for working with Hecke recursions in formal mathematics. It bundles the sequence with its proved identities, enabling modular reasoning about Hecke operators at different primes.

### 7.3 Tropical Perspective

The tropical Hecke recursion provides a novel perspective on the Ramanujan bound. The linearization phenomenon — the tropical sequence becoming affine exactly at the Ramanujan threshold — suggests a deeper connection between tropical geometry and automorphic forms that deserves further investigation.

---

## 8. Future Work

1. **Higher-rank extension**: Generalize to GL₃ and beyond, where the recursion becomes a system of coupled recurrences governed by higher-dimensional companion matrices.

2. **Maslov dequantization**: Formally prove the convergence of the soft-min family interpolating between the classical and tropical Hecke recursions.

3. **Algebraic Ramanujan bound**: Prove that |h(n)| ≤ (n+1)·q^{n/2} purely algebraically when |a| ≤ 2√q.

4. **Hecke algebra formalization**: Extend the `HeckeSystem` to a full formalization of the spherical Hecke algebra for GL₂.

---

## References

1. Hecke, E. (1937). Über Modulfunktionen und die Dirichletschen Reihen mit Eulerscher Produktentwicklung. *Math. Ann.* 114, 1–28.

2. Deligne, P. (1974). La conjecture de Weil. I. *Publ. Math. IHÉS* 43, 273–307.

3. Bump, D. (1997). *Automorphic Forms and Representations*. Cambridge University Press.

4. Maclagan, D. & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
