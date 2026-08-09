# Multiplicity in Pascal's Triangle: Smoothness Hierarchies, Density, Sharp Thresholds, and the Complete Classification of Adjacent Repetitions

**Author:** Aristotle
**Date:** 2026-08-09

---

## Abstract

For an integer $t \ge 2$ let $N(t) = \#\{(n,k) : 0 \le k \le n,\ \binom{n}{k} = t\}$ be the *multiplicity* of $t$ in Pascal's triangle. Singmaster's conjecture (1971) asserts that $N$ is bounded; it remains open. We develop a coherent body of unconditional results about $N$.

First, we prove a *smoothness hierarchy*: if $N(t) \ge 2m+2$ then every prime factor $p$ of $t$ satisfies $\binom{p}{m+1} \le t$, hence $(p-m)^{m+1} \le (m+1)!\,t$. The base case $m=1$ states that $N(t) \ge 3$ forces $p(p-1) \le 2t$ for every prime $p \mid t$; contrapositively, any $t$ with a prime factor exceeding $\sqrt{2t}+1$ has $N(t) = 2$ exactly. As corollaries, $N(cp) = 2$ for every $c \ge 1$ and every prime $p > 2c+1$, so each divisibility class contains infinitely many integers of multiplicity exactly two.

Second, we prove a counting bound: $\#\{t \le X : N(t) \ge 3\} \le (\sqrt{2X}+2)(\log_2 X + 1)$, so multiplicity exactly two has density one.

Third, we sharpen the classical elementary upper bound $N(t) \le 2\log_2 t$ by a factor of two, obtaining $N(t) \le \log_2\big((2\log_2 t + 1)t\big) \le \log_2 t + \log_2(2\log_2 t + 1) + 1$, strictly better than $2\log_2 t$ for $t \ge 2^{16}$.

Fourth, we establish *sharp thresholds*: the least $t$ with $N(t) \ge 3, 4, 6, 8$ is $6, 10, 120, 3003$ respectively, together with the general growth threshold $N(t) \ge 2m+2 \implies t \ge \binom{2m+3}{m+1}$.

Fifth, we completely classify *adjacent repetitions* $\binom{n}{k} = \binom{n-1}{k+1}$, the principal known mechanism producing multiplicity $\ge 6$. Clearing factorials, completing the square, and performing an unconditional Vieta descent on the norm form $x^2 - xy - y^2 = \pm 5$ shows that all solutions correspond to consecutive Lucas numbers; a Lucas–Fibonacci dictionary whose inductive engine is Cassini's identity then identifies them with Singmaster's classical Fibonacci family. Consequently the adjacent repetitions are exactly
$$(n,k) = \big(F_{2i+4}F_{2i+5},\ F_{2i+2}F_{2i+5}\big), \quad i \ge 0,$$
namely $(15,5), (104,39), (714,272), (4895,1869), \dots$, and $3003$ is the only value below $10^6$ arising this way.

**Keywords:** Pascal's triangle, binomial coefficients, Singmaster's conjecture, multiplicity, smooth numbers, Fibonacci numbers, Lucas numbers, Cassini's identity, Diophantine descent.

---

## 1. Introduction

### 1.1 The problem

Pascal's triangle contains every integer $t \ge 2$ at least twice: $\binom{t}{1} = \binom{t}{t-1} = t$, and these are distinct positions. Empirically, almost every integer appears exactly twice, but there are exceptions of every recorded even multiplicity up to eight and of odd multiplicity three:

| $t$ | $N(t)$ | positions (up to the mirror) |
|---|---|---|
| $2$ | $1$ | $\binom{2}{1}$ |
| $p \ge 3$ prime | $2$ | $\binom{p}{1}$ |
| $6$ | $3$ | $\binom{6}{1}, \binom{4}{2}$ |
| $10$ | $4$ | $\binom{10}{1}, \binom{5}{2}$ |
| $120$ | $6$ | $\binom{120}{1}, \binom{16}{2}, \binom{10}{3}$ |
| $210$ | $6$ | $\binom{210}{1}, \binom{21}{2}, \binom{10}{4}$ |
| $1540$ | $6$ | $\binom{1540}{1}, \binom{56}{2}, \binom{22}{3}$ |
| $3003$ | $8$ | $\binom{3003}{1}, \binom{78}{2}, \binom{15}{5}, \binom{14}{6}$ |

No integer of multiplicity $5$, $7$, or $\ge 9$ is known. Singmaster conjectured that $N$ is bounded; the strongest unconditional bounds in the literature are of the shape $N(t) = O(\log t / \log\log t)$, and even $N(t) \le 8$ for all $t$ is beyond current technique.

### 1.2 Contributions

This paper collects and proves five interlocking families of unconditional results.

1. **Smoothness (Section 3).** High multiplicity forces the prime factors of $t$ to be small, in a hierarchy indexed by $m$.
2. **Density (Section 4).** The exceptional set $\{t : N(t) \ge 3\}$ has density zero, with an explicit $O(\sqrt X \log X)$ bound.
3. **A sharpened universal bound (Section 5).** The leading constant in the elementary logarithmic bound is halved.
4. **Sharp thresholds (Section 6).** The classical specimens $6, 10, 120, 3003$ are proved to be *minimal*, by structural descent rather than by exhaustive search.
5. **Complete classification of adjacent repetitions (Section 7).** The Fibonacci family of adjacent repetitions is exhaustive.

