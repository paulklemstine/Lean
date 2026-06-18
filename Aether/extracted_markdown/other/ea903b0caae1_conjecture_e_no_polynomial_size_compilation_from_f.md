# The Language Barrier: Why Some Mathematical Expressions Cannot Be Simplified

## A tower too tall to compress

Imagine building a tower of powers. Start with a number, say 2. Now raise *e* — the famous mathematical constant, approximately 2.718 — to that power: *e*². That gives you about 7.4. Not very big. Now take *e* to the power of *that* result: *e*^7.4, roughly 1,600. Do it again: *e*^1600, a number with nearly 700 digits. One more step and you've blown past the number of atoms in the observable universe.

This process — called *iterated exponentiation* — creates functions that grow with breathtaking speed. The tenth iterate, applied to 1, produces a number so large that writing it would require more digits than particles in the cosmos. Mathematicians have studied these towers for centuries, from Euler's investigations of infinite power towers to modern analyses of computational complexity.

But here's a question that sounds almost too simple to be interesting: Can you write down a compact mathematical formula for the *n*-th iterated exponential?

The answer, surprisingly, reveals something deep about the nature of mathematical language itself.

## Two dialects of mathematics

Consider two ways of writing mathematical expressions. The first is the familiar one: you can freely use addition, multiplication, division, and the exponential and logarithm functions, combining them however you like. Call this the *full language*.

The second is more constrained. Instead of having separate exponential and logarithm operations, you have a single combined operation that multiplies one quantity by the exponential of another. Think of it as a building block that packages two common operations into one. Call this the *EML language* (for Exponential-Multiplicative Language).

At first glance, the EML language seems powerful enough. After all, you can recover the ordinary exponential by multiplying by 1: the expression "1 times *e* to the power of *x*" is just *e*^*x*. And indeed, for any single mathematical function — any polynomial, any exponential, any combination thereof — you can always find an EML expression that computes it.

The question is: at what cost?

## Depth as a measure of complexity

The key insight comes from thinking about *depth* — how many layers of the EML operation are nested inside each other.

A depth-0 EML expression uses no exponentials at all. It can only compute polynomial-like functions: sums and products of the variable and constants. These functions grow at most polynomially — like *x*², *x*³, or *x*^100.

A depth-1 expression nests one EML layer. It can compute things like "3 times *e* to the power of (*x*² + 1)" — functions that grow exponentially, but only *singly* exponentially.

A depth-2 expression can express *e* to the power of *e* to the power of something — doubly exponential growth. And so on.

The depth of an EML expression measures, roughly, how many layers of exponential growth it can produce. This is analogous to the depth of an electronic circuit: how many layers of logic gates a signal must pass through.

## The barrier theorem

The central mathematical result is this: **no matter how large or clever an EML expression you write, if its depth is bounded by some fixed number *D*, it cannot compute the iterated exponential of level *D* + 3 or higher.**

More precisely: the *n*-fold iterated exponential — apply exp, then apply exp again, then again, *n* times total — requires EML depth that grows with *n*. There is no shortcut, no clever rearrangement, no amount of additional size that can compensate for insufficient depth.

This is not a practical limitation of specific expression-writing systems. It is a theorem about the mathematical structure of real functions, proved with machine-checked rigor. The proof works by establishing a *growth hierarchy*: functions computable at depth *D* are eventually dominated by functions requiring depth *D* + 1, no matter how you scale or adjust them.

## Why it matters: the circuit complexity connection

This result is not merely a curiosity about exponential towers. It sits at the intersection of several deep mathematical traditions.

In computer science, a celebrated line of research studies *bounded-depth circuits* — networks of AND, OR, and NOT gates with a fixed number of layers. In the 1980s, researchers proved that certain natural functions (like determining whether the number of 1s in a binary string is even) cannot be computed by any bounded-depth circuit, regardless of how wide you make it. These results — the AC⁰ lower bounds — are among the crown jewels of computational complexity theory.

The EML depth separation theorem is the exact analogue for *real-valued* expressions. Where circuit complexity asks "what Boolean functions can bounded-depth circuits compute?", expression complexity asks "what real functions can bounded-depth expressions compute?"

The parallel is precise:

- Circuit depth corresponds to EML depth
- Circuit size corresponds to expression size
- The PARITY function (hard for shallow circuits) corresponds to iterated exponentials (hard for shallow expressions)
- The polynomial hierarchy in complexity theory corresponds to the iterated exponential hierarchy in expression theory

## The growth argument

The proof strategy is elegant in its simplicity, even if the technical details require care.

**Step 1: Growth bounds.** Show that any EML expression of depth at most *D* (without division by expressions that could be zero) computes a function bounded above by the (*D*+1)-fold iterated exponential with some linear scaling. The key is that each EML layer adds at most one level of exponential growth, and field operations (addition, multiplication, negation) cannot create new exponential layers.

**Step 2: Growth hierarchy.** Show that the iterated exponentials form a *strict* hierarchy: the (*n*+1)-fold iterated exponential eventually grows faster than the *n*-fold iterated exponential composed with any linear function. This is intuitive — exp(exp(x)) grows faster than exp(Cx) for any constant C — but requires careful formalization.

**Step 3: Contradiction.** If a depth-*D* expression could compute the *n*-fold iterated exponential for sufficiently large *n*, the growth bound (Step 1) would contradict the growth hierarchy (Step 2).

## Beyond exponential towers

The depth separation theorem opens a research program that extends far beyond iterated exponentials. The mathematical machinery — growth bounds, absorption lemmas, hierarchy comparisons — applies to any setting where syntactic depth controls semantic complexity.

Some natural next questions:

**Can we extend to all expressions, including division?** The current theorem restricts to expressions without certain division operations. Extending it requires showing that rational functions (fractions of polynomials) still have controlled growth, a fact well-known in analysis but requiring careful formalization.

**How tight is the bound?** The theorem proves separation for *n* ≥ *D* + 3. Is the gap of 3 necessary, or does separation hold already for *n* > *D*? There are reasons to believe the tight bound is *n* > *D*, matching the known optimal construction.

**What about size?** Even when depth suffices (say, *n* = *D*), how large must the expression be? The canonical construction uses size proportional to *n*, but could there be a more compact representation? Preliminary computational evidence suggests not — size appears to grow at least exponentially for fixed depth below the separation threshold.

## The bigger picture

For centuries, mathematicians have sought compact representations of mathematical objects. The decimal system compresses numbers. Algebraic notation compresses relationships. Computer algebra systems compress computations.

The depth separation theorem says there are fundamental limits to how far this compression can go. Some functions are *inherently* deep: no amount of cleverness in rearranging the pieces can reduce the number of exponential layers needed to express them.

This is reminiscent of other impossibility results that have shaped mathematics: you cannot trisect an angle with compass and straightedge, cannot solve the general quintic by radicals, cannot decide all mathematical statements by algorithm. Each such impossibility, far from being a dead end, opens new vistas of understanding.

The EML depth separation suggests that mathematical languages have their own complexity theory — a theory of what can and cannot be efficiently expressed in different syntactic frameworks. As symbolic computation systems become ever more sophisticated, and as artificial intelligence systems learn to manipulate mathematical expressions, understanding these fundamental barriers will become increasingly important.

The tower of exponentials stands as a reminder: in mathematics, as in architecture, there are heights that no amount of horizontal expansion can reach. Sometimes, you simply need more depth.
