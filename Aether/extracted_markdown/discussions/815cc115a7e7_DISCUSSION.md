# When Ancient Triangles Meet Modern Mathematics

## A Machine-Verified Journey from Pythagoras to the Frontiers of Number Theory

### The World's Oldest Equation

Every schoolchild learns it: 3² + 4² = 5². The Pythagorean theorem is perhaps the most ancient piece of mathematics still in active use today, carved into Babylonian clay tablets nearly 4,000 years ago. But behind this simple equation lies a fractal-like tree of infinite complexity — and it connects to some of the deepest unsolved problems in modern mathematics.

In a new research project combining computer-verified proofs with exploratory mathematics, we've traced these connections from the classical Berggren tree of Pythagorean triples through Einstein's spacetime geometry to the cutting edge of number theory — and along the way, rigorously disproved a conjecture that would have linked tropical geometry to integer factorization.

### The Berggren Tree: Infinity from Simplicity

In 1934, Swedish mathematician Berggren discovered something remarkable: every primitive Pythagorean triple (where the three sides share no common factor) can be generated from the "root" triple (3, 4, 5) by repeatedly applying three simple matrix operations. The result is an infinite ternary tree — each triple spawns exactly three "children," and every primitive triple appears exactly once.

What makes this tree mathematically rich is its hidden symmetry. The three Berggren matrices aren't just random transformations — they're discrete Lorentz transformations, the same kind of symmetries that govern Einstein's theory of special relativity. The equation a² + b² = c² defines a "null cone" in the Lorentz form Q = a² + b² − c², and the Berggren matrices preserve this cone. Every step up or down the tree is, in a precise mathematical sense, a spacetime boost.

Our project has formally verified this Lorentz structure using the Lean 4 proof assistant, establishing with machine-checked certainty that all three Berggren matrices belong to the integer Lorentz group O(2,1;ℤ), that they preserve the Pythagorean property at every level, and that the parent hypotenuse always satisfies the universal formula c' = 3c − 2a − 2b.

### The Tropical Mirage

One of the most tantalizing conjectures we investigated concerned "tropical" mathematics — a world where addition is replaced by taking minimums and multiplication becomes ordinary addition. Tropical geometry has recently found surprising applications in algebraic geometry, optimization, and even computational biology.

The conjecture proposed that if you look at the prime factorizations of numbers appearing along paths in the Berggren tree through the lens of p-adic valuations (which measure how many times a prime p divides a number), the resulting "tropical rank" would exactly equal the number of distinct prime factors. If true, this would have created an unexpected bridge between the ancient geometry of Pythagorean triples and the modern theory of integer factorization.

We proved this conjecture false with two concrete, machine-verified counterexamples. For the number 169 = 13², the tropical rank of the 13-adic valuation matrix is at least 2, while the number of distinct prime factors is just 1. The proof boils down to checking a single inequality — the "Monge condition" that characterizes tropical rank 1 — and showing it fails. The Lean proof assistant confirms this with absolute certainty: `native_decide` checks the numerical computation down to the last bit.

### Carmichael's Century-Old Theorem

Perhaps the deepest result we tackled is Carmichael's primitive divisor theorem from 1913. It states that for any Fibonacci number F(n) with n ≥ 13, there exists a prime number that divides F(n) but doesn't divide any smaller Fibonacci number. Such a prime is called a "primitive" divisor — it appears for the first time at position n in the Fibonacci sequence.

This theorem sits at the intersection of elementary number theory and deep algebraic machinery. The key insight is the beautiful identity gcd(F(m), F(n)) = F(gcd(m, n)), which means that the Fibonacci sequence has a multiplicative structure inherited from the integers themselves.

For prime values of n, the proof is elegant: any prime dividing F(n) must have "entry point" dividing n, and since n is prime, the entry point is either 1 or n. But F(1) = 1 has no prime divisors, so the entry point must be n, making every prime factor primitive.

For composite n, the situation is far more delicate. We verified the theorem computationally for all composite n up to 10,000 using Lean's `native_decide` capability — essentially asking the computer to check every case by direct computation of Fibonacci numbers and their prime factorizations. This required computing Fibonacci numbers with thousands of digits, but modern hardware handles this efficiently.

The analytical proof for all composite n beyond 10,000 remains an open formalization challenge. The mathematical argument exists (Carmichael proved it over a century ago), but translating it into machine-checkable form requires formalizing the "lifting the exponent" lemma for Fibonacci numbers and the theory of Lucas sequences — mathematical infrastructure that hasn't yet been built in the Lean proof library.

### Why Machine-Verified Proofs Matter

In an era of increasingly complex mathematics, human error is an ever-present risk. Andrew Wiles's first proof of Fermat's Last Theorem contained a gap that took a year to fix. More recently, several published results in top journals have been found to contain errors years after publication.

Machine-verified proofs eliminate this risk entirely. When the Lean proof assistant accepts a proof, it has checked every logical step against the axioms of mathematics, from the most obvious to the most subtle. The counterexamples to the tropical rank conjecture aren't just "we computed it and it looks wrong" — they are mathematical certificates of falsity, verified independently by a program whose correctness has been established at the foundational level.

This project demonstrates both the power and the limitations of current proof technology. We can verify intricate algebraic identities, computational number theory, and matrix calculations with perfect confidence. But some classical results — particularly those requiring deep analytical arguments about the growth of number-theoretic functions — remain beyond the reach of automated proof search, requiring careful human guidance to translate informal mathematical arguments into formal proofs.

### Looking Forward

The connection between Pythagorean triples and Lorentz geometry suggests deeper relationships waiting to be discovered. The Berggren tree is just one face of a rich algebraic structure that connects to modular forms, quaternion algebras, and the representation theory of SL(2,ℤ).

While the specific tropical rank conjecture proved false, the underlying question — whether the arithmetic structure of Pythagorean triples can reveal information about integer factorization — remains intriguing. The universal parent equation, with its elegant formula c' = 3c − 2a − 2b, hints at patterns in the descent from large Pythagorean triples to the root (3, 4, 5) that could potentially encode factorization information in ways we haven't yet imagined.

The full formalization of Carmichael's theorem for composite numbers stands as a concrete challenge for the growing community of mathematicians working with proof assistants. It requires building new mathematical infrastructure — the theory of Lucas sequences, the lifting-the-exponent lemma, and bounds on Fibonacci growth — that would benefit many other formalization projects.

In the end, the oldest equation in mathematics continues to surprise us, connecting Babylonian arithmetic to Einstein's spacetime, tropical geometry, and the frontiers of computational proof. The journey from 3² + 4² = 5² to the cutting edge is shorter than you might think.
