# When Codewords Conspire: The Hunt for Cycle-Containing Families

## A puzzle hidden in plain sight

Imagine you are handed a stack of cards. Each card carries a string of
length $k$, written in an alphabet of $b$ symbols — think of strings like
`0011`, `0101`, `0110` over the two-symbol alphabet $\{0,1\}$, or longer
words over a richer alphabet. The cards look harmless individually. The
interesting behaviour only appears when you compare *two* of them.

Here is the comparison rule. Take two distinct cards, say
$u = u_1 u_2 \cdots u_k$ and $v = v_1 v_2 \cdots v_k$. Build a little
diagram with two columns. The left column has one slot for each symbol of
the alphabet; so does the right column. Now walk down the two words
position by position. At position $i$ you read off the pair $(u_i, v_i)$,
and you draw a line connecting the symbol $u_i$ in the left column to the
symbol $v_i$ in the right column. After processing all $k$ positions you
are left with a **bipartite graph**: dots on the left, dots on the right,
and a tangle of connecting lines.

Some pairs of cards produce a tame, tree-like diagram with no loops. Other
pairs produce a diagram that contains a **cycle** — a closed loop that
returns to where it started without retracing its steps. We will call a
pair of cards *good* when its diagram contains a cycle.

The central question is deceptively simple:

> How many cards can you collect so that **every** pair among them is good?

We call such a collection a **cycle-containing family**. The challenge is
to find the largest possible one for each alphabet size $b$ and each word
length $k$, and to understand the structure of the extremal collections.
This article tells the story of what is now rigorously known, where the
sharp thresholds lie, and why a humble four-vertex square turns out to be
the secret engine of the whole subject.

## The graph behind two words

Let us be precise about the diagram, because everything flows from it.
Fix an alphabet of size $b$, which we model as the set
$\{0, 1, \dots, b-1\}$. A word is a function $u$ that assigns to each
position $i \in \{1, \dots, k\}$ a symbol $u_i$.

Given two words $u$ and $v$, the bipartite graph $G(u,v)$ has vertex set
made of two disjoint copies of the alphabet: a *left copy*
$\{\mathrm{L}_0, \dots, \mathrm{L}_{b-1}\}$ and a *right copy*
$\{\mathrm{R}_0, \dots, \mathrm{R}_{b-1}\}$. For each position $i$ we add
the edge
$$\mathrm{L}_{u_i} \;-\; \mathrm{R}_{v_i}.$$
Because every edge crosses from a left vertex to a right vertex, this graph
is automatically **bipartite**: you can two-colour its vertices (left =
colour A, right = colour B) so that no edge joins two vertices of the same
colour. Bipartiteness is not a side remark — it is the structural fact that
controls everything.

A pair $(u, v)$ is *good*, or **cycle-containing**, precisely when
$G(u,v)$ fails to be a forest; that is, when it contains at least one
cycle. A family $C$ of words is a **cyclic family** when every pair of
distinct members of $C$ is good.

## Why four is the magic number

The first surprise is that very short words can never be good, no matter how
cleverly you choose them. This is the **girth obstruction**, and it is a
clean theorem:

> **Theorem (Girth bound).** If the pair $(u, v)$ is cycle-containing,
> then the word length satisfies $k \ge 4$.

Why? Bipartite graphs cannot contain short, odd, or even three-edge cycles.
In a bipartite graph every cycle alternates between the left and right
sides, so it must have *even* length: the shortest conceivable cycle has
length four, traversing left–right–left–right and home again. A length-four
cycle uses four distinct edges. But in our construction each edge is
contributed by a single position $i$ of the words. Four distinct edges
therefore demand four distinct positions — and that forces $k \ge 4$.

The consequence is immediate and total:

> **Corollary (Collapse for short words).** If $k \le 3$, then every cyclic
> family contains at most one word.

For words of length one, two, or three, the game is over before it begins:
no two distinct words can ever form a good pair, so the largest "all-pairs-
good" family is a single lonely card. The interesting mathematics lives at
length four and beyond.

This is the kind of statement that feels obvious once explained and is
genuinely subtle to pin down rigorously, because it rests on the global
fact that bipartite graphs have girth at least four combined with the
bookkeeping that maps edges back to coordinates.

