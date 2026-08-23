# The Tokenizer Tax Is Four Keys

## What a language costs a machine that has to forget

Every system that reads has to forget. A human skimming a legal contract keeps a handful of clauses in working memory and lets the rest blur. A machine that reads a long document keeps a *cache* — a fixed number of stored summaries of what it has seen, one slot per retained position — and throws away the rest. The question that matters for anyone deploying such a system is brutally practical: **how many slots do you have to keep?**

Call that number the *budget*, $k$. Keep too few and accuracy collapses; keep too many and you pay for memory you never use. Somewhere in between is a knee: the smallest budget at which performance is essentially indistinguishable from remembering everything.

This article is about a small, sharp, surprisingly rigid fact concerning that knee. It says that the answer depends on the *language you are reading* — and that it depends on it by exactly one quantum.

---

## Measuring a knee

Fix a bar. We will say a budget is *sufficient* if it retains at least $98\%$ of the accuracy you would get with unlimited memory. Sweep the budget over a grid — $4, 8, 12, 16, 20, 24$ slots — and record the retained accuracy at each point. Because more memory never hurts, the resulting curve $a$ is nondecreasing. The **knee index** is the first grid index that clears the bar,
$$\kappa(a) \;=\; \min\{\,j : a(j) \ge \beta\,\}, \qquad \beta = 0.98,$$
and the **knee budget** is $4\kappa(a)$, since grid index $j$ means $4j$ slots.

Two readings determine everything. If the curve is nondecreasing and you observe $a(j) < \beta \le a(j+1)$, then $\kappa(a) = j+1$ — no matter what the curve does anywhere else. That triviality is what makes a sweep a *measurement* rather than a guess: you only have to trust two numbers.

Here are the two numbers, twice, for German prose (Goethe and a second classic), at two context lengths:

| context | $4$ | $8$ | $12$ | $16$ | $20$ | $24$ |
|---|---|---|---|---|---|---|
| $512$ | $0.883$ | $0.953$ | $0.969$ | $0.976$ | **$0.983$** | $0.988$ |
| $1024$ | — | $0.926$ | $0.956$ | $0.968$ | $0.975$ | **$0.982$** |

At context $512$ the bar is first cleared at $20$ slots; at $1024$, at $24$. Meanwhile the same experiment on **English** prose gives $16$ and $20$.

German costs exactly four more slots. At both context lengths. Not three, not five, not "somewhere between." Four.

---

## Why four is not a coincidence

Four is the grid step. It is also — and this is the part that turns a measurement into a structure — the amount you pay for *doubling the context*.

Earlier legs of this programme measured three other corpora and fitted each to an affine **budget law**
$$L(d) \;=\; b + c\,d,$$
where $d$ counts doublings of context above the reference length $512$, $b$ is the base budget at that reference, and $c$ is the per-doubling increment. The completed table:

| corpus | base $b$ | increment $c$ |
|---|---|---|
| source code | $12$ | $4$ |
| English prose | $16$ | $4$ |
| mathematics | $16$ | $4$ |
| German prose | $20$ | $4$ |

Three things jump out. The increment is the same, $4$, for every corpus: **scale does not see the language**. The bases $12, 16, 20$ form an arithmetic progression whose common difference is again $4$. And $4$ is the sweep grid step. Domain, scale, and resolution all share a single quantum.

The consequence is an *exchange law*. Because German's base exceeds English's by exactly the per-doubling increment,
$$L_{\text{German}}(d) \;=\; L_{\text{English}}(d+1) \;=\; L_{\text{code}}(d+2)$$
for every $d$. **Reading German at a given context costs precisely what reading English costs at twice that context, and what reading code costs at four times it.** A language rung and a context doubling are interchangeable currency.

Assign each corpus a *rank*: code $0$, English prose and mathematics $1$, German prose $2$. Then the entire eight-cell table collapses into a single affine function of a single variable,
$$\text{budget}(\text{corpus}, d) \;=\; 12 + 4\big(\mathrm{rank} + d\big).$$
Two workloads need exactly the same cache if and only if their rank sums agree. The deployment table is not a two-dimensional grid of independent numbers; it is a family of parallel diagonals.

---

## Was the diagonal forced?

Here is where the story stops being data and starts being mathematics. Collapse to one coordinate looks like numerology until you ask what *had* to be true for it to happen. The answer is: exactly two things, and no more.

