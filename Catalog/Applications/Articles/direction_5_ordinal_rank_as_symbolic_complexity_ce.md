# Why Some Equations Are Harder to Differentiate Than Others — And How Ordinal Numbers Tell Us in Advance

## The Calculus Student's Nightmare

Every calculus student eventually encounters *that* problem — the one where differentiating an expression doesn't simplify it but makes it explode. You start with something compact, apply the product rule, then the chain rule, and suddenly your half-page expression has metastasized into three pages of algebra. Your pencil breaks. Your eraser gives up. You wonder if you chose the wrong major.

But here's what no textbook tells you: some expressions are *inherently* harder to differentiate than others, and the difficulty isn't random. There's a hidden structure — a mathematical fingerprint — that predicts exactly how badly differentiation will blow up, before you ever pick up your pencil.

That fingerprint is an *ordinal number*, a concept from the deepest foundations of mathematics. And for the first time, mathematicians have proved that this fingerprint is a genuine "complexity certificate" — a guarantee, not just a guess, about how hard your symbolic computation will be.

## Counting Beyond Infinity

To understand why ordinal numbers matter here, we need to take a brief detour into the infinite.

In the 1880s, the German mathematician Georg Cantor was exploring the nature of infinity when he discovered something startling: there isn't just one infinity. There's a whole hierarchy of infinities, each larger than the last, organized into a precise system he called *ordinal numbers*.

The ordinals start familiar enough: 0, 1, 2, 3, and so on. But after you've exhausted all the finite numbers, there's a first infinite ordinal, denoted ω (omega). Then ω + 1, ω + 2, and onward to ω · 2, ω · 3, and eventually ω² and beyond. These aren't vague philosophical concepts — they're precise mathematical objects with rigorous rules of arithmetic.

For over a century, ordinal numbers lived primarily in the rarefied atmosphere of pure logic and set theory. Proof theorists used them to measure the "strength" of mathematical theories — the proof-theoretic ordinal of a theory tells you how complex its proofs can be. It was beautiful but abstract, seemingly disconnected from the everyday mathematics of calculus and computation.

Until now.

## The Expression Hierarchy

Consider the world of mathematical expressions built from a small toolkit: variables, constants, addition, multiplication, and the operation `a · exp(b)` — multiplying something by an exponential. This last operation is the gateway to transcendence. Without it, you're stuck in the world of polynomials. With it, you can build exponentials, double exponentials, towers of exponentials — functions that grow faster than anything a polynomial can describe.

The key insight is that these expressions naturally organize into layers, like geological strata:

- **Layer 0**: Polynomials. Expressions like `x³ + 2x + 1`. No exponentials anywhere.
- **Layer 1**: Single exponentials. Things like `x² · exp(3x)`. One layer of transcendence.
- **Layer 2**: Double exponentials. Expressions like `exp(x · exp(x))`. Exponentials inside exponentials.
- **Layer *n***: *n*-fold nested exponentials. Each layer grows incomparably faster than the one below it.

A polynomial, no matter how high its degree, will eventually be dwarfed by any exponential. And a single exponential, no matter how steep, will eventually be left in the dust by a double exponential. This isn't just intuition — it's a theorem.

The ordinal rank assigns each expression an ordinal number that captures exactly which layer it belongs to. A polynomial gets rank ω · 0 + *n* (a finite ordinal). A single exponential gets rank around ω · 1. A double exponential gets ω · 2. The ω-coefficient — that number multiplying omega — counts the depth of exponential nesting. It's the expression's growth-class passport.

## The Differentiation Surprise

Here's the discovery that ties it all together: **differentiation never increases the ordinal rank**.

Think about what this means. When you differentiate `x³`, you get `3x²` — still a polynomial. When you differentiate `x · exp(x)`, you get `exp(x) + x · exp(x)` — still a single-layer exponential. When you differentiate `exp(exp(x))`, you get `exp(x) · exp(exp(x))` — still a double exponential.

This isn't a coincidence. It's a theorem, proved by carefully tracking what happens at each step of the differentiation process. The product rule for `a · exp(b)` produces terms of the form `a' · exp(b) + a · b' · exp(b)`, where primes denote derivatives. By induction, if `a'` has the same or lower rank than `a`, and `b'` has the same or lower rank than `b`, then the whole derivative stays within the same rank.

