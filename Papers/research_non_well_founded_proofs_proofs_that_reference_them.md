# Non-Well-Founded Proofs as Self-Similarity: A Fixed-Point Theory of Safe Self-Reference

**Domain:** Geometry (self-similar structures, contraction dynamics) with applications to proof theory.

---

## Abstract

We develop a unified theory in which *self-reference, when it is valid, is self-similarity*. Classical logic treats self-referential statements with suspicion: the liar sentence and Gödel's diagonal lemma show that uncontrolled self-reference breaks completeness and consistency. We propose a sharp dividing criterion — **contraction** — that separates self-referential definitions which name a unique object from those which name nothing. A self-referential equation $x = f(x)$ has a unique solution exactly when $f$ shrinks distances by a constant factor below one; the same condition governs which self-similar geometric objects are well-defined and which recursive (proof) definitions converge.

We realize this thesis through two formal engines: **contraction fixed points** ($x^\star = f(x^\star)$) and **coinductive data** (infinite streams characterized up to bisimulation). We unify five phenomena under a single principle — *a quantity that is the unique solution of its own equation*: (i) the infinite geometric series $S = a + rS$; (ii) the coinductive geometric stream whose tail is a scaled copy of itself; (iii) the affine attractor $f(x) = cx + b$ with geometric convergence rate; (iv) the metallic ratios $\varphi_m^2 = m\varphi_m + 1$ with their gnomon self-similarity; and (v) the similarity dimension $D = \log k/\log(1/r)$ as the solution of $k r^D = 1$. We then transport the criterion to proof theory: the self-referential proof of $P \Rightarrow P$ is a *valid* non-well-founded proof of finite height, while the liar sentence is *invalid* precisely because its height functional $h \mapsto h+1$ is non-contractive and admits no fixed point. The paradox becomes a boundary case rather than a flaw.

All quantitative claims below are stated as theorems with proof sketches.

---

## 1. Introduction

### 1.1 The problem of self-reference

Self-reference is the engine behind the deepest negative results of twentieth-century logic. The liar sentence, *"this statement is false,"* has no stable truth value; Gödel's first incompleteness theorem constructs a sentence asserting its own unprovability; Russell's paradox exhibits a set that contains itself iff it does not. The orthodox response is *well-foundedness*: every legitimate definition and proof must bottom out in a finite descending chain, forbidding circular dependency.

Yet mathematics is replete with self-referential objects that are entirely well-behaved. The golden ratio is defined by $\varphi = 1 + 1/\varphi$. A geometric series equals its first term plus a scaled copy of itself. A fractal is, by construction, made of smaller copies of itself. None of these is paradoxical. The aim of this paper is to explain *why*, with a single criterion, and to use that criterion to rehabilitate a controlled class of self-referential proofs.

### 1.2 Thesis

> **A self-referential definition $x = f(x)$ is valid — names exactly one object — if and only if its defining operator $f$ is a contraction. Valid self-reference is self-similarity, and the unique named object is the contraction's fixed point.**

The "if" direction is the Banach fixed-point principle; the "only if" direction is exhibited by the family of non-contractive failures ($r = 1$ geometric series, the liar sentence) where existence or uniqueness collapses. The contribution of this paper is to (a) make the principle uniform across numbers, infinite streams, plane figures, and fractal dimension, and (b) transport it to a theory of non-well-founded proofs with a concrete validity test.

### 1.3 Two formal engines

- **Contraction fixed points.** A map $f$ on a complete metric space with Lipschitz constant $L < 1$ has a unique fixed point reached by iteration at geometric rate. This handles numbers, points, and finite-dimensional self-reference.
- **Coinduction.** Infinite objects (streams, trees) are characterized not by how they are built from below but by their *observations* (head/tail). Bisimulation supplies a uniqueness principle for self-referential infinite structures.

The two engines are dual faces of the same idea — "the object is determined by its own unfolding" — and we use whichever is sharper for each phenomenon.

---

## 2. Preliminaries and definitions

Throughout, $\mathbb{R}$ carries its usual metric. We write $f^{(k)}$ for the $k$-fold composition of $f$ with itself, with $f^{(0)} = \mathrm{id}$.

**Definition 2.1 (Contraction).** A map $f : \mathbb{R} \to \mathbb{R}$ is a *contraction with factor $L$* if $0 \le L < 1$ and $|f(x) - f(y)| \le L\,|x - y|$ for all $x, y$.

