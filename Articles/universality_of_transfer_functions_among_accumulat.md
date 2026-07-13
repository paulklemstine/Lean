# The Democracy of Points: How Every Landmark Can Be Reached From Any Other

## A number line that is all edges and no center

Imagine a number line so finely woven that no matter where you stand on it,
you are surrounded on every side by infinitely many companions, each closer
than the last. There are no isolated outposts, no lonely points hanging in
empty space. Every location is a crowded street corner. Such a set is called
*perfect* — not in the moral sense, but in the precise mathematical one: a set
that contains all of its own accumulation points, and in which every point is
itself an accumulation point.

This article is about a particular family of such sets, and about a surprising
kind of equality that holds among their points. The punchline, stated
informally, is this: **within one of these sets, every point looks exactly like
every other point, and there is a unique, simple motion of the whole line that
carries any chosen point precisely onto any other.** No point is special. The
set is a perfect democracy.

## Building the set: fractions with a favorite denominator

Fix a base $k$ — think of $k = 3$, so we count in powers of three: $1, 3, 9,
27, \dots$ Consider all the fractions you can build whose denominator is a
power of $k$:
$$
\mathbb{Z}[1/k] = \left\{ \frac{a}{k^m} : a \in \mathbb{Z},\ m \in \mathbb{N} \right\}.
$$
These are the *$k$-adic rationals*. For $k = 3$ they include $\tfrac{1}{3}$,
$\tfrac{7}{9}$, $-\tfrac{25}{27}$, every integer, and infinitely many numbers
crowding around every real number you can name.

Now pick a second whole number $\ell$, a "level," with $1 \le \ell < k$, and
scale everything by it:
$$
\Pi^k_\ell = \ell \cdot \mathbb{Z}[1/k]
           = \left\{ \frac{\ell\, a}{k^m} : a \in \mathbb{Z},\ m \in \mathbb{N} \right\}.
$$
This is our star: the **level-$\ell$, base-$k$ set**. For example, with $k = 3$
and $\ell = 2$, the set $\Pi^3_2$ consists of all numbers of the form
$2a/3^m$: values like $\tfrac{2}{3}$, $\tfrac{4}{9}$, $-\tfrac{2}{27}$, and so on.

The scaling factor $\ell$ is not cosmetic. Different levels genuinely give
different sets — $\Pi^3_1$ and $\Pi^3_2$ are honestly distinct as subgroups of
the real line, distinguished by which numbers they contain. The level is a real
label, and it stays with us throughout.

## Two hidden structures

Two facts about $\Pi^k_\ell$ do all the heavy lifting.

**First, it is an additive group.** If you take any two members and subtract
one from the other, you land back inside the set. Concretely, if $x = \ell
a/k^m$ and $y = \ell b/k^n$, then putting them over the common denominator
$k^{m+n}$ shows
$$
x - y = \frac{\ell\,(a\,k^n - b\,k^m)}{k^{m+n}} \in \Pi^k_\ell.
$$
Since $0 = \ell \cdot 0 / k^0$ is present and subtraction stays inside, addition
does too. So $\Pi^k_\ell$ is closed under the arithmetic of translation: shifting
any member by another member never leaves the set. It even has a self-similar
scaling symmetry, because multiplying any member by $k$ again lands inside the
set.

**Second, it is dense.** Between any two real numbers, no matter how close,
there is a member of $\Pi^k_\ell$. The reason is intuitive: the "grid spacing"
of the numbers $\ell a / k^m$ for a fixed exponent $m$ is $\ell/k^m$, and by
taking $m$ large this spacing shrinks below any tolerance you choose, since
$k \ge 2$ forces $k^m \to \infty$. To approximate a target $x$ to within a
tolerance $\varepsilon$, choose $m$ with $\ell/k^m < \varepsilon$ and snap $x$
to the nearest grid point $\ell \lfloor x k^m / \ell \rfloor / k^m$. The error is
less than one grid step, hence less than $\varepsilon$.

Density plus the group structure yields the headline property.

## Perfection: everywhere is a crowd

Here is the first main result.

> **Perfectness Theorem.** For every base $k \ge 2$ and level $\ell \ge 1$,
> every real number is an accumulation point of $\Pi^k_\ell$. In particular,
> every point of $\Pi^k_\ell$ is an accumulation point of $\Pi^k_\ell$.

An *accumulation point* of a set is a location with members of the set
arbitrarily close to it (but distinct from it). Because $\Pi^k_\ell$ is dense,
every real number $x$ has members of the set arbitrarily nearby; and because
the set is infinite and dense, you can always find such neighbors different from
$x$ itself. So no point of $\Pi^k_\ell$ is isolated. The set is *dense-in-itself*,
and being a subgroup it has no isolated points anywhere — the very definition of
a perfect crowd.

The immediate consequence is a clean identification: **the accumulation points
that lie inside $\Pi^k_\ell$ are exactly the points of $\Pi^k_\ell$.** There is
no distinction to draw between "ordinary" members and "limit" members. Every
member is a limit of others.

## Transfer functions: the simplest possible motions

