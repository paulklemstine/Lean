# When Code Meets Prose: The Hidden Arithmetic of Mixed Attention

## A number that refused to behave

Here is a small experiment you can imagine running on any modern language model.

Take a long stretch of text and ask: *how many of the model's attention weights actually
matter?* At each position the model spreads a unit of "attention" across all the earlier
tokens in its context. Sort those weights from largest to smallest and start adding them
up. How many of the top weights do you need before you have captured, say, $99\%$ of the
total? Call that number the **knee**, written $k^*$. It is the working memory of the
model, measured in keys rather than tokens: everything beyond the knee is, to a very good
approximation, noise.

Run the experiment on pure Python source code and on pure English prose, at two context
lengths, and you get a small table:

| context | Python code | English prose | interleaved code + prose |
|---|---|---|---|
| $512$ | $12$ | $16$ | $12$ |
| $1024$ | $16$ | $20$ | $20$ |

Read the last column twice. At a context of $512$ the mixed stream behaves exactly like
code — the *easier* of the two domains, the one with the smaller knee. Then you double
the context and the mixed knee jumps by $8$, while each pure domain rises by only $4$.
The mixture starts low and rises at double the rate.

This is odd. The naive guess is that a fifty-fifty blend of two things should behave like
the average of the two things. Here it starts at the bottom of the range and then
overtakes. Something about mixing is not an average at all.

This article is about what that something is. The answer turns out to be almost entirely
arithmetic — a small theory of how "how many keys do I need?" behaves under blending —
and it produces both an explanation of the observed numbers and a list of sharp
predictions that the next experiment can falsify.

## The two ways to blend

Write $w_0 \ge w_1 \ge w_2 \ge \dots$ for a sorted attention profile: $w_i$ is the
$i$-th largest weight. Define the **head mass** $H_w(k) = w_0 + \dots + w_{k-1}$ and the
**retained fraction** at budget $k$ inside a context of length $n$,
$$R_w(n,k) \;=\; \frac{H_w(\min(k,n))}{H_w(n)}.$$
The knee at gate $\tau$ is the smallest budget that clears the gate,
$$k^*_w(n,\tau) \;=\; \min\{\,k : R_w(n,k) \ge \tau\,\}.$$

Now there are two genuinely different ways to combine two domains $u$ (code) and $v$
(prose) into one context, and keeping them apart is the whole trick.

**Pooling.** Both domains contribute to the same context, with mixing weights $a$ and
$b$: the profile is $a u_i + b v_i$. The context is as long as either component; the
weights are added.

**Interleaving.** The context alternates: key $0$ from code, key $1$ from prose, key $2$
from code, and so on (in the actual protocol, in blocks of about five hundred characters
rather than single keys). The context is *twice* as long, and each key belongs to exactly
one domain.

The experiment interleaves. But the mathematics of interleaving turns out to be the
mathematics of pooling, viewed through a magnifying glass.

## The mediant sandwich

Start with pooling, where the picture is clean. The retained fraction of a pooled context
is
$$R_{\text{pool}}(n,k) \;=\; \frac{a H_u(k) + b H_v(k)}{a H_u(n) + b H_v(n)},$$
a *mediant* of the two component fractions: a fraction whose numerator and denominator
are each the sum of the corresponding pieces. A mediant always lies between the fractions
it is built from. So for every budget $k$ and every mixing ratio,
$$\min\bigl(R_u(n,k),R_v(n,k)\bigr) \;\le\; R_{\text{pool}}(n,k) \;\le\; \max\bigl(R_u(n,k),R_v(n,k)\bigr),$$
and consequently the pooled knee is caged between the component knees:
$$\min(k^*_u,k^*_v) \;\le\; k^*_{\text{pool}} \;\le\; \max(k^*_u,k^*_v).$$
This is the **Mediant Sandwich Theorem**, and it is the only universally valid constraint
of its kind. That last clause deserves emphasis, because it kills the naive prediction
outright.

## Three witnesses, and the death of the midpoint

Could the mixed knee be the *midpoint* of the component knees? No — and the failure is
not a near miss.

Consider a context of four keys, gate $\tau = 0.7$, and a flat prose-like domain
$v = (1,1,1,1)$, whose knee is $3$. Pair it in turn with three code-like domains, each
with a single dominant head key, each with knee $1$:

- $u_A = (10,1,1,1)$ — the balanced pool has knee $2$;
- $u_B = (100,1,1,1)$ — the balanced pool has knee $1$;
- $u_C = (0.1, 0.001, 0.001, 0.001)$ — the balanced pool has knee $3$.

