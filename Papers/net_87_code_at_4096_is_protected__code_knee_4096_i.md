# How much can a machine forget?

*A guided tour of retention knees, the narrowing domain factor, and why a
rising ratio is not evidence of convergence.*

---

## 1. The question, in one picture

You are reading something long. You cannot keep all of it. So you keep a few
things — the names, the key clause, the variable everything depends on — and let
the rest fade.

Machines that read text face the same problem in a form sharp enough to measure.
When a language model produces its next token it spreads attention across
everything it has read; most of the attention lands on very few places. So:
**how few places can you keep before the answer changes?**

Sort the positions from most-attended to least-attended and add up the weights.
The **retention curve** $M(k)$ is the mass held by the top $k$ positions. Fix a
tolerance $\tau$ — say you insist on preserving $98\%$ of the mass. The
**knee** is the smallest budget clearing the bar:

$$k^{*}(\tau) \;=\; \min\{\, k : M(k) \ge \tau \,\}.$$

That number is the honest price of memory. Everything below is about how it
behaves.

Play with the explorer before reading on. Drag the two peakedness sliders and
the bar; watch the knees move.

{{interactive_demo:1}}

> **What you should notice.** When the code curve sits above the prose curve at
> *every* budget, the code knee is below the prose knee at *every* bar — not just
> at the one you chose. That is not a coincidence; it is a theorem, and it is the
> right definition of "protected".

<details>
<summary><b>Click to reveal: protection at every bar <em>is</em> dominance of curves</b></summary>

**Theorem.** Let $M_c$ and $M_q$ be retention curves, with $c$ a nonnegative
profile. Then
$$M_q(k) \le M_c(k) \ \text{ for every budget } k$$
if and only if, for every bar $\tau$ that prose can reach, code can reach it too
and $k^{*}_c(\tau) \le k^{*}_q(\tau)$.

*Proof.* ($\Rightarrow$) The knee clears its own bar, so
$\tau \le M_q(k^{*}_q(\tau)) \le M_c(k^{*}_q(\tau))$, and the minimality of the
knee gives $k^{*}_c(\tau) \le k^{*}_q(\tau)$.

($\Leftarrow$) Fix a budget $k$ and apply the hypothesis at the *particular* bar
$\tau = M_q(k)$, which prose reaches at budget $k$. Then
$k^{*}_c(M_q(k)) \le k^{*}_q(M_q(k)) \le k$. Since the code knee clears its bar
and $M_c$ is nondecreasing,
$$M_q(k) \;\le\; M_c\bigl(k^{*}_c(M_q(k))\bigr) \;\le\; M_c(k). \qquad\blacksquare$$

The moral: a domain ordering that survives every threshold is a statement about
whole curves, so you never have to worry that "code is cheaper" was an artefact
of where the bar was set.
</details>

---

## 2. The measurement

Sweep the knee for **source code** and for **prose** at several context lengths:

| context | code knee | prose knee |
|---:|---:|---:|
| $512$ | $12$ | $16$ |
| $1024$ | $16$ | *(not yet measured)* |
| $4096$ | $32$ | $40$ |

Two things jump out.

**An acceleration.** Code goes $12 \to 16$ over the first doubling: four extra
keys. At that pace, two more doublings would land at $24$. The measurement says
$32$.

**A persistent but eroding discount.** Code is always cheaper: the ratio is
$12/16 = 0.75$ at short context and $32/40 = 0.80$ at long context. Code is
protected — but the protection appears to be wearing off, and the obvious
extrapolation is eventual parity.

That extrapolation is exactly wrong, and the rest of this page is about why.

---

## 3. First, a caveat that is a theorem

The code knee at $4096$ was found on a coarse grid: a budget of $28$ retained
about $0.976$ (fail) and $32$ retained $0.986$ (pass). Reported: $k^{*} = 32$.

But a fail at $28$ and a pass at $32$ prove only that the knee lies in
$\{29, 30, 31, 32\}$. And that bracket is *not improvable*.

> **Grid Ambiguity Theorem.** There are two nonnegative decreasing profiles that
> retain **exactly the same mass** at every budget at or below $28$ and at every
> budget at or above $32$, whose knees are $29$ and $32$ respectively.

