# The Dial That Hit the Floor

## What a fading number-theoretic signal can tell us about a machine-learning pipeline

There is a peculiar kind of detective work that happens inside large computational
pipelines. You cannot see the machinery directly. You can only attach instruments to it,
watch the needles move, and reason backwards about what the movements mean. This is the
story of one such instrument — we will call it *the dial* — and of what happened when its
needle slid all the way down to the bottom of its scale.

### An instrument made of trailing zeros

The dial is built out of one of the oldest ideas in arithmetic. Take a whole number $x$
and ask: how many times can you divide it by two before it turns odd? That count is the
number of trailing zeros in the binary expansion of $x$, written $v_2(x)$ and known to
number theorists as the **2-adic valuation**. The number $12 = 1100_2$ has $v_2 = 2$; the
number $7 = 111_2$ has $v_2 = 0$; and $2^{40}$ has $v_2 = 40$.

In the pipeline we are studying, integers are drawn uniformly at random from the range
$\{0, 1, \dots, 2^b - 1\}$ — all $b$-bit numbers, each equally likely. For each drawn
number the pipeline produces a downstream numerical outcome, which we will call the
*rate*. The dial is the **Spearman rank correlation** $\rho$ between the trailing-zero
count $T(x) = v_2(x)$ and the rate: rank all the inputs by their trailing zeros, rank all
the outputs by their rate, and measure how well the two orderings agree. A reading of
$\rho = 1$ means perfect agreement; $\rho = 0$ means no relationship at all.

Why should trailing zeros predict anything? Because a pipeline that manipulates integers —
that shifts them, halves them, tests them for divisibility, packs them into fixed-width
words — inherits the arithmetic structure of its inputs. A strong dial reading is evidence
that the downstream behaviour is genuinely tracking the arithmetic. A collapsing reading
means the pipeline is losing contact with the structure it is supposed to be exploiting.

The pipeline's health band for this instrument is $[0.55,\,0.85]$. Below $0.55$ the
diagnostic is declared uninformative.

### The needle slides

Here are the readings, taken over a sequence of experiments at increasing bit-widths $b$:

| bit-width $b$ | 44 | 52 | 64 | 76 | 92 |
|---|---|---|---|---|---|
| dial reading $\rho$ | $0.780$ | $0.705$ | $0.648$ | $0.608$ | $0.563 / 0.556$ |

At $b = 92$ two independent random seeds gave $0.563$ and $0.556$. Both sit essentially
*on* the floor: one is $0.013$ above it, the other $0.006$ above it, and their mean
$0.5595$ clears the floor by less than one part in a hundred. After a long, orderly slide
across five experiments, the needle has reached the bottom of the dial.

That raises the question this article is about. **Why?**

### Suspect number one: the instrument is too coarse

The most deflationary explanation is that nothing interesting is happening in the pipeline
at all — the *instrument* has run out of resolution.

Here is the idea. Suppose the dial cannot actually see arbitrarily deep valuations.
Suppose it resolves only the first $K$ levels, reporting $\min(v_2(x), K)$ instead of
$v_2(x)$. Then every input divisible by $2^K$ — no matter how divisible — is lumped into
one enormous class of indistinguishable values, a *tie class*. And ties are poison for
rank correlation: if a large fraction of your sample carries identical ranks, no amount of
downstream signal can produce a high $\rho$. Maybe the erosion is nothing but tie damage
from a truncated instrument.

This suspicion is testable, because the damage done by ties is exactly computable. If a
statistic partitions a sample of size $n$ into tie classes of sizes $m_1, \dots, m_J$, then
the very best rank correlation it can achieve against *any* perfectly aligned response is

$$\rho_{\max}^2 \;=\; 1 - \frac{\sum_j (m_j^3 - m_j)}{n^3 - n}.$$

This is a hard ceiling: geometry, not statistics. So we just need the tie profile of the
capped statistic. On $b$-bit draws with a cap at depth $K$, writing $r = b - K$, exactly
half of the numbers are odd, a quarter have exactly one trailing zero, and so on — giving
classes of sizes $2^{b-1}, 2^{b-2}, \dots, 2^{r}$ for the $K$ resolved levels — and the
merged deep class consists of the multiples of $2^K$ below $2^b$, of which there are
exactly $2^{r}$.

Summing the geometric series gives a clean closed form, which is the first main result of
this work.

> **Capped Resolution Law.** For the $K$-capped 2-adic statistic on uniform $b$-bit draws,
> with $r = b - K \geq 0$ and $b \geq 1$, the Spearman ceiling is exactly
> $$\rho_{\max}^2 \;=\; \frac{6}{7}\cdot\frac{8^{\,b} - 8^{\,r}}{8^{\,b} - 2^{\,b}} \;=\; \frac{6}{7}\cdot\frac{1 - 8^{-K}}{1 - 4^{-b}}.$$

