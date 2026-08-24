# The Cache That Broke Its Own Law

## What happens to a language model's memory when you double the page it is reading

There is a number hiding inside every long-context language model, and almost nobody looks at it directly. Call it the *knee*.

When a transformer reads a passage, each position distributes a fixed unit of attention across all the positions before it. Most of that attention lands on a handful of places: the very beginning of the document, the last few tokens, one or two anchors in the middle. The rest of the context receives a thin, wide drizzle. This is why key–value cache compression works at all. You do not need to keep every key. You need to keep the ones that carry the mass.

The knee is the smallest number of keys you can keep and still capture essentially all of the attention. Formally: order the attention weights from largest to smallest, write $p_0 \ge p_1 \ge p_2 \ge \cdots$ for the sorted profile, and define the **retention** of a budget of $k$ keys as the mass they carry,

$$R_p(k) \;=\; \sum_{i < k} p_i .$$

Fix a tolerance $\tau$ — the fraction of attention you insist on preserving — and the **knee** is

$$\kappa_p(\tau) \;=\; \min\{\, k : R_p(k) \ge \tau \,\}.$$

That is the whole object. It is a threshold of a monotone quantity, which makes it about as simple as a definition can be, and it is also the number that decides whether your deployment fits in memory.

The interesting question is how the knee moves when the context grows.

---

## Three doublings of good behaviour

Measure the knee of a half-billion-parameter model at four context lengths, each twice the last. Index the doublings by $j$, so that the context length is

$$N_j = 512 \cdot 2^{\,j}, \qquad j = 0,1,2,3 \;\longleftrightarrow\; 512,\ 1024,\ 2048,\ 4096 .$$

The measured knees are

| doublings $j$ | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| context $N_j$ | 512 | 1024 | 2048 | 4096 |
| knee $k^*$ | 16 | 20 | 24 | **40** |

For the first three entries the story is beautifully dull. Every doubling of the context costs four more keys. Sixteen, twenty, twenty-four: an arithmetic progression, the friendliest shape a scaling law can have. Extrapolating is trivial, and the extrapolation says that at $4096$ tokens you should need $28$ keys.

You need $40$.

The increment jumped from $+4$ to $+16$. The linear law that held through three doublings broke at the fourth. That is the phenomenon, and everything below is an attempt to say precisely what it does and does not license you to conclude.

The first thing it licenses is a flat impossibility. Write a *budget law* for a function $f$ assigning a key budget to each doubling index, and say $f$ **fits the chain** if $f(0)=16$, $f(1)=20$, $f(2)=24$, $f(3)=40$.

> **No Affine Law.** There are no constants $k_0, d$ with $f(j) = k_0 + dj$ fitting the chain.

The proof is one line of arithmetic — a constant-increment law cannot have increments $4, 4, 16$ — but it is worth stating as a theorem because it is the entire empirical content of the headline. Not "the law bends"; the law *cannot* be the law it was.

---

## What four points do not tell you

Here is where the discipline starts. The temptation, once a curve kinks, is to draw the new curve. But four points are four points, and the space of laws through them is enormous. Three natural candidates:

- the **ramp**, $\;f_{\mathrm{ramp}}(j) = 16 + 4j + 12(j-2)_+\;$ — linear with a single kink, the minimal way to accommodate the jump;
- the **cubic interpolant**, $\;f_{\mathrm{cub}}(j) = 16 + 4j + 12\binom{j}{3}\;$ — the unique cubic polynomial through the four points, written in Newton form;
- the **geometric** law, $\;f_{\mathrm{geo}}(j) = 16 + 4j + 4\,(4^{\,j-2}-1)\;$ for $j \ge 2$ — the reading in which the *increment itself* quadruples at every doubling, i.e. the acceleration is permanent and compounding.

All three reproduce $16, 20, 24, 40$ exactly. At the next doubling, $8192$ tokens, they predict

$$56, \qquad 80, \qquad 92$$

