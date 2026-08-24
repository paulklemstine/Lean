# One Number Per Language? The Rise and Fall of the Domain Factor

## A very tempting table

Here is a table that looks like a discovery.

Somebody measured, for five kinds of text, how many "keys" a long-context language model actually needs to keep in order to preserve $98\%$ of its attention mass. The number is called the *key budget*, written $k^*$, and it was measured twice per domain: once with a context window of $512$ tokens, once with $1024$.

| domain | $k^*$ at 512 | $k^*$ at 1024 | increment per doubling |
|---|---|---|---|
| source code | 12 | 12 | $+0$ |
| English prose | 16 | 20 | $+4$ |
| mathematics | 16 | 20 | $+4$ |
| German prose | 20 | 24 | $+4$ |
| French prose | 32 | 40 | $+8$ |

Stare at it and a pattern jumps out. French is exactly *twice* English in both columns: $32 = 2\times16$ and $40 = 2\times20$. Mathematics is exactly English. German looks like $1.25\times$, code like $0.75\times$. So perhaps every domain carries a single number — a *domain factor* — and its whole budget curve is the English curve times that number. If true, this would be genuinely useful: never sweep a grid for a new language again. Measure one point, get the factor, and the entire curve follows.

The claim has a name: **the domain factor is multiplicative**.

What happens when you take it seriously and ask a mathematician rather than a spreadsheet? The answer is more interesting than "yes" or "no". There *is* a precise mechanism producing multiplicative factors; it comes with a sharp error bar; it explains the French row exactly and proves two of the five rows cannot arise from it at all. And then, in a final twist, the way the experiment was run turns out to measure a *different* quantity from the one the mechanism predicts — so even the French row evaporates unless the underlying budget curve has already stopped moving.

## What a key budget actually is

Strip away the machinery and an attention head does something simple: it spreads a fixed amount of "importance" across the tokens it can see. Sort those importances from largest to smallest and you get a positive sequence
$$w_0,\; w_1,\; w_2,\; \dots$$
the **attention profile**. The mass in the top $m$ keys is the *head mass* $M_w(m) = w_0 + \cdots + w_{m-1}$.

Fix a context length $n$ — how many tokens are visible — and a budget $k$ — how many keys you may keep. The fraction of visible mass you retain is
$$R_w(n,k) = \frac{M_w(\min(k,n))}{M_w(n)}.$$
Finally fix a **gate** $\tau \in (0,1]$, the fraction you insist on keeping ($0.98$ in the experiment). The **key budget**, or **knee**, is the smallest budget that clears the gate:
$$k^*(w,n,\tau) = \min\{k : R_w(n,k) \ge \tau\}.$$

That is the whole setup: no transformers, no softmax, no training. Everything below is a theorem about a positive sequence, a truncation and a threshold.

## The mechanism: stretching a profile

Why would a domain have a *multiplicative* factor at all? Suppose French does exactly what English does, but spread thinner: each unit of information English packs into one token, French smears over $c$ tokens. Then the French profile is not some unrelated sequence — it is the English profile *time-dilated*. Define the **block dilation**
$$(D_c w)_i = \frac{w_{\lfloor i/c \rfloor}}{c}.$$
Each key is split into $c$ consecutive keys carrying $1/c$ of its mass. Nothing is created or lost; the information is stretched.

How does mass accumulate in a stretched profile? Exactly:

> **Master Mass Identity.** For every $c \ge 1$ and every $m \ge 0$,
> $$M_{D_c w}(m) = M_w\!\left(\left\lfloor \tfrac{m}{c} \right\rfloor\right) + (m \bmod c)\cdot \frac{w_{\lfloor m/c\rfloor}}{c}.$$

Mass accumulates block by block just as in the base profile, and *interpolates linearly inside a block*. Everything else is a corollary. At whole blocks the profiles agree, $M_{D_cw}(ck) = M_w(k)$, so the retained curve is merely reparametrised:

> **Reparametrisation Theorem.** $R_{D_c w}(cn, ck) = R_w(n,k)$ for all $n,k$.

Stretch context and budget by the same factor and you see the identical picture. This is the exact sense in which a dilated domain is "the same domain, slower".

## The multiplicative law — and its one-block error bar

If the retained curve is just reparametrised, surely the knee simply multiplies? Almost. The knee is a *minimum*, and the dilated profile has budgets available that are not multiples of $c$: the values *inside* a block. What is true is a bracket, and it is sharp.

