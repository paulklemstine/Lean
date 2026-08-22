# The Width Criterion for Chained Integer Labels: Exact Collapse Counts, a Signed Data-Processing Law, and a Two-Sided Collapse Ceiling

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

Experimental and statistical pipelines routinely encode a pair of discrete codes $(a,b)$ as a single integer *chained label* $\pi_M(a,b) = aM + b$ for a fixed decimal *frame* $M$. We prove that this encoding is injective on $\{0,\dots,A-1\}\times\{0,\dots,B-1\}$ if and only if $B \le M$, and that when the frame is narrow the failure is structural rather than data-dependent: an explicit collision exists for every population with at least two outer codes. For a narrow frame $M \le B$ we determine the image exactly — it is the unbroken integer interval $[0,\,M(A-1)+B)$ — so the number of distinct labels reported is exactly $M(A-1)+B$ against $A\cdot B$ genuine pairs, strictly fewer whenever $M<B$ and $A \ge 2$. Specialising to a $4\times 9$ code population and the frame $M=3$ gives the arithmetic signature $36 \mapsto 18$: exactly half the classes are silently merged.

We then develop, from first principles, an entropy-deficit calculus for finitely supported nonnegative weights, in bits, under the convention $0\log_2 0 = 0$. The deficit of a block is $D_s(w) = \sum_{i\in s} w_i\bigl(\log_2 S - \log_2 w_i\bigr)$ with $S = \sum_{i \in s} w_i$; it is nonnegative (merging destroys entropy), strictly positive whenever two atoms of the block carry positive mass, bounded above by $S\log_2|s|$ with equality for the uniform block, and *superadditive* under splitting — a deficit form of the concavity of entropy. As a by-product we record an explicit counterexample showing that Gibbs' inequality genuinely fails under the $0\log 0 = 0$ convention if the absolute-continuity hypothesis is dropped.

From this calculus we obtain the two structural theorems that adjudicate a disputed measurement. **Encoding invariance:** any injective relabelling of one coordinate leaves the mutual information of a joint weight unchanged, so two width-valid implementations must agree exactly. **Data-processing:** an arbitrary relabelling can only *decrease* mutual information, so collision artifacts are one-sided. Combining them, on a fixed population a width-valid reading dominates every other reading; a disagreement can therefore only be resolved in favour of the width-valid one.

Finally we give the converse, quantitative side — a **collapse ceiling**. If no label collects more than $k$ classes, the label entropy destroyed and the mutual information destroyed are each at most $\log_2 k$; a two-to-one merge costs at most one bit; a drop exceeding one bit *proves* the existence of a label collecting at least three classes; and, sharpest of all, the mutual information destroyed never exceeds the label entropy destroyed. These bounds convert the informal programme lesson "width-check chained encodings" into a falsifiable audit protocol with a two-sided error bar, executable on a printed results table without access to the underlying data.

**Keywords:** chained integer encoding, mixed radix, label collision, Shannon entropy, entropy deficit, Gibbs' inequality, data-processing inequality, mutual information, reproducibility audit.

---

## 1. Introduction

### 1.1 The disputed measurement

A joint-channel measurement on a fixed population of paired discrete codes was reported twice. The original analysis reported $36$ distinct joint labels, a label entropy of $4.6006$ bits, and a mutual information of $2.1314$ bits, with per-coordinate marginals of $1.0012$ bits each. A later rebuild of the same analysis on the same population reported $18$ distinct joint labels, a label entropy of $3.6073$ bits, and a mutual information of $0.5830$ bits.

The two constructions differed in exactly one respect that anybody had documented: the arithmetic frame used to chain the two component codes into a single integer. The original used $\pi(a,b) = a\cdot 10000 + b$; the rebuild used a $\cdot 10$ frame for the inner code nested inside a $\cdot 100$ frame for a six-valued outer code.

The question this paper answers is not "which run should we trust?" — that is a sociological question — but the mathematical question underneath it: *given only the encodings, and no access to either run's data, is one of the two readings necessarily wrong, and in which direction?*

We show the answer is yes, and that it decomposes into three independent pieces:

1. **Arithmetic** (§2): when does chaining lose classes, and exactly how many?
2. **Entropy calculus** (§3): what does losing classes do to entropy, in a form strong enough to survive being pushed through a joint distribution?
3. **Adjudication** (§4–§5): a signed one-sided law that says which reading is the artifact, plus a two-sided ceiling that says how large a discrepancy the artifact can legitimately explain.

### 1.2 Why this is not merely a bug report

Chaining is ubiquitous: contingency-table strata, group-by keys, sparse index arithmetic, feature hashing, and every ad-hoc "combine two categorical variables into one" idiom in applied statistics. The failure mode has three properties that make it unusually dangerous:

* **Silent.** No exception, no warning; the pipeline computes a perfectly well-defined statistic of a *coarsened* population.
* **Deterministic and reproducible.** Re-running the buggy code reproduces the buggy number exactly, so reproducibility checks do not detect it.
* **Conservative-looking.** By Theorem 5.2 below, merging can only lower measured information. The corrupted reading looks like a cautious reanalysis, which is exactly what reviewers expect a careful replication to produce.

