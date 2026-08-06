# The Dimension of a Search

*How a two-hundred-year-old idea about matrices, a hundred-year-old lemma about sequences, and the golden ratio conspire to measure the size of the space of proofs.*

---

## A forest with a secret

Imagine you are looking for a proof.

Not a particular proof — any proof. You have a goal, and you have a handful of moves that might get you closer to it. Each move produces new goals, each of which offers its own handful of moves. What you are standing in front of is a tree: the root is your original problem, and every branch is a decision. Somewhere out in that thicket, if you are lucky, there is a leaf that says **QED**.

The tree is enormous. If every node offers $b$ moves, then at depth $n$ there are $b^n$ nodes. For $b = 2$ and $n = 60$, that is more nodes than there are seconds since the Big Bang. Brute force is not an option; nobody expected it to be.

But here is the thing that makes proof search *possible* rather than merely hopeless: **most of those branches are dead**. A move that introduces an unsatisfiable side condition, a rewrite that loops, a case split into a contradiction — these die immediately, and everything below them dies with them. The living part of the tree, the part consisting of prefixes that are still *on the way* to a proof, is a sparse, ragged sub-thicket inside the full $b$-ary tree.

How sparse? That is the question this article is about. And the answer, remarkably, is a *number* — a number between $0$ and $1$ that behaves exactly like a **fractal dimension**.

---

## Counting what survives

Let us be concrete. Write $N(n)$ for the number of *successful prefixes of length $n$*: the number of partial search paths of depth $n$ that have not yet been pruned, that are still candidates for extending to a complete proof.

Two facts about $N$ are almost forced on us by the situation.

**First,** $N(n) \ge 1$. There is always at least one live path — if there were none, the problem would have no proof at all, and we would not be searching.

**Second, and this is the crucial one,** $N$ is *submultiplicative*:
$$N(m+n) \;\le\; N(m)\,N(n).$$

Why? A live path of length $m+n$ is, in particular, a live path of length $m$ followed by a continuation of length $n$. There are at most $N(m)$ choices for the first part. And the continuation, whatever it is, is a live path of length $n$ *in some search problem* — so there are at most $N(n)$ ways to complete each start, at least in the well-behaved situation where the search language is invariant under shifting your attention to a subgoal. Multiply, and you get the inequality. It can be a strict inequality — most pairings of a start and a continuation will not fit together — which is exactly why it is $\le$ and not $=$.

We call a function $N : \mathbb{N} \to \mathbb{R}$ with these two properties a **search profile**. It is a stunningly weak hypothesis. It says almost nothing about the search problem: no self-similarity, no regularity, no algebraic structure. And yet it is enough.

---

## The rate that always exists

For each $n \ge 1$, form the *finite-scale rate*
$$\text{rate}(n) \;=\; \frac{\log N(n)}{n}.$$

This is the average number of nats of branching per level, measured out to depth $n$. It is a natural quantity to compute — you run your search to depth $n$, count the survivors, take a logarithm, divide. But is it *stable*? Does looking deeper give you a different answer?

Here is the first main result.

> **The Search Entropy Theorem.** For every search profile $N$, the finite-scale rates converge:
> $$\lim_{n \to \infty} \frac{\log N(n)}{n} \;=\; h,$$
> and the limit $h$ is exactly the *infimum* of the finite-scale rates over all $n \ge 1$. Moreover $h \ge 0$.

Two things are being asserted, and both are worth pausing on.

The **existence** of the limit is not obvious. A submultiplicative sequence can wobble; the counts $N(n)$ need not be monotone, need not be smooth, need not follow any recursion. The reason the limit exists anyway is a beautiful piece of early-twentieth-century analysis known as *Fekete's subadditive lemma*: if a sequence $a_n$ satisfies $a_{m+n} \le a_m + a_n$, then $a_n/n$ converges to $\inf_n a_n/n$. Take logarithms of the submultiplicativity relation — $\log N(m+n) \le \log N(m) + \log N(n)$ — and the search profile becomes exactly such a sequence. The nonnegativity $N(n) \ge 1$ guarantees the infimum is not $-\infty$, and the whole machine turns over.

The **identification with the infimum** is the practically useful half. It says that *every finite computation is a rigorous upper bound*. If you run your search to depth $17$ and find $N(17) = 4096$ live prefixes, you have proved, with no further work, that the true asymptotic entropy satisfies
$$h \;\le\; \frac{\log 4096}{17} \;\approx\; 0.4895.$$
Not estimated. Proved. And the bounds you get by going deeper only improve. This is the rare situation in which a heuristic measurement is also a theorem.

