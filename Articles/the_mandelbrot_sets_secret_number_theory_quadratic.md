# The Mandelbrot Set’s Arithmetic Clockwork

*How a one-line recurrence turns divisibility, prime numbers, Möbius inversion, and Fibonacci addition into visible dynamics*

The Mandelbrot set begins with an instruction simple enough to fit on a postage stamp. Choose a complex number $c$, start at $z_0=0$, and repeat

$$
z_{n+1}=z_n^2+c.
$$

If the resulting orbit remains bounded, color the parameter $c$ black; if it escapes, color it according to how quickly it runs away. The familiar image emerges: a heart-shaped body surrounded by disks, filaments, and endlessly repeated miniature worlds.

It is tempting to treat this picture as pure geometry. Yet the recurrence is also a clock, and clocks ask arithmetic questions. When does an orbit return? Which return is the first? How many distinct positions does one cycle visit? How many cycles should occur at a given period? The answers bring divisibility, prime numbers, the Möbius function, and Fibonacci numbers into the same room.

The central lesson is both beautiful and cautionary. Exact periods carry genuine number-theoretic structure. But the picture does not automatically turn every appealing numerical pattern into a theorem. In particular, the multiplier at a bulb center is zero, not a finite cosine depending on an angle. The strongest story is the one the recurrence itself supports.

## From repetition to exact period

Fix $c$ and write $f_c(z)=z^2+c$. The notation $f_c^n(z)$ means applying $f_c$ exactly $n$ times, with $f_c^0(z)=z$. A point $z$ is **periodic with return time $n$** if

$$
f_c^n(z)=z.
$$

It has **exact period $q$** if $q>0$, it returns after $q$ steps, and it does not return after any positive number of steps smaller than $q$.

The engine behind everything is the composition law

$$
f_c^{m+n}(z)=f_c^n\bigl(f_c^m(z)\bigr).
$$

This says that walking $m+n$ steps is the same as walking $m$ steps and then another $n$. From this almost obvious identity comes a rigid arithmetic theorem.

**Exact-Period Divisibility Theorem.** If $z$ has exact period $q$, then $f_c^n(z)=z$ precisely when $q$ divides $n$.

One direction is immediate: if $n=kq$, repeat the $q$-step loop $k$ times. For the other, divide $n$ by $q$ with remainder:

$$
n=kq+r,\qquad 0\le r<q.
$$

Both the $n$-step walk and the $kq$-step walk return to $z$. The composition law therefore forces the remaining $r$ steps to return as well. Exactness forbids a positive return smaller than $q$, so $r=0$. Thus $q\mid n$.

This result gives “period” its full arithmetic meaning. Return times are not an irregular list; they are exactly

$$
0,q,2q,3q,\ldots.
$$

There is a second structural consequence.

**Distinct-Orbit Theorem.** If $z$ has exact period $q$, then the points

$$
z,f_c(z),f_c^2(z),\ldots,f_c^{q-1}(z)
$$

are all distinct. Consequently, the orbit contains exactly $q$ points before returning.

If two positions before the first return coincided, the segment between them would create a shorter return. That would contradict the definition of exact period. Moreover, every point on the same cycle returns after $q$ steps: starting the clock at a different point rotates the same loop rather than changing it.

These facts justify the basic labeling of periodic dynamics. A primitive period-$q$ cycle really has $q$ distinct phases, and every observed return time is a multiple of $q$. They do not, by themselves, prove that every geometric “bulb at angle $p/q$” has period $q$; that statement requires a separate theory connecting internal angles to hyperbolic components. Arithmetic rigidity begins once exact period has been established.

## Multipliers: the local weather of an orbit

A periodic orbit may attract nearby points, repel them, or sit at a boundary between the two behaviors. The diagnostic is its **multiplier**. Because $f_c'(z)=2z$, the chain rule gives the multiplier of the first $n$ steps from $z$ as

$$
M_n(c,z)=2^n\prod_{j=0}^{n-1}f_c^j(z).
$$

It obeys the recurrence

$$
M_{n+1}(c,z)=2f_c^n(z)M_n(c,z),\qquad M_0(c,z)=1.
$$

For a periodic cycle, a multiplier of modulus less than $1$ means attraction; modulus greater than $1$ means repulsion. A multiplier equal to $0$ is the strongest possible attraction and is called **superattracting**.

Now recall that the Mandelbrot orbit starts at the critical point $0$. For every positive $n$, its multiplier product contains the factor $f_c^0(0)=0$. Therefore

$$
M_n(c,0)=0\qquad(n>0).
$$

**Critical-Orbit Multiplier Theorem.** Every positive-length multiplier based at the critical point $0$ vanishes. In particular, if $0$ returns after exactly $q>0$ steps, its cycle is superattracting.

This is the correct local statement at a hyperbolic-component center. Under the usual logarithmic convention, the Lyapunov exponent of such a cycle is $-\infty$, since it involves the logarithm of a zero multiplier. It therefore cannot equal a generally finite expression such as $\log(2)\cos(\pi p/q)$. A numerical experiment that reports a finite value at the center is measuring a different quantity, sampling away from the center, or regularizing the logarithm.

The first two periods make the algebra tangible. A fixed point satisfies

$$
z^2-z+c=0,
$$

