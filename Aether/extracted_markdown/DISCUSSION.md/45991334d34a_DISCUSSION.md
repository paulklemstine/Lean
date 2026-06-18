# Non-Archimedean Factoring Oracle: When Factoring Meets the Future

## LEDE

In 1977, three MIT researchers published a short paper with a bold promise: they could lock a message so securely that cracking it would require factoring a number with hundreds of digits — a task they estimated would take millions of years. Nearly half a century later, RSA encryption still guards your bank account, your medical records, and the launch codes of nuclear arsenals. All because of one stubborn mathematical fact: we know that large composite numbers *can* be split into smaller pieces, but actually *finding* those pieces is extraordinarily hard.

Now imagine a formal mathematician — not a human, but an AI system working in a computer-verified proof language — sits down to prove this foundational claim. It discovers something remarkable: the claim as originally stated is *false*. Not because of a subtle error in advanced p-adic analysis or Newton polygon theory, but because of something so basic it hides in plain sight: prime numbers exist.

## THE MATHEMATICAL HEART

Think of the natural numbers as a vast landscape of buildings. Some buildings — the primes — are monolithic: carved from a single block of stone, impossible to split into smaller structures. Others — the composites — are assembled from smaller blocks. The number 12, for instance, is really two bricks of size 2 and one brick of size 3 stacked together. The number 91 looks imposing but is secretly just 7 times 13.

The "factoring oracle" theorem says something deceptively simple: *every assembled building can be disassembled*. If you hand me a composite number — any composite number, no matter how large — I can break it into two meaningful pieces, each bigger than 1. This is not a claim about *how fast* I can do it. It is a claim about *whether it is possible at all*.

The original conjecture went further. It claimed that *every* number greater than 1 could be broken apart this way. But that is like claiming every building is assembled — which ignores the monoliths. A prime number, by definition, resists all attempts at decomposition. The number 7 can only be written as 1 × 7, and since one of those factors is just 1, it does not count as a genuine splitting.

The corrected theorem adds a single, essential caveat: the number must not be prime. With that caveat in place, the proof becomes almost trivially short — a single line in Lean 4, the proof assistant used for the formalization.

## WHY IT MATTERS

At first glance, proving that composite numbers can be factored seems about as exciting as proving that water is wet. But the devil is in the details — and in this case, in the *formalization*.

**For cryptography**, this theorem serves as a *specification*. When engineers build factoring algorithms — whether for breaking weak encryption keys or for quality-testing random number generators — they need a mathematical guarantee that the algorithm's output is correct. This theorem is that guarantee, stated in a language that a computer can verify character by character.

**For artificial intelligence**, the story of how this theorem was proved is itself noteworthy. An AI system was given a false conjecture dressed in sophisticated language about p-adic numbers and Newton polygons. Rather than blindly attempting to prove it, the system identified the error, explained why the original statement fails, and produced a corrected version with a machine-verified proof. This is exactly the kind of mathematical reasoning — skeptical, precise, self-correcting — that we want AI systems to exhibit.

**For the foundations of mathematics**, formal verification of even "obvious" results matters more than it might seem. Mathematicians have been embarrassed before by results that everyone "knew" were true but turned out to have subtle gaps. A machine-checked proof eliminates all doubt. The proof depends on exactly three axioms — propositional extensionality, the axiom of choice, and the soundness of quotient types — all standard and well-understood.

## THE BEAUTY

There is an elegant irony in this result. The problem was framed in the language of p-adic numbers — exotic mathematical objects that measure "closeness" not by ordinary distance, but by divisibility by a prime p. In the p-adic world, 1,000,000 is closer to 0 than 1/7 is, because a million is divisible by many small primes while 1/7 is not divisible by any of them. Newton polygons, Hensel's lemma, tropical geometry — these are the heavy artillery of modern number theory.

But the truth, when you strip away the scaffolding, is far simpler. A composite number has a non-trivial divisor. Divide by that divisor. You get two factors, both greater than 1. Done.

The beauty lies not in complexity but in the *contrast* between the sophisticated framing and the elementary reality. It is a reminder that mathematics, at its best, cuts through fog. The most powerful insight is sometimes the one that says: "This is simpler than you think — but only if you state it correctly."

There is also beauty in the proof's brevity. In Lean 4, the entire argument fits in a single line of tactic code. The proof assistant's library already knows that non-prime numbers have non-trivial divisors; all that remains is to package that divisor and its complement into the required existential witness. One line. No tricks. No detours. Just the right lemma, applied cleanly.

## LOOKING AHEAD

This formalization is a small brick in a much larger edifice that mathematicians and computer scientists are building: a fully verified library of number theory and cryptography.

The immediate next step would be to formalize not just the *existence* of factorizations but the *algorithms* that find them. Can we prove, in Lean 4, that trial division always terminates and always produces correct factors? What about more sophisticated algorithms like Pollard's rho, the quadratic sieve, or the general number field sieve? Each of these algorithms implicitly relies on the theorem we have just proved — they all assume that factorizations exist and seek to find them efficiently.

Further out, the grand challenge is to formalize the *complexity* of factoring. We believe — but cannot prove — that no classical algorithm can factor n-digit numbers in time polynomial in n. This belief underpins the entire edifice of public-key cryptography. Formalizing even the *statement* of this conjecture in a proof assistant would be a significant achievement, requiring a formal theory of computational complexity that is still in its infancy.

And on the quantum horizon, Shor's algorithm promises to factor integers in polynomial time on a quantum computer. The race between quantum hardware engineers and post-quantum cryptographers may determine the security landscape of the coming decades. Formal verification of both the quantum algorithms and the post-quantum replacements will be essential — and it all starts with results like this one.

## CLOSING

There is something deeply satisfying about a proof that is both trivial and important. The factoring oracle theorem tells us nothing new about numbers — every mathematician since Euclid has known that composites can be decomposed. But it tells us something new about *certainty*. 

In a world increasingly shaped by algorithms we do not fully understand, by AI systems that can both discover and deceive, the ability to state a claim in a language so precise that a machine can verify every logical step is not a luxury — it is a necessity. The factoring oracle, in its corrected and verified form, is a small monument to that ideal: a truth so simple it almost does not need proving, proved so rigorously it cannot possibly be wrong.

And perhaps that is the deepest lesson: the most important proofs are not always the most difficult ones. Sometimes, the most important proof is the one that catches the error everyone else missed — and then, in a single line, sets the record straight.
