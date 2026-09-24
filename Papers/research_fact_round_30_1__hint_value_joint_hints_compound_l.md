# Hints Compound by One Orientation Bit per Field: Conditional Hint Synergy, the Quadratic Bottleneck, and the Legendre Symbol

**Aristotle**

*2026-09-24*

---

## Abstract

We study how much information about a secret label $T$ can be recovered from the *sum* $s = p+q$ and the *gap* $d = q-p$ of a pair of factor residues $(p,q)$, given that the *product* $N = pq$ is already known. We define the conditional hint value of each dial, $I(T;N,s)-I(T;N)$ and $I(T;N,d)-I(T;N)$. We define the joint hint value $I(T;s,d) - I(T;N)$ and the *hint synergy*, which is the joint value minus the two single-dial values.

We prove four groups of results. (i) Hint synergy has no sign: an explicit two-sample battery modulo $5$ has synergy exactly $-1$ bit, and an explicit four-sample battery modulo $7$ has synergy exactly $+1$ bit. (ii) **The One-Bit Law:** over residues modulo any odd prime, and for every population and every label alphabet, hint synergy is at most $1 - \max(\text{sum hint}, \text{gap hint}) \le 1$ bit. Synergy equals $1$ bit if and only if both single hints vanish and the joint value is one bit. (iii) **The Orientation-Bit-per-Field Law:** over any coefficient ring carrying a sign selector with $|F|$ values, synergy is at most $\log_2|F|$. Over a product of $k$ odd prime fields it is therefore at most $k$ bits, and a sixteen-sample battery over $\mathbb{Z}/7 \times \mathbb{Z}/7$ attains $2$ bits exactly. (iv) **The Legendre Law:** a cell $(N,s)$ of a prime field with nonzero discriminant $\Delta = s^2-4N$ hosts two distinct factorisations, and hence one orientation bit, if and only if the Legendre symbol $\left(\frac{\Delta}{p}\right)$ equals $1$. Consequently, batteries whose hinted sum view already determines the gap, and in particular batteries of square factorisations, cannot compound. Conversely, any positive orientation gain requires a cell whose discriminant is a nonzero square.

As an application, we show that an empirically reported synergy of $+1.40$ bits on a two-prime (CRT) modulus is impossible over one prime field and realisable over two. The slogan "hints compound like capacities" should therefore be replaced by "hints compound by one orientation bit per field".

---

## 1. Introduction

Synergy is a well-known phenomenon in information theory. Two random variables $X, Y$ can each be independent of a target $T$ and still determine it jointly; the parity $T = X \oplus Y$ is the standard example. Conversely, two variables can each determine $T$, which makes them fully redundant. The *interaction information*

$$I(T;X,Y) - I(T;X) - I(T;Y)$$

is accordingly not sign-definite.

This paper looks at a structured instance that comes from factoring. A secret pair $(p, q)$ of residues in a ring $R$ is given, and the *product* $N = pq$ is public. Two "dials" can be revealed: the *sum* $s = p+q$ and the *gap* $d = q-p$. A label $T$ attached to each sample is the target. Examples of $T$ are which factor is which, a bit of $p$, or a class of the underlying integers.

A large-scale experiment with a 36-label battery over a two-prime modulus combined by the Chinese Remainder Theorem reported the following table of plug-in mutual informations with the label:

| view | bits |
|---|---|
| product view $N$ (hint-free) | 2.1314 |
| sum view alone | 0.6432 |
| gap view alone | 0.6496 |
| joint view $(s,d)$ | 4.5605 (about 99.1% of the label-entropy ceiling) |
| **joint hint value** $I(T;s,d)-I(T;N)$ | **+2.4291** |

The experiment set this joint hint value against a per-dial hint total of $+1.0288$ bits, and so reported a *hint synergy* of about $+1.40$ bits. It concluded that "hints compound like capacities", by analogy with an earlier observation of unbounded *capacity synergy* for CRT-joint moduli. The ordering

$$I(T;N) < I(T;s,d) \le H(T)$$

was confirmed.

We answer the underlying question exactly: **how far can hints compound?** The answer depends on how a hint is defined. Once a hint is measured as the *conditional* gain on top of the always-available product, the synergy is bounded by the number of sign patterns of the coefficient ring. That is one bit per prime field. The bound is attained, and the orientation bit it counts is a quadratic-residue phenomenon controlled by the Legendre symbol.

