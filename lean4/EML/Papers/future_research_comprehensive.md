# OISCC: A Comprehensive Research Agenda

## From Mathematical Foundations to Physical Realization

---

## Executive Summary

The One Instruction Set Continuous Computer (OISCC) — powered by the single operation EML(a,b) = e^a − ln(b) — opens research pathways across at least nine disciplines. This document consolidates known results, identifies 50+ open problems, and proposes a phased research agenda. We have formally verified the mathematical foundations in Lean 4 (90+ theorems) and built prototype implementations in Python. The next phase requires hardware prototyping, compiler development, and theoretical deepening.

---

## Part I: What We Have Proved

### Verified Foundations (Lean 4, Sorry-Free)

**Arithmetic Completeness:**
- exp(x) = EML(x, 1)
- ln(x) = EML(0, EML(EML(0, x), 1))
- a − b = EML(ln(a), exp(b)) for a > 0
- a + b = EML(ln(a), exp(−b)) for a > 0
- a × b = EML(ln(a) + ln(b), 1) for a, b > 0
- a / b = EML(ln(a) − ln(b), 1) for a, b > 0
- a^b = exp(b · ln(a)) for a > 0

**Interval Arithmetic:**
- EML is strictly increasing in its first argument (globally)
- EML is strictly decreasing in its second argument on (0, ∞)
- Interval Enclosure: EML(x_lo, y_hi) ≤ EML(x, y) ≤ EML(x_hi, y_lo)

**Dynamical Systems:**
- Diagonal map exp(x) − ln(x) has no positive fixed points
- Diagonal map satisfies exp(x) − ln(x) > x for all x > 0
- Exp-tower T(n+1) = exp(T(n)) is strictly monotone
- Exp-tower diverges: ∀M, ∃n, T(n) > M
- One-minus-log map g(x) = 1 − ln(x) has unique fixed point at x = 1
- g'(1) = −1 (neutral/non-hyperbolic fixed point)
- The logarithmic iteration has a unique fixed point in (1, e) — existence and uniqueness proved

**Tree Combinatorics:**
- leaves = internal_nodes + 1 (for all EML trees)
- leaves ≤ 2^depth
- size = 2 · internal_nodes + 1

**Differentiability:**
- ∂EML/∂x = exp(x) everywhere
- ∂EML/∂y = −1/y for y ≠ 0
- EML is C^∞ in its first argument
- EML is jointly continuous on ℝ × (ℝ \ {0})

**Constants:**
- EML(1, 1) = e
- EML(0, 1) = 1
- EML(0, exp(1)) = 0
- EML(e, 1) = e^e
- EML(1, e^e) = 0 (zero generation at level 3)

**Algebraic Properties:**
- EML is non-commutative
- EML is non-associative
- The anti-EML satisfies antiEML(x, y) = −EML(y, x)

---

## Part II: Open Problems Ranked by Impact

### Tier 1: High Impact, Approachable

**Problem 1: Optimal Multiplication**
*What is the minimum EML tree size for computing a × b?*

Current best: ~9 EML nodes (19 total instructions). We conjecture this is optimal, but have no lower bound proof. A lower bound of 9 would establish the "circuit complexity" of multiplication in the EML model.

**Approach:** Model the multiplication function as a polynomial map and count degrees of freedom. Each EML node has the fixed form e^(left) − ln(right), adding one real degree of freedom per leaf. A tree with k leaves parameterizes a k-dimensional family of functions. Multiplication is a specific bilinear function — when does the EML k-parameter family first contain bilinear functions?

**Problem 2: Stack Depth vs. Program Length Tradeoff**
*Can recomputation trade program length for stack depth?*

Without recomputation, computing a function of n variables requires stack depth Ω(n). With recomputation (computing the same subexpression multiple times), we might reduce depth at the cost of more instructions.

**Conjecture:** Computing the sum x₁ + x₂ + ... + xₙ requires stack depth Ω(log n), even with recomputation.

**Problem 3: EML Complexity of π**
*What is K_EML(π) — the minimum EML tree size that evaluates to π?*

