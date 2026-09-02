# The Dial That Landed on the Floor

## What a confidence interval looks like when you measure it in the geometry of special relativity

There is a particular kind of scientific disappointment that arrives disguised as a success. A measurement comes in, it lands *just* inside the range you promised in advance that it would land in, and you write down: **the prediction holds**. Then somebody asks how wide your error bars were, and the whole thing dissolves.

This is a story about one such measurement, and about the piece of geometry that explains exactly why it dissolves — a piece of geometry borrowed, of all places, from the addition of velocities in special relativity.

---

## The setup: a dial with a floor

Imagine a long-running experiment with a single knob. The knob is an integer size: how many bits long the random numbers are. Call it the *bitlen*. At each setting of the knob you draw a large batch of random integers, compute a statistic $T$ from each one (here: how many trailing zeros the integer has in binary), compute a downstream quantity called the *rate*, and measure how strongly the two move together — the Spearman rank correlation $\rho_T$ between $T$ and the rate.

Before running anything, the experimenters committed to a validation band: the correlation must land in $[0.55,\ 0.85]$. Above the floor $0.55$, the dial is said to *hold*.

Turn the knob to bitlen 80 — the largest uniform setting on the ladder — and run three independent seeds. Here is what comes back:

$$\rho_T = 0.562,\qquad 0.551,\qquad 0.582,\qquad \text{pooled } 0.565,\ \text{ CI } [0.542,\ 0.587].$$

All four numbers sit inside the band. Technically, the dial holds.

But look closer, and two features nag. First, the second seed clears the floor by $+0.001$ — one part in a thousand of a rank correlation estimated from a few thousand draws. Second, the reported confidence interval, $[0.542, 0.587]$, *dips below the floor at its lower end*. The interval's lower reach, $0.542$, is a full $0.008$ under $0.55$, while its upper reach sits $0.022$ above the reading.

Two questions, then. Why is the interval lopsided — leaning downward — when nobody built any asymmetry into it? And how many draws would it actually take to say, with the promised confidence, that the dial clears $0.55$?

Both questions have exact answers. Both answers come from the same place.

---

## Correlations add like velocities

Correlations live on the interval $(-1,1)$, and they refuse to behave like ordinary numbers. The difference between $0.10$ and $0.15$ is nothing; the difference between $0.94$ and $0.99$ is enormous. Statistics has known this for a century, and its standard fix is a change of coordinate: replace a correlation $r$ by its *rapidity*

$$\zeta(r) = \operatorname{artanh} r = \tfrac12 \log\frac{1+r}{1-r}.$$

Do your arithmetic there, then map back with $r = \tanh \zeta$.

Physicists will recognise this instantly. It is the exact same substitution that linearises the composition of velocities in special relativity. Two velocities $u$ and $v$ (in units of the speed of light) do not add; they compose as $(u+v)/(1+uv)$. Their rapidities $\operatorname{artanh} u$ and $\operatorname{artanh} v$ *do* add. Correlations, it turns out, are velocities. Everything below is that analogy taken completely seriously.

The core identity is this. Define the **relativistic difference** of two correlations,

$$d(x,y) = \frac{x-y}{1-xy}.$$

Then, for any $x,y \in (-1,1)$, $d(x,y)$ is again a number in $(-1,1)$, and

$$\operatorname{artanh} x - \operatorname{artanh} y = \operatorname{artanh}\, d(x,y).$$

*The rapidity gap between two correlations is itself a correlation.* Subtraction in rapidity is relativistic subtraction in correlation coordinates. That single sentence generates every other result here.

---

## Why the interval leans down

A confidence interval for a correlation is not built in correlation coordinates. It is built in rapidity: you take the reading $r$, go to $\zeta(r)$, step a fixed distance $h$ either way, and map back. Perfect symmetry — in the coordinate where symmetry is the right thing to have.

Write $\tau = \tanh h$ for the rapidity half-width expressed as a correlation. Then the two endpoints are exactly

$$\text{lower} = d(r,\tau) = \frac{r-\tau}{1-r\tau}, \qquad \text{upper} = d(r,-\tau) = \frac{r+\tau}{1+r\tau}.$$

Two clean laws follow by pure algebra.

**The width law.** The interval's total width in correlation coordinates is
$$\text{width} = \frac{2\tau(1-r^2)}{1-r^2\tau^2}.$$
The factor $1-r^2$ is the familiar squeeze: near $\pm 1$ there is no room left, and intervals collapse.

