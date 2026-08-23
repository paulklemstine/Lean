# Grid Artifacts, Replication Margins, and the Exact Capacity of Threshold Sweeps

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

A *sweep* estimates a threshold — the least parameter value at which a monotone quality curve clears a gate — by evaluating the curve at a finite grid of sampled parameter values. We develop the exact theory of what such an estimate can and cannot report, and then solve the associated design problem in closed form.

Three groups of results are established. **(i) Measurement.** For a nondecreasing curve $A$, gate $g$, and grid $G$, the reported threshold equals the least grid point at or above the true threshold — the *factorisation theorem*. Hence a sweep can only over-report; refining a grid can only lower the reading; the reading is exact if and only if the true threshold lies on the grid; and, on a doubling grid, the reading is always strictly less than twice the truth. The artifact is irreducible: two nondecreasing curves agreeing at every point of a grid, and thus producing identical readings at every gate, may have arbitrarily prescribed true thresholds within a single grid cell. **(ii) Replication.** If two curves are uniformly $\varepsilon$-close and one clears the gate at $k$ with margin exceeding $\varepsilon$, while missing it by more than $\varepsilon$ at all smaller parameters, the two thresholds coincide exactly; and the margin hypothesis cannot be dropped, since for every $\varepsilon > 0$ and every $N$ there are $\varepsilon$-close nondecreasing curves with thresholds $1$ and $N$. Separately, thresholds of *normalised* (retention) curves are invariant under positive rescaling of the raw curve, so absolute quality level and threshold position are independent coordinates. **(iii) Design.** Call a grid $G$ an $(a,b)$-localiser of $[1,N]$ if every $c \in [1,N]$ admits $g \in G$ with $g \le bc$ and $c \le ag$. For integers $a,b \ge 1$ the exact capacity of an $s$-point grid is
$$\Sigma(ab, s) \;=\; ab + (ab)^2 + \cdots + (ab)^s,$$
attained by the unique grid $\{\,b(\Sigma(ab,j)+1) : 0 \le j < s\,\}$; uniqueness holds exactly at capacity and fails one unit below it. The capacity therefore depends on $(a,b)$ only through the product $ab$ — a *product law* which unifies the deployment-safe case $(1,r)$ with capacity $\Sigma(r,s)$ and the two-sided case $(r,r)$ with capacity $\Sigma(r^2,s)$, and which is sandwiched by $\Sigma(r,2s-1) < \Sigma(r^2,s) < \Sigma(r,2s)$, pricing the never-under-provision constraint at a factor two in sample points and no more.

The theory is applied to a concrete measurement problem: the minimal key budget of a limited-memory attention scheme retaining $98\%$ of full-context quality. It shows that a reported disagreement between two corpora ($24$ versus $32$ keys at context $2048$) is entirely explained by a grid difference on one and the same curve; that the observed replication of the chain $k^\*(512)=16$, $k^\*(1024)=20$, $k^\*(2048)=24$ across two disjoint corpora is forced by the measured margins ($\varepsilon = 0.0009$ suffices); that the corpora's differing absolute accuracies ($0.4946$ versus $0.4760$) are invisible to the threshold; and that the observed chain is incompatible with both a Zipf and a truncated-geometric attention profile.

---

## 1. Introduction

### 1.1 The empirical situation

Consider a language model with a long context window that, for memory reasons, retains only the top $k$ attention keys per query. Quality degrades as $k$ shrinks. Fix a *gate* $g$ — a retention level such as $0.98$ of full-context quality — and define the **knee** $k^\*$ as the least budget attaining it. The knee is the deployment-relevant number: it is what one provisions.

Knees are measured by *sweeps*: one evaluates quality at a finite list of candidate budgets and reports the smallest one clearing the gate. Two sweeps of the same model on two disjoint text shards, at context length $2048$, reported different knees — $24$ on shard A (measured on the fine grid $\{16,20,24,28,32\}$) and $32$ on shard B (measured on the coarse doubling grid $\{8,16,32,64\}$). A shard-level difference was the natural hypothesis.

Rerunning shard B on the fine grid gives the table

| budget $k$ | $20$ | $24$ | $28$ | $32$ |
|---|---|---|---|---|
| retained quality | $0.9790$ | $0.9832$ | $0.9853$ | $0.9862$ |

against the gate $0.98$: the knee is $24$, identical to shard A. Three pre-registered hypotheses were thereby resolved: the shard-level-difference hypothesis is refuted; the grid-artifact hypothesis is confirmed; and the "the truth lies strictly between $24$ and $32$" hypothesis is refuted. The consequence is a complete dual-corpus deployment table: the chain $\{16, 20, 24\}$ at contexts $\{512, 1024, 2048\}$ now replicates exactly, cell for cell, on two disjoint corpora. Baseline note: shard B's absolute accuracy is $0.4946$ against shard A's $0.4760$ — the second text is easier — yet the knees coincide.

### 1.2 What this paper proves

The empirical episode is the motivation; the content is a general theory of threshold sweeps. Section 2 fixes definitions. Section 3 proves the factorisation theorem and its corollaries, including the underdetermination result showing that the artifact cannot be removed by post-hoc inference, and instantiates them on the measured data. Section 4 proves the replication law, its sharpness, and the scale invariance decoupling accuracy level from threshold position. Section 5 records the closed-form logarithmic law satisfied by the measured chain, its status as a pre-registered and falsifiable prediction, and a trichotomy excluding the two standard attention-profile families. Sections 6–8 solve the design problem: exact one-sided capacity and rigidity (§6), the two-sided relaxation and the price of the deployment constraint (§7), and the asymmetric product law unifying both (§8). Section 9 gives algorithms, §10 discusses applications and limitations, and §11 lists open directions.

---

## 2. Setting and definitions

