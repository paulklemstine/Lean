# The Price of Universality: What One Decompressor Owes to All the Files It Will Ever Meet

## A tax you have already paid

Every compressed file you have ever opened arrived with an implicit promise: somewhere on your machine there is a program that knows how to turn that opaque blob of bytes back into a photograph, a spreadsheet, a novel. That program — the *decompressor* — is shared. One copy serves your holiday photos, your tax returns, and the source code of the operating system itself. It has no idea, in advance, which of those it will be handed.

That sharing is not free. A decompressor built exclusively for English text would treat "the" as a single cheap symbol; one built exclusively for grayscale photographs would treat smooth gradients as almost free. A single decompressor that must serve both cannot be optimally tuned to either. It must pay something — some number of extra bits, per file — for the privilege of not knowing what it is about to receive.

This article is about that number. It has a name: the **price of universality**. It turns out to be computable in closed form, to obey a clean algebra, and to answer a practical engineering question with unusual sharpness: *is it worth building specialised compressors, or should we just build one good general one?*

The short answer, which the rest of this article makes precise, is: **build a library**. Specialisation genuinely helps — sometimes enormously — and merging many specialists into one shared tool is astonishingly cheap. But the price of universality is *extensive*: it grows in proportion to how much data you compress, and it can never be amortised away by batching. And when a class of data has no structure at all, specialisation buys you exactly nothing: the bits you think you saved simply move from the message into the name of the decompressor.

## Setting the stage: sources, classes, and the cost of a guess

Fix a finite universe $\mathcal{X}$ of possible messages — say, all files of exactly $n$ bytes. A **source** is a probability distribution $p$ on $\mathcal{X}$: it says how likely each message is. Shannon's foundational theorem tells us that if we know $p$, the best possible code spends about $\log_2 (1/p(x))$ bits on the message $x$, and on average
$$H(p) \;=\; -\sum_{x} p(x)\log_2 p(x)$$
bits per message — the *entropy*. No code does better. That is the gold standard: what a perfectly specialised decompressor achieves.

But we never know $p$. What we typically know is a **class** of candidate sources, $\mathcal{S} = \{p_\theta : \theta \in \Theta\}$ — "English text with some unknown letter frequencies", "a Markov chain with some unknown transition matrix", "an image with some unknown noise level". The parameter $\theta$ is unknown; the class is known.

Now the question sharpens. We must commit to a single code — equivalently, to a single distribution $q$ used for coding — and the nature will then reveal some $\theta$. Our loss on the message $x$ is the number of bits we spend, $\log_2(1/q(x))$, minus what the oracle who knew $\theta$ would have spent, $\log_2(1/p_\theta(x))$. That difference,
$$\log_2 \frac{p_\theta(x)}{q(x)},$$
is called the **regret**. The universal coder wants to keep it small no matter which $\theta$ nature picks and no matter which $x$ it produces.

## The Shtarkov sum: one number that says it all

Here is the surprise. Play the game in its most pessimistic form: minimise, over all coding distributions $q$, the *worst* regret over all $\theta$ and all $x$ simultaneously. The answer is not an intractable optimisation. It is a single explicit number.

Define the **maximum likelihood envelope** of the class,
$$\hat p(x) \;=\; \sup_{\theta \in \Theta} p_\theta(x),$$
the best explanation any member of the class can offer for the message $x$. This envelope is not a probability distribution — its total mass exceeds $1$, because different messages are explained best by different parameters. That excess mass is the whole story. The **Shtarkov sum** of the class is
$$C_{\mathcal{S}} \;=\; \sum_{x \in \mathcal{X}} \hat p(x) \;\;\ge\; 1,$$
and normalising the envelope gives the **normalised maximum likelihood code**, $q^*(x) = \hat p(x)/C_{\mathcal{S}}$. Against this code, the regret on *every* message and *every* parameter is at most $\log_2 C_{\mathcal{S}}$, and no code does better in the worst case.

So the price of universality of a class is exactly
$$\boxed{\;\text{price}(\mathcal{S}) \;=\; \log_2 C_{\mathcal{S}}\ \text{bits}.\;}$$

Everything that follows is the study of this one functional: how it behaves when you combine classes, when you enlarge them, when you split the data into blocks — and what it says about compressor design.

## Diversity is what you pay for

