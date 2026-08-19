# Minimum Uncertainty Is a Subgroup: Rigidity of Finite Poisson Summation and the Extremals of the Donoho–Stark Uncertainty Principle

**Author:** Aristotle
**Date:** 2026-08-19

---

## Abstract

Let $G$ be a finite abelian group of order $N$ with Pontryagin dual $\widehat G$, and let $f \mapsto \hat f$ denote the discrete Fourier transform. Two classical "if" statements govern the interaction between the transform and the subgroup lattice of $G$: subgroup indicators attain equality in the Donoho–Stark uncertainty principle $|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f| \ge N$, and every subgroup $H \le G$ supports a Poisson summation formula $N\sum_{x \in H} f = |H| \sum_{\psi \in H^{\perp}} \hat f$.

We prove the converses of both, and show that the two resulting rigidity theorems describe one and the same object. First, if a nonempty finite set $S \subseteq G$ and a finite set $T \subseteq \widehat G$ satisfy the Poisson identity for *all* test functions, then $S$ is a subgroup and $T$ is exactly its annihilator; moreover the identity need only be verified on the $N$ Dirac functions, so the structure theorem is forced by finitely many scalar equations. Second, a nonzero $f : G \to \mathbb{C}$ satisfies $|\operatorname{supp} f| \cdot |\operatorname{supp} \hat f| = N$ if and only if $f = c\,\chi\,\mathbf 1_{a+K}$ for a subgroup $K \le G$, a character $\chi$, a coset representative $a$, and a nonzero scalar $c$. The subgroup $K$ is unique and equals the difference set $\operatorname{supp} f - \operatorname{supp} f$.

From the classification we derive an arithmetic theory of the extremal class. The support sizes of extremal functions divide $N$ and are complementary divisors (Lagrange rigidity); consequently the uncertainty inequality is strict, with an explicit gap $N + (s - N \bmod s)$, whenever $s = |\operatorname{supp} f|$ fails to divide $N$. Using the converse of Lagrange's theorem for finite abelian groups (proved here by induction from Cauchy's theorem), we show that the *extremal spectrum* of $G$ — the set of achievable support sizes — is exactly the divisor set of $N$, and that the achievable pairs $(|\operatorname{supp} f|, |\operatorname{supp} \hat f|)$ are exactly the factorisations $st = N$. This yields a detection of primality by the extremal class, a reconstruction statement (equal spectra imply equal orders), and a sharp limitation (equal orders imply equal spectra, so the spectrum sees only the order). The finer invariant given by the family of extremal *supports* does separate the two groups of order four.

We further show that the extremal class is closed under pointwise multiplication, convolution, convolution powers, and the Fourier transform itself, making it a rigid algebraic object rather than a merely analytic extremum set. Finally we specialise to probability: an extremal probability distribution on a finite abelian group is precisely a uniform distribution on a coset.

**Keywords:** uncertainty principle, Donoho–Stark, Poisson summation, finite abelian group, Pontryagin duality, coset modulation, extremal problem, discrete Fourier transform, uniform distribution.

---

## 1. Introduction

### 1.1 Two "if" theorems and two missing converses

Harmonic analysis on a finite abelian group $G$ of order $N$ is governed by the interaction between two lattices: the subgroup lattice of $G$ and the subgroup lattice of the dual group $\widehat G$, matched by the annihilator correspondence $H \mapsto H^{\perp}$. Two facts sit at the centre of that interaction.

**Fact A (extremality of subgroup indicators).** For $H \le G$, the transform of $\mathbf 1_H$ is $|H| \cdot \mathbf 1_{H^{\perp}}$, and $|H| \cdot |H^{\perp}| = N$. Hence $\mathbf 1_H$ attains equality in the Donoho–Stark uncertainty principle. Since the three basic symmetries of function space — scaling by a nonzero constant, translation, and modulation by a character — permute the two supports without changing their sizes, the whole orbit
$$f(x) = c\,\chi(x)\,\mathbf 1_{a+K}(x), \qquad c \ne 0,\ \chi \in \widehat G,\ a \in G,\ K \le G$$
consists of extremal functions. We call these **coset modulations**.

**Fact B (Poisson summation).** For $H \le G$ and every $f : G \to \mathbb{C}$,
$$N \sum_{x \in H} f(x) = |H| \sum_{\psi \in H^{\perp}} \hat f(\psi).$$

Both are "if" statements: a subgroup produces a phenomenon. The question addressed here is whether the phenomenon produces a subgroup. We answer yes in both cases, and we prove that the answers coincide.

### 1.2 Statement of the main results

Throughout, $\operatorname{supp} f = \{x \in G : f(x) \ne 0\}$.

**Theorem 1 (Rigidity of Poisson summation).** Let $S \subseteq G$ be nonempty and $T \subseteq \widehat G$, and suppose
$$N \sum_{x \in S} f(x) = |S| \sum_{\psi \in T} \hat f(\psi) \quad \text{for all } f : G \to \mathbb{C}.$$
Then $S$ is a subgroup of $G$ and $T = S^{\perp}$. In particular $0 \in S$ and $|S| \cdot |T| = N$.

**Theorem 2 (Classification of the Donoho–Stark extremals).** Let $f : G \to \mathbb{C}$ be nonzero. Then $|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| = N$ if and only if $f$ is a coset modulation.

**Theorem 3 (Extremal spectrum).** For $d \in \mathbb{N}$, there is a nonzero extremal $f$ on $G$ with $|\operatorname{supp} f| = d$ if and only if $d \mid N$. More precisely, a pair $(s,t)$ occurs as $(|\operatorname{supp} f|, |\operatorname{supp}\hat f|)$ for an extremal $f$ if and only if $st = N$.