Throughout, budgets are positive integers and quality values are rationals.

**Definition 2.1 (Quality curve, gate, knee).** A *quality curve* is a function $A : \mathbb{N} \to \mathbb{Q}$; it is *monotone* if $j \le k$ implies $A(j) \le A(k)$. Given a gate $g \in \mathbb{Q}$, the **knee** is
$$k^\*(A,g) \;=\; \inf\{k \in \mathbb{N} : A(k) \ge g\},$$
the infimum being over a set of naturals (so it is attained whenever the set is nonempty). Two basic facts are used repeatedly: if $A(k) \ge g$ then $k^\*(A,g) \le k$; and if the set is nonempty then $A(k^\*(A,g)) \ge g$.

**Definition 2.2 (Grid knee).** For a set $G \subseteq \mathbb{N}$ of sampled budgets, the **grid knee** — the only quantity a sweep can report — is
$$\hat{k}(G, A, g) \;=\; \inf\{k : k \in G \text{ and } A(k) \ge g\}.$$

**Definition 2.3 (Localisation).** Let $r \ge 1$ be an integer. A finite grid $G \subseteq \mathbb{N}$ **localises** $[1,N]$ *to a factor $r$* if
$$\forall c \in [1,N]\;\; \exists g \in G : \quad c \le g \le r\,c .$$
This is the *deployment-safe* requirement: the sampled budget is never below the target (never under-provision) and overshoots by at most $r$.

**Definition 2.4 (Two-sided and asymmetric localisation).** $G$ is a **two-sided** $r$-localiser of $[1,N]$ if for every $c \in [1,N]$ there is $g \in G$ with $g \le rc$ and $c \le rg$. More generally, for integers $a, b \ge 1$, $G$ is an **$(a,b)$-localiser** of $[1,N]$ if
$$\forall c \in [1,N]\;\;\exists g \in G : \quad g \le b\,c \;\;\text{and}\;\; c \le a\,g,$$
i.e. $g$ overshoots $c$ by at most the factor $b$ and undershoots it by at most the factor $a$. Taking $a = 1$ recovers Definition 2.3 with $b = r$; taking $a = b = r$ gives the two-sided notion.

**Definition 2.5 (Geometric sum).** For integers $r, s \ge 0$ put
$$\Sigma(r,s) \;=\; \sum_{i=0}^{s-1} r^{\,i+1} \;=\; r + r^2 + \cdots + r^s ,\qquad \Sigma(r,0) = 0 .$$
Two identities are used constantly:
$$\Sigma(r,s+1) = \Sigma(r,s) + r^{s+1}, \qquad \Sigma(r,s+1) = r\,\Sigma(r,s) + r. \tag{2.1}$$
The second (the *recurrence form*) says that adding one sample point multiplies the reachable range by $r$ and then adds $r$. For $r \ge 1$, $\Sigma(r,\cdot)$ is strictly increasing, and $\Sigma(1,s) = s$.

---

## 3. What a sweep measures: the factorisation theorem

### 3.1 The theorem

**Theorem 3.1 (Factorisation).** Let $A$ be monotone and suppose some $k \in G$ satisfies $A(k) \ge g$. Then
$$\hat{k}(G,A,g) \;=\; \inf\{k : k \in G \text{ and } k \ge k^\*(A,g)\}.$$

*Proof sketch.* For monotone $A$ and a gate that is met somewhere, one has $k^\*(A,g) \le k \iff A(k) \ge g$: the forward direction is monotonicity applied to $A(k^\*) \ge g$, the backward direction is minimality of $k^\*$. Substituting this equivalence inside the defining infimum of $\hat{k}$ replaces the condition "$A(k) \ge g$" by "$k \ge k^\*(A,g)$", which is the claim. $\square$

The content is that the map (curve) $\mapsto$ (sweep reading) *factors through the single number $k^\*$*. All other information in the curve — its values, its shape, its provenance — is annihilated by the sweep.

### 3.2 Corollaries

**Corollary 3.2 (Sweeps over-report).** $k^\*(A,g) \le \hat{k}(G,A,g)$ whenever the gate is met on $G$. Thus a reported knee is an upper bound for the true knee: provisioning at the reported value is always safe.

**Corollary 3.3 (Exactness is grid membership).** $\hat{k}(G,A,g) = k^\*(A,g)$ if and only if $k^\*(A,g) \in G$.

*Proof sketch.* If the reading equals the knee then the knee is a grid point, since readings are grid points. Conversely if $k^\* \in G$ then $k^\*$ is admissible in the infimum defining $\hat k$, giving $\hat k \le k^\*$, and Corollary 3.2 gives the reverse. $\square$

**Corollary 3.4 (Refinement is monotone).** If $G \subseteq H$ and the gate is met on $G$, then $\hat{k}(H,A,g) \le \hat{k}(G,A,g)$. A finer sweep never reports a larger knee than a coarser one.

**Proposition 3.5 (Bracketing).** If $A$ is monotone, $A(a) < g$ and $A(b) \ge g$, then $a < k^\*(A,g) \le b$. A sweep with a failing point below and a passing point above pins the knee to a half-open cell.

**Theorem 3.6 (Doubling-grid artifact bound).** Let $D = \{2^j : j \ge 0\}$ and let $A$ be monotone with the gate met somewhere. Then
$$\hat{k}(D, A, g) \;<\; 2\,k^\*(A,g)$$
whenever $k^\* \ge 1$.

*Proof sketch.* Let $m$ be minimal with $k^\* \le 2^m$. Then $2^m \in D$ and $A(2^m) \ge g$ by monotonicity, so $\hat k \le 2^m$. Minimality gives $2^{m-1} < k^\*$ (when $m \ge 1$), whence $2^m < 2k^\*$; the case $m = 0$ is immediate. $\square$

