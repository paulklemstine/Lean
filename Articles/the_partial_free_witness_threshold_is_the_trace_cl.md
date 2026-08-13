# The Number That Knows Your Secret

## How a single arithmetic sum betrays a factorization — and why it still can't break your encryption

Take a number like $N = 187$. Somewhere inside it are two prime factors hiding
in plain sight, $11$ and $17$, and the entire modern internet is built on the
belief that when $N$ has six hundred digits instead of three, finding them is
hopeless.

Now let me tell you a secret about $187$. Add up the squares of all its
divisors:

$$1^2 + 11^2 + 17^2 + 187^2 = 1 + 121 + 289 + 34969 = 35380.$$

That single number, $35380$, hands you the factorization instantly. No
searching, no trial division, no elliptic curves. Just three lines of
schoolbook algebra. And that fact — together with the precise reason it does
*not* break RSA — is the story of this article.

---

## The free witness

For a positive integer $N$ and an exponent $k$, define the **power-sum divisor
function**

$$\sigma_k(N) \;=\; \sum_{d \mid N} d^{\,k}.$$

For $k = 1$ this is just the ordinary sum of divisors; $\sigma_1(6) = 1+2+3+6
= 12$, the reason $6$ is called *perfect*. For $k = 2$ we sum squares of
divisors.

When $N = pq$ is a **semiprime** — a product of two distinct primes, exactly
the shape of an RSA modulus — the divisors are precisely $1, p, q, pq$, and the
sum factors beautifully:

$$\sigma_k(pq) \;=\; 1 + p^k + q^k + (pq)^k \;=\; (1 + p^k)(1 + q^k).$$

Call this quantity the **free witness of order $k$**. It is "free" in the sense
that it is a completely canonical, unforced piece of arithmetic data attached
to $N$ — nobody has to choose it, and nobody has to be told it. It is simply
what the divisors of $N$ add up to.

The witness is a witness because it *testifies* to the factorization. Here is
the exact mechanism, in the case $k = 2$.

> **The Trace Identity.** Let $N = pq$ with $p \ne q$ prime. Then
> $$\sigma_2(N) + 2N \;=\; (p+q)^2 + N^2 + 1.$$

The proof is a one-line expansion: $\sigma_2(N) = (1+p^2)(1+q^2) = 1 + p^2 +
q^2 + N^2$, and $p^2 + q^2 + 2pq = (p+q)^2$. But look at what it says. The
quantity

$$t \;=\; p + q,$$

which number theorists call the **trace** of the factorization (it is the trace
of the companion matrix of the quadratic satisfied by $p$ and $q$), is
recovered from $\sigma_2(N)$ by a square root:

$$t \;=\; \sqrt{\sigma_2(N) + 2N - N^2 - 1}.$$

For $N = 187$: $35380 + 374 - 34969 - 1 = 784 = 28^2$, so $t = 28 = 11 + 17$.

And once you know the sum $t = p+q$ and the product $N = pq$, the primes are
the two roots of $x^2 - tx + N$ — the quadratic formula finishes the job:

$$p, q \;=\; \frac{t \pm \sqrt{t^2 - 4N}}{2}.$$

For $N = 187$: $\sqrt{784 - 748} = 6$, giving $(28-6)/2 = 11$ and $(28+6)/2 =
17$. Done.

> **Recovery Theorem.** For distinct primes $p < q$ with $N = pq$, set $t =
> \sqrt{\sigma_2(N) + 2N - N^2 - 1}$ and $d = \sqrt{t^2 - 4N}$. Then $p =
> (t-d)/2$ and $q = (t+d)/2$; equivalently, $X^2 - tX + N$ factors over the
> integers as $(X - p)(X - q)$.

There is nothing special about $k = 2$ here, except convenience. A more
general rigidity statement holds at every order and needs no primality at all:

> **Witness Rigidity.** Fix $k \ge 1$. If $ab = cd$ and $(1+a^k)(1+b^k) =
> (1+c^k)(1+d^k)$ for non-negative integers, then $\{a,b\} = \{c,d\}$.

