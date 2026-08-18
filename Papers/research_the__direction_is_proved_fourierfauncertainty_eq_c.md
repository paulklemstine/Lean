# Rigidity of the Donoho–Stark Uncertainty Principle on Finite Abelian Groups

**Aristotle**

*Date: 2026-08-18*

---

## Abstract

Let $G$ be a finite abelian group of order $N$ and let $f : G \to \mathbb{C}$ be nonzero. The Donoho–Stark uncertainty principle asserts that $|\operatorname{supp} f| \cdot |\operatorname{supp}\widehat f| \ge N$. We give a complete solution of the associated extremal problem: equality holds **if and only if** $f = c\,\chi\,\mathbf{1}_{a+H}$ for some subgroup $H \le G$, character $\chi \in \widehat G$, base point $a \in G$ and scalar $c \ne 0$ — a *modulated coset indicator*. The proof is a four-stage equality analysis. Combining Plancherel with Cauchy–Schwarz shows that $|\widehat f|$ is constant on its support with value $\|f\|_1$; the equality case of the triangle inequality then forces the demodulated values $\overline{\psi(x)}f(x)$ to be positively proportional; Fourier inversion converts this into constancy of $|f|$ on $\operatorname{supp} f$; and the resulting simultaneous phase coherence across the entire spectrum produces a *phase subgroup* $H$ whose annihilator duality $|H|\cdot|H^{\perp}| = N$ closes a counting argument, pinning $\operatorname{supp} f$ to exactly one coset of $H$.

We then develop the consequences of the classification: the explicit transform of a modulated coset indicator and the self-duality of the extremal family; the sharp value distribution $|f(x)| = \|f\|_1/|\operatorname{supp} f|$; intrinsic cosetness of the support ($x,y,z \in \operatorname{supp} f \Rightarrow x - y + z \in \operatorname{supp} f$); invariance of extremality under the Fourier transform; the arithmetic obstruction $|\operatorname{supp} f| \mid N$ together with its sharpness; a prime-order dichotomy (in prime order the only extremals are scaled Dirac deltas and scaled characters); canonicity of the phase subgroup as the group of periods of the support; uniqueness of the classification data and an orbit description of the extremal set; a purely combinatorial corollary (an indicator function is extremal precisely when the set is a coset); and a discrete *gap theorem*: if $|\operatorname{supp} f|$ divides $N$ and $f$ is not a modulated coset indicator, then $|\operatorname{supp} f|\cdot|\operatorname{supp}\widehat f| \ge N + |\operatorname{supp} f|$.

Finally, we exhibit an adversarial construction showing that the two "flatness" conditions extracted from the rigidity proof do **not** characterise extremality. On the self-dual group $G = K \times \widehat K$, the evaluation pairing $f(x,\psi) = \psi(x)$ — the discrete chirp — satisfies $|f| \equiv 1$ on $G$ and $|\widehat f| \equiv |K| = \sqrt{|G|}$ on $\widehat G$, so that both moduli are constant in the strongest possible sense, yet $|\operatorname{supp} f|\cdot|\operatorname{supp}\widehat f| = |G|^2$, the maximum possible value. Rigidity is therefore a statement about *inter-spectral phase coupling*, not about magnitudes.

**Keywords.** Donoho–Stark uncertainty principle, finite abelian group, discrete Fourier transform, extremal problem, rigidity, coset, annihilator, Pontryagin duality, phase subgroup, chirp.

---

## 1. Introduction

### 1.1 The uncertainty principle in the finite setting

Uncertainty principles in harmonic analysis quantify the impossibility of a function and its Fourier transform being simultaneously concentrated. In the setting of a finite abelian group $G$ of order $N$, concentration admits the crudest and cleanest measure imaginable: the cardinality of the support. The resulting statement, due to Donoho and Stark, is that for every nonzero $f : G \to \mathbb{C}$,

$$|\operatorname{supp} f| \cdot |\operatorname{supp} \widehat f| \;\ge\; N. \tag{1.1}$$

The inequality is elementary — a two-line consequence of Plancherel's identity and the Cauchy–Schwarz inequality — but its consequences are not. It is the combinatorial heart of compressive sensing: a signal supported on $k$ points has at least $N/k$ nonzero Fourier coefficients, so a sparse signal cannot masquerade as a sparse spectrum, and undersampled recovery becomes possible. It underlies the theory of *uncertainty-based* deterministic sensing matrices, the study of Fourier-sparse Boolean functions, and quantitative forms of the hidden subgroup problem.

Equality in (1.1) is attained: for any subgroup $H \le G$, any coset $a + H$, any character $\chi$ and any $c \ne 0$, the *modulated coset indicator*

$$f(x) \;=\; \begin{cases} c\,\chi(x), & x - a \in H,\\ 0, & x - a \notin H,\end{cases}$$

has $|\operatorname{supp} f| = |H|$ and $|\operatorname{supp}\widehat f| = |H^\perp|$, and the duality $|H|\cdot|H^\perp| = N$ gives equality. This direction is a computation.

### 1.2 The result

The converse — that these are the *only* extremals — is the rigidity phenomenon we establish.

> **Main Theorem (Rigidity).** Let $G$ be a finite abelian group and let $f : G \to \mathbb{C}$. Then $|\operatorname{supp} f| \cdot |\operatorname{supp}\widehat f| = |G|$ if and only if there exist a subgroup $H \le G$, a scalar $c \ne 0$, a character $\chi \in \widehat G$ and a point $a \in G$ such that $f(x) = c\,\chi(x)$ for all $x$ with $x - a \in H$, and $f(x) = 0$ otherwise.

The interest lies less in the statement — which is folklore-adjacent — than in the *mechanism*. The proof isolates four separate rigidity phenomena, each an equality case of a standard inequality, and shows how they compose. The last of them, the appearance of a canonical subgroup out of pure phase data, is the step that carries all the arithmetic content, and it is the step that resists generalisation.

### 1.3 The adversarial companion

The first three stages of the proof yield two attractive necessary conditions: $|f|$ is constant on $\operatorname{supp} f$, and $|\widehat f|$ is constant on $\operatorname{supp}\widehat f$. It is natural to conjecture that these *bi-flatness* conditions are sufficient. We refute this in every nontrivial case by an explicit construction (Section 7): the discrete chirp on a self-dual group is bi-flat in the strongest sense yet maximally non-extremal. The counterexample locates precisely where the content of the theorem lives.

