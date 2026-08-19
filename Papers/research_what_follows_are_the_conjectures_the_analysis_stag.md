# Sidon Sets in Cyclic Groups: Rigidity of the Erdős–Turán Construction Modulo $2p^2$

**Author:** Aristotle
**Date:** 2026-08-19

---

## Abstract

A finite set $A$ in an additive cancellative commutative monoid is a *Sidon set* (a $B_2$-set) if the equation $a + b = c + d$ with $a,b,c,d \in A$ forces $\{a,b\} = \{c,d\}$ as unordered pairs. Equivalently, in a group, all differences of distinct elements are pairwise distinct.

We develop a complete quantitative theory of Sidon sets in two ambient settings — an initial segment $\{0,1,\dots,N-1\}$ of the natural numbers, and the cyclic group $\mathbb{Z}/N\mathbb{Z}$ — and we prove that the classical Erdős–Turán quadratic-residue construction survives the passage from the first to the second at the tightest possible modulus.

Our main results are as follows. (i) *Counting bounds:* a Sidon subset of $\{0,\dots,n-1\}$ satisfies $|A|(|A|-1) \le 2n-2$, and a Sidon subset of a finite abelian group $G$ satisfies $|A|(|A|-1) \le |G|-1$, hence $|A| \le \sqrt{|G|}+1$. (ii) *The interval sandwich:* writing $F(N)$ for the largest Sidon subset of $\{0,\dots,N-1\}$, we have $\sqrt{N/8} < F(N) \le \sqrt{2N}+1$ for all $N \ge 32$, so $F(N) = \Theta(\sqrt N)$. (iii) *The cyclic theorem:* for every odd prime $p$, the Erdős–Turán set $A_p = \{2pk + (k^2 \bmod p) : 0 \le k < p\}$ is Sidon **modulo $2p^2$**, not merely in $\mathbb{Z}$; consequently $\mathbb{Z}/2p^2\mathbb{Z}$ contains a Sidon set of size $p = \sqrt{N/2}$ where $N = 2p^2$, against the ceiling $\sqrt N + 1$ — a sandwich of ratio $\sqrt 2$. (iv) *Transfer and the general cyclic sandwich:* a Sidon subset of $\{0,\dots,n-1\}$ remains Sidon in $\mathbb{Z}/N\mathbb{Z}$ whenever $N \ge 2n$, and combining this with Bertrand's postulate, every $\mathbb{Z}/N\mathbb{Z}$ with $N \ge 64$ contains a Sidon set of size $> \sqrt{N/16}$, while none exceeds $\sqrt N + 1$. (v) *Structural results:* the counting characterisations $|A+A| = \binom{|A|+1}{2}$ and $|A-A| = |A|^2 - |A| + 1$; extremal rigidity, whereby a Sidon set is a perfect difference set iff $|A|^2 - |A| = |G| - 1$, forcing $|G| = k^2-k+1$; affine invariance of the Sidon property; the negative result that the reduced Erdős–Turán set is never a perfect difference set in $\mathbb{Z}/2p^2\mathbb{Z}$; and an exact dictionary identifying the Sidon property with $C_4$-freeness of an associated bipartite incidence graph, which yields an independent Reiman/Kővári–Sós–Turán proof of the upper bound.

The mechanism throughout is a single rigidity statement: over a field of characteristic $\ne 2$, two pairs with equal first and second power sums are equal as unordered pairs. The Erdős–Turán construction manufactures the second power-sum identity by storing $k^2 \bmod p$ in the low base-$2p$ digit while the first is stored in the high digit; the cyclic theorem follows because the modulus $2p^2 = (2p)\cdot p$ makes a full wrap-around a *clean digit shift*, which the same rigidity refutes. We record computational evidence that the modulus is sharp: $A_p$ fails to be Sidon modulo $2p^2+1$ for $p = 3,5,7,11,13$.

**Keywords:** Sidon set, $B_2$-set, Erdős–Turán construction, cyclic group, perfect difference set, quadratic residues, Bertrand's postulate, $C_4$-free graph, additive combinatorics.

---

## 1. Introduction

### 1.1 The problem

Let $M$ be an additive cancellative commutative monoid. A finite subset $A \subseteq M$ is a **Sidon set**, or a **$B_2$-set**, if for all $a,b,c,d \in A$,
$$a + b = c + d \;\Longrightarrow\; (a = c \wedge b = d) \;\vee\; (a = d \wedge b = c).$$
Informally: every element of the sumset $A+A$ has an essentially unique representation as an unordered sum of two elements of $A$.

In a group the condition takes an equivalent and often more convenient form. Since $a - b = c - d$ is the same as $a + d = c + b$, the Sidon condition says exactly that the $|A|(|A|-1)$ ordered differences $a - b$ with $a \ne b$ are **pairwise distinct**. This is the "perfect ruler" or "sparse ruler" picture: mark positions on a ruler so that no two pairs of marks are the same distance apart.

Sidon introduced these sets in the 1930s in the context of $L^p$ estimates for lacunary Fourier series and asked Erdős how large they could be. The resulting quantitative problem — determine
$$F(N) := \max\{|A| : A \subseteq \{0,1,\dots,N-1\},\ A \text{ Sidon}\}$$
— became one of Erdős's lifelong preoccupations and remains only partially resolved. The elementary theory, which is what we develop here in full, gives $F(N) = \Theta(\sqrt N)$ with explicit constants.

### 1.2 The question addressed here

All the classical constructions produce Sidon sets inside an *interval* of integers. The natural next question, and the one this paper answers, is whether the property survives **quotienting**: does a Sidon subset of $\{0,\dots,n-1\}$ remain Sidon after reduction modulo $N$, where sums wrap around?

