# Can Hints Compound Forever? The Arithmetic of Getting Smarter, One Clue at a Time

*Why "every extra clue is worth more than the last" and "every extra clue is worth less than the last" can each be true for a while, but never both forever.*

---

## A puzzle about puzzles

Imagine a detective who gets clues one at a time. The first clue barely helps. It narrows things down a little. The second clue is different: together with the first, it suddenly lights up the case, and it is worth far more than the first clue was on its own. The third clue still helps, but less dramatically.

This rise-then-fall pattern turns up in many places: in machine-learning models given extra features, in students given extra worked examples, in cryptanalysts given extra side channels. A recent experiment measured it precisely. It concerned an algorithm trying to learn a hidden label from arithmetic information about the two prime factors $p$ and $q$ of a number. The algorithm was given $k$ "hints", each one a piece of residue information about the factors. For each $k$ the experimenters measured how many **bits** of information about the label the hints carried:

| hints $k$ | hint value $V(k)$ (bits) | gain from the last hint |
|---|---|---|
| 0 | $0$ | — |
| 1 | $0.52$ | $+0.52$ |
| 2 | $2.43$ | $+1.91$ |
| 3 | $3.19$ | $+0.76$ |

The experimenters summed this up in a slogan: **hints compound, with diminishing returns.** "Compound" means that two hints together are worth more than the two hints counted separately; indeed $0.52 + 0.52 = 1.04$ is far less than $2.43$. "Diminishing returns" means that the gain from each additional hint is shrinking. From the second hint to the third, the gain fell from $1.91$ to $0.76$.

Each half of the slogan sounds reasonable, and the data seem to show both. This article explains a small but sharp piece of mathematics showing that, read as a *law* about how hint value grows, the two halves cannot both hold. It goes on to show which half has to give way, and why.

## Two words, made precise

To argue about a slogan, you first have to turn it into mathematics. Let $V(k)$ be the value, in bits, of having $k$ hints. We start from $V(0) = 0$, since no hints means no information.

**Compounding** is the property mathematicians call *superadditivity*:

$$V(m) + V(n) \le V(m+n) \quad \text{for all } m, n.$$

In words, a bundle of $m+n$ hints is worth at least as much as an $m$-bundle and an $n$-bundle counted separately. The whole is at least the sum of its parts.

**Diminishing returns** concerns the *marginal gain*, the value added by one more hint:

$$\Delta(k) = V(k+1) - V(k).$$

We say returns diminish from step $a$ onward if $\Delta(k+1) \le \Delta(k)$ for every $k \ge a$. From some point on, each new hint adds no more than the hint before it did.

Both definitions are entirely standard. Economists use superadditivity for synergy and diminishing marginal returns for saturation. The question is whether one curve can have both properties forever.

## The first surprise: the data are not even concave

Look at the marginal gains again: $0.52$, then $1.91$, then $0.76$. They go **up** before they come down. The curve accelerates and then decelerates. It is S-shaped, like a logistic growth curve or the adoption curve of a new technology. It is not a curve with "diminishing returns" in the textbook sense, because that would need the gains to shrink from the very first step.

So the honest reading of the experiment is narrower: the gains *start* diminishing from the second hint onward. That is the version we will test.

## The squeeze at the fourth hint

Here is the heart of the matter, and it uses nothing beyond addition. Suppose the curve keeps compounding, and suppose returns keep diminishing from $k = 2$ on. What must the fourth hint be worth?

- **Compounding says:** four hints are worth at least two bundles of two, so
  $$V(4) \ge V(2) + V(2) = 2.43 + 2.43 = 4.86.$$
- **Diminishing returns says:** the gain from the fourth hint is at most the gain from the third, so
  $$V(4) \le V(3) + 0.76 = 3.19 + 0.76 = 3.95.$$

No number is at least $4.86$ and also at most $3.95$. The slogan fails at the very next measurement anyone could take. However the experiment is continued, a fourth data point cannot satisfy both halves of the claim.

