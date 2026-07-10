# The Arithmetic of Games: How Numbers Are Born

Imagine a universe of numbers so vast that it contains not only every
ordinary number you have ever met—$0$, $1$, $-\tfrac{1}{2}$, $\pi$—but also
numbers *larger than infinity*, numbers *smaller than every positive
fraction yet still greater than zero*, and endless gradations in between.
This is the world of the **surreal numbers**, discovered by the
mathematician John Horton Conway in the 1970s while he was thinking about
the endgames of the board game Go. What began as a way to measure who is
winning in a game turned out to be one of the largest and most elegant
number systems ever conceived.

The surreal numbers have a remarkable feature that ordinary numbers lack:
they have **birthdays**. Every surreal number is *created* on a particular
day, built out of numbers that were created earlier. This article is about
what gets born on the *finite* days—the first day, the second, the
third—and about the beautiful, exact answer to the question *"which numbers
are these?"*

## How to build a number out of nothing

Conway's construction is astonishingly simple. A surreal number is nothing
more than a pair of sets of *earlier* surreal numbers: a **left set** $L$
and a **right set** $R$, written
$$x = \{\, L \mid R \,\},$$
subject to one rule—no member of $L$ may be greater than or equal to any
member of $R$. Intuitively, $x$ is the "simplest" number lying strictly
between everything on its left and everything on its right.

On **day $0$** we have nothing to work with, so the only number we can form
is
$$0 = \{\ \mid\ \},$$
the empty-left, empty-right number. It is squeezed between *no*
constraints, so it sits at the origin.

On **day $1$**, we may use $0$. Putting it on the left gives
$$1 = \{\, 0 \mid\ \},$$
the simplest number greater than $0$. Putting it on the right gives
$$-1 = \{\ \mid 0 \,\}.$$

On **day $2$**, new numbers appear: the number $\{\,0 \mid 1\,\}$, the
simplest number strictly between $0$ and $1$, turns out to be exactly
$\tfrac12$. Its mirror image is $-\tfrac12$, while $\{\,1\mid\,\}$ becomes
$2$ and $\{\ \mid -1\}$ becomes $-2$.

Continue in this way, and each finite day introduces the numbers whose
"complexity" matches that day. A pattern emerges immediately: the numbers
appearing on the finite days are precisely the **dyadic rationals**—the
fractions whose denominators are powers of two:
$$\ldots,\ -\tfrac34,\ -\tfrac12,\ -\tfrac14,\ 0,\ \tfrac14,\ \tfrac12,\
\tfrac34,\ \ldots$$
Halving intervals is exactly what the left–right construction does, so
powers of two are baked into the very fabric of the surreal hierarchy.

## The powers of one half

The engine driving this entire story is a single infinite family of
numbers: the **powers of one half**. Write $\tfrac{1}{2^n}$ for the surreal
number obtained by repeatedly taking simplest midpoints:
$$\tfrac{1}{2^0}=1,\qquad
\tfrac{1}{2^{n+1}}=\Bigl\{\,0 \ \Big|\ \tfrac{1}{2^{n}}\,\Bigr\}.$$
Each one is the simplest number between $0$ and the previous one.

These numbers behave *exactly* as their names promise, and we can make each
claim precise.

**They are genuinely positive.** Every power of one half satisfies
$\tfrac{1}{2^n} > 0$. None of them is an elaborate disguise for zero.

**They shrink, forever.** They form a strictly decreasing sequence,
$$1 > \tfrac12 > \tfrac14 > \tfrac18 > \cdots,$$
and consequently they are all *distinct*: the assignment $n \mapsto
\tfrac{1}{2^n}$ never repeats a value. Infinitely many different dyadic
values are realized, one for each natural number.

**They rescale to one.** Multiplying by the corresponding power of two
recovers the unit exactly:
$$2^{n}\cdot \tfrac{1}{2^{n}} = 1.$$
This is the sense in which $\tfrac{1}{2^n}$ truly *is* the reciprocal of
$2^n$—not merely a number that looks small, but the honest multiplicative
inverse.

**They multiply by adding exponents.** The most important arithmetic fact
of all is that these numbers obey the law of exponents,
$$\tfrac{1}{2^{m}}\cdot \tfrac{1}{2^{n}} = \tfrac{1}{2^{m+n}}.$$
This single identity is the seed from which the entire *multiplicative*
structure of the dyadic surreals grows. The proof is a little jewel:
multiply both sides by $2^{m+n}$, watch each factor collapse to $1$ via the
rescaling law above, and cancel—legal because the surreal numbers form a
genuine field in which nonzero elements can be divided out.

## When is a number born?

