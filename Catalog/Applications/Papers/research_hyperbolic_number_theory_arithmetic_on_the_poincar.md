# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

## Abstract

We develop a rigorous algebraic and geometric framework for arithmetic on the Poincaré disk, establishing five main results with machine-verified proofs. First, we prove the **Blaschke disk-preservation identity**: for a Möbius transformation $\varphi(z) = (az+b)/(\bar{b}z+\bar{a})$, the identity $|\bar{b}z+\bar{a}|^2(1-|\varphi(z)|^2) = (|a|^2-|b|^2)(1-|z|^2)$ holds, giving a clean proof that disk automorphisms preserve the hyperbolic metric. Second, we prove that **Einstein addition** (relativistic velocity addition) defines a commutative group on $(-1,1)$, including the non-trivial closure and associativity properties. Third, we establish the **rapidity homomorphism theorem**: $\operatorname{artanh}(a \oplus b) = \operatorname{artanh}(a) + \operatorname{artanh}(b)$, showing that hyperbolic arithmetic is isomorphic to ordinary addition. Fourth, we prove the **Chebyshev-cosine duality** $T_n(\cos\theta) = \cos(n\theta)$ and the **Chebyshev composition formula** $T_m(T_n(x)) = T_{mn}(x)$ for all real $x$, the latter requiring polynomial extensionality arguments. Fifth, we prove **orbit discreteness** for integer lattices.

**Keywords**: Poincaré disk, Einstein addition, Chebyshev polynomials, Möbius transformation, hyperbolic geometry, Selberg trace formula

## 1. Introduction

The integers $\mathbb{Z}$ are the fundamental objects of number theory, living on the flat real line with addition as their group operation. A natural question arises: what happens to arithmetic on a curved space?

The Poincaré disk $\mathbb{D} = \{z \in \mathbb{C} : |z| < 1\}$ is the standard model of the hyperbolic plane. Its isometries are Möbius transformations of the form $\varphi(z) = e^{i\theta}(z-a)/(1-\bar{a}z)$, and the group $\operatorname{PSL}_2(\mathbb{Z})$ acts on $\mathbb{D}$ via the Cayley transform from the upper half-plane. The orbit of any point under this action defines a discrete subset of $\mathbb{D}$ — the "hyperbolic integers."

In this paper, we establish the algebraic and geometric foundations needed to study number theory in this curved setting. Our results are:

1. **Blaschke identity** (Theorem 3.1): The fundamental metric identity for disk automorphisms.
2. **Einstein group** (Theorems 4.1–4.5): $(-1,1)$ with Einstein addition is a commutative group.
3. **Rapidity isomorphism** (Theorem 5.1): The artanh map is a group isomorphism $(-1,1) \xrightarrow{\sim} \mathbb{R}$.
4. **Chebyshev duality and composition** (Theorems 6.1–6.2): $T_n(\cos\theta) = \cos(n\theta)$ and $T_m \circ T_n = T_{mn}$.
5. **Orbit discreteness** (Theorems 7.1–7.2): Integer lattices in $\mathbb{R}$ are discrete.

All proofs have been formally verified in Lean 4 with the Mathlib library.

## 2. Preliminaries

### 2.1 The Poincaré Disk

The Poincaré disk is the open unit disk $\mathbb{D} = \{z \in \mathbb{C} : |z| < 1\}$ equipped with the Riemannian metric $ds^2 = 4|dz|^2/(1-|z|^2)^2$. The hyperbolic distance is:
$$d(z_1, z_2) = \operatorname{artanh}\left(\frac{|z_1-z_2|}{|1-\bar{z}_1 z_2|}\right)$$

### 2.2 Möbius Transformations

A Möbius transformation of the disk has the form $\varphi(z) = (az+b)/(\bar{b}z+\bar{a})$ where $|a|^2 - |b|^2 = 1$. These form the group $\operatorname{SU}(1,1)/\{\pm I\}$, isomorphic to $\operatorname{PSL}_2(\mathbb{R})$.

### 2.3 Notation

We write $\|z\|^2 = |z|^2 = z\bar{z}$ for the squared modulus (normSq in the formalization). The star ring endomorphism $\star$ denotes complex conjugation.

## 3. The Blaschke Disk-Preservation Identity

### 3.1 Core Algebraic Identity

