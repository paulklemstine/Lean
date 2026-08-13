# The Clock That Knows Everything Except the Secret

*How a beautiful exact law about squares and cycles turns out to be exactly as
useless for factoring as it is elegant.*

---

## A number that refuses to say its name

Take two large prime numbers, $p$ and $q$, multiply them together, and publish
the product $N = pq$. Keep $p$ and $q$ to yourself. That single asymmetry —
easy to multiply, apparently hard to unmultiply — is the load-bearing wall
under a large fraction of the world's encrypted traffic.

For fifty years people have been probing that wall, and one of the most
tempting strategies is *statistical*. You cannot factor $N$ directly, but you
can compute all sorts of cheap quantities attached to it. If any of those
quantities showed a systematic tilt that depended on $p$ and $q$ separately —
if the tilt were bigger when $p$ and $q$ were far apart, say — then the
statistics would be leaking. Enough leaked bits, and the wall comes down.

This is a story about one such statistic: the joint behaviour of two very
classical quantities, the **multiplicative order** and the **Jacobi symbol**.
The two are coupled by an exact, beautiful law. The bias it produces is
unmistakably real. And it leaks precisely nothing. We can now say that with
certainty, because the leak-proofness is a theorem, not a hope.

---

## Two ways of measuring a residue

Fix an odd number $N$ and pick a number $b$ with no factor in common with $N$
— what we will call a *unit* modulo $N$. There are $\varphi(N)$ of them, where
$\varphi$ is Euler's totient function. Two classical measurements attach to
each unit.

**The order.** Start multiplying $b$ by itself modulo $N$:
$$b,\quad b^2,\quad b^3,\quad \dots$$
Because there are only finitely many residues, this sequence must eventually
return to $1$. The first exponent $k \ge 1$ with $b^k \equiv 1 \pmod N$ is the
**multiplicative order** of $b$, written $\operatorname{ord}_N(b)$. It is the
length of the cycle $b$ traces out — how long the clock takes to come home.

**The symbol.** For an odd prime $p$, the **Legendre symbol** $\left(\frac{b}{p}\right)$
is $+1$ if $b$ is a perfect square modulo $p$ and $-1$ if it is not. Exactly
half the units at a prime are squares, so this is a perfectly fair coin. For a
composite modulus $N = pq$, the **Jacobi symbol** is the product
$$J(b \mid N) \;=\; \left(\tfrac{b}{p}\right)\left(\tfrac{b}{q}\right),$$
and — here is the crucial point for cryptography — it can be computed *without
knowing $p$ and $q$*, by a reciprocity algorithm as fast as Euclid's. It is a
free measurement. The order is not free: computing it in general is as hard as
factoring.

So we have one cheap bit and one expensive number. The question that drives
this article is: how are they related, and does their relationship know
anything about $p$ and $q$?

---

## The coupling: squares are the short cycles

At a single prime the answer is startlingly clean, and it goes back to Euler.

> **The Coupling Theorem.** Let $p$ be an odd prime and write $H_p = (p-1)/2$.
> A unit $b$ modulo $p$ is a quadratic residue — a perfect square — if and only
> if its order divides $H_p$.

Here is the picture. The units modulo an odd prime form a cyclic group of size
$p-1$: they are the powers $g^0, g^1, \dots, g^{p-2}$ of a single generator $g$,
arranged around a circle. The squares are exactly the even powers. But the even
powers are also exactly the elements whose order divides half the group size.
Two totally different-sounding descriptions — "is a square" and "has a short
cycle" — describe the same half of the circle. Euler's criterion,
$b^{(p-1)/2} \equiv \pm 1$, is precisely the bridge between them.

This is not a bias, not a tendency, not a heuristic. It is an equivalence, and
it holds for every unit at every odd prime, with no exceptions and no error
term. Call the set $\{b : \operatorname{ord}_p(b) \mid H_p\}$ the **half group**.
Squares are the half group; the half group is the squares.

---

## Lifting to a semiprime: where the beauty cracks

Now let $N = pq$. The Chinese Remainder Theorem says a unit modulo $N$ is the
same thing as a pair: a unit modulo $p$ together with a unit modulo $q$. And
the order of the pair is the least common multiple of the two component orders:
$$\operatorname{ord}_N(b) \;=\; \operatorname{lcm}\big(\operatorname{ord}_p(b),\, \operatorname{ord}_q(b)\big).$$

