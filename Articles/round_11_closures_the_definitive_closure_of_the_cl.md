# The Locked Room: Why a Beautiful Fingerprint of a Semiprime Tells You Nothing

## A number with a secret

Take two large prime numbers, $p$ and $q$, multiply them, and publish the product $N = pq$. That single act — trivial to perform, apparently impossible to undo — is the load-bearing wall of much of modern cryptography. Everyone can see $N$. Almost nobody can recover $p$ and $q$.

The natural question is not "can we factor $N$?" — sometimes we can, with enough computing power — but something subtler and more interesting: **where, exactly, is the information hiding?** If $N$ knows its own factors, and we can read off any function of $N$ we like in a reasonable amount of time, why can we never seem to read off anything that *depends* on $p$ and $q$ separately?

This article is about a family of very concrete answers to that question. We will build an object — the *cycle-index fingerprint* — that looks, at first sight, like exactly the kind of rich, structured, spectral gadget that ought to leak a secret. We will decompose it with the Möbius inversion formula, count its orbits with Burnside's lemma, and measure the information it carries. And each time, with an exactness that is almost comic, the answer will be: **nothing, until suddenly everything**.

## The fingerprint

Fix $N = pq$ and pick a base $b$ with no factor in common with $N$ — say $b = 2$. Now define, for each positive integer $c$,

$$F(c) \;=\; \gcd\!\left(b^{c} - 1,\; N\right).$$

This is the oldest trick in the computational-number-theory book. Compute $b^c \bmod N$ by repeated squaring, subtract one, take a greatest common divisor with $N$. Every step is fast: for a $2048$-bit $N$ you can evaluate $F(c)$ for any $c$ you like in a few milliseconds. The sequence $F(1), F(2), F(3), \dots$ is a kind of fingerprint of the pair $(N, b)$ — a signal, freely computable by anyone, that in principle reflects the hidden arithmetic of $p$ and $q$.

What does that signal actually look like? Here is the first, wholly elementary, structural fact.

> **Structure Theorem.** Let $N = pq$ with $p \neq q$ prime and let $b \geq 1$. Write $d_p$ for the multiplicative order of $b$ modulo $p$ (the least positive $k$ with $b^k \equiv 1 \bmod p$), and $d_q$ likewise. Then for every $c$,
> $$F(c) \;=\; p^{[\,d_p \mid c\,]} \cdot q^{[\,d_q \mid c\,]},$$
> where $[\,\cdot\,]$ is $1$ if the statement holds and $0$ otherwise.

The proof is three lines. A prime $p$ divides $b^c - 1$ exactly when $b^c \equiv 1 \bmod p$, which happens exactly when the order $d_p$ divides $c$; the greatest common divisor of $b^c - 1$ with a prime is either that prime or $1$; and because $p$ and $q$ are coprime, the gcd with the product splits as the product of the gcds.

So the fingerprint is a **two-tone square wave**. It equals $1$ almost everywhere, jumps to $p$ at every multiple of $d_p$, jumps to $q$ at every multiple of $d_q$, and jumps to the full $N$ at every common multiple. Nothing else ever happens.

## The order seal

That description already contains the punchline, and it is worth stating in its starkest form. Let

$$d^{*} \;=\; \min(d_p, d_q).$$

> **The Order Seal.** For every $c$ with $0 < c < d^{*}$ we have $F(c) = 1$. At $c = d^{*}$ we have $F(d^{*}) > 1$; indeed $d^{*}$ is the *least* index at which the fingerprint is nontrivial. And when $d_p \neq d_q$, the value $F(d^{*})$ is a proper nontrivial divisor of $N$ — that is, it *is* $p$ or $q$.

Read that again, because it is the whole story in miniature. Below the threshold $d^*$, the fingerprint is the constant function $1$ — the *same* constant function for every semiprime, for every base, for every choice of secret whatsoever. It is a blank page. At the threshold, it hands you the factorization outright.

There is no gentle transition, no gradual accumulation of evidence, no statistical edge that a clever attacker might amplify. Information does not seep out of the fingerprint; it arrives all at once, at a single index, and that index is precisely as expensive to reach as factoring itself. For a generic base $b$ modulo a generic semiprime, $d_p$ and $d_q$ are comparable in size to $p$ and $q$, so $d^{*}$ is of order $\sqrt{N}$ — the same square-root wall that every elementary factoring method runs into. The seal is not an accident of this construction. It *is* the wall, expressed in the language of orders.

## Möbius: a genuinely new decomposition that moves nothing

Whenever a sequence has hidden multiplicative structure, the reflex of a number theorist is to apply Möbius inversion — the arithmetic analogue of a Fourier transform, which strips away divisibility redundancies and isolates what is happening at each *scale* $d$. Define the spectral coefficients

$$M_d \;=\; \sum_{c \mid d} \mu\!\left(\frac{d}{c}\right) F(c),$$

