# When Functions Forget: The Hidden Thermodynamics of Information Loss

*Every function destroys information. A new mathematical theory measures exactly how much.*

---

In 1961, the physicist Rolf Landauer made a startling observation: erasing a single bit of information in a computer requires a minimum amount of energy — about 3 × 10⁻²¹ joules at room temperature. This tiny but irreducible cost, now known as Landauer's principle, revealed a deep connection between information and physics. Computation isn't free. Forgetting has a thermodynamic price.

But what, exactly, does it mean for a computation to "forget"?

Consider a simple example. You have a list of cities — New York, Paris, Tokyo, London — and you ask: "Which continent is each city on?" The answer — North America, Europe, Asia, Europe — collapses four distinct items into three. London and Paris, which were distinguishable before, are now identified: both are simply "Europe." Information has been lost. The function "which continent?" has an irreversible quality to it: knowing the continent, you can't recover the city.

This is the essence of a new mathematical concept called **functorial entropy**: a precise measure of how much information any function destroys.

## The Anatomy of Forgetting

The key insight is simple but powerful. When a function maps inputs to outputs, it creates **fibers** — groups of inputs that all land on the same output. The function "which continent?" maps both Paris and London to Europe, creating a fiber of size 2 over Europe, while New York and Tokyo each sit alone in fibers of size 1.

Functorial entropy is built from these fibers. If a function f maps from a set of N elements, and the fiber over each output b has size nᵦ, then:

**H(f) = Σ (nᵦ / N) × log(nᵦ)**

Each fiber of size 1 contributes zero — no information is lost when an input maps uniquely to an output. But fibers of size 2 or more contribute a positive amount proportional to the logarithm of the fiber size. The bigger the collapse, the more entropy.

## The Zero Theorem

The most fundamental result in the theory is the **zero characterization theorem**: the entropy of a function is exactly zero if and only if the function is injective — that is, no two inputs map to the same output.

This isn't just a formal curiosity. It captures a deep truth: **the only way to lose no information is to lose no information.** There are no half-measures. If even two elements collapse to the same output, the entropy is strictly positive. Every non-injective function has a measurable, positive cost.

The proof works by showing that each summand in the entropy formula is non-negative (since weights and logarithms of integers ≥ 1 are both non-negative). If the total is zero, every summand must vanish, which forces every fiber to have size at most 1 — precisely the condition for injectivity.

## The One-Way Street of Composition

Perhaps the most surprising discovery is the **composition monotonicity theorem**: if you compose two functions — first apply f, then apply g — the total information lost can only increase compared to what f alone loses.

**H(g ∘ f) ≥ H(f)**

In other words, adding another processing step can never *recover* lost information. This is the mathematical shadow of the Second Law of Thermodynamics applied to data processing. Just as entropy in physics can only increase in an isolated system, information loss in a data pipeline can only accumulate.

The proof reveals why: when you compose g with f, the fibers of the composition are *unions* of fibers of f. The function g merges some of f's fibers together. And merging always increases entropy, thanks to a fundamental inequality about the function t × log(t): for any non-negative numbers a and b,

**(a + b) × log(a + b) ≥ a × log(a) + b × log(b)**

This superadditivity of t × log(t) is the engine that drives the monotonicity theorem. It says that combining two groups of items produces more "weighted surprise" than keeping them separate.

## The Shannon Bridge

Classical information theory, founded by Claude Shannon in 1948, measures the uncertainty of a random variable through a quantity called Shannon entropy. Functorial entropy turns out to be intimately related:

**H(f) = log|α| − H_Shannon(fiber distribution)**

The functorial entropy is the gap between the maximum possible information content (log of the domain size) and the Shannon entropy of the fiber distribution. This bridge connects the new theory to 75 years of information-theoretic results, giving it immediate access to a vast mathematical toolkit.

## From Functions to Functors

What makes this theory truly novel is its categorical dimension. In modern mathematics, the concept of a "functor" generalizes functions to preserve the structure of entire mathematical universes (called categories). A functor F between two categories maps not just objects but also the relationships (morphisms) between them.

Every functor has an entropy — a measure of how much structural information it destroys. The identity functor, which maps every object to itself, has zero entropy. But a functor that collapses many objects onto one has high entropy.

The composition monotonicity theorem lifts seamlessly to functors: composing two functors can only increase the total information loss. This creates a hierarchy of information destruction across all of mathematics.

## The Landauer Connection

The theory circles back to physics through Landauer's principle. The **Landauer cost** of a computation f at temperature T is:

**Cost = kT × H(f)**

where k is Boltzmann's constant. A bijective (reversible) computation has zero Landauer cost — no energy need be dissipated. But any irreversible computation, any function that collapses fibers, incurs a minimum thermodynamic cost proportional to its functorial entropy.

This means functorial entropy isn't just an abstract mathematical measure. It's the number that Nature charges you for forgetting.

## A Thermodynamic Arrow for Data

The composition monotonicity theorem, combined with the Landauer connection, implies something profound: **data pipelines have a thermodynamic arrow.** As data flows through successive processing stages, the cumulative information loss can only increase, and the minimum energy cost of the pipeline can only grow.

This has practical implications for computing architecture. If you want to minimize energy consumption, you should delay irreversible operations as long as possible. Reversible computations are free (in the thermodynamic sense); every non-injective step costs energy proportional to the information it destroys.

## Uniform Fibers and Maximum Entropy

When all non-empty fibers of a function have the same size k, the entropy takes its simplest form:

**H(f) = log(k)**

This is the "uniform" case, and it achieves the maximum entropy for a given fiber size. A function that collapses pairs (k = 2) has entropy log(2) ≈ 0.693 nats. One that collapses triples has entropy log(3) ≈ 1.099 nats. The logarithm ensures that doubling the collapse doesn't double the entropy — information loss scales logarithmically.

## Looking Forward

Functorial entropy opens several research directions. The **composition superadditivity conjecture** — that composing with a surjection always increases entropy — remains open and connects to deep questions about the log-sum inequality. The theory's extension to infinite categories promises connections to ergodic theory and quantum information. And the entropy of specific functors — the forgetful functor from topological spaces to sets, the abelianization functor from groups to abelian groups — may reveal quantitative aspects of mathematical structure that have never been measured before.

At its core, functorial entropy offers a unified language for a phenomenon that pervades mathematics, physics, and computer science: the irreversible loss of distinction. Every time we abstract, simplify, project, or coarsen, we lose information. Functorial entropy tells us exactly how much.

---

*The mathematics of information loss continues to reveal connections between abstract algebra, thermodynamics, and computation — suggesting that the price of forgetting is written into the fabric of mathematics itself.*
