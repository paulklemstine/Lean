# Fourier Analysis on Finite Abelian Groups: Duality, Uncertainty, and Sumsets

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

We develop, from first principles and in full generality, the discrete Fourier transform on an arbitrary finite abelian group $G$, viewed as the decomposition of the regular representation into characters. Starting from the two orthogonality relations for characters we prove Fourier inversion, Parseval's identity, the convolution theorem, and the identity $\mathcal{F}^2 = |G| \cdot \mathcal{R}$ where $\mathcal{R}$ is the reflection $f \mapsto f(-\,\cdot\,)$; we show that the transform is precisely the Wedderburn decomposition $\mathbb{C}[G] \cong \mathbb{C}^{\hat G}$ of the group algebra, whence $\mathbb{C}[G]$ is reduced. We prove the Donoho–Stark uncertainty principle $|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \ge |G|$ for every $f \ne 0$, and exhibit an explicit family of extremals: all nonzero multiples of modulated translates of subgroup indicators, $f(x) = c\,\chi(x)\,1_H(x-a)$. Along the way we obtain the subgroup–annihilator duality $|H|\,|H^{\perp}| = |G|$ *from Plancherel's identity* rather than from Pontryagin duality of the quotient, together with a Poisson summation formula $|G|\sum_{x \in H} f(x) = |H| \sum_{\psi \in H^{\perp}} \hat f(\psi)$. Specializing to $G = \mathbb{Z}/n$ recovers the classical DFT matrix $e^{-2\pi i kx/n}$ with all of the above.

We then apply the machinery to additive combinatorics. Writing $r_{A,B}(c)$ for the number of representations $c = a+b$ with $a \in A$, $b \in B$, we prove the Fourier counting formula $|G|\,r_{A,B}(c) = \sum_{\psi} \psi(c)\widehat{1_A}(\psi)\widehat{1_B}(\psi)$ and deduce, via Parseval and Cauchy–Schwarz, that $A + B = G$ whenever $(|G|-|A|)(|G|-|B|) < |A||B|$. We then prove that this analytic hypothesis is *exactly equivalent* to the pigeonhole hypothesis $|A|+|B| > |G|$: Cauchy–Schwarz applied to the full nonprincipal spectrum is tight at, and only at, the pigeonhole threshold. This delimits precisely what cardinality information alone can achieve, and shows that improvements must come from spectral hypotheses. Below the threshold we prove the exact additive-energy identity $|G|\sum_c r_{A,B}(c)^2 = (|A||B|)^2 + E$, with $E = \sum_{\psi \ne 0} |\widehat{1_A}(\psi)|^2|\widehat{1_B}(\psi)|^2$, and the resulting quantitative covering bound $|A+B| \ge |G|(|A||B|)^2 / ((|A||B|)^2 + E)$, which is attained in explicit examples.

**Keywords:** finite abelian group, character, discrete Fourier transform, Pontryagin duality, Plancherel, convolution theorem, Donoho–Stark uncertainty principle, additive energy, sumset, group algebra.

---

## 1. Introduction

Fourier analysis on a finite abelian group is the special case of harmonic analysis in which every technical difficulty of the continuous theory — convergence, measurability, integrability, distributions — evaporates, leaving only the algebra. Sums are finite, all functions are integrable, all series converge, and the transform is a linear isomorphism between two finite-dimensional spaces of the same dimension. What survives is exactly the conceptual content: *translation-invariant operations are diagonalized by characters.*

This paper is a self-contained development of that theory, pursued far enough to reach two nontrivial destinations.

The first is the **Donoho–Stark uncertainty principle**: for $f \ne 0$ on a finite abelian group $G$,
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \ \ge\ |G|.$$
Unlike its continuous cousin, this is a purely combinatorial inequality with no constants; it is sharp, and its equality cases have a rigid algebraic structure that we determine in part.

The second is a **Fourier-analytic sumset theorem**, together with a precise accounting of what the Fourier method buys over elementary counting. We prove that Cauchy–Schwarz applied to the full nonprincipal spectrum reproduces the pigeonhole threshold $|A|+|B|>|G|$ *exactly* — neither more nor less — and we identify the exact identity (an additive-energy formula) that must be used instead if one wants information below that threshold.

Throughout, $G$ denotes a finite abelian group written additively, $|G|$ its order, and all functions take values in $\mathbb{C}$. The conjugate of $z$ is written $\bar z$.

---

## 2. Characters and the dual group

**Definition 2.1 (Character).** A *character* of $G$ is a map $\psi : G \to \mathbb{C}^{\times}$ with $\psi(x+y) = \psi(x)\psi(y)$ for all $x,y \in G$. The set of characters, with pointwise multiplication, is a group $\hat G$, the *dual group* (or Pontryagin dual) of $G$. We write its identity — the trivial character $x \mapsto 1$ — as $0$, and use additive notation in $\hat G$, so that $(\psi - \chi)(x) = \psi(x)\overline{\chi(x)}$.

