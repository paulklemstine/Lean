# Multiplicity in Pascal's Triangle: Smoothness Hierarchies, Sharp Thresholds, and the Complete Classification of Adjacent Repetitions

**Author:** Aristotle
**Date:** 2026-08-09

---

## Abstract

For an integer $t \ge 2$ let $N(t) = \#\{(n,k) : 0 \le k \le n,\ \binom{n}{k} = t\}$ denote the *multiplicity* of $t$ in Pascal's triangle. Singmaster's conjecture (1971) asserts that $N$ is bounded; it remains open. We develop the elementary theory of $N$ along four axes.

First, a **multiplicative criterion**: if $t \ge 3$ possesses a prime factor $p$ with $p(p-1) > 2t$, then $N(t) = 2$. Equivalently, $N(t) \ge 3$ forces every prime factor of $t$ to satisfy $p \le \sqrt{2t}+1$. This is the first level of an infinite **smoothness hierarchy**: $N(t) \ge 2m+2$ implies $\binom{p}{m+1} \le t$, hence $(p-m)^{m+1} \le (m+1)!\,t$, for every prime $p \mid t$. Repetition forces extreme smoothness; applied to Singmaster's record holder $3003$, the level $m=3$ already forbids any prime factor exceeding $17$.

Second, a **counting theorem**: $\#\{t \le X : N(t)\ge 3\} \le (\sqrt{2X}+2)(\log_2 X+1)$, whence the integers of multiplicity exactly two have density one.

Third, **sharp thresholds**: $6$, $10$, $120$ and $3003$ are the least integers of multiplicity at least $3$, $4$, $6$ and $8$ respectively, together with the general growth bound $N(t) \ge 2m+2 \Rightarrow t \ge \binom{2m+3}{m+1}$; and a **sharpened logarithmic bound** $N(t) \le \log_2 t + \log_2(2\log_2 t + 1)+1$, halving the leading constant of the classical estimate $N(t) \le 2\log_2 t$.

Fourth, and most precisely, we **completely classify adjacent repetitions** $\binom{n}{k} = \binom{n-1}{k+1}$ — the mechanism producing numbers of multiplicity at least six. Such a pair exists if and only if $5n+1 = L_{4j+9}$ and $5(n-k) = L_{4j+8}+3$ for consecutive Lucas numbers, if and only if $(n,k) = (F_{2i+4}F_{2i+5},\, F_{2i+2}F_{2i+5})$. The classical Fibonacci family is therefore **exhaustive**: the complete list of adjacent repetitions is $(15,5), (104,39), (714,272), (4895,1869), \dots$. The proof passes through the norm form $x^2-xy-y^2=\pm 5$ of $\mathbb{Q}(\sqrt5)$, all of whose natural solutions are consecutive Lucas pairs, and the identification of the two parametrisations is driven by Cassini's identity.

**Keywords:** Pascal's triangle, binomial coefficients, Singmaster's conjecture, multiplicity, smooth numbers, Lucas numbers, Fibonacci numbers, Cassini's identity, norm form, Diophantine descent.

---

## 1. Introduction

Pascal's triangle displays the binomial coefficients $\binom{n}{k}$ for $0 \le k \le n$, each interior entry being the sum of the two entries above it. It is an infinite array of positive integers, and one may ask a question of purely arithmetical flavour: how often does a given integer occur in it?

### 1.1 The multiplicity function

**Definition 1.1 (Occurrence set and multiplicity).** For $t \in \mathbb{N}$ set
$$
\mathrm{Occ}(t) = \left\{ (n,k) \in \mathbb{N}^2 \ :\ k \le n,\ \binom{n}{k} = t \right\},
\qquad N(t) = \#\,\mathrm{Occ}(t).
$$

The entry $1$ occupies every position with $k \in \{0,n\}$, so $N(1) = \infty$; throughout we consider $t \ge 2$, for which $N(t)$ is finite (Proposition 2.3). Two occurrences are automatic for $t \ge 3$, namely $\binom{t}{1}$ and $\binom{t}{t-1}$; the number $2$ is exceptional, with $N(2) = 1$ because those two positions coincide.

The known landscape is:

| $t$ | $2$ | $3,4,5,7,11,\dots$ | $6$ | $10, 21, 15$ | $120, 210, 1540$ | $3003$ |
|---|---|---|---|---|---|---|
| $N(t)$ | $1$ | $2$ | $3$ | $4$ | $6$ | $8$ |

No integer is known with $N(t) \in \{5,7\}$ or $N(t) \ge 9$, and $3003$ is the only known integer with $N(t)=8$; the number $3003$ occupies the eight positions
$$
\binom{3003}{1},\ \binom{3003}{3002},\ \binom{78}{2},\ \binom{78}{76},\ \binom{15}{5},\ \binom{15}{10},\ \binom{14}{6},\ \binom{14}{8}.
$$

**Conjecture 1.2 (Singmaster, 1971).** There is an absolute constant $C$ with $N(t) \le C$ for all $t \ge 2$.

The best unconditional bounds in the literature are of the form $O(\log t/\log\log t)$ and are not elementary; the elementary bound is $N(t) \le 2\log_2 t$. Nothing better than "bounded by a slowly growing function" is known, and even the statement that $N(t) \ne 5$ for all $t$ is open.

### 1.2 Two structural symmetries

Two symmetries organise every argument below.

**Reflection.** $\binom{n}{k} = \binom{n}{n-k}$, so occurrences come in mirror pairs unless $2k = n$. Calling an occurrence *left-interior* when $2 \le k$ and $2k < n$, and *central* when $2k = n$ and $k\ge2$, one obtains the **parity decomposition**
$$
N(t) = 2 + 2\,\#\mathrm{LeftInt}(t) + \#\mathrm{Center}(t), \qquad t \ge 3, \tag{1.1}
$$
where $\mathrm{Center}(t)$ has at most one element because $c \mapsto \binom{2c}{c}$ is strictly increasing. In particular **$N(t)$ is even unless $t$ is a central binomial coefficient.**

