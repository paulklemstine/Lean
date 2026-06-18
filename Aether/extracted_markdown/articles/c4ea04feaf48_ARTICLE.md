# The Staircase to Pi: How Neural Networks Climb Toward Irrational Numbers

**Can a machine made of straight lines capture a number that never repeats?**

Imagine building a staircase. Each step is perfectly flat — a horizontal line. With ten steps, you can make a rough approximation of a ramp. With a thousand, it looks almost smooth. With a million, you'd swear it was a perfect slope.

Now imagine something harder: instead of approximating a slope, you're trying to land on a single, infinitely precise point — the number π, that strange constant hiding inside every circle, every wave, every oscillation in the universe. Your staircase isn't climbing a hill. It's trying to reach a destination that, mathematically speaking, requires infinite information to describe exactly.

This is the challenge at the heart of a surprising collision between two fields that rarely speak to each other: the ancient mathematics of approximating irrational numbers, and the modern engineering of artificial neural networks.

## The Simplest Neural Network You Can Build

The most common neural network in use today — the kind powering image recognition, language translation, and scientific simulations — is built from a single, almost embarrassingly simple operation: take a number, and if it's negative, replace it with zero. If it's positive, leave it alone.

This operation is called ReLU, short for Rectified Linear Unit, and it's the workhorse of modern AI. Mathematically, ReLU(x) = max(0, x). That's it. That's the building block of systems that can recognize faces, drive cars, and fold proteins.

When you stack layers of these simple operations, something remarkable happens. Each layer can create a "kink" — a point where the output changes direction. A single layer with *w* neurons can create up to *w* kinks. But a second layer, also with *w* neurons, can create up to *w²* kinks. A third: *w³*. In general, *L* layers of width *w* can produce up to *w^L* kinks.

The output of such a network is a piecewise linear function — a series of straight-line segments joined at kinks. And the number of these segments grows *exponentially* with depth.

This exponential growth is the key to everything that follows.

## An Ancient Problem in Modern Clothing

Long before anyone imagined neural networks, mathematicians were obsessed with a deceptively simple question: how well can you approximate irrational numbers using fractions?

The ancient Greeks knew that 22/7 was a decent approximation to π. The fraction 355/113 is even better — it's accurate to six decimal places. But no fraction will ever equal π exactly. The question is: how close can you get, and how complicated does the fraction need to be?

In 1842, Peter Gustav Lejeune Dirichlet proved a beautiful theorem: for any irrational number α and any positive integer N, there exists a fraction p/q with q ≤ N such that |α - p/q| < 1/N. In other words, you can always find a "simple" fraction (with a small denominator) that's surprisingly close to any irrational number.

The connection to neural networks is immediate. A piecewise linear function with N segments on an interval can represent any fraction with denominator at most N. So a ReLU network with w^L pieces can approximate any real number to within 1/w^L.

This means the problem of approximating constants with neural networks is really a *Diophantine approximation problem* — a question about how rational numbers cluster around irrational ones. It's a 200-year-old mathematical framework applied to technology invented in the 2010s.

## The Depth Advantage

Here's where the mathematics becomes genuinely surprising.

Consider two ways to build a neural network with 1000 parameters. Option A: a very wide, shallow network — say, width 500 and depth 1. Option B: a narrow, deep network — width 10 and depth 50.

Option A produces at most 500 linear pieces. Option B produces up to 10^50 — a number with 50 digits. That's not just "more." That's incomprehensibly more. The deep network, with the same parameter budget, has an expressivity advantage that dwarfs the difference between an ant and the observable universe.

This "exponential depth advantage" has been proved rigorously: for any width w ≥ 2, the piece count w^L is always at least L+1, and for L ≥ 1, it satisfies w^L ≥ w·L. These aren't just theoretical curiosities — they explain why deep learning works so much better than shallow learning in practice.

The proof uses mathematical induction, that elegant technique where you prove something for the first case, then show that if it works for case *n*, it must work for case *n+1*. The dominos fall forever.

## Climbing Toward Pi

So how do you actually use a neural network to approximate π?

The Leibniz formula, discovered independently by Gottfried Wilhelm Leibniz and the Indian mathematician Madhava of Sangamagrama (who found it 300 years earlier), gives us:

π/4 = 1 - 1/3 + 1/5 - 1/7 + 1/9 - ...