**Theorem 4 (Extremal probability distributions).** Let $p$ be a probability distribution on $G$ attaining equality in the uncertainty principle. Then there are $a \in G$ and $K \le G$ with $p = \frac{1}{|K|}\mathbf 1_{a + K}$.

Sections 4–8 develop the arithmetic and algebraic consequences: Lagrange rigidity and the uncertainty gap, primality detection, reconstruction of the order, closure under products, convolutions and duality, and the identification of Poisson pairs with extremal support pairs.

### 1.3 Context

The inequality $|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \ge N$ is the discrete uncertainty principle of Donoho and Stark, the combinatorial backbone of sparse recovery: a nonzero signal cannot be simultaneously sparse in the space and frequency domains, and quantitative versions of this statement underwrite the uniqueness guarantees of compressed sensing. Understanding the equality case is understanding the worst case for such guarantees. The results below convert the analytic extremal problem into an arithmetic one: the extremal set sizes are exactly the divisors of $N$, so the abundance of "bad" signals is governed by the factorisation of the group order.

---

## 2. Setting and conventions

Let $G$ be a finite abelian group, written additively, with $N := |G| \ge 1$, and let $\widehat G := \operatorname{Hom}(G, \mathbb{C}^{\times})$ be its group of characters, written additively as well: $(\psi + \chi)(x) = \psi(x)\chi(x)$ and $(\psi - \chi)(x) = \psi(x)/\chi(x)$. Every character takes values in the unit circle, $|\psi(x)| = 1$, and $\widehat G \cong G$ with $|\widehat G| = N$.

**Definition 2.1 (Discrete Fourier transform).** For $f : G \to \mathbb{C}$,
$$\hat f(\psi) := \sum_{x \in G} \overline{\psi(x)}\, f(x), \qquad \psi \in \widehat G.$$

We use freely the following standard facts.

* **Character orthogonality over a subgroup.** For $H \le G$ and $\psi \in \widehat G$,
  $$\sum_{x \in H}\psi(x) = \begin{cases}|H| & \psi \in H^{\perp},\\ 0 & \text{otherwise,}\end{cases}$$
  where $H^{\perp} := \{\psi \in \widehat G : \psi|_H \equiv 1\}$ is the **annihilator**. *Proof:* translation by an $x_0 \in H$ with $\psi(x_0) \ne 1$ permutes $H$, whence $(\psi(x_0) - 1)\sum_{x\in H}\psi(x) = 0$.
* **Inversion.** $f(x) = \frac{1}{N}\sum_{\psi \in \widehat G} \psi(x)\hat f(\psi)$.
* **Plancherel.** $\sum_{\psi} |\hat f(\psi)|^2 = N \sum_{x}|f(x)|^2$.
* **Convolution.** With $(u * v)(x) := \sum_{y} u(y)v(x-y)$ one has $\widehat{u * v} = \hat u \cdot \hat v$.
* **Dirac functions.** $\delta_y(x) := [x = y]$ has $\widehat{\delta_y}(\psi) = \overline{\psi(y)}$.
* **Donoho–Stark.** For $f \ne 0$, $|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \ge N$.

**Definition 2.2 (Symmetries).** The *translate* is $(T_a f)(x) := f(x - a)$ and the *modulate* is $(M_\chi f)(x) := \chi(x)f(x)$.

**Lemma 2.3.** $\widehat{T_a f}(\psi) = \overline{\psi(a)}\,\hat f(\psi)$ and $\widehat{M_\chi f}(\psi) = \hat f(\psi - \chi)$.

*Proof.* Reindex the defining sum by $x \mapsto x + a$ in the first case, and use $\overline{(\psi-\chi)(x)} = \overline{\psi(x)}\chi(x)$ in the second. $\square$

**Corollary 2.4.** Translation preserves $|\operatorname{supp} f|$ and $|\operatorname{supp}\hat f|$; modulation does likewise; scaling by $c \ne 0$ preserves both. Hence the extremal set is invariant under the three symmetries.

**Definition 2.5 (Extremality).** $f : G \to \mathbb{C}$ is **extremal** if $|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| = N$.

---

## 3. The two rigidity theorems

### 3.1 Equality in the triangle inequality

Both proofs run on the same engine.

**Lemma 3.1.** Let $s$ be a finite index set and $z_i \in \mathbb{C}$ with $|z_i| = 1$ for all $i \in s$. If $\sum_{i \in s} z_i = |s|$, then $z_i = 1$ for all $i$.

*Proof.* Taking real parts, $\sum_i \operatorname{Re} z_i = |s|$, while $\operatorname{Re} z_i \le |z_i| = 1$ termwise; a sum of terms bounded by $1$ reaching $|s|$ forces every term to equal $1$. Then $\operatorname{Re} z_i = 1$ and $|z_i| = 1$ give $\operatorname{Im} z_i = 0$, so $z_i = 1$. $\square$

**Lemma 3.2 (Constant-modulus form).** Let $z_i$, $i \in s$, be complex numbers with $|z_i| = M > 0$ for all $i$, and suppose $\bigl|\sum_{i\in s} z_i\bigr| = |s| \cdot M$. Then all $z_i$ are equal.

*Proof.* Set $\Sigma := \sum_i z_i$; by hypothesis $\Sigma \ne 0$. The numbers $w_i := \overline{\Sigma}z_i/(|\Sigma| M)$ have modulus $1$ and satisfy $\sum_i w_i = \overline\Sigma \Sigma /(|\Sigma| M) = |\Sigma|/M = |s|$. By Lemma 3.1 all $w_i = 1$, hence $\overline\Sigma z_i = |\Sigma| M$ is independent of $i$; cancelling $\overline \Sigma \ne 0$ gives $z_i = z_j$. $\square$

### 3.2 Rigidity of Poisson summation