**Column monotonicity.** For fixed $k \ge 1$ the map $n \mapsto \binom{n}{k}$ is strictly increasing, so an occurrence is determined by its column: two distinct interior occurrences of the same $t$ have distinct columns. This "column uniqueness" converts multiplicity into a supply of *distinct columns*, which is the engine of Sections 3 and 5.

### 1.3 Results and organisation

Section 2 collects the geometric and arithmetic inputs. Section 3 proves the smoothness criterion and its infinite hierarchy. Section 4 proves the counting theorem and density one. Section 5 proves the sharp thresholds $6, 10, 120, 3003$ and the general growth bound. Section 6 sharpens the elementary logarithmic bound. Section 7 classifies adjacent repetitions in Lucas coordinates; Section 8 identifies that classification with the Fibonacci family via Cassini's identity, establishing completeness. Section 9 records algorithms, Section 10 discusses consequences and open problems.

---

## 2. Preliminaries: the geometry–arithmetic cross-cut

Two elementary facts are used everywhere. The first is *geometric*: an interior entry cannot be small relative to its row. The second is *arithmetic*: a binomial coefficient cannot have large prime factors relative to its row. Chaining them produces every smoothness statement in this paper.

**Lemma 2.1 (Unimodality along a row).** For $k \le n$ let $b = \min(k, n-k)$ be the *folded column index*. Then $\binom{n}{k} = \binom{n}{b}$, and $\binom{n}{j} \le \binom{n}{k}$ whenever $j \le b$. In particular $\binom{n}{2} \le \binom{n}{k}$ whenever $2 \le k \le n-2$.

*Proof sketch.* Rows of Pascal's triangle increase up to the middle: $\binom{n}{j}/\binom{n}{j-1} = (n-j+1)/j \ge 1$ for $j \le n/2$. Reflection handles $k > n/2$. $\square$

**Lemma 2.2 (Row cap).** If $\binom{n}{k} = t$ with $2 \le k \le n-2$, then $n(n-1) \le 2t$; consequently $n \le \sqrt{2t}+1$.

*Proof sketch.* By Lemma 2.1, $\binom{n}{2} \le t$, and $2\binom{n}{2} = n(n-1)$. $\square$

**Proposition 2.3 (Finiteness).** For $t \ge 2$, $N(t)$ is finite, and every interior occurrence satisfies $n \le \sqrt{2t}+1$ and $\min(k, n-k) \le \log_2 t$.

*Proof sketch.* The row bound is Lemma 2.2. For the column bound, $2^{b} \le \binom{2b}{b} \le \binom{n}{b} = t$ when $2b \le n$. $\square$

**Lemma 2.4 (Prime factors are small).** If $p$ is prime, $k \le n$, and $p \mid \binom{n}{k}$, then $p \le n$.

*Proof sketch.* $\binom{n}{k}\,k!\,(n-k)! = n!$, so $p \mid n!$, and a prime dividing $n!$ is at most $n$. $\square$

**Lemma 2.5 (The cross-cut).** If $\binom{n}{k} = t$ with $2 \le k \le n-2$ and $p$ is a prime factor of $t$, then
$$
p(p-1) \le n(n-1) \le 2t .
$$

*Proof sketch.* Lemma 2.4 gives $p \le n$; the map $x \mapsto x(x-1)$ is monotone on the positive integers; Lemma 2.2 finishes. $\square$

---

## 3. Smoothness: how repetition constrains factorisation

### 3.1 The multiplicity-two criterion

**Theorem 3.1 (Large prime factor forces multiplicity two).** Let $t \ge 3$ have a prime factor $p$ with $2t < p(p-1)$. Then $N(t) = 2$; the only occurrences are $\binom{t}{1}$ and $\binom{t}{t-1}$.

*Proof sketch.* By Lemma 2.5, $t$ has no occurrence with $2 \le k \le n-2$. It also has no central occurrence: a central occurrence with $k \le 1$ would force $t \le 2$, and one with $k \ge 2$ is interior, hence excluded. By the parity decomposition (1.1) both correction terms vanish and $N(t)=2$. $\square$

**Theorem 3.2 (Smoothness Theorem).** If $t \ge 3$ and $N(t) \ge 3$, then every prime factor $p$ of $t$ satisfies
$$
p(p-1) \le 2t, \qquad\text{hence}\qquad p \le \sqrt{2t}+1 .
$$

*Proof sketch.* Contrapositive of Theorem 3.1. For the second form, if $p > \sqrt{2t}+1$ then $p(p-1) \ge (\lfloor\sqrt{2t}\rfloor+1)^2 > 2t$. $\square$

### 3.2 Families of multiplicity exactly two

**Corollary 3.3.** For every $c \ge 1$ and every prime $p > 2c+1$ we have $N(cp) = 2$.

*Proof sketch.* Apply Theorem 3.1 to $t = cp$: $2t = 2cp < (p-1)p$ precisely when $2c < p-1$. $\square$

Special cases: every prime $p \ge 5$ occurs exactly twice ($c=1$); every $2p$ with $p \ge 7$ occurs exactly twice ($c=2$) — the exclusions $2\cdot3 = 6$ and $2\cdot5=10$ are exactly the numbers with $N=3$ and $N=4$.

**Corollary 3.4 (Multiplicity two in every divisibility class).** For each $c \ge 1$ the set $\{t : N(t) = 2 \text{ and } c \mid t\}$ is infinite.

*Proof sketch.* Choose primes $p$ exceeding $\max(2c+1, M)$; the numbers $cp$ are unbounded and each has $N = 2$ by Corollary 3.3. $\square$

