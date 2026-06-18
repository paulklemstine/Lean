# Sparse-Support Certificate Compression for Matroid Basis Polynomials

## Abstract

We establish that the recursion tree for Lorentzian recognition of matroid basis generating polynomials is isomorphic to the matroid's independent-set complex truncated at rank r−2. Specifically, for a rank-r matroid M on ground set [n], the number of nonzero quadratic derivative leaves of the basis generating polynomial B_M equals the number of independent (r−2)-sets of M. This replaces the ambient worst-case leaf count C(n, r−2) by a support-controlled complexity measure governed by the matroid's combinatorial geometry. We prove exact closed forms for uniform matroids (C(n, r−2)), establish a support compression bound in terms of active variable count, and provide a verified counting algorithm. All results are formalized in Lean 4 with complete machine-checked proofs.

**Keywords:** Lorentzian polynomials, matroid basis generating polynomial, M-convexity, certificate complexity, support compression, independent set enumeration

## 1. Introduction

### 1.1 Background

Lorentzian polynomials, introduced by Brändén and Huh [BH20], provide a powerful framework for establishing log-concavity and related inequalities in combinatorics. A homogeneous polynomial f of degree r with nonneg coefficients is *Lorentzian* if every iterated partial derivative of degree r−2 yields a quadratic form with at most one positive eigenvalue. Verification of this property requires examining all degree-(r−2) derivative branches — a recursion tree whose naive size is C(n, r−2), where n is the number of variables.

For matroid basis generating polynomials — which are always Lorentzian [BH20, Theorem 3.10] — this certification cost can be reduced by exploiting the polynomial's support structure. This paper develops the theory of *support-compressed certificate counting* and proves that the effective certification cost is controlled by the matroid's independent-set geometry.

### 1.2 Main Contributions

1. **Derivative Survival Criterion (Theorem 1):** For the basis generating polynomial B_M of a matroid M, the iterated derivative ∂_S B_M is nonzero if and only if S is independent in M.

2. **Leaf Count Identity (Theorem 2):** The number of nonzero quadratic derivative leaves equals the number of independent (r−2)-sets: #{I ⊆ [n] : |I| = r−2, I independent in M}.

3. **Uniform Matroid Closed Form (Theorem 3):** For U_{r,n}, the leaf count is exactly C(n, r−2).

4. **Support Compression Bound (Theorem 4):** For any matroid, the leaf count is at most C(k, r−2), where k is the number of active variables (those appearing in at least one basis).

5. **Verified Algorithm:** A combinatorial counting algorithm that computes certificate complexity from basis data without polynomial differentiation, with formal correctness proof.

### 1.3 Related Work

- Brändén–Huh [BH20] introduced Lorentzian polynomials and proved that matroid basis polynomials are Lorentzian.
- Murota [Mur03] developed discrete convex analysis and M-convex sets, which characterize Lorentzian polynomial supports.
- Anari–Liu–Oveis Gharan–Vinzant [ALOGV18] proved log-concavity of matroid basis polynomial coefficients via connections to completely log-concave polynomials.

Our contribution is orthogonal: we analyze the *computational complexity* of Lorentzian certification, not the Lorentzian property itself.

## 2. Definitions and Notation

### 2.1 Matroid Basics

A *matroid* M = (E, B) consists of a finite ground set E and a nonempty family B of *bases* — subsets of E all having the same cardinality r (the *rank*), satisfying the basis exchange axiom. A subset I ⊆ E is *independent* if I ⊆ B for some basis B ∈ B.

We work with the abstraction of a *basis family*: a nonempty collection of r-element subsets of [n] = {0, ..., n−1}.

### 2.2 Basis Generating Polynomial

For a basis family F with bases B, the *basis generating polynomial* is:

$$B_F(x_1, \ldots, x_n) = \sum_{B \in \mathcal{B}} \prod_{i \in B} x_i$$

This is homogeneous of degree r, multiaffine (each variable appears with exponent ≤ 1), and has all coefficients equal to 0 or 1.

### 2.3 Indicator Finsupp

We encode sets as indicator functions: for S ⊆ [n], define `indicatorFinsupp(S) : [n] →₀ ℕ` by:

$$\text{indicatorFinsupp}(S)(i) = \begin{cases} 1 & \text{if } i \in S \\ 0 & \text{otherwise} \end{cases}$$

This is injective (Lemma `indicatorFinsupp_injective`).

### 2.4 Iterated Partial Derivatives

We define `derivByList vars f` as the sequential application of partial derivatives ∂/∂x_i for each i in the list `vars`:

```
derivByList [] f = f
derivByList (i :: rest) f = derivByList rest (∂f/∂x_i)
```

Since partial derivatives of polynomials commute, the result is independent of the ordering of `vars`.

### 2.5 Certificate Complexity

The *support-compressed leaf count* of a basis family F of rank r is:

$$\text{SCLC}(F) = |\{I \subseteq [n] : |I| = r-2,\ I \text{ is independent in } F\}|$$

The *ambient leaf count* is C(n, r−2).

## 3. Main Results

### 3.1 Monomial Derivative Lemmas

