# Bayesian Werewolf: When the Most Suspicious Player Is—and Is Not—the Right Choice

A village wakes to bad news. During the night, a hidden werewolf has removed another villager from the game. Now the survivors must vote. One player contradicted herself yesterday. Another joined a suspicious coalition. A third has survived several nights despite appearing dangerous to the wolves. Whom should the village eliminate?

The natural answer is: eliminate the player most likely to be a werewolf. That principle sounds obvious, but it hides a crucial ambiguity. Does “right” mean most likely to make the correct decision *today*, or most likely to win the entire game? Those are different optimization problems. The first has a clean Bayesian solution. The second agrees with it only under a precise symmetry condition.

This distinction reaches far beyond Werewolf or Mafia. Medical triage, fraud investigation, cybersecurity, search, and active learning all face the same tension. The item most likely to be positive is not always the item whose inspection has the greatest long-term value. Probability ranks beliefs; utility ranks actions. They coincide only when the reward structure permits it.

## Turning suspicion into probability

Suppose there is a finite set $I$ of suspects. For each player $i\in I$, assign a prior probability $\pi_i$ that the player has the hidden role and a likelihood $L_i$ measuring how compatible the observed evidence is with that hypothesis. The unnormalized Bayesian weight is

$$
w_i=\pi_iL_i.
$$

The total evidence mass is

$$
Z=\sum_{j\in I}w_j,
$$

and, provided $Z\neq 0$, the posterior probability is

$$
p_i=\frac{w_i}{Z}.
$$

These posteriors sum to one. If $Z>0$, dividing every weight by the same positive number cannot change their order, so

$$
p_i\le p_j\quad\text{if and only if}\quad w_i\le w_j.
$$

This gives a useful computational shortcut: to find the most probable suspect, one may compare prior-times-likelihood scores without explicitly normalizing them.

A maximum-a-posteriori, or MAP, suspect is any player $a$ satisfying $p_i\le p_a$ for every $i\in I$. Because the suspect set is finite and nonempty, at least one MAP suspect always exists. Ties do not undermine the principle: every tied maximizer is locally optimal.

## The theorem behind the obvious vote

Imagine that exactly one of the listed hypotheses is true, and define the utility of eliminating player $a$ when the hidden werewolf is $w$ to be $1$ if $a=w$ and $0$ otherwise. The expected utility of choosing $a$ is

$$
\sum_{w\in I}p_w\mathbf 1_{\{a=w\}}=p_a.
$$

This identity yields the **Local MAP Optimality Theorem**: *among all possible eliminations, a MAP choice maximizes the probability that the current elimination is correct.*

The proof is only one line of mathematics once the model is stated. The expected correctness of choosing $a$ is exactly $p_a$, and a MAP player has the largest posterior coordinate. Yet this small theorem is the firm core inside a much larger strategic claim that is often made too casually.

The theorem does not say that MAP voting always maximizes the chance of eventually winning. A correct elimination can have different consequences depending on whom it removes. One hidden adversary may be more influential than another. Eliminating a particular player may reveal voting blocs, alter later information, or change the survival prospects of key villagers. The future can attach identity-dependent value to today’s action.

## When the local rule becomes globally valid

There is, however, an important setting in which the local and global objectives align. Suppose a correct elimination leads to continuation value $G$, an incorrect elimination leads to continuation value $B$, and these values do not depend on the identity selected. Assume also that $B\le G$: hitting a werewolf is at least as good as missing.

For a suspect with posterior $p_a$, the expected continuation value is

$$
p_aG+(1-p_a)B=B+(G-B)p_a.
$$

This affine formula is the center of the analysis. Since $G-B\ge 0$, expected continuation value increases with $p_a$. It follows that every MAP action maximizes eventual value in this identity-symmetric model.

This is the **Symmetric Continuation Theorem**: *if future value depends only on whether the present elimination is correct, not on which identity is selected, and correctness is no worse than error, then maximum-posterior voting is globally optimal for that decision stage.*

The symmetry assumption is not decorative. It does the real work. It says that identities are strategically exchangeable after conditioning on hit versus miss. In a simplified game with indistinguishable hidden adversaries and no identity-specific information effects, that can be a sensible approximation. In a rich social game, it must be tested rather than presumed.

## How costly is an approximate decision?

Real players rarely compute exact posteriors. They estimate. Fortunately, the affine formula gives a sharp robustness guarantee.

Suppose action $a$ is the benchmark and action $b$ has posterior no more than $\varepsilon$ below it:

$$
p_a\le p_b+\varepsilon.
$$

Under symmetric continuation with $B\le G$, the loss from choosing $b$ instead of $a$ is at most

