# How Many Words Does a Machine Really Need to Remember?

*A small measurement about attention, a hinge hiding in the data, and a law that says bigger models forget more gracefully.*

---

## The cheapest question in machine learning

Every time a language model reads a page of text, it does something extravagant. To produce the next word, it looks back at *every* word it has already seen, scores each one for relevance, and blends them into a single summary. If the page holds $n$ words, that is $n$ scores, every time, for every word produced. Double the page, double the bill.

This is why a natural engineering question keeps reappearing: **how many of those scores actually matter?**

Suppose we sort the attention scores from largest to smallest and keep only the top $k$ of them, throwing the rest away. If $k$ is tiny, the model's output drifts: it loses the thread, contradicts itself, forgets a name. If $k$ is large enough, the output is indistinguishable from the full computation. Somewhere in between is a threshold — call it the **knee** — the smallest $k$ at which the output still passes muster.

The knee is the number an engineer actually needs. It is the memory budget.

And the natural follow-up is: *how does the knee grow as the context grows?* If you double the length of the page, do you need twice as many keys? Ten more? None?

---

## Two models, three contexts, six numbers

The experiment is almost embarrassingly small. Take two language models of different size — one with about half a billion parameters, one with about one and a half billion. Run each at three context lengths: 512, 1024, and 2048 tokens. At each setting, sweep $k$ downward until the output fails a fixed drift test, and record the last $k$ that passes.

Six numbers come out. Writing $j$ for the number of doublings above the base context (so $j = 0, 1, 2$ corresponds to $512, 1024, 2048$):

| model | $j=0$ (512) | $j=1$ (1024) | $j=2$ (2048) |
|---|---|---|---|
| small (0.5B) | $16$ | $20$ | $24$ |
| large (1.5B) | $16$ | $16$ | $18$ |

Stare at those two rows for a moment. The small model's row is a perfect arithmetic progression: $+4$ keys per doubling. The large model's row is not: it goes $0$, then $+2$.

The headline writes itself. **Both models start at the same place — sixteen keys — and tripling the parameter count halves the price of context, from four extra keys per doubling to two.** Call this the *increment-halving* reading.

It is a good headline. It is also, when you push on it, only two-thirds true — and the third that fails is precisely the part an engineer would have deployed.

---

## The hinge

Start with the shape of the curves. The small model is described exactly by the straight line
$$K_{\text{small}}(j) \;=\; 16 + 4j,$$
which reproduces $16, 20, 24$ and has increment exactly $4$ at every step, forever.

For the large model, no straight line works. Suppose $K_{\text{large}}(j) = k_0 + dj$ for some whole numbers $k_0$ and $d$. Then $k_0 = 16$ from the first point, $16 + d = 16$ from the second forces $d = 0$, and then the third point demands $16 = 18$. There is no escape: **the large model's measured triple is not affine.** The increments $0$ and $2$ cannot both be one constant.

What *does* fit is a **hinge**:
$$K_{\text{large}}(j) \;=\; \max\bigl(16,\; 14 + 2j\bigr).$$
For $j = 0$ and $j = 1$ the affine demand $14 + 2j$ equals $14$ and $16$, both at or below the floor, so the floor wins and the curve reads $16, 16$. At $j = 2$ the demand reaches $18$ and lifts off, and the curve reads $18$. From then on it climbs by exactly $2$ per doubling.

The hinge has a pleasant mechanical interpretation. A model has a *minimum viable working set* — you cannot run it on four keys no matter how short the page, because a handful of attention heads always need their anchors. Sixteen is that floor. Underneath the floor sits a growing demand for context that is, for short pages, simply invisible; it becomes visible only once it exceeds the floor. The measurement caught the large model at exactly the moment of lift-off.

That also explains a small piece of scientific history. An earlier, coarser sweep of the same model — searching only $k \in \{16, 20, 24, \dots\}$, on a grid of spacing $4$ — reported the knee at 2048 as $20$. The finer sweep found $18$. Neither reading was wrong. A knee measured on a grid of spacing $d$ is *the least grid point at or above the true knee*, so it always satisfies
$$\text{true knee} \;\le\; \text{grid knee} \;<\; \text{true knee} + d.$$
A true knee of $18$, read on the spacing-$4$ grid, must come back as $20$: the over-read is $2$, comfortably inside the guaranteed resolution of $4$. The coarse experiment was correct about what it measured; it just measured something slightly coarser than it claimed.

---

## Halving, or quartering?

Now the headline. "Scale halves the increment, $4 \to 2$." Which increment?

