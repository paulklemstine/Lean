# The One Operation That Rules All of Mathematics

## How a single formula, exp(x) − ln(y), can compute anything — and what it means for science

---

*What if all of mathematics could be reduced to a single operation? A new line of research shows that it can — and the implications stretch from artificial intelligence to the fundamental nature of computation.*

---

### A Calculator with One Button

Imagine a calculator with just one button. Not addition. Not multiplication. A single mysterious operation that takes two numbers and returns a third. Could such a device compute everything a full scientific calculator can?

The answer, remarkably, is yes.

The operation is called **EML** — short for Exp-Minus-Log — and it works like this: given two numbers x and y, compute

> **eml(x, y) = eˣ − ln(y)**

where e ≈ 2.71828 is Euler's number, eˣ is the exponential function, and ln(y) is the natural logarithm.

With just this one operation and the number 1, you can reconstruct addition, subtraction, multiplication, division, powers, roots, trigonometric functions, logarithms — every function taught in a calculus course, and infinitely more.

### From NAND to EML

To understand why this matters, consider an analogy from computer science. In the 1910s, the American logician Henry Sheffer discovered that the logical operation NAND ("not both") is *universal*: every Boolean function can be built from NAND alone. This insight revolutionized circuit design. Today, billions of NAND gates power every computer on Earth.

EML does for continuous mathematics what NAND does for Boolean logic. Where NAND operates on true/false values, EML operates on real numbers. Where NAND generates AND, OR, and NOT, EML generates exp, log, sin, cos, and π.

The analogy goes deeper. NAND is the "Sheffer stroke" of logic — the minimal universal operator. EML is the **continuous Sheffer stroke**: the minimal universal operator for analysis.

### How It Works

The magic of EML lies in how exponentials and logarithms encode all of arithmetic.

**Getting exp**: eml(x, 1) = eˣ − ln(1) = eˣ. Just set the second input to 1.

**Getting the constant e**: eml(1, 1) = e¹ = e ≈ 2.718.

**Getting zero**: eml(1, eᵉ) = e − ln(eᵉ) = e − e = 0.

**Getting subtraction**: For any positive a, eml(ln(a), eᵇ) = a − b.

**Getting multiplication**: Since a × b = e^(ln(a) + ln(b)), we combine addition and exponentiation, both of which EML provides.

Each step builds on previous constructions, like a mathematical bootstrap. Starting from the single number 1 and the single operation eml, an entire universe of mathematics unfolds.

### The Complexity Question

How many EML operations does it take to compute a given function? This is the **EML complexity** K_EML(f), and it's one of the most tantalizing open questions in the field.

Some complexities are known exactly:
- exp(x): 1 operation (trivial)
- The constant e: 1 operation
- Zero: 3 operations
- exp(exp(x)): 2 operations

But the complexity of the *logarithm itself* — the very function that appears inside EML — remains open. We know it takes between 3 and 5 operations, but the exact answer is unknown. Closing this gap is the top priority of current research.

Even more dramatically, the complexity of multiplication (between 5 and 17 operations) and sine (between 5 and 53 operations) remain wide open.

### The Mountain That Cannot Be Climbed

One of the most beautiful results in EML theory concerns the **diagonal map**: d(z) = exp(z) − ln(z). This is what you get when you feed the same number into both inputs.

A natural question: does this map have a fixed point — a number z where d(z) = z, meaning exp(z) − ln(z) = z?

The answer is **no**. We have formally proved that d(z) > z for *every* real number z. The diagonal map always overshoots. Think of it as a mathematical mountain that you can never stand on top of — no matter where you start, the map pushes you higher.

Moreover, this mountain is **convex**: it has a single valley, a unique minimum, located at z₀ = W(1) ≈ 0.567, where W is the Lambert W function. At this point, the minimum "altitude" is d(z₀) ≈ 2.330 — the closest the diagonal map ever gets to the identity line.

### Towers to Infinity

The e-tower function e↑↑n is defined by iterating exponentiation: e↑↑0 = 1, e↑↑1 = e, e↑↑2 = eᵉ ≈ 15.15, e↑↑3 = e^(eᵉ) ≈ 3.8 million, and so on. By e↑↑4, the number is already incomprehensibly large — it has over a million digits.

