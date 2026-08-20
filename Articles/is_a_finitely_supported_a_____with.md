# The Head of the Eta Quotient

## How one number, hidden at the front of an infinite product, remembers a group law

There is a function in mathematics so ubiquitous that number theorists write it
without comment, the way physicists write $e^{i\theta}$. It is Dedekind's eta
function,

$$\eta(\tau) \;=\; q^{1/24}\prod_{n\ge 1}\bigl(1-q^{n}\bigr), \qquad q=e^{2\pi i\tau},$$

an infinite product over the upper half-plane. It is the archetype of a modular
form. It counts partitions, it computes dimensions of spaces of modular forms, it
appears in string theory partition functions and in the character formulas of
sporadic finite simple groups. And it has that strange fractional exponent
$1/24$ out front — a number that, once you have seen it a few times, starts to feel
less like an accident and more like a law of nature.

This article is about what happens when you take products of eta functions,
invert them, and look at the very first coefficient that is not forced by
normalisation. That coefficient, it turns out, has an exact closed form, and it
obeys a group law that is not the group law you would expect.

---

## Eta quotients, and the number 24

Fix a sequence of integers $a_1, a_2, a_3, \dots$, all but finitely many of them
zero. From it, build the **eta quotient**

$$\eta_a(\tau) \;=\; \prod_{k\ge 1}\eta(k\tau)^{a_k}.$$

Negative exponents are allowed — that is what makes it a quotient rather than a
product. This one construction sweeps up an enormous amount of classical number
theory. Take $a_1 = 24$ and everything else zero: you get the modular
discriminant

$$\Delta(\tau) = \eta(\tau)^{24} = q\prod_{n\ge1}(1-q^n)^{24},$$

whose coefficients are Ramanujan's tau function. Take $a_1 = a_2 = a_3 = a_6 = 1$
and you get a weight-two form attached to an elliptic curve of conductor 36. Take
$a_1 = -1$ and you get the generating function of the partition numbers. Eta
quotients are the workhorses of the subject.

Now watch the $q$-powers. Each factor $\eta(k\tau)^{a_k}$ contributes
$q^{k a_k/24}$, so the total leading power of $q$ is $q^{\,\frac{1}{24}\sum_k k\,a_k}$.
There is exactly one normalisation that makes this a clean single power of $q$
with exponent one:

$$\sum_{k\ge 1} k\,a_k \;=\; 24.$$

Call such an exponent vector **admissible**. It is the same 24 that appears in
$\eta^{24}=\Delta$, in the 24 dimensions of the Leech lattice, in the critical
dimension of the bosonic string, and in the $1/24$ of the eta function itself.
Under this normalisation the fractional powers evaporate and the eta quotient
becomes a bona fide power series in $q$ with integer coefficients and leading
term exactly $q$:

$$\eta_a(\tau) \;=\; q\prod_{m\ge 1}\bigl(1-q^m\bigr)^{\,b_m}, \qquad
b_m \;=\; \sum_{k\mid m} a_k .$$

That last identity is worth pausing over. The exponent $b_m$ of $(1-q^m)$ is a
**divisor sum** of the original exponents: the factor $\eta(k\tau)$ contributes
$(1-q^{kn})$ for every $n$, and the term $q^m$ receives a contribution from every
divisor $k$ of $m$. The passage $a \mapsto b$ is a Möbius-invertible
regrouping, and it is the reason the arithmetic of eta quotients is really
arithmetic of divisor functions.

---

## The head coefficient

Invert the whole thing. Because the eta quotient has a simple zero at the cusp
(that leading $q$), its reciprocal has a simple pole, and the natural object to
study is

$$\frac{1}{\eta_a} \;=\; q^{-1} + c(0) + c(1)\,q + c(2)\,q^{2} + \cdots$$

Equivalently, multiplying through by $q$,

$$F_a(q) \;:=\; \frac{q}{\eta_a} \;=\; \prod_{m\ge 1}\bigl(1-q^m\bigr)^{-b_m}
\;=\; \sum_{n\ge 0} A_n\, q^{\,n}, \qquad A_n = c(n-1).$$

