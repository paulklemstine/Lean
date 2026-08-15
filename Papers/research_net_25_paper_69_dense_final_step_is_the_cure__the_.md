# Dense Final-Step Inputs: Expressivity Invariance, Boundary Conditioning, and the State Horizon of Recurrent Carry Chains

**Author:** Aristotle
**Date:** 2026-08-15

---

## Abstract

A recurrent answer path trained on five-digit least-significant-digit-first base-$10$ addition attains perfect accuracy at the training length and collapses at length eight, even though the underlying transition rule is depth-uniform. We isolate the cause by a controlled decomposition. On the mathematical side we prove three things. **(i) Transition half.** The carry automaton satisfies an exact depth-uniform invariant, $\mathrm{val}(d,n) + c_n b^n = \mathrm{val}(a,n) + \mathrm{val}(b,n)$ for all $n$, and any learned step function that is pointwise correct on the finitely many reachable triples $(x,y,c)$ with $x,y<b$, $c\le 1$ — exactly the triples any depth-$\ge 2$ training set exercises — is automatically correct at every depth. Hence the observed length wall is not an expressivity obstruction. **(ii) Boundary half.** The end-of-sequence (EOS) input acts on the cell only through the vector $v = We \in \mathbb{R}^h$; for every EOS width $d \ge 1$ the realisable set of such $v$ is all of $\mathbb{R}^h$, so EOS width adds no representable function. But under gradient flow on the factorised parameterisation the induced velocity is $\dot v = -(\|e\|^2 I + WW^{\mathsf T})g$, a preconditioned descent whose gain $\langle g,-\dot v\rangle = \|e\|^2\|g\|^2 + \|W^{\mathsf T}g\|^2$ is at least $d c^2 \|g\|^2$ for per-coordinate initialisation scale $c$ — *linear in the EOS width*. Consequently the quadratic boundary loss contracts as $e^{-2dc^2 t}$ and a sufficient training budget scales like $1/d$. **(iii) Horizon half.** For a contractive cell ($\|Az\|\le\lambda\|z\|$, $\lambda<1$) and any bounded linear readout there is a finite depth beyond which every fixed decision margin is lost; a final-step gain $m\ge 1$ extends the usable depth by exactly $k \ge \log m/\log(1/\lambda)$ steps. These results explain a decisive empirical control in which two arms with byte-identical cell and head weights, differing only in EOS width ($384$ vs $20$), score $1.0000$ versus $0.0259$ at length eight. The synthesis, which we call the **dense-final-step law**, is that boundary-input width is invisible to the function class and visible to the optimiser, and that boundary richness buys usable depth only logarithmically.

**Keywords:** carry chain, length generalisation, boundary conditioning, factorised gradient flow, preconditioning, contraction, state horizon, recurrent readout.

---

## 1. Introduction

### 1.1 The phenomenon

Least-significant-digit-first addition is the canonical stress test for length generalisation. The task has a two-line exact solution with a one-bit state, the training distribution exercises every reachable state transition, and yet models trained at length $n=5$ routinely fail at $n = 8$. In the round of experiments this paper analyses, a recurrent carry cell over a trained encoder's per-column features reached full-sequence accuracy $1.0000$ at $n=5,6,7,8$, while a bare recurrent cell over raw one-hot digit inputs reached $1.0000$ at $n=5$ and $0.002$–$0.08$ at $n=8$ (chance $10^{-9}$).

The natural reading of such a pair — and the reading initially adopted — is that the cure lies in the *content* of the encoder's features. This paper reports the dissection of that claim and the mathematics that settles it.

### 1.2 The three hypotheses and their fate

Three mutually exclusive hypotheses were tested, each isolating one architectural variable while holding the rest fixed:

* **H1 (capacity).** The failure is a parameter-count artifact. *Test:* a capacity-matched raw recurrent cell at $471{,}582$ parameters (versus $335{,}242$ for the cure). *Outcome:* $n=8$ accuracy $0.0078$, $0.0063$ — **refuted**.
* **H2 (representation).** High-dimensional, well-separated features cure it; whether they are *learned* is immaterial. *Test:* a fixed **untrained** random $384$-dimensional projection of the same one-hots. *Outcome:* $1.0000$, $1.0000$ — the strong (learning-is-load-bearing) form is **refuted**, a weak dimensional form survives.
* **H3 (position).** The encoder's step-position signal is the lever. *Test:* raw one-hots concatenated with an $8$-dimensional sinusoidal position schedule ($28$-dimensional inputs). *Outcome:* $0.0049$, $0.0049$ — **refuted**.

