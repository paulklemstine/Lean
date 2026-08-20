# The Shape of Alignment: What Combinatorics Knows About Tuning a Language Model

## A tug-of-war written on a hypercube

Every modern language model that has been "aligned" — taught to be helpful, to follow
instructions, to refuse the things it should refuse — has been pulled through the same
tug-of-war. On one side is a *reward*: a score, produced by some judge, that says how
good a candidate answer is. On the other side is a *leash*: a penalty that punishes the
model for wandering too far from the behaviour it had before tuning. The tuned model is
whatever settles at the point where the pull and the leash balance.

Written down, the tug-of-war is a single line. If $q$ is the distribution over answers
that the tuned model produces, $p$ is the distribution the original model produced, and
$r$ is the reward, then the tuning procedure searches for the $q$ that maximises

$$J(q) \;=\; \mathbb{E}_{y \sim q}\bigl[r(y)\bigr] \;-\; \beta \, \mathrm{KL}(q \,\|\, p).$$

The first term is the pull: make the reward big. The second is the leash: the
Kullback–Leibler divergence $\mathrm{KL}(q\|p) = \sum_y q(y)\log\frac{q(y)}{p(y)}$
measures how much information separates the new behaviour from the old, and $\beta > 0$
sets how tight the leash is. Practitioners often add a third term that rewards the model
for still assigning high likelihood to its original training corpus, so that alignment
does not erase general competence.

This is a formula from machine learning. But something interesting happens if you refuse
to treat it as one — if you insist instead that it is a formula about *sets*.

Suppose an answer is not a string of words but a **set of satisfied conditions**. A
symbolic checker runs over a candidate answer and reports which of $n$ requirements it
met: cited a real source, respected the user's format, avoided the forbidden topic, got
the arithmetic right, and so on. The answer, as far as the reward is concerned, *is* the
subset $S \subseteq \{1,\dots,n\}$ of conditions it satisfied. The space of answers is
then the **Boolean lattice**: the $2^n$ corners of an $n$-dimensional cube, ordered by
inclusion.

Once the answer space is a hypercube, the tug-of-war stops being an optimisation problem
and becomes a counting problem. And counting problems have exact answers.

## The one identity everything rests on

Here is the pivot. Suppose you want to add up some quantity over all $2^n$ subsets of
$\{1,\dots,n\}$, and the quantity depends on a subset only through *how big it is*. Then
you do not need to visit $2^n$ subsets; you need to visit $n+1$ sizes, weighting each by
the number of subsets of that size:

$$\sum_{S \subseteq \{1,\dots,n\}} f\bigl(|S|\bigr) \;=\; \sum_{k=0}^{n} \binom{n}{k}\, f(k).$$

That is the whole trick — the transfer principle. Applied to $f(k) = x^k$ it gives the
binomial theorem in disguise, $\sum_S x^{|S|} = (1+x)^n$: the generating function of the
cube.

Now let the reward be the most natural thing a symbolic checker could produce: $a$ points
per satisfied condition, so $r(S) = a|S|$. What does the tug-of-war produce?

The answer is known in closed form, and it is startlingly clean. The **partition
function** — the normalising sum $Z = \sum_S p(S)\,e^{r(S)/\beta}$ that appears whenever
you solve this kind of problem — is nothing but the binomial theorem evaluated at
$x = e^{a/\beta}$:

$$Z \;=\; \left(\frac{1 + e^{a/\beta}}{2}\right)^{\! n}.$$

And the aligned model itself? It is a product of $n$ independent coin flips. Writing
$\sigma(t) = e^t/(1+e^t)$ for the logistic function — the sigmoid that appears in every
neural network ever built — the tuned policy assigns to the answer $S$ the probability

$$\pi(S) \;=\; \theta^{|S|}(1-\theta)^{\,n-|S|}, \qquad \theta = \sigma\!\left(\frac{a}{\beta}\right).$$

Read that again, because it is the heart of the matter. **KL-regularised alignment with a
counting reward turns the model into $n$ independent Bernoulli features, each satisfied
with probability $\sigma(a/\beta)$.** The sigmoid link is not a modelling choice anybody
made; it falls out of the optimisation. The reward-per-condition $a$ and the leash
tightness $\beta$ enter only through their ratio $a/\beta$ — a single effective
temperature — and that ratio is pushed through a logistic squashing function to become a
probability.

The consequences cascade immediately, and every one of them is a statement of elementary
combinatorics.

## Five things that follow for free

**The distribution of quality is binomial.** How many conditions does the aligned model
satisfy? Exactly $\mathrm{Binomial}(n, \theta)$: the chance of satisfying exactly $k$ of
them is $\binom{n}{k}\theta^k(1-\theta)^{n-k}$. Alignment converts a counting reward into
a binomial concentration.

