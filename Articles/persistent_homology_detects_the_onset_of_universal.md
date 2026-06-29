# When Matrices Forget Their Origins: A Hidden Phase Transition in the Arithmetic of Randomness

Take two simple integer matrices — the kind you might encounter in an introductory linear algebra course. Multiply them together in random order. Do it again. And again. Something extraordinary happens: at first, the product "remembers" which matrices you started with. But after a critical number of multiplications, that memory vanishes. The product enters a universal regime where, statistically, it behaves the same regardless of your starting ingredients.

This is not a vague handwave about randomness washing everything out. It is a precise, detectable phase transition — and mathematicians have now found a way to see it using the geometry of shapes that are normally invisible.

## The Recipe

Here is the setup. You choose a small handful of 2×2 integer matrices — say, the matrices [[1,1],[0,1]] and [[1,0],[1,1]], along with their inverses. These are elements of a famous mathematical object called SL₂(ℤ), the group of 2×2 integer matrices with determinant exactly 1. This group has been central to number theory since the 19th century, governing everything from the arithmetic of prime numbers to the geometry of tiling patterns.

Now pick a prime number *p* — say 7, or 23, or 10007. Reduce all your matrix entries modulo *p*: every entry becomes a remainder after division by *p*. Your matrices now live in SL₂(𝔽_p), a finite group with exactly p(p²−1) elements. For p = 7, that's 336 matrices. For p = 10007, it's over a trillion.

Start at the identity matrix and randomly multiply by your chosen generators, one at a time. You are taking a random walk on a finite group. The trajectory bounces around the group, visiting new elements, occasionally returning to old ones.

The question: *when does the walk forget where it started?*

## The Topological Telescope

The traditional approach uses probability theory — mixing times, spectral gaps, convergence rates. These are powerful tools, but they are intrinsically numerical. They tell you *how close* the walk is to uniform, not *what kind of structure remains*.

The new approach asks a different question: what does the geometry of the walk's exploration look like?

Imagine plotting every group element the walk has visited, and drawing a line between two elements the first time both have appeared. As the walk progresses, this network of connections grows — first a sparse scatter of isolated points, then clusters, then a dense web. Eventually, when every pair has been "co-discovered," the network becomes a complete graph, and all geometric structure collapses into trivial uniformity.

This network is not just a pretty picture. It is a *filtered graph* — a mathematical object with precisely defined properties. At each moment in time, you can ask: how many holes does this network have? How many independent loops? How many disconnected pieces?

These quantities — the so-called *Betti numbers* of the associated topological space — form a signature of the walk's exploration pattern. And here is where the surprise comes in.

## The Phase Transition

For early times, the Betti numbers depend sensitively on which generators you chose. Different starting matrices produce different exploration patterns, different networks, different topological signatures. The walk remembers its arithmetic origins.

But there is a critical time scale — proportional to the logarithm of the prime *p* — beyond which the signatures collapse. Different generator sets, different probability weights, even different algebraic types of generators all produce statistically indistinguishable topological profiles.

This is the phase transition: the topological signature crosses from an arithmetic regime, where local structure matters, to a universal regime, where only the ambient group determines the outcome.

The logarithmic scaling is not an accident. It reflects a deep property of these matrix groups: they form *expanders*, networks where information spreads explosively fast. In an expander, a random walk reaches every corner of the space in time proportional to the logarithm of its size — exponentially faster than in ordinary networks. This explosive mixing is what drives the topological collapse.

## Why Topology?

Why not just count how many group elements the walk has visited? That number grows monotonically and also shows a phase transition. But the topological approach captures something richer: the *relationships* between visited elements, not just their identities.

Consider an analogy. Imagine you are exploring a city by walking randomly through its streets. Counting the number of intersections you've visited tells you something. But the *topology* of your exploration — which neighborhoods are connected in your experience, where your path forms loops, which areas remain isolated — tells you far more about the city's structure and your walk's character.

Similarly, the meeting-time filtration captures the combinatorial geometry of exploration. Two walkers on the same group, with different generators but the same time budget, might visit the same number of elements but create very different exploration geometries. The topological signature detects this.

## The Deterministic Backbone

Beneath the probabilistic conjecture lies a clean deterministic framework. Consider *any* finite sequence of states — no randomness required. Define the *visited set* at time t as the collection of states seen so far. The *meeting-time graph* at time t has an edge between two states whenever both have appeared by time t.

Three structural theorems anchor this framework:

**Monotonicity.** Once an edge appears, it never disappears. The filtration can only grow. This is the property that makes persistent homology applicable — the topological features have well-defined birth and death times.

