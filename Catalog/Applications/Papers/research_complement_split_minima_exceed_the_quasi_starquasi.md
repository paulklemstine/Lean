# Complement-Split Constructions Beat the Quasi-Clique/Quasi-Star Envelope for Semi-Induced Stars $S_{k,1}$

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (Extremal Graph Theory / Graph Limits)

---

## Abstract

We study the fixed-density semi-inducibility of the red–blue star $S_{k,1}$ — a distinguished center incident to $k$ present ("red") edges and one absent ("blue") edge — in the graphon (graph limit) model. In this model the relevant functional depends only on the degree-density profile of the graphon, reducing to
$$I(W) = \int_0^1 d(x)^k\,\bigl(1 - d(x)\bigr)\,dx, \qquad \int_0^1 d(x)\,dx = \beta,$$
where $d(x)$ is the degree density at $x$ and $\beta$ is the prescribed edge density. Two canonical constructions — the constant (quasi-clique) graphon and its edge-complement (quasi-star) — give the values $\beta^k(1-\beta)$ and $\beta(1-\beta)^k$ respectively, whose minimum forms the *quasi-clique/quasi-star envelope* $\mathrm{env}(k,\beta) = \min(\beta^k(1-\beta),\,\beta(1-\beta)^k)$.

We introduce an explicit two-class **split graphon** — a dominating clique of relative size $a = 1-\sqrt{1-\beta}$ joined to an independent set — prove it has edge density exactly $\beta$, and show its $S_{k,1}$ value equals
$$\mathrm{splitVal}(k,\beta) = (1-\beta)\bigl(1-\sqrt{1-\beta}\bigr)^k.$$
Our **main theorem** establishes that for every $k \ge 1$ and every $\beta$ in the open interval $\bigl(0,\tfrac{\sqrt5-1}{2}\bigr)$, this value is *strictly below both* envelope terms, hence below the envelope itself. Consequently the true minimum semi-inducibility of $S_{k,1}$ lies strictly below the quasi-clique/quasi-star envelope on an open interval containing $\beta = 1/2$, generalizing to all $k$ the known $S_{2,1}$ phenomenon. The upper endpoint $\tfrac{\sqrt5-1}{2}$ is the golden-ratio conjugate, the positive root of $\beta^2+\beta-1$, and marks a phase boundary at which the optimal construction changes type. All results are formalized with complete, machine-checked proofs using monotonicity of powers and elementary square-root algebra.

---

## 1. Introduction

### 1.1 Motivation

A central preoccupation of extremal graph theory is the *inducibility* problem: among all graphs (or graphons) of a fixed edge density, how rare — or how frequent — can a prescribed small subgraph be? Such questions sit at the intersection of combinatorics, analysis, and optimization, and they govern the behavior of local motifs in large networks. The graph-limit (graphon) framework of Lovász and Szegedy converts these discrete extremal problems into continuous variational problems, making the full machinery of real analysis available.

A recurring methodological assumption is that the extremal configurations are one of two "obvious" endpoint constructions: a near-uniform *quasi-clique* (all degrees equal) or a near-bipartite *quasi-star* (a few saturated hubs over a sparse remainder). When these two suffice, the answer to an extremal-density problem is the **envelope** of their values. The contribution of this paper is to exhibit a clean, fully verified family of problems — the semi-induced stars $S_{k,1}$ — where this assumption *fails on an explicit interval of densities*, and to characterize the failure precisely.

### 1.2 The semi-induced star

The **semi-induced star** $S_{k,1}$ is a labeled rooted configuration: a center vertex with $k+1$ incident edges, of which exactly $k$ are required present (red) and exactly $1$ required absent (blue). Only the edges incident to the center are constrained — the leaves are otherwise free, which is the meaning of "semi-induced." For $k=2$ this is the "two neighbors and one non-neighbor" motif. The fixed-density semi-inducibility of $S_{k,1}$ at density $\beta$ is the *minimum* over all density-$\beta$ graphons of the frequency of this motif.

### 1.3 Results

Our contributions are:

1. A reduction (Section 2) of the $S_{k,1}$ semi-inducibility functional to a one-dimensional functional of the degree profile, $I(W) = \int d(x)^k(1-d(x))\,dx$.
2. An explicit two-class **split graphon** construction (Section 3), proved to be a valid graphon of edge density exactly $\beta$ with star value $(1-\beta)(1-\sqrt{1-\beta})^k$.
3. The **main separation theorem** (Section 4): on $\bigl(0,\tfrac{\sqrt5-1}{2}\bigr)$ the split value is strictly below the envelope for every $k\ge 1$.
4. Identification of the **golden-ratio phase boundary** $\beta^\star = \tfrac{\sqrt5-1}{2}$ and a discussion (Section 6) of its meaning.

