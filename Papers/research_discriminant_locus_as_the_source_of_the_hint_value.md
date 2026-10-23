# Branch Value and Conic Value: The Hint Value of a Factor Battery Along the Double Cover $(s,d)\mapsto(s,d^2)$

**Author:** Aristotle

**Date:** 2026-10-23

---

## Abstract

A *factor battery* is a finite, uniformly weighted population of individuals. Each individual carries two factor residues $P,Q$ in a commutative ring $R$ in which $2$ is invertible, together with a label $L$. The *hint value* of the labelling is the mutual information (in bits) that the label shares with the full residue view $(s,d)=(P+Q,\,Q-P)$, minus the mutual information it shares with the product view $N=PQ=(s^2-d^2)/4$. The product view factors through the double cover $\pi(s,d)=(s,d^2)$. Its deck transformation is the *branch swap* $(s,d)\mapsto(s,-d)$, which corresponds to exchanging the two factors, and its ramification locus is the discriminant locus $d=0$, equivalently $s^2=4N$. A natural conjecture holds that labels invariant under the branch swap have the same hint value as the sub-battery supported on the ramification locus. We show that this conjecture is false, using a two-individual counterexample over $\mathbb{Z}/5$, and we prove the correct statement. The hint value decomposes as **branch value + conic value**, both nonnegative. The branch value measures what the order of the factors adds to the unordered pair, and the conic value measures what the sum adds to the product. Swap-invariant labels have branch value zero, so their hint value equals $I(L;s,N)-I(L;N)$. The branch value never exceeds one bit, and more precisely never exceeds the fraction of the population lying off $d=0$ whose mirror point $(s,-d)$ is occupied. In particular the ramification locus carries no branch information. All bounds are sharp. The proofs rest on two facts about coarsenings of a statistic that hold in general: a *pure-merging lemma*, which is the equality case of data processing, and a *two-to-one lemma*, a fibrewise log-sum bound with a refinement that charges only split fibres.

---

## 1. Introduction

Factoring rests on an asymmetry of information. A product $N=PQ$ is easy to compute and hard to invert. Questions about how much side information the factors carry, beyond what the product reveals, can be posed in a clean finite setting. Fix a population of individuals and record for each one a pair of residues $(P,Q)$ and a label. The *hint value* of the labelling is the number of bits about the label that are visible in the factors but not in the product.

The product forgets the order of its factors, since $PQ=QP$. In sum–difference coordinates $s=P+Q$, $d=Q-P$, exchanging the factors sends $(s,d)$ to $(s,-d)$, and the product
$$N \;=\; \frac{s^2-d^2}{4}$$
depends on $d$ only through $d^2$. The map $(s,d)\mapsto N$ therefore factors as
$$(s,d)\;\xrightarrow{\;\pi\;}\;(s,d^2)\;\xrightarrow{\;\kappa\;}\;\frac{s^2-d^2}{4},$$
where $\pi$ is a double cover with deck involution $\sigma(s,d)=(s,-d)$, ramified exactly along $d=0$. That locus is the discriminant $s^2=4N$ of the quadratic $X^2-sX+N$, whose roots are $P$ and $Q$.

This picture suggests the following conjecture.

> **Ramification Conjecture.** If the labels satisfy $L(x)=L(y)$ whenever the residue views of $x$ and $y$ agree in the first coordinate and are negatives in the second, then the hint value of the battery equals the hint value of the restricted battery supported on the ramification locus $d=0$.

If true, the conjecture would make the hint value a ramification invariant of a degree-two cover. Its premise is that the only information the product destroys is the choice of branch.

**Main findings.** The conjecture is false (Theorem 6.1). The reason is that the second arrow $\kappa$ is not injective. Its fibres pull back to the conics $s^2-d^2=4N$, which over $\mathbb{F}_q$ have about $q$ points. The correct statement is a decomposition along the two arrows:

* **Decomposition (Theorem 4.1).** $\mathrm{HV}=B+C$ with $B,C\ge0$, where the *branch value* $B$ is the information lost by $\pi$ and the *conic value* $C$ is the information lost by $\kappa$.
* **Corrected theorem (Theorem 4.4).** Swap-invariant labels have $B=0$, hence $\mathrm{HV}=C=I(L;s,N)-I(L;N)$.
* **One-bit law (Theorems 5.1–5.3).** $B\le 1$ bit. More precisely, $B$ is at most the fraction of the population that lies off $d=0$ and has its mirror occupied. Consequently a battery supported on $d=0$ has purely conic hint value.
* **Sharpness (Theorem 6.2).** Each half of the decomposition can carry a full bit while the other half is $0$.

The structural input is an information calculus for a *coarsening* $g\circ f$ of a statistic $f$ (Section 3). It is stated and proved for arbitrary finite populations and arbitrary maps, so it applies equally to covers of higher degree.

---

## 2. Setting and definitions

### 2.1 Entropy on a finite population

Let $\Omega$ be a finite set, the *population*, with $|\Omega|=n\ge1$, equipped with the uniform probability measure. For a map $f:\Omega\to\alpha$ into any set, write $c_f(a)=|f^{-1}(a)|$ for the count of individuals with value $a$, and define the (natural-log) **entropy**
$$H(f)\;=\;\sum_{a\in f(\Omega)}\phi\big(c_f(a)\big),\qquad \phi(c)\;=\;-\frac{c}{n}\log\frac{c}{n}.$$
For two maps $L:\Omega\to\Lambda$ and $f:\Omega\to\alpha$, write $(L,f):\Omega\to\Lambda\times\alpha$ for the paired map, and define
$$H(L\mid f)\;=\;H(L,f)-H(f),\qquad I(L;f)\;=\;H(L)-H(L\mid f),\qquad I_2(L;f)\;=\;\frac{I(L;f)}{\log 2}.$$
$I_2$ is mutual information measured in bits. Conditional entropy expands as a sum over the image of $f$,
$$H(L\mid f)\;=\;\sum_{a\in f(\Omega)}\ \sum_{l\in L(\Omega)}\psi\big(c_{(L,f)}(l,a),\,c_f(a)\big),\qquad \psi(c,C)\;=\;-\frac{c}{n}\log\frac{c}{C},$$
with $\psi(0,C)=\psi(C,C)=0$.

We use the **data-processing inequality** in its elementary form: if $h$ is any map, then $H(h\circ f)\le H(f)$, and consequently $H(L\mid h\circ f)\ge H(L\mid f)$ and $I(L;h\circ f)\le I(L;f)$.

### 2.2 Batteries and their views

Let $R$ be a commutative ring. A **battery** is a pair of maps $P,Q:\Omega\to R$, called the *factor residues*, together with a **labelling** $L:\Omega\to\Lambda$. We use the following views of an individual $x$:

* the **residue view** $\rho(x)=(s(x),d(x))=(P(x)+Q(x),\;Q(x)-P(x))\in R\times R$;
* the **sum view** $s(x)$;
* the **product view** $N(x)=P(x)Q(x)$.

When $2$ is invertible in $R$, the residue view determines the factors, $P=(s-d)/2$ and $Q=(s+d)/2$, and the product can be recovered from it as
$$N \;=\; \mathrm{prod}(s,d)\;:=\;\tfrac14\,(s^2-d^2).$$
The choice of sign for $d$ plays no role anywhere below.

**Definition 2.1 (Hint value).** The hint value of a labelling is
$$\mathrm{HV}(L;P,Q)\;=\;I_2(L;\rho)\;-\;I_2(L;N).$$

### 2.3 The double cover and the branch swap

**Definition 2.2.** On $R\times R$ define

* the **branch swap** $\sigma(s,d)=(s,-d)$;
* the **double cover** $\pi(s,d)=(s,d^2)$;
* the **conic map** $\kappa(s,e)=\tfrac14(s^2-e)$, defined when $2$ is invertible.

The **branch view** of a battery is $\beta=\pi\circ\rho$, so $\beta(x)=(s(x),d(x)^2)$.

**Definition 2.3 (Swap invariance).** A labelling $L$ is **swap-invariant** for the battery $(P,Q)$ if
$$s(x)=s(y)\ \text{ and }\ d(y)=-d(x)\quad\Longrightarrow\quad L(x)=L(y).$$
A map $\tau:\Omega\to\Omega$ **realises the branch swap** if $P(\tau x)=Q(x)$ and $Q(\tau x)=P(x)$ for all $x$.

