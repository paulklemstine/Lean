# Matrix-Level Modular Action: Translations, the Cayley Transform, and Horocycle Rigidity

**Author:** Aristotle

**Date:** 2026-08-25

---

## Abstract

We develop, at the level of explicit $2\times 2$ matrices, the dictionary between the upper half-plane and the unit disc models of the hyperbolic plane, and use it to characterise exactly which Möbius transformations preserve the horocycle foliation at the cusp $\infty$.

Three groups of results are established. First, a **horocycle rigidity theorem**: a real matrix $M$ with $\det M = 1$ satisfies $\operatorname{Im}(M\cdot z) = \operatorname{Im} z$ for every $z$ in the upper half-plane if and only if $M = \pm T(t)$, where $T(t) = \begin{pmatrix}1&t\\0&1\end{pmatrix}$; consequently such an $M$ obeys the parabolic trace condition $(\operatorname{tr} M)^2 = 4\det M$. The converse implication requires the guard that $M$ fix the cusp $\infty$, and we exhibit the matrix $\begin{pmatrix}1&0\\1&1\end{pmatrix}$ — parabolic, determinant one, yet halving the altitude of $i$ — to show the guard cannot be dropped. We complete the picture with the classical conjugacy classification, proved by an explicit change of basis: every non-identity determinant-one real matrix of trace $2$ is $\mathrm{SL}_2(\mathbb{R})$-conjugate to a nontrivial translation.

Second, a **matrix-level intertwining identity** for the Cayley transform. With $K = \begin{pmatrix}i&1\\-i&1\end{pmatrix}$, whose Möbius action is $C(z) = (1+iz)/(1-iz)$, we prove $K\,T(t) = P(t)\,K$ where $P(t) = \begin{pmatrix}1+it/2 & it/2\\ -it/2 & 1-it/2\end{pmatrix}$ is an $\mathrm{SU}(1,1)$ parabolic fixing the boundary point $-1$. The family $\{P(t)\}$ is a faithful one-parameter group with $\det P(t) = 1$, $\operatorname{tr} P(t) = 2$. Introducing the disc horocycle function $h(w) = (1-|w|^2)/|w+1|^2$, we prove the exact dictionary $h(C(z)) = \operatorname{Im} z$ and deduce that $P(t)$ preserves $h$ and maps the open disc to itself. Both facts reduce to the twin algebraic identities $\nu + \delta = w+1$ and $|\delta|^2 - |\nu|^2 = 1 - |w|^2$ for the numerator $\nu$ and denominator $\delta$ of the disc-side action.

Third, an **elliptic contrast**. The matrices $S(a) = \begin{pmatrix}1&a\\-a&1\end{pmatrix}$, implementing the velocity-addition law $x\oplus y = (x+y)/(1-xy)$, are conjugated by $K$ to the diagonal rotations $R(a) = \mathrm{diag}(1+ia,\,1-ia)$, whose Möbius action is multiplication by the unimodular number $C(a)$. This yields the linearisation $C(x\oplus y) = C(x)C(y)$, together with the injectivity of $C$ on $\mathbb{R}$ and its surjectivity onto the punctured unit circle. The discriminant dichotomy $(\operatorname{tr} T)^2 - 4\det T = 0$ versus $(\operatorname{tr} S(a))^2 - 4\det S(a) = -4a^2 < 0$ places the two families on opposite sides of the parabolic/elliptic divide.

**Keywords:** Möbius action, Cayley transform, horocycle, parabolic subgroup, $\mathrm{SL}_2(\mathbb{R})$, $\mathrm{SU}(1,1)$, discriminant trichotomy, velocity addition.

---

## 1. Introduction

### 1.1 The problem

The upper half-plane $\mathbb{H} = \{z\in\mathbb{C}: \operatorname{Im} z > 0\}$, equipped with the metric $ds = |dz|/\operatorname{Im} z$, is the standard arena for modular forms, Fuchsian groups, and hyperbolic dynamics. Its orientation-preserving isometry group is $\mathrm{PSL}_2(\mathbb{R})$, acting by fractional linear (Möbius) transformations. Among all such isometries, a distinguished role is played by those that preserve the *horocycle foliation at the cusp $\infty$*, i.e. the family of horizontal lines $\operatorname{Im} z = c$. These are the orbits of the horocycle flow, one of the most intensively studied dynamical systems in mathematics.

Folklore asserts that the horocycle-preserving isometries are precisely the horizontal translations, and that these are precisely the parabolic elements fixing $\infty$. Both assertions are correct, but the second requires care: parabolicity is a *conjugacy-invariant* condition (a statement about the discriminant $(\operatorname{tr})^2 - 4\det$), whereas horocycle preservation at $\infty$ is *not* conjugacy-invariant (it names a specific cusp). This paper isolates exactly where the two conditions agree and exhibits the minimal counterexample where they diverge.

### 1.2 Contributions

1. A self-contained treatment of the Möbius action of arbitrary $2\times2$ complex matrices, with the imaginary-part transformation law and the cocycle (composition) law stated with explicit non-degeneracy hypotheses (§2).
2. The horocycle rigidity theorem and its sharp converse, including the counterexample certifying the necessity of the cusp-fixing guard (§4).
3. The matrix-level intertwining identity for the Cayley transform, the resulting disc-model parabolic one-parameter group in $\mathrm{SU}(1,1)$, and the exact horocycle dictionary $h\circ C = \operatorname{Im}$ (§5–§6).
4. The elliptic contrast, linearising the velocity-addition law, and the discriminant dichotomy separating the two families (§7).
5. An explicit conjugacy classification of real parabolics, in both the half-plane and the Cayley-conjugated disc form (§8).

Every statement is proved by finite algebra: matrix products of size two, evaluation at well-chosen test points, and modulus computations. No analytic machinery is required at any stage.

---

## 2. The Möbius action

### 2.1 Definition

**Definition 2.1 (Möbius action).** For a matrix $M = \begin{pmatrix}\alpha&\beta\\\gamma&\delta\end{pmatrix}$ with complex entries and $z\in\mathbb{C}$ with $\gamma z + \delta \neq 0$, set
$$M\cdot z \;=\; \frac{\alpha z + \beta}{\gamma z + \delta}.$$

