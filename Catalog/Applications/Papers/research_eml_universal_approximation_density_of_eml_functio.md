# EML Universal Approximation: Single-Generator Density and Explicit Shallow Softplus Rates

**Author:** Aristotle
**Date:** 2026-06-21
**Domain:** Computation

---

## Abstract

We study the approximation power of the **EML function class** — functions assembled by composing the exponential map $\exp$, the logarithm $\log$, and the field operations of $\mathbb{R}$. We establish two complementary pillars. First, a *qualitative* density theory: a single injective continuous generator $g$ on a compact Hausdorff domain generates a unital subalgebra that is uniformly dense in $C(X,\mathbb{R})$, because injectivity is exactly the point-separation hypothesis of the Stone–Weierstrass theorem. Specializing to $g = \exp$ on $[0,1]$, the class of *real polynomials in $e^x$* — a depth-one EML class — is dense in $C([0,1],\mathbb{R})$. Second, a *quantitative* shallow-network theory: the depth-two **softplus** primitive $\mathrm{softplus}_\beta(x) = \beta^{-1}\log(1+e^{\beta x})$ approximates the ReLU nonlinearity $\max(x,0)$ with the sharp uniform rate $|\mathrm{softplus}_\beta(x) - \mathrm{relu}(x)| \le \beta^{-1}\log 2$, the constant $\log 2$ being attained at the kink $x=0$. This lifts to an explicit error bound $(\sum_i|c_i|)\,\beta^{-1}\log 2$ for any width-$N$ shallow network and yields a constructive choice of $\beta$ achieving any target accuracy $\varepsilon$. Together these results close the qualitative⇄quantitative loop for EML approximation: density in principle, and explicit shallow rates in practice. All results have been formally verified.

---

## 1. Introduction

Universal approximation theorems are the theoretical bedrock of approximation theory and of modern machine learning. The classical **Weierstrass theorem** states that polynomials are uniformly dense in $C([a,b],\mathbb{R})$; **Stone's** generalization replaces "polynomials" by "any point-separating subalgebra." In parallel, the **universal approximation theorems** for neural networks assert that single-hidden-layer networks with a suitable nonlinearity are dense in $C(K,\mathbb{R})$ for compact $K$.

This paper concerns a function class sitting at the intersection of these traditions: the **EML class**, generated from $\exp$, $\log$, and the field operations $+,-,\times,\div$. EML functions are precisely the closed-form expressions that arise pervasively in scientific computing and machine learning — softmax, log-sum-exp, log-likelihoods, sigmoids, softplus units, and exponential-family densities are all EML.

Three properties make the EML class a natural object of study. First, it is *closed under the operations that appear in practice*: composition, affine maps, products, quotients, and the two transcendental primitives. Second, it is *analytically tame*: away from the singularities of $\log$ and division, EML functions are real-analytic, so questions of smoothness, differentiability, and Taylor expansion are well posed. Third, it is *computationally explicit*: every EML function is a finite expression tree that can be evaluated, differentiated, and bounded mechanically. The price of this expressiveness is that the class is not a vector space (it is closed under products but its elements need not sum to EML expressions of bounded depth), so classical linear approximation theory does not apply verbatim; one must reason about the *subalgebras* the primitives generate, which is exactly the Stone–Weierstrass setting.

We contribute two pillars.

**Pillar I (qualitative).** We isolate the minimal hypothesis for density of a *singly generated* subalgebra and show it is **injectivity** of the generator. The argument is generator-agnostic, but the exponential is distinguished: it is an EML primitive, so $\mathrm{adjoin}_{\mathbb R}\{\exp\}$ is a genuine, depth-bounded EML class, and it is dense.

**Pillar II (quantitative).** We give explicit, $x$-uniform error bounds for the **softplus** EML primitive as an approximant of ReLU, with a sharp constant, and lift them to whole shallow networks with a fully explicit, auditable error budget.

### 1.1 Notation

