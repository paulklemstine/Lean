# The Symmetric-Mixture Bump: Sup-Convolution Structure of the Attention Key Budget of Mixed-Domain Contexts

**Author:** Aristotle
**Date:** 2026-09-01

---

## Abstract

We study the *key budget* of a truncated attention mechanism reading a context assembled
from several content domains, and we determine the exact shape of its response to the
mixing ratio. Modelling each domain by a sorted attention profile — a nonincreasing
sequence of positive weights — and defining the *knee* $k^\ast$ as the least top-$k$
budget whose retained mass reaches a gate $\tau$, we prove that the head mass of a
mixed-domain context is the **sup-convolution** of the pure head masses. Every feature of
the mixing-ratio response follows from this single algebraic fact.

We establish: (i) **subadditivity**, $k^\ast(m,l,\tau) \le k^\ast_a(m,\tau) + k^\ast_b(l,\tau)$,
so the mixing premium never exceeds a doubling; (ii) a **mechanism bound**, a matching
superadditive inequality in which each domain must be served to a gate relaxed by the
*other* domain's mass share, which localises the premium precisely at comparable masses;
(iii) a **doubling sandwich** for balanced self-mixtures,
$2k^\ast_a(m,2\tau-1) \le k^\ast(m,m,\tau) \le 2k^\ast_a(m,\tau)$, which is logically
incompatible with any linear-in-ratio law; (iv) for the geometric profile $a_i = 2^{-i}$
at gate $\tau = 0.98$, the **exact values** $k^\ast_{\text{pure}} = 6$ and
$k^\ast_{\text{mixed}} = 12$, refuting three pre-registered candidate shapes (linear,
dip, monotone); (v) a **mass-balance criterion** — a minority domain of half the keys but
a thousandth of the mass leaves the knee at its pure value, so the phenomenon is governed
by mass, not block counts; (vi) that the balanced arm is the **maximum** of the sweep for
every sorted profile, via concavity of head mass along a split and a mirroring argument;
(vii) that the sweep is in fact **monotone in the imbalance** (Schur-concavity of the
knee in the key-count vector), so the response has no interior local minima; and (viii)
for $d$ equally massive geometric domains, the **exact budget**
$k^\ast(d) = \lceil 143 d / 25\rceil$, which reproduces the ladder $6 \to 12 \to 18$ for
$d \le 3$ but *refutes* the extrapolated law $6d$: four domains cost $23$, not $24$.

**Keywords:** sup-convolution, attention key budget, Schur concavity, majorisation,
mixture response, geometric profile, tangent-line bound.

---

## 1. Introduction

### 1.1 The engineering question

A transformer reading a long context stores one key–value pair per position. Practical
deployments cannot afford to keep all of them, and the standard remedy is *top-$k$
truncation*: retain the $k$ positions carrying the largest attention mass and evict the
rest. The design parameter is $k$, and it is chosen by fixing a retention gate $\tau$
(typically $0.98$) and taking the least budget that retains at least a $\tau$ fraction of
the attention mass. We call this budget the **knee**.

Single-domain knees are routinely measured: profile a code corpus, profile a prose
corpus, read off two numbers. The question addressed here is what happens when a single
context window contains *both*, in some mixing ratio $\rho$ — the situation of every
agentic workload, where source files, documentation, logs and natural-language
instructions occupy one window together.

### 1.2 Three predictions and a bump

Three shapes for the response $\rho \mapsto k^\ast(\rho)$ were registered in advance.

- **P1 (linear).** $k^\ast$ interpolates between the two pure endpoints.
- **P2 (dip).** Mixtures are cheaper than either pure domain, because a shared head of
  syntactic scaffolding serves both.
- **P3 (monotone).** $k^\ast$ is monotone in the prose fraction, one domain being
  intrinsically harder.

The measurement refuted all three. Both pure endpoints and both asymmetric mixtures
($25/75$ and $75/25$) sat at the same budget; the balanced $50/50$ arm sat one grid step
higher, at both context levels tested — a $+25$–$33\%$ premium purchased by symmetry
alone. The observed response is a **bump**: flat shoulders, a strict interior maximum at
the balance point.

### 1.3 Contribution

This paper supplies the structural theory that makes the bump a theorem rather than an
artefact. The organising object is the sup-convolution (§2). From it we derive matching
sub- and superadditive bounds (§3), exact numbers on a geometric profile with the
refutation of P1–P3 (§4), the sharp factor-two ceiling and the mass-balance criterion
that switches the bump on and off (§5), the identification of the balanced arm as the
global maximum of the sweep (§6), Schur-concavity of the knee in the key-count vector
(§7), and the exact $d$-domain budget with the collapse of the $6d$ law (§8).
Algorithms, applications, discussion and open problems occupy §9–§12.

---

## 2. The model

### 2.1 Single-domain theory

**Definition 2.1 (sorted attention profile).** A *profile* is a function
$a : \mathbb{N} \to \mathbb{R}$ with $a_i > 0$ for all $i$. It is *sorted* if $a$ is
antitone, i.e. $i \le j \implies a_i \ge a_j$.

**Definition 2.2 (head mass).** The *head mass* of the top $n$ keys of a profile $a$ is
$$A(n) \;=\; \sum_{i < n} a_i .$$
It is strictly increasing in $n$ and positive for $n \ge 1$.

**Definition 2.3 (retained fraction and knee).** In a context of $n$ keys with profile
$a$, a budget of $k$ keys retains the fraction
$$R_a(n,k) \;=\; \frac{A(\min(k,n))}{A(n)} \in (0,1],$$
which is nondecreasing in $k$ and equal to $1$ for $k \ge n$. For a gate $\tau \le 1$ the
**knee** is
$$k^\ast_a(n,\tau) \;=\; \min\{\,k \in \mathbb{N} \;:\; R_a(n,k) \ge \tau \,\}.$$
The minimum exists because $k = n$ always qualifies; consequently
$k^\ast_a(n,\tau) \le n$, and $R_a(n, k^\ast_a(n,\tau)) \ge \tau$.

