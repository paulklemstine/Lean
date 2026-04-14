# The One-Button Calculator

## How a Single Mathematical Operation Can Do Everything

*If you could keep only one operation in all of mathematics, which would you choose?*

---

### The Dream of Simplicity

In 1913, mathematician Henry Sheffer made a startling discovery about logic. He showed that a single operation — "not both" (NAND) — could replace AND, OR, NOT, and every other logical operation. Every digital computer in the world, with its billions of transistors, is built from this one simple idea.

For over a century, mathematicians wondered: could the same trick work for continuous mathematics? Could there be a single operation that replaces addition, multiplication, exponentiation, logarithms, trigonometry, and everything else we learned in school?

The answer, it turns out, is yes.

### Meet the EML Operator

The operation is breathtakingly simple:

> **eml(x, y) = eˣ − ln y**

That's it. Take the exponential of the first number, subtract the natural logarithm of the second. This single operation, called EML (for Exp-Minus-Log), can reconstruct all of mathematics.

### Building a Universe from One Brick

To see how this works, let's start building. Our only tools are the EML operation and the number 1.

**Step 1: Get e.** Compute eml(1, 1) = e¹ − ln(1) = e − 0 = e ≈ 2.718.

**Step 2: Get zero.** Compute eml(1, eml(eml(1,1), 1)). This chains together three EML operations and produces exactly 0.

**Step 3: Get exp(x).** For any number x, compute eml(x, 1) = eˣ − ln(1) = eˣ. So EML with 1 as the second input just gives us the exponential function.

**Step 4: Get ln(x).** With a little more work: ln(x) = e − eml(1, x). We subtract the EML output from e (which we already know how to generate).

**Step 5: Get subtraction.** Here's where it gets magical: eml(ln a, exp(b)) = a − b for positive a. By feeding logarithms and exponentials into EML, we recover ordinary subtraction.

**Step 6: Get addition.** Similarly: eml(ln a, exp(−b)) = a + b.

**Step 7: Get multiplication.** Since ln(a × b) = ln(a) + ln(b), we get a × b = exp(ln a + ln b). We already have exp, ln, and addition — so multiplication falls out.

And so it continues: division, powers, roots, trigonometric functions (via complex exponentials), and every other "elementary function" can be built from this single operation.

### Why This Matters

#### A New Kind of Computer

Imagine a processor with just one instruction: compute eml(x, y). No addition unit, no multiplication unit, no separate exponential function. Just one universal operation. Such a processor could, in principle, compute anything that a full-featured calculator can — just by chaining together EML operations in the right pattern.

This isn't just theoretical. Researchers have outlined designs for EML coprocessors that could be implemented in hardware. A single analog circuit combining an exponential element (like a diode) with a logarithmic amplifier would constitute a universal analog computer.

#### A Searchlight for Scientific Discovery

When physicists discover a new law of nature, they express it as an equation: F = ma, E = mc², PV = nRT. But how do they find these equations in the first place? Increasingly, they use *symbolic regression* — computer programs that search through possible mathematical expressions to find ones that fit experimental data.

The EML framework dramatically simplifies this search. Instead of searching over all possible combinations of +, ×, exp, sin, and dozens of other functions, a symbolic regression engine can search only over EML tree structures. The search space shrinks from exponentially many function combinations to a structured space parameterized by just 5·2ⁿ − 6 real numbers, where n is the "depth" of the expression.

#### Understanding Mathematical Complexity

How complex is a mathematical formula? With EML, we can give a precise answer: the *EML complexity* of a function is the smallest number of EML operations needed to express it.

| Expression | EML Complexity |
|-----------|----------------|
| x | 0 (just a leaf) |
| eˣ | 1 |
| e | 1 |
| eˣ² | 2 |
| 0 | 3 |
| ln(x) | 3–5 |
| x + y | 3–11 |
| x × y | 5–17 |
| sin(x) | 5–53 |

One of the most tantalizing open questions is: what is the exact EML complexity of multiplication? We know it takes between 5 and 17 EML operations, but the precise answer remains unknown.

### The Mathematics of No Fixed Points

One of the most elegant results about EML concerns the "diagonal map" d(z) = eml(z, z) = eᶻ − ln z. This is what you get when you feed the same number into both inputs.

Mathematicians have proven — with machine-verified certainty — that this map has no fixed points. There is no real number z satisfying eᶻ − ln z = z. The diagonal map always overshoots: d(z) > z for every z. This is because the exponential grows too fast and the logarithm shrinks too slowly for the two sides to ever balance.

However, a closely related iteration *does* converge. If you start with any positive number and repeatedly compute g(z) = e − ln(z), you spiral in toward a special number z* ≈ 2.01678. This number satisfies the beautiful identities:

> z* + ln(z*) = e
> z* · e^(z*) = e^e

The number z* is connected to the Lambert W function — the same function that appears in problems ranging from enzyme kinetics to the distribution of prime numbers.

### The E-Tower

Starting from 1 and repeatedly taking exponentials, we get the *e-tower*:

1, e, e^e, e^(e^e), ...

That's 1, 2.718..., 15.15..., 3,814,279..., and then numbers so large they dwarf the number of atoms in the observable universe.

We have formally proven that this sequence grows faster than 2ⁿ — in fact, faster than any exponential, faster than any tower of powers, faster than almost any function you can name. The e-tower is the EML operator's way of counting to infinity.

### A Bridge to the Tropics

There is a beautiful branch of mathematics called *tropical geometry*, where addition is replaced by maximum and multiplication is replaced by addition. In this "tropical" world, the EML operator becomes:

> trop_eml(x, y) = max(x, −y)

This tropical EML can recover the basic tropical operations, suggesting that EML's universality extends beyond ordinary arithmetic into these exotic mathematical worlds.

### Machine-Verified Truth

In an age where AI systems sometimes confidently produce wrong mathematics, the EML research program stands on uniquely solid ground. Over 120 theorems about EML have been formally verified in Lean 4, a computer proof assistant that checks every logical step. The number of unproven assumptions? Zero.

This means that no human error, no subtle logical gap, and no wishful thinking can creep into the foundations. Every theorem in the EML framework is backed by a machine-verified chain of reasoning stretching back to the axioms of mathematics.

### What's Next?

The EML operator opens research avenues across at least 12 distinct fields:

- **Pure mathematics**: Classify all continuous Sheffer operators
- **Dynamics**: Map the Julia set of the diagonal map in the complex plane
- **Complexity**: Determine the exact EML complexity of multiplication
- **AI**: Build symbolic regression engines using EML tree search
- **Hardware**: Design single-instruction EML processors
- **Education**: Create "two-button calculators" for teaching

Perhaps the most intriguing open question is the *constant-free Sheffer problem*: does there exist a binary operation B(x,y) that generates all elementary functions without needing any constant at all? EML requires the constant 1 as a starting point. Could we eliminate even that?

This question strikes at the heart of what it means for mathematical operations to be truly universal. And thanks to the EML framework, we now have the tools to attack it.

---

*The EML operator reminds us that beneath the apparent complexity of mathematics lies a hidden simplicity. All the functions we learned in school — addition, multiplication, exponentials, logarithms, trigonometry — are really just one operation, viewed from different angles. As the great mathematician Alexander Grothendieck might have said: it's not about the many operations, but about the single structure that gives rise to them all.*
