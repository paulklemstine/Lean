# Certified Adversarial Robustness via Sheaf Cohomology

## Abstract

We develop a topological account of certified adversarial robustness for classifiers that are piecewise linear over their input space. Two ingredients are isolated and shown to be independent. The first is a *local* (stalk) certificate: for a linear score $s_w(x) = \sum_i w_i x_i$ measured against $L^\infty$ perturbations, the exact Lipschitz constant is the weight $L^1$ norm $\|w\|_1$, and a point $x_0$ whose margin satisfies $\|w\|_1 \cdot r < |s_w(x_0)|$ has its predicted sign invariant on the entire $L^\infty$ ball of radius $r$; the tight certified radius is $|s_w(x_0)|/\|w\|_1$. The second is a *global* gluing law governed by the first Čech cohomology of the nerve of the region cover. On a tree-shaped (path) nerve the first cohomology vanishes — every prescribed overlap discrepancy is the coboundary of a global potential — so local certificates always assemble into one global certificate. On a loop-shaped (cyclic) nerve the first cohomology is nontrivial: the unit discrepancy cochain has loop holonomy $n+1 \ne 0$ and is not a coboundary, an ineliminable obstruction we identify as the cohomological signature of an adversarial cycle. Our main theorem combines the two: on a tree cover with a uniform per-region margin, every region is $L^\infty$-stable within a common radius $R$ and every overlap discrepancy glues. We conclude that certification factors as *stalk margin* $\times$ *nerve acyclicity*, and that these two failure modes are logically independent.

## 1. Introduction

A binary classifier is *certifiably robust* at an input $x_0$ with radius $R$ if its output label is provably constant on the ball of radius $R$ about $x_0$. For high-stakes deployments, such certificates are far more valuable than empirical accuracy against known attacks, because they rule out *all* perturbations within the radius, including attacks not yet invented.

For a single linear score the certified radius is classical and exact. The difficulty is *globalization*. A piecewise-linear network (for instance, one built from rectified-linear units) partitions its input domain into activation regions; inside each region the network is exactly affine, hence governed by a local linear score and a local certificate. The regions overlap, and an honest global certificate requires the local certificates to be *mutually consistent on overlaps* and to *assemble into a single global section*. This is precisely the situation that sheaf theory and Čech cohomology were built to analyze: local data, restriction to overlaps, and the obstruction to gluing.

This paper makes the analogy exact and provable in the simplest faithful setting. We prove (i) the tight $L^\infty$ stalk certificate, (ii) vanishing of first cohomology on tree-shaped nerves with an explicit gluing primitive, and (iii) nonvanishing of first cohomology on loop-shaped nerves via an explicit non-coboundary. We then combine (i) and (ii) into a single global certification theorem and contrast it with the cyclic obstruction. The conceptual payoff is a clean factorization of robustness into an independent local axis (margin) and global axis (cover topology).

## 2. Setup and definitions

Throughout, the input space is $\mathbb{R}^d$ with the $L^\infty$ metric $\|x\|_\infty = \max_{i} |x_i|$.

**Definition 2.1 (Linear score and classifier).** Given a weight vector $w \in \mathbb{R}^d$, the *linear score* is
$$ s_w(x) = \sum_{i=1}^d w_i x_i. $$
The associated binary classifier outputs the sign of $s_w(x)$; we encode the label by the predicate $[\,s_w(x) > 0\,]$.

**Definition 2.2 (Weight $L^1$ norm).** $\|w\|_1 = \sum_{i=1}^d |w_i|$.

**Definition 2.3 (Margin).** The *margin* of $w$ at a reference point $x_0$ is $|s_w(x_0)|$, the distance of the score from the decision threshold $0$.

**Definition 2.4 ($L^\infty$ ball / coordinate ball).** For radius $r \ge 0$, the closed $L^\infty$ ball about $x_0$ is $\{x : |x_i - x_0{}_{,i}| \le r \text{ for all } i\}$.

**Definition 2.5 (Cover and nerve).** A finite open cover $\{U_0, \dots, U_n\}$ of the input domain has a *nerve*, the abstract simplicial complex whose $k$-simplices are the $(k{+}1)$-fold nonempty intersections of cover elements. We work with two combinatorial shapes:
- the *path nerve*, with vertices $0, \dots, n$ and edges $\{i, i{+}1\}$ for $0 \le i < n$ (a tree);
- the *loop nerve* (cyclic nerve), with the same vertices and edges plus the closing edge $\{n, 0\}$ (a single cycle).

