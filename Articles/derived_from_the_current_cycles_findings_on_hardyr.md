# The Geometry of 1729: Lattice Points on a Cubic Curve, and the Numbers That Live There

## A taxi in Putney

The story is famous enough to have become a piece of mathematical folklore. In 1919, G. H. Hardy took a cab to visit the ailing Srinivasa Ramanujan in a nursing home in Putney, and — being Hardy — remarked that the cab's number, $1729$, seemed to him "rather a dull one." Ramanujan replied instantly that it was not dull at all: it was the smallest number expressible as a sum of two cubes in two different ways.

$$1729 = 1^3 + 12^3 = 9^3 + 10^3.$$

What almost nobody says out loud is that this anecdote conceals a *geometry* problem, and a surprisingly deep one. The equation $x^3 + y^3 = N$ is not a piece of arithmetic trivia; it is a **curve**. For each $N$ it traces a smooth arc through the plane, and asking "in how many ways is $N$ a sum of two cubes?" is asking "how many points with whole-number coordinates does this particular curve pass through?"

That reframing is the whole subject. Counting representations becomes counting lattice points on a cubic curve; the difficulty of the problem becomes the difficulty of controlling where a curve happens to cross the integer grid; and the tools that eventually crack it are the tools of algebraic geometry, not of arithmetic. This article is a tour of what can be nailed down rigorously along that road — and of exactly where the elementary road ends.

## The taxicab numbers, and why they are hard to find

Define $r(N)$ to be the number of ways of writing $N$ as $a^3 + b^3$ with $a$ and $b$ positive integers and $a \le b$ (the ordering just prevents us from double-counting $1^3 + 12^3$ and $12^3 + 1^3$). Then define
$$\mathrm{Taxicab}(n) = \text{the least } N \text{ with } r(N) \ge n.$$

Ramanujan's remark is the statement $\mathrm{Taxicab}(2) = 1729$, and it has two halves. The easy half is exhibiting the two representations, which anyone can check. The hard half is **minimality**: no smaller number works. That requires a genuinely exhaustive argument, and the geometry supplies it. If $a^3 + b^3 = N$ with $1 \le a \le b$, then $b^3 \le N$, so $b \le N^{1/3}$. Every candidate representation of a number below $1729$ therefore has both summands at most $12$, because $13^3 = 2197 > 1728$. The infinite search collapses to a $12 \times 12$ grid, and a finite sweep of that grid shows that no value below $1729$ is hit twice. That is the first, and simplest, appearance of a theme that runs through everything below: *the curve traps its own lattice points inside a computable box.*

The known values are staggeringly sparse:

| $n$ | $\mathrm{Taxicab}(n)$ (least known) | approximate size |
|---|---|---|
| 2 | $1729$ | $1.7 \cdot 10^3$ |
| 3 | $87\,539\,319$ | $8.8 \cdot 10^7$ |
| 4 | $6\,963\,472\,309\,248$ | $7.0 \cdot 10^{12}$ |
| 5 | $48\,988\,659\,276\,962\,496$ | $4.9 \cdot 10^{16}$ |
| 6 | $24\,153\,319\,581\,254\,312\,065\,344$ | $2.4 \cdot 10^{22}$ |

For instance $87\,539\,319 = 167^3 + 436^3 = 228^3 + 423^3 = 255^3 + 414^3$, three lattice points on one curve; and $6\,963\,472\,309\,248 = 2421^3 + 19083^3 = 5436^3 + 18948^3 = 10200^3 + 18072^3 = 13322^3 + 16630^3$, four. Each of these is a *witness*: an unconditional certificate that a number with that many representations exists.

## How fast must these numbers grow?

Every witness is a fact about one number. The interesting question is structural: if $N$ has $n$ representations, how big must $N$ be? Remarkably, there is a purely geometric answer, and it comes from a *shell*.

