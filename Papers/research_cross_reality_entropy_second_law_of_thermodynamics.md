# Cross-Reality Entropy: A Strict Second Law for Finite Branch Ensembles

**Aristotle**  
**July 25, 2026**

## Abstract

We formulate an entropy balance law for a finite ensemble of statistically weighted branches. Each branch carries a conditional probability distribution on a finite microscopic state space and an explicit environmental entropy, while the fixed branch weights contribute a mixing entropy. The total entropy is the sum of the mixing entropy and the weighted conditional microscopic and environmental entropies. We prove an exact change identity: the total entropy change equals the weighted sum of branchwise environmental export minus branchwise microscopic entropy loss. It follows that branchwise compensation implies a weak ensemble second law. If compensation is strict on at least one branch of positive weight, total entropy grows strictly. This remains compatible with a designated branch undergoing a strict decrease of microscopic Shannon entropy. For deterministic branch dynamics, the data-processing inequality makes microscopic loss nonnegative, and environmental compensation yields a deterministic multibranch second law. We give algorithms for evaluating the balance, certifying monotonicity and strictness, and computing deterministic pushforwards. The results isolate the precise roles of local compensation, statistical support, and fixed mixing weights.

## 1. Introduction

Thermodynamic reasoning often separates a subsystem from its environment. A subsystem may become more ordered and lose entropy, but the second law is preserved when the environment gains at least the amount lost. A finite ensemble of alternative histories, scenarios, records, or branches introduces an additional level of uncertainty: besides uncertainty within each branch, there is uncertainty about which branch is realized.

The purpose of this paper is to establish a transparent entropy law for such finite ensembles. The central question is local-to-global: which branchwise conditions guarantee monotonicity, or strict growth, of the entropy of the entire ensemble?

The answer is governed by a finite weighted sum. Let branch $i$ have weight $w_i$, microscopic distribution $p_i$, and environmental entropy $E_i$. With fixed branch weights, define total entropy by

$$
S(w,p,E)=H(w)+\sum_i w_i\bigl(H(p_i)+E_i\bigr).
$$

Between two times, let the environmental entropy export be $X_i=E_i^1-E_i^0$, and let microscopic entropy loss be $L_i=H(p_i^0)-H(p_i^1)$. Direct expansion gives

$$
\Delta S=\sum_i w_i(X_i-L_i).
$$

This identity contains the entire finite theory. If $X_i\ge L_i$ for every branch and $w_i\ge0$, then $\Delta S\ge0$. If one inequality is strict on a branch with $w_i>0$, then $\Delta S>0$. A branch of zero weight cannot witness strict growth because it contributes nothing to the weighted total.

The result makes precise how strict global entropy growth can coexist with a local microscopic entropy decrease. The local decrease merely makes $L_i$ positive. It is harmless to the total balance when the corresponding environmental export covers it. The branch providing strict global surplus may be the same branch or another one.

We also specialize the theory to deterministic updates. A deterministic map pushes a distribution forward by collecting the masses of states with a common image. Shannon entropy cannot increase under such a map, so the microscopic entropy loss is nonnegative. If each environment compensates this data-processing loss, with a strict excess on positive statistical support, the total entropy strictly increases.

The setting is intentionally finite and classical. This allows the strictness mechanism to be isolated without analytic convergence issues. The branch weights remain fixed; allowing them to evolve would create an additional mixing-entropy term and would require a transport relation between the old and new branches.

Two features distinguish the result from a generic statement about averages. First, the exact identity supplies not only the sign of the change but its numerical value. Second, the hypotheses identify a local certificate for the global conclusion: each branch can be checked independently, followed by a single weighted aggregation. This modularity is useful whenever branches arise from separately modeled devices, histories, or scenarios. It also makes the equality boundary transparent, since total stationarity under compensation occurs precisely when every branch carrying positive weight has zero production.

## 2. Finite ensemble framework

### 2.1 Branches, states, and distributions

Let $I$ be a nonempty finite set of branches and let $A$ be a finite microscopic state space. A **branch-weight distribution** is a family $w=(w_i)_{i\in I}$ satisfying

$$
w_i\ge0 \quad\text{for all }i\in I,
\qquad
\sum_{i\in I}w_i=1.
$$

For each branch $i$, a **microscopic distribution** is a function $p_i:A\to[0,1]$ satisfying

$$
\sum_{x\in A}p_i(x)=1.
$$

The algebraic balance results below require only nonnegative weights; normalization gives the intended probabilistic interpretation and the usual meaning of mixing entropy.

