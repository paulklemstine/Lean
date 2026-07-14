# The Machine That Climbs Dimensions: How One Point Builds Every Sphere

## A ham sandwich, an impossible retreat, and a staircase of spheres

Imagine you are standing anywhere on the surface of the Earth. There is, at
this very instant, a point on the exact opposite side of the planet — your
*antipode*. Temperature and barometric pressure vary continuously across the
globe, and a classical theorem guarantees something startling: there is always
at least one pair of antipodal points where **both** the temperature *and* the
pressure are identical. No matter how the weather churns, you cannot escape this
coincidence.

This is a shadow of one of the most quietly powerful results in mathematics: the
**Borsuk–Ulam theorem**. In its cleanest form it says that you cannot
continuously flatten a higher-dimensional sphere onto a lower-dimensional one
while respecting antipodes. There is no antipode-preserving map from the
$(n{+}1)$-sphere down to the $n$-sphere. The dimensions form a one-way staircase:
you can always climb up, but you can never climb down.

This article is about turning that staircase into a *machine*. We will build an
operation — the **suspension** — that takes any antipode-respecting map and
produces a new one, one dimension higher. We will show this operation behaves so
regularly that it deserves to be called a *functor*: a structure-preserving
transformation of an entire mathematical universe. And we will show that the
whole infinite tower of spheres, together with its sharpest quantitative
content, unfolds from a single, almost embarrassingly simple starting point: a
map from a two-point space to itself.

## Spheres you can count on your fingers

To make everything concrete — concrete enough to compute by hand or by machine —
we replace the smooth, curvy sphere with a crisp combinatorial skeleton.

The **combinatorial $n$-sphere** $S^n$ is built from just $2(n{+}1)$ vertices,
which we label by a coordinate index $i \in \{0, 1, \dots, n\}$ and a sign
$b \in \{+, -\}$. Think of these as the tips of the axes in
$(n{+}1)$-dimensional space: the points $\pm e_0, \pm e_1, \dots, \pm e_n$. So
$S^0$ is two points $\{+e_0, -e_0\}$; $S^1$ is the four "corners"
$\{\pm e_0, \pm e_1\}$ forming a diamond; $S^2$ is the six vertices of an
octahedron. This is the boundary of the *cross-polytope*, and topologically it
is a genuine sphere — just assembled from finitely many flat pieces.

The all-important extra structure is the **antipodal map** $\nu$, which flips the
sign: $\nu(i, +) = (i, -)$. Every vertex has a unique antipode, and $\nu$ never
fixes anything. A space carrying such a fixed-point-free involution is called a
**free $\mathbb{Z}_2$-space** — "$\mathbb{Z}_2$" because applying the flip twice
returns you to the start.

The maps we care about must honor this symmetry. A **$\mathbb{Z}_2$-map**
$F : S^m \to S^n$ is a rule sending vertices to vertices that is:

- **Equivariant** — it commutes with the flip: $F(\nu x) = \nu(F(x))$. Antipodes
  go to antipodes.
- **Simplicial** — it never tears the sphere: whenever two vertices $x, y$ are
  *not* antipodal (so they lie on a common face), their images $F(x)$ and $F(y)$
  are not antipodal either. Faces map to faces.

These two conditions are exactly the finite, checkable fingerprints of a
continuous antipode-preserving map. Everything that follows lives in this
hands-on world where a "map between spheres" is a finite table of values you
could write on an index card.

## Coindex: how tall a sphere can you fit inside?

Here is the single number this whole story is about. The **$\mathbb{Z}_2$-coindex**
of a space $X$ measures how large a sphere you can map *into* it while respecting
antipodes:
$$\operatorname{coind}(X) = \max\{\, m : \text{there exists a } \mathbb{Z}_2\text{-map } S^m \to X \,\}.$$

For the sphere itself, the answer is exactly what your intuition demands:
$$\operatorname{coind}(S^n) = n.$$

