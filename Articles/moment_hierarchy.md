# Counting by Averaging: The Hidden Ladder Above Burnside's Lemma

## A puzzle about necklaces

You have four beads arranged in a square and a supply of coloured paint. How many genuinely different necklaces can you make, if two colourings count as "the same" whenever one can be rotated into the other?

The naive count — colour each bead independently — overcounts wildly, because it treats every rotation of a pattern as a new object. The classical fix is a piece of nineteenth-century magic usually called **Burnside's lemma** (and, more accurately, the Cauchy–Frobenius orbit-counting theorem):

> **Burnside's Lemma.** Let a finite group $G$ act on a finite set $X$. For each $g \in G$ let $X^g = \{x \in X : g\cdot x = x\}$ be the set of points that $g$ leaves where they are. Then the number of orbits — the number of genuinely different configurations — is
> $$\#(X/G) \;=\; \frac{1}{|G|}\sum_{g \in G} |X^g|.$$

In words: *the number of orbits is the average number of fixed points.* You do not need to understand the orbits at all. You only need to count, for each symmetry of your problem, how many things that symmetry happens not to move — and then take the average.

This article is about what happens when you refuse to stop at the average.

## Averages, and everything above them

A probabilist looking at Burnside's lemma sees something familiar. Pick a group element $g$ uniformly at random and record the number $|X^g|$ of points it fixes. You now have a random variable — call it the **fixed-point statistic** — taking non-negative integer values. Burnside's lemma says its *mean* is the number of orbits.

But a random variable has more than a mean. It has a variance, a skewness, and an entire sequence of **moments**
$$M_k \;=\; \frac{1}{|G|}\sum_{g\in G} |X^g|^k, \qquad k = 0,1,2,3,\dots$$
Burnside computes $M_1$. What do the others compute?

The answer, which is the organising theorem of this work, is that *all of them* are orbit counts — not on $X$, but on tuples.

> **The Moment Identity.** Let a finite group $G$ act on a finite set $X$. Let $G$ act on the set $X^k$ of ordered $k$-tuples $(x_1,\dots,x_k)$ diagonally, i.e. $g\cdot(x_1,\dots,x_k) = (g\cdot x_1,\dots,g\cdot x_k)$. Then for every $k \ge 0$,
> $$\sum_{g\in G} |X^g|^k \;=\; |G| \cdot \#\bigl(X^k/G\bigr).$$
> Equivalently, the $k$-th moment of the fixed-point statistic is exactly the number of orbits of $G$ on ordered $k$-tuples of points.

The proof is a single, beautiful observation. A tuple $(x_1,\dots,x_k)$ is fixed by $g$ precisely when each coordinate is; so the fixed-point set of $g$ acting on $X^k$ is the $k$-fold product $(X^g)^k$, of size $|X^g|^k$. Now apply Burnside's lemma — not to $X$, but to $X^k$. That's the whole argument. Every moment is a Burnside average in disguise, one level up.

Suddenly a single classical lemma becomes an infinite **ladder**, and the rungs are all familiar:

- **$k = 0$.** There is exactly one $0$-tuple (the empty one), so $\#(X^0/G) = 1$, and the identity reads $|G| = |G|$. The bottom of the ladder is a tautology, as it should be.
- **$k = 1$.** This is Burnside's lemma itself.
- **$k = 2$.** The number of orbits of $G$ on *ordered pairs* is a classical invariant of a permutation group: its **rank**. So the second moment of the fixed-point statistic is $|G|$ times the rank.
- **$k \ge 3$.** These count orbits on triples, quadruples, … — invariants that are strictly finer, and which the classical lemma alone never reaches.

## What the second rung tells you

Rank is not an abstract curiosity: it is the standard measure of how homogeneous a symmetry group is.

Suppose the action is **transitive**: any point can be moved to any other. Then $\#(X/G) = 1$, so Burnside's lemma degenerates into the statement that the fixed-point statistic has mean exactly $1$ — the average symmetry fixes exactly one point, no matter how large or complicated the group. That single fact is essentially all the first moment can say.

The second moment says much more. First, an exact bookkeeping identity:

> **Rank Splitting.** For any finite group acting on a finite set,
> $$\#\bigl((X\times X)/G\bigr) \;=\; \#(X/G) \;+\; \#\bigl(\{(x,y) : x \ne y\}/G\bigr).$$

The reason is that a pair is either diagonal or not, and $G$ preserves that distinction; the diagonal is a copy of $X$. Combined with the moment identity this gives a sharp criterion:

> **Second-Moment Test for Double Transitivity.** Let $G$ act on a finite set $X$ with at least two points. The action is transitive *and* transitive on ordered pairs of distinct points — that is, $2$-transitive — if and only if
> $$\sum_{g\in G} |X^g|^2 \;=\; 2\,|G|.$$

