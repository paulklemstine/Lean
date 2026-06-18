# The Secret Geometry of Secrets: How Closure Systems Crack the Code of Cryptographic Sharing

## A surprising connection between abstract geometry and the mathematics of trust

Imagine you run a bank vault that requires three out of five executives to open. No single executive—and no pair—should be able to access the vault alone. But any three of them, working together, can unlock it. This is the essence of *secret sharing*, one of the foundational ideas in modern cryptography.

Since Adi Shamir and George Blakley independently invented secret-sharing schemes in 1979, cryptographers have built an elaborate theory of who can access what. The mathematics of *access structures*—the formal rules governing which groups of participants can reconstruct a secret—has grown into a rich field connecting algebra, combinatorics, and information theory.

But a new mathematical framework reveals something unexpected: the rules governing secret sharing are not just rules. They are *geometry*.

## The Language of Closure

To understand this connection, we need a concept from pure mathematics: the *closure operator*. Think of it as a mathematical version of "filling in the gaps."

Consider a set of points in space. Their *closure* includes every point that is somehow "generated" or "implied" by the original set. In linear algebra, the closure of a set of vectors is their span—every linear combination you can form. In topology, the closure of a set includes all its limit points. In logic, the closure of a set of axioms includes every theorem you can derive.

Closure operators are everywhere in mathematics, and they all satisfy three elegant properties: they are *extensive* (the closure always contains the original set), *monotone* (bigger sets have bigger closures), and *idempotent* (closing an already-closed set changes nothing). These three axioms define what mathematicians call a *Moore family* or *closure system*.

Now here is the key insight: secret sharing has a hidden closure structure.

## When Groups Become Geometric

Consider our bank vault again. The five executives are points. The "closure" of a group of executives represents all the information that group can collectively access. When three or more executives come together, their collective information "closes up" to include the secret—it spans the entire information space. But any two executives, no matter which two, generate a closure that falls short.

This geometric picture turns authorization into a threshold phenomenon. Attach a numerical *capacity* to each closed set—a measure of how much information it contains. A group is authorized precisely when the capacity of its closure crosses a threshold.

The mathematical framework makes this precise. A *closure-capacity system* consists of four ingredients:
- A finite set of participants
- A closure operator describing how information propagates
- A capacity function measuring information content
- A threshold value separating authorized from unauthorized groups

The capacity function must satisfy two natural conditions: it is *monotone* (more participants means at least as much information) and *closure-invariant* (the capacity depends only on the closure, not on which particular subset generated it). These conditions are not arbitrary requirements—they capture the physical reality that information cannot decrease when you add participants, and that the information content is determined by what can be collectively computed.

## The Three Theorems

This framework yields three fundamental results that together form a complete dictionary between closure geometry and cryptographic authorization.

**The first theorem** establishes that the authorized family—the collection of all groups that can reconstruct the secret—is automatically *upward-closed*. If a group can access the secret, then any larger group containing it can too. This is not assumed; it follows mathematically from the monotonicity of closure and capacity. The proof is beautifully simple: if Group A is authorized and Group B contains Group A, then the closure of B contains the closure of A (by monotonicity of closure), so the capacity of B's closure is at least that of A's closure (by monotonicity of capacity), which is at least the threshold (because A is authorized).

**The second theorem** characterizes the *minimal* authorized groups—those where removing any single participant drops the group below the threshold. These turn out to be precisely the *closure bases*: irredundant generating sets for their closures. A minimal authorized group is one where every participant is essential, not because of some ad hoc minimality condition, but because removing any participant changes the geometry. The closure shrinks, the capacity drops, and authorization is lost.

This is a genuinely geometric characterization. In linear algebra, a basis is a minimal spanning set—remove any vector and you lose some dimension. In our cryptographic setting, a minimal authorized set is a "basis" in exactly the same sense: remove any participant and you lose some essential information.

