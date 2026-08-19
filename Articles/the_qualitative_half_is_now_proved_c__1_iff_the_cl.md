# The Marginal Value of a Model

### How much is one more compression model worth? There is an exact formula — and it makes library design a solved problem.

---

## A tax you pay for not knowing

Every compressor is a bet. A ZIP archive bets that your file looks like English text or like source code; a JPEG bets that your image is smooth in the right places; a genomics compressor bets on the statistics of DNA. When the bet is right, the file shrinks close to the theoretical floor: a source that emits message $x$ with probability $p(x)$ cannot, on average, be encoded in fewer than $\log_2 (1/p(x))$ bits per message. That is Shannon's bound, and a well-matched compressor essentially achieves it.

But real compressors do not know which source they are facing. They must work for a whole *class* of sources — all plausible English texts, all plausible photographs, all plausible genomes. And here a small tragedy of information theory sets in: **you cannot be optimal for everybody at once.** Spreading your code's probability budget over many possible sources means it is slightly too thin for each of them. The extra bits you spend, relative to the best code you *could* have used had you known the truth in advance, are called the **regret**, and their unavoidable minimum is the **price of universality**.

Remarkably, that price has a closed form. Given a class of candidate sources $\mathcal{S} = \{p_\theta\}_{\theta \in \Theta}$ over a finite set $X$ of possible messages, form the pointwise best-fit curve — the **maximum-likelihood envelope**
$$\hat p_{\mathcal S}(x) \;=\; \sup_{\theta \in \Theta} \, p_\theta(x),$$
which records, for each message $x$, the largest probability any model in the class is willing to assign to it. Then add it all up. The total
$$C_{\mathcal S} \;=\; \sum_{x \in X} \hat p_{\mathcal S}(x)$$
is called the **Shtarkov sum**, and the price of universality is exactly $\log_2 C_{\mathcal S}$ bits — no more, no less. The code achieving it is beautifully simple: normalize the envelope into a probability distribution, $q(x) = \hat p_{\mathcal S}(x)/C_{\mathcal S}$, and encode with it. Then for *every single message* $x$, the number of bits you spend exceeds the best-in-hindsight $\log_2(1/\hat p_{\mathcal S}(x))$ by precisely $\log_2 C_{\mathcal S}$. The regret is a flat tax: the same for the easy messages and the hard ones.

Two facts about this tax are easy to believe and were established earlier in this line of work. First, $C_{\mathcal S} = 1$ — a free lunch, zero price — happens exactly when the class is *degenerate*, in the sense that a single distribution already dominates every member. Any genuinely new source makes the price strictly positive. Second, the price is monotone: a bigger class costs at least as much.

What was missing was the *quantity*. If I hand you a new model, how many bits does it cost you to also be good at it? That is the question this article answers.

---

## The formula: pay only for what is new

Here is the result, and it is as clean as one could hope.

> **The Marginal Value Formula.** Let $\mathcal S$ be a class of sources over a finite message set $X$, with envelope $\hat p_{\mathcal S}$, and let $p$ be one more probability distribution on $X$. Then the enlarged class $\mathcal S \cup \{p\}$ has Shtarkov sum
> $$C_{\mathcal S \cup \{p\}} \;=\; C_{\mathcal S} \;+\; \sum_{x \in X} \bigl(p(x) - \hat p_{\mathcal S}(x)\bigr)^{+},$$
> where $(t)^{+} = \max(t, 0)$ denotes the positive part.

In words: **you pay only for the mass on which the newcomer beats the incumbent envelope.** Wherever your existing library already explains a message at least as well as the new model does, the new model is free. Wherever it explains it better, you pay the difference — and only the difference.

The proof is a one-liner once you see the right picture. The Shtarkov sum is an $\ell^1$ norm of a pointwise supremum. Adding one function to a family replaces the envelope $\hat p_{\mathcal S}$ by $\max(p, \hat p_{\mathcal S})$, and for real numbers,
$$\max(a,b) - b = (a - b)^{+}.$$
Summing that identity over $x$ is the whole argument. The formula is exact — no approximation, no asymptotics, no regularity assumptions — and it holds even when the class is infinite and the supremum is not attained by any single member.

Several consequences follow immediately, and each of them says something a practitioner would want to know.

**A model is free exactly when it is already dominated.** Adding $p$ leaves the price unchanged if and only if $p(x) \le \hat p_{\mathcal S}(x)$ for every message $x$; and the price strictly increases if and only if there is at least one message where $\hat p_{\mathcal S}(x) < p(x)$. There is no middle ground and no hidden cost: novelty in the strict pointwise sense is the *only* thing you are charged for. The same dichotomy holds verbatim in bits, since the logarithm is strictly increasing.

**Mixtures are free.** If $p$ is a convex combination $\sum_\theta w_\theta \, p_\theta$ of models already in the class, then $p$ is pointwise below the envelope and costs nothing. The price of universality sees only the *extreme points* of a model library. Blending existing models — averaging two language models, say — buys no new expressive reach in this accounting, however useful the blend may be for other purposes.

