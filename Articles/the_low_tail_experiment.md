# The Fourth Seed: What One More Run Can — and Cannot — Tell You

## A cheap trick with an expensive question

Inside every transformer language model there is an operation that quietly dominates the bill: attention. Each token in the context looks at every other token, so a context of $n$ tokens costs on the order of $n^2$ comparisons. Double the context and you quadruple the work.

There is an obvious-looking economy. Most of that attention mass is negligible: for any given query, a handful of keys carry almost all of the weight and the rest contribute a rounding error. So *truncate*. Keep only the top $k$ attention entries per query and throw the rest away. If accuracy holds, you have bought a speed-up of roughly $\mathrm{ctx}/k$ for free.

The question is where the cliff is. As you shrink $k$, quality is flat, flat, flat — and then it falls off. The location of that cliff is what practitioners call the **knee**: the smallest retained budget $k$ at which the model still reaches a fixed fraction of its untruncated accuracy (here, $98\%$). Below the knee, the model breaks. Above it, you are paying for attention you did not need.

Knees are measured, not derived. And measurement has a nuisance: the knee depends on the random seed used to train the model. In the experiment that motivates this article — a small causal transformer, model width $64$, four heads, context $\mathrm{ctx} = 2048$, trained on a word-level corpus, with the accuracy bar set at $0.98$ of full — three seeds produced three different knees:

$$K = \{256,\ 224,\ 160\}.$$

There is a natural reference scale for this cell of the experiment grid, the **product point**

$$P = \frac{d \cdot \mathrm{ctx}}{32} = \frac{4 \cdot 2048}{32} = 256,$$

which is exactly an $8\times$ speed-up against the full context. Against that scale the three measurements read $P$, $\tfrac{7}{8}P$, and $\tfrac{5}{8}P$. The middle value $224 = \tfrac{7}{8}P$ is the **centre** of the sample. The straggler $160 = \tfrac{5}{8}P$ is the **low tail** — a seed whose model was unusually easy to truncate, and therefore unusually cheap to run.

That low tail is worth money. If it is a real feature of this configuration — if a typical seed lands well below the product point — then the honest speed-up on offer is closer to $13\times$ than $8\times$. If it is a fluke of one seed, it is worth nothing.

So: run a fourth seed. This article is about exactly what that fourth run can decide, what it provably cannot decide, and why the answer is not a matter of statistical taste but a theorem about counting.

## One bar, one bit

Before running anything, one has to fix what would count as confirmation. The honest way is to pre-register: name the possible outcomes and the verdict attached to each. Here the plausible knees form a rung ladder — the measurement grid is coarse — and the pre-registered outcomes were

$$\{160,\ 192,\ 224,\ 256\}.$$

The declared reading was: a fourth knee in $\{160, 192\}$ establishes the $0.625P$ low tail as a stable feature of the cell; a knee in $\{224, 256\}$ marks it seed-specific.

Where does the dividing line come from? The natural separator between the measured low tail $160$ and the measured centre $224$ is their midpoint,

$$\tau = \frac{\tfrac{5}{8}P + \tfrac{7}{8}P}{2} = \frac{3}{4}P = 192,$$

which we call the **tail bar**. Call a seed a tail seed if its knee is at or below $\tau$. Among the three recorded knees exactly one — the $160$ — is a tail seed. Add a fourth seed with knee $x$ and count:

$$\#\{\text{tail seeds}\} = \begin{cases} 2, & x \le 192, \\ 1, & x > 192.\end{cases}$$

Declare the low tail **stable** if at least two of the four seeds sit at or below the bar — a low tail with a witness, not a singleton. Then stability holds precisely when $x \le 192$, and on the pre-registered outcome set this reproduces the announced dichotomy exactly: stable for $\{160, 192\}$, seed-specific for $\{224, 256\}$.

That is the first thing worth saying clearly. The verdict is a *threshold functional* of the single number the run produces. It is constant on $\{160,192\}$, constant on $\{224,256\}$, and different across them. In information terms, **the fourth seed carries exactly one bit about the tail.** It cannot distinguish an exact repeat of $160$ from the intermediate rung $192$; both read "stable". It cannot distinguish $224$ from $256$; both read "seed-specific". A run that costs a full training cycle returns a single yes/no.

(There is a finer, three-way reading available if one wants it: only $x \le 160$ *replicates* the recorded tail value, while $x = 192$ delivers stability without replication. But the pre-registered verdict is two-way, and two-way it stays.)

