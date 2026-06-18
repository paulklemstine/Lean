# The One-Button Calculator That Does Everything

## How a single mathematical operation generates all of calculus — and what it reveals about the hidden unity of mathematics

---

### The Dream of One Operation

Imagine a calculator with just one button. Not "add." Not "multiply." Not even "equals." Just one mysterious operation that takes two numbers and produces a third. Could such a ridiculously simple device compute anything useful?

The astonishing answer is *yes* — and the operation that makes it possible might be the most elegant formula in mathematics:

**eml(x, y) = eˣ − ln y**

Take the exponential of the first number. Subtract the natural logarithm of the second. That's it.

From this single operation, you can build addition, subtraction, multiplication, division, powers, roots, logarithms, exponentials, trigonometric functions, and every other "elementary function" that appears in science and engineering. All from one button. All you need is the number 1 to get started.

This is the EML operator — the **E**xponential **M**inus **L**ogarithm — and mathematicians are just beginning to uncover its extraordinary properties.

### Why Should You Care?

To understand why EML matters, consider an analogy from computer science. Every computer ever built, from your smartphone to a supercomputer, is constructed from just one type of logic gate: the NAND gate. This single operation — "not both" — can simulate any logical operation. Alan Turing's insight that computation could be reduced to simple building blocks is one of the foundations of the digital age.

EML does the same thing, but for continuous mathematics instead of discrete logic. It's the NAND gate for calculus.

But where NAND works with just 0s and 1s, EML works with all real numbers. And where NAND produces only logical values, EML produces the full richness of mathematical functions — the curves and surfaces that describe everything from planetary orbits to quantum wave functions.

### Building Mathematics from Scratch

Here's a taste of how it works. Start with just the number 1 and the EML button:

**Step 1: Get the exponential.** Press eml(1, 1). Since ln(1) = 0, you get e¹ = *e* ≈ 2.718, the base of natural logarithms.

**Step 2: Build the e-tower.** Press eml(*e*, 1) to get *e*^*e* ≈ 15.15. Press eml(*e*^*e*, 1) to get *e*^(*e*^*e*) ≈ 3814279. These numbers grow astronomically fast — faster than any familiar sequence.

**Step 3: Find zero.** Here's a surprise: eml(1, *e*^*e*) = *e* − ln(*e*^*e*) = *e* − *e* = 0. You've generated zero from scratch!

**Step 4: Get subtraction.** For any positive number *a* and any number *b*: eml(ln *a*, *e*^*b*) = *a* − *b*. Subtraction falls out naturally.

**Step 5: Get addition.** Similarly: eml(ln *a*, *e*^(−*b*)) = *a* + *b*.

From here, multiplication and division follow, and eventually trigonometric functions, inverse functions, and the entire apparatus of calculus — all from that one simple operation.

### The Wild Algebra

But the most surprising discovery isn't what EML *can* do — it's how it *behaves*.

In school, you learned that addition is commutative: 3 + 5 = 5 + 3. And associative: (2 + 3) + 4 = 2 + (3 + 4). These are the bedrock properties that make algebra work.

EML obeys *none of them*.

It's not commutative: eml(0, 1) = 1, but eml(1, 0) is something different entirely. It's not associative. It has no identity element — there's no number *e*₀ such that eml(*e*₀, *x*) = *x* for all *x*. It fails a host of other algebraic laws with exotic names like "mediality," "flexibility," and "alternativity."

In the language of abstract algebra, EML defines a "wild magma" — a mathematical structure so free from constraints that it obeys no rules except the most basic ones. This is actually *useful*: it means that EML expressions have a unique structure, which is valuable for both theoretical analysis and practical computation.

"The EML magma is one of the most algebraically unruly natural structures we know of," says the research team. "And yet, from this wildness comes the power to generate all of mathematics."

### The Legendre Connection

Version 8 of the EML research program uncovered a beautiful hidden structure. When you feed an exponential into the second slot of EML, something magical happens:

**eml(x, eʸ) = eˣ − y**

The logarithm and exponential cancel, leaving just a simple subtraction! This identity connects EML to a deep idea in mathematics called the **Legendre transform**, which links functions to their "duals" and plays a central role in physics (it connects energy and momentum), economics (it connects supply and demand curves), and optimization (it connects primal and dual problems).

This means EML isn't just a computational trick — it sits at the intersection of analysis, geometry, and physics.

### The Orbit Problem

What happens when you feed EML's output back into itself? This is the "diagonal map": d(z) = eml(z, z) = eᶻ − ln z.

The research team proved that d(z) > z for *every* real number z. This means the diagonal map has no fixed points — no number stays in place. Every orbit shoots off toward infinity.

But *how fast*? The team proved that iterating d at least n times sends z at least n units higher: d^n(z) ≥ z + n. The actual growth is spectacularly faster — super-exponential, meaning faster than any tower of exponentials.

This connects EML to the theory of dynamical systems and chaos theory, opening up questions about the geometric structure of the "Julia set" of d(z) in the complex plane.

### A Flat Geometry in Disguise

Perhaps the most surprising V8 discovery is geometric. The EML operator defines a natural notion of "distance" through its Hessian matrix (the matrix of second derivatives). This distance is:

**ds² = eˣ dx² + (1/y²) dy²**

The first term, eˣdx², is an exponential stretching of the x-axis. The second term, (1/y²)dy², is the famous hyperbolic metric — the geometry of Escher's Circle Limit prints and of the mathematical universe underlying Einstein's special relativity.

And the curvature of this combined metric? **Zero.** It's perfectly flat, despite looking highly nonlinear. This means that locally, EML's geometry is as simple as ordinary Euclidean space — you can lay it out on a flat table without distortion.

### Machine-Verified Mathematics

Every theorem described in this article has been formally verified by a computer, using the Lean 4 proof assistant and its Mathlib mathematical library. This means the proofs aren't just "probably correct" — they have been checked down to the logical axioms, leaving no room for error.

The V8 formalization contains over 70 theorems across two Lean files, with zero unproven assertions (called "sorry" in the Lean world). This level of rigor is rare in mathematical research and ensures that every claim stands on absolutely solid ground.

### What Comes Next?

The biggest open problem in EML theory is deceptively simple to state: *how many EML operations does it take to compute the natural logarithm?*

We know it takes between 3 and 5 operations, but the exact answer remains unknown. Closing this gap would require new lower-bound techniques — and developing these techniques could have implications far beyond EML, potentially connecting to deep questions in computational complexity theory.

Other open frontiers include:
- **The Julia set**: What does the fractal boundary of d(z) look like in the complex plane?
- **Neural networks**: Can EML-based architectures compete with or surpass traditional neural networks?
- **The Sheffer classification**: EML is one example of a "Sheffer operator" — are there others, and can they be classified?
- **Physical laws**: Can the fundamental equations of physics be expressed more compactly in EML notation?

### The Bigger Picture

EML is a reminder that mathematics still holds surprises. A simple formula — just an exponential minus a logarithm — turns out to contain the seeds of all elementary functions, the geometry of curved space, the dynamics of chaos, and the algebra of freedom.

It's as if someone discovered that a single Lego brick, if you knew the right way to connect copies of it, could build any structure ever imagined.

The EML operator is that brick. And we're just beginning to learn what it can build.

---

*The EML V8 results are formalized and verified in Lean 4 with Mathlib. The research is ongoing, with over 70 new theorems in V8 alone, bringing the total to 300+.*

*For more information, see the technical paper: "The EML Operator: New Structure from a Single Binary Function, V8."*
