# The Mathematical LEGO Brick That Breaks Every Rule

## How a single operation that fails every algebraic law turns out to be the most powerful building block in mathematics

*By the EML Research Team · April 2026*

---

### A calculator with just one button

Imagine a calculator with a single button. You can type in two numbers, press the button, and get a result. That's it. No addition key. No multiplication. No square root or sine or logarithm.

Could such a device do anything useful?

Surprisingly, yes. In fact, it can do *everything*.

The operation is called EML — short for Exponential Minus Logarithm. Given two numbers x and y, it computes:

> **eml(x, y) = eˣ − ln y**

That's Euler's number e (about 2.718) raised to the power x, minus the natural logarithm of y. From this single operation and the starting number 1, you can build every function taught in every calculus course: addition, multiplication, trigonometry, logarithms, roots — the lot.

It's the mathematical equivalent of LEGO: one shape, infinite possibilities.

### The great paradox

Here's what makes the story strange. Most useful mathematical operations obey certain rules. Addition is commutative: 3 + 5 = 5 + 3. It's also associative: (2 + 3) + 4 = 2 + (3 + 4). Multiplication has an identity element: anything times 1 gives itself back.

EML obeys *none* of these rules.

Our team, using a computer proof assistant called Lean 4, has verified that the EML operation fails every standard algebraic property that mathematicians have named:

- **Not commutative**: eml(x,y) ≠ eml(y,x) in general
- **Not associative**: Grouping matters
- **Not medial**: A subtle symmetry law that even exotic algebras like octonions satisfy — EML doesn't
- **Not flexible**: Another basic property — EML fails it
- **Not alternative**: In either direction — EML fails both
- **No identity element**: There is no number e₀ such that eml(e₀, x) = x for all x, or eml(x, e₀) = x for all x

In the hierarchy of algebraic structures — groups, monoids, semigroups, quasigroups, loops — EML sits at the very bottom. It's just a "magma": a set with an operation. Period. No additional structure whatsoever.

And yet this structureless operation generates ALL of mathematics.

The paradox is striking. In digital logic, the NAND gate is universal — it can build any Boolean circuit. NAND at least satisfies some algebraic laws. EML, the continuous analogue, satisfies *none*. It's as if you discovered that a shape with no symmetry at all could tile every possible pattern.

### Numbers that dwarf the universe

One of the simplest things you can do with EML is build a tower. Start with 1, and repeatedly apply eml(·, 1) — which just computes the exponential:

- Level 0: 1
- Level 1: e ≈ 2.718
- Level 2: eᵉ ≈ 15.15
- Level 3: e^(eᵉ) ≈ 3,814,279
- Level 4: e^(e^(eᵉ)) ≈ a number with 1.6 million digits
- Level 5: a number whose *number of digits* has more digits than atoms in the observable universe

We proved a precise bound: the (n+2)-th level of this tower exceeds e raised to the power 2ⁿ. By level 5, you're dealing with numbers that make a googolplex look like pocket change.

This isn't just recreational mathematics. The tower's growth rate connects to deep questions about the nature of mathematical constants. Is e^(eᵉ) — the third level — even transcendental? Nobody knows. Despite being built from the most familiar constant in mathematics (e = 2.71828...), the tower quickly reaches territory where our knowledge of number theory runs out.

### The function that always overshoots

What happens when you put the same number into both slots of EML? You get the diagonal map:

> d(z) = eᶻ − ln z

This function is fascinatingly restless. We proved that d(z) > z for *every* real number z. No matter where you start, d always overshoots. It has no fixed point — no resting place where the function returns what it receives.

Start at z = 0.5, and watch the orbit:
- d(0.5) ≈ 2.34
- d(2.34) ≈ 9.54
- d(9.54) ≈ 13,920
- d(13,920) → explosion

The orbit rockets to infinity in just a few steps, strictly increasing at every stage. This relentless acceleration is a formally verified mathematical fact, checked by computer to the last logical step.