There is a trivial safe regime. If $N \ge 2n$ then all pairwise sums of elements of $A \subseteq \{0,\dots,n-1\}$ are strictly below $N$, so reduction changes nothing and Sidon-ness transfers (Theorem 6.1). But this costs a factor of $2$ in the modulus, and for the Erdős–Turán set, which lives in $\{0,\dots,2p^2-1\}$, the safe modulus is $4p^2$ while the interesting one is $2p^2$ — the smallest modulus for which the set's elements remain distinct.

At modulus exactly $2p^2$ a wrap-around is a genuine possibility: two pairwise sums both lie in $[0,4p^2)$, so they can be congruent modulo $2p^2$ without being equal, differing by exactly one full period. We prove that this never actually happens (Theorem 5.2), and we show computationally that the phenomenon is sharp: at modulus $2p^2+1$ it fails.

### 1.3 Summary of results

* **§3** develops the counting bounds. The key observation, used four separate times in this paper, is that the Sidon condition *is* an injectivity statement, and injectivity plus a target-size count yields a bound.
* **§4** presents the Erdős–Turán construction and its proof via Newton–Vieta rigidity, and assembles the interval sandwich $\sqrt{N/8} < F(N) \le \sqrt{2N}+1$ for $N \ge 32$ using Bertrand's postulate.
* **§5** contains the main new theorem: the Erdős–Turán set is Sidon modulo $2p^2$, hence $\mathbb{Z}/2p^2\mathbb{Z}$ contains a Sidon set of size $p$, with a sandwich of ratio $\sqrt 2$.
* **§6** proves the transfer principle and the general cyclic sandwich for all $N \ge 64$.
* **§7** treats structural theory: the sumset and difference-set counting characterisations, extremal rigidity, the order constraint $|G| = k^2 - k + 1$ for perfect difference sets, the explicit example $\{0,1,3,9\} \subseteq \mathbb{Z}/13\mathbb{Z}$, affine invariance, and the negative result on the Erdős–Turán set.
* **§8** gives the bridge to extremal graph theory: the Sidon property is *equivalent* to $C_4$-freeness of an explicit bipartite incidence graph, and the Reiman double count reproves the upper bound.
* **§9–§11** discuss algorithms, applications, and open problems.

---

## 2. Notation and conventions

Throughout, $A$ denotes a finite set. For a finite abelian group $G$ we write $|G|$ for its order. We write $\lfloor \sqrt{\cdot}\rfloor$ implicitly: all square roots in inequalities of the form $k \le \sqrt N + 1$ are to be read as integer square roots, i.e. $k \le \lfloor\sqrt N\rfloor + 1$, and the stated inequalities hold in that (stronger) integer form.

For a finite set $A$ in an abelian group we write
$$A + A = \{a+b : a,b \in A\},\qquad A - A = \{a-b : a,b \in A\},$$
and
$$D(A) = \{a - b : a,b \in A,\ a \ne b\}$$
for the set of **nonzero differences** — nonzero because a Sidon-set difference $a-b$ with $a \ne b$ is never $0$; note $D(A)$ omits $0$ by construction but is defined for arbitrary $A$.

$\mathbb{Z}/N\mathbb{Z}$ denotes the cyclic group of order $N$. For a prime $p$ it is the field $\mathbb{F}_p$.

---

## 3. Counting bounds: the ceiling

The following three results are all instances of one principle.

### 3.1 Distinct differences

**Lemma 3.1 (Distinct differences).** *Let $G$ be an abelian group and $A \subseteq G$ a Sidon set. Then the map $(a,b) \mapsto a - b$ is injective on the off-diagonal $\{(a,b) \in A \times A : a \ne b\}$.*

*Proof.* Suppose $a - b = c - d$ with $a \ne b$, $c \ne d$, all in $A$. Rearranging, $a + d = c + b$. The Sidon condition applied to this equation gives either $(a = c \wedge d = b)$, which is the desired conclusion, or $(a = b \wedge d = c)$, which contradicts $a \ne b$. $\square$

### 3.2 The group bound

**Theorem 3.2 (Sidon bound in a finite abelian group).** *If $A$ is a Sidon subset of a finite abelian group $G$, then*
$$|A|\,(|A|-1) \;\le\; |G| - 1,$$
*and consequently $|A| \le \sqrt{|G|} + 1$.*

*Proof.* The off-diagonal of $A \times A$ has exactly $|A|(|A|-1)$ elements. By Lemma 3.1 the difference map is injective on it, and each image $a - b$ with $a \ne b$ is a nonzero element of $G$. Hence $|A|(|A|-1) \le |G| - 1$.

For the second statement, suppose $|A| \ge \lfloor\sqrt{|G|}\rfloor + 2$. Writing $s = \lfloor\sqrt{|G|}\rfloor$ we have $|A|(|A|-1) \ge (s+2)(s+1) \ge (s+1)^2 > |G| \ge |G| - 1$ (using $|G| < (s+1)^2$, the defining property of the integer square root), a contradiction. $\square$

### 3.3 The interval bound

**Theorem 3.3 (Erdős–Turán upper bound).** *If $A \subseteq \{0,1,\dots,n-1\}$ is Sidon, then*
$$|A|\,(|A|-1) \;\le\; 2n - 2,$$
*and consequently the maximum $F(n)$ satisfies $F(n) \le \sqrt{2n} + 1$.*

*Proof.* The same argument, with the target set changed. The $|A|(|A|-1)$ ordered differences $a-b$, $a \ne b$, are distinct nonzero integers lying strictly between $-n$ and $n$, and there are exactly $2n-2$ such integers. The consequence follows exactly as in Theorem 3.2, with $2n$ in place of $|G|$. $\square$

Note the factor-of-two loss relative to the group bound: an interval of length $n$ has $2n-2$ available differences, whereas a group of order $n$ has only $n-1$. This is the reason the cyclic problem is *a priori* harder, and it is the reason the cyclic sandwich of §5 (ratio $\sqrt 2$) is tighter than the interval sandwich of §4 (ratio $4$).

---

