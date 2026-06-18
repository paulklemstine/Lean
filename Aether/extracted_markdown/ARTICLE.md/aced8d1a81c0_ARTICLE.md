# What Can You Learn by Asking an Oracle?

## The Hidden Question Behind the Greatest Unsolved Problems in Mathematics

Imagine you have a magic telephone that connects to an all-knowing mathematical oracle. You can ask it questions about certain special functions—functions that encode the deepest secrets of prime numbers and the geometry of equations. Each answer comes back instantly and with perfect accuracy.

Here is the question that should keep you up at night: *What exactly can you learn from those answers?*

This may sound like philosophy. It is not. It is a precise mathematical question, and the answer turns out to be surprisingly subtle—and profoundly important for some of the biggest open problems in mathematics, from the distribution of prime numbers to the security of your bank's encryption.

## The Functions That Know Everything

In the 1850s, Bernhard Riemann discovered that prime numbers—those indivisible atoms of arithmetic—are controlled by a single mathematical function. This function, called the Riemann zeta function, takes a complex number as input and produces a complex number as output. Its behavior, particularly the locations where it equals zero, dictates the precise distribution of primes among the integers.

Riemann made a famous prediction about where these zeros should lie: all on a single vertical line in the complex plane, like pearls on a string. This conjecture, known as the Riemann Hypothesis, remains unproven after 165 years. The Clay Mathematics Institute has offered one million dollars for its resolution.

But the zeta function is just the beginning. Mathematicians have since discovered entire families of similar functions—L-functions—each encoding arithmetic information about different mathematical objects. Some encode the behavior of prime numbers. Others encode the arithmetic of elliptic curves, the geometry of algebraic varieties, or the symmetries of modular forms. Together, they form a vast library of arithmetic truth.

Now suppose you could consult this library. What could you actually figure out?

## The Oracle Hierarchy

The breakthrough idea is deceptively simple: not all ways of accessing information are equally powerful.

Think of it like a medical database. Knowing a patient's temperature at one moment tells you something. Having their complete temperature history tells you more. Having their full medical chart tells you more still. And having their genetic sequence tells you something qualitatively different. Each level of access unlocks capabilities that the previous level cannot provide.

The same principle applies to L-functions. A recent mathematical investigation has identified a precise hierarchy of oracle capabilities:

**Level 1: Point Values.** You can ask "What is L(s) at this particular input s?" and get an exact answer. This is like being able to take the patient's temperature at any time you choose.

**Level 2: Derivatives.** You can ask "What is the n-th derivative of L at s?" This is like having not just the temperature, but its rate of change, acceleration, and all higher-order trends.

**Level 3: Zero Certificates.** You can ask "Where exactly does L equal zero in this region, and can you prove there are no others?" This is like having a certified diagnostic test, not just a measurement.

**Level 4: Local Factors.** You can ask about the building blocks of L—the local Euler factors that encode information one prime at a time. This is like having the genetic sequence, which determines everything else.

The mathematical theorem that makes this hierarchy precise and important is this: *consequences that seem similar actually live at different levels, and the levels are strictly separated.*

## The Barrier Nobody Expected

Here is the surprise. Suppose you have a Level 1 oracle—you can evaluate L(s) at any point you want, as many times as you want. Can you determine whether L has a zero at a specific point, say s = 1?

The answer is no. Not from any finite number of queries.

This is not a practical limitation. It is a theorem. For any finite set of query points you choose (avoiding the point you care about), there exist two perfectly valid analytic functions that give identical answers to every query but have completely different behavior at the target. One might vanish there; the other might not.

The proof is elegant and constructive. Given your query set Q, consider the vanishing polynomial—the product of all factors (z − q) for each query point q. This polynomial is zero at every point you queried, but nonzero at your target (since the target is not among the query points). The zero function is also zero at every query point. Both functions agree perfectly on your queries, but one is zero at the target and the other is not.

This is not a technicality. It is the mathematical reason why simply being able to compute L-function values—even with infinite precision and no time limit—is fundamentally insufficient for answering certain arithmetic questions. The oracle is not lying to you. It is telling you everything you asked. But what you asked was not enough.

## When Derivatives Change Everything

Move up one level. Now your oracle can tell you not just L(s), but also L'(s), L''(s), and every higher derivative. Suddenly, the world changes.

The vanishing order of a function at a point—the number of times it vanishes there—is determined by the first nonzero derivative. If L(1) = 0 and L'(1) = 0 but L''(1) ≠ 0, the vanishing order is exactly 2. Mathematics guarantees that this number, when it exists, is unique.

Why does this matter? Because one of the deepest conjectures in mathematics—the Birch and Swinnerton-Dyer conjecture, another million-dollar Clay problem—predicts that the vanishing order of a certain L-function at s = 1 equals the rank of an elliptic curve. The rank tells you, roughly, how many independent rational solutions the curve has.

The derivative oracle does not solve this conjecture. But it solves half the problem: it provides a certified, unambiguous computation of the analytic side. What remains is the purely arithmetic question of whether the two sides are equal—a question that belongs to algebraic geometry, not to oracle computation.

