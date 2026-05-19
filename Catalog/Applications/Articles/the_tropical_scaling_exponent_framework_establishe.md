# The Hidden Geometry That Controls How AI Learns

## Why some neural networks scale better than others — and how a branch of abstract mathematics finally explains it

---

In 2020, researchers at OpenAI published a striking observation: when you make a language model bigger, its performance improves in an eerily predictable way. Double the number of parameters and the error drops by a fixed percentage. Plot it on a log-log graph and you get an almost perfect straight line — a power law. The slope of that line, which researchers call the *scaling exponent*, seemed to encode something fundamental about how the system learns.

But nobody could explain *why*.

Different architectures — transformers, recurrent networks, state-space models — all exhibited power-law scaling, but with different exponents. Two networks could have completely different wiring diagrams yet produce identical scaling curves. Others, seemingly similar in structure, would diverge dramatically. The exponent appeared to be tied to the architecture's computational structure in some deep way, but the precise relationship remained a mystery.

Now, a new mathematical framework drawn from an unlikely corner of pure mathematics — *tropical geometry* — offers the first rigorous explanation. And the answer turns out to be surprisingly elegant: the scaling exponent is determined not by the specific weights or training procedure of a neural network, but by the *combinatorial geometry* of how information flows through it.

---

## The Map Is Not the Territory — But the Topology Is

To understand the breakthrough, you need to think of a neural network not as a collection of numbers (weights, biases, activations) but as a *directed graph* — a map of possible routes that information can take from input to output.

Imagine a city's road network. There are many possible routes from the airport to downtown, each with a different travel time that depends on distance, speed limits, and traffic. The *fastest route* at any given moment is the one you'd actually take. Now imagine scaling up the city: more roads, more intersections, more possible paths. The key question is: how does the travel time of the best route change as the city grows?

This is precisely the question that scaling laws ask about neural networks. Each "route" through the network is a computational pathway. Each pathway has a cost that depends on the network's size. The *envelope* — the minimum cost across all pathways — is what determines the network's actual performance at any given scale.

The crucial insight is that this minimum-of-linear-functions structure is exactly what tropical geometry was built to study.

---

## Tropical Geometry: Mathematics in a Parallel Universe

Tropical geometry sounds exotic, but its core idea is disarmingly simple. In ordinary algebra, the two fundamental operations are addition and multiplication. In tropical algebra, you replace addition with "take the minimum" and replace multiplication with "add." It's as if someone rewired the basic rules of arithmetic.

Why would anyone do this? Because in many optimization problems — shortest paths, scheduling, resource allocation — the natural operations *are* minimum and addition. When you're finding the shortest route through a network, you add up edge costs along each path and then take the minimum over all paths. That's tropical arithmetic, hiding in plain sight.

A *tropical polynomial* is a function that takes the minimum of several linear expressions. Graphically, it looks like a piecewise-linear curve — a zigzag of straight-line segments. The *tropical variety* (the set where two or more linear pieces tie for the minimum) marks the transition points where the dominant computational pathway changes.

What the new theory shows is that every computation graph naturally defines a tropical polynomial. The slopes of its linear pieces encode the scaling rates of different computational pathways. And the *minimum slope* — which controls what happens at very large scale — is the scaling exponent.

---

## The Uniqueness Theorem: One Exponent to Rule Them All

The first key result is a *uniqueness theorem*. Suppose you know that a system's performance, as a function of scale, is trapped between two parallel lines on a log-log plot (what mathematicians call an "affine sandwich"). The theorem proves that there is exactly one slope that can provide such a sandwich.

This might sound obvious, but it's not. A function can be bounded above and below by many different pairs of lines. What the theorem shows is that if the bounds are *asymptotically tight* — if they both have the same slope — then that slope is unique. No other slope can work.

The proof is clean: if two different slopes both provided valid sandwiches, then the gap between the upper bound of one and the lower bound of the other would grow linearly in scale. But the function is trapped between both, so no gap can grow. Contradiction.

This seemingly abstract result has a concrete consequence: the scaling exponent of any computational system with a well-defined tropical profile is not a matter of convention or curve-fitting — it is a mathematical invariant, uniquely determined by the system's asymptotic behavior.

---

## The Invariance Theorem: Architecture Doesn't Matter (Much)

The second, and more surprising, result is an *invariance theorem*. Two computation graphs are called *tropically equivalent* if they give rise to the same tropical profile — the same set of pathway cost functions. The theorem proves that tropically equivalent graphs necessarily have identical scaling exponents.

This is the mathematical formalization of a phenomenon that machine learning researchers have observed empirically but couldn't explain: architecturally different networks sometimes scale identically. The theorem says this happens precisely when their computational pathways, viewed through the tropical lens, are the same.

The implications are profound. It means that the scaling exponent is not a property of the *network* but of its *tropical equivalence class* — a much coarser classification. Many different networks can share the same class. This explains why seemingly different architectures (a simple chain and a diamond-shaped graph, for instance) can exhibit identical scaling behavior: they are tropically equivalent, and the theorem guarantees the rest.

