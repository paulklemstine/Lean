# Counting in a World Made of Subspaces: The Hidden Threshold of Grassmann Schemes

## A different kind of triangle

Almost everyone meets Pascal's triangle in school. You write a $1$ at the top,
then build each new row by adding the two numbers above. The entries are the
*binomial coefficients* $\binom{n}{k}$, the number of ways to choose $k$ things
from a set of $n$. They count committees, poker hands, lottery tickets, and
paths through a city grid.

But there is a second, stranger triangle hiding behind the first. Instead of
counting *subsets* of a set, it counts *subspaces* of a space. Pick a field with
$q$ elements — for example the two-element field of bits, or the three-element
field of remainders modulo $3$ — and build an $n$-dimensional vector space over
it. Now ask: how many $k$-dimensional subspaces does it contain? The answer is a
new number, written $\binom{n}{k}_q$ and called the **Gaussian binomial
coefficient**, or *$q$-binomial* for short.

These numbers are the population counts of a beautiful geometric object called
the **Grassmann scheme** $J_q(n,k)$: the universe of all $k$-dimensional
subspaces of an $n$-dimensional space over the field with $q$ elements, organized
by how the subspaces intersect one another. Grassmann schemes are the
"linear-algebra cousins" of the more familiar **Johnson scheme** $J(n,k)$, whose
points are the ordinary $k$-element subsets of an $n$-element set.

This article is about a single, sharp question on these schemes — *when are the
simplest possible functions on them forced to be boring?* — and about the
combinatorial scaffolding needed to even ask it precisely. The scaffolding has
been built and verified down to the last identity; the headline question remains
a frontier conjecture, and we will be honest about exactly where the known world
ends.

## The $q$-analogue: counting with a twist

Let us first see why the $q$-binomial is not just the ordinary binomial in
disguise.

The ordinary binomial $\binom{n}{1}$ — the number of $1$-element subsets of an
$n$-set — is simply $n$. The number of $1$-dimensional subspaces (lines through
the origin) of an $n$-dimensional space over the field with $q$ elements is
something richer:
$$\binom{n}{1}_q = 1 + q + q^2 + \cdots + q^{n-1}.$$
Each nonzero vector spans a line, there are $q^n - 1$ nonzero vectors, and each
line contains $q-1$ of them, so the count is $\tfrac{q^n-1}{q-1}$ — exactly the
geometric series above. When $q = 1$ this collapses back to $\underbrace{1 + 1 +
\cdots + 1}_{n} = n$, the ordinary answer. The parameter $q$ literally
*interpolates* between geometry over a finite field and plain set theory.

The whole $q$-triangle can be built by a recurrence that mirrors Pascal's, but
with a multiplicative twist:
$$\binom{n+1}{k+1}_q = \binom{n}{k}_q + q^{\,k+1}\binom{n}{k+1}_q.$$
Strip away the power of $q$ (set $q=1$) and you recover ordinary Pascal addition.
Restore it, and you are counting subspaces. This recurrence is the cleanest
possible definition because it never divides — it builds the numbers as honest
integers from the ground up. Concretely, over the field with $q=3$ elements the
$2$-dimensional counts $\binom{n}{2}_3$ run
$$0,\ 0,\ 1,\ 13,\ 130,\ 1210,\ 11011,\ \ldots$$
as $n = 0,1,2,3,\ldots$ — numbers that grow far faster than the ordinary
$\binom{n}{2} = 0,0,1,3,6,10,15$.

## Three laws that every subspace-triangle must obey

Before chasing the frontier, one earns trust by proving the structural laws the
new numbers must satisfy. Four of them are central.

**1. The classical limit is exact.** Setting $q=1$ turns every $q$-binomial into
the ordinary binomial:
$$\binom{n}{k}_1 = \binom{n}{k}.$$
This is the precise statement that the Grassmann scheme *degenerates* to the
Johnson scheme as $q \to 1$ — finite-field geometry melts into ordinary
combinatorics. It is the sanity check that the whole construction is faithful: if
this failed, the $q$-machinery would be measuring the wrong thing.

