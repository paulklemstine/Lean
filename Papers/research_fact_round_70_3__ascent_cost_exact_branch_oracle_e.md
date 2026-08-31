# The Ascent-Cost Laws: Exact Economics of a Branch Oracle under End-Verification Semantics

**Author:** Aristotle
**Date:** 2026-08-31

---

## Abstract

We give exact expected-cost laws for two canonical search schedules on a $b$-ary decision tree of height $h$ explored under *end-verification-only* semantics, in which a candidate solution can only be tested at a leaf and a wrong turn at level $j$ therefore forces exhaustion of the entire wrong subtree below it. The searcher is guided by a *branch oracle* that names the correct child with probability $\alpha$ independently at each level.

For depth-first search with backtracking, with level waste weight $w \in (0, b-1]$, the expected cost is exactly
$$E_{\mathrm{DFS}}^{(b,w)}(h) = h\Big(1 - \frac{w}{b-1}\Big) + \frac{w\,(b^{h+1}-b)}{(b-1)^2},$$
specializing at $b = 3$, $w = K := (1-\alpha)(2-\alpha)$ to $E_{\mathrm{DFS}}(h) = h(1 - K/2) + K(3^{h+1}-3)/4$. For restart-from-root, the expected cost is exactly $E_{\mathrm{restart}}(h) = h\,\alpha^{-h}$, derived as the mean of a geometric trial process with per-trial success probability $\alpha^h$ and per-trial cost $h$.

From these two laws we obtain four principal consequences.

1. **Effective branching is refuted.** For every $\alpha < 1$ and every admissible waste weight, the DFS growth ratio $E_{\mathrm{DFS}}(h+1)/E_{\mathrm{DFS}}(h)$ converges to exactly $b$. Oracle accuracy enters only through the prefactor $w b/(b-1)^2$; it never bends the exponential base. There is no "effective branching factor" below $b$.
2. **A dominance phase boundary at the reciprocal branching factor.** For $\alpha > 1/b$ restart beats DFS by an unbounded factor; for $\alpha < 1/b$ DFS beats restart by an unbounded factor. Consequently the optimal exponent is the non-analytic function $\min(b, 1/\alpha)$, with a kink at $\alpha = 1/b$. Beam (exhaustive level sweep) never wins at any accuracy or height.
3. **Master hint-law mapping is refuted.** A one-shot *class hint* preserving a fraction $\theta \ge 1/b$ of the space is capped at speedup $1/\theta \le b$. The sequential branch-hint speedup relative to the uninformed baseline is exactly $(b\alpha)^h$, which exceeds every constant cap whenever $\alpha > 1/b$. Branch hints therefore constitute a new taxonomy class — *sequential/geometric hints* — priced by $h\alpha^{-h}$, not by a bounded space-reduction ratio.
4. **An exact breakeven threshold.** Against a fixed exact-solver budget $F$ with per-step oracle overhead $c$, the guided ascent wins **if and only if** $\alpha > \alpha^\ast = ((1+c)h/F)^{1/h}$, and $\alpha^\ast$ is strictly increasing in $c$.

We complement the laws with a quantitative breakeven study against an exact benchmark scan of median $183$k steps, and with a supply-side entropy measurement, closing the gap from both ends.

**Keywords:** branch oracle, end-verification, restart schedules, backtracking search, effective branching factor, hint taxonomy, phase transition, breakeven analysis.

---

## 1. Introduction

### 1.1 The question

Search under a heuristic is one of the most-deployed algorithmic patterns in existence: at each decision point a heuristic — a hand-built rule, a learned model, a statistical channel — ranks the alternatives, and the searcher follows the ranking. The engineering question is always the same: *what is the heuristic worth?*

The widely held answer, which we shall call the **effective branching hypothesis**, holds that an accurate heuristic reduces the effective branching factor: if a $b$-ary search costs $b^h$ blind, then an oracle of accuracy $\alpha$ makes it cost $b_{\mathrm{eff}}(\alpha)^h$ for some $b_{\mathrm{eff}}(\alpha) < b$. Under this hypothesis, accuracy converts directly into exponent, and heuristic quality is measured on the same scale as problem hardness.

This paper prices the question exactly in a regime where the hypothesis can be tested rather than assumed, and finds it false.

### 1.2 End-verification-only semantics

The decisive modelling choice is *when the searcher learns it was wrong*. We work in the regime of **end-verification-only semantics**:

> A partial path carries no information. The searcher discovers that a path is wrong only upon reaching a leaf and testing the complete candidate.

This is the honest model for a large family of problems: integer factorization by structured scan, key search, proof search where only complete proofs typecheck, constraint problems with no propagation, and generally any setting where candidates are cheap to verify and impossible to partially verify. It is emphatically *not* the model for problems with strong propagation or admissible heuristics, where partial verification is exactly what makes search tractable. The gap between these two regimes is itself a research object, addressed in §8.

Under end-verification, a wrong turn at level $j$ is not a local error. The searcher will exhaust the *entire* subtree below the wrong child — $\Theta(b^{h-j})$ leaves — before learning anything. The oracle controls the *frequency* of errors; it has no control whatsoever over their *cost*. This asymmetry is the source of every result below.

### 1.3 Contributions

- Two exact closed-form cost laws (§3, §4), each proved equal to a first-principles construction: the DFS law to the accumulated per-level cost, the restart law to a geometric-trial expectation.
- A refutation of the effective branching hypothesis in the strongest available form: the growth ratio equals the branching factor *exactly in the limit*, for every accuracy below $1$ and every admissible waste weight (§5).
- The dominance phase boundary at $\alpha = 1/b$ and the resulting kinked exponent law $\min(b, 1/\alpha)$ (§6).
- A refutation of the master hint-law mapping and the introduction of a *sequential/geometric* hint class (§7).
- Exact breakeven analysis with an explicit critical accuracy and its comparative statics, plus a quantitative empirical calibration (§8).
- A universality theorem showing that all of the above is a one-parameter family in $b$, and that the ternary case is one point of it (§9).

