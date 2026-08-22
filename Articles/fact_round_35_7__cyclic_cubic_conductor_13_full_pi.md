# The Prime That Tells You Everything — and Nothing

## How a thirteen-element clock decides the fate of every prime number, and why it still refuses to name names

There is a small, stubborn fact about the number $13$ that has been sitting in plain sight since the nineteenth century, and it has a modern moral about information that is worth telling.

Take a prime number — any prime other than $13$ itself. Say $p = 5$, or $p = 7$, or $p = 1000003$. Now ask a question that sounds hopelessly abstract: *inside a certain very rigid algebraic world attached to $13$, does $p$ break apart, or does it stay whole?*

The remarkable answer is that you can decide this by doing one thing only: divide $p$ by $13$ and look at the remainder. Nothing else about $p$ matters. Not its size, not its decimal digits, not its distance to the next prime. The remainder mod $13$ is a **complete** answer key.

That is the phenomenon we will call **full pinning**, and the point of this article is to say exactly how much information is being pinned — the answer is $0.9183$ bits, and not a hair more or less — and then to watch that information behave in some very surprising ways when you multiply two primes together.

---

## The world attached to 13

The rigid algebraic world in question is a **cyclic cubic field**: a number system built out of the rational numbers by adjoining a single new quantity $\alpha$ that satisfies a cubic equation, in such a way that the three solutions of that equation are all expressible in terms of one another. For $13$ the relevant equation can be taken to be
$$x^3 + x^2 - 4x + 1 = 0 .$$
Its three roots are "periods" built from the thirteenth roots of unity, and each one is a polynomial in the others. That mutual expressibility is what the word *cyclic* means: the symmetries of this world form a cyclic group of order $3$, a three-position dial with no other structure.

Inside such a world every ordinary prime $p$ has to do one of a small number of things. It may **split completely**, dissolving into three distinct prime factors of the bigger system. It may stay **inert**, remaining a single indivisible prime. In principle a prime could also *ramify*, collapsing several factors into one — but for our field this happens only for $p = 13$, the lone exceptional prime, called the **conductor**.

So there are exactly **two behaviours**, two "types":
$$T(p) = \begin{cases}\textsf{split} & p \text{ dissolves into three primes},\\[2pt] \textsf{inert} & p \text{ stays whole}.\end{cases}$$

And here is the classical miracle, a special case of the reciprocity laws of class field theory: **$T(p)$ depends only on $p \bmod 13$**. Precisely, $p$ splits exactly when $p$ is a nonzero *cube* modulo $13$, i.e. when
$$p \bmod 13 \in \{1, 5, 8, 12\},$$
and $p$ is inert otherwise. Four of the twelve nonzero residues are cubes; the remaining eight are not.

Try it. $p = 5$: five is on the list, so $5$ splits into three primes. $p = 7$: seven is not on the list, so $7$ stays inert. $p = 1000003$: divide by $13$, remainder $1$ — it splits. You have just predicted the factorisation behaviour of a seven-digit prime inside a cubic number field using a single division.

---

## Weighing the answer in bits

Because the residues of primes mod $13$ are equidistributed — Dirichlet's theorem, in its quantitative form, guarantees that each of the twelve nonzero classes catches asymptotically the same share of primes — the type $T$ is a genuine random variable with
$$\Pr[T = \textsf{split}] = \tfrac{4}{12} = \tfrac13, \qquad \Pr[T = \textsf{inert}] = \tfrac{8}{12} = \tfrac23 .$$

Its **Shannon entropy** — the average number of yes/no questions needed to learn the type, the honest measure of how much surprise the type carries — is
$$H(T) = -\tfrac13\log_2\tfrac13 - \tfrac23\log_2\tfrac23 = \log_2 3 - \tfrac23 = 0.918295834\ldots \text{ bits}.$$

It is not one bit. A fair coin would be one bit; this coin is biased $1{:}2$, so it is slightly cheaper to describe.

Now the sharp statement. Let $R = p \bmod 13$ be the residue. The **mutual information** $I(R;T)$ measures how much of the type is revealed by the residue. Since $T$ is literally a function of $R$, nothing is lost:

> **Full Pinning Theorem.** For the cyclic cubic field of conductor $13$, the splitting type of a prime is determined by its residue modulo $13$, and consequently
> $$I(p \bmod 13\,;\,T) = H(T) = \log_2 3 - \tfrac23 \text{ bits},$$
> with conditional entropy $H(T \mid p \bmod 13) = 0$.

"Full pinning" is the statement that the residual uncertainty is exactly zero — not small, not asymptotically negligible, but zero. The thirteen-hour clock is a lossless channel for this particular question.

One more surprise: **the conductor barely matters.** Run the same construction with any prime conductor $f$ for which $3$ divides $f - 1$ — that is $f = 7, 13, 19, 31, 37, \dots$ — and you get the same two types with the same probabilities $1/3$ and $2/3$, hence the same $0.918296$ bits. The number $13$ is a *representative*, not a special case. The reason is structural: whatever the conductor, the symmetry dial has three positions, the splitting types correspond to "the dial reads zero" versus "the dial reads something else", and the primes distribute uniformly over the dial. Any two conductors give **uniform covers** of the same three-position dial, and a uniform cover cannot change a probability. That single observation, once made properly, proves far more than the entropy is stable: *every* averaged quantity built from the type distribution — every Rényi entropy, every moment, every functional whatsoever — is conductor-independent.

---

## Enter the semiprime: information that survives multiplication

Cryptography taught everyone to care about **semiprimes**: numbers $n = pq$ that are the product of two primes. Ask the natural question. If I hand you $n$, and you compute its splitting type $T(n)$ — one division by $13$ — how much do you learn about the *pair* of types $\{T(p), T(q)\}$ of the hidden factors?

Set up the arithmetic. The residue classes mod $13$, taken up to cubes, form a three-position dial $C_3 = \{0,1,2\}$, and the dial reading of a product is the *sum* of the dial readings:
$$g(n) = g(p) + g(q) \pmod 3 .$$
A number is split exactly when its dial reads $0$. So the observable $T(n)$ is the indicator of $g(p) + g(q) = 0$.

With $g(p), g(q)$ independent and uniform on $\{0,1,2\}$, the nine equally likely configurations sort themselves out beautifully:

- Both factors split, $(0,0)$, probability $1/9$: the product is split, with certainty.
- Exactly one factor split, probability $4/9$: the sum is nonzero, so the product is inert, with certainty.
- Both factors inert, probability $4/9$: the two dials read $1$ or $2$, and the sum vanishes precisely when they read *opposite* values — which happens half the time. The product is a coin flip.

Feeding this into the definition of mutual information gives an exact closed form:

> **Semiprime Pairing Theorem.** For a semiprime $n = pq$ with independent factors,
> $$I\big(T(n)\,;\,\{T(p),T(q)\}\big) = \log_2 3 - \tfrac{10}{9} = 0.473851389\ldots \text{ bits},$$
> and the information *lost* relative to full pinning is exactly the rational number
> $$H(T) - I_{\text{pair}} = \tfrac49 .$$

That $4/9$ is the third bullet above wearing a suit: with probability $4/9$ you land in the "both inert" configuration, and there you burn a full bit of uncertainty. The defect is rational because the ambiguous case is an exactly fair coin.

The defect being rational is a genuine coincidence of small numbers, and it is worth savouring, because it stops immediately. Repeat the whole construction in a cyclic field of prime degree $q$ (degree $3$ was our case): now there are still two types, split with probability $1/q$ and inert with probability $(q-1)/q$, the entropy is
$$H(T_q) = \log_2 q - \tfrac{q-1}{q}\log_2 (q-1),$$
and the pairing defect works out to
$$H(T_q) - I_{\text{pair}}(q) = \frac{(q-1)^2}{q^2}\left[\log_2(q-1) - \frac{q-2}{q-1}\log_2(q-2)\right].$$

> **Rigidity of the Rational Defect.** The pairing defect is a rational number if and only if the degree $q$ is $2$ or $3$. For every prime degree $q \ge 5$ it is irrational. Likewise, the type entropy $H(T_q)$ is rational only for $q = 2$; in particular the conductor-$13$ value $\log_2 3 - 2/3$ is irrational.