For any probability distribution $r$ on a finite set, its Shannon entropy is

$$
H(r)=-\sum_x r(x)\log r(x),
$$

where $0\log0$ is defined as $0$. The logarithm base fixes the unit: base $2$ gives bits and the natural logarithm gives nats. All identities and inequalities are independent of this choice provided it is used consistently.

Each branch also carries a real number $E_i$, called its **environmental entropy**. It is an explicit state variable. No particular microscopic bath model is assumed.

### 2.2 Mixing entropy and total entropy

**Definition 2.1 (Branch mixing entropy).** The entropy associated with uncertainty over branch labels is

$$
H_{\mathrm{br}}(w)=H(w)=-\sum_{i\in I}w_i\log w_i.
$$

**Definition 2.2 (Total finite-ensemble entropy).** For fixed weights $w$, branchwise microscopic distributions $p=(p_i)_{i\in I}$, and environmental entropies $E=(E_i)_{i\in I}$, define

$$
S(w,p,E)=H_{\mathrm{br}}(w)+\sum_{i\in I}w_i\bigl(H(p_i)+E_i\bigr).
$$

The first term measures uncertainty in the branch label. The second term is the weighted average of conditional microscopic entropy and environmental entropy once that label is known.

The formula is additive at the level needed here, but it does not assert statistical independence between arbitrary physical subsystems. Rather, it defines the aggregate quantity studied in this finite classical model.

### 2.3 Changes between two times

Let $p^0=(p_i^0)$ and $p^1=(p_i^1)$ denote initial and final branchwise microscopic distributions. Let $E^0=(E_i^0)$ and $E^1=(E_i^1)$ denote initial and final environmental entropies. The weights $w$ remain fixed.

**Definition 2.3 (Environmental entropy export).** For branch $i$, define

$$
X_i=E_i^1-E_i^0.
$$

Positive $X_i$ means that the environmental entropy assigned to branch $i$ has increased.

**Definition 2.4 (Microscopic entropy loss).** For branch $i$, define

$$
L_i=H(p_i^0)-H(p_i^1).
$$

Thus $L_i>0$ means the branch’s microscopic distribution has lower entropy at the final time, while $L_i<0$ means its microscopic entropy has increased.

**Definition 2.5 (Net branchwise entropy production).** Define

$$
\sigma_i=X_i-L_i.
$$

The compensation condition $L_i\le X_i$ is equivalent to $\sigma_i\ge0$.

## 3. Exact entropy balance

**Theorem 3.1 (Total entropy change identity).** For any finite branch family, fixed weights, initial and final microscopic distributions, and initial and final environmental entropies,

$$
S(w,p^1,E^1)-S(w,p^0,E^0)
=\sum_{i\in I}w_i\bigl(X_i-L_i\bigr)
=\sum_{i\in I}w_i\sigma_i.
$$

**Proof sketch.** Expand both total entropies. Because the weights are fixed, the two copies of $H_{\mathrm{br}}(w)$ cancel. For each branch,

$$
\begin{aligned}
&H(p_i^1)+E_i^1-H(p_i^0)-E_i^0\\
&=(E_i^1-E_i^0)-\bigl(H(p_i^0)-H(p_i^1)\bigr)\\
&=X_i-L_i.
\end{aligned}
$$

Multiplying by $w_i$ and summing proves the identity. $\square$

This theorem separates the model into a fixed mixing contribution and a conditional production contribution. It also shows why the fixed-weight assumption is structural rather than cosmetic. If the weights changed from $w^0$ to $w^1$, a term $H(w^1)-H(w^0)$ would survive, and changes in weighted conditional terms would require a rule identifying or transporting branch content.

## 4. Weak and strict second laws

### 4.1 Branchwise compensation

**Theorem 4.1 (Weak finite-ensemble second law).** Assume $w_i\ge0$ for every $i\in I$ and assume branchwise compensation,

$$
L_i\le X_i
\qquad\text{for every }i\in I.
$$

Then total entropy is nondecreasing:

$$
S(w,p^0,E^0)\le S(w,p^1,E^1).
$$

**Proof sketch.** Compensation gives $\sigma_i=X_i-L_i\ge0$. Since $w_i\ge0$, every term $w_i\sigma_i$ is nonnegative. Theorem 3.1 identifies the total entropy change with their sum, hence that change is nonnegative. $\square$