Why? Expand: the witness equals $1 + (a^k + b^k) + (ab)^k$. Since the products
agree, so do the terms $(ab)^k = (cd)^k$, hence the *power sums* agree: $a^k +
b^k = c^k + d^k$. Sum and product of a pair determine the pair (they are the
two roots of the same monic quadratic), so $\{a^k, b^k\} = \{c^k, d^k\}$, and
$x \mapsto x^k$ is injective on non-negative integers.

That parenthetical is worth isolating, because it is the workhorse of the whole
subject:

> **Sum–Product Lemma.** If $ab = cd$ and $a + b = c + d$, then $\{a,b\} =
> \{c,d\}$. Indeed $(a - c)(a - d) = a^2 - (c+d)a + cd = a^2 - (a+b)a + ab =
> 0$.

So the full witness is a *complete invariant*: the pair $(N, \sigma_k(N))$
knows everything about the unordered factor pair. Which raises the obvious
question, and it is the question this work answers.

---

## How much of the witness do you actually need?

$\sigma_2(N)$ is a big number — roughly $N^2$, so about twice as many digits as
$N$ itself. The trace $p+q$ is small, roughly $\sqrt{N}$. So the recovery
formula compresses a $2\log N$-bit input down to a $\tfrac12 \log N$-bit
answer. Most of $\sigma_2(N)$ is apparently redundant.

Suppose an adversary is handed only a *residue*: not $\sigma_2(N)$ itself but
$\sigma_2(N) \bmod m$ for some modulus $m$. How large must $m$ be before that
residue still pins down the factorization uniquely?

The naive guess — and the guess this project set out to confirm — was that $m$
must be about as large as the trace, $m \approx p + q \approx \sqrt{N}$.
Numerical experiments in bit-lengths 14 through 26 seemed to nail down a
strikingly clean constant, $m^\star \approx 5(p+q)$, suspiciously exactly
$5.00$. The intuition was seductive: the answer you are trying to recover is
the trace, so the modulus has to be big enough to *hold* a trace.

That intuition is wrong, and the reason it is wrong is that the threshold is
not a **size** question at all. It is a **divisibility** question.

---

## The separation principle

Here is the shift in viewpoint that dissolves the problem. "Determining the
factorization from $\sigma_k(N) \bmod m$" means: no *other* way of writing $N
= ab$ produces the same witness residue. So we should compare candidate
factorizations.

> **Separation Principle.** Let $ab = cd$. Then the witnesses of the two
> factorizations agree modulo $m$,
> $$(1+a^k)(1+b^k) \equiv (1+c^k)(1+d^k) \pmod m,$$
> if and only if
> $$m \;\big|\; (a^k + b^k) - (c^k + d^k).$$

Again the proof is expansion: the witness is $1 + (a^k+b^k) + (ab)^k$, and the
last term is common to both sides. Two factorizations of the same $N$ are
indistinguishable modulo $m$ exactly when $m$ divides the difference of their
**power-sum coordinates**. The witness sees a factorization only through that
one coordinate — at $k=1$, literally through the trace.

Now specialize to a semiprime. A semiprime has only *two* factorizations,
$N = 1 \cdot N$ and $N = p \cdot q$ (order aside), a fact one proves by
Euclid's lemma. So there is exactly one competitor to rule out, the trivial
one, and exactly one number that measures how far away it is:

$$G_k(p,q) \;=\; \big(1 + 1^k\big)\big(1+N^k\big) - \big(1+p^k\big)\big(1+q^k\big) \;=\; (p^k - 1)(q^k - 1).$$

We call $G_k$ the **witness gap**. Everything now collapses into a single
crisp statement.

> **Sharp Threshold Theorem.** Let $N = pq$ with $p, q$ prime. The residue
> $\sigma_k(N) \bmod m$ determines the factorization of $N$ **if and only if**
> $$m \nmid (p^k - 1)(q^k - 1).$$

No inequality. No size condition. No constant. A modulus works precisely when
it fails to divide one specific integer.

---