Suppose $N = a^3 + b^3$ with $a \le b$. Then $b^3 \le N$, and also $N = a^3 + b^3 \le 2b^3$. So the larger summand of *every* representation is confined to a thin annulus:
$$\left(\tfrac{N}{2}\right)^{1/3} \le b \le N^{1/3}.$$
The larger summand determines the representation completely (once you know $b$, you know $a^3 = N - b^3$), so $n$ representations means $n$ **distinct integers** inside that shell. If $s$ is the smallest and $m$ the largest, then $m - s \ge n-1$: the shell is at least $n-1$ integers wide. Writing $j = n - 1$ and combining $ (s+j)^3 \le m^3 \le N \le 2s^3$ gives a self-improving squeeze. A first pass yields $s \ge 3j$; feeding that back in yields $5s \ge 19j$; and then $N \ge (s+j)^3 \ge (4.8\,j)^3 > 110\,j^3$. Hence:

> **Growth floor.** If $N$ is a sum of two positive cubes in at least $n$ ways, then $N \ge 110\,(n-1)^3$. In particular $N > n^3$ for all $n \ge 2$.

The constant $110$ is a real improvement over the naive pigeonhole bound $n^3$, and it is obtained by nothing more than iterating one inequality. But iterating it *forever* does not help. The squeeze has a fixed point: setting $s = t j$ and demanding $(t+1)^3 \le 2t^3$ forces $t + 1 \le 2^{1/3} t$, i.e. $t \le 1/(2^{1/3} - 1) = 3.847\ldots$, and the resulting best-possible constant is
$$\left(\frac{2^{1/3}}{2^{1/3}-1}\right)^{3} = 113.8953\ldots$$

So the entire "shell method" — everything you can deduce from the ordering $a \le b$ and positivity alone — saturates at a bound of the form $N \gtrsim 113.90\,(n-1)^3$. It can never yield anything better than cubic growth.

Set that ceiling against the data. For $n = 6$ the method guarantees only $N \ge 13\,750$, while the smallest known witness is $24\,153\,319\,581\,254\,312\,065\,344$. The gap is **eighteen orders of magnitude**. The elementary method is not merely lossy; it is not even in the right complexity class. The truth is almost certainly exponential: $\log \mathrm{Taxicab}(n)/n \to \infty$. And now we know precisely why elementary means cannot reach it — any super-cubic bound must use arithmetic that the shell argument throws away.

## Signs are cheaper: the number 91

Here is where the geometry starts to pay dividends. Suppose we relax the problem and allow the summands to be *negative* integers, so that differences of cubes count too. The least number expressible in two such ways is called $\mathrm{Cabtaxi}(2)$, and it is small:

$$91 = 3^3 + 4^3 = 6^3 - 5^3.$$

And $91$ is minimal: no positive integer below it has two essentially different representations as a sum of two nonzero integer cubes. Compare with $1729$. Allowing one minus sign drops the answer by a factor of nineteen. The next case is just as dramatic:

$$728 = 6^3 + 8^3 = 9^3 - 1^3 = 12^3 - 10^3,$$

and $728$ is the *least* number with three signed representations — while $728$ has only **one** representation as a sum of two positive cubes, namely $6^3 + 8^3$. On a single curve, the positive quadrant sees one lattice point and the full plane sees three. Signs are strictly, quantifiably cheaper.

But there is a subtlety that has to be dealt with before any of this can even be *checked*. In the positive problem, $b^3 \le N$ gave an immediate bound on the search: everything lived in a box. When negative values are allowed, the curve $x^3 + y^3 = N$ has an unbounded branch running off into the second and fourth quadrants — the points where a huge cube is cancelled by another huge cube. Nothing obviously stops $N = 91$ from being $1000000^3 - 999999\ldots^3$ for some monstrous pair. Why is the signed problem finite at all?

The answer is a clean geometric estimate, and it is the technical heart of the signed theory.

