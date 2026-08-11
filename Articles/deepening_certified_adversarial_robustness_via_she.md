# The Shape of a Blind Spot

## How a nineteenth-century idea about loops explains when a classifier can be trusted

There is a photograph, famous in machine-learning circles, of a panda. A neural
network labels it "panda". Then a faint, structureless speckle of noise —
invisible to you, invisible to me, a nudge of a few brightness levels per pixel
— is added, and the same network confidently labels the same picture "gibbon".

That single image launched a decade of research into *adversarial examples*,
and with it, an industry of **certification**: rather than testing a model on
whatever attacks we happen to think of, prove a theorem. Prove that for a given
input $x$, every perturbation $\varepsilon$ with $\|\varepsilon\|_\infty \le
\rho$ — every perturbation that changes each coordinate by at most $\rho$ —
leaves the decision unchanged. The number $\rho$ is the **certified radius**,
and it is a genuine guarantee: not "we tried and failed to break it", but "it
cannot be broken."

Certification, though, is *local*. Certify a thousand inputs and you have a
thousand small promises, each valid inside its own little ball, with no
statement about the vast space between them. The obvious next move — glue the
promises together, declare the whole region safe — feels like bookkeeping.

It is not bookkeeping. It is topology. The punchline of this article is a
theorem that says so exactly:

> **Local certificates glue into a global certificate if and only if a certain
> loop invariant of the cover vanishes.** The number of independent ways gluing
> can fail is a Betti number: $\dim H^1 = |E| - |V| + 1$, where $|V|$ counts
> your certified regions and $|E|$ counts the pairs that overlap.

Robustness certification, it turns out, is a cohomology computation.

---

## Patches, and the graph that records how they meet

Start with a binary classifier described by a continuous **score function** $s$
on input space: predict "yes" when $s(y) > 0$, "no" when $s(y) < 0$. The set
$\{s = 0\}$ is the decision boundary, the invisible wall the adversarial noise
is trying to push you across.

Now take a finite family of **anchor points** $x_1, \dots, x_N$ — think of them
as your test set, or as a sampling of a region of interest. Around each one,
suppose you have run a certifier and obtained a promise: on the closed
$\rho$-ball around $x_i$, the sign of $s$ is constantly $\sigma_i \in \{+1,
-1\}$. Formally, say that $x_i$ is **sign-certified at radius $\rho$ with sign
$\sigma_i$** when
$$\|y - x_i\| \le \rho \;\Longrightarrow\; \sigma_i \, s(y) > 0 .$$
In the coordinate space $\mathbb{R}^d$ with the sup norm, this is precisely the
$L^\infty$ guarantee: change each coordinate by at most $\rho$ and the decision
survives.

Two anchors' balls may overlap. Record that fact in a graph: one **vertex** per
anchor, one **edge** for each overlapping pair. This graph is the **nerve** of
the cover — a construction going back to Pavel Alexandrov in the 1920s, whose
whole point is that a graph (or a simplicial complex) built from *which patches
meet* remembers the shape of the space they cover. A chain of overlapping discs
around an annulus produces a nerve that is a cycle; a chain along an interval
produces a nerve that is a path.

The certificates are what a topologist calls **local sections**: data attached
to each patch. The systematic study of when local agreement forces global
existence is *sheaf theory*, and the machinery measuring the failure is *sheaf
cohomology*. The claim of this article is that here the machinery is not
analogy: it is literally the right tool, and it computes the right number.

---

## The first surprise: the sheaf axiom is free

In general sheaf theory, "the sections agree on overlaps" is an assumption you
impose. Here it is a *theorem*.

> **Overlap Compatibility.** Suppose $x_i$ and $x_j$ are both sign-certified at
> radius $\rho \ge 0$, with signs $\sigma_i, \sigma_j \in \{+1,-1\}$, and
> suppose $\|x_j - x_i\| \le \rho$. Then $\sigma_i = \sigma_j$.

The proof is two lines and is worth seeing, because it is the seed of
everything. Since $x_j$ lies inside $x_i$'s certified ball, $\sigma_i\, s(x_j) >
0$. Since $x_j$ lies in its own ball (the centre is always within radius
$\rho \geq 0$ of itself), $\sigma_j \, s(x_j) > 0$. So $s(x_j) \ne 0$ and two
signs, both multiplying $s(x_j)$ to something positive, must be equal.

Certification, in other words, doesn't merely *permit* consistency across
overlaps — it *forces* it. Nature supplies the sheaf axiom.

