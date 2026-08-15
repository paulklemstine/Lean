# The Prime That Should Not Have Been There

## A conjecture about hidden factorizations, and the small number that broke it

Take a whole number $N$ and draw the curve
$$E_N : y^2 = x^3 + N.$$
These are the *Mordell curves*, and they have fascinated number theorists since the 1920s. Their charm is that they are simple enough to write on a napkin and stubborn enough to resist a century of attack. Fermat proved that $y^2 = x^3 - 2$ has essentially only the solution $(3,5)$. Nobody knows a general recipe for deciding whether $y^2 = x^3 + N$ has any rational solutions at all.

What makes these curves more than curiosities is that they carry a **group law**. Given two rational points on the curve, draw the line through them; because the curve has degree three, that line meets the curve in exactly one further point, and reflecting it across the $x$-axis gives a third rational point, called the sum. If you start with a single rational point $P$ and add it to itself over and over, you get $P$, $2P$, $3P$, $4P$, $\dots$ — an infinite parade of rational points, each one manufactured from the last by nothing more than high-school algebra.

Here is the thing that makes the parade interesting: the points get *ugly* fast. Start on $E_{55} : y^2 = x^3 + 55$ at the innocuous point
$$P = (9, 28), \qquad 28^2 = 784 = 729 + 55 = 9^3 + 55.$$
Double it. The tangent line at $P$ has slope $\lambda = 3\cdot 9^2/(2\cdot 28) = 243/56$, and the doubling formula $x(2P) = \lambda^2 - 2\cdot 9$ gives
$$x(2P) = \frac{2601}{3136}.$$
Keep going and the fractions explode:
$$x(3P) = -\frac{2302089191}{656538129}, \qquad x(4P) = \frac{\text{(21 digits)}}{\text{(22 digits)}},$$
with roughly a doubling of digit count at every step. This growth is not an accident; it is the *canonical height*, one of the deepest invariants attached to an elliptic curve.

But forget the size of those denominators for a moment and look at their **prime factorizations**. That is where a beautiful conjecture lived, and where it died.

## The conjecture: only bad primes

Every Mordell curve carries a distinguished integer, its **discriminant**
$$\Delta = -432 N^2,$$
which measures where the curve degenerates. A prime $\ell$ is called *bad* for $E_N$ if $\ell \mid \Delta$; equivalently, if $\ell \in \{2, 3\} \cup \{\text{primes dividing } N\}$. Every other prime is *good*: modulo a good prime the curve stays a genuine smooth curve.

Now suppose $N = pq$ is a product of two large primes — the kind of number cryptography is built on. The bad primes of $E_{pq}$ are exactly $2$, $3$, $p$, and $q$. So here is an alluring thought, which we will call the **"only bad primes" conjecture**:

> *For $N = pq$ and any rational point $P$ of $E_N$, the denominators of $x(P), x(2P), x(3P), \dots$ are divisible only by the primes $2, 3, p, q$.*

If it were true, it would be spectacular. Denominators are cheap to compute — a few multiplications and one greatest common divisor per step. Their prime factors would then hand you $p$ and $q$ directly: you would be *reading the factorization of $N$ off a sequence of fractions*. That would be a factoring algorithm, and a strange, elegant one.

The conjecture is false. Its refutation takes one line, and we already wrote it down:
$$x(2P) = \frac{2601}{3136}, \qquad 3136 = 2^6 \cdot 7^2.$$
Here $N = 55 = 5 \cdot 11$, and the bad primes are $2, 3, 5, 11$. The prime $7$ divides the denominator. And $7 \nmid \Delta = -432 \cdot 55^2$: seven is a *good* prime, a prime at which nothing whatsoever goes wrong with the curve. It has walked into the denominator uninvited.

Worse — and this is what turns a counterexample into a theory — the intruder never leaves.

## Why good primes get in: reduction and the point at infinity

The mechanism is one of the most useful ideas in arithmetic geometry: **reduction modulo a prime**. Fix a good prime $\ell$ and reduce the equation $y^2 = x^3 + N$ modulo $\ell$. You get an elliptic curve over the finite field with $\ell$ elements, and it has a finite group of points $E_N(\mathbb{F}_\ell)$ — at most about $\ell + 1 + 2\sqrt{\ell}$ of them, by a celebrated theorem of Hasse.

A rational point with $\ell$-free denominator reduces to an honest point of $E_N(\mathbb{F}_\ell)$. But a rational point whose denominator *is* divisible by $\ell$ has no finite reduction: it flies off to the point at infinity, the identity of the group. So the statement

$$\ell \mid \text{denominator of } x(kP)$$

is precisely the statement

$$kP \equiv \mathcal{O} \pmod \ell,$$

i.e. the reduced point $\bar P$ has order dividing $k$ in the finite group $E_N(\mathbb{F}_\ell)$.