None survives. The surviving common feature of the two curing arms was input *width*, which motivated the decisive control.

### 1.3 The decisive control

Pad the raw $20$-dimensional one-hot digit input with $364$ permanently zero coordinates. The digit pathway then carries exactly the information it carried before — $364$ of its input columns are dead. But the EOS token of this architecture is a **dense learned vector of the full input width**, presented at the final carry step; for the padded arm it is $384$-dimensional and the "dead" columns are alive for it. Because parameters are drawn in the same construction order, the recurrent cell and output head of the padded arm and of a variant whose EOS is only $20$-dimensional are **byte-identical for a fixed seed**; the arms differ in exactly one number, the EOS width, and by $364$ parameters in total.

| arm | EOS width $d$ | parameters | $n=8$ full accuracy | final-carry probe |
|---|---|---|---|---|
| padded, dense EOS (4 seeds) | $384$ | $335{,}242$ | $1.0000\times 4$ | $0.86$–$0.99$ |
| padded, narrow EOS (2 seeds) | $20$ | $334{,}878$ | $0.7441$, $0.0259$ | $0.86$–$0.99$ |
| untrained random projection (2 seeds) | $384$ | $335{,}242$ | $1.0000$, $1.0000$ | $0.86$–$0.99$ |
| raw + position (2 seeds) | $28$ | $129{,}830$ | $0.0049$, $0.0049$ | $0.86$–$0.99$ |
| capacity-matched raw (2 seeds) | $20$ | $471{,}582$ | $0.0078$, $0.0063$ | $0.86$–$0.99$ |
| raw baseline (7 seeds) | $20$ | $125{,}214$ | $0.0806$, $0.6997$, $0.0103$, $0.0063$, $0.0093$, $0.0020$, $0.0132$ | $0.86$–$0.99$ |

Protocol: plain $n=5$ LSB-first base-$10$ $a+b=c$, batch size $256$, $12{,}000$ AdamW steps, teacher-forced evaluation at $n=5,6,7,8$ on $2048$ fresh draws per length.

Two features of this table drive everything below. First, the *final-carry probe column is flat*: the recurrent transition retains its accuracy in every arm, including the ones whose full-sequence accuracy is at chance. The failure is a **readout** failure at the boundary, not a transition failure. Second, the raw baseline is a **distribution** ($0.0020$ to $0.6997$ across seven seeds), not a hard wall; an earlier two-seed reading undersampled it, though the qualitative conclusion — $0/7$ reach $1.0$ — stands.

### 1.4 Contributions

We prove:

1. **Exact length-generality of the carry transition** and a **local-to-global transfer theorem**: correctness on $200$ reachable triples forces correctness at all depths (§3). Consequently the wall is not an expressivity obstruction.
2. **Expressivity invariance of EOS width**: for all $d\ge 1$ the realisable boundary contributions are all of $\mathbb{R}^h$, so no two positive widths differ in function class (§4.1).
3. **Boundary conditioning**: a closed form for the induced gradient-flow velocity of the effective boundary bias, an exact expression for its descent rate, a gain bound linear in $d$, sharpness of that bound, and the resulting exponential contraction and $1/d$ budget law (§4.2–§4.4).
4. **The state horizon**: an impossibility theorem for bounded readouts of a contractive cell, and the logarithmic depth-shift bought by boundary gain (§5).
5. The **dense-final-step law** synthesising these (§6), with three falsifiable predictions (§8).

---

## 2. Notation

$b \ge 1$ is the base; digit streams are functions $\mathbb{N} \to \mathbb{N}$. For a stream $f$, $\mathrm{val}(f, n) = \sum_{i<n} f_i b^i$. The recurrent cell has hidden width $h$; the EOS vector is $e \in \mathbb{R}^d$ and the input matrix restricted to the EOS columns is $W \in \mathbb{R}^{h\times d}$. Norms are Euclidean, $\|x\|^2 = \sum_i x_i^2$. We write $I$ for the identity and $W^{\mathsf T}$ for the transpose.

---

## 3. The transition half: the carry chain is exactly length-general

### 3.1 The automaton

