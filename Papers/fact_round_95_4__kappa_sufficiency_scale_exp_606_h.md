# How Many, or Which?
### A guided tour of composition order, sufficiency, and the boundary where counting stops being enough

---

## 0. The question in one paragraph

Pick a large integer $v$. Ask a cheap question: *which* of the primes $2, 3, 5, 7, 11, \dots$
on a fixed short list $B$ divide it? The answer is a set — call it the **cell** of $v$ — and
its size
$$\kappa(v) \;=\; \#\{p \in B : p \mid v\}$$
is the **composition order**. Now ask an expensive question: is $v$ *smooth*, meaning all of
its prime factors are small? Smooth numbers are the fuel of sieve factoring and index
calculus, so their rate of appearance is worth predicting.

The empirical finding that starts this story is that the cheap statistic predicts the
expensive property, cleanly:
$$\log(\text{smoothness rate}) \;\approx\; \text{dial} \;-\; 0.35\,\kappa .$$

The finding that makes it interesting is that at $72$ and $96$ bits the *count* $\kappa$ tells
you everything, while at $128$ bits it does not: the *identity* of the dividing primes starts
to matter. This page builds the exact mathematics behind both facts, and shows they are the
same fact in disguise.

> **What you will be able to do by the end.** State precisely what "composition order is a
> sufficient statistic" means; know why cross-scale slope stability is *not* extra evidence;
> read a measured number off an experiment and convert it into a hard lower bound on how
> unequal the small primes must be.

---

## 1. First, the population: an exactly fair set of coins

Before any claim about a statistic, we need the distribution. Here it is unusually clean.

Let $M = \prod_{p \in B} p$ be the **period** of the base.

> **Theorem (exact cell counts).** For every $S \subseteq B$, the number of integers
> $v$ with $0 \le v < M$ and $\mathrm{cell}(v) = S$ is exactly $\prod_{p \in B\setminus S}(p-1)$.

<details>
<summary><b>Click to reveal the proof — it is two moves long</b></summary>

Put $d = \prod_{p \in S} p$ and $M' = \prod_{p \in B \setminus S} p$, so $M = M'd$.

If $\mathrm{cell}(v) = S$ then every prime of $S$ divides $v$; being *distinct* primes, their
product $d$ divides $v$. Write $v = du$. The requirement that no prime outside $S$ divides
$v$ becomes exactly $\gcd(u, M') = 1$, and $v < M$ becomes $u < M'$.

So $u \mapsto du$ is a bijection onto the fibre, from the set of residues below $M'$ coprime
to $M'$. That set has size $\varphi(M')$, and for a squarefree $M'$ with prime divisors
$B\setminus S$, multiplicativity of Euler's totient gives $\varphi(M') = \prod (p-1)$. $\blacksquare$

