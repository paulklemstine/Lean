# Poisson Summation Characterises Subgroups: A Complete Converse, with Exact Defect and a Rigidity Gap

**Author:** Aristotle
**Date:** 2026-08-19

---

## Abstract

Let $G$ be a finite abelian group and let $\widehat{G}$ denote its character group. For a subgroup $H \leq G$ with annihilator $H^{\perp} = \{\psi \in \widehat{G} : \psi|_H \equiv 1\}$, the finite Poisson summation formula states that
$$|G| \sum_{x \in H} f(x) \;=\; |H| \sum_{\psi \in H^{\perp}} \hat{f}(\psi)$$
for every $f : G \to \mathbb{C}$. The shape of this identity makes sense for an arbitrary subset $S \subseteq G$, since the annihilator $S^{\perp}$ is defined for any $S$; we call $S$ a *Poisson set* when the corresponding identity $(P_S)$ holds for all $f$. We prove the complete converse: $S$ is a Poisson set if and only if $S = \emptyset$ or $S$ is a subgroup, the empty set being a genuine and unique exceptional solution.

We establish four strengthenings. First, *one-test-function rigidity*: if $(P_S)$ holds for the single Dirac delta at one point of $S$, then $S$ is already a subgroup. Second, an *exact defect formula*, expressing the failure of $(P_S)$ at $f$ as the discrepancy between the average of $f$ over $S$ and over the generated subgroup $\langle S \rangle$; the driving structural fact is that $S^{\perp} = \langle S \rangle^{\perp}$, so that $|\langle S \rangle| \cdot |S^{\perp}| = |G|$ for every set $S$. Third, a *gap theorem*: a nonempty non-subgroup admits a Dirac delta with defect of modulus at least $|\langle S \rangle| - |S| \geq 1$, so no approximate theory of Poisson sets exists. Fourth, *constant rigidity*: if any complex constant $c$ makes $|G| \sum_{x \in S} f = c \sum_{\psi \in S^\perp} \hat f$ valid for all $f$ with $S \neq \emptyset$, then $S$ is a subgroup and $c = |S|$.

Consequences include: an affine version characterising cosets via a phase-twisted identity; the identification of Poisson sets with extremals of the Donoho–Stark uncertainty principle; a canonical order isomorphism between the family of nonempty Poisson sets and the subgroup lattice of $G$; the count of exact Poisson formulas on $\mathbb{Z}/n\mathbb{Z}$ as $d(n)$, the number of divisors of $n$; and the observation that the Poisson spectrum separates $\mathbb{Z}/4\mathbb{Z}$ from the Klein four-group, hence is an isomorphism invariant not determined by $|G|$. As an application we show the quadratic residues modulo $n$ are Poisson sets only for $n \in \{1, 2\}$, and that the squares modulo $8$ fail with a defect of modulus at least $5$.

**Keywords:** Poisson summation, finite abelian groups, character annihilator, subgroup lattice, uncertainty principle, rigidity, quadratic residues.

---

## 1. Introduction

### 1.1 Background

The Poisson summation formula occupies an unusual position in analysis: it is simultaneously a computational device, a structural statement about duality, and a bridge between arithmetic and harmonic analysis. In its classical form, for suitable $f : \mathbb{R}^n \to \mathbb{C}$ and a lattice $\Lambda \subseteq \mathbb{R}^n$ with dual lattice $\Lambda^{*}$,
$$\sum_{\lambda \in \Lambda} f(\lambda) \;=\; \frac{1}{\operatorname{covol}(\Lambda)} \sum_{\mu \in \Lambda^{*}} \hat{f}(\mu).$$
It underwrites the sampling theorem, the functional equation of the Jacobi theta function, Ewald summation in computational chemistry, and lattice-point counting in geometry of numbers.

The formula is habitually presented as a *tool*: one is handed a lattice and told what the identity yields. But the identity's statement makes formal sense in far greater generality than its proof requires. In the finite abelian setting — the setting in which every technical difficulty of convergence and decay disappears and only the algebra remains — one may write the identity down for an arbitrary subset. The question of which subsets satisfy it is then well-posed, elementary to state, and, as far as we are aware, not previously settled in the literature.

This paper settles it, and in the strongest form we could formulate.

### 1.2 Setting and notation

Throughout, $G$ is a finite abelian group, written additively, with $|G| = \operatorname{card}(G)$.

**Characters.** A *character* of $G$ is a homomorphism $\psi : G \to \mathbb{C}^{\times}$; since $G$ is finite, every character takes values in the roots of unity, so $|\psi(x)| = 1$ and $\overline{\psi(x)} = \psi(-x) = \psi(x)^{-1}$. The characters form a group $\widehat{G}$ under pointwise multiplication, and $|\widehat{G}| = |G|$.

**Fourier transform.** For $f : G \to \mathbb{C}$,
$$\hat{f}(\psi) \;=\; \sum_{x \in G} \overline{\psi(x)}\, f(x), \qquad \psi \in \widehat{G}.$$
We write $\delta_y$ for the Dirac delta at $y$, so $\delta_y(x) = 1$ if $x = y$ and $0$ otherwise; then $\hat{\delta_y}(\psi) = \overline{\psi(y)}$.

**Annihilators.** For an arbitrary subset $S \subseteq G$,
$$S^{\perp} \;=\; \{\psi \in \widehat{G} : \psi(x) = 1 \text{ for all } x \in S\}.$$
This is always a subgroup of $\widehat{G}$, regardless of whether $S$ is.

**Generated subgroup.** $\langle S \rangle$ denotes the smallest subgroup of $G$ containing $S$; equivalently the set of all finite sums $\sum_i \varepsilon_i s_i$ with $s_i \in S$, $\varepsilon_i \in \{\pm 1\}$, together with $0$.

**Support.** $\operatorname{supp}(f) = \{x : f(x) \neq 0\}$, and $\mathbf{1}_S$ is the indicator of $S$.

