# Fourier Analysis as a Functor: Pontryagin Duality, Self-Adjointness, and a Kernel-Level Uncertainty Principle

**Author:** Aristotle
**Date:** 2026-08-06

---

## Abstract

We develop harmonic analysis on finite abelian groups as a statement about *structure* rather than about formulas. Working in the category $\mathsf{FinAb}$ of finite abelian groups and group homomorphisms, we realise the Pontryagin dual $G \mapsto \widehat{G} = \operatorname{Hom}(G, \mathbb{C}^\times)$ as a functor and prove that it is an equivalence $\mathsf{FinAb} \simeq \mathsf{FinAb}^{\mathrm{op}}$, with unit the evaluation map into the double dual. The Fourier transform is then not a formula but a *natural isomorphism* between two functors $\mathsf{FinAb} \to \mathsf{Mod}_{\mathbb{C}}$: the group-algebra functor (with pushforward along fibres) and the dual-functions functor (with restriction along dual maps). Naturality is the identity $\widehat{\varphi_* f} = \widehat{f} \circ \widehat{\varphi}$; invertibility is Fourier inversion.

From this platform we obtain: the convolution theorem, Plancherel's identity, the fourth-power identity $\mathcal{F}^4 = |G|^2 \cdot \mathrm{id}$, exactness of duality with the character extension theorem and the annihilator count $|K^{\perp}||K| = |G|$, and Poisson summation. We then prove the Donoho–Stark uncertainty principle $|\operatorname{supp} f|\cdot|\operatorname{supp}\widehat f| \ge |G|$ together with a *complete* classification of its equality case: the extremals are exactly the modulated coset indicators. A corollary invisible from the inequality itself is that equality forces $|\operatorname{supp} f|$ to divide $|G|$, hence strictness whenever it does not. At the opposite extreme we evaluate the quadratic Gauss sum, $\bigl|\sum_x \psi(x^2)\bigr|^2 = N$ for odd $N$ and primitive $\psi$, and deduce that the quadratic phase realises the maximal uncertainty product $N^2$.

The two principal new results are structural. First, a **kernel-level uncertainty principle**: for an arbitrary array $k$ with entries of modulus $\le \mu$, invertible by an array $l$ with entries of modulus $\le \nu$, every non-zero $f$ obeys $1 \le \mu\nu\,|\operatorname{supp} f|\,|\operatorname{supp} Tf|$. No group, character, orthogonality or unitarity is used. Donoho–Stark, the Elad–Bruckstein coherence bound and the mutually-unbiased-bases bound are all instances, and the constant $(\mu\nu)^{-1}$ is optimal because flat kernels send Dirac masses to nowhere-vanishing functions. The relevant invariant is therefore *coherence*, not group order. Second, **Pontryagin duality is a self-adjunction** whose hom-set bijection is exactly the bicharacter swap $\operatorname{Hom}(G,\widehat H) \cong \operatorname{Hom}(H,\widehat G)$, and the Fourier kernel consists of the values of the swap of the identity — a precise sense in which the exponential kernel is not chosen but forced.

We close with a companion bridge theorem of the same flavour in enumerative combinatorics: the logarithmic-derivative form of the Pólya tree functional equation is *equivalent* to the divisor-weighted recurrence $a_k = \frac{1}{k-1}\sum_j a_j\omega_{k-j}$, $\omega_m = \sum_{d\mid m} d\,a_d$, the arithmetic weight being forced by a divisor reflection rather than assumed.

**Keywords:** Pontryagin duality, finite abelian groups, natural transformation, self-adjoint functor, Donoho–Stark uncertainty principle, mutual coherence, Gauss sums, Pólya trees.

---

## 1. Introduction

The Fourier transform on a finite abelian group $G$ is usually introduced as the sum
$$\widehat{f}(\psi) = \sum_{g \in G} f(g)\,\psi(-g), \qquad \psi \in \widehat{G},$$
accompanied by an inversion formula and a list of identities. This presentation obscures the fact that essentially every property in the list is a consequence of two structural facts: that the passage $G \mapsto \widehat G$ is a *functor*, and that this functor is an *equivalence*. The purpose of this paper is to make that reduction explicit and then to push past it.

Three questions organise the development.

1. **What is functorial about the Fourier transform?** We answer: the transform is a natural isomorphism between two functors from $\mathsf{FinAb}$ to complex vector spaces. Its naturality square is the aliasing/periodisation identity, and its invertibility is Fourier inversion (Section 4).
2. **What is the uncertainty principle about?** The classical answer is "the Fourier transform". We show it is not: the principle is a statement about any bounded kernel with a bounded inverse, and the classical constant $|G|$ is the reciprocal of a coherence product (Section 8).
3. **Why the exponential kernel?** We show that the dual functor is self-adjoint, that its hom-set bijection is the bicharacter swap, and that the Fourier kernel is the image of the identity morphism under that bijection (Section 10).

Notation throughout: $G, H$ are finite abelian groups written additively; $\widehat{G} = \operatorname{AddChar}(G,\mathbb{C})$ is the group of characters $\psi \colon G \to \mathbb{C}$ with $\psi(0)=1$ and $\psi(g+h)=\psi(g)\psi(h)$; $|G|$ is the order of $G$; $\operatorname{supp} f = \{g : f(g) \neq 0\}$; and $\mathbb{C}[G]$ denotes the space of all functions $G \to \mathbb{C}$. Characters of a finite abelian group take values in roots of unity, so $|\psi(g)| = 1$ and $\overline{\psi(g)} = \psi(-g)$.

---

## 2. The category $\mathsf{FinAb}$ and the dual functor

**Definition 2.1 (The category).** $\mathsf{FinAb}$ is the category whose objects are finite abelian groups (in a fixed small universe) and whose morphisms are additive group homomorphisms, with the usual composition.

