# When a Language Model Learns to Love the Primes

## An unlikely meeting between machine alignment and the arithmetic of the integers

There is a formula that sits at the heart of how modern language models are taught to behave. It is written down in every alignment pipeline, tuned by every practitioner, and it looks like this:

$$
J(q) \;=\; \underbrace{\mathbb{E}_{y \sim q}\big[r(y)\big]}_{\text{do what we reward}} \;-\; \underbrace{\beta\, \mathrm{KL}\big(q \,\Vert\, p\big)}_{\text{but don't drift too far}} \;+\; \underbrace{\gamma\, \mathbb{E}_{x \sim d}\big[\log q(x)\big]}_{\text{and don't forget what you knew}}.
$$

Here $p$ is the model you started with — the "reference" — and $q$ is the model you are trying to produce. The reward $r$ scores responses. The coefficient $\beta$ is a leash: turn it up and the tuned model stays close to where it began; turn it down and it chases reward with abandon. The last term drags the model back toward its original training distribution $d$ so that fine-tuning doesn't erase general competence.

Everybody in machine learning knows this object. What nobody expected is that if you feed it the right reward function, it starts computing the Riemann zeta function.

This article is about that discovery: a precise dictionary between the optimization of aligned language models and classical analytic number theory, in which Euler products become statements of statistical independence, the second derivative of a training curve becomes a variance, and a machine chasing a cleverly chosen reward reliably lands on the prime numbers.

---

## Part I: The alignment problem has an exact answer

The first thing to appreciate is that the objective above is not a black box. Over a finite space $\Omega$ of possible responses, it can be solved in closed form.

Define the **partition function**
$$
Z(\beta) \;=\; \sum_{y \in \Omega} p(y)\, e^{r(y)/\beta},
$$
and the **aligned policy**
$$
\pi_\beta(y) \;=\; \frac{p(y)\, e^{r(y)/\beta}}{Z(\beta)}.
$$
This is the reference model reweighted by an exponential in the reward — a softmax tilt.

**The Gibbs Variational Principle.** For every candidate policy $q$,
$$
J(q) \;=\; \beta \log Z(\beta) \;-\; \beta\, \mathrm{KL}\big(q \,\Vert\, \pi_\beta\big).
$$

Read that identity carefully, because it says everything at once. The objective is a constant minus a penalty, and the penalty is a *distance to $\pi_\beta$*. Since Kullback–Leibler divergence is nonnegative and vanishes only when the two distributions coincide, we learn that $J(q) \le \beta \log Z(\beta)$ for every $q$, with equality exactly at $q = \pi_\beta$. Training is not an approximation of some vague ideal: there is a unique optimum, and we can write it down.

The optimal value
$$
V(\beta) \;=\; \beta \log Z(\beta)
$$
is called the **free energy**, and it is the central character of everything that follows. It is a single real-valued curve, defined for $\beta > 0$, and it summarizes the entire alignment problem.

What does it look like? It is decreasing: a shorter leash (smaller $\beta$) always permits a better score. It is trapped between two natural quantities — never above the maximum achievable reward $\max_y r(y)$, never below the reference model's average reward $\mathbb{E}_p[r]$. And these are exactly its two limits: as $\beta \to 0^+$ the curve rises to $\max_y r(y)$ (pure greedy reward maximization), while as $\beta \to \infty$ it falls to $\mathbb{E}_p[r]$ (do nothing at all). Alignment interpolates between doing nothing and doing the most.

There is even a guarantee against catastrophe. If the reward takes values in $[m, M]$, then
$$
\beta \cdot \mathrm{KL}\big(\pi_\beta \,\Vert\, p\big) \;\le\; M - m.
$$
The aligned model cannot wander arbitrarily far from where it started; the leash and the reward range together bound the drift. Policy collapse, in this idealized setting, is impossible.

And what about the last term of the objective, the one that guards against forgetting? It contributes an exact and unavoidable cost. With the pretraining mix-in weighted by $\gamma$, the achievable value is at most $\beta \log Z(\beta) - \gamma H(d)$, where $H(d)$ is the entropy of the pretraining distribution, and — this is the sharp part — the bound is *strictly* unattainable unless the aligned policy happens to equal the pretraining distribution exactly. There is a genuine **alignment tax**: you cannot simultaneously be optimally aligned and optimally faithful to your origins, except in the degenerate case where those two demands coincide.

