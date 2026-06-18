# When Smooth Curves Meet Pixel Grids: A New Bridge Between Continuous and Discrete Mathematics

## The Problem Nobody Thought Was a Problem

Imagine you're trying to predict weather patterns across a continent. The atmosphere is continuous — pressure and temperature vary smoothly through space. But your computer can only store numbers at discrete grid points. So you chop the world into tiny boxes and assign each box a single value.

This kind of discretization is so routine that most scientists don't think twice about it. You make the grid fine enough, and the approximation should be good enough. End of story.

Except it isn't. Because hiding inside that innocent-sounding approximation is a question that has bedeviled mathematicians for decades: *When you discretize a continuous system, which of its deep structural properties survive?*

Not the superficial ones — everyone knows that averages and totals transfer easily. The hard question concerns the geometric and algebraic properties that make continuous systems behave well: their tendency toward equilibrium, their resistance to perturbation, their capacity for rapid mixing. These are the properties that matter for algorithms, for sampling, for scientific computing. And until now, there has been no rigorous way to certify that they survive the jump from smooth to digital.

## Two Worlds, One Problem

The story begins with two mathematical communities that have been working in parallel for twenty years, largely unaware that they're circling the same quarry.

In one camp are the geometers and probabilists who study *log-concave measures*. These are the natural probability distributions that arise everywhere from statistics to physics — bell curves, exponential distributions, and their high-dimensional cousins. Log-concave measures have a beautiful theory built around *isoperimetric inequalities*: quantitative statements that among all shapes of a given volume, spheres have the smallest boundary. This geometric principle, which goes back to the ancient Greeks, turns out to control how fast random walks converge to equilibrium.

In the other camp are the algebraists and combinatorialists who study *Lorentzian polynomials*. These mathematical objects, whose theory was revolutionized by Petter Brändén and June Huh around 2020, encode a kind of discrete curvature. When a probability distribution's generating polynomial is Lorentzian, the distribution inherits powerful properties: negative correlations, concentration of measure, and rapid mixing of sampling algorithms. The theory earned Huh a Fields Medal in 2022.

Here's the tantalizing connection: both camps are ultimately studying the same phenomenon — how geometric curvature controls algorithmic efficiency. But their languages are different, their tools don't obviously translate, and the gap between continuous geometry and discrete algebra has resisted all attempts at a clean formal bridge.

## The Discretization Barrier

Why is this bridge so hard to build? The difficulty is not just technical — it's conceptual.

When you discretize a continuous measure, you do several violent things to it. You chop it into cells. You approximate integrals by point samples. You truncate the tails. Each of these operations introduces error. And the crucial question is whether these errors are merely quantitative — small perturbations that leave the deep structure intact — or qualitative, capable of destroying the very properties that made the continuous measure useful.

Consider an analogy. A perfectly circular drum vibrates at frequencies determined by its shape. If you slightly dent the drum, the frequencies shift a little but maintain their pattern. But if you cut the drum into a polygon, something more dramatic happens: the geometry changes fundamentally, and it's not obvious which vibrational properties survive.

The same worry applies to discretization. A log-concave measure on continuous space has an isoperimetric constant — a number that quantifies how well-connected it is, how resistant to fragmentation. When you discretize it onto a grid, does this connectivity survive? And if so, with what quantitative guarantees?

## The Transfer Principle

The breakthrough lies in recognizing that discretization is not a single violent operation but a sequence of small, controllable perturbations. Each cell in the grid introduces a tiny error. Each truncation at the boundary removes a small amount of mass. Each point-sample approximation shifts the weights slightly.

The key mathematical insight is that these perturbations accumulate *additively*, not multiplicatively. If each cell contributes an error of at most ε, and there are N cells, the total damage to the structural properties is proportional to N×ε — not to some wild nonlinear function of the errors.

This is where the existing theory of Lorentzian polynomial stability becomes the crucial ingredient. Recent work had established that the "spectral gap" of a Lorentzian distribution — the algebraic quantity that controls mixing speed — degrades gracefully under coefficient perturbations. If you have a gap of γ and you perturb the coefficients by a total of δ, the gap shrinks to at most γ - 2δ. As long as the perturbation is small enough, the gap remains positive, and the distribution retains its good properties.