**Lemma (pderiv_indicatorMonomial_mem).** If i ∈ B, then:
$$\frac{\partial}{\partial x_i} \mathbf{x}^{\text{ind}(B)} = \mathbf{x}^{\text{ind}(B \setminus \{i\})}$$

**Lemma (pderiv_indicatorMonomial_nmem).** If i ∉ B, then:
$$\frac{\partial}{\partial x_i} \mathbf{x}^{\text{ind}(B)} = 0$$

*Proof.* By Mathlib's `MvPolynomial.pderiv_monomial`, the derivative of monomial(β, c) by x_i is monomial(β − e_i, c · β(i)). For the indicator β = ind(B), β(i) = 1 if i ∈ B (giving coefficient 1) and β(i) = 0 if i ∉ B (giving coefficient 0, hence the zero polynomial). The index β − e_i = ind(B \ {i}) when i ∈ B.

### 3.2 Iterated Derivative of Indicator Monomials

**Theorem (derivByList_indicatorMonomial_subset).** For a nodup list `vars` with `vars.toFinset ⊆ B`:
$$\partial_{\text{vars}} \mathbf{x}^{\text{ind}(B)} = \mathbf{x}^{\text{ind}(B \setminus \text{vars.toFinset})}$$

**Theorem (derivByList_indicatorMonomial_not_subset).** For a nodup list `vars` with `vars.toFinset ⊄ B`:
$$\partial_{\text{vars}} \mathbf{x}^{\text{ind}(B)} = 0$$

*Proof.* By induction on the list. At each step, if the current variable i is in the remaining basis, apply `pderiv_indicatorMonomial_mem` to reduce; if not, the monomial becomes zero and stays zero.

### 3.3 Theorem 1: Derivative Survival Criterion

**Theorem (derivByList_basisGenPoly_ne_zero_iff).** For a basis family with bases B and a nodup variable list `vars`:

$$\partial_{\text{vars}} B_F \neq 0 \iff \exists B \in \mathcal{B},\ \text{vars.toFinset} \subseteq B$$

*Proof sketch.*
1. By linearity (`derivByList_sum`), distribute the derivative across the sum: $\partial_{\text{vars}} B_F = \sum_{B \in \mathcal{B}} \partial_{\text{vars}} \mathbf{x}^{\text{ind}(B)}$.
2. Each term is either $\mathbf{x}^{\text{ind}(B \setminus S)}$ (if S ⊆ B) or 0 (otherwise).
3. The surviving terms have *distinct* exponent vectors: if B₁ ≠ B₂ and S ⊆ B₁ ∩ B₂, then B₁ \ S ≠ B₂ \ S, hence ind(B₁ \ S) ≠ ind(B₂ \ S) by injectivity of `indicatorFinsupp`.
4. A sum of distinct monomials with coefficient 1 is nonzero iff at least one term survives.
5. Therefore the derivative is nonzero iff ∃ B ∈ B with S ⊆ B, i.e., S is independent.

### 3.4 Theorem 2: Leaf Count = Independent Set Count

By Theorem 1, the set of (r−2)-element subsets S for which ∂_S B_F ≠ 0 is precisely the family of independent (r−2)-sets. Therefore:

$$\#\{\text{nonzero quadratic leaves}\} = \#\{I \subseteq [n] : |I| = r-2,\ I \text{ independent}\} = \text{SCLC}(F)$$

### 3.5 Theorem 3: Uniform Matroid Closed Form

**Theorem (leafCount_uniformMatroid).** For the uniform matroid U_{r,n} with 2 ≤ r ≤ n:

$$\text{SCLC}(U_{r,n}) = \binom{n}{r-2}$$

*Proof.* In U_{r,n}, every r-element subset is a basis. Therefore every subset of size ≤ r is independent. In particular, every (r−2)-element subset is independent, so the independent (r−2)-sets are exactly all (r−2)-element subsets of [n], of which there are C(n, r−2).

### 3.6 Theorem 4: Support Compression Bound

**Theorem (indepCount_le_active_choose).** For any basis family F of rank r on [n]:

$$\text{SCLC}(F) \leq \binom{|\text{active}(F)|}{r-2}$$

where active(F) = ∪_{B ∈ B} B is the set of variables appearing in at least one basis.

*Proof.* Every independent set is a subset of some basis, hence a subset of active(F). Therefore every independent (r−2)-set is an (r−2)-element subset of active(F), and there are at most C(|active(F)|, r−2) such subsets.

**Corollary.** If bases use only k ≪ n variables, then SCLC(F) ≤ C(k, r−2) ≪ C(n, r−2).

## 4. Algorithms

### 4.1 Support-Compressed Leaf Counting

**Algorithm 1: CountNonzeroQuadraticLeaves**

```
Input: Basis family F = (n, r, bases)
Output: Number of nonzero quadratic leaves

1. For each (r-2)-subset S of [n]:
   a. For each basis B in bases:
      - If S ⊆ B: mark S as independent; break
   b. If S is independent: increment counter
2. Return counter
```

**Complexity:** O(C(n, r−2) · |bases| · r) time, O(1) extra space.

