# Freivalds as the Degree-1 Shadow of Schwartz–Zippel over Finite Fields: A Certified Algebraic Bridge

## Abstract

We present a complete formalization of the Schwartz–Zippel lemma over finite fields and derive Freivalds' randomized matrix multiplication verification algorithm as its degree-1 specialization. The proof stack establishes a certified pipeline from multivariate polynomial zero-counting to randomized algorithmic verification, demonstrating that Freivalds' algorithm is not an isolated trick but the first nontrivial instance of polynomial identity testing (PIT) over finite fields. Our formalization includes: (1) a fiber polynomial construction for decomposing multivariate polynomials via `finSuccEquiv`, (2) the full Schwartz–Zippel induction with sharp degree tracking, (3) linear form zero-set bounds via kernel dimension arguments, (4) Freivalds' bound in both counting and probability forms over `ZMod q`, and (5) specializations connecting the algebraic and algorithmic viewpoints. All theorems are machine-verified and depend only on the standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

### 1.1 Motivation

The Schwartz–Zippel lemma [Schwartz 1980, Zippel 1979, DeMillo–Lipton 1978] is one of the most widely used tools in theoretical computer science. It states that a nonzero multivariate polynomial of total degree d over a finite field of q elements has at most d · q^{n−1} zeros in the n-dimensional affine space. Despite its elementary statement, it underlies polynomial identity testing, interactive proof systems, derandomization theory, coding bounds, and algebraic circuit complexity.

Freivalds' algorithm [Freivalds 1979] is a randomized procedure for verifying matrix multiplication: given n×n matrices A, B, C, it checks whether AB = C by sampling a random vector r and testing whether (AB)r = Cr. If AB ≠ C, the test detects the error with probability at least 1 − 1/q over ZMod q.

The folklore observation that Freivalds' bound is the degree-1 case of Schwartz–Zippel has been noted in textbooks (e.g., Motwani–Raghavan 1995, Arora–Barak 2009) but has never been formalized in a proof assistant. Our contribution makes this connection machine-certified and reusable.

### 1.2 Contributions

1. **Schwartz–Zippel Lemma (Theorem `schwartz_zippel_succ`)**: For any nonzero polynomial f ∈ K[x₁,...,x_{n+1}] over a finite field K, the number of zeros is at most totalDegree(f) · |K|^n.

2. **Linear Specialization (Theorem `linear_schwartz_zippel`)**: For degree ≤ 1, the bound simplifies to |K|^{n−1}.

3. **Freivalds' Discrepancy Bound (Theorem `freivalds_discrepancy_bound`)**: For a nonzero matrix D over K, the number of vectors r with Dr = 0 is at most |K|^{n−1}.

4. **Probability Form (Theorem `freivalds_error_probability`)**: The error probability of Freivalds' algorithm is at most 1/q.

5. **ZMod Specializations**: All bounds instantiated over ZMod q for prime q.

### 1.3 Relationship to Prior Work

The `NullstellensatzPIT.lean` file in the project provides `univariate_root_bound` and circuit-polynomial connections (`bounded_circuit_degree_bound`, `mulGates_lower_bound_from_degree`). Our Schwartz–Zippel formalization builds on the same algebraic infrastructure and is designed for downstream composition with these circuit complexity results.

## 2. Definitions and Notation

### 2.1 Setting

Throughout, K denotes a finite field (type with `[Field K] [Fintype K]`), and n ≥ 0 is the number of variables. We work with `MvPolynomial (Fin m) K` for multivariate polynomials and `Polynomial K` for univariate polynomials.

### 2.2 Key Definitions

**Fiber Polynomial.** Given f ∈ K[x₀, x₁, ..., xₙ] and an assignment a : Fin n → K to the "tail" variables, the fiber polynomial is the univariate polynomial in x₀ obtained by specializing:

```
fiberPoly(f, a) := Polynomial.map (MvPolynomial.eval a) (finSuccEquiv K n f)
```

This uses the ring isomorphism `finSuccEquiv : MvPolynomial (Fin (n+1)) K ≃ₐ Polynomial (MvPolynomial (Fin n) K)` to view f as a univariate polynomial over the coefficient ring MvPolynomial (Fin n) K, then evaluates the coefficients at a.

**Zero Set Cardinality.** We count zeros as `Fintype.card {x : Fin m → K // MvPolynomial.eval x f = 0}`.

**Dot Product Linear Map.** For v : Fin n → K, we define `dotProductLinearMap v : (Fin n → K) →ₗ[K] K` by `x ↦ ∑ᵢ vᵢ · xᵢ`.