## 4. The Erdős–Turán construction and the interval sandwich

### 4.1 Newton–Vieta rigidity

The engine of the construction is the following statement, which is nothing but the fact that a monic quadratic is determined by, and determines, its root multiset.

**Lemma 4.1 (Power-sum rigidity).** *Let $K$ be a field with $2 \ne 0$, and let $x_1,x_2,x_3,x_4 \in K$ satisfy*
$$x_1 + x_2 = x_3 + x_4 \quad\text{and}\quad x_1^2 + x_2^2 = x_3^2 + x_4^2.$$
*Then $(x_1 = x_3 \wedge x_2 = x_4)$ or $(x_1 = x_4 \wedge x_2 = x_3)$.*

*Proof.* From the two hypotheses,
$$2x_1x_2 = (x_1+x_2)^2 - (x_1^2+x_2^2) = (x_3+x_4)^2 - (x_3^2+x_4^2) = 2x_3x_4,$$
and since $2$ is invertible, $x_1x_2 = x_3x_4$. Set $s = x_1+x_2 = x_3+x_4$ and $q = x_1x_2 = x_3x_4$. Then
$$(x_1 - x_3)(x_1 - x_4) = x_1^2 - s\,x_1 + q = x_1^2 - (x_1+x_2)x_1 + x_1x_2 = 0.$$
As $K$ is a field, one factor vanishes. If $x_1 = x_3$ then $x_2 = s - x_1 = s - x_3 = x_4$; if $x_1 = x_4$ then $x_2 = x_3$. $\square$

Both hypotheses on $K$ matter. Over a non-domain such as $\mathbb{Z}/9\mathbb{Z}$ the factorisation argument fails; in characteristic $2$, $x^2$ is additive and the second identity carries no information beyond the first.

### 4.2 Digit separation

**Lemma 4.2 (Uniqueness of the two lowest base-$m$ digits).** *If $m > 0$, $b < m$, $d < m$ and $ma + b = mc + d$, then $a = c$ and $b = d$.*

*Proof.* Divide by $m$: $\lfloor (ma+b)/m \rfloor = a$ since $b < m$, and likewise for the right side. Hence $a = c$, and then $b = d$ by cancellation. $\square$

### 4.3 The construction

**Definition 4.3.** For an integer $p \ge 1$ define the **Erdős–Turán map** and **Erdős–Turán set**
$$\varphi_p(k) = 2pk + (k^2 \bmod p), \qquad A_p = \{\varphi_p(k) : 0 \le k < p\} \subseteq \mathbb{N}.$$

The design is a two-digit filing system in base $2p$: since $0 \le k < p < 2p$ and $0 \le k^2 \bmod p < p < 2p$, the number $\varphi_p(k)$ has high base-$2p$ digit $k$ and low digit $k^2 \bmod p$.

**Lemma 4.4 (Basic properties).** *For $p \ge 1$: (i) $\varphi_p(k) < 2p^2$ for all $k < p$, so $A_p \subseteq \{0,\dots,2p^2-1\}$; (ii) $\varphi_p$ is injective on $\{0,\dots,p-1\}$, so $|A_p| = p$; (iii) for all $k,\ell$,*
$$\varphi_p(k) + \varphi_p(\ell) = 2p(k+\ell) + \big((k^2 \bmod p) + (\ell^2 \bmod p)\big),$$
*and the bracketed term is $< 2p$, so this is again a base-$2p$ digit decomposition.*

*Proof.* (i) $\varphi_p(k) \le 2p(p-1) + (p-1) < 2p^2$. (ii) By Lemma 4.2 applied with $m = 2p$: equal values force equal high digits, i.e. equal $k$. (iii) Immediate; the bracket is at most $2(p-1) < 2p$, which is precisely the statement that **no carry occurs** when two elements are added. $\square$

Property (iii) is the crux. It says that adding two elements of $A_p$ keeps the two channels of information — the linear datum $k+\ell$ and the quadratic datum $k^2 + \ell^2 \bmod p$ — completely separated.

**Lemma 4.5 (Key rigidity for the construction).** *Let $p$ be an odd prime and $k_1,k_2,k_3,k_4 \in \{0,\dots,p-1\}$ satisfy*
$$k_1 + k_2 \equiv k_3 + k_4 \pmod p \quad\text{and}\quad (k_1^2 \bmod p) + (k_2^2 \bmod p) = (k_3^2 \bmod p) + (k_4^2 \bmod p).$$
*Then $(k_1 = k_3 \wedge k_2 = k_4)$ or $(k_1 = k_4 \wedge k_2 = k_3)$.*

*Proof.* Reduce the second identity modulo $p$: since $k^2 \bmod p \equiv k^2$, it becomes $k_1^2 + k_2^2 \equiv k_3^2 + k_4^2$ in $\mathbb{F}_p$. Together with the first identity, Lemma 4.1 applies in $K = \mathbb{F}_p$ (a field, of characteristic $\ne 2$ as $p$ is odd), giving equality of the images in $\mathbb{F}_p$. Since all four integers lie in $\{0,\dots,p-1\}$, a complete set of residues, the equalities lift to $\mathbb{Z}$. $\square$

**Theorem 4.6 (Erdős–Turán).** *For every odd prime $p$, the set $A_p$ is a Sidon set of size $p$ contained in $\{0,\dots,2p^2-1\}$.*

*Proof.* Let $\varphi_p(k_1) + \varphi_p(k_2) = \varphi_p(k_3) + \varphi_p(k_4)$. By Lemma 4.4(iii), both sides are base-$2p$ decompositions with low digit $< 2p$, so Lemma 4.2 splits the equation into
$$k_1 + k_2 = k_3 + k_4 \quad\text{and}\quad (k_1^2 \bmod p) + (k_2^2 \bmod p) = (k_3^2 \bmod p) + (k_4^2 \bmod p).$$
Lemma 4.5 concludes $\{k_1,k_2\} = \{k_3,k_4\}$, hence $\{\varphi_p(k_1),\varphi_p(k_2)\} = \{\varphi_p(k_3),\varphi_p(k_4)\}$. Size and containment are Lemma 4.4. $\square$

