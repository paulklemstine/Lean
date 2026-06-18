# The Simplest Impossible Problem: Why Nobody Can Prove 3n+1

*A number game that stumps the world's best mathematicians — and might be impossible to solve*

---

Pick any positive whole number. If it's even, cut it in half. If it's odd, triple it and add one. Now repeat. Try it with 7:

7 → 22 → 11 → 34 → 17 → 52 → 26 → 13 → 40 → 20 → 10 → 5 → 16 → 8 → 4 → 2 → 1.

Sixteen steps, and we land on 1. Try 27: the orbit soars to 9,232 before crashing back down, taking 111 steps to reach 1. Try any number you like. Every single one, as far as anyone has checked — and computers have checked every number up to 2⁶⁸, roughly 295 quintillion — eventually reaches 1.

This is the Collatz conjecture, named after the German mathematician Lothar Collatz who first posed it in 1937. It is the simplest unsolved problem in mathematics. The legendary Paul Erdős once said, "Mathematics is not yet ready for such problems."

But what if mathematics will *never* be ready? What if the Collatz conjecture isn't just unproven, but *unprovable*?

## The Orbit and Its Secrets

To understand why the Collatz problem is so devilishly hard, you need to see what happens inside an orbit. When the number is odd, we multiply by 3 and add 1 — an explosive expansion. When it's even, we divide by 2 — a gentle contraction. The drama of a Collatz orbit is the war between expansion and contraction.

Consider the number 871. Its orbit climbs to nearly 191,000 before collapsing to 1 after 178 steps. During those 178 steps, exactly 65 are "odd steps" (expansions) and 113 are "even steps" (contractions). The ratio of odd to even steps — what mathematicians call the *odd density* — is about 0.365.

This ratio is not random. Across millions of starting values, the odd density clusters around a specific value: roughly 0.37. This is no coincidence. It reflects a deep constraint: for an orbit to eventually converge to 1, the contracting force of repeated halving must overwhelm the expanding force of tripling. Mathematically, this requires the odd density to stay below a critical threshold related to log₂(3) ≈ 1.585 — specifically, below about 0.631.

Every orbit ever computed respects this constraint. But proving it *must always* hold is another matter entirely.

## The Diophantine Barrier

Here is where the problem takes a dark turn. Suppose, contrary to the conjecture, that some number enters a cycle — an endless loop that never reaches 1. What would such a cycle look like?

If a cycle has *k* total steps, and *s* of those steps are odd (expansive), then the net effect of the cycle must be zero: the orbit returns exactly to its starting value. This means the total expansion (roughly 3^s) must equal the total contraction (roughly 2^(k-s)). In precise terms, the cycle's existence requires solving the equation:

**2^(k−s) ≈ 3^s**

This is an *exponential Diophantine equation* — an equation asking when powers of 2 and powers of 3 are close together. And here's the key fact: **log₂(3) is irrational.** The powers of 2 and the powers of 3 never exactly align (except trivially). They can come *close* — 2¹⁰ = 1024 is near 3⁶·⁵ ≈ 1157, and 2⁵³ is remarkably close to 3³⁴ — but they never match.

This means any hypothetical cycle would require an almost miraculous near-coincidence between powers of 2 and 3. The longer the cycle, the more miraculous the coincidence must be. Computations show that no such coincidence occurs for cycles of length up to billions.

But "no coincidence has been found" is not a proof. And this is where the story intersects with one of the deepest results in all of mathematics.

## Gödel's Shadow

In 1931, Kurt Gödel proved his incompleteness theorems, showing that any consistent formal system powerful enough to describe basic arithmetic must contain true statements that cannot be proved within the system. These are the *undecidable* statements — mathematical truths that exist beyond the reach of proof.

Gödel's theorem is often presented as abstract and remote from "real" mathematics. But what if the Collatz conjecture is a concrete example?

The argument goes like this: The Collatz conjecture is equivalent to asking whether a certain computation always halts. Specifically, for each starting number *n*, does the Collatz orbit of *n* eventually reach 1? This is a halting problem — and halting problems are notoriously connected to undecidability.