**Definition 2.6 (Cochains and coboundaries).** A *$0$-cochain* assigns a real number to each vertex (region); a *$1$-cochain* assigns a real number to each edge (overlap). On the path nerve the coboundary operator $\delta^0$ sends a $0$-cochain $f$ to the $1$-cochain
$$ (\delta^0 f)_i = f_{i+1} - f_i \qquad (0 \le i < n). $$
On the loop nerve the cyclic coboundary $\delta^{\mathrm{cyc}}$ adds the closing edge:
$$ (\delta^{\mathrm{cyc}} f)_i = f_{i+1 \bmod (n+1)} - f_i \qquad (0 \le i \le n). $$
A $1$-cochain $g$ is a *coboundary* if $g = \delta f$ for some $0$-cochain $f$; the *first cohomology* $H^1$ is the quotient of $1$-cochains by coboundaries. (In these one-dimensional nerves all $1$-cochains are cocycles, so $H^1$ measures exactly the failure to be a coboundary.)

**Definition 2.7 (Holonomy).** On the loop nerve, the *holonomy* of a $1$-cochain $g$ is its total around the cycle, $\sum_{i=0}^{n} g_i$.

**Interpretation.** A $0$-cochain is a candidate *global potential* — one consistent scalar reconciliation per region. A $1$-cochain is a prescribed pattern of *overlap discrepancies* between neighboring local certificates. Gluing the local certificates is exactly the problem of realizing a given $1$-cochain as a coboundary $\delta f$.

## 3. The stalk certificate: exact $L^\infty$ robustness of a linear score

**Lemma 3.1 ($L^\infty$ Lipschitz bound, tight).** For all $x, y \in \mathbb{R}^d$ and $r \ge 0$, if $|x_i - y_i| \le r$ for every $i$, then
$$ |s_w(x) - s_w(y)| \le \|w\|_1 \cdot r. $$

*Proof.* By linearity $s_w(x) - s_w(y) = \sum_i w_i (x_i - y_i)$. The triangle inequality for finite sums gives $|s_w(x) - s_w(y)| \le \sum_i |w_i|\,|x_i - y_i|$. Bounding each $|x_i - y_i| \le r$ and factoring yields $\sum_i |w_i| \, r = \|w\|_1 r$. $\quad\blacksquare$

The constant is the dual-norm pairing: the dual of $\|\cdot\|_\infty$ is $\|\cdot\|_1$, and equality is attained by the perturbation $\Delta x_i = r \cdot \operatorname{sign}(w_i)$, so $\|w\|_1$ is the *exact* Lipschitz constant, not merely an upper bound.

**Theorem 3.2 (Sign stability / stalk certificate).** Fix $w$, a reference $x_0$, and $r \ge 0$ with the strict margin condition
$$ \|w\|_1 \cdot r < |s_w(x_0)|. $$
Then for every $x$ in the $L^\infty$ ball of radius $r$ about $x_0$, $s_w(x)$ has the same sign as $s_w(x_0)$; in particular the predicate $[\,s_w(x) > 0\,]$ is constant on the ball.

*Proof.* By Lemma 3.1, $|s_w(x) - s_w(x_0)| \le \|w\|_1 r < |s_w(x_0)|$. If $s_w(x_0) > 0$ then $s_w(x) > s_w(x_0) - |s_w(x_0)| = 0$; if $s_w(x_0) < 0$ then $s_w(x) < s_w(x_0) + |s_w(x_0)| = 0$. Either way the sign is preserved, equivalently $[\,s_w(x) > 0\,] = [\,s_w(x_0) > 0\,]$. $\quad\blacksquare$

**Corollary 3.3 (Certified radius and positivity).** If $|s_w(x_0)| > 0$ and $\|w\|_1 > 0$, the largest radius certified by Theorem 3.2 is
$$ R = \frac{|s_w(x_0)|}{\|w\|_1} > 0, $$
and this radius is strictly positive. Any $r < R$ satisfies the margin condition and is therefore certified.

*Proof.* The condition $\|w\|_1 r < |s_w(x_0)|$ is equivalent to $r < |s_w(x_0)|/\|w\|_1$ since $\|w\|_1 > 0$. Positivity of the quotient follows from positivity of numerator and denominator. $\quad\blacksquare$

We call $R = |s_w(x_0)|/\|w\|_1$ the *stalk radius* of the region. The certificate is intrinsically *local*: it guarantees a ball about one reference point, with no claim about how neighboring regions' balls interact.

## 4. The gluing law: first cohomology of the nerve

We now analyze when local certificates, presented as a $1$-cochain of overlap discrepancies, assemble into a global potential.

