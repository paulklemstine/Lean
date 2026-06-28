# Rank-One EML Kolmogorov–Arnold Representations: Separability as the Exact Frontier

**Author:** Aristotle

**Date:** 2026-06-28

**Domain:** Applications (Kolmogorov–Arnold representation; exp–log–multiply function classes; interpretable machine learning)

---

## Abstract

The Kolmogorov–Arnold superposition theorem states that every continuous function $f:[0,1]^n\to\mathbb{R}$ can be written as $f(x)=\sum_{q=0}^{2n}\Phi_q\big(\sum_{p=1}^{n}\psi_{q,p}(x_p)\big)$ for continuous univariate functions $\Phi_q,\psi_{q,p}$. The theorem is purely existential: the inner functions it produces are notoriously irregular and uncomputable. We investigate a constructive refinement: requiring all inner and outer functions to be **EML terms** — finite compositions of $\exp$, $\log$, addition, multiplication, and constants. We focus on the leanest possible superposition, the **rank-one EML representation** $f(x)=\exp\big(\sum_i \psi_i(x_i)\big)$, a single outer $\exp$ over a sum of $n$ univariate inner functions.

Our central result is an exact characterization: a target admits a rank-one EML representation **if and only if** it is a product of strictly positive univariate factors (*multiplicative separability*). In two variables we further show that separability is equivalent to a finite, checkable four-point invariant — the *cross-multiplicative identity* $f(x,y)\,f(x',y')=f(x,y')\,f(x',y)$ — and that any strictly positive target passing this test has an explicit, continuity-preserving rank-one EML representation. We exhibit the product $x\cdot y$ as the canonical rank-one target ($x\cdot y=\exp(\log x+\log y)$) and prove a sharp obstruction: the additive target $x+y$ fails the four-point test and therefore admits **no** rank-one EML representation. We also analyze the local-vs-global tension, isolating exp/log depth as the invariant that separates interior-only transcendental representations from globally valid polynomial ones. All results are formalized and machine-verified. We close with conjectures extending the theory to higher rank, where we conjecture EML rank coincides with the rank of the target's value matrix.

---

## 1. Introduction

### 1.1 Hilbert's 13th problem and the Kolmogorov–Arnold theorem

Hilbert's thirteenth problem asked whether every continuous function of several variables can be expressed through superpositions of continuous functions of fewer variables. Kolmogorov (1957) and Arnold answered affirmatively in the strongest form: only univariate functions and a single binary operation, addition, are needed.

**Theorem (Kolmogorov–Arnold).** *For every $n\ge 2$ there exist continuous functions $\psi_{q,p}:[0,1]\to\mathbb{R}$ ($0\le q\le 2n$, $1\le p\le n$) such that for every continuous $f:[0,1]^n\to\mathbb{R}$ there are continuous functions $\Phi_q:\mathbb{R}\to\mathbb{R}$ with*
$$f(x_1,\dots,x_n)=\sum_{q=0}^{2n}\Phi_q\!\left(\sum_{p=1}^{n}\psi_{q,p}(x_p)\right).$$

The representation uses $2n+1$ outer functions. Its weakness is constructive: the inner functions $\psi_{q,p}$ are continuous but highly non-smooth (typically nowhere differentiable on a dense set), and no closed form is available.

### 1.2 The EML refinement

The recent emergence of Kolmogorov–Arnold Networks (KANs) — architectures that place learnable univariate functions on network edges — has revived interest in *constructive* superpositions, where the univariate functions are drawn from a tractable, interpretable family. We study one such family.

