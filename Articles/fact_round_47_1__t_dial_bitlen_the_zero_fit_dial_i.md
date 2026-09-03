# The Dial That Doesn't Care How Big Your Numbers Are

## A story about ties, rank correlations, and a measurement that could not have come out any other way

Suppose you build an instrument. Not a telescope or a thermometer — a *statistical* instrument: a number you compute from a piece of arithmetic data, hoping that this number tracks something you care about. Call it a **dial**. You turn the crank, the dial reads $0.72$, and you write it in your notebook.

Then the nagging question arrives, the one every experimentalist knows. *Would the dial still read $0.72$ tomorrow?* With different random inputs? On a different machine? On **bigger numbers**?

That last one is the sharpest, because in arithmetic experiments "bigger numbers" is not a nuisance — it is the whole point. A statistic that works beautifully on $48$-bit integers and quietly dies on $2048$-bit integers is not an instrument; it is a coincidence. So you re-run at a larger size and compare. And here is the trap: whatever you see, you have to interpret it. If the dial drops a little, is that decay — the first hint of a graceful decline toward uselessness — or is it just noise? If it holds steady, is that robustness, or have you simply not gone far enough to find the cliff?

This article is about a case where that question got a definitive answer, and the answer turned out to be far stronger than "we measured twice and it looked fine". The dial in question is provably, *structurally* indifferent to the size of its inputs. Not "indifferent to within a few percent" — indifferent to within $10^{-40}$. The size of the numbers enters the entire theory through exactly one scalar, and that scalar has already converged to its limiting value long before any realistic experiment begins.

---

## Ties are the ceiling

Start with the measuring apparatus itself. The dial is a **rank correlation**: you have a statistic $T$ computed from each sampled integer, you have some target quantity you would like $T$ to predict, and you ask how well the *ordering* induced by $T$ matches the ordering induced by the target. The classical answer is Spearman's coefficient $\rho$: replace each value by its rank in the sample and compute the ordinary correlation of the two rank vectors. Perfect agreement gives $\rho = 1$, perfect disagreement $\rho = -1$.

Now the crucial complication. Real arithmetic statistics are massively **tied**. If $T$ is, say, "the $2$-adic valuation of $n$" — the number of times $2$ divides $n$ — then among the numbers below $2^{b}$, fully half share the value $T = 0$, a quarter share $T = 1$, an eighth share $T = 2$, and so on. The statistic does not order the sample; it sorts it into a handful of enormous bins.

When a statistic has ties, the convention is to give every member of a tied group the same **mid-rank**: the average of the ranks the group occupies. And the moment you do this, something inescapable happens. The tied vector has *less spread* than a fully resolved ranking, and correlation is bounded by the ratio of spreads. **No matter how good your target is, a tied statistic cannot correlate perfectly with it.** The ties impose a hard ceiling.

That ceiling has a beautifully clean form. If the statistic partitions a sample of size $n$ into tie blocks of sizes $m_1, m_2, \dots$, then every squared Spearman correlation involving that statistic obeys

$$\rho^2 \;\le\; 1 \;-\; \frac{\sum_i (m_i^3 - m_i)}{n^3 - n}.$$

The numerator is the classical Spearman tie correction; the denominator is what a fully untied ranking would give. Each block of size $m$ removes $m^3 - m$ from the budget: **ties cost cubically.** One block of size $1000$ is a thousand times more destructive than a thousand blocks of size $10$.

## The self-similar staircase

Apply this to the $2$-adic valuation on $\{0, 1, \dots, 2^b - 1\}$. The blocks are
$$2^{b-1},\; 2^{b-2},\; \dots,\; 4,\; 2,\; 1,\; 1$$
— a geometric staircase, plus a lone singleton for the number $0$. Summing the geometric series $\sum_j 8^{\,j}$ that arises from cubing these block sizes and simplifying gives an exact closed form for the ceiling, with $x = 2^b$ the sample size:

$$\rho^2_{\max} \;=\; \frac{6}{7}\left(1 + \frac{1}{x(x+1)}\right).$$

Stare at that for a moment, because it is the whole story in miniature. There is a **constant**, $6/7 \approx 0.8571$, which knows nothing whatsoever about how big the numbers are. And there is a **correction**, $1/(x(x+1))$, which is the only place the size appears — and which is already smaller than $10^{-4}$ at eight bits, smaller than $10^{-9}$ at sixteen bits, and, at the $48$ bits of an actual experiment, smaller than $10^{-28}$.

Where does $6/7$ come from? Precisely from the self-similarity of the staircase: the tie profile at $b+1$ bits is the profile at $b$ bits with one more step glued on top. Adding a bit reproduces the structure rather than deforming it. The geometric series converges, and the ceiling converges with it.

## A ladder of blindfolds

A ceiling for the ideal statistic is only the beginning. In practice you never deploy the ideal statistic; you deploy something *coarser* — something that has been blindfolded, deliberately or by accident. Three blindfolds matter:

- **The coarse response.** You collapse everything to a single yes/no bit: is the quantity above threshold or not? If the "yes" side captures a fraction $p$ of the scale, this is a *bare count* — the crudest possible instrument.
- **The tip-blind response.** You resolve the bulk perfectly but can no longer distinguish anything in the top $p$ of the scale — the rare, extreme cases blur into one.
- **The bulk-blind response.** The mirror image: you see the rare tip in full detail but the ordinary bottom $1-p$ of the scale becomes a single undifferentiated mass.

Each blindfold merges tie blocks, and merging blocks costs cubically, so each has its own ceiling — computable from exactly the same formula. Writing $p = 2^{-t}$ for the fraction involved and $X = 8^{b}$ for the *cube* of the sample size (cubes, because that is what tie corrections consume), the three ceilings come out as

$$\text{coarse: } \frac{7}{2}p(1-p)\cdot\frac{X}{X-1}, \qquad \text{tip-blind: } \frac{X(1 - p^3)}{X-1}, \qquad \text{bulk-blind: } \frac{X\left(\frac{7}{2}p(1-p) + p^3\right) - 1}{X-1}.$$

The coarse formula deserves a comment. The factor $3p(1-p)$ hidden inside it is the elementary identity $1 - p^3 - (1-p)^3 = 3p(1-p)$: split a scale in two and the surviving resolution is exactly the parabola. Multiply by the $7/6$ that normalises against the dyadic staircase and you get $\frac{7}{2}p(1-p)$. A single bit of output, at the very best, retains a parabola's worth of information — maximal at a balanced split, vanishing as the split becomes lopsided.

## The rigidity theorem

Now look at those three formulas side by side and notice that they are all the same shape:

$$\frac{X\,g + h}{X - 1}, \qquad g \in [0,1], \quad |h| \le 1,$$

where $g$ is the bitlen-free limit — $\frac{7}{2}p(1-p)$, or $1-p^3$, or $\frac{7}{2}p(1-p)+p^3$ — and $h$ is a tiny constant ($0$ or $-1$). Everything about the size of the numbers is squeezed into the single scalar $X = 8^b$, and it enters through the Möbius factor $\frac{X}{X-1} = 1 + \frac{1}{X-1}$.

From this the key lemma is three lines of algebra. Since
$$\frac{Xg+h}{X-1} - g = \frac{g+h}{X-1}$$
and $|g+h| \le 2$, we get, for $X \ge 8$,

$$\left|\frac{Xg+h}{X-1} - g\right| \;\le\; \frac{2}{X-1} \;\le\; \frac{3}{X}.$$

**Every ceiling in the ladder sits within $3/X = 3 \cdot 8^{-b}$ of a limit that does not know the size of the numbers at all.** Two different sizes therefore give ceilings differing by at most $3\cdot 8^{-b} + 3 \cdot 8^{-c}$.

