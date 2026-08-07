# Spectral Bounds on Non-Homogeneous Quadratic Forms over Lattices

### Torsion gaps, characteristic vectors, and the covering weight enumerator

**Author:** Aristotle
**Date:** 2026-08-07

---

## Abstract

Let $Q(x) = x^{\mathsf T} B x$ be a positive definite quadratic form with rational coefficients on the lattice $L = \mathbb{Z}^n \subset \mathbb{Q}^n$, and let $F(x) = Q(x - t)$ be the associated non-homogeneous form attached to a rational shift $t$. The integral solutions of $F(x) = c$ are the lattice points lying on the $Q$-ellipsoid of squared radius $c$ centred at $t$. We study two invariants: the *minimal lattice energy* (homogeneous minimum) $\lambda_1 = \min_{0 \neq m \in L} Q(m)$, and the *spectral gap* (inhomogeneous minimum) $\mu(t) = \min_{m \in L} Q(t - m)$, which is the exact threshold below which $F(x) = c$ has no integral solution.

We prove four groups of results.

1. **Archimedean.** For every $r$-torsion shift $t$ — a rational point with $rt \in L$ and $t \notin L$ — one has $\mu(t) \geq \lambda_1/r^2$, with a rigidity converse: equality holds if and only if $t \equiv w/r \pmod L$ for some $w$ realising $\lambda_1$. Non-extremal torsion shifts satisfy a strictly better second bound $\lambda_2/r^2$, so the spectrum of spectral gaps at $r$-torsion shifts has a hole. The constant $1/r^2$ is optimal; in particular the naive inequality $\mu \geq \lambda_1$ is false, and $\mu \geq \lambda_1/4$ is its correct sharp form. All invariants are $\mathrm{GL}_n(\mathbb{Z})$-invariants of the pair (lattice, form).

2. **Diophantine.** Completing the square converts every gap theorem into an unsolvability criterion for $F(x) = Q(x) + \ell(x) + c = 0$: when the completing shift is $-v/r$ with $v$ realising $\lambda_1$, the equation is unsolvable as soon as $c > 0$, whereas the classical archimedean criterion only rules out $c > \lambda_1/r^2$. The improvement is exactly the gap.

3. **$2$-adic.** For a symmetric integral form, a vector $v$ is a *characteristic vector* — meaning $u \mapsto \mathrm{Bil}(v,u) + Q(u)$ is even — **if and only if** $Q(v + 2u) \equiv Q(v) \pmod 8$ for all $u \in L$. Consequently the value set of $Q(x - v/2)$ at a characteristic $v$ lies in $Q(v)/4 + 2\mathbb{Z}$, and distinct attained values differ by at least $2$. The classical fact that a sum of $n$ odd squares is $\equiv n \pmod 8$, and hence the deep-hole spectrum $\tfrac n4 + 2\mathbb{Z}_{\geq 0}$ of $\mathbb{Z}^n$, is the instance $v = (1,\dots,1)$.

4. **Combinatorial.** On $2$-torsion shifts of a positive diagonal form $Q(x) = \sum a_i x_i^2$, the spectral gap equals the *weighted Hamming weight* $\bigl(\sum_{i \in s} a_i\bigr)/4$ of the class in $\mathbb{F}_2^n$; the whole gap spectrum is $\{(\sum_{i\in s} a_i)/4 : s \neq \emptyset\}$ and runs from the packing invariant $\lambda_1/4$ to the covering invariant $(\sum_i a_i)/4$. For $\mathbb{Z}^n$ this is exactly $\{k/4 : 1 \le k \le n\}$. On multiplicities, every coefficient of the shifted theta series is even whenever $2t \in L$, $t \notin L$; the converse fails ($t = (\tfrac12,\tfrac13)$ in $\mathbb{Z}^2$) and is replaced by the exact coordinatewise criterion: for a positive diagonal form, all coefficients are even iff some single coordinate $t_i$ is half-integral.

---

## 1. Introduction

### 1.1 The problem

A *non-homogeneous quadratic Diophantine equation* has the shape
$$F(x) \;=\; Q(x) + \ell(x) + c \;=\; 0, \qquad x \in \mathbb{Z}^n,$$
where $Q(x) = x^{\mathsf T} B x$ is a quadratic form and $\ell$ is linear. The standard first move is to complete the square, which — when the linear part lies in the image of twice the bilinear form — rewrites $F$ as $Q(x - t) + \text{const}$ for a rational shift $t$. All the arithmetic of the original equation is therefore concentrated in the geometry of the *shifted lattice* $\mathbb{Z}^n - t$ with respect to $Q$.

The basic obstruction to solvability is metric: if $c$ is smaller than the $Q$-distance from $t$ to the nearest lattice point, then $F$ has no solution. But this metric obstruction is only one of at least three, and the other two — a $2$-adic congruence and a combinatorial weight function — are what this paper isolates.

### 1.2 The invariants

Throughout, $B \in M_n(\mathbb{Q})$ is symmetric and $Q(x) = x^{\mathsf T} B x$; $L = \mathbb{Z}^n$; $\mathrm{Bil}(x,y) = x^{\mathsf T} B y$ is the associated bilinear form, so $Q(x) = \mathrm{Bil}(x,x)$ and
$$Q(x + y) = Q(x) + 2\,\mathrm{Bil}(x,y) + Q(y). \tag{1.1}$$

**Definition 1.1 (Positive definiteness).** $Q$ is *positive definite over $\mathbb{Q}$* if $Q(x) > 0$ for all $x \in \mathbb{Q}^n \setminus \{0\}$.

**Definition 1.2 (Minimal lattice energy).** A rational number $\lambda_1$ is the *minimal lattice energy* of $Q$ if it is attained ($Q(v) = \lambda_1$ for some $v \in L \setminus \{0\}$) and is a lower bound ($\lambda_1 \le Q(m)$ for all $m \in L \setminus \{0\}$). This is the homogeneous minimum, the packing invariant of the lattice.

**Definition 1.3 (Spectral gap / inhomogeneous minimum).** For a rational shift $t$, a rational number $\mu$ is the *spectral gap of $Q$ at $t$* if it is attained ($Q(t - m) = \mu$ for some $m \in L$) and is a lower bound ($\mu \le Q(t-m)$ for all $m \in L$). We write $\mu(t)$.

Both definitions are stated as attainment-plus-bound rather than as an infimum, so that every theorem below is an identity rather than a one-sided estimate. Positive definiteness guarantees existence of both (the relevant sets are discrete and the sublevel sets are finite), but no theorem in this paper needs that guarantee: attainment is always a hypothesis or a conclusion, never an appeal to compactness.

**Definition 1.4 (Torsion shift).** For an integer $r \geq 2$, a rational point $t$ is an *$r$-torsion shift* if $r t \in L$ and $t \notin L$; equivalently, $t$ is a nonzero $r$-torsion element of $(L \otimes \mathbb{Q})/L$.

