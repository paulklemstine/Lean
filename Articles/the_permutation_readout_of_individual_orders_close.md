# The Shuffle That Knows Your Secret — and Still Can't Tell You

## A card trick with $N$ cards

Take a number $N$ and lay out $N$ cards in a row, labelled $0, 1, 2, \dots, N-1$. Pick a multiplier $a$ that shares no factor with $N$. Now shuffle: send the card in position $x$ to position $a \cdot x \bmod N$. Because $a$ is invertible modulo $N$, no two cards collide; this is a genuine shuffle, a permutation of all $N$ positions.

Every shuffle decomposes into cycles: follow one card as it moves, and eventually it returns home. The set of cycle lengths is the shuffle's fingerprint. For $N = 143 = 11 \times 13$ and $a = 2$, the fingerprint is startlingly informative. There is one fixed point (the card $0$, which never moves). There is a cycle of length $10$, and a cycle of length $12$, and two cycles of length $60$. Read those numbers again: $10 = 11 - 1$ and $12 = 13 - 1$. The shuffle is quietly announcing the two prime factors of $143$.

This is not a coincidence, and the phenomenon behind it is exact and completely understood. It is also, as we shall see, a beautiful trap — one of the most instructive dead ends in the theory of integer factorisation. This article tells the whole story: what the shuffle really encodes, why it is strictly more informative than everything cryptographers usually study, and why that extra information is nevertheless worth precisely nothing.

## Orders, and the symmetric blindness of the unit group

Fix $N$ and an $a$ coprime to it. The **multiplicative order** $\operatorname{ord}_N(a)$ is the smallest $k \ge 1$ with $a^k \equiv 1 \pmod N$. It is the length of the cycle through the card $1$: the powers $1, a, a^2, \dots$ march around and come back after $\operatorname{ord}_N(a)$ steps.

Order-finding is the beating heart of modern factoring. Shor's quantum algorithm is, at bottom, an efficient order-finder; classical algorithms like Pollard's $p-1$ method are order-exploiters. If $N = pq$ is a product of two primes, the Chinese Remainder Theorem gives the fundamental identity

$$\operatorname{ord}_N(a) \;=\; \operatorname{lcm}\bigl(\operatorname{ord}_p(a),\ \operatorname{ord}_q(a)\bigr).$$

And there is the rub. The order modulo $N$ is a *symmetric* function of the two prime orders: the least common multiple treats $p$ and $q$ interchangeably and destroys the individual values. Knowing $\operatorname{ord}_N(a) = 60$ for $N = 143$ tells you that $\operatorname{lcm}(\operatorname{ord}_{11}(2), \operatorname{ord}_{13}(2)) = 60$; you cannot tell from that alone that the two orders are $10$ and $12$ rather than, say, $60$ and $12$, or $4$ and $15$. Every probe that lives in the unit group $(\mathbb{Z}/N\mathbb{Z})^\times$ — every "free" experiment an attacker who does not know $p$ and $q$ can run — sees only this one lcm-flattened number. Call this **lcm-blindness**. It is the reason so many order-based attacks stall.

The shuffle of all $N$ cards is not confined to the unit group. It also moves the non-units — the multiples of $p$, the multiples of $q$ — and there, we will see, the symmetry breaks.

## The stratification law

Group the cards by their greatest common divisor with $N$. For each divisor $d$ of $N$ define the **stratum**

$$S_d \;=\; \{\, x \in \mathbb{Z}/N\mathbb{Z} \;:\; \gcd(x, N) = d \,\}.$$

Multiplying by an invertible $a$ cannot change a card's gcd with $N$, so each stratum is shuffled among itself. The complete answer to what happens inside a stratum is the following clean statement, and it is the engine of everything that follows.

