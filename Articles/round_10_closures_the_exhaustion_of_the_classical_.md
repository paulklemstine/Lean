# The Shape of a Secret: Why Counting Roots of Unity Will Never Break RSA

## A number that refuses to talk

Take two large prime numbers, multiply them together, and publish the product. That is the whole
idea behind the encryption that protects your bank transfers, your messages, and the software
updates your phone installs overnight. The product $N = pq$ is public; the two factors $p$ and $q$
are the secret. Everyone can see the answer to the multiplication. Almost nobody can run it
backwards.

Why not? Not for lack of trying. Half a century of number theory has thrown everything at the
problem, and the good algorithms we have — the quadratic sieve, the number field sieve — are all
*subexponential*: they run in time roughly $\exp\!\big(c (\log N)^{1/3} (\log\log N)^{2/3}\big)$,
which is far better than trial division but hopelessly far from the polynomial time that would
break the internet.

The natural question is whether this is a failure of imagination or a fact about mathematics. This
article is about a family of results that answers a sharp, restricted version of that question with
a definite *no* — and, more interestingly, shows exactly where the wall is, and exactly where the
one known way through it passes.

## Free witnesses: what a modulus tells you for free

Here is a concrete way to interrogate a number $N$ without knowing its factors. Work modulo $N$,
and consider the *units* — the residues $x$ with $\gcd(x, N) = 1$, the ones that have multiplicative
inverses. For each exponent $k$, ask a simple counting question:

$$R_k(N) \;=\; \#\{x \bmod N : x \text{ is a unit and } x^k \equiv 1 \pmod N\}.$$

How many $k$-th roots of unity are there modulo $N$? This is a *free witness*: you can compute it
(in principle) knowing only $N$, and it is a pure structural invariant of the arithmetic modulo $N$.
The number $R_2(N)$ counts square roots of $1$; $R_3(N)$ counts cube roots; and so on.

These counts are not random. They obey a beautiful and completely rigid law.

> **The Trace Lemma.** Let $N = pq$ with $p$ and $q$ distinct primes. Then for every exponent $k$,
> $$R_k(N) \;=\; \gcd(k,\, p-1)\cdot \gcd(k,\, q-1).$$

The proof is a two-line argument once you see the right picture. The Chinese Remainder Theorem
splits the unit group modulo $N$ into a product of the unit group modulo $p$ and the unit group
modulo $q$; each of those is *cyclic* of order $p-1$ and $q-1$ respectively; and in a cyclic group
of order $n$ the equation $x^k = 1$ has exactly $\gcd(n,k)$ solutions. Multiply the two counts and
you are done.

The same argument runs unchanged over any number of prime factors. For a squarefree modulus
$N = r_1 r_2 \cdots r_n$,
$$R_k(N) \;=\; \prod_{i=1}^{n} \gcd(k,\, r_i - 1),$$
and with a little more care — using the fact that the units modulo an odd prime power form a cyclic
group — for *every* odd $N$,
$$R_k(N) \;=\; \prod_{p \mid N} \gcd\!\big(\varphi(p^{v_p(N)}),\, k\big),$$
where $v_p(N)$ is the exponent of $p$ in $N$ and $\varphi$ is Euler's totient.

The trace lemma is the good news and the bad news at once. Good news: this whole infinite family of
invariants is completely understood. There is nothing mysterious left in it. Bad news: *the formula
says exactly what the invariants can see*, and what they can see is only the pair of numbers
$\gcd(k, p-1)$ and $\gcd(k, q-1)$. The witness never touches $p$ and $q$ themselves — only their
shadows through the greatest-common-divisor filter.

## The information budget

Here is the first quantitative consequence, and it is almost embarrassingly simple. Since
$\gcd(k, p-1)$ and $\gcd(k, q-1)$ both divide $k$, the trace lemma gives
$$R_k(N) \mid k^2 .$$

