# The Spectrum Hidden Inside a Number

## How Well Can You Cheat at Approximating an Irrational?

Pick an irrational number — say $\sqrt{2} = 1.41421356\ldots$ — and try to
sneak up on it with fractions. You will quickly find $\tfrac{7}{5} = 1.4$,
then $\tfrac{17}{12} = 1.41\overline{6}$, then $\tfrac{41}{29} = 1.4137\ldots$,
each one a better impostor than the last. A natural question, almost as old as
mathematics itself, is: *how good can these impostors be?* Not in absolute
terms — any number can be approximated to arbitrary precision if you allow
enormous denominators — but relative to the size of the denominator you spend.

This is the heart of **Diophantine approximation**, and it has a beautiful,
precise scorecard. For a real number $x$, define its **Lagrange constant**

$$
k(x) = \limsup_{q \to \infty}\; \frac{1}{q^2 \,\bigl|x - p/q\bigr|},
$$

the largest constant $c$ for which the inequality $|x - p/q| < 1/(c\,q^2)$ has
infinitely many rational solutions $p/q$. A *large* $k(x)$ means $x$ is
**approximable** — it can be ambushed by unusually accurate fractions. A *small*
$k(x)$ means $x$ is **stubborn**, or in the trade, *badly approximable*. The
golden ratio $\varphi = \tfrac{1+\sqrt5}{2}$ is the most stubborn number of all,
with the smallest possible Lagrange constant $k(\varphi) = \sqrt5$. This is the
famous bottom rung of the **Lagrange spectrum**, and it is no accident that the
golden ratio's continued fraction is the maddeningly simple $[1;1,1,1,\ldots]$:
a number resists approximation precisely when its continued fraction refuses to
produce large terms.

This article is about a different, less explored question. Instead of asking how
the Lagrange constant behaves number by number, we ask how it *transforms* when
we push numbers around with the simplest nonlinear maps in mathematics.

## Moving Numbers with a Matrix

Take a $2\times 2$ matrix of integers,

$$
M = \begin{pmatrix} p & q \\ r & s \end{pmatrix},
$$

and let it act on a real number $x$ by the **Möbius transformation** (also
called a linear fractional transformation):

$$
M \cdot x = \frac{p\,x + q}{r\,x + s}.
$$

These maps are everywhere. They are the symmetries of the hyperbolic plane, the
gears of continued fractions, and the basic moves of the modular group that
organizes elliptic curves and modular forms. When $M$ is invertible over the
integers — that is, when its determinant $\det M = ps - qr$ equals $\pm 1$ — the
map $M$ shuffles the rationals among themselves perfectly and leaves the Lagrange
constant *completely unchanged*: $k(M\cdot x) = k(x)$. Such maps cannot make a
number easier or harder to approximate; they just relabel it.

The interesting case is when $\det M$ is some other nonzero integer, say $2$ or
$-3$ or $12$. Now $M$ is still a perfectly good map, but it is not reversible
within the integers. It can stretch and fold the number line in a way that
*does* change how approximable a number is. The natural quantity to study is the
**ratio**

$$
\rho(M, x) = \frac{k(M\cdot x)}{k(x)},
$$

which measures exactly how much the transformation $M$ amplifies or dampens the
approximability of $x$. If $\rho > 1$, the map made $x$ easier to approximate;
if $\rho < 1$, harder.

How big, and how small, can this ratio get? A theorem of Lagarias and Shallit
pins it inside a tidy interval. If $D = |\det M|$, then for every $x$,

$$
\frac{1}{D} \;\le\; \rho(M, x) \;\le\; D.
$$

The determinant — a single integer — sets a hard two-sided speed limit on how
much any Möbius map can distort approximability. Double the determinant's
absolute value and you double both the maximum boost and the maximum penalty.

## The Question: Does the Ratio Fill the Whole Interval?

Knowing the ratio *lives* in $[1/D, D]$ is one thing. Knowing *which values it
actually achieves* is another, and far richer. Picture the interval $[1/D, D]$ as
a radio dial. The Lagarias–Shallit bound tells us the dial's two ends. But are
all the stations in between real? Or are there silent gaps — values of the ratio
that no number can ever produce?

The central conjecture of this work says the dial is **completely full**, at
least when we restrict our attention to the most structured irrationals of all:

> **Density Conjecture.** For every primitive integer matrix $M$ with nonzero
> determinant and every pair of reals $u < v$ inside $[1/D, D]$, there exists a
> *real quadratic irrational badly approximable number* $x$ with
> $u < \rho(M, x) < v$.

In words: as $x$ ranges over quadratic irrationals — numbers like $\sqrt2$ or
$\tfrac{1+\sqrt{13}}{3}$ that solve quadratic equations with integer
coefficients — the ratios $k(M\cdot x)/k(x)$ are **dense** in the full interval
$[1/D, D]$. No gaps. Every station broadcasts.

Why restrict to quadratic irrationals? Because they are the numbers whose
approximation behavior we can actually compute. A theorem of Lagrange says a
number is a quadratic irrational exactly when its continued fraction is
**eventually periodic** — it repeats forever, like a decimal expansion that
settles into a cycle. That periodicity is what makes the Lagrange constant a
finite, computable maximum over one period rather than an unfathomable limit, and
it is what gives us the leverage to engineer ratios on demand.

## The Architecture Behind the Conjecture

Proving full density is a deep program, and it is not finished. But this work
lays down the **structural backbone** — the rigid scaffolding of facts that any
proof must rest on, each one established with complete certainty. These facts
fall into two groups: the geometry of the *target interval*, and the algebra of
the *Möbius action* itself.

### The target interval is real, centered, and self-reciprocal

The first thing to nail down is that the interval $[1/D, D]$ we are trying to
fill is not an illusion. Three facts secure it.

The cornerstone is almost embarrassingly simple, and yet everything hinges on
it: an integer matrix with nonzero determinant has

$$
|\det M| \ge 1.
$$

A determinant is an integer; the only integers excluded by "nonzero" are
sandwiched away from zero by at least a full unit. From this single inequality,
the rest of the interval's shape follows. Because $D \ge 1$, we have
$1/D \le 1 \le D$, so the value $\mathbf{1}$ — the "no change" ratio — always
lies inside the interval. Every Möbius map is *allowed* to leave approximability
untouched; the interval always contains its neutral point. And because
$1/D \le D$, the interval is genuinely nonempty, never a backwards or empty
range.

The most elegant structural fact is that the two endpoints are **reciprocals**:

$$
\frac{1}{D} \cdot D = 1.
$$

This is not a coincidence of arithmetic but a fingerprint of a deep symmetry.
Running a matrix $M$ backwards (using $M^{-1}$) inverts its effect on
approximability, sending a ratio $\rho$ to $1/\rho$. The interval $[1/D, D]$ is
exactly the set fixed, as a whole, by the flip $\rho \mapsto 1/\rho$. The
boost that $M$ can deliver at one extreme is mirrored, multiplicatively, by the
penalty it can inflict at the other. The spectrum is its own mirror image.

### Only the *primitive part* of the matrix matters

Here is a subtlety that the formalism makes sharp. Suppose you take a matrix $M$
and multiply every single entry by the same nonzero integer $k$, producing $kM$.
This changes the determinant dramatically — it gets multiplied by $k^2$. You
might expect the ratio spectrum to change too. It does not. The Möbius action is
**completely blind** to overall scaling:

$$
(kM)\cdot x = \frac{kp\,x + kq}{kr\,x + ks}
= \frac{k(p\,x+q)}{k(r\,x+s)} = \frac{p\,x+q}{r\,x+s} = M \cdot x.
$$

The shared factor $k$ cancels top and bottom, for *every* real $x$. The
geometric map is identical; only the bookkeeping changed. This is why the density
statement is phrased for **primitive** matrices — those whose entries share no
common factor. Every matrix is a primitive one in disguise, scaled up by some
integer, and the disguise is invisible to the spectrum. Primitivity is not a
technical convenience; it is the correct, irredundant way to label the maps.

### Möbius maps compose like matrices, and determinants multiply

The final pillar is what turns the problem from a study of individual maps into a
study of an entire algebraic system. Möbius transformations compose, and they do
so in perfect lockstep with matrix multiplication:

$$
M \cdot (N \cdot x) = (MN) \cdot x.
$$

Applying one fractional transformation after another is the same as applying the
single transformation built from the *product* of the two matrices. (One needs
only the mild caveat that no denominator along the way hits zero.) This is the
statement that the integer matrices form a *monoid acting on the line by
fractional transformations* — the same structure that powers the modular group.