**2. Nonemptiness.** Whenever $k \le n$ (and $q \ge 1$), there really is at least
one $k$-dimensional subspace:
$$\binom{n}{k}_q \ge 1.$$
A scheme with no points would be a ghost; this guarantees the geometry is real.
The hypothesis $q \ge 1$ is genuinely needed — at $q = 0$ the formula can vanish.

**3. The mirror symmetry.** Perhaps the most important identity of all:
$$\binom{n}{k}_q = \binom{n}{\,n-k\,}_q.$$
There are exactly as many $k$-dimensional subspaces as there are
$(n-k)$-dimensional ones. Why? Because every subspace has a well-defined
**orthogonal complement** (or dual), a partner of complementary dimension, and
this pairing is a perfect one-to-one correspondence. At $k=1$ this symmetry says
something vivid: *the number of points (lines) equals the number of hyperplanes.*
This is **point–hyperplane duality**, and it is the geometric heartbeat of
everything that follows.

**4. Strict growth.** For any genuine field ($q \ge 2$), enlarging the ambient
space *strictly* increases the count:
$$\binom{n}{k}_q < \binom{n+1}{k}_q.$$
More room means strictly more subspaces. This is special to $q \ge 2$; at $q=1$
the ordinary binomials can plateau (for instance $\binom{2}{2} = \binom{3}{2}$ is
false — $1 \ne 3$ — but past the central column binomials do stop being strictly
increasing). The "linear" world is strictly more crowded than the "set" world.

In the classical $q=1$ limit, these laws cast familiar shadows that have also
been verified directly: the row is **unimodal**, peaking at its center,
$$\binom{n}{k}_1 \le \binom{n}{\lfloor n/2\rfloor}_1;$$
the counts **grow with the ambient dimension**, $\binom{n}{k}_1 \le
\binom{m}{k}_1$ whenever $n \le m$; and the **total mass** over all dimensions is
$$\sum_{k=0}^{n} \binom{n}{k}_1 = 2^n,$$
the size of the Boolean lattice on $n$ elements. The Grassmann poset, in its
classical limit, is exactly the lattice of all subsets.

## The simplest functions, and when they go boring

Now for the frontier.

On any of these schemes we can ask about **functions** that assign a number to
each point (each $k$-subspace). Among all functions, there is a notion of
*complexity* measured by "degree," much like the degree of a polynomial. The
**degree-one** functions are the simplest non-constant ones — the linear layer of
the scheme's natural Fourier analysis.

A degree-one function is called **trivial** if it is built in the most obvious
way imaginable: a $\{0,1\}$-combination of two elementary families.

- A **point indicator** fixes one specific point $p$ (a $1$-dimensional subspace)
  and lights up every $k$-subspace that contains $p$.
- A **dual indicator** fixes one hyperplane $H$ and lights up every $k$-subspace
  contained in $H$.

These are the "atoms." A trivial function is just a sum of such atoms with
coefficients $0$ or $1$ — a Boolean function with an obvious geometric meaning.
The mirror symmetry $\binom{n}{k}_q = \binom{n}{n-k}_q$ is what makes points and
dual-points interchangeable, so the family of trivial functions is exactly the
**duality-closed span of rank-one indicators**.

The natural question is whether these obvious functions are the *only* simple
Boolean functions. When is every degree-one Boolean function trivial — forced to
be one of these obvious combinations, with nothing exotic possible?

## The threshold conjecture

Here is the headline, stated as sharply as the mathematics allows.

> **Degree-one triviality threshold (conjecture).** For every prime power $q$ and
> integers $k, n$ with $2 \le k \le n/2$, if $n \ge 2k+1$ then *every* Boolean
> degree-one function on the Grassmann scheme $J_q(n,k)$ is trivial.

