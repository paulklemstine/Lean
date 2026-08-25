# How Deep Can You Cut Space?

## A budget, a branching rule, and the exact depth of the world

Imagine you are handed a region of space and a pair of scissors with a peculiar
rule: every time you cut, each piece you have must split into exactly $B$ smaller
pieces. One cut turns $1$ cell into $B$. Two cuts turn those $B$ cells into $B^2$.
After $d$ rounds you are looking at a nested cascade — a coarse cell containing $B$
medium cells, each containing $B$ finer cells, and so on down $d$ generations.

Now the twist. Physics does not let you cut forever. Every serious proposal for
what happens to spacetime at very small scales — Wheeler's quantum foam, causal
sets, spin networks, holographic bounds of the Bekenstein type — comes with a
*finite budget*. A region of space can only hold so much distinguishable
structure. Call that budget $T$: the maximum number of distinguishable cells the
region can support. Once the cascade you have built contains more than $T$ cells,
you have written more information into the region than it can physically store.

So here is the question. **Given $B$ and given $T$, exactly how deep can you cut?**

Not "roughly how deep". Not "here is a table for a few sample numbers". *Exactly*
how deep, as a formula in $B$ and $T$, with a proof that no deeper cascade fits.

That question has a clean and complete answer, and this article is about it.

---

## Counting the cost honestly

The first decision is a modelling one, and it turns out to matter.

The naive way to charge for a cascade of depth $d$ is to count only its finest
level: $B^d$ cells. But a nested structure is not just its leaves. The coarse cell
exists. The intermediate cells exist. If you are counting distinguishable
configurations, they all count. So the honest cost of a depth-$d$ cascade is the
whole tree:

$$S_B(d) \;=\; 1 + B + B^2 + \cdots + B^d.$$

We say a depth $d$ is **supported** by the budget $T$ when $S_B(d) \le T$.

Immediately something pleasant happens. Because $S_B$ is strictly increasing in
$d$, the set of supported depths is *downward closed*: if depth $7$ fits, so does
depth $3$. The supported set is therefore an unbroken initial segment
$\{0, 1, \dots, d_{\max}\}$, and the entire physics of "how refined can this region
be" collapses to a single integer.

That integer has a closed form.

> **Theorem (Parameter-derived depth).** Let $B \ge 2$ and $T \ge 1$. The greatest
> depth $d$ with $1 + B + \cdots + B^d \le T$ is
> $$d_{\max}(B,T) \;=\; \bigl\lfloor \log_B\bigl((B-1)T + 1\bigr) \bigr\rfloor - 1.$$
> Moreover this depth is genuinely maximal: the depth $d_{\max}+1$ overshoots the
> budget, and the supported depths are exactly $0$ through $d_{\max}$.

The proof is a one-line algebraic pivot. The finite geometric identity

$$(B-1)\,S_B(d) + 1 \;=\; B^{\,d+1}$$

converts the budget inequality $S_B(d) \le T$ into the pure power inequality
$B^{\,d+1} \le (B-1)T + 1$, which is exactly the definition of the integer
logarithm. Everything else in the theory is downstream of that single identity.

Some concrete answers, each with the maximality certificate attached rather than
merely asserted:

| branching $B$ | budget $T$ | maximal depth | witness |
|---|---|---|---|
| $2$ | $1{,}000$ | $8$ | $S_2(8) = 511 \le 1000 < 1023 = S_2(9)$ |
| $3$ | $100$ | $3$ | $S_3(3) = 40 \le 100 < 121 = S_3(4)$ |
| $10$ | $10^6$ | $5$ | $S_{10}(5) = 111111 \le 10^6 < 1111111 = S_{10}(6)$ |
| $5$ | $10^6$ | $8$ | $S_5(8) = 488281 \le 10^6 < 2441406 = S_5(9)$ |

A million cells of budget buys you five levels of decimal refinement. That is
not a lot. Depth is expensive.

---

## Depth is a logarithm — and the resolution is not

