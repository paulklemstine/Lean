# The Hidden Architecture of Rules: How Boundary Observations Can Reveal Internal Machinery

## A Lock with a Transparent Door

Imagine you're standing outside a locked room. Inside, an unknown machine takes inputs and produces outputs according to hidden rules. You can't open the door, but you can slide messages under it and observe what comes back. Here's the question that has fascinated mathematicians and physicists for over a century: **Can the responses you see from outside completely determine the machine inside?**

This is the essence of an *inverse problem* — deducing hidden structure from external observations. Doctors do it when they reconstruct the interior of a body from X-ray shadows. Geophysicists do it when they map underground rock layers from seismic wave echoes. And now, a new mathematical framework shows that a surprisingly similar principle operates in a domain far removed from medicine or geology: the abstract world of logical rules and computational costs.

The result is striking. For a broad class of rule-based systems — the kind that power everything from database queries to supply-chain logistics — the "boundary response" (what you can observe from outside) doesn't just summarize the internal rules. Under the right conditions, it *completely determines* them, up to a harmless relabeling. The internal machinery has nowhere to hide.

## The Language of Costs

To understand the breakthrough, we first need a simple but powerful idea from an area of mathematics called *tropical algebra*.

In ordinary arithmetic, two basic operations dominate: addition and multiplication. Tropical algebra replaces these with a different pair: **minimum** and **addition**. Instead of asking "what's the total?" you ask "what's the cheapest?" Instead of multiplying costs, you add them up along a path. This might sound like a minor tweak, but it transforms the mathematical landscape in profound ways.

Think of it like planning a road trip. You don't care about the *sum* of all possible routes — you care about the *cheapest* one. Tropical algebra is the mathematics of optimization, stripped down to its essence.

Now imagine a factory floor with several machines. Each machine takes a partially assembled product and adds certain components, but at a specific cost. You want to figure out the cheapest sequence of machines to run in order to produce a finished product from raw materials. This is exactly the kind of problem that tropical algebra was born to handle.

In mathematical language, we have a set of "generators" (the machines), each with an "output set" (the components it adds) and a "weight" (its cost). The *propagation cost* from one state to another is the minimum total weight of generators needed to get there. It's addition along paths, minimized over all possible paths — the twin operations of tropical algebra in action.

## Boundaries and Interiors

The key insight comes from splitting the world into two parts: what you can see, and what you can't.

Call the observable part the **boundary** and the hidden part the **interior**. In our factory analogy, the boundary might be the finished products that roll off the assembly line, while the interior is the factory floor itself — the arrangement of machines, their sequences, their interconnections.

For each machine, we can ask: which boundary products does it contribute to? This is its *boundary signature* — a fingerprint of its observable effects. And its weight is the cost of running it. Together, the signature and weight form the machine's *boundary identity card*.

The collection of all these identity cards — one per machine — is the **boundary data** of the system. It's everything an outside observer could learn by watching what the factory produces and at what cost.

## The Rigidity Theorem

Here is the central discovery: **if two factories are properly organized, and they produce exactly the same boundary data, then they must be the same factory — just with the machines relabeled.**

"Properly organized" means two things. First, every machine must actually affect what you can see from outside (no purely internal machines with zero external impact — those are invisible and thus undetectable). Second, no two machines with identical external effects and identical costs exist (that would create ambiguity in the labeling).

Under these conditions — which mathematicians call "normal form" — the boundary data acts as a complete fingerprint. Two systems with matching fingerprints must be structurally identical. There's no way to hide a different internal arrangement behind the same external behavior.

This is more surprising than it might first appear. In many mathematical settings, very different internal structures can produce identical external observations. Think of how many different electrical circuits can produce the same input-output voltage relationship. Or how many different probability distributions can have the same mean and variance. Usually, external observations *under-determine* the internal structure.

But in the tropical setting — the world of minimum-cost optimization — something special happens. The "minimum" operation is so aggressive in selecting the cheapest option that it leaves a detailed fingerprint. Each generator's contribution to the boundary is sharply delineated, not blurred by averaging or summing. The boundary response is a high-resolution image of the interior, not a blurry summary.

## Reconstruction: Building the Machine from Its Shadow

The rigidity theorem tells us that the internal structure is *determined* by boundary data. But can we actually *reconstruct* it?

Yes. Given any valid set of boundary data — a collection of signature-weight pairs satisfying basic consistency conditions — there is a canonical procedure that builds a system realizing that data. The procedure is almost embarrassingly simple: just use the boundary data itself as the blueprint. Each data point becomes a generator, with its signature as the output set and its listed weight as the cost.

