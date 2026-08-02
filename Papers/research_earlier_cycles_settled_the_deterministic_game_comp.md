# Asymmetric Boolean Wagers: Affine Randomization, Sharp Profitability Thresholds, and Abstention

**Aristotle**  
**August 2, 2026**

## Abstract

We study a finite Boolean wagering problem with asymmetric consequences. A statement has a truth value in each possible world; a correct bet earns $a$ units and an incorrect bet loses $b$ units. The player may bet true with probability $r\in[0,1]$, bet false otherwise, and may optionally abstain for payoff $0$. For arbitrary finite rational world weights, we derive an exact expected-payoff formula in terms of the total true-world and false-world masses. The expected payoff of every randomized strategy is an affine combination of the two pure-strategy values. It follows that randomization cannot outperform the better pure action and that a positive randomized edge exists exactly when a pure action has positive value. Under a normalized prior and $a+b>0$, positive profit is possible exactly when the true probability $\pi$ satisfies $\pi<a/(a+b)$ or $\pi>b/(a+b)$. Thus the complementary region is a sharp no-bet region. Adding abstention produces value $\max\{0,V_{\mathrm{false}},V_{\mathrm{true}}\}$, guarantees nonnegative value, and dominates every randomized Boolean wager. We give constructive decision algorithms, examples, and applications to selective prediction and cost-sensitive classification.

## 1. Introduction

Binary decisions are rarely symmetric. A correct medical intervention and an unnecessary intervention do not have equal and opposite consequences. A fraud detector’s false rejection and false acceptance incur different losses. A market contract can offer a payoff that differs from the stake at risk. Even a purely logical question—whether a statement is true—becomes a decision-theoretic problem once rewards and penalties are attached to the answer.

This paper isolates the mathematical core of such decisions. There is a finite space $W$ of possible worlds and a Boolean statement $s:W\to\{\mathrm{false},\mathrm{true}\}$. A finite weight function $\mu:W\to\mathbb{Q}$ represents the prior. A pure prediction is either true or false. A randomized prediction chooses true with probability $r$ and false with probability $1-r$. Correctness earns $a\in\mathbb{Q}$, while error pays $-b$ for $b\in\mathbb{Q}$. The natural betting interpretation usually assumes $a,b\ge0$, but most identities require only rationality; the threshold theorem assumes the single sign condition $a+b>0$.

Three reductions govern the model. First, the internal structure of $W$ disappears after its weight is divided into true and false mass. Second, randomized payoff is affine in $r$, so the continuum of mixed actions reduces to two endpoints. Third, a zero-payoff abstention action turns optimization into a maximum of three explicit numbers.

These reductions yield exact, not asymptotic, conclusions. No sampling or numerical optimization is required. In particular, randomization cannot create an edge when both pure actions are nonpositive. Under normalization, the existence of a positive edge is characterized by two sharp probability thresholds. The resulting framework is a minimal model of selective prediction: act when posterior confidence clears the cost-adjusted boundary, and abstain otherwise.

## 2. Finite-world model

### 2.1 Worlds, statements, and masses

Let $W$ be a nonempty or empty finite set; none of the algebra below requires nonemptiness. Let

$$
s:W\longrightarrow\{\mathrm{false},\mathrm{true}\}
$$

be a Boolean statement evaluated in each world. Let $\mu:W\to\mathbb{Q}$ assign a rational weight to every world.

**Definition 2.1 (Truth and falsehood masses).** The true mass and false mass are

$$
T=\sum_{\omega\in W\,:\,s(\omega)=\mathrm{true}}\mu(\omega),
\qquad
F=\sum_{\omega\in W\,:\,s(\omega)=\mathrm{false}}\mu(\omega).
$$

A normalized prior satisfies

$$
\sum_{\omega\in W}\mu(\omega)=1.
$$

For a probabilistic interpretation one additionally assumes $\mu(\omega)\ge0$ for every $\omega$, although the identities proved below are algebraic and do not require positivity.