Both candidate worlds are observationally identical outside the gap. The
reported $32$ is the top of a four-wide bracket, and only measurement inside the
gap can shrink it. Slide "grid spacing" in the explorer above down to $1$ and
watch the bracket collapse.

Here is the algorithm that reports honestly.

{{algorithm:0}}

---

## 4. The model: one clock, two rates

The acceleration is a hint that context length is not the natural independent
variable. Something is undergoing a transition, and each domain rides the *same*
transition at its own rate. So introduce a shared coordinate $T$ —
"phase-transition time" — and posit that each domain's knee is affine in it:

$$K_d(T) \;=\; a_d + b_d\,T,$$

with $a_d$ the structural baseline of the domain and $b_d$ how hard the
transition inflates that domain's budget.

Now watch **two** observables, not one:

$$r(T) = \frac{K_{\text{code}}(T)}{K_{\text{prose}}(T)}
\qquad\text{and}\qquad
G(T) = K_{\text{prose}}(T) - K_{\text{code}}(T).$$

This is the heart of the matter. The laboratory below lets you set all four
constants and watch both observables at once. **Start with the "Measured fit"
preset, then press "Parity rival" and look only at the ratio panel.**

{{interactive_demo:0}}

> **The trap, in one click.** The two presets produce *identical* ratios at the
> two measured contexts — $3/4$ and $4/5$ — but their ceilings are $5/6$ and $1$.
> One is permanent protection; the other is eventual parity. Nothing about the
> ratio's history distinguishes them. The gap panel separates them instantly:
> $4 \to 8$ versus $4 \to 4$.

<details>
<summary><b>Click to reveal: narrowing is a sign condition, not a trend</b></summary>

**Theorem.** With $a_p > 0$, $b_p \ge 0$ and $0 \le T_1 < T_2$, the ratio
increases, $r(T_1) < r(T_2)$, **iff** $a_c b_p < a_p b_c$.

*Proof.* Both denominators are positive, so cross-multiplying,
$$r(T_1) < r(T_2)
\iff (a_c + b_c T_1)(a_p + b_p T_2) < (a_c + b_c T_2)(a_p + b_p T_1).$$
Expand: the $a_c a_p$ terms cancel, the $b_c b_p T_1 T_2$ terms cancel, and what
remains is
$$a_c b_p (T_2 - T_1) < a_p b_c (T_2 - T_1).$$
Since $T_2 - T_1 > 0$, this is equivalent to $a_c b_p < a_p b_c$. $\blacksquare$

So narrowing is not a trend that might continue or reverse — it is one fixed
inequality among four constants. It holds at all scales or none.
</details>

<details>
<summary><b>Click to reveal: the ratio never reaches its own ceiling</b></summary>

**Theorem (exact error term).** If $b_p > 0$ and $K_p(T) > 0$ then
$$r(T) - \frac{b_c}{b_p} \;=\; \frac{a_c b_p - a_p b_c}{b_p\,K_p(T)} .$$

*Proof.* Put both terms over the common denominator $b_p(a_p + b_p T)$. The
numerator is $b_p(a_c + b_c T) - b_c(a_p + b_p T)$; the $T$-terms cancel
identically, leaving the constant $a_c b_p - a_p b_c$. $\blacksquare$

Two consequences. Under narrowing the numerator is negative, so
$r(T) < b_c/b_p$ for **every** $T$ — the ratio climbs strictly toward a ceiling
it never touches. And since $K_p(T) \to \infty$, the error decays like
$1/K_p(T)$, so $r(T) \to b_c/b_p$. Whether that ceiling is parity depends only on
$b_c$ versus $b_p$, which the ratio's history cannot see. The fourth panel in the
laboratory plots exactly this error on a log scale.
</details>

<details>
<summary><b>Click to reveal: the permanence theorem</b></summary>

The gap is affine, $G(T) = (a_p - a_c) + (b_p - b_c)T$, so a growing gap forces
$b_c < b_p$ directly. Combining:

**Theorem (permanent protection).** Let $a_p, b_p > 0$ and $0 \le T_1 < T_2$.
If between two contexts *both* the ratio increased and the gap increased, then
$b_c < b_p$, hence
$$r(T) \;<\; \frac{b_c}{b_p} \;<\; 1 \qquad \text{for every } T \ge 0 .$$