**Definition 2.2 (Self-referential value / fixed point).** A point $x^\star$ is a *fixed point* of $f$ if $x^\star = f(x^\star)$. We read the equation $x = f(x)$ as a *self-referential definition* of $x$.

**Definition 2.3 (Geometric value).** For $a, r \in \mathbb{R}$ with $r \ne 1$, the *geometric value* is
$$\mathrm{geomVal}(a, r) := \frac{a}{1 - r}.$$
For $|r| < 1$ this is the sum of the convergent series $\sum_{n \ge 0} a r^n$.

**Definition 2.4 (Geometric stream).** The *geometric stream* $G_{a,r}$ is the infinite sequence with entries $G_{a,r}(n) = a\,r^n$. It is generated coinductively by the rule
$$\mathrm{head}(G_{a,r}) = a, \qquad \mathrm{tail}(G_{a,r}) = G_{a r,\, r}.$$
We write $\mathrm{scale}_r(s)$ for the stream obtained by multiplying every entry of $s$ by $r$.

**Definition 2.5 (Affine map).** For $c, b \in \mathbb{R}$, the *affine map* is $A_{c,b}(x) = c\,x + b$. It is a contraction with factor $|c|$ when $|c| < 1$.

**Definition 2.6 (Metallic ratio).** For an integer $m \ge 1$, the *$m$-th metallic ratio* is
$$\varphi_m := \frac{m + \sqrt{m^2 + 4}}{2}.$$
($\varphi_1$ is the golden ratio, $\varphi_2 = 1+\sqrt2$ the silver ratio, $\varphi_3$ the bronze ratio.)

**Definition 2.7 (Similarity dimension).** For a count $k \ge 1$ and ratio $r$ with $0 < r < 1$, the *similarity dimension* is
$$\mathrm{simDim}(k, r) := \frac{\log k}{\log(1/r)}.$$

**Definition 2.8 (Bisimulation of streams).** Two streams $s, t$ are *bisimilar* if there is a relation $\mathcal{R}$ with $s \mathrel{\mathcal{R}} t$ such that whenever $u \mathrel{\mathcal{R}} v$, we have $\mathrm{head}(u) = \mathrm{head}(v)$ and $\mathrm{tail}(u) \mathrel{\mathcal{R}} \mathrm{tail}(v)$. The coinduction principle states that bisimilar streams are equal.

---

## 3. Main results

We group the results by engine, then transport them to proof theory in §6.

### 3.1 The geometric series is a self-referential value

**Theorem 3.1 (Self-consistency of the geometric value).** *For $r \ne 1$, the geometric value $S = \mathrm{geomVal}(a, r)$ satisfies its own defining equation*
$$S = a + r\,S.$$

*Proof sketch.* Substitute $S = a/(1-r)$: $a + r \cdot \frac{a}{1-r} = \frac{a(1-r) + ra}{1-r} = \frac{a}{1-r} = S$. $\qquad\blacksquare$

**Theorem 3.2 (Uniqueness of the self-referential value).** *If $r \ne 1$ and $x = a + r\,x$, then $x = \mathrm{geomVal}(a,r) = \dfrac{a}{1-r}$.*

*Proof sketch.* From $x = a + rx$ we get $x(1 - r) = a$; since $r \ne 1$, divide by $1 - r$. Uniqueness needs only $r \ne 1$; the *interpretation as a convergent sum* needs $|r| < 1$. $\qquad\blacksquare$

**Remark 3.3 (The boundary case is the paradox in miniature).** At $r = 1$ the equation $x = a + x$ forces $a = 0$; it is then satisfied by *every* $x$ (total ambiguity) and otherwise by *none* (contradiction). The loss of contraction destroys uniqueness exactly as the liar sentence destroys a stable truth value (§6).

### 3.2 The geometric stream is self-similar and unique

**Theorem 3.4 (Self-similarity law).** *The geometric stream satisfies*
$$\mathrm{scale}_r\bigl(G_{a,r}\bigr) = \mathrm{tail}\bigl(G_{a,r}\bigr).$$
*That is, scaling the whole stream by $r$ yields its own tail.*

*Proof sketch.* Compare entry $n$ of both sides: $\mathrm{scale}_r(G_{a,r})(n) = r \cdot a r^n = a r^{n+1}$, while $\mathrm{tail}(G_{a,r})(n) = G_{a,r}(n+1) = a r^{n+1}$. Equal for all $n$. $\qquad\blacksquare$