All numerical values in Sections 5 and 6 are exact rational numbers of bits obtained from fibre counts. The only floating-point figures in this paper are the experimental ones quoted above.

---

## 2. Definitions

### 2.1 Populations and plug-in information

Let $\Omega$ be a finite nonempty set, the *population*, carrying the uniform measure. A *statistic* is any function $f : \Omega \to \mathcal{A}$ into an arbitrary type. Its *fibres* are the sets $f^{-1}(a)$, and we write $\mathrm{cnt}_f(a) = |f^{-1}(a)|$. The empirical (plug-in) entropy of $f$ in bits is

$$H(f) = -\sum_{a} \frac{\mathrm{cnt}_f(a)}{|\Omega|}\log_2 \frac{\mathrm{cnt}_f(a)}{|\Omega|}.$$

For a label $T : \Omega \to \Lambda$ and a statistic $f$, the plug-in mutual information is

$$I(T;f) = H(T) + H(f) - H(T,f),$$

where $(T,f)$ is the paired statistic $x \mapsto (T(x),f(x))$. Pairs of statistics $(f,g)$ are statistics in their own right.

We will use the following standard facts:

* $0 \le I(T;f) \le H(T)$, and $I(T;f) = H(T)$ when $f$ determines $T$ (that is, $f(x)=f(y) \Rightarrow T(x)=T(y)$).
* **Fibre invariance.** If $f$ and $g$ have the same fibres ($f(x)=f(y) \iff g(x)=g(y)$), then $I(T;f)=I(T;g)$.
* **Monotonicity.** If $f$ refines $g$ ($f(x)=f(y)\Rightarrow g(x)=g(y)$), then $I(T;g)\le I(T;f)$.
* **Pairing bound.** $I(T;(f,g)) \le I(T;f) + H(g)$.
* **Cardinality bound.** If $g$ takes values in a finite set $F$, then $H(g) \le \log_2|F|$.

### 2.2 Batteries and views

Let $R$ be a commutative ring. A **battery** over $R$ consists of a population $\Omega$, a label $T : \Omega \to \Lambda$, and two *factor residues* $P, Q : \Omega \to R$. The four **views** are

* the **product view** $N(x) = P(x)Q(x)$,
* the **sum view** $s(x) = P(x)+Q(x)$,
* the **gap view** $d(x) = Q(x)-P(x)$,
* the **joint (residue) view** $x \mapsto (s(x), d(x))$.

If $2 \in R^\times$, the joint view has the same fibres as $(P,Q)$, since $P = (s-d)/2$ and $Q = (s+d)/2$. The product is then a function of the joint view, $N = (s^2 - d^2)/4$.

We also use the **hinted views** $x \mapsto (N(x), s(x))$ (hinted sum) and $x \mapsto (N(x), d(x))$ (hinted gap).

### 2.3 Hints and synergy

**Definition 2.1 (Conditional hints).** For a battery $(\Omega, T, P, Q)$,

$$\mathrm{sumHint} = I(T; N,s) - I(T;N), \qquad \mathrm{gapHint} = I(T;N,d) - I(T;N),$$

$$\mathrm{hintValue} = I(T;s,d) - I(T;N), \qquad \mathrm{synergy} = \mathrm{hintValue} - \mathrm{sumHint} - \mathrm{gapHint}.$$

A hint is a value *on top of* the hint-free channel $N$, which the solver always holds. Positive synergy means the hints compound, and negative synergy means they are redundant.

### 2.4 Sign selectors

**Definition 2.2 (Sign selector).** A sign selector for $R$ with values in a set $F$ is a map $\sigma : R \to F$ such that for all $a, b \in R$,

$$a^2 = b^2 \ \text{ and } \ \sigma(a) = \sigma(b) \ \Longrightarrow\ a = b.$$

A selector tells apart the square roots of every square. The number $|F|$ is an upper bound on the number of "sign patterns" of $R$.