---

## 2. The model

### 2.1 Setup

Fix a branching factor $b \ge 2$ and a height $h \in \mathbb{N}$. The search graph is the complete $b$-ary tree of height $h$; exactly one leaf is the goal. A **branch oracle of accuracy $\alpha \in [0,1]$** is consulted at each internal node and names the correct child with probability $\alpha$, independently across nodes. A **visit** to a node is the unit of cost.

Three schedules are considered.

- **DFS with backtracking.** Descend following the oracle; on reaching a wrong leaf, backtrack to the deepest node with an unexplored child and continue.
- **Restart from root.** Descend following the oracle to a leaf; if wrong, discard the entire path and restart from the root with fresh oracle draws.
- **Beam / exhaustive level sweep.** Expand every node at every level; ignore the oracle.

### 2.2 The failure weight

**Definition 2.1 (Failure weight).** For a ternary branch oracle of accuracy $\alpha$, the *level failure weight* is
$$K(\alpha) := (1-\alpha)(2-\alpha).$$

$K$ is the expected number of wrong children fully expanded before the correct one is taken, doubled; equivalently $K/2$ is the mean count of wasted siblings at a level. It is calibrated at both boundaries: $K(0) = 2$ (a blind agent wastes both wrong siblings) and $K(1) = 0$ (a perfect agent wastes none), and it decreases monotonically in between.

**Lemma 2.2.** For $\alpha \le 1$, $K(\alpha) \ge 0$; for $\alpha < 1$, $K(\alpha) > 0$; and for $\alpha \in [0,1]$, $K(\alpha) \le 2$.

*Proof.* Both factors $1-\alpha$ and $2-\alpha$ are nonnegative on $\alpha \le 1$ and positive on $\alpha < 1$; the upper bound follows from $(1-\alpha)(2-\alpha) \le 2$ on $[0,1]$, since the product is decreasing there with value $2$ at $\alpha = 0$. $\square$

In the general setting of §9 the role of $K$ is played by an abstract **level waste weight** $w$, constrained by $0 < w \le b-1$: a level cannot waste more than its wrong siblings. Violating the upper constraint makes the linear term of the law negative and admits "costs" below zero at small $h$, which is not a search cost.

### 2.3 The two constructions

**Definition 2.3 (Per-level DFS cost).** Entering level $j$ costs one visit. With weight $K$, the searcher additionally exhausts a complete wrong ternary subtree of $(3^j-1)/2$ nodes. Hence
$$\mathrm{lvl}(\alpha, j) := 1 + \frac{K(\alpha)\,(3^j - 1)}{2},$$
and the accumulated cost is $C(\alpha, 0) := 0$, $C(\alpha, h+1) := C(\alpha, h) + \mathrm{lvl}(\alpha, h+1)$.

**Definition 2.4 (Success probability and restart cost).** A full depth-$h$ descent is correct with probability $\mathrm{succ}(\alpha,h) := \alpha^h$; a restart attempt costs $h$ visits.

---

## 3. Law 1: exact DFS backtracking cost

**Theorem 3.1 (DFS Ascent Law).** For all $\alpha$ and all $h \in \mathbb{N}$,
$$C(\alpha, h) \;=\; E_{\mathrm{DFS}}(\alpha, h) \;:=\; h\Big(1 - \frac{K}{2}\Big) + \frac{K\,(3^{h+1} - 3)}{4}, \qquad K = (1-\alpha)(2-\alpha).$$

*Proof sketch.* Induction on $h$. The base case is $0 = 0$. For the step, adding $\mathrm{lvl}(\alpha, h+1) = 1 + K(3^{h+1}-1)/2$ to $E_{\mathrm{DFS}}(\alpha,h)$ produces
$$(h+1)\Big(1-\frac{K}{2}\Big) + \frac{K(3^{h+1}-3)}{4} + \frac{K}{2} + \frac{K(3^{h+1}-1)}{2},$$
and the $K$-terms collect to $K(3^{h+2}-3)/4$ because $\tfrac14(3^{h+1}-3) + \tfrac12 + \tfrac12(3^{h+1}-1) = \tfrac14(3\cdot 3^{h+1} - 3)$. $\square$

The law is a geometric sum in disguise, and its two limits calibrate it against ground truth.

**Proposition 3.2 (Boundary calibration).**
- $E_{\mathrm{DFS}}(0, h) = (3^{h+1}-3)/2$, the exact number of internal nodes of the height-$h$ ternary tree: a blind agent sweeps everything.
- $E_{\mathrm{DFS}}(1, h) = h$: a perfect agent walks straight down.

*Proof.* Substitute $K(0)=2$ and $K(1)=0$ and simplify. $\square$

**Theorem 3.3 (Beam never wins).** Let $B(h) := (3^{h+1}-3)/2$ be the exhaustive level-sweep cost. For every $\alpha \in [0,1]$ and every $h$,
$$E_{\mathrm{DFS}}(\alpha, h) \le B(h),$$
with equality at $\alpha = 0$.

*Proof sketch.* Write $B(h) - E_{\mathrm{DFS}}(\alpha,h) = \tfrac14 (2 - K)\big(3^{h+1} - 3 - 2h\big)$. The first factor is nonnegative by Lemma 2.2; the second is nonnegative because $3^{h+1} \ge 2h+3$, an easy induction ($3^{n+2} = 3\cdot 3^{n+1} \ge 3(2n+3) \ge 2(n+1)+3$). Equality at $\alpha = 0$ is Proposition 3.2. $\square$

