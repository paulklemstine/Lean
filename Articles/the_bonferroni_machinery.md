# Which Marginals? How a Second Moment Rescued a Compression Bound

## A machine that eats probabilities

There is a certain kind of machine in combinatorics that everybody uses and almost nobody looks at closely. You feed it a list of bad events — event $A_1$, event $A_2$, up to event $A_k$ — together with two numbers: how likely each single bad event is, and how likely any *two* of them are to happen together. The machine hands you back a guarantee: *at least one of these events happens with probability at least so-and-so.*

The classical machine of this type is the **second Bonferroni inequality**. In exact counting form it says that for any finite family of finite sets $A_1,\dots,A_k$ inside a finite universe,

$$\sum_{i=1}^{k} |A_i| \;\le\; \Bigl|\bigcup_{i=1}^{k} A_i\Bigr| \;+\; \sum_{i \ne j} |A_i \cap A_j|.$$

You can read it as: the sum of the sizes overcounts the union, but only by the pairwise overlaps. It is a beautiful, elementary statement, and it powers a great many lower bounds in probabilistic combinatorics and information theory.

This article is about a moment when that machine produced a suspicious-looking answer, and about what happened when we asked whether the fault lay with the input or with the machine.

## The suspicious answer

The setting is data compression, in its purest cartoon form: **hashing**.

You have a large alphabet of possible messages. Nature has told you that in practice only a modest subset $S$ of them — the *typical set* — ever occurs. You want to compress: you pick a **codebook**, which is nothing but a function $H$ assigning to every message one of $M$ short labels. When a message $x$ arrives you transmit $H(x)$, and the receiver looks up which typical message has that label.

The scheme fails at $x$ if some *other* typical message $y$ carries the same label — a **collision** $H(y) = H(x)$. If we pick the labels uniformly at random and independently, a single collision has probability exactly $1/M$, and there are $k = |S \setminus \{x\}|$ competitors, so we expect failure with probability roughly $k/M$. Shannon's random-coding argument makes the upper half of this precise: the failure probability is at most $k/M$. Compression is possible whenever $k \ll M$.

The interesting question is the *converse*: is the failure probability also *at least* something like $k/M$? Is $k \approx M$ really the wall, or could a lucky random codebook do better?

Feed the Bonferroni machine the two obvious numbers — a single collision has probability $1/M$, a pair of collisions has probability at most $1/M^2$ — and out comes

$$\Pr[\text{failure}] \;\ge\; \frac{k}{2M}, \qquad \text{valid only when } 2(k-1) \le M.$$

Look at that side condition. It says the bound is available *only in the regime where the bound is small*. Precisely when $k$ approaches $M$ — the interesting regime, the wall — the guarantee evaporates. Something is wrong. But what?

Two suspects. Maybe the **marginals** — the probabilities $1/M$ and $1/M^2$ we fed in — are too crude, and a sharper description of the geometry of collision events would fix things. Or maybe the **machinery** — the Bonferroni inequality itself — is the bottleneck, and the same two numbers, fed to a different machine, would already do better.

The answer, it turns out, is: **the machinery**.

## A different machine: the second moment

Here is the replacement. For any finite family $A_1,\dots,A_k$ of subsets of a finite universe,

$$\Bigl(\sum_{i=1}^{k} |A_i|\Bigr)^{2} \;\le\; \Bigl|\bigcup_{i=1}^{k} A_i\Bigr| \cdot \sum_{i,j=1}^{k} |A_i \cap A_j|.$$

This is the **Chung–Erdős inequality** in exact counting form — the second-moment or Paley–Zygmund method, stripped of all measure theory and written as a statement about integers.

Its proof is a double count that fits in a paragraph. For each point $w$ of the union, let $f(w)$ be its **multiplicity**: the number of indices $i$ with $w \in A_i$. Then summing multiplicities one set at a time gives $\sum_i |A_i| = \sum_{w} f(w)$, and summing over ordered pairs gives $\sum_{i,j} |A_i \cap A_j| = \sum_{w} f(w)^2$, because a point $w$ lies in $A_i \cap A_j$ for exactly $f(w)^2$ ordered pairs $(i,j)$. So the inequality is nothing but Cauchy–Schwarz,

$$\Bigl(\sum_{w \in U} f(w)\Bigr)^2 \le |U| \sum_{w \in U} f(w)^2,$$

applied to the multiplicity function on the union $U$. Bonferroni controls the union by a *linear* overcount; Chung–Erdős controls it by a *quadratic* one — and quadratics are gentler where linear estimates blow up.

## The marginal-profile theorem

Now abstract away from hashing entirely. Suppose all you know about a family $A_1,\dots,A_k$ inside a universe of size $N$ is its **marginal profile**:

* every set has **first marginal exactly $1/m$**, meaning $m \cdot |A_i| = N$;
* every ordered pair of distinct sets has **second marginal at most $1/c$**, meaning $c \cdot |A_i \cap A_j| \le N$.

Then feeding these into the second-moment inequality yields, with no further hypotheses at all,

$$c\,k\,N \;\le\; m \cdot \Bigl|\bigcup_i A_i\Bigr| \cdot \bigl(c + m(k-1)\bigr),$$

or in probability form

$$\Pr\Bigl[\bigcup_i A_i\Bigr] \;\ge\; \frac{k}{m + \dfrac{m^2 (k-1)}{c}}.$$

The derivation is three lines of bookkeeping. The first moment gives $m\sum_i |A_i| = kN$. The second moment splits into $k$ diagonal terms (each $|A_i|$) and $k(k-1)$ off-diagonal terms (each at most $N/c$). Substituting both into Chung–Erdős and cancelling a factor of $kN$ gives the displayed inequality.

**And there is no side condition.** No "valid only when $2(k-1) \le M$". The bound holds for every $k$, every $m$, every $c$. That is the whole point: the regime restriction in the original argument was never a fact about collisions. It was an artefact of which inequality happened to be reached for.

## Two sanity checks that go opposite ways

A bound with no side conditions invites two questions. Is it sharp? And is the second marginal really needed?

Both have crisp answers, and they come from the *same* example: the **constant family**. Take a universe with just $N = 2$ points and let $A_1 = A_2 = A_3$ all be the same single point. Then $m = 2$ (each set is half the universe), and the pairwise intersections are also that single point, so $c = 2$ as well — the worst possible pairwise behaviour, no better than the singles. And $k = 3$.

Plug in. The theorem predicts $c\,k\,N = 2 \cdot 3 \cdot 2 = 12$ on the left, and $m|U|(c + m(k-1)) = 2 \cdot 1 \cdot (2 + 2\cdot 2) = 12$ on the right. **Equality.** So the marginal-profile theorem is *attained*: no better bound can be extracted from the numbers $(m, c, k, N)$ alone. Any improvement must know something extra about the family.

Now try the Bonferroni-shaped conclusion $|U| \ge kN/(2m)$ on the same family. It asserts $2m|U| \ge kN$, i.e. $2 \cdot 2 \cdot 1 = 4 \ge 6$. **False.** The constant family has a perfect first marginal and no pairwise control whatsoever, and it demolishes the conclusion. So the pairwise hypothesis genuinely carries weight; you cannot get a union bound of this strength from the first marginal alone.

Together: the abstract theorem is exactly as strong as its inputs permit, and its inputs are exactly what it needs.

## Back to hashing: an unconditional converse

Return to the compression problem and feed the same two marginals — $m = M$ for a single collision, $c = M^2$ for a pair — into the new machine. Out comes

$$\Pr[\text{failure}] \;\ge\; \frac{k}{M + k - 1}, \qquad \text{for all } k, \; \text{for all } M \ge 1.$$

Three things are worth noticing.

First, **it never loses**. Whenever the old side condition $2(k-1) \le M$ held, we have $M + k - 1 \le 2M$, so $k/(M+k-1) \ge k/(2M)$: the new bound dominates the old one throughout the old bound's entire domain of validity.

Second, **it has content the old bound could never have had**. As soon as $k \ge M$ — as soon as there are at least as many competing typical messages as there are labels — the new bound gives $k/(M+k-1) > 1/2$. A uniformly random codebook fails **more than half the time**. That is a genuine converse to Shannon's positive result: random hashing does not merely stop being provably good above the pigeonhole rate, it is provably bad. The old bound is not just weaker here; it is unavailable, since its hypothesis fails and its value exceeds $1$.

Third, and most tellingly, **not a single new probability estimate was required**. The same two marginals that gave the conditional bound give the unconditional one. The improvement is entirely in the machine.

## What the events actually look like

Having settled the question, one naturally wants to know how much room was left in those marginals. The answer is: essentially none, and understanding why brings out a pretty piece of geometry.

Call a **collision pattern** any graph $P$ on the set of messages, and let its **pattern event** be the set of codebooks that realise every collision demanded by $P$ — that is, $H(a) = H(b)$ for every edge $(a,b)$ of $P$. Which codebooks are these? A codebook realises the pattern precisely when it is constant on each connected component of the pattern graph, since equality propagates along paths. So a codebook satisfying $P$ is exactly a free choice of one label per component:

> **The component law.** The number of codebooks realising a collision pattern $P$ is exactly $M^{\,c(P)}$, where $c(P)$ is the number of connected components of $P$ (isolated vertices included).

