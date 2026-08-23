# How much of the past does a model actually need?

> **The one-sentence version.** The number of attention keys you must keep is a
> *multiplicative* quantity — it scales with how many tokens a language spends on
> the words the model needs — so measuring it with an evenly-spaced ruler is a
> category error, and one day a French text walks right off the end of the ruler.

This page is a guided tour. You will meet the objects, break an experiment, fix
the instrument, and end up with two independent derivations of the same law. Every
widget is live: change a slider and the mathematics changes with it.

---

## 1. Three definitions, and that is the whole vocabulary

A transformer reading a long document spreads its attention over the tokens behind
it. Sort those attention weights from heaviest to lightest and you get an
**attention profile**
$$p(0) \ \ge\ p(1) \ \ge\ p(2) \ \ge\ \cdots \ \ge\ 0 .$$

Keep only the $k$ heaviest keys and you retain the **prefix mass**
$$M_p(k) \;=\; \sum_{i<k} p(i).$$

Fix a **bar** $\tau$ — say, "I want $97\%$ of the attention mass" — and the
smallest budget that clears it is the **knee**
$$K_p(\tau) \;=\; \min\{\,k \;:\; \tau \le M_p(k)\,\}.$$

That is it. Every theorem below is a statement about these three objects, and
nothing else is needed.

<details>
<summary>Why the knee is the number that matters in practice</summary>

