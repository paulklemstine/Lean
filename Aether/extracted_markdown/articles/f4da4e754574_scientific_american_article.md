# The One Equation to Rule Them All

## How a single mathematical operation replaces every button on your scientific calculator

*By the Research Team — April 2026*

---

### A Calculator With Two Buttons

Pick up a scientific calculator. It has dozens of buttons: sine, cosine, square root, logarithm, exponential, plus, minus, times, divide, and many more. Each represents a distinct mathematical operation that took centuries to discover and formalize. Students spend years learning them. Engineers rely on all of them daily.

Now imagine throwing all of those buttons away — except two.

One button is simply the number **1**. The other performs a single operation called **EML**: it takes two inputs, *x* and *y*, and returns **e^x − ln(y)**, where *e* is Euler's number (approximately 2.718) and *ln* is the natural logarithm.

That's it. With just these two buttons, you can compute *everything* a full scientific calculator can: addition, subtraction, multiplication, division, square roots, powers, sines, cosines, tangents, logarithms of any base, hyperbolic functions, the number π, the imaginary unit *i* — the complete repertoire of what mathematicians call the *elementary functions*.

This stunning discovery was made by physicist Andrzej Odrzywolek of Jagiellonian University in Kraków, Poland, through a systematic computer-aided search. The result, now being explored by researchers worldwide, may reshape how we think about mathematical computation from the ground up.

---

### The Digital Precedent

To appreciate why EML matters, consider its closest relative: the NAND gate.

In digital electronics, the NAND gate (short for "NOT AND") is a single logical operation that can replicate any Boolean circuit. Every computer chip in existence — from the processor in your phone to the servers running the internet — can, in principle, be built entirely from NAND gates. This was proven by Henry Sheffer in 1913, and the result is considered one of the foundational insights of digital computing.

The NAND gate works in the world of 0s and 1s. But mathematics also has a continuous world: the real numbers, where functions like sine and exponential live. For over a century, nobody found an analogous universal primitive for this continuous domain. The conventional wisdom was that you needed at least a handful of distinct operations — exponential, logarithm, addition, maybe a few more.

EML shatters that assumption. It is the first *continuous Sheffer operator*: a single binary function from which all elementary mathematics can be reconstructed.

---

### How It Works

The magic begins with two simple observations:

**First:** EML with *y* = 1 gives you the exponential function, because ln(1) = 0, so eml(x, 1) = e^x.

**Second:** A clever three-step nesting recovers the logarithm: ln(z) = eml(1, eml(eml(1, z), 1)).

Once you have both *e^x* and *ln(x)*, everything else follows through known mathematical identities. Multiplication, for instance, becomes exp(ln(x) + ln(y)). Trigonometric functions emerge via Euler's formula, e^(iθ) = cos(θ) + i·sin(θ), once you generate the imaginary unit *i* (which itself comes from ln(−1)).

The complete chain of constructions looks like a family tree — Odrzywolek calls it a "phylogenetic tree" of mathematics, with EML and the digit 1 as the common ancestor.

---

### Trees All the Way Down

Perhaps the most beautiful consequence of the EML discovery is structural. Every mathematical expression, no matter how complex, can be written as a binary tree in which every internal node performs exactly the same operation: EML. The leaves are either the constant 1 or input variables.

This tree grammar is astonishingly simple:

> **S → 1 | x | eml(S, S)**

That's the complete specification. The number of possible trees with *n* nodes follows the famous Catalan number sequence: 1, 1, 2, 5, 14, 42, 132, ... These same numbers count the ways to parenthesize expressions, the number of paths on a grid, the number of triangulations of a polygon, and dozens of other combinatorial structures.

In other words, the space of all elementary mathematical formulas has the same shape as some of the best-studied objects in combinatorics. This wasn't known before, and it opens doors to powerful counting and enumeration techniques for mathematical expressions.

---

### A New Tool for AI

The EML representation has an immediate application that excites machine learning researchers: *symbolic regression*.

Symbolic regression is the problem of discovering a formula from data. Given a table of input-output pairs, can a computer figure out that the underlying law is, say, F = ma or E = mc²? Current approaches use grammars with many different operations (plus, times, sin, exp, ...), creating irregular search spaces that are hard to optimize.

EML changes the game. Because every elementary function is an EML tree, you can create a "master formula" — a parameterized EML tree of fixed depth — and train it like a neural network. Each parameter is a soft switch choosing between the constant 1, the input variable *x*, or the output of a child EML node. Training uses standard gradient descent (the Adam optimizer, for instance).

