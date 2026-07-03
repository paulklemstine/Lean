# The Row That Always Remembers: A Hidden Invariant of the Eulerian Numbers

## A triangle older than it looks

Pascal's triangle is the most famous number pattern in mathematics: start with a
$1$ at the top, and let every entry be the sum of the two above it. But it is not
the only triangle worth staring at. Just beneath the surface of everyday
combinatorics lives a second, subtler triangle — the **Eulerian numbers** — and
it hides a secret that this article is about.

The Eulerian number $\left\langle n \atop k \right\rangle$ counts something you
have done a thousand times without noticing. Take the numbers $1, 2, \dots, n$
and shuffle them into a random order — a *permutation*. Now walk along your
shuffled list and count how many times a number is *bigger* than the one right
after it. Each such spot is called a **descent**. For instance, the arrangement
$2\,5\,3\,1\,4$ descends at $5\!>\!3$ and $3\!>\!1$: two descents. The Eulerian
number $\left\langle n \atop k \right\rangle$ is simply the number of
arrangements of $1,\dots,n$ that have exactly $k$ descents.

These counts assemble into a triangle:

$$
\begin{array}{ccccc}
1 & & & & \\
1 & 1 & & & \\
1 & 4 & 1 & & \\
1 & 11 & 11 & 1 & \\
1 & 26 & 66 & 26 & 1
\end{array}
$$

Row $n = 4$, for example, reads $1, 11, 11, 1$. It is symmetric (reversing a
permutation swaps ascents and descents), and — here is the first quiet miracle —
its entries add up to $1 + 11 + 11 + 1 = 24 = 4!$. That is no accident. Every row
of the Eulerian triangle sums to $n!$, the total number of permutations of
$n$ objects. Of course it does: every permutation has *some* number of descents,
so if you group the $n!$ permutations by their descent count and add the group
sizes back up, you must recover $n!$. The row sum is a census.

This article is about a version of the Eulerian triangle that has been *bent* —
deliberately deformed by a continuous dial — and about the astonishing fact that,
no matter how far you turn the dial, **the row still sums to $n!$**. The census
never changes, even when the individual entries stop being whole numbers, stop
counting anything obvious, and slide off into the real numbers. The row
remembers.

## Turning the dial

To bend the triangle we need a formula, not just a picture. There is a classical
closed form for the Eulerian numbers, discovered in the nineteenth century:

$$
\left\langle n \atop k \right\rangle
   = \sum_{i=0}^{k} (-1)^i \binom{n+1}{i}\,(k+1-i)^{\,n}.
$$

You can check it by hand for small cases; it faithfully reproduces $1, 4, 1$ for
$n=2$ and $1, 11, 11, 1$ for $n=3$. It is a compact, if slightly mysterious,
alternating sum of powers weighted by binomial coefficients.

Now introduce a single real number $s$ — call it the **shift** — and slip it into
the formula in the most natural place, subtracting it inside the power:

$$
A(n, k, s) \;=\; \sum_{i=0}^{k} (-1)^i \binom{n+1}{i}\,(k+1-i-s)^{\,n}.
$$

We call $A(n,k,s)$ the **extended Eulerian numbers**. When $s = 0$ we recover the
classical Eulerian numbers exactly. But for any other value of $s$ we get a whole
new triangle of *real* numbers — no longer symmetric, no longer integer-valued,
no longer obviously counting permutations. The shift $s$ is a continuous knob: as
you turn it, every entry of the triangle glides smoothly to a new value.

Here is a taste. For $n = 3$ the classical row is $1, 11, 11, 1$. Turn the dial to
$s = \tfrac12$ and the row becomes something like
$-0.125,\; 5.375,\; 12.875,\; 3.875$ — no symmetry, fractions everywhere, even a
negative number where a count used to be. And yet:

$$
-0.125 + 5.375 + 12.875 + 3.875 = 24 = 3!\,.
$$

