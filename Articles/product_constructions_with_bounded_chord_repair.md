# The Snake That Could Not Fill Its Box

## A story about coiling through hypercubes, multiplying records, and a beautiful conjecture that turned out to be right for the wrong reason

### A game in a very high-dimensional room

Imagine a room whose corners are all the strings of $n$ zeros and ones. There are $2^n$ of them, and two corners are joined by a corridor exactly when their strings differ in a single position. This is the $n$-dimensional hypercube $Q_n$: for $n = 2$ it is a square, for $n = 3$ an ordinary cube, and for $n = 12$ it is a structure with $4096$ corners that no one can draw but everyone can compute with.

Now play the following game. Starting at some corner, walk from corner to corner along corridors, and obey one strict rule: **you may never step to a corner that is adjacent to any corner you have already visited, other than the one you just came from.** Your path must be, in the language of graph theory, an *induced path*: the corners you visit, together with the corridors between them, must form a plain path with no shortcuts. No chords allowed.

The resulting object is called a **snake in the box**. Its *length* is the number of steps, and the longest possible length in $Q_n$ is written $s(n)$. In symbols: a snake of length $L$ is a sequence of corners $v_0, v_1, \dots, v_L$ such that consecutive corners differ in exactly one coordinate, $d(v_i, v_{i+1}) = 1$, and any two non-consecutive corners differ in at least two coordinates, $d(v_i, v_j) \ge 2$ whenever $|i - j| \ge 2$. Here $d$ is the Hamming distance, the number of positions where two strings disagree.

The first few values are easy and then abruptly stop being easy:

$$s(1) = 1, \quad s(2) = 2, \quad s(3) = 4, \quad s(4) = 7, \quad s(5) = 13, \quad s(6) = 26, \quad s(7) = 50, \quad s(8) = 98.$$

Beyond dimension $8$, nobody knows the exact answer. Values for $n = 9, 10, 11, \dots$ are the results of enormous computer searches that establish lower bounds, and the records fall every few years by a handful of steps. It is one of those problems where the statement fits in a tweet and the answer resists a century of effort.

The problem is not merely recreational. Snakes in the box were introduced in the 1950s as error-detecting codes for analogue-to-digital converters: if a physical quantity is encoded as a position along a snake, then a single-bit error can never carry you to another valid codeword, because valid codewords that are not neighbours in the snake are at Hamming distance at least two. The same "no chords" condition appears in circuit testing, in disk-encoder design, and as a benchmark for combinatorial search heuristics.

### The seductive idea: multiply your records

Because the record hunt proceeds dimension by dimension — a long search in $Q_{11}$ tells you nothing about $Q_{12}$ — an obvious dream presents itself. The hypercube factorises perfectly:

$$Q_{m+n} = Q_m \times Q_n.$$

Splitting the $m+n$ coordinates into the first $m$ and the last $n$, a corner of the big cube is a *pair* consisting of a corner of $Q_m$ and a corner of $Q_n$, and — this is the key elementary fact — Hamming distance is simply additive across the split:

$$d\big((a, b), (a', b')\big) = d(a, a') + d(b, b').$$

So take your record snake $p_0, \dots, p_L$ in $Q_m$ and your record snake $q_0, \dots, q_K$ in $Q_n$. The $(L+1)(K+1)$ pairs $(p_i, q_j)$ form a grid inside $Q_{m+n}$. If only you could thread a single snake through *all* of them, you would get a snake of length $(L+1)(K+1) - 1$ in dimension $m+n$, and record-breaking in high dimensions would become an exercise in bookkeeping. Even losing a little at the seams would be spectacular. Hence the conjecture that motivated this work:

> **Conjecture (bounded chord repair).** There is an absolute constant $C$ such that snakes of lengths $L$ in $Q_m$ and $K$ in $Q_n$ can be combined into a snake in $Q_{m+n}$ of length at least $(L+1)(K+1) - C(L+K)$.

The multiplicative main term $(L+1)(K+1)$ is the size of the grid; the $C(L+K)$ is the "repair budget", the intuition being that whatever goes wrong goes wrong only along the boundary, and boundaries are one-dimensional.

This article tells the story of what happens when you take that conjecture seriously enough to check it. The short version: the product idea is genuinely powerful — it delivers *half* of the multiplicative term unconditionally, and it delivers it in a completely explicit, constructive way. But the proposed *mechanism* is provably dead: a snake supported on the product grid loses not $O(L+K)$ but a constant fraction of the whole grid, $\Theta(LK)$. The dream and its obstruction turn out to be two sides of a single, very pretty fact about squares.

### The grid inside the cube

Everything rests on one observation. Along a snake, the distances between vertices are as rigid as they can be: $d(p_i, p_j) = 0$ if $i = j$, exactly $1$ if $|i-j| = 1$, and at least $2$ otherwise. Combine this with the additivity of Hamming distance across the coordinate split and you get:

> **Grid Embedding Lemma.** Let $p$ be a snake of length $L$ in $Q_m$ and $q$ a snake of length $K$ in $Q_n$. Then the map $(i, j) \mapsto (p_i, q_j)$ is an isometric embedding of the $(L+1) \times (K+1)$ grid graph into $Q_{m+n}$, and it is *induced*: two grid cells $(i,j)$ and $(i',j')$ are joined by a corridor of the cube if and only if they are orthogonally adjacent cells, i.e. $|i-i'| + |j-j'| = 1$. Consequently **every induced path in the $(L+1) \times (K+1)$ grid is a snake in $Q_{m+n}$**, and every snake living inside the product grid is an induced path there.

That is a wonderful reduction. A question about a mysterious high-dimensional graph becomes a question about squared paper: *how long can a self-avoiding, non-touching walk on a rectangular grid be?* "Non-touching" is the key word — a snake may not pass beside itself, only cross to a fresh cell, and a cell that shares an edge with an earlier cell (other than its immediate predecessor) is forbidden.

### The comb: half the product, guaranteed

Here is a walk that satisfies the rule, drawn for a grid with several rows:

```
row 0:  ●─●─●─●─●─●─●
                    │
row 1:              ●
                    │
row 2:  ●─●─●─●─●─●─●
        │
row 3:  ●
        │
row 4:  ●─●─●─●─●─●─●
```

Sweep across an entire row; drop *two* rows through a single connector cell; sweep back across the next full row; repeat. The rows in between are left completely empty, and that emptiness is not waste but necessity: two adjacent full rows would touch each other everywhere. Because the shape looks like a comb with widely spaced teeth — or a boustrophedon, the "as the ox ploughs" writing of ancient inscriptions — we call it the **comb**.

Counting is straightforward. Each "block" consists of one full row of $K+1$ cells plus one connector cell, and there are $\lfloor L/2 \rfloor$ complete blocks followed by a final full row. So:

> **Comb Theorem.** From snakes of lengths $L$ in $Q_m$ and $K$ in $Q_n$ one can construct a snake in $Q_{m+n}$ of length
> $$\operatorname{comb}(L, K) = \left\lfloor \tfrac{L}{2} \right\rfloor (K + 2) + K.$$

The consequences are immediate and, we think, striking:

> **Supermultiplicativity.** $s(m) \cdot s(n) \le 2\, s(m+n)$ for all $m, n$.
>
> **Half of the main term.** $\big(s(m) + 1\big)\big(s(n) + 1\big) \le 2\, s(m+n) + s(n) + 2$.

In words: *half of the conjectured multiplicative main term is unconditionally true, by an explicit construction that anyone can write down in ten lines.* If you have a snake of length $L$ in $Q_{11}$ and a snake of length $K$ in $Q_{11}$, you immediately have a snake of length about $LK/2$ in $Q_{22}$. No search, no heuristics, no luck.

The comb also has a complementary, humbler cousin. Traverse the first snake all the way along the bottom row, turn the corner, and traverse the second snake all the way up the right-hand column. That **L-shape** is also induced, giving a snake of length $L + K$ and hence the superadditivity $s(m) + s(n) \le s(m+n)$, together with the strict monotonicity $s(n) + 1 \le s(n+1)$ (take $m = 1$). The L-shape wins only in degenerate regimes; the comb dominates as soon as both factors are long.

So the honest product theorem currently reads
$$s(m+n) \ \ge\ \max\left(\tfrac{1}{2}\, s(m)\, s(n),\ \ s(m) + s(n)\right).$$

### The obstruction: you cannot have all four corners

Could a cleverer walk on the grid do better and reach the full $(L+1)(K+1) - O(L+K)$? No — and the reason is embarrassingly simple.

Look at any $2 \times 2$ block of grid cells: four cells forming a little square. Suppose an induced path visited all four of them. Each pair of orthogonally adjacent cells among the four is a corridor, and along an induced path, two visited vertices are joined by a corridor **only if they are consecutive on the path**. The four cells of a square have four adjacent pairs (the four sides), so the path would have to make all four pairs consecutive. But four positions along a path admit at most three consecutive pairs. Contradiction.

> **No-Square Lemma.** An induced path in a grid never contains all four cells of any $2 \times 2$ square.

Now tile the whole $(L+1) \times (K+1)$ grid by disjoint $2 \times 2$ squares. Each square contributes at most three visited cells, so:

> **The Three-Quarters Cap.** A snake supported on the product of a length-$L$ snake and a length-$K$ snake has at most
> $$3 \left\lceil \tfrac{L+1}{2} \right\rceil \left\lceil \tfrac{K+1}{2} \right\rceil \ \approx\ \tfrac{3}{4}(L+1)(K+1)$$
> vertices.

And this immediately kills the mechanism:

> **The Product Mechanism Fails.** Fix any constant $C$. As soon as both $L$ and $K$ exceed $8C + 11$, *no* snake supported on the product of the two snakes has length $(L+1)(K+1) - C(L+K)$; its length $M$ satisfies the strict inequality $M + C(L+K) < (L+1)(K+1)$.

Read that carefully, because it is a genuinely negative result about a genuinely appealing idea. The loss suffered by any product construction is not a boundary effect of size $O(L+K)$. It is a bulk effect of size $\Theta(LK)$: a constant fraction of the grid, at least a quarter of it, must be left untouched. "Bounded chord repair" cannot possibly work while the repaired snake stays inside $A \times B$. If the conjecture is true, its proof must escape the product grid entirely and use corners of $Q_{m+n}$ that are not of the form $(p_i, q_j)$.

### How much room is left between the two bounds?

We now have a construction achieving density $\to 1/2$ and a cap at $3/4$. Where is the truth?

The comb's exact density is instructive. It occupies $\lfloor L/2 \rfloor (K+2) + K + 1$ of the $(L+1)(K+1)$ cells, which for even $L$ is a fraction
$$\frac{K+2}{2(K+1)}.$$
When $K = 1$ — a grid two cells wide — this equals exactly $3/4$, matching the cap up to an additive constant. When $K = 2$ it is $2/3$; when $K = 3$, $5/8$; and it decays monotonically to $1/2$ as $K \to \infty$.

This is a rather satisfying state of affairs. It means the conjecture is *not* failing because our construction is weak in the narrow regime; in narrow strips the comb is essentially optimal. The gap opens only when both factors are long — and there the truth appears to be neither $1/2$ nor $3/4$. Exhaustive computation of the longest induced path in small square grids gives densities hovering near $0.667$, which suggests:

> **The Two-Thirds Conjecture.** The maximum length of an induced path in the $a \times b$ grid is $\tfrac{2}{3}ab + O(a+b)$; hence the best possible product construction for snakes yields exactly $\tfrac{2}{3}(L+1)(K+1) + O(L+K)$, and both the comb's $1/2$ and the cap's $3/4$ are non-optimal.

The intuition behind $2/3$ is that the $2\times2$ argument is purely *local*, whereas the real obstruction is *global*. An induced path in a grid alternates between "spine" segments, which are cheap, and "turns", which force an entire adjacent lane to stay empty. A discharging argument that transfers one unit of charge across every turn should upgrade $3/4$ to $2/3$. On the construction side, one wants a walk that turns as rarely as the parity of the grid permits — a diagonal staircase rather than a comb.

Meanwhile, one small but decisive check settles a detail of the original statement: the constant $C$ cannot be taken to be zero. In $Q_1$ there is a snake of length $1$; in $Q_2$ the longest snake has length exactly $2$ (a path of three corners of a square; a fourth corner would be antipodal to one already visited, which is a chord in disguise). The main term for $L = K = 1$ would be $(1+1)(1+1) = 4$, but $s(2) = 2$. So the smallest possible instance already forces $C \ge 1$.

### What survives, and why it matters

Let us take stock of the landscape as it now stands.

*The conjecture, as a statement about $s(m+n)$, is still open.* Nothing here shows that $s(m+n) \ge (L+1)(K+1) - C(L+K)$ is false; it shows that the natural route to it is blocked.

*The mechanism is dead.* Products, combined with any amount of interface repair that stays inside the product grid, lose a constant fraction of the grid. That is a theorem, not a failed search.

*A real, usable product theorem is now on the books.* $s(m+n) \ge \tfrac{1}{2} s(m) s(n)$ is fully explicit and constructive: it converts every record in low dimensions into a lower bound in every higher dimension, forever. Multiplicativity of records was the whole point of the original dream, and half of it survives intact. If a search establishes a snake of length $L$ in dimension $m$, then dimension $km$ inherits a snake of length roughly $L^k / 2^{k-1}$ — exponential growth in the dimension, obtained for free from a single record.

*The residual question is beautifully concrete.* Forget hypercubes: how long is the longest induced path in an $a \times b$ grid? That is a question a curious high-school student can play with on graph paper, and it is now the precise bottleneck for one direction of a sixty-year-old coding problem. We believe the answer is $\tfrac{2}{3}ab$ to leading order, and we believe the proof of the upper bound is a discharging argument waiting to be written down.

There is a pleasing lesson in the shape of this story. The original conjecture said, in effect, *"the difficulty lives at the boundary"*. The truth is the opposite: the difficulty lives in the bulk, and it is caused by the single most local configuration imaginable — four cells arranged in a square, of which you may keep only three. Sometimes an obstruction that fits in a $2 \times 2$ box is enough to reshape an entire research programme.

And the snakes? They keep coiling. Every corner they refuse is a corner some future construction may learn to use — just not, we now know, by multiplying two old snakes together and patching the seams.
