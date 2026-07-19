# Discrete Confidence Valleys in Mathematical Communication: Uniqueness, Aggregation, Robustness, and Variation

**Aristotle**  
**July 19, 2026**

## Abstract

We develop a finite combinatorial model for a proposed “uncanny valley” in mathematical communication: confidence may decrease as an argument approaches near-completeness, attain a low point where a polished presentation retains unresolved gaps, and recover when those gaps are closed. The behavioral conjecture is not assumed as fact. Instead, we isolate its testable mathematical content for a real-valued confidence profile on an ordered set of rigor levels. A strict valley is defined by strict decrease up to a designated level and strict increase thereafter. We prove that its location is the unique global minimum and hence is unique. A quantitative minimum margin yields a sharp deterministic robustness theorem: uniform perturbations of size at most $\varepsilon$ cannot move the minimum whenever $2\varepsilon<\delta$, where $\delta$ is the margin; equality can permit ties. For a finite population, common strict-valley structure is preserved by summation or averaging, and individual margins add. Finally, for profiles indexed by consecutive natural-number levels, monotone descent and ascent imply an exact total-variation identity: variation equals the initial drop plus the subsequent recovery. Numerical algorithms are given for certifying shape, margin, perturbation stability, aggregation, and variation. The framework separates conditional mathematical consequences from empirical claims and identifies curvature, concentration, heterogeneous minima, excess variation, and multidimensional rigor as natural next questions.

## 1. Introduction

Informal intuition and complete proof occupy familiar roles in mathematics. The first suggests why a statement should be true; the second supplies all inferential obligations needed to establish it. Between them lies a potentially unstable form of communication: an argument that has the appearance and granularity of a completed proof but still contains a small unresolved dependency. Such an argument may be evaluated more harshly than a candid sketch because its surface completeness encourages stronger reliance while its remaining defect raises the possibility of a hidden failure.

This motivates a mathematical analogue of the uncanny valley. The original metaphor describes acceptance that improves with resemblance, drops when an artifact is almost but not fully lifelike, and then recovers. Here the independent variable is an ordered collection of presentation or rigor levels, while the dependent variable is a measured confidence score. The central empirical hypothesis is that confidence follows a descent-and-recovery profile around an “almost rigorous” level.

The purpose of this paper is not to infer psychology from definitions. Rather, it is to provide a precise finite model with consequences that can be checked on survey data. The model has four complementary certificates:

1. **Shape:** confidence strictly descends to one designated level and strictly ascends afterward.
2. **Separation:** the designated level lies below all competitors by a positive margin.
3. **Aggregation:** shared individual structure survives population summation and averaging.
4. **Path geometry:** a single descent followed by a single recovery has exactly determined total variation.

These certificates answer different questions. Shape tests whether the graph truly has one disciplined valley rather than merely a low point. Separation quantifies robustness to measurement error. Aggregation explains when respondent-level agreement passes to population summaries. Variation measures the total movement of the profile and provides a baseline against which extra reversals can be detected.

The results apply to any finite ordered experiment with real-valued responses. Although the motivating language concerns rigor, the theorems depend only on order and inequalities. The spacing between levels is irrelevant to the basic shape and margin results. This is useful in practice because categories such as “intuition,” “detailed sketch,” “nearly complete argument,” and “complete argument” need not be equally spaced on any latent psychological scale.

## 2. Ordered confidence profiles

### 2.1 Rigor levels and scores

Let $I$ be a linearly ordered set of tested presentation levels. A **confidence profile** is a function

$$
U:I\to\mathbb{R},
$$

where $U(i)$ is the confidence assigned to the presentation at level $i$. The finite experimental case is primary, but the first structural statements require only a linear order.

The term “rigor level” should be interpreted operationally: each element of $I$ corresponds to a specified stimulus. The order records increasing completeness or explicitness according to the experimental design. The model does not require numerical distances between levels.

### 2.2 Strict valleys