**Theorem 3.5 (Bisimulation rigidity / uniqueness).** *Let $s$ be any stream with $\mathrm{head}(s) = a$ and $\mathrm{scale}_r(s) = \mathrm{tail}(s)$. Then $s = G_{a,r}$.*

*Proof sketch.* The hypothesis $\mathrm{tail}(s) = \mathrm{scale}_r(s)$ says $s$ obeys exactly the coinductive generator of $G_{a,r}$: its head is $a$ and its tail is the "scale-by-$r$, restart with head $ar$" stream. Define $\mathcal{R} = \{(s', G_{a',r}) : \mathrm{head}(s') = a',\ \mathrm{tail}(s') = \mathrm{scale}_r(s')\}$. One checks heads agree ($a'$) and tails are again related (with head $a' r$). By coinduction (Definition 2.8), $s = G_{a,r}$. $\qquad\blacksquare$

This is the infinite-object analogue of Theorem 3.2: the self-referential *law* "my tail is a scaled copy of me" determines the object completely. Self-reference does not under-specify; it pins down a unique element.

### 3.3 The affine attractor: convergence with explicit rate

**Theorem 3.6 (Existence and value of the fixed point).** *If $|c| < 1$, then $x^\star = \dfrac{b}{1 - c}$ satisfies $A_{c,b}(x^\star) = x^\star$.*

*Proof sketch.* $A_{c,b}(x^\star) = c \cdot \frac{b}{1-c} + b = \frac{cb + b(1-c)}{1-c} = \frac{b}{1-c} = x^\star$. (This is Theorem 3.1 with $a = b$, $r = c$.) $\qquad\blacksquare$

**Theorem 3.7 (Uniqueness of the fixed point).** *If $|c| < 1$ and $A_{c,b}(x) = x$, then $x = \dfrac{b}{1-c}$.* (Immediate from Theorem 3.2.)

**Theorem 3.8 (Geometric error contraction).** *For all $x_0$ and all $k \ge 0$,*
$$\bigl|\,A_{c,b}^{(k)}(x_0) - x^\star\,\bigr| \;\le\; |c|^k\,\bigl|x_0 - x^\star\bigr|.$$

*Proof sketch.* Induction on $k$. Base $k=0$ trivial. For the step, since $x^\star$ is fixed, $A_{c,b}^{(k+1)}(x_0) - x^\star = A_{c,b}(A^{(k)}_{c,b}(x_0)) - A_{c,b}(x^\star) = c\,(A^{(k)}_{c,b}(x_0) - x^\star)$; take absolute values and apply the inductive bound. $\qquad\blacksquare$

**Theorem 3.9 (Convergence of every orbit).** *If $|c| < 1$, then $A_{c,b}^{(k)}(x_0) \to x^\star$ as $k \to \infty$, for every starting point $x_0$.*

*Proof sketch.* By Theorem 3.8 the error is bounded by $|c|^k |x_0 - x^\star|$, and $|c|^k \to 0$ since $|c| < 1$; squeeze. $\qquad\blacksquare$

Theorems 3.6–3.9 constitute the one-dimensional Banach fixed-point theorem made fully quantitative. The contraction factor $|c|$ is simultaneously the existence guarantee, the uniqueness guarantee, and the convergence rate — the three faces of "the loop shrinks."

### 3.4 Metallic ratios: a dynasty of self-referential numbers

**Theorem 3.10 (Defining quadratic).** *For every integer $m \ge 1$,*
$$\varphi_m^2 = m\,\varphi_m + 1.$$

*Proof sketch.* With $\varphi_m = \frac{m + \sqrt{m^2+4}}{2}$, compute $\varphi_m^2 - m\varphi_m = \varphi_m(\varphi_m - m) = \frac{m+\sqrt{m^2+4}}{2}\cdot\frac{-m+\sqrt{m^2+4}}{2} = \frac{(m^2+4) - m^2}{4} = 1$. $\qquad\blacksquare$

**Theorem 3.11 (Self-referential continued-fraction form).** *For $m \ge 1$, $\varphi_m > 0$ and*
$$\varphi_m = m + \frac{1}{\varphi_m}.$$

