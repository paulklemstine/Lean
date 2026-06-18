# Non-Archimedean Factoring Oracle: When Factoring Meets the Future

## The Day the Computer Said "No"

Imagine a mathematician walks into a room and announces: "I have proven that every number greater than one can be split into two smaller pieces." The audience nods. It sounds right — after all, 12 is 3 times 4, and 100 is 10 times 10. But in the back of the room, a computer — a formal proof assistant running Lean 4 — raises its metaphorical hand and objects: "What about 7?"

Seven is prime. Its only factorizations are 1 × 7 and 7 × 1. Neither split gives two pieces that are both genuinely "smaller" — one of them is always the trivial number 1. The mathematician's claim, dressed up in the exotic language of p-adic numbers and Newton polygons, was false. And a machine caught it.

This is the story of the Non-Archimedean Factoring Oracle — a theorem that arrived broken and left stronger, a case study in what happens when ancient number theory meets the rigorous eye of modern formal verification.

## THE MATHEMATICAL HEART

At its core, this is a story about two kinds of numbers. Think of the natural numbers — 2, 3, 4, 5, 6, and so on — as atoms and molecules. The primes (2, 3, 5, 7, 11, ...) are the atoms: indivisible, fundamental, the building blocks from which all other numbers are constructed through multiplication. The composites (4, 6, 8, 9, 10, ...) are the molecules: built from atoms, always splittable.

The original theorem claimed something bold: that *every* number greater than 1 — atom or molecule — could be split into two non-trivial pieces. It dressed this claim in sophisticated garb, invoking "p-adic" number systems where distances are measured not by how far apart two numbers are on a number line, but by how divisible their difference is by a prime p. In this strange universe, 1,000,000 is closer to 0 than 1 is, because a million is highly divisible by small primes.

But the exotic framing couldn't save a false claim. The corrected version is both simpler and true: every *composite* number greater than 1 can be split into two factors, each greater than 1. If n isn't prime, you can always find its smallest non-trivial divisor — call it k — and pair it with n/k. Both are bigger than 1, and their product is n.

## WHY IT MATTERS

You might wonder: who cares whether composite numbers can be factored? Isn't that obvious? In a sense, yes — but the *precision* of the statement matters enormously, and here's why.

Modern cryptography — the technology that secures your bank account, your messages, your medical records — rests on the assumption that while factoring is *possible* in principle, it is *hard* in practice. The RSA encryption system, used billions of times daily, works by multiplying two large primes together. Anyone who knows the factors can read the secret message; anyone who doesn't is locked out. The security of the entire system depends on the gap between "factors exist" (our theorem) and "factors are easy to find" (which, thankfully, they aren't for large numbers).

Getting the existence statement exactly right is the first step. A theorem that accidentally claims primes can be factored would be worse than useless in a cryptographic security proof — it would be dangerous, potentially invalidating the logical chain that guarantees your data is safe.

This is where formal verification shines. A human mathematician might wave away the prime case as "obviously excluded." A proof assistant demands precision. And in demanding precision, it catches the errors that matter.

## THE BEAUTY

There is an unexpected elegance in the interplay between the false and the true here. The original theorem, with its p-adic apparatus, its invocations of Hensel's lemma and Newton polygons, was like an ornate cathedral built on sand. Strip away the decorations, and the foundation crumbles.

The corrected theorem is a cottage — small, solid, perfectly functional. Its proof in Lean 4 is essentially one line: extract the minimal factor using `Nat.exists_dvd_of_not_prime2`, pair it with the complementary factor, and verify the arithmetic. The axioms it depends on — `propext`, `Classical.choice`, `Quot.sound` — are the standard logical foundations that underpin all of modern mathematics.

But the real beauty is in the *process*. The classification theorem we proved alongside it — "every n > 1 is either prime or composite" — is the kind of statement that mathematicians treat as so obvious it barely deserves mention. Yet stating it formally, and proving it in a system where every logical step is checked, reveals the hidden structure: classical logic (the law of excluded middle) is doing real work here, allowing us to split the natural numbers into two clean categories.

There's also a deeper lesson about mathematical fashion. The p-adic numbers are genuinely powerful tools in number theory — they underpin the proof of Fermat's Last Theorem, they appear in the Langlands program, they're essential to modern algebraic geometry. But invoking them doesn't magically make a false statement true. Mathematics rewards clarity over sophistication, and a correct elementary proof outranks an incorrect advanced one every time.

## LOOKING AHEAD

This small episode points toward several larger trends that will shape mathematics in the coming decades.

**Formal verification is becoming essential.** As mathematical proofs grow longer and more complex — some modern proofs span hundreds of pages across multiple papers — the chance of subtle errors increases. Proof assistants like Lean, with libraries like Mathlib containing hundreds of thousands of verified theorems, offer a safety net. The formalization of this factoring oracle, catching its error in seconds, is a microcosm of what formal verification will do for mathematics at scale.

**The gap between existence and computation deepens.** Our theorem proves factors *exist* but says nothing about how to *find* them efficiently. This gap is the heartbeat of computational complexity theory and cryptography. Quantum computers threaten to close this gap for integer factoring (via Shor's algorithm), which would revolutionize cryptography. Understanding the exact boundary between "provably exists" and "efficiently computable" remains one of the great open problems.

**P-adic methods have genuine potential.** While the original framing was flawed, p-adic analysis does offer real tools for factoring. Hensel's lemma — which lifts solutions from modular arithmetic to p-adic precision — is the mathematical engine behind several practical factoring algorithms. Formalizing these connections in proof assistants is an active area of research that could yield both theoretical insights and practical algorithms.

## CLOSING

There is something profoundly human about getting a theorem wrong and then getting it right. Mathematics is often presented as a march of certainties — axiom, theorem, proof, QED. But the reality is messier, more creative, more alive. We conjecture, we err, we correct, we refine. The p-adic factoring oracle began as an ambitious but flawed claim and emerged as a modest but true one, its error caught not by a rival mathematician but by a piece of software that simply insists on logical rigor.

In the end, the theorem tells us something we already knew: composite numbers can be split apart. But the *journey* to that theorem — through false starts, exotic number systems, and machine verification — tells us something we're still learning: that the pursuit of mathematical truth is not a solitary human endeavor anymore. We have partners now, silicon ones, and together we might just get it right.