Throughout, $X$ is a topological space; in the main theorems it is compact and Hausdorff ($T_2$). $C(X,\mathbb{R})$ denotes the $\mathbb{R}$-algebra of continuous real-valued functions on $X$, equipped with the uniform (supremum) norm
$$\|f\| = \sup_{x\in X}|f(x)|.$$
For a subset $S\subseteq C(X,\mathbb{R})$, $\mathrm{adjoin}_{\mathbb R}\,S$ (also written $\mathbb{R}[S]$) denotes the smallest unital $\mathbb{R}$-subalgebra containing $S$ — equivalently, all real polynomial expressions in the elements of $S$. A subalgebra $A$ **separates points** if for all $x\neq y$ in $X$ there exists $a\in A$ with $a(x)\neq a(y)$. The **topological closure** $\overline{A}$ is again a subalgebra; $A$ is *dense* iff $\overline{A} = C(X,\mathbb{R})$, i.e. $A.\mathrm{topologicalClosure} = \top$.

---

## 2. The EML function class

**Definition 2.1 (EML functions).** The class of *EML functions* is the smallest class of partial real functions containing the constants, the coordinate projections, $\exp$, and $\log$, and closed under addition, subtraction, multiplication, division (where defined), and composition. The **compositional depth** of an EML expression is the maximal number of nested $\exp/\log$ applications along any root-to-leaf path of its expression tree.

EML functions are the analytic "closed forms" of computation. Two depth strata organize our results:

- **Depth 1**: a single $\exp$ (or $\log$) layer, combined with arithmetic. Example: exponential polynomials $\sum_j c_j e^{jx}$.
- **Depth 2**: one $\exp$ followed by one $\log$. Example: the softplus unit $\beta^{-1}\log(1+e^{\beta x})$.

---

### 2.1 Why depth matters

The two depth strata above are not arbitrary; they mark a qualitative phase boundary. At depth $1$, exponential polynomials $\sum_j c_j e^{jx}$ form a *linear* space (a span of fixed basis functions), so their approximation theory is governed by the algebra they generate — and, as we show, that algebra is already dense. At depth $2$, the softplus introduces genuine *non-linearity in a single unit*: $\log(1+e^{\beta x})$ is neither a polynomial in $e^x$ of bounded degree nor an affine map, and it is precisely this two-layer structure that buys a *smooth* surrogate for the non-smooth ReLU corner. Thus depth-1 governs *what* can be approximated (everything), while depth-2 governs *how efficiently and how smoothly* a specific, practically important target (ReLU) can be matched.

## 3. Pillar I: Single-generator density

### 3.1 The Stone–Weierstrass engine

We take as given the Stone–Weierstrass density theorem in its subalgebra form.

**Theorem 3.1 (Stone–Weierstrass core).** *Let $X$ be compact Hausdorff and $A \le C(X,\mathbb{R})$ a unital subalgebra that separates points. Then $\overline{A} = C(X,\mathbb{R})$ (equivalently $A.\mathrm{topologicalClosure} = \top$), and consequently for every $f\in C(X,\mathbb{R})$ and every $\varepsilon>0$ there is $g\in A$ with $\|g-f\|<\varepsilon$.*

In the formal development this is `eml_topologicalClosure_eq_top_of_separatesPoints` (with its density and $\varepsilon$-forms `eml_dense_range_of_subalgebra_separatesPoints` and `eml_exists_uniform_approx`), packaged for EML use as `eml_universalApproximation`.

### 3.2 Injectivity is point separation

**Lemma 3.2 (single generator separates points).** *Let $g\in C(X,\mathbb{R})$ be injective. Then the subalgebra $\mathrm{adjoin}_{\mathbb R}\{g\}$ separates the points of $X$.*

