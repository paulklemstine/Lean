# The Coin-Flip Matrix That Cannot Lie

## How a single sign-flip turns a question about random spectra into a question about walks that retrace their steps

Take a large square grid of numbers. Fill the entries above the diagonal by flipping
a fair coin: heads writes $+1$, tails writes $-1$. Put zeros on the diagonal, and
copy each entry above the diagonal into its mirror image below, so that the array is
symmetric. What you now hold is one of the simplest random objects in mathematics — an
$N \times N$ symmetric sign matrix $W$ — and one of the most consequential. Matrices
like this stand in for the energy operators of heavy nuclei, for the correlation
structure of financial markets, for the adjacency data of random networks, and for
the loss landscapes of neural networks. Physicists have been staring at their
eigenvalues since the 1950s.

The famous fact about such matrices is Wigner's semicircle law: rescale the
eigenvalues by $\sqrt{N}$ and, as $N$ grows, their histogram settles into a perfect
half-ellipse — the semicircle of radius $2$. It is one of those results that feels
like a law of nature. But its usual proof is an asymptotic one: it says what happens
*eventually*, in a limit, with error terms swept into little-$o$ notation.

This article is about something sharper. It turns out that for this particular
ensemble — the symmetric coin-flip matrix — a great deal is true not eventually, but
*exactly*, at every finite size $N$, with no error term whatsoever. And the reason is
a piece of pure combinatorics so clean that it can be stated in a sentence: **the
average of any product of matrix entries is either exactly $1$ or exactly $0$, and
which one it is depends only on whether every edge has been used an even number of
times.**

Everything else in this story flows from that dichotomy.

---

## The exact dichotomy

Let us be precise about the object. Index the vertices by $1, \dots, N$. For each
unordered pair $\{i, j\}$ with $i \neq j$ we flip an independent fair coin and set
$W_{ij} = W_{ji} = \pm 1$ accordingly; the diagonal entries $W_{ii}$ are all zero. A
"configuration" is one particular assignment of signs to all $\binom{N}{2}$ edges,
and the ensemble average $\mathbb{E}[\,\cdot\,]$ is the plain arithmetic average over
all $2^{\binom{N}{2}}$ configurations, each equally likely.

Now pick any finite list of *steps* — pairs of indices $(a_1, b_1), \dots, (a_n, b_n)$
— and form the monomial
$$W_{a_1 b_1} W_{a_2 b_2} \cdots W_{a_n b_n}.$$
Two features of the list matter. It is **loop-free** if no step stays put, i.e.
$a_t \neq b_t$ for every $t$. And for each unordered pair $e = \{u, v\}$, its
**multiplicity** $m_e$ is the number of steps $t$ for which $\{a_t, b_t\} = e$.

> **The Exact Ensemble Dichotomy.** For any finite family of steps,
> $$\mathbb{E}\!\left[\prod_{t=1}^{n} W_{a_t b_t}\right] =
> \begin{cases}
> 1 & \text{if the family is loop-free and every multiplicity } m_e \text{ is even},\\[2pt]
> 0 & \text{otherwise.}
> \end{cases}$$

There is no third case, and no approximation. The proof splits neatly in two.

If some step is a loop, $a_t = b_t$, then the monomial contains the factor
$W_{a_t a_t} = 0$ and the whole product is identically zero. So assume loop-freeness.
Then, grouping equal edges, the monomial equals
$\prod_e \varepsilon_e^{\,m_e}$, where $\varepsilon_e = \pm 1$ is the sign attached to
edge $e$.

If every $m_e$ is even, each factor $\varepsilon_e^{m_e}$ equals $1$ *for every single
configuration* — the monomial is the constant function $1$, and its average is $1$.
No probability was used at all; the statement is deterministic.

If some multiplicity $m_{e_0}$ is odd, we run the **sign-flip involution**. Pair up
configurations by flipping the single sign $\varepsilon_{e_0}$ and leaving everything
else alone. This is an involution — do it twice and you are back where you started —
so it perfectly partitions the configuration space into pairs. Under the flip the
monomial gets multiplied by $(-1)^{m_{e_0}} = -1$, because $e_0$'s sign appears an odd
number of times and every other factor is untouched. So the monomial's values on the
two members of each pair cancel, and the total average is exactly $0$.

That is the whole argument. An involution and a triviality. Yet it is the engine of
everything below.

---

## From spectra to walks

Why do we care about monomials in matrix entries? Because they are what powers of a
matrix are made of. Expanding the trace of the $L$-th power,
$$\operatorname{tr}(W^L) = \sum_{w_0, w_1, \dots, w_{L-1}} W_{w_0 w_1} W_{w_1 w_2}
\cdots W_{w_{L-1} w_0},$$
the sum being over all $N^L$ sequences of indices. Each term is exactly a monomial of
the kind above, and the index sequence has a name: it is a **closed walk of length
$L$**. Think of $N$ cities and a traveller who makes $L$ hops, the $t$-th hop going
from city $w_t$ to city $w_{t+1}$, with the index arithmetic done cyclically so that
the last hop returns home.

