# Every Semiprime Hides in Two Trees — And Neither One Will Help You Factor It

## The oldest table in mathematics

Around 1800 BCE a scribe in Babylon pressed a stylus into a clay tablet and recorded fifteen rows of numbers. We call it Plimpton 322. Its rows are Pythagorean triples: whole numbers $a$, $b$, $c$ with

$$a^2 + b^2 = c^2.$$

Four thousand years later we still have not run out of things to say about them. This article is about one such thing — a fact that is at once completely elementary, slightly startling, and, in the end, a beautifully clean disappointment.

Here is the punchline in one sentence. **Every odd number that factors as a product of two coprime pieces sits at a specific, computable address in each of two famous infinite trees — and its address literally *is* its factorization.** Finding that address would factor the number. And we can now prove, exactly, that walking either tree to find it is always more expensive than the crude method Fermat published in the seventeenth century.

That is a negative result. But it is a *sharp* negative result, and sharp negatives are how a research direction is properly closed rather than merely abandoned.

## From triples to a pair of dials

The first thing to know is that Pythagorean triples are not really a three-dimensional zoo. They are parameterized by two numbers. Euclid knew this. Take any pair of whole numbers $(m,n)$ with

$$1 \le n < m, \qquad \gcd(m,n)=1, \qquad m+n \text{ odd},$$

and form

$$a = m^2 - n^2, \qquad b = 2mn, \qquad c = m^2 + n^2.$$

Then $a^2+b^2=c^2$, and the triple is *primitive*: $a$ and $b$ share no common factor. Conversely every primitive triple arises this way from exactly one such pair. So the entire infinite family of primitive triples is nothing but the set of admissible pairs $(m,n)$ — call these the **nodes**. The smallest node is $(2,1)$, which produces $(3,4,5)$.

Now stare at the odd leg:

$$a = m^2 - n^2 = (m-n)(m+n).$$

This is the whole story. *The odd leg of every primitive Pythagorean triple comes pre-factored.* A node is not merely a triple. A node **is** a factorization.

## The two trees

In 1963 F. J. M. Barning, and independently A. Hall and later B. Berggren, discovered something remarkable: all primitive triples fit into a single infinite ternary tree, rooted at $(3,4,5)$, with three explicit rules for producing children. In Euclid coordinates the three Berggren moves are startlingly simple:

$$(m,n) \mapsto (2m-n,\; m), \qquad (m,n) \mapsto (2m+n,\; m), \qquad (m,n) \mapsto (m+2n,\; n).$$

Start at $(2,1)$, apply these in every possible sequence, and you generate every admissible pair exactly once. No triple is missed; no triple appears twice.

Decades later H. Lee Price found a *different* tree on the same vertex set, with a completely different set of three moves:

$$(m,n) \mapsto (2m,\; m-n), \qquad (m,n) \mapsto (2m,\; m+n), \qquad (m,n) \mapsto (m+n,\; 2n).$$

Same root. Same nodes. Same "every node exactly once". Different tree.

This is the **interlock**: two ternary trees, sharing a vertex set and a root, disagreeing about essentially every edge.

Why do both work? Because each move preserves the three conditions defining a node. The subtle case is Price. The Berggren matrices have determinant $\pm 1$, so they are invertible over the integers and automatically preserve coprimality. Price's matrices have determinant $\pm 2$. A determinant-$2$ map can in principle turn a coprime pair into a pair sharing a factor of $2$ — but the parity condition $m+n$ odd forbids exactly that. Price's tree lives precisely in the gap that the parity condition leaves open. There is a clean general statement behind this: if $k$ divides both coordinates of the image of a coprime pair under an integer matrix, then $k$ divides the determinant of that matrix. Determinant $\pm1$ forces $k = 1$ for free; determinant $\pm2$ forces $k \in \{1,2\}$, and parity kills the $2$.

## The $N$-node identity

Here is the theorem that makes this more than a curiosity.