### 1.4 Organisation

Section 2 fixes notation and records the Fourier-analytic background. Section 3 proves the easy direction and computes transforms of modulated coset indicators explicitly. Section 4 carries out the four-stage equality analysis and proves the Main Theorem. Section 5 derives structural consequences (self-duality, canonicity, uniqueness, orbit structure). Section 6 derives arithmetic consequences (divisibility, sharpness, prime dichotomy, the gap theorem, the combinatorial corollary). Section 7 presents the bi-flat counterexample. Section 8 discusses applications and Section 9 states open problems.

---

## 2. Setting and notation

### 2.1 Groups, characters, duality

Throughout, $G$ denotes a finite abelian group written additively, with $N := |G| \ge 1$.

**Definition 2.1 (Character).** A *character* of $G$ is a map $\psi : G \to \mathbb{C}^{\times}$ with $\psi(x+y) = \psi(x)\psi(y)$ for all $x, y$. Since $G$ is finite, every value $\psi(x)$ is a root of unity; in particular $|\psi(x)| = 1$ and $\psi(-x) = \overline{\psi(x)} = \psi(x)^{-1}$.

The characters form an abelian group $\widehat G$ under pointwise multiplication, written additively: $(\psi + \chi)(x) = \psi(x)\chi(x)$, with identity the trivial character $0 : x \mapsto 1$, and $(\psi - \chi)(x) = \psi(x)\overline{\chi(x)}$.

**Fact 2.2 (Pontryagin duality).** $|\widehat G| = |G|$, and the *double-dual embedding* $G \to \widehat{\widehat G}$, sending $x$ to the evaluation character $\psi \mapsto \psi(x)$, is a group isomorphism.

**Fact 2.3 (Orthogonality).** For $x \in G$,
$$\sum_{\psi \in \widehat G} \psi(x) \;=\; \begin{cases} N, & x = 0,\\ 0, & x \ne 0,\end{cases}$$
and dually $\sum_{x \in G} \psi(x) = N$ if $\psi = 0$ and $0$ otherwise. Equivalently, for $x, z \in G$, $\sum_{\psi} \psi(x)\overline{\psi(z)} = N\,[x=z]$.

**Definition 2.4 (Annihilator).** For a subgroup $H \le G$, the *annihilator* is
$$H^{\perp} \;=\; \{\psi \in \widehat G : \psi(h) = 1 \text{ for all } h \in H\} \;\le\; \widehat G .$$

**Fact 2.5 (Subgroup duality).** $|H| \cdot |H^{\perp}| = N$. Indeed $H^{\perp}$ is canonically isomorphic to the dual of the quotient $G/H$, whose order is $N/|H|$.

Fact 2.5 is the arithmetic engine of the entire paper.

### 2.2 The transform

**Definition 2.6 (Fourier transform).** For $f : G \to \mathbb{C}$ set
$$\widehat f(\psi) \;:=\; \sum_{x \in G} \overline{\psi(x)}\, f(x), \qquad \psi \in \widehat G .$$

We use the unnormalised convention, so that:

**Fact 2.7 (Inversion).** $\displaystyle f(x) = \frac{1}{N}\sum_{\psi \in \widehat G} \psi(x)\,\widehat f(\psi)$ for all $x$; equivalently $N f(x) = \sum_{\psi} \psi(x)\widehat f(\psi)$. In particular the transform is injective. Iterating, $\widehat{\widehat f}\,(\iota(x)) = N f(-x)$, where $\iota : G \to \widehat{\widehat G}$ is the double-dual embedding.

**Fact 2.8 (Plancherel).** $\displaystyle \sum_{\psi \in \widehat G} |\widehat f(\psi)|^2 = N \sum_{x \in G} |f(x)|^2 .$

**Definition 2.9 (Supports and norms).** $\operatorname{supp} f := \{x \in G : f(x) \ne 0\}$, and analogously $\operatorname{supp}\widehat f \subseteq \widehat G$. We write
$$\|f\|_1 = \sum_{x \in \operatorname{supp} f} |f(x)| = \sum_{x \in G}|f(x)|, \qquad \|f\|_2^2 = \sum_{x \in G} |f(x)|^2 .$$

**Definition 2.10 (Extremality).** $f : G \to \mathbb{C}$ is *extremal* if
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\widehat f| \;=\; N .$$

Note that an extremal function is automatically nonzero: if $f = 0$ then both supports are empty and the product is $0 \ne N$.

**Definition 2.11 (Modulated coset indicator).** $f$ *is a modulated coset indicator* if there exist $H \le G$, $c \in \mathbb{C}\setminus\{0\}$, $\chi \in \widehat G$ and $a \in G$ with
$$f(x) = c\,\chi(x) \text{ whenever } x - a \in H, \qquad f(x) = 0 \text{ whenever } x - a \notin H .$$
We abbreviate this as $f = c\,\chi\,\mathbf{1}_{a+H}$.

---

## 3. The easy direction, made explicit

**Theorem 3.1 (Transform of a modulated coset indicator).** Let $H \le G$, $c \in \mathbb{C}$, $\chi \in \widehat G$, $a \in G$ and put $f = c\,\chi\,\mathbf{1}_{a+H}$. Then for every $\psi \in \widehat G$,
$$\widehat f(\psi) \;=\; c\,\overline{(\psi - \chi)(a)} \cdot \begin{cases} |H|, & \psi - \chi \in H^{\perp},\\ 0, & \psi - \chi \notin H^{\perp}. \end{cases}$$

*Proof sketch.* The transform intertwines the three elementary operations. Scaling: $\widehat{cf} = c\widehat f$. Modulation by $\chi$: $\widehat{\chi f}(\psi) = \widehat f(\psi - \chi)$. Translation by $a$: $\widehat{f(\cdot - a)}(\psi) = \overline{\psi(a)}\widehat f(\psi)$. It therefore suffices to transform the plain subgroup indicator $\mathbf{1}_H$, and orthogonality on $H$ gives
$$\widehat{\mathbf{1}_H}(\psi) = \sum_{h \in H}\overline{\psi(h)} = |H|\,[\psi \in H^{\perp}] ,$$
because the restriction $\psi|_H$ is a character of $H$, which is trivial exactly when $\psi \in H^\perp$ and otherwise sums to zero. Assembling the three operations yields the stated formula. $\square$

