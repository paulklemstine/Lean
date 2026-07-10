# Turing's Flowers: The Hidden Algebra of Spots and Stripes

## A pattern is a puzzle

Look closely at a leopard's coat, a zebra's flank, the ripples on a tropical fish, or the whorls at the tip of a fingerprint. These patterns are astonishingly regular, yet no architect drew them. They emerge on their own, as the animal grows, from a molecular conversation happening in the skin. In 1952 the mathematician Alan Turing proposed the mechanism that we still believe today: two chemical substances, one that activates a color and one that inhibits it, diffuse through tissue at different speeds and react with one another. Out of this tug-of-war between reaction and diffusion, a uniform sheet of cells spontaneously breaks its own symmetry and settles into spots, stripes, or a maze of interlocking ridges.

Turing's insight was revolutionary, but it left a difficulty behind. The patterns it predicts are solutions of *reaction–diffusion equations*: partial differential equations that describe how concentrations change in space and time. Such equations are notoriously hard to analyze. You can simulate them on a computer and watch spots bloom, but proving general statements about the shapes that appear is a different and much harder game.

This article tells the story of a shortcut. It turns out that the patterns Turing described are not just wiggly curves with no particular structure. At the moment a pattern is *born* — the instant the flat, featureless state first becomes unstable — the shape of the pattern is governed by **algebra**, not analysis. The boundary of a spot, the centerline of a stripe, the skeleton of a labyrinth: each of these is, to leading order, an *algebraic curve* — the zero set of an honest polynomial. And once you know that, the entire toolkit of classical geometry, the geometry of circles, ellipses, and hyperbolas that has been understood since the ancient Greeks, comes rushing in to describe biology.

The punchline, stated as vividly as possible: **the mathematics of leopard spots and zebra stripes is the mathematics of conic sections.**

## Where the algebra comes from

To see why, we need one clean idea from Turing's own analysis. Near the onset of pattern formation, the emerging pattern is a *superposition of waves*. Each wave is a simple oscillation in space, and in one direction it looks like

$$u(x) = \cos(n x),$$

where the integer $n$ counts how many full oscillations fit in the pattern — physicists call it a *mode*. A single mode gives you a single spatial frequency; adding a second mode gives you two; and so on. The number of modes that are "switched on" is the fundamental data of the pattern.

Now comes the magic key that unlocks everything. Write $X = \cos\theta$ for the value of a single cosine wave. Then the higher waves are not new, independent functions — they are *polynomials* in $X$. This is the classical **Chebyshev correspondence**:

$$\cos(2\theta) = 2X^2 - 1, \qquad \cos(3\theta) = 4X^3 - 3X, \qquad \cos(4\theta) = 8X^4 - 8X^2 + 1,$$

and in general $\cos(n\theta)$ is a polynomial of degree *exactly* $n$ in $X = \cos\theta$. The word "exactly" is the crucial part: the degree is never smaller than $n$, because the leading coefficient is $2^{n-1}$, which is never zero. So the correspondence is faithful. The number of modes cannot hide.

This single fact is a dictionary between two worlds:

$$\textbf{number of spatial modes} \;\longleftrightarrow\; \textbf{algebraic degree of the pattern.}$$

Turn on one mode and you get degree one — a linear equation, whose zero set is a straight line. Turn on two modes and you get degree two — a *quadratic*, whose zero set is a **conic section**. Turn on three and you can reach degree six — a *sextic*, the natural home of six-fold, hexagonal symmetry.

## Two modes, three destinies

The heart of the story lives at degree two. A generic two-mode pattern, restricted to the background level (the set of places where the chemical concentration equals its baseline value), is the zero set of a quadratic equation in two spatial coordinates $x$ and $y$:

$$a\,x^2 + b\,y^2 + (\text{lower-order terms}) = c.$$

The ancient Greeks classified exactly these curves. Depending on the signs of the coefficients, a quadratic curve is a **circle or ellipse**, a **pair of parallel lines**, or a **hyperbola**. And here is the beautiful coincidence at the center of this work: those three algebraic cases correspond precisely to the three great morphological classes of Turing patterns.

- **Spots are ellipses.** When the quadratic form is *positive definite* — both coefficients $a$ and $b$ positive — the curve closes up on itself. In the simplest, isotropic case the level set $\{\,a(x^2+y^2) = r^2\,\}$ is *exactly* a circle, of radius $r/\sqrt{a}$. More generally, an anisotropic spot $\{\,a x^2 + b y^2 = c\,\}$ with $a,b>0$ is an ellipse, and every point on it satisfies

  $$x^2 + y^2 \;\le\; \frac{c}{a} + \frac{c}{b}.$$

  In words: a spot is **bounded**. It fits inside a disc. This is the metric signature of an isolated blob of pigment.