The formula above is arithmetic. The physical content is analytic, and it is
this: the depth is the logarithm of the budget, *uniformly*, with an error you can
name.

> **Theorem (Logarithmic law).** For $B \ge 2$ and $T \ge 1$,
> $$\log_B T - 2 \;<\; d_{\max}(B,T) \;\le\; \log_B T.$$

This follows from trapping the depth between two powers. On one side, the finest
level alone costs $B^{d}$ cells, and the whole cascade fits, so $B^{d_{\max}} \le T$.
On the other side, the *next* cascade does not fit, and since
$S_B(d+1) \le (B-1)S_B(d+1) + 1 = B^{d+2}$, failure of $S_B(d_{\max}+1) \le T$ forces
$T < B^{\,d_{\max}+2}$. Taking base-$B$ logarithms of

$$B^{\,d_{\max}} \;\le\; T \;<\; B^{\,d_{\max}+2}$$

gives the claim. Note the constant $2$ is *absolute*: it does not drift with $B$,
and it does not drift with $T$. This is a genuinely uniform estimate, not an
asymptotic hand-wave.

And now the consequence that a physicist actually wants. Suppose the coarsest cell
has linear size $\ell_0$. Then the finest cell of the maximal cascade has size
$\ell = \ell_0 B^{-d_{\max}}$. Substituting the two-sided bound:

> **Theorem (Resolution scaling).** With $\ell_0 > 0$,
> $$\frac{\ell_0}{T} \;\le\; \ell \;<\; B^2\,\frac{\ell_0}{T}.$$

Read that carefully, because it inverts the intuition. The *depth* you can afford
grows only logarithmically in your budget — doubling $T$ buys you a fraction of a
level. But the *resolution* you can achieve improves **linearly** in $T$, up to a
constant window of width $B^2$ that depends on the branching rule alone and never
on the budget.

This is the whole tension of hierarchical models in one line. Levels are cheap in
resolution and expensive in count. If your finest length scale is what you care
about — and in physics it usually is — then the information budget buys resolution
at a fair, linear exchange rate. If your *number of scales* is what you care about
— renormalisation-group steps, layers of a nested code — you are paying a
logarithm, and no amount of budget will rescue you. There is no universal depth:
for any target $N$, some budget supports depth at least $N$, since the budget
$T = S_B(N)$ supports exactly depth $N$ and no more. That last fact is also the
calibration point showing both bounds above are attained.

---

## Does the answer depend on how you keep the books?

A skeptic should now object. The formula $\lfloor\log_B((B-1)T+1)\rfloor - 1$ looks
like an artefact of one specific accounting convention — "count every cell of the
tree, each worth one unit". Change the convention and surely the answer changes.

It does not, and this is the most robust result in the theory.

> **Theorem (Universality of the logarithmic depth law).** Let $\mathrm{cost}(d)$ be
> any strictly increasing cost function that is *geometrically sandwiched*,
> $$B^{\,d} \;\le\; \mathrm{cost}(d) \;\le\; K \cdot B^{\,d} \qquad \text{for all } d,$$
> and let $T$ be a budget affording at least depth $0$. Then the maximal supported
> depth satisfies
> $$\log_B T - (\log_B K + 1) \;\le\; d_{\max} \;\le\; \log_B T$$
> (with integer logarithms throughout).

The additive slack depends on the sandwich constant $K$ **and on nothing else** —
not on $T$, not on the shape of the cost inside the sandwich. All the modelling
freedom in how you charge for a level is worth $\log_B K + 1$ levels of depth and
not one level more.

The proof of the upper half is immediate: the maximal cascade fits, and it costs at
least $B^{d}$, so $B^{d_{\max}} \le T$. The lower half is a shift argument. Since
$K < B^{\log_B K + 1}$, writing $e = \log_B K + 1$ and $L = \log_B T$, the depth
$L - e$ costs at most $K B^{L-e} < B^{e} B^{L-e} = B^{L} \le T$, so it is supported.

Two applications make the point concrete.

