# Möbius Weights, Local Orders, and a Counting Criterion for Freeness

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

Let $\Lambda$ be an order — a ring that is finitely generated as a module over a complete discrete valuation ring or over $\mathbb{Z}$ — and let $M$ be a $\Lambda$-lattice. Solomon's zeta function $\zeta_M(s) = \sum_N [M:N]^{-s}$, summed over finite-index $\Lambda$-submodules $N \subseteq M$, is controlled by the *quotient-type counting function* $a_M(X) = \#\{N \subseteq M : M/N \cong X\}$, and this in turn by the **Möbius weight**
$$w(M,X) \;=\; \sum_{Y \le X} \mu(Y,X)\,\#\mathrm{Hom}_\Lambda(M,Y) \;=\; \#\mathrm{Surj}_\Lambda(M,X) \;=\; \#\mathrm{Aut}_\Lambda(X)\cdot a_M(X),$$
where $\mu$ is the Möbius function of the lattice of $\Lambda$-submodules of $X$.

We develop the structure theory of these weights over local orders and prove four groups of results.

1. **Locality ascent.** If $R$ is a commutative local ring and $\Lambda$ is a commutative $R$-algebra that is module-finite over $R$, and if $\Lambda$ has a maximal ideal $J$ every element of which has a power in $\mathfrak{m}_R\Lambda$, then $\Lambda$ is local with $\mathfrak{m}_\Lambda = J$. The hypothesis is nilpotence *modulo the base*, not nilpotence; Nakayama's lemma supplies the missing invertibility.

2. **$p$-adic group rings are local.** For $p$ prime and $G$ a finite abelian group of exponent dividing $p^e$, the group ring $\Lambda = \mathbb{Z}_p[G]$ is local, with maximal ideal the preimage of $p\mathbb{Z}_p$ under the augmentation and residue field $\mathbb{F}_p$. Consequently the local Solomon formula applies verbatim to free $\Lambda$-lattices: for every finite $\Lambda$-module $X$ with residual dimension $d = \dim_{\mathbb{F}_p} X/\mathfrak{m}X$,
$$\#\mathrm{Aut}(X)\cdot\#\{N \le \Lambda^n : \Lambda^n/N \cong X\} \;=\; \Big(\prod_{i<d}(p^n - p^i)\Big)\cdot|\mathfrak{m}X|^{\,n},$$
even though $\Lambda$ is neither maximal nor a domain.

3. **A Möbius characterisation of freeness.** Over a noetherian commutative local ring $R$ with finite residue field $k$, $q=|k|$, a finitely generated $R$-module $M$ is free of rank $n$ if and only if $w(M,X) = (\prod_{i<d}(q^n-q^i))\cdot|\mathfrak{m}X|^n$ for **every** finite quotient type $X$. The engine is a counting rigidity: composition with a surjection $\pi : R^n \twoheadrightarrow M$ injects $\mathrm{Surj}(M,X)$ into $\mathrm{Surj}(R^n,X)$, so equality of counts forces every surjection $R^n \twoheadrightarrow X$ to annihilate $\ker\pi$; taking $X = R^n/\mathfrak{m}^jR^n$ and applying Krull's intersection theorem yields $\ker\pi = 0$. Two by-products: free lattices *maximise* the Möbius weight among $n$-generated modules, and the family of test spaces cannot be reduced to the single residual space $k^{n+1}$ — over $\mathbb{Z}_p$ the module $\mathbb{F}_p$ passes that test but is not free of rank one. Combining with (2) gives a purely numerical freeness criterion over the non-maximal order $\mathbb{Z}_p[G]$.

4. **Additivity along direct sums.** Hom-counts are multiplicative along finite direct sums, $\#\mathrm{Hom}(\bigoplus_i M_i, Y) = \prod_i \#\mathrm{Hom}(M_i,Y)$; hence the Möbius weight of a decomposable lattice is $\sum_{Y\le X}\mu(Y,X)\prod_i\#\mathrm{Hom}(M_i,Y)$, and more generally the weight depends on $M$ only through the Hom-count function $Y \mapsto \#\mathrm{Hom}(M,Y)$ on the submodule lattice of $X$.

**Keywords:** Solomon zeta function, integral group ring, Möbius function of a lattice, Nakayama's lemma, Hall's formula, Gaussian binomial coefficient, local order, freeness criterion.

---

## 1. Introduction

### 1.1 Counting sublattices

Let $\mathbb{Z}^n$ be the standard lattice. Its finite-index subgroups are counted by
$$\zeta_{\mathbb{Z}^n}(s) \;=\; \sum_{[\mathbb{Z}^n:N]<\infty}[\mathbb{Z}^n:N]^{-s} \;=\; \zeta(s)\zeta(s-1)\cdots\zeta(s-n+1),$$
a classical identity which, prime by prime, says that the number of sublattices of $\mathbb{Z}_p^n$ of index $p^k$ is the coefficient of $T^k$ in $\prod_{i=0}^{n-1}(1-p^iT)^{-1}$.

When $\mathbb{Z}$ is replaced by an **order** $\Lambda$ — a ring, typically noncommutative in general, that is a finitely generated $\mathbb{Z}$- or $\mathbb{Z}_p$-module and spans a semisimple algebra over the fraction field — and $\mathbb{Z}^n$ by a $\Lambda$-lattice $M$, the corresponding series
$$\zeta_M(s) \;=\; \sum_{\substack{N \le M \ \Lambda\text{-submodule}\\ [M:N]<\infty}} [M:N]^{-s}$$
is *Solomon's zeta function*. Its local factors are rational in $p^{-s}$, but explicit formulas are rare and the coefficients encode genuine arithmetic of $\Lambda$. The present paper studies these coefficients through the Möbius function of the submodule lattice of the quotient type, and obtains complete answers for free lattices over local orders, together with a converse: the coefficients of a free lattice characterise freeness.

### 1.2 Notation and standing conventions

All rings are associative with $1$; from §2 onwards *commutative* is assumed unless stated otherwise. For a ring $R$ and $R$-modules $M, X$:

* $\mathrm{Hom}(M,X)$ and $\mathrm{Surj}(M,X)$ denote the sets of $R$-linear maps and of surjective $R$-linear maps;
* $\#S$ or $|S|$ is the cardinality of a finite set;
* a *finite quotient type* is a finite $R$-module $X$ that is finitely generated over $R$;
* for $R$ local with maximal ideal $\mathfrak{m}$ and residue field $k = R/\mathfrak{m}$, the *residual quotient* of $X$ is $X/\mathfrak{m}X$, a $k$-vector space, and the *residual dimension* is $d(X) = \dim_k X/\mathfrak{m}X$; by Nakayama, $d(X)$ is the minimal number of generators of $X$;
* $\mathfrak{m}X$ denotes the submodule $\mathfrak{m}\cdot X$;
* $\mathbb{Z}_p$ is the ring of $p$-adic integers, $\mathbb{F}_p = \mathbb{Z}/p$;
* $\mu(Y,Z)$ is the Möbius function of the partially ordered set of $R$-submodules of $X$, defined by $\mu(Y,Y)=1$ and $\mu(Y,Z) = -\sum_{Y \le W < Z}\mu(Y,W)$.

---

## 2. The Möbius weight

### 2.1 Definition and the two basic identities

**Definition 2.1 (Möbius weight).** Let $R$ be a commutative ring, $M$ an $R$-module and $X$ a finite $R$-module. The *Möbius weight of $M$ at $X$* is
$$w(M,X) \;:=\; \sum_{Y \le X}\mu(Y,X)\,\#\mathrm{Hom}_R(M,Y) \;\in\;\mathbb{Z},$$
the sum being over the (finite) lattice of $R$-submodules of $X$.

**Proposition 2.2 (Surjection count).** For every $M$ and every finite $X$,
$$w(M,X) \;=\; \#\mathrm{Surj}_R(M,X).$$

*Proof.* Each homomorphism $M \to Y$ has a well-defined image, so
$\#\mathrm{Hom}(M,Y) = \sum_{Z \le Y}\#\mathrm{Surj}(M,Z)$ for every $Y \le X$. Möbius inversion on the finite lattice of submodules of $X$ inverts this triangular relation, giving the claim. $\square$

**Proposition 2.3 (Orbit identity).** Let $X$ be a finite quotient type. Then
$$\#\mathrm{Aut}_R(X)\cdot\#\{N \le M : M/N \cong X\} \;=\; \#\mathrm{Surj}_R(M,X) \;=\; w(M,X).$$

*Proof.* $\mathrm{Aut}(X)$ acts freely on $\mathrm{Surj}(M,X)$ by post-composition, and two surjections lie in the same orbit if and only if they have the same kernel; orbits therefore correspond bijectively to submodules $N$ with $M/N\cong X$. $\square$

