# Tropical Shtarkov Sums: Packing, Counting, and a State-Budget Phase Transition for Finite-State Sources

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

The Shtarkov sum $S(\mathcal{P}) = \sum_{x} \sup_{\theta} P_\theta(x)$ of a parametric family of probability measures on a finite sample space is the normalising constant of the normalised maximum-likelihood distribution, and its logarithm is the exact minimax pointwise regret of the family. We observe that the inner supremum is a tropical (max-plus) sum of log-likelihoods, so that $S$ is the ordinary mass of the tropicalisation of the class, and we develop two structural principles for it: a *packing* lower bound, which converts any assignment of models to samples into a lower bound on $S$, and a *sufficient-statistic* upper bound, which shows that if the pointwise supremum is dominated by a family of sub-probability measures indexed by the values of a statistic $T$, then $S \le |\mathrm{im}\,T|$.

Applying these to the class of binary sources emitted by a fixed deterministic $k$-state automaton with one free Bernoulli parameter per state, we prove: (i) the class is a probability model, and its likelihood factorises through the vector of per-state emission counts; (ii) the maximum-likelihood plug-in source dominates every member of the class pointwise, so the tropical envelope is attained; (iii) consequently $S_n \le \big((n+1)^2\big)^k$ for every $k$-state automaton, i.e. the minimax regret is at most $2k\log(n+1)$, uniformly in the transition structure; (iv) for a single-state (memoryless) machine the sharpened bound $S_n \le n+1$ holds. On the lower side, the $(n{+}1)$-state counter machine memorises every word, giving $S_n = 2^n$ exactly and regret $n\log 2$. These combine into a **state-budget phase transition**: with $k(n) = \lfloor\sqrt n\rfloor + 1$ states the per-symbol minimax redundancy tends to $0$ for *every* family of automata, while with $k(n) = n+1$ states it equals $\log 2$ — the maximum possible — for every $n \ge 1$.

We also give an entropy-side reformulation: the pointwise supremum equals $e^{-\hat H_M(x)}$, where $\hat H_M$ is the empirical state-conditional entropy of $x$, so $S_n$ is the partition function of empirical entropy, and the counting bound becomes a Kraft-type inequality $\sum_x e^{-\hat H_M(x)} \le (n+1)^{2k}$. Two structural laws round out the theory: the Shtarkov sum tensorises over independent products of classes with attained envelopes, and it is monotone under automaton refinement. A pigeonhole consequence bounds the memorisation capacity of automata: a $k$-state machine can assign probability $1$ to at most $(n+1)^{2k}$ words of length $n$.

**Keywords:** tropical semiring, max-plus algebra, Shtarkov sum, normalised maximum likelihood, minimax regret, universal source coding, finite-state sources, empirical entropy, Kraft inequality, phase transition.

---

## 1. Introduction

### 1.1 Regret and the hindsight opponent

Fix a finite sample space $X$ and a family $\mathcal{P} = \{P_\theta\}_{\theta \in \Theta}$ of probability measures on $X$. A *universal code* for $\mathcal{P}$ is a single probability measure $Q$ on $X$; its *pointwise regret* on a sample $x$ is

$$R_Q(x) \;=\; \log \frac{\sup_{\theta} P_\theta(x)}{Q(x)},$$

the excess codelength (in nats) of $Q$ over the hindsight-optimal member of the family. The minimax problem $\min_Q \max_x R_Q(x)$ has an exact and famously clean solution: the minimiser is the *normalised maximum-likelihood* (NML) measure

$$Q^\star(x) \;=\; \frac{\sup_\theta P_\theta(x)}{S(\mathcal{P})}, \qquad S(\mathcal{P}) \;=\; \sum_{x \in X} \sup_\theta P_\theta(x),$$

and the minimax value is $\log S(\mathcal{P})$. The normalising constant $S(\mathcal{P})$ is the **Shtarkov sum** of the class. It is a single number that encodes the entire worst-case behaviour of the model family.

### 1.2 The tropical viewpoint

The inner supremum resists the usual algebra of sums. Under a logarithm, however, it becomes an ordinary sum in a different semiring. Recall the *tropical* (max-plus) semiring $\mathbb{T} = (\mathbb{R}\cup\{-\infty\}, \oplus, \odot)$ with $u \oplus v = \max(u,v)$ and $u \odot v = u + v$. Then

$$\log \sup_\theta P_\theta(x) \;=\; \bigoplus_\theta \log P_\theta(x),$$

and, since likelihoods multiply along a sequence, each $\log P_\theta(x)$ is itself a tropical product of per-symbol log-weights. Thus:

- the map $\theta \mapsto \log P_\theta(\cdot)$ turns the model class into a family of tropical polynomials in the log-parameters;
- the pointwise supremum $x \mapsto \sup_\theta P_\theta(x)$ is the (exponentiated) **tropicalisation** of the class;
- the Shtarkov sum is the ordinary total mass of that tropicalisation.

The consequence we exploit is methodological. Tropical objects are piecewise-linear and combinatorial; their invariants are governed by lattice-point counts and polyhedral subdivisions rather than by analysis. Correspondingly, the two principles we develop below — packing and counting — are purely combinatorial, and the *only* analytic ingredient in the entire development is the one-dimensional maximum-likelihood inequality of §3, itself a two-atom instance of Gibbs' inequality.

### 1.3 Contributions