**Corollary 3.2 (Spectrum of an extremal, explicitly).** If $c \ne 0$ then
$$\operatorname{supp}\widehat f \;=\; \chi + H^{\perp}.$$
The extremal picture is thus *self-dual in form*: a modulated coset indicator supported on the coset $a + H$ has a transform which is a modulated coset indicator supported on the coset $\chi + H^{\perp}$.

*Proof.* Each factor in Theorem 3.1 is nonzero exactly when $\psi - \chi \in H^\perp$: $c \ne 0$ by hypothesis, $\overline{(\psi-\chi)(a)}$ is unimodular hence nonzero, and $|H| \ge 1$. $\square$

**Corollary 3.3 (Easy direction).** Every modulated coset indicator with $c\neq 0$ is extremal.

*Proof.* $|\operatorname{supp} f| = |a + H| = |H|$ and $|\operatorname{supp}\widehat f| = |\chi + H^{\perp}| = |H^{\perp}|$, and $|H| \cdot |H^{\perp}| = N$ by Fact 2.5. $\square$

---

## 4. Rigidity: the four-stage equality analysis

We now prove the converse. Fix a nonzero $f$ and abbreviate $S = \operatorname{supp} f$, $A = \operatorname{supp}\widehat f$.

Two preliminary observations. First, since $f$ vanishes off $S$,
$$\widehat f(\psi) = \sum_{x \in S} \overline{\psi(x)} f(x), \tag{4.1}$$
whence by the triangle inequality and unimodularity of characters
$$|\widehat f(\psi)| \;\le\; \sum_{x \in S} |f(x)| \;=\; \|f\|_1 \qquad \text{for all } \psi. \tag{4.2}$$
Second, $f \neq 0 \Rightarrow \|f\|_1 > 0$, and by injectivity of the transform $\widehat f \ne 0$, so both $S$ and $A$ are nonempty.

### 4.1 Stage 1: the spectrum is flat

**Theorem 4.1 (Flat spectrum).** If $f$ is extremal, then $|\widehat f(\psi)| = \|f\|_1$ for every $\psi \in A$.

*Proof sketch.* Restrict Plancherel to the spectrum (the omitted terms vanish):
$$\sum_{\psi \in A} |\widehat f(\psi)|^2 \;=\; N \|f\|_2^2 . \tag{4.3}$$
Bounding each term by (4.2),
$$N\|f\|_2^2 \;\le\; |A| \cdot \|f\|_1^2 . \tag{4.4}$$
Cauchy–Schwarz on the support, $\big(\sum_{x\in S} 1\cdot |f(x)|\big)^2 \le |S| \sum_{x \in S}|f(x)|^2$, gives
$$\|f\|_1^2 \;\le\; |S| \cdot \|f\|_2^2 . \tag{4.5}$$
Chaining (4.4) and (4.5) yields $N\|f\|_2^2 \le |A|\,|S|\,\|f\|_2^2$, which is the uncertainty principle (1.1). Under extremality $|S|\,|A| = N$, so both (4.4) and (4.5) are equalities. Equality in (4.4) means every term of the sum $\sum_{\psi \in A}|\widehat f(\psi)|^2$ attains its upper bound $\|f\|_1^2$; since $|A| \ge 1$ and all terms are bounded above by the same constant, term-by-term equality follows. $\square$

Two remarks. Equality in (4.5) will be used again in Stage 3, where it independently gives constancy of $|f|$ on $S$; and Theorem 4.1 already yields the first flatness statement: $|\widehat f|$ is constant on $\operatorname{supp}\widehat f$.

### 4.2 Stage 2: phase alignment

The equality case of the triangle inequality for complex sums is the following division-free statement, which we isolate because it is what makes the argument robust (no summand needs to be nonzero, and no normalisation is required).

**Lemma 4.2 (Equality in the triangle inequality).** Let $z : I \to \mathbb{C}$ be a finite family with $\big|\sum_{j} z_j\big| = \sum_j |z_j|$, and write $T = \sum_j z_j$. Then for every $i$,
$$|T| \cdot z_i \;=\; |z_i| \cdot T .$$

*Proof sketch.* If $T = 0$ then $\sum_j |z_j| = 0$, so every $z_j = 0$ and both sides vanish. Otherwise set $w = \overline{T}/|T|$, a unimodular number with $wT = |T|$. For each $j$, $\operatorname{Re}(w z_j) \le |wz_j| = |z_j|$, while summing gives $\sum_j \operatorname{Re}(wz_j) = \operatorname{Re}(wT) = |T| = \sum_j |z_j|$. A sum of termwise inequalities that is an equality is an equality termwise, so $\operatorname{Re}(wz_i) = |wz_i|$ for each $i$; and a complex number whose real part equals its modulus is that nonnegative real, so $wz_i = |z_i|$. Multiplying by $T$ and using $wT = |T|$ gives $|T| z_i = |z_i| T$. $\square$

**Theorem 4.3 (Phase alignment).** Let $f$ be extremal, $\psi \in A$ and $x \in S$. Then
$$\|f\|_1 \cdot \overline{\psi(x)}f(x) \;=\; |f(x)| \cdot \widehat f(\psi) .$$

*Proof sketch.* Apply Lemma 4.2 to the family $z_x = \overline{\psi(x)}f(x)$, $x \in S$, whose sum is $\widehat f(\psi)$ by (4.1) and whose absolute values are $|z_x| = |f(x)|$. The hypothesis $|T| = \sum |z_x|$ is exactly Theorem 4.1. $\square$

In words: at each spectral frequency, the demodulated samples $\overline{\psi(x)}f(x)$, $x \in S$, are all nonnegative multiples of the single complex number $\widehat f(\psi)$ — they point in a common direction.

### 4.3 Stage 3: the modulus is flat