*Proof sketch.* Divide Theorem 3.10 by $\varphi_m$ (positive, hence nonzero). This exhibits $\varphi_m$ as the fixed point of the self-map $g(x) = m + 1/x$, the closed form of the infinite continued fraction $[m; m, m, \dots]$. $\qquad\blacksquare$

**Theorem 3.12 (Golden specialization).** *$\varphi_1 = \dfrac{1 + \sqrt5}{2}$, the golden ratio.* (Set $m=1$ in Definition 2.6.)

**Theorem 3.13 (Gnomon self-similarity).** *A rectangle with side ratio $\varphi_m : 1$, after removal of $m$ unit squares from the long side, leaves a rectangle with the same ratio $\varphi_m : 1$.*

*Proof sketch.* The long-to-short ratio is $\varphi_m$. Removing $m$ squares of side $1$ leaves a $1 \times (\varphi_m - m)$ rectangle; its ratio of long to short side is $1/(\varphi_m - m)$. By Theorem 3.11, $\varphi_m - m = 1/\varphi_m$, so $1/(\varphi_m - m) = \varphi_m$. The shape reproduces itself at scale $1/\varphi_m$. $\qquad\blacksquare$

Theorem 3.13 is the planar incarnation of self-similarity: a geometric figure satisfying "I contain a scaled copy of myself," with the scale dictated by the same self-referential equation that defines $\varphi_m$.

### 3.5 Similarity dimension: the exponent that balances the loop

**Theorem 3.14 (Defining balance equation).** *For $k \ge 1$ and $0 < r < 1$, $D = \mathrm{simDim}(k, r)$ satisfies*
$$k \cdot r^{D} = 1.$$

*Proof sketch.* $r^D = r^{\log k / \log(1/r)} = \exp\!\big(\tfrac{\log k}{\log(1/r)}\log r\big) = \exp\!\big(\tfrac{\log k}{\log(1/r)}\cdot(-\log(1/r))\big) = \exp(-\log k) = 1/k$. Hence $k r^D = 1$. $\qquad\blacksquare$

**Theorem 3.15 (Positivity).** *For $k \ge 2$ and $0 < r < 1$, $\mathrm{simDim}(k, r) > 0$.*

*Proof sketch.* $\log k > 0$ (as $k \ge 2$) and $\log(1/r) > 0$ (as $0 < r < 1$); the quotient is positive. $\qquad\blacksquare$

The dimension is the unique exponent making $k$ copies at scale $r$ reassemble into one whole — once more, a quantity defined as the solution of its own consistency equation. The classical examples ($D = 1$ for $k=2, r=1/2$; the Koch curve $D = \log 4/\log 3$) are instances.

---

## 4. The unifying principle

The five theorem-clusters above are not independent tricks. Each instantiates the same schema:

| Phenomenon | Self-referential equation | Unique solution | Engine |
|---|---|---|---|
| Geometric series | $S = a + rS$ | $a/(1-r)$ | contraction |
| Geometric stream | $\mathrm{tail}(s) = \mathrm{scale}_r(s)$, $\mathrm{head}=a$ | $G_{a,r}$ | coinduction |
| Affine attractor | $x = cx + b$ | $b/(1-c)$ | contraction |
| Metallic ratio | $x = m + 1/x$ | $\varphi_m$ | contraction |
| Similarity dimension | $k\,r^{D} = 1$ | $\log k/\log(1/r)$ | contraction |

In every row the object is *defined by referencing itself*, and in every row the reference is **guarded** — the loop strictly shrinks (the contraction factor is $|r|, |c|, 1/\varphi_m < 1$; the dimension equation is strictly monotone in $D$). Guardedness yields existence *and* uniqueness. This is the geometric content of "valid self-reference is self-similarity."

---

## 5. Algorithms

The contraction principle is not merely an existence statement; it is a computational method. We record two algorithms used to realize and certify the results numerically (full code in the accompanying demonstration files).

**Algorithm A — Banach iteration for self-referential values.**
*Input:* a contraction factor $c$ with $|c| < 1$, offset $b$, start $x_0$, tolerance $\varepsilon$.
*Output:* an approximation of $x^\star = b/(1-c)$ certified to within $\varepsilon$.
*Method:* iterate $x_{k+1} = c x_k + b$; by Theorem 3.8 the error after $k$ steps is $\le |c|^k|x_0 - x^\star|$, so a stopping index $k \ge \log(\varepsilon/|x_0-x^\star|)/\log|c|$ guarantees the tolerance. Complexity: $O(\log(1/\varepsilon)/\log(1/|c|))$ arithmetic operations.