Average the trace over the ensemble, apply the dichotomy term by term, and every
single term collapses to $0$ or $1$. What survives is a count.

Call a closed walk **even** if (i) it never stands still — no hop begins and ends at
the same city — and (ii) every edge it uses, it uses an even number of times. Write
$\mathcal{E}(N, L)$ for the number of even closed walks of length $L$ on $N$ cities.
Then:

> **The Walk-Counting Theorem.** For every $N \geq 1$ and every $L \geq 1$,
> $$\mathbb{E}\!\left[\operatorname{tr}(W^L)\right] = \mathcal{E}(N, L).$$

This is an identity, not an asymptotic. A probabilistic average of a spectral quantity
— the $L$-th moment of the eigenvalue distribution, up to normalisation, since
$\operatorname{tr}(W^L) = \sum_i \lambda_i^L$ — is *literally the same integer* as a
count of walks. The randomness has been fully converted into combinatorics with no
loss and no remainder.

---

## Odd moments vanish, exactly

The first dividend is immediate, and it is a genuinely finite-$N$ statement.

> **Odd Moments Vanish Exactly.** For every $N$ and every $k \geq 0$,
> $$\mathbb{E}\!\left[\operatorname{tr}(W^{2k+1})\right] = 0.$$

The proof is a one-line parity argument on the walk side. Every hop of a walk uses
exactly one edge, so the total number of hops is the sum of the edge multiplicities:
$$L = \sum_{e} m_e.$$
If all the $m_e$ are even, this sum is even, hence $L$ is even. An odd-length closed
walk therefore cannot be even, $\mathcal{E}(N, 2k+1) = 0$, and the moment vanishes.

Note what this is *not*. It is not "the odd moments are small", or "they tend to zero
after normalisation". They are zero, on the nose, for every dimension. The
distribution of eigenvalues of this ensemble is perfectly symmetric in a very strong
average sense — and the reason is that you cannot walk an odd number of steps and
still double back over everything.

---

## Counting the even walks

Once moments are walk counts, computing moments becomes combinatorics. Let us do the
first few.

**Length two.** A closed $2$-walk is just a pair $(w_0, w_1)$: hop out, hop back. It
is even precisely when $w_0 \neq w_1$, in which case both hops traverse the single
edge $\{w_0, w_1\}$, giving it multiplicity $2$. So
$$\mathcal{E}(N, 2) = N(N-1).$$
This says $\mathbb{E}[\operatorname{tr}(W^2)] = N^2 - N$, which one can also see
directly: $\operatorname{tr}(W^2) = \sum_{i \neq j} W_{ij}^2 = N(N-1)$ for *every*
configuration. The second moment is not random at all.

**Length four.**
$$\mathcal{E}(N, 4) = N(N-1)(2N-3).$$

**Length six.**
$$\mathcal{E}(N, 6) = N(N-1)\left(5N^2 - 15N + 11\right).$$

These are exact polynomials, not leading-order estimates. And their appearance is not
an accident of small cases: there is a structure theorem behind them.

---

## Why the counts are polynomials

Two structural facts control $\mathcal{E}(N, L)$.

The first is that **even walks are short-sighted**. Suppose a closed walk of length
$L$ is even. Every edge it actually traverses is traversed an even and nonzero number
of times, hence at least twice; since the multiplicities sum to $L$, the walk uses at
most $L/2$ distinct edges. Moreover, a connected closed walk visits at most one more
vertex than it has edges — the "spanning-tree inequality", proved by sending each
newly discovered vertex to the edge along which it was first reached, a map that is
injective because two vertices cannot each be discovered strictly before the other.
Combining:

> **The Vertex Bound.** An even closed walk of length $L$ uses at most $L/2$ distinct
> edges and visits at most $L/2 + 1$ distinct vertices.

The second fact is that **evenness does not know the names of the vertices**.
Composing a walk with an injective relabelling of the vertex set changes neither
loop-freeness nor any edge multiplicity: injectivity guarantees that two steps are
identified as the same edge after relabelling exactly when they were before. So the
number of even closed $L$-walks whose vertex set is a prescribed set $S$ depends on
$S$ only through $|S|$.

Put these together. Classify even closed walks by the set $S$ of vertices they
actually visit. For each $r$, there are $\binom{N}{r}$ choices of an $r$-element $S$,
and the number of even closed $L$-walks using all of $S$ is a number $b_{r,L}$ that
does not depend on $N$ at all — a pure **shape count**. Hence:

> **Polynomiality.** For every $L$,
> $$\mathcal{E}(N, L) = \sum_{r} \binom{N}{r}\, b_{r, L},$$
> where $b_{r,L}$ counts the even closed $L$-walks on $r$ labelled vertices that visit
> every one of them. Moreover $b_{r,L} = 0$ whenever $2r > L + 2$, so the sum is finite
> and $\mathcal{E}(\cdot, L)$ is a polynomial of degree at most $L/2 + 1$.