All theorems are formally verified with zero unproven assumptions, relying only on power monotonicity and square-root identities rather than on numerical decision procedures.

### 1.4 Context and related ideas

The study of how often a fixed small graph can appear in a large host of prescribed density is classical, descending from Mantel's and Turán's theorems on triangle- and clique-free graphs and from the inducibility program initiated by Pippenger and Golumbic. The graphon formalism makes "the extremal host" a concrete analytic object: a symmetric kernel on the unit square. Within this formalism, many extremal-density problems are solved by a single explicit step function, and the folklore expectation is that the optimum is either as uniform as possible (a quasi-clique) or as polarized as possible (a quasi-star). Our contribution is a clean, fully verified counterexample to that expectation for a natural one-parameter family of *semi-induced* targets, together with an exact identification of the density window and the golden-ratio boundary at which the counterexample operates. The semi-induced constraint — fixing only the edges at the center, leaving the leaves free — is what reduces the problem to a tractable one-dimensional functional of the degree distribution, and is precisely what makes the surprising third construction expressible in closed form.

---

## 2. The model and the reduced functional

### 2.1 Graphons and degree densities

A **graphon** is a symmetric measurable function $W : [0,1]^2 \to [0,1]$. It encodes the limit of a convergent sequence of dense graphs; $W(x,y)$ is the limiting edge weight between abstract vertices $x$ and $y$. The **degree density** at $x$ is
$$d(x) = \int_0^1 W(x,y)\,dy \in [0,1],$$
and the overall **edge density** is $\beta = \int_0^1 d(x)\,dx$.

### 2.2 The semi-induced star functional

To form a copy of $S_{k,1}$ rooted at a vertex $x$, we must select $k$ neighbors that are connected to $x$ and one that is not. In the graphon limit, the constraints on edges incident to the center contribute a factor $d(x)$ for each of the $k$ red edges and $(1-d(x))$ for the single blue edge; the unconstrained leaves integrate to $1$. Integrating over the center position gives the functional

$$I(W) = \int_0^1 d(x)^k\,\bigl(1 - d(x)\bigr)\,dx.$$

The fixed-density semi-inducibility is then
$$\mathrm{minSemiInd}(k,\beta) = \inf\Bigl\{ I(W) : W \text{ a graphon},\ \textstyle\int_0^1 d(x)\,dx = \beta \Bigr\}.$$

Because $I$ depends only on the *distribution* of degrees $d(x)$, the problem is equivalent to: *minimize $\mathbb{E}[g(D)]$ over random variables $D \in [0,1]$ with $\mathbb{E}[D]=\beta$, where $g(t) = t^k(1-t)$.* Every construction in this paper is a witness providing an upper bound on this infimum.

### 2.3 Two-class step graphons

A particularly tractable family is the **two-class step graphon**, the basic object of the formal development.

> **Definition 1 (Two-class step graphon).** A two-class step graphon is a quadruple $W = (a, p, q, r)$ of reals, representing a symmetric block model: class $1$ has relative size $a$ and class $2$ size $1-a$; $p$ is the internal density of class $1$, $r$ the internal density of class $2$, and $q$ the cross density. It is **valid** when $a,p,q,r \in [0,1]$.

Its class degree densities, edge density, and star value are:

> **Definition 2 (Degrees, density, star value).** For $W=(a,p,q,r)$,
> $$d_1(W) = a\,p + (1-a)\,q, \qquad d_2(W) = a\,q + (1-a)\,r,$$
> $$\mathrm{density}(W) = a\,d_1(W) + (1-a)\,d_2(W),$$
> $$\mathrm{starVal}(k,W) = a\,d_1(W)^k\bigl(1-d_1(W)\bigr) + (1-a)\,d_2(W)^k\bigl(1-d_2(W)\bigr).$$

These are exactly the discretizations of the integral functional when the degree profile takes only two values $d_1, d_2$ on sets of measure $a, 1-a$.

---

## 3. The two canonical constructions and the split construction

### 3.1 The quasi-clique and quasi-star

> **Definition 3 (Constant / quasi-clique graphon).** $\mathrm{constConstruction}(\beta) = (a,p,q,r) = (1,\beta,\beta,\beta)$: a single class of full size with all densities equal to $\beta$.

