# The Honest Negative: When a Failed Experiment Becomes a Theorem

## A criterion that would have been worth a lot

Primes are supposed to spread themselves evenly among the residue classes that can hold them. Fix a modulus $m$ and count how many primes below $x$ land in each admissible class $a \bmod m$. If the primes are as evenhanded as we believe, each of the $\varphi(m)$ admissible classes should receive about
$$E = \frac{\pi(x)}{\varphi(m)}$$
primes, where $\pi(x)$ is the total count of primes up to $x$ and $\varphi$ is Euler's totient function. Reality never matches the ideal exactly. The interesting question is always: *by how much does it miss, and is the miss structured or accidental?*

There is a family of deep arguments in analytic number theory — arguments about how well primes can be controlled in arithmetic progressions — that depend on an averaging assumption. Informally, the assumption says that when you average a quantity over many moduli, you may treat the moduli as interchangeable: the argument is allowed to be *blind to which factor* it is looking at, and this blindness costs nothing. Call this the **averaging assumption**. It is used as an axiom. Nobody knows how to prove it at the scales where it matters, and the honest bookkeeping of the field lists it as an open gap.

There is a weaker prize than proving it, and it would still be valuable: an **effectivity criterion**. That would be a *computable* test you could apply to a single modulus $m$ and get back a verdict — "for this modulus, the averaging assumption is realized" or "for this one, it isn't." You could then run the test over a range of moduli and know exactly where you stand, instead of assuming.

What would such a test be built from? The natural candidate comes from a hundred and fifty years of number theory. Attached to each modulus $m$ are the real (quadratic) Dirichlet characters $\chi$ modulo $m$, and to each character an $L$-value $L(1,\chi)$. These numbers are not decorative. Since Dirichlet they have been the pivot on which the distribution of primes in progressions turns: a small $L(1,\chi)$ signals an exceptional character, an exceptional character signals a possible conspiracy among the primes, and the classical error terms in the prime-counting theorems for progressions are written in terms of exactly these quantities. So the hypothesis practically writes itself:

> **If the deviation of primes from equidistribution is governed by quadratic-character $L$-values, then the total quadratic-character $L$-mass**
> $$P(m) = \sum_{\chi} |L(1,\chi)| \qquad (\chi \text{ real, nontrivial, mod } m)$$
> **should predict how badly a given modulus misbehaves — and a criterion exists.**

That is a testable claim, and the honest way to test it is to say in advance what will count as a success and what will count as a failure. So the terms were fixed before any data were seen. Take the per-modulus deviation
$$D(m) = \max_{a} \frac{|\pi(x;m,a) - E|}{\sqrt{E}},$$
the largest normalized shortfall or surplus over the admissible classes, with a secondary chi-squared readout $\chi^2(m) = \sum_a (\pi(x;m,a)-E)^2/E$. Regress $\log D$ on $\log P$ across a sweep of moduli. If the fit explains more than $80\%$ of the variance, the criterion is armed. If it explains less than $50\%$, the answer is no, and you say so.

## The answer was no

At $x = 2^{26}$ — that is, $3{,}957{,}809$ primes distributed across $287$ moduli — the fit explained $R^2 = 0.0187$ of the variance. Not $0.8$. Not $0.5$. Under two percent. Worse for the hypothesis, the fitted slope was *negative*, $-0.0767$ with a $95\%$ interval of $(-0.136,\,-0.015)$: to the extent that there is any trend at all, more $L$-mass goes with *less* deviation, which is the opposite of the story the criterion was supposed to tell.

Scaling up did not rescue it. At $x = 2^{28}$, with $14{,}630{,}843$ primes and $2489$ moduli, the fit reached $R^2 = 0.0785$ — still a null by the pre-registered rule. A finer, cell-level version of the analysis, running over $1902$ discriminant cells and using the theory-preferred signed direction, gave $R^2 = 0.00052$ with a slope of $-0.034$ whose confidence interval $[-0.101, +0.033]$ straddles zero.

And then the deflating control. Regress the same deviation readout on nothing but $\log m$ — on the *size* of the modulus, a quantity carrying no arithmetic information whatsoever — and you explain $R^2 = 0.790$ of the variance. The deviation field is size-dominated. Once you know how big the modulus is, knowing its $L$-mass tells you essentially nothing more.

So the magnitude route to an effectivity criterion is closed, at this scale. The averaging assumption stays an axiom.

## Why "no" is not the end of the story

Here is where the work becomes interesting rather than merely disappointing. A number like $R^2 = 0.0785$ is a *statistic*. It is not a theorem. It reports what one particular regression did on one particular sample. On its own, it does not forbid anyone from building a cleverer criterion — a nonlinear one, a threshold rule, a partition of the moduli into a dozen classes — out of the very same feature.

Or does it? The central insight of this work is that a null $R^2$, correctly interpreted, is a **hard geometric constraint on every possible criterion** built from that feature. Not a weak Bayesian nudge. A bound, with a constant, that no decision rule can escape.

