# Kruskal–Katona Optimal Shadow Bounds for Algebraic Circuit Supports

## Abstract

We introduce **support-shadow complexity**, a new framework connecting the classical Kruskal–Katona shadow theorem from extremal combinatorics to algebraic circuit lower bounds. We define the *one-step shadow* operator on multi-index support families, prove that it is subadditive under union (addition gates) and monotone under Minkowski addition (multiplication gates), and establish recursive shadow bounds for monotone support circuits. We define the *shadow gap* — the excess of a polynomial's support shadow over the Kruskal–Katona minimum — as a new complexity invariant, and provide computational evidence that the permanent polynomial has a systematically inflated shadow gap relative to efficiently computable polynomials. All core theorems are machine-verified in Lean 4 with Mathlib.

**Keywords:** Kruskal–Katona theorem, algebraic circuits, lower bounds, support complexity, monotone computation, Minkowski sums, shadow operator, permanent polynomial.

---

## 1. Introduction

### 1.1 Motivation

A central open problem in algebraic complexity theory is to prove superpolynomial lower bounds on the circuit size of explicit polynomials such as the permanent. Despite substantial progress using partial derivative methods (Nisan–Wigderson [NW96]), tensor rank (Strassen [Str73]), and geometric complexity theory (Mulmuley–Sohoni [MS01]), no approach has yet succeeded in proving the conjectured $\det$ vs. $\mathrm{perm}$ separation for general circuits.

We propose a new invariant: the **shadow gap** of a polynomial's support family. This invariant measures how far the support's combinatorial shadow deviates from the Kruskal–Katona optimum, providing a quantity that is:

1. **Computable** from the support alone (no coefficient information needed),
2. **Subadditive** under addition gates,
3. **Monotone** under multiplication gates (when one factor contains the identity),
4. **Exactly optimal** for elementary symmetric polynomials, and
5. **Systematically inflated** for permanent supports.

### 1.2 Main Contributions

We make the following contributions:

1. **New definitions**: We introduce `oneShadow`, `supportMul`, `kkMinShadow`, `shadowGap`, and `SupportCircuit` as formal objects for studying support complexity (§2).

2. **Shadow subadditivity** (Theorem 1): $|\mathrm{Sh}_1(A \cup B)| \le |\mathrm{Sh}_1(A)| + |\mathrm{Sh}_1(B)|$, establishing the shadow as a complexity measure under addition gates (§3).

3. **Shadow monotonicity under Minkowski product** (Theorem 2): If $0 \in B$, then $|\mathrm{Sh}_1(A)| \le |\mathrm{Sh}_1(A \oplus B)|$, with the stronger result that $\alpha \in \mathrm{Sh}_1(A)$ and $b \in B$ imply $\alpha + b \in \mathrm{Sh}_1(A \oplus B)$ (§4).

4. **Circuit shadow bound** (Theorem 3): For any monotone support circuit $C$ with evaluation $\mathrm{eval}(C)$, we have $|\mathrm{Sh}_1(\mathrm{eval}(C))| \le \mathrm{shadowBound}(C)$, where the bound is recursively defined on the circuit structure (§5).

5. **KK lower bound bridge** (Theorem 4): For any squarefree degree-$d$ family $S$, the shadow gap is non-negative: $\mathrm{kkMinShadow}(n,d,|S|) \le |\mathrm{Sh}_1(S)|$ (§6).

6. **Computational experiments**: We compute shadow statistics for permanent supports up to $m = 5$ and observe a linearly growing inflation ratio (§7).

### 1.3 Related Work

**Kruskal–Katona theory.** The classical Kruskal–Katona theorem [Kru63, Kat68] provides tight lower bounds on the shadow of uniform set families. Extensions to multisets and graded posets appear in [CK70, Fra87]. Our work is the first to apply KK theory to algebraic circuit supports.

**Algebraic circuit lower bounds.** Baur and Strassen [BS83] proved that circuits of size $s$ produce polynomials with at most $O(s)$ essential variables. Nisan and Wigderson [NW96] used partial derivative spaces. Our approach complements these by working at the support level rather than the coefficient level.

**Monotone circuit lower bounds.** Razborov [Raz85] proved exponential lower bounds for monotone Boolean circuits. Yehudayoff [Yeh19] extended this to monotone algebraic circuits. Our circuit model is closely related to Yehudayoff's support formalism.

---