Here the birthday story becomes quantitative. We can pin down *exactly*
which day each power of one half arrives:
$$\text{the birthday of } \tfrac{1}{2^n} \text{ is } n+1.$$
So $1$ is born on day $1$, $\tfrac12$ on day $2$, $\tfrac14$ on day $3$, and
in general the "denominator height" of $\tfrac{1}{2^n}$ is mirrored
perfectly by its birthday. The proof is a clean induction: the base case
$1=\{\,0\mid\,\}$ is born the day after $0$, and each new midpoint
$\tfrac{1}{2^{n+1}} = \{\,0\mid \tfrac{1}{2^n}\,\}$ costs exactly one
additional day beyond its predecessor.

The immediate payoff: since $n+1$ is always a finite number, **every power
of one half is born before the first infinite day**, traditionally called
day $\omega$. In the surreal cosmology, day $\omega$ is where truly infinite
and infinitesimal numbers first appear; everything born strictly earlier is
"finite-birthday". The powers of one half are a concrete, infinite supply of
finite-birthday numbers realizing the values $2^{-n}$.

## The dyadic rationals live inside the games

Individually interesting as they are, the powers of one half combine into a
much bigger structure. Take integer combinations of them—numbers of the
form $m \cdot \tfrac{1}{2^n}$—and you obtain exactly the **dyadic
rationals**, the ring
$$\mathbb{Z}\!\left[\tfrac12\right] = \left\{\, \tfrac{m}{2^n} : m \in
\mathbb{Z},\ n \in \mathbb{N} \,\right\}.$$
There is a natural map sending each abstract dyadic fraction $\tfrac{m}{2^n}$
to its surreal incarnation $m\cdot \tfrac{1}{2^n}$. The central result of
this work is that **this map is faithful**: distinct dyadic fractions land
on distinct surreal numbers. In technical language, the map is *injective*.

Why is faithfulness true, and why does it matter? The map respects
addition, so proving it never collapses two different inputs reduces to a
single question: which inputs get sent to $0$? Suppose $m\cdot
\tfrac{1}{2^n} = 0$. Since $\tfrac{1}{2^n}$ is strictly positive and the
surreals have *no zero divisors*—a product is zero only when a factor
is—we conclude $m=0$, so the input was already the trivial fraction. Nothing
but zero maps to zero, and faithfulness follows.

This resolves a subtle point that is easy to take for granted. The surreal
numbers are built by a strange, recursive, set-theoretic recipe; there is no
*a priori* guarantee that two different-looking dyadic fractions won't turn
out to be secretly equal once translated into games. Faithfulness certifies
that they never do. The countable, familiar number system
$\mathbb{Z}[\tfrac12]$ sits **perfectly and without distortion** inside the
enormous, proper-class universe of surreal numbers.

Packaged together, these facts say something clean and strong: the dyadic
surreals form a self-contained algebraic world—closed under addition,
subtraction, and multiplication—that is a **faithful mirror** of the dyadic
rationals. Not merely an additive copy: the multiplication matches too,
thanks to the law of exponents. The abstract ring $\mathbb{Z}[\tfrac12]$ and
its surreal image are *ring-isomorphic*—the same arithmetic object wearing
two different costumes.

## A hierarchy of number systems, one day at a time

Step back and the philosophical picture is striking. Conway's surreal line
is not a single, static set of numbers; it is a *process*, a cosmos that
unfolds in stages. Each birthday level contributes exactly the numbers that
its degree of complexity permits, and the finite levels contribute exactly
the dyadic rationals—no more, no less.

It is tempting to guess that the finite-birthday numbers might include *all*
rational numbers. They do not. A number like $\tfrac13$ has no finite
birthday at all; it requires an infinite process of nested approximations
(from below by $\tfrac14, \tfrac{5}{16}, \ldots$ and from above by $\tfrac12,
\tfrac38, \ldots$) and is not born until day $\omega$. The dyadic rationals
are special precisely because binary halving—not thirds, not fifths—is the
native language of the left–right construction.

And the story is only beginning. Beyond day $\omega$ live the reals that are
*not* dyadic, the infinite numbers larger than every integer, and the
infinitesimals—positive numbers smaller than $\tfrac{1}{2^n}$ for *every*
$n$. The smallest positive infinitesimal, $\varepsilon = \{\,0 \mid 1,
\tfrac12, \tfrac14, \ldots\,\}$, is squeezed beneath the entire sequence of
half-powers and first appears on day $\omega$ itself. From there, the
hierarchy climbs through days $\omega\cdot 2$, $\omega^2$, and beyond,
eventually encompassing the real numbers, the ordinals, and a dense thicket
of infinitesimals, all inside one ordered field.

What the finite-birthday layer teaches us is a blueprint for the whole:
**the surreal hierarchy encodes the constructive growth of number systems**.
Start with nothing. Each day, insert the simplest number missing from each
gap. The finite days build the dyadic scaffolding; the infinite days pour in
the reals and the infinities. It is a creation myth for mathematics itself—
numbers, quite literally, being born from the empty set, one day at a time,
in exactly the order their complexity demands.

That such a grand edifice grows from the humble question "who is winning this
game?" is perhaps the most surreal fact of all.
