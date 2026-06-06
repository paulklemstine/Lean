# The Speed of Light in a Universe Made of Squares

*How Conway's Game of Life reveals deep truths about computation, complexity, and the nature of universal machines*

---

In 1970, the British mathematician John Conway invented something that shouldn't exist: a universe. It had no particles, no forces, no differential equations. Just a grid of squares, each either alive or dead, following four simple rules about how many neighbors a cell needs to survive, die, or come alive. He called it the Game of Life.

What Conway didn't fully appreciate at the time was that he had created something with the same computational power as every computer ever built — or that could ever be built. The Game of Life is Turing complete: given enough space and time, it can compute anything that any computer can compute.

This is a remarkable claim. A grid of black and white squares, following four rules that a child could understand, possesses the same fundamental computational power as the machine on which you're reading this article. The question that has captivated mathematicians and computer scientists for over fifty years is: at what cost?

## The Cost of Computation

Every simulation carries overhead. When one system simulates another, it needs extra resources — more space, more time, or both. Think of it like translation between languages: you can express any idea in any language, but some translations require more words, more sentences, more pages.

For cellular automata like the Game of Life, this overhead has a precise mathematical structure. We recently discovered that simulation overhead forms what mathematicians call a *monoid* — an algebraic structure with a multiplication operation and an identity element. When you chain simulations together (simulate A using B, then simulate B using C), the overheads don't just add up: they *multiply*.

This multiplicativity is not obvious. You might expect that simulating A via B via C would cost roughly the sum of the two individual overheads. But the correct formula is:

> **Total overhead = overhead(A→B) × overhead(B→C)**

This means that long simulation chains are exponentially expensive. After chaining *n* simulations of overhead *k*, the total overhead is *k^n*. This exponential growth is not an artifact of sloppy engineering — it's a mathematical theorem, provable from first principles.

## A Speed Limit for Information

Perhaps the most elegant result concerns the speed of light in the Game of Life's universe.

In GoL, information travels through *gliders* — small patterns that move across the grid by translating themselves. The standard glider, discovered by Conway himself, is a five-cell pattern that shifts one cell diagonally every four steps, giving it a speed of 1/2.

But there's a fundamental speed limit. Because each cell only communicates with its eight immediate neighbors (the Moore neighborhood), no signal can travel faster than one cell per step. This is the Game of Life's speed of light: *c* = 1.

We proved that every glider respects this speed limit. The proof is beautifully simple: it follows directly from the *locality* of the transition rule. Since a cell's next state depends only on its immediate neighbors, any influence must propagate at most one cell per step. No cleverness in pattern design can circumvent this fundamental constraint.

This mirrors the real universe's speed of light — not as a coincidence, but as a deep structural parallel. Both speed limits arise from locality: the principle that interactions are local, not global.

## The Algebra of Simulation

Our central discovery is the **Computational Morphism Monoid**: the algebraic structure governing how efficiently one cellular automaton can simulate another.

The key insight is that simulation complexity has two independent dimensions: *space* and *time*. The spatial factor measures how many cells of the simulator represent one cell of the target. The temporal factor measures how many steps of the simulator represent one step of the target. The total overhead is spatial² × temporal — the square because space is two-dimensional.

This overhead function respects composition in a beautiful way. It's not just any function; it's a *monoid homomorphism*. This means:

1. The overhead of the identity simulation is 1
2. The overhead of a composed simulation is the product of individual overheads
3. Composition is associative

Taking logarithms converts this multiplicative structure into an additive one. The log-overhead of a composed simulation is the *sum* of the individual log-overheads. This transforms the problem of tracking simulation costs into simple addition — a profound simplification.

## Computational Density: A New Invariant

We introduce a novel concept: **computational density**, measuring how many cells and time steps a cellular automaton needs per bit of useful computation.

For Conway's Game of Life, the computational density is approximately 36 cells per bit and 30 steps per gate operation — a total overhead of 1080. These numbers come from the physical constraints of GoL's computational primitives: the smallest known glider gun (which generates a stream of gliders) has a period of 30 steps and requires a footprint of roughly 36 cells.

The efficiency — the reciprocal of density — is 1/1080. This means that for every 1080 "cell-steps" of GoL computation, you extract one bit-operation of useful work. It's not efficient by engineering standards, but it's finite. And finiteness is what matters for universality.

What makes computational density truly interesting is that it's *monotone under simulation*. If cellular automaton A simulates cellular automaton B with overhead *c*, then A's computational density is at most *c* times B's density. This makes computational density an invariant of the simulation lattice — a structural property that's preserved under the fundamental operation of the theory.

## NAND: The Atom of Computation

The path from the Game of Life to Turing completeness runs through a single logic gate: NAND (Not-AND).

NAND is *functionally complete*: every Boolean function — AND, OR, NOT, XOR, any function at all — can be built from NAND gates alone. This is a standard result in computer science, but it gains new significance in the cellular automata context.

In the Game of Life, a NAND gate is realized through *glider collisions*. Two streams of gliders, representing two input bits, collide in a carefully engineered arrangement. The collision products are routed to produce a glider stream representing the NAND of the inputs. The engineering is intricate, but the mathematics is exact.

Once you have NAND, you have everything. NOT is NAND with both inputs the same. AND is NAND followed by NAND. OR uses three NAND gates, via De Morgan's law. XOR needs four. From these building blocks, you can construct any digital circuit: adders, multipliers, memory cells, and eventually, a complete computer.

## Translation Invariance: A Hidden Symmetry

The Game of Life possesses a symmetry that's easy to overlook but mathematically deep: *translation invariance*. If you shift the entire grid by any displacement and then evolve one step, you get the same result as first evolving and then shifting.

This symmetry has a precise mathematical statement: GoL commutes with spatial translation. It follows from the uniformity of the transition rule — every cell applies exactly the same logic. There are no boundary effects, no special locations.

Translation invariance is what makes gliders possible. A pattern that "moves" is really a pattern that recreates itself at a shifted location. The equivalence between moving and being recreated is guaranteed by translation invariance.

## The Garden of Eden

Not every configuration in the Game of Life can arise from evolution. Some patterns — called *Gardens of Eden* — have no predecessor: no configuration, when evolved one step, produces them.

The existence of Gardens of Eden is a deep result connected to the theory of surjunctive groups in abstract algebra. It tells us that the Game of Life's dynamics are fundamentally irreversible: information is lost at every step. The number of possible states decreases (or stays the same) with each evolution step.

This irreversibility stands in contrast to the laws of physics, which are time-reversible at the fundamental level. It suggests that the Game of Life, despite its computational universality, captures only certain aspects of physical reality.

## What It All Means

The Game of Life teaches us something profound about the nature of computation. Universality — the ability to compute anything computable — is not a property of complexity. It can arise from the simplest possible ingredients: a grid, two states, and four rules.

The cost of this universality is measured by the Computational Morphism Monoid, a mathematical structure that governs how efficiently one system can simulate another. This structure has its own laws: overheads multiply, log-overheads add, and exponential growth is unavoidable for long simulation chains.

These are not merely theoretical curiosities. They speak to fundamental questions about the limits of simulation, the nature of complexity, and the relationship between simple rules and emergent computation. In a world increasingly reliant on simulation — from weather forecasting to drug design to artificial intelligence — understanding the mathematical structure of simulation overhead is not just interesting. It's essential.

Conway passed away in 2020, but his creation continues to surprise. The Game of Life is not just a mathematical toy. It's a mirror reflecting the deepest structures of computation itself.

---

*This article describes research formalizing Conway's Game of Life as a computational system and proving foundational theorems about simulation complexity, translation invariance, and the speed of information propagation.*