**Theorem 4.1 (Vanishing $H^1$ on the path nerve).** On the path nerve with vertices $0, \dots, n$ and edges $\{i, i{+}1\}$, the coboundary $\delta^0$ is surjective: for every $1$-cochain $g$ there exists a $0$-cochain $f$ with $\delta^0 f = g$. Hence $H^1(\text{path nerve}) = 0$.

*Proof (constructive).* Define $f$ by partial sums: $f_0 = 0$ and, for $1 \le k \le n$, $f_k = \sum_{i=0}^{k-1} g_i$. Then for each edge $i$, $(\delta^0 f)_i = f_{i+1} - f_i = g_i$ by telescoping. Thus $\delta^0 f = g$. Since every $1$-cochain is a coboundary, the quotient defining $H^1$ is trivial. $\quad\blacksquare$

The map $g \mapsto f$ is an explicit *gluing primitive*: it reconciles any prescribed overlap discrepancy on a tree-shaped cover. The surjectivity is genuine, not vacuous — a global potential is produced for every input.

**Theorem 4.2 (Nonvanishing $H^1$ on the loop nerve).** On the loop nerve of $n+1$ regions, a $1$-cochain $g$ is a coboundary $\delta^{\mathrm{cyc}} f$ only if its holonomy $\sum_{i=0}^{n} g_i$ vanishes. Consequently the unit cochain $g \equiv 1$, whose holonomy equals $n + 1 \neq 0$, is *not* a coboundary, and $H^1(\text{loop nerve}) \neq 0$.

*Proof.* For any $0$-cochain $f$, summing the cyclic coboundary around the loop telescopes:
$$ \sum_{i=0}^{n} (\delta^{\mathrm{cyc}} f)_i = \sum_{i=0}^{n} \big(f_{i+1 \bmod (n+1)} - f_i\big) = 0, $$
because each value $f_j$ appears once with a $+$ sign and once with a $-$ sign. Hence any coboundary has zero holonomy. The constant cochain $1$ has holonomy $\sum_{i=0}^{n} 1 = n + 1 > 0$, so it cannot be a coboundary; its class is nonzero in $H^1$. $\quad\blacksquare$

The holonomy is a single scalar that completely captures the obstruction on a one-cycle nerve: a loop $1$-cochain glues if and only if its holonomy is zero, and the residual holonomy is the nonzero cohomology class.

## 5. Main results: the global certificate and its obstruction

**Theorem 5.1 (Global certification on a tree cover).** Let the input domain be covered by activation regions $0, \dots, n$ arranged in a path nerve, region $i$ governed by a linear score $s_{w_i}$ with reference point $x_0^{(i)}$. Fix a common radius $R \ge 0$ and suppose the *uniform margin condition* holds:
$$ \|w_i\|_1 \cdot R < |s_{w_i}(x_0^{(i)})| \qquad \text{for every region } i. $$
Then:
1. **(Stalk certificates.)** For every region $i$ and every $x$ in the $L^\infty$ ball of radius $R$ about $x_0^{(i)}$, the prediction is unchanged: $[\,s_{w_i}(x) > 0\,] = [\,s_{w_i}(x_0^{(i)}) > 0\,]$.
2. **(Gluing / vanishing $H^1$.)** Every $1$-cochain $g$ of overlap discrepancies admits a global potential $f$ with $\delta^0 f = g$.

The certified global radius is therefore $R$, valid simultaneously on every region.

*Proof.* Part 1 is Theorem 3.2 applied region by region with the uniform margin hypothesis. Part 2 is Theorem 4.1. The two parts are independent and together certify radius $R$ globally. $\quad\blacksquare$

**Theorem 5.2 (Cyclic cover hosts an unremovable obstruction).** On the loop nerve of $n+1$ regions, there is no global potential $f$ with $\delta^{\mathrm{cyc}} f \equiv 1$; i.e. the unit overlap-discrepancy cochain cannot be glued away. This nonzero first-cohomology class, of holonomy $n+1$, is the cohomological signature of an adversarial cycle.

*Proof.* Immediate from Theorem 4.2: the holonomy $n+1 \neq 0$ rules out any coboundary representation. $\quad\blacksquare$

**Theorem 5.3 (Factorization of certified robustness).** Combining the above, a global certificate of radius $R$ exists when (a) every stalk clears the margin $\|w_i\|_1 R < |s_{w_i}(x_0^{(i)})|$ *and* (b) the nerve of the cover is acyclic ($H^1 = 0$). The two conditions are independent: (a) is a per-region (local) quantity blind to cover topology, while (b) is a global topological quantity blind to any single region's margin.