This is the shape of a *Hauptmodul*: a $q$-expansion beginning $q^{-1} + \cdots$,
the normal form of a generator of a genus-zero function field. In moonshine, the
McKay–Thompson series all have exactly this shape, and the coefficients
$c(0), c(1), c(2),\dots$ are the numbers that turn out to be dimensions of
representations of huge finite groups. So the question "what is $c(1)$?" is not
idle. It is the first genuinely non-trivial invariant of the whole construction.

The answer is a clean quadratic polynomial in just two of the exponents.

> **Head Coefficient Theorem.** For any finitely supported exponent vector
> $a$, the coefficient of $q$ in $1/\eta_a$ is
> $$c(1) \;=\; \frac{a_1(a_1+3)}{2} \;+\; a_2 .$$
> The preceding coefficients are $c(-1)=1$ and $c(0)=a_1$.

Two things about this are surprising. First, only $a_1$ and $a_2$ appear at all:
the exponents $a_3, a_4, \dots$ of $\eta(3\tau), \eta(4\tau), \dots$ are
invisible in this degree, because their factors begin at $q^3$ or later. Second,
the dependence on $a_1$ is *quadratic*, not linear, even though the map
$a \mapsto \eta_a$ turns addition of exponents into multiplication of series. We
will come back to that quadratic term — it is the whole point.

A sanity check. For $\Delta = \eta^{24}$ we have $a_1 = 24$, all other $a_k = 0$,
and the formula gives $c(1) = 24\cdot 27/2 = 324$. And indeed the classical
expansion is

$$\frac{1}{\Delta} \;=\; q^{-1} + 24 + 324\,q + 3200\,q^2 + 25650\,q^3 + 176256\,q^4 + \cdots$$

Push the same machinery one degree further and the next coefficient falls out as
well:

$$c(2) \;=\; \frac{a_1(a_1+1)(a_1+2)}{6} \;+\; a_1(a_1+a_2) \;+\; a_1 \;+\; a_3,$$

which for $a_1=24$ returns $2600+576+24 = 3200$, as it must. The pattern of the
proof is now visible: triangular numbers $\binom{n}{2}$ govern degree two,
tetrahedral numbers $\binom{n}{3}$ govern degree three, and in general the
binomial coefficients of the exponent do the work. They are the shadow of the
exponential map.

---

## Truncation, and why the infinite product is honest

Before any of this can be said, one has to know that the infinite product makes
sense. It does, and for a reason that is entirely elementary but must be
verified: each factor $(1-q^m)^{-b_m}$ differs from $1$ only in degrees $\ge m$,
so multiplying in the factors with $m > n$ cannot disturb the coefficient of
$q^n$.

> **Stability Theorem.** Let $F^{(N)} = \prod_{m=1}^{N}(1-q^m)^{-b_m}$ be the
> truncated product. If $n \le N$ and $n \le M$, then the coefficient of $q^n$ in
> $F^{(N)}$ equals the coefficient of $q^n$ in $F^{(M)}$.

So there is a well-defined coefficient $A_n$, computable by *any* long-enough
truncation, and every statement below about "the" coefficients of the infinite
product is a theorem about all sufficiently long finite products at once.

---

## A group law where you did not expect one

Exponent vectors add; eta quotients multiply. In symbols,
$F_{a+a'} = F_a \cdot F_{a'}$, since $b_m$ depends linearly on $a$ and exponents
of like factors add. So the family $\{F_a\}$ is a homomorphic image of the free
abelian group of exponent vectors, and one might hope that any natural invariant
of $F_a$ would be additive in $a$.

The constant term is: $c(0) = a_1$ is visibly linear. The head coefficient is
not. Instead, it satisfies

> **The Heisenberg Cocycle.** For all exponent vectors $a, a'$,
> $$c(1)(a+a') \;=\; c(1)(a) \;+\; c(1)(a') \;+\; a_1 a_1'.$$

