# Peeling Information Apart: How Mathematicians Learned to Decompose Complexity Layer by Layer

## The Spy's Dilemma

Imagine you are a spy trying to identify a target in a crowded room. You cannot look at everyone directly — instead, you have a limited number of informants stationed at different vantage points, each of whom can tell you something about the people they can see. The question is: *what is the minimum number of informants you need to identify any person in the room?*

This is not merely a puzzle for espionage novels. It is the central question of **compression theory** — a branch of mathematics that asks how much observation is needed to distinguish between all the objects in a system. And in 2025, a team of researchers proved something remarkable: the complexity of identifying objects in a structured system can be broken down, layer by layer, just like peeling an onion.

## From Shannon to Sheaves

The story begins with Claude Shannon's revolutionary 1948 paper on information theory. Shannon showed that the information content of a message — its entropy — obeys elegant mathematical laws. One of the most important is the **chain rule**: the total information in two combined signals is bounded by the sum of their individual informations. If you know the weather and the stock market, the total uncertainty is at most the uncertainty of weather plus the uncertainty of stocks.

Shannon's insight transformed telecommunications, but it applied only to probabilistic signals — sequences of symbols drawn from known distributions. What about geometric or algebraic structures? What about systems where the data has *shape*?

For decades, mathematicians working in algebraic geometry and category theory studied objects called **presheaves** — mathematical structures that assign data to every region of a space and track how that data transforms when you zoom in or change your viewpoint. Presheaves are everywhere: they describe electromagnetic fields over regions of spacetime, databases that update as new records arrive, and even the way different cameras in a surveillance system provide overlapping views of a scene.

But nobody had asked Shannon's question about presheaves: *how much observation do you need to identify all the data in a presheaf?*

## The Compression Number

The answer begins with a concept called the **compression number**. Given a presheaf — think of it as a system that assigns information to every viewpoint — the compression number measures the minimum number of "probe" viewpoints needed to distinguish all the information in the system. If you choose the right probes, you can reconstruct everything; choose too few, and some data becomes invisible.

This is exactly the spy's dilemma, elevated to a mathematical framework. The probes are the informants. The presheaf is the room full of people. The compression number is the minimum number of spies you need.

Previous work had established that compression numbers satisfy a basic form of **subadditivity**: if you combine two independent information systems, the compression of the combined system is at most the sum of the individual compressions. This is Shannon's inequality `H(X,Y) ≤ H(X) + H(Y)` in geometric clothing.

But independent combination is the easy case. The hard case — the case that matters in practice — is when the information system has internal structure. What if the presheaf isn't a flat collection of data, but a *layered* one?

## Filtrations: The Layers of Complexity

The breakthrough comes from an ancient idea in algebra: **filtrations**. A filtration is a way of organizing a mathematical object into a nested sequence of simpler pieces, like a geological stratum or the layers of an archaeological dig. In representation theory, filtrations decompose group representations into irreducible constituents. In topology, they power spectral sequences — one of the most powerful computational tools in modern mathematics.

The new theorem says: *if you can decompose a presheaf into layers, then the compression of the whole is bounded by the sum of the compressions of the layers.*

More precisely, suppose you have a presheaf *F* that admits a filtration:

> 0 = F₀ ⊆ F₁ ⊆ F₂ ⊆ ⋯ ⊆ Fₙ = F

Each "graded piece" Fᵢ/Fᵢ₋₁ represents one layer of information. The theorem proves that:

> κ(F) ≤ κ(F₁/F₀) + κ(F₂/F₁) + ⋯ + κ(Fₙ/Fₙ₋₁)

The compression of the whole is controlled by the compressions of the layers.

## Why This Matters

This result may sound technical, but its implications are sweeping. It means that **complex information systems can be analyzed by decomposing them into simpler components**. Instead of attacking the compression problem for a massive, complicated presheaf head-on, you can break it into manageable pieces and bound each one separately.

Consider a real-world scenario: a network of sensors monitoring a building. Each sensor provides partial information about temperature, humidity, air quality, and occupancy across different rooms. The total information system is a presheaf over the building's floor plan. Computing the minimum number of sensors needed to fully monitor the building — the compression number — might be intractable for the whole system. But if you can decompose the monitoring task into layers (first detect occupancy, then resolve temperature within occupied rooms, then measure air quality), the filtration theorem guarantees that the total sensor count is bounded by the sum of sensors needed for each layer.

