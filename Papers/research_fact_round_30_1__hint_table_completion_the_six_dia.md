# The Hint Is Universal Exactly at Odd Moduli: Two-Torsion Floors, Ceilings and the Independence of Capacity and Hint

**Author:** Aristotle

**Date:** 2026-09-25

---

## Abstract

Take a finite population of samples. Each sample carries a pair $(P,Q)$ of elements of a finite commutative ring $R$ and a label $T$. There are two natural ways to summarise the pair: by its product $N = PQ$, or by its sum and difference $(s,d) = (P+Q,\,P-Q)$. The *hint value* is the amount by which the sum/difference reading beats the product reading at predicting the label:

$$\mathrm{hint} = I\big(T;(s,d)\big) - I(T;N).$$

Here $I$ is empirical mutual information in bits. A six-dial experiment reported positive hint values at the moduli $11, 5, 31, 23, 8, 9$ and gave the verdict "the hint is universal". We determine exactly when this verdict holds. The main tool is a *two-torsion floor*. If some map into a finite set $F$ separates any two ring elements that have the same double, then $\mathrm{hint} \ge -\log_2|F|$. No invertibility of $2$ is needed. Consequences:

1. The hint is nonnegative in every ring without $2$-torsion, and in particular over $\mathbb{Z}/n$ for odd $n$.
2. Over $\mathbb{Z}/n$ with $n$ even, the hint is at least $-1$ bit, and $-1$ is attained at *every* even $n$ by a two-sample battery.
3. Every battery over $\mathbb{Z}/n$ has nonnegative hint **if and only if $n$ is odd**.
4. Over $\mathbb{Z}/2k \times \mathbb{Z}/2l$ the floor is $-2$ bits, attained over $\mathbb{Z}/8\times\mathbb{Z}/8$.

We also prove the ceiling $\mathrm{hint} \le 2\log_2 n$, the budget identity $I(T;N) + \mathrm{hint} = I(T;(s,d)) \le H(T)$, and the coupling floor $\mathrm{hint} \ge -I(T;N)$. Finally, we show that capacity and hint are functionally independent: over $\mathbb{Z}/5$ the pair (capacity, hint) attains all four points of $\{0,1\}^2$. Applied to the experimental table, five of the six dials have nonnegative hint by theorem. The sixth ($D_4$ at modulus $8$) lies in the proven window $[-\min(1, I(T;N)),\,6]$, which contains negative values that are actually attained.

---

## 1. Introduction

A recurring experimental design compares two summaries of the same data. In the setting studied here, each sample is a pair of residues $(P,Q)$ modulo $m$ with a label, and we compare:

- the **product reading** $N = PQ \bmod m$, whose informativeness about the label we call the **capacity**;
- the **sum/difference reading** $(s,d) = (P+Q,\;P-Q) \bmod m$.

Over a field of characteristic other than $2$, the map $(P,Q)\mapsto(s,d)$ is invertible, because $P = (s+d)/2$ and $Q = (s-d)/2$. The product is therefore a function of $(s,d)$. By the data-processing inequality, $(s,d)$ is at least as informative as $N$, so the hint value is nonnegative.

A six-dial experiment measured the following. Dials are named by a finite group and a modulus. Only the modulus enters the analysis below.

| dial | modulus $m$ | capacity $I(T;N)$ | hint value |
|---|---|---|---|
| $C_5$ | 11 | 1.2062 | +1.5896 |
| $F_{20}$ | 5 | 0.2920 | +0.9538 |
| $S_3$ (a) | 31 | 1.0011 | +0.5201 |
| $S_3$ (b) | 23 | 1.0008 | +0.5121 |
| $D_4$ | 8 | 1.9999 | +0.5032 |
| $A_4$ | 9 | 0.0015 | +0.0120 |

The total hint is $4.0908$ bits and the total capacity is $5.5015$ bits. The Pearson correlation between capacity and hint is $r \approx 0.256$. Two claims were drawn from this table: that the hint is universal, and that hint and capacity are independent properties of a dial.