**Definition 2.1 (Strict confidence valley).** A confidence profile $U$ has a strict valley at $v\in I$ if both conditions hold:

- for all $i<j\le v$, one has $U(j)<U(i)$;
- for all $v\le i<j$, one has $U(i)<U(j)$.

Thus $U$ is strictly decreasing on the levels at or below $v$ and strictly increasing on the levels at or above $v$. The definition compares every ordered pair on each side, although on a consecutive finite grid it is equivalent to checking adjacent pairs.

Strictness matters. Weak monotonicity permits a flat bottom and therefore does not identify a unique valley level. Likewise, the existence of a unique global minimum does not imply the strict-valley property: a profile may oscillate several times while retaining one lowest value.

### 2.3 Unique minimum and unique location

**Theorem 2.2 (Unique-minimum theorem).** If $U$ has a strict valley at $v$, then for every $i\ne v$,

$$
U(v)<U(i).
$$

In particular, $v$ is the unique global minimizer of $U$.

**Proof sketch.** If $i<v$, apply strict decrease to the pair $i<v$ within the left side of the valley; this yields $U(v)<U(i)$. If $v<i$, apply strict increase to the pair $v<i$ on the right side, again obtaining $U(v)<U(i)$. Linear order ensures that one of these two cases holds for every $i\ne v$. $\square$

**Corollary 2.3 (Uniqueness of valley location).** A confidence profile has at most one strict valley location.

**Proof sketch.** Suppose distinct levels $v$ and $w$ were both strict valley locations. By Theorem 2.2 applied at $v$, one obtains $U(v)<U(w)$. Applying the theorem at $w$ gives $U(w)<U(v)$, a contradiction. $\square$

This corollary makes location estimation unambiguous whenever the strict shape certificate succeeds. It does not say that every profile has a valley; profiles may be monotone, flat, oscillatory, or multi-modal.

## 3. Quantitative separation and deterministic robustness

### 3.1 Minimum margins

**Definition 3.1 (Minimum margin).** Let $v\in I$ and $\delta\in\mathbb{R}$. The profile $U$ has margin $\delta$ at $v$ if, for every $i\ne v$,

$$
U(v)+\delta\le U(i).
$$

A positive margin is a global separation certificate. On a finite grid, the largest valid margin is

$$
\delta_* = \min_{i\ne v}\bigl(U(i)-U(v)\bigr).
$$

**Proposition 3.2 (Positive margin implies uniqueness).** If $\delta>0$ and $U$ has margin $\delta$ at $v$, then $v$ is the unique global minimum.

**Proof sketch.** For each $i\ne v$, positivity gives $U(v)<U(v)+\delta$, while the margin gives $U(v)+\delta\le U(i)$. Transitivity yields $U(v)<U(i)$. $\square$

A strict valley implies a positive minimum margin when the tested set is finite, because finitely many positive differences have a positive minimum. On an infinite order, strictness alone need not provide a uniform positive margin.

### 3.2 Uniform observational error

Let $U$ denote an underlying profile and $V$ an observed or perturbed profile. Assume a uniform error bound

$$
|V(i)-U(i)|\le\varepsilon
$$

for every $i\in I$. No probabilistic structure is required; the error may be adversarial.

**Theorem 3.3 (Half-margin stability).** Suppose $U$ has margin $\delta$ at $v$, the uniform error bound above holds, and

$$
2\varepsilon<\delta.
$$

Then $v$ is the unique global minimum of $V$; explicitly, for every $i\ne v$,

$$
V(v)<V(i).
$$

**Proof sketch.** The error bound gives $V(v)\le U(v)+\varepsilon$ and $V(i)\ge U(i)-\varepsilon$. The margin gives $U(i)\ge U(v)+\delta$. Combining,

$$
V(i)-V(v)\ge \delta-2\varepsilon>0.
$$

Hence every competitor remains strictly above $v$. $\square$

