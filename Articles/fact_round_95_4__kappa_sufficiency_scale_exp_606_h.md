# How Many, or Which? The Hidden Grammar of Small Primes

## A number's fingerprint

Pick an integer at random — say a 96-bit one, roughly $7 \times 10^{28}$. Now ask a very
small question about it: which of the primes $2, 3, 5, 7, 11, \dots, 97$ divide it?

The answer is a *set*. Call it the number's **cell**. A number divisible by $2$ and by $7$
and by nothing else on your list has cell $\{2,7\}$. A number divisible by none of them has
the empty cell. The cell is a fingerprint: a compact, cheap-to-compute record of a number's
smallest arithmetic habits.

Now ask a much harder question about the same number: is it *smooth*? A number is called
$y$-smooth if all of its prime factors are below the bound $y$. Smooth numbers are the fuel
of modern integer factorization and discrete-logarithm algorithms — the quadratic sieve, the
number field sieve, index calculus. Those algorithms spend nearly all of their time hunting
for smooth values in a window of integers, and their running time is governed by exactly one
number: the rate at which smooth values turn up.

So here is the question this article is about. **Does the cheap fingerprint predict the
expensive property?** And if it does — does the *count* of divisors in your fingerprint tell
you everything, or does their *identity* matter too?

Call the count the **composition order**,
$$\kappa(v) = \#\{p \in B : p \mid v\},$$
where $B$ is your fixed base of small primes. Empirically, in three independent
populations at $72$, $96$ and $128$ bits, the logarithm of the smoothness rate falls off in
a strikingly clean way:
$$\log(\text{smoothness rate}) \;\approx\; \text{dial} \;-\; 0.35\,\kappa .$$

Every extra small prime in the fingerprint costs you about $0.35$ in log-rate. And the
slope $-0.35$ barely moves as you go from $72$ to $128$ bits: the three fitted values are
$-0.349$, $-0.380$, $-0.325$, with confidence intervals that all overlap. That stability
across a near-doubling of scale is the kind of coincidence that demands an explanation.

But there is a wrinkle. At $72$ and $96$ bits the count really does say everything: two
numbers with the same $\kappa$ have the same rate, to within measurement noise. At $128$
bits, that breaks. Knowing *which* primes divide $v$ adds real predictive power beyond
knowing *how many*. Somewhere between $96$ and $128$ bits, the fingerprint stops being
summarisable by a single integer.

This article explains what all three of those observations actually *mean*, by building an
exact model in which each one becomes a theorem — and, more interestingly, in which each one
turns out to be equivalent to a single, sharply-stated property of one hidden object.

---

## Step one: the fingerprint is an exactly fair coin

Before you can talk about a statistic being "sufficient," you need to know how the
fingerprints are distributed in the first place. Here the news is unusually good: not
approximately, not asymptotically, but *exactly*.

Fix a base $B$ of distinct primes and let $M = \prod_{p \in B} p$ be its **period**. Then:

> **Theorem (exact cell counts).** For every subset $S \subseteq B$, the number of integers
> $v$ in the range $0 \le v < M$ whose cell is exactly $S$ equals
> $$\prod_{p \in B \setminus S} (p-1).$$

The proof is a pretty two-line idea. If the cell of $v$ is exactly $S$, then $v$ is
divisible by $d = \prod_{p \in S} p$ — so write $v = d\,u$. The condition that no prime
outside $S$ divides $v$ becomes the condition that $u$ is coprime to $\prod_{p \in B\setminus
S} p$, and $u$ ranges over exactly one period of that modulus. The count is therefore Euler's
totient of a squarefree number, which is $\prod (p-1)$. Multiplication by $d$ is a bijection,
so the count transfers.

Divide by $M$ and the counts turn into a probability:

> **Theorem (exact independence).** The density of the cell $S$ over one period is
> $$\Pr[\,\text{cell} = S\,] \;=\; \prod_{p \in S} \frac{1}{p} \;\cdot\; \prod_{p \in B \setminus S}\!\left(1 - \frac{1}{p}\right).$$

Read that carefully: over one period, the events "$2$ divides $v$", "$3$ divides $v$",
"$5$ divides $v$" are *exactly* independent, each a biased coin flip with probability
$1/p$. Not independent in a limit; independent on the nose. The fingerprint is a vector of
independent Bernoulli coins whose biases happen to be the reciprocals of the primes.

