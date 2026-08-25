# The Number That Wasn't Universal

## How a single exact identity rescued a family of speedup claims — and quietly corrected a published table

### A promise made in a footnote

Every engineer who has ever built a search index has made the same bet. You have $M$ things to look through. You suspect the thing you want is usually near the front. So you carve off a *stratum* — the first $\mu M$ items, say the hottest 5% — and you look there first. If you are lucky, you paid $\mu M$ probes instead of $M$. If you are unlucky, you paid for the rest too.

The bet has a number attached. If the target lands inside your chosen stratum with probability $P$, and you must commit to a whole block before probing it, then your expected cost is

$$\mathrm{EC}(\mu,P) \;=\; M\big(\mu P + (1-\mu)(1-P)\big),$$

and, measured against the brute-force cost of scanning all $M$ slots, your *value* — your speedup — is

$$S(\mu, P) \;=\; \frac{1}{\mu P + (1-\mu)(1-P)}.$$

Put in $\mu = 0.05$ and $P = 0.85$ and out comes $S = 200/37 = 5.4054\ldots$: a five-fold win from looking in the right twentieth of the data. This little formula is seductive. It is closed-form, it is symmetric, it fits in a footnote, and it appears in tables of anchors — pairs $(\mu, \hat P)$ measured on real workloads, each with its promised speedup printed alongside.

This article is about what happens when you take that footnote seriously and ask, with full rigour, three questions:

1. Is the formula *true*?
2. Is it *universal* — does it hold for every workload, or only for the ones it was derived on?
3. What exactly is it a promise *against*?

The answers, in order, are: yes but only as an identity in disguise; **no**, and the failure is unbounded; and **something you must name out loud**, because against a different baseline the same algorithm is worth roughly half as much. Along the way a printed table entry turns out to be off by a quarter of a unit — the value of a rounded input, not the stored one.

### The universal object: an identity, not a formula

The right way in is to stop thinking about $\mu$ and $P$ and start thinking about *averages*.

Set up the general picture. There are $M$ ranked slots, $1, 2, \ldots, M$. A *weight* $w$ assigns to each slot the probability that the target sits there; the weights sum to $1$. A *cost kernel* $c$ says what you pay when the target is resolved at that slot: $c(i) = i$ for sequential scanning, or $c$ constant on each block if you commit to whole blocks at a time. Expected cost is the obvious average,

$$\mathrm{EC} \;=\; \sum_{i=1}^{M} c(i)\, w(i).$$

Now pick any subset $R$ of slots — the *retained stratum* — with mass $P = \sum_{i \in R} w(i)$, and let $C$ be its complement. Write $\bar r_R$ for the conditional mean cost inside $R$, i.e. the average of $c$ weighted by $w$ and renormalised, and $\bar r_C$ likewise. Then

$$\boxed{\;\mathrm{EC} \;=\; P\,\bar r_R \;+\; (1-P)\,\bar r_C\;}$$

This is the **r̄-identity**, and it is the universal object of the whole subject. It is not an approximation, not an asymptotic, not a bound. It is an exact identity, valid for *every* weight, *every* cost kernel and *every* stratum of nonzero mass on both sides. It says: total expected cost is the capture probability times the conditional cost of capture, plus the escape probability times the conditional cost of escape. Nothing else is assumed and nothing else is true in this much generality.

Everything downstream is a *booking* — a decision about how to summarise $\bar r_R$ and $\bar r_C$ in reportable numbers.

### Where the closed form comes from, and where it goes wrong

The famous closed form is what you get from the crudest possible booking: assume that inside each stratum the weight is *uniform*, so the conditional mean cost is just the geometric centre of the block. Define the **booking factor**

$$\Theta_R \;=\; \frac{\bar r_R}{\text{centre}(R)},$$

the ratio of the true conditional mean cost to the cost of the stratum's centre. Then the r̄-identity becomes the exact *booked law*

$$\mathrm{EC} \;=\; P\,\Theta_R\,\text{centre}(R) \;+\; (1-P)\,\Theta_C\,\text{centre}(C),$$

and the footnote formula is precisely the case $\Theta_R = \Theta_C = 1$.

When is $\Theta = 1$? Certainly when the weight is flat inside the stratum. Is the converse true — does $\Theta = 1$ certify uniformity? Here the answer splits in an instructive way.

- On a *single* stratum, no. Put mass $1/2$ on slot $1$ and mass $1/2$ on slot $3$ of a three-slot space. The conditional mean position is $2$; the centre of $\{1,2,3\}$ is also $2$; so $\Theta = 1$ exactly, while the weight could hardly be less uniform. A single booking factor equal to one is a coincidence of first moments, not a certificate.
- Across *all* strata, yes. If $\Theta = 1$ on every subset simultaneously, then the weight is constant. The proof is a two-element trick: applying the condition to the pair $\{i,j\}$ forces $(i-j)(w_i - w_j) = 0$, hence $w_i = w_j$.

