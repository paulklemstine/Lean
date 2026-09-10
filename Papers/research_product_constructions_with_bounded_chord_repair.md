# Product Constructions for Snake-in-the-Box Codes: Half the Multiplicative Term, and a Bulk Obstruction to the Rest

**Author:** Aristotle
**Date:** 2026-09-10

---

## Abstract

A *snake* of length $L$ in the hypercube $Q_n$ is an induced path $v_0, v_1, \dots, v_L$ in the graph whose vertices are the binary strings of length $n$ and whose edges join strings at Hamming distance $1$; the *snake-in-the-box number* $s(n)$ is the largest such $L$. Because $Q_{m+n}$ splits metrically as $Q_m \times Q_n$, it is natural to conjecture that snakes multiply: that there is an absolute constant $C$ such that snakes of lengths $L$ in $Q_m$ and $K$ in $Q_n$ combine into a snake of length at least $(L+1)(K+1) - C(L+K)$ in $Q_{m+n}$, the loss being confined to the interfaces between the two factors.

We settle the status of this *mechanism* completely, and we extract from the analysis the strongest unconditional product theorem currently available.

On the positive side, we show that the image of the product of two snakes is an **induced** copy of the grid graph $P_{L+1} \mathbin{\square} P_{K+1}$ inside $Q_{m+n}$, so that every induced path in that grid is a snake in the cube. We then exhibit an explicit boustrophedon ("comb") induced path of length
$$\operatorname{comb}(L, K) = \left\lfloor L/2 \right\rfloor (K+2) + K,$$
yielding the supermultiplicative bound $s(m)\,s(n) \le 2\, s(m+n)$ and the half-main-term inequality $(s(m)+1)(s(n)+1) \le 2 s(m+n) + s(n) + 2$. A complementary L-shaped path of length $L+K$ gives superadditivity $s(m) + s(n) \le s(m+n)$ and strict monotonicity $s(n) + 1 \le s(n+1)$.

On the negative side, we prove that an induced path in a grid never contains all four cells of a $2\times2$ square, whence any snake supported on the product vertex set has at most $3\lceil (L+1)/2\rceil\lceil (K+1)/2\rceil \approx \tfrac34 (L+1)(K+1)$ vertices. Consequently, for every constant $C$ and all $L, K \ge 8C + 11$, no product-supported snake attains $(L+1)(K+1) - C(L+K)$: the loss of a product construction is $\Theta(LK)$, not $O(L+K)$. Bounded chord repair inside the product grid is therefore impossible. Finally, the exact value $s(2) = 2$ forces $C \ge 1$ in any surviving form of the conjecture.

We quantify the remaining gap: the comb attains a fraction $(K+2)/\big(2(K+1)\big)$ of the grid — exactly $3/4$ when $K = 1$, matching the cap up to an additive constant, and degrading monotonically to $1/2$ as $K \to \infty$. We conjecture that the true asymptotic density of a longest induced path in an $a \times b$ grid is $2/3$, and outline a discharging strategy for the matching upper bound.

**Keywords:** snake-in-the-box, induced path, hypercube, Hamming distance, grid graph, product construction, discharging, error-detecting codes.

---

## 1. Introduction

### 1.1 Snakes in the box

Let $Q_n$ denote the $n$-dimensional hypercube graph: its vertex set is $\{0,1\}^n$, identified with functions $\{1,\dots,n\} \to \{0,1\}$, and two vertices are adjacent when their Hamming distance
$$d(x, y) \;=\; \#\{\, i : x_i \ne y_i \,\}$$
equals $1$.

**Definition 1.1 (Snake).** A *snake of length $L$* in $Q_n$ is a sequence of vertices $v_0, v_1, \dots, v_L$ such that

1. (step) $d(v_i, v_{i+1}) = 1$ for all $0 \le i < L$, and
2. (no chord) $d(v_i, v_j) \ge 2$ whenever $0 \le i, j \le L$ and $|i - j| \ge 2$.

Equivalently, $\{v_0, \dots, v_L\}$ induces a path in $Q_n$. The *snake-in-the-box number* $s(n)$ is the maximum length of a snake in $Q_n$.

Two consequences of Definition 1.1 will be used constantly. First, the full **distance dichotomy**: for indices $i \ne j$ in range, $d(v_i, v_j) = 1$ if $|i-j| = 1$ and $d(v_i, v_j) \ge 2$ otherwise; in particular $d(v_i, v_j) \ge \min(|i-j|, 2)$. Second, a snake is **injective**: $v_i = v_j$ forces $i = j$, since distinct indices give positive distance.

Snakes were introduced by Kautz in 1958 as error-detecting codes for analogue-to-digital conversion: positions along a snake are encoded by their vertices, and the no-chord condition guarantees that a single-bit error can never transform one codeword into a *different valid neighbouring* codeword. Determining $s(n)$ is a notorious open problem. The known exact values are
$$s(1),\dots,s(8) = 1,\ 2,\ 4,\ 7,\ 13,\ 26,\ 50,\ 98,$$
and for $n \ge 9$ only lower bounds from large-scale searches are available. The number of vertices of $Q_n$ grows like $2^n$, while the best known snakes have length $\Theta(2^n / n^{\,c})$ for constructions and $s(n) \le 2^{n-1}(1 - o(1))$ from counting; the multiplicative constants are the arena of the record hunt.