$$
(G-B)\varepsilon.
$$

This is the **Posterior Approximation Regret Bound**. It cleanly separates two sources of sensitivity. The term $\varepsilon$ measures inferential error: how far the chosen posterior is from the benchmark. The term $G-B$ measures strategic stakes: how much better a hit is than a miss. A rough probability estimate may be harmless when the two outcomes have similar continuation values, but costly when today’s decision is pivotal.

The bound also explains why near-ties deserve calm rather than false precision. If two suspects differ by only $0.01$ in posterior probability, no identity-symmetric continuation model can assign more than $0.01(G-B)$ additional expected value to the higher one.

## A two-player warning

To see exactly why symmetry matters, consider two suspects. Their posterior probabilities are

$$
p_0=\frac35,\qquad p_1=\frac25.
$$

Suspect $0$ is the MAP choice. Now suppose a correct elimination of suspect $0$ is worth only $1/10$, while a correct elimination of suspect $1$ is worth $1$; an incorrect elimination is worth $0$ in either case. The expected values are

$$
\frac35\cdot\frac1{10}=0.06
$$

for suspect $0$, and

$$
\frac25\cdot 1=0.4
$$

for suspect $1$. The less likely suspect is overwhelmingly the better action.

Nothing Bayesian has failed. The posteriors correctly describe which identity is more likely to be the target. What failed is the substitution of probability for utility. The example establishes a sharp negative result: *without identity symmetry, MAP need not maximize global value.*

That lesson appears whenever actions have heterogeneous payoffs. A doctor may test a less likely disease because delay would be catastrophic. A security team may inspect a moderately suspicious server because it controls critical infrastructure. A detective may pursue a weaker lead because resolving it unlocks many other cases. The correct decision maximizes expected utility, not probability in isolation.

## Suspicion as a spin

There is a surprising geometric way to represent a posterior probability. Transform $p\in[0,1]$ into the centered score

$$
s(p)=2p-1.
$$

The endpoints $p=0$ and $p=1$ become spins $-1$ and $+1$, while complete uncertainty $p=1/2$ becomes $0$. Because this transformation is increasing,

$$
s(p)\le s(q)\quad\text{if and only if}\quad p\le q.
$$

Thus MAP voting is exactly the same as maximum-spin voting.

Even more suggestively, complementing the role label flips the sign:

$$
s(1-p)=-s(p).
$$

Calling “werewolf” what was formerly called “villager” acts like a global spin flip in statistical mechanics. If a rectangular lattice has $(m+1)(n+1)$ sites and every site carries the same score $s(p)$, its magnetization—the sum of all spins—is

$$
M=(m+1)(n+1)s(p).
$$

Complementing the posterior changes $M$ to $-M$. This bridge is elementary but useful: individual suspicion becomes a spin variable, and role-label symmetry becomes the familiar symmetry of a magnetic system.

The one-site correspondence suggests a richer future model. If voting relationships create correlated suspicion, pairwise interactions might be represented as couplings between spins. Coalitions could resemble aligned domains; polarized voting could resemble competing phases. Such extensions require new assumptions and new analysis, but the basic symmetry is exact.

## What the results do—and do not—settle

The analysis proves a decision principle, not a universal numerical win rate for the full game. A complete Werewolf model must specify the number of hidden roles, night eliminations, voting behavior, information revealed after eliminations, tie rules, and how evidence changes over time. Claims such as a particular win probability for seven players, or a universal quadratic scaling law in the wolf-to-villager ratio, cannot be inferred from the local MAP theorem alone.

What can be stated exactly is more foundational:

1. Bayesian posteriors normalize to one, and positive normalization preserves the ranking of prior-times-likelihood weights.
2. A MAP suspect always exists in a finite nonempty set.
3. MAP maximizes immediate correctness.
4. MAP also maximizes continuation value under identity symmetry and the condition $B\le G$.
5. Posterior approximation incurs at most $(G-B)\varepsilon$ regret in that model.
6. Without identity symmetry, MAP can fail dramatically.
7. Centered posterior scores obey the order and complement symmetries of spins.

These statements draw a boundary around a popular intuition. “Vote for the most suspicious player” is not wrong. It is exactly right for the immediate classification problem, and exactly right for a broad symmetric continuation model. But strategy begins where symmetry ends.

The deepest practical message is therefore not a voting slogan but a modeling discipline. First infer what is likely. Then ask what each action changes. Bayesian probability supplies the beliefs; the continuation utility supplies the stakes. Only after both are visible can a village—or a hospital, a network defender, or a scientific search team—choose rationally.