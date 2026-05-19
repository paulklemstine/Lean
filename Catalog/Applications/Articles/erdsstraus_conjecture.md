# The 4/n Problem: How a Simple Fraction Stumped Mathematicians for 76 Years

In 1948, two of the twentieth century's most original mathematical minds sat down to think about fractions. Paul Erdős, the eccentric Hungarian genius who lived out of a suitcase and co-authored more papers than anyone in history, and Ernst Straus, a former assistant to Albert Einstein, posed a question so simple that a curious teenager could understand it — and so hard that no one has answered it since.

Their question: *Can you always break the fraction 4/n into exactly three pieces of the form 1/something?*

Take 4/5, for instance. It equals 1/2 + 1/5 + 1/10. Check it with a calculator: 0.5 + 0.2 + 0.1 = 0.8 = 4/5. Or try 4/7: that's 1/2 + 1/28 + 1/28. It works. In fact, for every number anyone has ever tested — and computers have checked billions — it works. But no one can prove it *always* works.

Welcome to one of mathematics' most tantalizing open problems.

## An Ancient Idea Meets Modern Mystery

The idea of writing fractions as sums of "unit fractions" — fractions with 1 on top — is nearly as old as mathematics itself. The ancient Egyptians, who built the pyramids and mapped the stars, used this exact system for all their arithmetic. The Rhind Papyrus, a mathematical text from around 1650 BCE, is essentially a giant table of unit-fraction decompositions. Where we write 2/7, an Egyptian scribe would write 1/4 + 1/28.

This wasn't mere convention. Egyptian fraction decomposition has a beautiful practical interpretation. Imagine you need to divide 4 loaves of bread equally among 7 people. You could try to cut each loaf into 7 equal pieces — but that requires extraordinary precision. Instead, the Egyptian approach says: cut 1 loaf in half (each person gets 1/2 of a piece), and divide the remaining half-loaves into 14ths and 28ths. The pieces are larger, fewer cuts are needed, and the division is fairer because the pieces are more uniform in size.

Erdős and Straus asked whether this always works when you have exactly 4 loaves and any number of people.

## The Architecture of Near-Proof

What makes the Erdős–Straus conjecture so maddening is that it's *almost* proved. Mathematicians have shown it's true for enormous classes of numbers using elegant algebraic identities.

**The even numbers are trivial.** If you're dividing among an even number of people — say 2k people — then 4/(2k) = 1/k + 1/(2k) + 1/(2k). You can verify this in your head: the three pieces always sum to the right amount. That single formula handles half of all integers in one stroke.

**Numbers divisible by 3 fall just as easily.** If n is a multiple of 3, say n = 3m, then 4/n = 1/m + 1/(6m) + 1/(6m). Another infinite family, dispatched by one formula.

**Numbers that leave remainder 2 when divided by 3** yield to a subtler identity. If n has this property, then (n+1)/3 is a whole number — call it m. Then 4/n = 1/n + 1/m + 1/(nm). The pieces are less symmetric now, but the algebra still clicks shut like a lock.

**Numbers that leave remainder 3 when divided by 4** require yet another construction, but again, a single parametric formula covers the entire infinite class.

Together, these four families cover every integer that does *not* leave remainder 1 when divided by 12. That is 11 out of every 12 consecutive integers — a coverage rate of about 91.7 percent.

The remaining holdouts — numbers like 13, 25, 37, 49, 61, 73 — are all congruent to 1 modulo 12. Every one that has been checked has a decomposition, but there is no single formula that handles them all. Each one requires its own clever arrangement.

## The View from Above: A Cubic Surface

To a modern mathematician, the Erdős–Straus equation is not really about fractions at all. Clear the denominators from 4/n = 1/x + 1/y + 1/z and you get:

4xyz = n(xy + xz + yz)

This is a cubic equation in three variables, parameterized by n. For each value of n, it defines a *surface* in three-dimensional space — a smooth, curving sheet that extends to infinity. The question becomes: does this surface always pass through a point with positive integer coordinates?