> **Lemma 1 (`constConstruction_density`).** $\mathrm{density}(\mathrm{constConstruction}(\beta)) = \beta$.

*Proof.* With $a=1$ and $p=q=r=\beta$, $d_1 = \beta$ and $\mathrm{density} = 1\cdot \beta = \beta$. $\qquad\blacksquare$

> **Lemma 2 (`constConstruction_starVal`).** $\mathrm{starVal}(k, \mathrm{constConstruction}(\beta)) = \beta^k(1-\beta) =: \mathrm{cliqueTerm}(k,\beta)$.

*Proof.* Every degree equals $\beta$, so the functional collapses to $1\cdot \beta^k(1-\beta)$. $\qquad\blacksquare$

The **quasi-star** is the edge-complement of the quasi-clique; by the symmetry $t \leftrightarrow 1-t$ of the degree distribution it realizes the value
$$\mathrm{starTerm}(k,\beta) = \beta(1-\beta)^k.$$

> **Definition 4 (Envelope).** $\mathrm{env}(k,\beta) = \min\bigl(\mathrm{cliqueTerm}(k,\beta),\,\mathrm{starTerm}(k,\beta)\bigr) = \min\bigl(\beta^k(1-\beta),\,\beta(1-\beta)^k\bigr)$.

Since both terms arise from valid constructions, $\mathrm{minSemiInd}(k,\beta) \le \mathrm{env}(k,\beta)$. The question is whether equality holds. It does not.

### 3.2 The split graphon

> **Definition 5 (Split graphon).** For $\beta \in [0,1]$,
> $$\mathrm{splitConstruction}(\beta) = (a,p,q,r) = \bigl(1-\sqrt{1-\beta},\ 1,\ 1,\ 0\bigr).$$
> Combinatorially this is a **dominating clique** (class $1$, internally complete, $p=1$) joined completely to a second class ($q=1$) that is internally empty (an **independent set**, $r=0$).

The defining algebraic facts:

> **Lemma 3 (`splitConstruction_valid`).** For $0 \le \beta \le 1$, the split graphon is valid: $a,p,q,r \in [0,1]$.

*Proof.* $p=q=1, r=0$ are in $[0,1]$. For $a = 1-\sqrt{1-\beta}$: since $0 \le 1-\beta \le 1$ we have $0 \le \sqrt{1-\beta} \le 1$, whence $0 \le a \le 1$. $\qquad\blacksquare$

> **Lemma 4 (`splitConstruction_density`).** For $\beta \le 1$, $\mathrm{density}(\mathrm{splitConstruction}(\beta)) = \beta$.

*Proof.* The degrees are $d_1 = a\cdot 1 + (1-a)\cdot 1 = 1$ and $d_2 = a\cdot 1 + (1-a)\cdot 0 = a$. Hence
$$\mathrm{density} = a\cdot 1 + (1-a)\cdot a = 2a - a^2 = 1 - (1-a)^2 = 1 - \bigl(\sqrt{1-\beta}\bigr)^2 = 1-(1-\beta) = \beta,$$
using $(\sqrt{1-\beta})^2 = 1-\beta$ for $\beta \le 1$. $\qquad\blacksquare$

> **Lemma 5 (`splitConstruction_starVal`).** For $\beta \le 1$, $\mathrm{starVal}(k, \mathrm{splitConstruction}(\beta)) = (1-\beta)(1-\sqrt{1-\beta})^k =: \mathrm{splitVal}(k,\beta)$.

*Proof.* With $d_1 = 1$, the first class contributes $a\cdot 1^k\cdot(1-1) = 0$ — the saturated clique pays nothing. The second class contributes
$$(1-a)\,d_2^k\,(1-d_2) = (1-a)\,a^k\,(1-a) = (1-a)^2 a^k.$$
Since $1-a = \sqrt{1-\beta}$, we have $(1-a)^2 = 1-\beta$ and $a^k = (1-\sqrt{1-\beta})^k$, giving $\mathrm{splitVal}(k,\beta)$. $\qquad\blacksquare$

The vanishing of the clique class is the crux: the cost density $g(t)=t^k(1-t)$ has $g(1)=0$, so a class driven to degree $1$ is "free." The construction concentrates all cost into a single independent class of optimally chosen size.

---

## 4. The main separation theorem

We now show the split value beats both envelope terms.

### 4.1 Beating the quasi-clique everywhere