**Definition 3.3 (Poisson pair).** A pair $(S,T)$ with $S \subseteq G$, $T \subseteq \widehat G$ is a **Poisson pair** if
$$N \sum_{x \in S} f(x) = |S| \sum_{\psi \in T} \hat f(\psi) \qquad \text{for every } f : G \to \mathbb{C}.$$

**Lemma 3.4 (Dirac test).** If $(S,T)$ is a Poisson pair, then for every $y \in G$,
$$N \cdot \mathbf 1_S(y) = |S| \sum_{\psi \in T}\psi(y).$$

*Proof.* Apply the definition to $f = \delta_y$: the left side becomes $N \mathbf 1_S(y)$ and the right side $|S|\sum_{\psi\in T}\overline{\psi(y)}$; conjugating the resulting scalar identity (its left side is real) gives the claim. $\square$

**Lemma 3.5.** If $(S,T)$ is a Poisson pair with $S \ne \emptyset$, then $0 \in S$ and $|S| \cdot |T| = N$.

*Proof.* Take $y = 0$ in Lemma 3.4: $\sum_{\psi \in T}\psi(0) = |T|$, so $N \mathbf 1_S(0) = |S| \, |T|$. If $0 \notin S$ then $|S| \, |T| = 0$, so $T = \emptyset$; but then Lemma 3.4 gives $N\mathbf 1_S(y) = 0$ for all $y$, contradicting $S \ne \emptyset$. Hence $0 \in S$ and $|S| \, |T| = N$. $\square$

**Definition 3.6.** For $T \subseteq \widehat G$ put ${}^{\perp}T := \{y \in G : \psi(y) = 1 \ \forall \psi \in T\}$, the **pre-annihilator**. It is a subgroup of $G$, being the intersection of the kernels of the $\psi \in T$.

**Theorem 3.7 (Theorem 1; rigidity of Poisson summation).** Let $(S,T)$ be a Poisson pair with $S$ nonempty. Then $S = {}^{\perp}T$ is a subgroup of $G$ and $T = S^{\perp}$.

*Proof.* By Lemma 3.5, $N = |S| \, |T|$, so Lemma 3.4 reads
$$\sum_{\psi \in T}\psi(y) = |T| \cdot \mathbf 1_S(y), \qquad y \in G. \tag{$\ast$}$$
If $y \in S$, the left side of $(\ast)$ is a sum of $|T|$ unit-modulus numbers equal to $|T|$; by Lemma 3.1 every $\psi \in T$ has $\psi(y) = 1$, i.e. $y \in {}^{\perp}T$. Conversely if $y \in {}^{\perp}T$, the left side of $(\ast)$ equals $|T| > 0$, so $\mathbf 1_S(y) = 1$, i.e. $y \in S$. Hence $S = {}^{\perp}T$, a subgroup. Now each $\psi \in T$ is trivial on $S$, so $T \subseteq S^{\perp}$; and $|S^{\perp}| = N/|S| = |T|$ by the annihilator count (Proposition 3.9 below), so $T = S^{\perp}$. $\square$

**Corollary 3.8 (Poisson summation is a finite test).** If the Poisson identity for $(S,T)$ holds for the $N$ Dirac functions $\delta_y$, $y \in G$, then it holds for every $f$, and hence the conclusion of Theorem 3.7 applies. *Proof:* both sides of the identity are $\mathbb{C}$-linear in $f$, and the $\delta_y$ span $\mathbb{C}^G$. $\square$

Thus the entire structure theorem is forced by $N$ scalar equations — a genuinely finite certificate.

**Proposition 3.9 (Annihilator count).** For $H \le G$, $\widehat{\mathbf 1_H} = |H| \cdot \mathbf 1_{H^{\perp}}$ and $|H| \cdot |H^{\perp}| = N$.

*Proof.* The first assertion is character orthogonality applied to $-\psi$ (note $\overline{\psi(x)} = (-\psi)(x)$, and $-\psi \in H^\perp \iff \psi \in H^{\perp}$). For the second, Plancherel applied to $\mathbf 1_H$ gives $|H^{\perp}| \cdot |H|^2 = N|H|$, and $|H| > 0$. $\square$

Note that this derives the index formula $|H^\perp| = [G:H]$ from Plancherel rather than from Pontryagin duality of the quotient — a self-contained route.

### 3.3 The equality analysis behind the uncertainty principle

**Theorem 3.10 (Flatness and alignment).** Let $f \ne 0$ be extremal. Then there is $M > 0$ with

1. *(flatness)* $|f(x)| = M$ for all $x \in \operatorname{supp} f$; and
2. *(alignment)* for every $\psi \in \operatorname{supp}\hat f$, the quantity $\overline{\psi(x)} f(x)$ is the same for all $x \in \operatorname{supp} f$.

*Proof.* Let $M := \max_x |f(x)|$, attained at $m$, and $\Sigma := \sum_{x \in \operatorname{supp} f}|f(x)|$. Three bounds:

* $(\mathrm i)$ $\Sigma \le |\operatorname{supp} f| \cdot M$;
* $(\mathrm{ii})$ $|\hat f(\psi)| = \bigl|\sum_{x \in \operatorname{supp} f}\overline{\psi(x)}f(x)\bigr| \le \Sigma$ for every $\psi$, since $|\psi(x)|=1$;
* $(\mathrm{iii})$ inversion at $m$, restricted to $\operatorname{supp}\hat f$, gives
  $N M = \bigl|\sum_{\psi \in \operatorname{supp}\hat f}\psi(m)\hat f(\psi)\bigr| \le \sum_{\psi\in\operatorname{supp}\hat f}|\hat f(\psi)|$.