The last property is why a *signed* theorem is worth having. Knowing the direction of the bias converts a stalemate into a verdict.

---

## 2. The arithmetic of chained labels

### 2.1 Definitions

**Definition 2.1 (Chained label).** For a frame $M \in \mathbb{N}$ and codes $a, b \in \mathbb{N}$, the *chained label* is
$$\pi_M(a,b) \;=\; a\,M + b .$$
We call $a$ the *outer code* and $b$ the *inner code*, and $M$ the *frame*. The *code population* with alphabet sizes $A, B$ is the set $P_{A,B} = \{0,\dots,A-1\}\times\{0,\dots,B-1\}$, of cardinality $A\cdot B$.

**Definition 2.2 (Width validity).** The frame $M$ is *width-valid* for an inner alphabet of size $B$ if $B \le M$.

### 2.2 Injectivity is exactly width validity

**Theorem 2.3 (Width criterion, sufficiency).** If $b < M$ and $b' < M$ and $aM + b = a'M + b'$, then $a = a'$ and $b = b'$.

*Proof.* From $b < M$ we get $M > 0$. Division with remainder is the decoder: $(aM+b)\,/\,M = a$ because $b/M = 0$, and likewise $(a'M+b')/M = a'$. Hence $a = a'$ from the equality of the labels, and then $b = b'$ by cancellation. $\square$

**Corollary 2.4.** If $B \le M$, the map $(a,b) \mapsto \pi_M(a,b)$ is injective on $P_{A,B}$ for every $A$.

**Theorem 2.5 (Narrow frames always collide).** Let $M < B$ and $A \ge 2$. Then there exist two *distinct* pairs in $P_{A,B}$ with the same chained label; explicitly, $(0,M) \ne (1,0)$ and
$$\pi_M(0,M) \;=\; M \;=\; \pi_M(1,0).$$

*Proof.* Both pairs lie in $P_{A,B}$: $M < B$ makes $(0,M)$ admissible and $A \ge 2$ makes $(1,0)$ admissible. Evaluating $\pi_M$ gives $M$ in both cases. $\square$

The pair of theorems combines into an exact characterisation, which is the criterion an audit should implement.

**Theorem 2.6 (Width validity $=$ no collisions).** Fix $A \ge 2$ and $B$. Then $B \le M$ **if and only if** for all admissible $(a,b), (a',b') \in P_{A,B}$, $\pi_M(a,b) = \pi_M(a',b')$ implies $(a,b) = (a',b')$.

*Proof.* Forward: Theorem 2.3. Backward: contrapositive via Theorem 2.5 — if $M < B$ then an explicit collision exists, contradicting injectivity. $\square$

The content of Theorem 2.6 is that the check `inner_alphabet_size <= frame` is neither conservative nor optimistic: it is *equivalent* to correctness of the encoding. A pipeline that passes it cannot exhibit this bug; one that fails it certainly does, on every nonempty population with two outer codes.

### 2.3 Exact label counts

**Theorem 2.7 (Wide frame preserves all classes).** If $B \le M$ then
$$\bigl|\pi_M(P_{A,B})\bigr| \;=\; A\cdot B .$$

*Proof.* Immediate from Corollary 2.4: an injective image of a finite set has the same cardinality. $\square$

**Theorem 2.8 (The narrow image is an interval).** If $M \le B$ and $A \ge 1$ then
$$\pi_M(P_{A,B}) \;=\; \{0,1,\dots,\,M(A-1)+B-1\}.$$

*Proof.* ($\subseteq$) For $a \le A-1$ and $b < B$ we have $aM + b \le (A-1)M + b < M(A-1) + B$.

($\supseteq$) Let $n < M(A-1)+B$. Two cases.

*Case $n < M(A-1)$.* Then $M > 0$ (otherwise the bound is vacuous), and we take $a = \lfloor n/M \rfloor$, $b = n \bmod M$. Then $a < A-1$ because $n < M(A-1)$, and $b < M \le B$, and $aM+b = n$ by division with remainder.

*Case $n \ge M(A-1)$.* Take $a = A-1$ and $b = n - M(A-1)$. Then $0 \le b < B$ by the two bounds on $n$, and $aM + b = M(A-1) + n - M(A-1) = n$. $\square$

Geometrically: outer value $a$ contributes the *strip* $[aM,\,aM+B)$ of labels. Consecutive strips are offset by $M$ but have length $B \ge M$, so they overlap like roof shingles and their union is a single unbroken run.

**Corollary 2.9 (Exact narrow-frame label count).** If $M \le B$ and $A \ge 1$,
$$\bigl|\pi_M(P_{A,B})\bigr| \;=\; M(A-1) + B .$$

**Theorem 2.10 (Strict loss).** If $M < B$ and $A \ge 2$ then $M(A-1) + B < A\cdot B$.

*Proof.* Since $M \le B-1$, we have $M(A-1) \le (B-1)(A-1)$, hence
$$M(A-1) + B \;\le\; (B-1)(A-1) + B \;=\; B(A-1) - (A-1) + B \;=\; AB - (A-1) \;<\; AB$$
because $A \ge 2$. $\square$

