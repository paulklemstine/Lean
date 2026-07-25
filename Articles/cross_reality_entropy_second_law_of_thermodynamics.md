# The Second Law Across Many Worlds

## When one branch grows quieter

Imagine a tree of possible histories. In one branch, a computer erases a bit. In another, a molecule settles into a more orderly arrangement. In a third, a measurement outcome leaves a small subsystem less uncertain than it was before. Look only at one such branch and entropy may fall. Does that contradict the second law of thermodynamics?

No. The familiar resolution is that entropy has not vanished: order gained by a subsystem must be paid for elsewhere, usually by heat or another increase in environmental uncertainty. But a branching description adds a second layer. Now there are many alternatives, each with its own probability, its own microscopic state, and its own environment. To formulate a second law for the whole ensemble, we must account for all three.

The resulting principle is simple but exact: if every branch exports at least as much entropy as its microscopic state loses, then the total entropy of the ensemble cannot decrease. If even one branch with positive probability exports strictly more than it loses, the total entropy strictly increases. A local decrease is therefore not merely compatible with a global increase; the bookkeeping explains precisely how the two coexist.

This is a theorem about finite classical ensembles. It does not require a particular interpretation of quantum mechanics, nor does it claim that physical universes literally split. “Branches” may stand for possible histories, measurement records, scenarios in a stochastic model, or components of a statistical mixture. The mathematics concerns any finite family of alternatives with fixed weights.

## Three kinds of uncertainty

Let the branches be indexed by $i=1,\ldots,n$. Branch $i$ has a nonnegative weight $w_i$. In the probabilistic interpretation, the weights satisfy

$$
\sum_{i=1}^n w_i=1.
$$

Inside branch $i$, the microscopic state is distributed according to probabilities $p_i(x)$ over a finite state space. Its Shannon entropy is

$$
H(p_i)=-\sum_x p_i(x)\log p_i(x),
$$

with the standard convention $0\log 0=0$. Each branch also has an environmental entropy $E_i$. Finally, the uncertainty in which branch occurs is itself measured by

$$
H(w)=-\sum_{i=1}^n w_i\log w_i.
$$

These pieces combine into the total ensemble entropy

$$
S(w,p,E)=H(w)+\sum_{i=1}^n w_i\bigl(H(p_i)+E_i\bigr).
$$

This expression has a natural reading. The first term is the “which branch?” uncertainty. The second is the average uncertainty remaining after the branch is known, augmented by the corresponding environmental entropy. The construction resembles the chain rule for entropy: uncertainty about a label plus average conditional uncertainty within that label.

The branch weights are held fixed between the initial and final times. This assumption matters. If weights move between branches, the mixing entropy $H(w)$ may change, creating an additional term. The finite fixed-weight setting isolates the central compensation mechanism without hiding it behind transport between branches.

## The balance sheet

Write $p_i^0$ and $p_i^1$ for the initial and final microscopic distributions in branch $i$, and $E_i^0$ and $E_i^1$ for the corresponding environmental entropies. Two branchwise quantities tell the whole story.

The microscopic entropy loss is

$$
L_i=H(p_i^0)-H(p_i^1).
$$

A positive $L_i$ means that the branch’s microscopic state has become more ordered. The exported environmental entropy is

$$
X_i=E_i^1-E_i^0.
$$

The branch’s net entropy production is therefore

$$
\sigma_i=X_i-L_i.
$$

The fundamental identity is

$$
S(w,p^1,E^1)-S(w,p^0,E^0)=\sum_{i=1}^n w_i\sigma_i
=\sum_{i=1}^n w_i(X_i-L_i).
$$

Nothing mysterious is concealed here. Because the weights do not change, $H(w)$ cancels. Expanding the remaining difference gives a weighted sum of the changes $H(p_i^1)-H(p_i^0)+E_i^1-E_i^0$, which is exactly $X_i-L_i$.

This identity is the engine of every result that follows. It turns a multibranch thermodynamic question into the sign of a finite weighted sum.

## A finite-ensemble second law

Suppose that every branch satisfies the compensation inequality

$$
L_i\le X_i.
$$

Equivalently, every net production obeys $\sigma_i\ge 0$. Since every weight is nonnegative, every product $w_i\sigma_i$ is nonnegative. Their sum is nonnegative, and the balance identity yields

$$
S(w,p^0,E^0)\le S(w,p^1,E^1).
$$

This is the weak second law for the ensemble: branchwise compensation implies global monotonicity.

The strict version reveals an important subtlety. Suppose there is a branch $j$ such that

$$
w_j>0
\qquad\text{and}\qquad
L_j<X_j.
$$

Then $w_j\sigma_j>0$, while all other weighted productions remain nonnegative. Consequently,

$$
S(w,p^0,E^0)<S(w,p^1,E^1).
$$

The positive-weight condition cannot be dropped. A branch with $w_j=0$ contributes nothing to the ensemble average, however large its entropy production may be. Strict growth must occur on the statistical support of the ensemble.

Nor is strict growth automatic. If $L_i=X_i$ on every positive-weight branch, then every relevant $\sigma_i$ is zero and the total entropy is unchanged. The theorem distinguishes exact compensation from genuine surplus.