### 3.3 The smoothness hierarchy

The criterion above is the case $m=1$ of an infinite family, obtained by replacing the column $2$ by an arbitrarily deep column. The supply of deep columns is created by column uniqueness.

**Lemma 3.5 (Deep column from high multiplicity).** Let $t \ge 3$, $m \ge 1$ and $N(t) \ge 2m+2$. Then there is an occurrence $\binom{n}{k}=t$ with $2k < n$ and $k \ge m+1$.

*Proof sketch.* By (1.1) and $\#\mathrm{Center}(t)\le 1$, we get $\#\mathrm{LeftInt}(t) \ge m$. Distinct left-interior occurrences have distinct columns (column monotonicity), and every such column is $\ge 2$. If all these columns were $\le m$ they would lie in $[2,m]$, a set of size $m-1 < m$ — contradiction. $\square$

**Theorem 3.6 (Smoothness Hierarchy).** Let $t \ge 3$, $m \ge 1$, and suppose $N(t) \ge 2m+2$. Then for every prime $p \mid t$,
$$
\binom{p}{\,m+1\,} \le t .
$$

*Proof sketch.* Take the occurrence $\binom{n}{k}=t$ of Lemma 3.5, with $k \ge m+1$ and $2k<n$. By Lemma 2.4, $p \le n$. Monotonicity in the row gives $\binom{p}{m+1} \le \binom{n}{m+1}$, and unimodality (Lemma 2.1, since $m+1 \le k = \min(k,n-k)$) gives $\binom{n}{m+1} \le \binom{n}{k} = t$. $\square$

**Corollary 3.7 (Quantitative form).** Under the hypotheses of Theorem 3.6,
$$
(p-m)^{m+1} \le (m+1)!\; t, \qquad\text{i.e.}\qquad p \le m + \big((m+1)!\,t\big)^{1/(m+1)} .
$$

*Proof sketch.* $(p+1-(m+1))^{m+1} \le p^{\underline{m+1}} = (m+1)!\binom{p}{m+1} \le (m+1)!\,t$, where $p^{\underline{m+1}}$ is the falling factorial. $\square$

Thus a number of multiplicity $\ge 4$ is essentially $\sqrt{2t}$-smooth, one of multiplicity $\ge 6$ is essentially $(6t)^{1/3}$-smooth (explicitly $p(p-1)(p-2) \le 6t$), one of multiplicity $\ge 8$ is $(24t)^{1/4}$-smooth, and so on.

**Example 3.8 (The hierarchy sees $3003$).** Since $N(3003)=8=2\cdot3+2$, Theorem 3.6 with $m=3$ gives $\binom{p}{4}\le 3003$ for each prime $p \mid 3003$. As $\binom{18}{4}=3060>3003$, no prime factor can be $\ge 18$: every prime factor of $3003$ is at most $17$. Indeed $3003 = 3\cdot 7\cdot 11\cdot 13$, and $\binom{13}{4}=715 \le 3003$ with room to spare.

---

## 4. Almost every integer occurs exactly twice

**Definition 4.1.** $H(X) = \#\{t : 2 \le t \le X,\ N(t)\ge 3\}$.

**Lemma 4.2.** If $t \ge 3$ and $N(t)\ge 3$, then $t$ has an occurrence $\binom{n}{k}=t$ with $2 \le k$ and $2k \le n$.

*Proof sketch.* By (1.1), either $\mathrm{LeftInt}(t) \neq \emptyset$ — giving such an occurrence directly — or $\mathrm{LeftInt}(t)=\emptyset$ and $\#\mathrm{Center}(t)=1$, in which case the central occurrence $\binom{2k}{k}=t$ has $k \ge 2$ since $\binom{2}{1}=2 < 3 \le t$. $\square$

**Theorem 4.3 (Counting Theorem).** For every $X$,
$$
H(X) \;\le\; \big(\lfloor\sqrt{2X}\rfloor+2\big)\big(\lfloor\log_2 X\rfloor+1\big).
$$

*Proof sketch.* By Lemma 4.2 every counted $t$ is a value $\binom{n}{k}$ with $2 \le k$, $2k\le n$. Lemma 2.2 gives $n(n-1)\le 2t \le 2X$, so $n \le \lfloor\sqrt{2X}\rfloor+1$; and $2^{k} \le \binom{n}{k} = t \le X$ gives $k \le \lfloor\log_2 X\rfloor$. Hence the counted set is contained in the image of the box $\{0,\dots,\lfloor\sqrt{2X}\rfloor+1\}\times\{0,\dots,\lfloor\log_2 X\rfloor\}$ under $(n,k)\mapsto\binom{n}{k}$, whose cardinality is at most that of the box. $\square$

**Theorem 4.4 (Density one).** For every $c \in \mathbb{N}$ there is $X_0$ with $c\,H(X) \le X$ for all $X \ge X_0$. Equivalently, $H(X) = o(X)$: the integers of multiplicity exactly two have natural density $1$.

*Proof sketch.* Theorem 4.3 gives $H(X) = O(\sqrt{X}\log X)$. Quantitatively, with $u=\lfloor\sqrt X\rfloor$ and $v = \lfloor\sqrt u\rfloor$, one shows $\log_2 X + 1 \le 4v+3$ and $\lfloor\sqrt{2X}\rfloor \le 2u+1$, hence $H(X) \le (2u+3)(4v+3) \le 15uv$; taking $X_0 = (21c+21)^4+16$ forces $v \ge 21c+21$ and $15cv \le u$, whence $cH(X) \le u^2 \le X$. $\square$

**Numerics.** For $X=10^6$ the bound of Theorem 4.3 gives $28\,320$; the exact count is $1\,732$, i.e. one integer in about $577$. The exact counts for $X = 10^2,\dots,10^6$ are $16,\ 64,\ 199,\ 592,\ 1732$. The full distribution below $10^{6}$ is

