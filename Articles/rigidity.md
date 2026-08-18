# The Symmetry That Cannot Keep a Secret

## Why every nontrivial symmetry group leaves a fingerprint on pairs

Imagine you are handed a perfectly symmetric object — a square tile, a circle of beads, a crystal — and told nothing about it except which of its points can be carried to which. You learn, in other words, its *orbits*: the clusters of points that the symmetry group shuffles among themselves. Two beads are in the same orbit if some symmetry takes one to the other.

Now here is the question that turns out to have a startlingly rigid answer. Suppose you ask the same question about **pairs** of points. Given two pairs $(x,y)$ and $(x',y')$, can a single symmetry carry the first pair to the second — carrying $x$ to $x'$ *and, at the same time,* $y$ to $y'$?

Naively, you might hope that pairs behave like independent coordinates: that $(x,y)$ can be moved to $(x',y')$ exactly when $x$ can be moved to $x'$ and $y$ can be moved to $y'$, each on its own. Call this the *independence hypothesis*. It says the group's behaviour on pairs is nothing more than its behaviour on points, twice over. If it were true, knowing the orbits would tell you everything about the orbits on pairs.

It is essentially never true.

**The Orbital Rigidity Theorem.** *For a group $G$ acting on a set $X$, the orbit of every pair $(x,y)$ under the diagonal action equals the product of the orbit of $x$ with the orbit of $y$ — that is, the independence hypothesis holds — if and only if the action is trivial: every group element fixes every point.*

Not "rarely". Not "only for special groups". *Only when there is no symmetry at all.* The moment a single group element moves a single point, the structure of pairs contains strictly more information than the structure of points. Symmetry cannot keep a secret at level two.

---

## The one-line reason

The proof of the hard direction is so short it fits in a sentence, and it is worth savouring, because the whole subject grows out of it.

Suppose the independence hypothesis holds, and let $g$ be any group element and $x$ any point. Consider the pair $(x,\, g\cdot x)$. Its first coordinate $x$ is certainly in the orbit of $x$; its second coordinate $g \cdot x$ is too. So by independence, the pair $(x, g\cdot x)$ must lie in the orbit of the pair $(x,x)$ — meaning there is a *single* group element $a$ with
$$a \cdot x = x \quad\text{and}\quad a \cdot x = g\cdot x .$$
The first equation says $a$ pins $x$ down. The second says $a$ sends $x$ to $g\cdot x$. Together they force $g \cdot x = x$.

That is the whole argument. The independence hypothesis demands one element to do two incompatible jobs — hold $x$ still and move $x$ to $g\cdot x$ — and the only escape is that there was no motion in the first place. Notice what the argument *doesn't* use: no finiteness, no counting, no assumption that $X$ is a nice space. It works for the rotations of a circle, the symmetries of the integers, the automorphisms of an infinite graph. Rigidity here is not a numerical accident; it is logical.

There is a second, structural way to see the same thing, and it explains *where* independence comes from in general. Consider two possibly different sets $X$ and $Y$ on which $G$ acts.

**Independence Criterion.** *The orbits of $G$ on $X \times Y$ are exactly the products of an orbit in $X$ with an orbit in $Y$ if and only if, for every point $x \in X$, the stabiliser $G_x$ — the subgroup of elements fixing $x$ — is still transitive on every $G$-orbit inside $Y$.*

In words: pairs decouple exactly when pinning down a point in $X$ costs you nothing in $Y$. Independence is a statement that the two sets are dynamically unrelated. Now set $Y = X$ and watch the criterion collapse: the stabiliser $G_x$ fixes $x$, so if it is transitive on the orbit of $x$, that orbit must be the single point $\{x\}$. A set is never independent of itself. Rigidity at pairs is self-independence failing, and it fails for the most elementary reason imaginable.

---

## From "never" to "by how much"

Knowing a phenomenon never happens is only the beginning. The interesting question is *how far* from happening it is — and here the story acquires a probabilistic soul.

Suppose now that $G$ and $X$ are finite. Write $n = |X|$, let $r$ be the number of orbits on $X$, and let $s$ be the number of orbits on $X \times X$ (these are traditionally called **orbitals**). Independence would mean $s = r^2$: each orbital would be one orbit crossed with another. The rigidity theorem says that never happens unless the action is trivial, so we may define the **rigidity defect**
$$\Delta \;=\; s - r^2 ,$$
the excess of orbitals over what independence would predict.

To compute $\Delta$ we need a classical tool. For each group element $g$, let $F(g)$ be the number of points of $X$ that $g$ leaves fixed. Burnside's counting lemma says that the number of orbits is the *average* number of fixed points:
$$r \;=\; \frac{1}{|G|}\sum_{g \in G} F(g).$$
Here is the pretty observation. A pair $(x,y)$ is fixed by $g$ precisely when $x$ and $y$ are separately fixed, so the number of pairs fixed by $g$ is $F(g)^2$. Applying Burnside to $X \times X$,
$$s \;=\; \frac{1}{|G|}\sum_{g \in G} F(g)^2 .$$