So doubling grids inflate by less than a factor $2$ — and can inflate by nearly that much, so the bound is essentially sharp.

### 3.3 The artifact is not removable by inference

**Theorem 3.7 (Underdetermination).** Fix the coarse grid $C = \{8,16,32,64\}$ and let $a, b \in (16, 32]$ be arbitrary. There exist monotone curves $A$ and $B$ with
$$A|_C = B|_C, \qquad k^\*(A,g) = a, \qquad k^\*(B,g) = b, \qquad \hat{k}(C,A,g) = \hat{k}(C,B,g) = 32 .$$

*Proof sketch.* Take the step curves $S_c(k) = \mathbf{1}[k \ge c]$, which are monotone with $k^\*(S_c, g) = c$ for any gate $g \in (0,1]$. For $c \in (16,32]$, $S_c$ vanishes at $8$ and $16$ and equals $1$ at $32$ and $64$, so all such curves agree on $C$ and all give the coarse reading $32$. Take $A = S_a$, $B = S_b$. $\square$

Since $A$ and $B$ agree at every sampled point, they yield identical readings *for every gate*, not merely for $g$. Consequently a coarse reading of $32$ is logically compatible with any true knee in $(16,32]$, and comparing a coarse reading on one corpus with a fine reading on another can never constitute evidence of a corpus-level difference.

### 3.4 The measured instance

Model the empirical row as a curve assembled from nonnegative per-key gains, $A(k) = \sum_{i<k} w_i$, which is automatically monotone. Choosing the gains so that the accumulated retention matches the measured table gives a curve $B_{\mathrm{obs}}$ with
$$B_{\mathrm{obs}}(20) = 0.9790,\quad B_{\mathrm{obs}}(24) = 0.9832,\quad B_{\mathrm{obs}}(28) = 0.9853,\quad B_{\mathrm{obs}}(32) = 0.9862,$$
and with no gain accruing strictly between $20$ and $23$, so $B_{\mathrm{obs}}(k) < 0.98$ for all $k \le 23$.

**Theorem 3.8 (The disagreement was a grid artifact).** With gate $g = 0.98$, the fine grid $F = \{16,20,24,28,32\}$ and the coarse grid $C = \{8,16,32,64\}$:
$$k^\*(B_{\mathrm{obs}}, g) = 24, \qquad \hat{k}(F, B_{\mathrm{obs}}, g) = 24, \qquad \hat{k}(C, B_{\mathrm{obs}}, g) = 32, \qquad \hat{k}(C,\cdot) < 2\,k^\* .$$

*Proof sketch.* $B_{\mathrm{obs}}(24) = 0.9832 \ge g$ and $B_{\mathrm{obs}}(k) < g$ for $k \le 23$, giving the true knee $24$; $24 \in F$, so Corollary 3.3 gives the fine reading; on $C$ the smallest point at or above $24$ is $32$, and $A(32) \ge g$, so the coarse reading is $32$ by Theorem 3.1; finally $32 < 48$. $\square$

One corpus, one curve, two readings. No shard-level effect is needed to produce the reported $24$-versus-$32$ discrepancy, and the size of the discrepancy obeys the general doubling bound.

---

## 4. Replication and the accuracy/knee decoupling

### 4.1 Replication is a margin phenomenon

**Theorem 4.1 (Replication law).** Let $A, B$ be quality curves with $|A(j) - B(j)| \le \varepsilon$ for all $j$. Suppose
$$A(k) \ge g + \varepsilon \qquad\text{and}\qquad A(j) + \varepsilon < g \;\; \text{for all } j < k .$$
Then $k^\*(B,g) = k$.

*Proof sketch.* From $B(k) \ge A(k) - \varepsilon \ge g$, the gate is met at $k$, so $k^\*(B,g) \le k$. For $j < k$, $B(j) \le A(j) + \varepsilon < g$, so no smaller budget qualifies. $\square$

**Corollary 4.2 (Agreement).** Under the hypotheses of Theorem 4.1, $k^\*(A,g) = k^\*(B,g) = k$. (Apply the theorem with $B$ replaced by $A$, using $|A - A| = 0 \le \varepsilon$ and $A(k) \ge g + \varepsilon \ge g$.)

**Corollary 4.3 (Measured replication threshold).** For the measured curve $B_{\mathrm{obs}}$ and gate $0.98$: the gate is cleared at $24$ with margin $0.9832 - 0.98 = 0.0032$ and missed at every $k \le 23$ with margin at least $0.98 - 0.9790 = 0.0010$. Hence **every** curve uniformly within $\varepsilon = 0.0009$ of $B_{\mathrm{obs}}$ has knee exactly $24$.

Thus the cell-for-cell replication observed across the two shards is not a coincidence to be marvelled at but a consequence of the measured margins, with an explicit tolerance.

**Theorem 4.4 (The margin hypothesis is necessary).** For every $\varepsilon \in (0,1]$ and every $N \ge 1$ there are monotone curves $A, B$ with $|A(j) - B(j)| \le \varepsilon$ for all $j$, $k^\*(A,g) = 1$ and $k^\*(B,g) = N$.

*Proof sketch.* Place the two curves within $\varepsilon$ of the gate on opposite sides throughout $[1, N)$: let $A$ sit just above $g$ from budget $1$ onward and $B$ sit just below $g$ until $N$, the vertical separation being at most $\varepsilon$ everywhere. Both are monotone, uniformly $\varepsilon$-close, and have the stated knees. $\square$

So the knee is a discontinuous functional of the curve; only margins tame it. The methodological corollary: report knees together with the margins by which the gate is cleared and missed, since these certify replicability.

### 4.2 Accuracy level and knee position are independent