**The third theorem** is the reconstruction theorem. Given any closure-capacity system, one can extract a *certified reconstruction object*—a compact data structure that correctly determines, for every possible coalition, whether that coalition is authorized. This reconstruction data is provably correct: it agrees with the original closure-capacity authorization on every single coalition.

## The Realization Surprise

These three theorems tell us that closure-capacity systems produce access structures. But does the converse hold? Can every access structure be realized by some closure-capacity system?

The answer is yes, and the proof is constructive. Given any upward-closed family of authorized sets (with finitely many minimal elements), one can build a closure operator and a capacity function whose threshold authorization recovers exactly the original family. The construction is elegant in its simplicity: use the identity as the closure operator, and define the capacity of a set to be "authorized" or "not authorized"—a boolean-valued capacity with threshold "true."

This might seem like cheating—the identity closure is trivial! But that is precisely the point. The theorem says that *every* access structure has at least one closure-capacity realization. The interesting question is not existence but quality: which closure operators give the most efficient, most structured, most information-theoretically optimal realizations?

## The Submodularity Connection

This question leads to a deeper layer of the theory. When the capacity function satisfies *submodularity*—the information-theoretic analogue of diminishing returns—the geometry becomes much richer.

A submodular capacity satisfies an inequality reminiscent of the inclusion-exclusion principle: the capacity of the union plus the capacity of the intersection is at most the sum of the individual capacities. This is exactly the condition satisfied by Shannon entropy, by matroid rank functions, and by many other natural measures of "information content."

Under submodularity, an exchange theorem emerges. If two groups are individually unauthorized but their union is authorized, then their individual capacities must together fall strictly below twice the threshold. This quantitative constraint limits how "close to authorized" two complementary groups can independently be. It is a combinatorial shadow of the fact that information has diminishing returns: the whole is less than the sum of its parts.

## Why This Matters

The closure-capacity framework matters for three reasons that reach far beyond the specific theorems.

First, it provides a *semantic* foundation for secret sharing. Traditional treatments define access structures axiomatically—authorized sets are whatever we say they are. The closure-capacity approach gives authorization a *meaning*: a group is authorized because it generates enough geometric structure to cross an information threshold. This semantic grounding opens the door to automatic synthesis of secret-sharing schemes from logical specifications. Instead of designing a scheme and checking that it has the right access structure, one could specify the desired information-flow properties and automatically derive the scheme.

Second, the framework connects secret sharing to a vast mathematical landscape. Closure operators appear in lattice theory, universal algebra, formal concept analysis, and topology. Capacity functions appear in game theory, combinatorial optimization, and information theory. By placing secret sharing at the intersection of these fields, the closure-capacity framework enables transfer of techniques in both directions. Results about closure lattices can inform cryptographic constructions; cryptographic requirements can motivate new theorems about closure systems.

Third, the reconstruction theorem has computational implications. The certified reconstruction object is not just a theoretical existence result—it is a concrete data structure that can be computed and verified. In a world increasingly concerned with verified computation and zero-knowledge proofs, having machine-checkable certificates of cryptographic correctness is not a luxury but a necessity.

## The View from Here

Mathematics often progresses by discovering that two seemingly unrelated structures are secretly the same. Number theory and geometry were unified by algebraic geometry. Logic and topology were connected by topos theory. Probability and measure theory were married by Kolmogorov's axioms.

The closure-capacity framework suggests a similar unification: that the combinatorics of secret sharing and the geometry of closure systems are two views of a single mathematical reality. Every access structure is a closure phenomenon. Every closure system, equipped with a capacity, defines a natural notion of authorization.

This is not the end of a story but the beginning. The framework points toward tropical algebraic models of secret sharing, where reconstruction becomes a problem in min-plus linear algebra. It suggests connections to circuit complexity, where the structure of minimal authorized sets controls the cost of computing access predicates. And it opens a path toward quantum generalizations, where closure operators on Hilbert subspaces and von Neumann entropy capacities might unify classical and quantum secret sharing.

The vault with five executives was always, secretly, a geometric object. The mathematics is just now catching up.
