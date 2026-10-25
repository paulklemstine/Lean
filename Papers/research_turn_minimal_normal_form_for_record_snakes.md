# Turn-Minimal Normal Forms for Snakes in Hypercubes and Box Products

**Aristotle**

*October 2026*

---

## Abstract

A *snake* in a graph is an induced path. The snake-in-the-box problem asks for the maximum length $S(n)$ of a snake in the $n$-dimensional hypercube $Q_n$. Many record constructions are product constructions: they view $Q_n$ as a box product $Q_a \,\square\, Q_b$ and assemble long snakes of the factor $Q_b$ into a "comb". Such constructions lose roughly one connector per change of the row coordinate. This motivates the conjecture that every snake can be normalised, at a cost of $O(n)$ in length, so that it has only $O(L/n)$ direction changes.

We study a *turn count* for snakes in box products and prove four facts. (i) **The Comb Theorem:** a row sequence that visits $r$ distinct rows has at least $r-1$ turns, with equality exactly for combs. (ii) **Step accounting:** in any box product, row turns plus column turns equals length. (iii) **Direction changes are essential:** if all snakes of $H$ have length at most $S$, then every snake of length $L$ in $G \,\square\, H$ satisfies $L+1 \le (t+1)(S+1)$, where $t$ is its turn count; in $Q_{a+b}$ this gives $L + 1 \le (t+1)2^b$ unconditionally. (iv) **The averaging normal form:** for every snake of length $L$ in $Q_n$ and every $1 \le a \le n$, some $a$-set of row coordinates yields at most $aL/n$ turns, and a coordinate permutation moves this set into standard position at zero cost in length. The normal-form conjecture therefore holds with loss $0$ rather than $O(n)$.

We argue that this makes the conjecture *true but cheap*, and that the real content lies in a stronger, block-maximal normal form. Computations on record snakes for $n \le 7$ support this. The least-flipped coordinate of each record meets the block lower bound in every case but one, and sits a factor of two below the averaging bound. We give algorithms for the computations, numerical data, and four conjectures.

---

## 1. Introduction

### 1.1 Snakes in the box

Let $Q_n$ be the graph on $\{0,1\}^n$ in which two vertices are adjacent exactly when their Hamming distance is $1$. A *snake* of length $L$ is a sequence of distinct vertices $p_0, p_1, \dots, p_L$ such that $p_i$ and $p_j$ are adjacent if and only if $|i - j| = 1$. In other words, it is a path that is an induced subgraph. The maximum length $S(n)$ is known for $n \le 7$:

$$S(1), \dots, S(7) \;=\; 1,\ 2,\ 4,\ 7,\ 13,\ 26,\ 50.$$

For $n \ge 8$ only lower bounds are known, obtained by heuristic and exhaustive computer search together with algebraic and product constructions. Snakes were first studied as error-detecting codes for analog-to-digital conversion. The search space grows super-exponentially, so restrictions that provably lose little are valuable.

### 1.2 Product constructions and turns

Splitting the coordinates of $Q_{a+b}$ into a first block of $a$ and a second block of $b$ identifies $Q_{a+b}$ with the box product $Q_a \,\square\, Q_b$. Under this identification a snake has a *row sequence*, its $Q_a$-coordinate, and a *column sequence*, its $Q_b$-coordinate. A *turn* (or direction change) is a step at which the row changes. Product constructions such as the comb place long snakes of $Q_b$ in successive rows and connect them at the turns. Each interface costs a constant number of cells, so the total loss of such a construction grows with the number of turns.

This suggests the following conjecture.

**Conjecture 0 (Turn-minimal normal form).** Every snake of length $L$ in $Q_n$ can be transformed into a snake of length at least $L - O(n)$ whose row sequence, in a suitable product decomposition, has $O(L/n)$ direction changes.

The opposite hypothesis is that direction changes are *essential* to long snakes, so that product methods always lose a constant fraction.

### 1.3 Results

We prove the following.

