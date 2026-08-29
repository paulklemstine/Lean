# The Filter Cap Law: $4/3$ for Exchangeable Dials, $1/\theta$ for Structural Ones

**Author:** Aristotle
**Date:** 2026-08-28

---

## Abstract

We give a complete analysis of a one-parameter cost model for candidate filters ("dials") in trial-division search, and use it to separate two regimes that are routinely conflated. Normalising the cost of an unfiltered sweep to $1$, a dial with retention $\theta \in (0,1]$ and soundness $s \in [0,1]$ has expected cost $1-s+s\theta$ and speedup $(1-s+s\theta)^{-1}$. We prove:

1. **The cap law.** An *exchangeable* dial ($s = \theta$: the true answer is retained no more readily than any other candidate) has speedup at most $4/3$, with equality exactly at $\theta = 1/2$.
2. **A sharp criterion.** A dial exceeds $4/3$ if and only if $s(1-\theta) > 1/4$; exchangeability makes this impossible because $\theta(1-\theta) \le 1/4$.
3. **A quantitative escape cost.** Any dial beating the cap satisfies $s - \theta > (1-2\theta)^2/\bigl(4(1-\theta)\bigr)$, a bound that vanishes precisely at $\theta = 1/2$, identifying half-retention as the extremal test point.
4. **The structural loophole.** A *deterministic* dial ($s=1$) has speedup $1/\theta$, unbounded as $\theta \to 0$; and the family of wheel dials of squarefree modulus $M$, with speedup $M/\varphi(M)$, is unbounded, by divergence of $\sum 1/p$.
5. **A zero-information, super-cap dial exists.** The residue table revealed by the Berggren tree of Pythagorean triples is the fixed two-element set $\{(1,0,1),(3,0,1)\}$ modulo $4$, identical for every target; the dial it induces has mutual information exactly $0$ with the target — the absolute floor, by a finite Gibbs inequality — while reading a speedup of $2 > 4/3$.
6. **The dichotomy.** A fixed dial evaluated against a *uniform* prior on candidates has soundness equal to retention and is therefore capped; a fixed dial evaluated against a prior *supported* in its kept set has soundness $1$. The escape is created by the prior, never by information.

Consequently the $4/3$ cap is not a bound on speedups: it bounds dials with no answer-bias, and a blind structural exclusion supplies such a bias for free, so a reading above $4/3$ is never by itself evidence of instance information.  The honest test of an informational claim measures a dial against the pool with the blind structure already discounted. Blind structural exclusions carry zero bits and are worth exactly their constant factor. In logarithmic coordinates the two regimes are visibly different objects — structural weights are additive under composition and unbounded, while exchangeable weights are confined to the window $[0, \log(4/3)]$, closed under composition.

Empirically, at the extremal operating point $\theta = 1/2$ over a population of $800$ semiprimes with moduli $m \in \{3,4,5,7,8,16\}$, a matched-random dial reads $1.3387$ (CI $[1.3008, 1.382]$) against the prediction $4/3 = 1.3333$; the orbit dial reads $2.0000$ with failure rate $0.000$ and paired difference exactly $0.0$ against a target-independent fixed dial; and no measured feature carries more than $0.09$ bits against ordinary residue baselines of $1$–$3$ bits.

**Keywords:** filter cost model, exchangeability, mutual information, Pythagorean triple tree, wheel sieve, Euler product, tropical semiring.

---

## 1. Introduction

### 1.1 The question

A search over a candidate set is the most primitive algorithm there is. Filtering that set before searching is the most primitive optimisation. The question this paper answers is: *how much is a filter worth, and where does its worth come from?*

The naive intuition is that a filter's value is measured by how much it discards. This is false, and the failure is quantitative and interesting. A filter that discards $99\%$ of candidates but discards the answer $99\%$ of the time is worth almost nothing, because the $1\%$ of the time it succeeds it saves you a full sweep, and the other $99\%$ you pay for the filtered sweep *and* the full sweep. There is an exact tension between aggressiveness and reliability, and once written down it yields a hard ceiling.

The second intuition — the one that motivated the present investigation — is that a filter's value tracks the *information* it carries about the instance. This is also false, and more interestingly so: we exhibit a filter with mutual information *exactly zero* against the instance that nonetheless outperforms the ceiling that binds every unbiased filter. Resolving that apparent contradiction is the substance of the paper.

### 1.2 Setting

Throughout, the object being searched for is a nontrivial divisor $p$ of an odd composite $N$, sought by descending trial division from $\lfloor\sqrt{N}\rfloor$. Nothing depends on this particular application; the reader may substitute any search whose baseline is an unfiltered sweep. What we do use, in Section 6, is a structural fact about the search: *the divisors of an odd number are odd*. This is a statement about the problem, not about any particular instance, and it is exactly the leverage that the structural regime exploits.

### 1.3 Summary of contributions

Sections 2–3 develop the cost model and prove the cap law with its sharp criterion and quantitative escape cost. Section 4 identifies the deterministic regime and computes its speedup. Section 5 analyses the Berggren tree of Pythagorean triples and proves that its revealed residue table is a universal constant. Section 6 measures the information content of the two dial types and exhibits the paradox. Section 7 resolves it via the prior/information dichotomy. Section 8 develops the unbounded wheel family and its tropical accounting. Section 9 reports the experimental readings. Sections 10–11 discuss scope, applications, and open problems.

