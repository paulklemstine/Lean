# Who Holds the Leash? Why the Number Field Sieve Escapes the Trap That Binds the Quadratic Sieve

*A story about factoring, squares, and the surprising freedom of choosing your own number system.*

---

## A puzzle with two locks

Multiply two large primes together and you get a number that is easy to write down and very hard to take apart. The security of RSA, the public-key system that still protects much of the world's encrypted traffic, rests on exactly that difficulty. Anyone who could split a 600-digit number $N = pq$ into its prime factors quickly could read the mail.

The two best-known general-purpose methods for that job are cousins. The **quadratic sieve** (QS) was the champion of the 1980s. The **number field sieve** (NFS) replaced it in the 1990s and still holds the records. Both rest on one old trick: find two numbers $X$ and $Y$ with

$$X^2 \equiv Y^2 \pmod N, \qquad X \not\equiv \pm Y \pmod N.$$

Then $N$ divides $(X-Y)(X+Y)$ without dividing either factor, so $\gcd(X-Y, N)$ is a proper factor of $N$. The algorithms differ only in how they *manufacture* such a congruence of squares, and that difference is the whole story of their speed.

The quadratic sieve runs in time roughly $L_N[1/2]$, and the number field sieve in time roughly $L_N[1/3]$, where

$$L_N[\alpha] = \exp\!\big(c\,(\ln N)^{\alpha}(\ln\ln N)^{1-\alpha}\big).$$

Going from exponent $1/2$ to $1/3$ is like going from walking to flying. For a 200-digit number it is the difference between "impossible" and "a big but feasible computation".

That speed difference is well known. This article is about a quieter, structural fact underneath it, which a recent line of analysis has pinned down exactly:

> **In the quadratic sieve, the integer being factored decides which primes are useful. In the number field sieve, a number *you choose* decides, and the integer being factored has no say at all.**

To see why, we need to look at the "columns" of a sieve.

---

## Columns: the primes that do the work

Both sieves gather many *relations*: numbers that factor completely over a small set of primes up to some bound $B$, the **factor base**. Each relation becomes a row of a big matrix over $\{0,1\}$ that records which primes appear to an odd power. Once there are more rows than columns, linear algebra finds a set of rows whose product is a perfect square, and out pops the congruence of squares.

The **columns** of that matrix are the primes that can actually turn up in relations. A prime that never divides a sieve value is a dead column: it costs nothing, but it also contributes nothing. So the column set is the sieve's real working vocabulary, and the question "what decides the column set?" is a question about what controls the algorithm.

---

## The quadratic sieve: slaved to $N$

In the quadratic sieve you look at values of the polynomial $x^2 - N$ for $x$ near $\sqrt N$. Which odd primes $r$ can divide such a value?

If $r$ divides $x^2 - N$, then $x^2 \equiv N \pmod r$, so $N$ must be a perfect square modulo $r$. Number theorists write this with the **Legendre symbol**: $(N/r) = +1$ means "$N$ is a nonzero square mod $r$", $(N/r) = -1$ means "it is not a square", and $(N/r)=0$ means $r$ divides $N$. So:

> **QS column theorem.** An odd prime $r \le B$ that does not divide $N$ divides some sieve value $x^2 - N$ exactly when $(N/r) = +1$.

The same holds for the homogeneous version used in practice. If $r \mid x^2 - Ny^2$ and $r$ divides neither $N$ nor $y$, then $(x/y)^2 \equiv N \pmod r$, which again forces $(N/r) = +1$.

So the set of useful primes for the quadratic sieve is

$$\mathcal C_{\mathrm{QS}}(N) = \{\, r \le B \text{ odd prime} : (N/r) = +1 \,\}.$$

About half the primes qualify, and **which** half is fixed by $N$, the very number you are trying to break. You cannot negotiate. Change $N$ and the columns change; keep $N$ and they are frozen. Indeed the column set depends only on the residues of $N$ modulo the factor-base primes, and those are part of the problem you were handed.

Concrete numbers make this vivid. With $B = 200$, count the odd primes $r \le 200$ at which $N$ is a nonzero square:

| $N$ | QS columns ($B = 200$) |
|---|---|
| $11$ | $20$ |
| $23$ | $19$ |
| $15$ | $21$ |
| $47$ | $25$ |

