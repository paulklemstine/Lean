# Iterated Shadow Geometry of Polynomial Supports: Exact Combinatorial Footprints of Mixed Partial Differentiation

## Abstract

We develop a theory of **iterated support shadows** for multivariate polynomials, establishing that higher-order mixed partial differentiation has an exact combinatorial footprint on exponent sets. The central result is the **Exact $k$-th Shadow Theorem**: for any polynomial $f$ over a characteristic-zero ring with no zero divisors, the union of supports of all $k$-th order mixed partial derivatives of $f$ equals the $k$-th combinatorial shadow of the Newton support of $f$. The proof rests on a multi-index coefficient transport formula involving products of ascending factorials. We further prove that the shadow operator satisfies a composition (semigroup) law: $\text{Sh}_b(\text{Sh}_a(S)) = \text{Sh}_{a+b}(S)$. We introduce the discrete exchange property as a formal proxy for M-convexity and formulate a Shadow Log-Concavity Conjecture, supported by extensive computational experiments with zero counterexamples found across 79 test cases. All main results are formalized and verified in Lean 4 with Mathlib.

**Keywords:** sparse differentiation, Newton polytope, M-convexity, matroid basis generating polynomial, Lorentzian polynomial, ultra-log-concavity, support dynamics, mixed partial derivatives, discrete convex analysis

---

## 1. Introduction

### 1.1 Motivation

The Newton support of a multivariate polynomial—the set of exponent vectors with nonzero coefficients—is a fundamental invariant connecting algebra, geometry, and combinatorics. Newton polytopes (convex hulls of supports) control the topology of algebraic hypersurfaces, the complexity of polynomial multiplication, and the zero structure of sparse polynomial systems.

A natural question, surprisingly underexplored, is: **how does the support transform under differentiation?** For a single partial derivative $\partial_i f$, the answer is simple: each exponent's $i$-th coordinate decreases by one (when it can). For higher-order mixed derivatives $\partial^{\tau} f$, the situation is more subtle. Multiple monomials might merge under differentiation, and cancellations could potentially occur.

We prove that, in characteristic zero, cancellation *never* occurs for individual mixed derivatives. Each coefficient in $\partial^{\tau} f$ is a positive scalar multiple of exactly one coefficient of $f$, with the scalar being a product of ascending factorials. This structural fact implies that the support of the family of all $k$-th order derivatives is governed by a purely combinatorial operator—the **$k$-th shadow**—acting on the Newton support.

### 1.2 Main Contributions

1. **Definitions.** We introduce the $k$-th shadow operator $\text{Sh}_k$, the iterated mixed partial derivative $\partial^{\tau}$, the derivative shadow profile, and the discrete exchange property.

2. **Coefficient Transport Formula** (Theorem 3.1). For any multi-index $\tau$:
$$\text{coeff}_{\beta}(\partial^{\tau} f) = \left(\prod_{i} ({\beta_i + 1})^{\overline{\tau_i}}\right) \cdot \text{coeff}_{\beta + \tau}(f)$$
where $n^{\overline{k}} = n(n+1)\cdots(n+k-1)$ denotes the ascending factorial.

3. **Exact $k$-th Shadow Theorem** (Theorem 3.3). In characteristic zero:
$$\beta \in \text{Sh}_k(\text{supp}(f)) \iff \exists \tau,\ |\tau| = k \text{ and } \beta \in \text{supp}(\partial^{\tau} f)$$

4. **Shadow Composition Law** (Theorem 4.1). $\text{Sh}_b(\text{Sh}_a(S)) = \text{Sh}_{a+b}(S)$.

5. **Shadow Log-Concavity Conjecture** (Conjecture 6.1). For M-convex (exchange-family) supports, the shadow profile is log-concave.

6. **Formal Verification.** All theorems (1–4) are verified in Lean 4 with Mathlib, with no sorry placeholders.

### 1.3 Related Work

The theory of Lorentzian polynomials (Brändén–Huh, 2020) establishes that certain polynomial classes have support sets satisfying matroidal exchange properties, and their Hessians preserve Lorentzian structure. Our shadow operator provides a combinatorial skeleton for the derivative recursion in Lorentzian recognition.

Murota's discrete convex analysis (2003) develops the theory of M-convex functions and sets, providing the algebraic foundation for our exchange property definition.