---

## 2. The cost model

### 2.1 Definitions

**Definition 2.1 (Dial).** A *dial* is a rule applied to the candidate pool of a search, characterised by two parameters:
- its **retention** $\theta \in (0,1]$, the fraction of candidates it retains;
- its **soundness** $s \in [0,1]$, the probability that the sought object is among the retained candidates.

**Definition 2.2 (Cost and speedup).** Normalise the cost of an unfiltered sweep of the whole pool to $1$. The *expected cost* of the dial is
$$\mathrm{cost}(s,\theta) \;=\; s\cdot\theta \;+\; (1-s)\cdot 1 \;=\; 1 - s + s\theta,$$
and its *speedup* is $\mathrm{speedup}(s,\theta) = \mathrm{cost}(s,\theta)^{-1}$.

The derivation of the cost is the two-branch accounting: sweep the retained fraction at cost $\theta$; with probability $s$ the object is found there and the search terminates; with probability $1-s$ it is not, and the complement must be swept as well, for total cost $\theta + (1-\theta) = 1$. Both branches assume the sweep is exhaustive and the pool ordering is uninformative, which is the honest baseline.

Two immediate specialisations: $\mathrm{cost}(1,\theta) = \theta$ (a dial that never discards the answer costs exactly what it sweeps), and $\mathrm{cost}(0,\theta) = 1$ (a dial that always discards the answer is worthless, exactly).

**Lemma 2.3 (Positivity).** For $0 \le s \le 1$ and $\theta > 0$, $\mathrm{cost}(s,\theta) > 0$.

*Proof.* If $s = 1$ the cost is $\theta > 0$. If $s < 1$ then $1-s > 0$ and $s\theta \ge 0$, so the sum is positive. $\square$

Hence the speedup is always well-defined and positive on the admissible parameter region.

### 2.2 Exchangeability

**Definition 2.4 (Exchangeable dial).** A dial is *exchangeable* if $s = \theta$: it retains the sought object with exactly the probability with which it retains an arbitrary candidate.

Exchangeability is the formal content of "the filter has no special insight into where the answer is." It is the null model against which any claimed filtering advantage must be compared. Note that it is a statement about the *joint* behaviour of the filter and the answer, not about the filter alone — the same filter may be exchangeable against one prior and highly sound against another. Section 7 makes this precise and shows it is the whole story.

For an exchangeable dial,
$$\mathrm{cost}(\theta,\theta) = 1 - \theta + \theta^2.$$

---

## 3. The cap law

### 3.1 Statement and proof

**Lemma 3.1 (Exchangeable cost floor).** For all real $\theta$,
$$\mathrm{cost}(\theta,\theta) \;\ge\; \tfrac34,$$
with equality if and only if $\theta = 1/2$.

*Proof.* Complete the square:
$$1-\theta+\theta^2 - \tfrac34 = \Bigl(\theta - \tfrac12\Bigr)^2 \;\ge\; 0,$$
with equality precisely when $\theta = 1/2$. $\square$

**Theorem 3.2 (The cap law).** Every exchangeable dial with retention $\theta \in (0,1]$ has
$$\mathrm{speedup}(\theta,\theta) \;\le\; \frac43 .$$

*Proof.* By Lemma 2.3 the cost is positive, and by Lemma 3.1 it is at least $3/4$; inverting reverses the inequality, giving $\mathrm{speedup} \le (3/4)^{-1} = 4/3$. $\square$

**Corollary 3.3 (No counterexample).** There is no $\theta \in (0,1]$ with $\mathrm{speedup}(\theta,\theta) > 4/3$.

**Theorem 3.4 (Extremality of half-retention).** For $\theta \in (0,1]$,
$$\mathrm{speedup}(\theta,\theta) = \frac43 \iff \theta = \frac12 .$$

*Proof.* Forward: equality of speedups forces equality of costs, $\mathrm{cost}(\theta,\theta) = 3/4$, hence $(\theta-1/2)^2 = 0$ and $\theta = 1/2$. Backward: direct computation, $1 - 1/2 + 1/4 = 3/4$. $\square$

The extremality is the design principle for any test of the cap: at $\theta = 1/2$ the exchangeable dial sits *exactly* on the boundary, so any real bias toward the answer registers immediately. Elsewhere the exchangeable value is strictly below $4/3$ and a violation would need to overcome the slack first. Theorem 3.7 quantifies this.

### 3.2 The sharp criterion

**Theorem 3.5 (Sharp cap-breaking criterion).** For $0 \le s \le 1$ and $\theta > 0$,
$$\mathrm{speedup}(s,\theta) > \frac43 \iff s(1-\theta) > \frac14 .$$

*Proof.* Since the cost is positive, $\mathrm{speedup} > 4/3$ is equivalent to $\mathrm{cost}(s,\theta) < 3/4$, i.e. $1 - s + s\theta < 3/4$, i.e. $s(1-\theta) > 1/4$ after rearrangement. $\square$

**Proposition 3.6 (Exchangeability never fires).** For all real $\theta$, $\theta(1-\theta) \le 1/4$.

