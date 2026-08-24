# The Key That Doesn't Know Its Own Worth

## Why "what a thing is" tells you almost nothing about "what a thing will matter for"

There is a particular kind of engineering problem that keeps reappearing, in different costumes, wherever memory is finite and the future is unknown. A librarian must decide which books to keep on the short shelf behind the desk. A CPU must decide which cache lines to evict. A large language model reading a hundred-thousand-token document must decide which of its stored *keys* — the compressed traces of everything it has already read — to throw away, because keeping all of them is unaffordable.

In all three cases the tempting shortcut is the same: **look at the thing itself.** Surely a book about tax law is more likely to be requested in an accountant's office than a book of sonnets. Surely a line of code containing a function definition is more likely to be re-read than a blank line. Surely, if you train a small linear model to look at a stored key's vector and predict how much attention it will eventually receive, you can use that prediction to decide what to keep.

This article is about a sequence of experiments and theorems which say, with unusual sharpness, that the shortcut fails — and, more interestingly, *why* the obvious explanation for the failure is wrong.

---

## The three arms

Set the scene concretely. A model reads a document and accumulates a pile of keys. We are allowed to retain only $B$ of them; call $B$ the **budget**. Each key $i$ carries a **true importance** $a_i \ge 0$: the total attention mass that all future queries will, in fact, direct at it. Of course we do not know $a$ at the moment we must evict — that is the whole difficulty. The quality of a policy is measured by its **retained mass**

$$\mathcal{A}(S) \;=\; \sum_{i \in S} a_i,$$

the fraction of future attention that survives our pruning. Retain $100\%$ and the model behaves exactly as if nothing had been thrown away.

Three policies were pitted against each other on Python source code — deliberately, because code is the *most favourable possible terrain* for the content shortcut. Identifiers repeat. Syntax is rigid. A `def` line looks like a `def` line. If a key's own vector ever carried information about its future reception, it would carry it here.

| Policy | Retained mass at $B = 64$ |
|---|---|
| Accumulated heavy-hitter (recency + running attention total) | $0.9340$ |
| Content probe alone (a trained linear predictor of importance) | $0.8149$ |
| Hybrid: accumulated $+$ probe | $0.9371$ |

The probe loses by nearly twelve points. It is not close. And the probe's raw predictive accuracy — the fraction of the variance in true importance it explains, the familiar $R^2$ — averages $0.3185$ on code, against $0.329$ on English prose. Two domains that look nothing alike from the outside give predictors that are, to three decimal places, equally mediocre.

That is the empirical verdict, and it has a name: **content weakness is domain-universal.** Whatever it is that makes a key important, it is not written on the key.

---

## The obvious explanation, and why it is false

Everyone's first instinct is: *the probe loses because $R^2 = 0.32$ is low.* A bad predictor makes bad decisions. Case closed.

It is not closed, and the reason it is not closed is the most interesting mathematics in this story.

Here is a theorem. Fix any true importance vector $a$ that is not constant, and fix any target accuracy $\rho$ strictly between $0$ and $1$ — say $\rho = 0.3185$, exactly the measured value. Then **there exists a score $s$ with $R^2$ exactly equal to $\rho$ which selects precisely the oracle's set of keys, at every single budget simultaneously.** Its retention is perfect. It leaves nothing on the table. And its $R^2$ is $0.3185$.

The construction is embarrassingly simple. Let $\bar a$ be the mean importance and put

$$s_i \;=\; \bar a + c\,(a_i - \bar a), \qquad c = 1 - \sqrt{1-\rho}.$$

This is the true importance vector *shrunk toward its own mean*. Its sum of squared errors is $(1-c)^2$ times the total dispersion of $a$, so its $R^2$ is exactly $1 - (1-c)^2 = \rho$. But shrinking toward the mean by a positive factor is a strictly increasing reparametrisation: it never swaps the order of two keys. A greedy top-$B$ evictor driven by $s$ therefore makes *exactly the same choices* as one driven by $a$ itself.

So $R^2$ — a single number summarising the *size* of the prediction error — cannot possibly explain a retention deficit. Retention depends on the **direction** of the error, on which pairs of keys the score misorders, and the variance ratio is blind to that. A probe can be wildly wrong about every magnitude and perfectly right about every ordering.

The point can be made even more violently, with four keys and no algebra. Let the true importances be

$$a = (10,\; 9,\; 1,\; 0).$$

Consider two candidate scores. The first, $h = (1,2,3,4)$, has squared error $81 + 49 + 4 + 16 = 150$. The second, $p = (40,30,20,10)$, has squared error $900 + 441 + 361 + 100 = 1802$ — more than *twelve times worse*. By any accuracy metric, $h$ is the superior predictor.

Now run a budget-$2$ evictor. Driven by $h$, it keeps the two highest-scoring keys, which are the last two, retaining $1 + 0 = 1$. Driven by $p$, it keeps the first two, retaining $10 + 9 = 19$. The score that is twelve times more accurate retains **nineteen times less mass**.

