# The Number That Almost Tells You Everything

## What a single bit-count can, and cannot, reveal about a hidden split

Imagine a laboratory that runs the same diagnostic on populations all over the
world. Each run produces a battery of numbers, and one of them — call it the
**wall** — is a single quantity measured in bits. It is the answer to a very
simple question: *if I record, for each member of the population, one yes/no
fact, how many bits of information does that record carry, on average?*

A wall of $1$ bit means the yes/no fact splits the population exactly in half:
each answer is a genuine coin flip, maximally surprising. A wall of $0$ bits
means everybody answers the same way, and the record is worthless. Between
those extremes, the wall slides continuously.

One recent report gave a wall of $0.4677$ bits. That number, on its own, looks
like a summary — a soft, qualitative indicator. This article is about a
surprising fact: it is not a summary at all. It is a *falsifiable claim about a
specific number*. The wall value $0.4677$ bits says, with no wiggle room, that
the minority class in that population made up somewhere between $8.34\%$ and
$11.11\%$ of it. Not $5\%$. Not $15\%$. A replication that reports the same
wall and a $5\%$ split has contradicted itself.

Getting from "a soft indicator" to "a hard bracket" requires understanding
exactly how much a wall pins down — and the honest answer turned out to be more
subtle, and more interesting, than the obvious guess.

---

## The wall is the binary entropy of the split

Write $p$ for the fraction of the population in the minority class, so
$0 \le p \le \tfrac12$. Shannon's formula for the information content of a
two-outcome record is the **binary entropy**

$$
h(p) \;=\; p \log \frac{1}{p} \;+\; (1-p)\log\frac{1}{1-p},
$$

which we will measure in *nats* (natural logarithms); to convert to bits,
divide by $\log 2$. So $h(0) = 0$, $h(\tfrac12) = \log 2$ — one bit — and in
between $h$ climbs smoothly and strictly.

Two elementary facts set the stage.

**The wall is a sufficient statistic on the balanced side.** Because $h$ is
*strictly* increasing on $[0,\tfrac12]$, the wall value determines the split
$p$ uniquely, provided we agree to report the *minority* fraction. This is the
qualitative starting point: knowing the wall is knowing the split.

**Off the balanced side, exactly one bit is lost.** On the full interval
$[0,1]$ the binary entropy is symmetric, $h(p) = h(1-p)$, and this is the
*only* coincidence: for $p, q \in [0,1]$,

$$
h(p) = h(q) \iff q = p \ \text{ or } \ q = 1-p .
$$

So a wall value determines the split *up to a label swap*, and nothing else is
lost. The familiar convention "report the minority fraction" is not a technical
convenience; it is precisely the missing bit, made explicit. Two independent
populations whose binary records have identical wall values must have identical
class fractions, or complementary ones — there is no third possibility.

---

## The obvious guess, and why it fails

Uniqueness is a statement about exact equality of walls. Real replications never
match exactly. The question that matters is *quantitative*:

> If two independent populations report walls agreeing to within $\varepsilon$,
> how close must their splits be?

Here is the natural guess. Away from balance, $h$ has a healthy slope; its
derivative is

$$
h'(x) \;=\; \log\frac{1-x}{x},
$$

which on the interval $[\delta, \tfrac12]$ takes its largest value
$c(\delta) = \log\frac{1-\delta}{\delta}$ at the left endpoint. So — the guess
goes — the entropy gap should be at least $c(\delta)$ times the gap in splits:

$$
|h(p) - h(q)| \;\ge\; c(\delta)\,|p-q| \quad \text{for } p,q \in [\delta,\tfrac12],
$$

and hence $|p-q| \le |h(p)-h(q)| / c(\delta)$: a clean, explicit inversion
constant.

**This is false, and it fails for a structural reason.** Take
$\delta = q = \tfrac14$ and $p = \tfrac12$. Then $c(\tfrac14) = \log 3$,
$h(\tfrac12) = \log 2$, and $h(\tfrac14) = 2\log 2 - \tfrac34\log 3$. The claim
demands

$$
\tfrac14 \log 3 \;\le\; \tfrac34 \log 3 - \log 2,
$$

i.e. $2\log 2 \le \log 3$, i.e. $4 \le 3$. Numerically it asks for
$0.2747 \le 0.1308$.

The diagnosis is a sign error in the mathematics, not in the arithmetic:
$c(\delta)$ is the **supremum** of $|h'|$ on the interval, not the infimum. A
supremum of the derivative gives an upper bound on the slope of a chord — a
*Lipschitz* constant. It can never give a lower bound. And indeed the correct
statement, with the inequality pointing the other way, is true: for
$p, q \in [\delta, 1-\delta]$,

$$
|h(p) - h(q)| \;\le\; \log\frac{1-\delta}{\delta}\;|p-q|.
$$

The proposed inversion inequality was the true theorem read backwards.

---

## The right constant lives at the other endpoint