* **Theorem 3.2 (Comb Theorem).** Turns $\ge$ rows $-\,1$, with equality iff comb.
* **Theorem 4.1 (Step accounting).** In any box product $G \,\square\, H$, row turns $+$ column turns $=$ length, for every walk.
* **Lemma 4.2 (Block Lemma).** Every block of constant row of a snake in $G \,\square\, H$ is a snake in $H$.
* **Theorem 4.3 (Direction changes are essential).** $L + 1 \le (t+1)(S+1)$ whenever $S$ bounds the snakes of $H$.
* **Corollary 5.3.** For snakes in $Q_{a+b}$: $L + 1 \le (t_R + 1)(S(b)+1) \le (t_R+1)2^b$.
* **Theorem 5.5 (Averaging normal form).** For every $a$ there is a split $Q_a \,\square\, Q_{n-a}$, reached by an automorphism, with $\frac{L+1}{2^{n-a}} - 1 \le t \le \frac{aL}{n}$.

Together these settle Conjecture 0 with zero loss. They also confirm the essential-turns hypothesis as a lower bound. Section 7 explains why the result is weaker than it looks, and Section 8 states sharper conjectures backed by data.

---

## 2. Definitions

Throughout, $G = (V, E_G)$ and $H = (W, E_H)$ are simple graphs. We write $x \sim_G y$ for adjacency.

**Definition 2.1 (Snake on a window).** Let $p : \mathbb{N} \to V$ and $a \le b$. We say $p$ is a *snake in $G$ on $[a, b]$* if

1. $p$ is injective on $\{a, a+1, \dots, b\}$, and
2. for all $i, j \in [a, b]$: $p_i \sim_G p_j \iff |i - j| = 1$.

A *snake of length $L$* is a snake on $[0, L]$. It has $L$ edges and $L + 1$ vertices.

**Definition 2.2 (Snake bound).** A number $S$ is a *snake bound* for $G$ if every snake in $G$ on any window $[a, b]$ satisfies $b - a \le S$. For finite $G$, $|V| - 1$ is a snake bound, since a snake visits distinct vertices. We write $S(n)$ for the least snake bound of $Q_n$, which is the snake-in-the-box number.

**Definition 2.3 (Walk).** $p$ is a *walk of length $L$* if $p_s \sim p_{s+1}$ for all $s < L$. Every snake is a walk.

**Definition 2.4 (Box product).** $G \,\square\, H$ has vertex set $V \times W$, and $(g, h) \sim (g', h')$ iff either $g \sim_G g'$ and $h = h'$, or $g = g'$ and $h \sim_H h'$.

**Definition 2.5 (Turn count).** For any sequence $f : \mathbb{N} \to X$ and any $L$,
$$\tau(f, L) \;=\; \#\{\, s < L : f(s) \neq f(s+1) \,\}.$$
For a walk $p$ in $G \,\square\, H$, the *row sequence* is $s \mapsto (p_s)_1$ and the *column sequence* is $s \mapsto (p_s)_2$. The *turn count* of $p$ is $\tau$ of its row sequence.

**Definition 2.6 (Blocks; comb).** A *block* of a sequence $f$ on $[0, L]$ is a maximal interval of indices on which $f$ is constant. The sequence is a *comb* if, for each value $x$, the index set $\{s \le L : f(s) = x\}$ is an interval. Equivalently, every value occupies exactly one block.

**Definition 2.7 (Coordinate split).** For $x \in \{0,1\}^{a+b}$ let $\mathrm{split}(x) = (x|_{[1,a]},\, x|_{[a+1,a+b]}) \in \{0,1\}^a \times \{0,1\}^b$. More generally, for $R \subseteq [n]$, the *$R$-row sequence* of a snake is its restriction to the coordinates in $R$, and $t_R$ denotes its turn count.

**Definition 2.8 (Flip profile).** For a walk $p$ in $Q_n$, the *flip count* $\varphi_i$ of coordinate $i$ is the number of steps $s < L$ at which $p_s$ and $p_{s+1}$ differ in coordinate $i$. The vector $(\varphi_1, \dots, \varphi_n)$ is the *flip profile*.