*Discussion.* The certified radius factors conceptually as
$$ \text{global certificate} \;=\; (\text{stalk margin}) \,\times\, (\text{nerve acyclicity}). $$
The surviving logical implication is *vanishing $H^1 \Rightarrow$ glueability*. The converse fails: a tree cover (with $H^1 = 0$) can still host a vulnerable point if some stalk margin is too small. Cohomology controls *gluing*, never the stalk margin. Thus margin-maximizing training, which acts only on axis (a), cannot by itself remove vulnerabilities that live on axis (b).

## 6. Algorithms

**Algorithm A (Stalk certified radius).** Given $w$ and $x_0$, compute the score $s = \sum_i w_i x_{0,i}$, the norm $N = \sum_i |w_i|$, and return $R = |s|/N$ (with $R = +\infty$ if $N = 0$ and $s \neq 0$, and $R = 0$ if $s = 0$). Complexity $O(d)$. Correctness is Corollary 3.3.

**Algorithm B (Tree gluing primitive).** Given a $1$-cochain $g = (g_0, \dots, g_{n-1})$ on a path nerve, return the partial-sum potential $f$ with $f_0 = 0$, $f_{k} = f_{k-1} + g_{k-1}$. Then $\delta^0 f = g$ exactly. Complexity $O(n)$. Correctness is Theorem 4.1.

**Algorithm C (Holonomy obstruction test).** Given a $1$-cochain $g$ on a loop nerve, return the holonomy $h = \sum_{i=0}^{n} g_i$. The cochain glues (is a coboundary) if and only if $h = 0$; otherwise $h$ is the irreducible obstruction. Complexity $O(n)$. Correctness is Theorem 4.2.

**Algorithm D (Global certificate on a tree cover).** Given per-region $(w_i, x_0^{(i)})$ and a candidate $R$: verify $\|w_i\|_1 R < |s_{w_i}(x_0^{(i)})|$ for all $i$ (each $O(d)$); if all pass, accept $R$ as a global certified radius and emit the tree gluing primitive for any required overlap reconciliation. Complexity $O(nd)$. Correctness is Theorem 5.1.

## 7. Applications

- **Combining per-region certificates.** Certified-defense pipelines that already decompose a network into linear regions can use Theorem 5.1 to fuse per-region certificates into one global radius equal to the minimum stalk radius — provided the region-adjacency nerve is acyclic.
- **Cover refinement as a defense.** Theorem 5.2 identifies cycles as the obstruction. Spanning-tree sparsification of the region-adjacency graph removes cycles cheaply, converting fragile local guarantees into a global guarantee (Theorem 5.1).
- **Diagnosing residual vulnerability.** When margin-maximizing training leaves a model attackable, Theorem 5.3 predicts the residual weakness lives in cover topology (nonzero holonomy), not in the margins — a falsifiable, actionable diagnosis.

## 8. Discussion and limitations

The framework is deliberately minimal: one-dimensional nerves (path and loop) make the cohomology computation transparent and the obstruction a single scalar. The honest scope is the implication *acyclicity $\Rightarrow$ glueability*; we do *not* claim *vulnerability $\Rightarrow$ nonzero cohomology*, which is false in general (a tree cover with a thin stalk is vulnerable yet acyclic). The two axes — stalk margin and nerve cohomology — are genuinely independent, which is both the central insight and the principal caveat: hardening a model requires acting on both.

## 9. Future directions

**(1) Holonomy lower-bounds the adversarial budget.** For a piecewise-linear classifier whose activation regions form a loop, the smallest perturbation flipping the prediction around the loop should be bounded below by the loop's holonomy divided by the largest local sensitivity; the certified radius around the whole loop is then governed by a single first-cohomology class. The inconsistency of local certificates around a cycle is concentrated in one scalar — the holonomy — so the hardest adversarial direction is the one that integrates this class around the loop.

**(2) Acyclic covers admit a uniform global certificate.** Whenever the nerve is acyclic, the per-region certified radii should assemble into a global certified radius equal to their minimum, with no loss from gluing — vanishing first cohomology turns the family of local certificates into a genuine global section, making certification a worst-case minimum rather than a fragile chain of overlap compatibilities. Cycle-removing cover refinements (spanning-tree sparsification of region-adjacency graphs) are a cheap, testable engineering lever.

**(3) Cohomology controls gluing, margin controls stalks — and they are independent.** Robustness failure should factor into two independent causes: a small stalk margin (local, invisible to nerve cohomology) and a nonzero nerve holonomy (global, invisible to any single region). Neither implies the other, and a classifier is globally robust iff both vanish at the relevant scale. Empirically, margin-maximizing training still leaves models vulnerable; the conjecture predicts the residual vulnerability lives in cover topology.