**Definition 2.2 (Complexification).** For a real matrix $M$, write $M_{\mathbb{C}}$ for the matrix with the same entries viewed in $\mathbb{C}$. We abbreviate $M\cdot z$ for $M_\mathbb{C}\cdot z$ when $M$ is real and $z$ complex.

### 2.2 The two structural laws

**Lemma 2.3 (Imaginary-part transformation law).** Let $a,b,c,d\in\mathbb{R}$ and $z\in\mathbb{C}$ with $cz+d\neq 0$. Then
$$\operatorname{Im}\!\left(\frac{az+b}{cz+d}\right) \;=\; \frac{(ad-bc)\,\operatorname{Im} z}{|cz+d|^2}.$$

*Proof sketch.* Write $\operatorname{Im}(u/v) = (\operatorname{Im}(u)\operatorname{Re}(v) - \operatorname{Re}(u)\operatorname{Im}(v))/|v|^2$ with $u = az+b$, $v = cz+d$. Since $a,b,c,d$ are real, $\operatorname{Im} u = a\operatorname{Im} z$, $\operatorname{Re} u = a\operatorname{Re} z + b$, $\operatorname{Im} v = c\operatorname{Im} z$, $\operatorname{Re} v = c\operatorname{Re} z + d$. Expanding the numerator, the terms in $\operatorname{Re} z$ cancel and one is left with $(ad-bc)\operatorname{Im} z$. $\square$

Two consequences used throughout: if $\det M = ad-bc = 1$ and $\operatorname{Im} z>0$, then $\operatorname{Im}(M\cdot z)>0$, so $\mathbb{H}$ is preserved; and the denominator $cz+d$ can never vanish for $\operatorname{Im} z > 0$ unless $c = d = 0$, which is excluded by $\det M = 1$.

**Lemma 2.4 (Non-vanishing of the denominator).** If $M$ is real with $\det M = 1$ and $\operatorname{Im} z > 0$, then $cz + d \neq 0$.

*Proof sketch.* If $cz+d = 0$ then, taking imaginary parts, $c\operatorname{Im} z = 0$, so $c=0$; taking real parts then gives $d=0$; but then $\det M = 0$, a contradiction. $\square$

**Lemma 2.5 (Cocycle law).** For complex $M, N$ and $z$ with $N_{21}z + N_{22}\neq 0$ (and the resulting denominators nonzero),
$$(MN)\cdot z = M\cdot(N\cdot z).$$

*Proof sketch.* Write $D = N_{21}z+N_{22}$. Substituting $N\cdot z = (N_{11}z+N_{12})/D$ into the numerator and denominator of $M\cdot(\;\cdot\;)$ and clearing $D$ produces exactly the numerator and denominator of $(MN)\cdot z$, whose entries are the four bilinear expressions $M_{i1}N_{1j} + M_{i2}N_{2j}$. The common factor $D$ cancels. $\square$

Lemma 2.5 is what makes the whole development *matrix-level*: every geometric identity between transformations can be verified as an identity between $2\times2$ matrices, up to nonzero scalar factors that the Möbius action ignores.

**Lemma 2.6 (Auxiliary modulus computation).** For real $c,d,y$: $|c(iy)+d|^2 = d^2 + c^2y^2$.

---

## 3. Translations as determinant-one matrices

**Definition 3.1.** For $t\in\mathbb{R}$ put
$$T(t) \;=\; \begin{pmatrix}1 & t\\ 0 & 1\end{pmatrix}.$$

**Proposition 3.2 (Basic invariants).** $\det T(t) = 1$ and $\operatorname{tr} T(t) = 2$; hence
$$(\operatorname{tr} T(t))^2 = 4 = 4\det T(t),$$
so $T(t)$ satisfies the parabolic trace condition.

**Proposition 3.3 (One-parameter group).** $T(s)T(t) = T(s+t)$, $T(0) = I$, and $T(t)^n = T(nt)$ for all $n\in\mathbb{N}$. Moreover $t\mapsto T(t)$ is injective, so it is a faithful embedding of $(\mathbb{R},+)$ into $\mathrm{SL}_2(\mathbb{R})$.

*Proof sketch.* The product law is a direct $2\times2$ multiplication; the power law follows by induction using $T(t)^{n+1} = T(t)^n T(t) = T(nt)T(t) = T((n+1)t)$. Injectivity is read off from the $(1,2)$ entry. $\square$

**Proposition 3.4 (Geometric meaning).** $T(t)\cdot z = z + t$ for all $z\in\mathbb{C}$.

Thus the level sets $\operatorname{Im} z = c$ — the horocycles based at the cusp $\infty$ — are each mapped to themselves by $T(t)$. The content of the next section is that nothing else does this.

---

## 4. Horocycle rigidity

We say a real matrix $M$ is **horocycle-preserving (at $\infty$)** if
$$\operatorname{Im}(M\cdot z) = \operatorname{Im} z \quad\text{for all } z\in\mathbb{H}.$$

### 4.1 The main bridge

**Theorem 4.1 (Horocycle rigidity).** Let $M = \begin{pmatrix}a&b\\c&d\end{pmatrix}$ be real with $\det M = 1$. Then $M$ is horocycle-preserving if and only if there exists $t\in\mathbb{R}$ with $M = T(t)$ or $M = -T(t)$.

*Proof.* ($\Leftarrow$) For $M = T(t)$ this is Proposition 3.4. For $M = -T(t)$, the Möbius action is unchanged, since $\frac{-z-t}{-1} = z+t$; explicitly $(-T(t))\cdot z = z + t$ and the imaginary part is again $\operatorname{Im} z$.