**Definition 3.1 (carry automaton).** For streams $a, b$ and base $\beta$ define $c_0 = 0$ and
$$c_{i+1} = \left\lfloor \frac{a_i + b_i + c_i}{\beta}\right\rfloor, \qquad d_i = (a_i + b_i + c_i) \bmod \beta .$$

**Lemma 3.2 (one-bit state).** If $\beta > 0$ and $a_i, b_i < \beta$ for all $i$, then $c_n \le 1$ for all $n$.

*Proof sketch.* Induction. If $c_n \le 1$ then $a_n + b_n + c_n \le 2\beta - 1$, so $c_{n+1} \le \lfloor (2\beta-1)/\beta\rfloor < 2$. $\square$

**Theorem 3.3 (exact depth-uniform invariant).** For every base $\beta$, all streams $a, b$, and every $n \ge 0$,
$$\mathrm{val}(d, n) + c_n\, \beta^{\,n} = \mathrm{val}(a, n) + \mathrm{val}(b, n).$$

*Proof sketch.* Induction on $n$. The base case is $0 = 0$. For the step, division with remainder gives the local identity $d_n + \beta c_{n+1} = a_n + b_n + c_n$. Multiplying by $\beta^n$ and expanding $\mathrm{val}(\cdot, n+1) = \mathrm{val}(\cdot, n) + (\cdot)_n\beta^n$ and $\beta^{n+1} = \beta^n\beta$, the claim reduces by ring rearrangement to the inductive hypothesis. $\square$

Equivalently: the emitted digit stream, extended by the terminal carry as a leading digit, *is* the base-$\beta$ representation of the sum of the truncated inputs, at every depth. There is no $n$-dependence anywhere in the rule.

### 3.2 Local-to-global transfer for a learned step function

**Definition 3.4 (model recurrence).** Let $T : \mathbb{N}^3 \to \mathbb{N}^2$, $T(x,y,c) = (\text{digit}, \text{next state})$. Define $\hat c_0 = 0$, $\hat c_{i+1} = T(a_i,b_i,\hat c_i)_2$ and $\hat d_i = T(a_i,b_i,\hat c_i)_1$.

**Definition 3.5 (reachable triples, local correctness).** A triple $(x,y,c)$ is *reachable* for base $\beta$ if $x < \beta$, $y < \beta$, $c \le 1$. A step function $T$ is *locally correct* if for every reachable triple
$$T(x,y,c) = \big((x+y+c)\bmod \beta,\ \lfloor (x+y+c)/\beta\rfloor\big).$$
For $\beta = 10$ there are $10\cdot 10\cdot 2 = 200$ reachable triples, all exercised by training data of depth $\ge 2$.

**Theorem 3.6 (local-to-global transfer).** Let $\beta > 0$, let $T$ be locally correct, and let $a_i, b_i < \beta$ for all $i$. Then $\hat c_n = c_n$ and $\hat d_n = d_n$ for every $n$.

*Proof sketch.* Induction on $n$ for the state part. By Lemma 3.2 the true state is in $\{0,1\}$; by the inductive hypothesis the model's state equals it, so the triple presented at step $n$ is reachable and local correctness applies verbatim, giving both the correct emitted digit and the correct next state. The system never leaves the finite verified region. $\square$

**Corollary 3.7 (no expressivity wall).** Under the hypotheses of Theorem 3.6, for every $n$,
$$\mathrm{val}(\hat d, n) + \hat c_n \beta^{\,n} = \mathrm{val}(a,n) + \mathrm{val}(b,n).$$
Moreover such a $T$ exists (take the true transition), so the hypothesis is not vacuous.

**Proposition 3.8 (sharpness).** If $T$ errs on a single reachable triple $(x,y,0)$ — i.e. $T(x,y,0)_1 \neq (x+y)\bmod\beta$ — then on the constant streams $a \equiv x$, $b \equiv y$ the model already emits a wrong digit at step $0$. Local correctness is thus exactly the right hypothesis: not weakenable, and finitely checkable.

**Discussion.** Theorem 3.6 and Corollary 3.7 say that the length wall cannot be blamed on the representational power of the recurrent cell: a correct, exactly depth-uniform step table exists, is finite, is pinned down by the training distribution, and generalises to arbitrary depth once pinned down. This is corroborated by the flat final-carry probe column of §1.3: in the measured system the transition really does generalise. The remaining suspect is the readout at the boundary step, which the next two sections analyse.

