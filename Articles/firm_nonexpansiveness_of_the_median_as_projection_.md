# The Median Is a Projection

## How a humble tie-breaker turns out to obey the Pythagorean theorem

### Three engineers, three numbers

Suppose you are tuning a machine and you need one number: the *knee* — the point where
pushing harder stops paying off. Maybe it is the batch size beyond which a training run
stops speeding up; maybe it is the load at which a server's latency curve bends upward;
maybe it is the dose at which a drug's benefit plateaus. You do not trust a single
measurement, so you run the experiment three times and get three candidate knees, say

$$256, \qquad 224, \qquad 160.$$

What number do you report?

Almost nobody reports the average. Everybody reports the **median**: the middle value,
$224$. The reason is folklore that every practitioner knows — one bad run cannot drag the
median very far, whereas one bad run drags the mean wherever it likes. If one of your three
seeds crashes and reports $10^6$, the mean explodes, but the median calmly moves to the
larger of the two survivors and stops there.

That folklore is a *qualitative* statement: the median stays inside the bracket spanned by
the clean measurements. It says nothing about the question an engineer actually asks:

> If one seed drifts by a little — by $\delta$ — how far does my reported answer drift?

The answer turns out to be far more structured than "at most $\delta$". The median obeys an
exact **Pythagorean budget**, and the reason is that the median is not really a
tie-breaking gadget at all. It is a *projection*: the operation of snapping a point onto the
nearest point of an interval. Once you see that, a hundred and fifty years of convex
geometry comes along for free.

---

### The trick: the median is a clamp

Write $\operatorname{med}(x,a,b)$ for the middle of the three numbers $x, a, b$. Fix the two
"clean" values $a$ and $b$ and let $x$ — the possibly-corrupted third seed — vary. Watch what
happens.

If $x$ falls between $a$ and $b$, it *is* the middle value, so the median is $x$. If $x$
drops below both, then the smaller of $a,b$ is now in the middle, so the median is
$\min(a,b)$, no matter how far below $x$ goes. If $x$ rises above both, the median is
$\max(a,b)$.

That is precisely the description of a **clamp**:

$$\operatorname{med}(x,a,b) \;=\; \operatorname{clamp}_{[\alpha,\beta]}(x) \;=\; \max\bigl(\alpha, \min(x, \beta)\bigr), \qquad \alpha = \min(a,b),\ \beta = \max(a,b).$$

And a clamp on the line is exactly the **metric projection** onto the interval
$[\alpha,\beta]$: among all points of the interval, $\operatorname{clamp}(x)$ is the one
closest to $x$. This is the whole conceptual move of this work, and it is worth stating as a
theorem in its own right.

> **Theorem (The median is a projection).** For all real numbers $x, a, b$,
> $$\operatorname{med}(x,a,b) = P_{[\min(a,b),\,\max(a,b)]}(x),$$
> where $P_C(x)$ denotes the point of the closed set $C$ nearest to $x$.

Suddenly the median is not a combinatorial selection rule ("sort and take the middle") but a
geometric one ("find the nearest admissible point"). Selection rules are awkward to analyse;
projections are the best-understood objects in convex analysis.

---

### The obtuse angle

Here is the property that makes projections tick, and it is entirely visual. Stand at a
point $x$ outside a convex set $C$, and let $p = P_C(x)$ be its projection. Draw the arrow
from $p$ back out to $x$ — the *residual*, the part of $x$ that the projection threw away.
Now draw an arrow from $p$ to any other point $y$ of $C$. These two arrows always make an
angle of at least $90^\circ$:

$$\langle x - p,\; y - p\rangle \le 0 \qquad \text{for every } y \in C.$$

This is the **variational inequality**, and on the line it is almost a tautology: if $x$ sits
to the left of the interval then $p$ is the left endpoint, so $x - p$ points left while every
$y - p$ points right; the product of a negative and a nonnegative number is $\le 0$. If $x$ is
already inside the interval, the residual is zero and there is nothing to prove.

From this one inequality everything follows. Add $\lVert p - y\rVert^2$ to both sides of a
short expansion and you get the **Pythagorean inequality for projections**:

$$\lVert x - p\rVert^2 + \lVert p - y\rVert^2 \le \lVert x - y\rVert^2 \qquad \text{for all } y \in C.$$

