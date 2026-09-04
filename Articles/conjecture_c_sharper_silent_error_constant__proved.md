# The Right to Say "I Don't Know"

### How one carefully chosen hash key, and one word of humility, make compression almost lossless

---

## A compression scheme that lies

Imagine a system that receives a stream of messages and must store each one in far less space than the message itself occupies. Photographs, sensor readings, the tokens flowing through a language model's cache — all of them get squeezed. Compression below the information content of the source is, by an old and unavoidable counting argument, sometimes wrong. The interesting question is not *whether* it is wrong but *how* it is wrong.

There are two ways to be wrong, and they are not remotely equal.

The first is to **fail loudly**: the decompressor looks at the stored code, cannot determine which message produced it, and announces that it cannot. Somebody retransmits; a fallback path fires; a log line is written. This is an inconvenience.

The second is to **fail silently**: the decompressor looks at the stored code, confidently reconstructs *a* message, and hands back the wrong one. Nobody is told. The wrong pixel, the wrong sensor reading, the wrong token propagates downstream and is treated as ground truth. This is a catastrophe wearing the costume of a success.

Everyone who has built such a system knows the distinction in their bones, but for a long time the mathematics treated the two as one lump called "error probability." This article is about splitting that lump — about a family of theorems that quantifies, exactly, how cheaply silent corruption can be bought, what the price is in loud failures, and why the whole enterprise depends on the decoder being allowed to answer *"I don't know."*

---

## The setup: a codebook and a hash

Fix a finite alphabet $\mathcal{X}$ of possible messages and a probability distribution $\mu$ on it. Real sources are lopsided: a small set of *typical* messages carries almost all the probability, and a vast tail carries almost none. Write that formally: choose a list $l = (x_1,\dots,x_n)$ of distinct typical messages — the **codebook** — and let $\delta$ measure the mass it misses,
$$\mu\left(\mathcal{X}\setminus l\right) \le \delta .$$
The list is the part of the world we intend to represent faithfully; $\delta$ is the atypical residue.

Now the encoder. We do not build a bespoke dictionary; we hash. Fix a family of functions
$$H_1,\dots,H_K : \mathcal{X}\to\{1,\dots,M\},$$
each mapping any message to one of $M$ codewords. The family is **2-universal** if, for any two distinct messages $x\ne y$, at most a $1/M$ fraction of the keys make them collide:
$$\#\{k : H_k(x)=H_k(y)\}\cdot M \le K .$$
Such families are cheap and classical — the maps $x\mapsto (ax+b \bmod p) \bmod M$ over a prime field are the textbook example. Picking a key $k$ picks an encoder: $x \mapsto H_k(x)$, a number between $1$ and $M$. That is the entire compressed representation.

And the decoder. Given a received codeword $i$, it scans the codebook once and collects every $x_j\in l$ with $H_k(x_j)=i$.

- If **exactly one** codebook entry matches, output it.
- If **none** or **several** match, output nothing — *abstain*.

That one design choice, the reject option, is the hero of this story. The scan costs exactly $n = |l|$ hash evaluations, always, no matter what.

Three things can now happen to a message $x$ drawn from $\mu$. The scheme **succeeds** if the decoder returns $x$ itself. It **abstains** if the decoder returns nothing. And it **corrupts silently** if the decoder returns some $y\ne x$. Note the crucial structural fact: a silent corruption requires $x$ to be *outside* the codebook (otherwise $x$ itself would be among the matches, so the unique match is $x$) and to collide with exactly one codebook entry. Silent corruption is therefore a **second-order event**: it needs both an atypical message *and* a hash collision. Loud failure needs only one of the two.

Write $L = |l|/M$ for the *load* — codebook entries per codeword — the natural collision-rate parameter. A single random key gives, on average, collision mass at most $L$ overall and at most $\delta L$ inside the atypical region. If we could use a fresh random key each time, we would get failure $\lesssim \delta + L$ and silent corruption $\lesssim \delta L$ for free. But randomness at decode time is a luxury: the decoder must know the key. We want **one fixed key** that is simultaneously good for both events. That is the derandomization problem, and it is where the mathematics begins.

---

## One key, two demands, and a hyperbola