**Lemma 2.2 (Mass partition).** For every finite weighted world model,

$$
T+F=\sum_{\omega\in W}\mu(\omega).
$$

**Proof sketch.** Every world belongs to exactly one of the two disjoint classes determined by $s$. Its weight therefore occurs exactly once in $T+F$. Summing this pointwise partition over $W$ gives the identity. $\square$

Under normalization, write $\pi=T$. Lemma 2.2 then gives $F=1-\pi$. If the weights are nonnegative, $\pi\in[0,1]$ and is precisely the prior probability that the statement is true.

### 2.2 Payoffs and strategies

**Definition 2.3 (Pure asymmetric payoff).** Given rational parameters $a$ and $b$, the payoff of a Boolean bet $q$ in world $\omega$ is

$$
P(q,\omega)=
\begin{cases}
a,&q=s(\omega),\\
-b,&q\ne s(\omega).
\end{cases}
$$

Thus $a$ is the gain for being correct and $b$ is the magnitude of the loss for being incorrect.

**Definition 2.4 (Randomized Boolean strategy).** For $r\in[0,1]$, the strategy $r$ bets true with probability $r$ and false with probability $1-r$. Its conditional expected payoff in world $\omega$ is

$$
P_r(\omega)=rP(\mathrm{true},\omega)+(1-r)P(\mathrm{false},\omega).
$$

Its total expected payoff is

$$
V(r)=\sum_{\omega\in W}\mu(\omega)P_r(\omega).
$$

The endpoint $r=0$ is the pure-false strategy and $r=1$ is the pure-true strategy. Denote their values by $V_F=V(0)$ and $V_T=V(1)$.

## 3. Exact payoff formulas

**Lemma 3.1 (Per-world randomized payoff).** For every world $\omega$,

$$
P_r(\omega)=
\begin{cases}
(a+b)r-b,&s(\omega)=\mathrm{true},\\
a-(a+b)r,&s(\omega)=\mathrm{false}.
\end{cases}
$$

**Proof sketch.** In a true world, the true component earns $a$ and the false component loses $b$, so $P_r(\omega)=ra-(1-r)b=(a+b)r-b$. In a false world, the true component loses $b$ and the false component earns $a$, so $P_r(\omega)=-rb+(1-r)a=a-(a+b)r$. $\square$

**Theorem 3.2 (Closed-form expectation).** For arbitrary finite rational weights,

$$
V(r)=\big((a+b)r-b\big)T+\big(a-(a+b)r\big)F.
$$

**Proof sketch.** Split the sum defining $V(r)$ into true worlds and false worlds. Lemma 3.1 makes the conditional payoff constant within each class. Factoring those constants out of the two finite sums leaves $T$ and $F$. $\square$

Taking the endpoints gives the next result.

**Corollary 3.3 (Pure values).** The pure-false and pure-true expected payoffs are

$$
V_F=aF-bT,
\qquad
V_T=aT-bF.
$$

**Proof sketch.** Substitute $r=0$ and $r=1$ into Theorem 3.2 and simplify. $\square$

**Corollary 3.4 (Normalized pure values).** If the prior is normalized and $\pi=T$, then

$$
V_F=a-(a+b)\pi,
\qquad
V_T=(a+b)\pi-b.
$$

**Proof sketch.** By Lemma 2.2, normalization gives $F=1-T=1-\pi$. Substitute this relation into Corollary 3.3 and collect terms. $\square$

The formulas clarify the role of asymmetric stakes. The true bet breaks even at $\pi=b/(a+b)$, while the false bet breaks even at $\pi=a/(a+b)$, provided $a+b>0$. These are utility-adjusted probability thresholds, not universal constants.

## 4. Affine randomization and endpoint optimality

The decisive structural fact is that $V(r)$ is affine in the mixing probability.

**Theorem 4.1 (Affine Randomization Theorem).** For every rational $r$,

$$
V(r)=rV_T+(1-r)V_F.
$$

In particular, for $0\le r\le1$, the randomized value lies on the closed line segment joining $V_F$ and $V_T$.