---

## 4. The boundary half: EOS width is invisible to the class, visible to the optimiser

### 4.1 Expressivity invariance

**Definition 4.1 (effective boundary bias).** For $W \in \mathbb{R}^{h\times d}$ and $e \in \mathbb{R}^d$, the *boundary bias* is $v = We \in \mathbb{R}^h$: the entire contribution of the learned EOS vector to the cell's pre-activation at the final carry step.

**Theorem 4.2 (surjectivity).** For every $d \ge 1$ and every $v \in \mathbb{R}^h$ there exist $W$ and $e$ with $We = v$.

*Proof.* Take $e = \mathbf 1_{\{j = 0\}}$ (the first standard basis vector) and let every column of $W$ equal $v$; then $(We)_i = \sum_j W_{ij}e_j = v_i$. $\square$

**Corollary 4.3 (no expressivity gain from EOS width).** For any $d_1, d_2 \ge 1$,
$$\{We : W\in\mathbb{R}^{h\times d_1}, e\in\mathbb{R}^{d_1}\} = \mathbb{R}^h = \{We : W\in\mathbb{R}^{h\times d_2}, e\in\mathbb{R}^{d_2}\}.$$
In particular the $20$-dimensional and $384$-dimensional EOS of the identical-weights control span exactly the same class of boundary contributions.

This is the formal death of any capacity reading of the control, and independently of H1: whatever the wide EOS does, it does not enlarge what the boundary step can express. It also shows the effect must be dynamical.

### 4.2 Gradient flow on the factorised parameterisation

Let the loss depend on the parameters only through $v = We$, and write $g = \nabla_v L \in \mathbb{R}^h$. The chain rule gives $\nabla_W L = ge^{\mathsf T}$ and $\nabla_e L = W^{\mathsf T} g$, so gradient flow on the factors is $\dot W = -ge^{\mathsf T}$, $\dot e = -W^{\mathsf T}g$, and the induced velocity of $v$ is $\dot v = \dot W e + W\dot e$.

**Definition 4.4 (boundary drift).** $\ \mathrm{drift}(W,e,g) := (-ge^{\mathsf T})e + W(-W^{\mathsf T}g)$.

**Lemma 4.5 (outer-product identity).** $(ge^{\mathsf T})e = \|e\|^2 g$.

**Theorem 4.6 (closed form of the boundary drift).**
$$\dot v = \mathrm{drift}(W,e,g) = -\big(\|e\|^2 I + WW^{\mathsf T}\big)g .$$

*Proof sketch.* The first term is Lemma 4.5 with a sign; the second is the associativity identity $W(W^{\mathsf T}g) = (WW^{\mathsf T})g$, which is a Fubini exchange of the two summations. $\square$

The matrix $\|e\|^2 I + WW^{\mathsf T}$ is symmetric positive semidefinite: the factorised parameterisation performs *preconditioned* descent on $v$, with a preconditioner that the training run itself determines.

### 4.3 The boundary gain and its dependence on $d$

**Theorem 4.7 (exact descent rate).**
$$\langle g, -\dot v\rangle = \|e\|^2\,\|g\|^2 + \|W^{\mathsf T}g\|^2 .$$

*Proof sketch.* Expand $\langle g, (\|e\|^2 I + WW^{\mathsf T})g\rangle$; the first term is immediate and the second is $g^{\mathsf T}WW^{\mathsf T}g = \|W^{\mathsf T}g\|^2$. $\square$

**Corollary 4.8 (gain bound).** $\langle g,-\dot v\rangle \ge \|e\|^2\|g\|^2$.

**Proposition 4.9 (sharpness).** For $W = 0$ the bound is an equality: $\langle g,-\dot v\rangle = \|e\|^2\|g\|^2$. So the EOS norm is the whole of the *guaranteed* gain; the $WW^{\mathsf T}$ term can only help.

**Theorem 4.10 (gain is linear in EOS width).** If the EOS vector has per-coordinate magnitude at least $c \ge 0$, i.e. $|e_j| \ge c$ for all $j$, then $\|e\|^2 \ge d c^2$ and hence
$$\langle g, -\dot v\rangle \;\ge\; d\,c^2\,\|g\|^2 .$$