A single free witness, no matter how enormous the modulus $N$, carries at most $2\log_2 k$ bits of
information. You cannot learn a $2048$-bit secret from a number that is bounded by $k^2$ unless $k$
is astronomically large. (For a squarefree modulus with $n$ prime factors the bound becomes
$R_k(N) \le k^n$ — the leak grows only linearly in the number of factors.)

So one witness is not enough. The obvious next move is to *aggregate*: compute many witnesses at
once, for a whole set $S$ of exponents, and read the joint profile
$$\big(R_k(N)\big)_{k \in S}.$$
Surely a rich enough profile pins down the factorisation?

## Dirichlet says no

It does not, and the reason is one of the oldest theorems in analytic number theory.

> **The Joint-Closure Theorem.** Fix any prime $q$ and any finite set $S$ of positive exponents.
> Then there are infinitely many primes $p$ for which the semiprime $N = pq$ has one and the same
> joint profile $\big(R_k(N)\big)_{k \in S}$. Consequently there is no function whatsoever which,
> given only that profile, returns the prime factor $p$.

Note how strong the conclusion is. It is not a statement about running time; it is
information-theoretic. Two genuinely different numbers present the profile-reader with byte-for-byte
identical input, so no algorithm — however clever, however slow — can distinguish them.

The proof is short and pretty. Let $M = \prod_{k \in S} k$. By Dirichlet's theorem on primes in
arithmetic progressions, there are infinitely many primes $p \equiv 1 \pmod{M}$. For such a prime,
$M$ divides $p-1$, so every $k \in S$ divides $p-1$, so $\gcd(k, p-1) = k$: the witness is
*saturated*, sitting at its maximum possible value. By the trace lemma the whole profile becomes
$$R_k(pq) = k \cdot \gcd(k, q-1) \qquad (k \in S),$$
which does not mention $p$ at all. Every saturating prime produces the same profile. Take two of
them, and you have a collision that no reader can resolve.

You can watch this happen by hand. The exponent set $\{6, 12, 15, 20, 30, 60\}$ was used in the
original experiments; both $61$ and $181$ are primes congruent to $1$ modulo $60$, so the two
distinct semiprimes $61 \cdot 7 = 427$ and $181 \cdot 7 = 1267$ have literally identical joint
free-witness profiles over that set. Two locked doors, one key-shaped hole, and the key fits both.

This is the wall — call it the *aggregation barrier*. The classification of free witnesses is
*closed under joints*: joining partial information never produces complete information.

## But the family is complete — at a ruinous price

Here is the twist that makes the story interesting rather than merely negative. The free-witness
family is not blind in principle. It is blind *cheaply*.

Watch what happens when the exponent gets big enough. By the trace lemma, $R_k(N)$ reaches its
maximum possible value $(p-1)(q-1) = \varphi(N)$ exactly when $\gcd(k,p-1) = p-1$ and
$\gcd(k,q-1) = q-1$, that is, exactly when
$$(p-1) \mid k \quad\text{and}\quad (q-1)\mid k,$$
which is to say exactly when $\operatorname{lcm}(p-1, q-1)$ divides $k$. And a *single* witness of
value $\varphi(N)$ hands over the factorisation immediately, by an identity every schoolchild can
verify:
$$(p-1)(q-1) + (p+q) = pq + 1,$$
so knowing $\varphi(N)$ and $N$ gives you the sum $s = p + q = N + 1 - \varphi(N)$, and then
$p$ and $q$ are the two roots of $x^2 - sx + N$:
$$p,\, q \;=\; \frac{s \pm \sqrt{s^2 - 4N}}{2}.$$
One square root, and the secret is out.

So the family *is* complete. The question is what completeness costs, and here the answer is exact,
not merely a bound.

> **The Aggregation-Cost Theorem.** For $N = pq$, the set of exponents $k$ with $R_k(N) = \varphi(N)$
> is precisely the set of multiples of $\operatorname{lcm}(p-1, q-1)$. Hence the *least* positive
> complete exponent is exactly
> $$\lambda(N) \;=\; \operatorname{lcm}(p-1, q-1) \;=\; \frac{\varphi(N)}{\gcd(p-1,q-1)} .$$