This paper turns both claims into theorems and states exactly where each holds. The obstruction to universality is the $2$-torsion of the ring, meaning the elements $a$ with $2a = 0$. The size of the obstruction is measured by the number of values needed to break the resulting ambiguity.

**Organisation.** Section 2 fixes definitions and the information-theoretic toolkit. Section 3 proves the two-torsion floor. Section 4 specialises to cyclic rings and proves the odd/even dichotomy. Section 5 treats products of rings. Section 6 gives the ceiling and budget results. Section 7 proves functional independence of capacity and hint. Section 8 applies everything to the six-dial table. Section 9 describes algorithms, Section 10 discusses geometry, and Section 11 lists open problems.

---

## 2. Definitions and toolkit

### 2.1 Batteries and readings

**Definition 2.1 (Battery).** A *battery* over a commutative ring $R$ consists of:

- a finite nonempty set $\Omega$ of samples;
- a label map $T : \Omega \to \Lambda$ into an arbitrary set;
- two coordinate maps $P, Q : \Omega \to R$.

All probabilities refer to the uniform distribution on $\Omega$.

**Definition 2.2 (Readings).** A *reading* is any map $f : \Omega \to \mathcal{A}$. We use three:

- the *product reading* $N(x) = P(x)Q(x)$;
- the *residue* (sum/difference) reading $\rho(x) = \big(P(x)+Q(x),\ P(x)-Q(x)\big) \in R^2$;
- the *pair reading* $\pi(x) = (P(x), Q(x)) \in R^2$.

**Definition 2.3 (Entropy and information).** For a reading $f$, let $H(f)$ be the Shannon entropy in bits of the pushforward of the uniform distribution on $\Omega$. For two readings $f, g$ let $(f,g)$ denote the joint reading. The *mutual information* is

$$I(T;f) = H(T) + H(f) - H(T,f).$$

**Definition 2.4 (Capacity, hint value).** The *capacity* of a battery is $I(T;N)$. Its *hint value* is

$$\mathrm{hint}(T,P,Q) = I(T;\rho) - I(T;N).$$

### 2.2 Standard facts

We use the following standard properties of empirical entropy and mutual information. Here $f, g$ are readings and $\phi$ is any function.

- **(F1) Nonnegativity and label bound.** $0 \le I(T;f) \le H(T)$.
- **(F2) Statistic bound.** $I(T;f) \le H(f) \le \log_2 |\mathcal{A}|$ when $f$ takes values in a finite set $\mathcal{A}$.
- **(F3) Data processing.** $I(T;\phi\circ f) \le I(T;f)$.
- **(F4) Determination.** If $f$ determines $T$ (that is, $f(x)=f(y) \Rightarrow T(x)=T(y)$), then $I(T;f) = H(T)$. If $T$ determines $f$, then $I(T;f) = H(f)$.
- **(F5) Constant readings.** If $f$ is constant then $I(T;f) = 0$. This follows from (F3) by factoring through a one-point set, together with (F1) and (F2).

**Lemma 2.5 (Refinement bound).** Let $f, g$ be readings and let $e : \Omega \to F$ take values in a finite set $F$. Assume:

- $f$ determines $g$;
- the pair $(g,e)$ determines $f$.

Then
$$I(T;f) \le I(T;g) + \log_2|F|.$$

*Proof sketch.* Since $(g,e)$ determines $f$ and $f$ determines $g$, the readings $f$ and $(f,g)$ generate the same partition of $\Omega$. Using (F3) and the chain rule,

$$I(T;f) \le I(T;(g,e)) = I(T;g) + I(T;e \mid g) \le I(T;g) + H(e\mid g).$$

Finally $H(e \mid g) \le H(e) \le \log_2|F|$. $\square$

---

## 3. The two-torsion floor

**Definition 3.1 (Torsion selector).** Let $R$ be a commutative ring and $F$ a finite set. A *two-torsion selector* for $R$ with values in $F$ is a map $\sigma : R \to F$ with the following property: for all $a, b\in R$,

