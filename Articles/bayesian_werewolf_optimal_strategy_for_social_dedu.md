# Bayesian Werewolf: What the Village Should Do Next

A village goes to sleep with seven people alive. Two are secretly werewolves. By morning, one villager will be gone. During the day, everyone will argue, accuse, defend, and finally vote to eliminate a suspect. The villagers possess no direct test for guilt; they have only behavior. Who voted with whom? Who survived? Whose story changed? In this setting, suspicion is not merely a feeling. It can be treated as a probability.

That simple observation leads to a precise answer to one important question: **if the village’s sole objective for the current vote is to eliminate a werewolf, it should choose a player with the largest posterior probability of being a werewolf.** No lottery over suspects can do better for that one vote.

The qualification “for the current vote” matters. Werewolf is a dynamic game. Today’s choice changes tomorrow’s information, alliances, and strategic incentives. A locally best elimination need not always be the move that maximizes the chance of ultimately winning. The mathematics here cleanly establishes the local result, explains why randomization cannot improve it, and marks the boundary between one-step Bayesian judgment and full-game strategy.

## Turning suspicion into a score

Let the surviving players form a finite set. For each player $i$, assign a prior probability $p_i$ that the player is a werewolf before the latest evidence is considered. Also assign a likelihood $\ell_i$, meaning the probability of observing the available evidence under the hypothesis that player $i$ is a werewolf.

The evidence might include ballots, statements, survival, or any other modeled observation. The mathematics does not prescribe the behavioral model that produces $\ell_i$; it begins once those likelihoods have been specified.

Bayes’ rule says to multiply prior plausibility by evidential fit. Define the unnormalized score

$$
s_i=p_i\ell_i.
$$

If the total score

$$
Z=\sum_j s_j
$$

is positive, the posterior probability assigned to player $i$ is

$$
\pi_i=\frac{s_i}{Z}.
$$

The normalization has exactly the expected effect:

$$
\sum_i \pi_i=\frac{\sum_i s_i}{Z}=1.
$$

Thus the scores become a probability distribution. Just as importantly, every score is divided by the same positive number. Therefore score order and posterior order agree: if $s_i\le s_m$, then $\pi_i\le\pi_m$. A player with the highest score also has the highest posterior probability.

When roles are initially assigned uniformly among $n$ players with exactly $k$ werewolves, every player begins with the same prior $k/n$. In that case,

$$
s_i=\frac{k}{n}\ell_i,
$$

so posterior ranking is simply likelihood ranking. The common prior changes the numerical normalization but not whom the evidence ranks first.

## The one-step optimality theorem

Suppose player $m$ has maximal score, so that $s_i\le s_m$ for every player $i$. The village might eliminate $m$ with certainty. Or it might randomize: choose player $i$ with probability $q_i$, where

$$
q_i\ge 0
\qquad\text{and}\qquad
\sum_i q_i=1.
$$

Conditional on the evidence, the chance that this randomized elimination hits a werewolf is

$$
\sum_i q_i\pi_i.
$$

Because $\pi_i\le\pi_m$ for every $i$, each weighted term satisfies $q_i\pi_i\le q_i\pi_m$. Summing gives

$$
\sum_i q_i\pi_i
\le \sum_i q_i\pi_m
=\pi_m\sum_i q_i
=\pi_m.
$$

This is the **One-Step Maximum-Posterior Elimination Theorem**: among all deterministic and randomized elimination rules, choosing a maximum-posterior player maximizes the conditional probability that today’s elimination removes a werewolf.

The proof is short because the underlying geometry is simple. A weighted average cannot exceed the largest number being averaged. Randomization mixes posterior probabilities; it cannot manufacture a value above their maximum.

Ties cause no difficulty. If several players share the largest posterior, any one of them is optimal. A lottery supported entirely on those tied leaders is also optimal. Randomization is harmless in a tie, but it provides no strict improvement.

## A seven-player example

Imagine seven surviving players with two werewolves. The uniform prior for each player is $2/7$. Suppose a voting-pattern model gives the likelihoods

$$
(0.12,0.08,0.25,0.10,0.18,0.09,0.18).
$$

Their sum is $1$, so multiplication by the common prior and subsequent normalization leaves these numbers unchanged as posterior probabilities. Player $3$ has posterior $0.25$, the largest value. Eliminating player $3$ therefore succeeds with probability $0.25$ under this model.

Suppose instead that the village flips a fair coin between players $3$ and $5$. Its success probability becomes

$$
\frac12(0.25)+\frac12(0.18)=0.215,
$$

which is lower. A uniform lottery over all seven players has success probability

$$
\frac17\sum_i\pi_i=\frac17.
$$

The best informed choice beats both lotteries for the current decision.

There is also a model-independent baseline. If exactly $k$ of $n$ players are werewolves and one player is selected uniformly, then the chance of selecting a werewolf is exactly