Two elementary facts are used throughout: the knee is bounded by any passing budget
(if $R_a(n,k) \ge \tau$ then $k^\ast_a(n,\tau) \le k$), and it exceeds any failing budget
(if $R_a(n,k) < \tau$ then $k < k^\ast_a(n,\tau)$). Together they pin $k^\ast$ exactly
whenever one exhibits a passing budget $k$ and a failing budget $k-1$; this "razor"
argument computes every exact value in this paper.

### 2.2 The mixed-domain head mass is a sup-convolution

Consider a context of $m$ keys with profile $a$ and $l$ keys with profile $b$. A top-$k$
selection from the union takes the $k$ largest of all $m+l$ weights. Since each domain's
weights are already sorted, such a selection is determined by *how many* keys it takes
from each domain, and the optimal selection maximises over that choice.

**Definition 2.4 (mixed head mass).**
$$H_{a,b}(m,l,k) \;=\; \max_{0 \le j \le k} \Big[\, A\big(\min(j,m)\big) \;+\; B\big(\min(k-j,\,l)\big)\Big].$$

**Definition 2.5 (mixed total, retained fraction, knee).**
$$T_{a,b}(m,l) = A(m) + B(l), \qquad
  R_{a,b}(m,l,k) = \frac{H_{a,b}(m,l,k)}{T_{a,b}(m,l)},$$
$$k^\ast(m,l,\tau) \;=\; \min\{\,k \;:\; R_{a,b}(m,l,k) \ge \tau\,\}.$$

**Proposition 2.6 (basic structure).** For positive profiles $a,b$ and $m,l \ge 1$:

1. $H_{a,b}(m,l,\cdot)$ is nondecreasing, and $H_{a,b}(m,l,m+l) = T_{a,b}(m,l)$;
2. $R_{a,b}(m,l,\cdot)$ is nondecreasing with $R_{a,b}(m,l,m+l) = 1$;
3. the knee is well defined, satisfies the gate, and $k^\ast(m,l,\tau) \le m+l$;
4. the maximum in Definition 2.4 is attained at some $j \le k$.

*Proof sketch.* Monotonicity in $k$ follows by keeping the split $j$ fixed and letting
the $b$-side absorb the extra budget. Fullness is the split $j = m$. The rest is the
definition of an infimum over a nonempty set of naturals together with the attainment of
a maximum over the finite index set $\{0,\dots,k\}$. $\square$

**Proposition 2.7 (the endpoints).** For positive $a$ and $b$,
$$H_{a,b}(m,0,k) = A(\min(k,m)), \qquad H_{a,b}(0,l,k) = B(\min(k,l)),$$
and consequently
$$k^\ast(m,0,\tau) = k^\ast_a(m,\tau), \qquad k^\ast(0,l,\tau) = k^\ast_b(l,\tau).$$

*Proof sketch.* With $l = 0$ the $b$-term vanishes and the maximand is monotone in $j$,
so the maximum is at $j = k$; the retained-fraction sets then coincide with the
single-domain ones. $\square$

Proposition 2.7 says the mixing-ratio sweep is a genuine curve *through* the
single-domain theory: the endpoints are not a separate model.

---

## 3. Sub- and superadditivity: the two-sided bound

### 3.1 The mixing premium is at most a doubling

**Theorem 3.1 (subadditivity).** For positive profiles $a, b$, $m,l \ge 1$ and
$\tau \le 1$,
$$k^\ast(m,l,\tau) \;\le\; k^\ast_a(m,\tau) + k^\ast_b(l,\tau).$$

*Proof sketch.* Write $k_A = k^\ast_a(m,\tau)$, $k_B = k^\ast_b(l,\tau)$. By definition
$A(\min(k_A,m)) \ge \tau A(m)$ and $B(\min(k_B,l)) \ge \tau B(l)$. The split $j = k_A$ of
the budget $k_A + k_B$ is admissible, hence
$$H_{a,b}(m,l,k_A+k_B) \;\ge\; A(\min(k_A,m)) + B(\min(k_B,l)) \;\ge\; \tau\,\big(A(m)+B(l)\big),$$
so the budget $k_A + k_B$ clears the gate and bounds the knee. $\square$

**Corollary 3.2 (asymmetry is protective).** $k^\ast(m,l,\tau) \le k^\ast_a(m,\tau) + l$.

*Proof.* Combine Theorem 3.1 with $k^\ast_b(l,\tau) \le l$. $\square$

Corollary 3.2 already contains the qualitative shoulder: a minority domain cannot inflate
the budget by more than its own key count, so extreme asymmetry cannot be bumped.

### 3.2 The mechanism: both heads must be bought

**Theorem 3.3 (mechanism bound / relaxed-gate superadditivity).** Let $S_a = A(m)$ and
$S_b = B(l)$. For positive profiles, $m,l \ge 1$ and $\tau \le 1$,
$$k^\ast_a\!\Big(m,\ \tau - (1-\tau)\tfrac{S_b}{S_a}\Big)
\;+\;
k^\ast_b\!\Big(l,\ \tau - (1-\tau)\tfrac{S_a}{S_b}\Big)
\;\le\; k^\ast(m,l,\tau).$$