The support compression results for matroid basis polynomials (relating derivative leaf sets to independent sets) provide direct precursors to the shadow theorem, which we generalize from order-2 (quadratic shadow) to arbitrary order $k$.

---

## 2. Definitions and Notation

### 2.1 Multi-Indices and Polynomials

Let $n \geq 0$. A **multi-index** is a function $\alpha : \{0, \ldots, n-1\} \to \mathbb{N}$, identified with a finitely supported function $\alpha \in (\text{Fin}\, n \to_0 \mathbb{N})$. The **total mass** (or degree) of $\alpha$ is $|\alpha| = \sum_i \alpha_i$.

We work with multivariate polynomials $f \in R[x_0, \ldots, x_{n-1}]$ over a commutative semiring $R$. The **Newton support** of $f$ is:
$$\text{supp}(f) = \{\alpha \mid \text{coeff}_{\alpha}(f) \neq 0\}$$

### 2.2 The $k$-th Shadow

**Definition 2.1** ($k$-th Shadow). For a finite set $S \subseteq (\text{Fin}\, n \to_0 \mathbb{N})$ and $k \in \mathbb{N}$:
$$\text{Sh}_k(S) = \{\beta \mid \exists\, \tau,\ |\tau| = k \text{ and } \beta + \tau \in S\}$$

Equivalently: $\text{Sh}_k(S) = \bigcup_{\alpha \in S} \{\alpha - \tau \mid \tau \leq \alpha,\ |\tau| = k\}$.

In Lean 4, this is implemented as:
```
def kthShadow (S : Finset (Fin n →₀ ℕ)) (k : ℕ) : Finset (Fin n →₀ ℕ) :=
  S.biUnion (fun α =>
    ((Finset.Iic α).filter (fun τ => τ.sum (fun _ m => m) = k)).image (α - ·))
```

### 2.3 Iterated Mixed Partial Derivative

**Definition 2.2** (Single-variable iterated derivative). For variable $i$ and power $k$:
$$\text{pderivPow}(i, k, f) = \underbrace{\partial_i \circ \cdots \circ \partial_i}_{k \text{ times}}(f)$$

**Definition 2.3** (Mixed partial derivative). For multi-index $\tau$:
$$\partial^{\tau} f = \prod_i \partial_i^{\tau_i} f$$

Since partial derivatives commute for polynomials, this is well-defined regardless of evaluation order.

### 2.4 Derivative Shadow Profile

**Definition 2.4.** $\text{derivShadowProfile}(f)(k) = |\text{Sh}_k(\text{supp}(f))|$.

### 2.5 Discrete Exchange Property

**Definition 2.5** (M-convexity proxy). A finite set $S \subseteq (\text{Fin}\, n \to_0 \mathbb{N})$ satisfies the **discrete exchange property** if: for all $\alpha, \beta \in S$ and all $i$ with $\alpha_i > \beta_i$, there exists $j$ with $\beta_j > \alpha_j$ and $\alpha - e_i + e_j \in S$.

This captures the symmetric exchange axiom of M-convex sets (Murota, 2003).

---

## 3. The Coefficient Transport Formula

### 3.1 Single-Variable Formula

**Lemma 3.1** (One-step transport). For any polynomial $f$ and variable $i$:
$$\text{coeff}_{\beta}(\partial_i f) = (\beta_i + 1) \cdot \text{coeff}_{\beta + e_i}(f)$$

*Proof sketch.* Decompose $f$ as a sum of monomials. The derivative $\partial_i(\text{monomial}(s, a)) = \text{monomial}(s - e_i, a \cdot s_i)$. The coefficient at $\beta$ picks out the unique monomial $s = \beta + e_i$, giving factor $s_i = \beta_i + 1$. $\square$

**Theorem 3.1** (Iterated single-variable transport). For variable $i$ and power $k$:
$$\text{coeff}_{\beta}(\partial_i^k f) = (\beta_i + 1)^{\overline{k}} \cdot \text{coeff}_{\beta + k \cdot e_i}(f)$$

where $n^{\overline{k}} = n(n+1)\cdots(n+k-1)$ is the ascending factorial (Pochhammer symbol).

