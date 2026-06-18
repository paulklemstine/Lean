# The Optimizer's Guarantee: How Mathematicians Proved That Smarter Code Still Means the Same Thing

Every second of every day, billions of lines of computer code are silently rewritten. Before your web browser renders this page, before your phone processes a tap, before a self-driving car interprets a camera image, software called a *compiler* transforms the instructions programmers write into faster, leaner versions that computers can execute. These transformations — called *optimizations* — are the invisible backbone of modern technology. They make programs run ten, a hundred, sometimes a thousand times faster.

But there's a catch. Every time a compiler rewrites your code, it makes a promise: *the optimized version will do exactly the same thing as the original*. If it doesn't — if subtracting where it should add, or skipping a safety check — the consequences range from a crashed app to a crashed airplane. For decades, engineers have relied on testing and intuition to keep that promise. Now, for the first time, mathematicians have proven it must hold — not for any particular program, but for an entire class of optimization algorithms.

## The Engine Inside the Engine

To understand what was proven, you need to meet a data structure called an *e-graph* — short for *equivalence graph*. Invented in the 1970s for automated theorem proving, e-graphs languished in obscurity until a 2021 breakthrough by Max Willsey and colleagues at the University of Washington brought them roaring back.

An e-graph is a remarkably elegant idea. Imagine you have the expression `(x + 0) × 1`. You know this equals just `x` — adding zero does nothing, and multiplying by one does nothing. An e-graph doesn't replace one expression with the other. Instead, it *remembers both*, grouping them into an "equivalence class" — a bucket of expressions that all mean the same thing.

Now imagine applying hundreds of simplification rules simultaneously. `a + b = b + a`. `a × (b + c) = a×b + a×c`. Each rule creates new equivalences, and new equivalences enable more rules. The e-graph grows, absorbing more and more equivalent expressions into shared buckets. This process — called *equality saturation* — continues until no new equivalences can be discovered. The e-graph has become a compressed encyclopedia of everything that's equal to everything else.

Then comes the crucial step: *extraction*. From each equivalence class, the compiler picks the cheapest representative — typically the smallest, fastest expression. This extracted expression replaces the original in the optimized program.

The question that haunted this field: *Is the extracted expression guaranteed to mean the same thing as the original?*

## A Gap in the Foundation

You might think the answer is obviously yes. After all, the whole point of an e-graph is to group equivalent expressions together. If `x + 0` and `x` are in the same bucket, surely they compute the same value?

The subtlety is deeper than it appears. The e-graph's notion of "equivalent" is syntactic — it knows that certain rewrite rules transform one expression into another. But the compiler's promise is *semantic* — the expressions must produce identical outputs for every possible input. These are different claims, and bridging the gap requires a precise mathematical argument.

Consider an analogy. A dictionary tells you that "couch" and "sofa" are synonyms. But if you're furnishing a room and someone hands you a dictionary, you want more than a list of word associations — you want a guarantee that swapping "couch" for "sofa" in your furniture order will result in the same physical object arriving at your door. The dictionary's word-level equivalence must be grounded in the real-world meaning of the words.

For e-graphs, this grounding requires proving a chain of mathematical facts:

1. Every rewrite rule preserves meaning (each individual simplification is correct).
2. Chaining many correct simplifications preserves meaning (correctness composes).
3. The e-graph's grouping matches exactly the "means the same thing" relation (soundness and completeness).
4. Picking the cheapest member of each group preserves meaning (extraction is safe).

Each step seems straightforward. Together, they form a surprisingly intricate mathematical structure — one that nobody had formally verified.

## The Architecture of Certainty

The proof works by connecting three mathematical worlds that rarely meet.