1. **Two general tools** (§2): a packing lower bound and a sufficient-statistic upper bound for arbitrary Shtarkov sums on finite sample spaces.
2. **The finite-state class** (§4): definition, normalisation, count factorisation, and attainment of the tropical envelope at the maximum-likelihood plug-in.
3. **The counting bound** (§5): $S_n(M) \le (n+1)^{2k}$ uniformly over $k$-state automata; the sharpened memoryless bound $S_n \le n+1$.
4. **Saturation and the phase transition** (§6): $S_n = 2^n$ exactly for the counter machine, and the resulting dichotomy in the state budget $k(n)$.
5. **The entropy bridge** (§7): $S_n = \sum_x e^{-\hat H_M(x)}$ and a Kraft-type inequality for empirical entropy.
6. **Structural laws** (§8): tensorisation, monotonicity under refinement, and a memorisation-capacity pigeonhole for automata.

---

## 2. The abstract layer: two principles

Throughout this section $X$ is a finite set, $\iota$ a nonempty index set, and $P : \iota \times X \to \mathbb{R}$ a family of real-valued weights written $P_i(x)$.

**Definition 2.1 (Shtarkov sum).** The *Shtarkov sum* of the family $P$ is
$$S(P) \;=\; \sum_{x \in X} \, \sup_{i \in \iota} P_i(x).$$
Its logarithm is the minimax pointwise regret of the class.

We always assume the uniform bound $0 \le P_i(x) \le 1$, under which the inner supremum is a supremum of a nonempty set bounded above by $1$, hence a genuine real number. (This is worth stating explicitly: the index set $\iota$ may be infinite — in our application it is the parameter cube $[0,1]^k$ — so the supremum is not automatically finite, and boundedness must be supplied.)

**Lemma 2.2 (boundedness).** If $P_i(x) \le 1$ for all $i, x$, then for each $x$ the set $\{P_i(x) : i \in \iota\}$ is bounded above, with $1$ an upper bound. $\square$

### 2.1 The packing lower bound

**Theorem 2.3 (packing).** Let $0 \le P_i(x) \le 1$ for all $i,x$. For every finite subset $A \subseteq X$ and every assignment $f : X \to \iota$ of models to samples,
$$\sum_{a \in A} P_{f(a)}(a) \;\le\; S(P).$$

*Proof.* For each $a \in A$, $P_{f(a)}(a) \le \sup_i P_i(a)$ since $f(a)$ is one competitor in the supremum, which exists by Lemma 2.2. Summing over $A$ gives $\sum_{a\in A} P_{f(a)}(a) \le \sum_{a\in A}\sup_i P_i(a)$. Finally, each term $\sup_i P_i(x)$ is nonnegative — it dominates $P_{i_0}(x) \ge 0$ for any fixed $i_0$ — so enlarging the index set of summation from $A$ to $X$ cannot decrease the sum. $\square$

The interpretation: a class that can *memorise* many samples (give each of them likelihood close to $1$ under some member) necessarily has large Shtarkov sum, hence large regret. Packing is how all worst-case lower bounds in universal coding are produced.

### 2.2 The sufficient-statistic upper bound

**Theorem 2.4 (counting).** Let $T : X \to Y$ be a statistic and $\{q_y\}_{y \in Y}$ a family of nonnegative weights on $X$ with $\sum_{x \in X} q_y(x) \le 1$ for each $y$ (a family of sub-probability measures). Suppose the *domination hypothesis*
$$P_i(x) \;\le\; q_{T(x)}(x) \qquad \text{for all } i \in \iota,\; x \in X$$
holds. Then
$$S(P) \;\le\; \big|\,T(X)\,\big|,$$
the number of values actually taken by $T$; in particular $S(P) \le |Y|$ if $Y$ is finite.

*Proof.* By domination and the definition of supremum, $\sup_i P_i(x) \le q_{T(x)}(x)$ pointwise, so $S(P) \le \sum_{x} q_{T(x)}(x)$. Decompose the right-hand side over the fibres of $T$:
$$\sum_{x \in X} q_{T(x)}(x) \;=\; \sum_{y \in T(X)} \ \sum_{x : T(x) = y} q_{y}(x).$$
For each fixed $y$, the inner sum runs over a subset of $X$ and the summands are nonnegative, hence it is at most $\sum_{x \in X} q_y(x) \le 1$. There are $|T(X)|$ outer terms, each at most $1$. $\square$

Two remarks. First, the theorem is a *pure counting* statement: the bound is the cardinality of the image of a statistic, with no analysis whatsoever. Second, it is deliberately wasteful: it charges a full unit of mass to each fibre, whereas the actual mass a fibre carries is typically much smaller. Making that waste precise is the route to sharp constants (§9).

**Corollary 2.5 (trivial cap).** If $P_i(x) \le 1$ for all $i,x$ then $S(P) \le |X|$. (Take $T$ to be the identity and $q_x = \delta_x$; or simply bound each term by $1$.) $\square$

---

## 3. The one-dimensional maximum-likelihood inequality

**Definition 3.1.** For $a,b \in \mathbb{N}$, the *maximum-likelihood Bernoulli parameter* is
$$\hat\theta(a,b) \;=\; \begin{cases} \dfrac{a}{a+b}, & a + b > 0,\\[4pt] 0, & a = b = 0.\end{cases}$$
It satisfies $0 \le \hat\theta(a,b) \le 1$.

**Theorem 3.2 (Bernoulli ML inequality).** For all $a, b \in \mathbb{N}$ and all $\theta \in [0,1]$,
$$\theta^a (1-\theta)^b \;\le\; \hat\theta(a,b)^{a}\,\big(1 - \hat\theta(a,b)\big)^{b}.$$