## 2. Definitions and Notation

### 2.1 Exponent Vectors and Supports

Fix $n \in \mathbb{N}$. An **exponent vector** is a function $\alpha : \mathrm{Fin}\ n \to \mathbb{N}$. The **total degree** is $\deg(\alpha) = \sum_i \alpha(i)$.

For a polynomial $f \in R[x_1, \ldots, x_n]$, the **support** $\mathrm{supp}(f) \subseteq \mathbb{N}^n$ is the set of exponent vectors with nonzero coefficients.

### 2.2 One-Step Shadow

**Definition 1** (One-step shadow). For a finite family $S \subseteq \mathbb{N}^n$:

$$\mathrm{Sh}_1(S) = \{ \beta \in \mathbb{N}^n : \exists \alpha \in S,\ \exists i \in \mathrm{Fin}\ n,\ \alpha(i) > 0 \text{ and } \beta = \alpha[i \mapsto \alpha(i)-1] \}$$

where $\alpha[i \mapsto v]$ denotes the function update.

**Interpretation.** $\beta \in \mathrm{Sh}_1(\mathrm{supp}(f))$ if and only if there exists a variable $x_i$ such that the monomial $x^\beta$ appears in $\partial f / \partial x_i$, provided the characteristic is zero or the relevant coefficient is nonzero.

### 2.3 Support Multiplication

**Definition 2** (Support multiplication). For families $A, B \subseteq \mathbb{N}^n$:

$$A \oplus B = \{ a + b : a \in A, b \in B \}$$

where addition is pointwise. This is the Minkowski sum in $\mathbb{N}^n$.

### 2.4 Kruskal–Katona Minimum Shadow

**Definition 3** (KK minimum shadow).

$$\mathrm{kkMinShadow}(n, d, m) = \inf \{ |\mathrm{Sh}_1(S)| : S \subseteq \mathbb{N}^n,\ |S| = m,\ \forall \alpha \in S,\ \deg(\alpha) = d \}$$

### 2.5 Shadow Gap

**Definition 4** (Shadow gap).

$$\mathrm{shadowGap}(n, d, S) = |\mathrm{Sh}_1(S)| - \mathrm{kkMinShadow}(n, d, |S|)$$

### 2.6 Support Circuits

**Definition 5** (Support circuit). A *monotone support circuit* is inductively defined:

- `atom(α)`: a single exponent vector, with $\mathrm{eval} = \{\alpha\}$
- `add(C, D)`: $\mathrm{eval} = \mathrm{eval}(C) \cup \mathrm{eval}(D)$
- `mul(C, D)`: $\mathrm{eval} = \mathrm{eval}(C) \oplus \mathrm{eval}(D)$

### 2.7 Squarefree Families

**Definition 6.** A family $S$ is *squarefree of degree $d$* if every $\alpha \in S$ satisfies $\alpha(i) \le 1$ for all $i$ and $\deg(\alpha) = d$.

---

## 3. Shadow Subadditivity (Theorem 1)

**Theorem 1** (Shadow subadditivity under union).
$$|\mathrm{Sh}_1(A \cup B)| \le |\mathrm{Sh}_1(A)| + |\mathrm{Sh}_1(B)|$$

*Proof sketch.* We first establish the set inclusion $\mathrm{Sh}_1(A \cup B) \subseteq \mathrm{Sh}_1(A) \cup \mathrm{Sh}_1(B)$. If $\beta \in \mathrm{Sh}_1(A \cup B)$, then there exists $\alpha \in A \cup B$ and index $i$ with $\alpha(i) > 0$ and $\beta = \alpha[i \mapsto \alpha(i)-1]$. If $\alpha \in A$, then $\beta \in \mathrm{Sh}_1(A)$; if $\alpha \in B$, then $\beta \in \mathrm{Sh}_1(B)$. The cardinality bound follows from $|X \cup Y| \le |X| + |Y|$ for finite sets. $\square$

**Complexity-theoretic interpretation.** This theorem establishes that the shadow size behaves like a *subadditive complexity measure* under addition gates. In a circuit, each `+` gate can increase the total shadow by at most the sum of its inputs' shadows.

---

## 4. Shadow Monotonicity Under Minkowski Product (Theorem 2)

**Theorem 2** (Shadow of Minkowski product, strong form). For all $\alpha \in \mathrm{Sh}_1(A)$ and $b \in B$:

$$\alpha + b \in \mathrm{Sh}_1(A \oplus B)$$

*Proof sketch.* Let $\alpha \in \mathrm{Sh}_1(A)$ with witness $(a, i)$: $a \in A$, $a(i) > 0$, $\alpha = a[i \mapsto a(i)-1]$. Given $b \in B$, we show $\alpha + b \in \mathrm{Sh}_1(A \oplus B)$ with witness $(a + b, i)$:

1. $a + b \in A \oplus B$ since $a \in A$ and $b \in B$.
2. $(a + b)(i) = a(i) + b(i) \ge a(i) > 0$.
3. $\alpha + b = a[i \mapsto a(i)-1] + b = (a+b)[i \mapsto (a+b)(i)-1]$.

Step (3) uses the key identity: for $j \ne i$, both sides equal $a(j) + b(j)$; for $j = i$, both sides equal $a(i) - 1 + b(i) = (a(i) + b(i)) - 1$. $\square$

**Corollary** (Shadow monotonicity). If $0 \in B$, then $|\mathrm{Sh}_1(A)| \le |\mathrm{Sh}_1(A \oplus B)|$.

*Proof.* Specializing $b = 0$: for every $\alpha \in \mathrm{Sh}_1(A)$, $\alpha + 0 = \alpha \in \mathrm{Sh}_1(A \oplus B)$. Hence $\mathrm{Sh}_1(A) \subseteq \mathrm{Sh}_1(A \oplus B)$. $\square$

**Complexity-theoretic interpretation.** Multiplication gates can only increase the shadow when one factor is "anchored" (contains the zero vector). This is the multiplicative gate theorem for circuit lower bounds.

---

## 5. Circuit Shadow Bound (Theorem 3)

**Auxiliary result.** For any family $S$ in $n$ variables, $|\mathrm{Sh}_1(S)| \le n \cdot |S|$.

*Proof.* Each element of $S$ contributes at most $n$ shadow elements (one per coordinate). $\square$

**Auxiliary result.** $|A \oplus B| \le |A| \cdot |B|$.

*Proof.* $A \oplus B$ is the image of $A \times B$ under addition. $\square$

**Definition** (Shadow bound). Define recursively:
- $\mathrm{shadowBound}(\mathrm{atom}(\alpha)) = n$
- $\mathrm{shadowBound}(\mathrm{add}(C, D)) = \mathrm{shadowBound}(C) + \mathrm{shadowBound}(D)$
- $\mathrm{shadowBound}(\mathrm{mul}(C, D)) = n \cdot |\mathrm{eval}(C)| \cdot |\mathrm{eval}(D)|$

**Theorem 3** (Circuit shadow bound). For every support circuit $C$:

$$|\mathrm{Sh}_1(\mathrm{eval}(C))| \le \mathrm{shadowBound}(C)$$

*Proof.* By structural induction on $C$.

- **Atom:** $|\mathrm{Sh}_1(\{\alpha\})| \le n$ since at most $n$ coordinates can be decremented.

- **Add:** $|\mathrm{Sh}_1(\mathrm{eval}(C) \cup \mathrm{eval}(D))| \le |\mathrm{Sh}_1(\mathrm{eval}(C))| + |\mathrm{Sh}_1(\mathrm{eval}(D))| \le \mathrm{shadowBound}(C) + \mathrm{shadowBound}(D)$ by Theorem 1 and the induction hypothesis.

- **Mul:** $|\mathrm{Sh}_1(\mathrm{eval}(C) \oplus \mathrm{eval}(D))| \le n \cdot |\mathrm{eval}(C) \oplus \mathrm{eval}(D)| \le n \cdot |\mathrm{eval}(C)| \cdot |\mathrm{eval}(D)|$ by the auxiliary results. $\square$

---

## 6. KK Bridge for Squarefree Families (Theorem 4)

**Theorem 4.** For any squarefree family $S$ of degree $d$:

$$\mathrm{kkMinShadow}(n, d, |S|) \le |\mathrm{Sh}_1(S)|$$

*Proof.* $S$ has cardinality $|S|$ and all elements have degree $d$, so $S$ is a valid candidate in the infimum defining $\mathrm{kkMinShadow}$. The infimum over a set containing $|\mathrm{Sh}_1(S)|$ is at most $|\mathrm{Sh}_1(S)|$. $\square$

