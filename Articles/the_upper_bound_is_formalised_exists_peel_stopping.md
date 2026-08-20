# Peeling an Onion, Perfectly

## What the humblest counting argument knows about the shape of space

There is a trick so simple that it barely deserves a name, and yet it appears
in nearly every corner of geometry, combinatorics and analysis. It goes like
this. You have a pile of stuff — a set, a body, a graph, a measure — and you
remove it in $N$ successive layers. If the total amount you removed is $A$,
then **at least one of those layers weighed no more than $A/N$**. You cannot
have $N$ layers all strictly heavier than the average; the arithmetic forbids
it.

That is the whole argument. It is the pigeonhole principle wearing a geometric
hat. Mathematicians reach for it constantly: to find a thin slab in a
decomposition, a cheap step in an algorithm, a sparse level in a filtration.
It is the workhorse that lets you say *"choose a good place to cut"* without
knowing anything about what you are cutting.

But a workhorse of that kind raises an uncomfortable question. The inequality
says a good cut exists. It never says how good — and it never says whether the
bound $A/N$ is the honest truth or a lazy overestimate. **When is the
inequality actually an equality?** And if it can be an equality, what do the
objects that achieve it look like?

This article is about the answer, which turns out to be far more structured
than the crude counting argument has any right to produce. In one sentence:
**the bound is saturated exactly by the perfectly symmetric peelings, and in
Euclidean space these are exactly the equal-volume dilation peelings of an
arbitrary star-shaped body.** Counting, symmetry, and geometry turn out to be
three descriptions of the same thing.

---

## The skeleton: a peeling profile

Strip away the geometry and what remains is a single sequence of numbers.

> **Definition (peeling profile).** A *peeling profile* is a sequence
> $s_0, s_1, s_2, \dots$ of real numbers that is nonincreasing
> ($s_{k+1} \le s_k$) and nonnegative ($s_k \ge 0$). Think of $s_k$ as the
> amount of material still left after $k$ layers have been peeled away.

From the profile we read off three derived quantities. The **layer content**
of step $k$ is what that step removed,
$$g_k \;=\; s_k - s_{k+1} \;\ge\; 0 .$$
Over a window of the first $N$ steps, the **budget** is the total removed,
$$A_N \;=\; s_0 - s_N \;=\; g_0 + g_1 + \cdots + g_{N-1},$$
and the **rate** is the average layer,
$$\rho_N \;=\; A_N / N .$$
The telescoping identity $\sum_{k<N} g_k = A_N$ is the only fact we need, and
it is free.

> **Theorem (existence of a good stopping time).** For every peeling profile
> and every $N \ge 1$ there is a step $k < N$ with $g_k \le \rho_N$.

*Proof.* If every one of the $N$ layers exceeded the average, their sum would
exceed $N\rho_N = A_N$, contradicting the telescoping identity. $\square$

It really is that short. Everything interesting comes afterwards.

---

## The straight line, and how far you can stray from it

The stopping-time theorem finds one good step. A more useful question is: how
does the whole profile behave over the window? The naive guess is that it
decays linearly, that after $k$ steps you have removed roughly $k\rho_N$:
$$\ell_k \;=\; s_0 - k\rho_N .$$
Call this the **linear estimate**. It is exact at both ends, $\ell_0 = s_0$
and $\ell_N = s_N$, and the error in between has a clean description. Since
$$s_k - \ell_k \;=\; \sum_{j<k} (\rho_N - g_j),$$
the deviation from the straight line is precisely the accumulated shortfall of
the layers relative to the average. Because each $g_j \ge 0$, and because the
total shortfall over the whole window is zero, we get a two-sided bound with
no hypotheses whatsoever:

> **Theorem (error of the linear estimate).** For $0 \le k \le N$,
> $$|s_k - \ell_k| \;\le\; \max(k,\; N-k)\cdot \rho_N ,$$
> and in particular $|s_k - \ell_k| \le A_N$: the linear estimate never errs
> by more than the entire budget.

The two halves of this bound come from reading the error forwards (over
$j < k$) and backwards (over $k \le j < N$), and taking whichever window is
shorter. There is no averaging magic — just the same telescoping identity,
used twice.

Good stopping times are also *plentiful*, not merely present. If $S$ is the
set of steps whose layer weighs at least $t$, then $|S| \cdot t \le A_N$,
since those heavy layers alone already use up $|S|t$ of the budget. Rescaling,
**at most $N/c$ of the $N$ steps can have a layer exceeding $c$ times the
average.** A random step is almost always a good stopping time.