($\Rightarrow$) Suppose $M$ preserves the imaginary part. By Lemma 2.4 the denominator never vanishes on $\mathbb{H}$, so Lemma 2.3 with $\det M = 1$ gives, for every $z\in\mathbb{H}$,
$$\frac{\operatorname{Im} z}{|cz+d|^2} = \operatorname{Im} z .$$
Since $\operatorname{Im} z > 0$, this forces the *normalisation identity*
$$|cz + d|^2 = 1 \qquad (z\in\mathbb{H}).$$
Specialise to $z = iy$ with $y>0$ and use Lemma 2.6: $d^2 + c^2y^2 = 1$ for all $y>0$. Two values suffice. Taking $y=1$ and $y=2$:
$$d^2 + c^2 = 1, \qquad d^2 + 4c^2 = 1 \;\Longrightarrow\; 3c^2 = 0 \;\Longrightarrow\; c = 0,$$
and then $d^2 = 1$, i.e. $d = \pm1$. With $c = 0$, $\det M = ad = 1$, hence $a = d$.

If $d = 1$ then $a = 1$ and $M = \begin{pmatrix}1&b\\0&1\end{pmatrix} = T(b)$. If $d = -1$ then $a=-1$ and $M = \begin{pmatrix}-1&b\\0&-1\end{pmatrix} = -T(-b)$. $\square$

The proof is worth pausing over: an *a priori* infinite family of constraints (one per point of $\mathbb{H}$) is collapsed to two linear equations in $c^2, d^2$ by testing at the two points $i$ and $2i$. The rigidity is genuinely two-point rigidity.

### 4.2 Horocycle preservation implies parabolicity

**Corollary 4.2.** If $M$ is real, $\det M = 1$, and $M$ is horocycle-preserving, then
$$(\operatorname{tr} M)^2 = 4\det M .$$

*Proof sketch.* By Theorem 4.1, $M = \pm T(t)$. In the $+$ case $\operatorname{tr} M = 2$, $\det M = 1$. In the $-$ case $\operatorname{tr} M = -2$ and $\det M = 1$; in both cases $(\operatorname{tr} M)^2 = 4 = 4\det M$. $\square$

This is the promised direct connection between the *horocycle equation* — an analytic-looking constraint on the imaginary part — and the *parabolic trace condition*, a purely algebraic one.

### 4.3 The converse and its guard

**Theorem 4.3 (Guarded converse).** Let $M$ be real with $\det M = 1$, $(\operatorname{tr} M)^2 = 4\det M$, and $c = M_{21} = 0$. Then $M$ is horocycle-preserving.

*Proof.* From $c=0$ and $\det M = 1$ we get $ad = 1$. The trace condition reads $(a+d)^2 = 4$. Substituting $a = 1/d$ gives $(1/d + d)^2 = 4$, i.e. $(d^2+1)^2 = 4d^2$, i.e. $(d^2-1)^2 = 0$, so $d^2 = 1$. Then for any $z$, $|cz+d|^2 = d^2 = 1$, and Lemma 2.3 with $\det M = 1$ yields $\operatorname{Im}(M\cdot z) = \operatorname{Im} z$. $\square$

**Theorem 4.4 (The guard is necessary).** Let
$$N = \begin{pmatrix}1&0\\1&1\end{pmatrix}.$$
Then $\det N = 1$ and $(\operatorname{tr} N)^2 = 4 = 4\det N$, so $N$ is parabolic; yet
$$\operatorname{Im}(N\cdot i) = \tfrac12 \neq 1 = \operatorname{Im}(i).$$

*Proof.* $\det N = 1\cdot1 - 0\cdot1 = 1$ and $\operatorname{tr} N = 2$. For the last claim, $c = d = 1$, so $|c\,i + d|^2 = |i+1|^2 = 2$, and Lemma 2.3 gives $\operatorname{Im}(N\cdot i) = 1\cdot 1/2$. $\square$

The geometric explanation: $N$ is parabolic about the cusp $0$, not $\infty$ (its unique fixed point on $\mathbb{R}\cup\{\infty\}$ is $0$, since $N\cdot z = z/(z+1)$ fixes $0$). It preserves the horocycles tangent to $\mathbb{R}$ at the origin, a different foliation. Thus "parabolic" alone is strictly weaker than "horocycle-preserving at $\infty$", and the exact statement is the conjunction:

$$\boxed{\;\text{horocycle-preserving at }\infty \iff \big[(\operatorname{tr} M)^2 = 4\det M \;\wedge\; M_{21} = 0\big] \iff M = \pm T(t).\;}$$

### 4.4 Fixed points of real parabolics

**Proposition 4.5.** Let $M$ be real with $\det M = 1$, $\operatorname{tr} M = 2$, and $c = M_{21}\neq 0$. Then
$$x_0 = \frac{a-d}{2c}$$
is a fixed point of the Möbius action of $M$ on $\mathbb{R}$.

*Proof sketch.* From $a + d = 2$ one obtains $c\,x_0 + d = \frac{a-d}{2} + d = \frac{a+d}{2} = 1$, so the denominator at $x_0$ equals $1$. It then suffices to check $a x_0 + b = x_0$, which after clearing $2c$ reduces to $2ac\,\frac{a-d}{2c} + 2bc = a - d$, i.e. $a(a-d) + 2bc = a-d$; using $bc = ad - 1$ and $d = 2-a$, both sides equal $2a-2$. $\square$

So a parabolic with $c\neq 0$ has its unique fixed point in $\mathbb{R}$; a parabolic with $c=0$ has it at $\infty$. In every case there is exactly one boundary fixed point — the defining feature of the parabolic species.

---

## 5. The Cayley transform at matrix level

### 5.1 Definitions

**Definition 5.1 (Cayley transform).** $C(z) = \dfrac{1+iz}{1-iz}$, defined for $z \neq -i$. Its restriction to $\mathbb{R}$ is the classical map $x \mapsto (1+ix)/(1-ix)$ onto the unit circle.

**Definition 5.2 (Cayley matrix).** $K = \begin{pmatrix} i & 1 \\ -i & 1\end{pmatrix}$.

**Proposition 5.3.** $\det K = 2i \neq 0$, and $K\cdot z = C(z)$ for all admissible $z$.

*Proof sketch.* $\det K = i\cdot 1 - 1\cdot(-i) = 2i$. The Möbius action is $\frac{iz+1}{-iz+1}$, which equals $\frac{1+iz}{1-iz}$. $\square$

