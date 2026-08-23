# The Knee That Escaped the Ruler

## What happens when a memory budget meets a foreign language

There is a small, stubborn engineering question hiding inside every large language model that runs in production: *how much of the past do you actually have to remember?*

A transformer, reading a long document, keeps a cache of every token it has seen. That cache is the expensive part — it grows linearly with the length of the text and it lives in the fastest, scarcest memory on the machine. So engineers do the obvious thing. They ask: at each step, when the model spreads its attention across the thousands of tokens behind it, how much of that attention actually matters? If ninety-seven percent of the attention mass sits on twenty-four keys, then keep twenty-four keys and throw the rest away.

The number of keys you need is called the **knee**. And the way people find it is a *sweep*: try budgets $8, 16, 24, 32$, see which one first clears the bar.

This article is about what happened when someone ran that sweep on French.

---

## The measurement

The experiment was mundane in its setup and startling in its result. A model that had been characterized carefully across English prose, source code, and mathematical text — three domains whose knees all sat comfortably inside the grid, and whose differences from one another were tiny, on the order of $\pm 4$ keys, one fine step of the ruler — was pointed at French prose.

At context length $512$, with the budget grid topping out at $24$ keys, the best grid point retained $0.9648$ of the attention mass. The bar was not met.

At context length $1024$, with the grid topping out at $32$ keys, the best grid point retained $0.9680$. The bar was not met.

Meanwhile the model was *doing better* on French than on English: full-context accuracy $0.584$ and $0.591$, against $0.446$ and $0.461$ for English prose.

So French was easier to predict and more expensive to remember. And the knee — the thing the whole sweep exists to find — was simply not in the grid. Every pre-registered hypothesis about where it would land, all of them phrased as small additive offsets, was wrong, and wrong in the same direction: not by a little, but past the end of the ruler.

The obvious reaction is to extend the grid. The interesting reaction is to ask why the ruler was the wrong shape. That is what this article is about, and the answer turns out to be a small, clean piece of mathematics with three parts: *a failed sweep tells you almost nothing*, *the domain tax is multiplicative rather than additive*, and *there is a single number you can read off an attention map that lower-bounds the knee without knowing anything about the language at all*.

---

## Setting the stage precisely

Strip the machine learning away and you are left with a very simple object.

An **attention profile** is a function $p$ assigning to each index $i = 0, 1, 2, \dots$ a nonnegative weight $p(i)$, arranged in nonincreasing order: $p(0) \ge p(1) \ge \cdots \ge 0$. Think of $p(i)$ as the attention mass carried by the $i$-th most important key.

The **retained mass** at a budget of $k$ keys is the prefix sum
$$M_p(k) \;=\; \sum_{i<k} p(i),$$
the mass you keep if you keep the $k$ heaviest keys. It is nondecreasing in $k$; that is the only structural fact most of what follows needs.

The **knee** at a bar $\tau$ is
$$K_p(\tau) \;=\; \min\{\, k \;:\; \tau \le M_p(k) \,\},$$
the smallest budget that clears the bar. A sweep is an attempt to locate $K_p(\tau)$ by evaluating $M_p$ at a handful of points.

That is the whole vocabulary. Everything below is a statement about these three objects.

---

## Part one: a failed sweep is almost silent

Here is the first thing to be honest about.

> **The Grid Lower-Bound Theorem.** *If a budget $g$ fails the bar — that is, $M_p(g) < \tau$ — then the knee is strictly greater than $g$. Consequently, if every point of a finite grid fails, the knee exceeds the largest grid point.*

The proof is one line: if the knee were at most $g$, monotonicity of $M_p$ would give $\tau \le M_p(K_p(\tau)) \le M_p(g) < \tau$, a contradiction. Applied to the measured cell — grid $\{8, 16, 24, 32\}$, all four points below the bar — the conclusion is exactly "the knee is at least $33$", and nothing stronger.

One might hope that a near-miss is informative: retaining $0.9680$ when you needed, say, $0.97$ feels like you were *close*, so surely the true knee is $36$ or so, not $200$. That hope is false, and provably so.

> **The Grid Underdetermination Theorem.** *Fix a grid ceiling $g$ and a bar $\tau = g+1$. For every target $N > g$ there exists a nonnegative, nonincreasing profile whose retained mass equals $k$ at every budget $k \le g$ — hence agrees with a fixed reference profile at every grid point, all of them below the bar — and whose knee is exactly $N$.*

The construction is a two-level staircase: height $1$ on the first $g$ keys, then a long plateau of height $c = 1/(N-g)$ on keys $g$ through $N-1$, then zero. Below $g$ nothing distinguishes it from anything else; above $g$ it creeps toward the bar at a rate you get to choose, and it arrives exactly at $N$. Every one of these profiles produces *identical measurements* on the grid.

So a failed sweep produces a one-sided bound and a one-sided bound only. The excess is invisible. "Knee $> 32$" is a fact; "knee $\approx 36$" is a guess with no evidential support whatsoever. This is not a limitation of the particular sweep — it is a theorem about grids.