One refinement is what one actually uses in practice. Break the window of
$N = JM$ steps into $M$ blocks of length $J$ and apply the stopping-time
theorem to the coarser profile that only looks every $J$ steps. Some block
removes at most $A_N/M$ of the budget — and therefore *every layer inside that
block* is that small. You get not one good step but a **stable window** of $J$
consecutive good steps.

---

## Rigidity: equality forces perfection

Now the main event. Suppose you have a peeling in which the bound is not just
attained once but everywhere: *every* layer in the window is at most average.
Intuitively this ought to be very restrictive — you cannot have all the numbers
below average unless they are all exactly average. That intuition is correct,
and the consequences ripple outwards.

> **Theorem (rigidity of the peeling bound).** For a peeling profile and
> $N \ge 1$, the following four statements are equivalent.
> 1. $g_k \le \rho_N$ for every $k < N$ — every layer is at most average.
> 2. $g_k = \rho_N$ for every $k < N$ — every layer is exactly average.
> 3. $s_k = s_0 - k\rho_N$ for every $k \le N$ — the profile is exactly the
>    straight line.
> 4. $g_k = g_{(k+1) \bmod N}$ for every $k < N$ — the layer contents are
>    invariant under the cyclic shift of the window.

*Why.* (1) $\Rightarrow$ (2): the numbers $\rho_N - g_k$ are all $\ge 0$ and
sum to zero, so all vanish. (2) $\Rightarrow$ (3) is induction. (3)
$\Rightarrow$ (1) is differentiation of a linear function. (2) $\Rightarrow$
(4) is trivial, and (4) $\Rightarrow$ (2) is the observation that cyclic
invariance makes the gap function constant, and a constant with the right sum
must equal the average.

The fourth clause is the surprise. It converts an *inequality* into a
*symmetry*. Being extremal is the same as having a cyclic symmetry acting on
your layers. And the cyclic group is not special:

> **Theorem (symmetry forces extremality).** Suppose some group $G$ acts on
> the $N$ steps of the window *pretransitively* — for any two steps there is a
> group element carrying one to the other — and suppose the layer contents are
> invariant, $g_{\sigma(k)} = g_k$ for all $\sigma \in G$. Then every layer is
> exactly the average, and the profile is exactly linear.

The proof is one line: transitivity makes $g$ constant, and a constant summing
to $A_N$ over $N$ terms is $A_N/N$. But the statement is a genuine dictionary
entry. It says the extremisers of a counting bound are the objects with a
transitive symmetry on their layers, and it says that a *single $N$-cycle*
already extracts as much information as the full symmetric group of the
window. Indeed, saturation is *equivalent* to invariance under the full
symmetric group on the window — symmetry is not merely sufficient for
extremality, it is a characterisation of it.

---

## What if you are only nearly extremal?

Rigidity is a brittle statement: it says exact equality forces exact
structure, and says nothing about near-equality. In applications you almost
never have exact equality. The right upgrade is a stability theorem, and here
it is, with a linear and dimension-free constant.

> **Theorem (stability).** Let $\varepsilon \ge 0$ and suppose every layer of
> the window satisfies $g_k \le (1 + \varepsilon)\rho_N$. Then for every
> $k \le N$,
> $$|s_k - \ell_k| \;\le\; \varepsilon \, A_N .$$

At $\varepsilon = 0$ this recovers rigidity exactly. For small $\varepsilon$
it says an approximate extremiser is uniformly close to the straight line, with
an error proportional to $\varepsilon$ and to the budget, and with no
dependence on $N$. Approximate symmetry buys approximate structure.

There is also a variational way to see all of this, which some readers will
find the most satisfying. Define the **layer energy** of the window as
$E = \sum_{k<N} g_k^2$. Completing the square gives an exact identity:
$$E \;-\; \frac{A_N^2}{N} \;=\; \sum_{k<N} \left(g_k - \frac{A_N}{N}\right)^{\!2}.$$
The right-hand side is a sum of squares, so $E \ge A_N^2/N$ always — that is
Cauchy–Schwarz, obtained here without invoking it — and equality holds exactly
when every $g_k$ equals the average. So the extremisers of the counting bound
are *also* the minimisers of the layer energy, and the excess energy is
literally the variance of the layer distribution. Rigidity, symmetry and
energy minimality are three faces of one fact.

(Dually and for free: every window also contains a step whose layer is at
*least* average. So $\min_k g_k \le \rho_N \le \max_k g_k$, with double
equality precisely in the extremal case.)

---