**Definition 2.4 (Branch and conic value).**
$$B(L;P,Q)=I_2(L;\rho)-I_2(L;\beta),\qquad C(L;P,Q)=I_2(L;\beta)-I_2(L;N).$$

**Definition 2.5 (Ramified battery).** The **ramification locus** of a battery is $\Omega_0=\{x\in\Omega:\ d(x)=0\}$. The **ramified hint value** $\mathrm{HV}_0(L;P,Q)$ is the hint value of the battery obtained by restricting $P,Q,L$ to $\Omega_0$, with the uniform measure on $\Omega_0$. It is defined to be $0$ if $\Omega_0=\varnothing$.

---

## 3. Information calculus of a coarsening

Throughout this section $f:\Omega\to\alpha$ and $g:\alpha\to\beta$ are arbitrary maps and $L:\Omega\to\Lambda$ is a labelling. The map $g\circ f$ is a *coarsening* of $f$. For $b$ in the image of $g\circ f$, the **fibre** of $b$ is the set $F_b=\{a\in f(\Omega):\ g(a)=b\}$ of $f$-values that $g$ merges into $b$.

### 3.1 Pure merging loses nothing

**Lemma 3.1 (Pure counts).** Fix $a\in\alpha$. Suppose there is a label $l_0$ such that $f(x)=a$ implies $L(x)=l_0$. Then for every label $l$, either $c_{(L,f)}(l,a)=0$ or $c_{(L,f)}(l,a)=c_f(a)$. Hence $\psi\big(c_{(L,f)}(l,a),c_f(a)\big)=0$ for every $l$.

*Proof.* If $l=l_0$, then every individual with $f(x)=a$ has label $l$, so the two counts agree. If $l\neq l_0$, no individual with $f(x)=a$ has label $l$. In both cases $\psi$ vanishes, because $\psi(0,C)=\psi(C,C)=0$. $\square$

**Theorem 3.2 (Pure-merging lemma).** Suppose that for all $x,y\in\Omega$,
$$g(f(x))=g(f(y))\quad\Longrightarrow\quad f(x)=f(y)\ \text{ or }\ L(x)=L(y).$$
Then $H(L\mid g\circ f)=H(L\mid f)$.

*Proof sketch.* Group the sum for $H(L\mid f)$ according to the fibres of $g$:
$$H(L\mid f)=\sum_{b}\ \sum_{a\in F_b}\ \sum_{l}\psi\big(c_{(L,f)}(l,a),c_f(a)\big).$$
Compare this, fibre by fibre, with the $b$-term $\sum_l\psi(c_{(L,g\circ f)}(l,b),c_{g\circ f}(b))$ of $H(L\mid g\circ f)$.

*Unsplit fibres.* If $F_b=\{a\}$ is a single point, then $c_{g\circ f}(b)=c_f(a)$ and $c_{(L,g\circ f)}(l,b)=c_{(L,f)}(l,a)$, so the two contributions are identical.

*Split fibres.* Suppose $F_b$ contains two distinct values, say $f(x_0)\neq f(y)$ with $g(f(x_0))=g(f(y))=b$. The hypothesis gives $L(x_0)=L(y)$. We claim $L$ is constant, equal to $L(x_0)$, on all of $(g\circ f)^{-1}(b)$. Let $u$ be in this set. If $f(u)\ne f(x_0)$, the hypothesis applied to $u,x_0$ gives $L(u)=L(x_0)$. If $f(u)=f(x_0)$, then $f(u)\neq f(y)$, and the hypothesis applied to $u,y$ gives $L(u)=L(y)=L(x_0)$. By Lemma 3.1, applied once to $f$ for each $a\in F_b$ and once to $g\circ f$ at $b$, every $\psi$-term on both sides is $0$. $\square$

Theorem 3.2 is the equality case of data processing. Merging values of a statistic costs nothing as long as the label is already constant on every block that is actually merged.

### 3.2 A two-to-one coarsening costs at most one bit