**Definition 1 (EML term).** An *EML term* (exp–log–multiply term) is an element of the inductive syntax generated from a variable symbol $\mathrm{var}$ and real constants $\mathrm{const}(c)$ by the binary operations $\mathrm{add}$, $\mathrm{mul}$ and the unary operations $\mathrm{expOf}$, $\mathrm{logOf}$. Its semantics is the evaluation map $\llbracket\cdot\rrbracket:\mathrm{EMLTerm}\to(\mathbb{R}\to\mathbb{R})$ defined recursively by
$$\llbracket\mathrm{var}\rrbracket(x)=x,\quad \llbracket\mathrm{const}(c)\rrbracket(x)=c,$$
$$\llbracket t_1+t_2\rrbracket(x)=\llbracket t_1\rrbracket(x)+\llbracket t_2\rrbracket(x),\quad \llbracket t_1\cdot t_2\rrbracket(x)=\llbracket t_1\rrbracket(x)\cdot\llbracket t_2\rrbracket(x),$$
$$\llbracket\mathrm{expOf}\,t\rrbracket(x)=\exp\!\big(\llbracket t\rrbracket(x)\big),\quad \llbracket\mathrm{logOf}\,t\rrbracket(x)=\log\!\big(\llbracket t\rrbracket(x)\big).$$

We attach two structural complexity measures to a term. Its **width** counts leaf nodes; its **exp/log depth** $\mathrm{elDepth}$ counts the maximal nesting of $\exp$/$\log$ operators (ignoring $+$, $\times$, constants). Thus a polynomial has $\mathrm{elDepth}=0$, while $\exp(\log x)$ has $\mathrm{elDepth}=1$. Two canonical terms recur throughout: the **outer exponential** $\mathrm{outerExp}=\mathrm{expOf}\,\mathrm{var}$ (i.e. $u\mapsto e^u$) and the **inner logarithm** $\mathrm{innerLog}=\mathrm{logOf}\,\mathrm{var}$ (i.e. $t\mapsto\log t$). A basic verified semantic fact is the cancellation
$$\llbracket\mathrm{expOf}(\mathrm{logOf}\,\mathrm{var})\rrbracket(x)=x\quad(x>0),$$
recorded as `eval_expOf_logOf_var`.

**The conjecture under test.** *The inner and outer univariate functions in a Kolmogorov–Arnold representation can be chosen to be EML terms.* This paper resolves the conjecture for the **rank-one** stratum and for the building-block targets $x\cdot y$ and $x+y$.

### 1.3 Rank-one representations

**Definition 2 (rank-one EML representation).** A function $f:(\mathrm{Fin}\,n\to\mathbb{R})\to\mathbb{R}$ has a *rank-one EML representation* if there exist univariate functions $\psi_1,\dots,\psi_n$ with
$$f(x)=\exp\!\left(\sum_{i} \psi_i(x_i)\right)\quad\text{for all }x.$$
We denote this predicate `RankOneEMLn f`. It is the cleanest conceivable Kolmogorov–Arnold superposition: outer count $1$, inner count $n$, dramatically below the worst-case $2n+1$.

The principal contributions are:
1. an exact characterization of rank-one EML targets as positive product-separable functions (Section 3);
2. a finite four-point test (the cross-multiplicative identity) detecting separability, with explicit reconstruction and continuity transfer (Section 4);
3. a sharp obstruction separating multiplication from addition (Section 5);
4. an analysis of the local-vs-global trade-off via exp/log depth (Section 6).

All statements named in `typewriter font` are machine-verified.

---

## 2. The canonical target: the product functional

We begin with the source of all the structure: the product, where the classical slide-rule identity $\log(xy)=\log x+\log y$ does the work.

**Theorem 1 (rank-one representation of the product, $n=2$; `mul_eq_expLog`).** *For $x,y>0$,*
$$x\cdot y=\llbracket\mathrm{outerExp}\rrbracket\big(\llbracket\mathrm{innerLog}\rrbracket(x)+\llbracket\mathrm{innerLog}\rrbracket(y)\big)=\exp(\log x+\log y).$$

*Proof sketch.* Unfold the evaluation of $\mathrm{outerExp}$ and $\mathrm{innerLog}$ to reduce to $\exp(\log x+\log y)$. Apply $\exp(a+b)=\exp a\cdot\exp b$ and then $\exp(\log x)=x$, $\exp(\log y)=y$ (valid since $x,y>0$). $\qquad\blacksquare$

This generalizes verbatim to arbitrary arity.

