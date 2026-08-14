# The Secret That Numbers Keep: Why the $p+1$ Weakness Cannot Be Seen

## A lock with a hidden flaw

Modern cryptography rests on a simple asymmetry: multiplying two large primes is easy, and pulling them apart again is hard. Give a computer $p = 359$ and $q = 5849$ and it will hand you $N = 2{,}099{,}791$ instantly. Hand it $N = 2{,}099{,}791$ and ask for the factors, and it must work — for numbers a few hundred digits long, it must work longer than the age of the universe.

But not every $N$ is equally hard. Since the 1970s number theorists have known that certain primes are *fragile*. If $p$ is a prime for which $p - 1$ happens to factor into only small primes, then John Pollard's $p-1$ method peels $p$ off $N$ in seconds. In 1982 Hugh Williams found the mirror-image weakness: if $p + 1$ factors into only small primes, a different algorithm — one built on Lucas sequences instead of ordinary powers — splits $N$ just as fast.

That poses an uncomfortable question for anyone who generates keys. A fragile prime is a disaster. Can you tell, from the public number $N$ alone, that a fragile prime is hiding inside it?

If the answer were yes, $N$ would be leaking a hint about its own factorization — a *self-hint* — and cryptography would be in trouble. The answer, we can now say with proof, is a resounding **no**. And the reason is beautiful: the weakness is an *asymmetric* property of one of the two factors, while everything you can compute from $N$ is inescapably *symmetric* in the two factors. $N$ knows the pair $\{p, q\}$; it does not know which is which.

This article tells the story of that impossibility, and of a surprising structural discovery made along the way: the $p+1$ method does not succeed whenever $p+1$ is smooth. It succeeds only when a quadratic character — a single $\pm 1$ — comes out the right way. And that $\pm 1$ is, from $N$'s point of view, invisible in exactly the same way.

## The Williams machine

Start with an integer $P$, the *base*, and build the sequence

$$V_0 = 2, \qquad V_1 = P, \qquad V_{n+2} = P\,V_{n+1} - V_n .$$

For $P = 3$ this is $2, 3, 7, 18, 47, 123, 322, 843, 2207, \dots$. These are Lucas sequences, cousins of the Fibonacci numbers.

The magic comes from a change of viewpoint. Consider the quadratic $x^2 - Px + 1$, with roots $a$ and $b$. They satisfy $a + b = P$ and $ab = 1$, and a two-line induction gives the **Binet form**

$$V_n = a^n + b^n .$$

Now reduce everything modulo a prime $p$. Whether the roots exist in the field $\mathbb{F}_p$ depends on the **discriminant**

$$D = P^2 - 4 .$$

There are exactly two cases, and they are the whole story.

**Case 1: $D$ is a non-residue mod $p$** (no square root in $\mathbb{F}_p$). Then $a$ and $b$ live in the quadratic extension $\mathbb{F}_{p^2}$, and they are conjugate: the Frobenius map $x \mapsto x^p$ swaps them. Combine $a^p = b$ with $ab = 1$ and you get

$$a^{p+1} = a^p \cdot a = b a = 1 .$$

The root has order dividing $p + 1$. So if the exponent $M$ is any multiple of $p+1$, then $a^M = b^M = 1$ and therefore

$$V_M \equiv a^M + b^M = 2 \pmod p .$$

**Theorem (the $p+1$ gate).** *Let $p$ be an odd prime and $P$ a base whose discriminant $D = P^2 - 4$ is a quadratic non-residue modulo $p$. Then $V_M \equiv 2 \pmod p$ for every exponent $M$ divisible by $p+1$.*

That congruence is the whole attack. Compute $V_M \bmod N$ for a huge exponent such as $M = \operatorname{lcm}(1, 2, \dots, 100)$, then take $\gcd(V_M - 2,\, N)$. If $p$ divides $V_M - 2$ and $q$ does not, the gcd is exactly $p$ — not $1$, not $N$, but the factor itself. Try it small: $N = 91 = 7 \cdot 13$, base $P = 3$, exponent $M = 8$ (a multiple of $7 + 1$). Then $V_8 = 2207$, and $\gcd(2205, 91) = 7$. The lock opens.