Read that as a right triangle with the right angle at $p$ — except the inequality goes the
"wrong" way from Pythagoras, because $C$ can bend away. It immediately gives that $p$ is the
*nearest* point of $C$ to $x$, and, better, that it is the *unique* nearest point: if some
$y\in C$ ties with $p$ for distance, the displayed inequality forces $\lVert p-y\rVert = 0$.

So the median is not merely *a* middle value. It is the unique minimiser of
$y \mapsto |x-y|$ over the bracket spanned by the clean seeds — in the language of
optimisation, the *proximal map* of the bracket.

---

### The headline: a Pythagorean robustness budget

Now the robustness question. Corrupt one seed: replace $x$ by $y$. The median moves from
$T x$ to $T y$, where $T$ is the clamp. Two things happen at once:

* the **output** moves, by $Tx - Ty$;
* the **residual** $x - Tx$, i.e. the amount of corruption the median *absorbs and
  discards*, also changes, by $(x - Tx) - (y - Ty)$.

The theorem is that these two motions share a single quadratic budget.

> **Theorem (Firm nonexpansiveness of the median).** Let $T$ be the clamp onto $[a,b]$, i.e.
> the median with clean seeds $a \le b$. Then for all $x, y$,
> $$(Tx - Ty)^2 + \bigl((x - Tx) - (y - Ty)\bigr)^2 \;\le\; (x - y)^2.$$

The proof is three lines: write the variational inequality at $x$ with $y' = Ty$ in the
interval, write it again at $y$ with $x' = Tx$, and add.

The interpretation is the point. The seed moved by $|x-y|$. That motion has to *go
somewhere*: partly into moving the reported median, partly into changing what the median
absorbs. The theorem says the two contributions add in quadrature and cannot exceed the
input. Every unit of output motion is paid for by a quadratic loss of absorption.

Discarding the residual term gives the folklore back as a corollary:

$$|Tx - Ty| \le |x-y|.$$

The median is $1$-Lipschitz — **nonexpansive**. A seed corrupted by $\delta$ moves the
three-seed median by at most $\delta$. But nonexpansiveness is strictly the weaker statement;
firmness is what actually holds, and — as we will see — the difference matters.

---

### What firmness *is*, on the line

Firm nonexpansiveness is a Hilbert-space notion, defined for operators on any inner-product
space, and in general it is subtle. On the line it collapses to something an undergraduate
can check.

> **Theorem (Characterisation of firmness on the line).** A map $T : \mathbb{R} \to
> \mathbb{R}$ is firmly nonexpansive if and only if it is **monotone** and
> **$1$-Lipschitz**: whenever $x \le y$,
> $$T x \le T y \quad\text{and}\quad T y - T x \le y - x.$$

In words: the graph of $T$ never goes down, and never rises faster than the diagonal. It is
squeezed between the horizontal and the $45^\circ$ line. Equivalently — and this is the
picture convex analysts prefer — $T$ is firmly nonexpansive exactly when its *reflection*
$2T - I$ is nonexpansive; equivalently, $T$ is the midpoint of the identity and some
nonexpansive map.

This characterisation is a small alchemy: it turns a **metric** hypothesis (Lipschitz) into
an **order** hypothesis (monotone). That conversion is what lets us pin the median down
completely.

> **Theorem (Characterisation of the median).** Fix $a \le b$. A map $T:\mathbb{R}\to
> \mathbb{R}$ equals the clamp onto $[a,b]$ — that is, the median with clean seeds $a,b$ — if
> and only if it satisfies all three of:
> 1. $T$ is firmly nonexpansive;
> 2. $T$ fixes the endpoints: $Ta = a$ and $Tb = b$;
> 3. $T$ takes values in $[a,b]$.

Three innocuous-looking axioms, and they identify the median uniquely among *all* self-maps
of the line. This closes a question that the qualitative theory had left open: the median is
not just *an* estimator with good robustness; it is *the* estimator with these properties.

---

### Firmness cannot be weakened

A natural instinct is to hope that the familiar $1$-Lipschitz bound would suffice in place of
firmness. It does not, and there is a one-line counterexample:

$$T(x) = \min\bigl(|x|, 1\bigr).$$