**Proof sketch.** One may expand the right-hand side using Corollary 3.3:

$$
r(aT-bF)+(1-r)(aF-bT).
$$

Collecting the coefficients of $T$ and $F$ yields exactly the expression in Theorem 3.2. Equivalently, linearity of expectation commutes with the random choice between the two pure bets. $\square$

**Theorem 4.2 (Pure-Strategy Optimality).** If $0\le r\le1$, then

$$
V(r)\le\max\{V_F,V_T\}.
$$

Moreover, the maximum over all randomized Boolean strategies is exactly

$$
\max_{0\le r\le1}V(r)=\max\{V_F,V_T\}.
$$

**Proof sketch.** Both $V_F$ and $V_T$ are at most $M=\max\{V_F,V_T\}$. Multiplying these inequalities by the nonnegative coefficients $1-r$ and $r$ and adding gives $V(r)\le(1-r)M+rM=M$. Equality is attained at $r=0$ when $V_F\ge V_T$ and at $r=1$ when $V_T\ge V_F$. $\square$

This theorem concerns randomization against a fixed prior. It does not contradict the importance of mixed strategies in interactive games where another player responds to one’s action. Here no response changes the distribution after $r$ is chosen, so mixing is only averaging.

**Theorem 4.3 (Positive-edge equivalence).** A positive-payoff randomized strategy exists if and only if a positive-payoff pure strategy exists:

$$
\big(\exists r\in[0,1]:V(r)>0\big)
\quad\Longleftrightarrow\quad
V_F>0\ \text{or}\ V_T>0.
$$

**Proof sketch.** If either endpoint is positive, choosing its corresponding pure strategy proves the forward existence claim. Conversely, if $V(r)>0$, Theorem 4.2 gives $0<V(r)\le\max\{V_F,V_T\}$. Hence the maximum endpoint value is positive, so at least one endpoint is positive. $\square$

The equivalence is stronger than saying pure play is optimal. It says randomization cannot even rescue a decision problem in which both pure actions fail to clear zero.

## 5. Sharp profitability thresholds

We now assume a normalized prior and $a+b>0$.

**Theorem 5.1 (Sharp Profitability Thresholds).** There exists $r\in[0,1]$ with $V(r)>0$ if and only if

$$
\pi<\frac{a}{a+b}
\quad\text{or}\quad
\frac{b}{a+b}<\pi.
$$

**Proof sketch.** By Theorem 4.3, positive value exists exactly when $V_F>0$ or $V_T>0$. Corollary 3.4 gives

$$
V_F>0\iff a-(a+b)\pi>0
\iff \pi<\frac{a}{a+b},
$$

and, because $a+b>0$,

$$
V_T>0\iff(a+b)\pi-b>0
\iff\frac{b}{a+b}<\pi.
$$

Taking the disjunction proves the result. $\square$

When $a,b\ge0$, interpretation depends on their relative size. If $b\ge a$, then

$$
\frac{a}{a+b}\le\frac{b}{a+b},
$$

and the closed interval

$$
\left[\frac{a}{a+b},\frac{b}{a+b}\right]
$$

is a no-positive-edge region: neither direction pays. If $a>b$, the thresholds overlap in the reverse order, leaving a region in which both pure bets are profitable. That overlap reflects favorable offered odds, not a contradiction. The exact theorem is therefore best stated as the disjunction above rather than by presupposing a particular ordering.

**Example 5.2 (Symmetric unit stakes).** With $a=b=1$,

$$
V_F=1-2\pi,
\qquad
V_T=2\pi-1.
$$

Positive value exists precisely when $\pi\ne1/2$. At $\pi=1/2$, every mixture has value $0$.

**Example 5.3 (Error costs twice the reward).** With $a=1$ and $b=2$,

$$
V_F=1-3\pi,
\qquad
V_T=3\pi-2.
$$

Bet false for $\pi<1/3$, bet true for $\pi>2/3$, and regard $[1/3,2/3]$ as the no-positive-edge interval.

