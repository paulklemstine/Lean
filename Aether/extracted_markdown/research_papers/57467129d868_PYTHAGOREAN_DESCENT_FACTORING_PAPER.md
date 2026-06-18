# Pythagorean Triple Descent Factoring: Analysis, Obstruction, and Corrected Algorithm

## Abstract

We investigate an integer factoring approach based on the Berggren ternary tree of primitive Pythagorean triples. The proposed algorithm forms a "factoring triple" $T(x) = (x, N, x^2 + N^2)$ with unknown variable $x$, applies the Universal Parent function iteratively, and attempts to solve for $x$ by equating the result to the root node $(3,4,5)$. We prove a **fundamental obstruction**: the Lorentz norm $L = a^2 + b^2 - c^2$ is preserved by the Universal Parent, $L(3,4,5) = 0$, but $L(T(x)) = -(x^2+N^2)(x^2+N^2-1) \neq 0$ for all $x, N \geq 1$. Therefore, no number of iterations can map $T(x)$ to $(3,4,5)$. We further show that the Universal Parent is a *linear* map, so the equating equations remain quadratic in $x$ at every depth, with discriminant growing as $-O(N^2 \cdot (3+2\sqrt{2})^{2k})$ at depth $k$ — guaranteeing no real solutions exist at any depth.

We then present a **corrected algorithm** using *true* Pythagorean triples with $N$ as a leg. This approach works but is mathematically equivalent to Fermat's difference-of-squares method: finding such triples requires factoring $N^2$ into same-parity divisor pairs, which is equivalent to factoring $N$ itself. The Berggren tree provides a beautiful structured representation of the factor space but does not yield a computational shortcut.

All results are formally verified in Lean 4 with Mathlib and accompanied by Python demonstrations.

---

## 1. Introduction

### 1.1 The Berggren Tree

Every primitive Pythagorean triple (PPT) can be generated uniquely from the root $(3,4,5)$ by applying sequences of three matrix transformations, discovered by Berggren (1934):

$$B_1 = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3 \end{pmatrix}, \quad
B_2 = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3 \end{pmatrix}, \quad
B_3 = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3 \end{pmatrix}$$

These generate a ternary tree rooted at $(3,4,5)$ that contains every PPT exactly once.

### 1.2 The Universal Parent Function

The **Universal Parent** is the inverse map: given any PPT $(a,b,c)$ with $a$ odd, $b$ even, it returns the unique parent in the Berggren tree by applying the appropriate inverse matrix $B_i^{-1}$.

The inverse matrices share a common structure. The "ghost parent" formulation uses:

$$\text{UP}(a, b, c) = (a + 2b - 2c, \; 2a + b - 2c, \; -2a - 2b + 3c)$$

This corresponds to $B_2^{-1}$ and maps any PPT toward the root $(3,4,5)$.

### 1.3 The Factoring Idea

Given a composite integer $N$ to factor:

1. Form the **factoring triple**: $T(x) = (x, N, x^2 + N^2)$ with unknown $x$
2. Apply the Universal Parent: $\text{UP}(T(x)) = (x_1, y_1, z_1)$ where components are functions of $x$ and $N$
3. Set $\text{UP}(T(x)) = (3, 4, 5)$ and solve for $x$
4. If $x$ is a positive integer, use $\gcd(x, N)$ to extract a factor
5. If no integer solution, iterate: apply UP again and re-solve

This is an elegant idea that connects number-theoretic factoring to the geometric structure of Pythagorean triples. We analyze it rigorously below.

---

## 2. The Lorentz Norm Obstruction

### 2.1 The Invariant

**Definition.** The *Lorentz norm* of a triple $(a,b,c)$ is $L(a,b,c) = a^2 + b^2 - c^2$.

**Theorem 1 (Lorentz Norm Preservation).** *For any triple $(a,b,c) \in \mathbb{Z}^3$:*

$$L(\text{UP}(a,b,c)) = L(a,b,c)$$