There are two honest ways to read an increment off three points. The **terminal** increment is the last measured step:
$$K_{\text{small}}(2) - K_{\text{small}}(1) = 4, \qquad K_{\text{large}}(2) - K_{\text{large}}(1) = 2.$$
Exactly a halving. The headline is vindicated.

The **average** increment is the total rise divided by the two steps:
$$\frac{K_{\text{small}}(2) - K_{\text{small}}(0)}{2} = \frac{8}{2} = 4, \qquad \frac{K_{\text{large}}(2) - K_{\text{large}}(0)}{2} = \frac{2}{2} = 1.$$
That is a *quartering*, $4 \to 1$.

Both computations are correct, and they genuinely disagree: twice the terminal increment of the large model is $4$, while its total rise over the window is only $2$. The disagreement is not sloppiness; it is the hinge announcing itself. Averaging across a hinge mixes the flat regime with the sloped one and understates the slope. **The halving is a statement about the terminal increment, and only about that.** Any deployment reasoning based on the window average will be wrong in the other direction.

---

## The corollary that broke

The practical payoff advertised alongside the headline was: *a 20-key budget covers both models out to 2048, with margin*.

Half of that is right. The large model needs $18$ keys at 2048, so a budget of $20$ clears it with margin $2$. But the small model needs $24$. A budget of $20$ does not cover it, and no amount of rounding makes $24 \le 20$.

The corrected constant is easy to state, because the small model dominates everywhere:
- **At 2048, the least budget that covers both models is exactly $24$.**
- **More generally, for any horizon of $J$ doublings, the least budget that covers both models at every context up to that horizon is exactly $16 + 4J$** — dictated entirely by the small model, since $16 + 4j \ge \max(16, 14+2j)$ for all $j$.

So the halving law, correctly applied, says nothing reassuring about a shared budget. Worse: because the two increments differ, the gap between them grows. Past the hinge,
$$K_{\text{small}}(j) - K_{\text{large}}(j) = (16 + 4j) - (14 + 2j) = 2j + 2,$$
which exceeds any fixed bound eventually. **No finite key budget is safe for both models at all context lengths.** And the ratio of budgets tends to
$$\frac{16 + 4j}{14 + 2j} \longrightarrow 2,$$
so asymptotically the small model needs exactly twice the keys — the halving of the increment reappears, in the limit, as a factor of two in the level. At the measured horizon the ratio is only $24/18 = 4/3$; the interesting factor is a long way off.

---

## Where could an additive law even come from?

Here is the question that turns a measurement into mathematics. A knee that grows by a *fixed number of keys per doubling* is a strange object. Can any single attention profile produce it?

Model the sorted attention weights as a decreasing sequence $p_0 \ge p_1 \ge \dots$, and let the retained mass after $k$ keys be $R(k) = p_0 + \dots + p_{k-1}$. The knee at threshold $\tau$ is the smallest $k$ with $R(k) \ge \tau$. On a context of $n$ keys, the profile is renormalised so the $n$ weights sum to one.

Take the classic model, a truncated geometric profile with ratio $r \in (0,1)$: weight $\propto r^i$. Its retained mass after $k$ keys, on a context of $n$, is $(1-r^k)/(1-r^n)$. The knee is then bounded by
$$k^\star = \left\lceil \frac{\log(1-\tau)}{\log r} \right\rceil,$$
and — this is the point — **that bound does not mention $n$ at all.** Lengthening the context dilutes the top-$k$ mass slightly (the knee is monotone in $n$), but it never pushes the knee past $k^\star$. A monotone, bounded, integer-valued sequence is eventually constant. So along contexts $n = 2^j$, **the increments of a fixed geometric profile eventually become zero.**

Therefore no fixed geometric profile can produce $16 + 4j$. And the obstruction is not the geometric shape: repeat the argument for *any* fixed profile with finite total mass, renormalised to the context, and the same uniform bound appears. **No context-independent attention profile whatsoever can produce a persistent additive key increment.** A measured increment that survives several octaves is not a fact about a distribution — it is a fact about a *family* of distributions that changes with the context.

---

## The family that works, and where the halving comes from

So change the profile with the context. Model the attention tail as exponential with decay rate $\lambda$: the mass beyond $k$ keys is $e^{-\lambda k}$. To push that tail below a budget $\delta$ requires exactly
$$k(\lambda) \;=\; \frac{\log(1/\delta)}{\lambda}$$
keys — an equivalence, not an approximation: $e^{-\lambda k} \le \delta$ holds precisely when $k \ge \log(1/\delta)/\lambda$.