### 1.3 The classical direction

We take as our starting point the following, which is the "if" half of the story and is classical.

> **Theorem 1.1 (Poisson summation for subgroups).** Let $H \leq G$ be a subgroup. Then for every $f : G \to \mathbb{C}$,
> $$|G| \sum_{x \in H} f(x) \;=\; |H| \sum_{\psi \in H^{\perp}} \hat{f}(\psi).$$

*Proof sketch.* Expand the right-hand side and interchange summation:
$$|H| \sum_{\psi \in H^{\perp}} \hat{f}(\psi) = |H| \sum_{y \in G} f(y) \sum_{\psi \in H^{\perp}} \overline{\psi(y)} .$$
The inner sum is a character sum over the subgroup $H^{\perp} \leq \widehat{G}$ evaluated at $y$; by orthogonality it equals $|H^{\perp}|$ when $y$ is annihilated by every element of $H^\perp$ — that is, when $y \in H$, by the double-annihilator theorem — and $0$ otherwise. Since $|H| \cdot |H^{\perp}| = |G|$, the right-hand side becomes $|G| \sum_{y \in H} f(y)$. $\square$

We also record the accompanying size identity, which will be generalised in §3:
$$|H| \cdot |H^{\perp}| = |G| \qquad \text{for every subgroup } H \leq G. \tag{1.1}$$

### 1.4 The question, and the answer

> **Definition 1.2 (Poisson set).** A subset $S \subseteq G$ is a **Poisson set** if
> $$|G| \sum_{x \in S} f(x) \;=\; |S| \sum_{\psi \in S^{\perp}} \hat{f}(\psi) \qquad \text{for all } f : G \to \mathbb{C}. \tag{$P_S$}$$

Theorem 1.1 says subgroups are Poisson sets. The empty set is trivially a Poisson set: both sides are $0$, the left because the sum is empty and the right because $|S| = 0$. The content of this paper is that these are all.

> **Theorem A (Classification).** A subset $S \subseteq G$ is a Poisson set if and only if $S = \emptyset$ or $S$ is a subgroup of $G$.

> **Theorem B (One-test-function rigidity).** Let $S \subseteq G$ and let $y_0 \in S$. If $(P_S)$ holds for the single function $f = \delta_{y_0}$, then $S = \langle S \rangle$; in particular $S$ is a subgroup.

> **Theorem C (Exact defect formula).** For $S \subseteq G$ and $f : G \to \mathbb{C}$ define the *Poisson defect*
> $$D_S(f) \;=\; |G| \sum_{x \in S} f(x) \;-\; |S| \sum_{\psi \in S^{\perp}} \hat{f}(\psi).$$
> Then
> $$|\langle S \rangle| \cdot D_S(f) \;=\; |G| \left( |\langle S \rangle| \sum_{x \in S} f(x) \;-\; |S| \sum_{x \in \langle S \rangle} f(x) \right).$$

> **Theorem D (Gap theorem).** If $S$ is nonempty and $S \neq \langle S \rangle$, then there exists $y_0 \in S$ with
> $$\big| D_S(\delta_{y_0}) \big| \;\geq\; |\langle S \rangle| - |S| \;\geq\; 1 .$$

Theorem D is the precise sense in which no approximate theory exists: the defect functional does not take small nonzero values on Dirac data. Theorem B is the sense in which the identity is rigid on contact: the weakest possible test function already forces the full structural conclusion.

### 1.5 Organisation

Section 2 develops the annihilator of an arbitrary set and proves the key blindness lemma $S^{\perp} = \langle S \rangle^{\perp}$. Section 3 derives the fundamental character sum and the general size identity. Section 4 proves Theorems B, A and C, and gives the combinatorial reformulation. Section 5 proves Theorem D and constant rigidity. Section 6 develops the affine (coset) theory. Section 7 links Poisson sets to uncertainty extremality. Section 8 identifies the Poisson spectrum with the subgroup lattice and counts it. Section 9 applies the results to quadratic residues. Section 10 discusses algorithms, and Section 11 open problems.

---

## 2. Annihilators of arbitrary sets

The whole argument rests on one asymmetry: the left-hand side of $(P_S)$ sees $S$ exactly, while the right-hand side sees only $S^{\perp}$ — and $S^{\perp}$ cannot distinguish $S$ from the subgroup it generates.

> **Lemma 2.1 (Blindness of the annihilator).** For every subset $S \subseteq G$,
> $$S^{\perp} \;=\; \langle S \rangle^{\perp}.$$

*Proof.* The inclusion $\langle S \rangle^{\perp} \subseteq S^{\perp}$ is immediate from $S \subseteq \langle S \rangle$. For the converse, fix $\psi \in S^{\perp}$ and consider the set $K = \{y \in G : \psi(y) = 1\} = \ker \psi$. Since $\psi$ is a homomorphism, $K$ is a subgroup: $\psi(0) = 1$; if $\psi(a) = \psi(b) = 1$ then $\psi(a + b) = \psi(a)\psi(b) = 1$; and $\psi(-a) = \psi(a)^{-1} = 1$. By hypothesis $S \subseteq K$, and $\langle S \rangle$ is the smallest subgroup containing $S$, so $\langle S \rangle \subseteq K$, i.e. $\psi \in \langle S \rangle^{\perp}$. $\square$

The proof is three lines, but it is the entire mechanism. Everything downstream is bookkeeping around it.

> **Corollary 2.2.** For every subset $S \subseteq G$,
> $$|\langle S \rangle| \cdot |S^{\perp}| \;=\; |G|.$$

*Proof.* Combine Lemma 2.1 with the subgroup identity (1.1) applied to $H = \langle S \rangle$. $\square$

Corollary 2.2 already explains why $(P_S)$ is so constrained. The right-hand side of $(P_S)$ is, structurally, a formula "about" $\langle S \rangle$; the coefficient $|S|$ in front of it is the only place where $S$ itself enters. If $S$ is a proper subset of $\langle S \rangle$, the coefficient is wrong and there is nothing to compensate.