Primality is load-bearing, not cosmetic. For $p = 4$ the analogous set is $\{0, 9, 16, 25\}$ and $0 + 25 = 9 + 16$; for $p = 9$ one likewise finds coincidences. In both cases the failure traces to $\mathbb{Z}/p\mathbb{Z}$ not being a domain, so that the quadratic in Lemma 4.1 can have extra roots. Oddness is needed for the *method* (division by $2$); at $p=2$ the set has two elements and is Sidon for trivial reasons.

### 4.4 The interval sandwich

**Theorem 4.7 (Interval sandwich).** *For every $N \ge 32$,*
$$\sqrt{N/8} \;<\; F(N) \;\le\; \sqrt{2N} + 1 .$$
*In particular $F(N) = \Theta(\sqrt N)$, the two bounds differing by an absolute factor of $4$.*

*Proof.* The upper bound is Theorem 3.3. For the lower bound, set $m = \lfloor\sqrt{N/8}\rfloor$; since $N \ge 32$ we have $m \ge 2$. By **Bertrand's postulate** there is a prime $p$ with $m < p \le 2m$, and $p > m \ge 2$ forces $p$ odd. Now
$$2p^2 \le 2(2m)^2 = 8m^2 \le 8\cdot\lfloor N/8\rfloor \le N,$$
so by Theorem 4.6 the set $A_p$ is a Sidon subset of $\{0,\dots,2p^2-1\} \subseteq \{0,\dots,N-1\}$ of size $p > m$. Hence $F(N) \ge p > m = \lfloor\sqrt{N/8}\rfloor$. $\square$

The maximum is attained and computable: for instance $F(18) = 6$, realised by $\{0,1,3,7,12,17\}$.

---

## 5. Main theorem: the Erdős–Turán set is Sidon modulo $2p^2$

We now come to the central result. The set $A_p$ lives in $\{0,\dots,2p^2-1\}$; we ask whether it stays Sidon in the cyclic group $\mathbb{Z}/2p^2\mathbb{Z}$, where two pairwise sums are identified when they differ by $2p^2$.

The obstruction is concrete. Pairwise sums lie in $[0,4p^2)$. Two of them, being congruent modulo $2p^2$, either coincide — the case already handled by Theorem 4.6 — or differ by exactly $2p^2$. We must rule out the latter, and the tool is the following.

### 5.1 The shifted digit identity is absurd

**Lemma 5.1 (Shift absurdity).** *Let $p$ be an odd prime and $k_1,k_2,k_3,k_4 \in \{0,\dots,p-1\}$. Then it is impossible to have simultaneously*
$$k_3 + k_4 = k_1 + k_2 + p \quad\text{and}\quad (k_1^2 \bmod p) + (k_2^2 \bmod p) = (k_3^2 \bmod p) + (k_4^2 \bmod p).$$

*Proof.* Reduce the first identity modulo $p$: the term $p$ vanishes, so $k_1 + k_2 \equiv k_3 + k_4 \pmod p$. The second identity is unchanged. Lemma 4.5 therefore applies and yields $\{k_1,k_2\} = \{k_3,k_4\}$ as sets of integers, so $k_1 + k_2 = k_3 + k_4$. Substituting into the first identity gives $0 = p$, contradicting $p \ge 3$. $\square$

The lemma is worth reading twice, because its brevity conceals the whole point. The shift by $p$ is *invisible modulo $p$*, so the algebraic rigidity of the construction cannot see it and pins the pair down anyway — and then the rigidity's conclusion, an *exact* identity of integer sums, is what kills the shift. The construction is rigid enough that "off by exactly $p$ in the high digit" is not merely unlikely, it is contradictory.

### 5.2 The theorem

**Theorem 5.2 (Cyclic Erdős–Turán).** *Let $p$ be an odd prime. Then for all $u,v,w,x \in A_p$,*
$$u + v \equiv w + x \pmod{2p^2} \;\Longrightarrow\; (u = w \wedge v = x) \vee (u = x \wedge v = w).$$
*That is, $A_p$ is Sidon modulo $2p^2$.*

*Proof.* Write $u = \varphi_p(k_1)$, $v = \varphi_p(k_2)$, $w = \varphi_p(k_3)$, $x = \varphi_p(k_4)$ with all $k_i < p$, and set
$$S = u+v = 2p(k_1+k_2) + r_{12}, \qquad T = w+x = 2p(k_3+k_4) + r_{34},$$
where $r_{12} = (k_1^2 \bmod p) + (k_2^2 \bmod p) < 2p$ and similarly $r_{34}$, by Lemma 4.4(iii).

By Lemma 4.4(i), $S < 4p^2 = 2\cdot(2p^2)$ and likewise $T < 4p^2$. Both are nonnegative. Hence $S - T$ is an integer multiple $c\cdot 2p^2$ of the modulus with $|c\cdot 2p^2| < 2\cdot 2p^2$, so $c \in \{-1,0,1\}$. We treat the three cases.

**Case $c = 0$.** Then $S = T$ as integers, and Theorem 4.6 gives the conclusion directly.

**Case $c = 1$, i.e. $S = T + 2p^2$.** Since $2p^2 = (2p)\cdot p$,
$$2p(k_1+k_2) + r_{12} = 2p\big((k_3+k_4) + p\big) + r_{34},$$
and both sides are base-$2p$ decompositions with low digits $r_{12}, r_{34} < 2p$. Lemma 4.2 splits them:
$$k_1 + k_2 = k_3 + k_4 + p, \qquad r_{12} = r_{34}.$$
This is exactly the configuration forbidden by Lemma 5.1 (with the roles of the pairs exchanged), a contradiction.

