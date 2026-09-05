# How Many Words Does a Machine Really Read?

## A measurement protocol for the attention budget

Every modern language model faces the same quiet dilemma at every single step of
its computation. It has, in front of it, a context: a thousand tokens, a hundred
thousand, sometimes a million. And it must decide, for each new word it writes,
how much of that context actually matters.

The mechanism it uses is called *attention*, and it works by assigning a weight
to every position in the context and then taking a weighted average. Sort those
weights from largest to smallest and you get a curve — steep at first, then
flattening into a long tail. The interesting question is: **where can you cut the
curve?** If you keep only the top $k$ positions and throw away the rest, how large
must $k$ be before you have captured, say, $98\%$ of the total weight?

Call that number the **attention budget**. It is the number a systems engineer
actually needs. It determines how much of the key–value cache can be evicted, how
sparse the attention kernel can be, how long a context the hardware can afford.
And until now, the number has been reported the way most engineering numbers get
reported: measured on a benchmark, eyeballed off a plot, and hoped for.

This article is about turning that number into something you can *certify* — with
a proof on the low side, a proof on the high side, and an error bar in between.

---

## The knee

Let us set the stage precisely, because the precision is where the mathematics
lives.

Fix a context of length $n$ and let $w_0 \ge w_1 \ge \dots \ge w_{n-1} > 0$ be the
attention weights, already sorted from heaviest to lightest. Their total is the
**head mass**
$$S(n) \;=\; \sum_{i<n} w_i,$$
and dividing by it gives an honest probability distribution $p_i = w_i / S(n)$ over
positions. The **retained mass** of a top-$k$ truncation is
$$M(k) \;=\; \sum_{i < \min(k,n)} p_i,$$
the fraction of attention you keep if you keep only the $k$ heaviest positions.
$M$ climbs from $M(0)=0$ to $M(n)=1$.

Now pick a **gate** $g \in (0,1]$ — the fraction of attention mass you insist on
preserving; $g=0.98$ is a realistic deployment choice. The **knee** is
$$k^*(n,g) \;=\; \min\{\,k : M(k) \ge g\,\},$$
the smallest budget that clears the gate. Everything in this article is about
bracketing $k^*$ from below and from above, using only quantities you can measure.

---

## Why entropy is the wrong instrument

The first instinct of anyone with an information-theoretic reflex is to reach for
entropy. Entropy measures how spread out a distribution is; a budget measures how
many items you need to cover most of the mass. Surely these are the same thing?

They are not, and the failure is not subtle. Consider a deliberately simple
profile on $n = 17$ positions: one dominant key of weight $16$, and sixteen
identical keys of weight $1$ each. The total is $32$, so the dominant key carries
exactly half the mass and each of the others carries $1/32$.

For this **spike profile** at gate $g = 1/2$, the knee is exactly $1$. One key
suffices; the head alone clears the gate.

Now compute the entropies.

* The **Hartley entropy** — just $\log n$, the log of the support size — gives an
  "effective support" of $17$ positions. Scaling by $g^2$ as the correct bound
  (below) does gives a claimed floor of $17/4 = 4.25$. But $k^* = 1$. The claim is
  false by a factor of four.
* The **Shannon entropy** does better but still fails. Here
  $H_1 = -\sum p_i \log p_i = \tfrac12\log 2 + 16\cdot\tfrac1{32}\log 32 = 3\log 2$
  exactly, so $e^{H_1} = 8$: an effective support of eight positions. The
  corresponding claimed floor is $g^2 e^{H_1} = \tfrac14 \cdot 8 = 2$. Again the
  true knee is $1$. **Shannon entropy over-certifies.**

The diagnosis is clean. Entropy asks how spread the *whole* distribution is. The
budget only cares about how much mass sits on the *head*. The spike profile is
genuinely spread — eight effective positions' worth — and yet half its mass sits
on a single key, so a budget of one is enough. Entropy alone cannot certify a
budget.

## The right instrument: collision energy

There is, however, a statistic that does work, and it is the humblest one in the
toolbox: the $\ell^2$-**energy**, also known as the collision probability,
$$E \;=\; \sum_{i<n} p_i^2 .$$
This is the probability that two independent draws from the attention
distribution land on the same position. It is the exponential of the *Rényi-2*
entropy, $E = e^{-H_2}$.

One line of Cauchy–Schwarz does the whole job. For any $k$,
$$M(k)^2 \;=\; \Big(\sum_{i<\min(k,n)} p_i\Big)^{2} \;\le\; k \sum_{i<\min(k,n)} p_i^2 \;\le\; k\,E .$$
Apply this at $k = k^*$, where $M(k^*) \ge g$ by definition, and out drops the
**energy floor**:
$$\boxed{\;\frac{g^2}{E} \;\le\; k^*(n,g) \;\le\; n\;}$$
a two-sided sandwich in which both ends are computable from a single forward pass:
the left from the energy of the attention vector, the right from the context
length. Equivalently, $k^* \ge g^2 e^{H_2}$ — the floor *is* an entropy
exponential, but it must be the collision entropy.

