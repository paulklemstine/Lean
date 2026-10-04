# The Posterior Filter Equals the Sham: Public-Residue Information Has Zero Conversion into Trial-Division Speedup

**Aristotle**

*October 2026*

---

## Abstract

Public quantities computable from a semiprime $N = pq$ — residues of $N$ modulo small integers, quadratic characters, Frobenius classes — carry genuine information about the factor pair: a battery of such "dials" was measured at $3.49$ bits. We ask whether this information can be converted into a speedup of trial division, and answer *no*, both experimentally and exactly. Experimentally, a Bayesian candidate filter built from the exact posterior over the smaller factor's residue class is indistinguishable from a same-size coin-flip keep-set at every dial (maximum discrepancy $0.0075$ against a batch standard deviation of $0.0073$, on $20{,}000$ semiprimes per cell in five batches), and under honest accounting every filter, real or sham, runs at about $0.50\times$ the speed of plain trial division. Theoretically, in the residue model where the two factor residues are independent and uniform in a finite group $G$, we prove: (i) a *flat-posterior theorem* — conditioned on any public reading, every class is equally likely to contain the target factor; (ii) the *keep-rate law* — a filter's success count is exactly its total keep size $\sum_c |K(c)|$, so the real filter and any same-size sham are identical and the success rate equals the keep rate; (iii) exact no-fallback failure probability $1/|G|$; (iv) *ordering invariance* — every examination order has expected target rank $(|G|-1)/2$; (v) a *$1\times$ cap* and an exact *$0.5\times$ law* when membership tests are priced at one division; (vi) *sham co-inflation* — the most common cost-accounting bug inflates real and sham filters identically; (vii) *$N$-blind optimality* under arbitrary target priors; (viii) the exact boundary of the sham law (the unordered event); and (ix) the information-theoretic statement that every public dial carries zero bits about the target and its full entropy about the pair. The refuted pre-stated prediction of a $4/3\times$ speedup is explained: the information rides a channel orthogonal to every ordering decision.

---

## 1. Introduction

Trial division finds the smaller prime factor $p$ of $N = pq$ by testing candidate divisors up to $\sqrt N$. Its cost is the number of candidates examined. A natural hope is to prune the candidate list using information that $N$ itself reveals. Such information certainly exists. If $3 \nmid pq$, then $N \bmod 3$ reveals whether $p \equiv q \pmod 3$; analogous statements hold modulo any $m$, and more refined invariants (characters, splitting types, Frobenius classes) give whole families of public readings. We call a function of $N$ alone a *dial*, and a tuple of dials a *battery*. In the programme from which this paper arises, the *type channel* — the information that such public dials carry about the factor pair — was measured carefully, and a battery reaching $3.49$ bits was assembled. The open question, posed earlier in the programme, was one of **utility**: how much of this capacity converts into factoring speed?

Before running the decisive experiment, a speedup of $4/3\times$ was predicted. This paper reports the experiment and the theory that explains its outcome:

> **The real posterior filter equals the sham, and the conversion rate is exactly zero.**

The mechanism is a single change of variables. For independent uniform residues $a, b$ in a finite group, the map $(a, b) \mapsto (a, ab)$ is a bijection of $G \times G$. Hence the *target* residue $a$ and the *public* residue $ab$ are independent. The public number constrains the pair heavily but leaves the marginal of the target perfectly flat. We refer to this as **barrier 2**, and this paper makes it algorithmic: every filtering, ordering and cost statement about trial division follows from it exactly.

**Contributions.**

1. An experiment (Section 2) comparing a Bayesian posterior filter with a coin-flip sham across five dials, showing indistinguishability and a universal $\approx 0.50\times$ honest cost.
2. A residue model (Section 3) and the flat-transport lemma that drives everything.
3. Exact theorems (Sections 4–8): flat posterior, keep-rate law, real $=$ sham, no-fallback failure rate, ordering invariance, the $1\times$ cap and $0.5\times$ law, sham co-inflation, $N$-blind optimality, the unordered boundary, and zero-channel/orthogonal-capacity statements.
4. An experimental-methodology ledger (Section 9) showing how two of these theorems functioned as bug detectors during the experiment.

---

## 2. The experiment

### 2.1 Design

For each dial — labelled $d_2$ (a $1$-bit dial), $d_3$, $d_5$, and two batteries $\mathrm{bat}_2$, $\mathrm{bat}_4$ (the latter carrying $3.49$ bits about the factor pair) — the following was done.