**Definition 2.2 (Dual of a homomorphism).** For $\varphi \colon G \to H$ define
$$\widehat{\varphi} \colon \widehat{H} \to \widehat{G}, \qquad \widehat{\varphi}(\psi) = \psi \circ \varphi .$$
This is a homomorphism of abelian groups, since $(\psi\chi)\circ\varphi = (\psi\circ\varphi)(\chi\circ\varphi)$.

**Proposition 2.3 (Functoriality).** $\widehat{\mathrm{id}_G} = \mathrm{id}_{\widehat G}$ and $\widehat{\psi \circ \varphi} = \widehat{\varphi} \circ \widehat{\psi}$. Hence
$$D \colon \mathsf{FinAb}^{\mathrm{op}} \longrightarrow \mathsf{FinAb}, \qquad D(G) = \widehat{G},\quad D(\varphi) = \widehat{\varphi}$$
is a functor: the **Pontryagin dual functor**.

*Proof sketch.* Both identities hold pointwise on characters and, evaluating further, pointwise on group elements; each is an instance of associativity of composition. $\square$

**Lemma 2.4 (Counting characters).** For every finite abelian group $G$, $|\widehat G| = |G|$.

*Proof sketch.* Reduce to cyclic $G = \mathbb{Z}/N$ by the structure theorem, where characters are exactly $x \mapsto \zeta^{kx}$ for $\zeta$ a primitive $N$-th root of unity and $0 \le k < N$; duality turns finite direct sums into finite direct products. $\square$

---

## 3. Pontryagin duality as an equivalence of categories

**Definition 3.1 (Evaluation).** For $g \in G$, let $\mathrm{ev}_g \in \widehat{\widehat{G}}$ be the character of $\widehat G$ given by $\mathrm{ev}_g(\psi) = \psi(g)$. The map $E_G \colon G \to \widehat{\widehat{G}}$, $g \mapsto \mathrm{ev}_g$, is a group homomorphism.

**Theorem 3.2 (Pontryagin duality).** $E_G$ is an isomorphism for every finite abelian $G$, and the family $(E_G)_G$ is a natural isomorphism $\mathrm{id}_{\mathsf{FinAb}} \Rightarrow D^{\mathrm{op}} \circ D$. Together with the corresponding counit this exhibits an equivalence of categories
$$\mathsf{FinAb} \;\simeq\; \mathsf{FinAb}^{\mathrm{op}} ,$$
whose functor is the dual functor and whose unit is $E$.

*Proof sketch.* Injectivity of $E_G$ is the separation property of characters: if $g \neq 0$ there is a character with $\psi(g) \neq 1$ (immediate for cyclic groups, then extended by the structure theorem). Surjectivity then follows by counting, using Lemma 2.4 twice: $|\widehat{\widehat G}| = |\widehat G| = |G|$. Naturality is the identity $\mathrm{ev}_{\varphi(g)} = \widehat{\widehat{\varphi}}(\mathrm{ev}_g)$, which unwinds to $\psi(\varphi(g)) = (\psi \circ \varphi)(g)$. The triangle identity for the equivalence is verified in the same pointwise way. $\square$

Three consequences record what the equivalence buys.

**Corollary 3.3 (Essential surjectivity).** Every finite abelian group is isomorphic to the character group of a finite abelian group — namely of its own dual.

**Corollary 3.4 (Fullness).** Every homomorphism $u \colon \widehat{H} \to \widehat{G}$ is of the form $u = \widehat{\varphi}$ for a unique $\varphi \colon G \to H$.

**Corollary 3.5 (Double dual of a map).** For $\varphi \colon G \to H$ one has $\widehat{\widehat{\varphi}} = E_H \circ \varphi \circ E_G^{-1}$: duality squares to the identity, up to conjugation by evaluation.

---

## 4. The Fourier transform as a natural isomorphism

We now compare two functors $\mathsf{FinAb} \to \mathsf{Mod}_{\mathbb{C}}$.

**Definition 4.1 (Group-algebra functor).** $\mathcal{A}(G) = \mathbb{C}[G]$, and for $\varphi \colon G \to H$ the **pushforward**
$$(\varphi_* f)(h) = \sum_{g \,:\, \varphi(g) = h} f(g).$$
Functoriality, $(\mathrm{id})_* = \mathrm{id}$ and $(\psi\varphi)_* = \psi_*\varphi_*$, is fibrewise regrouping of a finite sum.

**Definition 4.2 (Dual-functions functor).** $\mathcal{B}(G) = \mathbb{C}[\widehat G]$, and for $\varphi \colon G \to H$ the map $\mathcal{B}(\varphi) \colon F \mapsto F \circ \widehat{\varphi}$, precomposition with the dual homomorphism. Functoriality is Proposition 2.3.

**Definition 4.3 (Fourier transform and its inverse).** For $f \in \mathbb{C}[G]$ and $F \in \mathbb{C}[\widehat G]$,
$$\mathcal{F}_G(f)(\psi) = \widehat{f}(\psi) = \sum_{g \in G} f(g)\,\psi(-g), \qquad \mathcal{F}^{-1}_G(F)(g) = \frac{1}{|G|}\sum_{\psi \in \widehat G} F(\psi)\,\psi(g).$$
Both are $\mathbb{C}$-linear.

**Lemma 4.4 (Orthogonality).** For $x \in G$, $\ \sum_{\psi \in \widehat G} \psi(x) = |G|\,[x=0]$, and for $\psi \in \widehat G$, $\ \sum_{g \in G}\psi(g) = |G|\,[\psi = 1]$.

*Proof sketch.* If $x \neq 0$, pick $\chi$ with $\chi(x) \neq 1$; the substitution $\psi \mapsto \chi\psi$ permutes $\widehat G$ and multiplies the sum by $\chi(x)$, so the sum vanishes. The second statement is the same argument with the roles of $G$ and $\widehat G$ exchanged, using $E_G$. $\square$

