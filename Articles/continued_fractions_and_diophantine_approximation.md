# The Shadow Game of Numbers: How Well Can a Fraction Imitate the Infinite?

Pick a number that goes on forever without repeating — say $\pi = 3.14159\ldots$,
or the golden ratio $\varphi = 1.61803\ldots$, or $\sqrt{2} = 1.41421\ldots$. None
of these can be written as a simple fraction. They are *irrational*: their decimal
expansions never settle into a pattern, never close the loop. And yet, every day,
engineers, astronomers, and computer chips treat them as if they were fractions.
A calendar approximates the year's true length by $365 + \tfrac{97}{400}$ days. A
piano tuner approximates the twelfth root of two. A gear-maker cuts teeth whose
ratio is a deliberate stand-in for an impossible real number.

This raises a deceptively simple question, one that has haunted mathematicians for
three centuries:

> **How well can a fraction imitate an irrational number?**

It turns out the answer is astonishingly rich. Some irrational numbers submit to
fractions almost embarrassingly well; you can pin them down to dizzying precision
with surprisingly small fractions. Others resist — they are *stubborn*, refusing
to be cornered by any fraction that is not enormous. The story of which numbers are
"easy" and which are "hard" is the story of **Diophantine approximation**, and it
connects ancient calendar reform to the modern theory of transcendental numbers.
This article tells that story and states, in plain mathematical language, the
results we have made airtight.

## The cost of a good fraction

Suppose I want to approximate an irrational number $x$ by a fraction $p/q$. There
is always a trade-off. I can get as close as I like — that is just the statement
that fractions are *dense* on the number line. But closeness alone is cheap; the
real question is how close I can get *relative to the size of the denominator $q$ I
am willing to pay for*. A fraction with denominator $1{,}000{,}000$ had better be
very accurate, or it was a waste of effort. The honest measure of quality is not
$|x - p/q|$ by itself, but how that error compares to $q$.

The first great surprise, due to **Dirichlet** in the 1840s, is that you can always
do better than the denominator alone would suggest. For *every* irrational $x$,
there are infinitely many fractions $p/q$ with

$$\left| x - \frac{p}{q} \right| < \frac{1}{q^2}.$$

Read that carefully. The error is not merely smaller than $1/q$ — which any
careless rounding achieves — but smaller than $1/q^2$. Doubling the denominator
buys you *four times* the precision, for free, infinitely often. This is the
baseline that every irrational number meets. The deep question is whether some
numbers can beat it dramatically, and whether others sit right at the edge.

## The first new result: the denominators run away to infinity

There is a subtle gap in Dirichlet's statement that is easy to overlook. He
guarantees *infinitely many* good fractions $p/q$. But could all those fractions
share, say, a handful of denominators, written over and over with different
numerators? Intuitively no — but "intuitively no" is not a proof, and the entire
later theory depends on the denominators genuinely growing without bound.

Our first theorem closes this gap. We call a fraction *Dirichlet-good* for $x$ if it
beats the $1/q^2$ bound. The result is:

> **Theorem (unbounded denominators, `irrational_den_unbounded`).** *For every
> irrational number $x$ and every target $N$, there is a fraction $p/q$ in lowest
> terms with denominator $q \ge N$ satisfying* $\left| x - \tfrac{p}{q}\right| <
> \tfrac{1}{q^{2}}$.

In words: not only are there infinitely many excellent approximations, but their
denominators climb past every bound. You can demand a denominator larger than a
billion, larger than a googol, and a Dirichlet-good fraction with such a denominator
still exists.

The idea behind the proof is a beautiful pigeonhole-flavored argument about
*crowding*. Imagine you fix a ceiling $N$ on the denominator and a window of width
two around $x$, say the interval $(x-1, x+1)$. How many fractions can live in that
window with denominator at most $N$? The answer is: only finitely many. A fraction
$p/q$ inside a bounded interval, with $q \le N$, cannot have a wild numerator —
$|p|$ is squeezed between fixed bounds proportional to $q$. So there are only
finitely many allowable numerators for each of the finitely many allowable
denominators. Finitely many slots, period. We made this precise as:

> **Lemma (local finiteness, `finite_den_le_in_interval`).** *For any bound $N$ and
> any interval $(a,b)$, the set of rationals $q$ with denominator at most $N$ that
> land inside $(a,b)$ is finite.*

