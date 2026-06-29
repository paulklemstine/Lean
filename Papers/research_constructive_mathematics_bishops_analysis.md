# A Constructive, Non-Circular Approximate Intermediate Value Theorem with Explicit Modulus

**Author:** Aristotle
**Date:** 2026-06-21
**Domain:** Novelty (Constructive Mathematics / Bishop-style Analysis)

## Abstract

The classical Intermediate Value Theorem (IVT) asserts that a continuous function changing sign on an interval has a root, but its standard proofs are non-constructive: they rely on the completeness of the reals (via a least-upper-bound) or on the topological connectedness of intervals, and they yield a root that may be uncomputable. Following the constructive program of Errett Bishop, we develop an **approximate** IVT that, given a tolerance $\varepsilon > 0$ and an explicit modulus of continuity for the function, locates a point $x$ in the interval with $|f(x)| \le \varepsilon$. The development is organized strictly bottom-up and is deliberately **non-circular**: it does not invoke the classical IVT, connectedness, preconnectedness, or any root-existence theorem. The analytic content is reduced to a single finite, order-theoretic lemma — `finite_sign_change` — which states that a finite list of reals running from non-positive to non-negative either hits zero or exhibits an adjacent sign change. From this we derive a discrete approximate IVT (`discrete_approx_ivt`), then an oriented modulus-based theorem on a uniform grid (`approx_ivt_of_modulus_nonpos_nonneg`), and finally a symmetric version handling either sign orientation (`approx_ivt_of_modulus`). We describe the grid construction, prove the supporting mesh estimates, present the algorithm and its complexity, discuss applications to certified numerical root-finding, and outline generalizations to bisection refinement and the multidimensional Poincaré–Miranda setting. All results have been formalized and machine-checked.

---

## 1. Introduction

### 1.1 Motivation

The Intermediate Value Theorem is among the first deep results a student of analysis meets:

> **(Classical IVT.)** If $f : [a,b] \to \mathbb{R}$ is continuous and $f(a) \le 0 \le f(b)$, then there exists $c \in [a,b]$ with $f(c) = 0$.

Despite its intuitive obviousness, the theorem is not constructively valid in its classical form. The obstruction is fundamental: equality and order on the real numbers are **not decidable**. Determining whether a real number is exactly zero, as opposed to extremely small but nonzero, would require examining infinitely much information. As a consequence, one can construct continuous functions whose unique sign-change point is not computable by any algorithm; the classical existence claim then has no algorithmic content.

Bishop's constructive analysis resolves this not by abandoning the theorem but by **reformulating the conclusion** into something an algorithm can deliver. Rather than demanding an exact root, we demand an *approximate* one:

> **(Approximate IVT, informal.)** For every tolerance $\varepsilon > 0$ there exists $x \in [a,b]$ with $|f(x)| \le \varepsilon$.

This conclusion is constructively provable, and its proof is an explicit terminating search, *provided* continuity is supplied in a quantitative form — a **modulus of continuity** — rather than the classical $\varepsilon$–$\delta$ form with a non-computable $\delta$.

### 1.2 Contribution

We present a fully formalized, bottom-up development of the approximate IVT with the following distinguishing features:

1. **Explicit modulus.** Continuity enters only through a pointwise uniform modulus hypothesis: there is a step size $\delta$ such that inputs within $\delta$ have outputs within $\varepsilon$.
2. **Non-circularity.** The proof uses neither the classical IVT, nor `IsPreconnected`, nor interval connectedness, nor any least-upper-bound or supremum argument. This is a design constraint, not an accident: it guarantees the result is genuinely a *from-scratch* constructive theorem rather than a repackaging of a classical one.
3. **Strict separation of concerns.** The combinatorial skeleton (a finite sign change) is isolated in a lemma about sequences `ℕ → ℝ` that mentions no continuity whatsoever. The analytic content (the modulus, the grid, the metric estimates) is layered on top.
4. **An explicit, finite, terminating algorithm** with linear step count in the number of subdivisions $N$, where $N$ is determined directly from the modulus and the requested tolerance.

The remainder of this paper states all definitions and results inline, gives proof sketches, presents the extracted algorithm and its complexity, and discusses applications and extensions.

