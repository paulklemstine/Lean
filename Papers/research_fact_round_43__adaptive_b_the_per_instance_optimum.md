# Adaptive Smoothness Bounds in the Quadratic Sieve: A Real Per-Instance Optimum That Only an Oracle Can Reach

**Author:** Aristotle

**Date:** 2026-10-21

---

## Abstract

We study whether the smoothness bound $B$ of the single-polynomial quadratic sieve (QS) should be chosen per instance. In an experiment comprising 1,800 complete sieve runs — 120 validated 41-bit balanced semiprimes, each run at all 15 values of a ladder $B \in [150, 19000]$ with fixed sieve length $M = 150{,}000$ — we price each run by its *paid touch*, the number of elementary sieve operations actually executed. We prove that paid touch equals $2M\sum_{p\in S,\,p\ \mathrm{odd}} 1/p + M/2$ up to an additive error of at most $2|S| - 1$, where $S$ is the factor base, and observe a maximum relative deviation of $2.01 \times 10^{-4}$ on the data. The per-instance optimum $B^{*}$ spans the whole ladder (median $4800$). An oracle selecting $B^{*}$ per instance reduces work to $0.9533\times$ that of the best fixed bound ($B = 9600$), improving $102/120$ instances and worsening none ($t = -11.6$). Yet no rule based on features computable before sieving recovers this gain on held-out data: a stratified rule achieves $1.0047\times$ (a wash) and a regression rule $1.0290\times$ (significantly worse), against an oracle of $0.9590\times$ on the same split. The prize ($0.0478$ log units) is dwarfed by the held-out residual standard deviation ($0.536$): signal-to-noise $0.089$. We explain these findings by a small exact theory of oracle, fixed, and feature-based selection: the ordering *oracle* $\le$ *best feature rule* $\le$ *best fixed value*, the attainment of the middle term by per-fibre minimisation, an exact zero-gain criterion (a feature helps if and only if its fibres disagree on the optimal $B$), in-sample monotonicity under refinement, and an explicit train/test reversal. Finally we show that the observed elasticity $d\log Q/d\log m = 0.99718 \pm 0.03722$ between the split-prime count $Q$ and the factor-base size $m$ is, up to $O(c/Q)$, a bookkeeping identity: if $m = Q + c$ then every secant elasticity lies in $[1, 1 + c/Q_1]$. Adaptive $B$ is therefore a validated negative as an implementable method; the multi-polynomial sieve remains the only open decoupling channel in this family.

---

## 1. Introduction

The quadratic sieve factors an integer $N$ by collecting many values of a quadratic polynomial that are *smooth* — composed only of primes below a bound $B$ — and combining them via linear algebra over $\mathbb{F}_2$ into a congruence of squares. The smoothness bound $B$ is the algorithm's principal tuning parameter. Classical analysis chooses $B$ as a function of the size of $N$ alone, of the shape $B = \exp\bigl((\tfrac12 + o(1))\sqrt{\log N \log\log N}\bigr)$. But two semiprimes of the same bit length are not identical: they differ in which small primes split, in the sizes of their sieve values, and in the arithmetic accidents that determine how many smooth values appear. It is natural to ask whether choosing $B$ *per instance* can save work.

This question has two very different readings.

1. **Existence.** Does the cost-minimising $B$ actually vary from instance to instance, and how much would one save by always using it?
2. **Implementability.** Can that per-instance optimum be predicted from information available *before* sieving?

We answer the first in the affirmative and the second in the negative, and we give exact mathematical reasons why the two answers are compatible. The key distinction is between an *oracle*, which may consult the realised costs, and a *free rule*, which may consult only cheap pre-sieving features of $N$.

### 1.1 Contributions