$$2a = 2b \ \text{ and } \ \sigma(a) = \sigma(b) \ \Longrightarrow\ a = b.$$

In words, $\sigma$ separates any two elements that have the same double. Two elements with the same double differ by an element of the $2$-torsion $R[2] = \{t : 2t = 0\}$. So a selector must be injective on each coset $a + R[2]$, which forces $|F| \ge |R[2]|$.

**Theorem 3.2 (Product-versus-residue bound).** For every battery over $R$ and every two-torsion selector $\sigma : R \to F$,

$$I(T;N) \le I(T;\rho) + \log_2 |F|.$$

*Proof.* Apply Lemma 2.5 with $f = \pi$ (the pair reading), $g = \rho$ and $e = \sigma\circ P$.

- The pair determines the residue pair.
- Conversely, suppose $\rho(x) = \rho(y)$ and $\sigma(P(x)) = \sigma(P(y))$. From $s$ and $d$ we get $2P(x) = s + d = 2P(y)$, and the selector then forces $P(x) = P(y)$. It follows that $Q(x) = s - P(x) = Q(y)$.

Hence $I(T;\pi) \le I(T;\rho) + \log_2|F|$. Since $N = \mu\circ\pi$ with $\mu(p,q) = pq$, data processing (F3) gives $I(T;N)\le I(T;\pi)$. $\square$

**Corollary 3.3 (Two-torsion floor).** Under the same hypotheses, $\mathrm{hint}(T,P,Q) \ge -\log_2 |F|$.

**Corollary 3.4 (Two-torsion-free rings).** Suppose $2a = 0$ implies $a = 0$ in $R$. Then every battery over $R$ has $\mathrm{hint} \ge 0$.

*Proof.* The constant map into a one-point set is a selector: $2a = 2b$ gives $2(a-b) = 0$, hence $a = b$. Since $\log_2 1 = 0$, Corollary 3.3 applies. $\square$

Corollary 3.4 does not require $2$ to be invertible. It covers $\mathbb{Z}$ as well as every $\mathbb{Z}/n$ with $n$ odd.

---

## 4. Cyclic moduli: the odd/even dichotomy

**Lemma 4.1.** If $n$ is odd, $\mathbb{Z}/n$ has no nonzero $2$-torsion.

*Proof.* When $\gcd(2,n)=1$, the element $2$ is a unit, so $2a = 0$ forces $a = 0$. $\square$

**Theorem 4.2 (Universal floor at odd moduli).** For odd $n$, every battery over $\mathbb{Z}/n$ has nonnegative hint value.

*Proof.* Combine Lemma 4.1 with Corollary 3.4. $\square$

**Definition 4.3 (Half-range selector).** For $k\ge1$ define $\eta : \mathbb{Z}/2k \to \{\mathrm{true},\mathrm{false}\}$ by $\eta(a) = [\,\bar a < k\,]$, where $\bar a\in\{0,\dots,2k-1\}$ is the least nonnegative representative of $a$.

**Lemma 4.4.** The half-range selector is a two-torsion selector for $\mathbb{Z}/2k$ with two values.

*Proof.* Suppose $2\bar a \equiv 2\bar b \pmod{2k}$. Then $\bar a \equiv \bar b \pmod k$, so $\bar a$ and $\bar b$ are equal or differ by exactly $k$.

- If both lie in $[0,k)$, both are reduced mod $k$, so they are equal.
- If both lie in $[k,2k)$, then $\bar a - k$ and $\bar b - k$ are reduced mod $k$, so again $\bar a = \bar b$.

So equal half-bits and equal doubles force equality. $\square$

**Theorem 4.5 (One-bit floor at even moduli).** For even $n$, every battery over $\mathbb{Z}/n$ satisfies $\mathrm{hint} \ge -1$.

*Proof.* Apply Corollary 3.3 with the half-range selector, for which $|F| = 2$. $\square$

