# Stack Polyominoes with a Square Core: Structure, Regularity, and Stretched-Exponential Growth

**Author:** Aristotle
**Date:** 2026-08-26

---

## Abstract

A *stack polyomino* is a bottom-justified, column-convex polyomino whose column-height profile is unimodal. Its *core* is the maximal plateau; the stack has a **square core** when that plateau consists of exactly $k$ columns of common height $k$, so the crown of the shape is a $k \times k$ square. Let $a(n)$ denote the number of square-core stacks of area $n$.

We give a complete structural analysis of $a$. A slicing of each stack into (left slope) $\Vert$ ($k\times k$ core) $\Vert$ (right slope) yields the exact layer decomposition
$$a(n) = \sum_{k^2 \le n}\ \sum_{i+j = n-k^2} p_{\le k-1}(i)\,p_{\le k-1}(j),$$
where $p_{\le b}$ counts partitions with parts of size at most $b$; equivalently
$$\sum_{n\ge0} a(n)x^n = \sum_{k\ge0} \frac{x^{k^2}}{\prod_{i=1}^{k-1}(1-x^i)^2}.$$
The decomposition is proved to be a bijection onto genuine unimodal column-height lists, so the arithmetic and the geometry agree exactly.

From this we derive: the exact vanishing set $\{n : a(n)=0\} = \{2,3\}$; the linear lower bound $a(n) \ge n-3$ for $n\ge4$; strict monotonicity from $n=4$; convexity $2a(n+1)\le a(n)+a(n+2)$ for $n\ge2$, obtained from an exact difference identity for self-convolutions; divergence of the increments; and two sharp negative results, namely the failure of log-concavity ($a(8)^2 = 25 < 28 = a(7)a(9)$) and the failure of third-order convexity ($a(10)+3a(8)=24 < 25 = 3a(9)+a(7)$). The latter is explained by an exact closed form for the third core layer: writing $c_2(m)$ for its contribution, $24\,c_2(2s) = (2s+2)(2s+3)(2s+4)$ and $24\,c_2(2s+1) = (2s+2)(2s+4)(2s+6)$, whence the third forward differences are $-(t+2)$ at even arguments and $+(t+3)$ at odd ones — an infinite, linearly growing family of violations.

Finally we pin down the order of growth. An elementary Rankin-type bound gives $\log p_{\le b}(m) \le 8\sqrt m + 12$, *uniformly in the part bound $b$*; combined with an exponential lower bound obtained from a single core layer, this yields
$$\tfrac{1}{2}(\sqrt n - 2)\log 2 \ \le\ \log a(n)\ \le\ 30\sqrt n \qquad (n \ge 100),$$
so $\log a(n) \asymp \sqrt n$. Consequently $a$ is superpolynomial yet subexponential and the entropy density satisfies $\log a(n)/n \to 0$: in the interface-model reading, square-core stacks carry no extensive entropy, in sharp contrast with general polyominoes. Numerics indicate the true constant is the Hardy–Ramanujan constant $\pi\sqrt{2/3}$, and we explain the saddle-point mechanism responsible.

**Keywords:** stack polyomino, unimodal composition, Durfee square, bounded partitions, Euler product, stretched exponential, entropy density, quasi-polynomial, convexity, Hardy–Ramanujan.

---

## 1. Introduction

### 1.1 The objects

A **polyomino** is a finite edge-connected set of unit cells in $\mathbb{Z}^2$. Two natural restrictions produce families that can actually be counted: *column-convexity* (every column of the shape is a contiguous run of cells) and *bottom-justification* (every column starts at height $0$). A bottom-justified column-convex polyomino is determined completely by its list of column heights
$$L = (h_1, h_2, \dots, h_r), \qquad h_i \ge 1 .$$

A **stack polyomino** is such a shape whose profile is **unimodal**: there is an index at which $L$ stops weakly increasing and begins weakly decreasing. Formally, $L = P \Vert S$ where $P$ is weakly increasing and $S$ is weakly decreasing. The **area** is $|L| = h_1 + \dots + h_r$.

Let $k = \max_i h_i$ be the height of the summit. The **core** of the stack is the maximal plateau, i.e. the set of columns of height exactly $k$; by unimodality these columns are consecutive. We say the stack has a **square core** when
$$\#\{i : h_i = k\} = k,$$
so the plateau is a $k \times k$ square block.

**Definition 1.1 (the counting function).** $a(n)$ is the number of column-height lists $L$ with $|L| = n$, all entries $\ge 1$, $L$ unimodal, and $\#\{i : h_i = \max L\} = \max L$. By convention the empty list, of area $0$, is included, so $a(0)=1$.

The first thirty-two values are
$$1,1,0,0,1,2,3,4,5,7,9,13,17,24,31,42,54,71,90,117,147,188,236,298,371,466,576,716,882,1088,1331,1633 .$$

### 1.2 Why the family is interesting

Three separate motivations converge here.

*Combinatorial.* The square-core condition is equivalent, after slicing, to a *ceiling* on the parts of the two slope partitions. The resulting generating function is a near-miss of the classical Durfee-square identity for the partition function, and the comparison is illuminating in both directions.