- **A certified cost measure (Section 3).** We prove that the paid touch of a sieve over $[0,M)$ with factor base $S$ equals $2M\sum_{p\ \mathrm{odd}}1/p + M/2$ up to an additive error at most $2|S|-1$. The factor $2$ is the number of square roots of a nonzero quadratic residue modulo an odd prime.
- **Measurement (Section 4).** On 1,800 runs we find a real, consistent oracle gain ($0.9533\times$, no instance worsened) which free rules fail to capture on held-out data (signal-to-noise $0.089$).
- **An exact theory of selection (Section 5).** We prove the ordering oracle $\le$ best feature rule $\le$ best fixed value; that the best feature rule is the per-fibre argmin; an exact zero-gain criterion; refinement monotonicity; and a train/test reversal example.
- **A structural elasticity bound (Section 6).** We prove $d\log Q/d\log m = 1 + c/Q$ when $m = Q + c$, and that all secant slopes lie in $[1, 1+c/Q_1]$, identifying the observed elasticity $\approx 0.997$ as a consistency check rather than an independent discovery.

---

## 2. Background and Definitions

### 2.1 The single-polynomial quadratic sieve

Let $N$ be an odd composite that is not a perfect power, and let $s = \lceil \sqrt N\,\rceil$. The QS considers
$$f(x) = (x + s)^2 - N, \qquad x \in [0, M),$$
so that $f(x) \equiv (x+s)^2 \pmod N$. A value $f(x)$ is **$B$-smooth** if all its prime factors are at most $B$.

**Definition 2.1 (Split primes and factor base).** An odd prime $p \nmid N$ is *split* (for $N$) if $N$ is a nonzero quadratic residue modulo $p$, i.e. the Legendre symbol $\left(\frac{N}{p}\right) = 1$. For a bound $B$, let $Q(B)$ denote the number of split primes $p \le B$. The **factor base** $S(B)$ consists of the prime $2$ together with the split primes up to $B$; the linear-algebra matrix additionally carries a column for the sign $-1$. We write $m$ for the number of columns of the matrix and $c$ for the number of columns not indexed by split odd primes (e.g. $-1$ and $2$), so that $m = Q + c$.

Only primes in the factor base can divide $f(x)$: if an odd prime $p\nmid N$ divides $f(x)$ then $N \equiv (x+s)^2 \pmod p$ is a square.

**Definition 2.2 (Root classes).** For $p \in S$, the *root classes* of $p$ are the residues $r \in \{0,\dots,p-1\}$ such that $p \mid f(x)$ whenever $x \equiv r \pmod p$. We write $\mathrm{roots}(p)$ for this set.

**Definition 2.3 (Class touch and paid touch).** For integers $M \ge 0$, $p \ge 1$ and $0 \le r < p$, the *class touch* is
$$T(M,p,r) = \#\{x \in \{0,1,\dots,M-1\} : x \equiv r \pmod p\}.$$
For a finite set $S$ of positive integers and an assignment $p \mapsto \mathrm{roots}(p)$, the **paid touch** is
$$\mathrm{PT}(M, S) = \sum_{p\in S}\ \sum_{r \in \mathrm{roots}(p)} T(M, p, r).$$
This is precisely the number of array positions the sieve visits: for each root class it starts at $r$ and steps by $p$ until it leaves the interval.

### 2.2 Selection problems

**Definition 2.4 (Instances, ladder, costs).** Let $I$ be a finite set of *instances*, $L$ a finite nonempty *ladder* of admissible parameter values, and $c : I \times L \to \mathbb{R}$ a *cost*. (In our experiment $I$ is the set of semiprimes, $L$ the 15-value ladder of $B$, and $c(i,b)$ the log paid work.)

- The **oracle cost** is $\mathrm{Or} = \sum_{i\in I}\min_{b\in L} c(i,b)$.
- The **fixed cost** of $b\in L$ is $F(b) = \sum_{i\in I} c(i,b)$.
- A **feature** is any map $\varphi : I \to K$ into a set $K$; a **free rule** reading $\varphi$ is a map $g : K \to L$, with **rule cost** $R_\varphi(g) = \sum_{i\in I} c\bigl(i, g(\varphi(i))\bigr)$.
- The **fibre** of $f \in \varphi(I)$ is $\varphi^{-1}(f) \cap I$, with **fibre cost** $C_f(b) = \sum_{i\in I,\ \varphi(i)=f} c(i,b)$.
- The **fibre-best cost** is $\mathrm{FB}(\varphi) = \sum_{f\in\varphi(I)} \min_{b\in L} C_f(b)$.

