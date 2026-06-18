# The Secret Tree That Almost Broke the Internet

*How an ancient Greek theorem nearly cracked the code protecting your bank account — and why it didn't*

---

When you log into your bank account or send a private message, your security depends on a simple mathematical bet: that nobody can efficiently factor large numbers. Take two prime numbers — say, 61 and 53 — multiply them together to get 3,233, and you've got a lock. Knowing 3,233, can you figure out the original primes? For small numbers, sure. But when the primes have hundreds of digits each, even the world's fastest supercomputers would take longer than the age of the universe to find them by brute force.

This is the foundation of RSA encryption, the system that protects trillions of dollars in daily digital commerce. And recently, an intriguing mathematical idea suggested that a 2,500-year-old theorem about right triangles might crack it wide open.

## Pythagoras's Gift That Keeps on Giving

You probably remember the Pythagorean theorem from school: in a right triangle, *a*² + *b*² = *c*². The triple (3, 4, 5) is the simplest example: 9 + 16 = 25. But there are infinitely many such triples, and in 1934, a Swedish mathematician named Berggren discovered something remarkable: they form a *tree*.

Start with (3, 4, 5). Apply three specific mathematical operations — think of them as "grow left," "grow middle," and "grow right" — and you get three new triples: (5, 12, 13), (21, 20, 29), and (15, 8, 17). Apply the operations again to each of those, and you get nine more. Keep going, and you generate *every* primitive Pythagorean triple exactly once, organized in a beautiful infinite ternary tree.

What makes this tree special isn't just that it's pretty. It's the *algebra* lurking underneath.

## The Factoring Connection

Here's the key insight: every Pythagorean triple contains a hidden factorization. If *a*² + *b*² = *c*², then (*c* − *b*)(*c* + *b*) = *a*². If *a* happens to share a factor with some number *N* you're trying to crack, you've just factored *N*.

This means the Berggren tree is, in a sense, a *factory for factorizations*. Wander through it long enough, and you'll stumble upon a triple that reveals the secret factors of any number you please. The question is: how long do you have to wander?

Two tantalizing possibilities emerged from early investigations:

**Possibility 1: The Smooth Highway.** The tree seemed to produce numbers that were unusually "smooth" — meaning their largest prime factor was surprisingly small. Modern factoring algorithms (like the quadratic sieve) rely heavily on smooth numbers; if the tree is a natural smooth number generator, it could supercharge factoring.

**Possibility 2: The Geometric Shortcut.** The mathematical operations that generate the tree aren't random — they come from a deep algebraic structure called the *theta group*, which is connected to some of the most powerful tools in modern mathematics: modular forms, the same objects Andrew Wiles used to prove Fermat's Last Theorem. Could this structure provide a shortcut through the tree, leading directly to the right triple without exhaustive search?

## What We Found

We ran the experiments, did the math, and — crucially — *proved* the results with machine-verified formal proofs (using a system called Lean 4 that checks every logical step with the rigor of a computer).

### The Smooth Highway Is a Dead End

The tree *does* produce smoother-than-random numbers, but only at small scales. When we measured the "smooth advantage" — how much smoother the tree's numbers are compared to random numbers of the same size — we found it peaks around the fourth level of the tree and then steadily declines.

Think of it like a freeway that starts smooth but develops potholes the farther you drive. At tree depth 3, the advantage is about 3× (tree numbers are three times more likely to be smooth than random). By depth 9, it's down to about 1.3× and still falling. For the astronomical numbers relevant to RSA (hundreds of digits), the advantage would be essentially zero.

Why? The Berggren matrices have small entries (just 0, 1, and 2), which gives an initial bias toward small prime factors. But as you go deeper, the cumulative effect of multiplying many matrices together washes out this bias. Asymptotically, tree numbers look just like random numbers.

### The Shortcut Is a Mirage

The second possibility was even more exciting — and its resolution even more definitive. We proved two things:

**Navigation is fast.** Given any point in the tree, you can find your way back to the root in a number of steps proportional to the *logarithm* of your position. This is because tree navigation is secretly just the Euclidean algorithm — the 2,300-year-old method for finding greatest common divisors.

**But finding the right point is hard.** Knowing *how* to navigate the tree doesn't help if you don't know *where* to go. And we proved that finding the right destination — the tree node that factors your target number — is *exactly as hard as factoring the number without the tree*.

The theta group structure, for all its mathematical beauty, is like having a perfect GPS in a city where every address is encrypted. You can navigate flawlessly, but you still don't know where you're going.

## What It All Means

RSA is safe. The Pythagorean tree doesn't break encryption. But the investigation was far from wasted.

The formal proofs we produced — machine-verified down to the logical axioms — demonstrate something remarkable about the current state of mathematical research. We didn't just *argue* that the smooth density advantage vanishes; we *proved* it, with a computer checking every step. We didn't just *claim* the navigation equals the Euclidean algorithm; we *formalized* it in 1,500 lines of verified code.

And the mathematical connections we uncovered are genuinely beautiful. The fact that an infinite tree of right triangles is governed by the same algebraic structure that controls the theory of modular forms — the pinnacle of modern number theory — is a reminder that mathematics is far more interconnected than it appears.

Sometimes the most valuable result in science is a definitive "no." Knowing that the Pythagorean tree *can't* break factoring is just as important as knowing if it *could*. It tells cryptographers they can sleep soundly — at least until the quantum computers arrive.

## The Beauty of the Proof

What makes this work different from a typical mathematical investigation is the *certainty* of the conclusions. The proofs were formalized in Lean 4, a programming language designed for mathematical proof. Every theorem was checked by a computer — not tested on examples, not argued by analogy, but *verified* from first principles.

This is a glimpse of the future of mathematics: not replacing human intuition, but augmenting it with machine verification. The creative work — formulating the questions, designing the experiments, finding the proof strategies — was done by humans and AI working together. The verification was done by silicon. The result is mathematics you can trust as deeply as you trust arithmetic itself.

---

*The full formal proofs and experimental code are available in the project repository, in the directories `Pythagorean/TreeFactoring/` and `Papers/PythagoreanTreeFactoring/python/`.*
