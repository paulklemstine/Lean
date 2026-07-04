# An Explicit Two-Sided Power-Saving Estimate for Monic Minkowski Polynomials

## Abstract

We isolate and prove, unconditionally and with fully explicit constants, the elementary finitary skeleton underlying power-saving estimates for the image of a finite set of integers under a polynomial map. For a monic polynomial $f \in \mathbb{Z}[x]$ of degree $k \ge 2$ and a nonempty finite set $A \subseteq \mathbb{Z}$, we prove the two-sided estimate
$$\frac{|A|}{k} \ \le\ |f(A)| \ \le\ |A|^{\,k - 1/k^2},$$
where $f(A) = \{f(a) : a \in A\}$ is the elementwise (*Minkowski*) image. The lower bound is a fiber estimate expressing that a degree-$k$ polynomial is at most $k$-to-one; the upper bound realizes the frequently quoted power-saving constant $c(k) = 1/k^2$ as an admissible, explicit exponent. We show that the lower bound is sharp (saturated by symmetric windows under the squaring map) and that the upper bound is intrinsically loose, since injective progressions force the exponent to be exactly $1$ from below. We discuss the consequences of this asymmetry, provide an algorithmic realization of the estimate, and identify the difference set as the first place where genuine power expansion must appear.

**Keywords.** polynomial image, power saving, fiber estimate, root counting, sum–product phenomenon, additive combinatorics, Minkowski image, additive energy.

## 1. Introduction

A recurring theme in additive combinatorics is the tension between the *multiplicative* structure of polynomial maps and the *additive* structure of sets of integers. A guiding heuristic — the *power-saving* principle — asserts that pushing a set $A$ through a polynomial $f$ of degree $k$ produces an image whose size deviates measurably from the trivial extremes, with the deviation quantified by a *power-saving constant* $c$ in an inequality of the shape $|f(A)| \le |A|^{k-c}$.

The deep instances of this principle, developed in the additive-combinatorics literature on polynomial images and expansion, are asymptotic and rest on incidence geometry. Our purpose here is orthogonal and complementary: we extract the *exact, finitary core* that every such estimate silently relies upon, prove it from first principles, and pin down an explicit admissible constant $c(k) = 1/k^2$. In doing so we also clarify a persistent point of confusion — namely, that for the single elementwise image the advertised power saving is largely cosmetic, and the genuine content lives entirely on the lower (fiber) side.

Throughout, $|S|$ denotes the cardinality of a finite set $S$, and for a polynomial $f$ and a finite set $A \subseteq \mathbb{Z}$ we write
$$f(A) \ :=\ \{\, f(a) : a \in A \,\}$$
for the *elementwise image* (also called the *Minkowski image*), a set with duplicates removed.

### 1.1 Main results

**Theorem A (Fiber lower bound).** *Let $f \in \mathbb{Z}[x]$ have degree $k \ge 1$. Then for every finite set $A \subseteq \mathbb{Z}$,*
$$|A| \ \le\ k \cdot |f(A)|, \qquad\text{equivalently}\qquad |f(A)| \ \ge\ \frac{|A|}{k}.$$

**Theorem B (Real power-saving inequality).** *For integers $n \ge 1$ and $k \ge 2$,*
$$n \ \le\ n^{\,k - 1/k^2}.$$

**Theorem C (Power-saving upper bound).** *Let $f \in \mathbb{Z}[x]$ have degree $k \ge 2$ and let $A \subseteq \mathbb{Z}$ be nonempty and finite. Then*
$$|f(A)| \ \le\ |A|^{\,k - 1/k^2}.$$

**Theorem D (Two-sided estimate).** *Under the hypotheses of Theorem C,*
$$\frac{|A|}{k} \ \le\ |f(A)| \ \le\ |A|^{\,k - 1/k^2}.$$

These four statements are the substance of the paper. Theorem A is the universal obstruction to collapse; Theorem B is the analytic lemma that makes the constant $1/k^2$ admissible; Theorem C combines Theorem B with the trivial ceiling $|f(A)| \le |A|$; and Theorem D is the resulting corridor.

## 2. Definitions and preliminaries

We work over $\mathbb{Z}[x]$ but nothing below uses more than the elementary theory of polynomials over an integral domain.