**Lemma 4.6 (Collision mechanism).** Let $R$ be any commutative ring. Take a two-sample battery $\Omega=\{0,1\}$ with distinct labels $T(0) = 0$ and $T(1) = 1$, so that $H(T) = 1$. Suppose the two samples have equal residue readings $\rho(0) = \rho(1)$ but different products $N(0)\ne N(1)$. Then

$$\mathrm{hint} = -1.$$

*Proof.*

- The residue reading is constant, so $I(T;\rho) = 0$ by (F5).
- The product separates the two samples, so it determines $T$, and $I(T;N) = H(T) = 1$ by (F4).

$\square$

**Theorem 4.7 (The floor is attained at every even modulus).** For every $k\ge1$ there is a two-sample battery over $\mathbb{Z}/2k$ with distinct labels and hint value exactly $-1$. Explicitly:

- if $k$ is even: samples $(P,Q) = (0,1)$ and $(k,k+1)$;
- if $k$ is odd: samples $(P,Q) = (0,0)$ and $(k,k)$.

*Proof.* In the first case the sums are $1$ and $2k+1\equiv1$, and both differences equal $-1$. The products are $0$ and $k(k+1)$. If $2k \mid k(k+1)$ then $2 \mid k+1$, which contradicts $k$ even.

In the second case the sums are $0$ and $2k \equiv 0$, and both differences are $0$. The products are $0$ and $k^2$. If $2k\mid k^2$ then $2\mid k$, which contradicts $k$ odd.

Lemma 4.6 finishes the proof. $\square$

*Examples.* Modulo $8$ the samples $(0,1)$ and $(4,5)$ share $(s,d) = (1,7)$ and have products $0$ and $4$. Modulo $6$ the samples $(0,0)$ and $(3,3)$ share $(s,d) = (0,0)$ and have products $0$ and $3$.

**Theorem 4.8 (The hint is universal exactly at odd moduli).** Let $n \ge 1$. The following are equivalent:

1. every battery over $\mathbb{Z}/n$ has nonnegative hint value;
2. every two-sample battery over $\mathbb{Z}/n$ with two labels has nonnegative hint value;
3. $n$ is odd.

Moreover, when $n$ is even the infimum of the hint value over all batteries is exactly $-1$, and it is attained.

*Proof.* (1)$\Rightarrow$(2) is trivial. (3)$\Rightarrow$(1) is Theorem 4.2. For (2)$\Rightarrow$(3): if $n = 2k$ is even, Theorem 4.7 gives a two-sample, two-label battery with hint $-1<0$. The final statement combines Theorems 4.5 and 4.7. $\square$

---

## 5. Products of even rings: one negative bit per even factor

**Lemma 5.1 (Selectors multiply).** Let $\sigma_1$ be a selector for $R_1$ with values in $F_1$, and $\sigma_2$ a selector for $R_2$ with values in $F_2$. Then $(a_1,a_2)\mapsto(\sigma_1(a_1),\sigma_2(a_2))$ is a selector for $R_1\times R_2$ with values in $F_1\times F_2$.

*Proof.* Doubling and equality in $R_1 \times R_2$ are computed coordinatewise, so the selector property follows coordinate by coordinate. $\square$

**Theorem 5.2 (Two-factor floor).** Every battery over $\mathbb{Z}/2k\times\mathbb{Z}/2l$ has $\mathrm{hint}\ge-2$.

*Proof.* Use the product of two half-range selectors, which has $|F| = 4$, in Corollary 3.3. $\square$

**Theorem 5.3 (The two-factor floor is attained).** Over $\mathbb{Z}/8\times\mathbb{Z}/8$, take four samples with

$$P = (0,0),\,(0,4),\,(4,0),\,(4,4), \qquad Q = (1,1),\,(1,5),\,(5,1),\,(5,5),$$

in that order, and four distinct labels. This battery has hint value exactly $-2$.

