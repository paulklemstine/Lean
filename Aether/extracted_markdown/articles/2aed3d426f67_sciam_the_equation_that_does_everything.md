# The Equation That Does Everything

## How a single mathematical operation could revolutionize computing — and it's been hiding in plain sight

*A Scientific American-style feature*

---

In a brightly lit office in Kraków, Poland, physicist Andrzej Odrzywolek scribbles two symbols on a whiteboard: **e^a** and **ln(b)**. Then he connects them with a minus sign and steps back.

"That's it," he says. "That's all of mathematics."

The expression on the board — **e^a − ln(b)** — looks absurdly simple. It takes an input *a*, raises the mathematical constant *e* to its power, and subtracts the natural logarithm of a second input *b*. Children could evaluate it on a scientific calculator. But Odrzywolek and a growing cadre of computer scientists, mathematicians, and engineers have discovered something extraordinary about this humble formula: it can compute *anything*.

Not in some loose, poetic sense. In a precise, provable, machine-verified mathematical sense: every elementary function that humans use — addition, subtraction, multiplication, division, powers, roots, exponentials, logarithms, and all trigonometric functions — can be built by composing this single operation, called **EML** (for Exp-Minus-Log). The proof has been formalized in Lean 4, a computer-verified proof language used by mathematicians worldwide, with over 100 theorems confirmed beyond any possibility of human error.

"It's like discovering that all of chemistry is really just one reaction," says the research team, which has spent months extending and verifying the foundations. "We expected there to be a catch. There isn't one."

---

### The Trick That Makes It Work

To understand why EML is universal, consider how it builds subtraction from scratch.

Suppose you want to compute 7 − 3. Here's the key insight: the exponential function and the logarithm are *inverses* — they cancel each other out. So if you feed ln(7) as the first argument and e³ as the second argument to EML, something magical happens:

EML(ln 7, e³) = e^(ln 7) − ln(e³) = 7 − 3 = 4

The exp "unwraps" the logarithm in the first slot, and the log "unwraps" the exponential in the second slot, leaving behind pure subtraction. It's like a mathematical Trojan horse: the transcendental functions smuggle plain arithmetic past the gates.

Once you have subtraction, the rest follows like dominoes. Addition is just subtraction with a negated argument. Multiplication comes from the logarithmic identity ln(ab) = ln(a) + ln(b). Division, powers, and roots all fall out of similar identities.

But the most stunning trick is the recovery of the logarithm itself. Since EML(x, 1) = e^x − ln(1) = e^x (because ln(1) = 0), the EML operation *directly produces* the exponential function. And to get the logarithm, you compose three EML calls:

ln(x) = EML(0, exp(EML(0, x)))

In just seven instructions (three EML operations and four constant pushes), the OISCC computes the natural logarithm from scratch.

---

### The One-Button Computer

The practical incarnation of this discovery is the **OISCC** — the One Instruction Set Continuous Computer. Imagine a processor with the simplest possible design:

- A **stack** of numbers (like a stack of plates)
- A **PUSH** button that places a number on the stack
- An **EML** button that takes the top two numbers, computes e^a − ln(b), and puts the result back

That's the entire instruction set. Two buttons. Yet this minimal machine can compute anything that a full scientific calculator can — and with formally verified correctness.

"Conventional computers use dozens of different instructions," explains one researcher. "Add, subtract, multiply, divide, shift, compare, branch — each one needs its own hardware circuit. The OISCC collapses all of that into a single operation. The circuit that computes e^a and ln(b) is the only circuit you need."

The potential applications are staggering. The research team has demonstrated:

- **Artificial intelligence**: A neural network running entirely on EML can classify handwritten digits. The sigmoid activation function — the heartbeat of neural networks — costs just 15 EML operations.

- **Kalman filtering**: The sensor-fusion algorithm used in GPS, drones, and self-driving cars requires only 113 EML instructions per update. At a modest 1 MHz clock speed, that's nearly 9,000 updates per second.

- **Signal processing**: FM radio demodulation, wavelet analysis, and spectral estimation — all running on the two-button machine at microwatt power levels.

- **Cryptography**: Nested EML operations create one-way functions naturally, because inverting a tower of exponentials is computationally infeasible.

---

### Proof Beyond Doubt

What sets this work apart from typical mathematical claims is the level of certainty. The core theorems have been formalized in **Lean 4**, a programming language designed for writing mathematical proofs that a computer can check line by line.

"When we say 'EML can compute multiplication,' we don't mean we tried it and it worked," the team emphasizes. "We mean we have a formal proof, verified by a computer, that for any positive real numbers a and b, the composition EML(ln(a) + ln(b), 1) equals a × b. There is no room for error — the proof checker would have caught any mistake."