**Lemma 2.3 (The lower-half selector).** Let $p$ be an odd prime, and for $a\in\mathbb{Z}/p$ let $\bar a\in\{0,\dots,p-1\}$ be its standard representative. Then $\sigma(a) = [\,2\bar a < p\,] \in \{\text{true},\text{false}\}$ is a sign selector for $\mathbb{Z}/p$ with values in a two-element set.

*Proof.* In a field, $a^2=b^2$ gives $(a-b)(a+b)=0$, so $a = b$ or $a = -b$. If $a=-b$ and $a\ne 0$, then $\overline{-a} = p-\bar a$. Because $p$ is odd, exactly one of $\bar a$ and $p-\bar a$ is less than $p/2$, so $\sigma(a)\ne\sigma(-a)$. Hence $\sigma(a) = \sigma(b)$ forces $a = b$. $\square$

**Lemma 2.4 (Selectors multiply).** If $\sigma_1 : R_1 \to F_1$ and $\sigma_2 : R_2 \to F_2$ are sign selectors, then $(a_1,a_2)\mapsto(\sigma_1(a_1),\sigma_2(a_2))$ is a sign selector for $R_1\times R_2$ with values in $F_1\times F_2$. More generally, a finite product $\prod_i R_i$ carries the product selector with values in $\prod_i F_i$.

*Proof.* Squares and equality in a product are checked componentwise. $\square$

It follows that $\prod_{i=1}^k \mathbb{Z}/p_i$, with the $p_i$ odd primes, carries a selector with values in $\{\text{true},\text{false}\}^k$, a set of size $2^k$. Selectors can fail to exist with few values. In $\mathbb{Z}/9$, the three elements $0,3,6$ all square to $0$, so any selector needs at least three values.

---

## 3. The basic order structure

**Proposition 3.1 (The routing table is a partial order).** For every battery over a ring with $2$ invertible,

$$0 \le \mathrm{sumHint} \le \mathrm{hintValue}, \qquad 0\le\mathrm{gapHint}\le\mathrm{hintValue},$$

and

$$-\min(\mathrm{sumHint},\mathrm{gapHint}) \le \mathrm{synergy}.$$

*Proof sketch.* The hinted views $(N,s)$ and $(N,d)$ refine $N$ (their first coordinate is $N$), which gives non-negativity by monotonicity. Since $2$ is invertible, $N$, $s$ and $d$ are all functions of $(s,d)$. So the joint view refines both hinted views, and monotonicity gives the upper bounds. For the lower bound on synergy, suppose $\mathrm{sumHint}\le\mathrm{gapHint}$. Then $\mathrm{synergy} = (\mathrm{hintValue} - \mathrm{gapHint}) - \mathrm{sumHint} \ge -\mathrm{sumHint}$, because $\mathrm{hintValue}\ge \mathrm{gapHint}$. The other case is symmetric. $\square$

**Proposition 3.2 (Degenerate boundary).** If the label is a function of the product ($N(x)=N(y)\Rightarrow T(x)=T(y)$), then every view reads $H(T)$, all hints vanish, and $\mathrm{synergy}=0$.

---

## 4. The quadratic bottleneck and the One-Bit Law

### 4.1 The refinement ceiling

**Lemma 4.1 (Refinement ceiling).** Let $f:\Omega\to\mathcal{A}$ and $g:\Omega\to\mathcal{B}$ be statistics, with $f$ refining $g$. Let $e : \mathcal{A}\to F$ take values in a finite set, and suppose $e\circ f$ separates the points of every $g$-fibre:

$$g(x)=g(y)\ \text{ and }\ e(f(x))=e(f(y)) \ \Longrightarrow\ f(x)=f(y).$$

Then for every label $T$,

$$I(T;f)\ \le\ I(T;g) + \log_2|F|.$$

In particular, if $F$ has two elements, $I(T;f)\le I(T;g)+1$.

*Proof.* The hypotheses say exactly that $f$ and the pair $(g, e\circ f)$ have the same fibres. By fibre invariance, the pairing bound and the cardinality bound,

$$I(T;f) = I(T; g, e\circ f) \le I(T;g) + H(e\circ f) \le I(T;g) + \log_2|F|. \qquad\square$$

### 4.2 The quadratic identity

**Lemma 4.2 (Given $N$ and one dial, the other is pinned up to sign).** In any commutative ring,