| $N(t)$ | $1$ | $2$ | $3$ | $4$ | $6$ | $8$ |
|---|---|---|---|---|---|---|
| count | $1$ | $998\,266$ | $10$ | $1\,715$ | $6$ | $1$ |

with no occurrence of $N = 5$, $N = 7$ or $N \ge 9$; the six integers of multiplicity six are $120, 210, 1540, 7140, 11628, 24310$, and the unique integer of multiplicity eight is $3003$.

---

## 5. Sharp thresholds: the least number of each multiplicity

The classical specimens $6, 10, 120, 3003$ are not merely examples but *minima*.

**Theorem 5.1 (General growth threshold).** If $t \ge 3$, $m \ge 1$ and $N(t) \ge 2m+2$, then
$$
t \ \ge\ \binom{2m+3}{m+1}.
$$

*Proof sketch.* Lemma 3.5 supplies an occurrence with column $k \ge m+1$ and $2k<n$, so $n \ge 2m+3$. Then $t = \binom{n}{k} \ge \binom{n}{m+1} \ge \binom{2m+3}{m+1}$, using unimodality and row monotonicity. $\square$

For $m=1,2,3$ this reads $t \ge 10,\ 35,\ 126$. The true thresholds are larger and require genuine descent.

**Theorem 5.2 (Two interior columns force $t \ge 120$).** Suppose $\binom{n}{j} = \binom{m}{k} = t$ with $2 \le j < k$, $2j<n$, $2k<m$. Then $t \ge 120$.

*Proof sketch.* Since $j\ge2$ and $j<k$, we have $k \ge 3$. If $k \ge 4$ then unimodality and $m \ge 2k+1 \ge 9$ give $t \ge \binom{9}{4} = 126$. If $k = 3$ then $j = 2$, so $t$ is simultaneously $\binom{m}{3}$ with $m \ge 7$ and a triangular number $\binom{n}{2}$ with $n \ge 5$; if $m \ge 10$ then $t \ge \binom{10}{3} = 120$ already, and the residual candidates $\binom{7}{3}=35$, $\binom{8}{3}=56$, $\binom{9}{3}=84$ are not triangular. $\square$

**Theorem 5.3 (Sharp thresholds).** Among integers $t\ge 2$:
1. $6$ is the least $t$ with $N(t)\ge 3$;
2. $10$ is the least $t$ with $N(t)\ge 4$;
3. $120$ is the least $t$ with $N(t)\ge 6$;
4. $3003$ is the least $t$ with $N(t)\ge 8$.

Since $N(6)=3$, $N(10)=4$, $N(120)=6$, $N(3003)=8$, each of these is a genuine least element of the corresponding set.

*Proof sketch.* (1) and (2) are direct verification on $t \le 9$. (3): by (1.1) and $\#\mathrm{Center}\le1$, $N(t)\ge6$ forces $\#\mathrm{LeftInt}(t) \ge 2$, i.e. two left-interior occurrences; their columns are distinct by column uniqueness, so Theorem 5.2 applies and $t\ge120$.
(4): $N(t)\ge8$ forces $\#\mathrm{LeftInt}(t)\ge3$, hence three distinct interior columns, all $\ge 2$; the largest, $k$, satisfies $k\ge4$, and there are two further columns $2 \le j_1 < j_2 < k$. Suppose $t<3003$. If $k \ge 7$ then $t \ge \binom{15}{7}=6435$, contradiction, so $k \le 6$; if the row $m$ of the deepest occurrence were $\ge 18$ then $t \ge \binom{18}{4}=3060$, so $m \le 17$; and any interior occurrence in a column $\ge 2$ with $t<3003$ has row $\le 78$ because $\binom{79}{2}=3081>3003$. Within this explicit finite box no value below $3003$ carries three interior columns; the check is genuinely non-trivial — e.g. $210 = \binom{10}{4} = \binom{21}{2}$ has *two* interior columns and is excluded only by the requirement of a third. $\square$

---

## 6. A factor-two sharpening of the elementary logarithmic bound

The classical elementary bound $N(t) \le 2\log_2 t$ comes from combining $2^{b}\le\binom{n}{b}$ (for $2b \le n$) with column uniqueness. The inequality $2^{b}\le\binom{2b}{b}$ is lossy by a factor $2^{b}/\sqrt{b}$; replacing it by a free pigeonhole estimate halves the leading constant.

**Lemma 6.1 (Row pigeonhole).** For every $b \ge 0$, $\ 4^{b} \le (2b+1)\binom{2b}{b}$.

*Proof sketch.* The $2b+1$ entries of row $2b$ sum to $2^{2b} = 4^{b}$ and each is at most the central entry $\binom{2b}{b}$. $\square$

**Lemma 6.2.** If $\binom{n}{k}=t$ and $b=\min(k,n-k)$, then $\binom{2b}{b}\le t$, hence $4^{b}\le(2b+1)t$.

*Proof sketch.* $2b \le n$ and $\binom{n}{b} = \binom{n}{k} = t$ by reflection and folding; row monotonicity gives $\binom{2b}{b}\le\binom{n}{b}$. Then apply Lemma 6.1. $\square$

**Theorem 6.3 (Sharpened bound).** For every $t \ge 2$,
$$
N(t) \ \le\ \log_2\!\big((2\log_2 t+1)\,t\big) \ \le\ \log_2 t + \log_2(2\log_2 t+1) + 1 .
$$