> **Stratification Law.** Let $\gcd(a,N)=1$ and let $d \mid N$. The stratum $S_d$ has exactly $\varphi(N/d)$ elements, and *every* element of $S_d$ lies on a cycle of length exactly $\operatorname{ord}_{N/d}(a)$. Consequently the number of cycles inside $S_d$ is $\varphi(N/d)/\operatorname{ord}_{N/d}(a)$, and the total number of cycles of the shuffle is
> $$\#\mathrm{cycles} \;=\; \sum_{d \mid N} \frac{\varphi(N/d)}{\operatorname{ord}_{N/d}(a)}.$$

Here $\varphi$ is Euler's totient function, counting integers below $N/d$ coprime to it.

The proof is a single divisibility observation, and it is worth seeing because it explains *why* the modulus shrinks. To say that $a^k x \equiv x \pmod N$ is to say $N \mid (a^k - 1)x$. Write $d = \gcd(N, x)$. Then $N/d$ and $x/d$ are coprime, and the divisibility collapses to $\;(N/d) \mid (a^k-1)$. In other words, the card $x$ returns home exactly when $a^k \equiv 1$ *modulo the reduced modulus* $N/d$ — the card's own gcd with $N$ cancels part of the modulus away. The period of $x$ is therefore $\operatorname{ord}_{N/d}(a)$, the same for every $x$ in the stratum, and dividing the stratum's size $\varphi(N/d)$ by that common length counts its cycles.

## Breaking the symmetry

Now take $N = pq$. There are exactly four strata, and the law gives all of them at once:

| stratum | description | size | cycle length |
|---|---|---|---|
| $S_1$ | the units | $\varphi(N) = (p-1)(q-1)$ | $\operatorname{ord}_N(a)$ |
| $S_p$ | the nonzero multiples of $p$ | $q-1$ | $\operatorname{ord}_q(a)$ |
| $S_q$ | the nonzero multiples of $q$ | $p-1$ | $\operatorname{ord}_p(a)$ |
| $S_N$ | the single card $0$ | $1$ | $1$ |

There it is. The individual orders $\operatorname{ord}_p(a)$ and $\operatorname{ord}_q(a)$ appear as *distinct cycle lengths*, on distinct strata, side by side with their lcm. The shuffle is a **fully asymmetric readout**: it does not merge the two prime orders, it displays them. The total cycle count is exactly

$$\#\mathrm{cycles} \;=\; 1 \;+\; \frac{\varphi(N)}{\operatorname{ord}_N(a)} \;+\; \frac{q-1}{\operatorname{ord}_q(a)} \;+\; \frac{p-1}{\operatorname{ord}_p(a)}.$$

For $N=143$, $a=2$: $\operatorname{ord}_{143}(2)=60$, $\operatorname{ord}_{11}(2)=10$, $\operatorname{ord}_{13}(2)=12$, so the count is $1 + 120/60 + 12/12 + 10/10 = 5$. And indeed the shuffle has five cycles: the fixed point, one of length $10$, one of length $12$, and two of length $60$.

That the readout is *strictly* richer than the lcm can be exhibited concretely. Take $N = 65 = 5 \times 13$ with the multipliers $a = 57$ and $b = 31$. Both have order $4$ modulo $65$; the unit group cannot distinguish them, and neither can any probe confined to it. But $\operatorname{ord}_5(57) = 4$ while $\operatorname{ord}_5(31) = 1$, so on the stratum of the multiples of $13$ the first shuffle has cycles of length $4$ and the second has fixed points. Even the crudest summary statistic separates them: the first shuffle has $17$ cycles, the second has $20$.

And the asymmetric readout really does factor. Suppose $a$ is a primitive root modulo $q$, so that $\operatorname{ord}_q(a) = q - 1$. Follow the card $p$: it lies in $S_p$, so its cycle has length $\operatorname{ord}_q(a) = q-1$. Add one, and you have $q$ — a nontrivial factor of $N$. This is a complete, correct factoring algorithm, and it works on the nose:

- $N = 143$, $a = 2$: the cycle through $11$ has length $12$, giving $\{11, 13\}$.
- $N = 221$, $a = 7$: length $16$, giving $\{13, 17\}$.
- $N = 899$, $a = 3$: length $30$, giving $\{29, 31\}$.
- $N = 3127$, $a = 2$: length $58$, giving $\{53, 59\}$.

