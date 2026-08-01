# When Topology Cannot Guarantee a Robust Neural Network

## A clean counterexample—and the analytic ingredient that actually produces a certificate

A photograph classifier can be right and still be fragile. Change every pixel by an amount too small for a person to notice, and the label may flip from “panda” to “gibbon.” This phenomenon has inspired a search for *certificates*: mathematical guarantees that no allowed perturbation inside a specified neighborhood can alter a model’s decision.

One tempting route comes from topology. Modern neural networks are assembled from local pieces: parameter charts, activation regions, overlapping descriptions, and local computations that must agree where those descriptions meet. Sheaf theory was invented to organize exactly this kind of local-to-global information. Its first cohomology group, written $H^1$, measures a familiar kind of obstruction: local data may look compatible in pairs yet fail to arise from one coherent global object. If $H^1$ vanishes, that obstruction disappears.

Could the disappearance of such a global obstruction force adversarial robustness?

The answer is no—not by itself. A tiny example exposes the missing ingredient. The failure is instructive rather than destructive: it tells us precisely what topology can organize, what it cannot quantify, and how a score margin plus a Lipschitz bound restores a rigorous robustness guarantee.

## What a robustness certificate says

Let a classifier be determined by a real-valued score $f(x)$. It assigns the positive class when $f(x)>0$ and the negative class when $f(x)\le 0$. For finite-dimensional inputs, the natural adversarial distance considered here is the maximum coordinate change,

$$
\|x-y\|_\infty=\max_i |x_i-y_i|.
$$

The classifier is *certified at $x$ with strict radius $r$* if every $y$ satisfying

$$
\|x-y\|_\infty<r
$$

has the same decision as $x$. Strictness matters: the open ball excludes points exactly at distance $r$, avoiding irrelevant boundary conventions.

There is a useful local object hidden in this definition. Define the *vulnerability stalk* at $(x,r)$ to be the set

$$
\mathcal V_f(x,r)=\{y:\|x-y\|_\infty<r\ \text{and the decisions at $x$ and $y$ differ}\}.
$$

Despite the geometric name, this is simply the collection of all adversarial examples inside the chosen ball. It yields an exact criterion.

**Vulnerability–certification equivalence.** The classifier is certified at $x$ with radius $r$ if and only if $\mathcal V_f(x,r)$ is empty.

The reason is immediate but fundamental. If the set contains a point, that point violates certification. Conversely, if certification fails, the point witnessing failure belongs to the set. This equivalence converts robustness from a universal statement—“every nearby point preserves the label”—into the absence of a concrete local obstruction.

## The smallest possible sheaf calculation

Now consider two overlapping parameter charts. Forget every geometric complication and retain only the overlap pattern: two vertices joined by one edge. Put a copy of the real numbers on each chart and on their overlap. A degree-zero section is a pair $(a,b)$, one value on each chart. Its discrepancy on the oriented overlap is

$$
\delta(a,b)=b-a.
$$

Degree-one cohomology vanishes here exactly when every possible overlap value $c$ can be expressed as such a discrepancy. But this is always possible: choose $(a,b)=(0,c)$. Then

$$
\delta(0,c)=c.
$$

Thus the coboundary map is surjective and $H^1=0$. There is no degree-one gluing obstruction in this two-chart constant sheaf.

This calculation is not numerical evidence or a pattern seen in samples. It works uniformly for every real $c$. It gives an exact, complete proof of vanishing.

At first glance, that sounds promising. The local chart data glue perfectly. Yet nothing in the calculation mentions an input point, a class score, a distance to a decision boundary, or the sensitivity of the classifier. The gap becomes decisive in one dimension.

## A boundary that defeats every positive radius

Take the score

$$
f(t)=t
$$

on the real line, with the positive class assigned when $t>0$ and the negative class assigned when $t\le 0$. Examine the input $t=0$. Its score is zero, so it receives the negative label.

Suppose someone proposes any positive certified radius $r>0$. Choose the point

$$
y=\frac r2.
$$

Its distance from zero is $|y|=r/2<r$, so it lies strictly inside the proposed ball. But $f(y)=r/2>0$, hence its label is positive. The decision flips.

Because this construction works for *every* $r>0$, the threshold classifier has no positive certified radius at the boundary point. Its vulnerability stalk $\mathcal V_f(0,r)$ is nonempty for every positive radius; indeed, $r/2$ is an explicit member.

Put the two facts side by side:

1. the constant sheaf on the two-chart overlap has vanishing $H^1$;
2. the threshold classifier at zero has no positive robustness radius.

This pair is a counterexample to any universal claim that vanishing first cohomology of the bare weight-chart sheaf alone guarantees a positive adversarial radius for every score. The topology and the classifier can simply be independent. Perfect gluing in parameter space does not create separation from a decision boundary in input space.

## Qualitative structure versus quantitative safety

