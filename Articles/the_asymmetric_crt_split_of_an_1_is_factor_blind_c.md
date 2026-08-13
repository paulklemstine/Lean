# The Number That Knows Your Secret But Cannot Tell

## A cheap arithmetic quantity that genuinely depends on both prime factors of a public number — and the exact reason it still reveals nothing

### An asymmetry hiding in plain sight

Modern public-key cryptography rests on a single, stubborn asymmetry: multiplying two large primes $p$ and $q$ to get $N = pq$ is instantaneous, while recovering $p$ and $q$ from $N$ alone is, as far as anyone knows, hopeless once the numbers reach a few hundred digits. Every attack on that gap begins the same way: find something you can compute *from $N$ alone*, cheaply, that nevertheless *depends on $p$ and $q$ separately*. If such a quantity existed and you could read the dependence off, RSA would fall.

This article is about one very tempting candidate, about a genuine structural surprise it contains, and about the sharp, provable reason it collapses anyway. The candidate is about as simple as it gets:

$$Q(a) \;=\; a^{\,N-1} \bmod N.$$

You can compute it in a fraction of a millisecond for a $2048$-bit $N$ by repeated squaring. It uses nothing but $N$ and a chosen base $a$. It is the quantity at the heart of the Fermat primality test. And — here is the surprise — although its *definition* is perfectly symmetric in $p$ and $q$, its *internal structure* is not.

### The split

The Chinese Remainder Theorem says that a residue modulo $N = pq$ is the same thing as a pair of residues, one modulo $p$ and one modulo $q$. Every number mod $N$ has two "shadows," and the pair of shadows determines the number completely. So let us ask what $Q(a)$ looks like in each shadow.

Fermat's little theorem tells us $a^{p-1} \equiv 1 \pmod p$ whenever $p \nmid a$. Now decompose the exponent. Writing $N - 1 = pq - 1$, we have the identity

$$pq - 1 \;=\; (p-1)q + (q-1),$$

which you can check by expanding the right-hand side: $pq - q + q - 1 = pq - 1$. Reduce modulo $p$: the term $(p-1)q$ contributes $\left(a^{p-1}\right)^{q} \equiv 1^q = 1$, and what survives is the remainder $q - 1$. Reading the same number the other way, $pq - 1 = (q-1)p + (p-1)$, and the identical argument modulo $q$ leaves $p - 1$.

**The Asymmetric CRT Split.** *Let $N = pq$ with $p \ne q$ prime, and let $a$ be coprime to $N$. Then*

$$Q(a) \equiv a^{\,q-1} \pmod p, \qquad Q(a) \equiv a^{\,p-1} \pmod q.$$

*Moreover $Q(a)$ is the unique residue below $N$ with those two shadows.*

Look at what just happened. The number $pq - 1$ is symmetric — swap $p$ and $q$ and nothing changes. But when you *split* it, the two halves swap roles. Modulo $p$, the exponent behaves like the *other* prime's Fermat exponent $q-1$. Modulo $q$, it behaves like $p-1$. Each shadow of this cheap, factorisation-free quantity is governed by the prime it cannot see.

This is not a heuristic. It holds for every semiprime and every base, and it is exact: given the two shadows, $Q(a)$ is pinned down uniquely.

That is genuinely exciting for about five minutes. Here is a number you can compute without knowing the factorisation, whose left half secretly carries $q$ and whose right half secretly carries $p$. If you could get at one half, you would learn something about the prime you were not allowed to know.

### Why you cannot get at one half

The answer turns out to be brutally clean. Suppose someone hands you a procedure — call it a *component reader* — that, given any base $a$, outputs a number $s(a)$ that reproduces the left shadow of $Q$ faithfully ($s(a) \equiv a^{q-1} \bmod p$) while being invisible in the right shadow ($s(a) \equiv 0 \bmod q$). That is exactly what "isolating one CRT coordinate" means.

**The Component-Reading Barrier.** *Any such component reader factors $N$ immediately: $\gcd(s(1), N) = q$.*

The proof is three lines. Feed the reader the single base $a = 1$. Then $s(1) \equiv 1^{q-1} = 1 \pmod p$, so $p \nmid s(1)$; and $s(1) \equiv 0 \pmod q$, so $q \mid s(1)$. A number divisible by $q$ and not by $p$ has greatest common divisor exactly $q$ with $N = pq$. One call, one gcd, and you have the factorisation.

This is the crux. The device that would let you exploit the asymmetry — a way to look at one CRT coordinate in isolation — is a *CRT idempotent*, a number that is $1$ in one shadow and $0$ in the other. And CRT idempotents and factorisations are the same information. Knowing the factorisation lets you build the idempotent (that is just the Chinese Remainder Theorem run forwards); owning an idempotent hands you the factorisation via a single gcd. There is no partial credit, no "half of an idempotent," no way to peek.