and its multiplier is $2z$. At $c=0$, the point $z=0$ is a superattracting fixed point. A genuine period-two point—one that returns after two steps but is not fixed—satisfies

$$
z^2+z+c+1=0.
$$

If its partner is $z_1=f_c(z)=z^2+c$, the two-step multiplier is

$$
M_2(c,z)=4zz_1=4z(z^2+c).
$$

At the period-two center $c=-1$, the critical orbit is $0\mapsto-1\mapsto0$, so the multiplier vanishes exactly as predicted.

## Prime periods and binary necklaces

Iteration also produces a counting problem. The equation $f_c^n(z)=z$ has degree $2^n$ in $z$, but those solutions include points whose exact periods merely divide $n$. Möbius inversion separates primitive periods. Define

$$
\Psi(n)=\sum_{d\mid n}\mu(n/d)2^d,
$$

where $\mu$ is the Möbius function: $\mu(m)=0$ if a prime square divides $m$, and otherwise $\mu(m)=(-1)^k$ when $m$ is a product of $k$ distinct primes.

For generic parameters, $\Psi(n)$ is the number of points of exact period $n$, counted algebraically. The first values are

$$
\Psi(1)=2,\qquad \Psi(2)=2,\qquad \Psi(3)=6.
$$

The sum is nonnegative for every positive $n$. One way to see the underlying estimate is to isolate the leading term $2^n$. Every proper divisor $d$ of $n$ satisfies $d<n$, and the absolute value of each Möbius coefficient is at most $1$. Thus the possible negative contribution is bounded by a sub-sum of

$$
1+2+2^2+\cdots+2^{n-1}=2^n-1,
$$

so it cannot overwhelm $2^n$.

When $p$ is prime, its only positive divisors are $1$ and $p$, and the formula becomes

$$
\Psi(p)=2^p-2.
$$

Each exact period-$p$ cycle contains $p$ points, so the corresponding cycle count is $(2^p-2)/p$. Why is this an integer? Fermat’s little theorem answers:

$$
p\mid 2^p-2.
$$

For every prime $p\ge3$, this quotient is at least $2$. Prime periods are therefore rich, but not because primality magically gives a bulb a unique dihedral symmetry. The rigorous arithmetic statement is sharper and more modest: primality simplifies the divisor lattice, turning Möbius inversion into the two-term count $2^p-2$.

## Farey addition and Fibonacci growth

Fractions enter the combinatorics of rotation numbers through the **Farey mediant**. Given $p_1/q_1$ and $p_2/q_2$, their mediant is

$$
\frac{p_1+p_2}{q_1+q_2}.
$$

The denominators add. If consecutive numerator-denominator data are Fibonacci pairs, mediation advances the sequence. Writing $F_0=0$, $F_1=1$, and $F_{n+2}=F_{n+1}+F_n$, one obtains

$$
F_{n+1}+F_{n+2}=F_{n+3}.
$$

Thus the mediant of $F_n/F_{n+1}$ and $F_{n+1}/F_{n+2}$ has denominator $F_{n+3}$. This exact identity explains why Fibonacci arithmetic naturally appears whenever nearby rational rotation data are built by repeated mediation. Connecting a particular chain of visible components to those fractions requires geometric input, but the arithmetic mechanism itself is transparent.

## Knowing when an orbit has escaped

The recurrence also powers the algorithm that draws the set. Let $w=f_c^n(z)$. The reverse triangle inequality yields

$$
|w^2+c|\ge |w|^2-|c|.
$$

If $|w|>2$ and $|w|>|c|$, then

$$
|w^2+c|>|w|.
$$

**One-Step Escape-Growth Theorem.** Once an iterate is larger than both $2$ and $|c|$, the next iterate has strictly larger modulus.

This theorem certifies immediate outward growth. A full divergence theorem follows by strengthening and iterating a suitable lower bound; the familiar escape-time renderer uses this principle to stop tracking points that have unmistakably fled.

## What the picture truly computes

The Mandelbrot set does reveal arithmetic, but not as a literal prime-factorization machine. What it offers is subtler. Its recurrence turns exact period into divisibility. Its cycles turn primitive point counts into necklace-like quotients. Prime periods activate Fermat’s theorem. Rational mediation generates Fibonacci denominators. Its critical point forces superattracting centers to have zero multiplier.

Just as important are the boundaries of these conclusions. Period factorization alone does not produce a topological product decomposition of bulbs. A symmetry claim must specify whether it concerns a planar component, an orbit portrait, or an abstract combinatorial object. An angle-period correspondence needs definitions of internal angles and hyperbolic components. None follows merely from factoring an integer.

This viewpoint also changes how one reads a computer image. Color bands are not merely decoration: they record stopping times in an iterative experiment. A periodic window is not merely a round patch: it signals a stable cycle whose phases can be counted. Repeated decorations invite rational labels, but those labels become mathematically meaningful only after their connection to dynamics is proved. The picture is thus both a source of conjectures and a lesson in separating observation from consequence.

That restraint does not diminish the wonder. A single quadratic rule creates a landscape in which algebra controls return, calculus controls stability, and number theory controls counting. The image is not an oracle that answers every arithmetic question we project onto it. It is something better: a precise meeting place where geometry and arithmetic continually explain one another.