All three pairs have the *same* component knees, $1$ and $3$. Their fifty-fifty mixtures
have knees $2$, $1$ and $3$: the midpoint, the minimum and the maximum of the sandwich.
Every point of the cage is attained. Therefore **no function whatsoever of the two
component knees computes the mixed knee.** The midpoint prediction is not merely wrong;
the question it answers is ill-posed.

What separates the three witnesses is not their knees but their *masses*. In $u_B$ the
code domain carries almost all the attention mass, so the mixture inherits its knee. In
$u_C$ the code domain is a whisper, so prose takes over. This observation is the key to
everything that follows, and it can be made exact: writing
$$\lambda \;=\; \frac{a H_u(n)}{a H_u(n) + b H_v(n)}$$
for the **mass share** of the first domain, the pooled curve is an exact convex
combination,
$$R_{\text{pool}}(n,k) \;=\; \lambda\, R_u(n,k) \;+\; (1-\lambda)\, R_v(n,k).$$
The sandwich is just the statement that a weighted average lies between its endpoints.
The convex identity says considerably more, as we will see.

## Why the mixture rises twice as fast

Now interleaving. Here is the observation that explains the headline number, and it is
almost embarrassingly simple.

Take an interleaved context of length $2n$ and look at an *even* prefix of length $2k$.
Because the domains alternate, that prefix contains exactly the first $k$ keys of code
*and* the first $k$ keys of prose. So its head mass is $H_u(k) + H_v(k)$, and
$$R_{\text{mix}}(2n, 2k) \;=\; R_{\text{pool}}(n,k) \qquad (a=b=1).$$
**Interleaving is pooling, read in doubled key units.** A mixed context of length $2n$
is a pooled context of length $n$ whose keys have each been split in two.

Everything follows. If $Q$ is the pooled knee at context $n$, then the interleaved knee at
context $2n$ satisfies
$$2Q - 1 \;\le\; k^*_{\text{mix}}(2n,\tau) \;\le\; 2Q,$$
the one-key ambiguity coming from the fact that an odd budget might already suffice.
Subtract two such statements at contexts $n$ and $2n$ and you get the **Doubling Law**:
writing $\Delta(\tau,n) = k^*(2n,\tau) - k^*(n,\tau)$ for the context-doubling increment,
$$\bigl|\Delta_{\text{mix}} - 2\Delta_{\text{pool}}\bigr| \le 1 .$$
The mixed increment is twice the pooled increment, up to a single key. If each pure domain
moves by $+4$ when the context doubles, the interleaved stream must move by roughly $+8$.
That is precisely what was measured.

And it is not really a statement about *domains* at all. The same theorem applies when you
interleave a domain with a rescaled copy of itself — no cross-domain interaction
whatsoever — and still predicts a doubled increment. The "+8 versus +4" is a fact about
the *protocol*, not about the interaction of Python with English.

This gets sharper. Interleave $m$ domains in a round robin and the increment multiplier is
exactly $m$: $|\Delta_{\text{rr}} - m\Delta_{\text{pool}}| \le m-1$. And if the interleaving
is *unbalanced* — $s$ keys of one domain for every key of the other — the multiplier is
neither $2$ nor $m$ but the period $s+1$, the reciprocal of the rarest domain's rate. A
ninety-ten code/prose blend should show a *tenfold* increment, not a twofold one. That is
the sharpest available test of this whole picture.

## Why the mixture starts at code's level

The other half of the verdict — "starts low" — is the convex identity doing its work.

Since $R_{\text{pool}} = \lambda R_u + (1-\lambda) R_v$, the pooled curve is the dominant
component's curve read at a *shifted gate*. Clearing gate $\tau$ in the mixture is
sandwiched between clearing $\tau/\lambda$ and $(\tau - (1-\lambda))/\lambda$ in the
dominant domain alone. The width of that gate window is $(1-\lambda)/\lambda$ — the
reciprocal mass ratio — and it shrinks to nothing as one domain takes over the mass.

Now recall that the knee, as a function of the gate, is a **staircase**: it is constant on
each interval $\bigl(R_w(n,k-1), R_w(n,k)\bigr]$, where its value is $k$, and the width of
that step is exactly the normalised mass $w_k / H_w(n)$ of a single key. So if the shifted
gate window fits inside one step of the dominant domain's staircase, the mixture's knee
*equals* the dominant domain's knee, exactly, with no error term.

This is **Mass-Share Rigidity**, and it is the honest mechanism behind "the mixed domain
starts at code's level". At the shorter context the code domain still carries enough of
the mass that the whole gate window sits inside one step, and the mixture is
indistinguishable from pure code. At the longer context it no longer does.