**The asymmetry law.** The lower arm minus the upper arm is exactly
$$\frac{2r\tau^2(1-r^2)}{1-r^2\tau^2}.$$

Every factor here is positive when $r>0$ and $0<\tau<1$. So: **at any positive reading, a rapidity-symmetric interval always reaches further down than up.** Always. It is not a property of this dial, or of trailing zeros, or of bitlen 80. It is geometry.

That disposes of the first nagging feature. The record notes, as though it were evidence, that "every confidence interval dips below $0.55$ at its lower end." It had to. Lopsidedness in that direction is forced the moment you accept the standard interval construction and a positive reading. The observation carries no information about the dial beyond the point estimate itself.

For the actual numbers: a single rapidity half-width $\tau = 0.033$ about $r = 0.565$ reproduces the reported endpoints as
$$\frac{0.565-0.033}{1-0.565\cdot 0.033} = 0.54211,\qquad \frac{0.565+0.033}{1+0.565\cdot 0.033} = 0.58705,$$
matching $[0.542, 0.587]$ to better than $6\times 10^{-4}$ — exactly, after rounding to three decimals. And no interval symmetric in correlation coordinates can do that, because the arms provably differ.

---

## The certification criterion

Now the second question. When does an interval *certify* a floor $f$ — that is, when does the whole interval sit above $f$?

The answer is a single inequality, and it is beautiful:

$$\text{the interval clears } f \iff \tau \le d(r,f).$$

Read it aloud: **the half-width must not exceed the relativistic gap between the reading and the floor.** Both sides are correlations. The comparison is between the precision you bought and the margin you need.

Now bring in sample size. Standard theory says the rapidity half-width at confidence multiplier $z$ (with $z = 1.96$ for 95%) and effective sample size $n$ is $h = z/\sqrt{n-3}$. Push that through the criterion and rearrange, and you get the whole thing in closed form:

> **The Resolution Law.** A reading $r$ certifies a floor $f<r$ at multiplier $z$ **if and only if**
> $$n \;\ge\; 3 + \left(\frac{z}{\operatorname{artanh} r - \operatorname{artanh} f}\right)^{2}.$$

Resolution cost is a rapidity margin, squared and inverted. Halve the margin and you quadruple the required sample size — exactly, not approximately: the cost above the baseline of $3$ scales as the square.

This is the machine. Now feed it the record.

---

## Scoring the measurement

**How big was the experiment, really?** We never had to be told: the interval reveals it. From $\tau = 0.033$ and $z=1.96$, the resolution law run backwards gives an effective sample size between $3400$ and $3650$ paired draws. (The bounds come from elementary two-sided estimates of $\operatorname{artanh}$; the true value is about $3528$.)

**Does the pooled reading certify the floor?** The pooled reading is $0.565$, the floor is $0.55$, and the rapidity margin between them is about $0.0208$. The law demands
$$n \ \ge\ 3 + \left(\frac{1.96}{0.0208}\right)^2 \approx 8100,$$
and a rigorous lower bound of $7900$ holds. Against a budget of at most $3650$: **the measurement is short by more than a factor of two.** The pooled reading does not certify the floor it appears to clear.

**And the $+0.001$ seed?** Seed two read $0.551$. Its rapidity margin over $0.55$ is about $0.00143$. Square and invert:
$$n \ \ge\ 1.8\times 10^{6}.$$
Nearly two million paired draws, against the roughly twelve hundred that seed carried. Three orders of magnitude. The celebrated clearance is *statistically empty* — not wrong, not disconfirmed, simply invisible at this budget. It is the numerical equivalent of announcing that you can see a hair at a mile.

**Does any seed certify?** No. Splitting the budget three ways gives each seed at most about $1217$ draws. The three required sizes are roughly $12{,}700$, $1{,}866{,}000$, and $1{,}735$. Even the strongest seed, $0.582$, falls short — by a factor of about $1.4$. Not one of the three seeds certifies the floor.

This is the sharp lesson. "The dial holds at bitlen 80" is being asserted as a property of a point estimate. In the language above it should mean *the certification set of the measurement contains the floor* — and at this budget, for every seed and for the pool, it does not.

---

## Is rapidity a rigged coordinate?

A fair objection: all of this is computed in $\operatorname{artanh}$. Choose a different coordinate and the numbers change. Isn't the verdict an artefact?

