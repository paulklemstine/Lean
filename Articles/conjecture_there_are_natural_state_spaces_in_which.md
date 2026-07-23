# The Cost of Looking Away: Why Some Things Can Never Be Fully Reconstructed

## A puzzle about hidden differences

Imagine two objects that look *identical* under every measurement you are allowed to make, yet differ in some property you cannot measure directly. A pair of coins that weigh the same, ring the same, and reflect light the same — but one is subtly counterfeit. Two patients whose every recorded vital sign agrees to the digit — but who feel completely different inside. Two states of a physical system that respond identically to every experiment you can run — but that are, in some deeper sense, not the same state.

Philosophers have a colorful name for the extreme version of this puzzle: the **zombie twin**. A zombie twin is a being that behaves exactly like you — same words, same reflexes, same brain scans — but has no inner experience at all. Whether such twins are possible is a debate for another day. What is *not* a debate is the mathematical shadow the puzzle casts. If two things are indistinguishable to every instrument you own, and you nonetheless try to recover their hidden difference *from those instruments alone*, you are guaranteed to be wrong. The only open question is: **how wrong, and can we put a precise price on it?**

This article is about exactly that price. It turns out there is a clean, quantitative law governing how much of a hidden contrast survives any attempt to reconstruct it from limited observations. The law is short to state, robust to noise, and — pleasingly — it is at heart nothing more than the triangle inequality wearing a philosopher's costume.

## Three maps and a decoder

Let us set the stage with three ingredients. Think of a **state space** $X$ — the collection of all the underlying situations we care about (all possible internal configurations of a mind, a machine, or a molecule).

- A **functional observation** $F : X \to B$ records what our instruments can see. Two states $x$ and $z$ that our instruments cannot tell apart have $F(x)$ and $F(z)$ close together in the "readout space" $B$.
- An **experience observable** $E : X \to Y$ records the hidden property — the inner experience, the true label, the quantity we actually care about — living in a "meaning space" $Y$. Both $B$ and $Y$ come equipped with a notion of distance, so we can say how far apart two readouts, or two experiences, are.
- A **reconstruction** (or **decoder**) $R : B \to Y$ is any recipe that tries to guess the experience from the observation alone: feed it an instrument reading, and it outputs its best estimate of the hidden value.

The whole drama is captured by a single triangle. We would love the guess $R(F(x))$ to land right on the true value $E(x)$. The gap between them, $\operatorname{dist}\big(E(x),\, R(F(x))\big)$, is the **reconstruction error** at the state $x$ — how badly the decoder missed.

## Two states, one honest scoreboard

To make the accounting fair, we score the decoder on a small but revealing experiment: pick two states $x$ and $z$, present each with equal probability, and record the average error. We call this the **pair risk**:

$$\text{pairRisk} = \frac{\operatorname{dist}\big(E(x), R(F(x))\big) + \operatorname{dist}\big(E(z), R(F(z))\big)}{2}.$$

This is precisely the expected reconstruction loss when the two states are drawn from a fair coin flip — the simplest genuine probability experiment there is. A good decoder wants this number small. The results below say that sometimes it *can't* be.

## The exact law: half the secret always leaks into error

Start with the sharpest case. Suppose $x$ and $z$ are **functionally identical** — perfect twins to every instrument, so $F(x) = F(z)$. Suppose nonetheless that their experiences differ by at least $\delta$; that is, $\operatorname{dist}(E(x), E(z)) \geq \delta$. Then here is the punchline:

> **Exact reconstruction lower bound.** If $F(x) = F(z)$ and $\operatorname{dist}(E(x), E(z)) \geq \delta$, then for *every* decoder $R$ whatsoever,
> $$\text{pairRisk} \;\geq\; \frac{\delta}{2}.$$

No decoder — however clever, however complex, trained on however much data — can drive the average error below half the hidden contrast. The reason is disarmingly simple. Because $F(x) = F(z)$, the decoder returns the *same* guess for both states; call it $g = R(F(x)) = R(F(z))$. But a single point $g$ cannot be simultaneously close to two things that are far apart. By the triangle inequality,
$$\delta \;\leq\; \operatorname{dist}(E(x), E(z)) \;\leq\; \operatorname{dist}(E(x), g) + \operatorname{dist}(g, E(z)).$$
So the two errors must sum to at least $\delta$, and their average is at least $\delta/2$. The secret does not vanish; it is merely redistributed, half of it, into unavoidable error.

A companion statement sharpens *where* the error lands. Not only is the average at least $\delta/2$ — at least one of the two states individually suffers an error of at least $\delta/2$:

> **Worst-case leakage.** If $F(x) = F(z)$ and $\operatorname{dist}(E(x), E(z)) \geq \delta$, then
> $$\max\Big(\operatorname{dist}(E(x), R(F(x))),\ \operatorname{dist}(E(z), R(F(z)))\Big) \;\geq\; \frac{\delta}{2}.$$

You cannot even hide the damage in one convenient state and keep the other pristine; somebody always pays at least half.

## The robust law: what happens when the twins are merely close

