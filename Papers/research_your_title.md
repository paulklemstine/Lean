# Hyperbolic Geometry of the Pythagorean Tree: A Complete Census of the Straight Lines

**Aristotle**

**Date:** 2026-08-07

---

## Abstract

Every primitive Pythagorean triple arises from a unique *Euclid seed* $(m,n)$ with $0<n<m$, $\gcd(m,n)=1$ and $m+n$ odd, and the seeds are organized by three unimodular moves into an infinite ternary tree — the Berggren (Barning–Hall) tree. Embedding a seed as the point $z(m,n) = (n+i)/m$ of the hyperbolic upper half-plane and transporting the picture to the Poincaré disk with $i$ at the centre produces a plot visibly filled with straight rays. We give a complete explanation of that phenomenon.

We prove a master metric identity, $\cosh d(z(m,n),z(m',n')) = 1 + \big((nm'-n'm)^2+(m-m')^2\big)/(2mm')$, whose numerator is built from the determinant of the two seeds, and deduce a *ring theorem*: a seed with hypotenuse $c$ lies at distance strictly between $\tfrac12\log c$ and $\tfrac12\log 2c$ from the centre. We then develop a collinearity calculus based on the hyperbolic Cayley–Menger (Gram) invariant $\Phi$ and prove an *arithmetic bridge*: for seed nodes, $\Phi$ is the square of an integer $3\times3$ determinant divided by $(2m_1m_2m_3)^2$. Consequently straightness is quantized: non-collinear integer seeds have $\Phi \ge (2m_1m_2m_3)^{-2}$.

Collinearity with the centre is then shown to be equality of the *radial invariant* $\varrho(m,n)=(m^2-n^2-1)/(mn)$. Its level sets are the conics $bm^2-amn-bn^2=b$ for $\varrho=a/b$; each carries an explicit automorphism, driven by a solution of the unit equation $s^2-asu-b^2u^2=1$, which acts as a hyperbolic translation of length $\operatorname{arcosh}(s-au/2)$. For integral $\varrho=k$ we classify all positive integral points by Vieta descent, obtain distance quantization in exact multiples of $2\log\lambda_k$ with $\lambda_k=(k+\sqrt{k^2+4})/2$ the $k$-th metallic ratio, prove a parity census guaranteeing infinitely many genuine Euclid seeds on every such line, and establish separation of the pencil, quadratic-irrational ideal endpoints, exact ball counts $\lfloor R/(2\log\lambda_k)\rfloor+1$, hypotenuse growth $\lambda_k^{4j}/2<c_j<\lambda_k^{4j}$, and a *metallic gap* $2\log\lambda_k\ge 2\log\varphi$.

Finally we prove a dichotomy: a rational line is nonempty iff it is infinite iff its discriminant $a^2+4b^2$ is not a perfect square. As a corollary, $(m^2-n^2-1)^2+(2mn)^2$ is never a perfect square for $0<n<m$; hence every node lies on exactly one infinite line through the centre, and the alignment classes partition the nodes. Two negative results complete the picture: horocycles carry only finitely many seeds, and the tree's middle spine, though visually straight, has Gram defect exactly $1$.

**Keywords:** Pythagorean triples, Berggren tree, hyperbolic geometry, Pell equations, metallic ratios, Cayley–Menger determinant, Diophantine geometry.

---

## 1. Introduction

### 1.1 The Berggren tree

A *Euclid seed* is a pair of integers $(m,n)$ with
$$0<n<m,\qquad \gcd(m,n)=1,\qquad m+n \text{ odd},$$
and it generates the primitive Pythagorean triple
$$(a,b,c) = (m^2-n^2,\ 2mn,\ m^2+n^2).$$
This correspondence between seeds and primitive triples is a bijection. Berggren's theorem (rediscovered by Barning and by Hall) states that the three maps
$$L(m,n)=(2m-n,\,m),\qquad M(m,n)=(2m+n,\,m),\qquad R(m,n)=(m+2n,\,n)$$
preserve seedhood and generate, from the root $(2,1)$, every seed exactly once. The set of primitive triples is thus an infinite rooted ternary tree with no repetitions.

### 1.2 The picture

Send each seed to the upper half-plane point
$$z(m,n) = \frac{n+i}{m} = \left(\frac{n}{m},\ \frac1m\right) \in \mathbb H,$$
and map $\mathbb H$ to the unit disk by the Cayley transform $w=(z-i)/(z+i)$, which sends the base point $i = z(1,0)$ to the origin. Plotting all seeds with $m \le 90$ produces a picture dominated by long, exactly aligned files of nodes radiating from the centre. The question this paper answers is: *which alignments are exact, why, and how many are there?*

Throughout, $d$ denotes the hyperbolic distance of $\mathbb H$ (curvature $-1$), and the base point $i$ is called the *centre*. Because the Cayley map is an isometry, all metric statements may be made in $\mathbb{H}$ and read off in the disk.

### 1.3 Summary of results

1. **Metric dictionary** (§2): master identity, base-point distance, ring theorem.
2. **Collinearity calculus** (§3): Gram invariant, arithmetic bridge, quantization of straightness.
3. **Lines through the centre** (§4): radial invariant, conic classification, distance quantization, parity census.
4. **The pencil** (§5): separation, ideal endpoints, counting law, hypotenuse growth, metallic gap, horocycle rigidity.
5. **Rational lines and the dichotomy** (§6–§7): automorphisms from unit equations, empty-or-infinite dichotomy, the Diophantine corollary.
6. **Alignment classes** (§8): exhaustiveness, partition, and the final answer to the visual question.
7. **Impostors** (§9): the middle spine and the hypercycles.

---

## 2. The metric dictionary

### 2.1 The master identity

For $z,w \in \mathbb H$ one has $\cosh d(z,w) = 1 + \dfrac{(\operatorname{Re}z-\operatorname{Re}w)^2+(\operatorname{Im}z-\operatorname{Im}w)^2}{2\operatorname{Im}z \operatorname{Im}w}$.

> **Theorem 2.1 (Master identity).** For real $m,m'>0$ and arbitrary real $n,n'$,
> $$\cosh d\big(z(m,n),z(m',n')\big) \;=\; 1+\frac{(nm'-n'm)^2+(m-m')^2}{2mm'} .$$

*Proof.* Substitute $\operatorname{Re} z = n/m$, $\operatorname{Im} z = 1/m$ and clear denominators; the identity
$$\left(\frac nm-\frac{n'}{m'}\right)^2+\left(\frac1m-\frac1{m'}\right)^2 = \frac{(nm'-n'm)^2+(m-m')^2}{m^2m'^2}$$
together with $2\operatorname{Im}z\operatorname{Im}w = 2/(mm')$ gives the claim. $\square$

The numerator carries the determinant $nm'-n'm$ of the two seeds regarded as integer vectors — the arithmetic content of the metric.

> **Corollary 2.2 (Distance from the centre).** For $m>0$,
> $$\cosh d\big(i, z(m,n)\big) = \frac{m^2+n^2+1}{2m} = \frac{c+1}{2m},\qquad c=m^2+n^2 .$$

### 2.2 The ring theorem

> **Theorem 2.3 (Ring theorem).** Let $n \ge 1$ and $m\ge n+1$ be real, $c=m^2+n^2$. Then
> $$\tfrac12\log c \;<\; d\big(i,z(m,n)\big) \;<\; \tfrac12\log(2c),$$
> equivalently the *residual* $\rho = d - \tfrac12\log c$ lies in the open interval $\big(0,\tfrac12\log 2\big)$.

*Proof sketch.* Write $t = (c+1)/(2m) = \cosh d$. From $\cosh d = t$ and $d\ge 0$ we get $e^{d} = t+\sqrt{t^2-1}$. The lower bound is the assertion $\sqrt c < t+\sqrt{t^2-1}$, which reduces, after isolating the square root and squaring, to $c+1 < 2t\sqrt{c}$, i.e. $m\,(c+1) < (c+1)\sqrt c \cdot \tfrac{m}{m}$ — concretely to $\sqrt c > m$, true because $n \ge 1$. The upper bound is the assertion $t+\sqrt{t^2-1}<\sqrt{2c}$, which reduces to the polynomial inequality $2c(c+1)^2 < m^2(2c+1)^2$; this follows from $m^2-n^2\ge 2n+1$ and $c > n^2$ by a routine positivity argument. $\square$

Both bounds are sharp and neither is attained. Empirically, over the $32{,}335$ seeds with $m<400$ the residual ranges over $[0.0000032,\,0.3453]$, against the theoretical ceiling $\tfrac12\log2 = 0.3465736$.

Theorem 2.3 is the reason for the logarithmic pile-up in the plot: seeds inside the ball of radius $R$ are essentially the seeds with $c \lesssim e^{2R}$, and their number therefore grows exponentially in $R$.

---

## 3. A collinearity calculus

### 3.1 The Gram invariant

> **Definition 3.1.** For $c_1,c_2,c_3 \in \mathbb R$ set
> $$\Phi(c_1,c_2,c_3) = 2c_1c_2c_3-c_1^2-c_2^2-c_3^2+1 .$$
> For $P,Q,R \in \mathbb H$ the *Gram invariant* of the triangle is $\Phi\big(\cosh d(P,Q),\cosh d(Q,R),\cosh d(P,R)\big)$.

This is the hyperbolic Cayley–Menger determinant; it is exactly the Gram determinant of the three lifts to the hyperboloid model.

> **Theorem 3.2 (Collinearity calculus).** Let $P,Q,R\in\mathbb H$ and write $\Phi$ for their Gram invariant. Then
> 1. if $\Phi>0$ then $d(P,Q)+d(Q,R) > d(P,R)$ (strict triangle inequality);
> 2. if $\Phi=0$ then $d(P,Q)+d(Q,R)=d(P,R)$, i.e. $Q$ lies on the geodesic segment $PR$;
> 3. conversely $d(P,Q)+d(Q,R)=d(P,R)$ implies $\Phi=0$.

*Proof sketch.* Write $c_i$ for the three hyperbolic cosines and $s_i=\sqrt{c_i^2-1}$ for the corresponding sines. The addition formula gives
$$\cosh\big(d(P,Q)+d(Q,R)\big) = c_1c_2+s_1s_2 .$$
A direct computation shows $(c_1c_2+s_1s_2)^2 - c_3^2 = \Phi + (\text{terms that cancel})$; more precisely $(c_1c_2 - c_3)^2 - s_1^2s_2^2 = -\Phi$, so $c_1c_2+s_1s_2 \ge c_3$ with equality exactly when $\Phi=0$. Monotonicity of $\cosh$ on $[0,\infty)$ converts this into the three statements. $\square$

### 3.2 The arithmetic bridge

> **Definition 3.3.** The *seed determinant* of three seeds is
> $$\Delta(m_1,n_1;m_2,n_2;m_3,n_3) \;=\; \det\begin{pmatrix} n_1^2+1 & n_1m_1 & m_1^2\\ n_2^2+1 & n_2m_2 & m_2^2\\ n_3^2+1 & n_3m_3 & m_3^2\end{pmatrix}.$$

The rows are the coefficient vectors of the three nodes with respect to the pencil of circles centred on the real axis; $\Delta = 0$ says precisely that the three half-plane points lie on one such circle, i.e. on one geodesic.

> **Theorem 3.4 (Arithmetic bridge).** For $m_1,m_2,m_3 \ne 0$ the Gram invariant of the three seed nodes equals
> $$\Phi \;=\; \left(\frac{\Delta}{2m_1m_2m_3}\right)^{\!2}.$$

*Proof.* Substitute the master identity for each $\cosh$-distance into $\Phi$ and clear denominators; both sides become the same polynomial in $m_i,n_i$. (The identity is an exact polynomial identity, verified by expansion.) $\square$

Two immediate consequences:

> **Corollary 3.5 (Nonnegativity).** For seed nodes $\Phi \ge 0$, with equality iff $\Delta=0$.

> **Theorem 3.6 (Quantization of straightness).** Let $(m_i,n_i)$ be *integer* seeds with $m_i>0$. Either $\Delta = 0$ (exact collinearity) or
> $$\Phi \;\ge\; \frac{1}{(2m_1m_2m_3)^2}.$$

*Proof.* $\Delta$ is an integer, so $\Delta \neq 0$ implies $|\Delta| \ge 1$; apply Theorem 3.4. $\square$

Thus the picture admits no near-lines: an alignment that is not exact fails by an amount bounded below in terms of the sizes of the nodes involved. This is the precise sense in which a plot cannot mislead — it can only be under-resolved.

---

## 4. The lines through the centre

### 4.1 The radial invariant

Setting $(m_1,n_1)=(1,0)$ in Definition 3.3 and expanding gives
$$\Delta(1,0;m_1,n_1;m_2,n_2) = n_1m_1\,(m_2^2-n_2^2-1) - n_2m_2\,(m_1^2-n_1^2-1).$$

> **Definition 4.1.** The *radial invariant* of a node is $\displaystyle \varrho(m,n)=\frac{m^2-n^2-1}{mn}$.

> **Theorem 4.2 (Alignment criterion).** For $m_1,n_1,m_2,n_2>0$, the nodes $z(m_1,n_1)$ and $z(m_2,n_2)$ are exactly hyperbolically collinear with the centre if and only if $\varrho(m_1,n_1)=\varrho(m_2,n_2)$.

*Proof.* Cross-multiply the two fractions; the resulting equation is exactly $\Delta = 0$ as displayed above, and by Theorems 3.2 and 3.4 that is exactly collinearity. $\square$

> **Corollary 4.3.** The level sets of $\varrho$ are conics: for $m,n>0$, $\varrho(m,n)=k \iff m^2-kmn-n^2=1$.

### 4.2 Integral lines: Pell conics

Fix an integer $k \ge 1$ and call $\mathcal C_k: m^2-kmn-n^2=1$ the $k$-th *integral line*.

> **Theorem 4.4.** Any three points of $\mathcal C_k$ are hyperbolically collinear.

*Proof.* On $\mathcal C_k$ one has $n^2+1 = m^2-kmn$, so in $\Delta$ the first column equals (third column) $-\,k\cdot$(second column); the determinant vanishes identically. $\square$

> **Definition 4.5.** The *conic automorphism* is $T_k(m,n) = \big((k^2+1)m+kn,\ km+n\big)$, and $P_j = T_k^{\,j}(1,0)$ is the $j$-th node of the $k$-th line.

$T_k$ has determinant $1$ and preserves the quadratic form $m^2-kmn-n^2$; consequently $P_j \in \mathcal C_k$ for every $j$, and every point of $\mathcal C_k$ is coprime.

> **Theorem 4.6 (Classification).** For $k \ge 1$, every integral point $(m,n)$ of $\mathcal C_k$ with $m>0$ and $n\ge0$ equals $P_j$ for a unique $j\ge0$.

*Proof sketch.* Vieta descent. The inverse map is $T_k^{-1}(m,n) = (m-kn,\ -km+(k^2+1)n)$; one checks it preserves the conic, and that on a point with $m>0$, $n>0$ it strictly decreases $m$ while keeping the coordinates nonnegative. The key auxiliary bound is that a positive point of $\mathcal C_k$ satisfies $kn < m$, which follows from $m^2-kmn = n^2+1 > 0$ together with $m>0$. Descending terminates only at $(1,0)$. $\square$

> **Theorem 4.7 (Quantization of distance).** Let $\lambda_k = \frac{k+\sqrt{k^2+4}}2$ be the $k$-th metallic ratio, the positive root of $\lambda^2=k\lambda+1$. Set $\ell_k = \operatorname{arcosh}(1+k^2/2)$. Then
> $$\ell_k = 2\log\lambda_k,\qquad d(i,P_j) = j\,\ell_k,\qquad d(P_i,P_j)=|i-j|\,\ell_k .$$
> Consequently the $k$-th line is an isometric copy of $\mathbb N$ with spacing $\ell_k$, and *every* integral point of $\mathcal C_k$ lies at a distance from the centre that is an exact multiple of $\ell_k$.

*Proof sketch.* One step of $T_k$ changes $\cosh d$ by the master identity into $1+k^2/2$ regardless of the starting point on the conic — this is a polynomial identity modulo the conic equation. Collinearity (Theorem 4.4) makes the distances add, and induction gives $d(i,P_j)=j\ell_k$. For $e^{\ell_k}$: $\cosh\ell_k = 1+k^2/2$ gives $e^{\ell_k} = 1+\tfrac{k^2}2+\tfrac k2\sqrt{k^2+4} = \lambda_k^2$. $\square$

Numerically: $\ell_1 = 0.962424$, $\ell_2 = 1.762747$, $\ell_3 = 2.389526$; the distances of $(5,2),(29,12),(169,70),(985,408)$ from the centre are $1.7627, 3.5255, 5.2882, 7.0510$ — precisely $j\ell_2$.

### 4.3 The parity census

The points of $\mathcal C_k$ are automatically coprime, but a Euclid seed also requires $m+n$ odd and $n>0$. Which orbit points qualify?

> **Theorem 4.8 (Parity census).**
> 1. If $k$ is even, every $P_j$ with $j\ge1$ is a Euclid seed.
> 2. If $k$ is odd, the parity vector of $P_j$ is periodic of period three, cycling $(\text{odd},\text{even}) \to (\text{even},\text{odd}) \to (\text{odd},\text{odd}) \to \cdots$; hence $P_j$ is a Euclid seed exactly when $j \not\equiv 2 \pmod 3$.
> 3. Consequently, for **every** $k\ge1$ the $k$-th line carries infinitely many Euclid seeds.

*Proof sketch.* For even $k$ the step matrix is $\equiv \begin{pmatrix}1&0\\0&1\end{pmatrix} \pmod 2$ on the relevant residues and preserves the opposite-parity condition. For odd $k$ the step matrix reduces mod $2$ to $\begin{pmatrix}0&1\\1&1\end{pmatrix}$, of order $3$ in $\mathrm{GL}_2(\mathbb F_2)$, which produces the stated three-cycle; the excluded residue $j\equiv2$ is where both coordinates are odd. Positivity and $n<m$ come from Theorem 4.6's monotonicity. $\square$

Computationally, the seed pattern along the orbit for $k=1,\dots,5$ reads
$$\texttt{T F T T F T},\quad \texttt{T T T T T T},\quad \texttt{T F T T F T},\quad \texttt{T T T T T T},\quad \texttt{T F T T F T},$$
exactly as asserted.

---

## 5. The pencil: separation, endpoints, counting, growth

> **Theorem 5.1 (Separation).** If $k \ne k'$ and $(m,n)$ is an integral point of both $\mathcal C_k$ and $\mathcal C_{k'}$ with $m>0$, then $(m,n)=(1,0)$. The integral lines form a genuine pencil through the centre.

*Proof.* Subtracting the two conic equations gives $(k-k')mn = 0$, so $n=0$; then $m^2=1$ and $m>0$. $\square$

> **Theorem 5.2 (Ideal endpoint).** Along the $k$-th line, $n_j/m_j \to 1/\lambda_k = \frac{\sqrt{k^2+4}-k}{2}$, with error $O(m_j^{-2})$.

*Proof sketch.* Dividing $m_j^2-km_jn_j-n_j^2=1$ by $m_j^2$ gives $1-k x_j-x_j^2 = m_j^{-2}$ for $x_j=n_j/m_j$, while $1-k x - x^2$ vanishes at $x = 1/\lambda_k$ and has derivative bounded away from $0$ there; since $m_j \ge j+1 \to \infty$, the claim follows. $\square$

Hence each line escapes to a definite boundary point of the disk, a quadratic irrational: $1/\varphi = 0.618034$ for $k=1$, $\sqrt2-1 = 0.414214$ for $k=2$, and so on. Observed ratios on the golden line: $0.5,\,0.6,\,0.615385,\,0.617647,\dots$

> **Theorem 5.3 (Counting law on one line).** For $R \ge 0$, the number of nodes of the $k$-th line inside the closed ball of radius $R$ about the centre is exactly
> $$N_k(R) = \left\lfloor \frac{R}{2\log\lambda_k}\right\rfloor + 1 ,$$
> and therefore $\dfrac{R}{2\log\lambda_k} < N_k(R) \le \dfrac{R}{2\log\lambda_k}+1$.

*Proof.* By Theorem 4.7 the ball condition is $j\ell_k \le R$, i.e. $j \le \lfloor R/\ell_k\rfloor$. $\square$

> **Theorem 5.4 (Hypotenuse growth).** For $j\ge0$, the hypotenuse $c_{j+1} = m_{j+1}^2+n_{j+1}^2$ of the $(j{+}1)$-st node of the $k$-th line satisfies
> $$\tfrac12\lambda_k^{4(j+1)} \;<\; c_{j+1} \;<\; \lambda_k^{4(j+1)} .$$
> Consequently $\tfrac12\lambda_k^4 < c_{j+2}/c_{j+1} < 2\lambda_k^4$.

*Proof.* Combine the ring theorem (Theorem 2.3), which says $\tfrac12\log c_j < d(i,P_j) < \tfrac12\log 2c_j$, with the exact value $d(i,P_j)=2j\log\lambda_k$. $\square$

Golden line: $c = 5, 34, 233, 1597$ against $\lambda_1^{4j} = 6.854,\,46.98,\,321.997,\,2207.0$ — squeezed as claimed.

> **Theorem 5.5 (Metallic gap).** $\ell_k = 2\log\lambda_k$ is strictly increasing in $k>0$; hence for all $k \ge 1$,
> $$\ell_k \;\ge\; 2\log\varphi = 0.9624236\ldots, \qquad \lambda_k^4 > 6 .$$
> No line of the pencil has its nodes packed more tightly than the golden line, and no exactly collinear family of seeds grows more slowly than the golden rate.

*Proof.* $\lambda_k$ is strictly increasing in $k$ and $\log$ is monotone; $\lambda_1 = \varphi > 1.6$ and $1.6^4=6.5536>6$. $\square$

> **Theorem 5.6 (Counting law for the pencil).** For $R \ge 0$ and $K \ge 1$,
> $$R\sum_{k=1}^{K}\frac1{\ell_k} \;\le\; \sum_{k=1}^{K} N_k(R) \;\le\; R\sum_{k=1}^{K}\frac1{\ell_k} + K,$$
> and uniformly $N_k(R) \le R/(2\log\varphi) + 1$.

Since the number of *all* seeds in the ball is exponential in $R$ (ring theorem), the exactly-collinear part of the picture is a linearly thin skeleton. At $R=10$ the first ten lines contribute $11+6+5+4+4+3+3+3+3+3=45$ nodes in total.

> **Theorem 5.7 (Horocycle rigidity).** For each $t \in \mathbb{R}$ the horocycle $\mathcal H_t = \{w \in \mathbb H : \operatorname{Im} w = t\}$ based at $\infty$ contains only finitely many seed nodes: $z(m,n)\in\mathcal H_t$ forces $m = 1/t$, leaving at most $m-1$ choices of $n$. Together with Theorem 4.8: curves of curvature $0$ through the centre carry infinitely many seeds, curves of curvature $1$ carry only finitely many.

Counts of seeds on $\mathcal H_{1/m}$ for $m=2,\dots,12$: $1,1,2,2,2,3,4,3,4,5,4$ — the number of $n<m$ coprime to $m$ of opposite parity.

---

## 6. Rational lines

The census reveals heavily populated lines with non-integral $\varrho$: for instance $\varrho=2/3$ carries $(3,2),(25,18),(111,80),(949,684)$ and $\varrho=1/2$ carries $(4,3),(41,32),(260,203),(2705,2112)$.

> **Definition 6.1.** For integers $a\ge0$, $b>0$, the *rational line* of radial value $a/b$ is
> $$\mathcal L_{a/b}:\quad bm^2-amn-bn^2=b .$$
> A *unit* for $\mathcal L_{a/b}$ is a pair $(s,u)$ of integers with $s^2-asu-b^2u^2=1$.

> **Proposition 6.2.** $(s,u)$ is a unit for $\mathcal L_{a/b}$ if and only if $(s,bu)$ is a point of $\mathcal L_{a/b}$. Every point of $\mathcal L_{a/b}$ with $m,n>0$ has radial invariant exactly $a/b$; hence by Theorem 4.2 all its points are mutually collinear with the centre.

> **Theorem 6.3 (The line carries its own automorphism).** If $(s,u)$ is a unit, then
> $$S_{s,u}(m,n) = \big(sm+bun,\ \ bum + (s-au)n\big)$$
> maps $\mathcal L_{a/b}$ to itself. Conversely $S_{s,u}$ preserves the conic only if the unit equation holds.

*Proof.* Direct substitution: $b(sm+bun)^2 - a(sm+bun)(bum+(s-au)n) - b(bum+(s-au)n)^2$ equals $(s^2-asu-b^2u^2)\big(bm^2-amn-bn^2\big)$, so the conic is preserved exactly when the scalar is $1$. $\square$

> **Theorem 6.4 (Existence of a unit).** If $a\ge0$, $b>0$ and the discriminant $D = a^2+4b^2$ is not a perfect square, then a unit $(s,u)$ with $s,u>0$ exists.

*Proof sketch.* Solve the classical Pell equation $x^2-Dy^2=1$ in positive integers (possible since $D$ is a non-square positive integer) and substitute $s = x+ay$, $u = 2y$. Then $s^2-asu-b^2u^2 = x^2 - (a^2+4b^2)y^2 = 1$. $\square$

> **Theorem 6.5 (Constant step length and exact collinearity).** Let $(s,u)$ be a unit with $s,u>0$ and let $(m,n)$ be a point of $\mathcal L_{a/b}$ with $m \ge 1$, $n\ge0$. Then
> $$d\big(z(m,n),\ z(S_{s,u}(m,n))\big) = \operatorname{arcosh}\!\left(s-\frac{au}{2}\right),$$
> independently of the point, and the centre, $z(m,n)$ and $z(S_{s,u}(m,n))$ are exactly collinear. In particular, for the orbit $Q_j = S_{s,u}^{\,j}(1,0)$ of the centre,
> $$d(i, z(Q_j)) = j\cdot\operatorname{arcosh}\!\left(s-\frac{au}{2}\right).$$
> A rational line is again an isometric copy of $\mathbb N$.

*Proof sketch.* Insert the images into the master identity and reduce modulo the conic and unit equations; the resulting $\cosh$ is the constant $s-au/2$. Collinearity is Theorem 4.2 plus Proposition 6.2, and the orbit statement follows by induction as in Theorem 4.7. For $b=1$, $(s,u)=(k^2+1,k)$ one recovers $\operatorname{arcosh}(1+k^2/2)$. $\square$

> **Corollary 6.6.** If $a^2+4b^2$ is not a perfect square, $\mathcal L_{a/b}$ has infinitely many integral points with $m,n>0$, all exactly collinear with the centre.

**Worked example ($\varrho=2/3$).** Here $(a,b)=(2,3)$, $D = 4+36=40$ is not a square, and the smallest unit is $(s,u)=(25,6)$: indeed $625-300-324=1$. The step matrix is $\begin{pmatrix}25&18\\18&13\end{pmatrix}$, which sends $(3,2)\mapsto(111,80)$ and $(25,18)\mapsto(949,684)$ — exactly the observed points. The step length is $\operatorname{arcosh}(25-6)=\operatorname{arcosh}19 = 3.63689$, and the measured distances from the centre, $1.4910,\,3.6369,\,5.1279,\,7.2738$, form two interleaved arithmetic progressions of that common difference. The orbit of the centre itself is $(1,0),(25,18),(949,684),(36037,25974)$ at distances $0,\,3.6369,\,7.2738,\,10.9107$.

---

## 7. The square-discriminant dichotomy

What if $D = a^2+4b^2$ *is* a perfect square? Then the quadratic form factors over $\mathbb Z$ and the line collapses.

> **Theorem 7.1 (Empty in the square case).** Let $a\ge0$, $b>0$ with $a^2+4b^2$ a perfect square. Then $\mathcal L_{a/b}$ has **no** integral point with $m,n>0$.

*Proof sketch.* Reduce to the primitive case $\gcd(a,b)=1$ by descent. Squareness of $a^2+(2b)^2$ means $(a,2b,\sqrt D)$ is a Pythagorean triple, so there are coprime $e<f$ with
$$a = f^2-e^2,\qquad b = ef,\qquad \sqrt D = e^2+f^2 .$$
Substituting, the conic becomes
$$(em-fn)(fm+en) = ef .$$
Thus $F := fm+en$ is a positive divisor of $ef$. Since $\gcd(e,f)=1$, every divisor of $ef$ factors as $F = AB$ with $A\mid e$ and $B\mid f$. Reducing $F=fm+en$ modulo the divisors shows $B \mid en$, and $\gcd(B,e)=1$ forces $B\mid n$; likewise $A \mid e$. Hence
$$fm+en = AB \le e\cdot n,$$
contradicting $fm>0$. $\square$

> **Theorem 7.2 (Dichotomy).** For $a\ge0$, $b>0$ the following are equivalent: (i) $\mathcal L_{a/b}$ has a point with $m,n>0$; (ii) it has infinitely many; (iii) $a^2+4b^2$ is not a perfect square. In particular every rational line is either empty or infinite: there are no finite nonempty alignments through the centre.

> **Corollary 7.3 (A Diophantine statement).** For all integers $0<n<m$, the number
> $$(m^2-n^2-1)^2 + (2mn)^2$$
> is never a perfect square. Equivalently, $(m^2-n^2-1,\,2mn)$ is never the pair of legs of a Pythagorean triple.

*Proof.* The node $(m,n)$ lies on its own rational line $\mathcal L_{\varrho(m,n)}$; writing $\varrho = (m^2-n^2-1)/(mn)$ with numerator $a_0=m^2-n^2-1$ and denominator $b_0 = mn$, the discriminant of the (unreduced) line is $a_0^2+4b_0^2$, and reduction by $g=\gcd(a_0,b_0)$ divides it by $g^2$. If that number were a square the line would be empty by Theorem 7.1, contradicting the fact that it contains $(m,n)$. $\square$

An exhaustive sweep over all $0<n<m\le4000$ ($7{,}998{,}000$ pairs) finds no exception, as it must not. Sample empty square-discriminant lines, in factored form:

| $\varrho=a/b$ | $D=a^2+4b^2$ | $(e,f)$ | factorization |
|---|---|---|---|
| $0/1$ | $4 = 2^2$ | $(1,1)$ | $(m-n)(m+n)=1$ |
| $3/2$ | $25 = 5^2$ | $(1,2)$ | $(m-2n)(2m+n)=2$ |
| $8/3$ | $100 = 10^2$ | $(1,3)$ | $(m-3n)(3m+n)=3$ |
| $5/6$ | $169 = 13^2$ | $(2,3)$ | $(2m-3n)(3m+2n)=6$ |
| $16/15$ | $1156 = 34^2$ | $(3,5)$ | $(3m-5n)(5m+3n)=15$ |

---

## 8. Alignment classes: the census is exhaustive

> **Definition 8.1.** The *alignment class* of a node $(m,n)$ is the set of integral points $(p,q)$ with $p,q>0$ that are exactly hyperbolically collinear with $z(m,n)$ and the centre.

> **Theorem 8.2 (Alignment is a conic condition).** For integers $m_1,n_1,m_2,n_2$, the nodes $z(m_1,n_1)$, $z(m_2,n_2)$ and the centre are exactly collinear if and only if $(m_2,n_2)$ lies on the rational line
> $$\mathcal L\big(a,b\big)\quad\text{with}\quad a = m_1^2-n_1^2-1,\ \ b = m_1n_1 .$$
> Hence the alignment class of $(m,n)$ is exactly the positive part of one rational line, and the conic families of §4 and §6 exhaust all alignments through the centre.

*Proof.* Expand $\Delta(1,0;m_1,n_1;m_2,n_2)$; the vanishing condition reads
$$n_1m_1(m_2^2-n_2^2-1) = n_2m_2(m_1^2-n_1^2-1),$$
which is precisely $b\,m_2^2 - a\,m_2n_2 - b\,n_2^2 = b$ with $a,b$ as stated. $\square$

> **Theorem 8.3 (Every node is on an infinite line).** For $0<n<m$, the alignment class of $(m,n)$ contains $(m,n)$ and is infinite.

*Proof.* Membership is the vanishing of a determinant with two equal rows. Infinitude: the class is the positive part of $\mathcal L(a,b)$ by Theorem 8.2, its discriminant is not a perfect square by Corollary 7.3, and so it is infinite by Theorem 7.2. $\square$

> **Theorem 8.4 (Partition).** Alignment through the centre is an equivalence relation on nodes with positive coordinates: it is reflexive, symmetric and transitive. Two nodes are aligned iff their alignment classes coincide. The nodes of the picture are therefore partitioned into pairwise disjoint infinite lines through the centre.

*Proof.* By Theorem 4.2 alignment is the equality $\varrho(m_1,n_1) = \varrho(m_2,n_2)$ of two real numbers, and equality is an equivalence relation. $\square$

Combining Theorems 8.2–8.4 with §4–§6 gives the definitive answer to the visual question:

> **Through every node of the picture there passes exactly one straight line through the centre, that line is the level set of the node's radial invariant, it is an isometric copy of $\mathbb N$ with a step length given by a unit of the associated quadratic form, and it carries infinitely many further nodes.**

Sample classes, with the further Euclid seeds each contains:

| node | $\varrho$ | further seeds in the class | $D$ |
|---|---|---|---|
| $(2,1)$ | $1$ | $(13,8), (34,21), (233,144), (610,377)$ | $5$ |
| $(3,2)$ | $2/3$ | $(25,18), (111,80), (949,684)$ | $40$ |
| $(4,3)$ | $1/2$ | $(41,32), (260,203), (2705,2112)$ | $17$ |
| $(5,2)$ | $2$ | $(29,12), (169,70), (985,408)$ | $8$ |
| $(6,5)$ | $1/3$ | $(85,72), (870,737)$ | $37$ |

(The classes also contain integral non-seed nodes: on the $\varrho=1$ line, for instance, $(5,3)$, $(89,55)$, $(1597,987)$.)

---

## 9. Two impostors

### 9.1 The middle spine is not straight

The middle spine $(2,1)\to(5,2)\to(12,5)\to(29,12)\to\cdots$ obtained by iterating $M(m,n)=(2m+n,m)$ is visually the most conspicuous ray in the plot. It is not a geodesic.

> **Theorem 9.1.** For every $m,n>0$ the triple $\big(i,\ z(m,n),\ z(M(m,n))\big)$ has seed determinant $\Delta = 2m(2m+n)$ and hence Gram invariant
> $$\Phi = 1$$
> exactly. In particular the three points are never collinear, and the excess $d(i,P)+d(P,Q)-d(i,Q)$ is bounded away from $0$.

*Proof.* Substituting $(m_3,n_3)=(2m+n,m)$ into Definition 3.3 and expanding gives $\Delta = 2m(2m+n) = 2m_1m_2m_3$ with $m_1=1$; Theorem 3.4 then gives $\Phi = 1$. $\square$

Numerically, $\Delta = 20, 696, 23660, 803760, 27304196$ along $(2,1)\to(5,2)$, $(12,5)\to(29,12)$, $(70,29)\to(169,70)$, …, and in each case $\Delta/(2m_1m_2m_3) = 1$ exactly.

> **Theorem 9.2 (But the even part is exact).** $M \circ M = T_2$, the automorphism of the conic $m^2-2mn-n^2=1$. Hence the even-indexed nodes of the middle spine, $(5,2),(29,12),(169,70),(985,408),\dots$, do lie on one exact geodesic through the centre, evenly spaced by $2\log(1+\sqrt2) = 1.762747$.

*Proof.* $M(M(m,n)) = M(2m+n,m) = (2(2m+n)+m,\ 2m+n) = (5m+2n,\ 2m+n) = T_2(m,n)$. $\square$

So the spine is a zigzag whose alternate vertices are honestly collinear; the eye interpolates and sees a line.

### 9.2 Hypercycles: linear relations look straight too

Not every visually straight curve is a geodesic. Let $\mathcal V_\alpha = \{w \in \mathbb H: \operatorname{Re} w = \alpha\}$ be a complete vertical geodesic.

> **Theorem 9.3 (Distance to a vertical geodesic).** For any $z \in \mathbb H$ the infimum of $d(z,w)$ over $w \in \mathcal V_\alpha$ is attained and equals
> $$\operatorname{arsinh}\frac{|\operatorname{Re}z - \alpha|}{\operatorname{Im}z}.$$

*Proof sketch.* Set $D = \operatorname{Re}z-\alpha$, $v_0 = \sqrt{D^2+(\operatorname{Im}z)^2}$; a computation shows $\cosh d(z,(\alpha,v_0)) = v_0/\operatorname{Im}z = \cosh \operatorname{arsinh}(|D|/\operatorname{Im}z)$, and for any $(\alpha, v)$ on the geodesic $\cosh d(z,(\alpha,v)) - v_0/\operatorname{Im}z = (v_0-v)^2/(2v\operatorname{Im}z) \ge 0$. $\square$

> **Theorem 9.4 (Hypercycle theorem).** Let $A\ne0$, $B$, $C$ be reals. Every node whose parameters satisfy the affine relation $An+Bm+C=0$ lies at the *constant* distance
> $$\operatorname{arsinh}\left|\frac{C}{A}\right|$$
> from the geodesic $\mathcal V_{-B/A}$. Such a locus is an exact equidistant curve — a hypercycle, of constant geodesic curvature — which in the disk picture is a circular arc that the eye reads as a straight line.

*Proof.* Apply Theorem 9.3 with $\alpha = -B/A$ and $\operatorname{Re}z-\alpha = n/m + B/A = -C/(Am)$, $\operatorname{Im}z = 1/m$; the ratio is $|C/A|$. $\square$

Two corollaries explain the remaining visual structure:

- **Right spines.** $R(m,n)=(m+2n,n)$ fixes $n$. Hence the entire right spine of any node lies on the hypercycle at distance $\operatorname{arsinh}(n)$ from $\mathcal V_0$; the whole family $\{n = \text{const}\}$ is a hypercycle.
- **Left spine.** The seeds $(m,m-1)$ satisfy $n-m+1=0$ and therefore lie at constant distance $\operatorname{arsinh}(1) = 0.881374$ from $\mathcal V_1$.

Thus the complete taxonomy of "straight-looking" curves in the picture: **exact geodesics** through the centre (rational conics, §4–§8), **hypercycles** from affine relations (§9.2), and **zigzags** with a measurable, quantized defect (§3.2, §9.1).

---

## 10. Algorithms

Three computations organize the whole study.

**(A) Radial classification.** For each seed $(m,n)$ compute $\varrho = (m^2-n^2-1)/(mn)$ in lowest terms and bucket seeds by $\varrho$. Cost $O(M^2\log M)$ for all seeds with $m\le M$. By Theorem 4.2 the buckets are exactly the alignment classes: the picture's line structure is recovered by a single hash table, no geometry required.

**(B) Line generation from a unit.** Given $\varrho=a/b$, solve $s^2-asu-b^2u^2=1$ (equivalently $x^2-(a^2+4b^2)y^2=1$ via $s=x+ay$, $u=2y$), then iterate $S_{s,u}$ from any known point. Each iteration is $O(1)$ arithmetic operations on integers whose bit length grows linearly, so producing $J$ nodes costs $O(J^2)$ bit operations. By Theorem 6.5 the $j$-th node is at distance exactly $j\cdot\operatorname{arcosh}(s-au/2)$.

**(C) Exact collinearity test.** Given three seeds, evaluate the integer determinant $\Delta$ of Definition 3.3 with exact arithmetic; $\Delta=0$ certifies collinearity, and $\Delta\ne0$ certifies a Gram defect at least $(2m_1m_2m_3)^{-2}$ (Theorem 3.6). Cost $O(1)$ multiplications. This replaces any floating-point alignment heuristic with a decision procedure.

---

## 11. Discussion

**Why the picture looks the way it does.** Three effects combine. (i) The ring theorem compresses hypotenuses logarithmically, so the nodes accumulate in rings of exponentially growing arithmetic content. (ii) The alignment criterion attaches to each node a single rational number $\varrho$, and equality of $\varrho$ is exactly collinearity with the centre — so the nodes sort themselves into rays automatically. (iii) The dichotomy of §7 forbids short alignments: any two aligned nodes drag infinitely many companions along with them, producing long visible files rather than isolated coincidences. Add to this the quantization theorem, which prohibits near-misses, and the impression of drawn lines becomes inevitable.

**Arithmetic in geometric clothing.** Every geometric quantity in this study is arithmetic: distance from the centre is $\operatorname{arcosh}\frac{c+1}{2m}$; the spacing along a line is $2\log$ of a unit of a real quadratic order; the ideal endpoint of a line is a quadratic irrational; the growth exponent of hypotenuses is the fourth power of a metallic ratio. Conversely, the geometry proves arithmetic: Corollary 7.3, that $(m^2-n^2-1)^2+(2mn)^2$ is never square, is a statement with no geometry in it, obtained from an emptiness theorem about hyperbolic alignments.

**Curvature as an arithmetic filter.** The contrast between Theorem 4.8 (geodesics carry infinitely many seeds) and Theorem 5.7 (horocycles carry finitely many) is a clean instance of a general principle: the arithmetic richness of a curve in a locally symmetric space is governed by the arithmetic of its stabilizer. A geodesic through the centre is stabilized by a real quadratic unit group of infinite order; a horocycle at $\infty$ is stabilized by a unipotent group whose integer points translate $n$ but cannot preserve the coprimality-and-parity constraints indefinitely once $m$ is pinned.

**Thinness.** Theorem 5.6 quantifies how special the lines are: linear count in $R$ against an exponential total. The visible structure is a measure-zero skeleton, made conspicuous by the visual system's sensitivity to exact collinearity.

---

## 12. Future directions

1. **Second-order distribution of the radial invariant.** The class of $\varrho = a/b$ is nonempty iff $a^2+4b^2$ is not a square. How many reduced $a/b$ with $\max(|a|,b)\le X$ have a node with $m\le M$? A local–global heuristic suggests a count asymptotic to $cX^2$ with the density governed by the class numbers of the orders $\mathbb Z[\tfrac{a+\sqrt{a^2+4b^2}}2]$.
2. **Which classes contain Euclid seeds, not merely integral nodes?** Theorem 4.8 answers this for integral $\varrho$; for general $a/b$ the parity of the unit $(s,u)$ should decide it by an analogue of the period-three argument.
3. **A regulator interpretation of the step length.** $\operatorname{arcosh}(s-au/2)$ is $\log$ of a unit; is the step length of the line $a/b$ always an integer multiple of the regulator of the corresponding order, and which multiple?
4. **Angular equidistribution.** The lines emanate towards the ideal points $1/\lambda_k$ and their rational analogues. Do the directions of alignment classes equidistribute on the boundary circle with respect to a natural measure, weighted by density $1/\text{step}$?
5. **Higher analogues.** The tree of Pythagorean triples is the $\mathrm{SO}(2,1)$ story. Does the corresponding tree of Markov triples, or of quadruples of Descartes circle packings, exhibit the same geodesic/hypercycle taxonomy in its natural hyperbolic space?
6. **Effective near-collinearity.** Theorem 3.6 gives a lower bound $(2m_1m_2m_3)^{-2}$ on non-zero Gram defects. Is it attained infinitely often, and does the sequence of minimal defects at height $M$ have a limiting law?

---

## 13. Conclusion

Plotting the tree of Pythagorean triples in the Poincaré disk is not a decorative act: the hyperbolic plane is the natural home of the $2\times2$ integer matrices that build the tree, and in that home the arithmetic draws itself. Distances are determinants; straightness is an integer vanishing; the exact lines through the centre are the level sets of a single rational invariant; each line is a Pell conic in disguise, an evenly spaced ruler whose gauge is a metallic ratio, running out to a quadratic irrational on the boundary; every node lies on exactly one such line, and that line never ends. The lines the eye reports are real, they are completely classified, and the two apparent exceptions — the middle spine, which is a zigzag of defect exactly $1$, and the spines of constant $n$, which are hypercycles rather than geodesics — are explained rather than explained away.