Since $G$ is finite, $|G| \cdot x = 0$ for every $x$, hence $\psi(x)^{|G|} = 1$ and
$$|\psi(x)| = 1, \qquad \overline{\psi(x)} = \psi(x)^{-1} = \psi(-x) \qquad (x \in G,\ \psi \in \hat G). \tag{2.1}$$

**Theorem 2.2 (Orthogonality).** For all $x,y \in G$ and all $\psi, \chi \in \hat G$:
$$\text{(dual form)}\qquad \sum_{\psi \in \hat G} \psi(x)\,\overline{\psi(y)} \;=\; \begin{cases}|G|, & x = y,\\ 0, & x \ne y;\end{cases}$$
$$\text{(primal form)}\qquad \sum_{x \in G} \psi(x)\,\overline{\chi(x)} \;=\; \begin{cases}|G|, & \psi = \chi,\\ 0, & \psi \ne \chi.\end{cases}$$

*Proof sketch.* By $(2.1)$, $\psi(x)\overline{\psi(y)} = \psi(x-y)$, so the dual form reduces to the statement that $\sum_{\psi} \psi(z)$ equals $|G|$ if $z = 0$ and $0$ otherwise; likewise $\psi(x)\overline{\chi(x)} = (\psi-\chi)(x)$ reduces the primal form to $\sum_x \eta(x) = |G|\,[\eta = 0]$. Both special cases follow from the translation trick: if $\eta \ne 0$, pick $x_0$ with $\eta(x_0) \ne 1$; then $\eta(x_0)\sum_x \eta(x) = \sum_x \eta(x_0 + x) = \sum_x \eta(x)$, so $(\eta(x_0)-1)\sum_x \eta(x)=0$ and the sum vanishes. Dually for characters. $\square$

An immediate consequence of the primal form is that the $|\hat G|$ characters are linearly independent as functions on $G$, so $|\hat G| \le |G|$; the inversion theorem below forces equality, $|\hat G| = |G|$.

---

## 3. The transform and its fundamental identities

**Definition 3.1.** For $f : G \to \mathbb{C}$, the *discrete Fourier transform* is $\hat f : \hat G \to \mathbb{C}$,
$$\hat f(\psi) \;=\; \sum_{x \in G} \overline{\psi(x)}\,f(x).$$
The *inverse transform* of $F : \hat G \to \mathbb{C}$ is
$$\check F(x) \;=\; \frac{1}{|G|}\sum_{\psi \in \hat G} \psi(x)\,F(\psi).$$
The *convolution* of $f,g : G \to \mathbb{C}$ is $(f * g)(x) = \sum_{y \in G} f(y)\,g(x-y)$, and the *support* of $f$ is $\operatorname{supp} f = \{x \in G : f(x) \ne 0\}$.

**Theorem 3.2 (Fourier inversion).** For every $f : G \to \mathbb{C}$ and every $x \in G$,
$$f(x) \;=\; \frac{1}{|G|}\sum_{\psi \in \hat G}\psi(x)\,\hat f(\psi).$$

*Proof sketch.* Expand $\hat f$ and exchange the order of summation:
$$\sum_{\psi}\psi(x)\hat f(\psi) = \sum_{y \in G}\Bigl(\sum_{\psi}\psi(x)\overline{\psi(y)}\Bigr) f(y) = |G|\,f(x)$$
by the dual orthogonality relation, which kills every term except $y = x$. $\square$

**Theorem 3.3 (The transform is a linear isomorphism).** The map $\mathcal{F} : f \mapsto \hat f$ is $\mathbb{C}$-linear and bijective from $\{f : G \to \mathbb{C}\}$ to $\{F : \hat G \to \mathbb{C}\}$, with two-sided inverse $F \mapsto \check F$.

*Proof sketch.* Linearity is immediate. Theorem 3.2 says $\widecheck{\mathcal{F}f} = f$, giving injectivity; the dual computation, using the primal orthogonality relation in place of the dual one, gives $\mathcal{F}\check F = F$, hence surjectivity. In particular $|\hat G| = |G|$, since the two function spaces are isomorphic. $\square$

**Theorem 3.4 (Parseval–Plancherel).** For all $f, g : G \to \mathbb{C}$,
$$\sum_{\psi \in \hat G} \hat f(\psi)\,\overline{\hat g(\psi)} \;=\; |G| \sum_{x \in G} f(x)\,\overline{g(x)},$$
and in particular
$$\sum_{\psi \in \hat G} |\hat f(\psi)|^2 \;=\; |G| \sum_{x \in G} |f(x)|^2 .$$

*Proof sketch.* Expand both transforms as double sums over $G \times G$, exchange the order of summation so that the character sum is innermost, and apply the dual orthogonality relation, which collapses the double sum to the diagonal with the factor $|G|$. The norm form is the case $g = f$, using $z\bar z = |z|^2$. $\square$

**Theorem 3.5 (Convolution theorem).** For all $f,g$ and all $\psi \in \hat G$, $\ \widehat{f*g}(\psi) = \hat f(\psi)\,\hat g(\psi)$.

