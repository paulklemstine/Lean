# Non-Archimedean Factoring Oracle: When Factoring Meets the Future

## LEDE

Imagine you've invented a magical lens — one forged from the strange mathematics of p-adic numbers, where "closeness" means sharing the same prime factors rather than sitting near each other on a number line. You claim this lens can peer into any integer greater than 1 and split it into two meaningful pieces. You publish your result. Reviewers nod approvingly at the sophisticated machinery. And then a computer — cold, unyielding, immune to the charms of elegant theory — responds with a single word: *false*.

The number 2, a prime, cannot be split into two factors both greater than 1. Your beautiful oracle has a hole you could drive a prime number through.

This is the story of what happened when a p-adic factoring conjecture met formal verification — and what the corrected theorem reveals about the surprising interplay between advanced number theory, machine-checked proof, and the age-old quest to break numbers apart.

## THE MATHEMATICAL HEART

Here's the claim, stripped to its essence: take any whole number bigger than 1, and you can always write it as a product of two smaller numbers, each also bigger than 1. In other words, every number is composite — breakable.

The problem? Prime numbers exist. The number 7 stubbornly refuses to be written as, say, 3 times something-greater-than-1. It's 7, indivisible, atomic. The ancient Greeks knew this. Euclid proved there are infinitely many such stubborn numbers around 300 BCE.

So the original conjecture — dressed up in the language of p-adic analysis, Newton polygons, and Hensel's lemma — was making a claim equivalent to "there are no prime numbers." A spectacular claim, and spectacularly wrong.

But here's where the story gets interesting. When we add a single hypothesis — "and n is not prime" — the theorem becomes true, provable, and illuminating. Every composite number can be broken into two non-trivial pieces. This isn't deep mathematics; it's almost the *definition* of compositeness. Yet formalizing it precisely, stating it in a language a computer can verify, and producing a machine-checked proof reveals something profound about the gap between mathematical intuition and rigorous truth.

Think of it like this. You're in a warehouse full of LEGO bricks. Some bricks are single, atomic units — the primes. Others are assemblies that can be snapped apart into two smaller assemblies. The corrected theorem says: if a brick isn't atomic, you can always find the seam.

## WHY IT MATTERS

Integer factorization isn't just a mathematical curiosity. It's the bedrock of modern cryptography. Every time you send a credit card number over the internet, buy something online, or log into your bank, the security of that transaction rests on a simple bet: that nobody can efficiently factor the product of two large prime numbers.

RSA encryption, the workhorse of internet security for decades, works precisely because factoring is *hard* — not provably impossible, but practically intractable for numbers with hundreds of digits. A genuine "factoring oracle" — a mathematical black box that could decompose any number into its prime building blocks — would break RSA overnight.

The theorem we've formalized here doesn't provide such an oracle (sorry, cryptographers can relax). But it does something subtly important: it precisely delineates what a factoring guarantee can and cannot promise. The original, overreaching claim would have implied that every number is composite — a statement so strong it's false. The corrected version says something true but conditional: *if* you know a number is composite, *then* you can find its factors.

This distinction matters for formal verification of cryptographic protocols. When security proofs rely on the hardness of factoring, the exact logical structure of the assumption matters. Machine-checked proofs ensure that no subtle logical error — like accidentally assuming all numbers are composite — slips through.

## THE BEAUTY

There's an aesthetic pleasure in watching a false conjecture transform into a true theorem through the addition of a single hypothesis. It's like watching a sculptor remove one piece of marble to reveal the figure that was always inside.

The proof itself has a crystalline simplicity. Mathlib, the vast library of formalized mathematics for Lean, provides a lemma called `Nat.exists_dvd_of_not_prime2`. Given that n is greater than 1 and not prime, it extracts a divisor k satisfying 1 < k < n. From this single divisor, the entire factorization unfolds: set a = k and b = n/k, verify the arithmetic, and you're done.

What makes this elegant isn't complexity — it's the opposite. The proof is three lines long. But those three lines are *machine-verified*. No human error, no hidden assumptions, no hand-waving. The computer has checked every logical step against the foundations of mathematics, tracing back through thousands of prior theorems in the Mathlib library.

And the counterexample — showing that n = 2 defeats the original claim — is even simpler. If both factors exceed 1, their product is at least 4, which is too big to equal 2. QED. A proof so clean it almost feels like cheating.

## LOOKING AHEAD

This exercise points toward a future where all mathematical claims in cryptography, and indeed in all of science, are formally verified before being deployed.

Imagine a world where every proposed cryptographic protocol comes with a machine-checked proof of its security properties. Where the assumptions are stated precisely, the logic is verified automatically, and false claims are caught before they're published — not by clever reviewers, but by tireless proof assistants.

We're not there yet, but the tools are maturing rapidly. Lean 4, the proof assistant used here, combines a powerful programming language with an expressive logic capable of formalizing deep mathematics. The Mathlib library already contains hundreds of thousands of formalized theorems spanning algebra, analysis, topology, number theory, and combinatorics.

The frontier lies in formalizing the *computational* aspects of number theory — not just that factorizations exist, but that finding them is hard. This requires formalizing notions of computational complexity within the proof assistant, a project that several research groups are actively pursuing.

## CLOSING

There's a philosophical lesson buried in this small theorem. Mathematics, for all its reputation as the science of certainty, is practiced by humans — and humans make mistakes. We get seduced by beautiful theories, dazzled by sophisticated machinery, and sometimes we claim more than we've proven.

The p-adic numbers are genuinely beautiful. Newton polygons are genuinely powerful. Hensel's lemma is genuinely deep. But none of that sophistication can conjure prime numbers out of existence. The primes were there before we arrived, and they'll be there long after we're gone, stubbornly indivisible, quietly reminding us that mathematics is not about what we wish were true — it's about what *is* true.

A computer caught the error. A human corrected it. Together, they arrived at a small, clean, true theorem — and proved it beyond any doubt. That collaboration between human creativity and machine rigor may be the most important mathematical development of our century.
