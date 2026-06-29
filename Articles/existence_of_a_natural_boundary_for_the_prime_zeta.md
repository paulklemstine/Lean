# The Wall at the Edge of the Primes

## A forbidden number, and the question of how to tame it

There is a famous, infamous, slightly scandalous "fact" that floats around the
internet: that if you add up all the positive whole numbers,

$$1 + 2 + 3 + 4 + 5 + \cdots = -\tfrac{1}{12}.$$

Taken literally this is nonsense — the partial sums march off to infinity and
never come back. But taken as a piece of *mathematical physics*, it is one of
the most useful pieces of nonsense ever written down. It appears in string
theory, in the calculation of the Casimir force between two metal plates, and in
the regularization of quantum fields. The trick that rescues it has a name:
**analytic continuation**, the art of giving a meaningful value to a divergent
sum by routing around the place where it blows up.

The hero of that story is the Riemann zeta function,
$\zeta(s) = \sum_{n=1}^{\infty} n^{-s}$. The sum only converges when the real
part of $s$ is bigger than $1$, but the *function* it defines can be smoothly
extended to almost the entire complex plane. Evaluate that extension at
$s = -1$, and out pops $-\tfrac{1}{12}$. The series never converges there; the
function does the impossible on its behalf.

Now here is the natural follow-up question that this article is about. Instead of
adding up *all* the whole numbers, what if we add up only the **prime numbers**?
And what if we go further — into the strange, beautiful arithmetic of the
*Gaussian integers* — and try to add up not ordinary primes but the prime
*ideals* of an imaginary quadratic field? Can that sum, too, be tamed? Or is
there a wall in the way?

The answer, it turns out, is that there is a wall. This article is about where
that wall stands, what builds it, and why it appears to be unbreakable.

## The prime zeta function: a sharp cliff at $s = 1$

Start with the simplest version. Define the **prime zeta function**

$$P(s) = \sum_{p \text{ prime}} p^{-s} = \frac{1}{2^s} + \frac{1}{3^s} + \frac{1}{5^s} + \frac{1}{7^s} + \cdots.$$

When does this converge? There is a clean, complete answer: the series converges
if and only if $s > 1$. This single threshold is called the **abscissa of
convergence**, and for the prime zeta function it sits exactly at $1$.

The threshold is sharp on both sides. For any $s > 1$ the sum is a perfectly
finite positive number. But the instant you hit the boundary $s = 1$, you are
adding up the reciprocals of the primes,

$$\frac{1}{2} + \frac{1}{3} + \frac{1}{5} + \frac{1}{7} + \frac{1}{11} + \cdots = \infty,$$

and this diverges — a celebrated theorem of Euler, and the first real evidence
that the primes, though they thin out, never thin out *fast enough* to be
summable. To the left of $1$ the divergence only gets worse. At $s = -1$, the
analogue of the "sum of all primes,"

$$\sum_{p} p = 2 + 3 + 5 + 7 + 11 + \cdots,$$

the series is wildly divergent. So if a regularized "sum of all primes" exists at
all, it can *never* be the value of the series itself. It can only ever come from
an analytic continuation — a function that agrees with the series where the
series makes sense, and bravely supplies values where it does not.

That is the rational story, and it is completely understood. The interesting
twist begins when we change the *number system* we are working in.

## Into the Gaussian integers

Carl Friedrich Gauss studied numbers of the form $a + bi$, where $a$ and $b$ are
ordinary integers and $i = \sqrt{-1}$. These are the **Gaussian integers**,
written $\mathbb{Z}[i]$, and they form the arithmetic backbone of the field
$\mathbb{Q}(i)$ — the rational numbers with $i$ adjoined. Inside this larger
world, the familiar primes can *change their character*. A prime that was
indivisible among ordinary integers may suddenly factor.

The rule for what happens to a rational prime $p$ is astonishingly tidy, and it
depends only on $p$ modulo $4$:

- **$p = 2$ is *ramified*.** It becomes (up to a unit) a perfect square:
  $2 = -i\,(1+i)^2$. There is a single prime ideal lying above it, of *norm* $2$.
- **$p \equiv 1 \pmod 4$ is *split*.** It breaks into two distinct conjugate
  prime ideals, each of norm $p$. For example $5 = (2+i)(2-i)$ and
  $13 = (3+2i)(3-2i)$.
