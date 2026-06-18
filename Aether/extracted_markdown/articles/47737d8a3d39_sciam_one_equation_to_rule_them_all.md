# One Equation to Rule Them All

## How a Single Mathematical Operation Could Revolutionize Computing

*A Scientific American–Style Feature*

---

**What if every calculation your computer ever performs — from adding grocery prices to running artificial intelligence — could be reduced to a single operation?**

It sounds impossible. Modern processors have hundreds of distinct instructions: add, subtract, multiply, divide, compare, shift, and dozens more. Even the simplest pocket calculator needs separate circuits for each arithmetic operation. The idea that one equation could replace them all seems like a mathematical fantasy.

But that's exactly what a remarkable identity discovered in 2025 achieves. The operation is called **EML** (Exp-Minus-Log), and it looks like this:

$$\text{EML}(a, b) = e^a - \ln(b)$$

That's it. The exponential of one input, minus the natural logarithm of the other. From this single operation and the constant 1, you can build every arithmetic operation, every trigonometric function, every elementary function that mathematics has ever defined.

### The One-Instruction Computer

The machine that runs on this principle is called the **OISCC** — the One Instruction Set Continuous Computer. It has a stack (a tower of numbers) and exactly two commands:

- **PUSH**: Put a number on the stack.
- **EML**: Take the top two numbers off the stack, compute e^a − ln(b), and put the result back.

That's the entire instruction set. There is no ADD instruction, no MULTIPLY, no DIVIDE. Yet this machine can compute anything a conventional processor can.

### How Does It Work?

The magic lies in the intimate relationship between exponentials and logarithms. These two functions are inverses of each other: exp undoes log, and log undoes exp. The EML operator contains both, and by composing it cleverly, every other operation falls out:

**Getting exp:** EML(x, 1) = e^x − ln(1) = e^x − 0 = e^x. Done in one step.

**Getting ln:** This requires a deeper trick. Compute EML(0, x) = 1 − ln(x). Then compute exp of that: EML(1 − ln(x), 1) = e^(1−ln(x)). Finally, EML(0, e^(1−ln(x))) = 1 − (1 − ln(x)) = ln(x). Three EML operations.

**Getting subtraction:** a − b = EML(ln(a), exp(b)). Why? Because exp(ln(a)) = a, and ln(exp(b)) = b, so EML(ln(a), exp(b)) = a − b. This requires computing ln(a) and exp(b) first — about 11 instructions total.

**Getting multiplication:** a × b = exp(ln(a) + ln(b)). Addition of logarithms corresponds to multiplication of values — a principle that powered slide rules for centuries.

### The Number Tower

Something beautiful happens when you start with just the number 1 and apply EML repeatedly:

| Depth | Expression | Value |
|-------|-----------|-------|
| 0 | 1 | 1 |
| 1 | EML(1, 1) | e ≈ 2.718... |
| 2 | EML(e, 1) | e^e ≈ 15.15... |
| 2 | EML(1, e) | e − 1 ≈ 1.718... |
| 3 | EML(1, e^e) | **0** |

Look at that last line. The number zero — the foundation of all of mathematics — emerges at depth 3 in the EML tower. It takes three applications of EML, starting from nothing but the constant 1, to "discover" zero. This is a proven theorem, mechanically verified by computer.

### Why Should We Care?

Three reasons: power, simplicity, and AI.

**Power.** Modern processors waste enormous energy on instruction decoding — figuring out which of hundreds of operations to perform. The OISCC has a 1-bit instruction: either PUSH (0) or EML (1). The decode circuit could be a single logic gate. For ultra-low-power applications like implantable medical devices, environmental sensors, or satellite processors, this could mean the difference between a battery lasting months and one lasting years.

**Simplicity.** The entire processor reduces to one functional unit — a circuit that computes e^a − ln(b). No multiplier, no divider, no floating-point unit with dozens of special cases. The design could fit in a hundred transistors. A complete OISCC might require fewer transistors than the instruction decoder alone of a conventional chip.

