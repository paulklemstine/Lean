# The Million-Dollar Equation That Refuses to Be Coprime

## A prize, a puzzle, and a pattern

In 1993, a Texas banker named Andrew Beal, an amateur number theorist with a taste for hard problems, was experimenting with an equation on a computer. He was looking for whole-number solutions to

$$A^x + B^y = C^z,$$

with all six letters standing for positive integers and — this is the crucial restriction — with all three exponents at least $3$.

He found solutions. Plenty of them. Here is one:

$$3^3 + 6^3 = 27 + 216 = 243 = 3^5.$$

Here is another, bigger one:

$$7^6 + 7^7 = 7^6(1 + 7) = 7^6 \cdot 8 = (7^2)^3 \cdot 2^3 = 98^3 .$$

And another, from a completely different direction:

$$2^9 + 8^3 = 512 + 512 = 1024 = 2^{10}.$$

But something curious kept happening. In every single solution he found, the three bases $A$, $B$, $C$ shared a common prime factor. In $3^3 + 6^3 = 3^5$, all three bases are divisible by $3$. In $7^6 + 7^7 = 98^3$, all three are divisible by $7$. In $2^9 + 8^3 = 2^{10}$, all three are even.

Beal conjectured that this is no accident.

> **Beal's Conjecture.** If $A^x + B^y = C^z$ where $A, B, C, x, y, z$ are positive integers and $x, y, z \geq 3$, then $A$, $B$, and $C$ have a common prime factor.

He backed it with a cash prize, currently one million dollars, held in trust by the American Mathematical Society. It remains unclaimed. The conjecture is open.

This article is about what we *can* prove — and it turns out to be a surprising amount. We cannot yet claim the prize, but we can fence the problem in from every side: show exactly which single hypothesis carries the whole conjecture, prove that the conjecture is strictly harder than Fermat's Last Theorem, prove that any counterexample must be strictly "hyperbolic" and obey rigid parity constraints, show that the celebrated $abc$ conjecture would confine all counterexamples to a finite region — and prove the whole thing outright in a parallel universe where numbers are replaced by polynomials.

## Why exponent 3 is the magic threshold

The first thing to appreciate is how *sharp* the hypothesis $x, y, z \geq 3$ is. Drop any one of the three exponents to $2$ and the conjecture collapses immediately. Three famous identities do the demolition, one for each slot:

- Drop the *first* exponent: $7^2 + 2^5 = 49 + 32 = 81 = 3^4$. The bases $7, 2, 3$ are pairwise coprime.
- Drop the *middle* exponent: $7^3 + 13^2 = 343 + 169 = 512 = 2^9$. The bases $7, 13, 2$ are pairwise coprime.
- Drop the *last* exponent: $2^7 + 17^3 = 128 + 4913 = 5041 = 71^2$. The bases $2, 17, 71$ are pairwise coprime.

Each of these is a genuine, sporadic, coprime solution with exponents $(2,5,4)$, $(3,2,9)$, $(7,3,2)$. They belong to a famous short list — the known solutions of the **Fermat–Catalan equation**, of which more below — and they show that Beal's threshold of $3$ is not a matter of convenience. It is the exact boundary.

At the other extreme, the conjecture is not vacuous: solutions genuinely exist and there are infinitely many. Take the identity $3^3 + 6^3 = 3^5$ and scale it. Multiply the first equation through by $t^{15}$ and you get

$$(3t^5)^3 + (6t^5)^3 = (3t^3)^5$$

for every positive integer $t$. So there are Beal solutions with $C$ as large as you like — and, exactly as predicted, all three bases in each of them are divisible by $3$.

## The three-way collapse

The first real structural insight is a triviality that turns out to be the hinge of everything. Suppose $A^x + B^y = C^z$ and suppose a prime $p$ divides *two* of the three bases. Then it divides the third.

Why? If $p \mid A$ and $p \mid B$, then $p$ divides $A^x$ and $B^y$, hence their sum $C^z$; and a prime dividing a power divides the base. If $p \mid A$ and $p \mid C$, rearrange to $B^y = C^z - A^x$, and the same argument runs. Likewise for $B$ and $C$.

This has an immediate and useful consequence:

> **Pairwise Coprimality Theorem.** If a solution of $A^x + B^y = C^z$ with positive exponents has *no* common prime factor of all three bases, then $A$, $B$, $C$ are **pairwise** coprime: $\gcd(A,B) = \gcd(A,C) = \gcd(B,C) = 1$.