**Theorem 3.1** (blaschke_normSq_difference). *For all $a, b, z \in \mathbb{C}$:*
$$|a + b\bar{z}|^2 - |az + b|^2 = (|a|^2 - |b|^2)(1 - |z|^2)$$

*Proof sketch.* Expand both normSq expressions using $|w|^2 = w\bar{w}$:
$$|a + b\bar{z}|^2 = |a|^2 + a\overline{b}\cdot z + \bar{a}b\bar{z} + |b|^2|z|^2$$
$$|az + b|^2 = |a|^2|z|^2 + a\overline{b}\cdot z + \bar{a}b\bar{z} + |b|^2$$

The cross terms $a\bar{b}z + \bar{a}b\bar{z}$ are identical and cancel in the difference, leaving $(|a|^2 + |b|^2|z|^2) - (|a|^2|z|^2 + |b|^2) = (|a|^2 - |b|^2)(1 - |z|^2)$. □

**Theorem 3.2** (blaschke_disk_identity). *For $\bar{b}z + \bar{a} \neq 0$:*
$$|\bar{b}z + \bar{a}|^2 \cdot \left(1 - \left|\frac{az+b}{\bar{b}z+\bar{a}}\right|^2\right) = (|a|^2 - |b|^2)(1 - |z|^2)$$

*Proof sketch.* Note that $\bar{b}z + \bar{a} = \overline{a + b\bar{z}}$, so $|\bar{b}z+\bar{a}|^2 = |a+b\bar{z}|^2$. Then:
$$|\bar{b}z+\bar{a}|^2\left(1 - \frac{|az+b|^2}{|\bar{b}z+\bar{a}|^2}\right) = |a+b\bar{z}|^2 - |az+b|^2$$
and apply Theorem 3.1. □

**Corollary.** When $|a|^2 - |b|^2 = 1$, the map $\varphi(z) = (az+b)/(\bar{b}z+\bar{a})$ satisfies $|\varphi(z)|^2 < 1$ whenever $|z|^2 < 1$. Thus $\varphi$ maps $\mathbb{D}$ into $\mathbb{D}$.

## 4. Einstein Addition: The Hyperbolic Group on (-1, 1)

### 4.1 Definition

**Definition.** Einstein addition on $\mathbb{R}$ is defined by:
$$a \oplus b = \frac{a + b}{1 + ab}$$

This is the relativistic velocity addition formula with $c = 1$.

### 4.2 Group Axioms

**Theorem 4.1** (einstein_denom_pos). *If $|a| < 1$ and $|b| < 1$, then $1 + ab > 0$.*

*Proof.* Since $-1 < a < 1$ and $-1 < b < 1$, we have $ab > -1$, so $1 + ab > 0$. □

**Theorem 4.2** (einstein_fundamental_identity). *$(1+ab)^2 - (a+b)^2 = (1-a^2)(1-b^2)$.*

*Proof.* Direct algebraic verification (ring). □

**Theorem 4.3** (einstein_add_closure). *If $|a| < 1$ and $|b| < 1$, then $|a \oplus b| < 1$.*

*Proof.* By Theorem 4.2, $(1+ab)^2 - (a+b)^2 = (1-a^2)(1-b^2) > 0$ since $|a|, |b| < 1$. Since $1+ab > 0$ (Theorem 4.1), this gives $|a+b| < 1+ab$, hence $|(a+b)/(1+ab)| < 1$. □

**Theorem 4.4** (einstein_add_assoc). *$(a \oplus b) \oplus c = a \oplus (b \oplus c)$ when all denominators are nonzero.*

*Proof.* Expanding both sides as rational functions and clearing denominators yields a polynomial identity, verified by the `grind` tactic. □

**Theorem 4.5.** *$a \oplus 0 = a$, $a \oplus (-a) = 0$, and $a \oplus b = b \oplus a$.*

### 4.3 Significance

The group $(-1, 1, \oplus)$ is the 1-dimensional analogue of the Poincaré disk with Möbius composition. It is isomorphic to $(\mathbb{R}, +)$ via the rapidity map (Section 5), but the Einstein presentation reveals the hyperbolic geometry directly.

## 5. The Rapidity Isomorphism

### 5.1 Definition and Main Result

**Definition.** The rapidity function is $\rho(x) = \frac{1}{2}\ln\frac{1+x}{1-x}$ for $x \in (-1,1)$.

**Theorem 5.1** (rapidity_einstein_homomorphism). *For $|a| < 1$ and $|b| < 1$:*
$$\rho(a \oplus b) = \rho(a) + \rho(b)$$

