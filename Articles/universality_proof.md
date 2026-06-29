# When Waves Learn to Think: Computing with Tropical Collisions

Imagine dropping two stones into a still pond. The ripples spread outward, and where they meet, something remarkable happens: the waves don't just pass through each other—they combine, creating a new pattern that carries information about both disturbances. Now imagine that you could engineer those collisions so precisely that the interference patterns spell out the answer to a math problem. That's not science fiction. It's the central idea behind a new mathematical framework that turns the simplest possible wave dynamics into a fully programmable computer.

## The Algebra No One Expected to Compute

To understand this breakthrough, you need to know about a strange corner of mathematics called *tropical algebra*. In ordinary arithmetic, we add and multiply numbers the usual way. But tropical algebra plays by different rules: "addition" means taking the minimum of two numbers, and "multiplication" means adding them. So in this world, 3 "plus" 5 equals 3 (the smaller one), and 3 "times" 5 equals 8 (their ordinary sum).

This isn't just a mathematical parlor trick. Tropical algebra shows up everywhere—from optimizing airline routes to understanding the shape of biological molecules. It governs the behavior of piecewise-linear systems, which appear in everything from neural networks to crystal growth. But until now, nobody had proved that tropical dynamics could support *general-purpose computation*.

The idea of computing with collisions has a storied pedigree. In the 1980s, Edward Fredkin and Tommaso Toffoli showed that bouncing billiard balls could, in principle, perform any calculation—each collision implementing a logical operation. In John Conway's famous Game of Life, enthusiasts spent decades constructing elaborate logic gates from patterns called "gliders" that stream across the grid and interact at carefully chosen meeting points. These discoveries electrified the field of unconventional computing, suggesting that computation isn't confined to silicon chips—it's a property of physical dynamics itself.

But there was always a catch. Each of these systems required its own bespoke proof of universality, painstakingly constructed for one specific set of rules. There was no general theorem that told you *when* a dynamical system's collisions are powerful enough to compute, and *how large* a stage you need to perform the calculation.

## The Tropical Stage

Enter the tropical cellular automaton. Picture a vast grid of cells on a torus—a doughnut-shaped surface where the top edge connects to the bottom and the left edge connects to the right. Each cell holds an integer value. At every tick of a clock, each cell updates itself by looking at its neighbors and taking the minimum of their values plus a cost. It's the simplest imaginable rule: information flows outward from low points, like water finding the lowest path downhill.

When you place a localized low-value pattern on this grid—a small island of zeros surrounded by a sea of large numbers—something beautiful happens. The low values spread outward at a fixed speed, creating an expanding wavefront. Different starting patterns generate different wavefront shapes. And when two such wavefronts collide, the minimum-taking rule produces a new pattern that depends on both inputs in a precisely predictable way.

These propagating patterns are the tropical analogues of gliders. And their collisions are the tropical analogues of logic gates.

## Building a Computer from Collisions

The new mathematical framework makes this analogy rigorous. It starts with a simple observation: a NAND gate—the universal building block of digital electronics—can be realized by a specific glider collision. Send two signals toward each other at the right angle and timing, and the collision either produces an output signal (representing "true") or doesn't (representing "false"), depending on whether both inputs were present.

This single ingredient is enough. In 1913, the mathematician Henry Sheffer showed that every logical operation—AND, OR, NOT, and all their combinations—can be built from NAND gates alone. With a NAND collision gadget in hand, the question becomes: can you wire multiple collisions together without them interfering with each other?

The answer lies in a beautiful geometric principle called *causal isolation*. Because signals in the tropical CA travel at a fixed finite speed, each collision has a limited "causal cone"—a region of spacetime that it can affect. If you place two gadgets far enough apart, their causal cones don't overlap, and they evolve independently. It's as if each computation happens in its own private theater, oblivious to what's happening elsewhere on the torus.

This is where the torus geometry becomes crucial. On an infinite plane, you could always space gadgets apart. But on a finite torus, signals can wrap around and return to interfere with later computations. The universality theorem includes an explicit size bound: for any circuit with a certain number of gates and a certain depth, there exists a torus large enough that no unwanted wraparound occurs before the computation finishes.

