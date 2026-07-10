# The Fractal Dimension of Proof Search

*How hard is it to find a proof? Surprisingly, the answer has the geometry of a snowflake.*

## A search that branches like a tree

Imagine you are trying to prove a theorem, not by a flash of insight, but the way a
tireless machine would: step by step, trying every rule of inference that might
apply, backtracking when a path leads nowhere, pressing on when it looks promising.
Every time you write down a line of a proof, you face a choice. Maybe five different
lemmas could be invoked next; maybe fifty. Each choice opens a new set of choices.
The set of all possible partial proofs fans out into an enormous branching tree.

At the root sits your theorem. At each node sit the possible next steps. A complete
proof is a path from the root down through the tree, never getting stuck. The
question that haunts everyone who has ever run an automated prover — or stared at a
blackboard past midnight — is simply: *how hard is it to find one of those paths?*

The usual answers are crude. "It's exponential." "It's undecidable in general."
"Some theorems are just hard." These are true but unsatisfying. They don't tell you
*how* hard a specific theorem is, and they don't give you a number you can measure.
This article is about a sharper answer, one borrowed from an unexpected place: the
mathematics of fractals.

## The shape of the successful paths

Let's make the tree concrete. Suppose that at every node there are exactly $b$
possible next steps — we call $b$ the **branching factor**. If you never pruned
anything, the number of candidate partial proofs of length $n$ would be $b^n$: the
complete $b$-ary tree, growing explosively with depth.

But not every step leads to a real proof. Most branches are dead ends — they look
plausible for a while and then get stuck. Suppose the problem is *self-similar*:
at every node, exactly $s$ of the $b$ available steps can actually be extended all
the way to a finished proof, where $1 \le s \le b$. Then the number of genuinely
**successful** paths of length $n$ is not $b^n$ but

$$s^n.$$

Now here is the leap. Consider the *infinite* successful paths — the idealized
limit of proofs that never terminate but never get stuck either. These form a set
sitting inside the boundary of the tree. If we measure distance between two paths by
how long they agree before diverging, using the natural metric

$$d(x, y) = b^{-(\text{length of common prefix})},$$

then this set of successful paths is a genuine fractal — a self-similar Cantor set,
the same species of object as the Cantor middle-thirds set or the Sierpiński gasket.
And like every self-similar fractal, it has a **dimension**.

## The dimension is a ratio of logarithms

For a self-similar set built by keeping $s$ out of every $b$ pieces at each scale,
the similarity dimension is the ratio of logarithms

$$D(b, s) = \frac{\log s}{\log b}.$$

This single number — call it the **proof-search fractal dimension** — turns out to
capture everything about how focused or how sprawling the search is. It is not a
metaphor. It is the literal exponent that converts one count into another, as the
next result makes precise.

**The Bridge Identity.** *For a self-similar search space with branching factor
$b > 1$ and at least one proof ($s \ge 1$), the number of successful paths of depth
$n$ is exactly the total number of candidate paths raised to the fractal dimension:*

$$s^n \;=\; \bigl(b^n\bigr)^{D(b,s)}.$$

The proof is a one-line calculation once you notice that
$(b^n)^{\log s / \log b} = e^{n \log b \cdot (\log s / \log b)} = e^{n \log s} = s^n$,
but its meaning is anything but trivial. Combinatorial growth — the raw counting of
branches — is *exactly* a power law, and the power is the fractal dimension. The
sprawling tree and the smooth analytic exponent are two faces of one coin.

## Where does difficulty live? In the codimension

It is tempting to say "big dimension means hard theorem." The truth is more elegant.
The dimension $D$ always lives in the interval $[0, 1]$, and both endpoints have
crisp meanings.

**The dimension lives on the edge.** *For $b > 1$ and $1 \le s \le b$ we always have
$0 \le D(b,s) \le 1$. Moreover $D = 1$ if and only if $s = b$, and $D < 1$ the moment
even a single branch can be pruned ($s < b$). The dimension is also strictly
increasing in $s$: more ways to succeed genuinely raises the dimension.*

So the "hardest" case, $D = 1$, is precisely the one where *nothing* can be pruned —
every branch succeeds, so no search strategy can beat blind exhaustion. This is a
razor-sharp threshold, not a generic value: you reach $D = 1$ only when $s = b$
exactly. At the other extreme, $D = 0$ means $s = 1$: there is a unique proof path,
the successful set is a single point, and search is trivial.

The quantity that really governs difficulty is therefore not the dimension but its
complement, the **codimension** $\kappa = 1 - D$. It measures how fast the good
paths thin out among all the paths. This is made exact by a companion law.