*Proof.* Every sample has $s = (1,1)$ and $d = (7,7)$, so $I(T;\rho) = 0$. The products are $(0,0),(0,4),(4,0),(4,4)$, which are pairwise distinct. So $N$ determines $T$ and $I(T;N) = H(T) = \log_2 4 = 2$. $\square$

---

## 6. Ceiling, budget and coupling

**Theorem 6.1 (Modulus ceiling).** Every battery over $\mathbb{Z}/n$ satisfies $\mathrm{hint}\le 2\log_2 n$.

*Proof.* By (F2), $I(T;\rho) \le H(\rho)\le\log_2|(\mathbb{Z}/n)^2| = 2\log_2 n$. By (F1), $I(T;N)\ge0$. $\square$

**Proposition 6.2 (Budget identity and ceiling).** Over any commutative ring,

$$I(T;N) + \mathrm{hint} = I(T;\rho) \le H(T).$$

*Proof.* The identity is the definition of the hint value. The inequality is (F1). $\square$

**Proposition 6.3 (Coupling floor).** Over any commutative ring, $\mathrm{hint} \ge -I(T;N)$. A hint can never destroy more information than the product carries.

*Proof.* This follows from $I(T;\rho)\ge0$. $\square$

Combining Theorem 4.5 with Proposition 6.3: at an even modulus, $\mathrm{hint}\ge-\min\big(1, I(T;N)\big)$.

---

## 7. Capacity and hint are functionally independent

The observed correlation of $0.256$ suggests that the two quantities are unrelated. We establish the structural version of this claim.

**Theorem 7.1 (The four corners).** Over $\mathbb{Z}/5$ with four samples and labels in a four-element set, the pair $\big(I(T;N),\,\mathrm{hint}\big)$ attains each of $(0,0)$, $(0,1)$, $(1,0)$ and $(1,1)$.

*Proof.* We use two batteries:

- the *witness battery* $W$, with samples $(1,1),(1,2),(2,3),(2,1)$;
- the *product-measurable battery* $C$, with samples $(1,1),(1,1),(1,2),(1,2)$.

In $W$ the residue readings are $(2,0),(3,4),(0,4),(3,1)$, which are pairwise distinct. The products are $1,2,1,2$.

| corner | battery | labels | $I(T;N)$ | $I(T;\rho)$ | hint |
|---|---|---|---|---|---|
| $(0,0)$ | $W$ | $0,0,0,0$ | $0$ | $0$ | $0$ |
| $(0,1)$ | $W$ | $0,0,1,1$ | $0$ | $1$ | $1$ |
| $(1,0)$ | $C$ | $0,0,1,1$ | $1$ | $1$ | $0$ |
| $(1,1)$ | $W$ | $0,1,2,3$ | $1$ | $2$ | $1$ |

We justify each row.

- **$(0,0)$.** Constant labels have $H(T)=0$, so both informations vanish by (F1).
- **$(0,1)$.** The label classes are $\{0,1\}$ and $\{2,3\}$, and the product classes are $\{0,2\}$ and $\{1,3\}$. Each joint (label, product) cell contains exactly one sample, so $H(T,N) = 2 = H(T)+H(N)$ and $I(T;N)=0$. The residue reading is injective, so $I(T;\rho) = H(T) = 1$ by (F4).
- **$(1,0)$.** In $C$ both the product and the residue reading split the samples as $\{0,1\}\,|\,\{2,3\}$, which is exactly the label partition. So both informations equal $1$.
- **$(1,1)$.** With injective labels, $T$ determines $N$, so $I(T;N) = H(N) = 1$. The residue reading is injective, so $I(T;\rho) = H(T) = 2$.

$\square$

**Corollary 7.2.**

- There is no function $\phi:\mathbb{R}\to\mathbb{R}$ with $\mathrm{hint} = \phi(I(T;N))$ for all batteries over $\mathbb{Z}/5$: the corners $(0,0)$ and $(0,1)$ rule it out.
- There is no function $\psi$ with $I(T;N)=\psi(\mathrm{hint})$: the corners $(0,1)$ and $(1,1)$ rule it out.