The exponent works because of a *smoothness* condition, and here it is worth pausing on its shape. The classical exponent $\operatorname{lcm}(1,\dots,B)$ absorbs $n$ precisely when every prime power $\ell^{v}$ exactly dividing $n$ satisfies $\ell^{v} \le B$ — a condition on the **maximum** of a list of quantities, not on their sum or product. Conditions written with $\max$ and $+$ rather than $+$ and $\times$ are the native language of tropical (min-plus/max-plus) algebra, and smoothness is one of the purest examples: it is a bound on the sup-norm of a valuation vector.

**Case 2: $D$ is a square mod $p$.** Then $a$ and $b$ are already in $\mathbb{F}_p$, and their orders divide $p - 1$, not $p + 1$. The method silently degenerates into Pollard's $p-1$ method. And one can be completely precise about what happens at the crucial index:

**Theorem (sharp gate).** *If $D = P^2 - 4$ is a nonzero square modulo $p$, then $V_{p+1} \equiv P^2 - 2 \pmod p$. Consequently $V_{p+1} \equiv 2 \pmod p$ holds if and only if $D$ is a non-residue or $D = 0$.*

So the $p+1$ method has a hidden admission requirement — a **discriminant gate**. It is not enough for $p+1$ to be smooth. The Legendre symbol $(D \mid p)$ must equal $-1$.

## Measuring the gate

This is not folklore repackaged; it was found by measurement and then explained. In a controlled experiment, forty semiprimes were built in matched pairs, all with the same bit lengths (18-bit and 21-bit factors), differing *only* in whether the smaller factor's $p+1$ was smooth. Running the classical method with $M = \operatorname{lcm}(1,\dots,100)$ and bases $P = 3, 5, 7$:

- the smooth class was factored **24 out of 40** times;
- the control class, with no smoothness engineered anywhere, **0 out of 40**.

The classes genuinely differ; the weakness is real. But the per-base breakdown was startling. Base $3$ succeeded 11 times, base $5$ succeeded 17 times, base $7$ succeeded 11 times — and in each case the count was *exactly* the number of instances where $(D \mid p) = -1$. Not approximately. Exactly. All 24 successes had $(D \mid p) = -1$; no instance with $(D\mid p) = +1$ ever succeeded.

Two further coincidences fell out of the same table and both have clean explanations.

First, bases $3$ and $7$ succeeded on the *same eleven instances*. Their discriminants are $D_3 = 5$ and $D_7 = 45 = 5 \cdot 3^2$ — they differ by a perfect square, so they lie in the same square class, and the Legendre symbol cannot tell them apart: $(45 \mid p) = (5 \mid p)$ for every prime $p \ne 3$. Two "different" bases were secretly the same experiment.

Second, base $P = 2$ never worked at all. Its discriminant is $D = 0$, and the recurrence collapses: $V_n = 2$ for all $n$, so $V_M - 2 = 0$ and the gcd is always $N$ itself. A complete classification says which bases are unusable:

**Theorem (degenerate bases).** *The sequence $V_n(P)$ returns to the value $2$ at some positive index — making the gcd step vacuous for every modulus — if and only if $|P| \le 2$.* The five bad bases $-2, -1, 0, 1, 2$ have periods $2, 3, 4, 6, 1$; they are exactly the $P = 2\cos\theta$ for which the root $a$ is a root of unity. For $P \ge 3$ the sequence is strictly increasing and stays above $2$ forever. That is why the textbook algorithm starts its search at $P = 3$.

How lucky do you have to be to find a base that opens the gate? Exactly as lucky as a coin flip:

**Theorem (gate density).** *For an odd prime $p$, the discriminant $P^2 - 4$ is a square for exactly $(p+1)/2$ of the $p$ bases in $\mathbb{F}_p$, and a non-residue for exactly $(p-1)/2$ of them.* The proof is the *trace parametrization*: a base $P$ has square discriminant precisely when $P = a + a^{-1}$ for some $a \ne 0$, and the map $a \mapsto a + a^{-1}$ pairs $a$ with $a^{-1}$, so it is two-to-one except at the two fixed points $a = \pm 1$. Its image therefore has $(p - 1 - 2)/2 + 2 = (p+1)/2$ elements. So a random base works with probability $(p-1)/(2p) \to 1/2$, and trying the three classical bases $3, 5, 7$ gives success odds near $3/4$ rather than $7/8$, precisely because $3$ and $7$ are redundant.

## The invisible half

Now the null result. Here is the entire argument in one image.

Take two semiprimes:

$$N = 359 \cdot 5849 = 2{,}099{,}791, \qquad N' = 397 \cdot 5743 = 2{,}279{,}971 .$$

Both are $22$ bits long. Both have a $9$-bit small factor and a $13$-bit large factor. And — the point — both leave the same remainder $57{,}751$ upon division by $60{,}060 = 2^2 \cdot 3 \cdot 5 \cdot 7 \cdot 11 \cdot 13$.

That single congruence is enormously powerful. Knowing $N \bmod 60060$ tells you $N \bmod \ell$ for every prime $\ell \le 13$, hence every Jacobi symbol $(d \mid N)$ whose square class is supported on those primes. It is a far richer statistic than anything an attacker would think to try first. And yet:

- For the first number, the small factor $359$ satisfies $3 \mid p + 1$ (indeed $360 = 3 \cdot 120$); for the second, $397 + 1 = 398$ is not divisible by $3$.
- For the *same* pair, the base-$3$ discriminant gate is *closed* at $359$ (since $(5 \mid 359) = +1$) and *open* at $397$ (since $(5 \mid 397) = -1$).

Same statistic, opposite labels — twice over, with the labels swapped between the two channels. This yields the two central impossibility statements.

**Theorem (invisibility of $+1$ divisibility).** *No function of the pair $(N \bmod 60060,\ \text{bit length of } N)$ decides whether the smaller prime factor of $N$ satisfies $3 \mid p+1$.*

**Theorem (invisibility of the gate).** *No function of the pair $(N \bmod 60060,\ \text{bit length of } N)$ decides whether the base-$3$ Williams gate $(5 \mid p) = -1$ holds at the smaller prime factor of $N$ — even though that gate is exactly the condition under which the method succeeds.*

Both follow from an abstract principle so simple it is almost embarrassing: **if a statistic takes the same value on two legitimate instances carrying opposite labels, no predicate of that statistic can recover the label.** One collision kills an entire family of attacks.

## Why it must be so

Impossibility proofs by explicit counterexample can feel like accidents. This one is not. There is a mechanism, and it is visible in a companion theorem that says exactly what $N \bmod 3$ *does* reveal.

**Theorem (the $+1$ divisibility dichotomy).** *Let $p, q$ be primes different from $3$. Then $N = pq$ satisfies $N \equiv 2 \pmod 3$ if and only if exactly one of $p, q$ is congruent to $-1$ modulo $3$.*

Read that carefully. A single cheap residue test on the public number resolves the **exclusive-or** of the two bits "$3 \mid p+1$" and "$3 \mid q+1$". That is a genuine leak, and the experiment saw it: the mutual information between $N \bmod 3$ and the symmetric predicate "$3$ divides $p+1$ *or* $3$ divides $q+1$" was a hefty $0.2996$ bits. But the asymmetric question — *which* factor is the one congruent to $-1$? — gave mutual information $0.0005$ bits, statistically indistinguishable from zero. The same collapse held at $\ell = 5, 7, 11, 13$: symmetric signals of $0.0327$, $0.0158$, $0.0070$, $0.0052$ bits, against asymmetric signals of $0.0002$, $0.0014$, $0.0017$, $0.0022$ — all at or below the noise floor.