**One model costs at most one unit.** The increment $\sum_x (p(x) - \hat p_{\mathcal S}(x))^+$ is bounded above by $\sum_x p(x) = 1$. So a single new source can never more than add $1$ to the Shtarkov sum — and, more sharply, the increment never exceeds the $\ell^1$ distance $\sum_x |p(x) - \hat p_{\mathcal S}(x)|$ from the envelope.

**Whole classes merge the same way.** If instead of one model you graft an entire class $\mathcal T$ onto $\mathcal S$, the price rises by $\sum_x (\hat p_{\mathcal T}(x) - \hat p_{\mathcal S}(x))^+$: the same formula, with the newcomer's envelope playing the role of the newcomer.

---

## The twist: diminishing returns, and why that is good news

Look again at the increment, $\sum_x (p(x) - \hat p_{\mathcal S}(x))^+$. As the incumbent envelope $\hat p_{\mathcal S}$ rises — that is, as the library grows — every term $(p(x) - \hat p_{\mathcal S}(x))^+$ can only shrink. The marginal value of a fixed model is *antitone* in the library.

That is the definition of **diminishing returns**, and diminishing returns is the economic face of a structural property with a formal name: **submodularity**.

To state it, change perspective. Instead of a fixed class handed to you, imagine a *pool* of candidate models $P_1, \dots, P_m$ — the compressors you might ship, the decompressors you might bake into your archive format. A **library** is a finite subset $A$ of the pool. Its envelope is $\mathrm{env}_A(x) = \max_{i \in A} P_i(x)$ (with $\mathrm{env}_\emptyset = 0$), and its price functional is
$$C(A) \;=\; \sum_{x \in X} \mathrm{env}_A(x).$$
When $A$ is nonempty and the $P_i$ are genuine probability distributions, this is precisely the Shtarkov sum of the class of models in $A$ — so $C$ really is the price of universality, now as a function of the library.

The following facts hold for *any* pool of nonnegative functions whatsoever.

> **Monotone.** $A \subseteq B \implies C(A) \le C(B)$.
>
> **Vanishing.** $C(\emptyset) = 0$.
>
> **Marginal value.** $C(A \cup \{j\}) - C(A) = \sum_x \bigl(P_j(x) - \mathrm{env}_A(x)\bigr)^{+}$.
>
> **Submodular.** $C(A \cup B) + C(A \cap B) \;\le\; C(A) + C(B)$ for all libraries $A, B$.
>
> **Multiplicatively submodular.** $C(A \cup B) \cdot C(A \cap B) \;\le\; C(A) \cdot C(B)$.

The last of these is the one that matters for engineers, because engineers pay in bits, and bits are logarithms. One could reach for the general principle that a concave nondecreasing function of a monotone submodular function is again submodular — but the logarithm is unbounded below at $0$, which is exactly the value the price functional takes on the empty library, so the general principle degenerates precisely at the boundary of interest. The multiplicative form is sharper and needs no such appeal: it follows from the additive one and monotonicity via the elementary inequality $(C(A) - C(A\cap B))(C(B) - C(A \cap B)) \ge 0$, and it does the job: taking logarithms gives
$$\mathrm{price}(A \cup B) + \mathrm{price}(A \cap B) \;\le\; \mathrm{price}(A) + \mathrm{price}(B), \qquad \mathrm{price}(A) := \log_2 C(A),$$
valid whenever the shared part $A \cap B$ contains at least one genuine source. The caveat is not cosmetic. Take two point masses on a two-letter alphabet: each singleton library has $C = 1$, price $0$ bits; their union has $C = 2$, price $1$ bit; and their intersection is empty with $C = 0$. The inequality reads $1 + \log_2 0 \le 0 + 0$, which is true only if one is willing to write $\log 0 = -\infty$. In any real-number implementation it is a genuine counterexample, and the positivity guard must be respected.

---

## The payoff: greedy library design is provably near-optimal

Why should anyone care that a cost function is submodular? Because submodularity is the mathematical signature of problems where **the obvious algorithm is provably almost the best one.**

Here is the design problem. You have a pool of $m$ candidate models and room in your format for only $n$ of them. You want the library of size $n$ with the largest possible reach — the largest $C(A)$, because $C(A)$ measures exactly how much probability mass your envelope can capture, hence how many distinct sources your library can model well. Searching all $\binom{m}{n}$ subsets is hopeless for realistic $m$.

The greedy algorithm ignores all that: start with nothing, and repeatedly add whichever single model has the largest marginal value on top of what you already have. It is myopic by construction. Yet:

> **Greedy Design Theorem.** Let $A_0 = \emptyset \subseteq A_1 \subseteq A_2 \subseteq \cdots$ be a greedy run, each $A_{k+1}$ obtained from $A_k$ by inserting a model of maximal marginal value. Then for every target library $B$ with $|B| = n \ge 1$ and every $k$,
> $$C(B) - C(A_k) \;\le\; \Bigl(1 - \tfrac1n\Bigr)^{k} C(B),$$
> and in particular, after $n$ steps,
> $$C(A_n) \;\ge\; \bigl(1 - e^{-1}\bigr)\, C(B) \;\approx\; 0.632\, C(B).$$