## Where the geometry enters: peeling a ball

So far this is arithmetic. The question a geometer asks is whether the
extremisers exist in nature — whether there is an actual family of shapes
whose peeling saturates the bound at every step. There is, and it is one you
have already imagined.

Take the ball $B(0,R)$ in $\mathbb{R}^d$ and slice it into $N$ concentric
shells of *equal volume*. What are the radii? Since a ball of radius $r$ has
volume proportional to $r^d$, the ball whose volume is a fraction $1 - k/N$ of
the whole has radius
$$r_k \;=\; R\left(1 - \frac{k}{N}\right)^{1/d}.$$
These radii are emphatically **not** in arithmetic progression; only their
$d$-th powers are. In the plane with $R = 1$ and $N = 4$ the radii are
$$1,\quad \tfrac{\sqrt3}{2} \approx 0.866,\quad \tfrac{\sqrt2}{2} \approx 0.707,
\quad \tfrac12, \quad 0,$$
and each of the four annuli has area exactly $\pi/4$.

Two things are now true of this family, and together they answer the original
question.

> **Theorem (the shell peeling is extremal, and is $O(d)$-equivariant).** For
> every $d \ge 1$, every $R \ge 0$ and every $N \ge 1$, the concentric shells
> of radii $R(1-k/N)^{1/d}$ decompose $B(0,R)$ into $N$ pieces of equal volume
> $\mathrm{vol}\,B(0,R)/N$. Every one of these shells is carried to itself by
> every linear isometry of $\mathbb{R}^d$, so the orthogonal group $O(d)$ acts
> on the decomposition, permuting nothing and preserving everything. The
> resulting peeling profile is exactly linear: the pigeonhole bound is
> saturated at every single step.

> **Theorem (rigidity for ball peelings).** Conversely, let
> $r_0 \ge r_1 \ge \cdots \ge r_N$ be *any* nested family of radii with
> $r_0 = R$ and $r_N = 0$, such that every shell has volume **at most**
> $\mathrm{vol}\,B(0,R)/N$. Then necessarily $r_k = R(1-k/N)^{1/d}$ for all
> $k$. There is no other way to do it.

And the constant $1$ in the stopping-time bound cannot be improved even for
this most classical of examples: for any $c < 1$, the equal-volume shell
family has *every* shell strictly heavier than $c$ times the average, so no
estimate with a better constant can hold.

---

## A surprise in high dimensions: the shells collapse to the skin

Here the arithmetic and the geometry part company in an instructive way. The
abstract profile of the shell peeling is a perfectly uniform staircase: every
shell has the same volume. The *geometry* of those shells is anything but
uniform.

Consider the outermost shell, between radius $R$ and radius $R(1-1/N)^{1/d}$.
It carries a $1/N$ fraction of the volume — a substantial chunk. How thick is
it?

> **Theorem (boundary concentration).** For $d \ge 1$ and $N \ge 2$, the
> thickness of the outermost equal-volume shell of $B(0,R) \subseteq
> \mathbb{R}^d$ satisfies
> $$R - R\left(1 - \tfrac1N\right)^{1/d} \;\le\; \frac{R}{d\,(N-1)} .$$

The thickness decays like $1/d$. In $\mathbb{R}^{100}$, cutting a unit ball in
half by volume puts the dividing sphere at radius $2^{-1/100} \approx 0.9931$:
**half the volume of a hundred-dimensional ball lies in an outer skin of
thickness less than seven thousandths of the radius.** (The bound above gives
$0.01$ here, so it is right to within about 30% and has exactly the correct
$1/d$ decay.)

The proof is a one-line factorisation. Writing $s = (1-1/N)^{1/d}$, we have
$1 - s^d = (1-s)(1 + s + \cdots + s^{d-1}) \ge (1-s)\, d\, s^{d-1}$, because
each term of the geometric sum is at least the last; rearranging gives the
bound. The factorisation is two-sided — bounding the sum above by $d$ instead
gives a matching lower bound — so the $1/d$ order is the truth, not an
artefact.

This is the familiar concentration-of-measure phenomenon, arrived at from a
counting argument about peelings. It also explains why ball peelings *feel*
so different from the flat arithmetic staircase they realise: the volumes are
equal, but the shells are being crushed against the boundary sphere.

---

## The punchline: the ball was never the point

At this stage a sceptic has an obvious complaint. The ball is the most
symmetric body in existence. Of course it produces a perfectly symmetric
peeling — that is what "ball" means. Have we learned anything about geometry,
or only about spheres?