**Theorem 2 ($n$-ary product is rank-one; `prod_eq_exp_sum_log`).** *Let $s$ be a finite index set and $f:\iota\to\mathbb{R}$ with $f(i)>0$ for all $i\in s$. Then*
$$\prod_{i\in s} f(i)=\exp\!\left(\sum_{i\in s}\log f(i)\right).$$

*Proof sketch.* Rewrite $\sum_{i\in s}\log f(i)=\log\prod_{i\in s} f(i)$ using `Real.log_prod` (all factors nonzero), then cancel with $\exp(\log P)=P$, valid because $P=\prod_{i\in s} f(i)>0$ by `Finset.prod_pos`. $\qquad\blacksquare$

In EML-term form this is `prod_eq_outerExp_sum_innerLog`: $\prod_{i\in s} f(i)=\llbracket\mathrm{outerExp}\rrbracket\big(\sum_{i\in s}\llbracket\mathrm{innerLog}\rrbracket(f(i))\big)$. The single outer function is $\exp$ and the single inner function $\log$ is *shared* across all coordinates — rank one for every $n$. Specializing to two elements recovers Theorem 1 (`mul_eq_expLog_via_prod`), confirming consistency.

---

## 3. The characterization: rank-one EML = positive product separability

We now classify exactly which targets are rank-one EML.

**Definition 3 (product separability; `ProdSeparable`).** $f:(\mathrm{Fin}\,n\to\mathbb{R})\to\mathbb{R}$ is *product-separable* if there exist univariate factors $a_1,\dots,a_n$ with $a_i(t)>0$ for all $i,t$ and $f(x)=\prod_i a_i(x_i)$ for all $x$.

**Theorem 3 (characterization; `rankOneEMLn_iff_prodSeparable`).** *For every $f:(\mathrm{Fin}\,n\to\mathbb{R})\to\mathbb{R}$,*
$$\mathrm{RankOneEMLn}(f)\iff \mathrm{ProdSeparable}(f).$$

The theorem decomposes into two verified directions.

**Lemma 3a (separable $\Rightarrow$ rank-one; `rankOneEMLn_of_prodSeparable`).** *If $f(x)=\prod_i a_i(x_i)$ with each $a_i>0$, then $f$ is rank-one EML with inner functions $\psi_i=\log\circ\, a_i$.*

*Proof sketch.* Take $\psi_i(t)=\log(a_i(t))$. Then $\exp(\sum_i\psi_i(x_i))=\prod_i\exp(\log a_i(x_i))=\prod_i a_i(x_i)=f(x)$, using $\exp$ of a sum equals the product of $\exp$ (`Real.exp_sum`) and $\exp(\log a)=a$ for $a>0$. $\qquad\blacksquare$

**Lemma 3b (rank-one $\Rightarrow$ separable; `prodSeparable_of_rankOneEMLn`).** *If $f(x)=\exp(\sum_i\psi_i(x_i))$, then $f$ is product-separable with factors $a_i=\exp\circ\,\psi_i$, which are automatically strictly positive.*

*Proof sketch.* Set $a_i(t)=\exp(\psi_i(t))>0$. By `Real.exp_sum`, $\exp(\sum_i\psi_i(x_i))=\prod_i\exp(\psi_i(x_i))=\prod_i a_i(x_i)$. $\qquad\blacksquare$

The bridge is the homomorphism property of $\exp$: a sum of inner contributions becomes a product of positive outer factors. Phrased through the term algebra (`rankOneEMLn_eml`), the single outer function is exactly $\mathrm{outerExp}=\mathrm{expOf}\,\mathrm{var}$, so $f(x)=\llbracket\mathrm{outerExp}\rrbracket\big(\sum_i\psi_i(x_i)\big)$.

**Canonical instance.** The "geometric" functional $x\mapsto\prod_i\exp(x_i)$ is rank-one EML with inner functions the identity (`prod_exp_rankOneEMLn`), since it equals $\exp(\sum_i x_i)$; by the characterization it is therefore product-separable with factors $a_i=\exp$ (`prod_exp_prodSeparable`).

---

## 4. A finite test: the cross-multiplicative identity ($n=2$)

Separability is an existential statement (it asserts factors exist). For two variables we replace it by a finite, directly checkable invariant.