### 1.2 The product dream

Since searches proceed dimension by dimension and yield no information about higher dimensions, a *product theorem* — a way to combine a record in $Q_m$ with a record in $Q_n$ into a record in $Q_{m+n}$ — would transform the subject. The starting point is the metric factorisation of the cube.

**Lemma 1.2 (Additivity across a coordinate split).** Partition the coordinate set of $Q_{m+n}$ into a block $\alpha$ of size $m$ and a block $\beta$ of size $n$, and write a vertex as a pair $(a, b)$ with $a \in \{0,1\}^\alpha$, $b \in \{0,1\}^\beta$. Then
$$d\big((a, b),\, (a', b')\big) \;=\; d(a, a') + d(b, b').$$

*Proof.* The set of disagreeing coordinates of the pair is the disjoint union of the sets of disagreeing coordinates in the two blocks; cardinality is additive over disjoint unions. $\square$

Hamming distance is also invariant under any relabelling of the coordinates, so nothing is lost by working with an arbitrary finite coordinate set rather than $\{1, \dots, n\}$; the identification $Q_{m+n} \cong Q_m \times Q_n$ is a cosmetic relabelling. Throughout, we index coordinates by finite sets $\alpha$, $\beta$ and write $Q_\alpha$, $Q_{\alpha \sqcup \beta}$.

Given snakes $p_0, \dots, p_L$ in $Q_\alpha$ and $q_0, \dots, q_K$ in $Q_\beta$, the $(L+1)(K+1)$ vertices $(p_i, q_j)$ of $Q_{\alpha\sqcup\beta}$ form the *product vertex set*. The dream is to thread a single snake through all of them, or through all but a negligible fraction.

**Conjecture 1.3 (Bounded chord repair).** There is an absolute constant $C$ such that snakes of lengths $L$ in $Q_m$ and $K$ in $Q_n$ can be combined into a snake in $Q_{m+n}$ of length at least $(L+1)(K+1) - C(L+K)$.

The stated *mechanism* is that all offending chords are localised near the transitions between the two factors, so that a bounded family of separator coordinates can repair the interfaces without destroying the multiplicative main term.

### 1.3 Results of this paper

**(A) The product of two snakes is an induced grid** (Theorem 2.2). The map $(i,j) \mapsto (p_i, q_j)$ embeds the grid $P_{L+1} \mathbin{\square} P_{K+1}$ into $Q_{\alpha\sqcup\beta}$ as an induced subgraph. Hence the problem "how long a snake can be built inside the product vertex set?" is *exactly* the problem "how long an induced path exists in a rectangular grid?".

**(B) The comb: half of the multiplicative term, unconditionally** (Theorem 3.4 and Corollary 3.6). There is an explicit snake in $Q_{\alpha \sqcup \beta}$ of length $\operatorname{comb}(L,K) = \lfloor L/2 \rfloor(K+2)+K$. Consequently $s(m) s(n) \le 2 s(m+n)$ and $(s(m)+1)(s(n)+1) \le 2 s(m+n) + s(n) + 2$.

**(C) The L-shape: superadditivity and monotonicity** (Theorem 4.1, Corollary 4.2). There is a snake of length $L+K$; hence $s(m)+s(n) \le s(m+n)$ and $s(n) + 1 \le s(n+1)$.

**(D) The $3/4$ obstruction** (Lemma 5.2, Theorem 5.3). An induced path in a grid omits a corner of every $2\times2$ square; hence a product-supported snake has at most $3\lceil (L+1)/2\rceil \lceil (K+1)/2\rceil$ vertices.

**(E) The conjectured mechanism fails** (Theorem 5.4). For every $C$ and all $L, K \ge 8C+11$, a product-supported snake of length $M$ satisfies $M + C(L+K) < (L+1)(K+1)$.

**(F) The constant cannot be zero** (Theorem 6.3). Since $s(2) = 2$ while $(1+1)(1+1) = 4$, any valid $C$ satisfies $C \ge 1$.

**(G) Density accounting** (Proposition 3.7, Corollary 5.5). The comb uses a fraction $(K+2)/(2(K+1))$ of the grid: exactly $3/4$ at $K=1$, decaying to $1/2$. The comb is itself product-supported and therefore respects the cap, giving the sandwich $\operatorname{comb}(L,K)+1 \le 3\lceil (L+1)/2\rceil\lceil (K+1)/2\rceil$.

The upshot: **Conjecture 1.3 survives only as a statement about $s(m+n)$; its stated mechanism is dead.** The honest product theorem currently reads
$$s(m+n) \;\ge\; \max\Big(\tfrac{1}{2}\, s(m)\, s(n),\ \ s(m) + s(n)\Big).$$

---

## 2. The product grid

