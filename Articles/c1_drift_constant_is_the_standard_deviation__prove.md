# The Exact Price of Alignment

## How much does a language model really change when you nudge it toward a reward?

Imagine you have a machine that produces text — or images, or moves in a game — according to some
probability distribution $p$. Call $p$ the *base policy*: it is what the machine does before anyone
tries to improve it. Now someone hands you a **reward** $r$, a number attached to each possible
output, meant to capture "how good" that output is. Helpfulness. Harmlessness. Politeness. Whatever
the humans who wrote it were trying to encode.

You want the machine to score better on $r$. But you do not want to break it. The base policy is the
result of enormous effort; it knows grammar, facts, style, the whole texture of language. If you
optimize $r$ too hard you get a machine that has learned to game the reward — one that produces
strings of sycophantic filler because sycophancy scored well — and lost everything else.

So you compromise. You ask for the distribution that maximizes expected reward *minus* a penalty for
straying from $p$, the penalty measured in relative entropy. The answer to that optimization is old,
clean, and universal — it is the **Gibbs policy**, or exponential tilt:

$$\pi_\beta(y) \;=\; \frac{p(y)\,e^{r(y)/\beta}}{\sum_z p(z)\,e^{r(z)/\beta}}.$$

Every output's probability is multiplied by an exponential factor in its reward, then renormalized.
The knob $\beta > 0$ is the **temperature** of the constraint: small $\beta$ means aggressive
optimization; large $\beta$ means you barely move at all. This is not a heuristic — it is exactly the
maximizer of $\mathbb{E}_q[r] - \beta\,\mathrm{KL}(q\|p)$ over all distributions $q$. It is the same
formula that governs a physical system in contact with a heat bath, which is why the language of
statistical mechanics keeps reappearing here.

The question this article is about is deceptively simple:

> **In the gentle regime, when $\beta$ is large, exactly how far does $\pi_\beta$ move away from
> $p$?**

The answer turns out to be a small, sharp story about *which* statistic of the reward controls the
motion. And the punchline is that the statistic everyone expected — the standard deviation — is the
wrong one.

---

## Three ways to measure "how far"

Distance between distributions is not one thing. Three measures matter here.

**Total variation** ($\ell^1$): $\|\pi_\beta - p\|_1 = \sum_y |\pi_\beta(y) - p(y)|$. This is the
worst-case change in the probability of any event, doubled. It is the honest answer to "how likely
am I to notice the difference?"

**Relative entropy** (Kullback–Leibler divergence): $\mathrm{KL}(\pi_\beta \| p) = \sum_y
\pi_\beta(y)\log\frac{\pi_\beta(y)}{p(y)}$. This is the quantity the optimizer was penalizing in the
first place — the information-theoretic cost of the move.

**Audit drift**: pick any bounded statistic $f$ on outputs — a toxicity classifier, a length counter,
a fact-checking score — and ask how much its average moves: $\mathbb{E}_{\pi_\beta}[f] -
\mathbb{E}_p[f]$. This is what a safety team actually measures.

And the reward has statistics of its own. Write $\mu = \mathbb{E}_p[r]$ for the base mean and define

- the **variance** $\operatorname{Var}_p(r) = \mathbb{E}_p[(r-\mu)^2]$, with standard deviation
  $\sigma_p(r) = \sqrt{\operatorname{Var}_p(r)}$;
- the **mean absolute deviation** $\operatorname{MAD}_p(r) = \mathbb{E}_p|r - \mu|$;
- the **range** $R(r) = \max r - \min r$;
- and, for an audit statistic $f$, the **covariance** $\operatorname{Cov}_p(r,f) = \mathbb{E}_p[(r -
  \mu)(f - \mathbb{E}_p f)]$.

The folklore expectation, and the working conjecture that started this investigation, was that all
the drift laws should be governed by $\sigma_p(r)$: *the drift constant is the standard deviation*.
The reasoning was a cumulant heuristic — expand the exponential tilt, the second cumulant is the
variance, done. It is, roughly, right. But "roughly" hides the interesting part.