In words: once the ambient space is **comfortably larger than twice the subspace
dimension**, the only simple Boolean functions are the obvious ones. Exotic
degree-one Boolean functions cannot survive in a roomy space.

What is known? The case $q=2$ (the field of bits) is settled for *all* $k$. The
cases $q \in \{3,4,5\}$ are settled when $k=2$. The conjecture predicts that this
pattern continues uniformly across *every* prime power and every dimension above
the threshold — a single clean law replacing an ever-growing pile of special
cases.

Two structural predictions sharpen the picture, both flowing directly from the
mirror symmetry.

**The threshold is sharp.** Exactly at $n = 2k$ — one step below the threshold —
the symmetry $\binom{2k}{k}_q = \binom{2k}{\,2k-k\,}_q$ says the scheme is its own
mirror image: it is **self-dual**. Self-duality is conjectured to supply one
extra "$\pm 1$" pattern beyond the point/dual atoms — precisely a *non-trivial*
degree-one Boolean function. So the boundary $n = 2k+1$ is not a numerical
accident; it is the first dimension at which self-duality breaks and exotic
functions are squeezed out.

**Growth forces a gap.** The strict-growth law for $q \ge 2$ is conjectured to
upgrade to a *quantitative* statement: a spectral gap in the scheme's natural
operator, of a size depending only on $q$ and not on $n$. Strict crowding is the
visible shadow of an invisible separation between the largest and second-largest
frequencies — and that separation is what ultimately forbids exotic simple
functions.

## Why this matters beyond the page

Association schemes like the Johnson and Grassmann families are not abstractions
for their own sake. They are the geometric engines behind:

- **Error-correcting codes.** Subspace codes — codes whose codewords are
  subspaces rather than strings — power *random linear network coding*, the
  technology that lets information flow robustly through noisy, rerouting
  networks. The points of $J_q(n,k)$ *are* the codewords.
- **Extremal combinatorics.** The "$q$-analogue" program reinterprets classical
  theorems about sets (Erdős–Ko–Rado, sunflower bounds, isoperimetry) as theorems
  about subspaces. Degree-one triviality is the linear-algebraic face of the
  *stability* phenomenon: small Boolean functions must look like the obvious
  extremal examples.
- **Boolean function analysis.** The Fourier-analytic study of $\{0,1\}$-valued
  functions — central to theoretical computer science, learning theory, and
  hardness of approximation — extends from the Boolean cube to these richer
  geometric domains. Triviality theorems are the statement that "low-degree
  Boolean functions are juntas," translated into the language of subspaces.

The threshold conjecture is the statement that *all of this structure is rigid
once you have enough room.* Geometry over a finite field, for all its exotic
flavor, ultimately behaves: in a large enough space the simplest signals are the
obvious ones.

## The state of the art

What has been pinned down with complete certainty is the **counting backbone** —
the Gaussian binomial coefficient built from the division-free $q$-Pascal
recurrence, together with the classical limit, nonemptiness, the geometric-series
point count, the mirror symmetry, point–hyperplane duality, and strict growth in
the ambient dimension. The $q=1$ shadows — unimodality, ambient monotonicity, and
total mass $2^n$ — anchor the new theory to the familiar combinatorics of the
Boolean lattice and confirm that the degeneration to the Johnson scheme is exact.

What remains open is the headline itself: the uniform degree-one triviality
threshold for all prime powers $q \ge 2$. The cases $q=2$ and $(q\le 5, k=2)$ are
known; the rest awaits a single $q$-uniform spectral argument. The symmetry now
identifies the self-dual locus $n = 2k$ as the exact boundary, and the
strict-growth law now lives as one inductive object instead of endless casework —
turning "the threshold is $2k+1$" from a numerical coincidence into a structural
prediction waiting to be proved.

Pascal's triangle took centuries to give up its secrets. Its subspace cousin,
where every entry remembers a finite geometry, is still keeping a few.
