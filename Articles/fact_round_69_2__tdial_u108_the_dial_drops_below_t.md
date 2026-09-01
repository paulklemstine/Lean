# When a Dial Falls Off the Band: The Geometry of a Fading Signal

## A number that stopped being good enough

Somewhere inside a long-running measurement program there is a quantity people call *the dial*. It is a simple statistic — call it $T$ — computed from a randomly drawn integer: how many trailing zeros the number has in binary, how a handful of small primes sit against it as quadratic residues, that sort of arithmetic fingerprint. Downstream, there is a second quantity, *the rate*, that the experiment actually cares about. The dial is useful exactly to the extent that $T$ predicts the rate.

"Useful" was given a number in advance. If the rank correlation between $T$ and the rate is at least $0.55$, the dial is *in the band*. Below $0.55$, it is not.

For years the dial was in the band. Then the experimenters started turning one knob: the *bit length* of the integers being drawn — $96$ bits, then $100$, then $104$, and on up. Each new bit length is a rung on a ladder, and each rung gets its own correlation:

$$
\begin{array}{c|ccccccc}
\text{bit length} & 96 & 100 & 104 & 108 & 112 & 116 & 120\\\hline
\rho & 0.5739 & 0.5436 & 0.5005 & 0.4880 & 0.4621 & 0.4847 & 0.43636
\end{array}
$$

The dial fades. That much was visible from rung two. What made the fourth rung — bit length $108$, correlation $0.4880$ — a genuine event is that its uncertainty interval, $[0.445, 0.534]$, lies *entirely* below $0.55$. Every earlier rung had error bars that still brushed the floor; you could squint and say "noise." At $108$ you cannot. The dial has, with certainty, left the band.

That is the empirical headline. But a single number with error bars is not mathematics. What is genuinely interesting about the $108$ rung is that three separate questions it raises turn out to have exact, provable answers — and that all three answers are geometry.

## Correlations are angles

Here is the idea that organises everything that follows.

Standardise your variables: subtract the mean, divide by the standard deviation. What is left is a vector of unit length in a space where the inner product of two vectors *is* their correlation. So a correlation of $\rho$ between two quantities is not a number floating free — it is the cosine of an angle:

$$\theta = \arccos \rho.$$

Perfect correlation is angle zero; independence is a right angle; perfect anticorrelation is $180°$. The dial, the count baseline it is being compared against, and the rate are three unit vectors, three points on a sphere, and everything measurable about them is the triangle they span.

Two consequences follow immediately, and both are theorems rather than metaphors.

**The band floor is a cap.** The requirement $\rho \geq 0.55$ says: the dial must lie inside the spherical cap of angular radius $\arccos(0.55) \approx 56.6°$ centred on the rate. At bit length $108$ the dial sits at $\arccos(0.488) \approx 60.8°$. It has walked out of the cap. "Losing the band" is not a statistical accident; it is a displacement on a sphere, and the fade is the dial's trajectory away from the rate.

**Angles obey the triangle inequality.** If $a$ is the correlation of the dial with the rate, $b$ that of the baseline with the rate, and $c$ that of dial with baseline, then

$$\arccos c \;\le\; \arccos a + \arccos b .$$

This is not an assumption imported from geometry. It is *equivalent in content* to the requirement that the three-by-three matrix of correlations be a legitimate correlation matrix — that it be positive semidefinite, which in the scalar form used here reads

$$1 + 2abc - a^2 - b^2 - c^2 \;\ge\; 0 .$$

Correlation data really is spherical data, and the triangle inequality is the price of consistency.

## Question one: how good is the certificate?

At bit length $108$ the dial correlates $0.488$ with the rate; the plain count baseline correlates $0.396$. The dial's *advantage* is $\delta = 0.092$, and its own uncertainty interval $[0.043, 0.139]$ excludes zero — the dial is genuinely doing something the baseline is not.

The programme had been converting such an advantage into a *decorrelation certificate*: if two predictors differ this much in explanatory power, they cannot themselves be too similar. The rule in use was

$$c \;\le\; 1 - \frac{\delta^2}{2}, \qquad \delta = a - b,$$

which at $108$ gives $c \le 0.995768$.

Positive semidefiniteness gives something better. Solving the Gram inequality above for $c$ yields directly

$$c \;\le\; ab + \sqrt{(1-a^2)(1-b^2)} ,$$