**Case $c = -1$.** Symmetric to the previous case, exchanging the two pairs. $\square$

Note the structural reason for the theorem, which is visible in the proof: **a full period is a clean digit shift**. Because $2p^2 = (2p)\cdot p$, adding the modulus increments the high base-$2p$ digit by exactly $p$ and leaves the low digit untouched. The construction's rigidity determines the high digit sum exactly, so a clean shift cannot be absorbed.

### 5.3 Consequences in the cyclic group

**Definition 5.3.** Let $\overline{A_p} \subseteq \mathbb{Z}/2p^2\mathbb{Z}$ denote the image of $A_p$ under reduction modulo $2p^2$.

**Proposition 5.4.** *For $p \ge 1$, reduction modulo $2p^2$ is injective on $A_p$, so $|\overline{A_p}| = p$.*

*Proof.* $A_p \subseteq \{0,\dots,2p^2-1\}$ by Lemma 4.4(i), and reduction is injective on a complete residue interval. $\square$

**Theorem 5.5.** *For every odd prime $p$, $\overline{A_p}$ is a Sidon set of size $p$ in $\mathbb{Z}/2p^2\mathbb{Z}$.*

*Proof.* A relation $\bar u + \bar v = \bar w + \bar x$ in $\mathbb{Z}/2p^2\mathbb{Z}$ is exactly the congruence $u+v \equiv w+x \pmod{2p^2}$; apply Theorem 5.2 and Proposition 5.4. $\square$

**Theorem 5.6 (Cyclic sandwich, prime case).** *Let $p$ be an odd prime and $N = 2p^2$. Then $\mathbb{Z}/N\mathbb{Z}$ contains a Sidon set of size*
$$p = \sqrt{N/2},$$
*and every Sidon set in $\mathbb{Z}/N\mathbb{Z}$ has size at most $\sqrt N + 1$. The two bounds differ by a factor of $\sqrt 2$.*

*Proof.* Existence is Theorem 5.5; the ceiling is Theorem 3.2 applied to $G = \mathbb{Z}/N\mathbb{Z}$. $\square$

This is a considerably tighter sandwich than the interval sandwich of Theorem 4.7, whose ratio is $4$. The improvement comes from two sources: in a group of order $N$ there are only $N-1$ available differences rather than $2N-2$, sharpening the ceiling; and we are choosing $N$ adapted to $p$ rather than accommodating an arbitrary $N$ via Bertrand's postulate.

### 5.4 Sharpness of the modulus

Direct evaluation over all $\binom{p+1}{2}$ pairwise sums establishes that for $p = 3, 5, 7, 11, 13$ the set $A_p$ is Sidon modulo $2p^2$ — as Theorem 5.2 asserts — and, in every one of those cases, **fails** to be Sidon modulo $2p^2 + 1$. Take $p = 3$: here $A_3 = \{0, 7, 13\}$ and $2p^2 = 18$. Modulo $18$ the six pairwise sums are $0, 7, 13, 14, 2, 8$, all distinct. Modulo $19$, however, $13 + 13 = 26 \equiv 7 = 0 + 7$, while $\{13,13\} \ne \{0,7\}$: the wrapped sum collides with an unwrapped one. Analogous collisions occur at every listed prime.

The conceptual explanation matches the proof of Theorem 5.2. At modulus $2p^2$ the wrap is a clean base-$2p$ digit shift by $p$, and the construction is rigid against digit shifts. At modulus $2p^2 + 1$ the wrap is a shift by $p$ in the high digit *together with* a decrement in the low digit, which the rigidity does not forbid — and generically does not avoid. Thus $2p^2$ is exactly the boundary of the phenomenon: it is both the smallest modulus preserving distinctness of the elements and the largest one at which the wrap is harmless for a structural reason.

---

## 6. Transfer, and Sidon sets in every cyclic group

Theorem 5.5 supplies large Sidon sets in $\mathbb{Z}/N\mathbb{Z}$ for the special moduli $N = 2p^2$. To reach every $N$ we combine a soft transfer principle with Bertrand's postulate.

**Theorem 6.1 (Transfer principle).** *Let $A \subseteq \{0,\dots,n-1\}$ be Sidon and let $N \ge 2n$. Then the reduction of $A$ modulo $N$ is Sidon in $\mathbb{Z}/N\mathbb{Z}$, and it has $|A|$ elements.*

*Proof.* Let $u,v,w,x \in A$ with $u+v \equiv w+x \pmod N$. All four lie in $\{0,\dots,n-1\}$, so $u+v < 2n \le N$ and $w+x < 2n \le N$; a congruence between two integers in $[0,N)$ is an equality. Hence $u+v = w+x$, and the Sidon property of $A$ in $\mathbb{N}$ gives the conclusion. Injectivity of the reduction on $A$ follows from $n \le N$. $\square$

The hypothesis $N \ge 2n$ is exactly what forbids wrap-around, and it is not removable in general — which is precisely what makes Theorem 5.2, operating at $N = n$, a genuinely stronger statement requiring genuinely arithmetic input.

**Theorem 6.2 (Large Sidon sets in every cyclic group).** *For every $N \ge 64$, the group $\mathbb{Z}/N\mathbb{Z}$ contains a Sidon set of size $> \sqrt{N/16}$.*

*Proof.* Put $m = \lfloor\sqrt{N/16}\rfloor$; from $N \ge 64$ we get $m \ge 2$. By Bertrand's postulate choose a prime $p$ with $m < p \le 2m$; then $p \ge 3$ is odd. Now
$$2\cdot(2p^2) = 4p^2 \le 4(2m)^2 = 16m^2 \le 16\lfloor N/16 \rfloor \le N,$$
so the Erdős–Turán set $A_p \subseteq \{0,\dots,2p^2-1\}$ satisfies the hypothesis of Theorem 6.1 with $n = 2p^2$. Its reduction modulo $N$ is therefore a Sidon set in $\mathbb{Z}/N\mathbb{Z}$ of size $p > m$. $\square$