**Theorem 4.5 (Fourier inversion).** $\mathcal{F}^{-1}_G \circ \mathcal{F}_G = \mathrm{id}$ and $\mathcal{F}_G \circ \mathcal{F}^{-1}_G = \mathrm{id}$; hence $\mathcal{F}_G$ is a linear isomorphism $\mathbb{C}[G] \to \mathbb{C}[\widehat G]$.

*Proof sketch.* Expand and exchange the order of summation:
$$\mathcal{F}^{-1}(\mathcal{F}f)(x) = \frac{1}{|G|}\sum_\psi \sum_g f(g)\psi(-g)\psi(x) = \frac{1}{|G|}\sum_g f(g)\sum_\psi \psi(x-g) = f(x)$$
by Lemma 4.4. The other composite is symmetric, using the second orthogonality relation. $\square$

**Theorem 4.6 (Naturality).** For every $\varphi \colon G \to H$, every $f \in \mathbb{C}[G]$ and every $\psi \in \widehat H$,
$$\widehat{\varphi_* f}(\psi) \;=\; \widehat{f}\bigl(\widehat{\varphi}(\psi)\bigr) \;=\; \widehat{f}(\psi \circ \varphi).$$

*Proof sketch.* Write the left side as $\sum_{h} \bigl(\sum_{\varphi(g)=h} f(g)\bigr)\psi(-h)$ and interchange the two sums; the inner condition $\varphi(g)=h$ collapses the $h$-sum to the single term $h = \varphi(g)$, giving $\sum_g f(g)\,\psi(-\varphi(g)) = \sum_g f(g)\,(\psi\circ\varphi)(-g)$. $\square$

**Theorem 4.7 (Fourier analysis is a natural isomorphism).** The family $(\mathcal{F}_G)_{G}$ is a natural isomorphism $\mathcal{A} \cong \mathcal{B}$ of functors $\mathsf{FinAb} \to \mathsf{Mod}_{\mathbb{C}}$.

*Proof.* Theorem 4.6 is the commuting naturality square; Theorem 4.5 gives invertibility of each component. $\square$

This is the paper's organising statement. Downsampling and aliasing identities in signal processing are Theorem 4.6 for surjective $\varphi$; periodisation identities are Theorem 4.6 for the quotient map $G \to G/K$.

---

## 5. Convolution, Plancherel, and the fourth power

**Definition 5.1.** $(f * g)(x) = \sum_{y \in G} f(y)\,g(x-y)$.

**Theorem 5.2 (Convolution theorem).** $\widehat{f*g} = \widehat{f}\cdot\widehat{g}$ pointwise on $\widehat G$. Consequently $*$ is commutative and associative, distributes over addition, and has the Dirac mass $\delta_0$ as unit.

*Proof sketch.* $\widehat{f*g}(\psi) = \sum_x\sum_y f(y)g(x-y)\psi(-x)$; substitute $x = y+z$ and factor $\psi(-y-z) = \psi(-y)\psi(-z)$. The algebraic corollaries follow either directly or by transporting them through the injective map $\mathcal{F}$. $\square$

**Theorem 5.3 (Plancherel).** $\displaystyle\sum_{\psi \in \widehat G} |\widehat f(\psi)|^2 = |G| \sum_{g \in G} |f(g)|^2 .$

*Proof sketch.* Expand $\widehat f(\psi)\overline{\widehat f(\psi)} = \sum_{g,h} f(g)\overline{f(h)}\,\psi(h-g)$ using $\overline{\psi(x)} = \psi(-x)$, sum over $\psi$, and apply Lemma 4.4 to kill all terms with $g \neq h$. $\square$

**Theorem 5.4 (Fourth-power identity).** With the double-dual identification $E_G$, $\ \widehat{\widehat{f}}(E_G x) = |G|\,f(-x)$; consequently, after two such identifications, $\mathcal{F}^4 = |G|^2 \cdot \mathrm{id}$.

*Proof sketch.* $\widehat{\widehat f}(E_G x) = \sum_\psi \widehat f(\psi)\,\mathrm{ev}_x(-\psi) = \sum_\psi \widehat f(\psi)\,\psi(-x) = |G| f(-x)$ by inversion at $-x$. Iterating and using $|\widehat{\widehat G}| = |G|$ gives the fourth-power statement, so the transform has order $4$ projectively — the discrete shadow of the fact that $\mathcal{F}$ has eigenvalues $\{1,i,-1,-i\}$ on $L^2(\mathbb{R})$. $\square$

---

## 6. Exactness, annihilators, and Poisson summation

**Theorem 6.1 (Exactness of duality).** If $\varphi \colon H \to G$ is injective then $\widehat{\varphi} \colon \widehat{G} \to \widehat{H}$ is surjective; if $\varphi$ is surjective then $\widehat\varphi$ is injective.

*Proof sketch.* Both follow from the equivalence of Theorem 3.2: an equivalence preserves monomorphisms and epimorphisms and reverses them along $\mathrm{op}$, and in $\mathsf{FinAb}$ mono $=$ injective and epi $=$ surjective. $\square$

**Corollary 6.2 (Character extension).** Every character of a subgroup $K \le G$ is the restriction of a character of $G$.

*Proof.* Apply Theorem 6.1 to the inclusion $K \hookrightarrow G$: surjectivity of the restriction map $\widehat G \to \widehat K$ is exactly the assertion. $\square$

**Definition 6.3 (Annihilator).** $K^{\perp} = \{\psi \in \widehat G : \psi|_K \equiv 1\}$, the kernel of the restriction $\widehat G \to \widehat K$.

