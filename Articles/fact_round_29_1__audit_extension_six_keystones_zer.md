# The Arithmetic of Reproducibility

## What a computational record can promise, and what it cannot

There is a particular kind of anxiety that haunts anyone who has ever run a large
computational experiment and written the numbers down. You press the button, the
machine churns, a table appears. Six months later somebody asks: *are you sure?*
You press the button again. Usually the numbers come back the same. Sometimes
they don't, and then a long and unhappy investigation begins.

The standard response to this anxiety is the **audit**: re-run the pipeline from
stored random seeds and compare the new table with the old one, digit by digit.
If they agree, you report "zero drift." It is an honest and useful practice. It
is also, on its own, a statement about *one more execution* — an empirical fact
about two runs, not a guarantee about all possible runs.

This article is about a different way of settling the question. Instead of
re-running a pipeline and comparing tables, we can ask: **which of the numbers in
the table are forced by the arithmetic of the pipeline itself?** A number that is
a theorem cannot drift. It does not need an audit; it needs a proof. And it turns
out that a surprisingly large fraction of the quantities that appear in these
audit tables — the "capacity curves," the "deficit columns," the "synergy
decompositions," the "ramp laws" — are theorems in disguise.

Once you take that view, something else becomes possible. The theorems don't just
certify the table; they also *constrain* it. A number that violates a theorem
cannot have come from the model it claims to describe. The proof becomes an
instrument for auditing the audit. At the end of this article we will use one to
find a reported number that, however faithfully it reproduces, cannot mean what
it is said to mean.

---

## The pipeline, stripped to its bones

Strip away the application and almost every seeded experimental pipeline has the
same skeleton: a state, a deterministic step, and a seed. The canonical example
is the **linear congruential map**

$$x \;\longmapsto\; (a x + c) \bmod m,$$

which takes an integer state $x$, scrambles it, and wraps it back into the window
$\{0, 1, \dots, m-1\}$. Fix a multiplier $a$, an increment $c$, a modulus $m$, and
a seed $s$, and the entire future of the pipeline is determined. Write $R_n(s)$
for the state after $n$ steps.

Everything below is about this object and its relatives, and everything below is
proved, not measured.

---

## Keystone one: why batching cannot matter

The most basic promise an audit makes is that the way you *schedule* a
computation does not change its answer. You ran it as one block of $1000$ steps;
I ran it as ten blocks of $100$, checkpointing in between. We should agree.

This is a theorem, and a short one. From the definition of iteration,

$$R_{p+q}(s) \;=\; R_q\bigl(R_p(s)\bigr)$$

for all $p, q, s$: running $p$ steps and then $q$ more is the same as running
$p+q$ steps. Induct on the list of batch sizes and you get the general statement.

