# When Duplicates Don't Matter: How a Simple Algorithm Unlocks the Hidden Algebra of Optimization

*A four-step recipe — flatten, sort, deduplicate, rebuild — turns out to be a mathematically perfect simplifier for an entire branch of mathematics that governs everything from GPS navigation to computer chip design.*

---

## The Shortest Path Has a Secret

Every time your phone calculates a driving route, it solves an optimization problem so fundamental that mathematicians have been studying it since the 1950s. At its heart lies a deceptively simple operation: comparing two numbers and picking the smaller one. *Minimum.*

What makes this operation special — and what separates it from ordinary addition or multiplication — is a property so obvious it seems trivial: **the minimum of a number with itself is just that number.** If the shortest route from New York to Boston is 215 miles, then the "minimum of 215 and 215" is still 215. Of course it is.

But here is the surprise: this trivial-seeming property, called *idempotence*, turns out to have profound mathematical consequences. It means that when you build complex expressions out of minimum operations, you can simplify them far more aggressively than anyone realized — and a team of researchers has now proved, with mathematical certainty, exactly how far that simplification can go.

## The Algebra You Didn't Know You Were Using

In the 1960s, a Brazilian mathematician named Imre Simon noticed something peculiar. If you replace the usual rules of arithmetic — addition and multiplication — with a different pair of operations — minimum and addition — you get a strange new number system that still obeys most of the familiar algebraic laws. Mathematicians call it the *tropical semiring*, named (somewhat whimsically) after Simon's home country.

This "tropical" algebra turns up in an astonishing range of applications:

- **Navigation systems** compute shortest paths using tropical matrix multiplication.
- **Computer chip designers** analyze timing constraints using min-plus arithmetic.
- **Compiler writers** optimize programs using lattice-based analysis built on the same operations.
- **Biologists** align DNA sequences using algorithms that are secretly tropical at their core.

In all these domains, people write down expressions involving `min` — complicated, nested, redundant expressions — and need to know: *are two expressions really computing the same thing?*

## Three Laws That Govern Simplification

Consider a simple expression: `min(x, min(y, z))`. This computes the smallest of three values. So does `min(min(x, y), z)`. And `min(z, min(x, y))`. All three are equivalent, and any intelligent simplifier should recognize them as such.

The equivalences arise from three algebraic laws:

1. **Associativity**: The grouping doesn't matter. `min(min(a, b), c) = min(a, min(b, c))`.
2. **Commutativity**: The order doesn't matter. `min(a, b) = min(b, a)`.
3. **Idempotence**: Duplicates don't matter. `min(a, a) = a`.

The first two laws — associativity and commutativity, often abbreviated *AC* — are well-understood. Computer algebra systems have handled AC simplification for decades. But the third law, idempotence, changes the game entirely.

With just AC, the expression `min(x, min(x, y))` and `min(x, y)` are *different*. The first mentions `x` twice; the second mentions it once. An AC-only simplifier carefully preserves this multiplicity, because for operations like addition, `x + x` is genuinely different from `x`.

But for `min`, duplicates are meaningless. The expression `min(x, min(x, y))` is *always* equal to `min(x, y)`, no matter what values `x` and `y` take. An AC-only simplifier can never discover this. You need idempotence — the full *ACI* package.

## A Deceptively Simple Algorithm

The canonicalization algorithm that handles all three laws is almost comically simple:

1. **Flatten**: Walk through the expression tree and collect all the variable names into a list.
2. **Sort**: Arrange them in alphabetical (or numerical) order.
3. **Deduplicate**: Remove repeated entries.
4. **Rebuild**: Construct a new, right-associated expression from the cleaned-up list.

That's it. Four steps. A first-year computer science student could implement it in twenty minutes.

But proving that this algorithm is *mathematically correct* — that it produces a perfect canonical form, that it never conflates expressions that should be different, and that applying it twice gives the same result as applying it once — turns out to require surprising mathematical sophistication.

## What "Correct" Really Means

The researchers established five properties of this algorithm, each proven with absolute mathematical rigor:

**Soundness.** Every expression is equivalent (under ACI) to its normal form. The algorithm never changes the meaning.

