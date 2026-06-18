# The Ancient Triangles That Can Think

## How a 4,000-year-old piece of geometry turned out to be a secret computer

---

There is something almost magical about Pythagorean triples — those sets of three whole numbers where the squares of the two smaller ones add up to the square of the largest. The most famous is 3, 4, 5: build a right triangle with those sides, and the relationship holds perfectly. No fractions, no rounding, no approximation. Pure, crystalline arithmetic.

The Babylonians knew about these triples four millennia ago. Plimpton 322, a clay tablet from around 1800 BCE, lists fifteen of them in careful cuneiform. The Greeks elevated them to the status of profound mathematical truth. And for most of recorded history, that's where the story seemed to end: Pythagorean triples were beautiful, useful for surveying and architecture, and thoroughly understood.

Until now. New research has revealed something that the Babylonians, the Greeks, and two thousand years of mathematicians after them never suspected: these ancient triangles can compute.

---

## A Tree That Grows Triangles

The discovery begins with a structure called the Berggren tree, named after the mathematician who described it in 1934. Take the triple (3, 4, 5) and think of it as the root of a tree. Now apply three specific transformations — mathematical recipes involving nothing more exotic than multiplication and addition — and you get three new triples: (5, 12, 13), (21, 20, 29), and (15, 8, 17). Apply the same three transformations to each of those, and you get nine more. Then twenty-seven. Then eighty-one.

Here's the remarkable fact: this process generates *every* primitive Pythagorean triple exactly once. Not some of them — all of them. And each triple appears at exactly one location in the tree, reachable by exactly one path from the root. The tree is a perfect filing system for the entire infinite collection of right triangles with integer sides.

This uniqueness is the first clue that something deeper is happening. In the Berggren tree, every Pythagorean triple has a unique "address" — a sequence of letters A, B, and C that tells you which transformations to apply to reach it from (3, 4, 5). The triple (7, 24, 25), for instance, has address "AA": apply transformation A twice. The triple (55, 48, 73) has address "AB": A first, then B.

These addresses behave like coordinates in a strange mathematical space. You can measure the distance between two triples by counting how far apart their addresses are in the tree. You can identify neighborhoods. You can define "directions" and "paths." The Berggren tree isn't just a catalogue — it's a geometry.

## From Triangles to Circuits

The breakthrough came from asking an unusual question: what if you treated this geometry not as a filing system, but as a computer?

The idea sounds absurd at first. A computer needs a place to store information, a way to read and modify it, and a set of rules for how the modifications work. How could a tree of right triangles provide any of that?

The answer lies in what computer scientists call a *two-counter machine*. This is the simplest possible general-purpose computer: it has just two counters (think of them as displays that show a number, like the odometer on a car) and a short list of instructions. Each instruction either adds one to a counter, subtracts one, or jumps to a different instruction depending on whether a counter is zero.

Despite their simplicity, two-counter machines can compute anything that any computer can compute. Your laptop, your phone, the servers running the internet — they're all, in a deep mathematical sense, equivalent to a pair of counters and a list of instructions. This has been known since the work of Marvin Minsky in the 1960s.

The new result shows that the Berggren tree can simulate any two-counter machine. Here's how it works: pick three specific locations on the tree — say, the root (3, 4, 5), its A-child (5, 12, 13), and the grandchild (7, 24, 25). These three cells store the program counter and the two counter values. An update rule reads the values at these three positions, applies one step of the counter machine, and writes the results back.

All other positions in the infinite tree remain "quiescent" — silent, unchanging. The computation happens entirely on a thin ray of three cells threading through the vast lattice of Pythagorean triples.

## Why It Matters: Native Computation

At this point, a skeptic might say: "So what? You could store numbers anywhere — in a spreadsheet, on a napkin, in smoke signals. What's special about using Pythagorean triples?"

The answer is that the computation here is not arbitrary. It's controlled by the *native structure* of the orbit.

Consider the growth rate. As you move deeper into the Berggren tree, the numbers in each triple get larger. But they don't grow randomly — they grow in a tightly controlled, exponential pattern. The largest number in any triple at depth *n* in the tree is at most 7ⁿ × 5. This means the number of digits (the "bit-size") needed to write down a triple grows *linearly* with its depth in the tree.