The sum is untouched. That is the phenomenon. And it is not a coincidence of one
lucky value of $s$; it holds for *every* real shift simultaneously.

## The main theorem, in plain words

Two facts, stated together, capture the whole story.

**The Boundary Vanishing Theorem.** *For every degree $n$, every column index
$k \ge n+1$, and every shift $s$, we have $A(n,k,s) = 0$.*

In words: however far you turn the dial, the deformed triangle stays a triangle.
All the action is confined to the first $n+1$ columns, $k = 0, 1, \dots, n$;
outside that band, the entries are exactly zero. This matters because it tells us
the "row" is genuinely finite — there is nothing lurking off to the right that a
naive sum would miss.

**The Shift-Invariant Row-Sum Theorem.** *For every degree $n$ and every real
shift $s$,*

$$
\sum_{k=0}^{n} A(n, k, s) \;=\; n!\,.
$$

In words: the sum of a full row is always $n!$, no matter what $s$ is. The
individual numbers wobble as you turn the dial; their total is frozen. Setting
$s = 0$ recovers the familiar fact that the Eulerian numbers of order $n$ sum to
$n!$ — but now we see that this classical identity was just one snapshot of a
rigid, dial-independent law.

Why should a wildly deformed collection of real numbers keep adding up to the same
integer? The answer is a beautiful piece of mathematical machinery that turns the
problem inside out.

## The trick: differences instead of sums

The secret weapon is an operation as old as calculus but far more elementary: the
**forward difference**. Given any sequence or function $f$, its forward difference
is

$$
(\Delta f)(x) \;=\; f(x+1) - f(x).
$$

Repeat it — take the difference of the difference — and you get $\Delta^2 f$, then
$\Delta^3 f$, and so on. The forward difference is the discrete cousin of the
derivative, and it obeys two laws that are the heart of everything here.

**Law one: differencing lowers degree.** If $p(x)$ is a polynomial of degree $n$,
then $\Delta p$ has degree $n-1$. Difference it $n$ times and you are left with a
constant; difference it *one more time*, $n+1$ times in all, and you get exactly
zero. A degree-$n$ polynomial is annihilated by $\Delta^{n+1}$, always.

**Law two: the top difference of a power is a factorial.** Applying $\Delta$ to
the monomial $x^n$ exactly $n$ times does not give zero (that takes $n+1$
applications); it gives the constant $n!$. This is the discrete shadow of the fact
that the $n$-th derivative of $x^n$ is $n!$. Crucially, this survives shifting the
input: $\Delta^n$ applied to $(x + c)^n$ is still $n!$ for any constant $c$.

There is one more ingredient — an explicit formula for what an iterated difference
*looks like* when you expand it out. Differencing $n$ times produces exactly an
alternating binomial sum:

$$
(\Delta^n f)(x) \;=\; \sum_{k=0}^{n} (-1)^{\,n-k}\binom{n}{k}\, f(x+k).
$$

Now look back at the closed form for $A(n,k,s)$. It, too, is an alternating
binomial sum of a shifted power. These are the same species of expression. The
extended Eulerian numbers are *disguised iterated differences*. Once you see that,
the two theorems fall out almost of their own accord.

## Why the boundary vanishes

Fix a column $k \ge n+1$. The sum defining $A(n,k,s)$ runs over enough terms that,
after a change of index that reflects the summation, it turns into precisely the
alternating-binomial expansion of $\Delta^{n+1}$ applied to the polynomial
$x \mapsto (x-s)^n$, evaluated at a single point. But $(x-s)^n$ is a polynomial of
degree $n$, and by Law one, $\Delta^{n+1}$ wipes out any degree-$n$ polynomial
completely. So the whole expression is zero. The triangle stays a triangle not by
some delicate cancellation particular to Eulerian numbers, but because "one more
difference than the degree" always yields nothing.

## Why the row sum is frozen