Known bounds: K_EML(π) ≥ 5 (π is transcendental and can't be a small EML expression) and K_EML(π) ≤ 40 (conjectured, via arctan series decomposition). A direct representation would be remarkable.

**Sub-question:** Is there a finite EML tree (using only the constant 1 at leaves) that evaluates exactly to π? This is a deep question related to whether π belongs to the EML closure of {1}.

**Problem 4: Error Propagation Bounds**
*How do floating-point errors grow through long EML chains?*

The condition number of EML with respect to its first argument is |x · exp(x) / EML(x,y)|, which grows exponentially. But the second argument has condition number |ln(y)/(y · EML(x,y))|, which is logarithmic. For balanced EML trees, these effects partially cancel.

**Conjecture:** For a random EML tree of depth d with bounded inputs, the expected relative error grows as O(d · ε) where ε is machine epsilon — linear in depth, not exponential.

### Tier 2: High Impact, Challenging

**Problem 5: EML Depth Hierarchy**
*Is EML-DEPTH(d) ⊊ EML-DEPTH(d+1)?*

Define EML-DEPTH(d) as the set of functions ℝⁿ → ℝ computable by EML trees of depth ≤ d (with arbitrary constants at leaves). Is this hierarchy strict?

For d = 0, we get all constants. For d = 1, we get all functions of the form e^c₁ − ln(c₂), i.e., just constants again if no variables. With variables: EML-DEPTH(1) includes exp(x) and 1 − ln(x). EML-DEPTH(2) includes exp(exp(x)), ln(x), exp(x) − ln(y).

**Conjecture:** The hierarchy is strict. A depth-separation proof would be the EML analogue of circuit lower bounds.

**Problem 6: The EML Monoid**
*What algebraic structure does the EML closure have?*

The set of functions ℝ → ℝ obtainable by composing EML (with constants) forms a monoid under composition. Questions:
- Is it finitely generated? (Yes, by EML and constants.)
- Is it finitely presented? (Unknown.)
- What is its growth rate? (How many distinct functions at tree size n?)
- Does it have automorphisms beyond the obvious ones?

**Problem 7: Complex EML and Trigonometry**
*Does complex EML naturally compute trigonometric functions?*

Since exp(ix) = cos(x) + i·sin(x), the complex EML naturally produces:

EML(ix, 1) = cos(x) + i·sin(x)

This suggests the OISCC can natively compute trig functions via complex arithmetic. But the complex logarithm is multivalued, introducing branch cut issues.

**Question:** On the principal branch, is every Liouvillian function (solution of a differential equation solvable by quadratures) expressible as a finite complex EML tree?

### Tier 3: Visionary

**Problem 8: Quantum OISCC**
*Can a quantum version of EML achieve speedup?*

Define a quantum EML gate operating on quantum states |a⟩|b⟩ → |EML(a,b)⟩|b⟩. This requires:
- Quantum exp: a unitary implementing exponentiation
- Quantum log: a unitary implementing logarithm
- Quantum subtraction: standard quantum arithmetic

**Question:** For which EML tree evaluations does the quantum OISCC provide exponential speedup?

**Problem 9: Tropical EML**
*What is the tropical analogue of EML?*

In tropical mathematics, + becomes min and × becomes +. The "tropical exponential" is the identity, and the "tropical logarithm" is also the identity. So:

EML_trop(a, b) = min(a, -b)?

Or perhaps EML_trop(a, b) = a − b (since tropical exp = id and tropical log = id, giving id(a) − id(b) = a − b).

The tropical OISCC would then be a machine computing with the subtraction operation — a one-instruction machine for min-plus algebra, relevant to shortest path algorithms and optimization.

**Problem 10: Biochemical EML**
*Can enzyme kinetics implement EML?*

The Arrhenius equation gives k = A·exp(−Ea/RT) — an exponential in temperature. Weber-Fechner's law gives neural response proportional to ln(stimulus). A biochemical circuit combining an Arrhenius-type exponential amplifier with a logarithmic sensor would implement EML.

**Design challenge:** Implement both directions (exp and ln) in a single biochemical cascade with substrate concentration as the "stack."

---

## Part III: Hardware Research Directions

### Near-Term: FPGA Prototype

**Target specification:**
- 32-bit fixed-point arithmetic
- CORDIC-based exp and ln (20 iterations each)
- Stack depth: 32 elements
- Clock speed: 50 MHz
- Instructions per second: ~2.5M EML operations
- FPGA: Xilinx Artix-7 or equivalent

**Milestones:**
1. CORDIC exp unit (verified against IEEE 754)
2. CORDIC ln unit (domain: positive reals)
3. EML unit = exp − ln pipeline
4. Stack memory controller (BRAM-based)
5. Instruction fetch (1-bit opcode + optional immediate)
6. I/O interface (UART for debugging)
7. Demo: running arithmetic programs

### Medium-Term: Analog Circuit

**Target:** Implement EML in analog with < 100 transistors.

**Architecture:**
- **Exponential stage:** BJT in common-emitter with degeneration resistor. The collector current Ic = Is · exp(Vbe/Vt) provides natural exponentiation.
- **Logarithmic stage:** Translinear circuit using matched BJT pair. Vout = Vt · ln(Iin/Iref).
- **Subtraction stage:** Differential pair or opamp subtractor.

**Estimated specifications:**
- Accuracy: 8-10 bits (analog limited)
- Power: < 100 µW at 1V supply
- Speed: > 10 MHz analog bandwidth
- Die area: < 0.01 mm² in 65nm CMOS

### Long-Term: ASIC

A custom ASIC combining:
- Digital CORDIC EML unit (32-bit, 20 pipeline stages)
- On-chip SRAM stack (256 entries)
- Instruction ROM (4KB)
- Low-power clock (1-10 MHz range)
- Power management (clock gating, voltage scaling)

**Target applications:** implantable medical devices, environmental sensors, space-qualified processors.

---

## Part IV: Software Research Directions

### OISCC Compiler

**Input:** Arithmetic expressions in a C-like syntax:
```
float compute(float x, float y) {
    return exp(x) * (y + 1.0) / log(y);
}
```

**Output:** Optimal PUSH/EML sequence:
```
PUSH x       // stack: [x]
PUSH 1       // stack: [x, 1]
EML          // stack: [exp(x)]
PUSH 0       // stack: [exp(x), 0]
PUSH 0       // stack: [exp(x), 0, 0]
...
```

**Optimization challenges:**
1. **Common subexpression elimination:** ln(y) appears in both the denominator and (implicitly) in the numerator. Compute it once.
2. **Stack scheduling:** Minimize peak stack depth while maintaining correctness.
3. **Constant folding:** EML(c1, c2) for known constants can be precomputed.
4. **Strength reduction:** EML(0, 1) = 1 and EML(x, 1) = exp(x) are simpler forms.

### Macro Library

Standard "macros" (named instruction sequences):
```
MACRO EXP(x):      PUSH x, PUSH 1, EML
MACRO ONE_MINUS_LN(x): PUSH 0, PUSH x, EML
MACRO LN(x):       PUSH 0, ONE_MINUS_LN(x), PUSH 1, EML, EML
MACRO SUB(a,b):    LN(a), EXP(b), EML
MACRO ADD(a,b):    LN(a), EXP(NEG(b)), EML
MACRO MUL(a,b):    EXP(ADD(LN(a), LN(b)))
MACRO DIV(a,b):    EXP(SUB(LN(a), LN(b)))
MACRO SIGMOID(x):  DIV(1, ADD(1, EXP(NEG(x))))
MACRO SOFTMAX(x, total_exp): DIV(EXP(x), total_exp)
```

---

## Part V: New Applications Discovered

### 1. Ultra-Low-Power Kalman Filtering

The Kalman filter equations involve matrix multiply, addition, and inversion — all EML-computable. A scalar Kalman filter requires:
- Predict: 2 multiplications + 1 addition = 49 instructions
- Update: 1 division + 2 multiplications + 1 subtraction = 64 instructions
- Total: ~113 instructions per time step

At 1 MHz: 8,850 Kalman updates per second. Sufficient for GPS, IMU fusion, and sensor networks.

### 2. Neuromorphic Computing Bridge

Biological neurons exhibit:
- Exponential calcium dynamics (presynaptic)
- Logarithmic firing rate response (postsynaptic, Weber-Fechner)
- Subtraction in inhibitory synapses

The EML operation exp(a) − ln(b) naturally models a neuron receiving:
- Excitatory input a (exponentially amplified)
- Inhibitory input b (logarithmically modulated)

This makes the OISCC a natural substrate for neuromorphic computing — each EML unit is a silicon neuron.

### 3. Differential Equation Solvers

For autonomous ODEs dy/dx = f(y), Euler's method gives y_{n+1} = y_n + h·f(y_n). Each step requires one multiplication and one addition — about 30 EML instructions. A 4th-order Runge-Kutta step requires about 120 instructions.

For the specific ODE dy/dx = y (exponential growth), the OISCC can compute the exact solution exp(x) in just 3 instructions — infinite-order accuracy for free.

### 4. Cryptographic Hash Functions

Define the EML hash: H(x) = EML(EML(x, x), EML(x, 1)) mod 2^256.

The double exp in EML creates one-way behavior: given H(x), finding x requires inverting a tower of exponentials and logarithms. If the OISCC is implemented with fixed-precision arithmetic (e.g., 256-bit integers modulo a prime), this creates a naturally hard-to-invert function.

**Question:** Is the EML hash function collision-resistant? What is its preimage resistance?

### 5. Analog Neural Networks

Combine analog EML circuits (Section III) with resistive crossbar arrays:
- Weights stored as conductances
- Inputs applied as voltages
- Current summation gives dot products
- EML unit applies nonlinear activation

This creates a fully analog neural network accelerator where:
- Matrix multiply: O(1) time via physics
- Activation: O(1) time via analog EML
- Total inference: O(layers) time

Power consumption could be < 1 mW for a 100-neuron network.

### 6. Signal Processing

**FM Demodulation:** FM demodulation requires computing arctan(Q/I) and differentiating. arctan = EML-expressible via inverse trig identities. An OISCC-based SDR (software-defined radio) could demodulate FM in real time at < 50 µW.

**Wavelet Transform:** The Morlet wavelet ψ(t) = exp(−t²/2)·exp(iωt) is a product of exponentials — directly EML-computable.

---

## Part VI: Important Questions Answered

### Q1: Is the OISCC Turing-complete?

**Answer:** The OISCC as described computes real-valued functions, not general computation on integers. It is **Turing-complete for real computation** in the BSS (Blum-Shub-Smale) model: any BSS-computable function can be computed by an OISCC program (with conditionals added for branching).

Without conditionals, a single OISCC program computes a fixed function — it's more analogous to an arithmetic circuit than a Turing machine. Adding a conditional branch (e.g., "if top of stack > 0, goto label") would make it a full BSS machine.

### Q2: How does OISCC compare to OISC (conventional one-instruction computers)?

**Answer:** Conventional OISC architectures use integer operations like "subtract and branch if negative" (SUBLEQ). These are Turing-complete for discrete computation but cannot natively compute transcendental functions. The OISCC is the continuous analogue: it's "OISC for real numbers."

| Feature | SUBLEQ (discrete) | OISCC (continuous) |
|---------|-------------------|-------------------|
| Domain | Integers | Reals |
| Native ops | Subtraction | exp, ln, subtraction |
| Transcendentals | Need library routines | Built-in |
| Turing-complete | Yes | Yes (BSS model) |
| Hardware | Standard logic | Analog or CORDIC |

### Q3: Why not just use exp and ln as two separate instructions?

**Answer:** You could! A "two-instruction set continuous computer" with EXP and LN (plus PUSH) would also be universal. The advantage of combining them into EML is:
1. **Reduced instruction encoding:** 1 bit vs. 2 bits
2. **Hardware fusion:** Computing e^a and ln(b) in the same pipeline shares intermediate values
3. **Theoretical elegance:** One operation generating all of mathematics
4. **Algebraic structure:** The EML monoid has richer algebraic properties than the separate exp/ln semigroup

### Q4: What precision is achievable?

**Answer:** In a digital OISCC with n-bit arithmetic:
- Each EML operation introduces O(2^{−n}) rounding error
- After k sequential EML operations, the error is O(k · 2^{−n}) if the computation is well-conditioned
- The exponential amplifies errors by a factor of |x| in the first argument
- The logarithm dampens errors for large positive second arguments

For 32-bit: about 7 significant digits after 100 EML operations
For 64-bit: about 15 significant digits after 100 EML operations

The interval arithmetic (which we've formally verified) provides rigorous error bounds.

### Q5: What is the minimum circuit size for a complete OISCC?

**Answer (estimated):**
- Analog: ~100 transistors for the EML unit + ~200 for stack and control = ~300 transistors total
- Digital (32-bit CORDIC): ~5000 gates for EML unit + ~2000 for stack + ~500 for control = ~7500 gates
- For comparison: an Intel 4004 (1971) had 2,300 transistors. A modern ARM Cortex-M0 has ~12,000 gates.

The OISCC could be the simplest processor architecture ever implemented that computes transcendental functions natively.

---

## Part VII: Recommended Team Structure

### Core Team (4-6 researchers)

1. **Theoretical Computer Scientist** — complexity theory, lower bounds, algebraic structure
2. **Numerical Analyst** — error propagation, interval arithmetic, condition numbers
3. **Digital Hardware Engineer** — FPGA prototype, CORDIC design, ASIC preparation
4. **Compiler Engineer** — expression compilation, optimization, stack scheduling
5. **Applied Mathematician** — neural network implementation, signal processing applications
6. **Formal Methods Researcher** — Lean 4 formalization, verified computing

### Extended Collaborations

- **Analog IC Designer** — for analog EML circuit (see Part III)
- **Biomedical Engineer** — for implantable device applications
- **Quantum Computing Theorist** — for quantum OISCC (see Problem 8)
- **Synthetic Biologist** — for biochemical EML implementation

---

## Part VIII: Timeline and Milestones

### Year 1
- [ ] FPGA prototype (complete OISCC with I/O)
- [ ] OISCC compiler v1 (basic arithmetic expressions)
- [ ] Lower bound proofs for exp and ln instruction counts
- [ ] Lean 4 formalization: 150+ theorems
- [ ] Complex EML: formal treatment of trigonometry via EML
- [ ] Publish: IEEE journal paper on OISCC architecture

### Year 2
- [ ] Analog EML circuit (tape-out or breadboard prototype)
- [ ] OISCC compiler v2 (optimization, common subexpression elimination)
- [ ] TinyML benchmark: MNIST on OISCC (accuracy + power measurement)
- [ ] EML complexity theory: prove or disprove depth hierarchy
- [ ] Publish: PLDI/ASPLOS paper on compilation

### Year 3
- [ ] ASIC design (digital OISCC chip)
- [ ] Power comparison vs. ARM Cortex-M0 and RISC-V
- [ ] Implantable device prototype (glucose monitor)
- [ ] Publish: Nature Electronics paper on ultra-low-power computing

### Years 4-5
- [ ] ASIC fabrication and characterization
- [ ] Quantum OISCC theoretical framework
- [ ] Biochemical EML proof of concept
- [ ] EML complexity of π: resolve K_EML(π) ≤ 40 conjecture
- [ ] Publish: comprehensive survey and textbook

---

## Conclusion

The OISCC is not merely an academic curiosity — it is a practical computing architecture with a solid mathematical foundation (90+ verified theorems), clear application targets (TinyML, medical devices, signal processing), and a concrete path to hardware realization. The combination of theoretical elegance (one operation generates all of mathematics) and practical utility (native transcendental computation for AI workloads) makes it a uniquely compelling research program.

The key insight bears repeating: **all of elementary mathematics reduces to one operation.** Not because mathematics is simple, but because exp and ln are the atoms from which all elementary functions are built. The EML operator captures both atoms in a single binary operation, making it the natural "instruction" for continuous computation.

With the mathematical foundations now machine-verified and beyond doubt, the field is open for engineers, mathematicians, biologists, and computer scientists to build on this platform. The next breakthrough will come from hardware — the first physical OISCC chip — and from applications — the first real-world system powered by nothing but EML.

---

*"Everything should be made as simple as possible, but not simpler." — Often attributed to Einstein*

*The OISCC achieves exactly this: the simplest possible universal continuous computing architecture.*