The theorem controls the minimum location, not necessarily the complete strict-valley shape. Bounded noise can introduce local reversals among nonminimum levels even while the minimum remains fixed. Preserving the full shape requires margins for all relevant pairwise inequalities, not only separation from the minimum.

### 3.3 Sharpness

**Proposition 3.4 (Sharp tie threshold).** The strict inequality $2\varepsilon<\delta$ cannot in general be weakened to $2\varepsilon\le\delta$ if a unique observed minimum is required.

**Proof sketch.** Consider two levels $v$ and $i$ with $U(i)=U(v)+\delta$. Set $\varepsilon=\delta/2$, perturb $v$ upward by $\varepsilon$, and perturb $i$ downward by $\varepsilon$. Then

$$
V(v)=U(v)+\frac{\delta}{2}
=U(i)-\frac{\delta}{2}=V(i).
$$

Both perturbations satisfy the error bound, but the observed values tie. $\square$

This example explains the factor of two: a pairwise gap can be attacked from both ends. For experimental planning, any claimed deterministic localization should therefore compare the estimated margin with twice the maximal plausible measurement error.

## 4. Population aggregation

### 4.1 Aggregate profiles

Let $P$ be a finite nonempty population. Respondent $p\in P$ has profile

$$
U_p:I\to\mathbb{R}.
$$

Define the aggregate score by

$$
A(i)=\sum_{p\in P}U_p(i).
$$

The arithmetic mean is $\overline U(i)=A(i)/|P|$. Because division by the positive number $|P|$ preserves strict inequalities, every shape result for the sum also holds for the mean.

### 4.2 Preservation of a common strict valley

**Theorem 4.1 (Common-valley aggregation).** If every respondent’s profile has a strict valley at the same level $v$, then the aggregate profile $A$ has a strict valley at $v$.

**Proof sketch.** Take $i<j\le v$. For every respondent $p$, strict descent gives $U_p(j)<U_p(i)$. Summing these strict inequalities over the nonempty population yields $A(j)<A(i)$. Similarly, for $v\le i<j$, every respondent satisfies $U_p(i)<U_p(j)$, and summation gives $A(i)<A(j)$. These are exactly the two defining conditions of a strict valley. $\square$

Nonemptiness is essential for strictness: the sum over an empty population is identically zero.

### 4.3 Addition of margins

**Theorem 4.2 (Aggregate-margin theorem).** Suppose respondent $p$ has margin $\delta_p$ at the common level $v$, meaning that for every $i\ne v$,

$$
U_p(v)+\delta_p\le U_p(i).
$$

Then the aggregate profile has margin $\sum_{p\in P}\delta_p$ at $v$:

$$
A(v)+\sum_{p\in P}\delta_p\le A(i)
$$

for every $i\ne v$.

**Proof sketch.** Fix a competitor $i\ne v$ and sum the respondent-level margin inequalities. The sum of the left sides is $A(v)+\sum_p\delta_p$, and the sum of the right sides is $A(i)$. $\square$

For an average profile, the corresponding certified margin is the average of the individual margins. Combining Theorems 4.2 and 3.3 immediately gives a population robustness guarantee: if the aggregate is perturbed uniformly by less than half the summed margin, its minimum cannot move.

### 4.4 Why common location cannot be omitted

Theorem 4.1 is conditional on alignment. Without it, aggregation may create ties or erase strict shape. For example, take two three-level profiles

$$
U_1=(0,1,2),\qquad U_2=(2,1,0).
$$

Their minima lie at opposite ends, and their sum is $(2,2,2)$. The aggregate has no unique minimum and no strict valley. More elaborate mixtures can produce shoulders or several changes of direction. Consequently, heterogeneous locations require additional assumptions, such as convexity and lower bounds on discrete curvature.

## 5. Total variation and the geometry of a valley

### 5.1 Path variation

For a sequence $U:\mathbb{N}\to\mathbb{R}$, define total variation along the first $n$ adjacent edges by

$$
\operatorname{Var}_n(U)=
\sum_{k=0}^{n-1}|U(k+1)-U(k)|,
$$

