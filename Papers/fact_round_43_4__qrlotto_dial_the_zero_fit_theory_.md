# The Quadratic-Residue Lottery

### A one-line formula with no adjustable numbers — and a proof that nothing can beat it

---

## Prologue: the uncomfortable question

Every model eventually faces the same question: *how much of this is theory, and how much is curve-fitting?* A formula with tunable coefficients that fits your data may be telling you about the world, or it may just be telling you about your own tuning. The gold standard is a formula in which **every constant is forced by first principles** — and which then goes out and fits the data anyway.

This page is about one such formula. It lives inside integer factorisation, it is one line long, and it has exactly zero free parameters:

$$T(N) \;=\; \sum_{\substack{p \le B \\ N \text{ is a square mod } p}} \frac{2}{p}.$$

Walk through the small primes up to some bound $B$. For each, ask whether the number $N$ is a perfect square modulo that prime. If yes, add $2/p$. If no, add nothing. That total is the **dial**.

By the end of this page you will know where the $2$ comes from (it is a theorem, not a choice), why the dial is not an approximation of anything but an exact identity, why no amount of fitting can improve it, and why its value is pinned within an $O(1)$ window around a slowly rising centre no matter how big your factor base gets.

---

## 1. Where the dial comes from: sieving for a factorisation

To factor a large number $N$, the classical sieve algorithms scan positions $x$ near $\sqrt N$ and examine the values $x^2 - N$, hoping many of them factor completely over a fixed **factor base** of small primes $p \le B$. Each such lucky value is a *relation*; enough relations, and linear algebra over $\mathbb{F}_2$ produces a factorisation.

So everything hinges on how hospitable your particular $N$ is to your factor base. Fix a prime $p$. Which positions does it ever touch? Precisely those with

$$x^2 \equiv N \pmod p,$$

because $p \mid x^2 - N$ exactly then. The question *"how much work does $p$ do for me?"* is therefore the question *"how many square roots does $N$ have modulo $p$?"*

<details>
<summary><b>Background: quadratic residues in sixty seconds</b> (click to expand)</summary>