Now we introduce the motions that will shuffle the set. A **transfer function**
is a translation of the whole real line by a member of the set:
$$
f(x) = x + c, \qquad c \in \Pi^k_\ell.
$$
Nothing exotic — just a rigid slide. But these slides are perfectly matched to
the set, and they form a tidy algebraic system:

- **They preserve the set.** If $x \in \Pi^k_\ell$ and $c \in \Pi^k_\ell$, then
  $x + c \in \Pi^k_\ell$, because the set is closed under addition. A transfer
  function maps $\Pi^k_\ell$ into itself.
- **The identity is one of them** (slide by $c = 0$).
- **They compose.** Sliding by $c$ and then by $d$ is sliding by $c + d$, again
  a member of the set. So transfer functions are closed under composition and
  form a monoid.
- **They are continuous** — each is just $x \mapsto x + c$.

These are the "allowed rearrangements" of the number line that respect
$\Pi^k_\ell$. The question is how much they can accomplish.

## The universality theorem: reach anything from anything

> **Universality Theorem.** For any base $k \ge 3$, any level $\ell$ with
> $1 \le \ell < k$, and any two points $\alpha, \beta \in \Pi^k_\ell$, both are
> accumulation points of the set, and there exists a transfer function $f$,
> mapping $\Pi^k_\ell$ into itself, with
> $$ f(\alpha) = \beta. $$

The proof is disarmingly short once the groundwork is laid. The difference
$c = \beta - \alpha$ is itself a member of $\Pi^k_\ell$, because the set is
closed under subtraction. Then the single translation $f(x) = x + (\beta -
\alpha)$ does the job: it sends $\alpha$ to $\alpha + (\beta - \alpha) = \beta$,
it preserves the set, and it is continuous. That is universality: *any* landmark
can be carried onto *any* other by an allowed motion.

The analytic engine here — density and hence perfectness — only needs $k \ge 2$
and $\ell \ge 1$. The stronger bounds $k \ge 3$ and $\ell < k$ are the range in
which the question was originally posed, and we keep them faithfully even though
the mechanism does not strictly require the upper bound on $\ell$.

## Uniqueness: not just reachable, but reachable in exactly one way

Universality says at least one transfer function connects any two points. The
companion result says there is never more than one.

> **Simple Transitivity Theorem.** If two transfer functions agree at even a
> single point, they are identical. Consequently, the transfer function carrying
> $\alpha$ to $\beta$ is unique.

Why? A transfer function is completely determined by its shift $c$, and if
$x + c = x + d$ at one point $x$, then $c = d$, so the functions coincide
everywhere. Combined with universality, this says the transfer functions act
*simply transitively* on the set: given a source and a target, exactly one
motion links them. The bookkeeping of "which motion" is nothing more than the
bookkeeping of "which shift," and the shift is forced to be $\beta - \alpha$.

There is a pleasing structural way to see the whole picture. The transfer
functions, under composition, form a group; and this group is a faithful mirror
of the additive group $(\Pi^k_\ell, +)$ itself — composing slides corresponds to
adding shifts. The set acts on itself by translation, and it does so as
perfectly and rigidly as a group can act: freely and transitively. The points
of $\Pi^k_\ell$ are, quite literally, interchangeable.

## Why this matters

At first glance this may look like a story about one specific gadget. But it is
really a template, and templates are where mathematics earns its keep.

**A model of homogeneity.** Many objects in geometry and analysis are prized
for being *homogeneous* — looking the same at every point. Spheres, tori, and
Euclidean space all have symmetry groups that move any point to any other. Our
set is a discrete, self-similar, measure-zero cousin of these homogeneous
spaces: a dust-like set of measure zero that nonetheless has a symmetry group
rich enough to be point-transitive. It shows how much homogeneity can survive
even after almost all of the line has been thrown away.

**A prototype for jump phenomena.** Sets built from $k$-adic scaling arithmetic
appear across mathematics wherever a quantity can be subdivided by a fixed
factor: in the analysis of self-similar fractals, in dynamical systems with
expanding maps $x \mapsto kx$, and in combinatorics, where families of
achievable "densities" cluster and accumulate. Understanding when a set of
achievable values is perfect — all accumulation, no isolated jumps — and when a
simple family of operations can move freely among those values is a recurring
and important question. The clean result here is a laboratory example of exactly
that phenomenon: a perfect value set on which a transparent semigroup of
operations acts with full reach.

**A generalizable argument.** The proof used almost nothing specific to powers
of $k$. What it truly needed was a dense additive subgroup of a space without
isolated points. Any such group is perfect, and its own translations act simply
transitively on it. The $k$-adic set is just the most concrete and computable
member of a whole species of self-symmetric sets. In this sense the theorem is
less a fact about one set than a recipe: **wherever you find a dense additive
group inside a continuum, you find a perfect crowd on which the simplest motions
already achieve everything.**

## The moral

Strip a set of structure down far enough and you might expect its points to
become distinguishable — some central, some peripheral. The lesson of
$\Pi^k_\ell$ is the opposite. Even a threadbare, measure-zero scatter of
fractions can be so uniformly woven that no point is more special than another,
and the humblest possible motions — plain translations — suffice to carry any
point exactly onto any other, in one and only one way. Universality, it turns
out, does not require complexity. Sometimes a little arithmetic and a lot of
density are all it takes.