*Proof sketch.* Since $b \le \log_2 t$ always, Lemma 6.2 upgrades to the uniform estimate $4^{b} \le (2\log_2 t+1)t =: Y$ for every occurrence, so every folded index satisfies $b \le \tfrac12\log_2 Y$. Split $\mathrm{Occ}(t)$ into the positions with $b \le 1$ — at most two of them, namely the boundary pair — and the rest. Each folded value $b \ge 2$ is attained by at most two positions (reflection; column uniqueness within a fold), and the admissible values lie in $[2, \tfrac12\log_2 Y]$. Hence $N(t) \le 2 + 2(\tfrac12\log_2 Y - 1) = \log_2 Y$. The second inequality is $\log_2(ab)\le\log_2 a+\log_2 b+1$. $\square$

**Corollary 6.4.** For $t \ge 2^{16}$ the bound of Theorem 6.3 is strictly smaller than $2\log_2 t$.

*Proof sketch.* With $L = \lfloor\log_2 t\rfloor \ge 16$, one checks $2L+1 < 2^{L-2}$, so $\log_2(2L+1) \le L-3$ and the bound is at most $2L-2 < 2L$. $\square$

**Numerics.** For $t=3003$: classical bound $22$, new bound $16$, true value $8$. For $t<10^{6}$: $38$ versus $25$. The non-elementary Erdős–Abbott–Hanson–Singmaster estimate $O(\log t/\log\log t)$ is asymptotically stronger; Theorem 6.3 is elementary and attains the leading constant $1$ predicted by the "one column per power of four" heuristic.

---

## 7. Adjacent repetitions I: the Lucas classification

### 7.1 The phenomenon

A number with a single interior occurrence has four positions. To reach six, one needs a second interior occurrence, and the classical mechanism is an **adjacent repetition**: a value that reappears one row higher and one column to the right.

**Definition 7.1.** A pair $(n,k)$ with $1 \le k$ and $k+2\le n$ is an *adjacent repetition* if
$$
\binom{n}{k} = \binom{n-1}{k+1}.
$$

**Theorem 7.2 (Six positions).** If $(n,k)$ is an adjacent repetition with $2 \le k$ and $k+3 < n-k$, then $t=\binom{n}{k}$ satisfies $N(t)\ge 6$; the six positions are
$$
(t,1),\ (t,t-1),\ (n,k),\ (n,n-k),\ (n-1,k+1),\ (n-1,n-k-2).
$$

*Proof sketch.* The middle four are the reflections of the two occurrences $\binom{n}{k}$ and $\binom{n-1}{k+1}$; the hypotheses guarantee the six positions are pairwise distinct and that $t > n$, so the boundary pair is distinct from all of them. $\square$

### 7.2 From combinatorics to a Diophantine equation

**Theorem 7.3 (Dictionary).** For $1 \le k$ and $k+2 \le n$,
$$
\binom{n}{k} = \binom{n-1}{k+1}
\iff
n(k+1) = (n-k)(n-k-1).
$$

*Proof sketch.* Write $n = m+1$. Two Pascal recurrences read
$$
\binom{m}{k}(m+1) = \binom{m+1}{k}(m+1-k), \qquad \binom{m}{k+1}(k+1) = \binom{m}{k}(m-k).
$$
Multiplying and rearranging yields the identity
$$
\binom{m+1}{k}\big((m-k+1)(m-k)\big) = \binom{m}{k+1}\big((m+1)(k+1)\big),
$$
valid unconditionally. Since $\binom{m}{k+1} > 0$ and $(m-k+1)(m-k) > 0$, cancelling one or the other factor gives the two implications. $\square$

Two immediate structural consequences of the equation $n(k+1)=(n-k)(n-k-1)$:

**Lemma 7.4.** A solution with $1 \le k$, $k+2\le n$ has $k \ge 2$; and then $k+3 < n-k$ (so Theorem 7.2 applies) and $n < 4(k+1)$.

*Proof sketch.* Setting $v = n-k-2 \ge 0$ turns the equation into $(k+v+2)(k+1) = (v+2)(v+1)$. For $k=1$ this reduces to $v^2+v = 4$, which has no solution. The inequalities $v > k+1$ and $v < 3k+2$ follow by comparing the two sides under the contrary assumptions. $\square$

Asymptotically $k/n \to (3-\sqrt5)/2 \approx 0.382$, so adjacent repetitions occupy a fixed golden-ratio-determined slant in the triangle.

### 7.3 The norm form of $\mathbb{Q}(\sqrt5)$

**Definition 7.5 (Lucas sequence).** $L_0 = 2$, $L_1 = 1$, $L_{i+2} = L_i + L_{i+1}$: the sequence $2,1,3,4,7,11,18,29,47,76,123,199,322,521,\dots$

**Lemma 7.6 (Lucas pairs solve the form).** For all $i\ge0$,
$$
L_{i+1}^2 - L_{i+1}L_i - L_i^2 = 5\,(-1)^{i+1}.
$$

*Proof sketch.* Induction, using $L_{i+2}=L_i+L_{i+1}$; the inductive step is a one-line algebraic identity that reverses the sign. $\square$

**Theorem 7.7 (Complete solution of the norm form).** Let $x,y \in \mathbb{N}$ satisfy $x^2-xy-y^2 = \pm5$. Then $(x,y) = (L_{i+1}, L_i)$ for some $i \ge 0$.

*Proof sketch.* Vieta/Euclidean descent. The map $(x,y)\mapsto(y,x-y)$ preserves the set of solutions and negates the value of the form, and it strictly decreases the first coordinate whenever $x>y$. If $y=0$ the form is $x^2 = \pm5$, impossible since $5$ is not a square; if $x=y$ the form is $-x^2 = \pm5$, again impossible. If $x<y$ the form is negative and forces $x \le 1$, and then $x=1,y=2$, i.e. $(L_1,L_0)$ — the bottom of the descent. Otherwise $x>y$ and the descent step applies; strong induction on $x$ finishes, since the inverse of the step is exactly $(L_{i+1},L_i)\mapsto(L_{i+2},L_{i+1})$. $\square$