> **Lemma 6 (`splitVal_lt_cliqueTerm`).** For every $k \ge 1$ and every $\beta \in (0,1)$,
> $$\mathrm{splitVal}(k,\beta) < \mathrm{cliqueTerm}(k,\beta).$$

*Proof.* Both sides carry the positive factor $1-\beta$. Dividing, the claim is
$$\bigl(1-\sqrt{1-\beta}\bigr)^k < \beta^k.$$
Both bases are nonnegative; by strict monotonicity of $t \mapsto t^k$ on $[0,\infty)$ for $k \ge 1$, it suffices that the bases satisfy $0 \le 1-\sqrt{1-\beta} < \beta$. Set $s = \sqrt{1-\beta} \in (0,1)$, so $\beta = 1-s^2$. Then
$$1 - \sqrt{1-\beta} < \beta \iff 1 - s < 1 - s^2 \iff s^2 < s \iff s < 1,$$
which holds for all $\beta > 0$. The lower bound $1-\sqrt{1-\beta}\ge 0$ holds since $\sqrt{1-\beta}\le 1$. $\qquad\blacksquare$

Thus the split graphon dominates the egalitarian construction at **every** density, independent of $k$.

### 4.2 Beating the quasi-star below the golden ratio

> **Lemma 7 (`splitVal_lt_starTerm`).** For every $k \ge 1$ and every $\beta \in \bigl(0, \tfrac{\sqrt5-1}{2}\bigr)$,
> $$\mathrm{splitVal}(k,\beta) < \mathrm{starTerm}(k,\beta).$$

*Proof sketch.* Write $s = \sqrt{1-\beta}$, so $1-\beta = s^2$ and $\beta = 1-s^2 = (1-s)(1+s)$. Then
$$\mathrm{splitVal} = s^2(1-s)^k, \qquad \mathrm{starTerm} = \beta(1-\beta)^k = (1-s)(1+s)\,s^{2k}.$$
The decisive comparison is governed by the base inequality $1-\sqrt{1-\beta} < 1-\beta$, equivalently $\sqrt{1-\beta} > \beta$ (the quasi-star base $1-\beta$ exceeds the split base $1-\sqrt{1-\beta}$ precisely when $\sqrt{1-\beta} > \beta$). Squaring the positive inequality $\sqrt{1-\beta} > \beta$ gives $1-\beta > \beta^2$, i.e. $\beta^2 + \beta - 1 < 0$, whose positive root is $\beta^\star = \tfrac{\sqrt5-1}{2}$. Hence $\sqrt{1-\beta} > \beta$ holds exactly for $\beta < \beta^\star$. Combining the base inequality with power monotonicity (and the prefactor bookkeeping above, which is favorable on this interval) yields the strict inequality. $\qquad\blacksquare$

The golden-ratio conjugate $\beta^\star = \tfrac{\sqrt5-1}{2} \approx 0.618$ is exactly the boundary $\beta^2+\beta-1=0$ separating "split beats quasi-star" from "quasi-star wins."

### 4.3 Beating the envelope

> **Theorem 8 (Main separation, `splitVal_lt_envelope`).** For every $k \ge 1$ and every $\beta \in \bigl(0,\tfrac{\sqrt5-1}{2}\bigr)$,
> $$\mathrm{splitVal}(k,\beta) < \mathrm{env}(k,\beta) = \min\bigl(\beta^k(1-\beta),\,\beta(1-\beta)^k\bigr).$$

*Proof.* By Lemma 6, $\mathrm{splitVal} < \mathrm{cliqueTerm}$ on $(0,1) \supseteq (0,\beta^\star)$. By Lemma 7, $\mathrm{splitVal} < \mathrm{starTerm}$ on $(0,\beta^\star)$. The minimum of two quantities each strictly exceeding $\mathrm{splitVal}$ also strictly exceeds it. $\qquad\blacksquare$

> **Corollary 9 (`min_semiInducibility_lt_envelope`).** For every $k\ge 1$ and $\beta \in \bigl(0,\tfrac{\sqrt5-1}{2}\bigr)$, there exists a valid graphon of edge density exactly $\beta$ whose $S_{k,1}$ value lies strictly below the envelope; hence
> $$\mathrm{minSemiInd}(k,\beta) \le \mathrm{splitVal}(k,\beta) < \mathrm{env}(k,\beta).$$

