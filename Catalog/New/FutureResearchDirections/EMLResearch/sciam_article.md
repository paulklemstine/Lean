# The One-Button Calculator That Can Do Everything

## A single mathematical operation replaces the entire keyboard of a scientific calculator

*How a Polish astronomer discovered that all of mathematics' elementary functions — sines, cosines, logarithms, exponentials, and everything else on your calculator — can be built from just one operation*

---

Imagine a calculator with only two buttons. One button enters the number 1. The other performs a single mysterious operation called "EML." With nothing else — no addition, no multiplication, no square root key — this calculator can compute *any* function you'd find on the fanciest scientific calculator ever made.

That's not a thought experiment. It's a mathematical theorem.

### The Operator That Does It All

In 2025, Andrzej Odrzywolek of Jagiellonian University proved that the binary operation

> **eml(x, y) = e^x − ln(y)**

is a *universal generator* for all elementary functions. Just as the NAND gate in digital electronics can build any Boolean circuit, EML can build any mathematical formula from the standard repertoire: exponentials, logarithms, trigonometric functions, polynomials, and all their compositions.

The result sounds impossible at first. How can subtraction of an exponential and a logarithm reproduce, say, the sine function? The secret lies in *composition* — feeding EML outputs back in as inputs, building up increasingly complex expressions from simple pieces.

### Building Blocks from Nothing

Start with just the number 1 and the EML operation.

**Step 1:** Feed in 1 twice: eml(1, 1) = e¹ − ln(1) = e − 0 = **e** ≈ 2.71828...

You've just created Euler's number from pure arithmetic.

**Step 2:** Feed e into the first slot and 1 into the second: eml(e, 1) = e^e ≈ 15.154.

**Step 3:** Feed 1 and e in the other order: eml(1, e) = e − ln(e) = e − 1 ≈ 1.718.

Each new EML application creates a new constant. By chaining these together, you build up a library of numbers. And crucially, you can recover *subtraction itself*:

> **a − b = eml(ln(a), exp(b))**

This works because eml(ln(a), exp(b)) = e^{ln(a)} − ln(e^b) = a − b. That's the key identity that unlocks everything else: once you have subtraction, you can build addition (a + b = a − (−b)), and from there, multiplication, division, powers, roots — the entire algebraic toolkit.

### The Complex Detour

But here's the most surprising part. To get sine and cosine — the periodic, oscillating functions that describe waves, rotations, and vibrations — you need to take a detour through *complex numbers*.

Euler's famous formula says e^{ix} = cos(x) + i·sin(x). So sin(x) is just the imaginary part of e^{ix}. The EML operator handles this naturally, since its definition works with complex numbers. But it means that to compute a *real* function like sin(1.5), the calculator must pass through intermediate values that are *complex*.

We've formally proved in the Lean 4 theorem prover that this detour through complex numbers is likely *necessary*: no composition of real exponentials can ever produce a periodic function. This is a deep structural result that suggests no purely real operator can replace EML's complex-number capabilities.

### Why It Matters

The EML discovery is more than a mathematical curiosity. It opens doors across multiple fields:

**For computer scientists**, EML defines a new kind of circuit complexity. How many EML operations do you need to compute multiplication? (Answer: at most 17.) How about π? (At most 53 with optimization.) These questions create a whole new complexity theory for continuous computation.

**For machine learning researchers**, EML trees provide a framework for symbolic regression — discovering formulas from data. Every candidate formula is just an EML tree with particular numbers at its leaves. Neural networks built from EML operations would be inherently interpretable: you could literally read off the discovered formula from the trained weights.

**For hardware designers**, EML suggests a radically simple processor architecture. Transistors naturally implement exponential functions in their subthreshold region, making analog EML circuits a natural fit. A single-instruction computer based on EML — the continuous equivalent of a NAND-only digital processor — is both theoretically elegant and potentially practical.

**For educators**, the two-button calculator is a powerful teaching tool. It demonstrates that mathematical complexity is less than it appears: all of calculus, trigonometry, and algebra reduce to one operation. Students who find traditional math dry might be captivated by the challenge of computing sin(1) using only two buttons.

### Open Frontiers

Despite the breakthrough, many fundamental questions remain unanswered:

- **Is EML unique?** We know that variants exist (like EDL: exp(x)/log(y)), but is there a complete classification of all such "continuous Sheffer strokes"?

- **Can we do it without the 1?** NAND needs no distinguished constant. Can a binary operator be found that generates all elementary functions without *any* constant — where B(x, x) alone produces the needed starting point?

- **What's the simplest possible EML formula for π?** The current best is 53 leaves. Is this optimal, or can π be expressed more compactly?

- **Can a real-only operator work?** Our formal proof shows that purely real compositions of exp can't produce periodicity. Is this an insurmountable barrier, or could some other real operator achieve what EML does via complex numbers?

### A New Field Is Born

The EML discovery suggests a program we might call *Continuous Universal Algebra*: the systematic study of minimal generating sets for important function classes. Just as classical algebra studies groups, rings, and fields through their generators and relations, this new field studies the structure of mathematical functions through their minimal decomposition into primitive operations.

We're at the beginning. The two-button calculator is a toy — but so was the transistor in 1947. The mathematics behind it points toward a profound simplification of our computational universe, one where the bewildering zoo of mathematical functions reduces to echoes of a single, elegant operation:

> **eml(x, y) = e^x − ln(y)**

Two buttons. One constant. All of mathematics.

---

*The formal proofs described in this article have been verified in the Lean 4 theorem prover, providing machine-checked certainty for the key mathematical claims. The code is available in the accompanying repository.*