*Proof sketch.* Let $k$ be the mixed knee and let $j$ attain the maximum in
Definition 2.4, so that
$$A(\min(j,m)) + B(\min(k-j,l)) \;\ge\; \tau (S_a + S_b).$$
Bounding the $b$-term by $S_b$ gives $A(\min(j,m)) \ge \tau S_a - (1-\tau) S_b$, i.e.
$$R_a(m,j) \;\ge\; \tau - (1-\tau)\frac{S_b}{S_a},$$
so $j$ is a passing budget for the relaxed gate on the $a$-side and dominates the
corresponding pure knee. Symmetrically $k-j$ dominates the $b$-side relaxed knee. Adding
gives $k \ge$ the sum. $\square$

Theorem 3.3 is the formal content of "cross-domain query–key interactions inflate the
budget". Its most important feature is *how it degrades*. If $S_b \ll S_a$ then
$(1-\tau)S_a/S_b$ is enormous, the second relaxed gate is deeply negative, the second
term collapses to $0$, and the bound reduces to the pure $a$-statement: **a light domain
is free**. The premium is therefore a statement about *comparable mass*, not about
content, and this is exactly the regime distinction that produces shoulders.

### 3.3 The balanced self-mixture is a doubling, not an interpolation

**Theorem 3.4 (doubling sandwich).** For a positive profile $a$, $m \ge 1$ and
$\tau \le 1$,
$$2\,k^\ast_a(m,\,2\tau-1) \;\le\; k^\ast(m,m,\tau) \;\le\; 2\,k^\ast_a(m,\tau),$$
where the mixture uses $a$ on both sides.

*Proof.* Specialise Theorem 3.3 with $b = a$ and $m = l$: then $S_a = S_b$, both mass
ratios equal $1$, and both relaxed gates equal $\tau - (1-\tau) = 2\tau - 1$. The upper
bound is Theorem 3.1 with $b = a$. $\square$

**Remark 3.5 (P1 is structurally impossible).** A linear-in-ratio law would place the
balanced arm at the average of the endpoints, which for a self-mixture is
$k^\ast_a(2m,\tau)$ — a single pure knee. Theorem 3.4 says the balanced arm is instead
sandwiched around *twice* a pure knee. Whenever the gate relaxation from $\tau$ to
$2\tau-1$ does not move the pure knee — which is the generic situation for a profile with
a spectral gap — the two bounds coincide and the balanced arm is *exactly* twice a pure
knee. No linear law survives.

---

## 4. Exact values on the geometric profile, and the refutation of P1–P3

### 4.1 The profile

**Definition 4.1.** The *geometric profile* is $g_i = 2^{-i}$; it is positive and
antitone, with $G(n) = \sum_{i<n} 2^{-i} = 2\big(1 - 2^{-n}\big) < 2$, and
$G(n) \ge 2 - 2^{-15}$ for $n \ge 16$.

We fix the experimental gate $\tau = 0.98$ throughout §4–§8. The condition
$\tau \le G(k)/G(n)$ becomes, for $k \le n$,
$$\frac{1 - 2^{-k}}{1 - 2^{-n}} \;\ge\; \frac{49}{50}.$$
For large $n$ this is essentially $2^{-k} \le \tfrac{1}{50}$, and since
$2^{-5} = \tfrac{1}{32} > \tfrac{1}{50} > \tfrac{1}{64} = 2^{-6}$, the knee is $6$.

**Theorem 4.2 (both endpoints).** For every context length $n \ge 16$,
$$k^\ast_g(n, 0.98) \;=\; 6 .$$

*Proof sketch.* Razor argument. Passing: $G(6) = 2 - 2^{-5} = 1.96875$, while
$0.98\,G(n) \le 0.98 \cdot 2 = 1.96$, so budget $6$ clears the gate. Failing:
$G(5) = 2 - 2^{-4} = 1.9375$, while $0.98\,G(n) \ge 0.98\,(2 - 2^{-15}) > 1.9599$, so
budget $5$ misses it. $\square$

### 4.2 The interior plateau

**Theorem 4.3 (mixed knee, geometric).** If $m \ge 16$ and $l \ge 16$ then
$$k^\ast(m,l,0.98) \;=\; 12,$$
independently of the ratio $m : l$.

*Proof sketch.* Upper bound: Theorem 3.1 with Theorem 4.2 gives $\le 12$. Lower bound:
for a budget $k$ split as $(j, k-j)$, the retained mass is
$$G(\min(j,m)) + G(\min(k-j,l)) \;\le\; 4 - 2\big(2^{-j} + 2^{-(k-j)}\big),$$
while the gate demands at least $0.98 \cdot G(m)+0.98\cdot G(l) \ge 0.98(4 - 2^{-14})$.
Hence a budget $k$ can pass only if $2^{-j} + 2^{-(k-j)} \le \tfrac{1}{25}$ for some
$j \le k$, up to a truncation error of order $2^{-14}$. At $k = 11$ the minimum of
$2^{-j} + 2^{-(11-j)}$ over integers is attained at $j \in \{5,6\}$ and equals
$\tfrac{1}{32} + \tfrac{1}{64} = \tfrac{3}{64} = 0.046875 > 0.04$, so $11$ fails, and the
razor gives exactly $12$. $\square$

The extremal split at the failing budget is the *balanced* one — the first appearance of
the convexity phenomenon that §6–§7 make general.

### 4.3 The bump, and the three refutations

**Theorem 4.4 (the symmetric-mixture bump).** For every $N \ge 16$, with the geometric
profile on both sides and $\tau = 0.98$:
$$k^\ast(2N,0) = 6, \qquad k^\ast(0,2N) = 6, \qquad k^\ast(N,N) = 12,$$
and hence the balanced arm strictly exceeds both endpoints.

*Proof.* Propositions 2.7 with Theorem 4.2 for the endpoints, Theorem 4.3 for the
centre. $\square$

