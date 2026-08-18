# The Necklace That Broke a Conjecture

## How counting orbits on subsets reveals a hidden rigidity in symmetry

Take a bracelet with four beads. Colour two of them black and two white. How
many genuinely different bracelets have you made?

If you can rotate the bracelet — but not flip it over — the answer is two. The
black beads can sit next to each other, or opposite each other. No amount of
rotation turns one arrangement into the other. That little fact, which a child
could discover with a shoelace and some buttons, is enough to demolish a natural
and appealing conjecture about symmetry. This is the story of how.

---

## Counting shapes, not sets

Whenever a group of symmetries $G$ acts on a finite set $X$ of $n$ points, it
also acts on the subsets of $X$: if you can rotate the four bead-positions of a
bracelet, you can rotate any *collection* of positions. Two subsets that a
symmetry carries onto each other are, from the group's point of view, the same
shape. So it is natural to count shapes rather than subsets.

For each size $r$ between $0$ and $n$, write

$$t_r = \text{the number of } G\text{-orbits on the } r\text{-element subsets of } X.$$

The sequence $t_0, t_1, \dots, t_n$ is the **subset spectrum** of the action. It
is a fingerprint: it records, size by size, how much the symmetry group collapses
the combinatorics of $X$.

Three examples make the idea concrete.

**No symmetry at all.** If $G$ is the trivial group, nothing gets identified, so
$t_r$ is just the number of $r$-element subsets:
$$t_r = \binom{n}{r}.$$
For $n = 4$ the spectrum is $1, 4, 6, 4, 1$ — a row of Pascal's triangle.

**Total symmetry.** If $G$ is the full symmetric group of all $n!$ rearrangements
of the points, then any $r$-subset can be carried to any other, so
$$t_r = 1 \quad \text{for every } r,$$
and the spectrum is a flat line of ones.

**The bracelet.** If $G$ is the cyclic group of rotations of $n$ beads, the
spectrum counts *binary necklaces by weight*. For $n = 4$ it reads
$$1,\ 1,\ 2,\ 1,\ 1,$$
and there is the "adjacent versus opposite" phenomenon, sitting in the middle
slot. For larger $n$ the sequences swell:

| $n$ | spectrum of the rotation group on $n$ beads |
|---|---|
| $4$ | $1, 1, 2, 1, 1$ |
| $6$ | $1, 1, 3, 4, 3, 1, 1$ |
| $8$ | $1, 1, 4, 7, 10, 7, 4, 1, 1$ |
| $10$ | $1, 1, 5, 12, 22, 26, 22, 12, 5, 1, 1$ |

Every one of these is symmetric — read left to right or right to left, you see
the same numbers. That is no accident: complementing a subset, $s \mapsto X
\setminus s$, is compatible with every symmetry, so it matches orbits of
$r$-subsets with orbits of $(n-r)$-subsets. Hence
$$t_r = t_{n-r}$$
for every action, always. The spectra also start and end with $1$, since there
is exactly one empty subset and exactly one full subset.

There is one more universal constraint, and it is the one that makes the whole
subject tick. Every orbit of $r$-subsets has at most $|G|$ members (an orbit is
the image of the group, so it can be no bigger), and the orbits partition all
$\binom{n}{r}$ subsets of size $r$. So
$$\frac{1}{|G|}\binom{n}{r} \;\le\; t_r \;\le\; \binom{n}{r}.$$
The spectrum is a *squashed* copy of a row of Pascal's triangle: never bigger,
and never smaller than the row divided by the size of the group.

---

## The seductive conjecture

Rows of Pascal's triangle have a beautiful property: they are **log-concave**.
Each entry, squared, is at least the product of its two neighbours,
$$\binom{n}{r}^2 \;\ge\; \binom{n}{r-1}\binom{n}{r+1}.$$
Equivalently, the logarithms of the entries form a concave sequence: the row
rises, peaks, and falls, and it never "dents inward" on the way.