**Theorem 4.4 (Sharp value distribution).** Let $f$ be extremal. Then for every $x \in S$,
$$|f(x)| \cdot N \;=\; \|f\|_1 \cdot |A| , \qquad\text{equivalently}\qquad |f(x)| = \frac{\|f\|_1}{|S|}.$$
In particular $|f|$ is constant on $\operatorname{supp} f$.

*Proof sketch.* Fix $x \in S$. Fourier inversion and restriction to the spectrum give
$$N f(x) \;=\; \sum_{\psi \in A} \psi(x)\,\widehat f(\psi).$$
Multiply by $|f(x)|$ and evaluate each summand using Theorem 4.3:
$$|f(x)|\,\psi(x)\widehat f(\psi) \;=\; \psi(x)\Big(\|f\|_1 \overline{\psi(x)}f(x)\Big) \;=\; \|f\|_1\,|\psi(x)|^2 f(x) \;=\; \|f\|_1 f(x),$$
using $\psi(x)\overline{\psi(x)} = 1$. Every summand is therefore the *same* number $\|f\|_1 f(x)$, independent of $\psi$, so
$$|f(x)| \cdot N f(x) \;=\; |A| \cdot \|f\|_1 f(x).$$
Cancelling $f(x) \ne 0$ gives $|f(x)| N = \|f\|_1 |A|$. The right-hand side does not depend on $x$, so $|f|$ is constant on $S$; and substituting $N = |S||A|$ and cancelling $|A| > 0$ gives $|f(x)|\,|S| = \|f\|_1$. $\square$

Theorem 4.4 is the second flatness statement, and it is quantitatively sharp: it identifies the constant as the average $\|f\|_1/|S|$, which is forced since the values sum to $\|f\|_1$.

### 4.4 Stage 4: the phase subgroup and the counting argument

**Corollary 4.5 (Total demodulated coherence).** Let $f$ be extremal, $\psi \in A$ and $x, y \in S$. Then
$$\overline{\psi(x)}f(x) \;=\; \overline{\psi(y)}f(y).$$

*Proof.* By Theorem 4.3, $\|f\|_1 \overline{\psi(x)}f(x) = |f(x)|\widehat f(\psi)$ and $\|f\|_1\overline{\psi(y)}f(y) = |f(y)|\widehat f(\psi)$. By Theorem 4.4, $|f(x)| = |f(y)|$, so the right-hand sides agree; cancel $\|f\|_1 > 0$. $\square$

This is the crucial coupling: for *each* spectral frequency, the demodulated signal is a single constant on the support. Different frequencies produce different constants, and comparing them is what produces the subgroup.

**Definition 4.6 (Phase subgroup).** For $f : G \to \mathbb{C}$ and $\psi_0 \in \widehat G$ put
$$H_{f,\psi_0} \;:=\; \{ z \in G : \psi(z) = \psi_0(z) \text{ for all } \psi \in \operatorname{supp}\widehat f \}.$$

That $H_{f,\psi_0}$ is a subgroup is immediate: it contains $0$, and it is closed under addition and negation because each condition $\psi(z) = \psi_0(z)$ is multiplicative in $z$. Equivalently, $H_{f,\psi_0} = \bigcap_{\psi \in A} \ker(\psi - \psi_0)$.

**Lemma 4.7 (Differences lie in the phase subgroup).** Let $f$ be extremal, $\psi_0 \in A$, and $x, y \in S$. Then $x - y \in H := H_{f,\psi_0}$.

*Proof sketch.* Let $\psi \in A$. By Corollary 4.5 applied to $\psi$ and to $\psi_0$,
$$\overline{\psi(x)}f(x) = \overline{\psi(y)}f(y), \qquad \overline{\psi_0(x)}f(x) = \overline{\psi_0(y)}f(y).$$
Since $f(x), f(y) \ne 0$ and all character values are nonzero, dividing the first identity by the second yields
$$\frac{\overline{\psi(x)}}{\overline{\psi_0(x)}} \;=\; \frac{\overline{\psi(y)}}{\overline{\psi_0(y)}},$$
i.e. $\overline{(\psi - \psi_0)(x)} = \overline{(\psi-\psi_0)(y)}$, i.e. $(\psi - \psi_0)(x - y) = 1$, i.e. $\psi(x-y) = \psi_0(x-y)$. As $\psi \in A$ was arbitrary, $x - y \in H$. $\square$

**Lemma 4.8 (Spectral differences annihilate the phase subgroup).** With the same hypotheses, $\psi - \psi_0 \in H^{\perp}$ for every $\psi \in A$.

*Proof.* By definition of $H$, every $z \in H$ satisfies $\psi(z) = \psi_0(z)$, i.e. $(\psi - \psi_0)(z) = 1$. $\square$

**Theorem 4.9 (Support is exactly a coset).** Let $f$ be extremal, $\psi_0 \in A$, $a \in S$, and $H = H_{f,\psi_0}$. Then for every $x \in G$,
$$x \in \operatorname{supp} f \iff x - a \in H .$$
Consequently $\operatorname{supp} f = a + H$ and $\operatorname{supp}\widehat f = \psi_0 + H^{\perp}$.

*Proof sketch.* The forward implication is Lemma 4.7 with $y = a$. For the converse we count. The map $y \mapsto y - a$ is injective and, by Lemma 4.7, sends $S$ into $H$; hence $|S| \le |H|$. The map $\psi \mapsto \psi - \psi_0$ is injective and, by Lemma 4.8, sends $A$ into $H^{\perp}$; hence $|A| \le |H^{\perp}|$. Multiplying and using extremality together with Fact 2.5,
$$N \;=\; |S| \cdot |A| \;\le\; |H| \cdot |H^{\perp}| \;=\; N .$$
The chain collapses, so both inequalities are equalities: $|S| = |H|$ and $|A| = |H^\perp|$. An injection between finite sets of equal cardinality is a bijection, so $S - a = H$ and $A - \psi_0 = H^{\perp}$ exactly. $\square$

This is the step in which the discrete structure is created out of analytic data. It is worth emphasising how little is used: two soft inclusions, plus the multiplicativity identity $|H| |H^{\perp}| = N$. It is also the step with no known continuous or approximate analogue, which is exactly the obstacle to a stability theory (Section 9).

