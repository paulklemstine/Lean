# The Mathematics of Squeezing: How an Ancient Algebraic Trick Reveals the Hidden Structure of Compression

## A question that shouldn't have an answer

Here is a deceptively simple question: when you compress a file on your computer — zipping a folder, streaming a video, sending a text message — how do you *know* you've found the best compression? Not just a good one, but *the* best?

The unsettling answer, established by the Soviet mathematician Andrey Kolmogorov in the 1960s, is that you generally can't know. The theoretical gold standard for measuring a string's compressibility — its Kolmogorov complexity — is provably uncomputable. No algorithm can look at a sequence of data and determine the shortest possible description of it. It's not that we haven't found the right algorithm yet; it's that such an algorithm is mathematically impossible.

For sixty years, this impossibility result has cast a long shadow over the theory of compression. Practitioners build excellent compressors — gzip, JPEG, modern neural codecs — but the gap between practice and theory remains philosophically troubling. We compress data every day, yet the fundamental question "is this compressed enough?" has no general answer.

Until, perhaps, now. A new mathematical framework bridges this gap by revealing that compression is, at its heart, a geometric operation — a kind of projection — and that the objects which resist compression are characterized by a beautiful algebraic property: they are *fixed points* of an idempotent operator. This isn't a metaphor. It's a theorem.

## The closure trick

To understand the breakthrough, you need one idea from abstract algebra: a *closure operator*. Think of it as a machine that takes any object and produces a "simplified" or "canonical" version of it. The key properties are:

1. **It never makes things bigger.** The simplified version is at most as complex as the original.
2. **It's stable.** If you feed the simplified version back into the machine, you get the same thing out. Simplifying twice is the same as simplifying once.
3. **It groups things together.** Two different inputs can produce the same simplified output, meaning they're "equivalent" from the machine's perspective.

These properties might sound abstract, but you encounter closure operators constantly. When you round a number to the nearest integer, that's a closure operation on the real line. When a compiler optimizes code by removing dead variables, it's applying a closure. When you summarize a long email in a single sentence, you're performing a kind of closure on natural language.

The new result shows that any closure operator satisfying these properties automatically defines an optimal compression scheme — and the proof is startlingly clean.

## The shortest representative theorem

Here is the central result, stripped to its essence: Suppose you have a closure operator acting on some universe of data objects, and a "length" function measuring each object's size. If the closure never increases length (property 1) and applying it twice gives the same result as applying it once (property 2), then the closure image of any object is the *shortest* representative in its equivalence class.

Think about what this means concretely. Imagine you have a collection of files that are all "equivalent" in some semantic sense — they encode the same information, the same image, the same meaning. The theorem says that the closure automatically picks out the smallest file in each equivalence class. You don't need to search through all equivalent files to find the shortest one. The closure *computes* it directly, in a single step.

This is not an upper bound. It's not an approximation. The closure gives you the *exact* minimum description length within its semantic class. The infimum of all possible lengths in the equivalence class equals the length of the closure's output.

## Fixed points: the incompressible core

The framework reveals something deeper about the structure of compression. Every closure operator partitions data into two categories: objects that the closure changes, and objects that it leaves alone. The latter are *fixed points* — feed them into the machine and they come out unchanged.

The duality theorem states that these fixed points are exactly the incompressible objects. An object resists the closure's compression if and only if it's already in canonical form. This is the rigorous analogue of a famous (and famously unprovable) claim in Kolmogorov complexity theory: that random strings are exactly those that can't be compressed. Here, within the well-defined world of a specific closure operator, the claim becomes a precise, provable theorem.

The philosophical shift is significant. Instead of asking "is this string Kolmogorov-random?" (a question no algorithm can answer), we ask "is this object a fixed point of our closure?" — a question that is often decidable, always well-defined, and structurally rich enough to support deep mathematical theory.

## The tropical connection

The most vivid example of this framework comes from an unexpected corner of mathematics: *tropical geometry*.

Tropical mathematics replaces ordinary addition with the minimum operation and ordinary multiplication with addition. It sounds like a bizarre parlor trick, but tropical methods have revolutionized parts of algebraic geometry, optimization, and theoretical computer science over the past two decades. The "tropical" name, incidentally, honors the Brazilian mathematician Imre Simon, a pioneer of the field.

Here's the tropical compression operator: given a vector of numbers, subtract the smallest entry from every coordinate. The result is a new vector where the minimum entry is zero. For example, the vector (5, 3, 7) becomes (2, 0, 4).