**Definition 1.5 (Half point, deep hole, step shift).** For $v \in L$ write $v/2$ for the rational point with coordinates $v_i/2$. The *deep hole* of $\mathbb{Z}^n$ is $(\tfrac12, \ldots, \tfrac12)$. For $s \subseteq \{1,\dots,n\}$, the *step shift* $\sigma_s$ is the rational point with $(\sigma_s)_i = \tfrac12$ for $i \in s$ and $0$ otherwise; every $2$-torsion class of $(\tfrac12\mathbb{Z}/\mathbb{Z})^n \cong \mathbb{F}_2^n$ has a unique step-shift representative.

**Definition 1.6 (Shifted theta coefficients).** For $c \in \mathbb{Q}$, let $r_t(c) = \#\{m \in L : Q(t - m) = c\}$. The formal series $\theta_t(q) = \sum_c r_t(c)\,q^{c}$ is the *shifted theta series*; its support is the *value spectrum* of the non-homogeneous form.

### 1.3 What the results say, informally

The spectral gap is bounded below by the packing invariant divided by the square of the torsion order, and the equality case is a rigidity statement that detects the shortest vectors. Above that, the *value spectrum* of the non-homogeneous form is not merely a discrete set of rationals: at half a characteristic vector it is contained in an arithmetic progression of step $2$, and being characteristic is *equivalent* to that. Finally, on $2$-torsion classes of a diagonal form the gap function is a weighted Hamming weight, giving a literal dictionary between lattice covering theory and binary coding theory.

---

## 2. The archimedean theory: torsion gaps

### 2.1 The scaling identity

The engine of the entire archimedean half is a triviality.

**Lemma 2.1 (Scaling).** For $c \in \mathbb{Q}$ and $x \in \mathbb{Q}^n$, $Q(cx) = c^2 Q(x)$.

*Proof.* Immediate from bilinearity of $\mathrm{Bil}$ in each argument. $\square$

**Lemma 2.2 (Halving identity).** For $v, m \in L$,
$$Q\!\left(\tfrac{v}{2} - m\right) \;=\; \tfrac14\,Q(v - 2m).$$
More generally, if $rt = v \in L$ then $Q(t - m) = \tfrac{1}{r^2} Q(v - rm)$.

*Proof.* $t - m = \tfrac1r(v - rm)$; apply Lemma 2.1 with $c = 1/r$. $\square$

The content is that the *rational* quantity on the left is a rescaled *integral* quantity on the right, and integral quantities are controlled by $\lambda_1$ as soon as they are nonzero. Non-vanishing is the only nontrivial point.

**Lemma 2.3 (Primitivity).** Let $t$ be an $r$-torsion shift with $rt = v \in L$. Then $v - rm \neq 0$ for every $m \in L$.

*Proof.* If $v = rm$ then $t = m \in L$, contradicting $t \notin L$. $\square$

Two remarks. First, no positivity and no minimality is used. Second, in the special case $t = v/2$ with $v$ a shortest vector one can argue differently and more informatively: were $v = 2m$ with $m \neq 0$, then $\lambda_1 = Q(v) = 4Q(m) \geq 4\lambda_1$, contradicting $\lambda_1 > 0$. In other words, *a shortest vector is primitive modulo $r$ for every $r \geq 2$* — the same single fact that drives both the gap theorem and the even-multiplicity theorem of §5.

### 2.2 The gap theorem and its rigidity

**Theorem 2.4 (Torsion gap).** Let $\lambda_1$ be the minimal lattice energy of $Q$ and let $t$ be an $r$-torsion shift, $r \geq 2$. Then
$$Q(t - m) \;\geq\; \frac{\lambda_1}{r^2} \qquad \text{for every } m \in L,$$
and consequently $\mu(t) \geq \lambda_1/r^2$ whenever the spectral gap exists.

*Proof.* Write $rt = v \in L$. By Lemma 2.2, $Q(t-m) = r^{-2}Q(v - rm)$; by Lemma 2.3 the integer vector $v - rm$ is nonzero; by minimality $Q(v - rm) \geq \lambda_1$. $\square$

**Theorem 2.5 (Attainment at half a shortest vector).** If $Q$ is positive definite, $\lambda_1$ is the minimal lattice energy and $Q(v) = \lambda_1$, then the spectral gap at $v/2$ exists and equals $\lambda_1/4$:
$$\mu\!\left(\tfrac v2\right) = \frac{\lambda_1}{4}.$$
More generally $\mu(v/r) = \lambda_1/r^2$ for every $r \geq 2$.

*Proof.* The lower bound is Theorem 2.4. Attainment is the choice $m = 0$, for which Lemma 2.2 gives $Q(v/r) = r^{-2}Q(v) = \lambda_1/r^2$. $\square$

Theorem 2.5 disposes of the naive guess. One might hope for $\mu \geq \lambda_1$; Theorem 2.5 exhibits, for *every* positive definite rational form in *every* dimension, a shift at which $\mu$ equals $\lambda_1/4$ exactly. The factor $1/4$ is therefore not an artefact of a lossy argument. Its origin is the index $[L : 2L] $ scaling: halving a vector divides its energy by four.

**Example 2.6 (Sharpness on $\mathbb{Z}^n$).** For $B = I$, $\lambda_1 = 1$, realised by any standard basis vector $e_1$. Theorem 2.5 gives $\mu(e_1/2) = 1/4$. No constant larger than $1/4$ can appear in Theorem 2.4 with $r = 2$.

The converse of Theorem 2.5 is the substance of the archimedean theory, and it requires one further tool.

**Lemma 2.7 (Translation invariance).** For any $k \in L$, $\mu(t) = \mu(t + k)$; more precisely $\mu$ is a well-defined function on $(L \otimes \mathbb{Q})/L$.

*Proof.* $m \mapsto m + k$ is a bijection of $L$ carrying $Q(t - m)$ to $Q((t+k) - (m+k))$; the two sets of attained values coincide. $\square$

**Theorem 2.8 (Rigidity).** Let $Q$ be positive definite with minimal lattice energy $\lambda_1$, and let $t$ be an $r$-torsion shift. Then
$$\mu(t) = \frac{\lambda_1}{r^2} \iff t \equiv \frac{w}{r} \pmod{L} \text{ for some } w \in L \text{ with } Q(w) = \lambda_1 .$$

*Proof.* ($\Leftarrow$) By Lemma 2.7 we may assume $t = w/r$; then apply Theorem 2.5.

($\Rightarrow$) The definition of the spectral gap includes attainment: there is $m \in L$ with $Q(t - m) = \lambda_1/r^2$. Put $w = r(t - m) = rt - rm$, which lies in $L$ because $rt \in L$. By Lemma 2.1, $Q(w) = r^2 Q(t-m) = \lambda_1$. And $t - m = w/r$, so $t \equiv w/r \pmod L$. $\square$

Theorem 2.8 says the metric invariant $\mu$, restricted to $r$-torsion classes, *detects the shortest vectors*: the extremal classes are exactly the classes of $w/r$ for $w$ realising $\lambda_1$. This is a genuine "if and only if", and the reverse direction is essentially free once translation invariance is in place. It is worth noting that the earlier hypothesis "$v$ is shortest" in the special-shape versions was doing no work in the *inequality*: the hypothesis that actually matters in Theorem 2.4 is only $t \notin L$.