Log-concavity is one of the great unifying themes of modern combinatorics. It
holds for the coefficients of the chromatic polynomial of a graph, for the
independent sets of a matroid, for matching polynomials, for the coefficients of
products of real-rooted polynomials. Whole research programmes — Hodge theory
for matroids, Lorentzian polynomials — exist to explain why so many
combinatorial sequences bulge outward rather than inward. A log-concave sequence
with no internal zeros is automatically unimodal, so log-concavity is the
standard way of proving that a counting sequence rises and then falls exactly
once.

So here is the conjecture, and it is a very reasonable one:

> **Conjecture.** For every action of a finite group on a finite set, the subset
> spectrum is log-concave: $t_r^2 \ge t_{r-1}\, t_{r+1}$ for all $1 \le r < n$.

The evidence looks good. The trivial action gives Pascal's row, which *is*
log-concave. The full symmetric group gives the constant sequence $1,1,\dots,1$,
which *is* log-concave (with equality everywhere). Every spectrum is symmetric,
starts and ends at $1$, and lives sandwiched between two log-concave rows. And
morally, orbit counting is a "quotient" operation, and quotients of nice things
are often nice.

Now look again at the bracelet.

---

## Four beads, and the conjecture dies

For four beads under rotation the spectrum is $1, 1, 2, 1, 1$. Test
log-concavity at $r = 1$:
$$t_1^2 = 1^2 = 1, \qquad t_0 \cdot t_2 = 1 \cdot 2 = 2.$$
And $1 < 2$. The conjecture is false, at the smallest interesting example, by
the smallest possible margin.

What went wrong is worth savouring, because it is not an accident of small
numbers. The rotation group is *transitive*: it can carry any bead-position to
any other, so all four single-bead subsets form one orbit and $t_1 = 1$. It is
*not* transitive on pairs: adjacent and opposite pairs are genuinely different,
so $t_2 = 2$. Log-concavity at $r = 1$ asks that
$$1 = t_1^2 \ge t_0 \cdot t_2 = t_2,$$
i.e. that $t_2 = 1$ too. The problem is the forced boundary value $t_0 = 1$.
For a transitive action the sequence starts $1, 1, \dots$, and log-concavity at
the very first step demands that the sequence *never leaves* the value $1$.

That intuition can be made into a theorem, and it is the heart of the matter.

**Collapse principle.** *If two consecutive spectrum values are equal to $1$, say
$t_m = t_{m+1} = 1$, and the spectrum satisfies log-concavity from that point
onward, then $t_r = 1$ for every $r$ with $m \le r \le n$.*

The proof is a one-line induction. Log-concavity at $r = m+1$ says $t_{m+2} \le
t_{m+1}^2 / t_m = 1$; but every $t_r$ with $r \le n$ is at least $1$ (there is
always at least one $r$-subset, hence at least one orbit), so $t_{m+2} = 1$.
Now the pair $(t_{m+1}, t_{m+2})$ is again $(1,1)$, and the argument repeats
forever. The value $1$ is contagious: once the spectrum touches it twice in a
row, log-concavity locks it there for good.

---

## Rigidity: the conjecture is almost never true

A group is called **$r$-homogeneous** if it can carry any $r$-element subset to
any other — exactly the statement $t_r = 1$. It is **set-transitive** if it is
$r$-homogeneous for *every* $r$, i.e. if its spectrum is the constant sequence
of ones. Combining the collapse principle with the observation that a transitive
action has $t_0 = t_1 = 1$ gives:

> **Rigidity Theorem.** For a transitive action of a finite group on a finite
> set, the subset spectrum is log-concave **if and only if** the action is
> set-transitive, i.e. $t_r = 1$ for every $r$.

This is a startling reversal of expectations. Log-concavity is usually a soft
regularity property, satisfied by a wide swathe of sequences. Here it is
maximally rigid: it does not "usually" hold with a few exceptions; it holds
*only* in the single extreme case where the spectrum is as flat as it can
possibly be. There is no middle ground.