Thus the exhaustive sweep is never a rational schedule: it is dominated by DFS uniformly, and the domination is sharp exactly at blindness. Beam is eliminated from the competition, leaving two live schedules.

---

## 4. Law 2: exact restart-from-root cost

**Lemma 4.1 (Geometric trials).** For $p \in (0, 1]$,
$$\sum_{n=0}^{\infty} (n+1)\, p\,(1-p)^n \;=\; \frac{1}{p}.$$

*Proof sketch.* For $p = 1$ every term with $n \ge 1$ vanishes and the sum is $1$. For $p<1$ set $r = 1-p \in [0,1)$ and combine the two standard geometric identities $\sum_n n r^n = r/(1-r)^2$ and $\sum_n r^n = (1-r)^{-1}$, multiplied by $p$; the total is $p\big(r/p^2 + 1/p\big) = (r + p)/p = 1/p$. $\square$

**Theorem 4.2 (Restart Ascent Law).** For $0 < \alpha \le 1$ and every $h$, the expected work of the restart-from-root schedule is exactly
$$\Big(\sum_{n \ge 0} (n+1)\,\alpha^h (1-\alpha^h)^n\Big)\cdot h \;=\; E_{\mathrm{restart}}(\alpha, h) \;=\; \frac{h}{\alpha^h} \;=\; h\,\alpha^{-h}.$$

*Proof.* Each attempt is an independent Bernoulli trial with success probability $p = \alpha^h \in (0,1]$ (positivity from $\alpha>0$; $p \le 1$ from $\alpha \le 1$). Each attempt costs exactly $h$ visits, since under end-verification the searcher always descends the full depth before learning the outcome. Apply Lemma 4.1 and multiply by $h$. $\square$

Two structural facts follow immediately and are used in §7.

**Proposition 4.3 (Geometric compounding of sequential hints).** $\mathrm{succ}(\alpha, h_1 + h_2) = \mathrm{succ}(\alpha,h_1)\cdot \mathrm{succ}(\alpha,h_2)$, and consequently
$$E_{\mathrm{restart}}(\alpha, h_1+h_2) = \frac{h_1 + h_2}{\mathrm{succ}(\alpha,h_1)\,\mathrm{succ}(\alpha,h_2)}.$$

The price of a sequential hint chain is set by the *product* of stage success probabilities. This is the formal content of "branch hints compound".

**Proposition 4.4 (Strict monotonicity in accuracy).** For $0 < \alpha < \beta$ and $h \ge 1$, $E_{\mathrm{restart}}(\beta,h) < E_{\mathrm{restart}}(\alpha,h)$. Similarly, for $\alpha < \beta \le 1$ and $h \ge 1$, $E_{\mathrm{DFS}}(\beta,h) < E_{\mathrm{DFS}}(\alpha,h)$.

*Proof sketch.* For restart, $\alpha^h < \beta^h$ and $h > 0$, so $h/\beta^h < h/\alpha^h$. For DFS, $K$ is strictly decreasing, and the coefficient of $K$ in the law, namely $\tfrac14(3^{h+1}-3) - \tfrac{h}{2}$, is strictly positive for $h \ge 1$ because $3^{h+1} > 2h + 3$. $\square$

Accuracy therefore always has a price within a schedule — a fact worth holding alongside the refutation to come, which says accuracy has no *exponent* below the boundary.

---

## 5. Effective branching is refuted

**Theorem 5.1 (Prefactor asymptotics).** For every $\alpha$,
$$\lim_{h\to\infty} \frac{E_{\mathrm{DFS}}(\alpha,h)}{3^h} \;=\; \frac{3K(\alpha)}{4}.$$

*Proof sketch.* Dividing the closed law by $3^h$ gives the exact identity
$$\frac{E_{\mathrm{DFS}}(\alpha,h)}{3^h} = \Big(1-\frac{K}{2}\Big)\Big(h\,\big(\tfrac13\big)^h\Big) + \frac{3K}{4} - \frac{3K}{4}\big(\tfrac13\big)^h.$$
The first term vanishes because $h\,r^h \to 0$ for $|r|<1$, and the third because $r^h \to 0$. $\square$

**Theorem 5.2 (Effective branching refuted).** For every accuracy $\alpha < 1$,
$$\lim_{h \to \infty} \frac{E_{\mathrm{DFS}}(\alpha, h+1)}{E_{\mathrm{DFS}}(\alpha, h)} \;=\; 3.$$

*Proof sketch.* Write $q_h := E_{\mathrm{DFS}}(\alpha,h)/3^h$. Theorem 5.1 gives $q_h \to L := 3K/4$, and $L \ne 0$ precisely because $K > 0$ for $\alpha < 1$ (Lemma 2.2). Then
$$\frac{E_{\mathrm{DFS}}(\alpha,h+1)}{E_{\mathrm{DFS}}(\alpha,h)} = 3\cdot\frac{q_{h+1}}{q_h} \longrightarrow 3\cdot\frac{L}{L} = 3. \qquad \square$$

This is the refutation in its sharpest form. There is no accuracy $\alpha < 1$ at which the DFS ascent exhibits a base below $3$: the oracle scales the cost curve vertically, by the factor $3K/4$, and does nothing else. An oracle of accuracy $0.99$ has $K = 0.0101$ and buys a factor of $\approx 198$ against the blind agent — worth having, and equal to about four extra levels of depth, after which the exponential has absorbed the entire gain.