**Definition 4 (multiplicative separability; `MulSeparable`).** $f:\mathbb{R}\to\mathbb{R}\to\mathbb{R}$ is *multiplicatively separable* if $f(x,y)=a(x)\,b(y)$ for some univariate $a,b$.

**Definition 5 (cross-multiplicative identity; `CrossMul`).** $f$ satisfies $\mathrm{CrossMul}$ if
$$f(x,y)\,f(x',y')=f(x,y')\,f(x',y)\quad\text{for all }x,y,x',y'.$$
Geometrically: every $2\times2$ submatrix of the value table $[f(x_i,y_j)]$ has vanishing $2\times2$ determinant in the multiplicative sense — the value table has multiplicative rank one.

**Theorem 4 (separability $\Leftrightarrow$ four-point test; `mulSeparable_iff_crossMul`).** *For any $f$ possessing at least one nonzero value, $\mathrm{MulSeparable}(f)\iff\mathrm{CrossMul}(f)$.*

The theorem splits into two verified directions.

**Lemma 4a (easy direction; `crossMul_of_mulSeparable`).** *If $f(x,y)=a(x)b(y)$ then $\mathrm{CrossMul}(f)$.*

*Proof sketch.* Substitute: $f(x,y)f(x',y')=a(x)b(y)a(x')b(y')=a(x)b(y')a(x')b(y)=f(x,y')f(x',y)$ by commutativity (closed by `ring`). $\qquad\blacksquare$

**Lemma 4b (reconstruction; `mulSeparable_of_crossMul`).** *If $\mathrm{CrossMul}(f)$ and $f(x_0,y_0)\ne 0$ for some anchor $(x_0,y_0)$, then $f$ is multiplicatively separable via the explicit slices*
$$a(x)=\frac{f(x,y_0)}{f(x_0,y_0)},\qquad b(y)=f(x_0,y).$$

*Proof sketch.* For arbitrary $x,y$, apply $\mathrm{CrossMul}$ at $(x,y,x_0,y_0)$: $f(x,y)f(x_0,y_0)=f(x,y_0)f(x_0,y)$, hence $f(x,y)=\dfrac{f(x,y_0)f(x_0,y)}{f(x_0,y_0)}=a(x)b(y)$ since $f(x_0,y_0)\ne 0$. $\qquad\blacksquare$

The four-point test is the *operational* form of rank one: a single anchored equation reconstructs the factorization without any search.

**Theorem 5 (explicit rank-one EML from a positive test; `rankOne_exp_of_pos_crossMul` / `rankOne_eml_of_pos_crossMul`).** *If $f$ is strictly positive and satisfies $\mathrm{CrossMul}$, then $f$ has an explicit rank-one EML representation*
$$f(x,y)=\exp\!\big(\psi(x)+\varphi(y)\big)=\llbracket\mathrm{outerExp}\rrbracket\big(\psi(x)+\varphi(y)\big),$$
*with $\psi=\log\circ\,a$ and $\varphi=\log\circ\,b$ for the reconstructed positive slices $a,b$.*

*Proof sketch.* Positivity makes the anchor nonzero, so Lemma 4b gives positive slices $a,b$; then Lemma 3a (in the two-variable case) yields $\psi=\log a$, $\varphi=\log b$. $\qquad\blacksquare$

**Theorem 6 (continuity transfer; `rankOne_exp_continuous`).** *If the coordinate slices $x\mapsto f(x,y_0)$ and $y\mapsto f(x_0,y)$ are continuous (and $f$ is strictly positive and $\mathrm{CrossMul}$), then the inner functions $\psi,\varphi$ are continuous.*

*Proof sketch.* The slices $a,b$ are continuous (quotients/values of continuous slices with nonvanishing denominator), and $\log$ is continuous on $(0,\infty)$; compose. This matches the continuity regularity demanded by the Kolmogorov–Arnold theorem. $\qquad\blacksquare$

**Theorem 7 (converse; `crossMul_of_rankOne_exp`).** *Every rank-one target $f(x,y)=\exp(\psi(x)+\varphi(y))$ satisfies $\mathrm{CrossMul}$.*

