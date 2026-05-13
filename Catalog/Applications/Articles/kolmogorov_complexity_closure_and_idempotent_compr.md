# The Mathematics of Perfect Compression: How a Simple Rule Reveals What Cannot Be Simplified

## When "Do It Again" Changes Nothing

Imagine you've just organized your closet. Shirts folded, pants hung, shoes lined up. Now imagine you organize it again. Nothing changes — it was already organized. This seemingly trivial observation — that organizing an already-organized closet does nothing — is the mathematical seed of a breakthrough connecting compression, algebra, and the fundamental limits of information.

Mathematicians call this property *idempotence*: an operation that, when applied twice, gives the same result as applying it once. It sounds like a curiosity. But a team of researchers has now shown that idempotence is the skeleton key to understanding why some data can never be compressed — and why the best possible compressed version of any piece of information is always a "fixed point" of the compression process itself.

Their work bridges three seemingly unrelated fields: the theory of closure operators from abstract algebra, the tropical semiring from combinatorial optimization, and the counting arguments at the heart of information theory. The result is a rigorous mathematical framework that captures the essence of compression without requiring the impossible: computing the actual shortest description of every possible piece of data.

## The Compression Paradox

Here's a puzzle that has haunted computer science since the 1960s: given any piece of data — a photograph, a genome, a novel — what is the absolute shortest way to describe it? The Russian mathematician Andrey Kolmogorov formalized this question in 1965, defining the "Kolmogorov complexity" of a string as the length of the shortest computer program that produces it.

The catch? Kolmogorov complexity is *uncomputable*. No algorithm can determine the shortest description of an arbitrary piece of data. This is not a matter of insufficient computing power — it is a mathematical impossibility, proven with the same tools that show the halting problem is unsolvable.

For sixty years, this uncomputability has been a wall. Researchers could prove beautiful theorems *about* Kolmogorov complexity, but they couldn't *use* it directly. The new framework sidesteps this wall entirely.

## The Closure-Compression Connection

The key insight begins with a simple question: what does it mean for a compression scheme to be "done"?

Consider any compression process — call it *c* — that takes a piece of data and produces a compressed version. If the compression is well-designed, compressing an already-compressed file should leave it unchanged. In mathematical notation: *c(c(x)) = c(x)* for every input *x*. This is exactly idempotence.

Now add one more requirement: compression should never make things longer. The compressed version *c(x)* should always be at most as long as the original *x*.

These two axioms — idempotence and length-nonincreasing — define what the researchers call an *admissible compressor*. And from these two axioms alone, a rich mathematical structure emerges.

The first breakthrough result: **the fixed points of an admissible compressor — the data that compression leaves unchanged — are exactly the range of the compressor.** In other words, every compressed output is already in its final form, and every piece of data that can't be compressed further is itself a valid compressed output. This isn't obvious: it says the "incompressible" objects and the "already compressed" objects are the same set.

## The Fiber Theorem: Why Fixed Points Are Optimal

The deeper result is the *fiber optimality theorem*. Think of a compressor as sorting data into bins: everything that compresses to the same output lands in the same bin. These bins are called "fibers" in mathematics.

The theorem proves that under a natural optimality condition — the compressed representative is the shortest member of its bin — **the fixed points are exactly the shortest representatives of their equivalence classes.** The compressor doesn't just find *a* short description; it finds *the* shortest one available.

This is remarkable because it connects the algebraic property of idempotence to the information-theoretic goal of finding minimal descriptions. The abstract algebra is doing the work of optimization.

## Tropical Algebra: The Cost of Descriptions

The connection goes deeper still. In the 1990s, mathematicians developed "tropical mathematics" — a strange version of algebra where addition is replaced by taking the minimum and multiplication is replaced by ordinary addition. Tropical algebra sounds like a mathematical game, but it turns out to be the natural language for optimization problems, from shortest paths in networks to scheduling in factories.

