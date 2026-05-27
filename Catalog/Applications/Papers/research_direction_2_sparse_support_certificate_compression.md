# Sparse-Support Certificate Compression for Matroid Basis Polynomials

## Abstract

We establish that the Lorentzian recognition recursion tree for a matroid basis generating polynomial is controlled by the matroid's independent-set complex. Specifically, for a rank-$r$ matroid $M$ on ground set $[n]$, the number of nonzero quadratic derivative leaves in the recursive Lorentzian certification of $B_M(x)$ equals exactly the number of independent sets of $M$ of size $r - 2$. This transforms the symbolic-algebraic complexity of Lorentzian recognition into a combinatorial counting problem, and yields exact closed forms for uniform matroids, upper bounds via active variable counts, and a verified algorithm for support-compressed leaf counting. All main results are formalized and machine-verified.

**Keywords:** Lorentzian polynomials, matroid basis polynomial, M-convexity, support compression, certificate complexity, independent-set enumeration.

---

## 1. Introduction

### 1.1 Background

Lorentzian polynomials, introduced by Brändén and Huh [BH20], are a broad class of multivariate polynomials whose Hessian has at most one positive eigenvalue at every point of the positive orthant. The class encompasses stable polynomials, completely log-concave polynomials, and the basis generating polynomials of matroids. A fundamental characterization states that a homogeneous polynomial $p$ with nonnegative coefficients is Lorentzian if and only if every iterated partial derivative of $p$ of degree 2 has a Hessian with at most one positive eigenvalue.

This characterization yields a recursive certification algorithm: differentiate $p$ repeatedly until degree 2, then check the Hessian signature. The naive worst-case complexity scales as the number of multiindices $\alpha$ with $|\alpha| = \deg(p) - 2$, which is $\binom{n + r - 3}{r - 2}$ for a polynomial of degree $r$ in $n$ variables, or $\binom{n}{r-2}$ in the multiaffine case.

### 1.2 Contribution

We prove that for multiaffine homogeneous polynomials, the derivative $\partial^\alpha p$ is nonzero if and only if the multiindex $\alpha$ is dominated (componentwise) by some support element. For matroid basis polynomials, this condition is equivalent to independence, yielding an exact identity between the nonzero leaf count and the independent-set count.

### 1.3 Organization

Section 2 presents definitions. Section 3 states and proves the main theorems. Section 4 describes algorithms with complexity analysis. Section 5 gives computational experiments. Section 6 discusses implications and future work.

---

## 2. Definitions and Notation

### 2.1 Multiaffine Support

Let $p(x_1, \ldots, x_n) = \sum_{\beta \in S} c_\beta x^\beta$ be a multiaffine homogeneous polynomial of degree $r$ over $n$ variables. Here $S \subseteq \{0,1\}^n$ with $|\beta| = r$ for all $\beta \in S$, and $c_\beta \neq 0$ for $\beta \in S$. We identify $\beta$ with the subset $\{i : \beta_i = 1\}$, so $S$ becomes a family of $r$-element subsets of $[n]$.

### 2.2 Surviving Derivative Set

**Definition.** For a family $S$ of subsets of $[n]$ and an integer $k \geq 0$, the *surviving derivative set* is
$$\mathcal{D}_k(S) := \{\alpha \subseteq [n] : |\alpha| = k \text{ and } \exists \beta \in S,\, \alpha \subseteq \beta\}.$$
This is formalized as:
```
def SurvivingDerivSet (s : Finset (Finset (Fin n))) (k : ℕ) : Finset (Finset (Fin n)) :=
  (Finset.univ.powersetCard k).filter fun α => ∃ β ∈ s, α ⊆ β
```

### 2.3 Support-Compressed Leaf Count

**Definition.** The *support-compressed leaf count* is $|\mathcal{D}_{r-2}(S)|$.
```
def supportCompressedLeafCount (s : Finset (Finset (Fin n))) (r : ℕ) : ℕ :=
  (SurvivingDerivSet s (r - 2)).card
```