## Local order, global disorder

Now choose any branch $k$ whose microscopic entropy decreases:

$$
H(p_k^1)<H(p_k^0).
$$

This says $L_k>0$. It does not by itself determine the total change. If all branches satisfy $L_i\le X_i$, and some positive-weight branch has a strict surplus $L_j<X_j$, then two statements hold simultaneously:

$$
S(w,p^0,E^0)<S(w,p^1,E^1)
$$

and

$$
H(p_k^1)<H(p_k^0).
$$

The branch losing microscopic entropy need not even be the branch providing strict surplus. One branch can become more ordered while another supplies the positive margin, provided every branch pays its own compensation bill. The global theorem is therefore genuinely collective without allowing deficits to be hidden: each branch must avoid negative net production, and at least one statistically present branch must do better than break even.

Consider a numerical example with three branch weights $(0.5,0.3,0.2)$. Suppose the microscopic losses are $(0.40,-0.10,0.20)$ and the environmental exports are $(0.50,0.00,0.25)$. The productions are $(0.10,0.10,0.05)$, all nonnegative. The total increase is

$$
0.5(0.10)+0.3(0.10)+0.2(0.05)=0.09.
$$

Branch $1$ experiences a microscopic entropy decrease of $0.40$, yet its environment gains $0.50$. The ensemble grows in entropy because compensation occurs branch by branch and the weighted surplus is positive.

## Deterministic updates and information loss

A particularly revealing case occurs when each branch evolves by a deterministic map. Let $f_i$ send each initial microscopic state to a final state. The final distribution is the pushforward

$$
p_i^1(y)=\sum_{x:f_i(x)=y}p_i^0(x).
$$

Deterministic maps can merge distinguishable states. They cannot create more Shannon entropy in the output than was present in the input:

$$
H(p_i^1)\le H(p_i^0).
$$

Thus the microscopic loss

$$
L_i=H(p_i^0)-H(p_i^1)
$$

is automatically nonnegative. A one-to-one rearrangement preserves entropy, while a many-to-one operation may reduce it. Erasing a bit is the canonical example: two input states can be mapped to one output state, removing microscopic uncertainty from the logical subsystem.

The deterministic multibranch second law now follows immediately. If each environment gains at least the deterministic information loss,

$$
H(p_i^0)-H(f_{i*}p_i^0)\le E_i^1-E_i^0,
$$

and if the inequality is strict for one branch of positive weight, then total ensemble entropy strictly increases.

This is the architecture behind Landauer-style reasoning. Deterministic information processing produces a measurable entropy deficit in the processed subsystem. Environmental compensation covers that deficit. Weighted aggregation then converts branchwise balances into a law for the entire ensemble.

## Why the theorem matters beyond “many worlds”

The language of parallel branches is evocative, but the result belongs to a broader family of local-to-global principles.

In **stochastic thermodynamics**, branches can represent trajectories or coarse-grained histories. The theorem says that pathwise compensation guarantees nondecrease after averaging, while strict average growth requires positive production on events of positive probability.

In **information processing**, branches can represent inputs, contexts, or measurement records. A deterministic compression may lower conditional entropy in one context, but the environmental cost restores the total balance.

In **scenario analysis**, branches can represent possible futures. The identity separates uncertainty over scenarios from uncertainty inside each scenario, making clear which contribution changes when scenario probabilities remain fixed.

In **distributed systems**, branches can stand for components or modes. If each component has a nonnegative entropy budget, a weighted system-level budget follows without requiring all components to behave identically.

The same warning travels across these applications: a zero-weight event cannot certify strict average improvement. Strictness must live where probability lives.

## The boundary of the result

The theorem is exact within its scope, and that scope should not be overstated. The branch family and microscopic state spaces are finite. Branch weights are fixed. Environmental entropy is supplied explicitly rather than derived from a detailed heat bath. “Local decrease” means a decrease in microscopic Shannon entropy, not necessarily a decrease in the branch’s combined microscopic-plus-environmental entropy.

Several extensions invite further work. Evolving weights require a transport rule and a separate mixing-entropy contribution. Countably many branches require convergence and tail control. Quantum branches replace ordinary distributions by density operators and Shannon entropy by von Neumann entropy. Fluctuation theorems would go beyond mean growth to quantify the probability of temporary negative production.

Yet the finite theory already delivers a clear conceptual lesson. The second law across alternatives is neither a vague appeal to averaging nor a claim that every subsystem must become less ordered. It is a balance equation:

$$
\Delta S=\sum_{i=1}^n w_i\sigma_i.
$$

If each $\sigma_i$ is nonnegative, the whole cannot decrease. If one $\sigma_i$ is positive where $w_i>0$, the whole must increase. Local order and global entropy growth are not rivals. They are compatible entries in the same ledger.

That ledger also clarifies what observation can test. Measure or estimate each branch weight, each conditional entropy change, and each environmental change. The theorem predicts the aggregate change without requiring every branch to look alike. Its content is modest but sharp: once the local balances are known, the global sign—and the exact condition for strictness—are no longer matters of intuition.