**Lemma 7.8 (Period-four congruence).** For all $j$, $\ L_{4j}\equiv 2$, $L_{4j+1}\equiv 1$, $L_{4j+2}\equiv3$, $L_{4j+3}\equiv 4 \pmod 5$. Consequently $L_i \equiv 2 \pmod 5$ implies $4 \mid i$.

*Proof sketch.* Induction on $j$ using the recurrence, four cases at a time. $\square$

### 7.4 The classification

**Lemma 7.9 (Substitution).** Put $u = n-k \ge 2$. If $n(k+1) = u(u-1)$ then, with $X = 5n+1$ and $U = 5u-3$,
$$
X^2 - XU - U^2 = -5 .
$$

*Proof sketch.* Substitute $k = n-u$ to get $n(n-u+1) = u(u-1)$, then expand $(5n+1)^2-(5n+1)(5u-3)-(5u-3)^2$ and reduce using that relation; all terms cancel except $-5$. $\square$

**Theorem 7.10 (Classification of adjacent repetitions).** For $1 \le k$ and $k+2\le n$,
$$
\binom{n}{k} = \binom{n-1}{k+1}
\iff
\exists\, j \ge 0:\quad 5n+1 = L_{4j+9} \ \text{ and }\ 5(n-k) = L_{4j+8}+3 .
$$

*Proof sketch.* ($\Rightarrow$) Theorem 7.3 and Lemma 7.9 produce a solution $(X,U) = (5n+1, 5u-3)$ of the norm form with value $-5$; Theorem 7.7 makes it a consecutive Lucas pair $(L_{i+1}, L_i)$. Since $U = 5u-3 \equiv 2 \pmod 5$, Lemma 7.8 gives $4 \mid i$, say $i = 4m$; the indices $m \le 1$ give degenerate pairs (they would force $n \le 2$), so $m \ge 2$ and $j = m-2$ works. ($\Leftarrow$) Run the substitution backwards: Lemma 7.6 at index $4j+8$ gives $L_{4j+9}^2 - L_{4j+9}L_{4j+8}-L_{4j+8}^2 = -5$, which upon writing $L_{4j+9} = 5n+1$, $L_{4j+8}=5u-3$ becomes exactly $n(k+1) = u(u-1)$; apply Theorem 7.3. $\square$

**Theorem 7.11 (The family is infinite and realised).** For every $j\ge0$ there exist $n,k$ with $1\le k$, $k+2\le n$, $5n+1 = L_{4j+9}$, and $\binom{n}{k}=\binom{n-1}{k+1}$; consequently there are infinitely many integers $t$ with $N(t) \ge 6$, and they are unbounded.

*Proof sketch.* The congruences of Lemma 7.8 show $L_{4j+9}\equiv1$ and $L_{4j+8}\equiv2 \pmod 5$, so $n = (L_{4j+9}-1)/5$ and $u = (L_{4j+8}+3)/5$ are integers; growth estimates ($L_{4j+8}\ge47$, $L_{4j+9} \ge L_{4j+8}+29$) make them admissible, and Theorem 7.10 gives the repetition. Theorem 7.2, applicable by Lemma 7.4, yields $N(\binom{n}{k})\ge6$. Unboundedness follows from $5M+2 \le L_{4M+9}$, hence $n > M$, hence $\binom{n}{k} \ge \binom{n}{2} > n > M$. $\square$

**Theorem 7.12 (Small solutions).** The only adjacent repetitions with $n \le 700$ are $(15,5)$ and $(104,39)$; the only one whose value is below $10^{6}$ is $(15,5)$, with $\binom{15}{5} = \binom{14}{6} = 3003$.

*Proof sketch.* By Theorem 7.10, $5n+1 = L_{4j+9}$; monotonicity of the Lucas sequence and $L_{17}=3571$ force $j \le 1$, and $L_9=76$, $L_{13}=521$ give $n=15$ and $n=104$. For the second claim, $2^{k}\le\binom{n}{k}<10^{6}$ forces $k \le 19$, and $n<4(k+1)$ (Lemma 7.4) then gives $n \le 700$; of the two survivors, $\binom{104}{39} \ge 2^{39} > 10^{6}$. $\square$

This is the structural explanation of the empirical fact that $3003$ is the most repetitive number below $10^{6}$: the Fibonacci-type growth of the family pushes the second member to $29$ digits.

---

## 8. Adjacent repetitions II: completeness of the Fibonacci family

The classical description of these repetitions is in terms of Fibonacci numbers $F_0=0$, $F_1=1$, $F_{a+2}=F_a+F_{a+1}$. Define
$$
R_i = F_{2i+4}F_{2i+5}, \qquad C_i = F_{2i+2}F_{2i+5} \qquad (i \ge 0),
$$
so $(R_0,C_0) = (3\cdot5,\,1\cdot5) = (15,5)$, $(R_1,C_1)=(8\cdot13,\,3\cdot13) = (104,39)$, $(R_2,C_2)=(21\cdot34,\,8\cdot34)=(714,272)$, $(R_3,C_3)=(55\cdot89,\,21\cdot89)=(4895,1869)$.

That these are adjacent repetitions is classical. That there are no others is the content of the Lucas classification, once the two parametrisations are identified. The identification is driven by a single classical identity.