So $r$ is the *first moment* and $s$ is the *second moment* of one random variable: the fixed-point count $F$ of a uniformly random group element. And the difference between a second moment and the square of the first moment has a name.

**The Variance Identity.** *For a finite group acting on a finite set,*
$$|G| \cdot (s - r^2) \;=\; \sum_{g \in G} \bigl(F(g) - r\bigr)^2 .$$

**The rigidity defect is exactly the variance of the fixed-point statistic.**

Everything now falls out at once. A variance is never negative, so $s \ge r^2$ always — the orbital count can never fall below the square of the orbit count. And a variance vanishes only when the random variable is constant. If $\Delta = 0$, then every group element fixes exactly $r$ points; but the identity element fixes all $n$ of them, so $r = n$, so every orbit is a single point, so the action is trivial. Rigidity, re-proved in the language of probability. The abstract obstruction of the one-line argument turns out to be a statistical spread.

---

## How big must the defect be?

Once you know the defect is a variance, you can bound it from below by finding elements whose fixed-point count is far from the mean. The identity is the obvious candidate: it fixes all $n$ points, and more generally so does every element of the **kernel** $K$ — the (usually small) set of group elements that act trivially, doing nothing to any point. Each of them contributes $(n-r)^2$ to the variance, and if the action is nontrivial then $r < n$, so each contributes at least $1$. This already gives a bound, and $s > r^2$ once more.

But that bound throws away all the elements *outside* the kernel, and it is never tight. The repair uses a small conservation law: since $r$ is the average of $F$, the deviations $F(g) - r$ must sum to zero over the whole group. The kernel contributes a total deviation of $+|K|(n-r)$, so the remaining $|G| - |K|$ elements must contribute exactly $-|K|(n-r)$ between them. A batch of numbers with a prescribed total cannot all be small in a mean-square sense — that is precisely the Cauchy–Schwarz inequality — and it yields:

**Sharp Quantitative Rigidity.** *For a finite group acting on a finite set, with $K$ the set of elements acting trivially,*
$$|K| \cdot (n - r)^2 \;\le\; \bigl(|G| - |K|\bigr) \cdot \bigl(s - r^2\bigr).$$

This is a genuinely quantitative statement: it says the defect is at least $|K|(n-r)^2 / (|G| - |K|)$, an explicit positive number for every nontrivial action. And unlike the crude version, it is achieved. Which actions achieve it? Exactly the ones you would guess from the Cauchy–Schwarz equality case, and the answer is clean:

**Classification of the Extremal Actions.** *For a nontrivial finite action, equality holds in the sharp bound if and only if every group element outside the kernel fixes the same number of points.*

Groups with this "constant fixity" property are a familiar and beautiful family: regular actions (where only the identity fixes anything), sharply transitive actions, Frobenius groups. For them the fixed-point statistic takes only two values — $n$ on the kernel, some constant $c$ off it — and Cauchy–Schwarz is exact.

A gallery of small examples makes the theory tangible. Below, $F$ lists the fixed-point counts of the group elements.

| action | $n$ | $\lvert G\rvert$ | $F$ | $r$ | $s$ | $s-r^2$ | $\lvert K\rvert(n-r)^2$ | $(\lvert G\rvert-\lvert K\rvert)(s-r^2)$ |
|---|---|---|---|---|---|---|---|---|
| trivial on 3 points | 3 | 1 | $[3]$ | 3 | 9 | 0 | 0 | 0 |
| a swap of 2 points | 2 | 2 | $[2,0]$ | 1 | 2 | 1 | 1 | **1** |
| one transposition on 3 points | 3 | 2 | $[3,1]$ | 2 | 5 | 1 | 1 | **1** |
| rotation of a triangle | 3 | 3 | $[3,0,0]$ | 1 | 3 | 2 | 4 | **4** |
| all symmetries of 3 points | 3 | 6 | $[3,1,1,1,0,0]$ | 1 | 2 | 1 | 4 | 5 |
| the four-group on 4 points | 4 | 4 | $[4,0,0,0]$ | 1 | 4 | 3 | 9 | **9** |
| symmetries of the square | 4 | 8 | $[4,0,0,0,0,0,2,2]$ | 1 | 3 | 2 | 9 | 14 |
| rotation of a pentagon | 5 | 5 | $[5,0,0,0,0]$ | 1 | 5 | 4 | 16 | **16** |
| a 3-cycle on 5 points | 5 | 3 | $[5,2,2]$ | 3 | 11 | 2 | 4 | **4** |

The bold entries mark equality — and, exactly as the classification predicts, they are precisely the rows whose non-identity elements all fix the same number of points. The full symmetry group of three points has fixed-point vector $[3,1,1,1,0,0]$: two different values off the kernel, and the bound is strict ($4 < 5$). The square's symmetry group has $[4,0,0,0,0,0,2,2]$: again two values, again strict ($9 < 14$).

