# Ceilings on Correlation: what a tied variable can and cannot tell you

> **A guided tour.** By the end of this page you will be able to look at any
> rank correlation reported against a coarse, tied variable and say, from the
> block sizes alone, *how large it was allowed to be*. We build the theory from
> scratch, test it interactively, and then use it to solve a real measurement
> puzzle: a diagnostic correlation that stubbornly reads $0.648$.

---

## 1. The puzzle

Draw integers uniformly at random from $\{0, 1, \dots, 2^{b}-1\}$. For each
draw, record its **zero-count** $T$: how many binary zeros sit at the right-hand
end before the first $1$. ($40 = 101000_2$ has three; $7 = 111_2$ has none.)
Against this count, correlate a downstream continuous **rate**, and report the
Spearman rank correlation as a diagnostic dial.

At $b = 44$ the dial reads about $0.78$. At $b = 64$ it reads

| seed | reading |
|---|---|
| 20261140 | $0.658$ |
| 20261141 | $0.642$ |
| 20261142 | $0.643$ |
| **pooled** | **$0.648$**, CI $[0.629, 0.665]$ |

A gentle, monotone decline. Why?

The obvious suspect is **ties**. The zero-count is enormously lumpy: half of all
integers have $v_2 = 0$, a quarter have $v_2 = 1$, an eighth have $v_2 = 2$. Vast
numbers of observations share a value, and shared values mean shared ranks, and
shared ranks mean lost information. The rest of this page turns that hunch into
an exact formula — and then uses the formula to destroy it.

<details>
<summary><b>Background: what is a Spearman rank correlation?</b> (click to expand)</summary>