This operation is a closure in the abstract sense. It's idempotent (normalizing a normalized vector does nothing), and it partitions vectors into equivalence classes: two vectors are equivalent if and only if they differ by a constant added to every coordinate. The vector (5, 3, 7) and the vector (105, 103, 107) are in the same class, and both normalize to (2, 0, 4).

The theorems proved in the new framework show that this normalization is optimal: among all vectors equivalent to a given input, the normalized form has the smallest total coordinate sum (when all entries are non-negative). It also proves that the fixed points — vectors that are already normalized, meaning their minimum coordinate is already zero — are exactly the tropically incompressible objects.

This is not just a toy example. Tropical normalization appears naturally in auction theory (where it normalizes bidder valuations), in phylogenetics (where it parametrizes tree spaces), and in neural network theory (where ReLU activations perform a closely related operation). The compression framework reveals a hidden unity: all these applications are performing the same fundamental geometric projection.

## One step is enough

There's an elegant consequence of idempotence that deserves its own spotlight: compression converges in exactly one step. There is no need for iterative refinement, no convergence criterion to check, no danger of oscillation. You apply the closure once, and you're done.

This is a striking contrast with most optimization algorithms, which require many iterations to converge. Gradient descent needs thousands of steps. Expectation-maximization alternates back and forth. Even simple algorithms like repeatedly sorting a list require multiple passes. But idempotent compression is fundamentally different: the algebraic structure guarantees instantaneous convergence.

In the tropical setting, this means that subtracting the minimum coordinate *once* gives you the canonical form. In the abstract setting, it means that any idempotent compressor reaches its optimal output in a single application. This is why the framework calls compression a "projection" — like projecting a point onto a line in Euclidean geometry, you land on the target in one shot.

## The bridge to information theory

The classical theory of information, founded by Claude Shannon in 1948, characterizes compression in terms of probability and entropy. Shannon's source coding theorem says that the average length of a compressed message cannot be shorter than the entropy of the source. This is a statistical guarantee: it applies on average, over many messages drawn from a known distribution.

The closure-compression framework operates at a different level. It provides *per-object* guarantees: for each individual data object, the closure gives the shortest representative in its equivalence class. There's no probability distribution, no averaging, no appeal to the law of large numbers. The guarantee is algebraic and exact.

This suggests a tantalizing synthesis. Shannon's entropy describes optimal compression when you know the statistical structure of your data source. Kolmogorov complexity describes optimal compression in an absolute sense, but is uncomputable. Closure compression describes optimal compression relative to a structural equivalence — and is both computable and exact. The three theories form a hierarchy: Kolmogorov at the top (absolute but uncomputable), closure in the middle (structural and computable), Shannon at the base (statistical and efficient).

## Why it matters

The practical implications are immediate. Any time you define an equivalence relation on data — "these images look the same to the human eye," "these programs compute the same function," "these DNA sequences code for the same protein" — and find a closure operator respecting that equivalence, the theorems guarantee you've built an optimal compressor. The fixed points tell you exactly which objects are already in their most compact form.

But the deeper significance is conceptual. The framework reframes compression as algebra rather than computation. It replaces the fundamentally negative result of Kolmogorov (you can't compute optimal compression) with a positive program: choose your closure wisely, and optimality follows automatically. The impossibility hasn't disappeared — it's been localized to the choice of closure operator. Within any given closure, everything is clean, decidable, and optimal.

This is how mathematics often progresses: not by solving impossible problems directly, but by finding the right framework that makes the possible parts precise and the impossible parts explicit. The closure-compression duality does exactly that, and in doing so, it opens a new chapter in the ancient story of how we describe the world with fewer symbols than it seems to require.

## What comes next

The framework points toward several frontiers. Can the gap between closure-incompressibility and true Kolmogorov randomness be measured on finite domains? Can the tropical compression operator be generalized to non-commutative settings, capturing the structure of quantum information? Can the fixed-point characterization of incompressibility be connected to phase transitions in random constraint satisfaction — the boundary between compressible and incompressible random structures?

These questions are open, and they span pure mathematics, computer science, and physics. But they are now *precise* questions, grounded in a framework that turns the poetry of "compression as projection" into provable theorems. That's not a small thing. In mathematics, making a vague intuition precise is often the hardest step — and the most rewarding.