A free rule may be an arbitrarily sophisticated learner (stratification, regression, a neural network): whatever its internals, once trained it is a function of the features, hence of the form $g\circ\varphi$ for a suitable feature $\varphi$ (the vector of all inputs it reads).

---

## 3. Pricing the Sieve: The Paid-Touch Closed Form

### 3.1 Two roots per odd prime

**Lemma 3.1 (Two square roots).** Let $p$ be an odd prime and let $a \in \mathbb{Z}/p\mathbb{Z}$ be a nonzero square. Then the equation $x^2 = a$ has exactly two solutions in $\mathbb{Z}/p\mathbb{Z}$.

*Proof.* Write $a = r^2$. Then $r \ne 0$ because $a \neq 0$. Since $p$ is odd, $2$ is invertible modulo $p$, so $r = -r$ would give $2r = 0$ and hence $r = 0$, a contradiction; thus $r \neq -r$. Finally $x^2 = r^2$ if and only if $(x-r)(x+r) = 0$, and since $\mathbb{Z}/p\mathbb{Z}$ is a field this holds if and only if $x = r$ or $x = -r$. Hence the solution set is exactly $\{r, -r\}$, of size $2$. $\square$

Applied to $a = N \bmod p$ for a split prime $p$, the solutions $x_0$ of $x_0^2 \equiv N$ yield the two root classes $r \equiv x_0 - s \pmod p$ of $f$. For $p = 2$ and odd $N$, $f(x) = (x+s)^2 - N$ is even exactly when $x + s$ is odd, giving a single root class.

### 3.2 Touch count of one class

**Lemma 3.2 (Exact class touch).** For $p \ge 1$ and $0 \le r < p$,
$$T(M,p,r) = \Bigl\lfloor \frac{M}{p}\Bigr\rfloor + \begin{cases}1 & \text{if } r < M \bmod p,\\ 0 & \text{otherwise.}\end{cases}$$

*Proof sketch.* Write $M = p\lfloor M/p\rfloor + (M \bmod p)$. Each of the $\lfloor M/p \rfloor$ complete blocks $[kp, (k+1)p)$ contains exactly one element of the class of $r$; the final partial block $[p\lfloor M/p\rfloor, M)$ contains one if and only if $r < M \bmod p$. $\square$

**Corollary 3.3 (Two-sided bound).** $M < p\,T(M,p,r) + p$ and $p\,T(M,p,r) \le M + p$. Consequently, as real numbers,
$$\Bigl| T(M,p,r) - \frac{M}{p}\Bigr| \le 1 .$$

*Proof.* Immediate from Lemma 3.2 and $0 \le M \bmod p < p$, then dividing by $p$. $\square$

### 3.3 The closed form

**Theorem 3.4 (General paid-touch formula).** Let $S$ be a finite set of positive integers and suppose every $r\in\mathrm{roots}(p)$ satisfies $r<p$. Then
$$\Bigl|\ \mathrm{PT}(M,S) - M \sum_{p\in S} \frac{|\mathrm{roots}(p)|}{p}\ \Bigr| \;\le\; \sum_{p\in S} |\mathrm{roots}(p)| .$$

*Proof.* The difference equals $\sum_{p\in S}\sum_{r\in\mathrm{roots}(p)} \bigl(T(M,p,r) - M/p\bigr)$. Apply the triangle inequality twice and bound each summand by $1$ using Corollary 3.3. $\square$

