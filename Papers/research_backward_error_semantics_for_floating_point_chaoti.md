# Backward-Error Semantics for Floating-Point Chaotic Programs

**Aristotle**

**Date:** 2026-09-01

---

## Abstract

We propose and develop a two-layer theory of the numerical simulation of polynomial dynamical systems in floating-point arithmetic, in which the *semantics* of the arithmetic is rigorously separated from the *dynamics* of the map. The semantic layer establishes that a finite floating-point execution of a polynomial iteration, in a run free of overflow, underflow and exceptional values, is **exactly** the orbit of a nonautonomous polynomial system whose coefficients lie in a relative $\gamma_{2n}(u)$-neighbourhood of the nominal ones, where $u$ is the unit roundoff, $n$ the number of coefficients, and $\gamma_k(u) = (1+u)^k - 1$. As a corollary the execution is an exact $\delta$-pseudo-orbit of the exact real map with the compositional defect $\delta = \gamma_{2n}(u)\sum_i |a_i| B^i$, $B$ being an observed magnitude bound. This layer uses no dynamical hypothesis whatsoever. The dynamical layer is then a black box consuming the defect certificate: forward tracking from a fixed initial condition yields the bound $\delta(L^n-1)/(L-1)$, which we show is *attained*, and hence sharp; backward tracking along inverse branches of an expanding map yields the bound $\delta/(\lambda-1)$, *uniform in the number of steps*. A nonautonomous refinement replaces the global Lipschitz constant by observed local expansion factors, giving an a-posteriori certificate computable from the execution itself. Instantiations give explicit numbers: a double-precision execution of the logistic map $4z(1-z)$ observed to remain in $[0,1]$ is shadowed by the exact real orbit through the same initial point to within $2^{-46}(4^n-1)/3$; a double-precision execution of the expanding cubic $z^3+2z$ observed to remain within magnitude $B$ is shadowed by an exact orbit to within $\gamma_8(u)(2B+B^3)$ at *every* step. Finally we isolate a phenomenon we call **structural backward error**: the natural three-operation implementation of the logistic step is exactly a logistic step at a detuned parameter, a statement about the *program* rather than the mathematical function, and one that fails for the algebraically equivalent expanded form.

**Keywords:** backward error analysis, floating-point arithmetic, unit roundoff, Horner's rule, pseudo-orbit, shadowing, chaotic dynamics, logistic map, expanding maps, a-posteriori error certificates.

---

## 1. Introduction

### 1.1 The problem

It is a commonplace of computational science that chaotic systems cannot be reliably simulated. The argument is a syllogism: chaotic systems amplify perturbations at an exponential rate $e^{\lambda t}$; floating-point arithmetic perturbs every operation; hence after $O(\lambda^{-1}\log(1/u))$ steps the computed trajectory bears no relation to the intended one. The conclusion is correct as far as it goes, but the argument is informal in a specific and repairable way: it treats rounding as an *unmodelled disturbance* — an appeal to "precision" — and then hands that disturbance to a dynamical amplification argument.

This paper's thesis is that the appeal to precision should be replaced by a theorem, and that the theorem is a *semantic* one: it says which exact mathematical problem the program solved. The classical technology for such statements is Wilkinson's backward error analysis. What is new here is the observation that backward error analysis is exactly the right interface to the classical shadowing theory of dynamical systems, and that the composition of the two produces fully explicit, a-posteriori-checkable certificates for real programs. The two layers are:

- **(S) Semantics.** A finite floating-point execution, under a runtime-verifiable hypothesis (no overflow, observed magnitudes bounded), is an exact real pseudo-orbit with a computable local defect.
- **(D) Dynamics.** A pseudo-orbit with a given local defect is tracked by a true orbit, with an error governed by the expansion properties of the map.

Layer (S) contains all the arithmetic and no dynamics. Layer (D) contains all the dynamics and no arithmetic. The folk theorem conflates them; separating them tells us exactly which half is responsible for what, and, as we shall see, allows each half to be improved independently.

### 1.2 Contributions

1. **A backward-error semantics for rounded Horner evaluation** (Theorem 3.1): the rounded value is the *exact* value of a coefficientwise-perturbed polynomial at the *same* argument, with relative coefficient perturbation at most $\gamma_{2n}(u)$.
2. **A local defect certificate** (Theorem 3.3) derived from it, and a proof that its first-order term in $u$ cannot be removed (Theorem 3.5).
3. **A semantic translation theorem** (Theorem 4.2): a floating-point execution *is* a certified pseudo-orbit, unconditionally in the dynamics; and is exactly the orbit of a nonautonomous perturbed polynomial family (Theorem 4.3).
4. **Sharpness of forward shadowing** (Theorem 5.2): the geometric factor $(L^n-1)/(L-1)$ is attained, so the exponential degradation is intrinsic to layer (D).
5. **Uniform-in-time shadowing for expanding maps** (Theorem 6.1) and its instantiation to a concrete expanding cubic (Theorem 6.4), giving an $O(u)$ bound independent of the execution length.
6. **A-posteriori nonautonomous shadowing** (Theorem 7.1) driven by observed local expansion factors, with an explicit instantiation for double-precision logistic executions (Theorem 7.3).
7. **Structural backward error** (Theorem 8.1): the product-form logistic implementation is an exact logistic map at a detuned parameter — a syntactic property of the evaluation scheme.
8. **A boundary result** (Theorem 8.4) showing that the runtime hypothesis is load-bearing: arbitrarily small parameter detuning past $r=4$ destroys invariance of $[0,1]$.

### 1.3 Relation to classical material

Backward error analysis for polynomial evaluation and the constants $\gamma_k$ are classical numerical analysis. Shadowing of pseudo-orbits by true orbits is classical hyperbolic dynamics. What is developed here is the *interface*: the precise form of certificate that layer (S) can produce and layer (D) can consume, the demonstration that the interface is lossless (the forward bound is derivable from the backward one but not conversely), and the demonstration that each layer's bound is sharp in its own regime.

---

## 2. The model of computation

### 2.1 Rounding models

Throughout, $u \ge 0$ denotes the **unit roundoff**: $u = 2^{-24}$ for IEEE binary32, $u = 2^{-53}$ for binary64.

