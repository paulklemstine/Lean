# The Shape of Nothing: What Spacetime Might Look Like at $10^{-35}$ Metres

## A line with two origins

Take the real number line. Now do something slightly perverse: at the point $0$, and only there, tear the line apart and glue in a *second* copy of that point. Call them $0_{\text{red}}$ and $0_{\text{blue}}$. Everywhere else the line is untouched — there is one point at $1$, one at $-\pi$, one at $0.0001$. Only the origin has been doubled.

What have you made? Something that looks, from any finite distance, exactly like the ordinary line. Zoom in on $0_{\text{red}}$: every neighbourhood of it contains all the nearby points $\pm\varepsilon$, and it is a perfectly ordinary interval. Zoom in on $0_{\text{blue}}$: same thing. Locally, the object is indistinguishable from $\mathbb{R}$.

Globally, it is a monster. Take the sequence $1, \tfrac12, \tfrac13, \tfrac14, \dots$. Where does it converge? To $0_{\text{red}}$ — every neighbourhood of $0_{\text{red}}$ eventually contains the whole tail. But also to $0_{\text{blue}}$, for exactly the same reason. **One sequence, two limits.** The two origins can never be prised apart: any open set containing $0_{\text{red}}$ and any open set containing $0_{\text{blue}}$ must overlap, because both must swallow the punctured interval around zero.

This little object — the *line with two origins* — is the standard textbook counterexample to the Hausdorff property, the axiom that says distinct points can be surrounded by disjoint neighbourhoods. It is usually presented as a curiosity, a pathology to be quarantined.

This article is about taking it seriously as physics.

## Wheeler's foam

In 1955 John Wheeler argued that the smooth, gently curved spacetime of general relativity cannot survive all the way down. Quantum mechanics forces the metric to fluctuate, and the fluctuations grow as you shrink the region you look at. At the Planck length,
$$\ell_P = \sqrt{\frac{\hbar G}{c^3}} \approx 1.6 \times 10^{-35}\ \text{metres},$$
the fluctuations in the geometry are as large as the geometry itself. Wheeler's image was of a violently churning **spacetime foam**: at each Planck cell, the topology itself bubbles, wormholes flicker in and out, and the notion of "the geometry here" ceases to have a single answer.

Nobody knows the right mathematics for this. But here is a suggestion that is both minimal and surprisingly rich: *if the geometry at a Planck cell has no single answer, then the cell should be represented by more than one point of space — several coincident copies, one per branch of the fluctuation, indistinguishable to anything outside the cell.*

That is exactly the line with two origins, replicated at every excited Planck site.

## Building the foam

Let $X$ be macroscopic spacetime — for concreteness, the real line, though everything below works for any topological space. Let $S \subseteq X$ be the **branch locus**: the set of Planck cells at which the geometry bifurcates. Let $\iota$ be an index set of **sheets** — the possible branches, say $\{\text{red}, \text{blue}\}$.

Form the product $X \times \iota$: $|\iota|$ parallel copies of spacetime. Now glue them back together *everywhere except over $S$*. Formally, declare
$$(x, i) \sim (y, j) \iff x = y \ \text{ and } \ \big( i = j \ \text{ or } \ x \notin S \big),$$
and let the **foam** $\mathrm{Foam}(X, S, \iota)$ be the resulting quotient space. Off the branch locus the sheets are welded into one; over each branch point they stay apart. Each sheet gives an inclusion $s_i : X \to \mathrm{Foam}(X,S,\iota)$, and collapsing all sheets gives a projection $\pi : \mathrm{Foam}(X,S,\iota) \to X$, the "macroscopic shadow" map.

With $X = \mathbb{R}$, $S = \{0\}$, and two sheets, this is precisely the line with two origins. With $S$ a Planck lattice $\{\ell k : k \in \mathbb{Z}\}$, it is a line with a doubled point every $1.6 \times 10^{-35}$ metres. That is our model of Wheeler foam.

Everything that follows is a theorem about this object. The striking thing is how much of it reads like physics.

## Foam is invisible

The first theorem is a sharp dichotomy about when the foam is pathological at all.

> **Separation Theorem.** With at least two sheets, the foam is Hausdorff if and only if $X$ is Hausdorff *and* the branch locus $S$ is an **open** set. It is $T_1$ (points are closed) exactly when $X$ is.

The proof of the interesting direction is the two-origins argument in general form: if $x \in S$ is not in the interior of $S$, then any neighbourhood of the sheet-$i$ copy of $x$ contains smooth points arbitrarily close to $x$, and those smooth points belong to *every* sheet at once. So neighbourhoods of different branches always collide.