## The second surprise: gluing along chains, and a global guarantee

Once compatibility is free, an induction along paths gives the global statement.
Call the nerve **connected** if any anchor can be reached from any other by a
chain of overlaps.

> **Gluing Theorem.** Let the nerve be connected, let each anchor $x_i$ be
> sign-certified at radius $\rho \ge 0$ with sign $\sigma_i \in \{\pm 1\}$, and
> suppose every overlapping pair satisfies $\|x_j - x_i\| \le \rho$. Then all
> the signs are equal, $\sigma_i = \sigma_j$ for every $i,j$; and consequently
> for a fixed base index $i_0$,
> $$\|y - x_i\| \le \rho \;\Longrightarrow\; \sigma_{i_0}\, s(y) > 0
> \quad \text{for every } i .$$

Read the conclusion carefully: it is a **single** guarantee covering the
**union** of all the balls. Every point within $L^\infty$ distance $\rho$ of
*any* anchor receives the *same* verdict. The thousand small promises have
become one large one, and nothing was assumed beyond the promises themselves and
the combinatorics of which balls touch.

Spelled out in coordinates: if $y$ and $x_i$ differ by at most $\rho$ in every
single coordinate, then $\sigma_{i_0} s(y) > 0$. That is a certified
$L^\infty$ perturbation radius for an entire connected region of input space.

## The third surprise: the converse, with an explicit adversarial example

Suppose gluing fails. Concretely: suppose you walk along a chain of overlapping
anchors, all pairwise within $\delta$, and find $s$ positive at the start and
non-positive at the end. Sign has flipped along the walk. This is *holonomy* —
the same word used for what happens to a vector parallel-transported around a
loop on a curved surface, coming back rotated.

What does the flip cost you? Everything, and at an explicitly bounded scale.

> **Holonomy Obstruction Theorem.** Let $s$ be continuous, let $a$ be an anchor
> with $s(x_a) > 0$, let the walk $a \to \cdots \to b$ consist of overlaps with
> $\|x_j - x_i\| \le \delta$, and suppose $s(x_b) \le 0$. Then there is an
> anchor $x_u$ on the walk and a point $z$ on the decision boundary, $s(z) = 0$,
> with $\|z - x_u\| \le \delta$. Consequently **no** sign whatsoever certifies
> $x_u$ at radius $\delta$: the uniform certified radius of the cover is
> strictly capped by the overlap scale.

The proof is a discrete argument followed by a continuous one. Discretely: if
$s$ is positive at the start of the walk and not at the end, there must be a
single step $u \to v$ where positivity is lost — walk along until it happens.
Continuously: apply the intermediate value theorem to $t \mapsto s(u + t(v-u))$
on the segment joining the two anchors, obtaining a zero $z$ at distance at most
$\|v - u\| \le \delta$ from $x_u$. That $z$ is a *witness* — an actual input,
constructible by bisection, sitting on the wall, a hair's breadth from a point
you were about to certify.

Note the hypothesis: **continuity of the score, and nothing else.** No Lipschitz
constant, no smoothness, no architecture assumption. That matters, because
certification runs almost entirely on Lipschitz bounds, which are notoriously
loose for deep networks. Here a Lipschitz constant is not needed to *detect* the
failure, only to quantify how far it extends.

Put the two directions together and you get the slogan in theorem form:

> **Certification–Holonomy Equivalence.** On a connected nerve whose overlapping
> anchors are within $\delta$: a family of *local* $L^\infty$ certificates at
> radius $\delta$ exists if and only if a *single global* certificate at radius
> $\delta$ exists — equivalently, if and only if the decision sheaf has no sign
> holonomy.

Certification is not an analytic property that happens to be checkable
locally. It is a cohomological property.

---

## Counting the ways it can fail

So far the obstruction is a yes/no. Cohomology's real gift is that it *counts*.

Attach to each overlap a real number $c_{ij} = -c_{ji}$: the **discrepancy**
between the local certificates on that overlap (how much the two patches
disagree about the margin, the radius, the calibration — whatever quantity you
track). Call such a family a *1-cochain*. It **glues** if there is a single
global function $f$ on the regions with $c_{ij} = f_j - f_i$ for every overlap:
a global potential explaining all the local disagreements.

Along a walk $i_0 \to i_1 \to \cdots \to i_k$, define the **holonomy** as the
running total $\sum_{t} c_{i_t i_{t+1}}$.