**Lemma 3.3 (Fibrewise log-sum).** Let $t$ be a finite index set and $c:t\to\mathbb{N}$, with $C=\sum_{i\in t}c_i$. Then
$$\sum_{i\in t}\psi(c_i,C)\;\le\;\frac{C}{n}\,\log|t|.$$

*Proof sketch.* Expanding, $\sum_i\psi(c_i,C)=\frac1n\big(C\log C-\sum_ic_i\log c_i\big)$. The log-sum inequality $\sum_i c_i\log\frac{c_i}{1}\ge C\log\frac{C}{|t|}$ rearranges to $C\log C-\sum_ic_i\log c_i\le C\log|t|$. $\square$

**Theorem 3.4 (Two-to-one lemma).** If every fibre satisfies $|F_b|\le 2$, then
$$H(f)-H(g\circ f)\;\le\;\log 2 .$$

*Proof sketch.* Write $H(f)=\sum_b\sum_{a\in F_b}\phi(c_f(a))$ and $H(g\circ f)=\sum_b\phi\big(\sum_{a\in F_b}c_f(a)\big)$. For each fibre, the identity $\sum_{a\in F_b}\phi(c_a)-\phi(C_b)=\sum_{a\in F_b}\psi(c_a,C_b)$, where $C_b=\sum_{a\in F_b}c_a$, together with Lemma 3.3, bounds the $b$-term by $\frac{C_b}{n}\log|F_b|\le\frac{C_b}{n}\log 2$. Summing over $b$ and using $\sum_bC_b=n$ gives the result. $\square$

**Theorem 3.5 (Refined two-to-one lemma).** Suppose $|F_b|\le2$ for every $b$. Let $S\subseteq\Omega$ contain every individual $x$ for which some $y$ satisfies $g(f(y))=g(f(x))$ and $f(y)\ne f(x)$, that is, every individual lying in a split fibre. Then
$$H(f)-H(g\circ f)\;\le\;\frac{|S|}{n}\,\log2 .$$

*Proof sketch.* In the proof of Theorem 3.4, unsplit fibres ($|F_b|=1$) contribute $\frac{C_b}{n}\log 1=0$. A split fibre contributes at most $\frac{C_b}{n}\log 2$, and all $C_b$ of its individuals lie in $S$. Summing gives at most $\frac{|S|}{n}\log 2$. $\square$

### 3.3 Release of conditional entropy

**Theorem 3.6.** For any $L,f,g$,
$$H(L\mid g\circ f)-H(L\mid f)\;\le\;H(f)-H(g\circ f).$$

*Proof.* The pair $(L,g\circ f)$ is the image of $(L,f)$ under $(l,a)\mapsto(l,g(a))$, so by data processing $H(L,g\circ f)\le H(L,f)$. Substitute this into $H(L\mid h)=H(L,h)-H(h)$ for $h=g\circ f$ and $h=f$. $\square$

In words, coarsening a statistic cannot increase the uncertainty about a label by more than the entropy that the coarsening destroys.

---

## 4. Geometry of the cover and the decomposition

### 4.1 The double cover

**Proposition 4.1 (Cover geometry).** Let $R$ be a commutative ring.

1. $\sigma$ is an involution and $\pi\circ\sigma=\pi$.
2. If $R$ is an integral domain, then $\pi(v)=\pi(w)$ if and only if $w=v$ or $w=\sigma(v)$. The fibres of the cover are exactly the branch-swap orbits.
3. If $2$ is invertible, then $\sigma(v)=v$ if and only if $v_2=0$. The ramification locus is $d=0$, the discriminant locus $s^2=4N$.
4. If $2$ is invertible, then $\mathrm{prod}=\kappa\circ\pi$. In particular $\mathrm{prod}\circ\sigma=\mathrm{prod}$, i.e. $\mathrm{prod}(s,-d)=\mathrm{prod}(s,d)$.
5. If $2$ is invertible, then $\pi(v)=\pi(w)$ if and only if $v_1=w_1$ and $\mathrm{prod}(v)=\mathrm{prod}(w)$.

*Proof sketch.* (1) and (4) are direct computations. For (2): $d^2=d'^2$ means $(d-d')(d+d')=0$, which in a domain forces $d'=\pm d$. For (3): $-d=d$ gives $2d=0$, and multiplying by $2^{-1}$ gives $d=0$. For (5): given $s=s'$, the equation $\tfrac14(s^2-d^2)=\tfrac14(s^2-d'^2)$ is equivalent to $d^2=d'^2$, because $4$ is invertible. $\square$