This alternating series converges to π/4, and the error after N terms is bounded by the first omitted term: at most 1/(2N+1). This is the alternating series criterion, one of the first theorems students learn in calculus.

A ReLU network with w^L ≥ N pieces can represent the partial sum of the first N terms. The error in approximating π is then at most 4/(2N+1).

To get within ε of π, we need N ≥ roughly 2/ε terms, which requires a network with w^L ≥ 2/ε pieces. For width w = 2, this means depth L ≈ log₂(2/ε). To approximate π to 10 decimal places, we need depth about 34. To reach 100 decimal places, depth about 333.

But here's a conjecture that's even more interesting: by using smarter series (like Machin's formula), we might need only O(log(log(1/ε))) layers — a *double logarithm* of the precision. That would mean approximating π to a billion decimal places might require a network with only about 30 layers.

## The Tropical Connection

There's a beautiful hidden structure linking ReLU networks to a branch of mathematics called tropical geometry.

In tropical arithmetic, "addition" is replaced by taking the maximum, and "multiplication" is replaced by ordinary addition. Under this strange-sounding algebra, the ReLU function becomes the most natural operation possible: it's just tropical addition of zero and the input.

This means that every ReLU network is secretly computing a *tropical rational function* — a ratio of tropical polynomials. The number of "terms" in this tropical expression equals exactly the number of linear pieces in the network's output.

This isn't just a cute observation. It connects the approximation theory of neural networks to the deep waters of algebraic geometry, where tropical methods have been solving problems in enumerative geometry, optimization, and even phylogenetics (the study of evolutionary trees).

## What the Numbers Tell Us

When you actually build these networks and measure the approximation error, striking patterns emerge.

Different mathematical constants require different levels of effort:
- **e** (Euler's number, ≈ 2.718) converges factorially fast via its Taylor series. Each additional term reduces the error by a factor of roughly N. A network with 20 pieces can approximate e to 16 decimal places.
- **√2** converges quadratically via Newton's method. Each iteration doubles the number of correct digits. Fewer than 60 pieces suffice for machine precision.
- **π** converges only algebraically via the Leibniz series. Error decreases as 1/N, meaning you need 10× more pieces for each additional decimal digit.

These differences reflect a deep number-theoretic property: the *irrationality measure* of each constant. Almost all irrational numbers (including π, e, and √2, as far as we know) have irrationality measure 2, meaning they can't be approximated by rationals much better than Dirichlet's bound predicts. But the *series* used to compute them have very different convergence rates, and this is what determines the network size.

## A New Lens on an Old Question

What makes this research direction compelling is not any single theorem, but the *collision of perspectives* it forces.

Number theorists have spent centuries understanding how well rationals approximate irrationals. Computer scientists have spent decades understanding the power of depth in neural networks. Tropical geometers have been building algebraic tools for piecewise linear objects. These communities have been working on deeply related problems without knowing it.

The bridge is ReLU. A single function — max(0, x) — connects approximation theory, network architecture, and tropical algebra into a unified framework where theorems in one domain become theorems in the others.

The exponential depth advantage isn't just an engineering hack. It's a mathematical fact about the geometry of piecewise linear functions, and it has consequences for how hard it is to approximate specific numbers. The Leibniz series error bound isn't just a calculus exercise. It's a statement about the minimum complexity of a neural network that can output π.

## What Comes Next

Several tantalizing questions remain open:

**Is the Leibniz bound tight?** We know that N terms of the Leibniz series give error at most 1/(2N+1). But is this the best a piecewise linear function with N pieces can do for π? Or could a cleverly designed network do exponentially better?

**What about the depth conjecture?** The claim that O(log(log(1/ε))) layers suffice — using fast-converging series — is computationally testable but not yet proved. It would mean that the depth needed to approximate any computable constant grows unbelievably slowly with precision.

**Can tropical geometry help design better networks?** If every ReLU network is a tropical rational function, then the problem of finding the optimal network for a given task is really a problem in tropical algebraic geometry. This could lead to entirely new network design principles.

The staircase to π has infinitely many steps. But the mathematics of how we build those stairs — how many, how wide, how deep — turns out to be a story that connects some of the oldest questions in mathematics to some of the newest tools in artificial intelligence.

And sometimes, the deepest insights come from asking the simplest questions: how do you make straight lines bend toward an irrational truth?
