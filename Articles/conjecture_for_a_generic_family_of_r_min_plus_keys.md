# The Hash That Cannot Hide: Why Min-Plus Cryptography Leaks by Design

## A currency built on tropical arithmetic

Imagine a world in which arithmetic has been quietly rewired. Addition still exists, but multiplication has been replaced: to "multiply" two numbers you simply add them, and to "add" two numbers you take the smaller one. This is the **min-plus algebra**, also called the **tropical semiring**: the operations are

$$x \oplus y = \min(x, y), \qquad x \otimes y = x + y.$$

It sounds like a joke, but it is the native arithmetic of shortest paths, of scheduling, of optimal transport, and of a surprising amount of modern combinatorial geometry. Linear algebra survives the rewiring: a matrix times a vector still makes sense, only now the matrix-vector product

$$(A \otimes m)_i = \min_{j} \left( m_j + A_{ij} \right)$$

computes, for each row $i$, the cheapest way of combining the entries of $m$ with the costs stored in row $i$ of $A$.

Over the last decade several groups have proposed building cryptography on top of this arithmetic. The reasoning is seductive. Classical cryptanalysis is a machine tuned for ordinary linear algebra — Gaussian elimination, lattice reduction, Gröbner bases. In the tropical world, that machine seems to stall: min is not invertible, information is destroyed at every step, and the whole apparatus looks pleasantly hostile to algebraic attack. Tropical key exchange, tropical digital signatures, and — the object of this article — **tropical hash functions** for a hypothetical "tropical cryptocurrency" have all been proposed on exactly this intuition.

A tropical hash is the simplest thing you can write down. Fix a key: an $r \times k$ table $A$ of real numbers. A message is a vector $m \in \mathbb{R}^k$. The digest is the min-plus matrix-vector product,

$$D_i(m) = \min_{1 \le j \le k} \left( m_j + A_{ij} \right), \qquad i = 1, \dots, r.$$

So the digest has $r$ numbers, the message has $k$. The design intuition is that even a modest number of outputs should scramble the message beyond recovery, because each output has thrown away all but one of its $k$ inputs and refuses to say which.

This article is about what happens when you take that intuition apart. The short version: the min-plus hash does not merely fail to be collision-resistant, it fails in a structured, geometric, *completely predictable* way, and one can say exactly how badly, in terms of a single combinatorial invariant. Along the way, three natural attempts to rescue the scheme — more outputs, clever key design, small alphabets — can be shown to fail, or to succeed only in a trivial regime.

## Collisions are not accidents; they are cones

Start with the fundamental question: given a message $m$, which other messages have the same digest?

Here is the crucial observation, and it is embarrassingly simple. Fix an output $i$. Its value $D_i(m)$ is a minimum, and that minimum is attained at some coordinate $j$ — call the coordinates where it is attained the **active set** of the output,

$$\mathrm{Act}_i(m) = \{ j : m_j + A_{ij} = D_i(m) \}.$$

Now *increase* some coordinate $m_q$ of the message. Increasing a coordinate can only push the terms $m_j + A_{ij}$ up, so the minimum can only go up. But if the output $i$ still has an active coordinate $j \ne q$ — a witness for its minimum that you did not touch — the minimum has not moved at all. The output does not notice.

So the recipe for a collision is: *find a coordinate that every output can afford to ignore, and raise it.*

Can you always find one? Each output can be "pinned" to a single coordinate: pick one active coordinate per output. That uses up at most $r$ of the $k$ available coordinates. If $r < k$, at least $k - r$ coordinates are left over, and you can raise all of them, by any nonnegative amounts you like, simultaneously, forever, without changing a single digest value.

This gives the first theorem, and it is stronger than a collision statement.

> **Theorem (Universal Collision Cone).** Let $A$ be any $r \times k$ real key and $m$ any message. The set of directions $v$ such that $D(m + s v) = D(m)$ for all $s \ge 0$ spans a linear subspace of dimension at least $k - r$.