**Theorem 2.9 (Second gap).** Let $\lambda_2$ be a lower bound for the values of $Q$ on $L \setminus \{0\}$ strictly above $\lambda_1$; that is, $Q(m) \geq \lambda_2$ for every $m \in L\setminus\{0\}$ with $Q(m) \neq \lambda_1$. If $t$ is an $r$-torsion shift which is *not* of the form $w/r \bmod L$ with $Q(w) = \lambda_1$, then
$$\mu(t) \;\geq\; \frac{\lambda_2}{r^2}.$$
Hence the set of spectral gaps at $r$-torsion shifts contains no value strictly between $\lambda_1/r^2$ and $\lambda_2/r^2$.

*Proof.* Fix $m$ and set $w = rt - rm \in L\setminus\{0\}$. If $Q(w) = \lambda_1$ then $t \equiv w/r$, excluded by hypothesis. So $Q(w) \geq \lambda_2$ and $Q(t-m) = r^{-2}Q(w) \geq \lambda_2/r^2$. $\square$

### 2.3 Basis independence

The definitions above are phrased in coordinates: a Gram matrix $B$ together with the standard lattice $\mathbb{Z}^n$. Lattice reduction replaces a basis by a better one, i.e. replaces $B$ by a congruent matrix. Nothing changes.

**Lemma 2.10 (Congruence).** For any $U \in M_n(\mathbb{Q})$ and $x \in \mathbb{Q}^n$, $Q_{U^{\mathsf T} B U}(x) = Q_B(Ux)$.

*Proof.* A four-fold interchange of summation: $\sum_{k,l}(U^{\mathsf T}BU)_{kl}x_kx_l = \sum_{i,j}B_{ij}\bigl(\sum_k U_{ik}x_k\bigr)\bigl(\sum_l U_{jl}x_l\bigr)$. $\square$

**Theorem 2.11 (Invariance).** Let $U, V \in M_n(\mathbb{Z})$ with $UV = VU = I$ (i.e. $U$ unimodular). Then $\lambda_1$ is the minimal lattice energy of $B$ if and only if it is the minimal lattice energy of $U^{\mathsf T}BU$; and $\mu_B(t) = \mu_{U^{\mathsf T}BU}(U^{-1}t)$, equivalently $\mu_{U^{\mathsf T}BU}(t) = \mu_B(Ut)$.

*Proof.* By Lemma 2.10 the value sets coincide after the bijection $m \mapsto Um$ of $L$, whose inverse is $m \mapsto Vm$. Both attainment and lower-bound clauses transfer. $\square$

Every quantity in this paper is therefore a $\mathrm{GL}_n(\mathbb{Z})$-invariant of the pair (lattice, quadratic form), not of a chosen basis. Half-lattice points are carried to half-lattice points, so §3–§5 are basis-independent as well. This is precisely what legitimises the use of lattice reduction algorithms to *compute* $\lambda_1$ and $\mu$.

### 2.4 Packing and covering

**Theorem 2.12 (Packing–covering inequality).** Suppose $\mu$ is a *covering bound*: for every $t \in \mathbb{Q}^n$ there is $m \in L$ with $Q(t - m) \leq \mu$. Then $\mu \geq \lambda_1/4$.

*Proof.* Take $v$ realising $\lambda_1$ and apply the covering bound to $t = v/2$; combine with Theorem 2.4 for $r = 2$. $\square$

The squared covering radius of a lattice is thus at least a quarter of its minimal energy. The inequality is very far from tight in high dimension.

**Theorem 2.13 (Covering radius of $\mathbb{Z}^n$).** For $B = I$ the squared covering radius is exactly $n/4$, attained at the deep hole: $\mu\bigl((\tfrac12,\dots,\tfrac12)\bigr) = n/4$, and $\mu(t) \leq n/4$ for every $t$.

*Proof.* Upper bound: round each coordinate, so that $|t_i - m_i| \le \tfrac12$ and $\sum_i (t_i - m_i)^2 \le n/4$. Lower bound at the deep hole: each coordinate contributes $(\tfrac12 - m_i)^2 \geq \tfrac14$ since $m_i \in \mathbb{Z}$, with equality at $m_i \in \{0,1\}$. $\square$

**Corollary 2.14.** For $\mathbb{Z}^n$ the covering/packing ratio is $n$, unbounded. More generally, for the diagonal form $Q(x) = \sum a_i x_i^2$ with $a_i > 0$ one has $\lambda_1 = \min_i a_i$ and squared covering radius $(\sum_i a_i)/4$, so the ratio $(\sum_i a_i)/(\min_i a_i)$ is unbounded even at fixed $n$.

Thus the half of a shortest vector is a hole in the lattice, but for $n \geq 2$ it is emphatically not the deepest one; Theorem 2.4 is a bound of a different nature from the covering radius, and both are needed.

---

## 3. From gaps to Diophantine unsolvability

### 3.1 Completing the square

**Definition 3.1.** A linear form is $\ell(x) = \sum_i b_i x_i$; the general non-homogeneous quadratic form is $F(x) = Q(x) + \ell(x) + c$.

**Theorem 3.2 (Completing the square).** Suppose $B$ is symmetric and $s \in \mathbb{Q}^n$ satisfies $2\,\mathrm{Bil}(s, x) = \ell(x)$ for all $x$. Then
$$F(x) \;=\; Q(x + s) + \bigl(c - Q(s)\bigr) \qquad \text{for all } x .$$

*Proof.* By (1.1), $Q(x+s) = Q(x) + 2\,\mathrm{Bil}(s,x) + Q(s) = Q(x) + \ell(x) + Q(s)$. Rearrange. $\square$

The hypothesis "$\ell$ is in the image of $2\,\mathrm{Bil}$" is exactly the condition that a rational completing shift exists; we take it as a hypothesis rather than inverting $B$, which keeps the statement valid for singular $B$ too. It is non-vacuous: for the standard form and $\ell(x) = -\sum_i x_i$ one takes $s = -\tfrac12(1,\dots,1)$.

**Corollary 3.3 (Archimedean criterion).** If $Q$ is positive semidefinite then $F(x) \geq c - Q(s)$ for all real $x$, so $F = 0$ has no solution when $c > Q(s)$.

This is the classical criterion, and it is lossy: it ignores that $x$ is an integer.

**Theorem 3.4 (Lattice-refined criterion).** In the situation of Theorem 3.2, suppose additionally that $-s = v/r$ where $v \in L$ realises the minimal lattice energy $\lambda_1$ and $r \geq 2$. Then for every $x \in L$,
$$F(x) \;\geq\; \frac{\lambda_1}{r^2} + c - Q(s) \;=\; c,$$
since $Q(s) = Q(v/r) = \lambda_1/r^2$. Consequently $F(x) = 0$ has **no integral solution** whenever $c > 0$.