**Theorem 3.5 (Quadratic-sieve closed form).** Suppose in addition that $2 \in S$, that $|\mathrm{roots}(2)| = 1$, and that $|\mathrm{roots}(p)| = 2$ for every $p \in S\setminus\{2\}$ (as forced by Lemma 3.1 for split odd primes). Then
$$\Bigl|\ \mathrm{PT}(M,S) - \Bigl( 2M\!\!\sum_{p\in S\setminus\{2\}} \frac1p + \frac M2 \Bigr)\Bigr| \;\le\; 2|S| - 1 .$$

*Proof.* Under the hypotheses, $\sum_{p\in S}|\mathrm{roots}(p)|/p = 2\sum_{p\ne 2}1/p + 1/2$ and $\sum_{p\in S}|\mathrm{roots}(p)| = 2(|S|-1) + 1 = 2|S|-1$. Substitute into Theorem 3.4. $\square$

**Remark 3.6 (Relative precision).** Since $\mathrm{PT}(M,S) \ge M/2 - 1$, the relative error is $O(|S|/M)$. In the experiment, $M = 150{,}000$ and the measured maximum relative deviation between counted operations and the closed form was $2.01\times 10^{-4}$ over all 1,800 runs. This certifies that the cost being compared across $B$ is the actual sieve work, not a rank or proxy — an important correction over cost measures that only track the *direction* of change.

---

## 4. Experiment

### 4.1 Design

- **Instances.** 120 balanced semiprimes $N = pq$ of 41 bits, each validated (both factors prime, balanced sizes).
- **Ladder.** 15 smoothness bounds $B$ from $150$ to $19{,}000$.
- **Interval.** Fixed sieve length $M = 150{,}000$.
- **Runs.** Every instance at every ladder value: $120 \times 15 = 1{,}800$ complete QS runs.
- **Cost.** Total paid work of the run, priced in paid touch (Definition 2.3), compared in natural-log units.
- **Statistics.** One instance per row; error bars are between-instance standard deviations. Ratios are reported as $\exp(\text{mean log ratio})$.

### 4.2 Finding 1: the per-instance optimum moves

For each instance $i$ let $B^{*}_i = \arg\min_{b\in L} c(i,b)$. Over the 120 instances, $B^{*}_i$ spans the entire ladder, from $150$ to $19{,}000$, with median $4{,}800$. The optimal bound is genuinely instance-dependent.

### 4.3 Finding 2: the oracle gain is real

The best fixed ladder value fitted on training data is $B = 9{,}600$. Against it, the oracle achieves

| quantity | value |
|---|---|
| ratio (oracle / fixed) | $0.9533\times$ |
| mean log saving | $0.0478$ |
| between-instance sd of the log saving | $0.0451$ |
| $t$-statistic ($n = 120$) | $-11.6$ |
| improved / tied / worsened | $102 \,/\, 18 \,/\, 0$ |

That no instance is worsened is a theorem (Proposition 5.1), not an empirical observation; that $102$ are strictly improved proves, via Corollary 5.6, that no single ladder value is optimal for all instances.

### 4.4 Finding 3: no free rule reaches it

The 120 instances were split into 60 training and 60 test instances. Rules were fitted on training data and evaluated on test data relative to the train-fit fixed bound.

| rule (held-out) | ratio vs best fixed $B$ | $t$ |
|---|---|---|
| stratified by small-split-prime count $Q_{\mathrm{small}}$ | $1.0047\times$ | $+1.12$ |
| regression on free features | $1.0290\times$ | $+3.04$ |
| oracle (reference, not implementable) | $0.9590\times$ | — |

The stratified rule is indistinguishable from the fixed bound; the regression rule is significantly *worse*. The entire prize, $0.0478$ log units, must be compared with the held-out residual standard deviation of the free-feature model, $0.5360$:
$$\text{signal/noise} = \frac{0.0478}{0.5360} \approx 0.089 .$$
The variation in $B^{*}$ is real but essentially invisible to features computable before sieving.

### 4.5 Finding 4: $Q$ tracks $m$