**Completeness after coverage.** Once every state that will ever be visited has appeared, the meeting-time graph is the complete graph on the visited set. Every possible edge exists. All topological holes are filled. Every loop is the boundary of a filled-in region. This is the mechanism of topological collapse.

**Group equivariance.** If you relabel all the group elements by left-multiplying by a fixed element g, the topological structure of the filtration is unchanged. This means the topological signature is genuinely an invariant of the walk's law — not an artifact of how you labeled the group elements.

These are not deep theorems individually, but together they form the skeleton of a theory. They say: the meeting-time filtration is a well-behaved, natural, symmetry-respecting construction that *must* undergo topological collapse once coverage is achieved.

## The Expander Connection

The connection to expanders is where the theory becomes powerful. For random walks on expander graphs, coverage happens fast — in time O(log n) where n is the number of vertices. The family SL₂(𝔽_p), as p ranges over primes, forms one of the most celebrated expander families in mathematics, established through deep work on the Ramanujan conjecture and automorphic forms.

This means: for walks on SL₂(𝔽_p) driven by generators that produce the full group, the topological collapse happens by time O(log p). Different generator sets may have different constants in front of the logarithm, but the *scale* is the same.

The universality conjecture goes further: not only do all generator sets produce collapse at logarithmic scale, but the *shape* of the collapse — the precise profile of how topological features are born and die — converges to a universal law as p grows.

## Computational Evidence

Experiments with walks on SL₂(𝔽_p) for primes from 5 to 53 provide striking visual evidence. When topological summaries are plotted against the rescaled time variable t/log(p), curves from different generator sets — standard generators, unipotent generators, biased distributions — show progressive convergence as p increases.

The collapse time scales linearly with log(p), with slopes that differ modestly between generator sets but converge for larger primes. The inter-measure distance — a metric comparing the topological profiles of walks driven by different generators — shows a clear decreasing trend as p grows.

Perhaps most telling is the comparison with abelian groups. Random walks on the abelian group (ℤ/pℤ)² show fundamentally slower exploration and later topological collapse. The non-commutative structure of SL₂ is not incidental — it is the engine of universality.

## What It Means

If the universality conjecture is correct, it would establish a new kind of order parameter for dynamical systems on groups. In statistical physics, order parameters detect phase transitions: magnetization in ferromagnets, density differences in liquid-gas transitions. The topological persistence signature would play an analogous role for arithmetic dynamics, detecting the transition from structured to universal behavior.

This has practical implications. Expander graphs are used in computer science for error-correcting codes, cryptographic protocols, and derandomization algorithms. A topological diagnostic that detects expansion from sample trajectories — without requiring knowledge of the full graph structure — could provide a new tool for certifying the quality of pseudorandom generators and communication networks.

More broadly, the framework suggests a new way to think about randomness in mathematical systems. Randomness is not just the absence of pattern — it is a regime with its own characteristic topology, a universal signature that emerges when the system's memory of its initial conditions has been erased. The meeting-time filtration makes this precise: it tells you exactly *when* the topology becomes universal, and *how* the transition happens.

## The Bigger Picture

The idea that topology can detect dynamical phase transitions is part of a larger movement in mathematics and physics. Topological data analysis has already found applications in materials science (detecting phase transitions in glasses), neuroscience (mapping the topology of neural activity), and cosmology (characterizing the large-scale structure of the universe).

What is new here is the application to *arithmetic dynamics* — the study of number-theoretic systems through their dynamical behavior. The groups SL₂(𝔽_p) are not arbitrary finite groups; they are reductions of the most fundamental symmetry groups in number theory. The random walks on them are not arbitrary stochastic processes; they are the dynamical analogs of modular arithmetic, the system that governs prime numbers, cryptographic security, and the deepest structures in algebra.

By connecting the topology of exploration to the arithmetic of matrix products, this work opens a door between two mathematical worlds that have developed largely independently. On one side, the rich machinery of algebraic groups, automorphic forms, and the Langlands program. On the other, the computational power of topological data analysis and persistent homology.

The bridge between them is built from a simple observation: when you multiply random integer matrices modulo a prime and track which products you have seen, the geometry of your discoveries undergoes a phase transition. And that transition, detectable through the mathematics of shape, is universal.

It does not depend on which matrices you started with. It depends only on the prime, and on the deep fact that SL₂(𝔽_p) is an expander — a group where information cannot hide.

The matrices forget their origins. The topology reveals exactly when.
