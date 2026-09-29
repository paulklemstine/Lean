# The Seventh Root of Three, and What the Primes Whisper About It

*How a single residue — a prime's remainder modulo 7 — accounts for about 95% of what there is to know about how $x^7 - 3$ breaks apart*

---

## A polynomial meets the primes

Take the polynomial $x^7 - 3$. Over the rational numbers it cannot be factored: no product of two smaller polynomials with rational coefficients equals it. Now pick a prime $p$ and do all your arithmetic modulo $p$. The polynomial can suddenly fall apart.

Here is what happens for a few small primes:

- Modulo $p = 757$ it splits into seven linear factors: $x^7 - 3$ has seven distinct roots in the integers mod $757$. (This is the smallest prime where that happens.)
- Modulo $p = 13$ it factors as one linear piece times three quadratics, with degree pattern $1 + 2 + 2 + 2$.
- Modulo $p = 11$ the pattern is $1 + 3 + 3$.
- Modulo $p = 5$ the pattern is $1 + 6$.
- Modulo $p = 29$ (and $p = 43$) it stays in one piece, with pattern $7$.

The list of degrees is called the **splitting type** of $x^7-3$ at $p$. Number theorists have studied such patterns since Gauss, and they fill the central chapters of algebraic number theory. For a random-looking polynomial the pattern seems to jump around unpredictably from prime to prime. A natural question, and the one this work answers exactly, is:

> **How much of the splitting type can you predict from a simple fact about $p$, namely its remainder when divided by some number $m$?**

The answer is more precise than you might expect. Measured in bits, knowing $p \bmod 7$ tells you exactly
$$\frac13 + \log_2 3 \approx 1.918 \text{ bits}$$
about the splitting type, out of a total uncertainty of about $2.017$ bits. Knowing $p \bmod m$ for any $m$ **not** divisible by $7$ tells you nothing. That includes $m = 3$, even though $3$ is the other prime that appears in the polynomial. And $1/3 + \log_2 3$ is not a new constant. It is exactly the information content of a much simpler object from degree six: the order of a random element of a six-hour clock.

That last fact gives the result its title: *the framework extends*. An information law first seen in degree $6$ reappears unchanged in degree $7$, and then, as we will see, in every prime degree.

## Measuring predictability in bits

To make "how much you can predict" precise we use Claude Shannon's information theory.

Suppose a quantity $T$ takes finitely many values with probabilities $\pi_1, \pi_2, \dots$. Its **entropy** is
$$H(T) = -\sum_i \pi_i \log_2 \pi_i ,$$
which is the average number of yes/no questions needed to pin $T$ down. A fair coin has entropy $1$ bit, and a fair die has $\log_2 6 \approx 2.585$ bits.

If a second quantity $R$ is revealed, some uncertainty about $T$ remains. The **conditional entropy** $H(T \mid R)$ is the average over the values of $R$ of the entropy of $T$ given that value. The **mutual information**
$$I(T;R) = H(T) - H(T\mid R)$$
is the amount of uncertainty that $R$ removes. It is never negative. It is zero exactly when $R$ is useless for predicting $T$, and it equals $H(T)$ when $R$ determines $T$ completely. It is also symmetric, $I(T;R) = I(R;T)$, and it satisfies the bookkeeping identity
$$I(T;R) = H(T) + H(R) - H(T,R).$$

For us, $T$ is the splitting type of $x^7-3$ at a "random prime" and $R$ is the prime's residue $p \bmod m$. To turn "random prime" into an honest probability we need one more ingredient, and it is where the symmetry comes in.

## The hidden symmetry: 42 affine maps of a seven-point clock

The seven complex roots of $x^7 - 3$ are
$$\zeta^j \cdot \sqrt[7]{3}, \qquad j = 0, 1, \dots, 6,$$
where $\zeta = e^{2\pi i/7}$ is a primitive seventh root of unity. Label the root $\zeta^j\sqrt[7]{3}$ by the number $j$ on a seven-hour clock, $\mathbb{Z}/7$.

