# The Hint That Cannot Hurt You

## How two useless clues combine into a decisive one

Suppose I hand you a number $N = 391$ and tell you it is the product of two primes. You would like to know something *about* those primes — not necessarily their identity, but some property they have: whether a certain experiment run with them succeeds, whether a certain label attached to the pair reads $0$ or $1$. All you are allowed to look at is $N$, and only its remainder modulo some small number $m$ — say $m = 31$. That remainder is your entire window onto the hidden pair.

Now a friendly oracle offers you a hint. It will not tell you $p$ and $q$. It will tell you only their *sum* modulo $31$. Would you take it?

Here is what the numbers say: on a realistic battery of labelled examples, the sum alone recovers about $4\%$ of what the product's own residue tells you. Essentially nothing. So you decline, and ask instead for the *gap*, $q - p$, modulo $31$. Same answer: about $4\%$. Also essentially nothing.

Then you take both. And the two clues that were individually worthless suddenly read **$152\%$** of what the product residue reads — half a bit more information about the hidden labels than the product itself carries.

That is the phenomenon this article is about, and the surprising part is not that it happened. It is that it *had* to happen — and that the direction of the surprise was forced in advance by a piece of algebra a schoolchild could verify.

---

## The setup, precisely

Fix a modulus $m$ (odd, so that $2$ has an inverse mod $m$) and think of a large collection of labelled examples. Each example $x$ carries:

- a hidden pair of residues $p(x), q(x)$ modulo $m$ — think of them as the two factors,
- a visible label $T(x)$ drawn from some finite set — the outcome we actually care about.

There are four ways to *look* at each example, four **views**:

| view | what you read |
|---|---|
| product view | $N = pq \bmod m$ |
| sum view | $s = p + q \bmod m$ |
| gap view | $d = q - p \bmod m$ |
| joint residue view | the pair $(s, d)$ |

Each view is a lossy channel between the hidden pair and you. The natural way to score a channel is by **mutual information**: the number of bits about the label $T$ that the view reveals. Write $I(T; V)$ for the information the view $V$ carries about the label, measured in bits. A view that is statistically independent of the label scores $0$; a view that pins the label down exactly scores the full label entropy $H(T)$.

The measured table, on a battery of examples modulo $31$, reads

$$I(T; N) = 1.0012, \qquad I(T; s) = 0.0391, \qquad I(T; d) = 0.0387, \qquad I(T; s,d) = 1.5201 .$$

The last two columns are the interesting ones. Call

$$\Delta \;=\; I(T; s,d) \;-\; I(T; N)$$

the **hint value**: what a whispered hint of the factor residues adds over reading the product's residue yourself. Here $\Delta = +0.5189$ bits, and an independent replication of the experiment gave $+0.5099$ bits.

The pre-registered hypothesis had been that $\Delta = 0$ — that seeing $p$ and $q$ separately and seeing their product were, as far as the labels were concerned, the same thing. The experiment refuted it. The question is whether that refutation is a fact about the particular battery, or something deeper.

---

## One line of algebra settles the direction

Here is the identity that decides everything:

$$4pq \;=\; (p+q)^2 \;-\; (q-p)^2, \qquad\text{that is}\qquad N \;=\; \frac{s^2 - d^2}{4}.$$

Expand both sides; it is true in any commutative ring. And when $2$ is invertible — always, modulo an odd $m$ — you may divide by $4$, so the product residue is a *function of* the pair $(s,d)$.

That is the whole structural story. Anyone who knows $(s,d)$ can compute $N$ without further information. The product view is therefore not a rival channel at all: it is a **post-processing** of the joint residue view. And information-theory's most basic law — the data-processing inequality, which says that you cannot create information about a hidden quantity by computing a function of what you already have — then forces

$$I(T; N) \;\le\; I(T; s,d) \qquad\text{for every battery, every modulus, every labelling.}$$

**The hint value is never negative.** The pre-registered hypothesis $\Delta = 0$ was not merely false; it was false in the only direction it *could* fail. The experiment measured the size of $\Delta$, not its sign. Its sign was a theorem.

The same argument, applied to the two projections $(s,d) \mapsto s$ and $(s,d) \mapsto d$, forces $I(T;s) \le I(T;s,d)$ and $I(T;d) \le I(T;s,d)$ as well. The shape of the measured table — two tiny single-coordinate rows and one large joint row — is not a coincidence waiting to be explained. It is the only shape the table is allowed to have.

---

## The joint view *is* the factor pair

There is a second, equally elementary observation that pins down what the joint view actually is. The map

$$(p, q) \;\longmapsto\; (p + q,\; q - p)$$

