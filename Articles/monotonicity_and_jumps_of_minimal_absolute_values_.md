# The Golden Thread Hidden in the Fifth Roots of Unity

## A number that refuses to disappear

Take a regular pentagon and mark its five corners on a circle of radius one in the
plane. If you treat those corners as complex numbers, they are exactly the *fifth
roots of unity*: the five solutions of the equation $z^5 = 1$. Written out, they are
$1, \zeta, \zeta^2, \zeta^3, \zeta^4$, where $\zeta = e^{2\pi i/5}$ is the point you
reach by rotating one-fifth of the way around the circle.

Here is a game that sounds innocent but turns out to hide something beautiful. Pick a
handful of these five points — you are allowed to reuse them — and add them together
as vectors in the plane. Sometimes the sum lands exactly on the origin: for example
$1 + \zeta + \zeta^2 + \zeta^3 + \zeta^4 = 0$, because the five corners of a regular
pentagon perfectly balance. But whenever the sum does *not* vanish, it lands some
positive distance away from the origin. The question that drives this article is:

> Among all the ways to add up $n$ fifth roots of unity so that the result is **not**
> zero, how close to the origin can you possibly get?

Call that smallest possible distance $\sigma_5(n)$. It is the "minimal non-vanishing
modulus" of an $n$-term sum of fifth roots of unity. At first glance $\sigma_5(n)$
looks like a dry combinatorial quantity — a minimum over a finite but rapidly growing
list of vector sums. What is astonishing is *what controls it*: the golden ratio, and,
lurking right behind it, the Fibonacci and Lucas numbers.

## Two points, and the golden ratio appears

Start with the simplest interesting case: $n = 2$. We add two of the five points. Since
$5$ is an odd number, two of these unit vectors can never cancel exactly, so the sum is
always non-zero — no fine print needed. How small can $\lvert \zeta^i + \zeta^j\rvert$
be?

The answer is exactly the reciprocal of the golden ratio,
$$\sigma_5(2) = \frac{1}{\varphi} = \varphi - 1 = 0.6180339\ldots,$$
where $\varphi = \tfrac{1+\sqrt5}{2}$ is the golden ratio itself. This is not an
approximation or a numerical coincidence; it is exact, and there is a clean reason for
it.

The reason lives in a pair of special sums called the **Gaussian periods** of the
pentagon:
$$p = \zeta + \zeta^4, \qquad q = \zeta^2 + \zeta^3.$$
Each of these pairs up a root with its mirror image across the real axis (its complex
conjugate), so both $p$ and $q$ are ordinary real numbers. They satisfy two strikingly
simple relations:
$$p + q = -1, \qquad p\,q = -1.$$
The first follows because $1 + \zeta + \zeta^2 + \zeta^3 + \zeta^4 = 0$, so
$p + q = -1$. The second is a short computation using $\zeta^5 = 1$. Together they say
that $p$ and $q$ are the two roots of the quadratic
$$x^2 + x - 1 = 0.$$

Now compare with the defining equation of the golden ratio, $\varphi^2 = \varphi + 1$,
i.e. $\varphi$ is a root of $x^2 - x - 1 = 0$. Replacing $x$ by $-x$ turns one quadratic
into the other. So the two Gaussian periods are precisely $-\varphi$ and its conjugate
$-\psi$, where $\psi = \tfrac{1-\sqrt5}{2}$ is the "small" golden conjugate. Their
absolute values are
$$\lvert p\rvert, \lvert q\rvert = \varphi \ \text{ and }\ \frac{1}{\varphi}.$$

So the golden ratio is not merely *associated* with the pentagon in some vague
aesthetic sense — it is literally the length of one of these two-root sums, and its
reciprocal is the length of the other. A short geometric argument shows that no
two-term sum can be shorter than $1/\varphi$, so this smaller value is exactly the
champion: $\sigma_5(2) = 1/\varphi$.

## Powers of the periods: Lucas and Fibonacci step forward

The real magic starts when we take powers. Because $p$ and $q$ are $-\varphi$ and
$-\psi$, raising them to the $n$-th power and adding gives
$$p^n + q^n = (-\varphi)^n + (-\psi)^n = (-1)^n\bigl(\varphi^n + \psi^n\bigr).$$

The quantity $\varphi^n + \psi^n$ is one of the most famous formulas in all of
elementary number theory: it is exactly the $n$-th **Lucas number** $L_n$. The Lucas
numbers march along as
$$2,\ 1,\ 3,\ 4,\ 7,\ 11,\ 18,\ 29,\ 47,\ \ldots,$$
each the sum of the two before it, just like the Fibonacci numbers but starting from a
different pair. So we arrive at a clean bridge:
$$\boxed{\ (\zeta+\zeta^4)^n + (\zeta^2+\zeta^3)^n = (-1)^n\, L_n.\ }$$
An expression built purely from the corners of a pentagon turns out to be a Lucas
number in disguise, for every $n$.