So the natural guess is that the Coupling Theorem lifts. Put
$$L \;=\; \operatorname{lcm}(H_p, H_q), \qquad H_p = \tfrac{p-1}{2},\; H_q = \tfrac{q-1}{2}.$$
Is it true that $\operatorname{ord}_N(b) \mid L$ exactly when $b$ is a square
modulo $p$ *and* a square modulo $q$?

One direction is free. If $b$ is a square at both primes, then
$\operatorname{ord}_p(b) \mid H_p$ and $\operatorname{ord}_q(b) \mid H_q$, so
their lcm divides $L$. Done.

The converse is *false*, and the counterexample is embarrassingly small. Take
$b = -1$. Its order is $2$. If $q \equiv 1 \pmod 4$ then $H_q = (q-1)/2$ is
even, so $2 \mid H_q \mid L$, and $-1$ passes the order test. But if
$p \equiv 3 \pmod 4$ then $-1$ is a non-residue modulo $p$. The order test says
"square", the truth says "not a square". Try $N = 39 = 3 \cdot 13$: here
$L = \operatorname{lcm}(1,6) = 6$, and $b = -1 \equiv 38$ has order $2$, which
divides $6$ — yet $38 \equiv 2 \pmod 3$ is not a square modulo $3$.

Why does it fail? Because $L$ is a least common multiple, and least common
multiples are greedy about prime powers. If one of $H_p, H_q$ carries more
factors of $2$ than the other, $L$ inherits the larger power, and that surplus
power of $2$ lets short-order elements sneak through the test at the *other*
prime. Everything hinges on the exponent of $2$.

---

## The dial

Write $v_2(m)$ for the number of times $2$ divides $m$ — the **2-adic
valuation**. The failure above is not a nuisance case; it is the *whole* story.

> **The Dichotomy Theorem.** Let $N = pq$ with $p \ne q$ odd primes, and put
> $L = \operatorname{lcm}(H_p, H_q)$. The equivalence
> $$\operatorname{ord}_N(b) \mid L \quad\Longleftrightarrow\quad b \text{ is a square mod } p \text{ and mod } q$$
> holds for **every** unit $b$ modulo $N$ **if and only if**
> $$v_2(H_p) = v_2(H_q).$$

Both halves of this are sharp. If the valuations agree, a short lattice
argument does the job: an element's component order at $p$ divides
$2H_p = p-1$, and if it also divides $\operatorname{lcm}(H_p, H_q)$, then it
divides their greatest common divisor, which under 2-adic balance is exactly
$H_p$. If the valuations disagree, one can *construct* a violating unit: pick a
non-square at the prime with the smaller valuation whose order divides the
larger half order, and pair it with $1$ at the other prime.

So the whole rich-looking joint structure of order and residue is controlled by
a single integer comparison: $v_2\!\left(\frac{p-1}{2}\right)$ versus
$v_2\!\left(\frac{q-1}{2}\right)$. It is a **dial**, and its bottom rung is the
most familiar condition in this business:
$$p \equiv q \equiv 3 \pmod 4 \iff v_2(H_p) = v_2(H_q) = 0,$$
because $H_p$ is odd exactly when $p \equiv 3 \pmod 4$. These are the *Blum
integers*, the moduli that make Rabin encryption and the Blum–Blum–Shub
generator work. Here the joint law is exact, automatically and for free.

---

## Four equal quarters, and a symbol that cannot see

On that bottom rung the geometry becomes as clean as it can be. The pair of
Legendre symbols $\left(\left(\tfrac{b}{p}\right), \left(\tfrac{b}{q}\right)\right)$
cuts the units modulo $N$ into four classes, and each is exactly one quarter of
the group:

> **The Quadrant Theorem.** For $p \equiv q \equiv 3 \pmod 4$, the set of units
> whose order divides $L$ has exactly $H_p H_q = \varphi(N)/4$ elements — one
> quarter of the unit group. Equivalently, four times the size of the order
> class equals the size of the whole group.

Perfect equidistribution. No excess, no deficit, no residual signal hiding in
the counts.

And now the punchline that closes the door. The Jacobi symbol is the *product*
of the two Legendre symbols, so it merges the quadrant $(+1,+1)$ with the
quadrant $(-1,-1)$: both give $J = +1$. That merger destroys exactly the
information the order test uses.

> **The Blindness Theorem.** For $p \equiv q \equiv 3 \pmod 4$, the two units
> $1$ and $-1$ both have Jacobi symbol $+1$; but $\operatorname{ord}(1) = 1$
> divides $L$, while $\operatorname{ord}(-1) = 2$ does not, since $L$ is odd.