The pivot is a very old identity, the analysis of variance. Take any feature $P$ and split the sample into its **level sets** — the groups of moduli sharing a common value of $P$. Then the total spread of the response splits exactly in two:
$$\mathrm{TSS} = \underbrace{\text{(spread within the level sets)}}_{\text{invisible to any function of } P} + \underbrace{\text{(spread between the level sets)}}_{\text{all that } P \text{ can ever explain}}.$$
The second piece is *exactly* the explained energy of the class of **all** functions of $P$ — every one of them, linear, monotone, wildly nonlinear, tabulated by hand. If your recorded $R^2$ for that whole class is at most $\rho$, then the between-level-set energy is at most $\rho \cdot \mathrm{TSS}$, full stop. There is no cleverness budget left over.

From that single fact everything follows by elementary algebra. Suppose someone proposes a **threshold criterion**: pick a cutoff $t$, declare the moduli with $P(m) \geq t$ "effective" and the rest "ineffective," and claim that the two groups really do have different deviation behavior — say the high group all sits at $\mu + \delta$ or above and the low group at $\mu - \delta$ or below, so that $2\delta$ is the criterion's separating margin. Then a two-line computation shows that this criterion must generate explained variance at least
$$\frac{4\delta^2 n_1 n_2}{n}$$
where $n_1, n_2$ are the group sizes and $n = n_1 + n_2$. Contrapositively — and this is the theorem that turns the null into a certificate — **if the recorded ceiling is $R^2 \le \rho$, then every threshold criterion whatsoever obeys**
$$\frac{4\delta^2 n_1 n_2}{n} \le \rho \cdot \mathrm{TSS}.$$
For a balanced split this collapses to the quotable form $\delta^2 n \le \rho \cdot \mathrm{TSS}$; with $\rho = 0.0785$ that is
$$\delta \le \sqrt{0.0785} \approx 0.28 \text{ sample standard deviations}.$$
A quarter of a standard deviation. That is the entire separating power available to any threshold rule built from quadratic-character $L$-mass on this data. Not "we failed to find one" — *there isn't one*.

## Closing the escape routes

A skeptic has two natural objections, and both were closed.

**"Why should a criterion be a threshold?"** It needn't be. A rule may read the feature at arbitrary resolution and treat every level set separately. So the theorem was generalized. For *any* two level sets, of sizes $n_a$ and $n_b$, the ceiling forces their response means apart by at most
$$(m_a - m_b)^2 \le \rho \cdot \mathrm{TSS}\left(\frac{1}{n_a} + \frac{1}{n_b}\right).$$
And for *any* weighted combination of level-set means at all — any **contrast** $\sum_c w_c (m_c - m)$ — a Cauchy–Schwarz argument gives
$$\Big(\sum_c w_c (m_c - m)\Big)^2 \le \rho \cdot \mathrm{TSS} \sum_c \frac{w_c^2}{n_c}.$$
Setting $w = (+1,-1)$ on a pair recovers the two-cell bound; setting $w_c = \pm n_c / N$ on two *groups* of cells gives the form an actual decision rule takes: any rule that reads the $L$-mass and sorts the moduli into an "effective" pile and a "not effective" pile separates the two piles' mean deviations by at most $\rho \cdot \mathrm{TSS}(1/N_A + 1/N_B)$ in square.

One might hope that the constant here is lazy — that a criterion using three or four or twenty cells has extra hiding room inside a small $R^2$. It does not. The inequality is **exactly attained**: for a response that happens to be a function of the feature, the weights $w_c = n_c(m_c - m)$ — a genuine contrast, since they sum to zero — turn Cauchy–Schwarz into an equality with $\rho = R^2 = 1$, for any number of cells. The pairwise constant was already optimal. There is no deficiency to exploit at any resolution.

**"Isn't $R^2 = 0.79$ for $\log m$ impressive in its own right?"** No, and this too is a theorem rather than an intuition. If the centered response decomposes as $\tilde y = b\tilde x + r$ with residual energy at most $\eta$, and the feature's own centered spread beats the residual in the sense $2\eta < b^2\|\tilde x\|^2$, then the affine class in that single feature already explains at least
$$1 - \frac{\eta}{b^2\|\tilde x\|^2/2 - \eta}$$
of the variance. Mere near-affinity in a size covariate is *sufficient* to produce a high $R^2$. Since $\sqrt{E}$-normalized deviations grow with $\varphi(m)$ for elementary reasons, the $0.790$ baseline is exactly what near-affinity in size predicts — and carries no arithmetic content at all. Put together with the ceiling, one gets a clean dichotomy: the criterion route is capped at $\rho$, and as soon as the size bound exceeds $\rho$, the single dumb size covariate **strictly outperforms the entire, arbitrarily nonlinear class of functions of the $L$-mass**.

## Two things the experiment got wrong about itself, proved

Any careful experiment keeps a ledger of its own defects. Two entries in this one turned out to be not statistical complaints but mathematical facts.