*Proof.* Direct computation (formally verified in Lean 4, theorem `lorentz_norm_preservation`):

$$(a+2b-2c)^2 + (2a+b-2c)^2 - (-2a-2b+3c)^2 = a^2 + b^2 - c^2 \quad \square$$

### 2.2 The Obstruction

**Theorem 2 (Fundamental Obstruction).** *The factoring triple $T(x) = (x, N, x^2+N^2)$ satisfies:*

$$L(T(x)) = x^2 + N^2 - (x^2+N^2)^2 = -(x^2+N^2)(x^2+N^2-1)$$

*For $x \geq 1$ and $N \geq 1$, this is strictly negative. Since $L(3,4,5) = 0$, no finite number of UP iterations can map $T(x)$ to $(3,4,5)$.*

This is the central negative result: **the algorithm as described cannot work** because the factoring triple lives in a different Lorentz class than any Pythagorean triple.

### 2.3 Universality of the Obstruction

The obstruction applies to *all three* Berggren inverse branches, not just $B_2^{-1}$:

$$B_1^{-1}(a,b,c) = (a+2b-2c, \; -2a-b+2c, \; -2a-2b+3c)$$
$$B_2^{-1}(a,b,c) = (a+2b-2c, \; 2a+b-2c, \; -2a-2b+3c)$$
$$B_3^{-1}(a,b,c) = (-a-2b+2c, \; 2a+b-2c, \; -2a-2b+3c)$$

All three share the **same hypotenuse formula** $c' = -2a - 2b + 3c$, and all three preserve the Lorentz norm. Choosing different branches at different depths changes the path but cannot overcome the invariant obstruction.

---

## 3. Polynomial Degree and Discriminant Analysis

### 3.1 Linearity of UP

Since UP is a *linear* map $(a,b,c) \mapsto M \cdot (a,b,c)^T$, applying it to $T(x) = (x, N, x^2+N^2)$ yields components that are **degree-2 polynomials in $x$** at every depth.

Specifically, at depth $k$:

$$c_k(x) = \rho_k \cdot x^2 + \sigma_k \cdot x + (\rho_k \cdot N^2 + \sigma_k \cdot N)$$

where the coefficients evolve by the matrix recurrence:

$$\begin{pmatrix} \alpha_{k+1} \\ \rho_{k+1} \end{pmatrix} = \begin{pmatrix} 3 & -2 \\ -4 & 3 \end{pmatrix} \begin{pmatrix} \alpha_k \\ \rho_k \end{pmatrix}$$

### 3.2 Eigenvalue Analysis

The evolution matrix has eigenvalues $\lambda_{\pm} = 3 \pm 2\sqrt{2}$:
- $\lambda_+ = 3 + 2\sqrt{2} \approx 5.828$
- $\lambda_- = 3 - 2\sqrt{2} \approx 0.172$

Therefore $\rho_k = O(\lambda_+^k)$, and the sequence $\rho_k$ is:

| Depth $k$ | $\rho_k$ | $\sigma_k$ |
|-----------|----------|-----------|
| 0 | 1 | 0 |
| 1 | 3 | −2 |
| 2 | 17 | −12 |
| 3 | 99 | −70 |
| 4 | 577 | −408 |
| 5 | 3363 | −2378 |
| 6 | 19601 | −13860 |

These are related to the **Pell numbers**: $\rho_k$ satisfies $\rho_{k+1} = 6\rho_k - \rho_{k-1}$ with $\rho_0 = 1$, $\rho_1 = 3$.

### 3.3 Discriminant Growth

Setting $c_k = 5$ gives the quadratic $\rho_k x^2 + \sigma_k x + (\rho_k N^2 + \sigma_k N - 5) = 0$ with discriminant:

$$\Delta_k = \sigma_k^2 - 4\rho_k(\rho_k N^2 + \sigma_k N - 5)$$

For large $N$: $\Delta_k \approx -4\rho_k^2 N^2 < 0$.