*Proof.* $\tfrac14 - \theta(1-\theta) = (\theta - \tfrac12)^2 \ge 0$. $\square$

Theorem 3.2 is therefore Proposition 3.6 read through Theorem 3.5: the cap law is the arithmetic–geometric mean inequality for a pair of numbers summing to $1$. This is the conceptual heart of the barrier — it is not an artefact of the cost model's shape but a statement about the impossibility of simultaneously retaining little and retaining the answer often, when those two are the same event.

### 3.3 The quantitative escape cost

**Theorem 3.7 (Soundness excess).** Let $0 \le s \le 1$, $0 < \theta < 1$, and suppose $\mathrm{speedup}(s,\theta) > 4/3$. Then
$$s - \theta \;>\; \frac{(1-2\theta)^2}{4(1-\theta)} .$$

*Proof sketch.* By Theorem 3.5, $s(1-\theta) > 1/4$. Multiply the target inequality by $4(1-\theta) > 0$: it becomes $(1-2\theta)^2 < 4(1-\theta)(s-\theta)$. Expanding, $4(1-\theta)(s-\theta) = 4s(1-\theta) - 4\theta(1-\theta) > 1 - 4\theta + 4\theta^2 = (1-2\theta)^2$, using the criterion on the first term and Proposition 3.6 on the second. $\square$

The bound is a completed square divided by a positive quantity, so it is nonnegative, and it vanishes exactly at $\theta = 1/2$. Sample values of the required excess: at $\theta = 0.1$, $s - \theta > 0.1778$; at $\theta = 0.25$, $s-\theta > 0.0833$; at $\theta = 0.5$, $s - \theta > 0$; at $\theta = 0.9$, $s-\theta > 1.6$, which is impossible since $s \le 1$ — a dial retaining $90\%$ of candidates can never beat the cap, whatever its soundness. Indeed by Theorem 3.5 the cap is unreachable for any $\theta > 3/4$, since then $s(1-\theta) \le 1-\theta < 1/4$.

**Corollary 3.8 (Bias is necessary).** Under the hypotheses of Theorem 3.7, $\theta < s$: a dial that beats the cap is strictly more likely to retain the sought object than a random candidate.

*Proof.* The right-hand side of Theorem 3.7 is a nonnegative quantity, so $s - \theta > 0$. $\square$

Corollary 3.8 is the fork in the road. Some mechanism must be biasing the dial toward the answer. Sections 5–7 identify the two — and only two — available mechanisms.

### 3.4 Monotonicity

**Proposition 3.9.** For fixed $\theta \in (0,1]$, $\mathrm{speedup}(s,\theta)$ is nondecreasing in $s$ on $[0,1]$.

*Proof.* $\mathrm{cost}(s,\theta) = 1 - s(1-\theta)$ is nonincreasing in $s$ since $1-\theta \ge 0$; inverting a positive nonincreasing function gives a nondecreasing one. $\square$

So for fixed retention the best possible dial is the sound one, $s = 1$, which is the subject of the next section.

---

## 4. The deterministic regime

**Theorem 4.1 (Deterministic speedup).** A dial with soundness $s = 1$ has $\mathrm{speedup}(1,\theta) = 1/\theta$.

*Proof.* $\mathrm{cost}(1,\theta) = 1 - 1 + \theta = \theta$. $\square$

A dial that *never* discards the answer pays exactly the retained fraction, with no correction term at all. Its speedup is therefore unbounded as $\theta \to 0^+$: the entire cap phenomenon evaporates.

**Corollary 4.2 (The parity skip).** The dial "discard even candidates," applied to the divisor search for an odd $N$, has $\theta = 1/2$ and $s = 1$, hence speedup exactly $2$.

The soundness claim requires the structural fact:

**Proposition 4.3.** If $N$ is odd and $p \mid N$, then $p$ is odd.

*Proof.* If $2 \mid p$ and $p \mid N$ then $2 \mid N$, contradicting oddness. $\square$

**Corollary 4.4 (The measured ratio).** At $\theta = 1/2$,
$$\frac{\mathrm{speedup}(1, 1/2)}{\mathrm{speedup}(1/2,1/2)} = \frac{2}{4/3} = \frac32 .$$

This is the exact ratio the experiment of Section 9 sees between its orbit arm and its matched-random arm. It is a theorem, not a measurement.

---

## 5. The Berggren orbit and its universal residue table

### 5.1 The tree

**Definition 5.1.** A triple $t = (a,b,c) \in \mathbb{Z}^3$ is *Pythagorean* if $a^2+b^2=c^2$. Define three linear maps
$$B_1(a,b,c) = (a-2b+2c,\; 2a-b+2c,\; 2a-2b+3c),$$
$$B_2(a,b,c) = (a+2b+2c,\; 2a+b+2c,\; 2a+2b+3c),$$
$$B_3(a,b,c) = (-a+2b+2c,\; -2a+b+2c,\; -2a+2b+3c).$$
Let $\mathcal{T}$ be the smallest set containing $(3,4,5)$ and closed under $B_1, B_2, B_3$: the *root component* of the Berggren tree.

**Proposition 5.2.** Every $t \in \mathcal{T}$ is Pythagorean.

