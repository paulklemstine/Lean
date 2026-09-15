# The Congruent Number Laboratory

## A thousand-year-old puzzle, hiding inside an infinite tree of triangles

In the year 1225, at a mathematical tournament in Pisa held before the Emperor Frederick II, Leonardo of Pisa — Fibonacci — was handed a challenge problem: find a rational number $x$ such that $x^2 + 5$ and $x^2 - 5$ are both squares of rational numbers. He found one:

$$x = \frac{41}{12}, \qquad x^2 - 5 = \left(\frac{31}{12}\right)^2, \qquad x^2 + 5 = \left(\frac{49}{12}\right)^2.$$

Behind that piece of virtuosity is a question that is still open eight centuries later. Fibonacci's solution is equivalent to the statement that there is a right triangle with rational sides

$$\frac{3}{2}, \qquad \frac{20}{3}, \qquad \frac{41}{6}$$

whose area is exactly $5$. A whole number that arises as the area of some right triangle with rational side lengths is called a **congruent number**. The number $5$ is congruent. So is $6$, the area of the familiar $3$–$4$–$5$ triangle. So is $7$, though the smallest triangle witnessing it has sides $\tfrac{35}{12}, \tfrac{24}{5}, \tfrac{337}{60}$. But $1$, $2$ and $3$ are *not* congruent — no rational right triangle whatsoever has area $1$, a fact Fermat proved with the argument he was proudest of.

The **congruent number problem** asks for a rule: given $n$, decide whether it is congruent. There is a conjectural answer, but no proof, and a proof would settle a Millennium Prize Problem. This article is about a new way to look at the problem: not through the elliptic curves that dominate the modern approach, but through an infinite family tree of triangles, in which — as we shall see — *every congruent number is literally visible*.

---

## The tree of all right triangles

Start with the $3$–$4$–$5$ triangle. There is a remarkable fact, discovered by Barning in 1963 and rediscovered by Hall in 1970: every Pythagorean triple $(a,b,c)$ with $a^2+b^2=c^2$, $a,b,c>0$ and $\gcd(a,b)=1$ — a *primitive* triple — can be reached from $(3,4,5)$ by repeatedly applying three fixed integer matrices, and reached in exactly one way. The primitive triples form an infinite ternary tree with $(3,4,5)$ at the root: three children, nine grandchildren, twenty-seven great-grandchildren, forever, with nothing repeated and nothing omitted.

The tree is most transparent in Euclid's coordinates. Every primitive triple is
$$(a,b,c) = (m^2-n^2,\ 2mn,\ m^2+n^2)$$
for a unique pair of integers $m>n>0$ that are coprime and of opposite parity — we call such a pair an **admissible seed**. The root seed is $(m,n)=(2,1)$, giving $(3,4,5)$. In these coordinates the three branching moves are beautifully simple:

$$A:(m,n)\mapsto(2m-n,\ m),\qquad B:(m,n)\mapsto(2m+n,\ m),\qquad C:(m,n)\mapsto(m+2n,\ n).$$

Every admissible seed is obtained from $(2,1)$ by a unique finite word in $A$, $B$, $C$. The tree is complete and non-redundant: it is an *enumeration* of the right triangles with whole-number sides.

Now attach to every node the one quantity the congruent number problem cares about — its **area**. In Euclid coordinates the area of the triangle with legs $m^2-n^2$ and $2mn$ is

$$\mathcal{A}(m,n) \;=\; \tfrac12 (m^2-n^2)(2mn) \;=\; mn(m^2-n^2) \;=\; mn(m-n)(m+n).$$

The root has $\mathcal{A}(2,1)=6$. Its neighbours have $\mathcal{A}(3,2)=30$, $\mathcal{A}(5,2)=210$, $\mathcal{A}(4,1)=60$. Notice that all of them are divisible by $6$ — and that is no accident. Among the four factors $m$, $n$, $m-n$, $m+n$, one is always even and one is always divisible by $3$, so:

> **Theorem (the area of every node is a multiple of six).** For all integers $m,n$, the quantity $mn(m^2-n^2)$ is divisible by $6$.

## The bridge

Areas of integer triangles are integers; congruent numbers are areas of *rational* triangles. What connects them is a simple scaling observation. If a right triangle has area $N$, then scaling all three sides by a rational factor $t$ gives a right triangle of area $Nt^2$. Consequently:

> **Theorem (square-class invariance).** For any rational $N$ and any nonzero rational $t$, the number $N$ is congruent if and only if $Nt^2$ is congruent.

So being congruent depends only on a number's *squarefree part* — the number left after deleting every square factor. This is the hinge on which everything turns, because it lets a rational triangle of area $5$ be traded for an integer triangle of area $5k^2$: indeed, Fibonacci's triangle $\left(\tfrac32,\tfrac{20}{3},\tfrac{41}{6}\right)$ of area $5$ scales by $6$ to the integer triangle $(9,40,41)$ of area $180=5\cdot 6^2$ — which is exactly the node with seed $(m,n)=(5,4)$.

That example is the general theorem in miniature. The main result of this work is:

> **Main Theorem (the tree sees every congruent number).** Let $s$ be a squarefree positive integer. Then $s$ is a congruent number if and only if some node of the tree of primitive Pythagorean triples has area $s k^2$ for some positive integer $k$. Equivalently: **the congruent numbers are exactly the squarefree parts of the areas of the nodes of the tree.**

One direction is the easy one: a node is a genuine right triangle, so its area is congruent, and by square-class invariance so is its squarefree part. The other direction is a descent. Suppose a rational triangle has area $s$. Clear denominators — multiply the sides by their common denominator $D$ — to get an integer triangle of area $sD^2$. Then divide the three sides by their greatest common divisor $g$; the triangle becomes primitive and the area becomes $sD^2/g^2$, which need not be an integer times a square *a priori*. This is where squarefreeness does its work: if $Ag^2=sd^2$ with $s$ squarefree, then $A$ must itself be $s$ times a square. (Every prime dividing $s$ appears to an odd power on the right and hence in $A$; all remaining primes are matched off in pairs.) So the primitive triangle has area exactly $sk^2$ — and every primitive triangle is a node of the tree.

Stated in the round, the theorem says something striking. The congruent number problem, usually presented as a question about rational numbers with unbounded denominators, is *entirely contained in a single, completely explicit, non-redundant combinatorial object*. You do not have to search over rational triangles. You only have to look at the numbers $mn(m-n)(m+n)$.

## The same data, on an elliptic curve

Modern work on congruent numbers passes through the curve

$$E_s:\quad y^2 = x^3 - s^2 x .$$

The link is a pair of explicit substitutions. Given a rational right triangle with legs $a,b$, hypotenuse $c$ and area $s$, the point
$$\left(x,y\right)=\left(\frac{a(a+c)}{2},\ \frac{a^2(a+c)}{2}\right)$$
lies on $E_s$ with $x>0$ and $y>0$. Conversely, from a rational point with $x>0$, $y\neq 0$ one recovers the triangle
$$\left(\frac{x^2-s^2}{y},\ \frac{2sx}{y},\ \frac{x^2+s^2}{y}\right),$$
whose sides are positive (the curve equation forces $x>s$) and whose area is again $s$. So:

> **Theorem (the three-way equivalence).** For a squarefree positive integer $s$, the following are equivalent: (i) $s$ is a congruent number; (ii) some node of the tree has area $s$ times a perfect square; (iii) the curve $y^2=x^3-s^2x$ has a rational point with $x>0$ and $y\neq 0$.

Condition (iii) is the reason the problem is hard: such a point exists precisely when $E_s$ has positive rank, and the rank is governed by the Birch–Swinnerton-Dyer conjecture. Tunnell's celebrated theorem of 1983 gives a fast, finite test for congruence — counting solutions of $2x^2+y^2+8z^2=n$ and friends — but its *sufficiency* rests on BSD. The equivalence above says that the tree is not a shortcut around this difficulty; it is a faithful, fully explicit mirror of it. Every rational point of every congruent number curve is a node of one tree.

## What the tree can prove on its own

The mirror is useful because the tree comes with its own descent. Classical descent arguments move from one triangle to a smaller triangle; inside the tree, "smaller" is literal — the descent produces a node closer to the root, and a tree has no infinite descending path.

The first law of the laboratory is Fermat's:

> **Theorem (no node has square area).** For every admissible seed $m>n>0$, the number $mn(m^2-n^2)$ is never a perfect square. Consequently $1$ is not a congruent number, and neither is any perfect square.

