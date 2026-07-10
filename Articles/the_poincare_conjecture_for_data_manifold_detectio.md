# How Many Points Does It Take to See a Shape?

## A famous theorem, reborn as a question about data

At the turn of the twentieth century, Henri Poincaré asked one of the most consequential questions in the history of geometry: if a three-dimensional space has no holes — if every loop drawn inside it can be shrunk to a point — must it secretly be a sphere? A century later, Grigori Perelman proved that the answer is *yes*. Every simply connected closed three-dimensional space is, topologically, the three-dimensional sphere. It was one of the great intellectual achievements of our era, and it settled a problem so hard that it carried a million-dollar prize.

But there is a modern echo of Poincaré's question that has nothing to do with abstract spaces and everything to do with the messy world of data. Suppose you are handed not a smooth manifold but a **cloud of points** — the output of a sensor, the coordinates of galaxies, the activations of neurons, the pixels of ten thousand photographs. Somewhere hidden in that cloud might be a shape: a circle, a sphere, a torus, a curved surface bending through high-dimensional space. The **Poincaré conjecture for data** asks the natural analogue of Poincaré's question:

> *If a point cloud has the "shape signature" of a sphere, does it actually lie on a sphere — and at what scale can we tell?*

This article is about a precise, provable version of that question, and about a surprising twist: the clean formula everyone expected turns out to be *almost* right, and the story of *why* it is only almost right is more interesting than the formula itself.

## The shape you see depends on how far you squint

Handed a scatter of dots, how do you decide what shape they form? The central idea of *topological data analysis* is disarmingly simple. Pick a scale — call it $\varepsilon$ — and connect any two points that are closer than $\varepsilon$ apart. As $\varepsilon$ grows from zero, the cloud passes through a life cycle of shapes. When $\varepsilon$ is tiny, every point is an island: you see only dust. When $\varepsilon$ is enormous, everything blurs into one solid blob. But in between, at just the right scale, the true shape snaps into focus. A ring of points reveals a loop; points sprinkled on a sphere reveal a hollow surface with a cavity inside.

Mathematicians make this rigorous by building, at each scale $\varepsilon$, a combinatorial object called the Vietoris–Rips complex, and reading off its *homology* — an algebraic fingerprint that counts connected pieces, loops, voids, and their higher-dimensional cousins. A genuine $d$-dimensional sphere has an unmistakable fingerprint: one connected component, no loops or voids of intermediate dimension, and exactly one $d$-dimensional cavity. When a point cloud's fingerprint matches, we say the data "looks like a sphere."

The crucial catch is that this only works in a *window* of scales. Too small and the cloud is dust; too large and it is mush. The **Poincaré threshold** is the smallest scale $\varepsilon_\star$ at which the sphere finally comes into view. The whole game of manifold detection turns on understanding this one number.

## The conjectured law

Intuition, backed by heuristic sampling arguments, suggested a beautiful formula. If you scatter $n$ points on a $d$-dimensional sphere, the detection threshold should be

$$\varepsilon_\star \;=\; C \cdot d^{1/2} \cdot n^{-1/d}$$

for some universal constant $C$. Three ingredients live in this formula, and each tells a story:

- The factor $n^{-1/d}$ says that **more points let you resolve finer detail**, but with diminishing returns that get worse in higher dimensions. To halve the resolution of a curve ($d=1$) you double the points; to halve the resolution of a solid three-dimensional shape ($d=3$) you need *eight times* as many. This is the curse of dimensionality wearing a geometer's hat.
- The factor $d^{1/2}$ is a mysterious dimensional prefactor — where does a square root of the dimension come from?
- The constant $C$ is supposed to be universal, the same for every sphere in every dimension.

The formula is elegant. The question is whether it is *true*. And here the answer splits into three verdicts: two "yes"es and one instructive "no."

## Verdict one: the exponent is real, and it is exactly $-1/d$

To reason about thresholds without drowning in the analytic subtleties of curved spheres, we work in a clean model that captures the essential combinatorics: a **discrete grid cube**. Picture the integer lattice points $\{0, 1, \dots, m-1\}^d$ — an $m \times m \times \cdots \times m$ grid in $d$ dimensions. This grid stands in for a sampled shape, and covering it well with a small set of "landmark" points is exactly the problem of resolving a shape at a given scale. We measure distance in the *Chebyshev* (or $\ell^\infty$) metric, where the distance between two grid points is the largest coordinate-wise gap.

A set $S$ of landmarks is an **$r$-cover** if every point of the cube lies within Chebyshev distance $r$ of some landmark. This is precisely the condition — via the classical Nerve Lemma — under which the Rips complex built on $S$ faithfully reproduces the shape of the cube. So "detecting the shape at scale $r$" becomes "covering the cube with radius $r$," and the threshold becomes the smallest achievable covering radius for a given number of landmarks.

Now the counting is clean. A single Chebyshev ball of radius $r$ contains at most $(2r+1)^d$ grid points — a little cube of side $2r+1$. To blanket all $m^d$ points of the big cube you therefore need enough balls that

$$m^d \;\le\; |S| \cdot (2r+1)^d.$$

This is a genuine, rigorously proved **packing lower bound**. Rearranged, with $n = |S|$ the number of landmarks, it reads

$$m \;\le\; n^{1/d} \,(2r+1), \qquad\text{equivalently}\qquad 2r+1 \;\ge\; m\cdot n^{-1/d}.$$

There it is: the covering radius — the discrete Poincaré threshold — is forced to be at least a constant times $n^{-1/d}$. The exponent in the conjectured law is not a guess; it is a theorem.

## Verdict two: the exponent is sharp — you can't do better