---

## Part II: The shape of the training curve

Substituting $t = 1/\beta$ (physicists call this the inverse temperature) turns $\log Z$ into a beautifully behaved function of $t$:
$$
\log Z(t) \;=\; \log \sum_y p(y)\, e^{r(y) t}.
$$

Its derivatives are meaningful. The first derivative is the aligned expected reward, $\mathbb{E}_{\pi_t}[r]$. The second derivative is
$$
\frac{d^2}{dt^2} \log Z(t) \;=\; \mathrm{Var}_{\pi_t}(r).
$$

**The curvature of the alignment value curve is the reward variance under the current policy.** This one identity carries surprisingly much. Since variances are nonnegative, $\log Z$ is convex — and strictly convex the moment the reward is non-constant, so any two responses scored differently are enough to bend the curve. Convexity in turn means that annealing between two temperature settings never beats the corresponding average of the two endpoint values: there is no free lunch in temperature schedules.

More strikingly, it gives a **speed limit for alignment**. The expected reward can only increase as you tighten the leash, and its rate of increase is exactly the variance. If the reward is confined to $[m, M]$, Popoviciu's inequality caps every variance by $(M-m)^2/4$, so
$$
\mathbb{E}_{\pi_{t_2}}[r] - \mathbb{E}_{\pi_{t_1}}[r] \;\le\; \frac{(M-m)^2}{4}\,(t_2 - t_1).
$$
No matter how vast the response space, no matter how the reward is distributed, alignment progresses at a bounded rate per unit of inverse temperature. Even better, that rate is exactly integrable:
$$
\int_{t_1}^{t_2} \mathrm{Var}_{\pi_t}(r)\, dt \;=\; \mathbb{E}_{\pi_{t_2}}[r] - \mathbb{E}_{\pi_{t_1}}[r].
$$
Total alignment gain is accumulated variance. And the constant $1/4$ cannot be improved: a reward taking only the values $0$ and $1$ on a balanced reference has variance exactly $e^t/(1+e^t)^2$, hitting $1/4$ at $t = 0$ — the slope of the logistic curve at the origin. Equality in the general bound is attained precisely when the reward is two-valued at the extremes $m$ and $M$ and the aligned policy splits its mass evenly between them.

---

## Part III: Can you audit a model from its training curve?

Here is a question a safety auditor might ask. Suppose you can measure the value curve $V(\beta)$ — the achievable alignment score at each leash setting — but you cannot see the reward model itself. What have you learned?

Call the **reward spectrum** the function
$$
m(v) \;=\; \sum_{y : \, r(y) = v} p(y),
$$
the reference mass sitting at each reward value. The partition function is exactly its exponential transform, $Z(t) = \sum_v m(v) e^{vt}$.

**Spectral Rigidity Theorem.** If two alignment problems — possibly on entirely different response spaces — have the same free-energy curve for all $\beta > 0$, then they have the same reward spectrum: $m_1(v) = m_2(v)$ for every real $v$.

The value curve determines the reward model completely, up to relabelling which response carries which value. Nothing finer survives (permutations of responses are invisible to $Z$), and nothing coarser is lost. The proof rests on the linear independence of real exponentials with distinct rates — Dedekind's independence of characters — with an extra twist, because the physics only gives us the half-line $\beta > 0$, and Dedekind's argument does not see half-lines. One divides by the dominant exponential and lets $t \to \infty$, killing the subdominant terms one at a time.

That is an infinite-data statement. In practice an auditor gets finitely many measurements. How many?

The answer splits sharply along one question: *do you know the candidate reward levels?*

**If you do**, then $n$ known distinct levels require exactly $n$ temperature measurements, and — this is the refined version — **any** $n$ distinct temperatures will do. There is no bad grid. This is because exponential sums form what is classically called a Chebyshev system: a nonzero combination $\sum_{j<n} c_j e^{v_j x}$ with $n$ distinct exponents has at most $n-1$ real zeros. The proof is Rolle's theorem run as an induction: divide out the slowest exponential, differentiate, and each consecutive pair of zeros yields a zero of an exponential polynomial with one fewer exponent.