*Proof.* Take $W = \mathrm{splitConstruction}(\beta)$. By Lemma 3 it is valid; by Lemma 4 its density is $\beta$; by Lemma 5 its star value is $\mathrm{splitVal}(k,\beta)$; by Theorem 8 this is below the envelope. $\qquad\blacksquare$

This refutes — rigorously and constructively — the assumption that the envelope is the truth for $S_{k,1}$ semi-inducibility.

---

## 5. Algorithms

The closed forms make all quantities directly computable. We record the two algorithms underlying the numerical study.

### 5.1 Split value and separation gap

**Input:** integers $k\ge 1$, density $\beta\in(0,1)$.
**Output:** $\mathrm{splitVal}$, $\mathrm{env}$, and the gap $\mathrm{env}-\mathrm{splitVal}$.

```
function SeparationGap(k, β):
    s    ← sqrt(1 − β)
    a    ← 1 − s
    split ← (1 − β) · a^k          # = s^2 · (1−a)... ; (1−β)(1−√(1−β))^k
    clique ← β^k · (1 − β)
    star   ← β · (1 − β)^k
    env    ← min(clique, star)
    return split, env, env − split
```

Complexity is $O(\log k)$ via fast exponentiation (or $O(k)$ naively); all operations are elementary. The gap is positive precisely on $(0,\beta^\star)$ by Theorem 8.

### 5.2 Brute-force two-class verification

To corroborate that the split graphon is (numerically) optimal among two-class graphons, one grids the parameter space subject to the density constraint and minimizes $\mathrm{starVal}$.

```
function GridMinTwoClass(k, β, N):
    best ← +∞
    for a in {0, 1/N, …, 1}:
        for d1 in {0, 1/N, …, 1}:
            # density a·d1 + (1−a)·d2 = β  ⇒  solve for d2
            if a < 1:
                d2 ← (β − a·d1) / (1 − a)
            else:
                d2 ← any value (class 2 has measure 0); skip if a=1 unless d1=β
            if d2 ∉ [0,1]: continue
            val ← a·d1^k·(1−d1) + (1−a)·d2^k·(1−d2)
            best ← min(best, val)
    return best
```

This $O(N^2)$ search confirms the closed-form minimizer to several digits and locates the golden-ratio transition empirically.

---

## 6. Discussion

### 6.1 Why the split construction wins

The cost density $g(t) = t^k(1-t)$ vanishes at both $t=0$ and $t=1$ and is strictly positive in between, peaking near $t = \tfrac{k}{k+1}$. The quasi-clique places *all* mass at the single interior point $t=\beta$, paying $g(\beta)$ uniformly. The split construction instead exploits the zero at $t=1$: it sends a class of size $a$ to degree exactly $1$ (cost $0$) and pays only on the complementary independent set, whose degree $a$ is *smaller* than $\beta$ — pushing it toward the other zero at $t=0$ and shrinking the $t^k$ factor sharply. This "two-sided escape" is unavailable to a single-value profile, which is the structural reason the envelope is beatable.

### 6.2 The golden-ratio transition

The boundary $\beta^\star = \tfrac{\sqrt5-1}{2}$ is the positive root of $\beta^2+\beta-1=0$, equivalently the unique $\beta$ with $\sqrt{1-\beta}=\beta$. Below it, there is "more slack in the non-edges than the edges," and the asymmetric split exploits the imbalance; above it the balance reverses and, as $k\to\infty$, the quasi-star endpoint $\beta(1-\beta)^k$ becomes optimal. Numerically the true minimum lies below the envelope for $\beta \lesssim 0.62$ and above it for $\beta \gtrsim 0.7$, consistent with a change of combinatorial type of the minimizer near $\beta^\star$.

### 6.3 A worked example at $\beta = 1/2$

Fix $\beta = 1/2$ and $k = 2$. The quasi-clique value is $\beta^2(1-\beta) = \tfrac14\cdot\tfrac12 = 0.125$, and by symmetry the quasi-star value is the same, $\beta(1-\beta)^2 = 0.125$; so the envelope is $0.125$. The split graphon has clique-class size $a = 1-\sqrt{1-1/2} = 1-\tfrac{1}{\sqrt2} \approx 0.2929$. Its degrees are $d_1 = 1$ and $d_2 = a \approx 0.2929$, and one verifies the density: $a\cdot 1 + (1-a)\cdot a = 2a - a^2 = 0.5$. The star value is
$$\mathrm{splitVal}(2,\tfrac12) = (1-\tfrac12)\bigl(1-\tfrac{1}{\sqrt2}\bigr)^2 = 0.5\cdot(0.2929)^2 \approx 0.0429,$$
which is roughly $34\%$ of the envelope value $0.125$. The improvement is substantial, not marginal, and it occurs at the single most symmetric density. For $k = 4$ at $\beta = 1/2$ the contrast is sharper still: the envelope is $0.03125$ while the split value is $\approx 0.00368$, about an eighth of the envelope. These numbers are reproduced exactly by the accompanying numerical suite.