where $\mu$ is the Möbius function ($\mu(1)=1$; $\mu(m)=(-1)^k$ if $m$ is a product of $k$ distinct primes; $\mu(m)=0$ if $m$ has a repeated prime factor). Each $M_d$ is computable from $N$ and $b$ alone, in time polynomial in the number of divisors of $d$. This is a legitimately new way to look at the fingerprint — the transform is genuine, the coefficients are not obviously trivial, and the construction is exactly the sort of thing one hopes will relocate hidden information into a cheaper place.

It does not. Here is the complete spectrum.

> **The Four-Atom Spectrum.** For every $d \geq 1$,
> $$M_d \;=\; [\,d = 1\,] \;+\; (p-1)\,[\,d_p = d\,] \;+\; (q-1)\,[\,d_q = d\,] \;+\; (p-1)(q-1)\,[\,n = d\,],$$
> where $n = \mathrm{lcm}(d_p, d_q)$ is the order of $b$ modulo $N$.

The spectrum is a sum of **four point masses**. There is a trivial atom of mass $1$ at $d = 1$; an atom of mass $p-1$ sitting at the order $d_p$; an atom of mass $q-1$ at $d_q$; and an atom of mass $(p-1)(q-1) = \varphi(N)$, Euler's totient, at the global order $n$. Everywhere else the coefficient is exactly zero.

The masses are gorgeous: they are precisely the numbers an attacker would kill for, since knowing $\varphi(N)$ together with $N$ is the same as knowing $p$ and $q$. But they are *parked at the order scale*. Below $d^{*}$, every single coefficient $M_d$ equals $[\,d=1\,]$ — again the same universal vector $(1, 0, 0, 0, \dots)$ for every instance in the universe.

A companion transform makes the point even more sharply. If instead of the fingerprint values you Möbius-invert the exponent of $p$ in $F(c)$ — which is just the indicator of $d_p \mid c$ — you get an exact delta function:

$$\sum_{c \mid d} \mu\!\left(\frac{d}{c}\right) v_p\big(F(c)\big) \;=\; [\,d_p = d\,].$$

The spectrum of the fingerprint is *literally* an order detector, nothing more. Summed over an observation window $1 \le d \le D$, it returns $1$ if $d_p \le D$ and $0$ otherwise: a single bit, the bit that says "you have reached the order scale". Anyone who could read that bit cheaply could factor. The Möbius structure is real mathematics; it is also, from the attacker's point of view, a beautifully lit empty room.

## The hint that would work, and the source that does not exist

There is a genuine soft spot in the theory of factoring, and it is worth being precise about it. If you know $N = pq$ *and* the sum $\sigma = p + q$, you are done immediately:

> **Sum–Product Inversion.** Two positive integers are determined, up to order, by their sum and their product. So $(N, \sigma)$ determines $\{p, q\}$.

Indeed $p$ and $q$ are the roots of $x^2 - \sigma x + N$. More impressively, lattice-based methods in the spirit of Coppersmith's theorem on small solutions of modular polynomial equations turn an *approximation* $\hat{\sigma}$ with $|\hat{\sigma} - (p+q)| < N^{1/4}$ into a full factorization in polynomial time. So there is a real, unpriced channel: **any** source of even mildly accurate information about $p+q$ breaks the scheme.

The question is whether the fingerprint can be that source. It cannot, and the reason is the order seal, made into an information-theoretic statement.

Fix an observation window: the attacker is allowed to see $F(1), F(2), \dots, F(D)$. Take any finite family $\Omega$ of instances $(p, q, b)$ — chosen however you like, adversarially, with any distribution — subject only to the condition that both orders exceed the window, $D < \min(d_p, d_q)$. Fix any modulus $\ell$, and let the secret be $S = (p+q) \bmod \ell$.

> **Starvation Theorem.** On such a family, the truncated fingerprint carries *exactly zero* information about $(p+q) \bmod \ell$. Every joint fibre has exactly product cardinality: the number of instances with a given fingerprint window *and* a given secret value equals the product of the two counts divided by $|\Omega|$. Moreover, by the data-processing principle, **any** function of the window — a hash, a projection, a machine-learned estimator $\hat\sigma$, anything at all — is equally starved.

The proof is a single observation: below the order scale the window is a *constant* function of the instance, so its fibres are either empty or all of $\Omega$, and a constant statistic is trivially independent of everything. Not "approximately independent", not "independent up to a negligible bias" — independent on the nose, as an identity between integers counting instances. This is the strongest form the statement can take, and it is why the phrase for the situation is that the hint-amplification channel is *starved*: the amplifier exists and works, but there is no signal to feed it.

Two guardrails keep this from being a triviality. First, the hypothesis is satisfiable: for instance $(p,q,b) = (3,5,2)$ both orders exceed $1$, so a window of length $1$ is legitimate. Second, and more importantly, the theorem is **sharp**. Widen the window to reach the order scale and independence fails immediately: on the two instances $(p,q,b) = (3,5,2)$ and $(3,7,2)$, the window $1 \le c \le 4$ separates them — because the order of $2$ modulo $7$ is $3$, one has $F(3) = 7$ while the other has $F(3) = 1$ — and $(p+q) \bmod 3$ separates them too. The zero-information result is a statement about the sub-order-scale regime, not an artefact of a weak definition.