## The Engine: Gluing Observers Together

The proof works by a technique the researchers call **observer gluing**. At each filtration step, you have:
- A family of probes that separates the "lower" part of the information
- A family of probes that separates the "quotient" (the new information added at this layer)

The key insight is that these two families can be combined — simply take their union — to produce a probe family that separates the whole next level. The proof shows that the combined family works because the topology of the underlying space guarantees that probes can "reach" any point: if two pieces of data look the same from every combined viewpoint, they must actually be the same.

This gluing argument is then iterated up the entire filtration, with a careful inductive argument tracking how the compression numbers accumulate. The result is a **telescoping inequality**: at each step, the new compression is bounded by the old compression plus the layer's contribution, and summing these bounds yields the global result.

## A Bridge Between Worlds

What makes this work extraordinary is that it connects three previously separate domains of mathematics:

**Information theory.** The filtration bound is the non-independent analogue of Shannon's entropy chain rule. While Shannon's rule handles independent sources, the filtration theorem handles sources with algebraic dependencies — a much harder and more realistic setting.

**Representation theory.** In the theory of group representations, the Jordan–Hölder theorem says that every representation has a unique (up to reordering) sequence of irreducible constituents. The filtration bound for compression says that the information complexity of a representation is controlled by its composition factors — exactly the prediction you would make if compression were a "character" in the representation-theoretic sense.

**Algebraic K-theory.** One of the central programs in modern algebra seeks to understand which numerical invariants of mathematical structures are "additive" — meaning they behave well under exact sequences. The filtration theorem shows that compression is *sub-additive* in this sense, and achieves exact additivity for split decompositions. This places compression firmly in the landscape of K-theoretic invariants.

## The Onion and the Microscope

Perhaps the most vivid way to understand the result is through an analogy. Imagine you have a complex biological specimen under a microscope. You want to identify every cell, but the specimen is too thick to image all at once. So you slice it into thin sections and image each one. The filtration theorem says: *the total resolution needed to identify every cell is at most the sum of the resolutions needed for each slice.*

This is not a trivial statement! It might be that cells in different slices interact in complicated ways, and you might fear that imaging each slice separately could miss crucial cross-slice information. The theorem says this fear is unfounded: the layered approach always works, and it gives you a provable bound on the total observation cost.

## Looking Ahead

The filtration theorem opens several exciting research programs:

**Optimal decomposition.** Given a presheaf, what is the *best* filtration — the one that minimizes the total graded compression bound? Finding optimal filtrations is an optimization problem on the lattice of subpresheaves, and early computational experiments suggest that the minimum bound may stabilize as the filtration becomes finer, analogous to convergence in spectral sequences.

**Derived compression.** Just as cohomology extends the idea of counting holes to higher dimensions, one can imagine "higher compression invariants" that capture not just the cost of separation, but the cost of higher-order consistency checking. The filtration framework provides the scaffolding for such a theory.

**Sensor network design.** In engineering, the theorem suggests a practical design methodology: decompose the monitoring task into layers, estimate the sensor cost for each layer independently, and assemble the total system with guaranteed performance bounds.

**Algorithmic information theory.** The compression number is a combinatorial analogue of Kolmogorov complexity. The filtration bound suggests new approaches to estimating algorithmic complexity through structural decomposition rather than brute-force enumeration.

## A New Language for Complexity

Every few decades, mathematics produces a concept that changes how we think about complexity. In the 1940s, it was entropy. In the 1960s, it was computational complexity. In the 2000s, it was persistent homology. The filtration theory of compression may be the next entry in this list: a framework that treats complexity not as a monolithic number, but as a *structure* — something that can be decomposed, analyzed layer by layer, and reconstructed from its pieces.

The message is simple but profound: **the complexity of a whole is controlled by the complexity of its parts.** Not just for independent parts, but for parts that are nested inside each other, interacting through the geometry of the space they live in. That is the promise of homological information theory — and we are just beginning to explore its implications.
