# Cohomological Gluing Does Not Alone Certify Adversarial Robustness

## A finite cellular counterexample and a quantitative margin–Lipschitz replacement

**Author:** Aristotle  
**Date:** 2026-08-01

## Abstract

We examine the proposed principle that vanishing first sheaf cohomology on a cover of neural-network weight space should imply a positive certified adversarial radius. In its unrestricted form, the principle is false. We give an explicit finite cellular counterexample. For the constant real sheaf on two charts joined by one overlap, the degree-zero coboundary is $\delta(a,b)=b-a$ and is surjective, so first cohomology vanishes. Independently, the one-dimensional threshold score $f(t)=t$ at $t=0$ has no positive strict $L^\infty$ robustness radius: for every $r>0$, the point $r/2$ lies inside the radius-$r$ ball and has the opposite decision. Thus qualitative gluing on a bare weight-space cover cannot by itself determine a quantitative input-space margin.

We then formulate two constructive replacements. First, the vulnerability stalk at an input and radius is the set of label-changing perturbations in the corresponding strict $L^\infty$ ball; its emptiness is equivalent to certification. Second, if a score has positive margin $m$, obeys a local $L$-Lipschitz estimate, and satisfies the strict budget $Lr<m$, then $r$ is a certified radius. We give proofs, algorithms for affine scores and sampled diagnostics, numerical examples, and a research program for classifier-dependent, quantitative sheaves. The results isolate the missing parameter-to-input and qualitative-to-quantitative bridges required by any cohomological robustness theory.

## 1. Introduction

Adversarial robustness asks whether a classifier’s prediction remains unchanged under a prescribed family of small input perturbations. For a norm-based threat model, a local certificate at an input $x$ supplies a radius $r$ such that every point in the open ball of radius $r$ receives the same label as $x$. Such certificates are quantitative: they depend on the classifier, the selected input, the metric, and numerical separation from the decision boundary.

Sheaf theory suggests a different but potentially complementary language. A sheaf records local data and the consistency conditions required to combine those data globally. First cohomology detects an obstruction to gluing local descriptions. Neural networks naturally admit local decompositions—parameter charts, activation regions, and overlapping affine pieces—so it is reasonable to ask whether vanishing cohomology can entail robustness.

There is, however, a type mismatch between the premise and the desired conclusion. Ordinary cohomological vanishing is qualitative, whereas a certified radius is quantitative. Moreover, cohomology on weight space concerns parameter organization, while an adversarial radius concerns input-space decisions. Unless the sheaf and its restriction maps encode the classifier’s margins, sensitivities, and parameter-to-input behavior, no logical mechanism links these two domains.

This paper resolves the unrestricted claim with the smallest nontrivial cellular model. A graph with two vertices and one edge supports a constant real sheaf whose first cohomology vanishes. The vanishing is witnessed explicitly, not inferred statistically. Yet a threshold classifier remains maximally vulnerable at its boundary. This establishes that vanishing $H^1$ on a bare cover cannot imply robustness for arbitrary scores.

The negative result leads directly to a corrected positive theorem. A positive score margin gives distance in output space from the decision threshold. A local Lipschitz estimate converts input displacement into a bound on score displacement. Their ratio supplies a scale. The strict inequality $Lr<m$ then certifies the entire open ball.

The contributions are:

1. an exact formulation of strict-radius binary certification in $L^\infty$;
2. a vulnerability stalk whose emptiness is exactly equivalent to certification;
3. an explicit computation of vanishing first cohomology for a two-chart constant cellular sheaf;
4. a universal counterexample showing that this vanishing does not force any positive robustness radius;
5. a margin–Lipschitz certificate with a direct proof and computable affine specialization;
6. a framework for future classifier-dependent and quantitative sheaf constructions.

## 2. Decision rules, metrics, and certification

### 2.1 Binary scores

Let $X$ be an input space and let $f:X\to\mathbb R$ be a score. Define the binary decision map $D_f:X\to\{-,+\}$ by

$$
D_f(x)=
\begin{cases}
+, & f(x)>0,\\
-, & f(x)\le 0.
\end{cases}
$$

The convention at zero is important in the boundary counterexample, although assigning zero to the positive class would lead to an analogous construction using a negative perturbation.

### 2.2 Strict-radius certificates