**Correctness:** By Theorem 1, this counts exactly the nonzero derivative branches.

### 4.2 Optimized Version for Sparse Matroids

When the active variable set is small:

```
Input: Basis family F = (n, r, bases)
Output: Number of nonzero quadratic leaves

1. Compute active = ∪_B B
2. For each (r-2)-subset S of active:
   a. Test S ⊆ B for some B
3. Return count
```

**Complexity:** O(C(|active|, r−2) · |bases| · r).

## 5. Computational Experiments

### 5.1 Uniform Matroids

| (n, r) | Ambient C(n,r−2) | Actual Leaves | Ratio |
|---------|-----------------|---------------|-------|
| (5, 3)  | 5               | 5             | 1.000 |
| (8, 4)  | 28              | 28            | 1.000 |
| (10, 5) | 120             | 120           | 1.000 |
| (12, 4) | 66              | 66            | 1.000 |

As predicted by Theorem 3, the ratio is always 1.0 for uniform matroids.

### 5.2 Restricted Matroids (Support Compression)

Embedding U_{r,k} in [n] with k active variables out of n:

| k | n  | r | Ambient C(n,r−2) | Actual C(k,r−2) | Ratio |
|---|----|----|-----------------|-----------------|-------|
| 8 | 15 | 3  | 15              | 8               | 0.533 |
| 8 | 20 | 3  | 20              | 8               | 0.400 |
| 8 | 30 | 3  | 30              | 8               | 0.267 |
| 6 | 20 | 4  | 190             | 15              | 0.079 |
| 8 | 20 | 4  | 190             | 28              | 0.147 |
| 8 | 30 | 4  | 435             | 28              | 0.064 |

The compression ratio C(k,r−2)/C(n,r−2) decreases as n grows, demonstrating Theorem 4.

### 5.3 Graphic Matroids

| Graph | Edges | Rank | Ambient | Leaves | Ratio |
|-------|-------|------|---------|--------|-------|
| Path P_4 | 3 | 3 | 3 | 3 | 1.000 |
| Cycle C_4 | 4 | 3 | 4 | 4 | 1.000 |
| K_4 | 6 | 3 | 6 | 6 | 1.000 |
| K_{3,3} | 9 | 5 | 84 | 84 | 1.000 |

For graphic matroids with rank close to edge count, most subsets are forests (independent), yielding ratios near 1.0. The compression becomes significant for graphs with high cyclomatic complexity.

## 6. Discussion

### 6.1 Algorithmic Implications

The derivative survival theorem transforms Lorentzian certification from a symbolic-algebraic problem to a combinatorial one. Instead of computing polynomial derivatives (which involves coefficient arithmetic), we test subset containment in a matroid. This is:

- **Simpler**: No polynomial arithmetic needed.
- **Faster**: For sparse matroids, the search space is vastly smaller.
- **More informative**: The independent-set structure reveals *why* certain branches survive.

### 6.2 Structural Implications

The identification of the recursion tree with the independent-set complex has deeper consequences:

1. **Matroid invariant**: The nonzero leaf count is a matroid invariant — it depends only on the matroid, not on any particular representation.

2. **Monotonicity**: Adding bases can only increase the leaf count (more independent sets). Deleting bases can only decrease it.

3. **Extremality**: The uniform matroid maximizes the leaf count among all rank-r matroids on [n].

### 6.3 Limitations

1. The current formalization works with basis families rather than full Mathlib matroids. Bridging to `Mathlib.Order.Matroid` is straightforward but requires additional API work.

2. The compression is most dramatic when the matroid has few active variables relative to n. For matroids where all variables are active (e.g., uniform matroids), there is no compression.

3. We do not address the computational cost of the individual quadratic checks (Hessian eigenvalue analysis), only their number.

## 7. Future Work

1. **Graphic matroid specialization**: Prove that for graphic matroids, the leaf count equals the number of forests of size r−2. This connects to Kirchhoff's matrix tree theorem and algebraic graph theory.

2. **Complexity bounds from matroid structure**: Derive tighter bounds on independent (r−2)-set counts from matroid parameters (girth, connectivity, minor structure).

3. **Extension to M-convex supports**: The derivative survival criterion holds for any polynomial with positive coefficients and M-convex support. Extend the certificate compression theory to general Lorentzian polynomials.

4. **Algorithmic exploitation**: Design algorithms that certify Lorentzianity in time proportional to the compressed leaf count rather than the ambient count.

## References

- [ALOGV18] N. Anari, S. Liu, S. Oveis Gharan, C. Vinzant. Log-concave polynomials II: High-dimensional walks and an FPRAS for counting bases of a matroid. *STOC*, 2019.
- [BH20] P. Brändén, J. Huh. Lorentzian polynomials. *Annals of Mathematics*, 192(3):821–891, 2020.
- [Mur03] K. Murota. *Discrete Convex Analysis*. SIAM, 2003.
- [Oxl11] J. Oxley. *Matroid Theory*, 2nd edition. Oxford University Press, 2011.
- [Sch03] A. Schrijver. *Combinatorial Optimization*. Springer, 2003.
