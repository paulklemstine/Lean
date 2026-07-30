# Bayesian One-Step Decisions in Social Deduction Games

**Aristotle**  
**July 30, 2026**

## Abstract

We study the decision problem faced by an uninformed faction in a finite social deduction game when it must select one player for elimination. Given a prior role probability and a likelihood for the observed evidence under each single-player role hypothesis, we define an unnormalized Bayesian score and its normalized posterior distribution. We prove that normalization preserves score order whenever the normalizing constant is positive. Our principal result is a one-step maximum-a-posteriori optimality theorem: eliminating a player of maximal posterior probability maximizes the conditional probability of eliminating a werewolf, not only among deterministic choices but among all randomized elimination rules. We also establish the exact success probability $k/n$ for uniform elimination when $k$ of $n$ players are werewolves, and show that under a common prior, likelihood ordering and posterior ordering coincide. Finally, we analyze the proposed scaling factor $C(1-k/(n-k))^2$: for $n=7$, $k=2$, and $C=1$, it is exactly $9/25=0.36$, while it vanishes at the parity threshold $n=2k$. These identities do not determine the value of a complete dynamic game. We distinguish immediate classification from full-horizon control and specify the additional modeling needed for simulation and backward induction.

## 1. Introduction

Social deduction games combine hidden state, strategic communication, sequential action, and asymmetric information. In Werewolf or Mafia, a minority knows the hidden roles while the majority attempts to identify that minority through public behavior. A typical round contains a night elimination controlled by the informed faction and a day elimination selected through public voting. The majority wins by eliminating all werewolves; the werewolves win when they equal or outnumber the villagers.

The natural Bayesian recommendation is to eliminate the player currently most likely to be a werewolf. That recommendation contains two logically distinct claims. The first is local: the action maximizes the probability that the present elimination is correct. The second is global: the action maximizes the probability that the villagers eventually win. Only the first follows from posterior maximization without further assumptions. The second depends on how actions alter future observations, strategic behavior, and continuation values.

This paper isolates the model-independent local result. The setup accepts any finite player set and any specified prior and evidence likelihood. It does not assume a particular psychological model of voting, speech, or survival. Once those quantities are supplied, the posterior is obtained by normalization. The central proof then reduces to a basic property of convex combinations: no weighted average exceeds its largest component.

This abstraction has two advantages. First, it states precisely what can be concluded independently of detailed game rules. Second, it exposes what remains unspecified in claims about complete-game win rates. A numerical value such as $0.36$ cannot be inferred from player counts alone; it requires a transition model, observation model, policies, and tie-breaking conventions. We therefore treat a proposed scaling law as an expression whose special-case arithmetic can be established exactly, not as an established law of game value.

The paper proceeds from definitions through one-step optimality, baselines, numerical methods, dynamic limitations, and applications. All probabilities below are conditional on the currently available public evidence unless stated otherwise.

## 2. Finite Bayesian model

### 2.1 Players, hypotheses, priors, and likelihoods

Let $I$ be a finite nonempty set of surviving players. For each $i\in I$, let $W_i$ denote the hypothesis that player $i$ is a werewolf. Let

$$
p_i=P(W_i)
$$

be the prior probability of that hypothesis, and let $E$ denote the observed evidence. Define

$$
\ell_i=P(E\mid W_i).
$$

The evidence may aggregate multiple events. Under an explicitly assumed conditional factorization, it may be written

$$
\ell_i=\prod_{t=1}^{T}P(E_t\mid E_1,\ldots,E_{t-1},W_i).
$$

The product is the chain rule when each factor conditions on the preceding evidence. Replacing those conditional factors by independent marginal factors is an additional modeling assumption and is not automatic.

The hypotheses $W_i$ need not be mutually exclusive when several werewolves exist. Accordingly, the normalization used here should be interpreted as a distribution over the candidate selected by the model for one-step targeting, or as normalized marginal scores. If $p_i$ and $\ell_i$ arise from a coherent joint role model, the resulting target probabilities must be interpreted consistently with that model. The optimization theorem itself requires only a finite list of normalized nonnegative target probabilities.

### 2.2 Scores and posteriors

**Definition 1 (Bayesian score).** The unnormalized Bayesian score of player $i$ is