**The mean is exactly $n\theta$.** The expected number of satisfied conditions is
$n\,\sigma(a/\beta)$ and the expected reward is $a\,n\,\sigma(a/\beta)$. The proof is
the absorption identity $k\binom{n}{k} = n\binom{n-1}{k-1}$ — a fact about Pascal's
triangle, deployed to compute the output of a machine-learning pipeline.

**The information drift is exactly computable.** How far did the model actually travel?
The divergence from the original uniform behaviour is

$$\mathrm{KL}(\pi\|p) \;=\; n\left(\frac{a}{\beta}\,\sigma\!\left(\frac a\beta\right) - \log\frac{1+e^{a/\beta}}{2}\right),$$

which is *linear in $n$*. Drift is extensive: double the number of conditions and you
double the information distance travelled. There is no economy of scale in alignment.

**Alignment is order-preserving.** When the reward is non-negative, the aligned
distribution is a *monotone measure* on the cube: enlarging a set never decreases its
probability. If $S \subseteq T$ then $\pi(S) \le \pi(T)$. Satisfying more conditions is
always at least as likely as satisfying fewer — an intuitive statement that is,
pleasingly, exactly true rather than approximately so.

**Quality is never bimodal.** The level masses $m_k = \binom nk\theta^k(1-\theta)^{n-k}$
are **log-concave**: $m_k m_{k+2} \le m_{k+1}^2$. This follows from the log-concavity of
the binomial coefficients themselves, $\binom nk\binom n{k+2} \le \binom n{k+1}^2$, which
in turn follows from the single identity $\binom{n}{k+1}(k+1) = \binom nk (n-k)$.
Log-concavity forces unimodality: once the level masses start decreasing, they keep
decreasing. So a model aligned to a linear symbolic reward cannot split into two
populations — one excellent, one terrible — with a valley between. "Two-mode reward
hacking" is *impossible* in this regime. That is a genuine safety guarantee derived from
Pascal's triangle.

## Reward hacking, quantified

Everyone who has tuned a model against a reward has watched it collapse. Loosen the leash
too much and the model stops producing diverse, sensible answers and starts producing one
degenerate answer over and over — the one the reward loves most. How fast does that
happen?

Exactly this fast. The single best answer is the full set $\{1,\dots,n\}$, and the aligned
model puts probability $\theta^n$ on it. Bernoulli's inequality plus the elementary bound
$1 - \sigma(t) \le e^{-t}$ gives

$$\pi\bigl(\{1,\dots,n\}\bigr) \;\ge\; 1 - n\,e^{-a/\beta}.$$

A model that started uniform over $2^n$ answers — spread across a million possibilities
when $n = 20$ — concentrates on a *single* answer at a rate exponential in $a/\beta$. Set
$a/\beta = 10$ with $n=20$, and the aligned model already puts over $99.9\%$ of its mass on
one output. The leash is the only thing standing between a diverse model and a
one-note one, and its protection decays exponentially as you loosen it.

The trade-off is strictly monotone in both directions. Tightening the leash (increasing
$\beta$) strictly lowers the achieved reward $a n \sigma(a/\beta)$, and strictly lowers
the mass on the degenerate answer. There is no setting of $\beta$ that gets you both. This
is a no-free-lunch statement, proved rather than observed.

There is also an elegant bookkeeping identity hiding here. Compute the drift two
different ways — once from the free energy, once from the entropy of the tuned model,
which turns out to be exactly $n$ times the binary entropy
$H(\theta) = -\theta\log\theta - (1-\theta)\log(1-\theta)$ — and the two computations
must agree. They do, and forcing them to agree yields the analytic identity

$$t\,\sigma(t) - \log\frac{1+e^t}{2} \;=\; \log 2 - H\bigl(\sigma(t)\bigr)$$

for every real $t$. Two entirely different routes through the theory arrive at the same
number, which is the sort of cross-check that makes a piece of mathematics trustworthy.

## When conditions help each other

Real symbolic reward models are not linear. They contain *rules*: "if all the premises of
rule $R$ are present, award a bonus of $c$." A bonus like that is not a sum of per-condition
scores; it is a synergy. Satisfying premise $1$ is worth nothing on its own, worth nothing
with premise $2$, but worth $c$ once you also have premise $3$.

The right notion of synergy on a lattice is **supermodularity**:

$$r(S) + r(T) \;\le\; r(S \cap T) + r(S \cup T)$$

