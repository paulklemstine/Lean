# The Spectrum Hidden in a Fraction

## A puzzle about how well numbers can be approximated

Some numbers are easy to pin down with fractions, and some are stubborn. The number $\tfrac{22}{7}$ is a famously good approximation to $\pi$ — close, compact, useful. But ask how *well* any particular irrational number can be approximated by fractions $p/q$, and you uncover one of the oldest and most beautiful threads in mathematics.

The right way to measure "how well a number resists approximation" is a single real number attached to each irrational $x$, called its **Lagrange constant**:

$$k(x) = \liminf_{q \to \infty} \; q \cdot \lVert q x \rVert,$$

where $\lVert t \rVert$ denotes the distance from $t$ to the nearest integer. In words: take larger and larger denominators $q$, see how close $qx$ can get to a whole number after scaling by $q$, and record the smallest persistent value. A *small* $k(x)$ means $x$ can be approximated unusually well; a *large* $k(x)$ means $x$ is "badly approximable" — it holds fractions at arm's length.

The golden ratio $\varphi = \tfrac{1+\sqrt 5}{2}$ is the worst-approximable number of all, with $k(\varphi) = 1/\sqrt 5 \approx 0.447$. Numbers like the golden ratio, whose Lagrange constant is strictly positive, are the **badly approximable** numbers, and they form a rich and intricate set.

This article is about a surprising structure that appears when you do something simple to these numbers: feed them through a fraction.

## Twisting numbers through a Möbius map

Take four integers $p, q, r, s$ and arrange them into a $2 \times 2$ matrix
$$M = \begin{pmatrix} p & q \\ r & s \end{pmatrix}.$$
This matrix acts on a real number $x$ by the **Möbius transformation** (also called a linear fractional transformation):

$$M \cdot x = \frac{p\,x + q}{r\,x + s}.$$

These maps are the natural "symmetries" of the world of continued fractions. When $M$ has determinant $\det M = ps - qr = \pm 1$, the transformation merely reshuffles the front of a number's continued-fraction expansion and leaves its deep structure — and therefore its Lagrange constant — completely unchanged. In that special case, $k(M x) = k(x)$ exactly.

But what happens when the determinant is *not* $\pm 1$? Suppose $\det M = D$, an integer larger than $1$ in absolute value. Now the map genuinely distorts the number's approximation behaviour. A classical two-sided estimate, due to Lagarias and Shallit, says the distortion is bounded:

$$\frac{1}{|D|} \;\le\; \frac{k(M x)}{k(x)} \;\le\; |D|.$$

So the *ratio* of Lagrange constants — how much $M$ stretches or compresses the approximation quality of $x$ — is trapped inside the interval $\left[\tfrac{1}{|D|},\, |D|\right]$. This interval is the natural arena. It is symmetric in a precise sense: its two endpoints multiply to $1$,
$$\frac{1}{|D|} \cdot |D| = 1,$$
mirroring the fact that running $M$ backwards (using its inverse) swaps the roles of the endpoints. The midpoint, the value $1$, always lives inside it — corresponding to the case where $M$ leaves $k$ untouched.

## The central question: does the ratio fill the whole interval?

Knowing that the ratio $k(Mx)/k(x)$ *lives* in $[\tfrac{1}{|D|}, |D|]$ is one thing. A far deeper question is whether it actually *reaches everywhere* in that interval. As $x$ wanders over all badly approximable numbers, does the ratio sweep out the entire range, leaving no gaps?

The conjecture at the heart of this work says **yes — and densely**:

> **Density of the ratio spectrum.** For every primitive integer matrix $M$ with nonzero determinant, the set of ratios $k(Mx)/k(x)$, as $x$ ranges over the real *quadratic irrational* badly approximable numbers, is dense in the full interval $\left[\tfrac{1}{|\det M|},\, |\det M|\right]$. Equivalently, for any target window $u < v$ inside this interval, there is a quadratic irrational $x$ with $u < k(Mx)/k(x) < v$.