*Proof sketch.* Induction. The root satisfies $9+16=25$. For each $B_i$, expanding the image's defining identity produces exactly the hypothesis $a^2+b^2=c^2$ multiplied by a constant — the maps are (up to sign conventions) orthogonal for the form $a^2+b^2-c^2$, so the form is preserved identically. Each case is a polynomial identity in $a,b,c$. $\square$

Classically, $\mathcal{T}$ is exactly the set of primitive Pythagorean triples with $a$ odd, each occurring once, and the tree is ternary and complete. We need only the following invariant.

### 5.2 The invariant

**Theorem 5.3 (Congruence invariant of the root component).** For every $(a,b,c) \in \mathcal{T}$:
$$a \equiv 1 \pmod 2, \qquad b \equiv 0 \pmod 4, \qquad c \equiv 1 \pmod 4 .$$

*Proof sketch.* Induction on the generation of $\mathcal{T}$. The root $(3,4,5)$ satisfies all three. Suppose $(a,b,c)$ does. Consider $B_2$; the others are identical up to signs, which do not affect residues mod $4$ up to a case split.

- First coordinate $a + 2b + 2c$: with $4 \mid b$ we have $2b \equiv 0 \pmod 4$, and $2c \equiv 2 \pmod 4$, so the coordinate is $a + 2 \pmod 4$, which is odd because $a$ is.
- Second coordinate $2a + b + 2c$: modulo $4$ this is $2a + 0 + 2 = 2(a+1)$, and $a$ odd makes $a+1$ even, so the coordinate is $\equiv 0 \pmod 4$.
- Third coordinate $2a + 2b + 3c$: modulo $4$ this is $2a + 0 + 3 = 2a+3$, and $a$ odd gives $2a \equiv 2$, so the coordinate is $\equiv 5 \equiv 1 \pmod 4$.

All three cases are finite modular arithmetic and close the induction. $\square$

### 5.3 Universality of the revealed set

**Definition 5.4.** The *revealed residue set mod 4* of the root component is
$$R_4 \;=\; \bigl\{\,(a \bmod 4,\; b \bmod 4,\; c \bmod 4) \;:\; (a,b,c) \in \mathcal{T} \,\bigr\} \subseteq (\mathbb{Z}/4)^3 .$$

**Theorem 5.5 (Universality).**
$$R_4 \;=\; \bigl\{(1,0,1),\ (3,0,1)\bigr\}.$$

*Proof.* Containment $\subseteq$: by Theorem 5.3, $b \equiv 0$ and $c \equiv 1$ modulo $4$, and $a$ odd means $a \equiv 1$ or $3$ modulo $4$. Containment $\supseteq$: the root $(3,4,5)$ realises $(3,0,1)$, and its first $B_1$-child $B_1(3,4,5) = (5,12,13)$ realises $(1,0,1)$. $\square$

**Corollary 5.6 (No parameter dependence).** $R_4$ is a fixed two-element set. It does not depend on the search depth, on any target $N$, or on anything else: the "orbit dial" it induces is one universal exclusion table, computable in advance and identical for every instance.

This is the central negative result of the characterisation. The design premise being tested — that the subset of residues revealed by walking the tree varies with the target, and hence carries per-target information — fails for the root component, and fails structurally rather than for want of computational budget. (For the generic non-root components, the corresponding revealed sets saturate instantly to all $m$ classes at every modulus tested, so there is likewise no per-target subset structure; only frequencies and orbit lengths vary.)

### 5.4 A companion congruence

**Theorem 5.7.** In every Pythagorean triple $(a,b,c)$, $3 \mid ab$.

*Proof.* Work modulo $3$, where the squares are $\{0,1\}$. If neither $a$ nor $b$ is divisible by $3$ then $a^2 + b^2 \equiv 1+1 = 2$, which is not a square modulo $3$; contradiction. (Exhaustively: all $27$ triples of residues satisfying $a^2+b^2 \equiv c^2$ have $ab \equiv 0$.) $\square$

This is another universal structural exclusion, of the same type: it holds for every triple, hence carries no instance information, and it is exactly the sort of congruence that a naive information-theoretic accounting would misattribute to "discovered structure."

---

## 6. Information content

### 6.1 Definitions

**Definition 6.1.** For a joint law $p$ on a finite product alphabet $\mathcal{X}\times\mathcal{Y}$, with marginals $p_X(x) = \sum_y p(x,y)$ and $p_Y(y) = \sum_x p(x,y)$, the *mutual information* is
$$I(X;Y) \;=\; \sum_{x,y} p(x,y) \log \frac{p(x,y)}{p_X(x)\,p_Y(y)},$$
with the convention $0 \log 0 = 0$. Measured in bits, $I_{\mathrm{bits}} = I/\log 2$.

### 6.2 The floor

**Theorem 6.2 (Gibbs / nonnegativity).** For any nonnegative joint law $p$ with total mass $1$, $I(X;Y) \ge 0$.

*Proof sketch.* Cell by cell, with $r = p(x,y)/(p_X(x)p_Y(y))$ and $p(x,y) > 0$, the elementary bound $\log r \ge 1 - 1/r$ (equivalently $\log r^{-1} \le r^{-1} - 1$) gives
$$p(x,y)\log r \;\ge\; p(x,y)\Bigl(1 - \tfrac1r\Bigr) \;=\; p(x,y) - p_X(x)p_Y(y).$$
Cells with $p(x,y) = 0$ satisfy the same bound trivially since the right side is then $-p_X(x)p_Y(y) \le 0$. Summing over all cells, the right-hand side telescopes to $\sum p - (\sum_x p_X)(\sum_y p_Y) = 1 - 1 = 0$. $\square$

