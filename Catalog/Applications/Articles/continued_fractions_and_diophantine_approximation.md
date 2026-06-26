# The Most Irrational Number in the World

## A number that refuses to be pinned down

Every irrational number is, in a sense, a moving target. You can never write it
exactly as a fraction, but you can always sneak up on it. Pick your favorite
irrational — say $\pi = 3.14159\ldots$ — and you can find fractions that hug it
astonishingly closely. The famous $\tfrac{22}{7}$ is good; $\tfrac{355}{113}$ is
breathtaking, correct to six decimal places. Some numbers practically *invite*
good fractional approximations.

But not all numbers are so welcoming. There is one number that is, in a precise
mathematical sense, the *hardest* of all real numbers to approximate by
fractions — the number that fends off rational impostors more stubbornly than
any other. It is not $\pi$, nor $e$, nor $\sqrt{2}$. It is the **golden ratio**,

$$\varphi = \frac{1+\sqrt5}{2} = 1.6180339887\ldots$$

the same proportion that the ancient Greeks built into the Parthenon, that
appears in the spiral of a nautilus shell and the seed-head of a sunflower, and
that artists have invoked for two and a half millennia as the signature of
beauty. The golden ratio's reputation as nature's favorite number turns out to
have a hard mathematical core: it is the number that is *worst* approximated by
fractions. This article tells the story of why, and of a clean, self-contained
proof of a sharp quantitative version of that fact.

## How well can you approximate?

To make the question precise we need a fair way to score an approximation. A
fraction $p/q$ with a giant denominator $q$ has lots of room to be accurate, so
raw closeness $|\alpha - p/q|$ isn't a fair contest. The right currency,
discovered in the nineteenth century, is to weigh the error against $1/q^2$.

The reason is a theorem of Dirichlet: **for every irrational number $\alpha$,
there are infinitely many fractions $p/q$ with**

$$\left|\alpha - \frac{p}{q}\right| < \frac{1}{q^2}.$$

So *every* irrational can be approximated to within $1/q^2$ infinitely often.
The interesting question becomes: can you do *better* than $1/q^2$? Can you push
the constant on the right below $1$?

For most numbers, yes — dramatically. But here a beautiful universal law kicks
in, discovered by Adolf Hurwitz in 1891.

**Hurwitz's theorem.** For every irrational $\alpha$ there are infinitely many
fractions $p/q$ with

$$\left|\alpha - \frac{p}{q}\right| < \frac{1}{\sqrt5\, q^2}.$$

Moreover, the constant $\sqrt5$ cannot be replaced by any larger number — and
the *unique* obstruction, the number that prevents any improvement, is the
golden ratio and its arithmetic relatives.

In other words, $\sqrt5 \approx 2.236$ is a wall. Every irrational number can be
approximated at least as well as $1/(\sqrt5\, q^2)$ infinitely often, and the
golden ratio sits exactly on that wall: you cannot do appreciably better than
$1/(\sqrt5\, q^2)$ for $\varphi$, no matter how clever you are. That is what it
means to be the *most irrational* number.

## Why the golden ratio is the holdout

The deep reason lives in **continued fractions** — the practice of writing a
number as a cascade of nested fractions. Every real number has an essentially
unique expansion

$$\alpha = a_0 + \cfrac{1}{a_1 + \cfrac{1}{a_2 + \cfrac{1}{a_3 + \cdots}}}$$

where the $a_i$ are positive integers called the *partial quotients*. Truncating
this cascade gives the *convergents*, the best rational approximations to
$\alpha$ — better than any fraction with a smaller denominator. The key fact is
that **large partial quotients make for great approximations**. When some $a_i$
is huge, the convergent just before it is extraordinarily accurate. (This is
exactly why $\pi \approx 3.14159$ has the spectacular approximation
$355/113$: the continued fraction of $\pi$ is $[3;7,15,1,292,\ldots]$, and that
enormous $292$ produces a fraction accurate far beyond its modest denominator.)