So the asymmetry is real, and it is locked in a box whose key is the thing you were trying to find.

### The same lock, in three familiar disguises

This barrier is not an artifact of one clever quantity. It has a general engine behind it.

**The Splitting Lemma.** *Suppose $N = pq$ divides a product $uv$, but $N$ divides neither $u$ nor $v$, and no prime factor of $N$ divides both $u$ and $v$. Then $\gcd(u, N)$ is one of the two primes.*

The reasoning is a case analysis. Since $p \mid uv$ and $p$ is prime, $p$ divides $u$ or $v$; the same for $q$. If both divided the same one, $N$ would divide it — excluded. If both divided different ones, say $p \mid u$ and $q \mid v$, then $u$ is divisible by $p$ but not by $q$ (that would put $q$ in both), so $\gcd(u,N) = p$.

Feed different $u, v$ into this engine and out come the classical splits:

- **Nontrivial idempotents split $N$.** If $N \mid e(e-1)$ while $e \not\equiv 0$ and $e \not\equiv 1 \pmod N$ — that is, $e$ is an idempotent other than the two boring ones — then $\gcd(e, N)$ is a prime factor.
- **Rabin's split.** If $x^2 \equiv 1 \pmod N$ with $x \not\equiv \pm 1$, then $\gcd(x-1, N)$ is a prime factor. This is exactly the moment where the Miller–Rabin test stops merely certifying compositeness and starts *factoring* — and, as the lemma makes clear, it too is an oracle for the CRT split.

Every route to the asymmetry passes through the same gate.

### The other collapse: everything reduces to one number

Suppose you give up on isolating a shadow and try statistics instead. Compute $Q(a)$ for many bases $a$ and look for patterns that betray $p$ or $q$. Here a second, independent collapse occurs, and it has a name: the **Euler gap**

$$g \;=\; \gcd(p-1,\, q-1).$$

The reason is an exponent identity as simple as the first. Modulo $p-1$, the Fermat exponent $N-1$ is just $q-1$, because $N - 1 = (p-1)q + (q-1)$. Hence

$$\gcd(N-1,\, p-1) \;=\; \gcd(q-1,\, p-1) \;=\; g, \qquad \gcd(N-1,\, q-1) \;=\; g.$$

Both gcds collapse to the *same* number. The exponent $N-1$ is blind to which prime it is being reduced against — it sees only the gap they share.

In a finite group, whether $x^n = 1$ depends on $n$ only through $\gcd(n, |G|)$. Applying this in each shadow gives:

**The Fermat Test Is the Euler-Gap Test.** *For every unit $u$ modulo $N = pq$,*
$$u^{\,N-1} \equiv 1 \pmod N \iff u^{\,g} \equiv 1 \pmod N.$$

Every consequence follows mechanically. The units killed by the $(N-1)$-power map — the **Fermat liars** — number exactly $g^2$, since each shadow contributes $\gcd(p-1, N-1) = g$ possibilities. Better: the liar group is isomorphic to $\mathbb{Z}/g \times \mathbb{Z}/g$. Its isomorphism type depends on $p$ and $q$ *only through $g$*. The image of the power map has size $\varphi(N)/g^2$, and the map is a bijection exactly when $g = 1$.

Two consequences are worth pausing on.

First, **no semiprime with distinct factors is a Carmichael number**. Since $g$ divides both $p-1$ and $q-1$ but is strictly smaller than at least one of them (a proper divisor, hence at most half), one gets $2g^2 \le (p-1)(q-1) = \varphi(N)$. So at most half of all bases lie: the Fermat test on a semiprime succeeds with probability at least $1/2$. Carmichael numbers need three prime factors.

Second, **factor-blindness made concrete**. Take $33 = 3 \cdot 11$ and $35 = 5 \cdot 7$. Their prime factors are completely different, but $\gcd(2,10) = 2 = \gcd(4,6)$: the same Euler gap. Therefore their Fermat-liar groups are isomorphic, both being $\mathbb{Z}/2 \times \mathbb{Z}/2$, and both have exactly $4$ liars. Anything the $Q$-surface can measure that respects group isomorphism is a function of $(N, g)$ alone, and cannot tell these two apart.

This matches the experiment that motivated the theory. Across eighty semiprimes near $10^7$ with near-equal factors, the correlations of $Q$ with $p$, with $q$, with $p+q$, and with $|p-q|$ all sat inside the permutation null distribution — observed at most $0.19$ against a $95$th percentile of about $0.22$, for bases $2$, $3$, $5$. As a residue mod $N$, $Q(a)$ is a function of $N$ alone and behaves pseudorandomly. The asymmetry is inside; the outside is featureless.

### What the gcd variant actually measures