is a **bijection** of pairs, whenever $2$ is invertible: from $(s,d)$ you recover $p = \tfrac{s-d}{2}$ and $q = \tfrac{s+d}{2}$. So the joint residue view is *neither more nor less* than the view "both factors, separately, modulo $m$". Presenting the hint in sum/gap coordinates neither adds nor destroys anything:

$$I(T; s,d) \;=\; I(T; p,q).$$

Consequently the $152\%$ row is literally the capacity of the factor-residue hint itself. And since the pair $(p \bmod 31,\, q \bmod 31)$ ranges over $31^2 = 961 < 1024 = 2^{10}$ values, that hint is a genuine **ten-bit** hint: whatever it does, it cannot release more than $\log_2 961 \approx 9.908$ bits. The measured $+0.5189$ bits is about $5\%$ of that crude budget.

Swapping the two factors, finally, sends $d \mapsto -d$ and fixes $s$, hence fixes the recovered product; and it leaves the partition of examples by $(s,d)$ unchanged. So the hint value is exactly symmetric in $p \leftrightarrow q$ — the invariance the experiment checked numerically is an identity.

---

## Why the collapse loses anything at all

If $N$ is a function of $(s,d)$, why doesn't the reverse hold? Because the map $(s,d) \mapsto (s^2-d^2)/4$ is quadratic, and quadratic maps crush. Modulo $31$, the pairs $(p,q) = (1,6)$ and $(2,3)$ have the same product $6$ but different sum/gap coordinates — and they are not even swaps of each other, so the collapse is not merely the harmless $p \leftrightarrow q$ ambiguity. Likewise $(1,2)$ and $(0,3)$ share the sum $3$ while their products $2$ and $0$ differ, and $(1,2)$ and $(0,1)$ share the gap $1$ with the same disagreement in product. Each single coordinate is *strictly* coarser than the product; the pair is *strictly* finer.

Whenever the labels happen to distinguish two examples that the product view fuses, the hint releases information. Which brings us to the exact boundary.

---

## When is the hint worthless?

The hint value can be written, exactly, as a release of conditional uncertainty:

$$\Delta \;=\; H(T \mid N) \;-\; H(T \mid s,d),$$

the drop in residual uncertainty about the label when the hint arrives. So $\Delta = 0$ precisely when the two conditional entropies coincide — when the label is, given the product residue, conditionally independent of which point of the product fibre you are standing on.

A clean *sufficient* condition is easy: if the label is a function of the product residue — if $N$ already determines $T$ — then both views pin the label and $\Delta = 0$ on the nose. This is where the refuted hypothesis came from: it is exactly the assumption that batteries are product-measurable, illegitimately extrapolated to arbitrary ones.

But that sufficient condition is **not necessary**, and the counterexample is embarrassingly small. Take two examples, both with $p = q = 0$ modulo $5$, and give them different labels. Every view is constant, so every view reads $0$ bits and $\Delta = 0$ — yet the label is certainly not a function of the product residue, since the two examples share a product and disagree on the label. The honest characterisation is the conditional-independence one, not the measurability one.

---

## An exact one-bit refutation

Empirical bits are estimates, and estimates of mutual information are biased upward. A measured $+0.5189$ is evidence, not proof. So here is a battery on which the readings are exact rational numbers, with no estimation whatsoever.

Work modulo $5$, with four examples:

| example | $p$ | $q$ | $N = pq$ | $s = p+q$ | $d = q-p$ | label $T$ |
|---|---|---|---|---|---|---|
| 1 | $1$ | $1$ | $1$ | $2$ | $0$ | $0$ |
| 2 | $1$ | $2$ | $2$ | $3$ | $1$ | $0$ |
| 3 | $2$ | $3$ | $1$ | $0$ | $1$ | $1$ |
| 4 | $2$ | $1$ | $2$ | $3$ | $4$ | $1$ |

Read the product column against the label column: label $0$ sees the multiset of products $\{1,2\}$; label $1$ sees $\{1,2\}$. Identical. The product view is *exactly independent* of the label and reads **$0$ bits**. Read the $(s,d)$ column: the four pairs $(2,0), (3,1), (0,1), (3,4)$ are distinct, so the joint view determines the label and reads the full label entropy, **exactly $1$ bit**.

$$\Delta \;=\; 1 - 0 \;=\; 1 \text{ bit, exactly.}$$

There is no universal identity $I(T;s,d) = I(T;N)$. The hypothesis is dead, and what survives in its place is the inequality $I(T;N) \le I(T;s,d)$ with the conditional-independence boundary.

---

## How big can a hint get?

Three ceilings bound $\Delta$, and each says something different.

