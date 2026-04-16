# The Numbers That Guard Your Secrets — And the Machine That Proves It

## How Mathematicians Are Using AI-Verified Proofs to Crack Open the Deepest Problems in Number Theory

*A Scientific American-style article on the Gravitational Factoring project*

---

### The Lock That Protects the Internet

Every time you buy something online, send a private message, or log into your bank account, you're relying on one of the oldest unsolved problems in mathematics: the difficulty of factoring large numbers.

The idea is simple. Take two large prime numbers — say, each 150 digits long — and multiply them together. That multiplication takes a fraction of a second. But given only the product, finding those original primes could take longer than the age of the universe with today's fastest computers. This asymmetry is the foundation of RSA encryption, which protects trillions of dollars in daily transactions.

But how do we *know* factoring is hard? And could we be wrong?

A team of researchers has been attacking this question from an unexpected angle: they're building computer-verified proofs of the mathematical foundations underlying factoring algorithms. And their latest results are stunning.

### 280 Theorems, Zero Doubt

The project, known as "Gravitational Factoring," has now formally verified over 280 mathematical theorems using Lean 4, a proof assistant that checks every logical step with machine precision. Unlike ordinary mathematical proofs, which rely on human judgment and can contain subtle errors, these proofs are verified by a computer that accepts nothing on faith.

"When we say a theorem is proved, we mean a silicon chip has checked every deduction," explains the approach. "There's no room for hand-waving."

The latest version — v10 — includes some remarkable achievements:

**The Complete Euclid-Euler Theorem.** The ancient Greeks knew that certain numbers are "perfect" — they equal the sum of their proper divisors. (6 = 1 + 2 + 3 is the smallest example.) Euclid showed how to construct perfect numbers using prime numbers of a special form: the Mersenne primes. Two thousand years later, Euler proved the converse: every *even* perfect number must have Euclid's form. For the first time, both directions of this 2,300-year-old theorem have been formally verified by computer, stated as a single clean biconditional.

**Quadratic Reciprocity — Complete.** Gauss called it the "golden theorem" and gave six proofs during his lifetime. The law of quadratic reciprocity, which reveals deep patterns in how prime numbers interact, has now been fully formalized, along with both "supplements" that handle the special cases of -1 and 2.

**The Möbius Inversion Formula.** This fundamental tool of analytic number theory — which lets you "invert" sums over divisors — has been mechanically verified for the first time in this framework.

### Looking for Cracks in the Armor

But the project isn't just about proving old theorems. It's about understanding factoring at the deepest level.

The team has formalized key pieces of the **quadratic sieve** — the fastest known general-purpose factoring algorithm for numbers up to about 100 digits. They've verified that if you can find enough "smooth" numbers (numbers with only small prime factors), you can reliably extract factors. The mathematical chain is now almost entirely verified: from difference of squares, through congruence extraction, to the final gcd computation.

They've also verified foundations of the **Coppersmith method**, which finds small roots of polynomials modulo a number. This method is the basis for attacks on certain weak implementations of RSA.

### The Energy Landscape: A New Way to See Numbers

Perhaps the most innovative aspect of the project is its "energy landscape" perspective. For any number N, define E(N, x) = N mod x — the remainder when you divide N by x. This creates a landscape over the integers where every divisor of N sits at the bottom of a valley (energy zero), while non-divisors are perched on ridges.

The team has formally proved that these valleys are exactly the local minima of the landscape, and that the "sublevel sets" (regions below a threshold energy) grow monotonically as you raise the threshold. At threshold zero, you see only the divisors; at threshold N, you see everything.

This topological perspective opens the door to Morse theory — a powerful mathematical tool that relates the topology of a space to its critical points. Applied to factoring, it could reveal deep structural constraints on where factors must lie.

### What the Fibonacci Numbers Know

The project has also uncovered surprising connections between factoring and the Fibonacci sequence. Every prime p divides some Fibonacci number — but the pattern of which Fibonacci numbers it divides encodes information about p itself. The team has formally proved the existence of the Pisano period (the period of the Fibonacci sequence modulo any number) using the pigeonhole principle, and verified that the "entry point" of a prime in the Fibonacci sequence divides all other Fibonacci indices divisible by that prime.

These results connect to an open question: **do Wall-Sun-Sun primes exist?** These are primes p where p² divides F(p - (p/5)), where (p/5) is the Legendre symbol. The team has verified computationally that no such prime exists below 200. If they were found, they would have implications for Fermat's Last Theorem.

### The Perfect Number Mystery

While even perfect numbers are completely characterized by the Euclid-Euler theorem, the existence of **odd perfect numbers** remains one of the great unsolved problems. The team has verified by exhaustive computation that no odd perfect number exists below 10,000 — a tiny step in a search that has reached 10^1500 without success.

The question is deliciously simple: is there an odd number that equals the sum of its proper divisors? Most mathematicians believe the answer is no, but nobody has proved it. The formal verification of the Euclid-Euler theorem provides the infrastructure for future attacks on this problem.

### The Road Ahead

The project's roadmap stretches years into the future. Near-term goals include:

- **End-to-end quadratic sieve verification** — proving that the entire algorithm correctly factors any composite number
- **Formal Coppersmith bounds** — extending small root detection to arbitrary polynomial degrees
- **Persistent homology of energy landscapes** — using tools from topological data analysis to detect factors

Longer-term dreams include formally proving the correctness of the number field sieve (the fastest known factoring algorithm for very large numbers) and establishing formal lower bounds on the quantum speedup achievable by Shor's algorithm.

### Why It Matters

In an era of increasing reliance on cryptographic security — from blockchain to digital voting to military communications — understanding the mathematical hardness of factoring isn't just academic. It's a matter of national security.

"Every cryptographic protocol that depends on factoring hardness is implicitly making a mathematical claim," the researchers note. "Formal verification is the gold standard for ensuring those claims are correct."

With 280+ verified theorems and counting, the Gravitational Factoring project is building the most comprehensive formally verified foundation for factoring theory ever assembled. Whether it ultimately reveals a crack in the armor of RSA or confirms its strength, the mathematical infrastructure being constructed will stand as a permanent contribution to human knowledge.

After all, when you're guarding the world's secrets, "probably correct" isn't good enough. You need *proof*.

---

*The Gravitational Factoring project is open source and available as a Lean 4 library. All theorems can be independently verified by anyone with a computer and a Lean installation.*