This is exactly the kind of bound that computer scientists care about. It means that the overhead of using Pythagorean triples as a computational substrate is *polynomial* — it doesn't blow up faster than the computation itself. You're not wasting exponentially more resources to maintain the encoding. The tree's geometry naturally provides the kind of efficient scaling that makes a computational model practical rather than merely theoretical.

Furthermore, each Berggren transformation has an inverse. If you know which transformation was applied, you can always recover the parent triple. The transformations are, in the language of algebra, *injective* — they never produce collisions. Two different triples always generate different children. Two different directions from the same parent always lead to different places. This injectivity is what makes the tree a genuine address space, not a hash table with conflicts.

## The Lorentz Connection

Perhaps the most surprising aspect of the Berggren transformations is their physical significance. The three generating matrices are elements of the *integer Lorentz group* — the very same mathematical structure that governs the geometry of spacetime in Einstein's theory of special relativity.

The Lorentz group describes how measurements of space and time change when you switch between observers moving at different speeds. The Berggren matrices preserve a quadratic form Q(a, b, c) = a² + b² − c², which is precisely the Minkowski metric — the fundamental distance measure of relativistic physics — restricted to the integer lattice.

This means that the Pythagorean condition a² + b² = c² is equivalent to saying that the triple lies on the "light cone" Q = 0. Generating Pythagorean triples is, in a precise mathematical sense, the same as tracing out discrete light rays in a two-dimensional spacetime.

The fact that this same structure supports universal computation suggests a deep connection between number theory, physics, and the foundations of computing — one that mathematicians are only beginning to explore.

## What Computers Cannot Tell You

There's a beautiful irony in the universality result. Because the Berggren orbit can simulate any two-counter machine, and two-counter machines can simulate any computer, there exist questions about the orbit that *no computer can answer*.

For example: given a particular local update rule on the Berggren tree, will a specific configuration eventually reach a given target? This is equivalent to the halting problem for counter machines, which Alan Turing proved undecidable in 1936. No algorithm, no matter how clever, can answer this question in general.

So the Berggren tree contains, within its orderly branching pattern, problems that are forever beyond the reach of computation. The tree can compute anything, but it cannot predict its own behavior in general. This is the hallmark of genuine computational universality — and it lives inside a structure that the Babylonians were already exploring four thousand years ago.

## The Shape of Things to Come

This result opens several tantalizing directions. The Berggren tree is just one example of a *tree-structured orbit* in number theory. Apollonian gaskets — the fractal patterns formed by mutually tangent circles — have a similar tree structure. So do Markov triples, which appear in the theory of Diophantine approximation. Could these structures also support intrinsic computation? The machinery developed here suggests that many naturally occurring orbits in number theory may have hidden computational power.

Another direction involves reversibility. Because each Berggren transformation has an inverse, the computational dynamics on the tree are inherently reversible — no information is lost at any step. Reversible computation is central to the physics of thermodynamics and quantum computing, where the laws of physics forbid information destruction. Pythagorean orbits may offer a new testing ground for ideas about computation, physics, and the arrow of time.

Perhaps most intriguingly, the polynomial growth bounds connect the result to complexity theory — the branch of computer science that studies *how hard* problems are, not just *whether* they're solvable. The Berggren tree's controlled growth means that the computational simulation has low overhead, opening the door to intrinsic complexity classes defined not by abstract machines but by the geometry of number-theoretic orbits.

## The Oldest New Computer

Mathematics has a long history of surprising connections. The same equations that describe the vibration of a drum also describe the flow of heat. The same groups that classify wallpaper patterns also classify elementary particles. And now, the same triples that the Babylonians carved into clay tablets turn out to support universal computation.

The Berggren tree is not merely a way to list Pythagorean triples. It is a computational medium — a structure in which the basic operations of logic, memory, and control flow emerge naturally from the arithmetic of right triangles. The numbers (3, 4, 5) are not just the sides of a triangle. They are the root of a universal computer, branching forever into an infinite tree of computation.

The Babylonians could not have known this. But they were, in a sense, working on the earliest hardware of a machine that mathematics has only now learned to turn on.