Two immediate consequences fall out. The densities sum to $1$ (the fibres partition the
period). And the average composition order over a period is exactly the truncated Mertens
sum,
$$\mathbb{E}[\kappa] \;=\; \sum_{p \in B} \frac{1}{p},$$
which for $B = \{2,3,5\}$ is $\tfrac12+\tfrac13+\tfrac15 = \tfrac{31}{30}$ — and indeed the
total of $\kappa$ over the $30$ residues mod $30$ is exactly $31$. Also, every cell is
populated: no value of $\kappa$ between $0$ and $|B|$ is empty, so a regression on $\kappa$
has data at every level.

## Step two: real experiments do not sample a whole period

There is an honest objection. A base of a dozen small primes has a period in the hundreds
of millions; a base of thirty has a period past $10^{40}$. No experiment samples a period. It
samples a *window* — a few hundred thousand integers of a fixed bit-width. Could the whole
effect be a sampling artefact, a fossil of where the window happened to land?

No, and the reason is quantitative:

> **Theorem (window error bound).** For every base $B$, every cell $S \subseteq B$ and every
> window length $N$,
> $$\left|\; \#\{v < N : \text{cell}(v) = S\} \;-\; N \prod_{p\in S}\tfrac1p \prod_{p \in B\setminus S}\!\big(1-\tfrac1p\big) \;\right| \;\le\; 2^{|B \setminus S|}.$$

The error term does not grow with $N$ at all. It depends only on the base. So the empirical
cell frequencies converge to the exact periodic densities at rate $2^{|B|}/N$, with a fully
explicit constant and no hypothesis on how the window is placed.

The mechanism is inclusion–exclusion applied *before* truncation. Pointwise, for every
integer $v$,
$$\mathbf{1}[\text{cell}(v) = S] \;=\; \sum_{T \subseteq B \setminus S} (-1)^{|T|}\, \mathbf{1}\!\left[\textstyle\prod_{p \in S \cup T} p \;\Big|\; v\right],$$
because the alternating sum over the "extra" primes that divide $v$ collapses to $1$ when
there are none and to $0$ otherwise. Each divisibility count in $[0,N)$ is $\lceil N/d\rceil$,
within $1$ of $N/d$; there are $2^{|B\setminus S|}$ terms; add up the errors. A naive attempt
that bounds the error by the number of incomplete periods gives a constant of size $M$, which
is worthless in the regime $N \ll M$ where all real experiments live. Doing the
combinatorics first is what buys the uniform bound.

So the exact arithmetic of periods really does describe sampled windows.

---

## Step three: the model, and the one object that controls everything

Now the modelling step. Suppose that each small prime $p$ in the fingerprint imposes its own
additive penalty $w_p$ on the log-rate:
$$\Lambda(S) \;=\; \text{dial} \;-\; \sum_{p \in S} w_p .$$

This is the mildest possible hypothesis compatible with the observed graded law — it says
the primes act independently and additively, nothing more. The vector $w = (w_p)_{p\in B}$ is
the **weight profile**, and it is the single hidden object in the story. Every one of the
three empirical verdicts turns out to be a statement about $w$, and only about $w$.

### Verdict 1: the graded law says the weights are all equal

> **Theorem (identification of the graded law).** The affine law $\Lambda(S) = C - \beta\,|S|$
> holds for every cell $S \subseteq B$ **if and only if** $w_p = \beta$ for every $p \in B$;
> and in that case $C$ is the dial.

The forward direction is a computation. The converse is even easier and more revealing:
evaluate the law at the empty cell to pin the dial, then at each singleton $\{p\}$ to pin
$w_p = \beta$. The graded law is not a loose fit — it is a *complete determination* of the
model.

### Verdict 2: sufficiency is weight homogeneity, with no middle ground

Say that $\kappa$ is a **sufficient statistic** if any two cells of the same size carry the
same rate — i.e. the count really does summarise the fingerprint.

> **Theorem (sufficiency dichotomy).** In the additive model, $\kappa$ is sufficient if and
> only if $w$ is constant on $B$.

