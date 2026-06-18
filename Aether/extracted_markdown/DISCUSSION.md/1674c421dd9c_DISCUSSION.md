# Non-Archimedean Factoring Oracle: When Factoring Meets the Future

## The Lock That Cannot Be Picked

Imagine you are a locksmith in ancient Rome. Someone hands you a bronze lock and asks: "Can you take this apart into two smaller pieces?" Most of the time, you can — you find a seam, a joint, a place where the metal yields. But occasionally, someone hands you a lock cast from a single, seamless piece of bronze. No matter how hard you look, there is no way to split it without destroying it.

This is, in essence, the oldest unsolved problem in mathematics dressed in modern clothing. The "locks" are numbers. The "seamless" ones are primes. And the question of how to tell them apart — and how to split the composite ones — has consumed mathematicians for over two thousand years, from Euclid's *Elements* to the cryptographic protocols that guard your bank account today.

In April 2026, a formal verification project attempted something ambitious: to state and prove, in machine-checked mathematics, that a "factoring oracle" exists — a universal procedure that takes any integer greater than 1 and splits it into two non-trivial pieces. The attempt failed. But the *way* it failed reveals something beautiful about the nature of numbers, proof, and mathematical truth.

## The Mathematical Heart

Here is the claim that was originally made, translated from its formal Lean 4 notation into plain English:

> "For every whole number n greater than 1, there exist two numbers a and b — both themselves greater than 1 — such that a times b equals n."

Read that again. It sounds perfectly reasonable. After all, 12 = 3 × 4. And 100 = 10 × 10. And 91 = 7 × 13. Surely every number can be broken apart this way?

No. Consider the number 7. The only ways to write 7 as a product of two whole numbers are 1 × 7 and 7 × 1. In both cases, one of the factors is 1 — which violates the requirement that *both* factors exceed 1. The number 7 is prime: it is one of those seamless bronze locks.

The original theorem was *false*. Every prime number is a counterexample. A machine-checked proof assistant — Lean 4, developed at Microsoft Research — caught this error before any human reviewer might have. This is precisely the value of formal verification: it is incorruptible, tireless, and merciless in its logical precision.

The corrected theorem says something subtler and more truthful:

> "For every whole number n greater than 1, either n is prime, or there exist a and b — both greater than 1 — with a × b = n."

This is the *dichotomy*: every number greater than 1 falls into exactly one of two categories. There is no third option, no twilight zone between prime and composite. The proof is constructive in spirit — for composite numbers, it produces the factorization by finding the *smallest factor* greater than 1.

## Why It Matters

You might think this is trivially obvious. In a sense, it is — the mathematical content has been known since antiquity. But the *formalization* matters enormously, for three reasons.

**First, cryptographic security.** The entire RSA encryption system, which protects trillions of dollars in online transactions, rests on the assumption that factoring large composite numbers is *computationally hard*. Our theorem tells us that factorizations *exist* — the question is whether they can be *found efficiently*. This distinction between existence and computation is one of the deepest in all of mathematics and computer science, directly connected to the famous P versus NP problem.

**Second, proof verification.** The original statement was plausible-sounding but wrong. In an era where mathematical proofs are growing longer and more complex — some spanning hundreds of pages — the ability to machine-check every logical step is becoming essential. The formal proof of the corrected theorem serves as a template for building verified mathematical libraries that future researchers can trust absolutely.

**Third, p-adic mathematics.** The original conjecture was framed in the language of p-adic numbers — a strange, beautiful alternative number system where "closeness" is measured by divisibility rather than distance on a number line. While the corrected theorem doesn't require p-adic machinery, it lays the groundwork for future formalizations of Hensel's lemma and Newton polygon methods, which genuinely do use p-adic analysis to lift partial factorizations to complete ones.

## The Beauty

What makes this result elegant is not its difficulty but its *inevitability*. The dichotomy between prime and composite is not a human invention — it is a structural feature of the natural numbers that would be discovered by any sufficiently advanced intelligence anywhere in the universe. The proof proceeds by a beautifully simple case analysis: either n is prime (and we are done), or it is not (and its smallest non-trivial factor gives us the split).

There is a deeper aesthetic here too. The formal proof in Lean 4 is just two lines long for the dichotomy theorem. Two lines to capture a truth that has been known for millennia, verified by a machine to a standard of certainty that no human proof can match. There is something profound about expressing eternal mathematical truths in a language that silicon can understand.

The interplay between the false conjecture and the true theorem also reveals something about the creative process in mathematics. The original statement was *almost* right — it just needed one additional hypothesis. This pattern, where a bold conjecture fails at the boundary and needs careful correction, is the heartbeat of mathematical discovery. Fermat's Last Theorem, the Poincaré Conjecture, the Riemann Hypothesis — all began as bold guesses that required centuries of refinement.

## Looking Ahead

This small formalization opens several doors. Can we formalize *efficient* factoring algorithms — not just the existence of factorizations, but polynomial-time methods for finding them when they exist? Can we prove, in Lean 4, that no efficient classical factoring algorithm exists (which would essentially resolve P ≠ NP)? Can we formalize the connection between p-adic analysis and integer factorization, building a verified library of Hensel lifting and Newton polygon methods?

More broadly, this work is part of a growing movement to create a complete, machine-verified library of mathematics. The Mathlib project for Lean 4 already contains over a million lines of formalized mathematics. Each theorem added — no matter how elementary — strengthens the foundation on which future breakthroughs will be built.

In the coming decades, we may see AI systems that not only verify proofs but *discover* them, finding factoring algorithms that no human has imagined. When that day comes, the formal foundations we build today will be the bedrock on which those discoveries stand.

## A Final Thought

There is a lovely irony in the story of the factoring oracle. We set out to prove that every number can be split apart, and instead we proved that some numbers — the primes — are irreducibly whole. In trying to build a universal splitting machine, we rediscovered the atoms of arithmetic.

Perhaps this is the deepest lesson mathematics has to teach us: that the most powerful truths are not the ones that break things apart, but the ones that reveal which things *cannot* be broken. The primes stand as silent sentinels at the gates of number theory, indivisible and eternal, reminding us that even in a universe of infinite complexity, some things are fundamentally, beautifully simple.
