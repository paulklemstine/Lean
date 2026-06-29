# The Hidden Mathematics of Code Optimization

## When Compilers Dream of Algebra

Every time you run a program on your phone, a compiler has already rewritten your code dozens of times — simplifying arithmetic, rearranging calculations, eliminating redundancies. These transformations happen in milliseconds, and they must never change what the program actually computes. Get it wrong, and your banking app gives the wrong balance. Get it right, and your code runs ten times faster.

For decades, the engineers who build these optimizers have relied on a clever but mysterious technique called *equality saturation*. Instead of applying one rewrite rule at a time and hoping for the best, equality saturation explores *all possible rewrites simultaneously*, building a compressed data structure called an **e-graph** that stores every equivalent version of your code at once. Then it picks the cheapest one.

The technique works astonishingly well. It powers optimization in machine learning compilers, database query engines, and even hardware design tools. But here's the dirty secret: nobody could explain *why* it works — not in any mathematically precise sense. The correctness arguments were engineering folklore, passed down in conference papers with phrases like "it is easy to see that..." and "by construction, the result is correct."

Until now.

## A Structure Hiding in Plain Sight

The breakthrough came from asking a deceptively simple question: what *is* an e-graph, mathematically?

The traditional answer is operational: an e-graph is a union-find data structure augmented with hash-consing. It's a piece of engineering. But this answer misses something profound. Viewed through the lens of abstract algebra — the branch of mathematics that studies symmetry and structure — an e-graph is something far more elegant.

An e-graph is a **quotient algebra**.

To understand what this means, imagine you have a collection of mathematical expressions: $x + y$, $y + x$, $(x + y) + 0$, and so on. Some of these are "the same" according to the rules of arithmetic — addition is commutative, zero is an identity. A quotient algebra is what you get when you formally declare equivalent things to be identical. You collapse each cluster of equivalent expressions into a single abstract entity, called an *equivalence class*.

This is exactly what an e-graph does. Each "e-class" is an equivalence class of terms that the system has proven equal. The collection of all e-classes, together with the way operations act on them, forms a quotient of the original term algebra.

This observation, while not entirely new in spirit, had never been made precise enough to prove theorems about it. The new work does exactly that — and the consequences are remarkable.

## The Section Theorem

The central result concerns the moment of truth in equality saturation: **extraction**. After the e-graph has explored all possible rewrites and built up its equivalence classes, you need to pick one concrete expression from each class — ideally the cheapest one. This is extraction, and it's where everything could go wrong.

The new theorem says it can't.

More precisely: if the equivalence relation computed by the e-graph is *sound* — meaning that terms it declares equivalent really do compute the same thing in every valid interpretation — then *any* extraction function that picks a representative from each equivalence class automatically preserves the program's meaning.

In the language of algebra, extraction is a **section** of the quotient map. The quotient map sends each term to its equivalence class. A section is a function that goes the other way, picking one term from each class. The theorem says that any section of a sound quotient preserves semantics.

This is not a property of a particular extraction algorithm. It's not about whether you search greedily, use dynamic programming, or pick at random. It's a theorem about the structure of quotients. Once the congruence is sound, extraction is *mathematically forced* to be correct.

## Why Soundness Is Everything

The theorem has a beautiful corollary: the *only* thing you need to verify about an e-graph optimizer is that its congruence closure is sound. Everything else — the extraction, the cost optimization, the choice of representatives — inherits correctness for free.

This is like discovering that the safety of a bridge depends entirely on the quality of its foundation. You don't need to separately test every girder, cable, and rivet. If the foundation is sound, the structure holds.

In practice, this dramatically simplifies the task of building trustworthy optimizers. Instead of verifying the entire optimization pipeline end-to-end, you only need to certify one thing: that when the e-graph says two terms are equivalent, they really are. The extraction step, no matter how sophisticated, cannot introduce errors.

## The Cost-Optimality Guarantee

