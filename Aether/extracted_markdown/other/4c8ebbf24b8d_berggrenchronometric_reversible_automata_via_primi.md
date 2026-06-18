# When Ancient Triangles Meet Reversible Computers

## A hidden bridge between Pythagorean triples and the future of computation

Five thousand years ago, Babylonian scribes pressed cuneiform wedges into clay tablets, recording lists of numbers with a peculiar property: 3, 4, 5. Then 5, 12, 13. Then 8, 15, 17. Each triple satisfied the same mysterious relationship — the sum of the squares of the two smaller numbers equaled the square of the largest. These were the primitive Pythagorean triples, and the scribes who catalogued them could never have guessed that their numerical curiosities would one day illuminate the deepest questions in computer science.

## The Infinite Family Tree

In 1934, the Swedish mathematician Berggren discovered something remarkable. Every primitive Pythagorean triple — every set of three whole numbers (a, b, c) with no common factors where a² + b² = c² — could be generated from a single ancestor. The triple (3, 4, 5), the simplest of them all, sits at the root of an infinite ternary tree. Apply one of three specific matrix transformations (call them A, B, and C), and you get a new triple. Apply them to that triple, and you get three more. The process never terminates, it never repeats, and it produces every primitive Pythagorean triple exactly once.

This is not merely an organizing principle. It is a *generative grammar* for an infinite mathematical language. Each triple has an address — a word like "ABCA" or "BCAB" — that tells you exactly which sequence of transformations to apply to reach it from the root. The entire infinite family of Pythagorean triples collapses into a dictionary of three-letter words.

## Reversibility: The Physics of Undoing

Now consider a very different question: what does it cost to erase information?

In 1961, the physicist Rolf Landauer proved a startling result. Every time a computer erases a bit of information — every time an irreversible operation is performed — a minimum amount of energy must be dissipated as heat. This is not an engineering limitation. It is a law of physics, as fundamental as the second law of thermodynamics.

The implication was profound: if you could build a computer where every operation was *reversible* — where every step could be undone — you could, in principle, compute without any energy cost at all. Reversible computation became not just a theoretical curiosity but a design principle for future computing architectures, from quantum computers to ultra-low-power processors.

But reversible computers present a challenge. In a conventional computer, you can freely merge computational paths — two different inputs can produce the same output. In a reversible computer, every operation must be a bijection: different inputs must always produce different outputs. This constraint fundamentally changes what automata — the abstract machines at the heart of computation theory — look like.

## The Unexpected Connection

Here is where Babylonian number theory meets twenty-first-century computation.

The Berggren tree's three generators A, B, C form an alphabet. Words in this alphabet are programs. And because each generator is an invertible matrix, the Berggren tree naturally gives rise to a *reversible automaton* — a computational machine where every step can be undone.

But this automaton has additional structure that ordinary reversible computers lack. Each word carries a *chronometric length* — a weighted measure of computational cost where different generators have different weights. This length is additive: if you concatenate two programs, their costs add up. And crucially, it is invariant under time reversal — running a computation backward costs exactly the same as running it forward.

This is not obvious. Time-reversal invariance of cost is a deep physical principle. In relativistic physics, the proper time along a worldline is the same whether you traverse it forward or backward. The fact that the Berggren tree's chronometric length has this same symmetry is a mathematical echo of physical law.

## The Myhill-Nerode Principle: Minimal Machines

In the 1950s, John Myhill and Anil Nerode proved a fundamental theorem about automata. Given any language (any set of acceptable words), there is a unique minimal machine that recognizes it. This minimal machine is obtained by identifying words that are *indistinguishable by future behavior* — words that, no matter what suffix you append, produce the same result.

We have formalized a chronometric version of this principle for Berggren orbit automata. Two words are *causally congruent* if they produce identical behavior for all possible future extensions. This causal congruence is an equivalence relation — it partitions words into classes — and any reversible automaton that respects this congruence factors through the quotient.

The key theorem is a minimality result: if an automaton can distinguish all causally non-congruent words, then the quotient by causal congruence injects into the automaton's state space. This provides a *lower bound* on the number of states any such automaton needs — a complexity measure with direct implications for the resources required to implement reversible arithmetic.

## Entropy and the Arrow of Computation

Every node in the Berggren tree branches into exactly three children. This means the number of possible n-step extensions from any position is 3ⁿ — an exponential explosion of possibilities. This quantity, which we call the *causal entropy*, is monotonically non-decreasing as the horizon grows. Longer observation windows never decrease your ability to distinguish computational paths.

But if you add a physical constraint — forbidding immediate backtracking, so no step can be immediately followed by the same step — the branching drops. After the first step (3 choices), each subsequent step offers only 2 choices, giving at most 3 × 2ⁿ⁻¹ extensions. This non-backtracking entropy is strictly less than the full branching, yet still exponential.

The relationship between these two entropy measures captures something essential about the thermodynamics of computation. Full branching represents unrestricted computation; non-backtracking branching represents physically admissible computation. The gap between them is a measure of the computational cost of physical constraints.

## The Separation Principle: What Reversibility Remembers

Perhaps the most surprising result is a *separation theorem*. We can demonstrate that there exist pairs of words that are indistinguishable to an irreversible observer — they produce the same output — but distinguishable to a reversible one. The reversible observer, by examining how the words interact with future extensions, can tell them apart even though their immediate outputs are identical.

The concrete witnesses are the words [A, B] and [B, A]. Both have zero adjacent repeated steps (our test observable). But append the suffix [A], and they diverge: [A, B, A] still has no repetitions, while [B, A, A] has one. The irreversible observer sees only the current state; the reversible observer sees the entire causal history.

This is a mathematical formalization of Landauer's principle in miniature. Irreversible computation destroys information — it collapses distinct histories into identical states. Reversible computation preserves information, maintaining distinctions that would otherwise be lost. The separation theorem proves this is not merely a vague analogy but a precise mathematical fact.

## Security in a Post-Quantum World

These results have unexpected implications for cryptography. Modern encryption increasingly relies on *lattice-based* problems — mathematical puzzles whose difficulty provides security guarantees even against quantum computers. The Berggren tree, with its lattice-like structure and explicit cost metrics, provides a natural testing ground for post-quantum security analysis.

The chronometric length of a Berggren word serves as a security parameter: longer words (higher cost) correspond to harder problems. The additivity of this cost under composition means security is *composable* — chaining operations sums their costs. And the time-reversal invariance means an attacker gains no advantage from running computations backward.

These are not just abstract observations. The explicit bounds — depth ≤ chronometric length ≤ 2 × depth — provide concrete security margins. The exponential growth of causal entropy provides explicit lower bounds on brute-force search costs. The separation theorem guarantees that reversible implementations are strictly more informative than irreversible ones.

## A Bridge Between Worlds

What makes this work unusual is not any single result but the *bridge* it builds. Number theory (Pythagorean triples), automata theory (Myhill-Nerode minimization), thermodynamics (Landauer's principle), and cryptography (post-quantum security) are typically studied as separate disciplines. The Berggren tree reveals them as different views of the same underlying structure.

The tree's generators give an alphabet. The alphabet gives words. The words give programs. The programs run on reversible automata. The automata have entropy. The entropy has bounds. The bounds have security implications. Each step in this chain connects two fields that seemed unrelated.

This is how mathematics advances — not just by proving theorems within a discipline, but by discovering that different disciplines are speaking the same language. The Babylonian scribes who catalogued Pythagorean triples were, without knowing it, writing the first programs for a reversible computer that would not be conceived for five millennia. The bridge between their clay tablets and tomorrow's quantum-resistant cryptography runs through the branches of the Berggren tree.
