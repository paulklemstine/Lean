# Impossible Geometries: Where Parallel Lines Converge *AND* Diverge

For two thousand years, every geometry humans imagined had to make a choice
about parallel lines. Euclid's choice was the famous one: take a line and a
point not on it, and there is exactly one parallel through that point — a
companion line that runs alongside the first forever, never meeting, never
drifting closer. In the nineteenth century mathematicians dared to break the
rule. In *hyperbolic* geometry, parallels fan out: they diverge, racing away
from each other into an ever-widening gulf. In *elliptic* geometry — the
geometry of a sphere's surface — there are no parallels at all; every pair of
"straight lines" eventually crosses. They converge.

Diverge, or converge. Pick one. That has always been the deal.

This article is about a place where you don't have to pick — a discrete
geometry, hiding inside the most famous sequence in mathematics, in which the
*same* pair of parallel lines does **both**. Up close they spread apart like
hyperbolic parallels. Far away they are dragged back together and forced to
cross, like lines on a sphere. It sounds impossible. It is completely rigorous,
and we can write down exactly where the crossings happen.

## The Fibonacci numbers, and a question about divisibility

Everyone meets the Fibonacci sequence eventually:

$$F_1 = 1,\quad F_2 = 1,\quad F_3 = 2,\quad F_4 = 3,\quad F_5 = 5,\quad F_6 = 8,\quad F_7 = 13,\dots$$

each term the sum of the two before it. Most people meet it as a curiosity
about rabbits or sunflower spirals. We are going to meet it as a *landscape*.

Here is the question that builds the landscape. Fix a number — say 3. Now walk
along the Fibonacci sequence and ask: **which Fibonacci numbers are divisible by
3?**

$$F_4 = 3,\quad F_8 = 21,\quad F_{12} = 144,\quad F_{16} = 987,\dots$$

The answer is breathtakingly orderly. The multiples of 3 appear at positions
$4, 8, 12, 16, \dots$ — every fourth Fibonacci number, exactly, with metronomic
regularity. Try 4 instead: the Fibonacci numbers divisible by 4 sit at
positions $6, 12, 18, 24, \dots$. Try 5: positions $5, 10, 15, 20, \dots$.

Each modulus $m$ carves out a perfectly even ladder of positions. This is not a
coincidence and it is not approximate. It is a theorem, and it is the
foundation of everything that follows.

## The rank of apparition

The first rung of each ladder has a wonderful old name, coined in the era of
Édouard Lucas in the 1870s: the **rank of apparition**, written $\alpha(m)$. It
is the position of the *first* Fibonacci number that $m$ divides — the moment
$m$ first "appears" inside the sequence:

$$\alpha(m) = \text{the least } k > 0 \text{ such that } m \mid F_k.$$

So $\alpha(3) = 4$ (the first multiple of 3 is $F_4 = 3$), $\alpha(4) = 6$,
$\alpha(5) = 5$. A short table tells the story:

| $m$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|----|---|---|---|---|---|---|---|---|---|----|----|----|
| $\alpha(m)$ | 1 | 3 | 4 | 6 | 5 | 12 | 8 | 6 | 12 | 15 | 10 | 12 |

The deep fact — the one that turns arithmetic into geometry — is this.

> **The Law of Apparition.** A Fibonacci number $F_k$ is divisible by $m$ *if
> and only if* $k$ is a multiple of $\alpha(m)$. In symbols,
> $$m \mid F_k \iff \alpha(m) \mid k.$$

Once you know the very first appearance, you know *all* the appearances: they
are exactly the multiples of that first position. The ladder is perfectly even
because the law of apparition forces it to be. This is the engine. Everything
below is a consequence.

## Drawing the lines

Now we build the geometry. To each modulus $m$ we attach a **divisibility
line**:

$$L(m) = \{\, k \ge 0 : m \mid F_k \,\} = \{0,\ \alpha(m),\ 2\,\alpha(m),\ 3\,\alpha(m),\ \dots\}.$$