---

## 3. The fundamental character sum

> **Proposition 3.1.** For every subset $S \subseteq G$ and every $y \in G$,
> $$|\langle S \rangle| \sum_{\psi \in S^{\perp}} \overline{\psi(y)} \;=\; \begin{cases} |G| & \text{if } y \in \langle S \rangle,\\[2pt] 0 & \text{otherwise.}\end{cases}$$

*Proof.* Apply Theorem 1.1 to the subgroup $H = \langle S \rangle$ and the test function $f = \delta_y$. The left-hand side is $|G| \sum_{x \in \langle S \rangle} \delta_y(x) = |G| \cdot \mathbf{1}[y \in \langle S \rangle]$. The right-hand side is $|\langle S \rangle| \sum_{\psi \in \langle S\rangle^{\perp}} \hat{\delta_y}(\psi) = |\langle S \rangle| \sum_{\psi \in \langle S \rangle^{\perp}} \overline{\psi(y)}$. Rewriting $\langle S \rangle^{\perp} = S^{\perp}$ by Lemma 2.1 and equating gives the claim. $\square$

Proposition 3.1 is the analytic content of the entire paper compressed into a single displayed formula: the annihilator character sum is a *sharp indicator* of membership in $\langle S \rangle$, with no reference to $S$ beyond the subgroup it generates.

---

## 4. The converse

### 4.1 One test function suffices

> **Theorem B (restated).** Let $S \subseteq G$, $y_0 \in S$, and suppose
> $$|G| \sum_{x \in S} \delta_{y_0}(x) \;=\; |S| \sum_{\psi \in S^{\perp}} \hat{\delta_{y_0}}(\psi).$$
> Then $S = \langle S \rangle$.

*Proof.* Since $y_0 \in S$, the left-hand side equals $|G| \cdot 1 = |G|$. Since $y_0 \in S \subseteq \langle S \rangle$, Proposition 3.1 gives
$$|\langle S \rangle| \sum_{\psi \in S^{\perp}} \overline{\psi(y_0)} = |G|.$$
Multiply the hypothesis through by $|\langle S \rangle|$ and substitute, using $\hat{\delta_{y_0}}(\psi) = \overline{\psi(y_0)}$:
$$|\langle S \rangle| \cdot |G| \;=\; |S| \cdot \Big( |\langle S \rangle| \sum_{\psi \in S^{\perp}} \overline{\psi(y_0)} \Big) \;=\; |S| \cdot |G| .$$
As $|G| \neq 0$, we get $|\langle S \rangle| = |S|$. Since $S \subseteq \langle S \rangle$ and the two finite sets have equal cardinality, $S = \langle S \rangle$. $\square$

Note what the proof does *not* use: no orthogonality beyond Theorem 1.1, no structure theorem, no Pontryagin duality beyond what is already packaged in Theorem 1.1, and no properties of $S$ other than nonemptiness.

### 4.2 Classification

> **Theorem 4.1.** For nonempty $S \subseteq G$, the following are equivalent:
> 1. $S$ is a Poisson set;
> 2. $(P_S)$ holds for $f = \delta_{y_0}$ for some $y_0 \in S$;
> 3. $S$ is a subgroup of $G$;
> 4. $0 \in S$ and $x - y \in S$ whenever $x, y \in S$.

*Proof.* (1) $\Rightarrow$ (2) is trivial (pick any $y_0 \in S$, which exists by nonemptiness). (2) $\Rightarrow$ (3) is Theorem B, since $\langle S \rangle$ is a subgroup. (3) $\Rightarrow$ (1) is Theorem 1.1. (3) $\Leftrightarrow$ (4) is the standard subgroup criterion for a nonempty subset of an abelian group: closure under subtraction together with $0 \in S$ gives $-y = 0 - y \in S$ and hence $x + y = x - (-y) \in S$. $\square$

> **Theorem A (restated and proved).** $S \subseteq G$ is a Poisson set iff $S = \emptyset$ or $S$ is a subgroup.

*Proof.* If $S = \emptyset$, both sides of $(P_S)$ vanish, since $\sum_{x \in \emptyset} f(x) = 0$ and $|S| = 0$; hence $\emptyset$ is a Poisson set. If $S \neq \emptyset$, apply Theorem 4.1. Conversely subgroups are Poisson sets by Theorem 1.1. $\square$

The empty set genuinely is an exception rather than a degenerate case of "subgroup", because every subgroup contains $0$. So the nonemptiness hypothesis in Theorem 4.1 is sharp and cannot be dropped.

Equivalence (1) $\Leftrightarrow$ (4) deserves emphasis on its own:

> **Corollary 4.2 (Decidability).** For any finite abelian $G$ and any $S \subseteq G$, the analytic property $(P_S)$ — a statement quantified over the $|G|$-dimensional space of test functions $f : G \to \mathbb{C}$ — is equivalent to the finite combinatorial condition
> $$S = \emptyset \quad\text{or}\quad \big( 0 \in S \ \text{ and } \ \forall x, y \in S,\; x - y \in S \big),$$
> checkable in $O(|S|^2)$ group operations.

### 4.3 The defect formula

> **Theorem C (restated and proved).** $|\langle S \rangle| \, D_S(f) = |G| \big( |\langle S \rangle| \sum_{x \in S} f(x) - |S| \sum_{x \in \langle S \rangle} f(x) \big)$.

*Proof.* By Theorem 1.1 applied to $H = \langle S \rangle$ and Lemma 2.1,
$$|\langle S \rangle| \sum_{\psi \in S^{\perp}} \hat{f}(\psi) \;=\; |\langle S \rangle| \sum_{\psi \in \langle S \rangle^{\perp}} \hat{f}(\psi) \;=\; |G| \sum_{x \in \langle S \rangle} f(x).$$
Therefore
$$|\langle S \rangle| \cdot |S| \sum_{\psi \in S^{\perp}} \hat{f}(\psi) \;=\; |S| \cdot |G| \sum_{x \in \langle S \rangle} f(x),$$
and multiplying the definition $D_S(f) = |G| \sum_{S} f - |S| \sum_{S^{\perp}} \hat f$ by $|\langle S \rangle|$ and substituting yields the stated identity. $\square$