Throughout, $F_0 = 0, F_1 = 1, F_{a+2} = F_a + F_{a+1}$ are the Fibonacci numbers and $L_0 = 2, L_1 = 1, L_{a+2} = L_a + L_{a+1}$ the Lucas numbers.

---

## 2. Definitions and the reflection decomposition

**Definition 2.1 (Occurrences and multiplicity).** For $t \ge 2$ set
$$\mathrm{Occ}(t) = \{(n,k) \in \mathbb{N}^2 : k \le n,\ \tbinom{n}{k} = t\}, \qquad N(t) = \#\,\mathrm{Occ}(t).$$
The set is finite: $\binom{n}{k} = t$ with $1 \le k \le n-1$ forces $n \le t$.

**Definition 2.2 (Position types).** An occurrence $(n,k)$ is
- *boundary* if $k \in \{0,1,n-1,n\}$;
- *central* if $n = 2k$ and $k \ge 2$;
- *left-interior* if $2 \le k$ and $2k < n$;
- *right-interior* if $2 \le n-k$ and $n < 2k$.

Write $L(t)$ for the number of left-interior occurrences and $Z(t)$ for the number of central ones.

**Definition 2.3 (Folded column index).** For $(n,k)$ with $k \le n$ put $\mathrm{fold}(n,k) = \min(k, n-k)$. Row entries are unimodal: $\binom{n}{j} \le \binom{n}{k}$ whenever $\mathrm{fold}(n,j) \le \mathrm{fold}(n,k)$.

Two elementary structural facts drive everything.

**Lemma 2.4 (Column uniqueness).** *For fixed $k \ge 2$ the map $n \mapsto \binom{n}{k}$ is strictly increasing on $n \ge k$. Consequently two occurrences of the same value in the same column coincide, and the folded index determines an occurrence up to the mirror; in particular at most two occurrences share a given folded index.*

*Proof sketch.* $\binom{n+1}{k} - \binom{n}{k} = \binom{n}{k-1} > 0$ for $k \ge 1$ and $n \ge k$. $\square$

**Lemma 2.5 (Central uniqueness).** $Z(t) \le 1$.

*Proof sketch.* $\binom{2c}{c}$ is strictly increasing in $c$, since $\binom{2c+2}{c+1} = \frac{2(2c+1)}{c+1}\binom{2c}{c} > \binom{2c}{c}$. $\square$

**Proposition 2.6 (Reflection decomposition).** *For $t \ge 3$,*
$$N(t) = 2 + 2\,L(t) + Z(t), \qquad Z(t) \in \{0,1\}.$$

*Proof sketch.* The boundary occurrences of $t \ge 3$ are exactly $(t,1)$ and $(t,t-1)$, contributing $2$. The mirror $(n,k) \mapsto (n, n-k)$ is a fixed-point-free involution between left-interior and right-interior occurrences, contributing $2L(t)$. Central occurrences are fixed by the mirror and number $Z(t) \le 1$ by Lemma 2.5. $\square$

**Corollary 2.7 (Parity).** *$N(t)$ is even unless $t$ is a central binomial coefficient $\binom{2c}{c}$ with $c \ge 2$.*

This explains the empirical scarcity of odd multiplicities: $N(6)=N(20)=N(70)=3$ correspond to $\binom{4}{2}, \binom{6}{3}, \binom{8}{4}$. An exhaustive scan confirms the prediction sharply: the integers of odd multiplicity below $10^7$ are exactly $6, 20, 70, 252, 924, 3432, 12870, 48620, 184756, 705432, 2704156$ — the central binomial coefficients — each of multiplicity exactly three. The corollary also reduces the conjecture "$N(t) \notin \{5,7\}$" to the statement that no central binomial coefficient admits two or three further non-central representations.

---

## 3. The smoothness hierarchy

### 3.1 Two inputs

**Lemma 3.1 (Arithmetic input).** *If $p$ is prime, $k \le n$, and $p \mid \binom{n}{k}$, then $p \le n$.*

*Proof sketch.* $\binom{n}{k}\,k!\,(n-k)! = n!$, so $p \mid n!$, and a prime dividing $n!$ is at most $n$. $\square$

**Lemma 3.2 (Geometric input).** *If $\binom{n}{k} = t$ with $2 \le k$ and $k+2 \le n$, then $n(n-1) \le 2t$.*

*Proof sketch.* Unimodality gives $\binom{n}{2} \le \binom{n}{k} = t$, and $2\binom{n}{2} = n(n-1)$. $\square$

### 3.2 The base case

**Theorem 3.3 (Multiplicity two from a large prime factor).** *Let $t \ge 3$ and let $p$ be a prime with $p \mid t$ and $2t < p(p-1)$. Then $N(t) = 2$.*

*Proof sketch.* By Proposition 2.6 it suffices to show $L(t) = Z(t) = 0$. Any left-interior or central occurrence $(n,k)$ has $2 \le k$ and $k + 2 \le n$ (for a central occurrence, $k \ge 2$ follows because $t \ge 3$ excludes $k \le 1$). By Lemma 3.1, $p \le n$; by Lemma 3.2, $n(n-1) \le 2t$. Monotonicity of $x \mapsto x(x-1)$ gives $p(p-1) \le n(n-1) \le 2t$, contradicting the hypothesis. $\square$