---

## The Composition Laws: An Algebra of Scaling

Perhaps the most powerful results are the *composition laws*. They describe what happens to scaling exponents when you combine systems.

**Serial composition** (stacking two systems end-to-end): the scaling exponent of the combined system equals the *sum* of the individual exponents. This makes intuitive sense — if each stage slows things down by its own rate, the total slowdown is cumulative.

**Parallel composition** (running two systems side by side and taking the better result): the scaling exponent equals the *minimum* of the individual exponents. The better-scaling system dominates at large scale.

These two laws together form a complete algebraic calculus for scaling exponents. Given any architecture built from serial and parallel composition, you can compute its scaling exponent by walking the structure and combining exponents with addition and minimum.

This immediately explains one of the most celebrated phenomena in deep learning: *why residual networks scale better than plain deep networks*. A residual network is, in tropical terms, a plain serial backbone placed in parallel with skip connections. The parallel composition law says the overall exponent is the minimum of the backbone exponent and the skip exponent. Since skip connections typically have small exponents (they're computationally cheap), the residual network's exponent is dominated by the skip — it inherits the best scaling, regardless of how deep the backbone goes.

This isn't a heuristic explanation or an empirical correlation. It's a theorem.

---

## From Descriptive to Predictive

The composition laws transform the tropical framework from a descriptive tool (measuring exponents after the fact) into a *predictive* one (computing exponents before training). If you know the tropical profile of each component — each layer, each attention head, each feed-forward block — you can predict the scaling exponent of any architecture assembled from those components, using nothing more than addition and minimum.

This has immediate practical implications for architecture design. Instead of training hundreds of candidate architectures to discover which scales best, you can compute their tropical profiles and select the winner algebraically. The search space collapses: architectures in the same tropical equivalence class are guaranteed to have the same exponent, so you only need to evaluate one representative per class.

In one illustrative example, nine candidate architectures (including variants of MLPs, CNNs, transformers, and state-space models) collapsed to just five tropical equivalence classes — a 44% reduction in the search space with zero loss of information about scaling behavior.

---

## The Bigger Picture: A New Mathematical Language

What makes this work feel like the beginning of something larger is that it connects several mathematical traditions that have never been brought together in this way.

The *tropical geometry* community has spent decades developing the theory of piecewise-linear analogs of algebraic geometry. The *scaling laws* community has spent years cataloging empirical power laws in machine learning. The *circuit complexity* community has long studied how computational depth and width affect what's computable. And the *statistical physics* community has a century of experience with universality classes — the idea that wildly different systems can exhibit identical critical exponents because they share the same fundamental symmetries.

The tropical scaling exponent framework ties all of these threads together. Tropical equivalence classes function exactly like universality classes in physics: they group together systems that look different microscopically but behave identically at large scale. The composition laws play the role of renormalization group equations, telling you how exponents transform under changes of scale or structure.

This parallel to physics is not merely metaphorical. In statistical mechanics, the critical exponent of a phase transition is determined by the *symmetry class* of the system, not by its microscopic details. A magnet made of iron and one made of nickel have the same critical exponent because they share the same symmetry. Analogously, the scaling exponent of a neural network is determined by its tropical equivalence class, not by its specific weights or training dynamics. Two architectures with the same tropical profile scale identically, regardless of how different they look at the level of individual parameters.

---

## What Comes Next

The current results establish the foundation — uniqueness, invariance, and composition — but the theory is rich with unexplored directions.

One tantalizing question is whether tropical structure predicts not just the *leading* scaling exponent but also the *corrections*: the logarithmic factors and sub-leading terms that distinguish a clean power law from a slightly modified one. In physics, these corrections are where the real information lives — they separate universality classes within a given leading exponent. Preliminary analysis suggests that the *multiplicity* of dominant tropical pathways (how many forms tie for the minimum slope) may encode the degree of logarithmic correction, but this remains to be proven.

Another direction is the connection to computational complexity. A computation graph is a Boolean circuit, and the tropical scaling exponent is an asymptotic invariant of that circuit's scaling behavior. Could tropical exponents serve as new complexity measures for learning systems, complementing classical measures like circuit depth and size?

And then there's the most ambitious question of all: can we classify all possible scaling behaviors of computation graphs, the way physicists have classified all possible universality classes for phase transitions? The tropical framework provides the language for asking this question precisely. Whether it provides the answer remains to be seen.

---

## A Theorem for the Age of Scale

We live in an era where the dominant strategy in artificial intelligence is *scale* — make the model bigger, train it on more data, and watch the loss curve drop. Scaling laws are the empirical heartbeat of this paradigm, governing billions of dollars of compute allocation.

Yet until now, these laws have been observations without explanations — patterns in data without structural reasons. The tropical universality theorems change that. They provide the first mathematical proof that scaling exponents are not accidents of training but consequences of architecture, determined by the combinatorial geometry of computation.

That's a rare thing: a piece of pure mathematics that speaks directly to the most consequential technology of our time. It doesn't just describe what happens when you scale up a neural network. It explains *why*.