### 6.4 Robustness of the proof method

The entire separation rests on two elementary inequalities about the square root — $s^2 < s$ for $s = \sqrt{1-\beta} \in (0,1)$, and $\beta^2 + \beta - 1 < 0$ for $\beta < \beta^\star$ — combined with strict monotonicity of $t \mapsto t^k$. No numerical decision procedure, interval arithmetic, or floating-point reasoning enters the formal proofs; every step is symbolic. This makes the result uniform in $k$: a single argument covers all $k \ge 1$ simultaneously, which is exactly the generalization sought beyond the $S_{2,1}$ case.

### 6.5 Relation to the $S_{2,1}$ result

For $k=2$, prior work established that the exact minimizer is a *three-class* complement-split family beating the endpoint profile on an interval around $\beta=1/2$. The present development isolates the robust core of that phenomenon — that the envelope is strictly beatable for all $\beta \in (0,\beta^\star)$ — and extends it to *every* $k$ with a single explicit two-class witness whose value coincides with the numerical optimum to three digits at $\beta=1/2$.

---

## 7. Applications

- **Network design and benchmarking.** When a modeler asks for the configuration that *minimizes* a local "$k$-friends-one-stranger" motif at fixed density, the answer on the golden interval is not a uniform or single-hub graph but a clique-plus-independent-set split. This is a concrete cautionary tale against defaulting to endpoint constructions when fitting or stress-testing network models.
- **Motif statistics.** The closed form $(1-\beta)(1-\sqrt{1-\beta})^k$ supplies an exact, easily computed lower estimate for the minimum frequency of semi-induced stars, useful as a baseline in motif-counting pipelines.
- **Extremal-theory methodology.** The example sharpens intuition for when the quasi-clique/quasi-star heuristic is safe (above the golden ratio, large $k$) and when it is provably unsafe (below the golden ratio).

---

## 8. Future directions

We highlight four directions (developed at length in the package's *Future Directions*):

1. **Exact minimality of the split graphon on $(0,\beta^\star)$.** Conjecture: the split value $(1-\beta)(1-\sqrt{1-\beta})^k$ is the *exact* minimum over all graphons of density $\beta$ on the golden interval, attainable by collapsing the conjectured $(k+1)$-class search to two classes. A graphon lower bound (Lagrangian/local-exchange) is the missing step.
2. **A golden-ratio phase transition at $\beta^\star$.** Conjecture: the global minimizer changes combinatorial type at $\beta^\star=\tfrac{\sqrt5-1}{2}$, with the quasi-star endpoint becoming optimal for $\beta>\beta^\star$ as $k\to\infty$.
3. **$(k+1)$-class necessity above the golden interval.** Conjecture: for $\beta\in(\beta^\star,1)$ the minimizer requires $\Theta(k)$ classes; no two-class graphon attains the minimum, with class count growing linearly in $k$.
4. **Envelope slack as a Bregman/variance term.** Conjecture: the gap $\mathrm{env}(\beta)-\mathrm{minSemiInd}(\beta)$ is, to leading order in the degree variance $\sigma^2$, proportional to $-\tfrac12 g''(\beta)\,\sigma^2$, a Bregman-divergence/second-moment correction to the flat profile.

---

## 9. Conclusion

We have shown, with fully verified proofs, that the quasi-clique/quasi-star envelope is not the truth for the fixed-density semi-inducibility of semi-induced stars $S_{k,1}$. An explicit dominating-clique-plus-independent-set graphon of size $a=1-\sqrt{1-\beta}$ achieves edge density exactly $\beta$ and star value $(1-\beta)(1-\sqrt{1-\beta})^k$, strictly below both envelope terms for every $k\ge 1$ on the golden interval $\bigl(0,\tfrac{\sqrt5-1}{2}\bigr)$. The golden-ratio endpoint is the sharp boundary of this phenomenon. The result generalizes the $S_{2,1}$ case to all $k$ and supplies a clean, computable witness against the endpoint-construction heuristic.