---

## 2. Preliminaries and the Grid Construction

Throughout, $a, b, \delta, \varepsilon \in \mathbb{R}$ and $N, i \in \mathbb{N}$. We work on a closed interval $[a,b]$ with $a \le b$.

### 2.1 The uniform grid

**Definition 2.1 (Grid).** The *uniform grid* on $[a,b]$ with $N$ subdivisions assigns to index $i$ the node
$$
\operatorname{grid}(a,b,N,i) \;=\; a + \frac{i\,(b - a)}{N}.
$$
These are the $N+1$ equally spaced points $x_0, \dots, x_N$ partitioning $[a,b]$.

The construction satisfies four elementary but essential properties.

**Lemma 2.2 (Endpoints).**
$$\operatorname{grid}(a,b,N,0) = a, \qquad \operatorname{grid}(a,b,N,N) = b \quad (N > 0).$$
*Proof sketch.* For $i = 0$ the added term vanishes. For $i = N$, $\frac{N(b-a)}{N} = b - a$ after cancelling $N \ne 0$, and $a + (b-a) = b$. ∎

**Lemma 2.3 (Membership).** If $a \le b$, $0 < N$, and $i \le N$, then $\operatorname{grid}(a,b,N,i) \in [a,b]$.
*Proof sketch.* Since $0 \le i \le N$ we have $0 \le \frac{i(b-a)}{N} \le b - a$ (using $b - a \ge 0$ and $i/N \le 1$). Adding $a$ places the node in $[a,b]$. ∎

**Lemma 2.4 (Mesh / consecutive spacing).** If $a \le b$, $0 < N$, and the mesh satisfies $\frac{b-a}{N} \le \delta$, then for every $i$,
$$\bigl|\operatorname{grid}(a,b,N,i+1) - \operatorname{grid}(a,b,N,i)\bigr| \;\le\; \delta.$$
*Proof sketch.* The difference of consecutive nodes is exactly $\frac{b-a}{N} \ge 0$, so its absolute value equals $\frac{b-a}{N}$, which is bounded by $\delta$ by hypothesis. ∎

Lemmas 2.2–2.4 are the only facts about the grid the main theorem needs: the endpoints align with $a$ and $b$, all nodes lie in the interval, and consecutive nodes are within the modulus step $\delta$.

---

## 3. The Combinatorial Core

The genuinely indispensable idea is a purely finite statement about sequences of reals — no continuity, no metric, no limits.

### 3.1 Finite sign change

**Theorem 3.1 (`finite_sign_change`).** Let $u : \mathbb{N} \to \mathbb{R}$ and $N \in \mathbb{N}$ with $u_0 \le 0$ and $u_N \ge 0$. Then
$$
\bigl(\exists\, i \le N,\; u_i = 0\bigr) \quad\lor\quad \bigl(\exists\, i < N,\; u_i \le 0 \;\land\; 0 \le u_{i+1}\bigr).
$$
That is, either some node is exactly zero, or there is an adjacent pair across which the sign changes from non-positive to non-negative.

*Proof sketch.* Argue by contradiction: assume neither disjunct holds. Then (a) no node equals zero, and (b) no adjacent pair $(u_i, u_{i+1})$ has $u_i \le 0 \le u_{i+1}$. We prove by induction on $i$ that $u_i < 0$ for all $i \le N$. Base case: $u_0 \le 0$ and $u_0 \ne 0$ (by (a)), hence $u_0 < 0$. Inductive step: if $u_i < 0$ for $i < N$, then $u_{i+1} \ge 0$ would yield $u_i \le 0 \le u_{i+1}$, contradicting (b); so $u_{i+1} < 0$. Taking $i = N$ gives $u_N < 0$, contradicting $u_N \ge 0$. Hence one of the disjuncts holds. ∎

The proof uses only induction over $\mathbb{N}$ and trichotomy/linear order on $\mathbb{R}$ at finitely many tested points; this is precisely the decidable, finite skeleton of the IVT.

### 3.2 The discrete approximate IVT

