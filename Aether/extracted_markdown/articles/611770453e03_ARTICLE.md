# The Hidden Layers of Shape: How Mathematicians Found a New Way to Measure Curvature in Discrete Worlds

## A Surprising Question About Sequences

Consider the sequence 1, 3, 3, 1 — the coefficients that appear when you expand $(1 + x)^3$. These numbers have a beautiful property: each middle term squared is at least as large as the product of its neighbors. $3^2 = 9 \geq 1 \times 3 = 3$. Mathematicians call this *log-concavity*, and it shows up everywhere — in the number of spanning trees in a network, in the probabilities of certain random processes, in the ways you can partition a number into parts.

But here is a question nobody had thought to ask systematically until now: what happens when you *peel away* the first layer of curvature and look underneath?

Take those same coefficients and compute the ratios between consecutive terms: $3/1 = 3$, $3/3 = 1$, $1/3 \approx 0.33$. This ratio sequence — $3, 1, 0.33$ — is the *discrete derivative* of the original, in a logarithmic sense. Is this new sequence also log-concave? Check: $1^2 = 1$ versus $3 \times 0.33 = 1$. It passes! So the curvature goes at least two layers deep.

You can keep going: take ratios of the ratios, and check again. For $(1 + x)^3$, the curvature persists all the way down. But for other sequences — say, $1, 3, 2, 1$ — the first layer passes the test, but the ratio sequence $3, 2/3, 1/2$ fails: $(2/3)^2 = 4/9$ is *less* than $3 \times 1/2 = 3/2$. The curvature breaks at the second layer.

This difference — between sequences whose curvature persists indefinitely and those whose curvature is only skin-deep — turns out to encode deep geometric information. And it connects to problems that matter far beyond pure mathematics.

## A New Ruler for Combinatorial Geometry

The insight underlying this work is deceptively simple: *repeated ratio transforms measure how deeply curved a discrete object really is.*

Think of it by analogy. A road might look smooth when you drive over it, but what about the road's slope — does *that* change smoothly? And the rate of change of the slope — is *that* smooth too? In continuous mathematics, these questions lead to the theory of differentiability classes: a road can be $C^1$ smooth (nice slope), $C^2$ smooth (nice curvature), or $C^\infty$ smooth (nice everything).

For discrete objects — combinatorial structures defined on integer lattice points — no such hierarchy existed. A function was either log-concave or it wasn't. There was no way to say "this function is curvature-class 3" or "this one is curvature-class 7."

Now there is. The *directional depth* of a function counts how many layers of ratio transforms preserve log-concavity. It provides a fine-grained ruler for measuring the geometric quality of combinatorial objects, one that is invisible to any single-layer test.

## Why Products Are the Key

The first major result is that this depth measure is *multiplicatively stable*: if two functions each have depth at least $k$, their product does too.

Why does this matter? Because in both mathematics and physics, combining independent systems corresponds to multiplying their weight functions. If you have two independent physical subsystems with well-behaved energy landscapes (high depth), combining them preserves that good behavior. If you have two independent probability distributions, each deeply log-concave, sampling from their product is also deeply log-concave.

This multiplicative stability is what transforms depth from a curiosity into a robust invariant. It means you can build complex structures from simpler pieces and know the depth only increases (or stays the same). The depth classes form algebraic structures — multiplicative monoids — that organize the world of combinatorial functions into a natural hierarchy.

## The Tropical Connection

The second breakthrough connects this algebraic hierarchy to geometry — specifically, to *tropical geometry*, a relatively young branch of mathematics that replaces ordinary arithmetic with a strange alternative where addition becomes "take the maximum" and multiplication becomes addition.

Tropical geometry has revolutionized combinatorics over the past two decades because it translates complicated algebraic questions into simpler combinatorial ones. The key operation is taking the negative logarithm: $v = -\log f$. This transforms multiplication into addition and turns log-concavity into a condition called *supermodularity* — the discrete analog of convexity.

The tropical bridge theorem says that mixed log-concavity — a natural strengthening of directional log-concavity that accounts for interactions between different directions — implies that $-\log f$ is supermodular. But the depth hierarchy does more: at each level, the ratio transform produces a *new* tropical potential, and if the depth is high enough, that potential is also supermodular.