This is profound because it says the ordinal rank is a *conservation law* for differentiation. Just as energy is conserved in physics — it can change form but never increase in a closed system — the ordinal rank is conserved under differentiation. The growth class of a function is an invariant of the differentiation operator.

## The Practical Payoff

But ordinal rank doesn't just classify growth. It also bounds the *computational cost* of differentiation — how much bigger the differentiated expression is compared to the original.

The key result: if an expression has size *s* (measured by counting the nodes in its syntax tree), then its derivative has size at most 3*s*². That's a quadratic blowup, guaranteed, regardless of the expression's structure. And this bound is tight enough to be practically useful.

For iterated differentiation — taking the derivative *n* times — the size grows as at most (3*s*)^(2^*n*). Each differentiation step can at most square the size (up to constants). The ordinal rank acts as a gatekeeper: within each rank level, the blowup follows a predictable, bounded pattern.

This matters enormously for computer algebra systems — programs like those inside your smartphone's calculator, or the engines behind scientific computing. When a system receives an expression to differentiate, it needs to know in advance: will this computation finish in milliseconds, or will the expression blow up so large that it crashes the system? The ordinal rank answers this question before the computation even starts.

## The Tropical Connection

Perhaps the most surprising aspect of this work is where the ordinal rank shows up when you look at it from a completely different mathematical angle.

Tropical geometry is a relatively young field that replaces ordinary arithmetic with "tropical" arithmetic: addition becomes taking the minimum, and multiplication becomes addition. It sounds like a mathematician's fever dream, but it turns out to be enormously powerful for studying algebraic curves, optimization problems, and computational complexity.

When you translate an expression into its tropical version — replacing addition with min and multiplication with plus — the ordinal rank transforms into what's called the *tropical valuation*. And here's the punchline: the tropical valuation, the ordinal rank's omega-coefficient, and the syntactic nesting depth of exponentials are all the *same number*, viewed from three different mathematical perspectives.

This triple coincidence is not an accident. It reflects a deep structural truth: the complexity of an expression, whether measured by growth rate (ordinal analysis), by algebraic geometry (tropical valuation), or by syntax (nesting depth), is fundamentally the same thing. Three different branches of mathematics, developed for entirely different purposes, converge on the same invariant.

## A Window Into Proof Theory

The connection to proof theory — the study of mathematical proofs as mathematical objects — is particularly illuminating.

In the 1930s, Gerhard Gentzen made a breakthrough: he showed that the consistency of arithmetic could be proved using ordinal numbers up to a specific ordinal called ε₀. The key idea was that every valid proof could be transformed into a simpler one, and this simplification process was guaranteed to terminate because it decreased an ordinal measure at each step. The ordinal acts as a complexity certificate for the proof: it bounds how many simplification steps you'll need.

The ordinal rank of an expression plays exactly the same role for symbolic computation. Just as Gentzen's ordinals bound the complexity of proof simplification, the expression rank bounds the complexity of symbolic differentiation. The mathematics of proof theory and the mathematics of computer algebra are, at this level, the same mathematics.

## What Comes Next

This work opens several doors. The most immediate is in compiler optimization and static analysis. If a compiler can compute the ordinal rank of an expression at compile time — and rank computation is fast, just a single pass over the expression tree — it can predict the cost of subsequent symbolic operations without performing them. This enables smarter resource allocation, better memory management, and more reliable performance guarantees.

Further out, the tropical connection suggests that tools from algebraic geometry might yield new algorithms for symbolic computation. If the complexity of differentiation is controlled by a tropical invariant, then perhaps tropical methods can find shortcuts that pure symbolic methods miss.

And at the theoretical frontier, there's an open conjecture: that the derivative size for expressions of rank *n* and size *s* follows the exact pattern *s*^(*n*+1). If true, this would mean the ordinal rank doesn't just bound complexity — it *determines* it, with no gap between the upper and lower bounds. A complete characterization of symbolic differentiation complexity, predicted by a number theory from the 1880s.

Sometimes the most powerful tools in mathematics are the oldest ones, waiting patiently to be applied in ways their creators never imagined. Georg Cantor built ordinal numbers to understand infinity. A century and a half later, they're telling us how hard it is to differentiate an equation — and they're never wrong.
