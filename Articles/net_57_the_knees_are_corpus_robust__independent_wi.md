# Thirty Keys Are Enough: The Hidden Algebra of Attention Budgets

## A number that refused to move

Here is a small experimental fact that turns out to have a large mathematical shadow behind it.

Take a modern language model — the kind that reads a stretch of text and predicts what comes next. Internally, every time it processes a token, it looks back over everything it has read so far and distributes a fixed amount of *attention* across those earlier positions. Some positions get a lot; most get almost nothing. If you sort the attention weights from largest to smallest and start adding them up, you get a curve that climbs steeply and then flattens: a handful of positions carry nearly all the mass.

The natural question is: *how many is a handful?* Fix a threshold — say you want to retain $98\%$ of the total attention mass. Sort the weights, walk down the list, and record the first budget $k$ at which the top $k$ weights already account for $98\%$ of the total. Call that number the **knee**, written $k^\*$.

Measured on one corpus of English text with a $512$-token window, the knee came out at $16$. At a $1024$-token window, it came out at $32$. Then the same measurement was repeated on a completely independent body of text — a disjoint shard, never seen by the first experiment. The knee came out at $16$. And at $32$. Not approximately. Exactly. The control curves — random-key baselines that should carry no signal at all — matched the first run to four decimal places: $0.1775$ and $0.3004$, on the nose.

So the knee is not a property of the *text*. It is a property of the trained attention itself. Across three context lengths, two corpora, and two model sizes, the budget stays pinned near thirty keys.

That is an empirical statement. This article is about the mathematics underneath it: *why* a quantity like the knee is the sort of thing that can replicate exactly, when almost every other statistic of a corpus would only replicate approximately.

## The trick: keep the gate linear

The first move is to stop thinking about attention curves and start thinking about a cone.

Model a corpus as an **attention profile**: a sequence $w = (w_0, w_1, w_2, \dots)$ of nonnegative numbers, where $w_i$ is the attention mass carried by the $i$-th most important key, already sorted. Write

$$M_w(k) \;=\; \sum_{i<k} w_i$$

for the **head mass** — the total attention captured by the top $k$ keys. The retained fraction at budget $k$, in a context of length $n$, is $M_w(k)/M_w(n)$, and the experiment's gate condition is

$$\tau \;\le\; \frac{M_w(k)}{M_w(n)}.$$

Now here is the move that makes everything work. Do **not** write the gate as a statement about the ratio. Clear the denominator:

$$\boxed{\;\tau \, M_w(n) \;\le\; M_w(k).\;}$$

These two say exactly the same thing whenever the context carries any mass at all. But the second one is *linear in $w$*. It says that the profile $w$ lies on one side of a hyperplane in the space of all profiles. And the knee is then simply

$$k^\*(w, n, \tau) \;=\; \min\{\,k : \tau M_w(n) \le M_w(k)\,\},$$

the smallest budget whose half-space contains $w$.

Everything that follows is a consequence of that one reformulation. Ratios are awkward objects; half-spaces are not.

## Corpora add up, and so do their failures

Profiles can be added: pool two corpora and you add their attention profiles key by key. They can be scaled by positive numbers: measure the same corpus in different units and you multiply the profile by a constant. Nonnegative profiles closed under addition and positive scaling — that is a **cone**.

Fix a context $n$, a gate $\tau$, and a budget $K$. The profiles that clear the gate at $K$ form a sub-cone: if $A$ clears and $B$ clears, then $A+B$ clears, and $cA$ clears for every $c \ge 0$. That is one line of arithmetic — add two inequalities.

The genuinely useful observation is the *other* side. If $A$ **fails** at $K$ and $B$ **fails** at $K$, then $A+B$ fails at $K$ too. Add two strict inequalities pointing the other way. Both the passing set and the failing set are closed under pooling.

This two-sided linearity is the structural reason a knee can be corpus-robust. It gives immediately:

> **Pooling Sandwich.** For any two corpora $A$ and $B$ at the same context and gate,
> $$\min\big(k^\*(A),\, k^\*(B)\big) \;\le\; k^\*(A+B) \;\le\; \max\big(k^\*(A),\, k^\*(B)\big).$$

The upper bound comes from the passing side, the lower bound from the failing side. Pool two corpora and the knee cannot escape the interval spanned by the two ingredient knees.

And on the diagonal, the sandwich closes:

> **Exact Corpus Robustness.** If $k^\*(A) = k^\*(B)$, then $k^\*(A+B) = k^\*(A)$.

Two corpora with the same knee generate an entire cone of corpora with that same knee. It is not that the pooled knee is *close* to the common value; it *is* the common value. Add the scale invariance $k^\*(cA) = k^\*(A)$ for $c>0$, and one gets the whole family: any strictly positive mixture $aA + bB$ of equal-knee corpora has that knee, whatever the mixing weights.

Readers with an algebraic bent will recognise the shape of

$$k^\*(A+B) \le \max\big(k^\*(A), k^\*(B)\big), \qquad k^\*(cA) = k^\*(A),$$

as the axioms of a **non-archimedean valuation** — the same ultrametric shape as the $p$-adic order of an integer, or the degree of the pole of a rational function. The knee is not a linear functional on the corpus cone; it is a valuation. Its sublevel sets, the budget cones, form an increasing filtration of the cone indexed by the budget.

## What is *not* true (and why that matters)

It is tempting to try to state corpus robustness as additivity: $k^\*(A+B) = k^\*(A)$. That is false, and the counterexample is embarrassingly small.

Take a context of length $2$. Let $A$ be all mass on the first key, $B$ all mass on the second. Then $k^\*(A) = 1$ and $k^\*(B) = 2$, at any gate in $(0,1]$. Pool them: the pooled profile is $(1,1)$, uniform. At gate $\tfrac12$ the top key already carries half the mass, so $k^\*(A+B) = 1$ — the **minimum**. At gate $\tfrac34$ the top key carries only half, so you need both: $k^\*(A+B) = 2$ — the **maximum**.

The same pair of corpora hits the bottom of the sandwich at one gate and the top at another, with the ingredient knees unchanged. So both bounds are sharp, the knee is not additive, and — a subtler point — the pooled knee is not even a function of the ingredient knees alone. Corpus robustness has to be stated as the sandwich plus its diagonal equality case. Nothing cleaner is available, and now we know why.

## The four-decimal theorem

Now to the sharpest question the experiment raises. The two corpora did not have *identical* retention curves. They had curves agreeing to about $10^{-4}$. Yet the knees agreed *exactly*, as integers. How does approximate agreement in a continuous quantity force exact agreement in a discrete one?

The answer is a margin argument, and it is worth stating precisely because it is the logical content of the whole replication.

> **Four-Decimal Theorem.** Let $A$ and $B$ be corpora on a context of length $n$, both carrying positive mass, and let $\tau \le 1$ be a gate. Suppose
> 1. *(agreement)* the retention curves agree to within $\varepsilon$ at every budget $k \le n$:
> $$\left|\frac{M_A(k)}{M_A(n)} - \frac{M_B(k)}{M_B(n)}\right| \le \varepsilon;$$
> 2. *(margin)* the reference corpus stays strictly further than $\varepsilon$ from the gate at every such budget:
> $$\left|\frac{M_A(k)}{M_A(n)} - \tau\right| > \varepsilon.$$
>
> Then $k^\*(A) = k^\*(B)$ exactly.

The proof is a single observation. At each budget on the grid, corpus $A$'s retention is either above the gate by more than $\varepsilon$, or below it by more than $\varepsilon$. A perturbation of size at most $\varepsilon$ cannot carry it across. So $A$ and $B$ pass and fail at *precisely the same budgets* — the two gate predicates are literally the same predicate — and their minima therefore coincide.