No, and there is a theorem. The reason a confidence interval has a *fixed* half-width is that in this coordinate the sampling variance no longer depends on what you are measuring. Asymptotically a sample correlation has variance $(1-\rho^2)^2/n$; a change of coordinate $g$ turns that into $g'(\rho)^2(1-\rho^2)^2/n$, and demanding this be constant is the differential equation
$$g'(x)\,(1-x^2) = c.$$

Every solution on $(-1,1)$ is $g(x) = c\operatorname{artanh}(x) + b$. Conversely every such affine image solves it. So:

> **Rapidity is the unique coordinate, up to affine change, in which an interval's half-width is independent of the reading.**

Any other coordinate makes the half-width depend on the very quantity being measured — which is precisely the pathology the change of coordinate exists to cure. Rapidity is not a choice; it is the fixed point of the requirement.

Two corollaries worth having. First, rapidity never *deflates* a gap: for $0\le b\le a<1$,
$$\operatorname{artanh} a - \operatorname{artanh} b \ \ge\ a-b.$$
So the recorded "count parity" advantage of $+0.053$ (the statistic $T$ beating a plain bit-count baseline of $0.512$) is at least $+0.0745$ in rapidity — a 40% inflation. It survives, and grows, in the honest coordinate. Second, it still fades: at bitlen 44 the same advantage ($0.78$ over $0.71$) was more than $1.8\times$ larger *in rapidity*, so the decay of the parity effect is a real phenomenon and not an artefact of reading correlations on the wrong scale.

---

## The crossing test

The record announces the next setting, bitlen 84, as "the crossing test": does the dial fall decisively below $0.55$, or stabilise?

Fit a straight line in rapidity through the two most recent rungs, $(72, 0.605)$ and $(80, 0.565)$, and extrapolate. Two conclusions, both provable as exact statements about rational numbers:

- **The floor is crossed between bitlen 82 and bitlen 83.** The two halves are literally the rational inequalities $\left(\tfrac{2889}{2449}\right)^4 > \left(\tfrac{27927}{24727}\right)^5$ and $\left(\tfrac{2889}{2449}\right)^8 < \left(\tfrac{27927}{24727}\right)^{11}$.
- **The predicted bitlen-84 reading lies in $(0.543,\ 0.545)$** — decisively below the floor.

This is what makes the whole exercise arithmetic rather than numerical. Because $\operatorname{artanh} x = \tfrac12\log\frac{1+x}{1-x}$, every comparison between rapidity combinations of rational readings collapses to a comparison between products of rational powers. A rank-correlation extrapolation becomes a statement one can settle exactly, with integers.

Even better: you can drop the continuity assumption entirely. If a ladder falls by at least $\delta$ in rapidity per rung, then after $\lceil (w_0-L)/\delta\rceil$ rungs it is below $L$. Applied here, *one further 8-bit rung at the observed fade rate already puts the dial below the floor* — the discrete counterpart of the continuous prediction, resting on nothing more than the rational inequality $(313/87)^2 < (31/9)\cdot(321/79)$.

And the cost? Run the resolution law in the mirror direction (certifying a *drop* below a ceiling costs exactly the same rapidity margin as certifying a clearance above a floor). To certify that the bitlen-84 reading has fallen below $0.55$ needs at least $74{,}000$ paired draws at the conservative end of the predicted window, $38{,}000$ at the optimistic end. Against the U80 budget of $\le 3650$: **more than twenty times over.** Run at the current budget, the crossing test cannot be decisive whatever it returns.

---

## The last decidable rung

Step back and a general principle appears, and it is uncomfortable.

Suppose a dial fades roughly linearly in rapidity as you turn the knob. Then as it approaches a fixed floor, its margin shrinks *linearly* — while the sample size needed to resolve that margin grows like the *inverse square*. Margin and cost race in opposite directions, and cost wins quadratically.

Consequently, for any experimental budget $N$ there is a **last decidable rung**: a setting $b_{\max}(N)$ beyond which no experiment of size $N$ can classify the dial relative to the floor at all. And because the cost is exponential in the margin's linear decay, $b_{\max}$ grows only like $\log N$. Buying a hundred times more data buys you a couple more rungs.

The U80 cell is the first place on this ladder where the barrier is not a theoretical worry but the dominant effect: one measured margin is smaller than the experiment's resolution by three orders of magnitude. Past that point the honest report is not "the dial holds" or "the dial fails." It is: *at this budget, the question is no longer being asked.*

That is the real content of a measurement landing on the floor. Not that the answer was yes, and not that it was no — but that the instrument had already run out of the ability to tell.
