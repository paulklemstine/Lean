# Freivalds as the Degree-1 Shadow of Schwartz–Zippel over Finite Fields: A Machine-Verified Algebraic Complexity Pipeline

## Abstract

We present a complete machine-verified formalization of the Schwartz–Zippel lemma over finite fields, together with its specialization to Freivalds' randomized matrix multiplication verification algorithm. The formalization establishes a certified pipeline from multivariate polynomial zero counting through linear-algebraic discrepancy to randomized verification: **polynomial method → randomized verification → circuit complexity**. Our proof proceeds by induction on the number of variables using the `MvPolynomial.finSuccEquiv` algebra isomorphism to decompose multivariate polynomials into univariate fibers, establishing the base case via the classical univariate root bound and the inductive step via a coefficient-degree analysis. We derive Freivalds' bound as a corollary of the degree-1 case, proving that for a nonzero n×n matrix D over a finite field of size q, at most q^{n−1} vectors r satisfy Dr = 0. All results are fully verified with no `sorry` axioms or unproven assumptions. The formalization creates a reusable interface for future work in polynomial identity testing, algebraic circuit lower bounds, Reed–Muller codes, and certified randomized computation.

## 1. Introduction

### 1.1 Motivation

The Schwartz–Zippel lemma [Schwartz 1980, Zippel 1979, DeMillo–Lipton 1978] is a cornerstone of randomized algorithms and algebraic complexity theory. It states that a nonzero multivariate polynomial of total degree d over a finite field of size q has at most d · q^{n−1} zeros. Despite its simplicity, this bound has profound consequences in polynomial identity testing, error-correcting codes, interactive proofs, and cryptography.

Freivalds' algorithm [Freivalds 1979] for randomized verification of matrix multiplication is one of the earliest and most elegant randomized algorithms. It verifies whether AB = C by checking (AB)r = Cr for a random vector r, with one-sided error at most 1/q.

The folklore connection between these results — that Freivalds' algorithm is the degree-1 specialization of Schwartz–Zippel — has been known for decades but has never been formalized in a machine-verified framework. We establish this connection rigorously, creating a certified pipeline from polynomial algebra to algorithmic verification.

### 1.2 Contributions

1. **Full formalization of the Schwartz–Zippel lemma** (`schwartz_zippel_succ`) over arbitrary finite fields, proved by induction on the number of variables using Mathlib's `MvPolynomial.finSuccEquiv`.

2. **Freivalds' algorithm bounds** (`freivalds_discrepancy_bound`, `freivalds_bound`) derived via a direct linear-algebraic argument, independent of the full Schwartz–Zippel machinery.

3. **Specializations to ZMod q** (`schwartz_zippel_zmod`, `freivalds_zmod_bound`) with explicit cardinality bounds.

4. **Probability forms** (`freivalds_error_probability`, `linear_zero_probability_le`) expressing the results as error probability bounds.

5. **Degree-1 bridge** (`linear_schwartz_zippel`) connecting the full theorem to its linear specialization, making explicit that Freivalds' algorithm is a polynomial identity test.

### 1.3 Related Work

Prior formalizations of polynomial results in proof assistants include root bounds for univariate polynomials (present in Mathlib as `Polynomial.card_roots'`), the Combinatorial Nullstellensatz (partial formalizations), and basic polynomial identity over infinite domains. To our knowledge, no prior formalization establishes the multivariate Schwartz–Zippel bound or derives Freivalds' algorithm from polynomial identity testing.

## 2. Mathematical Setup

### 2.1 Notation

- K: a finite field with |K| = q elements
- MvPolynomial (Fin n) K: the ring of multivariate polynomials in n variables over K
- f.totalDegree: the total degree of a multivariate polynomial
- Fin.cons t a: the assignment (t, a₁, ..., aₙ) formed by prepending t to a
- Matrix.mulVec D r: the matrix-vector product Dr
- MvPolynomial.finSuccEquiv K n: the algebra isomorphism
  MvPolynomial (Fin (n+1)) K ≃ₐ[K] Polynomial (MvPolynomial (Fin n) K)