Two units, indistinguishable to the free measurement, on opposite sides of the
expensive one. The Jacobi symbol carries strictly less information than the
order class, and no amount of cleverness recovers the difference: the very
elements that separate the classes are the ones the symbol identifies.

---

## The bias is real

None of this means there is *nothing* to see. Run the numbers. For each unit
$b$ modulo $N$, record the pair $(\operatorname{ord}_N(b), J(b\mid N))$, and
compare the average order in the two Jacobi classes. Across a wide range of
semiprimes the ratio
$$\frac{\mathbb{E}[\operatorname{ord}_N(b) \mid J = +1]}{\mathbb{E}[\operatorname{ord}_N(b) \mid J = -1]}$$
sits reliably *below* $1$ — around $0.68$ to $1.01$ in large-scale sampling,
and for every tested $N$ with $p \equiv q \equiv 3 \pmod 4$ it lands on exactly
$3/4$. Units with Jacobi symbol $+1$ genuinely have shorter cycles on average.
That is a real, reproducible, structurally explicable effect: the $+1$ class
contains the entire both-residue quadrant, all of whose members are confined to
the half groups.

So the statistic is not noise. The question is only whether the tilt says
anything about $p$ and $q$ *individually*.

It does not. Correlate the conditional means, and the ratio, against $p$,
against $q$, against $p+q$, against $|p-q|$. Compare each observed correlation
against a permutation null — reshuffle the labels thousands of times and see
how big a correlation pure chance produces. Every observed value falls inside
the null band. Whatever the bias is tracking, it is not the sizes of the
factors, nor their sum, nor their gap. The only structure that survives is the
residue dial: the pair $(p \bmod 4, q \bmod 4)$, which is to say a function of
$N \bmod 4$ — something you already knew the moment $N$ was published.

---

## The theorem that closes the case

Empirical non-correlation is suggestive; it is not proof. Maybe a cleverer
statistic, some exotic functional of the joint law, would crack it open. The
final result rules that out unconditionally, and it does so by exhibiting a
**collision**.

Define the **joint law** of $N$ to be the complete multiset
$$\mathcal{L}(N) \;=\; \big\{\!\!\big\{\,(\operatorname{ord}_N(b),\, J(b \mid N)) \;:\; b \text{ a unit mod } N \,\big\}\!\!\big\}.$$
This is the maximal object of study: every conditional distribution, every
moment, every average, every quantile of "order given Jacobi symbol" is a
function of $\mathcal{L}(N)$. If any order-times-symbol statistic could factor,
some function of $\mathcal{L}$ could.

> **The Collision Theorem.** $\mathcal{L}(35) = \mathcal{L}(39)$.

The two moduli $35 = 5 \cdot 7$ and $39 = 3 \cdot 13$ have $24$ units each, and
their joint laws agree pair for pair, multiplicity for multiplicity:

| $(\text{order},\,J)$ | count in $35$ | count in $39$ |
|---|---|---|
| $(1,+1)$ | 1 | 1 |
| $(2,+1)$ | 1 | 1 |
| $(2,-1)$ | 2 | 2 |
| $(3,+1)$ | 2 | 2 |
| $(4,+1)$ | 2 | 2 |
| $(4,-1)$ | 2 | 2 |
| $(6,+1)$ | 2 | 2 |
| $(6,-1)$ | 4 | 4 |
| $(12,+1)$ | 4 | 4 |
| $(12,-1)$ | 4 | 4 |

Identical. And here is the sting: $\gcd(35, 39) = 1$.

> **The Barrier Theorem.** There is no function $F$ from joint laws to integers
> such that $F(\mathcal{L}(N))$ is a nontrivial divisor of $N$ for both
> $N = 35$ and $N = 39$.

The proof is three lines and completely airtight. Suppose such an $F$ existed.
Since $\mathcal{L}(35) = \mathcal{L}(39)$, it returns the same integer $d$ on
both inputs. By assumption $d > 1$, $d \mid 35$ and $d \mid 39$. Hence
$d \mid \gcd(35,39) = 1$, so $d = 1$ — contradiction.

No hypothesis, no heuristic, no "for sufficiently large $N$". A single
collision between coprime moduli kills the entire family of attacks at once.

---

## Why collisions are not an accident

Two small numbers agreeing might look like a coincidence. It is not; there is a
mechanism, and it explains why collisions should be everywhere.

> **The Transport Theorem.** If there is an isomorphism between the unit groups
> of $N_1$ and $N_2$ that preserves the Jacobi symbol, then
> $\mathcal{L}(N_1) = \mathcal{L}(N_2)$.