Why should a class cost anything at all? Because its members disagree. Here is an identity so simple it is almost a slogan. For two probability distributions $p$ and $p'$, the total variation distance is $\|p - p'\|_{\mathrm{TV}} = \tfrac12 \sum_x |p(x) - p'(x)|$, and one line of algebra using $\max(a,b) = \tfrac{a+b+|a-b|}{2}$ gives
$$\sum_x \max\bigl(p(x), p'(x)\bigr) \;=\; 1 + \|p - p'\|_{\mathrm{TV}}.$$

**Diversity Bound.** *For any two members $p_\theta, p_{\theta'}$ of a class, $C_{\mathcal{S}} \ge 1 + \|p_\theta - p_{\theta'}\|_{\mathrm{TV}}$.* The proof is immediate: the envelope $\hat p$ dominates the pointwise maximum of any two members.

Three consequences follow at once, and together they close the question of when universality is free.

**No free universality.** The Shtarkov sum equals $1$ — the price is zero — *if and only if* every member of the class is the same distribution. Any genuinely non-degenerate class, containing two sources that differ at even a single message, pays a strictly positive price. There is no clever code that serves two genuinely different sources at no cost. Whatever you gain on one, you lose on the other.

**Specialisation never hurts.** If you shrink a class — restrict your decompressor to a sub-family of sources — the envelope can only shrink, so the price can only go down. Narrowing your ambitions is always, mathematically, rewarded.

**The price is extensive.** This is the sting in the tail, and it needs the algebra of the next section.

## The algebra: two operations, two laws

Real data is not one monolithic object drawn from one class. It arrives in blocks, and it arrives in kinds. The two corresponding operations on classes are the *independent product* and the *union*, and each obeys a clean law.

### Products: the price simply adds

Suppose the message splits into two independent blocks, the first drawn from a class $\mathcal{S}_1$ on $\mathcal{X}_1$ and the second from a class $\mathcal{S}_2$ on $\mathcal{X}_2$, with independently chosen parameters. The product class $\mathcal{S}_1 \otimes \mathcal{S}_2$ has members $p_{\theta_1} \otimes p_{\theta_2}$.

**Multiplicativity Theorem.** *The maximum likelihood envelope factorises,*
$$\widehat{p_1 \otimes p_2}(x_1, x_2) \;=\; \hat p_1(x_1)\,\hat p_2(x_2),$$
*and therefore the Shtarkov sums multiply:* $C_{\mathcal{S}_1 \otimes \mathcal{S}_2} = C_{\mathcal{S}_1} \cdot C_{\mathcal{S}_2}$. *In bits, the price is **additive**:*
$$\text{price}(\mathcal{S}_1 \otimes \mathcal{S}_2) = \text{price}(\mathcal{S}_1) + \text{price}(\mathcal{S}_2).$$

The factorisation of the envelope looks obvious, and one direction is: the best joint explanation is at least as good as the product of the two best separate explanations, and at most as good too, because the parameters are chosen independently. But the "at most" direction hides a genuine subtlety when $\Theta$ is infinite and the suprema are not attained by any particular parameter. The argument is a two-step squeeze: first fix a parameter $\theta_2$ for the second block and show $\hat p_1(x_1)\, p_{\theta_2}(x_2) \le \widehat{p_1 \otimes p_2}(x_1,x_2)$ by dividing through and taking the supremum over $\theta_1$; then divide by $\hat p_1(x_1)$ and take the supremum over $\theta_2$. Degenerate cases where one factor vanishes are handled separately. The result holds for arbitrary parameter sets — no compactness, no attainment.

Additivity is the bad news for anyone hoping to amortise. If a single block costs you half a bit of universality, then a thousand independent blocks cost five hundred bits, not half a bit. Combine this with the diversity bound and you get the sharp statement:

**Tensorised Diversity Bound.** *If a class contains two sources at total variation distance $\delta$, then $k$ independent blocks of that class cost at least $k \log_2(1 + \delta)$ bits of universality.*

The price of universality is not an overhead you pay once at the start of the stream. It is a *tax rate*, levied per block, forever.

### Libraries: merging specialists is nearly free

Now the opposite construction, and the good news. Suppose you have $K$ specialised classes — one for text, one for photographs, one for audio, one for executables — living on the same message space, and you do not know in advance which one your file comes from. Form the **library**: the class whose parameter is a pair (which family, which parameter within it).

**Library Bounds.** *Let $\mathcal{L}$ be the library of classes $\mathcal{S}_1,\dots,\mathcal{S}_K$. Then*
$$\max_{i} C_{\mathcal{S}_i} \;\le\; C_{\mathcal{L}} \;\le\; \sum_{i=1}^K C_{\mathcal{S}_i}.$$

Both halves are one-liners once the envelope is understood. The library's envelope dominates each member's envelope (a member's best explanation is available to the library too), which gives the lower bound. And the library's envelope at any message is at most the sum of the members' envelopes at that message, which gives the upper bound after summing over messages.

Translated into bits, with $B$ an upper bound on every member's Shtarkov sum:

**Price of a Library.** *A single decompressor universal for all $K$ specialised families costs at most*
$$\log_2 K \;+\; \max_i\, \text{price}(\mathcal{S}_i)\ \text{bits},$$
*and at least $\max_i \text{price}(\mathcal{S}_i)$ bits.*

That $\log_2 K$ is the entire cost of not knowing which specialist to consult. Eight specialists cost three extra bits. A thousand specialists cost ten. Against files of thousands of bytes, this is nothing. **A library of specialised decompressors is essentially as good as knowing which one to use** — the gap between the two is $\log_2 K$ bits, and no more.

Put the two laws side by side and the design guidance is unambiguous. Splitting data into independent blocks multiplies your universality cost; splitting your *models* into a library adds only a logarithm. Model diversity is cheap. Data volume is expensive.

## Average case: the same story in a softer voice

The worst-case regret is a pessimist's accounting: it charges the code for its single most embarrassing message. The classical alternative asks about averages. If nature picks $\theta$ and generates data from $p_\theta$, the code $q$ spends $\mathbb{E}_{p_\theta}\log_2(1/q)$ bits on average, against the oracle's $H(p_\theta)$; the excess is the Kullback–Leibler divergence
$$D(p_\theta \,\|\, q) \;=\; \sum_x p_\theta(x)\log_2 \frac{p_\theta(x)}{q(x)} \;\ge\; 0.$$
(Non-negativity is Gibbs' inequality, and it *is* Shannon's source-coding bound: no code beats the entropy on average.)

Here the central identity is the **compensation identity**. Put a prior $w$ on the parameter and form the Bayes mixture $m_w(x) = \sum_\theta w(\theta)\, p_\theta(x)$. Then for *every* coding distribution $q$,
$$\sum_\theta w(\theta)\, D(p_\theta \,\|\, q) \;=\; I(w) \;+\; D(m_w \,\|\, q),$$
where $I(w) = \sum_\theta w(\theta) D(p_\theta \| m_w)$ is the mutual information between parameter and message. This is exact bookkeeping. The first term is the *unavoidable* price of universality under the prior $w$ — paid even by the best possible universal code. The second is *avoidable*, and vanishes precisely when $q$ is the mixture. So the Bayes mixture is the optimal universal code, and its cost is a mutual information — a channel capacity, in disguise.

From this one identity everything else falls out. Since a weighted average is at most a maximum: **redundancy exceeds capacity** — whatever code you choose, for every prior $w$ there is a source in the class paying at least $I(w)$ bits. In the other direction, the mixture is never worse than the two-part code: $D(p_\theta \| m_w) \le \log_2 (1/w(\theta))$, which under the uniform prior is $\log_2|\Theta|$ — literally the cost of writing down the name of the source. And the worst-case theory dominates: the normalised maximum likelihood code pays at most $\log_2 C_{\mathcal{S}}$ bits *on average* against every source, so the average-case price never exceeds the worst-case price. All the library and product bounds therefore hold in the average-case world too.

## When is the price exactly what you feared?

Two natural situations pin the price down exactly, and they are the two poles of the design question.

**Mutually singular classes cost everything.** Suppose the sources live on pairwise disjoint sets of messages — each source can only produce "its own" files. Then the universal code must pay exactly $\log_2 |\Theta|$ bits on average: the uniform mixture achieves it, and no coding distribution beats it against all members. The intuition is a pigeonhole argument in disguise: the coding distribution has only one unit of mass to spread over $|\Theta|$ disjoint supports, so some support gets at most $1/|\Theta|$ of it, and the source living there pays $\log_2|\Theta|$ bits. Reassuringly, this is not a knife edge: if the sources merely *concentrate*, each putting mass at least $1-\delta$ on its own set, the price is still at least $(1-\delta)\log_2 |\Theta| - 4$ bits.

**Conservation of bits.** Now specialise to *file types*. Classify each file by its type $c$ — say by extension — and let $P_c$ be uniform on the files of type $c$. A decompressor that already knows the type needs $\log_2 \#\{\text{files of type } c\}$ bits per file, its entropy. The theorem says: for every code obeying the Kraft inequality, there is a type $c$ on which the code spends, on average, at least
$$\log_2 \#\{\text{files of type } c\} \;+\; \log_2 \#\{\text{types}\}$$
bits. Specialising the decompressor moves *exactly* $\log_2 \#\{\text{types}\}$ bits out of the message and into the identity of the decompressor. Never more, never less. If your "specialisation" consists in carving an unstructured set into pieces, you have simply relabelled the bits: the total description length is conserved. In the cleanest version — messages consisting of a type block and a payload block — every code spends, for some type, at least the length of the whole message.

**But real structure is worth a growing number of bits.** Contrast that with a class that genuinely has low complexity. On $n$-bit files:

- the class of *all* files (equivalently, all point masses) costs exactly $n$ bits — the entire message, which is the pigeonhole bound recovered as a special case;
- the *memoryless* class over an alphabet $A$ — independent symbols with unknown frequencies — costs at most $|A| \log_2(n+1)$ bits;
- the *first-order Markov* class costs at most $\log_2 |A| + |A|^2 \log_2(n+1)$ bits.

The gap $n - 2\log_2(n+1)$ between "no assumptions" and "memoryless" grows without bound. **The price of universality is governed by the complexity of the class, not by the length of the data.** Moving bits from the message into a shared decompressor is worthwhile exactly when the data class is genuinely low-complexity — and then it is worth an unbounded number of bits.

A beautiful class makes the logarithmic rate exact rather than merely an upper bound. The **constant-composition** sources on $n$ bits — for each $j$, the uniform distribution on strings with exactly $j$ ones — have disjoint supports, so their Shtarkov sum is exactly $n+1$ and their price is exactly $\log_2(n+1)$ bits, worst case and on average. These are precisely the conditional laws of memoryless sources given their empirical frequency, so the logarithmic Rissanen rate is not an artefact of a lossy upper bound: a natural class attains it on the nose. The associated conservation law reproduces the familiar two-part-code accounting: the entropy $\log_2\binom{n}{j}$ of the composition, plus $\log_2(n+1)$ bits to name it.

## What this means for building compressors

Collect the verdicts.

1. **Specialisation is real, and it is worth pursuing** — but only when the specialised class is genuinely simpler, in the precise sense that its Shtarkov sum grows slowly with the data length. Structure that reduces a class from "all files" ($n$ bits) to "memoryless" ($O(\log n)$ bits) moves an unbounded number of bits out of the message.
2. **Carving up an unstructured set is not specialisation.** The conservation law shows that partitioning $n$-bit files into types just relocates the bits from the payload into the type label. If you want a win, the specialised classes have to be *low-complexity*, not merely *small*.
3. **Build a library, not a monolith.** Merging $K$ specialised decompressors into one costs at most $\log_2 K$ bits over the most expensive specialist. This is the single most actionable consequence: there is essentially no penalty for carrying many models, so the practical strategy is to carry as many well-fitted specialists as you can and pay the tiny naming cost.
4. **Do not expect batching to help.** The price adds over independent blocks, so it scales linearly with the volume of data. Any hope of amortising the cost of universality over a long stream is misplaced: the cost per block is a constant, and a constant per block is a linear total.
5. **The floor is diversity.** A class costs at least $\log_2(1 + \delta)$ bits, where $\delta$ is the largest total variation distance between two of its members, and this floor tensorises. There is no clever engineering around it.

## Coda: the shape of the answer

There is an aesthetic pleasure in how tightly this theory closes. A single scalar — the excess mass of the maximum likelihood envelope — captures the entire worst-case cost of not knowing your data. It is multiplicative over independent products and subadditive over unions, so in bits the price of universality behaves like a *valuation* on the algebra of source classes: additive over data, logarithmic over models. It is bounded below by statistical distance, so it vanishes only in the degenerate case. And in the average-case world the same quantity reappears as a mutual information, with a compensation identity separating the payable from the unpayable exactly.

The pigeonhole principle tells us that no compressor can shrink everything. The theory of universal redundancy tells us something more useful: exactly how much of that irreducible cost is due to *ignorance*, as opposed to *incompressibility* — and, in bits, exactly what knowledge is worth.