*Statistical-mechanical.* Rotated ninety degrees, a stack polyomino is a discrete interface with a single hump: a solid-on-solid profile constrained to be unimodal. The area is the particle number, and $\log a(n)$ is the microcanonical entropy. The central quantitative question — what is the growth order of $\log a(n)$? — is the question of whether the model has extensive entropy.

*Analytic.* The answer, $\log a(n) \asymp \sqrt n$, places the family squarely in the *stretched-exponential* regime, the same regime as the partition function, and raises the question of the precise constant.

### 1.3 Summary of results

| | Statement | Reference |
|---|---|---|
| Structure | $a(n)=\sum_{k^2\le n}\sum_{i+j=n-k^2}p_{\le k-1}(i)p_{\le k-1}(j)$, a bijection | Thm 3.4, 3.5 |
| Generating function | $\sum a(n)x^n = \sum_k x^{k^2}\prod_{i<k}(1-x^i)^{-2}$ | Thm 4.3 |
| Vanishing set | $a(n)=0 \iff n \in \{2,3\}$ | Thm 5.2 |
| Growth, elementary | $a(n)\ge n-3$; $a(n)<a(n+1)$ for $n\ge4$ | Thm 5.1, 5.3 |
| Convexity | $2a(n+1)\le a(n)+a(n+2)$ for $n\ge2$; increments $\to\infty$ | Thm 6.3, 6.5 |
| Sharpness | not log-concave; not $3$-convex | Thm 6.6, 7.4 |
| Third layer | exact cubic quasi-polynomial of period $2$ | Thm 7.1 |
| Growth order | $\tfrac12(\sqrt n-2)\log2 \le \log a(n)\le 30\sqrt n$ for $n\ge100$ | Thm 8.6 |
| Entropy | $\log a(n)/n \to 0$; $a$ superpolynomial | Thm 8.7, 8.8 |

---

## 2. Bounded partitions

Throughout, $p_{\le b}(m)$ denotes the number of partitions of $m$ into parts of size at most $b$, with $p_{\le b}(0)=1$ and $p_{\le 0}(m) = [\,m=0\,]$.

**Definition 2.1.** Recursively, choosing the multiplicity $c$ of the largest allowed part,
$$p_{\le b+1}(m) = \sum_{c=0}^{\lfloor m/(b+1)\rfloor} p_{\le b}\bigl(m - c(b+1)\bigr).$$

That this recursion counts the intended objects is not a definition but a theorem: one exhibits explicitly, for each $b$ and $m$, the finite set of weakly decreasing lists of integers in $[1,b]$ summing to $m$, and shows both that membership in it is exactly the stated condition and that its cardinality obeys the recursion. The key structural step is that a weakly decreasing list bounded by $b+1$ splits uniquely as a block of copies of $b+1$ followed by a list bounded by $b$.