The failure of additivity is exactly a symmetric bilinear form in the two leading
exponents. This is not sloppiness in the invariant; it is a structural fact about
multiplying power series. If $f = 1 + c_1 q + c_2q^2 + \cdots$ and
$g = 1 + d_1 q + d_2 q^2 + \cdots$, then the product has $q$-coefficient
$c_1 + d_1$ and $q^2$-coefficient $c_2 + c_1 d_1 + d_2$. The cross-term
$c_1 d_1$ is the cocycle.

And a cocycle like that has a name and a shape. Package the pair
$(c(0), c(1)) = (a_1, c(1))$ into the unipotent integer matrix

$$M(a) \;=\; \begin{pmatrix} 1 & a_1 & c(1) \\ 0 & 1 & a_1 \\ 0 & 0 & 1\end{pmatrix}.$$

> **Bridge Theorem.** $M(a+a') = M(a)\,M(a')$, and $\det M(a) = 1$.

The map $a \mapsto M(a)$ is a homomorphism from the additive group of exponent
vectors into the **discrete Heisenberg group** — the group of $3\times 3$ upper
triangular integer matrices with ones on the diagonal, the smallest non-abelian
nilpotent group, the group that underlies the canonical commutation relations of
quantum mechanics. The head coefficient of an eta quotient lives in its upper
right corner.

The visible moral: the linear invariant $a_1$ is the abelian shadow; the head
coefficient is the first non-abelian layer above it, and the two layers are
genuinely different in kind.

---

## Which numbers are head coefficients?

Suppose we only allow "pure" quotients with $a_2 = 0$, so that
$c(1) = a_1(a_1+3)/2$. Which integers arise? Completing the square,
$8c(1)+9 = (2a_1+3)^2$, and conversely every odd square arises. So:

> **Diophantine Characterisation.** An integer $c$ is the head coefficient of a
> pure eta power if and only if $8c+9$ is a perfect square.

Consequences drop out at once. The value $c = 1$ is *not* attainable, since
$17$ is not a square. Two exponents give the same head coefficient exactly when
$a_1' = a_1$ or $a_1' = -3-a_1$ — a reflection symmetry about $-3/2$, the vertex
of the parabola. And although the real function $x(x+3)/2$ dips to $-9/8$, the
integers cannot reach it:

> **Integrality Rigidity.** A pure head coefficient is never less than $-1$, and
> the value $-1$ is attained exactly twice, at $a_1=-1$ and $a_1=-2$.

Allow $a_2 \ne 0$ and the obstruction vanishes completely. Since $a_2$ enters
the formula linearly and additively, one can hit anything:

> **Surjectivity.** Every integer $c$ occurs as the head coefficient of an
> *admissible* exponent vector. Explicitly, $a_2 = c$, $a_3 = 2c-24$,
> $a_4 = 24-2c$ (all other $a_k=0$) has $\sum_k k\,a_k = 24$ and head coefficient
> exactly $c$.

So the arithmetic rigidity is a feature of the one-dimensional slice, not of the
theory: the second exponent is a free dial, and turning it sweeps out all of
$\mathbb{Z}$.

---

## Every coefficient at once, and two theorems no finite computation can see

Degree-by-degree jet calculus computes $c(1)$ and $c(2)$, but it does not scale.
The uniform statement comes from taking a logarithmic derivative. Write
$\theta = q\,\frac{d}{dq}$ for the Euler operator. Because $\theta \log$ turns
products into sums,

$$\theta \log F_a \;=\; \sum_{m\ge 1} m\,b_m\,\frac{q^m}{1-q^m}
\;=\; \sum_{j\ge 1}\sigma_b(j)\,q^{\,j},
\qquad \sigma_b(j) \;=\; \sum_{m \mid j} m\,b_m .$$

The right-hand side is a **twisted divisor sum**, a weighted version of the
classical $\sigma_1$. Comparing coefficients in $F_a \cdot \theta\log F_a = \theta F_a$
gives the whole story in one line.

> **Recursion Theorem.** For every $n \ge 1$,
> $$n\,A_n \;=\; \sum_{i=0}^{n-1} A_i\,\sigma_b(n-i), \qquad A_0 = 1.$$