**Theorem 6.4 (Annihilator counting).** $|K^{\perp}| \cdot |K| = |G|$.

*Proof sketch.* Restriction $\widehat G \to \widehat K$ is surjective (Corollary 6.2) with kernel $K^\perp$, so $|\widehat G| = |\widehat K|\cdot|K^\perp|$; now apply Lemma 2.4 to both $G$ and $K$. $\square$

**Lemma 6.5.** For $x \in G$, $\ \sum_{\psi \in K^{\perp}} \psi(x) = |K^{\perp}| \cdot [\,x \in K\,]$.

*Proof sketch.* $K^\perp \cong \widehat{G/K}$ and the sum is orthogonality (Lemma 4.4) on $G/K$ applied to the coset of $x$. $\square$

**Theorem 6.6 (Poisson summation).** For every subgroup $K \le G$ and every $f \in \mathbb{C}[G]$,
$$|G| \sum_{k \in K} f(k) \;=\; |K| \sum_{\psi \in K^{\perp}} \widehat{f}(\psi) .$$

*Proof sketch.* Expand the right side, exchange sums and apply Lemma 6.5 with $x = -g$:
$\sum_{\psi \in K^\perp}\widehat f(\psi) = \sum_g f(g)\sum_{\psi\in K^\perp}\psi(-g) = |K^\perp| \sum_{g \in K} f(g)$. Multiply by $|K|$ and use Theorem 6.4. $\square$

---

## 7. The uncertainty principle and its equality case

**Theorem 7.1 (Donoho–Stark).** For every non-zero $f \in \mathbb{C}[G]$,
$$|\operatorname{supp} f| \cdot |\operatorname{supp} \widehat f| \;\ge\; |G| .$$

*Proof.* Let $M = \max_g |f(g)| > 0$, attained at $g_0$. For every $\psi$,
$$|\widehat f(\psi)| \le \sum_{g \in \operatorname{supp} f} |f(g)|\,|\psi(-g)| \le |\operatorname{supp} f|\cdot M .$$
By inversion at $g_0$, only characters in $\operatorname{supp}\widehat f$ contribute, so
$$M = |f(g_0)| \le \frac{1}{|G|}\,|\operatorname{supp}\widehat f| \cdot |\operatorname{supp} f| \cdot M .$$
Divide by $M > 0$. $\square$

**Corollary 7.2 (Additive form).** $|\operatorname{supp} f| + |\operatorname{supp}\widehat f| \ge 2\sqrt{|G|}$, and hence $\max\bigl(|\operatorname{supp} f|, |\operatorname{supp}\widehat f|\bigr) \ge \sqrt{|G|}$.

*Proof.* AM–GM applied to Theorem 7.1. $\square$

**Corollary 7.3 (Contrapositive form).** If $|\operatorname{supp} f|\cdot|\operatorname{supp}\widehat f| < |G|$ then $f = 0$. In particular a function supported at a single point has a nowhere-vanishing transform.

**Theorem 7.4 (Sharpness).** For a Dirac mass $\delta_a$ one has $\widehat{\delta_a}(\psi) = \psi(-a)$, which never vanishes, so $|\operatorname{supp}\delta_a| \cdot |\operatorname{supp}\widehat{\delta_a}| = 1 \cdot |G| = |G|$: the bound of Theorem 7.1 is attained.

More generally, let $K \le G$, $a \in G$, $\chi \in \widehat G$, and set
$$c_{K,a,\chi}(g) = \begin{cases} \chi(g), & g - a \in K, \\ 0 & \text{else.}\end{cases}$$

**Theorem 7.5 (Coset indicators are extremal).** $|\operatorname{supp} c_{K,a,\chi}| = |K|$ and $|\operatorname{supp}\widehat{c_{K,a,\chi}}| = |K^\perp| = |G|/|K|$, so equality holds in Theorem 7.1.

*Proof sketch.* The transform is computed from $\sum_{k \in K}\psi(k) = |K|\,[\psi \in K^\perp]$; one finds $\widehat{c_{K,a,\chi}}(\psi) = |K|\,\overline{\psi(a)}\chi(a)\,[\,\chi\overline{\psi} \in K^{\perp}]$ up to a unimodular factor, whose support is the coset $\chi K^{\perp}$ of size $|K^\perp|$. Now apply Theorem 6.4. $\square$

The converse is the substantive half.

**Theorem 7.6 (Rigidity: complete classification of the extremals).** Let $f \neq 0$. Then
$$|\operatorname{supp} f| \cdot |\operatorname{supp} \widehat f| = |G|$$
**if and only if** there exist a subgroup $K \le G$, a point $a \in G$, a character $\chi \in \widehat G$ and a scalar $c \neq 0$ such that
$$f(g) = \begin{cases} c\,\chi(g), & g - a \in K,\\ 0, & \text{otherwise.}\end{cases}$$

*Proof sketch.* ($\Leftarrow$) is Theorem 7.5 together with the fact that supports are unchanged by multiplication by $c \ne 0$.

($\Rightarrow$) Equality forces every inequality in the proof of Theorem 7.1 to be an equality. Two rigidity steps result. First, $|\widehat f(\psi)| = M\,|\operatorname{supp} f|$ for every $\psi \in \operatorname{supp}\widehat f$: the triangle inequality $\bigl|\sum_{g \in \operatorname{supp} f} f(g)\psi(-g)\bigr| \le \sum |f(g)|$ is tight, which forces all summands to share a common phase and all $|f(g)|$ to equal $M$ on the support. Consequently there are a scalar $c$ with $|c| = M$ and a character $\chi$ with $f(g) = c\,\chi(g)$ for all $g$ in the support — the phase alignment, transported across the support, is precisely multiplicativity. Second, the set
$$P = \{x \in G : |\widehat f(\psi)\psi(x)| \text{ is constant along } \operatorname{supp}\widehat f\}$$
of "Fourier periods" of $f$, namely $\{x : f(\cdot + x) \text{ is a unimodular multiple of } f\}$, is a subgroup $K$, and equality forces $\operatorname{supp} f$ to be a single coset $a + K$. Combining the two gives the stated form. $\square$