$$
s_i=p_i\ell_i.
$$

Define the normalizing constant

$$
Z=\sum_{j\in I}s_j.
$$

**Definition 2 (Normalized posterior score).** If $Z\ne0$, define

$$
\pi_i=\frac{s_i}{Z}.
$$

For a probabilistic interpretation, one ordinarily assumes $p_i\ge0$, $\ell_i\ge0$, and $Z>0$. The algebraic normalization identity needs only $Z\ne0$; order preservation needs $Z>0$.

**Theorem 1 (Normalization).** If $Z\ne0$, then the normalized scores sum to one:

$$
\sum_{i\in I}\pi_i=1.
$$

**Proof sketch.** Substitute $\pi_i=s_i/Z$, factor the common denominator from the finite sum, and use the definition of $Z$:

$$
\sum_i\pi_i=\sum_i\frac{s_i}{Z}=\frac{\sum_i s_i}{Z}=\frac{Z}{Z}=1.
$$

The nonzero assumption makes the final quotient defined. $\square$

**Lemma 1 (Order preservation under positive normalization).** Suppose $Z>0$. If $s_i\le s_m$, then $\pi_i\le\pi_m$.

**Proof sketch.** Division by a common positive number preserves inequalities, so

$$
\frac{s_i}{Z}\le\frac{s_m}{Z}.
$$

These two quotients are $\pi_i$ and $\pi_m$. $\square$

This elementary lemma is the bridge from evidence scoring to decision theory. Computing the denominator is unnecessary if one needs only the identity of a maximizing player.

### 2.3 Uniform priors

If the initial assignment is exchangeable with exactly $k$ werewolves among $n$ players, then each player has marginal prior

$$
p_i=\frac{k}{n}.
$$

More generally, suppose all candidates share a common prior $c\ge0$.

**Theorem 2 (Likelihood ordering under a common prior).** Let $p_i=c$ for all $i$, with $c\ge0$, and suppose $Z>0$. If $\ell_i\le\ell_m$, then $\pi_i\le\pi_m$.

**Proof sketch.** Multiplication by $c\ge0$ preserves order, giving $c\ell_i\le c\ell_m$. These products are the scores $s_i$ and $s_m$. Lemma 1 then yields the posterior inequality. $\square$

Thus, under a uniform prior, selecting a maximum-posterior candidate is equivalent to selecting a maximum-likelihood candidate. This does not mean the common prior is irrelevant to every quantity; it means it is irrelevant to ranking.

## 3. One-step elimination as a decision problem

### 3.1 Deterministic and randomized rules

A deterministic rule selects one player $m\in I$. Its conditional one-step success probability is $\pi_m$.

A randomized elimination rule is a probability mass function $q:I\to[0,1]$ satisfying

$$
q_i\ge0
\qquad\text{and}\qquad
\sum_{i\in I}q_i=1.
$$

The rule first samples a target according to $q$. Its conditional success probability is

$$
S(q)=\sum_{i\in I}q_i\pi_i.
$$

This expression is linear in $q$. The feasible rules form a simplex, and deterministic rules are its vertices.

### 3.2 Maximum-posterior optimality

**Theorem 3 (One-Step Maximum-Posterior Elimination Theorem).** Assume $Z>0$, and let $m$ be a player with maximal Bayesian score:

$$
s_i\le s_m\quad\text{for every }i\in I.
$$

Then for every randomized elimination rule $q$,

$$
S(q)=\sum_{i\in I}q_i\pi_i\le\pi_m.
$$

Consequently, deterministically eliminating $m$ maximizes the conditional probability that the current elimination removes a werewolf.

**Proof sketch.** Lemma 1 gives $\pi_i\le\pi_m$ for every $i$. Since $q_i\ge0$, multiplication preserves each inequality:

$$
q_i\pi_i\le q_i\pi_m.
$$

Summing over all players and using $\sum_iq_i=1$ gives

$$
S(q)
\le\sum_iq_i\pi_m
=\pi_m\sum_iq_i
=\pi_m.
$$

The deterministic rule concentrated at $m$ attains equality. $\square$

**Corollary 1 (Randomization cannot strictly improve one-step success).** No lottery over players has a greater one-step success probability than a deterministic maximum-posterior choice.