Put the measured numbers in. At context $512$, gate $0.98$: the sweep records retention $0.9318$ at $k=8$ and $0.9759$ at $k=12$, both failing, and a pass at $k=16$. The distances from the gate are $0.048$ and $0.0041$ — the smallest margin is forty times the $10^{-4}$ agreement tolerance. The theorem applies, and the second corpus's knee is forced to be the first's: $12 < k^\*_B \le 16$, matching the reported $k^\* = 16$. The exactness of the replication is not luck. It is a consequence of the discreteness of the knee together with a measured margin.

And the margin hypothesis cannot be dropped. Consider the uniform corpus on a context of length $2$ at gate $\tfrac12$: its retention at $k=1$ sits *exactly* on the gate, at $0.5000\ldots$, with margin zero. Now tilt it slightly, replacing the first weight $1$ by $1-\delta$. The retention at $k=1$ becomes $(1-\delta)/(2-\delta)$, which is below $\tfrac12$ for every $\delta > 0$, so the knee jumps from $1$ to $2$. As $\delta \to 0$ the two retention curves become arbitrarily close, yet the knees never agree. **At zero margin, no tolerance whatsoever suffices** — the failure is scale-free. A replication claim genuinely needs its measured margin, and, by the theorem, needs nothing more.

## Reading a corpus off its budget table

Deployment engineers do not publish retention curves; they publish tables: "at gate $0.95$ you need $12$ keys, at $0.98$ you need $16$, at $0.99$ you need $24$." How much of the corpus does such a table actually determine?

Raising the gate can only raise the budget, so the sweep $\tau \mapsto k^\*(\tau)$ is a non-decreasing step function. Fix a budget $k$ and ask which gates it can serve. The answer is exactly the gates at or below the retained mass at $k$:

$$\{\tau \le 1 : k^\*(\tau) \le k\} \;=\; \big(-\infty,\; M_w(k)/M_w(n)\big].$$

Taking the supremum recovers the retention value itself. So the retention curve is the **upper envelope of the gate sweep**: the table determines the curve, point by point.

The consequence is a clean identifiability statement. If two corpora have the same knee at *every* gate $\tau \le 1$, their retention curves are identical on the whole budget grid. The gate sweep is a complete invariant of the measurable content of a corpus. A cross-corpus replication of the knee at every gate is therefore not merely suggestive of curve agreement — it is equivalent to it.

There is a caveat worth recording, because it constrains what a finite experiment can claim. Identifiability needs the *whole* gate axis. On a finite grid of gates two corpora can share every measured knee and still differ in retention strictly between the measured steps. The theorem quantifies over all gates, which is exactly the strength a sweep-based deployment claim may assume, and no more.

## Domain jumps: the right notion of distance

Both corpora in the experiment came from the same family of encyclopedic English text. The obvious next question — will the budget table survive a jump to source code, to mathematics, to another language? — is about corpora that are *not* numerically close.

For a scale-invariant functional, the right notion of distance is not additive but **projective**. Say $B$ is a **$\rho$-tilt** of $A$ if every key's weight is distorted by at most a factor $\rho$ in either direction:

$$B_i \le \rho A_i \quad\text{and}\quad A_i \le \rho B_i \qquad \text{for all } i.$$

This is a ball in the Hilbert projective metric on the corpus cone. A $\rho$-tilt of radius $1$ forces $A = B$; larger $\rho$ allows genuinely different domains.

The key exchange rate is this: **a $\rho$-tilt costs a factor $\rho^2$ in the gate, and nothing in the budget.** If $A$ clears gate $\rho^2\tau$ at budget $k$, then $B$ clears gate $\tau$ at the *same* budget $k$. One factor of $\rho$ inflates the numerator, one deflates the denominator. Running the argument in both directions gives the **gate-window law**:

$$k^\*_A(\tau/\rho^2) \;\le\; k^\*_B(\tau) \;\le\; k^\*_A(\rho^2\tau).$$

A domain jump can move the knee no further than the reference corpus's own sweep moves across a gate window of multiplicative width $\rho^2$. That converts an *unmeasured* domain into a *measured* interval of gates — and gives an immediately usable deployment criterion: **if the measured sweep is flat across that window, every $\rho$-tilted corpus has exactly the reference knee.** Flatness of your own table, on your own corpus, licenses the transfer.

There is a subtlety here, and it is instructive. Stated in the retained coordinate, inflating the gate by $\rho^2$ is useless at a gate of $0.98$: you would need $\rho^2 \le 1/0.98$, i.e. $\rho \lesssim 1.01$, which excludes every interesting domain jump. The repair is to change coordinates. Work with the **missing mass** $\delta = 1 - \tau$ instead:

> **Sharp Domain-Jump Law.** If the reference corpus leaves at most a fraction $\delta$ of its mass outside budget $k$, then any $\rho$-tilt of it leaves at most $\rho^2\delta$ outside the same budget.

Now the arithmetic is friendly. At gate $0.98$ we have $\delta = 0.02$; a $\rho = 1.1$ domain distortion inflates it to $0.0242$, i.e. an effective gate of $0.9758$ — comfortably inside the measured sweep. The complementary coordinate is the one in which a tilt acts boundedly at deployment gates.

Finally, an explicit number. Suppose the reference corpus has a **geometric retention tail**: at budget $k$ it retains at least $1 - r^k$. Then any $\rho$-tilted corpus at gate $\tau$ is served by any budget $K$ with $r^K \le 1 - \rho^2\tau$ — that is,

$$K \;=\; O\!\left(\frac{\log\big(1/(1-\rho^2\tau)\big)}{\log(1/r)}\right).$$

The price of a domain jump is *logarithmic* in the distortion. No re-measurement on the new domain is required. That is the shape of a deployment guarantee.

## The fan

One last structure, which ties the picture together. Fix a context and a gate and sort every corpus by its knee. What do the level sets look like?

For a positive label $K$, the corpus $w$ has knee exactly $K$ if and only if it **passes at $K$ and fails at $K-1$**. Two linear conditions: one closed half-space, one open half-space. So each level set — call it the **knee cell** of label $K$ — is a polyhedral cell in the corpus cone, convex and closed under positive scaling and pooling.

The cells are pairwise disjoint and cover the cone: the knee is the label of a **fan** on the space of corpora, not merely a number attached to each corpus. And no cell is empty: for every label $K$ with $1 \le K \le n$, the corpus placing all its mass on key $K-1$ has knee exactly $K$. (The one-hot corpus makes the intuition literal: a knee of $K$ means "the $K$-th key is the last one that matters.")

This gives the strongest available form of the replication result. *Corpus robustness is membership in a cell*, and a cell is certified by exactly the two grid measurements a bracket already reports — a failure just below and a pass at the budget. It also bounds what replication can prove: since every cell is non-empty, no argument from attention geometry alone can force a particular knee. The measurement is doing real work.

## What the algebra buys

The experimental headline was that a number replicated. The mathematics explains which properties of that number made replication possible, and turns each of them into a statement one can act on.

Because the gate is a *half-space*, corpora pool without moving the knee, and the knee behaves like a valuation. Because the knee is a *discrete* minimum guarded by a *measured margin*, four-decimal agreement forces exact agreement — and, at zero margin, nothing forces it at all. Because the gate sweep is the *upper envelope* of the retention curve, a published budget table determines the corpus's measurable content. Because domain jumps are *projective* perturbations acting boundedly on missing mass, an unmeasured domain costs only a logarithmic number of extra keys. And because the level sets are *non-empty polyhedral cells*, the two numbers a bracket reports are precisely a certificate of membership.

Thirty keys, it turns out, is a statement about the geometry of a cone.