---

## Result 1: total variation is governed by the mean absolute deviation, not the standard deviation

Here is the first sharp law. Assume $p$ has full support and the temperature is at least as large as
the reward range, $\beta \ge R(r)$. Then

$$\frac{\operatorname{MAD}_p(r)}{\beta} - \frac{3\operatorname{Var}_p(r)}{\beta^2}
\;\le\; \|\pi_\beta - p\|_1 \;\le\;
\frac{\operatorname{MAD}_p(r)}{\beta} + \frac{2\operatorname{Var}_p(r)}{\beta^2},$$

and consequently, as the constraint is relaxed,

$$\beta \,\|\pi_\beta - p\|_1 \;\longrightarrow\; \operatorname{MAD}_p(r).$$

Two things are worth savouring. First, the leading constant is exactly $1$ — no mysterious factor of
$2$ or $\sqrt{2}$, no exponential prefactor of the form $e^{R/\beta}$ that appears in the classical
bounds. Second, the functional is the **mean absolute deviation**, an $L^1$ quantity, not the
standard deviation.

Why $L^1$? The proof makes it transparent. Write the tilt in centred form: with $s(y) = (r(y) -
\mu)/\beta$ and $W_\beta = \mathbb{E}_p[e^{s}]$, we have $\pi_\beta(y) = p(y)e^{s(y)}/W_\beta$, so

$$\|\pi_\beta - p\|_1 \;=\; \frac{\mathbb{E}_p\big|e^{s} - W_\beta\big|}{W_\beta}.$$

Now expand: $e^{s} = 1 + s + O(s^2)$, and because $s$ is centred, $W_\beta = 1 + O(s^2)$ — indeed
$1 \le W_\beta \le 1 + \operatorname{Var}_p(r)/\beta^2$, the lower bound being Jensen and the upper
bound Taylor. Substituting, $|e^s - W_\beta| = |s| + O(s^2)$. Take expectations: the leading term is
$\mathbb{E}_p|s| = \operatorname{MAD}_p(r)/\beta$. The absolute value never got squared. Total
variation is an $L^1$ norm; it sees an $L^1$ moment of the reward.

---

## Result 2: the old conjecture was never wrong, only lossy — and we can say exactly how lossy

Is the standard-deviation law refuted? No, and this is the satisfying part. There is an exact
identity behind the classical inequality $\operatorname{MAD} \le \sigma$:

$$\operatorname{Var}_p(r) - \operatorname{MAD}_p(r)^2 \;=\; \mathbb{E}_p\Big(\big|r - \mu\big| -
\operatorname{MAD}_p(r)\Big)^2 .$$

The gap between the variance and the squared mean absolute deviation *is itself a variance* — the
variance of the absolute deviation. Call it the **deviation defect**. Since a variance is
non-negative, $\operatorname{MAD}_p(r) \le \sigma_p(r)$ always, and equality holds precisely when
$|r - \mu|$ is constant: when the reward takes exactly two values, symmetrically placed about its
mean. Balanced coin-flip rewards, and nothing else.

So the $\sigma/\beta$ law is a valid upper bound that is *attained exactly on the balanced two-valued
family* — which, tellingly, is precisely the family that had been used to show the $\sigma$-law could
not be improved by more than a constant. The earlier evidence for the conjecture was collected on the
one family where the conjecture is exactly true.

Everywhere else it is lossy, and it can be lossy without limit. Take the **rare-spike reward**: a
single rare good output. Let $\Omega = \{\text{hit}, \text{miss}\}$, let $p(\text{hit}) =
\varepsilon$, and let $r$ be the indicator of a hit. Then

$$\operatorname{MAD} = 2\varepsilon(1-\varepsilon), \qquad
\operatorname{Var} = \varepsilon(1-\varepsilon), \qquad
\frac{\operatorname{MAD}}{\sigma} = 2\sqrt{\varepsilon(1-\varepsilon)} \xrightarrow[\varepsilon \to
0]{} 0 .$$