> **Discrete Poincaré Lemma.** On a connected nerve, an antisymmetric 1-cochain
> with values in any abelian group glues if and only if its holonomy vanishes
> around every closed walk.

Necessity is a telescoping sum: if $c_{ij} = f_j - f_i$, the holonomy along any
walk equals $f(\text{end}) - f(\text{start})$, which is $0$ for a closed walk.
This is the discrete fundamental theorem of calculus. Sufficiency is a
construction: fix a base region $b$, define $f_i$ to be the holonomy along
*some* walk from $b$ to $i$, and check that vanishing loop holonomy makes the
answer independent of the walk chosen. The one delicate ingredient is that
reversing a walk negates its holonomy — which is exactly where antisymmetry
$c_{ji} = -c_{ij}$ earns its place.

Two immediate consequences reshape how one thinks about cover design.

**Trees never obstruct.** If the nerve is a tree — every region has a unique
parent, no cycles — then *every* antisymmetric discrepancy glues, no hypothesis
required, over any coefficient group. Integrate from the root down. There are no
loops, so there is nothing to fail.

**Loops obstruct exactly once.** For the cyclic nerve $U_0, U_1, \dots, U_n,
U_0$, a discrepancy $g$ glues if and only if $\sum_i g_i = 0$; and the map
"class $\mapsto$ holonomy" is an isomorphism
$$H^1(\text{loop}, M) \;\cong\; M$$
for *every* abelian coefficient group $M$. With $M = \mathbb{R}$, the first
cohomology is one-dimensional. With $M = \mathbb{Z}/2$, it is the parity of
label flips around the loop: **a loop of regions across which the predicted
label flips an odd number of times admits no consistent global labelling**,
full stop. A single flip realises the nontrivial class, so this is not an
abstract non-vanishing but an exhibited generator.

**Two-parameter periodicity obstructs exactly twice.** Cover a doubly periodic
family — say a two-parameter family of reparametrisations of the weights, or a
loop of layers crossed with a loop of input directions — and the nerve is a
discrete torus, an $(m+1) \times (n+1)$ grid with wrap-around. A 1-cochain is a
pair $(h,v)$ of horizontal and vertical discrepancies; it is **flat** when the
total discrepancy around every unit square vanishes,
$$h_{p} + v_{p + e_1} = v_{p} + h_{p+e_2}.$$
For a flat cochain the row sum is independent of the row and the column sum is
independent of the column, so there are two well-defined holonomies; and a flat
cochain glues iff *both* vanish. Hence
$$H^1(\text{torus nerve}, \mathbb{R}) \cong \mathbb{R}^2, \qquad \dim H^1 = 2 .$$
Both holonomies are realised by explicit flat cochains, so the answer $2$ is not
an artefact.

And now the law these three computations are instances of:

> **Betti Number Law.** For a finite connected nerve with vertex set $V$
> (regions) and edge set $E$ (overlaps),
> $$\dim H^1 = |E| - |V| + 1 .$$
> In particular $H^1 = 0$ — every local datum glues — precisely when $|E| = |V|
> - 1$, i.e. when the nerve is a spanning tree.

The proof is rank–nullity with one geometric input: on a connected nerve, a
0-cochain with no jump across any overlap is constant, so $\ker \delta$ is the
one-dimensional line of constants ($H^0 \cong \mathbb{R}$: a connected cover has
one global verdict, no more). Therefore the space of gluable discrepancies has
dimension $|V| - 1$, and the quotient has dimension $|E| - (|V| - 1)$.

Check it against the examples: path, $|E| = |V| - 1$, Betti $0$; loop, $|E| =
|V|$, Betti $1$; and the torus's grid graph has Betti $|V|+1$, cut down to
exactly $2$ by the plaquette relations.

**This is a design principle.** The number of independent ways your certificates
can fail to glue is not a property of the network, the data, or the attack. It
is $|E| - |V| + 1$, a property of *how you chose to cover the space*. Choose a
cover whose nerve is a tree and gluing is guaranteed for free. Every extra
overlap beyond a spanning tree is one more chance for the certificates to
disagree — and one more independent adversarial direction to check.

---

## How big is the obstruction? A metric for cohomology

Non-vanishing cohomology sounds qualitative. On a loop it is exactly
quantitative.

> **Defect Theorem.** For a cyclic nerve of $n+1$ regions and a discrepancy $g$
> with holonomy $H = \sum_i g_i$, the smallest $\varepsilon$ for which some
> global potential $f$ satisfies $|(f_{i+1} - f_i) - g_i| \le \varepsilon$ at
> *every* overlap is exactly
> $$\varepsilon_{\min} = \frac{|H|}{n+1}.$$
> This value is attained, not merely approached.

