# The Algebra of Forgetting: How Mathematics Reveals Why Perfect Memory Is Impossible

*When mathematicians turned their attention to the structure of memory itself, they discovered that forgetting isn't a bug — it's a theorem.*

---

## The Paradox of the Perfect Diary

Imagine keeping a perfect diary. Every sensory experience, every thought, every heartbeat — recorded with absolute fidelity. After a single day, you'd have a stream of data so vast that no physical storage could contain it. After a year, you'd need more atoms than exist in the observable universe just to index it.

This isn't a practical engineering limitation. It's a mathematical certainty.

In a recent line of research exploring the algebraic foundations of compression and memory, mathematicians have formalized a startling result: **any system that compresses an infinite stream of experiences into a finite set of states must lose information**. Moreover, the *structure* of what gets lost isn't random — it follows precise algebraic laws that connect to some of the deepest ideas in mathematics.

The story begins with a simple question: What, exactly, *is* a memory?

## Memory as a Machine

Strip away the neuroscience, the psychology, the philosophy. At its mathematical core, a memory system does one thing: it takes a sequence of inputs and produces a state. Your brain takes a lifetime of experiences and produces your current mental state. A thermostat takes a sequence of temperature readings and produces a setting. A hash function takes a file and produces a fingerprint.

Mathematicians call this a **monoid homomorphism** — a function that respects the sequential structure of experience. If you experience event A followed by event B, the memory of "A then B" should relate systematically to the memories of A and B individually. This isn't an assumption about biology; it's the minimum requirement for a memory system to be *coherent*.

The set of all possible experience sequences forms what algebraists call a **free monoid** — essentially, all possible words you could spell with a given alphabet, including the empty word. It's infinite even with just two symbols: {a, b, aa, ab, ba, bb, aaa, ...}. The state space, by contrast, is finite — your brain has finitely many neurons, your computer has finitely many bits.

## The Compression Theorem

Here's the first profound result: **no finite memory system can be lossless**. If your alphabet has at least two symbols, the free monoid is infinite, the state space is finite, and by the pigeonhole principle, some distinct experiences must map to the same state.

This might seem obvious — of course a finite system can't store infinite information. But the theorem goes deeper. It says that the *structure* of the information loss is not arbitrary. It forms what mathematicians call a **congruence**: a special kind of equivalence relation that respects the sequential structure.

What does this mean? If your memory can't distinguish between experience sequences X and Y (because they map to the same state), then it also can't distinguish between XZ and YZ, or between ZX and ZY, for *any* continuation Z. Forgetting propagates forward and backward through time.

This is the algebraic version of a psychological truth: once you've lost a memory, you can't recover it by adding more experiences. The algebraic structure of forgetting is *sticky*.

## The Cascade Product: Parallel Memories

What happens when you run two memory systems in parallel? Imagine wearing both a fitness tracker and a mood journal. Together, they remember more than either one alone — the tracker records your steps while the journal records your feelings.

Mathematically, this is the **cascade product**: if system φ₁ has states S and system φ₂ has states T, the cascade φ₁ × φ₂ has states S × T and records both simultaneously. The research proves three key properties:

**Universality**: The cascade product is the *coarsest* memory system that remembers everything both components remember. It's not ad hoc — it's the canonical mathematical construction.

**Tropical subadditivity**: The capacity of the cascade is at most the product of the individual capacities: |image(φ₁ × φ₂)| ≤ |image(φ₁)| × |image(φ₂)|. Taking logarithms, this becomes an *additive* bound: log(capacity₁₂) ≤ log(capacity₁) + log(capacity₂). This is where tropical algebra enters — the logarithmic transform converts multiplicative bounds into the additive structure of the tropical semiring.

**Lower bound**: The cascade always remembers at least as much as either component: |image(φ₁)| ≤ |image(φ₁ × φ₂)|.

## The Tropical Connection

Why "tropical"? The tropical semiring replaces ordinary addition with maximum and ordinary multiplication with addition. This seemingly strange algebraic structure appears naturally in optimization, phylogenetics, and — it turns out — in the theory of memory.