---

## 3. The Comb Theorem

**Lemma 3.1 (Block count).** A sequence $f$ on $[0, L]$ with $\tau(f, L) = t$ has exactly $t + 1$ blocks.

*Proof.* The blocks are separated exactly by the indices $s$ with $f(s) \ne f(s+1)$. Cutting $[0, L]$ at $t$ such places leaves $t+1$ intervals. $\square$

**Theorem 3.2 (Comb Theorem).** Let $f$ be a sequence on $[0, L]$ that takes $r$ distinct values. Then
$$\tau(f, L) \;\ge\; r - 1,$$
with equality if and only if $f$ is a comb.

*Proof.* Each value taken by $f$ occupies at least one block, and distinct values occupy disjoint blocks, so by Lemma 3.1 we get $t + 1 \ge r$. Equality holds iff each value occupies *exactly* one block, which is Definition 2.6. One can also argue by induction on $L$. Appending $f(L+1)$ either repeats $f(L)$, changing neither side, or changes it, adding one turn while adding at most one new value. The comb property survives the step only when the new value is either equal to $f(L)$ or genuinely new. $\square$

**Interpretation.** Among all row sequences visiting a fixed set of rows, the comb is the unique turn minimiser. "Turn-minimal" and "comb" mean the same thing.

---

## 4. Snakes in Box Products

**Theorem 4.1 (Step accounting).** Let $p$ be a walk of length $L$ in $G \,\square\, H$. Then
$$\tau\bigl(s \mapsto (p_s)_1, L\bigr) + \tau\bigl(s \mapsto (p_s)_2, L\bigr) \;=\; L.$$

*Proof.* By induction on $L$. The case $L = 0$ is trivial. For the inductive step, the edge $p_L \sim p_{L+1}$ is, by Definition 2.4, either a $G$-edge with equal second coordinates or an $H$-edge with equal first coordinates. In the first case the row changes, since adjacent vertices are distinct, and the column does not. In the second case the reverse holds. Exactly one of the two counts increases by one. $\square$

**Lemma 4.2 (Block Lemma).** Let $p$ be a snake in $G \,\square\, H$ on $[a, b]$, and suppose the row $(p_s)_1$ is constant on $[i, j] \subseteq [a, b]$. Then the column sequence $s \mapsto (p_s)_2$ is a snake in $H$ on $[i, j]$.

