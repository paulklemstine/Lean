# Bayesian Werewolf: Local Posterior Optimality, Symmetric Continuation Value, and Spin Symmetry

## Abstract

Social-deduction games motivate a basic sequential decision question: should a decision maker always act against the player with the largest posterior probability of holding a hidden adversarial role? We isolate the valid local principle from the stronger global claim. In a finite Bayesian model, normalized prior-times-likelihood weights form a posterior distribution, and their ordering agrees with that of the unnormalized weights whenever the evidence mass is positive. Eliminating a maximum-a-posteriori suspect maximizes the probability of an immediately correct elimination. For continuation utility that assigns a common value $G$ to every correct elimination and a common value $B$ to every incorrect elimination, expected value is the affine function $B+(G-B)p_a$ of the selected suspect’s posterior $p_a$. Consequently, if $B\le G$, every maximum-a-posteriori action maximizes continuation value. The same identity yields a sharp approximation-regret bound of $(G-B)\varepsilon$. We show by an explicit two-suspect example that identity symmetry is essential: a lower-posterior action can have much greater expected value when correct-hit rewards depend on identity. Finally, the centered posterior score $s(p)=2p-1$ preserves posterior order and turns role complementation into spin flip. Constant posterior fields therefore have magnetization equal to lattice size times centered posterior, with complementation reversing its sign. The results provide a precise foundation for Bayesian voting while delimiting what cannot be concluded about full-game win probabilities without an explicit sequential model.

## 1. Introduction

Games such as Werewolf and Mafia combine hidden roles, public actions, strategic deception, and repeated elimination. A typical informal prescription tells the uninformed team to vote for the player most likely to be an adversary. This prescription mixes two claims:

1. the selected player is most likely to be an adversary; and
2. selecting that player maximizes the probability of eventually winning.

The first claim is a classification decision. The second is a sequential control decision. They coincide under important conditions, but not automatically. The distinction is familiar in decision theory: posterior probability quantifies belief, whereas expected utility combines belief with consequences.

This paper develops the finite mathematics needed to state that distinction exactly. We treat a finite set of mutually exclusive role hypotheses. Priors and likelihoods produce posterior probabilities through normalization. The immediate utility for a correct elimination is represented by a zero-one indicator. A more general continuation model assigns value $G$ to a hit and $B$ to a miss, independently of the chosen identity. This exchangeability makes continuation value affine in the posterior coordinate of the chosen player, and monotonicity then proves global optimality for the decision stage.

The symmetry assumption is also shown to be necessary for any unconditional claim of this form. With two suspects having posterior probabilities $3/5$ and $2/5$, identity-dependent hit rewards can make the lower-posterior suspect preferable by a wide margin. Thus maximum-posterior selection is a theorem about immediate correctness and symmetric consequences, not a universal theorem about arbitrary games.

A second theme is representational. The centered posterior $2p-1$ has the algebra of a mean spin: posterior order is preserved, while swapping a role with its complement reverses the score. This creates a direct bridge to spin systems and suggests models of correlated suspicion based on interacting variables.

The contribution is deliberately foundational. No particular seven-player win probability and no asymptotic scaling law follows without specifying transition rules, observation channels, and strategic behavior. Instead, the analysis identifies which conclusions hold for every finite posterior and which require further game structure.

## 2. Finite Bayesian model

### 2.1 Hypotheses, priors, and evidence

Let $I$ be a finite, nonempty set of suspects. The elementary hypothesis indexed by $i\in I$ is that $i$ is the hidden target relevant to the present decision. In the simplest reading, exactly one listed player is the werewolf to be found. In a game with several werewolves, the same model can describe a marginal one-target decision, but dependencies between role assignments then require a larger joint state space for a complete analysis.

Let

$$
\pi:I\to\mathbb R
$$

be a prior weight and

$$
L:I\to\mathbb R
$$

be a likelihood for the observed evidence. Standard probabilistic use assumes $\pi_i\ge 0$ and $L_i\ge 0$, although the normalization identity below only needs nonzero total mass. Define the unnormalized Bayesian weight

$$
w_i=\pi_iL_i
$$

and evidence mass

$$
Z=\sum_{j\in I}w_j.
$$

Whenever $Z\neq 0$, define the posterior coordinate

$$
p_i=\frac{w_i}{Z}.
$$

If priors and likelihoods are probabilistically valid and at least one hypothesis has positive weight, then $Z>0$ and $(p_i)_{i\in I}$ is a probability distribution.

### Theorem 1 (Finite posterior normalization)

If $Z\neq 0$, then