The row-sum theorem is the real jewel, and its proof is a small marvel of
reorganization. We want

$$
\sum_{k=0}^{n} A(n,k,s)
   = \sum_{k=0}^{n}\sum_{i=0}^{k} (-1)^i \binom{n+1}{i}\,(k+1-i-s)^n .
$$

The first move is to **swap the order of summation** — sum over $i$ on the
outside, $k$ on the inside. When you do, the inner sum over $k$ becomes a running
total of shifted powers. Package that running total as a single sequence,

$$
Q(t) \;=\; \sum_{m=0}^{t-1} (m + 1 - s)^n ,
$$

the sum of the first $t$ shifted powers. The forward difference of this sequence
is transparent: adding one more term changes the total by exactly the next power,
so

$$
(\Delta Q)(t) \;=\; (t + 1 - s)^n .
$$

$Q$ is a discrete antiderivative of the shifted power. After the swap, the entire
row sum reorganizes into an alternating binomial combination of the values of
$Q$ — which, by the explicit expansion formula, is nothing but

$$
\sum_{k=0}^{n} A(n,k,s) \;=\; \bigl(\Delta^{n+1} Q\bigr)(0).
$$

The row sum is a *single iterated difference* of the running-total sequence. Now
finish with the two laws. Peel off one difference: $\Delta^{n+1} Q = \Delta^n(\Delta Q)
= \Delta^n\bigl[(t+1-s)^n\bigr]$. That is $\Delta^n$ applied to a shifted
monomial of degree $n$, and by Law two it equals $n!$ — regardless of the shift
$s$, because the factorial law is blind to translation. Evaluated at $0$, or
anywhere, it is $n!$.

That is the whole story. The shift $s$ enters only as a translation of the input,
and translation is exactly the thing the top-order difference cannot feel. The row
sum is frozen at $n!$ because a factorial is what you always get when you difference
a power all the way down — no matter where you start.

## Why any of this matters

It would be easy to dismiss the shift $s$ as a formal trick, a gratuitous knob
bolted onto a classical formula. It is not. Deformations like this are how
mathematics discovers that an identity it thought was special is really the tip of
a rigid structure.

The Eulerian numbers are not idle curiosities. They govern the statistics of
shuffles and sorting; they are the coefficients that convert between ordinary
powers and the "falling factorial" basis that underlies finite calculus; and they
appear, remarkably, in probability, as the exact description of how the sum of
several independent uniformly random numbers is distributed. When you add $n$
independent random numbers each drawn evenly from the interval $[0,1]$, the shape
of the resulting bell-like distribution is stitched together from polynomial
pieces whose weights are precisely the Eulerian numbers. The *shift* $s$ in our
deformation corresponds, in that picture, to sliding the whole random sum along
the line — and the row-sum invariant becomes the statement that probability is
conserved: shifting a distribution cannot create or destroy any of it. The total
is always $1$; here, rescaled, always $n!$.

There is a second, cleaner reason the result is satisfying. It is proved without
ever invoking the recurrence that normally *defines* the Eulerian numbers. The
usual development is slightly circular: define the numbers by a recurrence, prove
a closed form from the recurrence, then re-derive the recurrence from the closed
form. Here the numbers are *defined* by their closed form, and the row sum is
established directly, using only the difference calculus. The argument stands on
its own foundations. It is the difference between inheriting a house and building
one from the ground up.

## The moral

The forward difference is a humble instrument — subtract, then subtract again —
but it has an uncanny ability to reveal what is truly invariant. Under its gaze,
the Eulerian triangle turns out to be far more robust than its integer entries let
on. You can slide it, deform it, drag its numbers into the reals, and watch the
symmetry and the whole-number magic dissolve. But one thing survives every
insult: the row still adds up to $n!$. It is a small, sharp reminder that behind
the most familiar counting problems there often lies a continuous law, patiently
holding everything together — a row that always remembers where it came from.