*Proof sketch.* $\widehat{f*g}(\psi) = \sum_x \sum_y \overline{\psi(x)} f(y) g(x-y)$. Substituting $x = z + y$ (a bijection of $G$ for each fixed $y$) and factoring $\overline{\psi(z+y)} = \overline{\psi(z)}\,\overline{\psi(y)}$ splits the double sum into the product $\bigl(\sum_y \overline{\psi(y)}f(y)\bigr)\bigl(\sum_z \overline{\psi(z)}g(z)\bigr)$. $\square$

**Theorem 3.6 (The square of the transform).** Let $\iota : G \to \hat{\hat G}$ be the canonical embedding $\iota(x)(\psi) = \psi(x)$. Then for every $f$ and every $x \in G$,
$$\hat{\hat f}\bigl(\iota(x)\bigr) \;=\; |G| \cdot f(-x).$$

*Proof sketch.* Expanding, $\hat{\hat f}(\iota(x)) = \sum_{\psi}\overline{\psi(x)}\sum_y \overline{\psi(y)} f(y) = \sum_y \bigl(\sum_\psi \overline{\psi(x+y)}\bigr) f(y)$, and the inner character sum equals $|G|$ if $x + y = 0$ and $0$ otherwise. $\square$

Thus $\mathcal{F}^2 = |G|\,\mathcal{R}$ with $\mathcal{R}f = f(-\,\cdot\,)$, and since $\mathcal{R}^2 = \mathrm{id}$, the normalized transform $|G|^{-1/2}\mathcal{F}$ is an operator of order dividing $4$ — the finite counterpart of the classical fact that the Fourier transform on $\mathbb{R}$ has eigenvalues among the fourth roots of unity.

### 3.1 The cyclic case: the classical DFT

**Theorem 3.7.** Let $n \ge 1$ and $G = \mathbb{Z}/n$. For each $k \in \mathbb{Z}/n$ the map
$$\psi_k(x) = e^{2\pi i k x / n}$$
is a character, the assignment $k \mapsto \psi_k$ is a group isomorphism $\mathbb{Z}/n \to \widehat{\mathbb{Z}/n}$, and consequently the abstract transform coincides with the classical DFT
$$\hat f(k) \;=\; \sum_{x \in \mathbb{Z}/n} e^{-2\pi i kx/n} f(x).$$
Under this identification, Theorems 3.2, 3.4, 3.5 read, respectively,
$$f(x) = \frac1n \sum_{k} e^{2\pi i kx/n}\hat f(k), \qquad \sum_k |\hat f(k)|^2 = n \sum_x |f(x)|^2, \qquad \widehat{f*g}(k) = \hat f(k)\hat g(k),$$
and the uncertainty principle of Theorem 5.1 below reads $|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \ge n$.

*Proof sketch.* That each $\psi_k$ is a well-defined character is a direct computation with roots of unity; injectivity of $k \mapsto \psi_k$ follows from $\psi_k(1) = e^{2\pi i k/n}$ determining $k$, and surjectivity from $|\hat G| = |G| = n$. Every abstract statement then transfers by relabelling the index set of the dual along this isomorphism, which changes no sum. $\square$

---

## 4. The transform as the Wedderburn decomposition of $\mathbb{C}[G]$

The group algebra $\mathbb{C}[G]$ is the vector space of functions $G \to \mathbb{C}$ with convolution as product and $\delta_0$ as unit. The following theorem explains structurally why the convolution theorem holds.

**Theorem 4.1 (Wedderburn decomposition, abelian case).** The evaluation map
$$\mathcal{E} : \mathbb{C}[G] \longrightarrow \mathbb{C}^{\hat G}, \qquad \mathcal{E}(a)(\psi) = \sum_{x \in G} a(x)\,\psi(x),$$
is an isomorphism of $\mathbb{C}$-algebras, where $\mathbb{C}^{\hat G}$ carries pointwise multiplication. It is the Fourier transform read at the inverse character: $\mathcal{E}(a)(\psi) = \hat a(-\psi)$.

*Proof sketch.* Multiplicativity is the universal property of the group algebra applied to the monoid homomorphism $x \mapsto (\psi \mapsto \psi(x))$ — equivalently, it is the convolution theorem. The identity $\mathcal{E}(a)(\psi) = \hat a(-\psi)$ follows from $\overline{(-\psi)(x)} = \psi(x)$. Bijectivity is then Theorem 3.3, composed with the bijection $\psi \mapsto -\psi$ of $\hat G$. $\square$

**Corollary 4.2.** $\mathbb{C}[G]$ is reduced: it has no nonzero nilpotent elements.

*Proof sketch.* $\mathbb{C}^{\hat G} \cong \mathbb{C}^{|G|}$ is a finite product of fields, hence reduced; nilpotency is preserved by algebra isomorphisms in both directions. $\square$

In representation-theoretic language: every complex irreducible representation of a finite abelian group is one-dimensional, there are exactly $|G|$ of them, and $\mathbb{C}[G] \cong \prod_{\psi} \mathbb{C}$ is the corresponding decomposition. The Fourier transform *is* that decomposition.

---