There is no middle ground. A hypothetical counterexample to Beal's conjecture cannot be *partly* entangled — say, with $A$ and $B$ both even but $C$ odd. Either all three bases share a prime, or no two of them share anything at all.

And that means the conjecture, which as stated involves three simultaneous divisibility claims, can be tested by a single one:

> **Single-Coprimality Reformulation.** Beal's conjecture is true if and only if there is no solution of $A^x + B^y = C^z$ with positive bases, exponents $x, y, z \geq 3$, and $\gcd(A,B) = 1$.

The full conjecture and this apparently much weaker-looking statement are logically identical. If you want to disprove Beal, you need only produce one solution in which the two *summand* bases happen to be coprime; the collapse theorem does the rest of the work for you.

## Beal is Fermat, and more

Set $x = y = z = n$ and ask for a solution with no common prime factor. That is Fermat's Last Theorem for exponent $n$ — the statement, proved by Andrew Wiles in 1995 after 358 years, that $a^n + b^n = c^n$ has no solution in positive integers for $n \geq 3$.

Actually the connection is cleaner than "the special case". Beal's conjecture *implies* Fermat's Last Theorem for every $n \geq 3$, and the derivation is a classical infinite descent:

> **Beal Implies Fermat.** If Beal's conjecture holds, then for every $n \geq 3$ the equation $a^n + b^n = c^n$ has no solution in positive integers.

*Proof sketch.* Suppose $a^n + b^n = c^n$ with $a, b, c$ positive, and choose such a solution with $a$ as small as possible. Beal's conjecture supplies a prime $p$ dividing all three of $a, b, c$. Write $a = pa'$, $b = pb'$, $c = pc'$. Substituting and cancelling the common factor $p^n$ from both sides gives $a'^n + b'^n = c'^n$, a solution with $a' = a/p < a$ still positive. That contradicts minimality. $\square$

So Beal's conjecture is at least as hard as Fermat's Last Theorem, and its proof, if one exists, cannot be a soft argument. Conversely, Wiles's theorem and its ancestors hand us free cases of Beal. Since Fermat's Last Theorem is known for exponents $3$ and $4$, and since a solution with exponent $n$ produces one with exponent $d$ whenever $d \mid n$ (just regroup $a^n = (a^{n/d})^d$), we get:

> **Unconditional Cases.** There is no solution at all of $A^x + B^y = C^z$ with $A,B,C \geq 1$ and $x, y, z \geq 3$ whenever $3$ or $4$ divides $\gcd(x,y,z)$.

For instance, the exponent triple $(6, 9, 15)$ — gcd $3$ — admits no solutions whatsoever, common factor or not. Beal's conjecture holds there vacuously.

## Everything is hyperbolic

Fermat–Catalan theory divides exponent triples $(x,y,z)$ into three regimes according to the sign of $1/x + 1/y + 1/z - 1$:

- **spherical**, $1/x+1/y+1/z > 1$: triples like $(2,2,n)$, $(2,3,3)$, $(2,3,4)$, $(2,3,5)$. Here solutions come in infinite parametrized families.
- **euclidean**, $= 1$: exactly $(3,3,3)$, $(2,4,4)$, $(2,3,6)$. These correspond to elliptic curves and are settled classically.
- **hyperbolic**, $< 1$: everything else, where solutions are expected to be extremely rare.

Where does Beal live? Its hypothesis $x,y,z \geq 3$ gives $1/x+1/y+1/z \leq 1$ immediately, with equality only for $(3,3,3)$. But $(3,3,3)$ is exactly Fermat's exponent $3$, ruled out by Euler's theorem. So the boundary case is eliminated and one gets a strictly quantitative statement:

> **Quantitative Hyperbolicity.** Every solution of $A^x + B^y = C^z$ in positive integers with $x, y, z \geq 3$ satisfies
> $$\frac{1}{x} + \frac{1}{y} + \frac{1}{z} \leq \frac{11}{12}.$$
> In particular every Beal solution is strictly hyperbolic, $1/x+1/y+1/z < 1$.

The bound $11/12$ is best possible: it is attained by $(3,3,4)$ and its permutations, since once one exponent is at least $4$ the sum is at most $1/4 + 1/3 + 1/3 = 11/12$, and the only remaining triple is $(3,3,3)$. That harmless-looking $1/12$ gap is not decoration. It is precisely the fuel for the $abc$ argument below: a strictly negative "Euler characteristic" is what lets an inequality with an error term bite.