**The tree count itself.** One shows $S_B(d) \le 2 B^d$ for every $B \ge 2$ —
the whole tree is never more than twice its finest level, because the geometric
series is dominated by its last term. So $K = 2$, and universality independently
reproduces the logarithmic law without touching the exact arithmetic at all.

**Cells plus overhead.** Suppose each cell costs $a$ units of some resource, and
each *level* carries an additional fixed overhead $c$ — a boundary term, a
gauge-fixing cost, a per-scale bookkeeping charge. The total is
$E(d) = a\,S_B(d) + c\,(d+1)$. Since $d+1 \le B^d$, this is sandwiched with
$K = 2a + c$, and the depth law survives with the explicit shift
$\log_B(2a+c) + 1$. A per-level overhead can move the offset. It can never change
the law.

---

## Two regions are better than one — by exactly two levels

Independent subsystems compose. If two regions carry budgets $T_1$ and $T_2$, the
joint system carries budget $T_1 T_2$ — budgets count distinguishable
configurations, and configurations of independent systems multiply.

What does depth do under this tensoring?

> **Theorem (Composition).** For $B \ge 2$ and $T_1, T_2 \ge 1$,
> $$d_{\max}(T_1) + d_{\max}(T_2) \;\le\; d_{\max}(T_1 T_2) \;\le\; d_{\max}(T_1) + d_{\max}(T_2) + 2,$$
> and both ends of this window are attained.

Depth is additive under composition, up to an absolute slack of two levels. The
engine is a pair of matched multiplicative inequalities for the cell count, both
proved by induction from the geometric identity:

- $S_B(x+y) \le S_B(x)\,S_B(y)$ — merging two cascades never costs more than the
  product of their costs (this gives superadditivity of depth);
- $S_B(x)\,S_B(y) \le S_B(x+y+1)$ — and the product never exceeds a single cascade
  one level deeper than the sum (this gives subadditivity up to $+2$).

Both extremes really occur, with binary branching. Additive end: $d_{\max}(7) = 2$
and $d_{\max}(7 \cdot 7) = d_{\max}(49) = 4 = 2 + 2$, exactly additive. Maximal-gap
end: $d_{\max}(5) = 1$, $d_{\max}(13) = 2$, and $d_{\max}(65) = 5 = 1 + 2 + 2$. The
$+2$ cannot be improved.

Iterating superadditivity over $n$ identical subsystems gives
$n \cdot d_{\max}(T) \le d_{\max}(T^n)$: depth grows at least linearly in the number
of tensor factors. This is the discrete shadow of extensivity — the statement that
the information budget of a composite region is the sum of the budgets of its
parts, transported through the logarithm into a statement about refinement levels.

---

## The price of the coarse levels, and how often you pay it

Return to the modelling choice at the very start. What if you had cheated and
counted only the leaves, $B^d$ instead of the full tree? Then the maximal depth
would be exactly $\lfloor \log_B T \rfloor$. How much did honesty cost?

> **Theorem (One-level deficit).** For $B \ge 2$, $T \ge 1$,
> $$\lfloor\log_B T\rfloor - 1 \;\le\; d_{\max}(B,T) \;\le\; \lfloor\log_B T\rfloor.$$
> Charging for all the coarse levels costs at most a single level of depth, and it
> costs nothing precisely when the full tree of depth $\lfloor\log_B T\rfloor$ still
> fits inside $T$.

So the deficit $\delta(B,T) = \lfloor\log_B T\rfloor - d_{\max}(B,T)$ is always $0$
or $1$. Which is it? The answer is startlingly clean once you organise budgets by
scale. Fix $L$ and look at the block of budgets with $\lfloor\log_B T\rfloor = L$,
that is $B^L \le T < B^{L+1}$. Then:

- the **lossless** budgets ($\delta = 0$) are exactly the interval
  $[\,S_B(L),\, B^{L+1})$;
- the **lossy** budgets ($\delta = 1$) are exactly $[\,B^L,\, S_B(L))$;
- and therefore the number of lossy budgets at scale $L \ge 1$ is exactly
  $$S_B(L) - B^L \;=\; S_B(L-1),$$
  the total cell count of a cascade **one level shallower**.

