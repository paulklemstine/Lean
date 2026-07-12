# The Mandelbrot Set's Secret Number Theory

## A picture everyone has seen

Almost everyone has met the Mandelbrot set, even without knowing its name. It is the famous black
beetle-shaped emblem of chaos: an inky central body ringed by an infinite froth of buds, spirals,
and lightning-shaped filaments that keep revealing more detail the further you zoom. It looks
organic, endless, and impossibly complicated.

And yet the rule that generates it fits on a matchbook. Pick a complex number $c$. Start at $0$
and repeatedly apply the quadratic step
$$z_{n+1} = z_n^2 + c.$$
If the resulting sequence $0,\; c,\; c^2+c,\; \dots$ stays bounded forever, then $c$ belongs to the
Mandelbrot set $M$. If the sequence runs off to infinity, $c$ is excluded. That single feedback
loop — square and add — draws the entire intricate figure.

This article is about a surprise hiding beneath the pretty picture. The lumps that decorate the
boundary of the Mandelbrot set — its "bulbs" — are not placed randomly. Their arrangement is
governed by honest, classical number theory: prime numbers, modular arithmetic, Fermat's little
theorem, the Fibonacci sequence, and the Farey fractions that mathematicians have studied for
centuries. The Mandelbrot set, it turns out, is secretly counting.

## First: why the set fits in a disk

Before the number theory, a warm-up that already shows how much control the simple rule gives us.

The critical orbit is the sequence starting at $0$. Intuitively, if $c$ is large, then squaring
quickly overwhelms everything and the orbit blasts off. We can make this precise. A basic fact
about distances in the plane (the reverse triangle inequality) gives, for the quadratic step,
$$\|z^2 + c\| \;\ge\; \|z\|^2 - \|c\|.$$
Now suppose $\|c\| > 2$. One can show by induction that the orbit grows geometrically:
$$\|c\|\,(\|c\|-1)^n \;\le\; \big\| f_c^{(n+1)}(0)\big\|,$$
where $f_c^{(n+1)}(0)$ is the orbit after $n+1$ steps. Because $\|c\| - 1 > 1$, the right-hand
side explodes as $n$ grows, so the orbit tends to infinity.

**Escape Radius Theorem.** *If $\|c\| > 2$, the critical orbit of $c$ diverges to infinity.
Consequently the entire Mandelbrot set lies inside the closed disk of radius $2$:* $M \subseteq
\{c : \|c\| \le 2\}$.

This is why every rendering of the set fits comfortably in the window $[-2, 2] \times [-2, 2]$.
Two concrete checks illustrate the boundary between "in" and "out": for $c = 0$ the orbit is
frozen at $0$; for $c = -1$ the orbit bounces in the tidy two-step cycle $0, -1, 0, -1, \dots$; so
both belong to $M$. But $c = 3$ has $\|c\| = 3 > 2$, so it escapes and is excluded.

## The real secret: angles that double

The deep structure appears when we ask *where on the boundary the bulbs sit*. Every bulb of the
Mandelbrot set can be labelled by a fraction $p/q$ between $0$ and $1$, called its **external
angle**. Think of the boundary as a circle of directions; a rational angle $p/q$ points at a
specific decorative bud.

Here is the magical part. The natural dynamics on these angles is not addition but **doubling**:
$$\theta \;\longmapsto\; 2\theta \bmod 1.$$
Angle-doubling is the shadow that the squaring map $z \mapsto z^2$ casts on the circle of
directions — squaring a number doubles its angle. And when we restrict to angles whose denominator
is $q$, doubling becomes something a number theorist recognizes instantly: it is **multiplication
by $2$ in the modular world $\mathbb{Z}/q\mathbb{Z}$**.

Iterating is now transparent. Doubling $n$ times multiplies by $2^n$:
$$\underbrace{\theta \mapsto 2\theta \mapsto 4\theta \mapsto \cdots}_{n \text{ steps}}
\quad\text{is}\quad x \longmapsto 2^n x \pmod q.$$

## Odd versus even: a clean dichotomy

When does an angle $p/q$ eventually return exactly to itself, cycling forever without ever settling
into a pre-cycle? This is precisely the question of whether the bulb is a genuine periodic feature.
The answer is a crisp parity law.

**Periodicity Dichotomy.** *The doubling map on $\mathbb{Z}/q\mathbb{Z}$ is a bijection if and
only if $q$ is odd. When $q$ is even, it fails to be injective.*

The reason is elementary once you see it. Multiplication by $2$ can be undone only if $2$ has a
multiplicative inverse modulo $q$, which happens exactly when $2$ and $q$ share no common factor —
that is, exactly when $q$ is odd. When $q$ is even, $2$ is a zero-divisor: for instance $0$ and
$q/2$ both double to the same residue $0 \pmod q$, so information is lost and no clean cycle can
exist. Angles with odd denominators are **purely periodic**; angles with even denominators are only
**pre-periodic**, drifting for a while before entering a cycle. This is the rigorous version of a
folklore rule about which external rays land on true bulbs.

## The period is a multiplicative order

For an odd denominator, *how long* is the cycle? Take the simplest angle, $1/q$, represented by the
residue $1$. Doubling $n$ times sends $1$ to $2^n$. So the angle returns to itself exactly when
$$2^n \equiv 1 \pmod q,$$
and the smallest such $n$ has a classical name: the **multiplicative order of $2$ modulo $q$**,
written $\operatorname{ord}_q(2)$.

**Period Theorem.** *The period of the angle $1/q$ under doubling equals $\operatorname{ord}_q(2)$.
Equivalently, $(dbl)^n(1/q) = 1/q$ if and only if $\operatorname{ord}_q(2)$ divides $n$.*