(A matrix is **primitive** when its four entries share no common factor — the natural normalization, since multiplying all entries by a constant changes nothing about the Möbius map.)

This is a strong statement. It claims that the humble operation "divide one fraction by another" hides a complete continuum of behaviours, and that you can dial in any distortion ratio you like, to any precision, just by choosing the right quadratic irrational input.

## Why quadratic irrationals?

Why restrict the inputs $x$ to **quadratic irrationals** — numbers like $\sqrt 2$, $\tfrac{1+\sqrt 5}{2}$, or $3 - \sqrt 7$, the irrational solutions of quadratic equations with integer coefficients?

The reason is a theorem of Lagrange, one of the gems of number theory: a real number is a quadratic irrational *if and only if* its continued fraction is eventually periodic. Periodic continued fractions are the most controllable infinite objects in this subject — they repeat, so their Lagrange constants can in principle be computed exactly from a finite amount of data. They are the perfect laboratory specimens: rich enough to exhibit every behaviour, structured enough to be analyzable.

But this restriction raises an immediate worry. If you only allow a special, structured class of inputs, maybe that class is too thin to produce a *dense* set of outputs. Maybe the periodicity constraint leaves holes. This is exactly the worry that the formally verified results in this work lay to rest.

## Building the floor before building the house

The full density conjecture has two layers. The top layer is analytic and delicate: it requires controlling the Lagrange constant $k$ along families of periodic continued fractions, and showing the ratios can be nudged across the whole interval. The bottom layer is **topological and algebraic**: it must guarantee that the playing field is large enough — that quadratic irrationals are everywhere, that the Möbius map shuffles them around without collapsing them, and that nothing degenerate happens.

This work rigorously and completely establishes that bottom layer — the *floor* on which the full theorem will stand. Every statement below has been verified down to the last logical step.

**First cornerstone: quadratic irrationals are everywhere.** Consider the explicit family of numbers
$$x = q + \sqrt 2, \qquad q \text{ any rational number}.$$
Each such number is a genuine quadratic irrational: it is irrational (because $\sqrt 2$ is, and adding a rational cannot fix that), and it satisfies a quadratic equation with integer coefficients. Concretely, if $q = e/f$ in lowest terms, then $x = e/f + \sqrt 2$ is a root of
$$f^2\,x^2 - 2ef\,x + (e^2 - 2f^2) = 0,$$
an honest integer quadratic with nonzero leading coefficient $f^2$. This single one-parameter family does all the heavy lifting, because rationals are dense: between *any* two real numbers $u < v$, you can slip a rational $q$ into the shifted window $(u - \sqrt 2,\, v - \sqrt 2)$, and then $q + \sqrt 2$ is a quadratic irrational sitting strictly between $u$ and $v$.

This is the result we call **domain density**: every interval, no matter how tiny, contains a quadratic irrational. The set of allowed inputs is not thin at all — it is dense in the entire real line.

**Second cornerstone: the Möbius map can be run backwards.** The matrix $M = \begin{pmatrix} p & q \\ r & s\end{pmatrix}$ has a natural partner, its **adjugate**
$$\operatorname{adj} M = \begin{pmatrix} s & -q \\ -r & p\end{pmatrix},$$
which gives the inverse Möbius map. The key technical fact is that this partner map never breaks down on an irrational input: its denominator $-r\,w + p$ is never zero when $w$ is irrational and $\det M \ne 0$. (If $r \ne 0$, a zero denominator would force $w = p/r$, a rational — contradiction; if $r = 0$, the nonzero determinant forces $p \ne 0$.) With the denominator safely nonzero, a direct computation confirms that applying $M$ to the adjugate image of any number $w$ returns $w$ exactly:
$$M \cdot \left( \operatorname{adj} M \cdot w \right) = w.$$
This is **adjugate inversion**: the two maps undo each other, and the determinant reappears exactly as the scalar that makes the algebra balance. This is the precise reason the interval's endpoints are reciprocal — running $M$ forward and backward swaps $|D|$ and $1/|D|$.