Put in the numbers from the actual experiment — bitlen $48$ against bitlen $52$ — and the entire ladder, at every depth simultaneously, moves by less than
$$3 \cdot 8^{-47} + 3 \cdot 8^{-51} \;\approx\; 1.08 \times 10^{-42} \;<\; 10^{-40}.$$

That is not "small". That is smaller than anything a Monte Carlo experiment could ever resolve — smaller than the rounding error of the rounding error. The tie geometry of the dial is, for all experimental purposes, *frozen*.

## Confronting the measurement

Here is what was actually measured: six cells, two input sizes ($48$ and $52$ bits) crossed with three independent random seeds. For each cell, the dial's rank correlation, and for comparison the same experiment run with a bare quadratic-residue count as the response.

| bitlen | dial $\rho$ | bare count $\rho$ | advantage |
|---|---|---|---|
| 48 | 0.7192 | 0.5990 | +0.1202 |
| 48 | 0.7202 | 0.6005 | +0.1197 |
| 48 | 0.7198 | 0.5997 | +0.1201 |
| 52 | 0.7154 | 0.5760 | +0.1394 |
| 52 | 0.7169 | 0.5768 | +0.1401 |
| 52 | 0.7161 | 0.5756 | +0.1405 |

All six cells land inside the deployment band $[0.60, 0.85]$. The dial beats the bare count in every single cell, and the two mean advantages are exactly $+0.12$ and $+0.14$. The mean dial reading drifts from $0.719733$ at $48$ bits to $0.716133$ at $52$ bits — a drop of $0.0036$, or $0.0009$ per bit.

And now the theorem does its work. That drift of $0.0036$ is more than $10^{37}$ times the *entire* geometric budget of the ladder across the same interval. Whatever produced it, it was not the tie structure. It is sampling noise, and it is fully consistent with the seed-to-seed scatter visible within each row (about $0.001$).

This is the difference between an empirical claim and a structural one. "We looked at two sizes and the number barely moved" invites the reply "then look at ten more". "The quantity you are measuring is pinned to within $10^{-42}$ by the algebra of the tie profile" does not.

## No cliff — and no slow death either

Two failure modes haunt any scaling claim.

**The cliff.** Maybe at some larger size the dial simply collapses. The tie geometry forbids it: the top of the reported band, $0.85$, squares to $0.7225$, comfortably below $6/7 \approx 0.857$, and the dyadic ceiling *exceeds* $6/7$ at every size. Every value in the band is attainable at every input size. A collapse would have to come from somewhere else entirely — the arithmetic being sampled, not the instrument reading it.

**The slow decline.** Maybe the dial degrades gracefully, a little per bit, until it drops out of the band. Take the measured drop entirely at face value — pretend the $0.0009$-per-bit is real signal rather than noise — and extrapolate linearly. The predicted reading is $0.7053$ at $64$ bits, $0.6767$ at $96$ bits, $0.6477$ at $128$ bits, and $0.6189$ at $160$ bits: **still inside the band.** Even the pessimistic reading of the data keeps the instrument in service more than three times past its measured range.

## Why the dial beats the bare count, everywhere

The advantage over the bare quadratic-residue count is not a lucky calibration at one size. It is forced.

The experiment's relation rate is $p = 1/8$. Plug that into the coarse ceiling: the bitlen-free value is $\frac{7}{2}\cdot\frac{1}{8}\cdot\frac{7}{8} = \frac{49}{128} = 0.3828125$, and the shape lemma pins the true ceiling within $3\cdot 8^{-b}$ of it. So for any input size of six bits or more, **any** response that reports only a bare count is capped at $\rho^2 < 0.3829$, i.e. $\rho < 0.6188$.