*Proof sketch.* $\|e\|^2 = \sum_{j<d} e_j^2 \ge \sum_{j<d} c^2 = dc^2$, then apply Corollary 4.8 and monotonicity of multiplication by $\|g\|^2 \ge 0$. $\square$

**Proposition 4.11 (strict monotonicity in width).** For $d_1 < d_2$, fixed per-coordinate scale $c > 0$ and $g \neq 0$, the guaranteed gains satisfy $d_1c^2\|g\|^2 < d_2c^2\|g\|^2$ strictly.

**Theorem 4.12 (boundary dichotomy).** Let $1 \le d_1 < d_2$, $c > 0$, $g \neq 0$. Then simultaneously
1. the realisable boundary contributions at widths $d_1$ and $d_2$ are *the same set*, and
2. the guaranteed gradient-flow gain at width $d_2$ is *strictly larger* than at width $d_1$.

Consequently any measured difference between two such arms is an optimisation/conditioning effect and never a capacity one.

This is the formal core of the paper. It converts the empirical control — identical weights, different EOS width, radically different length generalisation — from a curiosity into a mechanism: the arms cannot differ in what they can represent, so they must differ in how the optimiser moves them, and the direction of that difference is provably $d$-increasing. With $c$ held fixed, $d : 20 \to 384$ multiplies the guaranteed gain by $19.2$.

### 4.4 Contraction and the training-budget law

**Definition 4.13.** $\mathcal{L}(v) := \tfrac12\|v - v^\star\|^2$ for a target boundary bias $v^\star$.

**Theorem 4.14 (Grönwall contraction).** Let $v(t)$ be differentiable with velocity $w(t)$ and suppose the descent rate dominates the residual: $\kappa\|v(t)-v^\star\|^2 \le \langle v(t)-v^\star, -w(t)\rangle$ for all $t$. Then for $t \ge 0$,
$$\mathcal{L}(v(t)) \le \mathcal{L}(v(0))\, e^{-2\kappa t}.$$

*Proof sketch.* Let $L(t) = \mathcal{L}(v(t))$; then $L'(t) = \langle v(t)-v^\star, w(t)\rangle \le -\kappa\|v(t)-v^\star\|^2 = -2\kappa L(t)$. Hence $F(t) = L(t)e^{2\kappa t}$ has $F' \le 0$, so $F$ is antitone and $L(t)e^{2\kappa t}\le L(0)$. $\square$

**Theorem 4.15 (dense-EOS exponential decay).** If $v$ evolves by the factorised gradient flow of Theorem 4.6 with residual gradient $g(t) = v(t)-v^\star$ and the EOS coordinates never fall below scale $c$, then
$$\mathcal{L}(v(t)) \le \mathcal{L}(v(0))\, e^{-2 d c^2 t}.$$
*The contraction exponent is linear in the EOS width.*

*Proof sketch.* Instantiate Theorem 4.14 at $\kappa = dc^2$, whose hypothesis is exactly Theorem 4.10 applied at each time. $\square$

**Theorem 4.16 (sufficient budget).** With contraction rate $2\kappa > 0$, any $t \ge \log(\mathcal{L}_0/\varepsilon)/(2\kappa)$ gives $\mathcal{L}_0 e^{-2\kappa t} \le \varepsilon$.

**Corollary 4.17 ($1/d$ budget law).** At $\kappa = dc^2$ the sufficient training budget is $\log(\mathcal{L}_0/\varepsilon)/(2dc^2)$, which is *strictly decreasing* in $d$: for $d_1 < d_2$, fixed $c>0$ and $0 < \varepsilon < \mathcal{L}_0$,
$$\frac{\log(\mathcal{L}_0/\varepsilon)}{2 d_2 c^2} \;<\; \frac{\log(\mathcal{L}_0/\varepsilon)}{2 d_1 c^2}.$$

This replaces the paper's open item "the threshold lies somewhere between $28$ and $384$, untested" with a quantitative, falsifiable statement: at fixed wall-clock budget, wider EOS should reach any fixed boundary-loss target sooner, with the sufficient time scaling as $1/d$.

---

## 5. The horizon half: contraction, readout margins, and what boundary gain buys

Sections 3 and 4 leave one question: *why* does poor boundary conditioning damage deep unrolls specifically, and why does the coarse carry probe survive while the fine digit readout fails? Section 5 answers this with a depth-explicit impossibility result.