**Interpretation.** Divide through by $|G| \cdot |S| \cdot |\langle S \rangle|$:
$$\frac{D_S(f)}{|G| \cdot |S|} \;=\; \frac{1}{|S|}\sum_{x \in S} f(x) \;-\; \frac{1}{|\langle S \rangle|}\sum_{x \in \langle S \rangle} f(x).$$
The normalised defect is *exactly* the difference between the mean of $f$ over $S$ and its mean over $\langle S \rangle$. Poisson summation for $S$ therefore asserts precisely that $S$ and $\langle S \rangle$ are indistinguishable as averaging measures — which, for $S \subseteq \langle S \rangle$, forces $S = \langle S \rangle$.

Equivalently: the defect functional $f \mapsto D_S(f)$ is (up to the factor $|G|\cdot|S|$) integration against the signed measure
$$\mu_S \;=\; \frac{1}{|S|} \mathbf{1}_S \;-\; \frac{1}{|\langle S \rangle|} \mathbf{1}_{\langle S \rangle},$$
a measure supported on $\langle S \rangle$ with total mass $0$ and total variation $2\big(1 - |S|/|\langle S \rangle|\big)$.

---

## 5. Quantitative rigidity

### 5.1 The gap theorem

> **Theorem D (restated and proved).** Let $S$ be nonempty with $S \neq \langle S \rangle$. Then there is $y_0 \in S$ with $|D_S(\delta_{y_0})| \geq |\langle S \rangle| - |S| \geq 1$.

*Proof.* Pick any $y_0 \in S$; then $y_0 \in \langle S \rangle$ as well. Both $\sum_{x \in S}\delta_{y_0}(x)$ and $\sum_{x \in \langle S \rangle}\delta_{y_0}(x)$ equal $1$, so Theorem C gives
$$|\langle S \rangle| \cdot D_S(\delta_{y_0}) \;=\; |G| \big( |\langle S \rangle| - |S| \big),$$
a real, nonnegative quantity, since $S \subseteq \langle S \rangle$ and the containment is strict, so $|\langle S \rangle| - |S| \geq 1$. Taking absolute values,
$$\big| D_S(\delta_{y_0}) \big| \;=\; \frac{|G|}{|\langle S \rangle|}\big(|\langle S \rangle| - |S|\big) \;\geq\; |\langle S \rangle| - |S|,$$
because $\langle S \rangle \subseteq G$ forces $|G| / |\langle S \rangle| \geq 1$. $\square$

The proof in fact gives an *exact* value, not merely a bound: for any $y_0 \in S$,
$$D_S(\delta_{y_0}) \;=\; [G : \langle S \rangle] \cdot \big( |\langle S \rangle| - |S| \big), \tag{5.1}$$
where $[G : \langle S \rangle] = |G|/|\langle S \rangle| = |S^\perp|$ is the index. The defect at a delta inside $S$ is a *positive integer*, independent of which point of $S$ is chosen, and it factorises as (index of the generated subgroup) $\times$ (number of missing points).

> **Corollary 5.1 (No approximate Poisson sets).** For any $\varepsilon < 1$, there is no nonempty $S \subseteq G$ which fails to be a subgroup yet satisfies $|D_S(f)| \leq \varepsilon$ for all $f$ with $\|f\|_{\infty} \leq 1$. The Poisson property is not merely rigid but *isolated*: the defect functional has a spectral gap of size $1$ at zero.

### 5.2 Rigidity of the normalising constant

One might hope to save non-subgroups by adjusting the constant. One cannot.

> **Theorem 5.2 (Constant rigidity).** Let $S \subseteq G$ be nonempty and suppose there exists $c \in \mathbb{C}$ with
> $$|G| \sum_{x \in S} f(x) \;=\; c \sum_{\psi \in S^{\perp}} \hat{f}(\psi) \qquad \text{for all } f : G \to \mathbb{C}.$$
> Then $S$ is a subgroup and $c = |S|$.

*Proof sketch.* Two applications of Proposition 3.1.

*Step 1 (the constant is forced to be $|\langle S \rangle|$).* Take $f = \delta_{y_0}$ with $y_0 \in S$. The left side is $|G|$. Multiplying by $|\langle S \rangle|$ and applying Proposition 3.1 at $y_0 \in \langle S \rangle$ turns the right side into $c \cdot |G|$. Cancelling $|G| \neq 0$ gives $c = |\langle S \rangle|$.

*Step 2 ($S$ has no missing points).* Suppose $y \in \langle S \rangle \setminus S$. Take $f = \delta_y$. The left side vanishes, since $y \notin S$. Multiplying by $|\langle S \rangle|$ and applying Proposition 3.1 at $y \in \langle S \rangle$ turns the right side into $c \cdot |G| = |\langle S \rangle| \cdot |G| \neq 0$, a contradiction. Hence $\langle S \rangle \subseteq S$, so $S = \langle S \rangle$ is a subgroup and $c = |\langle S\rangle| = |S|$. $\square$

Thus the constant $|H|$ appearing in Theorem 1.1 is not a normalisation convention: it is the unique constant for which any such identity can hold, and its correctness is equivalent to the subgroup property.

---

## 6. The affine theory: Poisson summation characterises cosets

Subgroups are not translation-invariant, but the two sides of Poisson summation transform predictably under translation.

> **Lemma 6.1 (Translation phase).** For $f : G \to \mathbb{C}$, $x_0 \in G$, $\psi \in \widehat{G}$,
> $$\widehat{f(x_0 + \cdot)}(\psi) \;=\; \psi(x_0)\, \hat{f}(\psi).$$