*Proof sketch.* Fix $x\neq y$ in $X$. The defining property of separation requires producing a single member of the subalgebra that distinguishes $x$ and $y$. Since $g$ is injective, $g(x)\neq g(y)$, so $g$ itself is such a member — provided $g$ lies in the subalgebra it generates, which holds because $\{g\}\subseteq \mathrm{adjoin}_{\mathbb R}\{g\}$ (`Algebra.subset_adjoin`). The witness is therefore $g$ together with the inequality $g(x)\neq g(y)$, obtained by contraposing injectivity. $\qquad\blacksquare$

(Formal name: `eml_single_generator_separatesPoints`. Note the proof requires *neither* compactness *nor* Hausdorffness of $X$; those are needed only downstream by Stone–Weierstrass.)

### 3.3 Density and approximation from one generator

Combining Lemma 3.2 with Theorem 3.1 gives the central qualitative result.

**Theorem 3.3 (single-generator EML density).** *Let $X$ be compact Hausdorff and $g\in C(X,\mathbb{R})$ injective. Then*
$$\mathrm{adjoin}_{\mathbb R}\{g\}.\mathrm{topologicalClosure} = \top,$$
*i.e. real polynomials in the single generator $g$ are uniformly dense in $C(X,\mathbb{R})$.*

*Proof sketch.* Apply `eml_universalApproximation` to $A = \mathrm{adjoin}_{\mathbb R}\{g\}$, whose separation hypothesis is supplied by Lemma 3.2. $\qquad\blacksquare$

(Formal name: `eml_single_generator_dense`.)

**Corollary 3.4 (single-generator $\varepsilon$-approximation).** *Under the hypotheses of Theorem 3.3, for every $f\in C(X,\mathbb{R})$ and $\varepsilon>0$ there is a polynomial $p$ in $g$ with $\|p-f\|<\varepsilon$.*

(Formal name: `eml_single_generator_approx`; proved via `eml_exists_uniform_approx`. Only compactness, not $T_2$, is used in this $\varepsilon$-form.)

The argument is *generator-agnostic*: the identity of $g$ never enters beyond its injectivity. This is the precise sense in which single-generator density is "generic."

### 3.4 The exponential generator on $[0,1]$

We instantiate $X = [0,1]$ (compact and Hausdorff) and $g = \exp$.

**Definition 3.5 (exponential generator).** Let $\mathrm{expGen}\in C([0,1],\mathbb{R})$ be the restriction of $\exp$ to $[0,1]$, i.e. $\mathrm{expGen}(x) = e^{x}$ for $x\in[0,1]$. It is the composition of the continuous primitive $\exp$ with the (continuous) inclusion $[0,1]\hookrightarrow\mathbb{R}$, hence a depth-1 EML element of $C([0,1],\mathbb{R})$.

**Lemma 3.6 (injectivity of $\mathrm{expGen}$).** *$\mathrm{expGen}$ is injective.*

*Proof sketch.* If $e^{x}=e^{y}$ then $x=y$ by strict monotonicity of $\exp$ (`Real.exp_injective`); the subtype equality follows by `Subtype.ext`. $\qquad\blacksquare$

(Formal name: `expGen_injective`.)

**Theorem 3.7 (density of the exponential EML class).** *The subalgebra $\mathrm{adjoin}_{\mathbb R}\{\mathrm{expGen}\}$ — equivalently, all real exponential polynomials $\sum_{j=0}^{k} c_j e^{jx}$ — is uniformly dense in $C([0,1],\mathbb{R})$:*
$$\mathrm{adjoin}_{\mathbb R}\{\mathrm{expGen}\}.\mathrm{topologicalClosure} = \top.$$

*Proof sketch.* Immediate from Theorem 3.3 and Lemma 3.6. $\qquad\blacksquare$

(Formal name: `exp_subalgebra_dense_on_Icc`; the $\varepsilon$-form is `exp_subalgebra_approx_on_Icc`.)