*Proof.* By induction on $k$. The base case is trivial. For the inductive step:
$$\text{coeff}_{\beta}(\partial_i^{k+1} f) = (\beta_i + 1) \cdot \text{coeff}_{\beta + e_i}(\partial_i^k f)$$
$$= (\beta_i + 1) \cdot (\beta_i + 2)^{\overline{k}} \cdot \text{coeff}_{\beta + (k+1) \cdot e_i}(f)$$
$$= (\beta_i + 1)^{\overline{k+1}} \cdot \text{coeff}_{\beta + (k+1) \cdot e_i}(f)$$

using the recurrence $n^{\overline{k+1}} = n \cdot (n+1)^{\overline{k}}$. $\square$

### 3.2 Multi-Variable Formula

**Theorem 3.2** (Full coefficient transport). For any multi-index $\tau$:
$$\text{coeff}_{\beta}(\partial^{\tau} f) = \left(\prod_{i=0}^{n-1} (\beta_i + 1)^{\overline{\tau_i}}\right) \cdot \text{coeff}_{\beta + \tau}(f)$$

*Proof.* The iteratedPDeriv applies $\partial_i^{\tau_i}$ for each variable $i$. We prove by induction on the list of variables that the coefficient formula accumulates multiplicatively. The key observation is that applying $\partial_i^{\tau_i}$ shifts only coordinate $i$ in the exponent, so $(β + \tau_i \cdot e_i)_j = β_j$ for $j \neq i$, making the ascending factorial factors independent across variables. $\square$

### 3.3 The Support Criterion

**Corollary 3.3** (Support criterion). If $R$ is a domain of characteristic zero, then:
$$\text{coeff}_{\beta}(\partial^{\tau} f) \neq 0 \iff \text{coeff}_{\beta + \tau}(f) \neq 0$$

*Proof.* The scalar $\prod_i (\beta_i + 1)^{\overline{\tau_i}}$ is a product of ascending factorials starting from positive integers, hence is a positive natural number. In a domain of characteristic zero, its image in $R$ is nonzero. $\square$

### 3.4 The Exact $k$-th Shadow Theorem

**Theorem 3.4** (Exact Shadow Theorem). For $f$ over a characteristic-zero domain:
$$\beta \in \text{Sh}_k(\text{supp}(f)) \iff \exists\, \tau,\ |\tau| = k \wedge \beta \in \text{supp}(\partial^{\tau} f)$$

*Proof.* By definition, $\beta \in \text{Sh}_k(\text{supp}(f))$ iff $\exists\, \tau$ with $|\tau| = k$ and $\beta + \tau \in \text{supp}(f)$. By the support criterion (Corollary 3.3), this is equivalent to $\exists\, \tau$ with $|\tau| = k$ and $\text{coeff}_{\beta}(\partial^{\tau} f) \neq 0$, which is exactly $\beta \in \text{supp}(\partial^{\tau} f)$. $\square$

---

## 4. The Shadow Semigroup Law

**Theorem 4.1** (Shadow Composition). For any finite set $S$ and $a, b \in \mathbb{N}$:
$$\text{Sh}_b(\text{Sh}_a(S)) = \text{Sh}_{a+b}(S)$$

*Proof sketch.*

**Forward ($\subseteq$):** If $\beta \in \text{Sh}_b(\text{Sh}_a(S))$, there exists $\tau_2$ with $|\tau_2| = b$ and $\beta + \tau_2 \in \text{Sh}_a(S)$. Then there exists $\tau_1$ with $|\tau_1| = a$ and $(\beta + \tau_2) + \tau_1 \in S$. Setting $\tau = \tau_1 + \tau_2$, we have $|\tau| = a + b$ and $\beta + \tau \in S$.

**Reverse ($\supseteq$):** If $\beta \in \text{Sh}_{a+b}(S)$, there exists $\tau$ with $|\tau| = a + b$ and $\beta + \tau \in S$. We need to decompose $\tau$ into $\tau_1 + \tau_2$ with $|\tau_1| = a$ and $|\tau_2| = b$. This requires a key combinatorial lemma:

**Lemma 4.2** (Multi-index splitting). For any $\tau$ with $|\tau| = m$ and any $a \leq m$, there exists $\tau_1 \leq \tau$ with $|\tau_1| = a$.