with $\operatorname{Var}_0(U)=0$.

Total variation records distance traveled rather than net displacement. It is therefore sensitive to reversals: a drop followed by a rise contributes both movements.

### 5.2 Monotone segments telescope

**Lemma 5.1 (Variation of a nonincreasing segment).** If

$$
U(k+1)\le U(k)
$$

for every $0\le k<n$, then

$$
\operatorname{Var}_n(U)=U(0)-U(n).
$$

**Proof sketch.** Every difference $U(k+1)-U(k)$ is nonpositive, so

$$
|U(k+1)-U(k)|=U(k)-U(k+1).
$$

Summing causes all intermediate terms to cancel, leaving $U(0)-U(n)$. $\square$

**Lemma 5.2 (Variation of a nondecreasing segment).** If

$$
U(k)\le U(k+1)
$$

for every $0\le k<n$, then

$$
\operatorname{Var}_n(U)=U(n)-U(0).
$$

**Proof sketch.** Every adjacent difference is nonnegative, so the absolute values can be removed without changing signs. The resulting sum telescopes to $U(n)-U(0)$. $\square$

These lemmas allow weak monotonicity. Flat steps contribute zero and do not disrupt the identity.

### 5.3 Exact variation law for a valley

**Theorem 5.3 (Valley variation identity).** Let $\ell,r\in\mathbb{N}$. Suppose

$$
U(k+1)\le U(k)\quad\text{for }0\le k<\ell
$$

and

$$
U(\ell+k)\le U(\ell+k+1)
\quad\text{for }0\le k<r.
$$

Then

$$
\operatorname{Var}_{\ell}(U)+
\operatorname{Var}_{r}\bigl(k\mapsto U(\ell+k)\bigr)
=
\bigl(U(0)-U(\ell)\bigr)
+
\bigl(U(\ell+r)-U(\ell)\bigr).
$$

**Proof sketch.** Apply Lemma 5.1 to the first $\ell$ edges, obtaining the total drop $U(0)-U(\ell)$. Apply Lemma 5.2 to the shifted recovery sequence $k\mapsto U(\ell+k)$, obtaining $U(\ell+r)-U(\ell)$. Adding the two identities gives the result. $\square$

The right side is the depth measured from the initial point plus the recovery measured to the terminal point. A clean valley incurs no extra travel. If a profile with the same endpoints and designated minimum reverses direction additionally, each excursion contributes extra variation. This motivates an empirical statistic

$$
E=	ext{observed variation}-
\bigl[(U(0)-U(\ell))+(U(\ell+r)-U(\ell))\bigr],
$$

where $E=0$ for the monotone descent-and-recovery model and $E>0$ signals additional movement, provided $U(\ell)$ is indeed the reference minimum.

## 6. Algorithms and numerical examples

### 6.1 Certification algorithm

For a finite vector $u=(u_0,\ldots,u_{n-1})$ and candidate index $v$, strict-valley certification requires checking

$$
u_{k+1}<u_k\quad(0\le k<v)
$$

and

$$
u_k<u_{k+1}\quad(v\le k<n-1).
$$

This adjacent test is sufficient by transitivity. It uses $n-1$ comparisons and therefore runs in $O(n)$ time with $O(1)$ auxiliary memory. If the test succeeds, the margin is

$$
\delta_*=
\min_{i\ne v}(u_i-u_v),
$$

which is computed in another $O(n)$ pass.

### 6.2 Perturbation audit

Given underlying and observed vectors $u$ and $w$, compute

$$
\varepsilon_*=
\max_i|w_i-u_i|.
$$

If $2\varepsilon_*<\delta_*$, the observed minimum is certified to remain at $v$. The calculation is linear in the number of levels. Failure of the inequality does not prove that the minimum moved; it only means this worst-case certificate is inconclusive.

### 6.3 Population aggregation

For $m$ respondents and $n$ levels, aggregate each column:

$$
a_i=\sum_{p=1}^{m}u_{p,i}.
$$

