# The Exact Baker–Norine Rank of a Uniform Divisor on a Complete Graph

**Author:** Aristotle
**Date:** 2026-08-07

---

## Abstract

Let $K_n$ denote the complete graph on $n$ vertices and let $m \cdot \mathbf{1}$ be the divisor placing $m$ chips at every vertex. We prove that for every $n \ge m+2$ the Baker–Norine rank of this divisor is exactly
$$r(m \cdot \mathbf{1}) \;=\; \frac{m(m+3)}{2},$$
a quantity **independent of $n$**. The engine is a complete characterisation of effectivity up to linear equivalence on $K_n$: a divisor $D$ is equivalent to an effective divisor if and only if some integer shift $s$ satisfies $\sum_v \lceil (s - D(v))/n\rceil \le s$. From this criterion we deduce, by averaging over a complete residue window and invoking Hermite's identity $\sum_{s=0}^{n-1}\lfloor (z+s)/n\rfloor = z$, a sharp form of Riemann's inequality on $K_n$: every divisor of degree at least the genus $g = \binom{n-1}{2}$ is equivalent to an effective divisor, and the staircase divisor $(-1,0,1,\dots,n-2)$ of degree $g-1$ shows the bound is sharp. The lower bound $r(m\cdot\mathbf{1}) \ge m(m+3)/2$ is obtained from a fixed-point argument on a monotone threshold function together with a counting identity for ceiling weights, $\sum_{j<m}\lceil (a-j)/n\rceil_+ = m\lfloor a/n\rfloor + \min(m, a \bmod n)$; the proof is constructive and yields an $O(nm)$ algorithm producing an explicit winning firing vector. A matching upper bound comes from an explicit staircase obstruction. Consequences: the rank grows quadratically in $m$, strictly exceeding for $m \ge 3$ the best bound $2m + \lfloor m^2/4\rfloor$ attainable from a single threshold firing; on $K_{2m+3}$ the divisor $m\cdot\mathbf{1}$ is a theta characteristic of the half-canonical degree $g-1$ whose rank $m(m+3)/2$ exceeds the universal $k-1$ half-canonical guarantee quadratically and satisfies $4r > g$, exhibiting complete graphs as extremely far from Brill–Noether general. We also give a linear-time algorithm for the effectivity test on $K_n$, and record numerical evidence for a conjectural formula for the maximum rank over all divisor classes of a given degree.

**Keywords:** chip-firing, Baker–Norine rank, divisor theory on graphs, Riemann–Roch for graphs, complete graph, theta characteristic, Brill–Noether theory, Hermite's identity.

---

## 1. Introduction

### 1.1 The dollar game and its rank

Divisor theory on finite graphs, initiated by Baker and Norine, transplants the language of algebraic curves onto combinatorics. A *divisor* on a graph $G = (V,E)$ is an element $D \in \mathbb{Z}^V$; one thinks of $D(v)$ as a number of chips (possibly negative, i.e. debt) held at $v$. The *degree* is $\deg D = \sum_{v} D(v)$, and $D$ is *effective* if $D(v) \ge 0$ for all $v$.

The dynamics come from *chip firing*: a vertex $v$ fires by sending one chip along each incident edge. If $f \in \mathbb{Z}^V$ records the number of times each vertex fires, the net effect on $D$ is the addition of $L f$, where $L$ is the graph Laplacian,
$$(L f)(v) \;=\; \deg_G(v)\, f(v) \;-\; \sum_{u \sim v} f(u).$$
Two divisors $D, D'$ are *linearly equivalent*, $D \sim D'$, if $D' = D + Lf$ for some $f$. The **dollar game** asks whether a given $D$ is linearly equivalent to an effective divisor.

Baker and Norine refined this binary question into a numerical invariant, the **rank**:
$$r(D) \;=\; \max\{\, r \in \mathbb{Z}_{\ge 0} \;:\; \text{for every effective } E \text{ with } \deg E = r,\ D - E \sim \text{effective} \,\},$$
with the convention $r(D) = -1$ if $D$ itself is not equivalent to an effective divisor. Equivalently, $r(D) \ge r$ means that the configuration survives the adversarial removal of any $r$ chips.

With the **genus** $g = |E| - |V| + 1$ (the first Betti number) and the **canonical divisor** $K_G(v) = \deg_G(v) - 2$, of degree $2g-2$, the central structural theorem is the graph-theoretic Riemann–Roch theorem:
$$r(D) - r(K_G - D) \;=\; \deg D - g + 1 .$$

Ranks are hard to compute: deciding whether $r(D) \ge r$ is NP-hard for general graphs. Explicit rank formulas for infinite families are therefore rare, and formulas for families of *unbounded* rank rarer still.

### 1.2 The problem and the result

This paper computes exactly the rank of the most symmetric divisor on the most symmetric graph.

> **Main Theorem.** Let $m \ge 0$ and $n \ge m+2$. On the complete graph $K_n$, the uniform divisor $m \cdot \mathbf{1}$, with $m$ chips at every vertex, has Baker–Norine rank exactly
> $$r(m\cdot\mathbf{1}) \;=\; \frac{m(m+3)}{2} .$$

Three features deserve emphasis.

1. **Independence of $n$.** The rank does not depend on the size of the graph, only on $m$. This is not visible from Riemann–Roch: the bound $r(D) \ge \deg D - g$ reads $mn - \binom{n-1}{2}$, which is negative for large $n$.
2. **Quadratic growth.** Prior general lower bounds for uniform divisors on graphs of minimum degree $k$ were linear in $m$: a one-shot set-firing estimate gives $\min(3m-1, k+m)$, and a refinement using an optimally chosen threshold set gives $2m + \lfloor m^2/4\rfloor$, still bounded by the ceiling $k+m$. On $K_n$ with $n$ large, the truth is quadratic and unbounded in $m$, and for $m \ge 3$ strictly exceeds $2m + \lfloor m^2/4\rfloor$. Hence *no* single firing move can prove the theorem; a whole coordinated firing vector is required.
3. **Extremality.** For odd $n = 2m+3$, the divisor $m\cdot\mathbf{1}$ is a theta characteristic of degree exactly $g-1$; its rank $m(m+3)/2$ satisfies $4r > g$. Brill–Noether heuristics predict rank at most about $\sqrt{g}$ at degree $g-1$; the complete graph beats this by an order of magnitude.

### 1.3 Method