**Remark 3.8.** The powers $\mathrm{expGen}^{\,j}$ are $x\mapsto e^{jx}$, so $\mathrm{adjoin}_{\mathbb R}\{\mathrm{expGen}\} = \mathrm{span}_{\mathbb R}\{1, e^{x}, e^{2x}, \dots\}$. Theorem 3.7 is thus the EML counterpart of the Weierstrass polynomial theorem with seed $e^x$ in place of $x$. Depth-1 EML already suffices for *qualitative* universality; deep towers are unnecessary for density.

---

## 4. Pillar II: Explicit shallow softplus rates

We now move from "an approximant exists" to "here is one, with this error." The vehicle is the depth-2 softplus primitive and its relationship to ReLU.

### 4.1 Definitions

**Definition 4.1 (ReLU).** $\mathrm{relu}(x) = \max(x,0)$.

**Definition 4.2 (softplus unit).** For steepness $\beta>0$,
$$\mathrm{softplus}_\beta(x) = \frac{\log\!\left(1 + e^{\beta x}\right)}{\beta}.$$
Reading inside-out — $\exp$, then $+1$, then $\log$, then scalar division — exhibits compositional depth exactly $2$. It is the simplest non-affine EML primitive.

### 4.2 The two-sided sandwich

**Lemma 4.3 (lower bound: softplus dominates ReLU).** *For all $x$ and all $\beta>0$, $\mathrm{relu}(x) \le \mathrm{softplus}_\beta(x)$.*

*Proof sketch.* For $x\ge 0$: $1 + e^{\beta x} \ge e^{\beta x}$, so $\log(1+e^{\beta x}) \ge \beta x$ and dividing by $\beta>0$ gives $\mathrm{softplus}_\beta(x)\ge x = \mathrm{relu}(x)$. For $x<0$: $1+e^{\beta x}>1$, so $\log(1+e^{\beta x})>0 = \mathrm{relu}(x)\cdot\beta$. Monotonicity of $\log$ closes both cases. $\qquad\blacksquare$

(Formal name: `softplus_ge_relu`.)

**Lemma 4.4 (upper bound: bounded overshoot).** *For all $x$ and all $\beta>0$,*
$$\mathrm{softplus}_\beta(x) \le \mathrm{relu}(x) + \frac{\log 2}{\beta}.$$

*Proof sketch.* The engine is the elementary inequality, valid for every real $t$,
$$1 + e^{t} \le 2\, e^{\max(t,0)}.$$
Indeed, if $t\ge 0$ then $1 + e^t \le e^t + e^t = 2e^t = 2e^{\max(t,0)}$; if $t<0$ then $1+e^t \le 1+1 = 2 = 2e^{0} = 2e^{\max(t,0)}$. Setting $t=\beta x$, taking $\log$ (monotone), and dividing by $\beta$:
$$\mathrm{softplus}_\beta(x) = \frac{\log(1+e^{\beta x})}{\beta} \le \frac{\log 2 + \max(\beta x,0)}{\beta} = \frac{\max(\beta x, 0)}{\beta} + \frac{\log 2}{\beta} = \mathrm{relu}(x) + \frac{\log 2}{\beta},$$
using $\max(\beta x, 0)/\beta = \max(x,0) = \mathrm{relu}(x)$ for $\beta>0$. $\qquad\blacksquare$

(Formal name: `softplus_le_relu_add`.)

### 4.3 The sharp depth-2 rate

**Theorem 4.5 (uniform softplus–ReLU rate).** *For all $x$ and all $\beta>0$,*
$$\bigl|\,\mathrm{softplus}_\beta(x) - \mathrm{relu}(x)\,\bigr| \le \frac{\log 2}{\beta}.$$
*The constant $\log 2$ is sharp, attained at $x=0$.*

