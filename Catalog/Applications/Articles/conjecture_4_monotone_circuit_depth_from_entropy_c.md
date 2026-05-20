# Circuits That Forget: How Entropy Reveals the Limits of Computation

Every time a computer makes a decision, it throws away information. A transistor that takes two inputs and produces one output irreversibly compresses what it knows. This mundane observation—that computation destroys information—turns out to have profound implications for understanding the fundamental limits of what circuits can do. And now, a new mathematical framework makes this intuition precise, opening a fresh avenue for proving that certain problems are genuinely hard.

## The Question That Haunts Computer Science

Here is a question that has bedeviled mathematicians and computer scientists for decades: how do you prove that a problem *cannot* be solved efficiently? We can often show that a clever algorithm solves a problem quickly. But showing that *no possible* algorithm can do better—that any circuit computing a particular function must be deep, using many sequential steps—is far harder.

This is not merely an academic curiosity. Understanding the minimum depth of circuits directly relates to how fast we can parallelize computation. A circuit's depth represents the number of sequential time steps required: the fewer steps, the more parallelizable the computation. If you could prove tight lower bounds on circuit depth, you would know the fundamental limits of parallel processing.

For a special but important class of circuits—*monotone* circuits, where the gates can only compute AND and OR operations, never negation—mathematicians have made real progress. Since the 1980s, landmark results by Alexander Razborov and others have shown that certain functions require exponentially large monotone circuits. But the proofs are notoriously technical, and extending them has proven difficult.

What if there were a simpler, more intuitive language for these lower bounds?

## Thinking in Terms of Entropy

The new approach begins with a beautifully simple idea. Consider a Boolean function that takes *n* binary inputs—a string of zeros and ones—and produces a single yes-or-no answer. Think of all possible inputs as the corners of a high-dimensional cube, where each coordinate is either 0 or 1.

Now, pick any corner of this cube and look *upward*—at all the corners that are "above" it, meaning they have ones in at least all the same positions you do, possibly more. Among those higher corners, some make the function output "true" and others don't. The *semantic entropy* at your chosen corner is a measure of how many of those higher, satisfying corners exist. Specifically, it's the logarithm of their count.

This quantity captures something intuitive: how much "room" the function has to be satisfied above your current position. If you're at the all-zeros corner, there are many possible ways to reach a satisfying assignment by flipping zeros to ones. If you're already at the all-ones corner, there's only one possibility—yourself.

The first key theorem establishes a fundamental law: **for monotone functions, semantic entropy can only decrease as you move upward in the cube**. This is because a monotone function, by definition, never "turns off" when you flip a zero to a one. So if you start higher up, you have fewer points above you, and the set of satisfying points can only shrink. The logarithm, being a monotone operation, preserves this ordering.

This might seem obvious, but its consequences are far-reaching. It means that entropy flows in one direction—downhill—as you traverse the Boolean cube upward. Monotone computation is, in a precise sense, an entropy-consuming process.

## The Fan-In Bottleneck

The second insight is where the theory becomes powerful. Consider a single gate in a circuit—say, an OR gate that takes *k* inputs. What does this gate do to the entropy landscape?

An OR gate combines *k* sets of satisfying assignments by taking their union. The new research proves that the logarithmic size of a union of *k* sets can exceed the largest individual set's log-size by at most log₂(*k*). In information-theoretic terms: a gate of fan-in *k* can only "create" at most log₂(*k*) bits of entropy.

This is the bottleneck. If each gate in a circuit can add at most log₂(*k*) to the entropy, and the circuit has depth *d* (meaning *d* sequential layers of gates), then the total entropy change across the circuit is bounded by *d* · log₂(*k*).

## The Telescoping Argument

Now comes the punch line. Suppose you want a circuit that computes a function with a large entropy drop—meaning there exist two points in the Boolean cube where the semantic entropy differs dramatically. If the total entropy can change by at most *d* · log₂(*k*) across *d* layers, then:

**depth ≥ (entropy drop) / log₂(fan-in)**

This is a genuine lower bound on circuit depth. It says: if the function has a big entropy gap, no shallow circuit can compute it. The minimum depth is forced by the laws of information dissipation.