Accuracy and retention are not merely weakly correlated. They do not order each other at all.

---

## What *can* be proved: the transfer theorems

None of this means accuracy is useless — it means it buys a *one-sided* guarantee, and the guarantee happens to be pessimistic. Here is the clean statement.

Call a set $S$ a **top set** for the score $s$ at budget $B$ if $|S| = B$ and no retained key is scored below a discarded one. (Ties make top sets non-unique; that turns out to matter.) The whole theory rests on a single **exchange inequality**: if $S$ is a top set for $s$ and $T$ is any other set of the same size, then the block of $S$ that $T$ omits carries at least as much $s$-mass as the block of $T$ that $S$ omits. Proof: take the *worst* key in $S \setminus T$ and the *best* key in $T \setminus S$; the top-set property says the former outscores the latter, and the two blocks have equal cardinality, so the comparison propagates to the sums.

From this one inequality everything follows. If the score is uniformly $\varepsilon$-accurate, meaning $|a_i - s_i| \le \varepsilon$ for every key, then against *any* rival selection $T$ of the same size,

$$\mathcal{A}(T) - 2B\varepsilon \;\le\; \mathcal{A}(S).$$

If instead we only control the total squared error $\mathrm{SSE} = \sum_i (a_i - s_i)^2$, Cauchy–Schwarz gives

$$\mathcal{A}(T) - 2\sqrt{B \cdot \mathrm{SSE}} \;\le\; \mathcal{A}(S),$$

and rewriting $\mathrm{SSE} = (1 - R^2)\,\mathrm{SS}_{\text{tot}}$ puts it in the experiment's own currency: the deficit of an $R^2$-accurate probe is at most $2\sqrt{B(1-R^2)\,\mathrm{SS}_{\text{tot}}}$.

Two consequences are worth pausing over.

**First, the pessimism is real, not an artefact of a lazy proof.** Take four keys with importances $(1, 1, -1, -1)$ and a score that is flat — every key looks identical. That score is $1$-accurate. At budget $2$ the evictor is entitled to keep the *worst* pair, retaining $-2$ where the oracle retains $+2$: a loss of exactly $4 = 2 \cdot B \cdot \varepsilon$. The constant cannot be improved. So the gap between the guarantee and the shrinkage probe's perfect performance is genuine: accuracy pins retention down only to the full width of the worst case.

**Second, run the inequality backwards and it becomes a measurement.** The probe arm's measured deficit is $0.9340 - 0.8149 = 0.1191$, at $B = 64$ with $R^2 = 0.3185$. Plug those into the bound and it *forces*

$$\mathrm{SS}_{\text{tot}} \;>\; 8 \times 10^{-5}.$$

A large observed deficit at a fixed accuracy is not only a fact about the probe; it is a lower bound on how spread out the true importances are. The two measurements are not independent, and the theory says exactly how they are chained.

And a small arithmetic point carries the round's headline. The code round's $R^2$ is $0.3185$; the prose round's is $0.329$. The guarantees they license differ by the ratio $\sqrt{0.6815}/\sqrt{0.671} < 1.008$: **less than eight tenths of one percent.** "Domain-universal" is usually a qualitative hedge. Here it is a number.

---

## Where the loss actually lives: the boundary band

If not $R^2$, then what? The theory answers precisely: the loss lives at the **cut-off**.

Suppose $\mu$ is an upper bound on the importance of every key the rival policy discards, so $\mu$ marks the boundary between "kept" and "dropped". Then the entire retention deficit of an $\varepsilon$-accurate score is carried by the keys of the rival set whose importance is within $2\varepsilon$ of that boundary:

$$\mathcal{A}(T) - \mathcal{A}(S) \;\le\; \sum_{\substack{i \in T \\ a_i \le \mu + 2\varepsilon}} a_i.$$

The keys that stand clear of the boundary — the *safe core* — are always retained, however bad the score is elsewhere. In the limiting case, if every key in $T$ clears the cut-off by more than $2\varepsilon$, the loss is **zero**: an $R^2$-weak probe is entirely harmless in the absence of near-ties.

This reframes the whole question. The right statistic is not a global variance ratio but a **local band mass**: how much attention sits in the narrow strip around the eviction threshold where a noisy score can plausibly flip a decision. And band mass is local, which means it is free to differ between code and prose *even when the two $R^2$ values are numerically identical*. Two domains can produce equally mediocre predictors and yet suffer very differently — a prediction the theory makes and the existing measurement apparatus can test.

---

## Why the hybrid is safe — and why safety costs you everything

The third arm mixed the two scores: $h + \lambda p$, accumulated statistic plus $\lambda$ times the probe. On code this was *non-degrading*: $0.9371$ against the accumulated arm's $0.9340$, a gain of $0.3$ points. On prose the same mixture harmed, and harmed monotonically in $\lambda$. Why the asymmetry?

Start with the exact condition. The mixture preserves a given selection $S$ if and only if

$$\lambda\,(p_j - p_i) \;\le\; h_i - h_j \qquad \text{for every retained } i \text{ and discarded } j.$$