The gap is not small: $4.86 - 3.95 = 0.91$ bits. Measurement noise of a few hundredths of a bit cannot rescue it.

## The deeper reason: the compounding horizon

The squeeze at $k=4$ is a symptom of a general theorem that has nothing to do with these particular numbers. We will call it the **Compounding Horizon Theorem**.

> **Compounding Horizon Theorem.** Let $V$ be any compounding curve whose marginal gains are non-increasing from step $a$ onward. Then for every number of hints $b$ and every step $k \ge a$,
> $$V(b) \le b \cdot \Delta(k).$$
> In words: every marginal gain from step $a$ on is at least as large as **every average rate** $V(b)/b$ the curve has ever achieved.

Here is the intuition. Compounding means that if you once got $V(b)$ bits from $b$ hints, you can "copy" that achievement. With $2b$ hints you get at least $2V(b)$, with $3b$ hints at least $3V(b)$, and so on. Compounding locks in the average rate $V(b)/b$ for good: from then on, the curve climbs at least that steeply on average.

Diminishing returns works the other way. Once the gains stop growing, the curve can never rise above its own tangent line. If the gain at step $k$ is $\Delta(k)$, then $j$ more hints add at most $j \cdot \Delta(k)$.

Put the two together. If some marginal gain $\Delta(k)$ were *smaller* than an earlier average rate $V(b)/b$, the copies of $b$ would climb at slope $V(b)/b$, and the tangent line would climb at the smaller slope $\Delta(k)$. Far enough out, a line with the larger slope passes any line with the smaller slope, whatever the head start. The curve would have to sit above its own ceiling, which is impossible. So diminishing returns can only diminish *towards* a slope that compounding has already locked in. Gains can shrink, but never below the best average rate achieved so far.

For the experiment, the best average rate on record is $V(2)/2 = 2.43/2 = 1.215$ bits per hint. So if the curve compounds and its returns eventually diminish, every later marginal gain is at least $1.215$ bits. The third hint, however, gained only $0.76$. That is the contradiction, seen from far away instead of at $k=4$.

## When compounding and diminishing returns do coexist: the straight line

Is there any curve that both compounds and has diminishing returns from the very first hint? Yes, but only one kind. The theorem forces it to be a straight line:

> **Linearity Theorem.** If $V(0) = 0$, $V$ compounds, and its marginal gains never increase, then $V(k) = k \cdot V(1)$ for every $k$.

The proof is a two-line squeeze. Compounding gives $V(k) \ge k \cdot V(1)$, since $k$ copies of one hint are worth at least $k$ times one hint. Diminishing returns gives $V(k) \le k \cdot V(1)$, since no hint after the first is worth more than the first. So the two meet in the middle. A consequence is that compounding together with *strictly* diminishing returns, where each hint is worth strictly less than the one before, cannot happen at all. The two words only fit together in the dull case where every hint is worth exactly the same.

## Information has a ceiling, so compounding must end

There is a second, more physical reason the slogan cannot hold forever. Information about a label is finite. If the label is one of a handful of categories, the total information any set of hints can carry is at most the label's **entropy**, a fixed number of bits. Hint curves are bounded.

Bounded curves cannot compound upwards:

> **Bounded Collapse Theorem.** If a compounding curve satisfies $V(k) \le B$ for all $k$ and some fixed bound $B$, then $V(k) \le 0$ for every $k$.

The reason is the same copying argument. If some $V(a)$ were positive, then $V(2a) \ge 2V(a)$, $V(3a) \ge 3V(a)$, and so on without limit, eventually breaking any ceiling. A slightly stronger version handles slanted ceilings too. If $V(k) \le ck + b$ for all $k$, then in fact $V(k) \le ck$: a compounding curve can't hide behind the offset $b$. For the experimental data, where $V(2) = 2.43 > 2$, this shows that no compounding continuation of the curve can stay below *any* ceiling of one bit per hint plus a constant.