This geometric perspective transforms the problem. The four parametric families are *rational curves* lying on the surface — one-dimensional highways of solutions that can be described by simple formulas. The exceptional cases (n ≡ 1 mod 12) are places where these highways don't pass through integer points, and you need to find isolated integer solutions by other means.

The surface 4xyz = n(xy + xz + yz) belongs to a well-studied class in algebraic geometry. It is a *del Pezzo surface* — the same type of geometric object that appears in string theory, mirror symmetry, and the classification of algebraic varieties. The Erdős–Straus conjecture is, in disguise, a question about whether a particular family of del Pezzo surfaces always has rational points.

## The Computational Frontier

While the mathematical proof remains elusive, computational verification has pushed the boundary to staggering heights. The conjecture has been verified for all integers up to at least 10^14 — that's a hundred trillion. Every one of these numbers has a decomposition.

The computational approach is not mere brute force. The key insight is a *reduction theorem*: if you can prove the conjecture for every prime number, then it's automatically true for every integer. Why? Because any composite number n has a prime factor p, and if 4/p = 1/a + 1/b + 1/c, then 4/n = 1/(a·d) + 1/(b·d) + 1/(c·d) where d = n/p. The denominators simply scale up.

This reduction cuts the computational workload dramatically. Instead of checking all integers up to a bound, you only need to check primes — and even then, only the primes congruent to 1 mod 12, since all others are already covered by the algebraic families.

For each such prime, a *smart search* algorithm exploits the algebraic structure. Rather than blindly testing all possible triples (x, y, z), the algorithm fixes x and y, then computes z exactly from the equation: z = nxy / (4xy − n(x+y)). If this quotient is a positive integer, a solution has been found. This reduces the search from cubic to quadratic time — and in practice, solutions are found almost immediately.

## Why Should Anyone Care?

The Erdős–Straus conjecture sits at an intersection of ideas that matter far beyond pure mathematics.

**Fair division.** The problem of splitting resources into unit fractions has direct applications in scheduling, load balancing, and resource allocation. If you need to divide 4 identical tasks among n processors using only "1/k-th of a task" assignments, the Erdős–Straus decomposition tells you it's always possible with just three assignment levels.

**Computational complexity.** The conjecture, if true, implies that finding Egyptian fraction decompositions is computationally easy — solutions exist and can be found quickly. If false, it would reveal a surprising gap between existence and efficient computability in elementary number theory.

**Covering systems.** The proof strategy — covering integers by congruence classes, each handled by its own formula — is a fundamental technique in combinatorial number theory. Erdős himself pioneered this approach in his work on covering systems, and the Erdős–Straus conjecture is a natural testing ground for these methods.

**Formal mathematics.** Recent advances in computer-verified mathematics have made it possible to construct machine-checked proofs of the partial results — the four parametric families, the prime reduction theorem, and the computational verifications. These certified proofs offer absolute certainty about the results they cover, building a verified mathematical infrastructure that could support a future complete proof.

## The Last Mile

The conjecture has the feel of a problem that is 95 percent solved. The algebraic machinery covers 11/12 of all integers. The prime reduction theorem focuses attention on a thin set of exceptional primes. Computational search has verified billions of cases without finding a counterexample.

And yet that final 5 percent — those primes congruent to 1 mod 12, where no uniform formula is known — has resisted every approach for three-quarters of a century. The surface 4xyz = n(xy + xz + yz) has integer points for every tested value of n, but proving it must *always* have them requires understanding something deep about the interplay between multiplication and addition, between the geometry of surfaces and the arithmetic of whole numbers.

Perhaps the answer lies in a new parametric family — a formula no one has yet discovered that covers the remaining exceptional cases. Perhaps it requires a fundamentally different approach: a sieve method, a modular form argument, or an insight from the geometry of numbers. Or perhaps — though no mathematician seriously expects this — there is a counterexample lurking among unimaginably large numbers, a fraction 4/n that simply cannot be split into three unit fractions.

Whatever the resolution, the Erdős–Straus conjecture continues to embody what makes number theory so compelling: questions that a child can understand, that the greatest minds have pondered, and that still conceal surprises in the most familiar of mathematical objects — the humble fraction.