Averaging tells us the *mean* is small; it does not produce a key. The classical move is Markov's inequality. Fix a threshold $c>0$ and call a key *bad at level $c$ for a region $A$* if its collision mass inside $A$ exceeds $c$ times the average. Markov says: **strictly fewer than $K/c$ keys are bad**. Sharpening this from the usual "at most" to a strict inequality is what makes the whole argument work at the boundary.

Now we have two demands and hence two bad sets: keys bad at level $c_2$ for the whole space (which governs loud failure) and keys bad at level $c_1$ for the atypical region (which governs silent corruption). Their densities are below $1/c_2$ and $1/c_1$. A key surviving both exists as soon as those densities cannot fill the key space:

> **Covering condition.** If $c_1, c_2 > 0$ and $\dfrac{1}{c_1}+\dfrac{1}{c_2}\le 1$, then some key is simultaneously good for both regions.

Feeding that key into the scheme yields the central achievability statement.

> **Frontier Theorem.** For every $c>1$ there is a single key whose scheme satisfies
> $$\Pr[\text{silent corruption}] \;\le\; c\,\delta\,\frac{|l|}{M}, \qquad \Pr[\text{failure}] \;\le\; \delta + \frac{c}{c-1}\cdot\frac{|l|}{M},$$
> with decoding cost exactly $|l|$ hash evaluations.

The pair $(c_1,c_2) = \big(c,\ c/(c-1)\big)$ traces a hyperbola — the *admissible frontier* — and every point on it is realised by an actual key. The point $c=2$ gives the symmetric scheme with both constants equal to $2$. Pushing $c$ down toward $1$ drives the silent constant to the **first-moment optimum** $1$, the value you would get from a fresh random key:

> **Near-optimal silent constant.** For every $\varepsilon>0$ there is a single key with silent-corruption probability at most $(1+\varepsilon)\,\delta\,|l|/M$, at the price of failure probability at most $\delta + \frac{1+\varepsilon}{\varepsilon}\cdot|l|/M$.

So the silent constant is not stuck at $2$; it can be pushed arbitrarily close to the theoretical floor. But you pay: the failure constant $\frac{1+\varepsilon}{\varepsilon}$ blows up. Trade-offs are the natural habitat of this subject, so the honest question is: *where on the hyperbola should you sit?*

---

## The $\sqrt{\delta}$ sweet spot

Add the two error probabilities. The total is $\delta + (c_2 + c_1\delta)L$, so the whole design question collapses to minimising the single number $c_2 + c_1\delta$ over the admissible region $\frac{1}{c_1}+\frac{1}{c_2}\le 1$. This is a Cauchy–Schwarz problem in disguise, and it has an exact answer.

> **Frontier Optimality.** For every $\delta\ge 0$ and every admissible pair $c_1,c_2>0$ with $\frac1{c_1}+\frac1{c_2}\le 1$,
> $$c_2 + c_1\delta \;\ge\; \big(1+\sqrt{\delta}\,\big)^2 ,$$
> with equality exactly at $c_1 = 1+\frac{1}{\sqrt{\delta}}$, $c_2 = 1+\sqrt{\delta}$.

The proof is a one-line algebraic identity that deserves to be seen. With $s=\sqrt{\delta}$,
$$\big(c_2 + c_1 s^2\big)\left(\frac{1}{c_1}+\frac{1}{c_2}\right) \;=\; (1+s)^2 \;+\; \frac{(c_2-c_1 s)^2}{c_1c_2}.$$
The left-hand side is at most $c_2+c_1s^2$ because the second factor is at most $1$; the excess on the right is a perfect square. So the inequality is forced, and equality holds precisely when $c_2 = c_1 s$ — the *balanced ray*. Intersecting that ray with the boundary hyperbola $\frac1{c_1}+\frac1{c_2}=1$ pins down the unique optimum.

Substituting it gives the headline scheme of this work.

> **The $\sqrt{\delta}$-Balanced Scheme.** For any source with atypical mass at most $\delta>0$, a *single explicit key* of the 2-universal family achieves, simultaneously:
> 1. failure probability at most $\displaystyle \delta + (1+\sqrt{\delta})\frac{|l|}{M}$;
> 2. silent-corruption probability at most $\displaystyle (\sqrt{\delta}+\delta)\frac{|l|}{M}$;
> 3. total error probability at most $\displaystyle \delta + (1+\sqrt{\delta})^2\frac{|l|}{M}$;
> 4. decoding cost exactly $|l|$ hash evaluations.