## 5. The uncertainty principle

**Theorem 5.1 (Donoho–Stark).** Let $G$ be a finite abelian group and $f : G \to \mathbb{C}$ with $f \ne 0$. Then
$$|\operatorname{supp} f| \cdot |\operatorname{supp} \hat f| \;\ge\; |G|.$$

*Proof.* Put $S = \operatorname{supp} f$, $\hat S = \operatorname{supp}\hat f$, and $M = \max_{x} |f(x)|$, which is positive since $f \ne 0$; fix $m$ with $|f(m)| = M$.

*(i) Fourier coefficients are bounded by $|S|M$.* For any $\psi$, only $x \in S$ contribute to $\hat f(\psi) = \sum_x \overline{\psi(x)}f(x)$, and $|\overline{\psi(x)}| = 1$, so by the triangle inequality
$$|\hat f(\psi)| \;\le\; \sum_{x \in S} |f(x)| \;\le\; |S|\,M.$$

*(ii) Inversion at the maximizer.* Only $\psi \in \hat S$ contribute to the inversion formula, so
$$M = |f(m)| = \frac{1}{|G|}\Bigl|\sum_{\psi \in \hat S}\psi(m)\hat f(\psi)\Bigr| \;\le\; \frac{1}{|G|}\sum_{\psi \in \hat S}|\hat f(\psi)| \;\le\; \frac{|\hat S| \cdot |S| \, M}{|G|}.$$

*(iii)* Multiplying by $|G| > 0$ and cancelling $M > 0$ gives $|G| \le |S|\cdot|\hat S|$. $\square$

The proof uses exactly two inequalities, both triangle inequalities, and both are equalities precisely when the relevant terms are nonnegative multiples of one another. This observation drives the extremal analysis of §6 and the open problems of §9.

**Proposition 5.2 (Sharpness: Dirac deltas).** Let $\delta_a(x) = [x = a]$. Then $\hat{\delta_a}(\psi) = \overline{\psi(a)}$, which is unimodular and hence never zero, so
$$|\operatorname{supp}\delta_a| \cdot |\operatorname{supp}\hat{\delta_a}| = 1 \cdot |G| = |G|.$$

---

## 6. Subgroups, annihilators, and extremals

Throughout this section $H \le G$ is a subgroup, $1_H$ its indicator function, and
$$H^{\perp} = \{\psi \in \hat G : \psi(x) = 1 \text{ for all } x \in H\}$$
its *annihilator* in the dual group.

**Lemma 6.1 (Orthogonality over a subgroup).** For every $\psi \in \hat G$,
$$\sum_{x \in H} \psi(x) \;=\; \begin{cases}|H|, & \psi \in H^{\perp},\\ 0, & \psi \notin H^{\perp}.\end{cases}$$

*Proof sketch.* If $\psi \in H^{\perp}$ every summand is $1$. Otherwise pick $x_0 \in H$ with $\psi(x_0) \ne 1$; translation by $x_0$ permutes $H$, so $\psi(x_0)\sum_{x \in H}\psi(x) = \sum_{x\in H}\psi(x_0+x) = \sum_{x\in H}\psi(x)$, forcing the sum to vanish. $\square$

**Theorem 6.2 (Transform of a subgroup indicator).** $\ \widehat{1_H} = |H| \cdot 1_{H^{\perp}}$. In particular $\operatorname{supp}\widehat{1_H} = H^{\perp}$.

*Proof sketch.* $\widehat{1_H}(\psi) = \sum_{x \in H}\overline{\psi(x)} = \sum_{x \in H}(-\psi)(x)$, and $-\psi \in H^{\perp} \iff \psi \in H^{\perp}$; now apply Lemma 6.1. $\square$

**Theorem 6.3 (Subgroup–annihilator duality, from Plancherel).**
$$|H| \cdot |H^{\perp}| \;=\; |G|.$$

*Proof.* Apply the norm form of Parseval (Theorem 3.4) to $f = 1_H$. The right-hand side is $|G| \sum_x |1_H(x)|^2 = |G|\,|H|$. By Theorem 6.2 the left-hand side is $\sum_{\psi}|\widehat{1_H}(\psi)|^2 = |H^{\perp}|\cdot|H|^2$. Equating and cancelling the factor $|H| > 0$ gives the claim. $\square$

This is the standard duality $|H|\,|H^{\perp}| = |G|$, usually derived from the identification $H^{\perp} \cong \widehat{G/H}$; the proof above uses nothing but Plancherel's identity.

**Corollary 6.4 (Subgroup indicators are extremal).** $|\operatorname{supp} 1_H| \cdot |\operatorname{supp}\widehat{1_H}| = |H|\,|H^{\perp}| = |G|$.

**Theorem 6.5 (Poisson summation).** For every $f : G \to \mathbb{C}$,
$$|G| \sum_{x \in H} f(x) \;=\; |H| \sum_{\psi \in H^{\perp}} \hat f(\psi).$$