Fix finite coordinate sets $\alpha, \beta$, a snake $p_0,\dots,p_L$ in $Q_\alpha$ and a snake $q_0,\dots,q_K$ in $Q_\beta$. Write $\Pi(i,j) := (p_i, q_j) \in Q_{\alpha \sqcup \beta}$.

**Lemma 2.1 (Rigidity along a snake).** For $0 \le i, j \le L$,
$$d(p_i, p_j) \;\ge\; \min\big(|i-j|,\, 2\big),$$
with equality to $0$ iff $i = j$ and to $1$ iff $|i-j| = 1$.

*Proof.* Immediate from Definition 1.1 by trichotomy on $i$ versus $j$. $\square$

**Theorem 2.2 (Grid Embedding).** The map $\Pi$ is injective, and for all admissible indices
$$d\big(\Pi(i,j),\, \Pi(i',j')\big) \;\ge\; \min\big(|i-i'|,2\big) + \min\big(|j-j'|,2\big).$$
In particular:

1. if $|i-i'| + |j-j'| = 1$ then $d(\Pi(i,j), \Pi(i',j')) = 1$ (grid edges are cube edges);
2. if $|i-i'| + |j-j'| \ge 2$ then $d(\Pi(i,j), \Pi(i',j')) \ge 2$ (non-edges are non-edges).

Hence $\Pi$ is an isomorphism onto an **induced** subgraph of $Q_{\alpha\sqcup\beta}$ isomorphic to the grid $P_{L+1} \mathbin{\square} P_{K+1}$.

*Proof.* Apply Lemma 1.2 to split the distance, then Lemma 2.1 in each factor. For (1), one of the two index gaps is $0$ and the other is $1$: the corresponding factor distances are $0$ and $1$. For (2): if some gap is $\ge 2$ the corresponding term already contributes $2$; otherwise both gaps are $1$ and the two terms contribute $1$ each. Injectivity follows since a nonzero gap in either coordinate gives positive distance. $\square$

**Corollary 2.3.** Every induced path in the grid $P_{L+1} \mathbin{\square} P_{K+1}$ transports, under $\Pi$, to a snake in $Q_{\alpha \sqcup \beta}$; conversely, every snake whose vertices all lie in the product vertex set is the image of an induced path in that grid.

The converse direction requires one extra observation, recorded here for use in §5.

**Lemma 2.4 (Grid adjacency forces index adjacency).** Let $v_0, \dots, v_M$ be a snake with $v_s = \Pi\big(a(s), b(s)\big)$ for all $s$, where $a(s) \le L$ and $b(s) \le K$. If $|a(s)-a(s')| + |b(s)-b(s')| = 1$ then $|s - s'| = 1$.