Numerically the pinning is visible early. At $\alpha = 0.9$ ($K = 0.11$), $E_{\mathrm{DFS}}(10) = 10\cdot 0.945 + 0.11(3^{11}-3)/4 = 4880.91$ against the predicted leading term $3^{10}\cdot 3K/4 = 4871.54$; the ratio $E(h+1)/E(h)$ is $2.99636$ at $h=10$ and $2.99994$ at $h=14$. At $\alpha = 0.99$ the same ratio is $2.99434$ at $h = 12$.

---

## 6. The dominance boundary and the ascent exponent law

The two live schedules have different bases: $3$ for DFS, $1/\alpha$ for restart. Comparing them is therefore comparing $3$ with $1/\alpha$, and the comparison is exact.

**Lemma 6.1 (Two-sided DFS bounds).** For $\alpha \in [0,1]$:
- (lower) for $h \ge 1$, $\;\dfrac{K}{4}\,3^h \le E_{\mathrm{DFS}}(\alpha, h)$;
- (upper) for all $h$, $\;E_{\mathrm{DFS}}(\alpha, h) \le h + \dfrac{3^{h+1}}{2}$.

*Proof sketch.* The linear term $h(1-K/2)$ is nonnegative since $K \le 2$, so the lower bound reduces to $K(3^{h+1}-3)/4 \ge K\,3^h/4$, i.e. $3^{h+1}-3 \ge 3^h$, true for $h \ge 1$. The upper bound uses $K \le 2$ on the exponential term and $1 - K/2 \le 1$ on the linear one. $\square$

**Theorem 6.2 (Restart dominates above $1/3$).** If $1/3 < \alpha < 1$ then
$$\lim_{h\to\infty} \frac{E_{\mathrm{restart}}(\alpha,h)}{E_{\mathrm{DFS}}(\alpha,h)} = 0.$$

*Proof sketch.* By the lower bound of Lemma 6.1, for $h \ge 1$,
$$\frac{E_{\mathrm{restart}}}{E_{\mathrm{DFS}}} \le \frac{h\alpha^{-h}}{(K/4)3^h} = \frac{4}{K}\;h\Big(\frac{1}{3\alpha}\Big)^{h}.$$
Since $\alpha > 1/3$ we have $1/(3\alpha) < 1$, so $h\,r^h \to 0$ squeezes the ratio to zero. $\square$

**Theorem 6.3 (DFS dominates below $1/3$).** If $0 < \alpha < 1/3$ then
$$\lim_{h\to\infty} \frac{E_{\mathrm{DFS}}(\alpha,h)}{E_{\mathrm{restart}}(\alpha,h)} = 0.$$

*Proof sketch.* By the upper bound of Lemma 6.1,
$$\frac{E_{\mathrm{DFS}}}{E_{\mathrm{restart}}} \le \frac{h + \tfrac32 3^h}{h\alpha^{-h}} \le \alpha^h + \frac32 (3\alpha)^h,$$
using $h \ge 1$. Both terms vanish because $\alpha < 1$ and $3\alpha < 1$. $\square$

Neither schedule merely edges ahead: on its own side of the boundary each beats the other by an unbounded factor. The empirical statement "restart-from-root dominates DFS in $99.0\%$ of cells" is exactly this theorem, evaluated over a parameter grid in which the overwhelming majority of cells have $\alpha > 1/3$.

We can now state the organizing result. Let $E_{\min}(\alpha,h) := \min\{E_{\mathrm{DFS}}(\alpha,h),\,E_{\mathrm{restart}}(\alpha,h)\}$.

**Theorem 6.4 (Ascent Exponent Law).** For $0 < \alpha < 1$,
$$\lim_{h\to\infty} \frac{\log E_{\min}(\alpha, h)}{h} \;=\; \log \min\Big(3, \frac{1}{\alpha}\Big).$$

*Proof sketch.* Two rate computations plus commutation of $\log$ with $\min$ on positives.

*Restart rate.* $\log(h\alpha^{-h})/h = \log h / h + \log(1/\alpha) \to \log(1/\alpha)$, since $\log h / h \to 0$.

*DFS rate.* Write $E_{\mathrm{DFS}} = 3^h \cdot q_h$ with $q_h \to 3K/4 > 0$ (Theorem 5.1). Then $\log E_{\mathrm{DFS}}/h = \log 3 + \log q_h / h \to \log 3$, since $\log q_h$ converges to the finite limit $\log(3K/4)$ and is divided by $h \to \infty$.

*Combination.* For positive $a,b$, $\log\min(a,b) = \min(\log a, \log b)$, and $\min$ is continuous, so the rate of the minimum is the minimum of the rates, $\min(\log 3, \log(1/\alpha)) = \log\min(3, 1/\alpha)$. $\square$

**Corollary 6.5 (The kink).**
- For $0 < \alpha \le 1/3$: $\min(3, 1/\alpha) = 3$. Accuracy is worth *nothing* at the level of the exponent.
- For $1/3 < \alpha < 1$: $\min(3, 1/\alpha) = 1/\alpha < 3$, strictly decreasing in $\alpha$.

The exponent is therefore a continuous but non-differentiable function of accuracy, constant on $(0, 1/3]$ and hyperbolic on $(1/3, 1)$. Note the tension with Proposition 4.4, which is not a contradiction but the precise content of the result: *accuracy always lowers the cost, but only above the kink does it lower the rate*.

Numerically, at $\alpha = 0.5$ the empirical rates $\log E / h$ read: restart $0.92341$ at $h=10$ and $0.78537$ at $h=40$, descending toward $\log 2 = 0.69315$; DFS $1.04109$ at $h=10$ and $1.08423$ at $h=40$, ascending toward $\log 3 = 1.09861$. The minimum tracks $\log(1/\alpha)$. At $\alpha = 0.25 < 1/3$ the roles invert and the minimum tracks $\log 3$.

