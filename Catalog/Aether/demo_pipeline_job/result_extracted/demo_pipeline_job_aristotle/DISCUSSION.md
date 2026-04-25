# Non-Archimedean Factoring Oracle: When Factoring Meets the Future

## The Lock That Cannot Lie

Imagine you are handed a padlock. Not a physical one — a mathematical one, forged from the product of two enormous prime numbers. This is essentially what secures every online bank transaction, every encrypted message, every digital signature in the modern world. The security of RSA encryption rests on a single, stubborn fact: given a large number that is the product of two primes, finding those primes is extraordinarily hard.

But what if we could *prove*, with absolute mathematical certainty, that those hidden factors must exist — and describe exactly how to extract them, at least in principle?

That is the question behind the "non-archimedean factoring oracle," a theorem recently formalized and machine-verified in Lean 4, a programming language designed not for running apps but for checking mathematical truth itself. The result is deceptively simple, yet it illuminates something deep about the nature of numbers, proof, and the surprising difficulty of getting mathematical statements exactly right.

## The Mathematical Heart

Here is the idea, stripped of all symbols. Every whole number greater than 1 falls into one of two categories: it is either *prime* (divisible only by 1 and itself — like 2, 3, 7, or 101) or *composite* (breakable into smaller pieces — like 6 = 2 × 3, or 15 = 3 × 5).

The theorem says: if you hand me any composite number, I can always crack it open into two meaningful pieces. Not trivial pieces like "1 times itself" — genuine, nontrivial factors, each bigger than 1.

This might sound obvious. Of course 12 splits into 3 × 4. Of course 100 splits into 10 × 10. But mathematics demands precision, and the original version of this theorem — as initially proposed — was actually *wrong*.

The original claim was bolder: *every* number greater than 1 can be split into two factors, each greater than 1. A moment's reflection reveals the flaw: what about 7? Or 13? Primes, by their very nature, refuse to split. They are the atoms of arithmetic, irreducible and indivisible.

A formal proof assistant — a computer program that checks every logical step with ruthless precision — caught this error instantly. No amount of hand-waving or intuitive reasoning could slip past it. The theorem had to be corrected, sharpened, stated with surgical precision: the factorization guarantee applies to composite numbers, and *only* to composite numbers.

## Why It Matters

At first glance, proving that composite numbers can be factored seems like proving that water is wet. But there are several reasons this matters far more than it appears.

**For cryptography**, the existence of factors is the easy part; the hard part is *finding* them efficiently. But every algorithm that searches for factors implicitly relies on the theorem that those factors exist. Before you can analyze the complexity of a search, you must know that there is something to find. This theorem provides that certified guarantee.

**For formal verification**, the story is more subtle and more important. As software systems grow more complex — self-driving cars, AI medical diagnostics, nuclear reactor controllers — the need for *provably correct* software intensifies. Formal verification in proof assistants like Lean is how we build that certainty. Every theorem added to the verified library is another brick in a fortress of trustworthy mathematics that software can rely on.

**For mathematics itself**, the episode illustrates a profound lesson: even "obvious" theorems can be stated incorrectly, and formalization is the most reliable safeguard against such errors. The history of mathematics is littered with published proofs that contained subtle gaps — gaps that persisted for years or decades before being noticed. A proof assistant notices them in milliseconds.

## The Beauty

What makes this result elegant is not its difficulty but its *clarity*. The proof, once correctly stated, is remarkably clean. It uses a single key insight from Mathlib (the vast mathematical library for Lean): a lemma called `Nat.exists_dvd_of_not_prime2`, which says that if a number is greater than 1 and not prime, then it has a divisor strictly between 1 and itself.

From this single fact, the rest unfolds like origami. Take that divisor *d*. Divide *n* by *d* to get the complementary factor. Verify that both pieces are greater than 1. Verify that their product reconstructs *n*. Done.

The beauty lies in the interplay between the human insight (knowing *what* to prove and *why* the original statement was wrong) and the machine's verification (checking every step with perfect reliability). Neither alone would suffice. The human catches the conceptual error; the machine certifies the correction.

There is also a hidden symmetry in the proof's structure. The minimal factor of a composite number and its complement are like two sides of a coin — one is always less than or equal to the square root of *n*, the other always greater than or equal to it. This is the same observation that makes trial division work: you only need to check divisors up to √n. The theorem formalizes the *existence* claim that makes such algorithms meaningful.

## Looking Ahead

This work sits at the intersection of several rapidly evolving fields.

**Formal mathematics** is entering a golden age. The Lean community has formalized thousands of theorems from undergraduate and graduate mathematics, and is now tackling research-level results. In 2023, a team formalized a proof of the Polynomial Freiman-Ruzsa conjecture in Lean within weeks of its announcement — a feat that would have been unthinkable a decade ago.

**AI-assisted theorem proving** is the next frontier. Large language models are increasingly capable of suggesting proof strategies, filling in routine steps, and even discovering novel mathematical arguments. The formalization described here was produced with the assistance of such a system, demonstrating that AI can not only generate proofs but also *catch and correct errors* in mathematical statements.

**Verified cryptography** is the ultimate application. Imagine a world where every cryptographic protocol comes with a machine-checked proof of security — not just a paper proof that might contain errors, but a certificate that a computer has verified down to the axioms of logic. Projects like EverCrypt and HACL* are already moving in this direction, and formalized number theory is a crucial foundation.

The specific question of whether factoring is *computationally hard* remains one of the great open problems of mathematics and computer science. If P ≠ NP (as most experts believe), then no efficient classical algorithm for factoring exists. But quantum computers, if built at scale, could factor efficiently using Shor's algorithm. The race between factoring algorithms and cryptographic defenses will shape the future of digital security.

## A Truth That Checks Itself

There is something philosophically remarkable about a proof that a computer has verified. It is not a matter of trust in any individual mathematician's reasoning. It is not a matter of peer review, where errors can slip through. It is a *mechanical guarantee*, as reliable as arithmetic itself.

When Euclid proved that there are infinitely many primes, he relied on the force of logical argument to convince other humans. When we formalize the same theorem in Lean, we rely on the same logic — but now the checking is done by a machine that never gets tired, never makes sign errors, and never confuses itself with wishful thinking.

The non-archimedean factoring oracle, in its corrected form, is a small theorem. But it carries a large message: in the age of formal verification, mathematics is becoming not just a human endeavor but a collaboration between human creativity and machine precision. The theorems we prove together — human and computer, intuition and logic — are stronger than either could produce alone.

And perhaps that is the deepest factorization of all: the splitting of mathematical discovery into imagination and verification, each greater than 1, and their product something truly indivisible.