The reason is almost trivial once stated: a group isomorphism automatically
preserves the order of every element, and the hypothesis takes care of the
symbol. So the joint law is not an invariant of the number $N$ at all. It is an
invariant of a much coarser object: the pair

$$\big(\text{the abstract group } \mathbb{Z}_{p-1} \times \mathbb{Z}_{q-1},\; \text{the quadratic character on it}\big).$$

And that object has *far* fewer degrees of freedom than the factorisation.
Semiprimes are plentiful; isomorphism classes of (group, character) pairs with
a given group size are not. Pigeonhole in the quotient category, and collisions
must abound. Our example is the smallest one: $\varphi(35) = \varphi(39) = 24$,
and $\mathbb{Z}_4 \times \mathbb{Z}_6 \cong \mathbb{Z}_2 \times \mathbb{Z}_{12}$
in a way that respects which elements are squares.

This is the deep reason the statistic cannot leak. It is not measuring $N$; it
is measuring a shadow of $N$, and the shadow is many-to-one.

And the shadow is crowded already at trivial scale. Among the $73$ semiprimes
below $400$ there are only $62$ distinct joint laws. Ten of those laws are
shared by coprime moduli — $\{35,39\}$, $\{77,93\}$, $\{95,111\}$,
$\{161,201\}$, $\{203,215\}$, $\{247,259\}$, $\{299,335\}$, $\{319,355\}$, and
the triple $\{143, 155, 183\}$, whose three unit groups
$\mathbb{Z}_{10}\times\mathbb{Z}_{12}$, $\mathbb{Z}_4\times\mathbb{Z}_{30}$ and
$\mathbb{Z}_2\times\mathbb{Z}_{60}$ are all the same group of order $120$ in
different clothing. Each of those is an independent proof of the same barrier.

---

## The circularity, and what it all means

There is a final, almost comic obstruction sitting on top of everything else.
Suppose you *did* want to compute the joint law of a large $N$. You would need
$\operatorname{ord}_N(b)$ for the units $b$. But computing multiplicative order
modulo a composite is, in general, exactly as hard as factoring — indeed
knowing the order of a random element is essentially the trick that lets a
quantum computer factor. To evaluate the statistic that is supposed to reveal
$p$ and $q$, you must first know $p$ and $q$.

Put the three obstructions side by side:

1. **It is a residue dial.** All the structure collapses to a comparison of
   two 2-adic valuations, whose bottom rung is $p \equiv q \equiv 3 \pmod 4$ —
   information visible in $N \bmod 4$.
2. **It is circular.** Computing the law requires the component orders, which
   requires the factors.
3. **It collides.** The law is an invariant of (unit group, quadratic
   character), and distinct coprime moduli share it — so no function of it can
   factor.

Each alone would be discouraging. Together they close the case.

---

## The value of a clean negative

It is worth saying plainly what has been gained, because "the attack does not
work" can sound like an absence of results. It is not.

Before, one had a suggestive empirical picture: an exact coupling at primes, a
real conditional bias at semiprimes, and correlations that stubbornly refused
to appear. Now one has a *description*. The lift of the coupling to semiprimes
is exact precisely on a 2-adic dial, and off it we can name the counterexample.
On the dial, the quadrants are exactly equal — not approximately, exactly. The
symbol's blindness is witnessed by the specific pair $1$ and $-1$. And the
barrier is a collision between two explicit integers, which no future
refinement of the statistic can dodge, because the collision is about the
statistic itself, not about any particular way of using it.

This is what a well-mapped dead end looks like, and dead ends of this quality
are worth having. Cryptographic confidence is built out of them: every attack
surface that is *provably* flat is one less place to worry about. In the
hint-free classical world — no side channels, no partial key exposure, no
special structure in $p$ and $q$ — the order-times-residue quadrant is now
closed. The combination grid that pairs order with residue information, and
order with spectral information, has been walked; the last remaining cell,
pairing residue with spectral data, is predicted to collapse in exactly the
same way, and for exactly the same reason.

Meanwhile the positive content stands on its own, independent of any
application. Euler's criterion is really a statement about cycle lengths. Its
failure to lift to composite moduli is governed by a single power of $2$. The
Blum integers are exactly the moduli where it lifts for free. And the joint law
of order and character is a genuine invariant of a category of pairs (group,
character) — coarser than arithmetic, and interesting in its own right.

The clock modulo $N$ knows a great deal. It simply does not know how to say
$p$.