### 2.3 Total Degree

The total degree `MvPolynomial.totalDegree f` is the maximum over all monomials in the support of f of the sum of their exponents. The degree with respect to a single variable is `MvPolynomial.degreeOf i f`.

## 3. Main Results

### 3.1 Fiber Polynomial Properties

**Theorem (Evaluation Identity).** For f ∈ K[x₀,...,xₙ], a : Fin n → K, and t : K:
```
eval t (fiberPoly f a) = MvPolynomial.eval (Fin.cons t a) f
```

*Proof.* Unfold `fiberPoly`, apply `Polynomial.eval_map`, and use `MvPolynomial.eval_eq_eval_mv_eval'` which relates the evaluation of the `finSuccEquiv` image to evaluation of the original polynomial at a consed assignment. □

**Theorem (Degree Bound).** `natDegree(fiberPoly f a) ≤ totalDegree(f)`.

*Proof.* The fiber polynomial's degree is at most the degree of the `finSuccEquiv` image (by `natDegree_map_le`), which equals `degreeOf 0 f` (by `MvPolynomial.natDegree_finSuccEquiv`), which is at most `totalDegree f` (by `degreeOf_le_totalDegree`). □

### 3.2 Schwartz–Zippel Base Case

**Theorem (`schwartz_zippel_one`).** For nonzero f ∈ K[x₁] (one variable):
```
card {x : Fin 1 → K | eval x f = 0} ≤ totalDegree(f)
```

*Proof sketch.* Convert f to a univariate polynomial g via `eval₂ Polynomial.C (fun _ => X)`. The zeros of f correspond bijectively (via the unique map Fin 1 → K ↔ K) to roots of g. By the standard root bound, g has at most natDegree(g) roots. We show natDegree(g) ≤ totalDegree(f) by bounding the degree of each monomial term. □

### 3.3 Schwartz–Zippel Inductive Step

**Theorem (`schwartz_zippel_succ`).** For nonzero f ∈ K[x₀,...,xₙ]:
```
card {x : Fin (n+1) → K | eval x f = 0} ≤ totalDegree(f) · |K|^n
```

*Proof.* By induction on n.

**Base case (n = 0):** Follows from `schwartz_zippel_one`.

**Inductive step (n → n+1):** Let d = degreeOf 0 f and let c_d be the leading coefficient of f viewed as a polynomial in x₀ (i.e., the coefficient of x₀^d in the `finSuccEquiv` decomposition). This c_d is a polynomial in the remaining n+1 variables.

Partition the assignments a : Fin (n+1) → K into:
- **Bad assignments** where c_d vanishes: the fiber fiberPoly(f, a) might be zero, contributing at most |K| zeros each. By the induction hypothesis, there are at most totalDegree(c_d) · |K|^n such assignments.
- **Good assignments** where c_d(a) ≠ 0: the fiber fiberPoly(f, a) is a nonzero polynomial of degree ≤ d, contributing at most d zeros each by the univariate root bound. There are at most |K|^{n+1} such assignments.

The total count satisfies:
```
#zeros ≤ totalDegree(c_d) · |K|^n · |K| + |K|^{n+1} · d
```

Since totalDegree(c_d) ≤ totalDegree(f) − d (each monomial contributing to c_d has x₀-exponent exactly d, so the remaining exponents sum to at most totalDegree(f) − d), we get:
```
#zeros ≤ (totalDegree(f) − d) · |K|^{n+1} + d · |K|^{n+1} = totalDegree(f) · |K|^{n+1}
```
which is the desired bound. □

### 3.4 Coefficient Degree Bound

**Key Lemma.** If c_d is the degree-d coefficient of f in the `finSuccEquiv` decomposition, then `totalDegree(c_d) ≤ totalDegree(f) − d`.

*Proof.* Each monomial m in the support of c_d corresponds to a monomial `Finsupp.cons d m` in the support of f (by `finSuccEquiv_coeff_coeff`). The total degree of this monomial is d + sum(m), so sum(m) ≤ totalDegree(f) − d. Taking the supremum over all m in the support gives the result. □

### 3.5 ZMod Specialization

**Theorem (`schwartz_zippel_zmod`).** Over ZMod q with q prime:
```
card {x : Fin (n+1) → ZMod q | eval x f = 0} ≤ totalDegree(f) · q^n
```

*Proof.* Direct from `schwartz_zippel_succ` using `ZMod.card q = q`. □

### 3.6 Linear Specialization