Rigidity also organises the mixing-ratio sweep. If one domain uniformly dominates the
other — its retained curve is everywhere higher — then the pooled knee is *monotone* in
the mixing ratio, the set of ratios at which it has collapsed onto the dominant knee is
upward closed and non-empty, and so the sweep is a monotone staircase with a single kink
followed by a terminal plateau. Better still, the kink has a closed formula. Writing $K$
for the dominant domain's knee, the critical weight is
$$a^{*} \;=\; \max\left(0,\ \frac{\tau H_v(n) - H_v(K)}{H_u(K) - \tau H_u(n)}\right),$$
four head masses of the two *pure* domains and nothing else. A mixing-ratio sweep needs no
mixed measurement to predict its own kink. And the boundary is genuinely interior — the
kink is at a strictly positive weight — exactly when the weak domain fails the gate at the
dominant knee. In the four-key example above, the formula gives
$(0.7 \cdot 4 - 1)/(10 - 0.7 \cdot 13) = 1.8/0.9 = 2$: the sweep collapses onto code's
knee at weight $2$, and the balanced protocol at weight $1$ sits strictly below it. That is
exactly why the balanced mixture has knee $2$ rather than code's knee $1$.

## The price of the doubling

So mixing doubles the increment. Is that a gain in sensitivity — a protocol that sees
more? No. It is a change of units, and the change is paid for elsewhere.

Interleaving subdivides each step of the gate staircase into one sub-step per domain, and
the sub-steps of a pooled step add up exactly to that pooled step. Resolution is
partitioned, not created. With $m$ domains, *some* sub-step is at most $1/m$ of the pooled
step, and the bound is attained: there is an explicit gate at which a perturbation of that
size already moves the knee by one key.

Multiply the two effects together and you get a conservation law. The "density" of a
protocol — increment times resolution — never increases under interleaving; for balanced
mixtures it is exactly conserved; and for unbalanced mixtures it is *lost*, unboundedly:
a faint second domain can shrink the resolution below any prescribed fraction of the
pooled step. Interleaving is never a measurement amplifier, and skewed interleaving is a
measurement destroyer.

There is a practical corollary that any experimenter should take to heart. A reported knee
is only a measurement of the model if the gate sits far enough from a step edge. There is
an explicit stability radius: every gate within
$\min\bigl(\tau - R_w(n,K-1),\, R_w(n,K) - \tau\bigr)$ of the reported gate returns the
same knee — and that radius is sharp, since at a step edge an arbitrarily small
perturbation moves the knee. A mixed protocol halves that radius. The doubled increment
and the halved resolution are the same fact seen twice.

## What the numbers were actually measuring

Here is the final reversal. A mixed-versus-pure knee excess that *grows* with context is
possible only for **gapless** profiles. If the attention weights decay geometrically —
$w_{i+1} \le r\,w_i$ for some $r < 1$ — then both the pure and the mixed knee are bounded
by a single constant independent of context. For the flat profile the excess is unbounded.
There is no middle ground.

So the table that opened this article is not a measurement of Python versus English. It is a measurement of
the *model's own attention spectrum*, and it can be turned into one explicitly. If
$r^K \le (1-\tau)(1-r)$ then the knee never exceeds $K$, at any context. Contrapose: an
observed knee exceeding $K$ *refutes* every candidate decay ratio passing that test, and
so certifies a lower bound on the true ratio. Dually, for a sorted profile with a floor
rate $q$ (weights that never fall off a cliff, $q\, w_i \le w_{i+1}$), a knee of at most
$K$ in a context at least twice as long forces $q^{2K} \le (1-\tau)/\tau$ — an upper
bound. A single exact knee value therefore brackets the spectrum from both sides. On the
reported numbers, the mixed knee of $20$ at a gate of $0.99$ pins the model's per-key decay
ratio into the window $(1/2,\,4/5)$ — a genuine two-sided spectral measurement extracted
from two integers in a table.

## The shape of the answer

The verdict that opened this article — *starts low, rises fast* — survives, but it is no
longer mysterious, and its two halves have entirely different causes.

"Starts low" is mass-share rigidity: at short contexts the heavier domain owns the
mixture, exactly and provably, and the mixture's knee is that domain's knee with no error
term.

"Rises fast" is a change of units: interleaving is pooling with each key split in two, so
every increment is automatically doubled. It would be doubled even if you interleaved a
domain with itself.

And "mixed attention has structure of its own" is true — but the structure is not a
mysterious cross-domain interaction. It is arithmetic: a mediant, a convex combination
with weight the mass share, and a staircase whose steps are individual key masses. What
makes it worth knowing is that this arithmetic is *predictive*. It says that a ninety-ten
mixture must show a tenfold increment; that a block-size sweep must show no trend at all;
that a mixing-ratio sweep must kink once, at a weight computable from the pure domains
alone; and that every one of these predictions can be checked, and any of them could turn
out to be false. That is more than the original table asked for, and it is the reason the
table was worth staring at.