*Proof sketch.* Replace each $|G| f(x)$ by $\sum_{\psi}\psi(x)\hat f(\psi)$ (inversion), exchange the order of summation, and evaluate the inner sum $\sum_{x \in H}\psi(x)$ with Lemma 6.1; only $\psi \in H^{\perp}$ survive, each with weight $|H|$. $\square$

### 6.1 Symmetries and the extremal family

**Definition 6.6.** For $a \in G$ and $\chi \in \hat G$ define the *translation* $T_a f(x) = f(x-a)$ and the *modulation* $M_\chi f(x) = \chi(x) f(x)$. Call $f$ *extremal* if $|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f| = |G|$.

**Theorem 6.7 (Translation ↔ modulation).** For all $f$, $a \in G$, $\chi, \psi \in \hat G$:
$$\widehat{T_a f}(\psi) = \overline{\psi(a)}\,\hat f(\psi), \qquad \widehat{M_\chi f}(\psi) = \hat f(\psi - \chi).$$

*Proof sketch.* For the first, substitute $x = y+a$ in the defining sum and factor $\overline{\psi(y+a)} = \overline{\psi(y)}\,\overline{\psi(a)}$. For the second, note $\overline{(\psi-\chi)(x)} = \overline{\psi(x)}\chi(x)$ and read off the definition. $\square$

**Corollary 6.8 (Invariance of extremality).** The set of extremal functions is invariant under $f \mapsto cf$ ($c \ne 0$), $f \mapsto T_a f$, and $f \mapsto M_\chi f$.

*Proof sketch.* Scaling by $c \ne 0$ changes neither support. Translation preserves $|\operatorname{supp} f|$ (it translates the support) and, by Theorem 6.7, leaves $\operatorname{supp}\hat f$ literally unchanged, since $\overline{\psi(a)} \ne 0$. Modulation leaves $\operatorname{supp} f$ unchanged (characters never vanish) and translates $\operatorname{supp}\hat f$ inside $\hat G$. $\square$

**Theorem 6.9 (A family of extremals: modulated cosets).** Let $H \le G$ be a subgroup, $a \in G$, $\chi \in \hat G$, and $c \in \mathbb{C}^\times$. Then
$$f(x) \;=\; c\,\chi(x)\,1_H(x-a)$$
satisfies $|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| = |G|$.

*Proof.* $f = c\,M_\chi T_a 1_H$; combine Corollary 6.4 with Corollary 6.8. $\square$

Concretely, $\operatorname{supp} f = a + H$ is a coset of $H$, $|f|$ is constant on it, and $\operatorname{supp}\hat f = \chi + H^{\perp}$ is a coset of the annihilator. The trade-off $|a+H|\cdot|\chi+H^{\perp}| = |H|\,|H^{\perp}| = |G|$ is exactly Theorem 6.3. In $\mathbb{Z}/12$, for instance, $H = \{0,3,6,9\}$ gives $|H| = 4$, $|H^{\perp}| = 3$; $H = \{0,4,8\}$ gives $3$ and $4$; $H = \{0,6\}$ gives $2$ and $6$.

Whether these are *all* the extremals is discussed in §9.

---

## 7. Sumsets: the Fourier counting method and its exact limit

Fix finite subsets $A, B \subseteq G$ and define the *representation function*
$$r_{A,B}(c) \;=\; \#\{(a,b) \in A\times B : a + b = c\}, \qquad c \in G.$$

**Lemma 7.1.** $r_{A,B} = 1_A * 1_B$, and $\widehat{1_A}(0) = |A|$.

*Proof sketch.* $(1_A * 1_B)(c) = \sum_y 1_A(y)1_B(c-y)$ counts the $y \in A$ with $c - y \in B$, which is exactly the number of representations. The second claim is immediate from $\overline{0(x)} = 1$. $\square$

**Theorem 7.2 (Fourier counting formula).** For every $c \in G$,
$$|G| \cdot r_{A,B}(c) \;=\; \sum_{\psi \in \hat G} \psi(c)\,\widehat{1_A}(\psi)\,\widehat{1_B}(\psi) \;=\; |A|\,|B| \;+\; \sum_{\psi \ne 0} \psi(c)\,\widehat{1_A}(\psi)\,\widehat{1_B}(\psi).$$

*Proof.* By Lemma 7.1 and inversion, $r_{A,B}(c) = |G|^{-1}\sum_\psi \psi(c)\widehat{1_A*1_B}(\psi)$, and the convolution theorem replaces $\widehat{1_A*1_B}$ by $\widehat{1_A}\widehat{1_B}$. Splitting off $\psi = 0$ and using $\widehat{1_A}(0)\widehat{1_B}(0) = |A||B|$ gives the second form. $\square$

**Lemma 7.3 (Nonprincipal Parseval mass).** $\displaystyle\sum_{\psi \ne 0} |\widehat{1_A}(\psi)|^2 = |G|\,|A| - |A|^2 = |A|\,(|G| - |A|).$

*Proof.* Parseval for $f = 1_A$ gives $\sum_{\psi}|\widehat{1_A}(\psi)|^2 = |G|\sum_x |1_A(x)|^2 = |G||A|$; subtract the $\psi = 0$ term $|\widehat{1_A}(0)|^2 = |A|^2$. $\square$