When the underlying law is truly elementary, something remarkable happens: the trained parameters *snap* to exact 0-or-1 values, recovering the precise symbolic formula. It's like training a neural network that, instead of producing an opaque black box, outputs a readable equation.

Odrzywolek's experiments show 100% success rate for formulas at EML depth 2, about 25% at depths 3–4, and the success rate decreases at greater depths. The architecture is sound — perturbing correct weights and re-training always recovers the formula — but navigating the optimization landscape from random initialization becomes harder for deeper trees.

---

### Analog Computing Renaissance

There's another, more physical application: building EML circuits.

Analog computers — machines that compute with continuous voltages rather than digital bits — were the workhorses of engineering computation before the digital revolution. They're experiencing a renaissance now, driven by the energy costs of digital AI and the inherent efficiency of analog for certain tasks (like solving differential equations in real time).

A persistent challenge in analog computing is implementing arbitrary mathematical functions in hardware. Traditionally, each function (sin, log, sqrt, ...) needs its own dedicated circuit. EML changes this: you need only one circuit element, the EML gate, which performs exp on one input and −ln on the other, then subtracts. Wiring these gates into binary trees gives you any elementary function.

This is directly analogous to how digital computers are built from NAND gates. The EML gate could become the universal building block for analog computation.

---

### The Complexity Question

Not all elementary functions are created equal in the EML world. The exponential function is cheap — just one EML application. The logarithm costs 7 symbols. Multiplication costs 17 in optimized form. The constant π requires over 53 symbols in the most compact known EML representation.

This creates a natural complexity measure for mathematical expressions: their *EML depth* (or leaf count). Unlike traditional measures of formula complexity, EML depth is canonical — there's only one operation, so there's no ambiguity about what counts as "simple."

Some natural questions arise: What is the shortest EML expression for multiplication? For π? For sin(x)? These questions have the flavor of Kolmogorov complexity — the study of the shortest program that produces a given output — but in a much more structured setting.

---

### Open Frontiers

The EML discovery raises as many questions as it answers:

**Can we eliminate the constant 1?** EML requires the distinguished constant 1 as a terminal symbol. The NAND gate doesn't need a distinguished input — it can generate 0 and 1 from any input. Does a binary operator exist that generates all elementary functions from *any* starting value? Odrzywolek has identified a ternary candidate, T(x,y,z) = (e^x/ln(x)) × (ln(z)/e^y), for which T(x,x,x) = 1, but the binary case remains open.

**Is there a real-only Sheffer?** EML requires complex arithmetic internally (to generate i, π, and trigonometric functions). Can continuous universality be achieved purely over the real numbers? This seems unlikely, but hasn't been proven impossible.

**What about a unary Sheffer?** Could a single function f(x), combined with standard arithmetic (+, −, ×), generate all elementary functions? If so, it could serve as both a neural network activation function *and* an exact formula generator — a dream for interpretable AI.

**How does EML relate to the theory of computation?** The EML grammar S → 1 | eml(S, S) defines a formal language. What are its automata-theoretic properties? Is there a natural notion of EML-computable functions? How does EML complexity relate to circuit complexity in theoretical computer science?

---

### The Bigger Picture

The discovery of EML is a reminder that mathematics still holds fundamental surprises. For centuries, we've treated elementary functions as an irreducible collection of distinct objects: exponentials and logarithms here, trigonometric functions there, radicals somewhere else. The EML operator reveals that this diversity is illusory — they're all shadows of a single primitive.

This is a profound simplification, the kind of unification that has driven progress throughout the history of science. Maxwell unified electricity and magnetism. Einstein unified space and time. The Standard Model unified the electromagnetic, weak, and strong forces. Each unification revealed that apparent diversity concealed a deeper identity.

EML achieves something analogous in the realm of mathematical functions. It shows that the dozens of operations on a scientific calculator are not fundamentally different — they are all compositions of one thing with itself.

Whether this insight leads to practical breakthroughs in computing, AI, or hardware design remains to be seen. But the mathematical fact itself is beautiful, surprising, and permanent. In a field as old as calculus, that alone is remarkable.

---

*The EML operator was discovered by Andrzej Odrzywolek at the Institute of Theoretical Physics, Jagiellonian University. The original paper, "All elementary functions from a single operator," is available as a preprint. Code and supplementary materials are in the SymbolicRegressionPackage repository.*