*Proof sketch.* Lemma 4.3 gives $\mathrm{softplus}_\beta(x) - \mathrm{relu}(x) \ge 0$; Lemma 4.4 gives $\mathrm{softplus}_\beta(x) - \mathrm{relu}(x) \le \log 2/\beta$. Hence the absolute value is bounded by $\log 2/\beta$. Sharpness: at $x=0$, $\mathrm{relu}(0)=0$ while $\mathrm{softplus}_\beta(0) = \beta^{-1}\log(1+e^0) = \beta^{-1}\log 2$, so the bound is met with equality. $\qquad\blacksquare$

(Formal name: `abs_softplus_sub_relu_le`.)

The crucial feature is **uniformity in $x$**: the same bound holds on all of $\mathbb{R}$, not merely on a bounded interval. The error is governed solely by the steepness $\beta$ and decays as $O(1/\beta)$. The worst case lives at the kink $x=0$, where a smooth curve is intuitively least able to imitate a corner.

### 4.4 Lifting to shallow networks

**Definition 4.6 (shallow networks).** A width-$N$ shallow ReLU network and its softplus EML counterpart are
$$F_{\mathrm{ReLU}}(x) = \sum_{i=1}^N c_i\,\mathrm{relu}(a_i x + b_i), \qquad
F_{\mathrm{soft}}(x) = \sum_{i=1}^N c_i\,\mathrm{softplus}_\beta(a_i x + b_i).$$

**Theorem 4.7 (shallow-network error bound).** *For all $x$ and all $\beta>0$,*
$$\bigl|\,F_{\mathrm{soft}}(x) - F_{\mathrm{ReLU}}(x)\,\bigr| \le \left(\sum_{i=1}^N |c_i|\right)\frac{\log 2}{\beta}.$$

*Proof sketch.* By linearity and the triangle inequality,
$$|F_{\mathrm{soft}}(x) - F_{\mathrm{ReLU}}(x)| \le \sum_{i=1}^N |c_i|\,\bigl|\mathrm{softplus}_\beta(a_i x + b_i) - \mathrm{relu}(a_i x + b_i)\bigr| \le \sum_{i=1}^N |c_i|\,\frac{\log 2}{\beta},$$
each summand bounded by Theorem 4.5 (applied at the affine argument $a_i x + b_i$). $\qquad\blacksquare$

(Formal name: `shallow_approx`.)

**Theorem 4.8 (explicit accuracy on demand).** *Let $S = \sum_{i=1}^N|c_i|$ and let $\varepsilon>0$. If*
$$\beta > \frac{S\,\log 2}{\varepsilon},$$
*then $\|F_{\mathrm{soft}} - F_{\mathrm{ReLU}}\|_\infty < \varepsilon$; i.e. an explicit steepness achieves any target accuracy.*

*Proof sketch.* Substitute the stated $\beta$ into Theorem 4.7: $S\,\log 2/\beta < S\,\log2/(S\log2/\varepsilon) = \varepsilon$. (When $S=0$ the network is identically zero and any $\beta$ works.) $\qquad\blacksquare$

(Formal name: `shallow_eml_uniform_approx`.)

---

## 5. Algorithms

### 5.1 Single-generator approximation (conceptual)

Given an injective generator $g$ on a compact domain and a target $f$, Corollary 3.4 guarantees a polynomial $p(g) = \sum_{j=0}^k c_j g^j$ with $\|p(g)-f\|<\varepsilon$. Constructively, with $g=\exp$ on $[0,1]$, one fits coefficients $\{c_j\}$ by least-squares collocation on a fine grid against the basis $\{1,e^x,\dots,e^{kx}\}$ and increases the degree $k$ until the residual drops below $\varepsilon$. Density (Theorem 3.7) guarantees termination.

### 5.2 Softplus steepness selection

Given a shallow ReLU network with output weights $\{c_i\}$ and a tolerance $\varepsilon$, Theorem 4.8 prescribes $\beta = \lceil (1+\delta)\, S\log 2/\varepsilon\rceil$ for any margin $\delta>0$ with $S=\sum_i|c_i|$, after which the softplus surrogate is provably within $\varepsilon$ everywhere. This is an $O(N)$ computation (one pass over the weights) and requires no optimization.

