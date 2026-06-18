# The One-Button Calculator That Can Do Everything

## A single mathematical operation replaces all of arithmetic, calculus, and beyond — and we can prove it

*By the EML Research Team · April 2026*

---

### What if all of mathematics ran on just one operation?

Every smartphone has a calculator app with dozens of buttons: plus, minus, times, divide, square root, sine, cosine, logarithm, exponential. Behind the scenes, computer chips implement these operations using billions of transistors arranged into specialized circuits.

But what if you could throw away every button except one?

In 2025, physicist Andrzej Odrzywolek at Jagiellonian University in Poland made a striking discovery: a single mathematical operation can replace them all. Take two numbers, x and y. Compute:

> **eml(x, y) = eˣ − ln y**

That's it. Raise *e* (≈ 2.718) to the power x, then subtract the natural logarithm of y. This operation, called EML (for Exponential-Minus-Logarithm), can reconstruct addition, subtraction, multiplication, division, trigonometry, and every other function studied in a calculus course — using nothing but itself and the number 1.

### Building Everything from Nothing

The trick is chaining. Start with the number 1 as your only raw material:

- **Step 1:** Compute eml(1, 1) = e¹ − ln 1 = *e*. You've just manufactured Euler's number.
- **Step 2:** Compute eml(*e*, 1) = eᵉ. Now you have *e* raised to the *e* power.
- **Step 3:** Compute eml(1, eᵉ) = *e* − *e* = 0. Zero falls out from three operations.
- **Step 4:** For any x, eml(x, 1) = eˣ. The exponential function is just EML with 1 as the second argument.

From here, logarithms, subtraction, addition, multiplication, and every other elementary function can be assembled through clever composition. The EML operator is the mathematical equivalent of a universal LEGO brick.

### Why Mathematicians Are Excited

This discovery echoes one of the great ideas in the history of logic. In 1913, Henry Sheffer showed that the NAND gate — "not both" — could replace AND, OR, and NOT. Every digital computer ever built is, at its heart, nothing but NAND gates arranged in patterns. Sheffer's discovery didn't just simplify logic; it revealed something deep about the structure of Boolean reasoning.

EML does for continuous mathematics what NAND did for logic. And our team has been pushing this idea to its limits using computer-verified proofs.

### What a Computer Can Prove

Over the past year, we have formalized more than 250 theorems about the EML operator in Lean 4, a proof assistant that checks every logical step with mathematical certainty. This isn't just paper-and-pencil reasoning — every claim has been verified by a computer to be logically airtight.

Here are some highlights:

**The EML operator breaks every algebraic rule.** Normal operations like addition are commutative (a + b = b + a) and associative ((a + b) + c = a + (b + c)). EML satisfies *neither* — and it fails every other standard algebraic property we've tested: mediality, flexibility, alternativity, even the existence of an identity element. In the language of abstract algebra, the EML magma is maximally unstructured. Yet from this chaos emerges the power to generate all of mathematics.

**The e-tower grows inconceivably fast.** Starting from 1, repeatedly applying eml(·, 1) builds the *e-tower*: 1, e, eᵉ, eᵉᵉ, and so on. We proved that the n-th level of this tower exceeds 2ⁿ — and, more dramatically, that the (n+2)-th level exceeds e raised to the power 2ⁿ. By the 5th level, the number has more digits than there are atoms in the observable universe.

**The diagonal map has no fixed points.** The function d(z) = eᶻ − ln z always overshoots: d(z) > z for every real number z. This means if you start at any point and repeatedly apply d, you rocket off to infinity — strictly increasing at every step. We proved this for all real numbers, positive, negative, or zero.

**EML connects to the AM-GM inequality.** One of the most beautiful inequalities in mathematics — the arithmetic mean is at least the geometric mean — has a natural expression in EML language: for positive a and b, the quantity a + b − ln a − ln b is always at least 2.

### The Two-Button Calculator

Imagine a calculator with just two buttons: **EML** and **1**. With patience and cleverness, you could compute anything that a scientific calculator can. Want π? It takes about 53 button presses. Want to add 3 and 5? About 11 presses.

This isn't just a curiosity. It suggests a radically different way to design computers. Instead of having separate circuits for addition, multiplication, and exponentials, a processor could have a single EML unit and compose all other operations from it. Such a design might be simpler to manufacture, easier to verify, and surprisingly powerful.

For machine learning, EML offers an intriguing alternative to neural networks. Instead of learning millions of weights in a neural architecture, an EML-based system would search for the right *tree structure* — which branches feed into which — while optimizing a handful of real-valued parameters. This is essentially symbolic regression with a universal basis, and early experiments suggest it can rediscover known physical laws from data.

### The Road Ahead

Despite 250+ formally verified theorems, many fundamental questions remain open. The most tantalizing:

**How many EML operations does it take to compute ln(x)?** We know it takes at least 3 and at most 5, but the exact number remains unknown. Closing this gap is one of the most important open problems in EML theory.

**Is the EML operator's geometry hyperbolic?** The natural metric induced by EML's second derivatives turns out to resemble the Poincaré half-plane — the foundational model of hyperbolic geometry. Understanding this connection could reveal deep links between EML and the geometry of information.

**Can EML expressions compress mathematical knowledge?** Just as ZIP files compress data, EML trees might provide the most compact representation of mathematical formulas. We are developing information-theoretic lower bounds on this "formula compression" problem.

### Why It Matters

The EML operator is more than a mathematical novelty. It is a lens that reveals hidden structure in the landscape of mathematical operations. By reducing everything to a single binary function, it forces us to ask: what is the true complexity of the mathematics we use every day?

The answer, it turns out, is simultaneously simpler and richer than anyone expected. Every function in your calculator — from humble addition to exotic trigonometry — is a pattern woven from a single thread. Understanding that thread may eventually transform how we compute, how we learn, and how we understand the mathematical universe itself.

---

*The EML research program is an ongoing effort in formally verified mathematics. All theorems mentioned in this article have been checked by the Lean 4 proof assistant with the Mathlib library, ensuring mathematical certainty beyond what human peer review alone can provide.*