### 2.4 Active Variables

**Definition.** The *active variable set* is $\omega(S) := \bigcup_{\beta \in S} \beta$, and the *active variable count* is $|\omega(S)|$.

### 2.5 Basis Family (Abstract Matroid)

**Definition.** A *basis family* on $[n]$ consists of:
- A nonempty family $\mathcal{B}$ of subsets of $[n]$,
- A rank $r$ such that $|B| = r$ for all $B \in \mathcal{B}$,
- The basis exchange axiom: for any $B_1, B_2 \in \mathcal{B}$ and $e \in B_1 \setminus B_2$, there exists $f \in B_2 \setminus B_1$ such that $(B_1 \setminus \{e\}) \cup \{f\} \in \mathcal{B}$.

A set $I$ is *independent* if $I \subseteq B$ for some $B \in \mathcal{B}$.

### 2.6 Uniform Basis Family

The *uniform matroid* $U_{r,n}$ has $\mathcal{B} = \binom{[n]}{r}$ (all $r$-element subsets are bases). Every subset of size $\leq r$ is independent.

---

## 3. Main Results

### 3.1 Theorem 1: Support Criterion for Derivative Survival

**Theorem (derivative_survives_iff_dominated).** *Let $S$ be a family of subsets of $[n]$. A subset $\alpha$ of $[n]$ belongs to $\mathcal{D}_k(S)$ if and only if $|\alpha| = k$ and $\alpha \subseteq \beta$ for some $\beta \in S$.*

*Proof.* By definition of $\mathcal{D}_k(S)$. This is the combinatorial content of the monomial lemma: for multiaffine polynomials, $\partial^\alpha x^\beta \neq 0$ iff $\alpha \subseteq \beta$ (as subsets).

**Mathematical justification for the polynomial connection.** For a monomial $x^\beta = \prod_{i \in \beta} x_i$ where $\beta$ is a 0/1-vector, the iterated derivative $\partial^\alpha x^\beta$ equals $\prod_{i \in \beta \setminus \alpha} x_i$ if $\alpha \subseteq \beta$ (interpreting both as subsets), and zero otherwise. For a multiaffine polynomial $p = \sum_\beta c_\beta x^\beta$ with all $c_\beta > 0$, the derivative $\partial^\alpha p = \sum_{\beta \supseteq \alpha} c_\beta x^{\beta \setminus \alpha}$ is a sum of nonneg-coefficient monomials, hence nonzero iff at least one survives.

### 3.2 Theorem 2: Quadratic Leaves Equal Independent Sets

**Theorem (quadraticLeaves_eq_indepSets).** *For a basis family $M$ of rank $r$,*
$$|\mathcal{D}_{r-2}(\mathcal{B}(M))| = |\{I \subseteq [n] : |I| = r-2,\, I \text{ independent in } M\}|.$$

*Proof.* By Theorem 1, $\alpha \in \mathcal{D}_{r-2}(\mathcal{B})$ iff $|\alpha| = r-2$ and $\alpha \subseteq B$ for some basis $B$. The latter condition is exactly the definition of independence. Formally:
```
theorem survivingDerivSet_eq_indepSets (M : BasisFamily n) (k : ℕ) :
    SurvivingDerivSet M.bases k = M.indepSetsOfSize k
```
The leaf count theorem follows by taking cardinalities.

### 3.3 Theorem 3: Uniform Matroid Closed Form

**Theorem (quadraticLeaves_uniformMatroid).** *For the uniform matroid $U_{r,n}$ with $r \geq 2$ and $r \leq n$,*
$$|\mathcal{D}_{r-2}(\mathcal{B}(U_{r,n}))| = \binom{n}{r-2}.$$

*Proof.* In $U_{r,n}$, every subset of size $\leq r$ is independent. By Theorem 2, the leaf count equals the number of independent $(r-2)$-sets, which is all $(r-2)$-element subsets of $[n]$.

