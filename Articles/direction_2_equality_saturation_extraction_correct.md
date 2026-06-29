# The Cloud of Equivalents: How Mathematicians Proved That Finding the "Best" Version of Anything Is a Quotient Search

## The Compiler's Secret Dilemma

Every time you open a web browser, stream a video, or tap a weather app, something invisible happens in the background: a compiler transforms the human-readable code written by programmers into machine instructions your device can execute. But here's the thing most people don't realize — a compiler doesn't just translate. It *optimizes*. It searches for faster, cheaper, more efficient ways to say the same thing.

And that search is, at its core, a mathematical problem of staggering depth.

Consider a simple arithmetic expression: `(a × 1) + (b × 0) + (a × 0 + a)`. Any high schooler can simplify this to `2a`. But a compiler has to do this with billions of such expressions, across a language far more complex than arithmetic, and it has to be *absolutely certain* that its "simplification" doesn't change the program's behavior. One wrong optimization, and your banking app computes the wrong balance.

For decades, compilers used a well-understood technique: *normalization*. Take every expression, apply a fixed set of simplification rules in a fixed order, and reduce it to a unique "normal form" — a canonical representative of its meaning. If two expressions reduce to the same normal form, they're equivalent. Simple, clean, provably correct.

But normalization has a fatal limitation. It demands a *canonical* choice. There must be exactly one "best" way to write each expression, and the system must always find it. For many real-world optimization problems — circuit design, machine learning model compression, cryptographic protocol simplification — no such canonical form exists, or finding it is computationally infeasible.

In the late 1990s and early 2000s, computer scientists began exploring a radical alternative. What if, instead of reducing to a single canonical form, you could explore *all* equivalent ways of writing an expression simultaneously?

## The E-Graph Revolution

The idea is called *equality saturation*, and the data structure that makes it possible is called an *e-graph* — short for "equivalence graph."

Imagine a vast cloud of mathematical expressions. Some of them mean the same thing: `a + b` and `b + a`, for instance, or `x × 1` and `x`. In an e-graph, you don't pick one representative. You keep *all* of them, grouped into clusters called *e-classes*. Every expression in a cluster is equivalent to every other expression in that cluster.

Now comes the key insight. Instead of applying simplification rules one at a time, hoping you'll converge on the best form, you apply all applicable rules simultaneously, merging the e-classes as you discover new equivalences. The graph *saturates* — it reaches a state where no new equivalences can be found. At that point, every equivalence that could possibly be derived from the rules has been captured.

Only then do you pick a representative. You walk through each e-class, select the "cheapest" expression according to whatever cost metric you care about — fewest operations, lowest energy, smallest circuit — and extract it.

This approach, pioneered in tools like egg (e-graphs good) and subsequently adopted in production compilers, has achieved stunning results. It has found optimizations that traditional normalizing compilers missed entirely. It has been applied to everything from floating-point arithmetic to 3D graphics pipelines to tensor computation scheduling.

But there was a nagging question that nobody had rigorously answered: *Why does this work?*

## The Missing Proof

The practitioners knew it worked — they could see it producing correct results on billions of test cases. But the mathematical foundations were surprisingly shaky. Why should picking the cheapest element from a saturated e-class preserve the meaning of the original expression?

The answer turns out to lie in one of the oldest and most beautiful ideas in mathematics: the *quotient*.

A quotient is what you get when you declare certain things to be "the same." Consider the integers modulo 3: you declare that 0, 3, 6, 9, ... are all "the same," and similarly for 1, 4, 7, 10, ... and 2, 5, 8, 11, .... The resulting quotient has just three elements, and arithmetic still works on it — addition and multiplication are well-defined on the equivalence classes, not just on individual numbers.

This is exactly what's happening with e-graphs. The rewrite rules generate an equivalence relation — two expressions are equivalent if you can transform one into the other by a finite sequence of rule applications (in either direction). This equivalence relation partitions the space of all expressions into equivalence classes. And a semantic evaluation function — one that computes the "meaning" of an expression — is *constant* on each equivalence class. That's what it means for the rules to be *sound*: they never change the meaning.

The new mathematical result makes this precise. It proves three things:

**First**, any extractor that picks a representative from the correct equivalence class automatically preserves semantics. It doesn't matter *which* representative you pick — the cheapest, the prettiest, a random one. As long as it's in the same class, the meaning is preserved. This is the *extraction soundness theorem*.

**Second**, if the extractor picks the cheapest representative in the class (according to some cost metric), then extraction is not just sound but *optimal*. No other equivalent expression in the saturated domain can be cheaper. This is the *certified optimization theorem*.

**Third**, and most surprisingly, extraction and normalization are doing the same thing at the deepest level — they are both computing sections of the same quotient map. A normalizer picks a *canonical* representative of each equivalence class. An extractor picks an *optimal* representative. Both are functions from the quotient to the original type that respect the equivalence relation. They agree semantically: the meaning of the extracted term always equals the meaning of the normal form.

## Why This Matters Beyond Compilers

This result is far more than a technical lemma about compiler optimization. It reveals a fundamental pattern: *optimization as quotient search*.

Here's the pattern in its purest form. You have a space of objects. You have a notion of equivalence (symmetry, rewrites, physical invariance — anything that partitions the space into classes of "same-meaning" objects). You have a cost function. And you want the cheapest object in each class.