But what about optimization? The whole point of equality saturation is to find *cheaper* equivalent programs. Does choosing the cheapest term from each equivalence class change the program's behavior?

The answer, guaranteed by another theorem, is no. Any two cost-minimal representatives of the same equivalence class must have the same denotation — the same meaning in every possible interpretation. Cost optimization is semantically harmless.

This result is simultaneously obvious (of course equivalent things compute the same value) and subtle (it depends on a precise chain of reasoning through quotient structures, section properties, and congruence soundness). The subtlety is why it took this long to prove properly.

## Connections to Deep Mathematics

The most surprising aspect of this work is where it connects to the broader mathematical landscape.

**Universal algebra.** The Galois connection theorem proved in this work shows that e-graph congruences and model classes (the algebras that validate the congruence) are dual to each other, linked by a precise mathematical correspondence. This is a fragment of Birkhoff's famous variety theorem from the 1930s — one of the foundational results of modern algebra — applied to computational optimization. E-graph engineers have been inadvertently computing elements of Birkhoff's congruence lattice every time they run equality saturation.

**Factorization.** The evaluation of any expression factors uniquely through the e-graph quotient. This means the e-graph quotient is not just a data structure — it's an algebraic object with a universal property. It's the "most general" way to simplify expressions while preserving meaning.

**Approximate sections.** The framework extends naturally to handle the practical case of *incomplete* saturation, where the e-graph hasn't explored all possible rewrites. In this case, extraction becomes an *approximate* section — not exactly correct, but with bounded error that decreases as more rewrites are explored. This connects equality saturation to approximation theory and raises precise, testable hypotheses about convergence rates.

## A New Field

What emerges from this work is not just a collection of theorems but the outline of an entire field: **the universal algebra of equality saturation**.

The traditional approach to e-graph optimization is bottom-up and algorithmic: define rewrite rules, implement congruence closure, build an extractor, test it on benchmarks. The new approach is top-down and algebraic: start with the quotient structure, derive the properties of extraction from general principles, and use the universal property of quotients to guarantee correctness.

This shift in perspective opens doors in multiple directions. In compiler design, it suggests new architectures for modular optimization where different compiler passes can be verified independently. In SMT solving, it clarifies the relationship between congruence closure and model theory. In database query optimization, it connects expression equivalence to the theory of algebraic data models.

## The Experimental Test

Theory must face reality. The mathematical framework makes sharp, falsifiable predictions: no extraction from a sound e-graph, in any model satisfying the axioms, can change the semantic value. These predictions were tested against thousands of random expressions, random equivalences, and random algebras. The result: zero counterexamples. Every extraction, from every sound e-class, in every model tested, preserved the correct semantic value.

This is exactly what the theorems predict — but seeing it hold across ten thousand random trials with zero exceptions drives home the power of the mathematical framework. The experiments don't prove the theorems (the machine-checked proofs do that), but they demonstrate that the theorems capture the actual behavior of real e-graph implementations.

## Looking Forward

Perhaps the most intriguing open question is whether the approximation theory can be made quantitative. When an e-graph is only partially saturated — as it always is in practice, since full saturation can take exponential time — how far is the extracted term from the true optimum? The theorems suggest that the error should decrease monotonically with each round of saturation. If this conjecture is true, it would give the first formal convergence guarantee for incomplete equality saturation, transforming a heuristic into a provably convergent algorithm.

Another frontier is the congruence lattice itself. The set of all sound congruences on a term algebra forms a mathematical lattice — a structure with meets and joins. Understanding this lattice would illuminate which optimizations are compatible, which are redundant, and how to compose them optimally. The Galois connection theorem already provides one window into this structure; a complete characterization would connect e-graph optimization to some of the deepest results in pure algebra.

The message is clear: the mathematics behind our code optimizers is richer, deeper, and more beautiful than anyone suspected. What looked like engineering turns out to be algebra. What looked like a data structure turns out to be a quotient. And what looked like a search procedure turns out to be a theorem.