Every marginal one might feed into any Bonferroni- or moment-type expansion is an instance. The **star pattern**, in which a whole set $T$ of competitors is joined to a fixed message $x \notin T$, collapses $T \cup \{x\}$ into a single component and leaves the rest alone, so it has $|\iota| - |T|$ components, where $|\iota|$ is the total number of messages. Its probability is therefore exactly $M^{-|T|}$: a prescribed star of $t$ collisions happens with probability exactly $1/M^t$. The two marginals fed into the original argument are the cases $t = 1$ and $t = 2$.

In particular the second marginal — fed in as an *inequality*, "at most $1/M^2$" — is in fact an *equality*. There was no slack to recover. And here is the striking part: two collisions sharing a vertex ($H(p) = H(r)$ and $H(q) = H(r)$) and two collisions on disjoint pairs ($H(p) = H(q)$ and $H(r) = H(s)$) are geometrically very different patterns, yet both have probability exactly $1/M^2$, because both remove exactly two components. **The machinery is blind to the shape of a pattern and sees only its component count.** Which is exactly why improving the answer required changing the machinery.

## The exact answer, and where everything sits

One can go further still and compute the failure probability outright. The key is a **conditional marginal principle**: if an event $G$ places no constraint on the label of message $y$ — formally, if $G$ is stable under overwriting the $y$-th coordinate of a codebook — then conditionally on $G$ the collision $H(y) = H(x)$ still has probability exactly $1/M$. Peeling off competitors one at a time, each new competitor multiplies the *survival* count by exactly $(M-1)/M$, and induction gives the exact law:

$$\Pr[\text{failure}] \;=\; 1 - \Bigl(1 - \frac{1}{M}\Bigr)^{k}.$$

Brute-force enumeration confirms it in small cases: with $3$ messages and $2$ labels there are $8$ codebooks and exactly $8 - 1^2\cdot 2 = 6$ failing ones; with $4$ messages and $3$ labels, $81 - 2^3 \cdot 3 = 57$ of the $81$ codebooks fail.

With the exact law in hand every estimate in the story falls into place. Bernoulli's inequality in one direction recovers Shannon's $k/M$; a small integer inequality, $(M-1)^j(M+j) \le M^{j+1}$, in the other direction shows the second-moment bound $k/(M+k-1)$ is implied by, and strictly weaker than, the exact law. The result is a clean hierarchy, valid for every typical set, every $M \ge 1$ and every $k \le M+1$:

$$\frac{k}{2M} \;\le\; \frac{k}{M+k-1} \;\le\; \Pr[\text{failure}] \;=\; 1 - \Bigl(1-\frac{1}{M}\Bigr)^{k} \;\le\; \frac{k}{M}.$$

The original Bonferroni output sits at the far left — the weakest member of a four-term chain whose middle terms use only the first two marginals. The failure probability of a uniformly random codebook is $\Theta(\min(1, k/M))$ for all $k$ and $M$, with no regimes and no exceptions.

## Making it deterministic

A last dividend. Random coding is only ever a device: what you want at the end is one *fixed* codebook that works. The standard derandomisation averages the union bound over all codebooks and produces a codebook losing at most $|S|(|S|-1)/M$ typical messages. That statement is vacuous the moment $|S| - 1 \ge M$ — again, exactly the interesting regime.

Averaging the *exact* law instead, one obtains a codebook $H$ with

$$M^{k}\,|\mathrm{bad}(H)| \;\le\; |S|\,\bigl(M^{k} - (M-1)^{k}\bigr), \qquad k = |S| - 1,$$

that is, a fixed codebook losing at most a $1 - (1 - 1/M)^{k}$ fraction of the typical set. For $M \ge 2$ that fraction is strictly less than $1$ however large $S$ is: **the statement is never vacuous.** And the integer inequality $M^k - (M-1)^k \le k\,M^{k-1}$ — that is, $1 - (1-1/M)^k \le k/M$ — shows the new bound always implies the old one. Strictly better, everywhere.

## The moral

It is easy, when a bound comes out with an awkward hypothesis attached, to blame the estimates and go hunting for sharper ones. Here the estimates were already exact — the pairwise marginal was an equality, not an inequality, and no refinement of it existed to be found. The awkward hypothesis lived entirely in the inequality that consumed them.

Bonferroni and Chung–Erdős take *identical* input: a first marginal and a second marginal. They differ in what they do with it. One overcounts linearly and breaks down when the overcount exceeds the truth; the other overcounts quadratically and degrades gracefully forever. Swapping them turned a bound with an artificial ceiling into an unconditional converse — and, as a bonus, into a converse strong enough to say that above the pigeonhole rate random hashing fails more often than it succeeds.

When a theorem carries a side condition, it is always worth asking which half of the argument it belongs to. Sometimes the answer is that your data were fine all along, and you were simply using the wrong machine.
