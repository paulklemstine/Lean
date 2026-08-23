# The Last Two Layers Are Not Yours to Lend

### What a transplant experiment on two sibling language models reveals about the geometry of agreement — and about how many personalities one set of weights can honestly wear at once

---

## An organ that will not take

Surgeons learned the hard way that some organs transplant easily and some do not. A cornea is nearly universal. A face is not. The difference is not size or complexity; it is *entanglement* — how much of the organ's function depends on the exact body it grew in.

Neural networks now pose the same question, and for an unglamorous reason: money. Suppose you have two descendants of the same pretrained language model — a raw "base" model and a chat-tuned "instruct" model. They share an architecture, a tokenizer, and most of their history; they differ only in the fine-tuning that came at the end. If you must serve both from one GPU, you would dearly like to keep *one* copy of most of the weights and swap only a small personal remainder. Which layers are personal, and which are common property?

There is a clean way to ask. Take the two models, and physically **transplant** a block of layers from one into the other, leaving everything else untouched. Then measure what the resulting hybrid actually predicts, position by position, on held-out text. If the transplanted block carries a model's identity, the hybrid should drift toward the donor. If the block is generic, nothing should change.

The experiment was run on two fine-tunes of a small transformer, over twelve held-out windows of text. First, the control: the two parents themselves agree on their top-choice next token at a fraction

$$\beta = 0.8327$$

of positions. Call this the **cross-parent baseline**: five out of six tokens, the two models say the same thing. Their disagreement is only $1-\beta = 0.1673$ — fine-tuning is a small perturbation, measured in behaviour.

Now the transplants. Swapping two *middle* layers (call them the bulk) is essentially free: the hybrid's predictive loss changes by $+0.0043$ nats in one direction and by $-0.0164$ nats in the other — the transplant slightly *improves* the recipient — and the hybrid still agrees with its host on $0.9635$ of positions, well above the cross-parent baseline. The bulk is common property.

Swapping the last two layers is a different animal. The loss jumps by nearly half a nat. But the striking number is not the loss. It is the agreement:

| transplant | agrees with base | agrees with instruct |
|---|---|---|
| base receiving instruct's **last two layers** | $0.5845$ | $0.5443$ |
| instruct receiving base's **last two layers** | $0.5887$ | $0.6289$ |
| base receiving instruct's **middle two layers** | $0.9635$ | $0.8385$ |
| instruct receiving base's **middle two layers** | $0.8459$ | $0.9495$ |

Look at the first two rows. The hybrid agrees with the donor $0.5443$ of the time — but it also agrees with its own host only $0.5845$ of the time, and *both* numbers sit far below the $0.8327$ that the two parents manage with each other. The pre-registered hypothesis had been that a transplanted tail would drag the hybrid toward the donor. It did not. The hybrid became a stranger to both parents.

That is the whole story in one sentence: **the tail is load-bearing but unportable.** It does something essential, and it cannot be moved.

---

## Why "a stranger to both" is a theorem, not a mood

It is tempting to read the table as merely "the numbers went down." They did something stricter, and a small piece of combinatorial geometry says exactly what.

Fix a finite set of $N$ text positions. A model is just a function assigning a predicted token to each position. For two models $f$ and $g$, write $\mathrm{agr}(f,g)$ for the fraction of positions where they choose the same token. This is one minus the normalized Hamming distance, and it inherits Hamming's triangle inequality in the following form.

> **The Portability Budget.** For any three models $f, g, h$ on the same positions,
> $$\mathrm{agr}(f,g) + \mathrm{agr}(g,h) \le 1 + \mathrm{agr}(f,h).$$

The reason is a one-line counting argument: a position where $f$ and $h$ differ must be a position where $f$ differs from $g$ or $g$ differs from $h$, so disagreements are subadditive along a chain. Rearranged, the budget says a hybrid cannot be simultaneously close to two parents that are far from each other. With $\mathrm{agr}(A,B) = \beta$, the two agreements of any hybrid must sum to at most $1+\beta$.

That is a ceiling. What makes the measurement interesting is the *floor* it violates. Consider the most natural mental model of what a layer swap does: at every position, the hybrid inherits *somebody's* answer — the host's or the donor's — and the swap only decides which. Call such a hybrid a **parent selector**. A selector never invents anything.

> **The Both-Parents-Collapse Certificate.** Let $\nu$ be the fraction of positions where the hybrid $H$ predicts a token that *neither* parent predicts. Then
> $$\nu \;\ge\; \mathrm{agr}(A,B) \;-\; \min\big(\mathrm{agr}(H,A),\, \mathrm{agr}(H,B)\big).$$

The proof is a picture. On the positions where the two parents already agree — there are $\beta N$ of them — the hybrid has only two options: say what they both say, or say something new. So the parents' consensus set is covered by the hybrid's agreement set with either parent, together with its novelty set; count, divide by $N$, done.

