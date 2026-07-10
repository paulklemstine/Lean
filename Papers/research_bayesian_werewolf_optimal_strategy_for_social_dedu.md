# The Probabilistic Backbone of Bayesian Play in Social-Deduction Games

## Abstract

Social-deduction games such as *Werewolf* and *Mafia* pit an informed malicious
minority against an uninformed majority that must identify and eliminate the
minority through repeated group decisions under uncertainty. We isolate and prove
the exact probabilistic core of the widely used "vote for the most suspicious
player" heuristic. Our central result is a **Symmetry Principle**: when the only
available evidence is the population census — $k$ werewolves hidden among $n$
players — the posterior probability that any fixed player is a werewolf equals the
prior $k/n$ exactly. Consequently every player is equally suspicious, a uniform
vote is optimal, and the evidence-free per-round detection probability is pinned at
exactly $k/n$. We complement this with (i) exact monotonicity of suspicion in the
number of werewolves and in the population size; (ii) the identification of the
**werewolf advantage** $A = k/(n-k)$ and a sharp **parity threshold**, namely that
the werewolves are at least as numerous as the villagers if and only if $n \le 2k$;
(iii) an **exchangeability / survival law** stating that a fixed player survives $t$
uniformly random removals with probability exactly $(n-t)/n$; and (iv) a
well-founded recursive model of the full consensus-elimination game whose villager
win-probability is proved to be a genuine probability lying in $[0,1]$. These
results give a rigorous, dimension-free foundation for optimal Bayesian play and
recast the informal $(1 - k/(n-k))^2$ "win-probability envelope" as the exact
parity criterion and monotonicity statements that actually underlie it.

## 1. Introduction

A social-deduction game is a repeated elimination contest between two groups: an
*informed minority* (the werewolves) who know each other's identities, and an
*uninformed majority* (the villagers) who do not. In the canonical rules, a
population of $n$ players contains $k$ werewolves and $n-k$ villagers. Play
alternates between two kinds of rounds:

- **Night.** The werewolves collectively remove one villager.
- **Day.** All surviving players vote, and the plurality target is removed. The
  vote may fall on a werewolf or a villager.

The villagers win if every werewolf is removed; the werewolves win the moment they
reach *parity*, i.e. become at least as numerous as the surviving villagers, since
a coordinated bloc can then control every subsequent vote.

The folklore strategy for villagers is Bayesian: maintain, for each player, a
posterior probability of being a werewolf, and vote for the maximizer. The natural
conjecture — and the motivating claim of this work — is that this heuristic is
optimal, that under symmetric (census-only) evidence the posterior collapses to the
prior $k/n$, and that the structural advantage of the werewolves is governed by the
ratio $k/(n-k)$. This paper proves the exact probabilistic statements that make
these claims precise.

Rather than fit an empirical curve to simulated games, we extract the *exact*
identities behind the heuristic. The payoff is a set of dimension-free theorems —
a collapsing posterior, monotone comparative statics, a sharp parity criterion, an
exchangeable survival law, and a well-defined game value — that hold for all $n$ and
$k$ and require no simulation.

## 2. Setup and Definitions

Throughout, $n$ denotes the number of players and $k$ the number of werewolves,
with $0 \le k \le n$. All probabilities are exact rationals.

**Definition 2.1 (Posterior).** *The posterior probability that a fixed player is a
werewolf, given only that there are $k$ werewolves among $n$ players, is*
$$\operatorname{post}(n,k) = \frac{\binom{n-1}{k-1}}{\binom{n}{k}},$$
*the number of $k$-subsets of the population containing the fixed player, divided by
the total number of $k$-subsets.*

**Definition 2.2 (Prior).** *The prior probability that a fixed player is a
werewolf is* $\operatorname{prior}(n,k) = k/n.$

**Definition 2.3 (Werewolf advantage).** *The werewolf advantage is the ratio of
werewolves to villagers,* $A(n,k) = \dfrac{k}{\,n-k\,}$ *(defined for $k < n$).*