$$
\sum_{i\in I}p_i=1.
$$

**Proof sketch.** Substitute $p_i=w_i/Z$, factor the common denominator out of the finite sum, and use $\sum_iw_i=Z$:

$$
\sum_i p_i=\frac{\sum_iw_i}{Z}=\frac ZZ=1.
$$

The nonzero-mass condition is exactly what makes the final division valid.

### Theorem 2 (Positive normalization preserves order)

If $Z>0$, then for every $i,j\in I$,

$$
p_i\le p_j\quad\Longleftrightarrow\quad w_i\le w_j.
$$

**Proof sketch.** Both posterior coordinates have the same positive denominator $Z$. Multiplication by $Z$ preserves inequalities, yielding the equivalence.

This theorem justifies comparing log-scores or unnormalized scores in implementations. Normalization is needed for calibrated probabilities, but not for selecting an argmax.

### 2.2 Maximum-a-posteriori actions

A suspect $a\in I$ is called **maximum-a-posteriori**, abbreviated MAP, if

$$
p_i\le p_a\qquad\text{for every }i\in I.
$$

### Lemma 3 (Existence of a MAP action)

Every real-valued posterior score on a finite nonempty suspect set has at least one MAP action.

**Proof sketch.** The finite set $\{p_i:i\in I\}$ is nonempty and therefore has a maximum. Any index attaining that maximum is MAP.

MAP actions need not be unique. All subsequent optimality statements apply to every maximizer.

## 3. Immediate correctness

Define the correctness utility for selecting $a$ when the true hidden identity is $w$ by

$$
u_{\mathrm{hit}}(a,w)=
\begin{cases}
1,&a=w,\\
0,&a\ne w.
\end{cases}
$$

For any utility function $u:I\times I\to\mathbb R$, define posterior expected utility by

$$
U_p(a;u)=\sum_{w\in I}p_wu(a,w).
$$

### Lemma 4 (Expected correctness identity)

For every action $a\in I$,

$$
U_p(a;\nu_{\mathrm{hit}})=p_a.
$$

**Proof sketch.** Every summand vanishes except the term with $w=a$, whose utility is $1$. The remaining term is $p_a$.

### Theorem 5 (Local MAP Optimality Theorem)

If $a$ is MAP, then for every action $b\in I$,

$$
U_p(b;\nu_{\mathrm{hit}})\le U_p(a;\nu_{\mathrm{hit}}).
$$

Equivalently, a MAP elimination maximizes the probability that the present elimination is correct.

**Proof sketch.** By Lemma 4, the two expected utilities are $p_b$ and $p_a$. The defining property of a MAP action gives $p_b\le p_a$.

The theorem is distribution-free: it does not depend on how the posterior was obtained. Voting patterns, survival information, speech acts, or any other evidence may determine $L_i$; once a posterior is available, the result follows.

The theorem is also local. It evaluates a hit indicator, not the eventual outcome of a multi-round game. Conflating these objectives is the central error addressed next.

## 4. Identity-symmetric continuation

### 4.1 Definition and affine representation

Let $G\in\mathbb R$ be the continuation value after a correct elimination and $B\in\mathbb R$ the continuation value after an incorrect elimination. Define the **identity-symmetric continuation utility**

$$
u_{G,B}(a,w)=
\begin{cases}
G,&a=w,\\
B,&a\ne w.
\end{cases}
$$

The adjective “identity-symmetric” means that all correct eliminations share the same continuation value and all incorrect eliminations share another. The utility may summarize the probability of eventual village victory, a discounted reward, or any scalar value-to-go, but it may not depend on which named player was selected beyond hit versus miss.

### Theorem 6 (Affine Continuation Formula)

If $\sum_{i\in I}p_i=1$, then for every $a\in I$,

$$
U_p(a;\nu_{G,B})=B+(G-B)p_a.
$$

**Proof sketch.** Separate the true state $w=a$ from all others:

$$
U_p(a;\nu_{G,B})=p_aG+\sum_{w\ne a}p_wB.
$$

Normalization gives $\sum_{w\ne a}p_w=1-p_a$, so

$$
p_aG+(1-p_a)B=B+(G-B)p_a.
$$

The formula shows that symmetric continuation utility is a modular, one-coordinate function of the posterior. All strategic detail is compressed into the slope $G-B$ and intercept $B$.

### 4.2 Guarded global optimality

### Theorem 7 (Symmetric Continuation Optimality Theorem)

Assume $\sum_i p_i=1$ and $B\le G$. If $a$ is MAP, then for every $b\in I$,