So which number is *hardest* to approximate? The one whose partial quotients are
as small as they can possibly be — all equal to $1$. And that number is

$$\varphi = 1 + \cfrac{1}{1 + \cfrac{1}{1 + \cfrac{1}{1 + \cdots}}} = [1;1,1,1,\ldots].$$

Because the recipe is "add $1$, take the reciprocal, repeat forever," the golden
ratio satisfies the self-referential equation $\varphi = 1 + 1/\varphi$, that
is,

$$\varphi^2 = \varphi + 1.$$

Its convergents are the ratios of consecutive **Fibonacci numbers**
$1, 1, 2, 3, 5, 8, 13, 21, \ldots$:

$$\frac{1}{1},\ \frac{2}{1},\ \frac{3}{2},\ \frac{5}{3},\ \frac{8}{5},\ \frac{13}{8},\ \frac{21}{13},\ \ldots \longrightarrow \varphi.$$

These are the best the golden ratio will ever allow — and because all its
partial quotients are the minimum possible value $1$, they converge as *slowly*
as the laws of arithmetic permit. The golden ratio is badly approximable
precisely because Fibonacci ratios are the slowest-converging best
approximations in all of mathematics.

## A proof without continued fractions

The continued-fraction story is the intuition. But there is a remarkably clean
*algebraic* route to the quantitative heart of the matter — one that never
mentions continued fractions at all, and that has been verified down to the last
logical step. It rests on a single clever object: a **norm form**.

Alongside $\varphi$ lives its algebraic twin, the **conjugate**

$$\psi = \frac{1-\sqrt5}{2} = -0.6180339887\ldots,$$

the *other* root of $x^2 = x + 1$. These two numbers satisfy three tidy
relations that drive everything:

$$\varphi + \psi = 1, \qquad \varphi\,\psi = -1, \qquad \varphi - \psi = \sqrt5.$$

Now take any integers $p$ and $q$ and form the quadratic expression
$p^2 - pq - q^2$. The magic is that it factors over the reals exactly the way
$\varphi$ and $\psi$ would predict:

$$\big(p - q\varphi\big)\big(p - q\psi\big) = p^2 - pq - q^2.$$

This is the **norm form** identity. Here is why it settles the question. The
right-hand side $p^2 - pq - q^2$ is always a whole number. Could it ever be
zero? If it were, then $(2p - q)^2 = 5q^2$, which would force $5$ to be a perfect
square — and it isn't. So for any integers with $q \geq 1$,

$$p^2 - pq - q^2 \neq 0, \qquad \text{hence} \qquad |p^2 - pq - q^2| \geq 1.$$

A nonzero integer has absolute value at least one: a humble fact with enormous
consequences. Combining it with the factorization, write $t = |p - q\varphi|$
for the (scaled) error of the approximation $p/q$. Since
$p - q\psi = (p - q\varphi) + q\sqrt5$, the triangle inequality gives

$$1 \leq |p^2 - pq - q^2| = t \cdot |p - q\psi| \leq t\big(t + \sqrt5\, q\big).$$

Now suppose, for contradiction, the approximation were *too* good: both
$t < \tfrac13$ and $q\,t < \tfrac13$. Using the safe bound $\sqrt5 < \tfrac83$,
the right-hand side would be

$$t^2 + \sqrt5\,(q\,t) < \tfrac19 + \tfrac{\sqrt5}{3} < 1,$$

contradicting $1 \leq t^2 + \sqrt5\,(q\,t)$. The conclusion is forced:
$q\,t \geq \tfrac13$. Translating back, $t = |p - q\varphi| = q\,|\varphi -
p/q|$, so $q^2 |\varphi - p/q| \geq \tfrac13$, that is:

**The golden ratio is badly approximable.** For all integers $p$ and all
$q \geq 1$,

$$\left|\varphi - \frac{p}{q}\right| \geq \frac{1/3}{q^2}.$$