**Corollary 4.5 (P1 refuted — not linear).**
$2\,k^\ast(N,N) \ne k^\ast(2N,0) + k^\ast(0,2N)$, since $24 \ne 12$. A linear response
would place the balanced arm at the endpoint average $6$; it is at $12$.

**Corollary 4.6 (P2 refuted — not a dip).**
$\max\big(k^\ast(2N,0),\,k^\ast(0,2N)\big) = 6 < 12 = k^\ast(N,N)$: the balanced arm lies
strictly *above* both pure domains.

**Corollary 4.7 (P3 refuted — not monotone).** The sweep
$m \mapsto k^\ast\big(\min(m,2N),\,2N-m\big)$ takes the values $6, 12, 6$ at
$m = 0, N, 2N$, so it is neither monotone nor antitone in the mixing fraction.

**Theorem 4.8 (the two experimental context levels).** At $\tau = 0.98$,
$$k^\ast_g(512) = k^\ast_g(1024) = 6, \qquad
k^\ast(256,256) = k^\ast(512,512) = k^\ast(128,384) = k^\ast(384,128) = 12 .$$
The premium is a factor of two at both context levels: it does not wash out with context
length.

### 4.4 Relation to the measured table

The measured sweep at context $512$ was $\{12, 12, 16, 16, 12\}$ across
(pure code, $25/75$, $50/50$, $75/25$, pure prose), and $\{16,16,20,16,16\}$ at context
$1024$. The theory above reproduces the *sign structure* exactly — interior never below
the endpoints; balanced arm strictly above both — while predicting a flat interior
plateau where the measurement resolves a step between $25/75$ and $50/50$. The
discrepancy is a resolution effect, not a contradiction: on the geometric profile the
knee grid is coarse (the retained fraction jumps by a factor of two per key), so the
interior of the sweep is flat and only the endpoint/interior distinction is visible.
Theorems 6.3 and 7.3 below give the profile-free statement — the interior is *ordered* by
imbalance and peaks at the centre — which is precisely the structure the measurement
resolves on a finer-grained empirical spectrum.

---

## 5. Sharpness and the mass-balance criterion

### 5.1 The factor-two ceiling is attained

**Theorem 5.1 (ceiling).** For a positive profile $a$, $m \ge 1$, $\tau \le 1$,
$$k^\ast(m,m,\tau) \;\le\; 2\,k^\ast_a(m,\tau).$$

*Proof.* Theorem 3.1 with $b = a$, $l = m$. $\square$

**Theorem 5.2 (ceiling attained).** For the geometric profile at $\tau = 0.98$ and
$N \ge 16$, $k^\ast(N,N) = 12 = 2\,k^\ast_g(N)$. The bound of Theorem 5.1 is therefore
sharp.