Once you see it this way, the conjecture never had a chance. The reduced point $\bar P$ lives in a finite group, so it has *some* finite order $m$, and at $k = m$ the prime $\ell$ appears in a denominator. This has nothing to do with whether $\ell$ divides $N$. On $E_{55}$ with $P = (9,28)$, the point $\bar P$ has order $2$ modulo $7$ and order $3$ modulo $13$ — and sure enough, $7$ shows up at $n = 2$ and $13$ shows up at $n = 3$, in the factorization $656538129 = 3^6 \cdot 13^2 \cdot 73^2$ of the denominator of $x(3P)$.

That single denominator, incidentally, kills the conjecture from *both* directions at once: it contains the good primes $13$ and $73$, and it contains **neither** $5$ nor $11$, the two primes we were hoping to read off. Denominators do not reveal factorizations.

## The structure that replaces the conjecture

A refutation is a small thing. What is worth having is the law that governs the phenomenon, and that law turns out to be clean, complete, and provable by hand.

### 1. Denominators are always perfect squares

Write a rational point of $E_N$ ($N$ an integer) as $x = a/d$ and $y = b/f$ in lowest terms. Substituting into $y^2 = x^3 + N$ and clearing denominators gives $b^2 d^3 = f^2 (a^3 + N d^3)$. Because $a$ is coprime to $d$ and $b$ to $f$, this forces $f^2 \mid d^3$ and $d^3 \mid f^2$, so $d^3 = f^2$; and since $2$ and $3$ are coprime, there is a single integer $e$ with

$$\boxed{\ \text{den}\,x = e^2, \qquad \text{den}\,y = e^3.\ }$$

Every rational point of every Mordell curve obeys this. In particular **every prime in an $x$-denominator appears to an even power** — which is why $7^2$, not $7$, sits inside $3136$, and why $656538129 = 3^6 \cdot 13^2 \cdot 73^2$ is a perfect square ($= 25623^2$). Denominators are thin: among the integers up to $X$, at most $\sqrt{X}+1$ can ever occur as an $x$-denominator, a set of density zero. And some very small numbers are *forever impossible*: no rational point of $E_{55}$ has $x$-denominator exactly $7$, even though $7$ genuinely occurs — squared — one step along the orbit.

### 2. A complete local rule for doubling

Using the parametrization $x = a/e^2$, $y = b/e^3$, the doubling formula becomes an identity between integers,
$$x(2P) = \frac{a^4 - 8Nae^6}{4b^2e^2} = \frac{a\,(b^2 - 9Ne^6)}{4b^2e^2},$$
and the whole local behaviour can be read off it. For a good prime $\ell \ge 5$ (that is, $\ell \nmid 6N$):

> $\ell$ divides the denominator of $x(2P)$ **if and only if** $\ell$ divides the denominator of $x(P)$, or $\ell$ divides the numerator of $y(P)$.

Both alternatives are the same geometric statement — that $2P$ reduces to the point at infinity — and neither mentions the factorization of $N$ in any way beyond the harmless condition $\ell \nmid N$. That independence is the precise sense in which the "only bad primes" conjecture fails: the criterion for a prime entering a denominator is a fact about the *curve modulo $\ell$*, not about how $N$ splits.

### 3. Once in, never out

What happens to a prime that has already entered? Nothing at all, if it is odd:

> If $\ell$ is an odd prime dividing $\text{den}\,x(P)$, then the $\ell$-part of $\text{den}\,x(2P)$ equals the $\ell$-part of $\text{den}\,x(P)$ — exactly, not just up to a bound.

The proof is a single observation: modulo $\ell$ the numerator $a(b^2 - 9Ne^6)$ is congruent to $a \cdot b^2$, and both $a$ and $b$ are coprime to $e$, so no cancellation whatsoever is possible; the $\ell$-part of the fraction is the $\ell$-part of $e^2$, unchanged. Remarkably, this needs no assumption about good or bad reduction: bad primes obey the same law.

The prime $2$ is the exception, and its exception is also exact: the factor $4$ in the denominator contributes two extra levels, so

$$v_2\big(\text{den}\,x(2P)\big) = v_2\big(\text{den}\,x(P)\big) + 2$$

whenever the denominator is already even, where $v_2$ counts factors of $2$. On $E_{55}$ the powers of $2$ in the denominators of $x(2P), x(4P), x(8P)$ are $2^6, 2^8, 2^{10}$ — the prediction, on the nose.

### 4. The kernel is a subgroup, and primes appear periodically