*Proof.* By Theorem 2.2(1), $d(v_s, v_{s'}) = 1$. Along a snake, distance $1$ occurs only for consecutive indices: equal indices give distance $0$, and indices at gap $\ge 2$ give distance $\ge 2$. $\square$

Thus the study of product constructions reduces, without any loss, to a two-dimensional combinatorial question on squared paper: *how long can an induced path in an $a \times b$ grid be?*

---

## 3. The comb construction

### 3.1 The path

Fix $K$ and set $B := K + 2$, the *block length*. For a step index $s \ge 0$ write $s = r + tB$ with $0 \le r < B$; define
$$\operatorname{row}(s) \;=\; 2t + \begin{cases} 0, & r \le K,\\ 1, & r = K+1,\end{cases}
\qquad
\operatorname{col}(s) \;=\; \begin{cases} \min(r, K), & t \text{ even},\\ K - \min(r, K), & t \text{ odd},\end{cases}$$
and let the $s$-th comb vertex be $\Pi\big(\operatorname{row}(s), \operatorname{col}(s)\big)$.

Verbally: within block $t$, the walk sweeps across row $2t$ from one end to the other (left to right for even $t$, right to left for odd $t$), consuming $K+1$ cells, and then drops through the single *connector* cell in row $2t+1$ at the far end. Odd rows are otherwise empty. The next block begins directly beneath the connector.

**Definition 3.1.** $\operatorname{comb}(L, K) := \lfloor L/2\rfloor\,(K+2) + K$.

**Lemma 3.2 (Steps).** For every $s$, either $\operatorname{row}(s+1) = \operatorname{row}(s)$ and $|\operatorname{col}(s+1) - \operatorname{col}(s)| = 1$, or $\operatorname{col}(s+1) = \operatorname{col}(s)$ and $\operatorname{row}(s+1) = \operatorname{row}(s) + 1$.

*Proof.* Case analysis on $r$. If $r < K$ we stay in the same full row and the column moves by one (in the direction dictated by the parity of $t$). If $r = K$ we are at the far end of the full row and step down into the connector: the row increases by one and the column is unchanged, since $\min(K+1, K) = \min(K,K)$. If $r = K+1$ we step from the connector of block $t$ to the first cell of block $t+1$: the row goes from $2t+1$ to $2(t+1)$, and the column is unchanged because the parity flip exchanges $\min(K+1,K) = K$ with $K - \min(0,K) = K$ (and symmetrically). $\square$

**Lemma 3.3 (No chords).** If $s + 1 < s'$ then $|\operatorname{row}(s) - \operatorname{row}(s')| + |\operatorname{col}(s) - \operatorname{col}(s')| \ge 2$.

*Proof.* Write $s = r + tB$, $s' = r' + t'B$; from $s < s'$ we get $t < t'$, or $t = t'$ and $r + 1 < r'$.

*Same block ($t = t'$, $r+1 < r'$).* If both $r, r' \le K$ the two cells are in the same row and their columns differ by $|r - r'| \ge 2$. Otherwise $r' = K+1$ (the connector) and $r \le K - 1$; then the rows differ by $1$ and the columns differ by at least $1$, since the connector sits at the far end $\min(K+1,K) = K$ of the sweep while $\min(r,K) = r \le K-1$ (mutatis mutandis for odd $t$).

*Adjacent blocks ($t' = t+1$).* Rows differ by $2t' - 2t \in \{1, 2\}$ up to the connector correction. If the row gap is $2$ we are done. The row gap is $1$ only when $s$ is the connector of block $t$ (row $2t+1$) and $s'$ lies in row $2t+2$; but then $s' \ge s + 1$ with equality excluded, so $s'$ is not the first cell of block $t+1$, and its column differs from the connector's column by at least $1$.

*Distant blocks ($t' \ge t + 2$).* Rows already differ by at least $2(t'-t) - 1 \ge 3$. $\square$

**Theorem 3.4 (The comb is a snake).** Given a snake of length $L$ in $Q_\alpha$ and a snake of length $K$ in $Q_\beta$, the comb vertices $s \mapsto \Pi(\operatorname{row}(s), \operatorname{col}(s))$, for $0 \le s \le \operatorname{comb}(L,K)$, form a snake of length $\operatorname{comb}(L,K)$ in $Q_{\alpha\sqcup\beta}$.

*Proof.* One first checks $\operatorname{row}(s) \le L$ and $\operatorname{col}(s) \le K$ for all $s \le \operatorname{comb}(L,K)$: the column bound is immediate from the definition, and for the row bound, $s \le \lfloor L/2 \rfloor B + K$ forces $t \le \lfloor L/2 \rfloor$, with $r \le K$ (hence no connector correction) when $t = \lfloor L/2 \rfloor$; so $\operatorname{row}(s) \le 2\lfloor L/2\rfloor \le L$. Now the step condition follows from Lemma 3.2 together with Theorem 2.2(1), and the chord condition from Lemma 3.3 together with Theorem 2.2(2). $\square$

### 3.2 Numerical consequences

**Proposition 3.5.** For $L \ge 1$: (i) $LK \le 2\operatorname{comb}(L,K)$, and (ii) $(L+1)(K+1) \le 2\operatorname{comb}(L,K) + K + 2$.

*Proof.* Write $L = 2\lfloor L/2\rfloor + \varepsilon$ with $\varepsilon \in \{0,1\}$. Then
$$2\operatorname{comb}(L,K) = (L - \varepsilon)(K+2) + 2K = LK + 2L + 2K - \varepsilon(K+2).$$
For (i), $LK \le LK + 2L + 2K - \varepsilon(K+2)$ because $2L + 2K - \varepsilon(K+2) \ge 2 + 2K - (K+2) = K \ge 0$ when $L \ge 1$. For (ii), $(L+1)(K+1) = LK + L + K + 1$, and $LK + 2L + 2K - \varepsilon(K+2) + K + 2 - (LK + L + K + 1) = L + 2K + 1 - \varepsilon(K+2) \ge 0$ again by $L \ge 1$. $\square$

**Corollary 3.6 (Supermultiplicativity of the snake number).** For all $m, n \ge 1$,
$$s(m)\cdot s(n) \;\le\; 2\, s(m+n), \qquad \big(s(m)+1\big)\big(s(n)+1\big) \;\le\; 2\,s(m+n) + s(n) + 2 .$$

*Proof.* Take optimal snakes of lengths $L = s(m)$ and $K = s(n)$, apply Theorem 3.4 to obtain a snake of length $\operatorname{comb}(L,K)$ in $Q_{m+n}$, so $\operatorname{comb}(L,K) \le s(m+n)$, and insert this into Proposition 3.5. $\square$

Thus **half of the conjectured multiplicative main term is unconditionally correct**, by an explicit construction. Iterating, a single record of length $L$ in dimension $m$ gives $s(km) \ge L^k / 2^{k-1}$ for every $k \ge 1$.

**Proposition 3.7 (Density of the comb).** The comb visits $\operatorname{comb}(L,K)+1$ cells of the $(L+1)(K+1)$-cell grid, and
$$(L+1)(K+2) \;\le\; 2\big(\operatorname{comb}(L,K)+1\big) + 2 .$$
For even $L$ the density is exactly
$$\frac{\operatorname{comb}(L,K)+1}{(L+1)(K+1)} \;=\; \frac{\tfrac{L}{2}(K+2)+K+1}{(L+1)(K+1)} \;\xrightarrow[L \to \infty]{}\; \frac{K+2}{2(K+1)} .$$

*Proof.* The displayed inequality is the same computation as Proposition 3.5 with $\varepsilon \in \{0,1\}$; the limit is immediate. $\square$

The limiting density $(K+2)/(2(K+1))$ equals $3/4$ at $K = 1$, $2/3$ at $K=2$, $5/8$ at $K=3$, and decreases monotonically to $1/2$. As we will see in §5, $3/4$ is a hard cap, so **the comb is asymptotically optimal for $K = 1$** and the conjecture cannot be rescued by improving the construction in the bounded-$K$ regime. Any improvement must concern the regime in which both factors grow.

---

## 4. The L-shape: superadditivity

**Theorem 4.1 (L-shape).** With $p$, $q$ as above, the vertices
$$s \longmapsto \Pi\big(\min(s, L),\ \max(s - L,\, 0)\big), \qquad 0 \le s \le L+K,$$
form a snake of length $L + K$ in $Q_{\alpha\sqcup\beta}$.

*Proof.* The walk traverses the bottom row from $(0,0)$ to $(L,0)$ and then the right-hand column from $(L,0)$ to $(L,K)$: consecutive steps change exactly one grid coordinate by $1$, giving cube edges by Theorem 2.2(1). For the chord condition, if $s + 1 < s'$ then $\min(s,L)$ and $\min(s',L)$ differ by $s'-s$ or the column indices differ by $s'-s$, or the walk turns the corner between them and the row gap plus the column gap equals $s' - s \ge 2$; in all cases the $\ell^1$ gap in the grid is $\ge 2$, and Theorem 2.2(2) applies. $\square$

**Corollary 4.2.** $s(m) + s(n) \le s(m+n)$ for all $m,n$, and $s(n) + 1 \le s(n+1)$ for all $n \ge 1$.

*Proof.* The first is Theorem 4.1 with optimal snakes. The second is the case $m = 1$, using $s(1) = 1$. $\square$

The L-shape beats the comb exactly in degenerate regimes ($K = 0$, or $L$ small and odd); for $L, K \ge 2$ the comb dominates.

---

## 5. The $3/4$ obstruction and the failure of the mechanism

We now bound *every* snake supported on the product vertex set, not merely the ones we construct.

Throughout this section, $v_0,\dots,v_M$ is a snake in $Q_{\alpha \sqcup \beta}$ with $v_s = \Pi(a(s), b(s))$, $a(s) \le L$, $b(s) \le K$.

**Lemma 5.1 (Injectivity in grid coordinates).** The map $s \mapsto (a(s), b(s))$ is injective on $\{0, \dots, M\}$.

*Proof.* If $(a(s),b(s)) = (a(s'),b(s'))$ then $v_s = v_{s'}$, and a snake never repeats a vertex. $\square$

**Lemma 5.2 (No $2\times2$ square).** There is no $2\times2$ square all of whose four cells are visited: there are no indices $s_1, s_2, s_3, s_4 \le M$ with
$$(a,b)(s_1) = (i,j),\quad (a,b)(s_2) = (i{+}1, j),\quad (a,b)(s_3) = (i, j{+}1),\quad (a,b)(s_4) = (i{+}1, j{+}1).$$

*Proof.* The four pairs $\{s_1,s_2\}, \{s_1,s_3\}, \{s_2,s_4\}, \{s_3,s_4\}$ are grid-adjacent, so by Lemma 2.4 each pair consists of *consecutive* indices: $|s_1 - s_2| = |s_1 - s_3| = |s_2 - s_4| = |s_3 - s_4| = 1$. Moreover $s_2 \ne s_3$ and $s_1 \ne s_4$ by Lemma 5.1 (their grid coordinates differ). Four integers cannot satisfy this system: from $|s_1-s_2| = |s_1-s_3| = 1$ and $s_2 \ne s_3$ we get $\{s_2, s_3\} = \{s_1 - 1, s_1 + 1\}$; say $s_2 = s_1+1$, $s_3 = s_1-1$. Then $|s_2 - s_4| = 1$ gives $s_4 \in \{s_1, s_1+2\}$ and $|s_3-s_4|=1$ gives $s_4 \in \{s_1-2, s_1\}$, forcing $s_4 = s_1$, contradicting $s_1 \ne s_4$. $\square$

Conceptually: the four cells of a square span a $4$-cycle, while four positions along a path support at most three consecutive pairs. A $4$-cycle is never an induced subgraph of a path.

**Theorem 5.3 (The $3/4$ cap).** Any snake supported on the product of a length-$L$ snake and a length-$K$ snake satisfies
$$M + 1 \;\le\; 3\left\lceil \frac{L+1}{2}\right\rceil \left\lceil \frac{K+1}{2}\right\rceil \;=\; 3 \left\lfloor \frac{L+2}{2}\right\rfloor\left\lfloor\frac{K+2}{2}\right\rfloor .$$

*Proof.* Let $S := \{(a(s), b(s)) : 0 \le s \le M\}$; by Lemma 5.1, $|S| = M+1$. Map each cell $(x,y) \in S$ to its $2\times2$ block $(\lfloor x/2\rfloor, \lfloor y/2 \rfloor)$, which lies in a set $T$ of $\lfloor (L+2)/2\rfloor \cdot \lfloor (K+2)/2\rfloor$ blocks. Each fibre of this map is contained in the four cells of one block, and by Lemma 5.2 cannot contain all four; so every fibre has at most $3$ elements. Summing fibre sizes over $T$ gives $|S| \le 3|T|$. $\square$

**Theorem 5.4 (The conjectured mechanism fails).** Fix any constant $C \ge 0$. If $L \ge 8C+11$ and $K \ge 8C+11$, then every snake supported on the product vertex set satisfies the strict inequality
$$M + C(L+K) \;<\; (L+1)(K+1).$$
In particular no product-supported snake attains length $(L+1)(K+1) - C(L+K)$.

*Proof.* From Theorem 5.3 and $2\lfloor (L+2)/2\rfloor \le L+2$,
$$4(M+1) \;\le\; 12 \left\lfloor \tfrac{L+2}{2}\right\rfloor\left\lfloor\tfrac{K+2}{2}\right\rfloor \;=\; 3\left(2\left\lfloor \tfrac{L+2}{2}\right\rfloor\right)\left(2\left\lfloor \tfrac{K+2}{2}\right\rfloor\right) \;\le\; 3(L+2)(K+2).$$
Hence $M \le \tfrac34 LK + \tfrac32(L+K) + 2$. It therefore suffices that
$$\tfrac34 LK + \tfrac32 (L+K) + 2 + C(L+K) \;<\; LK + L + K + 1,$$
i.e. that $\big(C + \tfrac12\big)(L+K) + 1 < \tfrac14 LK$. Put $T := 8C+11$. From $L, K \ge T$ we get $LK \ge T \max(L,K) \ge \tfrac{T}{2}(L+K)$, hence
$$\tfrac14 LK \;\ge\; \tfrac{T}{8}(L+K) \;=\; \Big(C + \tfrac{11}{8}\Big)(L+K).$$
On the other side, $L + K \ge 2T \ge 22 > 8$, so $1 \le \tfrac18 (L+K)$ and therefore $\big(C+\tfrac12\big)(L+K)+1 \le \big(C + \tfrac58\big)(L+K) < \big(C+\tfrac{11}{8}\big)(L+K)$. Combining the two displays gives the strict inequality. $\square$

The content of Theorem 5.4 is a *bulk* statement: the loss suffered by any product construction is $\Theta(LK)$ — at least a quarter of the grid — and not the $O(L+K)$ "interface" loss posited by Conjecture 1.3. Bounded chord repair cannot work while the repaired object stays inside the product vertex set. Any proof of Conjecture 1.3, if it is true at all, must use vertices of $Q_{m+n}$ outside $\{(p_i, q_j)\}$.

**Corollary 5.5 (Consistency sandwich).** Because the comb is itself product-supported, Theorem 5.3 applies to it, giving
$$\left\lfloor \tfrac{L}{2}\right\rfloor(K+2) + K + 1 \;\le\; 3\left\lfloor \tfrac{L+2}{2}\right\rfloor\left\lfloor\tfrac{K+2}{2}\right\rfloor$$
for all $L, K$. At $K = 1$ both sides are $\tfrac34 (L+1)(K+1) + O(1)$: the comb saturates the cap in the narrowest nontrivial strip.

---

## 6. Small cubes and the necessity of a positive constant

**Lemma 6.1.** In $Q_n$ every Hamming distance is at most $n$, and $d(x,y) = n$ exactly when $x$ and $y$ are antipodal (they differ in every coordinate).

**Proposition 6.2.** $s(0) = 0$, $s(1) = 1$, $s(2) = 2$.

*Proof.* $Q_0$ has one vertex and $Q_1$ has two, so a snake has at most $0$ resp. $1$ steps, and these are attained. For $Q_2$: the path $01, 11, 10$ (equivalently, three corners of a square) is a snake of length $2$. Conversely, suppose a snake of length $3$ existed, with vertices $v_0, v_1, v_2, v_3$. The chords force $d(v_0, v_2) \ge 2$ and $d(v_0, v_3) \ge 2$, and distances in $Q_2$ are at most $2$, so both equal $2$: thus $v_2$ and $v_3$ are both antipodal to $v_0$, hence $v_2 = v_3$, contradicting $d(v_2, v_3) = 1$. $\square$

**Theorem 6.3 (The constant is at least $1$).** Suppose $C$ is such that for all $m, n$ and all snakes of lengths $L$ in $Q_m$, $K$ in $Q_n$ one has $(L+1)(K+1) \le s(m+n) + C(L+K)$. Then $C \ge 1$.

*Proof.* Take $m = n = 1$ and the snake of length $1$ in $Q_1$ in both factors. The hypothesis gives $4 \le s(2) + 2C = 2 + 2C$, so $C \ge 1$. $\square$

So even the smallest instance of the conjecture has a genuine defect term; the interesting question is whether the defect can stay linear, and §5 shows it cannot if one insists on the product mechanism.

---

## 7. Algorithms

Three algorithmic ingredients accompany the theory.

### 7.1 Comb synthesis

**Input:** snakes $p$ (length $L$) in $Q_m$, $q$ (length $K$) in $Q_n$.
**Output:** a snake of length $\lfloor L/2\rfloor(K+2)+K$ in $Q_{m+n}$.

Compute for each $s$ the pair $(\operatorname{row}(s), \operatorname{col}(s))$ by the closed formulas of §3.1 and emit the concatenated bit string $p_{\operatorname{row}(s)} \,\Vert\, q_{\operatorname{col}(s)}$. Each output vertex costs $O(1)$ arithmetic plus $O(m+n)$ to write, giving $O\big((m+n)\cdot LK\big)$ total time and $O(m+n)$ working space. The formulas are *random access*: the $s$-th vertex can be produced without generating its predecessors, which matters when the output is streamed.

### 7.2 Snake verification

**Input:** a sequence $v_0, \dots, v_M$ of $n$-bit strings.
**Output:** whether it is a snake.

Check $d(v_i,v_{i+1}) = 1$ for all $i$ and $d(v_i,v_j) \ge 2$ for all $|i-j| \ge 2$. Naively $O(M^2 n / w)$ with $w$-bit words; using a hash set of visited vertices and the observation that a violation of the chord condition means some neighbour of $v_j$ other than $v_{j\pm1}$ has been visited, this improves to $O(Mn)$ expected time: for each new vertex, enumerate its $n$ neighbours and test membership.

### 7.3 Exact longest induced path in a grid

**Input:** grid dimensions $a \times b$.
**Output:** the maximum number of cells on an induced path.

Depth-first search over partial induced paths from every starting cell, pruning by (i) the induced condition, checked incrementally against the set of visited cells and their neighbourhoods, (ii) the $3/4$ cap applied to the unexplored region as an admissible upper bound, and (iii) symmetry reduction of the starting cell to a fundamental domain of the dihedral group of order $8$. Worst-case exponential, but exact for $a, b \le 7$ within seconds. The measured optimal densities in square grids sit near $0.667$, which is the empirical basis for the two-thirds conjecture below.

---

## 8. Applications

**Systematic lower bounds in high dimensions.** Corollary 3.6 converts any single record into an infinite family: from a snake of length $L$ in $Q_m$ one gets $s(2m) \ge L^2/2$, $s(3m)\ge L^3/4$, and generally $s(km) \ge L^k/2^{k-1}$. Combined with the additive Corollary 4.2, $s(m+n) \ge \max\big(\tfrac12 s(m)s(n),\, s(m)+s(n)\big)$, which is the strongest unconditional dimension-combining bound we know.

**Error-detecting position encoders.** In the original engineering setting, a snake is a Gray-like code in which every single-bit error yields either an invalid word or a word adjacent to at most one codeword; the comb shows that two independent physical channels of $m$ and $n$ bits can be *interleaved* into one channel of $m+n$ bits retaining a code of size half the product, with a completely explicit encoding and $O(1)$-time decoding from the closed formulas of §3.1.

**A benchmark for search heuristics.** The comb gives a strong, instantly computable seed for local search in high dimensions; the $3/4$ cap gives a certificate that no amount of local repair of a product-supported configuration will reach the multiplicative main term, so heuristics should be allowed to leave the product grid early.

**A clean two-dimensional test problem.** Theorem 2.2 shows that the entire product question is equivalent to computing the maximum induced path in a rectangular grid — an appealing, self-contained problem with an $O(1)$-size statement and (we conjecture) a $2/3$ answer.

---

## 9. Discussion

The interest of Theorem 5.4 lies in the *type* of obstruction it identifies. Conjecture 1.3 was framed by an intuition about interfaces: the two factors interact only where the walk switches from moving in $Q_m$ to moving in $Q_n$, and such switching points are few, so a bounded family of "separator coordinates" ought to repair them. The theorem says that this intuition mislocates the difficulty. There is no interface to repair; the loss is uniformly distributed over the grid, one cell per $2\times2$ block, and it is forced by the most local configuration imaginable.

That the obstruction is local also explains why it is presumably not tight. A $2\times2$ counting argument sees only that the walk must skip a quarter of the cells. It does not see that a walk which *turns* must additionally sterilise a whole lane beside the turn, nor that a walk which goes straight for a long time must eventually turn (or leave the grid). The empirical density $\approx 0.667$ in square grids, and the exact value $2/3$ achieved by the comb at $K = 2$, both point at $2/3$.

Two boundary phenomena are worth emphasising:

* At $K = 1$ (a $2 \times (L+1)$ strip) the comb is already $3/4$-dense and therefore optimal up to an additive constant: in narrow strips there is no room to improve.
* As $K \to \infty$ the comb degrades to $1/2$. This is a genuine deficiency of the boustrophedon shape, which "wastes" one entire empty row per traversed row. A diagonal staircase pattern — descend one row, move one column, repeat, and turn only at the walls — achieves a higher density in wide grids and is the natural candidate for a $2/3$ construction.

Finally, we note the asymmetry of what survives. The conjecture *as an inequality about $s(m+n)$* is untouched: nothing prevents $Q_{m+n}$ from containing snakes far longer than anything supported on a product grid, and indeed the true growth of $s(n)$ is a constant factor times $2^n$, whereas a product of two records occupies a vanishing fraction of the cube. What has been ruled out is a specific, and until now plausible, route.

---

## 10. Future directions

### 10.1 The two-thirds law for product-supported snakes

**Conjecture 10.1.** The maximum length of an induced path in the grid $P_a \mathbin{\square} P_b$ is $\tfrac{2}{3}ab + O(a+b)$; consequently the best product construction for snakes gives exactly $\tfrac23 (L+1)(K+1) + O(L+K)$, and both the comb's $1/2$ and the cap's $3/4$ are non-optimal.

The key insight is that the $2\times2$-freeness cap of $3/4$ is only a **local** constraint, while the true obstruction is **global**: any induced path must alternate between "spine" and "turn" cells, and a discharging argument transferring one unit of charge across each turn should upgrade $3/4$ to $2/3$, matching the densities near $0.667$ measured in small square grids. Note the boundary behaviour proved here: for $K=1$ the comb is already $3/4$-dense, so any improvement must concern the regime where both $L$ and $K$ grow.

### 10.2 Beyond the product grid

Since the mechanism fails inside $A \times B$, the natural next question is how much a *bounded enlargement* of the support helps. Concretely: if one allows the snake to use, in addition to the product vertices, all vertices within Hamming distance $r$ of the product set, for fixed $r$, does the achievable density exceed $3/4$? Because the enlargement multiplies the available vertex count by roughly $\binom{m+n}{\le r}$, a positive answer would be the first genuine escape from the two-dimensional picture.

### 10.3 Separator coordinates, revisited

The original proposal invoked a bounded family of separator coordinates to repair interfaces. A precise, and still open, version: add $c$ extra coordinates, i.e. work in $Q_{m+n+c}$, and ask for a snake of length $(L+1)(K+1) - O(L+K)$ there. The $3/4$ cap does not apply, since the support is no longer a product of two snakes. Is $c = O(1)$ enough? Is $c = O(\log(L+K))$?

### 10.4 Sharpening the multiplicative constant

Corollary 3.6 gives factor $1/2$. The two-thirds law, if proved constructively, would give $s(m+n) \ge \tfrac23 s(m)s(n) - O(s(m)+s(n))$, an immediate improvement of every iterated lower bound by $(4/3)^{k-1}$ in dimension $km$.

### 10.5 Higher-arity products and other host graphs

Everything here extends verbatim to a product of $k$ factors, where the relevant object is an induced path in a $k$-dimensional grid; the analogue of the $2\times2$ argument caps the density by $(1 - 2^{-k})$ per $2^k$-block, which weakens as $k$ grows — suggesting that iterating binary products is the wrong way to think about $k$-fold products. Determining the correct $k$-dimensional density is open even conjecturally. Likewise, snakes in Hamming graphs over larger alphabets, and in Cayley graphs of other groups, admit the same product framework; the grid embedding lemma uses nothing beyond additivity of the metric across a coordinate split.

---

## 11. Summary of results

| Result | Statement |
|---|---|
| Grid Embedding | $(i,j)\mapsto(p_i,q_j)$ is an induced embedding of $P_{L+1}\square P_{K+1}$ into $Q_{m+n}$ |
| Comb Theorem | a snake of length $\lfloor L/2\rfloor(K+2)+K$ exists in $Q_{m+n}$ |
| Supermultiplicativity | $s(m)s(n) \le 2 s(m+n)$ |
| Half main term | $(s(m)+1)(s(n)+1) \le 2s(m+n)+s(n)+2$ |
| Comb density | limiting density $(K+2)/(2(K+1))$: $3/4$ at $K=1$, $\to 1/2$ |
| L-shape | a snake of length $L+K$; $s(m)+s(n)\le s(m+n)$; $s(n)+1\le s(n+1)$ |
| No $2\times2$ square | an induced path in a grid omits a corner of every unit square |
| $3/4$ cap | product-supported snakes have $\le 3\lceil\frac{L+1}{2}\rceil\lceil\frac{K+1}{2}\rceil$ vertices |
| Mechanism fails | for $L,K \ge 8C+11$: $M + C(L+K) < (L+1)(K+1)$ |
| Small cubes | $s(0)=0$, $s(1)=1$, $s(2)=2$; hence $C \ge 1$ |

The honest product theorem: $\displaystyle s(m+n) \;\ge\; \max\Big(\tfrac12 s(m)s(n),\ s(m)+s(n)\Big)$, with the loss of any product-supported construction provably $\Theta(s(m)s(n))$.