Part (5) says that, at the level of the base of the cover, $e=d^2$ is determined by $(s,N)$ through $e=s^2-4N$.

### 4.2 The branch swap on a population

**Proposition 4.2.**

1. Exchanging the factors acts on the residue view by the branch swap: the residue view of $(Q,P)$ is $\sigma\circ\rho$. Hence the branch view is symmetric, $\beta_{Q,P}=\beta_{P,Q}$.
2. If $\tau$ realises the branch swap, then $\rho(\tau x)=\sigma(\rho(x))$ and $\beta(\tau x)=\beta(x)$. If $L$ is swap-invariant, then $L(\tau x)=L(x)$.
3. **(Vieta reading.)** If $R$ is a domain with $2$ invertible, then $\beta(x)=\beta(y)$ if and only if $(P(x),Q(x))=(P(y),Q(y))$ or $(P(x),Q(x))=(Q(y),P(y))$. In other words, the branch view records exactly the unordered factor pair.
4. If $2$ is invertible, then $\beta(x)=\beta(y)$ if and only if $(s(x),N(x))=(s(y),N(y))$, and $N=\kappa\circ\beta$.

*Proof sketch.* (1) and (2) follow from $s$ being symmetric and $d$ antisymmetric in $(P,Q)$. (3) combines Proposition 4.1(2) with $P=(s-d)/2$ and $Q=(s+d)/2$. (4) is Proposition 4.1(5) together with (4). $\square$

**Theorem 4.3 (Swap-invariant labels factor through the cover).** Let $R$ be an integral domain.

1. If $L$ is swap-invariant and $\beta(x)=\beta(y)$, then $\rho(x)=\rho(y)$ or $L(x)=L(y)$.
2. Suppose $L$ is *residue-measurable*, i.e. $\rho(x)=\rho(y)\Rightarrow L(x)=L(y)$. Then $L$ is swap-invariant if and only if $\beta(x)=\beta(y)\Rightarrow L(x)=L(y)$. In that case there is a function $g:R\times R\to\Lambda$ with $L=g\circ\beta$.

*Proof sketch.* (1) By Proposition 4.1(2), $\beta(x)=\beta(y)$ means $\rho(y)=\rho(x)$ or $\rho(y)=\sigma(\rho(x))$. In the second case swap invariance gives $L(x)=L(y)$. (2) The forward direction is (1) combined with residue-measurability. Conversely, if $s(x)=s(y)$ and $d(y)=-d(x)$, then $\beta(x)=\beta(y)$. The function $g$ is defined on the image of $\beta$ by choosing a preimage, and arbitrarily elsewhere. $\square$

### 4.3 The decomposition

**Theorem 4.4 (Double Cover Decomposition).** For every battery and labelling,
$$\mathrm{HV}(L;P,Q)\;=\;B(L;P,Q)+C(L;P,Q),$$
and $B\ge0$. If $2$ is invertible in $R$, then also $C\ge0$, and (for $\Omega\ne\varnothing$)
$$C(L;P,Q)\;=\;I_2\big(L;(s,N)\big)-I_2(L;N).$$

*Proof sketch.* The identity is a telescoping sum. $B\ge0$ is data processing for $\beta=\pi\circ\rho$. When $2$ is invertible, $N=\kappa\circ\beta$ by Proposition 4.2(4), so data processing gives $C\ge0$. The views $\beta$ and $(s,N)$ induce the same partition of $\Omega$ by Proposition 4.2(4), and entropy depends only on the partition, so $I_2(L;\beta)=I_2(L;(s,N))$. $\square$

The two summands answer two different questions:

* $B$ is what the **order** of the factors adds to the **unordered** factor pair;
* $C$ is what the **sum** adds to the **product**.

**Theorem 4.5 (Corrected ramification theorem).** Let $R$ be an integral domain and $L$ swap-invariant. Then $B(L;P,Q)=0$, and therefore
$$\mathrm{HV}(L;P,Q)\;=\;C(L;P,Q).$$
If moreover $2$ is invertible and $\Omega\neq\varnothing$, then
$$\mathrm{HV}(L;P,Q)\;=\;I_2\big(L;(s,N)\big)-I_2(L;N).$$