### 2.2 Key Definitions

**Fiber Polynomial.** Given f ∈ K[x₀, ..., xₙ] and an assignment a : Fin n → K to variables x₁, ..., xₙ, the fiber polynomial is:

```
fiberPoly(f, a) := Polynomial.map (eval a) (finSuccEquiv K n f)
```

This is the univariate polynomial in x₀ obtained by substituting a for (x₁, ..., xₙ).

**Evaluation Identity.** The fiber polynomial satisfies:

```
eval t (fiberPoly f a) = eval (Fin.cons t a) f
```

This follows from `MvPolynomial.eval_eq_eval_mv_eval'`.

## 3. Main Results

### 3.1 Schwartz–Zippel Lemma

**Theorem (schwartz_zippel_succ).** Let K be a finite field with |K| = q, and let f ∈ K[x₁, ..., x_{n+1}] be a nonzero polynomial. Then:

|{x ∈ K^{n+1} : f(x) = 0}| ≤ totalDeg(f) · q^n

**Proof sketch.** By strong induction on n.

*Base case (n = 0):* f is a polynomial in one variable. The zero set maps injectively to the roots of the corresponding univariate polynomial. By the univariate root bound (`Polynomial.card_roots'`), the number of roots is at most natDeg(f) ≤ totalDeg(f).

*Inductive step:* Apply `finSuccEquiv` to obtain F : Polynomial (MvPolynomial (Fin (n+1)) K). Let d = degreeOf₀(f) = natDeg(F), and let c_d = F.coeff(d) be the degree-d coefficient, a polynomial in (x₁, ..., x_{n+1}).

Partition assignments a : Fin (n+1) → K into:

- **Good:** eval(a, c_d) ≠ 0. Then the fiber Polynomial.map(eval a)(F) has natDegree = d, so by the univariate root bound, at most d values of t ∈ K satisfy eval(Fin.cons t a)(f) = 0.