### 6.3 Zero bits for the orbit dial

**Theorem 6.3 (Constant dials are uninformative).** If the dial's output is deterministic — there is a symbol $y_0$ with $p(x,y) = 0$ for all $x$ and all $y \neq y_0$ — then $I(X;Y) = 0$ exactly.

*Proof.* Under the hypothesis, $p_X(x) = p(x,y_0)$ for every $x$, and $p_Y(y_0) = \sum_x p(x,y_0) = \sum_x p_X(x) = 1$. Every cell with $y \ne y_0$ contributes $0$ by the convention. Every cell with $y = y_0$ and $p(x,y_0) > 0$ has ratio $p(x,y_0)/(p_X(x)\cdot 1) = 1$, hence $\log 1 = 0$. $\square$

By Theorem 5.5 the orbit dial's revealed table is a constant of the tree, so its joint law with the target is exactly of this form. Combining with Theorem 6.2:

**Corollary 6.4.** The orbit dial attains the absolute information floor: its mutual information with the target is $0$, and no joint law achieves less.

### 6.4 One bit for an ordinary residue dial

**Definition 6.5.** Let $\mathcal{X} = \mathcal{Y} = \{0,1\}$ and $p(x,y) = \tfrac12$ if $x=y$, else $0$: a perfectly correlated pair on two equiprobable classes.

**Theorem 6.6.** $I(X;Y) = \log 2$, i.e. exactly one bit.

*Proof.* Both marginals are uniform, $p_X = p_Y = 1/2$. The two diagonal cells each contribute $\tfrac12 \log\bigl(\tfrac{1/2}{1/4}\bigr) = \tfrac12\log 2$; the off-diagonal cells contribute $0$. $\square$

This is the model of a genuine, instance-dependent congruence hint. A concrete realisation:

**Proposition 6.7.** Let $p,q$ be odd with $pq \equiv 3 \pmod 4$. Then exactly one of $p,q$ is $\equiv 1$ and the other $\equiv 3$ modulo $4$.

*Proof.* Each of $p,q$ is $1$ or $3$ mod $4$. The four products are $1\cdot1=1$, $1\cdot3=3$, $3\cdot1=3$, $3\cdot3\equiv1$. Only the mixed cases give $3$. $\square$

Knowing $N \bmod 4$ therefore genuinely constrains the factor classes — the dial's output *changes with the instance*, which is precisely what the orbit dial's output does not do.

### 6.5 The paradox

Assembling Theorems 3.2, 4.1, 6.3 and 6.6:

**Theorem 6.8 (Zero information, super-cap speedup).**
1. The orbit dial has mutual information $0$ bits with the target.
2. An ordinary one-bit residue dial has mutual information $1$ bit.
3. The orbit dial reads speedup $2$ at $\theta = 1/2$.
4. Every exchangeable dial reads at most $4/3$.

In particular the zero-bit dial outperforms the ceiling that binds the one-bit dial. Information does not order speedup.

---

## 7. The resolution: prior, not information

The apparent contradiction in Theorem 6.8 is dissolved by noticing that *soundness is not a property of a dial* — it is a property of a dial *relative to a prior* over where the answer lies.

**Definition 7.1.** Fix a finite candidate pool $C$ and a *fixed* dial, i.e. a retained set $K$. Its *retention* is $\theta = |K\cap C|/|C|$. Given a prior $\pi$ on $C$ with $\sum_{a\in C}\pi(a) = 1$, its *soundness* is $s = \sum_{a \in K \cap C} \pi(a)$.

**Theorem 7.2 (Uniform prior forces exchangeability).** If $\pi$ is uniform on $C$, then $s = \theta$.

*Proof.* $s = \sum_{a\in K\cap C} 1/|C| = |K\cap C|/|C| = \theta$. $\square$

**Corollary 7.3 (No free lunch for information-free dials in general).** A fixed dial evaluated against a uniform prior obeys the $4/3$ cap.

*Proof.* Theorem 7.2 places it in the exchangeable class; apply Theorem 3.2. $\square$

Corollary 7.3 is the precise sense in which "you cannot beat the cap without learning something." A dial fixed in advance, facing a problem with no structural bias, is capped like everyone else. So the loophole must lie in the *problem*, not the dial:

**Theorem 7.4 (Supported prior gives perfect soundness).** If $\pi(a) = 0$ for every $a \in C \setminus K$, then $s = 1$, whatever the retention.

*Proof.* $\sum_{a\in K\cap C}\pi(a) = \sum_{a \in C}\pi(a) = 1$, since the omitted terms all vanish. $\square$

**Theorem 7.5 (Parity retention).** In the pool $C = \{0,1,\dots,2k-1\}$, the odd candidates number exactly $k$, so the parity dial has retention exactly $1/2$.

*Proof.* Induction on $k$: adjoining $\{2k, 2k+1\}$ adds exactly one odd element. $\square$