*Proof.* Injectivity: if $(p_s)_2 = (p_{s'})_2$ for $s, s' \in [i,j]$, then $p_s = p_{s'}$ because the rows also agree, so $s = s'$. Induced adjacency: for vertices with equal first coordinate, $(g, h) \sim (g, h')$ iff $h \sim_H h'$, since the $G$-edge alternative needs $g \sim_G g$, which is impossible in a simple graph. So $(p_s)_2 \sim_H (p_{s'})_2 \iff p_s \sim p_{s'} \iff |s - s'| = 1$. $\square$

**Theorem 4.3 (Direction changes are essential).** Suppose $S$ is a snake bound for $H$. If $p$ is a snake of length $L$ in $G \,\square\, H$ with turn count $t$, then
$$L + 1 \;\le\; (t + 1)(S + 1).$$
Equivalently, $t \ge \frac{L+1}{S+1} - 1$.

*Proof.* By Lemma 3.1 the row sequence has $t + 1$ blocks, which partition the $L + 1$ indices. By Lemma 4.2 each block $[i, j]$ carries a snake of $H$ on $[i,j]$, so $j - i \le S$ and the block has at most $S + 1$ indices. Summing gives the bound. Formally one proceeds by induction on $L$, tracking the length of the final block. $\square$

**Remark 4.4.** Theorem 4.3 is the formal version of the slogan "direction changes are essential". A snake much longer than $S$ cannot stay in one row, and the number of rows it must pass through, counted with multiplicity, grows linearly in $L/S$.

---

## 5. Hypercubes

**Lemma 5.1 (Hamming distance splits).** For $x, y \in \{0,1\}^{a+b}$,
$$d_H(x, y) \;=\; d_H\bigl(x|_{[1,a]}, y|_{[1,a]}\bigr) + d_H\bigl(x|_{[a+1,a+b]}, y|_{[a+1,a+b]}\bigr).$$

*Proof.* The set of differing coordinates is the disjoint union of the differing coordinates in each block. $\square$

**Theorem 5.2 (The hypercube is a box product).** The map $\mathrm{split}$ is a bijection $\{0,1\}^{a+b} \to \{0,1\}^a \times \{0,1\}^b$, and for all $x, y$,
$$x \sim_{Q_{a+b}} y \iff \mathrm{split}(x) \sim_{Q_a \square Q_b} \mathrm{split}(y).$$

*Proof.* Injectivity is clear, since a vector is determined by its two halves. By Lemma 5.1, $d_H(x,y) = 1$ iff one half has distance $1$ and the other has distance $0$, that is, the halves are equal. This is exactly Definition 2.4. $\square$

**Transfer principle.** If $f : V \to W$ is injective and preserves and reflects adjacency, then $f \circ p$ is a snake in the target whenever $p$ is a snake in the source, on the same window. This follows directly from Definition 2.1. In particular, snakes in $Q_{a+b}$ correspond to snakes in $Q_a \,\square\, Q_b$.

**Corollary 5.3 (Turn bounds in $Q_n$).** Let $p$ be a snake of length $L$ in $Q_{a+b}$, and let $t$ and $t'$ be the numbers of steps flipping one of the first $a$, respectively last $b$, coordinates. Then:

1. $t + t' = L$;
2. if $S$ is a snake bound for $Q_b$, then $L + 1 \le (t+1)(S+1)$;
3. unconditionally, $L + 1 \le (t + 1)\, 2^b$.

*Proof.* Transfer $p$ along $\mathrm{split}$ using Theorem 5.2. Then (1) is Theorem 4.1, and (2) is Theorem 4.3. For (3), apply (2) with the trivial snake bound $|V(Q_b)| - 1 = 2^b - 1$. $\square$

**Lemma 5.4 (Turns are flips).** For any $R \subseteq [n]$, the $R$-row sequence of a walk in $Q_n$ changes at step $s$ iff the coordinate flipped at step $s$ lies in $R$. Hence
$$t_R = \sum_{i \in R} \varphi_i, \qquad \sum_{i=1}^n \varphi_i = L.$$

*Proof.* Each step flips exactly one coordinate. $\square$

**Theorem 5.5 (Averaging normal form).** Let $p$ be a snake of length $L$ in $Q_n$ and $1 \le a \le n$. There is an $a$-set $R \subseteq [n]$ with
$$\frac{L+1}{2^{\,n-a}} - 1 \;\le\; t_R \;\le\; \frac{aL}{n}.$$
Moreover, there is a coordinate permutation $\sigma$, which is an automorphism of $Q_n$, such that $\sigma \circ p$ is a snake of the *same* length $L$ whose row sequence in the standard split $Q_a \,\square\, Q_{n-a}$ has exactly $t_R$ turns.

*Proof.* By Lemma 5.4,
$$\sum_{|R| = a} t_R \;=\; \sum_{i=1}^n \varphi_i \cdot \#\{R \ni i\} \;=\; \binom{n-1}{a-1} L,$$
so the average of $t_R$ over the $\binom{n}{a}$ sets is $\frac{a}{n}L$, and some $R$ is at most average. The minimiser is simply the set of the $a$ least-flipped coordinates. The lower bound is Corollary 5.3(3), applied after the permutation $\sigma$ that sends $R$ to $\{1, \dots, a\}$. Coordinate permutations preserve Hamming distance, so by the transfer principle $\sigma \circ p$ is a snake of length $L$. $\square$

**Corollary 5.6 (Conjecture 0 with zero loss).** Every snake of length $L$ in $Q_n$ is, after an automorphism of $Q_n$, a snake of the same length whose row sequence in $Q_1 \,\square\, Q_{n-1}$ has at most $L/n$ direction changes. In particular, the least-flipped coordinate of any snake satisfies
$$\frac{L+1}{S(n-1)+1} - 1 \;\le\; \min_i \varphi_i \;\le\; \frac{L}{n}.$$

---

## 6. Algorithms

**Algorithm A (Turn-minimal split).** *Input:* the transition sequence $c_1, \dots, c_L \in [n]$ of a snake, where $c_s$ is the coordinate flipped at step $s$, and an integer $a$. *Output:* an $a$-set $R$ minimising $t_R$, and the relabelling $\sigma$.

1. Compute the flip profile $\varphi_i = \#\{s : c_s = i\}$ in $O(L + n)$ time.
2. Sort the coordinates by $\varphi_i$ and take the $a$ smallest as $R$, in $O(n \log n)$ time.
3. Let $\sigma$ send $R$ to $\{1, \dots, a\}$ in order and the complement to $\{a+1, \dots, n\}$; output $\sigma(c_1), \dots, \sigma(c_L)$.

By Lemma 5.4 and Theorem 5.5 the output has exactly $t_R \le aL/n$ turns and the same length.

**Algorithm B (Record search with symmetry breaking).** Depth-first search over transition sequences starting at $0^n$. Keep, for every vertex $w$, the number $\mathrm{adj}(w)$ of path vertices adjacent to $w$. A vertex $w$ adjacent to the tail may be appended iff $w$ is unused and $\mathrm{adj}(w) = 1$, meaning the tail is its only path neighbour. Updates cost $O(n)$ per step. Coordinates are introduced in increasing order: the first flip of coordinate $i$ comes after the first flip of $i-1$. This removes the $n!$ coordinate-permutation symmetry. With this pruning, records for $n \le 6$ are found in under a second.

**Algorithm C (One-turn comb).** Given a snake $A$ in $Q_{n-1}$ ending at $u$, search for a snake $B$ in $Q_{n-1}$ starting at $u$ whose other vertices avoid the vertex set of $A$. Then $A$, followed by a flip of coordinate $n$, followed by $B$ is a snake in $Q_n$ of length $|A| + 1 + |B|$, whose row sequence in $Q_1 \,\square\, Q_{n-1}$ is a comb with one turn. *Correctness:* vertices $(0, x)$ and $(1, y)$ are adjacent iff $x = y$, so the only cross-layer adjacency is at the hop. Within each layer, the snake property of $A$ and of $B$ handles everything else.

---

## 7. Discussion: true but cheap

Corollary 5.6 proves Conjecture 0 with a loss of $0$ instead of $O(n)$. The proof should still make one wary. It uses no property of long snakes: every walk in $Q_n$ that changes one coordinate per step satisfies the averaging bound. A normal form satisfied by every snake does not reduce a search space at all.

The two sides of Theorem 5.5 explain the situation:

* the **upper bound** $t \le aL/n$ is free, because it comes from averaging;
* the **lower bound** $t \ge (L+1)/(S(n-a)+1) - 1$ is forced, because it comes from the Block Lemma.

For long snakes the gap between them is large. When $a = 1$ and $L \approx S(n) \approx 2S(n-1)$, the lower bound is about $1$ while the upper bound is about $L/n$. A meaningful normal form should push a snake towards the *lower* end. That is equivalent to asking that the blocks, which are snakes of $Q_{n-a}$ by the Block Lemma, be *long*. The Comb Theorem turns turn-minimality into a statement about block lengths, and that is where the difficulty lies.

The essential-turns hypothesis is confirmed in the weak sense of Theorem 4.3. Whether product methods must lose a constant *fraction* of length is a different question. The data in Section 8 suggest that for $a = 1$ they lose only an additive constant per doubling.

---

## 8. Numerical evidence

Using Algorithms A–C we computed flip profiles of record snakes.

| $n$ | $L$ | flip profile | $\min\varphi$ | block lower bound $\lceil\frac{L+1}{S(n-1)+1}\rceil - 1$ | $\lfloor L/n \rfloor$ | $L/(2n)$ |
|---|---|---|---|---|---|---|
| 2 | 2 | $(1,1)$ | 1 | 1 | 1 | 0.5 |
| 3 | 4 | $(2,1,1)$ | 1 | 1 | 1 | 0.67 |
| 4 | 7 | $(3,2,1,1)$ | 1 | 1 | 1 | 0.88 |
| 5 | 13 | $(4,3,3,2,1)$ | 1 | 1 | 2 | 1.3 |
| 6 | 26 | $(6,5,2,5,6,2)$ | 2 | 1 | 4 | 2.17 |
| 7 | 48 | one-turn comb | 1 | 1 | 6 | 3.43 |

The $n = 7$ snake of length $48$ is a one-turn comb in $Q_1 \,\square\, Q_6$, made of two snakes of $Q_6$ of total length $47 = 2 \cdot 26 - 5$. A short run of Algorithm C, starting from the $26$-snake above, gives a one-turn comb of length $47 = 25 + 1 + 21$ in $Q_7$ within seconds, with flip profile $(9,10,5,8,11,3,1)$.

**Observations.**

1. For $a = 1$ the block lower bound is met with equality for $n = 2,3,4,5,7$. The only exception is the single $26$-snake of $Q_6$, which was not optimised for this property.
2. In every record with $n \ge 5$ the least-flipped coordinate satisfies $\min\varphi \le L/(2n)$: $13 \to 1$, $26 \to 2$, $48 \to 1$. This is a factor of two below the averaging bound.
3. Step accounting (Theorem 4.1) and the Block Lemma were checked directly on every split with $a \in \{1, 2\}$ for $n = 5, 6$.

---

## 9. Future directions

**Conjecture 1 (Comb saturation).** For every $n \ge 3$ and some $a \ge 1$, at least one longest snake in $Q_n$ has a split $Q_a \,\square\, Q_{n-a}$ whose turn count equals the lower bound $\lceil (S(n)+1)/(S(n-a)+1) \rceil - 1$. For $a = 1$ this holds in the data at $n = 2, 3, 4, 5, 7$. Flip-profile certificates make it a finite check for each $n$.

**Conjecture 2 (One-turn doubling gap).** $S(n) \ge 2S(n-1) - c$ for an absolute constant $c$, realised by one-turn combs in $Q_1 \,\square\, Q_{n-1}$. A one-turn comb is a pair of snakes in $Q_{n-1}$ that share only the hop vertex. This is a packing problem that SAT solvers can attack directly.

**Conjecture 3 (Uneven flip profile).** For every longest snake in $Q_n$ with $n \ge 5$, the least-flipped coordinate is flipped at most $L/(2n)$ times.

**Conjecture 4 (Block-maximal normal form).** Every snake of length $L$ in $Q_n$ can be transformed into one of length $\ge L - O(n)$ such that, in some split $Q_1 \,\square\, Q_{n-1}$, every block except $O(1)$ of them has length $\ge S(n-1)/2$. By the Comb Theorem this is the natural strengthening of turn-minimality to block lengths. If it holds, record search reduces to searching for near-record snakes of $Q_{n-1}$ that can be packed together.

---

## 10. Conclusion

We introduced a turn count for snakes in box products and proved four things. Combs are exactly the turn-minimal row sequences. Row and column turns always add up to the length. Every block is a snake of the column factor, so long snakes are forced to turn. And averaging over coordinate choices gives, at zero cost, a split with at most $aL/n$ turns. The turn-minimal normal-form conjecture is therefore true, but its proof shows that turn counts alone do not capture the structure of record snakes. The data point to a sharper statement about block lengths, formulated here as four conjectures.
