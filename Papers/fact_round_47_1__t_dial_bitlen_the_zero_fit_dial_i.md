# Why a Dial Can Be Blind to the Size of Its Numbers

*A guided tour of tie geometry, Möbius rigidity, and one measurement that could not have come out any other way.*

---

## 1. The question, in one paragraph

You build a statistic. You compute how well it ranks things — a number like $\rho = 0.72$ — on $48$-bit integers. Then someone asks the only question that matters for deployment: **would it still read $0.72$ on bigger numbers?** Measure at $52$ bits and you get $0.7161$. Is that decay, or is that noise? Two data points cannot tell you. This page shows how the *shape* of the underlying formula answers the question outright, and to an accuracy of forty decimal places.

Here is the punchline before the build-up, so you know where we are going:

> Every accuracy ceiling attached to this dial is of the form
> $$\frac{X g + h}{X - 1}, \qquad X = 8^{\,b},$$
> where $b$ is the bit length, $g \in [0,1]$ knows nothing about $b$, and $|h| \le 1$. So every ceiling sits within $3/X$ of a bit-length-free number, and the bit length acts on the whole theory through the single Möbius factor $1 + \frac{1}{X-1}$.

---

## 2. First idea: ties are a ceiling

A rank correlation compares two orderings. But arithmetic statistics rarely *give* an ordering — they give a **grading into big tied groups**. If $T(n)$ is the $2$-adic valuation of $n$ (how many times $2$ divides $n$), then below $2^b$ half the sample shares $T = 0$, a quarter shares $T = 1$, an eighth shares $T = 2$, and so on.

Tied observations get the **mid-rank**: everyone in a tied group takes the average of the ranks the group occupies. That flattening costs spread, and correlation is bounded by spread. Concretely, if the tie blocks have sizes $m_1, \dots, m_r$ in a sample of size $n$, then for *any* companion variable whatsoever,

$$\rho^2 \;\le\; \mathcal{C}(P) \;=\; 1 - \frac{\sum_i (m_i^3 - m_i)}{n^3 - n}.$$

The single most important consequence: **ties cost cubically.** One block of size $1000$ hurts a thousand times more than a thousand blocks of size $10$.

Play with that. Merge blocks and watch the ceiling fall — then try the presets to see the exact profiles used later in this page.

{{interactive_demo:1}}

<details>
<summary><strong>Where the formula comes from (click to expand)</strong></summary>

Give each tied group of size $m$, occupying rank positions $j+1,\dots,j+m$, the common mid-rank $j + \frac{m+1}{2}$. The variance of the resulting vector, scaled by $12n$, is exactly
$$V(P) = (n^3 - n) - \sum_i (m_i^3 - m_i),$$
because a full untied ranking of $n$ items contributes $n^3 - n$ and each tied group replaces its own internal spread — worth $m^3 - m$ — by zero. Any correlation is bounded by the ratio of standard deviations, and the best possible companion is one that is increasing in the mid-ranks with maximal spread. Squaring the ratio of standard deviations gives the variance ratio $V(P)/(n^3-n)$. $\blacksquare$

A useful corollary, used repeatedly: **merging is monotone.** Since $(a+b)^3 - (a+b) \ge (a^3-a)+(b^3-b)$ for $a,b\ge 0$, coarsening a response can only lower its ceiling.
</details>

---

## 3. Second idea: the dyadic staircase and the number $6/7$

The $2$-adic valuation on $\{0,\dots,2^b-1\}$ produces the tie profile
$$A_b = (2^{b-1},\,2^{b-2},\,\dots,\,2,\,1,\,1),$$
a geometric staircase plus a lone singleton for $0$. Cubing a geometric series gives another geometric series, and everything collapses:

$$\mathcal{C}(A_b) \;=\; \frac{6}{7}\left(1 + \frac{1}{x(x+1)}\right), \qquad x = 2^b.$$