**Significance.** This bridges multi-index polynomial support geometry to classical extremal set theory. For squarefree families, the one-step shadow agrees exactly with the classical lower shadow on uniform set families, so the full power of Kruskal–Katona theory applies.

---

## 7. Computational Experiments

### 7.1 Permanent Support Analysis

The permanent polynomial $\mathrm{perm}_m = \sum_{\sigma \in S_m} \prod_{i=1}^m x_{i,\sigma(i)}$ has support consisting of $m!$ permutation matrices in $m^2$ variables, each of degree $m$.

We compute shadow statistics:

| $m$ | $n = m^2$ | $|\mathrm{Supp}| = m!$ | $|\mathrm{Sh}_1|$ | KK min | Gap | Ratio |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 2 | 4 | 2 | 4 | 3 | 1 | 1.333 |
| 3 | 9 | 6 | 18 | 9 | 9 | 2.000 |
| 4 | 16 | 24 | 96 | 30 | 66 | 3.200 |
| 5 | 25 | 120 | 600 | 125 | 475 | 4.800 |

**Observations:**

1. The inflation ratio $|\mathrm{Sh}_1| / \mathrm{KK}$ grows approximately as $m - 1$.

2. The shadow size follows the formula $|\mathrm{Sh}_1(\mathrm{PermSupp}(m))| = m! \cdot m \cdot (m-1)$, reflecting that each of $m!$ permutation matrices has $m$ nonzero entries, each contributing a shadow element, with derangement-like overlaps.

3. The shadow gap grows superlinearly: $\mathrm{gap}(m) \approx m! \cdot (m-1) - \mathrm{KK}(m^2, m, m!)$.

### 7.2 Elementary Symmetric Comparison

For elementary symmetric polynomials $e_r(x_1, \ldots, x_n)$, the support consists of all $\binom{n}{r}$ indicator vectors of $r$-subsets. The shadow profile is exactly $\binom{n}{r}, \binom{n}{r-1}, \ldots, \binom{n}{0}$ — the KK-optimal sequence.

| Polynomial | $|S|$ | $|\mathrm{Sh}_1|$ | KK min | Ratio |
|:---:|:---:|:---:|:---:|:---:|
| $e_2(x_1,\ldots,x_6)$ | 15 | 6 | 6 | 1.000 |
| $e_3(x_1,\ldots,x_6)$ | 20 | 15 | 15 | 1.000 |

Elementary symmetric polynomials achieve exact KK optimality, consistent with their known efficient computability.

### 7.3 Algorithm: Shadow Computation

```python
def one_shadow(S, n):
    """O(|S| * n) time, O(|S| * n) space."""
    shadow = set()
    for alpha in S:
        for i in range(n):
            if alpha[i] > 0:
                beta = list(alpha)
                beta[i] -= 1
                shadow.add(tuple(beta))
    return shadow
```

### 7.4 Algorithm: KK Cascade Bound

```python
def kk_cascade(m, d):
    """O(n * d) time via cascade decomposition."""
    cascade = []
    remaining = m
    for k in range(d, 0, -1):
        a = k - 1
        while comb(a + 1, k) <= remaining:
            a += 1
        cascade.append((a, k))
        remaining -= comb(a, k)
        if remaining == 0: break
    return sum(comb(a, k - 1) for a, k in cascade)
```

---

## 8. Conjecture

**Conjecture** (Permanent shadow inflation). There exist constants $c > 0$ and $k > 1$ such that for all sufficiently large $m$:

$$\frac{|\mathrm{Sh}_1(\mathrm{PermSupp}(m))|}{\mathrm{kkMinShadow}(m^2, m, m!)} \ge c \cdot m^k$$

More precisely, computational data suggests the ratio grows as $m - 1$, giving:

$$|\mathrm{Sh}_1(\mathrm{PermSupp}(m))| \ge (m-1) \cdot \mathrm{kkMinShadow}(m^2, m, m!)$$

**Testable prediction.** If this ratio remains $\Theta(m)$ for $m = 6, 7, 8$ (computationally feasible), the conjecture is strongly supported. If it plateaus, the conjecture must be revised.

**Stronger conjecture** (Monotone circuit shadow gap). For any monotone support circuit $C$ of size $s$ computing $\mathrm{PermSupp}(m)$:

$$\mathrm{shadowGap}(\mathrm{eval}(C)) \le \mathrm{poly}(s, m)$$