The *difference* of the same powers tells the Fibonacci story. Since
$\varphi^n - \psi^n = \sqrt5\,F_n$, where $F_n$ is the $n$-th Fibonacci number
($1, 1, 2, 3, 5, 8, 13, \ldots$), squaring removes the sign ambiguity and the messy
$\sqrt5$ in one stroke:
$$\boxed{\ \bigl((\zeta+\zeta^4)^n - (\zeta^2+\zeta^3)^n\bigr)^2 = 5\,F_n^2.\ }$$

These two identities are the heart of the matter. They say the two most celebrated
integer sequences in mathematics are the exact bookkeeping devices for the arithmetic
of the pentagon.

## Why staircases, and why those special heights

Return now to the general question: how does $\sigma_5(n)$ behave as $n$ grows? Adding
more roots gives you more freedom to nudge the sum toward the origin, so intuitively
$\sigma_5(n)$ should never increase as you add five more terms at a time. That intuition
is correct, and it can be made precise: within each residue class of $n$ modulo $5$, the
sequence $\sigma_5(n)$ is **monotone non-increasing**. It steps down, or stays level,
but never climbs.

The subtle and beautiful part is *when* it actually steps down. A strict decrease,
$$\sigma_5(n) > \sigma_5(n+5),$$
happens for a very special set of $n$: precisely when $n + 5$ has one of the three
forms
$$5F_m, \qquad L_m, \qquad 2L_m$$
for some positive integer $m$ — that is, five times a Fibonacci number, a Lucas number,
or twice a Lucas number. Everywhere else the sequence pauses on a plateau. The result
is a staircase whose steps fall exactly at Fibonacci- and Lucas-scaled positions.

Why should these particular heights govern the jumps? The reason traces back to the
identities above. Minimizing the length of a sum of roots is, after the reduction to the
real quadratic field generated by $\varphi$, a problem about how small an integer
combination $a\varphi + b$ can be made. The powers of $\varphi$ obey
$\varphi^n = F_n\varphi + F_{n-1}$, so the Fibonacci numbers are the *coefficients* that
appear when you push $\varphi$ to higher powers, while the Lucas numbers record the
symmetric combination $\varphi^n + \psi^n$. The extremal sums — the ones that get
closest to the origin without vanishing — turn out to be powers of the periods scaled by
powers of $\varphi$. That is why the value of $\sigma_5$ hovers around $\varphi^{-k}$
for suitable $k$, and why the sequence resets to a new, smaller plateau exactly when a
Fibonacci or Lucas milestone is crossed.

## A conversation between two worlds

Step back and notice what has happened. We began in the world of **cyclotomy** — roots
of unity, regular polygons, symmetries of the circle, the raw material of algebraic
number theory. We ended in the world of **combinatorics** — Fibonacci and Lucas numbers,
recurrences, the golden ratio, the arithmetic of a quadratic field. These are usually
taught in different courses and studied by different communities. Yet the Gaussian
periods of the pentagon act as a translator, sending each statement about vector sums of
fifth roots into an equivalent statement about the golden field.

This kind of bridge is what mathematicians prize most. A hard question on one side
becomes a tractable question on the other. The mysterious staircase of $\sigma_5(n)$,
which would be nearly impossible to guess by staring at lists of vector sums, becomes
almost inevitable once you know that Fibonacci and Lucas numbers are secretly running
the show.

## Where the pentagon meets the everyday

The pentagon and the golden ratio are not confined to pure mathematics. Five-fold
symmetry is forbidden to ordinary repeating crystals, yet it appears in *quasicrystals*,
exotic materials whose atomic patterns never repeat but are organized around exactly the
$\varphi$-arithmetic we met above; their diffraction patterns are governed by sums of
fifth (and tenth) roots of unity. The same golden combinations control certain error
bounds in signal processing, where one wants to know how close a sum of equally spaced
phases can come to cancelling. And the Fibonacci–Lucas duo turns up wherever growth,
tiling, or optimal spacing is at stake, from phyllotaxis in sunflowers to efficient
search algorithms.

What this story adds is a precise, exact dictionary. The vague sense that "pentagons and
the golden ratio go together" is upgraded to identities you can write down and check:
the length of a two-root sum is exactly $1/\varphi$, the $n$-th power sum of the periods
is exactly a Lucas number, and the staircase of minimal distances steps down exactly at
the Fibonacci and Lucas marks. It is a small, self-contained example of one of
mathematics' recurring miracles — that a pattern glimpsed in one corner of the subject
turns out to be an old friend from another, wearing a different name.