The assumption is branchwise, not merely average. It rules out financing an uncompensated loss in one branch by a surplus in another. This is a strong local thermodynamic condition whose global consequence is immediate under weighted aggregation.

### 4.2 Strict production on statistical support

**Theorem 4.2 (Strict finite-ensemble second law).** Under the assumptions of Theorem 4.1, suppose there exists a witness branch $j\in I$ such that

$$
w_j>0
\qquad\text{and}\qquad
L_j<X_j.
$$

Then total entropy strictly increases:

$$
S(w,p^0,E^0)<S(w,p^1,E^1).
$$

**Proof sketch.** All terms $w_i\sigma_i$ are nonnegative. For the witness branch, both factors are strictly positive: $w_j>0$ and $\sigma_j=X_j-L_j>0$. Thus one summand is positive and none is negative. The finite sum is strictly positive, and Theorem 3.1 gives the conclusion. $\square$

The theorem identifies two logically independent requirements for strictness. First, there must be a genuine compensation surplus. Second, that surplus must occur on positive statistical support.

**Corollary 4.3 (Zero-weight branches cannot witness strict growth).** A branch $j$ with $w_j=0$ contributes $w_j\sigma_j=0$ to the total entropy change, regardless of the value of $\sigma_j$. Consequently, a strict surplus confined to zero-weight branches does not imply strict total growth.

**Proof sketch.** Substitute $w_j=0$ into the change identity. $\square$

**Corollary 4.4 (Exact compensation gives equality).** If $L_i=X_i$ for every positive-weight branch, then

$$
S(w,p^0,E^0)=S(w,p^1,E^1).
$$

**Proof sketch.** Every positive-weight branch has $\sigma_i=0$; every zero-weight branch has $w_i\sigma_i=0$. Hence the weighted sum in Theorem 3.1 vanishes. $\square$

More generally, under nonnegative weights and branchwise compensation, equality of total entropy holds exactly when $w_i\sigma_i=0$ for every branch. Equivalently, every positive-weight branch has zero net entropy production.

## 5. Compatibility with local microscopic entropy decrease

A global second law does not require monotonicity of every microscopic conditional entropy.

**Theorem 5.1 (Strict global growth despite local decrease).** Assume the hypotheses of Theorem 4.2. Let $k\in I$ be any designated branch satisfying

$$
H(p_k^1)<H(p_k^0).
$$

Then both

$$
S(w,p^0,E^0)<S(w,p^1,E^1)
$$

and

$$
H(p_k^1)<H(p_k^0)
$$

hold simultaneously.

**Proof sketch.** The first statement is Theorem 4.2; the second is the designated local hypothesis. They impose no contradiction because total entropy includes environmental and weighted cross-branch contributions, whereas the local statement concerns only one microscopic conditional distribution. $\square$

The witness $j$ for strict surplus and the locally decreasing branch $k$ may coincide, but they need not. If they coincide, the same branch both becomes microscopically more ordered and exports more entropy than that ordering removes. If they differ, branch $k$ is exactly compensated or has its own surplus, while branch $j$ supplies at least one strict positive term in the global weighted sum.

### 5.1 Numerical illustration

Take three branches with weights

$$
w=(0.50,0.30,0.20).
$$

Let the microscopic losses and environmental exports be

$$
L=(0.40,-0.10,0.20),
\qquad
X=(0.50,0.00,0.25).
$$

Then

$$
\sigma=X-L=(0.10,0.10,0.05).
$$

Every branch satisfies compensation, and every weight is positive. The total change is

$$
\Delta S=0.50(0.10)+0.30(0.10)+0.20(0.05)=0.09>0.
$$

The first branch has $L_1=0.40>0$, so its microscopic entropy falls by $0.40$, yet its environmental entropy rises by $0.50$. The total ensemble entropy strictly increases.

To display the support condition, change the productions to $\sigma=(0,0,5)$ and the weights to $w=(0.6,0.4,0)$. Although branch $3$ has a large surplus, the total change is

$$
\Delta S=0.6(0)+0.4(0)+0(5)=0.
$$

Strictness is invisible outside the support.

## 6. Deterministic branch dynamics

### 6.1 Pushforward distributions

Let $A$ and $B$ be finite sets, let $p$ be a probability distribution on $A$, and let $f:A\to B$ be deterministic. The **pushforward distribution** $f_*p$ on $B$ is

$$
(f_*p)(y)=\sum_{x\in A:f(x)=y}p(x).
$$

The map may merge several input states into one output state. It cannot split the probability of a known input among multiple outputs because it is deterministic.