For cryptographically typical primes, $\gcd(p-1, q-1) = 2$, so the least complete exponent is
$\varphi(N)/2 \approx N/2$. You need to reach an exponent of the same order of magnitude as the
modulus itself — exponential in the number of digits of $N$. Even the crude bound is already fatal:
since $R_k(N)$ divides $k^2$, completeness forces $\varphi(N) \le k^2$, i.e. $k \ge \sqrt{\varphi(N)}
\approx \sqrt N$.

The same statement holds far beyond semiprimes. For every odd modulus $N$, the least positive
exponent whose free witness is complete is the *Carmichael exponent*
$$\lambda(N) \;=\; \operatorname{lcm}_{p \mid N} \varphi\big(p^{v_p(N)}\big),$$
the exponent of the group of units modulo $N$. The aggregation depth of this classical channel is,
quite literally, a classical arithmetic function — and it is always exponentially large in
$\log N$.

Complete but exponentially deep; cheap but permanently partial. There is no middle.

## Random walks don't help

A recurring hope in factoring is that randomness will find what structure hides. The archetype is
Pollard's rho method, where you walk pseudo-randomly through the residues modulo $N$ and take
$\gcd(\text{difference}, N)$, hoping to stumble onto a factor. The natural "smooth" variant is a
multiplicative walk: pick a smooth step $s$ and iterate $x \mapsto xs \bmod N$.

This walk is provably sterile, and the reason is a one-line observation dressed up as a theorem.

> **Walk Sterility.** If the seed $x$ and the step $s$ are both coprime to $N$, then every value of
> the walk $x_t = x s^t \bmod N$ is coprime to $N$. Hence $\gcd(x_t, N) = 1$ for all $t$: the
> greatest-common-divisor channel — the only channel through which such a walk can emit a factor —
> is identically trivial. Moreover, if $s$ has multiplicative order $r$ modulo $N$, the walk is
> periodic with period dividing $r$: the orbit is just a coset of the cyclic subgroup generated by
> $s$, and contains at most $r$ distinct values.

The walk has no randomness worth the name. It is a tour of a cyclic group wearing a mask. Its only
genuinely useful resource is the *smoothness* of the values it visits, which is exactly the resource
the quadratic sieve and the number field sieve already exploit — and which delivers subexponential,
never polynomial, running time.

## Where the quantum computer actually breaks in

Now for the most surprising item, because it is not a negative result but a precise piece of
attribution.

Shor's quantum algorithm factors integers in polynomial time. What, exactly, does it do that the
classical world cannot?

The naive answer is "it computes something classical algorithms cannot compute." That answer is
*wrong*, and the trace lemma is what shows it is wrong. Shor's algorithm computes the multiplicative
order of a random residue $a$ modulo $N$ — and the order is precisely one of the classified
free-witness coordinates. The trace lemma tells us exactly how many elements have each order; the
quantum algorithm learns nothing about the modulus that the classification did not already know how
to describe.

What Shor's algorithm does is *locate* such a coordinate in one shot, reading it off a single
coherent superposition, whereas the classical world must aggregate to exponential depth to get the
same coordinate. The quantum advantage is therefore localised at the aggregation barrier — not at
the trace lemma.

And the payoff coordinate is neither rare nor mysterious. By the trace lemma with $k = 2$, applied to
$N = pq$ with $p, q$ distinct odd primes:
$$R_2(N) = \gcd(2, p-1)\cdot \gcd(2, q-1) = 2 \cdot 2 = 4 .$$
There are exactly four square roots of $1$ modulo $N$. Two of them are the boring ones, $\pm 1$. The
other two are gold:

> **Residue-Witness Sufficiency.** For $N = pq$ with distinct odd primes, there exists an integer $a$
> with $a^2 \equiv 1 \pmod N$ but $a \not\equiv \pm 1 \pmod N$; and for any such $a$, the single
> greatest common divisor $\gcd(a-1, N)$ is one of the two prime factors of $N$.