For a reward that fires on one output in a million, the standard-deviation law overstates the actual
total-variation drift by a factor of about $500$. In alignment terms: rare, spiky reward signals —
exactly the shape of a reward model that has memorized a narrow behaviour — move the policy far less,
in total variation, than the variance would suggest. The sharp law knows this; the $\sigma$-law does
not.

---

## Result 3: for relative entropy, the variance *is* right, and the constant is one half

Switch distance measures and the answer changes. For relative entropy,

$$\Big|\mathrm{KL}(\pi_\beta\|p) - \frac{\operatorname{Var}_p(r)}{2\beta^2}\Big| \;\le\;
\frac{2R(r)\operatorname{Var}_p(r)}{\beta^3} + \frac{3\operatorname{Var}_p(r)^2}{\beta^4},
\qquad\text{hence}\qquad
\beta^2\,\mathrm{KL}(\pi_\beta\|p) \longrightarrow \frac{\operatorname{Var}_p(r)}{2}.$$

Here the cumulant heuristic is vindicated exactly: relative entropy is a quadratic form to leading
order, its Hessian is the Fisher information, and along the exponential family generated by $r$ the
Fisher information *is* the variance of $r$. The constant is $1/2$ — half of what the classical
bound gave.

The proof runs through an exact identity worth recording: with $A_\beta = \mathbb{E}_p[e^{s}s]$,

$$\mathrm{KL}(\pi_\beta\|p) \;=\; \frac{A_\beta}{W_\beta} - \log W_\beta .$$

Expanding, $A_\beta = \operatorname{Var}/\beta^2 + O(\beta^{-3})$ and $\log W_\beta =
\operatorname{Var}/(2\beta^2) + O(\beta^{-3})$; the difference is $\operatorname{Var}/(2\beta^2)$.
The two second-order terms partially cancel, and the surviving half is the answer.

---

## Result 4: Pinsker's inequality, and where exactly it leaks

Now the two laws can be compared. Pinsker's inequality — one of the workhorses of information theory
— says $\|q - p\|_1 \le \sqrt{2\,\mathrm{KL}(q\|p)}$. Along the alignment path, both sides are now
known exactly: the left is $\operatorname{MAD}/\beta + O(\beta^{-2})$, the right is $\sqrt{2 \cdot
\operatorname{Var}/(2\beta^2)} = \sigma/\beta + O(\beta^{-2})$. Divide:

$$\frac{\|\pi_\beta - p\|_1}{\sqrt{2\,\mathrm{KL}(\pi_\beta\|p)}} \;\longrightarrow\;
\frac{\operatorname{MAD}_p(r)}{\sigma_p(r)} \;\le\; 1,$$

with limit exactly $1$ if and only if $|r - \mu|$ is constant.

This is the cleanest statement of the whole story. **The standard deviation enters the picture only
through Pinsker's inequality, and the amount Pinsker loses is exactly the deviation defect of the
reward.** The conjecture "the drift constant is the standard deviation" was, all along, the
Pinsker-relaxed shadow of the true law. Along this family of paths, Pinsker is asymptotically tight
precisely for balanced two-valued rewards — a sharp characterization of the equality case of a
classical inequality, restricted to a natural family.

---

## Result 5: reward hacking is exactly the correlated component

The last result is the one with the most direct practical bite. Let $f$ be any audit statistic. Then
for $\beta \ge R(r)$,

$$\Big|\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f] - \frac{\operatorname{Cov}_p(r,f)}{\beta}\Big|
\;\le\; \frac{3\,R(f)\operatorname{Var}_p(r)}{\beta^2},
\qquad\text{hence}\qquad
\beta\big(\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f]\big) \longrightarrow \operatorname{Cov}_p(r,f).$$

Every measurable property of the model drifts, to first order, by exactly its covariance with the
reward, divided by the temperature. Nothing else about $f$ matters at leading order — not its mean,
not its variance, not its shape.