**Theorem 3.2 (`discrete_approx_ivt`).** Let $u : \mathbb{N} \to \mathbb{R}$, $N \in \mathbb{N}$, and $\varepsilon \ge 0$. Suppose $u_0 \le 0$, $u_N \ge 0$, and consecutive steps are controlled,
$$\forall\, i < N,\quad |u_{i+1} - u_i| \le \varepsilon.$$
Then there exists $i \le N$ with $|u_i| \le \varepsilon$.

*Proof sketch.* Apply Theorem 3.1. In the first case, some $u_i = 0$, so $|u_i| = 0 \le \varepsilon$. In the second case, there is $i < N$ with $u_i \le 0 \le u_{i+1}$. From $u_{i+1} \ge 0$ and $|u_{i+1} - u_i| \le \varepsilon$ with $u_i \le 0$, we get $0 \le u_{i+1} = (u_{i+1} - u_i) + u_i \le (u_{i+1} - u_i) \le \varepsilon$ (since $u_i \le 0$). Hence $|u_{i+1}| \le \varepsilon$, and $i + 1 \le N$. ∎

This theorem already *is* the approximate IVT for sequences. Everything that follows transfers it to continuous functions via the grid.

---

## 4. The Modulus-Based Approximate IVT

### 4.1 The oriented theorem

**Theorem 4.1 (`approx_ivt_of_modulus_nonpos_nonneg`).** Let $f : \mathbb{R} \to \mathbb{R}$, $a \le b$, $\varepsilon \ge 0$, $\delta > 0$, and $N > 0$, with mesh bound
$$\frac{b - a}{N} \le \delta,$$
endpoint signs
$$f(a) \le 0 \le f(b),$$
and an explicit modulus of continuity on $[a,b]$:
$$
\forall\, x, y \in [a,b],\quad |y - x| \le \delta \;\Longrightarrow\; |f(y) - f(x)| \le \varepsilon.
$$
Then there exists $x \in [a,b]$ with $|f(x)| \le \varepsilon$.

*Proof sketch.* Define the grid sample sequence $u_i := f(\operatorname{grid}(a,b,N,i))$. We verify the hypotheses of Theorem 3.2:

- $u_0 = f(\operatorname{grid}(a,b,N,0)) = f(a) \le 0$ by Lemma 2.2 and the left sign hypothesis.
- $u_N = f(\operatorname{grid}(a,b,N,N)) = f(b) \ge 0$ by Lemma 2.2 (using $N > 0$) and the right sign hypothesis.
- For $i < N$, both $\operatorname{grid}(a,b,N,i)$ and $\operatorname{grid}(a,b,N,i+1)$ lie in $[a,b]$ (Lemma 2.3), and their distance is $\le \delta$ (Lemma 2.4). The modulus hypothesis then gives $|u_{i+1} - u_i| \le \varepsilon$.

By Theorem 3.2 there is $i \le N$ with $|u_i| \le \varepsilon$. Setting $x := \operatorname{grid}(a,b,N,i)$, Lemma 2.3 gives $x \in [a,b]$ and $|f(x)| = |u_i| \le \varepsilon$. ∎

**Remark 4.2 (On the hypothesis $\delta > 0$).** The strict positivity $\delta > 0$ is part of the requested interface but is not actually used by the oriented proof; the mesh bound $\frac{b-a}{N} \le \delta$ together with the modulus hypothesis suffices. It is retained only to match the conventional statement of a modulus of continuity, where the step is positive.

### 4.2 The symmetric theorem

**Theorem 4.3 (`approx_ivt_of_modulus`).** Under the same hypotheses as Theorem 4.1 except that the sign condition is replaced by either orientation,
$$
\bigl(f(a) \le 0 \,\land\, 0 \le f(b)\bigr) \;\lor\; \bigl(0 \le f(a) \,\land\, f(b) \le 0\bigr),
$$
there exists $x \in [a,b]$ with $|f(x)| \le \varepsilon$.

*Proof sketch.* If the first orientation holds, apply Theorem 4.1 directly. If the second holds, apply Theorem 4.1 to $g := -f$. The endpoint signs become $g(a) = -f(a) \le 0 \le -f(b) = g(b)$, and $g$ inherits the modulus property because $|g(y) - g(x)| = |{-}(f(y) - f(x))| = |f(y) - f(x)|$. The conclusion $|g(x)| \le \varepsilon$ is identical to $|f(x)| \le \varepsilon$. ∎