*Proof sketch.* Such $f$ is multiplicatively separable with $a=e^{\psi}$, $b=e^{\varphi}$; apply Lemma 4a. $\qquad\blacksquare$

Together, Theorems 4–7 give a complete, constructive, continuity-preserving loop: *positive $\mathrm{CrossMul}$* $\Leftrightarrow$ *positive product separability* $\Leftrightarrow$ *rank-one EML*, with the four-point identity as the finite certificate.

---

## 5. The sharp obstruction: addition is not rank-one

The characterization is only interesting if some natural target *fails* it. The most elementary one does.

**Theorem 8 (additive obstruction; `add_not_crossMul`, `add_not_mulSeparable`, `add_not_rankOne_exp`).** *The additive target $f(x,y)=x+y$*
1. *does not satisfy $\mathrm{CrossMul}$;*
2. *is not multiplicatively separable;*
3. *has no rank-one EML representation $\exp(\psi(x)+\varphi(y))$.*

*Proof sketch.* For (1), evaluate the four-point identity at $(x,y,x',y')=(0,0,1,1)$:
$$f(0,0)\,f(1,1)=0\cdot 2=0,\qquad f(0,1)\,f(1,0)=1\cdot1=1,$$
so $0\ne1$ and $\mathrm{CrossMul}$ fails. (2) follows because separability implies $\mathrm{CrossMul}$ (Lemma 4a), contrapositive. (3) follows because any rank-one $\exp(\psi+\varphi)$ satisfies $\mathrm{CrossMul}$ (Theorem 7), contradicting (1). $\qquad\blacksquare$

Thus the two elementary binary operations of arithmetic occupy opposite sides of the rank-one frontier: **multiplication is rank-one EML, addition provably is not.** The distinguishing invariant is multiplicative separability, witnessed concretely by a single failing $2\times2$ block.

---

## 6. Local versus global: exp/log depth as the deciding invariant

The rank-one representation of $x\cdot y$ in Theorem 1 carries a caveat — positivity — and the caveat is essential.

**Theorem 9 (boundary obstruction; `expLog_fails_at_boundary`).** *At $(x,y)=(0,1)$,*
$$\llbracket\mathrm{outerExp}\rrbracket\big(\llbracket\mathrm{innerLog}\rrbracket(0)+\llbracket\mathrm{innerLog}\rrbracket(1)\big)\ne 0\cdot 1.$$

*Proof sketch.* With the standard total-function convention $\log 0=0$ and $\log 1=0$, the left side is $\exp(0+0)=1$, whereas $0\cdot1=0$, and $1\ne0$. $\qquad\blacksquare$

The $n$-ary analogue `prod_exp_sum_log_fails_at_zero` shows that as soon as one coordinate vanishes the exp/sum/log term (here $1$ on the family $(0,1)$) departs from the true product (here $0$), so the positivity hypothesis of Theorem 2 is load-bearing for every $n\ge1$.

A globally valid representation exists, but at a structural cost: it must abandon the transcendental inner $\log$ in favor of polynomial inner functions.

**Theorem 10 (global polynomial representation; `mul_eq_polarization`).** *For all $x,y\in\mathbb{R}$,*
$$x\cdot y=\tfrac{1}{4}(x+y)^2-\tfrac{1}{4}(x-y)^2=\llbracket\mathrm{outerQuadPos}\rrbracket\big(x+y\big)+\llbracket\mathrm{outerQuadNeg}\rrbracket\big(x+(-y)\big),$$
*where $\mathrm{outerQuadPos}(u)=\tfrac14u^2$, $\mathrm{outerQuadNeg}(u)=-\tfrac14u^2$, with inner functions the identity and negation.*

*Proof sketch.* Expand the polarization identity; the squares cancel to leave $xy$ (closed by `ring`). No positivity is needed. $\qquad\blacksquare$

At the same boundary point $(0,1)$ where the exp/log form fails, the polarization form returns the correct value $0$ (`polarization_ok_at_boundary`).