Let $d:X\times X\to\mathbb R$ be a distance model. We say that $f$ is **certified at $x$ with strict radius $r$** if

$$
\forall y\in X,\qquad d(x,y)<r\implies D_f(y)=D_f(x).
$$

No positivity condition on $r$ is built into this definition; a meaningful positive certificate additionally requires $r>0$. Separating these notions makes the universal counterexample precise: it denies the existence of any $r>0$ satisfying the certificate.

For $X=\mathbb R^n$, the adversarial metric used throughout is

$$
d_\infty(x,y)=\|x-y\|_\infty=\max_{1\le i\le n}|x_i-y_i|.
$$

In one dimension this reduces to $d_\infty(x,y)=|x-y|$.

### 2.3 Vulnerability stalks

The word “stalk” emphasizes that adversarial behavior is localized at a chosen center and scale.

**Definition 2.1 (Vulnerability stalk).** For a score $f:\mathbb R^n\to\mathbb R$, a center $x\in\mathbb R^n$, and a radius $r\in\mathbb R$, define

$$
\mathcal V_f(x,r)=
\left\{y\in\mathbb R^n:
\|x-y\|_\infty<r\ \text{and}\ D_f(y)\ne D_f(x)
\right\}.
$$

This set records all adversarial examples strictly inside the selected ball. It gives an exact obstruction rather than a sufficient proxy.

**Theorem 2.2 (Emptiness–certification equivalence).** The vulnerability stalk $\mathcal V_f(x,r)$ is empty if and only if $f$ is certified at $x$ with strict radius $r$.

**Proof sketch.** If $\mathcal V_f(x,r)$ contains $y$, then $y$ lies inside the ball and changes the decision, contradicting certification. Conversely, if certification fails, there exists a $y$ inside the ball with a different decision; this $y$ belongs to $\mathcal V_f(x,r)$. $\square$

This theorem can be viewed as a specification for any adversarial search procedure. Finding one member refutes certification. Failure to find a member by finite sampling does not establish emptiness, which is why analytic bounds remain necessary.

### 2.4 Monotonicity with respect to radius

Although not needed for the counterexample, the definition immediately implies a useful structural observation. If $0\le r_1\le r_2$, then

$$
\mathcal V_f(x,r_1)\subseteq\mathcal V_f(x,r_2).
$$

Thus vulnerability can only accumulate as the ball expands. Dually, certification at radius $r_2$ implies certification at every smaller radius $r_1$. This nested behavior motivates a future presheaf over input balls, discussed in Section 9.

## 3. The two-chart constant cellular sheaf

### 3.1 Cellular model

Consider a graph consisting of vertices $v_0,v_1$ and a single oriented edge $e$ from $v_0$ to $v_1$. Interpret the vertices as two charts and the edge as their overlap. Place a copy of $\mathbb R$ on each cell, with identity restriction maps. This is the constant real cellular sheaf on the graph.

The degree-zero and degree-one cochain spaces are

$$
C^0=\mathbb R\times\mathbb R,
\qquad
C^1=\mathbb R.
$$

A zero-cochain $(a,b)$ assigns values to the two charts. The cellular coboundary measures their oriented discrepancy on the overlap:

$$
\delta:C^0\to C^1,
\qquad
\delta(a,b)=b-a.
$$

Since there are no two-cells, the next coboundary is zero. Consequently,

$$
H^1=\frac{C^1}{\operatorname{im}\delta}.
$$

The first cohomology vanishes precisely when $\delta$ is surjective.

### 3.2 Exact vanishing

**Theorem 3.1 (Vanishing first cohomology on one edge).** The constant real cellular sheaf on two vertices joined by one edge has $H^1=0$.

**Proof sketch.** Let $c\in C^1=\mathbb R$ be arbitrary. Select the zero-cochain $(0,c)$. Then

$$
\delta(0,c)=c-0=c.
$$

Every one-cochain lies in the image of $\delta$, so $\delta$ is surjective and $C^1/\operatorname{im}\delta=0$. $\square$

This argument gives a right inverse $c\mapsto(0,c)$ for the coboundary. It is uniform over all real cochains and requires no sampling.

### 3.3 Interpretation and limitation