This is the most general statement: it requires only that the two endpoint values straddle zero in *some* order, which is the honest constructive analogue of "$f$ changes sign on $[a,b]$."

---

## 5. The Algorithm

The proof of Theorem 4.1 is constructive and yields the following procedure.

### 5.1 Grid search for an approximate crossing

**Input:** interval $[a,b]$ with $a \le b$; tolerance $\varepsilon > 0$; modulus step $\delta > 0$ valid for $f$ on $[a,b]$ at tolerance $\varepsilon$; endpoint values with $f(a) \le 0 \le f(b)$ (or the reversed orientation).

**Steps:**

1. Choose $N := \lceil (b-a)/\delta \rceil$ (any $N$ with $(b-a)/N \le \delta$ works), and ensure $N \ge 1$.
2. Form the $N+1$ grid nodes $x_i = a + \frac{i(b-a)}{N}$.
3. Evaluate (or comparably approximate) $f$ at the nodes. Find the first index $i$ with $u_i \le 0 \le u_{i+1}$ (or an exact zero $u_i = 0$).
4. Return that boundary node (the non-negative member of the straddling pair, or the exact zero).

**Output:** a node $x \in [a,b]$ with the certified guarantee $|f(x)| \le \varepsilon$.

### 5.2 Complexity

The search inspects at most $N + 1$ grid points and performs $O(N)$ comparisons, with
$$N = \Bigl\lceil \frac{b-a}{\delta} \Bigr\rceil.$$
The cost is therefore linear in the ratio of the interval length to the modulus step. Because $\delta$ is determined by the function's steadiness at the requested tolerance $\varepsilon$, the entire cost is an explicit, finite function of $(a, b, \varepsilon, \delta)$. There is no hidden unbounded search and no appeal to an uncomputable object.

### 5.3 On decidability of the comparisons

In exact real arithmetic, the comparison $u_i \le 0 \le u_{i+1}$ is not decidable. However, the algorithm never needs the *exact* sign of $f$ at a node — only a comparison accurate to within $\varepsilon$. A certified inexact comparator (e.g. a rational/dyadic approximation of $f$ with a known error bound below $\varepsilon$) is sufficient to drive the finite search, which is why the procedure is implementable in practice (see §7 and §8).

---

## 6. Discussion: Why Non-Circularity Matters

The classical IVT is typically proved in one of two ways: (i) via the **least-upper-bound** principle, taking $c = \sup\{x : f(x) \le 0\}$ and showing $f(c) = 0$; or (ii) via **connectedness**, observing that the continuous image of a connected interval is connected, hence an interval, hence contains $0$. Both proofs are short and elegant, and both are non-constructive: the supremum in (i) need not be computable, and the connectedness argument in (ii) is a pure existence statement that exhibits no point.

The development here deliberately avoids both routes. It uses:
- no `intermediate_value_Icc` or any classical IVT lemma;
- no `IsPreconnected`, no interval connectedness;
- no least-upper-bound, supremum, or completeness argument;
- no root-existence theorem of any kind.

The *only* nontrivial existence step is the finite sign-change lemma (Theorem 3.1), whose proof is a finite induction over tested order relations. This makes the construction genuinely foundational: it could serve as the *definition* of the constructive content of the IVT, rather than as a corollary of the classical theorem. The strict layering — finite combinatorics, then grid metrics, then the modulus — also makes each ingredient independently reusable.

A second benefit is conceptual transparency. Classical proofs hide *where* the crossing comes from inside an abstract supremum. The grid proof shows exactly where: at the unique adjacent pair, isolated by Theorem 3.1, where the sampled sequence turns over. One can literally carry out the search by hand.

---

## 7. Applications

**Certified numerical root-finding.** Every practical root-finder (bisection, regula falsi, Newton with bracketing) returns a point where $|f(x)|$ is small, not a provably exact root. Theorem 4.3 is the rigorous specification such routines meet: given a modulus and a tolerance, output a certified near-root. The theorem's guarantee is exactly the postcondition a verified numerical library would advertise.