1. **Posterior.** The exact posterior distribution of the smaller factor's residue class, given the dial reading of $N$, was computed.
2. **Real filter.** For each reading, the filter keeps the most probable classes (a fraction $\rho$ of all classes) and trial-divides only by candidates in kept classes.
3. **Sham filter.** For each reading, a keep-set of the *same size* is chosen by independent coin flips, ignoring the posterior.
4. **Measurement.** Success rate (target factor's class kept) and cost, on $20{,}000$ random semiprimes per cell, in five independent batches, with a fixed random seed.
5. **$\rho$-grid.** The keep rate $\rho$ was swept over a grid to see whether success depends on *which* classes are kept or only on *how many*.

### 2.2 Results

- **Real = sham.** At every dial, $\max |\text{real} - \text{sham}| = 0.0075$, against a batch standard deviation of $0.0073$. The difference is at the noise floor.
- **Keep-rate dependence only.** On the $\rho$-grid, the success rate of both filters is a function of $\rho$ alone; the curves coincide on the line "success $=\rho$".
- **No-fallback failures.** A filter that discards a single class and has no fallback fails at rate $1/n$ exactly, where $n$ is the number of classes, at every dial.
- **Honest cost.** With each membership test priced as one division-equivalent on every candidate up to $\sqrt N$, *every* filter, real or sham, runs at $\approx 0.50\times$ the speed of plain trial division: a net factor-of-two loss.
- **Prediction.** The pre-stated $4/3\times$ speedup is refuted. Under accounting for the complete procedure, the sharp cap is $1\times$.

The rest of the paper proves that, in the natural idealized model, each of these observations is an exact identity.

---

## 3. The residue model

Throughout, $G$ is a finite group of order $n = |G|$ (written multiplicatively), for example $G = (\mathbb Z/m\mathbb Z)^\times$. The smaller factor $p$ (the **target**) and the cofactor $q$ are recorded by their residues $a, b \in G$. The idealization is:

> **Equidistribution hypothesis.** $(a, b)$ is uniformly distributed on $G \times G$.

The public number $N$ fixes the **public residue** $c = ab$.

**Definition 3.1 (Dial).** A *public dial* is any function $\varphi : G \to D$ to some finite set $D$, evaluated at the public residue. Any function of $N$ that depends on $N$ only through $c$ is of this form; a battery $(\varphi_1, \varphi_2)$ is again a dial $c \mapsto (\varphi_1(c), \varphi_2(c))$.

**Definition 3.2 (Filter).** A *filter* (keep-policy) is a map $K : G \to 2^G$. After reading $c$, the filter keeps the candidate classes $K(c)$ and trial-divides only candidates in those classes. It **succeeds** on $(a,b)$ when $a \in K(ab)$. Its **success count** is
$$\operatorname{hit}(K) = \#\{(a,b) \in G \times G : a \in K(ab)\}.$$
A filter has *constant keep size* $k$ if $|K(c)| = k$ for all $c$.

**Definition 3.3 (Ordering policy).** An *ordering policy* assigns to each public residue $c$ a bijection $r_c : G \to \{0, 1, \dots, n-1\}$, the rank at which each class is examined.

All counting statements below are over the $n^2$ equally likely factor pairs; dividing by $n^2$ turns them into probabilities.

### 3.1 Flat transport

**Lemma 3.4 (Flat transport).** For any function $f : G \times G \to M$ into an additive commutative monoid,
$$\sum_{(a,b) \in G\times G} f(a,\, ab) \;=\; \sum_{c \in G}\, \sum_{a \in G} f(a,\, c).$$

*Proof.* For fixed $a$, left multiplication $b \mapsto ab$ is a bijection of $G$, so $\sum_b f(a, ab) = \sum_c f(a, c)$. Sum over $a$ and exchange the order of summation. $\square$

Equivalently, under the equidistribution hypothesis, the pair (target, public residue) $= (a, ab)$ is uniform on $G \times G$; the target and the public residue are independent. Note that only left multiplication is used: commutativity of $G$ is never needed.

---

## 4. The flat posterior (barrier 2)

**Theorem 4.1 (Flat posterior).** Let $\varphi : G \to D$ be any public dial, $d \in D$ a reading and $r \in G$ any class. Then
$$\#\{(a,b) : \varphi(ab) = d,\ a = r\} \;=\; \#\{c \in G : \varphi(c) = d\}.$$
In particular the right-hand side does not depend on $r$.

*Proof.* Apply Lemma 3.4 to the indicator $f(a, c) = [\varphi(c) = d \wedge a = r]$. For each $c$ with $\varphi(c) = d$ the inner sum over $a$ contributes exactly $1$ (from $a = r$); for other $c$ it contributes $0$. $\square$

**Corollary 4.2 (Posterior indifference).** For every reading $d$ and every two classes $r, s$, the number of factor pairs with reading $d$ and target in $r$ equals the number with reading $d$ and target in $s$. Conditioned on any dial reading, the posterior over the target's residue is uniform.

**Example 4.3.** Take $G = (\mathbb Z/3\mathbb Z)^\times = \{1, 2\}$ and the dial $\varphi(c) = c$. If $c = 1$, the factor pairs are $(1,1), (2,2)$; if $c = 2$ they are $(1,2), (2,1)$. In each case the target is $1$ or $2$ with equal probability, although $c$ fully determines whether $a = b$.

The posterior is flat *no matter what $N$ reveals about the joint distribution*. This is the precise sense in which posterior capacity cannot reweight candidates.

---

## 5. The keep-rate law

**Theorem 5.1 (Keep-rate law).** For every filter $K$,
$$\operatorname{hit}(K) = \sum_{c \in G} |K(c)|.$$

*Proof.* $\operatorname{hit}(K) = \sum_{(a,b)} [a \in K(ab)]$. By Lemma 3.4 this equals $\sum_c \sum_a [a \in K(c)] = \sum_c |K(c)|$. $\square$

**Corollary 5.2 (Real filter equals sham).** If two filters $K_{\mathrm{real}}$ and $K_{\mathrm{sham}}$ satisfy $|K_{\mathrm{real}}(c)| = |K_{\mathrm{sham}}(c)|$ for every $c$, then $\operatorname{hit}(K_{\mathrm{real}}) = \operatorname{hit}(K_{\mathrm{sham}})$.

The posterior-ranked filter and an arbitrary — e.g. coin-flip — keep-set of the same sizes are exactly indistinguishable. Since a randomly chosen keep-set is in particular *some* keep-set of the given sizes, the sham's success count is not merely equal in expectation; it is equal for every realization of the coins.

**Corollary 5.3 (Success rate equals keep rate).** If $|K(c)| = k$ for all $c$, then
$$\frac{\operatorname{hit}(K)}{|G \times G|} = \frac{k}{n}.$$

*Proof.* $\operatorname{hit}(K) = nk$ and $|G\times G| = n^2$. $\square$

This is the $\rho$-grid observation: success is a function of keep rate alone.

**Corollary 5.4 (No-fallback failure rate).** If $|K(c)| + 1 = n$ for every $c$ — the filter discards exactly one class per public residue and does not fall back — then
$$\#\{(a,b) : a \notin K(ab)\} = n,$$
i.e. the filter fails with probability exactly $1/n$.

*Proof.* By Theorem 5.1, $\operatorname{hit}(K) = n(n-1)$; the complement in $G \times G$ has $n^2 - n(n-1) = n$ elements. $\square$

No class is "safer" to discard than another; the observed failure rates of exactly $1/n$ at every dial are predicted.

---

## 6. Ordering invariance

Rather than discarding classes, a cleverer user of the posterior might *reorder* them, examining likely classes first. This also gains nothing.

**Lemma 6.1.** For a bijection $e : G \to \{0, \dots, n-1\}$ and $a \in G$, the set $\{x : e(x) \le e(a)\}$ of classes examined up to and including $a$ has exactly $e(a) + 1$ elements; and $2\sum_{a \in G} e(a) = n(n-1)$.

*Proof.* $e$ maps the set bijectively onto $\{0, \dots, e(a)\}$. The sum of ranks is $0 + 1 + \dots + (n-1)$. $\square$

**Theorem 6.2 (Ordering invariance).** For every ordering policy $(r_c)_{c \in G}$,
$$2 \sum_{(a,b) \in G\times G} r_{ab}(a) \;=\; n \cdot n (n-1).$$
Hence the expected rank of the target is $(n-1)/2$ and the expected number of classes examined is $(n+1)/2$, for every ordering policy — exactly as for the plain scan.

*Proof.* By Lemma 3.4, $\sum_{(a,b)} r_{ab}(a) = \sum_c \sum_a r_c(a)$, and each inner sum is $n(n-1)/2$ by Lemma 6.1. $\square$

**Corollary 6.3.** Any two ordering policies have the same total search cost.

---

## 7. Honest cost accounting

### 7.1 Cost model

Fix an ordering policy $r$. For public residue $c$ and target $a$, write $U_c(a) = \{x : r_c(x) \le r_c(a)\}$ for the classes examined up to and including the target.

**Definition 7.1 (Baseline cost).** The plain scan divides by every candidate up to the target: $\operatorname{base}(c, a) = |U_c(a)|$.

**Definition 7.2 (Honest filter cost).** A filter must *test* each examined candidate for membership in $K(c)$, priced at one division-equivalent, and then *divide* by the kept ones, one more unit each:
$$\operatorname{cost}_K(c, a) = \sum_{x \in U_c(a)} \bigl(1 + [x \in K(c)]\bigr).$$

The pricing reflects reality: determining a candidate's residue class and looking it up costs about as much as the division one hoped to skip.

**Lemma 7.3 (Decomposition).** $\operatorname{cost}_K(c, a) = \operatorname{base}(c, a) + |U_c(a) \cap K(c)|$.

### 7.2 The cap and the 0.5× law

**Theorem 7.4 (The $1\times$ cap).** For every filter $K$ and every ordering policy,
$$\sum_{(a,b)} \operatorname{base}(ab, a) \;\le\; \sum_{(a,b)} \operatorname{cost}_K(ab, a).$$
No filter — posterior-built or sham — beats the plain scan in total cost.

*Proof.* Sum Lemma 7.3; the extra term is non-negative. $\square$

**Proposition 7.5 (Baseline total).** For every ordering policy, $2 \sum_{(a,b)} \operatorname{base}(ab, a) = n \cdot n(n+1)$, i.e. the expected baseline cost is $(n+1)/2$.

*Proof.* $\operatorname{base} = \text{rank} + 1$ by Lemma 6.1; apply Theorem 6.2. $\square$

**Theorem 7.6 (The $0.5\times$ law).** For the full-keep filter $K(c) = G$,
$$\sum_{(a,b)} \operatorname{cost}_K(ab, a) \;=\; 2 \sum_{(a,b)} \operatorname{base}(ab, a).$$

*Proof.* When everything is kept, $U_c(a) \cap K(c) = U_c(a)$, so Lemma 7.3 gives $\operatorname{cost} = 2\operatorname{base}$ pointwise. $\square$

A filter whose fallback eventually divides every candidate it tested behaves as the full-keep filter: it pays the test and the division on every candidate, landing at exactly $0.5\times$. This is the observed $\approx 0.50\times$ for every filter, real or sham. Between the extremes, a constant-size filter keeping a fraction $\rho$ of the classes in a random arrangement costs approximately $(1+\rho)$ times the baseline; it never drops below $1$.

---

## 8. Robustness and boundary

### 8.1 Sham co-inflation

The experiment encountered two cost-accounting bugs that produced spurious speedups above $1.5\times$. The following theorem explains why the sham control exposed them.

**Lemma 8.1 (Rank-sum identity).** For any bijection $e : G \to \{0, \dots, n-1\}$ and any $T \subseteq G$,
$$2 \sum_{a \in T} \#\{x \in T : e(x) \le e(a)\} = |T|\,(|T|+1).$$

*Proof.* Write the left side as $\sum_{a, x \in T} \bigl([e(x)\le e(a)] + [e(a) \le e(x)]\bigr)$. For $x \ne a$ exactly one indicator is $1$; for $x = a$ both are. So the total is $|T|^2 + |T|$. $\square$

**Theorem 8.2 (Sham co-inflation).** Suppose the membership test is left unpriced, so that a successful run costs only the number of kept classes divided up to the target. Then for every filter $K$ and ordering policy $r$,
$$2 \sum_{(a,b)\,:\, a \in K(ab)} |U_{ab}(a) \cap K(ab)| \;=\; \sum_{c \in G} |K(c)|\,\bigl(|K(c)|+1\bigr).$$

*Proof.* By Lemma 3.4 the left side equals $\sum_c 2\sum_{a \in K(c)} |U_c(a) \cap K(c)|$; apply Lemma 8.1 with $T = K(c)$. $\square$

**Corollary 8.3.** Under this bug, the real filter and any same-size sham — even with different ordering policies — report identical total cost on successful runs.

So a bug of this type inflates the real filter and the sham by exactly the same factor. With constant keep size $k$, the mean buggy cost per success is $(k+1)/2$ while the plain scan costs $(n+1)/2$ on average, so the bug reports a speedup of exactly $(n+1)/(k+1)$ for *every* filter of that size. A "speedup" that the sham shares is an artefact of the accounting, not of the posterior. In the residue model with $n = 24$ classes and keep size $8$, the bug reports $25/9 \approx 2.78\times$ for both filters.

### 8.2 Arbitrary priors on the target: $N$-blind optimality

Real primes need not be uniform across residue classes, and the *smaller* factor's distribution may differ from the cofactor's. We therefore drop uniformity of the target, keeping only uniformity of the cofactor.

**Definition 8.4.** Let $\mu : G \to \mathbb R$ be an arbitrary weight on target classes (e.g. a prior). The **success weight** of a filter is
$$W_\mu(K) = \sum_{(a,b)\,:\, a\in K(ab)} \mu(a).$$

**Theorem 8.5 (Weighted keep law).** $W_\mu(K) = \sum_{c \in G} \sum_{a \in K(c)} \mu(a)$.

*Proof.* Lemma 3.4 with $f(a,c) = [a \in K(c)]\,\mu(a)$. $\square$

For constant $\mu \equiv 1$ this reduces to Theorem 5.1.

**Theorem 8.6 ($N$-blind optimality).** For every filter $K$ there is a public residue $c_0$ such that the *$N$-blind* filter $K'(c) \equiv K(c_0)$, which ignores the public number, satisfies $W_\mu(K) \le W_\mu(K')$. If $K$ has constant keep size $k$, so does $K'$.