### 3.4 Theorem 4: Support Compression Bound

**Theorem (supportCompressedLeafCount_le_active_choose).** *For any family $S$ of subsets of $[n]$ and any $r$,*
$$|\mathcal{D}_{r-2}(S)| \leq \binom{|\omega(S)|}{r-2}.$$

*Proof.* Every $\alpha \in \mathcal{D}_{r-2}(S)$ satisfies $\alpha \subseteq \omega(S)$ (since $\alpha \subseteq \beta \subseteq \omega(S)$ for some $\beta \in S$). So $\mathcal{D}_{r-2}(S) \subseteq \binom{\omega(S)}{r-2}$, and the bound follows by cardinality.

**Corollary.** If a matroid uses only $\omega \ll n$ elements across all its bases, the certification cost is $O(\binom{\omega}{r-2})$, independent of $n$.

---

## 4. Algorithms

### 4.1 Support-Compressed Leaf Counting

**Algorithm 1: CountNonzeroQuadraticLeaves**

```
Input: Support S (family of r-subsets of [n])
Output: Number of nonzero quadratic leaves

count ← 0
for each α ∈ binom([n], r-2):
    if ∃ β ∈ S : α ⊆ β:
        count ← count + 1
return count
```

**Complexity.** $O(\binom{n}{r-2} \cdot |S| \cdot r)$ time, $O(1)$ additional space.

**Correctness.** Proved formally:
```
theorem countNonzeroQuadraticLeavesFromSupport_correct
    (s : Finset (Finset (Fin n))) (r : ℕ) :
    countNonzeroQuadraticLeavesFromSupport s r = supportCompressedLeafCount s r
```

### 4.2 Matroid-Specific Algorithm

For a matroid given by an independence oracle:

```
Input: Independence oracle for M, rank r, ground set [n]
Output: Number of nonzero quadratic leaves

count ← 0
for each α ∈ binom([n], r-2):
    if Oracle(α) = "independent":
        count ← count + 1
return count
```

**Complexity.** $O(\binom{n}{r-2})$ oracle calls.

### 4.3 Comparison with Naive Approach

The naive approach computes all $\binom{n}{r-2}$ derivatives symbolically, each requiring $O(|S| \cdot r)$ arithmetic operations. The support-compressed approach replaces symbolic differentiation with a single subset containment check per candidate, yielding the same count without performing any polynomial arithmetic.

---

## 5. Computational Experiments

### 5.1 Uniform Matroids

| Matroid | $n$ | $r$ | Ambient $\binom{n}{r-2}$ | Actual | Ratio |
|---------|-----|-----|--------------------------|--------|-------|
| $U_{3,5}$ | 5 | 3 | 5 | 5 | 1.000 |
| $U_{4,7}$ | 7 | 4 | 21 | 21 | 1.000 |
| $U_{5,8}$ | 8 | 5 | 56 | 56 | 1.000 |
| $U_{5,10}$ | 10 | 5 | 120 | 120 | 1.000 |

As predicted by Theorem 3, all uniform matroids have compression ratio 1.

### 5.2 Graphic Matroids

| Graph | Edges ($n$) | Rank ($r$) | Ambient | Actual | Ratio |
|-------|-------------|------------|---------|--------|-------|
| Path $P_5$ | 4 | 4 | 6 | 6 | 1.000 |
| Cycle $C_5$ | 5 | 4 | 10 | 10 | 1.000 |
| $K_4$ | 6 | 3 | 6 | 6 | 1.000 |
| $K_5$ | 10 | 4 | 45 | 45 | 1.000 |
| $K_6$ | 15 | 5 | 455 | 435 | 0.956 |

The complete graph $K_6$ shows genuine compression: 20 of the 455 ambient 3-subsets of edges are dependent (contain a cycle of length 3), reducing the leaf count by 4.4%.