And the rigidity has teeth. Recall the sandwich $\binom{n}{r} \le |G|\, t_r$.
If a transitive action is log-concave then every $t_r = 1$, so
$$\binom{n}{r} \le |G| \qquad \text{for every } r,$$
and in particular
$$|G| \;\ge\; \binom{n}{\lfloor n/2 \rfloor} \;\approx\; \frac{2^n}{\sqrt{n}}.$$
A log-concave transitive action requires a group of *exponential* size. Any
transitive group smaller than the middle binomial coefficient is automatically a
counterexample — and almost every transitive group is smaller than that.

The cleanest family: a **regular** action is one where the group acts on itself
by translation, so that $|G| = |X| = n$ and the action is transitive. For $n \ge
4$ we have $n < \binom{n}{2}$, so the size obstruction kicks in immediately:

> **Every regular action on $n \ge 4$ points has a spectrum that is not
> log-concave.**

The four-bead bracelet is just the first member of an infinite family. Every
cyclic group $C_n$ with $n \ge 4$, acting on itself, breaks the conjecture — as
does the Klein four-group on four points (whose spectrum is $1,1,3,1,1$), and
every other group acting on itself by translation. In fact, looking at the necklace spectra listed above, the
failure is always visible at $r = 1$ (and by symmetry at $r = n-1$): the value
$t_2$ climbs while $t_1$ stays pinned at $1$.

Which groups *do* survive? Precisely the set-transitive ones — and these form a
very thin class. The symmetric groups are set-transitive in every degree, and so
are the alternating groups; beyond those there are only a handful of exceptional
examples in small degree, the smallest being the group of order $20$ of all maps
$x \mapsto ax + b$ on the five residues modulo $5$. A one-line conjecture about
all finite actions turns out to single out an exceptional list.

---

## What survives: two guarded inequalities

A false conjecture is not the end of a story; it is an invitation to find the
true statement hiding behind it. Log-concavity asks for $t_{r-1} t_{r+1} \le
t_r^2$ with constant $1$ on the right. What is the smallest constant that
*does* work?

**The group-size guard.** Squeeze the spectrum between its two binomial bounds
and use log-concavity of Pascal's row in the middle:
$$t_{r-1}\, t_{r+1} \;\le\; \binom{n}{r-1}\binom{n}{r+1} \;\le\; \binom{n}{r}^2
\;\le\; \bigl(|G|\, t_r\bigr)^2 = |G|^2\, t_r^2 .$$
So for **every** finite action and every $1 \le r < n$,
$$t_{r-1}\, t_{r+1} \;\le\; |G|^2\, t_r^2 .$$
The conjecture is true up to a factor of $|G|^2$. This is satisfying but
unsatisfying: for a huge group the constant is astronomically weak, and the
constant refers to the group rather than to the combinatorics.

**The group-free shadow guard.** Better is a bound that never mentions $|G|$ at
all. It comes from a classical shadow argument. Fix a representative $s$ of each
orbit of $r$-subsets. Any $(r+1)$-subset $u$ contains some $r$-subset $s'$; move
$s'$ onto the chosen representative $s$ of its orbit by a group element; then
$u$ has been carried to $s$ plus one extra point, chosen from the $n - r$ points
outside $s$. So every orbit of $(r+1)$-subsets is hit by one of $t_r \cdot (n-r)$
possibilities:
$$t_{r+1} \;\le\; (n-r)\, t_r \qquad \text{(extension bound)}.$$
Complementing subsets turns this statement into its mirror image,
$$t_r \;\le\; (r+1)\, t_{r+1} \qquad \text{(deletion bound)},$$
and multiplying the deletion bound at $r-1$ by the extension bound at $r$ gives,
for every finite action and every $1 \le r < n$,
$$\boxed{\,t_{r-1}\, t_{r+1} \;\le\; r\,(n-r)\, t_r^2 \,.}$$