The vanishing says that every discrepancy on the overlap is a coboundary. In this minimal model there is no residual degree-one obstruction to realizing overlap data from chart values. Yet the cochain complex contains no score function, input point, norm, margin, or sensitivity constant. Therefore its vanishing cannot distinguish a classifier far from its decision boundary from one exactly on the boundary.

## 4. A classifier with no positive certificate

Consider the real-line score

$$
f(t)=t.
$$

Its decision is negative for $t\le0$ and positive for $t>0$. The point $x=0$ lies exactly on the decision boundary and receives the negative class.

**Theorem 4.1 (Threshold boundary has zero certified radius).** For the score $f(t)=t$ at $x=0$, there exists no positive radius $r$ for which the classifier is certified under the distance $|x-y|$.

**Proof sketch.** Suppose $r>0$. Set $y=r/2$. Then

$$
|0-y|=\frac r2<r,
$$

so $y$ lies strictly inside the proposed ball. However, $f(0)=0$ gives the negative decision while $f(y)=r/2>0$ gives the positive decision. Therefore radius $r$ is not certified. Since the construction applies to every $r>0$, no positive certificate exists. $\square$

Equivalently, $r/2\in\mathcal V_f(0,r)$ for every $r>0$. This is stronger than observing failures on a finite list of radii.

## 5. Failure of the unrestricted cohomological implication

We can now combine two independent exact statements: the cellular sheaf has vanishing $H^1$, and the threshold score has no positive certificate.

**Theorem 5.1 (Cohomological vanishing alone does not imply robustness).** There exists a two-chart constant real cellular sheaf with vanishing first cohomology and a real-valued classifier that has no positive strict $L^\infty$ certified radius at a specified input.

**Proof sketch.** Use the sheaf of Theorem 3.1 and the threshold classifier of Theorem 4.1. The former has $H^1=0$ because $(a,b)\mapsto b-a$ is surjective; the latter has no positive certificate at zero because $r/2$ changes the decision inside every positive radius-$r$ ball. $\square$

A stronger logical formulation rules out a universal implication.

**Corollary 5.2 (Universal conjecture is false).** The following statement is false: if the two-chart constant sheaf has vanishing $H^1$, then every score $f:\mathbb R\to\mathbb R$ admits a positive certified radius at zero.

**Proof sketch.** The premise holds by Theorem 3.1. Applying the proposed conclusion to $f(t)=t$ would produce a positive certificate at zero, contradicting Theorem 4.1. $\square$

The counterexample does not claim that every classifier-dependent sheaf theory must fail. It shows exactly that cohomology of the *bare* chart cover, detached from score geometry, is insufficient.

## 6. A quantitative replacement theorem

### 6.1 Margin and local sensitivity

Let $f:\mathbb R^n\to\mathbb R$ and fix $x\in\mathbb R^n$. A positive number $m$ is a lower score margin at $x$ when

$$
0<m\le f(x).
$$

Let $L\ge0$. We require the following local Lipschitz estimate on the open ball $B_\infty(x,r)$:

$$
|f(y)-f(x)|\le L\|x-y\|_\infty
\quad\text{whenever}\quad
\|x-y\|_\infty<r.
$$

Only variation relative to the center $x$ is needed. A pairwise Lipschitz estimate throughout the ball is sufficient but stronger than necessary.

### 6.2 Certificate theorem

**Theorem 6.1 (Margin–Lipschitz $L^\infty$ certificate).** Let $f:\mathbb R^n\to\mathbb R$, $x\in\mathbb R^n$, and let $m,L,r\in\mathbb R$. Assume:

1. $m\le f(x)$;
2. $m>0$;
3. $L\ge0$;
4. $Lr<m$;
5. for every $y$ with $\|x-y\|_\infty<r$,
   $$
   |f(y)-f(x)|\le L\|x-y\|_\infty.
   $$

Then $f$ is certified at $x$ with strict radius $r$.

**Proof sketch.** Fix $y$ with $\|x-y\|_\infty<r$. Since $L\ge0$,

$$
L\|x-y\|_\infty\le Lr<m.
$$

The Lipschitz estimate bounds the possible decrease:

$$
f(x)-f(y)\le |f(y)-f(x)|\le L\|x-y\|_\infty<m.
$$

Therefore

$$
f(y)>f(x)-m\ge0.
$$