$$
U_p(b;\nu_{G,B})\le U_p(a;\nu_{G,B}).
$$

Thus every MAP action maximizes continuation value whenever a correct elimination is at least as valuable as an incorrect one and continuation is identity-symmetric.

**Proof sketch.** By Theorem 6,

$$
U_p(a;\nu_{G,B})-U_p(b;\nu_{G,B})=(G-B)(p_a-p_b).
$$

Both factors are nonnegative: $G-B\ge 0$ by assumption, and $p_a-p_b\ge 0$ because $a$ is MAP. Their product is therefore nonnegative.

The qualifier “guarded” is important. If $G=B$, every action has the same value. If $G<B$, the ordering reverses and minimizing the posterior maximizes utility, reflecting a perverse objective in which a miss is preferred. Under the natural condition $B\le G$, posterior ranking and utility ranking agree.

### 4.3 Interpretation in a sequential game

Suppose a belief state summarizes all public evidence at the start of a day. For each possible action, a complete dynamic model would average over immediate role uncertainty, subsequent night actions, future observations, and later votes. Theorem 7 applies when this entire value-to-go collapses to two identity-independent numbers: $G$ after a hit and $B$ after a miss.

This condition can hold in an exchangeable abstraction where surviving identities are strategically indistinguishable once hit versus miss is known. It may fail if:

- different werewolves have different powers;
- eliminating a particular player reveals more information;
- social influence differs by identity;
- voting histories create identity-specific future coalitions;
- survival changes the likelihood of later observations; or
- the action itself changes future policies in an identity-dependent way.

The theorem therefore supplies a sufficient structural criterion, not a blanket characterization of every social-deduction game.

## 5. Approximate posterior decisions

Exact Bayesian computation may be expensive, evidence models may be misspecified, and human players may only identify a near-maximal suspect. The affine continuation formula yields a quantitative stability statement.

### Theorem 8 (Posterior Approximation Regret Bound)

Assume $\sum_i p_i=1$ and $B\le G$. Let $a,b\in I$ satisfy

$$
p_a\le p_b+\varepsilon.
$$

Then

$$
U_p(a;\nu_{G,B})-U_p(b;\nu_{G,B})\le (G-B)\varepsilon.
$$

In particular, if $a$ is an exact MAP action and $b$ is within $\varepsilon$ of its posterior, choosing $b$ loses at most $(G-B)\varepsilon$ continuation value.

**Proof sketch.** Theorem 6 gives

$$
U_p(a;\nu_{G,B})-U_p(b;\nu_{G,B})=(G-B)(p_a-p_b).
$$

The posterior assumption implies $p_a-p_b\le\varepsilon$. Multiplication by the nonnegative factor $G-B$ preserves the inequality.

The bound is sharp whenever $p_a-p_b=\varepsilon$. It separates inferential accuracy from decision sensitivity. The approximation gap $\varepsilon$ measures ranking error, while $G-B$ measures the marginal value of correctness.

## 6. Failure without identity symmetry

A global MAP principle cannot survive arbitrary identity-dependent utilities.

### Theorem 9 (Two-Suspect Counterexample)

There exists a posterior on two suspects for which the unique MAP action has strictly smaller expected continuation value than the other action.

Specifically, take

$$
p_0=\frac35,\qquad p_1=\frac25.
$$

Let an incorrect elimination have value $0$. Let a correct elimination of suspect $0$ have value $1/10$, and a correct elimination of suspect $1$ have value $1$. Then suspect $0$ is MAP, but

$$
U_p(0)=\frac35\cdot\frac1{10}=\frac3{50}=0.06,
$$

whereas

$$
U_p(1)=\frac25\cdot1=\frac25=0.4.
$$

Hence $U_p(0)<U_p(1)$.

**Proof sketch.** The posterior comparison $3/5>2/5$ establishes the MAP choice. Direct multiplication by the identity-dependent hit rewards gives the expected values above, and $3/50<2/5$.

The example does not contradict Bayesian decision theory. On the contrary, Bayesian decision theory prescribes maximizing expected utility, which selects suspect $1$. It refutes only the unrestricted substitution of posterior maximization for utility maximization.

More generally, if action $a$ has identity-dependent hit value $R_a$ and zero miss value, its expected utility is $p_aR_a$. Ordering by $p_a$ alone is justified only when the rewards are equal, or under other assumptions strong enough to preserve the order of these products.

## 7. Centered posteriors and spin symmetry

### 7.1 The centered score

Define the **centered posterior score**

$$
s(p)=2p-1.
$$