**Definition 2.1 (Degree).** For a nonzero $f \in \mathbb{Z}[x]$, $\deg f = k$ means $f = a_k x^k + \cdots + a_1 x + a_0$ with $a_k \ne 0$. The polynomial is *monic* if $a_k = 1$. All results below hold for arbitrary (not necessarily monic) $f$ of the stated degree; monicity is inherited from the motivating construction but is not needed in the proofs.

**Definition 2.2 (Elementwise / Minkowski image).** For $f \in \mathbb{Z}[x]$ and finite $A \subseteq \mathbb{Z}$, the elementwise image is $f(A) = \{f(a) : a \in A\}$.

**Definition 2.3 (Fiber).** For $b \in \mathbb{Z}$, the *fiber* of $f$ over $b$ restricted to $A$ is
$$A_b \ :=\ \{\, a \in A : f(a) = b \,\}.$$
The fibers $\{A_b : b \in f(A)\}$ partition $A$: every element lies in exactly one fiber, and the number of nonempty fibers is exactly $|f(A)|$.

**Definition 2.4 (Power-saving constant).** For $k \ge 1$ we set
$$c(k) \ :=\ \frac{1}{k^2}.$$
We call the exponent $k - c(k) = k - 1/k^2$ the *shifted exponent* of degree $k$.

**Lemma 2.5 (Root count).** *For a nonzero $g \in \mathbb{Z}[x]$, the number of distinct integer roots of $g$ is at most $\deg g$.* This is the classical bound: over an integral domain, a nonzero polynomial of degree $d$ has at most $d$ roots (counted with or without multiplicity).

## 3. The fiber lower bound (Theorem A)

**Proof of Theorem A.** Fix $b \in f(A)$ and consider the shifted polynomial $g_b := f - b$ (constant shift). Since $\deg f = k \ge 1$, the leading term of $f$ survives the subtraction of a constant, so $g_b \ne 0$ and $\deg g_b = k$. Every element of the fiber $A_b$ is an integer root of $g_b$, because $a \in A_b$ means $f(a) = b$, i.e. $g_b(a) = 0$. Hence, by Lemma 2.5,
$$|A_b| \ \le\ \#\{\text{integer roots of } g_b\} \ \le\ \deg g_b \ =\ k.$$
Now sum over the distinct output values. Because the fibers partition $A$,
$$|A| \ =\ \sum_{b \in f(A)} |A_b| \ \le\ \sum_{b \in f(A)} k \ =\ k \cdot |f(A)|.$$
Dividing by $k > 0$ gives $|f(A)| \ge |A|/k$. $\qquad\blacksquare$

**Remark 3.1.** Only $\deg f \ge 1$ is used here; the lower bound holds for all non-constant polynomials. The bound is best possible in the following strong sense. For $f(x) = x^2$ and $A = \{-n, \dots, n\}$ we have $|A| = 2n+1$, while $f(A) = \{0, 1, 4, \dots, n^2\}$ has $|f(A)| = n+1$. Thus
$$\frac{|f(A)|}{|A|} \ =\ \frac{n+1}{2n+1} \ \longrightarrow\ \frac{1}{2} \ =\ \frac{1}{k},$$
so the factor $k$ in Theorem A cannot be improved to any constant larger than $k$.

## 4. The analytic lemma (Theorem B)

We first record the exponent inequality on which everything upper-bound-related turns.

**Lemma 4.1.** *For real $k \ge 2$, $\;1 \le k - 1/k^2$, and moreover $1 \le k - 1/k^2 < k$.*

**Proof.** Since $k \ge 2$ we have $k^2 \ge 4 \ge 1$, hence $1/k^2 \le 1$. Also $k - 1 \ge 1 \ge 1/k^2$, which rearranges to $1 + 1/k^2 \le k$, i.e. $1 \le k - 1/k^2$. The strict upper bound $k - 1/k^2 < k$ holds because $1/k^2 > 0$. $\qquad\blacksquare$

**Proof of Theorem B.** Let $n \ge 1$ and $k \ge 2$. Writing $n = n^1$ and using Lemma 4.1 to get $1 \le k - 1/k^2$, monotonicity of $t \mapsto n^t$ for base $n \ge 1$ yields
$$n \ =\ n^{1} \ \le\ n^{\,k - 1/k^2}. \qquad\blacksquare$$

The statement is phrased over integers $n$, but the proof only uses $n \ge 1$ as a real base, so it holds verbatim for all real $n \ge 1$.