More directly, combining $f(x)\ge m$ with the strict variation bound gives $f(y)>m-m=0$. Also $f(x)>0$. Hence both points receive the positive class, and the decision is constant throughout the open ball. $\square$

The strict budget is naturally aligned with the strict ball. When $L>0$, every $r<m/L$ satisfying the local estimate is certified. If $L=0$, the estimate forces $f(y)=f(x)$ throughout the ball, and the budget $0<m$ holds for any radius on which the estimate is valid.

### 6.3 Why the hypotheses are substantive

The threshold counterexample has $f(0)=0$, so no positive $m\le f(0)$ exists. The theorem therefore fails for the correct reason: there is no output-space reserve against perturbations. Conversely, a positive margin without sensitivity control is insufficient, because a discontinuous or steeply varying score may cross zero arbitrarily nearby. The margin and Lipschitz hypotheses play complementary roles.

The theorem is one-sided because the chosen center lies in the positive class. A negative-class analogue follows by applying the same reasoning to $-f$. More generally, one may use the absolute decision margin and a bound that prevents crossing zero.

## 7. Algorithms and numerical demonstrations

### 7.1 Exact affine certification

For an affine score

$$
f(x)=b+w^\top x,
$$

Hölder’s inequality gives

$$
|f(y)-f(x)|=|w^\top(y-x)|
\le \|w\|_1\|y-x\|_\infty.
$$

Thus $L=\|w\|_1$ is an exact global $L^\infty$ Lipschitz constant for the linear part.

**Algorithm 7.1 (Affine positive-class certificate).** Given $w$, $b$, and $x$, compute $s=b+w^\top x$ and $L=\sum_i|w_i|$. If $s\le0$, the positive-class theorem does not apply. If $s>0$ and $L>0$, the supremal radius supported by the strict budget is $s/L$, meaning every $r<s/L$ is certified. If $s>0$ and $L=0$, the score is constant and every finite radius is certified.

The computation takes $O(n)$ time and $O(1)$ additional working memory beyond the input arrays.

### 7.2 Two-dimensional example

Let

$$
f(x_1,x_2)=1.2+0.4x_1-0.7x_2
$$

at $x=(0,0)$. Then $f(x)=1.2$ and

$$
L=|0.4|+|-0.7|=1.1.
$$

The strict certificate condition is

$$
1.1r<1.2,
$$

or $r<12/11\approx1.0909$. In particular, $r=1$ is certified. At the extremal corner direction $(-1,1)$, the score at radius $1$ decreases to

$$
1.2-0.4-0.7=0.1>0.
$$

The calculation demonstrates both the theorem and the geometry of dual norms: an $L^\infty$ box couples to the coefficient $L^1$ norm.

### 7.3 Threshold example

For $f(t)=t$ at zero, inspect any radii such as $1$, $0.1$, or $10^{-6}$. The adversarial witnesses $r/2$ are respectively $0.5$, $0.05$, and $5\times10^{-7}$. Each lies strictly inside its ball and has positive score, while the center has negative decision. Numerical output illustrates the symbolic construction, but the proof quantifies over all positive real radii.

### 7.4 Sampling is diagnostic, not certifying

A grid or random search can locate members of $\mathcal V_f(x,r)$ and thereby disprove a candidate certificate. It cannot prove emptiness unless accompanied by a complete covering argument and analytic remainder bounds. This asymmetry is crucial:

- one discovered adversarial point is decisive;
- no adversarial point in a finite sample is inconclusive.

The margin–Lipschitz theorem turns a finite collection of computable bounds into a universal conclusion over an uncountable ball.

## 8. Applications

### 8.1 Local robustness of piecewise-affine networks

On a fixed activation region, a ReLU network is affine. If an $L^\infty$ ball remains inside that region, the affine algorithm yields an exact local sensitivity $\|w_{\mathrm{eff}}\|_1$ for a scalar output gap. If the ball intersects several regions, one may bound each region’s effective linear map and take a valid common upper bound. The theorem then supplies a certificate whenever the margin dominates the worst-case variation.

### 8.2 Multiclass classification

For logits $z_1(x),\ldots,z_k(x)$ and predicted class $c$, define competitor gaps

$$
g_j(x)=z_c(x)-z_j(x),\qquad j\ne c.
$$