For $p\in[0,1]$, this maps probability to $[-1,1]$. Certainty against the hidden role maps to $-1$, complete uncertainty maps to $0$, and certainty for the role maps to $+1$.

### Theorem 10 (Order preservation under centering)

For all real $p$ and $q$,

$$
s(p)\le s(q)\quad\Longleftrightarrow\quad p\le q.
$$

**Proof sketch.** Subtracting $1$ from both sides and multiplying by the positive constant $2$ preserve order. Equivalently, $s$ is a strictly increasing affine function.

Thus selecting a maximum posterior is exactly equivalent to selecting a maximum centered spin score.

### Theorem 11 (Role complementation is spin flip)

For every real $p$,

$$
s(1-p)=-s(p).
$$

**Proof sketch.** Expand directly:

$$
s(1-p)=2(1-p)-1=1-2p=-(2p-1).
$$

The operation $p\mapsto1-p$ swaps a binary role with its complement. In centered coordinates, this becomes the sign reversal familiar as global spin flip.

### 7.2 Constant-field magnetization

Consider a rectangular array indexed by pairs $(x,y)$ with $0\le x\le m$ and $0\le y\le n$. It contains $(m+1)(n+1)$ sites. For a field $\sigma$ on these sites, define magnetization as

$$
M(\sigma)=\sum_{x=0}^{m}\sum_{y=0}^{n}\sigma(x,y).
$$

### Theorem 12 (Constant Posterior Magnetization)

If every site carries the constant field $\sigma(x,y)=s(p)$, then

$$
M(\sigma)=(m+1)(n+1)s(p).
$$

**Proof sketch.** Magnetization sums the same value over $(m+1)(n+1)$ sites, so it equals the number of sites multiplied by that value.

### Corollary 13 (Complementation reverses magnetization)

If every site’s posterior is complemented from $p$ to $1-p$, then

$$
M(1-p)=-M(p).
$$

**Proof sketch.** By Theorem 11, every site value changes from $s(p)$ to $-s(p)$. Summation is linear, hence the total magnetization changes sign.

This correspondence is exact at the level of one-site marginals and constant fields. It does not by itself assert that a full posterior over correlated role assignments is an Ising Gibbs distribution. Such a representation would require specifying joint likelihoods and fixed-role-count constraints.

## 8. Algorithms

### 8.1 MAP selection from Bayesian weights

Given arrays of priors $\pi_i$ and likelihoods $L_i$, compute $w_i=\pi_iL_i$, verify that $Z=\sum_iw_i$ is positive, normalize to $p_i=w_i/Z$, and return any index attaining $\max_i p_i$. Theorem 2 permits selection directly from $w_i$. For $N=|I|$, time complexity is $O(N)$ and storage is $O(N)$ if all posterior values are returned, or $O(1)$ auxiliary storage if only an argmax is required.

For long evidence sequences, products may underflow. One may instead compute

$$
\ell_i=\log\pi_i+\sum_t\log L_{i,t}
$$

and apply a log-sum-exp normalization. Since logarithm is increasing, the maximizing index remains unchanged.

### 8.2 Symmetric continuation evaluation

Given posterior $p$, values $G$ and $B$, evaluate each action by

$$
V_i=B+(G-B)p_i.
$$

This requires $O(N)$ time for all actions. If $B\le G$, the MAP action is immediately optimal and no separate value scan is mathematically necessary beyond finding the maximum posterior.

### 8.3 Diagnostic test for identity dependence

When action-specific hit rewards $R_i$ are supplied and misses have common value zero, compare $p_iR_i$ rather than $p_i$. A disagreement between the two argmax sets certifies that MAP and utility maximization differ in the given instance. This diagnostic runs in $O(N)$ time.

## 9. Numerical examples

Consider priors

$$
\pi=(0.4,0.35,0.25)
$$

and likelihoods

$$
L=(0.2,0.8,0.5).
$$

The weights are

$$
w=(0.08,0.28,0.125),
$$

with evidence mass $Z=0.485$. The posterior is approximately

$$
p=(0.16495,0.57732,0.25773).
$$

The second suspect is MAP whether weights or normalized probabilities are compared.

If $G=0.9$ and $B=0.2$, continuation values are

$$
V_i=0.2+0.7p_i,
$$

or approximately

$$
V=(0.31546,0.60412,0.38041).
$$

The same suspect maximizes continuation value. If a near-MAP procedure chooses the third suspect, its posterior deficit is approximately $0.31959$ and the exact value deficit is $0.7$ times that amount, approximately $0.22371$, attaining the regret formula with equality.