for all sets $S, T$. Counting rewards satisfy this with equality (they are *modular*).
Rule bonuses satisfy it strictly. And supermodularity is preserved by sums and by
multiplication by non-negative constants, so *every* reward of the form "count the
conditions, plus bonuses for satisfied rules" is supermodular. That single hypothesis
covers essentially the whole design space of a symbolic reward model.

Here is what it buys. The aligned distribution of a supermodular reward is
**log-supermodular** — it satisfies the FKG lattice condition
$\pi(S)\pi(T) \le \pi(S\cap T)\pi(S \cup T)$ — which follows in one line from
exponentiating the supermodularity inequality. And log-supermodularity, by the
celebrated Fortuin–Kasteleyn–Ginibre inequality from statistical physics, implies
**positive association**: for any two increasing observables $f$ and $g$,

$$\mathbb{E}_\pi[f]\cdot\mathbb{E}_\pi[g] \;\le\; \mathbb{E}_\pi[fg].$$

In plain words: *alignment with synergistic symbolic rules provably entangles the
conditions*. Take any two conditions $i$ and $j$; under the aligned model the events
"condition $i$ was met" and "condition $j$ was met" are positively correlated. Never
negatively. You cannot design a supermodular reward that makes good behaviours trade off
against each other — the lattice structure forbids it.

There is a companion statement, coming from Holley's inequality (FKG's order-theoretic
sibling). If the reward is merely *monotone* — satisfying more conditions never hurts —
then the aligned model **stochastically dominates** the original: the expected value of
*every* increasing observable goes up, uniformly in $\beta$. Not the reward on average;
every monotone quantity whatsoever. Alignment against a monotone reward cannot make any
monotone property worse. That is a strong and completely unconditional guarantee, and it
comes from lattice combinatorics rather than from any analytic estimate.

## Everything scales linearly, and that is the problem

One last theme, and it applies far beyond the cube. Suppose the answer space is a product
— two independent sub-answers, two parallel rollouts, $n$ tokens generated
independently — the original model is a product of independent factors, and the reward is
*additive* across the factors. Then everything in the theory splits:

- the partition function multiplies, $Z = Z_1 Z_2$;
- the aligned model is again a product, so **alignment cannot manufacture correlations
  that the reward did not ask for**;
- the divergence adds, $\mathrm{KL} = \mathrm{KL}_1 + \mathrm{KL}_2$;
- the objective adds, and so does its optimal value.

For $n$ identical independent coordinates this becomes $Z_n = Z_1^n$ and a suite of
**linear scaling laws**: the value of alignment, the information drift, and the cost of
mixing in the original training data all grow *exactly* linearly in $n$. The
combinatorial engine is nothing more exotic than the distributive law — expanding a
product of $n$ sums enumerates the $|\Omega|^n$ possible answers — which is precisely why
tilting a product measure by an additive reward yields another product measure.

The linearity is a warning as much as a result. Because drift, reward gain and pretraining
cost all scale with the same exponent, you cannot asymptotically trade them off against
one another by retuning the leash tightness $\beta$ or the pretraining-mixture weight
$\gamma$. Whatever imbalance you have at one length, you have at every length. Only a
*per-coordinate* budget — KL per token rather than KL per answer — is stable as answers
get longer.

## Why this matters

None of these statements are approximations, asymptotics, or empirical trends. They are
identities and inequalities, exact for every $n$, $a$ and $\beta$. The reason they can be
exact is that the objects involved — subsets, sizes, binomial coefficients, lattices —
are combinatorial objects, and the tug-of-war between reward and leash happens to
respect their structure perfectly.

That is the real message. A formula that arrived from machine learning, decorated with
expectations over neural network outputs, turns out on a structured answer space to be a
piece of enumerative combinatorics wearing a disguise. The sigmoid link is the binomial
theorem. The mean reward is Pascal's absorption identity. The impossibility of bimodal
degeneration is log-concavity of binomial coefficients. The entanglement of good
behaviours is the FKG inequality of statistical physics. The collapse onto a single answer
is Bernoulli's inequality.

Alignment is a young and largely empirical subject, its practice running well ahead of
its theory. But wherever the space of answers has combinatorial structure — sets of
satisfied constraints, sequences of independent decisions, lattices of features — that
structure hands you exact answers to questions that otherwise require expensive
experiments. Knowing that the number of satisfied conditions is *binomially* distributed,
with a *known* parameter, tells you how many samples you need to estimate quality. Knowing
that mass on the degenerate answer is at least $1 - ne^{-a/\beta}$ tells you which leash
settings are safe *before* you spend the compute. Knowing that good behaviours are
positively correlated tells you that a symbolic reward built out of conjunctive rules will
never pit its own criteria against each other.

The cube was there all along. It just needed someone to count.