The proof runs entirely in Euclid coordinates. The four factors $m$, $n$, $m-n$, $m+n$ are pairwise coprime, so if their product is a square then each is a square: $m=a^2$, $n=b^2$, $m-n=c^2$, $m+n=d^2$. Since $m,n$ have opposite parity, $c$ and $d$ are odd, so $u=(d+c)/2$ and $v=(d-c)/2$ are coprime positive integers with
$$u^2+v^2=a^2,\qquad 2uv=b^2 .$$
The first says $(u,v,a)$ is itself a primitive Pythagorean triple — another node of the tree! The second, combined with coprimality, forces the even leg to be twice a square and the odd leg to be a square, and unwinding that node's own Euclid parameters $(p,q)$ produces $pq(p^2-q^2)$ equal to a square once more, with $p<a\le\sqrt{m}<m$. The seed has strictly shrunk. Iterate, and the parameter $m$ falls forever — impossible. Fermat's theorem becomes a statement about the *geometry of the tree*: the area function never lands on a square, and the reason is that a square area would let you climb down the tree forever.

The same machinery, run with one prime carried along, gives the second and third laws:

> **Theorem.** No node has area twice a perfect square; hence $2$ is not a congruent number, and neither is $2t^2$ for any nonzero rational $t$.

> **Theorem (Genocchi's theorem, tree form).** If $p$ is a prime with $p\equiv 3\pmod 8$, then no node of the tree has area $pk^2$. Hence no such prime is a congruent number: $3$, $11$, $19$, $43$, $59$, $67, \dots$ are all non-congruent, unconditionally.

For the last one the analysis is a case split rather than a single descent. In a node of area $pk^2$, the prime $p$ divides exactly one of the four coprime factors $m$, $n$, $m-n$, $m+n$; the other three are then perfect squares. That gives four "shapes". Three of them die immediately modulo $8$ — for instance, if $m-n=pc^2$ with $p\equiv3$, one finds a sum of two odd squares forced to be $\equiv 3 \pmod 8$, which is impossible since odd squares are $1 \bmod 8$. The surviving shape, $m=a^2$, $n=pb^2$, descends exactly as in Fermat's argument to a strictly smaller node whose area is again $p$ times a square, and the tree's finite depth finishes the proof. This is a genuinely infinite family of non-congruent numbers, proved without any appeal to the unproven parts of the theory.

## The shape of the area function

If the tree is to be a laboratory, we need to know how areas are distributed in it. Three structural facts do most of the work.

**Areas grow along every branch.** Each of the three moves strictly increases the area, and the identities that show it are exact:
$$\mathcal{A}(2m-n,m) = \mathcal{A}(m,n) + 6m^2(m-n)^2,\qquad \mathcal{A}(m+2n,n) = \mathcal{A}(m,n) + 6n^2(m+n)^2,$$
$$\mathcal{A}(2m+n,m) = 6\,\mathcal{A}(m,n) + m(m+n)\left(6m^2-mn+7n^2\right).$$
The third is the strongest: the middle branch multiplies the area by *more than six* at every step.

**The middle spine obeys a silver law.** Follow the middle branch forever from the root: the seeds are $(2,1),(5,2),(12,5),(29,12),(70,29),\dots$ — consecutive Pell numbers, the sequence whose growth rate is the silver ratio $1+\sqrt2$. They satisfy the Pell identity $m^2-2mn-n^2=(-1)^{d+1}$ at depth $d$, and substituting it into the area formula collapses the area to a single variable: with $t_d=m_dn_d$,
$$\mathcal{A}_d = 2t_d^{\,2} + (-1)^{d+1} t_d .$$
So $\mathcal{A}_0=2\cdot 4-2=6$, $\mathcal{A}_1=2\cdot 100+10=210$, $\mathcal{A}_2=2\cdot 3600-60=7140$, $\mathcal{A}_3=2\cdot 121{,}104+348=242{,}556$. The spine areas are near-perfect doubled squares, off by exactly their own square root, alternating in sign — the arithmetic shadow of the silver ratio. And they grow at least like $6^{d+1}$.

**The area function is proper.** Every node satisfies $\mathcal{A}(m,n)>m^2$, so a node of area at most $X$ has $m\le \sqrt X$ and $n<m$: only finitely many nodes have area below any bound. This is what makes the tree a *computable* model. To find every congruent number produced with a witness of area $\le X$, you enumerate a finite region of the tree — you never have to guess a denominator.

Here is the laboratory in action, reading squarefree parts off small nodes:

| seed $(m,n)$ | triple | area | squarefree part |
|---|---|---|---|
| $(2,1)$ | $(3,4,5)$ | $6$ | $\mathbf{6}$ |
| $(3,2)$ | $(5,12,13)$ | $30$ | $\mathbf{30}$ |
| $(4,1)$ | $(15,8,17)$ | $60$ | $\mathbf{15}$ |
| $(4,3)$ | $(7,24,25)$ | $84$ | $\mathbf{21}$ |
| $(5,2)$ | $(21,20,29)$ | $210$ | $\mathbf{210}$ |
| $(5,4)$ | $(9,40,41)$ | $180$ | $\mathbf{5}$ |
| $(8,1)$ | $(63,16,65)$ | $504$ | $\mathbf{14}$ |
| $(9,8)$ | $(17,144,145)$ | $1224$ | $\mathbf{34}$ |
| $(16,9)$ | $(175,288,337)$ | $25200$ | $\mathbf{7}$ |

Each right-hand entry is a theorem: $5$, $6$, $7$, $14$, $15$, $21$, $30$, $34$ and $210$ are congruent numbers, each certified by one explicit triangle. Fibonacci's $5$ appears at depth three; the notorious $7$ requires the seed $(16,9)$, and the smallest seed witnessing $157$ — Zagier's famous example whose simplest triangle has a $45$-digit numerator — lies unimaginably deeper. That gap between a number's size and the depth at which the tree first displays it is precisely the difficulty of the congruent number problem, rendered as a combinatorial statistic.

## Why this is a laboratory and not a solution

It would be dishonest to claim the tree cracks the problem. What it does is change its texture. Three things become available that were not before.

**Everything is explicit.** There is no search over rational numbers, no unknown denominators, no reliance on heights. The congruent numbers are precisely the values of the polynomial $mn(m-n)(m+n)$, read modulo squares, on a set of seeds that a tree enumerates exactly once each.

**Descent is native.** In the tree, "infinite descent" is just "no infinite path towards the root". Fermat's theorem, the non-congruence of $2$, and Genocchi's infinite family all become finite case analyses plus a depth argument — and the case analyses are purely local, depending only on residues modulo $8$ and on which of the four coprime factors a prime lands in. That locality is a promise: the same template, with a squarefree modulus in place of a prime, should generate a *table* of descent-provable non-congruent classes.

**Statistics become well-posed.** Because the area function is proper and grows at a controlled rate — at least $6\times$ per middle step, quadratically in the other two directions — questions like "how many distinct squarefree parts appear among nodes of depth $\le d$?" are finite, computable questions. The conjectural density of congruent numbers (all $n \equiv 5,6,7 \pmod 8$ should be congruent, and about half of each other admissible class) turns into a question about how often the polynomial $mn(m-n)(m+n)$ revisits a square class as you walk the tree. Repetition on the tree side is exactly rank on the curve side: two nodes with the same squarefree part are two independent triangles of the same area, and hence a point of infinite order producing another.

There is a real possibility that the answer is negative in an interesting way: that the squarefree parts of node areas are equidistributed with no exploitable pattern. That would itself be a sharp theorem — a precise statement of *why* the triangle side of the problem cannot, on its own, see the elliptic-curve side. Either way, the object being studied is now completely pinned down.

## Coda

What makes the congruent number problem so durable is that it is elementary enough for Fibonacci and deep enough for the Clay Institute. The tree of Pythagorean triples is likewise elementary enough to draw on a napkin — three matrices, one root, no repeats — and it turns out to carry, in a single polynomial attached to its nodes, the entire content of the problem. Fermat's descent, Genocchi's congruence condition, the elliptic curve $y^2=x^3-s^2x$, the Pell numbers and the silver ratio all show up in the same picture, each as a statement about how a number moves when you walk from one triangle to its children.

Eight hundred years after Pisa, we still cannot say which numbers are congruent. But we can now say exactly where to look.