*Proof.* If $a = 0$ then $\hat\theta = 0$ and the claim is $(1-\theta)^b \le 1$; if $b = 0$ then $\hat\theta = 1$ and the claim is $\theta^a \le 1$. Both hold since $\theta \in [0,1]$. So assume $a, b \ge 1$; then $t := \hat\theta = a/(a+b)$ satisfies $0 < t < 1$ and $1 - t = b/(a+b)$, and the right-hand side is strictly positive. If $\theta \in \{0,1\}$ the left-hand side vanishes and we are done; so assume $0 < \theta < 1$ and take logarithms. The claim becomes
$$a\log\theta + b\log(1-\theta) \;\le\; a\log t + b\log(1-t),$$
i.e. $a(\log\theta - \log t) + b(\log(1-\theta) - \log(1-t)) \le 0$. By the elementary inequality $\log u \le u - 1$ for $u > 0$, applied to $u = \theta/t$ and $u = (1-\theta)/(1-t)$,
$$a\left(\log\frac{\theta}{t}\right) + b\left(\log\frac{1-\theta}{1-t}\right) \;\le\; a\left(\frac{\theta}{t} - 1\right) + b\left(\frac{1-\theta}{1-t} - 1\right).$$
Substituting $t = a/(a+b)$ and $1-t = b/(a+b)$, the right-hand side equals
$$\theta(a+b) - a + (1-\theta)(a+b) - b \;=\; (a+b) - (a+b) \;=\; 0. \qquad \square$$

The exact cancellation is the signature of Gibbs' inequality: the first-order term of the Kullback–Leibler divergence between the empirical distribution and $\theta$ vanishes precisely because $\hat\theta$ is the empirical mean.

The role of Theorem 3.2 in what follows is not merely that a maximiser exists, but that the maximiser is *a function of the counts only*. This is exactly the hypothesis of Theorem 2.4.

---

## 4. Finite-state sources

### 4.1 Machines, words, and likelihoods

**Definition 4.1 (automaton).** A *deterministic binary finite-state machine* with $k$ states is a pair $M = (s_0, \delta)$ with initial state $s_0 \in \{1,\dots,k\}$ and transition map $\delta : \{1,\dots,k\} \times \{0,1\} \to \{1,\dots,k\}$.

Write $\{0,1\}^n$ for the set of binary words of length $n$. For a word $x$ and $0 \le i \le n$, let $\sigma_i(x)$ be the state reached after reading the first $i$ symbols: $\sigma_0(x) = s_0$ and $\sigma_{i+1}(x) = \delta(\sigma_i(x), x_i)$.

**Definition 4.2 (source).** Given a parameter vector $\theta \in [0,1]^k$, define the emission weight $w_\theta(s, b) = \theta_s$ if $b = 1$ and $1 - \theta_s$ if $b = 0$, and set
$$P^M_\theta(x) \;=\; \prod_{i=0}^{n-1} w_\theta\big(\sigma_i(x),\, x_i\big).$$
The *finite-state class* of $M$ at horizon $n$ is $\mathcal{P}^M_n = \{P^M_\theta(\cdot)\}_{\theta \in [0,1]^k}$.

Clearly $0 \le P^M_\theta(x) \le 1$, since each factor lies in $[0,1]$.

**Theorem 4.3 (normalisation).** For every $M$, every $\theta \in [0,1]^k$, every $n$, and every start state $s$, the measure $P^{M,s}_\theta$ obtained by starting in $s$ satisfies $\sum_{x \in \{0,1\}^n} P^{M,s}_\theta(x) = 1$.

*Proof.* Induction on $n$, generalising over the start state. For $n = 0$ the empty product is $1$ and there is exactly one word. For the step, split a word $x$ of length $n+1$ as $x = b \cdot y$ with $b \in \{0,1\}$ and $y$ of length $n$. The first factor of the product is $w_\theta(s, b)$ and the remaining factors are precisely those of $P^{M,\delta(s,b)}_\theta(y)$, because after reading $b$ the machine is in state $\delta(s,b)$ and reads $y$. Hence
$$\sum_{x} P^{M,s}_\theta(x) \;=\; \sum_{b \in \{0,1\}} w_\theta(s,b) \sum_{y} P^{M,\delta(s,b)}_\theta(y) \;=\; \sum_{b} w_\theta(s,b) \cdot 1 \;=\; \theta_s + (1-\theta_s) \;=\; 1,$$
the middle equality by the induction hypothesis applied at the start state $\delta(s,b)$. $\square$

The generalisation over the start state is essential: the statement for the fixed initial state $s_0$ alone is not inductive.

### 4.2 The count factorisation

**Definition 4.4 (visit counts).** For a word $x$ of length $n$, a state $s$ and a symbol $b$, let
$$v_{s,b}(x) \;=\; \#\{\, 0 \le i < n \ : \ \sigma_i(x) = s \text{ and } x_i = b \,\},$$
and write $a_s(x) = v_{s,1}(x)$, $b_s(x) = v_{s,0}(x)$. Each count lies in $\{0,\dots,n\}$, and the counts partition the time axis:
$$\sum_{s=1}^{k} \big(a_s(x) + b_s(x)\big) \;=\; n .$$

**Theorem 4.5 (factorisation).** For every $M$, $\theta$, $n$, $x$,
$$P^M_\theta(x) \;=\; \prod_{s=1}^{k} \theta_s^{\,a_s(x)}\,(1-\theta_s)^{\,b_s(x)}.$$