Look at what happens as the source becomes cleaner, $\delta\to 0$. The failure constant $1+\sqrt{\delta}\to 1$: derandomization becomes *free*, matching the best a fresh random key could do. The silent constant $\sqrt\delta + \delta \to 0$: silent corruption is not merely bounded, it becomes negligible compared with loud failure — it is $O(\sqrt{\delta}\,|l|/M)$, genuinely second order. No fixed point on the hyperbola achieves both limits; you have to move along it as $\delta$ shrinks, and $c_1 = 1+1/\sqrt\delta$ tells you exactly how fast. For every $\delta\le 1$ the balanced constants beat the symmetric ones, $1+\sqrt\delta \le 2$ and $(1+\sqrt\delta)^2\le 4$.

The word "optimal" here is precise and worth being careful about. The bound $(1+\sqrt\delta)^2$ is the exact optimum *of this method* — of everything reachable by counting bad keys and taking a union bound. It rules out, in particular, the naive hope of getting the ideal pair $(1,\delta)$ at once: $c_2=1$ forces $c_1=\infty$.

---

## Where the method stops — and why that's a theorem too

A satisfying feature of this story is that the covering condition $\frac1{c_1}+\frac1{c_2}\le 1$ is not a convenient artefact of the proof. It is exactly the boundary.

> **Necessity of the Covering Condition.** Suppose $\frac1{c_1}+\frac1{c_2}>1$, quantitatively $K\big(\frac1{c_1}+\frac1{c_2}-1\big)>1$. Then there exist two subsets $B_1,B_2$ of the key space with $|B_i|\,c_i < K$ — sizes strictly below what Markov's inequality permits — whose union is the *entire* key space.

The construction is disarmingly simple: cut the keys $\{1,\dots,K\}$ at the index $\lceil K/c_1\rceil-1$. The lower block is below the $c_1$-threshold by the ceiling bound; the upper block is below the $c_2$-threshold precisely because of the assumed density excess; together they cover everything. So no union-bound argument at thresholds violating the covering condition can ever produce a good key. The method has a sharp edge, and we know where it is.

---

## Fairness: protecting every group, not just the average

Counting arguments are not limited to two regions. If you have any finite family of regions $A_1,\dots,A_r$ and thresholds $c_1,\dots,c_r$ with $\sum_i 1/c_i \le 1$, the same union bound produces **one key good on all of them at once**. This has a direct machine-learning payoff.

A compressed model that reports an aggregate silent-error rate of $0.1\%$ may still be silently mislabelling one subpopulation ten times more often than another. Aggregate bounds say nothing about individuals.

> **Group-wise Silent-Error Control.** Let $G_1,\dots,G_r$ be arbitrary (possibly overlapping) protected subpopulations. A single key achieves global failure probability at most $\delta + (r+1)\frac{|l|}{M}$ and, for *every* group $g$,
> $$\Pr[\text{silent corruption inside } g] \;\le\; (r+1)\,\mu\big(g\setminus l\big)\,\frac{|l|}{M}.$$

The bound is *local*: it is driven by the mass of the part of that group the codebook misses, not by the worst group. A well-covered subpopulation is protected proportionally better. The entire price for controlling $r$ groups plus the global failure event with one key is a single factor $r+1$, coming from $\sum_{i=1}^{r+1}\frac{1}{r+1}=1$.

## Tags: exponential suppression for free

There is a purely practical way to buy more safety. Append a short **tag** to each codeword: a second hash, driven by an *independent* key, into $\{1,\dots,T\}$. A silent corruption now requires the codeword *and* the tag to collide. Formally this rests on a clean structural lemma: **the product of two 2-universal families is 2-universal** over the product key space and the product codeword space, with the collision densities $1/M$ and $1/T$ multiplying exactly. Hence a tagged balanced scheme with a $T$-valued tag achieves silent corruption at most $(\sqrt\delta+\delta)\frac{|l|}{MT}$ and failure at most $\delta+(1+\sqrt\delta)\frac{|l|}{MT}$ — with the scan cost still exactly $|l|$. With $T=2^t$, silent corruption is *exponentially rare in the tag length*: $t$ extra bits turn would-be silent lies into detected failures.