$$d^2 = s^2 - 4N \qquad\text{and}\qquad s^2 = d^2 + 4N.$$

Consequently, if two samples share the hinted sum view $(N,s)$, their gaps have equal squares. If they share the hinted gap view $(N,d)$, their sums have equal squares.

*Proof.* $(q-p)^2 = (p+q)^2 - 4pq$. $\square$

### 4.3 The One-Bit Law

**Theorem 4.3 ($\log_2|F|$ law).** Let $R$ be a commutative ring with $2\in R^\times$ and let $\sigma : R\to F$ be a sign selector. Then for every battery over $R$,

$$\mathrm{hintValue} \le \mathrm{sumHint} + \log_2|F|, \qquad \mathrm{hintValue}\le\mathrm{gapHint}+\log_2|F|,$$

and hence

$$\mathrm{synergy} \ \le\ \log_2|F| - \max(\mathrm{sumHint},\mathrm{gapHint})\ \le\ \log_2|F|.$$

*Proof.* Apply Lemma 4.1 with $f = (s,d)$, $g = (N,s)$ and $e(s,d) = \sigma(d)$. First, $f$ refines $g$ because $N = (s^2-d^2)/4$. Second, suppose $g(x) = g(y)$ and $\sigma(d(x)) = \sigma(d(y))$. By Lemma 4.2, $d(x)^2 = d(y)^2$, and the selector property gives $d(x)=d(y)$. Together with $s(x)=s(y)$ this gives $f(x)=f(y)$. So $I(T;s,d)\le I(T;N,s)+\log_2|F|$. Subtracting $I(T;N)$ from both sides gives the first inequality. The gap form is identical, with $e(s,d)=\sigma(s)$ and $s^2 = d^2+4N$.

For the synergy bound, suppose $\mathrm{sumHint}\le\mathrm{gapHint}$. Then $\mathrm{synergy} = (\mathrm{hintValue}-\mathrm{sumHint}) - \mathrm{gapHint} \le \log_2|F| - \mathrm{gapHint}$. The other case is symmetric. The last inequality uses $\mathrm{sumHint},\mathrm{gapHint}\ge0$. $\square$

**Corollary 4.4 (The One-Bit Law).** Let $p$ be an odd prime. For every finite nonempty population, every label alphabet, and all factor residues $P,Q:\Omega\to\mathbb{Z}/p$,

$$\mathrm{synergy}\ \le\ 1-\max(\mathrm{sumHint},\mathrm{gapHint})\ \le\ 1 .$$

In particular, no battery over a single odd prime field has conditional hint synergy greater than one bit.

*Proof.* $2$ is invertible modulo an odd prime. Apply Theorem 4.3 with the lower-half selector of Lemma 2.3, for which $|F| = 2$. $\square$

**Corollary 4.5 (All-or-nothing law).** Under the hypotheses of Theorem 4.3 with $|F|=2$,

$$\mathrm{synergy}=1 \iff \mathrm{sumHint}=0,\ \mathrm{gapHint}=0,\ \mathrm{hintValue}=1.$$

*Proof.* If $\mathrm{synergy}=1$, then $1 \le 1-\max(\mathrm{sumHint},\mathrm{gapHint})$ forces both hints, which are non-negative, to be $0$, and then $\mathrm{hintValue}=1$. The converse is arithmetic. $\square$

Maximal compounding therefore needs two individually *worthless* hints. Two individually valuable hints never compound to the ceiling.

### 4.4 The Orientation-Bit-per-Field Law

**Theorem 4.6 ($k$ fields, $k$ bits).** Let $p_1,\dots,p_k$ be odd primes (not necessarily distinct) and $R = \prod_{i=1}^k\mathbb{Z}/p_i$. For every battery over $R$,

$$\mathrm{synergy}\ \le\ k.$$

*Proof.* $2$ is invertible in each factor, hence in $R$. By Lemmas 2.3 and 2.4, $R$ carries a selector with $2^k$ values. Apply Theorem 4.3: $\log_2 2^k = k$. $\square$

By the Chinese Remainder Theorem, $\mathbb{Z}/(p_1p_2) \cong \mathbb{Z}/p_1\times\mathbb{Z}/p_2$ for distinct odd primes, so a two-prime CRT modulus falls under the case $k=2$.

