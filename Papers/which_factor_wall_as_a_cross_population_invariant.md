# One Number, One Population: How Much Does a Wall Really Tell You?

> **The premise.** A laboratory records, for every member of a population, a single
> yes/no fact. It publishes exactly one number: the average information content of
> that record, in bits. Call it the **wall**. What can a reader who sees only this
> number conclude about how the population actually splits?
>
> The short answer of this page: *far more than you would guess, but only if you
> also publish how much the number is allowed to say.*

---

## 1. The wall, in one formula

If a fraction $p$ of the population falls in the minority class and $1-p$ in the
majority, then the information content of one observation is the **binary
entropy**

$$
h(p) \;=\; p\log\frac1p \;+\; (1-p)\log\frac1{1-p}.
$$

We measure it in *nats* (natural logarithm) and convert to bits by dividing by
$\log 2$. Three facts do all the work:

- $h(0)=0$: everyone answers the same way, the record is worthless;
- $h(1/2)=\log 2$, one bit: a genuine coin flip, maximal surprise;
- $h$ is **strictly increasing** on $[0,\tfrac12]$, so a wall value determines the
  minority fraction *uniquely*.

That last point is the whole reason a wall is worth publishing. It is also, on its
own, almost useless — because two laboratories never report *identical* walls.

<details>
<summary><b>Why entropy and not, say, the variance $p(1-p)$?</b></summary>