Ordinary (Pearson) correlation measures linear agreement between two variables.
[Spearman's rank correlation](https://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient)
replaces each observation by its **rank** — its position in sorted order — and
then computes the ordinary correlation of the ranks. It therefore measures
*monotone* agreement: whether the two variables order the observations the same
way, regardless of scale.

When several observations share a value, they are given the **midrank**: the
average of the positions their block occupies. Four observations tied for
positions $3,4,5,6$ each receive $4.5$. This convention keeps the rank vector's
mean at $(n+1)/2$, but it *shrinks* its variance — and that shrinkage is the
whole subject of this page.
</details>

---

## 2. The collapse identity: why tied correlations are computable at all

Here is the piece of luck that makes everything exact.

Suppose our tied statistic is scored by midranks, and the response is **finer**:
it never ties two observations the statistic separates, and it orders the
observations inside each tied block somehow. Then the midrank vector $R$ is, by
construction, the average of the response's rank vector $S$ within each block.
In probabilistic language, $R = \mathbb{E}[S \mid \text{block}]$, and the tower
property gives
$$\operatorname{Cov}(R, S) = \operatorname{Var}(R).$$

The cross-term collapses. A correlation — normally a genuinely two-variable
object — becomes a ratio of two variances, both of which are determined by the
block sizes alone.

Play with it. Build a tie profile in the laboratory below and watch
$\operatorname{Cov}(R,S)$ and $\operatorname{Var}(R)$ track each other digit for
digit, while the brute-force correlation and the closed-form value agree to eight
decimals.

{{interactive_demo:1}}

<details>
<summary><b>The formal statement and proof sketch</b></summary>

**Theorem (Midrank collapse).** For a tie profile with blocks of sizes
$m_1,\dots,m_g$ summing to $n$, laid out in block order with midranks $R$ and
raw ranks $S = (1,\dots,n)$, and any centring constant $\mu$,
$$\sum_i (R_i-\mu)(S_i-\mu) \;=\; \sum_i (R_i-\mu)^2 .$$

*Proof.* Work block by block. Block $j$ contributes
$(R_j-\mu)\sum_{i\in j}(S_i-\mu)$. Write $S_i-\mu = (S_i-R_j) + (R_j-\mu)$; the
first part sums to zero over the block, because the midrank $R_j$ is exactly the
mean of the positions in block $j$ (a Gauss sum). What remains is
$m_j(R_j-\mu)^2$, block $j$'s contribution to $\sum_i (R_i-\mu)^2$. $\blacksquare$

**Theorem (Tie decomposition).** With $\mu = (n+1)/2$,
$$\underbrace{\frac{n^3-n}{12}}_{\text{total }V} \;=\; \underbrace{\sum_i (R_i-\mu)^2}_{\text{between blocks}} \;+\; \underbrace{\sum_j \frac{m_j^3-m_j}{12}}_{\text{within blocks } = \,T}.$$

*Proof.* Parallel-axis decomposition inside each block: the ranks in a block of
size $m$, centred at the block midrank, have sum of squares $(m^3-m)/12$. Sum
over blocks. $\blacksquare$
</details>

---

## 3. The tie-attenuation law

Put the two identities together and the correlation falls out in one line:
$$\rho^2 \;=\; \frac{\operatorname{Cov}(R,S)^2}{\operatorname{Var}(R)\operatorname{Var}(S)}
\;=\; \frac{\operatorname{Var}(R)}{\operatorname{Var}(S)} \;=\; \frac{V-T}{V}.$$

> **Tie-Attenuation Law.** For a statistic with tie blocks of sizes
> $m_1,\dots,m_g$ summing to $n \ge 2$, measured by midranks against *any*
> tie-refining response,
> $$\rho^2 \;=\; 1 - \frac{12\sum_j (m_j^3-m_j)}{n^3-n}.$$

Three things to notice.

1. **The response has vanished.** The right-hand side mentions only the block
   sizes. So this is a *ceiling*: no matter how informative the downstream
   variable is, the correlation cannot exceed it — and if the response is
   perfectly informative, it equals it.
2. **The cost of a tie is cubic.** A block of size $m$ costs $(m^3-m)/12$ of the
   total variance $V = (n^3-n)/12$. Doubletons are almost free; a single block
   holding half the sample destroys about an eighth of everything.
3. **Only the third moment matters.** In the large-$n$ limit, with class
   proportions $p_j$, the law reads $\rho^2 \to 1 - \sum_j p_j^3$. Every family
   of tie structures collapses to a one-parameter curve indexed by its **cubic
   mass**.

And the equality case is exactly what you would hope: $\rho = 1$ if and only if
every block has size $1$ — no ties at all.

Here is the law implemented in exact rational arithmetic, alongside the other
three computational primitives we will need.

{{algorithm:0}}

---

## 4. Zero-counts: an exact ceiling, and the death of the obvious hypothesis

Now compute the ceiling for the zero-count. Among the $2^b$ integers below
$2^b$, exactly $2^{b-1-k}$ have precisely $k$ trailing zeros (they are the
numbers $2^k(2u+1)$), plus the lone integer $0$. So the tie profile is geometric:
$$2^{b-1},\ 2^{b-2},\ \dots,\ 2,\ 1,\ 1 .$$

Feeding a geometric profile into a cubic sum gives a geometric series, and it
telescopes beautifully.

> **Dyadic Ceiling.** For uniform $b$-bit draws with $b \ge 1$,
> $$\rho^2 = \frac{6}{7}\left(1 + \frac{1}{2^b(2^b+1)}\right),$$
> strictly decreasing in $b$, with $\rho \downarrow \sqrt{6/7} = 0.9258200\ldots$

<details>
<summary><b>The three-line derivation</b></summary>

With $x = 2^b = n$, the cubic mass is
$\sum_j m_j^3 = \sum_{i=0}^{b-1} 8^i + 1 = \frac{x^3-1}{7} + 1$. Hence
$$\rho^2 = 1 - \frac{\frac{x^3-1}{7} + 1 - x}{x^3-x}
= \frac{6(x^3-1)}{7(x^3-x)}
= \frac{6}{7}\cdot\frac{x^2+x+1}{x^2+x}
= \frac{6}{7}\left(1+\frac{1}{x(x+1)}\right),$$
cancelling the common factor $x-1$. The limit $6/7$ is the signature of a
geometric profile of ratio $1/2$: asymptotically $\rho^2 = 1 - \sum_j p_j^3 =
1 - \sum_{k\ge1} 8^{-k} = 1 - 1/7$.
</details>

Now the punchline. How much can this ceiling move between $b = 44$ and $b = 64$?
The correction term is $\frac{1}{2^b(2^b+1)}$, already below $3\times10^{-27}$ at
$b = 44$. **The ceiling drops by less than $10^{-26}$.** The dial dropped by
$0.188$ in squared units. A gap of twenty-four orders of magnitude.

{{visualization:0}}

Whatever is pushing the dial down, it is not the tie granularity of the
zero-count. Hypothesis one is dead.

---

## 5. Blaming the instrument: truncation, and why that fails too

A good detective checks the alibi. Real instrumentation **truncates**: perhaps
the zero-count is capped at $c$, with every draw having $c$ or more trailing
zeros dumped into a single merged bucket. Merged buckets are huge, and huge
blocks are cubically expensive. Surely a small enough cap explains a low reading?

> **Truncation Ceiling.** Capping the trailing-zero count at $c$, $1 \le c \le b$,
> $$\rho^2(b,c) = \frac{6}{7}\cdot\frac{8^{b} - 8^{\,b-c}}{8^{b} - 2^{b}},$$
> which is increasing in $c$ and **never below $3/4$**.

The recorded reading is $\rho^2 = 0.648^2 = 0.419904$, far below $3/4$. No cap,
at any word length, can produce it. Hypothesis two is dead.

Use the explorer below to see this for yourself: switch to the *Capped
zero-count* tab and drag the cap all the way down to $c = 1$. The ceiling bottoms
out at exactly $\sqrt{3}/2 = 0.866$ and refuses to go lower. Then switch tabs to
watch the same machinery handle the full dyadic profile and the binary response
of the next section.

{{interactive_demo:0}}

<details>
<summary><b>Why the three formulas are mutually consistent</b></summary>

At $c = b$ the truncation formula returns $\frac{6}{7}\frac{8^b-1}{8^b-2^b}$,
which is exactly the dyadic ceiling. At $c = 1$ the capped profile is just the
even/odd split $(2^{b-1}, 2^{b-1})$, and the formula returns
$\frac{3}{4}\cdot\frac{4^b}{4^b-1}$ — precisely the balanced two-class value
$3j^2/(4j^2-1)$ with $j = 2^{b-1}$ from the next section. Three separate
derivations, one consistent picture: a genuine internal check on the algebra.
</details>

---

## 6. If not the statistic, then the response

By elimination, the coarseness must live on the *other* side. So we generalise:
let **both** variables be tied, with the response's blocks refining the
statistic's — nested, like counties inside states.

The collapse identity survives, for a lovely reason: averaging fine midranks
inside a coarse block, weighted by the fine block sizes, returns exactly the
coarse midrank. The tower property does not care how fine the fine partition is,
only that it refines the coarse one.

> **Two-Sided Attenuation Law.** For nested profiles with $n \ge 2$ observations
> and $V = (n^3-n)/12$,
> $$\rho^2 = \frac{V - T_{\mathrm{coarse}}}{V - T_{\mathrm{fine}}}.$$

Setting $T_{\mathrm{fine}} = 0$ recovers the one-sided law. And the coefficient
always lands in $[0,1]$, because $m \mapsto m^3-m$ is superadditive:
$(a^3-a)+(b^3-b) \le (a+b)^3-(a+b)$, so splitting a block never increases the tie
correction. Equality — a perfect $\rho = 1$ — happens exactly when the two
profiles coincide. **What attenuates a rank correlation is the *mismatch* in
granularity between the two variables.**

{{algorithm:1}}

Now specialise ruthlessly. The coarsest interesting response is **binary**.

> **Binary-Response Ceiling.** A two-class response with $j$ positives and $k$
> negatives, against a tie-free statistic, attains exactly
> $$\rho^2 = \frac{3jk}{(j+k)^2-1} \;\longrightarrow\; 3q(1-q), \qquad q = \frac{j}{j+k},$$
> so $\rho \le \sqrt{3}/2 = 0.8660254\ldots$, with the maximum at $q = 1/2$.

This deserves to be much better known: **if your outcome variable is a yes/no,
your rank correlation is capped at $0.866$ before you collect a single data
point** — and at $\sqrt{0.27} = 0.52$ if the classes split $10/90$.

---

## 7. Turning the formula into a measuring device

Now run the logic backwards. Our reading is $\rho = 0.648$, i.e.
$\rho^2 = 0.419904$. Solve $3q(1-q) = 0.419904$:
$$q = \frac{1 - \sqrt{1 - \tfrac{4}{3}(0.419904)}}{2} = 0.16829\ldots$$

A two-class response with $1683$ positives per $10\,000$ reproduces the recorded
value to within $10^{-4}$ in $\rho^2$. And the same formula **excludes**: any
two-class response whose minority class holds at least a quarter of the sample
gives $\rho^2 \ge 9/16 = 0.5625$, far above the reading.

{{visualization:1}}

That converts a soft observation into a sharp, falsifiable prediction:

> If response coarseness explains the decline, then the 64-bit rate variable is
> effectively a two-class variable with minority mass near $17\%$, and the dial
> can never exceed $\sqrt{3}/2$ at any word length.

Go and look at the response distribution. If its minority mass is $40\%$, the
explanation dies on the spot.

---

## 8. Verify everything yourself

The full demonstration suite below checks the closed forms against brute-force
computation on the actual rank vectors, in exact rational arithmetic — no
floating point, no simulation, no tolerance fudging. It reproduces every number
quoted on this page.

{{demo:0}}

And here is a practical tool: an **audit** that takes any reported rank
correlation and a hypothesis about the coarseness of the variables, and reports
the ceiling, the fraction of it actually realised, and whether the hypothesised
structure is outright excluded.

{{demo:1}}

<details>
<summary><b>A footnote on the verdict: what a near-miss really costs</b></summary>

The three seeds all cleared the pre-registered bar of $0.630$ (baseline $0.580$
plus a required improvement of $0.05$), and so did the pooled point estimate
$0.648$. But the protocol also demanded that the *lower confidence limit* clear
the bar, and it read $0.629$: an improvement of $0.049$, missing by one part in a
thousand. Verdict: majority passes, strict criterion fails.

Such near-misses are structurally bounded. If two of three readings clear a bar
$\tau$ and the third is at least the band floor $\ell$, then the pooled mean is at
least
$$\tau - \frac{\tau - \ell}{3}.$$
With $\tau = 0.63$ and $\ell = 0.55$ the pooled value could not have fallen below
$0.6033$ — and in fact read $0.648$. A "majority passes, pooled fails" verdict
lives inside a window of width $(\tau-\ell)/3 \approx 0.027$; it can never signal
gross discordance between seeds, only a fine one.
</details>

---

## 9. What to take away

| structure | limiting $\rho^2$ | limiting $\rho$ |
|---|---|---|
| tie-free | $1$ | $1$ |
| geometric halving (zero-counts) | $6/7$ | $0.925820$ |
| capped zero-count, cap $c$ | $\frac{6}{7}(1-8^{-c})$ | $\ge 0.866$ |
| balanced binary | $3/4$ | $0.866025$ |
| binary, base rate $q$ | $3q(1-q)$ | $\sqrt{3q(1-q)}$ |
| binary, $q = 0.1683$ | $0.419925$ | $0.648$ |

A reading of $0.648$ is *not* a weak association if the response is a
$17\%$-prevalence dichotomy — in that case it is essentially the maximum
attainable. Reporting a rank correlation without its structural ceiling is like
reporting a signal without a noise floor.

The moral is the oldest one in measurement: **before you ask why a number is
small, find out how large it was allowed to be.**

### Where to go next

- **Geometric responses.** Because the ceiling depends on the profile only
  through $\sum_j p_j^3$, every response family should collapse to a
  one-parameter calibration curve indexed by its third frequency moment. For
  geometric class masses with ratio $r$, that curve should be a closed-form
  rational function of $r$ alone.
- **Crossing partitions.** Everything here assumes nesting. When the two block
  structures *cross*, the collapse identity fails and the coefficient stops
  being a function of the two marginal profiles. Sharp bounds in terms of the
  marginals — with the nested case conjecturally extremal — would complete the
  theory.
- **Separating structure from noise.** A reading below its ceiling mixes
  structural attenuation with genuine imperfection of the association. A
  decomposition $\rho_{\text{observed}} = \rho_{\text{ceiling}} \cdot \kappa$
  with an estimable purity coefficient $\kappa \in [0,1]$ would turn ceilings
  into a reporting standard.

### Further reading

- [Spearman's rank correlation coefficient](https://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient)
- [Kendall's tau and tie corrections](https://en.wikipedia.org/wiki/Kendall_rank_correlation_coefficient)
- [2-adic valuation](https://en.wikipedia.org/wiki/P-adic_valuation)
- [Law of total variance (the parallel-axis decomposition used above)](https://en.wikipedia.org/wiki/Law_of_total_variance)