This separation is itself a conceptual advance. It disentangles the *computational* aspect of BSD (which reduces to a derivative oracle) from the *structural* aspect (the deep equality between analytic and algebraic invariants).

## When Zero Certificates Decide the Riemann Hypothesis

Move up another level. Suppose your oracle can not only evaluate L and its derivatives, but can also provide certified lists of all zeros in any bounded region—complete with proof that no others exist.

Now the Riemann Hypothesis up to any finite height becomes decidable. You simply ask: "List all zeros with imaginary part between −T and T." The oracle returns a finite, certified list. You check whether every zero on the list has real part exactly 1/2. If yes, the Riemann Hypothesis holds up to height T. If any zero deviates, it fails.

This does not prove the full Riemann Hypothesis—that would require checking infinitely many zeros. But it provides something that no finite amount of point evaluation can achieve: a certified verification for any specified height. This is exactly what large-scale computational projects actually do when they verify RH for billions of zeros. The theorem shows that this computational approach is logically justified at Level 3, and *cannot* be replicated at Level 1.

## Breaking Codes with Arithmetic

The hierarchy connects to cryptography through an unexpected channel: integer factorization.

Modern encryption relies on the difficulty of factoring large numbers that are the product of two primes. The factor extraction theorem demonstrates a clean mathematical principle: if you can find any number that is divisible by one prime factor but not the other, a single greatest-common-divisor computation—practically instantaneous—reveals the factorization.

The connection to L-functions is this: the local Euler factors of certain L-functions (Level 4 data) encode information about how arithmetic behaves modulo each prime. For a semiprime n = p × q, the Euler factor data naturally separates into contributions from p and from q. Any trace-of-Frobenius computation that distinguishes these contributions yields a separating invariant—and hence a factorization.

This does not mean that Level 4 L-function oracles would break RSA encryption. The hard part is not the GCD computation; it is obtaining the separating invariant in the first place. But the theorem precisely identifies *where* the computational difficulty lies. It is not in the arithmetic extraction step. It is entirely in the oracle access.

## The Identity Principle: Why Small Samples Determine Big Functions

Beneath all of this lies a beautiful classical theorem, now repurposed for the oracle framework. Two analytic functions that agree on a set with an accumulation point must agree everywhere on their common domain of definition.

What is an accumulation point? It is a point where your sample data clusters—where you have infinitely many data points converging to it. A sequence like 1, 1/2, 1/3, 1/4, ... has 0 as its accumulation point.

This theorem means that Level 1 oracle access, while insufficient for determining individual zeros, is sufficient for a different and equally remarkable task: *identifying the function itself.* If two candidate L-functions agree on a convergent sequence of query points, they must be the same function everywhere. Period. No exceptions.

This is the mathematical engine behind comparison: if someone claims to have a different L-function that matches yours on a carefully chosen (but infinite) test set, mathematics guarantees they are wrong. Their function is yours.

## A New Kind of Mathematics

What makes this framework genuinely new is not any single theorem. It is the systematic classification of arithmetic power by oracle strength.

Before this work, statements like "computing L-function values gives access to arithmetic information" were folklore—true in spirit but imprecise in content. The hierarchy replaces imprecision with theorems. It says:

- Point evaluation determines the function (identity principle) but cannot detect individual zeros (barrier theorem).
- Derivative access detects vanishing orders (and hence analytic ranks) with guaranteed uniqueness.
- Zero certification makes bounded instances of the Riemann Hypothesis decidable.
- Euler factor access yields separating invariants for factorization.

Each statement is proved. Each separation is strict. The framework is extensible—new oracle capabilities and new consequences can be slotted in at the appropriate level.

## What Comes Next

The oracle hierarchy opens several research directions.

First, the *quantitative* question: how many queries at a given level suffice for a given consequence? The barrier theorem says finitely many point queries never suffice for zero detection. But what about infinitely many, arranged carefully? The identity principle says yes—if arranged with an accumulation point. The gap between "finite" and "cleverly infinite" is rich territory.

Second, the *converse* question: if Level k access does not suffice for a given consequence, can one prove this for all algorithms, not just specific constructions? This leads to computational complexity lower bounds in the oracle model—connecting number theory to the deep waters of theoretical computer science.

Third, the *analogy* question: L-functions are not the only objects whose zero locations carry deep information. Dynamical zeta functions in physics, spectral determinants in quantum mechanics, and partition functions in statistical mechanics all share this structure. The oracle hierarchy framework may apply to all of them, providing a unified language for asking "what does zero-location information buy you?" across mathematics and physics.

The ultimate vision is a map: a comprehensive diagram showing which mathematical truths can be extracted from which kinds of arithmetic access. Some truths require only evaluation. Others require derivatives. Some require certified zero data. And some—perhaps the deepest truths of all—may require information that no oracle in our hierarchy can provide.

Drawing that map is the work of a generation. But the framework for drawing it now exists.
