# Free Witnesses: What a Number Tells You for Free

> **A guided tour.** By the end of this page you will know exactly what a modulus $N = pq$ gives away
> about its own factorisation, exactly how much of it is useless, exactly how deep you must dig
> before it becomes useful — and exactly which of those steps a quantum computer skips.
> No prior number theory beyond "remainders" is assumed; every dense argument is folded away behind
> a disclosure triangle, so you can read the narrative straight through and open the machinery only
> where you want it.

---

## 1. The question

Multiply two large primes and publish the product. That single act is the foundation of
[RSA](https://en.wikipedia.org/wiki/RSA_cryptosystem) and, through it, of a large part of digital
security. The product $N = pq$ is public; the factors are the secret. Everyone can check the
multiplication; nobody can undo it.

The question this page answers is not "can we factor?" but something sharper and more answerable:

> **If you are only allowed to ask $N$ a certain natural family of questions, how far can you get?**

Fixing the family makes the question mathematical rather than psychological, and lets us prove
theorems instead of reporting failures.

---

## 2. The family: counting roots of unity

Work with the *units* modulo $N$ — the residues $x$ with $\gcd(x, N) = 1$, the ones you can divide
by. For each exponent $k$, ask:

$$R_k(N) \;=\; \#\{x \bmod N \;:\; \gcd(x,N)=1,\ x^k \equiv 1 \pmod N\}.$$

How many $k$-th roots of unity are there? We call $R_k(N)$ the **free witness of exponent $k$**:
*free* because it depends only on $N$, and *witness* because its value constrains the factorisation.

<details>
<summary>Why this is the right family to study (click to expand)</summary>

Almost every classical exponent-based attack on a modulus reads from this family. Pollard's $p-1$
method searches for an exponent $k$ with $(p-1) \mid k$; order-finding computes the least $k$ with
$a^k \equiv 1$; Fermat and Euler tests probe $x^{N-1}$. All of these are queries about the exponent
structure of the unit group, which is precisely what $R_k$ records: $R_k(N)$ is the number of
elements whose order divides $k$, i.e. the cumulative distribution function of the order statistic.
Classify $R_k$ and you have classified the entire channel at one stroke.
</details>

**Play with it.** The widget below computes $R_k(N)$ two ways — the honest brute-force count over all
residues, and a closed formula we are about to derive. Change $p$, $q$ and $k$ and watch the two
numbers agree every time.

{{interactive_demo:0}}

---

## 3. The trace lemma: the family, solved

> **Theorem (Trace Lemma).** For $N = pq$ with $p \ne q$ prime,
> $$R_k(N) = \gcd(k,\,p-1)\cdot\gcd(k,\,q-1).$$

Three ingredients, none deeper than a first course in algebra.

<details>
<summary>Click to reveal the three-line proof</summary>

1. **Chinese remainder theorem.** Since $p$ and $q$ are coprime, arithmetic modulo $pq$ splits
   into arithmetic modulo $p$ and modulo $q$ independently:
   $(\mathbb{Z}/pq)^\times \cong (\mathbb{Z}/p)^\times \times (\mathbb{Z}/q)^\times$.
2. **Root counts multiply.** A pair $(x,y)$ satisfies $(x,y)^k = (1,1)$ exactly when both
   coordinates do, so the count over a product is the product of the counts.
3. **Cyclic root count.** Each factor is a [cyclic group](https://en.wikipedia.org/wiki/Cyclic_group)
   — of order $p-1$ and $q-1$ respectively — and in a cyclic group of order $n$ the equation
   $x^k = 1$ has exactly $\gcd(n,k)$ solutions, because the solution set is the kernel of the
   $k$-th power map, whose image has index $\gcd(n,k)$.

Multiply the two local counts and you are done. $\blacksquare$
</details>

The same three ingredients keep working when you add more primes. For a squarefree
$N = r_1 \cdots r_n$ we get $R_k(N) = \prod_i \gcd(k, r_i-1)$, and — using that the units modulo an
odd prime power are still cyclic — for **every odd $N$**:

$$R_k(N) \;=\; \prod_{p \mid N} \gcd\!\big(\varphi(p^{v_p(N)}),\ k\big).$$

Here is the algorithm this formula buys you: an evaluation of $R_k(N)$ in a handful of gcd
operations, where the definition would need a pass over all $N$ residues.

{{algorithm:0}}

**The first sting.** Both gcds in the trace lemma divide $k$, so
$$R_k(N) \ \big|\ k^2 .$$
A single free witness is *bounded by $k^2$* no matter how vast $N$ is — at most $2\log_2 k$ bits of
information. A 2048-bit secret cannot come out of that.

---

## 4. Aggregation: the obvious fix, and why it fails

If one witness is too small, use many. Fix a finite set $S$ of exponents and read the whole joint
profile $\big(R_k(N)\big)_{k \in S}$. Surely enough numbers pin down $p$?

They do not, and the reason is
[Dirichlet's theorem on primes in arithmetic progressions](https://en.wikipedia.org/wiki/Dirichlet%27s_theorem_on_arithmetic_progressions).

> **Theorem (Joint Closure).** For every finite exponent set $S$ and every prime $q$, there are
> infinitely many primes $p$ for which $N = pq$ has one and the *same* joint profile over $S$.
> Consequently no function of the profile can return a prime factor.

<details>
<summary>Click to reveal the proof — it is four lines</summary>

Let $M = \prod_{k \in S} k$. Dirichlet gives infinitely many primes $p \equiv 1 \pmod M$. For such a
prime, $M \mid p-1$, hence $k \mid p-1$ for every $k \in S$, hence $\gcd(k, p-1) = k$: the witness is
*saturated*. By the trace lemma the profile becomes
$$R_k(pq) = k \cdot \gcd(k, q-1), \qquad k \in S,$$
in which $p$ does not appear. Any two saturating primes therefore produce literally identical
profiles, and a function receiving identical inputs must return identical outputs. $\blacksquare$

Note how strong this is: the inputs are *equal*, not merely hard to tell apart. Unlimited running
time does not help; nor does nondeterminism; nor does any advice that depends only on the profile.
</details>

Here is the construction as runnable code, and then the picture: five different moduli, one profile.

{{algorithm:1}}

{{visualization:2}}

---

## 5. The price of completeness

Now the twist that makes this more than a negative result. The family is not blind in principle —
it is blind *cheaply*.

By the trace lemma, $R_k(N)$ hits its ceiling $\varphi(N) = (p-1)(q-1)$ exactly when $p-1$ and $q-1$
both divide $k$, i.e. exactly when $\operatorname{lcm}(p-1,q-1) \mid k$. And a single ceiling-value
witness gives up the secret immediately, via the schoolbook identity
$$(p-1)(q-1) + (p+q) = pq+1 :$$
knowing $\varphi(N)$ gives you $s = p+q = N+1-\varphi(N)$, and then $p,q$ are the roots of
$x^2 - sx + N$, i.e. $\tfrac12\big(s \pm \sqrt{s^2-4N}\big)$.

> **Theorem (Aggregation Depth).** The complete exponents are exactly the multiples of
> $\operatorname{lcm}(p-1,q-1)$, so the least one is
> $$\lambda(N) = \operatorname{lcm}(p-1,q-1) = \frac{\varphi(N)}{\gcd(p-1,q-1)} .$$
> For every odd modulus the same statement holds with $\lambda(N)$ the
> [Carmichael exponent](https://en.wikipedia.org/wiki/Carmichael_function)
> $\operatorname{lcm}_{p \mid N}\varphi(p^{v_p(N)})$.

For cryptographic primes $\gcd(p-1,q-1) = 2$, so the threshold is $\varphi(N)/2 \approx N/2$:
*linear in $N$*, exponential in the number of digits. Complete but unreachable.

{{algorithm:2}}

The heatmap below makes the geometry of the statement visible: the bright, complete cells sit on a
sparse lattice of multiples, and nothing you do with the dim cells in between ever brightens one.

{{visualization:0}}

And on a log-log plot over tens of thousands of semiprimes, the depth tracks $N$, not $\sqrt{N}$ —
the crude bound $R_k \mid k^2$ is true but far from sharp.

{{visualization:1}}

---

## 6. Where the quantum computer actually breaks in

[Shor's algorithm](https://en.wikipedia.org/wiki/Shor%27s_algorithm) factors in polynomial time by
computing the multiplicative order of a random residue. It is tempting to say it "computes something
classical algorithms cannot". The trace lemma says otherwise: the order is a *classified* coordinate
of the very family we just solved. What the quantum step does is **locate** such a coordinate in one
coherent evaluation, instead of paying the depth-$\lambda(N)$ aggregation cost.

And the payoff coordinate is common. By the trace lemma at $k=2$, a semiprime built from distinct
odd primes has exactly $R_2(N) = \gcd(2,p-1)\gcd(2,q-1) = 4$ square roots of unity. Two are
$\pm1$; the other two each split $N$:

> **Theorem (Residue-Witness Sufficiency).** If $a^2 \equiv 1 \pmod N$ and $a \not\equiv \pm1$, then
> $\gcd(a-1, N)$ is a prime factor of $N$.

<details>
<summary>Click to reveal the proof and the explicit construction</summary>

*Sufficiency.* $N = pq$ divides $(a-1)(a+1)$, so each of $p,q$ divides $a-1$ or $a+1$. They cannot
both divide $a-1$ (that would give $N \mid a-1$) nor both divide $a+1$. So exactly one of them
divides $a-1$, and $\gcd(a-1,N)$ is that prime.

*Existence.* By the Chinese remainder theorem, take the residue that is $1$ modulo $p$ and $-1$
modulo $q$. Squaring gives $(1,1)$, so $a^2 \equiv 1$; and $a \equiv 1$ would force its $q$-component
to be $1 \ne -1$, while $a \equiv -1$ would force its $p$-component to be $-1 \ne 1$. Both use only
that $p, q$ are odd. $\blacksquare$

For a general odd squarefree modulus the count is $2^{\omega(N)}$, where $\omega(N)$ is the number of
distinct prime factors. So the residue coordinate *knows how many* prime factors $N$ has, while
still being unable to *name* one without paying the aggregation cost. That gap is the subject of
this page in miniature.
</details>

{{algorithm:3}}

**Now race them.** The widget below runs both lanes side by side: the classical sweep grinding up
towards $\varphi(N)$, and the one-shot coordinate finishing before the animation starts.

{{interactive_demo:1}}

{{demo:1}}

---

## 7. What about random walks?

A recurring hope is that randomness finds what structure hides — as in
[Pollard's rho](https://en.wikipedia.org/wiki/Pollard%27s_rho_algorithm), which walks pseudo-randomly
and tests $\gcd$ at each step. The natural multiplicative variant $x \mapsto xs \bmod N$ with a
smooth step $s$ is provably sterile:

> **Theorem (Walk Sterility).** If the seed and the step are coprime to $N$, every value of the walk
> is coprime to $N$. Hence $\gcd(x_t, N) = 1$ always: the only channel through which such a walk can
> emit a factor is identically trivial. Moreover the orbit is a coset of the cyclic group generated
> by $s$, so the walk is periodic with period dividing $\operatorname{ord}_N(s)$.

The walk carries no randomness beyond that cyclic subgroup. Its one real resource is the
*smoothness* of the values it visits — exactly the resource the quadratic sieve and the number field
sieve already exploit, and which yields subexponential, never polynomial, time. Contrast Pollard's
rho, whose *quadratic* iteration can leave the unit group; that is precisely why rho can emit a
nontrivial gcd and the multiplicative walk cannot.

---

## 8. One hint changes everything

Finally, honesty about scope. Suppose someone leaks you the single number $s = p+q$. Then
$$p = \frac{s - \sqrt{s^2-4N}}{2}$$
and the factorisation falls out in constant time; moreover $(N, s)$ determines the ordered pair
uniquely. For $N = 8051$ and $s = 180$: $\sqrt{32400-32204} = 14$, so $p = 83$, and indeed
$8051 = 83\cdot 97$.

So the contrast is stark:

| channel | extractor |
|---|---|
| hint-free joint profile | **none exists**, at any running time |
| one external additive hint | explicit, closed form, constant time |

Methods in the [Coppersmith](https://en.wikipedia.org/wiki/Coppersmith_method) tradition amplify
roughly half the bits of $p$ into the full factorisation in polynomial time. That is not a
counterexample to anything above — it is a different problem: *amplification of external hints*
rather than *extraction from $N$ alone*. Any hardness claim must say which one it is about.

---

## 9. Everything at once

The complete numerical demonstration — trace lemma cross-checks, profile collisions, aggregation
depth, walk sterility, residue witnesses, hint amplification — with every displayed number verified
by assertion:

{{demo:0}}

---

## 10. Where this leaves us

1. Every invariant in the family is understood exactly: $R_k(N) = \prod_{p\mid N}\gcd(\varphi(p^{v_p}), k)$.
2. No finite aggregation of them can name a factor — an information-theoretic impossibility.
3. Completeness exists but sits at exponent depth $\lambda(N)$, of order $N$.
4. Multiplicative random walks emit no signal at all.
5. The quantum channel bypasses exactly one thing: the aggregation cost.
6. External hints are a separate, provably powerful resource.

What remains open is the summit: proving that the aggregation cost is unavoidable for *arbitrary*
classical algorithms, not merely those restricted to this channel. That would be a proof that
factoring is classically hard. Until then, what we have is an exact map of one large region of the
territory — and a precise statement of what makes the quantum computer special.

*The number $N$ is not silent. It answers every question in this family, promptly and exactly. It
just never answers the one you asked.*