The hyperbolicity also gives the cleanest way to say what Beal's conjecture actually *is*. Call $(a,b,c,x,y,z)$ a **Fermat–Catalan solution** if $a,b,c$ are positive and pairwise coprime, $x,y,z \geq 2$, $1/x+1/y+1/z < 1$, and $a^x + b^y = c^z$. Only ten such solutions are known — among them the three sporadic identities quoted earlier, plus $1^m + 2^3 = 3^2$, $3^5 + 11^4 = 122^2$, $33^8 + 1549034^2 = 15613^3$, $17^7 + 76271^3 = 21063928^2$, $1414^3 + 2213459^2 = 65^7$, $9262^3 + 15312283^2 = 113^7$, and $43^8 + 96222^3 = 30042907^2$ — and the Fermat–Catalan conjecture says there are only finitely many in total. Every one of the ten known solutions has an exponent equal to $2$. Beal's conjecture says that this is a law:

> **Fermat–Catalan Reformulation.** Beal's conjecture holds if and only if no Fermat–Catalan solution has all three exponents at least $3$.

So Beal's conjecture is exactly the *high-exponent tail* of Fermat–Catalan. And since counterexamples to Beal are Fermat–Catalan solutions, finiteness for Fermat–Catalan would immediately give: Beal's conjecture has at most finitely many counterexamples.

## The $abc$ conjecture puts a wall around the problem

The $abc$ conjecture of Masser and Oesterlé is the deepest known organizing principle in this area. It concerns the **radical** $\operatorname{rad}(n)$ of a positive integer: the product of its distinct prime factors, forgetting multiplicities. So $\operatorname{rad}(72) = \operatorname{rad}(2^3 \cdot 3^2) = 6$. The conjecture says that if $a + b = c$ with $a, b$ coprime, then $c$ cannot be much larger than $\operatorname{rad}(abc)$:

> **$abc$ Conjecture.** For every $\varepsilon > 0$ there is a constant $K_\varepsilon$ such that every coprime triple $a + b = c$ of positive integers satisfies $c \leq K_\varepsilon \cdot \operatorname{rad}(abc)^{1+\varepsilon}$.

The link with Beal is a single observation about radicals: **the radical cannot see exponents.** Since $A^x$, $B^y$, $C^z$ have exactly the same prime supports as $A$, $B$, $C$,

$$\operatorname{rad}(A^x B^y C^z) = \operatorname{rad}(ABC) \leq ABC .$$

Now suppose $(A,B,C,x,y,z)$ is a counterexample to Beal. Then $A^x$ and $B^y$ are coprime, so the $abc$ inequality applies to $A^x + B^y = C^z$. Write $N = C^z$ for the size of the solution. Applying $abc$ with $\varepsilon = 1/12$, in the clean integral form
$$c^{12} \leq K \cdot \operatorname{rad}(abc)^{13},$$
gives $N^{12} \leq K \cdot (ABC)^{13}$.

Against this we need an upper bound on $ABC$. Here is where hyperbolicity earns its keep. Since $A^x \leq N$, $B^y \leq N$, $C^z = N$, and since the exponents cannot all be $3$, one of them is at least $4$; grouping accordingly gives the clean exponent count

$$(ABC)^{12} \leq N^{11}.$$

Combining the two — raise the first to the twelfth power and substitute — yields $N^{144} \leq K^{12} N^{143}$, whence:

> **The $abc$ Wall.** If the effective $abc$ bound $c^{12} \le K \operatorname{rad}(abc)^{13}$ holds for coprime triples, then every counterexample to Beal's conjecture satisfies $C^z \leq K^{12}$.

Since the real-analytic $abc$ conjecture yields such an integral bound (take $\varepsilon = 1/12$ and clear denominators by rounding the constant up), the conclusion is unconditional in the following conditional sense: **if the $abc$ conjecture is true, then Beal's conjecture has only boundedly many counterexamples, all of size at most an explicit constant.** Indeed all of $A^x$, $B^y$, $C^z$ lie below $K^{12}$; and provided the summand bases $A, B$ are at least $2$, even the exponents are bounded, because $x < 2^x \leq A^x \leq K^{12}$. The entire hypothetical counterexample — six numbers — lies in one explicit finite box.

That is a remarkable state of affairs. Modulo $abc$, Beal's conjecture becomes a *finite computation*. An unimaginably large one, since nobody knows a usable value of $K$, but finite in principle.

## The parallel universe where Beal is a theorem