---

## 5. Sharpness: explicit batteries

### 5.1 A redundant battery (synergy $-1$)

Modulo $5$, take $\Omega=\{x_0,x_1\}$ with

$$(P,Q)(x_0) = (1,1),\quad (P,Q)(x_1) = (2,3),\quad T(x_0)=0,\ T(x_1)=1.$$

Both samples have $N\equiv 1$, so $I(T;N)=0$. The sums are $2, 0$ and the gaps are $0, 1$. Each of $(N,s)$, $(N,d)$ and $(s,d)$ separates the two samples, and hence determines $T$, which has $H(T)=1$. Therefore

$$\mathrm{sumHint}=\mathrm{gapHint}=\mathrm{hintValue}=1,\qquad\mathrm{synergy}=-1.$$

The lower bound of Proposition 3.1 is attained.

### 5.2 A compounding battery (synergy $+1$)

Modulo $7$, take four samples on the hyperbola $pq\equiv1$:

| sample | $(p,q)$ | $T$ | $N$ | $s$ | $d$ |
|---|---|---|---|---|---|
| $x_0$ | $(2,4)$ | 0 | 1 | 6 | 2 |
| $x_1$ | $(4,2)$ | 1 | 1 | 6 | 5 |
| $x_2$ | $(3,5)$ | 1 | 1 | 1 | 2 |
| $x_3$ | $(5,3)$ | 0 | 1 | 1 | 5 |

The label is the exclusive-or of "which sum class" and "which gap class". Equivalently, it is the *orientation* of the factor pair within its cell. We have $H(T)=1$ and $I(T;N)=0$ since $N$ is constant. Every fibre of $(N,s)$, namely $\{x_0,x_1\}$ and $\{x_2,x_3\}$, and every fibre of $(N,d)$, namely $\{x_0,x_2\}$ and $\{x_1,x_3\}$, contains one sample of each label. So $I(T;N,s)=I(T;N,d)=0$ exactly. The joint view separates all four samples, so $I(T;s,d)=1$. Hence

$$\mathrm{sumHint}=\mathrm{gapHint}=0,\qquad\mathrm{hintValue}=1,\qquad\mathrm{synergy}=+1.$$

**Theorem 5.1 (Hint synergy has no sign; the one-bit ceiling is sharp).** There is a battery over $\mathbb{Z}/5$ with synergy $-1$ and a battery over $\mathbb{Z}/7$ with synergy $+1$. Consequently, neither superadditivity nor subadditivity of conditional hints holds in general, and the bound of Corollary 4.4 cannot be improved.

### 5.3 A two-field battery (synergy $+2$)

Over $\mathbb{Z}/7\times\mathbb{Z}/7$, take the sixteen samples of the product of two copies of the battery in §5.2. Sample $(i,j)$ has factor residues $\big((p_i,p_j),(q_i,q_j)\big)$ and label $T = 2T_i + T_j\in\{0,1,2,3\}$, the pair of orientation bits. Explicit fibre counts show:

* every label class has $4$ samples, so $H(T)=2$;
* $N=(1,1)$ is constant, so $I(T;N)=0$;
* every fibre of $(N,s)$ and of $(N,d)$ has $4$ samples, one of each label, so $I(T;N,s)=I(T;N,d)=0$;
* $(s,d)$ separates all samples, so $I(T;s,d)=2$.

**Theorem 5.2 (The two-field ceiling is attained).** There is a battery over $\mathbb{Z}/7\times\mathbb{Z}/7$ with $\mathrm{sumHint}=\mathrm{gapHint}=0$, $\mathrm{hintValue}=2$ and $\mathrm{synergy}=2$.

### 5.4 The verdict on $+1.40$ bits

**Corollary 5.3.** A conditional hint synergy of $1.4$ bits is impossible over any single odd prime field and is realised (indeed exceeded) over $\mathbb{Z}/7\times\mathbb{Z}/7$.

*Proof.* Corollary 4.4 and Theorem 5.2. $\square$

The empirical $+1.40$ bits was measured on a two-prime modulus, so it is consistent with Theorem 4.6. It is *not* evidence of unbounded compounding: the ceiling scales with the number of prime fields, not with label entropy or population size. We also note a limitation. The experimental "per-dial" rows need not coincide with the conditional hints of Definition 2.1, and they are plug-in estimates. The theorems above constrain the conditional quantities exactly, whatever estimator is used for the experimental ones.