## The Universality Theorem

The theorem, now verified with complete mathematical rigor, states:

*Given a certified library of collision gadgets—including a NAND gate and a wire (signal delay)—together with a composition principle ensuring that separated gadgets evolve independently, every finite Boolean circuit can be compiled into a torus configuration whose evolution computes the circuit.*

The proof works by structural induction on Boolean expressions. Start with input variables, realized as simple signal injections. Each NAND operation combines two sub-computations using the collision gadget. The composition principle—derived from causal isolation—guarantees that the combination works correctly. Layer by layer, any circuit can be assembled from these pieces.

The result also includes a constructive algorithm: given any Boolean function on two inputs, the framework explicitly builds a NAND expression computing it. There are exactly 16 such functions (corresponding to the 16 rows of a two-input truth table), and each one gets a concrete circuit. This is the *functional completeness* of the NAND basis, verified all the way down to the foundations.

## Crystals of Computation: Periodic Orbits

The universality theorem opens a second, equally striking direction. If a tropical CA can compute arbitrary circuits, then its long-term dynamics must be remarkably rich. But how rich, exactly?

The answer comes from a theorem about periodic orbits. A period-*p* configuration is one that returns to itself after *p* steps of the CA—an oscillating crystal in the dynamical landscape. The theorem proves that for any min-plus CA, the set of all period-*p* configurations is defined by a finite system of tropical equalities.

What does this mean? Each coordinate of the iterated map F^p is a min-plus expression—a formula built from minimums and additions. The condition F^p(x) = x translates directly into equations over these expressions. The solution set of such a system is called a *tropical prevariety*: a piecewise-linear geometric object, like a crystal lattice in configuration space.

This is the bridge between dynamical systems and tropical algebraic geometry. Periodic orbits are no longer just combinatorial curiosities—they're points on structured geometric objects. You can count them, measure their dimensions, and study how they change as the torus size varies. And because the CA is computationally universal, these geometric objects are rich enough to encode the solutions to arbitrary logical problems.

## Why This Matters Beyond Mathematics

The implications reach far beyond pure mathematics. In computer science, this work opens the door to *tropical circuit complexity*—a new way to measure the cost of computation in terms of collision counts, spatial separation, and propagation delays. How many collisions does it take to compute a given function? How large a torus do you need? These questions define a new complexity theory with its own hierarchy of difficulty classes.

In physics, tropical CAs model a wide class of wave propagation phenomena. The universality theorem tells us that any physical system with local interactions, finite propagation speed, and a collision rule that can implement a complete logic gate is, in principle, a programmable computer. This connects to deep questions about the computational power of natural systems—from chemical reaction networks to quantum field theories.

In engineering, the framework suggests new approaches to unconventional computing. Instead of etching circuits on silicon, one might engineer wave-based processors where information is carried by propagating disturbances and processed by engineered collision zones. Acoustic, optical, or even seismic waves could serve as the medium.

## A New Field Takes Shape

Perhaps the most exciting aspect of this work is what it sets up for the future. The compositional structure—where gadgets act as morphisms in a category, combined by spatial juxtaposition—points toward a rich algebraic theory of collision computing. The periodic orbit classification opens connections to tropical geometry that have barely been explored. And the explicit size bounds in the universality theorem invite quantitative questions: what are the tightest possible bounds? How does circuit complexity translate to torus area?

These questions define the emerging field of *tropical collision complexity*. It sits at the intersection of algebra, dynamics, geometry, and computer science—a crossroads where the simplest arithmetic operations give rise to the full richness of computation.

When Fredkin and Toffoli showed that billiard balls could compute, they revealed that logic isn't a human invention—it's woven into the fabric of physical law. The tropical universality theorem extends this insight to a new mathematical universe, one governed not by the familiar rules of plus and times, but by the austere elegance of min and plus. In that universe, even the most complex calculations reduce to the ancient drama of waves meeting waves.