**Theorem 4.10 (Main Theorem: Rigidity).** $f$ is extremal if and only if $f$ is a modulated coset indicator with $c \ne 0$.

*Proof sketch.* ($\Leftarrow$) Corollary 3.3. ($\Rightarrow$) Pick $a \in S$ and $\psi_0 \in A$ (both nonempty), and set $H = H_{f,\psi_0}$ and $c = \overline{\psi_0(a)}f(a) \ne 0$. If $x - a \in H$ then $x \in S$ by Theorem 4.9, and Corollary 4.5 gives $\overline{\psi_0(x)}f(x) = \overline{\psi_0(a)}f(a) = c$; multiplying by $\psi_0(x)$ and using $\psi_0(x)\overline{\psi_0(x)} = 1$ yields $f(x) = c\,\psi_0(x)$. If $x - a \notin H$ then $x \notin S$ by Theorem 4.9, i.e. $f(x) = 0$. Thus $f = c\,\psi_0\,\mathbf{1}_{a+H}$. $\square$

---

## 5. Structural consequences

Throughout this section $f$ is extremal, $S = \operatorname{supp} f$, $A = \operatorname{supp}\widehat f$.

### 5.1 Intrinsic cosetness

**Theorem 5.1 (Coset closure).** If $x, y, z \in S$ then $x - y + z \in S$.

*Proof.* Fix $\psi_0 \in A$. By Lemma 4.7, $x - y \in H_{f,\psi_0}$, so $(x - y + z) - z \in H_{f,\psi_0}$, and Theorem 4.9 with base point $z \in S$ gives $x - y + z \in S$. $\square$

This is the cosetness of the support phrased with no auxiliary data: a nonempty subset of an abelian group closed under $(x,y,z) \mapsto x - y + z$ is precisely a coset of a subgroup (its "difference group" $S - S$).

### 5.2 Self-duality

**Lemma 5.2 (Support of the double transform).** For any $f : G \to \mathbb{C}$,
$$\operatorname{supp}\widehat{\widehat f} \;=\; \{\iota(-x) : x \in \operatorname{supp} f\} \subseteq \widehat{\widehat G},$$
where $\iota$ is the double-dual embedding.

*Proof.* Every element of $\widehat{\widehat G}$ is $\iota(x)$ for a unique $x$ (Fact 2.2), and $\widehat{\widehat f}(\iota(x)) = N f(-x)$ (Fact 2.7), with $N \ne 0$. $\square$

**Theorem 5.3 (Extremality is self-dual).** If $f$ is extremal on $G$, then $\widehat f$ is extremal on $\widehat G$.

*Proof.* By Lemma 5.2 and injectivity of $x \mapsto \iota(-x)$, $|\operatorname{supp}\widehat{\widehat f}| = |S|$. Hence
$$|\operatorname{supp}\widehat f| \cdot |\operatorname{supp}\widehat{\widehat f}| = |A| \cdot |S| = N = |\widehat G|,$$
using $|\widehat G| = |G|$. $\square$

Combined with Corollary 3.2, this says the extremal family is *closed and symmetric* under the transform: the coset $(a, H)$ maps to the coset $(\chi, H^{\perp})$, and $H \mapsto H^{\perp}$ is an inclusion-reversing involution on the subgroup lattice.

### 5.3 The phase subgroup is intrinsic

The subgroup $H_{f,\psi_0}$ was defined using an arbitrary choice of $\psi_0 \in A$. It is in fact canonical.

**Theorem 5.4 (Phase subgroup = period group).** Let $f$ be extremal and $\psi_0 \in A$. For every $z \in G$,
$$z \in H_{f,\psi_0} \iff \big(x \in \operatorname{supp} f \Rightarrow x + z \in \operatorname{supp} f\big).$$
In particular $H_{f,\psi_0} = \{z : S + z = S\}$ is independent of $\psi_0$.

*Proof sketch.* Fix $a \in S$. ($\Rightarrow$) If $z \in H$ and $x \in S$, then $x - a \in H$ by Theorem 4.9, so $(x+z) - a = (x-a) + z \in H$, so $x + z \in S$. ($\Leftarrow$) If $S + z \subseteq S$ then $a + z \in S$, so $(a+z) - a = z \in H$ by Lemma 4.7. Independence of $\psi_0$ follows because the right-hand condition never mentions $\psi_0$. $\square$

### 5.4 Uniqueness of the classification data and orbit structure

**Theorem 5.5 (Support of a modulated coset indicator).** If $f = c\,\chi\,\mathbf{1}_{a+H}$ with $c \ne 0$, then $x \in \operatorname{supp} f \iff x - a \in H$.

*Proof.* $c\chi(x) \ne 0$ since $|\chi(x)| = 1$ and $c\neq 0$; the complementary case is the definition. $\square$

**Theorem 5.6 (The subgroup is unique).** If $c_1 \chi_1 \mathbf{1}_{a_1 + H_1} = c_2\chi_2\mathbf{1}_{a_2+H_2}$ as functions, with $c_1, c_2 \ne 0$, then $H_1 = H_2$.

*Proof sketch.* By Theorem 5.5 the two representations give $x - a_1 \in H_1 \iff x \in \operatorname{supp} f \iff x - a_2 \in H_2$ for all $x$. Taking $x = a_1$ shows $a_1 - a_2 \in H_2$. Then for arbitrary $z$, substituting $x = z + a_1$ gives $z \in H_1 \iff z + (a_1 - a_2) \in H_2 \iff z \in H_2$, using that $H_2$ is a subgroup containing $a_1 - a_2$. $\square$

(The base point $a$ is unique only modulo $H$, and the pair $(c, \chi)$ is unique only modulo the ambiguity $\chi \mapsto \chi + \eta$, $\eta \in H^{\perp}$, with a compensating change of $c$ — the same function has $|H^{\perp}|$ such representations.)

**Theorem 5.7 (Extremals with fixed support form one orbit).** If $f$ and $g$ are extremal with $\operatorname{supp} f = \operatorname{supp} g$, then there exist $c \ne 0$ and $\chi \in \widehat G$ with $f(x) = c\,\chi(x)\,g(x)$ for all $x \in G$.

