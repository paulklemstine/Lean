# A Norm Criterion for Linearized Frobenius Permutation Polynomials over $\mathbb{F}_{p^2}$

**Author:** Aristotle

**Date:** 2026-06-28

**Domain:** Novelty — Permutation polynomials over finite fields

---

## Abstract

We study the family of polynomials
$$f(x) = x^{q} + b\,x^{2} + c\,x + d$$
over a finite field $K$ of cardinality $q^{2}$, with the aim of characterizing when $f$ is a *permutation polynomial* — that is, when the induced map $x \mapsto f(x)$ is a bijection of $K$. Working in the prime-field base case $q = p$ (so $|K| = p^{2}$ and the Frobenius $x \mapsto x^{p}$ plays the role of $x \mapsto x^{q}$), we establish a complete and discriminant-free criterion for the linearized sub-family. Our **main theorem** states that the $\mathbb{F}_p$-linear map
$$L_{a,c}(x) = a\,x^{p} + c\,x$$
is a bijection of $K$ **if and only if** $a^{p+1} \neq c^{p+1}$; equivalently, writing $N(z) = z^{p+1} = z\cdot z^{p}$ for the relative norm $N : K \to \mathbb{F}_p$, the map permutes $K$ iff $N(a) \neq N(c)$. Three consequences follow. (1) *Shift invariance*: the constant term $d$ never affects the permutation property. (2) *Exact count*: for $a = 1$, exactly $p+1$ coefficients $c$ fail the criterion, so exactly $p^{2} - (p+1)$ coefficients yield a permutation; the exceptional coefficients are precisely the $(p+1)$-th roots of unity. (3) *Characteristic-two collapse*: when $\operatorname{char} K = 2$ and $q = 2$, the quadratic term $b\,x^{2}$ merges with the Frobenius term $x^{2}$, so the full family $x^{2} + b\,x^{2} + c\,x + d$ over $\mathbb{F}_4$ is completely characterized by the same norm criterion, $N(1+b) \neq N(c)$, with no Weil-sum machinery required. We discuss the genuinely open odd-characteristic regime $b \neq 0$, where a Weil-sum/discriminant obstruction appears, and formulate sharp conjectures anchored by the proven exact count.

---

## 1. Introduction

### 1.1 Permutation polynomials

Let $K$ be a finite field. A polynomial $f \in K[x]$ is a **permutation polynomial** (PP) of $K$ if the evaluation map $x \mapsto f(x)$ is a bijection $K \to K$. Equivalently, because $K$ is finite, $f$ is a PP iff it is injective, iff it is surjective. Permutation polynomials are the algebraic incarnation of reversible transformations and are foundational in cryptography, coding theory, combinatorial design, and the theory of finite geometries: every invertible round function expressible in field arithmetic is a permutation polynomial.

Deciding whether a given $f$ is a PP is, in general, hard. For low-degree or highly structured families one can hope for explicit coefficient criteria, but already for cubic and quartic families the classification fragments into many cases, and for general degree no closed criterion is known. A standard and powerful approach reduces the question to counting solutions of $f(x) = f(y)$ with $x \neq y$, which, after extracting the diagonal factor $(x-y)$, becomes a point-counting problem on an algebraic curve and is governed by Weil's bound.

### 1.2 The family under study

We consider
$$f(x) = x^{q} + b\,x^{2} + c\,x + d \in K[x], \qquad |K| = q^{2}. \tag{1.1}$$
The exponent $q$ ties the leading term to the field automorphism structure: when $|K| = q^{2}$, the map $x \mapsto x^{q}$ is the generator of $\operatorname{Gal}(K/\mathbb{F}_q)$, an additive (linearized) operation. We focus on the prime base case $q = p$, where $|K| = p^{2}$ and $x \mapsto x^{p}$ is the Frobenius automorphism of $K$ over its prime field $\mathbb{F}_p$.

Our contribution is a complete, elementary classification of the **linearized core** of (1.1), namely $a\,x^{p} + c\,x + d$, together with the exact enumeration of its exceptional coefficients and a complete treatment of the characteristic-two specialization of the full family. The honest boundary of these methods — the odd-characteristic $b \neq 0$ regime — is delineated and packaged into precise conjectures.