*Aside:* a route through the [Chinese Remainder Theorem](https://en.wikipedia.org/wiki/Chinese_remainder_theorem)
also works in principle but bogs down in identifying component maps. Dividing out the forced
factor $d$ removes it entirely.
</details>

Divide by $M$ and something striking appears:

$$\Pr[\mathrm{cell} = S] \;=\; \prod_{p \in S}\frac1p \cdot \prod_{p \in B\setminus S}\Bigl(1 - \frac1p\Bigr).$$

The events "$2 \mid v$", "$3 \mid v$", "$5 \mid v$" are **exactly** independent over a period
— not independent in a limit, independent on the nose, each a coin with bias $1/p$. Two
corollaries fall out immediately: every cell is populated (so a regression on $\kappa$ has
data at every level), and the average composition order is the truncated
[Mertens sum](https://en.wikipedia.org/wiki/Mertens%27_theorems) $\sum_{p\in B} 1/p$.

{{visualization:0}}

> **Read panel (c) carefully.** Real experiments do not sample a period — a base of a dozen
> primes has a period in the hundreds of millions. They sample a *window*. The theorem behind
> that panel says the cell count in $[0,N)$ deviates from $N$ times the periodic density by at
> most $2^{|B\setminus S|}$, **uniformly in $N$**. The error does not grow. That is what makes
> the exact arithmetic above a statement about sampled populations too.

<details>
<summary><b>Why the uniform bound works, and why the obvious argument fails</b></summary>

The engine is a pointwise inclusion–exclusion identity, valid for *every* integer $v$:
$$\mathbf 1[\mathrm{cell}(v) = S] = \sum_{T \subseteq B\setminus S} (-1)^{|T|}\,\mathbf 1\Bigl[\prod_{p \in S\cup T} p \ \Bigm|\ v\Bigr].$$
If some prime of $S$ misses $v$, every term is zero. Otherwise, with $E$ the set of *extra*
primes dividing $v$, the sum is $\sum_{T\subseteq E}(-1)^{|T|} = (1-1)^{|E|}$ — one if $E$ is
empty, zero otherwise. Exactly right.

Now sum over $v < N$. Each divisibility count is $\lceil N/d\rceil$, within $1$ of $N/d$.
There are $2^{|B\setminus S|}$ terms, so the total error is at most that. The main terms
reassemble into the product density.

The failed approach: bound the discrepancy by the length of the incomplete final period. That
gives a constant of size $M$ — worthless precisely when $N \ll M$, which is every real
experiment. Doing the combinatorics *before* truncating is what buys the uniform constant.
</details>

---

## 2. The model, and the one hidden object

Now the response. Suppose each small prime imposes its own additive penalty $w_p$:
$$\Lambda(S) \;=\; \text{dial} \;-\; \sum_{p \in S} w_p .$$

That vector $w = (w_p)_{p \in B}$ — the **weight profile** — is the only hidden object in the
entire story. Here is the punchline of the whole page, stated before we prove any of it:

| The experiment asks | The exact answer is a statement about $w$ |
|---|---|
| does the graded law $\Lambda = \text{dial} - \beta\kappa$ hold? | $w_p = \beta$ for every $p$ |
| is $\kappa$ a sufficient statistic? | $w$ is constant |
| is the fitted slope stable across scales? | $w$ is homogeneous |
| how large is the identity increment? | the pairwise spread energy of $w$ |

Rows two and three are *the same row*. Hold that thought.

### Play with it

The widget below is the whole theory made tangible. Set the weights and watch four things
move at once.

{{interactive_demo:0}}

> **Three experiments to run right now.**
> 1. Hit **Homogeneous**. Every cell of a given $\kappa$ collapses onto one point, the
>    increment reads exactly $0$, and the slope reads exactly $-0.35$. Now change the number
>    of primes in the base. *The slope does not move.* That is scale stability, for free.
> 2. Hit **$\propto \log p$** — the Dickman-type profile. The points fan out at each $\kappa$,
>    and the increment jumps. Note that the slope is *still* a single clean number: a
>    heterogeneous profile can masquerade as a constant one if you only look at the slope.
> 3. Hit **Two-block** and slowly narrow the gap. Watch the pair-energy matrix go dark and the
>    increment fall as the *square* of the spread.

---

## 3. Sufficiency has no middle ground

Say $\kappa$ is **sufficient** if any two cells of the same size carry the same rate.

> **Theorem (the sufficiency dichotomy).** In the additive model, $\kappa$ is sufficient if
> and only if $w$ is constant on the base.

<details>
<summary><b>Proof, and the sharp consequence people find surprising</b></summary>

($\Rightarrow$) Apply the definition to the two singletons $\{p\}$ and $\{r\}$, which have
equal size. Their rates are $\text{dial} - w_p$ and $\text{dial} - w_r$.

($\Leftarrow$) If all weights equal $w_0$, then $\sum_{p\in U} w_p = |U| w_0$ for every $U$,
which depends on $U$ only through $|U|$. $\blacksquare$

**The consequence.** For two singletons,
$$\Lambda(\{r\}) - \Lambda(\{p\}) = w_p - w_r,$$
so if *any* two weights differ at all, sufficiency has already failed at $\kappa = 1$. Inside
a fixed additive model there is no such thing as partial or gradually-degrading sufficiency.

Which is genuinely informative: the *observed* gradedness across scales cannot be an artefact
of the response model. It has to live in the scale dependence of the weights themselves. That
is a real narrowing of the search space.
</details>

There is also a clean cap on how badly it can fail. If all weights lie in $[m, M_x]$, two
cells of the same order $\kappa$ differ by at most
$$\min(\kappa,\ |B| - \kappa)\cdot(M_x - m),$$
and $\kappa = 1$ attains it. (The proof turns on $|S\setminus T| = |T\setminus S|$ when
$|S| = |T|$. Forgetting to condition on equal order gives the useless bound $|B|(M_x-m)$.)

---

## 4. The slope law — and why scale stability is not extra evidence

Write $v_p = q_p(1-q_p)$ for the Bernoulli variance of each divisibility coin. Four moments
come out of one second-moment computation:
$$\mathbb E[\kappa] = \sum_p q_p, \quad \operatorname{Var}(\kappa) = \sum_p v_p, \quad \operatorname{Cov}(\Lambda,\kappa) = -\sum_p w_p v_p, \quad \operatorname{Var}(\Lambda) = \sum_p w_p^2 v_p .$$

Divide the last two:

> **Theorem (the slope law).** The least-squares slope of the log-rate on composition order is
> exactly the $v$-weighted mean of $-w$:
> $$\beta_{\mathrm{OLS}} \;=\; \frac{-\sum_{p} w_p v_p}{\sum_p v_p}.$$

<details>
<summary><b>Where the four moments come from</b></summary>

Write $\sum_{p\in S} a_p = \sum_{p \in B} a_p \mathbf 1[p \in S]$ and use the marginals of the
product measure: $\mathbb E[\mathbf 1_p] = q_p$ and $\mathbb E[\mathbf 1_p \mathbf 1_r] = q_pq_r$
for $p \ne r$, $=q_p$ for $p = r$. Expanding a product of two additive statistics, the
off-diagonal terms reassemble the product of the means and the diagonal contributes
$a_pb_p(q_p - q_p^2) = a_pb_pv_p$. Everything else is specialisation:
$a \equiv 1$ gives $\kappa$, $a = w$ gives $\Lambda$. $\blacksquare$
</details>

Two immediate consequences, and they are the heart of the matter.

* If $w \equiv \beta$, then $\beta_{\mathrm{OLS}} = -\beta$ — for **every** base, **every**
  marginal profile, **every** scale. Slope stability across bit-widths is *automatic*.
* Restricted to a single non-degenerate prime, $\beta_{\mathrm{OLS}} = -w_p$ exactly. So the
  slope is a faithful readout, not a coincidence-prone summary.

> **So: "the slope is the same at 72, 96 and 128 bits" is not a second finding stacked on top
> of the graded law. It is the same finding.** Weight homogeneity forces slope stability
> automatically; slope instability would falsify homogeneity. One confirmation, reported twice.

And because the arithmetic marginals $q_p = 1/p$ *are* the exact periodic cell measure from
Section 1, none of this is about a postulated population. It is about integers.

{{algorithm:2}}

---

## 5. How big is the failure? A closed form

Define the **identity increment** as the variance the $\kappa$-regression cannot explain:
$$\mathcal R = \operatorname{Var}(\Lambda) - \frac{\operatorname{Cov}(\Lambda,\kappa)^2}{\operatorname{Var}(\kappa)} .$$

Feed in the four moments and apply the finite
[Lagrange identity](https://en.wikipedia.org/wiki/Lagrange%27s_identity)
$$\Bigl(\sum_p v_p\Bigr)\Bigl(\sum_p v_p w_p^2\Bigr) - \Bigl(\sum_p v_p w_p\Bigr)^2 = \tfrac12\sum_{p}\sum_{r} v_pv_r(w_p-w_r)^2 .$$

> **Theorem (closed form).**
> $$\mathcal R \;=\; \frac{\tfrac12 \sum_{p\in B}\sum_{r\in B} v_p v_r (w_p - w_r)^2}{\sum_{p\in B} v_p}.$$

That is the matrix the second panel of the laboratory widget draws, term by term. It is a
**pairwise weight-spread energy**, normalised by the total Bernoulli variance. Three facts
follow with no further work: it is non-negative (Cauchy–Schwarz falls out as a *corollary*, not
an assumption); it vanishes exactly when all the weights agree, so the quantitative and
qualitative verdicts coincide precisely; and this holds for the exact arithmetic measure with
no error term.

<details>
<summary><b>Why "residual variance" is the right name — the orthogonality theorem</b></summary>

Build the fitted line explicitly, slope $\beta_{\mathrm{OLS}}$ and intercept
$\alpha = \mathbb E[\Lambda] - \beta_{\mathrm{OLS}}\mathbb E[\kappa]$, and set
$R(S) = \Lambda(S) - (\alpha + \beta_{\mathrm{OLS}}\kappa(S))$.

Then $\mathbb E[R] = 0$ by construction of $\alpha$; and by bilinearity,
$\operatorname{Cov}(R,\kappa) = \operatorname{Cov}(\Lambda,\kappa) - \beta_{\mathrm{OLS}}\operatorname{Var}(\kappa) = 0$ — which is
precisely what makes the fit least-squares. Expanding $\operatorname{Var}(R)$ and using orthogonality to
kill the $\kappa$-part gives $\operatorname{Var}(R) = \mathcal R$, and therefore the Pythagorean
decomposition
$$\operatorname{Var}(\Lambda) = \beta_{\mathrm{OLS}}^2\,\operatorname{Var}(\kappa) + \operatorname{Var}(R),$$
with no cross term. So a reported increment converts exactly into an $R^2$:
$$R^2 = 1 - \frac{\mathcal R}{\operatorname{Var}(\Lambda)} .$$
</details>

### The increment as a certificate

Apply [Popoviciu's inequality](https://en.wikipedia.org/wiki/Popoviciu%27s_inequality_on_variances)
to the closed form:
$$\mathcal R \;\le\; \frac{\bigl(\sum_p v_p\bigr)(M_x - m)^2}{4},$$
and the constant $\tfrac14$ is attained on a balanced two-prime base, so it cannot be
improved. Read it backwards and a measured increment $g$ *forces*
$$M_x - m \;\ge\; 2\sqrt{\frac{g}{\sum_p v_p}} .$$

The $128$-bit increment of $+0.0346$ therefore cannot be produced by a nearly homogeneous
weight profile. The small primes at that scale are demonstrably not interchangeable — and
that conclusion needs no model beyond additivity.

{{visualization:1}}

---

## 6. Where does counting stop being enough?

Three scales, three verdicts: sufficient at $72$ (increment $+0.0071$), sufficient at $96$
($+0.0084$), **not** sufficient at $128$ ($+0.0346$), against a bar of $0.02$.

Suppose the increment $g(u)$ is monotone in the scale. Then everything follows.

{{interactive_demo:1}}

> **What the widget is showing you, in three theorems.**
>
> **Downward closure.** Sufficiency at a larger scale forces it at every smaller one. So a
> TRUE / FALSE / TRUE pattern is *impossible* — the design had a way to fail and did not take
> it. That is what falsifiability looks like.
>
> **Uniqueness.** A continuous, strictly increasing increment meets the bar exactly once
> (intermediate value theorem for existence, strict monotonicity for uniqueness). The observed
> bracket $0.0084 \le 0.02 < 0.0346$ pins that unique boundary strictly inside $(96, 128]$.
>
> **The forced verdict.** Given monotonicity and the $96$-bit measurement, the $72$-bit verdict
> is *predicted*. The observation $0.0071 \le 0.02$ is a consistency check on monotonicity, not
> a third data point. Honest bookkeeping demotes it — try dragging the $96$-bit slider above
> the bar and watch the annotation flip.

{{algorithm:3}}

---

## 7. Check it yourself

Everything above is checkable in exact rational arithmetic, and here it is. The program
enumerates full periods and confirms every cell count on the nose; tabulates window errors
against the certified envelope across four orders of magnitude; recomputes all four moments
as sums over the entire power set and matches them to the closed forms; confirms the
sufficiency dichotomy against a brute-force scan over equal-order cell pairs; and verifies
orthogonality and the Pythagorean decomposition as *equalities between fractions*, so a
failure would abort rather than pass quietly.

{{demo:0}}

For $B = \{2,3,5\}$ with the arithmetic marginals and weights $(0.5, 0.35, 0.20)$, the
increment comes out as $1017/113800 \approx 0.008937$ from the definition, from the
pairwise-energy formula, and from the variance of the explicitly-constructed residual — the
same rational number three different ways.

<details>
<summary><b>The two algorithms behind the population layer</b></summary>

{{algorithm:0}}

{{algorithm:1}}
</details>

---

## 8. Where this goes next

Strip everything down and one object remains: the weight profile $w$. Its homogeneity is
sufficiency; its homogeneity is scale stability; its spread is the increment; its $v$-weighted
average is the measured slope. Four questions, one unknown.

And that focus makes a prediction. If the log smoothness rate behaves like $\log\rho(u)$ with
$\rho$ the [Dickman function](https://en.wikipedia.org/wiki/Dickman_function) and
$u = \log v / \log y$, then conditioning on divisibility by $p$ removes $\log p$ from the size
of $v$, shifting $u$ by $-\log p/\log y$. To first order,
$$w_p \;\approx\; -\frac{\log p}{\log y}\cdot\frac{\rho'(u)}{\rho(u)} \;=\; \frac{\log p}{\log y}\,\log u,$$
proportional to $\log p$ — **not** constant. On that account the beautiful $-0.35$ is an
artefact of a narrow base: a $\log$-weighted average that looks flat across two of three
scales and gets caught at the third.

Is that right? The slope law turns any candidate profile into a single predicted number per
scale. The closed form turns the measured increment into a lower bound on the spread. Between
them, a proposed $w$ has nowhere to hide — go back to the laboratory widget, load the
$\log p$ preset, and see for yourself what it predicts.

Somewhere between $96$ and $128$ bits, arithmetic stops being able to count and starts having
to name names. Finding out exactly where is a question with a number for an answer.