---

## From a rate to a dimension

The entropy $h$ has units — nats per level — and its value depends on which logarithm you use. To get a dimensionless number we normalize against the ambient tree. If the full search tree is $b$-ary, so that $N(n) \le b^n$ for all $n$, define the

> **proof-search dimension**
> $$\dim = \frac{h}{\log b}.$$

And now the second result:

> **The Dimension Bounds.** For a search profile inside a $b$-ary tree with $b > 1$, the proof-search dimension satisfies
> $$0 \;\le\; \dim \;\le\; 1.$$

The upper bound comes from the infimum characterization applied at $n = 1$: since $N(1) \le b$, we get $h \le \text{rate}(1) = \log N(1) \le \log b$. One line, and it is sharp.

This normalization is not an analogy — it is *the same formula* that defines the similarity dimension of a self-similar fractal. The middle-thirds Cantor set keeps $2$ of every $3$ subintervals at each scale and has dimension $\log 2/\log 3 \approx 0.6309$. A search that keeps $2$ of every $3$ branches at each level has proof-search dimension $\log 2/\log 3 \approx 0.6309$. The space of infinite live paths *is* a Cantor-like set sitting inside the boundary of the $b$-ary tree, and the entropy rate is measuring its coarse fractal size.

A dimension of $0$ means the live set is asymptotically negligible — the search is essentially a thin path. A dimension of $1$ means pruning has failed and you are still fighting the full exponential. Every real search system lives somewhere in between, and the number tells you *where*.

---

## Where the numbers come from: matrices

So far this is a framework. To make it produce specific numbers, we need a source of concrete search profiles. The richest one is **finite-state pruning**.

Suppose your pruning rule has bounded memory: whether a move is allowed depends only on which of finitely many *states* the search is currently in, and taking a move sends you to a new state. This is exactly a finite automaton, and it is described by a $k \times k$ matrix $A$ whose entry $A_{ij}$ counts the allowed moves that carry state $i$ to state $j$. Such matrices are **nonnegative** — you cannot have a negative number of moves.

The fundamental fact about such a matrix is that its powers count paths: $(A^n)_{ij}$ is the number of length-$n$ accepted paths from state $i$ to state $j$. So the total number of accepted paths of length $n$ is
$$P(n) \;=\; \sum_{i,j} (A^n)_{ij},$$
the sum of all entries of $A^n$.

> **Path counts are submultiplicative.** For any nonnegative square matrix $A$ and any $m, n \ge 0$,
> $$P(m+n) \;\le\; P(m)\,P(n).$$

The proof is a two-line rearrangement that is nonetheless the heart of the matter. Writing $A^{m+n} = A^m A^n$ and summing all entries gives
$$P(m+n) \;=\; \sum_{\ell} \Big(\sum_i (A^m)_{i\ell}\Big)\Big(\sum_j (A^n)_{\ell j}\Big) \;=\; \sum_\ell f(\ell) g(\ell),$$
where $f(\ell)$ is the number of length-$m$ paths *ending* at $\ell$ and $g(\ell)$ the number of length-$n$ paths *starting* at $\ell$. Meanwhile $P(m) = \sum_\ell f(\ell)$ and $P(n) = \sum_\ell g(\ell)$, so $P(m)P(n) = \sum_\ell f(\ell) \big(\sum_{\ell'} g(\ell')\big)$. Since every term is nonnegative, $g(\ell) \le \sum_{\ell'} g(\ell')$, and the inequality follows term by term. In words: *concatenating a length-$m$ path with a length-$n$ path only works when the endpoint of the first matches the start of the second, and the product $P(m)P(n)$ pays for all pairings, matched or not.*

So every finite-state pruned search is a search profile, and the Search Entropy Theorem applies. But now we can do much better than "the limit exists" — we can *compute* it.

---

## The Perron root

Here is where the third strand enters: the spectral theory of nonnegative matrices, going back to Perron and Frobenius at the turn of the twentieth century.

Suppose $A$ has a **strictly positive eigenvector**: a vector $v = (v_1, \dots, v_k)$ with all coordinates bounded between two positive constants, $0 < c \le v_i \le C$, satisfying
$$Av = r\,v$$
for some $r > 0$. For a strongly connected automaton — one where every state can reach every other — Perron–Frobenius theory guarantees such a $v$ exists, with $r$ the largest eigenvalue, the *Perron root*.