The answer is that **the construction never used the ball at all.** Let $K$
be *any* star-shaped body about the origin in $\mathbb{R}^d$ of finite volume:
star-shaped meaning that if $x \in K$ then $tx \in K$ for every
$0 \le t \le 1$, so that $K$ can be seen in full from the origin. No
convexity, no smoothness, no symmetry. Consider the shrunken copies
$$c_k K, \qquad c_k = \left(1 - \frac{k}{N}\right)^{1/d},$$
and let the $k$-th layer be the region $c_k K \setminus c_{k+1} K$ between two
consecutive copies.

> **Theorem (the universal matching family).** For every dimension $d \ge 1$,
> every $N \ge 1$ and every measurable star-shaped body $K \subseteq
> \mathbb{R}^d$ of finite volume:
> 1. **Equal volumes.** Each of the $N$ layers has volume exactly
>    $\mathrm{vol}(K)/N$, so the peeling profile is exactly linear and the
>    pigeonhole bound is saturated at every step.
> 2. **Full equivariance.** Every linear isometry of $\mathbb{R}^d$ that maps
>    $K$ to itself maps each layer to itself. The entire linear symmetry group
>    of $K$ — whatever it happens to be — acts on the decomposition.
> 3. **Rigidity.** Conversely, if $c_0 = 1 \ge c_1 \ge \cdots \ge c_N = 0$ is
>    any decreasing family of dilation factors all of whose layers have volume
>    at most $\mathrm{vol}(K)/N$, then $c_k = (1-k/N)^{1/d}$ for every $k$.

Two features of this deserve to be said aloud.

**The dilation factors do not depend on $K$.** They depend only on the
dimension $d$ and the number of layers $N$. Peel a disc into four equal parts
and peel a square into four equal parts, and you use *the same numbers*
$1, \sqrt3/2, \sqrt2/2, 1/2, 0$. The square $[-1,1]^2$ has area $4$; its four
dilation layers each have area exactly $1$; the intermediate boundaries are
squares of half-diagonals $\sqrt3/2$, $\sqrt2/2$ and $1/2$. The dimension
fixes the radial profile; the body is otherwise entirely free.

**The symmetry group comes along for the ride.** For $K$ a ball the symmetry
group is all of $O(d)$ and one recovers the shell peeling. For $K$ a square it
is the dihedral group of order $8$. For $K$ a generic blob it may be trivial —
and the peeling is *still* extremal, because extremality was never about the
symmetry of the body. It was about the transitive symmetry of the *window of
steps*, which the equal-volume construction supplies automatically.

So the final classification of the extremisers reads: they are parameterised
by all pairs $(K, G)$ with $K$ a star-shaped body and $G$ any group of linear
symmetries of $K$. The counting bound, which knows nothing about geometry, has
a geometric answer that spans every shape there is.

Finally, the variational picture transfers verbatim: among all nested ball
peelings of $B(0,R)$ shrinking to a point in $N$ steps, the equal-volume
shells are the unique minimisers of the sum of squared shell volumes, the
minimum value being $\mathrm{vol}(B(0,R))^2 / N$. Equal cuts are the
lowest-energy cuts.

---

## Why this matters

The pigeonhole peeling bound is a tool people use without thinking. What the
picture above supplies is the *knowledge of when the tool is tight*, and that
turns out to be operationally useful in at least three ways.

**You know when to stop looking.** If your peeling has decreasing layer
contents — a very common situation, since most natural processes peel their
heaviest layers first — then the last step of the window is *always* an
admissible stopping time and the first step *never* is. The existential search
in the theorem is only needed for genuinely oscillating peelings. That is a
free algorithmic shortcut.

**You know how much slack you have.** Stability says that if your peeling is
within a factor $1+\varepsilon$ of the bound at every step, its whole profile
is within $\varepsilon A_N$ of a straight line. Failure of extremality is
*measurable*, and what measures it is the variance of the layer contents.

**You know what the extremal objects look like.** In adaptive mesh generation,
in volume-balanced spatial partitioning, in any setting where one wants to
carve a region into equal-mass pieces with as much symmetry as possible, the
answer is the dilation family with radial profile $(1-k/N)^{1/d}$, and there
is no other answer.

There is also something satisfying in the chain of implications. A statement
about integers ("not all $N$ numbers can beat their average") forces a
statement about symmetry, which forces a statement about geometry, which
forces a statement about high dimensions. Each step is elementary; the
composite is not obvious at all.

The onion, it turns out, has only one way to be peeled perfectly — and it
doesn't care what shape the onion is.