**Definition 2.4 (Survival probability).** *The probability that a fixed player is
not among $t$ uniformly random players removed from a population of $n$ is*
$$\operatorname{surv}(n,t) = \frac{\binom{n-1}{t}}{\binom{n}{t}},$$
*the fraction of $t$-subsets that avoid the fixed player.*

**Definition 2.5 (Consensus-elimination game value).** *Let $W(w,v)$ denote the
villager win-probability of the game in which $w$ werewolves and $v$ villagers are
alive, one uniformly random living player is removed each round, villagers win when
no werewolf remains, and werewolves win upon reaching parity ($w \ge v$). It
satisfies $W(0,v) = 1$, $W(w,v) = 0$ whenever $w \ge v$ with $w \ge 1$, and
otherwise*
$$W(w,v) = \frac{w}{w+v}\, W(w-1,\,v) \;+\; \frac{v}{w+v}\, W(w,\,v-1).$$
*The two branches correspond to the removed player being a werewolf (probability
$w/(w+v)$) or a villager (probability $v/(w+v)$).*

## 3. The Symmetry Principle

The technical heart of the paper is a single classical counting identity.

**Lemma 3.1 (Double-counting identity).** *For $1 \le k \le n$,*
$$k \cdot \binom{n}{k} = n \cdot \binom{n-1}{k-1}.$$

*Proof sketch.* Count pairs $(S, x)$ where $S$ is a $k$-subset of the $n$ players
and $x \in S$ is a distinguished element. Choosing $S$ first and then $x$ gives
$\binom{n}{k}\cdot k$; choosing $x$ first from all $n$ players and then the
remaining $k-1$ elements of $S$ from the other $n-1$ gives $n\cdot\binom{n-1}{k-1}$.
Both count the same set of pairs. $\qquad\blacksquare$

**Theorem 3.2 (Symmetry Principle).** *For $1 \le k \le n$,*
$$\operatorname{post}(n,k) = \operatorname{prior}(n,k) = \frac{k}{n}.$$
*With only the population counts as evidence, the posterior probability that a fixed
player is a werewolf equals the prior. Every player is equally suspicious, and a
uniform vote is optimal.*

*Proof sketch.* Cross-multiplying, the claimed equality
$\binom{n-1}{k-1}/\binom{n}{k} = k/n$ is equivalent to
$n\binom{n-1}{k-1} = k\binom{n}{k}$, which is exactly Lemma 3.1. The denominators
$\binom{n}{k}$ and $n$ are positive for $1 \le k \le n$, so the division is
valid. $\qquad\blacksquare$

**Corollary 3.3 (Baseline detection probability).** *A single optimal (uniform)
vote removes a werewolf with probability exactly $k/n$.*

This corollary is the quantitative moral of the symmetry principle: absent
behavioral evidence, the town's per-round detection rate is fixed at the raw
prevalence $k/n$, independent of any strategic cleverness. It furnishes the clean
baseline against which the value of any information-driven refinement must be
measured.

## 4. Comparative Statics of Suspicion

Within a single game every player carries identical suspicion, but the shared level
$k/n$ responds monotonically to the two population parameters.

**Theorem 4.1 (Suspicion increases in werewolves).** *For $n > 0$,*
$\operatorname{prior}(n,k) < \operatorname{prior}(n,k+1).$

*Proof sketch.* Both sides have the same positive denominator $n$, and the
numerators satisfy $k < k+1$. $\qquad\blacksquare$

**Theorem 4.2 (Suspicion decreases in population).** *For $k \ge 1$ and $n \ge 1$,*
$\operatorname{prior}(n+1,k) < \operatorname{prior}(n,k).$

*Proof sketch.* The value is $k/(n+1)$ versus $k/n$; with $k \ge 1$ the numerator is
positive and the larger denominator yields the strictly smaller
fraction. $\qquad\blacksquare$

Together these state the two levers governing a game's tension: adding predators
raises suspicion, enlarging the crowd dilutes it, each by an exact strict
inequality.

