# The Whole Exceeds the Sum: Exact and Extremal Emergence in Composite Labels, with an Application to the Jacobi Symbol

**Aristotle** · 2026-10-02

---

## Abstract

We study *emergence* in the information-theoretic sense. A family of components each carries no information about a target label, yet the family as a whole determines the label. Working with Shannon mutual information on a finite probability space, we prove two general criteria. The *fibre-swap criterion* says that if every pair of label fibres can be exchanged by a measure-preserving bijection fixing an observable $X$, then $X$ carries exactly zero information about the label. The *determined-label law* says that if, in addition, the label is a function of $X$, then $X$ carries exactly $\log|\beta|$ nats, where $\beta$ is the label alphabet. We apply these criteria to the *sum label* $L = x_1+\dots+x_k$ of $k$ independent uniform components in a finite abelian group $A$. Every proper sub-family of components is blind to $L$, the whole family carries $\log|A|$, and for $k\ge 2$ the synergy $I(\text{whole};L)-\sum_i I(x_i;L)$ equals $\log|A|$. The threshold is sharp: a single component is blind if and only if $k\ge2$. We then prove Gibbs' inequality from the bound $\log t\le t-1$ and derive the label-capacity bound $I(X;Y)\le H(Y)\le\log|\beta|$. It follows that the emergent information is *saturated*: no observable whatsoever exceeds what the whole carries. The arithmetic instance is the Jacobi symbol modulo a squarefree product of $k\ge2$ odd primes. Any statistic of a uniformly random unit that depends on its residues modulo a proper subset of the primes carries exactly $0$ bits about the Jacobi symbol. The full residue carries exactly $1$ bit, and no statistic carries more. Finally, we show that a measured read of $1.8170$ bits about a composite label forces that label to take at least four values, since $\log_2 3<8/5$. The measured composite label therefore cannot be the Jacobi bit, and its value lies strictly below the $2$-bit capacity of a four-valued label.

---

## 1. Introduction

The phrase "the whole is greater than the sum of its parts" is usually a metaphor. Information theory can turn it into an inequality. Take components $X_1,\dots,X_k$ and a target label $L$, and compare what the whole tuple says about $L$ with what the parts say individually:

$$\operatorname{Syn}(X_1,\dots,X_k;L) \;=\; I\big((X_1,\dots,X_k);L\big) \;-\; \sum_{i=1}^k I(X_i;L).$$

When the components carry redundant information about $L$, the synergy can be negative. When they carry complementary information, it is positive. The extreme case, which we call *pure emergence*, is when every $I(X_i;L)$ vanishes and the left-hand term does not.

This paper was motivated by an empirical observation made in a series of experiments on composite moduli. At the semiprime level, three irreducible components each appeared to carry approximately zero information about a "composite type" label, while the composite label itself was read at $1.8170$ bits. We call the effect *the whole exceeds the sum*. Our aims are:

1. to state and prove exact theorems explaining why "approximately zero" is in fact *exactly* zero under uniform sampling;
2. to compute the information carried by the whole exactly, and to show that it is the maximum possible (*saturation*);
3. to instantiate the theory on the most natural arithmetic composite label, the Jacobi symbol;
4. to determine which labels are compatible with the measured figure of $1.8170$ bits.

The results fall into three layers. The abstract layer (Section 2) gives the fibre-swap criterion and the determined-label law for arbitrary finite probability spaces. The group layer (Sections 3–4) treats sum labels in finite abelian groups, proves a sharp emergence dichotomy, and proves the capacity bound together with saturation. The arithmetic layer (Section 5) applies all of this to the Jacobi symbol, and also proves the four-types theorem for the measured read.

---

## 2. Mutual information of observables and two exact criteria

### 2.1 Setting

Let $\Omega$ be a finite sample space carrying weights $\mu:\Omega\to\mathbb R_{\ge0}$ with $\sum_\omega\mu(\omega)=1$. An *observable* is a map $X:\Omega\to\alpha$ into a finite set $\alpha$.

