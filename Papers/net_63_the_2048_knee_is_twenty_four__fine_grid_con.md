# The Retention Knee: a guided tour

*How many keys do you actually have to keep?*

---

## 0. A number on a slide

Somewhere in an engineering document there is a small table: at context length
$512$, keep $16$ keys; at $1024$, keep $20$; at $2048$, keep $24$. Underneath, a
footnote: *"retains $98\%$ of attention mass."* Tables like this decide what runs
on your phone.

This page unpacks that number. By the end you will know exactly what such a table
proves, what it merely predicts, and what it quietly assumes — and you will have
discovered the central dichotomy yourself, by dragging a slider.

Here is the whole vocabulary. An **attention row** is a list of nonnegative
weights $w_0, w_1, w_2, \dots$ summing to $1$: how much one position attends to
each earlier one. Sort it heaviest-first and define

$$M(k) \;=\; \sum_{i<k} w_i \qquad\text{(the mass retained by the top } k \text{ keys)},$$

$$k^*(g) \;=\; \min\{k : M(k) \ge g\} \qquad\text{(the \textbf{retention knee} at gate } g).$$

That is it. Everything below is about the single number $k^*(g)$.

<details>
<summary><strong>Why should attention rows be lopsided at all?</strong> (background)</summary>

Attention weights are produced by a softmax over query–key inner products. A
softmax exponentiates, so modest differences in score become large differences in
weight, and a handful of positions typically dominate. That empirical lopsidedness
is what makes a small key budget viable in the first place; the mathematics below
never assumes it, but it is why the question is interesting. Background on the
mechanism: [attention and the transformer architecture](https://en.wikipedia.org/wiki/Attention_(machine_learning)).
</details>

---

## 1. Play first, theory second

Before any theorem, get the objects into your hands. In the explorer below, pick a
row family, set a gate, and set the spacing of the sweep grid — the set of key
counts an experiment actually tests.

Three things to try, in order:

1. **Geometric decay, spacing 1.** Watch the retention curve cross the gate; the
   crossing point is the knee. Nothing subtle yet.
2. **Now widen the spacing to 8.** The *reported* knee jumps up, but never by a
   full grid step. This is the entire story of "the knee moved when we refined the
   grid."
3. **Switch to spike + plateau and push $m$ up.** Watch the red "floor" marker
   refuse to move while the true knee marches right. Remember that feeling — it is
   the punchline of the last section.

{{interactive_demo:0}}

---

## 2. What a measurement actually proves

Suppose a sweep reports these four numbers at context $2048$, gate $g = 0.98$:

| keys $k$ | 20 | 24 | 28 | 32 |
|---|---|---|---|---|
| retained | $0.9793$ | $0.9835$ | $0.9854$ | $0.9885$ |

The headline is "the knee is $24$." The honest statement is a **bracket**.

> **Bracketing Theorem.** If the weights are nonnegative and $M(a) < g \le M(b)$,
> then $a < k^*(g) \le b$.

Applied here: $20 < k^*(0.98) \le 24$. Nobody measured $21, 22, 23$, and nothing
in the data distinguishes them.

<details>
<summary><strong>Proof (two lines)</strong></summary>

Nonnegative weights make $M$ nondecreasing. If $k^*(g) \le a$ then
$g \le M(k^*(g)) \le M(a)$, contradicting $M(a) < g$; so $a < k^*(g)$. And $b$
passes the gate, so by minimality $k^*(g) \le b$. $\blacksquare$
</details>

The same monotonicity gives the **fail/pass certificate** that a sweep really
produces: if $M(k-1) < g \le M(k)$ then $k^*(g) = k$ exactly. That is the shape of
every honest knee measurement.

---

## 3. The grid is not the row

A sweep never reports $k^*$; it reports the least *tested* value that passes,
$k^*_G(g) = \min\{k \in G : M(k) \ge g\}$. Four facts govern the gap.

- **No under-reporting:** $k^*(g) \le k^*_G(g)$, always.
- **Refinement only lowers the report:** $G \subseteq G' \Rightarrow k^*_{G'}(g) \le k^*_G(g)$.
- **On-grid landing is exact:** if $k^*(g) \in G$, the sweep returns it exactly.
- **Spacing bound:** on an arithmetic grid of spacing $s$ starting at or below the
  knee, $k^*(g) \le k^*_G(g) < k^*(g) + s$.

So a coarse sweep saying $28$ and a fine sweep saying $24$ are *not in conflict*.
No experiment was wrong; the grid was.

<details>
<summary><strong>Proof of the spacing bound</strong></summary>

Pick $j$ with $k^*(g) - a \le sj < (k^*(g)-a) + s$ — ceiling division. Then
$a + sj$ is a grid point at least $k^*(g)$, so it passes the gate by monotonicity,
whence $k^*_G(g) \le a+sj < k^*(g)+s$. The lower bound is no-under-reporting. $\blacksquare$
</details>