**If you do not know the levels**, the count changes, and one might naively hope that $2n-1$ measurements suffice — one for each unknown mass and each unknown level, minus normalization. It is false already for $n = 2$. There are two genuinely different two-atom reward models, all four reward levels distinct, whose partition functions agree at the three inverse temperatures $t = 0, 1, 2$ and whose spectra differ. The construction is a moment coincidence hiding in plain sight: the two-point distributions supported on $\{1, 3\}$ with masses $(1/2, 1/2)$ and on $\{3/2, 4\}$ with masses $(4/5, 1/5)$ share the same mean $2$ and the same second moment $5$. Take logarithms of the support, and those two coincidences become agreement of the partition functions at $t = 1$ and $t = 2$; agreement at $t = 0$ is just normalization. Three probes are not enough. Auditing is possible, but only with the right prior knowledge.

---

## Part IV: Alignment as a group action

Before we get to the primes, one more structural fact, and it is the one with the sharpest practical bite.

The map from reward models to aligned policies is not injective: adding a constant to the reward changes nothing, since the constant cancels between numerator and denominator. **That is the only ambiguity** — two rewards induce the same aligned policy if and only if they differ by an additive constant. Conversely, every strictly positive policy $q$ is the alignment of some reward, namely the implicit reward $\beta \log(q/p)$. So alignment is a *bijection* between reward models modulo constants and positive policies.

Now compose two alignment steps at the same temperature. The result is
$$
\pi_\beta\big(r_2, \pi_\beta(r_1, p)\big) \;=\; \pi_\beta(r_1 + r_2,\, p).
$$
Alignment steps *add their rewards*. And since only the ratio $r/\beta$ matters, a step at temperature $\beta'$ is a step at temperature $\beta$ with the reward rescaled by $\beta/\beta'$. Chain these together and you get:

**Schedule Collapse Theorem.** An arbitrary finite training schedule — step $i$ using its own reward $r_i$ at its own leash $\beta_i$ — produces exactly the same policy as a *single* step at any temperature $\beta$ of your choosing, with reward $\sum_i (\beta/\beta_i)\, r_i$.

Iterated alignment has no extra expressive power. The set of policies reachable by any schedule is exactly the set reachable in one step. Whatever multi-stage pipelines buy in practice, they buy it in optimization dynamics, not in the geometry of attainable models.

---

## Part V: The primes appear

Now the arithmetic.

Take the response space to be the $\{p, q\}$-smooth integers — numbers of the form $p^a q^b$ with bounded exponents — with a uniform reference. Give it the **Dirichlet reward** $r(n) = -\beta s \log n$: a model penalized, logarithmically, for producing large numbers.

Then the aligned policy is
$$
\pi(n) \;\propto\; n^{-s}.
$$
It is the truncated zeta distribution. The normalizing constant is the truncated zeta sum, and the Euler product
$$
\sum_{a,b} (p^a q^b)^{-s} \;=\; \Big(\sum_a p^{-as}\Big)\Big(\sum_b q^{-bs}\Big)
$$
becomes a probabilistic statement: **under the aligned policy, the prime exponents are statistically independent.** Euler's product formula, the founding identity of analytic number theory, is here the factorization of a fine-tuned model into independent per-prime components. Correspondingly, the free energy is *additive over the primes*, and each local factor is strictly dominated by the honest Euler factor $-\log(1 - p^{-s})$ — a Mertens-type ceiling on how much any one prime can contribute. All of this carries over verbatim to arbitrarily many primes at once.

The aligned model even reproduces classical densities. The probability that the sampled response is *not* divisible by $p$ equals $1/\sum_{k \le A} p^{-ks}$, which is strictly larger than $1 - p^{-s}$ and converges to exactly $1 - p^{-s}$ as the exponent cutoff is lifted. The Dirichlet density of $p$-indivisible integers emerges as a sampling statistic of an aligned model.