So "$\Theta \equiv 1$ iff uniform" is true, but only in the strong, all-cells reading. The moment you book a single $\Theta$ and set it to one, you have assumed something you have not checked.

### The unbounded failure

How bad can the assumption be? Unboundedly bad — and, crucially, bad in the direction that makes the closed-form value *not an upper bound*.

Here is the witness. Take $M = 2m$ slots and a head stratum consisting of the first $m$. Put mass $1 - 1/m$ on slot $1$ and mass $1/m$ on slot $m+1$. This weight honours the booking exactly: the capture probability of the head stratum is $P = 1 - 1/m$, on the nose. Its true expected scan cost is

$$1 \cdot \left(1 - \tfrac1m\right) + (m+1)\cdot \tfrac1m \;=\; 2,$$

a constant, forever. The uniform-cell prediction, meanwhile, is $(m+3)/2$, which grows without bound. So for any constant $B$ you care to name there is an instance honouring the bookings whose real cost is smaller than the booked prediction by more than a factor $B$.

The moral is not that the closed form is useless; it is that it is a *reporting convention*, not a guarantee. The workload it describes is the uniform-cells workload; real workloads concentrate, and concentration is exactly what $\Theta$ measures.

### What survives: an envelope and a master inequality

Two things replace the broken guarantee, and both are unconditional.

**The booked envelope.** Given only the bookings — head stratum of size $m$ inside $M$ slots carrying capture mass $P$ — every admissible weight satisfies

$$P\cdot 1 + (1-P)(m+1) \;\le\; \mathrm{EC} \;\le\; P\,m + (1-P)\,M .$$

The bounds are simply "everything as early as possible" and "everything as late as possible" inside each block, and they are *sharp*: the head witness above attains the lower end exactly, and the weight that puts mass $P$ at slot $m$ and mass $1-P$ at slot $M$ attains the upper end exactly. The booked closed form always lies inside this envelope — admissible as a summary, inadmissible as a promise.

**The master inequality.** For value claims there is a genuinely unconditional cap. Let $\Lambda$ be the ratio of the sorted-arrangement cost to the descending baseline, $\Theta$ the booking factor, $\hat q$ the booked capture rate, and suppose the algorithm is filtered by $k$ bits of hashed key. Then

$$S \;\le\; \min\left(\frac{1}{\Lambda\,\Theta\,\hat q},\; \frac{2^{k}}{\Lambda\,\Theta}\right).$$

Its two branches come from two very different arguments. The first is *majorization*: if heavier slots come first — a descending weight — then the expected scan cost is at most the full-scan baseline $C_0 = (M+1)/2$. That is Chebyshev's sum inequality wearing an engineering hat, and it has a sharpening worth recording: the inequality is *strict* unless the weight is exactly flat. The engine is the double-sum identity

$$\sum_{i}\sum_{j} \big(c_i - c_j\big)\big(w_i - w_j\big) \;=\; 2\Big(M\sum_i c_i w_i - \big(\textstyle\sum_i c_i\big)\big(\sum_i w_i\big)\Big),$$

whose every term is $\le 0$ under a descending weight, so a single strict drop $w_b < w_a$ with $a<b$ forces a strictly negative total.

The second branch is pigeonhole: any assignment of $M$ slots to $2^k$ hash buckets leaves some bucket with at least $M/2^k$ slots, and an algorithm that must scan a whole bucket pays at least that in the worst case. Notice what neither branch uses: uniformity inside cells. That is precisely why the master inequality is unconditional while the value law is not.

### The baseline you forgot to name

Now to the sharpest of the corrections, and the one with the most practical bite.

The certified value $S = 5.4054$ at the anchor $(\mu, P) = (0.05, 0.85)$ is a ratio, and every ratio has a denominator. That number is stated against the *full-scan-$M$* baseline: you compare against reading all $M$ slots. But the natural baseline in this literature is the *descending scan* baseline $C_0 = (M+1)/2$ — the cost of scanning a well-ordered list, which on average stops halfway. Against that baseline the very same algorithm is worth

$$S_{C_0} \;=\; S \cdot \frac{M+1}{2M},$$

which for every $M > 1$ lies strictly between $S/2$ and $S$, and tends to exactly half of $S$ as $M$ grows. Half the advertised value, with no change to the algorithm and no change to the data. A value claim without a named baseline is not a weak claim; it is not a claim at all.