The new framework shows that compression costs satisfy tropical algebra. The *closure cost* of a piece of data — the minimum description length across all equivalent representations — behaves like a tropical sum. More precisely, the researchers prove that the closure cost function is itself idempotent: computing the minimum cost, then recomputing it after compression, gives the same answer. In tropical language: **the compression operator computes the tropical minimum description length on each equivalence class.**

This is not a metaphor or an analogy. It is a theorem with a complete mathematical proof. The idempotent semiring structure of tropical algebra is literally the algebraic skeleton of optimal compression.

## What Cannot Be Compressed: A New Characterization

Perhaps the most striking result concerns incompressibility itself. The researchers define a *strict* admissible compressor as one that genuinely shortens every non-fixed input. Then they prove:

**An element is incompressible — meaning no strict compressor can shorten it — if and only if it is a fixed point of every strict compressor.**

Read that again. Incompressible data is exactly the data that *every possible* well-behaved compression scheme leaves alone. This is the closure-theoretic shadow of Kolmogorov's original insight — that random strings resist compression — but stated in a way that is mathematically precise and computationally meaningful.

The beauty is in the "if and only if." Not only do incompressible elements resist compression (which is obvious), but elements that resist all compressions are genuinely incompressible (which is the deep direction). The proof uses a elegant contrapositive argument: if some compressor could compress *x*, then the strict length reduction would witness the compression, contradicting the assumption.

## Counting the Incompressible

How many incompressible objects are there? The counting theorem gives a precise answer through the lens of partition theory. For any idempotent compressor on a finite set:

**The number of compressed elements plus the number of fixed points equals the total number of elements.**

This is a partition identity: every element is either compressed or left alone, with no overlap and nothing missed. Combined with the fiber theorem, it yields quantitative bounds: a compressor with few fixed points must compress many elements, and conversely, a compressor that leaves many elements alone must have a large range.

For binary strings of length *n*, these counting arguments recover the classical result that most strings are incompressible — but through the new framework's lens of closure operators rather than through counting programs.

## From Theory to Practice

The framework is not merely theoretical. The researchers demonstrate concrete applications:

**Data deduplication.** When you normalize text by collapsing whitespace and standardizing case, you're applying an idempotent compressor. The canonical forms (fixed points) are the deduplicated entries, and the fiber structure reveals which inputs are semantically identical.

**Compiler optimization.** Expression normalization in compilers — sorting commutative operands, folding constants, eliminating common subexpressions — is an idempotent operation. The fixed points are the irreducible expressions, and the theorem guarantees they are the shortest representations.

**Machine learning.** Feature quantization — rounding continuous values to discrete levels — creates an idempotent compressor on feature space. The framework quantifies exactly how much information is lost and how many distinct patterns survive.

## A Bridge Across Mathematics

What makes this work genuinely novel is not any single theorem but the bridge it builds. Closure operators come from order theory and lattice theory. Tropical algebra comes from algebraic geometry and optimization. Incompressibility counting comes from information theory and computability. The framework shows these are all facets of the same mathematical diamond.

The researchers' insight is that you don't need the full power (and full uncomputability) of Kolmogorov complexity to capture the structure of compression. Idempotence alone — the simplest possible axiom about a compression scheme — already forces a rich mathematical landscape: optimal representatives, tropical costs, incompressibility characterizations, and counting theorems.

It's as if organizing your closet taught you about the fundamental limits of information in the universe. Sometimes the deepest mathematics hides in the simplest observations.

## What Comes Next

The framework opens several research frontiers. Can the closure-compression duality be extended to infinite domains, capturing compression of infinite sequences? Can the tropical cost function be connected to entropy rates in ergodic theory? Can the incompressibility characterization be sharpened to yield constructive certificates of randomness?

Most provocatively: can the framework serve as a *computable surrogate* for Kolmogorov complexity — not computing the exact shortest description, but providing provable upper and lower bounds through families of concrete compressors?

These questions sit at the intersection of algebra, computation, and information theory. Sixty years after Kolmogorov proved that perfect compression is impossible to compute, mathematicians have found a way to reason rigorously about compression without computing it at all. The key was hiding in plain sight: do it again, and nothing changes.