No fraction can ever beat $\tfrac13 / q^2$. There is a hard floor under how close
you can get, and that floor scales like $1/q^2$ — the same order Dirichlet
guarantees from above. The golden ratio is squeezed from both sides into the
narrowest possible band.

The constant $\tfrac13$ here is honest but not optimal; the truly sharp constant
is $1/\sqrt5 \approx 0.447$, as Hurwitz's theorem demands. The elementary $\tfrac13$
argument captures the essential phenomenon — a genuine $c/q^2$ lower bound — with
nothing more than the factorization of a quadratic and the fact that $5$ is not a
perfect square.

## The Fibonacci fingerprint

The same algebra delivers a second jewel. If you measure how the Fibonacci
convergents chase $\varphi$, you find an exact formula. Writing $F_n$ for the
$n$-th Fibonacci number, one can prove the **Binet-type identity**

$$F_{n+1} - \varphi\, F_n = \psi^{\,n}.$$

Because $|\psi| = 0.618\ldots < 1$, the right-hand side shrinks geometrically:
each Fibonacci approximation overshoots and undershoots $\varphi$ by exactly
$\psi^n$, an error that marches steadily to zero but never reaches it. These are
the **Fibonacci linear forms** $F_n\varphi - F_{n+1} = -\psi^n$: nonzero numbers
that get arbitrarily small. Their very existence proves that $\varphi$ is
**irrational** — for if $\varphi$ were a fraction $a/b$, the quantity
$F_n\varphi - F_{n+1}$ would be a fraction with denominator $b$ and could not be
both nonzero and smaller than $1/b$. The Fibonacci forms violate that, so
$\varphi$ cannot be rational.

This is the continued-fraction route to irrationality in disguise: the
convergents $F_{n+1}/F_n$ produce a sequence of ever-better rational
approximations whose errors are *exactly* the powers $\psi^n$.

## Not a Liouville number

There is one more rung on this ladder, and it connects the golden ratio to the
very first numbers ever proven transcendental. In 1844 Joseph Liouville
discovered that *algebraic* irrational numbers — roots of polynomials with
integer coefficients — cannot be approximated *too* well by rationals. Numbers
that *can* be approximated absurdly well, faster than any power $1/q^n$, are
called **Liouville numbers**, and Liouville used them to construct the first
explicit transcendental numbers in history, such as
$\sum_k 10^{-k!} = 0.110001000000000000000001\ldots$.

The golden ratio is the opposite extreme. Its badly-approximable bound
$|\varphi - p/q| \geq \tfrac13/q^2$ says it cannot even be approximated *well*,
let alone absurdly well. So **the golden ratio is not a Liouville number** — a
fact that falls out immediately from the quadratic lower bound. It is, instead,
the most respectable kind of irrational: algebraic, of degree two, and maximally
resistant to rational seduction.

## The pattern continues

The argument that crowns $\varphi$ as the most irrational number is not a
one-off trick. It is the first case of an infinite family. For each whole number
$m \geq 1$, the **metallic ratio**

$$\alpha_m = \frac{m + \sqrt{m^2+4}}{2}, \qquad \text{root of } x^2 = mx + 1,$$

(with $\alpha_1 = \varphi$ the golden ratio, $\alpha_2 = 1+\sqrt2$ the silver
ratio, and so on) carries its own norm form $p^2 - mpq - q^2 = (p - q\alpha_m)(p
- q\beta_m)$. Because $m^2+4$ is never a perfect square, the very same logic
gives each metallic ratio its own badly-approximable bound. The golden ratio is
simply the first, and most extreme, member of a tower of stubborn numbers, each
guarding its own corner of the number line against the advances of fractions.

That a proportion celebrated for two thousand years as the emblem of harmony
should also be, in the cold arithmetic of approximation, the most uncooperative
number of all is one of mathematics' quiet jokes — and one of its deepest
truths.