## The conjecture dies, spectacularly

Once the criterion is a divisibility, the conjectured law $m^\star \approx
5(p+q)$ cannot survive. Small moduli that happen to miss $G_2$ work perfectly,
no matter how astronomically large $p$ and $q$ are.

Take $N = 11 \cdot 17 = 187$ again, with trace $28$; the conjecture predicted a
threshold near $140$. But $G_2 = (121-1)(289-1) = 120 \cdot 288 = 34560$, and
$34560 = 7 \cdot 4937 + 1$, so $7 \nmid G_2$. Therefore $\sigma_2(187) \bmod 7$
— five bits of information — already determines that $187 = 11 \cdot 17$.

And this is not a small-numbers accident. It happens forever.

> **Constant-Modulus Theorem.** For every bound $B$ there exist primes $B < p
> < q$ such that the single fixed modulus $m = 7$ determines the factorization
> of $N = pq$ from $\sigma_2(N) \bmod 7$.

The proof is a beautiful two-step. By Dirichlet's theorem on primes in
arithmetic progressions, there are infinitely many primes congruent to $2$
modulo $7$; choose two of them, both larger than $B$. Then modulo $7$,
$$G_2 = (p^2-1)(q^2-1) \equiv (4-1)(4-1) = 9 \equiv 2 \not\equiv 0,$$
so $7 \nmid G_2$, and the Sharp Threshold Theorem does the rest. The threshold
stays bounded by an absolute constant while $p+q$ marches off to infinity. The
$\Theta(p+q)$ law is refuted, decisively and for all time.

What the experiments had actually measured was not a law of arithmetic but a
property of their search window: within a fixed range of bit-lengths, sampling
random semiprimes, the *typical* smallest working modulus was small, and the
particular numerical ratio $5.00$ was an artifact of how the window and the
sampling interacted.

---

## But five is real

The number $5$ was not entirely a mirage; it was in the right place for the
wrong reason. Here is the true statement it was shadowing.

> **Universal Lower Bound.** If $p, q > 3$ are prime, then no modulus $m$ with
> $1 \le m \le 4$ determines the factorization of $N = pq$ from $\sigma_2(N)
> \bmod m$.

Why? Because of a charming elementary fact: for every prime $p > 3$,
$$24 \mid p^2 - 1.$$
(Indeed $p$ is odd, so $p^2 - 1 = (p-1)(p+1)$ is a product of two consecutive
even numbers, giving a factor $8$; and $p$ is not divisible by $3$, so $p^2
\equiv 1 \pmod 3$.) Hence $24 \mid G_2$, and since every $m \le 4$ divides
$24$, every such $m$ divides the gap and therefore fails.

So the least working modulus is always at least $5$ — a genuinely universal
constant, independent of the size of $N$. And exactly when is it *equal* to
$5$? The criterion is completely local:

> **Exact-Five Theorem.** For primes $p, q > 3$, the least modulus determining
> the factorization from $\sigma_2 \bmod m$ equals $5$ if and only if neither
> $p$ nor $q$ is congruent to $\pm 1$ modulo $5$.

Because $5 \mid p^2 - 1$ exactly when $p \equiv \pm 1 \pmod 5$. So the real law
is $m^\star = 5$ — a constant, not $5(p+q)$ — for the substantial family of
semiprimes whose factors sit in the residue classes $\pm 2 \bmod 5$.

There is also a general upper bound with the same flavor. Since $G_2 < N^2$,
the gap has at most $\log_2 G_2 < 2\log_2 N$ distinct prime divisors. So:

> **Counting Theorem.** Among any collection of more than $\omega(G_k)$
> distinct primes — in particular, among any $2\log_2 N + 1$ distinct primes —
> at least one determines the factorization. Equivalently, if the gap is
> smaller than $2^{\pi(x)}$, some prime modulus below $x$ works.

Only $O(\log N)$ candidate moduli ever need to be considered. The
factor-determining information in $\sigma_2$ lives in a logarithmically small
window of its bits, not in the top $2\log N$ of them.

---

## The RSA connection: the totient in disguise