**Proof sketch.** This is the final inequality of Theorem 3, together with attainability by placing probability one on $m$. $\square$

**Corollary 2 (Characterization of optimal lotteries).** Assume the posteriors are nonnegative. A randomized rule is one-step optimal if all of its probability is supported on players attaining the maximal posterior. Conversely, any rule assigning positive probability to a strictly submaximal player is strictly suboptimal.

**Proof sketch.** A weighted average equals its maximum when every component receiving positive weight equals that maximum. If a strictly smaller component receives positive weight, the average is strictly below the maximum. $\square$

The theorem is a finite decision-theoretic result, not a claim about equilibrium play. It requires no assumption about how wolves or villagers generated the evidence. Such assumptions enter upstream through the likelihoods.

## 4. Uniform elimination baseline

Let $I$ contain $n$ players, and let $A\subseteq I$ be the set of werewolves with $|A|=k$. Under uniform elimination, every player is selected with probability $1/n$.

**Theorem 4 (Uniform-elimination success).** The probability that uniform elimination selects a werewolf is exactly

$$
\frac{k}{n}.
$$

**Proof sketch.** Sum $1/n$ over the werewolf set and $0$ over its complement:

$$
\sum_{i\in I}
\begin{cases}
1/n,&i\in A,\\
0,&i\notin A
\end{cases}
=
\sum_{i\in A}\frac1n
=rac{|A|}{n}
=rac{k}{n}.
$$

$\square$

This baseline has a different interpretation from the posterior maximum. The value $k/n$ is an ex ante success probability based only on role counts. The posterior maximum is conditional on evidence and may vary by information state. Under a coherent posterior whose average marginal wolf probability is $k/n$, the largest posterior is at least the average, but care is needed when normalized candidate scores are not literal marginal role probabilities.

For $n=7$ and $k=2$, uniform elimination succeeds with probability

$$
\frac27\approx0.285714.
$$

## 5. The proposed scaling expression

Consider the proposed family

$$
F(n,k;C)=C\left(1-\frac{k}{n-k}\right)^2,
$$

where $n>k$ and $C$ represents dependence on the information structure. This expression is intended as a possible approximation to a full-game villager win probability, not a consequence of the one-step theorem.

**Theorem 5 (Seven-player identity).** For $n=7$, $k=2$, and $C=1$,

$$
F(7,2;1)=\frac9{25}=0.36.
$$

**Proof sketch.** Direct simplification gives

$$
\left(1-\frac{2}{7-2}\right)^2
=\left(1-\frac25\right)^2
=\left(\frac35\right)^2
=\frac9{25}.
$$

$\square$

**Theorem 6 (Vanishing at parity).** For every nonzero real $k$,

$$
\left(1-\frac{k}{2k-k}\right)^2=0.
$$

**Proof sketch.** Since $k\ne0$, the denominator $2k-k=k$ is nonzero. Hence the fraction is $k/k=1$, and the expression is $(1-1)^2=0$. $\square$

An equivalent form exposes the geometry:

$$
1-\frac{k}{n-k}=\frac{n-2k}{n-k},
$$

so

$$
F(n,k;C)=C\frac{(n-2k)^2}{(n-k)^2}.
$$

The numerator is the square of the population margin between the total population and twice the wolf count. Vanishing at $n=2k$ is therefore built into the algebra. The square also makes the expression nonnegative whenever defined. Neither property validates the expression as a stochastic-game value function.

## 6. Algorithms

### 6.1 Posterior computation and target selection

Given arrays of priors and likelihoods, compute $s_i=p_i\ell_i$, sum the scores to obtain $Z$, reject the input if $Z\le0$ for probabilistic use, normalize, and return any maximizing index. This procedure takes $O(n)$ time and $O(n)$ storage if all posteriors are retained. If only the target is needed, normalization can be omitted and the maximum score found in $O(n)$ time and $O(1)$ auxiliary storage.

Numerical implementations should use log scores when products of many small likelihood factors may underflow:

$$
\log s_i=\log p_i+\sum_t\log P(E_t\mid E_{<t},W_i).
$$

Subtracting the largest log score before exponentiation yields a stable log-sum-exp normalization.

### 6.2 Evaluating randomized policies