---

## The punchline: abstention is not a convenience, it is a necessity

Everything above depends on the decoder's right to answer "I don't know." A natural suspicion is that this is a technical convenience — that a cleverer decoder, one that always commits, could do just as well. It cannot, and the reason is elementary and absolute.

Let $p_{\max} = \max_x \mu(x)$ be the largest atom of the source; $M\cdot p_{\max}$ is a proxy for "how much mass the code can possibly carry", since correct decoding is injective on the set of successfully decoded messages, and that set has at most $M$ elements. Every message is either decoded correctly, abstained on, or silently corrupted — a trichotomy — so the three masses sum to at least $1$, and the first is at most $M p_{\max}$.

> **Abstention Trade-off.** For *every* encoder–decoder pair whatsoever, over a code of size $M$,
> $$\Pr[\text{silent corruption}] + \Pr[\text{abstention}] \;\ge\; 1 - M\,p_{\max}.$$

Below the min-entropy of the source, a decoder can suppress silent errors *only* by abstaining. There is a conserved quantity, and you choose how to spend it. In particular:

> **Committing decoders must lie.** If the decoder never abstains, its silent-corruption probability is at least $1 - M p_{\max}$. In the genuinely compressive regime $M p_{\max} \le \tfrac12$, that is at least $\tfrac12$.

Half the time. Confidently. With no warning. And this is not a statement about hash-based schemes: it holds for *arbitrary* encoders and decoders, however cleverly designed.

Put the two halves together and the picture snaps into focus.

> **The Abstention Separation.** Fix a source with atypical mass at most $\delta$ and a code size $M$ small enough to be a real compression, $M p_{\max}\le \frac12$. Let $\varepsilon$ be any target reachable by the balanced bound, $(\sqrt\delta+\delta)\frac{|l|}{M}\le\varepsilon$. Then:
> - **(with abstention)** some key gives silent-corruption probability at most $\varepsilon$, failure probability at most $\delta+(1+\sqrt\delta)\frac{|l|}{M}$, and decoding cost exactly $|l|$;
> - **(without abstention)** *every* scheme over the same code space whose decoder always commits has silent-corruption probability at least $\tfrac12$.

The gap is $\tfrac12 - \varepsilon$, and $\varepsilon$ can be made as small as you like by enlarging $M$. The ratio between the two is unbounded. Silent corruption is therefore **not an intrinsic cost of compressing below the min-entropy**. It is entirely an artefact of forcing the decoder to answer.

---

## Why this matters outside the theorem

The reject option is not an exotic device. It is the *selective prediction* or *abstention* setting in machine learning, where a classifier may decline to label an input it does not recognise; it is the checksum that says "corrupt block, retransmit"; it is the retrieval system that returns nothing rather than a plausible-looking wrong document; it is the model that says "I'm not sure."

What the mathematics here says is that this behaviour is not politeness or product design. It is the only mechanism by which a system operating below its information budget can avoid being confidently wrong a constant fraction of the time. The conservation law $\text{silent} + \text{abstain} \ge 1 - M p_{\max}$ has no escape clause: the mass has to go somewhere, and if you forbid the "I don't know" bucket, it all lands in the "confident lie" bucket.

And the achievability side says the good news is quantitative and cheap. One fixed key, chosen once and known to everyone. A codebook scan of exactly $|l|$ steps, no adaptivity, no data-dependent cost. Silent corruption at $(\sqrt\delta+\delta)\frac{|l|}{M}$ — second-order in the source's atypicality, divisible by a further $2^{-t}$ with $t$ tag bits — and every protected subgroup covered by its own local guarantee rather than an average that hides it.

The exact optimum $(1+\sqrt\delta)^2$, the perfect-square identity that proves it, the interval-splitting construction that marks the method's boundary, the trichotomy that makes abstention indispensable: a small, complete circle of ideas. What they add up to is a licence, backed by a theorem, for machines to admit uncertainty.