Now suppose the rate *degrades* with context, specifically that after $j$ doublings it has fallen to
$$\lambda_j \;=\; \frac{\lambda_0}{j+1}.$$
This says attention flattens in proportion to the logarithm of the context — a long page spreads a model's focus thin. Substituting,
$$k(\lambda_j) \;=\; (j+1)\,\frac{\log(1/\delta)}{\lambda_0},$$
which is **exactly affine in $j$**, with per-doubling increment $\log(1/\delta)/\lambda_0$.

Two consequences follow immediately.

**The halving, derived.** A model whose attention is twice as peaked at every context — replace $\lambda_0$ by $2\lambda_0$ — has exactly half the increment. That is the entire headline, obtained from one structural hypothesis rather than six data points. And the converse holds too: if a family of rates yields a knee affine in $j$ with slope $s$, then necessarily $\lambda_j = (\log(1/\delta)/s)/(j+1)$. *"Additive keys per doubling" and "decay rate inversely proportional to log-context" are the same statement.*

**The calibration.** Fix the tail budget at $\delta = e^{-4}$, so $\log(1/\delta) = 4$. Then $\lambda_0 = 1$ gives increment $4$ — the small model — and $\lambda_0 = 2$ gives increment $2$ — the large model, past its hinge. The measurement is telling us something clean: *the larger model's attention is exactly twice as peaked per unit of log-context.*

---

## A threshold at four and a half billion

If peakedness $\lambda_0$ is what scale buys, how does it scale? The simplest guess is a power law in the parameter count $N$ (in billions): $\lambda_0(N) = (2N)^\theta$, normalised so that the small model sits at $\lambda_0 = 1$. The large model then forces $3^\theta = 2$, i.e.
$$\theta = \frac{\log 2}{\log 3} \approx 0.6309.$$
The two measured cells determine the exponent completely. The induced prediction for the per-doubling increment is
$$I(N) \;=\; 4\,(2N)^{-\theta},$$
which returns $I(0.5) = 4$ and $I(1.5) = 2$ by construction, and is strictly decreasing in $N$.

Now ask when a model needs *less than one extra key per doubling* — when, for integer key counts, its attention budget is effectively context-free. Since $I$ is strictly decreasing and $2 \times 4.5 = 9 = 3^2$, we get $I(4.5) = 4 \cdot 2^{-2} = 1$ exactly, and hence
$$I(N) < 1 \iff N > 4.5 .$$
**Above roughly four and a half billion parameters, the attention budget stops caring about context length.** Similarly $2 \times 13.5 = 27 = 3^3$ gives $I(13.5) = 1/2$ on the nose.

This is a genuinely falsifiable prediction, and it names its own test. For a seven-billion-parameter model, the law brackets the increment strictly: $1/2 < I(7) < 1$. On an integer grid that means **the knee should move by zero or one key between contexts 2048 and 4096.** A measured jump of two or more kills the law outright.

---

## What one honest measurement teaches

There is a second experiment the analysis demands, and it is cheaper still. How well do three points pin down a hinge? A hinge with floor $16$, base $b$, and slope $s$ passes through $16, 16, 18$ exactly when
$$b + 2s = 18 \quad\text{and}\quad b + s \le 16 .$$
Those two conditions force $s \ge 2$ — but they permit $s$ anywhere from $2$ to $9$. The advertised slope of $2$ is the *parsimonious* fit, not a measurement: $(b,s) = (12,3)$ passes through the very same three points. The reason is structural, and it generalises: a measurement grid whose early points lie below the hinge supplies only inequalities there, and inequalities bound a slope from below without identifying it.

Happily, the ambiguity resolves at the next octave. At $j = 3$ (context 4096), the two admissible fits predict $\max(16, 14 + 6) = 20$ and $\max(16, 12 + 9) = 21$. **One measurement at 4096 — a single key of difference — decides the slope.**

That is the shape of the whole story. A six-number table produced one memorable slogan, and the slogan survived: scale really does halve the terminal key increment, and there is a clean structural reason why — peakedness of attention grows with scale, and increments are inversely proportional to peakedness. But the same six numbers also produced a deployment rule that was simply false, a "slope" that was only a lower bound, and an averaged reading that disagreed with the terminal one by a factor of two.

The lesson is not that the measurement was bad. It is that a curve with a hinge in it will lie to you if you fit a line, and a grid of spacing four will lie to you by up to three keys, and neither lie announces itself. What separates a slogan from a law is the willingness to write down exactly what the numbers force — no more — and then to say, out loud, which single experiment would prove you wrong.