**Definition 2.1 (joint law).** For observables $X:\Omega\to\alpha$ and $Y:\Omega\to\beta$, the *joint table* is
$$p_{X,Y}(a,b) \;=\; \sum_{\omega:\,X(\omega)=a,\;Y(\omega)=b}\mu(\omega).$$
Its marginals are $p_X(a)=\sum_b p_{X,Y}(a,b)$ and $p_Y(b)=\sum_a p_{X,Y}(a,b)$. The entries are nonnegative and add up to $\sum_\omega \mu(\omega)=1$.

**Definition 2.2 (mutual information).** For a nonnegative table $p$ on $\alpha\times\beta$ with marginals $p_X,p_Y$,
$$I(p) \;=\; \sum_{a\in\alpha}\sum_{b\in\beta} p(a,b)\,\log\frac{p(a,b)}{p_X(a)\,p_Y(b)},$$
with natural logarithms and the convention that terms with $p(a,b)=0$ vanish. For observables we write $I(X;Y)=I(p_{X,Y})$. This is measured in *nats*. The value in *bits* is $I/\log 2$.

**Definition 2.3 (label entropy).** $H(Y)=-\sum_b p_Y(b)\log p_Y(b)$.

### 2.2 Tables constant in the label

**Lemma 2.4 (constant tables carry nothing).** *Let $p$ be a nonnegative table on $\alpha\times\beta$ with total mass $1$, and suppose $p(a,b)=p(a,b')$ for all $a,b,b'$. Then $I(p)=0$.*

*Proof sketch.* Write $p(a,b)=c_a$. Then $p_X(a)=|\beta|\,c_a$ and $p_Y(b)=\sum_a c_a = 1/|\beta|$, because the total mass is $|\beta|\sum_a c_a=1$. Whenever $c_a>0$ the ratio inside the logarithm is $c_a/(|\beta|c_a\cdot|\beta|^{-1})=1$, and $\log 1=0$. The terms with $c_a=0$ vanish by convention. $\square$

### 2.3 The fibre-swap criterion

For a label $Y:\Omega\to\beta$ and $b\in\beta$, the *fibre* over $b$ is $Y^{-1}(b)$.

**Theorem 2.5 (fibre-swap criterion).** *Let $X:\Omega\to\alpha$ and $Y:\Omega\to\beta$ be observables. Suppose that for every pair $b,b'\in\beta$ there is a bijection $\tau:\Omega\to\Omega$ such that*
1. *$\mu(\tau\omega)=\mu(\omega)$ for all $\omega$ ($\tau$ preserves the weights),*
2. *$X(\tau\omega)=X(\omega)$ for all $\omega$ ($\tau$ fixes the observable),*
3. *$Y(\tau\omega)=b'$ if and only if $Y(\omega)=b$ ($\tau$ carries the fibre over $b$ onto the fibre over $b'$).*

*Then $I(X;Y)=0$.*

*Proof sketch.* Fix $a\in\alpha$. Reindex the sum defining $p_{X,Y}(a,b')$ along $\tau$. Properties 1–3 turn the summand at $\tau\omega$ into the summand of $p_{X,Y}(a,b)$ at $\omega$, so $p_{X,Y}(a,b')=p_{X,Y}(a,b)$. The joint table is therefore constant in the label coordinate, and Lemma 2.4 gives $I=0$. $\square$

The criterion is a *symmetry certificate*. Exhibiting the swaps proves that $X$ and $Y$ are exactly independent, so no estimate is needed.

### 2.4 The determined-label law

**Lemma 2.6 (swaps make the label uniform).** *If for all $b,b'$ there is a weight-preserving bijection $\tau$ of $\Omega$ carrying the fibre over $b$ onto the fibre over $b'$ (no condition on any $X$), then $\Pr[Y=b]=1/|\beta|$ for every $b$.*

*Proof sketch.* Reindexing along $\tau$ shows that all the fibre masses are equal. They add up to $1$. $\square$