*Proof.* $Q(x + s) = Q(x - v/r)$, and $v/r$ is an $r$-torsion shift (Lemma 2.3 applies since $v \notin rL$ by primitivity of a shortest vector), so Theorem 2.4 gives $Q(x+s) \geq \lambda_1/r^2$. Now use Theorem 3.2 and $Q(s) = \lambda_1/r^2$. $\square$

Comparing Corollary 3.3 with Theorem 3.4: the classical test rejects $c > \lambda_1/r^2$, the lattice test rejects $c > 0$. **The improvement is exactly $\lambda_1/r^2$, the whole of the spectral gap.**

The same comparison holds for an arbitrary completing shift, and it is worth recording in that generality.

**Theorem 3.4$'$ (General refined criterion).** In the situation of Theorem 3.2, for every $x \in L$,
$$F(x) \;\geq\; \mu(-s) + c - Q(s),$$
so $F(x) = 0$ has no integral solution once $c > Q(s) - \mu(-s)$. The improvement over Corollary 3.3 is exactly $\mu(-s)$, the spectral gap at the completing shift.

*Proof.* $Q(x + s) = Q((-s) - (-x)) \geq \mu(-s)$ because $-x \in L$; combine with Theorem 3.2. $\square$

Theorem 3.4 is the case where $-s = v/r$ with $Q(v) = \lambda_1$, so that $\mu(-s) = \lambda_1/r^2 = Q(s)$ and the threshold becomes $c > 0$. Another instance is $B = I$ with $-s$ the deep hole of $\mathbb{Z}^n$, where $Q(s) = \mu(-s) = n/4$ and the threshold is again $c > 0$; this is the case worked out below.

**Corollary 3.5 (Unsolvability below the gap).** For any $r$-torsion shift $t$ and any $c < \lambda_1/r^2$, the equation $Q(x - t) = c$ has no integral solution. Purely integrally: if $Q(v) = \lambda_1$ then $Q(w) \geq \lambda_1$ for every $w$ in the coset $v + 2L$, so $Q(w) = N$ has no solution with $w \equiv v \pmod{2L}$ when $N < \lambda_1$.

### 3.2 The concrete standard case

Take $B = I$ and $\ell(x) = -\sum_i x_i$, so $s = -\tfrac12(1,\dots,1)$, $Q(s) = n/4$, and $F(x) = \sum_i (x_i^2 - x_i) + c$. Here $-s$ is the deep hole, $\mu(-s) = n/4$ (Theorem 2.13), and Theorem 3.4$'$ rejects every $c > 0$ where the archimedean criterion rejects only $c > n/4$.

**Proposition 3.6.** For every $x \in \mathbb{Z}^n$, the integer $\sum_i (x_i^2 - x_i)$ is even and non-negative. Hence $\sum_i(x_i^2 - x_i) + c = 0$ forces $c$ to be a non-positive even integer, and $c = 0$ forces $x_i \in \{0,1\}$ for all $i$.

*Proof.* $x_i^2 - x_i = x_i(x_i - 1)$ is a product of consecutive integers, hence even and $\geq 0$. $\square$

The archimedean bound alone would only give $\sum_i(x_i^2-x_i) \geq -n/4$ — off by the whole gap *and* blind to the evenness. Proposition 3.6 is the first appearance of the $2$-adic phenomenon, which §4 explains structurally.

---

## 4. The $2$-adic theory: characteristic vectors and the law modulo $8$

### 4.1 The deep-hole spectrum of $\mathbb{Z}^n$

**Theorem 4.1 (Deep-hole spectrum).** For $B = I$ and $t = (\tfrac12,\dots,\tfrac12)$, every attained value of $Q(t - m)$, $m \in \mathbb{Z}^n$, lies in $\tfrac n4 + 2\mathbb{Z}_{\geq 0}$. Consequently distinct attained values differ by at least $2$, and $n/4$ and $n/4 + 2$ are both attained (for $n \geq 1$).

*Proof.* $4\,Q(t-m) = \sum_i (1 - 2m_i)^2$ is a sum of $n$ odd squares. Each odd square satisfies $(2k-1)^2 = 8\binom{k}{2} + 1 \equiv 1 \pmod 8$ with $\binom k2 \geq 0$. Summing, $4Q(t-m) = n + 8 N$ with $N \geq 0$ an integer, i.e. $Q(t-m) = \tfrac n4 + 2N$. Attainment of $n/4$ is $m = 0$; of $n/4 + 2$, take $m$ with a single coordinate equal to $-1$ (so that $(1+2)^2 = 9 = 1 + 8$). $\square$

**Corollary 4.2.** The equation $\sum_{i=1}^n (2x_i - 1)^2 = N$ is unsolvable in integers unless $N \equiv n \pmod 8$ and $N \geq n$.

Note the strength of the conclusion: integrality of $4Q$ would only give a gap of $1/4$ in the value spectrum; Theorem 4.1 gives $2$, a factor of eight better.

### 4.2 Characteristic vectors

Theorem 4.1 looks like a fact about $\mathbb{Z}^n$. It is not; it is the instance of a general principle at one specific vector. Assume now that $B \in M_n(\mathbb{Z})$ is symmetric, so $Q$ and $\mathrm{Bil}$ take integer values on $L$.

**Definition 4.3 (Characteristic vector).** A vector $v \in L$ is *characteristic* for $Q$ if
$$\mathrm{Bil}(v, u) + Q(u) \;\equiv\; 0 \pmod 2 \qquad \text{for every } u \in L,$$
i.e. the functional $u \mapsto \mathrm{Bil}(v,u) + Q(u)$ is everywhere even.

(Over $\mathbb{Z}^n$ with the dot product this is the familiar condition $v \cdot u \equiv u \cdot u \pmod 2$ for all $u$.)

**Lemma 4.4 (Fundamental expansion).** For symmetric integral $B$ and $v, u \in L$,
$$Q(v + 2u) \;=\; Q(v) + 4\bigl(\mathrm{Bil}(v,u) + Q(u)\bigr).$$

*Proof.* By (1.1) with $y = 2u$: $Q(v + 2u) = Q(v) + 2\,\mathrm{Bil}(v, 2u) + Q(2u) = Q(v) + 4\,\mathrm{Bil}(v,u) + 4Q(u)$. $\square$

**Theorem 4.5 (Characteristic Vector Criterion).** Let $B$ be symmetric integral and $v \in L$. Then
$$v \text{ is characteristic} \iff 8 \mid Q(v + 2u) - Q(v) \text{ for every } u \in L .$$

*Proof.* By Lemma 4.4, $Q(v + 2u) - Q(v) = 4T_u$ where $T_u = \mathrm{Bil}(v,u) + Q(u)$. Now $8 \mid 4T_u \iff 2 \mid T_u$, and both directions follow at once, uniformly in $u$. $\square$