The lemma is proved by a greedy argument: distribute mass $a$ among coordinates without exceeding $\tau_i$ at any coordinate. Given the split $\tau = \tau_1 + \tau_2$, we have $\beta + \tau_2 \in \text{Sh}_a(S)$ (witnessed by $\tau_1$), and then $\beta \in \text{Sh}_b(\text{Sh}_a(S))$ (witnessed by $\tau_2$). $\square$

---

## 5. Basic Shadow Properties

**Proposition 5.1.** $\text{Sh}_0(S) = S$.

**Proposition 5.2.** $\text{Sh}_k(\emptyset) = \emptyset$.

**Proposition 5.3** (Monotonicity). $S_1 \subseteq S_2 \implies \text{Sh}_k(S_1) \subseteq \text{Sh}_k(S_2)$.

**Proposition 5.4** (Simplex shadow). For the full simplex $\Delta(n, d) = \{\alpha \in \mathbb{N}^n : |\alpha| = d\}$:
$$\text{Sh}_k(\Delta(n, d)) = \Delta(n, d-k) \text{ for } k \leq d, \quad \text{Sh}_k(\Delta(n, d)) = \emptyset \text{ for } k > d$$

**Proposition 5.5** (Uniform matroid shadow). For the basis support $B(n, r)$ of the uniform matroid $U_{r,n}$:
$$|\text{Sh}_k(B(n, r))| = \binom{n}{r-k} \text{ for } 0 \leq k \leq r$$

---

## 6. The Shadow Log-Concavity Conjecture

### 6.1 Statement

**Conjecture 6.1** (Shadow Log-Concavity for Exchange Supports). If $S$ satisfies the discrete exchange property (Definition 2.5) and $a_k = |\text{Sh}_k(S)|$, then the sequence $(a_k)$ is log-concave:
$$a_k^2 \geq a_{k-1} \cdot a_{k+1} \quad \text{for all admissible } k$$

### 6.2 Computational Evidence

We tested the conjecture systematically across four families:

| Family | Parameters tested | Tests | Counterexamples |
|--------|------------------|-------|-----------------|
| Uniform matroid $U_{r,n}$ | $3 \leq n \leq 8$, $2 \leq r < n$ | 21 | 0 |
| Simplex $\Delta(n,d)$ | $2 \leq n \leq 6$, $1 \leq d \leq 6$ | 30 | 0 |
| Product $\prod [0, d_i]$ | Various, $n \leq 4$ | 8 | 0 |
| Random exchange families | $3 \leq n \leq 6$ | 20 | 0 |
| **Total** | | **79** | **0** |

The stronger ratio-monotonicity property ($a_{k+1}/a_k \leq a_k/a_{k-1}$) also holds in all tested cases.

### 6.3 Theoretical Context

If Conjecture 6.1 is true, it would provide a new combinatorial route to log-concavity results in the spirit of the Brändén–Huh theory. The shadow operator would serve as a discrete analogue of the differential operators whose norm decay gives the Lorentzian property.

For uniform matroids, the conjecture reduces to log-concavity of binomial coefficients $\binom{n}{r-k}$, which is classical. For general exchange families, it would be a new result.

---

## 7. Algorithms

### 7.1 Shadow Computation

**Algorithm 1: kth_shadow(S, k)**

```
Input: Finite set S ⊂ ℕ^n, integer k ≥ 0
Output: Sh_k(S)

shadow ← ∅
for each α ∈ S:
    for each τ ∈ {τ ∈ ℕ^n : τ ≤ α, |τ| = k}:
        shadow ← shadow ∪ {α - τ}
return shadow
```

**Complexity:** $O(|S| \cdot D^n)$ where $D = \max_{\alpha \in S} \max_i \alpha_i$ is the maximum coordinate value. The enumeration of multi-indices $\tau \leq \alpha$ with $|\tau| = k$ has size at most $\binom{k + n - 1}{n - 1}$.

### 7.2 Shadow Profile Computation

**Algorithm 2: shadow_profile(S)**

```
Input: Finite set S ⊂ ℕ^n
Output: [|Sh_0(S)|, |Sh_1(S)|, ..., |Sh_D(S)|]

D ← max{|α| : α ∈ S}
return [|kth_shadow(S, k)| for k = 0, 1, ..., D]
```

