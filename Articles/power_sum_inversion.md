# The Fingerprint of a Histogram: How a Handful of Sums Reveals Everything

## A guessing game with sums

Imagine I have a bag of numbered tokens. Each token carries a whole number between $0$ and $N$, and there may be many tokens with the same number. I refuse to show you the bag. Instead, I offer to answer a very restricted kind of question. You may ask me:

- How many tokens are there in total?
- What is the sum of the numbers?
- What is the sum of their squares?
- Their cubes? Their fourth powers?

Nothing else. No maximum, no median, no "how many threes are there".

The quantities I am willing to reveal are the **power sums**
$$p_k \;=\; \sum_{\text{tokens } i} (\text{value of } i)^k, \qquad k = 0, 1, 2, \dots$$
Note that $p_0$ is just the number of tokens (each token contributes $x^0 = 1$), $p_1$ is the ordinary sum, $p_2$ the sum of squares, and so on.

Here is the question. How many of these numbers do you need before you can reconstruct the entire contents of the bag — not just its total, but the exact count of tokens bearing each individual value?

The answer is startlingly clean: **$N+1$ of them, namely $p_0, p_1, \dots, p_N$, and never fewer.** And the reconstruction is not an abstract existence statement. There is a fixed table of rational numbers, depending only on $N$, that turns the list of power sums into the list of counts by a single matrix multiplication.

This article is about that table, why it exists, exactly how much noise it tolerates, and why the threshold $N+1$ is governed not by the *size* of the admissible values but by their *number*.

## From a bag of tokens to a bounded function

Let us set the scene precisely, because the precision is where the pleasure is.

Let $\alpha$ be a finite index set — the tokens — and let $f : \alpha \to \mathbb{N}$ assign to each token its value, with the standing assumption $f(i) \le N$ for every $i$. Two objects are attached to $f$:

- its **power sums** $p_k(f) = \sum_{i \in \alpha} f(i)^k$ for $k = 0, 1, 2, \dots$;
- its **value distribution**, or histogram, $c_f(v) = \#\{ i \in \alpha : f(i) = v \}$.

The histogram clearly determines the power sums. Grouping the tokens by their common value,
$$p_k(f) \;=\; \sum_{v=0}^{N} c_f(v)\, v^k .$$
This little identity is the whole problem in one line. Read it as a matrix equation: the vector of power sums $(p_0, \dots, p_N)$ is the image of the histogram vector $(c_f(0), \dots, c_f(N))$ under the matrix whose $(k,v)$ entry is $v^k$. That is a **transposed Vandermonde matrix** with the nodes $0, 1, \dots, N$.

Vandermonde matrices with distinct nodes are invertible. So the map from histogram to power sums is injective, and — this is the point — the inverse can be written down.

## The inverse you can hold in your hand

For each node $v \in \{0, 1, \dots, N\}$, consider the **Lagrange basis polynomial**
$$L_v(X) \;=\; \prod_{\substack{j = 0 \\ j \ne v}}^{N} \frac{X - j}{v - j},$$
the unique polynomial of degree at most $N$ that equals $1$ at $X = v$ and $0$ at every other node. Expand it into monomials,
$$L_v(X) \;=\; \sum_{k=0}^{N} W_N(v,k)\, X^k,$$
and call the coefficient array $W_N$ the **inversion table**. It is a square array of rational numbers, one row per node, one column per power.

> **Inversion Theorem.** For every finite index set $\alpha$, every $f : \alpha \to \mathbb{N}$ with $f(i) \le N$, and every $v \le N$,
> $$c_f(v) \;=\; \sum_{k=0}^{N} W_N(v,k)\, p_k(f).$$

The proof is a two-line computation once the Lagrange polynomials are in place. Substituting the identity $p_k(f) = \sum_j c_f(j) j^k$ and exchanging the order of summation, the right-hand side becomes
$$\sum_{j=0}^{N} c_f(j) \sum_{k=0}^{N} W_N(v,k)\, j^k \;=\; \sum_{j=0}^{N} c_f(j)\, L_v(j) \;=\; c_f(v),$$
because $L_v(j)$ is $1$ when $j = v$ and $0$ otherwise. The interior sum $\sum_k W_N(v,k) j^k$ is literally "evaluate the polynomial $L_v$ at $j$", and the defining property of the Lagrange basis does the rest.

Small cases are easy to write out. For $N = 1$ the table has rows $(1, -1)$ and $(0, 1)$: the number of zeros is $p_0 - p_1$ and the number of ones is $p_1$. Obvious in hindsight, and correct. For $N = 2$ the rows are
$$\left(1, -\tfrac{3}{2}, \tfrac{1}{2}\right), \qquad (0, 2, -1), \qquad \left(0, -\tfrac{1}{2}, \tfrac{1}{2}\right).$$
Take the bag $\{0, 1, 1\}$: its power sums are $p_0 = 3$, $p_1 = 2$, $p_2 = 2$. The middle row gives $0\cdot 3 + 2 \cdot 2 + (-1)\cdot 2 = 2$, the number of ones. The first row gives $3 - 3 + 1 = 1$, the number of zeros. The third gives $-1 + 1 = 0$, the number of twos. The bag has been reconstructed.