**Definition 4.5 (Retention curve).** Given a raw quality sweep $\mathrm{raw} : \mathbb{N} \to \mathbb{Q}$ and a context $\mathrm{ctx}$, the *retention curve* is $R(k) = \mathrm{raw}(k)/\mathrm{raw}(\mathrm{ctx})$.

**Theorem 4.6 (Scale invariance).** For every $c \ne 0$, every context and every gate,
$$k^\*\big(k \mapsto (c\cdot\mathrm{raw})(k)/(c\cdot\mathrm{raw})(\mathrm{ctx}),\; g\big) \;=\; k^\*\big(R, g\big).$$

*Proof sketch.* The two retention curves are *equal as functions*, since $c\,\mathrm{raw}(k)/(c\,\mathrm{raw}(\mathrm{ctx})) = \mathrm{raw}(k)/\mathrm{raw}(\mathrm{ctx})$; equal curves have equal knees. $\square$

**Corollary 4.7 (Baseline shift).** If shard B's raw sweep is shard A's multiplied by the difficulty factor $0.4946/0.4760$, then the two shards have identical knees at every gate.

Absolute accuracy level and knee position are therefore independent coordinates: the observation "corpus B is easier yet has the same knee" is not a tension in the data but the predicted behaviour of a ratio-gated statistic.

---

## 5. The measured chain: closed form, prediction, and profile trichotomy

### 5.1 A logarithmic law

The dual-corpus deployment table is $k^\*(512) = 16$, $k^\*(1024) = 20$, $k^\*(2048) = 24$; equivalently
$$k^\*(\mathrm{ctx}) \;=\; 4\log_2 \mathrm{ctx} - 20 . \tag{5.1}$$

**Proposition 5.1 (Prediction, not fit).** If $a\cdot 9 + b = 16$ and $a \cdot 10 + b = 20$, then $a = 4$, $b = -20$, and $a \cdot 11 + b = 24$. Conversely, if $a \cdot 9 + b = 16$ and $a \ne 4$, then $a\cdot 11 + b \ne 24$.

*Proof sketch.* Two affine equations in two unknowns determine $(a,b)$ uniquely; evaluation at $11$ gives $24$. For the converse, $a\cdot 11 + b = 24$ together with $a \cdot 9 + b = 16$ forces $2a = 8$. $\square$

The third cell was therefore forced by the first two under the hypothesis of a law affine in $\log_2 \mathrm{ctx}$, and any competing slope is discriminated by the measurement. The measurement returned $24$ on both corpora.

### 5.2 Two classical profiles are excluded

Suppose the per-key attention mass follows a probability profile $p$ on $n$ keys, and retention at budget $k$ is the captured mass $\sum_{i<k} p_i$ normalised by the total.

**Zipf profile.** Take $p_i \propto 1/(i+1)$, so retention is $H_{\min(k,n)}/H_n$ with $H_n$ the $n$-th harmonic number. Using the dyadic bounds $1 + m/2 \le H_{2^m} \le 1 + m$, one gets:

**Theorem 5.2 (Zipf is too dear).** For the Zipf profile on $n = 2^{11}$ keys and gate $0.98$, the knee exceeds $32$; in particular it differs from the measured $24$. Moreover, for every gate $\tau \in (0,1]$ and every bound $K$ there is a context at which the Zipf knee exceeds $K$: the Zipf obstruction is asymptotic, not an artifact of the particular context.

*Proof sketch.* Capturing a fraction $\tau$ of harmonic mass at budget $2^j$ requires $H_{2^j} \ge \tau H_{2^m}$ with $n = 2^m$; the upper bound $H_{2^j} \le 1 + j$ and the lower bound $H_{2^m} \ge 1 + m/2$ turn this into a linear inequality in $j$ that fails for $j$ small relative to $m$, forcing the knee above $2^j$. Instantiating $m = 11$, $\tau = 0.98$, $j = 5$ excludes all budgets up to $32$; letting $m \to \infty$ pushes the knee beyond any $K$. $\square$

**Truncated geometric profile.** Take $p_i \propto 2^{-i}$ on $n$ keys, so retention at $k$ is $(1 - 2^{-k})/(1 - 2^{-n})$.

**Theorem 5.3 (Geometric is too cheap and rigid).** For every $n \ge 10$ the knee at gate $0.98$ is exactly $6$. In particular the geometric knee at context $512$ equals that at context $2048$: it does not move with the context at all.

*Proof sketch.* $1 - 2^{-5} = 0.96875 < 0.98 \le 0.984375 = 1 - 2^{-6}$, and for $n \ge 10$ the normalising denominator lies within $2^{-10}$ of $1$, too small to flip either inequality. $\square$

**Theorem 5.4 (Profile trichotomy).** The measured chain is incompatible with both families: the Zipf knee at context $2048$ exceeds $24$ (indeed exceeds $32$), whereas the geometric knee is context-free, whereas the measured knee satisfies (5.1) and moves by $8$ keys between contexts $512$ and $2048$.

The attention profiles consistent with the deployment table therefore lie strictly between the heavy-tailed and light-tailed extremes: light enough that $24$ keys suffice at context $2048$, heavy enough that the requirement grows logarithmically rather than saturating.

---

## 6. Exact sweep capacity and rigidity

We now turn from measurement to design. Throughout this section $r \ge 1$ is an integer and grids are finite subsets of $\mathbb{N}$.

By Theorem 3.1, "$G$ localises $[1,N]$ to a factor $r$" (Definition 2.3) is exactly the statement that a sweep on $G$ reports every knee in $[1,N]$ to within a factor $r$: if $k^\* \in [1,N]$ and $g \in G$ satisfies $k^\* \le g \le r k^\*$, then $\hat{k}(G,A,g) \le r\,k^\*$.

### 6.1 A crude bound, and why it is not tight

**Proposition 6.1 (Packing bound).** If $G$ localises $[1,N]$ to a factor $r \ge 1$ then $N < (r+1)^{|G|}$.