**Theorem 6.6 (Exponential–polynomial transition at $\alpha = 1$).** $E_{\mathrm{restart}}(1, h) = h$, whereas for every $0 < \alpha < 1$,
$$\lim_{h\to\infty} \frac{E_{\mathrm{restart}}(\alpha,h)}{h} = \lim_{h\to\infty}\Big(\frac{1}{\alpha}\Big)^{h} = \infty.$$

The transition from exponential to polynomial cost is thus not gradual: it happens only *at* $\alpha = 1$. For every accuracy strictly below one, the cost per unit depth diverges.

---

## 7. The master hint law is refuted; a new hint class

A common accounting rule prices a hint by the fraction of the search space it preserves: a hint that keeps a fraction $\theta$ of the space delivers speedup $1/\theta$, and no more. We call this the **class-hint master law**, and define $S_{\mathrm{class}}(\theta) := 1/\theta$.

**Proposition 7.1 (Class-hint cap).** A one-shot class hint on a ternary branching keeps at least a third of the tree, i.e. $\theta \ge 1/3$; hence $S_{\mathrm{class}}(\theta) \le 3$.

*Proof.* $1/\theta \le 3 \iff 1 \le 3\theta$, which is $\theta \ge 1/3$. $\square$

Against this, define the **branch-hint speedup** relative to the uninformed ternary baseline $\alpha = 1/3$, measured with the restart law:
$$S_{\mathrm{branch}}(\alpha, h) := \frac{E_{\mathrm{restart}}(1/3, h)}{E_{\mathrm{restart}}(\alpha, h)}.$$

**Theorem 7.2 (Exact branch-hint speedup).** For $\alpha > 0$ and $h \ge 1$,
$$S_{\mathrm{branch}}(\alpha, h) = (3\alpha)^h.$$

*Proof.* $E_{\mathrm{restart}}(1/3,h) = h\,3^h$ and $E_{\mathrm{restart}}(\alpha,h) = h\alpha^{-h}$; the ratio is $3^h \alpha^h = (3\alpha)^h$. $\square$

**Theorem 7.3 (Master-law mapping refuted).** If $\alpha > 1/3$ then $S_{\mathrm{branch}}(\alpha, h) \to \infty$ as $h \to \infty$. In particular, for every constant $C$ — including the class-hint cap $C = 3$ — there exists $h$ with $S_{\mathrm{branch}}(\alpha,h) > C$.

*Proof.* $3\alpha > 1$, so $(3\alpha)^h \to \infty$. $\square$

**Corollary 7.4 (Sequential hints strictly dominate class hints).** For every $\alpha > 1/3$ and every $\theta$, there is a height $h$ at which the branch-hint speedup exceeds the class-hint speedup $1/\theta$.

The structural explanation is Proposition 4.3: a class hint fires once and prunes once, whereas a branch hint fires at every level and the successes multiply, giving joint success probability $\alpha^{d}$ over a $d$-level chain. The two are not the same kind of resource, and no bounded space-reduction ratio can price the second. This motivates a new entry in the taxonomy of algorithmic hints:

> **Sequential / geometric hints.** A hint resource applied independently at each of $d$ sequential decisions, with joint success probability $\alpha^{d}$, priced by the restart law $h\,\alpha^{-h}$ rather than by a bounded speedup ratio. Its value is unbounded in the depth of the chain whenever $\alpha$ exceeds the reciprocal branching factor.

Empirically the divergence is already visible at small depths: measured speedups of $1.01$, $1.30$, $1.98$, $3.56$, $10.10$ at $\alpha = 1/3,\ \ldots,\ 0.9$ — passing the class-hint cap of $3$ between $\alpha = 0.6$ and $\alpha = 0.7$ and continuing to climb, exactly as $(3\alpha)^h$ requires and exactly contrary to saturation at $1/\theta = 3$.

---

## 8. Breakeven against an exact solver

The laws are exact, so they can answer a decision-theoretic question in advance: *is it worth building the oracle at all?*

Suppose an exact algorithm solves the problem within a budget of $F$ visit-equivalents, and consulting the oracle costs an extra $c \ge 0$ visit-equivalents per step, so that the guided ascent's total cost is $(1+c)\,E_{\mathrm{restart}}(\alpha,h)$.

**Definition 8.1 (Critical accuracy).** $\displaystyle \alpha^\ast(c, F, h) := \Big(\frac{(1+c)\,h}{F}\Big)^{1/h}.$

**Theorem 8.2 (Breakeven is an exact threshold).** For $c \ge 0$, $F > 0$, $h \ge 1$, and $\alpha > 0$,
$$(1+c)\,E_{\mathrm{restart}}(\alpha, h) < F \quad\Longleftrightarrow\quad \alpha > \alpha^\ast(c,F,h).$$

*Proof sketch.* $(1+c)h/\alpha^h < F \iff (1+c)h/F < \alpha^h$. Since $\alpha^\ast$ is by construction the unique nonnegative real with $(\alpha^\ast)^h = (1+c)h/F$, and $x \mapsto x^h$ is strictly increasing on the nonnegatives, this is equivalent to $\alpha^\ast < \alpha$. $\square$

**Proposition 8.3 (Existence and nondegeneracy).** If $(1+c)h < F$ — that is, if even a perfect oracle would beat the budget — then $\alpha^\ast \in (0,1)$, so the threshold is a genuine, attainable accuracy rather than a vacuous one.

*Proof.* Set $t := (1+c)h/F \in (0,1)$; then $\alpha^\ast = t^{1/h} \in (0,1)$. $\square$