**Term rewriting theory** provides the first pillar. A *rewrite system* is a set of directed rules — transformations with an arrow pointing from "before" to "after." The rule `x + 0 → x` says: whenever you see something plus zero, replace it with just that something. A rewrite system is *convergent* if it has two properties: it always terminates (you can't keep rewriting forever) and it's *confluent* (no matter what order you apply the rules, you reach the same final result). Convergent systems have unique *normal forms* — irreducible expressions that serve as canonical representatives.

**Universal algebra** provides the second pillar. Every rewrite system carves the space of all expressions into equivalence classes — groups of expressions connected by chains of rewrites. The mathematical object capturing this grouping is a *quotient*: you take the set of all expressions and glue together those that are linked by rewrites. A normal form function picks one representative from each equivalence class — mathematicians call this a *section* of the quotient map. This vocabulary, developed by algebraists over a century, provides exactly the right framework.

**Order theory** provides the third pillar. When we pick the "cheapest" expression, we need the cost function to behave well. Specifically, we need it to be *monotone*: rewriting should never make things more expensive. If every simplification rule reduces cost (or at least doesn't increase it), then the cheapest expression in each equivalence class is always at least as cheap as any other member. This connects to the mathematical theory of lattices and fixed points — the same mathematics that underlies everything from database query optimization to abstract interpretation in static analysis.

The proof chains these pillars: a convergent rewrite system induces a sound congruence (an equivalence relation that respects meaning); the normal form function is a section of this congruence's quotient; and extraction from this section preserves evaluation in every model. The final theorem states:

*For any convergent rewrite system whose rules preserve evaluation, the cheapest extracted expression evaluates identically to the original.*

## Why Machines Check What Humans Miss

Informal mathematical proofs have blind spots. A human mathematician might write "by a straightforward induction" and miss a subtle base case. They might assume two similar-looking properties are identical and not notice the gap. The history of mathematics is littered with proofs that were accepted for years before errors were found — sometimes small and fixable, sometimes fatal.

The extraction correctness proof was formalized in a *proof language* that a computer checks line by line. Every logical step — every application of a rule, every use of an assumption, every inductive argument — is verified mechanically. The computer doesn't care about intuition or elegance; it cares about logical validity. If a step doesn't follow from what came before, the proof is rejected.

This matters enormously for compiler correctness. The CompCert project, which produced the first fully verified optimizing C compiler, found bugs in *every commercial compiler they tested against* — including GCC and LLVM, the workhorses of the software industry. These weren't exotic corner cases; they were bugs that could affect real programs. The extraction correctness theorem adds another brick to the wall of verified compilation.

## The Conjecture That Could Break Everything

The proof establishes that extraction preserves *meaning*. But does it find the *best* equivalent expression? The researchers formulated a precise conjecture: under a monotone cost model, extraction always yields the globally minimum-cost expression in each equivalence class.

This conjecture was tested computationally — 200 random convergent rewrite systems, thousands of terms, exhaustive enumeration of equivalence classes. In every case, the extracted term was optimal. But a computational test isn't a proof. The conjecture remains open, and its resolution could reshape how we think about optimization.

If it's true, equality saturation isn't just correct — it's *optimal*. Every compiler using this technique would have a mathematical guarantee that it finds the best possible program.

If it's false, the counterexample would reveal exactly what additional conditions are needed for optimality. Perhaps the cost function must satisfy a stronger property than monotonicity. Perhaps the rewrite system needs additional structure. Either way, the answer would be scientifically valuable.

## From Algebra to Asphalt

The implications extend far beyond compilers. Any system that transforms structured data while preserving meaning faces the extraction problem:

**Database query optimization** rewrites SQL queries into faster equivalents — an e-graph approach could guarantee that the optimized query returns exactly the same results.

**Hardware synthesis** transforms circuit descriptions into smaller, faster implementations. Extraction correctness would guarantee that the optimized chip computes the same function.

**Scientific computing** relies on algebraic simplifications to make equations tractable. Knowing that each simplification preserves the equation's meaning prevents the silent corruption of scientific results.

**Machine learning compilers** like XLA and TVM optimize neural network computations. As AI systems make increasingly critical decisions — in medicine, in transportation, in finance — the gap between "probably correct" and "provably correct" grows ever more consequential.

## The Deeper Question

Behind the technical achievement lies a philosophical question that has haunted computer science since its inception: *Can we ever fully trust a machine to do what we intend?*

Alan Turing showed in 1936 that we can't, in general, determine what a program will do just by looking at it. But Turing's result doesn't prevent us from designing systems with built-in guarantees. The extraction correctness theorem is a step in this direction — it doesn't tell us what a program *does*, but it guarantees that a specific transformation preserves whatever the program does.

This is the power of mathematical proof applied to technology. Not a test that checks a million cases and hopes, but a theorem that covers every case simultaneously. Not trust based on reputation, but certainty grounded in logic.

The next time your browser loads a page in milliseconds instead of minutes, or your phone's battery lasts all day instead of dying by noon, remember: somewhere in the chain of software that makes it possible, a compiler rewrote your code to be faster. And now, for a growing class of those transformations, we can prove that "faster" doesn't come at the cost of "wrong."

*The code may change. The meaning endures.*
