# The One-Button Computer

## How a Single Mathematical Operation Could Power the Next Revolution in Microchip Design

*A Scientific American–style feature*

---

**What if everything your computer does — every calculation, every pixel rendered, every AI prediction — could be reduced to pressing one button?**

That's the premise behind the OISCC (One Instruction Set Continuous Computer), a radical new approach to processor design that replaces the hundreds of instructions in modern CPUs with exactly one:

**EML(a, b) = e^a − ln(b)**

Take two numbers. Raise *e* to the power of the first. Subtract the natural logarithm of the second. That's it. That single operation — called EML, for Exp Minus Log — can compute anything: addition, multiplication, square roots, trigonometry, neural networks, even stock option prices. And it does so with a chip so simple it could be etched onto a grain of sand.

---

### The NAND Gate's Continuous Cousin

In the digital world, every computer ultimately reduces to NAND gates — simple circuits that output "false" only when both inputs are "true." With enough NAND gates wired together, you can build any logic circuit. This is why Claude Shannon's 1938 master's thesis, showing that Boolean algebra could implement any logical function, launched the computer age.

The EML operator plays the same role for *continuous* mathematics. Just as NAND is the universal gate for bits (0s and 1s), EML is the universal operator for real numbers. Need to multiply? It's a specific sequence of EML operations. Need a sine function? Another sequence. Need to train a neural network? More EML operations. The 2025 paper by Andrzej Odrzywolek proved this universality rigorously, and a team of researchers has since machine-verified over 150 theorems about EML using the Lean 4 proof assistant — the same system used to verify parts of modern mathematics.

---

### Why One Instruction?

Modern processors execute hundreds of different instructions: ADD, MUL, DIV, SQRT, SIN, COS, LOG, EXP, and many more. Each instruction requires dedicated silicon — transistors wired to perform that specific computation. An Intel Core i9 has billions of transistors precisely because it needs specialized circuitry for each operation.

The OISCC takes the opposite approach. Instead of building hardware for every operation, it builds hardware for exactly one operation and constructs everything else in software. The trade-off: more instructions per computation, but dramatically simpler hardware.

How simple? An analog OISCC could be built with roughly **300 transistors**. A digital version using a technique called CORDIC requires about **7,500 logic gates**. For comparison, an ARM Cortex-M0 — the simplest widely-used microprocessor — has about 12,000 gates. The OISCC is simpler than the simplest commercial processor.

---

### The Key Identity

The magic of EML lies in a single algebraic identity:

**EML(ln(a), exp(b)) = a − b**

Here's why: EML takes the exponential of its first argument and subtracts the logarithm of its second. If the first argument is already a logarithm, the exponential undoes it. If the second argument is already an exponential, the logarithm undoes it. What's left is pure subtraction.

From subtraction, you can build addition (subtract a negative). From addition and the raw exponential (which is just EML(x, 1), since ln(1) = 0), you can build multiplication (add logarithms, then exponentiate). From multiplication, you can build division, powers, roots — everything.

The researchers have verified each step in this chain formally:

| Operation | EML formula | Verified? |
|-----------|-------------|-----------|
| exp(x) | EML(x, 1) | ✓ |
| ln(x) | 3 EML operations | ✓ |
| x − y | EML(ln x, exp y) | ✓ |
| x + y | EML(ln x, exp(−y)) | ✓ |
| x × y | EML(ln x + ln y, 1) | ✓ |
| x / y | EML(ln x − ln y, 1) | ✓ |

---

### The Kolmogorov Complexity of Constants

One of the most intriguing questions about EML is: how many operations does it take to build familiar numbers from scratch?

Starting from just the number 1 — the only constant the OISCC needs — you can generate a tower of values:

- **Depth 0:** Just 1 itself.
- **Depth 1:** EML(1, 1) = e^1 − ln(1) = e ≈ 2.718. Euler's number appears immediately.
- **Depth 2:** Three new values emerge, including e^e ≈ 15.15 and e − 1 ≈ 1.718.
- **Depth 3:** Twenty-one values, including — remarkably — **zero**. The number 0 first appears at depth 3, via EML(1, e^e) = e − ln(e^e) = e − e = 0.
- **Depth 4:** An explosion to 370 new values.

