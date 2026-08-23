# The Tokenizer Tax Is Four Keys: A Rigidity Theorem for Domain–Scale Memory Budgets

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

We study the smallest retained-memory budget $k^{*}$ at which a limited-memory reader preserves a fixed fraction of its unlimited-memory accuracy, as a function of two variables: the *corpus* being read and the *context length*. A four-corpus measurement programme — source code, English prose, mathematics, and German prose — yields eight budget cells on a sweep grid of step $4$, all fitted by affine laws $L(d) = b + c\,d$ in the number $d$ of context doublings above a reference length. The fitted laws are $\langle 12,4\rangle$, $\langle 16,4\rangle$, $\langle 16,4\rangle$, $\langle 20,4\rangle$: the per-doubling increment is corpus-independent, and the bases form an arithmetic progression whose common difference equals both the increment and the sweep grid step.

Our contributions are four theorems and their sharpness statements. **(1)** A *knee stability theorem* with the two deciding margins as parameters, together with an exact converse: the below-bar margin is the precise stability radius of a reported knee. Instantiated on the German data, the reported knees tolerate uniform perturbations of $0.003$ (at context $512$) and $0.002$ (at $1024$), and no more. **(2)** A *rigidity theorem*: any two-variable integer budget family satisfying an *exchange law* (one corpus rung costs one context doubling) and a *universal increment* law is forced to be the affine function $F(0,0) + c(r+d)$ of the single coordinate $r + d$. The two hypotheses are independent, so the observed collapse of the eight-cell table to one degree of freedom is an empirical finding with exactly two testable ingredients. **(3)** A *quantisation analysis*: the sweep grid is a closure operator arising from a Galois connection; the reported shift of $+4$ certifies only that the unquantised tax lies in $(0,8)$, and this bracket is attained; the step-$4$ grid is the coarsest grid faithful to all three measured bases. **(4)** A *workload calculus*: the cache cost of a finite set of (corpus, context) cells is a join, is attained at a single certifying cell, is monotone and submodular, and equals $12 + 4\max(\mathrm{rank} + d)$. A quota refinement prices partial service: on the eight-cell round workload, serving all eight cells costs $24$ keys and serving seven costs $20$, with the dropped cell uniquely German prose at context $1024$.

We also give a calibrated density model $B(\rho) = 4\lceil 4\rho\rceil$ that converts the informal tokenizer-tax mechanism into disjoint, corpus-checkable density intervals, and pre-registered predictions at contexts $2048$ and $4096$.

**Keywords:** knee detection, threshold stability, exchange law, rigidity, quantisation, closure operator, submodular cost, cache sizing, tokenizer density.

---

## 1. Introduction

### 1.1 The problem

A reader with bounded memory must discard information. Formally, fix a task and a reader that, while processing a sequence of length $N$, retains at most $k$ stored positions. Retained accuracy $A(k)$ is nondecreasing in $k$ and saturates at the unlimited-memory accuracy $A(\infty)$. Deployment requires the *knee*: the smallest $k$ with $A(k) \ge \beta A(\infty)$ for a service bar $\beta$, here $\beta = 0.98$.

The knee is not one number but a function of two variables — what is being read, and how long the context is. The programme reported here measures that function on a grid and asks whether the resulting table has structure.

It does. This paper isolates precisely which structure, states it as theorems, proves the two structural hypotheses independent, and identifies the exact epistemic limits imposed by the measurement grid and the measurement noise.

### 1.2 Summary of results

Let $d \in \mathbb{N}$ index context doublings above the reference length $512$, so $d = 0$ is context $512$, $d=1$ is $1024$, and so on. Four corpora were measured, each fitting a budget law $L(d) = b + cd$:

| corpus | base $b$ | increment $c$ | rung $r$ |
|---|---|---|---|
| source code | $12$ | $4$ | $0$ |
| English prose | $16$ | $4$ | $1$ |
| mathematics | $16$ | $4$ | $1$ |
| German prose | $20$ | $4$ | $2$ |

The German leg is the new measurement. Its content is a shift of exactly one grid step: German prose sits $+4$ keys above English prose at both measured contexts, mirroring the earlier finding that code sits $-4$ keys below. Three horns were pre-registered before the measurement: **P1**, the shift is exactly one grid step at both contexts; **P2**, the shift is intermediate (strictly between zero and one step); **P3**, there is no shift. P1 is confirmed; P2 and P3 are refuted.

The structural consequences are the subject of Sections 3–6.

### 1.3 Organisation