**Lemma 5.4 (Denominator).** $1 - iz = 0$ only for $z = -i$; hence $C$ is defined on $\mathbb{C}\setminus\{-i\}$, in particular on all of $\overline{\mathbb{H}}$.

**Proposition 5.5 ($C$ maps $\mathbb{H}$ into the disc).** If $\operatorname{Im} z > 0$ then $|C(z)| < 1$.

*Proof sketch.* Writing $z = x+iy$, $|1+iz|^2 = (1-y)^2 + x^2$ and $|1-iz|^2 = (1+y)^2 + x^2$. Their difference is $-4y < 0$, so the ratio of moduli is $<1$. $\square$

Note also that $|C(x)| = 1$ for real $x$: the boundary $\mathbb{R}$ maps to the unit circle, and $z\to\infty$ maps to $-1$.

### 5.2 The intertwining identity

**Definition 5.6 (Disc-side parabolic).** For $t\in\mathbb{R}$,
$$P(t) \;=\; \begin{pmatrix} 1 + \tfrac{it}{2} & \tfrac{it}{2}\\[2pt] -\tfrac{it}{2} & 1 - \tfrac{it}{2}\end{pmatrix}.$$

**Theorem 5.7 (Matrix-level compatibility of the Cayley transform with translations).** For every $t\in\mathbb{R}$,
$$K\,T(t) \;=\; P(t)\,K .$$

*Proof.* Both sides are computed entrywise. On the left,
$$\begin{pmatrix}i&1\\-i&1\end{pmatrix}\begin{pmatrix}1&t\\0&1\end{pmatrix} = \begin{pmatrix} i & it+1\\ -i & -it+1\end{pmatrix}.$$
On the right, the $(1,1)$ entry is $\left(1+\tfrac{it}{2}\right)i + \tfrac{it}{2}(-i) = i - \tfrac{t}{2} + \tfrac{t}{2} = i$; the $(1,2)$ entry is $\left(1+\tfrac{it}{2}\right) + \tfrac{it}{2} = 1+it$; the $(2,1)$ entry is $-\tfrac{it}{2}\cdot i + \left(1-\tfrac{it}{2}\right)(-i) = \tfrac{t}{2} - i - \tfrac{t}{2} = -i$; and the $(2,2)$ entry is $-\tfrac{it}{2} + 1 - \tfrac{it}{2} = 1-it$. The two matrices agree. $\square$

**Corollary 5.8 (Möbius-level compatibility).** For $z\neq -i$ and $t\in\mathbb{R}$,
$$C(z+t) \;=\; P(t)\cdot C(z).$$

*Proof sketch.* Apply the cocycle law (Lemma 2.5) to both sides of Theorem 5.7 acting on $z$: $\;(K\,T(t))\cdot z = K\cdot(z+t) = C(z+t)$, while $(P(t)K)\cdot z = P(t)\cdot(K\cdot z) = P(t)\cdot C(z)$. The non-vanishing hypotheses are supplied by Lemma 5.4 (for $K$ at $z$) and by the trivial denominator of $T(t)$. $\square$

### 5.3 Structure of the disc-side family

**Proposition 5.9.** For all $s,t \in \mathbb{R}$:
1. $\det P(t) = 1$ and $\operatorname{tr} P(t) = 2$, hence $(\operatorname{tr} P(t))^2 = 4\det P(t)$: $P(t)$ is parabolic.
2. $P(s)P(t) = P(s+t)$, $P(0) = I$, $P(t)^n = P(nt)$, and $t\mapsto P(t)$ is injective.
3. $\overline{P(t)_{11}} = P(t)_{22}$ and $\overline{P(t)_{12}} = P(t)_{21}$, i.e. $P(t)\in\mathrm{SU}(1,1)$.
4. $P(t)\cdot(-1) = -1$, and for $t\neq 0$ this is the unique fixed point.

*Proof sketch.* (1) $\det P(t) = \left(1+\tfrac{it}{2}\right)\left(1-\tfrac{it}{2}\right) + \left(\tfrac{it}{2}\right)^2 = 1 + \tfrac{t^2}{4} - \tfrac{t^2}{4} = 1$; the trace is $\left(1+\tfrac{it}{2}\right)+\left(1-\tfrac{it}{2}\right) = 2$. (2) Direct multiplication, with induction for powers; injectivity from the $(1,2)$ entry, since $t\mapsto it/2$ is injective. (3) Conjugation negates $i$ and swaps the two diagonal entries; likewise for the off-diagonal pair. (4) Numerator at $w=-1$: $-\left(1+\tfrac{it}{2}\right)+\tfrac{it}{2} = -1$; denominator: $\tfrac{it}{2} + 1 - \tfrac{it}{2} = 1$; so the value is $-1$. Uniqueness follows from solving the fixed-point quadratic, which is $\tfrac{it}{2}(w+1)^2 = 0$ and, for $t\neq 0$, has the double root $w=-1$. $\square$

Point (1) is a consistency check on the whole construction: conjugation by an invertible matrix preserves the ratio $(\operatorname{tr})^2/\det$, so the disc-side image of a parabolic must again be parabolic. Point (4) identifies $-1$ as the image of the cusp $\infty$ under $C$, exactly as it must be.

---

## 6. The horocycle dictionary

### 6.1 The disc horocycle function

**Definition 6.1.** For $w \neq -1$,
$$h(w) \;=\; \frac{1 - |w|^2}{|w+1|^2}.$$

The level sets $h(w) = c > 0$ are the Euclidean circles inside the unit disc tangent to the unit circle at $-1$; $h(w) = 0$ is the unit circle minus $-1$; and $h < 0$ outside the disc. Thus $h$ measures "depth into the disc, normalised by distance from the distinguished boundary point $-1$".

**Theorem 6.2 (Horocycle dictionary).** For every $z \neq -i$,
$$h(C(z)) \;=\; \operatorname{Im} z .$$