keys respectively. A spread of nearly a factor of two, with no data able to adjudicate. This is the **Underdetermination Theorem**, and it is the honest ceiling on what a four-point chain can say: *the $+16$ increment is a measurement; its continuation is a choice.*

But the data are not powerless. The measured increments $4, 4, 16$ never decrease, and every plausible mechanism produces the same shape, so it is fair to restrict attention to **convex** laws: those whose per-doubling increments are non-decreasing, $2f(j+1) \le f(j) + f(j+2)$. Convexity converts a single observed jump into a permanent obligation, because a convex sequence can never surrender an increment it has once achieved. Iterating gives:

> **Forced Growth.** Every convex law fitting the chain satisfies $f(m+3) \ge 40 + 16m$ for all $m \ge 0$. In particular at least $56$ keys are needed at $8192$ tokens, and no finite budget $B$ suffices for all contexts.

The ramp attains the bound with equality, so $56$ is exactly the convex floor at $8192$ — the two survivors of the next section are separated by whether the truth sits on that floor or above it.

---

## The kink is a tropical corner

"Budgets are context-stable for the first couple of thousand tokens and then become sharply more expensive." That is the sentence one wants to write, and as it stands it is atmosphere, not mathematics. It can be made exact, and the exactness comes from an unexpected direction.

Observe that the ramp fit can be rewritten without any truncated subtraction:

$$f_{\mathrm{ramp}}(j) \;=\; \max\big(16 + 4j,\; 16j - 8\big).$$

A maximum of affine functions is, in the *max-plus* or **tropical** semiring — where addition is $\max$ and multiplication is ordinary $+$ — precisely a *polynomial*. The two affine pieces are its two monomials. And a tropical polynomial has a distinguished locus: the set of points where the maximum is attained twice, its **corner**, which is the tropical analogue of a root. Here

$$16 + 4x = 16x - 8 \iff x = 2,$$

a single crossing, at $j = 2$, which is to say at a context of exactly

$$512 \cdot 2^2 = 2048 \text{ tokens.}$$

So the informal "around two thousand tokens" is not a rounding of an observation. It is the root of a tropical hypersurface — the unique point where the fitted budget law's two regimes exchange dominance. Before it, the monomial $16+4j$ carries the law; after it, $16j-8$ does. The phase transition has a coordinate.

This is not a coincidence of the ramp. It is a general fact about budget laws, and it is the mathematical heart of the work:

> **Tropical Envelope Theorem (discrete Legendre biconjugation).** Let $f$ be any monotone convex budget law and let its *tangent at $i$* be the affine law $T_i(j) = f(i) + (j-i)\,\Delta f(i)$, where $\Delta f(i) = f(i+1)-f(i)$. Then for every $J$,
> $$f(J) \;=\; \max_{0 \le i \le J} \; T_i(J).$$

In words: a convex budget law *is* the tropical polynomial whose monomials are its own tangents. It is its own max-plus envelope. This is the discrete, order-theoretic shadow of the classical statement that a convex function equals its double Legendre transform, and it says that the language of tropical geometry is not decoration here — it is the native language of the object. Kinks in budget laws are tropical corners, and the corners are where the tangents change hands.

For the ramp, almost all the tangents are redundant: past the corner the envelope collapses onto just two, the tangent at $j=0$ (the $+4$ regime) and the tangent at $j=2$ (the $+16$ regime), and those two agree exactly at $j = 2$. The measured phase transition is the meeting point of the only two monomials that survive.

---

## How much acceleration, really?

Now the uncomfortable part, and the part that separates a result from a headline.

The knee at $4096$ was not measured on a continuum. It was read off a grid of trial budgets $\{16, 20, 24, 28, 32, 40\}$, with retentions

| $k$ | 16 | 20 | 24 | 28 | 32 | 40 |
|---|---|---|---|---|---|---|
| retained | 0.959 | 0.969 | 0.975 | 0.977 | 0.979 | **0.984** |

and the gate passing only at $40$. The gate itself is not directly observed, but the table pins it down: since $32$ fails and $40$ passes,

