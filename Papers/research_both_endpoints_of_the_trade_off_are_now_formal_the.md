# The Cost–Reliability Trade-off for Windowed Min-Plus Decoders

**Author:** Aristotle

**Date:** 2026-08-18

---

## Abstract

We give a complete two-sided analysis of the trade-off between computational cost
and failure probability for windowed min-plus (tropical) decoders on a chain. The
analysis separates cleanly into an algebraic half and a probabilistic half, and a
principal contribution of this work is to prove that the separation is *necessary*.

On the algebraic side we study the min-plus action $(A \otimes v)_a = \min_b(A_{ab} + v_b)$
of a transfer matrix on cost-to-go vectors, measured in the **span seminorm**
$\mathrm{sp}(v) = \max_a v_a - \min_a v_a$, which is exactly the projective quantity
a min-plus decoder can perceive. We prove that a tropically stochastic step is
nonexpansive for $\mathrm{sp}$, and that *any* step — with no hypothesis whatsoever —
satisfies the **tropical Dobrushin bound** $\mathrm{sp}(A \otimes v) \le \Delta(A)$,
where $\Delta(A) = \max_{a,a',b}(A_{ab} - A_{a'b})$ is the matrix diameter and the
bound is uniform in $v$. Chaining these yields an **absorption theorem**: after a
window of $k$ steps the span is at most $\min_{j<k}\Delta(A^{(i+j)})$ — a *single*
informative step anywhere in the window suffices. We then prove that this is the
end of the algebraic road: there is a two-state chain of diameter $d$ on which the
span equals $d$ exactly, after every number of steps, so **no bound of the form
$\mathrm{sp} \le \rho^k \mathrm{sp}(v)$ with $\rho < 1$ can hold**. We call this the
tropical noise floor.

On the probabilistic side we model informativeness as a Bernoulli($p$) product
measure on environments $\omega \in \{0,1\}^n$ and compute the failure probability
of the window-$b$ decoder — the event that some window of $b$ consecutive steps is
entirely uninformative — obtaining the two-sided estimate
$$\tfrac{1}{2}\lfloor n/b\rfloor (1-p)^b \;\le\; \Pr[\mathrm{fail}] \;\le\; (n+1-b)(1-p)^b$$
(the lower bound under the mild condition $\lfloor n/b\rfloor(1-p)^b \le 1$, via a
second-order Bonferroni inequality applied to the $\lfloor n/b\rfloor$ pairwise
disjoint windows).

Joining the halves, a robustness theorem shows that a windowed decision with margin
$2\theta$ is *exactly* optimal for every longer horizon whenever the window contains
a step of diameter at most $\theta$. With cost $C(b) = nbq^2$, we obtain the
trade-off invariant
$$\log\frac{1}{\Pr[\mathrm{fail}]}\cdot nq^2 \;\le\; C(b)\cdot \log\frac{1}{1-p},$$
a converse forcing $b \ge \log(1/\varepsilon)/\log\frac{1}{1-p}$ for $\varepsilon$-reliability,
and a matching achievability threshold $b \ge (\log n + \log(1/\varepsilon))/\log\frac{1}{1-p}$.
The sharpened Bonferroni converse narrows the residual gap between necessary and
sufficient window length to an additive $\log(2b)/\log\frac{1}{1-p}$.

**Keywords:** tropical semiring, min-plus algebra, span seminorm, Dobrushin
coefficient, Viterbi decoding, dynamic programming, Bonferroni inequalities,
reliability exponent.

---

## 1. Introduction

### 1.1 The problem

Sequential decoding is the problem of inferring a hidden state trajectory from a
noisy observation sequence. In its dynamic-programming formulation, one maintains a
*cost-to-go* vector $v \in \mathbb{R}^S$ over a finite state set $S$ and propagates
it backwards through a sequence of transfer matrices $A^{(0)}, A^{(1)}, \dots$ by the
min-plus rule
$$(A \otimes v)_a \;=\; \min_{b \in S}\bigl(A_{ab} + v_b\bigr).$$
This is matrix–vector multiplication in the **tropical semiring**
$(\mathbb{R}, \min, +)$, in which $\min$ is addition and $+$ is multiplication.
The Viterbi algorithm, Dijkstra-type shortest-path recursions, sequence alignment
under affine gap costs, and optimal control on finite horizons are all instances.

An *exact* decoder at position $i$ uses the full remaining horizon. A **window-$b$
decoder** truncates: it propagates only $b$ steps, from an arbitrary terminal guess,
and decides. The trade-off is immediate and universal. Truncation is cheap and
low-latency but may err; the full horizon is exact but expensive. Practitioners call
$b$ the *traceback depth* and choose it by simulation. The purpose of this paper is
to replace that simulation with theorems.

### 1.2 What we prove

We establish:

1. **Nonexpansiveness and contraction.** In the span seminorm, a tropically
   stochastic min-plus step is nonexpansive; and *every* min-plus step, stochastic or
   not, compresses the span below the matrix diameter $\Delta(A)$, uniformly in the
   input. This is the tropical analogue of Dobrushin's ergodic coefficient.

2. **Absorption.** After a window of $k$ steps, the span is bounded by the diameter
   of *any single* matrix inside the window, hence by their minimum. Forgetting is a
   one-step, threshold phenomenon.

3. **The tropical noise floor.** A two-state example in which the span equals the
   diameter exactly, at every window length. No geometric contraction estimate
   exists. This is an obstruction theorem: the exponential reliability of long
   windows *cannot* be produced by tropical algebra.

4. **The Bernoulli environment.** Exact cylinder probabilities, independence of
   disjoint windows, a union upper bound and a Bonferroni lower bound on the
   failure probability, matching to within a factor $\approx 2b$.

5. **The correctness bridge.** Robustness of margins under span perturbation, and
   hence exact agreement of the window-$b$ decoder with every longer-horizon
   decoder on every good environment.

6. **The two-sided trade-off.** Linear cost, exponential reliability, matching
   converse, and a single closing invariant.

### 1.3 Related ideas