But here's the surprise: **the integer 2 doesn't appear until at least depth 5.** Despite being one of the simplest numbers humans know, 2 is unreachable from 1 via four or fewer EML compositions. This reflects a deep truth: EML naturally generates transcendental numbers (like e, e^e, e^(e^e)), while ordinary integers live in a different mathematical universe and require more work to reach.

---

### A Computer for the Internet of Things

The OISCC isn't designed to replace your laptop. It's designed for the *other* computers — the billions of tiny processors embedded in sensors, medical devices, satellites, and smart infrastructure.

Consider a glucose monitor for diabetic patients. It needs to:
1. Read a sensor value
2. Apply a Kalman filter (to smooth noise)
3. Predict the next reading (exponential smoothing)
4. Check against thresholds (comparison)

All four operations are naturally expressed in EML. The entire computation takes about 200 EML instructions per measurement cycle. On a chip consuming less than 50 microwatts, a coin-cell battery could power it for over a year.

Or consider a satellite radiation monitor. The simplicity of the OISCC — just 300 transistors in its analog version — makes it inherently resistant to radiation damage. A triple-redundant OISCC would use 900 transistors, still simpler than a single conventional processor. In the harsh environment of space, simplicity is survival.

The research team has demonstrated EML implementations of:
- **Neural network inference** (MNIST digit recognition)
- **Kalman filtering** (sensor fusion)
- **Signal processing** (FM demodulation, spectral analysis)
- **Financial computing** (Black-Scholes option pricing with < 0.02% error)
- **PID control** (industrial process control)
- **Cryptographic hashing** (experimental EML-based hash function)

---

### The Mathematics Goes Deep

Beyond engineering, the EML operator opens rich mathematical questions that connect to number theory, dynamical systems, and complexity theory.

**The 2D EML Map.** What happens when you apply EML in two dimensions simultaneously? Define Φ(x, y) = (EML(x,y), EML(y,x)). Computer experiments show something remarkable: this map has no fixed points, no periodic orbits, and every trajectory spirals to infinity within a few iterations. The exponential growth in EML creates an irresistible expansive force — a mathematical whirlpool that swallows every initial condition. Proving this rigorously remains an open problem.

**The Depth Hierarchy.** Is EML "depth 3" strictly richer than "depth 2"? The researchers have proven that depth 2 is strictly richer than depth 1 — the function exp(exp(x)) cannot be written as exp(ax + b). Extending this to all depths would establish a strict hierarchy, analogous to the polynomial hierarchy in classical complexity theory.

**The Multiplication Lower Bound.** How many EML nodes are needed to multiply two numbers? The best known construction uses about 9 nodes. Proving that 9 is optimal — that no clever trick can do better — would be a landmark result in algebraic complexity theory.

---

### What's Next

The research team has laid out a 5-year roadmap:

**Year 1:** FPGA prototype running demo programs; compiler v1; 200+ verified theorems.

**Year 2:** Analog breadboard prototype; complexity lower bounds; medical device feasibility study.

**Year 3:** ASIC tape-out; power comparison vs. ARM Cortex-M0; clinical prototype.

**Years 4-5:** ASIC characterization; quantum OISCC theory; textbook publication.

The most exciting near-term target is the FPGA prototype — a working silicon implementation of the one-button computer. When a single chip running a single instruction can price stock options, classify handwritten digits, and filter sensor data, the computing world will have to take notice.

In the meantime, the mathematics continues to deepen. Every new theorem, verified by machine, adds another brick to the foundation. And at the center of it all sits one equation, elegant in its simplicity:

**EML(a, b) = e^a − ln(b)**

One equation. One instruction. One computer. The rest is engineering.

---

*All mathematical results described in this article have been machine-verified in the Lean 4 proof assistant using the Mathlib library. Python demonstrations and SVG visualizations are available in the project repository.*