**Theorem 7.4 (Cauchy–Schwarz bound on the error).** For every $c \in G$,
$$\Bigl|\sum_{\psi \ne 0}\psi(c)\widehat{1_A}(\psi)\widehat{1_B}(\psi)\Bigr|^2 \;\le\; |A|(|G|-|A|)\cdot|B|(|G|-|B|).$$

*Proof.* By the triangle inequality and $|\psi(c)| = 1$, the left side is at most $\bigl(\sum_{\psi \ne 0} |\widehat{1_A}(\psi)|\,|\widehat{1_B}(\psi)|\bigr)^2$, which by Cauchy–Schwarz is at most $\bigl(\sum_{\psi\ne0}|\widehat{1_A}(\psi)|^2\bigr)\bigl(\sum_{\psi\ne0}|\widehat{1_B}(\psi)|^2\bigr)$. Apply Lemma 7.3 twice. $\square$

**Theorem 7.5 (Fourier-analytic sumset theorem).** If
$$(|G| - |A|)\,(|G| - |B|) \;<\; |A|\,|B|, \tag{7.1}$$
then every $c \in G$ has a representation $c = a + b$ with $a \in A$, $b \in B$; that is, $A + B = G$.

*Proof.* Condition $(7.1)$ forces $|A|,|B| > 0$ (if $|A| = 0$ the left side is $|G|(|G|-|B|) \ge 0$ and the right side is $0$, a contradiction). Multiplying $(7.1)$ by $|A||B| > 0$ and using $|A|(|G|-|A|)\cdot|B|(|G|-|B|) = |A||B| \cdot (|G|-|A|)(|G|-|B|) < (|A||B|)^2$, Theorem 7.4 gives
$$\Bigl|\sum_{\psi \ne 0}\psi(c)\widehat{1_A}(\psi)\widehat{1_B}(\psi)\Bigr| \;<\; |A|\,|B|.$$
By Theorem 7.2, $|G| r_{A,B}(c)$ differs from $|A||B|$ by less than $|A||B|$ in absolute value, hence $|G| r_{A,B}(c) > 0$, hence $r_{A,B}(c) \ge 1$. $\square$

**Theorem 7.6 (The threshold is exactly pigeonhole).** For real $N > 0$ and $a, b \in \mathbb{R}$,
$$(N-a)(N-b) < ab \iff N < a + b.$$
Consequently hypothesis $(7.1)$ is *equivalent* to $|A| + |B| > |G|$.

*Proof.* Expand: $(N-a)(N-b) - ab = N^2 - N(a+b) = N\,(N - a - b)$. Since $N > 0$, this is negative if and only if $N < a+b$. $\square$

**Corollary 7.7 (Pigeonhole).** If $|A| + |B| > |G|$ then $A + B = G$.

Theorem 7.6 is the sharpest statement we can make about the *method*, and it is worth stating plainly.

> **The Fourier/Cauchy–Schwarz argument recovers the pigeonhole threshold exactly, and does not improve on it.**

This is neither a defect of the estimate nor an artefact of a lossy step: expanding the two sides shows that the crude Cauchy–Schwarz bound of Theorem 7.4 becomes competitive with the main term at precisely the point where the elementary counting argument succeeds. The reason is structural. Cauchy–Schwarz uses only the *total* nonprincipal mass $\sum_{\psi\ne0}|\widehat{1_A}(\psi)|^2 = |A|(|G|-|A|)$, and that quantity is determined by $|A|$ alone. Any argument whose only input is the cardinalities $|A|$, $|B|$ is subject to the extremal examples that saturate pigeonhole (cosets of a subgroup, for which the entire nonprincipal mass concentrates on the annihilator). To beat the threshold one must assume more, and the natural assumption is spectral: a bound $\max_{\psi \ne 0}|\widehat{1_A}(\psi)| \le \varepsilon |G|$ (*linear uniformity*, or $\alpha$-pseudorandomness) reduces the error to $\varepsilon |G| \cdot \sqrt{|B|(|G|-|B|)}$ by pulling one factor out of the sum before applying Cauchy–Schwarz, which is far smaller than the crude bound when $A$ is spread out. This is the standard mechanism by which Fourier analysis proves theorems that counting cannot — Roth's theorem being the archetype — and our Theorem 7.6 pinpoints why the cardinality-only version cannot.

---

## 8. Below the threshold: energy and covering

When $(7.1)$ fails, $A + B$ need not be all of $G$, but Plancherel still yields an *exact* identity, and from it a graceful quantitative bound.

**Theorem 8.1 (Additive energy identity).** Let
$$E \;=\; \sum_{\psi \ne 0} |\widehat{1_A}(\psi)|^2\,|\widehat{1_B}(\psi)|^2 \;\ge\; 0 .$$
Then
$$|G| \sum_{c \in G} r_{A,B}(c)^2 \;=\; (|A|\,|B|)^2 + E .$$