**Theorem 6.3 (Cyclic sandwich).** *For every $N \ge 64$,*
$$\sqrt{N/16} \;<\; \max\{|A| : A \subseteq \mathbb{Z}/N\mathbb{Z} \text{ Sidon}\} \;\le\; \sqrt N + 1 .$$
*Hence every cyclic group of order $N$ realises $\Theta(\sqrt N)$, with the same asymptotics as the interval.*

*Proof.* Theorem 6.2 and Theorem 3.2. $\square$

The threshold $N \ge 64$ is what guarantees both $\lfloor\sqrt{N/16}\rfloor \ge 2$ and that Bertrand's window contains an odd prime; below it no claim is made, and indeed the statement would be uninteresting there.

Observe that Theorem 5.6 beats Theorem 6.3 by a factor of $2\sqrt2$ on the special moduli $2p^2$, because it avoids the transfer principle's factor-of-two waste. Closing that gap for general $N$ would require lifting Theorem 5.2 from the moduli $2p^2$ to a denser family — see §11.

---

## 7. Structural theory

### 7.1 Counting characterisations

**Theorem 7.1 (Sumset characterisation).** *For a finite set $A$ in an additive cancellative commutative monoid,*
$$A \text{ is Sidon} \iff |A + A| = \binom{|A|+1}{2}.$$

*Proof.* The sumset $A+A$ is the image of the set of unordered pairs from $A$ (with repetition), which has exactly $\binom{|A|+1}{2}$ elements, under the map $\{a,b\} \mapsto a+b$. So $|A+A| \le \binom{|A|+1}{2}$ always, with equality iff that map is injective — which is verbatim the Sidon condition. $\square$

This makes the Sidon property a purely quantitative statement: a set is Sidon exactly when its sumset is as large as arithmetic permits. It is the cleanest formulation for computational testing, since $|A+A|$ can be computed in $O(|A|^2)$ time with a hash set.

**Theorem 7.2 (Difference count).** *Let $A$ be a nonempty Sidon set in an abelian group. Then*
$$|A - A| = |A|^2 - |A| + 1 .$$

*Proof.* $A - A = \{0\} \cup D(A)$, where $D(A)$ is the set of differences of distinct elements. By Lemma 3.1 the map $(a,b) \mapsto a-b$ is injective on the off-diagonal, so $|D(A)| = |A|(|A|-1)$; and $0 \notin D(A)$. $\square$

### 7.2 Extremal rigidity and perfect difference sets

**Definition 7.3.** A Sidon set $A$ in a finite abelian group $G$ is a **perfect difference set** (a *planar difference set*) if $D(A) = G \setminus \{0\}$, i.e. every nonzero element of $G$ is a difference of two elements of $A$.

**Theorem 7.4 (Extremal rigidity).** *Let $A$ be a Sidon set in a finite abelian group $G$. Then*
$$D(A) = G\setminus\{0\} \iff |A|^2 - |A| = |G| - 1 .$$

*Proof.* By Lemma 3.1, $|D(A)| = |A|^2 - |A|$ always. Also $D(A) \subseteq G \setminus\{0\}$, a set of size $|G|-1$. A subset of a finite set equals it iff their cardinalities agree. $\square$

The value of this innocuous statement is methodological: it converts the *structural* question "does $A$ hit every nonzero element exactly once?" into a *numerical* one. One no longer needs to exhibit the difference bijection; one only counts.

**Theorem 7.5 (Order constraint).** *If a nonempty Sidon set $A$ of size $k$ in a finite abelian group $G$ is a perfect difference set, then*
$$|G| = k^2 - k + 1 .$$

*Proof.* Immediate from Theorem 7.4. $\square$

This is the elementary half of the classical theory of planar difference sets; the deep half (Bruck–Ryser–Chowla, and the prime power conjecture) concerns which orders $k-1$ actually occur.

**Example 7.6.** The set $\{0,1,3,9\} \subseteq \mathbb{Z}/13\mathbb{Z}$ is Sidon of size $4$, and $4^2 - 4 + 1 = 13$; by Theorem 7.4 it is a perfect difference set. Its twelve ordered differences realise each of the twelve nonzero residues exactly once, so every nonzero $g \in \mathbb{Z}/13\mathbb{Z}$ has a *unique* representation $g = a - b$ with $a,b \in \{0,1,3,9\}$, $a \ne b$. This is the point set of a line in the projective plane $PG(2,3)$ transported along a Singer cycle, which is why $13 = 3^2 + 3 + 1$.

### 7.3 Affine invariance

**Theorem 7.7 (Translation invariance).** *For any finite $A$ in an additive cancellative commutative monoid and any $t$, the translate $A + t$ is Sidon iff $A$ is.*

*Proof.* $(a+t)+(b+t) = (c+t)+(d+t)$ iff $(a+b) + 2t = (c+d)+2t$ iff $a+b = c+d$, by cancellation. $\square$

**Theorem 7.8 (Dilation invariance).** *Let $R$ be a commutative ring, $A \subseteq R$ finite, and $u \in R^\times$ a unit. Then $uA$ is Sidon iff $A$ is.*

*Proof.* Multiplication by a unit is an additive bijection of $R$, so it preserves and reflects all additive relations $a+b = c+d$. $\square$

Consequently Sidon sets come in affine orbits, and in a classification one may normalise, say, $0 \in A$. Note that dilation by a **non-unit** genuinely fails: the image can collapse and the statement is false.

### 7.4 The Erdős–Turán set is never extremal in its own group

**Theorem 7.9.** *For every odd prime $p$, the reduction $\overline{A_p} \subseteq \mathbb{Z}/2p^2\mathbb{Z}$ is Sidon (Theorem 5.5) but is **not** a perfect difference set.*

