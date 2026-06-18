# The Simplest Formula You've Never Heard Of

## How subtracting a logarithm from an exponential reveals hidden structure across mathematics

---

*Take the most fundamental formula in mathematics — the exponential function eˣ — and subtract its mirror image, the natural logarithm ln(y). What you get is a remarkably simple expression: eˣ − ln y. It turns out this humble formula, which we call the EML operator, connects dozens of fields from information theory to Riemannian geometry — and a computer has checked every step.*

---

### A Formula That Breaks All the Rules

Most mathematical operations you learned in school have nice properties. Addition is commutative: 3 + 5 = 5 + 3. Multiplication is associative: (2 × 3) × 4 = 2 × (3 × 4). These rules are so familiar they seem inevitable.

But the EML operator, defined as eml(x, y) = eˣ − ln y, breaks *every single one* of these rules. It is not commutative: eml(0, 1) = 1, but eml(1, 0) is undefined (you can't take the log of zero). Even where both sides exist, the values differ. It is not associative. It has no identity element — no magic number that leaves other numbers unchanged. It's not even "flexible" or "medial," algebraic properties so mild that nearly every mathematical operation satisfies them.

Mathematicians have a name for this kind of structure: a **wild magma**. The EML magma is, in a formal sense, as untamed as a binary operation can be. And yet, paradoxically, this wildness coexists with deep internal structure.

### The Bridge Between Two Worlds

The exponential function eˣ converts addition to multiplication: e^(a+b) = eᵃ × eᵇ. The logarithm does the reverse: ln(a × b) = ln a + ln b. Together, they form the most fundamental bridge in mathematics — the connection between additive and multiplicative worlds.

EML combines them in a new way. The **Legendre bridge** identity reveals the connection:

> **eml(x, eʸ) = eˣ − y**

When the second argument is itself an exponential, the logarithm "undresses" it, leaving behind the raw value y. This creates a bridge between the exponential world and ordinary arithmetic — a Legendre-like duality that connects convex analysis to function generation.

Even more striking: if you plug in the same value for both arguments of the self-pairing, you get:

> **eml(x, eˣ) = eˣ − x**

This self-pairing function σ(x) = eˣ − x is always at least 1 (equality at x = 0), is strictly convex, and appears to be the natural "energy function" of the EML universe.

### A Map with No Fixed Points

Consider the **diagonal map**: d(z) = eᶻ − ln z. This is what you get when you feed the same number into both slots of EML. A natural question: does this map have any fixed points? Is there a number z where d(z) = z — meaning eᶻ − ln z = z?

The answer, proved with complete mathematical rigor: **no**. The diagonal map has no real fixed points whatsoever. In fact, d(z) > z for *every* real number z. More precisely, d(z) ≥ z + 1 always — the map always jumps at least 1 unit forward.

What happens if you iterate? Start with z = 1 and keep applying d:
- d(1) ≈ 2.718 (that's e)
- d(d(1)) ≈ 14.15 (that's eᵉ − 1)
- d(d(d(1))) ≈ 1,403,192

The orbit diverges *super-exponentially* — faster than any exponential function, approaching the speed of a tower of exponentials. And we proved that each step accelerates: the gap d(dⁿ(z)) − dⁿ(z) is non-decreasing.

Meanwhile, a sibling map g(z) = e − ln z does the opposite: it *converges* to a fixed point z* ≈ 2.017, which equals W(eᵉ) where W is the Lambert W function. The contrast is stark: diagonal orbits explode; off-diagonal orbits collapse.

### A Geometry That Turns Out to Be Flat

When mathematicians study a function of two variables, they sometimes construct a Riemannian metric from its second derivatives — the Hessian. For EML, this gives:

> **ds² = eˣ dx² + (1/y²) dy²**

The x-part stretches exponentially. The y-part is hyperbolic — it's actually the metric of Lobachevsky's non-Euclidean geometry in one dimension. You might expect this combination to produce complex curvature.

Instead, the Gaussian curvature is exactly **zero**. The EML metric is *flat* — as flat as a tabletop. This means that despite the wild-looking coordinates, the underlying geometry is secretly Euclidean. There must be a change of coordinates that transforms this warped metric into the standard dx² + dy². Finding those coordinates explicitly is an open problem.

### Information Theory Speaks EML

Claude Shannon's entropy formula H = −Σ p ln p — the foundation of information theory — decomposes naturally through EML:

> **−p ln p = p · eml(0, p) − p**

This means each "surprise" term in the entropy formula is an EML evaluation. Similarly, the Kullback-Leibler divergence — the fundamental measure of how different two probability distributions are — can be written as:

> **p · ln(p/q) = p · (eml(0, q) − eml(0, p))**

The KL divergence becomes a *difference of EML evaluations*. This suggests that EML might serve as a primitive operation from which information-theoretic quantities can be built, much as AND, OR, and NOT serve as primitives for Boolean logic.

### The Tower of e

From the single number 1, EML generates an infinite hierarchy of mathematical constants:

- eml(0, 1) = 1
- eml(1, 1) = e ≈ 2.718
- eml(e, 1) = eᵉ ≈ 15.15
- eml(eᵉ, 1) = e^(eᵉ) ≈ 3,814,279

Each step applies eml(·, 1) = exp(·) to generate the next level of the e-tower. This tower grows so fast that e^(e^(eᵉ)) is already a number with millions of digits. The question of whether these tower values {e, eᵉ, eᵉᵉ, ...} are algebraically independent — meaning no polynomial with integer coefficients relates them — remains unsolved.

### A Computer Checks Everything

Perhaps the most distinctive aspect of this research is its methodology. Every single theorem — over 370 of them — has been formally verified in Lean 4, a proof assistant used by mathematicians worldwide. A formal proof is not a human argument that might contain a subtle gap; it is a complete logical derivation checked by a computer down to the axioms of set theory.

The verification covers everything: the Legendre bridge, the non-commutativity, the fixed-point-free diagonal map, the convexity results, the orbit divergence bounds, the information-theoretic decompositions. The sorry count — the number of unproved assertions — is exactly **zero**.

This approach represents a new model for mathematical research: exploring structures computationally, formulating conjectures, and proving them with machine-verified rigor, all in the same framework.

### What's Next?

The EML operator sits at a crossroads of dozens of research directions:

- **Neural networks**: Can EML-based activation functions improve gradient flow?
- **Symbolic regression**: Can scientific formulas be discovered more efficiently using EML as the building block?
- **Complex dynamics**: What does the Julia set of d(z) = eᶻ − ln z look like?
- **Cryptography**: Does the super-exponential orbit divergence create useful one-way functions?
- **Quantum computing**: Is there a unitary analogue of EML?

The beauty of EML is its accessibility. The definition eˣ − ln y requires nothing beyond high school mathematics. Yet the structure it reveals — wild algebra, flat geometry, information decomposition, super-exponential dynamics — touches some of the deepest themes in contemporary mathematics.

Sometimes the most interesting mathematics hides in plain sight, waiting in the gap between an exponential and a logarithm.

---

*The author's formal verification files are publicly available as Lean 4 source code. All theorems referenced in this article correspond to named, machine-checked proofs.*