What makes this remarkable is its mechanism. Classical approaches to monotone lower bounds use intricate combinatorial arguments—sunflower lemmas, approximation methods, communication complexity games. The entropy approach replaces much of this machinery with a single, clean principle: *information cannot be created faster than the gates allow*.

## Connecting Worlds

The framework does not exist in isolation. It connects naturally to several deep areas of mathematics and theoretical computer science.

In *discrete geometry*, the entropy drop between two points in the Boolean cube behaves like a potential function. The theory proves that this drop is bounded by the Hamming distance—the number of bit-positions where two points differ—times the maximum single-step drop. This means entropy drop satisfies a kind of Lipschitz condition on the lattice, making it a metric-like object that encodes the function's complexity.

In *communication complexity*, the celebrated Karchmer–Wigderson framework characterizes circuit depth through a two-player game. The entropy approach provides what might be called a "thermodynamic" version of this game: instead of asking how many bits Alice and Bob must exchange, it asks how much entropy the function dissipates. Early computational evidence suggests these two measures may be comparable, up to universal constants—a tantalizing conjecture that, if true, would provide a fundamentally new characterization of circuit depth.

In *statistical mechanics*, the semantic entropy at a point has a natural interpretation as a zero-temperature partition function: it counts the number of "ground states" (satisfying assignments) accessible from a given boundary condition (the input bits already fixed to one). The information flow law then becomes an analogue of the second law of thermodynamics for discrete computation.

## Computing the Invariant

Unlike many theoretical constructs in complexity theory, semantic entropy is directly computable. For any monotone Boolean function given by its truth table, one can enumerate the upward satisfying fibers, compute their sizes, take logarithms, and measure the maximum entropy drop. This has been implemented and tested on standard function families.

For the OR function on *n* bits, the maximum entropy drop is approximately *n* − log₂(*n*+1), giving a depth lower bound of roughly *n* for fan-in-2 circuits. For threshold functions that output "true" when the number of ones exceeds a threshold, the entropy profile shows a smooth decrease, with the steepest drops occurring at the critical threshold level. For graph property functions—such as triangle detection—the entropy drops are substantial and correlate with known circuit complexity bounds.

Computational tests also verify the local-to-global conjecture: the maximum entropy drop from the bottom to the top of the cube exactly equals the sum of step-by-step drops along the optimal chain. This telescoping property confirms that no entropy is "lost" in the chain decomposition.

## The Road Ahead

The immediate scientific question is whether the entropy lower bounds are tight—whether they match known depth lower bounds up to constant factors. If the Entropy–KW Equivalence Conjecture holds, then semantic entropy would provide an alternative characterization of monotone circuit depth, one that is purely information-theoretic rather than game-theoretic.

A more ambitious goal is to extend the framework beyond monotone circuits. Non-monotone computation—where negation gates are allowed—can *increase* entropy, making the one-way flow law fail. But it may be possible to define a modified entropy that accounts for negation as a bounded-cost operation, leading to lower bounds for general circuits. This is speculative, but the monotone case provides a solid foundation.

Perhaps the most exciting prospect is automation. Because semantic entropy is computable, one could imagine software that takes a Boolean function as input and automatically produces a certified lower bound on its circuit depth. This would transform monotone lower bounds from a boutique art—requiring years of human ingenuity per result—into a systematic science.

## A New Language for Difficulty

At its heart, this work proposes a shift in perspective. Instead of asking "how many resources does a circuit need?" it asks "how much information does the circuit destroy?" The answer turns out to be tightly constrained by the structure of the computation, in a way that makes lower bounds emerge naturally.

The analogy to thermodynamics is not just poetic. In physics, the second law tells us that entropy increases—that information is inevitably lost to heat. In monotone computation, a dual law holds: semantic entropy decreases—satisfying possibilities are inevitably narrowed. Each gate acts as a tiny engine of compression, and the laws of information constrain how fast this compression can proceed.

Computation, it turns out, has its own thermodynamics. And like the thermodynamics of the physical world, these laws set absolute limits on what is possible—limits that no amount of cleverness can overcome.