*Proof.* Write $z = x + iy$, and set $A = |1+iz|^2 = (1-y)^2 + x^2$, $B = |1-iz|^2 = (1+y)^2 + x^2$, so $|C(z)|^2 = A/B$ and $B > 0$ since $z\neq -i$. The numerator of $h$ is
$$1 - \frac{A}{B} = \frac{B - A}{B} = \frac{4y}{B}.$$
For the denominator, note the useful algebraic identity
$$C(z) + 1 = \frac{1+iz}{1-iz} + 1 = \frac{2}{1-iz},$$
so $|C(z)+1|^2 = 4/B$. Dividing,
$$h(C(z)) = \frac{4y/B}{4/B} = y = \operatorname{Im} z. \qquad\square$$

The identity $C(z)+1 = 2/(1-iz)$ is the crux: it makes the two occurrences of $B$ cancel exactly, so no proportionality constant survives.

### 6.2 Invariance on the disc

Fix $t$ and write, for $w\in\mathbb{C}$,
$$\nu \;=\; \left(1+\tfrac{it}{2}\right)w + \tfrac{it}{2}, \qquad \delta \;=\; -\tfrac{it}{2}\,w + \left(1-\tfrac{it}{2}\right),$$
the numerator and denominator of $P(t)\cdot w$.

**Lemma 6.3 (Affine-sum identity).** $\nu + \delta = w + 1$.

*Proof.* $\nu + \delta = \left(1+\tfrac{it}{2} - \tfrac{it}{2}\right)w + \left(\tfrac{it}{2} + 1 - \tfrac{it}{2}\right) = w+1$. $\square$

**Lemma 6.4 ($\mathrm{SU}(1,1)$ pseudo-norm identity).** $|\delta|^2 - |\nu|^2 = 1 - |w|^2$.

*Proof sketch.* Writing $w = u+iv$ and expanding, $|\nu|^2 = |w|^2 + t\,\mathrm{Im}\!\left(\overline{w}\, \tfrac{i}{1}\right)$-type cross terms; systematically, with $\alpha = 1 + \tfrac{it}{2}$, $\beta = \tfrac{it}{2}$ one has $\nu = \alpha w + \beta$ and $\delta = \bar\beta w + \bar\alpha$ (using $\bar\beta = -\tfrac{it}{2}$, $\bar\alpha = 1 - \tfrac{it}{2}$). Then
$$|\delta|^2 - |\nu|^2 = (|\beta|^2|w|^2 + |\alpha|^2 + 2\operatorname{Re}(\bar\beta \alpha w)) - (|\alpha|^2|w|^2 + |\beta|^2 + 2\operatorname{Re}(\alpha \bar\beta w))$$
$$= (|\alpha|^2 - |\beta|^2)(1 - |w|^2) = 1 - |w|^2,$$
since $|\alpha|^2 - |\beta|^2 = 1 + \tfrac{t^2}{4} - \tfrac{t^2}{4} = 1$ (which is exactly $\det P(t)=1$ in $\mathrm{SU}(1,1)$ form). $\square$

**Lemma 6.5 (Non-degeneracy).** If $|w|\le 1$ then $\delta \neq 0$.

*Proof sketch.* If $\delta = 0$ then Lemma 6.4 gives $-|\nu|^2 = 1 - |w|^2 \ge 0$, forcing $\nu = 0$ and $|w| = 1$; but then Lemma 6.3 gives $w = -1$, and substituting $w=-1$ into $\delta$ yields $\delta = \tfrac{it}{2} + 1 - \tfrac{it}{2} = 1 \neq 0$, a contradiction. $\square$

**Theorem 6.6 (Horocycle invariance on the disc).** For every $t\in\mathbb{R}$ and $|w|\le 1$,
$$h(P(t)\cdot w) \;=\; h(w).$$

*Proof.* By Lemma 6.5 the value $P(t)\cdot w = \nu/\delta$ is defined. Then
$$1 - \left|\frac{\nu}{\delta}\right|^2 = \frac{|\delta|^2 - |\nu|^2}{|\delta|^2} = \frac{1-|w|^2}{|\delta|^2}$$
by Lemma 6.4, while
$$\left|\frac{\nu}{\delta} + 1\right|^2 = \frac{|\nu+\delta|^2}{|\delta|^2} = \frac{|w+1|^2}{|\delta|^2}$$
by Lemma 6.3. Dividing, the factors $|\delta|^{-2}$ cancel and one obtains $h(\nu/\delta) = (1-|w|^2)/|w+1|^2 = h(w)$. $\square$

**Corollary 6.7 (Disc preservation).** If $|w| < 1$ then $|P(t)\cdot w| < 1$.

*Proof sketch.* Lemma 6.4 gives $|\delta|^2 - |\nu|^2 = 1 - |w|^2 > 0$, so $|\nu| < |\delta|$ and $|\nu/\delta| < 1$. $\square$

Theorem 6.6 is the disc-side mirror of Proposition 3.4: translations shift the half-plane along horizontal lines, and $P(t)$ shears the disc along circles tangent at $-1$. Theorem 6.2 makes the correspondence exact, and Theorem 4.1 says that on the half-plane side no other determinant-one motion behaves this way.

---

## 7. The elliptic contrast

### 7.1 Velocity addition and its matrices

**Definition 7.1.** For real $x,y$ with $xy \neq 1$, set
$$x \oplus y \;=\; \frac{x+y}{1-xy}, \qquad S(a) = \begin{pmatrix} 1 & a\\ -a & 1\end{pmatrix}.$$

The operation $\oplus$ is the tangent addition law: if $x = \tan\alpha$ and $y=\tan\beta$ then $x\oplus y = \tan(\alpha+\beta)$. Its Möbius realisation is $S(a)\cdot z = (z+a)/(1-az)$, so $x \oplus a = S(a)\cdot x$.

**Proposition 7.2.** $\operatorname{tr} S(a) = 2$ and $\det S(a) = 1 + a^2$.

### 7.2 Diagonalisation by the Cayley transform

**Definition 7.3.** $R(a) = \begin{pmatrix} 1+ia & 0\\ 0 & 1-ia\end{pmatrix}$.

**Theorem 7.4 (Cayley conjugation of the elliptic family).** For every $a\in\mathbb{R}$,
$$K\,S(a) \;=\; R(a)\,K .$$