**AI.** Neural networks depend heavily on exponentials. The softmax function — the final layer of nearly every classification network — computes exp(x) for each class. The sigmoid activation function is built from exp. On the OISCC, these are single EML operations. A softmax over 10 classes costs about 280 instructions — and each one exercises the full power of the hardware. No transistors sit idle.

### Rigorous Verification

What makes this work truly remarkable is that it isn't just conjectured — it's *proved*. The research team formalized over 90 theorems in the Lean 4 proof assistant, a system that checks every logical step with mathematical certainty. Among the verified results:

- **Arithmetic completeness**: exp, ln, +, −, ×, ÷ are all expressible through EML
- **Interval arithmetic**: guaranteed bounds on EML outputs (for safety-critical computing)
- **No positive fixed points**: the diagonal map exp(x) − ln(x) always exceeds x
- **Tree combinatorics**: precise bounds on the computational cost of any EML program
- **Exp-tower divergence**: iterated EML(·, 1) grows without bound

These aren't informal arguments — they are machine-checked proofs that no human error can undermine.

### What Comes Next?

The research team has identified 35 concrete research directions spanning pure mathematics, computer engineering, biology, and quantum computing:

**In the next two years:** Build an FPGA prototype — a working OISCC on a programmable chip. Develop a compiler that automatically translates ordinary arithmetic into PUSH/EML sequences. Design an analog circuit implementing EML in less than 100 transistors.

**In five years:** Fabricate a custom ASIC (Application-Specific Integrated Circuit) and measure its actual power consumption against conventional microcontrollers. Implement small neural networks on the chip for edge AI applications. Explore complex-number EML for native trigonometry.

**In the long term:** Study quantum versions of the OISCC. Implement EML using biochemical reaction networks (enzyme kinetics naturally produce exponentials). Develop a full complexity theory for EML computation, answering questions like: "What is the minimum number of EML operations needed to compute π?"

### The Bigger Picture

The OISCC joins a proud tradition in computer science: the search for the simplest possible universal computing primitive. In 1913, Henry Sheffer showed that a single logic gate (NAND) could build any Boolean circuit. In 1936, Alan Turing showed that a single read-write-move operation sufficed for general computation. The OISCC does the same for continuous mathematics: a single operation over the reals that generates everything.

But unlike NAND gates and Turing machines, the OISCC is *practical*. Its single operation maps naturally to transistor physics (BJTs have exponential I-V curves). Its stack architecture eliminates register allocation complexity. Its 1-bit instruction encoding minimizes memory and decode overhead.

"The art of being wise," wrote William James, "is the art of knowing what to overlook." The OISCC knows what to overlook: every instruction except one.

---

### The EML Identity Card

| Property | Value |
|----------|-------|
| Definition | EML(a, b) = e^a − ln(b) |
| Introduced | 2025 (Odrzywolek) |
| Formal verification | 90+ theorems in Lean 4 |
| Instructions for exp | 3 |
| Instructions for ln | 7 |
| Instructions for a + b | 11 |
| Instructions for a − b | 11 |
| Instructions for a × b | ~19 |

---

### Sidebar: Can You Compute π?

One of the most tantalizing open questions about the OISCC: what is the minimum number of EML operations needed to compute π?

We can compute e = EML(1, 1) with just one operation. But π, despite being perhaps the most famous constant in mathematics, has no known short EML representation. The best approach uses π = 4·arctan(1), but arctan requires infinite series or CORDIC-style iteration.

The research team conjectures that K_EML(π) ≤ 40 — that π can be computed to arbitrary precision using an EML tree with at most 40 nodes. Proving or disproving this conjecture would illuminate deep connections between the structure of π and the algebraic properties of exp and ln.

In a sense, the EML complexity of π measures how "far" π is from the world of exponentials and logarithms. It's a new kind of complexity measure — not the number of digits, not the irrationality measure, but the *structural distance* from the exp-ln universe.

---

*The complete formalization and source code are available at the project repository.*
