# Batch to a Root

### A guided tour of the optimal batch size under sub-quadratic multiplication

---

## 1. The question

You have a stream of things to process — integer candidates to test for smoothness,
signatures to verify, rows to insert, gradients to accumulate. Processing them one at
a time wastes a fixed setup cost over and over. So you **batch**: pay the setup once,
share it across $k$ items.

The obvious conclusion is that bigger batches are always better. The obvious
conclusion is wrong, and the reason is worth a whole page of mathematics.

Here is the cost of a batch of size $k$, counted **per item**:

$$C(k) \;=\; \underbrace{\frac{A}{k}}_{\text{setup, amortised}} \;+\; \underbrace{c}_{\text{flat}} \;+\; \underbrace{q\bigl(k^{\mu-1}-1\bigr)}_{\text{multiplication penalty}}$$

The first term falls as $k$ grows. The third rises — because the batch's working
integer gets $k$ times longer, and multiplying long numbers is super-linear. The
exponent $\mu$ is the **multiplication exponent** of your arithmetic: $\mu = 2$ for
schoolbook long multiplication, $\mu = \log_2 3 \approx 1.585$ for Karatsuba,
$\mu = \log_3 5 \approx 1.465$ for Toom–Cook, and $\mu \to 1$ for FFT-based products
(and for any model that counts *operations* rather than machine words).

**Everything in this page follows from the tug-of-war between those two terms.**

<details>
<summary><b>Where does $k^{\mu-1}$ come from?</b> (click to expand)</summary>

