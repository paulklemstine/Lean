# When Forgetting Is a Mathematical Operation

## The Hidden Algebra of Memory

Every living creature forgets. From the fruit fly that cannot recall which sugar trail it followed yesterday, to the human who blanks on a childhood friend's name, forgetting seems like failure—a bug in the biological machinery of remembrance. But what if forgetting is not a bug at all? What if it is a feature, governed by precise mathematical laws as rigid as the rules of arithmetic?

A new line of mathematical research reveals that forgetting is not merely the passive decay of information. It is an *operation*—a structured transformation that obeys algebraic rules, forms mathematical patterns, and can be composed, reversed, and optimized just like any other mathematical function. The mathematics of forgetting turns out to be surprisingly rich, connecting ideas from abstract algebra, information theory, and computer science in ways that illuminate both artificial intelligence and the biology of memory.

## The Stream and the Squeeze

Imagine your life as a long sequence of experiences: the taste of your morning coffee, the sound of rain on the window, a conversation with a friend, the color of the sunset. Mathematicians call this sequence a *stream*—an ever-growing list of sensory events drawn from some alphabet of possible experiences.

Now imagine your brain (or a computer's memory) trying to store this stream. The catch: your brain has finite capacity. It cannot store every experience verbatim. Instead, it must compress the stream into some internal representation—a *state*—that captures as much useful information as possible in limited space.

This compression process is what mathematicians call a *monoid homomorphism*. The word sounds forbidding, but the idea is simple: the compression must be *consistent*. If you compress experience A followed by experience B, you should get the same result as compressing A, then separately compressing B, and combining the compressed versions. In other words, the compression respects the structure of sequential experience. It doesn't matter whether you process the morning and afternoon as one block or two—the final memory state should be the same.

This consistency requirement is not just a mathematical nicety. It reflects a deep truth about how memory must work in any system—biological or artificial—that processes experiences sequentially and maintains a coherent internal state.

## The Pigeonhole of Forgetting

With this framework in place, a remarkable theorem emerges, one that is almost embarrassingly simple yet profoundly consequential: **any consistent compression of an infinite experience stream into a finite state space must lose information.**

The proof uses the pigeonhole principle, one of the oldest and most intuitive ideas in mathematics. If you have more pigeons than pigeonholes, at least two pigeons must share a hole. Similarly, if there are infinitely many possible experience streams but only finitely many memory states, then at least two different streams must be mapped to the same state. The memory system literally cannot tell them apart. Information is lost. Forgetting is inevitable.

But the theorem goes further. It doesn't just say that *some* information is lost—it quantifies *when* collisions begin. If your memory has *n* possible states, then among all experience streams of length greater than *n*, there must exist at least two that are indistinguishable. The pigeonhole bites at exactly the point where the stream length exceeds memory capacity.

This is not a statement about any particular memory system. It applies to *every* consistent compression scheme: neural networks, databases, human brains, alien intelligences. If the compression is consistent and the memory is finite, forgetting is a mathematical certainty.

## The Algebra of What's Forgotten

If forgetting is inevitable, the next question is: what structure does it have? The answer reveals something beautiful.

The set of experience streams that a memory system *forgets*—those it maps to the identity state, treating them as if nothing happened—forms a mathematical structure called a *submonoid*. This means:

1. **The empty experience is always forgotten.** Doing nothing is always invisible to memory. (Trivially true, but the mathematics demands it.)

2. **Concatenating forgotten experiences yields a forgotten experience.** If stream A is invisible and stream B is invisible, then stream A followed by stream B is also invisible.

This is more than a curiosity. It means the set of forgotten experiences is *closed under composition*. You can stack invisible experiences indefinitely and the memory system will never notice. The invisible experiences form their own self-contained algebraic world.

Moreover, the full kernel of the memory map—the set of all pairs of streams that are confused with each other—forms a *congruence*, a special kind of equivalence relation that respects the sequential structure of experience. This congruence is compatible with concatenation from both the left and the right: if two streams are indistinguishable, prepending or appending any common experience preserves the confusion.

## Targeted Forgetting as Quotient

Perhaps the most surprising result concerns *targeted forgetting*—the deliberate decision to forget specific information. In the mathematical framework, targeted forgetting corresponds to choosing a *forgetting policy*: a set of stream pairs that you decide should be treated as equivalent, beyond what the memory already confuses.

The mathematics shows that any valid forgetting policy must itself be a congruence—an equivalence relation compatible with the monoid structure. And applying a forgetting policy is equivalent to taking a *quotient*: you collapse the memory system's state space by identifying additional states, producing a coarser but still consistent memory system.

This quotient construction has a remarkable property: **composing memory systems with quotients forms a category.** You can chain multiple rounds of forgetting, and each round produces a valid memory system that factors through the previous one. Forgetting is composable, reversible in structure (though not in practice), and categorically well-behaved.

## The Composition Theorem

When you compose a memory system with an additional compression step—a second homomorphism that further squeezes the state space—two things happen:

First, **no previously lost information is recovered.** Any streams that were already indistinguishable remain so. Composition can only increase confusion, never decrease it.

Second, **if the additional compression is lossy, new confusion is guaranteed.** Specifically, if the second compression is non-injective and the first memory system is surjective, then there exist streams that were distinguishable before the composition but become confused afterward. The composition strictly increases information loss.

This composition theorem captures a fundamental asymmetry: information, once lost through compression, cannot be recovered by further processing. Each additional layer of compression adds its own irreversible forgetting on top of whatever was already lost.

## Implications for Artificial Intelligence

These results have immediate implications for the design of artificial intelligence systems. Modern neural networks, language models, and reinforcement learning agents all maintain internal states of fixed size while processing potentially infinite input streams. The lossiness theorem guarantees that *every* such system forgets—the only question is *what* it forgets and *how gracefully*.

The submonoid structure of invisible experiences suggests a design principle: rather than treating forgetting as a deficiency to be minimized, engineers should design forgetting policies that produce algebraically well-structured loss patterns. A good forgetting policy is not one that forgets as little as possible, but one whose forgotten set has clean algebraic properties—making it possible to reason about, predict, and control what information is retained.

The quotient construction offers a concrete mechanism for implementing *selective attention*: by choosing which experiences to identify, a system can dynamically adjust its memory granularity, trading off detail for capacity in a mathematically principled way.

## A New Lens on an Old Problem

The mathematics of forgetting reveals that memory loss is not chaos—it is structure. Every finite memory system generates a precise algebraic signature: a congruence on the free monoid of experiences, a submonoid of invisible streams, and a tower of quotients corresponding to successive rounds of forgetting.

This algebraic perspective unifies phenomena that seem disparate: the inevitable information loss in data compression, the selective attention of biological organisms, the catastrophic forgetting of neural networks, and the garbage collection of computer systems. They are all instances of the same mathematical operation—a monoid homomorphism hitting the finite walls of its codomain, and the resulting quotient structure that emerges.

Forgetting, it turns out, is not the enemy of understanding. It is one of its most fundamental tools—a mathematical operation as natural and necessary as addition itself.