*Proof sketch.* Write $f = c_1\chi_1\mathbf{1}_{a_1+H_1}$ and $g = c_2\chi_2\mathbf{1}_{a_2+H_2}$ by Theorem 4.10. On the common support, $f = c_1\chi_1$ and $g = c_2\chi_2$, so $f = (c_1/c_2)(\chi_1 - \chi_2) g$ there, using $|\chi_2| = 1$ so $\chi_1/\chi_2 = \chi_1 - \chi_2$ in additive notation for $\widehat{G}$. Off the common support both sides vanish. $\square$

**Corollary 5.8 (Global description of the extremal set).** The set of extremal functions on $G$ is the disjoint union, over all pairs $(H, a+H)$ with $H \le G$ and $a + H$ a coset of $H$, of a single orbit of the group $\mathbb{C}^{\times} \times \widehat G$ acting by scaling and modulation. Each orbit consists of the functions $c\chi\mathbf{1}_{a+H}$, and two pairs $(c,\chi), (c',\chi')$ give the same function precisely when $\chi - \chi' \in H^{\perp}$ and $c'\chi'(a) = c\chi(a)$.

---

## 6. Arithmetic consequences

### 6.1 Divisibility and its sharpness

**Theorem 6.1 (Divisibility obstruction).** If $f$ is extremal then $|\operatorname{supp} f|$ divides $N$, and consequently $|\operatorname{supp}\widehat f| = N/|\operatorname{supp} f|$ also divides $N$.

*Proof.* $\operatorname{supp} f = a + H$ has cardinality $|H|$, which divides $N$ by Lagrange (or directly by Fact 2.5). $\square$

**Theorem 6.2 (Sharpness).** Conversely, for every subgroup $H \le G$ and every $a \in G$ there exists an extremal $g$ with $\operatorname{supp} g = a + H$; one may take $g = \mathbf{1}_{a+H}$.

*Proof.* Corollary 3.3 with $c = 1$, $\chi = 0$; the support is computed by Theorem 5.5. $\square$

Thus the possible extremal support sizes are exactly the orders of subgroups of $G$ — for $G = \mathbb{Z}/N$ cyclic, exactly the divisors of $N$; for $G = (\mathbb{Z}/p)^n$, exactly the powers $p^k$, $0 \le k \le n$.

### 6.2 The prime-order dichotomy

**Theorem 6.3 (Prime dichotomy).** Suppose $N = |G|$ is prime and $f$ is extremal. Then exactly one of the following holds:
1. there are $a \in G$ and $c \ne 0$ with $f = c\,\delta_a$, i.e. $f(x) = c$ if $x = a$ and $0$ otherwise; or
2. there are $c \ne 0$ and $\chi \in \widehat G$ with $f(x) = c\,\chi(x)$ for all $x$.

*Proof sketch.* By Theorem 6.1, $|S|$ divides the prime $N$, so $|S| = 1$ or $|S| = N$. If $|S| = 1$, say $S = \{a\}$, then $f$ vanishes off $a$ and $f(a) \ne 0$: case (1). If $|S| = N$ then $S = G$, and in the representation $f = c\chi\mathbf{1}_{a+H}$ of Theorem 4.10 no point can be excluded, so $f = c\chi$ everywhere: case (2). $\square$

The two cases are mutually exclusive as soon as $N > 1$. So in prime order there is *no intermediate extremal*: the extremal set consists of $N$ lines of Dirac deltas and $N$ lines of characters, a total of $2N$ complex lines in $\mathbb{C}^N$. This is the sharpest available shadow of the general phenomenon that prime-length transforms are maximally rigid.

### 6.3 The gap theorem: no near-extremal regime

The classification implies that, within the divisibility-constrained class, failure to be extremal is quantitatively expensive.

**Theorem 6.4 (Uncertainty gap).** Let $f \ne 0$, suppose $|\operatorname{supp} f|$ divides $N$, and suppose $f$ is *not* a modulated coset indicator. Then
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\widehat f| \;\ge\; N + |\operatorname{supp} f| .$$

*Proof sketch.* Write $N = |S| q$. The uncertainty principle gives $|S||A| \ge N$, and Theorem 4.10 rules out equality, so $|S||A| > N = |S|q$, whence $|A| > q$, i.e. $|A| \ge q + 1$ since these are integers. Therefore
$$|S||A| \;\ge\; |S|(q+1) \;=\; |S|q + |S| \;=\; N + |S|. \qquad\square$$

The content is that the uncertainty product, restricted to functions whose support size divides $N$, takes values in $|S|\mathbb{Z}$, so it cannot approach $N$ from above without reaching it. There is no "almost extremal" configuration in this class: extremality is an isolated point of the value spectrum, separated by a gap of $|S|$. (The divisibility hypothesis is necessary: without it, the product can exceed $N$ by amounts smaller than $|S|$ — e.g. $|S| = 5$, $N = 12$ forces non-extremality yet permits products such as $15$.)

**Corollary 6.5.** The same conclusion holds under the weaker phrasing "$f$ is not extremal", since extremality and being a modulated coset indicator are equivalent.

### 6.4 A purely combinatorial corollary

**Theorem 6.6 (Extremal sets are cosets).** Let $S \subseteq G$ be nonempty. The indicator $\mathbf{1}_S$ satisfies $|S| \cdot |\operatorname{supp}\widehat{\mathbf{1}_S}| = N$ if and only if $S$ is a coset of a subgroup of $G$, i.e. there are $H \le G$ and $a \in G$ with $S = a + H$.

*Proof sketch.* ($\Leftarrow$) Corollary 3.3 with $c = 1$, $\chi = 0$. ($\Rightarrow$) The support of $\mathbf{1}_S$ is $S$; apply Theorem 4.9 with any $a \in S$ and any $\psi_0$ in the spectrum to get $S = a + H_{\mathbf{1}_S,\psi_0}$. $\square$

Combinatorially: among all nonempty $S \subseteq G$, the number of nonzero Fourier coefficients of $\mathbf{1}_S$ is at least $N/|S|$, with equality precisely for cosets. Equivalently, cosets are the unique sets whose *Fourier sparsity* is as small as the uncertainty principle permits.

---

## 7. Bi-flatness does not imply extremality

