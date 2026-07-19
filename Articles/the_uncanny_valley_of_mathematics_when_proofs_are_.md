# The Uncanny Valley of Mathematics: Why Almost-Right Arguments Can Feel So Wrong

## Confidence does not always climb smoothly

A rough argument scribbled on a napkin can be charming. It announces itself honestly: here is an idea, a pattern, a reason to believe. A meticulous proof can be reassuring for the opposite reason: every dependency is visible, every transition is justified, and every possible objection has a place to land. Between those two modes lies a stranger object—the argument that looks finished but is not. Its notation is polished, its structure familiar, and most of its steps are convincing. Yet one unresolved inference remains. Instead of inspiring confidence, that near-completeness may provoke unusual suspicion.

This is the mathematical analogue of the “uncanny valley.” In design and robotics, increasingly humanlike figures may become more appealing until they are almost, but not quite, lifelike. At that point small discrepancies become conspicuous, and acceptance falls before recovering when the resemblance becomes convincing. For mathematical arguments, the horizontal coordinate is not human likeness but a sequence of rigor levels. The vertical coordinate is confidence.

The idea is psychological, but its mathematical core can be made precise without pretending that psychology has already been settled. Imagine testing finitely many presentations of an argument, ordered from least to most rigorous. A **confidence profile** assigns a real number to each tested level. A **strict confidence valley at level $v$** means that confidence strictly decreases as the presentations approach $v$ from the left and strictly increases after $v$. Symbolically, if $U(i)$ is confidence at level $i$, then whenever $i<j\le v$ we have $U(j)<U(i)$, while whenever $v\le i<j$ we have $U(i)<U(j)$.

This definition says more than “one score happened to be smallest.” It describes the whole shape of the profile. Every move toward the valley lowers confidence; every move away raises it. That distinction is crucial. A graph can have a unique lowest point while oscillating wildly elsewhere. Such a graph has a minimum, but not the disciplined descent-and-recovery pattern suggested by an uncanny valley.

## The bottom of a strict valley cannot hide

The first result is simple but foundational: **a strict confidence valley has a unique global minimum**. If $i<v$, strict descent gives $U(v)<U(i)$. If $i>v$, strict ascent gives the same conclusion. Thus no other tested level can match the value at $v$.

A useful corollary follows immediately: **one profile cannot have strict valleys at two different levels**. If $v$ and $w$ were distinct valley locations, the first would force $U(v)<U(w)$ while the second would force $U(w)<U(v)$, an impossibility.

These statements turn a visual metaphor into a falsifiable structural claim. Given survey data, one can check all required inequalities. If the inequalities hold, the location is unambiguous. If even one expected comparison fails, the strict-valley model does not fit that data.

Consider the five-level profile

$$
(8,5,1,4,7).
$$

It descends from $8$ to $5$ to $1$, then rises to $4$ and $7$. Its valley is the third level. A second profile,

$$
(9,6,2,3,8),
$$

has the same valley location. These are more informative than isolated minima because their values move in the expected direction at every step.

## How wide is the safety moat?

Strict inequalities tell us the winner, but not how secure the winner is. Measurements are noisy: respondents round scores, experimental conditions drift, and repeated judgments fluctuate. To discuss robustness we need a quantitative gap.

Say that $v$ has **minimum margin $\delta$** if every competing level $i\ne v$ satisfies

$$
U(v)+\delta\le U(i).
$$

When $\delta>0$, the valley point is automatically the unique minimum. More importantly, the margin measures how much observational error the conclusion can survive.

Suppose $V$ is an observed profile and every score differs from the underlying profile $U$ by at most $\varepsilon$:

$$
|V(i)-U(i)|\le\varepsilon
$$

for every level $i$. The valley score might be measured $\varepsilon$ too high, while a competitor might be measured $\varepsilon$ too low. The apparent gap can therefore shrink by as much as $2\varepsilon$. This gives the **half-margin stability theorem**: if

$$
2\varepsilon<\delta,
$$

then $v$ remains the unique minimum of $V$.

The factor of two is not bookkeeping; it is the exact adversarial cost of perturbing both ends of a comparison. At equality, a tie can occur. If the true valley is $\delta$ below a competitor, raising the valley by $\delta/2$ and lowering the competitor by $\delta/2$ erases the difference. The strict threshold is therefore sharp for avoiding ties.

This theorem gives an experimental design principle. Before arguing about whether a measured valley is meaningful, estimate its margin and the maximum plausible score error. A valley narrower than twice the error scale is not reliably localized. A valley wider than that scale has a stable bottom even if the exact scores wiggle.

## What happens when many people are combined?

Surveys rarely concern one person. Let $U_p(i)$ be respondent $p$’s confidence at rigor level $i$, and define population confidence by summing individual scores:

$$
A(i)=\sum_p U_p(i).
$$

Averaging gives the same shape because it merely divides this sum by the positive number of respondents.

The **common-valley aggregation theorem** says that if every respondent has a strict valley at the same level $v$, then the aggregate profile also has a strict valley at $v$. The proof is the arithmetic of agreement. On the left of $v$, every respondent’s score decreases between any two ordered levels, so the sum decreases strictly. On the right, every score increases, so the sum increases strictly.

Margins combine just as cleanly. If respondent $p$ separates $v$ from every competitor by at least $\delta_p$, then

$$
A(v)+\sum_p\delta_p\le A(i)
$$

for every $i\ne v$. Thus the **aggregate margin is at least the sum of the individual margins**.

The two sample profiles above aggregate to

$$
(17,11,3,7,15),
$$

which again descends and recovers around the third level. Their individual minimum margins are $3$ and $1$, while the aggregate margin is $4$, exactly the sum. The example illustrates both shape preservation and quantitative reinforcement.

But the common-location assumption matters. If different groups have valleys at different levels, averaging can flatten the bottom, produce a tie, or even change the number of apparent valleys. There is no unconditional theorem saying that a mixture of valleys is itself a strict valley. This limitation is scientifically healthy: the model identifies the hypothesis a survey must test rather than smuggling consensus into the conclusion.

## Counting every turn in the journey

A valley has another exact signature: its total variation. For scores $U(0),U(1),\ldots,U(n)$, define variation along the first $n$ steps by

$$
\operatorname{Var}_n(U)=\sum_{k=0}^{n-1}|U(k+1)-U(k)|.
$$

Variation is the total vertical distance traveled by the graph, ignoring direction. If the profile never increases during its first $n$ steps, every absolute difference is simply a drop, and the sum telescopes:

$$
\operatorname{Var}_n(U)=U(0)-U(n).
$$

If the profile never decreases, the analogous identity is

$$
\operatorname{Var}_n(U)=U(n)-U(0).
$$

Put the two halves together. Suppose a profile descends for $\ell$ steps to $U(\ell)$ and then rises for $r$ steps to $U(\ell+r)$. The **valley variation identity** is

$$
\operatorname{Var}_{\ell}(U)+
\operatorname{Var}_{r}\bigl(k\mapsto U(\ell+k)\bigr)
=
\bigl(U(0)-U(\ell)\bigr)+
\bigl(U(\ell+r)-U(\ell)\bigr).
$$

In words, the path length is exactly the depth of the descent plus the height of the recovery. No movement is wasted. Extra reversals would add travel beyond this baseline, which suggests an “excess variation” statistic for detecting noisy or multi-valley profiles.

For $(8,5,1,4,7)$, the adjacent movements have sizes $3,4,3,3$, totaling $13$. The drop from $8$ to $1$ is $7$, and the recovery from $1$ to $7$ is $6$; again the total is $13$.

## From metaphor to experiment

These results do not establish that mathematicians actually experience an uncanny valley. They say what would follow if confidence data have a particular finite shape. The distinction is essential. Mathematics supplies certificates for uniqueness, robustness, aggregation, and variation; behavioral evidence must decide whether those certificates describe real judgments.

A direct study could present many mathematicians with versions of the same argument at several rigor levels, randomized to control for order. Each participant would assign confidence scores. Researchers would then ask four questions. Does each profile descend and recover? Do respondents share a valley location? How large is the minimum margin? Is that margin larger than twice the estimated measurement error?

The framework also recommends caution about what “rigor” means. Length, number of details, transparency of sources, closure of dependencies, and reproducibility may move independently. Refining an argument can preserve its conclusion while changing its structural complexity. Confidence may respond less to raw length than to whether unresolved dependencies remain. A one-dimensional grid is therefore a first experiment, not the final psychology.

The most provocative claim behind the metaphor is that an honest sketch may be trusted differently from a nearly finished proof. The sketch wears its incompleteness openly and is judged as intuition. The almost-finished proof invites line-by-line reliance, so its small gap carries disproportionate weight. A complete argument restores confidence not by becoming prettier, but by removing the ambiguity about which obligations remain.

That story is plausible, but plausibility is not evidence. What the combinatorial theory contributes is a clean way to recognize the proposed phenomenon and to know when it is stable. A genuine strict valley has one bottom. Shared valleys survive aggregation. Margins survive bounded noise below the sharp half-margin threshold. And a single descent followed by a single recovery obeys an exact accounting law.

The uncanny valley of mathematics, if surveys reveal it, will not merely be a dramatic dip on a chart. It will be a structured, measurable object—with a unique location, a safety moat, a population law, and a precise cost for every downward and upward step.