A sharper version says how bad the ambiguity is even *between* successful probes:

> **The Gap Ambiguity Theorem.** *For consecutive probes $a < b$ there are two nonnegative nonincreasing profiles whose retention agrees at every budget $k \le a$ and at every budget $k \ge b$ — so they are indistinguishable to any grid avoiding the open interval $(a,b)$ — while their knees are $a+1$ and $b$ respectively.*

A grid can never certify a bracket tighter than the ratio $b/(a+1)$ between consecutive probes. Hold onto that ratio; it comes back.

---

## Part two: the tax is multiplicative

Why did French escape? The mechanistic hypothesis is about spelling, not about meaning. Tokenizers trained largely on English chop French into more pieces: accents, elisions, agglutinated function words. The model may need the same *words*, but each word now costs more *tokens*, and the attention mass that used to sit on one key is spread across several.

Model that. Given a profile $p$ and an integer $r \ge 1$, the **$r$-fold dilution** $D_r p$ replaces each unit $i$ by $r$ consecutive tokens each carrying mass $p(i)/r$:
$$(D_r p)(j) \;=\; \frac{p(\lfloor j/r \rfloor)}{r}.$$
This is mass-preserving — the total is unchanged — and it preserves the nonincreasing shape. It is exactly "the same semantic content, spelt with $r$ times as many tokens."

> **The Dilution Law.** *Let $K = K_p(\tau) > 0$ be the undiluted knee. Then the diluted knee satisfies*
> $$r\,(K-1) \;<\; K_{D_r p}(\tau) \;\le\; r\,K.$$

The upper half is easy: $r K$ tokens is exactly the first $K$ whole words, which by mass preservation retain precisely $M_p(K) \ge \tau$. The lower half: $r(K-1)$ tokens is exactly the first $K-1$ whole words, retaining $M_p(K-1) < \tau$ by minimality of the knee, so by the Grid Lower-Bound Theorem the diluted knee is strictly greater.

Both ends are attained — flat profiles realize the upper end, and slightly perturbed flat profiles realize the lower — so the sandwich is as tight as a sandwich in terms of $r$ and $K$ alone can be.

And now the punchline. The pre-registered hypotheses said the domain shift would be a small additive offset. But:

> **No Additive Domain-Shift Law.** *For every claimed offset $d$ there exist a profile $p$, a bar $\tau$, and a ratio $r$ with*
> $$K_p(\tau) + d \;<\; K_{D_r p}(\tau).$$

Take the flat profile on $d+2$ keys with bar $d+2$, so $K = d+2$, and dilute by $r = d+2$; the diluted knee is $(d+2)^2$, which exceeds $(d+2)+d$ for every $d \ge 0$. A multiplicative law admits no uniform additive bracket. The " $\pm 4$ fine-step" summary of the four-domain table was a perfectly accurate description of four domains whose ratios all happened to be close to $1$, and it had no right to extrapolate to a fifth.

Dilutions also compose the way you would want: splitting each word into $s$ tokens and then each token into $r$ pieces is exactly an $rs$-fold split, $D_r \circ D_s = D_{rs}$. Successive domain shifts multiply. Additive bookkeeping is the wrong arithmetic from the start.

Real tokenizers are of course not uniform, and the model handles that too. If word $i$ costs $w(i) \ge 1$ tokens and $C_w(m) = \sum_{i<m} w(i)$ is the cumulative token count of the top $m$ words, then the variable dilution obeys
$$C_w(K-1) \;<\; K_{\text{diluted}}(\tau) \;\le\; C_w(K).$$
This is the sharpest statement of the mechanism, and it is a *quantitative, falsifiable prediction*: the diluted knee is the number of tokens the tokenizer spends on precisely the words the model actually needs. Not the corpus-average tokens-per-word — the average *restricted to the top-$K$ attended words*. Those two numbers diverge exactly when attention concentrates on rare words, which is exactly the French situation, where accents and elisions inflate the token cost of the most frequent function words. Bracketing by the extremes, if every word costs between $L$ and $R$ tokens, then $L(K-1) < K_{\text{diluted}} \le RK$; a language whose ratio band sits strictly above another's must have a strictly larger knee, and can sit whole grid-ranges away.

---

## Part three: flatness alone forces a large knee

The tokenization story is appealing but it requires a tokenizer to test. There is a second, independent route to the same scaling, and it needs nothing but the attention numbers themselves.

Define the **collision mass** (the Rényi-2 mass) of the top $k$ keys:
$$C_p(k) \;=\; \sum_{i<k} p(i)^2.$$
It is a standard measure of concentration: for a probability vector, large collision mass means peaked, small collision mass means flat and high-entropy.

Cauchy–Schwarz, applied to the all-ones vector and $p$ on the first $k$ coordinates, gives
$$M_p(k)^2 \;\le\; k \cdot C_p(k).$$
That inequality, plus the definition of the knee, yields:

> **The Entropy Bound on the Knee.** *If the collision mass never exceeds $C$ — that is, $C_p(k) \le C$ for all $k$ — and the bar $\tau > 0$ is attainable, then*
> $$K_p(\tau) \;\ge\; \frac{\tau^2}{C}.$$

No tokenizer, no domain labels, no linguistics: only flatness. Attention that is spread out *cannot* be summarized by a few keys, and the collision mass quantifies exactly how few "few" is allowed to be.

This bound is not a lossy convenience. It is optimal:

> **Sharpness.** *For the flat profile on $n$ keys with mass $1/n$ each, the collision mass is at most $1/n$, the knee at bar $\tau = 1$ is exactly $n$, and the bound gives $\tau^2/C = n$.*

Equality. So no function of the collision mass can do better than $\tau^2/C$.

And here is the pleasing part. Dilution divides the collision mass exactly:
$$C_{D_r p}(rm) \;=\; \frac{C_p(m)}{r},$$
because each squared weight $p(i)^2$ becomes $r$ copies of $(p(i)/r)^2$. A uniform bound $C$ for $p$ therefore becomes a bound $C/r$ for $D_r p$ at *every* budget, and the entropy bound turns into
$$K_{D_r p}(\tau) \;\ge\; r \cdot \frac{\tau^2}{C}.$$

The same factor $r$. The tokenization argument and the entropy argument — one mechanistic and tokenizer-dependent, one purely spectral and language-blind — produce the identical multiplicative scaling. Two independent derivations of one law is the sort of coincidence that stops being a coincidence.

For the French cell this converts the vague hypothesis "the tokenizer dilutes attention" into a measurable prediction: French attention maps should show a *smaller* collision mass than English maps at the same context length, and the ratio of collision masses should predict the ratio of knees. That is checkable from attention maps alone, with no tokenizer in the loop — which makes it a genuinely falsifiable successor to the tokens-per-word story.

---

## What to do instead

The practical moral is not "use a bigger grid." It is "use a grid of the right shape."

> **The Geometric Grid Theorem.** *For any nonnegative profile and attainable bar, let $S$ be the least exponent with $M_p(2^S) \ge \tau$. Then $K_p(\tau) \le 2^S$, and if $S > 0$ then $2^S < 2\,K_p(\tau)$.*

A geometric sweep $1, 2, 4, 8, \dots$ always returns a **two-sided** bracket, pinning the knee within a factor of two, using about $\log_2 K$ probes. A multiplicative tax of factor $r$ merely shifts $S$ by $\log_2 r$ — it cannot escape the instrument, only translate along it. By contrast the arithmetic grid gives no upper bound at all: for any arithmetic ceiling there are profiles, indistinguishable across the entire grid, whose knees are arbitrarily far apart.

Six geometric probes reach $64$ keys. Four arithmetic probes reached $32$ and returned a fact with no upper bound attached. The geometric grid is cheaper *and* strictly more informative. That is a rare trade.

One more provisioning rule falls out. Multilingual serving mixes traffic, and one might hope to budget for a mixture by interpolating between per-language budgets. The mixture of profiles $s\,p + (1-s)\,q$ has retention $s M_p + (1-s) M_q$, and its knee satisfies
$$\min(K_p, K_q) \;\le\; K_{\text{mix}} \;\le\; \max(K_p, K_q).$$
That is the only guarantee available, and the upper end is the operative one: **budget by the maximum, never by an average.** Since the dilution law forbids interpolating budgets between domains in the first place, this sandwich is the honest replacement for the interpolation instinct.

---

## The shape of the lesson

What began as a failed measurement on French prose turns out to be a story about instruments. The knee of an attention profile is a multiplicative quantity: it scales with how many tokens a language spends on the words a model needs, it is bounded below by how flat the attention is, and it composes by multiplication under successive shifts. An arithmetic ruler is the wrong tool for measuring a multiplicative quantity, in the precise sense that it can be escaped, and once escaped it reports a lower bound and nothing else.

There is also a broader caution here about extrapolating an empirical table. The four-domain summary — English prose, code, mathematics, all within $\pm 4$ keys of each other — was not wrong about those four domains. It was wrong in a subtler way: it fitted an additive form to samples of a multiplicative law, in a regime where the ratios happened to be near $1$. Add a fifth domain whose ratio is not near $1$, and the fit does not degrade gracefully; it fails categorically, past every bracket at once.

And accuracy, it turns out, is no guide at all. Among the measured domains there are pairs where higher full-context accuracy comes with a *smaller* knee (code: easier and cheaper) and pairs where higher accuracy comes with a *larger* knee (French: easier and dearer). One can construct four profiles taking only two accuracy values that realize both orderings simultaneously, which shows that **no** function — monotone or otherwise — carries full-context accuracy to the memory knee. They are logically independent quantities, and a serving system that budgets memory by a quality metric is budgeting by noise.

Measure the flatness. Sweep geometrically. Budget by the maximum. And when a table of four points suggests a law, ask what shape of law it is before extending it to a fifth.
