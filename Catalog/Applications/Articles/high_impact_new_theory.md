# The Hidden Mathematics of Information Loss

## When You Blur an Image, What Exactly Disappears?

Every time you compress a photo, downsample a signal, or pool features in a machine learning model, something is lost. We all know this intuitively — a thumbnail can't contain as much information as the original image. But *how much* is lost? And is there a fundamental mathematical law governing this loss?

In 1961, Claude Shannon's student Jack Blackwell proved that no amount of clever post-processing can recover information that has been thrown away. This principle — the *data processing inequality* — became one of the foundational theorems of information theory. It says, roughly: if you have a noisy communication channel, applying any deterministic function to its output can only destroy information, never create it.

For sixty years, this principle has lived in the world of probability and logarithms. Shannon's information theory is built on averages, expectations, and the delicate machinery of probability distributions. But there exists a parallel mathematical universe — one built not on averages but on *extremes* — where addition becomes maximum and multiplication becomes addition. Welcome to tropical mathematics.

## The Strange World of Max-Plus

Imagine a world where "adding" two numbers means taking the larger one, and "multiplying" means ordinary addition. In this world, 3 ⊕ 5 = 5 (we take the max), and 3 ⊗ 5 = 8 (we add). This sounds like a mathematical curiosity, but it turns out to describe an enormous range of real phenomena.

Every time you ask for the shortest path in a navigation app, you're doing tropical arithmetic. When a logistics company optimizes delivery routes, the minimum over all paths of the maximum delay along each path is a tropical calculation. When engineers analyze the worst-case timing of a digital circuit, they're computing in the tropical semiring. The optimization problems that dominate engineering, economics, and computer science naturally speak the language of maxima and minima rather than sums and products.

Tropical mathematics — named whimsically after the Brazilian mathematician Imre Simon — has developed into a sophisticated field with its own geometry, algebra, and analysis. Tropical curves look like spiderwebs of line segments. Tropical polynomials are piecewise-linear functions. The entire apparatus of classical algebraic geometry has a tropical shadow, and this shadow often reveals structure that was invisible in the original.

But one domain remained stubbornly untouched: information theory. Could the data processing inequality — that foundational statement about information loss — have a tropical analogue?

## Measuring Distinguishability, Not Probability

The breakthrough required rethinking what "information" means. In Shannon's theory, information is measured using entropy, which quantifies the average surprise in a random variable. But averages don't exist in the tropical world. There's no expectation operator when your algebra replaces addition with maximum.

The key insight was to abandon entropy and focus instead on *distinguishability*. Consider a communication channel — a system that takes inputs and produces outputs. The question isn't "how much randomness flows through?" but rather "how well can we tell inputs apart by looking at the outputs?"

Think of it this way: suppose you have a security system with multiple sensors, and each sensor produces a reading when different people approach. The *tropical distinguishability* between two people is the maximum difference in sensor readings, summed over both directions. It captures the worst-case spread — not the average behavior, but the extremal separation.

More precisely, for a channel with weight matrix *K* (think of the rows as different inputs and columns as different outputs), the tropical distinguishability between inputs *x₁* and *x₂* is:

> δ(*x₁*, *x₂*) = max over outputs *y* of [*K*(*x₁*, *y*) − *K*(*x₂*, *y*)] + max over *y* of [*K*(*x₂*, *y*) − *K*(*x₁*, *y*)]

The first term measures how much *x₁* can dominate *x₂* at the best output; the second measures the reverse. Together, they capture the total separation between the two inputs as seen through the channel.

The *tropical mutual information* is then the maximum distinguishability over all pairs of inputs — the diameter of the input space as measured through the channel's lens.

## The Theorem That Opens a Field

With these definitions in place, the central theorem becomes precise: **deterministic post-processing cannot increase tropical mutual information.**

If you take a channel and coarsen its outputs — merging some outputs together — the tropical mutual information can only decrease. This is exactly the data processing inequality, but in the tropical world.

The proof is elegant in its structure. It proceeds in three steps:

**Step 1.** When you merge outputs by a deterministic map *g*, the post-processed channel takes the maximum of the original weights over each fiber (the set of original outputs that map to the same coarsened output). This is the tropical analogue of marginalization.

**Step 2.** The one-sided separation — the max of differences — contracts under this merging. Why? Because the maximum of a set of differences is at most the maximum of a set containing even more differences. Formally, the supremum over a subset is at most the supremum over the full set.