**Completeness.** If two expressions are ACI-equivalent, the algorithm produces identical output for both. Nothing slips through the cracks.

**Reflection.** Conversely, if the algorithm produces the same output for two expressions, they really are ACI-equivalent. There are no false positives.

**Idempotence.** Normalizing an already-normal expression returns it unchanged. The algorithm is stable.

**Strict strength.** There exist pairs of expressions that ACI normalization correctly identifies as equivalent, but that AC-only normalization cannot. The upgrade from AC to ACI is a genuine increase in reasoning power, not merely a cosmetic change.

Together, these five properties mean the algorithm is a *complete decision procedure*: a guaranteed method for answering the question "are these two expressions the same?" with perfect accuracy, every time.

## The Deep Insight: Sets, Not Lists

Why does this simple algorithm work? The answer reveals a beautiful mathematical structure.

An AC-only simplifier treats an expression as a *sorted list* of variables. The list `[x, x, y]` is different from `[x, y]` because lists care about multiplicity. Adding idempotence changes the data structure: it transforms sorted lists into *sorted sets*. And a sorted set is uniquely determined by its elements — there's only one way to write `{x, y}`, regardless of how many times you mentioned `x` along the way.

Mathematically, this is the passage from *commutative monoids* to *semilattices*. It's the difference between counting how many times you've seen something and merely recording *whether* you've seen it. In the language of algebra, the ACI normal form of an expression is the canonical representative of the *free semilattice* generated by its variables.

This isn't just a clever observation — it's a representation theorem. It says that the algebraic structure of `min` expressions, modulo ACI, is *exactly* the structure of finite sets under union. Every ACI equivalence class corresponds to a unique finite set of variables, and the canonical form is a sorted enumeration of that set.

## Why It Matters Beyond Mathematics

The practical implications span multiple fields:

**Faster optimization.** In shortest-path algorithms like Floyd-Warshall, the same candidate path can appear multiple times during recursive decomposition. ACI normalization eliminates these redundancies automatically, potentially reducing the size of intermediate expressions by factors of two or more.

**Smarter compilers.** Program analysis tools use lattice operations that satisfy ACI to track properties of variables across different execution paths. Canonicalization ensures that the analysis doesn't waste time re-examining states it has already explored.

**Cleaner mathematics.** Tropical polynomials — expressions combining `min` and addition — describe geometric objects called tropical varieties. Duplicate terms in a tropical polynomial don't affect the geometry, but they clutter the algebra. ACI normalization strips them away, revealing the essential structure.

**Reliable automation.** Perhaps most importantly, the decision procedure can be embedded directly into automated reasoning systems. Instead of requiring a human to recognize that two tropical expressions are equivalent, the machine can verify it in microseconds — with a mathematical proof of correctness standing behind every answer.

## The Proof That Proves Itself

What makes this result unusual in the history of algorithm design is the level of certainty attached to it. The correctness proofs are not informal arguments or "proof sketches" — they are machine-checked derivations, verified down to the axioms of logic. No human error can hide in the chain of reasoning. The algorithm doesn't just work in practice; it works in principle, provably, forever.

This kind of certified correctness is becoming increasingly important as algorithms are deployed in safety-critical applications. When an autonomous vehicle relies on optimization algorithms to plan its route, or a medical device uses timing analysis to guarantee response deadlines, the difference between "we tested it and it seems to work" and "we proved it correct" can be the difference between life and death.

## A Door Opens

The canonicalization of tropical `min` expressions may seem like a narrow technical achievement. But it sits at the entrance to a much larger territory.

The same algebraic structure — ACI — appears whenever we take the "best" of several options: the shortest path, the cheapest price, the fastest route, the most conservative estimate. In each case, seeing the same option twice doesn't help. In each case, a canonical form exists, waiting to be computed.

The next frontier is extending this normalization to the full tropical semiring, where `min` interacts with addition. That's where the real complexity lives — and where the real applications multiply. Tropical Gröbner bases, canonical tropical polynomial forms, certified simplification for min-plus control systems: all are now within reach, built on the foundation of this deceptively simple four-step algorithm.

Flatten. Sort. Deduplicate. Rebuild.

Four steps that turn chaos into canon — and prove it, mathematically, once and for all.