---

## 6. The orientation bit is a quadratic residue

The proof of Theorem 4.3 shows that the joint view refines the hinted sum view only by a *choice of square root of* $d^2 = s^2-4N$. We now identify exactly where that choice is non-trivial.

### 6.1 Cells and discriminants

**Definition 6.1.** A *cell* is a pair $(n,\sigma)\in R^2$, a product value and a sum value. Its *discriminant* is $\Delta = \sigma^2-4n$. A *factorisation* of the cell is an element $a\in R$ with $a(\sigma-a)=n$, which corresponds to the ordered pair $(a,\sigma-a)$.

**Lemma 6.2 (Change of variable).** Let $K$ be a field with $2\ne0$. For all $n,\sigma,a\in K$,

$$a(\sigma-a) = n \iff (2a-\sigma)^2 = \sigma^2-4n.$$

*Proof.* The identity $(2a-\sigma)^2 - (\sigma^2-4n) = -4\,(a(\sigma-a)-n)$ holds in any commutative ring, and $4 = 2\cdot 2 \neq 0$. $\square$

**Theorem 6.3 (Two factorisations iff a nonzero square root).** Let $K$ be a field with $2\ne0$ and $n,\sigma\in K$. The following are equivalent:

1. the cell $(n,\sigma)$ has two distinct factorisations $a\ne b$;
2. there is $t\ne0$ with $t^2=\sigma^2-4n$.

If moreover $\Delta = \sigma^2-4n\ne0$, both are equivalent to

3. $\Delta$ is a square in $K$.

*Proof.* (1 ⇒ 2) Put $t = 2a-\sigma$. By Lemma 6.2, $t^2 = \Delta$. If $t = 0$, then $\Delta = 0$ and also $(2b-\sigma)^2 = 0$, so $2b = \sigma = 2a$, and cancelling $2$ gives $a=b$, a contradiction. (2 ⇒ 1) Take $a = (\sigma+t)/2$ and $b=(\sigma-t)/2$. Lemma 6.2 shows both are factorisations, and $a-b = t\ne0$. (2 ⇔ 3 when $\Delta\ne0$) A square root of a nonzero element is nonzero. $\square$

The same computation shows that a cell with $\Delta=0$ has exactly one factorisation, $a=\sigma/2$, which is a square pair $p=q$. A cell whose $\Delta$ is a non-square has none. Over a field, the factorisations of a cell are in bijection with the square roots of its discriminant.

### 6.2 The Legendre form

For an odd prime $p$ and $a\in\mathbb{Z}$, the Legendre symbol $\left(\frac ap\right)$ is $0$ if $p\mid a$, $+1$ if $a$ is a nonzero square mod $p$, and $-1$ otherwise. Euler's criterion gives $\left(\frac ap\right)\equiv a^{(p-1)/2}\pmod p$.

**Theorem 6.4 (Legendre Law for Orientation).** Let $p$ be an odd prime and $n,\sigma\in\mathbb{Z}/p$ with $\Delta=\sigma^2-4n\ne0$. Then the cell $(n,\sigma)$ hosts two distinct factorisations, and hence an orientation bit, if and only if

$$\left(\frac{\Delta}{p}\right) = 1 .$$

*Proof.* $2\neq 0$ in $\mathbb{Z}/p$. Apply Theorem 6.3 together with the characterisation of the Legendre symbol: for $\Delta\not\equiv0$, $\left(\frac\Delta p\right)=1$ if and only if $\Delta$ is a square. $\square$

In every case the number of factorisations of the cell is $1+\left(\frac{\sigma^2-4n}{p}\right)$.

**Examples (modulo $7$).** The cell $(N,s)=(1,6)$ of the battery in §5.2 has $\Delta = 36-4 = 32\equiv 4 = 2^2$, a nonzero residue. It hosts exactly the two pairs $(2,4)$ and $(4,2)$, whose orientation is the label. The cell $(1,0)$ has $\Delta\equiv -4\equiv 3$. Since the squares mod $7$ are $\{0,1,2,4\}$, $3$ is a non-residue ($\left(\frac37\right)=-1$), and the cell has no factorisation: $a(0-a)=1$ is unsolvable.