This creates a tower of tropical convex functions, one for each layer of depth. Imagine peeling an onion: each layer reveals a new convex surface, and the depth counts how many layers you can peel before the convexity breaks. Functions with infinite depth are like onions that are convex all the way through — no matter how many layers you remove, the underlying geometry remains well-behaved.

## When Depth Is Finite

Not every function has infinite depth, and the *strictness theorem* proves this rigorously. The sequence $1, 3, 2, 1$ has exact depth 1: it passes the first-layer curvature test but fails the second.

What makes this example work? The issue is that the ratio sequence $3, 2/3, 1/2$ is *not* log-concave. The ratios drop too fast initially (from 3 to 2/3) and then too slowly (from 2/3 to 1/2), creating a curvature violation at the second level.

The *depth obstruction theorem* provides a practical test: to prove a function has depth less than 2, you only need to find a single direction where the ratio transform fails log-concavity. This gives a computational certificate — a finite, checkable proof that depth is bounded.

## The Dichotomy Conjecture

Computational experiments reveal a striking pattern: among "naturally arising" functions — those that come from algebra, combinatorics, or geometry — the depth seems to be either 1 or infinite. No natural example has been found with exact depth 2, 3, or any other finite value greater than 1.

This observation has been formalized as the *Depth Dichotomy Conjecture*: for valuated matroids — the combinatorial structures that encode optimization problems on weighted graphs, network flows, and linear programming — the depth is always 1 or $\infty$.

Geometric sequences (like powers of 2) have infinite depth — their ratio transform is constant, and a constant sequence trivially passes all log-concavity tests. The triangular sequence $1, 2, 1$ also has infinite depth. But binomial coefficients like $1, 4, 6, 4, 1$ (Pascal's triangle, row 4) have depth exactly 1.

The conjecture predicts that the transition between depth 1 and infinite depth is a *phase boundary* in the space of combinatorial functions, with no intermediate states. If true, this would mean the depth filtration cleanly separates the combinatorial world into two classes: functions with shallow curvature and functions with unlimited curvature depth.

## From Energy Landscapes to Chemical Potentials

The depth filtration has a natural interpretation in statistical physics. In this context, $-\log f$ is an *energy landscape* on a discrete state space — the energy of each configuration. The ratio transform $R_i f(m) = f(m + e_i)/f(m)$ is the Boltzmann factor for adding one particle of type $i$ to configuration $m$, and $-\log(R_i f)$ is the *chemical potential* — the energy cost of that addition.

Depth 1 says the energy landscape is convex along each axis. Depth 2 says the chemical potentials are also convex — meaning the energy cost of adding particles varies smoothly with the composition. Higher depth means this smoothness persists through more levels of thermodynamic derivatives.

In physical terms, a system with high depth has an energy landscape that is "well-behaved under renormalization" — you can coarse-grain it repeatedly and the convexity structure survives. This connects to fundamental ideas in statistical mechanics about universality and renormalization-group flow.

## A Proof You Can Trust

What makes this work particularly compelling is its foundation. Every theorem — multiplicative stability, the tropical bridge, hierarchy strictness, the depth obstruction — has been formalized as a complete, machine-verified mathematical proof. This is not merely a claim of truth; it is a guarantee, checked line by line by computer against the axioms of mathematics.

The formal proofs required careful handling of division by zero (since ratio transforms involve division), positivity tracking (to ensure logarithms are well-defined), and recursive induction (since the depth definition is inherently recursive). The resulting formalization serves as both a proof and a specification: anyone can inspect exactly what was proved and under what hypotheses.

## The Road Ahead

The directional depth filtration opens several exciting research directions. Can the depth invariant distinguish combinatorial structures that look identical under all first-order tests? Is there a fast algorithm for computing depth, or is it inherently expensive? What happens when you extend the theory from integer lattices to continuous domains?

Perhaps most ambitiously: does the depth filtration connect to the Hodge-Riemann relations that underlie the deepest results in combinatorial algebraic geometry? If so, the depth invariant might provide a computationally accessible proxy for structures that currently require heavy algebraic machinery to detect.

The mathematical universe, it turns out, has more layers than we thought. Directional depth gives us a new tool to measure just how deep the structure goes — and the answer, for the objects that matter most, seems to be: either barely beneath the surface, or all the way down.