## What the fourth seed cannot see

Now the negative half, which is the mathematically interesting half.

There are two standard ways to summarise where the *centre* of a knee sample sits and how much to trust it.

The first is geometric. The **Fermat–Weber point** of a set of numbers is the value $t$ minimising the total distance $C(t) = \sum_i |t - K_i|$ — the classical "minimise the sum of travel distances" problem, in one dimension. It is the robust notion of "the middle" of a sample: unlike the mean, one wild outlier cannot drag it far. There is a clean counting characterisation: $t$ is a Fermat–Weber point of an $n$-point sample exactly when at least half the sample lies weakly at or below $t$ **and** at least half lies weakly at or above it.

The second is a robustness measure. The **breakdown number** of an estimator is the least number of sample points an adversary must replace — with arbitrary values, arbitrarily far away — to push the estimate outside the range of the honest data. For the $k$-th smallest value of an $n$-point sample the answer is exact and pleasant:

$$\mathrm{bd}(n,k) = \min\{k,\ n-k+1\}.$$

Dragging the $k$-th order statistic *down* past any bound takes $k$ corrupted points; dragging it *up* takes $n-k+1$; fewer than the smaller of the two leaves it stranded inside the clean range.

Now apply both to our sample. For **every** value $x$ of the fourth seed:

* the value $224 = \tfrac{7}{8}P$ remains a Fermat–Weber point of $\{256, 224, 160, x\}$ — the centre does not move, no matter what the new run reports; and
* the breakdown number of the four-seed median is $2$, exactly the breakdown number of the three-seed median.

Both centre summaries are *constant across all four pre-registered outcomes*. And a constant cannot predict a non-constant: since the tail verdict differs between $x = 160$ and $x = 256$ while both centre summaries agree there, **no function whatsoever of either centre summary can reproduce the tail verdict.** The tail bit is logically independent of everything the centre records.

This is the precise content of the slogan "the fourth seed is diagnostic for the tail, not the centre". It is not a claim about statistical power or effect sizes. It is an impossibility statement: the information channel from the fourth run to the centre has capacity zero, while the channel to the tail has capacity exactly one bit.

## The parity law: why four is never the right number

Why does the fourth seed buy no robustness? Because of a parity phenomenon that is invisible until you write down $\mathrm{bd}(n,k) = \min\{k, n-k+1\}$ and maximise over $k$. The best any order statistic of an $n$-point sample can do is the lower median $k = \lceil n/2 \rceil$, whose breakdown number is $\lceil n/2 \rceil$. And $\lceil n/2\rceil$ is *flat across the pair $(2m-1, 2m)$*:

$$\lceil 3/2 \rceil = \lceil 4/2 \rceil = 2, \qquad \lceil 5/2\rceil = 3.$$

Three seeds tolerate one bad run. Four seeds tolerate one bad run. Five seeds tolerate two. Inverting: **the least sample size whose median tolerates $r$ corrupted runs is $2r-1$**, always odd. An even sample size is never a design optimum for any robustness target. Padding an odd design to the next even size is, from the robustness point of view, spending a full training run on nothing.

Nor is this an artefact of choosing the median: *no* rung of a four-seed sample beats the three-seed median. The all-seeds ("certified") budget, quota $4$ of $4$, has breakdown number $1$ — a single unlucky run destroys it. The obstruction is parity in the sample size, not a bad choice of estimator.

## Confirming and calibrating pull in opposite directions

There is a second, subtler cost, and it is the one an experimenter feels.

With four measurements the conventional central reading is the midpoint of the two middle values. Write $b(x)$ for the distance from that reading to the recorded centre $224$. Straightforward case analysis gives

$$b(x) = \begin{cases} 32, & x \le 160,\\[2pt] \tfrac{1}{2}(224 - x), & 160 \le x \le 224,\\[2pt] \tfrac{1}{2}(x - 224), & 224 \le x \le 256,\\[2pt] 16, & x \ge 256. \end{cases}$$

The reading is exactly calibrated — $b(x) = 0$ — only at $x = 224$. But $224 > 192$: the calibrating outcome is precisely an outcome that *refutes* the tail. Conversely, every outcome that confirms the tail satisfies $x \le 192$ and therefore

$$b(x) \ \ge\ \tfrac{1}{2}(224 - 192) \ =\ 16 \ =\ \frac{P}{16}.$$