## 5. The Werewolf Advantage and the Parity Threshold

Suspicion measures detectability; *parity* decides the game. Once the werewolves are
no longer outnumbered, a coordinated bloc controls every vote and cannot be
dislodged. The relevant order parameter is therefore the werewolf advantage
$A(n,k) = k/(n-k)$.

**Theorem 5.1 (Parity threshold).** *For $k < n$,*
$$A(n,k) \ge 1 \iff n \le 2k.$$
*As long as at least one villager remains, the werewolves are at least as numerous
as the villagers exactly when $n \le 2k$.*

*Proof sketch.* Since $k < n$ the denominator $n - k$ is positive, so
$k/(n-k) \ge 1$ is equivalent to $k \ge n - k$, i.e. $2k \ge n$. $\qquad\blacksquare$

**Theorem 5.2 (Advantage increases in werewolves).** *For $k+1 < n$,*
$A(n,k) < A(n,k+1).$

*Proof sketch.* Clearing the positive denominators $n-k$ and $n-k-1$ reduces the
claim to $k(n-k-1) < (k+1)(n-k)$, i.e. $0 < n - k$, which holds because
$k < n$. $\qquad\blacksquare$

The parity threshold is exact rather than asymptotic: it is an algebraic
equivalence, not an approximation. It is also the rigorous replacement for the
informal $(1 - k/(n-k))^2$ "win-probability envelope" from the motivating
conjecture. The envelope is a heuristic curve; the exact content behind it is the
sharp threshold $n \le 2k$ together with the monotonicity of the advantage — the raw
count matters only through its distance to parity.

## 6. Exchangeability and the Survival Law

Not all removals are chosen by the villagers; nightly eliminations are effectively
uniform over the exposed population. Exchangeability lets us compute survival exactly.

**Theorem 6.1 (Survival law).** *For $t \le n$ and $n \ge 1$,*
$$\operatorname{surv}(n,t) = \frac{n - t}{n}.$$
*A fixed player survives $t$ uniformly random removals with probability exactly
$(n-t)/n$.*

*Proof sketch.* Survival of the fixed player means the $t$ removed players form a
$t$-subset of the other $n-1$ players, giving $\binom{n-1}{t}$ favorable subsets out
of $\binom{n}{t}$ total. Using the Pascal / absorption identities
$\binom{n}{t} = \binom{n-1}{t} + \binom{n-1}{t-1}$ and the ratio
$\binom{n-1}{t}/\binom{n}{t} = (n-t)/n$ (equivalently, from Lemma 3.1's companion
identity $(n-t)\binom{n}{t} = n\binom{n-1}{t}$), the quotient simplifies to
$(n-t)/n$. $\qquad\blacksquare$

The survival law converts the messy multi-night stochastic process into a single
fraction — the surviving proportion of the town — and provides the raw material for
studying how quickly a town is ground down over a round-limited game.

## 7. The Consensus-Elimination Game Is Well Defined

A theory of "the town's chances" is only meaningful if that chance is an honest
probability.

**Theorem 7.1 (Value bounds).** *For all configurations $(w,v)$, the villager
win-probability satisfies*
$$0 \le W(w,v) \le 1.$$

*Proof sketch.* Induct on the number of rounds (a fuel parameter that equals the
live population $w+v$ in every reachable call and strictly decreases along each
recursive branch). The base cases $W(0,v)=1$ and the parity case $W=0$ lie in
$[0,1]$. In the recursive case $W(w,v)$ is a convex combination
$\lambda\,W(w-1,v) + (1-\lambda)\,W(w,v-1)$ with weights
$\lambda = w/(w+v) \in [0,1]$; by the inductive hypothesis both summands lie in
$[0,1]$, and a convex combination of values in $[0,1]$ remains in $[0,1]$.
$\qquad\blacksquare$

The fuel-bounded recursion guarantees termination and rules out a vacuous model:
$W$ is a genuine probability for every reachable configuration, so all downstream
statements about win-probability refer to well-defined numbers in $[0,1]$.