*Proof.* Substituting $z = x_0 + y$,
$$\sum_{y} \overline{\psi(y)} f(x_0 + y) = \sum_z \overline{\psi(z - x_0)} f(z) = \psi(x_0) \sum_z \overline{\psi(z)} f(z),$$
using $\overline{\psi(z - x_0)} = \overline{\psi(z)}\,\overline{\psi(-x_0)} = \overline{\psi(z)}\,\psi(x_0)$. $\square$

> **Definition 6.2.** For $S \subseteq G$ and a base point $x_0 \in G$, say $S$ is an **affine Poisson set with base point $x_0$** if
> $$|G| \sum_{x \in S} f(x) \;=\; |S| \sum_{\psi \in (S - x_0)^{\perp}} \psi(x_0)\, \hat{f}(\psi) \qquad \text{for all } f. \tag{$P_{S, x_0}$}$$

> **Theorem 6.3.** $(P_{S, x_0})$ holds for $S$ if and only if $(P_T)$ holds for the translate $T = S - x_0$.

*Proof sketch.* Substituting $f \mapsto f(x_0 + \cdot)$ maps $\sum_{y \in T} f(x_0 + y)$ to $\sum_{x \in S} f(x)$, and by Lemma 6.1 converts $\hat{f}(\psi)$ into $\psi(x_0)\hat{f}(\psi)$; the cardinalities agree since translation is a bijection, $|T| = |S|$. The two identities are therefore each other's images under this substitution, which is invertible. $\square$

> **Theorem 6.4 (Coset characterisation).** Let $x_0 \in S$. Then $(P_{S, x_0})$ holds if and only if $S = x_0 + H$ for some subgroup $H \leq G$; that is, iff $S$ is a coset.

*Proof.* By Theorem 6.3, $(P_{S,x_0})$ is $(P_{S - x_0})$. Since $x_0 \in S$, the translate $S - x_0$ contains $0$ and is in particular nonempty, so Theorem 4.1 applies: $(P_{S-x_0})$ holds iff $S - x_0$ is a subgroup $H$, i.e. iff $S = x_0 + H$. $\square$

> **Corollary 6.5.** A set $S$ admits *some* base point in $S$ for which the affine identity holds iff $S$ is a coset of a subgroup.

So the rigidity phenomenon is affine, not merely linear, and the affine Poisson sets are exactly the cosets — the flat subsets of $G$.

**Example.** The squares modulo $8$, $S = \{0, 1, 4\}$, form neither a subgroup nor a coset: were $S = x_0 + H$, then $H = S - x_0$ would be closed under subtraction, but for every choice of $x_0 \in S$ one of $1 - 4 + x_0$ or $4 - 1 + x_0$ escapes $S$ (e.g. for $x_0 = 0$: $4 - 1 = 3 \notin S$). Hence no base point rescues Poisson summation for the quadratic residues mod $8$.

---

## 7. Poisson sets are the uncertainty extremals

Two dual size estimates sandwich $|G|$ for any nonempty $S$.

> **Proposition 7.1 (Lower estimate).** For every $S \subseteq G$: $\;|S| \cdot |S^{\perp}| \leq |G|$.

*Proof.* $|S| \leq |\langle S \rangle|$ and $|\langle S \rangle| \cdot |S^{\perp}| = |G|$ by Corollary 2.2. $\square$

> **Proposition 7.2 (Upper estimate; Donoho–Stark).** For nonempty $S \subseteq G$:
> $$|G| \;\leq\; |S| \cdot \big| \operatorname{supp} \widehat{\mathbf{1}_S} \big| .$$

This is the finite uncertainty principle $|\operatorname{supp} f| \cdot |\operatorname{supp} \hat{f}| \geq |G|$, valid for every $f \neq 0$, applied to $f = \mathbf{1}_S$, whose support is exactly $S$.

Note also that $S^{\perp} \subseteq \operatorname{supp} \widehat{\mathbf{1}_S}$ always, since for $\psi \in S^{\perp}$ one computes $\widehat{\mathbf{1}_S}(\psi) = \sum_{x \in S} \overline{\psi(x)} = |S| \neq 0$. So the two propositions are genuinely dual: they bound $|G|$ from below and above by $|S|$ times the size of, respectively, the smaller and the larger of two nested sets of characters.

> **Theorem 7.3 (Extremality).** For nonempty $S \subseteq G$ the following are equivalent:
> 1. $S$ is a Poisson set;
> 2. $|S| \cdot |S^{\perp}| = |G|$, i.e. Proposition 7.1 is an equality;
> 3. $\operatorname{supp}\widehat{\mathbf{1}_S} = S^{\perp}$, i.e. the Fourier support of $\mathbf{1}_S$ is as small as it could possibly be.

*Proof sketch.* (1) $\Rightarrow$ (2): if $S$ is a subgroup then $\langle S \rangle = S$ and Corollary 2.2 gives the equality. (2) $\Rightarrow$ (1): from $|S| \cdot |S^{\perp}| = |G| = |\langle S \rangle| \cdot |S^{\perp}|$ and $|S^{\perp}| \geq 1$ we cancel to get $|S| = |\langle S \rangle|$, hence $S = \langle S \rangle$. (1) $\Rightarrow$ (3): for a subgroup $H$, $\widehat{\mathbf{1}_H}(\psi) = \sum_{x \in H}\overline{\psi(x)}$ equals $|H|$ if $\psi \in H^{\perp}$ and $0$ otherwise by orthogonality on $H$; so the support is exactly $H^{\perp}$. (3) $\Rightarrow$ (2): substituting (3) into Proposition 7.2 gives $|G| \leq |S| \cdot |S^{\perp}|$, and combining with Proposition 7.1 gives equality. $\square$

This is a satisfying reinterpretation. The uncertainty principle says a function and its transform cannot both be concentrated; Theorem 7.3 identifies the sets whose indicators achieve the theoretical minimum of joint concentration, and they are precisely the subgroups — precisely the Poisson sets.