An integer $a$ is a **quadratic residue** modulo $p$ if $x^2 \equiv a \pmod p$ has a solution. The [Legendre symbol](https://en.wikipedia.org/wiki/Legendre_symbol) $\chi_p(a)$ records the answer: it is $+1$ if $a$ is a nonzero residue, $-1$ if it is a non-residue, and $0$ if $p \mid a$.

Two classical facts make it computable and interesting:

* **Euler's criterion.** $\chi_p(a) \equiv a^{(p-1)/2} \pmod p$.
* **Quadratic reciprocity** (Gauss). For distinct odd primes, $\chi_p(q)\,\chi_q(p) = (-1)^{\frac{p-1}{2}\frac{q-1}{2}}$ — which turns the symbol into something computable in $O(\log^2 p)$ bit operations, about as cheap as a gcd.

Exactly half of the $p-1$ invertible classes are residues. That is the "fair coin" we will be exploiting throughout.
</details>

---

## 2. The theorem that fixes the coefficient

Here is the entire source of the $2$.

> **Root-count identity.** For every odd prime $p$ and every integer $N$,
> $$\#\{x \bmod p : x^2 \equiv N\} \;=\; \chi_p(N) + 1.$$

Since the Legendre symbol takes only the values $+1$, $-1$ and $0$, the root count is only ever $2$, $0$ or $1$: two roots when $N$ is a residue, none when it is a non-residue, and exactly one in the ramified case $p \mid N$. **There is no other possibility, ever.** Because roots repeat with period $p$, a fraction $2/p$ of all sieve positions are touched by $p$ when $N$ wins, and $0$ when it loses.

Play with the lottery table of a single prime below. Hover any residue class to see its square roots and the identity in action.

{{interactive_demo:1}}

Notice what the panel of running totals is telling you. The root counts summed over a full period *always* add to exactly $p$ — because each position $x$ is a root of exactly one class, namely $x^2$. That single sentence forces

$$2W + 1 = p, \qquad W = \frac{p-1}{2},$$

so the lottery is exactly fair: among the invertible classes, the win probability is precisely $1/2$, with no error term. And the mean hit density over a full period is exactly $1/p$ — the Mertens weight, again with nothing fitted.

---

## 3. The zero-fit theorem

Now sum over the factor base. Writing $d(p,N)$ for the measured fraction of sieve positions that $p$ touches:

> **Lottery law (sufficiency of the bit).** For an odd prime $p \nmid N$,
> $$d(p,N) = \begin{cases} 2/p & \text{if } N \text{ is a residue mod } p, \\ 0 & \text{otherwise.}\end{cases}$$

> **Zero-fit theorem.** Over a factor base of odd primes not dividing $N$,
> $$T(N) \;=\; \sum_{p} d(p,N),$$
> i.e. the closed-form dial *is* the expected footprint, exactly.

The first statement is deceptively small and enormously consequential. The *measured* hit fraction is a deterministic, two-valued function of the *single indicator bit* — no scatter, no residual, no third value. In statistical language the bit is a **sufficient statistic**: once you know it, measuring the fraction tells you nothing new. That is why no per-prime coefficient can add information; there is no information left to add.

<details>
<summary><b>Proof of the root-count identity</b> (click to reveal)</summary>

Reduction mod $p$ is a bijection from $\{0,1,\dots,p-1\}$ onto $\mathbb{Z}/p\mathbb{Z}$, so the count equals the number of $x \in \mathbb{Z}/p\mathbb{Z}$ with $x^2 = \bar N$. In a finite field of odd characteristic, squaring is two-to-one on the nonzero elements: $x^2 = y^2$ forces $x = \pm y$, and $x \ne -x$ unless $x = 0$. So the fibre of the squaring map over a nonzero $a$ has size $2$ if $a$ is a square and $0$ if not — that is, $1 + \eta(a)$ where $\eta$ is the quadratic character. The fibre over $0$ is the singleton $\{0\}$, consistent with $1 + \eta(0) = 1 + 0$. Identifying $\eta$ with the Legendre symbol finishes it. $\blacksquare$

The zero-fit theorem is then simply this identity, divided by $p$ and summed over the factor base.
</details>

There is also a tidy way to split the dial in two:

$$T(N) \;=\; \underbrace{\sum_{p \le B} \frac1p}_{\text{Mertens main term, no } N} \;+\; \underbrace{\sum_{p \le B}\frac{\chi_p(N)}{p}}_{\text{character fluctuation}} .$$

The first piece is the [Mertens](https://en.wikipedia.org/wiki/Mertens%27_theorems) sum $\log\log B + M + o(1)$, universal across targets. The second carries all the $N$-dependence. It is the same main-term-plus-fluctuation architecture that organises the prime number theorem, compressed into something you can evaluate on a phone.

---

## 4. Take the dial for a drive

Time to experiment. The bench below computes the dial for any target you type, over any factor base you choose. Watch the per-prime lottery table, the dial accumulating against the Mertens curve, and where your target falls in the exact distribution. Then try the last two panels: attempt to *beat* the theory weights, and see what truncating the factor base costs.

{{interactive_demo:0}}

Things worth trying:

* **Type any number and slide $B$.** The dial rises roughly like $\log\log B$ but the fluctuation around the Mertens curve stays small — that is Section 6 in visual form.
* **Press "steer to the maximum".** The Chinese remainder theorem builds a target that wins every lottery in the first dozen primes. Press "steer to zero" for one that loses every one. Every pattern is achievable.
* **Move the risk sliders off $c = a = 1$.** The risk climbs immediately in either direction. There is no free direction in weight space.
* **Drag the truncation slider down.** Even dropping the single largest prime costs a strictly positive amount, and the *deficit* depends on your target — which is why truncation corrupts a ranking rather than merely shifting it.

---

## 5. No fit can beat the theory weights

Suppose you are sceptical: keep the win/lose bits, but let the payouts be free parameters, $\widehat T_w(N) = \sum_i w_i b_i(N)$. Surely $k$ tuned numbers beat a rigid formula?

They cannot, and one can say exactly how much worse each alternative is. Averaged over the residue sample space,

> **Exact risk formula.** With $\delta_i = 2/q_i - w_i$,
> $$\mathrm{Risk}(w) = |\Omega|\left[\Big(\sum_i \frac{\delta_i}{2}\Big)^{2} + \sum_i \frac{\delta_i^{2}}{4}\right].$$
> It is non-negative, it vanishes at $w_i = 2/q_i$, and it vanishes **only** there.

A mean-squared term plus a variance term, both in the deviations from theory. Deviations that cancel in the mean are still penalised by the second. The theory point is the unique global minimum of an explicitly known landscape — so a fit can, at best, rediscover it.

{{visualization:1}}

The same formula prices truncation. Dropping the primes in a tail set $\mathcal{T}$ costs exactly

$$|\Omega|\left[\Big(\sum_{i \in \mathcal{T}} \frac{1}{q_i}\Big)^{2} + \sum_{i \in \mathcal{T}}\frac{1}{q_i^{2}}\right] \;>\; 0 ,$$

strictly positive the moment one prime is dropped. Full support strictly dominates every truncation, always, by a computable amount.

You can watch this play out in a controlled experiment: fit per-prime weights by least squares on synthetic data and compare against theory on held-out targets.

{{demo:1}}

With noiseless data the fit recovers $2/p$ to machine precision. With noise it lands at strictly positive risk. With truncated support it pays exactly the predicted price. Fitting never wins; the best it can do is converge to the formula that was there all along.

---

## 6. A diverging mean and a frozen spread

As $N$ ranges over residue classes, the bits are exactly independent fair coins — not "heuristically independent", exactly so: every one of the $2^k$ win/lose patterns is realised by exactly the same number of residue vectors, $\prod_i (q_i-1)/2^k$. The first two moments follow immediately:

$$\mathbb{E}[T] = \sum_i \frac{1}{q_i}, \qquad \operatorname{Var}[T] = \sum_i \frac{1}{q_i^{2}}.$$

Now look at what those two expressions do as the factor base grows. The mean *diverges* like $\log\log B$. The variance is bounded by an absolute constant:

$$\sum_i \frac{1}{q_i^2} \;\le\; \sum_{m \ge 3}\frac{1}{m^2} \;<\; \frac12,$$

for **any** family of distinct odd integers. The centre drifts upward forever; the spread never grows.

{{visualization:0}}

<details>
<summary><b>From two moments to an exponential tail</b> (click to reveal the Chernoff–Hoeffding argument)</summary>

Chebyshev already gives a bound with no dependence on the factor base: at most a fraction $V/t^2 \le 1/(2t^2)$ of targets read more than $t$ from the mean.

To do better, compute the moment generating function. A single centred coin takes the two values $\pm w/2$ on two equinumerous sets, so its exponential sum is exactly a hyperbolic cosine, $\cosh(sw/2)$ — the odd term cancels precisely because the lottery is fair. Independence makes the whole dial's generating function factor:

$$\mathbb{E}\big[e^{s(T - \mathbb{E} T)}\big] = \prod_i \cosh\!\Big(\frac{s}{q_i}\Big) \;\le\; \prod_i e^{s^2/(2q_i^2)} = e^{s^2 V/2},$$

using $\cosh u \le e^{u^2/2}$. Exponential Markov at the optimal $s = t/V$ then yields the two-sided tail

$$\Pr\big[|T - \mathbb{E}T| \ge t\big] \;\le\; 2e^{-t^2/(2V)} \;\le\; 2e^{-t^2}.$$

Already at $t = 2$ this beats Chebyshev: $2e^{-4} \approx 0.037$ against $0.125$. And since $2e^{-t^2} < 1$ for $t \ge 1$, some target always reads within $1$ of the Mertens weight — no factor base can push everything away from the centre.
</details>

---

## 7. Two clocks, one answer

So far we randomised over the *target*. A sieve randomises over *positions*: it marches along $x$ and counts how many factor-base primes divide $x^2 - N$. Call that counter $H(x)$. Averaged over a full period,

$$\mathbb{E}_x[H] = \sum_i \frac{\#\text{roots}(q_i,N)}{q_i} = T(N),$$

the very same dial, with variance $\sum_i \pi_i(1-\pi_i)$ over the theory-forced Bernoulli parameters $\pi_i \in \{0, 2/q_i\}$. Read across targets the dial is a sum of independent fair coins; read across positions it is the mean of a sum of independent Bernoulli indicators. Both readings put the same $2$ in the same place.

---

## 8. Under the hood: the algorithms

Three short algorithms carry all the practical content.

{{algorithm:0}}

{{algorithm:1}}

{{algorithm:2}}

And the full verification suite, checking every claim on this page numerically — the root-count identity across thousands of instances, the fairness identity, exact independence, the two moments, the risk formula against brute-force averaging, the truncation cost, the tail bounds, and the position-side duality:

{{demo:0}}

---

## 9. What it all means

**Practically.** Before committing compute to a factoring target, compute a few hundred Legendre symbols and read off the dial. In the experiments that motivated this analysis, the zero-fit dial tracked measured sieve yield at Spearman correlation $\approx 0.73$–$0.76$ across independent implementations, and explained out-of-sample variance at $R^2 \approx 0.53$–$0.54$ with a single global scale — outperforming a competing model carrying eight fitted coefficients, which reached only $0.46$.

**Methodologically.** We now know why the fitted model *had* to lose. It is not a quirk of one data set: the zero-parameter formula sits at the exact global minimum of the risk landscape, and every fitted alternative is measured, in closed form, by its distance from that minimum. When you can prove a model is the unique risk minimiser over the entire space of alternatives, benchmarking becomes redundant.

**Structurally.** This is a complete, small example of a phenomenon that recurs across analytic number theory: an arithmetic quantity that *is* a random variable, exactly, with computable moments and provable concentration — and whose only fitted constant turns out to have been a theorem all along.

<details>
<summary><b>Where to go next</b></summary>

* **From footprint to yield.** The dial is the expected number of factor-base divisions; what a factoring run cares about is smoothness yield. Combining the position-side Bernoulli structure with a [Dickman-type](https://en.wikipedia.org/wiki/Dickman_function) smoothness analysis is the natural next step.
* **All the cumulants.** The generating function factorises, so every cumulant is available in closed form from $\log\cosh(s/q_i)$; a Poisson-type limit for the hit counter looks within reach.
* **Realistic target ensembles.** The independence statement is unconditional and uniform. What happens when the target ensemble is conditioned, say to semiprimes of a fixed bit length? That is an equidistribution question with a large-sieve flavour.
* **Other sieves.** For multiple-polynomial variants the same identity holds with the Legendre symbol of the discriminant; for the number field sieve the analogue counts degree-one primes above $p$. In each case the arithmetic, not the modeller, should decide the payout.
* **Steering as design.** Every bit pattern is realisable, so best-case and worst-case benchmark instances — and the classical question of choosing a small multiplier $m$ so that $mN$ has a favourable dial — become concrete finite optimisations.
</details>