which is nothing but the cosine addition formula: the dial–baseline angle is at most the sum of the two angles to the rate. Numerically, at $108$, this reads $c \le 0.9949$ — a genuine improvement.

How much is being given up by the cruder rule? Exactly this much:

$$\Bigl(1 - \tfrac{(a-b)^2}{2}\Bigr) \;-\; \Bigl(ab + \sqrt{(1-a^2)(1-b^2)}\Bigr) \;=\; \frac{\bigl(\sqrt{1-a^2} - \sqrt{1-b^2}\bigr)^2}{2}.$$

That is an identity, valid for every $a, b \in [-1,1]$. The quantities $\sqrt{1-a^2}$ and $\sqrt{1-b^2}$ are the *residual lengths* — the parts of dial and baseline that the rate does not explain, the sines of the two angles. The gap between the two certificates is half the squared difference of those residual lengths, and it vanishes precisely when $a^2 = b^2$.

So the advantage rule is not a different method. It is the geometric bound with an arithmetic-mean–geometric-mean substitution baked in, and the loss is a perfect square. Since the gap is a square, it is never negative: the geometric bound always wins. And since it is *strictly* positive whenever $a^2 \ne b^2$, the geometric bound wins *strictly* in exactly the regime the experiment lives in — the regime where the dial and the baseline have measurably different strength, which is what "advantage $+0.092$, interval excluding zero" certifies.

There is a limit form too. If the ladder settles — the dial correlation tending to $A$, the baseline to $B$, their mutual correlation to $C$ — and every rung is a legitimate correlation matrix, then the limiting values inherit the certificate: $C \le 1 - (A-B)^2/2$. A permanent advantage is a permanent guarantee of non-redundancy. At the conservative edge of the measured advantage, $\delta \ge 0.043$, that says $C \le 0.9990755$ forever.

## Question two: where does the fade stop?

The step into $108$ was $-0.0125$. The two before it were $-0.0303$ and $-0.0431$. The fade is *decelerating*, and the natural reading is that the dial is settling onto a plateau near $0.48$ rather than sliding to zero.

Can that reading be made into a theorem? Suppose only this: the sequence of correlations is non-increasing, and each step is at most $r$ times the previous one for some contraction factor $r < 1$. Then the total remaining drop from any rung is controlled by the *current* step alone:

$$s_n - s_{n+m} \;\le\; \frac{d_n}{1-r}, \qquad d_n = s_n - s_{n+1},$$

by summing the geometric series. A bounded monotone sequence converges, so there is a plateau $L$, and it is sandwiched:

$$L \;\le\; s_n \;\le\; L + \frac{d_n}{1-r}.$$

One rung and one contraction bound localise the endpoint of an infinite process. Feeding in the measured $s_0 = 0.488$ at bit length $108$, $s_1 = 0.4621$ at $112$, and the conservative $r \le 1/2$: the plateau lies in

$$0.4362 \;\le\; L \;\le\; 0.488 .$$

The whole window sits at least $0.062$ below the band floor. For every model in this class, the band loss is not a dip — it is permanent.

Two follow-up facts sharpen this from a bound into an exact answer.

First, the window is *tight*, and it can be tightened. The explicit geometric fade
$$s_n \;=\; \Bigl(s_0 - \frac{d_0}{1-r}\Bigr) + \frac{d_0}{1-r}\,r^n$$
is non-increasing, contracts with ratio exactly $r$, matches both measured values, and converges to exactly the lower edge $0.4362$. So no better lower bound is derivable from the data given. At the other end, the upper edge $0.488$ is *not* attainable: the first step already costs $d_0$, so the plateau can be no larger than $s_1 = 0.4621$. Putting the two together gives the exact answer to "what plateaus are consistent with this data?":

> The attainable plateaus of a fade with initial value $s_0$, initial step $d_0 > 0$ and contraction ratio at most $r$ are precisely the points of the closed interval $\bigl[s_0 - \tfrac{d_0}{1-r},\; s_0 - d_0\bigr]$.

Every point of that interval is realised by an explicit fade, and nothing outside it is. At bit length $108$ this is the interval $[0.4362, 0.4621]$, of length $0.0259$ — and its length is exactly the step $d_0$ times $r/(1-r)$. One rung plus a ratio bound *cannot* pin down the plateau; a second ratio measurement is mathematically required.

Second, the forecast was scored. The rungs at bit lengths $116$ and $120$ were measured *after* the window was licensed. Both, $0.4847$ and $0.43636$, land inside $[0.4362, 0.488]$ — and $0.43636$ clears the lower edge by $0.00016$. The prediction was tight rather than vacuous.

