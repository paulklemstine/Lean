# The Hidden Grammar of Neural Networks: How Abstract Algebra Reveals Why Some AI Models Can't Be Compressed

## A Pattern Beneath the Patterns

Somewhere inside every neural network—the kind that writes emails, recognizes faces, or predicts stock prices—there is a hidden mathematical structure that determines what it can and cannot learn. For decades, researchers have treated neural architectures mostly as engineering artifacts: wire together enough layers, tune enough knobs, and hope for the best. But a new line of mathematical research is revealing that neural networks have a deep algebraic grammar, and that grammar has consequences—not just for machine learning, but for cryptography, physics, and the foundations of logic itself.

The core insight is deceptively simple: two neural architectures that produce identical outputs on every possible input are, for all practical purposes, the same thing. This "observational equivalence" is not a new idea—computer scientists have used it since the 1960s. But what *is* new is the realization that this equivalence, when viewed through the lens of abstract algebra, gives rise to a powerful minimization theory. Just as a complex English sentence can be parsed into its grammatical skeleton, a complex neural architecture can be reduced to a canonical minimal form—one that captures everything the original could do, but with no redundant parts.

## From Automata to Operads

The story begins with a 76-year-old theorem. In 1957, mathematicians Anil Nerode and John Myhill independently proved that every finite-state machine—think of the logic inside a vending machine or a traffic light controller—has a unique minimal equivalent. Two machines that respond identically to every possible sequence of inputs can be collapsed into a single, smallest machine. The Myhill–Nerode theorem is a cornerstone of theoretical computer science, taught in every undergraduate course on the theory of computation.

But neural networks are not finite-state machines. They are *compositional*: layers stack on top of layers, branches run in parallel, and the whole edifice composes hierarchically, like a tree. The correct algebraic language for this kind of composition is not automata theory but *operad theory*—a branch of abstract algebra that studies how operations with multiple inputs can be composed and substituted into one another.

An operad, in essence, is a catalog of composable operations. Imagine a LEGO instruction manual: each step tells you how to combine smaller assemblies into larger ones. The rules of combination—which pieces plug into which slots, and in what order—form an operad. Neural networks, viewed at the right level of abstraction, are elements of a neural operad: each layer is an operation, and training a network means navigating through the operad to find the right composite.

## The Proof Semiring: Where Logic Meets Algebra

The second key ingredient comes from an unexpected direction: the algebraic study of proofs.

A *semiring* is one of the most basic structures in algebra—a set equipped with addition and multiplication that satisfy familiar rules (think of the integers, but possibly without subtraction). When mathematicians study proof systems—formal logical frameworks for establishing mathematical truth—they can assign semiring elements to proofs: the "sum" of two proofs represents having either one available, and the "product" represents combining proofs sequentially.

This "proof semiring" carries additional structure. A *congruence* on a semiring is a way of declaring certain elements equivalent while preserving the arithmetic. Think of clock arithmetic: on a 12-hour clock, 3 and 15 are "the same" because their difference is a multiple of 12. A *prime* congruence is one that cannot be decomposed further—it represents an irreducible way of identifying elements.

The breakthrough is to use these prime congruences as *semantic probes* for neural architectures. Given a neural architecture and a prime congruence, we can evaluate the architecture's "semantic theory"—the set of proof terms it identifies with zero, the set of behaviors it considers trivial. Two architectures are "prime-observationally equivalent" when no prime congruence can tell them apart.

## The Minimization Theorem

This is where the magic happens. Prime observational equivalence turns out to be:

1. **An equivalence relation**: every architecture is equivalent to itself; equivalence is symmetric and transitive.
2. **A congruence for composition**: if you replace equivalent subcomponents within a larger architecture, the result is still equivalent.
3. **Compatible with a complexity measure**: among all architectures equivalent to a given one, there is a canonical *minimal* representative—one with the smallest "compression score."

The compression score combines three dimensions: depth (how many sequential steps), width (how many parallel branches), and generator count (how many distinct computational units). The minimization theorem says: given any finite pool of candidate architectures, there exists one with the smallest compression score that is semantically indistinguishable from the target. This is the neural analogue of the Myhill–Nerode theorem.

## Why Compression Has Limits

Perhaps the most striking consequence is a family of *lower bounds*. If you have a collection of architectures that are pairwise distinguishable—meaning for every pair, there exists some prime congruence that separates them—then the total compression score across the family must be at least as large as the family size. You cannot compress everything simultaneously without losing distinctions.

This is not just an abstract curiosity. It has direct implications for neural architecture search—the process by which researchers automatically discover efficient network designs. The lower bound says: if you want your search space to contain *n* genuinely different architectures, you need a total resource budget of at least *n*. No clever compression trick can evade this bound.

## Fingerprints for Networks

The prime congruences also give rise to a kind of "semantic fingerprint" for each architecture. Map each architecture to the function that assigns, to each prime congruence, its semantic theory. The separation theorem guarantees that this fingerprint is *injective*: distinct (non-equivalent) architectures get distinct fingerprints.

In cryptography, this has a natural interpretation. A hash function maps data to short fingerprints; a good hash function is collision-resistant—distinct inputs should yield distinct outputs. The semantic fingerprint of a neural architecture is a kind of "algebraic hash," and the prime separation lemma is a collision-resistance guarantee. In a post-quantum world, where traditional hash functions may be vulnerable to quantum attacks, algebraic constructions like these offer a fundamentally different approach to establishing security.

## The Thermodynamic Connection

There is an intriguing parallel with physics. The "compression gap"—the difference between total compression score and sequential depth—measures something like the thermodynamic cost of parallelism. Just as a physical system cannot process information without generating entropy, a neural architecture cannot exploit parallel computation without incurring a measurable overhead.

The compression gap decomposes the total score into two components: sequential depth (analogous to work in thermodynamics) and the gap itself (analogous to dissipated heat). The exact decomposition theorem says these always add up to the total score—there is no free lunch. This connection between self-reference, compression, and entropy is not yet fully understood, but it suggests deep links between the theory of computation and the physics of information.

## Looking Forward

This mathematical framework is still in its early stages, but the implications are far-reaching. The minimization theory could lead to principled methods for neural architecture search—replacing trial-and-error with algebraic analysis. The fingerprinting construction could inform new approaches to cryptographic hashing. And the compression lower bounds could provide rigorous foundations for understanding why some problems genuinely require large, complex models.

More speculatively, the connection between operadic composition and proof semirings opens a door to understanding neural networks as *formal reasoning systems*. If a neural architecture can be characterized by which logical theories it validates, then training a network is, in a precise sense, searching for the right logical axioms. The Myhill–Nerode minimization theorem then says: among all axiom systems that generate the same theorems, there is a unique simplest one.

We are used to thinking of neural networks as inscrutable black boxes. This work suggests they have a hidden grammar—one written in the language of algebra, logic, and physics. Reading that grammar may be the key to understanding not just how neural networks work, but what they fundamentally are.