**The Density Law.** *Under the same hypotheses, the fraction of candidate paths
that succeed decays as*

$$\left(\frac{s}{b}\right)^n = \bigl(b^n\bigr)^{D - 1} = \bigl(b^n\bigr)^{-\kappa}.$$

The codimension $\kappa = 1 - D$ is exactly the exponential rate at which successful
paths become rare. When $\kappa$ is tiny (dimension near $1$), the good paths barely
thin out — search is close to exhaustive and painfully expensive. When $\kappa$ is
large (dimension near $0$), the good paths vanish so fast that a smart searcher
homes in almost immediately. Difficulty is the *slowness of thinning*, and the
Density Law puts a number on it.

This also corrects a natural but mistaken intuition. One might guess that "hard"
theorems have dimension *greater* than $1$. For a self-similar subset of a tree that
is impossible: a piece can never be more dimensional than the whole, which sits at
dimension $1$. Hardness is not excess dimension; it is *deficient codimension*.

## The same number, seen as entropy

There is a second, equally illuminating way to read $D$. Take logarithms of the
successful-path count and define $L(n) = \log(s^n) = n \log s$. This is the "action"
of the search, and its per-step average $L(n)/n$ is a growth rate — an **entropy**.
For the uniform self-similar model it is exactly $\log s$ at every depth, and in
general it is the limit

$$\text{entropy} = \lim_{n \to \infty} \frac{L(n)}{n} = \log s.$$

The ambient tree has its own entropy, $\log b$, the growth rate of *all* paths. And
the fractal dimension is nothing but the ratio of the two:

$$D(b, s) = \frac{\text{entropy of successful paths}}{\text{entropy of all paths}}
= \frac{\log s}{\log b}.$$

In other words, the proof-search fractal dimension is a **relative entropy** — the
information-theoretic growth rate of good paths measured against the growth rate of
the whole search. This is the classical dictionary of dynamical systems, where such
ratios are called relative topological entropies, and it means our fractal exponent
is simultaneously a geometric dimension, a combinatorial growth rate, and an entropy.

The bridge to entropy also connects the story to a century-old piece of analysis:
Fekete's lemma on subadditive sequences. A sequence $L$ with
$L(n + m) \le L(n) + L(m)$ always has a well-defined average limit $L(n)/n$. Our
$L(n) = n \log s$ is additive — the extreme, tight case of subadditivity — which is
exactly why the entropy has a clean closed form. For example, doubling the search
depth at most doubles the log-count:

$$L(2n) \le 2\,L(n),$$

with equality here. The real power of Fekete's theory appears when the branching is
*non-uniform* — when the success factor $s_i$ varies with depth. Then the good-path
count is a product $\prod_i s_i$, no closed form survives, but Fekete's limit still
exists and still defines the entropy, and the identity $D = \text{entropy}/\log b$
still holds in the limit. The dimension survives the loss of a formula because it was
a ratio of growth rates all along.

## Counting the cost

None of this would matter if it didn't connect to real work. Consider the crudest
strategy: exhaustive search that expands every node down to depth $n$. How many nodes
does it visit? Summing the geometric series of the full tree gives the exact count

$$\sum_{i=0}^{n} b^i = \frac{b^{\,n+1} - 1}{b - 1},$$

a clean closed form. Against this baseline, the Density Law tells you how much an
*ideal* pruning searcher could save: it needs to explore only about $b^{nD}$ paths
rather than $b^n$, an exponential saving governed entirely by the codimension. The
gap between $b^n$ and $b^{nD}$ — between brute force and inspired search — is
measured, node for node, by $\kappa = 1 - D$.

## Why this is beautiful

Start with a slogan — "some theorems are harder to prove than others" — and you end
with a single number that is at once a fractal dimension, a relative entropy, and a
Fekete growth rate, tied together by the exact identity $s^n = (b^n)^D$. The
sprawling, combinatorial mess of a proof-search tree turns out to have the clean
self-similar geometry of a Cantor set, and the difficulty of the theorem is written
in the geometry of that set.

The dimension lives on a knife's edge in $[0, 1]$. Push it to $0$ and the proof is
essentially unique; push it to $1$ and no cleverness can save you from checking
everything. Most interesting theorems live in between, on the balanced edge where
search is neither trivial nor hopeless — where a good idea about which branch to try
next is worth exactly $1 - D$ in the exponent. Difficulty, it turns out, is fractal,
and its dimension is something you can compute.
