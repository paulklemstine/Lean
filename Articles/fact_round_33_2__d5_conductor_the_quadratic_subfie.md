# The Number That Wasn't There: Why the Hidden Fingerprint of $x^5+20x+32$ Is 20, Not 320

*A story about a quintic polynomial, a statistical scan that found the right answer for the wrong reason, and the small arithmetic fact that tells them apart.*

---

## A polynomial that won't be solved but can be read

Nobody can solve the equation

$$x^5 + 20x + 32 = 0$$

using square roots, cube roots and fifth roots in the way we solve quadratics. That's not because nobody has tried hard enough. Ever since Abel and Galois, we have known that a typical quintic has no such formula. Galois gave the reason, and it is about symmetry. The five roots of a polynomial can be shuffled by the "hidden symmetries" of arithmetic, and together those shuffles form a group, the **Galois group**. A formula in radicals exists exactly when that group is built up from abelian pieces in a suitable way. For most quintics the group is the full symmetric group $S_5$, with all $120$ ways of shuffling five objects, and no radical formula exists.

Our polynomial is not typical. Its Galois group is only the **dihedral group** $D_5$: the ten symmetries of a regular pentagon. There are five rotations (including "do nothing") and five reflections. You can picture the five roots sitting at the corners of a pentagon. The only shuffles arithmetic allows are the ones that turn or flip that pentagon rigidly.

Inside $D_5$ the rotations form a subgroup of index two, the cyclic group $C_5$. A subgroup of index two always means there is a **fork**: every symmetry is either a rotation or a reflection, and nothing else. Galois theory turns this fork into something concrete. The splitting field of the polynomial contains exactly one **quadratic field**, one field of the form $\mathbb{Q}(\sqrt{d})$, and a symmetry is a rotation exactly when it fixes $\sqrt{d}$.

So the question is which $d$ it is. What is the hidden square root inside $x^5+20x+32$?

## Listening to primes

There is an experimental way to find out, and it is one of the nicest facts in number theory. Take a prime $p$ and reduce the polynomial modulo $p$. For example, with $p = 67$ you look for whole numbers $t$ between $0$ and $66$ for which $t^5 + 20t + 32$ is divisible by $67$. Each prime $p$ picks out one symmetry in the Galois group, up to relabelling. It is called the **Frobenius element** at $p$, and you can read it off from how many roots the polynomial has mod $p$:

- **5 roots:** Frobenius is the identity (the "do nothing" rotation).
- **0 roots:** Frobenius is a genuine rotation, which moves all five corners of the pentagon.
- **1 root:** Frobenius is a reflection, which fixes one corner and swaps the other four in pairs.

So every prime lands on one side of the fork: rotation (0 or 5 roots) or reflection (1 root). Now watch the primes. Below $3000$, leaving out the special primes $2$ and $5$, there are $428$ primes. Of these, $221$ give one root, $175$ give no roots and $32$ give five. The first few primes where the polynomial splits completely into five roots are $67, 103, 269, 283, 449, 509, \dots$

These proportions are not arbitrary. A deep theorem of Chebotarev says that each symmetry shows up as Frobenius with frequency proportional to how common it is in the group. $D_5$ has $5$ reflections, $4$ non-trivial rotations and $1$ identity, so the predicted frequencies are $\tfrac12 : \tfrac25 : \tfrac1{10}$. The observed $0.516 : 0.409 : 0.075$ is already close.

## The conductor scan

Here is the experiment that sets off our story. If the fork is controlled by a quadratic field $\mathbb{Q}(\sqrt{d})$, then whether $p$ is a rotation prime or a reflection prime should depend only on $p$ modulo some fixed number. This is a consequence of quadratic reciprocity. The smallest such number is called the **conductor**. For a quadratic field it equals the absolute value of the field's discriminant.

So one can run a "conductor scan". For each candidate modulus $m$, measure how much information the residue $p \bmod m$ carries about which side of the fork $p$ is on. Measured in bits, the answer is between $0$ (no information) and $1$ (it decides the fork completely). One such scan picked out $m = 320$. At that modulus the mutual information was $0.9999$ bits, one full bit, and the report concluded that the quadratic subfield has discriminant of absolute value $320$. The claim was named **THE-CONDUCTOR-IS-320**.