---

## 8. The Poisson spectrum: structure and counting

Define the **Poisson spectrum** of $G$ to be the family
$$\mathcal{P}(G) \;=\; \{S \subseteq G : S \text{ is a nonempty Poisson set}\},$$
partially ordered by inclusion.

> **Theorem 8.1 (The spectrum is the subgroup lattice).** The map $S \mapsto \langle S \rangle$ is a bijection $\mathcal{P}(G) \to \{\text{subgroups of } G\}$, with inverse $H \mapsto H$. It is an order isomorphism: for $S, T \in \mathcal{P}(G)$, $S \subseteq T$ iff $\langle S \rangle \leq \langle T \rangle$.

*Proof.* By Theorem A, every $S \in \mathcal{P}(G)$ *is* a subgroup, so $\langle S \rangle = S$ and the map is the identity in disguise; well-definedness in the other direction is Theorem 1.1 plus $0 \in H$. Order preservation is then trivial. (More carefully: the order isomorphism statement holds even when comparing an arbitrary $S$ against a Poisson set $T$, since $S \subseteq T$ iff $\langle S \rangle \leq \langle T \rangle = T$.) $\square$

> **Corollary 8.2.** The number of exact Poisson summation formulas available on $G$ equals the number of subgroups of $G$.

> **Proposition 8.3 (Lattice behaviour).** $\mathcal{P}(G)$ is closed under intersection whenever the intersection is nonempty (it always is: $0$ lies in every member), but not under union. In the Klein four-group $\mathbb{Z}/2 \times \mathbb{Z}/2$, both $\{0, (1,0)\}$ and $\{0, (0,1)\}$ are Poisson sets, while $\{0, (1,0), (0,1)\}$ is not — it fails closure under addition, since $(1,0) + (0,1) = (1,1)$ is absent.

Hence $\mathcal{P}(G)$ is a meet-semilattice inside the Boolean algebra of subsets of $G$, but not a sublattice: its join is the generated subgroup, strictly larger than the union in general.

### 8.1 Counting on cyclic groups

> **Theorem 8.4.** For $n \geq 1$, the number of nonempty Poisson sets of $\mathbb{Z}/n\mathbb{Z}$ is $d(n)$, the number of divisors of $n$.

*Proof sketch.* By Corollary 8.2 the count is the number of subgroups of $\mathbb{Z}/n\mathbb{Z}$. That number is $d(n)$, by two facts.

*Uniqueness.* A cyclic group has at most one subgroup of each order: if $|H| = m$, then every $x \in H$ satisfies $m x = 0$, so $H \subseteq \{x : mx = 0\}$; but in a cyclic group the equation $mx = 0$ has at most $m$ solutions, so $|\{x : mx = 0\}| \leq m = |H|$ and the inclusion is an equality. Thus $H$ is determined by $|H|$ alone.

*Existence.* Lagrange forces $|H|$ to divide $n$; conversely for each divisor $d \mid n$ the subgroup generated by $n/d$ has order $\operatorname{ord}(n/d) = n / \gcd(n, n/d) = n/(n/d) = d$.

Hence subgroups correspond bijectively to divisors of $n$. $\square$

> **Example 8.5.** $\mathbb{Z}/12\mathbb{Z}$ supports exactly $d(12) = 6$ exact Poisson summation formulas, one for each of the divisors $1, 2, 3, 4, 6, 12$.

### 8.2 The spectrum is an isomorphism invariant

Explicit exhaustive determination of small spectra (counting the empty set, which is always a Poisson set):

| $G$ | Poisson sets | count |
|---|---|---|
| $\mathbb{Z}/4\mathbb{Z}$ | $\emptyset,\ \{0\},\ \{0,2\},\ \mathbb{Z}/4\mathbb{Z}$ | $4$ |
| $\mathbb{Z}/5\mathbb{Z}$ | $\emptyset,\ \{0\},\ \mathbb{Z}/5\mathbb{Z}$ | $3$ |
| $\mathbb{Z}/6\mathbb{Z}$ | $\emptyset,\ \{0\},\ \{0,3\},\ \{0,2,4\},\ \mathbb{Z}/6\mathbb{Z}$ | $5$ |
| $\mathbb{Z}/8\mathbb{Z}$ | $\emptyset,\ \{0\},\ \{0,4\},\ \{0,2,4,6\},\ \mathbb{Z}/8\mathbb{Z}$ | $5$ |
| $\mathbb{Z}/2 \times \mathbb{Z}/2$ | $\emptyset,\ \{0\},\ \{0,(1,0)\},\ \{0,(0,1)\},\ \{0,(1,1)\},\ G$ | $6$ |

Each row is a complete enumeration over all $2^{|G|}$ subsets, and in each cyclic case the number of *nonempty* entries is $d(n)$: $3 = d(4)$, $2 = d(5)$, $4 = d(6)$, $4 = d(8)$.

> **Theorem 8.6 (Separation).** $|\mathbb{Z}/4\mathbb{Z}| = |\mathbb{Z}/2 \times \mathbb{Z}/2| = 4$, yet the former has $4$ Poisson sets and the latter has $6$.

Consequently the size of the Poisson spectrum is *not* a function of $|G|$: it is a genuine isomorphism invariant. Poisson summation, in this sense, "sees" the isomorphism type of the group, not just its order. Note also that $\{0,1,4\}$ — the squares mod $8$ — is conspicuously absent from the $\mathbb{Z}/8\mathbb{Z}$ row.

---

## 9. Application: quadratic residues

Let $Q_n = \{a^2 : a \in \mathbb{Z}/n\mathbb{Z}\}$ denote the set of squares modulo $n$. These are the residue sets that control the classical parametrisation of Pythagorean triples: an integer congruent to $3 \bmod 4$ is not a sum of two squares, a leg parity argument lives in $\mathbb{Z}/4\mathbb{Z}$, and the finer congruence obstructions live in $\mathbb{Z}/8\mathbb{Z}$.