The formula behaves exactly as intuition demands. With no resolution at all ($K = 0$)
everything is one tie class and the ceiling is $0$. With full resolution ($r = 0$) it
becomes $\frac{6}{7}\bigl(1 + \frac{1}{2^b(2^b+1)}\bigr)$, the known dyadic ceiling.
Deeper caps are strictly better than shallower ones at the same bit-width. And as the cap
is lifted the ceiling climbs to $6/7 \approx 0.857$.

But now look at what the formula says at $K = 1$ — the crudest possible instrument, one
that can only tell odd from even:

$$\rho^2_{\max} \;=\; \frac{6}{7}\cdot\frac{1 - \tfrac18}{1 - 4^{-b}} \;\geq\; \frac{6}{7}\cdot\frac{7}{8} \;=\; \frac34.$$

That inequality is the punchline. **Every** capped dial, at **every** cap depth $K \geq 1$
and **every** bit-width, has $\rho_{\max}^2 \geq 3/4$, i.e. $\rho_{\max} \geq 0.866$.
Merging all the deep valuation levels into one giant tie class costs at most a quarter of
the squared correlation, because the deep levels are exponentially rare: the geometric
series $\tfrac12, \tfrac14, \tfrac18, \dots$ puts almost all the mass in the shallow
classes that the instrument *can* see.

The recorded bitlen-92 reading is $\rho \leq 0.563$, that is $\rho^2 \leq 0.317$. That is
not merely below the capped ceiling — it is below the ceiling of the *worst possible*
capped instrument, by a wide margin. Suspect number one is eliminated. Coarse resolution
cannot explain the erosion.

One can push the point further. Comparing the exact uncapped ceilings at $b = 52$ and
$b = 92$, they differ by less than $10^{-15}$, while the dial itself fell by more than
$0.14$ over that interval. The available tie-geometry budget is thirteen orders of
magnitude too small. Whatever is eroding the dial, it is not the arithmetic.

### Suspect number two: something is scrambling the ranks

If the ceiling is intact and the reading has fallen, then something must be actively
disagreeing with the arithmetic — reordering the outputs relative to what the trailing
zeros predict. So the natural next question is quantitative: *how much* reordering does
the reading force?

The tool here is a stability estimate for rank correlation. If two response vectors agree
everywhere outside a set $A$ of indices, then their Spearman correlations against any fixed
reference differ by at most $6\,|A|/n$. Rank correlation is Lipschitz in the fraction of
the sample you are allowed to touch.

Turn that around. Start from a perfectly aligned response, which reads $\rho = 1$. Let
some mechanism act on a set $A$ and drop the reading to $\rho$. Then

$$\frac{|A|}{n} \;\geq\; \frac{1 - \rho}{6}.$$

This is a **corruption budget**: a reading is a lower bound on how much of your sample the
disturbance had to touch. And the numbers are startlingly clean:

- At $b = 52$, $\rho = 0.705$ forces displacement of under $4.92\%$ of the sample.
- At $b = 92$, $\rho = 0.563$ forces displacement of more than $7.28\%$.
- At the validation floor $\rho = 0.55$, the budget is exactly $\frac{0.45}{6} = \frac{3}{40} = 7.5\%$.

And there is a converse, which is where the story acquires its real shape. Run the
Lipschitz estimate in the other direction: any mechanism touching at most $3/40$ of the
sample *cannot* push the reading below $0.55$. So membership of the validation band and a
$7.5\%$ corruption budget are literally the same statement.

> **The floor is the budget.** The validation floor $\rho \geq 0.55$ holds if and only if
> the disturbance displaces at most $7.5\%$ of the sample.

This explains something that had looked like a coincidence: why the dial *bottoms out* at
$0.55$ rather than decaying smoothly toward zero. The floor was never an arbitrary
convention. Someone, long ago, chose a number that encodes a $7.5\%$ tolerance for rank
displacement, and the instrument is now sitting exactly at that tolerance.

### The shape of the slide, and a prediction

Five readings across five experiments is enough data to ask what curve the erosion follows.
It is not exponential and it is not linear. It is hyperbolic:

$$\rho(b) \;=\; \frac{5}{14} + \frac{93}{5b} \;\approx\; 0.357 + \frac{18.6}{b}.$$

This two-constant law reproduces every recorded reading — $b = 44, 52, 64, 76, 92$,
spanning four separate experiments — to within $1/100$, with the largest residual
($0.0098$) at $b = 52$. It decreases strictly with $b$, and its asymptote is
$5/14 \approx 0.357$, comfortably *below* the floor. So the dial does not converge to the
floor; it passes through it.