**The control had power exactly zero.** The registered safeguard was a within-modulus permutation test: shuffle the residue-class counts of a modulus and see whether the readout drops. But look at the readouts. $D(m)$ is a maximum over classes; $\chi^2(m)$ is a sum over classes. Both are *symmetric functions of the counts* — relabeling the classes cannot change them. Therefore the permutation $p$-value is not "large," it is **identically $1$, for every count field, whatever the arithmetic**. The control could never have rejected anything. Its power is zero as a matter of algebra.

There is a repair, and it has provable power. Instead of shuffling, *perturb*: replace the count field $c$ by $c + t\,w$ for a direction $w$ that is nonzero somewhere. Then the chi-squared readout becomes the explicit quadratic
$$\chi^2(c + tw) = \chi^2(c) + \frac{2t\langle c - E, w\rangle + t^2\|w\|^2}{E},$$
and the symmetric pair $c \pm tw$ satisfies the exact identity
$$\chi^2(c+tw) + \chi^2(c-tw) = 2\chi^2(c) + \frac{2t^2\|w\|^2}{E}.$$
Because the excess term is strictly positive, at least one of the two perturbations beats the observed readout **at every nonzero amplitude** — no threshold needed. For the maximum-deviation readout the amplitude profile is a *convex* function of $t$, so the acceptance region is an interval with no gaps, and again the symmetric pair dominates. Best of all, the two-point $p$-value of the chi-squared readout is exactly $1/2$ whenever the amplitude is below $2|\langle c-E,w\rangle|/\|w\|^2$: one perturbation raises the statistic, the other lowers it. Compare: relabeling gives $p \equiv 1$ and no information; the additive control gives $p = 1/2$ and strictly informative structure.

**The whole sweep is blind to sign.** This is the caveat that should be pinned above the result, and it is the most delicate point of the paper. The readouts $D$ and $\chi^2$ measure *magnitude*; the predictor $P(m)$ sums *absolute values* $|L(1,\chi)|$. Nowhere does a sign appear. But the quantity the theory really cares about is the **signed alignment** of the deviation field with the character,
$$\langle c, \chi\rangle = \sum_a c(a)\,\chi(a),$$
which is a fundamentally finer instrument.

How much finer? Exactly this much. For a prime $p \equiv 3 \pmod 4$ the quadratic character is *odd*: $\chi(-a) = -\chi(a)$. So reflecting a count field through $a \mapsto -a$ flips the sign of its alignment while — because reflection is just a relabeling — leaving every symmetric readout untouched. Take the character-tilted field $c(a) = E + \chi(a)$. Its alignment with $\chi$ is $\sum_a \chi(a)^2 = p - 1$, the maximum possible. Its reflection has alignment $-(p-1)$. The two fields have **identical** $D$ and **identical** $\chi^2$.

Lift this to the whole sweep and the conclusion is stark: given any prescribed pattern of signs you like — one bit per modulus, chosen adversarially — there is a sample of count fields realizing that exact pattern of maximal alignments $\pm(p-1)$ whose recorded response vector, and hence whose fitted $R^2$ *in every model class whatsoever*, is identical to the unreflected sample's. The magnitude sweep therefore constrains the signed route **not at all**. Every sign pattern fits the same data equally well.

## What was actually established

The verdict, stated honestly at each layer:

- The magnitude route to a computable effectivity criterion for the averaging assumption is closed at toy scale — and closed by a *bound*, not a failure to find. Any criterion reading quadratic-character $L$-mass, at any resolution, with any decision rule, separates the deviation field by at most $\sqrt{0.0785} \approx 0.28$ standard deviations on a balanced split.
- The observed explanatory power of the sweep lives in modulus size, and a theorem explains why that requires no arithmetic.
- The pre-registered permutation control was provably vacuous; a provably non-vacuous replacement now exists with an exact $p$-value of $1/2$.
- The signed character-alignment route is untouched. Not "probably fine" — *formally unconstrained*, since every sign pattern is compatible with the recorded data.
- The computational path checks out against exact theory: the class-number formula gives $L(1,\chi_{-3}) = \pi/(3\sqrt3)$ exactly, and the truncated series used at scale matched it and $225$ other exactly-computable discriminants to a median relative error of $1.8 \times 10^{-5}$.

The averaging assumption stays axiomatic. Effectivity stays open. But the open gap is now *smaller and better mapped*: one route bounded with an explicit constant, one route proved untouched, and a broken control replaced by a working one.

There is a general lesson in the shape of this. A negative experimental result is usually treated as an absence — nothing to report, filed away. The move made here is to refuse that framing: to take the disappointing number and ask what it *logically entails*, then prove the entailment. What comes out is not "we looked and found nothing," but "here is the exact size of the region we have swept clean, and here is the region still to sweep." That is a contribution a positive result cannot make, and it is reusable: the ANOVA ceiling, the contrast inequality, the size-domination bound, and the vacuous-control diagnosis apply verbatim to any pre-registered regression sweep in any field. Everyone who has ever reported a small $R^2$ has, without knowing it, proved a theorem. It is worth writing it down.