*Proof sketch.* The intervals $[(r+1)^i, r(r+1)^i]$ for $i = 0, 1, \dots, |G|$ are pairwise disjoint, because $r(r+1)^i < (r+1)^{i+1}$. If $N \ge (r+1)^{|G|}$ each of these $|G|+1$ intervals contains a budget $\le N$, hence must contain its own grid point, giving $|G| + 1$ distinct grid points — a contradiction. $\square$

Equivalently, a grid with fewer than $\log_{r+1} N$ points has a *blind budget*: some $c \le N$ with no grid point in $[c, rc]$. This already shows that no four-point grid whatsoever localises $[1,81]$ to a factor $2$. But the bound is never tight, as the next results show.

### 6.2 The exact capacity

**Theorem 6.2 (Capacity upper bound).** If $|G| = n$, $r \ge 1$, and $G$ localises $[1,N]$ to a factor $r$, then $N \le \Sigma(r,n)$.

*Proof sketch.* Induct on $n$. For $n = 0$ the grid is empty and cannot serve $c = 1$, so $N = 0$. For $n \ge 1$ and $N \ge 1$, let $M = \max G$. Serving $c = N$ requires some grid point $\ge N$, so $N \le M$. Put $N' = \lfloor (M-1)/r \rfloor$. Any budget $c \le N'$ satisfies $rc \le rN' \le M - 1 < M$, so $M$ cannot serve it; hence $G \setminus \{M\}$, of size $n-1$, localises $[1, \min(N,N')]$. By induction $\min(N,N') \le \Sigma(r,n-1)$. If $N \le N'$ we are done by monotonicity of $\Sigma(r,\cdot)$. Otherwise $N' \le \Sigma(r,n-1)$, and from $M \le rN' + r$ and $N \le M$ we get
$$N \;\le\; r N' + r \;\le\; r\,\Sigma(r, n-1) + r \;=\; \Sigma(r,n),$$
the last step being the recurrence (2.1). $\square$

**Definition 6.3 (Offset geometric grid).** $\mathcal{G}(r,s) = \{\, \Sigma(r, j+1) : 0 \le j < s \,\} = \{ r,\; r + r^2,\; \dots,\; r + \cdots + r^s \}$. For $r \ge 1$ it has exactly $s$ elements.

**Theorem 6.4 (Attainment).** $\mathcal{G}(r,s)$ localises $[1, \Sigma(r,s)]$ to a factor $r$.

*Proof sketch.* Given $1 \le c \le \Sigma(r,s)$, let $j$ be least with $c \le \Sigma(r,j)$; then $1 \le j \le s$ and $\Sigma(r,j-1) < c$. Take the grid point $g = \Sigma(r,j)$. Then $c \le g$ by choice of $j$, and by the recurrence
$$g = r\,\Sigma(r,j-1) + r \le r(c-1) + r = rc .$$
$\square$

The geometry is transparent: each point sits at the exact *top* of the interval it can serve, so no reach is wasted.

**Theorem 6.5 (Exact capacity).** For $r \ge 1$ and every $s$,
$$\max\{\,N : \exists G,\; |G| = s,\; G \text{ localises } [1,N] \text{ to a factor } r\,\} \;=\; \Sigma(r,s).$$

**Proposition 6.6 (Both naive guesses are wrong).** The guess $r^{|G|}$ is too small: $\{2,6\}$ localises $[1,6]$ to a factor $2$, and $6 > 2^2$. The packing bound $(r+1)^s$ is too large: $\Sigma(r,s) < (r+1)^s$ for all $r, s \ge 1$.

### 6.3 Rigidity

**Theorem 6.7 (Rigidity).** Let $r \ge 1$, $|G| = s$, and suppose $G$ localises $[1, \Sigma(r,s)]$ to a factor $r$. Then $G = \mathcal{G}(r,s)$.

*Proof sketch.* Induct on $s$, following the peeling argument of Theorem 6.2 but tracking equality. With $N = \Sigma(r,s)$ and $M = \max G$, the strict monotonicity of $\Sigma(r,\cdot)$ forces the case $N' < N$, hence $G \setminus \{M\}$ localises $[1,N']$ with $s-1$ points, so $N' \le \Sigma(r,s-1)$. The chain $N \le M \le rN' + r \le r\Sigma(r,s-1) + r = N$ must be an equality throughout, giving $N' = \Sigma(r,s-1)$ and $M = \Sigma(r,s)$. The induction hypothesis identifies $G \setminus \{M\}$ with $\mathcal{G}(r,s-1)$, and $\mathcal{G}(r,s) = \mathcal{G}(r,s-1) \cup \{\Sigma(r,s)\}$. $\square$

**Corollary 6.8 (Structure of optima).** An optimal grid contains the top of its range, $\Sigma(r,s) \in G$; and for $r \ge 2$ it never contains the budget $1$, since every point of $\mathcal{G}(r,s)$ is at least $r$. In particular the classical grid $\{1, r, r^2, \dots\}$ is structurally excluded from optimality.

**Proposition 6.9 (Rigidity is exactly a capacity phenomenon).** One budget below capacity, uniqueness already fails: both $\{2,6\}$ and $\{2,5\}$ localise $[1,5]$ to a factor $2$, yet only $\{2,6\}$ localises $[1,6]$.

### 6.4 The dual question, and the measured sweep

**Theorem 6.10 (Minimal sweep cost).** For $r \ge 1$ and $N \ge 0$, the least number of sample points localising $[1,N]$ to a factor $r$ is the least $s$ with $N \le \Sigma(r,s)$; such an $s$ always exists since $s \le \Sigma(r,s)$.