This map is nonexpansive (composing $x \mapsto |x|$, which is $1$-Lipschitz, with a clamp).
Its range is exactly $[0,1]$. Its fixed points are exactly $[0,1]$ — precisely the same as
the clamp onto $[0,1]$. And yet it is not the clamp: at $x = -2$ the clamp reports $0$, while
$T$ reports $1$. It is a "median" that mistakes a seed which is far *too small* for one which
is far *too large*.

What went wrong is exactly monotonicity, and firmness is what forbids it. So the Pythagorean
inequality in the headline theorem is not decoration: it is load-bearing.

A companion fact rounds out the picture. The set of fixed points of any firmly nonexpansive
map of the line is an **interval** — it is order-convex: if $T$ fixes $u$ and $v$ and
$u \le w \le v$, then $T$ fixes $w$ too. This is the one-dimensional shadow of the
Hilbert-space theorem that the fixed-point set of a firmly nonexpansive operator is convex.
Robust estimators do not have holes in their agreement region.

---

### Where the line is special, and where it is not

Two natural questions arise once you have a good notion: does it survive composing maps, and
does it survive raising the dimension? The answers are, entertainingly, opposite.

**Composition works on the line.** If $S$ and $T$ are firmly nonexpansive maps of
$\mathbb{R}$, so is $S \circ T$. This is immediate from the characterisation: monotone
composes with monotone, $1$-Lipschitz composes with $1$-Lipschitz, and firmness is exactly
their conjunction.

**Composition fails in the plane.** Take $P_1$, the orthogonal projection onto the horizontal
axis, and $P_2$, the orthogonal projection onto the diagonal $\{y = x\}$. Both are firmly
nonexpansive — orthogonal projections onto convex sets always are. But $P_1 \circ P_2$ is
*not*. Test it on the pair $(0,1)$ and $(0,0)$: the composite sends $(0,1)$ to
$(\tfrac12, 0)$ and fixes the origin, so the output moves by $\tfrac12$ and the residual
$(x - Tx)$ moves by $\lVert(-\tfrac12, 1)\rVert$, whose square is $\tfrac54$. Adding gives
$\tfrac14 + \tfrac54 = \tfrac32 > 1 = \lVert x - y\rVert^2$. The budget is blown.

So the composition theorem is genuinely a theorem *about the line*, not a shadow of an
abstract Hilbert-space fact. Rotating structure — the fact that in the plane, two convex sets
can meet at an angle — destroys it.

**But firmness itself lifts.** In $\mathbb{R}^n$, the **coordinatewise median** — clamp each
coordinate into its own interval, i.e. project onto a box $\prod_i [a_i, b_i]$ — is firmly
nonexpansive for the full Euclidean norm. The proof is a pleasing accounting trick: each
coordinate obeys its own one-dimensional Pythagorean budget, and summing $n$ inequalities
gives the $n$-dimensional one. It also realises the Euclidean distance to the box. So the
median's robustness is not a one-dimensional accident; only the composition miracle is.

---

### Moving all the seeds at once

Everything above perturbs *one* seed. Real re-runs perturb them all. The right norm for that
is $\ell^\infty$ — the largest single perturbation — and the median behaves impeccably.

> **Theorem.** For all reals, $$\bigl|\operatorname{med}(a,b,c) - \operatorname{med}(a',b',c')\bigr| \le \max\bigl(|a-a'|, |b-b'|, |c-c'|\bigr).$$

The proof is a pure order argument: the median is monotone in each argument separately and
shifts by $d$ when all arguments shift by $d$; sandwich the perturbed triple between
$(a-d, b-d, c-d)$ and $(a+d,b+d,c+d)$ and apply both.

Concretely: at the recorded knee ensemble $\{256, 224, 160\}$, if a full re-run of the
experiment moves every seed by at most one grid step of $32$, the reported knee moves by at
most one grid step. That is a guarantee an engineer can actually use.

And the median is not alone. Consider the whole **ladder** of order-statistic-style summaries
of an ensemble of seeds — for each quota $m$, the largest budget that at least $m$ seeds can
certify. Every rung of that ladder is $1$-Lipschitz for $\ell^\infty$: if no seed's knee moves
by more than $d$, then no rung — the conservative low tail, the median, the certified
budget — moves by more than $d$.