*Proof.* $K S(a) = \begin{pmatrix}i&1\\-i&1\end{pmatrix}\begin{pmatrix}1&a\\-a&1\end{pmatrix} = \begin{pmatrix} i-a & ia+1\\ -i-a & -ia+1\end{pmatrix}$, and $R(a)K = \begin{pmatrix}1+ia&0\\0&1-ia\end{pmatrix}\begin{pmatrix}i&1\\-i&1\end{pmatrix} = \begin{pmatrix} (1+ia)i & 1+ia\\ -(1-ia)i & 1-ia\end{pmatrix}$. Since $(1+ia)i = i - a$ and $-(1-ia)i = -i - a$, the matrices agree. $\square$

**Corollary 7.5 (Invariants are preserved).** $\operatorname{tr} R(a) = \operatorname{tr} S(a) = 2$ and $\det R(a) = (1+ia)(1-ia) = 1+a^2 = \det S(a)$.

**Proposition 7.6 (Rotation).** $R(a)\cdot w = C(a)\,w$, where $C(a) = (1+ia)/(1-ia)$ has modulus one.

*Proof sketch.* $R(a)\cdot w = \frac{(1+ia)w + 0}{0\cdot w + (1-ia)} = \frac{1+ia}{1-ia}w$. Unimodularity holds because numerator and denominator are complex conjugates. $\square$

**Theorem 7.7 (Linearisation of velocity addition).** For real $x,y$ with $1 - xy \neq 0$,
$$C(x\oplus y) = C(x)\,C(y).$$

*Proof sketch.* Substituting $x\oplus y = (x+y)/(1-xy)$ into $C$ and clearing denominators, the claim becomes
$$\big((1-xy) + i(x+y)\big)\big((1-ix)(1-iy)\big) = \big((1-xy) - i(x+y)\big)\big((1+ix)(1+iy)\big)\quad\text{(after cross-multiplication)},$$
and both sides expand, using $i^2 = -1$, to the same polynomial. Equivalently and more conceptually: $(1+ix)(1+iy) = (1-xy) + i(x+y)$ and $(1-ix)(1-iy) = (1-xy) - i(x+y)$, so
$$C(x)C(y) = \frac{(1+ix)(1+iy)}{(1-ix)(1-iy)} = \frac{(1-xy)+i(x+y)}{(1-xy)-i(x+y)} = \frac{1 + i\frac{x+y}{1-xy}}{1 - i\frac{x+y}{1-xy}} = C(x\oplus y). \;\square$$

The second display is the whole theorem in one line: the Cayley transform is a homomorphism from the (partially defined) group $(\mathbb{R},\oplus)$ to the unit circle under multiplication.

**Corollary 7.8 (Consistency of the two dictionaries).** For real $a, x$ with $1 - xa \neq 0$, $\;R(a)\cdot C(x) = C(x \oplus a)$. This is the elliptic analogue of the parabolic statement $P(t)\cdot C(z) = C(z+t)$.

### 7.3 The Cayley transform on the boundary circle

**Proposition 7.9 (Injectivity).** $C$ is injective on $\mathbb{R}$.

**Proposition 7.10 ($-1$ is omitted).** $C(x)\neq -1$ for all real $x$; indeed $C(x) = -1$ would give $1+ix = -(1-ix)$, i.e. $2 = 0$.

**Theorem 7.11 (Surjectivity onto the punctured circle).** If $|w| = 1$ and $w \neq -1$, then $w = C(x)$ for
$$x \;=\; \operatorname{Re}\!\left(\frac{-i(w-1)}{w+1}\right),$$
and this $x$ is the unique real preimage.

*Proof sketch.* Inverting $w = (1+ix)/(1-ix)$ gives $ix = (w-1)/(w+1)$, i.e. $x = -i(w-1)/(w+1)$. One checks from $|w|=1$ that this quantity is real, so taking its real part is harmless; uniqueness is Proposition 7.9. $\square$

Together, Propositions 7.9–7.11 say that $C$ is a bijection from $\mathbb{R}$ onto the unit circle minus $\{-1\}$, and by Theorem 7.7 it is an isomorphism of group structures: $(\mathbb{R}, \oplus) \cong (S^1\setminus\{-1\}, \cdot)$ wherever both are defined.

### 7.4 Discriminant dichotomy

**Theorem 7.12.** For all real $t$ and all real $a \neq 0$:
$$(\operatorname{tr} T(t))^2 - 4\det T(t) = 0, \qquad (\operatorname{tr} S(a))^2 - 4\det S(a) = 4 - 4(1+a^2) = -4a^2 < 0 .$$

Hence the translations are exactly parabolic, while the velocity-addition matrices are strictly elliptic for $a\neq 0$. The discriminant $(\operatorname{tr})^2 - 4\det$ is invariant under conjugation, so the same classification is visible on the disc side: $P(t)$ is parabolic with a single boundary fixed point $-1$, while $R(a)$ is elliptic, fixing the centre $0$ of the disc and rotating around it by the argument of $C(a)$.

---

## 8. Conjugacy classification of real parabolics

**Theorem 8.1 (Every parabolic is a translation in disguise).** Let $M$ be real with $\det M = 1$, $\operatorname{tr} M = 2$, and $M \neq I$. Then there exist a real matrix $P$ with $\det P = 1$ and a real $s \neq 0$ such that
$$M P = P\,T(s), \qquad\text{i.e.}\qquad M = P\,T(s)\,P^{-1}.$$

*Proof.* Write $M = \begin{pmatrix}a&b\\c&d\end{pmatrix}$, so $a+d = 2$ and $ad - bc = 1$.

*Case $c = 0$.* Then $ad = 1$ and $a + d = 2$, whence $a = d = 1$ (the quadratic $a + 1/a = 2$ has the double root $1$). Thus $M = T(b)$; and $b \neq 0$, else $M = I$. Take $P = I$, $s = b$.