> **Theorem 9.1.** $Q_n$ is a Poisson set for $n = 1$ and $n = 2$, and fails to be one for $3 \leq n \leq 8$.

*Proof.* For $n = 1, 2$ every residue is a square, so $Q_n = \mathbb{Z}/n\mathbb{Z}$ is the whole group, a subgroup. For the failures, apply Corollary 4.2 and exhibit a pair violating closure under subtraction: $n=3$, $0 - 1 = 2 \notin \{0,1\}$; $n=4$, $0 - 1 = 3 \notin \{0,1\}$; $n = 5$, $1 - 4 = 2 \notin \{0,1,4\}$; $n = 6$, $3 - 4 = 5 \notin \{0,1,3,4\}$; $n = 7$, $1 - 2 = 6 \notin \{0,1,2,4\}$; $n = 8$, $1 - 4 = 5 \notin \{0,1,4\}$. $\square$

The mod-$8$ case is the interesting one, and the gap theorem makes the failure quantitative.

> **Proposition 9.2.** $\langle Q_8 \rangle = \mathbb{Z}/8\mathbb{Z}$.

*Proof.* $1 \in Q_8$ and $1$ generates $\mathbb{Z}/8\mathbb{Z}$. $\square$

> **Theorem 9.3 (Quantitative failure over the quadratic residues mod 8).** There is $y_0 \in Q_8 = \{0,1,4\}$ with
> $$\big| D_{Q_8}(\delta_{y_0}) \big| \;\geq\; 5 .$$

*Proof.* By Theorem D with $S = Q_8$, $\langle S \rangle = \mathbb{Z}/8\mathbb{Z}$: the bound is $|\langle S \rangle| - |S| = 8 - 3 = 5$. (By formula (5.1) the defect is in fact exactly $[G:\langle S\rangle](|\langle S\rangle| - |S|) = 1 \cdot 5 = 5$ for each of the three choices of $y_0$.) $\square$

Since the ambient group has size $8$, an error of $5$ is not a perturbation; it is of the same order as the group itself. There is no sense in which a Poisson-type formula "approximately holds" over the quadratic residues. Combined with Theorem 6.4 and the example in §6, no change of base point helps either: $Q_8$ is not even flat.

---

## 10. Algorithms

The classification converts an analytic quantifier over $\mathbb{C}^{G}$ into finite combinatorics, so all of the following are elementary.

**Algorithm 1 — Poisson set test.** Given $S \subseteq G$: return true if $S = \emptyset$; otherwise return $\big(0 \in S\big) \wedge \big(\forall x, y \in S: x - y \in S\big)$. Cost: $O(|S|^2)$ group operations with $O(1)$ membership tests via a hash set. Correctness: Corollary 4.2. Compare against the naive approach — verifying $(P_S)$ for a spanning set of $|G|$ test functions with $|G|$-term Fourier sums — which costs $O(|G|^3)$ complex operations, or $O(|G|^2 \log|G|)$ with fast transforms.

**Algorithm 2 — Generated subgroup by closure.** Given $S$, compute $\langle S \rangle$ by breadth-first closure: initialise $C = \{0\} \cup S$, repeatedly replace $C$ by $C \cup (C - C)$ until stable. Terminates in at most $\log_2|G|$ rounds, since $|C|$ at least doubles at each non-terminal round (a proper subgroup-generating step at least doubles the size once $C$ is symmetric and contains $0$). Cost: $O(|G|^2)$ worst case.

**Algorithm 3 — Exact defect evaluation.** Given $S$ and $f$, compute the defect in two ways and cross-check: (a) directly, by enumerating characters and forming $|G|\sum_S f - |S| \sum_{S^{\perp}} \hat f$; (b) via Theorem C, as $\frac{|G|}{|\langle S \rangle|}\big(|\langle S \rangle| \sum_S f - |S| \sum_{\langle S \rangle} f\big)$. Route (b) never touches a character and costs $O(|G|)$; route (a) costs $O(|G|^2)$. Their agreement is a numerical certificate of the defect formula.

**Algorithm 4 — Spectrum enumeration.** Enumerate the Poisson spectrum of $G$ by iterating over all $2^{|G|}$ subsets and applying Algorithm 1, or, exponentially faster, by enumerating subgroups directly (e.g. as $\langle T \rangle$ over all small generating sets $T$ and deduplicating). For cyclic $\mathbb{Z}/n\mathbb{Z}$ the answer is available in closed form: the spectrum is $\{\langle n/d \rangle : d \mid n\} \cup \{\emptyset\}$, of size $d(n) + 1$.

---

## 11. Discussion and future directions

### 11.1 What the converse changes

The classical direction presents Poisson summation as a computational identity. The converse recasts it as a *characterisation*, with three consequences of different flavours.

*Logical.* A statement quantified over an infinite-dimensional-looking space of test functions is equivalent to a finite check on $S$; and by Theorem B, to a single evaluation. Verification cost collapses from cubic to quadratic in $|S|$, and the certificate is a single Dirac delta.

*Structural.* The family of Poisson formulas on $G$ is not an amorphous analytic collection but a copy of the subgroup lattice, meet-closed and join-incomplete, and its cardinality distinguishes non-isomorphic groups of equal order.

*Quantitative.* The exact defect formula (Theorem C) and the resulting integrality (5.1) show that the defect at a delta is a positive integer, factoring as index times deficiency. There is no continuum of near-Poisson sets to develop a perturbation theory around.

### 11.2 Future directions

The following program builds on the results above.

**Conjecture 1 (Approximate Poisson sets in the $\ell^1$-averaged sense).** For nonempty $S \subseteq G$ define the normalised defect
$$D(S) \;=\; \sup_{\|f\|_{\infty} \leq 1} \frac{|D_S(f)|}{|G|}.$$
Conjecture: $D(S) = 2\big(1 - |S|/|\langle S \rangle|\big) \cdot \big(\text{something explicitly computable from the pair } (S, \langle S \rangle)\big)$, and in particular $D(S) \geq 1/|\langle S \rangle|$ with equality iff $S$ is a subgroup minus one point.