The key insight is that memory capacity behaves *tropically*. When you compose memory systems — one processing the output of another — the resulting information loss is *monotonically non-decreasing*. In tropical terms, the "cost of forgetting" satisfies a subadditivity law analogous to the triangle inequality.

The researchers proved a **tropical monotonicity theorem**: if you post-process a memory system's output through any additional function, the number of distinguishable states can only decrease. The quantity log|image(φ)| — a tropical valuation on memory systems — is monotone under composition.

This connects to a beautiful duality: the number of distinguishable states equals the number of congruence classes. The congruence captures exactly the same information as the image, viewed from the opposite direction. States tell you what you *remember*; congruence classes tell you what you've *forgotten*. They're two faces of the same algebraic coin.

## The Memory Spectrum

One of the novel contributions of this research is the **memory spectrum** — a sequence that reveals how quickly a memory system explores its state space.

For a memory system with state space S, define spectrum(k) as the number of distinct states reachable by experience sequences of length at most k. This sequence starts at spectrum(0) = 1 (only the "blank slate" state at depth zero) and grows monotonically until it stabilizes at the total number of reachable states.

The rate of growth of the spectrum captures something fundamental: how quickly does the system "saturate"? A memory system that reaches all its states quickly is efficiently using its capacity. One that takes many steps is, in some sense, wasting potential.

The spectrum is bounded above by |S| at every depth, and it must eventually stabilize since S is finite. The stabilization depth — how long it takes to reach every achievable state — is a tropical invariant: it represents the "diameter" of the memory system in a tropical-geometric sense.

## Idempotent Stabilization

Perhaps the most beautiful result connects memory to a fundamental property of finite algebraic structures: **idempotent stabilization**.

Consider a single input symbol — say, the letter 'a'. Feed it into a memory system repeatedly: a, aa, aaa, aaaa, ... What happens to the memory state? Since the state space is finite, the sequence of states must eventually cycle. But the theorem proves something stronger: the sequence eventually reaches an **idempotent** — a state that, when "applied to itself," gives back itself.

Concretely: there exists some depth n such that processing 2n copies of 'a' produces the same state as processing n copies. The memory reaches a fixed point: additional repetition has no further effect.

This is the algebraic version of habituation — the psychological phenomenon where repeated exposure to a stimulus decreases the response. Mathematics says it's not just common; it's *inevitable* in any finite memory system.

## What Forgetting Teaches Us

The deepest lesson of this research isn't about what memory systems can do — it's about the inevitability and structure of what they *can't* do.

Information loss in memory isn't random degradation. It's a structured, algebraic operation governed by congruences. These congruences form a lattice — a mathematical structure where you can take meets and joins — and this lattice encodes all possible "forgetting strategies" for a given memory system.

The trivial memory (total amnesia) sits at the top of this lattice; perfect memory (the identity congruence) sits at the bottom. Every real memory system lives somewhere in between, and the lattice structure tells you exactly which systems can be refined into which others.

The connection to tropical algebra suggests that this lattice has the structure of a tropical variety — a geometric object where the usual notions of distance and dimension are replaced by their tropical counterparts. This is still partly conjectural, but if true, it would mean that the space of all possible memory strategies has a rich geometric structure waiting to be explored.

## The Road Ahead

Several tantalizing questions remain open. Can every memory system be decomposed into "irreducible" components — a kind of prime factorization for forgetting? (This would be the memory-theoretic version of the Krohn-Rhodes decomposition theorem from automata theory.) Does the memory spectrum always stabilize by depth |S| - 1, or can it take longer? And what happens when the state space itself is allowed to grow — when memory can dynamically allocate new states?

These questions sit at the intersection of algebra, information theory, and theoretical computer science. Their answers could illuminate not just the mathematics of memory, but the fundamental limits of any system — biological, digital, or quantum — that must compress an infinite world into a finite representation.

Because in the end, the mathematics tells us something both humbling and liberating: **forgetting is not a failure of memory. It is a mathematical necessity that gives memory its structure, its meaning, and its power.**

---

*The research described in this article develops the algebraic theory of memory compression, connecting monoid homomorphisms, congruence lattices, and tropical valuations into a unified framework for understanding information loss.*