There *is* a related function that has a fixed point: g(z) = e − ln(z). This function converges to z* ≈ 2.017, a number connected to the Lambert W function. Start anywhere positive, and iterating g brings you to z*. The basin of attraction appears to be all of (0, ∞), but proving this remains an open problem.

### The inequality hiding inside

Perhaps the most beautiful V7 result connects EML to one of mathematics' oldest truths: the AM-GM inequality (the arithmetic mean is at least the geometric mean).

For any two positive numbers a and b:

> a + b − ln(a) − ln(b) ≥ 2

Equality holds only when a = b = 1. This is really saying that for any positive t, the quantity t − ln(t) is at least 1 — a fact that flows from the fundamental concavity of the logarithm.

In EML language, this inequality has a natural interpretation: the "EML cost" of any pair of positive numbers has a guaranteed minimum. It's a bridge between the algebraic world of EML and the analytic world of classical inequalities.

### What a computer can prove

Every result in this article — all 40+ theorems — has been verified by a computer proof assistant called Lean 4, developed by Microsoft Research. This isn't just running some examples; it's a complete logical verification that the theorems hold for *all* real numbers, *all* natural numbers, *all* cases.

The proofs use only three foundational axioms (propext, classical choice, and quotient soundness) that are standard in modern mathematics. No hand-waving. No gaps. No "we checked it for the first million cases."

When we say "d(z) > z for all z," we mean *all* z. Every positive number. Every negative number. Zero. The proof covers them all, and the computer has verified every step.

### Why it matters

The EML operator matters for at least three reasons:

**For mathematics**: It reveals a deep connection between computational universality and algebraic non-structure. The more "rule-breaking" an operation is, the more flexible it becomes. EML breaks every rule and gains the power to generate everything. This suggests a principle: *algebraic structure is a constraint on expressiveness, not a prerequisite for it.*

**For computer science**: EML provides a new basis for symbolic computation. Instead of searching over trees of dozens of operations (add, multiply, exp, log, sin, cos, ...), search over EML trees — a vastly smaller space. This has direct applications to AI-driven scientific discovery, where finding simple mathematical formulas in data is a key challenge.

**For philosophy**: EML challenges our intuition about what "structure" means. We tend to think of useful things as well-organized: commutative, associative, symmetric. EML is none of these. It's chaos that generates order — a single, maximally asymmetric operation that produces the entire symmetric, structured edifice of elementary mathematics.

### The 120 open questions

Version 7 of the EML project catalogs more than 120 open research problems across 25 fields. Here are a few of the most tantalizing:

1. **The complexity of logarithm**: How many EML operations does it take to compute ln(x)? We know it's between 3 and 5. Closing this gap is the top priority.

2. **The Julia set**: What does the Julia set of d(z) = eᶻ − ln(z) look like in the complex plane? Is it connected? What's its fractal dimension?

3. **The constant-free problem**: Can any single binary operation generate all elementary functions without needing a starting constant like 1? We conjecture the answer is no, but proving it would be a landmark result.

4. **EML for AI**: Can EML-based symbolic regression outperform state-of-the-art methods like PySR? The monotonicity theorems give theoretical advantages for pruning the search space.

5. **EML hardware**: Could a dedicated EML coprocessor accelerate scientific computing? The regional bounds we proved simplify error analysis for fixed-point implementations.

### An invitation

Mathematics is full of universal building blocks: NAND gates, Turing machines, cellular automata. EML adds something new to this list — a universal builder for the continuous world of functions and analysis.

The project is open. The theorems are machine-verified. The questions are abundant. And the one-button calculator is waiting.

---

*The EML V7 theorems are formalized in Lean 4.28.0 with Mathlib. Source code and interactive demonstrations are available in the project repository. For the complete catalog of open problems, see "Future Research Directions for the EML Operator — Version 7."*
