# When Probability Goes Tropical: Rare Events in the Max-Plus World

## A different kind of arithmetic

Ask a child to add two numbers and they will reach for the familiar operation: $2 + 3 = 5$. But there is another arithmetic, just as consistent and far older in spirit than it looks, in which "adding" two numbers means *taking the larger one*, and "multiplying" means ordinary addition. In this world,

$$a \oplus b = \max(a, b), \qquad a \otimes b = a + b.$$

This is the **max-plus semiring**, the backbone of *tropical mathematics*. It sounds like a curiosity, but it is the native language of optimization, scheduling, shortest-path algorithms, and — as we will see — of *rare events*.

Why rare events? Because the mathematics of extremely unlikely outcomes has a secret tropical heart. When a probability is astronomically small, what matters is not its precise value but its *exponential rate of decay*. And once you start taking logarithms of exponentials, ordinary sums turn into maxima, and products turn into sums. The probabilistic world quietly dequantizes into the tropical one. This article is about making that dictionary precise — and about a sharp, surprising place where it breaks.

## The exponential fog of large deviations

Classical probability theory has a celebrated chapter called the **theory of large deviations**. Its guiding intuition is simple to state. Suppose you average many independent random quantities. The average concentrates near its mean — that is the law of large numbers. But occasionally, against all odds, the average wanders far from where it should be. How unlikely is such an excursion?

The answer, due to Harald Cramér and his successors, is that the probability of seeing the average land near a forbidden value $x$ decays exponentially:

$$P(\text{average} \approx x) \approx e^{-n\, I(x)},$$

where $n$ is the number of samples and $I(x) \ge 0$ is the **rate function**, the "cost" of the deviation. The larger $I(x)$, the more violently improbable the excursion. The rate function is the hero of the story, and Cramér's theorem tells us exactly how to compute it: it is the **Legendre–Fenchel transform** of the cumulant generating function, the log-of-the-exponential-average that encodes all the moments of the distribution.

Now strip away the $e$ and the $\log$. Replace "probability $e^{-nI(x)}$" with "tropical weight $-I(x)$." Replace "average of exponentials" with "maximum." What remains is a fully self-contained probability theory living entirely in the max-plus world — Maslov's *idempotent probability*. The exponential fog lifts, and the skeleton of large-deviation theory stands revealed in clean, finite, combinatorial form.

## Idempotent probability in one paragraph

Here is the entire setup. Fix a finite set of outcomes $X$. A **max-plus measure** assigns to each outcome $x$ a real **weight** $w(x)$. We call it a **tropical probability measure** when the weights are all $\le 0$ and the largest of them is exactly $0$:

$$w(x) \le 0 \text{ for all } x, \qquad \max_{x} w(x) = 0.$$

The first condition is the analogue of "probabilities are at most one"; the second is the analogue of "the total probability is one" — except that "total" now means *maximum*, because in the tropical world summation is maximization. The **rate function** is simply the negated weight,

$$I(x) = -w(x) \ge 0,$$

so the most likely outcomes (weight $0$) cost nothing, and rarer outcomes (very negative weight) cost a lot. This is precisely the role $-\tfrac{1}{n}\log P$ plays classically.

To "integrate" an observable $f : X \to \mathbb{R}$ against such a measure, you compute the **max-plus integral**

$$\textstyle\int^{\!+} f \, d\mu = \max_{x}\big(f(x) + w(x)\big).$$

Maxima where there were sums; sums where there were products. Everything else follows.

## The tropical Cramér dictionary

With these definitions, the classical large-deviation machinery transcribes line by line. The **cumulant generating function** — classically $\tfrac{1}{n}\log \mathbb{E}[e^{\lambda S_n}]$ — becomes the idempotent

$$\Lambda(\lambda) = \int^{\!+} \big(\lambda \cdot \mathrm{val}\big)\, dP = \max_{x}\big(\lambda\, \mathrm{val}(x) + w(x)\big),$$

where $\mathrm{val} : X \to \mathbb{R}$ is the observable whose deviations we study. This $\Lambda$ is **convex** in $\lambda$ — it is a maximum of straight lines, and a maximum of lines is always convex.

Independence transcribes too. Classically, the moment generating function of a sum of independent variables factorizes; in logarithmic form, cumulant generating functions *add*. Tropically, the analogue is exact: for an independent product of measures with an additive observable,

$$\Lambda_{X+Y}(\lambda) = \Lambda_X(\lambda) + \Lambda_Y(\lambda).$$

Iterating this gives the cumulant generating function of an **$n$-step max-plus random walk** with no error term whatsoever:

$$\Lambda_{S_n}(\lambda) = n\, \Lambda(\lambda).$$

In classical probability this identity holds only in the limit, smeared by correction terms. Tropically it holds *exactly, for every finite $n$*. The idempotent world is the asymptotic limit made flesh.

From here, a **tropical Chernoff bound** drops out, and with it the sharp idempotent large-deviation principle: the cost of any event $A$ is exactly the cheapest deviation inside it,

$$P(A) = -\inf_{x \in A} I(x),$$