> **Rebatching Invariance (Zero Drift).** Let $L = [n_1, n_2, \dots]$ be a schedule
> of batch sizes and let $E(L, s)$ be the state obtained by running the batches of
> $L$ in order from seed $s$. Then $E(L, s) = R_{\,n_1 + n_2 + \cdots}(s)$. In
> particular, if two schedules $L$ and $L'$ have the same total length, then
> $E(L, s) = E(L', s)$ for every seed $s$.

So the final state depends on the seed and the *total step count*, and on nothing
else. No amount of re-chunking can perturb it.

That is the easy direction, and it is the one everybody assumes. The interesting
question is the converse. **Is batch invariance evidence of anything?** If I hand
you a black box that executes schedules and you verify that it is insensitive to
rebatching, have you learned something about its internals?

You have, and the statement is exactly as clean as one could hope. Let $F(L, s)$
be any schedule-executing process on any state space at all: all we assume is
that the empty schedule does nothing, $F([\,], s) = s$, and that running the
schedule $n :: L$ means running the batch $n$ first and then the rest,
$F(n :: L, s) = F(L, F([n], s))$.

> **The Rebatching Characterisation.** Such a process $F$ is batch invariant — its
> output depends only on the total step count $\lVert L \rVert = n_1 + n_2 + \cdots$ —
> **if and only if** it is the iterate of its own unit step:
> $$F(L, s) \;=\; \underbrace{\phi \circ \phi \circ \cdots \circ \phi}_{\lVert L\rVert \text{ times}}(s), \qquad \phi := F([1], \cdot).$$

The proof of the hard direction is a single trick: if $F$ is batch invariant, then
$F(L, s)$ equals $F$ applied to the schedule $[1, 1, \dots, 1]$ of the same total
length, and that schedule visibly composes the unit step with itself.

The contrapositive is where the value lies. Suppose two schedules of equal total
length give different outcomes. Then no unit step whatsoever can explain the
process: the box is carrying **hidden state** — an accumulator, a cache, a counter,
a floating-point reduction order, an unseeded thread — something that the visible
step map does not see. Batch sensitivity is not a bug to be patched; it is a
*certificate*, and a complete one. Reproducibility engineering acquires a
theorem: chunk your run two different ways, and if the answers differ, you have
proved the existence of hidden state without needing to find it.

---

## Keystone two: the shape of a capacity curve

The second family of numbers in these audit tables tracks how much of the state
space a pipeline has explored. Let $S_k$ be the set of distinct states visited up
to and including time $k$, and define the **capacity**

$$I(k) \;=\; \log_2 |S_k| \quad \text{bits},$$

together with the **deficit**

$$d(k) \;=\; k - I(k),$$

which measures how far the run has fallen behind the ideal of one fresh bit per
step. A typical recorded deficit column runs $+0.000, +0.000, +0.085, \dots$ and
climbs steadily to something like $+6.372$ by step $17$, with the capacity
flattening out. Auditors report this profile as an empirical finding.

It is not empirical. Every feature of it is forced:

> **Capacity Saturation.** For any congruential pipeline on modulus $m$ with seed
> $s < m$: the capacity $I$ is nondecreasing; it never exceeds $\log_2 m$; and it
> gains at most one bit per step, $I(k+1) \le I(k) + 1$. Consequently the deficit
> satisfies $d(0) = 0$, is nondecreasing, and tends to $+\infty$.

The "at most one bit per step" clause is the crux and is charmingly simple: one
extra step can add at most one new state, so $|S_{k+1}| \le |S_k| + 1 \le 2|S_k|$,
and taking $\log_2$ turns that into $I(k+1) \le I(k) + 1$. Subtracting from $k+1$
flips it into monotonicity of the deficit. And since $I$ is capped at $\log_2 m$
while $k$ marches to infinity, $d(k) \ge k - \log_2 m \to \infty$.

So the recorded shape — starts at zero, never dips, eventually climbs with the
clock — is a theorem, not a measurement. No re-execution could ever produce a
different shape.

But an audit reports *numbers*, not shapes. Can we pin those down too?

---

## The exact orbit count: one integer runs the whole column

Here is where the story becomes genuinely pretty. Consider first the simplest
possible pipeline, the **rotation** $x \mapsto x + 1 \bmod m$ (that is, $a = c = 1$).
Its state after $n$ steps is exactly $(s + n) \bmod m$, and its visited set is a
sliding window of residues that grows by one each step until it has wrapped all
the way around. Therefore

$$|S_k| \;=\; \min(k+1,\, m),$$

and consequently, with no free parameters at all,

$$I(k) \;=\; \log_2 \min(k+1,\, m), \qquad d(k) \;=\; k - \log_2 \min(k+1,\, m).$$

The whole capacity column of a rotation pipeline is a function of the single
integer $m$. Two audits of the same pipeline cannot disagree in the third decimal
place, because there is nothing left for them to disagree about.

The rotation is also extremal. Since a pipeline can visit at most one new state
per step and at most $m$ states in total, every congruential pipeline on modulus
$m$ obeys

$$I(k) \;\le\; \log_2 \min(k+1, m), \qquad d(k) \;\ge\; k - \log_2\min(k+1,m),$$

and the rotation attains both with equality. It is the upper envelope of
capacity, the lower envelope of deficit — the best any pipeline on that modulus
can do.

So far so good for a specially chosen map. The surprise is that you do not need
the special choice. Drop every assumption: take an *arbitrary* deterministic step
map $f$ on the integers, seeded anywhere, subject only to the requirement that
its orbit never escapes some finite window of size $m$. No linearity, no
periodicity, no structure.

> **The Exact Orbit-Count Law.** There is a single integer $N$ with $1 \le N \le m$
> — the size of the orbit the pipeline eventually fills — such that for *every* time $k$,
> $$|S_k| \;=\; \min(k+1,\, N).$$

The proof is a small gem. The visited set $S_k$ can only grow, and each growth is
by exactly one state. If it ever fails to grow at some step, it can never grow
again: the state at the failed step was already seen, and a deterministic map
sends equal states to equal states, so the whole future is trapped in what has
already been recorded. Finiteness forces a first failure at some index $K$; before
$K$ the count is exactly $k+1$, after it the count is frozen at $K+1 =: N$. That
is precisely $\min(k+1, N)$.

Notice what this says. *Every deterministic finite-state pipeline in existence has
the same capacity curve shape, and that shape is determined by one integer.* There
is no variety to be had. The counts must go $1, 2, 3, \dots, N, N, N, \dots$, and
nothing else is possible. All the apparent richness of a recorded capacity column
is the richness of the logarithm function, not of the pipeline.

---

## Reading the orbit size off the table

The exact law has an immediate diagnostic consequence, and it is the kind of thing
a practitioner can actually use.

Take consecutive differences of the deficit column. Before the orbit is exhausted,

$$d(k+1) - d(k) \;=\; 1 - \log_2\frac{k+2}{k+1} \;<\; 1.$$

After it is exhausted, the capacity has stopped changing, so the deficit grows in
lockstep with the clock and the difference is *exactly* $1$. That gives a clean
biconditional:

> **The Deficit Slope Detector.** For a deterministic pipeline with orbit size $N$,
> $$d(k+1) - d(k) = 1 \quad\Longleftrightarrow\quad N \le k+1.$$

So the deficit column alone tells you the size of the orbit: find the first index
at which consecutive deficits differ by exactly one bit, and that index is the
orbit size. You never need to instrument the pipeline, store its states, or know
its modulus. A single column of published numbers is enough — and the same
reasoning tells you that any *reported* deficit column with a jump of exactly one
bit followed later by a jump of less than one bit is simply impossible, and
someone has made an error.

---

## Keystone three: the arithmetic of combining channels

The third family of audited numbers concerns what happens when two periodic
processes are observed together. Channel one cycles with period $p$; channel two
cycles with period $q$. Watch both, and the joint configuration $(i \bmod p,\, i
\bmod q)$ evolves with period $\operatorname{lcm}(p,q)$ — and, crucially, it visits
*exactly* $\operatorname{lcm}(p,q)$ distinct configurations before repeating. (This
is the Chinese remainder theorem doing its usual work: two residues agree
simultaneously exactly when their common multiple divides the difference.)

Measuring channel capacity in bits, $I(n) = \log_2 n$, and using the identity
$\gcd(p,q)\cdot\operatorname{lcm}(p,q) = pq$, we immediately get an
**inclusion–exclusion law for capacity**:

$$I(\operatorname{lcm}(p,q)) \;+\; I(\gcd(p,q)) \;=\; I(p) \;+\; I(q).$$

Joint capacity plus shared capacity equals the sum of the parts. The audit reports
two derived statistics. The **synergy**

$$S(p,q) \;=\; I(\operatorname{lcm}(p,q)) \;-\; \max\bigl(I(p), I(q)\bigr)$$

is how much the pair buys you over the better of the two alone; the **overlap**

$$\Omega(p,q) \;=\; \frac{I(\gcd(p,q))}{\min\bigl(I(p), I(q)\bigr)}$$

is the fraction of the weaker channel that is redundant.

Both have clean closed forms. Combining the inclusion–exclusion law with its
order-theoretic twin $\max(p,q)\cdot\min(p,q) = pq$ collapses the synergy to

$$\boxed{\,S(p,q) \;=\; \log_2 \frac{\min(p,q)}{\gcd(p,q)}\,}$$

and shows that $\Omega(p,q) = I(\gcd)/I(\min)$ with the elegant partition of unity

$$\Omega(p,q) \;+\; \frac{S(p,q)}{I(\min(p,q))} \;=\; 1.$$

From the closed form everything follows. Synergy is never negative. It is zero
exactly when one period divides the other — the *nested* case, where the finer
channel already contains the coarser. Overlap always lies in $[0,1]$.

---

## The one-bit gap, and the number that cannot be

Now look hard at that boxed formula. The quantity $\min(p,q)/\gcd(p,q)$ is an
integer, because the gcd divides both arguments. If the channels are not nested,
that integer is not $1$; being an integer greater than $1$, it is at least $2$.
Therefore:

> **Synergy Quantisation.** For genuinely periodic integer channels, the synergy is
> either exactly $0$ or at least $1$ full bit. No value strictly between is
> attainable. Moreover $S(p,q) = 1$ exactly when the weaker period is twice the
> shared period, $\min(p,q) = 2\gcd(p,q)$.

There is a forbidden zone. Synergy of $0.3$ bits, or $0.05$ bits, or $0.0049$
bits, is not a small effect — it is an *impossible* effect, for this model.

Which brings us to the audited table that started this investigation. It reports
two synergy measurements: one pair contributing $+0.1290$ bits, another
contributing $+0.0049$ bits. Both reproduce perfectly on re-execution. Both are,
in the reproducibility sense, beyond reproach: the pipelines are deterministic,
the seeds are stored, the digits come back identical.

And both are in the forbidden zone.

This is exactly the situation the theorems were built to detect, and it is worth
being careful about what it does and does not show. It does **not** show that the
measurements are wrong, that the code has a bug, or that the audit failed. It
shows something sharper and more useful: *whatever those numbers measure, it is
not the joint-versus-marginal capacity of two exactly periodic integer channels.*
Some assumption in the interpretation is doing work that the arithmetic does not
support — the channels may not be exactly periodic; the observation window may be
too short to fill the joint orbit; the quantity may be an average over
configurations rather than a single decomposition; the logarithms may be of
smoothed counts rather than exact orbit sizes. Any of those is a perfectly
respectable modelling choice. But the label "synergy of two periodic channels"
cannot be attached to $0.0049$ bits without contradiction.

Reproducibility and correctness are orthogonal. A deterministic pipeline
reproduces its own mistakes with perfect fidelity. The one-bit gap is the sort of
theorem that catches what an audit structurally cannot.

---

## Keystone four: when a ramp is exactly a ramp

The last audited law is the humblest and, satisfyingly, the one that survives
untouched. Enumerate the cells of an $r \times r$ grid in reading order, so cell
$(i, j)$ carries index $ir + j$, and take the first $q$ of them. Divide by the
total $r^2$ to get a success fraction $P_1(q, r)$. Empirically this behaves like a
clipped linear ramp in $q/r^2$; the audit records it as $P_1 \approx
\operatorname{ramp}(q/r^2)$, where $\operatorname{ramp}(x) = \max(0, \min(1, x))$.

The approximation sign is unnecessary. The map $(i,j) \mapsto ir + j$ is a
bijection from the grid onto $\{0, 1, \dots, r^2 - 1\}$ — this is just division
with remainder, run backwards — so the number of cells with index below $q$ is
exactly $\min(q, r^2)$. Dividing:

> **The Ramp Law is Exact.** For every $q \ge 0$ and every $r \ge 1$,
> $$P_1(q, r) \;=\; \operatorname{ramp}\!\left(\frac{q}{r^2}\right) \;=\; \max\left(0,\ \min\left(1,\ \frac{q}{r^2}\right)\right),$$
> with no error term.

The clipping is not an artefact of the fit; it is the two branches of
$\min(q, r^2)$. Below saturation the fraction is exactly linear; above it, exactly
one.

---

## What this adds up to

Six numbers came out of an audit. Four of them — the batch-invariant states, the
monotone deficit column, the nonnegative synergy with overlap in $[0,1]$, and the
clipped ramp — turn out to be theorems of the underlying arithmetic. They did not
need to be verified by re-execution, because they could not have come out any
other way. Re-running the pipeline to check them is like re-adding a column of
figures to check that the total is still an integer.

Two things emerged that no amount of re-execution would have found. First, the
capacity column of *any* deterministic finite-state pipeline is governed by a
single integer, the orbit size, which can be read directly off the published
deficit column by looking for the first unit jump. Second, the synergy of two
periodic integer channels lives on a quantised ladder with a full bit of empty
space above zero — and two of the audited synergy values sit in that empty space.

The moral is not that audits are useless. It is that they answer a narrower
question than they appear to. An audit asks *did this computation happen the same
way twice?* A proof asks *could it have happened any other way?* The second
question is the one that tells you what your numbers mean, and it is answered not
by pressing the button again but by doing the arithmetic.