Two comments on the shape of Theorem 4.5. First, it is an equivalence, so it cannot be vacuous or one-sided; the mod-$8$ congruence is not a coincidence in $\mathbb{Z}^n$ but an exact characterisation of characteristic vectors in every integral lattice. Second, it is *sharp in the failure direction*: if $v$ is not characteristic, some $u$ has $T_u$ odd, whence $Q(v+2u) \equiv Q(v) + 4 \pmod 8$ — the value spectrum then contains a point at distance $1$ (not $2$) in the rescaled scale, breaking the gap exactly in half. Positive definiteness is used nowhere in this subsection.

**Proposition 4.6 (The all-ones vector).** For $B = I$ the vector $w = (1,\dots,1)$ is characteristic, since $\mathrm{Bil}(w,u) + Q(u) = \sum_i u_i + \sum_i u_i^2 = \sum_i u_i(1 + u_i)$, a sum of products of consecutive integers.

Applying Theorem 4.5 to Proposition 4.6 recovers the arithmetic of Theorem 4.1, and Proposition 3.6 becomes the statement that $0$ is characteristic-shifted by $w$: $\sum_i(u_i^2 + u_i)$ is even.

### 4.3 The spectral consequence

Transfer the integral statement to the rational form by viewing $B \in M_n(\mathbb{Z})$ inside $M_n(\mathbb{Q})$; then $Q(x)$ for integral $x$ is the image of the integral value.

**Theorem 4.7 (Characteristic shifted spectrum).** Let $B$ be symmetric integral and $v \in L$ characteristic. Then for every $m \in L$ there exists $k \in \mathbb{Z}$ with
$$Q\!\left(\tfrac v2 - m\right) \;=\; \frac{Q(v)}{4} + 2k .$$
That is, the value spectrum of the non-homogeneous form at the half of a characteristic vector is contained in $\tfrac{Q(v)}{4} + 2\mathbb{Z}$.

*Proof.* By the halving identity (Lemma 2.2), $Q(v/2 - m) = \tfrac14 Q(v - 2m) = \tfrac14 Q(v + 2(-m))$. By Theorem 4.5 applied with $u = -m$, $Q(v + 2(-m)) = Q(v) + 8k$ for some integer $k$. Divide by $4$. $\square$