**Theorem 7.6 (The escape, end to end).** For odd $N$, in any even-length candidate pool, the parity dial has retention $1/2$ (Theorem 7.5) and soundness $1$ (Proposition 4.3 makes the divisor prior supported in the odd residues, then Theorem 7.4), hence speedup $2$; whereas the same fixed dial against a uniform prior would have soundness $1/2$ and speedup exactly $4/3$.

**The dichotomy.** By Corollary 3.8, beating the cap requires $s > \theta$. By Theorems 7.2 and 7.4 there are exactly two sources of such a gap:

- **Information.** The dial's kept set varies with the instance, in a way correlated with the answer's location. This is the regime the cap law governs, and it is capped at $4/3$ per exchangeable stage.
- **Prior concentration.** The kept set is fixed, but the answer was already constrained to lie inside it, by a congruence true of the problem class rather than of the instance. This regime carries zero bits and escapes the cap.

The orbit dial is entirely of the second kind. The correct statement of the barrier is therefore: **a dial with no answer-bias cannot beat $4/3$**; a super-cap reading certifies bias, and only the *source* of the bias distinguishes a discovery from a blind constant.

This has an immediate methodological corollary, the *filter accounting rule*: an informational claim must be measured on the pool with the blind structure already discounted.  A dial that quietly re-derives a structural congruence inherits its constant and can read above the cap while contributing nothing of its own.  Discount the blind part — measure retention and soundness relative to the already-structurally-filtered pool — and only a genuine instance-dependent bias survives.  In the readings of Section 9 nothing survived: discounted, the orbit dial reads exactly $1$.

---

## 8. Wheels: the unbounded structural family

The parity skip is the smallest member of an infinite family.

**Definition 8.1 (Wheel dial).** Fix a squarefree modulus $M$ coprime to the target $N$. The *wheel dial of modulus $M$* retains exactly the candidates coprime to $M$. Its idealised speedup is $W(M) = M/\varphi(M)$.

**Theorem 8.2 (Soundness).** If $\gcd(N,M) = 1$ and $p \mid N$, then $\gcd(p,M)=1$. Hence $s = 1$.

*Proof.* A common factor of $p$ and $M$ divides $N$ and $M$. $\square$

**Theorem 8.3 (Retention).** Exactly $\varphi(M)$ of the $M$ residues mod $M$ are coprime to $M$, so the retained fraction is $\varphi(M)/M$ and, by Theorem 4.1, the speedup is $M/\varphi(M)$.

**Theorem 8.4 (Blindness).** The wheel dial's kept set $\{p : \gcd(p,M)=1\}$ does not depend on $N$: one universal table per modulus, carrying zero bits by Theorem 6.3.

**Theorem 8.5 (Euler product).** For $M = \prod_{p\in S} p$ with $S$ a finite set of distinct primes,
$$W(M) \;=\; \prod_{p\in S} \frac{p}{p-1}.$$

*Proof sketch.* Multiplicativity of $\varphi$ on coprime factors and $\varphi(p) = p-1$ give $\varphi(M) = \prod_{p\in S}(p-1)$ by induction on $S$; divide into $M = \prod_{p\in S} p$ termwise. $\square$

Concretely: $W(2) = 2$, $W(6) = 3$, $W(30) = 15/4 = 3.75$, $W(210) = 35/8 = 4.375$. All exceed $4/3$; all carry zero bits.

**Theorem 8.6 (Structural dials are unbounded).** For every $B \in \mathbb{R}$ there is a squarefree $M$ with $W(M) > B$.

*Proof sketch.* Two ingredients. First, the Weierstrass bound $\prod_{i}(1+x_i) \ge 1 + \sum_i x_i$ for $x_i \ge 0$, proved by induction (the inductive step needs only $x_a \sum_{i} x_i \ge 0$). Second, for prime $p$,
$$\frac{p}{p-1} \;\ge\; 1 + \frac1p,$$
equivalent after clearing denominators to $p - \tfrac1p \ge p-1$, i.e. $\tfrac1p \le 1$. Combining with Theorem 8.5, $W(M) \ge 1 + \sum_{p \in S} 1/p$. Since $\sum_p 1/p$ diverges over the primes, one may choose a finite $S$ with $\sum_{p\in S} 1/p > B$. $\square$

Theorem 8.6 is the decisive structural statement. **The $4/3$ cap is not a bound on speedups.** Information-free filters of arbitrarily large constant advantage exist; they are the classical wheels, and their advantage is bounded only by the divergence rate of $\sum 1/p$ — which, by Mertens, is $\log\log$ slow, but unbounded.

### 8.1 Tropical accounting

Independent structural dials *compose multiplicatively*, so their logarithms add. This is the arithmetic of the tropical semiring $(\mathbb{R}\cup\{+\infty\}, \min, +)$, in which "multiplication" is ordinary addition of weights and "addition" is minimum.

**Theorem 8.7 (Structural composition).** $\mathrm{speedup}(1,\theta_1\theta_2) = \mathrm{speedup}(1,\theta_1)\cdot\mathrm{speedup}(1,\theta_2)$.

*Proof.* $(\theta_1\theta_2)^{-1} = \theta_1^{-1}\theta_2^{-1}$ by Theorem 4.1. $\square$