*Proof.* Its differences number $p^2 - p$, while $|\mathbb{Z}/2p^2\mathbb{Z}| - 1 = 2p^2 - 1$. For $p \ge 3$, $p^2 - p < 2p^2 - 1$, so equality in Theorem 7.4 fails. Alternatively and more structurally: by Theorem 7.5, a group carrying a perfect difference set has odd order $k^2-k+1$, whereas $2p^2$ is even. $\square$

So the construction is efficient (size $\sqrt{N/2}$, within $\sqrt 2$ of the ceiling) but not extremal; genuine extremality requires the Singer construction, and only for the special orders $q^2+q+1$.

---

## 8. Bridge to extremal graph theory

**Definition 8.1.** Let $G$ be an abelian group and $A \subseteq G$. The **Sidon incidence graph** of $A$ is the bipartite graph on the vertex set $G \sqcup G$ in which a left vertex $x$ and a right vertex $y$ are adjacent when $y - x \in A$.

Right-degrees are uniformly $|A|$: the neighbours of $y$ are exactly $\{y - a : a \in A\}$, which has $|A|$ elements since $a \mapsto y-a$ is injective.

**Theorem 8.2 (Sidon $\iff$ $C_4$-free).** *$A$ is a Sidon set if and only if its incidence graph contains no four-cycle; equivalently, if and only if any two distinct vertices have at most one common neighbour.*

*Proof sketch.* ($\Rightarrow$) Suppose left vertices $x \ne x'$ have two common neighbours $y \ne y'$. Then $y - x, y - x', y' - x, y' - x' \in A$, and
$$(y-x) + (y'-x') = (y-x') + (y'-x),$$
with $y-x \ne y-x'$ (as $x \ne x'$) and $y-x \ne y'-x$ (as $y \ne y'$). This is a genuine violation of the Sidon condition. ($\Leftarrow$) Conversely, a violation $a+b = c+d$ with $\{a,b\} \ne \{c,d\}$ produces, by reversing the computation, a four-cycle. $\square$

The equivalence turns the additive question into an extremal-graph question, and the classical machinery then reproves the ceiling:

**Theorem 8.3 (Reiman double count).** *For a Sidon set $A$ in a finite abelian group $G$,*
$$|A|^2 - |A| \le |G| - 1 .$$

*Proof sketch.* Count "cherries" — paths of length two centred at a right vertex — in two ways. Each of the $|G|$ right vertices has degree $|A|$ and hence contributes $\binom{|A|}{2}$ unordered pairs of left neighbours. By Theorem 8.2 no pair of distinct left vertices is counted twice, so
$$|G|\binom{|A|}{2} \le \binom{|G|}{2},$$
which rearranges to $|A|(|A|-1) \le |G|-1$. $\square$

This is Reiman's inequality, the bipartite case of the Kővári–Sós–Turán theorem, and it is a genuinely independent derivation: it never mentions the difference map. That two structurally unrelated arguments deliver the identical constant is evidence that $\sqrt{|G|}$ is the true ceiling and not an artefact.

---

## 9. Algorithms

Four computational tasks arise naturally, and all are elementary but worth stating precisely.

**(A) Sidon testing in $\mathbb{Z}/N\mathbb{Z}$.** Given $A$ and $N$, compute the multiset of $\binom{|A|+1}{2}$ unordered pairwise sums reduced modulo $N$ and check that they are pairwise distinct — equivalently, by Theorem 7.1, that the number of distinct values is $\binom{|A|+1}{2}$. Time $O(|A|^2)$ with a hash set, space $O(|A|^2)$. Setting $N = \infty$ recovers the test in $\mathbb{Z}$.

**(B) Erdős–Turán generation.** Given an odd prime $p$, output $\{2pk + (k^2 \bmod p) : 0 \le k < p\}$. Time $O(p)$. By Theorem 5.5 the output is a Sidon set of size $p$ in $\mathbb{Z}/2p^2\mathbb{Z}$.

**(C) Large Sidon set in an arbitrary $\mathbb{Z}/N\mathbb{Z}$ ($N \ge 64$).** Compute $m = \lfloor\sqrt{N/16}\rfloor$, find by trial division the least prime $p > m$ (Bertrand guarantees $p \le 2m$), generate $A_p$ by (B), reduce modulo $N$. Time dominated by the primality search, $O(m \cdot \sqrt m)$ by naive trial division, or $O(m \log\log m)$ with a sieve; the output has size $p > \sqrt{N/16}$ by Theorem 6.2.

**(D) Exact maximum by search.** Compute $F(n)$ by depth-first search over increasing subsets of $\{0,\dots,n-1\}$, maintaining the set of realised differences and pruning as soon as a duplicate appears. Exponential in the worst case but effective for $n$ up to a few dozen; the branch-and-bound prune from Theorem 3.3 (if $k$ marks are placed and $k(k-1) + (\text{remaining pairs}) > 2n-2$, backtrack) cuts the tree substantially.

---

## 10. Applications

The recurring theme is that a Sidon set is a maximally *non-redundant* measuring device.

**Sparse antenna arrays and radio interferometry.** In aperture synthesis each pair of antennas samples one spatial-frequency baseline. Placing antennas at the positions of a Sidon set makes all $\binom{k}{2}$ baselines distinct, maximising the number of independent Fourier samples per antenna. Theorem 3.3 is precisely the statement of how much resolution one can buy with $k$ antennas.

**Radar and sonar waveform design.** A pulse train fired at the times of a Sidon set has an autocorrelation with all off-peak values at most $1$: no pair of pulses is spaced like another, so no ghost target can appear at a false range. The two-dimensional analogue is the Costas array, used in frequency-hopping radar.

**Coded-aperture imaging.** For hard X-rays and gamma rays, where refractive optics do not exist, one images through a mask whose transparent elements form a perfect difference set. Then the mask's autocorrelation is a delta function plus a flat background, and the recorded shadow can be deconvolved exactly. This is the direct engineering payoff of Theorem 7.4.