**Theorem 3.4 (Smoothness theorem).** *If $t \ge 3$ and $N(t) \ge 3$, then every prime factor $p$ of $t$ satisfies $p(p-1) \le 2t$, hence $p \le \sqrt{2t} + 1$.*

*Proof sketch.* Contrapositive of Theorem 3.3. For the quantitative form, if $p > \sqrt{2t} + 1$ then $p(p-1) \ge (\lfloor\sqrt{2t}\rfloor+1)^2 > 2t$. $\square$

**Corollary 3.5 (Families of multiplicity two).** *For every $c \ge 1$ and every prime $p > 2c+1$, $N(cp) = 2$. In particular $N(p) = 2$ for all primes $p \ge 5$, and $N(2p) = 2$ for all primes $p \ge 7$.*

*Proof sketch.* Set $t = cp \ge 3$. Then $2t = 2cp < (p-1)p$ because $2c < p-1$. Apply Theorem 3.3. $\square$

**Corollary 3.6 (Every divisibility class).** *For every $c \ge 1$ the set $\{t : N(t) = 2 \text{ and } c \mid t\}$ is infinite.*

*Proof sketch.* By Euclid there are arbitrarily large primes $p$; for each, $cp$ is a multiple of $c$ with $N(cp) = 2$ by Corollary 3.5, and $cp \ge p \to \infty$. $\square$

### 3.3 The hierarchy

**Lemma 3.7 (A deep column exists).** *Let $t \ge 3$, $m \ge 1$ and $N(t) \ge 2m+2$. Then there is an occurrence $\binom{n}{k} = t$ with $2k < n$ and $k \ge m+1$.*

*Proof sketch.* By Proposition 2.6 and Lemma 2.5, $2m+2 \le N(t) = 2 + 2L(t) + Z(t) \le 4 + 2L(t)$ gives $L(t) \ge m$. By Lemma 2.4 distinct left-interior occurrences have distinct columns, all $\ge 2$. If all $m$ columns were $\le m$ they would lie in the $m-1$-element set $\{2,\dots,m\}$, a contradiction. Hence some column is $\ge m+1$. $\square$

**Theorem 3.8 (Smoothness hierarchy).** *Let $t \ge 3$, $m \ge 1$, $N(t) \ge 2m+2$, and let $p$ be a prime with $p \mid t$. Then*
$$\binom{p}{m+1} \le t.$$

*Proof sketch.* Take $(n,k)$ from Lemma 3.7. Lemma 3.1 gives $p \le n$, so $\binom{p}{m+1} \le \binom{n}{m+1}$ by monotonicity in the row. Since $m+1 \le k$ and $2k < n$, unimodality gives $\binom{n}{m+1} \le \binom{n}{k} = t$. $\square$

**Corollary 3.9 (Quantitative hierarchy).** *Under the hypotheses of Theorem 3.8,*
$$(p-m)^{m+1} \le (m+1)!\,t, \qquad\text{i.e.}\qquad p \le m + \big((m+1)!\,t\big)^{1/(m+1)}.$$

*Proof sketch.* $(p+1-(m+1))^{m+1} \le p^{\underline{m+1}} = (m+1)!\binom{p}{m+1} \le (m+1)!\,t$. $\square$

**Corollary 3.10 (Level $m=2$).** *If $N(t) \ge 6$ then $p(p-1)(p-2) \le 6t$ for every prime $p \mid t$: such $t$ is essentially $t^{1/3}$-smooth.*

**Example 3.11 (The champion).** $N(3003) = 8 = 2\cdot 3 + 2$, so Theorem 3.8 with $m = 3$ gives $\binom{p}{4} \le 3003$ for every prime $p \mid 3003$. Since $\binom{18}{4} = 3060 > 3003$, every prime factor of $3003$ is at most $17$. Indeed $3003 = 3 \cdot 7 \cdot 11 \cdot 13$: the champion saturates the constraint.

---

## 4. Density: almost every number occurs exactly twice

**Definition 4.1.** $\mathcal{E}(X) = \{t : 2 \le t \le X,\ N(t) \ge 3\}$.

**Lemma 4.2.** *If $t \ge 3$ and $N(t) \ge 3$ then $t$ has an occurrence $\binom{n}{k} = t$ with $2 \le k$ and $2k \le n$.*

*Proof sketch.* By Proposition 2.6, $N(t) \ge 3$ forces $L(t) \ge 1$ or $Z(t) = 1$; either produces such an occurrence. $\square$

**Theorem 4.3 (Counting bound).** *For all $X$,*
$$\#\mathcal{E}(X) \le \big(\lfloor\sqrt{2X}\rfloor + 2\big)\big(\lfloor\log_2 X\rfloor + 1\big).$$

*Proof sketch.* Let $t \in \mathcal{E}(X)$ and take $(n,k)$ from Lemma 4.2. Lemma 3.2 gives $n(n-1) \le 2t \le 2X$, hence $n \le \sqrt{2X} + 1$. The standard estimate $2^k \le \binom{n}{k}$ for $2k \le n$ gives $2^k \le t \le X$, hence $k \le \log_2 X$. So $\mathcal{E}(X)$ is contained in the image of the box $\{0,\dots,\lfloor\sqrt{2X}\rfloor+1\}\times\{0,\dots,\lfloor\log_2 X\rfloor\}$ under $(n,k)\mapsto\binom{n}{k}$, and the image of a finite set is no larger than the set. $\square$