again with no asymptotics — an equality, at every scale.

## The Legendre–Fenchel transform, tropically

The deepest part of Cramér's theorem is the claim that the rate function $I$ is the Legendre–Fenchel transform of $\Lambda$. The transform turns a function into its "best linear lower bounds" and back again. Applied twice — the **biconjugate** — it returns not the original function but its *convex lower envelope*: the largest convex function sitting beneath it. For the biconjugate,

$$\Lambda^{**}(v) = \sup_{\lambda}\big(\lambda v - \Lambda(\lambda)\big),$$

one direction of Cramér's theorem is unconditional and easy: the biconjugate never overshoots the rate function,

$$\Lambda^{**}(\mathrm{val}(x)) \le I(x).$$

This is the tropical Fenchel–Young inequality, and it holds for *every* idempotent law. The temptation — and this is exactly the temptation a careful skeptic should resist — is to believe the inequality is secretly always an equality, that the double transform always recovers the rate function on the nose. If true, this would make the whole convexity discussion vacuous.

It is not true. And the place it fails is the heart of this article.

## A spike that the transform cannot see

Consider the smallest interesting example: three outcomes, labeled by their values $\mathrm{val} = (0, 1, 2)$. Put weight $-2$ on the middle outcome and weight $0$ on the two ends:

$$w = (0,\, -2,\, 0), \qquad I = (0,\, 2,\, 0).$$

This is a genuine tropical probability — its weights are all $\le 0$ and its maximum weight is $0$. Its rate function is a **spike**: the cost of landing at the middle value is $2$, while the two flanking values cost nothing. Crucially, this rate function is **non-convex**. The middle point sits at the midpoint of the two ends, so a convex function there could be no higher than the average of the endpoint costs, namely $(0+0)/2 = 0$. Our spike towers a full $2$ units above that chord.

Now compute the cumulant generating function. With values $(0,1,2)$ and weights $(0,-2,0)$,

$$\Lambda(\lambda) = \max\big(0,\; \lambda - 2,\; 2\lambda\big).$$

Here is the decisive observation. For *every* slope $\lambda$, the line $y = \lambda$ lies below $\Lambda(\lambda)$:

$$\lambda \le \Lambda(\lambda) \quad \text{for all } \lambda.$$

(If $\lambda \ge 0$, then $\lambda \le 2\lambda \le \Lambda(\lambda)$; if $\lambda < 0$, then $\lambda < 0 \le \Lambda(\lambda)$.) Consequently $\lambda - \Lambda(\lambda) \le 0$ for every $\lambda$, with equality at $\lambda = 0$. The biconjugate at the middle value is therefore

$$\Lambda^{**}(1) = \sup_{\lambda}\big(\lambda \cdot 1 - \Lambda(\lambda)\big) = 0.$$

The double Legendre–Fenchel transform reports a cost of **zero** at the very point where the true rate function charges **two**. The transform has flattened the spike down to its chord, exactly as a convex envelope must:

$$\Lambda^{**}(1) = 0 \;<\; 2 = I(1).$$

The **duality gap** is precisely

$$I(1) - \Lambda^{**}(1) = 2,$$

equal to the full height of the spike above its chord. There is no supporting line that can reach the tip of a spike, because a spike is concave there, and the Legendre–Fenchel machinery only ever sees convex shadows.

## Why this matters

This little counterexample is not a defect; it is the *sharpening* of the theorem. It pins down the exact boundary of Cramér's theorem in the idempotent world:

> **The double Legendre–Fenchel transform recovers the idempotent rate function if and only if that rate function equals its own convex lower envelope.**

The unconditional inequality $\Lambda^{**} \le I$ is therefore genuinely an inequality — it can be strict — and the supporting-line hypothesis that upgrades it to equality is genuinely necessary, not a technical decoration. Convexity is the precise dividing line between the case where moments determine deviations and the case where they cannot.

There is a broader lesson here, one that recurs throughout the tropical reimagining of analysis. Many classical theorems are, at heart, statements about convex duality wearing an exponential disguise. When you dequantize — strip off the $\exp$ and the $\log$ — the convexity stands exposed, and you see at once both why the theorem is true and exactly when it must fail. The classical Cramér theorem hides its convexity assumption inside the smoothing power of the exponential; the tropical version cannot hide anything. A non-convex rate function produces a visible, measurable, provable gap of exactly the height of its tallest spike.

## The view from the summit

Tropical mathematics began as a tool for counting solutions and routing trains. Maslov's idempotent calculus revealed it as a shadow world cast by classical analysis under the bright light of the exponential. What we have sketched here is one room of that shadow world: a complete, finite, exact theory of large deviations, where cumulant generating functions are convex maxima of lines, where independence makes them add, where random walks scale them linearly with no error, and where the cost of any rare event is simply the cheapest way to achieve it.

And then, at the center of the room, the spike — a three-point measure whose rare middle outcome is invisible to the Legendre–Fenchel transform, betraying a duality gap of exactly $2$. It is a small object with a large message: in probability as in geometry, convexity is not a convenience. It is the dividing line between what duality can see and what it cannot.