The measured cell has ratios $3/4 \to 4/5$ and gaps $4 \to 8$. Both increased.
So the discount is permanent, and its floor is $b_c/b_p = 20/24 = 5/6$: **code
stays cheaper by a sixth, forever.**
</details>

The figure below is the same story in static form — the two laws, the ratio with
its unreachable ceiling, and the gap that decides.

{{visualization:0}}

And here is the fitting-and-deciding algorithm in full.

{{algorithm:1}}

---

## 5. The fit, and a prediction with something to lose

The measured numbers fit an affine pair exactly, with $T = 0$ at context $512$
and $T = 1$ at context $4096$:

$$K_{\text{code}}(T) = 12 + 20T, \qquad K_{\text{prose}}(T) = 16 + 24T .$$

All four measured knees, both ratios, both gaps, no residual. And there is a
bonus: the code knee $16$ at context $1024$ pins that context to $T = 1/5$, and
then the same fit *forces* the prose knee there to be

$$K_{\text{prose}}(1024) \;=\; 16 + \tfrac{24}{5} \;=\; \tfrac{104}{5} \;=\; 20.8 .$$

Nothing was fitted to produce that. A prose sweep landing on $20$ or $21$
corroborates the model; a landing at $24$ or above destroys it.

There is an even cheaper falsifier, requiring no fitting at all. For an affine
law take any three contexts and form the **normalised increment**

$$\rho \;=\; \frac{K(T_2) - K(T_1)}{K(T_3) - K(T_1)} \;=\; \frac{T_2 - T_1}{T_3 - T_1}.$$