*The key insight is* that the defect formula already expresses the defect as $|G| \big(|\langle S \rangle| \sum_S f - |S| \sum_{\langle S \rangle} f\big) / |\langle S \rangle|$, i.e. as a *signed measure* supported on $\langle S \rangle$ with mass $|S|$ on $S$ — so the supremum over $\|f\|_{\infty} \leq 1$ is the total variation of that measure, a purely combinatorial quantity.

*Why now?* The exact defect identity is established and the extremal test function is already known to be a Dirac delta; only the total-variation computation is missing, and it is a finite sum.

**Falsifiable:** compute $D(S)$ for all $S \subseteq \mathbb{Z}/8\mathbb{Z}$ by exhaustion and compare with the formula.

**Conjecture 2 (Poisson spectrum determines the group).** For finite abelian $G$, $H$, the multiset of cardinalities $\{|S| : S$ a nonempty Poisson set of $G\}$ determines $G$ up to isomorphism.

*The key insight is* that this multiset is exactly the multiset of subgroup orders, so the conjecture asserts that a finite abelian group is determined by its subgroup-order multiset — false in general for arbitrary groups, but plausible for abelian ones ($\mathbb{Z}/4\mathbb{Z}$ gives $\{1,2,4\}$, the Klein group $\{1,2,2,2,4\}$).

*Why now?* The bijection with the subgroup lattice eliminates the analytic side of the question entirely; what remains is a clean statement about abelian groups that can be attacked through the structure theorem, and refuted or confirmed by exhaustion for all abelian groups of order $\leq 64$.

**Falsifiable:** search for two non-isomorphic abelian groups with equal subgroup-order multisets (e.g. among groups of order $p^4$, $p^5$).

**Conjecture 3 (Weighted / non-flat Poisson sets).** Let $w : G \to \mathbb{C}$ be supported on a nonempty $S$. Suppose that for all $f$,
$$|G| \sum_{x} w(x) f(x) \;=\; c \sum_{\psi \in \operatorname{supp}(\hat w)} \hat w(\psi)\, \hat f(\psi)$$
for some constant $c$. Conjecture: $w$ must be a scalar multiple of a *coset indicator times a character*. This would unify the subgroup classification (Theorem A) and the coset classification (Theorem 6.4) into a single weighted statement, with the character factor accounting for the translation phase of Lemma 6.1.

### 11.3 Further questions

- **Non-abelian analogues.** Replacing characters by irreducible representations and $S^{\perp}$ by the set of representations trivial on $S$, does the analogue of Theorem A hold, with "subgroup" replaced by "normal subgroup" or by "subgroup" simpliciter? Lemma 2.1 survives verbatim (the kernel of a representation is a normal subgroup), which suggests the right statement involves the normal closure.
- **Infinite locally compact groups.** For a closed subgroup of a locally compact abelian group, Poisson summation holds with Haar measures; what is the analogue of Theorem B when "Dirac delta" is replaced by an approximate identity, and does one-test-function rigidity survive?
- **Stability in weaker norms.** Corollary 5.1 rules out approximate Poisson sets for the $\ell^\infty$ test class. What is the correct statement for defect measured against random $f$, or for $f$ drawn from a restricted class such as nonnegative functions?
- **Algorithmic group recovery.** Theorem B gives a one-query test for subgroup-hood of a set accessible only through the oracle $f \mapsto \sum_{x \in S} f(x)$. What is the query complexity of *recovering* $\langle S \rangle$, or of estimating $|\langle S \rangle| - |S|$, from such an oracle?

---

## 12. Summary of results

1. **Blindness lemma.** $S^{\perp} = \langle S \rangle^{\perp}$ for every $S \subseteq G$, hence $|\langle S \rangle| \cdot |S^{\perp}| = |G|$.
2. **Fundamental character sum.** $|\langle S \rangle| \sum_{\psi \in S^{\perp}} \overline{\psi(y)} = |G| \cdot \mathbf{1}[y \in \langle S \rangle]$.
3. **One-test-function rigidity.** $(P_S)$ for a single Dirac delta at a point of $S$ forces $S = \langle S \rangle$.
4. **Classification.** $S$ is a Poisson set iff $S = \emptyset$ or $S$ is a subgroup; equivalently (for nonempty $S$) iff $0 \in S$ and $S$ is closed under subtraction.
5. **Exact defect formula.** $|\langle S \rangle| D_S(f) = |G|\big(|\langle S \rangle|\sum_S f - |S|\sum_{\langle S \rangle} f\big)$; the normalised defect is the difference of averages over $S$ and $\langle S \rangle$.
6. **Gap theorem.** For nonempty non-subgroups, some Dirac delta has defect exactly $[G : \langle S \rangle](|\langle S \rangle| - |S|) \geq 1$: there are no approximate Poisson sets.
7. **Constant rigidity.** No renormalisation rescues a non-subgroup; the constant $|S|$ is forced.
8. **Coset characterisation.** The phase-twisted affine identity holds iff $S$ is a coset.
9. **Uncertainty extremality.** For nonempty $S$: Poisson $\iff$ $|S| |S^{\perp}| = |G|$ $\iff$ $\operatorname{supp}\widehat{\mathbf{1}_S} = S^{\perp}$.
10. **Spectrum.** Nonempty Poisson sets form a copy of the subgroup lattice: meet-closed, not join-closed; of size $d(n)$ on $\mathbb{Z}/n\mathbb{Z}$; and distinguishing $\mathbb{Z}/4\mathbb{Z}$ (four Poisson sets) from the Klein four-group (six).
11. **Quadratic residues.** The squares mod $n$ are Poisson only for $n \in \{1,2\}$; mod $8$ they fail with defect exactly $5$ and are not even a coset.