*Proof.* Partition the index set $\{0,\dots,n-1\}$ of the defining product into the fibres of the map $i \mapsto (\sigma_i(x), x_i)$. On the fibre over $(s,b)$ every factor equals $w_\theta(s,b)$, and the fibre has $v_{s,b}(x)$ elements, so the sub-product is $w_\theta(s,b)^{v_{s,b}(x)}$. Multiplying over the $2k$ pairs and grouping the two symbols of each state gives the claim. $\square$

The determinism of $M$ is what makes the counts functions of $x$ alone; this is the whole reason the class has a finite-dimensional sufficient statistic.

### 4.3 Attainment of the tropical envelope

**Definition 4.6 (plug-in source).** Let $\hat\theta(x) \in [0,1]^k$ be the vector with coordinates $\hat\theta(x)_s = \hat\theta\big(a_s(x), b_s(x)\big)$ in the sense of Definition 3.1.

**Theorem 4.7 (maximum-likelihood domination).** For every $\theta \in [0,1]^k$ and every word $x$,
$$P^M_\theta(x) \;\le\; P^M_{\hat\theta(x)}(x).$$
Consequently $\sup_{\theta} P^M_\theta(x) = P^M_{\hat\theta(x)}(x)$: the tropical envelope of the finite-state class is attained, at the empirical model.

*Proof.* Apply Theorem 4.5 to both sides and compare factor by factor: for each state $s$, Theorem 3.2 with $(a,b) = (a_s(x), b_s(x))$ gives $\theta_s^{a_s}(1-\theta_s)^{b_s} \le \hat\theta(x)_s^{a_s}(1-\hat\theta(x)_s)^{b_s}$. All factors are nonnegative, so the products compare in the same direction. Attainment follows because $\hat\theta(x)$ is itself a member of the parameter cube. $\square$

---

## 5. The counting bound

**Theorem 5.1 (finite-state Shtarkov bound).** For every $k$-state automaton $M$ and every $n \ge 0$,
$$S_n(M) \;:=\; \sum_{x \in \{0,1\}^n} \max_{\theta \in [0,1]^k} P^M_\theta(x) \;\le\; \big((n+1)^2\big)^{k},$$
equivalently the minimax pointwise regret satisfies $\log S_n(M) \le 2k\log(n+1)$.

*Proof.* Apply Theorem 2.4 with the statistic
$$T(x) \;=\; \big(a_s(x), b_s(x)\big)_{s=1}^{k} \ \in\ \{0,\dots,n\}^{2k} \;=:\; Y,$$
and, for each $y \in Y$, the sub-probability measure $q_y := P^M_{\hat\theta[y]}$, where $\hat\theta[y]_s = \hat\theta(y_{s,1}, y_{s,0})$ is the plug-in parameter vector read off from $y$. Three hypotheses must be checked.
*Domination:* $\hat\theta[T(x)] = \hat\theta(x)$ by construction, so Theorem 4.7 gives $P^M_\theta(x) \le q_{T(x)}(x)$ for all $\theta$.
*Nonnegativity:* immediate from Definition 4.2.
*Sub-normalisation:* each $q_y$ is a genuine probability measure on $\{0,1\}^n$ by Theorem 4.3, so its total mass is exactly $1 \le 1$.
Theorem 2.4 then bounds $S_n(M)$ by $|Y| = (n+1)^{2k}$. $\square$

Three comments.

- **Uniformity.** The bound depends on the automaton only through its number of states. No connectivity, aperiodicity, or irreducibility hypothesis is needed.
- **The universal cap.** By Corollary 2.5, $S_n(M) \le 2^n$ always, so the effective bound is $\min\{(n+1)^{2k}, 2^n\}$, and the counting bound is informative exactly when $2k\log(n+1) < n\log 2$.
- **The floor.** By Theorem 2.3 with $A = \{0,1\}^n$ and any constant assignment $f \equiv \theta_0$, we get $S_n(M) \ge \sum_x P^M_{\theta_0}(x) = 1$. So $1 \le S_n(M)$ always, and $\log S_n \ge 0$: regret is never negative.

**Theorem 5.2 (memoryless sharpening).** For a single-state machine $M$ (so $k = 1$, and the class is the full Bernoulli family) and every $n$,
$$S_n(M) \;\le\; n+1, \qquad \text{hence} \qquad \log S_n(M) \le \log(n+1) \quad\text{and}\quad \frac{\log S_n(M)}{n} \le \frac{\log(n+1)}{n}.$$

*Proof.* With one state, the two counts satisfy $a_1(x) + b_1(x) = n$, so $b_1(x) = n - a_1(x)$ is determined by $a_1(x)$. Run the proof of Theorem 5.1 with the reduced statistic $T(x) = a_1(x) \in \{0,\dots,n\}$ and the plug-in $q_y = P^M_{\hat\theta(y, n-y)}$. The domination and normalisation hypotheses are unchanged, and $|Y| = n+1$. $\square$

The generic bound would have given $(n+1)^2$ here; eliminating the redundant coordinate saves a full factor of $n$. The same elimination applies to any state: the counts obey the single linear relation $\sum_s (a_s + b_s) = n$, which the generic bound ignores, and further linear (Kirchhoff-type) relations hold whenever the transition graph is constrained.

---

## 6. Saturation and the state-budget phase transition

### 6.1 The counter machine

**Definition 6.1.** The *counter machine* $C_n$ has $n+1$ states $\{0,1,\dots,n\}$, initial state $0$, and transition $\delta(s, b) = \min(s+1, n)$, independent of $b$. After reading $i$ symbols it is in state $\min(i, n)$; in particular, for $i < n$ it is in state $i$.

Thus $C_n$ assigns a private Bernoulli parameter to each time index up to $n$.