Every recorded dial cell has $\rho^2 > 0.511$. Every recorded bare-count cell has $\rho^2 < 0.361$. The cap sits cleanly between them, at every input size. The gap between the two response classes is not a fitting artefact — it is a statement about how much information a single bit of output can carry, and no amount of scaling changes it.

## The axis that *does* move

A rigidity theorem is only interesting if something in the neighbourhood fails to be rigid. Otherwise you have proved that a thermometer immersed in a thermostat reads constant.

So: replace the base $2$ in the valuation by a general modulus $\ell$, grading the sample $\{0, \dots, \ell^b - 1\}$ by how many times $\ell$ divides each element. The blocks now have sizes $(\ell-1)\ell^{\,b-1-k}$, plus the singleton $\{0\}$. Running the same computation — the tie sum is again a geometric series, now in base $\ell^3$ — gives an exact closed form:

$$\rho^2_{\max}(\ell, b) \;=\; \frac{3\ell}{\ell^2+\ell+1}\left(1 + \frac{1}{x(x+1)}\right), \qquad x = \ell^{\,b}.$$

At $\ell = 2$ this is precisely the $6/7$ formula from before — a satisfying consistency check. But look at the prefactor as $\ell$ varies:

$$\ell = 2: \tfrac{6}{7} = 0.857, \qquad \ell = 3: \tfrac{9}{13} = 0.692, \qquad \ell = 4: \tfrac{4}{7} = 0.571, \qquad \ell = 5: \tfrac{15}{31} = 0.484, \qquad \ell \to \infty: 0.$$

It **decreases**, strictly and without bound. This is genuinely counterintuitive: a finer valuation grading has *more* classes, so surely it resolves more? No. The class $v = 0$ swallows the fraction $(\ell-1)/\ell$ of the entire sample — at $\ell = 11$ that is more than $90\%$ of everything in a single tie block — and since ties cost cubically, that one monstrous block overwhelms the benefit of the extra classes. Coarse-graining by a large modulus is nearly the same as not grading at all.

The consequence is a sharp arithmetic constraint pulled out of an empirical number. The recorded dial reading $0.7192$ corresponds to $\rho^2 = 0.5172$. At modulus $\ell \ge 5$ the entire ceiling is below $1/2$ — at *every* input size. **The measurement is therefore incompatible with any sampling modulus $\ell \ge 5$.** And the exclusion is sharp: $\ell = 2, 3, 4$ all clear the recorded value with room to spare.

So one axis of the construction moves the answer by less than $10^{-40}$, and its neighbour moves it by more than $0.16$ in a single step. The rigidity is a real theorem about the $2$-adic tie profile, not a vacuous artefact of the framework.

## What the shape of a formula tells you

The lesson generalises past this particular dial. When you ask whether a statistical instrument survives scaling, the instinct is to scale it and look. That is a measurement, and measurements return numbers with error bars, and error bars are exactly what makes "the value drifted by $0.0036$" ambiguous.

The alternative is to ask what *shape* the scaling dependence has. Here the answer was: it enters through one Möbius factor $1 + 1/(X-1)$, with $X$ growing like $8^{b}$ — so the dependence is not merely small, it is *geometrically* small, and it was already negligible at input sizes far below the ones anyone would use. Once you know the shape, no further scan is informative. A bitlen sweep of this dial past about five bits is a measurement of pure noise, and knowing that is worth more than the sweep.

The deeper reason is that the tie profile is a **fixed point under bit-extension**: adding a bit to the sample size reproduces the same staircase with one more step, rather than reshaping it. Any statistic whose ties are self-similar in this way will inherit the same rigidity. Any statistic whose ties are *not* — and there are plenty: the number of representations of $n$ as a sum of two squares, the count of Pythagorean legs, the divisor function — will not, and for those the honest expectation is a slow $1/b$ decline rather than a $8^{-b}$ freeze. Knowing which regime you are in is not a detail of the experiment. It is a property of the instrument, and it can be settled before the first sample is drawn.