### 7.3 Exchange Property Test

**Algorithm 3: is_exchange_family(S)**

```
Input: Finite set S ⊂ ℕ^n
Output: Boolean

for each α, β ∈ S:
    for each i with α_i > β_i:
        if ∄ j with β_j > α_j and α - e_i + e_j ∈ S:
            return False
return True
```

**Complexity:** $O(|S|^2 \cdot n^2)$.

---

## 8. Applications

### 8.1 Sparse Automatic Differentiation

The shadow profile provides exact predictions for the number of nonzero terms in any $k$-th order mixed partial derivative, without performing any polynomial arithmetic. This enables:

- **Cost prediction**: Before computing a derivative, determine its output size.
- **Memory allocation**: Pre-allocate exact storage for sparse derivative representations.
- **Parallelization**: Distribute derivative computations based on predicted workloads.

### 8.2 Newton Polytope Analysis

The shadow operator describes discrete contraction of the Newton polytope. For convex supports (full simplices), $\text{Sh}_k$ yields smaller simplices—the discrete analogue of moving inward through the polytope by $k$ lattice steps. For non-convex supports, shadows can exhibit non-monotone behavior, revealing geometric complexity invisible in the convex hull.

### 8.3 Matroid Independence Counting

For matroid basis generating polynomials, $|\text{Sh}_k(B)|$ counts the number of independent sets of rank $r - k$, connecting shadow geometry to matroid invariants. This provides a derivative-free approach to computing matroid statistics.

---

## 9. Formal Verification

All main theorems are formalized in Lean 4 (v4.28.0) with Mathlib. The formalization resides in `Catalog/Speculative/AutoResearch/IteratedShadowGeometry.lean` and includes:

| Theorem | Lean Name | Status |
|---------|-----------|--------|
| Membership criterion | `mem_kthShadow_iff'` | ✓ Verified |
| Coefficient transport (single) | `coeff_pderivPow` | ✓ Verified |
| Coefficient transport (multi) | `coeff_iteratedPDeriv` | ✓ Verified |
| Support criterion | `coeff_iteratedPDeriv_ne_zero_iff` | ✓ Verified |
| Exact shadow theorem | `mem_kthShadow_iff_exists_iteratedDerivative` | ✓ Verified |
| Shadow composition law | `kthShadow_add` | ✓ Verified |
| Shadow at zero | `kthShadow_zero` | ✓ Verified |
| Shadow monotonicity | `kthShadow_mono` | ✓ Verified |
| Product of asc. factorials positive | `prod_ascFactorial_pos` | ✓ Verified |

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

---

## 10. Discussion and Future Work

### 10.1 Limitations

- The shadow log-concavity conjecture (Conjecture 6.1) remains unproven.
- The antitonicity of shadow profiles is false in general (counterexample: $S = \{(1,1)\}$ has $|\text{Sh}_0| = 1 < 2 = |\text{Sh}_1|$).
- The theory currently applies to characteristic zero; extensions to positive characteristic would require different scalar analysis.

### 10.2 Open Questions

1. **Prove or disprove Conjecture 6.1** for general exchange families.
2. **Tropical shadow operators**: define shadows on tropical semirings and relate to tropical differentiation.
3. **Circuit complexity**: can shadow profile decay rate provide lower bounds for algebraic circuit complexity?
4. **Probabilistic shadows**: define random shadow processes and study their mixing times.
5. **Hodge-theoretic interpretation**: relate shadow profiles to mixed Hodge numbers or intersection cohomology.

---

## References

1. P. Brändén and J. Huh, "Lorentzian polynomials," *Annals of Mathematics*, vol. 192, no. 3, pp. 821–891, 2020.

2. K. Murota, *Discrete Convex Analysis*, SIAM Monographs on Discrete Mathematics, 2003.

3. A. Schrijver, *Combinatorial Optimization: Polyhedra and Efficiency*, Springer, 2003.

4. R. Stanley, "Log-concave and unimodal sequences in algebra, combinatorics, and geometry," *Annals of the New York Academy of Sciences*, vol. 576, pp. 500–535, 1989.

5. J. Huh, "Combinatorial applications of the Hodge–Riemann relations," *Proceedings of the International Congress of Mathematicians*, 2018.