**Remark 6.5 (Cell census).** For fixed $\sigma$, the map $n\mapsto\sigma^2-4n$ is a bijection of $\mathbb{Z}/p$. So each column $\sigma$ contains exactly $(p-1)/2$ residue cells, one zero cell and $(p-1)/2$ non-residue cells. Of the $p^2$ cells, $p(p-1)/2$ carry an orientation bit. For $p=7$ this gives $21$ residue cells, $7$ zero cells and $21$ non-residue cells. This counts *cells*. How a given battery's *population* is distributed over residue cells is a separate question (Section 8).

### 6.3 Information consequences

**Theorem 6.6 (No orientation, no compounding).** Let $R$ be a commutative ring with $2\in R^\times$, and consider a battery in which the hinted sum view determines the gap: $(N,s)(x)=(N,s)(y)\Rightarrow d(x)=d(y)$. Then

$$\mathrm{hintValue}=\mathrm{sumHint}\qquad\text{and}\qquad\mathrm{synergy}=-\mathrm{gapHint}\le0.$$

*Proof.* Under the hypothesis, $(s,d)$ and $(N,s)$ have the same fibres. One direction is refinement, since $N$ is a function of $(s,d)$. The other is the hypothesis together with $s$ being a coordinate of $(N,s)$. Fibre invariance gives $I(T;s,d)=I(T;N,s)$. $\square$

**Corollary 6.7 (Square factorisations cannot compound).** If $P(x)=Q(x)$ for every sample, then $\mathrm{synergy}\le0$.

*Proof.* The gap vanishes identically, so it is trivially determined by $(N,s)$. $\square$

**Theorem 6.8 (Positive orientation gain needs a residue cell).** If $\mathrm{sumHint}<\mathrm{hintValue}$, then some sample $x$ has $d(x)\ne0$. Its cell $(N(x),s(x))$ then has discriminant $s(x)^2-4N(x) = d(x)^2$, which is a nonzero square.

*Proof.* If every gap vanished, Theorem 6.6 would give $\mathrm{hintValue}=\mathrm{sumHint}$. The discriminant identity is Lemma 4.2. $\square$

Over a prime field, the positive part of the synergy is therefore supported on residue cells of the Legendre law. Non-residue cells host no samples at all, and zero-discriminant cells host only square pairs, which carry no orientation.

---

## 7. Algorithms

**Algorithm A (Exact routing table).** *Input:* a battery $(T_x, p_x, q_x)_{x\in\Omega}$ over $\prod_i\mathbb{Z}/m_i$.

1. For each $x$ compute $N_x=p_xq_x$, $s_x=p_x+q_x$ and $d_x=q_x-p_x$ componentwise.
2. Build the count tables of $T$, $N$, $(N,s)$, $(N,d)$, $(s,d)$ and of each paired with $T$.
3. Compute $H(\cdot)=\log_2|\Omega|-\frac1{|\Omega|}\sum_a \mathrm{cnt}(a)\log_2\mathrm{cnt}(a)$ and $I(T;V)=H(T)+H(V)-H(T,V)$.
4. Return sumHint, gapHint, hintValue and synergy.

With hashing this takes $O(|\Omega|)$ time and space. Because entropies are $\log_2$ of ratios of integer counts, the table is exact whenever the counts are uniform on fibres, as they are in all batteries of Section 5.

**Algorithm B (Orientation-cell classification).** *Input:* odd prime $p$ and a cell $(n,\sigma)$.

1. $\Delta\leftarrow\sigma^2-4n \bmod p$.
2. If $\Delta=0$, return "one factorisation $(\sigma/2,\sigma/2)$; no bit".
3. $\chi\leftarrow\Delta^{(p-1)/2}\bmod p$.
4. If $\chi=1$, find $t$ with $t^2=\Delta$ (for instance by Tonelli–Shanks) and return the two factorisations $((\sigma\pm t)/2,(\sigma\mp t)/2)$ and "one orientation bit". Otherwise return "no factorisation".

Step 3 costs $O(\log p)$ multiplications and step 4 costs expected $O(\log^2 p)$.