The complete graph makes the Laplacian degenerate in a very useful way:
$$(L f)(v) \;=\; n f(v) - \sum_u f(u) \qquad \text{on } K_n .$$
Each coordinate depends on $f(v)$ and on the single scalar $\sum_u f(u)$. Consequently, the dollar game on $K_n$ is equivalent to a one-parameter integer optimisation:

> **Effectivity Criterion.** $D$ on $K_n$ is linearly equivalent to an effective divisor if and only if
> $$\exists\, s \in \mathbb{Z} : \quad \sum_{v} \left\lceil \frac{s - D(v)}{n}\right\rceil \;\le\; s .$$

Every result in this paper is a consequence of this criterion. Section 4 derives Riemann's inequality by averaging over a complete residue window; Section 6 derives the exact rank by a fixed-point argument on the threshold parameter; Section 7 handles the extremal witnesses; Section 8 gives linear-time algorithms.

### 1.4 Organisation

Section 2 fixes notation. Section 3 proves the effectivity criterion and its algorithmic consequences. Section 4 proves Riemann's inequality on $K_n$ and its sharpness. Section 5 develops the arithmetic of ceiling weights. Section 6 proves the lower bound, Section 7 the upper bound, and assembles the Main Theorem. Section 8 gives algorithms. Section 9 treats theta characteristics and Brill–Noether specialty. Section 10 presents numerical evidence and conjectures; Section 11 discusses future directions.

---

## 2. Preliminaries

Throughout, $G = (V,E)$ is a finite, simple, connected graph, $|V| = n$.

**Definition 2.1 (Divisor).** A *divisor* on $G$ is a function $D : V \to \mathbb{Z}$. Divisors form the free abelian group $\mathrm{Div}(G) \cong \mathbb{Z}^V$. Its *degree* is $\deg D = \sum_{v\in V} D(v)$. $D$ is *effective*, written $D \ge 0$, if $D(v) \ge 0$ for all $v$.

**Definition 2.2 (Laplacian, linear equivalence).** For $f : V \to \mathbb{Z}$ set $(Lf)(v) = \deg_G(v) f(v) - \sum_{u \sim v} f(u)$. Then $\deg(Lf) = 0$. Write $D \sim D'$ iff $D' - D = Lf$ for some $f$. Since $G$ is connected, $Lf = 0$ iff $f$ is constant.

**Definition 2.3 (Rank).** For a divisor $D$, define $r(D) \ge r$ (for $r \in \mathbb{Z}_{\ge 0}$) to mean: for every effective $E$ with $\deg E = r$ there is $f$ with $D - E + Lf \ge 0$. The *Baker–Norine rank* $r(D)$ is the largest such $r$, or $-1$ if $D \not\sim$ any effective divisor. The predicate is antitone in $r$, and $r(D)$ depends only on the linear equivalence class of $D$.

**Definition 2.4 (Genus, canonical divisor).** $g(G) = |E| - |V| + 1$ and $K_G(v) = \deg_G(v) - 2$. Then $\deg K_G = 2|E| - 2|V| = 2g-2$.

**Theorem 2.5 (Riemann–Roch for graphs; Baker–Norine).** For every divisor $D$ on a connected graph $G$,
$$r(D) - r(K_G - D) = \deg D - g + 1 .$$

**Definition 2.6 (Theta characteristic).** A divisor $D$ is a *theta characteristic* if $2D \sim K_G$. Every theta characteristic has degree $g-1$ and is a fixed point of the residual involution $D \mapsto K_G - D$ on classes of degree $g-1$. By Theorem 2.5 the involution preserves rank, so extremal behaviour at the *half-canonical degree* $g-1$ is naturally studied through these fixed classes.

**Notation 2.7 (Complete graph).** $K_n$ is the complete graph on the vertex set $\{v_1,\dots,v_n\}$; it is $(n-1)$-regular, has $\binom{n}{2}$ edges,
$$g(K_n) = \binom{n}{2} - n + 1 = \frac{(n-1)(n-2)}{2}, \qquad K_{K_n} = (n-3)\cdot\mathbf{1},$$
where $c \cdot \mathbf{1}$ denotes the constant divisor with value $c$. Note $\deg\big((n-3)\mathbf{1}\big) = n(n-3) = 2g-2$, as required.

We write $\lceil x \rceil_+ = \max(\lceil x\rceil, 0)$ for the truncated ceiling of a rational number, and $\lceil a/n \rceil = \lfloor (a+n-1)/n\rfloor$ for integers $a$ and $n \ge 1$.

---

## 3. The effectivity criterion on a complete graph

**Lemma 3.1 (Collapse of the Laplacian).** On $K_n$, for every $f : V \to \mathbb{Z}$ and every $v$,
$$(Lf)(v) = n\,f(v) - \sum_{u} f(u).$$

*Proof.* $\deg_{K_n}(v) = n-1$ and $\sum_{u \sim v} f(u) = \sum_u f(u) - f(v)$, so $(Lf)(v) = (n-1)f(v) - \big(\sum_u f(u) - f(v)\big) = n f(v) - \sum_u f(u)$. $\square$

The whole point is that the coupling between vertices is through the single scalar $\sum_u f(u)$.

**Theorem 3.2 (Effectivity criterion).** Let $n \ge 1$ and let $D$ be a divisor on $K_n$. Then
$$\big(\exists f : D + Lf \ge 0\big) \iff \big(\exists s \in \mathbb{Z} : \textstyle\sum_v \lceil (s - D(v))/n\rceil \le s\big).$$

*Proof.* ($\Rightarrow$) Suppose $D + Lf \ge 0$ and put $s := \sum_u f(u)$. By Lemma 3.1, $D(v) + n f(v) - s \ge 0$ for every $v$, i.e. $f(v) \ge (s - D(v))/n$. As $f(v)$ is an integer, $f(v) \ge \lceil (s-D(v))/n\rceil$. Summing over $v$ gives $s = \sum_v f(v) \ge \sum_v \lceil (s-D(v))/n\rceil$.

($\Leftarrow$) Given such an $s$, define $f(v) := \lceil (s - D(v))/n\rceil$ and let $S := \sum_v f(v) \le s$. By definition of the ceiling, $n f(v) \ge s - D(v)$, so
$$(D + Lf)(v) = D(v) + n f(v) - S \;\ge\; D(v) + \big(s - D(v)\big) - S \;=\; s - S \;\ge\; 0 . \qquad\square$$