### 2.4 The audited instance

**Corollary 2.11.** On the population $P_{4,9}$ of $36$ pairs:

* the width-valid frame $M = 10000$ reports $4 \times 9 = 36$ labels;
* the narrow frame $M = 3$ reports $3\cdot(4-1) + 9 = 18$ labels;
* hence exactly $2\cdot 18 = 36$: the narrow frame reports precisely **half** the classes.

This $36 \mapsto 18$ signature — half the classes, arising from a frame narrower than the inner alphabet — is the arithmetic fingerprint of the retracted reading. Note that it is *derived*, not simulated: Corollary 2.9 is proved for all $(A,B,M)$ with $M \le B$, and the instance is a substitution.

### 2.5 Multi-field chaining

The criterion iterates. Chaining $r$ dials as $\sum_{i=1}^{r} a_i M_i$ with $M_1 = 1$ is injective on $\prod_i \{0,\dots,A_i-1\}$ precisely when the mixed-radix condition
$$M_{i+1} \;\ge\; A_i\,M_i \qquad (1 \le i < r)$$
holds, since each nested chaining must be width-valid with respect to the *combined* alphabet of everything below it. The failure documented in §1.1 is the smallest interesting instance: a $\cdot 10$ frame nested inside a $\cdot 100$ frame, with an inner combined alphabet larger than $10$.

---

## 3. An entropy-deficit calculus

Section 2 counts classes. To reason about *bits* we need entropy for finitely supported nonnegative weight functions — not necessarily normalised, since fibers of a labelling carry sub-unit mass — with the convention that empty atoms contribute nothing.

### 3.1 Definitions

**Definition 3.1.** For $t \in \mathbb{R}$ put $\eta(t) = -\,t\log_2 t$, with $\eta(0) = 0$. For a finite index set $s$ and a weight function $w$, the *entropy in bits* is
$$H_s(w) \;=\; \sum_{i \in s} \eta(w_i),$$
and the *deficit* of the block $s$ — the entropy destroyed by collapsing all of $s$ into a single atom of mass $\sum_{i\in s} w_i$ — is
$$D_s(w) \;=\; H_s(w) \;-\; \eta\!\Bigl(\sum_{i \in s} w_i\Bigr).$$

**Lemma 3.2 (Closed form).** For any weight function $w$ and finite $s$, with $S = \sum_{j \in s} w_j$,
$$D_s(w) \;=\; \sum_{i \in s} w_i \bigl(\log_2 S - \log_2 w_i\bigr).$$

*Proof.* Purely algebraic: $S\log_2 S = \sum_{i\in s} w_i \log_2 S$ by distributing the sum, and then
$D_s(w) = -\sum_i w_i\log_2 w_i + \sum_i w_i \log_2 S$. No positivity is used. $\square$

The closed form is the workhorse: it exhibits the deficit as a *relative-entropy-like* sum of per-atom terms $w_i\log_2(S/w_i)$.

### 3.2 Merging destroys entropy

**Theorem 3.3 (Nonnegativity of the deficit).** If $w_i \ge 0$ for all $i \in s$, then $D_s(w) \ge 0$; equivalently $\eta\bigl(\sum_{i\in s} w_i\bigr) \le H_s(w)$.

*Proof.* By Lemma 3.2 it suffices that each term is nonnegative. If $w_i = 0$ the term vanishes. If $w_i > 0$ then $w_i \le S$ (a single atom cannot exceed the total of a nonnegative block), so $\log_2 w_i \le \log_2 S$ and the term $w_i(\log_2 S - \log_2 w_i)$ is a product of nonnegatives. $\square$

**Theorem 3.4 (Strict loss).** Suppose $w \ge 0$ on $s$ and there are distinct $i, j \in s$ with $w_i > 0$ and $w_j > 0$. Then $D_s(w) > 0$.

*Proof.* Now $S \ge w_i + w_j > w_i$, so $\log_2 w_i < \log_2 S$ strictly and the $i$-th term of Lemma 3.2 is strictly positive; the remaining terms are nonnegative by the proof of Theorem 3.3. $\square$

So merging does not merely fail to increase entropy: whenever a merged block genuinely contains two populated classes, entropy strictly falls.

### 3.3 Gibbs' inequality and a necessary hypothesis

**Theorem 3.5 (Unnormalised Gibbs, base 2).** Let $a, b \ge 0$ on a finite $s$ with (i) *absolute continuity*: $b_i = 0 \Rightarrow a_i = 0$, and (ii) $\sum_i b_i \le \sum_i a_i$. Then
$$\sum_{i \in s} a_i\bigl(\log_2 a_i - \log_2 b_i\bigr) \;\ge\; 0 .$$

*Proof.* Per term, from $\log x \le x - 1$: for $a_i > 0$ (whence $b_i > 0$ by absolute continuity), $\log(b_i/a_i) \le b_i/a_i - 1$, so $a_i(\log a_i - \log b_i) \ge a_i - b_i$; dividing by $\log 2 > 0$ gives $a_i(\log_2 a_i - \log_2 b_i) \ge (a_i-b_i)/\log 2$, and for $a_i = 0$ the left side is $0 \ge -b_i/\log 2$. Summing, the right side telescopes to $\bigl(\sum a_i - \sum b_i\bigr)/\log 2 \ge 0$. $\square$