Look at the anatomy of that formula. A **constant** $6/7 \approx 0.857143$ that knows nothing about the bit length, plus a **correction** $1/(x(x+1))$ that is the only place $b$ appears — and which is already below $10^{-4}$ at eight bits and below $10^{-28}$ at forty-seven.

The reason is *self-similarity*: $A_{b+1}$ is $A_b$ with one more step glued on top. Adding a bit reproduces the structure instead of deforming it.

<details>
<summary><strong>The three-line derivation</strong></summary>

The cubes of the block sizes are $8^{b-1} + \cdots + 8 + 1 + 1 = \frac{x^3-1}{7} + 1$, and the block sizes themselves sum to $x$. Hence
$$V(A_b) = x^3 - x - \left(\frac{x^3-1}{7} + 1 - x\right) = \frac{6}{7}\,(x^3-1).$$
Divide by $x^3 - x = x(x-1)(x+1)$ and cancel the factor $x-1$ against $x^3-1 = (x-1)(x^2+x+1)$:
$$\mathcal{C}(A_b) = \frac{6}{7}\cdot\frac{x^2+x+1}{x(x+1)} = \frac{6}{7}\left(1+\frac{1}{x(x+1)}\right). \qquad \blacksquare$$
</details>

Related background reading: [Spearman's rank correlation coefficient](https://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient) and the [p-adic valuation](https://en.wikipedia.org/wiki/P-adic_valuation).

---

## 4. Third idea: three blindfolds

Nobody deploys the ideal statistic; they deploy something coarser. Three coarsenings bracket the realistic cases. Fix a depth $t$ and write $p = 2^{-t}$ for the *relation rate*, the fraction of the scale treated as "the tip".

| blindfold | what it can still see | ceiling | bit-length-free limit $g$ |
|---|---|---|---|
| **coarse** (bare count) | one output bit: above threshold or not | $\frac{7}{2}p(1-p)\frac{X}{X-1}$ | $\frac{7}{2}p(1-p)$ |
| **tip-blind** | the bulk perfectly, the top $p$ not at all | $\frac{X(1-p^3)}{X-1}$ | $1-p^3$ |
| **bulk-blind** | the tip perfectly, the bottom $1-p$ not at all | $\frac{X(\frac{7}{2}p(1-p)+p^3)-1}{X-1}$ | $\frac{7}{2}p(1-p)+p^3$ |

Two things are worth noticing immediately. **Blinding the tip is cheap** ($1 - p^3 = 0.998$ at $t=3$): the tip is small and ties cost cubically. **A single output bit is expensive**: the parabola $\frac{7}{2}p(1-p)$ peaks at $7/8$ and collapses as the split becomes lopsided.

<details>
<summary><strong>Why a parabola? The cubic identity behind the coarse ceiling</strong></summary>

Splitting the sample into a bottom part of size $x(1-p)$ and a top part of size $xp$ leaves
$$V = x^3\bigl(1 - (1-p)^3 - p^3\bigr),$$
and for $a + b = 1$ one has $1 - a^3 - b^3 = 3ab$. So $V = 3p(1-p)X$. Dividing by $V(A_b) = \frac67(X-1)$ converts the $3$ into $\frac72$ and produces the Möbius factor. The same identity, applied to the bulk-blind merge, gives $\frac{7}{6}\bigl(1-(1-p)^3-\frac{p^3}{7}\bigr) = \frac{7}{2}p(1-p) + p^3$ — the coarse parabola plus the residual tip resolution.
</details>

Here is the algorithm that evaluates all of this, and — importantly — audits each closed form against the explicitly merged profile, so you can see the two agree exactly rather than approximately:

{{algorithm:1}}

---

## 5. The main event: rigidity

Now put the three ceilings side by side and notice they are the *same shape*:

$$\frac{Xg+h}{X-1}, \qquad g \in [0,1],\quad |h|\le 1,\quad X = 8^b.$$

**Theorem (affine-shape bound).** For $X \ge 8$, $g\in[0,1]$, $|h|\le1$:
$$\left|\frac{Xg+h}{X-1} - g\right| \;\le\; \frac{3}{X}.$$

<details>
<summary><strong>Proof (it really is two lines)</strong></summary>

$$\frac{Xg+h}{X-1} - g = \frac{Xg + h - g(X-1)}{X-1} = \frac{g+h}{X-1},$$
and $|g+h| \le 2$. Finally $\frac{2}{X-1} \le \frac{3}{X}$ is equivalent to $2X \le 3X - 3$, i.e. $X \ge 3$. $\blacksquare$

The content is not the difficulty — it is the *scope*. Every ceiling in the ladder, at every depth, is covered by one inequality.
</details>

Consequence: two bit lengths $b$ and $c$ give ceilings differing by at most $3\cdot8^{-b} + 3\cdot 8^{-c}$. At the measured pair — $48$ and $52$ bits, i.e. $b = 47$ and $b = 51$ valuation classes — that is

$$3\cdot 8^{-47} + 3\cdot 8^{-51} \approx 1.08\times10^{-42} \;<\; 10^{-40}.$$

**Drive it yourself.** Slide the bit length and the depth; watch the "ceiling at $b$" column refuse to move away from the bit-length-free column, and watch the certified budget shrink geometrically. Then push the modulus slider — that one *does* move things, and section 8 explains why.

{{interactive_demo:0}}

And here is the same story as a picture: the finite-bit-length ceilings sitting exactly on top of their limits (left), and the gap decaying like $8^{-b}$ against the certified bound (right).

{{visualization:0}}

---

## 6. Confronting the measurement

Six cells: two bit lengths crossed with three independent seeds, each reporting the dial's rank correlation and, as a control, a bare quadratic-residue count.

| bit length | dial $\rho$ | bare count $\rho$ | advantage |
|---|---|---|---|
| 48 | 0.7192 / 0.7202 / 0.7198 | 0.5990 / 0.6005 / 0.5997 | $+0.1202$ / $+0.1197$ / $+0.1201$ |
| 52 | 0.7154 / 0.7169 / 0.7161 | 0.5760 / 0.5768 / 0.5756 | $+0.1394$ / $+0.1401$ / $+0.1405$ |

All six inside the band $[0.60,0.85]$; mean advantages exactly $+0.12$ and $+0.14$; mean drift $0.719733 \to 0.716133$, i.e. $0.0036$.

That drift is **more than $10^{37}$ times** the entire geometric budget of the ladder. Whatever produced it, it was not the tie structure — it is sampling noise, consistent with the $0.0015$ scatter already visible between seeds at a fixed bit length.

The certification routine below states this as a computation you can run: it returns the worst gap over all depths and all blindfolds together with the closed-form certificate, in $O(1)$ work. It *replaces* the bit-length scan rather than performing one.

{{algorithm:2}}

<details>
<summary><strong>Two failure modes, both closed off</strong></summary>

**No cliff.** The top of the band, $0.85$, squares to $0.7225$, below $6/7 \approx 0.857$; and the dyadic ceiling exceeds $6/7$ at every bit length. So every value in the band is attainable at every size — a collapse cannot come from the tie geometry.

**No slow death.** Take the measured drop at face value as signal, slope $-0.0009$ per bit, and extrapolate: $0.7053$ at $64$ bits, $0.6765$ at $96$, $0.6477$ at $128$, $0.6189$ at $160$. Still in band, more than three times past the measured range.
</details>

---

## 7. Why the dial beats a bare count, at every size

The experiment's relation rate is $p = 1/8$. The bit-length-free coarse ceiling is then
$$\frac{7}{2}\cdot\frac18\cdot\frac78 = \frac{49}{128} = 0.3828125,$$
so for any $b \ge 6$ **every** single-bit response is capped at $\rho^2 < 0.3829$, i.e. $\rho < 0.6188$. Every recorded dial cell has $\rho^2 > 0.511$; every recorded bare-count cell has $\rho^2 < 0.361$. The cap sits cleanly between the two classes, uniformly in the bit length: the advantage is structural, not a calibration accident.

---

## 8. The control experiment: an axis that *does* move

A rigidity theorem is only meaningful if something nearby fails to be rigid. Replace $2$ by a general modulus $\ell$: grade $\{0,\dots,\ell^b-1\}$ by the $\ell$-adic valuation, giving blocks $(\ell-1)\ell^{\,b-1-k}$ plus the singleton $\{0\}$. The same computation yields

$$\mathcal{C}\bigl(A_b^{(\ell)}\bigr) \;=\; \frac{3\ell}{\ell^2+\ell+1}\left(1+\frac{1}{x(x+1)}\right), \qquad x = \ell^b,$$

which at $\ell = 2$ is exactly the $6/7$ formula. But the prefactor **decreases** in $\ell$:
$$\tfrac67 = 0.857 \;\to\; \tfrac9{13} = 0.692 \;\to\; \tfrac47 = 0.571 \;\to\; \tfrac{15}{31} = 0.484 \;\to\; \cdots \to 0.$$

<details>
<summary><strong>Why finer grading <em>hurts</em> — the refuted conjecture</strong></summary>

The natural guess is that more valuation classes resolve more, so the ceiling should rise. It falls. The reason: the class $v = 0$ holds a fraction $(\ell-1)/\ell$ of the sample — at $\ell = 11$ that is over $90\%$ of everything, in one block. Since ties cost cubically, that single monstrous block overwhelms the benefit of the extra classes.

Formally, for $2 \le \ell < m$, the inequality $\frac{3m}{m^2+m+1} < \frac{3\ell}{\ell^2+\ell+1}$ cross-multiplies to $0 < (m-\ell)(\ell m - 1)$, which is immediate. $\blacksquare$
</details>

This turns an empirical number into an arithmetic constraint. The recorded $0.7192$ means $\rho^2 = 0.5172$; at any modulus $\ell \ge 5$ the *entire* ceiling is below $1/2$, at every bit length. So **the measurement excludes every sampling modulus $\ell \ge 5$**, and the exclusion is sharp: $\ell = 2, 3, 4$ all clear it.

{{visualization:1}}

The contrast is the point: bit length $48 \to 52$ moves the ceiling by less than $10^{-40}$; modulus $2 \to 3$ moves it by $\frac{15}{91} > 0.16$. One axis is a nuisance parameter, the other is real physics.

---

## 9. Run the numbers yourself

Everything above, in exact rational arithmetic — the tie ceilings, the ladder, the $10^{-42}$ budget, the six cells, the extrapolation, the modulus exclusion:

{{demo:0}}

And an independent check that does not trust a single closed form: brute-force the valuation classes, build the mid-rank vector, compute the Spearman correlation directly, and compare. The columns agree to floating point — which also shows the ceilings are *attained*, not merely upper bounds.

{{demo:1}}

<details>
<summary><strong>The primitive underneath everything (click to see the core algorithm)</strong></summary>

{{algorithm:0}}
</details>

---

## 10. What to take away

1. **Ties are geometry, not nuisance.** The tie profile of a statistic determines a hard ceiling on every correlation it can ever achieve, and the cubic cost means the ceiling is dominated by the largest block.
2. **Ask for the shape, not the scan.** Once you know the dependence has the form $1 + \frac{1}{X-1}$ with $X$ growing like $8^b$, no amount of further scanning is informative. The dependence is not merely small — it is geometrically small, and already negligible at sizes far below the ones anyone would use.
3. **Rigidity is a fixed-point property of the profile.** The dyadic staircase satisfies $A_{b+1} = (2^b) \frown A_b$: adding a bit prepends a step rather than reshaping the profile. Statistics whose ties are self-similar in this way inherit the rigidity. Statistics whose ties are not — the number of representations as a sum of two squares, Pythagorean leg counts, the divisor function — should show a genuine $1/b$ decline instead, and that is the natural next theorem to prove.