- **Stripes are parallel lines.** A single mode $\{\cos x = c\}$ carves the plane into an infinite family of parallel lines. Two features distinguish it. First, it is **periodic**: if a point lies on the pattern, so does the same point shifted by any whole number of wavelengths, $x \mapsto x + 2\pi k$. The stripes repeat forever. Second, it is **unbounded**: each stripe runs off to infinity in the transverse direction, because nothing in the equation $\cos x = c$ constrains $y$ at all. A zebra's stripe does not curl back on itself; it sweeps across the whole flank.

- **Labyrinths are hyperbolas.** When the quadratic form is *indefinite* — the coefficients have opposite signs, as in $\{\,x^2 - y^2 = c\,\}$ — the curve splits into two branches that fly apart to infinity. It is **unbounded** in the strongest sense: for any radius $R$, no matter how large, the curve contains a point farther out than $R$. This is the algebraic hallmark of the space-filling, maze-like patterns — the "brain coral" texture — that biologists call labyrinthine.

So a single algebraic quantity, the **definiteness of a quadratic form**, sorts every two-mode pattern into spot, stripe, or labyrinth. Bounded means spot. Unbounded and periodic means stripe. Unbounded and split means labyrinth.

## Spots are not labyrinths — and here is the proof

It is tempting to worry that this is all bookkeeping — that with enough algebraic sleight of hand a circle could be re-described as a hyperbola and the whole dichotomy would collapse. It cannot. There is a clean, unarguable reason a spot and a labyrinth are genuinely different objects, and it is worth stating precisely.

**Theorem (Morphological Dichotomy).** *Let $\rho$ be any radius and let $c>0$. The circle*

$$\{(x,y) : x^2 + y^2 = \rho^2\}$$

*and the hyperbola*

$$\{(x,y) : x^2 - y^2 = c\}$$

*are never the same set of points in the plane.*

The proof is a two-line argument that a child can follow and a skeptic cannot escape. Every point on the circle satisfies $x^2+y^2 = \rho^2$; the whole set sits at a fixed distance from the origin, so no point of it has squared distance greater than $\rho^2$. The hyperbola, on the other hand, contains points arbitrarily far away: take $x = \sqrt{t^2+c}$ and $y = t$ for large $t$, and you get an honest point of $\{x^2-y^2=c\}$ whose squared distance $2t^2 + c$ blows up without limit. A set that stays inside a disc cannot equal a set that runs off to infinity. Therefore the two are different — not by convention, but as a matter of fact.

This is the whole dichotomy in miniature. **Boundedness** is the invariant. A spot is bounded; a labyrinth is not; and no amount of relabeling can turn one into the other.

## Climbing to hexagons

Two modes give conics. What about three? Here the degree climbs. Because $\cos(3\theta)$ is a *cubic* in $X = \cos\theta$, a quantity built from three modes — for instance the squared amplitude $\cos(3\theta)^2$ — is a polynomial of degree **six**. Concretely, there is a sextic polynomial $Q$ with

$$Q(\cos\theta) = \cos(3\theta)^2$$

for every angle $\theta$. Degree six is exactly the algebraic setting in which six-fold symmetry lives naturally, and hexagonal spot lattices — the packing you see on the skin of a pufferfish or in the dots on a giraffe — are the biological patterns with three active modes. The dictionary keeps its promise: more modes, higher degree, richer symmetry.

## The horizon: a genus dictionary

The results above pin down the *coarse* morphology — bounded versus unbounded, spot versus stripe versus labyrinth — from the algebra of low-degree curves. There is a bolder conjecture waiting just beyond, and it concerns not the size of the curve but its *topology*.

Every algebraic curve has a whole-number invariant called its **genus**, which counts, roughly, how many holes it has when you view it as a surface over the complex numbers. The genus–degree formula from classical geometry says a smooth curve of degree $d$ has genus at most $(d-1)(d-2)/2$. Since the degree is fixed by the number of modes, the topology of the pattern is *capped by the mode count*. The conjecture is that this bound is sharp and meaningful: genus zero gives isolated spots (topologically spheres), genus one gives stripes (topologically a torus), and higher genus gives labyrinths with more and more holes — the number of holes being, quite literally, a count of the passages in the maze.

If that dictionary holds, then the most intricate feature of a biological pattern — how connected it is, how many loops and passages it contains — would be readable directly from a single integer: the number of chemical waves that started it all. The topology of a seashell would be a corollary of counting.

## Why this matters

Turing gave biology a *mechanism*. What the algebraic viewpoint adds is a *classification*. Instead of solving a hard differential equation and squinting at the pictures, you can ask a purely algebraic question — what is the degree, is the form definite, what is the genus — and read off the morphological class directly. Circles for spots, parallel lines for stripes, hyperbolas for labyrinths, sextics for hexagons.

There is something deeply satisfying about the collapse of scales this represents. The conic sections were studied by Apollonius more than two thousand years before anyone knew what a cell was. The same curves that describe the orbit of a comet and the path of a thrown stone turn out to describe the spots on a big cat and the stripes on a fish. Morphogenesis, at the moment of its birth, speaks the oldest language in geometry.

Nature, it seems, is not only a physicist. She is also, quietly, an algebraist.