**Approximate equation solving.** To solve $f(x) = t$ approximately, apply the theorem to $g(x) = f(x) - t$; the modulus of $g$ equals that of $f$. This yields certified approximate solutions to transcendental and algebraic equations alike, with an explicit accuracy contract.

**Teaching constructive analysis.** Because the proof separates a transparent finite lemma from the analytic packaging, it is a clean pedagogical illustration of how Bishop-style mathematics replaces non-constructive existence with explicit search, and of the precise role played by the modulus of continuity.

---

## 8. Future Directions

**A fully computable approximate-root finder with verified complexity.** The present development exhibits the approximate root as one of $N+1$ grid samples but stops short of an executable function returning the index, because exact real comparison is undecidable. Parametrizing the search by a *decidable sign oracle* — a rational/dyadic approximation of $f$ with a known error bound — would yield an extracted `findApproxRoot` together with a proof that its output satisfies $|f(x)| \le \varepsilon$ and an $O(N)$ step count. The key insight is that the approximate IVT never needs the exact sign of $f$ at a grid point, only a comparison accurate to within $\varepsilon$, so a certified inexact comparator suffices to drive the entire finite search.

**Logarithmic-depth bisection refinement.** The uniform grid gives a search linear in $N$. A bisection variant that repeatedly halves the bracketing interval would give an $O(\log N)$ approximate root at the same accuracy, while still avoiding any exact-zero claim. The finite sign-change lemma already isolates a single straddling adjacent pair; applying the same minimization recursively on halves turns the one-shot grid into a constructive bisection with an explicit contraction rate. The recursion needs only a termination measure and a mesh-halving lemma — standard `Nat`-recursion patterns supported by the current lemma set.

**Multidimensional generalization (Poincaré–Miranda).** The Poincaré–Miranda theorem is the $n$-dimensional analogue of the IVT for maps of a box into $\mathbb{R}^n$ with sign conditions on opposite faces. An approximate, constructive version on a product grid would substantially generalize this work. The one-dimensional finite sign-change mechanism is essentially a discrete-degree/parity argument; the higher-dimensional case reduces to a finite combinatorial lemma on a triangulated grid (a Sperner-style labeling) that, like `finite_sign_change`, carries no analytic content. The same strict separation between finite combinatorics and modulus of continuity demonstrated here points directly to the multidimensional statement.

---

## 9. Conclusion

We have given a constructive, non-circular, machine-checked approximate intermediate value theorem with an explicit modulus of continuity. The argument reduces all analytic existence to a single finite order lemma (`finite_sign_change`), lifts it to sequences (`discrete_approx_ivt`), and transfers it to continuous functions via a uniform grid with elementary mesh estimates, yielding both an oriented theorem (`approx_ivt_of_modulus_nonpos_nonneg`) and a symmetric one (`approx_ivt_of_modulus`). The result is an explicit terminating algorithm of linear cost whose accuracy is contracted in advance by the requested tolerance. This realizes, in miniature, Bishop's program: a classical theorem rebuilt so that its existence claim is backed by a construction one can actually run.

---

## Appendix A: Summary of Formal Results

| Name | Statement (informal) |
|---|---|
| `grid` | Definition of the $i$-th uniform node $a + i(b-a)/N$. |
| `grid_zero` | $\operatorname{grid}(a,b,N,0) = a$. |
| `grid_last` | $\operatorname{grid}(a,b,N,N) = b$ for $N > 0$. |
| `grid_mem_Icc` | Every node with $i \le N$ lies in $[a,b]$. |
| `grid_succ_dist_le` | Consecutive nodes are within $\delta$ when $(b-a)/N \le \delta$. |
| `finite_sign_change` | A finite list from non-positive to non-negative hits zero or changes sign across an adjacent pair. |
| `discrete_approx_ivt` | A bounded-step sequence from non-positive to non-negative has an entry of size $\le \varepsilon$. |
| `approx_ivt_of_modulus_nonpos_nonneg` | Oriented approximate IVT via modulus and uniform grid. |
| `approx_ivt_of_modulus` | Symmetric approximate IVT for either sign orientation. |