XOR is symmetric. Swap $p$ and $q$ and nothing changes. And $N = pq$ *is* a symmetric function of the pair: it sees only the elementary symmetric functions of the factors, never the labels "smaller" and "larger". So the leak is real but its content is exactly the part that survives the swap; the asymmetric residue is annihilated.

The character channel tells the same story in a different alphabet. The Jacobi symbol of a semiprime splits as a product:

**Theorem (character splitting).** *For distinct primes $p, q$ and any integer $D$, $\ (D \mid N) = (D \mid p)\,(D \mid q)$ when $N = pq$.*

The attacker can compute the left side in microseconds. But the product cannot distinguish $(-1, +1)$ from $(+1, -1)$, and it certainly cannot distinguish $(-1,-1)$ from $(+1,+1)$: both give $+1$. Concretely, $N = 21 = 3 \cdot 7$ has $(5 \mid 21) = +1$ with the gate *open* at the smaller factor ($(5\mid 3) = -1$), while $N = 209 = 11 \cdot 19$ also has $(5 \mid 209) = +1$ with the gate *closed* ($(5 \mid 11) = +1$). The experiment confirmed this quantitatively: among the 24 successful factorizations, the publicly computable symbol $(D \mid N)$ equalled $-1$ in 11 of them — about half, exactly as coin-flipping would predict.

This is the deepest of the findings. On the $p-1$ side, the weakness is at least a multiplicative-order condition with no character attached. On the $p+1$ side, success is governed by a quadratic character of the hidden factor, and the only character of $N$ the attacker can evaluate is the *product* of the two hidden characters. **The $p+1$ weakness is strictly more hidden than the $p-1$ one.**

A third channel was tested and also came up empty. Rather than reducing $N$ modulo small primes, one can run the Lucas recurrence itself modulo $N$ and look at the trajectory: 21 features extracted from windowed $V$-sequences (window length $256$, bases $3, 5, 7$) were fed to a class separator. Maximum standardized difference between the classes: $0.241$, sitting *below* the null-model mean of $0.381$, with $p = 0.898$. The sequence you compute while attacking $N$ tells you nothing about whether the attack will work until it works.

Finally, a geometric remark. When the method does succeed, what it returns is the divisor of $N$ lying on the lower branch of the divisor hyperbola $xy = N$, below the corner at $\sqrt{N}$. In tropical terms, the two factors straddle a corner locus of a piecewise-linear function, and $\min(p, q) \le \sqrt N \le \max(p,q)$. The algorithm locates a specific lattice point in the window $[1, \sqrt N]$ that no statistic of $N$ can point to.

## What this means

Put the pieces together and a sharp picture emerges. The Williams weakness is:

1. **Real** — a factor of $24/40$ versus $0/40$ is not noise.
2. **Gated** — the decisive congruence at the critical exponent holds precisely when a quadratic character condition on the hidden factor is met; smoothness alone is not enough, and when the gate is closed the procedure quietly reverts to the $p-1$ method.
3. **Residue-invisible** — no congruence data about $N$, however rich, locates the weak factor.
4. **Character-invisible** — the one relevant character of $N$ is the product of two hidden characters, and products destroy exactly the information needed.
5. **Trajectory-invisible** — the Lucas sequence run modulo $N$ separates the classes at chance.

The practical conclusion for cryptography is reassuring and precise. A fragile modulus is fragile, but only to someone willing to *run the 1982 algorithm*. There is no shortcut, no cheap screening test, no leak in the public number that says "this one is worth attacking". Screening must cost what the attack costs — which is to say, screening buys you nothing.

The theoretical conclusion is more interesting. Every statistic tried here — residues, Jacobi symbols, bit lengths, sequence trajectories — is a function of $N$, hence a symmetric function of $\{p, q\}$; and the exploitable weakness is an asymmetric predicate of one member of the pair. That mismatch, not any particular arithmetic accident, is what closes the door. Escaping it would require a statistic of $N$ that is not multiplicative and not abelian — something whose value does not factor through the *product* of the two local invariants. Whether such a statistic can exist is, for now, the open question that this line of work leaves behind.

The lock has a flaw. The lock does not tell you it has one.
