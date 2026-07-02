# The Stubborn Half: Chasing a Constant Between Two Worlds

## A puzzle about watchmen on a grid

Imagine a museum whose floor plan is a grid of rooms. You want to place guards so
that every room is either occupied by a guard or lies next to one. Guards are
expensive, so you want as few as possible. This "fewest guards" number is one of
the oldest and most useful quantities in the mathematics of networks. It is called
the **domination number**, and it turns up whenever we want a small set of
sentinels to keep watch over a large structure — servers monitoring a network,
sensors covering a region, or facilities serving a population.

Formally, take a graph $G$: a collection of vertices (rooms) joined by edges
(doorways). A set $S$ of vertices *dominates* $G$ if every vertex is either in $S$
or shares an edge with some vertex of $S$. The domination number $\gamma(G)$ is the
size of the smallest such set.

Now here is where it gets interesting. Real networks are often *products* of
simpler ones. A grid of rooms is the product of a row and a column. A torus of
processors is the product of two rings. The natural product for this purpose is the
**Cartesian product**, written $G \,\square\, H$. Its vertices are the pairs
$(g, h)$ with $g$ a vertex of $G$ and $h$ a vertex of $H$. Two pairs are joined by
an edge exactly when they agree in one coordinate and are adjacent in the other.
Picture stacking a copy of $H$ over every vertex of $G$; you may step *within* a
copy along an edge of $H$, or step *between* copies along an edge of $G$, but never
diagonally. Every edge of the product keeps one coordinate perfectly still — a
small fact that turns out to be the hinge of the whole story.

## Vizing's fifty-year-old guess

In 1968 Vadim Vizing asked a question so clean it still has no answer. If you know
how many guards each factor needs, what can you say about the product? He conjectured
the most optimistic possible bound:
$$\gamma(G \,\square\, H) \ \ge\ \gamma(G)\,\gamma(H).$$
In words: dominating a product is at least as hard as dominating each factor and
multiplying the costs. It sounds almost obvious. It has resisted proof for more than
half a century and is one of the most famous open problems in graph theory.

Because the full conjecture is out of reach, mathematicians have chased the next best
thing: prove the inequality with a *constant* in front,
$$\gamma(G \,\square\, H) \ \ge\ c \cdot \gamma(G)\,\gamma(H),$$
and push the constant $c$ as close to $1$ as possible. In 2000, W. Edwin Clark and
Stephen Suen proved a landmark result with $c = \tfrac{1}{2}$. Half of Vizing.
Every product needs at least half of what the conjecture predicts. That "stubborn
half" has been the benchmark ever since.

## An unlikely number

Later work by Suen, Tarr, and others nudged the constant upward, and out of the
bookkeeping emerged a strange and specific number:
$$c \;=\; \frac{19 - \sqrt{73}}{18} \;\approx\; 0.5809.$$
Why on earth $\sqrt{73}$? The answer is one of the small delights of this subject.
The Clark–Suen method dominates a product by covering it fibre by fibre, and each
edge of the product only "pays" for its fixed coordinate, leaving the moving
coordinate to be accounted for separately. When you carefully balance the cost of
the fixed half against the cost of the moving half, the two competing quantities
meet in a quadratic equation:
$$9x^2 - 19x + 8 = 0.$$
Its two roots are $\dfrac{19 \pm \sqrt{73}}{18}$, and the smaller one — the
honest, binding constraint — is exactly $\dfrac{19 - \sqrt{73}}{18}$. The
irrational-looking constant is not arbitrary at all: it is where two rates of
spending cross.

This gives us three clean, checkable facts about $c$.

**It really is a root of that quadratic.** Substituting $c = \tfrac{19-\sqrt{73}}{18}$
into $9x^2 - 19x + 8$ and using $(\sqrt{73})^2 = 73$, everything cancels to $0$. The
number is algebraic of degree two, pinned down exactly.

**It genuinely beats the stubborn half.** Since $\sqrt{73} < \sqrt{100} = 10$, we have
$19 - \sqrt{73} > 9$, so $c > \tfrac{9}{18} = \tfrac12$. The improvement over
Clark–Suen is real, not cosmetic.

**It stays below Vizing's dream.** Since $\sqrt{73} > \sqrt{1} = 1$, we have
$19 - \sqrt{73} < 18$, so $c < 1$. The constant sits strictly between the proven
half and the conjectured whole: $\tfrac12 < c < 1$.

So $c \approx 0.5809$ is the precise numerical shape of "better than half, not yet
all the way."

## The two walls that box the answer in