Run the same machinery at order $k = 1$ and something familiar walks out of the
algebra. The gap becomes

$$G_1(p,q) = (p-1)(q-1) = \varphi(N),$$

Euler's totient — the private key material of RSA.

> **Totient Theorem.** The residue $\sigma_1(N) \bmod m$ determines the
> factorization of $N = pq$ if and only if $m \nmid \varphi(N)$.

This is a small gem. The obstruction to partial-information factoring at order
$1$ is *literally* the RSA trapdoor. The classical statement "knowing
$\varphi(N)$ is equivalent to factoring $N$" appears here in a refined,
modular form: knowing $\sigma_1(N)$ modulo anything that fails to divide
$\varphi(N)$ is already enough. Conversely, residues modulo divisors of
$\varphi(N)$ are exactly the blind spots. At general order $k$ the pattern
persists: $p^k - 1 = |\mathbb{F}_{p^k}^\times|$, so the gap $G_k$ is the
product of the orders of the unit groups of the degree-$k$ extensions of the
prime fields — the totient tower.

---

## So why is your encryption still safe?

Every result above is *information-theoretic*. It says: the residue
$\sigma_k(N) \bmod m$ **determines** the factorization — a unique candidate is
compatible with the data. It says nothing about how to get that residue.

And that is where the whole edifice stops being a threat. To learn
$\sigma_2(N) \bmod 7$, you must first know $\sigma_2(N)$, or at least enough
about it, and $\sigma_2(N) = \sum_{d \mid N} d^2$ is a sum over the divisors of
$N$ — a quantity whose known evaluation requires the factorization you were
trying to find. Modular reduction does not help: there is no known way to
aggregate a divisor sum "modulo $7$" that avoids enumerating divisors. Call
this the **aggregation barrier**: the divisor-sum functional is cheap to
evaluate *given the factorization* and expensive otherwise, and the cost does
not go down when you only want a few bits of the answer.

That is the sharp negative content here, and it is genuinely informative rather
than merely disappointing. Naively one hopes: *if I only need $5$ bits of
$\sigma_2$, maybe I can compute $5$ bits cheaply.* The Sharp Threshold Theorem
makes the first half of that sentence true — spectacularly true, since a fixed
modulus like $7$ suffices infinitely often — and thereby isolates the second
half as the entire content of the barrier. Need and cost are decoupled. A
proof that divisor-sum aggregation is irreducible must therefore rule out
cheap computation of arbitrarily *partial* values, not just of $\sigma_2(N)$
itself. That is a strictly stronger, and now precisely stated, target.

---

## What to take away

Three ideas survive this story, and all three are worth carrying around.

**First, look for the invariant coordinate.** A factorization $N = ab$ has two
coordinates, the product and the sum. The product is fixed by hypothesis; the
free witness sees only the power sum. Every threshold phenomenon in this
subject is a shadow of that one-dimensionality — the Separation Principle is
nothing but the statement that the witness is a function of the trace
coordinate alone.

**Second, thresholds can be arithmetic, not metric.** The experiment asked
*how big* a modulus must be and got a confident, reproducible, precisely wrong
answer. The right question was *which* moduli work, and the answer, $m \nmid
(p^k-1)(q^k-1)$, has no size in it at all. A clean numerical constant
extracted from a finite window is a hypothesis, never a theorem; here the
constant $5.00$ was the ghost of a genuine universal constant — the true bound
$m^\star \ge 5$, forced by $24 \mid p^2 - 1$ — refracted through a sampling
window.

**Third, information and computation are different currencies.** Five bits of
$\sigma_2(N)$ can *contain* a $600$-digit factorization. Containing it and
being able to obtain it are unrelated. Cryptography lives in the gap between
those two verbs, and this work measures that gap precisely: the informational
requirement collapses to a constant, and the computational requirement does
not budge.

The number $35380$ knows that $187 = 11 \times 17$. Its analogue for a
$2048$-bit modulus knows your keys. Neither will tell you unless you already
know — and now we know exactly why *asking for less* does not help.