---

## 6. Applications

1. **Certified surrogates for ReLU networks.** Theorem 4.8 converts any trained shallow ReLU network into a smooth, everywhere-differentiable EML network with a *provable* uniform error budget — useful for gradient-based downstream tasks (adversarial robustness certification, sensitivity analysis) that require smoothness.

2. **Exponential-basis function fitting.** Theorem 3.7 licenses fitting signals with exponential polynomials $\sum_j c_j e^{jx}$, natural for relaxation/decay phenomena, with a guarantee that the basis is asymptotically complete.

3. **Interpretability via shallow EML.** Single-hidden-layer softplus networks are simple enough to inspect and, by Pillar I, expressive enough to be universal in the limit — a favorable transparency/expressivity tradeoff.

---

## 6A. Relationship to classical and neural approximation theory

The two pillars sit at the confluence of three classical streams, and it is illuminating to place them precisely.

**Versus Weierstrass/Stone.** The Weierstrass theorem is the special case of Theorem 3.3 with generator $g(x)=x$ on $[a,b]$: the identity is injective, so its generated algebra (the ordinary polynomials) is dense. Theorem 3.7 replaces the seed $x$ by $e^x$; the proof is identical in structure, which is the whole point — *the seed is interchangeable as long as it is injective*. Stone's contribution was to identify separation as the governing condition; our contribution in Pillar I is to observe that for a *single* generator, separation collapses exactly to injectivity, a pointwise and easily checkable property.

**Versus neural universal approximation.** The classical Cybenko/Hornik universal approximation theorems state that finite sums $\sum_i c_i\,\sigma(a_i x + b_i)$ with a non-polynomial activation $\sigma$ are dense in $C(K,\mathbb R)$. These are *non-constructive* density statements with no rate. Pillar II is complementary and constructive: rather than appealing to abstract density of softplus combinations, it pins down the *exact* per-unit discrepancy between the EML softplus and the canonical ReLU, with a sharp constant, and propagates it through arbitrary finite combinations. In effect we trade generality (any $\sigma$) for precision (explicit constants for the specific, ubiquitous softplus/ReLU pair).

**Versus spectral methods.** Exponential polynomials $\mathrm{span}\{1,e^x,\dots,e^{kx}\}$ are a non-orthogonal spectral basis. Theorem 3.7 guarantees completeness of this basis; Conjecture 4 in Section 8 concerns its *rate* for analytic targets, where one expects geometric decay governed by an analyticity strip, mirroring the behavior of Chebyshev and Fourier spectral methods.

## 6B. On sharpness and the constant $\log 2$

It is worth dwelling on why $\log 2$ — and not some smaller constant — is unavoidable for the softplus. At the kink $x=0$ the two competing descriptions of the ReLU corner (the left branch $y=0$ and the right branch $y=x$) meet, and any smooth function passing between them must "round" the corner. The softplus rounds it by exactly $\beta^{-1}\log 2$, because $\mathrm{softplus}_\beta(0)=\beta^{-1}\log(1+e^0)=\beta^{-1}\log 2$ while $\mathrm{relu}(0)=0$. Since Theorem 4.5 shows the discrepancy never *exceeds* this value, the maximum is attained precisely at the corner and equals $\beta^{-1}\log 2$. No reparametrization of $\beta$ can reduce the constant without changing the unit; the constant is intrinsic to the softplus shape. This sharpness is what makes the downstream network bound (Theorem 4.7) tight in its dependence on $\beta$ and on the output-weight $\ell^1$ mass.

## 7. Discussion

The two pillars are complementary rather than redundant. Stone–Weierstrass (Pillar I) is *existential and non-quantitative*: it asserts an approximant exists in an enormous algebra, with no handle on degree, magnitude, or rate. The softplus analysis (Pillar II) is *constructive and quantitative*: it names an explicit approximant and bounds its error with the sharp constant $\log 2$. The phrase "qualitative⇄quantitative loop" captures the design: density tells us the EML class is *complete*; the shallow rate tells us the *cheapest non-linear EML primitive already pays off* at rate $O(1/\beta)$.