*Case $c \neq 0$.* Take
$$P = \begin{pmatrix} -(a-1)/c & 1 \\ -1 & 0\end{pmatrix}, \qquad s = -c .$$
Then $\det P = 0 - (1)(-1) = 1$ and $s\neq 0$. Verifying $MP = P\,T(s)$ entrywise uses the single relation
$$bc = -(a-1)^2,$$
which follows from $ad - bc = 1$ and $d = 2-a$: indeed $a(2-a) - bc = 1$ gives $bc = 2a - a^2 - 1 = -(a-1)^2$. $\square$

**Theorem 8.2 (Cayley form of the classification).** Let $M$ be real with $\det M = 1$, $\operatorname{tr} M = 2$, $M \neq I$. Then there exist an invertible complex matrix $X$ and a real $s \neq 0$ with
$$M X = X\,P(s).$$
One may take $X = P\,K^{-1}$ with $P, s$ as in Theorem 8.1.

*Proof sketch.* From Theorem 5.7, $K T(s) = P(s) K$, hence $K^{-1}P(s) = T(s)K^{-1}$. Then
$$M(PK^{-1}) = (MP)K^{-1} = (P\,T(s))K^{-1} = P\,(T(s)K^{-1}) = P\,(K^{-1}P(s)) = (PK^{-1})P(s).$$
Invertibility of $X$ follows from $\det X = \det P \cdot (\det K)^{-1} = 1/(2i)\neq 0$. $\square$

The geometric reading of Theorem 8.2: every non-identity parabolic of $\mathrm{SL}_2(\mathbb{R})$ becomes, after transfer to the disc, a horocyclic shear of the standard form $P(s)$. In particular, by Theorem 6.6, every such parabolic preserves a horocycle foliation — just not, in general, the one at $\infty$. This closes the circle opened by Theorem 4.4: the counterexample $N$ is not an exception to parabolic geometry but an instance of it at a different cusp.

---

## 9. Algorithms

The results above are entirely constructive; we record the three computations they define.

### 9.1 Horocycle-preservation test

**Input:** real $2\times2$ matrix $M$ with $\det M = 1$.
**Output:** whether $M$ preserves all horocycles at $\infty$, and if so the translation parameter $t$ and sign.

By Theorem 4.1 the test is: check $c = 0$ and $|d| = 1$ (equivalently $c = 0$ and $(\operatorname{tr} M)^2 = 4$). If $d = 1$, return $(+, b)$; if $d = -1$, return $(-, -b)$. Cost: $O(1)$. The correctness proof is exactly the two-test-point argument, so an equivalent *numerical* test is to evaluate $\operatorname{Im}(M\cdot i)$ and $\operatorname{Im}(M\cdot 2i)$ and compare against $1$ and $2$: two samples always suffice.

### 9.2 Half-plane $\leftrightarrow$ disc transfer

**Input:** a determinant-one real matrix $M$ acting on $\mathbb{H}$.
**Output:** the matrix $K M K^{-1}$ acting on the unit disc.

With $K = \begin{pmatrix}i&1\\-i&1\end{pmatrix}$ and $K^{-1} = \frac{1}{2i}\begin{pmatrix}1&-1\\i&i\end{pmatrix}$, this is two $2\times2$ complex multiplications, cost $O(1)$. Theorem 5.7 asserts $KT(t)K^{-1} = P(t)$; Theorem 7.4 asserts $KS(a)K^{-1} = R(a)$. The transfer preserves trace and determinant, hence the discriminant, hence the parabolic/elliptic/hyperbolic type.

### 9.3 Parabolic normalisation

**Input:** real $M$ with $\det M = 1$, $\operatorname{tr} M = 2$, $M\neq I$.
**Output:** $P$ with $\det P = 1$ and $s\neq0$ with $M = P\,T(s)\,P^{-1}$.

Follow Theorem 8.1: if $c = 0$, return $(I, b)$; else return $\left(\begin{pmatrix}-(a-1)/c & 1\\ -1 & 0\end{pmatrix},\, -c\right)$. Cost: $O(1)$. Composing with §9.2 gives the disc form $M = X P(s) X^{-1}$ of Theorem 8.2.

---

## 10. Discussion

### 10.1 What the rigidity theorem really says

Theorem 4.1 is a statement about the *stabiliser of a foliation*. The group $\mathrm{SL}_2(\mathbb{R})$ is three-dimensional; the subgroup fixing the cusp $\infty$ (upper-triangular matrices) is two-dimensional, containing both the translations and the dilations $z\mapsto \lambda^2 z$; and the requirement of preserving each individual horocycle cuts this down to the one-dimensional unipotent subgroup, doubled by the centre $\{\pm I\}$ which acts trivially. So the theorem measures the exact codimension of "preserving every leaf" over "preserving the leaf space", and the dilations are precisely what is lost.

### 10.2 Why the guard is unavoidable

The trace condition $(\operatorname{tr})^2 = 4\det$ is invariant under conjugation; the condition "$\operatorname{Im}$ is preserved" is not, because it privileges $\infty$. A conjugation-invariant condition can never characterise a non-invariant one, so *some* additional, cusp-specific hypothesis is forced by pure logic. Theorem 4.3 shows $M_{21}=0$ suffices, and Theorem 4.4 shows something is required. The pair is thus optimal in the sense of naming the weakest cusp-specific supplement.

### 10.3 The role of the intertwining identity

Once Theorem 5.7 is available, all the Möbius-level statements about the Cayley transform become corollaries of matrix algebra plus the cocycle law. This is a genuine simplification: identities between fractional-linear maps involve case analysis on vanishing denominators, whereas identities between matrices do not. The bookkeeping cost is that matrices represent Möbius maps only up to scalars, which is why the intertwining relation is stated in the product form $KT(t) = P(t)K$ rather than as $P(t) = KT(t)K^{-1}$ with an implicit normalisation.

### 10.4 Parabolic versus elliptic: one transform, two behaviours

The pairing of Theorems 5.7 and 7.4 makes a pedagogical point vivid. The same conjugation sends the shear $T(t)$ to the $\mathrm{SU}(1,1)$ shear $P(t)$ (trace $2$, one boundary fixed point, preserving a horocycle foliation) and the rotation-like $S(a)$ to a literal diagonal rotation $R(a)$ (trace $2$, determinant $1+a^2$, one interior fixed point). The invariant that separates them is the discriminant, and both computations are two lines long. That the "velocity addition" law $\oplus$ becomes plain multiplication is the payoff: an apparently nonlinear operation is revealed as a rotation group in disguise.