This pattern appears everywhere:

**In physics**, symmetries define equivalence classes of states. The ground state of a physical system is the cheapest (lowest-energy) representative of its symmetry orbit. Energy minimization subject to symmetry constraints is quotient optimization.

**In machine learning**, equivalent neural network architectures — networks that compute the same function but differ in structure — form equivalence classes. Model compression seeks the smallest network in the equivalence class of a given model. That's extraction from a saturated e-graph of architectures.

**In drug design**, molecules that bind to the same receptor site with the same affinity form equivalence classes. The "cheapest" molecule — easiest to synthesize, most stable, least toxic — is the optimal representative. Medicinal chemistry is, in a precise sense, extraction from a molecular equivalence graph.

**In mathematics itself**, proofs of the same theorem form an equivalence class. The shortest proof, the most illuminating proof, the most generalizable proof — these are different cost metrics applied to the same equivalence class of logical derivations.

The new theorem says: in *all* of these settings, if your equivalence relation is complete (you've found all the equivalences) and sound (equivalent things really are equivalent), then picking the cheapest representative is guaranteed to preserve meaning. You can optimize without fear.

## The Bridge Between Two Worlds

What makes this result intellectually exciting is that it bridges two mathematical traditions that have historically developed in isolation.

On one side: *term rewriting theory*, a branch of mathematical logic and computer science dating back to the 1930s. Church, Rosser, and later Knuth and Bendix developed the theory of confluent and terminating rewrite systems — systems where applying simplification rules in any order always leads to the same normal form. This is the world of canonical representatives, unique normal forms, and the satisfying certainty that there is One True Simplified Form.

On the other side: *quotient semantics*, a branch of abstract algebra and category theory. Here, the focus is not on choosing canonical representatives but on understanding the *structure* of equivalence classes themselves. The quotient is a first-class mathematical object. Functions on the quotient are well-defined by construction. There is no need for canonical forms — any representative will do, as long as your operations respect the equivalence.

The new result shows that equality saturation is the meeting point. The e-graph is a finite approximation of the full equivalence relation generated by rewrite rules. When it saturates (captures all equivalences), it coincides with the quotient defined by the rewrite system. Extraction is a section of the quotient map — a choice of representative from each class — that happens to minimize cost.

This means that all of the theoretical guarantees from both traditions apply simultaneously. From term rewriting, you get the guarantee that saturation terminates for well-behaved (convergent) systems. From quotient semantics, you get the guarantee that any class-respecting function is sound.

## The Algorithmist's Gift

Beyond the pure mathematics, the result has immediate practical implications.

Modern equality saturation engines like egg, egglog, and Metatheory.jl operate on bounded e-graphs — they saturate up to a finite depth or size limit. The full theorem shows that even *partial* saturation preserves soundness: as long as the e-graph relation is sound (only merges truly equivalent terms), extraction preserves meaning, even if some equivalences haven't been discovered yet.

This means engineers can use equality saturation with confidence even when they can't afford full saturation. The extractor might miss the globally cheapest equivalent, but it will never produce a *wrong* answer. Soundness is unconditional; optimality is conditioned on completeness.

For the growing field of verified compilation — where compilers come with mathematical proofs that they never introduce bugs — this is exactly the missing piece. Previous verified compilers used normalization, which limits them to well-orderable rule systems. The new theorem opens the door to verified equality-saturation-based compilers, which can explore a vastly larger space of optimizations.

## An Open Frontier

The mathematics opens as many questions as it answers.

One tantalizing conjecture: for finite convergent rewrite systems, is there always a polynomial bound on the saturation depth needed to capture all equivalences? If so, equality saturation would be not just correct but *efficient* in a strong theoretical sense. If not — if some systems require exponentially many saturation steps — that would fundamentally limit the technique and suggest where hybrid approaches are needed.

Another frontier: extending the theory from term rewriting to higher-order rewriting, where the "terms" being rewritten can themselves contain functions and abstractions. This would connect equality saturation to the lambda calculus and open the door to verified optimization of functional programs at a deep semantic level.

And perhaps the most ambitious direction: treating equality saturation as a general-purpose mathematical tool, not just a compiler technique. Could we use saturated e-graphs to explore the equivalence classes of mathematical conjectures themselves, searching for the "simplest" formulation of an open problem? Could we build a mathematical search engine that, given a theorem, automatically finds the most elegant equivalent statement?

## The Deeper Lesson

At its heart, this result tells us something profound about the relationship between equivalence and optimization. When we search for the "best" version of something — the fastest program, the simplest proof, the cheapest design — we are navigating an equivalence class. The constraint is that the meaning must be preserved. The objective is to minimize cost.

This is not a metaphor. It is a theorem. And like all good theorems, it takes something we intuitively knew — that equivalent things can be swapped — and makes it precise, general, and actionable.

The next time your code compiles faster than expected, or your GPS finds a shorter route, or a drug designer identifies a simpler molecule with the same activity, remember: somewhere behind the scenes, an algorithm is searching a cloud of equivalents, picking the cheapest one, and a theorem guarantees that the meaning is preserved.

That's the quiet power of mathematics: making sure the world works correctly, even when you can't see it happening.