So at four seeds, **confirmation and calibration are mutually exclusive**. Every outcome that establishes the low tail biases the central reading by at least $P/16$; the only outcome that leaves the centre exactly where three seeds put it is the one that says the tail was a fluke. The experimenter cannot have both. This is the same parity obstruction wearing different clothes: an even sample splits its mass into two equal halves, and the tail quota and the centre quota pull those halves in opposite directions.

At five seeds the conflict dissolves. The ensemble $\{256, 224, 160, 192, 224\}$ — three recorded knees, a low-tail fourth, a centre-confirming fifth — simultaneously

1. keeps two seeds at or below the tail bar (the tail is stable),
2. reads the median rung exactly at $224 = \tfrac{7}{8}P$ (zero bias, unattainable at four seeds), and
3. has breakdown number $3$ (unattainable at four seeds, at any rung).

The fifth seed is exactly what the plan claimed it was: the fourth is diagnostic, the fifth is decisive.

## The bit you can measure is the fragile one

One more twist, and it is a sobering one. We measured how robust the *centre* is. How robust is the tail verdict itself?

A verdict of the form "at least $m$ of the seeds lie at or below the bar $\tau$" is a monotone threshold statement, and its breakdown number — the number of runs an adversary must re-run to flip it — is simply its slack:

$$\text{if the verdict holds: } \ \#\{\text{tail seeds}\} - m + 1; \qquad \text{if it fails: } \ m - \#\{\text{tail seeds}\}.$$

Notice the difference in character from the centre. The breakdown number of the median is a *design* quantity, fixed once you choose $n$. The breakdown number of a verdict is a *data-dependent* slack: you have to buy it with runs that actually land in the tail.

At four seeds we have $m = 2$ and a tail count of $2$ (if the tail is confirmed) or $1$ (if it is not). Either way the breakdown number is $1$. **One re-run overturns the verdict, whichever way it points.** So the single bit the experiment can measure is strictly *less* robust than the centre it cannot measure at all — breakdown $1$ against breakdown $2$. The fourth seed is diagnostic exactly where the design is weakest.

The remedy is the same and it is quantified by a clean design law: an ensemble supporting a quota-$m$ tail verdict robust to $r$ corrupted runs must have tail count at least $m + r - 1$; and since the recorded knees $256$ and $224$ sit permanently above the bar, the ensemble needs at least $m + r + 1$ seeds in total. For a majority verdict robust to one re-run, that is **five** — and five suffice: $\{256, 224, 160, 192, 160\}$ has tail-verdict breakdown $2$ and centre breakdown $3$ at once.

## What it is worth

Finally, the payoff, because this is an engineering measurement in the end.

The product point $P = 256$ certifies an $8\times$ attention speed-up for *all* seeds — that is the conservative, all-seeds guarantee. If the fourth seed confirms the low tail, then the majority budget of the cell — the smallest budget that works for at least half the seeds — is at most $\tfrac{3}{4}P = 192$, and the speed-up certified for a majority of seeds is at least

$$\frac{2048}{192} = \frac{32}{3} \approx 10.7\times.$$

A one-bit experiment converts an $8\times$ all-seeds guarantee into a $10.7\times$ majority guarantee. Whether that bit is worth a training run is a budget question. But now it is a budget question with a price tag on both sides, and — this is the real deliverable — with an honest statement of what the run *cannot* deliver: no improvement in the location of the centre, no improvement in its robustness, and a verdict that one further unlucky run would overturn.

## The moral

Experiment design is usually argued in the language of statistics: power, variance, significance. What this small case study shows is that a surprising amount of it is decided earlier, at the level of *counting*. The centre and the tail are two quota statements about the same counting function $w \mapsto \#\{i : K_i \le w\}$ — the tail reads it at a fixed bar, the centre reads it at a moving one. Once that is visible, the design facts fall out as arithmetic:

* even sample sizes are never robustness optima, because $\lceil n/2\rceil$ is flat across $(2m-1, 2m)$;
* a summary that is constant across all pre-registered outcomes cannot predict a verdict that is not;
* confirming a tail and calibrating a centre are quotas that an even sample pulls apart;
* verdict robustness is slack, and slack must be bought with observations in the tail.

None of that depends on distributional assumptions, on how the knees are generated, or on the accuracy bar chosen. It depends on how many numbers you have and where the bar sits. Before you spend the next training run, it is worth knowing which of your questions it is arithmetically capable of answering.