**Proposition 2.2 (Euler's recurrence).** For $b+1 \le m$,
$$p_{\le b+1}(m) = p_{\le b}(m) + p_{\le b+1}\bigl(m-(b+1)\bigr),$$
while $p_{\le b+1}(m) = p_{\le b}(m)$ for $m < b+1$.

*Proof sketch.* Split the sum of Definition 2.1 according to whether $c=0$ (the part $b+1$ is unused, giving $p_{\le b}(m)$) or $c \ge 1$ (remove one copy of $b+1$ and reindex). $\square$

**Proposition 2.3 (elementary bounds).**
1. $p_{\le b}(m) \le p_{\le b+1}(m)$ for all $b,m$, and $p_{\le b}(\cdot)$ is non-decreasing for $b \ge 1$.
2. $p_{\le b}(m) \le (m+1)^{b-1}$ for $b \ge 1$.
3. $2^{\,b} \le p_{\le b+1}(m)$ whenever $b(b+3) \le 2m$.

*Proof sketch.* (1) The $c=0$ term of Definition 2.1 already contributes $p_{\le b}(m)$; monotonicity in $m$ follows by strong induction from Proposition 2.2. (2) Each of the $\lfloor m/(b+1)\rfloor + 1 \le m+1$ summands is at most $(m+1)^{b-1}$ by induction. (3) Induct on $b$: if $b+2 \le m$, Proposition 2.2 gives $p_{\le b+1}(m) = p_{\le b}(m) + p_{\le b+1}(m - (b+2)+1)$-type splittings whose two summands each dominate $2^{\,b-1}$ by the inductive hypothesis (the hypothesis $b(b+3)\le 2m$ is exactly what guarantees room for both). Doubling at every step gives $2^{\,b}$. $\square$

Part (3) is the engine of the lower bound in Section 8. Its content is that once the area $m$ is quadratically large compared with the part ceiling, each increment of the ceiling doubles the number of partitions.

---

## 3. The core decomposition

**Definition 3.1 (slope convolution).** For $b,m \ge 0$,
$$c_b(m) := \sum_{i+j = m} p_{\le b}(i)\,p_{\le b}(j) = \sum_{j=0}^{m} p_{\le b}(j)\,p_{\le b}(m-j).$$

Thus $c_0(m) = [\,m = 0\,]$ and $c_1(m) = m+1$.

**Definition 3.2 (layer decomposition).**
$$a(n) := \sum_{k \,:\, k^2 \le n} c_{k-1}\bigl(n - k^2\bigr).$$

We now justify that this arithmetic quantity is the geometric count of Definition 1.1.

**Definition 3.3 (assembly map).** For $k \ge 1$ and lists $\ell, r$ of positive integers, all entries $< k$, both weakly decreasing, set
$$\Phi(k,\ell,r) := \overleftarrow{\ell} \ \Vert\ \underbrace{(k,k,\dots,k)}_{k \text{ copies}} \ \Vert\ r ,$$
where $\overleftarrow{\ell}$ is $\ell$ reversed. (For $k=0$ both slopes are empty and $\Phi$ is the empty list.)

**Theorem 3.4 (the decomposition is a bijection).** $\Phi$ is a bijection from
$$\bigl\{ (k, \ell, r) : k^2 \le n,\ \ell,r \text{ partitions into parts} < k,\ |\ell| + |r| = n - k^2 \bigr\}$$
onto the set of square-core stacks of area $n$.

*Proof sketch.* **Well-definedness.** $\overleftarrow{\ell}$ is weakly increasing and $r$ weakly decreasing, so $\Phi(k,\ell,r)$ is unimodal; all entries are $\ge 1$; the maximum is $k$ because both slopes are bounded by $k-1$; and the multiplicity of $k$ is exactly the $k$ core columns, since no slope entry equals $k$. The area is $|\ell| + k^2 + |r| = n$.

**Surjectivity.** Given a square-core stack $L$ with maximum $k \ge 1$, unimodality forces the $k$ occurrences of the maximum to be consecutive, so $L = A \Vert (k,\dots,k) \Vert B$ with $A$ weakly increasing, $B$ weakly decreasing, and all entries of $A, B$ strictly below $k$ (an entry equal to $k$ would enlarge the plateau). Then $\ell := \overleftarrow{A}$ and $r := B$ are partitions into parts $< k$. For $k = 0$ the list is empty and $n = 0$.

**Injectivity.** The maximum $k$ of $\Phi(k,\ell,r)$ recovers $k$; the maximal run of $k$'s locates the core uniquely (again by unimodality and the exact multiplicity $k$); deleting it recovers $A$ and $B$, hence $\ell$ and $r$. $\square$

**Theorem 3.5 (counting formula).** For every $n$,
$$a(n) = \sum_{k^2 \le n}\ \sum_{i+j=n-k^2} p_{\le k-1}(i)\, p_{\le k-1}(j).$$

*Proof.* Immediate from Theorem 3.4, since for fixed $k$ the pairs $(\ell,r)$ with $|\ell| = i$, $|r| = j$ number $p_{\le k-1}(i)p_{\le k-1}(j)$. $\square$

Two special layers are worth recording. Layer $k=1$ contributes $[\,n=1\,]$, and layer $k=2$ contributes $c_1(n-4) = n-3$ for $n \ge 4$: the $2\times2$ block with a tail of unit columns distributed left and right.

---

## 4. Generating functions

Work in the ring $\mathbb{Z}[[x]]$ of formal power series with integer coefficients.

**Definition 4.1.** $F_b(x) := \sum_{m\ge0} p_{\le b}(m)\,x^m$.

**Theorem 4.2 (truncated Euler product).** For every $b \ge 0$,
$$F_b(x)\cdot\prod_{i=1}^{b}\bigl(1 - x^i\bigr) = 1 .$$

*Proof sketch.* Proposition 2.2 says precisely $F_{b+1}(x)\,(1-x^{b+1}) = F_b(x)$: comparing coefficients of $x^m$, the two cases $m \ge b+1$ and $m < b+1$ of the recurrence are exactly the two cases of the coefficient extraction. Induction on $b$, with base $F_0 = 1$, completes the proof. $\square$

**Theorem 4.3 (generating function of the sequence).**
$$\sum_{n\ge0} a(n)\,x^n = \sum_{k\ge0} \frac{x^{k^2}}{\prod_{i=1}^{k-1}\bigl(1-x^i\bigr)^{2}} ,$$
interpreted as the coefficientwise-convergent sum of the layer series
$$L_k(x) := F_{k-1}(x)^2\,x^{k^2}, \qquad L_k(x)\cdot\Bigl(\prod_{i=1}^{k-1}(1-x^i)\Bigr)^{2} = x^{k^2}.$$

*Proof sketch.* The coefficient of $x^m$ in $F_b(x)^2$ is exactly $c_b(m)$ by the Cauchy product, and multiplication by $x^{k^2}$ shifts. Hence for any $N \ge n$ the coefficient of $x^n$ in $\sum_{k\le N} L_k$ equals $\sum_{k^2\le n} c_{k-1}(n-k^2) = a(n)$; the terms with $k^2 > n$ contribute nothing, so the truncation is harmless and the family is summable. The displayed product identity is Theorem 4.2 squared. $\square$

**Remark 4.4 (the Durfee near-miss).** The Durfee square decomposition of an ordinary partition gives
$$\sum_{n\ge0} p(n)x^n = \sum_{k \ge 0} \frac{x^{k^2}}{\prod_{i=1}^{k}(1-x^i)^{2}} .$$
Our series is obtained by deleting the *last* factor $(1-x^{k})^{-1}$ from each layer. Since $(1-x^{k})^{-1}$ has non-negative coefficients, this comparison is coefficientwise favourable to $p$, layer by layer, which strongly suggests the inequality $a(n) \le p(n)$ for all $n$ (verified numerically well past $n = 4000$). Turning "layer by layer" into a proof requires only a formal Durfee bijection; see Section 10.

---

## 5. Positivity, the gap at $n=2,3$, and monotonicity

**Theorem 5.1 (linear lower bound).** For $n \ge 4$, $a(n) \ge n-3$.

*Proof.* The layer $k=2$ alone contributes $c_1(n-4) = n-3$, and all layers are non-negative. $\square$

**Theorem 5.2 (vanishing set).** $a(n) = 0$ if and only if $n \in \{2,3\}$.

*Proof.* For $n \ge 4$ apply Theorem 5.1; $a(0)=a(1)=1$ directly. Conversely, for $n = 2$: the maximum $k$ is $1$ or $2$; if $k=1$ the plateau has $2$ columns but a square core needs $1$; if $k=2$ the plateau has $1$ column but a square core needs $2$. For $n=3$ the three profiles $(1,1,1)$, $(1,2)$/$(2,1)$, $(3)$ all fail for the same reason. $\square$

The two-element gap is a genuine arithmetic obstruction: for small areas there is simply no room to fit a $k\times k$ block plus a compatible remainder.

**Theorem 5.3 (strict monotonicity).** For $n \ge 4$, $a(n) < a(n+1)$.

*Proof sketch.* Compare the two layer sums term by term. Every layer $k$ with $k^2 \le n$ satisfies $c_{k-1}(n-k^2) \le c_{k-1}(n+1-k^2)$, because $c_b$ is non-decreasing for $b \ge 1$ (a convolution of non-decreasing non-negative sequences) and trivially for $b \in \{0\}$; layers switching on between $n$ and $n+1$ only add. Meanwhile the layer $k=2$ strictly increases, from $n-3$ to $n-2$. $\square$

---

## 6. Convexity, and the failure of log-concavity

The regularity of $a$ is governed by an exact identity for self-convolutions, which we isolate.

**Lemma 6.1 (difference rule for convolutions).** Let $g, f : \mathbb{N}\to\mathbb{Z}$ and let $d$ be the forward difference of $f$ extended by $d(0) = f(0)$, i.e. $d(i+1) = f(i+1)-f(i)$. Then for all $m$,
$$\sum_{i=0}^{m+1} g(i) f(m+1-i) \;-\; \sum_{i=0}^{m} g(i) f(m-i) \;=\; \sum_{i=0}^{m+1} g(i)\, d(m+1-i).$$

*Proof sketch.* Match the first $m+1$ terms pairwise, using $f(m+1-i) - f(m-i) = d(m+1-i)$; the leftover term $g(m+1)f(0) = g(m+1)d(0)$ supplies the last summand. In generating-function language this is just $(1-x)\,(g*f) = g*\bigl((1-x)f\bigr)$. $\square$

**Proposition 6.2 (second differences of a self-convolution).** If $f$ is non-decreasing and $S = f*f$ (so $S(m) = \sum_{i+j=m} f(i)f(j)$), then
$$S(m+2) - 2S(m+1) + S(m) = \sum_{i+j = m+2} d(i)\,d(j) \ \ge\ 0,$$
where $d$ is as in Lemma 6.1.

*Proof sketch.* Apply Lemma 6.1 twice, once in each argument, using commutativity of the finite convolution: $(1-x)^2 (f*f) = \bigl((1-x)f\bigr)^{*2}$. Since $f$ is non-decreasing, $d \ge 0$, and a convolution of non-negative sequences is non-negative. $\square$

**Theorem 6.3 (convexity of the layers and of $a$).** For $b \ge 1$ and all $m$, $2c_b(m+1) \le c_b(m) + c_b(m+2)$. Consequently, for $n \ge 2$,
$$2\,a(n+1) \;\le\; a(n) + a(n+2).$$

*Proof sketch.* The layer statement is Proposition 6.2 with $f = p_{\le b}$, non-decreasing for $b \ge 1$. For $a$ itself, write all three values as a sum over a common finite range of layer functions $k \mapsto \bigl[k^2\le n\bigr]\,c_{k-1}(n-k^2)$ and check convexity layer by layer. Two cases need care: the degenerate layers $k \le 1$, and the layers that *switch on* between $n$ and $n+2$; in the latter case the newly created terms are non-negative and appear on the larger side of the inequality, so they only help. $\square$

**Corollary 6.4.** The increments $\Delta a(n) = a(n+1) - a(n)$ are non-decreasing for $n \ge 1$.

**Theorem 6.5 (divergence of the increments).** $\Delta a(n) \to \infty$. Quantitatively, if $n \ge 2$ and $(n+1)^2 \le a(n+1)$ then $\Delta a(n) \ge n$.

*Proof sketch.* Convexity plus telescoping gives $a(j+2) \le j\,\Delta a(j+1)$ by induction: the increments being non-decreasing, the total rise from $a(2)=0$ to $a(j+2)$ is at most $j$ copies of the last increment. Feed in the superpolynomial growth of Theorem 8.8 (with $d = 2$) to force $\Delta a(n) \ge n$ eventually. $\square$

**Theorem 6.6 (log-concavity fails).** It is **not** the case that $a(n)a(n+2) \le a(n+1)^2$ for all $n \ge 4$. Indeed
$$a(8)^2 = 25 \;<\; 28 = a(7)\,a(9).$$

The failure is instructive: $a$ is convex but not log-concave, so the two standard notions of "smooth growth" genuinely separate for this family. The reason is the layer structure: new layers switch on at the perfect squares, producing local surges that convexity tolerates but log-concavity does not.

---

## 7. The third core layer, exactly

The layers $k=0,1,2$ are respectively a delta, a delta, and the linear function $m\mapsto m+1$. The first layer with arithmetic content is $k=3$, governed by $c_2 = p_{\le 2} * p_{\le 2}$.

Since $p_{\le 1}(m) = 1$ and $p_{\le 2}(m) = \lfloor m/2 \rfloor + 1$, one has $\sum_{j\le m} p_{\le 2}(j) = (\lfloor m/2\rfloor+1)(\lfloor (m+1)/2\rfloor+1)$, and a two-step recurrence
$$c_2(m+2) = c_2(m) + g(m)g(m+1) + g(m+1) + g(m+2), \qquad g(m) := \lfloor m/2\rfloor+1 .$$

Integrating it gives:

**Theorem 7.1 (closed form of the third layer).** For all $s \ge 0$,
$$24\,c_2(2s) = (2s+2)(2s+3)(2s+4), \qquad 24\,c_2(2s+1) = (2s+2)(2s+4)(2s+6).$$
Equivalently, $c_2(m) = \frac{(m+2)(m+3)(m+4)}{24}$ for even $m$ and $c_2(m) = \frac{(m+1)(m+3)(m+5)}{24}$ for odd $m$.

*Proof sketch.* Both sides satisfy the two-step recurrence and agree at $m = 0,1$ (values $1$ and $2$); induction in steps of two. The computation reduces to a polynomial identity in $s$. $\square$

So $c_2$ is a **quasi-polynomial of degree $3$ and period $2$**. The two cubics have the same leading coefficient $1/24$ but differ in the lower-order terms, and that discrepancy is exactly what destroys higher-order convexity.

**Theorem 7.2 (exact third differences).** For all $t \ge 0$,
$$\Delta^3 c_2(2t) = -(t+2), \qquad \Delta^3 c_2(2t+1) = +(t+3),$$
where $\Delta^3 u(m) = u(m+3) - 3u(m+2) + 3u(m+1) - u(m)$.

*Proof sketch.* Substitute the four relevant instances of Theorem 7.1, clearing the denominator $24$; both identities are then polynomial identities in $t$. $\square$

**Corollary 7.3 ($3$-convexity fails at every even argument).** $c_2(2t+3) + 3c_2(2t+1) < 3c_2(2t+2) + c_2(2t)$ for every $t \ge 0$.

This is an infinite family of counterexamples with linearly growing amplitude, not an artefact of small values. It refutes the natural strengthening of Theorem 6.3 to a total-positivity statement, and it reaches the sequence itself.

**Theorem 7.4 ($a$ is not $3$-convex).** It is **not** the case that $3a(n+2) + a(n) \le a(n+3) + 3a(n+1)$ for all $n \ge 4$. Indeed
$$a(10) + 3a(8) = 9 + 15 = 24 \;<\; 25 = 21 + 4 = 3a(9) + a(7).$$

**Summary of regularity.** For square-core stacks, convexity is exactly the right statement: it holds (Theorem 6.3), and both natural strengthenings — multiplicative (log-concavity) and higher-order ($3$-convexity) — fail, the second one infinitely often at the level of the layers.

---

## 8. Growth: $\log a(n) \asymp \sqrt n$

### 8.1 The lower bound

**Theorem 8.1.** If $3m^2 + 11m + 8 \le 2n$ then $2^{\,m} \le a(n)$.

*Proof sketch.* Choose the single layer $k = m+2$; the hypothesis guarantees $(m+2)^2 \le n$, so this layer is present, and $a(n) \ge c_{m+1}(N)$ where $N = n - (m+2)^2$. Since $c_b(N) \ge p_{\le b}(N)$ (take the term $i=0$), it suffices to apply Proposition 2.3(3): the hypothesis is calibrated so that $m(m+3) \le 2N$, giving $2^{\,m} \le p_{\le m+1}(N)$. $\square$

**Corollary 8.2.** For $n \ge 100$,
$$\frac{\sqrt n - 2}{2}\,\log 2 \;\le\; \log a(n) .$$

*Proof sketch.* Take $m = \lfloor \lfloor\sqrt n\rfloor / 2 \rfloor$. Elementary estimates ($\lfloor\sqrt n\rfloor \le \sqrt n < \lfloor\sqrt n\rfloor+1$ and $\lfloor\sqrt n\rfloor \le 2m+1$) show both that the hypothesis of Theorem 8.1 holds and that $m \ge (\sqrt n - 2)/2$. Take logarithms. $\square$

### 8.2 A crude upper bound

**Proposition 8.3.** $a(n) \le (n+1)^{2\lfloor\sqrt n\rfloor + 2}$, hence $\log a(n) \le 4\sqrt n\,(\log 2 + \log n)$ for $n \ge 1$.

*Proof sketch.* From $p_{\le b}(m) \le (m+1)^{b}$ we get $c_b(m) \le (m+1)^{2b+1}$, and each present layer has $k \le \lfloor \sqrt n\rfloor$; there are at most $n+1$ layers in the formal sum. Multiply. $\square$

This bound has a spurious factor $\log n$. Removing it is the technical heart of the paper.

### 8.3 A Hardy–Ramanujan bound uniform in the part ceiling

**Lemma 8.4 (Rankin/Chebyshev bound).** For $0 < x < 1$ and all $b, m$,
$$p_{\le b}(m)\,x^{m} \;\le\; \prod_{i=1}^{b}\frac{1}{1-x^{i}} .$$

*Proof sketch.* Induct on $b$ using Proposition 2.2 in the equivalent form $F_b(x) = \prod_{i\le b}(1-x^i)^{-1}$; concretely, the left-hand side is a single term of the series $F_b(x)$, which has non-negative coefficients and sums to the right-hand side. $\square$

Taking logarithms, $\log p_{\le b}(m) \le m\log(1/x) + \sum_{i=1}^{b} -\log(1-x^i)$. The whole game is now to estimate the Euler sum for a good choice of $x$.

**Lemma 8.5 (two-regime estimate).** Put $x = 1 - 1/N$ with $N \ge 2$. Then
$$\sum_{i=1}^{b} -\log\bigl(1-x^{i}\bigr) \;\le\; 6N \qquad \text{uniformly in } b .$$

*Proof sketch.* Split the range at $i = N$.
For $i \le N$ one shows the elementary lower bound $1 - x^{i} \ge i/(8N)$; this follows from $(1-1/N)^N \ge 1/8$ (a consequence of the elementary Stirling-type inequality $N^N \le N!\,e^{N}$) together with convexity. Hence
$$\sum_{i\le N} -\log(1-x^i) \le \sum_{i \le N}\log\frac{8N}{i} = N\log(8N) - \log N! \le cN$$
using $\log N! \ge N\log N - N$.
For $i > N$ one has $x^{i} \le x^{N} \le 1/2$, so $-\log(1-x^i) \le 2x^{i}$ (using $-\log(1-u)\le 2u$ for $u \le 1/2$), and the geometric series $\sum_{i>N} x^{i} \le (1-x)^{-1} = N$ finishes. Combining the two regimes yields the constant $6$. $\square$

**Theorem 8.6 (uniform Hardy–Ramanujan bound).** For all $b, m$,
$$\log p_{\le b}(m) \;\le\; 8\sqrt{m} + 12 .$$

*Proof sketch.* In Lemma 8.4 take $x = 1-1/N$. Then $m\log(1/x) = m\,\log\bigl(1+\tfrac{1}{N-1}\bigr) \le \tfrac{m}{N-1}$, so
$$\log p_{\le b}(m) \le \frac{m}{N-1} + 6N .$$
Choosing $N \approx \sqrt m$ balances the two terms and yields $8\sqrt m$ plus an absolute constant, uniformly in $b$. $\square$

The uniformity in $b$ is the crucial feature: it lets us handle all $\Theta(\sqrt n)$ layers with a single estimate.

**Theorem 8.7 (sharp two-sided bound).** For $n \ge 100$,
$$\frac{\sqrt n - 2}{2}\,\log 2 \;\le\; \log a(n) \;\le\; 30\,\sqrt n .$$
In particular $\log a(n) \asymp \sqrt n$: each of $\log a(n) = O(\sqrt n)$ and $\sqrt n = O(\log a(n))$ holds.

*Proof sketch.* The lower bound is Corollary 8.2. For the upper bound, Theorem 8.6 gives $p_{\le b}(m) \le e^{8\sqrt m + 12}$, hence
$$c_b(M) \le (M+1)\,e^{16\sqrt M + 24}$$
(each of the $M+1$ products of two factors is bounded using $\sqrt i + \sqrt j \le 2\sqrt M$ for $i+j=M$). Summing over the at most $\sqrt n + 1$ present layers, each with $M \le n$, gives
$$\log a(n) \le 16\sqrt n + 2\log(n+1) + 24 ,$$
and for $n \ge 100$ the elementary inequality $2\log(n+1) + 24 \le 14\sqrt n$ finishes. $\square$

**Theorem 8.8 (superpolynomial growth).** For every $d$ there is $N$ with $n^{d} \le a(n)$ for all $n \ge N$.

*Proof sketch.* Theorem 8.1 gives $2^{m} \le a(n)$ with $m \asymp \sqrt n$, and $n^{d} \le \bigl(4(m+1)^2\bigr)^{d}$ is polynomial in $m$; every polynomial in $m$ is eventually dominated by $2^{m}$. $\square$

**Theorem 8.9 (vanishing entropy density).**
$$\lim_{n\to\infty}\frac{\log a(n)}{n} = 0 .$$

*Proof sketch.* Squeeze: $0 \le \log a(n)/n \le 4\log 2/\sqrt n + 4\log n/\sqrt n \to 0$, using Proposition 8.3 for the upper bound and positivity of $a(n)$ for $n \ge 4$. (Theorem 8.7 gives the stronger $O(1/\sqrt n)$.) $\square$

---

## 9. Physical interpretation

Rotate the picture: a stack polyomino is the graph of a height function over a finite interval, i.e. a **discrete interface** of solid-on-solid type, constrained to have a single hump. The area $n$ is the number of particles; the configuration space at fixed $n$ has cardinality $a(n)$; and the microcanonical entropy is $S(n) = \log a(n)$.

**Vanishing free energy.** Theorem 8.9 says the entropy density $S(n)/n$ tends to $0$. Compare with unrestricted polyominoes, whose number grows like $\lambda^{n}$ with the Klarner constant $\lambda \approx 4.06$: there the entropy density is $\log\lambda > 0$, i.e. the system has extensive disorder. Unimodality plus a square crown collapses that: the model is *rigid*, with entropy of order $\sqrt n$ only. Physically, all the freedom lives in the $O(\sqrt n)$ effective degrees of freedom of the two slopes, not in the $n$ particles.

**The $\sqrt n$ exponent.** $S(n) \asymp \sqrt n$ is the signature of a one-dimensional bosonic system: the number of states of a 1D Bose gas at energy $n$ is $p(n) \sim \frac{1}{4n\sqrt3}\exp\bigl(\pi\sqrt{2n/3}\bigr)$, and $\pi\sqrt{2/3}$ is, in that language, $\sqrt{2\pi^2/3} = \sqrt{2\zeta(2)\cdot 2}$ — the Cardy-type constant built from the central charge of a single free boson. Our layers are exactly two such bosonic slopes cut off at the core height.

**The core as a chemical potential.** In the generating function $\sum_k x^{k^2}\prod_{i<k}(1-x^i)^{-2}$, the parameter $k$ behaves like an order parameter, the core cost $x^{k^2}$ like a confining potential and the truncated Euler product like the entropy gained by widening the slopes. Section 10 makes this competition quantitative.

---

## 10. Discussion and open problems

### 10.1 The exact Hardy–Ramanujan constant

The proved bounds trap $\log a(n)/\sqrt n$ between $\approx 0.34$ and $30$. Numerically, the ratio reads $1.765$ at $n=100$, $2.137$ at $n=500$, $2.241$ at $n=1000$, $2.290$ at $n=1500$, and $2.381$ at $n=4000$: a very slow climb, as always with Hardy–Ramanujan asymptotics, toward
$$\pi\sqrt{2/3} = 2.5650996\ldots$$

**Conjecture 10.1.** $\log a(n) \sim \pi\sqrt{2n/3}$ as $n \to \infty$; equivalently, $a(n)$ and $p(n)$ have the same exponential order.

*Heuristic.* Set $x = e^{-t}$, $t \to 0^{+}$, and analyse $\Phi(t) = \sum_{k} e^{-k^2 t}\prod_{i<k}(1-e^{-it})^{-2}$ by a saddle point in $k$. The logarithm of the $k$-th term is
$$-k^2 t \;+\; \frac{2}{t}\int_{0}^{kt} -\log\bigl(1-e^{-s}\bigr)\,ds \;+\; o(1/t).$$
Differentiating in $k$ gives the stationarity condition $-2kt + 2\bigl(-\log(1-e^{-kt})\bigr) = 0$, i.e. $e^{-kt} = 1 - e^{-kt}$, i.e.
$$kt = \log 2 .$$
Remarkably, at that saddle the loss $-k^2t$ from the square core is exactly compensated by the gain from the last stretch of the Euler product, and one recovers
$$\log \Phi(t) \sim \frac{\pi^2}{6t},$$
identical with the untruncated Euler product $\prod_{i\ge1}(1-e^{-it})^{-1}$ governing $p(n)$. A standard saddle-point transfer then gives $\log a(n)\sim 2\sqrt{\pi^2 n/6} = \pi\sqrt{2n/3}$.

Making this rigorous by elementary means looks feasible: the required inputs — the Rankin bound of Lemma 8.4 and the two-regime estimate of Lemma 8.5, both uniform in $b$ — already exist; one replaces the crude inequality $1-x^i \ge i/(8N)$ by the integral comparison $\sum_{i} -\log(1-e^{-it}) \le \pi^2/(6t)$ and tracks the constants.

### 10.2 Domination by the partition function

**Conjecture 10.2.** $a(n) \le p(n)$ for all $n \ge 0$.

Verified for $n \le 4000$. As explained in Remark 4.4, the Durfee square identity exhibits $\sum p(n)x^n$ as the same layer sum with each Euler product extended by one factor; since $(1-x^k)^{-1}$ has non-negative coefficients, the inequality should hold layer by layer, and reduces to the already-available monotonicity $p_{\le k-1} \le p_{\le k}$ once a formal Durfee bijection is in place. Note that domination is *strict* for $n \ge 2$: e.g. $a(10) = 9 < 42 = p(10)$.

### 10.3 Parity alternation of higher differences

Theorem 7.2 shows the third differences of the layer $k=3$ alternate with period $2$ and grow linearly. Numerically the same pattern — sign alternation governed by the parity of the argument, amplitude growing like a polynomial of degree $\deg - 3$ — persists for higher layers.

**Conjecture 10.3.** For each $b \ge 2$, $c_b$ is a quasi-polynomial of degree $2b-1$ whose $(2b)$-th differences alternate in sign according to the residue of $m$ modulo $\mathrm{lcm}(1,\dots,b)$.

For $b = 2$ the modulus is $2$ and the statement is Theorem 7.2. The general case would follow from an explicit quasi-polynomial formula for $c_b$, which exists in principle (a self-convolution of a quasi-polynomial with period $\mathrm{lcm}(1,\dots,b)$) but whose sign structure is not obvious.

### 10.4 Other core shapes

The square-core condition can be replaced by any relation between plateau width $w$ and height $k$. Taking $w = \alpha k$ replaces $x^{k^2}$ by $x^{\alpha k^2}$ and rescales the saddle; taking $w = k^{\beta}$ interpolates between the flat case ($\beta=0$, giving essentially unrestricted stacks) and the strongly confined case. In all cases the saddle-point analysis of Section 10.1 applies with a modified core cost, and it would be interesting to determine for which exponents the "core is asymptotically free" phenomenon (constant $\pi\sqrt{2/3}$) survives.

### 10.5 Refined statistics

Beyond counting, one may ask for the distribution of the core height $k$ in a uniformly random square-core stack of area $n$. The saddle-point condition $kt = \log 2$ with $t \sim \pi/\sqrt{6n}$ predicts
$$k \;\approx\; \frac{\log 2}{\pi}\sqrt{6n} \;\approx\; 0.5406\,\sqrt n$$
with Gaussian fluctuations of order $n^{1/4}$. Proving a local limit theorem for the core height is the natural probabilistic sequel.

---

## 11. Algorithms

Two computations underpin every numerical statement above.

**Layer accumulation.** To tabulate $a(0..N)$: maintain the array $p_{\le k-1}(0..N)$ and, for $k = 0,1,2,\dots$ while $k^2 \le N$, add the self-convolution of that array (truncated at length $N-k^2+1$) into $a$ at offset $k^2$, then promote $p_{\le k-1}$ to $p_{\le k}$ by the in-place coin-change update $p[m] \mathrel{+}= p[m-k]$ for $m = k,\dots,N$. The convolutions dominate the cost at $O(N^2)$ integer multiplications (each of numbers with $O(\sqrt N)$ digits); the table updates cost only $O(N^{3/2})$ additions.

**Direct enumeration.** For validation at small $n$: enumerate all compositions of $n$ (there are $2^{n-1}$), keep those that are unimodal and whose maximal value $k$ occurs exactly $k$ times. Exponential, but a decisive cross-check; agreement holds for every $n \le 16$ checked.

**Closed-form evaluation of the third layer.** $c_2(m)$ is computed in $O(1)$ arithmetic operations from Theorem 7.1, which is both a speedup and a test of the theorem.

---

## 12. Conclusion

Imposing a single geometric constraint — that the summit plateau of a stack polyomino be a perfect square — produces a counting sequence with a rich and completely determined structure. The constraint translates into a ceiling on the parts of two slope partitions, giving the layer decomposition and the generating function $\sum_k x^{k^2}\prod_{i<k}(1-x^i)^{-2}$, a one-factor truncation of the Durfee-square series for $p(n)$. From there: the sequence vanishes exactly at $n = 2, 3$; it is strictly increasing and convex thereafter, with divergent increments; and convexity is optimal, since log-concavity fails at $n=8$ and third-order convexity fails infinitely often, as the exact cubic quasi-polynomial of the third layer makes explicit. Globally, $\log a(n) \asymp \sqrt n$, so the family is superpolynomial, subexponential, and of vanishing entropy density — a rigid one-dimensional interface model whose asymptotic constant appears to coincide with the Hardy–Ramanujan constant of the partition function.