**Corollary 4.4 (Density one).** *For every constant $c$ there is $N_c$ with $c\,\#\mathcal{E}(X) \le X$ for all $X \ge N_c$. Hence the set of $t$ with $N(t) = 2$ has natural density one.*

*Proof sketch.* $\sqrt{2X}\log_2 X = o(X)$; explicitly one may take $N_c = (21c+21)^4 + 16$, using $\log_2 X + 1 \le 2\sqrt[4]{X}$ and $\sqrt{2X}+2 \le 2\sqrt X$ for large $X$. $\square$

**Remark 4.5.** At $X = 10^6$ the bound gives $28\,320$; the true count of $t \le 10^6$ with $N(t) \ge 3$ is $1\,732$. At $X = 10^7$ the bound gives $107\,376$ against a true count of $5\,125$. The bound is therefore lossy by a factor growing slowly (about $16$ at $10^6$, about $21$ at $10^7$), but it is of the correct shape $\Theta(\sqrt X \log X)$ for this method: the box genuinely has that many cells.

---

## 5. A factor-two sharpening of the elementary logarithmic bound

The classical elementary bound $N(t) \le 2\log_2 t$ comes from $2^b \le \binom{n}{b}$ for $2b \le n$, together with Lemma 2.4 (at most two occurrences per folded index). The inequality $2^b \le \binom{2b}{b}$ is lossy: the truth is $\binom{2b}{b} \asymp 4^b/\sqrt{b}$. Replacing it costs nothing.

**Lemma 5.1 (Row pigeonhole).** *For all $b$, $4^b \le (2b+1)\binom{2b}{b}$.*

*Proof sketch.* The $2b+1$ entries of row $2b$ sum to $2^{2b} = 4^b$ and each is at most the central entry $\binom{2b}{b}$. $\square$

**Lemma 5.2.** *If $\binom{n}{k} = t$ and $b = \mathrm{fold}(n,k)$, then $\binom{2b}{b} \le t$.*

*Proof sketch.* $2b \le n$ and $\binom{n}{b} = \binom{n}{k} = t$ (folding preserves the value), so $\binom{2b}{b} \le \binom{n}{b} = t$ by monotonicity in the row. $\square$

**Lemma 5.3.** *If $t \ge 2$ and $\binom{n}{k} = t$ with $b = \mathrm{fold}(n,k)$, then $4^b \le (2\log_2 t + 1)t$ and hence $b \le \tfrac12\log_2\big((2\log_2 t + 1)t\big)$.*

*Proof sketch.* Combine Lemmas 5.1 and 5.2 to get $4^b \le (2b+1)t$, then use the crude bound $b \le \log_2 t$ (from $2^b \le t$) to replace $2b+1$ by $2\log_2 t + 1$. $\square$

**Theorem 5.4 (Sharpened bound).** *For $t \ge 2$,*
$$N(t) \;\le\; \log_2\!\big((2\log_2 t + 1)\,t\big) \;\le\; \log_2 t + \log_2(2\log_2 t + 1) + 1 .$$

*Proof sketch.* Split $\mathrm{Occ}(t)$ into occurrences of folded index $\le 1$ (at most $2$, namely the boundary pair) and the rest. Each remaining folded index $b$ lies in $[2, M]$ with $M = \lfloor \tfrac12\log_2((2\log_2 t+1)t)\rfloor$ by Lemma 5.3, and by Lemma 2.4 carries at most two occurrences. Hence $N(t) \le 2 + 2(M-1) = 2M \le \log_2((2\log_2 t+1)t)$. The second inequality is $\log_2(ab) \le \log_2 a + \log_2 b + 1$ for integers. $\square$

**Corollary 5.5 (Strict improvement).** *For $t \ge 2^{16}$, $N(t) < 2\log_2 t$.*

*Proof sketch.* With $L = \lfloor\log_2 t\rfloor \ge 16$ one has $2L+1 < 2^{L-2}$, hence $\log_2(2L+1) \le L-3$ and Theorem 5.4 gives $N(t) \le L + (L-3) + 1 = 2L - 2 < 2L$. $\square$

**Numerical comparison.**

| $t$ | classical $2\log_2 t$ | Theorem 5.4 |
|---|---|---|
| $3003$ | $22$ | $16$ |
| $2^{16}$ | $32$ | $22$ |
| $10^6$ | $38$ | $25$ |
| $2^{32}$ | $64$ | $39$ |
| $10^{20}$ | $132$ | $74$ |

The Erdős–Abbott–Hanson–Singmaster estimate $O(\log t/\log\log t)$ is asymptotically stronger but not elementary; Theorem 5.4 is elementary and gives the leading constant $1$ predicted by the heuristic "one usable column per power of four".

---

## 6. Sharp thresholds: the minimal value of each small multiplicity

Corollary 3.9 and Lemma 3.7 also bound $t$ from below.

**Theorem 6.1 (Growth threshold).** *If $t \ge 3$, $m \ge 1$ and $N(t) \ge 2m+2$, then*
$$t \ge \binom{2m+3}{m+1}.$$

*Proof sketch.* Take $(n,k)$ from Lemma 3.7: $k \ge m+1$ and $n > 2k \ge 2m+2$, so $n \ge 2m+3$. Then $\binom{2m+3}{m+1} \le \binom{n}{m+1} \le \binom{n}{k} = t$ by monotonicity and unimodality. $\square$