> **Definition 2.1 (Rounding model).** A *rounding model* with unit roundoff $u \ge 0$ consists of three binary operations $\oplus, \ominus, \otimes$ on $\mathbb{R}$ such that for all $a, b \in \mathbb{R}$ there exist $e_\oplus, e_\ominus, e_\otimes$ with $|e_\bullet| \le u$ and
> $$a \oplus b = (a+b)(1+e_\oplus), \qquad a \ominus b = (a-b)(1+e_\ominus), \qquad a \otimes b = ab(1+e_\otimes).$$

This is precisely the standard IEEE-754 model *in the absence of overflow, underflow and exceptional values*. The hypothesis "the execution avoids overflow and exceptional values" in the informal statement of the problem is discharged, exactly and completely, by the assumption that the model applies to every operation performed. No property of the bit-level format — radix, exponent range, subnormal handling — is used anywhere below, so every result applies verbatim to any faithfully-rounded arithmetic.

Two remarks. First, we do **not** assume $u < 1$: the semantic results are unconditional in $u \ge 0$, and hypotheses of the form $ku<1$ appear only where the classical estimates require them. Second, the operations are total functions on the reals, not partial functions on a finite set; the finiteness of the format is captured entirely by the relative-error bound.

> **Definition 2.2 (Adversarial model).** For $u \ge 0$ the *uniform adversarial model* is $a \oplus b = (a+b)(1+u)$, $a \ominus b = (a-b)(1+u)$, $a \otimes b = ab(1+u)$. It is a rounding model with unit roundoff $u$ (take $e_\bullet = u$ throughout).

The adversarial model is the vehicle for all sharpness statements: any bound valid for all rounding models must hold for it.

### 2.2 The error constant

> **Definition 2.3.** For $u \in \mathbb{R}$ and $k \in \mathbb{N}$, set $\gamma_k(u) := (1+u)^k - 1$.

> **Lemma 2.4.** Let $u \ge 0$. Then (i) $\gamma_k(u) \ge 0$; (ii) $k \le l \implies \gamma_k(u) \le \gamma_l(u)$; (iii) $u \le \gamma_k(u)$ for $k \ge 1$.

*Proof.* (i) $(1+u)^k \ge 1$ since $1+u \ge 1$. (ii) Monotonicity of $t \mapsto t^k$ in $k$ for base $\ge 1$. (iii) Take $k=1$ in (ii) and note $\gamma_1(u) = u$. $\square$

> **Lemma 2.5 (Composition of relative perturbations).** Let $u \ge 0$ and let $t_1, t_2$ satisfy $|t_1 - 1| \le \gamma_a(u)$ and $|t_2-1| \le \gamma_b(u)$. Then $|t_1t_2 - 1| \le \gamma_{a+b}(u)$.

*Proof.* Write $t_1t_2 - 1 = (t_1-1)t_2 + (t_2-1)$. Since $|t_2| \le 1 + \gamma_b(u) = (1+u)^b$, the triangle inequality gives
$$|t_1t_2-1| \le \gamma_a(u)(1+u)^b + \gamma_b(u) = \bigl((1+u)^a - 1\bigr)(1+u)^b + (1+u)^b - 1 = (1+u)^{a+b}-1. \square$$

This lemma is the engine of the entire theory: it says that the exponent of $\gamma$ is an additive account of "how many roundings have touched this quantity."

> **Theorem 2.6 (Classical form of the error constant).** Let $u \ge 0$ and $k \in \mathbb{N}$ with $ku < 1$. Then
> $$\gamma_k(u) \le \frac{ku}{1-ku}.$$

*Proof.* Induction on $k$. For $k=0$ both sides vanish. Assume the bound for $k=n$, and let $(n+1)u < 1$, whence also $nu<1$ and $1-nu>0$. From $\gamma_{n+1}(u) = \gamma_n(u)(1+u) + u$ and the inductive hypothesis,
$$\gamma_{n+1}(u) \le \frac{nu}{1-nu}(1+u) + u = \frac{(n+1)u}{1-nu},$$
the last equality by clearing denominators. Since $0 < 1 - (n+1)u \le 1-nu$ and $(n+1)u \ge 0$, the right-hand side is at most $(n+1)u/(1-(n+1)u)$. $\square$

For $k u \le \tfrac12$ this reads $\gamma_k(u) \le 2ku$; in double precision with $k$ in the tens, $\gamma_k(u) \approx ku$ to fifteen digits.

### 2.3 Horner evaluation

We represent a polynomial by its coefficient list $\mathbf{a} = (a_0, \dots, a_{n-1})$, meaning $p(x) = \sum_{i=0}^{n-1} a_i x^i$.

> **Definition 2.7 (Exact and rounded Horner evaluation).** The exact evaluation is defined recursively by $H(\,(),\,x) = 0$ and $H((a_0,\dots,a_{n-1}), x) = a_0 + x\cdot H((a_1,\dots,a_{n-1}),x)$. The rounded evaluation in a rounding model is $\widehat{H}(\,(),\,x)=0$ and
> $$\widehat{H}((a_0,\dots,a_{n-1}),x) = a_0 \oplus \bigl(x \otimes \widehat{H}((a_1,\dots,a_{n-1}),x)\bigr).$$

Thus an $n$-coefficient polynomial costs $n$ multiplications and $n$ additions in this convention: **two roundings per coefficient**.

> **Definition 2.8 (Magnitude functional).** $\ \mathcal{A}(\mathbf{a}, x) := \sum_{i=0}^{n-1} |a_i|\,|x|^i = H\bigl((|a_0|,\dots,|a_{n-1}|), |x|\bigr).$