So $2$-transitivity, one of the strongest homogeneity conditions in group theory, is a single numerical equation about how many things each symmetry fixes. And the test is tight in an instructive way: transitivity alone does *not* force rank $2$. The symmetry group of a square, acting on the four vertices, is transitive; but the pairs $(v, \text{neighbour})$ and $(v, \text{opposite vertex})$ can never be interchanged, so its rank is $3$. Its fixed-point statistic reads $4,0,0,0,2,2,0,0$ across the eight symmetries, and $\sum |X^g|^2 = 16+4+4 = 24 = 3 \cdot 8$ — rank three, right on the nose. The tempting slogan "transitive means rank two" is simply false, and the ladder tells you exactly by how much it fails.

There is a second, more local reading of the same rung. Fix a point $x_0$ and let $H$ be its stabiliser — the symmetries that leave $x_0$ alone. For a transitive action, the orbits of $G$ on pairs correspond exactly to the orbits of $H$ on $X$, the classical **suborbits**:
$$\#\bigl((X\times X)/G\bigr) \;=\; \#(X/H).$$
The bijection sends the $H$-orbit of $y$ to the $G$-orbit of $(x_0,y)$. So the second moment of a global statistic is computable entirely inside one point stabiliser — a global-to-local principle in miniature. And when $X$ has at least two points, those suborbits split as the singleton $\{x_0\}$ together with the orbits on distinct pairs, giving $\#(X/H) = 1 + \#(\text{off-diagonal}/G)$.

## The ladder has shape

Once you know that a sequence of integers is a sequence of moments, you inherit every inequality that probabilists know about moments. The remarkable thing is that these become statements about *counting orbits*, with the group order cancelling out entirely.

Write $o_k = \#(X^k/G)$ for the $k$-th rung.

> **Monotonicity.** For $k \ge 1$, $o_k \le o_{k+1}$: there are never fewer orbits on longer tuples.

(The restriction to $k\ge1$ is genuine: for the empty set, $o_0 = 1$ but $o_1 = 0$.)

> **Log-Convexity.** For all $k \ge 0$,
> $$o_{k+1}^2 \;\le\; o_k \cdot o_{k+2}.$$

This is Cauchy–Schwarz for moments, transported through the identity. Pointwise, $2x^{k+1}y^{k+1} \le x^ky^{k+2} + y^kx^{k+2}$ for non-negative integers $x,y$ — a repackaging of $(x-y)^2 \ge 0$. Summing over all pairs of group elements and symmetrising gives $\bigl(\sum_g a_g^{k+1}\bigr)^2 \le \bigl(\sum_g a_g^{k}\bigr)\bigl(\sum_g a_g^{k+2}\bigr)$ for $a_g = |X^g|$, and each side carries a factor $|G|^2$ which cancels. What remains is a purely combinatorial inequality about orbit counts that seems to have no business being true if you have never met the moment picture.

Integrating log-convexity once yields something stronger still:

> **Superexponential Growth.** If $X$ is non-empty, $\bigl(\#(X/G)\bigr)^k \le \#(X^k/G)$ for all $k$.

The number of orbits on $k$-tuples grows at least like the $k$-th power of the number of orbits on points. And the whole ladder is trapped:

> **The Sandwich.** $|X|^k \;\le\; |G|\cdot o_k \;\le\; |G|\cdot|X|^k$.

The left bound comes from the identity element alone, which fixes everything; the right from the fact that no symmetry can fix more than everything.

One more consequence is arithmetic rather than analytic, and is often overlooked: since $o_k$ is an integer, **$|G|$ divides $\sum_{g\in G} |X^g|^k$ for every $k$**. An infinite family of divisibility constraints on a sequence of ordinary integers, with no visible group theory in the statement.

Finally, high moments control rare events, exactly as Markov's inequality does in probability:

> **Moment Bound on Heavily-Fixing Elements.** For all $t$ and $k$,
> $$\#\{g \in G : |X^g| \ge t\}\cdot t^k \;\le\; |G| \cdot \#(X^k/G).$$

Choosing $k$ large turns knowledge of a high rung into a strong bound on how many symmetries can fix many points at once.

## Where Bell numbers fall out of the sky

The ladder becomes spectacular when the group is as big as possible. Take $X$ with $n$ elements and let $G$ be the full symmetric group of all $n!$ permutations. What are the orbits on $k$-tuples?

Two tuples $(x_1,\dots,x_k)$ and $(y_1,\dots,y_k)$ lie in the same orbit precisely when they have the same **coincidence pattern**: $x_i = x_j$ exactly when $y_i = y_j$. Any relabelling of the underlying set can be realised by a permutation, so the pattern is the only invariant — and provided $k \le n$, every pattern is achievable. A coincidence pattern is nothing but a partition of $\{1,\dots,k\}$ into blocks. Hence:

> **Orbits are Partitions.** For $k \le n$, the orbits of the full symmetric group on $k$-tuples from an $n$-element set are in bijection with the set partitions of a $k$-element set, so $o_k = P(k)$, the $k$-th Bell number.

Feed this back through the moment identity:

> **The Poisson Moment Theorem.** Let $n = |X|$ and let $k \le n$. Then
> $$\sum_{\sigma} |\mathrm{fix}\,\sigma|^k \;=\; P(k)\cdot n!,$$
> the sum being over all $n!$ permutations of $X$.

Divide by $n!$: the $k$-th moment of the number of fixed points of a uniformly random permutation is exactly the $k$-th Bell number, for every $k$ up to $n$. Those are precisely the moments of a **Poisson distribution of mean $1$** — the celebrated Dobiński formula $P(k) = e^{-1}\sum_{m\ge0} m^k/m!$ is the statement that Bell numbers are Poisson moments. So the classical fact that the number of fixed points of a random permutation is asymptotically Poisson$(1)$ is here not a limit theorem but an *exact* finite identity, valid rung by rung as far as $k \le n$, and derived from nothing but orbit counting.

Test it on three points. The six permutations of $\{1,2,3\}$ fix $3,1,1,1,0,0$ points respectively. Then $\sum|\mathrm{fix}| = 6 = 1\cdot 3!$ (Bell number $P(1)=1$); $\sum|\mathrm{fix}|^2 = 12 = 2 \cdot 3!$ ($P(2)=2$); $\sum|\mathrm{fix}|^3 = 30 = 5\cdot 3!$ ($P(3)=5$). And at $k=4$, beyond the range $k \le n = 3$, we get $84 = 14\cdot 3!$ — while $P(4) = 15$. The hypothesis $k\le n$ is not decoration: past it, three points simply cannot exhibit a partition needing four distinct blocks.

There is a bonus. Log-convexity of the ladder was proved for *every* group action, so it holds here too, and the orbit counts are Bell numbers:

> **Bell Numbers are Log-Convex.** $P(k+1)^2 \le P(k)\cdot P(k+2)$ for all $k$.

A classical inequality in enumerative combinatorics, obtained as a special case of Cauchy–Schwarz applied to a random permutation's fixed points. Check the start of the sequence $1, 1, 2, 5, 15, 52$: $4 \le 5$, $25 \le 30$, $225 \le 260$. Comfortably true, and now *explained*.

## A pairing, not just a ladder

The moment identity has a bilinear sibling that reveals what is really going on. If $X$ and $Y$ are two sets carrying actions of the same group,
$$\sum_{g\in G} |X^g|\cdot|Y^g| \;=\; |G|\cdot\#\bigl((X\times Y)/G\bigr),$$
and more generally, for any finite family $X_1,\dots,X_m$ of $G$-sets,
$$\sum_{g\in G}\;\prod_{i=1}^m |X_i^g| \;=\; |G|\cdot\#\Bigl(\bigl(\textstyle\prod_i X_i\bigr)/G\Bigr).$$

Representation theorists will recognise the left-hand side of the two-factor version: $g \mapsto |X^g|$ is the **permutation character** of the $G$-set $X$, and the sum divided by $|G|$ is the standard inner product of two characters. So the identity says: *the inner product of two permutation characters counts orbits on the product*. The moment ladder is the diagonal of a positive-semidefinite pairing on $G$-sets, and its Cauchy–Schwarz inequality is visible directly in the counting:
$$\#\bigl((X\times Y)/G\bigr)^2 \;\le\; \#\bigl((X\times X)/G\bigr)\cdot\#\bigl((Y\times Y)/G\bigr).$$

From this vantage point the whole story is one sentence: **counting orbits is taking an inner product, and the moment hierarchy is what you see when you point that inner product at a single object over and over again.**

## Why it matters

Three things make this ladder worth climbing.

*It unifies.* Burnside's lemma, the rank of a permutation group, suborbit counts, permutation-character inner products, and the Poisson moments of random permutations are not five theorems. They are five values of $k$, or five readings of the same identity.

*It transfers structure.* Because orbit counts *are* moments, every inequality about moments — Cauchy–Schwarz, Markov, monotonicity — becomes a theorem about combinatorics for free, with the group order cancelling. That is how log-convexity of the Bell numbers appears here without any manipulation of partitions.

*It computes.* The right-hand side of the identity, the number of orbits on $k$-tuples, is usually the thing you want and rarely the thing you can enumerate. The left-hand side is a sum over group elements of a quantity — how many points does this symmetry fix? — that is typically immediate. Necklaces, chemical isomers, error-correcting codes, isomorphism classes of graphs on labelled vertices: all are counted this way at $k=1$. The ladder says that the same cheap data, raised to higher powers, already contains the answers for tuples, for rank, for suborbits, and for everything the classical lemma leaves on the table.

The average is only the first rung.
