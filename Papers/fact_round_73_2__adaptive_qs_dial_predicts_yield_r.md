# A Good Predictor, a Bad Knob

### How a well-calibrated dial lost 17.6% of a computation — and what it was actually good for

---

## 0 · The situation, in one paragraph

You have a big computation split into many independent **targets**. Each target, per unit of
effort you spend on it, hands back a certain number of useful outputs; call that number the
target's **rate** $r_i$. You have a fixed budget $B$ of effort to divide among $n$ targets,
and — this is the interesting part — you have built a cheap **dial** that predicts each
target's rate *before* you spend anything.

The dial is good. Ranked against reality it agrees about $74\%$ of the time; a perfect
oracle dial, scored against the same noisy realised outputs, manages $78\%$. So you use it
in the obvious way: **spend more where the yield is thin**, sieve length inversely
proportional to the predicted rate, so that every target ends up contributing its fair share.

Output fell by $17.6\%$. With an engineering safety floor removed, it fell by $146.7\%$. A
policy running in the *opposite* direction gained $8.6\%$, and an oracle would have gained
$74.8\%$.

This page is about why — and the answer is not "the dial wasn't good enough."

> **The one-sentence spoiler.** The equalising policy delivers the budget times the
> *harmonic* mean of the rates; doing nothing clever delivers the budget times the
> *arithmetic* mean; and the harmonic mean is never larger. The loss has nothing to do with
> prediction quality at all.

---

## 1 · Play with it before you read the proof

The workbench below is the whole theory in four panels. Drag the six rates. Watch the four
policy yields at the top left. Then hit the **equal rates** preset and notice that every
policy suddenly ties — the loss vanishes *exactly* when the dial stops carrying information.

{{interactive_demo:0}}

Three things to try, in order:

1. **Panel 1, preset “spread rates”.** Note the gap between the baseline and the unclipped
   policy. Now widen the spread by dragging $r_1$ up. The loss grows. *A better dial makes
   this policy worse.*
2. **Panel 2, drag the floor slider to 0.** The yield slides down a perfectly straight line.
   That single line is the entire explanation of "$-17.6\%$ with the clip, $-146.7\%$
   without".
3. **Panel 4, drag $d_2$ below $d_3$** so the dial ranks two targets backwards. Watch the
   inversion count jump to $1$ and — this is the punchline of the second half of the page —
   watch how *little* that mistake actually costs compared with the crude accounting.

---

## 2 · The model, stated once

Targets $i = 1,\dots,n$ have rates $r_i > 0$. An **allocation** $\ell$ assigns sieve length
$\ell_i \ge 0$ with $\sum_i \ell_i = B$. The **yield** is
$$Y(\ell) \;=\; \sum_{i=1}^{n} r_i \,\ell_i .$$

Four policies compete:

| name | allocation | slogan |
|---|---|---|
| uniform baseline | $\ell_i = B/n$ | do nothing clever |
| inverse-rate | $\ell_i = B r_i^{-1}\big/\sum_j r_j^{-1}$ | prop up the weak |
| clipped, floor $f$ | $\ell_i = f + (B - nf)\,r_i^{-1}\big/\sum_j r_j^{-1}$ | prop up the weak, but not too hard |
| concentrator | everything on one maximal-rate target | back the winner |

<details>
<summary><strong>Why the inverse-rate allocation has that exact form (click to expand)</strong></summary>

"Inversely proportional to the rate" fixes $\ell_i = c\, r_i^{-1}$ for some constant $c$;
the budget constraint $\sum_i \ell_i = B$ then forces $c = B/\sum_j r_j^{-1}$. There is
nothing to choose. Likewise the clipped version hands out $f$ to everybody first, leaving
$B - nf$ to distribute, and splits *that* inversely by rate — so $f = 0$ recovers the raw
policy and $f = B/n$ leaves nothing to split, i.e. is exactly the uniform baseline.
</details>

---

## 3 · The two-line theorem

**Uniform baseline.** $Y = \frac{B}{n}\sum_i r_i = B \cdot \operatorname{AM}(r)$.