This clean equality has two halves, and they could not be more different in
character.

**The lower bound, $\operatorname{coind}(S^n) \ge n$, is constructive.** To prove
it you simply *exhibit* a map $S^n \to S^n$ — and the identity map, sending every
vertex to itself, does the job. Easy.

**The upper bound, $\operatorname{coind}(S^n) < n+1$, is an obstruction.** It says
there is *no* $\mathbb{Z}_2$-map $S^{n+1} \to S^n$ whatsoever. This is precisely
the combinatorial Borsuk–Ulam theorem: the impossible retreat down the staircase.

The gap between these two halves — "here is a witness" versus "no witness can
exist" — is the tension that animates the subject. The lower bound is a matter of
building; the upper bound is a matter of proving that all attempts must fail.

## The suspension: a machine for climbing

Now for the engine. Given a $\mathbb{Z}_2$-map $F : S^m \to S^n$, its
**suspension** $\Sigma F : S^{m+1} \to S^{n+1}$ is built by a single vivid idea.
Picture the $(m{+}1)$-sphere as the original $m$-sphere sitting around the
"equator", with two brand-new poles — a north $(+)$ and a south $(-)$ — added
along a fresh axis. Then:

- **The poles are pinned.** $\Sigma F$ sends the new north pole to the new north
  pole and the new south pole to the new south pole. The extra dimension is
  carried straight up, untouched.
- **The equator is transported by $F$.** On every old vertex, $\Sigma F$ simply
  does what $F$ did (reinterpreted one dimension up).

Geometrically, you are taking the map $F$ and "coning it off" at both ends,
stretching an $m$-dimensional picture into an $(m{+}1)$-dimensional one by pulling
its two suspension points apart. This mirrors exactly how the smooth suspension
of spaces works — but here it is a finite operation on finite tables.

The immediate payoff: suspension turns any coindex witness into a taller one. If
there is a map $S^m \to S^n$, then there is a map $S^{m+1} \to S^{n+1}$. Climbing
is automatic.

## From a construction to a functor

The heart of this work is the realization that suspension is not just a one-off
trick applied to individual maps — it is a *uniform, structure-preserving*
operation on the entire universe of spheres and their maps. In mathematical
language, it is a **functor**. Making that precise requires proving three things.

First, a foundational fact that makes the whole theory tractable:

> **Extensionality.** Two $\mathbb{Z}_2$-maps are equal precisely when their
> underlying vertex tables agree. Because "equivariant" and "simplicial" are
> yes/no properties rather than extra data, a map carries no hidden information
> beyond where it sends each vertex.

This sounds like bookkeeping, but it is the key that unlocks everything: to prove
two maps are the *same map*, you only need to check they agree vertex by vertex.

With extensionality in hand, the two functor laws fall out by a clean case split
— pole versus equator — that literally retraces the geometry of suspension:

> **Suspension preserves identities.** Suspending the identity map of $S^n$ gives
> exactly the identity map of $S^{n+1}$:
> $$\Sigma(\mathrm{id}_{S^n}) = \mathrm{id}_{S^{n+1}}.$$

> **Suspension preserves composition.** Suspending a composite of two maps is the
> composite of their suspensions:
> $$\Sigma(G \circ F) = \Sigma G \circ \Sigma F.$$

Together these say $\Sigma$ is a genuine endofunctor of the category of free
$\mathbb{Z}_2$-spheres: it respects the two things that define composition of
maps — doing nothing, and doing one thing after another.

## One point to rule them all

Once suspension is a functor, we can crank it repeatedly. The **$k$-fold
suspension** $\Sigma^k$ sends a map $S^m \to S^n$ to a map
$S^{m+k} \to S^{n+k}$, and it inherits the same laws: it preserves identities and
composition too.

This yields the article's most striking image. Start with the humblest possible
object: the identity map of $S^0$, a map between two-point spaces — essentially a
single point of data. Apply the suspension machine $n$ times. What comes out?