Combining, $N M \le \sum_{\psi \in \operatorname{supp}\hat f} |\hat f(\psi)| \le |\operatorname{supp}\hat f| \cdot \Sigma \le |\operatorname{supp}\hat f|\cdot|\operatorname{supp} f| \cdot M = NM$ by extremality. Hence all inequalities are equalities. Equality in $(\mathrm i)$ forces $|f(x)| = M$ on $\operatorname{supp} f$, which is (1). Equality in the middle forces $|\hat f(\psi)| = \Sigma = |\operatorname{supp} f| \cdot M$ for every $\psi \in \operatorname{supp}\hat f$; for such $\psi$ the sum $\sum_{x \in \operatorname{supp} f}\overline{\psi(x)}f(x)$ consists of $|\operatorname{supp} f|$ terms of modulus $M$ and has modulus $|\operatorname{supp} f| \cdot M$, so Lemma 3.2 makes all terms equal, which is (2). $\square$

### 3.4 The structure theorem

**Definition 3.11.** For $\psi, \chi \in \widehat G$, the *equalizer* $E(\psi,\chi) := \{g \in G : \psi(g) = \chi(g)\}$ is a subgroup of $G$.

**Theorem 3.12 (Theorem 2; classification of extremals).** Let $f : G \to \mathbb{C}$ be nonzero. Then $f$ is extremal if and only if there are $K \le G$, $\chi \in \widehat G$, $a \in G$ and $c \ne 0$ with
$$f(x) = \begin{cases} c\,\chi(x), & x - a \in K,\\ 0, & x - a \notin K.\end{cases}$$

*Proof.* ($\Leftarrow$) Such an $f$ equals $c\,M_\chi T_a \mathbf 1_K$; by Proposition 3.9, $\mathbf 1_K$ is extremal, and by Corollary 2.4 extremality survives the three symmetries.

($\Rightarrow$) Let $M$, flatness and alignment be as in Theorem 3.10. Pick $a \in \operatorname{supp} f$ and $\psi_0 \in \operatorname{supp}\hat f$ (both supports are nonempty: $f \ne 0$, and $\hat f \ne 0$ since the transform is injective).

*Step 1 (values are prescribed by any surviving frequency).* Fix $\psi \in \operatorname{supp}\hat f$ and $x \in \operatorname{supp} f$. Alignment gives $\overline{\psi(x)}f(x) = \overline{\psi(a)}f(a)$. Multiplying by $\psi(x)$ and using $\psi(x)\overline{\psi(x)} = 1$, $\overline{\psi(a)} = \psi(a)^{-1}$ and $\psi(x)\psi(a)^{-1} = \psi(x-a)$, we get
$$f(x) = \psi(x-a)\,f(a). \tag{3.1}$$

*Step 2 (all surviving frequencies agree on a subgroup).* Let
$$K := \langle \, x - a \ : \ x \in \operatorname{supp} f \, \rangle \le G .$$
For $\psi \in \operatorname{supp}\hat f$ and $x \in \operatorname{supp} f$, comparing (3.1) for $\psi$ and for $\psi_0$ and cancelling $f(a) \ne 0$ gives $\psi(x-a) = \psi_0(x-a)$. Thus the generators of $K$ lie in the subgroup $E(\psi,\psi_0)$, so $K \le E(\psi,\psi_0)$: every $\psi \in \operatorname{supp}\hat f$ agrees with $\psi_0$ on all of $K$.

*Step 3 (two inclusions).* By construction $\operatorname{supp} f \subseteq a + K$, so $|\operatorname{supp} f| \le |K|$. By Step 2, the map $\psi \mapsto \psi - \psi_0$ sends $\operatorname{supp}\hat f$ injectively into $K^{\perp}$, so $|\operatorname{supp}\hat f| \le |K^{\perp}|$.

*Step 4 (the squeeze).* Multiplying the two inequalities and using extremality and Proposition 3.9,
$$N = |\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \le |K| \cdot |K^{\perp}| = N,$$
so both inequalities are equalities. In particular $|\operatorname{supp} f| = |K|$, and combined with $\operatorname{supp} f \subseteq a+K$ this gives $\operatorname{supp} f = a + K$ exactly.

*Step 5 (reading off).* Put $c := f(a)\,\overline{\psi_0(a)} \ne 0$ and $\chi := \psi_0$. For $x - a \in K$, (3.1) with $\psi_0$ gives $f(x) = \psi_0(x-a)f(a) = \psi_0(x)\psi_0(a)^{-1}f(a) = c\,\chi(x)$; for $x - a \notin K$, $x \notin \operatorname{supp} f$, so $f(x) = 0$. $\square$

**Corollary 3.13.** The support of an extremal function is a coset of a subgroup; the frequency support is a coset of the annihilator of that subgroup. Consequently $\operatorname{supp} f$ is closed under the *parallelogram operation* $(x,y,z)\mapsto x - y + z$.

**Corollary 3.14 (Prime order rigidity).** If $|G| = p$ is prime and $f \ne 0$ is extremal, then either $f = c\,\delta_a$ for some $a \in G$, $c \ne 0$, or $f = c\,\chi$ for some character $\chi$ and $c \ne 0$.

*Proof.* A group of prime order has only the trivial subgroups; take $K = \{0\}$ and $K = G$ in Theorem 3.12. $\square$

---

## 4. Uniqueness and the combinatorial description of $K$

**Proposition 4.1 (Uniqueness of the subgroup).** Suppose a nonempty $S \subseteq G$ satisfies $S = a_1 + K_1 = a_2 + K_2$ for subgroups $K_1, K_2$ and elements $a_1, a_2$. Then $K_1 = K_2$ and $a_1 - a_2 \in K_1$.

*Proof.* Both descriptions give $S - S = K_1 = K_2$ (see Proposition 4.2), and $a_1 \in S = a_2 + K_2$. $\square$

**Proposition 4.2 (The subgroup is the difference set).** If $S = a + K$ for a subgroup $K$, then $K = S - S := \{x - y : x, y \in S\}$.