**Step 3.** Since both one-sided separations contract, the full distinguishability contracts. And since every pair contracts, the overall maximum contracts too.

Each step is individually simple, but their composition establishes something profound: there exists a monotone resource theory in tropical mathematics, with information as the conserved (more precisely, non-increasing) quantity.

## Beyond the First Theorem

The data processing inequality is just the beginning. A second theorem — proved in the same framework — establishes that tropical mutual information is *additive* under tensor products. When you combine two independent channels in parallel (in the tropical sense, where the combined weight is the sum of individual weights), the total tropical information is exactly the sum of the individual informations.

This additivity is actually *stronger* than what holds in Shannon's theory, where mutual information is only subadditive under tensor products. The tropical world is, in some sense, better behaved.

These two properties — monotonicity under coarse-graining and additivity under parallel composition — are precisely what you need to build a coding theory. They tell you that information is a well-behaved resource: it flows downhill through processing pipelines, and it adds up correctly when you combine independent sources.

## What This Means for Real Technology

The implications ripple outward in several directions.

**Neural networks.** Modern deep learning relies heavily on max-pooling layers, which compute the maximum over spatial neighborhoods. These are exactly tropical post-processing operations. The tropical data processing inequality provides certified bounds on how much discriminative information each pooling layer destroys. For the first time, we have a rigorous framework — not based on probabilistic assumptions but on worst-case guarantees — for quantifying representation bottlenecks in neural architectures.

**Cryptographic hashing.** A hash function maps a large input space to a smaller output space, deterministically. The tropical DPI immediately implies that hashing reduces the tropical distinguishability of inputs. This gives collision resistance bounds: if the original inputs were well-separated, the hash can only bring them closer together, never push them further apart. The quantitative bound tells you exactly how much separation survives.

**Sensor fusion.** When multiple sensors observe the same scene independently, the tensor additivity theorem says the combined system's information is exactly the sum of individual sensors' information. This provides a precise framework for sensor network design: you can predict the information gain from adding a new sensor without having to analyze the combined system from scratch.

**Optimization under uncertainty.** Many robust optimization problems naturally involve max-min operations — minimizing the worst case over uncertainties, maximizing the best case over decisions. These are tropical operations. The data processing inequality provides a principled way to reason about information loss in hierarchical optimization, where high-level decisions are made based on coarsened summaries of lower-level data.

## A Mathematical Genealogy

This work sits at a remarkable crossroads. Tropical geometry, pioneered by researchers like Grigory Mikhalkin and Bernd Sturmfels, has transformed algebraic geometry by revealing combinatorial skeletons underneath smooth algebraic varieties. Information theory, founded by Shannon in 1948, has shaped the entire digital age. Monotone resource theories, formalized in quantum information theory by researchers like Bob Coecke and Gilad Gour, provide the abstract framework for irreversible processes.

The tropical data processing inequality is, as far as we can tell, the first theorem that rigorously connects all three traditions. It takes the resource-theoretic structure of information theory, transplants it into the algebraic framework of tropical mathematics, and proves that the resulting theory is nontrivial and well-behaved.

What makes this particularly exciting is that the tropical world is, in many ways, simpler than the probabilistic world. There are no integrability conditions to check, no measure-theoretic subtleties, no concerns about convergence. Everything is finite, combinatorial, and computable. This simplicity doesn't come at the cost of power — the theorems are sharp and the applications are genuine.

## The Road Ahead

Several frontiers are immediately accessible. A *tropical channel capacity* — the supremum of tropical mutual information over all possible input configurations — would provide the tropical analogue of Shannon's channel capacity theorem. Tropical f-divergences would generalize the distinguishability to a family of separation measures, each with its own data processing inequality. Tropical Markov chains, defined through iterated max-plus matrix multiplication, could yield mixing time bounds in the tropical setting.

Perhaps most intriguing is the connection to zero-temperature limits in statistical physics. Classical entropy and free energy involve logarithms of partition functions — sums of Boltzmann weights. In the zero-temperature limit, these sums are dominated by their maximum terms, and the mathematics becomes tropical. The tropical data processing inequality may therefore be the zero-temperature shadow of thermodynamic irreversibility.

The ancient observation that information, once lost, cannot be recovered turns out to have a twin in the mathematics of extremes. Tropical algebra doesn't just parallel probability theory — it reveals a structural truth about information that transcends the framework in which it was originally discovered. The data processing inequality isn't about probability at all. It's about the geometry of coarse-graining, the mathematics of merging and forgetting. And that mathematics speaks tropical.
