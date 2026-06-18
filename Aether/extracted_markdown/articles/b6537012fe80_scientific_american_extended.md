# Mathematics' Best-Kept Secret: The One Formula That Does Everything

## How a physicist's discovery of a single equation that replaces your entire calculator could reshape computing, AI, and our understanding of mathematical structure

*A Scientific American–Style Feature — April 2026*

---

### The Challenge

Imagine you are stranded on a desert island with a calculator that has only two buttons. One button enters the number 1. The other performs a cryptic operation called EML, which takes two numbers and returns a result. Can you do anything useful?

The astonishing answer, proven in 2025 by physicist Andrzej Odrzywolek of Jagiellonian University in Poland, is: *you can do everything*. Every calculation a scientist, engineer, or mathematician might need — from simple addition to the intricacies of quantum wave functions — can be performed by pressing these two buttons in the right sequence.

The operation is simple to state: EML takes two inputs, call them *x* and *y*, and returns *e* raised to the power *x*, minus the natural logarithm of *y*. In symbols: **eml(x, y) = eˣ − ln(y)**. That's it. This single formula, paired with the number 1, is mathematically equivalent to every button on a scientific calculator combined.

---

### Why It Matters

This result is the continuous analogue of one of the most important discoveries in the history of computing.

In 1913, mathematician Henry Sheffer proved that a single logical operation called NAND (short for "NOT AND") could replace all of Boolean logic. Every digital circuit ever built — from pocket calculators to supercomputers to the chip in your smartphone — can theoretically be constructed from NAND gates alone. This insight, now over a century old, remains foundational to computer engineering.

But NAND works only with 0s and 1s: the discrete, on-off world of digital logic. The real world is continuous. Physical quantities like temperature, velocity, and electromagnetic fields vary smoothly and are described by functions like sine, cosine, exponential, and logarithm — the so-called *elementary functions* that generations of students labor to master.

For over 100 years, mathematicians assumed these functions were irreducibly diverse. You might need exponentials for growth, logarithms for compression, trigonometry for oscillation, arithmetic for combination — at minimum, a handful of independent building blocks.

EML proves them wrong. One operation suffices.

---

### How It Works: The Bootstrap

The magic of EML lies in a bootstrapping process that starts from almost nothing and builds up all of mathematics. Here's the chain:

**Step 1: Create *e*.** Press [1], press [1], press [EML]. The calculator computes eml(1, 1) = e¹ − ln(1) = e − 0 = e ≈ 2.71828. You've just generated Euler's number from nothing but 1.

**Step 2: Create the exponential function.** For any number x already on your stack, compute eml(x, 1) = eˣ − ln(1) = eˣ. The exponential function falls out as a special case of EML.

**Step 3: Create the logarithm.** This is trickier but still works: ln(x) = eml(1, eml(eml(1, x), 1)). Three nested EML operations recover the natural logarithm.

**Step 4: Create zero.** Once you have *e* and exp, you can compute exp(e) and then eml(1, exp(e)) = e − ln(exp(e)) = e − e = 0.

**Step 5: Create negative numbers, then imaginary numbers.** From 0, a longer chain produces −1. From −1, the complex logarithm gives ln(−1) = iπ — Euler's iconic constant, which unlocks the imaginary unit *i* and the number π simultaneously.

**Step 6: Create trigonometry.** With *i* in hand, Euler's formula e^(ix) = cos(x) + i·sin(x) delivers all of trigonometry.

**Step 7: Create arithmetic.** Addition, subtraction, multiplication, and division all reduce to combinations of exp and log: for example, x × y = exp(ln(x) + ln(y)). Since exp and log are already available, so is all of arithmetic.

The entire edifice of elementary mathematics — hundreds of functions, dozens of identities — emerges from iterating a single two-input operation.

---

### Trees All the Way Down

One of the most elegant consequences of the EML discovery is structural. Every mathematical expression can be drawn as a binary tree: a branching diagram where each fork represents one EML operation, and each leaf is either the number 1 or an input variable.

The grammar is breathtakingly simple:

> **S → 1 | x | eml(S, S)**

Read this as: "An expression is either the constant 1, a variable, or the EML of two expressions." This three-rule grammar generates *all of elementary mathematics*.

The number of distinct tree shapes with *n* forks follows the famous *Catalan numbers*: 1, 1, 2, 5, 14, 42, 132, 429, ... These numbers appear throughout mathematics — in polygon triangulations, ballot counting, lattice paths — and now they count the shapes of mathematical formulas. It's as if the space of all possible equations has the same combinatorial skeleton as some of the best-understood objects in discrete mathematics.

---

### The Complexity Landscape

If every function can be built from EML, a natural question arises: *how complex is each function?* The EML complexity of a function is the minimum number of leaves (1s and variables) in its smallest EML tree.

Some functions are surprisingly cheap:
- The constant 1 costs 1 leaf (trivial)
- Euler's number *e* costs 3 leaves
- The exponential function exp(x) costs 3 leaves
- The natural logarithm ln(x) costs 7 leaves

Others are expensive:
- The constant 0 costs 7 leaves (you need a chain to cancel *e* against itself)
- Multiplication x × y costs at most 17 leaves
- The constant π costs at most 53 leaves
- Trigonometric functions like sin and cos require long chains through the complex numbers