**Theorem 2.7 (determined-label law).** *Let $X:\Omega\to\alpha$ and $Y:\Omega\to\beta$, and suppose $Y=\varphi\circ X$ for some $\varphi:\alpha\to\beta$. Suppose also that the label fibres can be swapped by weight-preserving bijections as in Lemma 2.6. Then*
$$I(X;Y)=\log|\beta|.$$

*Proof sketch.* Since $Y$ is a function of $X$, we have $p_{X,Y}(a,b)=p_X(a)$ if $\varphi(a)=b$ and $0$ otherwise. By Lemma 2.6, $p_Y(b)=1/|\beta|$. Each nonzero term is $p_X(a)\log\frac{p_X(a)}{p_X(a)/|\beta|}=p_X(a)\log|\beta|$. Summing over $a$ gives $\log|\beta|$. $\square$

---

## 3. Sum labels in finite abelian groups

### 3.1 The model

Let $A$ be a finite abelian group, written additively, and let $k\in\mathbb N$. The sample space is $\Omega=A^k$ with the uniform weights $\mu(\omega)=|A|^{-k}$.

**Definition 3.1.**
- The *components* are the coordinate observables $x_i(\omega)=\omega_i$.
- For $S\subseteq\{1,\dots,k\}$, the *sub-family observable* is the restriction $\omega\mapsto(\omega_i)_{i\in S}$.
- The *composite label* is the sum $L(\omega)=\sum_{i=1}^k\omega_i\in A$.

The key identity is that translating a single coordinate translates the label:
$$L(\omega+c\,e_j) \;=\; L(\omega)+c,$$
where $c\,e_j$ is the vector with $c$ in coordinate $j$ and $0$ elsewhere. So the translation $\tau_{j,c}:\omega\mapsto\omega+c\,e_j$ with $c=b'-b$ carries the fibre over $b$ onto the fibre over $b'$. It preserves the uniform weights, and it fixes every coordinate other than $j$.

### 3.2 Blindness of proper sub-families and the value of the whole

**Theorem 3.2 (every proper sub-family is blind).** *For every proper subset $S\subsetneq\{1,\dots,k\}$, the sub-family $(x_i)_{i\in S}$ carries exactly zero information about $L$:*
$$I\big((x_i)_{i\in S};L\big)=0.$$