So we have an object that defeats lcm-blindness and factors integers. Why is RSA not in flames?

## Three walls

**Wall one: you cannot get in.** To read the cycle through the card $p$, you must first *have* the card $p$. But a point of a non-trivial stratum is, by definition, a number whose gcd with $N$ is a proper nontrivial divisor. Producing such a point is not a step towards factoring $N$ — it *is* factoring $N$. One Euclidean algorithm and you are done; the shuffle is superfluous. This is a perfectly circular entry condition: the only cards you can reach for free are the units, and on the unit stratum the readout is exactly $\operatorname{ord}_N(a)$ again. The free part of the readout is lcm-blind, precisely the datum we were trying to escape.

**Wall two: the informative cards are vanishingly rare, and finding one costs more than trial division.** The interesting strata together contain $p + q - 1$ cards out of $N = pq$. For balanced semiprimes — say $p \le q \le 2p$, the case of cryptographic interest — one has the sharp bound

$$(p + q - 1)\,\lfloor \sqrt{N} \rfloor \;\le\; 6N,$$

that is, the informative cards have density at most $6/\sqrt{N}$. Blind sampling needs about $\sqrt{N}/6$ tries, and each successful try already hands you a factor by gcd. Worse, running the shuffle honestly means enumerating a permutation of an $N$-element set: the unit stratum alone has $\varphi(N) = (p-1)(q-1) > \sqrt{N}$ elements for odd primes, so merely walking the free part of the structure costs more than trial division, and enormously more than Pollard's rho with its $N^{1/4}$ expected work.

**Wall three: reading a single cycle length is itself an order-finding problem.** Every cycle length divides $\operatorname{ord}_N(a)$, and measuring the length of the cycle through a given card means iterating until it returns — an order computation. There is no shortcut from "the structure contains $\operatorname{ord}_p(a)$" to "I can read $\operatorname{ord}_p(a)$ cheaply."

The verdict is unambiguous: separating $\operatorname{ord}_p(a)$ from $\operatorname{ord}_q(a)$ is *not* the hard part. The object that carries the asymmetry is exactly the $\Theta(N)$ enumeration of the ring, and that enumeration is the whole cost.

## What the shuffle really is: a bundle of Pollard probes

There is a lovely identity that explains, in one line, why the cycle count contains no new secret. Counting the pairs (power $k$, card fixed by $a^k$) in two different ways — Burnside's orbit-counting argument — gives

$$\operatorname{ord}_N(a) \cdot \#\mathrm{cycles} \;=\; \sum_{k=0}^{\operatorname{ord}_N(a)-1} \gcd\bigl(N,\ a^k - 1\bigr),$$

because the map $x \mapsto a^k x$ has exactly $\gcd(N, a^k-1)$ fixed points on $\mathbb{Z}/N\mathbb{Z}$.

Look at the right-hand side. Those gcds are *precisely the probes of Pollard's $p-1$ algorithm*. The cycle count is nothing but their aggregate. And the identity has a sharp corollary: the cycle count sits at its minimum possible value exactly when every one of the probes $\gcd(N, a^k-1)$, $1 \le k < \operatorname{ord}_N(a)$, is trivial. The readout beats its floor if and only if one of the classical probes has already succeeded — that is, if and only if the old algorithm has already factored $N$ for you. The shuffle is not a new weapon; it is a summation over a familiar one.

## How much extra information, exactly?

We can be quantitative about the surplus. Write $i_p = (p-1)/\operatorname{ord}_p(a)$ and $i_q = (q-1)/\operatorname{ord}_q(a)$ for the *indices* of $a$ at the two primes, so that the shuffle on $\mathbb{Z}/p\mathbb{Z}$ has $1 + i_p$ cycles and similarly at $q$. Then