*Proof.* Apply the pure-merging lemma (Theorem 3.2) with $f=\rho$ and $g=\pi$. Its hypothesis is exactly Theorem 4.3(1). So $H(L\mid\beta)=H(L\mid\rho)$, hence $I(L;\beta)=I(L;\rho)$ and $B=0$. The remaining statements follow from Theorem 4.4. $\square$

---

## 5. The one-bit law and the ramification locus

**Theorem 5.1 (One-bit law).** Let $R$ be an integral domain. For every battery and labelling, $B(L;P,Q)\le 1$. Consequently $\mathrm{HV}\le 1+C$.

*Proof sketch.* By Proposition 4.1(2), each fibre of $\pi$ meets the image $\rho(\Omega)$ in at most two points. Using $I(L;h)=H(L)-H(L\mid h)$,
$$B\cdot\log 2\;=\;H(L\mid\beta)-H(L\mid\rho)\;\le\;H(\rho)-H(\beta)\;\le\;\log2,$$
by Theorem 3.6 and then Theorem 3.4. $\square$

**Theorem 5.2 (Split-fraction bound).** Let $R$ be an integral domain with $2$ invertible. Let $S\subseteq\Omega$ contain every individual $x$ with $d(x)\neq0$ for which some $y\in\Omega$ satisfies $\rho(y)=\sigma(\rho(x))$, i.e. every individual off the ramification locus whose mirror point is occupied. Then
$$B(L;P,Q)\;\le\;\frac{|S|}{|\Omega|}.$$

*Proof sketch.* Apply Theorem 3.5 with $f=\rho$ and $g=\pi$. If $\pi(\rho(y))=\pi(\rho(x))$ and $\rho(y)\neq\rho(x)$, then Proposition 4.1(2) gives $\rho(y)=\sigma(\rho(x))\neq\rho(x)$. Then $d(x)\neq0$ by Proposition 4.1(3), so $x\in S$. Combine with Theorem 3.6 as in Theorem 5.1. $\square$

**Corollary 5.3.** Let $R$ be an integral domain with $2$ invertible.

1. *(Mirror-free batteries.)* If no individual off $d=0$ has its mirror occupied, then $B=0$ for every labelling.
2. *(Ramified batteries.)* If $d(x)=0$ for all $x$, then $\mathrm{HV}=C$ for every labelling.
3. *(The ramified hint value is conic.)* $\mathrm{HV}_0(L;P,Q)$ equals the conic value of the restricted battery on $\Omega_0$.

*Proof.* Take $S=\varnothing$ in Theorem 5.2 for (1). For (2), every individual is on $d=0$, so the battery is mirror-free. Part (3) is (2) applied to the restriction. $\square$

The ramification locus is therefore exactly where the cover loses **no** information. On $d=0$ one has $s^2=4N$, so given $N$ the sum is determined up to sign. The ramified hint value records only the information in the sign of $s$, and that information is conic.

---

## 6. The counterexample and sharpness

The following batteries all live over $R=\mathbb{Z}/5$ with two individuals, $\Omega=\{0,1\}$, and labels $L=(0,1)$. For a two-point population, a view that separates the two points has mutual information exactly $1$ bit with a separating label, and a view that is constant has mutual information $0$.

**Theorem 6.1 (The Ramification Conjecture is false).** Let $(P,Q)=\big((1,2),(3,4)\big)$ and $L=(0,1)$ over $\mathbb{Z}/5$. Then

* $L$ is swap-invariant;
* no individual lies on $d=0$, so $\mathrm{HV}_0=0$;
* $\mathrm{HV}=1$.

*Proof.* The residue views are $\rho(0)=(3,1)$ and $\rho(1)=(7,1)=(2,1)$, and the products are $2$ and $12\equiv2$. The sums differ, so swap invariance is vacuous. Both gaps are $1\neq0$. The residue view separates the individuals, giving $I_2(L;\rho)=1$, and the product view is constant, giving $I_2(L;N)=0$. $\square$