This single identity converts a question about a fractal's geometry into a question about the powers
of $2$. And it comes with a beautiful corollary. Since $2^{\operatorname{ord}_q(2)} \equiv 1
\pmod q$, the denominator always divides a Mersenne-type number:
$$q \;\big|\; 2^{\operatorname{ord}_q(2)} - 1.$$
The periods of Mandelbrot bulbs are woven from the same fabric as Mersenne primes.

## Fermat guards the primes

When the denominator $q$ is a prime other than $2$, an even sharper law kicks in — one of the oldest
gems in number theory.

**Fermat Bound.** *If $q$ is an odd prime, then the bulb period $\operatorname{ord}_q(2)$ divides
$q - 1$.*

This is Fermat's little theorem in disguise: $2^{q-1} \equiv 1 \pmod q$ for every prime $q$ not
dividing $2$, so the true period must be a divisor of $q - 1$. The consequence is striking: the
period of a prime-denominator bulb can never be arbitrary. It is corralled into the divisors of
$q - 1$.

## A cautionary tale: the tempting false conjectures

Whenever a pattern is this clean, it invites overreach. Two natural guesses look almost obviously
true — and both are false. We can settle them with explicit counterexamples.

**Tempting Conjecture 1.** *"$2$ is always a primitive root modulo every odd prime," i.e. the
period always attains its maximum $q - 1$.* **False.** Take $q = 7$. The powers of $2$ modulo $7$
are $2, 4, 1, 2, 4, 1, \dots$, so $\operatorname{ord}_7(2) = 3$, not $6$. The bulb has period $3$,
well short of the maximum. (Whether $2$ is a primitive root infinitely often is, in fact, a famous
unsolved problem — Artin's conjecture — which is exactly why no easy rule can hold.)

**Tempting Conjecture 2.** *"Every bulb period is prime."* **False.** Take $q = 5$. The powers of
$2$ modulo $5$ are $2, 4, 3, 1$, so $\operatorname{ord}_5(2) = 4$, which is composite. For contrast,
$\operatorname{ord}_3(2) = 2$. Bulb periods obey the divisibility laws above, but they are not
constrained to be prime.

These counterexamples are not failures; they are the guardrails that tell us exactly how far the
clean theory reaches.

## The golden thread: Fibonacci in the froth

There is one last, gorgeous layer. The bulbs are not just individually labelled — they are
*ordered*, and the ordering is the same one that organizes the rational numbers themselves: the
**Farey / Stern–Brocot** structure.

Two angles $p/q$ and $p'/q'$ are called **Farey neighbours** when their cross-difference is as small
as possible:
$$|p\,q' - p'\,q| = 1.$$
Between any two neighbours sits a new fraction, their **mediant**, formed by the delightfully
illegal-looking rule of adding numerators and denominators separately:
$$\frac{p}{q} \;\oplus\; \frac{p'}{q'} \;=\; \frac{p + p'}{q + q'}.$$
On the Mandelbrot set, the mediant is geometry: the largest bulb wedged between two neighbouring
bulbs carries exactly the mediant angle. This is why the bulbs shrink in an orderly way as their
denominators grow — the bigger the $q$, the smaller the bud.

Now follow the greedy path: at every stage, jump to the largest satellite bulb. That path traces out
$$\frac{1}{1},\; \frac{1}{2},\; \frac{2}{3},\; \frac{3}{5},\; \frac{5}{8},\; \frac{8}{13},\; \dots$$
— consecutive ratios of the **Fibonacci numbers** $1, 1, 2, 3, 5, 8, 13, \dots$, defined by
$F_{n+2} = F_{n+1} + F_n$. Three facts nail this down.

**Fibonacci Mediant Law.** *The mediant of the consecutive Fibonacci ratios $F_n/F_{n+1}$ and
$F_{n+1}/F_{n+2}$ is the next one, $F_{n+2}/F_{n+3}$.* This is just the recurrence, since
$F_n + F_{n+1} = F_{n+2}$ in both numerator and denominator.

**Cassini's Identity.** *For every $n$,*
$$F_{n+1}^2 - F_n\,F_{n+2} = (-1)^n.$$
The right side has absolute value $1$, which says precisely that consecutive Fibonacci ratios are
Farey neighbours. The golden path threads perfectly through the unimodular structure.

**Lowest Terms.** *Consecutive Fibonacci numbers are coprime,* so each ratio $F_n/F_{n+1}$ is
already fully reduced and names a genuine bulb — and since $F_{n+1} < F_{n+2}$ for $n \ge 1$, the
denominators strictly increase and the bulbs along the golden path steadily shrink.

The ratios $F_n/F_{n+1}$ famously converge to the reciprocal golden mean, $1/\varphi \approx
0.618$. So the most "irrational" number of all — the golden ratio, the hardest number to approximate
by fractions — is encoded in the accumulation point of the largest bulbs along the cardioid.

## Why this is beautiful

Start with a doodle: square a number and add a constant, over and over. Ask only whether the result
stays finite. Out of that one bit of information — bounded or not — emerges a shape whose decorations
are indexed by fractions, whose cycle lengths are multiplicative orders governed by Fermat's little
theorem, whose forbidden patterns are refuted by the same primes that resist Artin's conjecture, and
whose grandest features march to the beat of Fibonacci and the golden mean.

The Mandelbrot set is often celebrated as a monument to chaos and infinite complexity. But look
closely and you find something almost opposite at its heart: the oldest, most orderly ideas in
mathematics — primes, orders, Farey fractions, Fibonacci — quietly running the show. The froth on
the boundary is not noise. It is number theory, drawn in the plane.