And here is the honest boundary, stated as bluntly as it deserves: the measured seven-rung ladder is **not** monotone. The rung at $116$ rebounds above the rung at $112$. So the deceleration hypothesis is not a claim about the raw ladder — it is a claim about the fade *component*, with the rebound as residual. That rebound also escapes the narrowed window $[0.4362, 0.4621]$, which is exactly how one should expect a non-monotone excursion to show up.

## Question three: can heterogeneity rescue the band?

The $108$ rung was the first whose three independent runs disagreed noticeably. That raises a deflationary possibility: perhaps the sub-floor pooled number is a *pooling artefact*, and honest aggregation would put the dial back in the band.

The standard way to average correlations is not to average them. One first applies Fisher's transform $z = \operatorname{artanh}\rho$, averages there, and maps back with $\tanh$. And this is where the physics is hiding: $\operatorname{artanh}$ is exactly the map from velocity to *rapidity* in special relativity. Correlations compose the way collinear velocities do:

$$\tanh\bigl(\operatorname{artanh} x + \operatorname{artanh} y\bigr) \;=\; \frac{x+y}{1+xy}.$$

That is the Einstein velocity-addition formula, letter for letter, with the speed of light set to one. Fisher's $z$ *is* rapidity; the interval $(-1,1)$ of admissible correlations is the interval of admissible velocities; and composition never escapes it — there is no superluminal correlation. Under this operation correlations form an abelian group, isomorphic to the additive reals via rapidity, with $0$ as identity and $-\rho$ as inverse.

Now the pooling question. Because $\tanh$ is concave on $[0,\infty)$ — an assertion that follows from the exact hyperbolic identity $\cosh(m+d)\cosh(m-d) = \cosh^2 m + \sinh^2 d$, the surplus $\sinh^2 d$ being precisely the effect of spreading — Fisher pooling of nonnegative seed correlations is *at least* their arithmetic mean, strictly so as soon as the seeds actually disagree. Heterogeneity **inflates** the pooled estimate. The bias runs in the optimistic direction, in favour of the band.

But pooling can never exceed the largest seed, because the rapidity mean cannot exceed the largest rapidity and $\tanh$ is increasing. And so:

> If every seed correlation is below $0.55$, the pooled value is below $0.55$.

The pooling-artefact escape is closed. Even with the bias pushing upward, disagreement between runs cannot manufacture a value back inside the band unless some individual run was already there.

One caveat, and it is a sharp one: this is a statement about *averaging* rapidities, not about *composing* them. Composition is a different operation, and it can cross the floor — two correlations of $0.4$, each comfortably sub-floor, compose to $0.8/1.16 \approx 0.690$, above the band floor, while their Fisher average is exactly $0.4$. Aggregation preserves the floor; boosting does not.

## Can you build a good dial out of bad ones?

The natural last move: if one dial is below the floor, ensemble several. The geometry answers in advance. Suppose $k$ unit dials each correlate at least $\rho \ge 0$ with the rate and are pairwise nearly orthogonal, with mutual correlations at most $c < \rho^2$. Compare the length of their sum with its projection onto the rate — the projection is at least $k\rho$, while the squared length is at most $k\bigl(kc + (1-c)\bigr)$ — and the Cauchy–Schwarz inequality forces

$$k \;\le\; \frac{1-c}{\rho^2 - c}.$$

This is a packing bound: dials at a fixed angle from the rate live in a spherical cap, and you cannot fit unboundedly many near-orthogonal directions into a cap. At the band floor $\rho = 0.55$ with genuinely weak pairwise alignment $c \le 0.1$, the bound gives $k \le 4.44$, hence **at most four dials**. The ensemble strategy is capacity limited before you write a line of code.

## What the rung means

Strip away the apparatus and the fourth rung of this ladder says three things, each of them exact.

The advantage rule that the programme had been using to certify that the dial is not a repackaged baseline is an arithmetic-mean–geometric-mean shadow of a sharper spherical bound, and the shadow costs exactly half the squared difference of the two residual lengths. The deceleration in the fade is not an impression: it localises the endpoint to an interval that is now known exactly, and the two rungs measured afterwards fell inside the interval, one of them by a whisker. And the disagreement between runs, far from explaining the band loss away, is provably incapable of doing so — pooling is optimistic but bounded by its best seed.

The dial has left the band, and it is not coming back. Geometry says so.