Not "there exists a collision". Not "there exists a colliding ray". A whole $(k-r)$-dimensional continuum of colliding directions, through *every* message, for *every* key. The fiber of the digest map — the set of all messages with a given digest — is not a scattered set of accidental coincidences. It is a polyhedral set with a fat, unbounded cone of escape directions attached to every point.

The geometric name for this object is the **recession cone** of the fiber cell: the set of directions in which you can travel to infinity while staying inside the fiber. What the theorem says is that the recession cone of a min-plus digest fiber is always at least $(k-r)$-dimensional.

## Exactly how fat is the cone?

A lower bound invites the obvious question: is $k - r$ the truth, or just the easy part of it?

Generically it is the truth. Say the key and message are in **general position** at $m$: each output $i$ has a *unique* active coordinate $p(i)$, and these coordinates are distinct for different outputs. This is what you would expect from random data — ties among the $k$ quantities $m_j + A_{ij}$ are measure-zero coincidences, and so is a collision between $p(i)$ and $p(i')$ if the key entries are drawn independently.

> **Theorem (Exact Cone in General Position).** If each output $i$ has a unique minimizing coordinate $p(i)$, then the collision cone at $m$ is exactly
> $$\{ v \in \mathbb{R}^k : v_j \ge 0 \text{ for all } j, \text{ and } v_{p(i)} = 0 \text{ for all } i \}.$$
> If moreover $p$ is injective, the span of this cone has dimension exactly $k - r$.

The proof of the "exactly" direction is where the geometry earns its keep, and it has two halves. First, *no coordinate may decrease*: if $v_q < 0$, then travelling far enough along $v$ drives $m_q + A_{iq}$ below the current digest value of any output $i$, and the digest drops. Since we may travel arbitrarily far, even a tiny negative component eventually bites. Second, *the pinned coordinates are frozen*: if $v_{p(i)} > 0$ for some output $i$ whose minimum is uniquely certified at $p(i)$, then a small step along $v$ raises the unique certificate while the non-certifying terms, which sat a uniform gap $g > 0$ above the minimum, cannot fall by more than a fraction of $g$. So the whole minimum strictly rises. Both halves together squeeze the cone down to the nonnegative orthant of the $k - r$ free coordinates.

Two footnotes make the picture complete. The general-position hypothesis is not vacuous — for any $r \le k$ one can write down a key (put a $0$ in position $(i, i)$ and a $1$ everywhere else) with unique, pairwise distinct minimizers at the zero message. And it is *stable*: if the minimizers are strict with uniform gap $g$, then perturbing every key entry and every message coordinate by less than $g/4$ preserves the same minimizers. General position is an open condition, so the exactness theorem holds on an open set of data, not on a razor-thin slice.

And the hypothesis cannot simply be dropped. With ties, the cone is genuinely bigger. Take $k = 2$, $r = 1$, and the all-zero key. The single output is $\min(m_1, m_2)$; at the origin both coordinates are active. The collision cone then spans the entire plane — dimension $2$, not the predicted $k - r = 1$. Degeneracy helps the attacker, never the designer.

## The real security parameter is not the number of outputs

If ties make the cone bigger, then the number of outputs $r$ is not the right bookkeeping device. What is?

The answer is a clean piece of hypergraph combinatorics, and it comes from a criterion that decides *exactly* which coordinates may be raised.

> **Theorem (Exact Local Criterion).** A set $S$ of coordinates can be raised by arbitrary nonnegative amounts without changing the digest **if and only if** every output has an active coordinate outside $S$.

The "if" is the argument we already made. The "only if" is the interesting one: if some output has *all* of its active coordinates inside $S$, then bumping all of $S$ by a small enough uniform amount $\varepsilon$ raises that output strictly — the inactive coordinates were a definite distance above the minimum and $\varepsilon$ is chosen smaller than that distance.

Read the criterion again with combinatorial eyes. The complement of $S$ must meet every active set. A set that meets every member of a family of sets is a **hitting set** (equivalently, a vertex cover of the hypergraph whose edges are the active sets). So define

$$\tau(A, m) = \text{the least size of a set of coordinates meeting every active set } \mathrm{Act}_i(m).$$

> **Theorem (Hitting-Set Criterion).** A raisable set of $d$ coordinates exists if and only if the active sets admit a hitting set of size at most $k - d$. Consequently the largest coordinate collision cone at $m$ has dimension exactly $k - \tau(A, m)$.

Since choosing one active coordinate per output produces a hitting set, $\tau \le r$ always, and the bound $k - \tau \ge k - r$ recovers the universal theorem. But $\tau$ can be much smaller than $r$: whenever different outputs share active coordinates, one coordinate covers several outputs at once, $\tau$ collapses, and the collision cone grows. **The security parameter of a min-plus digest is $\tau$, not $r$**, and $\tau$ is a property of the key *and the message*, computed locally.

It is worth recording a natural guess that turns out to be wrong, because the failure is instructive. One might expect a **Hall-type** criterion instead: the classical marriage theorem governs when a family of sets admits a *system of distinct representatives* (a transversal — one representative per set, all distinct), and transversals are the reflexive tool for problems of the form "pick one active coordinate per output". But transversals are the wrong invariant here. Take $k = r = 2$ with key rows both equal to $(0, 1)$ and the zero message. Both outputs have the single active coordinate $1$ — the family $\{\{1\}, \{1\}\}$ has no system of distinct representatives whatsoever. Yet coordinate $2$ may be raised freely: a one-dimensional collision cone exists. Transversals ask for *distinct* certificates; the geometry only asks for *some* certificate outside $S$, and sharing is allowed. Hitting sets, not transversals, are the right dual object.

## Can a small alphabet save the scheme?

Everything so far concerns real-valued messages, and a natural defence suggests itself. Real messages give the attacker infinite room; a genuine hash operates on a bounded alphabet, say bytes, or bits. The colliding ray must eventually run into the boundary of the message space. Perhaps, if the alphabet is small relative to the *spread* of the key entries — the difference between the largest and smallest values in $A$ — the ray is cut off before it can produce a legal second message, and injectivity is restored. One would then expect a **key-spread threshold**: collisions appear only once the alphabet size exceeds some explicit function of the key.

This is false, and the refutation is a single line.

> **Theorem (No Bounded-Alphabet Threshold).** Let $r < k$. For **any** key $A$ and **any** two-letter alphabet $\{a, b\}$ with $a < b$, there are two distinct messages over that alphabet with the same digest. In particular, binary messages already collide.

The construction: take the constant message all of whose coordinates equal $a$. Since $r < k$, some coordinate $q$ is *unused* — every output certifies its minimum somewhere other than $q$. Raise that one coordinate from $a$ to $b$. Every output keeps its untouched certificate; the digest does not move. Two distinct legal messages, same digest, done.

The point is that the earlier reasoning about "running out of room" mistakes the nature of the escape. The colliding ray does not need to travel far. It needs to travel *one letter*. The very first step of the alphabet already suffices, and no quantity built from the key — spread, condition number, anything — appears anywhere in the construction. The threshold is exactly two letters, universally. In the integer form: with integer keys and messages in $\{0, 1, \dots, B\}$, any $B \ge 1$ and any $r < k$ admit a collision.

And the threshold is sharp in the only parameter that matters, namely $r$ versus $k$. When $r = k$ there *are* injective keys: take $A_{ij} = 0$ if $i = j$ and $A_{ij} = B+1$ otherwise, on the box $[0, B]^k$. Then the off-diagonal terms $m_j + B + 1 \ge B+1 > m_i$ never win, so $D_i(m) = m_i$: the digest is the identity map. Injective, and utterly useless as a hash — it hides nothing. That is the pincer. Below $r = k$ the digest collides over the smallest nontrivial alphabet; at $r = k$ the only escape is to make the digest as large as the message and, in the extreme case, an outright copy of it. There is no compressing regime in which min-plus digests resist collisions.

## Inverting the hash costs one evaluation

Collision resistance is one property; preimage resistance is another. Given a target digest $y \in \mathbb{R}^r$, how hard is it to find a message $m$ with $D(m) = y$? This is the tropical analogue of *mining*: the miner searches for a message whose digest hits a target.

Here the intuition that tropical structure is hostile has real content. Each equation $\min_j (m_j + A_{ij}) = y_i$ is a *disjunction*: the minimum is attained at coordinate $1$, or at coordinate $2$, or…. There are $k^r$ ways of choosing which coordinate certifies which output, and each choice defines a different linear region. A naive solver would enumerate them. That is exponential.

It is also entirely unnecessary. Split each equation into its two halves. The inequality half, $m_j + A_{ij} \ge y_i$ for all $i$ and $j$, is just a system of coordinatewise lower bounds, and it has a coordinatewise least solution:

$$m^\star_j = \max_i \left( y_i - A_{ij} \right).$$

The equality half — that each minimum is actually *attained* — is where the disjunction lived. But the digest is monotone: raising the message never lowers any output. So if any $m$ satisfies $D(m) = y$, then $m \ge m^\star$ coordinatewise, hence $y_i = D_i(m^\star) \le D_i(m) = y_i$ forces equality, and $m^\star$ itself is already a solution.

> **Theorem (One-Shot Inversion).** A preimage of $y$ exists if and only if the single canonical candidate $m^\star_j = \max_i(y_i - A_{ij})$ is one. When the fiber is nonempty, $m^\star$ is its coordinatewise least element.

Inversion therefore costs one $r \times k$ evaluation. No search, no enumeration, no disjunction. And the same argument survives constraints of the right shape: if mining is restricted to messages inside a box $L \le m \le U$ — a bounded alphabet, or a nonce family given by independent coordinate ranges — the constrained fiber is nonempty exactly when the single shifted candidate $\max(m^\star, L)$ lies below $U$ and hits the target. Restricting to a box does not make tropical mining harder.

The moral, which is sharper than "the scheme is broken": *whatever hardness a tropical mining problem has, it does not come from the min-plus structure.* The min-plus part is solved by a formula. Hardness, if it exists at all, must be manufactured by nonce languages that are not upward closed — constraints that force genuine disjunctive reasoning, not the monotone shortest-path-like structure that min-plus provides for free.

## What is left standing

Let us total up. For an $r \times k$ min-plus digest:

- **Every** fiber, through **every** message, for **every** key, carries a collision cone of dimension at least $k - r$ — a continuum of collisions, not isolated coincidences.
- The exact dimension of the maximal coordinate cone is $k - \tau$, where $\tau$ is the minimum number of coordinates needed to hit all active sets. Generically $\tau = r$; degeneracies only make $\tau$ smaller and the cone larger.
- A two-letter alphabet is already enough to collide, for any key. There is no key-spread threshold and no alphabet-based defence.
- Compression is fatal: the transition sits exactly at $r = k$, and the injective examples at $r = k$ are essentially copies of the message.
- Inversion, including under box constraints, is one evaluation of an explicit formula.

None of this says min-plus algebra is useless — quite the opposite. The very structure that dooms the hash is what makes tropical mathematics powerful elsewhere. Monotonicity plus attainment-of-minima is exactly what makes shortest-path algorithms work and scheduling problems tractable. It is the same structure, seen from the attacker's side.

There is also a general lesson about cryptographic design. "The standard attacks don't apply" is not the same as "attacks don't exist". Min-plus operations resist Gaussian elimination because they are piecewise linear rather than linear — but piecewise linear functions come with their own analysis, and here that analysis is convex geometry, not algebra. Once you ask the right question — *what is the recession cone of a fiber?* — the answer arrives immediately, and it is devastating.

The most interesting things left open are the sharper questions. Is the *full* recession cone — including directions that are not coordinate-aligned — also exactly $k - \tau$-dimensional? Computational experiment on hundreds of random instances says yes without exception. And is computing $\tau$ itself hard? It is a vertex-cover-flavoured quantity, and vertex cover is the archetypal hard combinatorial problem, so one expects deciding $\tau \le d$ to be NP-complete when $r$ is part of the input. That would leave min-plus cryptography in a peculiar position: a security parameter that is perfectly well defined, universally too small to help, and expensive to compute. Not a foundation for a currency — but a rather elegant object to have understood.