For a proposed rule $q$, first verify $q_i\ge0$ and $\sum_iq_i=1$ within numerical tolerance. Compute

$$
S(q)=q\cdot\pi.
$$

Compare this with $\max_i\pi_i$. Theorem 3 guarantees $S(q)\le\max_i\pi_i$ under valid inputs. This is $O(n)$ time.

### 6.3 Evaluating the scaling factor

For $n>k$, evaluate

$$
C\left(1-\frac{k}{n-k}\right)^2.
$$

Exact rational arithmetic is preferable for small integer cases because it preserves identities such as $9/25$. The formula is undefined at $n=k$ and should not be used outside a clearly stated parameter regime. If interpreted as a probability approximation, values must also be checked against $[0,1]$; the algebra alone does not enforce that range for arbitrary $C,n,k$.

## 7. Numerical illustration

Consider seven candidates with common prior $2/7$ and likelihood vector

$$
\ell=(0.12,0.08,0.25,0.10,0.18,0.09,0.18).
$$

Because the likelihoods sum to one and the prior is common, the normalized posterior equals this vector. The maximum-posterior action targets candidate $3$ and has one-step success probability $0.25$.

A lottery assigning probability $1/2$ to candidate $3$ and $1/2$ to candidate $5$ has success

$$
S(q)=\frac12(0.25)+\frac12(0.18)=0.215.
$$

The uniform lottery over candidates has success

$$
S(q)=\frac17\sum_i\pi_i=\frac17\approx0.142857
$$

under this normalized single-target model. This value should not be confused with the role-count baseline $2/7$. The difference illustrates an important modeling issue: a posterior distribution normalized across mutually exclusive target hypotheses sums to one, whereas the marginal probabilities that each of seven players is among two wolves sum to two. A complete multi-wolf Bayesian model must respect that distinction.

For a marginal-probability illustration, consider

$$
r=(0.20,0.18,0.45,0.22,0.35,0.25,0.35),
$$

whose entries sum to $2$. Uniform targeting succeeds with the average $2/7$, while targeting candidate $3$ succeeds with probability $0.45$. The same weighted-average argument establishes maximum-marginal targeting as the one-step optimum.

The numerical examples are diagnostic rather than empirical estimates. They show the theorem’s mechanics for specified inputs; they do not claim that these likelihoods describe human play.

## 8. Why one-step optimality is not full-game optimality

Let a public history $h$ encode all revealed actions and observations. A complete finite-horizon model must specify a hidden role state, legal day and night actions, behavioral strategies, an observation kernel, transition probabilities, terminal events, and utilities. If $a$ is a day elimination and $h'$ a subsequent history, a value function has the form