**Corollary 6.11 (The measured instance).**
1. Four doubling-accurate points cover exactly $[1,30]$, and no four-point grid covers $[1,31]$.
2. The optimum is unique: any four-point grid localising $[1,30]$ to a factor $2$ equals $\{2, 6, 14, 30\}$.
3. The coarse grid actually used, $\{8,16,32,64\}$, does *not* localise $[1,30]$: the budget $3$ has no grid point in $[3,6]$. Starting a doubling sweep high wastes points at the bottom of the range.
4. Localising $[1,64]$ to a factor $2$ costs exactly six points. The coarse sweep used four — under-resourced by half.

---

## 7. Relaxing the deployment constraint: two-sided sweeps

Definition 2.3 forbids under-provisioning. For exploratory work one may accept a factor $r$ of slack on either side (Definition 2.4 with $a = b = r$).

**Theorem 7.1 (Two-sided capacity).** For $r \ge 1$, the maximum range coverable by $s$ points with a factor $r$ on either side is exactly $\Sigma(r^2, s) = r^2 + r^4 + \cdots + r^{2s}$, attained by
$$\mathcal{T}(r,s) \;=\; \{\, r\,(\Sigma(r^2,j) + 1) : 0 \le j < s \,\},$$
and this grid is the unique optimum at capacity.

*Proof sketch.* Both bound and attainment are the $a = b = r$ instances of Theorem 8.2 and Theorem 8.4 below; the peeling step now loses a factor $r$ at the bottom (a point $M$ serves only $c \ge M/r$) and gains a factor $r$ at the top (it reaches up to $rM$), so the two factors compound into $r^2$. $\square$

**Proposition 7.2 (A natural guess is refuted).** The value $r^{2s-1}$ is strictly too small: at $r = 2$, $s = 2$ it predicts $8$, while two points genuinely cover $[1,20]$, namely $\mathcal{T}(2,2) = \{2,10\}$.

**Theorem 7.3 (The price of never under-provisioning).** For $r \ge 2$ and $s \ge 1$,
$$\Sigma(r, 2s-1) \;<\; \Sigma(r^2, s) \;<\; \Sigma(r, 2s).$$

*Proof sketch.* For the left inequality, the single top term $r^{2s}$ of the two-sided sum already exceeds the entire one-sided sum $\Sigma(r,2s-1)$, since $\Sigma(r,m) + r \le r^{m+1}$ for $r \ge 2$. For the right, an induction on $s$ matches the terms of $\Sigma(r^2,s)$ with the even-indexed terms of $\Sigma(r,2s)$, the odd-indexed terms remaining as strict slack. $\square$

Thus a two-sided sweep with $s$ points is strictly better than a one-sided sweep with $2s-1$ points and strictly worse than one with $2s$: **the deployment constraint costs a factor two in sample points, and no more.**

**Corollary 7.4 (Measured instance).** At $r = 2$ and $s = 4$: two-sided capacity $340$, attained uniquely by $\{2, 10, 42, 170\}$; one-sided capacity $30$, attained uniquely by $\{2, 6, 14, 30\}$.

---

## 8. The product law

Both preceding capacity theorems are instances of one statement.

**Definition 8.1.** For integers $a, b \ge 1$, recall from Definition 2.4 that $G$ is an $(a,b)$-localiser of $[1,N]$ if every $c \in [1,N]$ admits $g \in G$ with $g \le bc$ and $c \le ag$. The one-sided notion is $(1,r)$ and the two-sided notion is $(r,r)$.

**Theorem 8.2 (Asymmetric capacity, upper bound).** If $|G| = n$, $a,b \ge 1$, and $G$ is an $(a,b)$-localiser of $[1,N]$, then $N \le \Sigma(ab, n)$.