> **A priori bound on the signed cubic.** Let $N \ge 1$ and let $x, y$ be nonzero integers with $x^3 + y^3 = N$. Then $x^2 \le N$ and $y^2 \le N$.

The proof is a one-line factorisation once you see it. Suppose $x < 0 < y$ and write $x = -k$ with $k \ge 1$. Then
$$N = y^3 - k^3 = (y - k)\left(y^2 + yk + k^2\right).$$
Since $N > 0$ we must have $y > k$, so the first factor $y - k$ is at least $1$, which forces
$$N \ge y^2 + yk + k^2 \ge \max(y^2, k^2).$$
The unbounded branch is therefore not unbounded at all once $N$ is fixed: the further out along the branch you travel, the more violently the two cubes must cancel, and the difference of consecutive cubes grows quadratically. The escape route is closed. (In the positive quadrant the same conclusion is immediate, since $y^2 \le y^3 \le N$.)

This bound is what makes $\mathrm{Cabtaxi}(2) = 91$ and $\mathrm{Cabtaxi}(3) = 728$ *decidable*: every signed representation of a number below $91$ lies in the square $[-9, 9]^2$, and every signed representation of a number below $728$ lies in $[-26,26]^2$, because $9^2 < 91 \le 10^2$ and $26^2 < 728 \le 27^2$. A finite region, a finite sweep, a theorem.

## What cubes do, and what they do not do

There is one obvious way to manufacture a number with many representations: take one that already has them and scale. If $N = a^3 + b^3$ then $m^3 N = (ma)^3 + (mb)^3$. Multiply $1729$ by $8$ and you get $13832 = 2^3 + 24^3 = 18^3 + 20^3$. So $r(m^3 N) \ge r(N)$ always.

How much does scaling *really* do? Exactly this much, and no more:

> **Structure theorem for cube scaling.** For $m \ge 1$, the representations of $m^3 N$ in which both summands are divisible by $m$ are precisely the $m$-fold multiples of the representations of $N$. The correspondence $(a,b) \mapsto (ma, mb)$ is a bijection onto that subset.

That is a complete description of the "imprimitive" part of the representation set. The scaling map creates nothing; it simply relabels. Every genuine increase in the representation count must come from somewhere else.

It is tempting to go further and conjecture that scaling by a cube changes nothing at all — that every $N$ factors as $m^3 N_0$ with $N_0$ cube-free, and that $r(N) = r(N_0)$, so that the whole theory reduces to cube-free numbers. This is false, and the counterexample is embarrassingly small:
$$344 = 2^3 \cdot 43, \qquad 344 = 1^3 + 7^3, \qquad r(344) = 1, \qquad r(43) = 0.$$
The cube-free core $43$ is not a sum of two positive cubes at all, yet its cube multiple $344$ is — because $1$ and $7$ are not both divisible by $2$, so this representation is *primitive* and lies entirely outside the image of the scaling map. The correct statement is a decomposition rather than an equality: the representations of $m^3N_0$ split into the scaled copies of those of $N_0$ plus a primitive remainder, and the remainder can be nonempty. Cube-free cores control part of the story, never all of it.

## The elliptic curve in the room

If elementary manipulations cannot produce numbers with arbitrarily many representations, what can? Here the geometric picture finally becomes indispensable.

It is a conjecture — widely believed, still open in general — that $\mathrm{Taxicab}(n)$ exists for *every* $n$: that for each $n$ there is some integer expressible as a sum of two positive cubes in at least $n$ ways. The plausible route to it splits cleanly in two.