The proof of irrationality is not analytic and needs no heavy transcendence machinery. Suppose $\log_2 q - \frac{q-1}{q}\log_2(q-1)$ were a rational number $a/(qb)$. Clear denominators and exponentiate: you obtain the integer identity
$$q^{\,qb} = 2^{\,a}\,(q-1)^{\,(q-1)b}.$$
But $q$ and $q-1$ are consecutive integers, hence coprime, and $q$ is an odd prime, so the odd prime $q$ divides the left side and cannot divide the right. Contradiction, unless the exponent $qb$ vanishes. The same trick — clear to an integer identity, then let unique factorisation and the coprimality of consecutive integers do the killing — handles the defect, where the pair $(q-1, q-2)$ takes over the role of $(q, q-1)$. Small numbers are rational by accident; large ones cannot be.

---

## The wall: what the observable will never tell you

Now the result that gives the story its punch line. Suppose you have learned everything the observable can tell you: you know $n = pq$, you know $T(n)$, and — grant yourself even more — you know the unordered pair $\{T(p), T(q)\}$, say "one splits and one is inert". One question remains, and it is the only question a factoriser actually cares about:

**Which one is which?**

> **The Which-Factor Wall.** The mutual information between the observable data and the identity of which factor carries which type is **exactly zero**:
> $$I\big(\text{observable}\,;\,\text{which factor}\big) = 0 .$$
> Consequently, the optimal decoder for "which factor is the split one" succeeds with probability exactly $1/2$ — the coin-flip rate — and no strategy does better.

Note the word *exactly*. Not $10^{-4}$, which is what a finite experiment reports when it is estimating a zero from noisy samples. Zero.

The reason is a symmetry argument of the cleanest kind. Consider the operation that relabels the factors — swaps the roles of $p$ and $q$, or more generally rotates the hidden labels cyclically. This relabelling **fixes every observable**: the product $n$ is unchanged, its dial reading is unchanged, the unordered pair of types is unchanged. But it moves the hidden variable transitively: any label can be carried to any other. A quantity that is constant on the observable side and uniformly shuffled on the hidden side has, conditionally on the observation, a uniform hidden distribution — and uniform means zero information.

> **The Cyclic Wall, in general.** Whenever a group acting freely and transitively on a hidden label leaves every observable invariant, the mutual information between observation and hidden label is exactly zero.

That is a *structural* zero, not a numerical one. It is the information-theoretic shadow of the fact that multiplication forgets order. And it is a small, exact instance of the folklore intuition behind factoring-based cryptography: local, cheap, congruence-style observations of $n$ can be extremely informative about *aggregate* properties of its factors, while contributing literally nothing to the asymmetry you would need to separate the factors.

---

## A ladder of fields, a ladder of bits

The cubic field is one rung of a ladder. Inside the world generated by the thirteenth roots of unity, there is exactly one subfield of each degree dividing $12$: degrees $1, 2, 3, 4, 6, 12$. Each rung has its own notion of splitting type — the *residue degree*, the order of the residue class $p$ inside the corresponding cyclic dial of size $d$ — and hence its own entropy
$$H(T_d) = -\sum_{e \mid d} \frac{\varphi(e)}{d}\,\log_2\frac{\varphi(e)}{d},$$
where $\varphi$ is Euler's totient. Climbing the ladder, one never loses information: a larger field refines the observation, and the entropies increase. The numbers at conductor $13$ are:

| degree $d$ | $1$ | $2$ | $3$ | $4$ | $6$ | $12$ |
|---|---|---|---|---|---|---|
| $H(T_d)$ (bits) | $0$ | $1$ | $\log_2 3 - \tfrac23 \approx 0.9183$ | $\tfrac32$ | $1 + \log_2 3 - \tfrac23 \approx 1.9183$ | $\tfrac32 + \log_2 3 - \tfrac23 \approx 2.4183$ |

Two exact laws are visible in that row, and both are theorems.

> **Multiplicativity across coprime degrees.** If $m$ and $n$ are coprime, then $H(T_{mn}) = H(T_m) + H(T_n)$.