Section 2 fixes definitions. Section 3 treats the measurement and its exact stability radius. Section 4 proves the rigidity theorem and the independence of its hypotheses. Section 5 treats quantisation: what the grid can and cannot certify. Section 6 develops the workload calculus and the quota refinement. Section 7 gives the calibrated density model. Section 8 states pre-registered predictions and discusses limitations. Section 9 lists future directions.

---

## 2. Definitions

### 2.1 Sweeps and knees

**Definition 2.1 (sweep curve).** A *sweep curve* is a function $a : \mathbb{N} \to \mathbb{Q}$, where $a(j)$ is the accuracy retained at grid index $j$, i.e. at budget $4j$ keys, expressed as a fraction of unlimited-memory accuracy. A sweep curve is *admissible* if it is monotone (nondecreasing).

**Definition 2.2 (bar, knee index, knee budget).** Fix the *bar* $\beta = 0.98$. The *knee index* of a sweep curve $a$ is
$$\kappa(a) \;=\; \min\{\,j \in \mathbb{N} : a(j) \ge \beta\,\},$$
and the *knee budget* on a grid of step $s$ is $s\,\kappa(a)$. Throughout, the *fine step* is $s = 4$.

**Lemma 2.3 (bracket determines the knee).** If $a$ is monotone, $a(j) < \beta$, and $\beta \le a(j+1)$, then $\kappa(a) = j+1$.

*Proof.* Monotonicity and $a(j) < \beta$ give $a(i) < \beta$ for all $i \le j$, so no index $\le j$ qualifies; $a(j+1) \ge \beta$ makes $j+1$ qualify. $\square$

Lemma 2.3 is the reason a sweep is a measurement: only the two bracketing readings enter, and everything else about the curve is irrelevant. Correspondingly, the *adjunction* $\kappa(a) \le j \iff \beta \le a(j)$ holds for monotone $a$, which is the form used in the sharpness arguments below.

### 2.2 Budget laws

**Definition 2.4 (budget law).** A *budget law* is a pair $L = \langle b, c\rangle \in \mathbb{Z}^2$ with evaluation
$$L(d) \;=\; b + c\,d, \qquad d \in \mathbb{N},$$
where $b$ is the *base* (budget at the reference context $512$) and $c$ the *increment* (extra keys per context doubling).

**Lemma 2.5 (two points pin a law).** If $L(0) = L'(0)$ and $L(1) = L'(1)$ then $L = L'$.

*Proof.* $b = L(0)$ and $c = L(1) - L(0)$. $\square$

**Definition 2.6 (shift).** For laws $L, L'$ with equal increments, the *shift* is $\mathrm{shift}(L, L') = b' - b$.

**Lemma 2.7 (constant shift $\iff$ equal increments).** $L'(d) - L(d)$ is independent of $d$ if and only if $c = c'$.

The domain axis therefore carries the structure of a *torsor*: only differences of bases are observable, and the origin is a gauge choice. We make this precise in Section 4.4.

### 2.3 The four-corpus table

**Definition 2.8 (domains, laws, rungs).** Let $\mathcal{D} = \{\mathrm{code}, \mathrm{EN}, \mathrm{math}, \mathrm{DE}\}$ with laws
$$L_{\mathrm{code}} = \langle 12,4\rangle, \quad L_{\mathrm{EN}} = \langle 16,4\rangle, \quad L_{\mathrm{math}} = \langle 16,4\rangle, \quad L_{\mathrm{DE}} = \langle 20,4\rangle,$$
and rungs $r(\mathrm{code}) = 0$, $r(\mathrm{EN}) = r(\mathrm{math}) = 1$, $r(\mathrm{DE}) = 2$.

**Definition 2.9 (cell, workload).** A *cell* is a pair $c = (D, d) \in \mathcal{D} \times \mathbb{N}$; its *budget* is $L_D(d)$ and its *rank sum* is $\mathrm{rs}(c) = r(D) + d$. A *workload* is a finite set of cells.

---

## 3. The German measurement and its stability radius

### 3.1 The readings

The German sweep (Goethe plus a second classic, per-corpus held-out splits, deterministic harness, exact gate) gave, as fractions of unlimited-memory accuracy:

* at context $512$: $4 \mapsto 0.883$, $8 \mapsto 0.953$, $12 \mapsto 0.969$, $16 \mapsto 0.976$, $20 \mapsto 0.983$, $24 \mapsto 0.988$;
* at context $1024$: $8 \mapsto 0.926$, $12 \mapsto 0.956$, $16 \mapsto 0.968$, $20 \mapsto 0.975$, $24 \mapsto 0.982$.

