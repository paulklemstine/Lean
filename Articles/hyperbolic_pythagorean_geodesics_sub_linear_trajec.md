# The Tree of Right Triangles, Drawn on a Hyperbolic Disk

## A shape you already know, in a geometry you don't

Every schoolchild meets $3^2 + 4^2 = 5^2$. Fewer people learn the astonishing fact that *all* right triangles with whole-number sides — infinitely many of them — are the descendants of that single triangle, arranged in a perfect family tree.

The rule is simple enough to write on a napkin. Take a primitive Pythagorean triple $(a,b,c)$ — three coprime whole numbers with $a^2+b^2=c^2$ — and apply any of three fixed $3\times 3$ integer matrices to it. Out comes another primitive triple. Start at $(3,4,5)$, apply the three matrices, apply them again to each result, and keep going. You get an infinite ternary tree, and — this is the miracle, discovered by B. Berggren in 1934 and rediscovered several times since — **every** primitive Pythagorean triple appears in it, exactly once. Nothing is missed; nothing is repeated.

$$(3,4,5) \to (5,12,13),\ (21,20,29),\ (15,8,17) \to \cdots$$

This article is about what happens when you stop thinking of that tree as a combinatorial object and start thinking of it as a *geometric* one — specifically, when you draw it inside the hyperbolic plane, the strange saddle-shaped world where parallel lines diverge and circles have more area than they ought to. The result is a dictionary in which arithmetic questions about Pythagorean triples become questions about distance, and where a seductive-looking plan for factoring large integers turns out to be exactly, provably, doomed — for a reason that is itself beautiful.

## From triangles to points

The first step is a change of coordinates that goes back to Euclid. Every primitive Pythagorean triple can be written

$$(a,b,c) = (m^2-n^2,\; 2mn,\; m^2+n^2)$$

