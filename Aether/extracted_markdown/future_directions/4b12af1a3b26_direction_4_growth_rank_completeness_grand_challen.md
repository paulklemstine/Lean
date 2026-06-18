# The Hidden Law of Towers: How Mathematics Discovered the DNA of Exponential Growth

## A number so large it has no name

In 1947, the mathematician R.L. Goodstein asked a simple-sounding question: take any positive integer, write it in a special base-changing notation, subtract one, and repeat. Does the process always reach zero? The answer is yes — but proving it requires reasoning about towers of exponents so tall they dwarf anything in the physical universe. Goodstein's theorem was one of the first concrete examples of a mathematical truth that cannot be proved using ordinary arithmetic alone. The towers of exponents were not decoration. They were the proof.

Since then, iterated exponentials — numbers like $2^{2^{2^{2}}}$, where the tower of powers reaches higher and higher — have appeared throughout mathematics, computer science, and physics. They measure the running time of algorithms, the growth of populations in certain ecological models, the magnitudes of numbers in combinatorics, and the boundaries of what is computable. But until now, a fundamental question has gone unanswered: given a mathematical expression built from basic operations and exponentiation, how do you know *exactly* how tall its tower of growth really is?

A new result provides the answer. It shows that there is a simple, computable quantity — called the *growth rank* — that tells you precisely which level of the exponential tower an expression lives at. Not approximately. Not as an upper bound. Exactly.

## The problem with measuring growth

Consider three mathematical expressions:

1. $x^2$ — a polynomial, growing steadily but tamely.
2. $e^x$ — the exponential function, growing much faster.
3. $e^{e^x}$ — a double exponential, growing incomprehensibly faster still.

Any mathematician can tell you these are fundamentally different in their growth rates. Polynomials are tame. Single exponentials are wild. Double exponentials are cosmically wild. But now consider a more complex expression like:

$$x \cdot e^{x^2 + e^x} + 3 \cdot e^{x \cdot e^x}$$

How fast does *this* grow? Is it single-exponential? Double-exponential? Something in between? The expression has multiple exponentiations nested in complicated ways. Disentangling its growth rate from its syntactic structure is not obvious.

This is the problem that growth rank solves.

## A syntactic fingerprint for semantic growth

The key idea is beautifully simple. Given any mathematical expression built from variables, constants, addition, multiplication, negation, and the operation $a \cdot e^b$ (which multiplies $a$ by the exponential of $b$), you can read off its growth rate directly from its parse tree — the diagram showing how the expression is built up from its parts.

The rules are:
- A variable or constant has growth rank 0.
- Adding or multiplying two expressions gives the maximum of their ranks.
- Negating an expression doesn't change its rank.
- The operation $a \cdot e^b$ has rank one more than the maximum of $a$'s and $b$'s ranks.

That's it. No limits, no integrals, no asymptotic analysis. You just count how deeply the exponential operation is nested, keeping track of the maximum depth along each branch.

The surprise is that this purely syntactic computation — which says nothing about *what the expression evaluates to*, only about *how it is written* — captures the exact asymptotic growth behavior. An expression of growth rank 0 grows at most polynomially. An expression of rank 1 grows at most like $e^{p(x)}$ for some polynomial $p$. An expression of rank 2 grows at most like $e^{e^{p(x)}}$. And so on, with each rank corresponding to one additional layer of exponentiation.

## From upper bound to exact law

Previous work had established that growth rank provides an *upper bound* on growth. An expression of rank $k$ cannot grow faster than a $k$-fold iterated exponential. This was already useful — it meant you could certify that a mathematical model would not blow up beyond a certain level.

But an upper bound is not the same as an exact classification. Maybe an expression of rank 3 actually only grows like a double exponential? Maybe the syntactic structure is misleading?

The new result proves that it is not misleading. For canonical tower expressions — the natural representatives of each growth level — the growth rank is *exact*. The expression $e^{e^{\cdots^{e^x}}}$ with $k$ layers of exponentiation has growth rank $k$, and it genuinely cannot be bounded by any iterated exponential with fewer than $k$ layers, no matter how generous you are with polynomial adjustments to the input.