## What follows immediately

Once you own the inverse, a cascade of statements becomes routine.

**Rigidity.** If $f$ and $g$ are two value functions on possibly *different* finite index sets, both bounded by $N$, and $p_k(f) = p_k(g)$ for every $k \le N$, then $c_f(v) = c_g(v)$ for every $v$ — including every $v > N$, where both counts are zero for trivial reasons. Nothing needs to be assumed relating the two index sets: even the statement that they have the same number of elements is a *conclusion*, being exactly the $k = 0$ component.

**Rigidity up to relabelling.** More is true. If the power sums agree up to $k = N$, there is a bijection $e$ between the two index sets with $g(e(i)) = f(i)$ for all $i$. Matching histograms means matching fibres, and matching fibres can be glued into a global bijection. So "equal power sums up to $N$" is not merely a numerical coincidence; it means the two labelled data sets are the same data set, differently named.

**A spectral reading.** If $A$ and $B$ are diagonal rational matrices whose diagonal entries are natural numbers at most $N$, and $\operatorname{tr}(A^k) = \operatorname{tr}(B^k)$ for $k \le N$, then $A$ and $B$ have the same eigenvalue multiplicities. Traces of powers *are* power sums of eigenvalues; a spectrum confined to $\{0,\dots,N\}$ is pinned down by the first $N+1$ of them.

## The table is unique, and the inverse works both ways

Two refinements make the inversion table feel less like a lucky choice and more like an inevitability.

First, **canonicity**. Suppose someone hands you any row vector $(a_0, \dots, a_N)$ of rational numbers with the property that $\sum_k a_k p_k = c(v)$ for *every* rational vector $c$ supported on the nodes, where $p_k = \sum_j c(j) j^k$. Then $a_k = W_N(v,k)$ for all $k$. There is exactly one linear recipe that reads the count at $v$ off the power sums; the Lagrange coefficients are it.