Behind the race for the best constant lies a much more elementary and completely
settled picture. For *any* graphs $G$ and $H$, the domination number of the product
is squeezed between two simple walls:
$$\max\bigl(\gamma(G),\,\gamma(H)\bigr) \ \le\ \gamma(G \,\square\, H)\ \le\ \gamma(G)\cdot |V(H)|,$$
where $|V(H)|$ is the number of vertices of $H$. Both walls have one-line intuitions.

**The upper wall — cylindrification.** Take a smallest dominating set of $G$, and in
the product select *every* vertex sitting above it: all pairs $(g, h)$ with $g$ in the
dominating set. This uses $\gamma(G)\cdot|V(H)|$ vertices, and it dominates the whole
product, because any pair $(g', h)$ is handled inside its own copy of $H$ by whatever
dominated $g'$ down in $G$. Crude, but always valid.

**The lower wall — projection.** This is the subtle and beautiful half, and it is the
engine that powers every Vizing-type theorem. Take *any* dominating set of the product
and shadow it down onto the first coordinate — record which $g$'s appear. Here the
"one coordinate stays fixed" property of Cartesian edges does its quiet work: whenever
$(g', h)$ is dominated by some $(g, h')$ in the set, either $g = g'$ (a within-copy
step) or $g$ is adjacent to $g'$ in $G$ (a between-copy step). Either way the shadow
of the dominating set dominates $G$ itself, so the product needs at least $\gamma(G)$
vertices. By symmetry it needs at least $\gamma(H)$, hence at least the larger of the
two. (A small caveat: the factor being projected onto must be nonempty, so there is
actually a fibre to shadow onto.)

These two walls are not just decoration. The lower wall — the projection bound — is
exactly the combinatorial fact that Clark and Suen leaned on, and it is the reason the
whole enterprise gets off the ground.

## Where the constant is already earned

Put the algebra of $c$ together with the projection wall and something concrete falls
out immediately. Suppose one of the two factors is easy to dominate — say
$\min(\gamma(G), \gamma(H)) \le 1$, meaning one of them needs just a single guard.
Then the product of the two domination numbers is no larger than the *bigger* of them,
and the projection wall already guarantees the product needs at least that bigger
value. Since $0 < c < 1$, we conclude
$$c \cdot \gamma(G)\,\gamma(H) \ \le\ \max\bigl(\gamma(G),\gamma(H)\bigr) \ \le\ \gamma(G \,\square\, H).$$
In this regime the coveted constant $c = \tfrac{19-\sqrt{73}}{18}$ is not merely
plausible — it is *proved*, and it follows from nothing deeper than the projection
bound and the fact that $c$ lies below $1$. To be scrupulous: this is the regime the
elementary method already covers. The unconditional constant, valid when *both*
factors are hard to dominate, remains the frontier — that is where the extra
discharging argument, and the full force of the quadratic, must eventually be spent.

## Why the small facts matter

It is tempting to shrug at a result that only settles the "easy" regime. But the value
here is in the *anatomy*. We now know precisely three things and can say them without
hand-waving: the mysterious constant is the smaller root of an explicit integer
quadratic; it strictly beats one-half and strictly undershoots one; and the very same
projection argument that Clark and Suen used already delivers the improved constant
whenever one factor is dominated by a single vertex. The stubborn half has been given
a face, a formula, and a clear boundary marking exactly how much of Vizing's
conjecture the elementary method can honestly claim.

## The road ahead

The natural dream is to remove the crutch entirely — to prove
$\gamma(G\,\square\,H) \ge \tfrac{19-\sqrt{73}}{18}\,\gamma(G)\,\gamma(H)$ for *all*
graphs, no matter how hard each factor is to dominate. The projection argument spends
only the fixed-coordinate half of every product edge; the missing factor must come
from a discharging step that also accounts for the moving-coordinate half, and
balancing the two is precisely what regenerates the quadratic $9x^2 - 19x + 8$ whose
smaller root is our constant. There are equally tempting side quests: build families
of graphs that make the lower wall exactly tight for arbitrarily large domination
numbers, and study the *fractional* version of the problem, where dominating sets are
allowed to be spread out as weights. Remarkably, in the fractional world the product
rule holds on the nose — the domination "measure" of a product equals the product of
the measures — so the entire deficit captured by $\tfrac{19-\sqrt{73}}{18}$ is
exactly the price of insisting that guards be whole people rather than fractions of
one.

Half a century after Vizing's deceptively simple question, we still cannot say whether
dominating a product costs as much as the product of the costs. But we can now name,
to the last decimal, the best constant the classical method reaches, explain where its
$\sqrt{73}$ comes from, and prove it exactly where the argument is strong enough to
carry it. Sometimes progress in mathematics is not a thunderclap but a sharpening —
turning a stubborn half into a precise $0.5809\ldots$, and knowing exactly why.