*Proof.* $(a+k) - (a+k') = k - k' \in K$, so $S - S \subseteq K$; conversely $k = (a+k) - a \in S - S$. $\square$

**Corollary 4.3.** For an extremal $f \ne 0$, the subgroup appearing in Theorem 3.12 is uniquely determined and equals $\operatorname{supp} f - \operatorname{supp} f$ — a purely combinatorial description of an object introduced analytically.

This is a useful sanity check in practice: to test extremality of a candidate one may compute the difference set of its support and verify that it has the same cardinality as the support (Section 9).

---

## 5. Arithmetic of the extremal class

### 5.1 Lagrange rigidity and the uncertainty gap

**Theorem 5.1 (Lagrange rigidity).** Let $f \ne 0$ be extremal. Then $|\operatorname{supp} f|$ divides $N$, $|\operatorname{supp} \hat f|$ divides $N$, and
$$|\operatorname{supp}\hat f| = \frac{N}{|\operatorname{supp} f|}.$$

*Proof.* By Theorem 3.12 and Corollary 4.3, $\operatorname{supp} f$ is a coset of a subgroup $K$, hence $|\operatorname{supp} f| = |K|$ divides $N$ by Lagrange's theorem. The rest is extremality. $\square$

**Theorem 5.2 (Uncertainty gap).** Let $f \ne 0$ and set $s := |\operatorname{supp} f|$. If $s \nmid N$, then
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \;\ge\; N + \bigl(s - (N \bmod s)\bigr) \;\ge\; N+1,$$
equivalently $|\operatorname{supp}\hat f| \ge \lceil N/s\rceil$.

*Proof.* Write $N = s q + r$ with $0 < r < s$ (using $s \nmid N$). Donoho–Stark gives $s\,t \ge N$ with $t := |\operatorname{supp}\hat f|$, hence $t \ge q+1$ (if $t \le q$ then $st \le sq < N$). Therefore $st \ge s(q+1) = sq + s = N - r + s$. $\square$

**Corollary 5.3 (Prime gap).** If $|G| = p$ is prime and $f \ne 0$ has $1 < |\operatorname{supp} f| < p$, then $|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \ge p+1$.

### 5.2 The extremal spectrum

**Definition 5.4.** The **extremal spectrum** of $G$ is
$$\operatorname{Spec}(G) := \{\, d \in \mathbb{N} : \exists f \ne 0 \text{ extremal with } |\operatorname{supp} f| = d \,\}.$$

**Proposition 5.5.** $\operatorname{Spec}(G)$ is exactly the set of subgroup orders of $G$.

*Proof.* If $f$ is extremal, $|\operatorname{supp} f| = |K|$ for a subgroup $K$ by Corollary 4.3. Conversely $\mathbf 1_K$ is extremal with support $K$. $\square$

The remaining input is purely group-theoretic and, notably, false for nonabelian groups.

**Theorem 5.6 (Converse of Lagrange for finite abelian groups).** Let $A$ be a finite abelian group and $d \mid |A|$. Then $A$ has a subgroup of order $d$.

*Proof sketch.* Induct on $|A|$. If $d = 1$ take the trivial subgroup. Otherwise pick a prime $p \mid d$; then $p \mid |A|$, so by Cauchy's theorem $A$ has an element of order $p$, generating a subgroup $C$ of order $p$. In $A/C$, of order $|A|/p$, the number $d/p$ is a divisor, so by induction there is a subgroup $\bar B \le A/C$ of order $d/p$. Its preimage $B$ under the quotient map is a subgroup of $A$ with $|B| = p \cdot (d/p) = d$. $\square$

(For general finite groups this fails: $|A_5| = 60$ but $A_5$ has no subgroup of order $30$.)

**Theorem 5.7 (Theorem 3; extremal spectrum theorem).** For any finite abelian $G$ and $d \in \mathbb{N}$,
$$d \in \operatorname{Spec}(G) \iff d \mid N.$$
Dually, $d$ occurs as $|\operatorname{supp}\hat f|$ for an extremal $f$ if and only if $d \mid N$; and $(s,t)$ occurs as $(|\operatorname{supp} f|, |\operatorname{supp}\hat f|)$ if and only if $st = N$.

*Proof.* Proposition 5.5 plus Lagrange's theorem gives $\Rightarrow$; Proposition 5.5 plus Theorem 5.6 gives $\Leftarrow$. For the pair statement, given $st = N$ take an extremal with support size $s$; its frequency support then has size $N/s = t$ by Theorem 5.1. $\square$

**Theorem 5.8 (Primality is visible in the extremal class).** $N$ is prime if and only if $N > 1$ and every nonzero extremal $f$ on $G$ has $|\operatorname{supp} f| \in \{1, N\}$.

*Proof.* ($\Rightarrow$) Lagrange rigidity: the support size divides a prime. ($\Leftarrow$) Let $d \mid N$. By Theorem 5.7 there is an extremal with support size $d$, so $d \in \{1, N\}$; with $N>1$ this is primality. $\square$

**Theorem 5.9 (Reconstruction, and its ceiling).** Let $G, G'$ be finite abelian. Then $\operatorname{Spec}(G) = \operatorname{Spec}(G')$ if and only if $|G| = |G'|$.

*Proof.* By Theorem 5.7, $\operatorname{Spec}(G)$ is the divisor set of $|G|$; a positive integer is the maximum of its divisor set, and divisor sets determine (and are determined by) the integer. $\square$

So the spectrum is a complete invariant of the *order* and of nothing more: no finer invariant (exponent, number of invariant factors, rank) can be read off from support sizes alone. The *supports* themselves are strictly finer.

**Theorem 5.10 (Supports of extremals are exactly the cosets).** A nonempty $S \subseteq G$ equals $\operatorname{supp} f$ for some extremal $f$ if and only if $S$ is a coset of a subgroup, equivalently if and only if $S$ is closed under the parallelogram operation $(x,y,z)\mapsto x-y+z$.