For each instance, regressing $\log Q$ on $\log m$ across the ladder gives slopes with mean $0.99718$, between-instance sd $0.03722$, range $[0.923, 1.094]$ ($n=120$; $t = +293$ against zero). At fixed $N$, varying $B$ moves $Q$ and $m$ together; Section 6 shows this is, to leading order, forced by bookkeeping.

---

## 5. An Exact Theory of Oracle, Fixed, and Feature-Based Selection

Throughout, $I, L, c, \varphi$ are as in Definition 2.4.

### 5.1 Ordering

**Proposition 5.1 (Pointwise oracle dominance).** For every $i\in I$ and $b \in L$, $\min_{b'\in L} c(i,b') \le c(i,b)$. $\square$

**Lemma 5.2 (Fibre decomposition).** For every free rule $g : K \to L$,
$$R_\varphi(g) = \sum_{f\in\varphi(I)} C_f\bigl(g(f)\bigr), \qquad\text{and in particular}\qquad F(b) = \sum_{f\in\varphi(I)} C_f(b).$$

*Proof.* Group the sum defining $R_\varphi(g)$ according to the value $f = \varphi(i)$; on the fibre of $f$ the rule's choice is the constant $g(f)$. The second identity is the case of the constant rule $g \equiv b$. $\square$

**Theorem 5.3 (Oracle $\le$ best rule $\le$ best fixed).** For every rule $g : K \to L$ and every $b \in L$:
1. $\mathrm{Or} \le R_\varphi(g)$;
2. $\mathrm{FB}(\varphi) \le R_\varphi(g)$;
3. there exists a rule $g^{*}$ with $R_\varphi(g^{*}) = \mathrm{FB}(\varphi)$, namely any rule with $g^{*}(f) \in \arg\min_{b} C_f(b)$;
4. $\mathrm{Or} \le \mathrm{FB}(\varphi) \le F(b)$.

*Proof.* (1) Sum Proposition 5.1 with $b = g(\varphi(i))$. (2) By Lemma 5.2, compare $C_f(g(f)) \ge \min_b C_f(b)$ fibrewise. (3) For each $f$ choose a minimiser (the ladder is finite and nonempty); then each fibre term equals its minimum. (4) The left inequality is (1) applied to $g^{*}$ together with (3); the right is (2) applied to the constant rule. $\square$

Thus the best possible free rule reading $\varphi$, whatever learning method produced it, has cost exactly $\mathrm{FB}(\varphi)$, and its gain over a fixed value $b$ is
$$F(b) - \mathrm{FB}(\varphi) \;=\; \sum_{f\in\varphi(I)} \Bigl( C_f(b) - \min_{b'} C_f(b') \Bigr),$$
the **sum of per-fibre regrets** of $b$. Implementability is a property of the fibres, not of the learner.

### 5.2 The zero-gain criterion

**Theorem 5.4 (Zero-gain characterisation).** For $b \in L$,
$$\mathrm{FB}(\varphi) = F(b) \iff \text{for every } f \in \varphi(I) \text{ and every } b' \in L:\ C_f(b) \le C_f(b').$$
That is, a free feature yields no gain over the fixed value $b$ if and only if $b$ is simultaneously optimal on every fibre.

*Proof.* By Lemma 5.2 both sides are sums over $\varphi(I)$, and termwise $\min_{b'} C_f(b') \le C_f(b)$. A sum of termwise-dominated terms equals the dominating sum if and only if every term is equal, i.e. if and only if $C_f(b) = \min_{b'} C_f(b')$ for every fibre $f$. $\square$

**Corollary 5.5 (Oracle zero-gain).** Taking $\varphi$ to be the identity (so every fibre is a single instance), $\mathrm{Or} = F(b)$ if and only if $b$ is optimal on every instance: $c(i,b) \le c(i,b')$ for all $i\in I$, $b'\in L$. $\square$

**Corollary 5.6 (One strict win suffices).** If some $i\in I$ and $b'\in L$ satisfy $c(i,b') < c(i,b)$, then $\mathrm{Or} < F(b)$. $\square$

