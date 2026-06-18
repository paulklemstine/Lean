# Non-Archimedean Factoring Oracle: When Factoring Meets the Future

## The Lede

Imagine you are handed a 600-digit number and told that the security of every bank transaction on Earth depends on nobody being able to split it into two smaller pieces. This is, roughly speaking, the premise behind RSA encryption — the workhorse of internet security for nearly half a century. The number is composite, meaning it was constructed by multiplying two large primes together, but actually finding those primes from the product alone is, as far as anyone knows, extraordinarily hard.

Now imagine someone walks into the room and says: "I have a mathematical oracle. Give me any composite number, and I will produce its factors." You'd be alarmed. But then they add a caveat: "Of course, it only works on composite numbers. If you hand me a prime, I'll have to refuse."

This distinction — seemingly trivial — turns out to be exactly the line where a plausible-sounding mathematical claim becomes false. And it took a computer to catch the mistake.

## The Mathematical Heart

Think of the natural numbers as a vast landscape. Some numbers — 2, 3, 5, 7, 11, and infinitely many others — are like atoms: indivisible, irreducible. These are the primes. Every other number greater than 1 is composite: it can be broken apart into smaller pieces, like a molecule into its constituent atoms.

The theorem we formalized makes a deceptively simple claim: every composite number can be split into two pieces, each bigger than 1. Take 12: it breaks into 2 × 6, or 3 × 4. Take 143: that's 11 × 13. The claim seems obvious — after all, "composite" practically means "can be factored."

But here's where things get interesting. The original version of the theorem, as proposed, dropped the word "composite." It claimed that *every* number greater than 1 could be split this way. That's flatly wrong. The number 7, for instance, cannot be written as a product of two numbers both exceeding 1. It's prime — and primes, by definition, resist exactly this kind of decomposition.

The error is subtle. It's the kind of mistake that might slip past a human reviewer, especially when buried in elaborate mathematical language about p-adic numbers and Newton polygons. But it cannot slip past a proof assistant. Lean 4, the formal verification system we used, simply refused to accept the proof. There is no way to prove a false statement in a consistent logical system — and Lean's type theory is precisely that.

## Why It Matters

The formal verification of mathematical claims is not merely an academic exercise. It represents a fundamental shift in how we establish mathematical truth.

In cryptography, the distinction between prime and composite numbers is the foundation of security. RSA works because multiplying two large primes is easy, but factoring their product is hard. Any theorem about factoring — even an elementary one — must get the boundary conditions exactly right. A cryptographic protocol built on a subtly incorrect mathematical assumption could be catastrophically vulnerable.

More broadly, as artificial intelligence systems increasingly generate mathematical conjectures and proof sketches, the need for machine verification becomes acute. AI systems are prone to exactly the kind of plausible-but-wrong reasoning that produced the original false statement. They can generate text that *looks* like a valid mathematical argument, complete with references to sophisticated techniques like Hensel's lemma and p-adic valuations, while containing a fundamental logical gap.

Our work demonstrates the corrective power of formal verification: no matter how convincing the surrounding narrative, the proof must compile.

## The Beauty

There is an aesthetic pleasure in the corrected proof's simplicity. The entire argument, once the right hypothesis is in place, reduces to a single line of Lean code. The key insight is that Mathlib — the vast library of formalized mathematics for Lean — already contains the lemma `Nat.exists_dvd_of_not_prime2`, which states: if n > 1 and n is not prime, then there exists a divisor k with 1 < k < n. From there, the factorization n = k × (n/k) writes itself.

This economy of expression reveals something deep about mathematical structure. The theorem isn't really about p-adic numbers or Newton polygons — those are sophisticated tools for attacking the *computational* problem of factoring (finding the factors efficiently). The *existence* of factors for composite numbers is a far simpler claim, one that follows directly from the definition of primality by logical negation.

The beauty lies in the gap between the elaborate machinery suggested by the problem framing and the elementary nature of the actual proof. It's a reminder that in mathematics, the most powerful move is often to strip away unnecessary complexity and see the problem for what it really is.

## Looking Ahead

The formalization of elementary number theory is just the beginning. The real frontier lies in formalizing the computational aspects of factoring — proving that specific algorithms (trial division, Pollard's rho, the number field sieve) actually produce correct factorizations, and ideally, characterizing their complexity.

Several tantalizing directions emerge:

**Certified Factoring Algorithms.** Can we write a factoring program in Lean that comes with a machine-checked proof of correctness? Such a program would output not just the factors, but a *certificate* — a proof object that any verifier can check independently.

**P-adic Methods Formalized.** The original problem mentioned Hensel's lemma and p-adic valuations. These are genuine mathematical tools used in algorithms like factoring polynomials over the integers. Formalizing these methods in Lean would bring certified computation to a much more powerful algorithmic level.

**The Frontier of Hardness.** Perhaps the deepest open question is whether integer factoring is inherently hard. This is closely related to the famous P vs. NP problem. Formalizing what we know — and don't know — about computational hardness could clarify the logical structure of these conjectures.

## Closing

There is a quiet drama in watching a computer refuse to accept a false theorem. No argument from authority, no appeal to intuition, no elaborate theoretical framework can override the simple logical check: does this proof follow from the axioms?

The non-archimedean factoring oracle began as an ambitious claim draped in the language of p-adic analysis and algebraic geometry. It ended as a humble truth about composite numbers — corrected, simplified, and verified beyond any possibility of doubt.

In this exchange between human ambition and machine precision, we glimpse something essential about the nature of mathematical truth. It is not a matter of consensus or persuasion. It is not about how sophisticated your tools are or how impressive your vocabulary is. It is about whether your reasoning, laid bare in formal logic, actually holds.

The primes, as always, remind us: some things simply cannot be broken apart. And knowing which things those are — with absolute certainty — is worth more than all the oracles in the world.