> **The $N$-Node Identity.** Let $N = pq$ where $p$ and $q$ are odd, coprime, and $1 \le p < q$. Then the pair
> $$(m,n) = \left(\frac{p+q}{2},\ \frac{q-p}{2}\right)$$
> is a valid node. Its odd leg is exactly $N$:
> $$m^2 - n^2 = (m-n)(m+n) = p \cdot q = N,$$
> its hypotenuse is $(p^2+q^2)/2$, and its even leg is $(q^2-p^2)/2$. Consequently $N$ occupies one and only one address in the Berggren tree, and one and only one address in the Price tree.

The check is a line of algebra: writing $p=2a+1$, $q=2b+1$, the pair becomes $(a+b+1,\, b-a)$, which is manifestly integral; coprimality of $p,q$ transfers to $m,n$, and $m+n = q$ is odd. Then $m^2-n^2 = (m-n)(m+n) = pq$.

The pair $\left(\frac{p+q}{2},\frac{q-p}{2}\right)$ is exactly Fermat's pair: Fermat's method of factorization searches for $m$ with $m^2-N$ a perfect square $n^2$, and this is that $(m,n)$. So the dictionary is perfect and reversible: nodes $\leftrightarrow$ coprime odd factorizations, via $(m,n) \mapsto (m-n,\, m+n)$ in one direction and Fermat's pair in the other. Each is inverse to the other.

Take $N = 15 = 3 \times 5$. Fermat's pair is $(4,1)$: odd leg $16-1=15$, even leg $8$, hypotenuse $17$. The triple $(15,8,17)$ *contains* the factorization of $15$ in plain sight: $15 = (4-1)(4+1)$. Take $N = 391 = 17\times 23$. Fermat's pair is $(20,3)$: the triple $(391, 120, 409)$, and $391 = 17\cdot 23$ read straight off as $(20-3)(20+3)$.

So the slogan is now a theorem: **factoring $N$ is the same problem as finding the $N$-node.** Walk either tree to the right address and the factorization falls out; in fact the root-to-node word *is* the factorization, in coded form.

An important false start is worth recording. One might instead hope to find $N$ on the *hypotenuse* — to look for nodes with $N \mid m^2+n^2$. That embedding is empty in the worst cases, for a reason as old as Fermat: if $N$ has a prime factor $p \equiv 3 \pmod 4$, then no primitive triple at all has hypotenuse divisible by $p$, because $-1$ is not a square modulo such a $p$ and primitivity forbids $p$ dividing both $m$ and $n$. For $N = 15, 21, 35, 77, 91$ the hypotenuse search finds nothing whatsoever. The odd leg is the right place to look; that is not a matter of taste but of a congruence.

## Two descents, genuinely different

So we have one vertex set and two trees. How different are they, really? Three exact separations.

**They are not the same tree in disguise.** The Berggren generators have determinants $+1, -1, +1$; Price's have $-2, +2, +2$. Determinant is invariant under change of coordinates, so no invertible linear change of variables can carry a Berggren move to a Price move. The two descents are inequivalent, permanently.

**One is leg-symmetric; the other is not.** Both trees act linearly on the triple $(a,b,c)$ itself, by $3\times3$ integer matrices. Swapping the two legs, $(a,b,c)\mapsto(b,a,c)$, *permutes* the three Berggren matrices: it exchanges the first and third and fixes the second. It is an honest symmetry of the Berggren tree. Conjugating any Price matrix by the same swap produces a matrix that is *not* a Price matrix — every Price generator has an even first column, and the swap destroys that. Zero out of three. The asymmetry is total.

**They agree on exactly two edges.** If a node has the same parent in both trees via matching moves, the node is $(3,2)$ or $(4,1)$ — the two nodes immediately below the root. Both really occur: $(3,2)$ is Berggren's first child and Price's third child of the root, and $(4,1)$ is Berggren's third and Price's first. Below the second level the trees never agree again. (A breadth-first sweep of nearly half a million nodes confirms exactly two coincidences.)