*Interpretation.* The $102/120$ strict oracle wins prove the instances disagree about the optimal $B$ (Corollary 5.6). The wash of the stratified rule says, via Theorem 5.4, that the $Q_{\mathrm{small}}$-fibres essentially *agree*: the per-instance disagreement is averaged out within each fibre a free feature can resolve.

### 5.3 Refinement and overfitting

**Proposition 5.7 (Refinement monotonicity).** If $\psi : I \to K'$ and $h : K' \to K$, then $\mathrm{FB}(\psi) \le \mathrm{FB}(h\circ\psi)$.

*Proof.* Let $g^{*}$ attain $\mathrm{FB}(h\circ\psi)$ (Theorem 5.3(3)). Then $g^{*}\circ h$ is a rule reading $\psi$ with the same cost, so $\mathrm{FB}(\psi) \le R_\psi(g^{*}\circ h) = \mathrm{FB}(h\circ\psi)$ by Theorem 5.3(2). $\square$

Finer features never hurt *in-sample*. This is exactly why in-sample comparisons are meaningless for adaptive tuning, and why only held-out results are reported in Section 4.4. The following example shows that out-of-sample, the in-sample winner can strictly lose.

**Proposition 5.8 (Train/test reversal).** Let $I = K = L = \{\mathsf{T}, \mathsf{F}\}$ with $\varphi = \mathrm{id}$, and define training and test costs by

| | $c_{\text{train}}(i,\mathsf{T})$ | $c_{\text{train}}(i,\mathsf{F})$ | $c_{\text{test}}(i,\mathsf{T})$ | $c_{\text{test}}(i,\mathsf{F})$ |
|---|---|---|---|---|
| $i = \mathsf{T}$ | $9/10$ | $1$ | $3/2$ | $1$ |
| $i = \mathsf{F}$ | $6/5$ | $1$ | $1$ | $1$ |

Then: (a) $\mathsf{F}$ is the train-optimal fixed value, $F_{\text{train}}(\mathsf{F}) = 2 < 21/10 = F_{\text{train}}(\mathsf{T})$; (b) the rule $g = \mathrm{id}$ is train-optimal, $R_{\text{train}}(\mathrm{id}) = 19/10 = \mathrm{FB}_{\text{train}}(\mathrm{id})$, and strictly beats the fixed value, $19/10 < 2$; (c) on test it strictly loses, $F_{\text{test}}(\mathsf{F}) = 2 < 5/2 = R_{\text{test}}(\mathrm{id})$.

*Proof.* Direct computation; for (b), the per-fibre minima are $9/10$ and $1$, which $\mathrm{id}$ attains. $\square$

The held-out regression result, $1.0290\times$, has exactly this shape: a rule that is optimal on its training sample fits noise and loses out of sample.

---

## 6. The Elasticity of $Q$ with Respect to $m$

**Theorem 6.1 (Instantaneous elasticity).** Let $c\in\mathbb{R}$ and parametrise the column count as $m = e^t$ with $e^t > c$. Then $t \mapsto \log(e^t - c) = \log Q$ is differentiable at $t$ with derivative
$$\frac{d\log Q}{d\log m} = \frac{m}{m - c}.$$

*Proof.* Chain rule: the derivative of $e^t - c$ is $e^t$, and $\log$ has derivative $1/(e^t-c)$ at the positive point $e^t - c$. $\square$

**Proposition 6.2 (Elasticity bounds).** If $0 \le c < m$ then
$$\frac{m}{m-c} = 1 + \frac{c}{m-c} = 1 + \frac{c}{Q} \qquad\text{and}\qquad \frac{m}{m-c} \ge 1 .$$ $\square$