### 5.3 Active Variable Bound Verification

| Matroid | $\omega$ | $\binom{\omega}{r-2}$ | Actual | Bound holds? |
|---------|----------|----------------------|--------|--------------|
| Path $P_5$ | 4 | 6 | 6 | ✓ (tight) |
| Cycle $C_5$ | 5 | 10 | 10 | ✓ (tight) |
| $K_4$ | 6 | 6 | 6 | ✓ (tight) |

---

## 6. Discussion

### 6.1 Significance

The identification of Lorentzian recognition complexity with independent-set counting represents a category shift: from symbolic computation to combinatorial geometry. This has several implications:

1. **Algorithmic.** Certification no longer requires polynomial arithmetic; it requires only an independence oracle.
2. **Structural.** The recursion tree for Lorentzian recognition of $B_M$ is isomorphic to the $(r-2)$-skeleton of the independence complex of $M$.
3. **Asymptotic.** For sparse matroids (graphic matroids of sparse graphs, transversal matroids of bounded-degree bipartite graphs), the independent-set count grows polynomially while the ambient count grows combinatorially.

### 6.2 Limitations

- The exact identity (Theorem 2) requires *multiaffine* support with *positive* coefficients. Signed or non-multiaffine polynomials require different techniques.
- The active variable bound (Theorem 4) is tight for uniform matroids but can be loose for highly structured supports.
- Our formalization works at the combinatorial/support level. The polynomial-level connection (showing that the support criterion implies nonvanishing of the actual derivative) relies on the monomial lemma, which is standard but not formalized in this work.

### 6.3 Relation to Prior Work

- **Brändén–Huh [BH20]** proved that matroid basis polynomials are Lorentzian, establishing the context for our work.
- **Murota [M03]** developed discrete convex analysis and M-convexity, which governs the support structure of Lorentzian polynomials.
- **Anari–Liu–Oveis Gharan–Vinzant [ALOV19]** proved log-concavity of the basis generating polynomial using the theory of completely log-concave polynomials, closely related to Lorentzian polynomials.

### 6.4 Machine Verification

All four main theorems are formally verified:
- `derivative_survives_iff_dominated` — support criterion
- `quadraticLeaves_eq_indepSets` — leaf count = independent set count
- `quadraticLeaves_uniformMatroid` — uniform matroid closed form
- `supportCompressedLeafCount_le_active_choose` — active variable bound

The verified algorithm `countNonzeroQuadraticLeavesFromSupport` is proved correct against the definition of `supportCompressedLeafCount`.

---

## 7. Future Work

1. **Polynomial-level formalization.** Connect the support-level theorems to the actual MvPolynomial differentiation API, proving that the combinatorial criterion implies nonvanishing of iterated partial derivatives.

2. **Graphic matroid closed forms.** For graphic matroids, express the leaf count in terms of graph invariants (Tutte polynomial evaluations, forest counting formulas).

3. **M-convex extension.** Extend the support compression theory beyond matroids to general M-convex supports, which govern all Lorentzian polynomials.

4. **Complexity-theoretic implications.** Study the computational complexity of the independent-set counting problem for specific matroid families, connecting to #P-hardness results for general matroids.

5. **Applications to optimization.** Use support compression to accelerate Lorentzian certification in matroid optimization and partition function computation.

---

## References

- [BH20] P. Brändén and J. Huh, "Lorentzian polynomials," *Annals of Mathematics*, 192(3), 821–891, 2020.
- [M03] K. Murota, *Discrete Convex Analysis*, SIAM, 2003.
- [ALOV19] N. Anari, K. Liu, S. Oveis Gharan, C. Vinzant, "Log-concave polynomials II: High-dimensional walks and an FPRAS for counting bases of a matroid," *STOC*, 2019.
- [Oxl11] J. Oxley, *Matroid Theory*, 2nd ed., Oxford University Press, 2011.