Perfect indistinguishability is an idealization. Real instruments have resolution limits, not blind spots — they merge things that are *close*, not only things that are *equal*. So the interesting question is whether the law degrades gracefully. It does, and this robustness is the heart of the story.

Suppose now that $F(x)$ and $F(z)$ are within $\varepsilon$ of each other — the instruments *almost* can't tell them apart — while the experiences remain a full $\delta$ apart. We do need one mild assumption about the decoder: that it is **$K$-Lipschitz**, meaning it never amplifies distances by more than a factor of $K$. (Any sensible, stable decoder is Lipschitz; this simply rules out pathological recipes that turn tiny input wiggles into wild output swings.) Then:

> **Robust reconstruction lower bound.** If $\operatorname{dist}(F(x), F(z)) \leq \varepsilon$, $\operatorname{dist}(E(x), E(z)) \geq \delta$, and $R$ is $K$-Lipschitz, then
> $$\text{pairRisk} \;\geq\; \frac{\delta - K\varepsilon}{2}.$$

Read this as a budget. The total experiential contrast is $\delta$. A near-blind instrument, with discrepancy at most $\varepsilon$, can *legitimately explain* at most $K\varepsilon$ of that contrast through the decoder. **Everything left over — the amount $\delta - K\varepsilon$ — is forced, irretrievably, into reconstruction error.** When the instruments are exactly blind ($\varepsilon = 0$) we recover the earlier law $\delta/2$ exactly, so the robust statement contains the exact one as its zero-noise endpoint.

The proof is again a triangle, just a slightly longer one. Because $R$ is $K$-Lipschitz and its two inputs are within $\varepsilon$, its two outputs are within $K\varepsilon$. Now walk from $E(x)$ to $E(z)$ in three hops — from $E(x)$ to the guess $R(F(x))$, across to the guess $R(F(z))$, and down to $E(z)$:
$$\delta \leq \operatorname{dist}(E(x),E(z)) \leq \underbrace{\operatorname{dist}(E(x),R(F(x)))}_{\text{error at }x} + \underbrace{\operatorname{dist}(R(F(x)),R(F(z)))}_{\leq\, K\varepsilon} + \underbrace{\operatorname{dist}(R(F(z)),E(z))}_{\text{error at }z}.$$
Rearranging, the two errors sum to at least $\delta - K\varepsilon$, and dividing by two finishes it. Notice what the argument does *not* need: no assumption that the state space is small, or compact, or nicely shaped. The bound is a universal consequence of distance geometry.

## Why this matters beyond the metaphor

Strip away the zombie costume and you are left with a statement about **the limits of measurement and inference** — a subject at the crossroads of geometry, probability, and machine learning.

- **In machine learning**, $F$ is your feature extractor and $R$ is your predictor. The law says: if your features collapse two inputs whose true labels differ by $\delta$, then no downstream model — no deeper network, no bigger training set — can push the average error below $(\delta - K\varepsilon)/2$. The bottleneck is the *features*, not the *classifier*. This is a clean, adversary-free companion to the usual data-processing intuition: information a representation throws away cannot be recovered by anything applied afterward.

- **In statistics and signal processing**, this is a decision-theoretic risk bound. The pair risk is genuinely the Bayes risk of the two-point uniform experiment, and the theorem is a lower bound on that risk that holds for every estimator in the Lipschitz class. It quantifies exactly how a lossy sensor caps the fidelity of any stable reconstruction.

- **In the philosophy of mind**, it makes the zombie thought experiment quantitative. If experience genuinely varies across functionally identical states, then any theory that reads experience off from function must, on average, be off by at least half the experiential gap. The impossibility is not a vague worry; it is $\delta/2$.

What makes the result satisfying is the contrast between the depth of the questions and the economy of the answer. A single geometric inequality — distances add up along a path — simultaneously tells a neural network why its features are the bottleneck, tells a statistician the price of a lossy sensor, and tells a philosopher the exact toll for reconstructing the inner from the outer. The exact case ($\varepsilon = 0$) is the crisp impossibility theorem; the robust case is the engineering reality, where blindness is a matter of degree and the law degrades in proportion.

## The road ahead

The two-point experiment is a seed, not the whole tree. A natural next step is to average the bound over many pairs of states — over an entire *transport plan* matching functionally-close states to experientially-far ones — turning the local inequality into a global one phrased in the language of optimal transport. Another is to pin down when the factor $\tfrac{1}{2}$ is *sharp*, converting the bound into a full minimax theorem that identifies the single best decoder. One can also let decoders be randomized — Markov kernels from observations to distributions over experiences — and replace metric loss by Wasserstein loss; the same triangle-inequality skeleton should survive. And there is a topological cousin lurking: when functionally-identical twins exist only *locally* but cannot be matched up consistently across the whole space, the obstruction becomes one of monodromy and covering spaces rather than distance.

But the core lesson is already in hand, and it is unusually clean. Whenever you compress the world through a lens that cannot resolve a difference, that difference does not politely disappear. It reappears — half of it, at least — as error in anything you try to rebuild. The world keeps its secrets, and geometry tells you their exact price.