**The deciding invariant.** The two representations differ exactly in exp/log depth:
- the rank-one exp/log form has $\mathrm{elDepth}=1$ in both inner and outer terms (`expLog_elDepth`) — genuinely transcendental, valid only on the open positive quadrant;
- the polarization form is exp/log-free, $\mathrm{elDepth}=0$ throughout (`polarization_elDepth_zero`) — valid globally, at the cost of $2$ outer terms.

Both representations use strictly fewer than the $2n+1=5$ outer terms guaranteed by Kolmogorov–Arnold for $n=2$ (`polarization_terms_lt_KA_bound`: $2<5$). The exp/log depth is therefore the precise dial trading transcendental economy (rank one, interior-only) against polynomial robustness (more terms, global). This reframes the inner-function question as: *what is the minimal exp/log depth of a globally valid EML superposition of a given target?*

---

## 7. Algorithms

The theory yields three directly implementable procedures.

**Algorithm A — Four-point separability test.** Given samples of $f$ on a grid $\{x_i\}\times\{y_j\}$, verify $f(x_i,y_j)f(x_k,y_\ell)=f(x_i,y_\ell)f(x_k,y_j)$ for all index pairs (up to tolerance). Returns whether $f$ is (numerically) multiplicatively separable, hence whether a rank-one EML representation is possible. Complexity $O(m^2 n^2)$ for an $m\times n$ grid, or $O(mn)$ using a fixed anchor row/column.

**Algorithm B — Rank-one EML reconstruction.** Given a strictly positive separable $f$ and an anchor $(x_0,y_0)$ with $f(x_0,y_0)\ne0$, output $\psi(x)=\log\frac{f(x,y_0)}{f(x_0,y_0)}$ and $\varphi(y)=\log f(x_0,y)$, so that $f(x,y)=\exp(\psi(x)+\varphi(y))$. Complexity $O(m+n)$ to tabulate the inner functions.

**Algorithm C — $n$-ary product collapse.** Given positive $f(1),\dots,f(n)$, compute $\prod_i f(i)$ stably as $\exp(\sum_i\log f(i))$, the rank-one EML form, avoiding overflow/underflow in long products. Complexity $O(n)$.

---

## 8. Applications

**Interpretable machine learning.** In a Kolmogorov–Arnold Network, the choice of inner-function family fixes both expressivity and interpretability. Our characterization tells a practitioner exactly when a single $\exp$-of-sums layer suffices: precisely for multiplicatively separable (positive product) targets, with inner functions the logarithms of the factors. The four-point test (Algorithm A) is a cheap data-side diagnostic that decides, *before training*, whether an $\exp$-headed layer is appropriate; if the target is additive-like it will fail the test, and Theorem 8 guarantees the $\exp$ layer cannot fit it.

**Numerically stable products.** Algorithm C is the standard log-sum-exp trick, here grounded as the rank-one EML representation: it computes large products of positive quantities (likelihoods of independent events, multiplicative gains, reaction-rate monomials) through a single sum-of-logs, with provable correctness on the positive domain.

**Domain-aware modeling.** Theorem 9 is a cautionary tale made precise: the most elegant model (rank-one exp/log) silently returns wrong values at domain boundaries under total-function conventions ($\log 0=0$). The exp/log depth quantifies the trade between elegance and global validity (Theorem 10), guiding the choice of representation by the domain of interest.

---

## 9. Discussion

The results crystallize a single message: **rank-one EML representability is exactly positive product separability**, and over two variables it is finitely detectable by the cross-multiplicative identity. Multiplication and addition emerge as the two poles of the rank-one frontier — the former achieving the absolute minimal superposition, the latter provably excluded. The exp/log-depth invariant further refines the picture, separating interior-only transcendental forms from globally valid polynomial ones.

These statements are sharper than the classical Kolmogorov–Arnold theorem in one direction (they are fully constructive and give explicit, computable inner functions) and narrower in another (they pertain to the rank-one stratum and the EML vocabulary). The narrowing is the point: by fixing a tractable function class we trade the universal but uncomputable classical guarantee for an exact, certificate-bearing classification.

---

## 10. Future directions