*Proof sketch.* Compute:
$$\frac{1 + \frac{a+b}{1+ab}}{1 - \frac{a+b}{1+ab}} = \frac{1+ab+a+b}{1+ab-a-b} = \frac{(1+a)(1+b)}{(1-a)(1-b)}$$

Therefore:
$$\rho(a \oplus b) = \frac{1}{2}\ln\frac{(1+a)(1+b)}{(1-a)(1-b)} = \frac{1}{2}\ln\frac{1+a}{1-a} + \frac{1}{2}\ln\frac{1+b}{1-b} = \rho(a) + \rho(b)$$

using $\ln(xy) = \ln x + \ln y$ for positive reals. □

### 5.2 Interpretation

This theorem shows that $\rho : ((-1,1), \oplus) \to (\mathbb{R}, +)$ is a group isomorphism. The inverse is $\rho^{-1}(r) = \tanh(r)$. Hyperbolic arithmetic is ordinary arithmetic "in disguise" — the rapidity map removes the curvature.

In physics, $\rho(v)$ is the rapidity of a particle with velocity $v$ (in units of $c$). The fact that rapidities add linearly while velocities don't is the key to understanding relativistic kinematics.

## 6. Chebyshev Polynomials and Trace-Distance Duality

### 6.1 Definitions and Basic Properties

**Definition.** Chebyshev polynomials of the first kind:
$$T_0(x) = 1, \quad T_1(x) = x, \quad T_{n+2}(x) = 2xT_{n+1}(x) - T_n(x)$$

### 6.2 The Chebyshev-Cosine Duality

**Theorem 6.1** (chebyshevT_cos). *$T_n(\cos\theta) = \cos(n\theta)$ for all $n \in \mathbb{N}$ and $\theta \in \mathbb{R}$.*

*Proof.* Induction on $n$ using strong induction. Base cases $n=0,1$ are immediate. For $n+2$:
$$T_{n+2}(\cos\theta) = 2\cos\theta \cdot \cos((n+1)\theta) - \cos(n\theta)$$
The product-to-sum formula $2\cos\alpha\cos\beta = \cos(\alpha-\beta) + \cos(\alpha+\beta)$ with $\alpha = \theta$, $\beta = (n+1)\theta$ gives:
$$= \cos(n\theta) + \cos((n+2)\theta) - \cos(n\theta) = \cos((n+2)\theta) \quad \square$$

### 6.3 The Composition Formula

**Theorem 6.2** (chebyshevT_comp). *$T_m(T_n(\cos\theta)) = T_{mn}(\cos\theta)$ for all $m, n, \theta$.*

*Proof.* By Theorem 6.1: $T_m(T_n(\cos\theta)) = T_m(\cos(n\theta)) = \cos(mn\theta) = T_{mn}(\cos\theta)$. □

**Theorem 6.3** (chebyshevT_comp_general). *$T_m(T_n(x)) = T_{mn}(x)$ for ALL $x \in \mathbb{R}$.*

*Proof.* Both sides are polynomial functions of $x$. They agree for all $x \in [-1,1]$ (since every such $x$ is $\cos\theta$ for some $\theta$). Since $[-1,1]$ is infinite and two polynomials agreeing on an infinite set must be identical, the equality holds for all $x \in \mathbb{R}$.

The formal proof constructs explicit polynomial representations of both sides using Mathlib's `Polynomial` type, verifies they agree on the infinite set $\{cos\theta : \theta \in \mathbb{R}\} \supseteq [-1,1]$, and applies the polynomial identity principle (a nonzero polynomial has finitely many roots). □

### 6.4 Application: Trace-Distance Duality

For $\gamma \in \operatorname{SL}_2(\mathbb{Z})$ with $|\operatorname{tr}(\gamma)| = t$, the hyperbolic distance from $i$ to $\gamma \cdot i$ satisfies $\cosh(d(i, \gamma \cdot i)) = t/2$. The $n$-th iterate has trace $2T_n(t/2)$, so by the composition formula:

$$\operatorname{tr}(\gamma^{mn}) = 2T_{mn}(t/2) = 2T_m(T_n(t/2)) = 2T_m(\operatorname{tr}(\gamma^n)/2)$$

This recurrence is the key to counting orbit points in hyperbolic space and connects to the Selberg trace formula.

## 7. Orbit Discreteness