> **Dilation Bracket Theorem.** For a positive profile $w$, $c \ge 1$, $n \ge 1$, $0 < \tau \le 1$, writing $k^* = k^*(w,n,\tau)$:
> $$c\,(k^* - 1) \;<\; k^*(D_c w,\; cn,\; \tau) \;\le\; c\,k^*.$$

The upper bound holds because at budget $ck^*$ the dilated profile retains exactly what the base retained at $k^*$ — enough. The lower bound holds because at budget $c(k^*-1)$ it retains exactly what the base retained at $k^*-1$ — which by definition failed.

So the multiplicative law is right **up to one dilation block**, and that is not a defect of the proof:

> **Sharpness.** For the uniform profile $w_i = 1$ with $c=2$, $n=2$, $\tau = 1/4$, the base knee is $1$ and the dilated knee is also $1$, not $2$.

Exact multiplicativity is therefore *false* as a general theorem. It needs a hypothesis, and there is a clean, checkable one:

> **Exactness Criterion.** If the gate is still not cleared one key before the block boundary — that is, $R_{D_c w}(cn,\, ck^*-1) < \tau$ — then $k^*(D_cw,cn,\tau) = c\,k^*$ on the nose.

Dividing the bracket by $ck^*$ gives the practical reading:

> **Relative Error Bound.** $\;1 - \dfrac{1}{k^*} \;<\; \dfrac{k^*(D_c w, cn,\tau)}{c\,k^*} \;\le\; 1.$

The relative error of a multiplicative factor is at most $1/k^*$: below $6.3\%$ on budgets of $16$ to $40$, the range of the reported table. A factor law read off a coarse grid can be perfectly honest at the resolution it was measured while being false as an identity.

Crucially, *one* dilation parameter governs *both* columns. Writing $\Delta$ for the doubling increment:

> **Increment Bracket.** $\;c\,\Delta - (c-1) \;\le\; \Delta_{\text{dilated}} \;\le\; c\,\Delta + (c-1)$.

That is the structural reason a "$+4$" English column should become a "$+8$" French column at $c=2$. Not a coincidence in the data: a theorem about stretched sequences.

## Auditing the table: three rows pass, two cannot

With a mechanism in hand the table becomes arithmetic. Say a row $(a,b)$ *has factor* $\lambda$ relative to a base row $(a_0,b_0)$ if the *same* $\lambda$ reproduces both columns. The factor is then determined by the first column alone, $\lambda = a/a_0$; there is at most one. And the entire empirical content compresses to one multiplication per row:

> **Cross-Ratio Criterion.** A row admits some factor if and only if $a\,b_0 = b\,a_0$.

Apply it. English $(16,20)$ and mathematics $(16,20)$: pass, factor $1$. French $(32,40)$: $32\cdot 20 = 640 = 40 \cdot 16$ — **passes, factor exactly $2$**. Code $(12,12)$: $240 \ne 192$ — **fails**; the factor $0.75$ predicts $15$ at the long context, the measurement is $12$. German $(20,24)$: $400 \ne 384$ — **fails**; the factor $1.25$ predicts $25$, the measurement is $24$.

The global verdict is refuted by its own data. The true statement is a classification: exactly English, mathematics and French are multiples of the English curve.

The two failures fail *differently*. German misses by one key out of $25$ — a single grid point, inside the measurement's resolution. Code misses by $3$ out of $15$, and is the only row with a *zero* increment. That is qualitative, not quantitative, because of an elementary fact: a non-zero increment can never be scaled to zero by a non-zero factor. If English gains $4$ keys per doubling, no multiplicative family containing English yields a domain that gains none. Source code is not a scaled dialect of prose.

The mechanism sharpens arithmetic into impossibility. Since the bracket holds for *every* positive profile, context and gate, feeding in the English knee $16$ makes each row decidable:

- **No integer dilation gives the code row.** The dilated knee exceeds $15c \ge 15$, hence is at least $16$; $12$ is unreachable for every $c \ge 1$.
- **No integer dilation gives the German row.** The dilated knee lies in $(15c,\,16c]$, and that window skips $20$ for every $c$: $(15,16]$, then $(30,32]$, then $(45,48]$, …
- **The French row forces $c = 2$.** If $32 \in (15c,16c]$ then $c = 2$, uniquely.

And here is the part that makes this science rather than curve-fitting. Once $c = 2$ is *forced* by the short column, the theory **predicts** the long column before looking: the knee must lie in $(2\cdot 19,\ 2 \cdot 20] = \{39,40\}$. The reported measurement is $40$. A pre-registered, two-valued prediction, confirmed.

## Fractions, and why merging is different