There is a well-known dictionary between integers and polynomials: $\mathbb{Z}$ and $k[X]$ behave alike, with degree playing the role of size and irreducible polynomials the role of primes. In this parallel universe, the $abc$ conjecture is not a conjecture — it is the **Mason–Stothers theorem**, proved in the 1980s with an argument short enough to fit on a postcard, and crucially *without any error term $\varepsilon$*.

That missing $\varepsilon$ makes all the difference. Combining Mason–Stothers with the hyperbolicity inequality — in its multiplicative form, $yz + zx + xy \leq xyz$ for $x,y,z \geq 3$ — proves the polynomial analogue outright:

> **Polynomial Beal Theorem.** Let $k$ be a field of characteristic zero and let $a, b, c \in k[X]$ be nonzero polynomials with $a^x + b^y = c^z$ where $x, y, z \geq 3$. If not all of $a, b, c$ are constant, then $a$, $b$, $c$ have a common irreducible factor. Equivalently, if $a$ and $b$ are coprime then all three polynomials are constant.

The analogy even reproduces the examples. Scale the integer identity $3^3 + 6^3 = 3^5$ by $X^{15}$:

$$(3X^5)^3 + (6X^5)^3 = (3X^3)^5,$$

a genuine polynomial solution — and, exactly as the theorem demands, its three entries share the irreducible factor $X$.

This is the sharpest possible statement of where the difficulty in Beal's conjecture lies. It is *not* in the combinatorics of exponents, nor in the divisibility bookkeeping; those transfer verbatim to polynomials. It is in the error term. Over $\mathbb{Z}$ the additive and multiplicative structures are only *approximately* incompatible, and closing that approximation gap is the entire content of the $abc$ conjecture.

## What a counterexample would have to look like

Suppose, against expectation, that a counterexample exists. What do we know about it?

- Its bases are **pairwise coprime**, with no shared factor anywhere.
- Its exponents are **strictly hyperbolic**: $1/x+1/y+1/z \leq 11/12$, so at least one exponent exceeds $3$.
- Its exponents are **not all equal**, and indeed no common divisor of the three exponents can be $3$ or $4$.
- **Exactly one of $A$, $B$, $C$ is even.** If two were even, the third would be too (the collapse theorem), contradicting coprimality; and all three odd is impossible because odd $+$ odd $=$ even.
- If $C$ is the even one, then $x$ and $y$ **cannot both be even**. This is a mod-$8$ obstruction: an odd number raised to an even power is $\equiv 1 \pmod 8$, so $A^x + B^y \equiv 2 \pmod 8$; but $C$ even and $z \geq 3$ force $C^z \equiv 0 \pmod 8$, and $2 \neq 0$.
- It may be assumed to have all three exponents **odd primes or $4$**. Every $n \geq 3$ is divisible by an odd prime or by $4$, and replacing $A^x$ by $(A^{x/d})^d$ reduces exponents without disturbing anything. So the whole conjecture rests on a set of exponent triples of density zero.
- It is not small. Exhaustive search confirms that no coprime solution exists with $A, B \leq 10$, $C \leq 40$ and exponents in $\{3,4,5\}$ — and much larger searches have found nothing either.

Each item chips away at the space where a counterexample could hide. None of them, so far, closes it.

## Why it matters

Beal's conjecture is the cleanest modern statement of a very old theme: **addition and multiplication do not get along.** Perfect powers are objects of pure multiplicative structure; adding two of them is a violently non-multiplicative act. The empirical rule that the result is almost never a third perfect power, unless everything shares a factor and the whole equation is really a scaled-down smaller one, is the same phenomenon behind Fermat's Last Theorem, the Catalan conjecture ($8$ and $9$ are the only consecutive perfect powers, proved by Mihăilescu in 2002), and the $abc$ conjecture itself.

The results above make the shape of the problem unusually crisp. Beal's conjecture is:

- the high-exponent tail of Fermat–Catalan, and finite modulo that conjecture;
- confined to one explicit finite box modulo $abc$;
- strictly stronger than Fermat's Last Theorem;
- a theorem in the function-field world, where the error term vanishes.

Four independent perspectives that all say the same thing: the obstruction to a proof is not structural, it is quantitative. Somebody needs to prove that a sum of two coprime perfect powers cannot be enormously larger than the product of its distinct prime factors. Do that, and a million dollars — and a great deal more — falls out as a corollary.

Until then, the pattern Andrew Beal noticed on his computer in 1993 remains exactly what it was: an observation that has resisted every attempt to explain it, and every attempt to break it.