*Proof sketch.* Induct on $n$, peeling $M = \max G$. Serving $c = N$ gives $N \le aM$ (the point that serves $N$ satisfies $N \le a g \le a M$). Put $N' = \lfloor (M-1)/b \rfloor$; a budget $c \le N'$ has $bc \le bN' \le M-1 < M$, so $M$ cannot serve it, and $G \setminus \{M\}$ is an $(a,b)$-localiser of $[1, \min(N,N')]$. Induction gives $\min(N,N') \le \Sigma(ab, n-1)$. In the nontrivial case,
$$N \;\le\; a M \;\le\; a(bN' + b) \;=\; ab\,N' + ab \;\le\; ab\,\Sigma(ab,n-1) + ab \;=\; \Sigma(ab, n).$$
The two tolerances enter as a product because one governs the *bottom* of the interval a point serves and the other its *top*. $\square$

**Definition 8.3 (Asymmetric grid).** $\mathcal{A}(a,b,s) = \{\, b\,(\Sigma(ab, j) + 1) : 0 \le j < s\,\}$, of cardinality $s$ for $a,b \ge 1$.

**Theorem 8.4 (Attainment).** $\mathcal{A}(a,b,s)$ is an $(a,b)$-localiser of $[1, \Sigma(ab,s)]$.

*Proof sketch.* Given $1 \le c \le \Sigma(ab,s)$, let $j$ be least with $c \le \Sigma(ab,j)$, so $j \ge 1$ and $\Sigma(ab,j-1) < c$. Take $g = b(\Sigma(ab,j-1)+1) \in \mathcal{A}$. Then $g \le bc$ since $\Sigma(ab,j-1)+1 \le c$; and by the recurrence,
$$a g = ab\,\Sigma(ab,j-1) + ab = \Sigma(ab,j) \ge c .$$
$\square$

**Theorem 8.5 (Exact asymmetric capacity).** For $a, b \ge 1$ and every $s$,
$$\max\{\,N : \exists G,\; |G| = s,\; G \text{ is an } (a,b)\text{-localiser of } [1,N]\,\} \;=\; \Sigma(ab, s).$$

**Theorem 8.6 (Asymmetric rigidity).** If $|G| = s$ and $G$ is an $(a,b)$-localiser of $[1, \Sigma(ab,s)]$, then $G = \mathcal{A}(a,b,s)$.

*Proof sketch.* As in Theorem 6.7, the peeling chain $N \le aM \le a(bN'+b) \le ab\Sigma(ab,s-1) + ab = N$ collapses to equalities, forcing $N' = \Sigma(ab,s-1)$ and $M = b(\Sigma(ab,s-1)+1)$; the induction hypothesis identifies the rest, and $\mathcal{A}(a,b,s) = \mathcal{A}(a,b,s-1) \cup \{ b(\Sigma(ab,s-1)+1)\}$. $\square$

**Theorem 8.7 (Product law).** Let $a,b,a',b' \ge 1$ with $ab = a'b'$. Then for every $s$ the sets of achievable ranges coincide:
$$\{N : \exists G,\, |G| = s,\, G \text{ an } (a,b)\text{-localiser of } [1,N]\} \;=\; \{N : \exists G,\, |G| = s,\, G \text{ an } (a',b')\text{-localiser of } [1,N]\}.$$

*Proof sketch.* Both sets are the initial segment $[0, \Sigma(ab,s)] = [0, \Sigma(a'b',s)]$: membership is bounded above by Theorem 8.2, and every $N$ below the capacity is achieved by the corresponding asymmetric grid, since localisation of a range restricts to any subrange. $\square$

The capacity of a sweep therefore depends on its two tolerance factors *only through their product*. Tolerance is a single scalar currency, freely tradeable between the undershoot and overshoot sides.

**Corollary 8.8 (The two earlier theorems are instances).** Taking $(a,b) = (1,r)$ recovers Theorem 6.5 with capacity $\Sigma(r,s)$ and $\mathcal{A}(1,r,s) = \mathcal{G}(r,s)$; taking $(a,b) = (r,r)$ recovers Theorem 7.1 with capacity $\Sigma(r^2,s)$ and $\mathcal{A}(r,r,s) = \mathcal{T}(r,s)$. The identity $\mathcal{A}(1,r,s) = \mathcal{G}(r,s)$ is the recurrence $r(\Sigma(r,j)+1) = \Sigma(r,j+1)$.

**Corollary 8.9 (The tolerance trade, measured instance).** With four sample points:
$$\text{tolerance } (1,2): [1,30], \qquad \text{tolerance } (2,2): [1,340], \qquad \text{tolerance } (1,4): [1,340].$$
Doubling the one-sided tolerance is worth exactly as much as symmetrising it; the product $ab = 4$ is all that matters. An experimenter who must never under-provision loses nothing in resolution relative to a two-sided sweep at tolerance $r$, provided she is willing to overshoot by $r^2$.

---

## 9. Algorithms

The theory is entirely constructive, and yields four short algorithms.

**(A1) Sweep reading and its exactness certificate.** Given a monotone curve sampled on a grid $G$ and a gate $g$, the reading is the least $k \in G$ with $A(k) \ge g$; by Theorem 3.1 it equals the least grid point at or above the true knee, and by Proposition 3.5 the true knee lies in the half-open cell $(\text{previous grid point}, \text{reading}]$. Sorting $G$ and scanning costs $O(|G| \log |G|)$; the returned cell is the *sharpest possible* statement about the truth given the data.

**(B) Optimal grid construction.** Given tolerances $a, b \ge 1$ and a target range $N$, compute the minimal point count $s$ as the least $s$ with $N \le \Sigma(ab,s)$ (equivalently $s = \lceil \log_{ab}(1 + N(ab-1)/ab) \rceil$ for $ab \ge 2$; $s = N$ for $ab = 1$), then emit $\mathcal{A}(a,b,s) = \{b(\Sigma(ab,j)+1) : j < s\}$. Cost: $O(s)$ arithmetic operations, and $s = O(\log_{ab} N)$. By Theorems 8.5 and 8.6 the output is optimal, and uniquely so when $N$ equals the capacity.

**(C) Replication certificate.** Given a sampled curve, a gate, and the reported knee $k$, compute
$$\varepsilon^\* = \min\Big( A(k) - g,\; \min_{j<k}\,\big(g - A(j)\big) \Big) \big/ 1,$$
and report that every curve uniformly within any $\varepsilon < \varepsilon^\*$ of $A$ has knee exactly $k$ (Theorem 4.1). Cost: linear in the number of samples. For the measured row, $\varepsilon^\* = \min(0.0032, 0.0010) = 0.0010$, so $\varepsilon = 0.0009$ certifies.

**(D) Exhaustive capacity verification.** For small $r, s, N$ one can confirm the capacity theorems by brute force: enumerate all $s$-subsets of $[1, N_{\max}]$ and test localisation directly. This independently reproduces $\Sigma(2,3) = 14$ with unique optimum $\{2,6,14\}$, and $\Sigma(2\cdot 2, 2) = 20$ with unique optimum $\{2,10\}$. Cost is $\binom{N_{\max}}{s} \cdot O(sN)$ and is feasible only for toy parameters — which is precisely why the closed form matters.

---

## 10. Discussion

### 10.1 Methodological consequences

The factorisation theorem is a warning about a very common experimental design. Whenever a threshold is estimated by sampling a monotone response on a grid, the estimate is the ceiling of the truth in the grid, and *only* that. It follows that:

* Comparisons across studies are meaningful only at equal grid resolution. A coarse reading on one dataset and a fine reading on another are incomparable; their difference is bounded below by nothing and above by the coarse cell width.
* A disagreement between a coarse and a fine sweep is always resolved in favour of the fine one (Corollary 3.4), and needs no substantive explanation.
* Reporting the *bracketing cell* $(\text{last failing sample}, \text{first passing sample}]$ rather than a point estimate is strictly more informative and costs nothing.
* Reporting the *margins* at the bracketing samples converts a point measurement into a replication guarantee with an explicit tolerance (Theorem 4.1) — and Theorem 4.4 shows nothing weaker will do.

### 10.2 Design consequences

The capacity theory answers the question an experimenter actually faces: *how many sample points do I need, and where do I put them?* The answers are exact and cheap to compute: capacity $\Sigma(ab,s)$, minimal point count the least $s$ clearing $N$, optimal placement $\{b(\Sigma(ab,j)+1)\}$, uniqueness at capacity. Three points deserve emphasis.

*Offsetting matters.* The reflexive choice $\{1, r, r^2, \dots\}$ is not merely suboptimal but structurally excluded for $r \ge 2$ (Corollary 6.8), because sampling the very bottom of the range wastes a point whose reach is only $[1,r]$. The optimal grid instead places each point at the top of its interval.

*Starting high is worse.* The grid used in the motivating experiment, $\{8,16,32,64\}$, is blind at the budget $3$: it does not even localise $[1,30]$, which four well-placed points do. Its capacity failure is at the *bottom* of the range, exactly where a doubling sweep started high has no coverage.

*The deployment constraint is cheap.* By Theorem 7.3 it costs a factor two in points, and by Corollary 8.9 it can be bought back exactly by squaring the overshoot tolerance. Both statements are sharp.

### 10.3 Scope and limitations

The theory assumes monotonicity of the quality curve. Real sweeps are noisy and only approximately monotone; the honest reading of the results is that they describe the *deterministic core* of the estimation problem, with noise handled separately through the margin machinery of §4 — indeed Theorem 4.1 can be read as a noise-robustness statement, with $\varepsilon$ the sup-norm noise level.

The capacity theorems are stated for integer tolerances $a, b$ and integer budgets. The multiplicative structure suggests real-valued analogues with $\Sigma$ replaced by a real geometric sum; the peeling argument uses $\lfloor (M-1)/b \rfloor$ and would need a corresponding real-valued adjustment.

Finally, the empirical claims are about one model family, one gate ($0.98$), three contexts, and two text corpora. The trichotomy of §5 constrains the attention profile qualitatively, not quantitatively; identifying the actual profile family whose knee grows like $4\log_2 \mathrm{ctx} - 20$ is open.

---

## 11. Future directions

1. **Domain-jump corpora.** The replication established here is across two shards of the same textual domain. The margin machinery predicts replication whenever curves are uniformly $0.0009$-close; testing code and mathematics corpora would probe whether the chain is a property of the architecture or of the text distribution.
2. **Larger models and quantised offload.** Extending the fine-grid chain to larger parameter counts, and to a quantised-offload configuration, would test whether the slope of $4$ keys per context doubling is model-size dependent.
3. **Real-valued and continuous capacity.** Extend Theorems 8.5–8.7 to real tolerances and continuous budget ranges, where the expected answer is a geometric-sum formula in $ab$ with the offset replaced by a limit.
4. **Adaptive (sequential) sweeps.** All results here concern *non-adaptive* grids fixed in advance. A sequential sweep that chooses its next budget after seeing the previous answers is a bisection and needs $\Theta(\log N)$ points to localise exactly; quantifying the exact adaptive/non-adaptive gap at tolerance $(a,b)$ is open.
5. **Noisy capacity.** Combine §4 and §8: what is the capacity of $s$ points when each evaluation returns the curve value corrupted by noise bounded by $\varepsilon$, and one demands the reported knee be within a factor $r$ with certainty?
6. **Profile identification.** Characterise the families of attention profiles whose knee grows logarithmically in the context, filling the gap between the excluded Zipf and geometric extremes.

---

## 12. Summary of principal results

| Result | Statement |
|---|---|
| Factorisation | A sweep reports the least grid point at or above the true knee — nothing else about the curve is visible. |
| Exactness criterion | The reading equals the knee iff the knee is a sampled budget. |
| Doubling bound | On a doubling grid, the reading is $< 2k^\*$. |
| Underdetermination | Curves agreeing on a grid can have any knees within one cell, so cross-grid comparisons carry no information. |
| Measured verdict | One curve with true knee $24$ yields a fine reading of $24$ and a coarse reading of $32$: the reported corpus disagreement is a grid artifact. |
| Replication law | Uniform $\varepsilon$-closeness plus margins $> \varepsilon$ forces equal knees; $\varepsilon = 0.0009$ certifies the measured cell. |
| Margin necessity | Without margins, $\varepsilon$-close curves can have knees $1$ and $N$. |
| Scale invariance | Knees of retention curves are invariant under positive rescaling: accuracy level and knee position are independent. |
| Logarithmic law | $k^\*(\mathrm{ctx}) = 4\log_2\mathrm{ctx} - 20$, with the third cell forced by the first two and falsifiable. |
| Profile trichotomy | Zipf is too dear (knee $> 32$ at context $2048$, unbounded in general); truncated geometric is context-free with knee $6$; the measured chain is neither. |
| Sweep capacity | $s$ points at one-sided tolerance $r$ localise exactly $[1, \Sigma(r,s)]$, uniquely via the offset geometric grid. |
| Two-sided capacity | $s$ points at two-sided tolerance $r$ localise exactly $[1, \Sigma(r^2,s)]$, uniquely. |
| Price of safety | $\Sigma(r,2s-1) < \Sigma(r^2,s) < \Sigma(r,2s)$: never under-provisioning costs a factor two in points, no more. |
| Product law | Asymmetric capacity is $\Sigma(ab,s)$ with a unique optimal grid; only the product $ab$ matters. Four points: $(1,2) \to 30$, $(2,2) \to 340$, $(1,4) \to 340$. |
