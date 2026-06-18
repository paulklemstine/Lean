# The One-Equation Computer: How a Single Formula Can Do Everything

*A new kind of computer needs only one operation to perform all of mathematics*

---

Imagine a computer with no add instruction, no multiply instruction, no division—a computer that knows how to do exactly one thing. It sounds impossible, even absurd. Yet a remarkable mathematical discovery shows that a single equation is enough to compute *anything*:

$$\text{EML}(a, b) = e^a - \ln(b)$$

This elegant formula—the exponential of *a* minus the logarithm of *b*—is the beating heart of the OISCC, the **One Instruction Set Continuous Computer**, a theoretical machine that strips computing down to its absolute mathematical minimum.

## The Sheffer Stroke of Calculus

In 1913, Henry Sheffer showed that all of Boolean logic—AND, OR, NOT, and everything built from them—could be reduced to a single operation called the Sheffer stroke (NAND). This discovery transformed computer science and chip design. Every modern processor, from your smartphone to the world's fastest supercomputer, is built from NAND gates.

The EML operator does for continuous mathematics what the Sheffer stroke did for logic. Just as NAND generates all logical operations, EML generates all arithmetic and transcendental functions:

- **Exponentiation**: e^x = EML(x, 1)
- **Logarithm**: ln(x) = EML(0, exp(EML(0, x)))
- **Subtraction**: a − b = EML(ln a, exp b)
- **Addition**: a + b = EML(ln a, exp(−b))
- **Multiplication**: a × b = EML(ln a + ln b, 1)
- **Division**: a ÷ b = EML(ln a − ln b, 1)
- **Powers**: a^b = EML(b · ln a, 1)

Every formula you learned in school—every calculation a scientist, engineer, or financial analyst performs—can be built from this single operation and the number 1.

## A Computer with One Moving Part

The OISCC architecture is disarmingly simple. It has a stack (a column of numbers) and exactly two commands:

1. **PUSH v** — Put the number v on top of the stack
2. **EML** — Take the top two numbers, compute e^a − ln(b), and put the result back

That's it. No addition instruction. No multiplication instruction. No trigonometric functions. Just PUSH and EML.

To compute exp(3), for instance, the program is:
```
PUSH 3
PUSH 1
EML
```
Result: e³ ≈ 20.086.

To compute 5 − 2:
```
PUSH ln(5)    (≈ 1.609)
PUSH exp(2)   (≈ 7.389)
EML
```
Result: exp(ln 5) − ln(exp 2) = 5 − 2 = 3.

The programs get longer for complex operations, but the principle is always the same: combine EML calls to build any mathematical function you need.

## The Diagonal Map: Where Math Gets Deep

When you feed the same number into both inputs—EML(x, x) = e^x − ln(x)—you get what mathematicians call the **diagonal map**. This simple-looking function turns out to have extraordinary properties:

**It has no fixed points.** For every positive number x, e^x − ln(x) > x. The curve always sits above the line y = x. This was formally proved in Lean 4, a computer proof assistant that guarantees mathematical certainty beyond human error.

**It has a unique minimum.** The lowest point of the curve occurs at x* ≈ 0.567, which is the solution to the equation x · e^x = 1. This number is the famous **Lambert W(1)**, connecting EML to one of the most important special functions in mathematics.

**Every orbit diverges.** Start with any positive number, apply the diagonal map repeatedly, and the sequence rockets to infinity. Always. The function is like a mathematical rocket engine—there's no stable orbit, no equilibrium, no rest.

The minimum value d(x*) ≈ 2.333 has deep significance: it means the diagonal map always adds at least 2.333 at every step. This relentless growth is what makes EML so powerful for computation but so challenging for dynamical systems theory.

## Machine-Verified Mathematics

One of the most innovative aspects of the OISCC program is its use of **formal verification**. Every major theorem about EML has been proved not just by human mathematicians, but by a computer proof assistant called Lean 4. These are not numerical checks or simulations—they are complete, rigorous logical proofs that have been verified down to the axioms of mathematics.

Among the 170+ machine-verified theorems:

- EML generates all basic arithmetic operations ✓
- The diagonal map has no fixed points ✓
- The diagonal map is strictly convex ✓
- EML(1, 1) = e is irrational ✓
- The depth hierarchy DEPTH(1) ⊊ DEPTH(2) ✓
- The EML semigroup has no idempotents ✓

This level of verification is unusual in mathematics. Most published proofs rely on human checking, which is fallible. The OISCC program's combination of beautiful mathematics and iron-clad verification represents a new paradigm for mathematical research.

## 80 Open Questions and 7 Frontiers

The OISCC research program has identified over 80 open problems, organized into seven frontiers:

**Pure Mathematics (20 problems):** Is the EML closure of {1} dense in the real numbers? Can the depth hierarchy be proved to be strictly infinite? What is the transcendence degree of EML-reachable constants?

**Complexity Theory (15 problems):** What is the minimum-depth EML tree that evaluates to 2? (Currently known: K_EML(2) > 4, meaning it takes more than 4 levels of nesting.) Can multiplication be proved to require at least 9 EML operations?

**Dynamical Systems (12 problems):** Does the 2D EML map have any bounded orbits? (Almost certainly not, but proving it rigorously remains open.) What are the Lyapunov exponents? Does the system exhibit chaos in any meaningful sense?

**Hardware Design (10 problems):** Can OISCC be implemented on an FPGA? As a custom chip? The minimalist architecture could lead to ultra-low-power processors for IoT devices and implantable medical electronics.

**Applications (12 problems):** Can a neural network run on OISCC? (Yes—we've demonstrated XOR classification.) Can it handle image recognition? Signal processing? Cryptography?

**Formal Verification (6 problems):** Can we prove the compiler correct? Can we formally verify floating-point error bounds? Can we decide whether two EML trees compute the same function?

**Cross-Domain Connections (10 problems):** What does EML look like through the lens of category theory? Tropical geometry? Information theory?

## Why It Matters

The OISCC is not just an intellectual curiosity. Its radical simplicity has practical implications:

**Ultra-simple hardware.** A processor that needs only one functional unit (exp/ln via CORDIC) could be manufactured at lower cost and power than conventional chips. For edge computing and IoT, where every milliwatt counts, OISCC could be transformative.

**Provably correct computing.** Because the instruction set is so small, formal verification of OISCC hardware and software is far more tractable than for complex architectures like x86 or ARM. This matters for safety-critical applications in aerospace, medicine, and autonomous vehicles.

**Mathematical unification.** EML reveals that the exponential and logarithm are not just important functions—they are, in a precise sense, the *only* functions you need. This is a new perspective on the foundations of analysis, connecting to deep questions about the structure of the real number line.

## The Road Ahead

The OISCC research program is in its early stages, with a 5-year roadmap stretching to 2031. Near-term goals include an FPGA prototype, a complete depth-5 enumeration of EML-reachable values, and a demonstration of MNIST handwritten digit classification on an OISCC simulator.

Longer-term, the program aims for a custom ASIC chip, 500+ machine-verified theorems, and real-world deployment in niche applications. The dream is an ecosystem of ultra-simple, formally verified, mathematically elegant computing devices.

Whether OISCC achieves commercial success or remains a theoretical landmark, it has already accomplished something rare in mathematics: it has shown that the entire edifice of elementary computation rests on a single, beautiful equation.

$$e^a - \ln(b)$$

One formula. All of mathematics. Verified by machine.

---

*The OISCC research program is an ongoing collaboration combining pure mathematics, computer science, and formal verification. All results are open-source and machine-verified in the Lean 4 proof assistant.*
