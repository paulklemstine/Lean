# The Algebra of Forgetting: Why Your Brain Is a Lossy Compressor

*How mathematicians proved that perfect memory is impossible — and why that's actually a feature, not a bug*

---

You're reading this sentence. By the time you finish this article, you will have forgotten most of the words you just read — their exact spacing, the way your eyes tracked across the page, the ambient sounds around you. Your brain will compress the experience into something like "I read an article about memory and math." That compression isn't a failure. It's a mathematical inevitability.

A new line of mathematical research reveals that memory — biological, digital, or artificial — obeys rigid algebraic laws. These laws don't just describe how memory works; they constrain what memory *can* do. And the central constraint is both simple and profound: **any finite memory system operating over an infinite stream of experiences must be lossy**. It must forget.

## The Monoid of Experience

To understand why, we need to think about experiences differently. Consider your day as a sequence of moments: waking up, brushing teeth, commuting, working, eating. Each moment is an atomic experience, but the day itself — the *composite* of all those moments — is also an experience. And the empty experience (doing nothing) is an experience too.

This structure has a name in mathematics: a *monoid*. A monoid is any system where you can combine things sequentially, and where there's a "do nothing" element. The integers under addition form a monoid (add zero, nothing changes). Strings of text form a monoid (concatenate them; the empty string changes nothing). And crucially, sequences of experiences form a monoid.

Memory, in this framework, is a *function* from the experience monoid to a state monoid — the set of possible brain states, or hard drive states, or neural network weights. The key insight is that this function must respect the monoid structure. If you experience A, then B, the memory of "A then B" should be derivable from processing A and then processing B. In mathematical language, memory is a **monoid homomorphism**.

This single assumption — that memory respects sequential composition — unlocks a cascade of theorems.

## The Lossy Memory Theorem

The first and most fundamental result is the *Lossy Memory Theorem*. It's almost embarrassingly simple, but its implications are vast.

**Theorem**: If the space of possible experiences is infinite and the space of possible memory states is finite, then there must exist distinct experiences that produce identical memory states.

The proof is the pigeonhole principle wearing algebraic clothing. If you have infinitely many pigeons (experiences) and finitely many holes (memory states), some holes must contain multiple pigeons. Two different life stories, fed through any finite memory system, will inevitably produce the same mental state.

This isn't just about biological brains. It applies to any hash function, any neural network with finite weights, any database with bounded storage. The theorem doesn't say *which* experiences will be conflated — that depends on the specific encoding — but it guarantees that conflation is inevitable.

## The Anatomy of Forgetting

If memory must lose information, what exactly gets lost? The mathematical framework provides a precise answer through the *Kernel Submonoid Theorem*.

The **kernel** of a memory system is the set of all experiences that map to the "neutral" state — experiences so thoroughly forgotten that they leave absolutely no trace. The theorem proves that this set of perfectly-forgotten experiences forms a submonoid: if experience A leaves no trace, and experience B leaves no trace, then "A then B" also leaves no trace.

This might seem obvious, but it has a non-trivial consequence. It means forgetting has algebraic structure. The set of forgotten things isn't some arbitrary garbage heap — it's a *coherent algebraic object* that respects the sequential structure of experience. You can study it, classify it, and make predictions about it using the tools of abstract algebra.

Beyond the kernel, every memory system induces what mathematicians call a **congruence** — an equivalence relation that partitions all possible experiences into classes that "look the same" to memory. Two experiences are congruent if they produce identical memory states. The collection of these congruence classes — the partition of experience space — completely characterizes what the memory system remembers and forgets.

## The Architecture of Selective Forgetting

Perhaps the most surprising result is the *Congruence Refinement Theorem*, which reveals a hidden hierarchy in how memory systems relate to each other.

Say you have two memory systems: a detailed one (like episodic memory, which remembers what you had for breakfast) and a coarse one (like semantic memory, which just knows that you eat breakfast). The detailed system *refines* the coarse one — whenever the detailed system equates two experiences, so does the coarse one, but not vice versa.