The set
$$E_\ell(\mathbb{Q}) = \{P : \ell \mid \text{den}\,x(P)\} \cup \{\mathcal{O}\}$$
is not merely stable under doubling: it is closed under the full group law, at *every* prime, good or bad. The argument avoids all heavy machinery. Suppose $P$ and $Q$ lie in the set but $S = P + Q$ does not, so $S$ has $\ell$-free coordinates. Rewrite $P = S - Q$ using the chord identity
$$x_3 (x_1 - x_2)^2 = x_1x_2(x_1+x_2) + 2N - 2y_1y_2,$$
which follows from the two curve equations and, crucially, contains no slope and no square roots. Every term on the right is $\ell$-integral and the factor $(x_1-x_2)^2$ is a unit at $\ell$; so $x(P)$ is $\ell$-integral, contradicting $\ell \mid \text{den}\,x(P)$.

Being a subgroup has an immediate and rather beautiful consequence. Fix a point $P$ and pull the subgroup back along the map $k \mapsto kP$. The result is a subgroup of $\mathbb{Z}$ — and every subgroup of $\mathbb{Z}$ is the set of multiples of a single number. Therefore:

> **The apparition index law.** For every prime $\ell$ and every rational point $P$ of $E_N$ there is a natural number $m = m(\ell, P)$ such that, for all integers $k$,
> $$\ell \mid \text{den}\,x(kP) \iff m \mid k.$$

A prime never appears sporadically. It appears along an arithmetic progression through $0$, or never. This is the exact elliptic analogue of the classical *rank of apparition* of a prime in a Fibonacci or Lucas sequence, where the indices $n$ with $\ell \mid F_n$ likewise form the multiples of a single number.

On $E_{55}$ with $P = (9,28)$ the two indices are pinned down exactly: the good prime $7$ has apparition index $2$, so $7$ divides $\text{den}\,x(kP)$ **precisely when $k$ is even**; and the good prime $13$ has apparition index $3$. (Both are genuine equivalences — one has to verify that the odd multiples really do *fail* the divisibility, which they do, since $x(P) = 9$ is an integer.) The failure locus of the "only bad primes" conjecture inside a single orbit is thus not one periodic pattern but a superposition of arithmetic progressions with different moduli, one for each prime that ever appears.

### 5. And the orbit really is infinite

There is one thing left to check: that all these multiples are genuinely distinct points, so that "infinitely many counterexamples" means what it says. The exact $2$-adic growth law supplies it. Along the sub-orbit $Q, 2Q, 4Q, 8Q, \dots$ we get
$$v_2\big(\text{den}\,x(2^kQ)\big) = v_2\big(\text{den}\,x(Q)\big) + 2k,$$
which is strictly increasing, so the points are pairwise different and the orbit can never close up. The induction never stalls, because a point with even $x$-denominator cannot be $2$-torsion: if $y = 0$ then $\text{den}\,y = 1 = e^3$, forcing $e = 1$ and an integral $x$.

The upshot is a proof — with no descent, no heights, no Nagell–Lutz — that $P = (9,28)$ has infinite order and that $E_{55}(\mathbb{Q})$ is an infinite group, obtained purely by watching denominators grow. And along the way: infinitely many distinct rational points of $E_{55}$ whose $x$-denominator is divisible by the good prime $7$.

## What this means for reading factorizations off curves

Return to the original hope. Suppose $N = pq$ with $p, q$ large primes and you want to recover them from denominators. Two things now stand in the way, and they are structural, not incidental.

First, the denominators contain far more than $\{2,3,p,q\}$. A survey of eleven semiprime Mordell curves, each with a small rational point and its first several multiples, found the "only bad primes" property holding in **zero** of the eleven cases. The larger prime factor $q$ appeared in a denominator in **none** of them; the smaller factor $p$ appeared in roughly half to three-quarters of them, depending on how the sample is chosen. That asymmetry is exactly what the apparition index predicts: a small prime lives in a small finite group, so its index is small and it surfaces within the first few multiples, while a large prime has an index of size comparable to itself and is invisible in any short prefix of the orbit. The signal you wanted is absent and the noise is everywhere.

Second, and more fundamentally: the criterion for a prime $\ell$ to appear is *the order of $\bar P$ in $E_N(\mathbb{F}_\ell)$*. That number depends on the curve modulo $\ell$ and on nothing else — the factorization of $N$ is invisible to it. Denominators are a function of $N$ as a number, not of $N$ as a product. Any scheme to extract $p$ and $q$ from them must first find a quantity that distinguishes $N = pq$ from a prime of the same size, and the denominator sequence is not that quantity.

So the "only bad primes" conjecture is false, and it is false for a reason that is worth more than the conjecture would have been. What replaces it is a small, complete, elementary theory: denominators are perfect squares $e^2$ with $y$-denominators $e^3$; a good prime enters exactly when the point becomes $\ell$-adically trivial; odd primes, once in, keep their exact exponent forever while the prime $2$ climbs by precisely two levels per doubling; the set of points a prime touches is a subgroup; and consequently every prime has an apparition index, appearing along an arithmetic progression and nowhere else.

The prime $7$ was not supposed to be in that denominator. It turns out it had every right to be — and it will be there in infinitely many more.