Once you see this, the fix is clear. The inversion constant must be the
derivative at the endpoint *closest to balance*, where $h$ is flattest. The
sharp mean-value statement is:

> **Endpoint slope bound.** For $0 \le p \le q \le \tfrac12$,
> $$(q-p)\log\frac{1-q}{q} \;\le\; h(q) - h(p).$$

The constant $\log\frac{1-q}{q}$ is the *smallest* value the derivative takes on
$[p,q]$, so this is the best linear lower bound available, and it is achieved in
the limit $p \to q$.

Feeding this into the replication question gives the corrected
cross-population theorem. Fix a **guard** $\eta > 0$ and suppose both splits lie
in $[0, \tfrac12 - \eta]$ — that is, both populations are known to be at least
$\eta$ away from balance. Then

$$
\Big(\log\tfrac{1/2+\eta}{1/2-\eta}\Big)\,|p-q| \;\le\; |h(p)-h(q)|,
\qquad\text{so}\qquad
|p-q| \;\le\; \frac{\varepsilon}{\log\frac{1/2+\eta}{1/2-\eta}}
$$

whenever the walls agree within $\varepsilon$. Same shape as the guess; the
constant is evaluated at the guard point rather than at the far end.

And the guard cannot be removed. As $\eta \to 0$ the constant
$\log\frac{1/2+\eta}{1/2-\eta} \approx 4\eta$ goes to zero, and it must: near
balance the entropy is *flat to second order*. Precisely, writing
$p = \tfrac12 - t$,

$$
2t^2 \;\le\; \log 2 - h\!\left(\tfrac12 - t\right) \;\le\; 4t^2 .
$$

Because the deficit vanishes quadratically, no constant $C$ whatsoever can
satisfy $|p - q| \le C\,|h(p)-h(q)|$ near $\tfrac12$: for *any* $C$ and any
window around balance, however small, one can find two splits inside it whose
walls are closer than $C$ times their separation. Linear inversion of the wall
at balance is impossible, full stop.

---

## The moment of doubt — and the square root that rescues it

At this point the natural conclusion is bleak, and it was the conclusion the
original brief drew: near a balanced split, the wall carries almost no
information about the split, so it should be dropped from the report.

That conclusion is **wrong**, and the reason is one of the most useful
inequalities in information theory. The quadratic flatness cuts both ways. The
entropy deficit is *at most* $4t^2$ — but it is also *at least* $2t^2$. Turning
that into a statement about two arbitrary splits gives a Pinsker-type bound:

> **Quadratic inversion.** For $0 \le p \le q \le \tfrac12$,
> $$2(q-p)^2 \;\le\; h(q) - h(p).$$

It is proved by showing that the function $x \mapsto h(x) + 2\left(\tfrac12 -
x\right)^2$ is increasing on $[0,\tfrac12]$, which reduces to the pointwise
tangent-line comparison $\log\frac{1-x}{x} \ge 4\left(\tfrac12 - x\right)$ — the
statement that binary entropy is $2$-strongly concave at balance.

The consequence is immediate and unconditional:

> **Cross-population stability.** If two populations have minority fractions
> $p, q \in [0,\tfrac12]$ and their walls agree to within $\varepsilon$, then
> $$|p - q| \;\le\; \sqrt{\varepsilon/2}.$$

No guard. No hypothesis beyond being on the balanced side. The wall is
*always* invertible; only the *rate* changes. Away from balance the resolution
is linear in the measurement error, $\Theta(\varepsilon)$; at balance it
degrades to $\Theta(\sqrt{\varepsilon})$ — worse, but very far from useless. A
wall measured to $0.01$ nats pins even a perfectly balanced split to within
$\sqrt{0.005} \approx 0.07$.

And the square root is genuinely the truth, not an artefact of a lossy proof.
For every $0 < \varepsilon \le \tfrac14$, the pair
$p = \tfrac12 - \tfrac{\sqrt\varepsilon}{2}$ and $q = \tfrac12$ has walls
agreeing within $\varepsilon$ while the splits differ by
$\tfrac{\sqrt\varepsilon}{2}$. So no bound $|p-q| \le C\varepsilon^{\alpha}$
with $\alpha > \tfrac12$ can hold, and the constant in the stability theorem is
off from optimal by only a factor of $\sqrt2$.

Dropping the wall from the report would have thrown away a coordinate that is
provably informative at every split. The correct action is the opposite:
**publish the wall together with the resolution its error bar implies.**

Dropping the balanced-side assumption too, the fully general version reads:
for any $p, q \in [0,1]$ with walls agreeing within $\varepsilon$,

$$
\min\big(|p-q|,\ |p+q-1|\big) \;\le\; \sqrt{\varepsilon/2}.
$$

Either the splits nearly agree, or they nearly complement — the label-swap
ambiguity, now in quantitative form.

---

## Closing the loop: how much can the wall move?

Stability theorems bound the split by the wall gap. For a replication protocol
you also need the converse: if two labs are looking at populations whose splits
differ by at most $\delta$, how far apart may their walls be? The answer is
elegant, and sharp:

$$
|h(p) - h(q)| \;\le\; h\big(|p - q|\big)
\qquad \text{for } p,q \in [0,\tfrac12].
$$

The modulus of continuity of the entropy *is the entropy*. It follows from the
subadditivity $h(q+d) \le h(q) + h(d)$, itself a consequence of the fact that
the shifted difference $x \mapsto h(x+d) - h(x)$ decreases as $x$ moves toward
balance. And it is attained exactly, at $q = 0$: there
$|h(p) - h(0)| = h(|p - 0|)$. No smaller function of $|p-q|$ can serve.

Put the two directions together and you get the complete law governing the
wall on the balanced side:

$$
2\,|p-q|^2 \;\le\; \big|h(p)-h(q)\big| \;\le\; h\big(|p-q|\big),
$$

**with both sides sharp.** The wall map is a bi-Hölder homeomorphism from the
interval of splits $[0,\tfrac12]$ onto the interval of readings $[0,\log 2]$:
squared on one side, $t\log(1/t)$ on the other. Splits and walls determine each
other quantitatively, in both directions, with no gaps in the theory.

---

## What $0.4677$ bits actually claims

Return to the reported number. In nats, a wall of $0.4677$ bits is
$0.4677\log 2 \approx 0.32418$ nats. Evaluate the entropy at two convenient
rational splits:

$$
h(\tfrac1{12}) = 2\log 2 + \log 3 - \tfrac{11}{12}\log 11 \approx 0.28684
\;<\; 0.32418 \;<\;
h(\tfrac19) = 2\log 3 - \tfrac83 \log 2 \approx 0.34883 .
$$

By continuity there is a split in $\left(\tfrac1{12}, \tfrac19\right)$ realising
the reported wall, and by strict monotonicity it is the *only* one in
$[0,\tfrac12]$. So:

> **The reported wall of $0.4677$ bits asserts that the minority fraction lies
> strictly between $8.34\%$ and $11.11\%$.**

The independently reported figure of $9.96\%$ sits comfortably inside; a $5\%$
or $15\%$ split is flatly excluded. This is the whole point: the wall was
promoted from a mood-indicator to a testable prediction.

Better still, the theory supplies the replication tolerance. For splits below
$\tfrac19$, the guarded linear bound applies with guard $\eta = \tfrac7{18}$,
and the constant is exactly
$\log\frac{1/2 + 7/18}{1/2 - 7/18} = \log 8 = 3\log 2$ nats per unit of
imbalance. Hence a replication whose wall agrees to $0.01$ bits pins the split
to within

$$
\frac{0.01 \log 2}{3 \log 2} = \frac{1}{300},
$$

a third of a percentage point. That is a protocol: measure the wall to a
hundredth of a bit, and you have measured the split to $\pm 0.33\%$.

---

## Why this generalises beyond one laboratory

The argument nowhere mentions what the yes/no fact *is*. Formally, one starts
with a finite population $\Omega$ and any function $f$ from $\Omega$ to a set of
readings, defines the empirical entropy

$$
H(f) \;=\; \sum_{a \in \operatorname{img} f}
\frac{n_a}{N}\,\log\frac{N}{n_a},
$$

where $N = |\Omega|$ and $n_a$ counts the members with reading $a$, and observes
that when $f$ takes exactly two values $a \ne b$, this collapses to
$H(f) = h(n_a/N)$. Every theorem above then lifts verbatim to a statement about
*two binary statistics on two entirely different populations*: if their
empirical entropies agree within $\varepsilon$ and both minority fractions are
on the balanced side, the fractions agree within $\sqrt{\varepsilon/2}$;
if additionally both are guarded from balance by $\eta$, they agree within
$\varepsilon / \log\frac{1/2+\eta}{1/2-\eta}$; and conversely, splits differing
by at most $\delta$ force entropies differing by at most $h(\delta)$.

That is what makes the wall a genuine **cross-population invariant**. It is not
a property of one dataset, one instrument, or one lab. It is a coordinate on the
space of binary splits, with a known, two-sided, sharp modulus of continuity in
each direction.

---

## The lesson

Three things happened here that are worth separating.

First, an appealing conjecture was *false*, and its falsity was diagnosable:
someone had reached for the supremum of a derivative when the argument required
the infimum. The counterexample is a single exact computation collapsing to
$4 \le 3$.

Second, the corrected version came with a *guard*, and the guard was not a
technical blemish — it encoded a real phenomenon, the quadratic flatness of
entropy at balance, and no constant can remove it.

Third — and this is the part that reverses the practical recommendation — a
degenerate *linear* rate is not the same as no information. The quadratic
flatness that kills linear inversion is exactly what supplies the square-root
inversion, uniformly and unconditionally. The instinct to discard the wall was
formed by looking at only one of the two inequalities that the same quadratic
law provides.

A single number, measured in bits, telling you a population's composition to a
third of a percentage point — provided you know precisely how much it is
allowed to say.