The class remains unchanged if every gap stays positive. If $g_j(x)\ge m_j>0$ and each gap has local Lipschitz constant $L_j$, then any radius satisfying

$$
L_jr<m_j\qquad\text{for all }j\ne c
$$

is certified. For positive $L_j$, a common bound is

$$
r<\min_{j\ne c}\frac{m_j}{L_j}.
$$

This is the natural multiclass extension of the scalar theorem, though the present results focus on the binary score.

### 8.3 Organizing local certificates

Sheaf methods may become useful when a network’s domain is partitioned into many activation cells. Each cell can carry a local margin or Lipschitz estimate; intersections can carry compatibility data. The counterexample dictates that these stalks cannot be merely constant scalars unrelated to the classifier. Their restriction maps must preserve the quantitative information needed by the budget $Lr<m$.

## 9. Discussion and future work

### 9.1 Relative cohomology tied to decisions

A classifier-dependent construction could use relative or constructible sheaves whose data depend on labels, score margins, and activation regions. Obstruction classes might then characterize the inability to glue local certificates. The relevant theorem would need to state exactly how vanishing produces a global bound, not merely a global qualitative section.

### 9.2 Quantitative sheaves

Ordinary vanishing discards magnitude. Enriching stalks in normed spaces and equipping restriction maps with operator-norm bounds could retain scale. A bounded contracting homotopy would be more informative than abstract exactness: its norm could propagate local constants and potentially yield a numerical radius.

### 9.3 The parameter-to-input bridge

Weight perturbations and input perturbations are distinct. A useful theory must include an explicit estimate connecting changes in parameters, activation geometry, and input-space score margins. The finite counterexample shows that topology of weight charts alone supplies no such bridge.

### 9.4 Boundary-local presheaves

The family $\mathcal V_f(x,r)$ is nested in $r$. One can refine it into a presheaf over input balls, with restriction induced by inclusion. Its support marks where adversarial examples occur. Degree-zero structure and local cohomology near decision boundaries may describe how vulnerable components emerge as radius increases.

### 9.5 Piecewise-linear activation complexes

ReLU networks induce finite polyhedral activation complexes on bounded domains. Cellular sheaves on these complexes could encode local affine maps and Lipschitz bounds. The research challenge is to combine combinatorial obstruction detection with norm-controlled gluing so that outputs include both obstruction classes and numerical certificates.

### 9.6 Limits of the present model

The two-chart sheaf is intentionally minimal. It does not model a full neural architecture, training dynamics, or a classifier-dependent restriction map. That simplicity is a strength for refuting the unrestricted implication: a universal theorem must cover the minimal case. It is not evidence against richer hypotheses. Likewise, the positive theorem assumes an available local Lipschitz constant; obtaining tight constants for large networks remains a separate computational problem.

## 10. Conclusion

The relationship between topology and adversarial robustness must respect two distinctions: qualitative versus quantitative information, and parameter space versus input space. Vanishing first cohomology for the constant sheaf on two overlapping charts is exact and explicit, yet it coexists with a classifier whose certified radius at a decision boundary is zero. Therefore bare cohomological vanishing cannot imply a positive $L^\infty$ certificate for arbitrary scores.

A correct local guarantee emerges from analytic data. If a score at $x$ has positive lower margin $m$, varies by at most $L\|x-y\|_\infty$ in the relevant ball, and satisfies $Lr<m$, then every point in that ball remains on the positive side of the threshold. Equivalently, the vulnerability stalk is empty.

These results do not eliminate a role for sheaf theory. They specify the role it must play: organizing classifier-dependent, norm-controlled local information while preserving enough magnitude to produce a radius. Topological gluing can be part of a certification pipeline, but the numerical scale must enter through margins, sensitivities, and an explicit bridge to input-space decisions.

A practical consequence is a separation of responsibilities. Combinatorial structure can index regions, intersections, and compatibility constraints; analysis must attach valid inequalities to those objects; and an assembly theorem must show that the inequalities survive passage from local pieces to the complete neighborhood. Each layer has a distinct failure mode. Cohomology may expose incompatible local data, interval or convex methods may bound regional sensitivity, and the final budget comparison determines whether the decision threshold can be reached. Keeping these layers explicit prevents a qualitative invariant from being mistaken for a metric guarantee and offers a testable design criterion for future certification systems.