Then the eigenvector *sandwiches the path counts*:

> **The Perron Sandwich.** With $A$, $v$, $c$, $C$, $r$ as above, for every $n$,
> $$c \cdot P(n) \;\le\; r^n \sum_i v_i \;\le\; C \cdot P(n).$$

The argument is a comparison. Because $v$ is an eigenvector of $A$, it is an eigenvector of every power: $A^n v = r^n v$, i.e. for each row $i$,
$$\sum_j (A^n)_{ij}\, v_j \;=\; r^n v_i.$$
Now replace $v_j$ on the left by its lower bound $c$: since the entries $(A^n)_{ij}$ are nonnegative, this only decreases the sum, giving $c\sum_j (A^n)_{ij} \le r^n v_i$. Sum over $i$ to get the left inequality. Replace $v_j$ by its upper bound $C$ instead, and the same argument run backwards gives the right one. That is the entire proof — no spectral decomposition, no Jordan form, no complex analysis. Just the observation that a positive eigenvector pins the row sums of $A^n$ within a bounded factor of $r^n$.

The sandwich says $P(n)$ is trapped between two constant multiples of $r^n$: it is *exactly exponential* with base $r$, up to bounded fluctuation. Take logarithms and divide by $n$, and the constants wash out:

> **The Bridge Theorem.** For a nonnegative matrix admitting a strictly positive eigenvector for an eigenvalue $r > 0$, the path counts have entropy
> $$\lim_{n \to \infty} \frac{\log P(n)}{n} \;=\; \log r,$$
> and consequently, relative to an ambient $b$-ary search tree with $b > 1$,
> $$\dim \;=\; \frac{\log r}{\log b}.$$

Three worlds meet in this one line. **Combinatorics** supplies the object being measured — accepted paths in a pruned tree. **Analysis** supplies the guarantee that the measurement converges — Fekete's lemma. **Linear algebra** supplies the answer — the Perron root.

---

## The unexpected payback

Bridges carry traffic in both directions, and this one has a surprise going the other way.

The infimum half of the Search Entropy Theorem says $h \le \text{rate}(n)$ for *every* $n$, not just in the limit. Combine that with $h = \log r$:
$$\log r \;\le\; \frac{\log P(n)}{n} \quad\text{for all } n \ge 1,$$
which exponentiates to a clean, purely algebraic statement:

> **The Perron Domination Inequality.** For a nonnegative $k \times k$ matrix with a strictly positive eigenvector for the eigenvalue $r > 0$ (and with all path counts at least $1$),
> $$r^n \;\le\; \sum_{i,j} (A^n)_{ij} \quad\text{for every } n \ge 0.$$

There is no asymptotics here, no limit, no epsilon. It is a finite inequality about matrix powers — and it was obtained by a detour through an entropy that only exists in the limit. The infimum characterization in Fekete's lemma converted an asymptotic statement into a uniform one.

---

## The golden ratio, hiding in a search tree

Abstract frameworks are cheap. Let us cash this one out.

Take a binary search tree — at each step, two moves. Now impose a pruning rule with one bit of memory: **never use two "expensive" inference steps in a row.** (Think: never apply two consecutive case splits, or never invoke the same heavy decision procedure twice running.) An automaton with two states — "the last step was expensive" and "the last step was cheap" — implements this exactly, with transition matrix
$$A = \begin{pmatrix} 1 & 1 \\ 1 & 0 \end{pmatrix}.$$
From the cheap state you may take either move; from the expensive state, only the cheap one.

What are the path counts? A direct computation on the matrix identity $A^2 = A + I$ shows they satisfy the recursion $P(n+2) = P(n+1) + P(n)$, with $P(0) = 2$ and $P(1) = 3$ — and therefore:

> **The path counts are Fibonacci numbers:** $P(n) = F_{n+3}$, where $F_1 = F_2 = 1$ and $F_{m+2} = F_{m+1} + F_m$.

So the number of surviving search prefixes at depth $n$ is $2, 3, 5, 8, 13, 21, 34, 55, \dots$

The Perron root of $A$ is the larger root of $\lambda^2 = \lambda + 1$: the **golden ratio**
$$\varphi = \frac{1+\sqrt 5}{2} \approx 1.6180,$$
with strictly positive eigenvector $(\varphi, 1)$. Feeding this into the Bridge Theorem:

> **Golden-ratio proof-search dimension.** The Fibonacci-pruned binary search space has proof-search dimension
> $$\frac{\log \varphi}{\log 2} \;\approx\; 0.6942.$$

A single bit of memory in the pruning rule has knocked the dimension of the search space from $1$ down to $0.694$. In concrete terms: at depth $100$, the unpruned tree has $2^{100} \approx 1.27 \times 10^{30}$ nodes, while the pruned one has $F_{103} \approx 1.5 \times 10^{21}$ — nine orders of magnitude fewer. Still astronomically many, but the *exponent* has been permanently reduced, and that reduction compounds with depth. This is precisely the sense in which a pruning heuristic "helps": it does not make an exponential problem polynomial, it lowers the base of the exponential, and the dimension is the exact measure of by how much.

And the Perron Domination Inequality, specialized to this matrix, spits out a classical fact for free:
$$\varphi^n \;\le\; F_{n+3} \quad \text{for every } n \ge 0.$$
The golden ratio's powers are dominated by the Fibonacci numbers three places later. A fact about a famous integer sequence, derived from a theorem about proof search, by way of a lemma about subadditive sequences. Bridges are like that.

---

## What the number does and does not know

Two cautions, both instructive.

**Dimension measures abundance, not difficulty.** The entropy counts how many live prefixes there are; it says nothing about *the order in which you visit them*. Two search problems can have identical prefix counts at every depth — hence identical dimension — while a depth-first traversal finds the proof immediately in one and only after an astronomical detour in the other. Dimension is a property of the geometry of the search space; the cost of an actual search is that geometry *composed with a policy*. Separating the two is exactly what makes the framework useful: it isolates the part of the difficulty that no clever traversal order can remove.

**Sparse damage does not matter.** If you change the branching structure at a set of depths of density zero — one level in a million behaves anomalously — the logarithmic volumes shift by a sublinear amount and the entropy is unchanged. The dimension is a robust, asymptotic quantity. It is insensitive to any finite amount of local weirdness, which is exactly what you want from a measure of intrinsic size.

---

## The road ahead

Several directions open up naturally from here.

The Bridge Theorem currently assumes a strictly positive eigenvector. Perron–Frobenius theory says strong connectivity of the automaton suffices to produce one; removing the hypothesis altogether would let one write "the dimension is $\log \rho(A)/\log b$" for the spectral radius $\rho$. Gelfand's formula — the spectral radius is the limit of $\|A^n\|^{1/n}$ for any matrix norm — is the natural route, since the sum-of-entries functional $P(n)$ is precisely such a norm, whose submultiplicativity we already have.

The set of infinite live paths, with the ultrametric $b^{-|\text{common prefix}|}$, is a genuine compact metric space, and one expects the entropy computed here to be its exact *Hausdorff* dimension. The Perron eigenvector defines a natural measure on that boundary, and a mass-distribution argument should convert the counting estimate into the geometric one.

Then there is the question of *which numbers occur*. The achievable dimensions are exactly the normalized Perron roots $\log r/\log b$ of nonnegative integer matrices — a well-studied and strikingly restrictive class of algebraic numbers — so an answer would classify the possible "sizes" of finite-state-prunable search spaces.

Finally, one can let the branching *fluctuate randomly*. If the ambient and surviving branching numbers at level $n$ form a stationary ergodic sequence $(B_n, S_n)$ with $1 \le S_n \le B_n$, then logarithmic path volumes become additive cocycles and the Birkhoff ergodic theorem should deliver an almost-sure dimension $\mathbb{E}[\log S_0]/\mathbb{E}[\log B_0]$ — the random-block limit of the exact finite-block identity proved here.

---

## Coda

The picture that emerges is this. A search space is not just big or small; it has a *size in the fractal sense*, a real number between $0$ and $1$ that survives all the local irregularity of a real search problem. That number exists for reasons of pure analysis — submultiplicativity plus Fekete — with essentially no hypotheses. It is bounded by any finite measurement you care to make. And when the pruning is implementable in bounded memory, it is not just an abstraction but a computable eigenvalue: take the transition matrix, find its Perron root, take a ratio of logarithms.

That a heuristic search rule should have a dimension, that the dimension should be a spectral invariant, and that computing it for one of the simplest possible pruning rules should hand you back the golden ratio — this is the kind of coincidence that is not a coincidence. Exponential growth is exponential growth, whether it is happening in a fractal, in a matrix, or in the branching tree of everything you might try next.