**Proposition 8.4 (Comparative statics).** $\alpha^\ast$ is strictly increasing in the per-step overhead $c$: a costlier per-step feature strictly raises the accuracy the oracle must reach.

*Proof.* $t = (1+c)h/F$ is strictly increasing in $c$, and $x \mapsto x^{1/h}$ is strictly increasing on $(0,\infty)$. $\square$

### 8.1 Calibration against an exact benchmark scan

We instantiate the threshold against an exact benchmark scan whose median solve time is $\approx 183{,}000$ steps, stratified by instance type. Three findings:

1. **The majority stratum is winnable but demanding.** A majority-win survives to per-step overheads as large as $c \le 3000$ visit-equivalents per step. Across $c \in [0, 3000]$ the required accuracy rises from $\alpha^\ast \approx 0.85$ to $\alpha^\ast \approx 0.96$ — consistent with Proposition 8.4 and with the mild $1/h$-th-root dependence on $c$ implied by Definition 8.1.
2. **The balanced stratum never wins.** There, the exact scan is already effectively instantaneous: $F$ is so small that $(1+c)h \ge F$ and Proposition 8.3's nondegeneracy condition fails. There is nothing for an oracle to buy.
3. **The deep tail is unwinnable.** For the hardest instances, $F$ is astronomically large — but so is $h$, and the required accuracy is not achievable even at $\alpha = 0.9999$. The failure mode here is the geometric compounding of Proposition 4.3 run backwards: a $10^{-4}$ per-level error rate compounds to near-certain failure over a sufficiently deep chain.

A further **barrier probe** asks whether a per-step feature whose evaluation costs $\Theta(\sqrt{N})$ could ever pay for itself. It cannot — but the exclusion margin is only about $1.7$ orders of magnitude. That is a thin barrier: a fifty-fold cheaper feature evaluation would flip the calculus.

### 8.2 The supply side

Breakeven is a two-sided question: the threshold says what accuracy is *needed*; a measurement says what accuracy is *available*. The best-characterized candidate signal channel carries roughly $19\%$ of the relevant entropy, and its raw predictive accuracy sits near the majority baseline — far below the $\alpha^\ast \ge 0.85$ that §8.1 demands. The channel is real and measurable; it simply is not loud enough to buy an ascent win today. Quantifying the gap from both ends — demand $\alpha^\ast \ge 0.85$, supply $\approx$ baseline — is more informative than either number alone, because it converts an open-ended engineering question into a stated target.

A secondary observation from the same data is a cautionary note about pooled statistics: the rank correlation between the branching-depth statistic and exact-solver step count is $-0.364$ when pooled over all strata but $+0.443$ *within* the dominant stratum. A previously reported anti-correlation is therefore stratum-dependent — a textbook sign reversal of the kind that pooled correlations invite, and a reminder that breakeven analysis must be run per-stratum, as in §8.1.

---

## 9. Universality: removing the number three

Nothing in §§3–7 used ternarity beyond arithmetic. We now show the entire theory is a one-parameter family, with the ternary case one point of it.

**Definition 9.1 (General DFS law).** For $b > 1$ and level waste weight $w$, set
$$\mathrm{lvl}_b(w, j) := 1 + \frac{w\,(b^j - 1)}{b-1}, \qquad C_b(w,0) := 0,\quad C_b(w,h+1) := C_b(w,h) + \mathrm{lvl}_b(w,h+1),$$
$$E_b(w, h) := h\Big(1 - \frac{w}{b-1}\Big) + \frac{w\,(b^{h+1} - b)}{(b-1)^2}.$$
Here $(b^j-1)/(b-1)$ is the node count of a complete wrong $b$-ary subtree at level $j$.

**Theorem 9.2 (Exact general DFS law).** For $b > 1$ and every $w$ and $h$, $C_b(w,h) = E_b(w,h)$.

*Proof sketch.* Induction on $h$, exactly as Theorem 3.1, with $(b-1)$ in place of $2$; the algebra is a single clearing of denominators over $(b-1)^2$. $\square$

**Proposition 9.3 (Specialization).** $E_3\big(K(\alpha), h\big) = E_{\mathrm{DFS}}(\alpha, h)$ for every $\alpha$ and $h$.

*Proof.* Substitute $b=3$: $1 - w/(b-1) = 1 - K/2$ and $w(b^{h+1}-b)/(b-1)^2 = K(3^{h+1}-3)/4$. $\square$

**Standing assumptions.** For the asymptotic and comparison results we require $b \ge 2$ (a branching factor below $2$ is not a branching factor, and $b^h \ge 2$ for $h \ge 1$ is used in the lower bound) and $0 < w \le b-1$ (a level cannot waste more than its wrong siblings; larger $w$ makes the linear term negative and admits negative "costs").

**Theorem 9.4 (General prefactor asymptotics).** For $b>1$ and every $w$,
$$\lim_{h\to\infty} \frac{E_b(w,h)}{b^h} = \frac{w\,b}{(b-1)^2}.$$

*Proof sketch.* As in Theorem 5.1, using the exact decomposition
$$\frac{E_b(w,h)}{b^h} = \Big(1 - \frac{w}{b-1}\Big) h\Big(\frac1b\Big)^h + \frac{wb}{(b-1)^2} - \frac{wb}{(b-1)^2}\Big(\frac1b\Big)^h,$$
and $1/b < 1$. $\square$

**Theorem 9.5 (Effective branching refuted at every branching factor).** For $b>1$ and $w>0$,
$$\lim_{h\to\infty} \frac{E_b(w,h+1)}{E_b(w,h)} = b.$$

*Proof sketch.* Identical to Theorem 5.2, the nonvanishing of the limit $wb/(b-1)^2$ coming from $w>0$. $\square$