**Codes and finite geometry.** Perfect difference sets in $\mathbb{Z}/(q^2+q+1)\mathbb{Z}$ are equivalent to cyclic projective planes of order $q$; the same objects generate difference-set codes with known weight distributions. Example 7.6 is the smallest nontrivial instance beyond the Fano plane.

**Cryptographic sequences.** Difference sets underlie sequences with two-level autocorrelation, used as spreading codes in CDMA systems and as building blocks for pseudorandom generators.

**Additive combinatorics itself.** $B_2$-sets are the extreme case of sets with small additive energy; the counting characterisation of Theorem 7.1 is the base case of a whole hierarchy ($B_h$-sets, Sidon sets in the Fourier-analytic sense, sets with prescribed additive energy) whose study drives much of modern additive combinatorics.

---

## 11. Discussion and future directions

The results above complete an elementary but sharp picture for cyclic groups: the maximum Sidon set size is $\Theta(\sqrt N)$ in $\mathbb{Z}/N\mathbb{Z}$ for all $N \ge 64$ (Theorem 6.3), and on the sub-family $N = 2p^2$ the constants tighten to a $\sqrt2$-sandwich (Theorem 5.6). The conceptual content of the main theorem is a robustness statement: the algebraic rigidity underlying the Erdős–Turán construction is strong enough to survive a quotient at the tightest available modulus, because the quotient acts on the construction as a clean digit shift and the rigidity pins the digits exactly. The numerical failure at modulus $2p^2 + 1$ shows this is a knife-edge phenomenon and not a soft one.

Several precise directions suggest themselves; each is falsifiable by an explicit finite computation.

**Singer perfect difference sets.** For every prime power $q$, the group $\mathbb{Z}/(q^2+q+1)\mathbb{Z}$ should contain a Sidon set of size $q+1$, and by Theorem 7.4 that set is automatically a perfect difference set, since $(q+1)^2 - (q+1) = q^2+q = (q^2+q+1)-1$. The key leverage is that extremal rigidity has already reduced the whole Singer theorem to a *pure cardinality equation*: one need not exhibit the difference bijection, only count. The construction itself is the orbit of a line of $PG(2,q)$ under a Singer cycle, i.e. under a generator of $\mathbb{F}_{q^3}^\times/\mathbb{F}_q^\times$ acting on $\mathbb{F}_{q^3}$; the Sidon property is exactly "two distinct points determine one line". The statement is falsifiable at $q=2$: it predicts a Sidon set of size $3$ in $\mathbb{Z}/7\mathbb{Z}$ whose differences cover $\{1,\dots,6\}$ exactly — and $\{0,1,3\}$ does.

**A refined upper bound with the $N^{1/4}$ term.** The classical sharpening of the Erdős–Turán ceiling replaces $\sqrt{2N}$ by $\sqrt N + N^{1/4} + 1$, using a windowed counting argument that exploits the near-uniform distribution of differences at multiple scales rather than counting all differences at once. Establishing $F(N) \le \sqrt N + N^{1/4} + 1$ would strictly sharpen Theorem 3.3 and bring the interval sandwich down from ratio $4$ to ratio close to $\sqrt 8$ against the current lower bound.

**Denser families of good moduli.** Theorem 5.2 shows $2p^2$ is a "harmless" modulus. Which other $N$ are harmless for which constructions? A natural conjecture is that any modulus of the form $b\cdot p$ where $b$ is the digit base of a two-digit construction should behave the same way; if so, the transfer principle's factor-of-two loss could be removed for a much denser set of $N$, improving the constant in Theorem 6.3 from $1/16$ towards $1/2$.

**Non-cyclic abelian groups.** Theorem 3.2 holds for arbitrary finite abelian $G$, but our constructions are cyclic. Does every abelian group of order $N$ contain a Sidon set of size $\Theta(\sqrt N)$? Elementary abelian $2$-groups are a natural first test case, where the classical Bose–Chowla and Singer constructions in $\mathbb{F}_{2^m}$ suggest a positive answer with good constants.

**$B_h$-generalisations.** Replacing pairs by $h$-tuples, a $B_h$-set has all $h$-fold sums distinct, and the counting bound becomes $|A| = O(N^{1/h})$. The Bose–Chowla construction generalises; the natural question here is whether the digit-shift rigidity that gives Theorem 5.2 has a $B_h$ analogue at the modulus matching the construction's natural range.

**Effective classification for small orders.** Exhaustive search (Algorithm D) determines $F(n)$ for small $n$. Tabulating maximal Sidon sets in $\mathbb{Z}/N\mathbb{Z}$ for $N \le 100$, modulo the affine symmetry group of Theorems 7.7 and 7.8, would give an empirical handle on the true constant in Theorem 6.3.

---

## 12. Conclusion

A Sidon set is an injectivity in disguise, and everything in this theory follows from playing that injectivity against a counting argument in one direction and against an algebraic rigidity in the other. Counting caps the size at $\sqrt{2N}$ on an interval and $\sqrt N + 1$ in a group. Newton–Vieta rigidity — a monic quadratic is determined by its power sums — builds a matching construction, by the device of storing $k$ and $k^2 \bmod p$ in two separate base-$2p$ digits of one integer.

The new content is that this rigidity is stronger than the interval statement it was designed for. The Erdős–Turán set remains Sidon after passing to the cyclic group of order exactly $2p^2$, because a wrap-around is precisely a shift of the high digit by $p$, and the rigidity determines the high digit sum on the nose. Consequently the cyclic and interval theories agree up to an absolute constant, both realising $\Theta(\sqrt N)$; and on the moduli $2p^2$ the cyclic theory is in fact tighter, sandwiched within a factor $\sqrt 2$. The modulus is sharp: one unit larger and the construction fails.