A concrete case is worth more than the general statement. The dyadic row
$w_i = 2^{-(i+1)}$ has $M(k) = 1-2^{-k}$, so at gate $0.98$ its true knee is $6$
($M(5) = 0.96875$, $M(6) = 0.984375$). Sweep it on $\{2,4,8,16\}$ and you report
$8$: a $33\%$ over-provision on a noiseless profile. Add the point $6$ and the
truth reappears.

{{visualization:0}}

Here is the procedure that produces a report *with* its bracket, plus the optional
bisection that recovers the exact knee inside it:

{{algorithm:1}}

<details>
<summary><strong>The simpler primitive underneath: the exact knee with its certificate</strong></summary>

{{algorithm:0}}
</details>

---

## 4. Why the deployment chain must climb

The three table entries $16 < 20 < 24$ look like a coincidence. They are forced.
Say a profile $w$ **majorizes** $v$ if $M_v(k) \le M_w(k)$ for every $k$ — that is
the precise sense in which "$v$ is more spread out". Lengthening the context
spreads attention.

> **Majorization Theorem.** If $M_v(k) \le M_w(k)$ for all $k$, then
> $k^*_w(g) \le k^*_v(g)$: the flatter profile needs at least as many keys, at
> every gate.
>
> **Strict version.** If the longer-context profile *still fails* the gate at the
> shorter context's knee, its knee is strictly larger.

Chain that at $512 \to 1024 \to 2048$ and strict monotonicity of the budget chain
follows from one qualitative fact plus the certificates a sweep already produces.
And the chain is realizable: the plateau profile spreading mass $g$ over exactly
$K$ keys is a genuine sorted row with knee exactly $K$, so $16, 20, 24$ are not
vacuous.

<details>
<summary><strong>A bonus for multi-head models</strong></summary>

Retained mass is linear in the profile, so for any blend
$\lambda u + (1-\lambda) v$ of two heads,
$$k^*_{\lambda u + (1-\lambda)v}(g) \;\le\; \max\{k^*_u(g),\,k^*_v(g)\}.$$
Budget for the hardest head and every mixture is covered — per-head budgets
aggregate by a maximum, not a sum. The proof is one line: both $u$ and $v$ pass
the gate at $K = \max\{k^*_u, k^*_v\}$, and a convex combination of two numbers
$\ge g$ is $\ge g$.
</details>

---

## 5. An audit you can run on someone else's table

Now a genuinely negative result, and a satisfying one, because it needs no access
to raw data.

