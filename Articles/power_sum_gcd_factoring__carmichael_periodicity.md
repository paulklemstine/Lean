# The Sum That Knows Your Secret

## How adding up powers of every number below $N$ quietly betrays its prime factors

Take a number $N$ that you believe is the product of two large primes — the kind of number that guards a bank transfer. Now do something that looks utterly naive: add up the $k$-th powers of *every* number from $1$ to $N$,

$$F(N,k) \;=\; 1^k + 2^k + 3^k + \cdots + N^k,$$

and compute the greatest common divisor of that gargantuan sum with $N$ itself.

You would expect noise. What you get is a clean, deterministic read-out of the arithmetic of $N$'s hidden prime factors — a sequence that is *periodic*, whose period is a famous secret quantity, and whose values are always exact divisors of $N$. Nothing is random, nothing is heuristic, and no lucky choices are required.

This is the story of what that sum knows, why it knows it, and why — despite knowing so much — it still cannot break your bank transfer.

---

## A first experiment

Let $N = 15 = 3 \times 5$. Compute $g(k) = \gcd(F(15,k), 15)$ for $k = 1, 2, 3, \dots$:

$$15,\; 5,\; 15,\; 1,\; 15,\; 5,\; 15,\; 1,\; 15,\; 5,\; 15,\; 1,\; \dots$$

Two things leap out. First, at $k = 2$ the answer is $5$ — a genuine prime factor of $15$, handed over without a search. Second, the whole sequence repeats with period $4$.

Try $N = 35 = 5 \times 7$:

$$35,\; 35,\; 35,\; 7,\; 35,\; 5,\; 35,\; 7,\; 35,\; 35,\; 35,\; 1,\; 35,\; \dots$$

Again the factors appear — $7$ at $k=4$, $5$ at $k=6$ — and the pattern repeats with period $12$. Those periods, $4$ and $12$, are not accidents: $4 = \mathrm{lcm}(3-1, 5-1)$ and $12 = \mathrm{lcm}(5-1,7-1)$. They are the *Carmichael exponents* $\lambda(N)$, the smallest exponent $L$ for which $a^{L} \equiv 1 \pmod N$ for every $a$ coprime to $N$ — a quantity that is, for a cryptographic modulus, exactly as secret as the factorisation itself.

So the sum is not merely leaking a factor now and then. It is displaying the full multiplicative skeleton of $N$.

---

## Why it happens: counting residues

The mechanism is disarmingly simple, and it fits in a paragraph.

Fix a prime $p$ dividing $N$, and write $N = pq$ (for the moment, $q$ need not be prime; it just must not be divisible by $p$). The numbers $1, 2, \dots, N$ sweep through the residues modulo $p$ in perfect rotation: each residue class $0, 1, \dots, p-1$ is hit exactly $q$ times. So modulo $p$,

$$F(N,k) \;\equiv\; q \cdot \big(0^k + 1^k + \cdots + (p-1)^k\big) \pmod p .$$

Now the bracket is a classical object: the complete power sum over the field with $p$ elements. Its value is a strict dichotomy. If $p-1$ divides $k$, then by Fermat's little theorem every nonzero $x$ satisfies $x^k = 1$, so the bracket is $p - 1 \equiv -1$. If $p-1$ does *not* divide $k$, the nonzero $x^k$ run over the values of a nontrivial character-like map and cancel exactly: the bracket is $0$. In symbols, for $k > 0$,

$$\sum_{x \in \mathbb{F}_p} x^k \;=\; \begin{cases} -1, & (p-1) \mid k, \\ 0, & \text{otherwise.}\end{cases}$$

Substituting, we get the whole theory in one line:

$$F(N,k) \;\equiv\; \begin{cases} -q \pmod p, & (p-1)\mid k,\\ \;\;\;0 \pmod p, & (p-1)\nmid k.\end{cases}$$

Since $p \nmid q$, the first case is *nonzero*. So we obtain a perfect criterion — no error term, no probability:

> **The Divisibility Criterion.** Let $p$ be a prime with $p \mid N$ and $p^2 \nmid N$, and let $k > 0$. Then $p$ divides $F(N,k)$ **if and only if** $p - 1$ does not divide $k$.

The prime $p$ "switches off" the moment $k$ becomes a multiple of $p-1$. The power sum is a bank of switches, one per prime factor of $N$, each toggled by its own order condition.

---

## Reading the switches: the product formula

Once you see the switches, the general theorem writes itself. Suppose $N$ is squarefree (no repeated prime factors — the case of an RSA-style modulus). Then for every $k > 0$,

$$\gcd\big(F(N,k),\,N\big) \;=\; \prod_{\substack{r \text{ prime},\; r \mid N \\ (r-1)\,\nmid\, k}} r .$$

The gcd is the product of exactly those primes of $N$ that have *not* yet switched off. Everything observed in the experiments is a corollary.

**The factor reveal.** Take $N = pq$ with $p, q$ distinct primes, and set $k = p-1$. Then $p$ switches off (it divides $p-1$, trivially) but $q$ stays on, provided $q-1$ does not divide $p-1$. The formula gives