When? Solve $5/14 + 93/(5b) = 11/20$. The answer is exact and it is sharp:

> **Crossing Prediction.** Under the hyperbolic law the dial stays at or above $0.55$ for
> every bit-width $b \leq 96$, and falls strictly below it for every $b \geq 97$.

That is a falsifiable claim about an experiment nobody has run. One measurement at, say,
$b = 108$ either confirms the law or destroys it.

The same law also settles the corruption ledger. Feeding $\rho(b)$ through the budget
formula gives a forced displacement of exactly $\frac{3}{28} - \frac{31}{10b}$, which grows
with $b$ but is bounded strictly by $3/28 \approx 10.7\%$. So no rank-level mechanism
consistent with the fitted trend will ever be forced to displace more than about a tenth of
the sample. And the dial exits its validation band precisely when the forced displacement
overruns the $3/40$ floor budget — which is to say, precisely at $b = 97$. The geometric
statement and the arithmetic statement are two views of a single crossing.

### A change of base

Finally, an unexpected reinterpretation. Everything above was about the prime $2$, but
nothing in the argument was. Replace "trailing zeros in base $2$" by "trailing zeros in
base $p$" — the $p$-adic valuation $v_p(x)$ — and the whole edifice survives. The tie
classes now have sizes $(p-1)p^{b-1}, (p-1)p^{b-2}, \dots$, and the geometric sum gives:

> **Base-$p$ Capped Resolution Law.** For the $K$-capped $p$-adic statistic on uniform draws
> from $\{0,\dots,p^b-1\}$, with $b = r + K \geq 1$ and $p \geq 2$,
> $$\rho_{\max}^2 \;=\; L(p)\cdot\frac{p^{3b} - p^{3r}}{p^{3b} - p^{b}}, \qquad L(p) = \frac{3p}{p^2 + p + 1}.$$

The constant $L(p)$ is the asymptotic ceiling of a *perfect* base-$p$ valuation dial;
$L(2) = 6/7$ recovers the dyadic case exactly. And the universal floor survives too: every
capped base-$p$ dial has $\rho^2 \geq L(p)(1 - p^{-3})$, which at $p = 2$ is precisely the
$3/4$ we used to eliminate suspect number one. The floor was never an accident of base
two; only its numerical value was.

Now invert the picture. Since $L(p) = 3p/(p^2+p+1)$ decreases strictly in $p$, every
reading $\rho$ has a well-defined **effective base**: the unique integer $p$ with
$L(p+1) < \rho^2 \leq L(p)$. It is the base of the idealised valuation dial that would
produce exactly this reading. Because $L$ is strictly decreasing, a smaller reading always
means an effective base at least as large. **Erosion is base drift.**

And drift it does. At $b = 76$ the reading sat above the base-seven ceiling
$L(7) = 7/19$. At $b = 92$ both seeds have effective base exactly $8$: their squares fall
between $L(9) = 27/91 \approx 0.2967$ and $L(8) = 24/73 \approx 0.3288$. In sixteen bits of
draw width the dial's effective base moved by a full unit.

Where does it end? Feed the hyperbolic law's asymptote $5/14$ through the same lens:
$(5/14)^2 \approx 0.1276$ sits strictly between $L(23) \approx 0.1248$ and
$L(22) \approx 0.1302$. So the effective base predicted by the erosion law never passes
$23$, at any bit-width.

That is the last twist of the story. The dial is not dying. It is *becoming a different
instrument* — sliding, as the draws grow wider, from a faithful binary-valuation dial into
something that behaves like a valuation dial in base twenty-two-and-a-half, and stopping
there. The signal does not vanish; it changes arithmetic.

### What the exercise teaches

Three lessons generalise well beyond this particular pipeline.

**Ceilings are cheap and decisive.** Before hunting for a mechanism, compute what the
instrument could possibly read under that mechanism. A single closed form — here, the
capped resolution law — turned a plausible hypothesis into an eliminated one, with a
margin of a factor of two in $\rho^2$, using no data at all.

**Readings are budgets.** A rank correlation is not just a number on a scale; via a
Lipschitz estimate it converts into a hard lower bound on how much of the sample any
explanation must disturb. That makes soft-looking diagnostics into quantitative
constraints on candidate mechanisms.

**Validation thresholds have hidden meanings.** The floor $0.55$ turned out to be exactly a
$7.5\%$ displacement tolerance. Thresholds inherited from convention often encode a
sharp statement that nobody wrote down. It is worth going back and finding out what yours
says.

The needle is on the floor. But the floor, it turns out, was a measurement all along.