**Algorithm C (Selector-based certificate).** To certify $\mathrm{hintValue}\le\mathrm{sumHint}+k$ over $\prod_{i=1}^k\mathbb{Z}/p_i$, append to the hinted sum view the $k$ lower-half bits $[2\bar d_i<p_i]$ of the gap. Then check that the augmented view has the same fibres as $(s,d)$. That check is Lemma 4.1 applied constructively.

---

## 8. Discussion

**Hints versus capacities.** The analogy behind "hints compound like capacities" is that in both cases a CRT-joint statistic sees all residues at once. The exact analysis separates the two. Capacity synergy, the unconditional interaction information of residue views, is bounded only by label entropy. Conditional hint synergy is bounded by the size of the sign group $\{\pm1\}^k$ of the modulus. The difference comes from the quadratic identity $d^2 = s^2-4N$: once $N$ is known, the two dials are *algebraically coupled*, and their joint surplus over either one is a single square-root choice per field.

**Relation to factoring.** Over the integers, $N$ together with $s$ recovers $\{p,q\}$ through the quadratic formula; this is Fermat's representation $N = \left(\frac{s}{2}\right)^2-\left(\frac d2\right)^2$. The results here are the residue analogue. Modulo primes, $(N,s)$ fixes the unordered pair, and the *ordered* pair costs exactly one extra bit per field, available precisely on residue cells.

**The flagged which-factor statistic.** The experiment also reported a "which-factor" statistic of $0.9663$ bits in the $(s,d)$ view. It was estimated from about $508{,}000$ residue-pair cells with $30{,}000$ samples, which is the extreme sparse plug-in regime where mutual-information estimates are strongly biased upward. None of the results above depend on this figure, and we do not interpret it. We note a structural point: $s$ and $d^2$ are invariant under $p\leftrightarrow q$, so any genuine which-factor leakage would have to be orientation-conditional and would be significant in its own right. A permutation-null test is the appropriate next step.

**Limitations.** The upper bounds are theorems about the plug-in quantities of Definition 2.1 on arbitrary finite populations. They do not by themselves say which estimator the experiment used for its per-dial row. The selector hypothesis is essential. Over rings with nilpotents, such as $\mathbb{Z}/9$, square roots can have multiplicity above $2^{(\text{number of fields})}$ and the bound changes.

---

## 9. Future work

1. **Square-root multiplicity ceiling.** For a finite commutative ring $R$ with $2\in R^\times$, we conjecture that the supremum of conditional hint synergy equals $\log_2 m(R)$, where $m(R)=\max_e|\{d: d^2=e\}|$. For reduced rings $\prod_{i=1}^k\mathbb{F}_{q_i}$, $m=2^k$, which recovers Theorem 4.6. For $\mathbb{Z}/9$, $m=3$, and the prediction is $\log_2 3\approx1.585$ bits on a single prime-power modulus. The upper bound follows from Lemma 4.1 with $F$ the fibre of $d\mapsto d^2$. Attainment is open.
2. **Tensor batteries.** We conjecture that the $k$-fold product of the mod-$7$ battery ($4^k$ samples) has $\mathrm{sumHint}=\mathrm{gapHint}=0$ and $\mathrm{hintValue}=k$ for every $k$. The missing ingredient is additivity of plug-in entropy over product populations.
3. **Population-weighted density of orientation cells.** Remark 6.5 counts cells. The open problem is to control the fraction of a battery's *population* that sits over residue cells, for instance for residues of random semiprimes, and to relate that fraction to the attainable synergy, presumably through character-sum estimates.
4. **Permutation-null test** of the $0.9663$-bit which-factor statistic.

---

## 10. Conclusion

Conditional hints about a factor pair compound, but only in a strictly limited way. Over one odd prime field, the sum and gap dials together can exceed their separate conditional values by at most one bit, and exactly one bit is attainable. The maximum is reached only when both dials are individually worthless. Over $k$ fields the ceiling is $k$ bits, and it is attained for $k=2$. The bit being counted is the orientation of the factor pair, the sign of the square root in $d^2=s^2-4N$. It exists in a cell exactly when the cell's discriminant is a nonzero quadratic residue, that is, when the Legendre symbol $\left(\frac{s^2-4N}{p}\right)$ equals $1$.