- **$p \equiv 3 \pmod 4$ is *inert*.** It refuses to factor at all and stays
  prime in $\mathbb{Z}[i]$, but now it is regarded as a single prime ideal of
  norm $p^2$. For example $3$, $7$, $11$, and $19$ remain stubbornly whole.

The *norm* $N(\mathfrak{p})$ of a prime ideal is the size of the finite world you
get by reducing modulo it — the right notion of "magnitude" in this setting. The
prime zeta function of a number field $K$ is then built exactly as before, but
summed over prime ideals and weighted by their norm:

$$P_K(s) = \sum_{\mathfrak{p}} N(\mathfrak{p})^{-s}.$$

For the Gaussian field, we can organize this sum prime-by-prime according to the
splitting law above. Each rational prime $p$ contributes a single term that we
can write down explicitly:

$$
\mathrm{term}(s, p) =
\begin{cases}
2^{-s}, & p = 2 \quad (\text{ramified}),\\[4pt]
2\,p^{-s}, & p \equiv 1 \pmod 4 \quad (\text{split, two ideals}),\\[4pt]
p^{-2s}, & p \equiv 3 \pmod 4 \quad (\text{inert, norm } p^2).
\end{cases}
$$

The factor of $2$ on the split primes counts the *two* ideals above $p$; the
exponent $-2s$ on the inert primes records that their norm is $p^2$, not $p$. Add
these contributions over all rational primes and you get the **Gaussian
prime-ideal zeta function**,

$$P_{\mathbb{Q}(i)}(s) = \sum_{p \text{ prime}} \mathrm{term}(s, p).$$

This is the object at the center of our story. The question is the same as
before: where does it converge, and is there a wall?

## A tale of two species of prime

Here is the key conceptual move, and it is what makes the Gaussian case richer
than the rational one. The sum $P_{\mathbb{Q}(i)}(s)$ is secretly a *blend of two
very different kinds of term*, and they behave in opposite ways.

The **split primes** ($p \equiv 1 \pmod 4$) contribute terms of size $2\,p^{-s}$
— essentially twice an ordinary prime-zeta term. These behave just like the
rational primes: they want to converge when $s > 1$ and diverge when $s \le 1$.

The **inert primes** ($p \equiv 3 \pmod 4$) contribute terms of size $p^{-2s}$.
Because of that doubled exponent, the inert series looks like a prime zeta
function *evaluated at $2s$ instead of $s$*. It converges when $2s > 1$, i.e.
when $s > \tfrac{1}{2}$, and diverges when $s \le \tfrac{1}{2}$.

So the two species disagree about exactly where the trouble starts. This gives us
a clean, rigorous, two-sided bracket on the true abscissa of convergence, and
each side of the bracket is built from one species:

> **Convergence (the ceiling).** For every $s > 1$, the Gaussian prime-ideal
> zeta series converges absolutely. The proof is a comparison: every term
> satisfies $\mathrm{term}(s,p) \le 2\,p^{-s}$, so the whole sum is dominated by
> twice the rational prime zeta function, which converges for $s > 1$.

> **Divergence (the floor).** For every $s \le \tfrac{1}{2}$, the series
> diverges. The proof is the reverse comparison: every term satisfies
> $\mathrm{term}(s,p) \ge p^{-2s}$, and the inert contribution alone — the sum of
> $p^{-2s}$ over all primes — already diverges once $2s \le 1$.

Put these together and the abscissa of convergence is *trapped* in the closed
interval $[\tfrac{1}{2},\, 1]$. The floor at $\tfrac{1}{2}$ is forced entirely by
the inert primes; the ceiling at $1$ is forced by the split primes. Two species,
two walls, one bracket.

Two further facts round out the rigorous picture. First, wherever the series
converges it is **strictly positive** — guaranteed by the single ramified prime
$2$, which always contributes the genuinely positive term $2^{-s}$, so the sum is
never zero or negative or some artifact of cancellation. Second, there is a clean
**bridge inequality** tying the Gaussian function back to the rational one: for
all $s > 1$,

$$P_{\mathbb{Q}(i)}(s) \le 2\,P(s).$$

The Gaussian prime-ideal zeta is at most twice the ordinary prime zeta. That
factor of $2$ is not arbitrary — it is the maximum number of prime ideals that
can sit above any single rational prime, the "degree" of the field made
quantitative.