**Theorem (`linear_schwartz_zippel`).** For nonzero f with totalDegree(f) ≤ 1:
```
card {x : Fin n → K | eval x f = 0} ≤ |K|^{n−1}
```

*Proof.* For n = 0, f is a nonzero constant, so the zero set is empty. For n = m + 1, apply `schwartz_zippel_succ` to get ≤ totalDegree(f) · |K|^m ≤ 1 · |K|^m = |K|^{(m+1)−1}. □

**Theorem (`linear_zero_probability_le`).** Under the same hypotheses:
```
card {x | eval x f = 0} / card(Fin n → K) ≤ 1 / |K|
```

*Proof.* From `linear_schwartz_zippel`, noting card(Fin n → K) = |K|^n. □

### 3.7 Nonzero Linear Form Bound

**Theorem (`nonzero_linear_form_zero_set_bound`).** For nonzero v : Fin n → K:
```
card {x : Fin n → K | ∑ᵢ vᵢxᵢ = 0} ≤ |K|^{n−1}
```

*Proof.* The zero set is isomorphic to the kernel of `dotProductLinearMap v`. Since v ≠ 0, this linear map is surjective (choose the coordinate where v is nonzero, solve for it). By rank-nullity, the kernel has dimension n − 1 over K, so its cardinality is |K|^{n−1}. □

### 3.8 Freivalds' Bounds

**Theorem (`freivalds_discrepancy_bound`).** For nonzero D : Matrix (Fin n) (Fin n) K:
```
card {r : Fin n → K | D.mulVec r = 0} ≤ |K|^{n−1}
```

*Proof.* Since D ≠ 0, some row i has D i ≠ 0 (by `exists_nonzero_row_of_ne_zero`). The condition D.mulVec r = 0 implies (D.mulVec r) i = ∑ⱼ D i j · r j = 0. The map r ↦ (r, proof that ∑ⱼ Dᵢⱼrⱼ = 0) is an injection from {r | Dr = 0} into {r | ∑ⱼ Dᵢⱼrⱼ = 0}. Apply `nonzero_linear_form_zero_set_bound`. □

**Theorem (`freivalds_bound`).** For A, B, C with AB ≠ C:
```
card {r | (AB).mulVec r = C.mulVec r} ≤ |K|^{n−1}
```

*Proof.* Set D = AB − C ≠ 0. The condition (AB)r = Cr is equivalent to Dr = 0. Apply `freivalds_discrepancy_bound`. □

**Theorem (`freivalds_error_probability`).** Over ZMod q:
```
card {r | D.mulVec r = 0} / q^n ≤ 1/q
```

*Proof.* From `freivalds_zmod_bound`, the numerator is ≤ q^{n−1}. Dividing by q^n = q · q^{n−1} gives ≤ 1/q. □

## 4. Algorithms

### 4.1 Freivalds' Algorithm

**Input:** n×n matrices A, B, C over 𝔽_q, repetition parameter k.
**Output:** "EQUAL" or "NOT EQUAL" (with one-sided error).

```
procedure Freivalds(A, B, C, k):
    for i = 1 to k:
        r ← uniform random vector in 𝔽_q^n
        if A · (B · r) ≠ C · r:
            return "NOT EQUAL"
    return "EQUAL"
```

**Complexity:**
- Time: O(kn²) — each iteration requires two matrix-vector products.
- Space: O(n) additional space for the random vector and products.
- Error: If AB ≠ C, Pr[output "EQUAL"] ≤ (1/q)^k.

**Comparison:** Naïve verification (compute AB and compare) costs O(n³) time (or O(n^ω) with fast matrix multiplication). Freivalds achieves O(n²) per iteration, a significant speedup.

### 4.2 Schwartz–Zippel PIT

**Input:** An algebraic circuit C computing f ∈ 𝔽_q[x₁,...,xₙ] of degree d.
**Output:** "ZERO" or "NONZERO" (with one-sided error).

```
procedure SZ_PIT(C, d, q, k):
    for i = 1 to k:
        r ← uniform random point in 𝔽_q^n
        if C.eval(r) ≠ 0:
            return "NONZERO"
    return "ZERO"
```

**Error:** If f ≠ 0, Pr[output "ZERO"] ≤ (d/q)^k.

## 5. Applications

### 5.1 Matrix Multiplication Verification

Given matrices A (m×p), B (p×n), and a claimed product C (m×n) over 𝔽_q, verify AB = C in O(k(m+n)p) time with error ≤ q^{−k}. This is used in:
- Verified numerical linear algebra
- Distributed computing (checking results from untrusted nodes)
- Certificate-based proof systems