The only constraints linking the two coordinates are the budget $I(T;N)+\mathrm{hint}\le H(T)$ (Proposition 6.2) and the floors of Sections 3 to 6. Conceptually, capacity measures how well the *product partition* of $\Omega$ predicts the label. The hint measures how much the *residue partition* adds beyond it. At odd moduli the residue partition refines the product partition, and these are two independent features of the pair of partitions. "Independent" here means functional independence subject to a joint budget. It is not a claim of statistical independence under any distribution on dials.

---

## 8. The six-dial table

**Theorem 8.1 (Dial windows).**

1. For each of the moduli $m\in\{11,5,31,23,9\}$, every battery over $\mathbb{Z}/m$ has $0\le\mathrm{hint}\le2\log_2 m$.
2. Every battery over $\mathbb{Z}/8$ satisfies
$$-1\le \mathrm{hint},\qquad -I(T;N)\le\mathrm{hint},\qquad \mathrm{hint}\le 6.$$
3. The value $-1$ is attained over $\mathbb{Z}/8$, by the samples $(0,1)$ and $(4,5)$.

*Proof.* The moduli in (1) are odd, so Theorems 4.2 and 6.1 apply. Part (2) follows from Theorem 4.5, Proposition 6.3 and Theorem 6.1, using $2\log_2 8 = 6$. Part (3) is Theorem 4.7 with $k=4$. $\square$

**Arithmetic checks on the reported table.** Direct computation gives:

- The hint column sums to $4.0908$ and the capacity column to $5.5015$.
- Every reported hint lies in its window: $[0, 2\log_2 m]$ for the odd dials and $[-1,6]$ for $D_4$. Indeed every hint is below $2 \le 2\log_2 5$.
- Let $\mathrm{cov}(u,v) = \sum_i (u_i - \bar u)(v_i-\bar v)$. Then
$$\mathrm{cov}(c,h) = \tfrac{48451189}{10^8},\qquad \mathrm{cov}(c,c) = \tfrac{299900341}{1.2\times 10^8},\qquad \mathrm{cov}(h,h)=\tfrac{71677991}{5\times10^7}.$$
From these, $0.255<r<0.257$ and $r^2 < 0.07$.

**Interpretation.** For the five odd dials, positivity of the hint is a law that holds for every possible battery. For the $D_4$ dial at $m=8$, the reported $+0.5032$ is an empirical property of the particular battery measured. The proven window reaches down to $-1$, and $-1$ is attained. So the verdict "the hint is universal" should read: *the hint is universal at odd moduli, and costs at most one bit at even moduli.*

---

## 9. Algorithms

**Algorithm A (Empirical hint value).** Given $n$ samples $(P_i,Q_i,T_i)$ over $\mathbb{Z}/m$:

1. Compute $N_i = P_iQ_i$, $s_i = P_i+Q_i$ and $d_i = P_i-Q_i$ modulo $m$.
2. Build frequency tables of $T$, $N$, $(s,d)$, $(T,N)$ and $(T,s,d)$ using hashing.
3. Return $I(T;(s,d)) - I(T;N)$, with $I(T;X) = H(T)+H(X)-H(T,X)$.

The cost is $O(n)$ expected time and $O(n)$ memory.

**Algorithm B (Collision witness at an even modulus).** Input $m=2k$. If $k$ is even, output $(0,1),(k,k+1)$. Otherwise output $(0,0),(k,k)$. Assign labels $0$ and $1$. The hint value is $-1$ (Theorem 4.7). This takes $O(1)$ time.

**Algorithm C (Selector check).** Input a ring $R$ and a map $\sigma$. Check that $\sigma$ separates every pair $a\neq b$ with $2a=2b$. Grouping elements by $2a$ and testing injectivity of $\sigma$ on each group costs $O(|R|)$ time. For a valid selector, $-\log_2|F|$ is a certified lower bound on the hint.