for a unique pair of whole numbers $(m,n)$ with $0 < n < m$, $\gcd(m,n)=1$, and $m+n$ odd. Call such a pair a **seed**. The triple $(3,4,5)$ has seed $(2,1)$; the triple $(5,12,13)$ has seed $(3,2)$; $(65 = 63^2 + 16^2$'s two friends$)$ have seeds $(8,1)$ and $(7,4)$.

In seed coordinates the three Berggren matrices simplify beautifully. They become

$$B_1:(m,n)\mapsto(2m-n,\,m),\qquad B_2:(m,n)\mapsto(2m+n,\,m),\qquad B_3:(m,n)\mapsto(m+2n,\,n).$$

Three affine maps on a pair of integers. That is the entire tree.

Now for the geometry. The **Poincaré upper half-plane** $\mathbb{H}$ is the set of complex numbers with positive imaginary part, equipped with the metric $ds = |dz|/\operatorname{Im} z$ — lengths get magnified as you approach the real axis, so the boundary is infinitely far away. It is the standard playground for hyperbolic geometry, and it is where the modular group $\mathrm{SL}_2(\mathbb{Z})$ lives.

Send each seed $(m,n)$ to the point

$$z(m,n) \;=\; \frac{n+i}{m} \;=\; \frac{n}{m} + \frac{i}{m}.$$

The real part is the *slope* $n/m$ of the seed, a number in $(0,1)$; the imaginary part is $1/m$, so bigger seeds sit closer to the real line. Take the imaginary unit $i$ as the origin of the picture.

## The distance formula, and a small miracle

How far is a node from the origin? The hyperbolic distance in $\mathbb{H}$ obeys

$$\cosh d(z,w) = 1 + \frac{|z-w|^2}{2\,\operatorname{Im}z\,\operatorname{Im}w}.$$

Plug in $z=i$ and $w = (n+i)/m$, turn the crank, and something remarkable falls out:

> **Exact Distance Formula.** For every seed $(m,n)$,
> $$\cosh d_{\mathbb H}\big(i,\, z(m,n)\big) \;=\; \frac{m^2+n^2+1}{2m}.$$

Look at the numerator. It is $c+1$, where $c=m^2+n^2$ is the **hypotenuse** of the Pythagorean triple. The geometry has no business knowing about the hypotenuse — we defined $z(m,n)$ using $n/m$ and $1/m$, not $m^2+n^2$ — but there it is, sitting in the numerator of a hyperbolic cosine. This one identity is the hinge on which everything else turns.

Because $\cosh d \approx \tfrac12 e^{d}$ for large $d$, and because $(c+1)/(2m)$ is comparable to $\sqrt{c}$ (the seed conditions force $m$ to be within a bounded factor of $\sqrt c$), the formula immediately gives:

> **Logarithmic Trajectory Theorem.** For every seed with hypotenuse $c$,
> $$\tfrac12 \log c \;\le\; d_{\mathbb H}\big(i,\, z(m,n)\big) \;\le\; \tfrac12\log\big(2(c+1)\big).$$

In words: *every* node of the tree, however deep, sits at hyperbolic distance $\tfrac12\log c + O(1)$ from the origin. The lower bound is exact — no additive slack at all. The upper bound exceeds it by less than $\tfrac12\log 2 \approx 0.3466$, plus a term of size $1/(2c)$ that vanishes.

So the entire infinite, exponentially branching tree of Pythagorean triples is compressed into a thin logarithmic filament. A triple with a hundred-digit hypotenuse is only about $115$ units of hyperbolic distance from $(3,4,5)$.

## The residual: reading the slope off the geometry

Since the distance is $\tfrac12\log c$ plus a bounded correction, the interesting quantity is the correction itself. Define the **residual**

$$\rho(m,n) \;=\; d_{\mathbb H}\big(i,z(m,n)\big) - \tfrac12\log c.$$

The theorem above says $0 \le \rho < \tfrac12\log 2 + o(1)$. What is it *really*?

The answer is startlingly clean. Set $t = n/m$, the slope. Then

> **Slope Model.** $\rho(m,n) = \tfrac12\log(1+t^2) + \text{(a tiny error)}$, and the error is nonnegative and at most $n^2/\big(c(c-1)\big)$.

That is, the residual depends only on the *shape* of the triangle, not its size — up to an error of order $1/c$, the reciprocal of the hypotenuse. And $t\mapsto \tfrac12\log(1+t^2)$ maps $(0,1)$ onto $(0,\tfrac12\log 2)$, which is exactly the window the trajectory theorem predicted. The window is not an artifact of crude estimation; it is the exact image of the slope interval.

One can go further and write down the error *exactly*. With $S = \sqrt{(c+1)^2-4m^2}$ (which is $2m\sinh d$),

$$\exp\!\Big(\rho(m,n) - \tfrac12\log(1+t^2)\Big) \;=\; \frac{(c+1)+S}{2c}.$$

The gap between the true residual and the slope model is therefore the logarithm of a quantity extremely close to $1$, and the whole difficulty is the near-cancellation in $S - (c-1)$. The trick that dissolves it is a one-line factorization:

$$\big(S-(c-1)\big)\big(S+(c-1)\big) = S^2-(c-1)^2 = (c+1)^2-4m^2-(c-1)^2 = 4(c-m^2) = 4n^2.$$

A difference of nearly equal quantities has become a *quotient*, and since $2(c-1)\le S+(c-1)\le 2c$, the gap is pinned between $n^2/c^2$ and $n^2/\big(c(c-1)\big)$ — two bounds within a factor $(c+1)/(c-1)$ of each other. At the seed $(4,1)$, for example, this gives $0.003448 \le \text{gap} \le 0.003676$, bracketing the true value $0.0036555\ldots$ to three digits.

## Which way does each branch move you?

Now a natural dynamical question. Each of the three Berggren moves takes a node to a child. Does the child sit *closer* to the ideal $\tfrac12\log c$, or further? Equivalently: does the residual go up or down along $B_1$, $B_2$, $B_3$?

For the slope model the answer is easy algebra. $B_1$ sends the slope $t$ to $1/(2-t)$, and $(m-n)^2\ge0$ forces $t \le 1/(2-t)$: the slope increases, so the residual increases. $B_3$ sends $t$ to $t/(1+2t) \le t$: the residual decreases. And $B_2$ sends $t$ to $1/(2+t)$, which is larger or smaller than $t$ depending on which side of $\sqrt2 - 1 = 0.41421\ldots$ the slope sits.

But the slope model is only accurate to $O(1/c)$ — and the differences we are comparing are themselves $O(1/c)$ or smaller in some regimes. Does the monotonicity survive the error term? This is the boundary-layer question, and it is where the real work lies. The answers:

> **Branch Monotonicity.** For every seed $(m,n)$, the *exact* hyperbolic residual satisfies
> $$\rho(m,n) \le \rho(2m-n,\,m) \qquad\text{(the } B_1 \text{ branch always increases it)},$$
> $$\rho(m+2n,\,n) \le \rho(m,n) \qquad\text{(the } B_3 \text{ branch always decreases it)},$$
> with no side conditions whatsoever.

> **The $B_2$ Dichotomy.** For every seed, $\rho(2m+n,\,m) \le \rho(m,n)$ if $m^2 < 2mn+n^2$ (slope above $\sqrt2-1$), and $\rho(m,n) \le \rho(2m+n,\,m)$ if $m^2 > 2mn+n^2$. No seed satisfies $m^2 = 2mn+n^2$ — coprimality forbids it — so every seed falls strictly on one side. **The exact residual always moves in exactly the direction the slope model predicts.**

The proof strategy is a pleasant piece of engineering. One bounds the slope-model difference from *below* by an elementary rational function, using only $\log x \ge 1 - 1/x$; then one bounds the residual-versus-slope-model error from *above* by the sharp estimate; then one checks that the first beats the second. For $B_1$ and $B_3$ the resulting polynomial inequalities become *coefficient-positive* after the substitution $n = a+1$, $m = a+b+2$ (which encodes $0<n<m$), which is what makes the guard-free statements possible.

The $B_2$ case has a genuine hard core. The argument covers everything except the seeds with $m^2 = 2mn + n^2 + 1$ — that is, $(m-n)^2 = 2n^2+1$, a **Pell equation**, whose solutions are $(m,n) = (5,2), (29,12), (169,70), \ldots$. On this thin family the whole question collapses, after substituting the Pell relation, to the single polynomial inequality
$$mn\big(28n^4-96n^2-34\big) + \big(12n^6-30n^4-50n^2-8\big) \;\ge\; 0,$$
whose two brackets turn non-negative *exactly* at $n=2$. Read over the real numbers this is false — it fails near $(m,n)=(3.8,1.48)$ — so the proof must use arithmetic: the Pell equation itself forces $n\ge2$, because $n=1$ would need $m^2=2m+2$. At the smallest member $(5,2)$ the two sides are $42250$ and $42630$, a margin of nine parts in a thousand. The boundary layer is real, and it is closed.

## The factoring dream, and why it fails

Here is why anyone would care beyond aesthetics. Euler's method of factoring rests on a classical observation: if an odd number $N$ has *two essentially different* representations as a sum of two squares, $N = a^2+b^2 = c^2+d^2$, then $N$ is composite and you can read off its factors:

$$\gcd(N,\, ac+bd)\cdot\gcd(N,\, ad+bc) = N,$$

with both factors strictly between $1$ and $N$. Try $65 = 8^2+1^2 = 7^2+4^2$: $\gcd(65, 8\cdot7+1\cdot4) = \gcd(65,60) = 5$ and $\gcd(65, 8\cdot4+1\cdot7) = \gcd(65,39) = 13$. Out pops $65 = 5\cdot 13$. If $N=pq$ is a semiprime, this always recovers exactly $p$ and $q$: one collision, complete factorization.

And *collisions in the tree are exactly such pairs*. Two distinct nodes of the Berggren tree with the same hypotenuse $N$ give two primitive representations of $N$ as a sum of squares, hence a full splitting. Collisions are not rare, either: the two seed families $(20j+9,\,10j+2)$ and $(20j+7,\,10j+6)$ both have hypotenuse $500j^2+400j+85$ for every $j$, so collisions occur at every scale. (For $j=0$ these are $(9,2)$ and $(7,6)$, both with hypotenuse $85$, and the extracted divisor is $5$.)

So the plan writes itself. Colliding nodes lie at *nearly the same hyperbolic distance* from the origin — within $2\log 2$ of each other, since both distances are $\tfrac12\log N + O(1)$. Every node is only $\tfrac12\log N$ away. Walk out along a short geodesic to radius $\tfrac12\log N$, minimize some energy functional, find the collision, factor $N$. Path length $O(\log N)$: sub-linear, wonderful.

It does not work, and the reason is a theorem.

> **Ball Volume Growth.** The number of tree nodes inside the hyperbolic ball of radius $R$ about the origin is between $e^{2R}/300$ and $4e^{2R}$.

The lower bound is the hard half: one must exhibit quadratically many *coprime* pairs of opposite parity inside a box, which requires a genuine sieve. (The trick: the box $\{m \text{ even},\, 2K<m\le 4K\}\times\{n\text{ odd},\,1\le n\le 2K\}$ has $K^2$ pairs, and an inclusion–exclusion over odd divisors $d\ge3$, controlled by the telescoping estimates $\sum 1/(2i+3)^2 \le 1/4$ and $\sum 1/(2i+3)\le\sqrt{2n+1}-1$, discards fewer than three quarters of them.) The upper bound is easy from the exact distance formula.

Now count. The ball guaranteed to contain a collision for $N$ has radius $R \approx \tfrac12\log N$, so it contains $\asymp e^{2R} = \asymp N$ nodes. The search region is as large as the number you were trying to factor. Short geodesics, yes — but exponentially many of them. This is a **no-free-lunch theorem**: the hyperbolic metric compresses the tree, but it compresses the haystack and the needle by exactly the same factor.

There is a further, independent obstruction. One might hope that the *combinatorial* depth of a node — the number of Berggren moves needed to reach it — is also $O(\log N)$. It is not. The left spine $(2,1)\to(3,2)\to(4,3)\to\cdots$ reaches depth $k$ with hypotenuse only $2k^2+6k+5$, so depth there is $\Theta(\sqrt{c})$: exponentially worse than the geodesic distance. In the other direction, depth *does* bound the distance: a node at depth $k$ has $m\le 2\cdot 3^k$, hence $2d \le \log 32 + k\log 9$. So distance $\lesssim$ depth, with no reverse inequality. The hyperbolic metric compresses the tree exponentially, and that compression is not something an algorithm can walk along.

The one form in which "$O(\log N)$" survives is this: for every target $N$ there *is* a node of hypotenuse at least $N$ at depth $\lfloor\log_2 N\rfloor$, namely along the middle spine $(2,1)\to(5,2)\to(12,5)\to(29,12)\to\cdots$ (whose entries, pleasingly, are Pell numbers, and whose alternate members are precisely the $B_2$ boundary layer). *Reaching* size $N$ is logarithmically cheap. *Finding a particular node* of size $N$ is not.

## What we are left with

Strip away the failed algorithm and what remains is, I think, more interesting than what was sought. A purely combinatorial object — a ternary tree of integer triples — has been given a metric geometry in which:

- every node's position is known exactly, by a closed formula;
- the radial coordinate is $\tfrac12\log(\text{hypotenuse})$ to within $\tfrac12\log 2$;
- the angular information — the residual — is a function of the triangle's *shape* alone, to within $n^2/c^2$, which we can compute both ways;
- each of the three generators moves you in a determined direction, and the direction is decided by a single quadratic threshold, $\sqrt2-1$;
- the tree is genuinely a tree (every seed reachable, at exactly one depth, via an explicit descent that reads the slope against the thresholds $1/3$ and $1/2$);
- and the density of nodes at radius $R$ is $\Theta(e^{2R})$, the exact volume growth rate of the hyperbolic plane itself.

The leading constant even appears to be computable. The distance formula turns the ball $d\le R$ into the Euclidean disc $(m-\cosh R)^2+n^2 \le \sinh^2 R$; intersecting the rescaled unit disc with the wedge $0<n<m$ leaves area $\tfrac{\pi}{4}+\tfrac12$, and seeds have density $4/\pi^2$ among integer pairs (coprime density $6/\pi^2$, times the two thirds of coprime pairs of opposite parity). The prediction is $\#\mathcal B(R) \sim \tfrac{\pi+2}{4\pi^2}e^{2R} = 0.130237\ldots\,e^{2R}$; direct enumeration up to $R=8$ gives $0.13024$. Turning that agreement into a theorem, with an error term, is open.

That last point deserves a final word. The hyperbolic plane's area grows like $e^{2R}$ — that is the defining feature of negative curvature. The Berggren tree, placed in it, has *exactly* the same growth rate. The tree of Pythagorean triples is not merely embeddable in the hyperbolic plane; it is, in a precise density sense, a uniformly distributed net in it. The arithmetic and the geometry have the same volume.

Which is why no clever walk will save you. You cannot outrun the curvature you are standing in.