*Proof.* Choose $c_0$ maximizing $\sum_{a \in K(c)} \mu(a)$. Then by Theorem 8.5, $W_\mu(K) = \sum_c \sum_{a\in K(c)}\mu(a) \le \sum_c \sum_{a \in K(c_0)} \mu(a) = W_\mu(K')$. $\square$

The prior on the target can be exploited, but reading $N$ adds nothing on top of the best fixed keep-set.

### 8.3 The boundary: the unordered event

Trial division up to $\sqrt N$ must find the **smaller** factor. If a filter is scored instead on the event "*some* factor lies in a kept class," the sham law fails.

**Definition 8.7.** The *mirror* of $T \subseteq G$ at $c$ is $c\,T^{-1} = \{c x^{-1} : x \in T\}$; it is the set of cofactor classes that pair with kept target classes. The *unordered success count* is
$$\operatorname{hit}^{\mathrm{sym}}(K) = \#\{(a,b) : a \in K(ab) \text{ or } b \in K(ab)\}.$$

**Theorem 8.8 (Unordered score).** $\operatorname{hit}^{\mathrm{sym}}(K) = \sum_{c \in G} \bigl|K(c) \cup c\,K(c)^{-1}\bigr|$.

*Proof.* Rewrite $b = a^{-1}(ab)$; then $b \in K(c)$ iff $a \in c\,K(c)^{-1}$. Apply Lemma 3.4. $\square$

**Corollary 8.9.** (a) $\operatorname{hit}(K) \le \operatorname{hit}^{\mathrm{sym}}(K)$. (b) If each $K(c)$ is mirror-closed, $c\,K(c)^{-1} \subseteq K(c)$, the two scores agree. (c) If $K(c) \cup c\,K(c)^{-1} = G$ for every $c$, then $\operatorname{hit}^{\mathrm{sym}}(K) = n^2$: every factor pair is caught on the unordered event, whatever the keep size.

**Proposition 8.10 (Boundary of the sham law).** In the cyclic group $C_3$ of order three, the policies $K_1(c) = \{1\}$ and $K_2(c) = \{c^2\}$ have equal sizes and hence equal ordered scores ($3$ each), but $\operatorname{hit}^{\mathrm{sym}}(K_1) = 5 \ne 3 = \operatorname{hit}^{\mathrm{sym}}(K_2)$.

*Proof.* $\{c^2\} = \{c^{-1}\}$ is its own mirror at $c$, so $K_2$ scores $1+1+1 = 3$. The mirror of $\{1\}$ at $c$ is $\{c\}$, so $K_1$ scores $1 + 2 + 2 = 5$ (the union has size $1$ at $c = 1$ and size $2$ otherwise). $\square$

The unordered event is thus the *only* place in this model where the choice of classes matters — and it is the wrong event for trial division. Scoring on it is a further way an accounting error could manufacture a phantom gain.

---

## 9. Information: capacity orthogonal to the target

We now phrase barrier 2 in Shannon's terms. All distributions are uniform on a finite sample space $S$; for readouts $X, T$ on $S$, $H(X)$ is the entropy in bits, $I(X;T) = H(X) + H(T) - H(X,T)$, and $I(X; T_2 \mid T_1)$ the conditional mutual information.

**Lemma 9.1 (Flat readouts).** If $X$ takes values in a set $A$ and every value in $A$ is taken on exactly a $1/|A|$ share of $S$, then $H(X) = \log_2 |A|$.

**Theorem 9.2 (Flat posterior implies zero channel).** If $X$ takes values in $A$ and, on every fibre of $T$, each value of $A$ is taken on exactly a $1/|A|$ share of the fibre, then $I(X; T) = 0$.

*Proof.* By Lemma 9.1 applied on $S$ and on each fibre, $H(X) = \log_2|A|$ and $H(X \mid T = t) = \log_2 |A|$ for every $t$. The chain rule $H(X,T) = H(T) + \sum_t \Pr[T=t]\,H(X\mid T=t)$ then gives $I(X;T) = 0$. $\square$

**Theorem 9.3 (Zero conversion).** On $S = G \times G$, for every public dial $\varphi$,
$$I\bigl(a\,;\,\varphi(ab)\bigr) = 0.$$

*Proof.* The fibre of the dial at $d$ has $n\cdot\#\varphi^{-1}(d)$ elements (Lemma 3.4), and by Theorem 4.1 each target class occupies exactly $\#\varphi^{-1}(d)$ of them, a $1/n$ share. Apply Theorem 9.2. $\square$

**Corollary 9.4 (Batteries add nothing).** For public dials $\varphi_1, \varphi_2$, $I\bigl(a\,;\,\varphi_2(ab) \mid \varphi_1(ab)\bigr) = 0$.

*Proof.* By the chain rule, $I(a; (\varphi_1,\varphi_2)) = I(a;\varphi_1) + I(a;\varphi_2\mid\varphi_1)$, and both unconditional terms vanish by Theorem 9.3, the battery being itself a dial. $\square$

**Theorem 9.5 (Capacity is real but orthogonal).** For every public dial $\varphi$,
$$I\bigl((a,b)\,;\,\varphi(ab)\bigr) = H\bigl(\varphi(ab)\bigr), \qquad I\bigl(a\,;\,\varphi(ab)\bigr) = 0.$$
In particular the public residue itself carries $I((a,b); ab) = \log_2 n$ bits about the factor pair.

*Proof.* The dial is a function of the pair, so its mutual information with the pair is its full entropy. The public residue is uniform on $G$ (each fibre has $n$ elements), so its entropy is $\log_2 n$. $\square$

**Theorem 9.6 (Public-ness audit).** (a) A dial computed by reading a table $\psi$ through the target, $D(a,b) = \psi(a)$, satisfies $I(a; D) = H(D)$. (b) Any readout $D$ on $G \times G$ with $I(a; D) \ne 0$ is not of the form $\varphi(ab)$: it cannot be computed from the public number.

*Proof.* (a) $D$ is a function of $a$. (b) Otherwise Theorem 9.3 would give $I(a;D)=0$. $\square$

**Example 9.7 (The 1-bit instance).** For $G = (\mathbb Z/3\mathbb Z)^\times$, $I((a,b); ab) = 1$ bit and $I(a; ab) = 0$, while the identity table read through the target leaks $I(a; a) = 1$ bit.

This is exactly the "dummy dial v1" failure: a supposedly neutral dial leaked one bit because it read its random table through the factors rather than through $N$; Theorem 9.6(b) certifies that any such leak is a public-ness violation.

---

## 10. Methodology ledger

The experiment logged nine catches. Three bear directly on the theory:

1. **Two cost-accounting bugs** each produced spurious speedups above $1.5\times$. They were caught by *sham co-inflation*: the coin-flip filter showed the same inflated speedup, which by Theorem 8.2 identifies a keep-size-only artefact, and an explicit derivation of the cost confirmed the error.
2. **Dummy dial v1** leaked $1$ bit about the target. By Theorem 9.6 this certified that the dial was not computable from $N$; inspection showed it read its random table through the factors. It was rebuilt to be public, and the leak disappeared.

The general lesson is that in this problem the sham is a *theorem-backed* control: any discrepancy between real and sham at the level of success counts, or any shared "speedup," has a precise diagnostic meaning.

---

## 11. Algorithms

**Algorithm A (Posterior-ranked filter).** Input: dial $\varphi$, keep size $k$, training sample of factor pairs.
1. For each reading $d$, tabulate counts $w_d(r)$ of training targets in class $r$ among pairs with reading $d$.
2. Set $K(c)$ to the $k$ classes of highest $w_{\varphi(c)}(\cdot)$, ties broken arbitrarily.
3. On input $N$, compute $c = N \bmod m$, then trial-divide only candidates $x \le \sqrt N$ with $x \bmod m \in K(c)$, followed (optionally) by a fallback over the rest.

Cost: tabulation is linear in the sample; per $N$, the membership test is one modular reduction and one table lookup per candidate.

**Algorithm B (Same-size sham).** Identical to Algorithm A except that $K(c)$ is a uniformly random $k$-subset of $G$, drawn independently for each $c$.

**Algorithm C (Exact keep-rate audit).** For a finite group $G$ and a policy $K$, enumerate all $n^2$ pairs $(a,b)$, count $a \in K(ab)$, and compare with $\sum_c |K(c)|$. This $O(n^2)$ check, together with the honest-cost tally of Definition 7.2, validates any proposed filter in the residue model before it is run on real semiprimes.

In the residue model, Theorem 5.1 guarantees that Algorithms A and B have identical success; Theorems 7.4–7.6 guarantee that neither beats the plain scan under honest pricing.

---

## 12. Discussion

**Why the prediction failed.** The $4/3\times$ prediction implicitly assumed that bits about the factor *pair* could be spent on the *target*. Theorem 9.5 shows the two are orthogonal: the full entropy of every public dial is information about the relation between $a$ and $b$, and none of it is information about $a$. Trial division searches for $a$.

**Model versus reality.** The theorems are exact under equidistribution of the factor residues. Real semiprimes satisfy this only approximately; the experiment measured a deviation of about $0.009$, consistent with the noise-floor discrepancy between real and sham. Theorem 8.6 already removes the assumption on the target and retains only uniformity of the cofactor; a quantitative stability version is the natural next step.

**What is and is not ruled out.** The results concern filters and orderings driven by public residue information, with static keep-sets. They say nothing against algorithms that use $N$ in fundamentally different ways (e.g. sieve methods, which exploit smoothness rather than residue classes of a factor). Within the trial-division paradigm, the utility question is closed: type-channel and battery capacity have exactly zero conversion into speed, and honest accounting caps every filter at $1\times$.

---

## 13. Future work

1. **Approximate flatness.** If the cofactor residue law is $\varepsilon$-close to uniform in total variation, every public-dial filter should exceed the best $N$-blind filter of the same size by at most $2\varepsilon$ times the keep size, with a matching small bound on $I(a; \text{dial})$. Flat transport is a bijection, so a total-variation perturbation perturbs every keep count linearly.
2. **Non-abelian Frobenius filters.** Replacing residues by Frobenius classes in a non-abelian Galois group, any filter built from class functions of the Frobenius of $N$ should still have success equal to keep size whenever the cofactor's Frobenius is Haar-distributed; flat transport uses only left multiplication.
3. **Mirror-pair covering number.** The minimal keep size achieving full unordered coverage should be $\lceil (n + s(c))/2 \rceil$ with $s(c)$ the number of square roots of $c$ — yet its ordered success is still only its keep rate.
4. **Adaptive filters.** Even when the keep-set adapts to failed divisions, the expected cost under a flat posterior should be at least $(n+1)/2$ divisions, since a failed division removes one class and leaves the posterior flat on the rest.

---

## 14. Conclusion

A Bayesian filter built from the exact posterior over the smaller factor's residue class is no better than a coin. This is not an empirical accident but a theorem: the map $(a,b)\mapsto(a,ab)$ is a bijection, so the public residue is independent of the target, the posterior is flat, success equals keep size, every ordering has the same expected cost, and under honest pricing no filter beats plain trial division, while full-keep filters run at exactly half speed. Public dials carry their full entropy about the factor pair and exactly zero bits about the factor that trial division must find.