**Theorem 8.8 (Wheel multiplicativity).** For coprime $M_1, M_2$, $W(M_1M_2) = W(M_1)W(M_2)$.

*Proof.* Multiplicativity of $\varphi$ on coprime arguments. $\square$

**Definition 8.9.** The *tropical weight* of a wheel is $w(M) = \log W(M)$, an element of the tropical semiring.

**Theorem 8.10.** $w$ is a monoid homomorphism on coprime moduli: $w(M_1M_2) = w(M_1) + w(M_2)$, i.e. tropical multiplication of weights. Tropical addition, $w(M_1) \oplus w(M_2) = \min\bigl(w(M_1), w(M_2)\bigr)$, is the pessimistic combination. Moreover $w(M) \ge 0$ for $M \ge 1$, since $\varphi(M) \le M$.

**Theorem 8.11 (Unbounded structural window).** $\sup_M w(M) = +\infty$.

*Proof.* Apply Theorem 8.6 with bound $e^B$ and take logarithms. $\square$

**Theorem 8.12 (Bounded exchangeable window).** For $\theta \in (0,1]$, $\log \mathrm{speedup}(\theta,\theta) \in [0, \log\tfrac43]$, and the window is closed under composition: if $\theta_1, \theta_2 \in (0,1]$ then the stacked dial with retention $\theta_1\theta_2$ is again exchangeable and again capped.

*Proof.* The lower bound is $\mathrm{cost}\le 1$; the upper is Theorem 3.2 under $\log$, which is monotone. Closure is Theorem 3.2 applied at $\theta_1\theta_2 \in (0,1]$. $\square$

**The scope note in tropical form.** Exchangeable weights inhabit the compact window $[0, \log(4/3)] \approx [0, 0.2877]$, closed under composition. Structural weights form an unbounded additive family, with the parity skip at $w(2) = \log 2 \approx 0.6931$ — already outside the window, with zero bits of instance content. These are two genuinely different objects, not two points on one scale.

---

## 9. Experimental readings

The theory above was tested on a population of $800$ semiprimes of bit-length $40$ ($500$ balanced, $300$ with factor ratio $4$), with moduli $m \in \{3,4,5,7,8,16\}$, using permutation nulls stratified by decile of $\log N$, at the extremal operating point $\theta = 1/2$ under $\sqrt{\cdot}$-descending trial division.

**Matched-random arm.** A dial retaining a random half of the candidates read a speedup of
$$1.3387 \quad \text{CI } [1.3008,\ 1.382],$$
against the prediction $4/3 = 1.3333$ of Theorems 3.2 and 3.4. The cap law is confirmed to within about $0.4\%$. A co-inflation ("sham") control designed to detect artefactual enhancement returned $[1.2717,\ 1.3579]$ — clean, bracketing the prediction.

**Orbit arm.** The orbit dial read
$$2.0000 \quad \text{CI } [2.0,\ 2.0], \qquad \text{failure rate } 0.000,$$
matching Corollary 4.2 exactly. Crucially, when compared instance by instance against a universal fixed dial computable from $N$ alone with no tree walk, the paired difference was $0.0$ **exactly**. The orbit dial *is* the parity skip: the observed $2\times$ is a constant shave, not a barrier event. The measured ratio between the two arms, $2/1.3387 = 1.494$, matches the theoretical $3/2$ of Corollary 4.4 to within the matched-random arm's own error.

**Information null.** Across $48$ measurement cells, the maximum standardised joint deviation was $+2.29$ and the maximum conditional deviation $+1.78$ — the sort of extremes one expects from $48$ draws under the null. No feature carried more than $0.09$ bits, against ordinary residue-dial baselines of $I(N \bmod m;\, p \bmod m) = 1.00$–$3.00$ bits. Nothing beyond ordinary residue content was present, exactly as Theorem 6.3 and Corollary 5.6 predict.

**Loaded accounting.** When each arm was charged its own evaluation overhead, *every* arm read below $1$ (range $0.20$–$0.75$). The idealised accounting of Sections 2–8 charges nothing for applying a dial; in practice the bookkeeping of a large wheel eventually consumes the constant it buys. This is the honest practical caveat, and it is the reason none of these constants translate into a usable factoring advantage at cryptographic sizes.

**Interpretation.** The pre-registered hypothesis that the orbit's revealed-set advantage is fully accounted for by ordinary residue content, with measured speedup indistinguishable from a matched-random dial *within the exchangeable class*, is confirmed — with one scope refinement, namely that the observed $2.0$ read arises outside that class entirely, as a deterministic exclusion. The competing hypothesis, that a speedup above $4/3$ survives replication, sham control, and computability-from-$N$-alone as an *informative* effect, is false: the effect is real but blind.

---

## 10. Discussion

### 10.1 What the cap does and does not say

The cap law is often stated informally as "filters are worth at most $4/3$." That statement is false, and the parity skip refutes it in one line. The correct statement is conditional on exchangeability, which is itself conditional on the prior. Precisely:

> A filter whose retention of the answer is statistically indistinguishable from its retention of an arbitrary candidate cannot be worth more than $4/3$, whatever it retains. A filter that beats $4/3$ has an answer-retention bias, sourced either from instance information or from a structural congruence of the problem class.

The second half of that sentence is the contribution. It converts a barrier into a classification.