**Theorem 3.6 (Absolute continuity is necessary).** Under the convention $\log_2 0 = 0$, hypothesis (i) cannot be dropped. Take $s = \{0,1\}$, $a = (\tfrac12, \tfrac12)$ and $b = (1, 0)$. Then $a, b \ge 0$ and $\sum b = \sum a = 1$, but
$$\sum_i a_i(\log_2 a_i - \log_2 b_i) \;=\; \tfrac12(-1 - 0) + \tfrac12(-1 - 0) \;=\; -1 \;<\; 0 .$$

This is a genuine trap for implementations: the convenient convention $0\log 0 = 0$ silently converts an infinite penalty into zero penalty, and the "obvious" nonnegativity of relative entropy becomes false. Every use of Gibbs below is discharged with an explicit absolute-continuity argument.

### 3.4 Concavity in deficit form

The engine of the data-processing inequality is the following superadditivity statement, which is exactly the concavity of entropy rewritten in terms of deficits.

**Theorem 3.7 (Superadditivity of the deficit).** Let $\{v^{(y)}\}_{y \in t}$ be a finite family of nonnegative weight functions on $s$, and let $w = \sum_{y\in t} v^{(y)}$ pointwise. Then
$$\sum_{y \in t} D_s\bigl(v^{(y)}\bigr) \;\le\; D_s(w).$$

*Proof sketch.* If the total mass $W = \sum_{x\in s} w_x$ is zero, all weights vanish and both sides are $0$. Otherwise write $V_y = \sum_{x\in s} v^{(y)}_x$ and compare each piece against the *tilted* measure $b^{(y)}_x = w_x V_y / W$, which has the same total mass $V_y$ as $v^{(y)}$ and is absolutely continuous with respect to it in the required direction. Gibbs (Theorem 3.5) gives
$$0 \;\le\; \sum_{x\in s} v^{(y)}_x\bigl(\log_2 v^{(y)}_x - \log_2 b^{(y)}_x\bigr),$$
and expanding $\log_2 b^{(y)}_x = \log_2 w_x + \log_2 V_y - \log_2 W$ turns the right-hand side into exactly
$$\sum_{x\in s} v^{(y)}_x\Bigl[\bigl(\log_2 W - \log_2 w_x\bigr) - \bigl(\log_2 V_y - \log_2 v^{(y)}_x\bigr)\Bigr].$$
Summing over $y \in t$ and using $\sum_y v^{(y)}_x = w_x$, the first bracket sums to $D_s(w)$ in closed form (Lemma 3.2) and the second to $\sum_y D_s(v^{(y)})$. $\square$

### 3.5 The maximum-entropy ceiling on a block

**Theorem 3.8 (Deficit ceiling).** For nonnegative $w$ on a finite block $s$ with total mass $S$,
$$D_s(w) \;\le\; S\,\log_2 |s| .$$

*Proof sketch.* For $S=0$ both sides vanish. For $S>0$ compare $w$ against the uniform weight $u_i = S/|s|$ on $s$, which has the same total mass; Gibbs (Theorem 3.5) gives $\sum_i w_i(\log_2 w_i - \log_2 u_i) \ge 0$, i.e. $-\sum_i w_i \log_2 w_i \le -S\log_2(S/|s|)$, which rearranges into $D_s(w) \le S \log_2 |s|$. $\square$

**Theorem 3.9 (The ceiling is attained).** For a nonempty block $s$ and the uniform weight $w_i = 1/|s|$,
$$D_s(w) \;=\; \log_2 |s| .$$

*Proof.* $S = 1$, so each term of Lemma 3.2 is $\tfrac{1}{|s|}\bigl(0 - \log_2 \tfrac{1}{|s|}\bigr) = \tfrac{1}{|s|}\log_2 |s|$, and there are $|s|$ of them. $\square$

So no better constant than $\log_2 |s|$ is available: the ceiling of §5 is sharp in the worst case.

---

## 4. Labellings, pushforwards, and the two structural theorems

### 4.1 Setup

Let $\alpha, \beta, \alpha'$ be finite types. A *labelling* is a map $f : \alpha \to \alpha'$; its *fiber* over $u \in \alpha'$ is $f^{-1}(u) \subseteq \alpha$. For a weight $p$ on $\alpha$ the *pushforward* is
$$(f_* p)(u) \;=\; \sum_{x \in f^{-1}(u)} p(x),$$
and for a joint weight $p$ on $\alpha \times \beta$ we relabel only the first coordinate:
$$(f_\sharp p)(u, y) \;=\; \sum_{x \in f^{-1}(u)} p(x,y).$$
The marginals are $p_1(x) = \sum_y p(x,y)$ and $p_2(y) = \sum_x p(x,y)$, and the *mutual information* in bits is
$$I(p) \;=\; H(p_1) + H(p_2) - H(p).$$

Two elementary identities will be used repeatedly:
$$(f_\sharp p)_1 = f_*(p_1), \qquad (f_\sharp p)_2 = p_2 . \tag{4.1}$$
The first is a reordering of a double sum; the second says that relabelling the first coordinate does not touch the second marginal.