> **Rigidity Theorem.** Let $F(r,d)$ be any integer-valued budget assigned to rung $r$ at $d$ doublings. Suppose
> **(E)** *one rung up costs one doubling*: $F(r+1,d) = F(r,d+1)$ for all $r,d$; and
> **(I)** *the increment is a constant $c$*: $F(r,d+1) = F(r,d) + c$ for all $r,d$.
> Then $F(r,d) = F(0,0) + c\,(r+d)$ for all $r,d$.

The proof is two nested inductions, each one line long: (I) alone gives $F(0,d) = F(0,0) + cd$; then (E) lets you walk any rung down to rung zero, trading each rung for a doubling.

That is a genuinely satisfying kind of theorem, because it converts a coincidence into a pair of testable claims. And the two claims are *independent* — neither implies the other. The family $F(r,d) = (r+d)^2$ satisfies the exchange law perfectly and is not affine in $r+d$ at all, so (E) alone does not force the collapse. The family $F(r,d) = r^2 + 4d$ has exactly the right constant increment $4$ but violates exchange (at $r=2$, $d=0$: $9 \ne 8$), so (I) alone does not force it either. Both are needed, and the German leg is precisely the experiment that tested (E) in a new place.

The theorem also tells you what a *refutation* would look like. If some future corpus has an increment other than $4$, then no exchange law can ever connect it to this ladder: the mismatch shows up at a computable context, and the diagonal picture breaks. The prediction is falsifiable by one cell.

---

## How much noise can a knee survive?

A knee is a threshold crossing, and threshold crossings are exactly where noise is most dangerous. So how fragile is "$20$"?

Precisely as fragile as the smaller of its two margins.