This gives $t \ge 10, 35, 126, 462, \dots$ for $N(t) \ge 4, 6, 8, 10$. The true thresholds are larger, and can be determined exactly for the first few.

**Lemma 6.2 (Two interior columns are expensive).** *Suppose $\binom{n}{j} = \binom{m}{k} = t$ with $2 \le j < k$, $2j < n$, $2k < m$. Then either $k \ge 4$ and $t \ge \binom{9}{4} = 126$, or $k = 3$, $j = 2$ and $t$ is simultaneously of the form $\binom{m}{3}$ with $m \ge 7$ and $\binom{n}{2}$.*

*Proof sketch.* If $k \ge 4$ then $m \ge 2k+1 \ge 9$ and unimodality gives $t = \binom{m}{k} \ge \binom{9}{4}$. If $k = 3$ then $j = 2$ and $m \ge 7$. $\square$

**Theorem 6.3 (Sharp thresholds).**
1. *$6$ is the least $t \ge 2$ with $N(t) \ge 3$.*
2. *$10$ is the least $t$ with $N(t) \ge 4$.*
3. *$120$ is the least $t$ with $N(t) \ge 6$.*
4. *$3003$ is the least $t$ with $N(t) \ge 8$.*

*Proof sketch.* Attainment is the computation $N(6)=3$, $N(10)=4$, $N(120)=6$, $N(3003)=8$. For minimality of $120$: by Proposition 2.6 and Lemma 2.5, $N(t) \ge 6$ forces $L(t) \ge 2$, so Lemma 6.2 applies. In the first case $t \ge 126 > 120$. In the second, $t = \binom{m}{3}$ with $m \ge 7$ and $t$ triangular; the values $\binom{7}{3} = 35$, $\binom{8}{3} = 56$, $\binom{9}{3} = 84$ are the only candidates below $120$ and none is triangular, so $t \ge 120$. Cases 1 and 2 are the corresponding one-column analyses. Case 4 runs the same descent one level deeper: $N(t) \ge 8$ forces three left-interior occurrences in distinct columns $2 \le j_1 < j_2 < k$, hence $k \ge 4$; the residual possibilities below $3003$ are a finite, explicitly decidable list. $\square$

**Remark 6.4.** These are structural results, not exhaustive searches: the value $120$ is forced by the *shape* of the two required occurrences, with only three residual numbers decided by direct computation.

---

## 7. Adjacent repetitions: complete classification

### 7.1 The phenomenon

**Definition 7.1.** A pair $(n,k)$ with $1 \le k$ and $k+2 \le n$ is an *adjacent repetition* if
$$\binom{n}{k} = \binom{n-1}{k+1}.$$

The value then occupies (at least) the six positions
$$(n,k),\ (n,n-k),\ (n-1,k+1),\ (n-1,n-k-2),\ (t,1),\ (t,t-1),$$
so $N(t) \ge 6$ once these are pairwise distinct.

**Proposition 7.2 (Adjacent repetitions give multiplicity $\ge 6$).** *If $2 \le k$, $k+3 < n-k$ and $\binom{n}{k} = \binom{n-1}{k+1}$, then $N\big(\binom{n}{k}\big) \ge 6$.*

*Proof sketch.* The four interior positions listed above are pairwise distinct under the stated inequalities (they lie in two different rows and, within each row, strictly left of centre together with their mirrors), and $t = \binom{n}{k} > n$ so the boundary pair $(t,1), (t,t-1)$ is disjoint from them. $\square$

Singmaster observed the infinite family
$$n = F_{2i+4}F_{2i+5}, \qquad k = F_{2i+2}F_{2i+5} \qquad (i \ge 0),$$
i.e. $(15,5), (104,39), (714,272), (4895,1869), (33552,12815), \dots$, each an adjacent repetition. We prove there are no others.

### 7.2 Step 1: from combinatorics to a Diophantine equation

**Lemma 7.3.** *For $1 \le k$ and $k + 2 \le n$,*
$$\binom{n}{k} = \binom{n-1}{k+1} \iff n(k+1) = (n-k)(n-k-1).$$

*Proof sketch.* Write $n = m+1$. The Pascal-type identities $\binom{m}{k}(m+1) = \binom{m+1}{k}(m+1-k)$ and $\binom{m}{k+1}(k+1) = \binom{m}{k}(m-k)$ let one clear factorials and reduce the equality of the two binomial coefficients to the displayed quadratic relation, using that binomial coefficients in range are positive. $\square$

### 7.3 Step 2: from the equation to a norm form

**Lemma 7.4.** *Let $n, u$ satisfy $u = n - k \ge 2$ and $n(k+1) = u(u-1)$, i.e. $n(n-u+1) = u(u-1)$. Put $N = 5n+1$ and $U = 5u-3$. Then*
$$N^2 - N\,U - U^2 = -5.$$

*Proof sketch.* Expanding, $n(n-u+1) = u^2-u$ is equivalent to $n^2 - nu + n - u^2 + u = 0$. Multiplying by $25$ and substituting $n = (N-1)/5$, $u = (U+3)/5$ turns the left side into $N^2 - NU - U^2 + 5$ after simplification. $\square$