**The label ceiling.** $\Delta \le H(T)$: a hint cannot release more uncertainty than the label had. This is sharp, and sharply attained. Take four examples modulo $5$ sitting on the single product fibre $pq = 1$, namely $(1,1), (2,3), (3,2), (4,4)$, and give them four distinct labels. The product residue is *constant* across the battery, so the hint-free channel reads exactly $0$ bits; the residue pairs are distinct, so the hint reads the full $2$ bits of label entropy. Here $\Delta = H(T) = 2$ bits and the product view's share is $0$ — the $152\%$ of the measured table is nowhere near the structural maximum, which is unbounded as a percentage.

**The split ceiling.** $\Delta \le I(T;s) + H(d)$: on top of what the sum dial already reads, the gap dial can contribute at most its own entropy.

**The hyperbola ceiling**, which is the one that knows the modulus. In general
$$\Delta \;\le\; H(s,d) \;-\; H(N),$$
the residual uncertainty in the factor pair once the product is known. For the *uniform* battery over a field with $q$ elements — all $q^2$ residue pairs, each occurring once — both sides evaluate in closed form, because the fibres of the product map are hyperbolas. The curve $xy = n$ with $n \ne 0$ has exactly $q - 1$ points; the degenerate fibre $xy = 0$ is a pair of crossing lines with $2q - 1$ points. So the joint view is a faithful code with entropy $\log_2 q^2$, while the product view's entropy is assembled from one fat degenerate fibre and $q-1$ thin hyperbolic ones. At $q = 31$ this gives
$$H(s,d) = \log_2 961 = 9.9084 \text{ bits}, \qquad H(N) = 4.9365 \text{ bits}, \qquad \Delta \le 4.9719 \text{ bits},$$
and the measured $+0.5189$ bits is $10.4\%$ of the true available budget. At $q=5$ the ceiling is $2.4212$ bits, and the four-example battery above attains $2$ of them — so the two ceilings are genuinely of comparable size, not artefacts of slack.

The whole modulus-dependent budget for factor-residue hints, then, is a statement about **a single degenerate conic**. Everything else in the picture is uniform.

---

## Two dials, one signal

One last phenomenon deserves its own name, because the measured table exhibits it and it is easy to mistake for noise. Why were the sum row and the gap row each near zero while their combination was large?

Because information can be **synergistic**: present in a pair of variables and in neither of them alone. The canonical toy is exclusive-or, and it is realisable here exactly. Modulo $5$, take the four examples
$$(p,q) = (0,0),\ (2,3),\ (3,3),\ (0,1),$$
whose sum/gap coordinates are $(0,0), (0,1), (1,0), (1,1)$, and label them by the parity of $s + d$: labels $0,1,1,0$. Then the sum view reads **exactly $0$ bits**, the gap view reads **exactly $0$ bits**, and the joint view reads **exactly $1$ bit**. Two dials that individually see nothing jointly see everything.

Redundancy — the opposite direction — is bounded: the joint view always dominates each single view, so the synergy of the split can never fall below $-\min\big(I(T;s), I(T;d)\big)$.

And here is the sting in the tail. That exclusive-or battery has *maximal* synergy and hint value **exactly zero**: its labels happen to be a function of the product residue. The four-labels-on-one-fibre battery has *maximal* hint value. Release and synergy are independent coordinates of a routing table. No single scalar — not $+0.5189$, not $152\%$ — summarises how much structure a battery has. You need at least two numbers, and they measure different things.

---

## What to take away

The experiment that opened this story looked like a clean empirical surprise: a clue worth $4\%$, plus another clue worth $4\%$, adding up to $152\%$. The analysis turns it into three separate statements, with three different statuses.

1. **The sign was never in doubt.** Because $4pq = (p+q)^2 - (q-p)^2$, the product view factors through the joint view, and the hint value is nonnegative by data processing. The hypothesis it refuted could only fail upward.

2. **The boundary is conditional independence, not measurability.** The hint is worthless exactly when the label, given the product residue, says nothing more about where in the product's fibre you are. Product-measurable labels are one sufficient case; assuming they were the only one is what produced the failed prediction.

3. **The size is genuinely empirical, and the right yardstick is the hyperbola ceiling.** Not the $10$-bit hint size, and not $H(T)$: the number to divide by is $H(s,d) - H(N) = 4.97$ bits at modulus $31$. Against that, the measured release is about a tenth.

The wider point generalises past factoring. Any time a visible quantity is an *algebraic function* of hidden ones — a product, a norm, a trace, a symmetric function — the hidden coordinates form a strictly finer view, and there is a well-defined number of bits locked behind the collapse. The sum/difference split is the degree-two case, where the collapse is the quadratic map $(s,d) \mapsto (s^2-d^2)/4$ and the fibres are hyperbolas. For $k$ hidden factors the product is recovered from the elementary symmetric functions, the same data-processing argument runs verbatim, and the hint value should scale with the codimension of the locus where the collapse degenerates.

Two clues worth nothing apiece, worth more than the answer together. It is not an anomaly. It is what happens whenever a bijection is composed with a crush.