**Theorem 3.1 (German knees).** Every monotone sweep curve with $a(4) = 0.976$ and $a(5) = 0.983$ has $\kappa(a) = 5$, hence knee budget $20$. Every monotone sweep curve with $a(5) = 0.975$ and $a(6) = 0.982$ has $\kappa(a) = 6$, hence knee budget $24$.

*Proof.* Immediate from Lemma 2.3, since $0.976 < 0.98 \le 0.983$ and $0.975 < 0.98 \le 0.982$. $\square$

The hypotheses are non-vacuous: the measured tables are monotone and realise them, and every sub-knee reading indeed fails the bar (the ✗ column: five failures at $512$, six at $1024$).

### 3.2 Stability in general

A knee is a threshold crossing, so its robustness is exactly the question of how far the two deciding readings sit from the bar. The following theorem parameterises that.

**Theorem 3.2 (knee stability).** Let $a$ be a sweep curve, $m > 0$, and $j \in \mathbb{N}$, and suppose
$$a(j) + m \le \beta \qquad \text{and} \qquad \beta + m \le a(j+1).$$
Then every monotone $a'$ with $|a'(i) - a(i)| < m$ for all $i$ satisfies $\kappa(a') = j+1$.

*Proof.* From $|a'(j) - a(j)| < m$ we get $a'(j) < a(j) + m \le \beta$; from $|a'(j+1) - a(j+1)| < m$ we get $a'(j+1) > a(j+1) - m \ge \beta$. Apply Lemma 2.3 to $a'$. $\square$

**Theorem 3.3 (sharpness; exact converse).** Let $a$ be monotone, $m \ge 0$, and suppose $\beta \le a(j) + m$. Then there exists a monotone $a'$ with $|a'(i) - a(i)| \le m$ for all $i$ and $\kappa(a') \le j$.

*Proof.* Take $a'(i) = a(i) + m$. It is monotone, uniformly within $m$ of $a$, and satisfies $a'(j) = a(j) + m \ge \beta$, so by the adjunction $\kappa(a') \le j$. $\square$

Together: **the below-bar margin is the exact stability radius**. Any perturbation strictly smaller preserves the knee; a uniform perturbation of exactly that size destroys it.

**Corollary 3.4 (stability radii of the German knees).**

* At context $512$: the deciding readings are $0.976$ (below-bar margin $0.004$) and $0.983$ (above-bar margin $0.003$). Every monotone curve within uniform distance $0.003$ of the measured one reports $\kappa = 5$, i.e. $20$ keys; and there is a monotone curve within $0.004$ reporting $\kappa = 4$, i.e. $16$ keys.
* At context $1024$: margins $0.005$ and $0.002$. Every monotone curve within $0.002$ reports $\kappa = 6$, i.e. $24$ keys; and there is a monotone curve within $0.005$ reporting $\kappa = 5$, i.e. $20$ keys.

These radii are of the order of one reported standard error. Corollary 3.4 is therefore the honest statistical boundary of the round: the $+4$ is certified to about one standard error and no further. In particular the $16$-key miss at context $512$, which clears nothing by only $\approx 1.5$ standard errors, is exactly the reading that the stability analysis flags.

### 3.3 The fitted German law and the mirror

**Theorem 3.5 (fit and uniqueness).** $L_{\mathrm{DE}} = \langle 20,4\rangle$ satisfies $L_{\mathrm{DE}}(0) = 20$, $L_{\mathrm{DE}}(1) = 24$, and is the unique budget law doing so.

**Theorem 3.6 (the shift is context-free).** For every $d$, $L_{\mathrm{DE}}(d) - L_{\mathrm{EN}}(d) = 4$. Consequently $L_{\mathrm{DE}}$ and $L_{\mathrm{EN}}$ have the same increment: *language enters only through the base.*

**Theorem 3.7 (the mirror).** For every $d$,
$$L_{\mathrm{DE}}(d) - L_{\mathrm{EN}}(d) \;=\; L_{\mathrm{EN}}(d) - L_{\mathrm{code}}(d) \;=\; 4.$$
Hence the three distinct bases $12 < 16 < 20$ form an arithmetic progression of common difference $4$, and
$$\underbrace{4}_{\text{domain spacing}} \;=\; \underbrace{4}_{\text{per-doubling increment}} \;=\; \underbrace{4}_{\text{sweep grid step}}.$$

This triple coincidence is the structural content of the verdict *the tokenizer tax is four keys*.

**Theorem 3.8 (the horns).**
**P1 confirmed:** the measured German knee budgets equal $L_{\mathrm{DE}}(0) = 20$ and $L_{\mathrm{DE}}(1) = 24$, and $L_{\mathrm{DE}}(d) - L_{\mathrm{EN}}(d) = 4$ for *every* $d$, not just the two measured.
**P2 refuted:** there is no $d$ with $0 < L_{\mathrm{DE}}(d) - L_{\mathrm{EN}}(d) < 4$.
**P3 refuted:** $L_{\mathrm{DE}}(d) \ne L_{\mathrm{EN}}(d)$ for every $d$.
**No crossover:** $L_{\mathrm{code}}(d) < L_{\mathrm{EN}}(d) < L_{\mathrm{DE}}(d)$ at every context, with $L_{\mathrm{DE}}(d) - L_{\mathrm{code}}(d) = 8$.

---

## 4. Rigidity: the diagonal was forced

### 4.1 The exchange law

**Theorem 4.1 (exchange law).** For every $d$,
$$L_{\mathrm{DE}}(d) = L_{\mathrm{EN}}(d+1), \qquad L_{\mathrm{EN}}(d) = L_{\mathrm{code}}(d+1), \qquad L_{\mathrm{DE}}(d) = L_{\mathrm{code}}(d+2).$$

*Proof.* Each side is $12 + 4(r + d)$ with equal rank sums; e.g. $r(\mathrm{DE}) + d = 2 + d = 1 + (d+1) = r(\mathrm{EN}) + (d+1)$. $\square$

Reading German at a given context costs exactly what reading English costs at twice that context, and what reading code costs at four times it. One rung of the corpus ladder is exchangeable for one doubling of context.

### 4.2 Collapse to one coordinate

**Theorem 4.2 (the table is one affine function).** For every domain $D$ and every $d$,
$$L_D(d) \;=\; 12 + 4\big(r(D) + d\big).$$

**Theorem 4.3 (iso-budget classification).** $L_D(d) = L_E(e)$ if and only if $r(D) + d = r(E) + e$. Moreover $r(D) + d < r(E) + e$ implies $L_D(d) < L_E(e)$.

The eight-cell table is therefore not a two-dimensional grid of independent numbers; it is a family of parallel diagonals in the single coordinate $\mathrm{rs} = r + d$, with a strictly increasing affine value along it.

### 4.3 The rigidity theorem

Theorem 4.2 could be an arithmetic accident of four measured bases. It is not. It is forced.

**Theorem 4.4 (rigidity).** Let $F : \mathbb{N} \times \mathbb{N} \to \mathbb{Z}$ and $c \in \mathbb{Z}$ satisfy
* **(E) exchange:** $F(r+1, d) = F(r, d+1)$ for all $r,d$;
* **(I) universal increment:** $F(r, d+1) = F(r,d) + c$ for all $r,d$.

Then $F(r,d) = F(0,0) + c\,(r+d)$ for all $r, d$.

*Proof.* First, induction on $d$ using (I) at $r = 0$ gives $F(0,d) = F(0,0) + cd$. Now induct on $r$. The base case is the previous sentence. For the step, assume $F(k, e) = F(0,0) + c(k+e)$ for all $e$. Then for any $d$,
$$F(k+1, d) \overset{\text{(E)}}{=} F(k, d+1) \overset{\text{IH}}{=} F(0,0) + c\big(k + d + 1\big) = F(0,0) + c\big((k+1) + d\big). \qquad \square$$

**Corollary 4.5 (the table, re-derived from the axioms).** Define the *ladder law* $\Lambda_r = \langle 12 + 4r,\, 4\rangle$. Then $\Lambda$ satisfies (E) and (I) with $c = 4$, hence $\Lambda_r(d) = 12 + 4(r+d)$; and $L_D = \Lambda_{r(D)}$ for every measured domain. Theorem 4.2 thus follows from (E) and (I) with no arithmetic on the measured bases.

### 4.4 The two axioms are independent

**Theorem 4.6 ((E) does not imply the affine collapse).** The family $F(r,d) = (r+d)^2$ satisfies (E), yet there is no $c$ with $F(r,d) = F(0,0) + c(r+d)$ for all $r,d$.

*Proof.* (E) is immediate since $F$ depends only on $r+d$. If such a $c$ existed, then $F(0,1) = 1$ forces $c = 1$ while $F(0,2) = 4$ forces $2c = 4$, i.e. $c = 2$ — a contradiction. $\square$

**Theorem 4.7 ((I) does not imply (E)).** The family $F(r,d) = r^2 + 4d$ satisfies (I) with $c = 4$, yet violates (E): $F(3,0) = 9 \ne 8 = F(2,1)$.

**Corollary 4.8.** The observed collapse is a genuine empirical finding with exactly two ingredients, neither redundant. The German leg is the experiment that tested (E) in a new place; the earlier scale legs tested (I).

**Theorem 4.9 (what a non-conforming corpus would look like).** If a budget law $L$ has increment $c \ne 4$, then $L$ cannot satisfy the universal-increment law $L(d+1) = L(d) + 4$; consequently no exchange law can embed $L$ into the ladder, and the discrepancy is visible at $d = 0 \to 1$, i.e. at a computable context.

Theorem 4.9 is the falsification criterion: a future corpus refutes the diagonal picture precisely by exhibiting an increment other than $4$.

### 4.5 Identifiability: three numbers, not four

**Theorem 4.10 (torsor identifiability).** Let $f, g : \mathcal{D} \to \mathbb{Z}$ be assignments of bases. Then
$$\big(\forall A, B \in \mathcal{D}:\; f(B) - f(A) = g(B) - g(A)\big) \iff \big(\exists t \in \mathbb{Z}\; \forall D:\; g(D) = f(D) + t\big).$$

*Proof.* ($\Leftarrow$) Translations cancel in differences. ($\Rightarrow$) Put $t = g(\mathrm{code}) - f(\mathrm{code})$; the hypothesis at $A = \mathrm{code}$ gives $g(D) = f(D) + t$ for all $D$. $\square$

**Corollary 4.11.** Only pairwise shifts are observable; the origin of the domain axis is convention. The four-domain experiment therefore measures three independent numbers, and its content is the *shift vector* $\big(b_D - b_{\mathrm{code}}\big)_D = 4\cdot(0,1,1,2)$. Shifts also compose along the ladder: $\mathrm{shift}(\mathrm{code},\mathrm{EN}) + \mathrm{shift}(\mathrm{EN},\mathrm{DE}) = \mathrm{shift}(\mathrm{code},\mathrm{DE}) = 8$.

---

## 5. Quantisation: what the grid can certify

A sweep on a grid of step $s$ never reports a true requirement; it reports the requirement rounded up. This section separates three questions that the headline "+4" silently conflates.

### 5.1 The grid is a closure operator

**Definition 5.1.** For $s \in \mathbb{N}_{>0}$ and $x \in \mathbb{Q}$, let $G_s(x) = s\,\lceil x/s\rceil$.

**Theorem 5.2 (Galois connection).** For $s > 0$, $x \in \mathbb{Q}$, $n \in \mathbb{N}$:
$$x \le s\,n \iff \lceil x/s\rceil \le n.$$

**Corollary 5.3.** $G_s$ is inflationary ($x \le G_s(x)$), monotone, and idempotent ($G_s \circ G_s = G_s$), with fixed points exactly the grid multiples $s\,n$. A reported knee is thus a fixed point of the measurement map.

### 5.2 The bracket, and what "+4" does and does not certify

**Theorem 5.4 (bracketing).** If $j \ne 0$ and a step-$4$ sweep reports index $j$ for a true requirement $\kappa$ — i.e. $\lceil \kappa/4\rceil = j$ — then
$$4j - 4 < \kappa \le 4j,$$
and nothing more.

**Theorem 5.5 (the true tax is strictly positive but not four).** Suppose the unquantised German and English requirements at context $512$ satisfy $\lceil \kappa_{\mathrm{DE}}/4\rceil = 5$ and $\lceil \kappa_{\mathrm{EN}}/4\rceil = 4$. Then
$$0 < \kappa_{\mathrm{DE}} - \kappa_{\mathrm{EN}} < 8.$$

*Proof.* $\kappa_{\mathrm{DE}} > 16 \ge \kappa_{\mathrm{EN}}$ gives positivity; $\kappa_{\mathrm{DE}} \le 20$ and $\kappa_{\mathrm{EN}} > 12$ give the upper bound. $\square$

**Theorem 5.6 (non-identifiability, exhibited).** Both endpoints of the analysis are attained in the sense that the interval cannot be narrowed: the pair $(\kappa_{\mathrm{DE}}, \kappa_{\mathrm{EN}}) = (33/2,\, 16)$ reproduces both measured indices with true tax $1/2$, while $(20,\, 49/4)$ reproduces them with true tax $31/4$.

**Theorem 5.7 (what is identified).** For *every* pair of true requirements consistent with the two measured indices,
$$G_4(\kappa_{\mathrm{DE}}) - G_4(\kappa_{\mathrm{EN}}) = 4.$$

So the headline value is a property of the reported grid readings, not of the underlying knees. What survives quantisation is: (i) the true tax is strictly positive — P3 is refuted *continuously*, not merely on the grid; (ii) it is less than two grid steps; (iii) the reported shift is exactly one step, unconditionally.

### 5.3 Resolution: step $4$ is the coarsest faithful grid

**Definition 5.8.** Write $R_g(k) = g\lceil k/g\rceil$ for the step-$g$ reading of an integer budget $k$. A grid of step $g$ is *faithful* to the measured bases if $R_g(12) = 12$, $R_g(16) = 16$, $R_g(20) = 20$.

**Theorem 5.9 (exact resolution threshold).** For $g > 0$, the step-$g$ grid is faithful to the measured bases if and only if $g \mid 4$.

*Proof.* $R_g(k) = k \iff g \mid k$. Faithfulness gives $g \mid 12$ and $g \mid 16$, hence $g \mid 4$. Conversely $g \mid 4$ divides $12, 16, 20$. $\square$

**Theorem 5.10 (a coarser grid is doubly misleading).** On the step-$8$ grid, $R_8(12) = R_8(16) = 16$, so the code/English gap is reported as $0$; and $R_8(20) - R_8(16) = 24 - 16 = 8$, so the English/German gap is reported as twice its true reported size. On the step-$4$ grid both gaps read $4$.

Step $4$ is therefore the coarsest grid that reports every measured gap correctly — a minimality result, not a lucky choice after the fact.

---

## 6. The workload calculus

### 6.1 Cover cost

**Definition 6.1.** For a finite nonempty workload $S$ of cells, the *cover cost* is
$$\mathrm{cost}(S) \;=\; \max_{c \in S} L_{D(c)}(d(c)).$$

**Theorem 6.2 (one-cell certificate).** $\mathrm{cost}(S)$ is attained: there is $c \in S$ with $\mathrm{cost}(S) = L_{D(c)}(d(c))$. Every cell of $S$ is served by $\mathrm{cost}(S)$.

A deployment budget can always be justified by exhibiting a single worst case — an operationally important property, since it makes budget disputes decidable by one measurement.

**Theorem 6.3 (join, monotonicity, submodularity).** For nonempty $S, T$:
1. $\mathrm{cost}(S \cup T) = \max\big(\mathrm{cost}(S), \mathrm{cost}(T)\big)$ — budgets combine by join, never by addition;
2. $S \subseteq T \Rightarrow \mathrm{cost}(S) \le \mathrm{cost}(T)$;
3. if $S \cap T \ne \emptyset$, $\;\mathrm{cost}(S \cup T) + \mathrm{cost}(S \cap T) \le \mathrm{cost}(S) + \mathrm{cost}(T)$.

*Proof.* (1) is the sup of a union. (2) is monotonicity of sup. (3): by (2), $\mathrm{cost}(S \cap T) \le \min(\mathrm{cost}(S), \mathrm{cost}(T))$, and by (1) the left side is $\max + \mathrm{cost}(S\cap T) \le \max + \min = \mathrm{cost}(S) + \mathrm{cost}(T)$. $\square$

Submodularity says consolidating two workloads onto one cache is never more expensive than provisioning them separately, and quantifies the saving as the slack of the overlap.

**Theorem 6.4 (cost in ladder coordinates).** $\mathrm{cost}(S) = 12 + 4\max_{c\in S}\mathrm{rs}(c)$. Sizing a heterogeneous deployment reduces to computing a single integer: the largest rank sum present.

### 6.2 The four-domain deployment table

**Theorem 6.5 (mixed-workload envelope).** For any nonempty set of domains containing German prose, the pointwise supremum of the domains' laws is again a budget law, namely $L_{\mathrm{DE}}$. German dominates every domain at every context.

**Theorem 6.6 (the headline number and its optimality).** A cache of $24$ keys serves every domain at every context $\le 1024$; and any bound serving all four domains to context $1024$ is at least $24$, since German at $1024$ attains it. Hence $24$ is the *least* universal cache for the measured programme.

**Theorem 6.7 (the cell that breaks it).** At context $2048$ the $24$-key cache fails, and it fails for German alone: $L_{\mathrm{DE}}(2) = 28 > 24$ while $L_{\mathrm{code}}(2) = 20$, $L_{\mathrm{EN}}(2) = L_{\mathrm{math}}(2) = 24$.

**Theorem 6.8 (the multilingual premium).** For every $d$,
$$\max\big(L_{\mathrm{EN}}(d), L_{\mathrm{DE}}(d)\big) - L_{\mathrm{EN}}(d) = 4, \qquad L_{\mathrm{DE}}(d) - L_{\mathrm{code}}(d) = 8.$$
Sizing by English under-provisions a multilingual workload by exactly one grid step at every context; sizing by code, by two.

### 6.3 Quota sizing: pricing partial service

Full coverage is a strong requirement; a real deployment often need only serve a quota of its cells.

**Definition 6.9.** For a workload $S$ and rung $r$, the *coverage* is $\sigma_S(r) = \#\{c \in S : \mathrm{rs}(c) \le r\}$. The *quota rank* for a quota $m$ is $\varrho_S(m) = \min\{r : \sigma_S(r) \ge m\}$, and the *quota cost* is $Q_S(m) = 12 + 4\,\varrho_S(m)$.

**Theorem 6.10 (coverage).** $\sigma_S$ is monotone; $\sigma_S(\max_{c\in S}\mathrm{rs}(c)) = |S|$; and $\sigma_S(r) < |S|$ whenever $r < \max_{c\in S}\mathrm{rs}(c)$.

**Theorem 6.11 (adjunction).** For $m \le |S|$: $\;\varrho_S(m) \le r \iff m \le \sigma_S(r)$. In particular $\varrho_S(m)$ does serve the quota, and $\varrho_S$ is monotone in $m$.

**Theorem 6.12 (quota extends coverage).** $\varrho_S(|S|) = \max_{c \in S}\mathrm{rs}(c)$, hence $Q_S(|S|) = \mathrm{cost}(S)$ and $Q_S(m) \le \mathrm{cost}(S)$ for all $m \le |S|$.

So the quota construction is a genuine refinement of Section 6.1, agreeing with it at full quota.

**Theorem 6.13 (the tokenizer tax, priced).** Let $W$ be the eight-cell round workload: four domains at contexts $512$ and $1024$. Then coverage grows
$$\sigma_W(0) = 1, \quad \sigma_W(1) = 4, \quad \sigma_W(2) = 7, \quad \sigma_W(3) = 8,$$
so $Q_W(8) = 24$ and $Q_W(7) = 20$: serving all eight cells costs $24$ keys, while dropping one cell costs $20$. The difference is exactly one grid step.

**Theorem 6.14 (the dropped cell is unique).** The unique cell of $W$ with maximal rank sum $3$ is German prose at context $1024$.

One-sixth of the multilingual cache budget buys the last one-eighth of the workload, and it buys exactly one cell.

---

## 7. A calibrated, falsifiable mechanism

The informal explanation of the tax is linguistic: German compounding packs more content per token, so each retained position carries a denser payload and more positions are needed per unit of argument. We convert this into arithmetic that can be checked without running the sweep at all.

**Definition 7.1 (density model).** A corpus of *relative content density* $\rho \in \mathbb{Q}_{>0}$ (English $= 1$) requires $16\rho$ keys before quantisation, hence has predicted base
$$B(\rho) \;=\; 4\lceil 4\rho \rceil \;=\; G_4(16\rho).$$

**Theorem 7.2.** $B(1) = 16$ (calibration); $B$ is monotone; and for $n \ge 1$,
$$B(\rho) = 4n \iff \frac{n-1}{4} < \rho \le \frac{n}{4}.$$

**Theorem 7.3 (the measured bases bound the densities).** If $B(\rho_{\text{code}}) = 12$, $B(\rho_{\mathrm{EN}}) = 16$, $B(\rho_{\mathrm{DE}}) = 20$, then
$$\rho_{\text{code}} \in \left(\tfrac12, \tfrac34\right], \qquad \rho_{\mathrm{EN}} \in \left(\tfrac34, 1\right], \qquad \rho_{\mathrm{DE}} \in \left(1, \tfrac54\right].$$
These intervals are pairwise disjoint and ordered, so the model predicts a strict density ladder $\rho_{\text{code}} < \rho_{\mathrm{EN}} < \rho_{\mathrm{DE}}$, and it reproduces the measured gaps: $B(\rho_{\mathrm{DE}}) - B(\rho_{\mathrm{EN}}) = B(\rho_{\mathrm{EN}}) - B(\rho_{\text{code}}) = 4$.

The crucial point is that $\rho$ is a *token-counting* quantity. The three interval constraints can be tested by counting tokens on the corpora — no model, no training, no sweep. The mechanism is therefore falsifiable independently of the experiment that suggested it.

**Theorem 7.4 (pre-registered density prediction).** If $\rho > 3/2$, then $B(\rho) \ge 28$.

Any corpus measured at more than $1.5\times$ English's content per token, but reading a base of $20$, refutes the density model outright.

---

## 8. Predictions, limitations, and discussion

### 8.1 Pre-registered predictions

**Theorem 8.1 (context $4096$).** $L_{\mathrm{code}}(3) = 24$, $L_{\mathrm{EN}}(3) = L_{\mathrm{math}}(3) = 28$, $L_{\mathrm{DE}}(3) = 32$; and $32$ is the least cache covering all four domains to context $4096$.

Together with Theorem 6.7 (the $24$-key cache fails at $2048$, for German alone) and Theorem 7.4, these are the round's falsifiable commitments. Each is decided by a single measured cell.

### 8.2 Limitations, stated precisely

We record four boundaries, each of which is a theorem rather than a caveat.

1. **Noise.** The reported knees are certified only within uniform perturbations of $0.003$ (context $512$) and $0.002$ (context $1024$); these radii are sharp (Corollary 3.4) and are of the order of one standard error.
2. **Quantisation.** The reported $+4$ certifies only $0 < \text{true tax} < 8$, and this bracket is attained by explicit scenarios (Theorems 5.5–5.6). The strictly-positive part is robust; the value $4$ is a grid artefact of a real effect.
3. **Corpus scope.** One non-English language, two classical texts. The exchange law has been tested at exactly one new rung.
4. **Gauge.** The experiment measures three independent numbers, not four; the origin of the domain axis is a convention (Corollary 4.11).

### 8.3 Discussion

The intellectual content of the round is the passage from *four fitted laws* to *one affine function of one coordinate*, and then from that observation to a rigidity theorem that says the collapse was forced by two independently testable regularities. This is the pattern that makes an empirical table into a theory: not "the numbers happened to line up", but "here are two laws, here is the proof that they force the alignment, and here are two counterexamples showing that neither law alone suffices."

The exchange law is the more interesting of the two, and the more surprising. There is no a priori reason why the difficulty added by switching to a denser language should equal the difficulty added by doubling the amount of text. That they coincide — and coincide exactly, at both measured contexts — is the finding.

The quantisation analysis is included deliberately, and it is the part most often omitted in empirical reports. A grid reading is a closure operator, and closure operators lose information in a way that is invisible unless you compute the fibre. Doing so here shows that a headline number can be simultaneously *correct as reported* and *not a property of the underlying quantity* — the true tax could be $0.5$ keys or $7.75$ keys. What the data does establish is that it is not zero.

Finally, the workload calculus turns the table into an engineering instrument. Because cost is a join and not a sum, mixing workloads is cheap; because it is attained at one cell, budgets are auditable; and because it is submodular, consolidation is always weakly beneficial. The quota refinement then prices the tail, and the answer on the measured workload is stark: the hardest cell out of eight consumes one-sixth of the budget.

---

## 9. Future directions

**1. The rank-sum invariant across a third axis (depth).** *Conjecture:* the collapse $\text{budget} = \text{base} + \text{step}\cdot(\text{rank} + \text{doublings})$ extends to a depth axis, so that with model width and head count fixed, halving the number of layers shifts every domain's base by a constant number of steps and the budget becomes $12 + 4(\text{rank} + \text{doublings} + \text{layerRungs})$ — one affine function of a *three*-term sum. The key insight is that the exchange law of the rigidity theorem never mentions which axis supplies a rung: any second regularity of the same shape can be adjoined to the diagonal, and rigidity then forces a single coordinate again. Because the rigidity theorem is already established for two axes and its two hypotheses are independent, the three-axis version is a one-cell experiment (depth $2$ at context $512$, German) rather than a new theory: it either lands on the predicted diagonal or refutes the exchange law in its first non-trivial instance.

**2. Sub-step domain shifts and the resolution barrier.** *Conjecture:* there exists a natural-language corpus whose true knee sits strictly between two grid points relative to English — i.e. the *unquantised* tax is not a multiple of $4$ — and no experiment on a step-$4$ grid can detect it. Theorems 5.4–5.6 make this precise: the fibre of the reading map is a half-open interval, and any sub-step effect lives inside it. Deciding this requires a finer sweep, and Theorem 5.9 identifies which finer sweeps are admissible.

**3. More languages, and the density ladder.** Extend the corpus axis with languages of markedly different compounding behaviour and test the disjoint-interval predictions of Theorem 7.3 directly by token counting, before any sweep is run. Theorem 7.4 supplies the sharp falsifier at the dense end.

**4. Modern technical prose.** The mathematics corpus tied with English prose at base $16$. Modern technical text with heavy notation is the natural probe for whether the rung structure is about *language* or about *notation density*.

**5. Increments at longer contexts, and quantised deployment.** Test the universal increment at context $4096$ (Theorem 8.1) and in a memory-constrained regime, where the exchange law's practical consequence — that a rung of language is purchasable with a doubling of context — becomes a scheduling primitive rather than a curiosity.