The key–value cache of an autoregressive attention model grows linearly with
context length and lives in the scarcest memory on the accelerator. Top-$k$
retention discards all but the $k$ heaviest keys per step. Choosing $k$ below the
knee degrades the model's behaviour; choosing it far above the knee wastes memory
that could hold a longer context or a larger batch. Locating the knee *is* the
provisioning problem. Background on the cost structure it lives in:
[attention](https://en.wikipedia.org/wiki/Attention_(machine_learning)) and
[transformer architecture](https://en.wikipedia.org/wiki/Transformer_(deep_learning_architecture)).
</details>

---

## 2. Play with it first

Before any theorems: get a feel for the object. Pick a shape, set the bar, and
then turn the dilution dial $r$ — which splits every word into $r$ equal tokens,
exactly what a tokenizer does to a language it was not optimized for. Watch three
things: the knee, the arithmetic probe grid (orange), and the geometric one (green).

{{interactive_demo:0}}

Two experiments worth running before you read on:

1. **Break the grid.** Choose *Flat*, set $n = 60$, $\tau = 0.9$, then raise $r$.
   Somewhere around $r = 2$ the arithmetic grid $\{8,16,24,32\}$ stops being able
   to say anything except "knee $> 32$". The geometric grid never stops working.
2. **Race the two predictors.** Notice that the purple dashed line — a bound
   computed only from how *flat* the attention is, with no knowledge of the
   tokenizer — moves right in exact lockstep with the knee as you raise $r$.

---

## 3. The honest reading of a failed sweep

Here is the measurement that started this. A sweep on French prose:

| context | best grid point | retained mass | verdict |
|---|---|---|---|
| $512$ | $24$ | $0.9648$ | bar not met |
| $1024$ | $32$ | $0.9680$ | bar not met |

and meanwhile French was *easier* for the model than English prose (full-context
accuracy $0.584/0.591$ versus $0.446/0.461$). Easier to predict, more expensive to
remember.

**Theorem (Grid lower bound).** *If a probe at budget $g$ misses the bar, then
$K_p(\tau) > g$. If every point of a finite grid misses, the knee exceeds the
largest grid point.*

<details>
<summary>Click to reveal the one-line proof</summary>

Suppose $K_p(\tau) \le g$. The knee meets the bar, so $\tau \le M_p(K_p(\tau))$.
Retention is nondecreasing (the weights are nonnegative), so
$M_p(K_p(\tau)) \le M_p(g) < \tau$. Chaining: $\tau < \tau$. Contradiction. $\blacksquare$
</details>

So the measurement licenses exactly "$K \ge 33$" at context $1024$. Tempting to
add: *and probably not much more, since $0.9680$ was so close*. That temptation is
provably unfounded.

**Theorem (Grid underdetermination).** *Fix a grid ceiling $g$ and bar $\tau = g+1$.
For every target $N > g$ there is a nonnegative nonincreasing profile whose
retained mass equals $k$ at every budget $k \le g$ — identical readings at every
probe, all below the bar — and whose knee is exactly $N$.*

<details>
<summary>Click to reveal the construction</summary>

Take the two-level staircase: height $1$ on keys $0,\dots,g-1$, then height
$c = 1/(N-g)$ on keys $g,\dots,N-1$, then zero. It is nonnegative and
nonincreasing since $0 < c \le 1$.

* For $k \le g$: $M(k) = k < g+1$. Identical to the reference profile at every probe.
* For $g \le j < N$: $M(j) = g + (j-g)/(N-g) < g+1$. Still below.
* At $k = N$: $M(N) = g + c(N-g) = g+1$. Exactly the bar.

So the knee is $N$, and $N$ was arbitrary. $\blacksquare$
</details>

The left panel below draws this family: six curves lying exactly on top of one
another throughout the sweep region, with knees from $9$ to $60$. The right panel
shows the consequence for instrument design.

{{visualization:0}}

<details>
<summary>An even sharper version: the gap ambiguity</summary>

For any consecutive probes $a < b$ there are two profiles agreeing at every budget
$k \le a$ *and* at every budget $k \ge b$ — indistinguishable to any grid that
skips the open interval $(a,b)$ — with knees $a+1$ and $b$. A grid can therefore
never certify a bracket tighter than the **ratio** $b/(a+1)$ of its consecutive
probes. Ratio, not difference, is the natural resolution parameter of a sweep.
That is the first hint that the whole problem is multiplicative.
</details>

---

## 4. The domain tax is multiplicative

Why did French escape? The mechanistic guess is about *spelling*, not meaning:
tokenizers trained mostly on English chop French into more pieces, so the mass
that used to sit on one key gets spread across several.

Formalize it. For $r \ge 1$, the **$r$-fold dilution** is
$$(D_r p)(j) \;=\; \frac{p(\lfloor j/r\rfloor)}{r}:$$
each semantic unit is spelt with $r$ tokens, each carrying an equal share. Total
mass is unchanged; the shape stays nonincreasing.

**Theorem (Dilution law).** *If the undiluted knee is $K > 0$, then*
$$r(K-1) \;<\; K_{D_rp}(\tau) \;\le\; rK,$$
*and both ends are attained, so the sandwich cannot be tightened.*

<details>
<summary>Click to reveal the proof</summary>

The crucial lemma is *mass preservation on whole words*: $M_{D_rp}(rm) = M_p(m)$,
because the block $[rm, rm+r)$ consists of $r$ copies of $p(m)/r$, summing to $p(m)$.

*Upper bound.* $M_{D_rp}(rK) = M_p(K) \ge \tau$, so a budget of $rK$ tokens clears
the bar and the knee is at most $rK$.

*Lower bound.* $M_{D_rp}(r(K-1)) = M_p(K-1) < \tau$ by minimality of $K$. That is a
failed probe at budget $r(K-1)$, so by the Grid Lower Bound Theorem the diluted
knee is strictly greater.

*Sharpness.* The $r$-fold dilution of the flat profile on $n$ keys is the flat
profile of height $1/r$ on $rn$ keys, whose knee at bar $\tau$ is $\lceil r\tau\rceil$;
choosing $\tau$ integral attains the top, choosing it just above $K-1$ attains
$r(K-1)+1$. $\blacksquare$
</details>

And now the corollary that kills the pre-registered hypothesis:

**Theorem (No additive domain-shift law).** *For every claimed offset $d$ there
exist a profile, a bar and a ratio $r$ with $K_p(\tau) + d < K_{D_rp}(\tau)$.*

<details>
<summary>Click to reveal the counterexample</summary>

Take the flat profile on $d+2$ keys with bar $d+2$, so $K = d+2$, and dilute by
$r = d+2$. The diluted knee is $(d+2)^2$, and $(d+2)^2 > (d+2) + d$ for every
$d \ge 0$. A multiplicative law admits no uniform additive bracket. $\blacksquare$
</details>

Dilutions also compose: splitting into $s$ tokens and then each of those into $r$
is exactly an $rs$-fold split, $D_r \circ D_s = D_{rs}$. Successive domain shifts
**multiply**. Additive bookkeeping was the wrong arithmetic from the first line.

{{visualization:1}}

---

## 5. Real tokenizers are not uniform — and that makes the law sharper

Let word $i$ cost $w(i) \ge 1$ tokens and write $C_w(m) = w(0) + \cdots + w(m-1)$.

**Theorem (Variable dilution law).** *If the undiluted knee is $K$, then*
$$C_w(K-1) \;<\; K_{\text{diluted}}(\tau) \;\le\; C_w(K).$$

In words: **the diluted knee is the number of tokens the tokenizer spends on
precisely the words the model actually attends to** — a bracket of width one word.

This is the falsifiable core of the whole mechanism story, and it makes a specific
prediction that a naive reading would miss. The correct predictor is
$C_w(K)/K$ — the tokens-per-word average *restricted to the top-$K$ attended
words* — not the corpus average. Those two diverge exactly when attention sits on
words of atypical token cost.

Test it yourself. Edit the per-word token costs and watch the two predictors race:

{{interactive_demo:1}}

Try the "rare-word-heavy" preset: the corpus average under-predicts the knee by a
third, while the top-$K$ bracket is exact. This is the shape of the French
hypothesis — accented and elided high-frequency function words are both heavily
attended and expensive to spell.

{{algorithm:1}}

<details>
<summary>The extreme-ratio corollary, and why languages sit grid-ranges apart</summary>

If every word costs between $L$ and $R$ tokens, then $L(K-1) < K_{\text{diluted}} \le RK$.
So a language whose cost band lies strictly above another's has a strictly larger
knee as soon as $L(K-1) \ge R'K'$ — the knees are then separated by a *range* of
budgets, not by a fine step. This is the precise content of "language families
differ by whole grid ranges."
</details>

---

## 6. A second road to the same exponent — with no tokenizer at all

Everything so far needed a tokenizer. Here is an independent route that needs
only the attention numbers.

Define the **collision mass** (the Rényi-2 mass)
$$C_p(k) \;=\; \sum_{i<k} p(i)^2 .$$
Small collision mass means flat, [high-entropy](https://en.wikipedia.org/wiki/R%C3%A9nyi_entropy)
attention; large means peaked. Its reciprocal is the *effective support size* of
the distribution.

**Theorem (Entropy bound on the knee).** *If $C_p(k) \le C$ for all $k$ and
$\tau > 0$ is attainable, then*
$$K_p(\tau) \;\ge\; \frac{\tau^2}{C}.$$

<details>
<summary>Click to reveal the proof (two inequalities)</summary>

By [Cauchy–Schwarz](https://en.wikipedia.org/wiki/Cauchy%E2%80%93Schwarz_inequality)
applied to the all-ones vector and $p$ on the first $k$ coordinates,
$$M_p(k)^2 = \Bigl(\sum_{i<k} 1 \cdot p(i)\Bigr)^2 \le k \sum_{i<k} p(i)^2 = k\,C_p(k).$$
At the knee $K$ we have $\tau \le M_p(K)$, hence
$\tau^2 \le M_p(K)^2 \le K\,C_p(K) \le K\,C$, i.e. $K \ge \tau^2/C$. $\blacksquare$
</details>

**Theorem (Sharpness).** *For the flat probability profile on $n$ keys, the
collision mass is $1/n$, the knee at bar $\tau = 1$ is exactly $n$, and the bound
gives $\tau^2/C = n$.* Equality — so **no** function of the collision mass beats
$\tau^2/C$.

And the punchline. Dilution divides collision mass exactly:
$$C_{D_rp}(rm) = \frac{C_p(m)}{r} \qquad\Longrightarrow\qquad K_{D_rp}(\tau) \ \ge\ r\cdot\frac{\tau^2}{C}.$$

<details>
<summary>Why the division is exact</summary>

Each weight $p(i)$ becomes $r$ weights of size $p(i)/r$, so its contribution to the
collision mass goes from $p(i)^2$ to $r \cdot (p(i)/r)^2 = p(i)^2/r$. Summing over
words gives $C/r$; a short argument extends the bound from whole-word budgets to
all budgets by monotonicity. Feeding $C/r$ into the entropy bound turns
$\tau^2/(C/r)$ into $r\,\tau^2/C$. $\blacksquare$
</details>

The same factor $r$ — from a combinatorial argument about splitting blocks, and
from an analytic argument about second moments, sharing no step beyond the
definition of the knee. That is the strongest evidence in the whole development
that the multiplicative law describes the phenomenon rather than fitting it.

{{algorithm:2}}

---

## 7. Fixing the instrument

**Theorem (Geometric grids bracket the knee).** *Let $S$ be the least exponent with
$M_p(2^S) \ge \tau$. Then $K_p(\tau) \le 2^S$, and if $S > 0$ then $2^S < 2K_p(\tau)$.*

A geometric sweep always returns a **two-sided** bracket of ratio $2$, in about
$\log_2 K$ probes. A multiplicative tax of factor $r$ merely shifts $S$ by
$\log_2 r$: it translates along the instrument instead of escaping it. The
arithmetic grid, by contrast, provably supplies no upper bound once escaped.

<details>
<summary>Click to reveal the proof</summary>

$K \le 2^S$ because $2^S$ is a witness clearing the bar. For the other side,
minimality of $S$ means $M_p(2^{S-1}) < \tau$, a failed probe, so by the Grid Lower
Bound Theorem $2^{S-1} < K$; doubling gives $2^S < 2K$. $\blacksquare$
</details>

Six geometric probes reach budget $64$. Four arithmetic probes reached $32$ and
returned a fact with no upper bound attached. Cheaper *and* strictly more
informative — a rare trade, and the concrete design correction implied by the
failed measurement.

{{algorithm:0}}

<details>
<summary>One more provisioning rule: mixed multilingual traffic</summary>

Retention is affine under mixing, so the knee of $s\,p + (1-s)\,q$ satisfies
$$\min(K_p, K_q) \;\le\; K_{\text{mix}} \;\le\; \max(K_p, K_q).$$
Since the dilution law forbids interpolating budgets *between* domains, this
sandwich is the honest replacement for the interpolation instinct: **budget by the
maximum, never by a traffic-weighted average.**
</details>

---

## 8. And accuracy tells you nothing

A last, slightly uncomfortable result. It is natural to assume harder domains need
more memory. The measurements say otherwise in *both* directions — code is easier
and cheaper, French is easier and dearer — and this is not an accident of the data.

**Theorem (Accuracy/knee decoupling).** *There are four profiles taking only two
distinct accuracy values such that in one pair the higher accuracy comes with the
larger knee and in the other with the smaller.*

<details>
<summary>Click to reveal the four cells</summary>

Let $A$ be the flat profile of height $1$ on four keys (knee $1$ at bar $\tau = 1$)
and $B$ the flat profile of height $1/2$ on four keys (knee $2$). Set
$D_1 = (\text{acc } 0, A)$, $D_2 = (\text{acc } 1, B)$, $D_3 = (\text{acc } 0, B)$,
$D_4 = (\text{acc } 1, A)$. Then $K_{D_1} = 1 < 2 = K_{D_2}$ (accuracy up, knee up)
and $K_{D_4} = 1 < 2 = K_{D_3}$ (accuracy up, knee down). $\blacksquare$
</details>

So **no** function — monotone or otherwise — carries full-context accuracy to the
memory knee. They measure different things: accuracy measures how predictable the
text is, the knee measures how concentrated the attention is. A serving system
that budgets memory from a quality metric is budgeting from an unrelated statistic.

---

## 9. Run the whole thing

Every theorem above is checked numerically here, with exact rational arithmetic so
nothing hides behind floating point. Each section asserts the inequality it
illustrates.

{{demo:0}}

---

## 10. What to take away

- A failed sweep certifies a **lower bound and nothing else** — the excess is not
  merely unmeasured, it is unmeasurable by that instrument.
- The domain tax is **multiplicative**: $r(K-1) < K_{\text{dil}} \le rK$, sharp at
  both ends, and no additive fine-step rule can survive it.
- The exact predictor is the **cumulative token count over the top-$K$ attended
  words**, not the corpus average.
- Flatness alone forces $K \ge \tau^2/C$, a **tokenizer-free** and sharp bound that
  scales by the same factor $r$ — two independent derivations of one exponent.
- **Sweep geometrically**, provision mixed traffic by the maximum, and never infer
  a memory budget from an accuracy number.

The four-domain table that suggested a $\pm 4$ fine-step was not wrong about its
four domains. It fitted an additive form to samples of a multiplicative law, in a
regime where all the ratios happened to be near $1$. Add a fifth domain whose
ratio is not near $1$, and the fit does not degrade gracefully — it fails past
every bracket at once. When a small table suggests a law, ask what *shape* of law
it is before extending it.