This is the honest replacement for the conjecture: a *quantitative*
log-concavity that holds universally, with a defect factor $r(n-r)$ that is
purely combinatorial. And it is attained: the Klein four-group acting on four
points has spectrum $1,1,3,1,1$, and at $r=1$ the bound reads $t_0 t_2 = 3 = 1
\cdot 3 \cdot 1^2$, with equality. It is very nearly tight wherever the
conjecture fails. For
the four-bead bracelet at $r = 1$ it reads $t_0 t_2 = 2 \le 1 \cdot 3 \cdot 1 =
3$: the true value overshoots log-concavity by a factor of $2$, and the bound
allows $3$. For the ten-bead bracelet at $r = 1$ the violation is by a factor of
$5$ and the bound allows $9$. In the interior, though, the factor $r(n-r)$ is
generous by roughly a factor of $n/2$ — a hint (still a conjecture) that the
sharp universal constant is closer to $\max(r,\, n-r)$.

---

## Why the conjecture *felt* right — and what to conjecture instead

The interesting question is not why the conjecture fails but why it looked so
plausible. Log-concavity constrains the **second** differences of $\log t_r$.
For a transitive action the sequence is pinned at $t_0 = t_1 = 1$, so the second
difference at $r = 1$ is forced to compare a genuine growth step against no
growth at all. Any transitive action that grows anywhere must grow *first* at
$r = 1$ or later, and log-concavity refuses to let a sequence start flat and
then rise. The pathology is entirely a boundary effect, created by the
normalisation $t_0 = 1$.

Change "second differences" to "first differences" and the picture transforms.
The classical Livingstone–Wagner theorem says that for *any* finite permutation
group,
$$t_{r-1} \le t_r \qquad \text{whenever } 2r \le n .$$
Combined with the symmetry $t_r = t_{n-r}$, this says the spectrum is
**unimodal**, rising to a peak at $r = \lfloor n/2 \rfloor$ and then descending
mirror-symmetrically. Every necklace spectrum in the table above does exactly
that. Unimodality is normally the *consequence* of log-concavity; here it is the
truth, and log-concavity is the false strengthening. Monotonicity survives
because it is protected by a linear-algebraic fact — the inclusion map from
formal combinations of $r$-subsets to formal combinations of $(r+1)$-subsets is
injective in the range $2r \le n$ — that is immune to boundary effects.

Where does this leave the subject? With three sharpened questions:

1. **Is Livingstone–Wagner monotonicity the correct replacement?** The spectrum
   should be non-decreasing up to the middle and hence unimodal, for every
   finite action. This is a theorem about first differences, protected by
   injectivity of the inclusion map, and it is unspoiled by the boundary
   normalisation that ruins log-concavity.
2. **What is the sharp group-free constant?** The bound $r(n-r)$ is achieved
   nowhere; the measured slack suggests the true law is $t_{r-1} t_{r+1} \le
   \max(r, n-r)\, t_r^2$, with the exponent $1$ unimprovable.
3. **Is log-concavity true in the interior?** For a regular abelian action —
   the necklace case — the boundary values $t_0 = t_1 = 1$ are the only
   obstruction. Deleting them, the truncated sequence $t_1, t_2, \dots, t_{n-1}$
   appears to be genuinely log-concave in every computed example. If true, this
   would say the conjecture was not wrong so much as *misindexed*.

---

## The moral

The most useful thing a conjecture can do is fail informatively. This one did.
Asked whether the subset spectrum of a finite group action is always
log-concave, the answer is no — and a bracelet with four beads says so. But the
failure is not a random glitch; it is a razor-sharp dichotomy. For transitive
actions, log-concavity is not a mild regularity condition satisfied by most
groups: it is *equivalent* to being one of the handful of set-transitive
permutation groups, and it forces the group to have at least $\binom{n}{\lfloor
n/2\rfloor}$ elements. A property that in most of combinatorics is soft and
ubiquitous is here an exact characterisation of an exceptional finite list.

Meanwhile the true universal statement, $t_{r-1} t_{r+1} \le r(n-r)\, t_r^2$,
comes out of an argument you can explain in two sentences: to build an
$(r+1)$-shape you add one of $n-r$ points to an $r$-shape, and to build an
$r$-shape you delete one of $r+1$ points from an $(r+1)$-shape.

Which is exactly what you were doing all along with the shoelace and the
buttons.