There is one route by which $Q$ *does* leak: the classical trick of computing $\gcd(a^{N-1} - 1, N)$ and hoping for a nontrivial answer. When does it fire?

Exactly when the left shadow is $1$ but the right is not, or vice versa. By the asymmetric split, $Q(a) \equiv 1 \pmod p$ precisely when the multiplicative order of $a$ modulo $p$ divides $q - 1$ — the *other* prime's exponent again. Counting these is easy once you know the liar structure: the units that lie modulo $p$ number $g(q-1)$, those that lie modulo $q$ number $g(p-1)$, and those that lie in both number $g^2$.

**The Reveal Density Law.** *The gcd variant $\gcd(a^{N-1}-1, N)$ returns a proper factor of $N$ for exactly*
$$g(q-1) + g(p-1) - 2g^2$$
*of the $\varphi(N) = (p-1)(q-1)$ bases coprime to $N$ — a fraction of roughly $\frac{g}{p} + \frac{g}{q}$.*

This is the measured "$g/p + g/q$" law, now with the exact count rather than an estimate. And it says exactly what a cryptographer would want: the leak is proportional to the Euler gap and inversely proportional to the size of the primes. When $g = 1$, only $(p-1) + (q-1) - 2$ bases work out of nearly $pq$ — a probability around $1/p + 1/q$, utterly negligible at cryptographic sizes. The usable handle is not the asymmetry at all; it is the smoothness of $p-1$ and $q-1$, which is precisely the handle Pollard's $p-1$ method already exploits, and precisely the reason key-generation standards ask for *strong* primes.

### A hint that does work, for contrast

It is worth seeing what a genuine factoring hint looks like, because the difference is instructive. Euler's totient $\varphi(N)$ looks just as innocent as $Q$: one number, easy to state. But it is *not* factor-blind. From $N$ and $\varphi(N)$, set

$$s = N + 1 - \varphi(N) = p + q,$$

which follows from $\varphi(N) = (p-1)(q-1) = pq - p - q + 1$. Then $s^2 - 4N = (p+q)^2 - 4pq = (p-q)^2$, so

$$p = \frac{s + \sqrt{s^2 - 4N}}{2}, \qquad q = \frac{s - \sqrt{s^2 - 4N}}{2}.$$

A closed form. No gcds, no randomness, no search. That is what "carries signal" means, and it is exactly the property $Q$ lacks. Two quantities of comparable apparent cost, on opposite sides of the line.

### The moral

The pattern here deserves a name, because it recurs across attempted attacks on factoring. Call it **asymmetry without the split is invisible**.

$Q(a) = a^{N-1} \bmod N$ is the sharpest example yet. It is cheap — logarithmically many modular multiplications by square-and-multiply, verified correct with recursion depth bounded by the binary length of the exponent. It is genuinely asymmetric: its two CRT coordinates are $a^{q-1} \bmod p$ and $a^{p-1} \bmod q$, each ruled by the other prime. And it is worthless as an attack, for reasons that stack up independently:

1. The factor-dependence lives *entirely* in the CRT coordinates, and reading a coordinate is provably equivalent to factoring.
2. Viewed from outside — as a residue mod $N$ — it is a function of $N$ alone, empirically uncorrelated with $p$, $q$, $p+q$, or $|p-q|$ at near-equal factor sizes.
3. Every multiplicative statistic it supports factors through the single number $g = \gcd(p-1,q-1)$, which is blind to which primes produced it: $33$ and $35$ are indistinguishable.
4. The only genuine leak, the gcd variant, has reveal density $\approx g/p + g/q$ and reduces to $p-1$ smoothness — old news.

The verdict is refutation, but refutation of a satisfying kind. We now know precisely *where* the information is (in the CRT coordinates), precisely *why* it is unreachable (the coordinate reader is an idempotent, and an idempotent is a factorisation), and precisely *how much* leaks anyway (the exact count $g(q-1)+g(p-1)-2g^2$). A negative result with all its constants filled in is a map of the terrain, not a dead end.

Where does one look next? Three directions suggest themselves. One is to prove the barrier in exact form: that *every* isomorphism-invariant statistic of the power surface $\{(a, a^{N-1} \bmod N)\}$ is a function of $(N, g)$ only — a claim that is falsifiable by exhibiting one statistic separating $33$ from $35$. Another is the converse question of whether the Euler gap is itself a factoring hint: does knowing $g > 1$ alongside $N$ yield the factorisation in randomised polynomial time? The splitting machinery is in place; only the amplification step is open. The third is to leave the classical hint-free setting altogether — quantum period-finding, after all, does exactly the coordinate read that classical arithmetic forbids.

The uniform, hint-free classical surface looks exhausted. But we know its shape now, in exact numbers, and that is worth something.