**Lemma 6.1 (Deterministic entropy loss is nonnegative).** For a finite probability distribution $p$ and deterministic map $f$,

$$
H(f_*p)\le H(p),
$$

or equivalently,

$$
H(p)-H(f_*p)\ge0.
$$

**Proof sketch.** Let $X$ be an $A$-valued random variable with distribution $p$, and set $Y=f(X)$. Since $Y$ is determined by $X$, the chain rule gives

$$
H(X)=H(Y)+H(X\mid Y).
$$

Conditional entropy is nonnegative, so $H(Y)\le H(X)$. The laws of $X$ and $Y$ are $p$ and $f_*p$, respectively. $\square$

Equality holds for any map that is injective on the support of $p$. Strict loss may occur when positive-probability states are merged.

### 6.2 Deterministic multibranch law

For each branch $i$, let $f_i:A\to A$ be a deterministic update and set

$$
p_i^1=(f_i)_*p_i^0.
$$

Its microscopic loss is

$$
L_i=H(p_i^0)-H((f_i)_*p_i^0)\ge0.
$$

**Theorem 6.2 (Deterministic multibranch second law).** Let $I$ and $A$ be finite, let $w_i\ge0$, and let each branch evolve by a deterministic map $f_i:A\to A$. Assume

$$
H(p_i^0)-H((f_i)_*p_i^0)\le E_i^1-E_i^0
$$

for every branch. If there exists $j\in I$ with $w_j>0$ and

$$
H(p_j^0)-H((f_j)_*p_j^0)<E_j^1-E_j^0,
$$

then

$$
S\bigl(w,p^0,E^0\bigr)
<
S\bigl(w,((f_i)_*p_i^0)_{i\in I},E^1\bigr).
$$

**Proof sketch.** Lemma 6.1 identifies a canonical nonnegative microscopic loss for each deterministic update. The assumed environmental inequality is exactly branchwise compensation, and the witness supplies strict compensation on positive support. Apply Theorem 4.2. $\square$

This theorem separates three layers. Deterministic processing produces a microscopic information loss. Environmental entropy export compensates that loss. Weighted aggregation turns one strict positive-support surplus into strict growth of the whole ensemble.

### 6.3 Bit erasure example

Suppose a branch contains a fair bit with distribution $(1/2,1/2)$. Its entropy is $\log 2$. Erasure maps both logical values to $0$, yielding the point distribution $(1,0)$ with entropy $0$. Thus

$$
L=\log2.
$$

If the environmental entropy gain is exactly $\log2$, the combined branch contribution is unchanged. If the gain is $\log2+\varepsilon$ for $\varepsilon>0$, that branch has production $\varepsilon$. If its ensemble weight is $w>0$, it contributes $w\varepsilon>0$ to total growth.

## 7. Algorithms and computational realization

The finite theory leads to direct numerical procedures. Let $n=|I|$ and $m=|A|$.

### 7.1 Entropy evaluation

Given a probability vector $r=(r_1,\ldots,r_m)$, compute

$$
H(r)=-\sum_{a:r_a>0}r_a\log r_a.
$$

Skipping zero entries implements the continuous convention $0\log0=0$. This requires $O(m)$ time and $O(1)$ auxiliary storage beyond the input.

### 7.2 Balance and certificate algorithm

For each branch, compute $H(p_i^0)$ and $H(p_i^1)$, then form

$$
L_i=H(p_i^0)-H(p_i^1),
\qquad
X_i=E_i^1-E_i^0,
\qquad
\sigma_i=X_i-L_i.
$$

Compute

$$
\Delta S=\sum_i w_i\sigma_i.
$$

A weak certificate succeeds if each $w_i\ge0$ and each $\sigma_i\ge0$. A strict certificate additionally requires some $i$ with $w_i>0$ and $\sigma_i>0$. Given explicit distributions, the running time is $O(nm)$ and storage is $O(n)$ if branchwise diagnostics are retained.

Floating-point implementations should use a numerical tolerance. Such a tolerance is an engineering device, not part of the exact theorem. Near equality, higher precision or interval arithmetic is appropriate.

### 7.3 Deterministic pushforward algorithm

Represent $f_i$ as an array of output indices. Initialize an output vector with zeros, and for each input state $x$, add $p_i(x)$ to the entry indexed by $f_i(x)$. This computes $(f_i)_*p_i$ in $O(m)$ time per branch. Entropies and compensations are then evaluated as above, for total complexity $O(nm)$ when input and output state spaces have comparable finite sizes.