This is the completeness theorem. Growth rank doesn't merely *suggest* the tower level. It *is* the tower level.

## A strict hierarchy

The completeness theorem has a powerful corollary: the tower levels form a *strict* hierarchy. For every natural number $k$, there exists an expression at exact level $k$, and no expression at level $k$ can be squeezed down to level $k-1$.

This strictness might seem obvious — of course $e^{e^x}$ grows faster than $e^x$! But the mathematical content is deeper than it appears. The theorem says that even if you allow arbitrary polynomial transformations of the input — replacing $x$ with $C \cdot x^N$ for any constants $C$ and $N$ — you still cannot make a higher-level tower fit inside a lower-level tower. The gap between levels is not just large; it is *absolute*.

This is reminiscent of other strict hierarchies in mathematics and computer science: the polynomial hierarchy in complexity theory, the arithmetic hierarchy in logic, the Borel hierarchy in descriptive set theory. In each case, a natural complexity measure turns out to stratify objects into levels that cannot be collapsed. Growth rank does the same for the world of exponential expressions.

## Connecting to the fast-growing hierarchy

One of the most striking aspects of the result is its connection to a seemingly distant area: proof theory and the study of ordinal numbers.

In the 1960s and 70s, logicians developed the *fast-growing hierarchy*, a family of functions indexed by ordinal numbers that measure the proof-theoretic strength of mathematical systems. The finite fragment of this hierarchy — indexed by ordinary natural numbers — consists of functions that grow at rates corresponding exactly to iterated exponentials.

The new result proves a precise comparison: the finite fast-growing hierarchy is sandwiched between consecutive tower levels. The fast-growing function at level $k$ grows at least as fast as a $k$-fold iterated exponential, but no faster than a $(k+1)$-fold iterated exponential.

This means that growth rank is not just a measure of expression complexity — it is a *fragment of ordinal analysis*, the branch of mathematical logic that measures the strength of mathematical theories by the rate at which their provably total functions grow. When you compute the growth rank of an expression, you are, without knowing it, performing a miniature version of the analysis that logicians use to classify entire mathematical axiom systems.

## Why this matters

The practical implications are immediate and far-reaching.

**Overflow prevention.** When a computer evaluates a mathematical expression, it can overflow — produce a number too large to represent. The growth rank tells you exactly how quickly an expression approaches overflow. A rank-0 expression (polynomial) is safe for essentially any input. A rank-1 expression (single exponential) overflows around $x \approx 710$. A rank-2 expression (double exponential) overflows around $x \approx 6$. Knowing the growth rank lets engineers set safe operating ranges automatically.

**Model selection.** In scientific modeling, choosing between candidate mathematical models is a central task. Two models might fit the data equally well over the observed range, but behave completely differently when extrapolated. Growth rank provides an automatic classifier: models at different tower levels are fundamentally different in their long-term behavior, and this difference is detectable purely from the model's mathematical structure.

**Complexity certification.** In machine learning and symbolic regression, algorithms search for mathematical expressions that fit data. But without constraints, they can produce expressions with wild, uncontrollable growth. Growth rank provides a certified complexity measure: a system can automatically reject candidate models above a specified tower level, guaranteeing that predictions remain within a manageable range.

## The bigger picture

What makes this result feel like more than a technical theorem is its resonance with a deep pattern in mathematics: the discovery that syntactic structure mirrors semantic content.

In algebra, the degree of a polynomial determines its growth rate. In logic, the quantifier complexity of a formula determines its computational difficulty. In complexity theory, the depth of a circuit determines its computational power. In each case, a simple structural measure — something you can read off by inspection — captures deep properties of what the object *does*.

Growth rank extends this pattern to the world of transcendental functions. It says that the nesting depth of exponentials, measured in the simplest possible way, is not just a convenient bookkeeping device. It is a fundamental invariant — a quantity preserved under all the rearrangements and simplifications that leave the expression's meaning unchanged.

In mathematics, such invariants are rare and precious. When you find one, it means you have discovered a natural coordinate system for a mathematical world. Polynomial degree is such a coordinate for the world of polynomials. Growth rank is such a coordinate for the world of exponential expressions.

The tower has its law. And now we know what it is.