The converse direction is constructive: the shift $s$ *is* the winning strategy.

**Definition 3.3 (Deficiency).** For a divisor $D$ on $K_n$ set
$$\varphi_D(s) \;=\; \sum_v \left\lceil \frac{s - D(v)}{n}\right\rceil - s, \qquad d(D) \;=\; \min_{s\in\mathbb{Z}} \varphi_D(s).$$
By Theorem 3.2, $D \sim$ effective $\iff d(D) \le 0$. (The minimum exists: see Lemma 3.4.)

**Lemma 3.4 (Periodicity).** $\varphi_D(s+n) = \varphi_D(s)$ for all $s$, and
$$\varphi_D(s+1) - \varphi_D(s) \;=\; \#\{v : D(v) \equiv s \pmod n\} - 1 .$$
In particular $d(D)$ is the minimum of $\varphi_D$ over any $n$ consecutive integers.

*Proof.* For integers $a$, $\lceil (a+n)/n\rceil = \lceil a/n\rceil + 1$; summing over $v$ and subtracting $n$ from the $-s$ term gives $\varphi_D(s+n) = \varphi_D(s) + n - n = \varphi_D(s)$. For the increment, $\lceil (s+1-D(v))/n\rceil - \lceil (s-D(v))/n\rceil$ equals $1$ if $n \mid (s - D(v))$ and $0$ otherwise, because the ceiling of an integer sequence with step $1/n$ increases exactly when the argument crosses an integer. Subtracting the $-s$ term's increment of $1$ gives the formula. Summing the increments over one period recovers $n - n = 0$, consistent with periodicity. $\square$

**Remark 3.5.** Lemma 3.4 shows that $\varphi_D$ is a *cyclic prefix-sum* profile determined only by the multiset of residues $D(v) \bmod n$ together with a single base value. This gives an $O(n)$ algorithm for the dollar game on $K_n$ (Section 8), a striking contrast with the NP-hardness of rank computation on general graphs.

**Example 3.6.** On $K_4$ take $D = (-1,0,1,2)$. Residues mod $4$ are $3,0,1,2$, one in each class, so $\varphi_D$ is constant; evaluating at $s = 2$ gives $\lceil 3/4\rceil + \lceil 2/4\rceil + \lceil 1/4\rceil + \lceil 0/4\rceil - 2 = 1+1+1+0-2 = 1$. Hence $d(D) = 1 > 0$: the configuration can never be rescued. Adding a single chip to the last vertex, $D' = (-1,0,1,3)$, gives $d(D') = 0$.

---

## 4. Riemann's inequality on a complete graph

We now prove, from Theorem 3.2 alone, the graph analogue of Riemann's inequality on $K_n$. The proof averages the criterion over a complete residue window; the mechanism is Hermite's identity.

**Lemma 4.1 (Ceiling as a floor).** For integers $y$ and $n \ge 1$, $-\lfloor y/n\rfloor = \lfloor (-y+n-1)/n\rfloor$.

*Proof.* Write $y = nq + t$ with $0 \le t < n$. Then $-y + n - 1 = (n-1-t) + n(-q)$ and $0 \le n-1-t < n$, so the right-hand side is $-q$. $\square$