Now the trap springs shut. Dirichlet hands us infinitely many good fractions, and
all of them lie close to $x$, hence inside the window $(x-1, x+1)$. If their
denominators were bounded by some $N$, the local-finiteness lemma would say there
are only finitely many of them — a flat contradiction. Therefore the denominators
*cannot* be bounded. They run away to infinity. From this we also extract a clean
"coprime" restatement: for every $N$ there are integers $a$ and $b$ with $b \ge N$,
$\gcd(a,b)=1$, and $|x - a/b| < 1/b^2$ (`irrational_infinitely_many_coprime_approx`).

This unboundedness is not a technicality. It is precisely the fuel that lets us pass
from "good approximations exist" to statements about *limits* as denominators grow —
the gateway to measuring a number's stubbornness.

## Measuring stubbornness: the Lagrange constant

To compare how hard different numbers are to approximate, we attach a single number
to each real $x$ that captures its long-run resistance to fractions. Start with the
distance from a real number $y$ to the nearest integer, written $\lVert y \rVert$.
For example $\lVert 3.2 \rVert = 0.2$ and $\lVert 4.5 \rVert = 0.5$. This little
quantity measures how badly $y$ misses being a whole number.

Now, for a denominator $q$, look at $q \cdot \lVert q\,x \rVert$. Here $\lVert q\,x
\rVert$ is small exactly when $qx$ is near an integer $p$ — that is, when $p/q$ is a
good approximation of $x$ — and multiplying by $q$ normalizes for the cost of the
denominator. A small value of $q \cdot \lVert q\,x \rVert$ signals a *high-quality,
cheap* approximation. We package the long-run best case as the **Lagrange constant**:

$$\mathrm{Lc}(x) = \liminf_{q \to \infty} \; q \cdot \lVert q\,x \rVert.$$

The $\liminf$ — the eventual smallest accumulation value — records the best
approximation quality that recurs no matter how far out you look. A number is called
**badly approximable** when $\mathrm{Lc}(x) > 0$: fractions can never corner it
beyond a fixed quality ceiling. A number with $\mathrm{Lc}(x) = 0$ is the opposite,
*extraordinarily* approximable — fractions can imitate it arbitrarily well relative
to their denominators.

## Everyone meets the universal speed limit

The second new result says that Dirichlet's bound, translated into the language of
the Lagrange constant, imposes a universal ceiling:

> **Theorem (universal bound, `Lc_le_one_of_irrational`).** *Every irrational number
> $x$ satisfies* $\mathrm{Lc}(x) \le 1$.

The proof is a direct dividend of the runaway-denominator theorem. For each target
$N$ we produce a Dirichlet-good fraction $p/q$ with $q \ge N$. A short calculation
turns $|x - p/q| < 1/q^2$ into $\lVert q\,x \rVert < 1/q$, hence $q \cdot \lVert q\,x
\rVert < 1$. Because such denominators $q$ occur arbitrarily far out (this is exactly
where unboundedness is indispensable), the long-run smallest value — the $\liminf$ —
cannot exceed $1$. Every irrational number, no matter how stubborn, is forced under
the same universal speed limit.

This is the "easy half" of a famous sharper result, **Hurwitz's theorem**, which
lowers the ceiling all the way to $1/\sqrt{5} \approx 0.447$ and shows the golden
ratio sits exactly at that edge — the single most stubborn number there is. Our
framework reaches the ceiling $1$ with one Dirichlet approximation per scale;
squeezing it down to $1/\sqrt{5}$ requires extracting three consecutive
approximations at once, a refinement we flag as a natural next step.

## The other extreme: numbers too good to be algebraic

If some numbers are maximally stubborn, what about numbers that are maximally
*compliant*? Enter the **Liouville numbers**, discovered by Joseph Liouville in 1844
and famous for being the first numbers ever *proven* to be transcendental — that is,
not the root of any polynomial with whole-number coefficients.

A Liouville number is one that fractions can approximate with superhuman accuracy:
for every exponent $n$, there is a fraction $p/q$ (with $q > 1$) so good that

$$\left| x - \frac{p}{q} \right| < \frac{1}{q^{\,n}}.$$

Compare this to Dirichlet's universal $1/q^2$. A Liouville number blows past $1/q^2$,
past $1/q^{10}$, past $1/q^{1000}$ — the approximations are so absurdly precise that
no algebraic number could ever tolerate them. (Liouville's original insight: an
algebraic number of degree $d$ can never be approximated better than about $1/q^d$,
so a number beating *every* power must be transcendental.) The canonical example is

