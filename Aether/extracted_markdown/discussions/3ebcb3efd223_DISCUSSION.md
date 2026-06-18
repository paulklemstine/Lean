# Non-Archimedean Factoring Oracle: When Factoring Meets the Future

## LEDE

Imagine you hand a number to a machine—say, 91—and it instantly tells you: "That's 7 times 13." No sweat. Now imagine the number has 300 digits. Suddenly, the world's fastest supercomputers would need longer than the age of the universe to crack it. This asymmetry—easy to multiply, brutally hard to factor—is the bedrock of modern cryptography, the invisible lock on every online bank transaction and encrypted message you've ever sent.

But what if we could prove, with absolute mathematical certainty, that every composite number *must* have a nontrivial factorization? Not just believe it, not just observe it empirically, but nail it down in a language so precise that a computer can verify every logical step? That's exactly what a recent formalization effort accomplished—and the journey there revealed a surprising trap that even experienced mathematicians can fall into.

## THE MATHEMATICAL HEART

Here's the core question, stripped of jargon: take any whole number bigger than 1. Can you always break it into two smaller pieces, both bigger than 1, that multiply back to the original?

Think of it like splitting a chocolate bar. If your bar has 12 squares, you can snap it into a piece of 3 and a piece of 4: 3 × 4 = 12. Easy. But what if your bar has exactly 7 squares? You can't snap it into two pieces that are both at least 2 squares each. Seven is *prime*—it refuses to be broken.

This is the crux of the story. Someone proposed a bold theorem: "Every number greater than 1 can be split into two non-trivial factors." It sounds almost obvious if you're thinking about numbers like 12, 15, or 91. But it's *wrong*. Primes are the stubborn exceptions, the indivisible atoms of arithmetic.

The corrected theorem adds one crucial condition: the number must not be prime. With that single guardrail, the statement becomes true, provable, and—here's the kicker—formally verified by a computer in Lean 4, a proof assistant that checks every logical deduction with the rigor of a mathematical judge who never sleeps.

The proof itself is elegant in its simplicity. Given a composite number n, the system finds the smallest factor k greater than 1. Since n isn't prime, such a k must exist and must be strictly less than n. The complementary factor, n divided by k, is also greater than 1. Two witnesses, one clean verification, proof complete.

## WHY IT MATTERS

"But wait," you might say, "isn't this obvious?" In a sense, yes. Every math student learns that composite numbers have factors. But *formal verification* of even "obvious" facts matters enormously, for three reasons.

**Cryptographic foundations.** The security of RSA encryption—used by governments, banks, and tech companies worldwide—rests on assumptions about factoring. If we're going to trust our digital infrastructure to mathematical claims, those claims should be verified at the highest possible standard. A formally verified factoring theorem is one brick in that foundation.

**Catching hidden errors.** The original proposed theorem was *false*. It slipped past informal reasoning because it *felt* true. This is not an academic curiosity—subtle mathematical errors have derailed engineering projects, crashed spacecraft (remember the Mars Climate Orbiter?), and introduced security vulnerabilities. Formal verification is the antidote.

**Building toward bigger results.** In mathematics, you build towers of theorems, each resting on the ones below. Formal verification of elementary results creates a bedrock that more ambitious formalizations can stand on—results about prime distribution, computational complexity, and the ultimate limits of factoring algorithms.

## THE BEAUTY

There's something deeply satisfying about this theorem's correction. The original statement had a certain swagger to it—"every number factors!"—but it was hollow. The corrected version is more modest but *true*, and truth is the ultimate elegance in mathematics.

The proof leverages a beautiful structural fact about the natural numbers: if a number isn't prime, then by definition it has a divisor that's neither 1 nor itself. This is almost tautological, yet formalizing it requires navigating the subtle difference between "a divisor exists" (an existential claim) and "here is the divisor" (a constructive witness). The Lean proof threads this needle using Mathlib's `Nat.exists_dvd_of_not_prime2`, a lemma that extracts the witness from the definition of primality.

There's also a meta-level beauty: the interplay between human intuition (which got the original statement wrong) and machine verification (which caught the error). It's a partnership, not a competition. The human brings creativity and vision; the machine brings infallible logical checking.

## LOOKING AHEAD

This small formalization opens several fascinating doors.

First, there's the question of *efficiency*. Our proof shows that factors *exist* but says nothing about how quickly we can *find* them. The great open question—is factoring fundamentally hard?—remains one of the deepest unsolved problems in computer science. A formal proof that factoring is hard (or easy!) would reshape our understanding of computation itself.

Second, the "p-adic" framing of the original conjecture, while not needed for the corrected proof, hints at genuine research directions. Mathematicians have long used p-adic numbers—a strange alternative number system where "closeness" is measured by divisibility rather than distance on the number line—to study factoring and primality. Hensel's lemma, a workhorse of p-adic analysis, can lift approximate factorizations to exact ones. Formalizing these techniques in Lean could yield verified implementations of sophisticated factoring algorithms.

Third, as proof assistants grow more powerful, we can imagine a future where every theorem in a cryptography textbook is formally verified, creating an unbreakable chain of trust from axioms to applications. We're not there yet, but every formalized theorem—even a simple one—brings us closer.

## CLOSING

Mathematics has always been humanity's most reliable way of knowing. When Euclid proved there are infinitely many primes over two millennia ago, he established a truth that no experiment could ever overturn. Today, we're extending that tradition with digital tools that can verify proofs too complex for any single human mind to check.

The factoring oracle theorem—corrected, formalized, and verified—is a small result with a big lesson. It reminds us that even simple-sounding mathematical claims deserve scrutiny, that the gap between "sounds right" and "is right" can be bridged only by rigorous proof, and that the collaboration between human creativity and machine precision is producing mathematics more reliable than either could achieve alone.

In the end, the theorem tells us something we already knew: composite numbers can be broken apart. But now we know it with a certainty that transcends human fallibility—the certainty of a proof checked by logic itself.