If dilation only makes integer factors, what about $0.75$ and $1.25$? They need the *adjoint* operation. Where dilation splits keys, **key merging** fuses them:
$$(C_q w)_i = w_{qi} + w_{qi+1} + \cdots + w_{qi+q-1}.$$
Merging is mass-preserving too, and reparametrises the retained curve as $R_{C_qw}(n,k) = R_w(qn,qk)$. But its knee obeys something dilation's does not — an *exact closed form*:

> **Ceiling Law.** $\;k^*(C_q w, n, \tau) = \left\lceil k^*(w, qn, \tau)/q \right\rceil.$

No window, no error bar: an equality. The proof is a small gem — the budgets clearing the gate for the merged profile are exactly $\{k : k^*(w,qn) \le qk\}$, whose least element is the ceiling. This ceiling is the real origin of the quantisation everyone sees in such tables: every reported entry is a multiple of $4$, every increment lies in $\{0,4,8\}$. **Dilation multiplies increments; merging quantises them.**

A rational factor $p/q$ is merging followed by dilation, with knee window $\big(p(\lceil K/q\rceil - 1),\; p\lceil K/q\rceil\big]$ where $K = k^*(w,qn)$. This buys back German: at $5/4$ the two windows are $(15,20]$ and $(20,25]$, and $(20,24)$ sits inside both. The German anomaly is a *ceiling effect*, not noise — a genuine gain, since integer dilation provably excluded it.

Code is not rescued so cheaply. Its signature is the flat column, and flatness has a price:

> **Flat curves force coarse merging.** If a rational rescaling of a base curve with knees $16$ and $20$ has the same knee at both contexts, then $q \ge 5$.

For $q \le 4$ the ceilings differ — $16$ vs $20$, $8$ vs $10$, $6$ vs $7$, $4$ vs $5$ — so the windows are disjoint and the increment cannot vanish. Only at $q = 5$ do both collapse to $4$; and at $q=5,p=3$ both windows are $(9,12]$, containing the measured $12$ twice. Code *is* describable — at effective factor $3/5 = 0.6$, not the reported $0.75$. The reported factor and the reported flat increment cannot come from one mechanism.

## The twist: the experiment measured something else

Everything so far compares a domain with English at *matched contexts*: the dilated profile at $cn$ against the base at $n$. That is the comparison in which "the same information" is visible on both sides. It is not the comparison the experiment made. Every row was measured at the *same token budget*: $512$ for everybody, then $1024$. Under that **token-matched** reading the answer is sharp and negative.

> **Token-Matching Dichotomy.** If a domain is a $c$-fold dilation of a base profile and the exact law $k^*(D_cw, N) = c\,k^*(w,N)$ holds at a single context $N = cn$, then $k^*(w,n) = k^*(w,N)$: the base curve is *flat* across the whole ratio $c$. Conversely, if it is flat (and the gate is not cleared one key early), the token-matched law holds exactly.

An exact factor at equal token counts is available **only to a context-stable base curve**. Contrapositively, a curve that still rises across the ratio — and $16 \to 20$ rises — admits *no* exact token-matched factor at any depth.

Quantitatively the two readings differ by exactly $c$ times the base increment, up to one block, and that gap kills the flagship row. Read the English chain backwards by its own $+4$ law: $k^*@512 = 16$ gives $k^*@256 = 12$. Every two-fold dilation then has, at $512$,
$$22 < k^*(D_2w,\,512) \le 24.$$
The reported French $32$ is not unlikely; it is **unreachable** — no positive profile, no scale, no gate produces it. The honest token-matched French factor lies in $(11/8,\,3/2]$, not at $2.0$. Insist on the $32$ and you force English to be flat between $256$ and $512$, contradicting the $+4$ reported in the same table.

The code column fares no better, and here we compute rather than bracket, because merging is exact. Continuing the chain, $k^*@1024 = 20$ and $k^*@2048 = 24$ give $k^*(C_2w,512) = \lceil 20/2\rceil = 10$ and $k^*(C_2w,1024) = \lceil 24/2\rceil = 12$: a $+2$ increment. Merging turns $+4$ into $+2$; never into $+0$. In general, whenever the base increment is at least the merging depth, the merged increment stays positive. The flat code column is not a merging artefact.

The verdict, then, is less wrong than *mis-addressed*: a matched-context statement tested by a token-matched experiment. The two agree exactly when the base curve has stopped moving — the one thing the table denies by reporting a positive increment.

## When is a factor legitimate? A certificate

The dichotomy is constructive, and points at what one should have measured. A factor is legitimate as soon as the base curve is flat. So: when is a budget curve flat?

Begin with a fact obvious once stated: **the knee is monotone in the context length** — seeing more tokens can only raise the budget. Then:

> **Flatness Certificate.** Let the profile decay geometrically, $w_{i+1}\le r\,w_i$ with $0<r<1$. If the tail beyond the measured knee already fits inside the gate slack,
> $$\frac{r^{\,k^*(w,n)}}{1-r} \;\le\; 1-\tau,$$
> then the knee never moves again: $k^*(w,m) = k^*(w,n)$ for every $m \ge n$.

A *finite, checkable inequality* in three numbers: decay ratio, gate, one measurement. And never vacuous, because unconditionally:

> **Eventual Exact Flatness.** A geometrically decaying profile's knee is eventually *constant*, not merely bounded.

Monotone plus bounded, for integers, means eventually constant. Hence past its stabilisation point every dilation of a geometric profile satisfies the token-matched law **exactly**. A domain factor at equal token counts is real — it is the privilege of *spectral-gap* domains, whose attention decays fast enough that the tail is already paid for.

Conversely, a curve still rising across a doubling fails the certificate *for every admissible decay ratio at once*: its conclusion is an exact equality of two measured integers, and a rise contradicts it. The reported English row has no certificate, at any $r$. We get a dichotomy: a domain either stabilises — and then has an honest, exact factor — or keeps rising, and then no factor is even *defined* at the context where it was measured.

## What the number really multiplies

If factors live in the stable regime, what is the stable value? It is a property of the profile alone. Define the **limit knee**
$$k_\infty(w,\tau) = \min\Big\{k : \tau\sum_i w_i \le M_w(k)\Big\},$$
the least budget clearing the gate against the *total* mass. Three facts pin it down. Always $k^*(w,n) \le k_\infty(w)$: **every measurement systematically under-reports the asymptotic budget.** One inequality decides the knee exactly — as soon as $M_w(k_\infty-1) < \tau M_w(n)$, the measured knee *is* the limit knee. And for geometric decay the freezing context is explicit: any $N$ with $\tau w_0 r^N/(1-r) < \tau\sum_i w_i - M_w(k_\infty-1)$ works, and such an $N$ always exists.

Hence the honest form of the verdict:

> **Asymptotic Factor Theorem.** Past the stabilisation locus, $k^*(D_c w, cm, \tau) = c\,k_\infty(w,\tau)$. The single number per domain multiplies the *asymptotic* budget, never a pre-asymptotic measurement.

This explains, with no appeal to noise, why measured factors drift with context: measurements always under-report, so a ratio of two under-reports need not be the ratio of the limits. The error is systematic and downward.

Is any of this realisable? Yes — explicitly. Take $w_i = 2^{-i}$ with gate $\tau = (2^{32}-5000)/(2^{32}-1) \approx 0.9999988$. Then, in exact arithmetic: $k^*(w,16) = 16$ and $k^*(w,32) = 20$, a genuine $+4$-per-doubling chain with geometric decay; the limit knee is exactly $20$; at context $20$ the knee is still at most $19$, and from $21$ onwards it is frozen at $20$. The stabilisation locus is *exactly* $21$. The reported short context sits strictly below it: the reported $20$ is the asymptotic budget, the reported $16$ is not. The audit is not vacuous — the chain is perfectly realisable, and it is the *certificate*, not the data, that fails.

## What survives

What does not survive is the global verdict. Two of five rows violate the cross-ratio identity a single factor forces; the flat code column comes neither from a multiplicative family with a rising base nor from key merging; and under the reading actually used, the flagship French $32$ is outside the achievable window by eight keys.

What survives, across all five rows, is *quantisation*: every entry a multiple of $4$, every increment in $\{0,4,8\}$. Strictly weaker than multiplicativity, and violated by nothing — and the ceiling law says where it comes from: merging, not stretching.

What also survives is the mechanism, sharpened. Multiplicative factors are exactly the signature of block dilation. They are accurate to one block, hence to relative error $1/k^*$. They carry to doubling increments with the same factor. They become exact past the stabilisation locus, where they multiply a genuine profile invariant. Spectral-gap domains have honest factors; rising domains have none yet.

That is a better result than the one we started with. "Measure one number per domain" is a real prescription — with a precondition (check the certificate) and a proper object to attach the number to: not a measurement, but a limit. And the table's most interesting row, French with its factor of $2$, is exactly the row whose factor was *forced* by one column and *confirmed* by the next. That is the shape of a real prediction.

The moral keeps needing relearning: a regularity spotted in a small table is a hypothesis about a mechanism. Write the mechanism down, and it tells you two things at once — the precise sense in which the regularity is true, and the precise rows on which it cannot be.