**Example 5.4 (Reward twice the loss).** With $a=2$ and $b=1$,

$$
V_F=2-3\pi,
\qquad
V_T=3\pi-1.
$$

The false bet is positive below $2/3$, and the true bet is positive above $1/3$. Both are positive for $1/3<\pi<2/3$.

## 6. Abstention

A compulsory binary decision can have negative optimal value. Introduce a third action, abstention, with payoff $0$ in every world.

**Definition 6.1 (Abstention value).** The optimal value with a pass option is

$$
A=\max\{0,V_F,V_T\}.
$$

**Theorem 6.2 (Nonnegativity).** For every finite weighted model and all rational $a,b$,

$$
A\ge0.
$$

**Proof sketch.** Zero is one of the entries in the maximum. $\square$

**Theorem 6.3 (Optimal abstention in the no-bet region).** If $V_F\le0$ and $V_T\le0$, then

$$
A=0,
$$

so abstention is optimal.

**Proof sketch.** Under the hypotheses, all three candidates $0,V_F,V_T$ are at most $0$, and one candidate equals $0$. Their maximum is therefore $0$. $\square$

**Theorem 6.4 (Dominance over randomized betting).** For every $r\in[0,1]$,

$$
V(r)\le A.
$$

**Proof sketch.** Theorem 4.2 yields $V(r)\le\max\{V_F,V_T\}$. By definition, $\max\{V_F,V_T\}\le\max\{0,V_F,V_T\}=A$. Transitivity completes the proof. $\square$

The pass option does not alter the values of the existing bets. It changes the feasible action set, replacing unavoidable negative value by a guaranteed floor of zero.

## 7. Algorithms

### 7.1 Sufficient statistics from a finite world table

Given explicit worlds, weights, and truth labels, compute

$$
T=\sum_{s(\omega)=\mathrm{true}}\mu(\omega),
\qquad
F=\sum_{s(\omega)=\mathrm{false}}\mu(\omega).
$$

A single pass through $n=|W|$ worlds takes $O(n)$ time and $O(1)$ auxiliary space beyond the input. Once $T$ and $F$ are known, every strategy evaluation takes $O(1)$ time via Theorem 3.2. Thus the pair $(T,F)$ is sufficient for all payoff questions in this model.

### 7.2 Optimal action with abstention

Compute

$$
V_F=aF-bT,
\qquad
V_T=aT-bF.
$$

Compare $0$, $V_F$, and $V_T$. Return false if $V_F$ is maximal and positive, true if $V_T$ is maximal and positive, and abstain if both are nonpositive. Ties may be resolved arbitrarily among maximizing actions. This requires $O(1)$ time after aggregation.

### 7.3 Strategy-curve generation

For visualization, choose grid points $r_k=k/m$ for $k=0,\ldots,m$ and evaluate

$$
V(r_k)=r_kV_T+(1-r_k)V_F.
$$

The computation costs $O(m)$ time and $O(m)$ output space. The points lie exactly on a line; the grid illustrates rather than estimates the function.

## 8. Geometry and comparative statics

The strategy set $[0,1]$ is a one-dimensional simplex whose extreme points are the pure-false and pure-true actions. The map $r\mapsto V(r)$ is affine, so maximizing expected payoff over this simplex is a linear optimization problem. The endpoint theorem is therefore an instance of a general geometric principle: an affine functional on a compact polytope attains a maximum at an extreme point. In the present two-action setting, the full principle reduces to elementary order arithmetic.

The slope of the strategy line is

$$
V_T-V_F=(a+b)(T-F).
$$

For a normalized prior this becomes

$$
V_T-V_F=(a+b)(2\pi-1).
$$

When $a+b>0$, the sign of the slope depends only on whether $\pi$ is above or below $1/2$. Thus the more likely truth value determines which pure bet is better, even though profitability depends on the asymmetric thresholds. These are distinct questions. At $\pi=0.6$ with $a=1$ and $b=2$, true is better than false, but its value $3(0.6)-2=-0.2$ remains negative; abstention is better than either. Relative ranking does not imply absolute profitability.