**Lemma 9.6 (General two-sided bounds).** For $b \ge 2$, $0 < w \le b-1$:
$$\frac{wb}{2(b-1)^2}\,b^h \;\le\; E_b(w,h)\quad (h \ge 1), \qquad E_b(w,h) \;\le\; h + \frac{b}{b-1}\,b^h \quad (\text{all } h).$$

*Proof sketch.* The linear term is nonnegative exactly because $w \le b-1$. For the lower bound, $b^{h+1} - b = b(b^h - 1)$ and $b^h - 1 \ge b^h/2$ for $b^h \ge 2$, which holds at $h \ge 1$ since $b\ge2$. For the upper bound, again $b^{h+1}-b = b(b^h-1) \le b\,b^h$ and $w/(b-1) \le 1$. $\square$

**Theorem 9.7 (Crossover at the reciprocal branching factor).** Let $b \ge 2$, $0 < w \le b-1$, $\alpha > 0$.
- If $\alpha > 1/b$ then $E_{\mathrm{restart}}(\alpha,h)/E_b(w,h) \to 0$.
- If $\alpha < 1/b$ then $E_b(w,h)/E_{\mathrm{restart}}(\alpha,h) \to 0$.

*Proof sketch.* Substituting the bounds of Lemma 9.6 gives, in the first case, the majorant $\tfrac{2(b-1)^2}{wb}\,h\,(1/(\alpha b))^h \to 0$ since $\alpha b > 1$; and in the second, the majorant $\alpha^h + \tfrac{b}{b-1}(\alpha b)^h \to 0$ since $\alpha b < 1$ and $\alpha < 1$. $\square$

**Theorem 9.8 (General Ascent Exponent Law).** For $b \ge 2$, $0 < w \le b-1$, $\alpha > 0$, with $E^{(b)}_{\min}(h) := \min\{E_b(w,h), E_{\mathrm{restart}}(\alpha,h)\}$,
$$\lim_{h\to\infty} \frac{\log E^{(b)}_{\min}(h)}{h} = \log \min\Big(b, \frac{1}{\alpha}\Big),$$
and the kink is exactly at $\alpha = 1/b$: $\min(b, 1/\alpha) = b$ for $\alpha \le 1/b$ and $= 1/\alpha$ for $\alpha \ge 1/b$.

*Proof sketch.* The general DFS log-rate is $\log b$ by Theorem 9.4 plus the argument of Theorem 6.4; the restart log-rate is $\log(1/\alpha)$ unchanged; combine by $\log\min = \min\log$. $\square$

The $1/3$ of the ternary theory was $1/b$ all along. The phase boundary sits at the accuracy of a uniform random guess over $b$ alternatives — which is to say, the boundary is not a fact about trees at all but a fact about where the accuracy scale is anchored.

**Worked instance ($b=5$).** With $w = b - 1 = 4$ (a blind agent) at $h = 6$: $E_5(4,6) = 4(5^7-5)/16 = 19{,}530$, exactly the internal-node count of a depth-$6$ quinary tree, and $E_5(4,7)/E_5(4,6) = 5.00026$. With $w = 0.2$ (a twentyfold better oracle) the same ratio is $4.97801$: the base is $5$ either way, the prefactor differs by $20$. For restart at $b=5$ the crossover accuracy is $0.2$: at $\alpha = 0.15 < 1/5$, $E_{\mathrm{restart}}(8) = 8/0.15^8 = 3.12\times 10^7$ against $E_5(1,8) = 1.22\times 10^5$, so DFS wins; at $\alpha = 0.25 > 1/5$, $E_{\mathrm{restart}}(8) = 5.24\times 10^5$ and restart pulls ahead as $h$ grows, the ratio falling like $(1/(5\cdot 0.25))^h$.

---

## 10. Algorithmic reading

The results yield a short decision procedure for a practitioner holding a branch heuristic.

**Schedule selection.** Given branching $b$ and estimated accuracy $\alpha$: if $\alpha > 1/b$, use restart-from-root and expect cost $h\alpha^{-h}$; if $\alpha < 1/b$, use DFS with backtracking and expect cost $\approx \tfrac{wb}{(b-1)^2}b^h$; never use an exhaustive sweep. The decision is a single comparison and its consequence is an unbounded factor in either direction.

**Value accounting.** Do not report a heuristic's value as an "effective branching factor" unless you are in the restart regime; inside a backtracking search under end-verification, the correct statement is *cost multiplier* $w/(b-1)$ relative to blind, with the base untouched. Reporting an effective base for a backtracking search is not conservative — it is wrong by an unbounded factor as depth grows.

**Feasibility screening.** Before building the heuristic, compute $\alpha^\ast = ((1+c)h/F)^{1/h}$ from the exact solver's budget $F$, the intended depth $h$, and an estimate of per-step overhead $c$. If $\alpha^\ast$ exceeds what any measured channel can plausibly deliver, the project is excluded before implementation. Run this per stratum, never pooled (§8.2).

**Depth budgeting.** Since accuracy compounds geometrically (Proposition 4.3), the maximal depth reachable within a work budget $W$ at accuracy $\alpha$ under restart is the largest $h$ with $h\alpha^{-h} \le W$, i.e. $h \lesssim \log W / \log(1/\alpha)$. Halving the error rate $1-\alpha$ near $\alpha \approx 1$ roughly doubles the reachable depth; this is the correct way to convert an accuracy improvement into a capability statement.

---

## 11. Discussion

The results split cleanly into a negative half and a positive half.