**Lemma 4.2 (Hermite's identity).** For every integer $z$ and every $n \ge 1$,
$$\sum_{s=0}^{n-1} \left\lfloor \frac{z+s}{n}\right\rfloor \;=\; z .$$

*Proof.* Write $z = nq + t$, $0 \le t < n$. For $0 \le s < n$, $\lfloor (z+s)/n\rfloor = q + \lfloor (t+s)/n\rfloor$, and $\lfloor (t+s)/n\rfloor$ is $1$ exactly when $s \ge n-t$ and $0$ otherwise. There are $t$ such $s$, so the sum is $nq + t = z$. $\square$

**Theorem 4.3 (Riemann's inequality on $K_n$).** Let $n \ge 1$ and let $D$ be a divisor on $K_n$ with $\deg D \ge g(K_n) = \frac{(n-1)(n-2)}{2}$. Then $D$ is linearly equivalent to an effective divisor.

*Proof.* Suppose not. By Theorem 3.2, for every $s \in \mathbb{Z}$ we have $\sum_v \lceil (s-D(v))/n\rceil \ge s+1$. Apply this for $s = 0,1,\dots,n-1$ and sum:
$$\sum_{s=0}^{n-1}(s+1) \;\le\; \sum_{s=0}^{n-1}\sum_v \left\lceil \frac{s-D(v)}{n}\right\rceil .$$
The left-hand side is $n(n+1)/2$. For the right-hand side, use Lemma 4.1 with $y = D(v) - s$:
$$\left\lceil \frac{s-D(v)}{n}\right\rceil = -\left\lfloor \frac{D(v)-s}{n}\right\rfloor = \left\lfloor \frac{(-D(v)+n-1) + s}{n}\right\rfloor .$$
Exchanging the order of summation and applying Lemma 4.2 with $z = -D(v)+n-1$ for each $v$:
$$\sum_v \sum_{s=0}^{n-1} \left\lfloor \frac{(-D(v)+n-1)+s}{n}\right\rfloor = \sum_v \big(-D(v)+n-1\big) = -\deg D + n(n-1).$$
Therefore $\frac{n(n+1)}{2} \le n(n-1) - \deg D$, i.e.
$$\deg D \;\le\; n(n-1) - \frac{n(n+1)}{2} \;=\; \frac{n(n-3)}{2} \;=\; \frac{(n-1)(n-2)}{2} - 1 \;=\; g - 1 ,$$
contradicting $\deg D \ge g$. $\square$

**Corollary 4.4.** If $\deg D \ge g + r$ with $r \ge 0$, then $r(D) \ge r$ on $K_n$.

*Proof.* For effective $E$ of degree $r$, $\deg(D-E) \ge g$, so $D - E \sim$ effective by Theorem 4.3. $\square$

Riemann's inequality is sharp, and the witnesses are the *staircase* divisors, which will also supply the upper bound in Section 7.

**Definition 4.5 (Staircase divisor).** For $n \ge m+2$ let
$$S_{n,m} \;=\; \big(\,{-1},\ 0,\ 1,\ 2,\ \dots,\ m,\ \underbrace{m,\ \dots,\ m}_{n-m-2}\,\big) \in \mathbb{Z}^{n},$$
i.e. $S_{n,m}(v_1) = -1$, $S_{n,m}(v_{i}) = i-2$ for $2 \le i \le m+2$, and $S_{n,m}(v_i) = m$ for $i > m+2$. Its degree is
$$\deg S_{n,m} \;=\; -1 + \frac{m(m+1)}{2} + (n-m-2)m \;=\; mn - \frac{m(m+3)}{2} - 1 .$$

**Proposition 4.6 (The staircase is stuck).** For $n \ge m+2$, $d(S_{n,m}) = 1$; in particular $S_{n,m}$ is not linearly equivalent to any effective divisor.

*Proof.* Write $S = S_{n,m}$. Every value of $S$ lies in $[-1, m]$ with $m \le n-2$. Take the window $s \in \{-1, 0, \dots, n-2\}$, a complete set of residues mod $n$ (Lemma 3.4). For such $s$ and any vertex $v$ we have $s - S(v) \in (-n, n]$, so
$$\left\lceil \frac{s-S(v)}{n}\right\rceil = \begin{cases} 1, & S(v) < s,\\ 0, & S(v) \ge s,\end{cases}$$
whence $\varphi_S(s) = \#\{v : S(v) < s\} - s$. Now:

* $s = -1$: no value is $< -1$, so $\varphi_S(-1) = 0 - (-1) = 1$.
* $0 \le s \le m$: the values below $s$ are $-1$ and $0,1,\dots,s-1$, that is $s+1$ vertices (the plateau contributes nothing since $m \ge s$). So $\varphi_S(s) = (s+1)-s = 1$.
* $m+1 \le s \le n-2$: all $n$ values are $< s$, so $\varphi_S(s) = n - s \ge 2$.

Hence $\min \varphi_S = 1 > 0$. $\square$

**Corollary 4.7 (Sharpness of Theorem 4.3).** Taking $m = n-2$, the divisor $S_{n,n-2} = (-1,0,1,\dots,n-2)$ has degree exactly $g - 1$ and is not equivalent to an effective divisor. So the hypothesis $\deg D \ge g$ in Theorem 4.3 cannot be weakened.

*Proof.* $\deg S_{n,n-2} = -1 + \sum_{i=0}^{n-2} i = \frac{(n-1)(n-2)}{2} - 1 = g-1$; apply Proposition 4.6. $\square$

---

## 5. Ceiling weights and a counting identity

The lower bound in Section 6 requires precise control on sums of truncated ceilings. Fix $n \ge 1$.

**Definition 5.1.** For $a, j \in \mathbb{Z}_{\ge 0}$ put
$$w(a,j) \;=\; \left\lceil \frac{a-j}{n}\right\rceil_{\!+} \;=\; \left\lfloor \frac{(a \dot- j) + n - 1}{n}\right\rfloor ,$$
where $a \dot- j = \max(a-j, 0)$ is truncated subtraction.

**Lemma 5.2 (Defining property).** $a \le j + n\, w(a,j)$ for all $a, j \ge 0$.

*Proof.* If $a \le j$ then $w \ge 0$ and the claim is clear. Otherwise $n w(a,j) = n\lceil (a-j)/n\rceil \ge a-j$. $\square$

**Lemma 5.3 (Antitonicity).** If $j \le j'$ then $w(a,j') \le w(a,j)$.

**Lemma 5.4 (Exact value).** If $0 \le j < n$ and $a = nQ + R$ with $0 \le R < n$, then
$$w(a,j) \;=\; Q + [\,j < R\,],$$
where $[\,\cdot\,]$ is the Iverson bracket.

*Proof.* If $j < R$ then $a - j = nQ + (R-j)$ with $0 < R - j \le n-1$, so the ceiling is $Q+1$. If $j \ge R$ and $Q \ge 1$ then $a-j = n(Q-1) + (R + n - j)$ with $0 < R+n-j \le n$, giving $Q$. If $j \ge R$ and $Q = 0$ then $a = R \le j$, so the truncated value is $0 = Q$. $\square$

**Proposition 5.5 (Counting identity).** For $m \le n$, $a \ge 0$, writing $a = nQ + R$ with $0 \le R < n$,
$$\sum_{j=0}^{m-1} w(a,j) \;=\; mQ + \min(m, R) .$$

*Proof.* Immediate from Lemma 5.4: the bracket contributes $1$ for exactly $\min(m,R)$ indices $j \in \{0,\dots,m-1\}$. $\square$

**Corollary 5.6 (Weight sums do not overshoot).** If $m + 2 \le n$ then $\sum_{j<m} w(a,j) \le a$ for every $a \ge 0$, with **strict** inequality whenever $a \ge m+1$.

*Proof.* With $a = nQ+R$: $\sum_{j<m} w(a,j) = mQ + \min(m,R) \le nQ + R = a$ since $m \le n$. For strictness with $a \ge m+1$: if $Q = 0$ then $a = R$ and the sum is $\min(m,a) = m \le a - 1$. If $Q \ge 1$ then $nQ \ge (m+2)Q \ge mQ + 2$, so $a = nQ + R \ge mQ + R + 2 \ge mQ + \min(m,R) + 2$. $\square$

Corollary 5.6 is the arithmetic heart of the argument: the total cost of firing, aggregated over all thresholds, is strictly cheaper than the number of chips the adversary spent, provided the adversary concentrated more than $m$ chips somewhere.

---

## 6. The lower bound

**Theorem 6.1 (Lower bound).** Let $n \ge m+2$ and $r = \frac{m(m+3)}{2}$. Then on $K_n$,
$$r(m\cdot\mathbf{1}) \;\ge\; r .$$

*Proof.* Let $E \ge 0$ be effective with $\deg E = r$; write $A(v) = E(v) \in \mathbb{Z}_{\ge 0}$, so $\sum_v A(v) = r$. We must produce $f$ with $m\cdot\mathbf{1} - E + Lf \ge 0$.

**Case 1: $A(v) \le m$ for every $v$.** Then $m\cdot\mathbf{1} - E \ge 0$ already; take $f = 0$.

**Case 2: $A(v_0) \ge m+1$ for some $v_0$.** For a threshold $t \in \{1,\dots,m\}$ define the *cost*
$$T(t) \;=\; \sum_v w\big(A(v),\, m-t\big) .$$
By Lemma 5.3, $T$ is nondecreasing in $t$.

*Step 1: some threshold pays for itself.* We claim there is $t \in \{1,\dots,m\}$ with $T(t) \le t$. Suppose not, so $T(t) \ge t+1$ for all $t \in \{1,\dots,m\}$. Substituting $t = j+1$ for $j = 0,\dots,m-1$ and summing:
$$\sum_{j=0}^{m-1}(j+2) \;\le\; \sum_{j=0}^{m-1} T(j+1) \;=\; \sum_v \sum_{j=0}^{m-1} w\big(A(v), m-1-j\big) \;=\; \sum_v \sum_{j=0}^{m-1} w\big(A(v), j\big),$$
the last step being the reflection $j \mapsto m-1-j$ of the inner index. By Corollary 5.6 the right side is $\le \sum_v A(v) = r$, and *strictly* less because the vertex $v_0$ has $A(v_0) \ge m+1$. But the left side is
$$\sum_{j=0}^{m-1} (j+2) = \frac{m(m-1)}{2} + 2m = \frac{m(m+3)}{2} = r .$$
So $r < r$, a contradiction.

*Step 2: the least such threshold is a fixed point.* Let $t$ be minimal in $\{1,\dots,m\}$ with $T(t) \le t$. We claim $T(t) = t$.
If $t = 1$: since $A(v_0) \ge m+1 > m-1$, we have $w(A(v_0), m-1) \ge 1$, so $T(1) \ge 1$; with $T(1) \le 1$ this gives $T(1) = 1$.
If $t \ge 2$: by minimality $T(t-1) \ge t$, and by monotonicity $T(t-1) \le T(t) \le t$; hence $T(t) = t$.

*Step 3: the firing vector.* Define
$$f(v) \;=\; w\big(A(v), m-t\big) - 1 .$$
Then $\sum_u f(u) = T(t) - n = t - n$. By Lemma 3.1, for each $v$,
$$\big(m\cdot\mathbf{1} - E + Lf\big)(v) = m - A(v) + n\,f(v) - (t-n) = m - A(v) + n\, w\big(A(v), m-t\big) - t .$$
By Lemma 5.2 applied with $j = m-t$, $A(v) \le (m-t) + n\, w(A(v), m-t)$, so the displayed quantity is $\ge m - (m-t) - t = 0$. Hence $m\cdot\mathbf{1} - E + Lf$ is effective. $\square$

**Remark 6.2 (Why one shot is not enough).** The two "one-shot" strategies in the literature fire the complement of a single set $\{v : E(v) \ge t\}$, and their yield is $\min(3m-1, k+m)$ and $\min\big(2m+\lfloor m^2/4\rfloor,\ k+m\big)$ respectively, where $k$ is the minimum degree. On $K_n$ with $n$ large the cap $k+m$ is irrelevant, and Theorem 6.1 beats both as soon as $m \ge 3$ (see Corollary 7.4). The reason is visible in the proof: the winning $f$ takes *many distinct values* $w(A(v), m-t) - 1$, i.e. different vertices fire different numbers of times. A set firing takes only two values.

**Remark 6.3 (Complexity).** Steps 1–3 constitute an algorithm: compute $T(1), T(2), \dots$ until $T(t) \le t$, then output $f$. Each evaluation of $T$ costs $O(n)$, so the algorithm runs in $O(nm)$ time and produces a certified firing vector.

---

## 7. The upper bound and the Main Theorem

**Theorem 7.1 (Upper bound; staircase obstruction).** Let $n \ge m+2$ and $r = \frac{m(m+3)}{2}$. Then on $K_n$ it is **not** the case that $r(m\cdot\mathbf{1}) \ge r+1$; that is, $r(m\cdot\mathbf{1}) \le r$.

*Proof.* Consider the effective *staircase test divisor*
$$E^\ast \;=\; \big(m+1,\ m,\ m-1,\ \dots,\ 1,\ 0,\ \underbrace{0,\dots,0}_{n-m-2}\big),$$
so $E^\ast(v_1) = m+1$, $E^\ast(v_i) = m - (i-2)$ for $2 \le i \le m+2$, and $E^\ast(v_i) = 0$ for $i > m+2$. Its degree is
$$\deg E^\ast = (m+1) + \sum_{j=0}^{m} j = (m+1) + \frac{m(m+1)}{2} = \frac{m(m+3)}{2} + 1 = r+1 .$$
Subtracting, $m\cdot\mathbf{1} - E^\ast$ has value $-1$ at $v_1$, value $m - (m-(i-2)) = i-2$ at $v_i$ for $2 \le i \le m+2$, and value $m$ elsewhere: precisely the staircase divisor $S_{n,m}$ of Definition 4.5. By Proposition 4.6, $d(S_{n,m}) = 1 > 0$, so $m\cdot\mathbf{1} - E^\ast$ is not linearly equivalent to an effective divisor. Since $E^\ast$ is effective of degree $r+1$, this witnesses $r(m\cdot\mathbf{1}) < r+1$. $\square$

**Theorem 7.2 (Main Theorem).** For $n \ge m+2$, on the complete graph $K_n$,
$$r(m\cdot\mathbf{1}) \;=\; \frac{m(m+3)}{2} .$$
In particular the rank is independent of $n$.

*Proof.* Combine Theorems 6.1 and 7.1. $\square$

**Corollary 7.3 (Riemann–Roch consistency).** On $K_n$ the canonical divisor is $(n-3)\mathbf{1}$, so the residual of $m\cdot\mathbf{1}$ is $(n-3-m)\mathbf{1}$, uniform again. For $0 \le m \le n-3$ Theorem 7.2 applies to both (note $n \ge (n-3-m)+2$ whenever $m \ge -1$), and Riemann–Roch reads
$$\frac{m(m+3)}{2} - \frac{(n-3-m)(n-m)}{2} \;=\; mn - \frac{(n-1)(n-2)}{2} + 1 ,$$
an identity verified by expansion. Equivalently, the upper and lower bounds of Theorem 7.2 are exchanged by $m \leftrightarrow n-3-m$: for $m \le n-3$, either half of the theorem implies the other. For $m = n-2$ the residual is $(-1)\mathbf{1}$, which has rank $-1$, and Riemann–Roch gives $r = m n - g = \frac{m(m+3)}{2}$ directly.

*Proof of the displayed identity.* Put $M = n-3-m$. Then $m + M = n-3$ and
$$\frac{m^2+3m}{2} - \frac{M^2+3M}{2} = \frac{(m-M)(m+M+3)}{2} = \frac{(2m-n+3)\,n}{2} = mn - \frac{n^2-3n}{2},$$
while $mn - \frac{(n-1)(n-2)}{2} + 1 = mn - \frac{n^2-3n+2}{2} + 1 = mn - \frac{n^2-3n}{2}$. $\square$

**Corollary 7.4 (One-shot firing is insufficient).** For $m \ge 3$ and $n \ge m+2$,
$$r(m\cdot\mathbf{1}) \;=\; \frac{m(m+3)}{2} \;>\; 2m + \left\lfloor \frac{m^2}{4}\right\rfloor \;\ge\; 3m-1 ,$$
so the exact rank strictly exceeds the best bound obtainable from a single threshold set firing.

*Proof.* $\frac{m^2+3m}{2} - 2m - \frac{m^2}{4} = \frac{m^2 - 2m}{4} = \frac{m(m-2)}{4} > 0$ for $m \ge 3$; the floor only helps. $\square$

Numerically:

| $m$ | $1$ | $2$ | $3$ | $4$ | $5$ | $6$ | $7$ | $8$ | $10$ | $12$ |
|---|---|---|---|---|---|---|---|---|---|---|
| exact rank $m(m+3)/2$ | $2$ | $5$ | $9$ | $14$ | $20$ | $27$ | $35$ | $44$ | $65$ | $90$ |
| set-firing bound $3m-1$ | $2$ | $5$ | $8$ | $11$ | $14$ | $17$ | $20$ | $23$ | $29$ | $35$ |
| threshold bound $2m+\lfloor m^2/4\rfloor$ | $2$ | $5$ | $8$ | $12$ | $16$ | $21$ | $26$ | $32$ | $45$ | $60$ |

---

## 8. Algorithms

The criterion of Theorem 3.2 turns three natural computational problems on $K_n$ into elementary integer routines.

### 8.1 Deciding the dollar game in linear time

By Lemma 3.4, $\varphi_D$ is $n$-periodic with increments determined by the residue histogram of $D$. This yields:

```
Input: D in Z^n.
1. c[j] <- #{ v : D(v) = j (mod n) }, for j = 0..n-1.        // O(n)
2. s0 <- min_v D(v);  phi <- sum_v ceil((s0 - D(v))/n) - s0.  // O(n)
3. best <- phi.
4. for s = s0 to s0 + n - 1:
       phi <- phi + c[s mod n] - 1
       best <- min(best, phi)
5. return best.        // best = d(D);  D ~ effective  iff  best <= 0.
```

**Proposition 8.1.** The algorithm returns $d(D)$ in $O(n)$ arithmetic operations.

*Proof.* Correctness of the increment is Lemma 3.4; periodicity guarantees a window of $n$ consecutive shifts contains a global minimiser. Each step is $O(n)$. $\square$

This should be contrasted with the general situation, where deciding $r(D) \ge r$ is NP-hard.

### 8.2 Constructing a winning firing vector

Given the uniform divisor $m\cdot\mathbf{1}$ on $K_n$ ($n \ge m+2$) and any effective $E$ of degree at most $\frac{m(m+3)}{2}$, the proof of Theorem 6.1 is an algorithm:

```
Input: n, m, effective E with deg E <= m(m+3)/2.
1. if E(v) <= m for all v: return f = 0.
2. for t = 1, 2, ..., m:
       T <- sum_v ceil_+((E(v) - (m - t))/n)
       if T <= t: return f(v) = ceil_+((E(v) - (m - t))/n) - 1  for all v.
3. (unreachable)
```

**Proposition 8.2.** The algorithm terminates, runs in $O(nm)$ time, and its output satisfies $m\cdot\mathbf{1} - E + Lf \ge 0$.

*Proof.* Termination is Step 1 of the proof of Theorem 6.1; correctness is Step 3 there, using that the first $t$ found is the minimal one, hence a fixed point $T(t) = t$. Each of the at most $m$ iterations costs $O(n)$. $\square$

### 8.3 Computing ranks exactly

Since $r(D) + 1$ is the least degree of an effective $E$ with $D - E \not\sim$ effective, and effectivity is decidable in $O(n)$, one can compute the exact rank of any divisor on $K_n$ by enumerating effective test divisors in order of degree. The enumeration is exponential in general, but for small $n$ it is entirely practical and was used to verify all the exact values reported here.

---

## 9. Theta characteristics and Brill–Noether specialty

The degree $g-1$ is distinguished: it is fixed by the residual involution $D \mapsto K_G - D$, which by Riemann–Roch preserves rank. The classes actually fixed by the involution are the theta characteristics. On complete graphs of odd order these are visible by inspection.

**Theorem 9.1 (Half-canonical theta characteristic on $K_{2m+3}$).** Let $n = 2m+3$ with $m \ge 0$. On $K_n$:

1. $K_{K_n} = (n-3)\mathbf{1} = 2m\cdot\mathbf{1} = 2\,(m\cdot\mathbf{1})$, so $m\cdot\mathbf{1}$ is a theta characteristic (indeed $2D = K$ on the nose, without passing to equivalence);
2. $\deg(m\cdot\mathbf{1}) = m(2m+3) = g(K_n) - 1$;
3. $r(m\cdot\mathbf{1}) = \frac{m(m+3)}{2}$.

*Proof.* (1) is immediate from $K_{K_n}(v) = n-3 = 2m$. For (2), $g = \frac{(n-1)(n-2)}{2} = \frac{(2m+2)(2m+1)}{2} = 2m^2+3m+1$, while $\deg(m\cdot\mathbf{1}) = m(2m+3) = 2m^2+3m = g-1$. (3) is Theorem 7.2, applicable since $n = 2m+3 \ge m+2$. $\square$

**Corollary 9.2 (Beating the universal half-canonical bound).** $K_{2m+3}$ is $k$-regular with $k = 2m+2$. A general theorem guarantees that every simple $k$-regular graph with $k \ge 6$, $k \ne 7$, carries a divisor of degree $g-1$ and rank at least $k-1$. On $K_{2m+3}$ the witness of Theorem 9.1 has rank $\frac{m(m+3)}{2}$, and
$$\frac{m(m+3)}{2} \ge 2m+1 = k-1 \quad (m \ge 2), \qquad \frac{m(m+3)}{2} > k-1 \quad (m \ge 3).$$
So the universal linear-in-$k$ guarantee is attained exactly at $m=2$ (the graph $K_7$, where the rank is $5 = k-1$) and is quadratically far from sharp thereafter.

*Proof.* $\frac{m^2+3m}{2} - (2m+1) = \frac{m^2 - m - 2}{2} = \frac{(m-2)(m+1)}{2}$, which is $\ge 0$ for $m \ge 2$ and $> 0$ for $m \ge 3$. $\square$

**Corollary 9.3 (A quarter of the genus).** With $n = 2m+3$, $g = 2m^2+3m+1$ and $r = \frac{m^2+3m}{2}$,
$$4r - g = 2m^2 + 6m - 2m^2 - 3m - 1 = 3m - 1 > 0 \qquad (m \ge 1).$$
Thus $r > g/4$: the half-canonical rank on a complete graph is a constant proportion of the genus.

**Discussion 9.4 (Brill–Noether).** For a Brill–Noether general object of genus $g$, the expected dimension of the family of degree-$d$ divisor classes of rank $\ge r$ is the Brill–Noether number $\rho = g - (r+1)(g-d+r)$, and classes of rank $\ge r$ exist only when $\rho \ge 0$. At $d = g-1$ this reads $\rho = g - (r+1)^2 \ge 0$, i.e. $r \le \sqrt{g} - 1$. Corollary 9.3 says complete graphs have half-canonical rank $> g/4$, exceeding $\sqrt{g}-1$ by an unbounded factor. Complete graphs are thus extremal specimens of Brill–Noether *special* behaviour — the exact opposite of the random or "generic" regime in which the tropical proof of the Brill–Noether theorem operates.

**Remark 9.5 (Even order).** For $n$ even, $K_{K_n} = (n-3)\mathbf{1}$ has *odd* constant value, so no uniform divisor is half of it and the natural half-canonical witnesses are non-uniform: one takes $\lfloor (n-3)/2\rfloor$ chips at every vertex and dumps the leftover degree on one vertex. On $K_6$ ($k=5$, $g=10$) this gives $(4,1,1,1,1,1)$ of degree $9 = g-1$, whose rank is exactly $2$, well short of $k-1 = 4$; on $K_8$ ($k=7$, $g=21$) it gives $(6,2,2,2,2,2,2,2)$ of degree $20 = g-1$, whose rank is exactly $5 = k-2$. The exact ranks in this regime are governed by Conjecture 10.1.

---

## 10. Numerical evidence and conjectures

All values below were computed exactly by exhaustive search using the effectivity criterion (Section 8.3); every class of the relevant degree is covered, since every class has a $q$-reduced representative whose values away from the base vertex lie in $\{0,1,\dots,n-2\}$.

### 10.1 Verification of the Main Theorem

| $m$ | $n$ | $\deg$ | $g$ | computed $r$ | $m(m+3)/2$ |
|---|---|---|---|---|---|
| $1$ | $3,4,5,6$ | $3,4,5,6$ | $1,3,6,10$ | $2,2,2,2$ | $2$ |
| $2$ | $4,5,6,7$ | $8,10,12,14$ | $3,6,10,15$ | $5,5,5,5$ | $5$ |
| $3$ | $5,6,7$ | $15,18,21$ | $6,10,15$ | $9,9,9$ | $9$ |

The constancy in $n$ is striking: for $m = 2$ the Riemann bound $\deg - g$ reads $5, 4, 2, -1, -5, -10$ as $n$ runs from $4$ to $9$, while the true rank stays at $5$.

### 10.2 The maximum rank over all classes

The uniform divisor is not always optimal in its degree. Exhaustive search over all classes suggests:

> **Conjecture 10.1.** On $K_n$, the maximum of the Baker–Norine rank over all divisor classes of degree $d \ge 0$ is attained at the *concentrated* divisor $d \cdot v$ for any single vertex $v$, and equals
> $$\rho_n(d) \;=\; \frac{a(a+1)}{2} + \min(b, a), \qquad \text{where } d = a(n-1) + b,\ 0 \le b \le n-2 .$$

At the half-canonical degree $d = g-1$ this predicts the sequence
$$0,\ 0,\ 2,\ 2,\ 5,\ 5,\ 9,\ 9,\ 14,\ 14,\ \dots \qquad (n = 3,4,5,\dots),$$
each triangular-type value $j(j+3)/2$ repeated twice. Exhaustive verification for $n \le 6$ confirms both the maximum and that the concentrated divisor attains it; the predicted value is confirmed for the concentrated divisor at $n = 7$ as well (rank $5$ at degree $14$).

A consequence, if the conjecture holds, is that $K_n$ meets the universal half-canonical target $k-1 = n-2$ with *equality* only at $n = 7$. Indeed the two sequences run

| $n$ | $3$ | $4$ | $5$ | $6$ | $7$ | $8$ | $9$ | $10$ | $11$ | $12$ |
|---|---|---|---|---|---|---|---|---|---|---|
| predicted max rank at $g-1$ | $0$ | $0$ | $2$ | $2$ | $5$ | $5$ | $9$ | $9$ | $14$ | $14$ |
| $k-1 = n-2$ | $1$ | $2$ | $3$ | $4$ | $5$ | $6$ | $7$ | $8$ | $9$ | $10$ |

so the maximum is strictly below the target for $n \le 6$ and for $n=8$, equal at $n=7$, and strictly above from $n = 9$ onwards (thereafter the quadratic growth of $\rho_n(g-1) \sim n^2/8$ leaves the linear target far behind).

### 10.3 The residual regularities $k = 5$ and $k = 7$

The universal half-canonical existence theorem covers $k \ge 6$, $k \ne 7$. The complete-graph computations sharpen the picture at the two exceptions.

* At $k=5$: exhaustive enumeration of all $3125$ divisor classes of degree $g-1 = 9$ on the $5$-regular graph $K_6$ shows the maximum rank there is $2 < 4 = k-1$. Hence any statement of the form "every $5$-regular graph on at least $N_0$ vertices carries a divisor of degree $g-1$ and rank $\ge 4$" requires $N_0 > 6$: no threshold-free version can hold.
* At $k=7$: on $K_8$ (degree $g-1 = 20$) every tested witness has rank exactly $5 = k-2$, one short of the target.

These are precisely the two regularities for which the parameter $\lfloor (k-2)/2\rfloor$ lands in $\{1,2\}$ and the one-shot estimates fall short.

---

## 11. Discussion and future directions

### 11.1 What made the complete graph tractable

Three structural facts conspired.

1. **Rank-one coupling.** On $K_n$ the Laplacian is $nI - J$ where $J$ is all-ones; the off-diagonal part has rank one. A firing vector is therefore summarised, from each vertex's point of view, by a single scalar. Anything with this property will admit an analogue of Theorem 3.2.
2. **Convexity and periodicity.** The resulting objective $\varphi_D$ is a piecewise-linear function of a single integer variable whose increments depend only on residues mod $n$ — hence periodic, hence globally minimisable by a linear scan.
3. **A fixed-point structure on thresholds.** The lower bound needed not just existence of a good threshold but the *minimal* one, which is automatically an equilibrium $T(t)=t$. This is a discrete analogue of the least-fixed-point arguments familiar from Dhar's burning algorithm, and it is what makes the winning vector explicit.

### 11.2 Immediate open problems

**Conjecture 10.1** (maximum rank at every degree) is the most concrete. Its truth would give a complete determination of the Brill–Noether behaviour of complete graphs.

**Extension of the criterion.** Which graph families have an effectivity criterion of the shape "$\exists$ a small number of parameters ..."? Complete multipartite graphs have Laplacians of the form (diagonal) $-$ (low-rank), and it seems plausible that the dollar game there reduces to an optimisation in as many integer parameters as there are parts. Strongly regular graphs, and circulants with few distinct eigenvalues, are further candidates. Every such reduction would yield exact rank formulas for a new infinite family.

**The two residual regularities.** Is there a finite $N_0(5)$ such that every simple connected $5$-regular graph on at least $N_0(5)$ vertices carries a divisor of degree $g-1$ and rank at least $4$, and likewise $N_0(7)$ for rank $6$? The $K_6$ computation shows $N_0(5) > 6$, so a genuine threshold is required. Numerical evidence suggests that near-uniform witnesses on $5$-regular circulants have rank exactly $2$ regardless of size, so any proof must select the witness using the structure of the graph, not a universal recipe.

**Scale of the threshold.** The exact positivity criterion for the Brill–Noether number at $(d,r) = (g-1,k-1)$ on a $k$-regular graph on $n$ vertices is $2k^2 \le (k-2)n$, i.e. $n \gtrsim 2k+4$; a sufficient linear bound $n \ge 2k+7$ is available. The plausible sharp threshold is therefore $\Theta(k)$, not $\Theta(k^2)$.

**Theta characteristics as extremal witnesses.** For every even $k \ge 6$, is the maximum of the rank over classes of degree $g-1$ on a $k$-regular graph attained at a theta characteristic? On $K_{2m+3}$ this is what happens: the uniform theta characteristic attains the observed maximum, and Theorem 9.1 identifies it explicitly. Since the theta characteristics form a finite (in fact $2^{2g}$-torsor-like) set of classes, this would replace a search over $\mathrm{Pic}^{g-1}$ by a search over a computable finite set.

### 11.3 Beyond graphs

Baker's specialisation lemma relates the rank of a divisor on an algebraic curve to that of its specialisation on the dual graph of a degeneration: $r_{\text{curve}} \le r_{\text{graph}}$. Theorem 7.2 therefore yields nontrivial *upper* bounds for ranks of divisors on curves degenerating to a configuration whose dual graph is complete — a common situation for stable curves with many components meeting pairwise. The independence of $n$ makes the bound uniform in the number of components. Making this application precise, and identifying the curves for which it is sharp, seems a promising direction.

---

## 12. Summary of results

* **Effectivity criterion.** On $K_n$, $D \sim$ effective $\iff \exists s : \sum_v \lceil (s-D(v))/n\rceil \le s$; the optimal $s$ yields the firing vector explicitly.
* **Linear-time decision.** The deficiency $d(D) = \min_s\big(\sum_v \lceil (s-D(v))/n\rceil - s\big)$ is computable in $O(n)$ from the residue histogram of $D$.
* **Riemann's inequality on $K_n$.** Every divisor of degree $\ge g = \binom{n-1}{2}$ is equivalent to an effective divisor; hence $r(D) \ge \deg D - g$. The staircase divisor $(-1,0,1,\dots,n-2)$ of degree $g-1$ shows sharpness.
* **Counting identity.** $\sum_{j<m}\lceil (a-j)/n\rceil_+ = m\lfloor a/n\rfloor + \min(m, a\bmod n) \le a$, strictly if $a > m$ (for $m+2 \le n$).
* **Exact rank.** $r(m\cdot\mathbf{1}) = \frac{m(m+3)}{2}$ on $K_n$ for all $n \ge m+2$; independent of $n$, quadratic in $m$, and constructively certified in $O(nm)$ time.
* **One-shot insufficiency.** For $m \ge 3$ the exact rank strictly exceeds $2m + \lfloor m^2/4\rfloor$, the best bound obtainable from a single threshold set firing.
* **Theta characteristics.** On $K_{2m+3}$ the uniform divisor $m\cdot\mathbf{1}$ satisfies $2D = K$ exactly, has degree $g-1$, and has rank $\frac{m(m+3)}{2}$, beating the universal half-canonical guarantee $k-1$ quadratically and satisfying $4r > g$.

---

## References

1. M. Baker and S. Norine, *Riemann–Roch and Abel–Jacobi theory on a finite graph*, Advances in Mathematics **215** (2007), 766–788.
2. M. Baker, *Specialization of linear systems from curves to graphs*, Algebra & Number Theory **2** (2008), 613–653.
3. N. L. Biggs, *Chip-firing and the critical group of a graph*, Journal of Algebraic Combinatorics **9** (1999), 25–45.
4. D. Dhar, *Self-organized critical state of sandpile automaton models*, Physical Review Letters **64** (1990), 1613–1616.
5. R. Cori and Y. Le Borgne, *The sand-pile model and Tutte polynomials*, Advances in Applied Mathematics **30** (2003), 44–52.
6. V. Kiss and L. Tóthmérész, *Chip-firing games on Eulerian digraphs and NP-hardness of computing the rank of a divisor on a graph*, Discrete Applied Mathematics **193** (2015), 48–56.
7. F. Cools, J. Draisma, S. Payne and E. Robeva, *A tropical proof of the Brill–Noether theorem*, Advances in Mathematics **230** (2012), 759–776.