That is a *linear system in $\lambda$* — one inequality per retained/discarded pair. Three things follow immediately.

**A non-degradation threshold.** If the accumulated score separates $S$ from the discarded keys by a margin $\gamma$, and the probe's values oscillate by at most $D$, then every $\lambda$ with $\lambda D \le \gamma$ leaves the selection — and therefore the retained mass — completely untouched. Non-degradation is a **margin phenomenon**. It has nothing to do with how good the probe is. It is a statement about how confidently the accumulated statistic already separates its keeps from its drops, relative to how loudly the probe can shout.

**The safe region is an interval.** Since each constraint is linear in $\lambda$, the set of mixing weights preserving a selection is a solution set of linear inequalities, hence convex; if a selection survives at $\lambda_1$ and at $\lambda_2$ it survives at every weight in between. This is the structural reason a domain can only exhibit *monotone* harm: once $\lambda$ walks out of the stability interval of the accumulated selection, it never walks back in. Prose's monotone degradation is not an empirical accident. It is forced.

**And here is the sting.** Consider four keys with importances $(10, 9, 1, 0)$, accumulated score $h = (6,2,4,0)$ and probe $p = (2,7,2,5)$. At budget $2$: the accumulated arm keeps keys $0$ and $2$, retaining $11$. The probe alone keeps keys $1$ and $3$, retaining $9$. The mixture at $\lambda = 1$ has scores $(8,9,6,5)$ and keeps keys $0$ and $1$ — retaining $19$. **Strictly more than either parent.** The two scores misrank *different* pairs, and their sum repairs both. So the measured $+0.3$ points is not noise-shaped luck; strict dominance over both arms is a structurally available effect.

Now compute the stability interval for that same instance. The binding constraint comes from the retained key $2$ (with $h=4$, $p=2$) versus the discarded key $1$ (with $h=2$, $p=7$): we need $\lambda(7-2) \le 4-2$, that is $\lambda \le 2/5$. The accumulated selection survives precisely for $0 \le \lambda \le 2/5$.

And the useful weight, $\lambda = 1$, lies *outside* it.

This is the deployment corollary, and it is uncomfortable: **choosing $\lambda$ below the margin ratio guarantees safety, and guarantees the hybrid learns nothing.** Any $\lambda$ small enough to be provably harmless is by definition too small to change a single decision. Safety and usefulness are in exact quantitative tension — you can have a certificate, or you can have an effect, and the certificate is precisely the statement that there is no effect.

---

## The floor beneath everything

One last piece closes the picture. A companion analysis studies the **knee** of a sorted attention profile: the smallest number of keys $k$ such that the top $k$ of them already carry a target fraction $\tau$ of the total mass. For code, that number came out at $12$ out of $16$ — fewer keys needed than for prose.

It would be easy to read the knee as a property of one particular heuristic, namely top-$k$ eviction. It is not. For a sorted profile, the prefix of length $k$ *is* a top set, and top sets maximise retained mass among all sets of their size. Therefore:

> **Below the knee, every policy fails.** No scoring rule, however clever, retains $\tau$ with fewer than $\mathrm{knee}(\tau)$ keys.

The retention curve is not the curve of a heuristic; it is the **envelope of all heuristics**, an information-theoretic floor. And the contrapositive is what experimenters actually use: an arm that passes its drift threshold at budget $B$ has thereby certified $\mathrm{knee} \le B$.

Running a probe at or above the knee, the transfer theorem returns as a price tag: a score with error $\varepsilon$ still reaches $\tau - 2B\varepsilon$. Combined with the sharpness example, that pins the cost of content-blindness exactly — linear in the budget and in the error, and no better.

---

## The law, and what it means

Put the pieces together and a single principle emerges.

> **Importance is relational, not intrinsic.** A key's own vector carries almost no information about its future reception — not in prose, and not in code, where identifiers repeat and grammar is rigid and every intuition says content ought to work. What matters about a key is not what it *is* but what will later be *asked* of it, and that lives in the interaction between the key and queries that have not yet arrived.

The domain difference sits entirely in the interaction term: content is neutral on code and harmful on prose, and the margin theory says that asymmetry should be predictable from margin statistics alone, without ever measuring $R^2$ again.

For practice the conclusion is blunt: **recency and accumulation remain the deployable pair.** What a key has already been used for is a far better guide to what it will be used for than anything written inside it — a lesson cache designers arrived at empirically decades ago, now with theorems attached.

And there is a broader moral, one that reaches past attention caches. We reach instinctively for intrinsic properties when we want to predict future relevance: the topic of the book, the type of the file, the content of the message. This story is a precise, quantified demonstration that intrinsic properties can be *equally and universally* uninformative across domains that look completely different — and that the summary statistic we habitually use to check them, the variance explained, is structurally incapable of telling us whether they will work. The right question was never "how accurately does the score predict?" It was "how much mass is sitting at the boundary where a small error flips a decision?"

Those are different questions. The theorems say only the second one has an answer.