## The binary world: a tale of four patterns

The cleanest and most beautiful case is the binary alphabet, $b = 2$. Here
the bipartite graph lives on just four vertices: two on the left
($\mathrm{L}_0, \mathrm{L}_1$) and two on the right
($\mathrm{R}_0, \mathrm{R}_1$). A graph on four vertices in a $2 \times 2$
bipartite layout can contain only one possible cycle: the full square
$$\mathrm{L}_0 - \mathrm{R}_0 - \mathrm{L}_1 - \mathrm{R}_1 - \mathrm{L}_0,$$
the famous complete bipartite graph $K_{2,2}$. This square is present if and
only if all four of its edges are present.

Now translate "all four edges present" back into the language of words. The
edge $\mathrm{L}_s - \mathrm{R}_t$ exists exactly when some position $i$ has
$u_i = s$ and $v_i = t$. So the square is complete precisely when all four
pattern-pairs
$$(0,0), \quad (0,1), \quad (1,0), \quad (1,1)$$
each appear in some coordinate as we read $u$ and $v$ together. This is a
classical and lovely condition: the two binary words are said to be
**qualitatively independent**, or to **shatter** one another. We capture it
with a definition:

> **Definition (Shattering).** Two binary words $u, v$ of length $k$
> *shatter* if for every pair of symbols $(s, t) \in \{0,1\} \times \{0,1\}$
> there is a position $i$ with $u_i = s$ and $v_i = t$.

The binary picture now collapses into a single crisp slogan: **for the
binary alphabet, a pair of words is good if and only if they shatter.** One
half of this equivalence — that shattering forces a genuine cycle — is a
theorem we can state and rely on:

> **Theorem (Shattering builds a cycle).** If two binary words $u, v$
> shatter, then the pair $(u,v)$ is cycle-containing: the graph $G(u,v)$
> literally contains the four-cycle
> $\mathrm{L}_0 - \mathrm{R}_0 - \mathrm{L}_1 - \mathrm{R}_1 - \mathrm{L}_0$.

The proof is constructive and concrete. Shattering hands us four positions,
one realising each of the four patterns. Each position gives one edge of the
square. Threading them together in the order
$\mathrm{L}_0 \to \mathrm{R}_0 \to \mathrm{L}_1 \to \mathrm{R}_1 \to
\mathrm{L}_0$ produces an honest closed loop that visits four distinct
vertices and uses four distinct edges — a genuine cycle in the precise
graph-theoretic sense.

Shattering also explains the threshold from a fresh angle. To shatter, the
coordinate map $i \mapsto (u_i, v_i)$ must hit all four pattern-pairs. A
function whose image is a four-element set must have at least four inputs, so
again $k \ge 4$. The girth bound and the counting bound are two faces of the
same coin.

## Climbing the ladder: monotonicity

A reassuring feature of the problem is that lengthening your words never
hurts. If $u$ and $v$ already shatter at length $k$, then padding both with
one more symbol — appending any value $a$ to $u$ and any value $b$ to $v$ —
preserves shattering:

> **Theorem (Extension preserves shattering).** If binary words $u, v$ of
> length $k$ shatter, then for any appended symbols the longer words
> $u\,a$ and $v\,b$ of length $k+1$ also shatter.

The reason is that the four required patterns were already realised at
positions inside the original words; adding a coordinate can only add to the
stockpile of realised patterns, never remove one. The practical upshot is
that the **extremal function** — the maximum size of a cyclic family at
length $k$ — is *monotone non-decreasing* in $k$. Once you can build a large
good family, you keep it for all longer lengths.

## The first real family

When does anything interesting actually happen? At exactly length four, the
threshold, we find the first nontrivial cyclic family, and it is built from
three specific binary words:
$$w_1 = 0011, \qquad w_2 = 0101, \qquad w_3 = 0110.$$
These three are not random. Read any two of them down their four columns and
you will find all four patterns $(0,0), (0,1), (1,0), (1,1)$ appear. They are
pairwise shattering, and therefore pairwise good:

> **Theorem (A good triple at length four).** The family
> $\{0011,\, 0101,\, 0110\}$ of three binary words of length four is a
> cyclic family: every pair among them shatters, hence every pair's
> bipartite graph contains a cycle. Consequently the maximum cyclic family
> at $k = 4$ has size **at least three**.

Notice the elegance of the choice. Each word has exactly two zeros and two
ones, and the three words correspond to the three distinct ways to split
four positions into two pairs — the three perfect matchings on four points.
That hidden symmetry is exactly what guarantees that every pair realises all
four patterns. Exhaustive computation confirms that three is also the
*maximum* at length four: you cannot find a fourth binary word that shatters
with all three at once. So the value $M_2(4) = 3$ is sharp, with the lower
bound now rigorously established and the matching upper bound a finite, fully
checkable claim.

## The sequence that emerges

Pushing the brute-force search further reveals a striking sequence of binary
maxima. Writing $M_2(k)$ for the largest cyclic family of binary words of
length $k$, the computed values are
$$M_2(2) = 1, \quad M_2(3) = 1, \quad M_2(4) = 3, \quad M_2(5) = 4,
\quad M_2(6) = 10, \quad M_2(7) = 15.$$
The pattern is not a simple polynomial or a textbook recurrence. It jumps,
it pauses, and then it leaps — from $4$ to $10$ as we pass from length five
to length six. Sequences like this are the lifeblood of combinatorics: they
hint at hidden structure waiting to be named.

## Blocks, residues, and the general conjecture

For larger alphabets the geometry of the bipartite graph becomes richer —
more left vertices, more right vertices, more shapes of cycle — but a
unifying construction is conjectured to govern the extremal families. The
idea is to stop thinking position-by-position and start thinking
**block-by-block**.

Partition the $k$ coordinates into $b$ consecutive blocks of prescribed
sizes. Consider the words that are *constant on each block*, choosing the
block values so that any two such words induce a cycle that spans all $b$
symbol-classes. The number of these "good" block-vectors is a combinatorial
count we denote $N_b(k)$. The grand conjecture, which this body of work
frames and partially settles, reads:

> **Conjecture (Block construction is extremal).** For every alphabet size
> $b \ge 2$, the largest cyclic family in $\{0,\dots,b-1\}^k$ has size at
> most $N_b(k)$, and this bound is attained for all sufficiently large $k$ —
> in particular whenever $k \equiv -1 \pmod{b}$.

The magic of the block viewpoint is that it converts a *global* requirement
("the whole bipartite graph must contain a cycle") into a *local* one ("the
block-value assignments of two words must differ in a way that closes a loop
among the $b$ symbol-classes"). The combinatorics of closing loops among $b$
labels is governed by permutations and derangements on $b$ symbols, a finite
and tractable object, rather than by the unmanageable full space of $b^k$
words. For the binary alphabet the residue condition $k \equiv -1 \pmod 2$
simply says $k$ is odd, and indeed the odd lengths $k = 5, 7$ sit at clean
values $4, 15$ in the computed sequence.

## Why this matters beyond the puzzle

Cycle-containing families are not merely a recreational curiosity. The
underlying notion — when do the coordinate patterns of two strings cover all
possibilities? — is the engine behind **covering codes** and **qualitatively
independent partitions**, structures used in the design of statistical
experiments, in software and hardware testing (where you want a small suite
of test vectors that jointly exercises every combination of feature
settings), and in extremal set theory. The bipartite cycle reformulation
adds a geometric lens: it recasts a counting condition about strings as a
question about loops in a graph, where the powerful machinery of girth,
bipartiteness, and graph colouring can be brought to bear.

The story so far has a satisfying shape. A single structural fact — that
bipartite graphs have no cycles shorter than four — propagates into a sharp
length threshold, a complete collapse for short words, an exact and elegant
extremal example at the threshold, and a clear conjectural roadmap built
from blocks and residues. The four-vertex square $K_{2,2}$, the simplest
loop imaginable, turns out to be the keystone holding up an entire tower of
combinatorics. The remaining peaks — proving the exact maxima for every
length and confirming the block construction in full generality — are now
sharply visible, and the path up the mountain has been charted.