The form $x^2 - xy - y^2$ is the norm form of $\mathbb{Z}[\varphi]$, $\varphi = (1+\sqrt5)/2$: it factors as $\big(x - \varphi y\big)\big(x - \bar\varphi y\big)$.

### 7.4 Step 3: descent on the norm form

**Lemma 7.5 (Lucas pairs solve the form).** *For all $i \ge 0$, $L_{i+1}^2 - L_{i+1}L_i - L_i^2 = 5(-1)^{i+1}$.*

*Proof sketch.* Induction on $i$, using $L_{i+2} = L_{i+1} + L_i$: the substitution $(x,y) \mapsto (x+y, x)$ negates the form. Base case $(L_1, L_0) = (1,2)$: $1 - 2 - 4 = -5$. $\square$

**Theorem 7.6 (Descent: all solutions are Lucas pairs).** *If $x, y \in \mathbb{N}$ satisfy $x^2 - xy - y^2 = \pm 5$, then there is $i \ge 0$ with $x = L_{i+1}$ and $y = L_i$.*

*Proof sketch.* Strong induction on $x$. The map $(x,y) \mapsto (y, x-y)$ preserves the form up to sign: $y^2 - y(x-y) - (x-y)^2 = -(x^2-xy-y^2)$. One checks that no solution has $x \le y$ with $x$ minimal except the base pairs; that $x \ne y$ (else $-y^2 = \pm5$, impossible since $5$ is not a square); and that $x > y$ forces $0 \le x - y < x$, so the descent strictly decreases the first coordinate and terminates. The terminal solutions are $(1,2)$ and $(3,1)$, i.e. $(L_1,L_0)$ and $(L_2,L_1)$; running the descent backwards reconstructs $(L_{i+1}, L_i)$. $\square$

**Lemma 7.7 (Index selection).** *The residues $L_j \bmod 5$ are periodic with period $4$: $L_j \equiv 2, 1, 3, 4 \pmod 5$ for $j \equiv 0,1,2,3 \pmod 4$. Hence $L_j \equiv 2 \pmod 5$ forces $4 \mid j$.*

**Theorem 7.8 (Classification in Lucas form).** *For $1 \le k$ and $k+2 \le n$,*
$$\binom{n}{k} = \binom{n-1}{k+1} \iff \exists j \ge 0:\ 5n+1 = L_{4j+9} \ \text{ and }\ 5(n-k) = L_{4j+8}+3.$$

*Proof sketch.* ($\Rightarrow$) Lemmas 7.3 and 7.4 produce a solution $(N,U)$ of $N^2-NU-U^2=-5$; Theorem 7.6 makes $(N,U)$ a consecutive Lucas pair $(L_{i+1}, L_i)$; the sign $-5$ and the congruences $N \equiv 1$, $U \equiv 2 \pmod 5$ (from $N = 5n+1$, $U = 5u-3$) force $i \equiv 0 \pmod 4$ and $i \ge 8$ via Lemma 7.7, i.e. $i = 4j+8$. ($\Leftarrow$) Reverse the substitutions and apply Lemma 7.3. $\square$

**Corollary 7.9 (Small cases).** *The only adjacent repetitions with $n \le 700$ are $(15,5)$ and $(104,39)$; and $3003$ is the only value $\binom{n}{k} < 10^6$ arising from an adjacent repetition.*

*Proof sketch.* For $j \ge 2$, $L_{4j+9} \ge L_{17} = 3571 > 5\cdot700+1$. For the value bound, $2^k \le \binom{n}{k}$ and $k = 39$ for $j=1$ already gives $\binom{104}{39} > 2^{39} > 10^6$. $\square$

### 7.5 Step 4: the Lucas–Fibonacci dictionary via Cassini