Feed in the measurement. With $\beta \ge 0.8327$ and both hybrid agreements at most $0.5845$ and $0.5443$, we get $\nu \ge 0.2884$: **at least $28.84\%$ of all held-out positions carry a prediction that neither parent would ever have made.** In the reverse direction the certificate gives $\nu \ge 0.2038$. And an immediate corollary, since a selector has $\nu = 0$:

> The tail-swapped hybrid is **not** a parent selector. No assignment of positions to parents can reproduce its behaviour.

This is the sharp form of "the hypothesis was refuted". The hybrid is not a blend, not a compromise, not a mixture. It is off-manifold: a third model, produced by gluing statistics that were never meant to meet.

The certificate has real teeth only because the measured numbers had room to look otherwise. The portability budget allowed the two agreements to sum to $1.8327$; they summed to at most $1.1288$, leaving $0.7039$ of the budget on the floor. Nothing forced the collapse arithmetically — the experiment could have shown a donor transfer and did not. And the certificate does not fire for the bulk arm at all: with the host agreement at $0.9635 > \beta$, the bound is vacuous, and a selector explanation stays available. The collapse is a property of the *tail*, not of transplanting.

One more sanity check, and a satisfying one: the four measured numbers are jointly realizable **on the nose**. Split $10{,}000$ positions into five classes of sizes $5000, 3327, 845, 443, 385$ — parents agreeing with the hybrid following them, parents agreeing with the hybrid going rogue, parents differing with the hybrid picking each, and parents differing with the hybrid picking a third token. This gives exactly $\mathrm{agr}(A,B)=0.8327$, $\mathrm{agr}(H,A)=0.5845$, $\mathrm{agr}(H,B)=0.5443$, with novelty exactly $0.3712$ — comfortably above, and therefore consistent with, the guaranteed $0.2884$.

---

## Cost is not agreement, and damage is not a haze

Two frequent inferential shortcuts get closed off along the way.

**"The loss didn't move, so the model didn't change."** False, and demonstrably so. For any $t \in (0, \tfrac12)$, the two-token distributions $(\tfrac12+t, \tfrac12-t)$ and $(\tfrac12-t, \tfrac12+t)$ have *exactly equal* cross-entropy against a uniform truth, yet their top-1 choices are opposite — at every position. A vanishing $\Delta\mathrm{CE}$ licenses no conclusion whatsoever about agreement. The bulk arm's $0.9635$ agreement is therefore independent evidence, not a corollary of its free loss. (What *does* control the cost gap is a bounded log-ratio: if two predictive distributions differ by at most $\kappa$ in log-space at every token, their cross-entropies against any truth differ by at most $\kappa$.)

**"The average damage was small, so it was spread thinly."** Also false, in the other direction. A reverse-Markov argument: if a nonnegative per-window excess is capped at $C$ and averages at least $\Delta$, then at least a $\Delta/(2C)$ fraction of windows individually carry excess at least $\Delta/2$. With the tail arm's measured $+0.4652$ nats and a $2$-nat cap, at least $11.63\%$ of windows must each lose at least $0.2326$ nats. That is a falsifiable prediction about a histogram, not a slogan.

There is also a pleasing consequence for the *next* experiment. Every statistic here — agreement with a fixed parent, novelty against a fixed pair — is $1$-Lipschitz in the hybrid with respect to normalized Hamming distance. Run that backwards on the data: since the bulk hybrid agrees with the host at $0.9635$ and the tail hybrid at $0.5845$, the two hybrids must themselves differ on at least $37.90\%$ of positions. Built from the same two parents, the two transplants end up **further from each other than the parents ever were** ($0.3790$ versus $0.1673$). Two surgeries on the same pair of patients produce two organisms more different than the patients.

---

## From one boundary to a capacity law

The practical verdict — share everything except the last two layers — invites a scaling question. If you are serving not two fine-tunes but $k$ of them from one shared body of weights, how much can a single shared model possibly retain?

Apply the portability budget to every pair and average. If the $k$ fine-tunes agree pairwise at most $\beta$, then any single shared model $H$ has mean agreement

$$M := \frac{1}{k}\sum_{i=1}^{k} \mathrm{agr}(H, A_i) \;\le\; \frac{1+\beta}{2}.$$

This ceiling is independent of $k$, and it *is* attainable for two: split the parents' disagreement set in half, follow the donor on one half and the host on the other. The resulting **balanced compromise** saturates the budget exactly, $\mathrm{agr}(H,A) + \mathrm{agr}(H,B) = 1 + \mathrm{agr}(A,B)$, and is equidistant from both parents up to a single position. So the best achievable *worst-case* agreement with a fine-tune pair is exactly $(1+\beta)/2$, to within $1/(2N)$. At the measured baseline this is $0.9163$ with **both** parents at once — against the tail hybrid's $0.5443$ with its donor. The transplant forfeits more than $0.37$ of what a deliberately designed shared model would have delivered; the bulk transplant, measured in mean agreement across the two parents, comes within $0.0154$ of that optimum.