### 4.2 The exact entropy loss of a labelling

**Theorem 4.1 (Loss $=$ total fiber deficit).** For any labelling $f$ and any weight $p$ on $\alpha$,
$$H(p) - H(f_* p) \;=\; \sum_{u \in \alpha'} D_{f^{-1}(u)}(p).$$

*Proof.* The fibers partition $\alpha$, so $H(p) = \sum_u H_{f^{-1}(u)}(p)$. By definition $H(f_*p) = \sum_u \eta\bigl(\sum_{x \in f^{-1}(u)} p(x)\bigr)$. Subtract termwise and apply Definition 3.1. $\square$

**Corollary 4.2 (Labelling cannot create entropy).** If $p \ge 0$ then $H(f_*p) \le H(p)$, by Theorem 3.3.

**Corollary 4.3 (Injective labellings are lossless).** If $f$ is injective, every fiber has at most one element and hence zero deficit, so $H(f_*p) = H(p)$ for every $p$.

The joint version of Theorem 4.1, obtained by slicing over $y \in \beta$, reads
$$H(p) - H(f_\sharp p) \;=\; \sum_{u \in \alpha'}\ \sum_{y \in \beta} D_{f^{-1}(u)}\bigl(p(\cdot, y)\bigr). \tag{4.2}$$

### 4.3 Encoding invariance

**Theorem 4.4 (Encoding invariance).** If $f : \alpha \to \alpha'$ is injective, then for every joint weight $p$ on $\alpha\times\beta$,
$$I(f_\sharp p) \;=\; I(p).$$

*Proof.* By (4.1) and Corollary 4.3, $H\bigl((f_\sharp p)_1\bigr) = H(f_* p_1) = H(p_1)$ and $H\bigl((f_\sharp p)_2\bigr) = H(p_2)$. By (4.2) with all fiber deficits zero, $H(f_\sharp p) = H(p)$. Substituting into the definition of $I$ gives the claim. $\square$

*Interpretation.* A width-valid chained encoding is injective (Corollary 2.4), so mutual information is *notation-independent*: two clean implementations that both satisfy the width criterion are evaluating the same functional of the same data and must agree bit-for-bit. Exact agreement between two independent width-valid pipelines is therefore evidence of correctness, and *approximate* agreement between two allegedly-exact pipelines is itself an anomaly.

### 4.4 The signed data-processing inequality

**Theorem 4.5 (Data-processing for label coarsenings).** For any labelling $f$ (injective or not) and any nonnegative joint weight $p$,
$$I(f_\sharp p) \;\le\; I(p).$$

*Proof.* By (4.1) the second marginal is untouched, so $H\bigl((f_\sharp p)_2\bigr) = H(p_2)$ cancels and
$$I(p) - I(f_\sharp p) \;=\; \underbrace{\bigl[H(p_1) - H(f_* p_1)\bigr]}_{\text{marginal loss}} \;-\; \underbrace{\bigl[H(p) - H(f_\sharp p)\bigr]}_{\text{joint loss}} . \tag{4.3}$$
By Theorem 4.1 the marginal loss equals $\sum_u D_{f^{-1}(u)}(p_1)$, and by (4.2) the joint loss equals $\sum_u \sum_y D_{f^{-1}(u)}\bigl(p(\cdot,y)\bigr)$. Since $p_1 = \sum_{y} p(\cdot,y)$ pointwise, superadditivity of the deficit (Theorem 3.7), applied on each fiber to the family indexed by $y \in \beta$, gives
$$\sum_{y\in\beta} D_{f^{-1}(u)}\bigl(p(\cdot,y)\bigr) \;\le\; D_{f^{-1}(u)}(p_1) \qquad (u \in \alpha').$$
Summing over $u$ shows joint loss $\le$ marginal loss, so the right-hand side of (4.3) is nonnegative. $\square$

**Theorem 4.6 (The reconciliation).** Let $p \ge 0$ be a joint weight on $\alpha \times \beta$, let $f$ be injective (width-valid) and let $g$ be arbitrary. Then
$$I(g_\sharp p) \;\le\; I(f_\sharp p).$$

*Proof.* $I(f_\sharp p) = I(p)$ by Theorem 4.4, and $I(g_\sharp p) \le I(p)$ by Theorem 4.5. $\square$

**Corollary 4.7 (Verdict rule).** If two analyses of the *same* population differ only in their label encoding, and one of the encodings is width-valid, then the larger reported mutual information is the admissible one and the smaller is an artifact. Collision artifacts are *signed*: they can only deflate a measurement, never inflate it.

Applied to §1.1: the width-valid reading of $2.1314$ bits stands; the narrow-frame rebuild's smaller reading is the artifact.

### 4.5 Strictness on the audited population

Domination is an inequality; on the audited population it can be made strict with an explicit margin, using no data beyond the encoding.

**Theorem 4.8 (Strict loss on $P_{4,9}$).** Equip the $36$ pairs of $P_{4,9}$ with the uniform weight $1/36$. Then the width-valid chaining preserves the full label entropy,
$$H\bigl(\text{wide labels}\bigr) \;=\; \log_2 36 \;\approx\; 5.1699\ \text{bits},$$
while the narrow $\cdot 3$ chaining satisfies
$$H\bigl(\text{narrow labels}\bigr) \;\le\; \log_2 36 - \tfrac{1}{18} .$$
In particular the narrow reading is strictly below the wide one.

*Proof.* The wide statement is Corollary 4.3. For the narrow one, the pairs $(0,3)$ and $(1,0)$ both receive label $3$ under $\pi_3$ (Theorem 2.5 with $M=3 < 9 = B$). That fiber therefore contains two atoms of mass $1/36$ each; by Lemma 3.2 its deficit is at least $2 \cdot \tfrac{1}{36}\log_2\frac{2/36}{1/36} = \tfrac{1}{18}$ bit. By Theorem 4.1 the total loss is at least the loss of that single fiber. $\square$

---

## 5. The collapse ceiling: an error bar for the artifact

Theorem 4.6 fixes the *direction* of the discrepancy but not its *size*. Without an upper bound, "collisions did it" is unfalsifiable. This section supplies the missing side.

**Theorem 5.1 (Entropy collapse ceiling).** Let $p$ be a probability weight on $\alpha$ ($p \ge 0$, $\sum_x p(x) = 1$) and let $f$ be a labelling all of whose fibers have at most $k \ge 1$ elements. Then
$$H(p) - H(f_*p) \;\le\; \log_2 k .$$

*Proof.* By Theorem 4.1 the loss is $\sum_u D_{f^{-1}(u)}(p)$. By Theorem 3.8 each term is at most $m_u \log_2 |f^{-1}(u)| \le m_u \log_2 k$, where $m_u = \sum_{x \in f^{-1}(u)} p(x)$ is the mass of the fiber. Since labelling preserves total mass, $\sum_u m_u = 1$, and the bound follows. $\square$

**Theorem 5.2 (Information lost $\le$ label entropy lost).** For any labelling $f$ and any nonnegative joint weight $p$,
$$I(p) - I(f_\sharp p) \;\le\; H(p_1) - H(f_* p_1).$$

*Proof.* From the identity displayed in the proof of Theorem 4.5,
$$I(p) - I(f_\sharp p) = \bigl[H(p_1) - H(f_*p_1)\bigr] - \bigl[H(p) - H(f_\sharp p)\bigr],$$
and the joint loss $H(p)-H(f_\sharp p)$ is nonnegative by (4.2) and Theorem 3.3. $\square$

**Theorem 5.3 (Information collapse ceiling).** Let $p$ be a joint *probability* weight on $\alpha\times\beta$ and let every fiber of $f$ have at most $k \ge 1$ elements. Then
$$I(p) - I(f_\sharp p) \;\le\; \log_2 k .$$

*Proof.* Combine Theorem 5.2 with Theorem 5.1 applied to the first marginal $p_1$, which is a probability weight on $\alpha$. $\square$

**Corollary 5.4 (A two-to-one merge costs at most one bit).** If no label collects more than two classes, then $I(p) - I(f_\sharp p) \le 1$, whatever the size of $\alpha$, $\beta$, or the strength of the channel.

**Corollary 5.5 (Audit contrapositive).** If two readings of a probability population differ by more than one bit of mutual information and the difference is attributed to a label merge, then some label must collect at least three distinct classes. Pairwise merging *cannot* account for a drop exceeding one bit.

**Theorem 5.6 (Sandwich).** For a probability weight $p$ and a $k$-bounded labelling,
$$0 \;\le\; H(p) - H(f_*p) \;\le\; \log_2 k,$$
and by Theorem 3.9 the upper end is attained (a uniform $k$-atom fiber carrying all the mass loses exactly $\log_2 k$), so no smaller universal ceiling exists.

### 5.1 The audited population, quantitatively

Under the narrow $\cdot 3$ frame on $P_{4,9}$, direct inspection of the strips shows that no label collects more than three of the $36$ pairs; the maximal fibers are the three-element ones in the overlap region. Hence, by Theorem 5.3:

**Corollary 5.7.** For any probability weight on $P_{4,9}\times\beta$, the narrow-frame relabelling can destroy at most
$$\log_2 3 \;\approx\; 1.5850 \ \text{bits}$$
of mutual information, while the width-valid relabelling destroys exactly zero (Theorem 4.4).

---

## 6. The audit protocol

The theory above compiles into three checks. The first is *preventive* and costs nothing; the last two are *forensic* and can be run on a printed results table with no access to raw data.

**Check W (width).** Before running: for a chained key $\sum_i a_i M_i$ with $M_1 = 1$, verify $M_{i+1} \ge A_i M_i$ for every $i$, where $A_i$ is the alphabet size of dial $i$. By Theorem 2.6 this is *exactly* the no-collision condition — not a sufficient heuristic but an equivalence. If it fails, the predicted label count is $M(A-1)+B$ (Corollary 2.9) in the two-dial case, and the discrepancy against $A\cdot B$ tells you how many classes were merged.

**Check D (direction).** Given two readings of the same population that differ only in encoding, with one encoding width-valid: the width-valid reading dominates (Theorem 4.6). The smaller reading is the artifact. This is a verdict, not a preference.

**Check C (ceiling).** Given the maximal fiber size $k$ of the suspect encoding — computable from the encoding alone — the gap between the two readings must satisfy $\Delta I \le \log_2 k$ (Theorem 5.3), and additionally $\Delta I \le \Delta H$ where $\Delta H$ is the drop in label entropy (Theorem 5.2). A violation of either inequality *proves* that the two pipelines differ in something beyond the label encoding, and the investigation must continue.

### 6.1 Running the protocol on the disputed rows

| construction | frame | distinct labels | $H(\text{labels})$ | $I(\text{joint})$ |
|---|---|---|---|---|
| original | $a\cdot 10000 + b$ | $36$ | $4.6006$ | $2.1314$ |
| independent clean re-implementation | width-valid | $36$ | $4.6006$ | $2.1314$ |
| rebuild | nested $\cdot 10$ inside $\cdot 100$ | $18$ | $3.6073$ | $0.5830$ |

*Check W.* The rebuild's inner frame is narrower than the combined alphabet below it, so by Theorem 2.6 the encoding certainly collides; by Corollary 2.9 the collapsed class count is a determinate function of $(A,B,M)$, and the observed $36 \to 18$ is exactly the predicted $M(A-1)+B$ with $(A,B,M) = (4,9,3)$.

*Check D.* The original encoding is width-valid; the rebuild's is not; both act on the same population. Theorem 4.6 therefore places the rebuild's reading below the original's, and the original's $2.1314$ bits is the admissible value. The independent clean re-implementation reproduces $2.1314$ *exactly*, which is what Theorem 4.4 predicts for two width-valid encodings — exact agreement, not agreement to within noise.

*Check C.* The maximal fiber under the narrow frame is $3$, so the ceiling on the information drop is $\log_2 3 \approx 1.5850$ bits. The observed drop is $2.1314 - 0.5830 = 1.5484$ bits, which clears the ceiling with $0.0366$ bits of margin: the collision explanation is quantitatively admissible.

The second half of Check C is more informative, and we record it as a flag rather than a confirmation. The observed label-entropy drop is $4.6006 - 3.6073 = 0.9933$ bits, while the observed information drop is $1.5484$ bits. Theorem 5.2 forbids $\Delta I > \Delta H$ for a *single* coarsening of a fixed joint weight. The two rows therefore cannot differ only by one merge of the joint label: at least one further difference — a second compression stage, a different marginalisation, or a different population restriction — is present in the rebuild. This is exactly the intended use of the protocol: the ceiling confirms that collisions can explain the magnitude, while the sharp inequality localises a residual discrepancy that a re-run should target.

For calibration, the reported per-coordinate marginals are $1.0012$ bits each, summing to $2.0024$ against a joint value of $2.1314$; the excess of about $0.129$ bits is genuine synergy between the two dials, which is precisely the quantity that a class merge destroys first.

---

## 7. Algorithms

**Algorithm 1 (Width audit for a multi-field chained key).** Input: alphabet sizes $A_1,\dots,A_r$ and frames $M_1,\dots,M_r$ with $M_1 = 1$. Output: `VALID`, or the first violating index together with the predicted number of merged classes. Complexity: $O(r)$ integer operations. Correctness: Theorem 2.6 iterated.

**Algorithm 2 (Exact collapse count).** Input: $A$, $B$, $M$. Output: the number of distinct labels, namely $A\cdot B$ if $M \ge B$ and $M(A-1) + B$ otherwise. Complexity: $O(1)$. Correctness: Theorems 2.7 and Corollary 2.9. This is the lookup an experimenter should consult *before* running.

**Algorithm 3 (Fiber profile and collapse ceiling).** Input: $A$, $B$, $M$ with $M \le B$. Output: for each label $n < M(A-1)+B$, the fiber size $|\{a < A : 0 \le n - aM < B\}|$; hence the maximal fiber $k$ and the ceiling $\log_2 k$ on both the entropy and the information that the frame can destroy. Complexity: $O(AB)$ by direct enumeration, or $O(1)$ per label with the closed form $|\{a : \max(0,\lceil (n-B+1)/M\rceil) \le a \le \min(A-1, \lfloor n/M\rfloor)\}|$. Correctness: Theorems 5.1 and 5.3.

**Algorithm 4 (Forensic reconciliation of two readings).** Input: two rows $(\text{labels}, H, I)$ from the same population, plus the encodings. Output: a verdict (which reading is admissible) and a consistency report. Steps: run Algorithm 1 on each encoding; if exactly one is valid, the valid one's $I$ is admissible (Check D); compute $k$ via Algorithm 3 and test $\Delta I \le \log_2 k$ and $\Delta I \le \Delta H$; report any violation as evidence of an undocumented second difference between the pipelines. Complexity: dominated by Algorithm 3.

---

## 8. Discussion

### 8.1 What is genuinely new here

Each ingredient is individually classical — division with remainder, Gibbs' inequality, concavity of entropy, the data-processing inequality. What the present work contributes is their assembly into a *decision procedure for a disputed measurement*, together with three sharpenings that the classical statements do not supply directly:

1. **An exact, not asymptotic, collapse count.** $M(A-1)+B$ is the precise number of surviving classes, with the image identified as an unbroken interval (Theorem 2.8). Most treatments of hash collisions are probabilistic; here the structure is deterministic and fully resolved.
2. **A signed verdict rule.** Theorem 4.6 says a fixed population cannot be over-read by a bad encoding. This turns the usual "two runs disagree" stalemate into an ordering.
3. **A two-sided error bar with attainability.** Theorems 5.1–5.6 bound the damage by $\log_2 k$, and Theorem 3.9 shows the bound is achieved, so the audit test is as tight as any universal test can be.

The deficit calculus of §3 is also of independent use: it is a self-contained treatment of Shannon entropy for *unnormalised* finitely supported weights, which is the natural setting for fiberwise arguments, and it flags the absolute-continuity subtlety (Theorem 3.6) that the $0\log 0 = 0$ convention conceals.

### 8.2 Limitations

* The ceiling $\log_2 k$ uses only the *largest* fiber. The true loss is the mass-weighted average $\sum_u m_u \log_2 |f^{-1}(u)|$, which for a chained frame is an explicit arithmetic object (Algorithm 3). A sharper, profile-dependent ceiling is available and is the first item in §9.
* Theorem 4.6 compares two encodings of a *fixed* population. If two runs also differ in filtering, binning, or estimator, the verdict rule does not apply directly — though Theorem 5.2 will typically detect the difference, as it did in §6.1.
* Everything is stated for finite alphabets and exact (plug-in) entropies. Finite-sample estimation bias is a separate, well-studied source of discrepancy and is not modelled here; notably, plug-in mutual information is biased *upward* on small samples, in the opposite direction to a collision artifact, which makes the two failure modes distinguishable in principle.

### 8.3 Practical recommendations

Use a struct, a tuple, or a factorised index rather than a chained integer wherever the language permits. Where chaining is unavoidable — sparse indices, database keys, GPU kernels — compute frames from measured alphabet sizes rather than from decimal aesthetics ($10$, $100$, $10000$ are chosen for readability, and readability is not a correctness criterion), and assert the mixed-radix condition at pipeline entry. Log the distinct-label count alongside every joint statistic: a discrepancy against the product of the alphabet sizes is a zero-cost detector of exactly this bug.

---

## 9. Future directions

**Sharp collapse ceiling from the fiber profile.** The ceiling $\log_2 k$ uses only the largest fiber, whereas the true loss is the mass-weighted average $\sum_u m_u \log_2 |F_u|$, and for a chained frame the whole fiber profile is an explicit arithmetic object: under $M \le B$ the fiber over $n$ has size $|\{a < A : 0 \le n - Ma < B\}|$. Combining the per-fiber deficit bound with the exact label set yields a *closed formula* for the worst-case entropy loss of an $(A,B,M)$ frame — a lookup table an audit can consult before running an experiment.

**Reconstructibility: when is the true channel recoverable?** The data-processing inequality has a computable defect — the fiber deficits — so a coarsened reading together with the fiber profile bounds the true reading from *both* sides; for a $k$-bounded distortion the true value can be reconstructed from the collapsed one to within $\log_2 k$. Retracted rows currently have to be re-run from scratch; a reconstruction bracket would let a retracted number be repaired rather than discarded, at the cost of a widened error bar.

**Multi-dial chaining and a width calculus.** Chaining $r$ dials as $\sum_i a_i M_i$ is injective precisely under the mixed-radix condition $M_i \ge A_{i-1}M_{i-1}$ (with $M_1 = 1$), so width checking becomes a small calculus on frame vectors, with a canonical minimal-frame normal form and a notion of "slack" measuring how much headroom a key has before a new category breaks it.

**Estimator-level integration.** Combining the collapse ceiling with finite-sample bias bounds for plug-in entropy estimators would give a single interval within which two readings of one population must lie if they differ only by encoding and sampling — a complete forensic bracket.

---

## 10. Conclusion

A chained integer label $\pi_M(a,b) = aM+b$ is faithful if and only if the frame dominates the inner alphabet, $B \le M$; otherwise it collides, on every population with at least two outer codes, and reports exactly $M(A-1)+B$ classes in place of $A\cdot B$. On a $4\times 9$ population with $M=3$ this is $18$ in place of $36$ — half the classes, gone silently.

Merging classes destroys entropy (strictly, whenever two merged classes are populated) and can only *decrease* measured mutual information, while an injective re-encoding changes nothing at all. Hence, on a fixed population, a width-valid reading dominates every other reading: when two analyses disagree and one is width-valid, the larger value is the admissible one. And the damage is bounded: a $k$-bounded merge destroys at most $\log_2 k$ bits of label entropy and at most $\log_2 k$ bits of information, with the bound attained, so "collisions did it" is a falsifiable claim with an explicit error bar.

The lesson generalises beyond one disputed measurement: whenever discrete fields are packed into a single integer key, width-check the frames against the alphabets. The check is $O(1)$, and it is not merely sufficient — it is exactly equivalent to the absence of the bug.