If a single candidate occupies $n$ machine words, a batch of $k$ candidates occupies
about $kn$ words. Multiplying two $m$-word integers costs $\Theta(m^{\mu})$ word
operations, so the batch's big multiplication costs $\Theta((kn)^{\mu})$ against
$\Theta(n^{\mu})$ for a single candidate. Divide by $k$ to get a per-candidate figure:
$\Theta(k^{\mu-1}n^{\mu})$. Absorbing constants into $q$, and normalising so that a
batch of one carries no penalty, gives $q(k^{\mu-1}-1)$. See
[multiplication algorithms](https://en.wikipedia.org/wiki/Multiplication_algorithm)
for the exponents themselves.
</details>

---

## 2. Play with it first

Before any theorem, get the feel of the curve. Drag $\mu$ from $2$ down toward $1$ and
watch the minimum slide to the right — and then vanish.

{{interactive_demo:0}}

Three things to notice while you play:

1. **There is exactly one minimum** whenever $\mu > 1$. Never two, never a flat valley.
2. **The minimum moves right as $\mu$ falls.** Faster multiplication does not just make
   batching cheaper — it makes *bigger* batching optimal.
3. **The bottom is flat.** The yellow band marks $\pm 10\%$ around the optimum; the cost
   barely changes across it. Read off the "loss from mis-sizing" figure and see how
   small it stays even at a factor of two.

Each of these is a theorem. Let us prove them.

---

## 3. The Root Law

> **Theorem (Root Law).** Let $A>0$, $q>0$ and $\mu>1$. The per-item cost
> $C(k) = A/k + c + q(k^{\mu-1}-1)$ attains its minimum over $(0,\infty)$ at exactly
> one point,
> $$k^{*} = \left(\frac{A}{(\mu-1)q}\right)^{1/\mu},$$
> with minimum value
> $$C(k^{*}) = c - q + \mu(\mu-1)^{\frac{1-\mu}{\mu}}A^{\frac{\mu-1}{\mu}}q^{\frac{1}{\mu}}.$$
> Every other batch size is strictly worse.

At $\mu = 2$ this reads $k^{*} = \sqrt{A/q}$ and $C(k^{*}) = c - q + 2\sqrt{Aq}$: the
classical **square-root law**, the same shape as the
[economic order quantity](https://en.wikipedia.org/wiki/Economic_order_quantity) of
inventory theory. The general statement says the square root was never fundamental —
it was the fingerprint of schoolbook arithmetic. The true law is a $\mu$-th root.

<details>
<summary><b>Click to reveal the full proof — no calculus required</b></summary>

**Step 1: Bernoulli's inequality.** For $u \ge 0$ and $\mu \ge 1$,
$$\mu u \;\le\; u^{\mu} + (\mu-1),$$
strictly when $\mu > 1$ and $u \ne 1$. (Put $s = u-1$ in
$1+\mu s \le (1+s)^{\mu}$.)

**Step 2: divide by $u$.** For $u>0$ this becomes the *weighted AM–GM shape*
$$\mu \;\le\; \frac{\mu-1}{u} + u^{\mu-1},$$
again strict off $u=1$. This is exactly weighted AM–GM with weights
$\bigl(\tfrac{\mu-1}{\mu}, \tfrac{1}{\mu}\bigr)$ applied to $u^{-1}$ and $u^{\mu-1}$,
whose geometric mean is $1$.

**Step 3: the balance principle.** Call $t>0$ *balanced* if
$$A = q(\mu-1)t^{\mu}, \qquad\text{equivalently}\qquad \frac{A}{t} = (\mu-1)\cdot q\,t^{\mu-1}:$$
the amortised setup is $(\mu-1)$ times the marginal penalty. Writing $k = \theta t$ and
using $t\cdot t^{\mu-1} = t^{\mu}$, the variable part of the cost factors as
$$\frac{A}{k} + q k^{\mu-1} \;=\; q\,t^{\mu-1}\left(\frac{\mu-1}{\theta} + \theta^{\mu-1}\right).$$
By Step 2 the bracket is $\ge \mu$ with equality only at $\theta = 1$. So a balanced
point is the unique global minimiser, with value $q\mu t^{\mu-1}$.

**Step 4: solve for the balanced point.** $A = q(\mu-1)t^{\mu}$ gives
$t = (A/((\mu-1)q))^{1/\mu} = k^{*}$, and substituting into $q\mu t^{\mu-1}$, then
adding $c - q$, produces the closed form in the statement. $\blacksquare$

The proof never differentiates anything. That robustness pays off twice below: once
for unimodality, once for the discrete optimum.
</details>

**The balance condition is the moral of the story.** At the optimum, the setup share of
the cost is exactly $\frac{\mu-1}{\mu}$ of the variable cost. For $\mu = 2$ that is a
50/50 split — the familiar "balance the two terms" heuristic, now a theorem. As
$\mu \downarrow 1$ the setup share collapses to zero, and the only way the curve can
achieve that is to push $k^{*}$ off to infinity.

{{visualization:0}}

---

## 4. What happens at $\mu = 1$: the vanishing act

Set $\mu = 1$ and the penalty term is identically zero:

$$C(k) = \frac{A}{k} + c.$$

This is strictly decreasing. **There is no optimum**: every batch size is beaten by a
larger one. This is not a special case bolted on — it is the continuous limit of the
root law. Quantitatively: if $\mu - 1 \le A/(qM^{2})$ (with $\mu \le 2$ and $M \ge 1$),
then $k^{*} \ge M$ already. Push $\mu$ toward $1$ in the explorer above and watch
$k^{*}$ blow past $10^{6}$.

This single fact resolves the engineering puzzle that started the whole investigation.
A measurement in the *word* model (counting machine words, so $\mu = 2$) shows batching
reversing around a few thousand candidates. A measurement in the *operation* model
(one tick per multiplication, so effectively $\mu = 1$) shows no reversal at all.
Both are right. **The reversal belongs to the arithmetic, not to the batching.**

---

## 5. One curve in disguise: the universal collapse

Here is the most elegant structural fact. Measure the batch not in items but in
multiples of the optimum: write $k = \theta k^{*}$. Then

$$C(\theta k^{*}) \;=\; (c-q) \;+\; q\,(k^{*})^{\mu-1}\,S_{\mu}(\theta),
\qquad\boxed{\,S_{\mu}(\theta) = \frac{\mu-1}{\theta} + \theta^{\mu-1}\,}$$

The setup $A$ and penalty $q$ have vanished into a vertical scale. The *shape* depends
only on $\mu$, and $S_{\mu}(1) = \mu$: the minimum of the shape is its own exponent.

Toggle "shape coordinates" in the explorer, then change $A$ and $q$ freely — the curve
does not move. That is the collapse, live.

{{visualization:1}}

The left panel above overlays cost curves from wildly different $(A,q)$ pairs after
rescaling: they land on one another exactly. The right panel is the flatness bound.

> **Theorem (Quadratic flatness).** For $1 < \mu \le 2$ and $\theta > 0$,
> $$S_{\mu}(\theta) - \mu \;\le\; \frac{(\mu-1)(\theta-1)^{2}}{\theta}.$$

The excess is **second order** in the sizing error. In relative terms the overhead of
using $\theta k^{*}$ is at most $\frac{\mu-1}{\mu}\cdot\frac{(\theta-1)^2}{\theta}$:
for schoolbook arithmetic, a $20\%$ sizing error costs under $1.7\%$, and being off by a
whole factor of two costs at most $25\%$. On faster arithmetic the plateau is flatter
still, because the prefactor is $\mu-1$.

<details>
<summary><b>Why the collapse is a falsifiability test, not just an aesthetic</b></summary>

A single-tier model has *exactly one* optimum — that is the uniqueness clause of the
Root Law. So if you plot a real measured cost curve in shape coordinates and it shows
**two** local minima, you have not found a counterexample to the mathematics: you have
found evidence that your machine is not a single-tier model. The usual culprit is the
memory hierarchy, which makes the effective $\mu$ jump when the working set spills a
cache level, or a multiplication library that switches algorithms at a size threshold.
The collapse gives you a parameter-free way to spot the boundary.
</details>

---

## 6. Convex — but only in the logarithm

A subtlety that only appears below the quadratic model. Is $C$ convex in $k$?

* For $\mu = 2$: yes, obviously — $A/k$ and $qk$ are both convex.
* For $\mu < 2$: **no.** Take $\mu = 3/2$, $A = q = 1$, $c = 0$. Then
  $C(4) = 1.25$, $C(100) = 9.01$, average $5.13$; but $C(52) = 6.23 > 5.13$. A convex
  function cannot exceed the chord at the midpoint.

What survives, for every $\mu$, is **multiplicative convexity**: along geometric
interpolations $k = k_1^{w}k_2^{1-w}$ with $w \in [0,1]$,
$$C\bigl(k_1^{w}k_2^{1-w}\bigr) \;\le\; w\,C(k_1) + (1-w)\,C(k_2).$$
Equivalently, $C$ is convex as a function of $\log k$.

<details>
<summary><b>Proof sketch, and why this explains the root</b></summary>

Apply the two-point weighted AM–GM inequality $x^{w}y^{1-w} \le wx + (1-w)y$ separately
to the setup term, using $A/(k_1^{w}k_2^{1-w}) = (A/k_1)^{w}(A/k_2)^{1-w}$, and to the
penalty term, using $(k_1^{w}k_2^{1-w})^{\mu-1} = (k_1^{\mu-1})^{w}(k_2^{\mu-1})^{1-w}$.
Add.

In logarithmic coordinates $x = \log k$, the cost is $Ae^{-x} + c + q(e^{(\mu-1)x}-1)$:
a sum of two exponentials with slopes $-1$ and $\mu-1$. Minimising such a sum gives a
weighted *geometric* mean of the parameters, with weights $\frac{1}{\mu}$ and
$\frac{\mu-1}{\mu}$ — that is, a $\mu$-th root of $A/q$. Multiplicative convexity is
not a curiosity; it is the reason the answer is a root at all.
</details>

The practical warning: optimisation routines that assume convexity in $k$ lose their
guarantees below $\mu = 2$. Run them on $\log k$ instead.

---

## 7. What integer should I actually use?

Real batch sizes are integers. Does knowing $k^{*}$ help? Only if the cost does not
wobble — and it does not.

> **Theorem (Strict unimodality).** $C$ is strictly decreasing on $(0,k^{*}]$ and
> strictly increasing on $[k^{*},\infty)$.
>
> **Corollary.** For every integer $n \ge 1$, $C(n)$ is at least the smaller of
> $C(\lfloor k^{*}\rfloor)$ and $C(\lceil k^{*}\rceil)$: **the best integer batch is a
> neighbour of the real optimum.** (Clamp the floor at $1$ when $k^{*} < 1$.)

<details>
<summary><b>The balance-shift trick (click to reveal)</b></summary>

To show $C$ falls as you move up toward $k^{*}$, take $0 < k_1 < k_2 \le k^{*}$ and
invent an *auxiliary* problem with setup $A' := q(\mu-1)k_2^{\mu}$, chosen precisely so
that $k_2$ is its balanced point. The balance principle then gives, for free,
$$\frac{A'}{k_2} + qk_2^{\mu-1} \;<\; \frac{A'}{k_1} + qk_1^{\mu-1}.$$
Since $k_2 \le k^{*}$ we have $A' \le A$, and the discrepancy between the real and
auxiliary costs is $(A-A')/k$, which is *decreasing* in $k$, hence
$(A-A')/k_2 \le (A-A')/k_1$. Adding the two relations transfers the strict inequality
to the real cost. The other half is symmetric. Once again: no derivatives.
</details>

A pleasant consequence: **ternary search is correct**. Because there are no spurious
local minima, a black-box search that only times batches converges to the exact integer
optimum in $O(\log N)$ measurements — no calibration required.

{{algorithm:2}}

And when you *do* know the parameters, the answer is closed-form and $O(1)$:

{{algorithm:0}}

If you do not know them yet, three timings suffice, because the model is linear in
$(A,c,q)$ at fixed $\mu$:

{{algorithm:1}}

---

## 8. The question practitioners actually ask: batch, or not?

Not "what is the best batch?" but "is batching worth it for this pool at all?".
Compare the batched per-item cost $q(k^{\mu-1}-1)+c_1$ against a solo cost $s_1$:

> **Theorem (Crossover root law).** Batching is at least as cheap as solo testing
> exactly for pools of size
> $$k \;\le\; M^{*}(\mu) = \left(1 + \frac{s_1-c_1}{q}\right)^{\frac{1}{\mu-1}}.$$

At $\mu = 2$ the exponent is $1$ and this is the plain linear formula
$1 + (s_1-c_1)/q$ — which is why a measured schoolbook crossover looks like a simple
ratio. Calibrated to a measured turning point of $1715$ candidates, the ratio is
$R = 1715$. But for $\mu < 2$ the crossover is a **root** of the same ratio, and it
never shrinks: $M^{*}(\mu) \ge M^{*}(2)$ for all $1 < \mu \le 2$. At $\mu = 3/2$ it is
$1715^{2} = 2\,941\,225$ — three orders of magnitude further out. As $\mu \downarrow 1$
it diverges, and there is no crossover at any pool size.

Try it: set the ratio to $1715$ and slide $\mu$.

{{interactive_demo:1}}

{{visualization:2}}

---

## 9. Check it numerically

Theory is one thing; here are the numbers. The first program walks through every
result above — the root law across exponents, equipartition, the flat model, the
collapse and flatness bounds, the convexity counterexample, the discrete optimum, the
crossover, and a calibration round-trip.

{{demo:0}}

The second is an audit: hundreds of random parameter triples, each checked against the
closed form, unimodality, the neighbour property of the integer optimum, the flatness
bound and multiplicative convexity. Note what it reports about *ties*: for very large
$k^{*}$ the plateau is so flat that neighbouring integer costs are indistinguishable in
double precision. That is the flatness theorem making itself felt in floating point.

{{demo:1}}

---

## 10. Where to go next

* **Cache tiers.** A memory hierarchy makes $\mu$ a *step function* of the batch size,
  so the true cost is a finite gluing of root laws and the global optimum is the best of
  finitely many tier-local optima. The universal collapse is the detector: a second
  local minimum means a tier boundary.
* **Beyond pure powers.** FFT multiplication costs $k\log k\log\log k$, whose "local
  exponent" is slowly varying rather than constant. The balance principle never used the
  exact form $k^{\mu-1}$ — only multiplicative convexity with the opposite slope — so the
  natural generalisation puts the optimum wherever the elasticity $kP'(k)/P(k)$ of the
  penalty profile crosses $1$.
* **Sharper flatness.** The bound $(\mu-1)(\theta-1)^{2}/\theta$ is Bernoulli-derived,
  while the true excess has Taylor coefficient $\mu(\mu-1)/2$ at $\theta = 1$. Pinning
  down where the crude bound stays within a fixed factor of the truth turns "the optimum
  is a plateau" into an actionable tuning tolerance.

**The one-line takeaway:** batch, but batch to a root — and if your measurements say
batching stops paying off, suspect your multiplication before you suspect your batching.