The engine of the proof is a pigeonhole on the marginals. Because the price functional is submodular, the amount that the *whole* of $B$ could add on top of the current library $A$ is at most the sum of the individual marginals of $B$'s members:
$$C(A \cup B) - C(A) \;\le\; \sum_{j \in B} \bigl( C(A \cup \{j\}) - C(A)\bigr).$$
So some single $j \in B$ has marginal value at least $\frac{1}{n}$ of the whole remaining gap $C(B) - C(A)$. Greedy picks something at least that good, so each step shaves a $1/n$ fraction off the gap; after $n$ steps the gap has been multiplied by $(1 - 1/n)^n \le e^{-1}$.

In bit terms the guarantee reads: the greedy library's price of universality is at least
$$\mathrm{price}(\text{best library of size } n) \; - \; \log_2 \frac{e}{e-1},$$
and $\log_2 \frac{e}{e-1} < 0.67$. **A myopic, linear-time-per-step design procedure comes within two-thirds of one bit of the optimal library — for every pool, every alphabet, every target size.**

---

## A worked miniature

Abstraction earns its keep on examples. Take a three-letter alphabet $\{a_0, a_1, a_2\}$ and a pool of four models:

| model | $p(a_0)$ | $p(a_1)$ | $p(a_2)$ |
|---|---|---|---|
| $P_0$ | $1/2$ | $1/4$ | $1/4$ |
| $P_1$ | $1/4$ | $1/2$ | $1/4$ |
| $P_2$ | $1/3$ | $1/3$ | $1/3$ |
| $P_3$ | $0$ | $0$ | $1$ |

A single model always has $C = 1$: if you know the source, universality is free. Now build up. The library $\{P_0, P_1\}$ has envelope $(1/2, 1/2, 1/4)$ and price factor $C = 5/4$: the two skewed models overlap heavily, so the second one is cheap — worth $1/4$. The library $\{P_0, P_3\}$ has envelope $(1/2, 1/4, 1)$ and $C = 7/4$: the degenerate point mass, which is as far from $P_0$ as a distribution can be on the letter $a_2$, is worth a full $3/4$.

The most striking comparison is $\{P_0, P_1, P_2\}$ against $\{P_0, P_3\}$. The three-model library, containing the "sensible" uniform model, has $C = 4/3 \approx 1.33$ — *less* than the two-model library's $7/4$. The uniform model $P_2$ is almost worthless once $P_0$ and $P_1$ are present, because it barely pokes above their envelope anywhere; the eccentric $P_3$ is worth six times as much. Reach is not about being reasonable; it is about covering territory nobody else covers.

Run greedy on this pool with a budget of three. It starts with any single model (all tie at $C = 1$); say $P_0$. The marginals are then $1/4$ for $P_1$, $1/6$ for $P_2$, and $3/4$ for $P_3$, so it takes $P_3$, reaching $C = 7/4$. Next round: $P_1$ is worth $1/4$, $P_2$ only $1/12$; it takes $P_1$, reaching $C = 2$. And $C = 2$ is exactly the optimum over all three-element libraries. Here greedy is not merely within $63\%$ — it is exact.

There is also a pretty closed form for two-model libraries. For any two distributions $p, q$,
$$C(\{p, q\}) \;=\; 1 + \|p - q\|_{\mathrm{TV}}, \qquad \|p-q\|_{\mathrm{TV}} = \tfrac12 \sum_x |p(x) - q(x)|.$$
The price of being universal over exactly two sources *is* their total-variation distance, in the most literal sense. Diversity and cost are the same quantity.

---

## What it means

Three ideas are worth carrying away.

**Novelty is measurable, pointwise.** The value of a model is not how good it is in isolation, nor how different it "feels" — it is the integral of the amount by which it out-explains everything you already have, message by message. That quantity is computable in a single pass over the alphabet.

**Redundancy is a coverage problem.** Submodularity places universal compression in the same family as sensor placement, influence maximization in networks, feature selection, and document summarization — the classical habitat of greedy algorithms with provable guarantees. Designing a library of decompressors is, structurally, a facility-location problem in the space of probability distributions.

**The obvious algorithm is defensible.** Engineers have always built codec libraries greedily: ship the most valuable model, look at what it fails on, ship the model that fixes the biggest failure, repeat. The results above say that this instinct is not just pragmatic but provably near-optimal, with a worst-case shortfall under two-thirds of a bit against a search no one can afford to run.

Open questions remain, and they are inviting. Under a *matroid* constraint — "at most $k$ models per data modality", a natural budget for a real codec — plain greedy degrades to a factor $1/2$, but continuous-greedy methods should restore $1 - 1/e$; the marginal value formula already supplies the gradient of the relevant continuous relaxation in closed form. When the models in the pool are all close to one another, the *curvature* of the price functional is small and greedy should beat $1 - 1/e$, approaching optimality; the two-model formula $C = 1 + \|p-q\|_{\mathrm{TV}}$ suggests total variation as exactly the right modulus of control. And in the other direction: exact library design is very likely NP-hard, which would explain — and vindicate — why we have all been reaching for the greedy algorithm anyway.

The tax on not knowing, it turns out, has an itemized bill.