**Algorithm B — Continued-fraction evaluation of metallic ratios.**
*Input:* integer $m \ge 1$, depth $N$.
*Output:* the depth-$N$ truncation of $[m; m, m, \dots]$ approximating $\varphi_m$.
*Method:* fold the self-map $g(x) = m + 1/x$ from a seed; by contraction near $\varphi_m$ (the derivative $|g'(\varphi_m)| = 1/\varphi_m^2 < 1$) the truncations converge geometrically. The error after $N$ folds shrinks by a factor $\approx \varphi_m^{-2}$ per step.

---

## 6. Transport to proof theory: non-well-founded proofs

We now apply the criterion to self-referential *proofs*. Model a (possibly non-well-founded) proof as a structure that may contain a sub-derivation referencing its own conclusion. Assign each such structure an **ordinal height**, the least ordinal bounding the lengths of its dependency chains, defined as the fixed point of the height functional induced by its sub-derivation structure.

**Principle 6.1 (Validity criterion).** *A self-referential proof is valid iff its height functional is a contraction on the ordinals — i.e., admits a (least) fixed point. Equivalently, each unfolding of the self-reference must occur at a strictly smaller ordinal (guardedness).*

**Proposition 6.2 (The proof of $P \Rightarrow P$ is a valid non-well-founded proof of height $1$).** Consider the derivation: *to prove $P \Rightarrow P$, assume $P$; the subgoal $P$ is then discharged immediately by the assumption.* The dependency loop closes in one step; its height functional is $h \mapsto 1$ (constant, hence contractive), with fixed point $h = 1$. The proof is valid with ordinal height $1$.

*Justification.* This is the proof-theoretic image of Theorem 3.1 in the degenerate guarded case: a self-reference that is resolved after a single, strictly-decreasing step. Formally it is a corecursive/coinductive derivation whose unique solution exists by the same bisimulation/fixed-point reasoning as Theorem 3.5. $\qquad\blacksquare$

**Proposition 6.3 (The liar sentence is not a valid non-well-founded proof).** Let $L$ assert its own unprovability. A purported derivation of $L$ must, by the content of $L$, reference a derivation of $L$ of the *same* size; the induced height functional is $h \mapsto h + 1$. The equation $h = h + 1$ has no ordinal solution; the functional is non-contractive (the loop does not shrink), so no fixed point — hence no well-defined height — exists.

*Justification.* This is the proof-theoretic image of Remark 3.3 (the $r = 1$ geometric series) and of $A_{c,b}$ with $c = 1$: loss of the contraction factor destroys the fixed point. The liar is therefore not a logical defect but the canonical *non-guarded* loop — the boundary that delimits the valid region. $\qquad\blacksquare$

**Consequence.** Self-referential proofs form a class of mathematical objects stratified by Principle 6.1: the guarded ones are valid (and, by the uniqueness theorems, determine their conclusions unambiguously), while the unguarded ones — the liar, Russell's predicate, the Gödel diagonal in its naive reading — are exactly the non-contractive failures. The paradoxes are not exceptions to be excised; they are the precise complement of the convergent loops.

---

## 7. Applications

- **Iterative numerics.** Algorithm A is the abstract template for fixed-point solvers (Newton-type schemes, value iteration in dynamic programming, Picard iteration for ODEs). The error bound of Theorem 3.8 is the convergence certificate.
- **Fractal geometry and compression.** Theorem 3.13 and the similarity dimension (§3.5) underlie iterated function systems: a fractal is the unique fixed point of a contraction on the space of compact sets, and fractal image compression stores the contraction rather than the image.
- **Design and aesthetics.** The metallic ratios (§3.4) govern self-similar tilings, rectangle subdivisions, and continued-fraction approximation quality (the golden ratio being the "most irrational" number).
- **Programming language semantics.** Coinduction (Theorem 3.5) is the foundation for reasoning about infinite data and non-terminating processes; guarded recursion (Principle 6.1) is the type-theoretic guarantee that a corecursive definition is productive.

---

## 8. Discussion

The contribution is conceptual rather than a single hard theorem: a *criterion* (contraction/guardedness) that simultaneously explains (i) why certain self-referential numbers, streams, shapes, and dimensions are well-defined, and (ii) why certain self-referential proofs are valid while the paradoxes are not. The two engines — contraction fixed points and coinduction — are complementary: the former is sharpest for finite-dimensional, quantitative statements (with explicit convergence rates), the latter for infinite objects (with bisimulation uniqueness). Their agreement on the geometric series / geometric stream pair (Theorems 3.2 and 3.5) is the technical evidence that "self-reference = self-similarity" is a single phenomenon rather than an analogy.

A limitation is that the proof-theoretic transport (§6) is presented at the level of a validity *criterion* keyed to ordinal-height fixed points; a fully general calculus of non-well-founded proofs (cut-elimination, normalization) is left open. The geometric core, by contrast, is complete and quantitative.

---

## 9. Future directions

*(Carried forward verbatim, lightly edited, from the upstream research program.)*

**Theme.** Across two cycles we established the thesis that *self-reference / non-well-foundedness = self-similarity*, realized by two formal engines — coinductive data and contraction fixed points — and unified the geometric series, the affine attractor, and the (golden / metallic) continued fractions as one phenomenon: *a quantity that is the unique solution of its own equation.*

**Closed conjectures.**
- *Bisimulation rigidity* — proved: the self-similarity law "tail equals scaling by $r$" with fixed head characterizes the geometric stream uniquely.
- *Metallic ratios* — proved: the golden lemmas generalize to the whole family $\varphi_m = (m + \sqrt{m^2+4})/2$ (defining quadratic, continued-fraction form, gnomon self-similarity, golden specialization).
- *Similarity dimension* — core proved: $D = \log k/\log(1/r)$ solves $k r^D = 1$ and is positive; monotonicity remains open (D3 below).

**Conjecture D1 — IFS attractor in $\mathbb{R}^n$ via Banach.** For an affine contraction $f(x) = Ax + b$ on $\mathbb{R}^n$ with operator norm $\|A\| < 1$, there is a unique self-referential point $x^\star = f(x^\star)$, every orbit $f^{(k)}(x_0) \to x^\star$, and $\|f^{(k)}(x_0) - x^\star\| \le \|A\|^k \|x_0 - x^\star\|$. *Test:* lift the one-dimensional affine theorems to $\mathbb{R}^n$ through the contraction/edist API. Falsified if no $\mathbb{R}^n$ statement closes under just $\|A\| < 1$.

**Conjecture D2 — Coinductive geometric trees and self-similar measure.** Define an infinite binary coinductive tree whose node at depth $d$ carries scale $r^d$. Conjecture: the depth-$d$ level holds $2^d$ copies of scale $r^d$, and the total-measure recursion $M = 1 + 2rM$ has the self-referential closed form $M = 1/(1 - 2r)$ for $2r < 1$ — the tree analogue of the geometric-series self-reference. *Test:* build the tree corecursively, prove the level identity by induction and the measure equation by fixed-point uniqueness.

**Conjecture D3 — Monotonicity of the similarity dimension.** $\mathrm{simDim}(k, r) = \log k/\log(1/r)$ is strictly increasing in $k$ (for $0 < r < 1$) and strictly increasing in $r$ on $(0,1)$ (for $k \ge 2$); moreover it is the unique real solving $k r^D = 1$. *Test:* prove both monotonicities and exponent uniqueness; falsified if either monotonicity reverses on any admissible $(k, r)$.

**Conjecture D4 — Mixed-ratio IFS and the Moran equation.** For a finite list of ratios $r_1, \dots, r_k \in (0,1)$, the similarity dimension is the unique $D$ solving the Moran equation $\sum_{i=1}^k r_i^{D} = 1$, generalizing the single-ratio balance $k r^D = 1$.

---

## 10. Conclusion

We have argued, with theorems, that the right way to think about self-reference is geometric: a self-referential definition names a unique object exactly when its loop contracts, and the named object is then a self-similar fixed point. This single criterion organizes the geometric series, infinite self-similar streams, affine attractors, the metallic ratios, and fractal dimension, and it draws a precise line through proof theory — validating the self-referential proof of $P \Rightarrow P$ while diagnosing the liar sentence as the canonical non-contractive loop. The paradox is not a wall but a boundary: on one side, the hall of mirrors converges to a single point; on the other, it runs forever. Knowing how to measure the difference turns self-reference from a hazard into a tool.