## 8. Applications

### 8.1 Information erasure

A logical operation may merge states and reduce the Shannon entropy of a computational subsystem. The deterministic theorem identifies the reduction exactly as $H(p)-H(f_*p)$. If the environment acquires at least this amount branch by branch, the ensemble obeys the weak second law; strict excess on positive support forces strict growth.

### 8.2 Coarse-grained histories

Branches can represent recorded histories or macrostates, while $p_i$ describes unresolved microscopic uncertainty conditional on a history. Fixed history weights leave the mixing entropy unchanged. The total change is therefore controlled solely by weighted conditional production.

### 8.3 Stochastic scenario ensembles

In risk or scenario models, $w_i$ may represent the likelihood of scenario $i$. The theory distinguishes uncertainty among scenarios from uncertainty within each scenario. If the scenario probabilities remain fixed, local entropy budgets aggregate linearly. The support condition warns that a dramatic effect in a scenario assigned zero probability does not alter an expected total.

### 8.4 Measurement records

A branch may encode a finite measurement record, with a conditional distribution over unobserved microscopic states. The framework then describes a classical register of records coupled to branchwise states and environments. The present theorem concerns classical finite data; a quantum extension would replace conditional probability distributions by density operators.

## 9. Discussion and limitations

The principal virtue of the framework is its exactness. No asymptotic limit is needed, and strictness reduces to a positive term in a finite nonnegative sum. This also exposes the precise failure modes.

First, strict total growth is not unconditional. Branchwise exact compensation gives equality. Second, a strict surplus on a zero-weight branch has no global effect. Third, the branch distribution is fixed. If weights evolve, the branch mixing entropy changes and weighted conditional terms can be redistributed. Without a transport rule connecting old and new branches, changing weights can alter total entropy arbitrarily.

Fourth, all sets are finite. Countably infinite ensembles require absolute convergence or another summation framework, as well as tail controls strong enough to preserve strictness. Fifth, environmental entropy is an explicit scalar assigned to each branch. The theory does not derive it from temperature, heat flow, Hamiltonian dynamics, or reservoir microstates. Sixth, local decrease refers specifically to microscopic Shannon entropy. It does not assert that the combined microscopic and environmental entropy of that branch decreases.

The branchwise compensation hypothesis is stronger than requiring only $\sum_iw_i\sigma_i\ge0$. Its advantage is locality: no branch is allowed an uncompensated deficit. If cross-branch transfers are physically meaningful, a more general theory could permit negative $\sigma_i$ provided transport terms are modeled explicitly.

The terminology “cross-reality” is interpretive rather than mathematical. The same finite structure applies to alternatives, histories, records, modes, or scenarios. The theorems do not depend on an ontological claim about parallel universes.

## 10. Future work

Several directions follow naturally.

1. **Evolving branch weights.** Introduce a stochastic transport kernel and separate conditional production from mixing-entropy production. A strict law should require nonnegative combined production and positive production on a set of positive transported mass.

2. **Countable ensembles.** Extend the weighted identity under summability, finite conditional entropy, and uniform-integrability assumptions. The key issue is preventing entropy production from escaping into tails.

3. **Quantum channels.** Replace branchwise distributions by density operators and Shannon entropy by von Neumann entropy. For block-diagonal classical-quantum states, the total entropy naturally splits into classical mixing entropy plus average conditional quantum entropy.

4. **Fluctuation-sensitive laws.** Supplement mean entropy growth with exponential tail bounds for negative production, potentially combining branch mixing with work-fluctuation relations.

5. **Rigidity.** Develop equality classifications for richer dynamical models. In the present finite compensated setting, equality already means zero net production on every positive-weight branch.

## 11. Conclusion

For a finite ensemble with fixed branch weights, total entropy admits the exact balance

$$
\Delta S=\sum_{i\in I}w_i(X_i-L_i).
$$

This yields a local-to-global second law. Environmental export that covers microscopic loss on every branch implies nondecrease of total entropy. Strict surplus on one positive-weight branch implies strict increase. The conclusion remains compatible with strict microscopic entropy loss in any designated branch. Under deterministic updates, data processing supplies a canonical nonnegative loss, and environmental compensation completes the argument.

The result is a precise entropy ledger for finite alternatives: mixing uncertainty, conditional microscopic uncertainty, and environmental entropy occupy distinct columns, while strictness is detected exactly on positive statistical support.