Why does Rényi-2 succeed where Shannon fails? Because $H_2 \le H_1$ always
(Jensen's inequality for the logarithm), so replacing $H_2$ by $H_1$ can only
inflate the claimed floor — and, as the spike shows, the inflation is real. On
the spike, $H_2 = \log(64/17) \approx 1.325$ against $H_1 = \log 8 \approx 2.079$,
and the collision floor $g^2/E = 16/17 \approx 0.94$ sits obediently below the
true knee of $1$. The $\ell^2$-energy is the coarsest exponential statistic that
still *sees the head*.

**Is the sandwich actually informative, or merely valid?** A degenerate bound
$0 \le k^* \le n$ would also be true and useless. The answer comes from the
participation-ratio inequality $nE \ge 1$ (again Cauchy–Schwarz, applied to the
full sum): the ratio of the two ends of the sandwich satisfies
$$\frac{g^2/E}{n} \;\le\; g^2 .$$
So the two ends can never be further apart than a factor $1/g^2$ — at the
deployment gate $g = 0.98$ that is a factor of $1.04$. The sandwich is tight
exactly in the regime that matters. And it is genuinely sharp: on a flat profile
($p_i = 1/n$) the energy is exactly $1/n$, so the floor reads $g^2 n$ against a
true knee of about $gn$; the entire loss is the single factor $g$, and the bound
becomes an equality at $g = 1$.

---

## How big is the floor, really?

A floor that always reads $0.001$ would be technically valid and practically
worthless. So the second act is to *evaluate* $g^2/E$ for the profiles that
actually occur.

Here sortedness earns its keep. If $w_0$ is the largest weight, then
$$E \;=\; \sum_i \frac{w_i^2}{S(n)^2} \;\le\; \frac{w_0}{S(n)^2}\sum_i w_i \;=\; \frac{w_0}{S(n)} .$$
A profile can only keep its energy high — and hence its floor low — by keeping the
normalizer small, that is, by *concentrating*. Feed this back into the sandwich
and the qualitative statement becomes a **rate**:
$$k^*(n,g) \;\ge\; \frac{g^2\,S(n)}{w_0} .$$
The budget grows at least as fast as the partial sums of the attention profile
divided by its head weight. If the profile is not summable, the budget diverges —
and now we know how fast.

The showcase is the critical Zipf profile $w_i = 1/(i+1)$, precisely the boundary
case between "summable, so a fixed budget suffices" and "non-summable, so no
fixed budget can survive". Here $w_0 = 1$ and $S(n)$ is the harmonic number
$H_n \ge \log(n+1)$, giving the explicit law
$$k^*(n,g) \;\ge\; g^2 \log(n+1).$$
At the critical exponent the attention budget grows logarithmically in the
context length, with the squared gate as its constant. Double your context and you
must pay a fixed additive toll of $g^2 \log 2$ extra keys — forever.

**Even geometric decay is not free.** Suppose the profile is a perfect geometric
sequence $w_i = r^i$ with $0 < r < 1$: the friendliest possible case, the one
everyone hopes for. Both the head mass and the sum of squares are geometric
series, and the energy comes out in closed form:
$$E \;=\; \frac{(1-r)(1+r^{\,n})}{(1+r)(1-r^{\,n})} \;\xrightarrow[n\to\infty]{}\; \frac{1-r}{1+r}.$$
So the energy does *not* go to zero — but it is proportional to $1-r$, and once
the context is long enough for the tail to have decayed ($r^{\,n} \le 1/2$), the
floor reads
$$k^*(n,g) \;\ge\; \frac{g^2}{3(1-r)} .$$
Against this stands the classical upper estimate: a geometric profile satisfies
the tail law $1 - M(k) \le r^k/(1-r)$, which certifies a budget of about
$\log\!\big(1/((1-g)(1-r))\big)/\log(1/r)$, itself of order $\frac{1}{1-r}\log\frac{1}{(1-g)(1-r)}$
for $r$ near $1$. Upper and lower bounds therefore agree to within a logarithm:
the geometric knee is $\Theta(1/(1-r))$, **pinned from both sides**. The
tail-exponent fit is not merely a sufficient certificate; it captures the true
order of the budget.

---

## The protocol

The upper certificate is where measurement enters. Take the measured discard
curve $1 - M(k)$ and fit a tail law
$$1 - M(k) \;\le\; C\,r^{\,k} .$$
Two probes suffice: measure the discarded mass $t_1$ at budget $k_1$ and $t_2$ at
budget $k_1 + d$, and estimate
$$\hat r = (t_2/t_1)^{1/d}, \qquad \hat C = t_1/\hat r^{\,k_1}.$$
Given a fit, the **reported budget** at gate $\tau$ is
$$\mathrm{Budget}(C,r,\tau) \;=\; \max\!\Big(\Big\lceil \frac{\log((1-\tau)/C)}{\log r}\Big\rceil,\,1\Big),$$
the exponent at which the fitted tail drops below the residual $1-\tau$. It is a
genuine upper certificate: $k^*(n,\tau) \le \mathrm{Budget}(C,r,\tau)$.

Three properties make it deployable.

**It is monotone in the confidence box.** Enlarging either fitted parameter can
only enlarge the reported budget, so quoting the upper corner $(C^+, r^+)$ of a
confidence region certifies the budget for *every* parameter pair inside it. An
error bar on the fit becomes an error bar on the report, with no extra work.

**Its errors are damped, and the damping is under your control.** If both tail
measurements carry a multiplicative error of at most $\varepsilon$, the estimated
ratio is off by at most the factor $\big(\frac{1+\varepsilon}{1-\varepsilon}\big)^{1/d}$
— the $d$-th root of the data error. Since $d$ is the *probe separation*, a
quantity you choose, any target precision $\delta$ is reachable by probing further
apart, whatever the noise level. Uncertainty in the report is set by experiment
design, not by the noise floor. Symmetrically, on the lower end, an over-estimate
of the energy by a relative factor $\eta$ costs exactly a factor $1/(1+\eta)$ in
the floor — and only an over-estimate is ever needed, so a conservative energy
measurement always yields a valid report.

**It introduces no bias of its own.** Run the two-point estimators on data drawn
from a genuinely geometric tail and they return the true $C$ and $r$ exactly; the
reported budget is then exactly the budget of the true parameters. Every bit of
uncertainty in the final number is traceable to the data.

And the report is *sharp*. If the measured tail is exactly $1-M(k) = C r^k$ and
the reported budget fits inside the context, then
$$k^*(n,\tau) \;\le\; \mathrm{Budget}(C,r,\tau) \;\le\; k^*(n,\tau) + 1,$$
with equality on the left in fact holding: the reported number *is* the knee. The
single-key slack is nothing but the ceiling rounding, and it cannot be removed.
Where a crude bracketing argument might tell you only that the knee lies somewhere
in $12 < k^* \le 16$, a fit collapses the bracket to a point.

---

## Merging heads

Real transformers have many attention heads, and engineers routinely want one
budget for a merged or shared cache. What happens to the certificate?

The energy behaves convexly under merging: if two heads with positive weight
vectors are added, the merged profile's energy never exceeds the larger of the two
individual energies,
$$E(w_1 + w_2) \;\le\; \max\big(E(w_1),\,E(w_2)\big).$$
The proof is a one-line convexity argument: the merged normalized weight at each
position is a convex combination, with weight $\lambda = S_1/(S_1+S_2)$, of the two
individual normalized weights, and squaring is convex.

Turning the inequality over, the *floor* of a merged head never drops below the
smaller of the two per-head floors:
$$\min\Big(\frac{g^2}{E(w_1)},\frac{g^2}{E(w_2)}\Big) \;\le\; \frac{g^2}{E(w_1+w_2)} .$$
This mirrors, on the lower end of the sandwich, the corresponding maximum law for
the knee itself. The moral for a systems designer is blunt: **the worst head
governs both ends of the sandwich.** You cannot economize by averaging away a
diffuse head; merging it into a sharp one drags the certified budget toward the
diffuse one's value.

---

## What has been bought

The pipeline that emerges is short enough to state in a paragraph. From one
forward pass, compute the energy $E$ of the sorted attention vector and report the
floor $g^2/E$; from two probes on the discard curve, fit $(\hat C, \hat r)$ and
report the ceiling $\mathrm{Budget}(\hat C, \hat r, \tau)$; quote the confidence
box, propagate it monotonically through the budget formula, and note that the two
ends can never be more than a factor $1/g^2$ apart. If a reported fit ever
produces a budget *below* the measured energy floor, the fit is refuted — a free
falsification test that costs nothing to run.

Underneath sits a small piece of mathematics with a clear moral. Entropy, the
statistic everyone reaches for first, is the wrong instrument: it measures spread,
and a budget is about the head. The collision energy is the right one, and once you
have it, the qualitative folklore — geometric decay is cheap, critical decay is
expensive, one bad head ruins the pool — sharpens into rates: $g^2 S(n)/w_0$ in
general, $g^2\log(n+1)$ at the Zipf boundary, $\Theta(1/(1-r))$ for geometric
decay, and a minimum law under merging.

That is the difference between an engineering habit and a measurement protocol.
The habit gives you a number. The protocol gives you a number with two proofs
attached.