$$0.979 < \tau \le 0.984 .$$

That is the **Gate Recovery** statement, and it is what makes everything downstream possible without knowing the experimenter's threshold. Now ask the real question: what is the *true* knee, the smallest budget — not necessarily on the grid — that would have passed?

Retention is non-decreasing in $k$, so any budget of $32$ or fewer fails outright, and $40$ certainly passes. Hence:

> **Bracket Theorem.** Every non-negative attention profile reproducing the measured table, with any gate in the recovered range, has true knee in $[33, 40]$.

And the bracket cannot be improved, because both ends are realised. Two explicit profiles reproduce the entire six-entry table:

- one that places its final $0.005$ of mass at index $32$, so retention hits $0.984$ already at $k=33$;
- one that places the same mass at index $39$, so retention stays at $0.979$ until $k=40$.

With, say, $\tau = 0.98$ their true knees are $33$ and $40$ respectively. Same table, same gate, seven keys apart. The measurement genuinely does not distinguish them: this is the **Sharpness** statement, and the interval $[33,40]$ is a property of the grid, not a weakness of the argument.

The consequence for the headline is immediate and slightly deflating. The increment at the fourth doubling is not $16$; it lies in $[9, 16]$. The advertised "four-fold acceleration" over the previous $+4$ is the *top* of a bracket whose bottom is

$$\frac{9}{4} = 2.25 .$$

The honest sentence is: **the increment at least doubles, by a factor between $2.25$ and $4$.** The direction of the effect is proved; its magnitude is grid-limited. It is worth pausing on how rarely this distinction is drawn, and how cheaply it could have been avoided — three more probes, at $34$, $36$, $38$, would collapse the bracket to a point by binary search.

What survives the bracket entirely is the deployment consequence, which needs only the lower end:

> **A 24-key cache fails at $4096$ tokens** — for *every* profile consistent with the table and *every* admissible gate. More precisely, budgets of $32$ or fewer are provably unsafe, budgets of $40$ or more are certified safe, and $33$–$39$ is exactly the undecided window.

A cache sized from the $2048$-token table will silently break when the context doubles. That is the practical content, and it does not depend on the disputed factor at all.

---

## Attention that is too flat to compress

Underneath the counting there is a mechanism. Suppose the sorted attention tail decays exponentially, $p_i \propto e^{-\lambda i}$, with a rate $\lambda_j$ that depends on the context. Requiring the tail beyond the knee to fall below a budget $\delta$ gives the clean reciprocal relation

$$k \cdot \lambda = \log(1/\delta),$$

so the knee and the decay rate are exact inverses: *the knee is the reciprocal of the peakedness of attention*. A model that spreads its attention twice as flat needs twice the cache.

This immediately converts the measured chain into a statement about rates, with no free parameters at all. From $k_1 = 20$, $k_2 = 24$, $k_3 = 40$ we get $\lambda_2 = \tfrac{5}{6}\lambda_1$ and $\lambda_3 = \tfrac{3}{5}\lambda_2$, and therefore

$$\frac{\lambda_3}{\lambda_2} \;<\; \frac{\lambda_2}{\lambda_1}.$$

The *relative* collapse of attention sharpness accelerates. And this survives the grid gap: it holds for every true knee at or above the certified lower end $33$, so the phase transition is robust even though the factor $4$ is not. A rate family previously fitted to the first three points, $\lambda_j = \lambda_0/(j+1)$, is refuted outright, since it yields a knee exactly affine in $j$. Its replacement is a crossover family whose inverse rate picks up an extra slope past the corner,

$$\lambda_j = \frac{\lambda_0}{4 + j + 3\,(j-2)_+},$$

and at $\lambda_0 = 1$ with tail budget $\delta = e^{-4}$ this reproduces the entire measured chain exactly, $16, 20, 24, 40$, with rates $\tfrac14, \tfrac15, \tfrac16, \tfrac1{10}$: a drop by $5/6$ at the third doubling and by $3/5$ at the fourth.

---

## What cannot happen, and why that helps