**Lemma 6.2 (memorisation).** Let $m \le n$ and let $z \in \{0,1\}^m$. Define $\theta^{(z)} \in [0,1]^{n+1}$ by $\theta^{(z)}_s = z_s$ for $s < m$ (as a $0/1$ value) and $\theta^{(z)}_s = 0$ otherwise. Then $P^{C_n}_{\theta^{(z)}}(z) = 1$.

*Proof.* At time $i < m \le n$ the machine is in state $i$, and the emission weight is $w_{\theta^{(z)}}(i, z_i)$, which equals $\theta^{(z)}_i = 1$ if $z_i = 1$, and $1 - \theta^{(z)}_i = 1$ if $z_i = 0$. Every factor of the defining product is $1$. $\square$

**Theorem 6.3 (saturation).** For $m \le n$, $\ S_m(C_n) = 2^m$. In particular $S_n(C_n) = 2^n$ and the minimax regret of the $(n{+}1)$-state counter class at horizon $n$ is exactly $n\log 2$: no compression is possible in the worst case.

*Proof.* Lower bound: apply Theorem 2.3 with $A = \{0,1\}^m$ and $f(z) = \theta^{(z)}$; by Lemma 6.2 each term is $1$, so $S_m(C_n) \ge |A| = 2^m$. Upper bound: Corollary 2.5 gives $S_m \le 2^m$. $\square$

### 6.2 The dichotomy

**Definition 6.4.** The *regret* of $M$ at horizon $n$ is $\rho(M, n) = \log S_n(M) \ge 0$, and the *regret rate* is $\rho(M,n)/n$, the per-symbol worst-case redundancy.

**Theorem 6.5 (regret rate vanishes under a sub-linear state budget).** Let $k : \mathbb{N} \to \mathbb{N}$ be a state budget and $M_n$ any automaton with $k(n)$ states. If
$$\frac{k(n)\,\log(n+1)}{n} \;\longrightarrow\; 0,$$
then $\rho(M_n, n)/n \to 0$.

*Proof.* By Theorem 5.1, $0 \le \rho(M_n,n)/n \le 2\,k(n)\log(n+1)/n$, and both bounding sequences tend to $0$; conclude by squeezing. $\square$

**Lemma 6.6.** The budget $k(n) = \lfloor\sqrt n\rfloor + 1$ satisfies the hypothesis of Theorem 6.5.

*Proof.* For $n \ge 1$ we have $\lfloor\sqrt n\rfloor + 1 \le 2\sqrt n$, so
$$\frac{(\lfloor\sqrt n\rfloor+1)\log(n+1)}{n} \;\le\; \frac{2\sqrt n \log(n+1)}{n} \;=\; \frac{2\log(n+1)}{\sqrt n} \;\le\; \frac{4\log(n+1)}{\sqrt{n+1}},$$
using $\sqrt{n+1} \le 2\sqrt n$. Since $\log y/\sqrt y \to 0$ as $y \to \infty$ (substitute $y = t^2$ and use $\log t / t \to 0$), the right-hand side tends to $0$. $\square$

**Theorem 6.7 (state-budget phase transition).** Both of the following hold.

1. *(Vanishing side.)* For **every** family of automata $M_n$ with $\lfloor\sqrt n\rfloor + 1$ states, $\ \rho(M_n, n)/n \to 0$.
2. *(Saturated side.)* For the counter family with $n+1$ states, $\ \rho(C_n, n)/n = \log 2$ for every $n \ge 1$.

*Proof.* (1) is Theorem 6.5 with Lemma 6.6. (2) is Theorem 6.3: $\rho(C_n,n) = \log 2^n = n\log 2$. $\square$

This is a dichotomy in the strongest possible sense, not a matter of constants. On the sub-linear side the per-symbol overhead is *asymptotically free*, uniformly over all automata with that many states — the transition structure cannot help or hurt. On the linear side the per-symbol overhead is *exactly maximal*: the model class has degenerated into a lookup table, which explains nothing and compresses nothing. The threshold sits at $k(n) \asymp n / \log n$, where $2k(n)\log(n+1)$ crosses $n\log 2$.

---

## 7. The entropy bridge

Write $h(p) = -p\log p - (1-p)\log(1-p)$ for the binary entropy in nats, with $h(0) = h(1) = 0$ by continuity; $0 \le h(p) \le \log 2$ on $[0,1]$, with maximum at $p = 1/2$.

**Lemma 7.1 (ML factor as an exponentiated entropy).** For all $a,b \in \mathbb{N}$,
$$\hat\theta(a,b)^{a}\,\big(1-\hat\theta(a,b)\big)^{b} \;=\; \exp\!\big(-(a+b)\,h(\hat\theta(a,b))\big).$$

*Proof.* If $a = b = 0$ both sides are $1$. Otherwise set $t = a/(a+b)$; then $a = (a+b)t$ and $b = (a+b)(1-t)$. The logarithm of the left-hand side is $a\log t + b\log(1-t) = (a+b)\big(t\log t + (1-t)\log(1-t)\big) = -(a+b)h(t)$. (Each factor is strictly positive whenever its exponent is nonzero: $t > 0$ when $a > 0$ and $t < 1$ when $b > 0$, so the logarithms are legitimate.) $\square$

**Definition 7.2 (empirical entropy).** The *empirical state-conditional entropy* of a word $x$ relative to $M$ is
$$\hat H_M(x) \;=\; \sum_{s=1}^{k}\big(a_s(x)+b_s(x)\big)\, h\!\left(\hat\theta(a_s(x), b_s(x))\right).$$