$$\gcd\big(F(pq,\,p-1),\, pq\big) \;=\; q .$$

A prime factor of $N$, produced by a single gcd, with no search, no randomness, and no base to choose. On the eight test semiprimes examined — $15, 21, 35, 55, 91, 143, 221$ and $9797 = 97 \times 101$ — this returns $5, 7, 7, 11, 13, 13, 17, 101$ every time.

**The trivial locus.** The gcd equals $1$ exactly when *all* primes have switched off, i.e. when $(r-1)\mid k$ for every prime $r \mid N$. That condition says precisely $\lambda(N) \mid k$, where $\lambda(N) = \mathrm{lcm}_{r \mid N}(r-1)$. So the $1$'s in the sequence sit exactly on the multiples of the Carmichael exponent — that is the $k=4,8,12$ pattern for $N=15$ and the lone $k=12$ for $N=35$.

**Periodicity, and its exactness.** Because the switches depend on $k$ only through the divisibilities $(r-1)\mid k$, the sequence $g(k) = \gcd(F(N,k),N)$ satisfies $g(k+\lambda(N)) = g(k)$ for all $k>0$. Something stronger is true term-wise: $F(N, k+\lambda(N)) \equiv F(N,k) \pmod N$, which is nothing but Korselt's criterion — the congruence $a^{k+\lambda} \equiv a^k \pmod N$ behind Carmichael numbers — summed over all $a$. And the period is not merely *a* period; it is *the* period: if $g(k+d) = g(k)$ for every $k>0$, then $\lambda(N)$ divides $d$. The proof is a one-liner once you have the trivial locus: at $k = \lambda(N)$ the value is $1$, so at $k = \lambda(N)+d$ it is also $1$, so $\lambda(N)$ divides $\lambda(N)+d$, so $\lambda(N) \mid d$.

The secret exponent $\lambda(N)$ is therefore not hidden inside the sequence in some subtle statistical sense. It is the sequence's minimal period, plain as a heartbeat.

---

## No bad bases

There is a classical algorithm that lives in the same neighbourhood: **Pollard's $p-1$ method**. Choose a base $a$, choose a smooth exponent $M$, and compute $\gcd(a^M - 1, N)$. When it works, it works for the same reason as ours: $a^M \equiv 1$ modulo one prime factor but not the other.

But Pollard's method has a base to choose, and choices can be wrong. If $a^M \equiv 1$ modulo *both* factors, the gcd returns $N$ and nothing is learned. Such bad bases are not exotic; they always exist. For any two distinct odd primes $p, q$ and any even exponent $M$, take the number $a$ with

$$a \equiv 1 \pmod p, \qquad a \equiv -1 \pmod q$$

(the Chinese Remainder Theorem supplies one with $1 < a < pq$). Then $a^M \equiv 1^M = 1$ modulo $p$, and $a^M \equiv (-1)^M = 1$ modulo $q$ because $M$ is even, so $\gcd(a^M-1, N) = N$ exactly. For $N = 15$ and $M = 2$ the witness is $a = 4$: $\gcd(4^2-1,15) = \gcd(15,15) = 15$, a total failure — while at that same exponent $k=2$ the power sum hands over $\gcd(F(15,2),15) = 5$.

This is the robustness theorem: **at every exponent where the power-sum method succeeds, Pollard's method has a base that fails.** The reason is structural. The power sum has no base parameter at all. It aggregates *every* residue $a = 1, \dots, N$ simultaneously, so there is nothing to choose badly. Where Pollard samples the multiplicative group at one point, the power sum integrates over the whole of it.

---

## The exact residue: a Giuga-type formula

The criterion above says *whether* a prime divides the sum. One can say more: what the sum actually *is*, modulo $N$. For squarefree $N$ and $k > 0$,

$$F(N,k) \;\equiv\; -\!\!\sum_{\substack{r \text{ prime},\, r\mid N \\ (r-1) \mid k}} \frac{N}{r} \pmod N .$$

The proof is the same residue count performed one prime at a time: modulo a prime $r_0 \mid N$, every term $N/r$ with $r \neq r_0$ is divisible by $r_0$ and dies, while the surviving term $N/r_0$ cancels the Fermat contribution $-N/r_0$ from the $r_0$-block. The formula is verified in the experiments: $F(35,12) \equiv 23 \equiv -(7+5) \pmod{35}$.

Specialising to $N = p$ prime and $k = p-1$ recovers a classical fact: $1^{p-1} + \cdots + (p-1)^{p-1} \equiv -1 \pmod p$. That congruence is the heart of **Giuga's conjecture**, which asserts that $N > 1$ is prime if and only if $\sum_{a=1}^{N-1} a^{N-1} \equiv -1 \pmod N$. Our closed form says that the power-sum read-out is a Giuga statement in disguise: when $\lambda(N)\mid k$, the criterion "$F(N,k) \equiv -1$" becomes "$\sum_{r \mid N} N/r \equiv 1 \pmod N$", which is exactly Giuga's condition. A primality test and a factoring probe turn out to be the same object viewed from two angles.