And here is the sting: the failure is visible immediately. For two singleton cells,
$$\Lambda(\{r\}) - \Lambda(\{p\}) = w_p - w_r,$$
so if any two weights differ at all, sufficiency has already failed at $\kappa = 1$. There is
no graded, slowly-degrading sufficiency inside a fixed additive model. Any *gradedness* in
the empirical picture must therefore come from somewhere else — from the weights themselves
changing with scale. That is a genuinely informative negative result: it tells you where to
look.

There is also a clean a priori cap on how badly sufficiency can fail. If all the weights lie
in an interval $[m, M_x]$, then two cells of the same order $\kappa$ differ by at most
$$\min(\kappa,\; |B| - \kappa)\cdot(M_x - m),$$
and the case $\kappa = 1$ shows the bound is attained. (The proof turns on the little
combinatorial fact that $|S \setminus T| = |T \setminus S|$ when $|S| = |T|$, and that this
common size is at most $\min(\kappa, |B|-\kappa)$. Bounding without conditioning on equal
order gives the useless constant $|B|\cdot(M_x-m)$.)

### Verdict 3: scale stability is *equivalent* to weight homogeneity

This is the one that reframes the experiment. Under the product cell measure with marginals
$q_p$, write $v_p = q_p(1-q_p)$ for the Bernoulli variance of each divisibility coin. Then a
short second-moment computation gives everything:
$$\mathbb{E}[\kappa] = \sum_p q_p, \qquad \operatorname{Var}(\kappa) = \sum_p v_p, \qquad \operatorname{Cov}(\Lambda, \kappa) = -\sum_p w_p\, v_p, \qquad \operatorname{Var}(\Lambda) = \sum_p w_p^2\, v_p.$$

Dividing the last two of these:

> **Theorem (the slope law).** The least-squares slope of the log-rate regressed on the
> composition order is exactly the $v$-weighted mean of $-w$:
> $$\beta_{\mathrm{OLS}} \;=\; \frac{-\sum_{p \in B} w_p\, v_p}{\sum_{p \in B} v_p}.$$

Immediately: if $w \equiv \beta$, the slope is $-\beta$ — for *every* base, *every* marginal
profile, *every* scale. Conversely, restricted to a single non-degenerate prime, the slope
*is* $-w_p$, so the slope is a faithful readout of the penalty.

That is the punchline about scale stability. The observation "the slope is the same at $72$,
$96$ and $128$ bits" is not an extra empirical coincidence stacked on top of the graded law.
It is *the same fact*. Weight homogeneity forces slope stability across all scales
automatically; slope instability would falsify homogeneity. One experimental finding, not
two.

And because the arithmetic cell measure with $q_p = 1/p$ *is* the product measure — that was
Step One — the slope law is a theorem about integers, not about a postulated population.

---

## Step four: how big is the failure, exactly?

The $128$-bit result says identity adds something. The natural next question is: how much,
and what does the amount tell you?

Define the **identity increment** as the variance the $\kappa$-regression cannot explain,
$$\mathcal{R} \;=\; \operatorname{Var}(\Lambda) \;-\; \frac{\operatorname{Cov}(\Lambda,\kappa)^2}{\operatorname{Var}(\kappa)} .$$

Plug in the four moments above and a classical algebraic identity — the finite Lagrange
identity
$$\Big(\sum_p v_p\Big)\Big(\sum_p v_p w_p^2\Big) - \Big(\sum_p v_p w_p\Big)^2 = \tfrac12 \sum_{p}\sum_{r} v_p v_r (w_p - w_r)^2$$
— and the increment collapses to a closed form:

> **Theorem (closed form for the identity increment).**
> $$\mathcal{R} \;=\; \frac{\tfrac12 \sum_{p \in B}\sum_{r \in B} v_p\, v_r\, (w_p - w_r)^2}{\sum_{p \in B} v_p}.$$

The increment is a **pairwise weight-spread energy**, normalised by the total Bernoulli
variance. That single formula settles everything at once. It is manifestly non-negative
(recovering Cauchy–Schwarz as a corollary rather than assuming it). It vanishes exactly when
all the weights agree — so the *quantitative* verdict ("increment below the bar") and the
*qualitative* verdict ("$\kappa$ is sufficient") coincide precisely, with no error term, and
in particular they coincide for the exact arithmetic measure $q_p = 1/p$.