The span seminorm is the tropical counterpart of the Hilbert projective metric,
under which classical positive operators contract (Birkhoff's theorem). The
diameter $\Delta(A)$ plays the role of the Dobrushin ergodic coefficient of a
stochastic matrix. The reader who expects, on the strength of these analogies, a
geometric contraction rate should read §5 carefully: the analogy is exact for one
step and false for many. This failure is not a defect of our estimates; it is a
structural feature of idempotent (max-plus / min-plus) analysis, where the additive
structure is *idempotent* ($\min(x,x) = x$) and averaging — the mechanism behind
classical geometric mixing — does not exist.

---

## 2. Tropical preliminaries

Throughout, $S$ is a finite nonempty set of states, $q = |S|$, and all vectors and
matrices have real entries.

### 2.1 Tropical sums, the span seminorm

**Definition 2.1 (Tropical sum and maximum).** For $f : S \to \mathbb{R}$, write
$$\mathrm{tmin}(f) = \min_{s\in S} f(s), \qquad \mathrm{tmax}(f) = \max_{s\in S} f(s).$$
Both exist since $S$ is finite and nonempty. $\mathrm{tmin}$ is the tropical sum;
$\mathrm{tmax}$ is auxiliary, used only to define the span.

**Definition 2.2 (Span seminorm).** For $v : S \to \mathbb{R}$,
$$\mathrm{sp}(v) \;=\; \mathrm{tmax}(v) - \mathrm{tmin}(v) \;=\; \max_a v_a - \min_a v_a .$$

**Proposition 2.3.** $\mathrm{sp}$ is a seminorm-like functional with the following
properties, for all $v$ and $c \in \mathbb{R}$:

  (i) $\mathrm{sp}(v) \ge 0$;
  (ii) $\mathrm{sp}(v + c\mathbf{1}) = \mathrm{sp}(v)$ (*projective invariance*);
  (iii) $v_a - v_b \le \mathrm{sp}(v)$ for all $a, b \in S$.

*Proof.* (i) Pick any $s$; then $\min v \le v_s \le \max v$. (ii) Adding a constant
shifts both the max and the min by $c$, since $\max(v + c\mathbf 1) = \max v + c$
(one inequality by termwise bounding, the other by evaluating at an argmax), and
symmetrically for the min. (iii) $v_a \le \max v$ and $\min v \le v_b$. $\square$

Property (ii) is the reason the span is the correct notion of size here: the
decision rule of a min-plus decoder is $\arg\min_a(u_a + v_a)$, which is unchanged
when $v$ is shifted by a constant. The decoder perceives $v$ only as a point of the
quotient $\mathbb{R}^S / \mathbb{R}\mathbf 1$, and $\mathrm{sp}$ is a genuine norm
on that quotient.

### 2.2 Transfer matrices, stochasticity, diameter

**Definition 2.4 (Min-plus action and product).** For $A, B : S \times S \to \mathbb{R}$
and $v : S \to \mathbb{R}$,
$$(A \otimes v)_a = \min_b (A_{ab} + v_b), \qquad
(A \otimes B)_{ac} = \min_b (A_{ab} + B_{bc}).$$

**Definition 2.5 (Tropical stochasticity).** $A$ is **tropically stochastic** if
every row has tropical sum $0$: $\min_b A_{ab} = 0$ for all $a$.

Every matrix can be made tropically stochastic by subtracting from each row its own
minimum. This operation changes $(A\otimes v)$ by an additive row-dependent shift and
therefore alters neither the argmin structure nor any decoder decision; it is pure
normalization. Note that stochasticity forces $A_{ab} \ge 0$ for all $a, b$.

**Definition 2.6 (Diameter / tropical Dobrushin coefficient).**
$$\Delta(A) \;=\; \max_{a, a', b}\bigl(A_{ab} - A_{a'b}\bigr).$$