---

## A lattice hiding in the exponents

Here is an unexpected piece of structure. The read-out map $g_N(k) = \gcd(F(N,k),N)$ turns the gcd of exponents into the lcm of divisors:

$$g_N\big(\gcd(k,k')\big) \;=\; \mathrm{lcm}\big(g_N(k),\, g_N(k')\big).$$

Why? A prime $r$ survives in $g_N(\gcd(k,k'))$ iff $(r-1) \nmid \gcd(k,k')$, i.e. iff $(r-1)$ fails to divide $k$ *or* fails to divide $k'$. Survival sets combine by *union*, and unions of sets of distinct primes correspond to lcm's of their products. So $g_N$ is an order-reversing morphism from the divisibility lattice of exponents to the divisor lattice of $N$. One immediate corollary: if $k \mid k'$ then $g_N(k') \mid g_N(k)$ — refining the exponent can only shrink the revealed factor, never enlarge it.

This means the whole factorisation of $N$ is a *lattice-theoretic invariant* of the single sequence $k \mapsto g_N(k)$: the minimal nontrivial values of the read-out ought to be exactly the co-factors $N/r$, one for each prime $r \mid N$.

---

## The catch, and an honest correction

If the sequence displays $\lambda(N)$ so plainly, why is $N$ not broken?

Because computing a single term is expensive. Evaluating $F(N,k)$ naively costs $O(N)$ modular operations, and the first informative exponent for a balanced semiprime is not small: for $N = pq$ the gcd is *the whole of $N$* — no information — for every $0 < k < \min(p-1, q-1)$, and drops below $N$ for the first time exactly at $k = \min(p-1,q-1) \approx \sqrt{N}$. Multiplying, one pays about $O(N^{3/2})$ to reach the first hit: dramatically worse than trial division, which finishes in $O(\sqrt N)$.

The barrier is precisely a *period-finding* barrier — the same barrier that Shor's quantum algorithm demolishes. Shor's algorithm also factors by finding the period of a function built from modular exponentiation; the quantum Fourier transform reads the period out of a superposition in polynomial time. The power-sum sequence is the classical shadow of the same object: same structure, same secret encoded as a period, but with the period accessible only by walking the sequence one costly step at a time.

And there is a cautionary tale in the arithmetic. Once you know $N$ and $\lambda(N)$, is the factorisation free? The tempting identity is

$$p + q \;=\; N - \lambda(N) + 1,$$

which would come from $\lambda(N) = (p-1)(q-1)$, whereupon $p+q$ and $pq$ give $p$ and $q$ by a quadratic. But $\lambda(N) = \mathrm{lcm}(p-1,q-1)$, not the product. The correct identity is

$$p + q + \lambda(N)\cdot\gcd(p-1,q-1) \;=\; N + 1,$$

which follows from $\mathrm{lcm}(a,b)\cdot\gcd(a,b) = ab$ with $a = p-1$, $b = q-1$. Since $p-1$ and $q-1$ are both even whenever $p$ and $q$ are odd primes, $\gcd(p-1,q-1) \geq 2$ *always*, and the naive formula *always* strictly overshoots. For $N = 15$: $\lambda = 4$, the naive prediction is $15 - 4 + 1 = 12$, while the truth is $3 + 5 = 8$. Knowing $N$ and $\lambda(N)$ leaves exactly one unknown, $g = \gcd(p-1,q-1)$ — and that residual ambiguity, not the difficulty of period-finding alone, is what stands between the read-out and the factorisation.

---

## What to take away

A sum of powers over all residues below $N$ is a spectral instrument. Point it at $N$ and it deletes, one at a time, each prime $r \mid N$ for which the exponent $k$ is a multiple of $r-1$. What remains — the gcd — is a divisor of $N$ that names exactly the primes still standing.

Three theorems summarise the picture. **The factor reveal:** for distinct primes $p,q$ with $(q-1)\nmid(p-1)$, $\gcd(F(pq,p-1),pq)= q$ exactly. **Robustness:** at that very exponent Pollard's $p-1$ method has a base that returns no information, whereas the power sum, having no base, cannot fail this way. **Carmichael periodicity:** the read-out sequence is periodic with least period exactly $\lambda(N)$, and its trivial values sit exactly on the multiples of $\lambda(N)$.

It is not a faster way to factor — the cost is $O(N^{3/2})$, and honest bookkeeping shows that even a free $\lambda(N)$ leaves the quantity $\gcd(p-1,q-1)$ unaccounted for. But it is a strikingly clean picture of *where the secret lives*. The factorisation of $N$ is not hidden in the values of some arithmetic function; it is hidden in the *period* of a function that anyone can write down in a single line. The whole difficulty of factoring, in this account, is the difficulty of getting at a period. That is a good sentence to keep in mind the next time somebody says that factoring is hard "because multiplication is easy to do and hard to undo." Undoing multiplication, here, is undoing a rhythm.