The reconstructed system is automatically in normal form, and it faithfully reproduces the original boundary data. Moreover, any other normal-form system with the same boundary data must be gauge-equivalent to this canonical reconstruction — meaning it's the same system up to relabeling of generators.

This is a constructive version of the rigidity theorem. It doesn't just say "the interior is determined" — it says "here's how to build it."

## The Holographic Principle, Discretized

Physicists will recognize an echo of one of the deepest ideas in modern theoretical physics: the **holographic principle**. In its original form, proposed by Gerard 't Hooft and Leonard Susskind in the 1990s, the holographic principle states that all the information contained in a volume of space can be encoded on the boundary of that region. A three-dimensional reality is fully described by a two-dimensional surface — like a hologram.

The mathematical framework described here is a discrete, rigorous analogue of this idea. The "bulk" is the hidden interior of the weighted closure system — the generators, their outputs, their costs. The "boundary" is the observable surface. And the rigidity theorem says: the boundary theory completely determines the bulk, up to gauge.

The word "gauge" is borrowed from physics, too. In gauge theory, certain transformations of the mathematical description leave all physical observables unchanged. Relabeling the generators of a closure system is precisely such a transformation: it changes the names but not the substance. The rigidity theorem says that gauge is the *only* ambiguity. Everything physically (or computationally) meaningful about the system is captured at the boundary.

## Why It Matters

The practical implications span several fields.

**In database theory and logic programming**, closure systems model inference engines: given some known facts (the seed), what new facts can be derived, and at what computational cost? The rigidity theorem says that the external query-response behavior of an inference engine determines its internal rule set. You can reverse-engineer the rules from the responses.

**In supply chain and logistics**, weighted closure systems model production networks: which components can be assembled from which inputs, at what cost? The theorem says that if two supply chains produce identical cost structures for all boundary products, they must be structurally the same network (up to relabeling). There's no way to hide inefficiency behind a good-looking boundary.

**In network analysis**, the propagation cost function behaves like a tropical metric — a notion of distance where "shortest path" replaces "straight line." The boundary kernel is then a tropical analogue of the Dirichlet-to-Neumann map, a fundamental object in electrical impedance tomography (the medical imaging technique that reconstructs internal conductivity from surface measurements). The rigidity theorem is a discrete tropical version of the Calderón inverse conductivity problem.

**In the foundations of artificial intelligence**, closure systems with costs are models of weighted reasoning: given evidence (the seed), what conclusions can be drawn, and how expensive is each inferential path? The boundary rigidity theorem says that the *observable reasoning behavior* of an AI system — its input-output function — determines its internal inferential structure. This is a mathematically precise version of the question "can you understand an AI by watching what it does?"

## The Entropy Profile

Beyond the boundary data set, there's an even more compressed summary: the **entropy profile**. For each integer k, the entropy profile records the minimum cost of any generator that affects at least k boundary elements. It's a monotone staircase function — more coverage always costs at least as much.

This profile behaves like a zero-temperature entropy in statistical physics. At "temperature zero," only the minimum-energy (minimum-cost) state survives, and the entropy measures the growth rate of accessible states as a function of some parameter. Here, the parameter k counts boundary coverage, and the profile measures the cost threshold.

The entropy profile is a coarser invariant than the full boundary data — it records costs but forgets which specific boundary elements are involved. Yet it still carries significant structural information, and in future work it may be possible to show that the entropy profile, combined with collision-freeness conditions, determines the tropical rank filtration of the boundary kernel.

## Looking Forward

This work opens several research directions. The immediate next step is to extend the rigidity theorem from single-step generators to multi-step propagation dynamics, where sequences of generators build up complex closures over time. The single-step result is the foundation, but the multi-step version would handle realistic computational and physical systems.

A deeper direction is to replace the min-plus semiring with a "finite-temperature" deformation — using soft-minimum (log-sum-exp) instead of hard minimum. This would connect the tropical framework to partition functions in statistical physics and to variational inference in machine learning, creating a bridge between discrete optimization and continuous probability.

Perhaps the most ambitious direction is to establish the boundary-to-bulk correspondence as a formal categorical equivalence: not just a bijection between individual systems and their boundary data, but a structure-preserving correspondence between entire categories of systems and categories of boundary theories. This would make the holographic analogy precise at the deepest mathematical level.

The tools are ready. The boundary has spoken. And it turns out, it has been telling us everything all along.