$$\#\mathrm{cycles}(pq) \;=\; \#\mathrm{cycles}(p)\cdot\#\mathrm{cycles}(q) \;+\; \bigl(\gcd(\operatorname{ord}_p a,\ \operatorname{ord}_q a) - 1\bigr)\, i_p\, i_q .$$

The composite readout is *supermultiplicative*: gluing two primes never loses cycles, and equality holds exactly when the two prime orders are coprime. The entire surplus of the composite readout over the two prime readouts is one number, $\gcd(\operatorname{ord}_p a, \operatorname{ord}_q a)$. Since the lcm is already known from the unit group and $\operatorname{lcm}\cdot\gcd = \operatorname{ord}_p\cdot\operatorname{ord}_q$, this is exactly the statement that the *only* new datum beyond the lcm is the gcd — one number, not a new kind of structure. (When $a$ is primitive at both primes the surplus is $\gcd(p-1,q-1)-1 \ge 1$, so it is genuinely nonzero: the readout really is finer, just not usefully so.)

## The sign: a global summary that is free

If the fine structure is out of reach, what about a crude global summary? The coarsest possible one is the *sign* of the shuffle: a permutation of an $N$-element set with $c$ cycles is even or odd according to the parity of $N - c$. One bit. Surely a bit distilled from the whole cycle spectrum knows something?

It does not, and the reason is a classical gem in modern dress. Zolotarev's lemma says that for a prime $p$, multiplication by $a$ is an even permutation of $\mathbb{Z}/p\mathbb{Z}$ exactly when $a$ is a quadratic residue. The full stratified analysis extends this to every odd modulus:

> **General Sign Law (odd modulus).** For every odd $N \ge 1$ and every $a$ coprime to $N$, the permutation $x \mapsto ax$ of $\mathbb{Z}/N\mathbb{Z}$ is even if and only if the Jacobi symbol $J(a \mid N)$ equals $+1$.

The proof is a parity-localisation argument of some charm. Each stratum contributes its index $i_e = \varphi(e)/\operatorname{ord}_e(a)$ to the cycle count. Whenever the label $e$ splits into two coprime factors both exceeding $2$, that index is even — such strata are *parity-dead*, invisible to the sign. Along a prime-power tower the index is parity-constant, because raising the modulus can only multiply the order by a power of $p$. What survives is a sum over the prime factors of $N$, and Euler's criterion converts each surviving term into a Legendre symbol; their product is the Jacobi symbol.

And the Jacobi symbol is computable in polynomial time by quadratic reciprocity, *without knowing the factorisation of $N$*. So the sign bit is free: it can be predicted in advance from $a$ and $N$ alone. No attack can extract a secret from it.

The even case completes the picture, with an amusing twist. At an even modulus $N$, write $N = 2^s m$ with $m$ odd. Then the odd part of $N$ becomes entirely invisible to the sign: if $N \equiv 2 \pmod 4$ the shuffle is *always* even; and if $4 \mid N$ it is odd exactly when $a \equiv 3 \pmod 4$. Putting the halves together:

> **Complete Sign Law.** For every modulus $N \ge 1$ and every $a$ coprime to $N$, the permutation $x \mapsto ax$ of $\mathbb{Z}/N\mathbb{Z}$ is even if and only if: $J(a\mid N) = 1$, when $N$ is odd; and $a \equiv 1 \pmod 4$ whenever $4 \mid N$, when $N$ is even.

Two lines, valid at every modulus, computable in polynomial time from $a$ and $N$.

## Trying to enrich the shuffle

If multiplication alone is exhausted, why not shuffle with something bigger? Two natural enlargements suggest themselves, and both turn out to be closed.