The construction is explicit: by the Chinese Remainder Theorem, take the residue that is $1$ modulo
$p$ and $-1$ modulo $q$. Then $N \mid a^2 - 1 = (a-1)(a+1)$ while $N$ divides neither factor, so the
prime $p$ must go into $a-1$ and $q$ into $a+1$ (or vice versa) — and $\gcd(a-1, N)$ splits $N$.

So the witness is *not rare* — it is a full half of the square roots of unity, a $50\%$ target — and
it is *not unclassified* — the trace lemma counts it exactly. It is merely expensive to find.
The entire quantum advantage in factoring is the price of that search.

For a general odd squarefree modulus the count generalises to
$$R_2(N) = 2^{\omega(N)},$$
where $\omega(N)$ is the number of distinct prime factors. The residue coordinate *knows how many
prime factors $N$ has* — and still cannot name a single one of them without paying the aggregation
cost. That gap, between counting the factors and naming them, is the whole subject in miniature.

## One hint changes everything

Finally, an honest accounting of what lies *outside* this picture. Real cryptanalysis sometimes has
side information: a few leaked bits of $p$, a timing side channel, a partially exposed key. Methods
in the Coppersmith tradition can amplify roughly half the bits of $p$ into the full factorisation in
polynomial time. Does that contradict everything above?

No — and the cleanest way to see why is to price the simplest possible hint. Suppose someone hands
you the single number $s = p + q$, the *trace* of the factorisation. Then, as we already noted,
$$p \;=\; \frac{s - \sqrt{s^2 - 4N}}{2},$$
and the factorisation falls out in constant time with one square root. Moreover the hint is
information-theoretically complete: if $pq = p'q'$ and $p+q = p'+q'$ with $p \le q$ and
$p' \le q'$, then $p = p'$ and $q = q'$. Concretely, for $N = 8051$ and the hint $s = 180$, the
formula gives $(180 - \sqrt{32400 - 32204})/2 = (180-14)/2 = 83$, and indeed $8051 = 83 \cdot 97$.

The contrast is the point:

- *Hint-free channel*: no extractor exists at all, at any running time.
- *Hinted channel*: an explicit closed-form extractor exists, in constant time.

Hint amplification is not a counterexample to the barrier. It lives in a different universe of
problems: **extraction from $N$ alone** versus **amplification of external hints**. Any honest
hardness framework must declare which one it is talking about, and the results above are firmly
about the first.

## The verdict

Put the pieces together and you get a single, clean picture of a classical attack surface that has
been mapped to its edges:

1. **Every invariant in the free-witness family is understood exactly.** The trace lemma gives a
   closed formula, over semiprimes, over squarefree moduli, and over all odd moduli.
2. **No finite aggregation of them can name a factor.** Dirichlet supplies infinitely many
   colliding moduli; the impossibility is information-theoretic, not computational.
3. **Completeness exists but is exponentially deep.** The exact aggregation depth is the Carmichael
   exponent $\lambda(N)$ — of order $N$ for cryptographic semiprimes.
4. **Multiplicative random walks are sterile.** They emit no greatest-common-divisor signal at all
   and merely re-enact sieve methods in disguise.
5. **The quantum channel bypasses exactly one thing: the aggregation cost.** It reads the
   residue/order coordinate — a fully classified coordinate — from one superposition, and the
   post-processing that turns it into a factorisation is elementary and unconditional.
6. **External hints are a separate resource**, with an explicit closed-form amplifier, and must be
   priced separately.

What remains genuinely open is the hardest and most valuable question of all: whether the
aggregation cost identified here can be shown to be *unavoidable* for arbitrary classical
algorithms, not merely for algorithms restricted to reading this particular family of invariants. A
proof of that would be a proof that factoring is classically hard — one of the great open problems
of the subject. What the results above provide is something more modest and, in its way, more
useful: an exact map of where the boundary lies, a precise statement of what makes the quantum
computer special, and a clear declaration of which resources any future hardness claim must price.

The number $N$ is not silent. It answers every question in the free-witness family, promptly and
exactly. It just never answers the one you asked.