The lower bound is averaging: coboundaries have zero total sum, so the total
mismatch must absorb all of $H$, and $|H| \le (n+1)\varepsilon$ by the triangle
inequality. Tightness comes from subtracting the mean: replacing $g_i$ by $g_i -
H/(n+1)$ kills the holonomy, making the remainder a genuine coboundary, and the
mismatch is the constant $|H|/(n+1)$ at every single overlap. That extremal
cochain — the constant one — is the discrete analogue of the **harmonic
representative** in Hodge theory: each cohomology class has a unique minimal
representative, and its size is a metric invariant of the class.

The consequence for practice: a loop of $n+1$ regions with holonomy $H$ admits
no global certificate assignment whose per-overlap mismatch is below
$|H|/(n+1)$. The obstruction has a price tag, and you can compute it by
summing $n+1$ numbers.

There is a matching positive statement. Suppose the local certified radii $r_i$
*do* form a global section, all overlap discrepancies are at most $\varepsilon$,
and every region is reachable from a base region $i_0$ within $D$ steps of the
nerve. Then
$$r_j \;\ge\; r_{i_0} - D\,\varepsilon \qquad \text{for every region } j,$$
a uniform certified radius for the whole cover from purely local data plus the
diameter of the nerve. Vanishing cohomology gives existence; the nerve's
geometry gives the constant.

---

## When the classes don't commute

Everything above is binary. Real classifiers have $k$ classes, and there the
story changes character in a way worth savouring.

For $k$ classes, the data attached to an overlap is no longer a number but a
**relabelling**: a permutation of $\{1, \dots, k\}$ telling you how region $i$'s
class names correspond to region $j$'s. Holonomy is no longer a sum but an
ordered product, and products of permutations do not commute.

> **Nonabelian Discrete Poincaré Lemma.** On a connected nerve, a group-valued
> transition cochain with $c_{ji} = c_{ij}^{-1}$ arises from a global relabelling
> ($c_{ij} = f_i^{-1} f_j$) if and only if the ordered product of transitions
> around every closed walk is the identity.

The abelian proof survives intact once sums become ordered products —
commutativity was never used. The only structural input is that reversing a walk
*inverts* its holonomy, the group-theoretic form of antisymmetry. Specialising
to permutations:

> **Multi-Class Monodromy Obstruction.** If transporting the predicted labels of
> a $k$-class classifier around a loop of overlapping regions returns a
> nontrivial permutation of the classes, then no globally consistent labelling
> of the cover exists.

And this is realised, not hypothetical. Take three mutually overlapping regions
of a three-class problem, and let each "upward" crossing apply the transposition
swapping classes $0$ and $1$. Every pairwise overlap is consistent by
construction — you can always match up two regions. But the monodromy around the
triangle $0 \to 1 \to 2 \to 0$ is the transposition $(0\,1)$, not the identity,
and so no global labelling exists at all. Local consistency, everywhere, with
global inconsistency: the Escher staircase of classification.

For $k = 2$ the permutation group is $\mathbb{Z}/2$ and this collapses back to
the parity obstruction. Binary robustness genuinely hides the nonabelian nature
of the problem.

---

## What to take away

Three ideas, in increasing order of unexpectedness.

**One.** Certification is naturally *sheaf-like*, and the compatibility axiom
comes for free. You don't have to impose agreement on overlaps; certification
implies it.

**Two.** Whether local certificates assemble into a global guarantee is
*exactly* a cohomological question, and the answer is computable from the
combinatorics of your cover alone: $\dim H^1 = |E| - |V| + 1$. Zero for trees;
one per independent loop. When the obstruction vanishes you get a genuine
$L^\infty$ radius over the whole union; when it doesn't, the intermediate value
theorem hands you a decision-boundary point within the overlap scale of an
anchor — an adversarial witness, explicitly located, from continuity alone.

**Three.** The obstruction has a size, $|H|/(n+1)$ on a loop, and that size is
the unavoidable certificate mismatch. Cohomology classes here are not abstract
labels; they are numbers you can bound your engineering by.

The panda-to-gibbon flip is, in this language, a walk along a chain of nearby
inputs whose sign holonomy is nonzero — not bad luck, and not an artifact of
the attack algorithm, but the signature of a nonzero cohomology class living on
the shape of your cover. And that shape is something you chose, and can choose
better.