A subtle but important point is that the single-generator density proof uses *only* injectivity. Compactness and the Hausdorff property are spent solely inside the Stone–Weierstrass engine; the separation lemma itself is hypothesis-light. This explains why the result is "generic": almost any non-folding continuous primitive seeds a universal class.

Finally, the softplus bound's uniformity over all of $\mathbb{R}$ (not just $[0,1]$) means the shallow conversion theorem is domain-free: the $\varepsilon$ budget of Theorem 4.8 holds globally, which is exactly what one needs when the network's inputs are unbounded.

---

## 8. Future directions

**Conjecture 1 — Sharp depth-vs-rate law for softplus towers.** A depth-$d$ EML tower built by iterating the softplus unit (layer steepness $\beta_i$) approximates the $d$-fold ReLU composition with uniform error exactly $\sum_i L_i\,\log 2/\beta_i$, where $L_i$ is the product of downstream Lipschitz constants, and the leading constant $\log 2$ cannot be reduced at any layer. The per-layer gap is uniform in the input and attained at $x=0$, so layerwise worst cases telescope additively through the Lipschitz constants rather than compounding multiplicatively. The single-layer sharp constant (Theorem 4.5) and existing telescoping machinery make this the immediate next step.

**Conjecture 2 — Width–accuracy tradeoff for Lipschitz targets.** Every $L$-Lipschitz $f:[0,1]\to\mathbb{R}$ is approximated to uniform error $\varepsilon$ by a shallow softplus network of width $N=\lceil L/\varepsilon\rceil$ and steepness $\beta=\Theta(N\log 2/\varepsilon)$, giving total error $\le 2\varepsilon$. Continuous-piecewise-linear interpolation on a uniform $N$-grid gives error $L/N$ using $N$ ReLU units, and Theorem 4.7 converts each ReLU into an EML softplus unit at additive cost $(\sum_i|c_i|)\log 2/\beta$; balancing the two error sources fixes both $N$ and $\beta$. Only the CPWL interpolation error bound remains to be formalized.

**Conjecture 3 — Single-generator density is generic; parity is the only obstruction.** For continuous $g:[0,1]\to\mathbb{R}$, the subalgebra $\mathrm{adjoin}_{\mathbb R}\{g\}$ is dense in $C([0,1],\mathbb{R})$ **iff** $g$ is injective; for non-injective $g$, the closure is exactly the algebra of functions constant on the level sets of $g$. Lemma 3.2 gives injectivity ⇒ density; the converse follows because two points in a common level set of $g$ can never be separated by polynomials in $g$, and the level-set/pullback language is already available.

**Conjecture 4 — Exponential-class spectral approximation rate.** Approximating analytic $f$ on $[0,1]$ by $\mathrm{span}\{1,e^x,\dots,e^{kx}\}$ achieves geometric error decay $O(\rho^{-k})$ for some $\rho>1$ depending on the width of the analyticity strip of $f$, strictly faster than the algebraic $O(k^{-s})$ rate of polynomial approximation for $C^s$ targets.

---

## 9. Conclusion

We have established a self-contained, two-pillar approximation theory for the EML function class. Qualitatively, a single injective generator — in particular the depth-1 exponential primitive on $[0,1]$ — generates a uniformly dense subalgebra, because injectivity *is* the point-separation hypothesis of Stone–Weierstrass (Theorems 3.3, 3.7). Quantitatively, the depth-2 softplus primitive approximates ReLU with the sharp uniform rate $\log 2/\beta$ (Theorem 4.5), lifting to explicit, auditable error budgets for whole shallow networks (Theorems 4.7, 4.8). The combination yields both universality in principle and computable accuracy in practice.
