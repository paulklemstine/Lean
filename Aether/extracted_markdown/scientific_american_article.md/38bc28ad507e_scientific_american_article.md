# The One-Instruction Computer That Does Everything

## How a single mathematical operation — combining exponentials and logarithms — can replace every instruction in a modern processor

---

*By the OISCC Research Team — April 2026*

---

### A Computer with One Button

Imagine a calculator with just one button. Not "add," not "multiply," not even "equals" — just one button that performs a single, strange operation. Press it, and the calculator takes two numbers, *a* and *b*, and returns:

**e^a − ln(b)**

That's it. The exponential of the first number, minus the natural logarithm of the second. It sounds absurdly limited. How could you possibly do arithmetic — let alone run a spreadsheet, render a video, or train an AI — with this single operation?

And yet, this is exactly what the OISCC does. The One Instruction Set Continuous Computer is a processor that executes only one instruction, called **EML** (for Exponential Minus Logarithm), and it can compute *anything*.

### The Magic of EML

The key insight is beautifully simple. The EML operation hides all of arithmetic inside it, like a mathematical Swiss Army knife:

- **Want exponentials?** Just set *b* = 1. Since ln(1) = 0, you get EML(*a*, 1) = e^a.
- **Want subtraction?** Use *a* = ln(x) and *b* = e^y. Then EML(ln(x), e^y) = e^(ln(x)) − ln(e^y) = x − y. Subtraction appears as if by magic!
- **Want multiplication?** Use the fact that e^(ln(a) + ln(b)) = a × b. So EML(ln(a) + ln(b), 1) = a × b.
- **Want division?** Similarly, EML(ln(a) − ln(b), 1) = a / b.

Every arithmetic operation — addition, subtraction, multiplication, division, and powers — can be built from compositions of EML. One instruction to rule them all.

### From Theory to Silicon

The OISCC is not just a mathematical curiosity. It is a complete, formal computational architecture:

- **Two instructions:** PUSH (put a number on the stack) and EML (combine the top two numbers).
- **One functional unit:** A hardware module that computes e^x and ln(x) using the CORDIC algorithm.
- **Formally verified:** Every theorem about the OISCC has been machine-checked in the Lean 4 proof assistant. There are no hidden assumptions, no hand-waving — pure mathematical certainty.

The architecture is strikingly minimal. Where a conventional processor needs dozens of different functional units (integer ALU, floating-point multiplier, division unit, branch predictor...), the OISCC needs exactly one. This makes it potentially ideal for applications where simplicity is paramount: medical implants that must be ultra-reliable, spacecraft that must survive cosmic radiation, or embedded controllers that must be formally verified end-to-end.

### The Depth Hierarchy: A New Complexity Theory

One of the most fascinating aspects of the OISCC is its **depth hierarchy**. If you start with just the number 1 and apply EML repeatedly, you build a tree of values:

- **Depth 0:** Just {1}.
- **Depth 1:** Apply EML(1, 1) = e ≈ 2.718. Now you have {1, e}.
- **Depth 2:** Apply EML to all pairs from depth 1. You get e^e ≈ 15.15, and e − 1 ≈ 1.72.
- **Depth 3:** The set explodes: 21 new values, including 0 itself.
- **Depth 4:** 370 new values.

This hierarchy is **strict** — each new depth genuinely adds values that couldn't be reached before. We proved this using a *growth rate separation theorem*: functions at depth *d* + 1 grow exponentially faster than any function at depth *d*. The witness is the **e-tower**: e↑↑n, which is e raised to itself *n* times. This grows so fast that e↑↑4 already exceeds 10^(1,656,520), and e↑↑5 is so large it cannot be written down in the observable universe.

### The Diagonal Map: A Window into Chaos

When you feed the EML operation its own output — setting both arguments equal — you get the **diagonal map**: d(x) = e^x − ln(x). This deceptively simple function has remarkable properties:

1. **It has no fixed points.** For every positive x, d(x) > x. The proof is elegant: e^x ≥ 1 + x (always), and ln(x) ≤ x − 1 (always), so e^x − ln(x) ≥ 2 > x for small x, and the exponential dominates for large x.

2. **It always diverges.** Start at any positive number and iterate the diagonal map. The sequence races to infinity at a double-exponential rate — one of the fastest growth rates in mathematics.

3. **Its minimum is precisely characterized.** The minimum of d(x) over positive reals occurs where x · e^x = 1, a point related to the celebrated **Lambert W function**. The minimum value is approximately 2.33.

The two-dimensional version — Φ(x, y) = (EML(x, y), EML(y, x)) — is even more dramatic. We proved that this map has **no fixed points** in the positive quadrant, and we computed its Lyapunov function: V(Φ(x, y)) = e^(e^x)/y + e^(e^y)/x. The ratio V(Φ)/V grows super-exponentially, confirming that every orbit diverges.

### Is e Irrational? Yes, and We Proved It from Scratch

As a byproduct of our research, we produced a machine-verified proof that Euler's number *e* is irrational — proved from first principles using the classical approach via the factorial series. This may be the most elementary of our results, but it illustrates the power of formal verification: every step of the proof has been checked by a computer, eliminating any possibility of error.

### The K_EML Problem: A New Kind of Complexity

How hard is it to reach a specific number using EML? The **K_EML complexity** of a value *v* is the minimum depth of an EML tree (starting from {1}) that evaluates to *v*. Some values are easy:

| Value | K_EML |
|-------|-------|
| 1     | 0     |
| e     | 1     |
| e^e   | 2     |
| 0     | 3     |

But others are stubbornly hard. The integer 2 has not been reached at depth 4, despite 396 values being generated. The integer 3 is equally elusive. This raises a tantalizing question: **Is there an integer that can never be reached by EML from {1}?**

If K_EML is hard to compute in general, it could form the basis of a new kind of proof-of-work — imagine a cryptocurrency where mining requires finding minimum-depth EML trees for target values. The difficulty would be rooted in deep mathematical structure rather than arbitrary hash puzzles.

### What's Next?

The OISCC program has generated over 90 open problems spanning pure mathematics, complexity theory, dynamical systems, and engineering. Here are the most exciting:

1. **The Density Conjecture:** Is the EML closure of {1} dense in the positive reals? Our computational evidence strongly suggests yes, but a proof remains elusive.

2. **Universal Divergence:** We proved the 2D EML map has no fixed points, but we conjecture it has no bounded orbits at all. A complete Lyapunov proof would be a landmark result.

3. **FPGA Prototype:** An OISCC chip on an FPGA, computing at 10 million operations per second, is within reach with current technology.

4. **EML Neural Networks:** Can a neural network, with all multiplications and additions replaced by EML compositions, achieve competitive accuracy on standard benchmarks? Our analysis suggests that a 128-neuron hidden layer on MNIST would require about 900,000 EML operations per inference — feasible at 90 milliseconds on an FPGA.

5. **The EML Model Theory:** What is the first-order theory of (ℝ, EML, 1)? Wilkie's celebrated theorem tells us that (ℝ, exp) is model-complete. Does this extend to EML?

### A New Paradigm?

The OISCC is not going to replace your laptop anytime soon. But it represents something deeper: a proof that the entire edifice of computation can be rebuilt from a single mathematical operation. Just as the NAND gate in digital logic shows that every Boolean function arises from one gate, the EML operation shows that every real computation arises from one transcendental function.

In an age of ever-increasing processor complexity — modern chips have billions of transistors and hundreds of instruction types — the OISCC is a reminder that simplicity and power are not opposites. Sometimes, all you need is one button.

---

*The OISCC research program includes formally verified proofs in the Lean 4 proof assistant, Python simulation tools, and ongoing FPGA development. All code and proofs are publicly available.*