Second, **two-sidedness**. The inversion table is not just a left inverse of the transposed Vandermonde matrix but a genuine two-sided one. Concretely, for $k, k' \le N$,
$$\sum_{j=0}^{N} j^k\, W_N(j, k') \;=\; \begin{cases} 1 & k = k',\\ 0 & \text{otherwise.}\end{cases}$$
Read the other way round, this says the *columns* of the table are rational vectors on the nodes with any prescribed moment profile. So the moment map "histogram $\mapsto$ power sums" is not merely injective on $\mathbb{Q}^{N+1}$: it is a linear automorphism, onto as well as one-to-one. Every conceivable list of $N+1$ moments is realised by exactly one rational weighting of the nodes.

## How much noise can it take?

Real measurements are approximate. Suppose you are told the power sums of $f$ and $g$ only up to an error $\varepsilon$: $|p_k(f) - p_k(g)| \le \varepsilon$ for all $k \le N$. How far apart can the histograms be?

The answer is governed by the $\ell^1$-norm of a row of the inversion table, a quantity that classical approximation theory calls a **Lebesgue constant**:
$$\Lambda_N(v) \;=\; \sum_{k=0}^{N} |W_N(v,k)|.$$

> **Stability Theorem.** Under the above hypotheses, $|c_f(v) - c_g(v)| \le \Lambda_N(v)\, \varepsilon$ for every $v \le N$.

That is just the triangle inequality applied to the inversion formula. But now comes the trick that makes it *exact* rather than approximate: counts are **integers**. Two integers that differ by less than $1$ are equal. Hence:

> **Robust Exact Recovery.** If $\Lambda_N(v)\,\varepsilon < 1$, then $c_f(v) = c_g(v)$ exactly.

So the inversion is not merely injective; it has a positive radius of certainty, and that radius is $1/\Lambda_N(v)$. Moreover the Lebesgue constant is never zero — no row of the inversion table vanishes — so the criterion is never vacuous. For $N = 1$ the constants are $\Lambda_1(0) = 2$ and $\Lambda_1(1) = 1$; for $N = 2$ they are $3, 3, 1$. Both cases fit the pattern $\Lambda_N(0) = N+1$, which comes from the pleasant identity $\Lambda_N(0) = |L_0(-1)| = \prod_{j=1}^{N} (1 + 1/j) = N+1$, valid whenever the coefficients of $L_0$ alternate in sign.

The bad news, familiar to anyone who has tried to reconstruct a distribution from its moments in floating point, is that these constants grow: for the middle nodes they grow exponentially in $N$. Power-sum inversion is exact and canonical, but it is ill-conditioned, and the Lebesgue constant is the exact currency in which that ill-conditioning is priced.

## Why $N+1$ and not fewer

Could a cleverer method get away with $p_0, \dots, p_{N-1}$? No — and the obstruction is concrete.

> **Sharpness.** For every $N \ge 1$ there exist two bounded functions on finite index sets whose power sums agree for all $k < N$ but whose value distributions differ.

For $N = 2$ the smallest witness is the pair of bags $\{0, 2\}$ and $\{1, 1\}$: both have two tokens ($p_0 = 2$) and both sum to $2$ ($p_1 = 2$), yet their histograms are entirely different. Only at $k = 2$ do they part ways, $4 + 0 = 4$ versus $1 + 1 = 2$. At level $3$ the minimal pair is $\{0,2,2,2\}$ versus $\{1,1,1,3\}$: equal counts, equal sums, equal sums of squares, different histograms.

These are not accidents but instances of a general construction, and understanding it reveals the real theorem.

## It is the number of values that matters, not their size

Here is the twist. The bound $N$ played only one role in the story: it limited how many *distinct values* could occur. Suppose instead that both functions take values in an arbitrary finite set $A \subseteq \mathbb{N}$ — possibly sparse, possibly enormous.

> **Sparse Rigidity.** If $f$ and $g$ take values in a common set $A$ with $\#A = m$, and $p_k(f) = p_k(g)$ for all $k < m$, then $f$ and $g$ have the same value distribution.

If your tokens are known to carry only the values $0$ or $10^6$, then two power sums suffice: the count and the sum. The magnitude $10^6$ is irrelevant. The proof is the same Lagrange argument with nodes $A$ instead of $\{0,\dots,N\}$, carried out over any field of characteristic zero.

And this window is exactly the right length, for *every* node set. The witness comes from the **nodal weight vector**
$$w_a \;=\; \prod_{\substack{b \in A \\ b \ne a}} \frac{1}{a - b}, \qquad a \in A,$$
which is the top-degree coefficient of the Lagrange basis polynomial of $a$ and, by the two-sidedness of the inverse, satisfies the perfect annihilation identities
$$\sum_{a \in A} a^k w_a = 0 \quad (k < m-1), \qquad \sum_{a \in A} a^{m-1} w_a = 1 .$$
Clear the denominators to get an integer vector $z_a$, split it into its positive and negative parts, and read each part as a bag of tokens with values in $A$. The annihilation identities say precisely that the two bags have identical power sums for every $k < m - 1$, while their histograms are disjointly supported and hence different.

> **Threshold Theorem.** For any nonempty finite $A \subseteq \mathbb{N}$ with $\#A = m$: the power sums $p_0, \dots, p_{m-1}$ determine the value distribution of any function with values in $A$, and the shorter window $p_0, \dots, p_{m-2}$ does not.

The recipe reproduces the classical witnesses automatically. For $A = \{0,1,2\}$ the weights are $\tfrac{1}{2}, -1, \tfrac{1}{2}$, clearing to $(1, -2, 1)$: the bags $\{0,2\}$ and $\{1,1\}$, exactly the minimal pair found by hand. For the sparse set $A = \{0, 1, 5\}$ the weights are $\tfrac{1}{5}, -\tfrac14, \tfrac{1}{20}$, clearing to $(4, -5, 1)$: the bags $\{0,0,0,0,5\}$ and $\{1,1,1,1,1\}$. Both have five tokens and both sum to five, but their contents could hardly be more different. One power sum short of the threshold, and the reconstruction collapses.

## Where this lives in the world

Recovering a distribution from its moments is one of the oldest problems in analysis, and in general it is delicate: the classical moment problem needs infinitely many moments and can still fail to have a unique solution. What changes here is a single, very common assumption — the values are integers drawn from a known finite palette. Discreteness converts an analytic problem into exact linear algebra with a closed-form inverse, and integrality converts an approximate stability estimate into an exact recovery guarantee.

That combination shows up whenever a system reports aggregate statistics about a quantised population: sketching and streaming algorithms that maintain running power sums and must recover frequency histograms; database query engines answering "how many rows have value $v$" from cached aggregates; spectral fingerprints of graphs and matrices whose eigenvalues are known to be small integers; privacy analyses, where the fact that $N+1$ aggregates determine a histogram *exactly* is precisely the leak one must reason about. The Lebesgue constant is the honest measure of how much noise must be injected before recovery genuinely fails — and the threshold theorem says that no amount of cleverness can compensate for withholding even one power sum.

A bag of numbered tokens, a Vandermonde matrix, and a polynomial that knows how to be $1$ in one place and $0$ everywhere else. That is the whole machine, and it recovers everything there was to know.