## Closing the gap, and the wall on the horizon

The bracket $[\tfrac{1}{2}, 1]$ is rigorous and unconditional. But where, inside
that window, does convergence *actually* break? The conjecture is that the true
abscissa is exactly $1$ — the same as for the rational primes. Why isn't this
already proved? Because closing the gap $(\tfrac{1}{2}, 1]$ requires knowing that
the *split* primes are plentiful: that the sum of their reciprocals,
$\sum_{p \equiv 1 (4)} 1/p$, diverges.

This is true, and it is one of the jewels of nineteenth-century number theory:
Dirichlet's theorem on primes in arithmetic progressions guarantees that the
primes split evenly, in a precise density sense, between the residue classes
$1 \bmod 4$ and $3 \bmod 4$. Each class carries "half" of the primes, and half of
a divergent sum still diverges. So the split primes really do push the wall all
the way out to $s = 1$. The reason this is *conjectured* rather than *proved*
here is that it draws on machinery genuinely deeper than the elementary
comparisons that establish the bracket — but the mathematics behind it is solid.

And now the deepest part of the story, the part that gives this article its
title. Recall that for the rational zeta function, the divergent series at
$s = -1$ could still be assigned a value, because the function continued
analytically past its wall of convergence. Does $P_{\mathbb{Q}(i)}(s)$ continue?

The expectation is: **only so far, and no farther.** The prime-ideal zeta
function can be written through a Möbius-twisted expansion in terms of the
logarithm of the field's Dedekind zeta function,

$$P_K(s) = \sum_{k \ge 1} \frac{\mu(k)}{k}\,\log \zeta_K(ks),$$

where $\mu$ is the Möbius function. Every nontrivial zero of $\zeta_K$ becomes a
logarithmic singularity of $P_K$, and the rescaling by $k$ scatters copies of
each singularity at the points $\rho/k$. As $k$ ranges over all integers, these
singular points pile up — they accumulate *densely* along the vertical line
$\mathrm{Re}(s) = 0$, the imaginary axis. A function cannot be analytically
continued across a line that is solidly packed with its own singularities. That
line becomes a **natural boundary**: an impassable wall, beyond which the
function simply does not exist.

This is the conjectural punchline. For the rational primes the same phenomenon
was identified long ago (the Landau–Walfisz natural boundary for the prime zeta
function). In the imaginary quadratic case, the class-number-one condition makes
the Dedekind zeta factor cleanly as $\zeta_K(s) = \zeta(s)\,L(s, \chi)$ — the
Riemann zeta times a Dirichlet $L$-function — so the zeros of *both* factors
contribute their singularities to the pile-up. The wall on the imaginary axis is,
if anything, doubly reinforced.

## Why the wall matters

The consequence is a clean impossibility statement. Physicists love to
"regularize" infinite products and sums — the regularized product of all positive
integers, for instance, famously equals $\sqrt{2\pi}$ via the zeta-function
trick. One might hope to do the same for the primes of an imaginary quadratic
field: to assign a finite, meaningful value to "the product of all prime ideals"
by evaluating a continued $P_K$ at $s = 0$.

But $s = 0$ sits squarely *on the imaginary axis* — squarely *on the wall*. If
the natural boundary is real, then there is no analytic continuation to evaluate
there, and no zeta-style regularization of the product of all prime ideals is
possible. The infinity is not a removable inconvenience to be routed around; it
is a fundamental feature of the arithmetic, a boundary built brick by brick out
of the zeros of $L$-functions.

So the story comes full circle. We began with a divergent sum that physics learned
to tame, and we end with a divergent sum that — if the conjecture holds — *cannot
be tamed at all*. The split primes set the outer edge of convergence; the inert
primes set the inner floor; and the zeros of the field's zeta function, marching
in lockstep up the imaginary axis, raise a wall that no continuation can cross.

What is rigorously secured today is the bracket: convergence for $s > 1$,
divergence for $s \le \tfrac{1}{2}$, strict positivity in between, and the factor-of-two
bridge to the ordinary primes. What lies just beyond is the sharp abscissa at
exactly $1$ and the natural boundary on the imaginary axis — the wall at the edge
of the primes, visible on the horizon, and waiting to be reached.
