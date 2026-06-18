# One Operation to Rule Them All

## How a Simple Formula Captures All of Mathematics

*A journey into the surprising world of the EML operator — the mathematical equivalent of a Swiss Army knife*

---

Imagine you're stranded on a desert island with only a calculator. But this isn't any ordinary calculator — it has just **one button**. Press it, and it computes a single operation. Could you still do all of mathematics?

The answer, astonishingly, is **yes** — provided that button computes the right thing.

### The One Formula

The magic formula is deceptively simple:

> **eml(x, y) = eˣ − ln(y)**

That's it. The exponential of the first input, minus the natural logarithm of the second. Mathematicians call it the **EML operator** (for Exponential Minus Logarithm), and it may be the most powerful single formula in all of mathematics.

Starting from this operation and the number 1, you can reconstruct:
- Every number: 0, −1, π, √2, e, and every other mathematical constant
- Every operation: addition, subtraction, multiplication, division, powers, roots
- Every function: exponentials, logarithms, sines, cosines — everything you learned in school and far beyond

### How It Works: The First Steps

Let's start building mathematics from scratch.

**Step 1: Get the number e.**
Apply eml to 1 and 1: eml(1, 1) = e¹ − ln(1) = e − 0 = e ≈ 2.71828...

**Step 2: Get e^e.**
Apply eml to e and 1: eml(e, 1) = eᵉ − ln(1) = eᵉ ≈ 15.154...

**Step 3: Get zero.**
This is the clever part. Apply eml to 1 and eᵉ: eml(1, eᵉ) = e¹ − ln(eᵉ) = e − e = 0.

**Step 4: Get negative numbers.**
eml(0, eˣ) = e⁰ − ln(eˣ) = 1 − x. So from 0 and any number x, you get 1 − x.

**Step 5: Addition and subtraction.**
For any positive a: eml(ln a, eᵇ) = a − b. And eml(ln a, e⁻ᵇ) = a + b.

From here, multiplication follows (a × b = e^(ln a + ln b)), and with multiplication comes everything else.

### The NAND of Calculus

To understand why this matters, consider an analogy from computer science. Every computer chip — from your phone to the world's fastest supercomputer — is built from a single type of logic gate called **NAND**. This "Not-AND" gate can simulate any logical operation: AND, OR, NOT, and therefore any computation whatsoever. It is *functionally complete*.

The EML operator is the NAND gate of continuous mathematics. Where NAND operates on true/false values, EML operates on real numbers. Where NAND generates all Boolean functions, EML generates all *elementary functions* — the entire toolkit of calculus and beyond.

| Boolean World | Continuous World |
|--------------|-----------------|
| NAND gate | EML operator |
| {True, False} | ℝ (real numbers) |
| All Boolean functions | All elementary functions |
| Logic circuits | EML expression trees |

### A Tower of Constants

One of the most beautiful aspects of EML is how it generates constants. Starting from just the number 1, a cascade of increasingly exotic values emerges:

| EML Applications | Result | Value |
|-----------------|--------|-------|
| Start | 1 | 1.000 |
| eml(1, 1) | e | 2.718... |
| eml(e, 1) | eᵉ | 15.154... |
| eml(1, eᵉ) | 0 | 0 |
| eml(1, e) | e − 1 | 1.718... |

These constants form what mathematicians call the **e-tower**: 1, e, eᵉ, eᵉᵉ, ...

The e-tower grows unimaginably fast. The fourth term, eᵉᵉ ≈ 3,814,279. The fifth would have millions of digits. We've proved that this tower grows faster than *any* polynomial — faster than n², faster than n¹⁰⁰, faster than n^(any number you choose). In fact, we've proved the precise bound: each step multiplies by at least e.

### The Mystery of the Fixed Point

Here's a puzzle: if you start with a number and repeatedly apply the rule "replace z with e − ln(z)," where do you end up?

Starting from z = 2:
- 2 → 2.025 → 2.013 → 2.019 → 2.016 → 2.017 → ...

The numbers converge to a special value: **z* ≈ 2.01678**. This number satisfies the beautiful equation:

> z* + ln(z*) = e

And equivalently:

> z* × eᶻ* = eᵉ

This mysterious constant is connected to the *Lambert W function*, one of the more exotic special functions in mathematics: z* = W(eᵉ).

**Is z* transcendental?** Nobody knows. This seemingly simple question connects to some of the deepest unsolved problems in number theory, including Schanuel's conjecture — a sweeping claim about the algebraic independence of exponentials that, if true, would settle dozens of open problems at once.

### Proving It All: Machine-Verified Mathematics

In an age of increasing skepticism about mathematical claims, we've taken an extraordinary step: **every theorem in this paper has been formally verified by computer.**

Using Lean 4, a programming language designed for mathematical proofs, we've written over 160 theorems about EML — and every single one has been checked, line by line, by a machine. There are zero unproven claims (zero "sorries," in the language of formal verification).

This isn't just pedantry. Formal verification catches subtle errors that human mathematicians miss. It forced us to be precise about edge cases (What is ln(0)? What happens for negative numbers?) and uncovered several results we hadn't expected.

For instance, we discovered and proved that EML is **not power-associative** — meaning x ⊕ (x ⊕ x) ≠ (x ⊕ x) ⊕ x in general. This places the EML algebra outside the familiar world of groups, rings, and fields, in the more exotic territory of general magmas.

### The Tropical Shadow

If you take EML and "turn down the temperature" — a process mathematicians call *tropicalization* — something beautiful happens. The exponential becomes max, the logarithm becomes the identity, and the EML operator transforms into:

> tropical eml(x, y) = max(x, −y)

This simple formula recovers the *max-plus algebra*, a cornerstone of tropical geometry — a field that has revolutionized our understanding of algebraic geometry, optimization, and phylogenetics.

We've proved that tropical EML can compute:
- **max(x, y)** = trop(x, −y)
- **min(x, y)** = −trop(−x, y)
- **|x|** = trop(x, x)

So EML is universal in two worlds simultaneously: the classical world of exponentials and logarithms, and the tropical world of max and min.

### What's Next?

The EML operator opens dozens of research directions. Here are the most tantalizing:

**The Complexity Question.** We know that computing the logarithm requires between 3 and 5 EML operations. But which is it? Closing this gap would be a breakthrough in *EML complexity theory* — a new field with connections to circuit complexity and Kolmogorov complexity.

**The Fractal Frontier.** The diagonal map d(z) = eᶻ − ln(z), when extended to complex numbers, appears to generate intricate fractal Julia sets. We've proved that d has no fixed points and is convex, but the full picture of its complex dynamics remains mysterious.

**One Formula, No Constant?** We need the number 1 as a starting point. Could there exist an operator so powerful that it doesn't even need a starting constant? This is the *constant-free Sheffer problem*, and we conjecture the answer is no — but proving it would be a landmark result.

**Machine Learning.** EML trees provide an elegant representation for symbolic regression — the art of discovering mathematical formulas from data. With only one operation to optimize, the search space shrinks dramatically. Early experiments suggest this approach could compete with state-of-the-art methods.

### The Big Picture

The EML operator reminds us of a fundamental truth about mathematics: beneath the apparent diversity of formulas, functions, and operations lies a deep unity. Just as the diversity of life can be traced to a single ancestral cell, and the diversity of matter to a handful of elementary particles, the diversity of mathematics can be traced to a single operation.

eml(x, y) = eˣ − ln(y).

One formula. All of mathematics.

---

*The EML research project is ongoing. All 160+ theorems are publicly available as Lean 4 source code, and computational tools are provided as Python scripts. The research paper, formal proofs, and interactive demos are available in the project repository.*