Combining, the Solomon zeta function is recovered from the weights:
$$\zeta_M(s) \;=\; \sum_{[X]}\frac{w(M,X)}{\#\mathrm{Aut}(X)}\,|X|^{-s},$$
the sum over isomorphism classes of finite quotient types. Proposition 2.3 has three immediate structural consequences that we record because they are used throughout: $w(M,X) \ge 0$; $\#\mathrm{Aut}(X)$ divides $w(M,X)$; and $w(M,X) = 0$ if and only if $M$ admits no surjection onto $X$.

**Proposition 2.4 (Vanishing criterion).** For a finite $R$-module $X$ over a local ring, the least $n$ for which $w(R^n, X) \ne 0$ is exactly the minimal number of generators $d(X)$ of $X$.

*Proof sketch.* $w(R^n,X) \neq 0$ iff there is a surjection $R^n \twoheadrightarrow X$ iff $X$ is generated by $n$ elements; by Nakayama this happens iff $n \ge d(X)$. $\square$

### 2.2 Invariance properties

**Proposition 2.5 (Invariance).** $w(M,X)$ depends on $M$ only up to isomorphism and on $X$ only up to isomorphism; more precisely, $\mu(Y,X)$ depends only on the order-isomorphism type of the submodule lattice of $X$, so $w(-,X)$ is an invariant of the pair (Hom-count function of $M$, poset of submodules of $X$).

**Theorem 2.6 (Hom-counts are multiplicative along direct sums).** Let $M_1,\dots,M_m$ be $R$-modules and $Y$ any $R$-module. Then
$$\#\mathrm{Hom}_R\Big(\bigoplus_{i=1}^m M_i,\;Y\Big) \;=\; \prod_{i=1}^{m}\#\mathrm{Hom}_R(M_i,Y).$$

*Proof.* The universal property of the coproduct gives a natural bijection $\mathrm{Hom}(\bigoplus_i M_i, Y) \cong \prod_i \mathrm{Hom}(M_i,Y)$, which is in fact an isomorphism of $R$-modules. $\square$

**Corollary 2.7 (Weight of a direct sum).** For a finite $R$-module $X$,
$$w\Big(\bigoplus_{i=1}^m M_i,\;X\Big) \;=\; \sum_{Y\le X}\mu(Y,X)\prod_{i=1}^m\#\mathrm{Hom}_R(M_i,Y).$$
In particular, for two summands, $w(M_1\oplus M_2, X) = \sum_{Y\le X}\mu(Y,X)\#\mathrm{Hom}(M_1,Y)\#\mathrm{Hom}(M_2,Y)$.

**Theorem 2.8 (The weight sees only the Hom-count function).** If $M$ and $M'$ satisfy $\#\mathrm{Hom}_R(M,Y) = \#\mathrm{Hom}_R(M',Y)$ for every submodule $Y \le X$, then $w(M,X) = w(M',X)$.

*Proof.* Immediate from Definition 2.1: the two sums agree term by term. $\square$

Theorem 2.8 is the structural reason why the Solomon coefficients of a decomposable lattice reduce to data of its indecomposable summands. Over $\Lambda = \mathbb{Z}_p[\mathbb{Z}/p\mathbb{Z}]$, where every $\Lambda$-lattice is a direct sum of copies of the three indecomposables $\mathbb{Z}_p$, $\mathbb{Z}_p[\zeta_p]$ and $\Lambda$, Corollary 2.7 expresses the weight of an arbitrary lattice as a Möbius sum of a product of three Hom-count functions raised to the multiplicities.

---

## 3. Nakayama collapse and Hall's formula

The single computational engine behind every closed formula in this paper is the following elementary but sharp form of Nakayama's lemma, which requires *no* local hypothesis.

**Lemma 3.1 (Nilpotent-ideal Nakayama).** Let $R$ be a commutative ring, $I \subseteq R$ an ideal, $X$ an $R$-module with $I^eX = 0$ for some $e$, and $Y \le X$ a submodule with $Y + IX = X$. Then $Y = X$.

*Proof.* Substituting the hypothesis into itself, $X = Y + IX = Y + I(Y+IX) = Y + I^2X = \cdots = Y + I^eX = Y$. $\square$

**Theorem 3.2 (Hall's formula over $\mathbb{Z}$).** Let $p$ be a prime and $X$ a finite abelian $p$-group of exponent dividing $p^e$, with $d = \dim_{\mathbb{F}_p}X/pX$. Then for every $n \ge 0$,
$$\#\mathrm{Aut}(X)\cdot\#\{N \le \mathbb{Z}^n : \mathbb{Z}^n/N \cong X\} \;=\; \Big(\prod_{i=0}^{d-1}(p^n - p^i)\Big)\cdot|pX|^{\,n}.$$
Equivalently $w(\mathbb{Z}^n, X) = \big(\prod_{i<d}(p^n-p^i)\big)|pX|^n$.

*Proof sketch.* By Proposition 2.3 the left side is $\#\mathrm{Surj}(\mathbb{Z}^n, X)$, i.e. the number of $n$-tuples $(x_1,\dots,x_n) \in X^n$ generating $X$. By Lemma 3.1 with $I=(p)$, a tuple generates $X$ if and only if its image in the $\mathbb{F}_p$-vector space $X/pX$ spans. The reduction map $X^n \to (X/pX)^n$ is surjective with all fibres of size $|pX|^n$, and the number of spanning $n$-tuples in a $d$-dimensional $\mathbb{F}_p$-space is the number of surjections $\mathbb{F}_p^n \twoheadrightarrow \mathbb{F}_p^d$, namely $\prod_{i<d}(p^n-p^i)$ (choose the images of the $d$ dual basis vectors to be linearly independent). Multiplying gives the formula. $\square$

**Remark 3.3 (Dependence only on two invariants).** The right side of Theorem 3.2 depends on the isomorphism type of $X$ only through the pair $(|pX|, d)$. If $X \cong \prod_i \mathbb{Z}/p^{\lambda_i}$ has type the partition $\lambda$, then $d = \#\mathrm{parts}(\lambda)$ and $|pX| = p^{|\lambda|-d}$, so
$$w(\mathbb{Z}^n, X) = p^{\,n(|\lambda|-d)}\prod_{i<d}(p^n-p^i).$$

**Corollary 3.4 (Gaussian binomial evaluation).** For $X = (\mathbb{Z}/p)^d$ elementary abelian, $pX=0$ and $\#\mathrm{Aut}(X)=\#\mathrm{GL}_d(\mathbb{F}_p)=\prod_{i<d}(p^d-p^i)$, whence
$$\#\{N \le \mathbb{Z}^n : \mathbb{Z}^n/N \cong (\mathbb{Z}/p)^d\} \;=\; \frac{\prod_{i<d}(p^n-p^i)}{\prod_{i<d}(p^d-p^i)} \;=\; \binom{n}{d}_p,$$
the Gaussian binomial coefficient, i.e. the number of $d$-codimensional $\mathbb{F}_p$-subspaces of $\mathbb{F}_p^{\,n}$.

The underlying linear-algebra input deserves separate mention because it is what makes the elementary abelian case self-dual: for a $d\times n$ matrix over a field, *the columns span $\mathbb{F}_p^d$ if and only if the rows are linearly independent in $\mathbb{F}_p^n$.* This rank duality converts the spanning count into an independence count.

**Corollary 3.5 (Cyclic quotients and Jordan's totient).** For $X = \mathbb{Z}/m$ (any $m \ge 1$),
$$\varphi(m)\cdot\#\{N \le \mathbb{Z}^n : \mathbb{Z}^n/N \cong \mathbb{Z}/m\} \;=\; \sum_{d\mid m}\mu_{\mathrm{arith}}(d)\Big(\frac{m}{d}\Big)^n \;=\; J_n(m),$$
where $\mu_{\mathrm{arith}}$ is the classical arithmetic Möbius function and $J_n$ is Jordan's totient. In particular, for a prime power, $\varphi(p^e)\cdot\#\{\cdots\} = (p^e)^n - (p^{e-1})^n$.

*Proof sketch.* Multiplicativity in $m$ reduces to prime powers, where Theorem 3.2 with $d=1$ gives $w(\mathbb{Z}^n,\mathbb{Z}/p^e) = (p^n-1)p^{(e-1)n} = (p^e)^n - (p^{e-1})^n$; summing the arithmetic Möbius expression gives the same. The reduction to prime powers is an Euler factorization: for coprime $m_1,m_2$ the submodule lattice of $\mathbb{Z}/m_1m_2$ splits as a product, and the Möbius function of a product of posets is the product of the Möbius functions, so $w(\mathbb{Z}^n, X_1\oplus X_2) = w(\mathbb{Z}^n,X_1)\,w(\mathbb{Z}^n,X_2)$ whenever $|X_1|,|X_2|$ are coprime. $\square$

Corollary 3.5 is the precise sense in which the incidence-algebra Möbius function of the submodule poset is *carried onto* the arithmetic Möbius function by this counting problem.

---

## 4. Local orders: the general formula

Let now $R$ be a commutative local ring with maximal ideal $\mathfrak{m}$ and finite residue field $k$, $q = |k|$.

**Theorem 4.1 (Local Nakayama collapse).** For every finite $R$-module $X$ with $d = \dim_k X/\mathfrak{m}X$ and every $n$,
$$w(R^n, X) \;=\; \sum_{Y\le X}\mu(Y,X)\,\#\mathrm{Hom}_R(R^n,Y) \;=\; \Big(\prod_{i=0}^{d-1}(q^n-q^i)\Big)\cdot|\mathfrak{m}X|^{\,n}.$$
Consequently
$$\#\mathrm{Aut}_R(X)\cdot\#\{N \le R^n : R^n/N \cong X\} \;=\; \Big(\prod_{i<d}(q^n-q^i)\Big)\cdot|\mathfrak{m}X|^{\,n}.$$

*Proof sketch.* Exactly as in Theorem 3.2. By Proposition 2.2, $w(R^n,X) = \#\mathrm{Surj}(R^n,X)$, which is the number of generating $n$-tuples in $X$. Nakayama's lemma (in the local form, or Lemma 3.1 applied to $I = \mathfrak{m}$ if $\mathfrak{m}$ acts nilpotently on the finite module $X$) says a tuple generates iff its residue spans the $d$-dimensional $k$-vector space $X/\mathfrak{m}X$. The fibres of $X^n \to (X/\mathfrak{m}X)^n$ all have size $|\mathfrak{m}X|^n$ and the spanning tuples in $k^d$ number $\prod_{i<d}(q^n-q^i)$. $\square$

**Corollary 4.2 (Two-invariant dependence).** Over a local order, the Solomon coefficient of a free lattice $R^n$ at $X$ depends on $X$ only through the pair $(|\mathfrak{m}X|, \dim_k X/\mathfrak{m}X)$; two quotient types with the same pair contribute identically, whatever their finer structure.

**Corollary 4.3 (The maximal order $\mathbb{Z}_p$).** For $R = \mathbb{Z}_p$, $q = p$, $\mathfrak{m}X = pX$, and Theorem 4.1 recovers Hall's formula over $\mathbb{Z}_p$; since a finite abelian $p$-group is a $\mathbb{Z}_p$-module in a unique way, it is equivalent to Theorem 3.2.

### 4.1 Generating functions

Summing Theorem 4.1 over quotient types of a given length recovers the shape of the classical zeta function. Over $R = \mathbb{Z}_p$, summing $w(\mathbb{Z}_p^n,X)/\#\mathrm{Aut}(X)$ over all $X$ with $|X| = p^k$ yields the coefficient of $T^k$ in $\prod_{i=0}^{n-1}(1-p^iT)^{-1}$; for instance with $p=2$ the coefficient sequences are $1,1,1,1,\dots$ for $n=1$; $1,3,7,15,31,\dots$ for $n=2$; and $1,7,35,155,651,\dots$ for $n=3$. The general expectation, which Theorem 4.1 makes a finite bookkeeping problem, is that over any commutative local order with finite residue field the refined generating function $\sum_X w(R^n,X)T^{\ell(X)}$ is rational with denominator $\prod_{i=0}^{n-1}(1-q^iT)$: each coefficient is a Gaussian-binomial numerator times a power of $|\mathfrak{m}X|$, so the sum is a finite combination of geometric series indexed by $d \le n$.

---

## 5. Locality ascent and $p$-adic group rings

Theorem 4.1 is only useful for orders that one can *prove* to be local. Group rings of $p$-groups over $\mathbb{Z}_p$ are the case of interest for integral representation theory, and the obstruction is that the classical nilpotence criterion does not apply: in $\mathbb{Z}_p[G]$ the element $p$ is a non-unit but is not nilpotent.

### 5.1 Nakayama's unit criterion

**Lemma 5.1 (Unit criterion).** Let $R$ be a commutative local ring with maximal ideal $\mathfrak{m}$ and let $\Lambda$ be a commutative $R$-algebra which is finitely generated as an $R$-module. If $x \in \Lambda$ satisfies
$$x\Lambda + \mathfrak{m}\Lambda \;=\; \Lambda,$$
then $x$ is a unit of $\Lambda$.

*Proof.* The hypothesis says that the $R$-submodule $x\Lambda \le \Lambda$ satisfies $x\Lambda + \mathfrak{m}\cdot\Lambda = \Lambda$. Since $\Lambda$ is a finitely generated $R$-module and $R$ is local, Nakayama's lemma applied to the finitely generated module $\Lambda/x\Lambda$ (which satisfies $\mathfrak{m}\cdot(\Lambda/x\Lambda) = \Lambda/x\Lambda$) gives $\Lambda/x\Lambda = 0$, i.e. $x\Lambda = \Lambda$, i.e. $x$ is a unit. $\square$

**Lemma 5.2 (Geometric series).** With $R,\Lambda$ as above, if $a \in \Lambda$ satisfies $a^N \in \mathfrak{m}\Lambda$ for some $N$, then $1-a$ is a unit of $\Lambda$.

*Proof.* The identity $(1-a)\sum_{i<N}a^i = 1-a^N$ shows $1 \in (1-a)\Lambda + \mathfrak{m}\Lambda$, so $(1-a)\Lambda + \mathfrak{m}\Lambda = \Lambda$ and Lemma 5.1 applies. $\square$

**Theorem 5.3 (Locality ascent).** Let $R$ be a commutative local ring and $\Lambda$ a commutative $R$-algebra that is finitely generated as an $R$-module. Suppose $\Lambda$ possesses a maximal ideal $J$ such that
$$\forall\, a \in J\ \exists\, N \in \mathbb{N} : a^N \in \mathfrak{m}_R\Lambda,$$
i.e. $J/\mathfrak{m}_R\Lambda$ is a nil ideal of $\Lambda/\mathfrak{m}_R\Lambda$. Then $\Lambda$ is a local ring, and $\mathfrak{m}_\Lambda = J$.

*Proof.* It suffices to show that for each $a\in\Lambda$ either $a$ or $1-a$ is a unit. If $a \in J$, Lemma 5.2 makes $1-a$ a unit. If $a \notin J$, maximality of $J$ gives $y \in \Lambda$ and $i \in J$ with $ya = 1 - i$; by Lemma 5.2 the right-hand side is a unit, hence so is $a$ (a factor of a unit in a commutative ring is a unit). Locality follows, and since $J$ is a maximal ideal of a local ring it must equal $\mathfrak{m}_\Lambda$. $\square$

Theorem 5.3 is the exact strengthening required: nilpotence is weakened to nilpotence *modulo the extension of the base maximal ideal*, and module-finiteness enters only through Nakayama.

### 5.2 $\mathbb{Z}_p[G]$ is local

Fix a prime $p$ and a finite abelian group $G$ of exponent dividing $p^e$. Write $\varepsilon : \Lambda = \mathbb{Z}_p[G] \to \mathbb{Z}_p$ for the augmentation $\sum_g c_g g \mapsto \sum_g c_g$, a surjective ring homomorphism.

**Lemma 5.4 (Nilpotence of the augmentation ideal in characteristic $p$).** In $\mathbb{F}_p[G]$, every element $u$ of the augmentation ideal satisfies $u^{p^e} = 0$.

*Proof sketch.* In characteristic $p$ the $p^e$-power map is a ring homomorphism, so for $u = \sum_g c_g g$ one gets $u^{p^e} = \sum_g c_g^{p^e} g^{p^e} = \big(\sum_g c_g\big)\cdot 1 = \varepsilon(u)$, using $g^{p^e}=1$ and $c^{p}=c$ in $\mathbb{F}_p$. If $u$ is in the augmentation ideal, $\varepsilon(u)=0$. $\square$

**Lemma 5.5 (Reduction of coefficients).** Coefficientwise reduction $\mathbb{Z}_p \to \mathbb{F}_p$ induces a surjective ring homomorphism $\rho : \mathbb{Z}_p[G] \to \mathbb{F}_p[G]$ commuting with the augmentations, and $\ker\rho \subseteq p\,\mathbb{Z}_p[G] = \mathfrak{m}_{\mathbb{Z}_p}\Lambda$.

*Proof sketch.* An element of $\ker\rho$ has all coefficients in $p\mathbb{Z}_p$; writing it as a finite sum $\sum_g c_g\cdot g$ with $c_g \in p\mathbb{Z}_p$ exhibits it in $\mathfrak{m}_{\mathbb{Z}_p}\Lambda$. $\square$

**Theorem 5.6 ($p$-adic group rings of abelian $p$-groups are local).** Let $G$ be a finite abelian group of exponent dividing $p^e$. Then $\Lambda = \mathbb{Z}_p[G]$ is a local ring with
$$\mathfrak{m}_\Lambda \;=\; \varepsilon^{-1}(p\mathbb{Z}_p) \;=\; \{\text{augmentation ideal}\} + p\Lambda,\qquad \Lambda/\mathfrak{m}_\Lambda \cong \mathbb{F}_p.$$

*Proof.* Put $J = \varepsilon^{-1}(p\mathbb{Z}_p)$. Since $\varepsilon$ is surjective and $p\mathbb{Z}_p$ is maximal in $\mathbb{Z}_p$, $J$ is a maximal ideal of $\Lambda$ with $\Lambda/J \cong \mathbb{Z}_p/p\mathbb{Z}_p = \mathbb{F}_p$. Let $a \in J$. Then $\rho(a)$ has augmentation $0$ in $\mathbb{F}_p[G]$, so by Lemma 5.4, $\rho(a)^{p^e} = \rho(a^{p^e}) = 0$; by Lemma 5.5, $a^{p^e} \in \mathfrak{m}_{\mathbb{Z}_p}\Lambda$. Since $\Lambda$ is a free $\mathbb{Z}_p$-module of rank $|G|$, hence module-finite, Theorem 5.3 applies with $R = \mathbb{Z}_p$, $N = p^e$, and yields locality with $\mathfrak{m}_\Lambda = J$. $\square$

**Theorem 5.7 (Free Solomon coefficients over $\mathbb{Z}_p[G]$).** Let $G$ be a finite abelian group of exponent dividing $p^e$ and $\Lambda = \mathbb{Z}_p[G]$. For every finite $\Lambda$-module $X$ that is finitely generated over $\Lambda$, with $d = \dim_{\mathbb{F}_p} X/\mathfrak{m}X$, and every $n$,
$$\#\mathrm{Aut}_\Lambda(X)\cdot\#\{N \le \Lambda^n : \Lambda^n/N \cong X\} \;=\; \Big(\prod_{i=0}^{d-1}(p^n-p^i)\Big)\cdot|\mathfrak{m}X|^{\,n}.$$

*Proof.* Theorem 5.6 makes $\Lambda$ local with residue field of size $q = p$; apply Theorem 4.1. $\square$

The case $G = \mathbb{Z}/p\mathbb{Z}$, $\Lambda = \mathbb{Z}_p[\mathbb{Z}/p\mathbb{Z}] \cong \mathbb{Z}_p[x]/(x^p-1)$, is the smallest non-maximal example: $\Lambda$ has zero divisors, since $(x-1)(1+x+\cdots+x^{p-1}) = x^p-1 = 0$, and $\Lambda \otimes \mathbb{Q}_p \cong \mathbb{Q}_p \times \mathbb{Q}_p(\zeta_p)$ is not a field. Nonetheless the free-lattice coefficients are given by exactly the same expression as over the maximal order $\mathbb{Z}_p$.

**Example 5.8.** Take $p=2$ and work in the finite quotient $\Lambda_2 = (\mathbb{Z}/4)[x]/(x^2-1)$ of $\Lambda$, a ring of $16$ elements, with $\mathfrak{m}$ the set of elements whose coefficient sum is even. For $X = \Lambda_2$ we have $d = 1$ and $|\mathfrak{m}X| = 8$, so the theorem predicts $(2^n-1)\cdot 8^n$ surjections $\Lambda^n \twoheadrightarrow X$: namely $8$ for $n=1$ (the units of $\Lambda_2$) and $192$ for $n=2$. Direct enumeration of the $16^n$ tuples confirms both. For $X = \Lambda_2/(x-1) \cong \mathbb{Z}/4$ one has $d=1$, $|\mathfrak{m}X|=2$ and the counts $2$ and $12$; for $X = \mathbb{F}_p$ the residue field, $d=1$, $|\mathfrak{m}X|=1$ and the counts $1$ and $3$.

---

## 6. A Möbius characterisation of freeness

We now prove the converse direction: the numbers of Theorem 4.1 do not merely *hold* for free modules, they *detect* them.

Throughout this section $R$ is a commutative local ring with maximal ideal $\mathfrak{m}$ and finite residue field $k$, $q=|k|$, and $M$ is a finitely generated $R$-module.

**Definition 6.1 (Free weight).** For $n \in \mathbb{N}$ and a finite $R$-module $X$ set
$$\mathrm{fw}_n(X) \;:=\; \Big(\prod_{i=0}^{d-1}(q^n-q^i)\Big)\cdot|\mathfrak{m}X|^{\,n},\qquad d = \dim_k X/\mathfrak{m}X,$$
so that Theorem 4.1 reads $w(R^n,X) = \mathrm{fw}_n(X)$.

### 6.1 The residual test space

**Lemma 6.2.** For every $m$, the $R$-module $k^m$ satisfies $\mathfrak{m}\cdot k^m = 0$ and $\dim_k (k^m/\mathfrak{m}k^m) = m$.

*Proof.* $\mathfrak{m}$ acts as zero on $k = R/\mathfrak{m}$, hence on $k^m$; the residual quotient is $k^m$ itself, of dimension $m$. $\square$

**Lemma 6.3 (Vanishing at $k^{n+1}$).** $\mathrm{fw}_n(k^{\,n+1}) = 0$.

*Proof.* By Lemma 6.2, $d = n+1$, so the product $\prod_{i<n+1}(q^n-q^i)$ contains the factor $i = n$, namely $q^n - q^n = 0$. $\square$

**Lemma 6.4 (Residual dimension bound).** If $w(M,k^{\,n+1}) = 0$ then $\dim_k M/\mathfrak{m}M \le n$; conversely, if $\dim_k M/\mathfrak{m}M > n$ then $M$ surjects onto $k^{\,n+1}$ and hence $w(M,k^{\,n+1}) > 0$.

*Proof sketch.* If $\dim_k M/\mathfrak{m}M > n$, choose a $k$-basis of $M/\mathfrak{m}M$ and project onto $n+1$ of the coordinates; composing with $M \to M/\mathfrak{m}M$ gives an $R$-linear surjection $M \twoheadrightarrow k^{\,n+1}$, so $w(M,k^{\,n+1}) = \#\mathrm{Surj}(M,k^{n+1}) > 0$ by Proposition 2.2. $\square$

**Lemma 6.5 (Existence of a free cover).** If $\dim_k M/\mathfrak{m}M \le n$ then there is a surjection $\pi : R^n \twoheadrightarrow M$.

*Proof sketch.* Lift a $k$-spanning family of $M/\mathfrak{m}M$ of size $\le n$ (padding with zeros) to elements $v_1,\dots,v_n \in M$. By Nakayama, since the $v_i$ span modulo $\mathfrak{m}M$ and $M$ is finitely generated, they generate $M$; the map $R^n \to M$, $e_i \mapsto v_i$, is onto. $\square$

### 6.2 Counting rigidity

**Theorem 6.6 (Free modules maximise the weights).** Let $M$ be generated by at most $n$ elements and let $\pi : R^n \twoheadrightarrow M$ be a surjection. Then for every finite quotient type $X$,
$$w(M,X) \;\le\; w(R^n, X) \;=\; \mathrm{fw}_n(X).$$

*Proof.* The map $g \mapsto g\circ\pi$ sends $\mathrm{Surj}(M,X)$ into $\mathrm{Surj}(R^n,X)$, and it is injective because $\pi$ is surjective (if $g_1\pi = g_2\pi$ then $g_1,g_2$ agree on the image of $\pi$, which is all of $M$). Both sets are finite because $\mathrm{Hom}(R^n,X) \cong X^n$ is finite. Apply Proposition 2.2. $\square$

**Theorem 6.7 (Counting rigidity).** Let $\pi : R^n \twoheadrightarrow M$ be a surjection and let $X$ be a finite $R$-module such that
$$\#\mathrm{Surj}(M,X) \;=\; \#\mathrm{Surj}(R^n,X).$$
Then every surjection $f : R^n \twoheadrightarrow X$ satisfies $\ker\pi \subseteq \ker f$.

*Proof.* The injection $\Phi : g \mapsto g \circ \pi$ of the proof of Theorem 6.6 is an injective map between finite sets of equal cardinality, hence a bijection. Given $f \in \mathrm{Surj}(R^n,X)$ choose $g \in \mathrm{Surj}(M,X)$ with $g\circ\pi = f$. For $x \in \ker\pi$ we get $f(x) = g(\pi(x)) = g(0) = 0$. $\square$

This is the conceptual heart of the section: *a deficiency of $M$ relative to $R^n$ is always visible as a shortfall in the number of surjections onto some finite quotient, and if no shortfall occurs then every finite quotient of $R^n$ already factors through $M$.*

### 6.3 The characterisation

**Lemma 6.8 (Finiteness of the test quotients).** If $I \subseteq R$ is an ideal with $R/I$ finite, then $R^n/IR^n$ is finite (indeed it embeds in $(R/I)^n$, and in fact equals it).

**Lemma 6.9.** If $R$ is noetherian local with finite residue field, then $R/\mathfrak{m}^j$ is finite for every $j$.

*Proof sketch.* The associated graded pieces $\mathfrak{m}^i/\mathfrak{m}^{i+1}$ are finitely generated modules over the finite field $k$, hence finite; $R/\mathfrak{m}^j$ has a finite filtration with these quotients. $\square$

**Theorem 6.10 (Freeness is detected by the Möbius weights).** Let $R$ be a noetherian commutative local ring with finite residue field $k$, $q=|k|$, and let $M$ be a finitely generated $R$-module. Fix $n \ge 0$. Then
$$M \cong R^n \iff \Big(\;w(M,X) = \mathrm{fw}_n(X)\ \text{ for every finite quotient type } X\;\Big).$$

*Proof.* ($\Rightarrow$) is Theorem 4.1 together with the isomorphism-invariance of $w$.

($\Leftarrow$) Assume the weight identity for all $X$.

*Step 1 (generation).* Apply the hypothesis to $X = k^{\,n+1}$. By Lemma 6.3 the right side is $0$, so $w(M,k^{n+1})=0$, and Lemma 6.4 gives $\dim_k M/\mathfrak{m}M \le n$. By Lemma 6.5 there is a surjection $\pi : R^n \twoheadrightarrow M$.

*Step 2 (rigidity on the test quotients).* Fix $j \ge 1$ and set $X_j := R^n/\mathfrak{m}^jR^n$. By Lemmas 6.8 and 6.9, $X_j$ is a finite, finitely generated $R$-module, hence a legitimate test space. By hypothesis and Theorem 4.1,
$$\#\mathrm{Surj}(M,X_j) = w(M,X_j) = \mathrm{fw}_n(X_j) = w(R^n,X_j) = \#\mathrm{Surj}(R^n,X_j).$$
Theorem 6.7 therefore applies. The canonical projection $R^n \twoheadrightarrow X_j$ is a surjection, so $\ker\pi \subseteq \ker(R^n \to X_j) = \mathfrak{m}^jR^n$.

*Step 3 (Krull).* Since $j$ was arbitrary, $\ker\pi \subseteq \bigcap_{j\ge 1}\mathfrak{m}^jR^n = 0$ by the Krull intersection theorem for the noetherian local ring $R$ and the finitely generated module $R^n$. Hence $\pi$ is injective as well as surjective, and $M \cong R^n$. $\square$

**Corollary 6.11 ($p$-adic case).** A finitely generated $\mathbb{Z}_p$-module $M$ is free of rank $n$ if and only if for every finite $\mathbb{Z}_p$-module $X$,
$$\sum_{Y \le X}\mu(Y,X)\,\#\mathrm{Hom}(M,Y) \;=\; \Big(\prod_{i<d}(p^n-p^i)\Big)\cdot|pX|^{\,n},\qquad d = \dim_{\mathbb{F}_p}X/pX.$$

**Corollary 6.12 (Freeness over $\mathbb{Z}_p[G]$).** Let $G$ be a finite abelian group of exponent dividing $p^e$ and $\Lambda = \mathbb{Z}_p[G]$. A finitely generated $\Lambda$-module $M$ is free of rank $n$ if and only if for every finite $\Lambda$-module $X$,
$$\sum_{Y \le X}\mu(Y,X)\,\#\mathrm{Hom}_\Lambda(M,Y) \;=\; \Big(\prod_{i<d}(p^n-p^i)\Big)\cdot|\mathfrak{m}X|^{\,n},\qquad d=\dim_{\mathbb{F}_p}X/\mathfrak{m}X.$$

*Proof.* $\Lambda$ is module-finite over the noetherian ring $\mathbb{Z}_p$, hence noetherian; it is local with residue field $\mathbb{F}_p$ by Theorem 5.6; apply Theorem 6.10. $\square$

Specialised to $\Lambda = \mathbb{Z}_p[\mathbb{Z}/p\mathbb{Z}]$, whose indecomposable lattices are $\mathbb{Z}_p$ (trivial action), $\mathbb{Z}_p[\zeta_p]$ and $\Lambda$ itself, Corollary 6.12 separates the free lattice from the other two indecomposables purely by a table of integers.

### 6.4 Sharpness: one test space is not enough

**Theorem 6.13 (The residual test space alone does not characterise freeness).** Let $R = \mathbb{Z}_p$, $n = 1$, and $M = \mathbb{F}_p$, the residue field regarded as a cyclic $\mathbb{Z}_p$-module. Then
$$w(M, \mathbb{F}_p^{\,2}) \;=\; 0 \;=\; \mathrm{fw}_1(\mathbb{F}_p^{\,2}),$$
yet $M$ is not free of rank $1$.

*Proof.* By Lemma 6.3, $\mathrm{fw}_1(\mathbb{F}_p^2) = 0$. On the other side, a surjection $M \twoheadrightarrow \mathbb{F}_p^2$ would force $p^2 = |\mathbb{F}_p^2| \le |M| = p$, impossible; so $w(M,\mathbb{F}_p^2) = \#\mathrm{Surj}(M,\mathbb{F}_p^2) = 0$. Finally $M$ is finite while $\mathbb{Z}_p$ is infinite, so $M \not\cong \mathbb{Z}_p$. $\square$

**Remark 6.14 (What separates them).** The pair is separated by the test space $X = \mathbb{Z}/p^2$: there $d = 1$, $|pX| = p$, so $\mathrm{fw}_1(X) = (p-1)p = \varphi(p^2) > 0$, while $w(\mathbb{F}_p, \mathbb{Z}/p^2) = 0$ because a module annihilated by $p$ admits no surjection onto one that is not. The correct reading of Theorem 6.13 is therefore: the residual test space $k^{n+1}$ detects the *number of generators* — a one-space invariant — but freeness is not a one-space invariant; the family $\{R^n/\mathfrak{m}^jR^n\}_{j\ge1}$ used in Step 2 of Theorem 6.10 is what does the work.

---

## 7. Algorithms

The theory yields three effective procedures, all implementable by finite enumeration on small objects and by closed formulas in general.

### 7.1 Möbius weight by lattice inversion

**Input:** a finite $R$-module $X$ (as a finite abelian group with $R$-action), a module $M$.
**Output:** $w(M,X)$.

1. Enumerate all submodules of $X$ by saturating generating sets (start from $0$; repeatedly adjoin an element and take the closure).
2. Sort submodules by cardinality and compute $\mu(Y,Z)$ recursively via $\mu(Y,Y)=1$, $\mu(Y,Z) = -\sum_{Y\le W<Z}\mu(Y,W)$.
3. For each $Y$, compute $\#\mathrm{Hom}(M,Y)$ (for $M = R^n$ this is $|Y|^n$; in general enumerate images of a generating set subject to the relations).
4. Return $\sum_Y \mu(Y,X)\#\mathrm{Hom}(M,Y)$.

Complexity is dominated by step 1–2: with $s$ submodules the Möbius table costs $O(s^3)$ comparisons in the worst case; $s$ grows quickly with $|X|$, which is why the closed formulas of §§3–4 matter.

### 7.2 Closed-form free coefficient

**Input:** $q$, $n$, and the invariants $d = \dim_k X/\mathfrak{m}X$ and $|\mathfrak{m}X|$.
**Output:** $w(R^n,X) = \big(\prod_{i<d}(q^n-q^i)\big)|\mathfrak{m}X|^n$, and, after division by $\#\mathrm{Aut}(X)$, the sublattice count.

This runs in $O(d)$ multiplications of big integers — an exponential speed-up over §7.1, which is precisely the content of Theorem 4.1.

### 7.3 Freeness test

**Input:** a finitely generated module $M$ over a noetherian local $R$ with finite residue field; a rank $n$.
**Output:** whether $M \cong R^n$.

1. Compute $d_M = \dim_k M/\mathfrak{m}M$. If $d_M > n$, report *not free of rank $n$* (this is the $X = k^{n+1}$ test).
2. Otherwise choose a surjection $\pi : R^n \twoheadrightarrow M$ lifting a residual basis.
3. For $j = 1,2,3,\dots$ compare $\#\mathrm{Surj}(M, R^n/\mathfrak{m}^jR^n)$ with $\#\mathrm{Surj}(R^n, R^n/\mathfrak{m}^jR^n) = \mathrm{fw}_n(R^n/\mathfrak{m}^jR^n)$. A shortfall at any $j$ certifies non-freeness; agreement at $j$ certifies $\ker\pi \subseteq \mathfrak{m}^jR^n$.
4. If $\ker\pi$ is known to be finitely generated (automatic over noetherian $R$), agreement for $j$ large enough — beyond the Artin–Rees bound for $\ker\pi$ inside $R^n$ — already forces $\ker\pi = 0$.

Step 3 is the algorithmic form of Theorem 6.7, and step 4 is the effective substitute for the Krull intersection argument.

---

## 8. Applications and discussion

**8.1 Zeta functions of orders.** The formulas of §§3–5 give the complete local factor of the Solomon zeta function of a free lattice over any local order with finite residue field: since $w(R^n,X)$ depends only on $(|\mathfrak{m}X|,d)$, the generating function $\sum_X w(R^n,X)T^{\ell(X)}$ is a finite sum of geometric series indexed by $d \le n$, with denominator $\prod_{i<n}(1-q^iT)$ — the same denominator as the classical $\zeta(s)\cdots\zeta(s-n+1)$, but now over rings that are neither Dedekind nor domains.

**8.2 Integral representation theory.** Corollary 6.12 turns a structural question (is a given $\mathbb{Z}_p[G]$-lattice free?) into a counting question, and Theorem 6.6 says free lattices are the extremal objects for this count. For $G = \mathbb{Z}/p$ this distinguishes $\Lambda$ from the other indecomposables $\mathbb{Z}_p$ and $\mathbb{Z}_p[\zeta_p]$ numerically. Combined with Corollary 2.7, the weights of an arbitrary lattice $\bigoplus_i M_i^{a_i}$ are determined by the multiplicities $a_i$ and the Hom-count functions of the indecomposables.

**8.3 Combinatorics.** Corollary 3.4 places Gaussian binomial coefficients and Corollary 3.5 places Jordan's totient inside a single Möbius-theoretic frame: the incidence-algebra $\mu$ of the submodule poset is carried to the arithmetic $\mu$. Both are instances of the same Nakayama collapse.

**8.4 Limits of the method.** Theorem 6.13 shows that the weight family cannot be truncated to a single space, and Corollary 4.2 shows that free-lattice coefficients are blind to all of $X$ beyond the pair $(|\mathfrak{m}X|, d)$ — so the Solomon coefficients of a *free* lattice carry strictly less information than $X$ itself. The interesting arithmetic therefore lives in the non-free lattices, where the Nakayama collapse fails and Corollary 2.7 is the only reduction available.

**8.5 Noncommutativity.** Theorems 5.3 and 5.6 are proved for commutative $\Lambda$; the counting arguments of §§2, 4, 6 use commutativity only for bookkeeping (restriction of scalars, the submodule lattice as an ordered set). One expects the whole picture to hold for a module-finite noncommutative $\Lambda$ over a commutative local ring whose quotient by the extended maximal ideal has nil Jacobson radical — for instance $\mathbb{Z}_p[G]$ with $G$ a non-abelian $p$-group.

---

## 9. Future work

Five directions suggest themselves, in increasing order of difficulty.

1. **Noncommutative group rings.** Extend Theorem 5.6 to non-abelian finite $p$-groups $G$: the augmentation ideal of $\mathbb{F}_p[G]$ is nilpotent for any $p$-group, so the only obstacle is redoing the ascent (Theorem 5.3) with a one-sided Nakayama argument.

2. **Non-free lattices over $\mathbb{Z}_p[\mathbb{Z}/p]$.** Using Corollary 2.7 and the classification of $\Lambda$-lattices into the three indecomposables $\mathbb{Z}_p$, $\mathbb{Z}_p[\zeta_p]$, $\Lambda$, express the weight of an arbitrary lattice as an explicit $\mathbb{Z}$-linear combination of "free-like" weights, and deduce that the Solomon zeta function of any $\Lambda$-lattice is a rational function in $p^{-s}$ whose numerator degree is bounded by the number of indecomposable summands.

3. **Rationality of the refined generating function.** Prove that $\sum_X w(R^n,X)T^{\ell(X)}$, over isomorphism classes of finite quotient types weighted by length, is rational with denominator $\prod_{i<n}(1-q^iT)$, and that its quotient by the maximal-order zeta function has nonnegative integer coefficients. The coefficientwise input (integrality, nonnegativity, divisibility by $\#\mathrm{Aut}$) is available; what remains is the formal-power-series bookkeeping and the finiteness of the set of quotient types of bounded length.

4. **Partition form of Hall's formula.** For $X$ of type $\lambda$, identify $|\mathfrak{m}X| = p^{|\lambda|-d}$ and $d = \#\mathrm{parts}(\lambda)$ intrinsically, turning Theorem 3.2 into the classical statement in terms of partitions, and assemble the global (all primes at once) formula from the coprime Euler factorization of Corollary 3.5.

5. **Effective bounds in the freeness test.** Make step 4 of §7.3 quantitative: find an explicit $j_0(n,R)$ such that agreement of the surjection counts for $j \le j_0$ already implies freeness. Artin–Rees provides such a bound in principle; an explicit one would turn Theorem 6.10 into a terminating decision procedure.

---

## 10. Summary of results

| Result | Statement |
|---|---|
| Möbius weight identity | $w(M,X) = \sum_{Y\le X}\mu(Y,X)\#\mathrm{Hom}(M,Y) = \#\mathrm{Surj}(M,X) = \#\mathrm{Aut}(X)\,a_M(X)$ |
| Direct sums | $\#\mathrm{Hom}(\bigoplus M_i, Y) = \prod \#\mathrm{Hom}(M_i,Y)$; $w$ depends on $M$ only via $Y \mapsto \#\mathrm{Hom}(M,Y)$ |
| Hall's formula | $\#\mathrm{Aut}(X)\,a_{\mathbb{Z}^n}(X) = \big(\prod_{i<d}(p^n-p^i)\big)|pX|^n$ |
| Gaussian binomial | $a_{\mathbb{Z}^n}((\mathbb{Z}/p)^d) = \binom{n}{d}_p$ |
| Cyclic case | $\varphi(m)\,a_{\mathbb{Z}^n}(\mathbb{Z}/m) = J_n(m) = \sum_{d\mid m}\mu(d)(m/d)^n$ |
| Local formula | over local $R$ with $|k|=q$: $w(R^n,X) = \big(\prod_{i<d}(q^n-q^i)\big)|\mathfrak{m}X|^n$ |
| Locality ascent | module-finite $\Lambda/R$ with a maximal $J$ nil mod $\mathfrak{m}_R\Lambda$ $\Rightarrow$ $\Lambda$ local, $\mathfrak{m}_\Lambda=J$ |
| $p$-adic group rings | $\mathbb{Z}_p[G]$ is local with residue field $\mathbb{F}_p$ for $G$ a finite abelian $p$-group |
| Maximality | $w(M,X) \le w(R^n,X)$ for $M$ generated by $n$ elements |
| Freeness criterion | $M \cong R^n \iff w(M,X) = \mathrm{fw}_n(X)$ for all finite quotient types $X$ |
| Sharpness | over $\mathbb{Z}_p$, $M=\mathbb{F}_p$ matches the rank-one free weight at $k^2$ but is not free |