**F1. Strict rank hierarchy: rank-1 $\subsetneq$ rank-2.** Conjecture: the strictly positive target $g(x,y)=\exp(x+y)+\exp(2x+3y)$ is a sum of two rank-one EML terms but admits no single rank-one EML representation; hence the EML rank filtration is strict at level 1. Key insight: $\mathrm{CrossMul}$ is a *multiplicative* $2\times2$-minor condition, so a generic sum of two distinct exponentials breaks it while remaining a length-2 superposition. The cross-multiplicative test already gives a numerically validated separating witness ($g(0,0)\,g(1,1)\ne g(0,1)\,g(1,0)$), leaving only a transcendental inequality (bounding $e$) to close.

**F2. Rank = matrix rank of the log-Hankel form.** Conjecture: for strictly positive $f$, the minimal number of rank-one EML terms needed equals the rank of an associated "exponential-bilinear" kernel: $f=\sum_{k<r}\exp(\psi_k(x)+\varphi_k(y))$ iff the value matrix $[f(x_i,y_j)]$ has nonnegative factorization rank $r$. Key insight: $\exp$ turns additive inner sums into multiplicative outer factors, so EML rank is literally the (nonnegative) factorization rank of the value matrix. The $n$-variable result shows the rank-one layer is exactly the positive-product (rank-one matrix) layer; promoting "rank one" to "rank $r$" is the natural continuation.

**F3. Additive targets need an identity outer, never an exp outer.** Conjecture: a continuous $f(x,y)=u(x)+v(y)$ has a single-outer-term EML Kolmogorov–Arnold representation iff that outer term is affine (not transcendental); no single $\exp$/$\log$-headed outer EML term represents a non-constant additive target. Key insight: any $\exp$-headed outer forces the multiplicative $\mathrm{CrossMul}$ identity, which additive non-constant targets provably violate (`add_not_crossMul`). `add_not_rankOne_exp` is the $\exp$ case; generalizing from $\exp$ to every transcendental-headed outer is a direct strengthening.

**F4. Quantitative $2n+1$ for non-separable continuous targets.** Conjecture: every continuous $f:[0,1]^n\to\mathbb{R}$ admits a Kolmogorov–Arnold superposition with at most $2n+1$ outer terms whose inner functions are continuous EML terms (finite $\exp$/$\log$/$+$/$\times$ compositions), and $2n+1$ is sharp in general.

---

## Appendix: index of verified results

- `eval_expOf_logOf_var` — $\exp(\log x)=x$ for $x>0$ at the term level.
- `mul_eq_expLog` — $x\cdot y=\exp(\log x+\log y)$ on the positive quadrant (Theorem 1).
- `prod_eq_exp_sum_log`, `prod_eq_outerExp_sum_innerLog`, `mul_eq_expLog_via_prod` — $n$-ary product collapse (Theorem 2).
- `ProdSeparable`, `RankOneEMLn` — definitions 2–3.
- `rankOneEMLn_of_prodSeparable`, `prodSeparable_of_rankOneEMLn`, `rankOneEMLn_iff_prodSeparable`, `rankOneEMLn_eml` — characterization (Theorem 3, Lemmas 3a–3b).
- `prod_exp_rankOneEMLn`, `prod_exp_prodSeparable` — canonical instance.
- `MulSeparable`, `CrossMul` — definitions 4–5.
- `crossMul_of_mulSeparable`, `mulSeparable_of_crossMul`, `mulSeparable_iff_crossMul` — four-point test (Theorem 4, Lemmas 4a–4b).
- `rankOne_exp_of_pos_crossMul`, `rankOne_eml_of_pos_crossMul`, `rankOne_exp_continuous`, `crossMul_of_rankOne_exp` — explicit reconstruction, continuity, converse (Theorems 5–7).
- `add_not_crossMul`, `add_not_mulSeparable`, `add_not_rankOne_exp` — additive obstruction (Theorem 8).
- `expLog_fails_at_boundary`, `prod_exp_sum_log_fails_at_zero`, `mul_eq_polarization`, `polarization_ok_at_boundary`, `expLog_elDepth`, `polarization_elDepth_zero`, `polarization_terms_lt_KA_bound` — local-vs-global analysis (Theorems 9–10).