The name "residual variance" is earned, not asserted. Build the fitted line explicitly,
with slope $\beta_{\mathrm{OLS}}$ and the matching intercept, and let
$R(S) = \Lambda(S) - (\alpha + \beta_{\mathrm{OLS}}\kappa(S))$ be the residual. Then $R$ has
mean zero; $R$ is uncorrelated with $\kappa$ (which is what makes the fit least-squares); the
variance of $R$ is exactly $\mathcal{R}$; and there is a Pythagorean decomposition
$$\operatorname{Var}(\Lambda) \;=\; \beta_{\mathrm{OLS}}^2 \operatorname{Var}(\kappa) \;+\; \operatorname{Var}(R),$$
with no cross term. A reported increment therefore converts directly into an $R^2$: the
fraction of log-rate variance explained by composition order is $1 - \mathcal{R}/\operatorname{Var}(\Lambda)$.

Finally, the increment is a *certificate*. Popoviciu's inequality applied to the closed form
gives
$$\mathcal{R} \;\le\; \frac{\big(\sum_p v_p\big)(M_x - m)^2}{4},$$
and the constant $1/4$ is attained on a balanced two-prime base with $q = 1/2$, so it cannot
be improved. Read backwards, a measured increment $g$ *forces* a weight spread of at least
$$M_x - m \;\ge\; 2\sqrt{\frac{g}{\sum_p v_p}}.$$
The $128$-bit increment of $+0.0346$ therefore cannot be produced by a nearly homogeneous
weight profile. The primes at that scale are demonstrably not interchangeable.

---

## Step five: where the boundary is

Three scales, three verdicts: TRUE at $72$ bits (increment $+0.0071$), TRUE at $96$
(increment $+0.0084$), FALSE at $128$ (increment $+0.0346$), against a pre-registered bar of
$0.02$. What can be deduced?

Suppose the increment is a monotone function of scale. Then the sufficiency verdict is
**downward closed**: sufficiency at a larger scale forces sufficiency at every smaller one.
Two consequences follow, and they cut in opposite directions.

First, a *falsifiability* statement: a TRUE / FALSE / TRUE pattern across increasing scales
is impossible. If a future run produced one, it would refute monotonicity outright, not
merely add noise. The three-verdict pattern is a real test, with a shape it could have failed
and did not.

Second, a *deflation*: the $72$-bit TRUE verdict was **predicted**, not independent evidence.
Given the $96$-bit increment of $0.0084 \le 0.02$ and monotonicity, sufficiency at $72$ bits
is forced. The observation $0.0071 \le 0.02$ is a consistency check on monotonicity, not a
third data point. Honest bookkeeping demotes it.

What remains is a genuine crossing. If the increment is continuous and strictly increasing,
then it crosses the bar at exactly one scale, and the observed bracket
$0.0084 \le 0.02 < 0.0346$ places that unique boundary strictly inside $(96, 128]$. The
verdict at a scale is then literally the statement "you are below the boundary."

This is the sharp form of the empirical claim. Below the boundary, *how many* small primes
divide $v$ summarises everything rate-relevant. Above it, *which* primes matter too.

---

## What is really being asked

Strip the story down and one object remains: the weight profile $w$. Its homogeneity is
sufficiency; its homogeneity is scale stability; its spread is the identity increment; its
average against the Bernoulli variances is the measured slope $-0.35$. Four experimental
questions have become one.

And that focus makes a real prediction. Suppose the log smoothness rate of a window behaves
like $\log \rho(u)$, where $\rho$ is the Dickman function and $u = \log v / \log y$ is the
usual smoothness parameter. Conditioning on divisibility by $p$ removes $\log p$ from the
size of $v$, shifting $u$ by $-\log p / \log y$. To first order the penalty is then
$$w_p \;\approx\; \frac{\log p}{\log y}\,\log u ,$$
which is proportional to $\log p$ — *not* constant. On that account, the beautiful constant
$-0.35$ is an artefact of a narrow base: a $\log$-weighted average masquerading as a single
number, homogeneous enough to look flat across two-thirds of the scales tested and
heterogeneous enough to be caught at the third.

That is a falsifiable statement, and the results above make it cheap to test. The slope law
turns any candidate weight profile into a single predicted number per scale. The closed form
turns the measured increment into a lower bound on the weight spread. Between the two, a
proposed $w$ has nowhere to hide.

Somewhere between $96$ and $128$ bits, arithmetic stops being able to count and starts having
to name names. Finding out exactly where — and which primes are the culprits — is a question
with a number for an answer.
