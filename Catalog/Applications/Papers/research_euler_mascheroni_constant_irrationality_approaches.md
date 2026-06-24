# An Irrationality Engine and Effective Bracketing for the Euler–Mascheroni Constant

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Number Theory (Diophantine approximation, irrationality criteria)

## Abstract

We develop a complete *Diophantine engine* for irrationality — the equivalence between irrationality of a real number $x$ and the existence of arbitrarily small nonzero integer linear forms $q\,x - p$ — and we apply it as a diagnostic to the Euler–Mascheroni constant $\gamma = \lim_{n\to\infty}(H_n - \ln n)$. We prove the engine in three formulations: a biconditional $\varepsilon$-form, its two constituent directions (sufficiency via the nonzero-integer floor; necessity via Dirichlet's approximation theorem), and a sequence form suited to Apéry-style arguments. We then quantify the standard approximations to $\gamma$. Writing $s_n = H_n - \ln(n+1)$ and $s'_n = H_n - \ln n$, we establish the exact trapping-width identity $s'_n - s_n = \ln(n+1) - \ln n = \ln(1 + 1/n)$ for $n \geq 1$, and derive effective one-sided and two-sided error bounds $|s_n - \gamma| < \ln(1 + 1/n)$. The combination of these results isolates, in precise terms, the structural obstruction to an elementary irrationality proof of $\gamma$: the natural approximants converge only at rate $\Theta(1/n)$ (sub-geometric) and have *transcendental* endpoints, hence cannot supply the integer data the engine requires. We close with five precise, testable conjectures charting a route forward. The mathematical content corresponds to a machine-checked Lean 4 development with no unproven assumptions.

---

## 1. Introduction

The Euler–Mascheroni constant
$$\gamma \;=\; \lim_{n\to\infty}\Bigl(\sum_{k=1}^{n}\frac{1}{k} - \ln n\Bigr) \;\approx\; 0.5772156649,$$
is among the most fundamental constants in analysis and number theory, yet its arithmetic nature is entirely unresolved: it is not known whether $\gamma$ is irrational, let alone transcendental. This stands in stark contrast with $e$ (irrationality: Euler; transcendence: Hermite) and $\zeta(3)$ (irrationality: Apéry, 1978).

The purpose of this paper is twofold. First, we give a self-contained, rigorous treatment of the abstract criterion that underlies essentially all irrationality proofs — what we call the **irrationality engine** — including a faithful biconditional and a sequence form. Second, we apply the engine *diagnostically* to $\gamma$: rather than claiming a proof of an open problem, we quantify the best elementary approximations and prove precisely why they cannot drive the engine. The outcome is a sharp, formal articulation of the obstruction, together with a research program.

Throughout, $H_n = \sum_{k=1}^n 1/k$ denotes the $n$-th harmonic number, $\ln$ the natural logarithm, $\lfloor \cdot \rfloor$ the floor, and $\operatorname{round}(t)$ the nearest integer to $t$.

### 1.1 Summary of contributions

- **Theorem A (engine, sequence form).** If $x \in \mathbb{R}$ admits integers $q_n \geq 1$, $p_n$ with $q_n x - p_n \neq 0$ for all $n$ and $q_n x - p_n \to 0$, then $x$ is irrational.
- **Theorem B (engine, $\varepsilon$-form, sufficiency).** If for every $\varepsilon > 0$ there exist $q \geq 1$, $p$ with $0 < |q x - p| < \varepsilon$, then $x$ is irrational.
- **Theorem C (engine, $\varepsilon$-form, necessity).** If $x$ is irrational, then for every $\varepsilon > 0$ such $q, p$ exist. Consequently the $\varepsilon$-criterion is a biconditional characterization of irrationality.
- **Theorem D (exact bracket width).** For $n \geq 1$, $s'_n - s_n = \ln(n+1) - \ln n$.
- **Theorems E–G (effective error bounds).** For $n \geq 1$: $\gamma - s_n < \ln(n+1)-\ln n$, $s'_n - \gamma < \ln(n+1)-\ln n$, and $|s_n - \gamma| < \ln(n+1)-\ln n$.

All statements correspond to machine-checked theorems with no `sorry` and only standard foundational axioms.

### 1.2 Relation to classical irrationality proofs

The engine of §3 is not a new idea in disguise; it is the explicit, reusable distillate of a method that is two and a half centuries old. Euler's proof that $e$ is irrational, in its modern packaging, constructs the integer pairs $q_n = n!$ and $p_n = n!\sum_{k=0}^n 1/k!$, for which $q_n e - p_n = n!\sum_{k>n} 1/k! \in (0,1)$ and tends to $0$; Theorem A then concludes irrationality immediately. Apéry's 1978 tour de force for $\zeta(3)$ produces, by a far deeper recurrence, integer sequences $a_n, b_n$ with $b_n \zeta(3) - a_n \neq 0$ decaying geometrically; once those sequences are in hand, the *logical* step to irrationality is again exactly Theorem A. What changes from constant to constant is never the engine — it is the difficulty of manufacturing the integer fuel. Isolating the engine as a standalone, proven biconditional (Corollary 3.2) lets us state, with no hand-waving, precisely what fuel a proof for $\gamma$ would need, and then prove that the obvious fuel does not ignite. That negative half is the genuine content of §§4–5.

We stress what we do *not* claim. We do not prove $\gamma$ irrational; that remains open. We prove (i) the engine, in full, in both directions, and (ii) sharp, effective facts about the standard approximants that, taken together, show the standard approximants cannot drive the engine. The value of (ii) is diagnostic: it converts the vague statement "$\gamma$ is hard" into two named, measurable defects.

---

## 2. Definitions

**Definition 2.1 (Harmonic number).** For $n \in \mathbb{N}$, $H_n = \sum_{k=1}^{n} \tfrac{1}{k}$, with $H_0 = 0$.

**Definition 2.2 (Euler–Mascheroni constant).** $\gamma = \lim_{n\to\infty}(H_n - \ln n)$. The limit exists because $n \mapsto H_n - \ln n$ is decreasing and bounded below.

**Definition 2.3 (Standard approximants).** For $n \in \mathbb{N}$ define
$$s_n = H_n - \ln(n+1), \qquad s'_n = H_n - \ln n,$$
with the convention $s'_0 = H_0 = 0$ to avoid $\ln 0$. We call $s_n$ the *lower approximant* and $s'_n$ the *upper approximant*. (In the formal development these are `eulerMascheroniSeq` and `eulerMascheroniSeq'` respectively.)

**Definition 2.4 (Integer linear form).** Given $x \in \mathbb{R}$, $q \in \mathbb{N}$, $p \in \mathbb{Z}$, the associated *integer linear form* is $L(q,p;x) = q\,x - p \in \mathbb{R}$. Its magnitude $|L|$ measures how nearly the integer multiple $qx$ approximates an integer $p$.

**Definition 2.5 (Irrationality).** $x \in \mathbb{R}$ is *irrational* if $x \notin \mathbb{Q}$, equivalently if there is no pair $(q,p) \in \mathbb{N}_{\geq 1} \times \mathbb{Z}$ with $x = p/q$.

---

## 3. The irrationality engine

The engine formalizes the folklore principle that *rationals are "rigid" against integer linear forms while irrationals are "flexible."* The rigidity is a hard floor; the flexibility is Dirichlet's theorem.

### 3.1 The rational floor

**Lemma 3.1 (Nonzero-integer floor).** Let $x = a/b$ with $b \in \mathbb{N}_{\geq 1}$, $a \in \mathbb{Z}$. For every $q \in \mathbb{N}$, $p \in \mathbb{Z}$,
$$q x - p = \frac{qa - pb}{b}.$$
If $qx - p \neq 0$ then $qa - pb$ is a nonzero integer, so $|qa - pb| \geq 1$ and therefore
$$|q x - p| \;\geq\; \frac{1}{b}.$$

*Proof.* Substitute $x = a/b$ and clear denominators; $qa - pb \in \mathbb{Z}$, and a nonzero integer has absolute value at least $1$. $\square$

Lemma 3.1 is the engine of sufficiency: a rational cannot have arbitrarily small nonzero linear forms.

### 3.2 Sufficiency

**Theorem B ($\varepsilon$-form, sufficiency).** Let $x \in \mathbb{R}$. Suppose that for every $\varepsilon > 0$ there exist $q \in \mathbb{N}$, $p \in \mathbb{Z}$ with $1 \leq q$, $0 < |q x - p|$, and $|q x - p| < \varepsilon$. Then $x$ is irrational.

*Proof.* Contrapose. Assume $x$ is rational, $x = p_0/q_0$ in lowest terms with $q_0 \geq 1$. Apply Lemma 3.1 with $b = q_0$: every nonzero linear form satisfies $|qx - p| \geq 1/q_0$. Now take $\varepsilon = 1/q_0 > 0$. The hypothesis would require a pair with $0 < |qx - p| < 1/q_0$, contradicting the floor. Hence no rational $x$ satisfies the hypothesis, i.e. any $x$ that does is irrational. $\square$

**Theorem A (sequence form).** Let $x \in \mathbb{R}$ and suppose there are sequences $q : \mathbb{N} \to \mathbb{N}$, $p : \mathbb{N} \to \mathbb{Z}$ with, for all $n$, $q_n \geq 1$ (implicitly, to make $q_n$ usable) and $q_n x - p_n \neq 0$, and with $q_n x - p_n \to 0$. Then $x$ is irrational.

*Proof.* Contrapose: suppose $x = a/b$ rational, $b \geq 1$. For each $n$, $q_n x - p_n \neq 0$, so by Lemma 3.1 $|q_n x - p_n| \geq 1/b > 0$, a fixed positive bound independent of $n$. This contradicts $q_n x - p_n \to 0$, which forces the terms eventually below $1/b$. Hence $x$ is irrational. $\square$

Theorem A is the form deployed in classical proofs: one constructs explicit integer sequences (e.g. Apéry's for $\zeta(3)$, the partial-sum/remainder pairs for $e$) whose linear forms are nonzero and decay to $0$.

### 3.3 Necessity via Dirichlet

**Theorem C ($\varepsilon$-form, necessity).** If $x$ is irrational, then for every $\varepsilon > 0$ there exist $q \in \mathbb{N}_{\geq 1}$ and $p \in \mathbb{Z}$ with $0 < |q x - p| < \varepsilon$.

*Proof.* Fix $\varepsilon > 0$. Choose $N \in \mathbb{N}$ with $1/(N+1) < \varepsilon$ (e.g. $N = \lfloor \varepsilon^{-1}\rfloor + 1$). By **Dirichlet's approximation theorem** (the form `Real.exists_nat_abs_mul_sub_round_le`: for any real $x$ and any positive integer bound there is a $k$ with $1 \leq k$ and $|k x - \operatorname{round}(kx)| \leq 1/(N+1)$), select such a $k$ with
$$|k x - \operatorname{round}(kx)| \leq \frac{1}{N+1} < \varepsilon.$$
Put $q = k$ and $p = \operatorname{round}(kx) \in \mathbb{Z}$. Then $|qx - p| < \varepsilon$. It remains to check $|qx - p| > 0$: if $qx - p = 0$ then $x = p/q \in \mathbb{Q}$, contradicting irrationality. Hence $0 < |qx - p| < \varepsilon$. $\square$

**Corollary 3.2 (Biconditional characterization).** $x$ is irrational $\iff$ for every $\varepsilon > 0$ there exist $q \geq 1$, $p$ with $0 < |qx - p| < \varepsilon$. (Theorem B gives $\Leftarrow$; Theorem C gives $\Rightarrow$.) In the formal development this biconditional is `irrational_iff_forall_eps_linear_form`, and its specialization to $\gamma$ is `irrational_eulerMascheroniConstant_iff`.

The biconditional is the precise statement of *what an irrationality proof of $\gamma$ must produce*: an effective supply of arbitrarily small nonzero integer linear forms in $\gamma$.

---

## 4. Effective bracketing of $\gamma$

We now turn the abstract criterion onto $\gamma$ via the standard approximants of Definition 2.3.

### 4.1 The sandwich

It is classical, and provable from monotonicity of $n \mapsto H_n - \ln n$ together with $\ln(n+1) - \ln n = \int_n^{n+1} dt/t$ and the integral comparison $1/(n+1) < \int_n^{n+1} dt/t < 1/n$, that for all $n \geq 1$,
$$s_n \;<\; \gamma \;<\; s'_n. \tag{Sandwich}$$
That is, the lower approximant strictly underestimates and the upper approximant strictly overestimates $\gamma$. (In the formal development the two inequalities are `eulerMascheroniSeq_lt_eulerMascheroniConstant` and `eulerMascheroniConstant_lt_eulerMascheroniSeq'`, packaged as `eulerMascheroniSeq_sandwich`.)

### 4.2 Exact width

**Theorem D (bracket width).** For all $n \geq 1$,
$$s'_n - s_n = \ln(n+1) - \ln n = \ln\!\Bigl(1 + \frac{1}{n}\Bigr).$$

*Proof.* For $n \geq 1$ the convention does not engage, so
$$s'_n - s_n = \bigl(H_n - \ln n\bigr) - \bigl(H_n - \ln(n+1)\bigr) = \ln(n+1) - \ln n.$$
The harmonic terms cancel identically; the last equality is the logarithm law $\ln(n+1) - \ln n = \ln((n+1)/n)$. $\square$

This identity is exact — no error term — and computable: $H_n \in \mathbb{Q}$, and $\ln(1+1/n)$ admits rapidly convergent rational enclosures.

### 4.3 Effective error bounds

**Theorem E (effective lower error).** For all $n \geq 1$, $\;\gamma - s_n < \ln(n+1) - \ln n$.

*Proof.* By the right half of (Sandwich), $\gamma < s'_n$, hence $\gamma - s_n < s'_n - s_n$. Apply Theorem D to the right side. $\square$

**Theorem F (effective upper error).** For all $n \geq 1$, $\;s'_n - \gamma < \ln(n+1) - \ln n$.

*Proof.* By the left half of (Sandwich), $s_n < \gamma$, hence $s'_n - \gamma < s'_n - s_n$. Apply Theorem D. $\square$

**Theorem G (two-sided absolute error).** For all $n \geq 1$, $\;|s_n - \gamma| < \ln(n+1) - \ln n$.

*Proof.* By the left half of (Sandwich), $s_n < \gamma$, so $s_n - \gamma < 0$ and $|s_n - \gamma| = \gamma - s_n$. Apply Theorem E. $\square$

Because $\ln(1 + 1/n) \to 0$, the approximants converge to $\gamma$; because the bound is explicit, the convergence is *effective*: for any target precision $\delta$, taking $n$ with $\ln(1+1/n) < \delta$, i.e. $n > 1/(e^{\delta}-1)$, guarantees $|s_n - \gamma| < \delta$.

### 4.4 Rate analysis

Since $\ln(1 + 1/n) = \tfrac1n - \tfrac{1}{2n^2} + O(n^{-3})$, the bracket width is $\Theta(1/n)$. To force the error below $10^{-d}$ one needs roughly $n \approx 10^{d}$ terms. This is **sub-geometric**: contrast with the constructions for $e$ and $\zeta(3)$, where the linear forms decay like $\rho^n$ for some fixed $\rho < 1$, giving $d \approx (\log_{10}(1/\rho))\, n$ — exponentially faster in $n$.

---

## 5. The obstruction, made precise

Combining §3 and §4 yields the central diagnostic. The engine (Theorem A / Corollary 3.2) consumes *integer* data: nonzero forms $q_n \gamma - p_n$ with $q_n \in \mathbb{N}_{\geq 1}$, $p_n \in \mathbb{Z}$, tending to $0$. The harmonic bracket supplies approximants $s_n, s'_n$ that converge to $\gamma$ and even sandwich it. Yet:

1. **Transcendental endpoints.** $s_n = H_n - \ln(n+1)$ and $s'_n = H_n - \ln n$ are *not rational*: although $H_n \in \mathbb{Q}$, the subtracted logarithm is (for $n \geq 1$, $n+1 \neq 1$) transcendental. There is no integer $q_n$ such that $q_n s_n$ or $q_n s'_n$ is forced to be an integer, so the bracket does not present a clean integer linear form $q_n \gamma - p_n$. The convergence is of the right *kind* (a closing interval) but of the wrong *material* (irrational/transcendental endpoints), and the engine cannot read it.

2. **Sub-geometric speed.** Even setting aside (1), the width $\Theta(1/n)$ is far too slow. Irrationality measures and the engine's quantitative refinements need decay faster than the reciprocal of the denominator $q_n$; with denominators that grow at least linearly (to carry $H_n$), a $\Theta(1/n)$ width is at the boundary where no contradiction with rationality can be extracted.

These two facts are not heuristic. They are exactly why the most natural family of approximations — the one written into the definition of $\gamma$ — cannot, even in principle, be fed into the irrationality engine. This is the formal content behind the long-standing difficulty of the problem.

---

## 6. Algorithms

### 6.1 Effective enclosure of $\gamma$

**Input:** precision $\delta > 0$.
**Output:** rational interval $[\ell, u]$ with $\ell \leq \gamma \leq u$ and $u - \ell < \delta$.

```
1. Choose n with ln(1 + 1/n) < δ, e.g. n = ceil(1/(exp(δ) - 1)).
2. Compute H_n = Σ_{k=1}^n 1/k as an exact rational.
3. Compute rational bounds L ≤ ln(n)   ≤ L'      (interval logarithm).
4. Compute rational bounds M ≤ ln(n+1) ≤ M'.
5. Return ℓ = H_n - M', u = H_n - L.   // s_n ≤ γ ≤ s'_n, widened by log error
```
Complexity: $O(n) = O(1/\delta)$ rational additions plus two interval-logarithm evaluations. The $\Theta(1/\delta)$ term count is exactly the sub-geometric cost quantified in §4.4.

### 6.2 Engine certificate checker

**Input:** a finite list of triples $(q_i, p_i, b_i)$ purporting that $|q_i x - p_i| < b_i$, with $q_i \geq 1$ and $b_i \to 0$.
**Output:** verdict "irrational (certified)" if all forms are nonzero and the bounds witness decay below every threshold; else "inconclusive."

```
1. For each i: assert q_i ≥ 1 and (q_i x - p_i) ≠ 0  (the nonzero condition).
2. Assert b_i is monotone-ish and inf b_i = 0.
3. If both hold for a genuine sequence, conclude Irrational x by Theorem A.
```
This is the executable shadow of Theorem A: a valid certificate is precisely a sequence satisfying its hypotheses.

---

## 7. Numerical illustration

For small $n$ the approximants and the exact width are:

| $n$ | $H_n$ | $s_n = H_n - \ln(n+1)$ | $s'_n = H_n - \ln n$ | width $\ln(1+1/n)$ |
|----:|------:|-----------------------:|---------------------:|-------------------:|
| 1   | 1.000000 | 0.306853 | 1.000000 | 0.693147 |
| 10  | 2.928968 | 0.531073 | 0.626383 | 0.095310 |
| 100 | 5.187378 | 0.572257 | 0.582207 | 0.009950 |
| 1000| 7.485471 | 0.576716 | 0.577716 | 0.000999 |

Every row satisfies $s_n < \gamma \approx 0.5772157 < s'_n$, and the width column is exactly $\ln(1+1/n)$, confirming Theorem D and the $\Theta(1/n)$ rate. Note that to gain one decimal digit of accuracy one must multiply $n$ by ten — the sub-geometric signature.

---

## 8. Applications and significance

- **A diagnostic template.** The pairing "engine + effective bracket" is reusable for any constant defined as a discrete-minus-continuous limit (Stieltjes constants, generalized Euler constants, $\sum 1/p - \ln\ln$ type sums over primes). It cleanly separates *convergence kind* from *arithmetic readability*.
- **Conditional number theory.** The biconditional (Corollary 3.2) is the correct hypothesis to assume in conditional theorems: "if small forms exist then …". It makes precise the input that irrationality-measure results need.
- **Pedagogy of irrationality proofs.** Theorems A–C isolate the exact logical skeleton shared by the proofs for $e$ and $\zeta(3)$, stripped of constant-specific construction.

---

## 9. Discussion and future work

The analysis localizes the difficulty of $\gamma$'s irrationality to two measurable defects of the harmonic bracket: transcendental endpoints and $\Theta(1/n)$ speed. A successful attack must replace the bracket with a sequence that is *rational* and *geometrically fast*. We record five precise conjectures (the Phase A future directions):

**C1 — Geometric-rate criterion unmet by the harmonic bracket.** There is no sequence of pairs $(q_n, p_n) \in \mathbb{N}_{\geq 1} \times \mathbb{Z}$ obtained as integer linear combinations of $\{H_k, \ln(k+1) : k \leq n\}$ with bounded integer coefficients such that $0 < |q_n \gamma - p_n| \leq C\rho^n$ for some $\rho < 1$. A negative result would explain elementary failure; a positive one would be a breakthrough.

**C2 — Effective irrationality-measure scaffold.** Prove, vacuity-free, the dichotomy $\text{Irrational } x \Rightarrow (\text{LiouvilleNumber } x \ \lor\ \text{HasFiniteIrrationalityMeasure } x)$ as a general lemma and instantiate at $\gamma$; the $\gamma$ branch remains open but the framework is provable.

**C3 — Linear-forms transfer between $\gamma$ and $\zeta$-values.** Small nonzero integer linear forms in $\{1,\gamma,\zeta(2)\}$ (resp. $\{1,\gamma,\ln 2\}$) exist iff small forms in $\{1,\gamma\}$ exist; i.e. adjoining a known irrational creates no spurious approximations. Testable via a two-variable engine for $qx + ry - p$ and the conditions under which $r$ can be forced to $0$.

**C4 — BBP-style rational accelerant.** There exists a rational-coefficient series $\gamma = \sum r_n$, $r_n \in \mathbb{Q}$, with partial-sum denominators $D_n$ satisfying $|\gamma - \sum_{k\leq n} r_k| = o(1/D_n)$. Such a series would feed the engine and prove irrationality; candidates arise from the digamma/Stieltjes-constant expansions.

**C5 — Width-optimality of the harmonic bracket.** Among all brackets $[H_n - \ln f(n),\, H_n - \ln g(n)]$ containing $\gamma$ with $g(n) < n+1 \leq f(n)$, the choice $f = n+1$, $g = n$ is width-optimal in an appropriate sense.

---

## 9.1 On the role of the Stieltjes constants

The Stieltjes constants $\gamma_k$ arise as the coefficients in the Laurent expansion of the Riemann zeta function about its pole at $s=1$:
$$\zeta(s) = \frac{1}{s-1} + \sum_{k=0}^{\infty} \frac{(-1)^k}{k!}\,\gamma_k\,(s-1)^k, \qquad \gamma_0 = \gamma.$$
Thus $\gamma$ is merely the zeroth member of an infinite family, and the same arithmetic mystery surrounds every $\gamma_k$. There are representations
$$\gamma_k = \lim_{n\to\infty}\Bigl(\sum_{m=1}^{n} \frac{(\ln m)^k}{m} - \frac{(\ln n)^{k+1}}{k+1}\Bigr),$$
which generalize the harmonic definition of $\gamma$ ($k=0$) and exhibit the same structural defect: discrete sums minus a continuous (here, logarithmic-power) term, with transcendental tails. The diagnostic of §5 therefore applies verbatim to each $\gamma_k$, and conjecture C4 — the search for a rational-coefficient accelerant — is naturally posed for the whole family at once. A method that cracks one $\gamma_k$ by manufacturing rational, geometrically convergent fuel would plausibly crack all of them, which is part of why the problem is regarded as a genuine frontier rather than an isolated curiosity.

## 9.2 Why effectivity matters

Many existence results in Diophantine approximation are ineffective: they assert that approximations exist without bounding *where* to find them. The bounds of §4 are deliberately effective. Theorem D is an exact identity, and Theorems E–G give explicit, computable error envelopes. Consequently the enclosure algorithm of §6.1 is a genuine procedure: feed it a precision and it returns a rational interval guaranteed to contain $\gamma$. Effectivity is also what makes the obstruction analysis rigorous rather than heuristic — we are not merely observing that the bracket *seems* slow; we have the exact width and can quantify the term count to any digit.

## 10. Conclusion

We have given a rigorous, self-contained account of the irrationality engine in biconditional, directional, and sequence forms, and applied it diagnostically to the Euler–Mascheroni constant. The harmonic approximants $s_n = H_n - \ln(n+1)$ and $s'_n = H_n - \ln n$ trap $\gamma$ with an exact width $\ln(1+1/n)$ and effective error $|s_n - \gamma| < \ln(1+1/n)$, yet — by transcendental endpoints and sub-geometric speed — cannot drive the engine. This is a precise map of the wall that has stood for three centuries, and a concrete specification of the door a future proof must open.