For $k \ge 3$ something new happens, and it is the mathematically richest part of the story. Count, at each position, how many of the $k$ fine-tunes the shared model matches. Two fine-tunes matched at the same position necessarily agree there — so the pairwise budget limits the *square* of that count, and Cauchy–Schwarz converts this into a quadratic constraint on the mean:

$$k M^2 \;\le\; M + (k-1)\beta.$$

Unlike the ceiling, this one knows about $k$. Solving it gives a closed-form **serving-capacity curve**

$$M^{*}(k) \;=\; \frac{1 + \sqrt{1 + 4k(k-1)\beta}}{2k},$$

and the two bounds cross *exactly* at $k(1-\beta) = 2$. Below the threshold the pairwise ceiling is the binding one; above it, the capacity curve is strictly smaller and the ceiling becomes unreachable. This is a genuine phase transition in the number of models you are trying to serve, and the threshold is sharp: at $\beta = 1 - 2/k$ there is an explicit family of $k$ fine-tunes and a shared model hitting the ceiling exactly.

At the measured baseline $\beta = 0.8327$, the threshold sits at $2/(1-\beta) = 11.95$. So: **at most eleven fine-tunes can be served at the pairwise ceiling.** From twelve onward, the achievable mean agreement is strictly smaller — $0.91634$ at $k=12$, $0.91297$ at $k=100$. And the curve has an exact limit that is not the ceiling at all:

$$\sqrt{\beta} \;\le\; M^{*}(k) \;\le\; \sqrt{\beta} + \frac{1}{k}, \qquad M^{*}(k) \longrightarrow \sqrt{\beta}.$$

Serving many fine-tunes from one set of weights is governed by the *geometric* mean of the pairwise budget, not the arithmetic one. At $\beta = 0.8327$ that asymptote is $0.9125$.

---

## The surprise: extremal sharing is quantised

The last turn of the screw is unexpected. Ask which families actually *attain* the quadratic bound. An exact algebraic identity separates the total slack into two nonnegative pieces — a Cauchy–Schwarz spread term measuring how unevenly the matched count varies across positions, and a budget term measuring how far the pairwise agreements are from $\beta$. Equality forces both to vanish, which pins the geometry completely:

* the shared model matches **exactly the same number of fine-tunes at every position**; and
* every pair of fine-tunes agrees exactly $\beta$ of the time, and agrees *only* where both are matched by the shared model.

Let $c$ be that constant matched count. Counting incidences twice gives $M = c/k$ and $\beta = c(c-1)/\big(k(k-1)\big)$. In other words, extremal shared-serving configurations are **quantised**: only a finite ladder of $(\beta, M)$ values, indexed by an integer $c \le k$, can ever be extremal. No family saturates the bound at, say, an irrational budget.

And the ladder is exactly filled. For every $2 \le c \le k$, take the positions to be the $c$-element subsets of $\{1,\dots,k\}$; let fine-tune $i$ speak a neutral token at subset $S$ when $i \in S$ and its own private token otherwise; let the shared model always speak the neutral token. Binomial counting gives $\mathrm{agr}(H, A_i) = \binom{k-1}{c-1}/\binom{k}{c} = c/k$ and $\mathrm{agr}(A_i,A_j) = \binom{k-2}{c-2}/\binom{k}{c} = c(c-1)/(k(k-1))$ — precisely the quantised pair, saturating the bound. So the necessary condition is also sufficient: the extremal serving values are *exactly* the quantised ones, and the earlier threshold family is the single case $c = k-1$.

A question about GPU memory has turned into a combinatorial design problem, and the answer is a block design.

---

## What to do on Monday morning

The engineering advice survives the abstraction intact, and now with reasons.

**Share the bulk; keep the tail.** The middle layers transplant at literally zero measured cost — one direction even improves the recipient — while the last two layers, moved between siblings of the same architecture, produce a model that belongs to neither parent on almost a third of its predictions. Do not approximate the tail, do not borrow it, do not average it. Re-run it per model.

**Do not read agreement off the loss.** They are provably dissociable in both directions. If you care about which token comes out, measure which token comes out.

**Know your capacity.** If your fine-tunes are as similar as this pair, one shared model can serve about eleven of them at full geometric efficiency; past that, the returns decay along an explicit curve toward $\sqrt{\beta}$. That is a budgeting number, available before you buy the hardware.

Three independent probes of this architecture have now converged on the same two layers as special. The transplant experiment adds the sharpest characterisation: they are the only layers that are not transplantable. The tail is where a fine-tune keeps its personality, and personality, it turns out, is exactly the part that does not survive being lent.