The counterexample highlights a difference that appears across applied mathematics. Ordinary cohomology is qualitative. It can say that an obstruction exists or vanishes. A robustness radius is quantitative: it has units, a magnitude, and a dependence on both the score at the chosen input and the rate at which the score can change.

Imagine a map with perfectly consistent street names but no scale bar. Consistency helps one navigate, yet it cannot tell whether the nearest cliff is one meter or one kilometer away. In the same way, a vanishing gluing obstruction may organize local descriptions without determining any numerical distance to a class boundary.

Two analytic numbers supply the missing scale:

- a positive *margin* $m$, giving a lower bound $m\le f(x)$ on the score at the point of interest;
- a nonnegative local *Lipschitz constant* $L$, controlling score variation by distance.

These quantities connect the geometry of the input ball to the classifier’s output.

## The corrected robustness theorem

Assume $f(x)\ge m>0$. Suppose that throughout the open $L^\infty$ ball of radius $r$ around $x$,

$$
|f(y)-f(x)|\le L\|x-y\|_\infty,
$$

where $L\ge 0$. If the strict budget inequality

$$
Lr<m
$$

holds, then the classifier is certified at $x$ with radius $r$.

Here is the entire mechanism. For any $y$ in the ball,

$$
L\|x-y\|_\infty<Lr<m.
$$

The Lipschitz estimate gives

$$
f(y)\ge f(x)-L\|x-y\|_\infty>m-m=0.
$$

Thus both $f(x)$ and $f(y)$ are positive, so their decisions agree. Since $y$ was arbitrary, every point in the ball preserves the label.

This theorem does not need cohomology. Its role is different: it identifies the numerical bridge any topological theory of certification must eventually carry. If topology is to produce a radius, it must organize data that contain margins, Lipschitz constants, or comparable quantitative controls—not merely constant values on weight charts.

When $L>0$, the familiar ratio $m/L$ appears as a limiting radius: every strict radius $r<m/L$ is certified under the local estimate. If $L=0$, the score is locally constant under the stated bound, and any radius on which that bound holds satisfies the budget because $0<m$.

## A concrete numerical picture

Consider the affine score

$$
f(x_1,x_2)=1.2+0.4x_1-0.7x_2
$$

at the origin. Its margin is $m=1.2$. For the $L^\infty$ input norm, the exact Lipschitz constant of this linear part is the $L^1$ norm of its coefficients:

$$
L=|0.4|+|-0.7|=1.1.
$$

Hence any radius satisfying $1.1r<1.2$ is certified. For example, $r=1$ works. Every perturbation with $\max(|x_1|,|x_2|)<1$ changes the score by less than $1.1$, leaving it strictly positive.

By contrast, for $f(t)=t$ at zero the margin is $m=0$. No inequality $Lr<m$ can hold with $r>0$ and $L\ge0$. The analytic theorem diagnoses exactly what the counterexample displays: at the boundary, there is no positive reserve to absorb perturbations.

## What topology might still contribute

The lesson is not that sheaf theory is irrelevant. Rather, the sheaf must be tied to the classifier and enriched with quantities that can survive gluing.

A promising construction would place local margins and local sensitivity bounds on activation regions of a piecewise-linear network. Restriction maps would record how those bounds behave on shared faces. Cohomology could then detect whether local certificates fail to assemble, while operator norms or contracting estimates could preserve the constants needed for a global radius.

Another direction begins with the vulnerability sets $\mathcal V_f(x,r)$. As $r$ grows, these sets form a nested family over input balls. Their support identifies where adversarial examples first appear. Near a decision boundary, local cohomological tools might describe how vulnerable regions connect or bifurcate. For multiclass networks, the scalar score is replaced by the gap between the winning logit and each competitor, and every gap must remain positive.

There is also a crucial parameter-to-input question. Weight-space topology concerns how model descriptions vary with parameters; adversarial robustness concerns how decisions vary with inputs. Any theorem connecting them must explicitly bridge those domains. Without that bridge, even flawless topology on weight charts says nothing about the distance from a particular input to a decision boundary.

## The sharper principle

The central result is therefore a boundary marker for future theories:

**Vanishing first cohomology of a bare weight-space cover does not imply a positive $L^\infty$ robustness radius.** A two-chart constant sheaf already has $H^1=0$, while the threshold score at its decision boundary fails certification at every positive radius.

The constructive replacement is equally clear:

**Positive margin plus controlled local sensitivity yields certification.** If $f(x)\ge m>0$, the score is locally $L$-Lipschitz in $L^\infty$, and $Lr<m$, then the radius $r$ is certified.

Topology can reveal whether local information fits together. Robustness demands more: the information must carry a scale. The most fruitful future theory will not ask topology to manufacture that scale from nothing. It will use topology to transport, reconcile, and expose obstructions among quantitative local certificates already anchored to the classifier’s margins and sensitivities.