Read this physically. A "thick" branch locus with nonempty interior — a whole open region that is uniformly foamy — is harmless: the foam over it is a perfectly ordinary Hausdorff space, just with more room. But a genuine Wheeler foam, where Planck branch points sit isolated in an otherwise smooth background, has a branch locus with *empty interior*, and it is never Hausdorff. In fact one can say more: such a foam fails even the much weaker axiom $R_1$, so its non-Hausdorffness cannot be repaired by throwing away topologically indistinguishable points. **The pathology is intrinsic.**

Second theorem: it is also *unobservable*.

> **Invisibility Theorem.** If the branch locus has empty interior, then every continuous map from the foam into a Hausdorff space factors uniquely through the macroscopic projection. That is, for every continuous $f : \mathrm{Foam}(X,S,\iota) \to Y$ with $Y$ Hausdorff there is a unique continuous $g : X \to Y$ with $f = g \circ \pi$.

Why? Because a Hausdorff-valued continuous map must send non-separated points to the same value — if $u$ and $v$ cannot be pulled apart in the foam, their images cannot be pulled apart in $Y$, and in a Hausdorff space that forces $f(u) = f(v)$. So $f$ is constant on each Planck fibre and descends.

The physical statement is worth pausing on. **No measurement with real-number outcomes can tell you which branch of a Planck fluctuation you are on.** The foam is not merely hard to detect; it is provably invisible to the entire class of Hausdorff-valued observables — which is to say, to every measurement anyone has ever performed. And yet the foam is genuinely *not* homeomorphic to smooth spacetime. It is a real structural difference that no continuous number-valued instrument can register.

## A hidden gauge symmetry

If the branches are indistinguishable, relabelling them should change nothing. It doesn't — and this can be made precise.

> **Gauge Theorem.** Every permutation $\sigma$ of the sheet index set induces a homeomorphism of the foam commuting with the macroscopic projection. This gives a group homomorphism from the symmetric group $\mathrm{Sym}(\iota)$ into the homeomorphism group of the foam, and it is **injective precisely when the branch locus is nonempty**. Moreover, when the branch locus has empty interior, every continuous Hausdorff-valued observable is invariant under the whole group.

So the foam carries a genuine internal gauge symmetry — a copy of $\mathrm{Sym}(\iota)$ acting nontrivially on the space — exactly when there *is* foam, and this symmetry acts trivially on everything measurable. That is the textbook definition of a gauge redundancy, arrived at not by postulate but as a theorem about a quotient topology.

## Not a covering space — and exactly why

The natural guess is that the foam is a multi-sheeted covering of spacetime. It isn't, and the failure is precisely diagnosable.

Define the **sheet number** at a macroscopic point $x$ to be the number of foam points sitting above it. It equals $|\iota|$ on the branch locus and $1$ off it. A covering space needs this number to be *locally constant*; here it jumps discontinuously at every Planck branch point that is a limit of smooth points. The result is a clean dichotomy:

> **Covering Dichotomy.** The macroscopic projection is a covering map if and only if the branch locus is clopen (both open and closed). On a connected spacetime this forces either $S = \varnothing$ (no foam at all) or $S = X$ (uniformly foamy space).

Equivalently: a continuous global "which branch am I on?" observable exists exactly in those degenerate regimes. When the branch locus is closed, the projection is still a *local homeomorphism* — every foam point has a neighbourhood mapped homeomorphically onto an open piece of spacetime — so the foam is locally Euclidean. It is just not a covering. Wheeler foam lives exactly in the gap between these two notions.

## How far from a metric? A boundary count

Non-Hausdorff spaces admit no metric, so there is no Planck-scale distance function on a genuine foam. But *how badly* does the metric fail? Count the obstructions.

Call a pair of distinct foam points **defective** if their neighbourhood filters are not disjoint — the pairs a metric would have to separate but cannot. The defect set turns out to be computable exactly.

> **Metric Defect Theorem.** Two distinct branches over a point $x \in S$ are separable if and only if $x$ lies in the interior of $S$. Consequently the defective pairs are exactly the pairs of distinct sheet copies of points of the topological boundary $S \setminus \mathrm{int}\,S$, and with finitely many sheets their number is
> $$\big|S \setminus \mathrm{int}\,S\big| \cdot \big(|\iota|^2 - |\iota|\big),$$
> which for two-sheeted foam is simply $2\,\big|S \setminus \mathrm{int}\,S\big|$.

This is a genuinely surprising formula. The distance from metrizability is a **boundary quantity**: it does not depend on how much foam there is, only on how much of the foam sits on the edge of itself. A branch locus can be enormous and metrically harmless (if it is open), or a single isolated point and already fatal — one doubled origin gives defect exactly $2$.

## Randomness: the foam has a density