**Theorem 7.7 (Divisibility obstruction).** If $f \neq 0$ attains equality in Theorem 7.1, then $|\operatorname{supp} f|$ divides $|G|$.

*Proof.* By Theorem 7.6 the support is a coset of a subgroup $K$, so $|\operatorname{supp} f| = |K|$, and Lagrange's theorem applies. $\square$

**Corollary 7.8 (Strict uncertainty).** If $|\operatorname{supp} f|$ does not divide $|G|$ then $|\operatorname{supp} f|\cdot|\operatorname{supp}\widehat f| > |G|$ strictly.

This is a genuinely stronger statement than Theorem 7.1 and is invisible from the inequality alone. For $G = \mathbb{Z}/p$ with $p$ prime it yields the Tao-type dichotomy: any non-zero $f$ with $1 < |\operatorname{supp} f| < p$ has strictly super-critical uncertainty product, which underlies exact sparse recovery from few frequency samples.

---

## 8. The kernel-level uncertainty principle

The proof of Theorem 7.1 used only three facts: $|\psi(-g)| \le 1$; the inversion identity; and $|\,|G|^{-1}\psi(g)\,| \le |G|^{-1}$. Nothing else. Abstracting them gives the following.

**Definition 8.1 (Kernel transform).** For finite sets $G, H$ and $k \colon G \times H \to \mathbb{C}$, put $(T_k f)(h) = \sum_{g \in G} f(g)\,k(g,h)$.

**Theorem 8.2 (Kernel uncertainty principle).** Let $k \colon G\times H \to \mathbb{C}$ satisfy $|k(g,h)| \le \mu$ for all $g,h$, and suppose $l \colon H \times G \to \mathbb{C}$ satisfies $|l(h,g)| \le \nu$ and reconstructs:
$$f(g) = \sum_{h \in H} (T_k f)(h)\,l(h,g) \qquad \text{for all } f \text{ and } g .$$
Then for every $f \neq 0$,
$$1 \;\le\; \mu\,\nu\,\bigl|\operatorname{supp} f\bigr|\cdot\bigl|\operatorname{supp} T_k f\bigr| .$$

*Proof.* Let $M = \max_g|f(g)|$, attained at $g_0$; $M > 0$ since $f \ne 0$. For each $h$,
$$|(T_kf)(h)| \le \sum_{g \in \operatorname{supp} f}|f(g)|\,|k(g,h)| \le |\operatorname{supp} f|\,M\mu .$$
Applying the reconstruction identity at $g_0$, and noting that only $h \in \operatorname{supp} T_kf$ contribute,
$$M = |f(g_0)| \le |\operatorname{supp} T_kf| \cdot \bigl(|\operatorname{supp} f|\,M\mu\bigr)\cdot\nu .$$
Cancel $M>0$. $\square$

No linearity beyond the definition of $T_k$, no orthogonality, no unitarity, no group structure was used.

**Corollary 8.3 (Donoho–Stark recovered).** Take $G$ a finite abelian group, $H = \widehat G$, $k(g,\psi) = \psi(-g)$ and $l(\psi,g) = |G|^{-1}\psi(g)$. Then $\mu = 1$, $\nu = |G|^{-1}$, and Theorem 8.2 reads $1 \le |G|^{-1}|\operatorname{supp} f||\operatorname{supp}\widehat f|$, i.e. Theorem 7.1.

The classical constant $|G|$ therefore enters only through the normalisation of the *inversion* kernel; the invariant that actually governs the principle is the coherence product $\mu\nu$.