It sounds convincing, and it is wrong. It is wrong in an instructive way.

## First problem: 320 is not a discriminant of anything

Every quadratic field is $\mathbb{Q}(\sqrt{d})$ for a unique **squarefree** integer $d \ne 0,1$, meaning $d$ has no repeated prime factor. Its discriminant follows a simple rule:

$$
d(\mathbb{Q}(\sqrt d)) = \begin{cases} d, & d \equiv 1 \pmod 4,\\ 4d, & \text{otherwise.}\end{cases}
$$

Suppose a quadratic field had discriminant $\pm 320$. Since $320$ is even, it cannot be the case $d \equiv 1 \pmod 4$. So it must be $4d = \pm 320$, which means $d = \pm 80$. But $80 = 16 \cdot 5$ is divisible by $4^2$, so it is not squarefree. That is a contradiction.

**No quadratic field anywhere has discriminant $320$ or $-320$.** That rules out this polynomial's field and every other quadratic field too. The phrase "a quadratic subfield with $|d(K)| = 320$" describes nothing at all.

## Second problem: 20 does the whole job

So what did the scan actually detect? Look at the prime data directly. A prime $p \ne 2, 5$ turns out to be a rotation prime exactly when

$$
p \equiv 1,\ 3,\ 7,\ 9 \pmod{20}.
$$

This is exactly the set of primes for which $-5$ is a square mod $p$. In the notation of the Legendre–Jacobi symbol, $\left(\tfrac{-5}{p}\right) = +1$. The fork is the quadratic character of the field $\mathbb{Q}(\sqrt{-5})$, and the discriminant of that field, by the rule above with $d=-5 \equiv 3 \pmod 4$, is

$$
d(\mathbb{Q}(\sqrt{-5})) = 4\cdot(-5) = -20.
$$

The hidden square root inside $x^5+20x+32$ is $\sqrt{-5}$. This was checked prime by prime for every prime below $400$, and the numerical data confirm it for every prime below $3000$.

Why did $320$ light up in the scan? Because $320 = 16 \times 20$. If you know $p \bmod 320$, you know $p \bmod 20$, and $p \bmod 20$ already decides the fork. The same is true for $40$, $60$, $160$, and every other multiple of $20$. At all of these moduli the scan shows a full bit. At $m=64$ it shows about $0.0045$ bits, and at $m=16$ about $0.0007$. The scan found a multiple of the conductor and reported it as the conductor.

## The theorem that settles it

The whole situation comes down to one clean statement, which we call the **Minimal-Modulus Theorem**.

> **Theorem.** Let the *fork* of an odd integer $N$ be the Jacobi symbol $\left(\tfrac{-5}{N}\right)$. For a positive integer $m$, the fork is a function of $N \bmod m$ (whenever two odd integers agree mod $m$, their forks agree) **if and only if $20$ divides $m$.**

The "if" direction is quadratic reciprocity: the symbol $\left(\tfrac{-5}{N}\right)$ only depends on $N \bmod 20$. The "only if" direction is the interesting part, and its proof is short enough to give in full.

Suppose $20 \nmid m$. Then either $4 \nmid m$ or $5 \nmid m$.

- **If $5 \mid m$ but $4 \nmid m$:** let $L = \operatorname{lcm}(m,2)$. It is a multiple of $m$ that is even but still not divisible by $4$. Compare $N=1$ with $N' = 1 + 5L$. They agree mod $m$. But $5L \equiv 10 \pmod{20}$, so $N' \equiv 11 \pmod{20}$, and the fork of $11$ is $-1$ while the fork of $1$ is $+1$. So $N \bmod m$ cannot decide the fork.
- **If $5 \nmid m$:** compare $N = 1$ with $N' = 1 + (4m)^4$. They agree mod $m$. The number $(4m)^4$ is divisible by $4$, and by Fermat's little theorem it is $\equiv 1 \pmod 5$ because $5 \nmid 4m$. So $(4m)^4 \equiv 16 \pmod{20}$ and $N' \equiv 17 \pmod{20}$, where the fork is again $-1$.

In both cases two numbers that look the same mod $m$ fall on opposite sides of the fork. ∎

For example, with $m = 16$ the witnesses are $1$ and $1 + 64^4 = 16{,}777{,}217$. They agree mod $16$, but one is a rotation class and the other a reflection class.