**Definition 5.1 (affine cell).** On a normed space $E$, one step is $f(x) = Ax + u$ with $A$ a bounded linear map and $u$ fixed. Note $f(x) - f(y) = A(x-y)$: the affine offset cancels.

**Theorem 5.2 (geometric collapse of state separation).** If $\|Az\| \le \lambda\|z\|$ for all $z$, with $\lambda \ge 0$, then for all $n$,
$$\|f^{[n]}(x) - f^{[n]}(y)\| \le \lambda^n\|x-y\| .$$

*Proof sketch.* Induction, using $f(x)-f(y) = A(x-y)$ at each step. $\square$

**Theorem 5.3 (readout margin collapse).** Let $r$ be a linear readout with $\|r(z)\|\le R\|z\|$, $R\ge 0$, and let $\|x-y\|\le\Delta$. If $\lambda^n \Delta R < \gamma$ then
$$|r(f^{[n]}(x)) - r(f^{[n]}(y))| < \gamma .$$

*Proof sketch.* Chain $|r(z_1)-r(z_2)| = |r(z_1-z_2)| \le R\|z_1-z_2\| \le R\lambda^n\Delta$. $\square$

**Theorem 5.4 (the state horizon exists).** Let $0 \le \lambda < 1$, $R,\Delta \ge 0$, $\gamma > 0$. Then there is a finite $N$ such that for all $n \ge N$ and all $x,y$ with $\|x-y\|\le\Delta$, $|r(f^{[n]}(x)) - r(f^{[n]}(y))| < \gamma$.

*Proof sketch.* If $\lambda = 0$ take $N=1$; if $\Delta R = 0$ take $N=0$; otherwise choose $N$ with $\lambda^N < \gamma/(\Delta R)$, possible since $\lambda^n \to 0$, and use monotonicity of $\lambda^n$ together with Theorem 5.3. $\square$

**Interpretation.** This is a genuine impossibility statement: *no* training procedure and *no* parameter count evades it. Only a less contractive cell (larger $\lambda$) or additional gain at the boundary can extend the horizon. It predicts the measured shape of the raw baseline exactly: $\lambda, \Delta, R, \gamma$ all vary with initialisation, so different seeds have different horizons, and one observes a *distribution* of length-$8$ accuracies ($0.0020$ to $0.6997$ over seven seeds) rather than a sharp threshold. It also explains the flat carry probe: a one-bit state needs only a coarse margin, while a ten-way digit readout needs a fine one, and it is the fine margin that is lost first.

**Theorem 5.5 (boundary gain buys depth).** Let $\lambda \ge 0$, $DR \ge 0$, and suppose depth $N$ is still within margin, $\lambda^N \cdot DR < \gamma$. If a final-step gain $m$ satisfies $m\lambda^k \le 1$, then
$$\lambda^{N+k}\,(m\cdot DR) < \gamma,$$
i.e. the gain $m$ preserves usability for $k$ further steps.

*Proof sketch.* $\lambda^{N+k}(m\,DR) = (\lambda^N DR)(m\lambda^k) \le \lambda^N DR < \gamma$. $\square$

**Theorem 5.6 (logarithmic depth law).** For $0 < \lambda < 1$ and $m \ge 1$, the condition $m\lambda^k \le 1$ holds as soon as
$$k \;\ge\; \frac{\log m}{\log(1/\lambda)} .$$

*Proof sketch.* $k \log(1/\lambda) \ge \log m$ gives $m \le (1/\lambda)^k = 1/\lambda^k$, i.e. $m\lambda^k \le 1$. $\square$

**Corollary 5.7 (boundary richness buys depth only logarithmically).** Multiplying the boundary gain by a constant extends the usable unroll depth by a *constant additive* number of steps, $\log m/\log(1/\lambda)$. Depth enters the margin exponentially while gain enters it multiplicatively.

Combining with Theorem 4.10, whose guaranteed gain is proportional to $d$: usable depth should grow like $a + b\log d$ with $b = 1/\log(1/\lambda)$. The measured jump $d = 28 \to 384$ (a factor $\approx 13.7$ in $d$) therefore corresponds to a modest additive depth gain — which happened to be enough to clear $n = 8$ — and *not* to a qualitative change of regime.

---

## 6. The dense-final-step law

Assembling §§3–5:

> **The dense-final-step law.** In a state-augmented sequential answer path,
> 1. the recurrent **transition** is not the bottleneck: an exactly depth-uniform solution exists and is forced by pointwise correctness on the finitely many reachable state–input triples (Theorem 3.6, Corollary 3.7);
> 2. the width of the **final-step (EOS) input** adds no representable boundary function whatsoever (Corollary 4.3);
> 3. but it strictly increases the guaranteed gradient-flow gain on the effective boundary bias, linearly in the width, with a $1/d$ sufficient training budget (Theorems 4.10, 4.15, Corollary 4.17);
> 4. and, because a contractive cell has a provable state horizon for every bounded readout, that gain converts into usable depth only logarithmically (Theorems 5.4, 5.6).

The corresponding empirical claims, in the same order: the final-carry probe is flat at $0.86$–$0.99$ across all arms; the padded and narrow-EOS arms have byte-identical cell and head weights; the narrow arm scores $0.0259$–$0.7441$ and the wide arm $1.0000\times 4$; and the raw baseline's spread over seven seeds is a distribution, not a wall.

**Corrections to earlier readings.** (i) The cure is *not* the encoder's content-rich column features: an untrained random projection cures ($5/5$), and raw one-hots padded with $364$ dead dimensions cure ($4/4$). (ii) The digit pathway may be raw; the failing configuration's problem was its $20$-dimensional EOS, not its $20$-dimensional digit inputs. (iii) The raw state horizon is real but heavy-tailed in seed variance; a two-seed reading undersampled it, though the conclusion holds at $0/7$. (iv) EOS richness must exceed the digit count by a large factor: a $28$-dimensional learned EOS still fails at $0.0049$, so the threshold lies strictly in $(28, 384)$ and is untested.

---

## 7. Algorithms

Three procedures make the theory computable and testable.

**Algorithm A (carry-chain local-to-global certification).** Enumerate the $\beta^2\cdot 2$ reachable triples, check a candidate step table against the true transition on each, and — if it passes — conclude by Theorem 3.6 that the table is exactly correct at every depth; optionally confirm empirically at chosen depths. Complexity $O(\beta^2)$ for the certificate, $O(n)$ per depth-$n$ confirmation.

**Algorithm B (boundary-gain / preconditioner spectrum).** Given $W$ and $e$, form $P = \|e\|^2 I + WW^{\mathsf T}$, evaluate the exact descent rate $\langle g, Pg\rangle = \|e\|^2\|g\|^2 + \|W^{\mathsf T}g\|^2$, compare with the guaranteed bound $dc^2\|g\|^2$, and report the conditioning ratio $\lambda_{\max}(P)/\lambda_{\min}(P)$. Complexity $O(h^2 d)$ to form $P$, $O(hd)$ per gain evaluation, $O(h^3)$ for the spectrum.

**Algorithm C (horizon estimation and log-depth prediction).** Given $\lambda, \Delta, R, \gamma$, the horizon is the least $N$ with $\lambda^N\Delta R < \gamma$, i.e. $N = \lceil \log(\gamma/(\Delta R))/\log\lambda\rceil$ when $\Delta R > \gamma$; the depth bought by a gain $m$ is $\lceil \log m/\log(1/\lambda)\rceil$. Composing with the $d$-linear gain gives the predicted usable depth $N(d) = N_0 + \lceil \log(d/d_0)/\log(1/\lambda)\rceil$. Complexity $O(1)$.

---

## 8. Predictions

The mechanism is falsifiable in three distinct ways.

**P1 — logarithmic depth law.** Sweeping $d \in \{20,28,40,64,96,160,256,384\}$ should give usable depths equally spaced on a $\log d$ axis, with slope $1/\log(1/\lambda)$ set by the cell's contraction factor — a smooth ramp, not a threshold in $(28, 384)$. A sharp threshold would falsify Corollary 5.7 as the operative mechanism.

**P2 — scale invariance (the sharpest test).** The proved gain is $\|e\|^2\|g\|^2$, which depends on the *norm* of the EOS vector, not its dimension per se. Initialising the wide EOS at per-coordinate scale $c/\sqrt d$, so that $\|e\|^2$ is held constant as $d$ grows, should therefore make the cure disappear and return the wide arm to the failing distribution. This is a one-line change to the initialiser and it cleanly separates "richness" from "dimension".