The new result chains this perturbation stability together with explicit control on discretization error. For a density that is L-Lipschitz (meaning it doesn't oscillate too fast), the per-cell error from point-sampling versus exact integration is bounded by L×h×√n, where h is the grid spacing and n is the dimension. Summing over all cells in a box of side R gives a total coefficient distance that scales as O(h) — vanishing as the grid refines.

Combining these two estimates yields the transfer theorem:

> *If a continuous density has isoperimetric constant ψ > 0, and you discretize it on a grid of spacing h with error rate A, then the discrete distribution has a certified spectral gap of at least ψ - 2Ah, provided 2Ah < ψ.*

## What This Means for Algorithms

The practical consequence is immediate and striking. The spectral gap controls how fast Markov chain Monte Carlo (MCMC) algorithms converge. An MCMC algorithm with gap γ needs roughly (1/γ) × log(N) steps to produce a good sample from N states. So the transfer theorem gives a *certified upper bound* on the running time of discrete sampling algorithms, derived entirely from the continuous geometry of the target distribution.

For the standard Gaussian distribution on the plane — the familiar bell curve — the isoperimetric constant is ψ ≈ 0.399. Numerical experiments confirm that discretizing this Gaussian on a grid of spacing h = 0.125 preserves over 99% of the continuous gap, yielding a certified mixing time of a few thousand steps for thousands of grid cells. As the grid refines, the certified bound approaches the continuous optimum.

Even more remarkably, the theory provides an information-theoretic bonus. The KL divergence — a fundamental measure of the distance between probability distributions, central to machine learning and statistical physics — between the exact and approximate discretizations is bounded by O(h²/m), where m is the minimum cell mass. This creates a bridge not just between geometry and algorithms, but between geometry and information theory.

## The Hierarchy of Distances

One of the elegant features of this framework is the chain of inequalities connecting different ways to measure the discretization error:

**KL divergence ≤ χ² divergence ≤ (1/m) × (coefficient distance)²**

Each link in this chain has been proved rigorously. The first inequality (KL ≤ χ²) requires that both distributions sum to one — it exploits a beautiful cancellation that only works for probability measures. The second inequality (χ² ≤ (1/m) × L₁²) uses the minimum-mass condition to convert pointwise squared errors into a global bound.

This hierarchy is not just a curiosity. It means that a single computable quantity — the coefficient distance — simultaneously controls the geometric gap (through perturbation theory), the information-theoretic distance (through the KL bound), and the algorithmic complexity (through the mixing-time theorem). One measurement, three guarantees.

## Beyond the Gaussian

While the Gaussian provides the cleanest test case, the framework applies to any log-concave density: exponential distributions, uniform distributions on convex bodies, Gibbs measures at high temperature. The key requirement is an isoperimetric constant ψ > 0 and a Lipschitz bound on the density within the discretization region.

The theory extends naturally to higher dimensions, though with a caveat: the number of grid cells grows exponentially with dimension (the infamous "curse of dimensionality"), making brute-force discretization impractical for n much larger than about 10. But the theoretical bounds remain valid, and they provide the foundation for more sophisticated discretization schemes — adaptive grids, importance sampling, sparse representations — that might tame the dimensional explosion.

## A New Synthesis

What makes this work significant is not any single theorem but the synthesis it achieves. For the first time, three previously separate mathematical worlds are connected by a single rigorous pipeline:

1. **Continuous geometry** (isoperimetric inequalities, log-concavity)
2. **Discrete algebra** (Lorentzian polynomials, spectral gaps)
3. **Algorithmic complexity** (MCMC mixing times, certified convergence)

The bridge runs in one direction — from continuous to discrete — but it opens the door to a reverse engineering program: using discrete algebraic tools to attack continuous sampling problems, and using continuous geometric intuition to guide the design of discrete algorithms.

This is reminiscent of other great unifications in mathematics. Just as the Langlands program connects number theory and geometry, and just as information theory connects probability and communication, this work connects the geometry of continuous measures with the algebra of discrete stability. The individual pieces existed before. The new contribution is showing that they fit together, quantitatively and rigorously, into a single machine.

## Looking Forward

Several natural questions remain open. Can the error bounds be sharpened for specific distribution families? For the Gaussian, numerical evidence suggests that symmetry cancellation makes the actual error O(h²) rather than O(h) — a quadratic improvement that would dramatically extend the useful range of the discretization. Can adaptive grid strategies exploit local smoothness to reduce the effective number of cells? Can the pipeline be run in reverse, using discrete certificates to verify properties of continuous measures?

Perhaps most intriguingly: can this framework be extended to non-log-concave distributions? Many distributions of practical interest — multimodal posteriors in Bayesian inference, spin glasses in physics, energy landscapes in chemistry — violate log-concavity. The isoperimetric approach breaks down for these cases, but the perturbation stability of Lorentzian polynomials might still provide partial certificates.

The mathematics of discretization is as old as numerical analysis itself. But the idea that discretization can *certify* deep structural properties — not just approximate them — is genuinely new. It suggests that the gap between continuous and discrete mathematics, far from being a barrier, can be a source of rigorous guarantees. In an age of increasingly complex computational models, such guarantees are not a luxury. They are a necessity.