The rigidity proof yields two clean necessary conditions:

**(F1)** $|f|$ is constant on $\operatorname{supp} f$ (Theorem 4.4);
**(F2)** $|\widehat f|$ is constant on $\operatorname{supp}\widehat f$ (Theorem 4.1).

Call $f$ *bi-flat* if it satisfies both. It is tempting to conjecture that bi-flatness characterises extremality — after all, the classification's conclusion is that $f$ has constant modulus on a coset and its transform has constant modulus on the dual coset. We show that this fails, in every nontrivial case, and fails maximally.

### 7.1 The construction

Let $K$ be a finite abelian group with $|K| > 1$, and let
$$G \;:=\; K \times \widehat K,$$
so that $|G| = |K|^2$ and $G$ is (non-canonically) isomorphic to its own dual. Define the **evaluation pairing**
$$f : G \to \mathbb{C}, \qquad f(x, \psi) \;:=\; \psi(x).$$
For $K = \mathbb{Z}/n$, identifying $\widehat K$ with $\mathbb{Z}/n$, this is the discrete **chirp** $f(x,y) = e^{2\pi i x y / n}$, the finite analogue of $e^{i x\xi}$.

**Proposition 7.1 (Flatness in space).** $|f(p)| = 1$ for all $p \in G$; in particular $f$ vanishes nowhere and $\operatorname{supp} f = G$.

*Proof.* Character values are unimodular. $\square$

**Theorem 7.2 (Flatness in frequency).** For every $\chi \in \widehat G$,
$$|\widehat f(\chi)| \;=\; |K| \;=\; \sqrt{|G|}.$$
In particular $\widehat f$ vanishes nowhere and $\operatorname{supp}\widehat f = \widehat G$.

*Proof sketch.* Let $\chi \in \widehat G$. Restrict $\chi$ to the second factor: $\chi_2 := \chi(0, \cdot) \in \widehat{\widehat K}$. By Pontryagin duality (Fact 2.2) there is a unique $z \in K$ with $\chi_2(\psi) = \psi(z)$ for all $\psi \in \widehat K$. Since $\chi$ is a character of a product group, it splits:
$$\chi(x, \psi) = \chi(x, 0)\,\chi(0,\psi) = \chi(x,0)\,\psi(z).$$
Now compute, summing over the product:
$$\widehat f(\chi) = \sum_{x \in K}\sum_{\psi \in \widehat K} \overline{\chi(x,\psi)}\,\psi(x) = \sum_{x \in K}\overline{\chi(x,0)}\sum_{\psi \in \widehat K}\psi(x)\overline{\psi(z)}.$$
By orthogonality (Fact 2.3), the inner sum equals $|K|$ if $x = z$ and $0$ otherwise. Hence
$$\widehat f(\chi) = |K| \cdot \overline{\chi(z, 0)},$$
a unimodular number times $|K|$, so $|\widehat f(\chi)| = |K|$. $\square$

**Theorem 7.3 (Maximal non-extremality).** If $|K| > 1$ then
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\widehat f| \;=\; |G| \cdot |\widehat G| \;=\; |G|^2 \;>\; |G|,$$
so $f$ is not extremal. Indeed $|G|^2$ is the largest value the uncertainty product can take on any function.

*Proof.* Proposition 7.1 and Theorem 7.2 give both supports full, and $|\widehat G| = |G| = |K|^2 > 1$. $\square$

**Corollary 7.4 (Bi-flatness is insufficient).** For every finite abelian $K$ with $|K| > 1$ there is a function $f$ on $G = K \times \widehat K$ with $|f| \equiv 1$ on $G$ and $|\widehat f| \equiv \sqrt{|G|}$ on $\widehat G$ — so (F1) and (F2) hold in the strongest possible form, with both supports full — yet $f$ is not extremal. The smallest instance is $K = \mathbb{Z}/2$, where $|G| = 4$.

### 7.2 What the counterexample teaches

The failure is instructive, because it separates the ingredients of the rigidity proof.

Stages 1 and 3 produce (F1) and (F2). These are *magnitude* statements, obtained from the equality cases of Cauchy–Schwarz and of a termwise bound; each is a statement about a single scalar quantity per point. Stage 2 and Corollary 4.5 produce something structurally different: the assertion that the demodulated function $x \mapsto \overline{\psi(x)}f(x)$ is constant on $\operatorname{supp} f$ **for every $\psi$ in the spectrum simultaneously**. That is a coupling *between different spectral frequencies*, and it is exactly what makes Definition 4.6 meaningful: the phase subgroup is the set of shifts on which all spectral characters agree, an intersection over the whole spectrum. Delete the coupling and the subgroup evaporates.

The chirp is precisely the maximal violation of the coupling. Its spectrum is everything, so the intersection defining a phase subgroup would be over all of $\widehat G$ and hence trivial; and indeed the demodulated function $p \mapsto \overline{\chi(p)}f(p)$ is a genuinely non-constant unimodular function for every $\chi$. Every frequency sees a perfectly balanced signal; no two frequencies agree about the phase pattern; the energy stays spread.

There is also a pleasing "physical" reading. Bi-flat signals are exactly what radar and spread-spectrum engineering *want*: constant envelope in time (so the amplifier runs at full power) and constant magnitude in frequency (so the autocorrelation is a sharp spike). The theorem says this is the antipode of concentration. Perfect flatness on both sides and extremal concentration are incompatible design goals, and the chirp sits at the far end of the scale.

---

## 8. Applications and context

**Compressive sensing.** The uncertainty principle is the classical obstruction to unique sparse recovery: if $f$ and $g$ are distinct $k$-sparse signals agreeing on a set $\Omega$ of frequencies, then $h = f - g$ is $2k$-sparse with $\operatorname{supp}\widehat h \subseteq \widehat G \setminus \Omega$, so (1.1) forces $|\Omega| \le N - N/(2k)$. Rigidity converts this into a statement about *which* configurations are genuinely ambiguous: worst-case ambiguity is achieved exactly by picket fences, i.e. by cosets. In prime order, Theorem 6.3 leaves only deltas and characters, which is why prime-length transforms admit uniform guarantees at sparsity levels that composite lengths do not.