*Proof.* Apply the norm form of Parseval to $f = 1_A * 1_B$. On the space side, $\sum_c |(1_A*1_B)(c)|^2 = \sum_c r_{A,B}(c)^2$ by Lemma 7.1. On the dual side, the convolution theorem gives $\sum_\psi |\widehat{1_A}(\psi)|^2|\widehat{1_B}(\psi)|^2$; splitting off $\psi = 0$, whose term is $(|A||B|)^2$, and rearranging yields the identity. $\square$

The left-hand sum $\sum_c r_{A,B}(c)^2$ is the *additive energy* of the pair $(A,B)$: the number of quadruples $(a,b,a',b') \in A\times B\times A\times B$ with $a+b = a'+b'$. Theorem 8.1 says the energy is read off the spectrum with no loss whatsoever.

**Lemma 8.2 (Total mass).** $\displaystyle\sum_{c \in G} r_{A,B}(c) = |A|\,|B|$.

*Proof sketch.* Exchange the order of summation: $\sum_c \sum_{y\in A}[c - y \in B] = \sum_{y \in A}\#\{c : c - y \in B\} = |A|\,|B|$, since $c \mapsto c-y$ is a bijection of $G$. $\square$

**Theorem 8.3 (Quantitative covering bound).** Let $A, B$ be nonempty. Then
$$|A + B| \;=\; \#\{c \in G : r_{A,B}(c) > 0\} \;\ge\; \frac{|G|\,(|A||B|)^2}{(|A||B|)^2 + E}.$$

*Proof.* Let $T = \{c : r_{A,B}(c) > 0\}$. Since $r_{A,B}$ vanishes off $T$, Lemma 8.2 gives $\sum_{c \in T} r_{A,B}(c) = |A||B|$, and Cauchy–Schwarz on $T$ (against the constant function $1$) gives
$$(|A||B|)^2 = \Bigl(\sum_{c\in T} r_{A,B}(c)\Bigr)^2 \le |T| \sum_{c \in T} r_{A,B}(c)^2 = |T| \sum_{c \in G} r_{A,B}(c)^2 .$$
Substituting the exact value of $\sum_c r_{A,B}(c)^2$ from Theorem 8.1 and rearranging (the denominator $(|A||B|)^2 + E$ is positive because $A,B \ne \emptyset$) gives the claim. $\square$

Two features are worth noting. First, the bound is *continuous* in the data: it degrades smoothly as $E$ grows, rather than switching off at a threshold, so it says something for every pair of sets. Second, it is attained. In $G = \mathbb{Z}/12$ with $A = \{0,1,2\}$ and $B = \{0,4,8\}$ we have $|A|+|B| = 6 < 12$, so pigeonhole is silent; but a direct computation gives $r_{A,B} \equiv 1$ on nine elements, so $|G|\sum_c r_{A,B}(c)^2 = 12 \cdot 9 = 108$ while $(|A||B|)^2 = 81$, whence $E = 27$, and the bound reads $|A+B| \ge 12 \cdot 81/108 = 9$, which is exactly $|A+B|$: here $B$ is a subgroup, $A$ is a set of coset representatives, and $r_{A,B} \equiv 1$ on a union of three cosets.

---

## 9. Discussion and open problems

### 9.1 What is proved

The development above is complete and unconditional: orthogonality (Theorem 2.2), inversion and bijectivity (Theorems 3.2, 3.3), Parseval (Theorem 3.4), convolution (Theorem 3.5), the fourth-root-of-identity structure (Theorem 3.6), the classical DFT as a special case (Theorem 3.7), the Wedderburn decomposition and reducedness of $\mathbb{C}[G]$ (Theorem 4.1, Corollary 4.2), the uncertainty principle with sharpness (Theorem 5.1, Proposition 5.2), subgroup duality from Plancherel and Poisson summation (Theorems 6.3, 6.5), the modulated-coset family of extremals (Theorem 6.9), the sumset counting formula and its exact threshold (Theorems 7.2, 7.5, 7.6), and the energy identity and covering bound (Theorems 8.1, 8.3).

### 9.2 Classification of the uncertainty extremals

**Conjecture 9.1.** For $f \ne 0$ on a finite abelian group $G$, equality $|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f| = |G|$ holds *if and only if* there exist a subgroup $H \le G$, an element $a \in G$, a character $\chi$, and $c \ne 0$ with
$$f(x) = c\,\chi(x)\,1_H(x-a).$$

Theorem 6.9 is the "if" direction. The "only if" direction should follow from tracking equality in the proof of Theorem 5.1: equality in step (i) forces $|f|$ to be constant on its support; equality in step (ii) forces the phases $\psi(m)\hat f(\psi)$ to align for all $\psi \in \operatorname{supp}\hat f$, and (after step (i)) forces $\overline{\psi(x)}f(x)$ to be independent of $x \in \operatorname{supp} f$ for each such $\psi$. Phase alignment across a full family of characters is exactly the assertion that the support is a coset of a subgroup. By Corollary 6.8 one may normalize to $f \ge 0$, $0 \in \operatorname{supp} f$, $f(0)=1$, reducing the conjecture to a finite combinatorial statement.