The baseline cancels by subtraction and the slope by division: **$\rho$ does not
depend on the domain at all.** It is the knee analogue of a
[cross-ratio](https://en.wikipedia.org/wiki/Cross-ratio), invariant under affine
reparametrisation — and the converse holds, so "one shared transition,
per-domain slopes" is *exactly* "equal normalised increments".

For the code chain $\rho = (16-12)/(32-12) = 1/5$, giving every domain on the
same transition the one-line forecast

$$K(4096) \;=\; K(512) + 5\,\bigl(K(1024) - K(512)\bigr).$$

A domain kneeing at $10, 14$ must knee at $30$; one at $14, 20$ at $44$; one at
$16, 24$ at $56$. Any single sweep that misses its line kills the model.

---

## 6. The acceleration is a broken concavity

What does "the acceleration hits code" mean, precisely? Index contexts by
doublings from $512$. A law of **diminishing returns** is one whose per-doubling
increments never grow.

> **Concave Chain Bound.** If $K(j+2) - K(j+1) \le K(j+1) - K(j)$ for all $j$,
> then $K(j) \le K(0) + j\,(K(1) - K(0))$.

Two-line induction: every increment is at most the first one, so $j$ steps add at
most $j$ times the first increment. Now apply it with $K(0) = 12$, $K(1) = 16$:
the cap at four doublings is $12 + 3\cdot 4 = 24$. The measurement is $32$.

**Every diminishing-returns law is refuted, by $8$ keys.** Not one curve — the
whole class.

{{visualization:1}}

<details>
<summary><b>Click to reveal: so where <em>did</em> the acceleration go?</b></summary>

Here is a genuine puzzle. The affine two-slope fit has *constant* increments in
$T$; it is not convex. Yet it reproduces a chain that refutes concavity. How?

The acceleration lives in the **clock**. The fit forces
$$T(0) = 0, \qquad T(1) = \tfrac15, \qquad T(3) = 1,$$
so the coordinate advances by $1/5$ over the first doubling and by $2/5$ per
doubling thereafter — with strictly increasing increments. Phase-transition time
races ahead of calendar time.

The domain responds linearly. **The transition accelerates.** That is a much more
interesting statement than "code got expensive faster than expected", and it is
what makes the shared-coordinate model testable across domains at all.
</details>

{{algorithm:2}}

---

## 7. Reading the verdict on attention itself

Everything so far has been about budgets. Push down to the attention weights and
something clean appears. Model the attention tail as exponential with decay rate
$\lambda$; keeping enough positions that the discarded tail falls below $\delta$
requires exactly

$$K(\lambda, \delta) \;=\; \frac{\log(1/\delta)}{\lambda}.$$

Two domains at the same tolerance therefore satisfy

$$\frac{K_{\text{code}}}{K_{\text{prose}}} \;=\; \frac{\lambda_{\text{prose}}}{\lambda_{\text{code}}} .$$

The domain factor is an **inverse ratio of decay rates**. "Code is protected"
says precisely: *code's attention is more sharply peaked than prose's.* And the
narrowing says the peakedness advantage is eroding — from $4/3$ at short context
to $5/4$ at $4096$, with a permanent floor of $6/5$.

<details>
<summary><b>Click to reveal: the chain pins the rates, and no harmonic law fits</b></summary>

From $K = 12, 16, 32$ at doublings $j = 0, 1, 3$, each knee gives
$\log(1/\delta) = K_j \lambda_j$, so
$$4\lambda_1 = 3\lambda_0, \qquad 8\lambda_3 = 3\lambda_0,
\qquad\text{hence}\qquad \lambda_3 = \tfrac38\lambda_0 < \tfrac12\lambda_0 .$$
An affine knee law would put the long-context rate at $\lambda_0/2$; the
measurement forces it strictly below. The degradation is **super-harmonic**.

Worse for the simple story: the natural family of rate laws — the one equivalent
to "each doubling costs a fixed number of extra keys" — is the generalised
harmonic family $\lambda_j = C/(j+c)$. Writing $L = \log(1/\delta)$, each knee
becomes $L(j + c) = K_j C$, so
$$Lc = 12C, \qquad L(1+c) = 16C, \qquad L(3+c) = 32C .$$
Subtracting consecutively gives $L = 4C$ and $2L = 16C$, i.e. $L = 8C$. Hence
$C = 0$, which is impossible. **No member of the family fits, for any $C$ and any
offset.** The acceleration is a change of *shape*, not of scale.
</details>

---

## 8. Is it just the tokenizer?

The obvious objection: perhaps code only looks cheaper because tokenizers chop
code and prose at different granularity. Suppose each code unit becomes $r_c$
tokens and each prose unit $r_p$. Then protection survives whenever

$$r_c \cdot K_{\text{code}} \;\le\; r_p \cdot (K_{\text{prose}} - 1),$$

and in particular whenever the tokenizer is **no coarser on code than on prose**,
$r_c \le r_p$ — which covers every realistic case. The condition is not
decorative: with $r_c = 8$, $r_p = 1$ the diluted code knee provably exceeds the
diluted prose knee. So protection is a genuine, and mild, constraint.

There is also a companion negative result worth stating. A *purely
multiplicative* domain model — code's knee a fixed constant times prose's, which
is what a pure tokenisation mechanism predicts — is refuted by **any** change in
the ratio. The ratio demonstrably moved from $3/4$ to $4/5$. Therefore an
**additive** structural term is required: the $a_d$ in the law is real, and the
data insists on it.

---

## 9. Run the numbers yourself

The demonstration below reproduces every numerical claim on this page in exact
rational arithmetic, one function per theorem, with no dependencies.

{{demo:0}}

---

## 10. What to take away

* **The knee is the price of memory**, and a knee read off a coarse grid is
  honestly a bracket. The reported $32$ is really $[29, 32]$, provably not
  narrower on the available data.
* **Protection is a property of curves, not thresholds.** A domain ordering that
  survives every bar is pointwise dominance of retention, and conversely.
* **A rising ratio proves nothing about its limit.** Two laws with the same two
  measured ratios can have limits $5/6$ and $1$. The gap decides in one step,
  and the measured gap doubled.
* **Hence permanence:** the code discount settles at a sixth and never closes,
  even as the ratio narrows. Both facts are true at once, and confusing them is
  the easiest mistake here.
* **The absolute cost accelerates for everyone.** No diminishing-returns law
  survives the code chain, and on rates the degradation is super-harmonic and
  outside the whole harmonic family.

The most transferable lesson is the third. A clean monotone trend in a ratio does
not determine where the ratio is going, and the remedy is not more precision on
the same observable — it is a *different* observable. Here the gap does it
immediately, and for a structural reason: the ratio is blind to a common
rescaling of both laws, and the gap is not.