> **Lemma 2.9.** $\mathcal{A} \ge 0$; $\mathcal{A}((a_0,\mathbf{a}'),x) = |a_0| + |x|\,\mathcal{A}(\mathbf{a}',x)$; and $|x| \le B \implies \mathcal{A}(\mathbf{a},x) \le \mathcal{A}(\mathbf{a},B)$.

*Proof.* All three by induction on the list, using the displayed recursion and nonnegativity of each summand. $\square$

$\mathcal{A}(\mathbf{a},x)$ is the *condition-like* quantity that controls the intermediate magnitudes of a Horner run: every partial result of the exact evaluation is bounded by it.

---

## 3. The semantic layer I: backward error of one evaluation

### 3.1 Transfer lemmas

> **Lemma 3.0a (Coefficientwise to evaluation).** Suppose $|b_i - a_i| \le c\,|a_i|$ for all $i$, with $c \ge 0$. Then for all $x$,
> $$|H(\mathbf{b},x) - H(\mathbf{a},x)| \le c\,\mathcal{A}(\mathbf{a},x).$$

*Proof.* Induction on the list. The empty case is trivial. For lists $(b_0,\mathbf{b}')$ and $(a_0,\mathbf{a}')$,
$$H(\mathbf b,x)-H(\mathbf a,x) = (b_0-a_0) + x\bigl(H(\mathbf b',x)-H(\mathbf a',x)\bigr),$$
so by the triangle inequality and the inductive hypothesis this is at most $c|a_0| + |x|\,c\,\mathcal A(\mathbf a',x) = c\,\mathcal A(\mathbf a,x)$ by Lemma 2.9. $\square$

> **Lemma 3.0b (Rescaling degrades the exponent by two).** Let $u \ge 0$. If $|b_i - a_i| \le \gamma_{2m}(u)|a_i|$ for all $i$ and $|t-1| \le \gamma_2(u)$, then $|b_it - a_i| \le \gamma_{2m+2}(u)|a_i|$ for all $i$.

*Proof.* Write $b_i = a_i s_i$ where, if $a_i \ne 0$, $|s_i - 1| \le \gamma_{2m}(u)$; then $|s_it - 1| \le \gamma_{2m+2}(u)$ by Lemma 2.5, and multiply by $|a_i|$. (If $a_i = 0$ then $b_i = 0$ and the claim is trivial.) $\square$

### 3.2 The main semantic theorem

> **Theorem 3.1 (Backward-error semantics of rounded Horner evaluation).** Fix a rounding model with unit roundoff $u \ge 0$, a coefficient list $\mathbf{a} = (a_0,\dots,a_{n-1})$ and a point $x \in \mathbb{R}$. Then there exists a real coefficient list $\mathbf{b} = (b_0,\dots,b_{n-1})$ with
> $$|b_i - a_i| \le \gamma_{2n}(u)\,|a_i| \qquad (0 \le i < n)$$
> such that
> $$\widehat{H}(\mathbf{a},x) = H(\mathbf{b},x).$$
> That is: the rounded evaluation of $p$ at $x$ is the **exact** evaluation, at the same point $x$, of a polynomial whose coefficients are relatively within $\gamma_{2n}(u)$ of those of $p$.

*Proof.* Induction on $n$. For $n=0$ both sides are $0$ and $\mathbf b$ is empty.

For the step, write $\mathbf{a} = (a_0, \mathbf{a}')$ with $\mathbf{a}'$ of length $m = n-1$, and let $\mathbf{b}'$ be the list supplied by the inductive hypothesis for $\mathbf a'$, so $|b'_i - a'_i| \le \gamma_{2m}(u)|a'_i|$ and $\widehat H(\mathbf a', x) = H(\mathbf b', x)$. Let $v := \widehat H(\mathbf a',x)$. The model supplies $e_2$ with $|e_2| \le u$ and $x \otimes v = xv(1+e_2)$, and $e_1$ with $|e_1| \le u$ and $a_0 \oplus (x\otimes v) = (a_0 + xv(1+e_2))(1+e_1)$. Set
$$t := (1+e_1)(1+e_2).$$
By Lemma 2.5 with $a=b=1$, $|t - 1| \le \gamma_2(u)$. Now
$$\widehat H(\mathbf a, x) = a_0(1+e_1) + x\,v\,t = a_0(1+e_1) + x\,H(\mathbf b', x)\,t = H\bigl((a_0(1+e_1),\ t\mathbf b'),\ x\bigr),$$
using that scaling every coefficient of a list by $t$ scales its Horner value by $t$. Take $\mathbf b := (a_0(1+e_1),\ t b'_0, \dots, t b'_{m-1})$. For the head, $|a_0(1+e_1) - a_0| = |e_1||a_0| \le u|a_0| \le \gamma_{2m+2}(u)|a_0|$ by Lemma 2.4(iii). For the tail, Lemma 3.0b gives $|t b'_i - a'_i| \le \gamma_{2m+2}(u)|a'_i|$. Since $2m+2 = 2n$, the proof is complete. $\square$

**Remark 3.2 (Why the exponent is $2n$).** The exponent is forced by the induction: each Horner level performs two roundings and *both* of them multiply every previously perturbed coefficient by a common factor. A graded refinement in which the coefficient $a_i$ carries only $\gamma_{2i+2}$ is true and follows from the same induction, but the uniform bound is what the dynamical layer consumes, and it is the uniform bound that composes cleanly under iteration.

**Remark 3.2b (Strictness).** Theorem 3.1 is strictly stronger than any forward bound: it identifies the exact problem solved and localizes the perturbation to the data, allowing the conditioning of the evaluation to be assessed *separately* by the user. Near an ill-conditioned root, the forward error can be $100\%$ while the backward error remains at the sixteenth digit.

### 3.3 The local defect certificate

> **Theorem 3.3 (Local defect certificate).** For any rounding model with unit roundoff $u \ge 0$, any $\mathbf{a}$ of length $n$ and any $x$,
> $$\bigl|\widehat{H}(\mathbf{a},x) - H(\mathbf{a},x)\bigr| \le \gamma_{2n}(u)\ \mathcal{A}(\mathbf{a},x) = \gamma_{2n}(u)\sum_{i=0}^{n-1}|a_i|\,|x|^i.$$

*Proof.* Immediate from Theorem 3.1 and Lemma 3.0a. $\square$

This is the *compositional expression in the unit roundoff and the intermediate magnitudes* demanded by the informal conjecture: a product of a precision factor $\gamma_{2n}(u)$, depending only on the arithmetic and the length of the program, and a magnitude factor $\mathcal A(\mathbf a,x)$, depending only on the data.

### 3.4 Sharpness of the certificate

> **Theorem 3.4 (Exact defect in the adversarial model).** In the uniform adversarial model with parameter $u \ge 0$, evaluating the constant polynomial $\mathbf a = (a)$ at any $x$ gives
> $$\bigl|\widehat H((a),x) - H((a),x)\bigr| = u\,\mathcal A((a),x) = u|a|.$$

*Proof.* $\widehat H((a),x) = a \oplus (x \otimes 0) = a(1+u)$, $H((a),x)=a$, $\mathcal A((a),x)=|a|$. $\square$

> **Theorem 3.5 (The first-order term cannot be removed).** For $0 \le u \le 1$ and any $a, x$, in the uniform adversarial model,
> $$\frac{1}{3}\,\gamma_{2}(u)\,\mathcal A((a),x) \le \bigl|\widehat H((a),x) - H((a),x)\bigr|.$$

*Proof.* By Theorem 3.4 the right side is $u|a|$, while $\gamma_2(u) = 2u+u^2 \le 3u$ for $u \le 1$. $\square$

Thus the bound of Theorem 3.3 is correct to within a factor $3$ in the worst case for $n=1$, and no bound of order $u^2$ can hold. The theory is first-order tight.

---

## 4. The semantic layer II: executions are certified pseudo-orbits

### 4.1 Pseudo-orbits

> **Definition 4.1.** A sequence $(x_k)_{k\ge0}$ is a **$\delta$-pseudo-orbit of $f$ for $N$ steps** if $|x_{k+1} - f(x_k)| \le \delta$ for all $k < N$. The **true orbit** of $f$ through $y_0$ is $\mathcal{O}_f(y_0)_k := f^{k}(y_0)$.

> **Definition 4.1b (Floating-point orbit).** Given a rounding model and a coefficient list $\mathbf a$, the *floating-point orbit* through $x_0$ is $X_0 := x_0$, $X_{k+1} := \widehat H(\mathbf a, X_k)$.

### 4.2 The translation theorem

> **Theorem 4.2 (Semantic translation).** Let $\mathbf a$ have length $n$, let $(X_k)$ be the floating-point orbit through $x_0$ in a rounding model with unit roundoff $u \ge 0$, and suppose $|X_k| \le B$ for all $k \le N$. Then $(X_k)$ is a $\delta$-pseudo-orbit of the exact map $p(z) = H(\mathbf a,z)$ for $N$ steps, with
> $$\delta = \gamma_{2n}(u)\ \mathcal{A}(\mathbf a, B) = \gamma_{2n}(u)\sum_{i=0}^{n-1}|a_i|B^i.$$

*Proof.* For $k<N$, $X_{k+1} = \widehat H(\mathbf a, X_k)$, so Theorem 3.3 gives $|X_{k+1} - p(X_k)| \le \gamma_{2n}(u)\mathcal A(\mathbf a, X_k)$, and Lemma 2.9 (monotonicity of $\mathcal A$) with $|X_k| \le B$ gives $\mathcal A(\mathbf a, X_k) \le \mathcal A(\mathbf a, B)$. Multiply by $\gamma_{2n}(u) \ge 0$. $\square$

Two features are worth stressing.

- **Unconditionality in the dynamics.** No hypothesis on $p$ appears. The theorem knows nothing about chaos, hyperbolicity, or Lyapunov exponents.
- **The hypothesis is a runtime check.** "$|X_k| \le B$ for $k \le N$" is not an a-priori assumption; it is a predicate the program can evaluate on its own output, and it is exactly the certificate that no overflow or exceptional value occurred. It is also non-vacuous: for the logistic map at $r=4$, the exact orbit of any $x_0 \in [0,1]$ remains in $[0,1]$.

> **Theorem 4.3 (Backward-error semantics of the whole execution).** In the setting of Theorem 4.2, for each $k$ there is a coefficient list $\mathbf b^{(k)}$ with $|b^{(k)}_i - a_i| \le \gamma_{2n}(u)|a_i|$ for all $i$, such that
> $$X_{k+1} = H\bigl(\mathbf b^{(k)}, X_k\bigr)$$
> **exactly**. Hence the execution is the exact orbit of a nonautonomous polynomial system whose coefficient sequence lies in a relative $\gamma_{2n}(u)$-tube around $\mathbf a$.

*Proof.* Apply Theorem 3.1 at the point $X_k$ for each $k$. $\square$

Theorem 4.3 is the precise form of the conjecture stated informally at the outset: *every finite execution avoiding overflow and exceptional values can be translated into an exact real pseudo-orbit whose local defect is bounded by a compositional expression in unit roundoff and the intermediate magnitudes.* Theorem 4.2 is its quantitative shadow, and Theorem 4.3 is the statement that no information is lost in the translation.

---

## 5. The dynamical layer I: forward shadowing, and its sharpness

> **Theorem 5.1 (Finite-time shadowing).** Let $f : \mathbb{R}\to\mathbb{R}$, $L \ge 0$, and $S \subseteq \mathbb{R}$ with $|f(a)-f(b)| \le L|a-b|$ for all $a,b \in S$. Let $(x_k)$ be a $\delta$-pseudo-orbit of $f$ for $N$ steps such that $x_k \in S$ and $f^k(x_0) \in S$ for all $k \le N$. Then for all $n \le N$,
> $$\bigl|x_n - f^{\,n}(x_0)\bigr| \le \delta\sum_{k=0}^{n-1}L^k = \begin{cases}\delta\,\dfrac{L^n-1}{L-1}, & L \ne 1,\\[2mm] n\delta, & L = 1.\end{cases}$$

*Proof.* Induction on $n$; the case $n=0$ is trivial. Writing $y_k := f^k(x_0)$ and splitting
$$x_{n+1} - y_{n+1} = \bigl(x_{n+1} - f(x_n)\bigr) + \bigl(f(x_n) - f(y_n)\bigr),$$
the triangle inequality, the pseudo-orbit property, and the Lipschitz property give $|x_{n+1}-y_{n+1}| \le \delta + L|x_n-y_n| \le \delta + L\delta\sum_{k<n}L^k = \delta\sum_{k<n+1}L^k$, using $\sum_{k<n+1}L^k = L\sum_{k<n}L^k + 1$. $\square$

> **Corollary 5.1b (Contractions).** If moreover $0 \le L < 1$ and $\delta \ge 0$, then $|x_n - f^n(x_0)| \le \delta/(1-L)$ for all $n \le N$, uniformly in $n$.

*Proof.* $\sum_{k<n}L^k = (1-L^n)/(1-L) \le 1/(1-L)$. $\square$

The exponential factor in Theorem 5.1 is not an artifact:

> **Theorem 5.2 (The forward bound is attained).** For every $L \ge 0$ and $\delta \ge 0$ there exist a map $f:\mathbb{R}\to\mathbb{R}$ with $|f(a)-f(b)| = L|a-b|$ for **all** $a,b$, and a sequence $(x_k)$ with $|x_{k+1}-f(x_k)| = \delta$ for **all** $k$, such that
> $$\bigl|x_n - f^{\,n}(x_0)\bigr| = \delta\sum_{k=0}^{n-1}L^k \qquad \text{for all } n.$$

*Proof.* Take $f(z) = Lz$ and $x_0 = 0$, $x_{k+1} = Lx_k + \delta$. Then $|f(a)-f(b)| = L|a-b|$ identically and $|x_{k+1}-f(x_k)| = \delta$ identically. The true orbit through $x_0=0$ is identically $0$, while an easy induction, using $\sum_{k<n+1}L^k = L\sum_{k<n}L^k+1$, gives $x_n = \delta\sum_{k<n}L^k \ge 0$. $\square$

> **Corollary 5.3 (The exponential is dynamical, not arithmetical).** For $L>1$ and $\delta>0$ and every $n$, there is an exactly $L$-Lipschitz map and a sequence whose per-step defect is exactly $\delta$ with $|x_n - f^n(x_0)| = \delta(L^n-1)/(L-1)$.

The moral: any attempt to improve the composed bound must attack the *question*, not the arithmetic. Section 6 does exactly that.

### 5.1 Instantiation: the logistic map in binary64

> **Definition 5.4.** $f(z) := 4z(1-z)$, with coefficient list $\mathbf a = (0,4,-4)$, so that $H(\mathbf a, z) = f(z)$.

> **Lemma 5.5.** $f([0,1]) \subseteq [0,1]$; consequently $f^n(y_0) \in [0,1]$ for all $n$ whenever $y_0 \in [0,1]$.

*Proof.* For $z \in [0,1]$, $4z(1-z) \ge 0$; and $1 - 4z(1-z) = (2z-1)^2 \ge 0$. $\square$

> **Lemma 5.6.** $|f(a)-f(b)| \le 4|a-b|$ for $a,b \in [0,1]$.

*Proof.* $f(a)-f(b) = (a-b)\cdot 4(1-a-b)$ and $|4(1-a-b)| \le 4$ for $a,b\in[0,1]$. $\square$

> **Lemma 5.7 (Defect bound in binary64).** If $0 \le u \le 2^{-53}$ then
> $$\gamma_6(u)\ \mathcal{A}(\mathbf a, 1) \le 2^{-46}.$$

*Proof.* $\mathcal A((0,4,-4),1) = 0 + 4 + 4 = 8$. Since $6u \le 6\cdot 2^{-53} < \tfrac12$, Theorem 2.6 gives $\gamma_6(u) \le 6u/(1-6u) \le 12u \le 12\cdot 2^{-53}$. Hence $\gamma_6(u)\cdot 8 \le 96\cdot 2^{-53} < 128\cdot2^{-53} = 2^{-46}$. $\square$

> **Theorem 5.8 (Certified shadowing of a binary64 logistic execution).** Let $(X_k)$ be the floating-point orbit of $f(z)=4z(1-z)$ evaluated by Horner's rule in any rounding model with $u \le 2^{-53}$, started at $x_0 \in [0,1]$, and suppose the execution is *observed* to satisfy $X_k \in [0,1]$ for all $k \le N$. Then for all $n \le N$,
> $$\bigl|X_n - f^{\,n}(x_0)\bigr| \le 2^{-46}\,\frac{4^n-1}{3}.$$

*Proof.* By Theorem 4.2 with $B=1$, $(X_k)$ is a $\delta$-pseudo-orbit of $f$ with $\delta = \gamma_6(u)\mathcal A(\mathbf a,1) \le 2^{-46}$ (Lemma 5.7). By Lemma 5.5 the true orbit through $x_0$ stays in $[0,1]$, and by hypothesis so does the execution, so Theorem 5.1 applies on $S=[0,1]$ with $L=4$, giving $|X_n - f^n(x_0)| \le \delta\sum_{k<n}4^k = \delta(4^n-1)/3 \le 2^{-46}(4^n-1)/3$. $\square$

**The bound is fully attributable.** The factor $2^{-46}$ comes only from layer (S) — from the arithmetic, the length of the coefficient list, and the observed magnitude bound. The factor $(4^n-1)/3$ comes only from layer (D) — from the Lipschitz constant of the exact map. They are computed independently and multiplied once. Setting the bound to $1$ (the diameter of the state space) gives $4^n \approx 3\cdot2^{46}$, i.e. $n \approx 23$: this is the certified horizon of a double-precision logistic simulation under forward tracking. It agrees with the practitioners' heuristic of losing $\log_{10}4 \approx 0.6$ decimal digits per step.

---

## 6. The dynamical layer II: uniform-in-time shadowing for expanding maps

The horizon of Theorem 5.8 is limited by an artifact of the *question*: we insisted the shadowing orbit start at the same point $x_0$. Classical hyperbolic theory removes that restriction, and the price of the exponential with it.

> **Theorem 6.1 (Uniform-in-time backward shadowing).** Let $f:\mathbb{R}\to\mathbb{R}$, $\lambda>1$, $\delta\ge0$. Suppose given maps $g_n:\mathbb{R}\to\mathbb{R}$ ($n \in \mathbb{N}$) — *inverse branches* — with
> $$f(g_n(z)) = z, \qquad |g_n(z)-g_n(w)| \le \frac{|z-w|}{\lambda} \quad\text{for all } z,w,$$
> and let $(x_k)$ be a $\delta$-pseudo-orbit of $f$ for $N$ steps compatible with the branches in the sense $g_n(f(x_n)) = x_n$ for all $n$. Then there exists a genuine orbit $(y_k)$ of $f$ — i.e. $f(y_k) = y_{k+1}$ for $k<N$ — with
> $$|y_n - x_n| \le \frac{\delta}{\lambda-1} \qquad \text{for all } n \le N.$$
> The bound is **independent of $N$**.

*Proof.* Induction on $N$, generalizing over the pseudo-orbit and the branch family. For $N=0$ take $y_k \equiv x_0$; the bound at $n=0$ is $0 \le \delta/(\lambda-1)$.

For the step, apply the inductive hypothesis to the shifted data $x'_k := x_{k+1}$, $g'_n := g_{n+1}$ — which is a $\delta$-pseudo-orbit for $N$ steps compatible with the shifted branches — obtaining an orbit $(y'_k)$ with $|y'_n - x_{n+1}| \le \delta/(\lambda-1)$ for $n \le N$. Define $y_0 := g_0(y'_0)$ and $y_{k+1} := y'_k$. Then $f(y_0) = y'_0 = y_1$ by the branch identity, and the orbit relation for $k \ge 1$ is inherited. For the estimate at $n=0$: using $g_0(f(x_0)) = x_0$ and the contraction property,
$$|y_0 - x_0| = |g_0(y'_0) - g_0(f(x_0))| \le \frac{|y'_0 - f(x_0)|}{\lambda} \le \frac{|y'_0-x_1| + |x_1 - f(x_0)|}{\lambda} \le \frac{\frac{\delta}{\lambda-1}+\delta}{\lambda} = \frac{\delta}{\lambda-1},$$
the last equality because $\delta/(\lambda-1)$ is the fixed point of $E \mapsto (\delta+E)/\lambda$. The estimates for $n \ge 1$ are inherited. $\square$

The mechanism is transparent: the induction runs *backwards along the time horizon*, and each backward step is a $1/\lambda$-contraction, so accumulated error converges to a fixed point rather than diverging geometrically. The price is that $y_0 \ne x_0$: the shadowing orbit starts at a nearby but different point.

### 6.1 A concrete expanding polynomial

> **Definition 6.2.** $p(z) := z^3 + 2z$, with coefficient list $\mathbf c = (0,2,0,1)$, so $H(\mathbf c, z)=p(z)$, and $\mathcal A(\mathbf c, B) = 2B + B^3$ for $B \ge 0$.

> **Lemma 6.3.** (i) $|p(a)-p(b)| \ge 2|a-b|$ for all $a,b$; (ii) $p$ is a bijection of $\mathbb{R}$; (iii) $p^{-1}$ satisfies $|p^{-1}(z)-p^{-1}(w)| \le |z-w|/2$.

*Proof.* (i) $p(a)-p(b) = (a-b)(a^2+ab+b^2+2)$ and $a^2+ab+b^2 = \tfrac12(a^2+b^2+(a+b)^2) \ge 0$, so the second factor is $\ge 2$. (ii) Injectivity is immediate from (i); surjectivity follows from continuity and $p(z)\to\pm\infty$ via the intermediate value theorem. (iii) Substitute $a = p^{-1}(z), b=p^{-1}(w)$ in (i). $\square$

> **Theorem 6.4 (Uniform certified shadowing of an expanding-cubic execution).** Let $(X_k)$ be the floating-point orbit of $p(z)=z^3+2z$ by Horner's rule in a rounding model with unit roundoff $u \ge 0$, started at any $x_0$, and suppose $|X_k| \le B$ for all $k \le N$. Then there exists a **genuine** orbit $(y_k)$ of $p$ (i.e. $p(y_k)=y_{k+1}$) with
> $$|y_n - X_n| \le \gamma_8(u)\,\bigl(2B+B^3\bigr) \qquad \text{for all } n \le N,$$
> a bound independent of $N$.

*Proof.* $\mathbf c$ has length $4$, so Theorem 4.2 makes $(X_k)$ a $\delta$-pseudo-orbit of $p$ with $\delta = \gamma_8(u)\mathcal A(\mathbf c, B) = \gamma_8(u)(2B+B^3)$. Apply Theorem 6.1 with $g_n := p^{-1}$ for every $n$ and $\lambda = 2$ (Lemma 6.3), noting $p^{-1}(p(x))=x$; the conclusion is $|y_n - X_n| \le \delta/(2-1) = \delta$. $\square$

For $B=1$ and $u=2^{-53}$: $\gamma_8(u) \le 16\cdot2^{-53}$ and $2B+B^3 = 3$, so the certified error is below $6 \times 10^{-15}$ — for **every** $n$, however large. The exponential catastrophe of Theorem 5.8 is thus attributable entirely to the rigidity of forward tracking, not to floating point.

**Remark 6.5 (Expansivity is essential).** Theorem 6.1 does not silently subsume Theorem 5.8: $f(z)=4z(1-z)$ has a critical point at $z=\tfrac12$ where $f'=0$, so it admits no globally $1/\lambda$-Lipschitz inverse branch on $[0,1]$; indeed it is two-to-one. Extending the uniform bound to non-invertible maps requires a genuinely different construction (local inverse branches plus a combinatorial choice of itinerary).

---

## 7. The dynamical layer III: a-posteriori nonautonomous certificates

The Lipschitz constant $L=4$ in Theorem 5.8 is the worst case over $[0,1]$, attained only at the endpoints. A run that spends its time in the interior expands less. The following replaces the global constant by *observed* local factors.

> **Definition 7.1a.** Given $\delta \ge 0$ and a sequence $L : \mathbb{N}\to[0,\infty)$, define the *a-posteriori error recursion*
> $$E_0 := 0, \qquad E_{n+1} := \delta + L_n E_n.$$

> **Lemma 7.0.** $E_n \ge 0$; $E$ is monotone in $\delta$; and if $L_n \equiv L$ then $E_n = \delta\sum_{k<n}L^k$.

*Proof.* Each by induction, the last using $\sum_{k<n+1}L^k = L\sum_{k<n}L^k+1$. $\square$

The last clause guarantees that the nonautonomous bound is never worse than the autonomous one of Theorem 5.1: it *refines* it.

> **Theorem 7.1 (Nonautonomous a-posteriori shadowing).** Let $f:\mathbb{R}\to\mathbb{R}$, $S \subseteq \mathbb{R}$, $\delta \ge 0$, and $L:\mathbb{N}\to[0,\infty)$. Let $(x_k)$ be a $\delta$-pseudo-orbit of $f$ for $N$ steps, suppose $f^k(x_0) \in S$ for $k \le N$, and suppose the *one-sided* local Lipschitz estimate
> $$|f(x_n) - f(b)| \le L_n\,|x_n - b| \qquad \text{for all } n<N,\ b \in S.$$
> Then $|x_n - f^{\,n}(x_0)| \le E_n$ for all $n \le N$.

*Proof.* Induction on $n$, identical in shape to Theorem 5.1 but using $L_n$ at step $n$: $|x_{n+1}-y_{n+1}| \le \delta + L_n|x_n-y_n| \le \delta + L_nE_n = E_{n+1}$. $\square$

Note the asymmetry: the Lipschitz estimate is required only *at the observed point* $x_n$, against all comparison points in $S$. This is what makes it a-posteriori-checkable — the program knows $x_n$.

> **Lemma 7.2 (Local expansion of the logistic map).** For $a \in [0,1]$ and all $b \in [0,1]$,
> $$|f(a)-f(b)| \le 4\max(a,\,1-a)\,|a-b|, \qquad f(z)=4z(1-z).$$

*Proof.* $f(a)-f(b)=(a-b)\cdot4(1-a-b)$; for $b\in[0,1]$, $4(1-a-b) \le 4(1-a) \le 4\max(a,1-a)$ and $4(1-a-b) \ge -4a \ge -4\max(a,1-a)$. $\square$

The factor $4\max(a,1-a)$ lies in $[2,4]$, equals $4$ only at the endpoints, and equals $2$ at $a=\tfrac12$.

> **Theorem 7.3 (A-posteriori certificate for a binary64 logistic execution).** Let $(X_k)$ be the floating-point orbit of $4z(1-z)$ by Horner's rule with $u \le 2^{-53}$, from $x_0 \in [0,1]$, observed to satisfy $X_k \in [0,1]$ for $k \le N$. Then for all $n\le N$,
> $$\bigl|X_n - f^{\,n}(x_0)\bigr| \le E_n, \qquad E_0=0,\quad E_{n+1} = 2^{-46} + 4\max\bigl(X_n,\,1-X_n\bigr)\,E_n.$$

*Proof.* Theorem 4.2 and Lemma 5.7 give the $\delta$-pseudo-orbit property with $\delta \le 2^{-46}$; Lemma 5.5 places the true orbit in $S=[0,1]$; Lemma 7.2 supplies the local factors; Theorem 7.1 concludes, and monotonicity of $E$ in $\delta$ (Lemma 7.0) allows replacing the exact $\delta$ by $2^{-46}$. $\square$

Every quantity on the right is computed from the execution itself. In practice one runs the iteration and the recursion $E$ side by side, and stops trusting the output when $E_n$ exceeds a tolerance — a fully rigorous runtime monitor.

---

## 8. Structural backward error: a property of the program

The results so far treat the polynomial abstractly, through its coefficient list. But a *program* is an expression, and different expressions for the same function have different backward-error structure. This section isolates the phenomenon.

> **Definition 8.0.** The *product-form* logistic step is the three-operation program
> $$\mathrm{Step}(r,x) := r \otimes \bigl(x \otimes (1 \ominus x)\bigr),$$
> approximating $\Phi_r(x) := r\,x(1-x)$.

> **Theorem 8.1 (Structural backward error).** For any rounding model with unit roundoff $u \ge 0$ and any $r,x$, there is $r' \in \mathbb{R}$ with
> $$|r'-r| \le \gamma_3(u)\,|r| \qquad\text{and}\qquad \mathrm{Step}(r,x) = \Phi_{r'}(x)\ \ \textbf{exactly}.$$
> The floating-point step is an exact logistic step *of the same family*, at a detuned parameter.

*Proof.* The model supplies $e_1,e_2,e_3$ with $|e_i|\le u$ and
$$1\ominus x = (1-x)(1+e_1),\quad x\otimes(1\ominus x) = x(1-x)(1+e_1)(1+e_2),\quad \mathrm{Step}(r,x) = r\,x(1-x)(1+e_1)(1+e_2)(1+e_3).$$
Put $r' := r(1+e_1)(1+e_2)(1+e_3)$. Then $\mathrm{Step}(r,x) = r'x(1-x) = \Phi_{r'}(x)$, and $|r'-r| = |(1+e_1)(1+e_2)(1+e_3)-1|\,|r| \le \gamma_3(u)|r|$ by two applications of Lemma 2.5 (each factor is within $\gamma_1(u)=u$ of $1$). $\square$

> **Corollary 8.2 (Forward defect of one step).** $\ |\mathrm{Step}(r,x) - \Phi_r(x)| \le \gamma_3(u)\,|r|\,|x|\,|1-x|.$

*Proof.* Substitute Theorem 8.1: the difference is $(r'-r)x(1-x)$. $\square$

> **Theorem 8.3 (A floating-point logistic run is an exact nonautonomous logistic family).** Let $Y_0 := x_0$, $Y_{k+1} := \mathrm{Step}(r, Y_k)$. Then there is a sequence $(r_k)$ with $|r_k - r| \le \gamma_3(u)|r|$ for all $k$ and
> $$Y_{k+1} = \Phi_{r_k}(Y_k) \qquad\text{for all }k.$$

*Proof.* Apply Theorem 8.1 at each $Y_k$ and collect the parameters. $\square$

Consistency with the coefficient picture is immediate: $\Phi_{r}(z) = H((0,r,-r),z)$, so Theorem 8.3 is a *strengthening* of Theorem 4.3 for this particular program — it says the perturbed coefficient list can be taken of the special form $(0,r',-r')$, i.e. the perturbation respects the parametric family. Theorem 4.3 alone would allow the two nonzero coefficients to be perturbed independently.

**Remark 8.3b (Why the expression matters).** The proof of Theorem 8.1 uses in an essential way that the symbol $r$ occurs *once* in the expression, so all three roundings can be collected onto it. The algebraically equivalent expanded program $ (r\otimes x) \ominus (r \otimes (x\otimes x))$ contains two occurrences of $r$, which receive independent distortions; the result is generally not $\Phi_{r'}$ for any single $r'$. Structural backward error is therefore a *syntactic* invariant of the evaluation graph — parameter multiplicity — rather than a property of the function computed. This is the content of the first conjecture in Section 10.

> **Theorem 8.4 (Boundary of the theory: detuning can destroy invariance).** If $r>4$ then $\Phi_r(\tfrac12) = r/4 \notin [0,1]$.

*Proof.* $\Phi_r(1/2) = r\cdot\tfrac12\cdot\tfrac12 = r/4 > 1$. $\square$

Small as it is, the parameter perturbation of Theorem 8.1 can push $r$ across the threshold $4$, after which $[0,1]$ is no longer invariant and the orbit escapes. Consequently **no a-priori argument can dispense with the observed hypothesis** "the execution remained in $[0,1]$" in Theorems 5.8 and 7.3: that hypothesis is load-bearing, and it is exactly the runtime check the semantics layer requires.

---

## 9. Algorithms

Three algorithms follow directly from the theory. All are $O(1)$ per iteration in additional cost, so certification is essentially free.

**Algorithm A — Certified defect.** Given a coefficient list $\mathbf a$ of length $n$, an observed magnitude bound $B$, and a unit roundoff $u$, return $\delta = \gamma_{2n}(u)\sum_i |a_i|B^i$. Cost: $O(n)$. Correctness: Theorem 4.2.

**Algorithm B — Instrumented iteration with a-posteriori bound.** Run $X_{k+1} = \widehat H(\mathbf a, X_k)$; at each step, check $|X_k| \le B$ (abort if violated: the semantic hypothesis has failed); update $E_{k+1} = \delta + L_k E_k$ where $L_k$ is the observed local expansion factor at $X_k$; report the certified horizon $\max\{n : E_n \le \texttt{tol}\}$. Cost: $O(n)$ per step. Correctness: Theorem 7.1.

**Algorithm C — Backward coefficient reconstruction.** Replay the Horner recursion recording the two per-level rounding factors, and emit the perturbed coefficient list $\mathbf b$ of Theorem 3.1 explicitly, together with the verification $\widehat H(\mathbf a,x) = H(\mathbf b,x)$ to the last bit. Cost: $O(n)$. Correctness: constructive content of Theorem 3.1. This algorithm turns the semantics theorem into a *witness*: it hands the user the exact polynomial the machine solved.

---

## 10. Discussion and future directions

### 10.1 What the separation buys

The two-layer architecture is not a presentational convenience; it changes what can be proved.

- **Layer (S) is improvable by better arithmetic, layer (D) is not.** Doubling the precision divides $\delta$ by $2^{53}$ and extends the certified horizon of Theorem 5.8 by $\log_4 2^{53} \approx 26$ steps — linearly in the number of bits, exactly as the folklore predicts, but now as a theorem.
- **Layer (D) is improvable by asking a better question, layer (S) is not.** Theorem 6.4 achieves a bound uniform in $n$ with *identical* arithmetic, purely by allowing the shadowing orbit to start elsewhere.
- **The interface is lossless.** Theorem 3.3 is derived from Theorem 3.1 in two lines; the converse derivation is impossible, since the forward bound does not determine which perturbed problem was solved. This is why the backward statement, not the forward one, is the right output of layer (S).

### 10.2 Limitations

The theory as developed covers univariate polynomial iterations evaluated by Horner's rule in a relative-error rounding model. Extensions to multivariate systems, to rational and transcendental primitives (where the relative-error model still applies but the magnitude functional changes), to division (where cancellation can violate the "no exceptional value" hypothesis in subtler ways), and to underflow (where the relative model must be replaced by a mixed relative/absolute one) are all natural and open. Theorem 6.1 requires global inverse branches; extending it to piecewise-expanding maps with critical points, such as the logistic map at $r=4$, requires tracking itineraries.

### 10.3 Future directions

> **1. Structural backward error is a property of the evaluation scheme, not the polynomial.**
> *Conjecture.* For a parameterised polynomial family $p_\theta$, a straight-line evaluation program admits *family-structural* backward error (every rounded execution equals the exact $p_{\theta'}$ for some $\theta'$ with $|\theta'-\theta| \le \gamma_k(u)|\theta|$) **iff** the program's expression graph factors through a single occurrence of each parameter. The key insight is that structural backward error is a *syntactic* invariant of the graph (parameter multiplicity), not a numerical property. Theorem 8.1 proves the positive direction for the single-occurrence product form $r \otimes (x \otimes (1 \ominus x))$ and identifies the expanded form $rx - rx^2$, where $r$ occurs twice, as the natural candidate counterexample; the general statement is a finite combinatorial claim about expression graphs.

> **2. Nonautonomous shadowing with observed local expansion beats the global constant.**
> *Conjecture.* For the logistic map at $r=4$ the a-posteriori recursion $E_{n+1} = \delta + |4-8X_n|\,E_n$ of Theorem 7.1 grows like $e^{n\ln 2}$, not $4^n$, for Lebesgue-almost every initial condition, so the certified shadowing horizon doubles. The key insight is that the Birkhoff average of $\ln|f'|$ against the natural invariant density $\tfrac1{\pi\sqrt{z(1-z)}}$ is $\ln 2$, not $\ln 4$: the orbit visits the strongly-expanding endpoints rarely enough that the *product* of observed local factors grows at the Lyapunov rate rather than the worst-case rate.

> **3. Uniform shadowing beyond invertibility.** Extend Theorem 6.1 to maps with critical points by choosing inverse branches along an itinerary, and determine whether a double-precision logistic execution is shadowed uniformly in time by *some* exact orbit (not through the same initial point).

> **4. Mixed relative/absolute models.** Replace Definition 2.1 by $\mathrm{fl}(a\circ b) = (a\circ b)(1+e) + \eta$ with $|e|\le u$, $|\eta| \le \eta_{\min}$ to cover gradual underflow, and determine how the defect certificate of Theorem 3.3 degrades near the bottom of the exponent range.

> **5. Interval and stochastic refinements.** The certificate of Algorithm B is deterministic and worst-case. A probabilistic version — treating the $e_i$ as independent bounded random variables — should replace $\gamma_{2n}(u)$ by $O(\sqrt{n}\,u)$ with high probability, giving a horizon extension of $\tfrac12\log_L n$ steps.

---

## 11. Conclusion

The claim that floating-point simulation of chaos is meaningless conflates a semantic question with a dynamical one. Separated, both become tractable and both become sharp. A finite floating-point execution of a polynomial iteration, free of overflow and exceptional values, is not an approximation to anything: it is the exact orbit of a nonautonomous polynomial system whose coefficients lie within relative distance $\gamma_{2n}(u)$ of the nominal ones, hence an exact pseudo-orbit with the compositional defect $\gamma_{2n}(u)\sum_i|a_i|B^i$. That certificate is unconditional in the dynamics and checkable at runtime. Handing it to a dynamical theorem then yields explicit, attributable error bounds: exponential and provably unimprovable under forward tracking; uniform in time under expansivity; and, in the a-posteriori nonautonomous form, computable by the running program about itself. The exponential loss of accuracy in chaotic simulation is real, but it is a fact about dynamics, not about arithmetic — and knowing exactly which problem the machine solved is more useful than knowing how far its answer drifted.