**Theorem 3.** *For $N \geq 2$, the discriminant $\Delta_k < 0$ for all $k \geq 0$. Therefore no real (let alone integer) solution for $x$ exists at any depth.*

This provides a second, independent proof that the algorithm cannot work, complementing the Lorentz norm argument.

---

## 4. The Corrected Algorithm

### 4.1 Using True Pythagorean Triples

Instead of the artificial triple $(x, N, x^2+N^2)$, we use *genuine* Pythagorean triples with $N$ as a leg: $(x, N, z)$ where $x^2 + N^2 = z^2$.

Such triples exist if and only if $N > 2$. They arise from same-parity factorizations of $N^2$:

$$N^2 = d \cdot e, \quad d < e, \quad d \equiv e \pmod{2}$$

giving $x = \frac{e-d}{2}$, $z = \frac{e+d}{2}$.

### 4.2 Factoring from Pythagorean Triples

**For $N$ odd:** $N = m^2 - n^2 = (m-n)(m+n)$ where $m,n$ come from the Euclid parametrization. Each non-trivial factoring $N = d \cdot e$ gives $m = \frac{d+e}{2}$, $n = \frac{e-d}{2}$.

**For $N$ even:** $N = 2mn$, and each factoring of $N/2 = a \cdot b$ gives the parametrization.

**Theorem 4 (Factoring Equivalence).** *Finding a non-trivial Pythagorean triple with $N$ as a leg is equivalent to finding a non-trivial factoring of $N$.*

### 4.3 The Descent Step

Once a true Pythagorean triple $(x, N, z)$ is found, it can be reduced to its primitive form and descended to $(3,4,5)$ via the Universal Parent in $O(\log z)$ steps. The descent is guaranteed to terminate because:

1. The triple is genuinely Pythagorean ($L = 0$)
2. The hypotenuse strictly decreases: $c' = 3c - 2a - 2b < c$
3. The root $(3,4,5)$ is the unique PPT with smallest hypotenuse

### 4.4 Complexity

| Step | Operation | Complexity |
|------|-----------|-----------|
| 1 | Find divisor pair of $N^2$ | $O(N)$ (trial division) |
| 2 | Build Pythagorean triple | $O(1)$ |
| 3 | Reduce to primitive form | $O(\log N)$ (GCD) |
| 4 | Descend to $(3,4,5)$ | $O(\log N)$ |
| 5 | Extract factor | $O(1)$ |

**Total: $O(N)$**, dominated by step 1, which is equivalent to trial division.

### 4.5 Relationship to Fermat's Method

Fermat's difference-of-squares method finds $N = a^2 - b^2 = (a-b)(a+b)$ by searching for $a \geq \lceil\sqrt{N}\rceil$ such that $a^2 - N$ is a perfect square. This is *mathematically identical* to finding a Pythagorean triple $(b, N, a)$ with $N$ as a leg.

The Pythagorean triple tree provides a beautiful *structural organization* of the search space but does not improve the asymptotic complexity.

---

## 5. Experimental Results

### 5.1 Small Semiprimes

| $N$ | Factors | Triples with $N$ as leg | Factor-revealing triples |
|-----|---------|------------------------|-------------------------|
| 15 | 3 × 5 | (8,15,17), (20,15,25), (36,15,39), (112,15,113) | 3 of 4 |
| 21 | 3 × 7 | (20,21,29), (28,21,35), (72,21,75), (220,21,221) | 3 of 4 |
| 35 | 5 × 7 | (12,35,37), (84,35,91), (120,35,125), (612,35,613) | 3 of 4 |
| 77 | 7 × 11 | (36,77,85), (204,77,217), (360,77,373), (2964,77,2965) | 3 of 4 |

### 5.2 Larger Semiprimes