The theorem proves that whenever such a refinement relationship exists, there must be a "forgetting map" between the two systems — a function that transforms the detailed state into the coarse state. Moreover, this forgetting map is essentially unique. There's only one way to degrade a detailed memory into a coarse one while maintaining consistency.

This has implications for understanding how different memory systems in the brain might interact. Episodic memory, semantic memory, procedural memory — if they form a refinement hierarchy, then the transformations between them are algebraically constrained. Evolution didn't have infinite freedom in designing how memories degrade from one system to another.

## Irreversibility: The Arrow of Forgetting

Another theorem formalizes an intuition that feels obvious but has deep consequences: **forgetting is irreversible**.

If a memory system is lossy — if it conflates some experiences — then composing it with any further encoding cannot restore the lost distinctions (unless that further encoding is itself injective, but even then, the original loss persists). Once two experiences have been compressed into the same state, no subsequent processing can tell them apart.

This is the algebraic version of the second law of thermodynamics applied to information. Information, once lost, is gone. The proof shows that if the composite system were injective, the first system would have to be injective too — contradicting the assumption that it was lossy.

## Tropical Memory: The Mathematics of Salience

The framework extends naturally to what researchers call *tropical* mathematics — a variant of ordinary algebra where addition is replaced by the "max" operation. In tropical algebra, 3 + 5 = 5 (taking the maximum), and 3 × 5 = 8 (ordinary addition plays the role of multiplication).

Why would this matter for memory? Because the "max" operation is inherently lossy — it discards information about the smaller operand. This makes tropical algebra a natural language for modeling *salience-based* memory, where only the most important or intense version of an experience is retained.

In a tropical memory system, each state carries a "priority" value, and combining two memories retains the higher-priority one. This captures how vivid, emotional, or surprising experiences tend to overwrite mundane ones. The mathematical framework proves that such systems are *idempotent*: remembering something you already remember doesn't change anything. The max of a value with itself is just that value.

This idempotence property distinguishes tropical memory from ordinary memory systems and connects to the mathematical theory of *bands* (idempotent semigroups), opening a bridge to lattice theory and order-theoretic approaches to information.

## Counting What's Left

The final piece of the puzzle is quantitative. The *Image Cardinality Bound* proves that for any finite collection of experiences, the number of *distinguishable* memory traces is bounded by the size of the state space. If your brain has *n* possible states, then any set of experiences can produce at most *n* distinct memories.

Combined with the Lossy Memory Theorem, this gives both a qualitative and quantitative picture: not only must finite memory lose information, but the amount of information it can retain is precisely bounded by the size of its state space.

## Why It Matters

This mathematical framework does more than formalize intuitions about memory. It provides a *language* for asking precise questions about any information-processing system that operates under resource constraints.

How much does a neural network forget during training? The congruence structure tells you. Can two different architectures produce the same forgetting pattern? The refinement theorem constrains the answer. Is there an optimal way to forget — a lossy encoding that preserves the maximum useful information? The tropical memory framework suggests that salience-based forgetting may have special algebraic properties that make it particularly natural.

The deepest insight may be philosophical. We tend to think of forgetting as a deficiency — memory's failure to do its job. But the algebra tells a different story. Forgetting isn't the absence of memory; it's a *structured algebraic operation* with its own laws, its own hierarchy, and its own notion of optimality. Perfect memory isn't just impractical — it's mathematically impossible for any finite system. What's possible, and what evolution and engineering have both converged on, is *structured* forgetting: losing information in algebraically coherent ways that preserve the most important distinctions while inevitably blurring the rest.

Your brain isn't failing when it forgets. It's obeying the algebra.

---

*This research connects to broader investigations in algebraic information theory, tropical mathematics, and the mathematical foundations of artificial intelligence. The algebraic framework for memory was developed as part of ongoing work in applied abstract algebra.*