The endpoint values vary linearly with belief:

$$
\frac{dV_T}{d\pi}=a+b,
\qquad
\frac{dV_F}{d\pi}=-(a+b).
$$

Accordingly, increasing confidence in truth improves the true bet and worsens the false bet at equal rates. Increasing the reward $a$ raises $V_T$ in proportion to $\pi$ and raises $V_F$ in proportion to $1-\pi$. Increasing the loss $b$ lowers the same values in the complementary proportions. These sensitivities make the model transparent enough for policy analysis: one can see directly whether a changed decision boundary comes from revised beliefs or revised consequences.

The abstention value is the upper envelope of three affine functions of $\pi$:

$$
A(\pi)=\max\{0,\,a-(a+b)\pi,\,(a+b)\pi-b\}.
$$

It is therefore piecewise affine and convex. Kinks occur where the maximizing action changes. In the punitive regime $b\ge a\ge0$, the graph has a flat zero segment between the false and true entry thresholds. In the favorable regime $a>b\ge0$, the two betting lines cross at $\pi=1/2$ above zero, and the pass action is never optimal. This envelope gives a complete phase diagram of optimal behavior.

### 8.1 Robust decisions under probability intervals

Often $\pi$ is not known exactly; calibration or sampling may supply only an interval $[\ell,u]$. A conservative decision can require positive payoff throughout that interval. Because $V_T$ increases with $\pi$ and $V_F$ decreases when $a+b>0$, betting true is robustly positive exactly when

$$
\ell>\frac{b}{a+b},
$$

and betting false is robustly positive exactly when

$$
u<\frac{a}{a+b}.
$$

If neither inequality holds, abstention protects against the unresolved probability uncertainty. This robust extension follows immediately from monotonicity and requires no new optimization machinery.

## 9. Applications

### 9.1 Cost-sensitive classification

Suppose $\pi$ is a classifier’s posterior probability of a positive label. If correct classification gains $a$ and incorrect classification loses $b$, the theorem prescribes a positive label when $\pi>b/(a+b)$ and a negative label when $\pi<a/(a+b)$. If neither action is profitable and deferral is available, abstain. More general confusion matrices can have class-dependent rewards and losses, but the same expected-utility method applies.

### 9.2 Selective prediction

A selective predictor may route uncertain cases to a human reviewer. The abstention theorems explain the value of this option: the system acts only when one endpoint value is positive. Its acceptance region is determined jointly by calibrated probability and action cost. Confidence alone is insufficient without a payoff model.

### 9.3 Forecasting and event contracts

An event contract converts a belief about a Boolean event into gains and losses. Transaction costs, bid–ask spreads, or unequal payout schedules shift the break-even point away from $1/2$. The formulas here provide the one-period, risk-neutral value. Repeated trading, wealth constraints, and risk aversion require additional state variables and generally destroy the simple linear utility model.

### 9.4 Logical uncertainty

When worlds represent possible completions of incomplete information, $T$ and $F$ quantify how prior mass divides across truth values. The results distinguish uncertainty from exploitable asymmetry. Randomizing an answer does not create information: it only averages the values already implied by the prior. A profitable edge must come from the prior-payoff relation, not from an independent coin toss.

### 9.5 A decision table

For deployment, the mathematics can be summarized without searching over $r$. Given normalized true probability $\pi$ and $a+b>0$, first compute

$$
V_F=a-(a+b)\pi,
\qquad
V_T=(a+b)\pi-b.
$$

The operational rule is:

| Condition | Maximizing recommendation |
|---|---|
| $V_F>\max\{0,V_T\}$ | Bet false |
| $V_T>\max\{0,V_F\}$ | Bet true |
| $V_F\le0$ and $V_T\le0$ | Abstain |
| Equality among maxima | Any tied maximizing action |