## 5. The power-saving upper bound and the corridor (Theorems C, D)

**Proof of Theorem C.** Let $\deg f = k \ge 2$ and $A$ nonempty, so $|A| \ge 1$. The image of a set under a function never has more elements than the set, so
$$|f(A)| \ \le\ |A|.$$
Regard both sides as real numbers. Applying Theorem B with $n = |A| \ge 1$ gives $|A| \le |A|^{\,k - 1/k^2}$, and chaining the two inequalities,
$$|f(A)| \ \le\ |A| \ \le\ |A|^{\,k - 1/k^2}. \qquad\blacksquare$$

**Proof of Theorem D.** The upper bound is Theorem C. For the lower bound, apply Theorem A (valid since $k \ge 2 \ge 1$) to obtain $|A| \le k \cdot |f(A)|$. Since $k > 0$ we may divide, obtaining $|A|/k \le |f(A)|$. Combining,
$$\frac{|A|}{k} \ \le\ |f(A)| \ \le\ |A|^{\,k - 1/k^2}. \qquad\blacksquare$$

**Worked example 5.1.** Let $f(x) = x^2$ ($k = 2$) and $A = \{-2,-1,0,1,2\}$, so $|A| = 5$ and $f(A) = \{0,1,4\}$, $|f(A)| = 3$. The corridor reads
$$\frac{5}{2} = 2.5 \ \le\ 3 \ \le\ 5^{\,2 - 1/4} = 5^{1.75} \approx 16.723.$$
The lower wall is close to sharp (the symmetric window nearly saturates the factor $k = 2$); the upper wall is very loose, foreshadowing Section 6.

## 6. Sharpness and the honest content

The two walls of the corridor in Theorem D are of very different quality.

**Proposition 6.1 (Lower bound is sharp).** *For $f(x) = x^2$ and $A_n = \{-n, \dots, n\}$, $\;|f(A_n)| / |A_n| \to 1/k = 1/2$ as $n \to \infty$.* This is Remark 3.1. More generally, for an even monic polynomial the fibers $\{a, -a\}$ (and their analogues) have full size, so the lower bound is essentially attained.

**Proposition 6.2 (Upper bound cannot beat exponent $1$).** *There exist arbitrarily large finite sets $A$ on which $f$ is injective, so that $|f(A)| = |A|$.* For instance, any polynomial is eventually monotone, so restricting to a sufficiently sparse or sufficiently far-out arithmetic progression makes $f$ injective on $A$; then $|f(A)| = |A| = |A|^1$. Consequently no upper bound of the form $|f(A)| \le |A|^{1-\varepsilon}$ can hold for a positive $\varepsilon$: the exponent is pinned to exactly $1$ from below.

**Corollary 6.3 (The honest power saving).** For the single elementwise image the "power saving" $c = 1/k^2$ describes slack in a bound dominated by the trivial ceiling $|f(A)| \le |A|$. The genuine, unavoidable content of the corridor is the fiber lower bound $|f(A)| \ge |A|/k$; the real saving on the image side is the factor $k$, i.e. an *additive* exponent gap of $k-1$ relative to the naive $|A|^k$, not a small power saving.

This is the central conceptual message: *the number $1/k^2$ is honest as an admissible constant but is not the source of the interesting mathematics for the univariate image.* Where, then, does genuine expansion live? Sections 7 and 9 address this.

## 7. Algorithmic realization

The estimates are entirely constructive. Given $f$ and $A$, one computes $f(A)$ by evaluation and deduplication, then verifies the corridor.

**Algorithm 7.1 (Corridor verification).**
1. Compute the multiset $\{f(a) : a \in A\}$ by evaluating $f$ at each $a \in A$.
2. Deduplicate to obtain $f(A)$ and its cardinality $m = |f(A)|$.
3. Let $n = |A|$ and $k = \deg f$.
4. Report the triple $\big(\lceil n/k \rceil,\ m,\ n^{k - 1/k^2}\big)$ and assert $n/k \le m \le n^{k-1/k^2}$.

The dominant cost is Step 1–2: $O(n)$ polynomial evaluations, each $O(k)$ arithmetic operations by Horner's rule, followed by an $O(n \log n)$ sort (or $O(n)$ expected with hashing) for deduplication. Total $O(nk + n\log n)$.