Different targets, different vocabularies. Earlier analysis had looked at several clever attempts to *decouple* the quadratic sieve's bookkeeping from $N$, ways of reweighting or repricing columns. Every one of them turned out to be provably closed, and for one shared reason: the split set is tied to $N$. That analysis ended by naming its own boundary. A method can only escape if its relations are *not* differences of squares tied to $N$.

That boundary has a name. It is the number field sieve.

---

## The number field sieve: a leash held by someone else

The number field sieve changes the arena. Instead of plain integers, it works in a ring of algebraic numbers. In the simplest quadratic version, that ring is

$$\mathbb Z[\sqrt d] = \{\, x + y\sqrt d : x, y \in \mathbb Z \,\},$$

where $d$ is an integer that **you pick**. The only requirement linking $d$ to $N$ is *validity*: the polynomial $t^2 - d$ must have a root $m$ modulo $N$, that is,

$$N \mid m^2 - d.$$

That root lets you map $\sqrt d \mapsto m$, which turns statements in $\mathbb Z[\sqrt d]$ into statements modulo $N$.

In this world the "primes" that make up columns are **prime ideals**, the right generalisation of primes to rings where unique factorisation of elements can fail. The useful ones, called *degree-one* prime ideals, correspond to ways of sending $\sqrt d$ to a square root of $d$ in the finite field $\mathbb F_r$ of integers modulo $r$. So the question "how many useful prime ideals lie above $r$?" becomes "how many square roots does $d$ have modulo $r$?" The answer is clean:

> **Degree-one prime count.** For an odd prime $r$, the number of ring homomorphisms $\mathbb Z[\sqrt d] \to \mathbb F_r$, which is the number of degree-one prime ideals above $r$, is exactly $1 + (d/r)$.

If $(d/r) = +1$ there are two of them, a conjugate pair: $\sqrt d \mapsto s$ and $\sqrt d \mapsto -s$. If $(d/r) = -1$ there are none, and $r$ is "inert". If $r \mid d$ there is exactly one, and $r$ "ramifies".

An element $x + y\sqrt d$ has *norm* $x^2 - dy^2$, and a relation lands in a prime ideal above $r$ exactly when $r$ divides that norm (with $r \nmid y$). So the NFS column set is

$$\mathcal C_{\mathrm{NFS}}(d) = \{\, r \le B \text{ odd prime} : (d/r) = +1 \,\}.$$

Look closely at that formula. **$N$ does not appear in it.** The leash is held by $d$.

The numbers bear this out. Take $d = -7$ and $B = 200$. There are $21$ odd primes $r \le 200$ with $(-7/r) = +1$, and $22$ if you count $r = 2$, which also splits because $-7 \equiv 1 \pmod 8$. Now notice that

$$2^2 + 7 = 11, \qquad 4^2 + 7 = 23,$$

so $d = -7$ is a valid field for **both** $N = 11$ (root $m = 2$) and $N = 23$ (root $m = 4$). For both targets the NFS column set is literally the same set of primes. The QS column sets for $11$ and $23$ have $20$ and $19$ elements and are not equal.

---

## The decoupling theorem: every pattern is on the menu

"The formula doesn't mention $N$" is a good slogan, but a skeptic will object. Validity, $N \mid m^2 - d$, *does* tie $d$ to $N$. Maybe that tie quietly restricts which column sets you can reach.

It does not, and this is the central result:

> **Decoupling Theorem.** Fix the integer $N$ to be factored, and even fix the root $m$. Let $S$ be the odd primes $r \le B$ that do not divide $N$. Then for **every** subset $T \subseteq S$ there is an integer $d$ that is valid for $N$ (so $N \mid m^2 - d$) whose NFS column set, restricted to $S$, is exactly $T$. All $2^{|S|}$ possible patterns occur.

The proof is a single application of the **Chinese Remainder Theorem**, which says that congruences modulo pairwise coprime moduli can be solved simultaneously. Validity is a condition modulo $N$. Whether $r$ is a column is a condition on $d$ modulo $r$. Because each $r \in S$ is coprime to $N$, and distinct primes are coprime to each other, these conditions never interfere. So:

1. Ask for $d \equiv m^2 \pmod N$. This makes $d$ valid.
2. For each $r \in T$, ask for $d \equiv 1 \pmod r$. Then $d$ is a nonzero square, so $r$ splits.
3. For each $r \in S \setminus T$, ask for $d \equiv u_r \pmod r$, where $u_r$ is any non-square modulo $r$. One always exists because $r$ is odd. Then $r$ is inert.

The Chinese Remainder Theorem hands back a single $d$ that satisfies all of these at once. That's the proof.

Compare the quadratic sieve. Its column set is *one* point in this space of $2^{|S|}$ possibilities. In fact it is precisely the member $d = N$, $m = 0$ of the NFS family, since $N \mid 0^2 - N$. **The quadratic sieve is the number field sieve with the one choice of field that the attacker does not get to make.**

---

## No free lunch: yield cancellation

So the attacker can choose the columns. Can they choose *more* of them, and pick a $d$ that makes every prime split?

On any finite factor base, yes: target $T = S$. On average, no. There is a conservation law:

> **Yield cancellation.** For an odd prime $r$, add up the number of degree-one prime ideals above $r$ over a full period of fields, $d = 0, 1, \ldots, r-1$. The total is exactly $r$, so on average one per field.

The reason is that the Legendre symbols $(d/r)$ over a full period sum to zero, since there are as many squares as non-squares, so $\sum_d \big(1 + (d/r)\big) = r$. Choosing $d$ *redistributes* split primes; it does not create them out of nothing. The freedom is real but zero-sum on average, and the price of a lopsided choice shows up elsewhere. The Chinese Remainder construction above produces $d$ of size up to $N\cdot\prod_{r\in S} r$, and bigger $d$ means bigger norms that are harder to factor.

---

## Where did the coupling go?

Validity has to constrain $d$ *somewhere*. It does, just not where it matters for the columns:

> **Residual coupling.** If $d$ is valid for $N$, then at every prime $p$ dividing $N$ with $p \nmid d$, we have $(d/p) = +1$. Conversely, for a prime $p \nmid d$, a root of $t^2 - d$ modulo $p$ exists exactly when $(d/p) = +1$.

So the tie to $N$ has not vanished. It has **moved** onto the hidden prime factors of $N$, the very primes the attacker cannot see and that never sit in the factor base. On the factor base the coupling is gone. This is the precise sense in which NFS escapes: the dependence on $N$ has been pushed off to places where it does not constrain the sieve.

---

## Why this matters

There is a long-standing intuition that the number field sieve wins because it works with *smaller numbers*. With a well-chosen polynomial of growing degree, its values are of size $N^{o(1)}$, while QS values are of size about $\sqrt N$. That intuition is correct. The analysis here adds a complementary, structural explanation of *what kind of freedom* NFS enjoys:

- In the quadratic sieve, every lever you might pull, whether the choice of columns, the weighting of primes, or the large-prime bookkeeping, is ultimately governed by Legendre symbols $(N/r)$. Those are fixed by the problem. That is exactly why every attempted QS "decoupling channel" turned out to be provably closed.
- In the number field sieve, the corresponding quantities are governed by $(d/r)$, where $d$, and in full NFS the whole defining polynomial, is chosen by the attacker. A per-instance lever there is **not slaved to $N$**.

To be clear about scope: none of this is a new algorithm or a new running-time exponent. The $L[1/3]$ bound for NFS is decades old, and this analysis treats only the quadratic model $\mathbb Z[\sqrt d]$ of the ideal sieve. What it contributes is a *mechanism*. It explains why the quadratic-sieve channels are closed (the split set is tied to $N$), it identifies the one escape (the split set is tied to a free choice of field), and it gives a precise count of that freedom: all $2^{|S|}$ patterns, at a zero-sum average yield.

---

## Coda: a picture to keep

Imagine a row of light bulbs, one for each small prime. In the quadratic sieve the switchboard is welded shut. The number $N$ you were handed decides which bulbs glow, and that is that. In the number field sieve you walk up to the switchboard and set every switch however you like, as long as you also pay the electricity bill (bigger norms). The only wires you cannot touch run to bulbs hidden behind the wall, the secret primes $p$ and $q$. Those are forced on, quietly confirming that your chosen field really does see $N$.

That one welded-versus-free switchboard is a structural reason the faster algorithm is free to be faster.