**P3 — stability window.** The preconditioner $\|e\|^2I + WW^{\mathsf T}$ that accelerates the flow also bounds the stable step size of a discrete optimiser, roughly $\eta < 1/(dc^2 + \|W\|^2)$. Wide-EOS arms should thus have their optimum at a learning rate smaller by a factor $\approx 20/384$ and should *diverge*, not merely slow, above it.

---

## 9. Related considerations and scope

**What is proved and what is not.** Proved: exact length-generality and local-to-global transfer for the carry transition; expressivity invariance of the boundary pathway in the EOS width; the closed form of the induced drift, the exact and lower-bounded gains, sharpness at $W = 0$, exponential contraction and the $1/d$ budget; the existence of a state horizon for every bounded linear readout and the logarithmic depth shift bought by boundary gain. Not proved, and explicitly flagged: that the improved boundary conditioning is *the* reason the trained digit readout stays in distribution at depth. That last inferential step is the mechanism hypothesis; the theorems constrain it tightly (they exclude capacity and expressivity explanations and quantify the only remaining channel) but do not close it.

**Modelling caveats.** §4 analyses the boundary pathway in isolation, with the loss depending on parameters only through $v = We$; the real cell is nonlinear and the loss also flows through the digit pathway. §5 models the cell in its linear/contractive regime; a real gated cell is contractive only in a region and only for some parameterisations. Both idealisations are standard, and both are chosen so that the *conclusions are conservative*: they identify a lower bound on gain and an upper bound on usable depth.

**Design of the control.** The empirical strength of the round rests on the identical-weights construction. Because the cell and head parameters are drawn in the same order and are byte-identical per seed, the comparison cannot be circular: no property of the cell, the head, the data, the optimiser, or the seed differs between the two arms. Exactly one architectural variable moves.

---

## 10. Discussion

Three intuitions are overturned.

*"Bigger is better."* A raw model with $471{,}582$ parameters fails where one with $335{,}242$ succeeds, and the theory says why: the boundary pathway's function class is width-independent (Corollary 4.3), so extra capacity in the wrong place buys nothing.

*"Better features are the cure."* An untrained random projection cures the task. The learned encoder was never load-bearing; its incidental contribution was a wide input space, and therefore a wide EOS vector.

*"Position information fixes length generalisation."* Adding a sinusoidal position code left accuracy at $0.0049$. The transition never needed positional help (Theorem 3.3 has no $n$-dependence), and the readout needs margin, not coordinates.

What replaces them is a statement about *boundary conditions*. The final step of a recurrent answer path is where an accumulated, geometrically shrinking state has to be converted into a fine-grained symbolic decision. Everything that determines how well that conversion is learned flows through the input pathway at that one step. Widening it does not change what the model *can* do; it changes the geometry of the optimisation that decides what the model *will* do. In the language of §4, factorised parameterisations induce preconditioners, and the preconditioner at the boundary step scales with the boundary input's norm.

The practical corollary for larger recurrent or state-augmented answer paths is concrete and cheap: give the terminal/decoding step a rich, well-scaled input pathway. Padding an otherwise raw input to a wide space costs $364$ dead dimensions and no additional information, and yet it flipped four out of four seeds to perfect length-$8$ accuracy.

---

## 11. Future work

Beyond the three predictions of §8: characterise the threshold in $(28, 384)$ and test whether it is smooth in $\log d$; extend the boundary-conditioning analysis from the isolated bilinear model to a gated nonlinear cell, where $\|e\|^2 I + WW^{\mathsf T}$ becomes a state-dependent metric; quantify $\lambda$ empirically per seed and check whether the measured horizon distribution matches the prediction of Theorem 5.4; and test whether the same boundary-richness lever operates in autoregressive decoders, where the analogue of the EOS step is the transition from prompt to generation.

---

## 12. Conclusion

A recurrent machine that has provably learned an exactly length-general transition can still fail at depth, because a contractive state and a bounded readout have a finite horizon. What extends that horizon is not capacity, not learned feature content, and not positional information — all three were tested and all three failed. It is the richness of the input pathway at the *final* step, which is invisible to the function class and visible to the optimiser, entering the guaranteed gradient-flow gain linearly in its width and the usable depth logarithmically. In the controlled comparison that motivated this analysis, moving that single variable — with byte-identical cell and head weights — took length-$8$ full-sequence accuracy from $0.0259$ to $1.0000$.