**Affine maps.** Replace $x \mapsto ax$ by $x \mapsto ax + b$. A new parameter, a bigger family, surely a richer readout. But suppose $1 - a$ is invertible modulo $N$. Then the translation $x \mapsto x + b(1-a)^{-1}$ conjugates $x \mapsto ax$ into $x \mapsto ax+b$: the two shuffles are the *same* shuffle in different coordinates, with literally the same cycle structure. The shift is invisible. And in general — for every $a$, every $b$ — the affine cycle count depends on $b$ **only through the single number $\gcd(\gcd(N, a-1),\, b)$**. The proof uses the two symmetries of the affine family: rescaling $x \mapsto ux$ by a unit sends the shift $b$ to $ub$, and translating $x \mapsto x + t$ sends $b$ to $b + (a-1)t$; Bézout's identity then shows that the orbit of $b$ under these moves is determined by that one gcd. At the other extreme, the pure translation $x \mapsto x + b$ has exactly $\gcd(N, b)$ cycles.

So the entire cost of enlarging the attack surface from one parameter to two buys exactly one extra gcd — a quantity computable in polynomial time with no factorisation. As for the sign, the affine family is multiplicative in exactly the way one would hope: the sign of $x \mapsto ax+b$ is the sign of $x \mapsto ax$ times the sign of $x \mapsto x+b$, at every modulus. At an odd modulus the shift never affects the sign at all, and the affine sign is the Jacobi symbol $J(a \mid N)$ — free again.

**Power maps.** At a prime modulus $p$, the map $x \mapsto x^k$ is a permutation exactly when $\gcd(k, p-1) = 1$. What is its cycle structure? Taking discrete logarithms turns $\mathbb{Z}/p\mathbb{Z}$ into the cyclic group $\mathbb{Z}/(p-1)\mathbb{Z}$ with the point $0$ adjoined, and turns the power map into *multiplication by $k$*. Hence

$$\#\mathrm{cycles}\bigl(x \mapsto x^k \text{ on } \mathbb{Z}/p\mathbb{Z}\bigr) \;=\; \#\mathrm{cycles}\bigl(x \mapsto kx \text{ on } \mathbb{Z}/(p-1)\mathbb{Z}\bigr) \;+\; 1.$$

The power readout is the multiplicative readout one level down. And since $p-1$ is even, the even-modulus half of the sign law applies verbatim and gives another explicit, factorisation-free rule: $x \mapsto x^k$ is an even permutation of $\mathbb{Z}/p\mathbb{Z}$ exactly when $4 \mid p-1$ implies $k \equiv 1 \pmod 4$.

## The moral

It is tempting to think of a cryptographic secret as *hidden information*, and of an attack as a device that reveals it. The story of this shuffle argues for a different picture. Here the information was never hidden. The cycle structure of $x \mapsto ax$ on $\mathbb{Z}/N\mathbb{Z}$ displays $\operatorname{ord}_p(a)$ and $\operatorname{ord}_q(a)$ separately, in plain view, on strata whose sizes are $q-1$ and $p-1$; you can read the factorisation off it in one subtraction. The secret is not concealed. It is merely *expensive to look at* — the viewing apparatus is an enumeration of $N$ objects, and you cannot get inside the interesting part of it without already knowing the answer.

This is a genuinely different kind of barrier from the ones usually invoked. It is not that the map is one-way, nor that the relevant group is unstructured. It is that the structure exists, is exactly known, and its every accessible summary — the free stratum, the cycle count parity, the affine extension, the power maps — has been shown to be a quantity anyone can compute in polynomial time from $N$ and $a$ alone.

Seen this way, the shuffle completes a natural progression. Orders are *free* as probes, *partial* as constraints on smooth parts, and *sealed* as readouts: the object that separates them costs more to build than the factorisation it would reveal. What remains are genuinely different avenues — a lower-bound proof that any such enumeration must cost $\Omega(N)$, a quantum channel that samples the structure without enumerating it, or an amplification of some external hint about $p$ and $q$.

Meanwhile there is something quietly satisfying in a dead end this clean. We now know exactly what the multiplication shuffle of the integers modulo $N$ looks like — every cycle, every length, every parity bit, at every modulus, together with its affine and power-map relatives. It is a small and complete piece of mathematics, born from an attack that failed. Most of what we know about hardness, we learned that way.