This has a moral. Lipschitz robustness does **not** distinguish the rungs of the ladder; they
are all equally stable against small perturbations of everything. What distinguishes them is
their **breakdown point** — how many seeds can be corrupted arbitrarily before the summary is
useless. The maximum has breakdown $0$; the median has breakdown $1/2$. Small-perturbation
stability and gross-error resistance are *independent axes* of robustness, and the median
happens to be excellent on both.

---

### Iterating the filter

The last movement of the story is dynamical. Instead of clamping all the way in one step, one
often *relaxes*: move a fraction $\lambda$ of the way from the current estimate towards the
median,

$$x \;\longmapsto\; (1-\lambda)x + \lambda\, T x, \qquad 0 < \lambda \le 1.$$

Iterating this contracts the distance to the median by **exactly** the factor $1-\lambda$ each
step:

$$T_\lambda^{\,n}(x) - Tx = (1-\lambda)^n\,\bigl(x - Tx\bigr).$$

Not a bound — an identity. Hence convergence to the median at a known geometric rate. (The
subtle ingredient is that a relaxed step never crosses the interval, so the projection of the
iterate never changes; that is where monotonicity of the clamp earns its keep.) This is a
Krasnoselskii–Mann theorem with an exact rate rather than an asymptotic one.

Can relaxation be dropped? In a general Hilbert space, no: an unrelaxed iteration of a merely
nonexpansive map can rotate forever, and even for firmly nonexpansive maps one only gets weak
convergence. **On the line it can.**

> **Theorem (Unrelaxed convergence on the line).** If $T:\mathbb{R}\to\mathbb{R}$ is firmly
> nonexpansive and has at least one fixed point, then for every starting point $x$ the orbit
> $x, Tx, T^2x, \dots$ converges to a fixed point of $T$.

The proof is not metric at all — it is order-theoretic. A fixed point $p$ cuts the line into
two half-lines, each invariant under $T$ by monotonicity. On the upper one, monotonicity and
the Lipschitz bound force the orbit to be decreasing and bounded below by $p$; on the lower
one, increasing and bounded above. The completeness of the real line then hands you the
limit, and continuity makes it a fixed point. No contraction estimate is used — and none
could be, since the identity map is firmly nonexpansive and its orbits never move.

The payoff is a **consensus algorithm**. Suppose two independent experiments certify two
brackets, $[a,b]$ and $[c,d]$, and suppose they overlap. Alternately re-clamping a candidate
answer into one bracket, then the other, converges — and, crucially, converges to a point
lying in *both* brackets, never to a spurious compromise stuck between them. The key
structural fact is that when two firmly nonexpansive maps of the line share a fixed point,
the fixed points of their composition are exactly their *common* fixed points. Alternating
median filters find consensus, or nothing.

---

### Why this is more than a curiosity

The median is one of the most-used statistics on earth, and its robustness is usually
justified by a hand-wave about outliers. Reframing it as a metric projection replaces the
hand-wave with a geometry:

* **A sharper constant.** The honest robustness statement is not "the median moves by at most
  $\delta$" but the quadratic budget $(\Delta \text{output})^2 + (\Delta\text{absorbed})^2 \le
  \delta^2$. Output motion and absorption trade off in quadrature.
* **A uniqueness theorem.** Firm nonexpansiveness plus fixing the endpoints plus staying in
  range determines the median outright — and the Lipschitz bound alone provably does not.
* **A design principle.** Because firmly nonexpansive maps of the line are exactly the
  monotone $1$-Lipschitz ones, and because their unrelaxed orbits always converge, any
  estimator built by composing such filters inherits stability and convergence for free.
* **A clean separation of robustness notions.** Everything in the order-statistic ladder is
  equally Lipschitz; only breakdown separates them.

Projections onto convex sets are the atoms out of which modern optimisation is built —
proximal gradient methods, alternating projections, splitting algorithms, the whole apparatus
that trains models and solves feasibility problems. To notice that the median has been one of
those atoms all along is to place a piece of statistical folklore inside a theory that
already knows how to iterate it, compose it, relax it, and prove it converges.

The middle of three numbers, it turns out, has been doing convex geometry the whole time.