## Burnside's mirror

One more attack deserves its own paragraph, because it comes from a completely different direction and lands in exactly the same place.

Instead of arithmetic, think topologically. The base $b$ generates a cyclic group acting on the ring $\mathbb{Z}/N$ by multiplication; the natural invariant of a group action is its number of orbits, and the number of orbits is a kind of "homotopy cardinality" of the associated quotient groupoid. Perhaps *that* invariant is cheaper to compute than the factorization?

Burnside's lemma says the orbit count is the average number of fixed points. And here is the beautiful bridge: the number of $x \in \mathbb{Z}/N$ fixed by multiplication by $b^{k}$ is

$$\#\{x : b^{k} x = x\} \;=\; \gcd(b^{k}-1, N) \;=\; F(k).$$

The fixed-point count *is* the fingerprint. So the topological invariant is nothing but a Burnside average of the very sequence whose spectrum we have just shown to be sealed. Averaging it over one full period $n = \mathrm{lcm}(d_p,d_q)$ gives, exactly,

> **Orbit-Count Identity.** With $C$ the number of orbits of $\langle b\rangle$ acting on $\mathbb{Z}/N$,
> $$C \cdot n \;=\; n \;+\; (p-1)\frac{n}{d_p} \;+\; (q-1)\frac{n}{d_q} \;+\; (p-1)(q-1),$$
> equivalently $C = 1 + \dfrac{p-1}{d_p} + \dfrac{q-1}{d_q} + \dfrac{\varphi(N)}{n}$.

A lovely formula — and a closed door. To evaluate the right-hand side you need $\varphi(N)$ and the local orders, which is to say you need the factorization. Conversely, if an oracle handed you $C$, would you learn anything? Rearranging with $(p-1)(q-1) = N - p - q + 1$ turns the identity into an **affine observation**

$$\left(\frac{n}{d_p}-1\right)p \;+\; \left(\frac{n}{d_q}-1\right)q \;=\; C n - n + \frac{n}{d_p} + \frac{n}{d_q} - N - 1,$$

and a weighted version of sum–product inversion shows that any such affine relation, combined with $pq = N$, pins the factorization down to at most two candidates. So the orbit count is a factoring oracle — *except* in exactly the case where its coefficients vanish, namely the balanced case $d_p = d_q = d$. And there the identity degenerates to

$$C \cdot d \;=\; d + N - 1,$$

a function of $N$ and the global order alone, carrying no trace of how $N$ splits. The dichotomy is complete: the topological invariant is either uncomputable-without-factoring or informationless. Burnside's lemma re-sums the same sealed data. Category theory and topology, in this setting, give you re-encodings — not new computation.

## And a word on speed

A final, more prosaic closure. One can attempt to accelerate Pollard's rho method by an early-abort policy tuned to the Dickman function, which governs the density of integers with only small prime factors. Measurements give a mean speedup of about $1.95$. Is that a breakthrough?

No, and there is a clean statement of why. If a policy's running time $T$ is squeezed between a baseline $T'$ and $C\,T'$ for a constant $C \ge 1$, with $T' \to \infty$, then

$$\frac{\log T(n)}{\log T'(n)} \;\longrightarrow\; 1.$$

The *exponent* — the only thing that matters asymptotically for a subexponential algorithm — is untouched. A factor of $1.95$ buys you one bit of modulus. And the statement is sharp in the right direction: if the replacement is genuinely polynomial-strength, $T = (T')^{\theta}$, then the same ratio tends to $\theta$. Constant factors are free; exponents are not.

## What the locked room teaches

Put the pieces together and a single picture emerges. The cycle-index fingerprint, its Möbius spectrum, its Burnside average, its information content — four different mathematical languages, four different attempts to find a crack — all return the same verdict, and they return it as *theorems*, not as measurements. Below the order scale $d^{*} \sim \sqrt{N}$, every one of these objects is a **constant function of the instance**. It is not that the signal is small, or noisy, or hard to extract. There is no signal.

This is what a good negative result looks like in mathematics: not a shrug, but a map. The map says that the classical, uniform, hint-free attack surface around the fingerprint is closed, and it says *why* — everything on that surface is a linear functional of a two-tone square wave whose only feature is located at the order scale. It also draws the coastline of what remains open: the hint-amplification channel, which is real but has no known source computable from $N$; and the quantum exception, since a quantum computer's ability to find the order $n$ directly is precisely an ability to leap the wall that all of these classical arguments run into. Shor's algorithm does not break the seal — it walks straight to $d^{*}$.

The room is locked, and now we have the blueprints showing there is no window. That, in its own way, is a satisfying place to stand.