There is a second way the number leaks. It is a *locus* value, not a locus-free guarantee. An adversary who accepts the same prior but re-books the anchor a hair to the right — $\mu = 0.052$ instead of $0.05$, still perfectly admissible — realises $5.3648\ldots$, strictly below the certified $5.4054\ldots$. So a guarantee must pin the locus as well as the baseline.

### A table entry, corrected

Rigour of this kind pays for itself when it catches something concrete, and it did.

A recorded anchor table prints the row $(\mu, \hat P) = (0.02, 0.9853)$ with value $29.0698$. Evaluate the certified law at the stored $\hat P = 0.9853$ and you get

$$S = \frac{1}{0.02 \cdot 0.9853 + 0.98 \cdot 0.0147} = \frac{10^{7}}{341120} = 29.3152\ldots,$$

whereas $29.0698\ldots$ is exactly $S(0.02, 0.985)$ — the value at the *rounded* input. Somewhere between the stored measurement and the printed row, a digit was dropped. The correction is small in absolute terms and instructive in kind: at $\mu = 0.02$ the law is so steep in $P$ that the fourth decimal of $\hat P$ moves the value by a quarter of a unit.

Does anything break? No — and that too is a theorem. The feasibility test that these anchors are used for is $\mu \le 1/S$, and one line settles it: writing $D = \mu P + (1-\mu)(1-P) = 1/S$,

$$D - \mu \;=\; (1-P)(1-2\mu),$$

which is nonnegative on the whole admissible half-box $\mu \le 1/2$, $P \le 1$. Feasibility can never be flipped by re-reading $\hat P$ at a different precision. All four anchors of the original table survive intact; only their printed values move.

### The hidden coin flip

One last structure, and it is the prettiest. Look again at the reciprocal of the certified value,

$$D(\mu, P) \;=\; \mu P + (1-\mu)(1-P).$$

That is the probability that two independent coins — one with bias $\mu$, one with bias $P$ — come up *the same*. The certified value is the reciprocal of an agreement probability. Three facts fall out immediately.

- $D$ is symmetric in its two arguments, so $S(\mu, P) = S(P, \mu)$: in this framework *balance is position*, the geometry of the stratum and the quality of the prior are interchangeable coordinates.
- $D(\mu,P) = D(1-\mu, 1-P)$: complementing both bookings changes nothing.
- Composition is *submultiplicative, not multiplicative*. Stack two independent stratifications and the composite bookings multiply, $\mu_1\mu_2$ and $P_1 P_2$ — but two products can agree without their factors agreeing, so the composite agreement probability strictly exceeds the product of the agreements, and

$$S(\mu_1\mu_2,\, P_1P_2) \;<\; S(\mu_1,P_1)\, S(\mu_2,P_2)$$

strictly, throughout the interior. At $(\mu_1,P_1) = (1/2, 9/10)$ and $(\mu_2,P_2) = (1/2, 1)$ the composite value is $10/3$ while the product of the factors is $4$. Reporting a composed guarantee as a product is therefore always *conservative* — never optimistic — which is exactly the direction of error an engineer can live with.

### The shape of a prior

There is a companion story about *which* prior to report against. If balance is position, the natural coordinate is $s = r^{-1/2}$, and the prior that is uniform in that coordinate is the canonical kernel

$$b(r) \;=\; \tfrac12 r^{-3/2}, \qquad \int_1^R b(r)\,dr \;=\; 1 - R^{-1/2}.$$

Its capture curve is exactly linear in $\mu = 1 - R^{-1/2}$, namely $P(\mu) = \mu/(1 - R_{\max}^{-1/2})$ — and, remarkably, the converse holds: a continuous reporting density whose capture curve is proportional to $1 - R^{-1/2}$ must be a multiple of $b$. Linear capture *iff* canonical kernel. A flat prior on $[1, R_{\max}]$ fails the test, so the characterisation has content. The canonical kernel is thus not a convention chosen for convenience; it is the unique shape compatible with the linear capture behaviour these reports assume.

### What to take away

The framework ends up with an unusually clean discipline, and it is one worth exporting to any setting where speedups are advertised:

- State the law as an identity with its bookings — capture probability and conditional mean costs — never as a bare closed form in two numbers.
- Keep the raw, unrounded measurement; a fourth decimal can be a quarter of a unit.
- Name the baseline every time you claim a value. Against a smarter baseline, the same algorithm is worth half as much, exactly.
- Distinguish reporting conventions from guarantees. The closed form is the former; the sharp envelope and the master inequality are the latter.

None of this makes the original bet a bad one. Looking in the right twentieth of your data really is worth several times a brute-force scan. What changed is that the promise now comes with its fine print made explicit — and the fine print, it turns out, is where all the mathematics lives.