### 10.5 Connections

- **Modular forms.** The relation $T(1)\cdot z = z+1$ underlies the Fourier expansion of modular forms at the cusp; Theorem 4.1 characterises the cusp stabiliser's unipotent part.
- **Homogeneous dynamics.** The horocycle flow on $\mathrm{SL}_2(\mathbb{R})/\Gamma$ is generated by $\{T(t)\}$; the dictionary $h\circ C = \operatorname{Im}$ transfers it to the disc model without distortion, which is convenient for bounded-domain numerics.
- **Special relativity and hyperbolic trigonometry.** Theorem 7.7 identifies $\oplus$ with circle multiplication, the same phenomenon as the additivity of rapidity.
- **Geometric group theory.** Theorem 8.1 supplies the normal form used to define cusp neighbourhoods and to run ping-pong arguments for discreteness.

---

## 11. Future work

Several concrete continuations suggest themselves.

1. **Ping-pong discreteness for the parabolic–elliptic pair.** For the group $\Gamma(t,a)\le \mathrm{SL}_2(\mathbb{R})$ generated by $T(t)$ and the elliptic $S(a)$, one expects an explicit real-algebraic threshold $\mathcal{T}(a)$ with $\Gamma(t,a)$ discrete and free of rank $2$ exactly when $|t|\ge \mathcal{T}(a)$, and $\mathcal{T}(a)$ a root of a polynomial in the entries of $R(a)$. The key structural advantage is that after transfer to the disc, $h$ furnishes a single scalar Lyapunov function: it is exactly invariant under $P(t)$ and strictly monotone under $R(a)$ away from the fixed point, so the ping-pong sets can be defined by inequalities in $h$ rather than by ad-hoc fundamental domains.

2. **Horocycle height as a group cocycle.** Setting $\beta(g,z) = \log\big(h(g\cdot C(z))/h(C(z))\big)$ should define an $\mathbb{R}$-valued cocycle on $\mathrm{SL}_2(\mathbb{R})\times\mathbb{H}$ whose vanishing locus is exactly $\{\pm T(t)\}$ — which is to say that Theorem 4.1 computes the kernel of a Busemann-type cocycle. Making the cocycle identity $\beta(gh,z) = \beta(g, h\cdot z) + \beta(h,z)$ explicit at matrix level would connect this circle of ideas to Busemann functions and Patterson–Sullivan theory.

3. **All three species at once.** Extend the guarded converse to hyperbolic and elliptic elements: characterise, for each conjugacy species, the exact family of foliations it preserves, and identify the cusp- or centre-specific guard needed in each case.

4. **Quantitative horocycle displacement.** For a general determinant-one $M$, the quantity $\operatorname{Im}(M\cdot z)/\operatorname{Im} z = |cz+d|^{-2}$ is an explicit displacement function. Bounding it uniformly over horocycle segments would give effective statements about how far a non-parabolic element moves a horocycle, with applications to effective equidistribution.

5. **Higher rank and other symmetric spaces.** The Cayley transform generalises to Siegel upper half-spaces and bounded symmetric domains. A matrix-level intertwining identity there, together with an appropriate multi-dimensional analogue of $h$, would extend the dictionary of §6 beyond rank one.

---

## 12. Summary of results

| Statement | Content |
|---|---|
| Imaginary-part law | $\operatorname{Im}(M\cdot z) = \det M \cdot \operatorname{Im} z / |cz+d|^2$ |
| Cocycle law | $(MN)\cdot z = M\cdot(N\cdot z)$ when denominators are nonzero |
| Translations | $T(s)T(t) = T(s+t)$, $\det = 1$, $\operatorname{tr} = 2$, $(\operatorname{tr})^2 = 4\det$ |
| Horocycle rigidity | $\det M = 1$: $\operatorname{Im}$ preserved on $\mathbb{H}$ $\iff$ $M = \pm T(t)$ |
| Parabolicity | Horocycle preservation $\Rightarrow (\operatorname{tr} M)^2 = 4\det M$ |
| Guarded converse | $(\operatorname{tr} M)^2 = 4\det M$ and $M_{21}=0$ $\Rightarrow$ horocycle preservation |
| Sharpness | $\begin{pmatrix}1&0\\1&1\end{pmatrix}$ is parabolic but sends $i$ to height $1/2$ |
| Cayley matrix | $K = \begin{pmatrix}i&1\\-i&1\end{pmatrix}$, $\det K = 2i$, $K\cdot z = (1+iz)/(1-iz)$ |
| Intertwining | $K\,T(t) = P(t)\,K$; equivalently $C(z+t) = P(t)\cdot C(z)$ |
| Disc parabolics | $P(s)P(t) = P(s+t)$, $\det = 1$, $\operatorname{tr} = 2$, $\mathrm{SU}(1,1)$, fixes only $-1$ |
| Horocycle dictionary | $h(C(z)) = \operatorname{Im} z$ with $h(w) = (1-|w|^2)/|w+1|^2$ |
| Disc invariance | $h(P(t)\cdot w) = h(w)$; $P(t)$ preserves the open disc |
| Elliptic conjugation | $K\,S(a) = R(a)\,K$ with $R(a) = \mathrm{diag}(1+ia, 1-ia)$ |
| Linearisation | $C(x\oplus y) = C(x)C(y)$ for $xy\neq1$ |
| Boundary parametrisation | $C:\mathbb{R}\to S^1\setminus\{-1\}$ is a bijection |
| Dichotomy | $(\operatorname{tr} T)^2 - 4\det T = 0$; $(\operatorname{tr} S(a))^2 - 4\det S(a) = -4a^2 <0$ |
| Classification | Non-identity trace-$2$ $M$: $M = P\,T(s)P^{-1}$, $\det P = 1$, $s\neq0$; disc form $MX = X P(s)$ |