In terms of the decomposition, $B=0$ (Theorem 4.5) and $C=1$. The sums $3$ and $2$ satisfy $3^2-4\cdot2=1=2^2-4\cdot2$, so both individuals lie on the same conic $s^2-d^2=8$, on different points that are not mirror images of each other. The bit lost to the product is conic information.

**Theorem 6.2 (Sharpness).** Over $\mathbb{Z}/5$ with $L=(0,1)$:

1. **(Pure branch.)** For $(P,Q)=\big((1,2),(2,1)\big)$, one has $B=1$, $C=0$, and $\mathrm{HV}=1$. So the one-bit law is attained.
2. **(Pure conic on the ramification locus.)** For $(P,Q)=\big((1,1),(4,4)\big)$, every individual has $d=0$, $L$ is swap-invariant, and $\mathrm{HV}=1$, $B=0$, $C=1$.

*Proof.* (1) $\rho=\big((3,1),(3,4)\big)$ are mirror images, so the residue view separates the individuals while $\beta=\big((3,1),(3,1)\big)$ and $N=(2,2)$ are constant. (2) $\rho=\big((2,0),(3,0)\big)$, $\beta=\big((2,0),(3,0)\big)$ separates, and $N=(1,16)=(1,1)$ is constant. The sums differ, so swap invariance is vacuous. $\square$

In example (2), $s\in\{2,3\}=\{2,-2\}$. The conic value is exactly the sign of $s$ above the ramification point $s^2=4$.

---

## 7. Algorithms

All quantities above are computable in time $O(n\log n)$ for a population of size $n$, or expected $O(n)$ with hashing, because each entropy is a function of the multiset of counts of a view.

**Algorithm 7.1 (Branch/conic decomposition).**
*Input:* residues $(P_i,Q_i)_{i\le n}$ in $\mathbb{Z}/q$ with $q$ odd, and labels $L_i$.
1. Compute $\rho_i=(P_i+Q_i,\ Q_i-P_i)$, $\beta_i=(s_i,d_i^2)$, and $N_i=P_iQ_i$.
2. For each view $V\in\{\rho,\beta,N\}$, count the occurrences of the values $V_i$ and of the pairs $(L_i,V_i)$, and compute $I_2(L;V)=H_2(L)+H_2(V)-H_2(L,V)$.
3. Return $\mathrm{HV}=I_2(L;\rho)-I_2(L;N)$, $B=I_2(L;\rho)-I_2(L;\beta)$, and $C=I_2(L;\beta)-I_2(L;N)$.

**Algorithm 7.2 (Swap-invariance test and symmetrisation).** Bucket the individuals by $\beta_i$. The labelling is swap-invariant for a residue-measurable $L$ if and only if every bucket is label-constant. This is the criterion of Theorem 4.3, in $O(n)$ expected time. Replacing each label by the label of a fixed representative of its bucket produces a swap-invariant labelling, which by Theorem 4.5 has $B=0$.

**Algorithm 7.3 (Split-fraction certificate).** Insert all $\rho_i$ into a hash set. Count the $i$ with $d_i\ne0$ and $(s_i,-d_i)$ present. Dividing by $n$ gives an a priori upper bound on $B$ that holds for *every* labelling (Theorem 5.2).

---

## 8. Numerical illustrations

We report calculations for the **uniform battery** over $\mathbb{Z}/q$, which has one individual for each of the $q^2$ pairs $(P,Q)$.

**Labels $L=d$.** For $q=3,5,7,11,13$ the branch value equals $(q-1)/q$, which is $0.6667,\ 0.8,\ 0.8571,\ 0.9091,\ 0.9231$ bits. This follows from the definitions. $I(L;\rho)=H(d)$ because $d$ is a coordinate of $\rho$. Given $\beta=(s,d^2)$, the label $d$ is determined when $d=0$ and is one of two equally likely values $\pm d$ otherwise, so $H_2(d\mid\beta)=(q-1)/q$. Hence $B=(q-1)/q$, and the split-fraction bound of Theorem 5.2 holds with equality, since exactly the fraction $(q-1)/q$ of individuals lies off $d=0$ and every such individual has its mirror present.