**Theorem 6.3 (Secant elasticity).** Let $0 \le c < m_1 \le m_2$ and $Q_k = m_k - c$. Then
$$\log\frac{m_2}{m_1} \;\le\; \log\frac{Q_2}{Q_1} \;\le\; \frac{m_1}{m_1 - c}\,\log\frac{m_2}{m_1}.$$
Hence, whenever $m_1<m_2$, the secant slope $\log(Q_2/Q_1)/\log(m_2/m_1)$ lies in $[1, 1 + c/Q_1]$.

*Proof sketch.* Lower bound: $Q_2/Q_1 \ge m_2/m_1$ is equivalent to $m_1(m_2 - c) \ge m_2(m_1 - c)$, i.e. $c(m_2 - m_1) \ge 0$; then apply monotonicity of $\log$. Upper bound: put $e = m_1/(m_1-c) \ge 1$ and $s = m_2/m_1 - 1 \ge 0$. A direct computation gives $Q_2/Q_1 = 1 + e s$, and Bernoulli's inequality $(1+s)^e \ge 1 + es$ (valid for $e \ge 1$, $s \ge -1$) yields $\log(1 + es) \le e\log(1+s) = e\log(m_2/m_1)$. $\square$

**Discussion.** With $c$ a handful of special columns, Theorem 6.3 traps every secant elasticity within $c/Q_1$ above $1$: about $10^{-1}$ at the bottom of the ladder, where $Q$ is of order $20$, and below $10^{-2}$ once $Q$ reaches the hundreds, as it does over most of the ladder (up to $Q\approx 10^3$ at $B = 19{,}000$). The observed mean $0.99718$ is therefore, to leading order, a *consistency check* that the instrument measures what it should, rather than an independent proof that $Q$ cannot be decoupled from $m$. The observed spread on both sides of $1$ (range $[0.923, 1.094]$) reflects that the empirical relationship between the split set and the column count is not exactly $m = Q + \text{const}$ across the ladder: the fraction of primes up to $B$ at which a fixed $N$ is a quadratic residue fluctuates around $1/2$ as $B$ moves. Under either bookkeeping, slope $\approx 1$ is forced by construction. The substantive conclusion stands: at fixed $N$, choosing $B$ moves $m$ and $Q$ together, so $B$ supplies no lever to decouple them.

---

## 7. Algorithms

**Algorithm A (Paid-touch evaluation by closed form).** Input $N$, $B$, $M$.
1. Enumerate primes $p\le B$ by a sieve of Eratosthenes ($O(B\log\log B)$).
2. For odd $p$, test $\left(\frac{N}{p}\right)=1$ by Euler's criterion $N^{(p-1)/2}\equiv 1 \pmod p$ ($O(\log p)$ multiplications each).
3. For each split $p$ compute the two square roots of $N$ modulo $p$ (Tonelli–Shanks) and the root classes $r = (x_0 - s) \bmod p$; for $p=2$ the single class.
4. Exact paid touch: $\sum_{p}\sum_{r}\bigl(\lfloor M/p\rfloor + [r < M \bmod p]\bigr)$, in $O(|S|)$ time, without touching the array.
5. Closed form: $2M\sum_{p\ne2}1/p + M/2$; certify $|\text{exact} - \text{closed}| \le 2|S|-1$.

**Algorithm B (Oracle / fixed / fibre-best evaluation).** Input a cost table $c(i,b)$ and a feature $\varphi$.
1. $\mathrm{Or} \leftarrow \sum_i \min_b c(i,b)$; $F(b) \leftarrow \sum_i c(i,b)$ for each $b$.
2. Group instances by $\varphi(i)$; for each fibre $f$, compute $C_f(b)$ for all $b$ and set $g^{*}(f)\leftarrow\arg\min_b C_f(b)$.
3. $\mathrm{FB}\leftarrow\sum_f C_f(g^{*}(f))$; per-fibre regret of $b$: $C_f(b) - C_f(g^{*}(f))$.
4. Report the zero-gain test: does some $b$ have zero regret on all fibres?
Cost: $O(|I|\,|L|)$ time and memory.