It is the ideal codelength of $x$ under a state-conditional code whose per-state coin biases are fitted to $x$ after the fact.

**Theorem 7.3 (the Shtarkov sum is a partition function).** For every $M$ and $n$,
$$\max_{\theta} P^M_\theta(x) \;=\; e^{-\hat H_M(x)} \qquad\text{for every } x, \qquad\text{hence}\qquad S_n(M) \;=\; \sum_{x \in \{0,1\}^n} e^{-\hat H_M(x)}.$$

*Proof.* By Theorem 4.7 the maximum equals $P^M_{\hat\theta(x)}(x)$, which by Theorem 4.5 factorises as $\prod_s \hat\theta(x)_s^{a_s}(1-\hat\theta(x)_s)^{b_s}$. Apply Lemma 7.1 in each state and multiply; the exponents add to $-\hat H_M(x)$. Summing over $x$ gives the second statement. $\square$

**Theorem 7.4 (Kraft-type inequality for empirical entropy).** For every $k$-state automaton and every $n$,
$$\sum_{x \in \{0,1\}^n} e^{-\hat H_M(x)} \;\le\; \big((n+1)^2\big)^{k}.$$

*Proof.* Immediate from Theorems 7.3 and 5.1. $\square$

Kraft's inequality says that the codeword lengths of a prefix code satisfy $\sum_x e^{-\ell(x)} \le 1$. The quantities $\hat H_M(x)$ are *not* codeword lengths of any single code — they are obtained by refitting the model to each $x$ — and Theorem 7.4 quantifies exactly how much they may violate Kraft: by a factor at most $(n+1)^{2k}$, i.e. by at most $2k\log(n+1)$ nats. This is the model-cost term of minimum description length, derived here purely by counting.

**Proposition 7.5 (range of empirical entropy).** $0 \le \hat H_M(x) \le n\log 2$ for every $x$.

*Proof.* Nonnegativity is termwise, since $h \ge 0$ and the counts are nonnegative. For the upper bound, $h \le \log 2$ termwise gives $\hat H_M(x) \le \log 2 \sum_s (a_s + b_s) = n\log 2$, since the visit counts partition $\{0,\dots,n-1\}$. $\square$

Combined with Theorem 7.3 this recovers both $S_n \ge 1$ (some word has $\hat H = 0$; e.g. the all-zeros word) and $S_n \le 2^n$ from the entropy side.

---

## 8. Structural laws

### 8.1 Tensorisation

**Theorem 8.1 (regret is additive over independent components).** Let $\{P_i\}_{i\in\iota}$ on $X$ and $\{Q_j\}_{j\in\kappa}$ on $Y$ be classes with values in $[0,1]$, and suppose both have *attained* envelopes: there are $f_P : X \to \iota$ and $f_Q : Y \to \kappa$ with $P_i(x) \le P_{f_P(x)}(x)$ and $Q_j(y) \le Q_{f_Q(y)}(y)$ for all indices and points. Let the product class on $X\times Y$ be $(P\otimes Q)_{(i,j)}(x,y) = P_i(x)Q_j(y)$. Then
$$S(P \otimes Q) \;=\; S(P)\cdot S(Q).$$

*Proof.* At a point $(x,y)$ the supremum over $(i,j)$ of $P_i(x)Q_j(y)$ is attained at $(f_P(x), f_Q(y))$: indeed $P_i(x)Q_j(y) \le P_{f_P(x)}(x)Q_j(y) \le P_{f_P(x)}(x)Q_{f_Q(y)}(y)$, using nonnegativity at each step. Hence the pointwise supremum of the product class is the product of the pointwise suprema, and
$$S(P\otimes Q) = \sum_{(x,y)} \Big(\sup_i P_i(x)\Big)\Big(\sup_j Q_j(y)\Big) = \Big(\sum_x \sup_i P_i(x)\Big)\Big(\sum_y \sup_j Q_j(y)\Big). \ \square$$

Taking logarithms: minimax regret is additive over independent components. This is why regret scales linearly in the number of free parameters and behaves like a dimension count; it is also the multiplicativity of tropicalisation under products.

### 8.2 Monotonicity under refinement

**Definition 8.2 (simulation).** An automaton $M'$ with $k'$ states *simulates* $M$ with $k$ states if there is $\pi : \{1,\dots,k'\}\to\{1,\dots,k\}$ with $\pi(s'_0) = s_0$ and $\pi(\delta'(s,b)) = \delta(\pi(s), b)$ for all $s, b$. ($M'$ is then a *refinement* of $M$.)