## The duality of depths — and the death of the idea

If the two trees order the same vertex set in two different ways, perhaps one ordering puts $N$ shallow?

**Price depth is size-driven.** Every Price move at most doubles $m$, so after $d$ steps $m \le 2^{d+1}$. The $N$-node therefore sits at Price depth at least about $\log_2 m$ — and experiment says the depth is about $1.4\log_2(p+q)$ with standard deviation about $2.4$: tight, predictable, logarithmic. Wonderful, except for arithmetic: a tree of depth $d$ has $3^d$ nodes on its bottom level. One can prove that whenever $m \ge 9$, the Price level containing the node already has more than $m$ members — while Fermat's *entire scan* for the same factorization takes at most $m - \lfloor\sqrt N\rfloor \le m$ trial values. Enumerating even one level of the tree is already more work than the classical method, before any search has begun.

**Berggren depth is ratio-driven, and erratic.** A Berggren step either resets the ratio $m/n$ below $3$ or increases it by exactly $2$. Hence after $d$ steps, $m \le (2d+3)\,n$. Depth measures the *ratio* $m/n = (p+q)/(q-p)$, not the size of $N$. And $(p+q)/(q-p)$ is precisely Fermat's ease coordinate: Fermat's scan length is about $(q-p)^2/(8\sqrt N)$, short exactly when the factors are close, that is when the ratio is large. Combining the ratio law with the elementary bound $n^2 \le 2m\,s$ on Fermat's scan length $s$ gives the trade-off in a single inequality:

$$m \;\le\; 2\,s\,(2d+3)^2.$$

Read it the right way and it is devastating. A *cheap* Fermat scan (small $s$) *forces* a large Berggren depth, $d \gtrsim \tfrac12\sqrt{m/s}$ — and depth $d$ means $3^d$ nodes to sift. The two cost measures are inversely coupled. The tree is not a shortcut; it is Fermat's own scan, re-sorted in the worst possible order.

There is an exact, embarrassing illustration. On the line $n=1$, the node $(2k+2,1)$ carries $N=(2k+1)(2k+3)$ — two numbers two apart — and sits at Berggren depth exactly $k$, arbitrarily deep. Fermat's method finds the same factorization at its *first* trial value. The deepest Berggren nodes are the easiest factorizations.

And the two orderings do not rescue each other. The node $(2^{i+2},1)$ sits at Price depth $i+1$ but at Berggren depth exactly $2^{i+1}-1$: exponentially deeper. Measured empirically at 20-bit primes, Berggren depth of the $N$-node averages $78.5$ with a range from $19$ to $1135$; Price depth averages about $25.8$ with tiny spread; the correlation between them is $-0.16$. The correlation between Berggren depth and Fermat's cost is $-0.31$ — negative. In $209$ trials at 20-bit primes, the tree beat Fermat's scan zero times; Fermat averaged $6{,}630$ steps, while the cheapest tree traversal was $3^{19} \approx 1.2\times 10^9$.

## What is actually true here

The Pythagorean trees are not a factoring algorithm, and now we know exactly why, in terms one can state without any hedging:

- The vertex set of both trees is the set of coprime odd factorizations, canonically.
- Every odd semiprime $N=pq$ occupies a unique address in each tree, at the Fermat pair, with odd leg exactly $N$.
- The two descents are inequivalent — determinants $\pm 1$ versus $\pm 2$, leg-symmetric versus not, exactly two shared edges.
- Traversal cost and Fermat cost are *inversely* coupled: $m \le 2s(2d+3)^2$.

The trees organize the ratio $(p+q)/(q-p)$. Factoring needs the product $pq$. Translating between the two *is* the factorization step, and the trees never perform it. They arrange the answers beautifully — sorted by exactly the wrong key.

Which, for a four-thousand-year-old table of numbers, is a rather elegant way to be useless.