### 5.2 Polynomial Identity Testing for Circuits

Given an algebraic circuit of size s with m multiplication gates computing a polynomial of degree ≤ 2^m, Schwartz–Zippel gives a randomized test with error ≤ 2^m/q per trial. Combined with `bounded_circuit_degree_bound`, this yields circuit-aware PIT bounds.

### 5.3 Reed–Muller Code Distance

The Schwartz–Zippel bound directly implies that the minimum distance of the Reed–Muller code RM(d, n, q) is at least (q − d) · q^{n−1}. This is tight for d < q and provides the foundation for:
- Error correction in communication systems
- Locally decodable codes
- Low-degree testing for probabilistically checkable proofs

## 6. Computational Experiments

We provide Python implementations demonstrating:

1. **Freivalds' Algorithm**: Empirical verification that the error rate matches the theoretical 1/q bound across various matrix sizes and field sizes.

2. **Zero Set Counting**: Exhaustive enumeration of zeros of random polynomials over small finite fields, confirming the Schwartz–Zippel bound.

3. **Probability Convergence**: Visualization of how the empirical zero fraction converges to the theoretical bound as the field size grows.

See `demo.py`, `algorithms.py`, and `applications.py` for implementations and `visualizations/` for generated figures.

## 7. Discussion

### 7.1 Proof Architecture

Our proof of Schwartz–Zippel follows the classical induction on the number of variables, but with several technical choices dictated by the formalization context:

- **Successor formulation**: We state the theorem for `Fin (n+1)` rather than `Fin n` to avoid the `n − 1` exponent in the bound, which causes natural number subtraction issues.
- **finSuccEquiv decomposition**: Rather than manually constructing coefficient extraction, we use the Mathlib ring isomorphism `MvPolynomial.finSuccEquiv` which provides a clean interface.
- **Kernel dimension for linear forms**: For Freivalds, we avoid the full Schwartz–Zippel machinery and give a direct proof via linear algebra (kernel of a surjective linear map has codimension 1), which is both simpler and more transparent.

### 7.2 Limitations

- The formalization covers finite fields but not evaluation over arbitrary finite subsets S ⊆ K (the "grid" version of Schwartz–Zippel). The grid version is needed for the Combinatorial Nullstellensatz.
- We do not formalize probability distributions or random sampling; instead, we use cardinality bounds that imply probability bounds by finite counting.
- The connection to algebraic circuits is stated but not fully exploited: composing `schwartz_zippel_succ` with `bounded_circuit_degree_bound` requires additional interface work.

### 7.3 Comparison with Textbook Proofs

Our proof closely follows Motwani–Raghavan (1995, Section 7.2) and Arora–Barak (2009, Theorem 7.2). The main departure is the coefficient degree bound lemma (Section 3.4), where we track the relationship between `Finsupp.cons` and `Finsupp.sum` explicitly rather than reasoning about "the degree drops by at least 1" informally.

## 8. Future Work

See `FUTURE_DIRECTIONS.md` for a detailed roadmap. The highest-priority directions are:

1. **Reed–Muller minimum distance** from Schwartz–Zippel.
2. **Circuit PIT soundness** composing with `bounded_circuit_degree_bound`.
3. **Grid Schwartz–Zippel** for the Combinatorial Nullstellensatz.
4. **Low-degree testing** for PCP/IOP foundations.
5. **Polynomial fingerprinting** for streaming and communication complexity.

## 9. References

- N. Alon. Combinatorial Nullstellensatz. *Combinatorics, Probability and Computing*, 8(1-2):7–29, 1999.
- S. Arora and B. Barak. *Computational Complexity: A Modern Approach*. Cambridge University Press, 2009.
- R. A. DeMillo and R. J. Lipton. A probabilistic remark on algebraic program testing. *Information Processing Letters*, 7(4):193–195, 1978.
- R. Freivalds. Fast probabilistic algorithms. In *Mathematical Foundations of Computer Science*, LNCS 74:57–69, 1979.
- V. Kabanets and R. Impagliazzo. Derandomizing polynomial identity tests means proving circuit lower bounds. *Computational Complexity*, 13(1-2):1–46, 2004.
- R. Motwani and P. Raghavan. *Randomized Algorithms*. Cambridge University Press, 1995.
- J. T. Schwartz. Fast probabilistic algorithms for verification of polynomial identities. *Journal of the ACM*, 27(4):701–717, 1980.
- R. Zippel. Probabilistic algorithms for sparse polynomials. In *EUROSAM '79*, LNCS 72:216–226, 1979.