This creates a natural "difficulty hierarchy" for mathematical operations. Simple functions like exp sit near the bottom; complex ones like sin(x) are high up. The hierarchy is determined purely by the structure of the EML operator — no human choices are involved.

---

### The Four Siblings

EML is not the only continuous Sheffer operator. It turns out there is a small family of related operators that all share the same power:

| Operator | Formula |
|----------|---------|
| **EML** | eˣ − ln(y) |
| **LEA** | ln(x) + eʸ |
| **anti-EML** | ln(x) − eʸ |
| **−EML** | −eˣ + ln(y) |

These four are related by two symmetries: *swapping* the inputs (x ↔ y) and *negating* the output. Together, they form a mathematical structure called the *Klein four-group* — the same structure that describes the symmetries of a rectangle.

There is also a fifth operator, EDL(x,y) = exp(x)/ln(y), which uses division instead of subtraction. It, too, is universal, but it doesn't belong to the same symmetry family as EML.

Are there others? That's an open question. But the evidence suggests that every continuous Sheffer operator must combine exponential growth with logarithmic compression through some non-commutative operation — a deep structural constraint on what "universality" requires.

---

### The Missing Button

There's one way in which EML is less powerful than NAND. The NAND gate needs no external constants: NAND(x, x) = NOT(x), and from NOT you can derive both 0 and 1. NAND is entirely *self-contained*.

EML, by contrast, requires the constant 1 as a seed. You cannot start from an unknown number x and build 1 — because eml(x, x) = eˣ − ln(x) depends on x and never produces a constant.

Does a truly self-contained continuous operator exist? Can some binary function B(x, y) generate all elementary functions from *any* starting value, with no distinguished constant?

This is one of the most tantalizing open problems in the field. The evidence — and expert intuition — suggests the answer is no. The continuous world may be fundamentally different from the discrete: you always need a seed.

---

### The Complex Detour

Here's a philosophical surprise: to compute purely real functions like sin(x) and cos(x), EML must pass through *complex numbers*. The chain goes from 1 to *e* to 0 to −1 to ln(−1) = iπ — and iπ is imaginary.

This is reminiscent of a deep principle in physics: quantum mechanics uses complex probability amplitudes to compute real-valued probabilities. In both cases, the complex numbers serve as a computational "workspace" — invisible in the final answer but essential to the calculation.

Can this detour through the complex plane be avoided? Almost certainly not. Sine and cosine oscillate, but no composition of real exponentials and logarithms can oscillate. You *need* the imaginary unit to make the connection, and you need complex logarithms to create it.

If proven rigorously, this would be a beautiful impossibility theorem: the complex numbers are not merely convenient for trigonometry — they are *necessary*.

---

### Applications on the Horizon

The EML discovery isn't just theoretically elegant. It opens practical doors:

**Symbolic Regression.** Scientists often have data and want equations. EML provides a natural parameterization: search over EML trees of increasing depth, fitting the parameters to data. This "EML symbolic regression" has been demonstrated in proof-of-concept systems and could complement AI methods like those used by the AI Feynman project.

**Neural Networks.** Replace standard neural network layers with EML trees. Each "neuron" computes eml(input₁, input₂), making the network intrinsically interpretable: after training, you can read off a symbolic formula from the parameters. This connects to the recent wave of Kolmogorov-Arnold Networks (KANs).

**Hardware Design.** A processor that implements only EML as its instruction would have radically simple control logic — the continuous analogue of a NAND-only chip. While impractical for general computing, such a design could find niche applications in specialized analog or neuromorphic hardware.

**Data Compression.** Mathematical formulas can be compressed to their EML tree representation: a topology (counted by Catalan numbers) plus leaf labels. This canonical encoding could be useful in computer algebra systems.

**Education.** A two-button calculator is a powerful teaching tool. Students can discover that mathematical complexity is less than it appears, and that the apparent diversity of mathematical operations hides a deep unity.

---

### The Bigger Picture

The EML discovery invites us to ask: what other minimal generating sets exist in mathematics?

Classical universal algebra studies this question for discrete structures: groups, rings, lattices. EML extends the question to the continuous, analytic world. We might call this emerging field *Continuous Universal Algebra*.

Key open questions include:
- Can EML-like operators be found for *special functions* (Bessel, Gamma, hypergeometric)?
- Is there a "quantum EML" — a single operation that generates all unitary transformations?
- Does EML complexity correlate with physical "fundamentalness"? Are simpler physical laws described by shorter EML trees?
- Can EML theory shed light on the Langlands program, which connects number theory to representation theory through functions that might have canonical EML representations?

These questions span the boundary between pure mathematics, theoretical physics, and computer science. They represent the opening moves in a game that could run for decades.

---

### The View from Two Buttons

Stand back and appreciate what has happened. A physicist in Kraków, searching systematically through combinations of exponentials and logarithms, found that the entirety of elementary mathematics — the mathematical toolkit that humanity has built over millennia — can be compressed into a single operation and a single number.

It's as if someone discovered that every word in every language can be spelled with just two letters. The words would be longer, certainly. But the alphabet would be as small as possible, and its structure would reveal hidden connections between words that no one had noticed before.

Mathematics, it turns out, is simpler than we thought. Not easier — simpler. Its complexity lies not in the diversity of its operations but in the depth of their composition. And from two buttons, everything follows.

---

*The author wishes to thank the EML research community for their contributions to this rapidly developing field.*