$$
\frac{k}{n}.
$$

This follows by adding $1/n$ once for each of the $k$ werewolves. For $n=7$ and $k=2$, the random baseline is $2/7$, approximately $0.286$. A posterior policy improves on this baseline only when the evidence concentrates enough probability on its leading suspect.

## The alluring number $0.36$

A proposed approximation for the villagers’ eventual win probability has the form

$$
C\left(1-\frac{k}{n-k}\right)^2,
$$

where $C$ is intended to capture the information structure. The expression has two exact and illuminating arithmetic features.

For $n=7$, $k=2$, and $C=1$,

$$
\left(1-\frac{2}{7-2}\right)^2
=\left(1-\frac25\right)^2
=\left(\frac35\right)^2
=\frac9{25}
=0.36.
$$

At the parity threshold $n=2k$, where werewolves occupy half the population,

$$
\left(1-\frac{k}{2k-k}\right)^2
=\left(1-1\right)^2
=0
$$

for $k\ne0$. These are exact identities, not evidence that the formula predicts a full game. The appearance of $0.36$ in the seven-player case is a consistency check for the proposed expression when $C=1$; it is not a derivation of the villagers’ actual win probability.

That distinction is essential because the full-game probability is not determined until the rules and behavior are completely specified. Do eliminated roles become public? How do wolves select a night target? How are tied ballots resolved? How do players translate voting histories into likelihoods? Do villagers coordinate? Different answers define different games and can produce different values.

## Why the best move now may not be the best plan

The one-step theorem optimizes a clear quantity: the chance that the next eliminated player is a werewolf. Eventual victory is a different objective.

Consider a stylized situation in which one suspect is slightly more likely to be a wolf, while eliminating another player would reveal far more information about the remaining group. The first action may maximize today’s hit probability; the second might improve all later decisions enough to raise the total chance of victory. Strategic opponents complicate matters further: wolves may manipulate ballots precisely because they know how villagers update beliefs.

To solve the complete game, one must define a state containing the public history and the players’ beliefs, specify legal actions and transition probabilities, and assign terminal values to villager and werewolf victories. A value function can then be computed backward from terminal states. At each information state, the optimal action maximizes expected continuation value—not necessarily immediate hit probability.

This is a familiar divide across decision science. Medical triage distinguishes the most likely diagnosis from the test with the greatest future informational value. Cybersecurity distinguishes blocking the most suspicious account from observing it to expose a network. Fraud investigation distinguishes the transaction most likely to be fraudulent from the intervention that best disrupts a criminal strategy. In every case, maximum posterior probability answers “which hypothesis is most likely now?” Dynamic control asks “which action creates the best future?”

## What has been established

The rigorous core can be summarized in five statements.

First, prior times likelihood gives an unnormalized Bayesian score. Second, if the total score is nonzero, normalized scores sum to one. Third, when the total score is positive, score ranking and posterior ranking coincide. Fourth, deterministically choosing a maximum-posterior player is optimal for the one-step objective, and no randomized rule can improve its success probability. Fifth, uniform elimination hits one of $k$ werewolves among $n$ players with probability exactly $k/n$.

Alongside these decision results, the proposed scaling factor equals exactly $9/25=0.36$ for seven players and two wolves when $C=1$, and it vanishes exactly at parity. Those arithmetic facts clarify the conjecture’s shape while leaving its empirical and strategic validity open.

The result is both useful and disciplined. It converts a folk strategy—“vote for the most suspicious player”—into a theorem for a precisely stated objective. It also refuses to claim more than that theorem proves. Bayesian reasoning identifies the best immediate target once priors and likelihoods are given. Whether the same action is optimal for winning the entire game is the next, richer question: one that requires a complete model of information, behavior, and time.

## The discipline of evidence

The framework also highlights that Bayes’ rule does not create information; it organizes information supplied by a model. Calling a silence, a ballot, or survival “suspicious” is not yet a likelihood. One needs conditional probabilities describing how often that observation would arise under competing role hypotheses. If those probabilities are poorly estimated, the posterior can be precise-looking but misleading. Good play therefore has two layers: construct a credible evidence model, then apply the decision rule correctly.

That observation suggests a careful experimental program. Fix every gameplay convention and every behavioral policy, simulate complete games, and report uncertainty intervals rather than isolated percentages. Vary both $n$ and $k$, estimate the constant $C$ independently of the proposed exponent, and compare the square law against plausible finite-size alternatives. Most importantly, compare maximum-posterior actions with actions selected by backward induction. Such experiments could reveal where the simple rule remains globally optimal, where it is merely a strong heuristic, and where information-seeking moves decisively outperform it.

The village’s problem is dramatic because mistakes remove voices from the table, but its mathematical lesson is universal. Beliefs should be updated by evidence, actions should be matched to objectives, and a theorem about the next move should never be mistaken for a theorem about the whole future.