**Theorem 8.1 (Cassini's identity).** For all $a \ge 0$, $\ F_{a+1}^2 - F_aF_{a+2} = (-1)^a$.

*Proof sketch.* Induction on $a$, expanding $F_{a+3}=F_{a+1}+F_{a+2}$ and $F_{a+2}=F_a+F_{a+1}$; the inductive step reduces to the sign flip $(-1)^{a+1} = -(-1)^a$. $\square$

**Theorem 8.2 (Lucas–Fibonacci dictionary).** For all $a\ge0$,
$$
L_{2a} = 5F_a^2 + 2(-1)^a, \qquad L_{2a+1} = 5F_aF_{a+1} + (-1)^a .
$$

*Proof sketch.* Simultaneous induction on $a$. Both statements advance together through $L_{2a+2} = L_{2a}+L_{2a+1}$ and $L_{2a+3} = L_{2a+1}+L_{2a+2}$, and the resulting algebraic identities are exactly Cassini's identity at index $a$. $\square$

**Corollary 8.3 (The family in Lucas coordinates).** For all $i \ge 0$,
$$
5R_i + 1 = L_{4i+9}, \qquad 5\,(R_i - C_i) = L_{4i+8}+3 .
$$

*Proof sketch.* For the first, put $a = 2i+4$ in the odd case of Theorem 8.2: $L_{4i+9} = 5F_{2i+4}F_{2i+5} + 1$ since $(-1)^{2i+4}=1$. For the second, note $R_i - C_i = (F_{2i+4}-F_{2i+2})F_{2i+5} = F_{2i+3}F_{2i+5}$, and Cassini at index $2i+3$ gives $F_{2i+3}F_{2i+5} = F_{2i+4}^2+1$; the even case of Theorem 8.2 with $a = 2i+4$ then yields $5F_{2i+4}^2 = L_{4i+8}-2$, so $5(R_i-C_i) = L_{4i+8}+3$. $\square$

**Theorem 8.4 (Completeness of the Fibonacci family).** For $1 \le k$ and $k+2\le n$,
$$
\binom{n}{k} = \binom{n-1}{k+1}
\iff
(n,k) = \big(F_{2i+4}F_{2i+5},\ F_{2i+2}F_{2i+5}\big) \text{ for some } i \ge 0 .
$$
Hence the complete list of adjacent repetitions in Pascal's triangle is
$$
(15,5),\quad (104,39),\quad (714,272),\quad (4895,1869),\quad \dots
$$

*Proof sketch.* Combine Theorem 7.10 with Corollary 8.3. Given a repetition, Theorem 7.10 supplies $j$ with $5n+1 = L_{4j+9}$ and $5(n-k)=L_{4j+8}+3$; Corollary 8.3 says the pair $(R_j, C_j)$ satisfies the same two equations, and these determine $n$ and $n-k$ uniquely (both are linear in $n$ and $k$ with invertible coefficient matrix over the integers, given $C_j + 2 \le R_j$). Conversely, Corollary 8.3 verifies the Lucas conditions for each $(R_i,C_i)$, so each is a repetition. $\square$

**Corollary 8.5.** The smallest adjacent repetition is $(15,5)$, giving $\binom{15}{5} = \binom{14}{6} = 3003$; combined with Theorem 7.2, every member of the family produces an integer of multiplicity at least six, and every such "extra pair" of occurrences arising from an adjacent repetition comes from this single Fibonacci family.

---

## 9. Algorithms

Three procedures are implicit in the proofs and are of independent computational value.

**Algorithm A (Exact multiplicity).** Given $t \ge 2$, list $\mathrm{Occ}(t)$: start with the boundary occurrences, then loop $n = 4, 5, \dots$ while $n(n-1) \le 2t$, and for each $n$ loop $k = 2, \dots, \lfloor n/2\rfloor$, breaking as soon as $\binom{n}{k} > t$ (the row is increasing). Correctness is Lemma 2.2 and unimodality; the loop performs $O(\sqrt{t}\log t)$ binomial evaluations.

**Algorithm B (Counting sieve for $H(X)$).** Insert into a hash set every value $\binom{n}{k} \le X$ with $2 \le k \le n/2$, looping over $n$ while $n(n-1)\le 2X$ and breaking each row when the value exceeds $X$. By Lemma 4.2 the resulting set is exactly $\{t \le X : N(t)\ge3\}$. The work is $O(\sqrt X \log X)$ big-integer comparisons.

**Algorithm C (Generation and verification of adjacent repetitions).** Generate Lucas numbers $L_{4j+8}, L_{4j+9}$ and output $n = (L_{4j+9}-1)/5$, $k = n - (L_{4j+8}+3)/5$; independently generate $R_i = F_{2i+4}F_{2i+5}$, $C_i = F_{2i+2}F_{2i+5}$. Theorem 8.4 guarantees the two streams agree termwise, and each pair satisfies $n(k+1) = (n-k)(n-k-1)$, verifiable in $O(1)$ big-integer multiplications — far cheaper than evaluating the binomial coefficients themselves, which grow doubly exponentially in $i$.

**Algorithm D (Descent certificate for the norm form).** Given $(x,y)$ with $x^2-xy-y^2=\pm5$, iterate $(x,y)\mapsto(y,x-y)$ while $x>y$, recording the sign of the form at each step; the sequence terminates at $(1,2)$ in $O(\log x)$ steps, and reading it backwards exhibits $(x,y)$ as a consecutive Lucas pair. This is a constructive form of Theorem 7.7 and runs in time linear in the number of digits.

---

## 10. Discussion and open problems

### 10.1 What the results say together

The four strands interlock. The counting theorem says repetition is rare; the smoothness hierarchy says the rare repetitive numbers are highly structured; the sharp thresholds say the structure begins late and specifically; the classification says that the one *known* infinite mechanism producing multiplicity six is a single Fibonacci family with no exceptional members.

It is worth noting how little brute force is involved. The threshold $t \ge 120$ for multiplicity six is forced by the *shape* of two interior occurrences, with only three residual numbers decided by inspection. The threshold $t \ge 3003$ for multiplicity eight reduces, after unimodality caps the deepest column at $6$ and its row at $17$, to a small explicit box. And the classification of adjacent repetitions involves no search at all: the descent on $x^2-xy-y^2=\pm5$ is unconditional.

### 10.2 Toward Singmaster's conjecture

Theorem 3.6 converts multiplicity into smoothness: $N(t)\ge 2m+2$ makes $t$ essentially $t^{1/(m+1)}$-smooth. Theorem 5.1 converts multiplicity into size: $N(t) \ge 2m+2$ forces $t \ge \binom{2m+3}{m+1} \sim 4^{m}/\sqrt{\pi m}$. The two pull in opposite directions, and a proof of boundedness plausibly lies in their collision: an integer of size $t$ all of whose prime factors are below $t^{1/(m+1)}$ needs $\Omega(t) \ge m+1$ prime factors with multiplicity, and if one can also force those prime powers to be individually small, a counting contradiction appears for large $m$.

**Conjecture 10.1.** There is an absolute constant $m_0$ such that no $t \ge 2$ satisfies $N(t) \ge 2m_0+2$; concretely, $N(t) \le 8$ for all $t \ge 2$, with equality only at $t = 3003$.

A single $t$ with nine or more representations as a binomial coefficient falsifies this.

### 10.3 The odd multiplicities

The parity decomposition (1.1) shows that $N(t)$ is even unless $t$ is a central binomial coefficient, and $t$ can be central for at most one index. Hence:

**Proposition 10.2.** If $N(t)$ is odd then $t = \binom{2c}{c}$ for a unique $c$, and $N(t) = 3 + 2\,\#\mathrm{LeftInt}(t)$.

**Conjecture 10.3.** $N(t)\notin\{5,7\}$ for every $t \ge 2$.

By Proposition 10.2, $N(t)=5$ is equivalent to: some central binomial coefficient $\binom{2c}{c}$ has exactly one further left-interior occurrence $\binom{n}{k}=\binom{2c}{c}$ with $k<c$. This is a Diophantine problem of the same species as the one solved completely in Sections 7–8, and the same template — reduce to a binary quadratic form, classify all solutions by descent, filter by congruences — is the natural line of attack. The evidence is suggestive: below $10^{6}$ the integers of odd multiplicity are precisely the central binomial coefficients $\binom{2c}{c}$ for $2 \le c \le 11$, namely $6, 20, 70, 252, 924, 3432, 12870, 48620, 184756, 705432$, and every one of them has multiplicity exactly $3$ — the central occurrence plus the boundary pair, with no further interior occurrence at all.

### 10.4 Further directions

- **Beyond adjacency.** Adjacent repetitions are the case $(\Delta n, \Delta k) = (-1,+1)$ of the coincidence $\binom{n}{k} = \binom{n-a}{k+b}$. The case $(a,b)=(1,1)$ is now completely solved; $(a,b)=(2,1)$, $(1,2)$, $(2,2)$ are the next targets and lead to different quadratic (or cubic) forms. Which of them have infinitely many solutions?
- **Uniqueness of $3003$.** Is $3003$ the only integer of multiplicity exactly $8$? By Theorem 5.3 it is the smallest, and by Theorem 7.12 it is the only value below $10^6$ arising from the adjacent mechanism; a proof of uniqueness would require ruling out coincidences among three interior columns in general.
- **Effective density.** Theorem 4.3 gives $H(X) = O(\sqrt X\log X)$, whereas the data suggest $H(X) \approx c\sqrt X$ with the $\log$ superfluous (the column-$2$ triangular numbers alone contribute $\sim\sqrt{2X}$). Removing the logarithm requires understanding coincidences between deep columns, i.e. the same Diophantine questions again.
- **Quantitative smoothness.** Corollary 3.7 bounds prime factors of highly repetitive numbers. A companion lower bound on $\Omega(t)$ — the number of prime factors needed to assemble a $t^{1/(m+1)}$-smooth integer of size $t$ — is exactly what is needed to close the loop on Conjecture 10.1.

---

## 11. Summary of the main results

1. **Multiplicity-two criterion.** $t \ge 3$ with a prime factor $p$ satisfying $p(p-1)>2t$ has $N(t)=2$. Consequently $N(cp)=2$ for every $c\ge1$ and prime $p>2c+1$, and every divisibility class contains infinitely many integers of multiplicity two.
2. **Smoothness Theorem and Hierarchy.** $N(t)\ge3$ implies $p \le \sqrt{2t}+1$ for every prime $p\mid t$; more generally $N(t) \ge 2m+2$ implies $\binom{p}{m+1}\le t$, hence $(p-m)^{m+1}\le(m+1)!\,t$. Applied to $3003$, every prime factor is at most $17$.
3. **Counting and density.** $\#\{t\le X: N(t)\ge3\} \le (\sqrt{2X}+2)(\log_2X+1)$, and the integers of multiplicity exactly two have density one.
4. **Sharp thresholds.** $6,10,120,3003$ are the least integers of multiplicity $\ge3,\ge4,\ge6,\ge8$; in general $N(t)\ge2m+2$ forces $t \ge \binom{2m+3}{m+1}$.
5. **Sharpened logarithmic bound.** $N(t)\le\log_2 t+\log_2(2\log_2 t+1)+1$, strictly better than $2\log_2 t$ for $t\ge2^{16}$.
6. **Classification of adjacent repetitions.** $\binom{n}{k}=\binom{n-1}{k+1}$ holds iff $5n+1=L_{4j+9}$ and $5(n-k)=L_{4j+8}+3$, iff $(n,k)=(F_{2i+4}F_{2i+5},F_{2i+2}F_{2i+5})$. All natural solutions of $x^2-xy-y^2=\pm5$ are consecutive Lucas pairs; Cassini's identity bridges the two parametrisations. The complete list is $(15,5),(104,39),(714,272),(4895,1869),\dots$, each producing an integer of multiplicity at least six, and only the first has value below $10^{6}$ — namely $3003$.