Any strictly increasing function of $p$ on $[0,\tfrac12]$ would identify the split.
The entropy is the canonical choice because it is the average number of bits needed
to transmit the record, so it composes correctly when several statistics are
reported together, and it is invariant under relabelling the two classes. Its
price is that it is *flat* at $p=1/2$ — $h'(1/2)=0$ — and that flatness is the
central drama of everything below. For orientation, see
[Entropy (information theory)](https://en.wikipedia.org/wiki/Entropy_(information_theory))
and [binary entropy function](https://en.wikipedia.org/wiki/Binary_entropy_function).
</details>

---

## 2. Play with it first

Before any theorem: drag the wall reading and see what it pins down. Try the
preset for the reported value of $0.4677$ bits, then the presets for a $5\%$ and a
$15\%$ split, and notice how far those readings sit from $0.4677$. Then push the
reading toward $1$ bit and watch the certified interval blow up.

{{interactive_demo:0}}

Three things to notice while you play.

1. **The recovered split is unique.** There is exactly one point where the dashed
   reading line meets the curve on $[0,\tfrac12]$.
2. **The width of the certified interval depends enormously on where you are.**
   The same $\pm 0.01$ bit error bar buys a resolution of a third of a percentage
   point at a $10\%$ split, and several percentage points near balance.
3. **A prior cap helps a lot — when it is legitimate.** If you already know the
   split is at most $1/9$, the resolution improves by more than an order of
   magnitude. Set the cap below the reading and the widget refuses to use it.

---

## 3. The question, made precise

> If two independent populations report walls agreeing to within $\varepsilon$, how
> close must their splits be?

This is the *cross-population* question, and it is the only version that matters
for replication. Everything else on this page is an answer to it.

The natural attack is the mean value theorem. The derivative of the wall is

$$
h'(x) \;=\; \log\frac{1-x}{x},
$$

which on an interval $[\delta,\tfrac12]$ is largest at the left endpoint, with
value $c(\delta) = \log\frac{1-\delta}{\delta}$. So one is tempted to write

$$
|h(p)-h(q)| \;\ge\; c(\delta)\,|p-q|
\qquad\Longrightarrow\qquad
|p-q| \;\le\; \frac{|h(p)-h(q)|}{c(\delta)} .
$$

**This is false.** And the reason is worth internalising, because it is the kind of
error that survives a plausibility check.

---

## 4. Break the conjecture yourself

$c(\delta)$ is the **supremum** of the derivative. A supremum of a derivative bounds
the slope of a chord from *above* — it is a Lipschitz constant. An inverse bound
needs the **infimum**, which on $[p,q] \subseteq [0,\tfrac12]$ is the slope at the
endpoint *nearest balance*.

Drag the sliders below until the verdict panel turns red. It takes about one second.

{{interactive_demo:1}}

<details>
<summary><b>Click to reveal the exact counterexample and its one-line arithmetic</b></summary>

Take $\delta = q = \tfrac14$ and $p = \tfrac12$. Then $c(\tfrac14) = \log 3$ and
$|p-q| = \tfrac14$, while

$$
h(\tfrac12) = \log 2,
\qquad
h(\tfrac14) = \tfrac14\log 4 + \tfrac34\log\tfrac43 = 2\log 2 - \tfrac34\log 3 .
$$

The conjecture demands

$$
\tfrac14\log 3 \;\le\; \tfrac34\log 3 - \log 2
\quad\Longleftrightarrow\quad
2\log 2 \le \log 3
\quad\Longleftrightarrow\quad
4 \le 3 .
$$

Numerically: it asks for $0.27465 \le 0.13082$.

The salvage is the same inequality with the direction reversed, which *is* a
theorem: for $p,q \in [\delta,1-\delta]$,
$$
|h(p) - h(q)| \;\le\; \log\tfrac{1-\delta}{\delta}\,|p-q| .
$$
The conjecture was this theorem read backwards.
</details>

---

## 5. The correct linear constant, and the guard it needs

The right mean-value statement uses the slope at the *upper* endpoint:

> **Endpoint slope bound.** For $0 \le p \le q \le \tfrac12$,
> $$(q-p)\,\log\frac{1-q}{q} \;\le\; h(q) - h(p).$$

<details>
<summary><b>Proof sketch</b></summary>

For $x$ between $p$ and $q$ we have $x \le q \le \tfrac12$, so $\log x \le \log q$
and $\log(1-q) \le \log(1-x)$; hence $h'(x) \ge \log\frac{1-q}{q} =: c$. Therefore
$x \mapsto h(x) - cx$ has nonnegative derivative and is nondecreasing, and
evaluating it at $p$ and at $q$ gives the chord bound. The boundary case $p = 0$ is
a direct computation: the difference between the two sides is exactly
$-\log(1-q) \ge 0$.

The constant $\log\frac{1-q}{q}$ is the *infimum* of $h'$ on $[p,q]$, so no larger
constant works, and it degenerates to $0$ as $q \to \tfrac12$.
</details>

Feeding this into the replication question gives the corrected theorem. Fix a
**guard** $\eta > 0$ and suppose both splits lie in $[0,\tfrac12-\eta]$. Then

$$
|p-q| \;\le\; \frac{\varepsilon}{\log\dfrac{1/2+\eta}{1/2-\eta}}
$$

whenever the walls agree within $\varepsilon$. Same shape as the guess, constant
evaluated at the guard point instead of the far end.

The pipeline that turns a reading into this bound is short and entirely explicit:

{{algorithm:1}}

---

## 6. Why the guard cannot be dropped

As $\eta \to 0$ the constant $\log\frac{1/2+\eta}{1/2-\eta} \approx 4\eta$ collapses.
It must, because the wall is *quadratically flat* at balance:

$$
2t^2 \;\le\; \log 2 - h\!\left(\tfrac12 - t\right) \;\le\; 4t^2 .
$$

Consequently, for **any** constant $C$ and **any** window around $\tfrac12$, there
are two splits inside it whose walls are closer than $C$ times their separation.
Linear inversion at balance is impossible, full stop.

{{visualization:1}}

The right-hand panel is the whole story in one line: the deficit hugs a slope-$2$
line on log-log axes, trapped between $2t^2$ and $4t^2$.

<details>
<summary><b>Where does the upper bound $4t^2$ come from?</b></summary>

Write $p = \tfrac12 - t$, so $p = (1-2t)/2$ and $1-p = (1+2t)/2$. Then

$$
\log 2 - h(p) \;=\; \left(\tfrac12-t\right)\log(1-2t) + \left(\tfrac12+t\right)\log(1+2t).
$$

Apply $\log u \le u-1$ to each logarithm: $\log(1-2t) \le -2t$ and
$\log(1+2t) \le 2t$. Since both weights are positive,

$$
\log 2 - h(p) \;\le\; \left(\tfrac12-t\right)(-2t) + \left(\tfrac12+t\right)(2t) = 4t^2 .
$$
</details>

---

## 7. The twist: quadratic flatness is also the rescue

Here is where the story turns. The obvious conclusion at this point — *the wall is
useless near balance, drop it* — is wrong, and it is wrong because the very same
quadratic law has a **lower** side.

> **Quadratic (Pinsker-type) inversion.** For $0 \le p \le q \le \tfrac12$,
> $$2(q-p)^2 \;\le\; h(q) - h(p).$$

> **Unconditional stability.** Hence if two splits in $[0,\tfrac12]$ have walls
> agreeing within $\varepsilon$, then
> $$|p - q| \;\le\; \sqrt{\varepsilon/2}.$$
> No guard. No hypotheses. Ever.

<details>
<summary><b>Proof sketch: a tangent-line comparison</b></summary>

Consider $\Phi(x) = h(x) + 2\left(\tfrac12-x\right)^2$ on $[0,\tfrac12]$. Its
derivative is $\log\frac{1-x}{x} - 4\left(\tfrac12-x\right)$, and this is
nonnegative because the auxiliary function
$\psi(z) = \log(1-z)-\log z + 4z - 2$ satisfies

$$
\psi'(z) = \frac{4z(1-z)-1}{z(1-z)} = \frac{-(1-2z)^2}{z(1-z)} \le 0,
\qquad \psi(\tfrac12) = 0,
$$

so $\psi \ge 0$ on $(0,\tfrac12]$. Thus $\Phi$ is nondecreasing, and
$\Phi(p) \le \Phi(q)$ rearranges to
$h(q)-h(p) \ge 2(q-p)(1-p-q) \ge 2(q-p)^2$, the last step because $2q \le 1$.
This is the binary-entropy shadow of
[Pinsker's inequality](https://en.wikipedia.org/wiki/Pinsker%27s_inequality).
</details>

**And the exponent is exactly right.** For every $\varepsilon \le \tfrac14$, the pair
$p = \tfrac12 - \tfrac{\sqrt\varepsilon}{2}$, $q = \tfrac12$ has walls within
$\varepsilon$ while the splits differ by $\tfrac{\sqrt\varepsilon}{2}$. So the
guaranteed $\sqrt{\varepsilon/2}$ is off from optimal by a factor of exactly
$\sqrt2$, and no bound $C\varepsilon^{\alpha}$ with $\alpha > \tfrac12$ can hold.

**The practical upshot reverses the original recommendation.** The wall's
resolution is $\Theta(\varepsilon)$ away from balance and $\Theta(\sqrt\varepsilon)$
at it — degraded, never absent. Publish the wall *with* its resolution.

---

## 8. Closing the loop: the complete two-sided law

Everything so far bounds the split by the wall gap. A replication protocol also
needs the converse: if two splits differ by at most $\delta$, how far apart can
their walls be? The answer is elegant and sharp — *the modulus of continuity of the
entropy is the entropy*:

$$
|h(p) - h(q)| \;\le\; h\bigl(|p-q|\bigr), \qquad p,q \in [0,\tfrac12],
$$

with equality at $q = 0$, so nothing smaller works. Combining the two directions:

$$
\boxed{\;2\,|p-q|^2 \;\le\; \bigl|h(p)-h(q)\bigr| \;\le\; h\bigl(|p-q|\bigr)\;}
$$

**with both sides sharp.** The wall map is a bi-Hölder homeomorphism of the splits
$[0,\tfrac12]$ onto the readings $[0,\log 2]$.

<details>
<summary><b>Proof sketch of the upper modulus</b></summary>

It follows from subadditivity, $h(q+d) \le h(q) + h(d)$: fix $d$ and note that
$x \mapsto h(x+d) - h(x)$ has derivative $h'(x+d) - h'(x) \le 0$, because $h'$ is
decreasing. So the shifted difference is largest at $x = 0$, where it equals
$h(d) - h(0) = h(d)$. Setting $d = q-p$ gives $h(q) - h(p) \le h(|p-q|)$, and the
left side is nonnegative since $h$ increases on $[0,\tfrac12]$.
</details>

You can audit both sides of the boxed law numerically, including locating the pairs
where each is nearly attained:

{{algorithm:2}}

---

## 9. What the number $0.4677$ actually claims

A wall of $0.4677$ bits is $0.4677\log 2 \approx 0.32418$ nats. Two convenient
rational splits have exact closed forms:

$$
h(\tfrac1{12}) = 2\log 2 + \log 3 - \tfrac{11}{12}\log 11 \approx 0.28684,
\qquad
h(\tfrac19) = 2\log 3 - \tfrac83\log 2 \approx 0.34883 .
$$

The reading falls strictly between them. By continuity a realising split exists in
$\left(\tfrac1{12},\tfrac19\right)$, and by strict monotonicity it is the only one
on the balanced side:

> **A wall of $0.4677$ bits asserts that the minority fraction is strictly between
> $8.34\%$ and $11.11\%$.**

The independently reported $9.96\%$ sits comfortably inside; $5\%$ and $15\%$ are
flatly excluded. A soft summary statistic has become a falsifiable prediction.

{{visualization:0}}

Better still, the theory hands you a replication tolerance. For splits below
$\tfrac19$ the guard is $\eta = \tfrac7{18}$ and the constant is exactly
$\log 8 = 3\log 2$ nats per unit of imbalance, so a replication whose wall agrees to
$0.01$ bits pins the split to

$$
\frac{0.01\log 2}{3\log 2} = \frac{1}{300},
$$

a third of a percentage point. That is a protocol, not an aspiration.

The inversion routine underneath all of this is a few lines long:

{{algorithm:0}}

---

## 10. Two laboratories, no shared data

None of the arguments care what the yes/no fact *is*. Given a finite population
$\Omega$ of size $N$ and any statistic $f$, the empirical entropy is

$$
H(f) \;=\; \sum_{a \in \operatorname{img} f} \frac{n_a}{N}\log\frac{N}{n_a},
$$

and when $f$ takes exactly two values this equals $h$ of the minority fraction.
Every theorem lifts verbatim to two binary statistics on two *entirely different*
populations. That is what makes the wall a genuine cross-population invariant: a
coordinate on the space of splits, with a known sharp modulus in each direction.

Watch it happen on simulated laboratories, with every certificate checked against
the hidden truth:

{{demo:1}}

<details>
<summary><b>One caveat: the wall cannot see which class is the majority</b></summary>

On the full interval $[0,1]$ the entropy is symmetric, and that is its *only*
coincidence:

$$
h(p) = h(q) \iff q = p \ \text{ or } \ q = 1-p .
$$

So a wall determines the split exactly up to the label swap, and nothing else is
lost. The convention "report the minority fraction" is precisely the missing bit,
made explicit. Quantitatively, with no balanced-side hypothesis at all,

$$
\min\bigl(|p-q|,\ |p+q-1|\bigr) \;\le\; \sqrt{\varepsilon/2} :
$$

either the splits nearly agree, or they nearly complement.
</details>

---

## 11. Which resolution should a report quote?

Finally, the decision a laboratory actually faces. For an error bar $\varepsilon$
and a prior cap $m$ on the split, compare the guarded linear resolution
$\varepsilon/\log\frac{1-m}{m}$ with the unconditional $\sqrt{\varepsilon/2}$ and
quote the smaller. The crossing point is visible at a glance:

{{visualization:2}}

---

## 12. The whole argument, verified end to end

Everything above — the counterexample, both sharp moduli, the optimality of the
exponent $\tfrac12$, the $0.4677$-bit bracket via exact closed forms, and every
population-level statement — is checked numerically here, with assertions on every
claim:

{{demo:0}}

---

## What to take away

1. An appealing conjecture was **false**, and diagnosably so: someone reached for
   the supremum of a derivative where the argument required the infimum. The
   counterexample collapses to $4 \le 3$.
2. The corrected statement needed a **guard**, and the guard encodes a real
   phenomenon — quadratic flatness at balance — that no constant can remove.
3. A degenerate *linear* rate is **not** the same as no information. The same
   quadratic law that kills linear inversion supplies square-root inversion,
   uniformly and unconditionally, with optimal exponent.

A single number, measured in bits, telling you a population's composition to a
third of a percentage point — provided you also say precisely how much it is
allowed to say.