For the asymmetric counterexample, posterior ranking selects suspect $0$ because $0.6>0.4$, while expected-utility ranking selects suspect $1$ because $0.4>0.06$.

Finally, at posterior $p=0.7$, the centered score is $s(p)=0.4$. On a $4$-by-$5$ set of sites, corresponding to $m=3$ and $n=4$, magnetization is $20\cdot0.4=8$. Complementation gives posterior $0.3$, score $-0.4$, and magnetization $-8$.

## 10. Applications

The theory applies wherever a posterior ranking is used to choose an intervention.

**Social deduction.** MAP voting maximizes the chance of the present hit. It maximizes a value-to-go only when hit and miss continuation values are identity-exchangeable.

**Medical testing.** Testing the most likely diagnosis maximizes immediate diagnostic hit probability under a one-diagnosis model. It may not maximize health value when diseases differ in urgency or treatability.

**Cybersecurity.** Investigating the most likely compromised node maximizes immediate detection probability. Criticality, containment effects, and information gained can favor a lower-posterior node.

**Fraud review.** Auditing the most suspicious transaction maximizes expected immediate positives when each detected fraud has equal value. Different transaction sizes and network effects break that symmetry.

**Active learning and search.** Querying the most likely label or location is locally optimal for zero-one success, but information gain and downstream decisions can produce identity-dependent continuation value.

Across these domains, the methodological sequence is the same: estimate posterior beliefs, specify action-conditioned utilities, test exchangeability, and only then infer whether posterior ranking is an optimal policy.

## 11. Limitations and relation to full-game claims

The present results do not determine a village win probability for a specified player count. A numerical assertion such as a $0.36$ win rate for seven players with two werewolves depends on rules and policies absent from the finite one-step model. At minimum, a full analysis must specify:

- whether eliminated roles are revealed;
- how ties are resolved;
- the order of day and night phases;
- how wolves choose night targets;
- how villagers generate and update evidence;
- whether role assignments are sampled without replacement;
- how multiple-wolf correlations are represented; and
- what happens when wolves equal or outnumber villagers.

Likewise, a proposed scaling law such as

$$
C\left(1-\frac{k}{n-k}\right)^2
$$

cannot be established from MAP optimality. The constant $C$ and even the functional form depend on the information channel and transition process. The local theory can serve as a component of such a model, but does not replace it.

The one-target posterior also abstracts away the fixed total number of wolves. If exactly $k$ of $n$ players are wolves, a complete posterior is a distribution on the $k$-element subsets of players. Marginal probabilities still support local hit maximization—selecting the largest marginal maximizes the chance that the chosen player is a wolf—but continuation effects can depend on the entire joint posterior.

## 12. Future research

Several directions emerge from the boundary established here.

First, adaptive submodularity may generalize the affine one-step theorem. If continuation value has diminishing returns in eliminated wolves and is exchangeable over identities, greedy posterior voting may admit global guarantees.

Second, an exchangeable noisy voting channel may exhibit a value-of-information threshold. Posterior concentration, rather than ranking alone, should determine whether villagers overcome the adversaries’ elimination rate as population grows.

Third, information-free games may retain parity effects because a missed daytime vote followed by a night elimination removes villagers in pairs. Separate even- and odd-population asymptotics may be required.

Fourth, pairwise log-linear likelihoods for voting histories may induce a constrained spin system on role assignments. Centered marginal symmetry supplies the one-site boundary case; correlations would become couplings.

Fifth, the one-step approximation bound invites a sequential regret theory. Calibrated posterior errors could be accumulated through martingale or dynamic-programming arguments to obtain horizon-sensitive guarantees.

## 13. Conclusion

Maximum-posterior voting has an exact but bounded scope. It always maximizes immediate correctness in a finite posterior model. It also maximizes continuation value when the future distinguishes only a correct elimination from an incorrect one and values the former at least as highly. In that symmetric setting, continuation value is affine in the selected posterior and approximate choices enjoy the sharp regret bound $(G-B)\varepsilon$.

Identity-dependent consequences break the conclusion, as a two-suspect counterexample demonstrates. The correct general principle is therefore expected-utility maximization, with MAP emerging as a special case under zero-one or identity-symmetric rewards.

The centered transformation $s(p)=2p-1$ adds a complementary structural insight: posterior ranking becomes spin ranking, role complementation becomes sign flip, and constant posterior fields acquire the expected magnetization law. Together, these results provide both a decision-theoretic foundation for social-deduction voting and a precise map of the assumptions needed before local suspicion can be promoted to global strategy.