The immediate corollary is a statement about safety auditing that reads almost like a slogan:

> **An audit statistic uncorrelated with the reward cannot be moved to first order.** If
> $\operatorname{Cov}_p(r,f) = 0$, then $\beta(\mathbb{E}_{\pi_\beta}[f] - \mathbb{E}_p[f]) \to 0$;
> the drift is $o(\beta^{-1})$.

Reward hacking, in the gentle-optimization regime, is *not* a mysterious emergent phenomenon. It is
the projection of the audit statistic onto the reward direction, and nothing more. If a toxicity
score moves under alignment, it moved because toxicity is correlated with the reward under the base
policy. If it is genuinely uncorrelated, it is first-order immune, no matter how aggressively you
optimize — up to the second-order terms.

And the standard bound in the literature, $|\mathbb{E}_{\pi_\beta} f - \mathbb{E}_p f| \lesssim
\sigma_p(r)\sigma_p(f)/\beta$, is now visibly just the Cauchy–Schwarz relaxation
$|\operatorname{Cov}_p(r,f)| \le \sigma_p(r)\sigma_p(f)$ of the exact law. Again: the standard
deviations were never the mechanism. They were a bound applied to the mechanism.

---

## The pattern

Step back and a single structural principle organizes all five results. The alignment path
$\beta \mapsto \pi_\beta$ is a one-parameter exponential family, and every drift functional along it
is a **cumulant or moment expansion in $1/\beta$**. Each distance measure sees the first cumulant or
moment that does not vanish:

| what you measure | leading law | which moment |
| --- | --- | --- |
| total variation $\|\pi_\beta - p\|_1$ | $\operatorname{MAD}_p(r)/\beta$ | first absolute moment ($L^1$) |
| relative entropy $\mathrm{KL}(\pi_\beta\|p)$ | $\operatorname{Var}_p(r)/(2\beta^2)$ | second cumulant |
| audit drift of $f$ | $\operatorname{Cov}_p(r,f)/\beta$ | mixed second moment |

The three constants that had been floating around the subject — the range, the standard deviation,
the mean absolute deviation — are not rivals. They are readings of the same object taken at different
exponents: the centred $L^q$ norms $\|r - \mu\|_{L^q(p)}$ at $q = \infty$, $q = 2$, and $q = 1$. Which
one governs your problem is determined by which divergence you chose to measure with.

---

## Why it matters outside the mathematics

Three concrete consequences.

**Budgeting.** If you want to certify that alignment changes the model's behaviour by at most some
tolerance $\delta$ in total variation, the temperature you need is $\beta \approx
\operatorname{MAD}_p(r)/\delta$ — computable from the base policy and the reward alone, with no
tuning and no exponential safety factor. Using $\sigma$ instead costs you a factor of
$\sigma/\operatorname{MAD}$, which the spike example shows can be arbitrarily large. You would be
paying for a drift you never incur.

**Auditing.** Choose safety metrics with small covariance against the reward, and they are provably
first-order stable under alignment. This turns "which metrics should we monitor?" from a matter of
taste into a computation on the base policy: estimate $\operatorname{Cov}_p(r,f)$ for each candidate
$f$ and read off the drift.

**Diagnosis.** The ratio $\operatorname{MAD}_p(r)/\sigma_p(r)$ is a one-number diagnostic for the
*shape* of a reward. Near $1$, the reward is essentially binary and balanced. Near $0$, it is a rare
spike — a reward model that has latched onto a narrow behaviour. The same number tells you how much
information the classical Pinsker-based bounds are throwing away on your particular reward.

There is a broader lesson in it too. The conjecture that the drift constant is the standard deviation
was not false; it was a true statement standing one inequality away from a sharper one. Chasing the
absolute constant — refusing to accept $\Theta(\sigma/\beta)$ and demanding to know what the constant
actually *is* — is what revealed that the constant belongs to a different functional entirely, and
that the discrepancy has a name: the deviation defect. Constants are where the mathematics hides.