*Proof.* Necessity is Corollary 3.13, sufficiency is Theorem 3.12 applied to $T_a\mathbf 1_K$. For the combinatorial criterion: a coset is clearly parallelogram-closed; conversely, suppose $S \ne \emptyset$ is parallelogram-closed and fix $a \in S$, setting $K := S - a$. Then $0 = a - a \in K$. For $x, y \in S$ the element $x - a + y$ lies in $S$, so $(x-a)+(y-a) = (x-a+y)-a \in K$: closure under addition. And $a - x + a \in S$, so $-(x-a) = (a-x+a)-a \in K$: closure under negation. Hence $K$ is a subgroup and $S = a + K$. $\square$

Because parallelogram-closure is a decidable finite condition, this yields an effective test (Section 9, Algorithm 3).

**Example 5.11 (The two groups of order four).** $\mathbb{Z}/4$ and $\mathbb{Z}/2\times\mathbb{Z}/2$ have the same extremal spectrum $\{1,2,4\}$. But $\mathbb{Z}/4$ has a single subgroup of order $2$ and hence exactly $2$ extremal supports of size $2$, while the Klein group has three subgroups of order $2$ and hence exactly $6$. An exhaustive enumeration confirms these counts, and therefore the family of extremal supports separates the two groups while the spectrum does not.

---

## 6. The extremal class is an algebra

Extremality is an analytic condition, but Theorem 3.12 converts it into membership in a set of algebraically defined functions, and that set turns out to be closed under the natural operations.

**Lemma 6.1 (Transform of a coset modulation).** For $K \le G$, $c \ne 0$, $\chi \in \widehat G$, $a \in G$ and $f = c\,M_\chi T_a \mathbf 1_K$,
$$\hat f(\psi) = \begin{cases} c\;\overline{(\psi-\chi)(a)}\;|K|, & \psi - \chi \in K^{\perp},\\ 0, & \text{otherwise.}\end{cases}$$

*Proof.* Combine Lemma 2.3 with Proposition 3.9: $\hat f(\psi) = c\,\widehat{T_a \mathbf 1_K}(\psi - \chi) = c\,\overline{(\psi-\chi)(a)}\,\widehat{\mathbf 1_K}(\psi-\chi)$. $\square$

In particular the transform of a coset modulation is again a coset modulation, on the dual group, with subgroup $K^{\perp}$ and coset representative $\chi$.

**Lemma 6.2 (Intersecting cosets).** Let $K, K' \le G$ and $a, a' \in G$, and suppose $b$ lies in both cosets, i.e. $b - a \in K$ and $b - a' \in K'$. Then for all $x$,
$$\bigl(x - a \in K \ \wedge\ x - a' \in K'\bigr) \iff x - b \in K \cap K'.$$
Hence the intersection of a coset of $K$ and a coset of $K'$ is either empty or a coset of $K \cap K'$.

*Proof.* Write $x - b = (x-a)-(b-a) = (x-a')-(b-a')$ and reverse. $\square$

**Theorem 6.3 (Closure under products).** If $u, v \ne 0$ are extremal, then $uv$ is either identically zero or extremal.