So any honest continuation of the experiment, one that respects the fact that information is finite, **cannot compound** over the long run. Of the slogan's two halves, compounding is the one that has to go. It can hold locally, over a few hints, but not as a law.

## Each half alone survives

It would be wrong to conclude that the data are inconsistent. They are not. Each half of the slogan, taken alone, can be continued forever:

- **Diminishing returns alone.** Continue the curve along its last tangent: $V(k) = 2.43 + 0.76\,(k-2)$ for $k \ge 2$. The marginal gains are $0.52, 1.91, 0.76, 0.76, 0.76, \dots$, non-increasing from the second hint on.
- **Compounding alone.** Keep the four data points and set $V(k) = k^2$ for $k \ge 4$. Checking superadditivity at every pair of indices takes some care, but it works: the four data points never exceed $k^2$, and $(m+n)^2 \ge m^2 + n^2$.

Four data points cannot settle the question. What settles it is outside knowledge: information is bounded, and that favours diminishing returns. A better slogan for the experiment is **"hints compound locally, saturate globally"**. The curve is an S-shape, not a law of perpetual synergy.

## Where the numbers come from: primes, residues and one orientation bit

The experiment behind the data had a specific structure, and that structure explains the shape of the curve.

The hidden label is attached to a number built from two prime "factors". The hints are pieces of the factors' residues, meaning their remainders in a finite number system modulo a prime. Three kinds of view matter:

- the **product view**, which reveals only the product of the two residues;
- the **sum dial**, which also reveals their sum;
- the **joint residue view**, which reveals both residues outright.

The value of the hints is the extra information about the label carried by the joint residue view beyond the product view. The first hint in this model is the sum dial, and the curve continues as $0$, then the sum-dial value, then the full joint value.

Three facts about this structure fit the earlier mathematics.

**1. The third hint is worthless.** Once you know both residues exactly, any further hint computed from those residues adds nothing. Its information is already contained in what you have. In the residue model the curve *saturates* at the second hint. It is monotone, it has diminishing returns from the first hint on, and it is bounded by the label entropy. By the Bounded Collapse Theorem, such a curve compounds *only if it is identically zero*. So the experiment's third-hint gain of $0.76$ bits cannot come from the residues themselves. Something outside the residue ring must be supplying it, perhaps a second modulus.

**2. One field allows a jump of at most one bit.** Knowing the product $pq$ and the sum $p+q$ of two residues pins the pair down to the two roots of the quadratic $x^2 - (p+q)x + pq$. The only thing left unknown is *which root is which*, an "orientation" that is worth at most one bit. So, working modulo a single odd prime, going from the sum-dial hint to the full residues can gain at most **1 bit**. The experiment's jump from $k=1$ to $k=2$ was $1.91$ bits, which is impossible over a single prime field.

**3. Several fields add one bit each.** If the arithmetic is done modulo several odd primes at once, there is an independent orientation bit for each prime. So with $k$ prime fields the jump is at most $k$ bits. Two fields give up to $2$ bits, which the observed $1.91$ fits under. The size of the jump says something about the structure of the experiment: the data are consistent with at least two independent prime "channels", and inconsistent with one.

## The moral

Slogans about scaling (returns diminish, effects compound, more is different) come with a quantifier hidden in them: *forever*, or *for a while*. Over a finite window the two can coexist, and the reported curve does compound over the measured window: $0.52 + 0.52 < 2.43$ and $0.52 + 2.43 < 3.19$. As soon as either property is claimed as a law, simple inequalities take over. Compounding copies the best average rate forward, diminishing returns traps the curve under its tangent, and a line with the larger slope eventually passes one with the smaller slope.

In this case one more measurement would have settled it. Whatever the fourth hint turns out to be worth, it will contradict one half of the slogan. Because information is bounded, the half that has to give way is compounding.
