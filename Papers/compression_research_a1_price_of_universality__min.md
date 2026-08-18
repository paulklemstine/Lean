# The Price of Universality

### *What one shared decompressor owes to every file it will ever meet*

---

Every compressed file arrives with an implicit promise: somewhere there is a program that knows how to turn it back into a photograph, a spreadsheet, a novel. That program — the **decompressor** — is shared. One copy serves all of them, and it has no idea in advance which it will be handed.

That sharing is not free, and this page is about exactly how expensive it is. By the end you will be able to compute, for any family of data sources, the precise number of extra bits that a single universal decompressor must pay — and you will know two structural laws that tell a compression engineer what to build.

> **The two laws, in one sentence each.**
> *Splitting your data into independent blocks multiplies the cost. Splitting your models into a library adds only a logarithm.*

---

## 1. The set-up: sources, classes, and regret

Fix a finite set $\mathcal{X}$ of possible messages — say all files of exactly $n$ bits. A **source** is a probability distribution $p$ on $\mathcal{X}$. [Shannon's source coding theorem](https://en.wikipedia.org/wiki/Shannon%27s_source_coding_theorem) says that a code which *knows* $p$ spends about $\log_2\bigl(1/p(x)\bigr)$ bits on the message $x$, and on average the **entropy**

$$H(p) \;=\; -\sum_{x\in\mathcal{X}} p(x)\log_2 p(x)$$

bits — and that nothing does better. That is our gold standard: what a perfectly specialised decompressor achieves.

But we never know $p$. What we know is a **class** $\mathcal{S} = \{p_\theta : \theta\in\Theta\}$ of candidates: "English text with unknown letter frequencies", "a Markov chain with unknown transitions", "an image with unknown noise level". We must commit to one coding distribution $q$; nature then reveals $\theta$ and produces $x$. Our loss, the **regret**, is

$$\log_2\frac{p_\theta(x)}{q(x)} \;=\; \underbrace{\log_2\frac{1}{q(x)}}_{\text{bits we spend}} \;-\; \underbrace{\log_2\frac{1}{p_\theta(x)}}_{\text{bits the oracle spends}}.$$

<details>
<summary><b>Why "regret" and not just "extra bits"?</b> (click to expand)</summary>

Because the comparison is against a *hindsight* benchmark. The oracle is not merely lucky; it is allowed to look at the data and pick the member of the class that explains it best. Measuring against that benchmark is what makes the answer a property of the *class*, independent of any assumption about which source is "really" active. It is the same move that defines regret in [online learning](https://en.wikipedia.org/wiki/Online_machine_learning) and in [minimax decision theory](https://en.wikipedia.org/wiki/Minimax_estimator).
</details>

---

## 2. One number says it all: the Shtarkov sum

Here is the surprise that makes the whole theory work. Minimise the *worst* regret over all $\theta$ and all $x$ at once, and the answer is not an intractable optimisation — it is a single explicit number.

Define the **maximum likelihood envelope**, the best explanation the class can offer for each message:

$$\hat p(x) \;=\; \sup_{\theta\in\Theta} p_\theta(x).$$

The envelope is *not* a probability distribution: its total mass exceeds $1$, because different messages are explained best by different parameters. That excess is the whole story. The **Shtarkov sum** is

$$C_{\mathcal{S}} \;=\; \sum_{x\in\mathcal{X}}\hat p(x)\;\ge\;1,$$

and normalising the envelope gives the **normalised maximum likelihood code** $q^{*}(x) = \hat p(x)/C_{\mathcal{S}}$. Against it the regret is at most $\log_2 C_{\mathcal{S}}$ for *every* $\theta$ and *every* $x$, and no code does better in the worst case:

$$\min_q\;\max_{\theta,\,x}\;\log_2\frac{p_\theta(x)}{q(x)} \;=\; \log_2 C_{\mathcal{S}}.$$

This quantity is **the price of universality** of the class.

<details>
<summary><b>The two-line proof of minimaxity</b></summary>

*Upper bound.* By definition $p_\theta(x)\le \hat p(x) = C_{\mathcal{S}}\,q^{*}(x)$, so the regret of $q^{*}$ is at most $\log_2 C_{\mathcal{S}}$ everywhere.

*Lower bound.* Suppose some $q$ has regret at most $r$ everywhere, i.e. $p_\theta(x)\le 2^{r}q(x)$ for all $\theta,x$. Taking the supremum over $\theta$ gives $\hat p(x)\le 2^{r}q(x)$; summing over $x$ gives $C_{\mathcal{S}}\le 2^{r}\sum_x q(x)\le 2^{r}$, i.e. $r\ge \log_2 C_{\mathcal{S}}$. $\blacksquare$

The whole minimax problem collapses because the envelope is defined pointwise, so the constraint "small regret everywhere" is a pointwise domination, and pointwise domination sums.
</details>

Let us make this tangible before going further.

{{visualization:0}}

The left-hand panel is the entire idea in one picture: two sources, each of mass $1$, and their envelope, of mass $C$. The shaded surplus is what you pay for. The right-hand panel foreshadows §4: for a class of exactly *two* sources, the Shtarkov sum equals $1$ plus the total variation distance between them, exactly.

---

## 3. Play with it: the laboratory

Now take the controls. Everything below is computed live by exhaustive summation over the message space — nothing is fitted or approximated.

{{interactive_demo:0}}

**Things worth trying.**

1. **Set $\theta_A = \theta_B$.** The price drops to exactly $0$ bits. A class with one member costs nothing — and, as we will prove in §4, that is the *only* way universality is free.
2. **Pull the two parameters apart.** Watch $C$ rise towards $2$: two nearly disjoint sources cost nearly one full bit, because the code must effectively say which of them is speaking.
3. **Drag the block slider in panel 2.** The bars rise linearly. That is additivity, and it is the bad news: universality is a tax per block, never a one-off overhead.
4. **Drag $K$ in panel 3 while the specialists are sharply separated.** The true library price hugs the top of the guaranteed band — you are genuinely paying $\log_2 K$ bits to name the model. Now reduce the spread so the specialists overlap: the price falls to the bottom of the band, because there is almost nothing to name.

---

## 4. Why anything is ever paid: the diversity floor

Why should a class cost anything at all? Because its members disagree — and the amount they disagree is *precisely* what you pay. The bridge between "supremum of likelihoods" and "statistical distance" is an identity so simple it is almost a slogan. With the [total variation distance](https://en.wikipedia.org/wiki/Total_variation_distance_of_probability_measures) $\|p-q\|_{\mathrm{TV}} = \frac12\sum_x|p(x)-q(x)|$:

$$\sum_x \max\bigl(p(x),q(x)\bigr) \;=\; 1 + \|p-q\|_{\mathrm{TV}}.$$

> **Theorem (Diversity bound).** For any two members of a class,
> $$1 + \|p_\theta - p_{\theta'}\|_{\mathrm{TV}} \;\le\; C_{\mathcal{S}}.$$

<details>
<summary><b>Proof, and its three corollaries</b></summary>

*Proof.* Pointwise $\max(a,b) = \frac{a+b+|a-b|}{2}$; summing over $x$ and using that both distributions have mass $1$ gives the identity. Since $\hat p \ge \max(p_\theta,p_{\theta'})$ pointwise, summing gives the bound. $\blacksquare$

**Corollary 1 (No free universality).** $C_{\mathcal{S}} = 1$ **if and only if** every member of the class is the same distribution. So any class containing two sources that differ at even one message pays a strictly positive price. There is no clever code that serves two genuinely different sources for free.

**Corollary 2 (Specialisation never hurts).** If you pass to a subclass, the envelope can only shrink, so the price can only fall. Narrowing your ambitions is always rewarded.

**Corollary 3 (The floor tensorises).** Combined with the additivity of §5, a class containing two sources at distance $\delta$ costs at least $k\log_2(1+\delta)$ bits over $k$ independent blocks.
</details>

This gives a genuinely useful computational tool: a *certificate* that no universal scheme can beat a stated target, obtained from a single linear pass and no optimisation at all.

{{algorithm:3}}

---

## 5. The first law — products penalise data

Real data arrives in blocks. If the message splits into two independent blocks drawn from classes $\mathcal{S}_1$ and $\mathcal{S}_2$ with independently chosen parameters, what is the price?

> **Theorem (Multiplicativity and additivity).** The envelope of a product factorises,
> $$\hat p_{\mathcal{S}_1\otimes\mathcal{S}_2}(x_1,x_2) = \hat p_{\mathcal{S}_1}(x_1)\,\hat p_{\mathcal{S}_2}(x_2),$$
> hence $C_{\mathcal{S}_1\otimes\mathcal{S}_2} = C_{\mathcal{S}_1}\cdot C_{\mathcal{S}_2}$ and, in bits,
> $$\text{price}(\mathcal{S}_1\otimes\mathcal{S}_2) = \text{price}(\mathcal{S}_1)+\text{price}(\mathcal{S}_2).$$
> In particular, $k$ independent blocks cost **exactly** $k$ times the per-block price.

<details>
<summary><b>The proof — and the subtlety that makes it interesting</b></summary>

Write $M$ for the joint envelope at $(x_1,x_2)$ and $M_i$ for the two marginal envelopes.

*The easy direction ($M \le M_1M_2$).* Multiply $p_{\theta_1}(x_1)\le M_1$ by $p_{\theta_2}(x_2)\le M_2$; all quantities are nonnegative, so the product of the likelihoods is at most $M_1M_2$; take the supremum.

*The delicate direction ($M \ge M_1M_2$).* Neither supremum need be attained — the parameter set may be infinite and the sup may only be approached. So we squeeze twice.

- **Step 1.** Fix $\theta_2$. If $p_{\theta_2}(x_2)=0$ then trivially $M_1p_{\theta_2}(x_2)=0\le M$. Otherwise, for *every* $\theta_1$ we have $p_{\theta_1}(x_1)\le M/p_{\theta_2}(x_2)$; since this bound is uniform in $\theta_1$, the supremum obeys it: $M_1 p_{\theta_2}(x_2)\le M$.
- **Step 2.** If $M_1=0$ we are done. Otherwise divide: $p_{\theta_2}(x_2)\le M/M_1$ for every $\theta_2$, so $M_2\le M/M_1$, i.e. $M_1M_2\le M$. $\blacksquare$

The moral: the correct definition of the envelope is by its *universal property* (least upper bound), not by "the value at the maximising parameter". With the universal property in hand, no compactness or attainment is needed anywhere.
</details>

This also has an immediate algorithmic payoff — an exponential saving over brute force:

{{algorithm:1}}

**Why this is bad news.** If one block of your stream costs half a bit of universality, a thousand independent blocks cost five hundred bits, not half a bit. There is no batching strategy that dilutes the tax.

<details>
<summary><b>...but then why is the memoryless class so cheap?</b></summary>

Because the memoryless class on $n$ symbols is **not** the $n$-fold product of the one-symbol class. In the product, each block gets its *own* parameter; in the memoryless class, one parameter is *shared* across all $n$ symbols. That single distinction is the difference between a price of $\Theta(n)$ and a price of $\Theta(\log n)$.

This is the deepest practical lesson on this page: a model family should tie its parameters across the stream as tightly as the data allows. Every genuinely independent degree of freedom costs its own full price, forever.
</details>

---

## 6. The second law — libraries barely penalise models

Now the opposite construction, and the good news. Suppose you have $K$ *specialised* classes — text, photographs, audio, executables — on the same message space, and you do not know which one applies. Merge them into a **library**: the class whose parameter is a pair (which family, which parameter within it).

> **Theorem (Library bounds).** $\displaystyle \max_i C_{\mathcal{S}_i}\;\le\; C_{\mathcal{L}}\;\le\;\sum_i C_{\mathcal{S}_i}$, and therefore
> $$\max_i \text{price}(\mathcal{S}_i)\;\le\;\text{price}(\mathcal{L})\;\le\;\log_2 K + \max_i\text{price}(\mathcal{S}_i).$$

<details>
<summary><b>Proof (two one-liners)</b></summary>

*Lower bound.* Every likelihood available to a member is available to the library, so $\hat p_{\mathcal{S}_i}\le \hat p_{\mathcal{L}}$ pointwise; sum over $x$.

*Upper bound.* For any library parameter $(i,\theta)$, $p_{(i,\theta)}(x)\le \hat p_{\mathcal{S}_i}(x)\le \sum_j \hat p_{\mathcal{S}_j}(x)$ because the terms are nonnegative; take the supremum over $(i,\theta)$ and sum over $x$. Then $C_{\mathcal{L}}\le KB$ where $B$ bounds every member, and take logarithms. $\blacksquare$
</details>

That $\log_2 K$ is the *entire* cost of not knowing which specialist to consult. Eight specialists cost three extra bits; a thousand cost ten. Against files of thousands of bytes this is nothing.

**A library of specialised decompressors is essentially as good as knowing which one to use.**

The bound is cheap enough to evaluate from summary statistics alone, without ever touching the message space:

{{algorithm:2}}

---

## 7. The same story on average: mutual information

The worst-case account charges a code for its single most embarrassing message. The classical [Bayes/Rissanen](https://en.wikipedia.org/wiki/Minimum_description_length) account asks about averages instead. If nature draws from $p_\theta$, the code $q$ overspends by the [Kullback–Leibler divergence](https://en.wikipedia.org/wiki/Kullback%E2%80%93Leibler_divergence)

$$D(p_\theta\|q) = \sum_x p_\theta(x)\log_2\frac{p_\theta(x)}{q(x)} \;\ge\; 0,$$

and this is *literally* the excess of expected code length over entropy, because $D(p\|2^{-\ell}) = \mathbb{E}_p[\ell] - H(p)$.

> **The compensation identity.** For every prior $w$ on $\Theta$, with Bayes mixture $m_w = \sum_\theta w(\theta)p_\theta$ and mutual information $I(w) = \sum_\theta w(\theta)D(p_\theta\|m_w)$, *every* coding distribution $q$ satisfies
> $$\sum_\theta w(\theta)\,D(p_\theta\|q) \;=\; I(w) \;+\; D(m_w\|q).$$

This is exact bookkeeping, and everything follows from it.

<details>
<summary><b>The three consequences, each in a line</b></summary>

- **The mixture is optimal.** $D(m_w\|q)\ge 0$ vanishes exactly at $q=m_w$, so the Bayes-optimal universal code is the mixture and its cost is exactly $I(w)$: a channel capacity in disguise.
- **Redundancy $\ge$ capacity.** A weighted average is at most a maximum, so for every prior *some* source pays at least $I(w)$ bits, whatever code you use.
- **Two-part codes are not bad.** $D(p_\theta\|m_w)\le \log_2(1/w(\theta))$ — under a uniform prior, at most $\log_2|\Theta|$: literally the cost of writing down the name of the source.

And the **bridge**: the worst-case-optimal code pays at most $\log_2 C_{\mathcal{S}}$ *on average* against every member, so the average-case price never exceeds the worst-case price, and every product and library bound above holds verbatim in the Bayes world.
</details>

You can watch all of this hold to ten decimal places:

{{demo:1}}

---

## 8. Two exactly solvable extremes, and a conservation law

**Mutually singular classes cost everything.** If the sources live on pairwise disjoint sets of messages, the price is exactly $\log_2|\Theta|$ bits — worst case *and* on average.

<details>
<summary><b>The pigeonhole argument behind it</b></summary>

A coding distribution has only one unit of mass to spread over $|\Theta|$ disjoint supports, so some support $A_\theta$ receives mass $c_\theta \le 1/|\Theta|$. Conditioning the code on that support (which costs $\log_2 c_\theta$) and applying Gibbs' inequality gives $D(p_\theta\|q)\ge -\log_2 c_\theta \ge \log_2|\Theta|$. The uniform mixture attains it, so the value is exact.

It is not a knife edge either: if the sources merely *concentrate*, each putting mass at least $1-\delta$ on its own set, the price is still at least $(1-\delta)\log_2|\Theta| - 4$ bits.
</details>

**Conservation of bits.** Classify each file by its type $c$ and let $P_c$ be uniform on the files of that type. Then for every code obeying the [Kraft inequality](https://en.wikipedia.org/wiki/Kraft%E2%80%93McMillan_inequality) there is a type on which it spends, on average, at least

$$\underbrace{\log_2 \#\{\text{files of type } c\}}_{\text{what the specialist needs}} \;+\; \underbrace{\log_2 \#\{\text{types}\}}_{\text{price of serving all types}}$$

bits. Specialisation moves *exactly* $\log_2\#\{\text{types}\}$ bits from the message into the identity of the decompressor — never more, never less. **Carving an unstructured set into pieces is relabelling, not compression.**

**But real structure is worth a growing number of bits.** On $n$-bit files: the class of *all* files costs exactly $n$ bits (this is the pigeonhole bound, recovered); the memoryless class over an alphabet $A$ costs at most $|A|\log_2(n+1)$; the first-order Markov class at most $\log_2|A| + |A|^2\log_2(n+1)$. And a natural class attains the logarithmic rate *exactly*: the **constant-composition** sources on $n$ bits — for each $j$, uniform on the strings with $j$ ones — have Shtarkov sum exactly $n+1$ and price exactly $\log_2(n+1)$.

{{visualization:1}}

The bottom panel of that figure is the punchline of the whole subject: **the price of universality is governed by the complexity of the class, not by the length of the data.**

---

## 9. Compute it yourself

The core routine is short enough to read in one sitting — compute the envelope, sum it, take a logarithm, normalise:

{{algorithm:0}}

And here is the full battery of checks, verifying every identity on this page by brute force over small message spaces:

{{demo:0}}

---

## 10. What to build

| Question | Answer |
|---|---|
| Are specialised decompressors worth building? | **Yes**, when the specialised class is genuinely *low-complexity* — its Shtarkov sum must grow slowly with the data length, not merely cover fewer files. |
| Does partitioning files by type help? | **No.** Conservation of bits: you move exactly $\log_2\#\{\text{types}\}$ bits from the payload to the label, and nothing more. |
| One monolith or many specialists? | **Many.** Merging $K$ specialists costs at most $\log_2 K$ bits over the worst of them. Doubling the zoo costs one bit. |
| Can longer messages amortise the cost? | **No.** The price is additive over independent blocks: a constant per block is a linear total. |
| Is there any escape from the floor? | **No.** A class costs at least $\log_2(1+\delta)$ bits, $\delta$ the largest total variation distance between two members, and that floor tensorises. |

---

## 11. Two open problems, if you want to go further

**The redundancy–capacity theorem.** Is $\inf_q\max_\theta D(p_\theta\|q) = \max_w I(w)$, with the infimum attained at the Bayes mixture of a maximising prior? The "$\ge$" half is proved above. The missing half is a genuine [minimax exchange](https://en.wikipedia.org/wiki/Minimax_theorem): $w\mapsto I(w)$ is concave and $q\mapsto \sum_\theta w(\theta)D(p_\theta\|q)$ is convex, so a Sion-type argument on the compact simplices ought to close it, once the divergence is handled at the boundary.

**The sharp Rissanen constant.** For the binary memoryless class on $n$ bits, is

$$\log_2 C_n \;=\; \tfrac12\log_2 n + \tfrac12\log_2\frac{\pi}{2} + o(1)\,?$$

The known two-sided bounds leave a factor-two gap at the top. The Shtarkov sum is a sum of binomial *mode* probabilities, $C_n = \sum_j \Pr[\mathrm{Bin}(n,j/n)=j]$, so [Stirling](https://en.wikipedia.org/wiki/Stirling%27s_approximation) bounds on the central term plus a Laplace-type comparison of neighbours should pin the constant. Numerically the ratio $C_n/\sqrt{\pi n/2}$ is $1.017$ at $n=1000$ — try dialling $n$ upward in the demo and watch it creep down.

---

*The pigeonhole principle tells us that no compressor can shrink everything. The theory of universal redundancy tells us something more useful: exactly how much of that irreducible cost is due to **ignorance**, as opposed to **incompressibility** — and, in bits, exactly what knowledge is worth.*