### 1.3 Notation

Throughout, $K$ is a field with $\operatorname{Fintype.card} K = p^{2}$ for a prime $p$, of characteristic $p$. We write:

- $\operatorname{Frob}(x) = x^{p}$ for the Frobenius endomorphism; on $K$ it is an automorphism with $\operatorname{Frob}^{2} = \mathrm{id}$.
- $N : K \to K$, $N(z) = z^{p+1} = z\cdot z^{p} = z \cdot \operatorname{Frob}(z)$ for the relative norm of $K/\mathbb{F}_p$. One has $N(z) \in \mathbb{F}_p$ for all $z$, and $N$ is multiplicative on $K^{\times}$.
- $L_{a,c}(x) = a\,x^{p} + c\,x$ for the linearized map with coefficients $a,c \in K$.

---

## 2. Preliminaries

### 2.1 The Frobenius as conjugation

**Lemma 2.1 (Freshman's dream / additivity of Frobenius).** *In a field $K$ of characteristic $p$, the map $\operatorname{Frob}(x) = x^{p}$ satisfies $\operatorname{Frob}(x+y) = \operatorname{Frob}(x) + \operatorname{Frob}(y)$ and $\operatorname{Frob}(xy) = \operatorname{Frob}(x)\operatorname{Frob}(y)$.*

*Proof sketch.* Multiplicativity is immediate. For additivity, expand $(x+y)^p$ by the binomial theorem; each intermediate coefficient $\binom{p}{k}$ for $0 < k < p$ is divisible by $p$, hence zero in $K$. $\square$

Consequently $\operatorname{Frob}$ is $\mathbb{F}_p$-linear. When $|K| = p^{2}$, the fixed field of $\operatorname{Frob}$ is exactly $\mathbb{F}_p$, and $\operatorname{Frob}^{2} = \mathrm{id}$ (since $x^{p^2} = x$ for all $x \in K$). Thus $\operatorname{Frob}$ behaves precisely like complex conjugation on a quadratic extension, and $N(z) = z\cdot\operatorname{Frob}(z)$ behaves precisely like the squared modulus $|w|^2 = w\bar w$.

### 2.2 The multiplicative group is cyclic

**Lemma 2.2.** *The group $K^{\times}$ is cyclic of order $p^{2} - 1 = (p-1)(p+1)$.*

This is the standard fact that the multiplicative group of any finite field is cyclic. It is the structural engine behind both the sufficiency direction of the main theorem and the exact count.

**Lemma 2.3 (Existence of a primitive $(p+1)$-th root of unity).** *There exists $\zeta \in K$ with $\operatorname{IsPrimitiveRoot}\,\zeta\,(p+1)$, i.e. $\zeta$ has multiplicative order exactly $p+1$.*

*Proof sketch.* Since $(p+1) \mid (p-1)(p+1) = |K^{\times}|$ and $K^{\times}$ is cyclic, it contains a (unique) subgroup of order $p+1$, any generator of which is a primitive $(p+1)$-th root of unity. Formally one exhibits an element of order $p+1$ using `IsCyclic.card_orderOf_eq_totient` applied to the divisor $p+1$ of $|K^{\times}|$. This is the content of the formal lemma `exists_primitiveRoot_pSucc`. $\square$

---

## 3. Main results

### 3.1 The norm criterion for linearized maps

**Theorem 3.1 (Norm criterion; `linearized_bijective_iff`).** *Let $|K| = p^{2}$ and let $a, c \in K$. The $\mathbb{F}_p$-linear map*
$$L_{a,c}(x) = a\,x^{p} + c\,x$$
*is a bijection of $K$ if and only if*
$$a^{p+1} \neq c^{p+1}, \qquad\text{equivalently}\qquad N(a) \neq N(c).$$

*Proof sketch.* Since $L_{a,c}$ is an $\mathbb{F}_p$-linear endomorphism of the finite-dimensional $\mathbb{F}_p$-vector space $K$, it is a bijection iff it is injective iff $\ker L_{a,c} = \{0\}$.

*(Necessity of $N(a)\neq N(c)$ — the kernel identity.)* Suppose $L_{a,c}(x) = 0$, i.e.
$$a\,x^{p} + c\,x = 0. \tag{3.1}$$
Apply $\operatorname{Frob}$ to (3.1). Using Lemma 2.1 and $\operatorname{Frob}^2 = \mathrm{id}$ (so $(x^p)^p = x$),
$$a^{p}\,x + c^{p}\,x^{p} = 0. \tag{3.2}$$
Eliminate $x^{p}$ between (3.1) and (3.2): multiply (3.1) by $c^{p}$ and (3.2) by $a$ and subtract, obtaining $(c^{p}c - a\,a^{p})\,x = 0$, that is
$$\bigl(c^{p+1} - a^{p+1}\bigr)\,x = 0. \tag{3.3}$$
Hence if $a^{p+1} \neq c^{p+1}$ then $x = 0$, so the kernel is trivial and $L_{a,c}$ is a bijection. This proves the "$\Leftarrow$" direction (a clean, discriminant-free implication obtained from a single application of Frobenius and elimination).

*(Sufficiency of failure when $N(a) = N(c)$.)* Conversely, suppose $a^{p+1} = c^{p+1}$. We produce a nonzero kernel element. If $a = 0$ then $c^{p+1} = 0$, so $c = 0$ and $L_{a,c} \equiv 0$ is not injective. If $a \neq 0$ then $c \neq 0$, and $(c/a)^{p+1} = 1$, so $t := c/a$ is a norm-one element. Using cyclicity of $K^{\times}$ (Lemma 2.2), the $(p-1)$-power map on $K^\times$ surjects onto the norm-one subgroup $\{u : u^{p+1} = 1\}$; hence there is $w \in K^{\times}$ with $w^{p-1} = -t$ (the sign is available because $-t$ also has norm one). Setting $x = w$ gives $a\,x^{p} + c\,x = a\,w(w^{p-1} + t) = a\,w(-t + t) = 0$ with $x \neq 0$. Thus $L_{a,c}$ is not injective. (This is the "Hilbert-90-free" cyclic-group argument; it avoids invoking the additive Hilbert 90 directly.) $\square$

**Remark 3.2.** The criterion is genuinely two-sided and entirely free of discriminants: deciding whether $L_{a,c}$ permutes $K$ reduces to comparing the two prime-field elements $N(a)$ and $N(c)$. This stands in sharp contrast to the general odd-characteristic case (Section 6), where a Weil-sum obstruction enters.

### 3.2 Irrelevance of the constant term

**Theorem 3.3 (Shift invariance; `bijective_add_const_iff`).** *For any $a, c, d \in K$, the affine map $x \mapsto a\,x^{p} + c\,x + d$ is a bijection of $K$ if and only if $x \mapsto a\,x^{p} + c\,x$ is.*

*Proof sketch.* Translation $T_d(y) = y + d$ is a bijection of $K$ with inverse $T_{-d}$. The affine map equals $T_d \circ L_{a,c}$, and a composite with a bijection is a bijection iff the other factor is. $\square$

Combining Theorems 3.1 and 3.3 gives the complete classification of the linearized family $a\,x^{p} + c\,x + d$: it permutes $K$ iff $N(a) \neq N(c)$, regardless of $d$.

### 3.3 Counting the exceptional coefficients

Fix $a = 1$, so $N(a) = 1$ and the criterion becomes $c^{p+1} \neq 1$. We enumerate the failures.

**Lemma 3.4 (Exceptional set $=$ roots of unity; `normOne_eq_nthRoots`).** *As subsets of $K$,*
$$\{\,c \in K : c^{p+1} = 1\,\} = \mu_{p+1},$$
*the set of $(p+1)$-th roots of unity in $K$ (`Polynomial.nthRootsFinset (p+1) 1`).*

*Proof sketch.* By definition $c \in \mu_{p+1}$ iff $c \neq 0$ and $c^{p+1} = 1$; but $c^{p+1} = 1$ already forces $c \neq 0$, so the two descriptions coincide. $\square$

**Theorem 3.5 (Exact count; `card_norm_one`).** *If $|K| = p^{2}$, then*
$$\#\{\,c \in K : c^{p+1} = 1\,\} = p + 1.$$
*Equivalently, exactly $p+1$ coefficients $c$ make $x \mapsto x^{p} + c\,x$ fail to permute $K$.*

*Proof sketch.* By Lemma 3.4 the set is $\mu_{p+1}$. By Lemma 2.3 there is a primitive $(p+1)$-th root of unity $\zeta \in K$; a primitive $n$-th root of unity exists in $K$ iff $\#\mu_n = n$ (the polynomial $X^{p+1} - 1$ then splits with distinct roots), so $\#\mu_{p+1} = p+1$. Formally this is `IsPrimitiveRoot.card_nthRootsFinset`. $\square$

**Theorem 3.6 (Complementary count; `card_permutation_coeffs`).** *If $|K| = p^{2}$, then*
$$\#\{\,c \in K : c^{p+1} \neq 1\,\} = p^{2} - (p+1).$$
*These are exactly the coefficients $c$ for which $x \mapsto x^{p} + c\,x$ permutes $K$.*

*Proof sketch.* The two sets $\{c^{p+1} = 1\}$ and $\{c^{p+1} \neq 1\}$ partition $K$, so their cardinalities sum to $|K| = p^{2}$. Subtract Theorem 3.5. $\square$

**Corollary 3.7 (Vanishing exceptional fraction).** *The proportion of coefficients $c$ for which $x \mapsto x^{p} + c\,x$ fails to permute is $(p+1)/p^{2} \to 0$ as $p \to \infty$.* In particular $c = 0$ is never exceptional, since $0^{p+1} = 0 \neq 1$; the pure Frobenius $x \mapsto x^{p}$ is always a permutation.

### 3.4 The characteristic-two collapse

**Theorem 3.8 (Characteristic-two characterization; `permPoly_charTwo_iff`).** *Let $K = \mathbb{F}_4$ (so $p = 2$, $|K| = 4$, $q = 2$). For all $b, c, d \in K$, the polynomial*
$$f(x) = x^{2} + b\,x^{2} + c\,x + d$$
*is a permutation polynomial of $K$ if and only if*
$$N(1+b) \neq N(c).$$

*Proof sketch.* In characteristic $2$ the Frobenius is $\operatorname{Frob}(x) = x^{2}$, and the two quadratic contributions merge:
$$x^{2} + b\,x^{2} = (1+b)\,x^{2} = (1+b)\,\operatorname{Frob}(x).$$
Hence $f(x) = (1+b)\,x^{p} + c\,x + d$, a linearized affine map with leading coefficient $a = 1+b$. By Theorems 3.1 and 3.3, $f$ permutes $K$ iff $N(1+b) \neq N(c)$. $\square$

This yields a *complete* characterization of the full family (1.1) when $q = 2$ over $\mathbb{F}_4$, with no Weil-sum input. The crucial phenomenon is that the would-be "genuine quadratic" term is, in characteristic two, secretly linear modulo Frobenius.

---

## 4. Algorithms

The criteria above are constructive and translate directly into decision and enumeration procedures. We describe three.

### 4.1 Norm-criterion permutation test

**Purpose.** Decide whether $L_{a,c}(x) = a\,x^{p} + c\,x$ (or its affine variant with any $d$) permutes $K = \mathbb{F}_{p^2}$.

**Method.** Compute $N(a) = a^{p+1}$ and $N(c) = c^{p+1}$ in $K$ (each landing in $\mathbb{F}_p$), and return $N(a) \neq N(c)$. With fast exponentiation this is $O(\log p)$ field multiplications, versus $O(p^2)$ for the brute-force injectivity check — an exponential speedup in the bit-size of $p$.

**Pseudocode.**
```
function PermutesLinearized(a, c, p, K):
    Na <- Pow(a, p + 1)        # field exponentiation in K = F_{p^2}
    Nc <- Pow(c, p + 1)
    return (Na != Nc)
```

### 4.2 Exact enumeration of exceptional coefficients

**Purpose.** Produce the exact set and count of coefficients $c$ for which $x \mapsto x^{p} + c\,x$ fails to permute $K$.

**Method.** By Theorem 3.5 the count is $p+1$ without any search. To list them explicitly, find a primitive $(p+1)$-th root of unity $\zeta$ (e.g. raise a multiplicative generator $g$ of $K^\times$ to the power $(p-1)$), then output $\{\zeta^{0}, \zeta^{1}, \dots, \zeta^{p}\}$. Complexity: $O(p)$ multiplications to list, $O(1)$ to count.

**Pseudocode.**
```
function ExceptionalCoefficients(p, K):
    g    <- multiplicative generator of K^x          # order p^2 - 1
    zeta <- Pow(g, p - 1)                              # order exactly p + 1
    return { Pow(zeta, k) : k = 0, 1, ..., p }         # exactly p + 1 elements
```

### 4.3 Characteristic-two full-family decision

**Purpose.** Decide whether $x^{2} + b\,x^{2} + c\,x + d$ permutes $\mathbb{F}_4$.

**Method.** Apply the collapse of Theorem 3.8: set $a \leftarrow 1 + b$ and return $N(a) \neq N(c)$.

**Pseudocode.**
```
function PermutesCharTwoFamily(b, c, d, K = F_4):
    a <- 1 + b
    return (Norm(a) != Norm(c))      # d ignored by shift invariance
```

---

## 5. Numerical validation

Exhaustive computer checks confirm every theorem on small fields (the diagonal-free brute-force injectivity test is feasible there):

- **Theorem 3.1.** Over $\mathbb{F}_{9}, \mathbb{F}_{25}, \mathbb{F}_{49}$, all $p^{2}\times p^{2}$ pairs $(a,c)$ were tested; the brute-force permutation status matched $N(a)\neq N(c)$ in every case (0 mismatches).
- **Theorem 3.3.** Over $\mathbb{F}_{25}$, for fixed $(a,c)$ the permutation status was invariant across all $25$ constants $d$.
- **Theorems 3.5–3.6.** Over $\mathbb{F}_{9}, \mathbb{F}_{25}, \mathbb{F}_{49}, \mathbb{F}_{121}$ the exceptional counts were $4, 6, 8, 12 = p+1$ and the permutation counts $5, 19, 41, 109 = p^{2}-(p+1)$, matching exactly.
- **Theorem 3.8.** Over $\mathbb{F}_4$, all $4^{3} = 64$ triples $(b,c,d)$ were tested; brute-force status matched $N(1+b)\neq N(c)$ with 0 mismatches.

These computations use the explicit model $K = \mathbb{F}_p[t]/(t^2 - g)$ with $g$ a fixed quadratic non-residue, in which $\operatorname{Frob}(u + vt) = u - vt$ and $N(u+vt) = u^{2} - g\,v^{2}$.

---

## 6. The open odd-characteristic regime ($b \neq 0$)

When $p$ is odd and $b \neq 0$, the term $b\,x^{2}$ is a genuine quadratic that does not merge with the Frobenius term, and the clean norm criterion no longer applies. The standard reduction is illuminating. Define the difference quotient
$$\Phi(x,y) = \frac{f(x) - f(y)}{x - y} = \frac{x^{p} - y^{p}}{x - y} + b(x + y) + c.$$
Then $f$ fails to be a permutation iff $\Phi(x,y) = 0$ has a solution with $x \neq y$. The locus $\Phi = 0$ is an affine plane curve over $K$, and by Weil's bound its number of $K$-points is $q + O(\sqrt{q})$. For large $q$ the obstruction therefore degenerates to a single low-degree resultant condition on $(b,c)$ — a discriminant-type polynomial $g(b,c)$ whose non-vanishing should characterize the permutation property. The proven cases above pin down the boundary value of any such $g$: as $b \to 0$ the criterion must reduce to $c^{q+1} \neq 1$, i.e. $g|_{b=0} = c^{q+1} - 1$ up to a unit.

This is exactly the structure that turns vague heuristics into sharp conjectures (Section 8).

---

## 7. Applications

**Cryptographic primitives.** Linearized and near-linearized permutation polynomials over $\mathbb{F}_{p^2}$ furnish invertible diffusion layers and S-box components. The norm criterion gives a constant-time ($O(\log p)$ field operations) reversibility test, and the exact count $p^2 - (p+1)$ quantifies the abundance of valid keys/parameters: a vanishing fraction $(p+1)/p^2$ of choices must be avoided.

**Coding theory and finite geometry.** Permutation polynomials parametrize certain linear and nonlinear codes and act as collineations in finite projective planes; the norm-one subgroup $\mu_{p+1}$ that emerges here is the same object underlying Hermitian curves and unitals over $\mathbb{F}_{p^2}$, linking the count $p+1$ to incidence structures.

**Pedagogical model.** The analogy "Frobenius $=$ conjugation, norm $=$ squared modulus" makes the quadratic-extension case an ideal first encounter with the general philosophy of permutation-polynomial classification via point counting.

---

## 8. Discussion and future directions

What is **proved** is a clean, Weil-free norm criterion for the linearized ($b = 0$) family and for the $q$-even full family, together with the exact exceptional count $p+1$. What remains genuinely open is the honest $b \neq 0$, $q$ odd regime, where a discriminant/Weil-sum obstruction appears. We record three bold, falsifiable conjectures.

**Conjecture 8.1 (general $b$, odd $q$: cubic discriminant criterion).** For odd $q$ and $b \neq 0$, $f(x) = x^{q} + b\,x^{2} + c\,x + d$ permutes $\mathbb{F}_{q^2}$ iff a single explicit polynomial $g(b,c) \in \mathbb{F}_{q^2}[b,c]$ of degree bounded by an absolute constant is non-zero, and $g$ specializes to $c^{q+1} - 1$ (up to a unit) as $b \to 0$. *Rationale:* the difference quotient factors as in Section 6, so non-permutation is governed by the $\mathbb{F}_{q^2}$-points of the affine curve $(x^q - y^q)/(x-y) + b(x+y) + c = 0$; by Weil's bound this count is $q + O(\sqrt q)$, so for large $q$ the criterion degenerates to a single low-degree resultant condition on $(b,c)$. The fully formalized $b = 0$ reduction supplies the exact boundary value $g|_{b=0} = c^{q+1}-1$ that any correct general $g$ must match — a precise, checkable constraint.

**Conjecture 8.2 (bounded defect of the exceptional count).** For every $(b, q)$ the number $M(b)$ of coefficients $c$ making $x^{q} + b\,x^{2} + c\,x$ a non-permutation equals $q + 1$ when $b = 0$ and differs from $q + 1$ by at most $2\sqrt{q}$ for $b \neq 0$. *Rationale:* the proven count pins the $b = 0$ value to exactly $q + 1$, and the Weil bound forces only a $\sqrt q$-size perturbation when the quadratic term is switched on, so the count cannot jump wildly. The exact baseline $p+1$ (Theorem 3.5) turns a vague "about $q$" heuristic into a sharp conjecture with a provable anchor.

**Conjecture 8.3 (norm dichotomy is the only obstruction in characteristic two).** In characteristic $2$, for every $k$, the polynomial $f(x) = x^{2^{k}} + b\,x^{2} + c\,x + d$ over $\mathbb{F}_{2^{2k}}$ permutes iff a norm inequality of the shape $N(\alpha) \neq N(\gamma)$ holds for explicit $\alpha, \gamma$ built from $b, c$ — i.e. the clean criterion survives all of characteristic $2$, never needing a genuine Weil sum. *Rationale:* Theorem 3.8 proves the $k = 1$ case ($\mathbb{F}_4$) via the collapse $b\,x^2 = b\cdot\operatorname{Frob}(x)$; the same additive structure of $x \mapsto x^{2^k}$ suggests the quadratic term stays "linear modulo Frobenius powers" throughout characteristic $2$.

---

## 9. Conclusion

For the linearized Frobenius family $a\,x^{p} + c\,x + d$ over $\mathbb{F}_{p^2}$ — and for the entire quadratic family $x^{2} + b\,x^{2} + c\,x + d$ in characteristic two — being a permutation polynomial is equivalent to a single, instantly checkable inequality between two relative norms, $N(a) \neq N(c)$. The constant term is always irrelevant, and the exceptional coefficients are exactly the $p+1$ roots of unity $\mu_{p+1}$, a vanishing fraction of all coefficients. The viewpoint that recognizes the Frobenius as a conjugation and the norm as a squared magnitude dissolves what could appear to be a hard classification into elementary algebra, while sharply demarcating the genuinely deeper odd-characteristic frontier where Weil sums take over.