**Corollary 8.4 (Elad–Bruckstein coherence bound).** Let $U \colon G \times H \to \mathbb{C}$ have orthonormal rows, $\sum_h U(g,h)\overline{U(g',h)} = [g = g']$, and entries of modulus $\le \mu$. Then for every $f \neq 0$,
$$1 \le \mu^2\,|\operatorname{supp} f|\cdot|\operatorname{supp} T_U f| .$$

*Proof sketch.* Orthonormality of the rows makes $l(h,g) = \overline{U(g,h)}$ a reconstruction kernel: substituting $T_Uf$ and exchanging sums gives $\sum_{g'} f(g')\sum_h U(g',h)\overline{U(g,h)} = f(g)$. Since $|\overline{U(g,h)}| = |U(g,h)| \le \mu$, Theorem 8.2 applies with $\nu = \mu$. $\square$

**Corollary 8.5 (Mutually unbiased / complex Hadamard form).** If in addition all entries have modulus $\le 1/\sqrt{n}$ for some $n>0$, then
$$n \le |\operatorname{supp} f| \cdot |\operatorname{supp} T_U f| .$$

*Proof.* Corollary 8.4 with $\mu = 1/\sqrt n$, so $\mu^2 = 1/n$. $\square$

**Example 8.6 (A group-free witness).** Let $H_2 = \tfrac{1}{\sqrt2}\begin{pmatrix}1&1\\1&-1\end{pmatrix}$. Its rows are orthonormal and its entries have modulus $1/\sqrt2$, so Corollary 8.5 gives $|\operatorname{supp} f|\cdot|\operatorname{supp} H_2 f| \ge 2$ for every non-zero $f \in \mathbb{C}^2$: no vector is a single coordinate in both the standard and the Hadamard basis. This instance involves no group and no characters.

**Theorem 8.7 (Optimality of the constant).** Suppose the kernel is *flat*, i.e. $|k(g,h)| = \mu > 0$ for all $g,h$. Then for every $a \in G$, $T_k \delta_a = k(a,\cdot)$ is nowhere zero, so $|\operatorname{supp} \delta_a|\cdot|\operatorname{supp} T_k\delta_a| = |H|$, and Theorem 8.2 forces
$$1 \le \mu\,\nu\,|H| .$$
Thus Dirac masses attain the abstract bound and the constant $(\mu\nu)^{-1}$ cannot be improved.

*Proof.* $T_k\delta_a(h) = \sum_g \delta_a(g)k(g,h) = k(a,h)$, of modulus $\mu > 0$. $\square$

Theorem 8.7 identifies flatness as the precise mechanism behind sharpness in Theorem 7.4: the character table is a flat matrix.

---

## 9. The opposite extreme: quadratic Gauss sums

Let $N$ be odd, and let $\psi$ be a *primitive* additive character of $\mathbb{Z}/N$ (that is, $\psi_a := \psi(a\,\cdot)$ is non-trivial for every $a \ne 0$). Define the **quadratic phase** $q_\psi(x) = \psi(x^2)$.

**Theorem 9.1 (Gauss sum evaluation).** $\displaystyle\Bigl|\sum_{x \in \mathbb{Z}/N}\psi(x^2)\Bigr|^2 = N .$

*Proof sketch.* Write $S = \sum_x \psi(x^2)$ and expand $S\overline{S} = \sum_{x,y}\psi(x^2 - y^2)$. Substituting $x = y+t$ gives $\psi(x^2 - y^2) = \psi(t^2 + 2ty)$, hence
$$S\overline{S} = \sum_t \psi(t^2)\sum_y \psi(2ty).$$
Since $N$ is odd, $2$ is a unit in $\mathbb{Z}/N$, so $2t = 0$ iff $t=0$; for $t \ne 0$ the inner sum is a complete character sum of the non-trivial character $\psi_{2t}$ and vanishes by Lemma 4.4. Only $t = 0$ survives, contributing $\psi(0)\cdot N = N$. $\square$

**Theorem 9.2 (Flatness of the quadratic phase).** For every character $\chi$ of $\mathbb{Z}/N$, $\ |\widehat{q_\psi}(\chi)|^2 = N$. In particular $\widehat{q_\psi}$ never vanishes.

*Proof sketch.* Primitivity implies every $\chi$ is a shift $\psi_b = \psi(b\,\cdot)$. Then $q_\psi(x)\psi_b(-x) = \psi(x^2 - bx)$, and completing the square (again using that $2$ is invertible) reduces the sum to a Gauss sum times a unimodular factor; apply Theorem 9.1. $\square$

**Theorem 9.3 (Maximal uncertainty product).** For odd $N > 1$ and primitive $\psi$,
$$|\operatorname{supp} q_\psi| \cdot |\operatorname{supp}\widehat{q_\psi}| = N \cdot N = N^2 > N ,$$
so the quadratic phase is *anti-extremal*: it strictly maximises the uncertainty product while modulated coset indicators strictly minimise it.

*Proof.* Characters never vanish, so $\operatorname{supp} q_\psi$ is everything; Theorem 9.2 gives the same for the transform; and $|\widehat{\mathbb{Z}/N}| = N$. $\square$

Chirps are used in radar and in spread-spectrum communication for exactly this reason: they are maximally delocalised in both domains, hence robust to narrowband interference and to timing error.

---

## 10. Duality as a self-adjunction; the Fourier kernel as the image of the identity

**Definition 10.1 (Bicharacter swap).** For $f \colon G \to \widehat H$ a homomorphism, define $\sigma(f) \colon H \to \widehat G$ by $\sigma(f)(h)(g) = f(g)(h)$.

**Proposition 10.2.** $\sigma(f)$ is a homomorphism, $\sigma \circ \sigma = \mathrm{id}$, and $\sigma$ is additive. Hence
$$\sigma \colon \operatorname{Hom}(G,\widehat H) \;\xrightarrow{\ \cong\ }\; \operatorname{Hom}(H,\widehat G)$$
is an isomorphism of abelian groups, involutive, and natural in both variables:
$$\sigma(f \circ \varphi) = \widehat{\varphi}\circ\sigma(f), \qquad \sigma(\widehat{\varphi}\circ f) = \sigma(f)\circ\varphi .$$

*Proof sketch.* Each assertion is checked by evaluating both sides at a group element and then at a character; all reduce to the defining rule $\sigma(f)(h)(g) = f(g)(h)$ and to the fact that a homomorphism into $\widehat H$ is exactly a bicharacter of $G \times H$. $\square$

**Corollary 10.3 (Counting bicharacters).** $|\operatorname{Hom}(G,\widehat H)| = |\operatorname{Hom}(H,\widehat G)|$: bicharacters of $G \times H$ may be counted on either side.

**Theorem 10.4 (Self-adjunction).** The dual functor is adjoint to itself, in the sense appropriate to a contravariant functor: the equivalence of Theorem 3.2 is an adjunction $D^{\mathrm{op}} \dashv D$ whose unit is the double-duality isomorphism $E$. Moreover, the abstract hom-set bijection of this adjunction is exactly $\sigma$: for all $G,H$ and every $u \colon H \to \widehat G$, the adjunct of $u$ is $\sigma(u)$.

*Proof sketch.* Any equivalence gives rise to an adjunction with unit its unit isomorphism; here the unit is $E$ by Theorem 3.2. The abstract adjunct is computed by the recipe $u \mapsto D(u)\circ \text{unit}$, and evaluating that composite at $g$ and then at $h$ gives $u(h)(g)$, which is the defining formula for $\sigma$. $\square$

**Theorem 10.5 (Fourier kernel as the swap of the identity).** Let $E = \sigma(\mathrm{id}_{\widehat G}) \colon G \to \widehat{\widehat G}$. Then $E$ is the evaluation map of Definition 3.1, and for every $f \in \mathbb{C}[G]$ and $\psi \in \widehat G$,
$$\widehat f(\psi) = \sum_{g \in G} f(g)\; E(-g)(\psi) .$$
Consequently Fourier inversion (Theorem 4.5) is the statement that integration against the evaluation bicharacter is invertible.

*Proof.* $\mathrm{id}_{\widehat G}$ is a homomorphism $\widehat G \to \widehat G$, i.e. a bicharacter of $\widehat G \times G$; swapping gives $\sigma(\mathrm{id})(g)(\psi) = \mathrm{id}(\psi)(g) = \psi(g)$, which is $\mathrm{ev}_g$. Hence $E(-g)(\psi) = \psi(-g)$ and the displayed formula is Definition 4.3. $\square$

This is the precise content of the slogan "the Fourier transform is the unit of self-duality". The exponential kernel is not a choice of basis or a convenient ansatz: it is the image of the identity morphism under a canonical, natural, involutive bijection. Any category self-dual in this way carries a Fourier transform, and the kernel is determined.

---

## 11. Algorithms

Three algorithmic remarks tie the theory to computation.

**11.1 Character-table transform and the fast algorithm.** For $G = \mathbb{Z}/N$, $\mathcal{F}$ is the $N\times N$ DFT matrix and costs $O(N^2)$ naively, $O(N\log N)$ by the Cooley–Tukey factorisation. Cooley–Tukey is itself an instance of Theorem 4.6: for $N = N_1N_2$, the short exact sequence $\mathbb{Z}/N_1 \hookrightarrow \mathbb{Z}/N \twoheadrightarrow \mathbb{Z}/N_2$ makes the transform factor through pushforward along the quotient, which is exactly the "decimate, transform, twiddle, transform" pattern.

**11.2 Certifying extremality.** Given $f$ on $G$, computing $\widehat f$ and the two support sizes decides whether $f$ is extremal for Theorem 7.1 in $O(|G|\log|G|)$ time for cyclic $G$. Theorem 7.7 gives a *cheaper* one-sided certificate: if $|\operatorname{supp} f| \nmid |G|$ then extremality is impossible, no transform required — an $O(|G|)$ test.

**11.3 The Pólya tree recurrence.** See Section 12: computing $a_1,\dots,a_n$ costs $O(n^2)$ arithmetic operations once the divisor weights $\omega_1,\dots,\omega_n$ have been accumulated in $O(n\log n)$ by sieving over multiples.

---

## 12. A companion bridge: Pólya trees

The Fourier development above is an instance of a general pattern: an identity that converts a structural description into a computational recurrence, and the observation that the conversion is *reversible*. We record a second, independent instance in enumerative combinatorics.

Let $a_k$ be the number of rooted unlabelled trees ("Pólya trees") on $k$ nodes: $1, 1, 2, 4, 9, 20, 48, 115, 286, 719, 1842, 4766, \dots$. The generating function $A(z) = \sum_{k\ge1}a_kz^k$ satisfies the functional equation reflecting that a tree is a root together with an unordered multiset of subtrees:
$$A(z) = z\,\exp\!\Bigl(\sum_{i\ge1}\frac{A(z^i)}{i}\Bigr) = z\exp(S(z)), \qquad S(z) := \sum_{i \ge 1}\frac{A(z^i)}{i}. \tag{FE}$$

Exponentials of power series are awkward. Logarithmic differentiation of (FE) removes them entirely, yielding the exp-free identity
$$z\,A'(z) = A(z)\bigl(1 + z\,S'(z)\bigr), \tag{LD}$$
which is equivalent to (FE) given $a_1 = 1$.

**Definition 12.1.** For a sequence $a \colon \mathbb{N}\to\mathbb{Q}$ define the *divisor weight* and the *$S$-coefficient*
$$\omega_n = \sum_{d \mid n} d\,a_d, \qquad s_n = \sum_{i \mid n} \frac{a_{n/i}}{i} .$$
Here $s_n$ is literally the coefficient $[z^n]S(z)$, since $A(z^i)$ contributes $a_{n/i}/i$ to $[z^n]$ exactly when $i \mid n$.

**Theorem 12.2 (Divisor bridge).** For every sequence $a$ and every $n$,
$$n\,s_n = \omega_n, \qquad \text{i.e.}\qquad n \sum_{i\mid n}\frac{a_{n/i}}{i} = \sum_{d\mid n} d\,a_d .$$

*Proof.* Reflect the divisor index: the map $i \mapsto n/i$ is an involution of the set of divisors of $n$. Under it the term $n \cdot a_{n/i}/i$ becomes $n\,a_{d}/(n/d) = d\,a_d$ where $d = n/i$. Summing over all divisors gives the claim. $\square$

This one line is the whole mathematical content of the bridge: it is what connects the *analytic* object $S(z) = \sum_i A(z^i)/i$ to the *number-theoretic* weight $\omega_n$. Note that $[z^n]\bigl(zS'(z)\bigr) = n\,[z^n]S(z) = n s_n$, so Theorem 12.2 says precisely that the coefficients of $zS'$ are the divisor weights.

**Theorem 12.3 (Equivalence of the functional equation and the recurrence).** For a sequence $a$, the coefficientwise form of (LD),
$$n\,a_n = a_n + \sum_{j=1}^{n-1} a_j \cdot \bigl((n-j)\,s_{n-j}\bigr) \qquad \text{for all } n \ge 1, \tag{LD$_n$}$$
holds **if and only if**
$$(k-1)\,a_k = \sum_{j=1}^{k-1} a_j\,\omega_{k-j} \qquad \text{for all } k \ge 2. \tag{R$_k$}$$

*Proof.* By Theorem 12.2 applied termwise, $\sum_j a_j\bigl((n-j)s_{n-j}\bigr) = \sum_j a_j\,\omega_{n-j}$; so the two convolution sums are literally equal. Given (LD$_n$) for $n = k \ge 2$, subtract $a_k$ from both sides to get (R$_k$). Conversely, given (R$_n$) for $n \ge 2$, add $a_n$ to both sides to recover (LD$_n$); and for $n=1$ the identity (LD$_1$) reads $1\cdot a_1 = a_1 + (\text{empty sum})$, which is automatic. $\square$

The vacuity of the $n=1$ case is exactly the reason the recurrence begins at $k = 2$.

**Theorem 12.4 (Pólya tree recurrence).** If $a_1 = 1$ and (LD$_n$) holds for all $n \ge 1$, then $a_1 = 1$ and for every $k \ge 2$
$$a_k = \frac{1}{k-1}\sum_{j=1}^{k-1} a_j\,\omega_{k-j}, \qquad \omega_m = \sum_{d\mid m} d\,a_d .$$

*Proof.* Theorem 12.3 gives $(k-1)a_k = \sum_j a_j\omega_{k-j}$; since $k \ge 2$ we have $k-1 \ne 0$ and may divide. $\square$

Together with $a_0 = 0$, $a_1 = 1$ the recurrence determines the sequence uniquely, and it is the algorithm used in practice: sieve the weights $\omega_m$ in $O(n\log n)$, then convolve in $O(n^2)$.

Two remarks make the parallel with the Fourier story precise. First, the divisor weight $\omega_n$, which looks like an *ad hoc* modelling choice, is **forced**: it is $n[z^n]S(z)$, nothing more. Second, the passage from structure to computation is an **equivalence**, not merely an implication: no information is discarded in going from (FE) to the recurrence. Both are precisely the phenomena isolated in Sections 8 and 10 — an apparently essential constant turning out to be a normalisation (there, $|G|$; here, the weight $\omega$), and a formula turning out to be forced by a canonical involution (there, the bicharacter swap; here, the divisor reflection $d \mapsto n/d$).

---

## 13. Discussion

**What the categorical framing actually buys.** It is a fair objection that categorical language can be decoration. Here it is not, for three reasons.

1. *It separates the hard content from the bookkeeping.* All of Sections 4–6 reduce to the two orthogonality relations of Lemma 4.4; the categorical apparatus is exactly the machinery that makes those relations *natural*, i.e. compatible with all homomorphisms simultaneously. That compatibility is what one uses in practice under the names aliasing, periodisation and downsampling.
2. *It predicts the right generalisations.* Theorem 10.5 says the Fourier kernel is the swap of the identity in a self-adjoint duality. This is a definition that makes sense in any self-dual setting, and it explains why "Fourier transforms" exist for objects far from groups — the exponential is not the essential ingredient.
3. *It relocates the uncertainty principle.* Theorem 8.2 shows the principle has nothing to do with the group; it belongs to any bounded pair (analysis kernel, synthesis kernel). The group order $|G|$ is the reciprocal coherence product. This is the conceptual reason the Donoho–Stark bound and the Elad–Bruckstein bound look identical: they are the same theorem.

**Sharpness landscape.** The results identify both ends of the uncertainty spectrum on $\mathbb{Z}/N$ for odd $N$: modulated coset indicators (uncertainty product exactly $N$, Theorem 7.6) and quadratic phases (product exactly $N^2$, Theorem 9.3). Between them, Theorem 7.7 imposes an arithmetic constraint — a function can only be extremal if its support size divides $N$.

**Limits of the present treatment.** Everything is finite. The passage to locally compact abelian groups requires Haar measure, topology on the dual, and the Pontryagin–van Kampen theorem, none of which is developed here; the self-adjunction of Section 10 would then be an adjunction of topological categories with continuous bicharacters. The finite case is nonetheless the one relevant to computation, and it is where the coherence viewpoint of Section 8 is quantitatively meaningful.

---

## 14. Future directions

* **Beyond finiteness.** Establish the analogue of Theorem 10.4 for locally compact abelian groups, with $\operatorname{Hom}$ taken in the category of topological abelian groups. The bicharacter swap of Proposition 10.2 should still be the hom-set bijection; the analytic input is joint continuity of bicharacters.
* **Coherence-optimal frames.** Theorem 8.7 says flat kernels saturate the abstract bound. Classify the flat kernels admitting a bounded inversion with $\mu\nu|H| = 1$; these should be exactly the complex Hadamard matrices up to scaling, which would be an "extremals theorem" for Theorem 8.2 parallel to Theorem 7.6.
* **Rigidity for general kernels.** Extend Theorem 7.6 to Theorem 8.2: for which kernels does equality force coset structure? Conjecturally the phase-alignment step goes through whenever the kernel is flat and the reconstruction is the adjoint, producing a notion of "coset" internal to the kernel.
* **Non-abelian and quantum analogues.** Replace $\widehat G$ by the set of irreducible representations. The dual is no longer a group, so Theorem 3.2 fails; but Theorem 8.2 does not use group structure and should give a Donoho–Stark bound for the non-abelian Fourier transform with $\mu$ the largest matrix-entry modulus.
* **Arithmetic of extremality.** Theorem 7.7 makes extremality a divisor-theoretic condition. For $G = \mathbb{Z}/N$ with $N$ highly composite, count the extremal functions up to scaling: by Theorem 7.6 they are indexed by triples (subgroup, coset, character), giving $\sum_{d \mid N} d \cdot N$ up to normalisation — a clean formula worth stating and proving in general.
* **Pólya-type bridges.** Theorem 12.3 shows a functional equation and a divisor recurrence are equivalent. Identify the general mechanism: for which multiset-substitution schemes does logarithmic differentiation produce an exp-free identity whose coefficients are divisor sums?