That is a self-similarity statement: the population of budgets that pay the
overhead at scale $L$ is itself counted by the same cascade function, at scale
$L-1$. Equivalently, $(B-1)\cdot\#\{\text{lossy}\} + 1 = B^L$.

Divide by the block size $B^{L+1} - B^L = (B-1)B^L$ and let $L \to \infty$:

> **Theorem (Density of the depth penalty).** The fraction of scale-$L$ budgets
> that lose a level converges, as $L \to \infty$, to
> $$\frac{1}{(B-1)^2}.$$

For binary branching this limit is $1$: **almost every** information budget pays
the extra level. Binary foam essentially always loses a level of depth to the cost
of its own coarse structure. For $B = 3$ the density drops to $1/4$; for $B = 10$
it is $1/81$. The more aggressively each level branches, the more completely the
finest level dominates the count, and the more nearly free the coarse scaffolding
becomes.

This is a precise, quantitative answer to a question one would otherwise wave at:
*are the coarse-grained levels of a hierarchical spacetime model a negligible part
of its information budget?* For large branching, yes, with density $1 - 1/(B-1)^2$.
For binary, essentially never.

---

## Foams that do not branch uniformly

Real hierarchies are messy. There is no reason a physical cascade should split
every cell into the same number of pieces at every scale. So let a **schedule**
$r(0), r(1), r(2), \dots$ prescribe the branching number used at each level. Then a
level-$k$ family contains $w_r(k) = r(0)r(1)\cdots r(k-1)$ cells, and a cascade of
depth $d$ costs $\sum_{k \le d} w_r(k)$.

> **Theorem (Quenched disorder).** Suppose the schedule is quenched between two
> branching numbers, $B_{\min} \le r(k) \le B_{\max}$ for all $k$, with
> $B_{\min} \ge 2$. Then for every budget $T \ge 1$,
> $$\log_{B_{\max}} T - \bigl(\log_{B_{\max}} 2 + 1\bigr) \;\le\; d_{\max} \;\le\; \log_{B_{\min}} T.$$

Disorder cannot destroy the logarithmic depth law. It can only slide the depth
inside the window between the two extreme logarithms, and the additive constant is
uniform in $T$. Setting $B_{\min} = B_{\max} = B$ recovers the ordered theory
exactly.

A worked disordered example: the alternating schedule $2, 3, 2, 3, \dots$. Its
cumulative cell counts are $1, 3, 9, 21, 57, 129, \dots$. With a budget of $100$
cells, depth $4$ fits ($57 \le 100$) and depth $5$ does not ($129 > 100$), so the
maximal depth is exactly $4$ — comfortably inside the predicted window
$3 \le 4 \le 6$.

---

## What this all adds up to

Start with two numbers a physicist can actually name: how finely each scale
subdivides, and how much information a region can hold. Everything else is then
determined, not chosen.

The maximal refinement depth is $\lfloor\log_B((B-1)T+1)\rfloor - 1$, and it is
*the* answer, not *an* answer — the greatest supported depth, unique, with every
shallower depth supported and the next one provably over budget. Around that
formula sits a small ecosystem of structural facts: the depth is $\log_B T$ to
within an absolute additive $2$; the finest resolvable length is $\Theta(\ell_0/T)$
with a $B^2$ window; the law is universal across any geometrically sandwiched cost
model, with slack controlled only by the sandwich constant; depth is additive
under composition of independent regions up to a sharp $+2$; the penalty for
honest bookkeeping is at most one level, paid with limiting density $1/(B-1)^2$;
and quenched disorder in the branching schedule merely relocates the depth inside
the window between the extreme logarithms.

The moral is a modest but sturdy one. When people say "spacetime has a smallest
scale" or "the hierarchy bottoms out", they are usually reaching for something
mystical. It need not be. Fix your branching rule, fix your information bound, and
the depth of the world is a computation — one you can carry out, and one whose
maximality you can prove.