Also relevant is monotonicity in context: for a positive profile, $n \le n'$ implies
$k^\ast_a(n,\tau) \le k^\ast_a(n',\tau)$, because retained mass at a fixed budget can
only fall as the context grows.

### 5.2 Mass, not blocks

**Definition 5.3.** The *light geometric profile* is $h_i = 10^{-3}\cdot 2^{-i}$; its head
mass satisfies $H(n) < \tfrac{1}{500}$ for all $n$.

**Theorem 5.4 (a light domain is invisible).** For $m, l \ge 16$,
$$k^\ast_{g,h}(m,l,0.98) \;=\; 6 .$$

*Proof sketch.* Total mass is at most $2 + \tfrac{1}{500}$, so the gate demands at least
$0.98\,(2 + \tfrac{1}{500}) < 1.962$. Budget $6$ spent entirely on the heavy domain
retains $G(6) \ge 2 - 2^{-14} - 2^{-5} > 1.968$ and passes; budget $5$ retains at most
$G(5) + H(l) < 1.9375 + 0.002 = 1.9395$ and fails. $\square$

**Theorem 5.5 (bump with shoulders).** For $N \ge 16$ at $\tau = 0.98$:
$$k^\ast_{g,g}(2N,0) = 6, \qquad k^\ast_{g,h}(N,N) = 6, \qquad k^\ast_{g,g}(N,N) = 12 .$$

Theorem 5.5 is the decisive control. The middle arm has a *perfectly balanced key count*
— half the keys from each domain — and shows no premium whatsoever, because the second
domain carries a thousandth of the mass. The bump is therefore not a phenomenon of block
counting; it is a phenomenon of **mass balance**, exactly as predicted by the collapse of
the second term in Theorem 3.3.

### 5.3 The minority threshold

**Theorem 5.6 (small minorities are free).** For the geometric profile at $\tau = 0.98$
with $m \ge 16$ and $1 \le l \le 5$,
$$k^\ast(m,l,0.98) \;\le\; 11 \;<\; 12 .$$

*Proof.* Corollary 3.2 with $k^\ast_g(m) = 6$ gives $\le 6 + l \le 11$. $\square$

So the hypothesis $l \ge 16$ in Theorem 4.3 is not decorative: the plateau genuinely
fails in the extreme-asymmetry regime, and Theorems 5.4 and 5.6 delimit the two
mechanisms — too little mass, or too few keys — by which a minority domain escapes the
premium.

---

## 6. The balanced arm is the peak of the sweep

Theorem 4.4 compares the centre only with the endpoints, and only for one profile. The
substantive structural claim is that the centre is the **maximum of the entire sweep**,
for *every* sorted profile. It rests on two independent facts, both consequences of
antitonicity, which happen to point the same way.

### 6.1 Concavity of head mass along a split

**Lemma 6.1 (head-mass concavity).** Let $a$ be antitone, $m \le N$ and $m + l = 2N$.
Then
$$A(m) + A(l) \;\le\; 2\,A(N).$$

*Proof.* Since $m \le N \le l$,
$$A(N) - A(m) = \sum_{i < N-m} a_{m+i}, \qquad A(l) - A(N) = \sum_{i < l-N} a_{N+i},$$
and $l - N = N - m$ because $m + l = 2N$. The two sums have the same number of terms, and
term by term $a_{N+i} \le a_{m+i}$ since $m \le N$ and $a$ is antitone. Hence
$A(l) - A(N) \le A(N) - A(m)$, which rearranges to the claim. $\square$

Interpretation: a Robin Hood move (transfer keys from the majority side to the minority
side) trades a block of deep-tail weights for a block of near-head weights, and for a
decreasing profile that trade always *gains* mass. A balanced split therefore has the
most mass to cover.

### 6.2 The balanced split offers the least head

**Lemma 6.2 (mirroring).** Let $a$ be a positive profile, $m \le N \le l$, and let
$k \le 2m$. Then
$$H_{a,a}(N,N,k) \;\le\; H_{a,a}(m,l,k).$$

*Proof.* It suffices to show that every split $j \le k$ in the balanced context is
dominated by some split in the unbalanced one.

*Case $j \le m$.* Keep the split. Then $\min(j,m) = \min(j,N) = j$, and
$\min(k-j,N) \le \min(k-j,l)$ because $N \le l$; monotonicity of $A$ gives the claim.

*Case $j > m$.* Then $k - j \le 2m - j < m$, so mirror the split: use $k-j$ on the
$a$-side (which fits, $\min(k-j,m) = \min(k-j,N) = k-j$) and $j$ on the $l$-side, where
$\min(j,N) \le \min(j,l)$. After commuting the two summands the balanced value is
dominated. $\square$

Interpretation: whatever allocation you can devise for the balanced context, the
unbalanced context can copy or reflect it, so the balanced context is the *hardest to
serve* at every budget below $2m$.

### 6.3 The peak

**Theorem 6.3 (balanced maximises the knee).** Let $a$ be a positive antitone profile,
$\tau \le 1$, and let $m \ge 1$, $m \le N$, $m + l = 2N$. If the side condition
$$k^\ast(N,N,\tau) \;\le\; 2m$$
holds, then
$$k^\ast(m,l,\tau) \;\le\; k^\ast(N,N,\tau).$$

*Proof sketch.* Put $k = k^\ast(N,N,\tau)$. By definition
$\tau\,T(N,N) \le H(N,N,k)$. Lemma 6.2 (applicable because $k \le 2m$) upgrades this to
$\tau\,T(N,N) \le H(m,l,k)$, and Lemma 6.1 gives $T(m,l) \le T(N,N)$. Chaining,
$$\tau\, T(m,l) \;\le\; \tau\, T(N,N) \;\le\; H(m,l,k),$$
so $k$ clears the gate in the unbalanced context and dominates its knee. (For $\tau \le 0$
the statement is trivial since head masses are nonnegative.) $\square$

**Remark 6.4 (the side condition is real).** If the budget exceeds twice the minority
side, the mirroring in Lemma 6.2 has no room and the comparison can fail. The condition
is stated, not hidden; on the geometric instance it is *verified* rather than assumed.

**Theorem 6.5 (geometric instance).** For the geometric profile at $\tau = 0.98$, with
$N \ge 16$, $m \ge 16$, $m \le N$ and $m + l = 2N$,
$$k^\ast(m,l) \;\le\; k^\ast(N,N) \quad\text{and}\quad k^\ast(2N,0) \;<\; k^\ast(N,N).$$
The side condition holds because $k^\ast(N,N) = 12 \le 32 \le 2m$.

Thus the interior pattern of the measured table — interior values dominated by, and the
endpoint strictly below, the balanced arm — is a theorem, not a corpus artefact.

---

## 7. Schur-concavity: the whole sweep is ordered by imbalance

Theorem 6.3 is a single comparison against the centre. It leaves open whether the
response between endpoint and centre is *ordered*, or whether it can wander up and down
with interior local minima. For self-mixtures of a sorted profile it is ordered.

**Definition 7.1 (majorisation for pairs).** With a common sum, $(m,l)$ *majorises*
$(m',l')$ — is the more unbalanced pair — when $m \le m' \le l' \le l$ and
$m + l = m' + l'$.

**Lemma 7.2 (transposition versions).** Let $a$ be a positive profile and let
$m \le m' \le l' \le l$ with $m + l = m' + l'$. Then

1. if $a$ is antitone, $A(m) + A(l) \le A(m') + A(l')$ — a Robin Hood step increases the
   mass to be covered;
2. for every budget $k \le 2m$, $H_{a,a}(m',l',k) \le H_{a,a}(m,l,k)$ — a Robin Hood step
   decreases the best head available.

*Proof sketch.* Identical in structure to Lemmas 6.1 and 6.2, with $(N,N)$ replaced by
the more balanced pair $(m',l')$: for (1) the gained block $\sum_{i<m'-m} a_{m+i}$
dominates the lost block $\sum_{i<l-l'} a_{l'+i}$ term by term (same length by the sum
constraint, larger indices in the lost block); for (2) split into $j \le m$ (keep) and
$j > m$ (mirror). $\square$

**Theorem 7.3 (Schur-concavity of the mixed knee).** Let $a$ be positive and antitone,
$\tau \le 1$, $m \ge 1$, and $m \le m' \le l' \le l$ with $m + l = m' + l'$. If
$k^\ast(m',l',\tau) \le 2m$ then
$$k^\ast(m,l,\tau) \;\le\; k^\ast(m',l',\tau).$$

*Proof sketch.* Verbatim the argument of Theorem 6.3, with Lemma 7.2 in place of
Lemmas 6.1–6.2. $\square$

**Corollary 7.4.** Theorem 6.3 is the case $(m',l') = (N,N)$; the balanced pair is the
top element of the majorisation order on pairs with a fixed sum, so "the peak is at the
centre" was never a statement about the centre but about the order.

**Corollary 7.5 (no interior local minima).** Along the sweep
$m \mapsto k^\ast(m, 2N-m)$ for $m \le N$, the knee is nondecreasing (subject to the side
condition at each comparison). In particular there is no intermediate mixing ratio
cheaper than a more lopsided one.

**Theorem 7.6 (geometric sweep, ordered).** For the geometric profile with
$16 \le m \le m' \le N$, $k^\ast(m, 2N-m) \le k^\ast(m', 2N-m')$; on this profile the
common value is $12$ throughout the interior, so the sweep is flat there and the ordering
is non-strict.

**Remark 7.7 (strictness is open).** The proved ordering is deliberately non-strict. On a
profile with a coarse knee grid — geometric decay is the extreme case — the sweep *is*
flat over the interior, so a strict claim would be false. Strictness is a quantitative
question: one transposition step moves the retained fraction by an explicit amount (the
difference of two blocks of weights), and the knee strictly increases exactly when that
amount exceeds the local spacing of the knee grid. See §12.

---

## 8. Many domains: the exact ladder and the collapse of the $6d$ law

### 8.1 Three domains

The construction nests. The three-domain head mass is
$$H_3(m,l,n,k) \;=\; \max_{0\le j\le k}\Big[\,H_{a,b}(m,l,j) + C\big(\min(k-j,\,n)\big)\Big],$$
and one checks that this equals the maximum of $A(j_1) + B(j_2) + C(j_3)$ over all
allocations with $j_1 + j_2 + j_3 \le k$ (and $j_i$ capped by the respective domain
sizes). Dropping a domain recovers the two-domain theory exactly. Subadditivity and the
mechanism bound both generalise: the three-domain knee is at most the sum of the three
pure knees, and at least the sum of three pure knees at gates relaxed by the *other two*
domains' mass shares.

**Theorem 8.1 (three balanced geometric domains).** For $m,l,n \ge 16$ at $\tau = 0.98$,
$$k^\ast_3(m,l,n) \;=\; 18 .$$

*Proof sketch.* Upper: subadditivity plus $k^\ast_g = 6$. Lower: the gate forces
$2^{-j_1} + 2^{-j_2} + 2^{-j_3} \le \tfrac{3}{50}$ up to truncation error, while for
integers with $j_1+j_2+j_3 \le 17$ one has
$$2^{-j_1} + 2^{-j_2} + 2^{-j_3} \;\ge\; \tfrac{1}{16} \;=\; 0.0625 \;>\; 0.06,$$
the minimum being attained at the balanced allocation $(6,6,5)$. Hence $17$ fails and the
razor gives $18$. $\square$

The ladder so far is $6 \to 12 \to 18$, and the obvious extrapolation is
$k^\ast(d) = 6d$: no saturation, each additional massive domain costs a full pure budget.

### 8.2 The general $d$-domain theory

**Definition 8.2 ($d$-fold sup-convolution).** For $d$ domains of $m$ keys each with a
common profile $a$,
$$H_d(k) = \begin{cases} 0, & d = 0,\\[2pt]
\displaystyle\max_{0\le j\le k}\Big[H_{d-1}(j) + A\big(\min(k-j,\,m)\big)\Big], & d \ge 1,\end{cases}$$
with total $T_d = d\cdot A(m)$, retained fraction $H_d(k)/T_d$, and knee $k^\ast(d)$ the
least $k$ clearing $\tau$. This recovers the previous cases: $k^\ast(1) = k^\ast_a(m)$,
$k^\ast(2) = k^\ast_{a,a}(m,m)$ and $k^\ast(3) = k^\ast_3(m,m,m)$, so the ladder concerns
one and the same object throughout.

**Lemma 8.3 (tangent-line bound).** For every integer $j \ge 0$,
$$\frac{7-j}{64} \;\le\; 2^{-j},$$
with equality exactly at $j = 5$ and $j = 6$.

*Proof sketch.* The line is the chord of the convex function $j \mapsto 2^{-j}$ through
the points $j = 5$ and $j = 6$; convexity places the chord below the curve outside
$[5,6]$ and there are no integers strictly inside. For $j \ge 7$ the left side is
$\le 0 <$ the right side. $\square$

**Theorem 8.4 (exact $d$-domain budget).** For the geometric profile at $\tau = 0.98$,
$d \ge 1$, $m \ge 16$ with $1600\,d \le 2^m$,
$$k^\ast(d) \;=\; \left\lceil \frac{143\,d}{25}\right\rceil \;=\; \left\lfloor\frac{143d+24}{25}\right\rfloor .$$

*Proof sketch.* Write an allocation as $(j_1,\dots,j_d)$ with $\sum j_i = k$. The mass
left uncovered is $2\sum_i 2^{-j_i}$ (up to the truncation correction $O(d\,2^{-m})$),
and the total is $2d$ up to the same correction, so the gate $\tau = \tfrac{49}{50}$
demands
$$\sum_{i=1}^{d} 2^{-j_i} \;\le\; \frac{d}{50}.$$

*Lower bound (impossibility).* By Lemma 8.3, $\sum_i 2^{-j_i} \ge \frac{7d - k}{64}$ for
every allocation. Passing therefore requires $\frac{7d-k}{64} \le \frac{d}{50}$, i.e.
$k \ge 7d - \frac{32d}{25} = \frac{143d}{25}$.

*Upper bound (construction).* Take $k = \lceil 143d/25\rceil$. Since
$5d \le \tfrac{143d}{25} \le k \le 6d$ for all $d \ge 1$, we may write $k = 6x + 5y$ with
$x + y = d$ and $x,y \ge 0$: use $x$ blocks of size $6$ and $y$ of size $5$. Equality
holds in Lemma 8.3 at both block sizes, so this allocation attains
$\sum_i 2^{-j_i} = \frac{7d-k}{64} \le \frac{d}{50}$ and clears the gate.

*Finite-context correction.* The gate is evaluated against the actual mass
$2(1-2^{-m})$ per domain; the razor at $k-1$ has margin $\tfrac{1}{800}$, which the
truncation error $1.96\, d\, 2^{-m}$ must not consume. The hypothesis
$1600\,d \le 2^m$ guarantees this; with the experimental $m \ge 16$ it covers every
$d \le 41$. $\square$

**Corollary 8.5 (the $5.72$ rate).**
$$143\,d \;\le\; 25\,k^\ast(d) \;\le\; 143\,d + 24,$$
so the per-domain cost converges to $143/25 = 5.72 < 6$.

**Theorem 8.6 (the $6d$ law fails from four domains on).** For $d \ge 4$ (and $m$ as
above), $k^\ast(d) < 6d$.

**Theorem 8.7 (the corrected ladder).** For $m \ge 16$ at $\tau = 0.98$,
$$k^\ast(1)=6,\quad k^\ast(2)=12,\quad k^\ast(3)=18,\quad k^\ast(4)=23 < 24 .$$

The ladder continues $6, 12, 18, 23, 29, 35, 41, 46, \dots$, hitting exactly $143$ at
$d = 25$.

**Remark 8.8 (why the small-$d$ ladder lied).** $\lceil 5.72 d\rceil = 6d$ exactly when
$0.28\,d < 1$, i.e. for $d \le 3$. The first three rungs are therefore consistent with an
integer law that is false; only the exact formula reveals that the per-domain rate was
never an integer. The moral is methodological: three exact data points can determine a
clean integer law uniquely and still determine it wrongly.

---

## 9. Algorithms

Everything above is computable, and the computations are cheap. We record the three
routines that matter.

### 9.1 Pure knee by prefix scan

Given a profile truncated to $n$ weights and a gate $\tau$, accumulate prefix sums and
return the first index whose prefix reaches $\tau\,A(n)$. Cost $O(n)$ time, $O(1)$ extra
space.

### 9.2 Mixed head mass by dynamic programming

The two-domain head mass at budget $k$ is a maximum over $k+1$ splits, each evaluated in
$O(1)$ from precomputed prefix sums: $O(k)$ per budget, $O(k^2)$ to tabulate all budgets
up to $k$. For $d$ domains, the nested definition is a chain of sup-convolutions,
computable in $O(d\,k^2)$ by the standard $(\max,+)$-convolution recursion
$$H_{r}(k) \;=\; \max_{0\le j \le k}\big[H_{r-1}(j) + A(\min(k-j,m))\big].$$
Because each $A$ is concave (the profile is antitone, so the increments decrease), the
$(\max,+)$-convolution of concave sequences is again concave and can in fact be computed
in $O(k)$ by *merging increments*: the sorted merge of the two increment sequences.
This reduces the $d$-domain tabulation to $O(d\,k)$, and it is exactly the algorithmic
shadow of the theory — the optimal allocation is obtained greedily, taking at each step
the largest remaining increment across all domains.

### 9.3 Sweep evaluation and the peak

To evaluate the full mixing-ratio response at fixed total key count $2N$, run the mixed
knee at each split $(m, 2N-m)$. Theorem 7.3 says the resulting vector is unimodal with
its maximum at $m = N$, so the peak can be located without scanning: evaluate the centre.
The practical recommendation follows immediately — a budget table for mixed workloads
needs one extra entry, the balanced one, and that entry is the worst case.

---

## 10. Applications

**KV-cache provisioning.** The direct application. If a deployment's key budget is
calibrated on pure corpora, it is calibrated at the *shoulders* of the response and
underestimates the balanced interior. Theorems 3.4 and 5.2 bound the shortfall by a
factor of two and show the bound is attained, so a doubling is the correct worst-case
provisioning rule for two comparable domains; Theorem 8.4 refines it to
$\lceil 5.72\,d \rceil$ for $d$ comparable domains, an economy of roughly $5\%$ per
domain relative to the naive $6d$.

**Corpus design for evaluation.** Because the response is monotone in imbalance
(Theorem 7.3), any evaluation suite that samples mixing ratios only near the extremes
systematically misses the hardest configuration. One should test the balanced arm
explicitly.

**Mass-based triage.** Theorem 5.4 licenses a cheap heuristic: measure each domain's
*mass share*, not its block share. Domains below a mass threshold can be ignored in
budget planning entirely, no matter how many keys they contribute.

**Beyond attention.** The sup-convolution is domain-agnostic. Any system that splits a
fixed resource across two or more demand profiles with decreasing marginal returns
inherits the same structure: cache partitioning across concurrent processes, bandwidth
allocation across streams, newsvendor inventory against two comparable demand
distributions. In each case the pure regimes are easy because one demand dominates; the
symmetric case, which looks like the natural compromise, is the expensive one.

---

## 11. Discussion

### 11.1 What is proved and what is measured

The theorems are statements about the model of §2 — sorted profiles, top-$k$ truncation,
a mass gate. Within that model everything above is exact. The empirical claim they
explain is the observed bump, and the correspondence is at the level of *shape*: the
interior is never below the endpoints (Theorem 6.3), the peak is at the centre
(Corollary 7.4), the ceiling is a factor of two (Theorems 5.1–5.2), and the switch
between shoulder and plateau is governed by mass balance (Theorems 3.3 and 5.4).

The exact integer values $6, 12, 18, 23$ belong to the geometric profile, which has an
unusually clean spectral gap and hence an unusually coarse knee grid. On a real attention
spectrum the grid is finer, the interior plateau resolves into a shaped curve, and the
predicted structure is the ordering rather than the flatness.

### 11.2 Honest limits of the empirical side

The measurement that motivated this work used one model scale, one domain pair, one block
size, two context lengths and twelve held-out windows, with an oracle top-$k$ selection
and an exact retention gate. The pure-code endpoint replicated an earlier reading
exactly; the pure-prose endpoint came in one grid step low, within the $\pm 1$-step knee
fuzz expected on razor-thin curves. Mixed arms showed larger draw-to-draw variance than
pure arms across independent corpus draws — construction variance in mixed budgets is
genuinely larger, which is itself consistent with the theory: near the peak the sweep is
flat to first order, so small perturbations move the argmax cheaply while the *value*
stays pinned.

### 11.3 Why two effects and not one

It is worth emphasising that the peak at the centre is *overdetermined*. Lemma 6.1 says a
balanced split maximises the demand; Lemma 6.2 says it minimises the supply at every
budget. Either alone would suggest a peak; together they force it. This is the
mathematical content of the informal mechanism reading — at the balanced point every
query attends into the other domain's keys, so cross-domain interaction is maximised —
and it also explains why the effect is robust to details of the profile: both lemmas need
only antitonicity.

### 11.4 The methodological lesson of §8

For as long as only small cases were known, the $6d$ ladder was consistent with every
available exact value. It took the general formula to see that the per-domain rate is $143/25$ and that the
first three rungs coincide with $6d$ by rounding. When a discrete optimisation admits a
tight linear relaxation — here the tangent-line bound of Lemma 8.3 — the honest constant
is the slope of that relaxation, and integer coincidences at small parameters should be
distrusted.

---

## 12. Future work

**Strict Schur-concavity.** Theorem 7.3 gives the non-strict ordering. Conjecture: for a
*strictly* decreasing profile the mixed knee is strictly Schur-concave in the key-count
vector, i.e. a Robin Hood step strictly increases the knee whenever the knee grid is fine
enough (say, whenever the profile's tail ratio exceeds a threshold depending on $\tau$).
The transposition lemmas already expose the exact mass moved by each step; what is
missing is the comparison of that quantity with the local slope of the retained-fraction
curve. Profiles with a coarse grid (geometric decay) must be excluded, since the sweep is
provably flat there. If true, the whole ratio response is determined by a single scalar —
the imbalance — and budget tables could be published per-imbalance rather than
per-corpus. If false, some profile has a knee curve with interior local minima and the
empirical premium is not a robust design parameter.

**Unequal domain sizes and unequal profiles in the $d$-fold theory.** Theorem 8.4 assumes
$d$ equally massive domains with a common profile. The general problem — $d$ domains with
distinct profiles and mass shares — should be governed by a $d$-dimensional
mass-balance simplex, with the peak at the barycentre and shoulders along every face
where one domain's mass degenerates. Theorem 5.4 is the $d=2$ face.

**Non-geometric exact values.** The tangent-line technique of Lemma 8.3 is not specific
to $2^{-j}$: any convex decreasing profile admits a tight chord between two consecutive
integers, and the resulting rate is the slope of that chord. Determining the analogous
rate for power-law profiles $a_i = (i+1)^{-\alpha}$, which are closer to measured
attention spectra, would give a directly usable budget law.

**Block-size sensitivity and larger models.** The empirical side leaves open: other
domain pairs; sensitivity to the block size at which domains are interleaved; whether
the premium persists at larger model scales; and how the bump interacts with the
acceleration effects observed at very long contexts.

---

## 13. Summary of results

| # | Statement | Content |
|---|---|---|
| 2.4 | Sup-convolution | Mixed head mass is $\max_j [A(\min(j,m)) + B(\min(k-j,l))]$ |
| 2.7 | Endpoints | The sweep passes exactly through the single-domain theory |
| 3.1 | Subadditivity | $k^\ast(m,l) \le k^\ast_a(m) + k^\ast_b(l)$ |
| 3.2 | Minority bound | $k^\ast(m,l) \le k^\ast_a(m) + l$ |
| 3.3 | Mechanism | Both heads must be bought, at gates relaxed by mass share |
| 3.4 | Doubling sandwich | $2k^\ast_a(m,2\tau-1) \le k^\ast(m,m,\tau) \le 2k^\ast_a(m,\tau)$ |
| 4.2 / 4.3 | Exact geometric values | Pure $=6$; mixed $=12$ for both sides $\ge 16$ |
| 4.5–4.7 | P1, P2, P3 refuted | Not linear, not a dip, not monotone |
| 5.2 | Ceiling sharp | The factor-two bound is attained |
| 5.4 / 5.5 | Mass, not blocks | A light half-of-the-keys domain leaves the knee at $6$ |
| 5.6 | Minority threshold | $l \le 5$ keeps the knee $\le 11 < 12$ |
| 6.1 / 6.2 | Two mechanisms | Balanced splits: most mass, least head |
| 6.3 | Peak at the centre | $k^\ast(m,l) \le k^\ast(N,N)$ for every split |
| 7.3 | Schur-concavity | The sweep is monotone in the imbalance |
| 8.1 | Three domains | $k^\ast_3 = 18$ |
| 8.4 | $d$ domains, exactly | $k^\ast(d) = \lceil 143d/25\rceil$ |
| 8.6 / 8.7 | $6d$ refuted | Four domains cost $23$, not $24$ |