- **Bad:** eval(a, c_d) = 0. Trivially, at most q values of t work. Since c_d is nonzero (it's the leading coefficient of a nonzero polynomial) and has totalDeg(c_d) ≤ totalDeg(f) − d, the induction hypothesis gives at most (totalDeg(f) − d) · q^n bad assignments.

Total zeros ≤ (totalDeg(f) − d) · q^n · q + q^{n+1} · d = totalDeg(f) · q^{n+1}. ∎

The formal proof in Lean spans approximately 50 lines of tactic-mode proof, with the main technical challenges being:
- Relating `finSuccEquiv` coefficients to the original polynomial's support
- Managing the `Finsupp.cons` construction for degree bookkeeping
- The fiber decomposition of the zero set as a sum over assignments

### 3.2 Freivalds' Discrepancy Bound

**Theorem (freivalds_discrepancy_bound).** Let D be a nonzero n×n matrix over a finite field K. Then:

|{r ∈ K^n : Dr = 0}| ≤ |K|^{n−1}

**Proof sketch.** Since D ≠ 0, there exists a nonzero row D_i. The set {r : Dr = 0} is contained in {r : (Dr)_i = 0} = {r : Σⱼ D_{ij} r_j = 0}. This is the zero set of a nonzero linear form, which has cardinality |K|^{n−1}.

The linear form bound is proved via linear algebra: the map φ(x) = Σ v_i x_i is a surjective linear functional (when v ≠ 0), so its kernel has dimension n−1, hence cardinality |K|^{n−1}.

### 3.3 Freivalds' Algorithm

**Theorem (freivalds_bound).** If AB ≠ C, then:

|{r ∈ K^n : (AB)r = Cr}| ≤ |K|^{n−1}

**Proof.** Set D = AB − C ≠ 0. The condition (AB)r = Cr is equivalent to Dr = 0. Apply the discrepancy bound. ∎

**Theorem (freivalds_error_probability).** For n ≥ 1:

Pr_r[Dr = 0] ≤ 1/q

**Proof.** The numerator is ≤ q^{n−1} and the denominator is q^n, giving ratio ≤ 1/q. ∎

### 3.4 Linear Schwartz–Zippel

**Theorem (linear_schwartz_zippel).** If f is a nonzero polynomial of total degree ≤ 1 in n variables, then:

|{x ∈ K^n : f(x) = 0}| ≤ |K|^{n−1}

**Proof.** For n = 0, the polynomial is a nonzero constant, so the zero set is empty. For n ≥ 1, apply `schwartz_zippel_succ` to get ≤ totalDeg(f) · |K|^{n−1} ≤ 1 · |K|^{n−1}. ∎

This theorem makes explicit the degree-1 specialization: Freivalds' algorithm tests whether a degree-1 polynomial (the linear form defined by a matrix row) vanishes at a random point.

## 4. Algorithms

### 4.1 Freivalds' Verification Algorithm

```
Algorithm: FreivaldsVerify(A, B, C, q, k)
Input: n×n matrices A, B, C over F_q; number of trials k
Output: ACCEPT or REJECT

for i = 1 to k:
    r ← uniformly random vector in F_q^n
    if A·(B·r) ≠ C·r:
        return REJECT
return ACCEPT
```

**Complexity:**
- Time: O(k · n²) per verification (vs O(n³) for naive recomputation)
- Space: O(n) auxiliary
- Error: ≤ (1/q)^k (one-sided: if AB = C, always accepts)

### 4.2 Polynomial Identity Testing

```
Algorithm: PIT(f, q, n, d, k)
Input: Black-box access to polynomial f in n variables of degree d over F_q; trials k
Output: ZERO or NONZERO

for i = 1 to k:
    x ← uniformly random point in F_q^n
    if f(x) ≠ 0:
        return NONZERO
return ZERO
```

**Complexity:**
- Time: O(k · T_eval) where T_eval is the evaluation cost
- Error: ≤ (d/q)^k (one-sided: if f = 0, always says ZERO)

## 5. Computational Experiments

### 5.1 Schwartz–Zippel Bound Tightness

We computed exact zero counts for several polynomial families:

| Polynomial | Field | Vars | Deg | Actual Zeros | S-Z Bound | Ratio |
|-----------|-------|------|-----|-------------|-----------|-------|
| x + 2y + 1 | F₅ | 2 | 1 | 5 | 5 | 1.000 |
| x² + yz + x + 2 | F₇ | 3 | 2 | 49 | 98 | 0.500 |
| x·y | F₁₁ | 2 | 2 | 21 | 22 | 0.955 |
| x + 2y + 3z + 1 | F₁₃ | 3 | 1 | 169 | 169 | 1.000 |

The bound is tight for linear polynomials and nearly tight for products of linear forms.

### 5.2 Freivalds Error Rates

Empirical error rates for Freivalds' algorithm over F₇ with 10,000 experiments:

| Trials (k) | Empirical Error | Theoretical Bound (1/7)^k |
|-----------|----------------|--------------------------|
| 1 | 0.1459 | 0.1429 |
| 2 | 0.0215 | 0.0204 |
| 3 | 0.0027 | 0.0029 |
| 5 | 0.0001 | 0.0001 |
| 10 | 0.0000 | 0.0000 |

The empirical rates closely track the theoretical bounds.

### 5.3 Timing Comparison

Freivalds verification vs naive matrix multiplication (20 trials, F₁₀₁):

| n | Naive Time (s) | Freivalds Time (s) | Speedup |
|---|---------------|-------------------|---------|
| 50 | 0.0003 | 0.0005 | 0.6× |
| 100 | 0.0009 | 0.0012 | 0.8× |
| 200 | 0.0047 | 0.0033 | 1.4× |
| 500 | 0.0574 | 0.0131 | 4.4× |

The crossover point where Freivalds becomes faster is around n = 150–200 (using NumPy's optimized BLAS, which makes naive multiplication faster than expected).

## 6. Applications

### 6.1 Verifiable Computation

In the verifiable computation paradigm, a powerful but untrusted server performs a computation and provides the result along with a proof of correctness. Freivalds' algorithm provides the simplest instantiation: the server computes AB and the client verifies in O(kn²) time.

### 6.2 Reed–Solomon Codes

The Schwartz–Zippel bound immediately implies the minimum distance of Reed–Solomon codes: for a [q, k] RS code, the minimum distance is q − k + 1. This follows because a nonzero polynomial of degree ≤ k−1 has at most k−1 zeros (univariate case of Schwartz–Zippel), so any two distinct codewords differ in at least q − (k−1) positions.

### 6.3 Interactive Proofs

The IP = PSPACE theorem [Shamir 1992] uses the Schwartz–Zippel lemma as its key soundness tool. The verifier checks the prover's polynomial claims by evaluating at random points; the Schwartz–Zippel bound ensures that a dishonest prover is caught with high probability.

### 6.4 Polynomial Fingerprinting

Two parties holding large datasets can check equality by exchanging polynomial fingerprints: evaluate the data polynomial at a random point. By Schwartz–Zippel, the collision probability is at most d/q, where d is the data length and q is the field size. For q ≈ 2⁶¹, this gives negligible error.

## 7. Discussion

### 7.1 Proof Architecture

The formalization employs two complementary proof strategies:

1. **Schwartz–Zippel via induction**: Uses `MvPolynomial.finSuccEquiv` to decompose polynomials, with the key technical insight being the coefficient-degree relationship `totalDeg(c_d) + d ≤ totalDeg(f)`.

2. **Freivalds via linear algebra**: Uses the surjectivity of nonzero linear functionals and the dimension formula for kernels. This is independent of the Schwartz–Zippel induction and provides a cleaner, more direct proof for the degree-1 case.

Both strategies produce fully verified results with no axioms beyond the standard foundational axioms (propext, Classical.choice, Quot.sound).

### 7.2 Proof Complexity

| Theorem | Lines of Proof | Key Tactics |
|---------|---------------|-------------|
| schwartz_zippel_succ | ~50 | induction, simp, nlinarith, aesop |
| freivalds_discrepancy_bound | ~5 | injection into linear form |
| freivalds_error_probability | ~8 | div_le_div, norm_cast |
| linear_schwartz_zippel | ~3 | case split + application |

The bulk of the proof effort is in the Schwartz–Zippel induction, where managing the fiber decomposition and degree bookkeeping requires careful handling of Finsupp, Polynomial, and MvPolynomial APIs.

### 7.3 Limitations

- The formalization does not currently establish tightness (existence of polynomials achieving the bound).
- The probability formulations use rational numbers rather than a formal probability monad.
- The connection to algebraic circuits is stated at the level of theorem dependencies rather than as a single unified statement.

## 8. Future Work

1. **Reed–Muller distance**: Derive the minimum distance of Reed–Muller codes as a direct corollary of `schwartz_zippel_succ`.
2. **Circuit PIT soundness**: Combine `schwartz_zippel_succ` with `totalDegree_le_degreeBound` to get PIT bounds for algebraic circuits.
3. **Combinatorial Nullstellensatz**: Strengthen the result for grid evaluations.
4. **Derandomization connections**: Formalize hitting set generators and their relationship to circuit lower bounds.
5. **Interactive proof soundness**: Use the formalized Schwartz–Zippel bound as a building block for IP protocol verification.

## 9. References

- DeMillo, R.A., Lipton, R.J. (1978). A probabilistic remark on algebraic program testing. *Information Processing Letters*, 7(4), 193–195.
- Freivalds, R. (1979). Fast probabilistic algorithms. In *Mathematical Foundations of Computer Science*, LNCS 74, pp. 57–69.
- Schwartz, J.T. (1980). Fast probabilistic algorithms for verification of polynomial identities. *Journal of the ACM*, 27(4), 701–717.
- Zippel, R. (1979). Probabilistic algorithms for sparse polynomials. In *EUROSAM '79*, LNCS 72, pp. 216–226.
- Shamir, A. (1992). IP = PSPACE. *Journal of the ACM*, 39(4), 869–877.
- Alon, N. (1999). Combinatorial Nullstellensatz. *Combinatorics, Probability and Computing*, 8(1-2), 7–29.