*Proof sketch.* Choose $j\notin S$. The translations $\tau_{j,b'-b}$ fix the restriction to $S$, preserve the weights and swap the label fibres. Theorem 2.5 applies. $\square$

**Theorem 3.3 (the whole carries everything).** *For $k\ge1$,*
$$I\big((x_1,\dots,x_k);L\big)=\log|A|.$$

*Proof sketch.* $L$ is a function of the full tuple, and the translations $\tau_{1,b'-b}$ supply fibre swaps. Theorem 2.7 applies with $\beta=A$. $\square$

**Corollary 3.4 (single components are blind).** *If $k\ge2$, then $I(x_i;L)=0$ for every $i$.*

This is Theorem 3.2 with $S=\{i\}$, which is a proper subset because $k\ge2$.

### 3.3 The synergy theorem and the emergence dichotomy

**Theorem 3.5 (The Whole Exceeds the Sum).** *Let $k\ge2$ and $|A|>1$. Then*
$$I\big((x_1,\dots,x_k);L\big)-\sum_{i=1}^k I(x_i;L) \;=\; \log|A|,$$
*and in particular $\sum_i I(x_i;L)=0<\log|A|=I\big((x_1,\dots,x_k);L\big)$.*

*Proof sketch.* Combine Theorem 3.3 and Corollary 3.4, and note that $\log|A|>0$ when $|A|>1$. $\square$

**Proposition 3.6 (no emergence with one component).** *For $k=1$, $I(x_1;L)=\log|A|$.*

*Proof sketch.* Here $L=x_1$. Apply Theorem 2.7 with $\varphi=\mathrm{id}$. $\square$

**Theorem 3.7 (emergence dichotomy).** *Let $|A|>1$, $k\ge1$ and $1\le i\le k$. Then*
$$I(x_i;L)=0 \iff k\ge2.$$

*Proof sketch.* The reverse direction is Corollary 3.4. For the forward direction, if $k=1$ then Proposition 3.6 gives $I(x_1;L)=\log|A|>0$. $\square$

At least two irreducible parts are therefore needed before the whole can know something that no part knows.

---

## 4. Capacity and saturation

### 4.1 Gibbs' inequality

**Theorem 4.1 (Gibbs' inequality, uniform form).** *If $q:\beta\to\mathbb R_{\ge0}$ satisfies $\sum_b q_b=1$, then*
$$-\sum_{b\in\beta}q_b\log q_b\;\le\;\log|\beta|.$$

*Proof sketch.* Let $n=|\beta|$. This is positive because $\sum_b q_b=1$ forces $\beta\neq\varnothing$. We claim that for every $b$,
$$-q_b\log q_b-q_b\log n \;\le\; \tfrac1n-q_b.$$
If $q_b=0$ this reads $0\le 1/n$. If $q_b>0$, the left side equals $q_b\log\frac{1}{nq_b}$, and the inequality $\log t\le t-1$ at $t=1/(nq_b)$ gives $q_b\log\frac1{nq_b}\le q_b\big(\frac1{nq_b}-1\big)=\frac1n-q_b$. Summing over $b$ gives $H(q)-\log n\le 1-1=0$. $\square$

### 4.2 The label-capacity bound

**Lemma 4.2 (term-wise comparison).** *For a nonnegative table $p$ and all $(a,b)$,*
$$p(a,b)\log\frac{p(a,b)}{p_X(a)p_Y(b)} \;\le\; -\,p(a,b)\log p_Y(b).$$

*Proof sketch.* If $p(a,b)=0$ both sides vanish. Otherwise $0<p(a,b)\le p_X(a)$ and $p(a,b)\le p_Y(b)$, so
$$\log\frac{p(a,b)}{p_X(a)p_Y(b)}=\log\frac{p(a,b)}{p_X(a)}-\log p_Y(b)\le-\log p_Y(b),$$
because $p(a,b)/p_X(a)\le1$. $\square$

**Theorem 4.3 (information is bounded by label entropy).** *For every nonnegative table, $I(p)\le H(Y)$.*

*Proof sketch.* Sum Lemma 4.2 over $(a,b)$ and exchange the order of summation. Summing over $a$ turns $-\sum_a p(a,b)\log p_Y(b)$ into $-p_Y(b)\log p_Y(b)$. $\square$

**Theorem 4.4 (label-capacity bound).** *For every nonnegative table on $\alpha\times\beta$ of total mass $1$,*
$$I(p)\;\le\;\log|\beta|.$$
*Consequently, for any observables $X,Y$ on a finite probability space, $I(X;Y)\le\log|\beta|$.*

*Proof sketch.* Combine Theorem 4.3 with Theorem 4.1 applied to $q=p_Y$. This $q$ is nonnegative and sums to the total mass $1$. For observables, use the fact that the joint table is nonnegative with total mass $\sum_\omega\mu(\omega)=1$. $\square$

### 4.3 Saturated emergence

**Theorem 4.5 (synergy is saturated).** *In the sum-label model of Section 3 with $k\ge2$:*
1. *every component is blind: $I(x_i;L)=0$ for all $i$;*
2. *the whole carries $I\big((x_1,\dots,x_k);L\big)=\log|A|$;*
3. *every observable $X:A^k\to\alpha$, for any finite $\alpha$, satisfies $I(X;L)\le I\big((x_1,\dots,x_k);L\big)$.*

*Proof sketch.* Items 1 and 2 are Corollary 3.4 and Theorem 3.3. Item 3 follows from Theorem 4.4 with $\beta=A$, together with item 2. $\square$

The emergent information is therefore *extremal* in two senses. The parts carry the minimum possible amount (zero), and the whole carries the maximum that any observable could carry.

### 4.4 How many label types does a read require?

**Lemma 4.6.** $\log 3<1.8170\cdot\log 2$, *that is,* $\log_2 3<1.8170$.

*Proof sketch.* $3^5=243<256=2^8$, so $5\log3<8\log2$, which gives $\log_23<8/5=1.6<1.8170$. $\square$

**Theorem 4.7 (four-types theorem).** *Let $X,Y$ be observables on a finite probability space. If $I(X;Y)/\log2\ge1.8170$, then $|\beta|\ge4$.*

*Proof sketch.* The sample space is nonempty because its weights add up to $1$, so $\beta$ is nonempty. Suppose $|\beta|\le3$. Theorem 4.4 and monotonicity of the logarithm give $I(X;Y)\le\log|\beta|\le\log3<1.8170\log2$, a contradiction. $\square$

The minimal alphabet sizes for a few reads, computed as $\lceil 2^{r}\rceil$ for a read of $r$ bits, are shown below.

| read (bits) | minimal number of label types |
|---|---|
| $\le 1$ | $2$ |
| $(1,\log_2 3]\approx(1,1.585]$ | $3$ |
| $(1.585,2]$, including $1.8170$ | $4$ |
| $(2,\log_2 5]\approx(2,2.322]$ | $5$ |

---

## 5. The arithmetic instance: the Jacobi symbol

### 5.1 Legendre bits

Let $p$ be an odd prime. For a unit $a\in(\mathbb Z/p\mathbb Z)^\times$, define the **Legendre bit**
$$\beta_p(a)=\begin{cases}0 & \text{if } a \text{ is a square in } \mathbb Z/p\mathbb Z,\\ 1 & \text{otherwise.}\end{cases}$$
In terms of the Legendre symbol, $\left(\frac ap\right)=(-1)^{\beta_p(a)}$.

**Lemma 5.1 (nonresidues flip the bit).** *If $p$ is an odd prime and $u$ is a quadratic nonresidue unit mod $p$, then $\beta_p(ua)=\beta_p(a)+1$ in $\mathbb Z/2\mathbb Z$ for every unit $a$.*

*Proof sketch.* The quadratic character $\chi$ of $\mathbb Z/p\mathbb Z$ is multiplicative, takes the value $-1$ exactly on nonsquares, and takes the value $+1$ on nonzero squares. This uses the fact that the characteristic is not $2$. So $\chi(ua)=\chi(u)\chi(a)=-\chi(a)$, and $ua$ is a square exactly when $a$ is not. $\square$

**Lemma 5.2.** *Every odd prime $p$ has a quadratic nonresidue unit.*

This holds because in a finite field of odd characteristic, squaring is two-to-one on the nonzero elements.

### 5.2 The residue model and the Jacobi label

Let $P_1,\dots,P_k$ be odd primes, and let
$$\mathcal R=\prod_{i=1}^k(\mathbb Z/P_i\mathbb Z)^\times,$$
with the uniform law. When the $P_i$ are distinct and $N=P_1\cdots P_k$, the Chinese remainder theorem identifies $\mathcal R$ with $(\mathbb Z/N\mathbb Z)^\times$. A uniformly random unit mod $N$ is then exactly a vector of independent, uniform prime residues.

**Definition 5.3 (Jacobi label).** For $\omega\in\mathcal R$,
$$J(\omega)=\sum_{i=1}^k\beta_{P_i}(\omega_i)\in\mathbb Z/2\mathbb Z.$$
The *prime components* are the coordinate observables $\omega\mapsto\omega_i$. For $S\subseteq\{1,\dots,k\}$, the *residues on $S$* are $\omega\mapsto(\omega_i)_{i\in S}$.

**Theorem 5.4 (bridge to the Jacobi symbol).** *Let $P_1,\dots,P_k$ be primes and let $a\in\mathbb Z$ be prime to each $P_i$. Then*
$$\left(\frac{a}{P_1\cdots P_k}\right)=\prod_{i=1}^k\left(\frac{a}{P_i}\right),$$
*and*
$$\left(\frac{a}{P_1\cdots P_k}\right)=1\iff\sum_{i=1}^k\beta_{P_i}(a)=0\ \text{in }\mathbb Z/2\mathbb Z.$$

*Proof sketch.* The first identity follows by induction on $k$ from multiplicativity of the Jacobi symbol in its lower argument, together with the fact that the Jacobi symbol modulo a prime is the Legendre symbol. Each Legendre symbol equals $(-1)^{\beta_{P_i}(a)}$. A product of signs $(-1)^{g_i}$ equals $(-1)^{\sum g_i}$, which is $+1$ exactly when $\sum_i g_i=0$ in $\mathbb Z/2\mathbb Z$. $\square$

So $J$ is the Jacobi symbol written additively, and Sections 2–4 apply to it.

### 5.3 Label swaps by nonresidue multiplication

**Lemma 5.5 (flipping one coordinate flips the label).** *Fix $j$ and a nonresidue $u$ mod $P_j$. Let $u\,e_j\in\mathcal R$ denote the vector with $u$ in coordinate $j$ and $1$ elsewhere. Then $J\big((u\,e_j)\cdot\omega\big)=J(\omega)+1$.*

*Proof sketch.* Only coordinate $j$ changes, and by Lemma 5.1 its Legendre bit flips. $\square$

**Lemma 5.6 (label-swap family).** *For each $j$ and each $b,b'\in\mathbb Z/2\mathbb Z$ there is a bijection $\tau$ of $\mathcal R$ that preserves the uniform law, fixes every coordinate $i\ne j$, and satisfies $J(\tau\omega)=b'\iff J(\omega)=b$.*

*Proof sketch.* If $b=b'$, take $\tau=\mathrm{id}$. If $b\ne b'$, take $\tau=$ multiplication by $u\,e_j$, where $u$ is a nonresidue mod $P_j$ (Lemma 5.2). By Lemma 5.5 it flips the label, so $J(\omega)+1=b'\iff J(\omega)=b$ in $\mathbb Z/2\mathbb Z$. $\square$

### 5.4 Emergence of the Jacobi symbol

**Theorem 5.7 (proper statistics are blind).** *Let $P_1,\dots,P_k$ be odd primes, let $S\subsetneq\{1,\dots,k\}$, and let $X:\mathcal R\to\alpha$ be any observable that depends only on the coordinates in $S$; that is, $X(\omega)=X(\omega')$ whenever $\omega_i=\omega'_i$ for all $i\in S$. Then*
$$I(X;J)=0.$$

*Proof sketch.* Choose $j\notin S$. The swaps of Lemma 5.6 fix all coordinates in $S$, so they fix $X$. Theorem 2.5 applies. $\square$

**Corollary 5.8.** *The complete residue vector on any proper subset of the primes is blind to $J$. In particular, knowing $a$ modulo every prime but one reveals nothing about the Jacobi symbol.*

**Theorem 5.9 (the whole carries one bit).** *For $k\ge1$ odd primes,*
$$I(\mathrm{id};J)=\log2,$$
*that is, exactly $1$ bit. The vector of Legendre bits $(\beta_{P_i}(\omega_i))_i$ alone also carries exactly $1$ bit about $J$.*

*Proof sketch.* $J$ is a function of $\omega$, and also a function of the Legendre-bit vector, namely its coordinate sum. The swaps of Lemma 5.6 (with $j=1$) supply the fibre exchanges. Theorem 2.7 with $|\beta|=2$ applies. $\square$

**Theorem 5.10 (The Whole Exceeds the Sum, arithmetic form).** *For $k\ge2$ odd primes,*
$$\sum_{i=1}^kI(\omega_i;J)=0,\qquad I(\mathrm{id};J)=\log2,\qquad\text{so}\quad \sum_iI(\omega_i;J)<I(\mathrm{id};J).$$

**Corollary 5.11 (semiprimes).** *For odd primes $p,q$, the residue of $a$ mod $p$ and the residue of $a$ mod $q$ each carry $0$ bits about the Jacobi label of a uniformly random unit $a$ mod $pq$, while the pair carries exactly $1$ bit.*

**Corollary 5.12 (three primes).** *For odd primes $P_1,P_2,P_3$, every* pair *of prime components carries $0$ bits about $J$, while the triple carries exactly $1$ bit.*

**Theorem 5.13 (Jacobi-label capacity).** *For $k\ge2$ odd primes:*
1. *every observable $X$ of a uniformly random unit satisfies $I(X;J)\le 1$ bit;*
2. *the full residue vector carries exactly $1$ bit;*
3. *every single prime component carries exactly $0$ bits.*

*Proof sketch.* Item 1 is Theorem 4.4 with $|\beta|=|\mathbb Z/2\mathbb Z|=2$. Items 2 and 3 are Theorem 5.9 and Theorem 5.7 with $S=\{i\}$. $\square$

The emergence of the Jacobi symbol is therefore extremal. Partial residue knowledge yields nothing, and full knowledge yields the maximum.

### 5.5 Worked enumerations

**$N=15$.** The units are $\{1,2,4,7,8,11,13,14\}$. The squares mod $3$ are $\{1\}$ and the squares mod $5$ are $\{1,4\}$. The joint counts are as follows.

| | $J=0$ (symbol $+1$) | $J=1$ (symbol $-1$) |
|---|---|---|
| $a\equiv1\pmod3$ | 2 | 2 |
| $a\equiv2\pmod3$ | 2 | 2 |

| | $J=0$ | $J=1$ |
|---|---|---|
| $a\equiv1,2,3,4\pmod5$ | 1 each | 1 each |

Both tables are flat, so each prime component carries $0$ bits. Four units have symbol $+1$ and four have symbol $-1$. The full residue determines the symbol, so it carries $1$ bit.

**$N=105=3\cdot5\cdot7$.** There are $48$ units. For each class $r$ mod $15$, the number of units $a\equiv r\pmod{15}$ with $J=0$ equals the number with $J=1$. Knowledge of the pair of residues mod $3$ and mod $5$ is therefore blind, as Corollary 5.12 says. The two label values each occur $24$ times.

These enumerations agree exactly with the general theorems.

---

## 6. Algorithms

**Algorithm A (exact mutual information of observables).** Given a finite list of outcomes with weights and two observables, accumulate the joint table in a hash map. That takes $O(|\Omega|)$ time. Then compute both marginals and evaluate Definition 2.2 in $O(|\operatorname{supp} p|)$ time. For the residue model mod $N$, $|\Omega|=\varphi(N)$.

**Algorithm B (fibre-swap certificate).** Given a candidate family of bijections $\tau_{b,b'}$, check properties 1–3 of Theorem 2.5 for every outcome. This costs $O(|\beta|^2|\Omega|)$. It is enough to check swaps $b_0\to b'$ from one base value together with their inverses, which costs $O(|\beta||\Omega|)$. A successful check proves that $I(X;Y)=0$ exactly, with no floating-point error, and also (Lemma 2.6) that the label is uniform.

**Algorithm C (minimal alphabet for a read).** Given a read of $r$ bits, the minimal label alphabet size is $\lceil2^r\rceil$, by Theorem 4.4. Applying this to $r=1.8170$ gives $4$. The exact certificate is the integer inequality $3^5<2^8$.

**Algorithm D (Jacobi label by Legendre bits).** For $N=\prod P_i$ and a unit $a$, compute each $\beta_{P_i}(a)$ by Euler's criterion $a^{(P_i-1)/2}\bmod P_i$, in $O(\log P_i)$ multiplications, and add the bits mod $2$. By Theorem 5.4 this agrees with the reciprocity-based Jacobi algorithm whenever the factorisation is known.

---

## 7. Discussion

### 7.1 What the theory says about the measured effect

The theory explains three features of the measured effect.

- **"Approximately zero" is exactly zero.** Under the uniform law on units, Theorem 5.7 and its abstract version, Theorem 3.2, leave no room for a small positive leak. Nonzero per-component estimates are therefore sampling artefacts or estimator bias, not structure.
- **The figure $1.8170$ bits is not the Jacobi bit.** By Theorem 5.13 no observable carries more than $1$ bit about $J$. By Theorem 4.7 a read of $1.8170$ bits requires at least four label types. The measured composite label is therefore a richer object than the Jacobi parity.
- **Consistency with emergence.** If the composite label has exactly four types, then its capacity is $2$ bits and the measured read is below capacity. That is compatible with a saturated four-valued emergent label observed through a channel that loses about $0.18$ bits. For example, a symmetric four-symbol channel with error rate about $2.1\%$ yields $1.817$ bits. If the label is a sum label in a group of order at least $4$, Theorems 3.2–3.5 give exact per-component blindness and a whole worth $\log_2|A|\ge2$ bits.

### 7.2 Boundaries

The theory breaks down in two places.

- **$k=1$.** There is no emergence. By Proposition 3.6 and Theorem 3.7, a lone component carries everything.
- **The prime $2$.** $(\mathbb Z/2\mathbb Z)^\times$ is trivial, so there is no nonresidue, and the swap of Lemma 5.6 does not exist. This is why all primes in Section 5 are assumed odd.

### 7.3 Connections

- **Secret sharing.** Additive secret sharing over a group $A$ is precisely the sum-label model. Theorem 3.2 is the statement that any $k-1$ shares are perfectly hiding, and Theorem 4.5 adds that the reconstruction is information-theoretically optimal.
- **Parity and XOR synergy.** For $A=\mathbb Z/2\mathbb Z$ the model is the XOR gate, the standard example of pure synergy in partial-information decompositions. Our results extend it to every finite abelian group and every $k\ge2$, and they add the saturation statement.
- **Quadratic residuosity.** Theorem 5.7 is an exact, unconditional statement that partial residue information about a unit modulo a squarefree $N$ says nothing about its Jacobi symbol. It is the information-theoretic core of the folklore that the Jacobi symbol "mixes" the prime components.

---

## 8. Future directions

1. **Fourier-support characterisation of emergence.** For a uniform law on a finite abelian group $G=\prod_iG_i$ and a label $L:G\to\beta$, we conjecture that the sub-family $S$ is blind to $L$ if and only if no non-trivial character of $G$ supported on $S$ correlates with the level sets of $L$. The fibre-swap criterion would then be the translation-invariant special case of this Fourier condition.
2. **Synergy–entropy identity for character labels.** For a label $L=\chi$, a character $G\to\mu_m$ that is non-trivial on every coordinate, we conjecture that the synergy equals $\log|\operatorname{im}\chi|$ exactly. Here $\chi$ factors as a product of coordinate characters, and each non-trivial factor supplies a label swap. The Jacobi label is the case $m=2$.
3. **Identifying the four-type label.** Find a natural four-valued composite label at the semiprime level whose exact emergent information can be computed, and compare it with the measured $1.8170$ bits.
4. **Non-uniform laws.** Determine how much per-component information leaks when the components are drawn from non-uniform or correlated distributions, and give quantitative versions of the fibre-swap criterion for approximate symmetries.

---

## 9. Conclusion

We have given an exact account of emergence for composite labels. A symmetry certificate (the fibre swap) shows that the parts carry exactly nothing. A determination argument shows that the whole carries the full label entropy. Gibbs' inequality shows that nothing can carry more. For sums in finite abelian groups the synergy is exactly $\log|A|$, with a sharp threshold at two components. For the Jacobi symbol modulo a product of at least two odd primes, every proper statistic carries $0$ bits and the whole carries the maximal $1$ bit. Finally, the capacity bound shows that a measured read of $1.8170$ bits can only come from a label with at least four types.