The consequence is immediate. The moduli that decide the fork are exactly $20, 40, 60, 80, \dots$. The smallest one, the **conductor**, is $20$, and in particular it is not $320$. It also agrees with the conductor–discriminant formula: $20 = |d(\mathbb{Q}(\sqrt{-5}))|$.

## Anatomy of the number 20

Why $20$, and why is it $4 \times 5$? Quadratic reciprocity splits the fork into two independent pieces:

$$
\left(\frac{-5}{N}\right) = \chi_4(N)\cdot\left(\frac{N}{5}\right),
$$

where $\chi_4(N)$ is $+1$ for $N \equiv 1 \pmod 4$ and $-1$ for $N \equiv 3 \pmod 4$. The first factor only looks at $N \bmod 4$ and the second only at $N \bmod 5$. Each one alone carries essentially no information about the fork: the scan gives about $0$ bits at $m=4$ and at $m=5$. Only their *product* decides it, and seeing both at once means looking mod $\operatorname{lcm}(4,5) = 20$. The two witnesses in the proof above use this directly. One flips the $\chi_4$ factor while keeping $N \bmod 5$ fixed; the other flips the mod-$5$ factor while keeping $N \bmod 4$ fixed.

The polynomial fits this picture. Mod $5$ it collapses to a perfect fifth power, $x^5 + 20x + 32 \equiv (x+2)^5$, and mod $2$ it collapses to $x^5$. Those are the signatures of total ramification, and the primes $2$ and $5$ are exactly the primes dividing $20$. Its discriminant, computed from the classical trinomial formula $5^5 b^4 + 4^4 a^5$ with $a=20,\ b=32$, is

$$
5^5\cdot 32^4 + 4^4\cdot 20^5 = 4{,}096{,}000{,}000 = 64000^2 = \left(2^9\cdot 5^3\right)^2,
$$

a perfect square. That is exactly what a dihedral quintic requires, since $D_5$ contains only even permutations. It also means the quadratic subfield is *not* $\mathbb{Q}(\sqrt{\text{disc}})$, which would be trivial here. The square root has to be found some other way. The same is true for the whole family $x^5 + 20t^4x + 32t^5$ obtained by rescaling $x \mapsto x/t$, whose discriminant is always the square $(64000\,t^{10})^2$.

## Why this matters beyond one polynomial

It is tempting to think of an information scan as a measuring instrument: point it at the data and read off the answer. The instrument here worked. $I = 1$ bit at modulus $320$ is a true measurement. The mistake was reading "a modulus that works" as "the modulus that is minimal". The Minimal-Modulus Theorem shows the set of working moduli is not a scatter of lucky numbers. It is exactly the set of multiples of one number, the conductor, so the only correct reading of such a scan is its *smallest* full-bit modulus. The discriminant rule gives an independent sanity check that costs nothing: any claimed quadratic discriminant has to be a fundamental discriminant, and $320$ fails that test right away.

This pattern of periodic signals, a fundamental period hidden under its multiples, and the error of reporting a harmonic as the fundamental, will be familiar to anyone who has done spectral analysis in physics or signal processing. Here the "signal" is the sequence of Frobenius elements, the "frequency" is a modulus, and the fundamental is $20$.

## What remains open

Two things are proved outright: that no quadratic field has discriminant $\pm 320$, and that the character $\left(\tfrac{-5}{N}\right)$ has conductor exactly $20$. The identification of the fork of $x^5+20x+32$ with that character has been confirmed for every prime below $400$ by complete case-by-case checking, and numerically well beyond. Proving it for *all* primes needs one more ingredient from Galois theory: an explicit formula for $\sqrt{-5}$ as a polynomial expression in the five roots, so that one can see every Frobenius element acting on it through the rotation/reflection sign. Other natural next steps are to extend the minimal-modulus principle from $-20$ to every fundamental discriminant, and to watch the root-count frequencies approach the Chebotarev proportions $\tfrac12 : \tfrac25 : \tfrac1{10}$.

The headline is simple. The hidden square root of $x^5+20x+32$ is $\sqrt{-5}$, and its fingerprint is $20$. The value $320$ was a multiple of the conductor that the scan picked up, not the conductor itself.