Wheeler's foam is stochastic. Model that: fix a Planck spacing $\ell$, take $N$ cells, and let each cell independently bifurcate with probability $p$. A configuration is a subset $A$ of excited cells, with weight
$$w(A) = \prod_{i} \big( p \ \text{if } i \in A, \ 1-p \ \text{otherwise} \big).$$

Three exact computations follow.

First, **when is the foam smooth?** It is Hausdorff exactly when *no* cell is excited, so
$$\Pr[\text{foam is Hausdorff}] = (1-p)^N \le e^{-pN}.$$
Smoothness is exponentially improbable in the number of Planck cells. Over a macroscopic length $L$, the expected number of branch points is $\approx pL/\ell$, which diverges as $\ell \to 0^+$: shrink the Planck length and the foam becomes infinitely fine.

Second, **entropy**. The Shannon entropy of the configuration measure over $n$ cells is exactly
$$H = n\,\mathcal{H}(p), \qquad \mathcal{H}(p) = -p\log p - (1-p)\log(1-p),$$
so entropy is perfectly *extensive* — one cell, one contribution — and bounded by $n \log 2$, with equality precisely at the maximally foamy value $p = \tfrac12$. **One bit per Planck cell**, exactly the holographic-flavoured bookkeeping one hopes for.

And there is a duality lurking. Count the points of the foam directly: it has $|S^c| + |S| \cdot |\iota|$ points, that is, $|S|\,(|\iota| - 1)$ *more* than its macroscopic shadow — one extra point per branch point per extra sheet. Call that the **excess**. Then at $p = \tfrac12$ the entropy satisfies
$$H = \log\big(2^{\,\text{excess}}\big).$$
The information content of the foam is exactly the logarithm of the number of geometries its branch bits can produce. Geometry and information agree on the nose, with no error term.

Third, **concentration**. Computing the second moment of the branch count exactly gives $np(1-p) + (np)^2$, hence variance $np(1-p)$, hence by Chebyshev:
$$\Pr\Big[\,\big|\tfrac{\#\text{branch points}}{N} - p\big| \ge \varepsilon \,\Big] \le \frac{p(1-p)}{N\varepsilon^2}.$$
As the number of Planck cells in a region grows, the observed **branch density becomes deterministic**. A macroscopic observer sees a fixed, sharp foam density $p$ even though every individual cell is a coin flip. This is the mechanism by which a wildly fluctuating microstructure can present a stable effective description — the same mechanism that makes thermodynamics work.

## Coarse-graining: the foam never goes away

Finally, what happens when you look at the foam through blurrier glasses? Shrinking the branch locus is realised by a canonical continuous surjection between foams, and these maps compose, so branch loci form a renormalisation tower. Each step loses information exactly when it erases a branch point.

Run the physical flow on the line: start with the lattice foam of spacing $\ell$, branch locus $\{\ell n : n \in \mathbb{Z}\}$, and halve the resolution, $\ell \mapsto 2\ell$. What are the fixed points?

One might guess: only the empty foam (smooth spacetime) and the totally foamy one. That guess is **wrong**, and provably so.

> **Renormalisation Theorem.** The scale-halving flow fixes the lattice foam of spacing $\ell$ if and only if $\ell = 0$ — that is, the only fixed lattice foam is the single-branch-point foam $S = \{0\}$. Moreover, for any nonzero spacing, the intersection of all rescalings is exactly $\{0\}$: the tower converges not to smooth spacetime but to a foam with one Planck branch point, which is still non-Hausdorff, with metric defect exactly $2$.

So Wheeler foam is **renormalisation-persistent**. Coarse-graining a lattice foam thins it out forever but never sterilises it: at the end of the flow one doubled point remains, and one doubled point is enough to destroy the metric. You cannot blur your way back to a smooth manifold.

## What to take away

None of this proves that spacetime *is* foam. It is a model, and a deliberately austere one — no metric, no dynamics, no quantum amplitudes, just topology and a coin flip per cell. But austere models are where you find out which of your intuitions were theorems and which were wishes.

What the model says is this. Branching at the Planck scale is compatible with everything we see: the foam is locally Euclidean, path-connected, $T_1$, and utterly invisible to continuous number-valued measurement. It carries a gauge symmetry that is faithful exactly when the foam is real and trivial on everything observable. Its failure to be a metric space is a boundary count, not a volume count. Its information content is one bit per cell and equals the logarithm of its own geometric excess. Its branch density is macroscopically deterministic. And it is stable under coarse-graining in the strongest possible sense: the flow has a nontrivial, still-branching fixed point.

Wheeler wrote that at the Planck scale spacetime resembles "a foam of ever-changing curvature and topology." The mathematics suggests he was right about something sharper: the foam is not a wilder version of the manifold we know. It is a space where the question "which point is this?" has more than one answer, and where — remarkably — nothing you could ever measure would tell you the difference.