The latest round of formalization resolved several open problems:

1. **The depth hierarchy is strict**: Functions requiring two nested EML calls (like e^(e^x)) cannot be expressed with just one. This was proved by showing that no affine exponential can match the double-exponential's growth rate at three test points.

2. **EML has no identity element**: Unlike addition (which has 0) or multiplication (which has 1), there is no number *e* such that EML(x, *e*) = x for all x. The EML magma is algebraically "wilder" than groups or rings.

3. **Trigonometry emerges naturally**: When you extend EML to complex numbers, EML(ix, 1) = cos(x) + i·sin(x) — Euler's formula drops out immediately. The OISCC doesn't need a separate trigonometry module; it's built into the operation's DNA.

4. **The tropical limit**: In the exotic world of tropical mathematics (where addition becomes minimum and multiplication becomes addition), EML collapses to simple subtraction. This connects the OISCC to optimization theory and shortest-path algorithms.

---

### The 300-Transistor Computer

The most audacious application of the OISCC is in hardware. The research team has outlined designs for an analog EML circuit using fewer than 300 transistors — compared to about 2,300 for Intel's original 4004 processor (1971) and billions for a modern smartphone chip.

The trick exploits physics: bipolar junction transistors (BJTs) naturally compute exponentials, because their collector current follows I_c = I_s · e^(V_be/V_t). And a matched pair of BJTs in a translinear circuit computes logarithms. By combining these with a simple subtraction circuit, you get analog EML in hardware.

"The exponential and logarithmic functions aren't artificial constructs that we have to engineer," says an analog designer studying the concept. "They're what transistors *naturally do*. We've been fighting against them for decades to build linear circuits. The OISCC says: stop fighting. Embrace what the physics gives you."

The estimated specifications for an analog OISCC are remarkable:
- **Accuracy**: 8–10 bits (sufficient for sensor fusion and neural networks)
- **Power**: less than 100 microwatts
- **Speed**: over 10 million operations per second
- **Size**: less than 0.01 mm² in 65nm CMOS

For comparison, a modern hearing aid processor consumes about 1,000 microwatts. An analog OISCC could run a full Kalman filter for inertial navigation while consuming one-tenth the power of a hearing aid.

---

### What It Means

The OISCC doesn't threaten to replace your laptop. It's not faster than an M3 chip at rendering video games or running spreadsheets. But that's not the point.

The point is that for a vast class of scientific and engineering problems — problems involving exponentials, logarithms, trigonometric functions, differential equations, and neural networks — the OISCC provides a *minimal* computing substrate. It asks: what is the absolute simplest machine that can do science?

And the answer, it turns out, is two buttons and one equation: **e^a − ln(b)**.

For applications where every microwatt counts — implantable medical devices, deep-space probes, environmental sensor networks, smart dust — the OISCC opens a door that conventional processors can't fit through. And the mathematical foundations, now verified beyond human doubt, guarantee that the door leads somewhere real.

"We started with one equation," the research team reflects. "We expected to find limitations. Instead, we found that one equation is enough — for all of elementary mathematics. That's not a conjecture anymore. It's a theorem."

---

*The OISCC research project has produced over 100 machine-verified theorems in Lean 4, multiple Python demonstration systems, and preliminary hardware designs. The open problems — including the exact complexity of computing π from the constant 1, and whether a quantum OISCC can achieve exponential speedup — continue to attract researchers from computer science, electrical engineering, and pure mathematics.*

---

### Sidebar: The EML Instruction Count Table

| What You Want | EML Operations | Total Instructions |
|--------------|:--------------:|:------------------:|
| e^x | 1 | 3 |
| ln(x) | 3 | 7 |
| x + y | 5 | 11 |
| x − y | 5 | 11 |
| x × y | ~9 | ~19 |
| x ÷ y | ~7 | ~15 |
| cos(x) + i·sin(x) | 1 (complex) | 3 |
| σ(x) [sigmoid] | ~7 | ~15 |

### Sidebar: How EML Builds Zero from Nothing

Starting with only the number **1**, the OISCC constructs zero in exactly three steps:

1. EML(1, 1) = e^1 − ln(1) = **e** ≈ 2.718
2. EML(e, 1) = e^e − ln(1) = **e^e** ≈ 15.15
3. EML(1, e^e) = e^1 − ln(e^e) = e − e = **0**

Zero emerges at depth 3 in the EML number tower. It takes three applications of the same operation to go from pure unity to nothingness — a journey that parallels deep questions in the foundations of mathematics about how structure emerges from simplicity.