The last row of the table above deserves a second glance, and so does one further example: the four-group acting on six points, generated by the double transposition of the first two pairs and of the last two pairs. Its three non-identity elements fix *three different pairs of points* — different fixed sets entirely — but each fixes exactly two points, and equality holds. The extremal class is about the *size* of fixed sets, not their identity. That is a genuinely subtler condition than "all the non-identity elements look alike".

---

## What the defect is *not* controlled by

A natural guess is that a bigger set forces a bigger defect: surely acting on a million points must leave more of a fingerprint than acting on two? It does not. Take the group of order two acting on $n$ points by a single transposition, swapping two of them and fixing the rest. Then $r = n-1$, and a short count gives $s = (n-1)^2 + 1$, so the defect is
$$\Delta = 1 \qquad \text{for every } n.$$

The defect is stubbornly $1$ whether $n$ is $2$ or $2$ million. No lower bound of the form $\Delta \ge c\,n$ with $c > 0$ can hold. What *does* control the defect is the ratio $|K|(n-r)^2 / (|G| - |K|)$ from the sharp bound — a quantity blind to the size of $X$ except through the orbit deficiency $n - r$, which for the single transposition is only $1$. The theory does not merely prove an inequality; it identifies the right variable.

---

## Climbing the tower: triples, quadruples, and beyond

Pairs were only the ground floor. Let $s_k$ denote the number of orbits of $G$ on the set $X^k$ of $k$-tuples, so $s_1 = r$ and $s_2 = s$. Independence at level $k$ would say $s_k = r^k$.

Burnside gives $s_k = \frac{1}{|G|}\sum_g F(g)^k$ — the $k$-th moment of the same statistic. Moments of a nonnegative random variable are not free to do as they please: larger powers of $F$ are large exactly where $F$ itself is large, so the functions $F^k$ and $F$ *monovary*, and Chebyshev's sum inequality applies. It gives
$$\Bigl(\sum_g F(g)^k\Bigr)\Bigl(\sum_g F(g)\Bigr) \;\le\; |G| \sum_g F(g)^{k+1},$$
which, translated through Burnside, is the elegant growth law
$$s_{k+1} \;\ge\; s_k \cdot r .$$
Orbit counts on powers grow at least geometrically, with ratio the orbit count itself. Combining this chain with the strict inequality $s_2 > r^2$ already established at the ground floor and running up the tower:

**Rigidity at Every Arity.** *For a finite group acting on a finite set and any $k \ge 2$, the number of orbits on $k$-tuples equals $r^k$ if and only if the action is trivial; otherwise $s_k > r^k$ strictly.*

Once symmetry breaks the independence of pairs, it breaks it at every level above, and the gap only widens. The numbers make the widening vivid: for the rotation group of a pentagon acting on its five vertices, $r = 1$ and the orbit counts on tuples run $1, 5, 25, 125$ against a predicted $1, 1, 1, 1$. For the three-cycle acting on five points, $r = 3$ and one finds $9, 27, 81$ predicted against $11, 47, 219$ actual.

---

## Why this matters

There is a classical slogan in the theory of permutation groups: *a group is known by its action on tuples*. The number of orbits on $k$-tuples is called the $k$-th **rank** (for $k = 2$, literally *the* rank of a transitive group), and it is one of the most informative invariants a permutation group has. Rank $2$ means 2-transitivity — the group can carry any ordered pair of distinct points to any other — a condition strong enough that the finite groups satisfying it have been completely classified. Orbitals are also exactly the edge sets of the *orbital graphs* whose study underpins coherent configurations, association schemes, and the modern approach to the graph-isomorphism problem.

What the rigidity theorem contributes to that picture is a clean logical statement about the *bottom* of the hierarchy: level two is never redundant. You can never reconstruct the pair structure from the point structure, and the extent of the failure is a variance — a single, computable number carrying information about the kernel, the orbit deficiency, and the spread of fixed-point counts across the group.

The three proofs of the same theorem are, in a way, the real payload. The first is pure logic: one element cannot both hold a point and move it. The second is probability: a variance vanishes only for a constant random variable. The third is structural: a set is not independent of itself, because pinning a point down always costs you something. Each generalises in a different direction — the first to infinite groups and arbitrary sets, the second to sharp quantitative bounds and a classification of extremal cases, the third to a criterion for when two *different* sets do decouple.

And the third is the one that points forward. The independence criterion says orbits on $X \times Y$ factor precisely when every stabiliser $G_x$ remains transitive on every $G$-orbit of $Y$. Take $Y = X$ and this is the statement that orbitals of $G$ are suborbits of the stabiliser: orbital counting is stabiliser counting one level down. That recursion is where the subject goes next — toward a quantitative theory of 2-transitivity in which the rank of a group is bounded in terms of the largest suborbit, and in which the whole tower of tuple-orbit counts becomes a recursive descent through the stabiliser chain.

For now, the moral stands, and it is a pleasingly absolute one. **Symmetry is never invisible at the level of pairs.** The instant a group does anything at all, the pairs know.