Immediately $\Delta(A) \ge 0$ (take $a = a'$), and $\Delta(A) = 0$ if and only if all
rows of $A$ are equal. The interpretation: $\Delta(A)$ measures how much two source
states can disagree about the cost of reaching the same destination. Small $\Delta$
means the step is *informative* (the past is nearly irrelevant to the future cost);
large $\Delta$ means it is *uninformative*.

**Proposition 2.7 (Basic bounds).** If $A$ is tropically stochastic then for all $v$
and all $a$,
$$\mathrm{tmin}(v) \;\le\; (A\otimes v)_a \;\le\; \mathrm{tmax}(v).$$

*Proof.* Lower: $A_{ab} + v_b \ge 0 + \mathrm{tmin}(v)$ for every $b$, so the minimum
over $b$ is at least $\mathrm{tmin}(v)$. Upper: choose $b_0$ with $A_{ab_0} = 0$
(stochasticity); then $(A\otimes v)_a \le A_{ab_0} + v_{b_0} = v_{b_0} \le \mathrm{tmax}(v)$. $\square$

---

## 3. Contraction theory in the span seminorm

### 3.1 Nonexpansiveness

**Theorem 3.1 (Nonexpansiveness).** *If $A$ is tropically stochastic then for every
$v$,*
$$\mathrm{sp}(A \otimes v) \;\le\; \mathrm{sp}(v).$$

*Proof.* By Proposition 2.7, every entry of $A\otimes v$ lies in
$[\mathrm{tmin}(v), \mathrm{tmax}(v)]$, so $\mathrm{tmax}(A\otimes v) \le \mathrm{tmax}(v)$
and $\mathrm{tmin}(A \otimes v) \ge \mathrm{tmin}(v)$; subtract. $\square$

### 3.2 The tropical Dobrushin bound

**Theorem 3.2 (Uniform contraction to the diameter).** *For every matrix $A$ — no
hypothesis at all — and every $v$,*
$$\mathrm{sp}(A \otimes v) \;\le\; \Delta(A).$$

*Proof.* Let $a$ be a state minimizing $(A\otimes v)_a$, and let $b$ attain
$(A\otimes v)_a = A_{ab} + v_b$. For an arbitrary $a'$, the minimum defining
$(A\otimes v)_{a'}$ is at most the value at the same $b$:
$$(A\otimes v)_{a'} \;\le\; A_{a'b} + v_b \;=\; (A_{a'b} - A_{ab}) + (A\otimes v)_a
\;\le\; \Delta(A) + (A \otimes v)_a .$$
Taking the maximum over $a'$ gives $\mathrm{tmax}(A\otimes v) \le \Delta(A) + \mathrm{tmin}(A\otimes v)$. $\square$

The essential point is that $v$ does not appear on the right. One min-plus step
"forgets" its input down to the level $\Delta(A)$, no matter how large the input span
was. This is the exact analogue of the classical statement that the total-variation
distance between two distributions after one Markov step is at most the Dobrushin
coefficient of the kernel, uniformly in the initial pair.

### 3.3 Algebraic structure

**Theorem 3.3 (Associativity).** *For all $A, B, v$:*
$$(A \otimes B) \otimes v \;=\; A \otimes (B \otimes v).$$

*Proof.* Both sides are $\min_{b,c}(A_{ab} + B_{bc} + v_c)$ at coordinate $a$; formally
one proves two inequalities. For "$\ge$": fix $b$, choose $c$ attaining
$\min_c(B_{bc} + v_c)$; then the left side is at most $(A\otimes B)_{ac} + v_c \le A_{ab} + B_{bc} + v_c
= A_{ab} + (B\otimes v)_b$, and taking the min over $b$ gives the claim. For "$\le$":
fix $c$, choose $b$ attaining $(A\otimes B)_{ac} = \min_b(A_{ab} + B_{bc})$, and bound
$A\otimes(B\otimes v)$ by the value at that $b$ and then at $c$. $\square$

**Theorem 3.4 (Monoid of stochastic matrices).** *If $A$ and $B$ are tropically
stochastic then so is $A \otimes B$.*

*Proof.* Nonnegativity of entries gives $\min_c (A\otimes B)_{ac} \ge 0$. For the
reverse, pick $b_0$ with $A_{ab_0} = 0$ and $c_0$ with $B_{b_0c_0} = 0$; then
$(A\otimes B)_{ac_0} \le A_{ab_0} + B_{b_0c_0} = 0$. $\square$

**Theorem 3.5 (Monotonicity of the diameter under composition).** *For all $A, B$,*
$$\Delta(A \otimes B) \le \Delta(A);$$
*and if $A$ is tropically stochastic,* $\Delta(A\otimes B) \le \Delta(B)$, *hence*
$$\Delta(A \otimes B) \;\le\; \min\bigl(\Delta(A), \Delta(B)\bigr).$$

*Proof.* Observe that the $c$-th column of $A\otimes B$ is precisely $A \otimes (B_{\bullet c})$,
the min-plus image of the $c$-th column of $B$. Any row difference in the product is
bounded by the span of the corresponding column, so
$\Delta(A\otimes B) \le \max_c \mathrm{sp}\bigl((A\otimes B)_{\bullet c}\bigr)$.
For the first claim apply Theorem 3.2 to that column; for the second apply Theorem 3.1
and then the elementary fact that the span of a column of $B$ is at most $\Delta(B)$
(the span of column $c$ is $B_{ac} - B_{a'c}$ for suitable $a, a'$). $\square$

Composition, in other words, can only improve mixing — but, as we will see, it cannot
improve it *repeatedly*.

### 3.4 Absolute stability

The span controls decisions; the sup norm controls numerics. Both are stable.

**Theorem 3.6 ($1$-Lipschitz in the sup norm).** *For every $A$, all $v, w$, and all $a$,*
$$\bigl|(A\otimes v)_a - (A\otimes w)_a\bigr| \;\le\; \max_{s}|v_s - w_s|.$$

*Proof.* Set $M = \max_s|v_s - w_s|$. Then $v \le w + M\mathbf 1$ pointwise; the min-plus
action is monotone (a pointwise inequality between vectors is preserved) and commutes
with adding a constant, $A \otimes (w + M\mathbf 1) = (A\otimes w) + M\mathbf 1$. Hence
$A\otimes v \le A\otimes w + M\mathbf 1$, and symmetrically. $\square$

---

## 4. Windows and the absorption theorem

**Definition 4.1 (Windowed propagation).** Given a chain of transfer matrices
$A^{(0)}, A^{(1)}, \dots$, define $W_{i,k} : \mathbb{R}^S \to \mathbb{R}^S$ by
$$W_{i,0}(v) = v, \qquad W_{i,k+1}(v) = A^{(i)} \otimes W_{i+1,k}(v).$$
Thus $W_{i,k}(v)$ propagates a terminal guess $v$ backwards through the $k$ matrices
$A^{(i)}, \dots, A^{(i+k-1)}$. It is the cost-to-go vector of the horizon-$k$ decoder
at stage $i$.

**Lemma 4.2 (Window composition).** $W_{i, j+r}(v) = W_{i,j}\bigl(W_{i+j, r}(v)\bigr)$.

*Proof.* Induction on $j$, using the recursion and the index shift $i + (j+1) = (i+1) + j$. $\square$

**Theorem 4.3 (Window nonexpansiveness).** *If every $A^{(i)}$ is tropically stochastic,
then $\mathrm{sp}(W_{i,k}(v)) \le \mathrm{sp}(v)$ for all $i, k, v$.*

*Proof.* Induction on $k$ using Theorem 3.1. $\square$

**Theorem 4.4 (Absorption).** *Assume every $A^{(i)}$ is tropically stochastic. Then
for every $j < k$ and every $v$,*
$$\mathrm{sp}\bigl(W_{i,k}(v)\bigr) \;\le\; \Delta\bigl(A^{(i+j)}\bigr),$$
*and consequently*
$$\mathrm{sp}\bigl(W_{i,k}(v)\bigr) \;\le\; \min_{0 \le j < k}\Delta\bigl(A^{(i+j)}\bigr).$$

*Proof.* Write $k = j + (m+1)$. By Lemma 4.2,
$$W_{i,k}(v) = W_{i,j}\Bigl( A^{(i+j)} \otimes W_{i+j+1, m}(v)\Bigr).$$
By Theorem 4.3 the outer $j$ steps do not increase the span, so
$\mathrm{sp}(W_{i,k}(v)) \le \mathrm{sp}\bigl(A^{(i+j)} \otimes W_{i+j+1,m}(v)\bigr)$,
and by Theorem 3.2 the latter is at most $\Delta(A^{(i+j)})$ — uniformly in whatever
the inner propagation produced. $\square$

Theorem 4.4 is the structural heart of the algebraic half. It says that memory loss in
min-plus dynamics is **not** an accumulation of small effects but a **threshold event**:
one informative step anywhere in the window caps the span, and the surrounding steps
neither help nor hurt. Nothing in the statement improves as $k$ grows, except through
the min over a larger index set.

---

## 5. The tropical noise floor: an obstruction theorem

Given Theorems 3.1, 3.2 and 4.4, the natural conjecture is a geometric estimate
$$\mathrm{sp}\bigl(W_{i,k}(v)\bigr) \;\le\; \rho^{k}\,\mathrm{sp}(v), \qquad \rho < 1,$$
in analogy with Birkhoff–Hopf contraction for positive linear operators and with
geometric ergodicity of Markov chains. We show that no such estimate exists, even for
a fixed, symmetric, tropically stochastic matrix of bounded diameter.

**Definition 5.1.** For $d \ge 0$ let $T_d$ be the two-state matrix on $S = \{0,1\}$
with $ (T_d)_{ab} = 0$ if $a = b$ and $d$ otherwise.

**Lemma 5.2.** $T_d$ is tropically stochastic and $\Delta(T_d) = d$.

*Proof.* Each row is $(0,d)$ or $(d,0)$, so has minimum $0$. Row differences take the
values $0, \pm d$, whose maximum is $d$ since $d \ge 0$. $\square$

**Lemma 5.3 (A fixed point).** $T_d \otimes (0, d) = (0, d)$.

*Proof.* Coordinate $0$: $\min(0 + 0,\ d + d) = 0$ since $d \ge 0$. Coordinate $1$:
$\min(d + 0,\ 0 + d) = d$. $\square$

**Theorem 5.4 (Tropical noise floor).** *For the constant chain $A^{(i)} = T_d$, every
$k \ge 0$ and every $i$,*
$$\mathrm{sp}\bigl(W_{i,k}(0,d)\bigr) \;=\; d \;=\; \Delta(T_d).$$

*Proof.* By Lemma 5.3 and induction on $k$, $W_{i,k}(0,d) = (0,d)$ for all $i,k$; its
span is $d - 0 = d$. $\square$

**Corollary 5.5 (No geometric contraction).** There is no $\rho < 1$ and no constant
$C$ such that $\mathrm{sp}(W_{i,k}(v)) \le C\rho^k\,\mathrm{sp}(v)$ holds for all
tropically stochastic chains, all $v$, and all $k$. Indeed the absorption bound of
Theorem 4.4 is attained *with equality* at every window length on the chain of
Definition 5.1.

**Discussion.** Why does the classical intuition fail? Geometric mixing in the
classical setting is driven by *averaging*: a convex combination of two distinct values
lies strictly between them, so repeated combination shrinks differences at a definite
rate. In the tropical semiring the additive operation is $\min$, which is *idempotent*:
$\min(x,x) = x$, and more importantly $\min$ of a family equals one of its members. A
min-plus step is a *selection*, not a blend. It can discard information wholesale (that
is Theorem 3.2), but it can never partially erode a difference that no single step
removes. Symmetric ambiguity — the state of affairs modelled by $T_d$ with $v = (0,d)$ —
is a fixed point of selection dynamics and survives forever.

The consequence for our problem is decisive: **the exponential improvement in
reliability obtained from a longer decoding window cannot be an algebraic phenomenon.**
The algebra supplies exactly one thing, absorption, and the exponential must come from
the *statistics* of the diameters $\Delta(A^{(i)})$ along the chain. That is the subject
of the next section.

---

## 6. The Bernoulli environment

### 6.1 Environments and cylinder probabilities

**Definition 6.1 (Environment).** An **environment** of length $n$ is a map
$\omega : \{0,\dots,n-1\} \to \{\texttt{true}, \texttt{false}\}$. We read
$\omega_i = \texttt{true}$ as "step $i$ is *informative*" and $\omega_i = \texttt{false}$
as "step $i$ is *uninformative*". Given a threshold $\theta$ and a chain $A$, the
**induced environment** is $\omega_i = [\Delta(A^{(i)}) \le \theta]$.

**Definition 6.2 (Bernoulli weight).** For $p \in [0,1]$ define
$$w_p(\omega) = \prod_{i=0}^{n-1}\bigl(p\,[\omega_i] + (1-p)\,[\lnot \omega_i]\bigr),
\qquad \Pr_p[E] = \sum_{\omega \in E} w_p(\omega)$$
for any set $E$ of environments.

**Proposition 6.3 (Normalization).** $\Pr_p[\text{all environments}] = 1$; the weights
are nonnegative for $p \in [0,1]$; $\Pr_p$ is monotone under inclusion; and
$\Pr_p[E^c] = 1 - \Pr_p[E]$.

*Proof.* Expanding the product over coordinates and distributing the sum over all
environments gives $\prod_{i}\bigl(p + (1-p)\bigr) = 1$. The remaining claims are
immediate from nonnegativity of the weights. $\square$

**Definition 6.4 (Cylinder).** For a set $W$ of positions, let $\mathcal{B}(W)$ be the
event that every position in $W$ is uninformative:
$\mathcal{B}(W) = \{\omega : \omega_x = \texttt{false} \text{ for all } x\in W\}$.

**Theorem 6.5 (Exact cylinder probability).** $\Pr_p[\mathcal{B}(W)] = (1-p)^{|W|}$.

*Proof.* Distributing the product over coordinates, the sum over $\mathcal{B}(W)$
factorizes into $\prod_{x \in W}(1-p) \cdot \prod_{x \notin W} \bigl(p + (1-p)\bigr)
= (1-p)^{|W|}$. $\square$

**Proposition 6.6 (Cylinders are closed under intersection).**
$\mathcal{B}(W_1) \cap \mathcal{B}(W_2) = \mathcal{B}(W_1 \cup W_2)$, hence
$$\Pr_p\bigl[\mathcal{B}(W_1) \cap \mathcal{B}(W_2)\bigr] = (1-p)^{|W_1 \cup W_2|}.$$
In particular, for disjoint $W_1, W_2$ this equals $(1-p)^{|W_1|}(1-p)^{|W_2|}$: disjoint
coordinate blocks are independent.

### 6.2 The failure event

**Definition 6.7 (Uninformative window and the failure event).** For $0 \le i$ and
$b \ge 1$ let $\mathrm{Win}(i,b) = \{x : i \le x < i+b\} \cap \{0,\dots,n-1\}$ and
$\mathcal{W}_{i,b} = \mathcal{B}(\mathrm{Win}(i,b))$ — the event that the whole window
starting at $i$ is uninformative. The **failure event** of the window-$b$ decoder is
$$\mathcal{F}_{n,b} \;=\; \bigcup_{i=0}^{n-b} \mathcal{W}_{i,b}.$$

If $i + b \le n$ then $|\mathrm{Win}(i,b)| = b$ and $\Pr_p[\mathcal{W}_{i,b}] = (1-p)^b$
exactly.

**Theorem 6.8 (Union upper bound).** *For $0 \le p \le 1$ and $b \le n$,*
$$\Pr_p\bigl[\mathcal{F}_{n,b}\bigr] \;\le\; (n+1-b)\,(1-p)^b .$$

*Proof.* Subadditivity of $\Pr_p$ over a union of finitely many events (immediate from
nonnegativity of the weights) plus Theorem 6.5 for each of the $n+1-b$ windows. $\square$

**Theorem 6.9 (Elementary lower bound).** *For $0 \le p \le 1$ and $b \le n$,*
$$(1-p)^b \;\le\; \Pr_p\bigl[\mathcal{F}_{n,b}\bigr].$$

*Proof.* The single window $\mathcal{W}_{0,b}$ is contained in $\mathcal{F}_{n,b}$ and
has probability exactly $(1-p)^b$. $\square$

**Endpoints.** Specializing $b = 1$ gives $\Pr_p[\mathcal{F}_{n,1}] \le n(1-p)$ — the
symbol-by-symbol decoder, whose error probability is only linearly small. Specializing
$b = n$ gives $\Pr_p[\mathcal{F}_{n,n}] \le (1-p)^n$ — the full-block decoder, whose
error probability is exponentially small in the block length. Theorem 6.8 is the exact
interpolation between them.

### 6.3 Closing the polynomial gap: a Bonferroni lower bound

Theorems 6.8 and 6.9 differ by the polynomial factor $n+1-b$, and it is that factor
alone which separates the converse of §8 from the achievability result of §9. It can be
largely removed, because the $\lfloor n/b\rfloor$ windows starting at $0, b, 2b, \dots$
are *pairwise disjoint*, hence genuinely independent by Proposition 6.6.

**Theorem 6.10 (Second Bonferroni inequality).** *For any finite family
$E_0,\dots,E_{m-1}$ of events,*
$$\sum_{i<m}\Pr_p[E_i] \;-\; \sum_{i<m}\sum_{j<i}\Pr_p[E_j \cap E_i]
\;\le\; \Pr_p\Bigl[\bigcup_{i<m}E_i\Bigr].$$

*Proof.* Induction on $m$. The case $m=0$ is trivial. For the step, write
$U = \bigcup_{i<m}E_i$ and use inclusion–exclusion for two events,
$\Pr[E_m \cup U] + \Pr[E_m \cap U] = \Pr[E_m] + \Pr[U]$, together with the subadditive
bound $\Pr[E_m \cap U] = \Pr\bigl[\bigcup_{j<m}(E_j\cap E_m)\bigr] \le \sum_{j<m}\Pr[E_j\cap E_m]$
and the inductive hypothesis for $\Pr[U]$. $\square$

**Theorem 6.11 (Bonferroni lower bound for the failure probability).** *Let $m$ satisfy
$mb \le n$. Then*
$$m(1-p)^b - \frac{m(m-1)}{2}(1-p)^{2b} \;\le\; \Pr_p\bigl[\mathcal{F}_{n,b}\bigr].$$

*Proof.* Apply Theorem 6.10 to $E_t = \mathcal{W}_{tb,\,b}$ for $t < m$. Each has
probability exactly $(1-p)^b$ (Theorem 6.5, since $tb + b \le mb \le n$). For $j < i$
the windows starting at $jb$ and $ib$ are disjoint, so by Proposition 6.6 the pairwise
intersection has probability exactly $(1-p)^{2b}$; there are $\binom{m}{2}$ such pairs.
Finally $\bigcup_{t<m}E_t \subseteq \mathcal{F}_{n,b}$ and $\Pr_p$ is monotone. $\square$

**Corollary 6.12 (Half of the first-order term survives).** *If $mb \le n$ and
$m(1-p)^b \le 1$ then*
$$\frac{m}{2}(1-p)^b \;\le\; \Pr_p\bigl[\mathcal{F}_{n,b}\bigr].$$

*Proof.* With $x = (1-p)^b \ge 0$, the subtracted term satisfies
$\frac{m(m-1)}{2}x^2 \le \frac{m}{2}\cdot(mx)\cdot x \le \frac m2 x$ using $mx \le 1$;
substitute into Theorem 6.11. $\square$

**Corollary 6.13 (Linearity in $n/b$).** *Taking $m = \lfloor n/b\rfloor$, whenever
$\lfloor n/b\rfloor (1-p)^b \le 1$,*
$$\frac{\lfloor n/b\rfloor}{2}(1-p)^b \;\le\; \Pr_p\bigl[\mathcal{F}_{n,b}\bigr]
\;\le\; (n+1-b)(1-p)^b .$$

The upper and lower bounds now differ by a factor of at most $\approx 2b$, down from
$\approx n$.

---

## 7. The correctness bridge: from span to decisions

We now connect the algebra of §3–§5 to the probability of §6 through the decision rule.

**Definition 7.1 (Decision and margin).** Given a local cost $u : S \to \mathbb{R}$ and
a cost-to-go vector $V$, a state $a_0$ **is a decision** if
$u_{a_0} + V_{a_0} \le u_a + V_a$ for all $a$. It **wins by margin $m$** if
$u_{a_0} + V_{a_0} + m \le u_a + V_a$ for all $a \ne a_0$.

**Theorem 7.2 (Robustness of margins).** *Let $\theta \ge 0$, let $V$ and $W$ satisfy
$\mathrm{sp}(V) \le \theta$ and $\mathrm{sp}(W) \le \theta$, and suppose $a_0$ wins by
margin $2\theta$ with respect to $W$. Then $a_0$ is a decision with respect to $V$.*

*Proof.* Let $a \ne a_0$. By Proposition 2.3(iii), $V_{a_0} - V_a \le \theta$ and
$W_a - W_{a_0} \le \theta$. The margin hypothesis gives
$u_{a_0} + W_{a_0} + 2\theta \le u_a + W_a$. Adding the two span inequalities,
$$u_{a_0} + V_{a_0} \le u_{a_0} + V_a + \theta
\le u_a + W_a - W_{a_0} - 2\theta + V_a + \theta \le u_a + V_a. \qquad\square$$

In words: a min-plus decoder that wins by twice the span cannot be misled by *any*
replacement of its cost-to-go vector by another of comparable span. This is the precise
sense in which the decoder is only sensitive to the projective data.

**Theorem 7.3 (Locality / lossless truncation).** *Assume every $A^{(i)}$ is tropically
stochastic. Suppose the window $[i, i+b)$ contains an informative step: there is $j < b$
with $\Delta(A^{(i+j)}) \le \theta$. Suppose further that the window-$b$ decision $a_0$
computed from an arbitrary terminal guess $w$ wins by margin $2\theta$ against
$W_{i,b}(w)$. Then for every $r \ge 0$ and every terminal guess $v$, $a_0$ is also a
decision for the horizon-$(b+r)$ cost-to-go vector $W_{i,b+r}(v)$.*

*Proof.* By Theorem 4.4 applied twice — once to the window of length $b$ and once to the
window of length $b + r$, both of which contain index $j$ — both $W_{i,b}(w)$ and
$W_{i,b+r}(v)$ have span at most $\Delta(A^{(i+j)}) \le \theta$. Apply Theorem 7.2. $\square$

Note the strength: the conclusion holds for *all* $r$, including $r$ large enough to
reach the end of the chain. Truncation is not an approximation on a good window; the
windowed decision is *exactly* the exact decoder's decision.

**Theorem 7.4 (Correctness on good environments).** *Assume every $A^{(i)}$ is
tropically stochastic and let $\omega$ be the environment induced by $A$ at threshold
$\theta$. If $\omega \notin \mathcal{F}_{n,b}$ then for every admissible position $i$
(that is, $i + b \le n$) the conclusion of Theorem 7.3 holds.*

*Proof.* If $\omega \notin \mathcal{F}_{n,b}$ then in particular $\omega \notin \mathcal{W}_{i,b}$,
i.e. the window starting at $i$ is not entirely uninformative, so some $j < b$ has
$\omega_{i+j} = \texttt{true}$, i.e. $\Delta(A^{(i+j)}) \le \theta$. Apply Theorem 7.3. $\square$

**Corollary 7.5 (Probabilistic guarantee).** *For $0 \le p \le 1$ and $b \le n$, the set
of environments on which the window-$b$ decoder is lossless at every admissible position
has probability at least*
$$1 - (n+1-b)(1-p)^b .$$

*Proof.* Combine Theorem 7.4 with Theorem 6.8 and $\Pr_p[E^c] = 1 - \Pr_p[E]$. $\square$

---

## 8. The cost model and the converse

**Definition 8.1 (Cost).** One min-plus matrix–vector product on $q = |S|$ states costs
$q^2$ scalar operations. The horizon-$k$ recursion therefore costs $H(k) = kq^2$
(by induction on the same recursion that defines $W_{i,k}$), and running the window-$b$
decoder at each of $n$ positions costs
$$C(b) \;=\; n\,H(b) \;=\; n\,b\,q^2 .$$

**Proposition 8.2 (Endpoints and interpolation).**
  (i) $C(1) = nq^2$ (symbol-by-symbol decoding);
  (ii) $C(n) = n^2q^2$ (full-block decoding);
  (iii) $C(b) = b\,C(1)$, so the cost is exactly linear in the window;
  (iv) for $1 \le b \le n$, $C(1) \le C(b) \le C(n)$;
  (v) $C$ is strictly increasing in $b$ whenever $q, n \ge 1$.

Combined with Theorem 6.8, the picture is: cost grows *linearly* in $b$ while failure
probability decays *exponentially* in $b$. The question is whether this exchange rate
is optimal. It is.

**Theorem 8.3 (Converse: reliability exponent).** *Let $0 \le p < 1$ and $b \le n$. Then*
$$\log\frac{1}{\Pr_p[\mathcal{F}_{n,b}]} \;\le\; b \,\log\frac{1}{1-p}.$$

*Proof.* By Theorem 6.9, $\Pr_p[\mathcal{F}_{n,b}] \ge (1-p)^b > 0$. Taking logarithms
(monotone) gives $b\log(1-p) \le \log \Pr_p[\mathcal{F}_{n,b}]$, and negating both sides
gives the claim. $\square$

**Theorem 8.4 (Window lower bound).** *Let $0 < p < 1$, $b \le n$, and suppose the
window-$b$ decoder achieves $\Pr_p[\mathcal{F}_{n,b}] \le \varepsilon$. Then*
$$b \;\ge\; \frac{\log(1/\varepsilon)}{\log\frac{1}{1-p}}.$$

*Proof.* From $(1-p)^b \le \Pr_p[\mathcal{F}_{n,b}] \le \varepsilon$, take logs:
$b\log(1-p) \le \log\varepsilon$, i.e. $b\log\frac{1}{1-p} \ge \log\frac1\varepsilon$;
divide by the positive quantity $\log\frac{1}{1-p}$. $\square$

**Theorem 8.5 (Cost lower bound).** *Under the hypotheses of Theorem 8.4,*
$$n q^2 \cdot \frac{\log(1/\varepsilon)}{\log\frac{1}{1-p}} \;\le\; C(b).$$

*Proof.* Multiply the conclusion of Theorem 8.4 by the nonnegative quantity $nq^2$ and
use $C(b) = nq^2 b$. $\square$

Thus the cost of $\varepsilon$-reliable windowed decoding is $\Theta(\log(1/\varepsilon))$:
each additional decimal digit of reliability costs a fixed additive increment
$nq^2 \log 10 / \log\frac{1}{1-p}$ of computation, and no cleverness in choosing the
window can beat this.

**Theorem 8.6 (Trade-off invariant).** *For $0 \le p < 1$ and $b \le n$,*
$$\log\frac{1}{\Pr_p[\mathcal{F}_{n,b}]}\cdot \bigl(nq^2\bigr)
\;\le\; C(b)\cdot \log\frac{1}{1-p}.$$

*Proof.* Multiply Theorem 8.3 by $nq^2 \ge 0$ and substitute $C(b) = nq^2 b$. $\square$

This single inequality is the whole trade-off: *reliability exponent times per-position
budget never exceeds total cost times the per-step informativeness rate.* Reading it as
an exchange rate, one unit of computation buys at most $\log\frac{1}{1-p}/(nq^2)$ nats
of reliability exponent.

---

## 9. Achievability, and how tight the sandwich is

**Theorem 9.1 (Simplified interpolation).** *For $0\le p\le 1$ and $1 \le b \le n$,*
$$\Pr_p[\mathcal{F}_{n,b}] \;\le\; n(1-p)^b .$$

*Proof.* $n + 1 - b \le n$ for $b \ge 1$, and $(1-p)^b \ge 0$. $\square$

**Theorem 9.2 (Achievability).** *Let $0 < p < 1$, $\varepsilon > 0$, $1 \le b \le n$. If*
$$b \;\ge\; \frac{\log n + \log(1/\varepsilon)}{\log\frac{1}{1-p}}$$
*then $\Pr_p[\mathcal{F}_{n,b}] \le \varepsilon$.*

*Proof.* Multiplying through by $\log\frac{1}{1-p} > 0$, the hypothesis reads
$\log n + \log\frac1\varepsilon \le b\log\frac{1}{1-p}$, i.e.
$\log n + b\log(1-p) \le \log\varepsilon$, i.e. $\log\bigl(n(1-p)^b\bigr)\le \log\varepsilon$.
Exponentiating and applying Theorem 9.1 gives the claim. $\square$

**Corollary 9.3 (The sandwich).** Let $b^\star(\varepsilon)$ be the least window length
achieving failure probability $\varepsilon$. Then
$$\frac{\log(1/\varepsilon)}{\log\frac{1}{1-p}} \;\le\; b^\star(\varepsilon)
\;\le\; \Bigl\lceil \frac{\log n + \log(1/\varepsilon)}{\log\frac{1}{1-p}}\Bigr\rceil .$$
The two thresholds differ by an additive $\log n / \log\frac{1}{1-p}$.

**Theorem 9.4 (Sharpened converse).** *Let $0\le p<1$, let $m = \lfloor n/b\rfloor \ge 1$
and suppose $m(1-p)^b \le 1$ and $\Pr_p[\mathcal{F}_{n,b}] \le \varepsilon$. Then*
$$\log\frac{m}{2\varepsilon} \;\le\; b\,\log\frac{1}{1-p}.$$

*Proof.* By Corollary 6.13, $\frac m2 (1-p)^b \le \varepsilon$, hence
$\frac{m}{2\varepsilon} \le (1-p)^{-b}$; take logarithms. $\square$

With $m = \lfloor n/b\rfloor$, Theorem 9.4 forces
$b \ge \bigl(\log n - \log(2b) + \log(1/\varepsilon)\bigr)/\log\frac{1}{1-p}$,
which is within an additive $\log(2b)/\log\frac{1}{1-p}$ of the achievability threshold
of Theorem 9.2. Since $b$ is itself logarithmic in $1/\varepsilon$, the residual gap is
doubly logarithmic in the target reliability: the optimal window length is determined
essentially exactly.

---

## 10. Algorithms

**Algorithm A (Windowed min-plus decoding).** Given a chain $A^{(0)},\dots,A^{(n-1)}$
of $q\times q$ matrices, local costs $u^{(0)},\dots,u^{(n-1)}$, a window $b$ and a
terminal guess $w$:

  for $i = 0$ to $n-b$: set $v \leftarrow w$; for $t = i+b-1$ down to $i$ set
  $v \leftarrow A^{(t)} \otimes v$; output $\hat a_i = \arg\min_a (u^{(i)}_a + v_a)$.

Cost: $n b q^2$ scalar operations, exactly $C(b)$ of Definition 8.1. A sliding
implementation that reuses the overlap between consecutive windows reduces this to
$O(nq^2)$ amortized when the terminal guess is held fixed, at the price of a
different (and weaker) correctness guarantee; the bound $C(b)$ is the honest cost of
the memoryless windowed decoder analysed here.

**Algorithm B (Certified-window decoding).** Instead of fixing $b$ in advance, extend
the window until it certifies its own answer: at position $i$, grow $b$ until either
$\mathrm{sp}(W_{i,b}(w)) \le \theta$ and the current decision wins by $2\theta$ — in
which case, by Theorem 7.3, the decision is *provably* the exact decoder's decision and
one may stop — or a budget is exhausted. The expected cost of this adaptive scheme is
governed by the expected waiting time $1/p$ for the first informative step, giving
expected window length $O(1/p)$ rather than the worst-case $O(\log(n/\varepsilon))$.

**Algorithm C (Exact failure probability by transfer matrix).** The event
$\mathcal{F}_{n,b}$ is recognizable by a $(b+1)$-state automaton tracking the length of
the current run of uninformative steps (saturating at $b$, which is absorbing). Its
probability is therefore computable in $O(nb)$ time by propagating a length-$(b+1)$
distribution, avoiding the $2^n$ enumeration. This is the tool that turns the
inequalities of §6 into exact numbers for any given $(n,b,p)$.

**Algorithm D (Optimal window selection).** Given $n$, $q$, $p$ and a target
$\varepsilon$, return the least $b$ with $\Pr_p[\mathcal{F}_{n,b}] \le \varepsilon$
(computed by Algorithm C), together with the certified cost $C(b) = nbq^2$ and the
certified bracket of Corollary 9.3. Complexity $O(n b_{\max}\log b_{\max})$ with binary
search over $b$ (the failure probability is monotone decreasing in $b$).

---

## 11. Discussion

### 11.1 A clean division of labour

The results above split the analysis of windowed min-plus decoding into two
non-overlapping halves whose interface is a single combinatorial predicate:

  *"the window contains at least one step of diameter $\le \theta$."*

Everything to the left of that predicate is deterministic tropical algebra
(Theorems 3.1–4.4, 7.2–7.3); everything to the right is elementary probability on the
Bernoulli cube (Theorems 6.5–6.13). The noise floor (Theorem 5.4) is the proof that
the interface cannot be moved: no amount of additional algebra will produce a bound
decaying in $b$, because a decaying bound is *false* for the chain $T_d$.

This is worth emphasizing because the temptation to look for a purely algebraic
explanation of long-window reliability is strong — the classical analogies (Birkhoff
contraction, Dobrushin coefficients, geometric ergodicity) all point that way. In the
tropical world the analogy holds for exactly one step.

### 11.2 Idempotency and the absence of averaging

The deep reason is structural. Classical contraction arguments rest on averaging: a
convex combination of two values lies strictly inside their interval, and iterating
convex combinations shrinks intervals geometrically. Min-plus addition is idempotent
and *selective*: $\min$ returns one of its arguments. A min-plus operator can therefore
truncate a spread wholesale — that is exactly the content of the uniform bound
$\mathrm{sp}(A\otimes v)\le \Delta(A)$ — but it cannot shave a spread that no single
operator removes. The dynamics live in a world of records and thresholds. Records do not
compound.

Seen this way, Theorem 4.4 is not a weak version of geometric contraction but a
*different* and in some respects stronger statement: it is uniform in $v$, requires no
smallness, and gives the exact answer after one good step. Its weakness — no improvement
with $k$ — is intrinsic.

### 11.3 Practical reading

For an engineer choosing a traceback depth, the results say:

* The correct notion of "how informative is step $i$" is the row diameter
  $\Delta(A^{(i)}) = \max_{a,a',b}(A_{ab}^{(i)} - A^{(i)}_{a'b})$, computable in $O(q^2)$
  per step; it is *not* the size of the entries.
* A window is good as soon as it contains one step with $\Delta \le \theta$, where
  $\theta$ is half the decision margin one is willing to require. Waiting for more
  informative steps is wasted computation.
* If informative steps arrive at rate $p$, the failure probability of window $b$ over a
  chain of length $n$ is $\Theta\bigl((n/b)(1-p)^b\bigr)$, so
  $b \approx \bigl(\log n + \log(1/\varepsilon)\bigr)/\log\frac{1}{1-p}$ and the total
  cost is $nq^2 b$.
* An adaptive decoder (Algorithm B) that stops at the first certified window pays
  $O(1/p)$ steps in expectation rather than $O(\log(n/\varepsilon))$ in the worst case —
  a real saving whenever $p$ is not tiny — at the price of variable latency.

### 11.4 Scope and limitations

Three assumptions deserve scrutiny.

*Independence.* Real channels have bursty noise; informativeness is correlated across
steps. The union bound of Theorem 6.8 survives correlation unchanged (it only needs the
marginals), but the Bonferroni lower bound of Theorem 6.11 uses independence of disjoint
windows essentially. Under a mixing assumption on the environment one expects the same
qualitative conclusion with a modified exponent.

*The threshold model.* We reduce the real number $\Delta(A^{(i)})$ to a bit
$[\Delta(A^{(i)})\le\theta]$. A finer analysis would keep the distribution of
$\Delta(A^{(i)})$ and replace "one good step" by a quantitative statement about
$\min_{j<b}\Delta(A^{(i+j)})$ — the minimum of $b$ i.i.d. random variables, whose
distribution near its lower endpoint drives everything.

*The margin.* Theorem 7.3 requires the decision to win by $2\theta$. Positions with
small margin are genuinely ambiguous and no window length repairs them; the failure
probability computed here is the probability of *window inadequacy*, not of *intrinsic
ambiguity*. A complete error analysis would add a term for the latter, which depends on
the source and channel rather than on $b$.

---

## 12. Future directions

**Conjecture 1 (Sharp constant).** The union-bound factor $n+1-b$ should be replaceable
by $(n-b+1)p$ asymptotically, with
$$\frac{(n-b+1)p(1-p)^b}{1 + (n-b+1)p(1-p)^b} \;\le\; \Pr_p[\mathcal{F}_{n,b}]
\;\le\; (n-b+1)p(1-p)^b + (1-p)^b .$$
Numerically, the ratio of the exact failure probability to the union bound converges to
$p$ as $b$ grows; at $p = 3/4$, $n = 10$, $b = 8$ it is already $0.7999\ldots$. The key
insight is that overlapping bad windows can be replaced by *first-occurrence* windows:
the failure event decomposes as a disjoint union over the position of the leftmost
maximal uninformative run, whose left boundary must carry an informative step, and this
boundary condition contributes exactly the extra factor $p$. The exact cylinder
probabilities of Theorem 6.5 and the window-size count are precisely what a
first-occurrence decomposition needs; only the disjointness bookkeeping is missing.

**Conjecture 2′ (Exact asymptotics and Gumbel fluctuations).**
$$\Pr_p[\mathcal{F}_{n,b}] = (1+o(1))\,(n-b+1)\,p\,(1-p)^b$$
uniformly for $b \ge (1+\delta)\log n / \log\frac{1}{1-p}$, and the correct
normalization of the *maximal* uninformative run is a Gumbel limit. The key insight is
that the failure event is a *renewal* event: conditioning on the leftmost uninformative
run turns the union over overlapping windows into a genuine disjoint decomposition, and
the renewal kernel produces both the factor $p$ and the Gumbel fluctuations. The exact
probabilities for arbitrary cylinders and for disjoint window pairs (Theorem 6.5,
Proposition 6.6) are the ingredients. The second-order Bonferroni bound
(Theorem 6.11) already establishes the *linear in $n/b$* behaviour; what remains open is
the exact constant and the limiting distribution.

Beyond these two, four further directions seem fruitful.

*(a) Correlated environments.* Replace the Bernoulli product measure by a Markov
environment and identify the correct exponent, which should be the decay rate of the
runs-of-bad-steps generating function rather than $\log\frac{1}{1-p}$.

*(b) Continuous diameters.* Keep $\Delta(A^{(i)})$ as a real random variable and study
$\min_{j<b}\Delta(A^{(i+j)})$ directly; extreme-value theory should replace the Bernoulli
count, with the small-value behaviour of the diameter distribution determining the
reliability exponent.

*(c) Adaptive window certificates.* Analyse Algorithm B and prove the $O(1/p)$
expected-cost bound, together with a concentration statement for the total cost over $n$
positions.

*(d) Beyond chains.* The absorption theorem uses only nonexpansiveness and the uniform
diameter bound; both hold for min-plus operators on trees and on general acyclic graphs.
The combinatorics of "which windows can fail" becomes the combinatorics of cutsets, and
the union/Bonferroni analysis should generalize with $n+1-b$ replaced by a cutset count.

---

## 13. Conclusion

We have given a complete two-sided account of the cost–reliability trade-off for
windowed min-plus decoders. Cost is exactly linear in the window length,
$C(b) = nbq^2$; failure probability is exponential in it,
$\Theta\bigl((n/b)(1-p)^b\bigr)$; and the two are locked together by the invariant
$$\log\frac{1}{\Pr[\mathrm{fail}]}\cdot nq^2 \;\le\; C(b)\cdot\log\frac{1}{1-p}.$$
The mechanism is a strict division of labour: tropical algebra contributes the
*absorption theorem* — one informative step anywhere in the window caps the span of the
cost-to-go vector, and hence certifies the windowed decision against every longer
horizon — while independence contributes the exponential decay of the probability that
no such step exists. The tropical noise floor shows this division is forced: on a
symmetric two-state chain the span never decays at all, so no purely algebraic argument
can ever produce a bound improving with the window length. What looks like exponential
forgetting in a min-plus decoder is not forgetting; it is the exponentially rare event
that nothing worth remembering ever arrived.