It lives on the number line of positions — a discrete, perfectly regular set of
points, like the tick marks of a ruler whose spacing is $\alpha(m)$. The line
for 3 ticks every 4 steps; the line for 5 ticks every 5 steps; the line for 4
ticks every 6 steps.

These are our "lines." When are two of them *parallel*? In spirit, when their
spacings disagree — when $\alpha(a) \neq \alpha(b)$, so the two rulers never
keep step locally. Take $L(3)$ (ticks at $0,4,8,12,\dots$) and $L(5)$ (ticks at
$0,5,10,15,\dots$). Near the origin they immediately separate: after the shared
start at $0$, line 3 is at 4 while line 5 is at 5; then 8 versus 10; then 12
versus 15. The gap between corresponding ticks grows without bound: $0, 1, 2, 3,
\dots$. **They diverge** — the unmistakable signature of hyperbolic parallels.

This is the *Euclidean–hyperbolic face* of the geometry, and it is a theorem
about even spacing: consecutive members of any line $L(m)$ are separated by
*exactly* $\alpha(m)$, with nothing in between. The lines are honest arithmetic
progressions, drifting apart at constant rate whenever their steps differ.

## …and then they cross

Here is where the impossible happens. Follow $L(3)$ and $L(5)$ far enough and
something a Euclidean would call paradoxical occurs. At position $20$, both
lines have a tick: $20 = 5 \times 4$ is a multiple of $\alpha(3)=4$, and
$20 = 4 \times 5$ is a multiple of $\alpha(5)=5$. The two parallels, having
spent the whole journey running away from each other, **meet**.

And they keep meeting — at $20, 40, 60, \dots$ — a brand-new evenly spaced
ladder of crossings. Diverging parallels that nonetheless intersect, again and
again, forever. That is precisely the *elliptic face* of the parallel
postulate, the behavior of great circles on a sphere, living inside the very
same pair of lines that was just diverging.

How can both be true? Because "parallel" here is a local statement about
spacing, while "crossing" is a global statement about coincidence — and in this
arithmetic world the two are not in conflict. The crossings are not a glitch;
they are governed by an exact and beautiful law.

> **The Convergence Law.** Two divisibility lines always re-intersect, and
> their meeting set is itself a divisibility line:
> $$L(a) \cap L(b) = L(\operatorname{lcm}(a,b)),$$
> an evenly spaced ladder whose step is $\operatorname{lcm}\!\big(\alpha(a),
> \alpha(b)\big)$.

For $L(3)$ and $L(5)$: their meeting set is $L(15)$, ticking at $0, 20, 40,
\dots$, with step $\operatorname{lcm}(4,5) = 20$. The lines that flee each other
in the small are bound to each other in the large, and the binding is as
regular as everything else.

## The law that makes it click

Underneath the crossings is an arithmetic identity so clean it feels like it
*has* to be true — and which the project establishes with full rigor, with no
assumptions whatsoever beyond positivity:

> **The Join Law.** For all positive integers $a$ and $b$,
> $$\alpha\big(\operatorname{lcm}(a,b)\big) = \operatorname{lcm}\big(\alpha(a),\, \alpha(b)\big).$$

In words: the rank of apparition turns the least common multiple of *moduli*
into the least common multiple of their *ranks*. The first appearance of "$a$
and $b$ simultaneously" lands exactly at the least common multiple of when each
appears alone. Older results in the literature proved this only when $a$ and $b$
share no common factor; here the coprimality crutch is thrown away entirely. It
holds across the board — $\alpha(\operatorname{lcm}(4,6)) = \alpha(12) = 12 =
\operatorname{lcm}(6,12) = \operatorname{lcm}(\alpha 4,\alpha 6)$, and so on for
every pair.