Together with $A_0=1$ this determines every coefficient of the eta quotient from
the divisor data alone. And crucially, unlike the head coefficient, the structure
constants are honestly additive: $\sigma_{b+b'} = \sigma_b + \sigma_{b'}$. All the
non-linearity of the coefficients is the non-linearity of exponentiating a linear
thing — which is exactly why unipotent groups appear.

Two theorems now follow that no amount of finite jet computation could establish,
because they are statements about *all* degrees simultaneously.

**Positivity.** If $b_m \ge 0$ for every $m$, then every $\sigma_b(j)\ge 0$, and
an induction on the recursion gives $A_n \ge 0$ for every $n$. If moreover
$b_1 \ge 1$, then every term on the right is at least $1$, there are $n$ of them,
so $A_n \ge 1$ for every $n$. For $1/\Delta$, where $b_m = 24$ for every $m$,
this proves that the sequence $1, 24, 324, 3200, 25650, 176256, \dots$ never dips
to zero or below — positivity of all of it, from a two-line induction.

**A congruence.** Suppose an integer $d$ divides every $b_m$. Then $d$ divides
every $\sigma_b(j)$, hence $d \mid n A_n$ for every $n\ge 1$. If $d$ is coprime
to $n$, it may be cancelled:

> **Congruence Theorem.** If $d \mid b_m$ for all $m$ and $\gcd(d,n)=1$, then
> $d \mid A_n$. In particular, for $1/\Delta$: $24 \mid A_n$ whenever
> $\gcd(n,24)=1$.

Check it: $A_1 = 24$, $A_5 = 176256 = 24\cdot 7344$, $A_7 = 5930496 = 24\cdot 247104$.
And the coprimality is not decorative — $A_2 = 324$ is not divisible by $24$, and
neither is $A_3 = 3200$ nor $A_4 = 25650$. Combine the congruence with positivity
and you get a lower bound with no computation at all: for every $n$ coprime to
$24$, the $n$-th coefficient of $q/\Delta$ is a *positive multiple of 24*, hence
at least $24$.

---

## The tropical shadow, and what it forgets

There is a coarser invariant one can attach to any power series: its order of
vanishing, the index of its first non-zero coefficient. Order is a valuation —
it turns products into sums and behaves like a minimum under addition. That is
precisely the arithmetic of the **tropical semiring**, where "multiplication" is
ordinary addition and "addition" is $\min$. Transporting the order into that
semiring, one gets a genuine multiplicative map $T$: $T(fg) = T(f)\otimes T(g)$,
and $T(f)\oplus T(g)\le T(f+g)$.

Applied to our family, the result is comically degenerate: since $F_a$ is a unit
power series with constant term $1$, its order is $0$, and $T(F_a)$ is the
tropical unit for *every* $a$. The normalisation has absorbed all of the
valuation-theoretic information into the single factor $q$ we divided out.

That degeneracy is the punchline, not a disappointment. It says the tropical
layer is *strictly coarser* than the head coefficient: $\Delta$ and the trivial
quotient have identical tropical shadows and head coefficients differing by
$324$. The invariant tower has a bottom floor that is tropical, additive, and
blind, and a first floor that is Heisenberg, non-abelian, and sharp.

---

## What it adds up to

Start with an infinite product built from a fistful of integers. Normalise so
the leading term is $q$. Invert. The first free coefficient is
$a_1(a_1+3)/2 + a_2$ — a quadratic, and quadratics in this business always mean
a cocycle, and a cocycle always means a group. Here the group is the Heisenberg
group, and the eta quotients map into it.

One degree deeper the tetrahedral numbers appear, and the pattern of a unipotent
tower becomes visible: linear in degree one, quadratic in degree two, cubic in
degree three, each new layer a new commutator. Behind all of it sits a single
recursion whose structure constants are twisted divisor sums, honestly linear in
the input — the entire non-linearity of eta quotient coefficients is the
non-linearity of the exponential function, seen through a formal power series.

And from that one recursion: every coefficient of $1/\Delta$ is positive, and
every coefficient indexed by a number coprime to $24$ is divisible by $24$. Two
infinite families of facts, both invisible to any finite calculation, both
consequences of the same line of algebra. That is a good day's work for a
logarithmic derivative.