### 9.3 Tao's uncertainty principle for prime order

**Conjecture 9.2.** For $p$ prime and $0 \ne f : \mathbb{Z}/p \to \mathbb{C}$,
$$|\operatorname{supp} f| + |\operatorname{supp}\hat f| \;\ge\; p + 1,$$
and this is sharp for every admissible pair of support sizes.

This is strictly stronger than Theorem 5.1 in the prime case: a hypothetical $f$ with $|\operatorname{supp} f| = |\operatorname{supp}\hat f| = \sqrt p$ would satisfy the product bound and violate the sum bound. The natural route is Chebotarev's theorem: for $p$ prime, every square submatrix of the $p \times p$ DFT matrix $\bigl(e^{-2\pi i kx/p}\bigr)$ is nonsingular. Chebotarev's theorem in turn follows from a resultant/Vandermonde computation in $\mathbb{Q}(\zeta_p)$ using the irreducibility of the $p$-th cyclotomic polynomial. Once available, Conjecture 9.2 is immediate: if $|\operatorname{supp} f| = s$ and $|\operatorname{supp}\hat f| = t$ with $s + t \le p$, then the $t \times s$ submatrix of the transform indexed by the two supports is nonsingular *and* annihilates the nonzero vector $f|_{\operatorname{supp} f}$ on its complement, a contradiction. The failure of the statement for composite $p$ is explained by Theorem 6.9: a proper subgroup $H$ has $|H| + |H^{\perp}| \le |G|$ whenever $|H| \notin \{1, |G|\}$ and $|G|$ is composite, and such $H$ exist precisely then.

### 9.4 Quantitative stability

**Conjecture 9.3.** There is an absolute constant $\kappa > 0$ such that for every finite abelian $G$ and every $0 \ne f : G \to \mathbb{C}$,
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \;\ge\; |G|\,\bigl(1 + \kappa\,\delta(f)\bigr),$$
where
$$\delta(f) \;=\; 1 - \frac{\|f\|_2^2}{\max_x|f(x)|^2 \cdot |\operatorname{supp} f|} \in [0,1)$$
measures the deviation of $|f|$ from being constant on its support, so that $\delta(f) = 0$ exactly for the conjectural extremals of Conjecture 9.1.

The only lossy step in the proof of Theorem 5.1 is the pointwise bound $|f(x)| \le M$ in step (i); a function whose modulus is far from constant on its support loses a definite amount there, and the conjecture asserts that this loss can be quantified uniformly.

### 9.5 Beyond cardinality: spectral hypotheses in sumset theory

Theorem 7.6 shows that cardinality-only hypotheses cannot beat pigeonhole with this method. The natural next step is to develop the same counting formula (Theorem 7.2) under a *linear uniformity* hypothesis $\max_{\psi\ne0}|\widehat{1_A}(\psi)| \le \varepsilon |G|$, giving $A + B = G$ under a condition of the shape $\varepsilon |G| \sqrt{|B|(|G|-|B|)} < |A||B|$, which is far weaker than $|A|+|B|>|G|$ when $A$ is a pseudorandom set of density bounded away from $0$. Combining this with the energy identity (Theorem 8.1) should yield a Balog–Szemerédi-type statement: bounded additive energy forces the covering bound of Theorem 8.3 to be near-optimal.

### 9.6 Non-abelian generalizations

For non-abelian $G$ the characters are replaced by irreducible representations of dimension $d_\rho > 1$, and $\mathbb{C}[G] \cong \bigoplus_\rho M_{d_\rho}(\mathbb{C})$. Inversion, Plancherel and the convolution theorem survive with matrix-valued transforms and traces; the uncertainty principle survives in the weaker form $|\operatorname{supp} f| \cdot \operatorname{rank}_{\text{tot}}\hat f \ge |G|$, and the classification of its extremals is entirely open. Reducedness (Corollary 4.2) genuinely fails in the non-abelian case, since matrix algebras have nilpotents — a sharp indication of how much commutativity buys.

---

## 10. Conclusion

The finite abelian theory is small enough to be proved in its entirety from two orthogonality relations, and rich enough to contain the fast Fourier transform, Pontryagin duality, Poisson summation, the Wedderburn decomposition of the group algebra, a sharp uncertainty principle with a rigid extremal family, and the opening moves of additive combinatorics. Two results deserve emphasis. First, the subgroup duality $|H| \cdot |H^{\perp}| = |G|$ falls directly out of Plancherel's identity applied to a subgroup indicator, with no appeal to quotient groups — a reminder that duality and energy conservation are the same statement in different clothes. Second, the exact equivalence $(|G|-|A|)(|G|-|B|) < |A||B| \iff |A|+|B| > |G|$ shows that the Fourier/Cauchy–Schwarz route to sumset covering is neither weaker nor stronger than pigeonhole, and thereby identifies precisely where additional (spectral) hypotheses must enter. Negative results of this kind are rare and valuable: they tell you not to look for an improvement where none exists, and where to look instead.