This table separates three logically different outputs: the ranking of the two labels, the profitability of acting, and the handling of ties. For example, $V_T>V_F$ only says that true is preferable to false; it does not say $V_T>0$. A compulsory predictor answers true in that situation, whereas a selective predictor can still abstain. Similarly, equality $V_T=V_F$ occurs at $\pi=1/2$ when $a+b\ne0$, but the common value may be positive, zero, or negative according to the stakes. Tie-breaking should therefore follow the application’s secondary criteria only after primary expected values have been evaluated.

Because all comparisons are exact affine inequalities, the rule is stable away from its boundaries. Small perturbations of $\pi$, $a$, or $b$ cannot change the action unless they cross a line on which two candidate values coincide. Near such a boundary, reporting the margin between the best and second-best actions is more informative than reporting the selected label alone.

## 10. Scope and limitations

The model is finite, static, and risk-neutral. Rational weights make all expressions exact, but finite real weights would obey the same algebra. A probabilistic reading requires nonnegative normalized weights, whereas the general identities remain true for arbitrary finite rational weights.

The assumption $a+b>0$ in the threshold theorem is essential for dividing inequalities without reversing their direction or dividing by zero. In ordinary wagering, $a,b\ge0$ and at least one is positive, so the condition is automatic. The phrase “no-bet interval” must also be used carefully: a conventional interval between the two thresholds is a region where neither bet is positive when $a\le b$. When $a>b$, the thresholds overlap and both bets may be profitable. The disjunctive statement of Theorem 5.1 covers both regimes exactly.

Randomization is powerless here because the objective is affine and the feasible set $[0,1]$ is a line segment. Nonlinear utility, adversarial response, information acquired after randomization, or constraints coupling many bets could make interior strategies relevant. None is included in the present model.

Finally, abstention has been assigned exactly zero payoff. Real deferral may carry delay, review, or opportunity costs. Such costs can be represented by replacing $0$ with a third action value, after which optimization is still a finite maximum if that value is fixed.

## 11. Future work

A measure-theoretic extension would replace finite sums by expectations over infinite world spaces. Since randomization enters pointwise as an affine combination, the principal identity should persist whenever the relevant payoffs are integrable.

A sequential model could allow Bayesian updating after observations and measure cumulative regret against the best adaptive policy. Explicit fees and bid–ask spreads would create distinct entry and exit thresholds. A two-player formulation could allow an adversary to choose the prior and would invite a genuine minimax equality. Proper scoring rules would replace the single randomized Boolean action with a reported probability and reward calibration directly.

### 11.1 Sequential and generalized action spaces

A sequential extension should distinguish three sources of value: learning from new observations, adapting the action to the resulting posterior, and any direct benefit of randomization. The present theorem isolates the third source and shows it is absent in the static one-round model. Consequently, any improvement achieved by a sequential policy must be attributed to information or intertemporal constraints rather than to mixing alone.

For more than two labels, the same geometry suggests assigning one expected value to each pure action. A randomized action is a point in a higher-dimensional probability simplex, and its risk-neutral expected payoff is the corresponding convex combination of pure values. Without adversarial response or nonlinear constraints, an extreme point remains optimal. Abstention adds one more pure action, usually with a fixed value. What is special about the Boolean case is not endpoint optimality itself, but the complete reduction to one posterior probability and two explicit thresholds.

## 12. Conclusion

The asymmetric Boolean wager has an exact solution. All world-level detail compresses to true and false masses. Every randomized strategy is an affine combination of the two pure strategies, so a continuum of choices reduces to endpoint comparison. Under a normalized prior and $a+b>0$, positive expected profit exists exactly when

$$
\pi<\frac{a}{a+b}
\quad\text{or}\quad
\pi>\frac{b}{a+b}.
$$

Allowing abstention raises the value to

$$
\max\{0,V_F,V_T\},
$$

guaranteeing nonnegative value and making inaction optimal whenever both bets are nonpositive. The resulting rule is both mathematically sharp and operationally simple: aggregate belief, evaluate the two endpoints, and act only when an endpoint clears zero.