**Theorem 7.1** (int_is_discrete). *The set $\mathbb{Z} \subset \mathbb{R}$ is discrete: for every $R > 0$, the set $\{n \in \mathbb{Z} : |n| < R\}$ is finite.*

**Theorem 7.2** (scaled_int_is_discrete). *For $c \neq 0$, the set $\{cn : n \in \mathbb{Z}\}$ is discrete.*

These results establish the discreteness paradigm that extends to orbits of SL₂(ℤ) acting on the Poincaré disk. The orbit $\operatorname{SL}_2(\mathbb{Z}) \cdot 0$ is discrete in $\mathbb{D}$ — a consequence of the discreteness of SL₂(ℤ) in SL₂(ℝ).

## 8. Discussion and Future Work

### 8.1 Unique Factorization

Since $\operatorname{PSL}_2(\mathbb{Z}) \cong \mathbb{Z}/2 \star \mathbb{Z}/3$ (the free product), every group element has a unique reduced word in the generators $S$ and $T$. This provides a natural notion of "unique factorization" for hyperbolic integers. Formalizing this requires the normal form theorem for free products.

### 8.2 The Prime Geodesic Theorem

The number of primitive closed geodesics of length at most $R$ on $\operatorname{PSL}_2(\mathbb{Z}) \backslash \mathbb{H}$ is asymptotic to $e^R / R$ as $R \to \infty$ (Huber's theorem). This is the hyperbolic analogue of the prime number theorem and follows from the Selberg trace formula.

### 8.3 The Selberg Zeta Function

The Selberg zeta function $Z(s) = \prod_{\{p\}} \prod_{k=0}^{\infty} (1 - e^{-(s+k)\ell(p)})$ satisfies a functional equation and has its nontrivial zeros at $s = 1/2 \pm ir_j$ where $\lambda_j = 1/4 + r_j^2$ are eigenvalues of the Laplacian. Unlike the Riemann zeta function, the location of these zeros is a *theorem*, not a conjecture.

### 8.4 Connections to Physics

Einstein addition is not just an analogy — it IS the velocity addition formula of special relativity. The rapidity isomorphism is the standard tool of relativistic kinematics. The Poincaré disk model appears naturally in:

- Quantum information (the Bloch ball is hyperbolic)
- AdS/CFT correspondence (Anti-de Sitter space is hyperbolic)
- Machine learning (hyperbolic embeddings for hierarchical data)

## 9. Summary of Formal Results

| Theorem | Statement | Lean Name |
|---------|-----------|-----------|
| Blaschke identity | $\|a+b\bar{z}\|^2 - \|az+b\|^2 = (\|a\|^2-\|b\|^2)(1-\|z\|^2)$ | `blaschke_normSq_difference` |
| Disk preservation | $\|\bar{b}z+\bar{a}\|^2(1-\|\varphi(z)\|^2) = (\|a\|^2-\|b\|^2)(1-\|z\|^2)$ | `blaschke_disk_identity` |
| Einstein closure | $\|a\|,\|b\|<1 \Rightarrow \|a\oplus b\|<1$ | `einstein_add_closure` |
| Associativity | $(a\oplus b)\oplus c = a\oplus(b\oplus c)$ | `einstein_add_assoc` |
| Rapidity homomorphism | $\rho(a\oplus b) = \rho(a)+\rho(b)$ | `rapidity_einstein_homomorphism` |
| Chebyshev-cosine | $T_n(\cos\theta)=\cos(n\theta)$ | `chebyshevT_cos` |
| Chebyshev composition | $T_m \circ T_n = T_{mn}$ | `chebyshevT_comp_general` |
| Integer discreteness | $\mathbb{Z}$ is discrete in $\mathbb{R}$ | `int_is_discrete` |

## References

1. Ungar, A.A. *Analytic Hyperbolic Geometry and Albert Einstein's Special Theory of Relativity.* World Scientific, 2008.
2. Beardon, A.F. *The Geometry of Discrete Groups.* Springer, 1983.
3. Selberg, A. "Harmonic analysis and discontinuous groups in weakly symmetric Riemannian spaces with applications to Dirichlet series." *J. Indian Math. Soc.* 20, 47–87, 1956.
4. Iwaniec, H. *Spectral Methods of Automorphic Forms.* AMS, 2002.
5. Mason, J.C. and Handscomb, D.C. *Chebyshev Polynomials.* CRC Press, 2003.