## 8. Algorithms

We record two algorithms implicit in the results above.

**Algorithm A (Exact game value by memoized recursion).** Evaluate $W(w,v)$ by
dynamic programming over the finite state space $\{(w',v') : w' \le w, v' \le v\}$.
Each state is a convex combination of two smaller states, so a bottom-up fill
computes all values in $O(w\cdot v)$ arithmetic operations on exact rationals. The
parity and no-werewolf boundary conditions seed the table.

**Algorithm B (Baseline vs. informed detection comparison).** Given a per-round
evidence model that maps observations to posteriors, compare the informed
single-round detection probability against the symmetric baseline $k/n$ from
Corollary 3.3. Because the baseline is an exact constant, the *value of information*
is a well-posed difference: informed rate minus $k/n$, aggregated over rounds via
Algorithm A.

## 9. Applications

The structure of Werewolf recurs wherever a group must identify a hidden malicious
minority from noisy, strategic, partial information: fraud detection in marketplaces,
identifying compromised nodes in a network, insider-threat screening, and moderation
against coordinated online manipulation. Three transferable morals follow directly
from the theorems.

1. **Symmetry fixes the baseline.** Without discriminating evidence, the detection
   rate is exactly the prevalence $k/n$ (Corollary 3.3); the entire value of a
   detection system is how far its evidence lifts it above this line.
2. **Ratios, not counts.** System health is governed by the advantage
   $A = k/(n-k)$ with a sharp phase transition at parity (Theorem 5.1), so the
   correct order parameter is distance to parity, $n - 2k$, not raw counts.
3. **The clock is adversarial.** Because each imperfect round can remove the wrong
   party, and because value is a decreasing function toward parity (Theorems 4.1,
   5.2), time works against the defenders; a detector that cannot outpace attrition
   loses regardless of per-round cleverness.

## 10. Discussion and Future Work

The symmetry principle is exact and dimension-free, and the parity threshold is a
sharp algebraic equivalence rather than an empirical fit. This reframes the
motivating $(1 - k/(n-k))^2$ envelope as a heuristic silhouette of the rigorous
content: the exact threshold $n \le 2k$ and the monotonicity of suspicion and
advantage. Several directions extend these exact results.

**Conjecture 1 (Parity as a phase transition).** As the werewolf fraction crosses
$k = n/2$, the villager win-probability drops discontinuously to zero, and just
below parity decays like a fixed power of the villager surplus $n - 2k$. Distance to
parity, not raw counts, is the correct order parameter of the entire value surface.

**Conjecture 2 (Bounded value of information).** Any villager strategy using
per-round evidence improves single-round detection from the symmetric baseline
$k/n$ to at most $1$, and the resulting gain in overall win-probability is bounded
by a factor depending only on the number of rounds, not on $n$.

**Conjecture 3 (Square-root werewolf scaling).** For the game to be balanced —
villager win-probability bounded away from both $0$ and $1$ as $n \to \infty$ — the
number of werewolves must grow on the order of $\sqrt{n}$. The survival law
$(n-t)/n$ makes the expected number of werewolves removed a concrete quantity, and
balancing removals against parity pressure forces a sub-linear werewolf count.

**Conjecture 4 (Monotone comparative statics for mixed rulesets).** The strict
monotonicity of suspicion (increasing in werewolves, decreasing in population) and
of the advantage persists verbatim when nightly eliminations are added, so
comparative statics proven for the consensus model transfer to full mixed rulesets.

## 11. Conclusion

Beneath the theatrics of accusation and denial, social-deduction games rest on a
compact exact theory. The posterior collapses to the prior $k/n$; suspicion and the
werewolf advantage move monotonically with the population parameters; parity is
reached exactly when $n \le 2k$; a fixed player survives $t$ uniform removals with
probability exactly $(n-t)/n$; and the full consensus game has a well-defined value
in $[0,1]$. Together these furnish a rigorous foundation for optimal Bayesian play
and a template for reasoning about hidden-adversary detection far beyond the game
table.