*Negatively*, two widely used accounting devices are refuted. The effective branching factor is not a property of an oracle inside a backtracking search: the base is pinned at the structural branching factor for every accuracy below $1$ (Theorems 5.2, 9.5). And the class-hint master law, which caps a hint's speedup at $1/\theta$, does not extend to sequential hints, whose speedup $(b\alpha)^h$ diverges (Theorem 7.3). Both failures have the same root: they price a hint by a one-shot space reduction, and a sequential hint is not a one-shot object.

*Positively*, the correct pricing is a pair of exact laws whose combination is the kinked exponent $\min(b, 1/\alpha)$. The kink is a genuine phase boundary — non-analytic, with unbounded dominance on both sides — and it sits at the accuracy of random guessing. Below it, accuracy is a discount; above it, accuracy is a rate. This distinction is operationally decisive and is invisible to any analysis that considers only one schedule.

Three limitations bound the scope honestly. First, independence: accuracy is assumed constant and independent across levels. Real oracles are correlated and depth-dependent, and the correct generalization (see D3 below) replaces $\alpha^h$ by $\prod_j \alpha_j$, making the *geometric mean* accuracy the only statistic that matters. Second, end-verification: with partial verification the entire structure changes, and quantifying that change is the most valuable open direction (D4). Third, the waste weight $w$ is an aggregate of the oracle's error structure; the derivation $w = (1-\alpha)(2-\alpha)$ at $b=3$ is a specific model of which wrong siblings get expanded, and other error structures give other $w$ within the admissible band $(0, b-1]$ — but by Theorem 9.5 they all give the same base, which is why the theory is robust to that modelling choice.

---

## 12. Future directions

**D1. Optimality of the two-schedule envelope.** We conjecture that $\min(b, 1/\alpha)$ is not merely the best of two hand-picked schedules but the *information-theoretic floor* for any end-verification search: a schedule can only spend visits on descents, and a descent of length $d$ is correct with probability $\alpha^d$, so any policy is a mixture of "restart-like" behaviour (paying $1/\alpha$ per unit depth) and "sweep-like" behaviour (paying $b$ per unit depth). With both exact laws and their common exponent in place, the statement to beat is precise: no policy has exponent below $\min(b, 1/\alpha)$.

**D2. Cutoff-restart interpolation and the absence of an intermediate base.** Restart-with-cutoff-depth $d < h$ — descend $d$ levels guided, then sweep the remaining $h-d$ — has an exponent that is a depth-weighted combination of the two stages, so the achievable exponents form the *segment* between $1/\alpha$ and $b$, yet the optimum should always sit at an endpoint. Both endpoints are attained exactly, and the interpolation is a one-parameter family whose cost is a product of the two established laws.

**D3. Accuracy schedules: depth-dependent oracles.** A real oracle is not uniformly accurate; its accuracy $\alpha_j$ decays with depth, and the restart law becomes $h / \prod_j \alpha_j$ — the geometric mean accuracy is the only statistic that matters. The compounding identity of Proposition 4.3 is the seed; the geometric-mean reduction is the natural next result and immediately predicts which measured per-level channels can matter.

**D4. Verification cost as the hidden third resource.** End-verification-only is one extreme of a family in which a partial verifier fires every $k$ levels at cost $v$. The optimal $k$ should scale like $\log_b(1/v)$, and the exponent should drop from $\min(b, 1/\alpha)$ toward $1$ as $v \to 0$. The barrier probe of §8.1 excludes a $\sqrt{N}$-cost per-step feature by only about $1.7$ orders of magnitude, so this family is exactly where the thin margins live.

---

## 13. Summary of results

| Result | Statement |
|---|---|
| DFS Ascent Law | $E_{\mathrm{DFS}}(h) = h(1-K/2) + K(3^{h+1}-3)/4$, $K=(1-\alpha)(2-\alpha)$ |
| Restart Ascent Law | $E_{\mathrm{restart}}(h) = h\,\alpha^{-h}$ |
| Boundary calibration | $E_{\mathrm{DFS}}(0,h) = (3^{h+1}-3)/2$; $E_{\mathrm{DFS}}(1,h) = h$ |
| Beam never wins | $E_{\mathrm{DFS}}(\alpha,h) \le (3^{h+1}-3)/2$ for all $\alpha\in[0,1]$ |
| Effective branching refuted | $E_{\mathrm{DFS}}(h+1)/E_{\mathrm{DFS}}(h) \to 3$ for all $\alpha < 1$ |
| Prefactor | $E_{\mathrm{DFS}}(h)/3^h \to 3K/4$ |
| Dominance boundary | restart wins unboundedly iff $\alpha > 1/3$; DFS iff $\alpha < 1/3$ |
| Ascent exponent law | $\log E_{\min}(h)/h \to \log\min(3, 1/\alpha)$, kink at $\alpha = 1/3$ |
| Phase transition | $E_{\mathrm{restart}}(1,h)=h$; $E_{\mathrm{restart}}(\alpha,h)/h \to \infty$ for $\alpha<1$ |
| Hint speedup | $S_{\mathrm{branch}}(\alpha,h) = (3\alpha)^h$, unbounded for $\alpha > 1/3$ |
| Master law refuted | class cap $1/\theta \le 3$ is exceeded at some depth for every $\alpha > 1/3$ |
| Breakeven | $(1+c)E_{\mathrm{restart}} < F \iff \alpha > ((1+c)h/F)^{1/h}$ |
| Comparative statics | $\alpha^\ast$ strictly increasing in $c$ |
| Universality | $E_b(w,h) = h(1-\tfrac{w}{b-1}) + \tfrac{w(b^{h+1}-b)}{(b-1)^2}$; ratio $\to b$; kink at $\alpha = 1/b$; exponent $\min(b,1/\alpha)$ |