And the log-convexity from Part II, translated: truncated Dirichlet series are log-convex in the exponent $s$, with curvature equal to the variance of $\log n$ under the truncated zeta law, and — beautifully — the curvature of the truncated Euler product is the *sum* of the per-prime curvatures. Alignment difficulty decomposes additively over the primes.

---

## Part VI: Reward hacking discovers arithmetic

The finale. Take the response space $\{1, 2, \dots, N\}$ with a uniform reference and the **von Mangoldt reward**
$$
\Lambda(n) \;=\; \begin{cases} \log p & \text{if } n = p^k \text{ for a prime } p, \\ 0 & \text{otherwise.}\end{cases}
$$
This is the canonical arithmetic reward: it pays you, in logarithms, for producing a prime power, and pays nothing otherwise.

The aligned policy has an explicit form: $\pi_\beta(n) \propto p^{1/\beta}$ if $n = p^k$, and $\propto 1$ otherwise. Its value curve is pinned between two classical prime-counting quantities:
$$
\frac{\psi(N)}{N} \;\le\; V(\beta) \;\le\; \log N,
$$
where $\psi(N) = \sum_{n \le N} \Lambda(n)$ is the Chebyshev function. For $N \ge 2$ the left inequality is *strict* — the alignment gain over the untuned model is powered exactly by the irregularity of the distribution of primes. A perfectly uniform reward would give no gain at all; it is the lumpiness of the primes that creates room to improve. In the two limits: as $\beta \to \infty$ the curve tends to the Chebyshev average $\psi(N)/N$, and as $\beta \to 0^+$ it tends to $\log P$, where $P$ is the **largest prime not exceeding $N$**. The entire alignment spectrum of this model is bracketed by prime-counting data.

And then the quantitative statement:

**Prime Discovery Theorem.** If the KL coefficient satisfies $\beta \log N \le \log 2$, then the aligned policy emits a prime power with probability at least $1/2$.

The proof is a two-line weighing. Every non-prime-power carries Gibbs weight exactly $1$, so all of them together weigh at most $N$. Meanwhile the single response $n = 2$ carries weight $e^{\log 2/\beta} = 2^{1/\beta} \ge N$ under the threshold. One response outweighs the entire complement, and the primes win by a majority.

Nor is this a knife-edge. The aligned mass of any upper level set of the reward is *antitone* in $\beta$ — tighten the leash and the mass on high-reward responses only increases. (The mechanism is a rearrangement inequality on Gibbs weights: for $y$ in the level set and $z$ outside, $(r(y) - r(z))(1/\beta_2 - 1/\beta_1) \le 0$, and summing the resulting pairwise inequality over all such pairs gives the monotonicity.) So the set of leash settings at which the model is majority-prime is downward closed and contains the whole interval $(0, \log 2 / \log N]$. There is a genuine phase transition, and below it the model has become, in a precise and quantified sense, an instrument that finds primes.

---

## Why this matters

It is tempting to file this under "cute coincidence". I think that undersells it.

The alignment objective is, structurally, a Gibbs measure — statistical mechanics with a reward playing the role of energy and the KL coefficient playing the role of temperature. Analytic number theory has been doing statistical mechanics with $n^{-s}$ for a hundred and fifty years without calling it that; the Riemann zeta function *is* a partition function. So the dictionary is not an accident. It is two fields discovering they had been using the same object.

What the dictionary buys is transfer in both directions. From physics and number theory, alignment inherits: an exact optimum, a convexity theory with sharp constants, a speed limit, an identifiability theorem, and a rigidity theorem telling you exactly what an audit of the value curve can and cannot recover. From alignment, number theory inherits a new source of questions — what does it mean, arithmetically, for the log-convexity of a truncated zeta function to be the curvature of a training curve? What arithmetic reward makes a model discover twin primes rather than primes?

And there is the moral for the practitioner. "Reward hacking" is usually a pejorative: the model finds structure in the reward that you did not intend. Here we have a theorem certifying that reward hacking works — that a model given an arithmetic reward and a short enough leash will provably discover the prime numbers, with an explicit threshold and a rate. Sometimes the structure the model finds is the structure you were hoping for. The question is whether you knew, in advance, what structure your reward encoded.

For the von Mangoldt reward, we now know exactly. That, at least, is a start.