The symmetries of these roots, meaning the field automorphisms that permute them (the **Galois group**), act on the labels in a very specific way. Each one has the form
$$j \;\longmapsto\; a\,j + b \pmod 7, \qquad a \in \{1,\dots,6\},\ b \in \{0,\dots,6\}.$$
Multiplying by $a$ comes from sending $\zeta \mapsto \zeta^a$. Adding $b$ comes from sending $\sqrt[7]{3} \mapsto \zeta^b\sqrt[7]{3}$. All $6 \times 7 = 42$ such maps occur. This is the **Frobenius group** $F_{42}$, also written $\mathrm{AGL}(1,7)$: the group of affine maps of the line over the field with seven elements.

Every prime $p$ other than $3$ and $7$ has a distinguished symmetry attached to it, its **Frobenius element**. Two classical facts connect Frobenius elements to our question:

1. **The linear part is the residue.** The multiplier $a$ in the Frobenius of $p$ is exactly $p \bmod 7$. This comes from the elementary behaviour of the seventh roots of unity modulo $p$.
2. **Chebotarev's density theorem.** As $p$ runs through the primes, its Frobenius is equidistributed over the group. In the long run each of the 42 affine maps is hit by $1/42$ of the primes.

A third fact, due to Frobenius and Dedekind, closes the loop: **the splitting type of $x^7 - 3$ modulo $p$ is the cycle structure of the Frobenius permutation of the seven roots.** A cycle of length $d$ in the permutation corresponds to an irreducible factor of degree $d$.

So the whole number-theoretic question turns into a finite puzzle about 42 permutations of a seven-point clock. The rest of this work solves that puzzle exactly.

## What an affine map does to a clock

Take the map $x \mapsto ax + b$ on $\mathbb{Z}/7$, or more generally on any field. How does it permute the points?

**Case $a \ne 1$.** The equation $ax + b = x$ has exactly one solution, $x_0 = b/(1-a)$. Subtracting it gives
$$f(x) - x_0 = a\,(x - x_0), \qquad\text{so}\qquad f^{k}(x) - x_0 = a^k (x - x_0).$$
A point $x \ne x_0$ comes back to itself after $k$ steps exactly when $a^k = 1$. So **every point other than the fixed point lies on a cycle of the same length**, namely the multiplicative order of $a$. The map is a single fixed point plus $6/\operatorname{ord}(a)$ cycles of length $\operatorname{ord}(a)$.

**Case $a = 1$, $b \ne 0$.** Now $f^{k}(x) = x + kb$, which returns to $x$ only when $7$ divides $k$. There are no fixed points and one big seven-cycle.

**Case $a = 1$, $b = 0$.** The identity: seven fixed points.

Translated back into factorisations of $x^7 - 3$ modulo $p$, where $a = p \bmod 7$:

| $p \bmod 7$ | Frobenius | factor degrees | share of primes |
|---|---|---|---|
| $1$, and $3$ is a 7th power mod $p$ | identity | $1+1+1+1+1+1+1$ | $1/42$ |
| $1$, and $3$ is not a 7th power | 7-cycle | $7$ | $6/42$ |
| $6$ (order 2) | fixed point + three 2-cycles | $1+2+2+2$ | $7/42$ |
| $2, 4$ (order 3) | fixed point + two 3-cycles | $1+3+3$ | $14/42$ |
| $3, 5$ (order 6) | fixed point + one 6-cycle | $1+6$ | $14/42$ |

The table already shows the main phenomenon. **Four of the five rows are determined by $p \bmod 7$ alone.** Only when $p \equiv 1 \pmod 7$ is anything left to chance, namely whether $x^7-3$ splits completely or stays irreducible, and even then the odds are lopsided, $1$ to $6$.

## Counting the bits