> **The whole tower is one point, suspended.** The $n$-fold suspension of the
> identity map of $S^0$ is exactly the identity map of $S^n$:
> $$\Sigma^n(\mathrm{id}_{S^0}) = \mathrm{id}_{S^n}.$$

Every rung of the infinite ladder of lower bounds
$\operatorname{coind}(S^n) \ge n$ — the identity witness at each level — is the
orbit of a *single* base map under the suspension functor. The constructive lower
bound is not an infinite list of separate constructions; it is one construction,
iterated. The staircase is generated by turning a crank.

## Pinning the excess to exactly one

The functor tells us each suspension raises the coindex by *at least* one. But
does it raise it by *exactly* one? That is the sharpness question, and it needs
the other, harder half: the obstructions.

Each obstruction is a statement of the form "there is no $\mathbb{Z}_2$-map
$S^{n+1} \to S^n$." Crucially, in our finite model this is a **decidable** claim.
Because a map is determined by its values on the finitely many positive vertices,
and each value has finitely many choices, one can in principle *check every
candidate* and confirm that all of them fail either equivariance or
simpliciality. Borsuk–Ulam, in each fixed dimension, becomes a finite search.

Running that search establishes the obstructions at the bottom of the tower:

- There is no $\mathbb{Z}_2$-map $S^1 \to S^0$.
- There is no $\mathbb{Z}_2$-map $S^2 \to S^1$.
- There is no $\mathbb{Z}_2$-map $S^3 \to S^2$ — the newest rung, pushing the
  verified reach of sharpness up to $\operatorname{coind}(S^2) = 2$.

Pairing each constructive witness with the matching obstruction one dimension up
gives the sharp result along the base of the tower:

> **Sharp excess up to $S^2$.** At each level $0, 1, 2$ there is a coindex witness
> of exactly the expected dimension (an identity map), while no witness of the
> next dimension exists. Hence each suspension $S^0 \rightsquigarrow S^1
> \rightsquigarrow S^2$ raises the coindex by *exactly one*.

The two forces meet: the suspension functor pushes the coindex *up* by at least
one, and the finite Borsuk–Ulam obstructions forbid it from going up by *more*
than one. The excess of the functor is pinned, precisely, to $1$.

## Why this way of seeing it matters

There is a real conceptual gain here, not just a repackaging. Classically, the
lower bound $\operatorname{coind}(S^n) \ge n$ is proved case by case, or by an
appeal to abstract topology. Recasting it as *the orbit of a single map under a
functor* turns a family of facts into one structural phenomenon. It tells you
*why* the bound holds uniformly across all dimensions: because there is a machine
that manufactures the next witness from the current one, forever, and it all
traces back to a single seed.

This viewpoint also charts the road ahead. If suspension is "coning off a map,"
then the more general **join** operation — gluing two spheres together to form
$S^m * S^n \cong S^{m+n+1}$ — ought to be a *two-input* functor whose effect on
the coindex is *additive*. Suspension would then be revealed as the special case
of joining with $S^0$, and its mysterious "$+1$" would simply be the coindex of a
single point, $\operatorname{coind}(S^0) + 1$. And the obstructions, currently
verified rung by rung, invite an inductive argument that transports each
"no map exists" upward — running the suspension machine *in reverse* to prove
that the excess is exactly one in *every* dimension, not just the first few.

## The takeaway

Borsuk–Ulam is usually told as a tale of impossibility: you cannot retreat down
the staircase of dimensions. This work tells the complementary tale of
*possibility and structure*: there is a machine that climbs the staircase, it
climbs it in perfect lockstep with the rules of composition, the entire ascent is
powered by a single point, and finite searches confirm that every step rises by
exactly one. A theorem about what *cannot* happen has been recast as a theorem
about a beautiful, regular process that *does*.