We have formally proved that e↑↑n ≥ 2ⁿ for all n, and that the e-tower eventually exceeds any polynomial, any exponential, and any tower of fixed height. The e-tower grows so fast that it provides a natural measuring stick for computational complexity in the EML framework.

### The Shape of EML

The EML operator has a natural geometry. Its **Hessian matrix** — the matrix of second derivatives — is always positive definite:

> H = diag(eˣ, 1/y²)

This means EML is jointly strictly convex: its graph curves upward in every direction. The Hessian defines a **Riemannian metric** on the half-plane {(x, y) : y > 0}, turning EML into a landscape with its own notion of distance, geodesics, and curvature.

This geometric structure has practical implications. In machine learning, the "natural gradient" method uses the inverse Hessian to scale gradient steps, adapting automatically to the local curvature of the loss landscape. The EML metric provides exactly this kind of adaptive geometry for optimizing EML-based models.

### The Tropical Shadow

There is a beautiful limit where EML simplifies dramatically. If we rescale the inputs by a small parameter ε — replacing eml(x,y) with ε·eml(x/ε, y/ε) — and let ε → 0, we get the **tropical EML**:

> trop(x, y) = max(x, −y)

This single tropical operation recovers the entire max-plus algebra:
- max(x, y) = trop(x, −y)
- min(x, y) = −trop(−x, y)
- |z| = trop(z, z)

The tropical EML is to piecewise-linear functions what the standard EML is to smooth functions — a single universal building block.

### An Alien Algebra

The EML operator, viewed as a binary operation on real numbers, forms what algebraists call a **magma** — a set with a binary operation, and nothing else. No familiar algebraic law holds:

- **Not commutative**: eml(0, 1) ≠ eml(1, 0)
- **Not associative**: eml(eml(0,1), 1) ≠ eml(0, eml(1,1))
- **Not power-associative**: eml(0, eml(0,0)) ≠ eml(eml(0,0), 0)
- **No identity element**: There is no number e₀ such that eml(e₀, x) = x for all x

The failure of power-associativity is especially striking. Even exotic algebras like octonions and sedenions are power-associative. The EML magma lives outside all standard algebraic categories — it is a genuinely new kind of mathematical object.

### A Fixed Point in the Wilderness

While the diagonal map has no fixed point, a closely related iteration does. The map g(z) = e − ln(z) has a unique attracting fixed point:

> z* ≈ 2.01712

This mysterious constant satisfies z* + ln(z*) = e and z* · exp(z*) = eᵉ. It can be expressed as z* = W(eᵉ), where W is the Lambert W function.

Is z* transcendental? Almost certainly, but proving it would require major advances in transcendence theory — possibly Schanuel's conjecture, one of the deepest open problems in number theory.

### Applications: From AI to Hardware

The EML framework opens practical applications in several directions:

**Symbolic Regression**: Instead of searching an exponentially large space of mathematical formulas, EML reduces the search to optimizing the parameters of a fixed-structure binary tree. Each n-node EML tree is parameterized by at most 5·2ⁿ⁻⁶ real numbers, compared to the combinatorial explosion of traditional symbolic regression.

**Neural Networks**: EML trees can serve as interpretable alternatives to neural network layers, offering exact mathematical expressions instead of opaque weight matrices.

**Hardware**: A single hardware unit computing eml(x,y) could replace the multiple arithmetic and transcendental units in a conventional floating-point processor, potentially simplifying chip design.

**Physics**: EML naturally combines the two functions most fundamental to physics — the exponential (Boltzmann factors, radioactive decay, wave functions) and the logarithm (entropy, information, decibels).

### What Comes Next

The EML program has formalized over 200 theorems in the Lean proof assistant, with zero unproved claims (zero "sorry's" in the formal development). This level of rigor is unusual in exploratory mathematics and provides a solid foundation for future work.

The most pressing open problems include:
1. **The logarithm complexity gap**: How many EML operations does ln(x) really need?
2. **The Sheffer classification**: What other operators share EML's universality?
3. **The constant-free conjecture**: Can any single binary operator generate all elementary functions without a distinguished constant?

These questions connect to fundamental issues in computability, complexity theory, and the philosophy of mathematics: What is the minimum structure needed to generate all of analysis?

The answer, it seems, might be simpler than anyone imagined. One operation, one constant, infinite mathematics.

---

*The EML operator was introduced by A. Odrzywolek in 2025. The formal verification described here uses the Lean 4 proof assistant with the Mathlib library.*