### 10.2 Why the loaded arms all read below $1$

Every idealised speedup above charges nothing for evaluating the dial. Charging $\kappa$ per candidate turns the cost into $\kappa + 1 - s + s\theta$, and the loaded speedup into $1/(\kappa + \mathrm{cost})$. Immediately: the exchangeable cap tightens to $1/(\kappa + 3/4)$, and the deterministic parity dial falls below $1$ once $\kappa > 1/2$. That one-parameter deformation appears to account deterministically for the observed loaded readings, and is a natural next theorem.

### 10.3 Relation to sieve practice

Everything in Section 8 is, mathematically, the wheel of a classical sieve; the contribution here is not the wheel but its *classification* as a zero-information object, together with the observation that the divergence of $\sum 1/p$ is exactly the statement that this class is unbounded. The tropical framing then makes the two regimes' incomparability structural rather than numerical: one is a bounded interval closed under the semiring operation, the other an unbounded submonoid.

### 10.4 The methodological moral

The pattern generalises well beyond divisor search. Whenever a heuristic accelerates a search, one may ask which of two things happened: the heuristic *learned* something about this instance, or it *exploited* something true of every instance. The two are indistinguishable from the timing data alone — both look like the answer arriving sooner — and they are cleanly separated by a single control: recompute the filter's kept set with the instance withheld. If the table is unchanged, the advantage is structural, bounded by the problem's symmetries, and worth exactly its constant. If the table moves, the advantage is informational, and the cap applies. The paired-difference-of-zero observed in Section 9 is exactly this control firing.

---

## 11. Future directions

### 11.1 The loaded cap law

**Conjecture.** Charge the dial its own evaluation cost $\kappa$ per candidate. Then the loaded speedup $1/(\kappa + 1 - s + s\theta)$ obeys the strictly smaller exchangeable cap $1/(\kappa + 3/4)$, and there is a critical overhead $\kappa^\ast = 1/2$ beyond which even the deterministic parity dial ($s=1$, $\theta=1/2$) falls below $1$.

The key insight is that the experiment's loaded arms reading below $1$ are not noise but the deterministic image of a single one-parameter cost identity. The unloaded law being a completed square, the loaded statement changes only the constant term and should yield to the same argument.

### 11.2 A Mertens ceiling for blind structural sieving

**Conjecture.** Along primorials, $\log\bigl(M/\varphi(M)\bigr) = \log\log M + \gamma + o(1)$, so the tropical weight of any information-free dial applicable in time $T$ is at most $\log\log T + O(1)$.

The key insight is that tropical (additive) accounting turns the Euler product into a partial sum of $1/p$, and Mertens' theorem is exactly the growth law of that sum. With multiplicativity of the wheel speedup and additivity of the tropical weight already available, the reduction is essentially complete; what remains is importing the analytic estimate. The payoff would be a *second* barrier, complementary to the first: unbiased dials are capped at $4/3$ absolutely, and structural dials are capped at $\log\log$ of the available time. Together these would bound the total achievable filtering advantage of any dial pipeline.

### 11.3 Further questions

- **Partial soundness.** The dichotomy of Section 7 is stated for priors that are either uniform or fully supported in the kept set. What is the right statement for intermediate priors, and does the escape margin interpolate as $s - \theta$ measured against the prior's overlap with $K$?
- **Optimal stacking under load.** Given per-dial overheads $\kappa_i$ and structural weights $w_i$, which subset of wheels maximises the loaded speedup? The tropical framing suggests a knapsack in log-coordinates with an additive penalty.
- **Adaptive dials.** The model assumes a single filtering stage. A multi-stage adaptive dial, whose later stages depend on earlier failures, is not exchangeable even if each stage is; whether the $4/3$ cap survives adaptivity, or degrades to a bound depending on stage count, is open.
- **Other structural families.** Beyond wheels, which congruence families give sound blind exclusions with computable retention? Theorem 5.7 supplies one (the leg-divisible-by-$3$ congruence); a systematic classification of sound blind dials for a given search problem would make the "structural budget" of a problem an intrinsic invariant.

---

## 12. Conclusion

We have proved a complete cost-theoretic account of candidate filtering in trial-division search. In the model $\mathrm{cost}(s,\theta) = 1-s+s\theta$:

- exchangeable dials are capped at $4/3$, attained exactly at half-retention;
- the cap breaks exactly when $s(1-\theta) > 1/4$, with quantified escape cost $s-\theta > (1-2\theta)^2/(4(1-\theta))$;
- deterministic dials achieve $1/\theta$, unbounded;
- the Berggren triple tree's revealed residue table is the fixed set $\{(1,0,1),(3,0,1)\}$ mod $4$, hence carries exactly zero bits — the absolute information floor;
- yet the dial it induces reads $2 > 4/3$, because the divisors of an odd number are already odd: the escape is created by the prior, not by information;
- and this structural regime is unbounded, by the divergence of $\sum 1/p$, with log-speedups composing tropically while the exchangeable regime stays confined to $[0,\log\tfrac43]$.

The barrier stands, with its scope now delimited: **it bounds dials carrying no bias toward the answer; blind structural exclusions escape it for free, carrying zero bits and worth exactly their constant factor, and nothing more.**