**Algorithm D (Exhaustive floor search).** Enumerate all two-sample batteries $(P_0,Q_0),(P_1,Q_1)\in(\mathbb{Z}/n)^4$ with distinct labels and take the minimum hint. This costs $O(n^4)$. It returns $0$ for odd $n$ and $-1$ for even $n$, in agreement with Theorem 4.8. In randomised tests with $2$ to $10$ samples and $2$ to $5$ labels at $m\in\{5,7,9,11,23,31\}$ and $m \in\{8,12,16\}$, the observed minima were exactly $0$ and $-1$ respectively.

---

## 10. Discussion: the geometry of the fold

View $(P,Q)$ as a point of the discrete torus $(\mathbb{Z}/m)^2$. The linear map $(P,Q)\mapsto(s,d)$ has determinant $-2$.

- At odd $m$ it is a bijection of the torus. The level sets of the product, the discrete hyperbolas $\{PQ = N\}$, are carried to the conics $\{s^2 - d^2 = 4N\}$, and no information is lost.
- At even $m$ the map folds the torus. Its fibres are the cosets of the diagonal subgroup $\{(t,t): t\in R[2]\}$. Along a fibre the product changes by
$$(P+t)(Q+t) - PQ = t\,s + t^2.$$
A negative hint arises exactly when this change is nonzero on some fibre that the labels distinguish.

The two-torsion floor bounds the damage by the logarithm of the number of values needed to resolve a fibre. Theorems 4.7 and 5.3 show that for cyclic rings and for products of two even cyclic rings, this worst case really occurs.

The result parallels a known phenomenon on the ceiling side, where a synergy bound gains one "orientation bit" per field factor. Here the floor loses one bit per even cyclic factor. Both follow from the multiplicativity of selectors (Lemma 5.1).

---

## 11. Future directions

**F1. Torsion floor law.** Conjecture: for every finite commutative ring $R$, the infimum of the hint over all batteries equals $-\log_2|R[2]|$. The fibres of $(P,Q)\mapsto(s,d)$ are cosets of $\{(t,t):t\in R[2]\}$, on which $N\mapsto N+ts+t^2$. The floor is reached exactly when $t\mapsto ts+t^2$ is injective on $R[2]$ for some $s$. The lower bound already holds whenever there is a selector into a set of size $|R[2]|$. What remains is attainment.

**F2. One negative bit per even factor.** Conjecture: over $\prod_{i<k}\mathbb{Z}/2m_i$ the floor is exactly $-k$ bits, reached by the $2^k$-sample product of the one-factor collision batteries. The cases $k=1$ and $k = 2$ are proved above (Theorems 4.7, 5.2 and 5.3). The general case needs one lemma about the entropy of a product population.

**F3. Product-fibre ceiling.** Conjecture: over $\mathbb{Z}/n$ the supremum of the hint equals $\log_2 M(n)$, where $M(n)$ is the largest number of pairs sharing one product residue. For example $M(p) = 2p-1$ for a prime $p$ (the zero fibre), $M(8)=20$ and $M(9)=21$. The upper bound comes from $\mathrm{hint}\le H(\pi\mid N)\le\log_2M(n)$. The lower bound is reached by placing one sample on each pair of the largest fibre with distinct labels, which gives $I(T;N)=0$ and $I(T;\rho)=\log_2 M(n)$ at odd $n$.

**F4. Exact capacity–hint region.** Conjecture: for an odd prime $p$ and a label alphabet of entropy $h$, the achievable (capacity, hint) pairs are dense in the triangle
$$\{c\ge0,\ t\ge0,\ c+t\le\min(h, 2\log_2 p)\}.$$

---

## 12. Conclusion

The six positive readings of the hint-value experiment have been replaced by a complete description. The hint value is at least $-\log_2|F|$ for any two-torsion selector into $F$. It is nonnegative precisely at odd cyclic moduli, and at even cyclic moduli its sharp floor is $-1$ bit, attained everywhere. It is capped by $2\log_2 m$ and by the label budget. It is functionally independent of capacity. Five of the six dials are positive by necessity, while the sixth is positive by circumstance.