The Join Law is what makes the crossings *predictable*. To find where two
diverging lines will reunite, you do not chase Fibonacci numbers; you simply
take a least common multiple. The convergence is computed, not searched.

## A subtle twist: the asymmetry of converging and diverging

There is one more turn of the screw, and it is the most interesting part of the
whole story. We have two natural ways to combine moduli: take their least common
multiple (the "join," reaching *up* the divisibility hierarchy) or their
greatest common divisor (the "meet," reaching *down*). The Join Law says
$\alpha$ respects the join *perfectly*. Does it also respect the meet?

It does not — and the failure is sharp. Compare $\alpha$ of the gcd with the gcd
of the $\alpha$'s, using $a = 4$ and $b = 6$. The greatest common divisor of 4
and 6 is 2, and $\alpha(2) = 3$. But the greatest common divisor of $\alpha(4) =
6$ and $\alpha(6) = 12$ is $6$. So

$$\alpha\big(\gcd(4,6)\big) = 3 \quad\text{while}\quad \gcd\big(\alpha(4),\alpha(6)\big) = 6.$$

There is always a *bound* — $\alpha(\gcd(a,b))$ divides $\gcd(\alpha(a),
\alpha(b))$ — but here $3 \ne 6$, so the bound is strict. The rank of apparition
is a **join-morphism but not a meet-morphism**.

This is the mathematical fingerprint of our impossible geometry. The two faces
of the parallel postulate are *not* mirror images. Convergence — lines being
forced back together — is governed by an exact law. Divergence — the way lines
spread and the way coarser moduli relate to finer ones — is only governed by an
inequality, a one-way bound that genuinely leaks. The geometry is lopsided, and
the lopsidedness is a precise, provable theorem rather than a vague impression.

Along the way the structure also behaves like a well-mannered map of
hierarchies: if $a$ divides $b$, then $\alpha(a)$ divides $\alpha(b)$
(monotonicity). Coarser questions have answers that sit cleanly inside finer
ones.

## The Pythagorean cameo

It would be a shame to talk about impossible geometries without the most famous
triangle of all. Feed the legs and hypotenuse of the $(3,4,5)$ right triangle
into the rank of apparition and read off the **apparition profile**:

$$\big(\alpha(3),\ \alpha(4),\ \alpha(5)\big) = (4,\ 6,\ 5).$$

The smallest Pythagorean triple casts a shadow $(4,6,5)$ into the apparition
lattice — a small, concrete fingerprint of the same machinery, computed from
$F_4 = 3$, $F_6 = 8$, and $F_5 = 5$. It is a reminder that this exotic geometry
is not floating in the abstract: it is anchored to the most elementary objects
in arithmetic.

## Why this matters

Strip away the romance and a real idea remains. We usually think of geometry as
the study of shapes in space and arithmetic as the study of whole numbers, two
separate continents. The rank of apparition builds a bridge between them: it
takes the divisibility relationships among numbers — a purely arithmetic web —
and renders them as *lines*, *spacings*, *parallels*, and *intersections*, the
raw vocabulary of geometry. The Law of Apparition is the dictionary that
translates one language into the other, and once you have a dictionary, every
sentence in one language becomes a sentence in the other.

In that translated picture, the ancient debate about parallel lines dissolves.
The question "do parallels meet?" assumed a single answer was possible.
Here the honest answer is *yes and no, at different scales*, and we can say
exactly which scales: parallels diverge locally with their own spacings, and
they reconverge globally at the least common multiple of those spacings. The
asymmetry between the exact Join Law and the leaky meet bound even tells us that
the converging and diverging are not the same phenomenon viewed from two sides;
they are genuinely different, and the geometry knows it.

Euclid asked us to choose. Lobachevsky and Riemann each chose differently. The
Fibonacci numbers, it turns out, refuse to choose at all — and in their refusal
they sketch a geometry where parallel lines converge *and* diverge, exactly,
forever, on a ladder we can compute with nothing more than a least common
multiple.
