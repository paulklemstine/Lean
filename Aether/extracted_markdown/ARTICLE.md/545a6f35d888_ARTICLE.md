# The Mathematics of Forgetting: How Algebra Reveals the Hidden Structure of Memory

*When we compress a lifetime of experience into a handful of memories, where does the lost information go? A new mathematical framework shows that forgetting follows precise algebraic laws — and connects to a surprising branch of geometry.*

---

## The Paradox of Productive Forgetting

Consider a simple experiment. You read a hundred-digit number, glance away, and try to recall it. You might remember the first few digits, the last few, perhaps a pattern in the middle. The vast majority is gone. But here's what's remarkable: the *way* you forget isn't random. You compress the input according to consistent rules — recency, pattern recognition, emotional salience. Your forgetting has structure.

This isn't just psychology. It's mathematics. A new body of research reveals that the information loss inherent in any finite memory system — biological or digital — obeys precise algebraic laws that mirror the rules of a strange and beautiful branch of mathematics called tropical geometry.

## Memories as Monoid Homomorphisms

The key insight begins with a deceptively simple formalization. Think of your experiences as a stream of symbols: every sight, sound, and sensation is one character in an immensely long word. Your memory is a machine that reads this word and compresses it into a finite set of internal states. Mathematically, this is a *homomorphism* — a structure-preserving map — from the free monoid of experience streams to a finite state monoid.

The free monoid is the mathematical name for "all possible sequences of symbols." It's free because it imposes no constraints: any sequence is valid. The state monoid is finite — your brain (or your computer) has limited capacity. The homomorphism property captures something deep about memory: it means the state after processing "ABC" is the same whether you process it as "A then BC" or "AB then C." Memory is compositional.

This simple setup already yields surprising consequences. Two experience streams that map to the same internal state are, from the memory's perspective, identical. The set of all such identifications forms what algebraists call a *congruence* — a special equivalence relation that respects the monoid structure. The congruence is the mathematical fingerprint of what the memory forgets.

## The Fiber Sum Theorem: Conservation of Information

The first deep result concerns what happens when you compress one memory system into another — when you map states to states in a way that loses information. Think of it as summarizing your memories: the summary preserves some distinctions and erases others.

The **Fiber Sum Theorem** states that information loss is *conservative*. If you have a function mapping a set of states to a smaller set, the "fibers" — the groups of original states that map to the same compressed state — have sizes that sum to exactly the original number of states. Nothing is created; nothing is destroyed. Information is merely redistributed.

This sounds obvious, even trivial. But its implications cascade. It means that in any chain of memory compressions — summarizing a summary of a summary — the total information loss at each step is precisely accounted for. There's no "dark information" that slips through the cracks. Every bit of forgotten data can be traced to a specific fiber of a specific compression step.

## The Tropical Triangle Inequality

The most striking connection emerges when we measure memory capacity using logarithms. If a memory system can distinguish *n* different states, its "tropical capacity" is log *n*. This seemingly arbitrary choice reveals hidden structure.

Consider running two memory systems in parallel — one recording sounds, another recording images. Their combined system can distinguish at most *n*₁ × *n*₂ states (every combination of a sound-state and an image-state). Taking logarithms: log(*n*₁ × *n*₂) = log *n*₁ + log *n*₂. Capacity adds.

But the actual combined capacity might be less — perhaps certain sound-image combinations never occur. The **Cascade Capacity Subadditivity** theorem makes this precise: the capacity of the combined system is at most the sum of individual capacities. In the language of tropical geometry, this is the *tropical triangle inequality*.

Tropical geometry is the mathematics you get when you replace addition with maximum (or minimum) and multiplication with addition. It sounds like a mathematician's joke, but it arises naturally in optimization, phylogenetics, and algebraic geometry. The discovery that memory systems satisfy tropical inequalities suggests that the space of all possible memories has the structure of a *tropical metric space* — a geometric object where distances are measured not by straight lines but by tropical addition.

## Idempotent Stabilization: The End of Forgetting

Perhaps the most philosophically resonant result concerns what happens when you repeat the same experience over and over. If you hear the same song a thousand times, your memory of it eventually stabilizes — further repetitions produce no change.

The **Idempotent Power Existence** theorem proves this mathematically: in any finite state monoid, every element has a power that is *idempotent* — squaring it gives back itself. Applied to memory: for any input symbol, repeating it enough times produces a memory state that is stable under further repetition.

The proof uses the pigeonhole principle in a clever way. Since the monoid is finite, the sequence *s*, *s*², *s*³, ... must eventually repeat: *s*ⁱ = *s*ʲ for some *i* < *j*. This creates a "period" that, when iterated enough times, produces an idempotent element. The precise bound on how many repetitions are needed — the *idempotent power index* — is at most the square of the monoid size.

This connects to a deep theorem in semigroup theory: the Krohn-Rhodes decomposition, which shows that every finite state machine can be decomposed into "atoms" that are either simple groups (reversible transformations) or aperiodic semigroups (irreversible ones). The idempotent power existence theorem is the foundation of this decomposition.

## The Joint Capacity Theorem

When two memory systems observe the same stream of experiences, how much do they collectively remember? The **Joint Capacity Theorem** shows that running two systems in parallel always remembers at least as much as either one alone. This is intuitive — more memory is better — but the proof reveals a subtle geometric structure.

The joint capacity is symmetric: the amount remembered by system A augmented with system B equals the amount remembered by B augmented with A. This symmetry, combined with subadditivity, means that the space of memory systems equipped with joint capacity forms a *tropical semimodule* — an algebraic structure that lives naturally in tropical geometry.

## The Landscape of Forgetting

What emerges from these results is a picture of information loss as a precisely structured mathematical landscape. Every memory system occupies a point in a tropical metric space. Composing systems moves you through this space according to tropical geometry's alien but consistent rules. The fiber sum theorem ensures conservation; the idempotent stabilization theorem ensures convergence; the cascade inequality constrains the geometry.

The implications extend beyond abstract mathematics. In cryptography, one-way functions are precisely memory systems where information loss is computationally irreversible — you can compress but cannot decompress. The tropical framework suggests new ways to analyze the security of cryptographic systems by studying the geometry of their forgetting patterns.

In neuroscience, the framework offers a mathematical language for distinguishing types of memory loss. Alzheimer's disease, for instance, doesn't simply erase memories — it changes the *structure* of forgetting, altering which congruences the brain's memory system imposes. The tropical capacity valuation could, in principle, quantify this structural change.

In artificial intelligence, every neural network is a memory system: it compresses training data into weights. The cascade capacity bound constrains how much information can flow through parallel processing streams. Understanding these constraints in tropical-geometric terms could lead to better architectures.

## What We Still Don't Know

The framework raises as many questions as it answers. Is there a tight bound on the idempotent power index — can we do better than *n*²? Does the tropical metric space of memory systems have finite dimension, and if so, what does the dimension mean? Can we detect the Krohn-Rhodes decomposition of a memory system from its tropical capacity profile alone?

These questions sit at the intersection of algebra, geometry, and information theory — a fertile crossroads where the mathematics of forgetting is only beginning to be explored. The ancient art of memory, it turns out, has a modern geometry. And that geometry is tropical.

---

*The research described here was conducted as part of a systematic investigation into the algebraic structure of information loss in finite-state systems. The results connect classical semigroup theory to tropical geometry through the lens of memory compression.*