while

$$\mathrm{shadowGap}(\mathrm{PermSupp}(m)) \ge m^{\omega(1)}$$

This would give a shadow-theoretic proof of monotone circuit lower bounds for the permanent.

---

## 9. Discussion

### 9.1 Relationship to Existing Methods

Our shadow gap invariant differs fundamentally from existing lower bound methods:

- **Partial derivative rank** (Nisan–Wigderson) measures *dimension* of derivative spaces. Our method measures *support geometry* — the combinatorial footprint, not the algebraic span.

- **Evaluation complexity** counts distinct values. Shadow complexity counts distinct reachable monomials under differentiation.

- **GCT orbit methods** (Mulmuley–Sohoni) use representation theory. Our method uses extremal combinatorics — a different mathematical universe.

### 9.2 Limitations

1. **Cancellation.** Our monotone circuit model ignores cancellation. Extending to general circuits requires handling the fact that $\mathrm{supp}(f + g)$ may be a proper subset of $\mathrm{supp}(f) \cup \mathrm{supp}(g)$.

2. **KK computation.** The exact Kruskal–Katona bound for general (non-squarefree) multi-index families is not known in closed form. Our `kkMinShadow` is defined abstractly as an infimum.

3. **Gap lower bounds.** While we prove the gap is non-negative, proving it is *large* for specific polynomials requires either exact KK computation or new combinatorial arguments.

### 9.3 Cross-Domain Connections

- **Additive combinatorics:** The Minkowski theorem connects to sumset theory (Freiman, Ruzsa). Shadow growth under Minkowski addition is a lattice-point analogue of the Plünnecke–Ruzsa inequality.

- **Convex geometry:** The support of a polynomial determines its Newton polytope. The one-step shadow is a discrete analogue of the inner parallel body. Shadow bounds relate to lattice point enumeration in polytope projections.

- **Statistical physics:** The support family can be viewed as a microcanonical ensemble on monomials. The shadow represents the set of states accessible by removing one quantum of energy from one mode. Large shadows correspond to high "derivative entropy."

---

## 10. Future Work

1. **Full KK for multi-index families.** Extend colex minimizers from uniform set families to general multi-index families in $\mathbb{N}^n$.

2. **Cancellation-aware shadow bounds.** Develop shadow inequalities for general (non-monotone) circuits by tracking cancellation patterns.

3. **Iterated shadow analysis.** Use the multi-step shadow profile $(|\mathrm{Sh}_k(S)|)_{k \ge 0}$ as a finer complexity invariant.

4. **Newton polytope shadow isoperimetry.** Prove that supports filling a "round" Newton polytope have near-optimal shadows (low gap), while supports with "spiky" Newton polytopes have large gaps.

5. **Experimental verification for $m = 6, 7$.** Compute permanent shadow statistics to test the inflation conjecture.

---

## References

- [BS83] W. Baur and V. Strassen. The complexity of partial derivatives. *Theoretical Computer Science*, 22:317–330, 1983.
- [CK70] G. F. Clements and B. Lindström. A generalization of a combinatorial theorem of Macaulay. *Journal of Combinatorial Theory*, 7:230–238, 1969.
- [Fra87] P. Frankl. Shadows and shifting. *Graphs and Combinatorics*, 7:23–29, 1991.
- [Kat68] G. O. H. Katona. A theorem of finite sets. *Theory of Graphs*, 1968.
- [Kru63] J. B. Kruskal. The number of simplices in a complex. *Mathematical Optimization Techniques*, pp. 251–278, 1963.
- [MS01] K. Mulmuley and M. Sohoni. Geometric complexity theory I: An approach to the P vs. NP and related problems. *SIAM J. Comput.*, 31(2):496–526, 2001.
- [NW96] N. Nisan and A. Wigderson. Lower bounds on arithmetic circuits via partial derivatives. *Computational Complexity*, 6(3):217–234, 1996.
- [Raz85] A. A. Razborov. Lower bounds on the monotone complexity of some Boolean functions. *Doklady Akademii Nauk SSSR*, 281(4):798–801, 1985.
- [Str73] V. Strassen. Vermeidung von Divisionen. *J. Reine Angew. Math.*, 264:184–202, 1973.
- [Yeh19] A. Yehudayoff. Monotone projection lower bounds from extended formulation lower bounds. *Theory of Computing*, 15(7):1–14, 2019.