*Proof.* Write $u = c\,\chi\,\mathbf 1_{a+K}$, $v = c'\chi'\mathbf 1_{a'+K'}$ by Theorem 3.12. If the two cosets are disjoint, $uv \equiv 0$. Otherwise pick $b$ in the intersection; by Lemma 6.2 the product is $cc'\,(\chi+\chi')\,\mathbf 1_{b + (K\cap K')}$, a coset modulation with nonzero scalar, hence extremal by Theorem 3.12. $\square$

This is a genuinely non-formal statement: for arbitrary functions, pointwise products destroy the support structure entirely.

**Theorem 6.4 (Closure under convolution).** If $u, v \ne 0$ are extremal, then $u * v$ is either identically zero or extremal.

*Proof sketch.* Here the support of the product is not determined pointwise, so one squeezes from both sides. On the frequency side, $\widehat{u*v} = \hat u \hat v$, and by Lemma 6.1 each factor is supported on a coset of an annihilator; by Lemma 6.2 (in the dual) the frequency support of $u * v$ is empty or a coset of $K^{\perp} \cap K'^{\perp} = (K + K')^{\perp}$, giving $|\operatorname{supp}\widehat{u*v}| \le |(K+K')^{\perp}|$. On the space side, $\operatorname{supp}(u*v) \subseteq (a+a') + (K + K')$, giving $|\operatorname{supp}(u*v)| \le |K+K'|$. Their product is $|K+K'| \cdot |(K+K')^{\perp}| = N$ by Proposition 3.9, while Donoho–Stark forces the product of the two actual support sizes to be at least $N$. Hence equality throughout, i.e. $u*v$ is extremal (unless it vanishes). $\square$

**Theorem 6.5 (Convolution powers).** Define $f^{*0} := \delta_0$ and $f^{*(k+1)} := f * f^{*k}$. If $f \ne 0$ then $f^{*k} \ne 0$ for all $k$, since $\widehat{f^{*k}} = (\hat f)^k$ is nonzero wherever $\hat f$ is. If moreover $f$ is extremal, then $f^{*k}$ is extremal for every $k \ge 1$, and $|\operatorname{supp} f^{*k}| = |\operatorname{supp} f|$.

*Proof.* Nonvanishing and extremality follow from Theorem 6.4 by induction. For the invariance, $\operatorname{supp}\widehat{f^{*k}} = \operatorname{supp}(\hat f)^k = \operatorname{supp}\hat f$, so the frequency support size is constant along the dynamics, and extremality then pins the space support size. $\square$

Thus the support size is a conserved quantity of the convolution dynamics on the extremal class: convolution moves the coset representative and the character but never the "size scale".

**Theorem 6.6 (Fourier invariance).** If $f$ is extremal on $G$, then $\hat f$ is extremal on $\widehat G$:
$$|\operatorname{supp}\hat f| \cdot |\operatorname{supp}\widehat{\hat f}| = |\widehat G| = N.$$

*Proof.* The double transform satisfies $\widehat{\hat f} = N \cdot f \circ (-\mathrm{id})$ up to the identification $\widehat{\widehat G}\cong G$, so $|\operatorname{supp}\widehat{\hat f}| = |\operatorname{supp} f|$; combine with $|\widehat G| = N$. $\square$

Summarising Sections 3 and 6: the extremal class is a groupoid of coset modulations, indexed by (subgroup, coset representative, character, scalar), stable under pointwise multiplication (meet of subgroups), convolution (join of subgroups), and the Fourier transform (annihilation).

---

## 7. The two rigidities are one

**Theorem 7.1.** Let $(S,T)$ be a Poisson pair with $S$ nonempty. Then $S = \operatorname{supp} f$ and $T = \operatorname{supp}\hat f$ for the extremal function $f = \mathbf 1_S$; the subgroup witnessing the pair is unique; and $|S| \mid N$.

*Proof.* By Theorem 3.7, $S$ is a subgroup $H$ and $T = H^{\perp}$. Proposition 3.9 gives $\operatorname{supp}\widehat{\mathbf 1_H} = H^{\perp}$ and extremality of $\mathbf 1_H$; uniqueness is Proposition 4.1; divisibility is Lagrange. $\square$

**Theorem 7.2 (Poisson spectrum).** A natural number $d$ is the size of a nonempty set carrying a Poisson summation formula on $G$ if and only if $d \mid N$.

*Proof.* Necessity is Theorem 7.1; sufficiency is Theorem 5.6 plus Fact B for the resulting subgroup. $\square$

So Poisson pairs on $G$ are indexed exactly by the subgroups of $G$; the extremal functions are indexed by (subgroup, coset, character, scalar); and the map "extremal $f$ $\mapsto$ support pair" carries the latter onto the former. Two apparently different rigidity phenomena — one about an identity holding for *all* test functions, one about a *single* numerical equality for one function — are two descriptions of the subgroup lattice.

---

## 8. Extremal probability distributions

**Theorem 8.1 (Theorem 4).** Let $p : G \to \mathbb{R}$ satisfy $p \ge 0$ and $\sum_{x} p(x) = 1$, and suppose the complex-valued function $x \mapsto p(x)$ is extremal. Then there are $a \in G$ and $K \le G$ such that
$$p(x) = \begin{cases} 1/|K|, & x \in a + K,\\ 0, & \text{otherwise.}\end{cases}$$

*Proof.* $p \ne 0$ since it sums to $1$. By Theorem 3.12, $p = c\,\chi\,\mathbf 1_{a+K}$ with $c \ne 0$. Since $|\chi(x)| = 1$, flatness gives $|p(x)| = |c|$ on the support, and $p \ge 0$ upgrades this to $p(x) = |c|$ there. Summing, $|a+K| \cdot |c| = 1$, so $|c| = 1/|K|$. $\square$

**Corollary 8.2.** The minimum-uncertainty distributions on $G$ are exactly the uniform distributions on cosets of subgroups. Their supports have size dividing $N$; in particular, on a group of prime order the only minimum-uncertainty distributions are the point masses and the uniform distribution on $G$.

This is a striking dichotomy for a probabilist: the analytically defined class of "maximally concentrated in both domains" distributions turns out to have no free parameters beyond a subgroup and a translate. Any attempt to design a distribution with, say, $5$ atoms on $\mathbb{Z}/12$ that is optimally frequency-concentrated is doomed by arithmetic, not by analysis: $5 \nmid 12$, and Theorem 5.2 quantifies the loss.

---

## 9. Algorithms

Let $G = \mathbb{Z}/n_1 \times \cdots \times \mathbb{Z}/n_r$ with $N = \prod n_i$. Characters are indexed by $k \in G$ via $\psi_k(x) = \exp\bigl(2\pi i \sum_j k_j x_j / n_j\bigr)$.

**Algorithm 1 (Uncertainty audit).** Given $f$, compute $\hat f$ by the defining sum in $O(N^2)$ operations (or by mixed-radix FFT in $O(N \log N)$), count the two supports with a numerical tolerance, and report the product against $N$. Output: the product, the extremality flag, and — if extremal — the reconstructed data $(K, a, \chi, c)$.

**Algorithm 2 (Structure extraction).** Given an extremal $f$: set $S := \operatorname{supp} f$, choose $a \in S$, and put $K := S - a$ (a subgroup by Theorem 3.12). Recover $c\chi$ by $\chi(x) := f(x)/f(a) \cdot \chi(a)$; concretely, $f(x)/f(a) = \chi(x - a)$ determines $\chi$ on $K$, and any extension to $G$ (there are $|K^\perp|$, matching the frequency support) works. Complexity $O(|S|)$ after the transform.

**Algorithm 3 (Coset test by parallelogram closure).** Given nonempty $S$, fix $a \in S$ and check that $S - a$ is closed under addition and negation; equivalently check $x - y + z \in S$ for all $x,y,z \in S$. This is $O(|S|^2)$ (build $S - a$ and test closure) and decides, by Theorem 5.10, whether $S$ is the support of an extremal function.

**Algorithm 4 (Poisson pair verification).** Given $(S,T)$, verify only the $N$ Dirac identities $N\mathbf 1_S(y) = |S|\sum_{\psi \in T}\psi(y)$, $y \in G$. By Corollary 3.8 this certifies the identity for all test functions; complexity $O(N|T|)$.

**Algorithm 5 (Extremal spectrum).** By Theorem 5.7, enumerate the divisors of $N$ — $O(\sqrt N)$ — to obtain all achievable support sizes; to obtain all extremal *supports* of a given size $d$, enumerate subgroups of order $d$ and their cosets.

---

## 10. Computational evidence

An exhaustive check on $G = \mathbb{Z}/4$ is small enough to be carried out in exact arithmetic: all characters take values in $\{1, i, -1, -i\}$, so with function values restricted to $\{0, 1, -1, i, -i\}$ the transform lives in the Gaussian integers and every count below is exact rather than numerical.

Enumerating all $5^4 = 625$ such functions:

| experiment | result |
|---|---|
| functions tested / nonzero | 625 / 624 |
| the bound $|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| \ge 4$ | holds in every case |
| number of extremals in the sample | 48 |
| support-size distribution of extremals (sizes $0,1,2,3,4$) | $0, 16, 16, 0, 16$ |
| every extremal support is a coset (parallelogram closure) | yes |
| every extremal has constant modulus on its support | yes |
| every extremal frequency support is a coset | yes |
| pointwise products of extremals are zero or extremal | yes |
| convolutions of extremals are zero or extremal | yes |
| the non-coset set $\{0,1\}$ as a support | not extremal ($2 \cdot 3 = 6 > 4$) |

Every entry matches the theory. The absence of extremals with support of size $3$ is Theorem 5.7: $3 \nmid 4$. The counts $16$ are also predicted exactly: for size $1$, four positions times four allowed nonzero values; for size $2$, two cosets of $\{0,2\}$ times four values times two characters modulo the annihilator; for size $4$, four characters times four values.

Section 5's separation of the two groups of order four was likewise confirmed by exhaustive enumeration: $\mathbb{Z}/4$ has exactly $2$ extremal supports of size $2$ and $\mathbb{Z}/2\times\mathbb{Z}/2$ has exactly $6$.

---

## 11. Discussion

**What the theorems buy.** The classification turns an analytic extremal problem into an arithmetic one. Questions of the form "how sparse can a signal be while having few frequencies?" become questions about the divisor lattice of $N$. On $\mathbb{Z}/p$ the extremal class is trivial (deltas and characters) and every other support size incurs a definite penalty; on $\mathbb{Z}/2^k$ the extremal class is a full chain of subgroups with plentiful worst cases. Group order, not group size, decides how badly the uncertainty principle can be saturated.

**Sharpness of the bound in signal recovery.** In compressed sensing, the uncertainty principle underlies the uniqueness of sparse representations: if $|\operatorname{supp} f| \cdot |\operatorname{supp}\hat f| < N$ for two candidate representations of the same signal, they must coincide. The extremal functions are exactly the boundary cases where such arguments become tight, and Theorem 3.12 says these boundary cases are structured — they are Dirac combs on cosets — so they can be recognised and excluded in $O(|S|^2)$ time by Algorithm 3.

**The role of the abelian hypothesis.** Two ingredients are genuinely abelian: Pontryagin duality (used through $|H|\cdot|H^{\perp}| = N$, which we obtain from Plancherel) and the converse of Lagrange's theorem (Theorem 5.6). The latter fails for nonabelian groups, so any nonabelian analogue of Theorem 5.7 must have a different shape; already for $A_5$ one would need to explain the missing "divisor" $30$.

**A remark on proof technique.** Both rigidity results are equality analyses of the triangle inequality, and both use the same lemma — unit-modulus complex numbers whose sum has maximal modulus are all equal. It is the same phenomenon that makes coherence arguments work in analysis: perfect constructive interference is a very strong constraint, and in the presence of a group action it forces homomorphy.

---

## 12. Future directions

**Beyond abelian groups.** Formulate and prove an uncertainty classification on finite nonabelian groups, where the correct notion of "support" on the dual side involves matrix coefficients and the natural extremals should be induced-from-a-subgroup constructions. Theorem 5.6 fails, so the achievable spectrum will not be the divisor set.

**Approximate rigidity.** Both theorems here are exact. The natural stability question is quantitative: if $|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f| \le (1+\varepsilon)N$, must $f$ be $\delta(\varepsilon)$-close (in a suitable norm) to a coset modulation? Section 3's equality analysis is a chain of inequalities each of which admits a stability version, so a quantitative statement should follow with explicit constants; the interesting question is the optimal dependence on $\varepsilon$ and $N$. Similarly, an approximate Poisson pair — one for which the identity holds up to $\varepsilon\|f\|_1$ — should be close to a subgroup/annihilator pair.

**Ring and module versions.** Replace $G$ by a finite module over a ring and $\widehat G$ by its Pontryagin dual; the extremal class should become the class of modulated indicators of submodules, and the spectrum should be the set of submodule orders. The interest is that this set is generally *not* the divisor set.

**Finite-test phenomena.** Corollary 3.8 says Poisson summation is determined by $N$ scalar identities. Which other functional identities in harmonic analysis are determined by finitely many test cases, and with what optimal test families? A minimal test family for the Poisson identity would be an appealing extremal combinatorial problem in its own right.

**Extremal supports as an invariant.** The family of extremal supports separates $\mathbb{Z}/4$ from $\mathbb{Z}/2 \times \mathbb{Z}/2$. Is the multiset $\{(d, \#\{\text{extremal supports of size } d\})\}_{d \mid N}$ a complete invariant of a finite abelian group? Equivalently: is a finite abelian group determined by the number of subgroups it has of each order? The question reduces, by the structure theorem, to the case of abelian $p$-groups, where the counts are governed by the partition describing the group.

**Dynamics of convolution.** Theorem 6.5 shows the support size is conserved under convolution powers of an extremal function. Describe the full orbit structure of the convolution dynamics on the extremal class: convolution acts on the parameters $(K, a, \chi, c)$ by join of subgroups, addition of representatives and addition of characters, so the dynamics is a semigroup action on the subgroup lattice — the equilibrium states and their basins are worth mapping out explicitly.
