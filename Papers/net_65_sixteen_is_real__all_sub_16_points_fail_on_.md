# How Many Keys Does a Machine Actually Need?

*A guided tour of the attention-budget knee — from a single measured table to a
convergence test that decides whether your cache can ever be a fixed size.*

---

## 1. The question, in one picture

When a model reads a context of $n$ tokens, each attention head produces a probability
distribution over those $n$ positions. Sort those weights largest-first:

$$w_0 \ \ge\ w_1 \ \ge\ w_2 \ \ge\ \cdots \ >\ 0 .$$

Keep the top $k$ of them and throw the rest away — the bet behind
[top-$k$ attention](https://en.wikipedia.org/wiki/Attention_(machine_learning)) and every
key–value cache eviction scheme. The fraction of mass you keep is

$$R(n,k) \;=\; \frac{w_0 + \cdots + w_{k-1}}{w_0 + \cdots + w_{n-1}} .$$

Fix a bar — a **gate** $\tau$, say $0.98$ — and the smallest budget clearing it is the
**knee**:

$$k^*(n) \;=\; \min\{\,k \ :\ R(n,k) \ge \tau\,\}.$$

Everything in this page is about one question: **does $k^*(n)$ stay put as $n$ grows?**

Start by playing. Drag the exponent slider below the value $1$ and watch the right-hand
chain lift off the floor; drag it back above $1$ and watch the chain flatten into a
horizontal line. That transition is the whole story, and by the end of the page you will
know exactly why it happens where it does.

{{interactive_demo:0}}

---

## 2. The measurement that started it

At gate $0.98$, a fine sweep of a language model at context length $1024$ produced this
table:

| budget $k$ | 4 | 6 | 8 | 12 | 16 |
|---|---|---|---|---|---|
| retained mass | $0.9318$ | $0.9532$ | $0.9660$ | $0.9759$ | passes |

Every budget below $16$ fails. The last one misses by $0.0041$ — about two standard
errors. Meanwhile, walking up a ladder of context lengths gave a **rising** chain
$\{16, 20, 24\}$ for a half-billion-parameter model and a **flat** chain $\{16, 16\}$ for
a model three times larger.

The tempting conclusion — "bigger models need fewer keys" — is wrong; the fine sweep
shows the knee did not drop below $16$. What changed with scale was not the size of the
budget but its *stability*. Holding that distinction precisely is what the mathematics
buys us.

---

## 3. The razor: two measurements are a proof

Here is the first theorem, and its proof fits in a sentence.

> **Razor bracket.** If budget $a$ fails ($R(n,a) < \tau$) and budget $b$ passes
> ($R(n,b) \ge \tau$), then $a < k^*(n) \le b$.

<details>
<summary><b>Click to reveal the proof (one line, no statistics required)</b></summary>

Retained mass is non-decreasing in $k$: enlarging the budget only adds positive weights
to the numerator while the denominator is fixed. So if the knee were $\le a$, then
$\tau \le R(n,k^*) \le R(n,a) < \tau$ — a contradiction. And $b$ is in the passing set, so
the least passing budget is at most $b$.

No corpus model, no sampling assumption, no architecture enters. The bracket is a
*deduction*.
</details>

Applied to the table: a fail at $12$ and a pass at $16$ give

$$12 \;<\; k^*(1024) \;\le\; 16 .$$

That is the honest content of "the knee is sixteen". Try it yourself — the lab below
hides a profile, lets you probe budgets, and shows the bracket tightening with each
measurement. Notice how hard it is to pin the knee *exactly*: you need a failure
immediately below a pass.

{{interactive_demo:1}}

<details>
<summary><b>Bonus: why the failing table could never have been a plateau</b></summary>

For **every** positive profile and every context length $n > 12$,

$$R(n,4) < R(n,6) < R(n,8) < R(n,12),$$

strictly, because $\min(a,n) < \min(b,n)$ whenever $a<b<n$ and head mass is strictly
increasing. So the measured chain $0.9318 < 0.9532 < 0.9660 < 0.9759$ is forced: each
failing grid point is independent evidence, and the failures come out ordered no matter
what the model or the corpus is.
</details>

---

## 4. Two worlds: a gap, or a floor

Why should the knee ever stay bounded? Two extreme profiles show the mechanism.

**A spectral gap.** Suppose each weight is at most $r$ times the previous one,
$w_{i+1} \le r\,w_i$ with $r<1$. Then for every budget $k \ge 1$ and **every** context
length,

$$R(n,k) \;\ge\; 1 - \frac{r^k}{1-r}.$$

<details>
<summary><b>Click to see why the context length disappears</b></summary>

The discarded tail is $\sum_{k \le i < n} w_i \le \sum_{i \ge k} w_0 r^i = w_0 r^k/(1-r)$.
The retained head is at least $H(1) = w_0$, hence at least as large as $w_0$ no matter how
long the context is. Dividing, the factor $w_0$ cancels:

$$1 - R(n,k) \;=\; \frac{\text{tail}}{H(n)} \;\le\; \frac{w_0 r^k/(1-r)}{w_0} \;=\; \frac{r^k}{1-r}.$$

The cancellation of the largest weight is the entire trick, and it is why the guarantee is
free of $n$.
</details>

Solving for the budget that reaches $\tau$ gives a formula that depends on nothing but
the decay ratio and the gate:

$$K(r,\tau) \;=\; \max\left\{\left\lceil \frac{\log\big((1-\tau)(1-r)\big)}{\log r}\right\rceil,\,1\right\}.$$

**A floor.** Now suppose the weights never really decay: $c \le w_i \le M$ with $c > 0$.
Then the mass you keep is at most $kM$ while the total is at least $nc$, so clearing the
gate forces

$$k^*(n) \;\ge\; \frac{\tau\,n\,c}{M},$$

linear in the context. For perfectly flat attention this is sharp: the knee is squeezed
between $\tau n$ and $\lceil \tau n\rceil$, and the context sensitivity
$k^*(2n) - k^*(n)$ grows without bound. That is the scaling wall.

Both regimes are real, so a flat chain and a rising chain are fingerprints of two
genuinely different internal geometries — not noise around one truth.

{{algorithm:1}}

---

## 5. A warning: the flat chain is not literally flat

It is tempting to read $\{16,16\}$ as a conservation law $k^*(2n) = k^*(n)$. It is false,
and it fails in the friendliest possible case.

> For the ideal geometric profile $w_i = 2^{-i}$ at gate $3/4$: $k^*(1) = 1$ but
> $k^*(2) = 2$.

<details>
<summary><b>Click for the two-line computation, and the mechanism behind it</b></summary>

At $n=1$ the single key holds everything, so $k^*(1)=1$. At $n=2$ the total mass is
$1 + \tfrac12 = \tfrac32$, so one key retains $\tfrac{1}{3/2} = \tfrac23 \approx 0.667$,
below $0.75$; both keys are needed, so $k^*(2)=2$.

The mechanism is **context dilution**: for a fixed budget, the numerator of $R(n,k)$ does
not change as $n$ grows but the denominator does, so $R(n,k)$ is *antitone* in $n$. Near a
gate crossing this pushes the knee up by a step — even with the fastest imaginable decay.
</details>

**Moral.** A two-point measurement can support *uniform boundedness* of the budget. It can
never support an equality. The right invariant is: *does one finite budget serve every
context length?*

---

## 6. The exact answer: it is a convergence test

Geometric decay is sufficient but far too strong a hypothesis for real spectra. The true
boundary is a first-year analysis condition.

> **Stability equals summability.** For any positive sorted profile and any gate
> $0 < \tau < 1$: a single context-independent key budget exists **if and only if**
> $\sum_i w_i < \infty$.

<details>
<summary><b>Click to reveal the proof of both directions</b></summary>

($\Rightarrow$) Suppose budget $K$ works at every $n$. Then
$\tau \le R(n,K) \le H(K)/H(n)$, so $H(n) \le H(K)/\tau$ for all $n$: the partial sums are
bounded. A positive series with bounded partial sums converges.

($\Leftarrow$) Suppose $S = \sum_i w_i < \infty$. Since $\tau S < S$ and $H(m) \to S$,
choose $k$ with $H(k) > \tau S$. For any $n > k$,
$\tau H(n) \le \tau S < H(k)$, so $R(n,k) > \tau$; and for $n \le k$, $R(n,k) = 1$. That
one $k$ serves every context length.
</details>

Two consequences are worth their own line.

* **The gate does not matter.** Raising the bar from $0.98$ to $0.999$ changes the *value*
  of the budget but not *whether a finite budget exists* — summability never mentions
  $\tau$. Stability is a property of the model, not of your measurement standard.
* **There is a critical exponent.** Attention spectra are usually described by
  [Zipf's law](https://en.wikipedia.org/wiki/Zipf%27s_law), $w_i \propto (i+1)^{-s}$, and
  $\sum_i (i+1)^{-s}$ converges exactly when $s > 1$. So a Zipf profile has a
  context-stable key budget **iff $s > 1$** — a sharp
  [phase transition](https://en.wikipedia.org/wiki/Phase_transition) at $s=1$.

Here is that transition drawn over the whole plane of exponents and context lengths. Look
at the right-hand panel: the context sensitivity collapses to zero the moment you cross
the critical line.

{{visualization:1}}

---

## 7. The knee as a spectrometer

If the knee is decided by the tail exponent, then measuring the knee measures the
exponent. Fit the reported grid at context $1024$ to a power law and each point returns an
exponent:

| $k$ | 4 | 6 | 8 | 12 |
|---|---|---|---|---|
| fitted $s$ | $2.353$ | $2.301$ | $2.290$ | $2.237$ |

Consistent to about $5\%$ — a single-parameter power-law tail describes the measurement
well — and comfortably supercritical. Feeding that band back through the theory predicts a
knee of $11$–$15$ keys that **does not move** from context $1024$ up to $65\,536$. That is
a falsifiable prediction of continued flatness, extracted from a spectrum fitted at one
context length.

{{algorithm:2}}

And here is the whole picture in three panels: the gate crossings, the razor, and the two
kinds of chain.

{{visualization:0}}

---

## 8. Many heads, one worst case

Real transformers have dozens of heads, and a deployed cache serves all of them. Merging
heads adds their masses, so the merged retained fraction is
$\frac{A_1+A_2}{B_1+B_2}$ — the [mediant](https://en.wikipedia.org/wiki/Mediant_(mathematics))
of the two per-head fractions, which always lies between them.

> **Max law.** The knee of a mixture lies between $\min(k_1^*, k_2^*)$ and
> $\max(k_1^*, k_2^*)$. Consequently, mixing context-stable heads is context stable — but
> a single gapless head destroys stability for the whole model.

<details>
<summary><b>Click for the mediant argument</b></summary>

If $m = \min(A_1/B_1, A_2/B_2)$ then $mB_j \le A_j$ for each $j$; adding gives
$m(B_1+B_2) \le A_1+A_2$, i.e. the mixture retains at least $m$. The upper bound is
symmetric. For the knees: at $K = \max(k_1^*,k_2^*)$ both heads pass, so by the lower
mediant bound the mixture passes; and if the mixture passes at $k$, the upper mediant bound
says some head passes at $k$.
</details>

Try it in the explorer above: switch the family to *Mixture* and set a large exponent. The
Zipf head alone would be perfectly stable, yet the chain climbs anyway. Stability is as
good as your **worst** head.

---

## 9. Compute it yourself

The exact knee is a monotone bisection — the razor bracket, run as an algorithm.

{{algorithm:0}}

And here is the complete numerical tour: the bracket, the strict sub-knee ordering, the
context-free mass guarantee, the linear lower bound, the refutation of exact flatness, the
Zipf transition, the mediant law, and the spectral fit — all reproduced from scratch.

{{demo:0}}

---

## 10. What to take away

1. **A knee measurement is a bracket, never a point.** Monotonicity turns a fail and a
   pass into a proof; the leftover ambiguity is the grid's.
2. **A flat chain means bounded, not constant.** Even ideal geometric decay moves the knee
   by a step when the context grows, because a longer context dilutes any fixed budget.
3. **Boundedness is convergence.** One key budget serves every context length exactly when
   the sorted attention weights form a convergent series — for Zipf tails, exactly when
   $s>1$.
4. **So stop measuring the budget and start measuring the exponent.** Above the critical
   value you can size a cache once and forget it; at or below it, no fixed cache will ever
   do, and that is a theorem rather than a tuning problem.

Sixteen is real. But the number was never the point — the point is that the model's
attention, sorted and laid out, is a series that converges.