> **Stability Theorem.** Suppose the sweep clears the bar at index $j+1$ with margin $m$ and misses it at $j$ with margin $m$: $a(j) + m \le \beta$ and $\beta + m \le a(j+1)$. Then *every* nondecreasing curve $a'$ with $|a'(i) - a(i)| < m$ for all $i$ reports the same knee, $\kappa(a') = j+1$.
>
> **Sharpness.** Conversely, if $\beta \le a(j) + m$, then the uniform upward shift $a'(i) = a(i) + m$ — a perfectly legitimate curve at that noise level, still nondecreasing, still within $m$ — already reports a knee at $j$ or below.

The below-bar margin is therefore the exact stability radius: not a bound one hopes is tight, but the tight one.

Applied to the German data: at context $512$ the deciding readings are $0.976$ (below, margin $0.004$) and $0.983$ (above, margin $0.003$), so the knee $20$ survives any uniform error below $0.003$ — and a uniform error of $0.004$ demonstrably drags it down to $16$. At context $1024$ the margins are $0.005$ and $0.002$, so the radius is $0.002$.

Those radii are on the order of one reported standard error. The honest reading of the round is therefore: the $+4$ is real, and it is certified to about one standard error, no more. That is the boundary of what the data can support, stated as a theorem rather than a hedge.

---

## What "$+4$" actually certifies

There is a second, subtler honesty problem, and it is worth dwelling on because it recurs everywhere in empirical mathematics: **the grid**.

A sweep on step $4$ never reports a true requirement; it reports the true requirement rounded up. Write $\lceil x \rceil_4 = 4\lceil x/4 \rceil$ for that reading. It is a closure operator in the exact technical sense — it is inflationary ($x \le \lceil x\rceil_4$), monotone, and idempotent — because it is one half of a Galois connection: for a grid point $4n$,
$$x \le 4n \iff \lceil x/4\rceil \le n.$$

Now suppose the true, unquantised German requirement is $\kappa_{\mathrm{DE}}$ and the English one is $\kappa_{\mathrm{EN}}$. The sweep tells us $\lceil \kappa_{\mathrm{DE}}/4\rceil = 5$ and $\lceil \kappa_{\mathrm{EN}}/4\rceil = 4$, which means exactly
$$16 < \kappa_{\mathrm{DE}} \le 20, \qquad 12 < \kappa_{\mathrm{EN}} \le 16.$$
Subtracting, the true tax lies in the open interval $(0,8)$ — **strictly positive, but not pinned to $4$.** And that is sharp in both directions: the pair $(\kappa_{\mathrm{DE}}, \kappa_{\mathrm{EN}}) = (16.5, 16)$ reproduces both measured readings with a true tax of $1/2$, while $(20, 12.25)$ reproduces them with a true tax of $31/4$.

So the headline number is a property of the *reported* budgets, not of the underlying knees. What survives is: the true tax is strictly positive (so "no shift at all" is refuted continuously, not merely on the grid), it is less than two grid steps, and the reported shift is exactly one step for *every* pair of true knees consistent with the readings.

Could a finer grid have done better? Could a coarser one have sufficed? There is an exact answer. A sweep of step $g$ reports all three measured bases $12, 16, 20$ without distortion if and only if $g$ divides $4$. So step $4$ is the *coarsest faithful* grid — a lucky choice, and a provably minimal one. Step $8$ is doubly misleading: it collapses the code-to-English gap to zero and inflates the English-to-German gap to $8$, twice its reported size. The grid the experiment happened to use is the only coarse grid that tells the truth about all three.

---

## Why German? A falsifiable mechanism

The intuition behind the tax is linguistic: German compounds pack more content into each word — *Geschwindigkeitsbegrenzung* is one word where English needs three — so a tokenizer spends fewer tokens per idea, and each retained slot carries a denser payload. More content per position means more positions are needed to hold an argument.

That story can be turned into arithmetic. Suppose a corpus has *relative content density* $\rho$ (English $= 1$) and needs $16\rho$ slots before quantisation. Then its predicted base on the fine grid is
$$B(\rho) \;=\; 4\lceil 4\rho\rceil.$$
This is calibrated by construction ($B(1) = 16$), monotone, and invertible in a precise sense: $B(\rho) = 4n$ if and only if $\rho \in \big(\tfrac{n-1}{4}, \tfrac{n}{4}\big]$.

Feed in the three measured bases and the densities are forced into **disjoint, ordered intervals**:
$$\rho_{\text{code}} \in (\tfrac12, \tfrac34], \qquad \rho_{\text{English}} \in (\tfrac34, 1], \qquad \rho_{\text{German}} \in (1, \tfrac54].$$
The point is that these are claims about *token counts alone*. You can check them by counting tokens on the corpora, with no model, no sweep, and no training. The mechanism has been made falsifiable independently of the experiment that suggested it. The model also pre-registers a prediction: any corpus packing more than $3/2$ times English's content per token must show a base of at least $28$ slots. A language measured denser than that but reading $20$ would refute the model outright.

---

## What to actually buy

Finally, the engineering payoff. A *workload* is a finite set of cells, each a (corpus, context) pair. Its cost is the largest budget among its cells — never a sum, always a join. Three facts make this useful:

* **One-cell certificate.** The cost of any workload is *attained* by one of its cells. You can always justify a budget by exhibiting a single worst case.
* **Monotonicity and submodularity.** Adding work never lowers the bill, and $\mathrm{cost}(S \cup T) + \mathrm{cost}(S \cap T) \le \mathrm{cost}(S) + \mathrm{cost}(T)$. Consolidating two workloads onto one cache never costs more than provisioning them separately.
* **One number.** In ladder coordinates, $\mathrm{cost}(S) = 12 + 4\max_{c \in S}(\mathrm{rank}(c) + d(c))$. Sizing a deployment reduces to finding the largest rank sum present.

For the four measured corpora at contexts $512$ and $1024$: **$24$ slots covers everything, and $24$ is the least such budget** — German at $1024$ attains it exactly. At $2048$ the $24$-slot cache fails, and it fails for German alone; code, English and mathematics still fit. At $4096$ the least universal cache is $32$.

Sizing by English is not a safe default: it under-provisions a multilingual workload by exactly one grid step, at every context. Sizing by code is short by two.

And if you can tolerate missing part of your traffic, the price of the last cell is stark. Over the eight-cell workload, coverage grows $1, 4, 7, 8$ as the budget rung climbs $0, 1, 2, 3$. Serving all eight cells costs $24$ slots; serving seven costs $20$. **One-sixth of the multilingual cache budget buys the last one-eighth of the workload** — and that last cell is unique: German prose at context $1024$.

That, in one sentence, is the tokenizer tax. It is four keys, it is the same four keys that a context doubling costs, and on a mixed workload you pay it for one cell in eight.