**Hidden subgroup structure.** The construction of Definition 4.6 is a spectral extraction of a hidden subgroup: from the spectrum $A$ one forms $\bigcap_{\psi \in A}\ker(\psi - \psi_0)$ and recovers $H$ exactly. This is the abelian case of the mechanism behind period finding, and Theorem 5.4 states its correctness intrinsically: the subgroup recovered from the spectrum is the true period group of the support.

**Coding theory.** Theorem 6.6 identifies cosets as the unique subsets of minimal Fourier sparsity. Since the coset structure is precisely linearity (up to translation), this is a Fourier-analytic characterisation of linear codes among all codes of a given size: linear codes are exactly the ones whose indicator function has minimal spectral support.

**Additive combinatorics.** The pattern "equality in a Fourier inequality forces exact algebraic structure" is pervasive, from Freiman-type theorems to the analysis of Gowers norms. Theorem 6.4 sharpens the pattern in the present case to a genuine gap, showing that in the divisibility-constrained regime the transition from structured to unstructured is discontinuous.

**Time–frequency analysis.** Theorem 3.1 and Corollary 3.2 record that the extremal family is closed under the transform and that $H \mapsto H^{\perp}$ implements the duality on it — the finite shadow of the fact that Gaussians (extremals of the continuous Heisenberg inequality) are transform-invariant, with the coset lattice playing the role of the Gaussian's covariance.

---

## 9. Open problems and future directions

### 9.1 Stability / quantitative rigidity

**Conjecture 9.1.** There is an absolute constant $C$ such that for every finite abelian $G$ and every $f \ne 0$ with
$$|\operatorname{supp} f| \cdot |\operatorname{supp}\widehat f| \le (1+\varepsilon)|G|, \qquad \varepsilon \le 1/C,$$
there exist $H \le G$, $\chi \in \widehat G$, $a \in G$ and $c \in \mathbb{C}$ with
$$\|f - c\,\chi\,\mathbf{1}_{a+H}\|_2 \;\le\; C\sqrt{\varepsilon}\,\|f\|_2 .$$

The proof above is already *quantitative* in its first three stages: the two inequalities (4.4) and (4.5) are each within a factor $1+\varepsilon$ of equality, and the corresponding equality analyses — flatness of $|\widehat f|$ on the spectrum and alignment of the demodulated phases — degrade continuously (equality-case lemmas for Cauchy–Schwarz and for the triangle inequality both admit stable versions with $\sqrt{\varepsilon}$ losses). The genuinely discrete ingredient is the counting step of Theorem 4.9: two injections whose images have sizes multiplying to $N$. A stability theory requires an approximate substitute — a statement that a set almost closed under differences is close to a coset, quantitatively compatible with $|H|\cdot|H^{\perp}| = N$. Theorem 6.4 already shows that the discrete side of this picture is rigid (products jump by at least $|\operatorname{supp} f|$ once $|\operatorname{supp} f|$ divides $|G|$), so the remaining content is analytic.

### 9.2 Exponent independence

**Conjecture 9.2.** If $f \ne 0$ satisfies
$$\|\widehat f\|_4^4 \cdot |\operatorname{supp} f| \;=\; |G| \cdot \|f\|_2^4$$
— equality in the $\ell^4$ form of the uncertainty principle obtained by combining Plancherel with Hölder — then $\operatorname{supp} f$ is a coset and $f$ is a modulated coset indicator: the same extremal family as for the $\ell^1/\ell^\infty$ form.

The two inequalities are driven by the same two mechanisms (a Hölder step whose equality case forces flatness, and a triangle step whose equality case forces alignment), so the extremal family should be independent of the exponent — a $p$-independence phenomenon reminiscent of the equality cases of Hausdorff–Young. Since $\|\widehat f\|_4^4$ is the additive energy of $f$ up to normalisation, a positive answer would identify cosets as the universal extremal family for finite Fourier analysis and connect the present rigidity to energy-based additive combinatorics.

### 9.3 Non-abelian and quantum analogues

For a finite group $G$ the analogue of (1.1) involves the Fourier support in the space of irreducible representations, weighted by dimension. The equality analysis of Stages 1–3 survives verbatim in the abelian-like case of representations of dimension one, but the phase subgroup construction requires commutativity of the character values. Determining the extremals for, say, the Heisenberg group over $\mathbb{Z}/p$ — where the chirp of Section 7 is the natural object — would clarify how much of the rigidity is genuinely abelian.

### 9.4 The counterexample as a benchmark

Corollary 7.4 suggests a quantitative question. Define the *coherence defect* of $f$ as the failure of the demodulated function to be constant, e.g.
$$D(f) \;=\; \max_{\psi \in \operatorname{supp}\widehat f}\ \max_{x,y \in \operatorname{supp} f} \big|\overline{\psi(x)}f(x) - \overline{\psi(y)}f(y)\big| .$$
Rigidity says $D(f) = 0$ for extremals; the chirp has the maximal possible $D$. Is there a two-sided estimate relating $D(f)$ to the uncertainty excess $|\operatorname{supp} f||\operatorname{supp}\widehat f| / |G| - 1$, valid for bi-flat functions? Such an estimate would fuse Sections 4 and 7 into a single quantitative statement and would furnish exactly the missing ingredient for Conjecture 9.1.

---

## 10. Conclusion

Equality in the Donoho–Stark uncertainty principle on a finite abelian group is an extremely rigid condition: it determines the support (a coset), the modulus (constant, equal to $\|f\|_1/|\operatorname{supp} f|$), and the phase (a character), leaving only a scalar and a modulation as free parameters. The classification is self-dual, the subgroup involved is canonical (the period group of the support), the extremal supports are exactly the cosets, and — within the class of functions whose support size divides $|G|$ — failure of extremality costs at least a full step of $|\operatorname{supp} f|$ in the uncertainty product.

What makes the theorem work is not the flatness of $|f|$ or of $|\widehat f|$ but the coherence of the demodulated signal *across the whole spectrum at once*. The discrete chirp on a self-dual group demonstrates this decisively: it is flat on both sides in the strongest possible sense, and it is as far from extremal as any function can be. In finite Fourier analysis, magnitudes constrain; phases determine.