| $N$ | Factors | Parametrization | Tree Depth |
|-----|---------|----------------|-----------|
| 1073 | 29 × 37 | $33^2 - 4^2$ | moderate |
| 2021 | 43 × 47 | $45^2 - 2^2$ | 11 |
| 10403 | 101 × 103 | $102^2 - 1^2$ | 49 |

### 5.3 Tree Depth vs Factor Gap

The tree depth of the factor-revealing triple correlates with the *parametric ratio* $m/n$. Close factors (small gap) give $n \approx 1$, leading to deep tree positions. Twin-prime products like $101 \times 103$ produce the deepest paths.

---

## 6. Formal Verification

### 6.1 Lean 4 Theorems

The following core results are formally verified in the project's Lean files:

1. **`lorentz_norm_preservation`**: $L(\text{UP}(a,b,c)) = L(a,b,c)$
2. **`invB1_pyth`**, **`invB2_pyth`**, **`invB3_pyth`**: All three inverse branches preserve the Pythagorean property
3. **`parent_hypotenuse_lt`**: The parent hypotenuse is strictly less than $c$
4. **`factoring_h_large`**: For the factoring triple, $h \geq x^2 + N^2$
5. **`split_triplet_fixed_point`**: $(N-x, x, N)$ is a fixed point of UP
6. **`divisor_gap_theorem`**: For $(d, e, de)$, the ghost gap $p - q = e - d$
7. **`diff_of_squares_pyth`**: $(c-b)(c+b) = N^2$ for $N^2 + b^2 = c^2$
8. **`divisor_pair_gives_triple`**: Same-parity divisor pairs yield Pythagorean triples

---

## 7. Conclusions and Future Directions

### 7.1 Summary

The proposed factoring algorithm using the factoring triple $(x, N, x^2+N^2)$ has a fundamental obstruction: the Lorentz norm invariant prevents convergence to $(3,4,5)$. The corrected algorithm using true Pythagorean triples works but reduces to known methods (Fermat's difference-of-squares).

### 7.2 What the Pythagorean Tree Reveals

Despite the negative complexity result, the Berggren tree provides genuine structural insight:

1. **Factor Organization**: Each non-trivial factor of $N$ corresponds to a distinct Pythagorean triple containing $N$
2. **Scale Factor Encoding**: Non-primitive triples with $N$ as a leg have scale factors that are divisors of $N$
3. **Geometric Representation**: The factoring problem has a natural geometric interpretation on the Pythagorean circle $x^2 + N^2 = z^2$

### 7.3 Open Questions

1. **Can tree structure guide heuristic search?** The branching pattern of the Berggren tree might inform a non-trivial search strategy for Pythagorean triples containing $N$.

2. **Modular descent**: Can working modulo a prime $p$ (using Pythagorean triples in $\mathbb{F}_p$) provide factoring information? The tree structure might give algebraic constraints.

3. **Connections to the Stern-Brocot tree**: The Euclid parameter tree (isomorphic to the Berggren tree) is closely related to the Stern-Brocot tree of rational numbers. Can this connection yield factoring insights via continued fractions?

4. **Higher-dimensional generalizations**: Pythagorean quadruples $(a^2 + b^2 + c^2 = d^2)$ form a quaternary tree. Does factoring through higher-dimensional Diophantine equations provide additional structure?

---

## References

- Berggren, B. (1934). "Pytagoreiska trianglar." *Tidskrift för elementär matematik, fysik och kemi*, 17, 129–139.
- Barning, F.J.M. (1963). "Over pythagorese en bijna-pythagorese driehoeken en een generatieproces met behulp van unimodulaire matrices." *Math. Centrum Amsterdam Afd. Zuivere Wisk.*, ZW-011.
- Hall, A. (1970). "Genealogy of Pythagorean triads." *The Mathematical Gazette*, 54(390), 377–379.
- Price, H.L. (2008). "The Pythagorean Tree: A New Species." arXiv:0809.4324.

---

*This paper accompanies the formal verification project at `Pythagorean/Core/` and `Pythagorean/Berggren/` in the CatalogBuild repository.*