$$
V(h)=\max_a\sum_{h'}P(h'\mid h,a)V(h'),
$$

with terminal value $1$ for villager victory and $0$ for werewolf victory. The maximizing action depends on continuation values $V(h')$, not solely on the immediate probability that $a$ removes a wolf.

An action can have lower immediate success but greater information value. Eliminating one player may reveal a role, split a voting coalition, or change which night target is attractive. Conversely, an immediate high-probability target may destroy a source of information or induce an unfavorable transition. Therefore a theorem identifying the best immediate classification action does not establish global control optimality.

A global maximum-posterior theorem would require additional structural conditions. One possible condition would be that continuation value depends on the current action only through whether the eliminated player is a wolf, with a fixed advantage for success independent of player identity and history. Under such a condition, maximizing immediate wolf probability would also maximize continuation value. Real social deduction models generally violate this simplification because identities and information pathways matter.

## 9. Simulation protocol for a complete model

A reproducible simulation must specify more than $n$ and $k$. At minimum it must define:

1. the distribution over hidden role assignments;
2. the order of night and day actions;
3. the wolf policy for selecting night victims;
4. the villager ballot policy and its tie-breaking rule;
5. whether eliminated roles are revealed;
6. the evidence extracted from votes, speech, and survival;
7. the likelihood model or estimator used for updating;
8. behavior when several players maximize the posterior; and
9. the exact terminal conditions.

After fixing these choices, repeated independent games can estimate a win probability. If $X_r$ is the indicator of villager victory in trial $r$, the estimator is

$$
\widehat{P}_N=\frac1N\sum_{r=1}^{N}X_r.
$$

Its estimated standard error is

$$
\sqrt{\frac{\widehat{P}_N(1-\widehat{P}_N)}{N}}.
$$

For large $N$, an approximate $95\%$ interval is

$$
\widehat{P}_N\pm1.96
\sqrt{\frac{\widehat{P}_N(1-\widehat{P}_N)}{N}}.
$$

Near $\widehat{P}_N=0.36$ with $N=10^6$, the standard error is about $0.00048$, but this quantifies Monte Carlo sampling error only. It does not account for misspecified behavior or likelihoods.

Testing the scaling proposal requires varying $k$ for each $n$, estimating $C$ rather than fixing it from a single point, and comparing residuals against alternative finite-size models. Data at $n=7$ through $20$ with only one $k$ per $n$ cannot cleanly distinguish dependence on wolf fraction from dependence on population size.

## 10. Applications beyond games

The one-step theorem is an instance of a general classification principle. If an action selects one candidate and reward is one exactly when that candidate has a target property, expected reward equals the candidate’s posterior probability. A maximum-posterior action is therefore Bayes-optimal under zero-one loss.

In fraud screening, if one account can be audited and all audits have equal cost and downstream effect, auditing the account with the largest fraud posterior maximizes the immediate detection probability. In cybersecurity, if one endpoint can be isolated and isolation has symmetric consequences, choosing the endpoint with the highest compromise posterior is locally optimal. In diagnosis, if one mutually exclusive condition must be named under zero-one loss, the maximum-posterior diagnosis minimizes immediate error.

The limitations transfer as well. Audits teach investigators, isolations change attackers’ behavior, and medical tests produce information. Once actions have unequal costs or future effects, the objective becomes expected utility or dynamic value rather than posterior probability alone.

## 11. Discussion

The results identify a robust mathematical core beneath informal advice. Bayesian scores combine prior plausibility with evidential fit. Positive normalization converts those scores into a distribution without changing their order. Linear expectation then makes a maximal posterior optimal for the immediate hit objective, and shows that randomization cannot outperform a deterministic maximizer.

Several boundaries deserve emphasis. First, likelihoods are inputs, not conclusions. They must be learned or postulated from a behavioral model. Second, with multiple wolves, normalized candidate scores and marginal role probabilities are conceptually different objects. Third, the arithmetic equality $0.36=9/25$ at $(n,k)=(7,2)$ does not establish an actual win rate. Fourth, a full-game optimum is a policy over information states, not a single ranking rule.

These qualifications strengthen rather than weaken the result. They make the theorem reusable wherever its assumptions hold and prevent a local decision principle from being overextended into an unsupported strategic claim.

## 12. Future work

The next step is to define a complete finite-horizon stochastic game with hidden role assignments, public histories, night actions, ballots, behavioral strategies, observations, and terminal win events. An explicit likelihood model for voting and survival evidence is indispensable.

Once the model is fixed, backward induction can compute the value function and compare its maximizing action with the maximum-posterior action at every reachable information state. Agreement would establish global optimality for that model; disagreement would produce a concrete counterexample and quantify the value of information.

Simulation should follow only after tie-breaking, role revelation, action order, and all policies are fixed. Report confidence intervals and conduct sensitivity analysis. To investigate the scaling expression, vary $k$ within each $n$, estimate both $C$ and the exponent, and compare against alternative models. The exact seven-player and parity identities provide useful checks for software and algebra, but not validation of the approximation.

## 13. Conclusion

For a finite set of candidates with positive total Bayesian score, score normalization preserves ranking. A player with maximal prior-times-likelihood score has maximal posterior probability. Deterministically eliminating such a player maximizes the conditional probability of an immediate werewolf elimination among every randomized policy. Uniform elimination has exact success probability $k/n$ when $k$ of $n$ players are wolves.

The proposed factor $(1-k/(n-k))^2$ equals $9/25=0.36$ for seven players and two wolves, and equals zero at parity. These exact statements concern the expression itself. Determining complete-game win probabilities requires a specified stochastic game and a dynamic value calculation. The central lesson is therefore precise: maximum-posterior elimination is the optimal answer to the one-step question, while optimal play over the entire game remains a problem of sequential information and control.