Every moment of the coin-flip ensemble is a polynomial in the dimension, and the
polynomial is determined by finitely many dimension-free integers. In the binomial
basis the first three read
$$\mathcal{E}(N, 2) = 2\binom{N}{2}, \qquad
\mathcal{E}(N, 4) = 2\binom{N}{2} + 12\binom{N}{3}, \qquad
\mathcal{E}(N, 6) = 2\binom{N}{2} + 60\binom{N}{3} + 120\binom{N}{4}.$$
The shape vectors are $(2)$, $(2, 12)$, and $(2, 60, 120)$. Expanding the last one
gives back $N(N-1)(5N^2 - 15N + 11)$.

---

## The semicircle, seen through the top shapes

Now normalise the way random matrix theory tells us to. Divide the matrix by
$\sqrt{N}$ and average the eigenvalue powers: the $m$-th normalised moment is
$$\mathbb{E}\!\left[\frac{1}{N}\operatorname{tr}\!\left(\frac{W}{\sqrt{N}}\right)^{\!m}\right]
= \frac{\mathcal{E}(N, m)}{N^{1 + m/2}}.$$

The degree bound says the numerator has degree at most $m/2 + 1$, exactly matching the
denominator. So the normalised moments are **bounded uniformly in $N$**, at every
order — the total shape count $\sum_r b_{r,m}$ is an explicit, dimension-free bound.
This is the tightness half of the semicircle law, and here it holds at all orders with
a combinatorial constant you could in principle write down.

The limit itself is read off from the leading coefficient, which comes from the *top*
shape count $b_{k+1, 2k}$: the walks that visit the maximum permitted $k+1$ vertices.
Such a walk has no slack anywhere. It must use exactly $k$ distinct edges, each exactly
twice, and those $k$ edges must connect $k+1$ vertices — which forces them to form a
spanning tree. The walk is therefore the *contour traversal* of a plane tree with each
edge doubled: go down an edge, explore, come back up. The classical bijection between
such traversals and balanced bracket sequences supplies a Catalan number, and $(k+1)!$
accounts for which vertex gets which label. So one expects
$$b_{k+1,\,2k} = C_k \cdot (k+1)!, \qquad C_k = \frac{1}{k+1}\binom{2k}{k},$$
and hence a leading coefficient of exactly $C_k$. At the orders where the count can be
carried out exhaustively this is confirmed:
$$b_{2,2} = 2 = C_1 \cdot 2!, \qquad b_{3,4} = 12 = C_2 \cdot 3!, \qquad
b_{4,6} = 120 = C_3 \cdot 4!.$$
The Catalan numbers $1, 2, 5$ appear on cue.

Order six can then be pushed all the way to a limit theorem. Exactly, at finite $N$,
$$\mathbb{E}\!\left[\frac{1}{N}\operatorname{tr}\!\left(\frac{W}{\sqrt{N}}\right)^{\!6}\right]
= \frac{(N-1)(5N^2 - 15N + 11)}{N^3} = 5 - \frac{20}{N} + \frac{26}{N^2} - \frac{11}{N^3},$$
which converges to $5 = C_3$, the sixth moment of the semicircle distribution. And
the correction terms are not estimates — they are the exact finite-size corrections,
visible as a $-20/N$ leading defect. At $N = 10$ the sixth moment is already $3.249$;
at $N = 100$, $4.803$; at $N = 10^4$, $4.998$. The approach to the semicircle is
$O(1/N)$, and you can see the constant.

---

## What the dichotomy buys

Step back and look at the shape of the argument. There is one probabilistic input,
and it is a sign flip. From it:

- every moment becomes a walk count, **exactly**;
- odd moments vanish **exactly**, at every finite dimension, with no asymptotics;
- moments are **polynomials in the dimension** with dimension-free coefficients;
- all normalised moments are **uniformly bounded** by explicit combinatorial constants;
- the low-order moments are computable in closed form: $N(N-1)$, $N(N-1)(2N-3)$,
  $N(N-1)(5N^2-15N+11)$;
- and the semicircle's Catalan numbers emerge as counts of doubled plane trees.

The lesson is one that recurs across mathematics. A statement about averages over an
enormous probability space — $2^{\binom{N}{2}}$ configurations, more than the atoms in
the universe by $N = 12$ — has been replaced by a statement about a finite, concrete,
enumerable set of combinatorial objects. The randomness does not merely simplify in the
limit; for this ensemble it disappears entirely, leaving behind walks that retrace
their steps.

The remaining frontier is to prove the tree-contour bijection in full generality. The
two hard structural ingredients are already secured: the vertex bound forces the
extremal walks to use exactly $k$ doubly-traversed edges, and relabelling invariance
reduces the count to unlabelled shapes. What is missing is the bijection itself —
between doubled spanning trees traversed cyclically and Dyck paths of semilength $k$.
Once it is in place, the entire semicircle law for this ensemble becomes a theorem
about brackets: a statement whose only randomness was ever a single flipped sign.