Now the arithmetic. The five splitting types have probabilities $\tfrac{1}{42}, \tfrac{6}{42}, \tfrac{7}{42}, \tfrac{14}{42}, \tfrac{14}{42}$, so the total uncertainty is
$$H(T) = \frac{4}{21} + \frac{6}{7}\log_2 3 + \frac16 \log_2 7 \approx 2.0169 \text{ bits}.$$

The residue $p \bmod 7$ is uniform over six values, so it carries $\log_2 6$ bits. The pair (type, residue) has fibres of sizes $1, 6, 7, 7, 7, 7, 7$ out of $42$, and entropy $\tfrac67 + \tfrac67\log_2 3 + \tfrac16\log_2 7$. The bookkeeping identity then gives

> **Conductor signal for $x^7-3$.** $\displaystyle I(T;\ p \bmod 7) = \frac13 + \log_2 3 \approx 1.9183$ bits.

That is about $95.1\%$ of the total. The remaining uncertainty, the **residual**, is only
$$H(T \mid p \bmod 7) = \frac{7\log_2 7 - 6 \log_2 6}{42} \approx 0.0986 \text{ bits}.$$
It is exactly the uncertainty of the one lopsided coin toss (split completely or stay irreducible?) that is only tossed when $p \equiv 1 \pmod 7$.

## The echo from degree six

Where have we seen $\tfrac13 + \log_2 3$ before?

Pick a random element of the cyclic group $\mathbb{Z}/6$ (a six-hour clock) and record its **order**, the number of times you have to add it to itself to get back to $0$. The element $0$ has order $1$. The element $3$ has order $2$. The elements $2$ and $4$ have order $3$. The elements $1$ and $5$ have order $6$. The entropy of this "cyclic type" is
$$\tfrac16\log_2 6 + \tfrac16 \log_2 6 + \tfrac26\log_2 3 + \tfrac26\log_2 3 = \frac13 + \log_2 3 .$$

This is the same number. It is also the information carried by the splitting type of a degree-six polynomial with cyclic Galois group $C_6$, the *sextic cyclic type channel*. The degree-seven conductor signal is **exactly** the degree-six cyclic type entropy:
$$I\big(T_{x^7-3};\ p \bmod 7\big) = \mathcal{T}(6),$$
where $\mathcal{T}(n)$ denotes the entropy of the order of a uniformly random element of $\mathbb{Z}/n$.

The coincidence has a clean explanation. The residue $p \bmod 7$ lives in the multiplicative group $(\mathbb{Z}/7)^\times$, which is a cyclic group of order $6$. Away from $a = 1$, the splitting type is just the order of $a$ dressed up in different clothes. At $a = 1$ the type carries one extra coin toss (split or irreducible?), but that coin is invisible to the residue, so it adds nothing to the shared information. What the residue knows about the type is therefore exactly the order of $a$, where $a$ is a uniformly random element of a cyclic group of order $6$. The entropy of that order is $\mathcal T(6)$.

## Every prime degree at once

Nothing in that argument used the number $7$. Replace it with any prime $q$ and consider the full affine group $\mathrm{AGL}(1,q)$ acting on $q$ points. This is the Galois group of $x^q - c$ for a generic integer $c$. The same reasoning gives a universal law.

> **Conductor law, every prime degree.** For the uniform Frobenius in $\mathrm{AGL}(1,q)$ with splitting type $T$ and linear part $a = p \bmod q$,
> $$I(T;\ p \bmod q) = \mathcal{T}(q-1), \qquad H(T\mid p\bmod q) = \frac{q\log_2 q - (q-1)\log_2(q-1)}{q(q-1)} \le \frac{\log_2 q}{q-1}.$$

The residual is at most $(\log_2 q)/(q-1)$, and in fact shrinks roughly like $(\log_2 q)/q^2$. Meanwhile the signal $\mathcal T(q-1)$ is never less than one bit when $q$ is odd. The reason is short: $q-1$ is even, and "is the order of $a$ a divisor of $(q-1)/2$?" is the same question as "is $a$ an even power of a generator?", a fair coin that the order already answers. Putting the two facts together:

> **Information completeness.** For every odd prime $q$,
> $$\frac{I(T;\ p\bmod q)}{H(T)} \;\ge\; 1 - \frac{\log_2 q}{q-1}.$$

So the fraction of the splitting type explained by one residue tends to $100\%$ as the degree grows. The actual ratios are much better than the bound: $68.5\%$ for $q=3$, $89.3\%$ for $q=5$, $95.1\%$ for $q=7$, $98.7\%$ for $q = 13$, and $99.85\%$ for $q = 43$.

## Silence everywhere else

Why does $p \bmod 5$, or $p \bmod 3$, say nothing?

Residues modulo $m$ are *abelian* information. By class field theory they are recorded by the cyclotomic field $\mathbb{Q}(\zeta_m)$, whose Galois group $(\mathbb{Z}/m)^\times$ is commutative. Anything a residue can tell you about the Frobenius must pass through a homomorphism from $F_{42}$ to a commutative group.

Here an elegant identity takes over. Write $t_c$ for the translation $x \mapsto x+c$ and $s_a$ for the scaling $x \mapsto ax$. Then
$$t_{(a-1)c} \;=\; s_a\, t_c\, s_a^{-1}\, t_c^{-1}.$$
**Every translation is a commutator.** A homomorphism into a commutative group sends every commutator to the identity. So:

> **Abelian obstruction.** Every homomorphism from an affine group (one containing a non-trivial scaling and all translations) to a commutative group kills all translations.

Abelian data can therefore see only the linear part $a$, which is $p \bmod 7$. It cannot see the translation part $b$, which records how $\sqrt[7]{3}$ moves. That is why the prime $3$, although it appears in the polynomial and is ramified in its splitting field, is **not** a signal modulus. Whatever $p \bmod 3$ knows, it knows only through a commutative quotient, and that quotient is already accounted for by $p \bmod 7$. For moduli $m$ coprime to $7$ the cyclotomic field $\mathbb{Q}(\zeta_m)$ is independent of the relevant symmetry, and in that product model the mutual information is exactly zero.

## Checking against real primes

Theory predicts; the primes can be asked directly. Factoring $x^7-3$ modulo each of the $17{,}982$ primes below $200{,}000$ (leaving out $3$ and $7$) gives:

| splitting type | observed share | predicted |
|---|---|---|
| $1^7$ (split) | $0.0235$ | $0.0238$ |
| $7$ (inert) | $0.1424$ | $0.1429$ |
| $1+2^3$ | $0.1666$ | $0.1667$ |
| $1+3^2$ | $0.3331$ | $0.3333$ |
| $1+6$ | $0.3345$ | $0.3333$ |

The empirical mutual information with $p \bmod m$ is about $1.917$ bits for $m = 7, 14, 21, 35$, against the predicted $1.918$. For $m = 2, 3, 4, 5, 6, 11, 13$ it is below $0.001$ bits, which is statistical noise from a finite sample.

## Why this matters

On one level this is a small, exact piece of arithmetic statistics. On another it is a proof of concept: an information-theoretic lens on splitting types that was built for cyclic sextic fields carries over *verbatim* to a non-abelian group in degree seven, and then to every prime degree. The results line up as follows:

- The signal lives at the **abelian conductor**, not at every ramified prime.
- Its size is a **cyclic** invariant $\mathcal T(q-1)$, inherited from the multiplicative group of the residue field.
- What is left over is **small and explicit**, the entropy of one biased coin, weighted by the chance that it is tossed.

The picture suggests a general principle, left open here: for any Galois group, the best any single modulus can do is the information carried by the group's abelianization. For a *perfect* group, such as the simple group $\mathrm{PSL}(2,7)$ that governs certain other septic polynomials, the prediction would be total silence at every modulus. Whether the primes agree is the next experiment.