This requires $O(mn)$ arithmetic operations and $O(n)$ output storage. One may then certify the aggregate shape and margin in $O(n)$ time. If individual margins at a common candidate are available, their sum provides a guaranteed aggregate margin, possibly below the exact aggregate margin when the individual certificates are conservative.

### 6.4 Worked example

Consider

$$
u^{(1)}=(8,5,1,4,7),
\qquad
u^{(2)}=(9,6,2,3,8).
$$

Both strictly decrease to index $2$ and strictly increase thereafter. For the first respondent, differences above the minimum are $7,4,3,6$, so the exact margin is $3$. For the second they are $7,4,1,6$, so the margin is $1$.

Their aggregate is

$$
a=(17,11,3,7,15).
$$

It has the same strict valley. Its differences above the minimum are $14,8,4,12$, giving margin $4$, equal to $3+1$.

For the first profile, total variation is

$$
|5-8|+|1-5|+|4-1|+|7-4|
=3+4+3+3=13.
$$

The valley identity gives the same result:

$$
(8-1)+(7-1)=7+6=13.
$$

Now perturb the first profile to

$$
w=(7.6,4.8,1.4,3.7,6.8).
$$

The maximum absolute error is $0.4$. Since $2(0.4)=0.8<3$, the minimum is guaranteed to remain at index $2$. This guarantee follows without inspecting which direction each individual error took.

## 7. Experimental interpretation and applications

### 7.1 A survey design

A direct behavioral study could recruit mathematicians and present controlled variants of a single argument. The stimuli might range from heuristic intuition through increasingly explicit derivations to a fully resolved proof. To avoid conflating rigor with topic or conclusion, all versions should state the same claim and preserve as much wording as possible. Presentation order should be randomized, and repeated or paired items could estimate within-respondent variability.

For each respondent, researchers would record a confidence profile and ask:

1. Is there a strict valley, and where?
2. What is its exact minimum margin?
3. Do locations align across respondents?
4. Does the aggregate preserve a strict valley?
5. Is the aggregate margin large relative to measurement error?
6. How much excess variation appears beyond a single descent and recovery?

The theorems clarify the interpretation of each answer. A successful strict-shape test establishes unique location. A large margin establishes robust localization. Common locations justify direct aggregation. Variation distinguishes a clean valley from a graph with additional reversals.

### 7.2 Conditional scope

No theorem here establishes that “almost-right proofs are less trusted than informal intuitions.” That statement requires data. The results instead take observed inequalities as hypotheses and derive consequences. They also expose several failure modes:

- A unique minimum need not imply strict descent and recovery.
- A strict valley can have a small margin and therefore be unstable under noise.
- Respondents with different valley locations need not produce an aggregate valley.
- Stability of the minimum does not imply stability of every adjacent comparison.
- The order of levels alone does not identify which aspect of rigor drives confidence.

These limitations prevent the metaphor from becoming unfalsifiable. A dataset that violates the shape inequalities rejects the strict-valley model for that experiment.

### 7.3 Semantic content and structural complexity

Argument refinement should be viewed in at least two coordinates. One coordinate records semantic content—the proposition or conclusion being defended. Another records structural complexity, such as unresolved dependencies, length, branching, or the number of inferential obligations. A revision may preserve the conclusion while reducing some complexity measure. Confidence recovery can then be studied while semantic content is held fixed.

This distinction matters because more detail is not always less complex. Adding explanatory steps may increase length while reducing dependency opacity. Conversely, a short argument may conceal a difficult lemma. Experiments should therefore manipulate and measure logical completeness, source transparency, dependency structure, and reproducibility separately rather than treating “rigor” as a synonym for word count.

## 8. Discussion

The model’s principal advantage is its modesty. It translates an evocative metaphor into elementary order conditions and quantitative inequalities. The resulting theory is exact:

- strict descent and ascent force one unique minimum;
- common strict inequalities survive finite population sums;
- minimum margins add under aggregation;
- a margin $\delta$ resists uniform errors below $\delta/2$;
- the half-margin threshold is sharp for avoiding ties;
- monotone descent and recovery obey an exact variation law.

The results are distribution-free and do not depend on equal spacing of rigor levels. They also scale transparently: shape and margin checks are linear in the number of tested levels, while aggregation is linear in both respondents and levels.

At the same time, the common-minimum assumption is strong. Real populations may divide according to expertise, field, familiarity, or tolerance for omitted detail. In such settings, mean confidence can conceal meaningful subgroups. Reporting individual locations, subgroup profiles, and margins is therefore preferable to publishing only a grand average.

The deterministic stability theorem is particularly useful as a bridge to statistics. If a concentration inequality guarantees that empirical means uniformly approximate population means within $\varepsilon$, then the half-margin theorem immediately converts that bound into correct minimum recovery whenever $2\varepsilon<\delta$. Thus the combinatorial result separates the inferential task into two modules: statistical control of uniform error and deterministic conversion of that control into location stability.

Variation offers a complementary diagnostic. Margin concerns only the bottom relative to competitors, whereas variation sees every adjacent movement. Two profiles may share the same minimum and margin but differ greatly in oscillation. Excess variation may therefore capture disagreement, poorly ordered stimuli, or multidimensional effects that a one-dimensional valley cannot represent.

## 9. Future directions

### 9.1 Heterogeneous valley positions

A natural conjecture replaces exact alignment with controlled dispersion. Suppose each respondent’s profile is strictly convex on a common ordered grid, every minimum lies within distance $d$ of a central level, and all discrete second differences have a common positive lower bound. One expects the aggregate to have a unique minimum within the same distance $d$. Curvature could prevent the flattening seen in arbitrary mixtures and quantify how displaced minima combine.

### 9.2 Statistical recovery

For bounded independent survey responses, suppose the population mean has margin $\delta$ over $m$ tested levels. Uniform concentration suggests that a sample size on the order of

$$
\delta^{-2}\log(m/\eta)
$$

should identify the true minimum with probability at least $1-\eta$, with optimal dependence up to constants. The deterministic half-margin theorem supplies the final implication once uniform estimation error is controlled.

### 9.3 Excess variation

Among profiles with fixed endpoints and fixed minimum value, a single monotone descent followed by a monotone recovery is expected to minimize total variation. Every additional reversal should incur a penalty equal to twice the total height of the added excursions. Establishing and calibrating this decomposition would turn visual “wiggles” into an additive statistic.

### 9.4 Complexity and confidence recovery

Controlled experiments can preserve an argument’s conclusion while altering dependency structure and measured complexity. A central hypothesis is that confidence recovery depends more strongly on eliminating unresolved dependencies than on reducing raw length. Paired stimuli could isolate these effects.

### 9.5 Multidimensional rigor

Logical completeness, source transparency, and computational reproducibility are distinct coordinates. In a multidimensional space, low confidence may form a ridge rather than a point. Coordinatewise margins, partial orders, and robust low-confidence regions are natural generalizations of the one-dimensional theory.

## 10. Conclusion

A mathematical uncanny valley is best treated not as an established psychological law but as a testable shape hypothesis. On an ordered finite set of rigor levels, strict descent followed by strict ascent yields a unique and uniquely located minimum. Positive margins quantify separation, and uniform perturbations below half the margin cannot change the minimum; the boundary is sharp because equal and opposite errors can create a tie. Shared respondent-level valleys survive summation and averaging, while their margins add. Along a single descent and recovery, total variation is exactly the drop plus the rise.

Together these results provide a complete finite framework for designing, auditing, and interpreting confidence-profile experiments. They identify what agreement is required for aggregation, what signal-to-error ratio supports robust localization, and how additional reversals depart from the ideal valley. Whether mathematical audiences actually exhibit this pattern remains an empirical question. If they do, the phenomenon can be measured with more precision than the metaphor alone suggests.