**Algorithm C (Honest held-out evaluation).** Split $I$ into train/test; fit $b_{\mathrm{fix}} = \arg\min_b F_{\text{train}}(b)$ and $g^{*}$ by Algorithm B on train; report $\exp$ of the mean test log ratios $c(i,g^{*}(\varphi(i))) - c(i,b_{\mathrm{fix}})$ and of the oracle, with a paired $t$-statistic. Unseen fibres on test fall back to $b_{\mathrm{fix}}$.

---

## 8. Applications and Broader Lessons

The structure exposed here — a cost table over instances and a finite menu of settings — is ubiquitous: per-program compiler flags, per-dataset hyperparameters, per-query database plans, per-patient dosing. In each case:

- the **oracle never loses** (Proposition 5.1), so a large fraction of "improved" instances under hindsight selection is not evidence of an implementable method;
- the **attainable gain of any feature-based policy equals the summed per-fibre regret** of the best fixed setting (Theorem 5.3), which can be estimated directly from data without training a learner;
- the **zero-gain criterion** (Theorem 5.4) gives a sharp test for when adaptivity is pointless;
- **in-sample improvements from richer features are guaranteed** (Proposition 5.7) and therefore uninformative; only held-out comparisons count (Proposition 5.8).

For factoring specifically, the result supports the classical practice of choosing $B$ from the size of $N$ alone in the single-polynomial setting, and identifies where the remaining design freedom lies.

---

## 9. Discussion and Limitations

- **Scale.** All instances are 41-bit. The closed form (Theorem 3.5) is size-independent, but the magnitude of the oracle gain and its predictability may change with $\log N$.
- **Noise in the oracle.** The oracle gain $\sum_i \min_b c(i,b)$ is biased upward by per-instance noise on the ladder, since a minimum of noisy values is systematically low. Part of the $0.0478$ prize may be noise rather than structure.
- **Feature families.** Only two families of free features were tested. Theorem 5.4 implies that any future feature can be judged by computing its fibre regrets on the existing table.
- **Elasticity.** As explained in Section 6, the $Q$–$m$ elasticity should be cited as a consistency check rather than as independent evidence.

---

## 10. Future Work

1. **Fibre-agreement test.** Compute per-fibre argmins of the existing 1,800-run table for $Q_{\mathrm{small}}$ strata and test Theorem 5.4 directly; conjecturally $B = 9600$ lies within 1% of the per-fibre optimum in every stratum, which would close stratified adaptive $B$ as a provable null.
2. **Oracle gain as a smoothing artifact.** Re-run each instance with a different sieve interval; if $B^{*}$ is uncorrelated between repetitions, the prize is mostly noise.
3. **Multi-polynomial decoupling.** In the self-initialising multi-polynomial QS with $k$ polynomials and per-polynomial interval $M'$, the column count is still $m = Q + c$ and the work becomes $k\bigl(2M'\sum 1/p + M'/2\bigr)$ plus $k$ times a switching cost; only the switching term can decouple $Q$ from $m$.
4. **An information-theoretic ceiling.** A rule reading $\varphi$ can capture at most the between-fibre variance of $\log B^{*}$; with signal/noise $0.089$, we predict an achievable gain at most $\rho^2$ times the prize, where $\rho$ is the correlation between $\varphi$ and $\log B^{*}$.

---

## 11. Conclusion

The best smoothness bound for the single-polynomial quadratic sieve really does vary from semiprime to semiprime, and an oracle that knew it would save almost five percent of the sieve work without ever losing. But the information needed to find it is not present in anything computable before sieving: the prize is a twelfth of the unexplained noise, free rules are a wash or worse on held-out data, and the exact theory of Section 5 explains why — the feature fibres agree on the optimum even though the instances do not. Adaptive $B$ is a validated negative as an implementable method, the paid-touch formula provides a certified ruler for future comparisons, and the multi-polynomial sieve's switching cost is the one remaining unpriced lever.