**Inverse-rate policy.** Each target contributes
$r_i \ell_i = r_i \cdot B r_i^{-1}/T = B/T$ with $T = \sum_j r_j^{-1}$ — *the same amount for
every target*. Summing $n$ identical terms,
$$Y \;=\; \frac{Bn}{T} \;=\; B \cdot \operatorname{HM}(r).$$

That is the whole content of "equalising": the policy is designed to make every target
contribute equally, and it succeeds perfectly. And then:

> **Theorem (the inverse-rate policy never wins).** For positive rates and $B \ge 0$,
> $$B\cdot\operatorname{HM}(r) \;\le\; B\cdot \operatorname{AM}(r),$$
> with strict inequality whenever $B > 0$ and two rates differ.

<details>
<summary><strong>Click to reveal the proof — a symmetrisation over pairs</strong></summary>

The claim is equivalent to $n^2 \le \big(\sum_i r_i\big)\big(\sum_i r_i^{-1}\big)$. Expand
the product over ordered pairs:
$$\Big(\sum_i r_i\Big)\Big(\sum_j r_j^{-1}\Big) \;=\; \sum_{(i,j)} \frac{r_i}{r_j}.$$
The same product also equals $\sum_{(i,j)} r_j/r_i$ — just swap which factor supplies which
index. Adding the two expressions,
$$2\Big(\sum_i r_i\Big)\Big(\sum_j r_j^{-1}\Big) \;=\; \sum_{(i,j)}\left(\frac{r_i}{r_j} + \frac{r_j}{r_i}\right).$$
Now the elementary identity, for $x, y > 0$,
$$\frac{x}{y} + \frac{y}{x} - 2 \;=\; \frac{(x-y)^2}{xy} \;\ge\; 0,$$
strict exactly when $x \ne y$. Each of the $n^2$ ordered pairs contributes at least $2$, so
the sum is at least $2n^2$; and if $r_a \ne r_b$ for some pair, that pair alone contributes
strictly more. $\blacksquare$