**Theorem 4.8 (Gap two).** In the situation of Theorem 4.7, if $m, m' \in L$ give *distinct* values then
$$\left| Q\!\left(\tfrac v2 - m\right) - Q\!\left(\tfrac v2 - m'\right) \right| \;\geq\; 2 .$$

*Proof.* Write the two values as $\tfrac{Q(v)}4 + 2k$ and $\tfrac{Q(v)}4 + 2k'$ with $k, k' \in \mathbb{Z}$. Distinctness forces $k \neq k'$, hence $|k - k'| \geq 1$, hence the difference is $|2(k-k')| \geq 2$. $\square$

Together, Theorems 4.5, 4.7 and 4.8 give the structural slogan:

> **Gap $2$ in the shifted value spectrum $\iff$ the shift is half a characteristic vector.**

The deep-hole theorem for $\mathbb{Z}^n$ is the case $v = (1,\dots,1)$.

### 4.4 Two independent fours

The number $4$ appears twice in this paper: as the denominator in the spectral gap $\lambda_1/4$ and as the multiplier in the expansion $Q(v+2u) = Q(v) + 4(\cdots)$. Both come from the same source, the index scaling of $2L$ inside $L$: halving squares the scaling factor. But the two theorems are logically independent. Theorem 2.5 is archimedean — a statement about the real ellipsoid metric, insensitive to congruences. Theorem 4.5 is $2$-adic — a statement about congruences, insensitive to the metric and valid without positive definiteness. Combining them yields the complete local picture at a half characteristic vector realising $\lambda_1$: the smallest attained value is $\lambda_1/4$, and the next possible one is $\lambda_1/4 + 2$.

---

## 5. Multiplicities: parity of shifted theta coefficients

### 5.1 Evenness from an antipodal involution

**Theorem 5.1 (Even multiplicity).** Let $B$ be an arbitrary rational matrix and $t$ a rational shift with $2t = v \in L$ and $t \notin L$. Then for every $c$, the coefficient $r_t(c) = \#\{m \in L : Q(t-m) = c\}$ is even.

*Proof.* Define $\iota(m) = v - m$. Since $t = v/2$, we have $t - \iota(m) = v/2 - v + m = -(t - m)$, and $Q$ is even, so $Q(t - \iota(m)) = Q(t-m)$: the map $\iota$ preserves each fibre. It is an involution. It has no fixed point: $\iota(m) = m$ means $v = 2m$, i.e. $t = m \in L$, excluded. A fixed-point-free involution of a finite set partitions it into pairs, so each fibre has even cardinality. $\square$

Note that no minimality, positivity or symmetry hypothesis is needed: the involution only requires $v \notin 2L$. This strictly generalises the version where $v$ is assumed shortest, and it closes one direction of the natural characterisation.

**Proposition 5.2.** If all coefficients $r_t(c)$ are even, then $t \notin L$.

*Proof.* If $t = k \in L$ then $r_t(0) = \#\{m : Q(k - m) = 0\} = 1$ for positive definite $Q$, since $Q(k-m) = 0$ forces $m = k$. $\square$

### 5.2 The converse in rank one — and its failure in rank two

**Theorem 5.3 (Rank one).** For $n = 1$ with $Q(x) = x^2$ and $t \in \mathbb{Q}$: all coefficients $r_t(c)$ are even $\iff$ $2t \in \mathbb{Z}$ and $t \notin \mathbb{Z}$.

*Proof.* ($\Leftarrow$) Theorem 5.1. ($\Rightarrow$) Suppose $2t \notin \mathbb{Z}$. If $(t-m)^2 = (t-m')^2$ with $m \neq m'$, then $t - m = -(t-m')$, i.e. $m + m' = 2t \in \mathbb{Z}$, a contradiction. So every fibre has at most one element; the fibre over $c = t^2$ contains $m = 0$, hence $r_t(t^2) = 1$, odd. $\square$

It is natural to conjecture that Theorem 5.3 holds in all ranks: all coefficients even should force $2t \in L$. **This is false already for $n = 2$.**

**Theorem 5.4 (Counterexample).** Let $n = 2$, $B = I$, and $t = (\tfrac12, \tfrac13)$. Then every coefficient $r_t(c)$ is even, but $2t = (1, \tfrac23) \notin \mathbb{Z}^2$.

*Proof.* Consider the *partial* reflection $\rho(m_1, m_2) = (1 - m_1,\, m_2)$. It is an involution of $\mathbb{Z}^2$; it preserves $(m_1 - \tfrac12)^2 + (m_2 - \tfrac13)^2$ because $(1 - m_1) - \tfrac12 = -(m_1 - \tfrac12)$; and it has no fixed point because $m_1 = 1 - m_1$ has no integer solution. Pairing as in Theorem 5.1 gives evenness of every fibre. $\square$

Structurally: the standard theta series factors over coordinates, $\theta_t = \prod_i \theta_{t_i}$, and a *single* even factor annihilates the whole product modulo $2$. Evenness is therefore a coordinatewise, not a global, phenomenon — for forms that split.

### 5.3 The exact criterion for diagonal forms

**Definition 5.5.** A rational number $x$ is *half-integral* if $x \in \mathbb{Z} + \tfrac12$, i.e. $x = k + \tfrac12$ for some $k \in \mathbb{Z}$.

**Theorem 5.6 (Parity criterion, diagonal case).** Let $Q(x) = \sum_{i} a_i x_i^2$ with all $a_i > 0$, and let $t \in \mathbb{Q}^n$. Then
$$\bigl(\forall c,\; r_t(c) \text{ is even}\bigr) \iff \bigl(\exists i,\; t_i \text{ is half-integral}\bigr).$$

*Proof.* ($\Leftarrow$) Suppose $t_{i_0} = k + \tfrac12$. The partial flip
$$\rho(m)_i = \begin{cases} 2k + 1 - m_{i_0}, & i = i_0,\\ m_i, & i \neq i_0,\end{cases}$$
satisfies $t_{i_0} - \rho(m)_{i_0} = -(t_{i_0} - m_{i_0})$ and leaves all other coordinates alone, so it preserves $Q(t - \cdot)$ because the diagonal form has no coupling between coordinates. It is an involution, and it is fixed-point free since $m_{i_0} = 2k+1-m_{i_0}$ would force $2m_{i_0} = 2k+1$, impossible. Pair off.

($\Rightarrow$) Suppose no coordinate of $t$ is half-integral. We claim the rounding point $m^\ast = (\mathrm{round}(t_1),\dots,\mathrm{round}(t_n))$ is the *unique* minimiser of $Q(t - \cdot)$. Indeed, for each coordinate, $|t_i - \mathrm{round}(t_i)| < \tfrac12$ strictly (this is exactly where non-half-integrality is used), while $|t_i - k| \geq \tfrac12$ for every integer $k \neq \mathrm{round}(t_i)$; multiplying by $a_i > 0$ and summing, any $m \neq m^\ast$ has $Q(t-m) > Q(t - m^\ast)$. Hence the bottom coefficient $r_t\bigl(Q(t - m^\ast)\bigr)$ equals $1$, which is odd. $\square$

**Corollary 5.7 (Standard form).** For $B = I$: all shifted theta coefficients at $t$ are even $\iff$ some coordinate $t_i$ is half-integral. Theorem 5.3 is the case $n = 1$; Theorem 5.4 is the shift $t=(\tfrac12,\tfrac13)$, whose first coordinate is half-integral.

**Theorem 5.8 (General-rank obstruction).** For an arbitrary positive definite $Q$ and shift $t$: if the *bottom* coefficient of the shifted theta series is even, then the nearest lattice point to $t$ is not unique.

*Proof.* The bottom coefficient counts the minimisers of $Q(t-\cdot)$. If it were unique the count would be $1$, odd. $\square$

Theorem 5.8 is the correct general shadow of the criterion: evenness always forces geometric degeneracy of the nearest-point problem, even when there is no splitting to exploit. What obstructs a rank-$n$ proof of the naive converse is that a coefficient can be even "by accident", two unrelated pairs of lattice points landing at the same distance; the rank-one argument works only because the fibre of $x \mapsto x^2$ over $c$ has at most two points.

---

## 6. The combinatorial theory: the covering weight enumerator

We now compute $\mu$ on *all* $2$-torsion classes, first for $\mathbb{Z}^n$, then for arbitrary positive diagonal forms.

Recall the step shift $\sigma_s$ from Definition 1.5. Every $2$-torsion class of $(\tfrac12\mathbb{Z}/\mathbb{Z})^n$ has a unique step-shift representative, and $|s|$ is the Hamming weight of the class in $\mathbb{F}_2^n$.

**Theorem 6.1 (Gap at a step shift, standard form).** For $B = I$ and any $s \subseteq \{1,\dots,n\}$,
$$\mu(\sigma_s) = \frac{|s|}{4}.$$

*Proof.* $Q(\sigma_s - m) = \sum_{i \in s}(\tfrac12 - m_i)^2 + \sum_{i \notin s} m_i^2$. Each term of the first sum is $\geq \tfrac14$ (a half-integer squared), each of the second is $\geq 0$; so the total is $\geq |s|/4$. Both bounds are simultaneously attained at $m = 0$. $\square$

The key structural point is *additivity*: the standard form splits over coordinates and the coordinatewise minima are achieved at the same lattice point, so there is no interaction. This is exactly what fails for a general form, where off-diagonal entries couple the coordinates.

**Theorem 6.2 (Gap of a $2$-torsion class = Hamming weight / 4).** For $B = I$ and $t$ with $2t = v \in \mathbb{Z}^n$, the spectral gap is
$$\mu(t) = \frac{k}{4}, \qquad k = \#\{i : v_i \text{ is odd}\},$$
i.e. a quarter of the Hamming weight of the class of $t$ in $\mathbb{F}_2^n$.

*Proof.* Write $t = \sigma_s + \kappa$ with $s = \{i : v_i \text{ odd}\}$ and $\kappa \in \mathbb{Z}^n$ (coordinatewise: $v_i/2$ is either an integer or an integer plus $\tfrac12$). Apply translation invariance (Lemma 2.7) and Theorem 6.1. $\square$

**Theorem 6.3 (Gap spectrum of $\mathbb{Z}^n$).** The set of spectral gaps of $\mathbb{Z}^n$ at $2$-torsion shifts is exactly
$$\Bigl\{\tfrac k4 : 1 \leq k \leq n\Bigr\}.$$

*Proof.* ($\subseteq$) Theorem 6.2, with $k \geq 1$ because $t \notin \mathbb{Z}^n$. ($\supseteq$) For each $k$ take $s$ any $k$-element subset and use Theorem 6.1; $\sigma_s$ is a genuine $2$-torsion shift for $s \neq \emptyset$. $\square$

Both endpoints are familiar: $k = 1$ is the extremal class of the rigidity theorem (gap $\lambda_1/4 = 1/4$), and $k = n$ is the deep hole (gap $n/4$, Theorem 2.13). The metric invariant $\mu$ on $2$-torsion classes *is* the Hamming weight function of $\mathbb{F}_2^n$, divided by four.

**Theorem 6.4 (Weighted weight enumerator, diagonal case).** Let $Q(x) = \sum_i a_i x_i^2$ with $a_i > 0$. Then:

1. $\mu(\sigma_s) = \dfrac{1}{4}\sum_{i \in s} a_i$ for every $s \subseteq \{1,\dots,n\}$;
2. for $t$ with $2t = v \in \mathbb{Z}^n$, $\mu(t) = \dfrac14\sum_{i : v_i \text{ odd}} a_i$;
3. the $2$-torsion gap spectrum is exactly $\Bigl\{\tfrac14\sum_{i \in s} a_i : \emptyset \neq s \subseteq \{1,\dots,n\}\Bigr\}$;
4. the minimum of that spectrum is $\tfrac14 \min_i a_i = \lambda_1/4$, the packing invariant, and its maximum is $\tfrac14\sum_i a_i$, the covering invariant (squared covering radius).

*Proof.* (1) $Q(\sigma_s - m) = \sum_{i\in s} a_i(\tfrac12 - m_i)^2 + \sum_{i \notin s} a_i m_i^2 \geq \tfrac14\sum_{i \in s}a_i$, attained at $m = 0$, as in Theorem 6.1 with the weights carried along (here $a_i > 0$ is used to keep the inequalities in the right direction). (2) As in Theorem 6.2 via translation invariance. (3) Both inclusions as in Theorem 6.3. (4) The sum over $s$ is minimised at singletons and maximised at $s = \{1,\dots,n\}$ since all $a_i > 0$; $\lambda_1 = \min_i a_i$ because a nonzero integer vector has $\sum a_i m_i^2 \geq \min_i a_i$, attained at a standard basis vector; the deep hole $\sigma_{\{1,\dots,n\}}$ realises the covering radius by the rounding argument of Theorem 2.13. $\square$

Part (4) is the striking one: a *single* formula, the weighted Hamming weight, interpolates between the two classical extremal constants of the geometry of numbers — packing at weight one, covering at full weight — and takes every intermediate value indexed by a subset. Theorem 6.1 is the case $a_i \equiv 1$ of Theorem 6.4.

---

## 7. Algorithms

The results above are effective, and the following procedures compute all quantities discussed. Throughout, arithmetic is exact (rational), and the ambient dimension $n$ and a search radius $R$ are inputs.

### 7.1 Minimal lattice energy by bounded enumeration

To compute $\lambda_1 = \min_{0 \neq m} Q(m)$ for positive definite $Q$, enumerate $m \in \{-R,\dots,R\}^n \setminus \{0\}$ and take the minimum. Correctness for a given $R$ follows once $R$ exceeds the *Cholesky radius*: if $Q \succeq \delta \|\cdot\|^2$ then any $m$ with $\|m\|_\infty > \sqrt{Q(e_1)/\delta}$ has $Q(m) > Q(e_1)$ and can be skipped. Cost: $O((2R+1)^n \cdot n^2)$ exact rational operations. In practice one first reduces the basis (Theorem 2.11 guarantees the answer is unchanged), which shrinks the required $R$ dramatically.

### 7.2 Spectral gap by bounded enumeration over a coset

To compute $\mu(t)$, enumerate $m \in \{-R,\dots,R\}^n$ and minimise $Q(t-m)$. Two accelerations follow from the theory: by translation invariance (Lemma 2.7) one may first replace $t$ by its representative in $[0,1)^n$, which lets $R$ be small; and by Theorem 2.4 one may terminate as soon as the value $\lambda_1/r^2$ is met when $t$ is an $r$-torsion shift, since that value is then provably minimal.

### 7.3 Gap spectrum of a diagonal form

Theorem 6.4 turns an exponential search into a subset-sum: enumerate the $2^n - 1$ nonempty subsets $s$ and emit $\tfrac14\sum_{i \in s}a_i$. The result is the exact $2$-torsion gap spectrum without any lattice enumeration at all. For $a_i \equiv 1$ this collapses further to $\{k/4 : 1 \le k \le n\}$, computable in $O(n)$.

### 7.4 Testing whether a vector is characteristic

Naively, Definition 4.3 quantifies over all $u \in L$. But $u \mapsto \mathrm{Bil}(v,u) + Q(u) \bmod 2$ is determined by $u \bmod 2$, so it suffices to test the $2^n$ classes; better, $Q(u) = \sum_i B_{ii}u_i^2 + 2\sum_{i<j}B_{ij}u_iu_j \equiv \sum_i B_{ii}u_i \pmod 2$, so the functional is the $\mathbb{F}_2$-linear map $u \mapsto \sum_i (\mathrm{Bil}(v,\cdot)_i + B_{ii}) u_i$, and it suffices to test the $n$ standard basis vectors:
$$v \text{ characteristic} \iff (Bv)_i \equiv B_{ii} \pmod 2 \text{ for } i = 1,\dots,n.$$
Cost: $O(n^2)$. This is the practical form of Theorem 4.5 and shows that characteristic vectors form a coset of $2L^\ast \cap L$.

### 7.5 Shifted theta coefficients and parity certification

To tabulate $r_t(c)$, enumerate the shifted lattice within a radius and bucket the exact rational values. Theorem 5.1 and Theorem 5.6 provide *certificates*: instead of counting, exhibit the fixed-point-free involution (the full reflection $m \mapsto 2t - m$, or the partial flip in the half-integral coordinate) and verify in $O(n)$ that it preserves the form and has no fixed point. This turns an unbounded verification into a constant-size proof.

---

## 8. Applications

**Solvability testing for quadratic Diophantine equations.** Theorem 3.4 gives an immediately implementable test that strictly dominates the classical complete-the-square criterion whenever the completing shift is a torsion point of a shortest vector, improving the rejected range by exactly $\lambda_1/r^2$. Corollary 4.2 adds an orthogonal, purely congruential filter.

**Covering-radius estimation.** Theorem 2.12 gives a lower bound for the covering radius from a shortest-vector computation alone; Theorem 6.4(4) shows that for diagonal forms the bound and the truth differ by the ratio $(\sum a_i)/(\min a_i)$, quantifying exactly how lossy packing-based covering estimates are.

**Coding-theoretic dictionary.** Theorem 6.4 identifies the geometric function "distance from a $2$-torsion class to the lattice" with the weighted Hamming weight on $\mathbb{F}_2^n$. Since $\mathbb{Z}^n/2\mathbb{Z}^n \cong \mathbb{F}_2^n$ carries the standard weight structure, questions about the distribution of $\mu$ over $2$-torsion classes become questions about weight enumerators of binary codes, and conversely.

**Structure of value spectra.** Theorem 4.8 says that at the half of a characteristic vector, the sequence of representable values of the shifted form skips by at least $2$. For an unsolvability proof this is a factor-of-eight strengthening over integrality — and it is a *complete* criterion, so failure of the gap is itself informative: it certifies that the shift is not half a characteristic vector.

**Basis-independent invariants for reduction algorithms.** Theorem 2.11 licenses lattice reduction as a preprocessing step for every quantity in this paper, which is what makes the enumerations of §7 feasible beyond toy dimensions.

---

## 9. Discussion

Three separate mechanisms have been isolated behind the single question "when does $Q(x) = c$ have no integral solution near a given shift?".

The **archimedean mechanism** (§2) is a scaling argument: an $r$-torsion shift is $1/r$ of an integral vector, and $1/r$ of a nonzero integral vector has energy at least $\lambda_1/r^2$. Its content is not the inequality, which is three lines, but the rigidity: the equality case pins down the shortest vectors exactly, and there is even a gap above the extremal classes. Notably, the hypotheses shrink as the theory develops: the inequality needs only $t \notin L$, not any relation to shortest vectors, and the mission's original guess $\mu \geq \lambda_1$ is off by precisely the index-scaling factor $4$.

The **$2$-adic mechanism** (§4) is the expansion $Q(v + 2u) = Q(v) + 4(\mathrm{Bil}(v,u) + Q(u))$, together with the observation that $8 \mid 4T \iff 2 \mid T$. This turns a mod-$8$ statement into a mod-$2$ statement about a linear functional, and hence into the classical notion of a characteristic vector. The gain is conceptual: the mod-$8$ law of sums of odd squares stops being a curiosity of $\mathbb{Z}^n$ and becomes an exact characterisation valid in every integral lattice. Positive definiteness is not used at all here — an honest reduction of hypotheses relative to §2.

The **combinatorial mechanism** (§6) is additivity of a diagonal form over coordinates, with coordinatewise minima attained simultaneously. This is genuinely restrictive: for a general form the off-diagonal entries couple the coordinates and the minimum is not additive. The theorem is thus sharp in its hypothesis rather than in its proof, and the right general statement should be that $\mu$ on $L/2L$ is a "weight enumerator of the lattice" — a function on $\mathbb{F}_2^n$ that need not be a weighted Hamming weight.

The multiplicity theory of §5 offers a cautionary tale worth stating explicitly. The rank-one criterion (all shifted theta coefficients even $\iff$ $2t \in L$, $t\notin L$) is exact, and it is very tempting to promote it to all ranks. The promotion is false: $t = (\tfrac12,\tfrac13)$ in $\mathbb{Z}^2$ has all coefficients even because the *first coordinate alone* supplies a fixed-point-free involution. The failure is instructive rather than merely a nuisance: it shows that parity of the theta series is a coordinatewise, factorisation phenomenon, and it directs one to the correct statement (Theorem 5.6), which is stronger, cleaner, and covers the whole diagonal family.

Finally, the two occurrences of the constant $4$ deserve a last word. They share an origin — the index of $2L$ in $L$ — but the theorems they appear in are logically independent, one archimedean and one $2$-adic. Their combination is what gives the sharp local picture at a half characteristic vector realising the minimum: the value spectrum starts at $\lambda_1/4$ and its next possible member is $\lambda_1/4 + 2$.

---

## 10. Future directions

**A reflection criterion for parity in arbitrary rank.** Theorem 5.6 is proved for diagonal forms, where the reflection in a single coordinate is available. The right general statement should replace "some coordinate $t_i$ is half-integral" by "there is an isometry $\rho$ of $(L,Q)$ with $\rho^2 = \mathrm{id}$ and $\rho(t) \equiv t \pmod L$ acting freely on $L$". Theorem 5.8 is the first step: even parity forces a non-unique nearest lattice point, which is a necessary condition for such a $\rho$ to exist.

**The van der Blij invariant.** For an even unimodular lattice, $Q(v) \equiv \operatorname{sign}(Q) \pmod 8$ for every characteristic $v$. Theorem 4.5 gives the local version — that $Q(v) \bmod 8$ is constant on the coset $v + 2L$ — from which the global statement should be reachable by a genus argument. Making that reduction explicit for the forms of this paper is a concrete next target.

**Strictness of the packing–covering inequality.** Theorem 2.12 gives covering $\geq \lambda_1/4$ and Corollary 2.14 shows the ratio is unbounded for diagonal forms. Determining for which lattices equality holds — presumably only $n = 1$ up to scaling — remains open.

**The weight enumerator of a general lattice.** Define $W_L : L/2L \to \mathbb{Q}$ by $W_L(\bar t) = \mu(t/2)$. Theorem 6.4 computes $W_L$ for diagonal forms as a weighted Hamming weight. For a general form $W_L$ is a genuinely new invariant; its symmetry group, its extremal values, and whether it determines the lattice are all open.

**A Eureka threshold.** For which $N$ does the equation $\sum_i (2x_i - 1)^2 = N$ acquire many solutions, and how does the multiplicity grow? Theorem 4.1 fixes the support ($N \equiv n \bmod 8$, $N \geq n$); the density of solutions on that progression is not addressed here.

**Higher torsion spectra.** Theorem 6.3 computes the $2$-torsion gap spectrum of $\mathbb{Z}^n$ completely. The $r$-torsion spectrum for $r \geq 3$ is not a Hamming weight — the coordinatewise minimum of $\min_k (t_i - k)^2$ over $t_i \in \tfrac1r\mathbb{Z}$ takes $\lfloor r/2\rfloor + 1$ values — and its combinatorial description should be a weight enumerator over $\mathbb{Z}/r$ rather than $\mathbb{F}_2$.

---

## 11. Summary of results

| Result | Statement |
|---|---|
| Torsion gap | $t$ an $r$-torsion shift $\Rightarrow$ $Q(t-m) \ge \lambda_1/r^2$ for all $m \in L$ |
| Attainment | $Q(v) = \lambda_1 \Rightarrow \mu(v/r) = \lambda_1/r^2$; in particular $\mu(v/2) = \lambda_1/4$ |
| Rigidity | $\mu(t) = \lambda_1/r^2 \iff t \equiv w/r \pmod L$ with $Q(w) = \lambda_1$ |
| Second gap | non-extremal $r$-torsion shift $\Rightarrow$ $\mu(t) \ge \lambda_2/r^2$ |
| Invariance | $\lambda_1$ and $\mu$ are unchanged under $B \mapsto U^{\mathsf T}BU$, $U$ unimodular |
| Packing–covering | squared covering radius $\ge \lambda_1/4$; $= n/4$ for $\mathbb{Z}^n$, ratio unbounded |
| Sharpened unsolvability | $F = Q + \ell + c$ with completing shift $-v/r$: no integral zero once $c > 0$ |
| Characteristic criterion | $v$ characteristic $\iff$ $Q(v+2u) \equiv Q(v) \bmod 8$ for all $u \in L$ |
| Gap two | $v$ characteristic $\Rightarrow$ values of $Q(x - v/2)$ lie in $Q(v)/4 + 2\mathbb{Z}$ |
| Deep-hole spectrum | values of $\sum(x_i - \tfrac12)^2$ lie in $n/4 + 2\mathbb{Z}_{\ge 0}$; both ends attained |
| Even multiplicity | $2t \in L$, $t \notin L$ $\Rightarrow$ every $r_t(c)$ is even |
| Parity converse fails | $t = (\tfrac12,\tfrac13)$ in $\mathbb{Z}^2$: all $r_t(c)$ even, $2t \notin \mathbb{Z}^2$ |
| Parity criterion | diagonal $Q$: all $r_t(c)$ even $\iff$ some $t_i$ is half-integral |
| Gap spectrum | $\mathbb{Z}^n$: $2$-torsion gaps $=\{k/4 : 1 \le k \le n\}$, gap $=$ Hamming weight$/4$ |
| Weight enumerator | diagonal $Q$: gap at class $s$ is $\tfrac14\sum_{i\in s}a_i$, from $\lambda_1/4$ to $\tfrac14\sum_i a_i$ |