**Lemma 8.3.** If $M'$ simulates $M$ via $\pi$, then $\pi(\sigma'_i(x)) = \sigma_i(x)$ for all $i$ and $x$, and consequently $P^M_\theta = P^{M'}_{\theta \circ \pi}$ for every $\theta \in [0,1]^k$.

*Proof.* The first claim is induction on $i$: the base case is $\pi(s'_0) = s_0$, and the step is the intertwining property. For the second, the two defining products have equal factors termwise, since $w_{\theta\circ\pi}(\sigma'_i(x), x_i) = w_\theta(\pi(\sigma'_i(x)), x_i) = w_\theta(\sigma_i(x), x_i)$. $\square$

**Theorem 8.4 (monotonicity).** If $M'$ simulates $M$, then $S_n(M) \le S_n(M')$ for every $n$: refining the state space can only increase the minimax regret.

*Proof.* By Lemma 8.3 every member of $\mathcal{P}^M_n$ is also a member of $\mathcal{P}^{M'}_n$, so at every word the supremum over the larger class dominates. Sum over words. $\square$

### 8.3 Memorisation capacity of automata

**Theorem 8.5 (capacity pigeonhole).** Let $M$ have $k$ states and let $A \subseteq \{0,1\}^n$ be a set of words each of which is *memorisable*, i.e. for each $x \in A$ there is $\theta^{(x)} \in [0,1]^k$ with $P^M_{\theta^{(x)}}(x) \ge 1$. Then
$$|A| \;\le\; \big((n+1)^2\big)^{k}.$$

*Proof.* By packing (Theorem 2.3) with $f(x) = \theta^{(x)}$, $\ |A| = \sum_{x\in A} 1 \le \sum_{x \in A} P^M_{\theta^{(x)}}(x) \le S_n(M)$, and by counting (Theorem 5.1) $S_n(M) \le (n+1)^{2k}$. $\square$

**Corollary 8.6 (automata cannot memorise).** If $(n+1)^{2k} < 2^n$ then there is a word $x \in \{0,1\}^n$ with $P^M_\theta(x) < 1$ for *every* $\theta \in [0,1]^k$. In particular, for a single-state machine and any $n \ge 6$ (where $(n+1)^2 < 2^n$), such a word exists.

*Proof.* If every word were memorisable, Theorem 8.5 with $A = \{0,1\}^n$ would give $2^n \le (n+1)^{2k}$, contradicting the hypothesis. The numerical claim $(n+1)^2 < 2^n$ for $n \ge 6$ follows by induction from $7^2 = 49 < 64 = 2^6$, since doubling outpaces $\left(\frac{n+2}{n+1}\right)^2 \le 2$. $\square$

A $k$-state automaton, however cleverly wired and however finely its $k$ real parameters are tuned, has memorisation capacity at most $2k\log(n+1)$ nats. The uncountable parameter space does not help: it is the *finiteness of the sufficient statistic*, not the cardinality of the parameter set, that bounds capacity. This is the exact analogue, in the max-plus world, of the familiar principle that a model's effective capacity is set by the dimension of its sufficient statistic rather than by the cardinality of its hypothesis class.

---

## 9. Algorithms

The theory is effective, and three algorithms suffice to compute everything numerically for moderate $n$.

**Algorithm A (exact Shtarkov sum by count enumeration).** By Theorems 4.7 and 4.5, the maximised likelihood of $x$ depends only on the count vector $c(x) = (a_s, b_s)_{s}$, and equals $\prod_s \hat\theta(a_s,b_s)^{a_s}(1-\hat\theta(a_s,b_s))^{b_s}$. Therefore
$$S_n(M) \;=\; \sum_{c} N(c) \prod_{s=1}^k \hat\theta(a_s,b_s)^{a_s}\big(1-\hat\theta(a_s,b_s)\big)^{b_s},$$
where $N(c)$ is the number of words with count vector $c$. The multiplicities $N(c)$ can be accumulated by a dynamic program over $(\text{time}, \text{state}, \text{counts})$, or, for small $n$, by direct enumeration of the $2^n$ words. Direct enumeration costs $\Theta(2^n \cdot n)$; the dynamic program costs $O(n \cdot k \cdot |\mathcal{C}_n|)$ where $\mathcal{C}_n$ is the reachable count set, which is polynomial in $n$ for fixed $k$ — a genuine exponential speed-up that is only possible *because* the class has a sufficient statistic.

**Algorithm B (empirical entropy).** For a fixed word, run the automaton, tally the $2k$ counts, and return $\sum_s (a_s+b_s) h(a_s/(a_s+b_s))$. Cost $\Theta(n + k)$. By Theorem 7.3 this is exactly $-\log$ of the maximised likelihood, a useful cross-check of Algorithm A.

**Algorithm C (packing certificate).** Given a set $A$ of words and, for each, a parameter vector, evaluate $\sum_{a\in A}P_{\theta^{(a)}}(a)$; by Theorem 2.3 this is a certified lower bound on $S_n(M)$. For the counter machine with $\theta^{(z)}$ as in Lemma 6.2 the certificate equals $2^n$ exactly, proving saturation numerically.

---

## 10. Discussion

**What the bound really is.** The classical statement "a $d$-parameter family has minimax regret $\tfrac{d}{2}\log n + O(1)$" is usually derived by Laplace approximation of the integral $\int \sqrt{\det I(\theta)}\,d\theta$ over the parameter space, i.e. by genuine asymptotic analysis. The development above shows that a bound of the *right logarithmic order* requires no analysis at all: it is the cardinality of the image of a sufficient statistic. The analysis contributes only the constant $\tfrac{1}{2}$ per parameter, and it does so by replacing "one unit of mass per statistic value" by "the actual mass of the fibre", which is $\Theta(n^{-1/2})$ per parameter because a binomial fibre has Gaussian width $\sqrt n$.

**Why the state count and nothing else.** It is at first surprising that Theorem 5.1 is completely insensitive to the transition structure. The reason is that the counting bound uses only the *range* of the statistic, and the range is contained in a box $\{0,\dots,n\}^{2k}$ for any wiring. Structure enters only through constraints that shrink the range: the universal relation $\sum_s(a_s+b_s) = n$ (worth one factor of $n$, as exploited in Theorem 5.2), and the Kirchhoff-type flow relations forced by the transition graph, since state visits are edge frequencies of a closed walk. Exploiting these would replace the box by a lattice polytope and $(n+1)^{2k}$ by the corresponding Ehrhart count.

**Positioning of the phase transition.** The classical intuition — "more model, more overfitting" — is here made quantitative and, in a sense, reassuring: the overhead of an *unboundedly growing* model class can still be asymptotically negligible per symbol, provided the growth is sub-linear in $n/\log n$. Only at linear growth does the class become a memory. Since practical universal coders (context-tree weighting, dictionary methods) do grow their state space with the data, the theorem is a licence: growth is safe up to a sharp and explicit threshold.

**Limitations.** Three should be stated plainly. (i) The bound $(n+1)^{2k}$ is off by a square root per parameter; it gives $2k\log n$ where the truth is $\tfrac{k}{2}\log n$. (ii) The lower-bound side is currently proved only for the counter machine; for a general strongly connected machine, a matching $\Omega(n^{k/2})$ requires a packing construction on the lattice of realisable count vectors. (iii) The alphabet is binary; the extension to alphabets of size $q$ should replace $(n+1)^2$ by $(n+1)^{q}$ per state and $h$ by the $q$-ary entropy, with no conceptual change.

---

## 11. Future directions

The results assembled above make several sharp questions immediately attackable. We list the two most concrete, each stated so that a single theorem — or a single counterexample — decides it.

**C1. The $\tfrac{k}{2}\log n$ law by tropical counting alone.** *Conjecture:* for every fixed $k \ge 1$ there are constants $0 < c_k \le C_k$ with
$$c_k\, n^{k/2} \;\le\; S_n(M) \;\le\; C_k\, n^{k/2}$$
for every strongly connected $k$-state machine $M$ and all $n \ge k$. The key insight is that the sufficient statistic used in the counting bound is wasteful by exactly one square root per state: the bound charges $(n+1)^2$ per state, while the mass the plug-in distribution concentrates on a single fibre is $\Theta(n^{-1/2})$ per state, precisely the Gaussian width of a binomial fibre. Replacing "one unit per statistic value" by "the actual fibre mass" should convert the counting bound into a sharp estimate with no analytic machinery beyond a Stirling bound for the central binomial coefficient. The three ingredients — the fibre decomposition, the plug-in domination, and the packing device — are all in place; the missing step is a single lower bound of the form $\binom{n}{j}(j/n)^j((n-j)/n)^{n-j} \ge c/\sqrt n$ in the bulk. Numerics already pin the constants to test against: $S_n \approx \sqrt{\pi n/2}$ for $k=1$ and $S_n \approx n$ for $k=2$.

**C2. The image of the count statistic is a polytope of lattice points.** *Conjecture:* for a strongly connected $k$-state machine and $n \ge k^2$, the image of the count statistic is exactly the set of vectors $\big((a_s,b_s)\big)_s$ with $\sum_s (a_s+b_s) = n$ that are realisable as Eulerian-type flows on the transition graph, and its cardinality is $\Theta(n^{2k-1})$. The counting bound $(n+1)^{2k}$ ignores the linear constraint $\sum_s(a_s+b_s)=n$ — already available — and it ignores the Kirchhoff/flow constraints coming from the transition graph: state visits are the edge frequencies of a closed walk, so the statistic lands on the lattice points of a flow polytope. Making this exact would give the first structure-sensitive Shtarkov bound and would immediately shave one power of $n$ off the generic estimate.

Beyond these, natural targets include: a matching lower bound for general strongly connected machines via packing on the realisable count lattice; the $q$-ary alphabet extension; a treatment of context-tree classes as a limit of finite-state classes ordered by the refinement relation of §8.2, where monotonicity gives a coherent notion of a Shtarkov sum for the whole tree; and an operational reading of the state-budget phase transition in terms of the practical performance of adaptive dictionary coders.

---

## 12. Summary of results

| Result | Statement |
|---|---|
| Packing lower bound | $\sum_{a\in A}P_{f(a)}(a) \le S(P)$ for any $A$, $f$ |
| Sufficient-statistic upper bound | $S(P) \le \lvert\mathrm{im}\,T\rvert$ under plug-in domination |
| Bernoulli ML inequality | $\theta^a(1-\theta)^b \le \hat\theta^a(1-\hat\theta)^b$, $\hat\theta = a/(a+b)$ |
| Normalisation | $\sum_x P^M_\theta(x) = 1$ from any start state |
| Count factorisation | $P^M_\theta(x) = \prod_s \theta_s^{a_s}(1-\theta_s)^{b_s}$ |
| Envelope attained | $\sup_\theta P^M_\theta(x) = P^M_{\hat\theta(x)}(x)$ |
| Finite-state Shtarkov bound | $S_n(M) \le \big((n+1)^2\big)^k$; regret $\le 2k\log(n+1)$ |
| Memoryless sharpening | $S_n \le n+1$ for $k = 1$ |
| Universal cap and floor | $1 \le S_n(M) \le 2^n$ |
| Saturation | $S_n(C_n) = 2^n$ exactly; regret $= n\log 2$ |
| Phase transition | rate $\to 0$ at $k(n)=\lfloor\sqrt n\rfloor+1$; rate $=\log 2$ at $k(n)=n+1$ |
| Entropy bridge | $S_n(M) = \sum_x e^{-\hat H_M(x)}$ |
| Kraft-type inequality | $\sum_x e^{-\hat H_M(x)} \le \big((n+1)^2\big)^k$; $0 \le \hat H_M \le n\log 2$ |
| Tensorisation | $S(P\otimes Q) = S(P)S(Q)$ for attained envelopes |
| Refinement monotonicity | $M'$ simulates $M \implies S_n(M) \le S_n(M')$ |
| Memorisation capacity | at most $\big((n+1)^2\big)^k$ words get probability $1$ |