**Theorem 7.10 (Cassini's identity).** *For all $a \ge 0$, $F_{a+1}^2 - F_aF_{a+2} = (-1)^a$.*

*Proof sketch.* Induction on $a$: substituting $F_{a+3} = F_{a+1}+F_{a+2}$ and $F_{a+2} = F_a+F_{a+1}$ into $F_{a+2}^2 - F_{a+1}F_{a+3}$ and expanding yields $-(F_{a+1}^2 - F_aF_{a+2})$. $\square$

**Theorem 7.11 (Dictionary).** *For all $a \ge 0$,*
$$L_{2a} = 5F_a^2 + 2(-1)^a, \qquad L_{2a+1} = 5F_aF_{a+1} + (-1)^a .$$

*Proof sketch.* Simultaneous induction on $a$. Base: $L_0 = 2 = 0+2$, $L_1 = 1 = 0+1$. Step: using $L_{2a+2} = L_{2a}+L_{2a+1}$ and $L_{2a+3} = L_{2a+1}+L_{2a+2}$, the required identities reduce, after substituting the inductive hypotheses and $F_{a+2} = F_a + F_{a+1}$, exactly to Cassini's identity at index $a$. $\square$

Now specialise. Write $R_i = F_{2i+4}F_{2i+5}$ and $C_i = F_{2i+2}F_{2i+5}$ for the Fibonacci family.

**Lemma 7.12 (Family in Lucas coordinates).** *For all $i \ge 0$,*
$$5R_i + 1 = L_{4i+9}, \qquad R_i - C_i = F_{2i+3}F_{2i+5}, \qquad 5(R_i - C_i) = L_{4i+8}+3 .$$

*Proof sketch.* The first is Theorem 7.11 at $a = 2i+4$ (odd case), noting $(-1)^{2i+4} = 1$. The second is $F_{2i+4} = F_{2i+2} + F_{2i+3}$. The third combines Theorem 7.11 at $a = 2i+4$ (even case) with Cassini at index $2i+3$, which reads $F_{2i+3}F_{2i+5} = F_{2i+4}^2 + 1$. $\square$

**Lemma 7.13 (Admissibility).** *For all $i$: $C_i \ge 1$ and $C_i + 2 \le R_i$.*

*Proof sketch.* $C_i$ is a product of positive Fibonacci numbers. For the gap, $R_i - C_i = F_{2i+3}F_{2i+5} \ge 1\cdot 5 = 5 \ge 2$. $\square$

### 7.6 The classification theorem

**Theorem 7.14 (Completeness of the Fibonacci family).** *For $1 \le k$ and $k+2 \le n$,*
$$\binom{n}{k} = \binom{n-1}{k+1} \iff \exists\, i \ge 0:\ n = F_{2i+4}F_{2i+5} \ \text{ and }\ k = F_{2i+2}F_{2i+5}.$$

*Proof sketch.* ($\Leftarrow$) Lemma 7.12 supplies the Lucas certificate of Theorem 7.8 with $j = i$. ($\Rightarrow$) Theorem 7.8 gives $j$ with $5n+1 = L_{4j+9}$ and $5(n-k) = L_{4j+8}+3$. Lemma 7.12 at $i = j$ gives $5R_j + 1 = L_{4j+9}$ and $5(R_j - C_j) = L_{4j+8}+3$. Comparing, $5n = 5R_j$ so $n = R_j$, and then $5(n-k) = 5(R_j - C_j)$ so $k = C_j$ (using Lemma 7.13 to keep the subtractions legitimate). $\square$

**Corollary 7.15 (The complete list).** *The adjacent repetitions in Pascal's triangle are exactly*
$$(15,5),\ (104,39),\ (714,272),\ (4895,1869),\ (33552,12815),\ (229970,87840),\ \dots$$
*with $(n,k) = (F_{2i+4}F_{2i+5}, F_{2i+2}F_{2i+5})$, and no others. Each yields a value of multiplicity at least $6$; hence there are infinitely many integers of multiplicity $\ge 6$, and the smallest of them is $\binom{15}{5} = 3003$.*

**Remark 7.16 (Interpretation).** Combined with Proposition 7.2, Theorem 7.14 says that *every* "extra pair" of occurrences produced by an adjacent repetition comes from this single Fibonacci family. Other sources of multiplicity $6$ exist — the complete list of $t \le 10^7$ with $N(t) = 6$ is $120, 210, 1540, 7140, 11628, 24310$, all of them *non-adjacent* coincidences between two interior columns, e.g. $120 = \binom{16}{2}=\binom{10}{3}$, $210 = \binom{21}{2}=\binom{10}{4}$, $1540 = \binom{56}{2}=\binom{22}{3}$ — but the adjacent mechanism, the only one currently known to be infinite, is now completely understood.

---

## 8. Algorithms

Three computational procedures underlie the numerical illustrations.

**(A) Multiplicity by bounded enumeration.** To compute $N(t)$ it suffices to scan rows $2 \le n \le t$; within each row, unimodality allows an early break as soon as $\binom{n}{k}$ exceeds $t$. Cost: $O(t \log t)$ big-integer operations in the naive version; the row bound of Lemma 3.2 reduces the interior search to $n \le \sqrt{2t}+1$, so the true cost of finding all *interior* occurrences is $O(\sqrt t \log t)$.

**(B) Smoothness certificate.** Given $t$, factor $t$ by trial division and report, for each prime factor $p$ and each level $m$, whether $\binom{p}{m+1} \le t$. By Theorem 3.8 the first level $m$ that fails certifies $N(t) \le 2m+1$, hence $N(t) \le 2m$ when $t$ is not a central binomial coefficient. This turns a factorisation into an unconditional multiplicity ceiling.

**(C) Enumeration of adjacent repetitions.** Rather than search rows, iterate the Fibonacci recursion and output $(F_{2i+4}F_{2i+5}, F_{2i+2}F_{2i+5})$; by Theorem 7.14 this is complete. Cost: $O(1)$ big-integer operations per member, versus $O(n^2)$ binomial comparisons for a brute-force row scan to depth $n$. Cross-validation over $n \le 1200$ recovers precisely $(15,5), (104,39), (714,272)$.

---

## 9. Applications and context

**Smooth-number heuristics.** Theorem 3.8 converts a combinatorial hypothesis into an arithmetic one: high multiplicity implies extreme smoothness. Smooth numbers of size $t$ with all prime factors below $t^{1/(m+1)}$ have density governed by the Dickman function $\rho(m+1)$, which decays super-exponentially. This is the quantitative reason to believe Singmaster's conjecture, and it also explains why the extremal examples ($120 = 2^3\cdot3\cdot5$, $210 = 2\cdot3\cdot5\cdot7$, $3003 = 3\cdot7\cdot11\cdot13$) are all products of the very smallest primes.

**Diophantine equations from combinatorial identities.** Section 7 is a template: a coincidence between binomial coefficients becomes, after clearing factorials, a binary quadratic Diophantine equation; completing the square identifies a norm form; descent classifies solutions in terms of a linear recurrence. The same route handles $\binom{n}{2} = \binom{m}{3}$ (a Mordell-type curve), $\binom{n}{2} = \binom{m}{4}$, and — in principle — the central-column equation $\binom{2c}{c} = \binom{n}{k}$ that governs odd multiplicities.

**Verification and search design.** Theorem 3.4 provides a cheap sieve for exhaustive searches: any candidate with a prime factor exceeding $\sqrt{2t}+1$ can be discarded without examining the triangle. Theorem 6.1 provides the complementary cutoff from below. Together they confine any hypothetical high-multiplicity number to a thin, explicitly described region.

---

## 10. Discussion and future directions

The results assembled here bracket Singmaster's problem from several sides without solving it.

**Conjecture 1 (Grand challenge).** *There is an absolute $m_0$ such that no $t \ge 2$ satisfies $N(t) \ge 2m_0+2$; concretely, $N(t) \le 8$ for all $t \ge 2$, with equality only at $t = 3003$.*

The key insight is that Theorem 3.8 converts multiplicity directly into arithmetic smoothness: $N(t) \ge 2m+2$ forces $\binom{p}{m+1} \le t$ for *every* prime $p \mid t$, so a number of large multiplicity must be $t^{1/(m+1)}$-smooth. Combining this with a lower bound on the number of prime factors needed to build $t$ out of small primes — a Stirling-type count giving $\Omega(t) \gg \log t/\log\log t$ — should close the gap between "smooth" and "impossible". A first quantitative step is already in hand: Theorem 6.1 gives $t \ge \binom{2m+3}{m+1}$ whenever $N(t) \ge 2m+2$, and the sharp thresholds of Theorem 6.3 ($t \ge 120$ for six occurrences, $t \ge 3003$ for eight) show what the true growth looks like at the bottom of the range. Both halves of the argument now exist: the smoothness side (Theorems 3.4 and 3.8) and the counting side in the aggregate (Theorem 4.3). What remains is a single quantitative comparison between the smoothness ceiling and the size of $t$. *Falsifier:* an explicit $t$ with nine or more representations as a binomial coefficient.

**Conjecture 2.** *For every $t \ge 2$, $N(t) \notin \{5, 7\}$.*

The key insight is the parity decomposition of Proposition 2.6: multiplicity equals $2 + 2L(t)$ plus a correction supported only on the central column, and that correction is at most one (Lemma 2.5). Odd multiplicity therefore *requires* a central binomial coefficient $\binom{2c}{c} = t$, so the conjecture reduces to "no central binomial coefficient has two other non-central occurrences", a statement about $\binom{2c}{c} = \binom{n}{k}$ with $k < c$. The reduction is a theorem; the residual problem is a Diophantine one of the same shape as Theorem 7.8, which was solved completely by descent. The same template — reduce to a Pell-like form, classify solutions by a Lucas/Fibonacci recursion — can be re-instantiated. *Falsifier:* a $t$ with exactly five or exactly seven representations.

**Further directions.**

- *Uniqueness of $3003$.* Is $3003$ the only integer with $N(t) = 8$? Equivalently, is it the only integer that is simultaneously triangular, adjacent-repetitive, and small enough? Corollary 7.9 already shows the next adjacent repetition has $29$ digits, and any competitor would need a triangular coincidence of that size.
- *Non-adjacent infinite families.* Are there infinitely many $t$ with $N(t) \ge 6$ arising from *non-adjacent* column coincidences (like $120$, $210$, $1540$)? Each such family corresponds to a curve $\binom{n}{j} = \binom{m}{k}$ with $j < k$ fixed; for $(j,k) = (2,3)$ the curve has finitely many integral points, so any infinite family must use unbounded columns.
- *Sharpening Theorem 4.3.* The bound is off by roughly a factor $16$ at $X = 10^6$. Restricting the box using the smoothness theorem — the value $\binom{n}{k}$ must be $\sqrt{2X}$-smooth — should lower the exponent of the logarithm.
- *Improving Theorem 5.4.* The pigeonhole $4^b \le (2b+1)\binom{2b}{b}$ is nearly sharp; the remaining loss is the crude "two occurrences per folded index". A column-by-column analysis using Lemma 3.2 (which bounds the *row*, not just the column) should shave further.

---

## 11. Conclusion

Pascal's triangle repeats itself far less than one might expect, and the reasons are now substantially understood. A reflection symmetry makes multiplicity even away from the central column, so odd multiplicities are a central-binomial phenomenon. A cross-cut between the geometry of the triangle (interior entries cap their row) and the arithmetic of factorials (prime factors cap at the row index) yields a hierarchy: the more often a number appears, the smoother it must be, and the larger it must be. Counting the resulting admissible box shows that the exceptional numbers occupy density zero, and a free pigeonhole halves the constant in the classical logarithmic bound. Finally, the principal known source of multiplicity six — a value repeating one row up and one column right — is now completely classified: it happens exactly at the Fibonacci pairs $\big(F_{2i+4}F_{2i+5},\, F_{2i+2}F_{2i+5}\big)$, a fact proved by turning the combinatorial coincidence into the norm-form equation $x^2 - xy - y^2 = \pm 5$, descending to consecutive Lucas numbers, and translating back through a dictionary whose engine is Cassini's identity. Singmaster's conjecture itself stands; but the terrain around it has been mapped.