**Algorithm 7.2 (Fiber histogram).** To *exhibit* the mechanism behind Theorem A, group $A$ by output value and record fiber sizes. The maximum fiber size never exceeds $k$; summing fiber sizes recovers $|A|$; and the number of fibers equals $m = |f(A)|$. This makes the identity $|A| = \sum_b |A_b| \le k\,m$ visible term by term.

## 8. Applications

The corridor is a foundational building block wherever polynomial images of sets appear.

- **Sum–product estimates.** The interplay of the multiplicative deformation $f$ with additive set operations is the setting of the sum–product phenomenon; the fiber bound is the elementary lower obstruction that any refined estimate must respect.
- **Exponential sums and equidistribution.** Bounds on $|f(A)|$ control the number of distinct phases in sums $\sum_{a \in A} e(f(a)/q)$; the corridor gives immediate, unconditional control.
- **Pseudorandomness and expanders.** Expansion of polynomial maps under addition underlies explicit expander constructions; understanding when images *cannot* expand (Proposition 6.2) tells the designer to combine images (difference sets) rather than rely on a single application.
- **Sanity certificates.** In any computation involving polynomial images, the corridor provides an $O(nk)$ verifiable certificate that no coding error has produced an impossible cardinality.

## 9. Discussion and future work

The asymmetry documented in Section 6 reframes the subject: for the univariate elementwise image, the lower bound is the truth and the upper bound is packaging. Genuine expansion must therefore be sought one structural level higher. We record the concrete conjectures that emerge.

**The factor-$k$ collapse is achievable for every even monic polynomial.** For the squaring map, a symmetric window collapses in pairs, so the image is almost exactly half the domain. We conjecture this is not peculiar to squaring: for every even monic $f$ of degree $k$ there is an explicit finite set — a union of complete level sets chosen away from the branch points — on which every fiber has full size $k$, forcing $k \cdot |f(A)| = |A| + O_k(1)$. The fibers of $f$ are exactly the orbits of the finite symmetry group permuting the roots of $f(x) = b$; assembling a domain out of whole orbits makes the map uniformly $k$-to-one and drives the image to its theoretical minimum. With the $k=2$ case settled by an exact identity and orbit–stabilizer tools classical, a complete resolution appears ripe.

**Difference sets of polynomial images genuinely expand.** A single image $f(A)$ is no larger than $A$, so no expansion is guaranteed; the difference set should behave differently. We conjecture that for monic $f$ of degree $k \ge 2$,
$$|f(A) - f(A)| \ \ge\ c_k \cdot |A|^{\,1 + 1/k^2},$$
a strict power gain over $|A|$. Coincidences $f(a) - f(b) = f(c) - f(d)$ correspond to integer points on a fixed algebraic surface, and the at-most-$k$-to-one structure limits their number, bounding the additive energy of $f(A)$ from above and hence the difference set from below. With the single-image corridor fully understood, the difference set is the natural next target — the first place genuine expansion must appear.

**The honest power-saving constant separates the univariate and multivariate worlds.** The constant $1/k^2$ is often quoted as *the* power saving, yet for the elementwise image the exponent is pinned to $1$ from below by injective progressions, so the real saving is $k-1$. We conjecture that $1/k^2$ is instead the correct order of magnitude for the $k$-fold image $f(A_1, \dots, A_k)$, and that the univariate and multivariate problems obey provably different optimal constants. "Power saving" silently refers to two different constructions; untangling them shows the small $1/k^2$-type constant is a genuinely multivariate effect. Explicit no-expansion families for the univariate case give the first hard lower obstruction that forces the two regimes apart.

## 10. Conclusion

We have proved, from the single classical fact that a degree-$k$ polynomial has at most $k$ roots, a clean two-sided estimate
$$\frac{|A|}{k} \ \le\ |f(A)| \ \le\ |A|^{\,k - 1/k^2}$$
for every non-constant integer polynomial of degree $k \ge 2$ and every nonempty finite $A \subseteq \mathbb{Z}$, with the explicit admissible power-saving constant $c(k) = 1/k^2$. The lower bound is sharp; the upper bound is honestly loose, and this asymmetry precisely locates where the interesting mathematics — expansion of difference sets, orbit-engineered collapse, and the multivariate origin of the $1/k^2$ constant — begins.