Paired with composition is multiplicativity of the determinant, verified as a
bare polynomial identity in the eight entries of two matrices:

$$
\det(MN) = \det M \cdot \det N.
$$

Together these two facts have a powerful consequence for the spectrum. Since
ratios multiply under composition and determinants multiply under products, the
reachable ratios of a product $MN$ live inside the *product* of the intervals for
$M$ and $N$. The two-sided bound $[1/D, D]$ is not an isolated fact about one
matrix — it is **closed under composition**, exactly as a well-behaved spectrum
should be. And it explains the strategy behind the full conjecture: any matrix
$M$ can be factored, via its **Smith normal form**, into $U \cdot
\mathrm{diag}(1, D) \cdot V$ where $U$ and $V$ are reversible integer matrices
that *do not move the ratio at all*. All of the spectral action is concentrated
in the single diagonal matrix $\mathrm{diag}(1, D)$. Prove density for that one
clean family and, by composition, you get it for every matrix at once.

## Why the Restriction Class Must Be Stable

There is one more fact without which the entire question would be ill-posed. We
chose to study the ratio spectrum *restricted to quadratic irrationals*. For that
to even make sense, the transformation $M$ must keep us inside that class: if $x$
is a quadratic irrational, $M\cdot x$ had better be one too. Otherwise the
ratio $k(M\cdot x)/k(x)$ might be comparing apples to a number outside our
universe.

This **closure property** is the algebraic shadow of Lagrange's periodicity
theorem, and it holds in full generality:

> The Möbius image of a real quadratic irrational, under any integer matrix of
> nonzero determinant, is again a real quadratic irrational.

The proof has two moving parts. First, irrationality is preserved: if $x$ is
irrational and $M$ has nonzero determinant, then $M\cdot x$ cannot suddenly
become a fraction, because that would force $x$ itself to be rational. Second,
the *quadratic* nature survives: plug $M\cdot x = \tfrac{px+q}{rx+s}$ into a
generic quadratic equation and clear denominators, and out pops another quadratic
equation with integer coefficients that $x$ satisfies — and the nonzero
determinant guarantees the new equation is genuinely quadratic, not a degenerate
linear one. A clean discriminant identity,

$$
4a\,(a m^2 - b m n + c n^2) = (2am - bn)^2 - (b^2 - 4ac)\,n^2,
$$

underlies the key fact that a quadratic with non-square discriminant has no
nontrivial integer roots — the algebraic expression of the geometric truth that
an *anisotropic* binary form never vanishes. With closure in hand, the quadratic
irrationals form a stable arena, and the ratio spectrum is a well-defined object
living on it.

## What This Buys Us, and What Comes Next

The picture that emerges is strikingly clean. The approximability of an
irrational number, distilled into the single number $k(x)$, transforms under
integer fractional maps in a way governed entirely by one integer: the absolute
determinant $D$. That determinant fixes a symmetric, self-reciprocal interval
$[1/D, D]$; the neutral ratio $1$ always sits inside it; overall scaling is
invisible, so only the primitive class matters; and the whole apparatus is
closed under composition, with the spectral content of any map concentrated in
its diagonal Smith form.

What remains is to show the dial is truly full — that *every* value in $[1/D, D]$
is approached by an actual quadratic irrational. The roadmap is now concrete.
One direction is to realize the extreme ratios $D$ and $1/D$ as limits of
purely periodic continued fractions whose period is "aligned" with the diagonal
form $\mathrm{diag}(1, D)$, so the determinant gets absorbed into a single
partial-quotient step. Another is to upgrade density to a statement about
*measure*: not merely that the achievable ratios are dense, but that they fill up
a set of full length as we allow more and more complex continued fractions —
with the anisotropy identity above providing the quantitative control. A third is
to make the mirror symmetry $\rho \in \mathrm{Spec}(M) \iff 1/\rho \in
\mathrm{Spec}(M^{-1})$ exact.

These are the open frontiers. But the foundation is laid in stone. The ratio
spectrum is no longer a vague conjecture floating above the number line; it is a
rigid algebraic object with a known shape, a known symmetry, and a known
strategy for its conquest. Hidden inside every integer matrix, waiting to be read
off from a single determinant, is a spectrum of stations — and we now know
exactly where to tune the dial.