A lower bound alone might be pessimistic. Perhaps the true threshold decays even faster, and $n^{-1/d}$ is merely a loose estimate. It is not. The bound is *achieved*, exactly, by the most natural construction imaginable: a **regular grid of landmarks**.

Suppose the side length factors as $m = (2r+1)\,t$. Chop each coordinate axis into $t$ equal blocks of width $2r+1$, and place one landmark at the center of each block in every dimension. This produces exactly $t^d$ landmarks, and every point of the cube sits within radius $r$ of its block center — a perfect $r$-cover. So a cover of size exactly $t^d = (m/(2r+1))^d$ exists.

And nothing smaller works: combining the construction with the packing bound above shows that **every** $r$-cover must use at least $t^d$ landmarks. The minimum cover size is *exactly* $t^d$. There is no slack, no hidden improvement, no cleverer arrangement. The exponent $-1/d$ is not just valid — it is optimal. Manifold detection genuinely obeys the curse of dimensionality, and the grid cover proves the curse cannot be dodged.

## Verdict three: where the $\sqrt{d}$ comes from — and why it isn't topology

What about the mysterious $d^{1/2}$? The answer is quietly deflationary, and all the more satisfying for it. The clean packing story lives in the Chebyshev metric, where balls are little cubes. But real spheres, and the scale parameter $\varepsilon$ of the Rips complex, are measured with the ordinary Euclidean ruler, where balls are round. To translate a covering radius from one metric to the other, you must convert between the two ways of measuring length — and that conversion is governed by a sharp, elementary inequality:

$$\|x\|_\infty \;\le\; \|x\|_2 \;\le\; \sqrt{d}\,\|x\|_\infty.$$

In words: the Euclidean length of a vector is never smaller than its largest coordinate, and never larger than $\sqrt{d}$ times its largest coordinate. Both bounds are tight. The right-hand inequality becomes an *equality* for the vector $(1,1,\dots,1)$, whose largest coordinate is $1$ but whose Euclidean length is exactly $\sqrt{d}$. So $\sqrt{d}$ is the exact, unbeatable worst-case cost of switching rulers.

That is the whole origin of the $d^{1/2}$ prefactor. It is a **metric artifact** — an accounting entry for the change from cube-balls to round-balls — not a feature of the underlying topology. The shape does not care which ruler you use; only your bookkeeping does. Recognizing this dissolves the mystery: the square root of the dimension was never geometry, it was units.

## Verdict four: the clean equality is false

Now the twist. The conjecture did not merely claim a scaling *proportional* to $n^{-1/d}$; it claimed an exact *equality*, $\varepsilon_\star = C\,d^{1/2}\,n^{-1/d}$, with a single positive constant $C$. And that stronger claim is simply false.

The reason is a matter of arithmetic honesty. The number of landmarks $n$ is a whole number, and so is the covering radius $r$. As you slowly add landmarks, the minimal achievable radius does not glide smoothly downward — it drops in **steps**, staying flat across whole ranges of $n$ before ticking down. It is a staircase, not a slope.

The smallest concrete witness lives in one dimension. Take the line grid of $m = 7$ points. Covering it with radius $0$ would require a separate landmark on every single point — all seven of them. But with radius $1$, just three landmarks (say at positions $1$, $3$, and $5$) suffice, since each covers itself and its two neighbors. So the minimal radius for $3$ landmarks is exactly $1$. Add a fourth landmark, and the minimal radius is *still* $1$ — you cannot reach radius $0$ without four more points. In fact the minimal radius stays pinned at $1$ for every landmark count from $3$ through $6$.

Now confront this with the proposed law. In one dimension it reads $\varepsilon_\star = C/n$. If it held exactly, then the threshold for $3$ landmarks and for $4$ landmarks would be $C/3$ and $C/4$ — necessarily *different* numbers, since $C > 0$. But the true thresholds are equal: both are $1$. A strictly decreasing function cannot be constant on a stretch. The only escape is $C = 0$, which contradicts $C$ being a positive constant. **No positive constant reproduces the threshold exactly.**

This is not a defect to be patched; it is a lesson. The conjectured equality confuses a smooth continuous law with a discrete, integer-valued reality. The honest statement replaces the equals sign with an "$\asymp$": the threshold *scales like* $n^{-1/d}$, matching it up to bounded constant factors, but it is not literally proportional to it.

## What survives, and why it matters

Strip away the false precision and a robust, fully rigorous picture remains:

- **The scaling exponent is exactly $-1/d$**, proved as a matched pair of upper and lower bounds. Detecting a $d$-dimensional shape requires resolution that improves only as the $-1/d$ power of the sample size — a hard, unavoidable curse of dimensionality.
- **The $\sqrt{d}$ prefactor is a change-of-ruler constant**, the sharp price of converting between the Chebyshev and Euclidean metrics, with nothing topological about it.
- **The clean equality is false**, because the true threshold is a staircase; the correct statement is a scaling relation, not an identity.

The upshot is a genuinely useful principle for anyone who works with high-dimensional data. Manifold detection is fundamentally a **topological** problem, and its difficulty is governed by a single exponent tied to the intrinsic dimension of the hidden shape — not the dimension of the space it floats in. If your data secretly lives on a two-dimensional surface, you pay the $d=2$ price to see it, no matter how many ambient coordinates you recorded. That is liberating: it means the sample complexity of "seeing the shape" depends on the shape, not on the sensor.

Poincaré asked whether a space with no holes must be a sphere. Its data-world descendant asks how many points it takes to *notice*. The answer, made precise, is a clean power law with a subtle staircase hiding inside it — a reminder that in the passage from continuous mathematics to finite data, the most beautiful formulas are usually true only up to a constant, and the constant has a story of its own.