The dial of size $mn$ factors as a product of dials of size $m$ and $n$, and the two coordinates are independent — the Chinese Remainder Theorem, promoted from arithmetic to information. This is why the degree-$6$ entropy is exactly the degree-$2$ entropy plus the degree-$3$ entropy, and the degree-$12$ entropy is the degree-$4$ plus the degree-$3$.

> **Prime-power saturation.** For a prime $p$ and exponent $e \ge 1$,
> $$H(T_{p^e}) = C(p)\left(1 - p^{-e}\right), \qquad C(p) = \frac{p\log_2 p}{p-1} - \log_2(p-1).$$

Each additional power of $p$ in the degree buys you a geometrically shrinking slice of new information, and the total is capped at $C(p)$ forever. For $p = 2$, $C(2) = 2$ bits exactly, and the tower reads $1, \tfrac32, \tfrac74, \tfrac{15}{8}, \ldots$ — the rational gaps $1$ and $\tfrac12$ visible in the table above, and the gap $\tfrac32$ from the cubic field to the full cyclotomic field. For $p = 3$, $C(3) = \tfrac32\log_2 3 - 1 = 1.377444\ldots$, and the first rung of that tower is our $0.918296$.

So the arithmetic of $13$ carries a tidy little information filtration: rational gaps in the $2$-direction, irrational ones in the $3$-direction, and exact additivity between them.

---

## Every kind of entropy, one answer

A cautious reader might suspect that Shannon entropy is just one lens and that a different lens would see the conductors differ. It does not. The **Rényi entropy of order $a$**, defined by
$$H_a = \frac{1}{1-a}\log_2\!\left(\sum_v p_v^{\,a}\right),$$
interpolates between counting ($a=0$), Shannon ($a\to1$), collision ($a=2$) and the min-entropy ($a\to\infty$). For the cubic channel at conductor $13$ — indeed at any admissible conductor —
$$H_a = \frac{1}{1-a}\log_2\!\left(\left(\tfrac13\right)^{a} + \left(\tfrac23\right)^{a}\right),$$
so $H_0 = 1$ bit (there are two types), $H_1 = \log_2 3 - \tfrac23$, and the collision entropy is
$$H_2 = -\log_2\left(\tfrac19 + \tfrac49\right) = \log_2 \tfrac95 = 0.847997\ldots$$
The inequality $H_2 < H_1$ is forced, as it must be, and its proof collapses to a comparison of two integers: clearing logarithms in $\log_2\frac95 < \log_2 3 - \frac23$ turns it into $27 \cdot 4 < 125$, that is, $108 < 125$. It is pleasing that the entire ordering of two transcendental-looking quantities rests on seventeen units of slack between two three-digit integers.

---

## What it all means

Strip away the number theory and a clean picture remains, and it is a picture about the shape of information rather than about $13$.

There is a **channel** — nature's map from a prime to its algebraic behaviour — and it is *perfect*: a single residue determines the outcome, zero bits are lost, and the exact capacity is $\log_2 3 - 2/3$ bits, an irrational number that no finite experiment will ever confirm to the last digit but that a proof pins down completely.

There is a **composition law**: multiply two primes and the channel degrades in a way you can compute to the last fraction. Exactly $4/9$ of a bit evaporates, and the surviving $\log_2 3 - 10/9$ bits describe the pair of factors as a set.

And there is a **wall**: about the ordering of the factors — the one thing you would want — the channel says nothing at all, and this is not a quantitative shortfall but an exact structural zero enforced by symmetry.

Perfect knowledge of an aggregate; total ignorance of the individuals. Physics has a name for that shape of situation — a conserved quantity that fixes the whole while leaving the parts free — and it is a little startling to meet it in the splitting behaviour of primes in a cubic field of conductor $13$. The lesson generalises: whenever your measurement is invariant under a group that shuffles the unknowns, no amount of measuring will ever break the tie. You need a genuinely new observable, not a better estimator.

The number $13$ turns out to be a fine place to learn that lesson, precisely because it is not special. Any conductor tells the same story, in the same number of bits.