If rows are **sorted**, the retention curve is **discretely concave**: equal-width
blocks of keys contribute less and less as you move right,
$$M(k'+d) - M(k') \;\le\; M(k+d) - M(k) \qquad (k \le k').$$
The reason is immediate — the later block consists of keys each no heavier than
the corresponding earlier ones. And averaging over evaluation windows preserves
concavity, since an average of concave curves is concave.

Now check the reported row. Block $24 \to 28$ adds $0.0019$; the *later* block
$28 \to 32$ adds $0.0031$. The increments go **up**.

> **Obstruction.** Those four numbers cannot be the window-averaged top-$k$ masses
> of sorted attention rows, for any number of windows.

Crucially, this does **not** falsify the knee: the bracket used only monotonicity.
What it kills is *extrapolation* — interpolating a knee at a finer gate, or
projecting one model's budget from another's curve. Run the audit yourself, and
compare with rows that pass it:

{{interactive_demo:1}}

---

## 6. A floor, and its name is entropy

Everything so far certifies that $k$ keys *suffice*. What forces you to keep at
least a certain number? For that you need to know how flat the row is, and the
right notion of flatness is the **attention energy**
$$E(k) \;=\; \sum_{i<k} w_i^2,$$
the collision probability of the distribution — equivalently $2^{-H_2}$ where
$H_2$ is the [Rényi-2 (collision) entropy](https://en.wikipedia.org/wiki/R%C3%A9nyi_entropy).

Cauchy–Schwarz does the rest: $\left(\sum_{i<k}w_i\right)^2 \le k\sum_{i<k}w_i^2$,
so passing the gate with $k$ keys forces $g^2 \le k\,E(k)$, and therefore

$$\boxed{\;k^*(g) \;\ge\; \frac{g^2}{E}\;}$$

whenever the row's energy never exceeds $E$.

<details>
<summary><strong>Read it backwards — this is the interesting direction</strong></summary>

If a sweep *certifies* $k^*(g) \le K$, then monotonicity gives $g \le M(K)$, so
the same inequality yields $E(K) \ge g^2/K$: **a measured knee caps the entropy of
the row.** For the table above — gate $0.98$, knee at most $24$ —
$$E(24) \;\ge\; \frac{0.9604}{24} \;=\; 0.04001\overline{6} \;>\; 0.04,
\qquad\text{i.e.}\qquad H_2 \;<\; \log_2 25 \;\approx\; 4.64 \text{ bits}.$$
This is a falsifiable prediction about data the experiment never reported. A row
flatter than $4.64$ bits of collision entropy cannot have a knee of $24$ at gate
$0.98$.

And the constant is optimal: the plateau spreading mass $0.98$ over exactly $24$
keys has knee exactly $24$ and energy exactly $0.98^2/24$. The floor is attained.
</details>

Pair the floor with a decay hypothesis and the knee is trapped from both sides: if
$E(k) \le E$ and the un-retained tail obeys $1 - M(k) \le Cr^k$, then any $N$ with
$Cr^N \le 1-g$ gives
$$\frac{g^2}{E} \;\le\; k^*(g) \;\le\; N.$$
A free corollary is a consistency test — any reported (gate, energy, tail) triple
must satisfy $g^2/E \le N$, whatever the sweep printed. Here is the whole
procedure, fit included:

{{algorithm:2}}

---

## 7. The dichotomy: when does entropy actually predict the budget?

A lower bound is only useful if it is close. So how lossy is $g^2/E$?

**On exponentially decaying rows, barely lossy at all.** For $w_i = (1-a)a^i$
everything is closed-form: $M(k) = 1-a^k$, so the knee is at most
$1 + \log\frac{1}{1-g}/(1-a)$, and the energy is exactly $E(a) = \frac{1-a}{1+a}$,
so the floor is $g^2(1+a)/(1-a)$. Both blow up like $1/(1-a)$ as the row flattens
— and the blow-ups cancel:

> **Flatness bound.** For every geometric row and every gate,
> $$k^*(g) \;\le\; \frac{1 + \log\frac{1}{1-g}}{g^2}\cdot\frac{g^2}{E(a)}.$$
> The constant depends on the **gate alone** — at $g = 0.98$ it is
> $(1+\log 50)/0.9604 \approx 5.11 < 6$.

So the natural conjecture that the ratio diverges as $a \to 1^-$ is *false*.

<details>
<summary><strong>Proof of the flatness bound</strong></summary>

Write $L = \log\frac1{1-g} \ge 0$. The right-hand side is $(1+L)(1+a)/(1-a)$, so
after multiplying through by $1-a>0$ it suffices that
$(1-a) + L \le (1+L)(1+a) = 1 + a + L + La$, i.e. $-a \le a + La$ — true for
$a \in (0,1)$, $L \ge 0$. Combine with the logarithmic ceiling, which itself
follows from $\log a \le a-1$: taking $N = \lceil L/(1-a)\rceil$ gives
$N(-\log a) \ge N(1-a) \ge L$, hence $a^N \le 1-g$. $\blacksquare$
</details>

**On rows with a spike over a long shelf, arbitrarily lossy.** Take one key of
weight $\tfrac12$, then $2m$ keys of weight $\tfrac1{4m}$ — a perfectly honest
sorted probability row. At gate $\tfrac34$:

- the knee is exactly $m+1$ (retention is $\tfrac12 + \tfrac{k-1}{4m}$ on the shelf);
- the energy is pinned in $\left[\tfrac14,\ \tfrac14 + \tfrac1{8m}\right]$, because
  the spike alone contributes $\tfrac14$ — so $H_2$ never exceeds $2$ bits, however
  long the shelf;
- hence the floor never exceeds $(3/4)^2/(1/4) = 9/4$ keys.

Let $m \to \infty$ and the ratio (truth)/(floor) diverges at a *fixed* gate.

> **Tightness dichotomy.** Bounded knee-to-floor ratio on the whole geometric
> family; unbounded on the spike-plus-plateau family, at the same gate.
> **Exponential decay, not sortedness, is what makes the entropy floor
> informative.**

{{visualization:1}}

Go back to the explorer in §1 and re-run experiment 3 with this in mind: the red
floor marker sticking while the knee walks away is exactly the unbounded-loss
theorem happening in front of you.

---

## 8. Run every number yourself

Everything above — the bracket, the grid guarantees, the realized chain, the
concavity audit, the entropy prediction and its sharpness, both halves of the
dichotomy, the sandwich and the consistency test — is reproduced here, with a
runtime assertion behind every printed claim:

{{demo:0}}

---

## 9. What the number means now

The table entry "$24$ keys at context $2048$" has become four separate things:

- an **honest bracket** $20 < k^* \le 24$, whose width is the grid spacing and no
  smaller;
- a **forced chain** $16 < 20 < 24$, because longer contexts spread mass and each
  still failed at the previous budget;
- a **prediction** that the underlying rows carry collision entropy below
  $\log_2 25 \approx 4.64$ bits — testable, and not yet tested;
- a **warning** that those four numbers cannot come from window-averaged sorted
  rows, so no concave extrapolation from them is licensed.

And the durable lesson is the dichotomy. It is tempting to summarize an attention
row by one scalar and read the memory budget off it. On exponentially decaying
rows that works, to within a factor of about five at a $98\%$ gate. On a row with
one spike and a long shelf it fails by an unbounded factor. Entropy bounds the
budget from below, decay bounds it from above, and neither alone is the answer.