$$L = \sum_{k=1}^{\infty} \frac{1}{10^{k!}} = 0.110001000000000000000001\ldots,$$

whose decimal expansion has long deserts of zeros punctuated by lonely ones at
factorial positions — gaps so vast that truncating the sum gives ferociously good
fractional approximations.

Our third result places Liouville numbers at the polar opposite of the golden ratio
on the stubbornness scale:

> **Theorem (Liouville numbers vanish, `Lc_eq_zero_of_liouville`).** *Every Liouville
> number $x$ has* $\mathrm{Lc}(x) = 0$.

The argument drives the quantity $q \cdot \lVert q\,x \rVert$ below any positive
threshold $\varepsilon$ you name. Given $\varepsilon$, choose the Liouville exponent
$n$ large enough; the resulting hyper-accurate fraction $p/q$ forces $q \cdot \lVert
q\,x \rVert$ to be minuscule. Since this happens for arbitrarily large denominators,
the $\liminf$ is pinned to $0$. (A delicate point handled along the way: one must
ensure the Liouville denominators are themselves large, and that $q\,x$ is never
exactly an integer, which holds because $x$ is irrational.)

From this the headline corollary falls out immediately:

> **Corollary (`liouville_not_bad`).** *No Liouville number is badly approximable.*

In the geometry of the number line, badly approximable numbers and Liouville numbers
sit in disjoint camps: the maximally stubborn versus the maximally yielding.

## A dictionary between two worlds

Step back and admire the bridge we have built. On one side lies *classical
Diophantine approximation*: explicit inequalities like $|x - p/q| < 1/q^2$, the
machinery of continued fractions, Dirichlet, Liouville, Hurwitz. On the other side
lies the *Lagrange constant* $\mathrm{Lc}(x)$, a single real number — really a point
in the extended nonnegative reals — that summarizes a number's entire approximation
personality. Our theorems form a precise dictionary:

- **Good approximations exist and their costs grow** $\longleftrightarrow$
  $\mathrm{Lc}(x) \le 1$ for every irrational (`Lc_le_one_of_irrational`).
- **Superhumanly good approximations exist** (Liouville) $\longleftrightarrow$
  $\mathrm{Lc}(x) = 0$ (`Lc_eq_zero_of_liouville`).
- **Stubbornness** ($\mathrm{Lc}(x) > 0$, "badly approximable") **excludes the
  Liouville extreme** (`liouville_not_bad`).

This is the same dictionary that, pushed further, classifies the *spectrum* of
possible stubbornness values — the celebrated Lagrange and Markov spectra — and that
governs the behavior of numbers under the symmetries $x \mapsto -1/x$ and
$x \mapsto x + 1$ that generate the modular group. The golden ratio anchors the top;
Liouville numbers anchor the bottom; everything else lives in between.

## Why it matters beyond mathematics

The instinct to approximate the infinite by the finite is everywhere. Continued
fractions — the natural engine behind all these best approximations — tell a Gregorian
calendar designer that $365.2425$ days is a near-optimal cheap stand-in for the true
solar year. They tell a synthesizer that $2^{7/12}$ is a near-perfect rational echo
of a musical fifth. They are the reason your computer's clock can stay synchronized
using integer counters, and they sit quietly inside algorithms for factoring
integers and breaking certain weak cryptographic keys, where an attacker who can
approximate a secret ratio *too well* can recover it outright. The line between "well
approximable" and "badly approximable" is, in those settings, the line between
security and exposure.

And there is a philosophical payoff. Liouville's discovery that some numbers are
*too well approximated to be algebraic* was humanity's first proof that
transcendental numbers exist at all — that the number line holds points beyond the
reach of any polynomial equation. The Lagrange constant turns this qualitative
discovery into a quantitative dial. A number's resistance to fractions, captured by a
single value $\mathrm{Lc}(x)$, encodes whether it is as smooth as the golden ratio or
as porous as a Liouville number. The fact that *every* irrational obeys
$\mathrm{Lc}(x) \le 1$, and that the most yielding numbers register exactly $0$, is a
small, sharp window onto the hidden order of the continuum — an order that, once
glimpsed, you can never quite unsee.