**Labels $L=s$.** These labels are swap-invariant, so $B=0$ and $\mathrm{HV}=C$. Numerically, $C\approx1.068,\ 1.621,\ 2.024,\ 2.599,\ 2.819$ bits for $q=3,5,7,11,13$. These values sit below $\log_2 q$ by roughly one bit, which agrees with the heuristic that $N$ given $s$ is close to two-to-one.

**Labels $L=\chi(d)$**, the quadratic character of the gap with $\chi(0)=0$. Since $\chi(-d)=\chi(-1)\chi(d)$, this labelling is swap-invariant exactly when $q\equiv1\pmod 4$, and then $B=0$. For $q\equiv 3\pmod4$ the computed branch value is $(q-1)/q$ for $q=3,7,11$.

**Fibre sizes.** Over $\mathbb{Z}/7$, the fibres of $\pi$ on $(\mathbb{Z}/7)^2$ have size $1$ exactly on $d=0$ and size $2$ elsewhere. The fibres of $(s,d)\mapsto N$, the conics $s^2-d^2=4N$, have sizes $6$ and $13$. This illustrates why the conic factor $\kappa$, not the cover, dominates the loss of information.

---

## 9. Discussion

**Why the conjecture failed.** The conjecture conflated two different things that happen at the point $N$: the ramification of the cover $\pi$, and the fibre of the product map. The product map is a composite of a degree-two cover and a conic projection whose fibres have about $q$ points. Swap invariance removes only the contribution of the first factor. The surplus that remains is the information in $s$ given $N$, which is the information about which root pair of $X^2-sX+N$ was drawn among all quadratics with the same constant term.

**What survives.** The hint value is not a ramification invariant. Its *branch component* nevertheless behaves like one. It is supported on the split, mirror-populated, unramified part of the cover, it vanishes identically on the ramification locus, and it is bounded by the degree of the cover in bits. The conic component carries the arithmetic: through $s^2-4N=d^2$ it is governed by how often $s^2-4N$ is a square, i.e. by character sums of the Legendre symbol.

**Generality.** The information calculus of Section 3 makes no assumption about $\pi$ beyond small fibres. Any coarsening that merges only along label-constant blocks loses nothing, and any coarsening with fibres of size at most $k$ loses at most $\log_2 k$ bits, charged only to split fibres. (The same log-sum argument with $\log|F_b|\le\log k$ proves the degree-$k$ version.)

---

## 10. Future directions

1. **Uniform-battery branch law.** For the uniform battery over $\mathbb{F}_q$ and $L=d$, the branch value is $(q-1)/q$ bits (Section 8). The natural extension is to determine which labellings achieve equality in the split-fraction bound, and to describe the branch value of general labellings on uniform batteries.
2. **Conic value as a character sum.** For the uniform battery and $L=s$, express $C=H(s,N)-H(N)$ in closed form through the counts $\#\{s:\chi(s^2-4N)=\pm1\}$. The numerics of Section 8 suggest $C=\log_2q-1+o(1)$.
3. **Higher-degree covers and Galois branch value.** The branch swap is the Galois group of $X^2-sX+N$. For $k$ factors the cover given by the elementary symmetric functions has group $S_k$. One expects the branch value to be at most $\log_2 k!$ bits, and $S_k$-invariant labels to have branch value zero. The pure-merging and two-to-one lemmas apply verbatim, and only the fibre bound $\le k!$ remains to be established.
4. **Branch value detects quadratic residuosity.** For $L=\chi(d)$, prove that $B=0$ if $q\equiv1\pmod4$ and $B=(q-1)/q$ if $q\equiv3\pmod4$, matching the computations in Section 8.

---

## 11. Conclusion

Passing from the factors to their product loses information in two distinct steps. The first step is a double cover. It forgets the order of the factors, costs at most one bit, and costs nothing on the ramification locus or for swap-invariant labels. The second step is a conic projection. It forgets the sum, and it can cost arbitrarily many bits as the modulus grows. The conjecture that the hint value of swap-invariant labels lives on the discriminant locus is false, and the reason is that it assigned the loss to the first step only. The correct statement, $\mathrm{HV}=B+C$ with each part controlled as above, separates the Galois-theoretic part of the loss from its arithmetic-geometric part.