**Step 1 (geometry).** The curve $x^3 + y^3 = q$ is an elliptic curve in disguise. Elliptic curves come with a group law: given two rational points on the curve, the line through them meets the curve in a third rational point, and the tangent line at a single point meets it again in another. So from *one* rational point one can generate an entire orbit of rational points — infinitely many, provided the starting point has infinite order. Concretely, the tangent line at a rational point $(x,y)$ of $x^3 + y^3 = N$ with $x^3 \neq y^3$ meets the curve again at
$$\left(\frac{x(x^3 + 2y^3)}{x^3 - y^3},\ \frac{-y(2x^3 + y^3)}{x^3 - y^3}\right),$$
which is an exact algebraic identity: substituting these coordinates into $x^3 + y^3$ returns $N$ on the nose. Started from a positive rational point, the construction genuinely moves — the new pair is never the old one, in either coordinate. From $(1,2)$ on $x^3 + y^3 = 9$, for example, it produces $\left(-\tfrac{17}{7}, \tfrac{20}{7}\right)$, and indeed $(-17)^3 + 20^3 = -4913 + 8000 = 3087 = 9 \cdot 343$.

**Step 2 (arithmetic bookkeeping).** Rational points are not integer representations. But they can be converted, and this step is completely elementary and unconditional:

> **Transfer theorem.** Let $q > 0$ be rational and let $S$ be any finite set of rational points $(x,y)$ on $x^3 + y^3 = q$ with nonzero coordinates. Then there is a positive integer $M$ with at least $|S|$ representations as a sum of two nonzero integer cubes. If all the points have positive coordinates, $M$ has at least $|S|$ representations as a sum of two *positive* cubes.

The proof is exactly the schoolchild's trick of clearing denominators, done carefully. Let $D$ be a common denominator for every coordinate of every point in $S$. Multiplying a solution of $x^3 + y^3 = q$ by $D$ produces a solution of $X^3 + Y^3 = D^3 q$ with integer coordinates, and $M = D^3 q$ is the same integer for every point of $S$ because $D$ was chosen once and for all. Distinct rational points stay distinct after scaling by the fixed nonzero factor $D$, so all $|S|$ representations survive. The many rational points collapse onto a single integer, which inherits all of them.

Put the two steps together and the conjecture is *reduced to a single arithmetic input*: the existence of a curve $x^3 + y^3 = q$ carrying infinitely many rational points with positive coordinates. Given that, taking the first $n$ of them and clearing denominators produces, for every $n$, an integer with at least $n$ representations. This is the precise sense in which the taxicab problem is an elliptic-curve problem: the combinatorics is free, the geometry is everything.

Meanwhile, without waiting for the conjecture, the witnesses plus the scaling map already give something unconditional: since $24\,153\,319\,581\,254\,312\,065\,344$ has six representations, so does $m^3$ times it for every $m \ge 1$. Hence there are **infinitely many** integers that are a sum of two positive cubes in at least six ways, and they occur beyond every bound.

## Why any of this matters

Three lessons survive the specifics.

The first is that *finiteness is a theorem, not an assumption*. Almost every computation above — the $12\times12$ sweep for $1729$, the $[-9,9]^2$ sweep for $91$, the $[-26,26]^2$ sweep for $728$ — is possible only because a geometric inequality first proved that the curve cannot hide its solutions far away. The signed bound $x^2 \le N$ is a small result with an outsized role: it converts an unbounded diophantine search into a finite one.

The second is that *knowing where a method stops is as valuable as the method*. The shell bound $N \ge 110(n-1)^3$ is a real theorem; the observation that no refinement of it can beat $113.90$ is arguably more useful, because it tells you not to keep polishing. The eighteen-order-of-magnitude gap at $n = 6$ is a signpost: the answer lies in the height theory of rational points, not in counting integers in an annulus.

The third is that *small counterexamples are worth their weight in gold*. The cube-free-core conjecture is attractive, natural, and killed by $344 = 2^3 \cdot 43$ — a number small enough to check by hand. It survives only in the corrected form, as a decomposition into an imprimitive part (which scaling explains completely) and a primitive part (which it does not).

And behind it all sits the same curve Ramanujan saw in a hospital bed: $x^3 + y^3 = N$, a smooth arc bending through the plane, occasionally, unpredictably, and with beautiful reluctance, touching a point where both coordinates happen to be whole.