The symmetrisation is worth the extra line because it delivers the *strict* case for free,
and strictness is exactly what the application needs: the loss is real, not marginal,
precisely when the dial is informative. This is the classical
[AM–GM–HM chain of inequalities](https://en.wikipedia.org/wiki/HM-GM-AM-QM_inequalities) in
its sharpest usable form.
</details>

**Read the statement carefully.** The rate vector in it is the *true* one. No predictor
appears. A dial with perfect foresight, plugged into this policy, still loses — and loses
by exactly
$$1 - \frac{\operatorname{HM}(r)}{\operatorname{AM}(r)} = 1 - \frac{n^2}{\big(\sum_i r_i\big)\big(\sum_i r_i^{-1}\big)},$$
a functional of the rate distribution and of nothing else.

---

## 4 · The safety floor was doing all the work

The floor clip looks like defensive engineering. It is in fact a *coordinate*.

> **Theorem (the clip line).** For any floor $f$,
> $$Y(f) \;=\; \frac{Bn}{T} \;+\; f\left(\sum_i r_i - \frac{n^2}{T}\right),$$
> which is affine in $f$ with slope $\ge 0$ — strictly positive as soon as two rates differ.
> Its endpoints are $f = 0$ (the unclipped policy) and $f = B/n$ (the uniform baseline).

<details>
<summary><strong>Click for the computation and why the slope's sign is the same theorem again</strong></summary>

Termwise, $r_i\ell_i(f) = r_i f + (B - nf)/T$, because the second piece equalises just as
before. Summing over $i$,
$$Y(f) = f\sum_i r_i + \frac{n(B - nf)}{T} = \frac{Bn}{T} + f\left(\sum_i r_i - \frac{n^2}{T}\right).$$
The slope is nonnegative iff $\sum_i r_i \ge n^2/T$ iff $\big(\sum r\big)\big(\sum r^{-1}\big) \ge n^2$
— i.e. iff AM–HM. So the *same* inequality that dooms the policy also guarantees that the
clip helps.
</details>

Slide the floor in **Panel 2** above. The measured pair of numbers, $-17.6\%$ and $-146.7\%$,
are two points on that line; removing the clip is nothing more exotic than travelling to its
lower endpoint. And since the top endpoint *is* the uniform baseline, no clip value can ever
push this family above doing nothing clever.

{{visualization:0}}

The right panel of that figure is the moral in a single curve: the loss of the equalising
policy grows monotonically with the spread of the rates, i.e. with the amount that a good
dial has to tell you.

---

## 5 · The other direction, and the ceiling

If spreading is wrong, concentrating should be right, and it is: putting the entire budget
on a maximal-rate target yields $B\,r_{\max} \ge B\cdot\operatorname{AM}(r)$, since the
maximum dominates the mean. That is the measured $+8.6\%$, the same inequality read
backwards.

How much is on the table altogether?

> **Theorem (the oracle bound, attained).** Every allocation with $\ell \ge 0$ and
> $\sum_i \ell_i = B$ satisfies $Y(\ell) \le B\,r_{\max}$; the concentrator attains it.
> Hence the headroom of the baseline is exactly $B\big(r_{\max} - \operatorname{AM}(r)\big)$,
> and at most a factor $n$ above it.

*Proof:* $\sum_i r_i \ell_i \le \sum_i r_{\max}\ell_i = B\,r_{\max}$, termwise, using
$\ell_i \ge 0$. Attainment is the previous paragraph. $\blacksquare$

So the measured $+74.8\%$ is not a loose estimate of unclaimed gain — it is exactly the
spread between the best target and the average one.

Run the audit yourself:

{{algorithm:0}}

---

## 6 · The flip: stop reallocating, start refusing

Here is what actually worked in deployment. Do not vary *how much* effort each target gets.
Use the dial to decide *which targets to work on at all*: fix a threshold $\theta$, keep the
targets whose dial value is at least $\theta$, defer the rest. In the field this skipped
$28.3\%$ of the work while retaining $89.5\%$ of the relations — a $28.9\%$ throughput gain.

Call a split of the targets **separated** if every kept target has rate at least that of
every deferred one. A threshold on a rank-faithful dial always produces a separated split,
and then:

> **Theorem (retention beats work fraction).** For a separated split $s = K \sqcup D$,
> $$\frac{\sum_{i \in K} r_i}{\sum_{i \in s} r_i} \;\ge\; \frac{|K|}{|s|},$$
> equivalently the throughput (yield per unit of work) never falls, and rises strictly as
> soon as a genuinely worse target is deferred.

<details>
<summary><strong>Click for the two-line proof</strong></summary>

Write $\Sigma_K, \Sigma_D$ for the kept and deferred totals. Summing the separation
hypothesis $r_j \le r_i$ over all $(i,j) \in K \times D$ gives $|K|\Sigma_D \le |D|\Sigma_K$.
Therefore
$$|K|\big(\Sigma_K + \Sigma_D\big) \;\le\; |K|\Sigma_K + |D|\Sigma_K \;=\; |s|\,\Sigma_K,$$
which rearranges to the claim. $\blacksquare$

Note what is *not* assumed: no independence, no distributional model, no calibration. Only
the ordering.
</details>

Drag the **keep top k** slider in Panel 3 of the workbench: the curve of retention against
work never crosses below the diagonal. Here is the same picture for the true rates of an
actual factor base:

{{visualization:1}}

The flat stretch at the right-hand side is the *null tail* — targets that produce nothing at
any depth. We will see in §8 that they are null for an exact arithmetic reason.

---

## 7 · What a wrong ranking actually costs

The deployed dial is not rank-faithful; it makes mistakes. The right way to charge for them
is not by prediction error but by **inversions**: pairs $(j,i)$ where the dial says $j$ is
worse but the truth says $j$ is better.

A first bound charges each inversion the largest rate $M$:
$$|K|\sum_{i\in s} r_i \;\le\; |s|\sum_{i \in K} r_i \;+\; M\,|\mathrm{Disc}| .$$
Degradation is **linear** in the number of mistakes, and it collapses to the exact
separated statement when there are none. But it is crude. The refinement charges each
inversion its *actual* rate gap — the **inversion mass**
$$\mathrm{IM} = \sum_{(j,i)\in\mathrm{Disc}} (r_j - r_i),$$
which never exceeds $M|\mathrm{Disc}|$, vanishes exactly for faithful dials, and can be
tenfold smaller in practice.

And the truth is better still — it is an *identity*:

> **Theorem (the ledger).** At any threshold,
> $$\underbrace{|K_\theta|\sum_{i\in s} r_i - |s|\sum_{i \in K_\theta} r_i}_{\text{retention deficit}} \;=\; \underbrace{\mathrm{IM}_\theta}_{\text{mass paid on inverted pairs}} \;-\; \underbrace{\mathrm{CM}_\theta}_{\text{mass earned on correct pairs}} .$$

<details>
<summary><strong>Click to see where the identity comes from</strong></summary>

Expanding the double sum over deferred × retained pairs,
$$\sum_{(j,i) \in D\times K}(r_j - r_i) = |K|\Sigma_D - |D|\Sigma_K = |K|\sum_s r - |s|\sum_K r,$$
using $\sum_s r = \Sigma_K + \Sigma_D$ and $|s| = |K| + |D|$. Now split each term by sign
with $x = x^{+} - (-x)^{+}$: the positive parts of $r_j - r_i$ are the mass paid, the
positive parts of $r_i - r_j$ are the mass earned. $\blacksquare$

Dropping the earned half gives the one-sided budget, which is therefore tight exactly when
the dial is never right about a deferred/retained pair — a regime no informative dial is in.
</details>

**This is the real criterion for deploying a dial**, and it is *not* a rank-correlation
threshold: a dial is worth using when it earns more mass than it pays. Panel 4 of the
workbench computes the ledger live; the code is here:

{{algorithm:2}}

---

## 8 · Where the barren targets come from (and this part is not statistics)

The sieve is looking for primes $p$ dividing values $x^2 - N$. Whether a given $p$ *ever*
divides such a value is decided by a congruence you have met before:
$$x^2 \equiv N \pmod p .$$

> **Theorem.** Let $p$ be an odd prime with $N \not\equiv 0$. If $N$ is a
> [quadratic residue](https://en.wikipedia.org/wiki/Quadratic_residue) mod $p$, this
> congruence has **exactly two** solutions per period; otherwise it has **exactly zero**.
> Consequently the per-period hit rate is exactly
> $$\rho(p) = \frac{2}{p} \quad\text{or}\quad \rho(p) = 0,$$
> with nothing in between and nothing random.

<details>
<summary><strong>Click for the argument</strong></summary>

Modulo a prime, $\mathbb{Z}/p$ is a field. If $N = b^2$ with $b \ne 0$, then $x^2 = b^2$ iff
$(x-b)(x+b) = 0$ iff $x = b$ or $x = -b$, and for odd $p$ these are distinct — exactly two
solutions. If $N$ is not a square, there are none by definition. Counting inside a window of
length $p$ is the same as counting in $\mathbb{Z}/p$, because reduction mod $p$ is a
bijection from $\{0,\dots,p-1\}$. $\blacksquare$
</details>

Three consequences follow immediately, and each one closes a loop opened earlier on this page.

- **The dial is not a proxy for the rate — it *is* the rate**, up to the deterministic factor
  $2/p$. Whatever a correlation coefficient below $1$ is measuring, it is noise in the
  finite-window realisation, not error in the dial.
- **The hard tail is unreachable by construction.** A non-residue prime divides *no* value
  $x^2 - N$ whatsoever, at any depth. In the run, $40$ of $400$ targets were of this kind.
  Moving any positive budget off such a target onto a live one strictly increases yield.
  Deferral is the instrument; depth is not.
- **Small admissible primes carry the yield**, since $2/p$ decreases in $p$ — which is
  precisely why concentrating gains and spreading loses.

Summing over the admissible primes $A$ of a factor base gives a closed form,
$$R(A) = \sum_{p \in A}\frac{2}{p} = 2H_A, \qquad H_A = \sum_{p\in A}\frac1p,$$
with the inadmissible primes contributing exactly nothing. The oracle target is the
*smallest* admissible prime, with rate $2/p_{\min}$, and the ratio of oracle to mean is
exactly
$$\frac{|A|}{p_{\min}\,H_A},$$
strictly below the crude ceiling $|A|$ once the base has two primes.

---

## 9 · One number instead of $2^n$ schedules

A deployment does not have to accept threshold policies on faith. Suppose you must collect a
quota $Q$ of relations, and may pick *any* subset of targets — $2^n$ choices.

> **Theorem (the policy space collapses).** Among subsets of a given size, every maximiser of
> total rate is separated. Hence the minimum-work quota-feasible schedule may always be taken
> separated, every separated schedule sits inside a single threshold set, and therefore:
> whenever the quota is attainable at all, it is attained by **one threshold** on the rate
> dial, with throughput at least that of working on everything.

<details>
<summary><strong>Click for the exchange argument, and for the one loose end (ties)</strong></summary>

*Maximisers are separated.* If $i$ is retained, $j$ is deferred, and $r_j > r_i$, then
swapping them keeps the size and strictly increases the total — contradicting maximality.

*The loose end.* A threshold retains *every* target whose rate equals $\theta$, so it can
overshoot a minimal schedule. The overshoot is exactly the tie class and nothing more. But
on a genuine factor base $p \mapsto 2/p$ is injective, so distinct primes have distinct
rates, there are no ties, and the threshold policy is **exactly** minimum-work.
</details>

{{algorithm:1}}

**The honest trade-off.** Raising the threshold never lowers throughput — so on throughput
alone the optimum is degenerate: keep only the single best target. Raising it never raises
total yield, and strictly lowers it once a live target is deferred. The two headline numbers,
"$+28.9\%$ throughput" and "$89.5\%$ retention", move in opposite directions *by theorem*.
Choosing $\theta$ is choosing which constraint binds: wall-clock, or relations.

---

## 10 · Check everything yourself

The following runs every claim on this page against explicit numbers in exact rational
arithmetic — no floating point, no rounding, no wiggle room. It verifies the two mean
formulas, the affine clip law at a grid of floors, the oracle bound and its attainment, the
retention inequality, the paid-minus-earned identity at several thresholds, the agreement of
the greedy prefix schedule with a brute-force search over all $2^n$ subsets, and the exact
values $2/p$ and $0$ of the arithmetic rates — finishing with a $300$-instance randomised
stress test.

{{demo:0}}

---

## 11 · The moral

A **predictor** and a **policy** are different objects, and a good predictor wired into a bad
policy produces exactly the evidence that would convict the predictor. Nothing in the
$-17.6\%$ was about the dial; the number is a measurement of
$1 - \operatorname{HM}(r)/\operatorname{AM}(r)$, wearing a disguise.

The rescue was not a better forecast. It was noticing that the loss had the shape of a
classical mean inequality — a quantity blind to forecast accuracy — and then re-deploying the
same forecast in the one place where separation makes it monotone: not *where do I spend
more*, but *what do I refuse to spend on at all*.

<details>
<summary><strong>Further reading, and the open questions this leaves</strong></summary>

Background on the underlying computation:
[the quadratic sieve](https://en.wikipedia.org/wiki/Quadratic_sieve),
[quadratic residues and the Legendre symbol](https://en.wikipedia.org/wiki/Legendre_symbol),
[Mertens' theorems](https://en.wikipedia.org/wiki/Mertens%27_theorems) for sums of prime
reciprocals, and [Kendall's tau](https://en.wikipedia.org/wiki/Kendall_rank_correlation_coefficient)
for the inversion count that the ledger of §7 refines.

Open:
1. **Nonlinear yield curves** — replace $r_i\ell_i$ by a concave $g_i(\ell_i)$ modelling
   saturation. Does the sign of the equalising rule survive, and is the clip still a
   monotone coordinate?
2. **Analytic control of the headroom** — the ratio is exactly $|A|/(p_{\min}H_A)$; combining
   this with classical estimates for $\sum_{p \le B} 1/p$ over an admissible subfamily should
   give a closed-form asymptotic.
3. **The Pareto frontier in $\theta$** — throughput up, total yield down; what is the optimum
   at a stated exchange rate between wall-clock and relations?
4. **Ledger-driven dial design** — build dials that maximise earned-minus-paid mass directly,
   rather than a rank statistic.
5. **Beyond a single threshold** — let depth vary on the retained set, which reintroduces the
   allocation problem inside it, where the linear model says "concentrate" and practice says
   otherwise.
</details>