John Conway proved in 1972 that a natural generalization of the Collatz map — where instead of "3n+1," you use different linear rules depending on the residue of *n* modulo some base — can simulate arbitrary computations. In his generalized setting, the halting problem is provably undecidable: no algorithm can determine in advance whether every orbit converges.

The standard 3n+1 problem is a *specific instance* of these generalized maps, with very particular parameters (multiply by 3 and add 1 for odd numbers, divide by 2 for even). The question is whether this specific instance inherits the general undecidability, or whether its particular structure makes it tractable.

## The Independence Hypothesis

Here is the bold conjecture that emerges from this analysis: **The Collatz conjecture is independent of Peano Arithmetic.**

Peano Arithmetic (PA) is the standard formal system for reasoning about natural numbers. It is the foundation on which virtually all of number theory is built. To say the Collatz conjecture is "independent of PA" means that PA can neither prove it nor disprove it — it is true in the standard natural numbers but unprovable from PA's axioms.

This would make the Collatz conjecture a concrete example of Gödel's incompleteness phenomenon — perhaps the *simplest* such example. Most known independent statements are either artificially constructed (like Gödel sentences) or involve combinatorial principles far removed from everyday mathematics (like the Paris-Harrington theorem). A simple, naturally-occurring statement about a three-line arithmetic algorithm being independent of PA would be extraordinary.

The evidence, circumstantial though it is, points in this direction:

**1. Growth rate.** The Collatz orbit can grow faster than any function provably total in PA. The stopping time of *n* — the number of steps to reach 1 — appears to grow like a slowly varying function, but the *maximum orbit value* can spike to astronomical heights. The number 27, which is tiny, already reaches 9,232. These growth spikes are reminiscent of functions that outpace PA's provable totality.

**2. Diophantine structure.** The cycle exclusion problem reduces to solving exponential Diophantine equations. By the Matiyasevich-Robinson-Davis-Putnam theorem, the solvability of Diophantine equations is undecidable in general. While the specific Collatz equations are highly constrained, they sit at the boundary of what Diophantine methods can handle.

**3. Encoding power.** The Collatz map, despite its simplicity, has enough computational complexity to encode intricate arithmetic relationships. Every orbit traces a path through a tree of arithmetic operations that mirrors the structure of proofs in PA.

## What Would It Mean?

If the Collatz conjecture truly is independent of PA, the implications are profound.

First, it would mean that *every orbit does converge to 1* — because a counterexample (a specific number whose orbit doesn't reach 1) would be a finite, checkable proof of the negation, and the negation *is* provable if true. Independence implies truth.

Second, it would mean that no proof of the conjecture can exist within standard number theory. Not because the proof is too long or too clever, but because the tools of PA are fundamentally insufficient. You'd need stronger axioms — perhaps large cardinal axioms, or axioms asserting the consistency of PA itself — to prove it.

Third, and most tantalizing, it would establish a connection between a simple arithmetic process and the deepest foundations of mathematics. The three-line algorithm "if even, halve; if odd, triple and add one" would become a bridge between elementary arithmetic and metamathematical consistency.

## The Road Ahead

Proving that a statement is independent of PA is itself extremely difficult. Only a handful of "natural" mathematical statements have been shown to be independent, and each required sophisticated techniques from mathematical logic.

For the Collatz conjecture, a full independence proof would likely require showing that the statement is equivalent, over a weak base theory, to the consistency of PA — and then invoking Gödel's second incompleteness theorem. This is a grand challenge, and it remains open.

What we can do now is map the boundaries. We can classify exactly which orbit properties are provable in PA and which require stronger assumptions. We can formalize the connections between Collatz dynamics and exponential Diophantine equations. We can test the independence hypothesis computationally, looking for the signatures of unprovability in the arithmetic structure of orbits.

The Collatz conjecture may be the simplest question that no one can answer — not because the answer is hidden, but because the question itself transcends the framework we use to ask it. In the landscape of mathematical truth, it may sit just beyond the horizon of proof, visible but unreachable, a monument to the limits of formal reasoning.

And that would be the most beautiful thing about it.