The three-way ambiguity at $8192$ can be narrowed without any new experiment, by adding the one constraint the physical setting cannot violate: **a cache cannot hold more keys than the context has tokens.** Call a law *feasible* if $f(j) \le 512 \cdot 2^{\,j}$ for all $j$.

The ramp and the cubic are feasible — polynomial growth against an exponential ceiling. The geometric law is not. By twelve doublings, at a context of $2^{21} \approx 2.1$ million tokens, it demands more than four million keys for a two-million-token window, and it stays above the ceiling forever after. So the reading in which the acceleration compounds indefinitely is **refuted on structural grounds, without data**. Three candidates become two, and those two are separated by a single measurement: $56$ keys at $8192$ if the ramp is right, $80$ if the cubic is.

Combining the convex floor with the feasibility ceiling traps every physically possible convex fit in a band,

$$40 + 16m \;\le\; f(m+3) \;\le\; 512 \cdot 2^{\,m+3},$$

and the band is inhabited — the ramp lives in it. Finally, the reassuring asymptotic: for *any* law growing at most polynomially in the number of doublings, the fraction of the context it retains,

$$\frac{f(j)}{512 \cdot 2^{\,j}} \;\longrightarrow\; 0 .$$

Both surviving laws are polynomial, so both keep the cache asymptotically negligible. **The phase transition changes the constant in the budget table; it does not change the fact that long-context attention is compressible.** That is the correct thing to tell someone frightened by the word "transition".

---

## Where the corner comes from

One last question, and the best one: *why $2048$?*

Two readings fit the single observation equally well. Under the **context reading**, something about attention changes past roughly two thousand tokens, for every model. Under the **budget reading**, a curve kinks not at a context length but when its knee crosses a critical budget of about $24$ keys — the corner is a property of the cache, not the page.

For the half-billion model the two readings are indistinguishable, because its pre-transition law $16+4j$ crosses $24$ keys at exactly $j=2$: the budget reading *retrodicts* the observed corner rather than merely coinciding with it. But a three-times-larger model has a gentler law, $16, 16, 18, 20, 22, 24, \ldots$, which does not reach $24$ keys until $j = 5$ — a context of $16384$ tokens, an eightfold delay.

So the two hypotheses make identical predictions on every existing measurement of the larger model and differ by exactly eight keys at the first new one: $28$ under the context reading, $20$ under the budget reading. Both rivals are perfectly respectable budget laws — convex, monotone, feasible — so the test is fair. And under either, the larger model still needs fewer keys than the smaller one at $4096$: the scale advantage survives the transition.

One cell of one table, and the question is settled. That is what it looks like when a phenomenon has been made precise enough to be dangerous to its own explanation.

---

## The shape of the argument

Strip away the subject matter and what remains is a small, transferable methodology for reading a scaling law honestly.

1. **Prove the refutation, not the replacement.** "No affine law fits" is airtight; "the law is quadratic" is a guess.
2. **Quantify the underdetermination.** Exhibit the rival continuations explicitly and compute their disagreement. Three laws, $56$ against $80$ against $92$.
3. **Extract what the weakest structural assumption forces.** Convexity alone gives $40+16m$, a permanent obligation from a single jump.
4. **Confront the grid.** A threshold read on a coarse grid is a bracket, not a number. The bracket was $[33,40]$, and the sharpness examples prove it cannot be shrunk without more probes.
5. **Use impossibility as data.** Feasibility eliminated a candidate for free.
6. **Find the right language.** Once the kink is recognised as a tropical corner, the general theorem — every monotone convex law is the max-plus polynomial of its own tangents — arrives on its own.

The headline that started all of this was a four-fold acceleration. What is left after the audit is smaller, stranger, and much more useful: a factor somewhere between $2.25$ and $4$; a corner with an exact coordinate and a tropical explanation; a cache size that is provably unsafe and a window that is provably undecided; a compounding runaway ruled out by pure counting; and a single missing experiment that would tell us whether the corner belongs to the page or to the cache.