**Third cornerstone: the image is everywhere too.** Combining the first two cornerstones yields the payoff. Given any target window $(u, v)$, we want a quadratic irrational $x$ whose Möbius image $M \cdot x$ lands inside it. The construction is wonderfully direct: first use domain density to find a quadratic irrational $w$ *already* inside $(u, v)$, then pull it back through the adjugate to define
$$x = \operatorname{adj} M \cdot w = \frac{s\,w - q}{p - r\,w}.$$
A closure theorem guarantees that this $x$ is *still* a quadratic irrational (the Möbius image of a quadratic irrational under an integer matrix of nonzero determinant is always another quadratic irrational), and adjugate inversion guarantees that $M \cdot x = w$, which by construction lies strictly between $u$ and $v$. This is **image density**: the Möbius image of the quadratic-irrational world is dense in the real line.

Why is the closure theorem true? If $x$ is an irrational root of $a x^2 + b x + c$, substitute the inverse map into the quadratic and clear denominators. You get a new integer quadratic satisfied by the image, whose leading coefficient is the binary form $a s^2 - b s r + c r^2$. The one thing that could go wrong is this coefficient vanishing — but it cannot, because the discriminant $b^2 - 4ac$ of an irrational root is never a perfect square, which makes the form **anisotropic** (it has no nontrivial integer zeros). The identity
$$4a\,(a m^2 - b mn + c n^2) = (2am - bn)^2 - (b^2 - 4ac)\,n^2$$
turns "the leading coefficient is nonzero" into "the discriminant is not a square," which is just another face of irrationality.

## What this means

Put the three cornerstones together and a clear picture emerges. The inputs to the ratio spectrum form a dense set; the Möbius map is invertible and non-degenerate on them; and the images form a dense set too. The geometric and algebraic scaffolding the full density theorem needs is now completely in place and rigorously certified.

There is one honest gap remaining, and it is worth naming precisely. Everything above controls *where the numbers go* under $M$ — the geometry of the map. The full conjecture is about *what happens to their Lagrange constants* — the arithmetic of approximation. Bridging the two requires the analytic Lagarias–Shallit machinery: defining $k$ through continued-fraction convergents and showing its ratio can be steered continuously across $[\tfrac{1}{|D|}, |D|]$ by inserting larger and larger partial quotients into a periodic expansion. That is the next chapter.

What makes the story satisfying is how it collapses a hard-looking problem into something almost tactile. A deep fact about determinant structure — that the *only* feature of $M$ visible to the ratio spectrum is $|\det M|$ together with the primitive class — comes from two elementary observations: integer matrices of nonzero determinant have $|\det| \ge 1$, and scaling all entries of $M$ by a constant leaves the Möbius map unchanged. Through the lens of the Smith normal form, every primitive matrix of determinant $D$ is equivalent to the diagonal matrix $\operatorname{diag}(1, D)$, so the whole problem reduces to studying the single map $x \mapsto x/D$. The matrix melts away, and what remains is a question about dividing one badly approximable number by an integer.

## A continuum in a fraction

It is tempting to think of approximation quality as a fixed, intrinsic property of a number — either it is well-approximable or it isn't. The ratio spectrum says otherwise. It says that approximation quality is *malleable*: you can take any badly approximable number, run it through an integer fraction, and tune the resulting change in quality to land anywhere in a predictable band. And the conjecture says that band is filled completely, with no gaps, by the most structured numbers we have — the periodic, the quadratic, the eventually-repeating.

The work described here builds the rigorous foundation for that claim: a verified guarantee that the stage is set, the actors are everywhere, and the choreography of forward-and-backward Möbius maps works exactly as it must. The final act — the dance of the Lagrange constants themselves — awaits, but the floor beneath it is now solid.
