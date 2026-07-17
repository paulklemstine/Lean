# Quantum-Surreal Measurement: Label Invariance, Standard-Part Observation, and the Equal-Amplitude Obstruction

## Abstract

We study finite quantum states whose orthogonal basis vectors are indexed by surreal numbers while their amplitudes lie in a non-Archimedean ordered field equipped with a standard-part map. The central structural distinction is that surreal numbers label outcomes, whereas normalized squared amplitudes determine probability. We define exact Born weights and real observed probabilities and prove an equal-amplitude theorem: two distinct surreal-labelled branches with a common nonzero amplitude each have exact and observed probability $1/2$, independent of whether either label is infinitesimal. Hence an infinitesimal label alone cannot suppress an outcome. We contrast this obstruction with genuine infinitesimal-amplitude collapse, in which a branch of infinitesimal normalized weight has standard-part probability zero while finite normalization is preserved. A finite lexicographic probability model exhibits the same signature: total standard mass is one although every purely infinitesimal atom has standard mass zero. We give algorithms for finite measurement, visibility classification, and numerical approximation, identify essential hypotheses, and explain the boundary at which branchwise standard part may fail to commute with unlimited summation.

## 1. Introduction

Conway’s surreal numbers form an ordered field containing the real numbers together with infinitesimal and infinite elements. Their breadth makes them natural candidates for labelling an enlarged spectrum of possible outcomes. A finite quantum-surreal state has the schematic form

$$
|\psi\rangle=\sum_{i=1}^{m}\alpha_i|s_i\rangle,
$$

where the labels $s_i$ are surreal numbers and the amplitudes $\alpha_i$ belong to a scalar field suitable for non-Archimedean probability.

A basic interpretive issue immediately arises. If $s_i$ is infinitesimal, should the branch $|s_i\rangle$ have infinitesimal probability? The answer depends on whether the infinitesimal occurs as an outcome label or as amplitude mass. In the Born rule, labels select orthogonal coordinates; probabilities are computed from coefficients. Multiplying probability by the numerical magnitude of a label would introduce a different, label-dependent measurement law.

This paper isolates the finite mathematics needed to make that distinction precise. The principal result is an obstruction to label-based suppression. For distinct $s$ and $t$ and nonzero amplitude $a$, the state

$$
a|s\rangle+a|t\rangle
$$

assigns probability $1/2$ to both outcomes. This remains true when $t$ is a nonzero infinitesimal surreal. By contrast, if a branch’s normalized squared amplitude is infinitesimal, its observed probability under standard part is zero.

The results are deliberately finite. At finite support, additivity and normalization interact cleanly with standard part. Unlimited collections introduce a different phenomenon: every branch may have zero standard probability while the exact total mass remains one. This potential failure marks the boundary between the established finite theory and an infinite-dimensional extension.

## 2. Mathematical setting

### 2.1 Surreal-labelled basis states

Let $S$ be a finite set of distinct surreal numbers. For each $s\in S$, let $|s\rangle$ denote a basis vector, with inner products

$$
\langle s|t\rangle=
\begin{cases}
1,&s=t,\\
0,&s\ne t.
\end{cases}
$$

The arithmetic order or magnitude of a label does not enter this orthogonality rule. A label identifies a coordinate. In particular, $|0\rangle$ and $|\varepsilon\rangle$ are distinct orthogonal vectors whenever $\varepsilon\ne0$, even if $\varepsilon$ is infinitesimal.

### 2.2 Non-Archimedean amplitudes

Let $K$ be an ordered non-Archimedean field containing $\mathbb R$. An element $x\in K$ is **infinitesimal** if

$$
|x|<\frac1n
$$

for every positive integer $n$. It is **finite** if $|x|<n$ for some positive integer $n$, and **appreciable** if it is finite but not infinitesimal in magnitude. For the real-amplitude model used below, the squared magnitude is $|a|^2=a^2$. A complex extension would replace this by $\overline a a$.

Assume every finite $x\in K$ has a real **standard part**, denoted $\operatorname{st}(x)$, characterized by

$$
x-\operatorname{st}(x)\text{ is infinitesimal}.
$$

We use the familiar consequences

$$
\operatorname{st}(r)=r\quad(r\in\mathbb R),
\qquad
\operatorname{st}(\delta)=0\quad(\delta\text{ infinitesimal}),
$$

and finite additivity whenever all terms involved lie in the domain of standard part.

### 2.3 States, norm, and measurement

A finite state is a finitely supported function $\psi:S\to K$, represented as

$$
|\psi\rangle=\sum_{s\in S}\psi(s)|s\rangle.
$$

Its squared norm is

$$
\|\psi\|^2=\sum_{s\in S}\psi(s)^2.
$$

For a nonzero state, define the **exact Born weight** of outcome $s$ by

$$
W_\psi(s)=\frac{\psi(s)^2}{\|\psi\|^2}.
$$

When $W_\psi(s)$ is finite, define the **observed probability** by

$$
P_\psi(s)=\operatorname{st}(W_\psi(s)).
$$

The distinction between $s$ and $\psi(s)$ is fundamental. The first is an index in the outcome space; the second is a scalar coefficient. Only the coefficient enters $W_\psi(s)$.

### 2.4 Coincident labels

If two written terms use the same label, they are not orthogonal branches. They must first be combined:

$$
a|s\rangle+b|s\rangle=(a+b)|s\rangle.
$$

The resulting contribution to squared norm is $(a+b)^2$, not $a^2+b^2$. Consequently, distinctness of labels is an essential hypothesis in the two-branch theorems below.

## 3. Equal amplitudes and label invariance

### Lemma 1 (Squared norm of an equal-amplitude pair)

Let $s$ and $t$ be distinct surreal numbers and let $a\in K$. For

$$
|\psi\rangle=a|s\rangle+a|t\rangle,
$$

one has

$$
\|\psi\|^2=2a^2.
$$

**Proof sketch.** Expand the inner product of $|\psi\rangle$ with itself. The two diagonal terms each contribute $a^2$. The cross terms contain $\langle s|t\rangle$ and $\langle t|s\rangle$, both of which vanish because $s\ne t$. Their sum is therefore $2a^2$. $\square$

### Theorem 1 (Exact equal-amplitude law)

Let $s\ne t$ be surreal labels and let $a\ne0$. In the state

$$
|\psi\rangle=a|s\rangle+a|t\rangle,
$$

the exact Born weights satisfy

$$
W_\psi(s)=W_\psi(t)=\frac12.
$$

**Proof sketch.** At either label the squared coefficient is $a^2$. Lemma 1 gives total squared norm $2a^2$. Since $a\ne0$, cancellation is valid:

$$
W_\psi(s)=\frac{a^2}{2a^2}=\frac12.
$$

The same calculation applies to $t$. $\square$

The nonzero hypothesis cannot be removed: when $a=0$, the state has zero norm and normalized Born weights are undefined.

### Theorem 2 (Observed equal-amplitude law)

Under the hypotheses of Theorem 1,

$$
P_\psi(s)=P_\psi(t)=\frac12.
$$

**Proof sketch.** The exact weight $1/2$ is an embedded real number, so the standard-part map fixes it. Apply standard part to both identities in Theorem 1. $\square$

### Corollary 1 (Equal-amplitude obstruction for an infinitesimal label)

Let $\varepsilon$ be a nonzero infinitesimal surreal label. The state

$$
|\psi\rangle=\frac1{\sqrt2}|0\rangle+\frac1{\sqrt2}|\varepsilon\rangle
$$

has

$$
P_\psi(0)=P_\psi(\varepsilon)=\frac12.
$$

Thus an infinitesimal label does not make a branch unobservable when that branch carries an appreciable amplitude equal to the other branch’s amplitude.

**Proof sketch.** The labels $0$ and $\varepsilon$ are distinct, and their common amplitude is nonzero. Theorem 2 applies directly. The infinitesimal order of $\varepsilon$ is irrelevant to the cancellation. $\square$

This corollary corrects a plausible but invalid computation in which the second weight is taken to be $\tfrac12\varepsilon^2$. Such a factor would arise only if the coefficient of $|\varepsilon\rangle$ itself contained $\varepsilon$. The label inside a ket is not an amplitude multiplier.

### Corollary 2 (Swap invariance)

For distinct labels $s,t$ and common nonzero amplitude $a$, exchanging $s$ and $t$ preserves the ordered pair of probability values up to the same exchange. In particular, the multiset of observed probabilities remains $\{1/2,1/2\}$.

**Proof sketch.** Both branches satisfy the identical coefficient calculation of Theorem 2. Swapping labels changes neither squared norm nor coefficient magnitudes. $\square$

### Proposition 1 (Common-scale invariance)

Let $c\ne0$ and let $|\phi\rangle=c|\psi\rangle$ for a nonzero finite state. Whenever the relevant quotients are defined,

$$
W_\phi(s)=W_\psi(s)
$$

for every label $s$.

**Proof sketch.** Every numerator gains a factor $c^2$, and the squared norm also gains $c^2$. Cancellation yields the original weight. Hence even a common infinitesimal scale does not by itself make all branches observationally vanish after normalization. $\square$

## 4. Genuine infinitesimal-amplitude collapse

The equal-amplitude obstruction does not say that infinitesimal probabilities are impossible. It identifies their correct source.

### Definition 1 (Visibility)

A branch $s$ of a normalized finite state is **observationally visible** if

$$
P_\psi(s)>0.
$$

It is **standard-part invisible** if $P_\psi(s)=0$. A nonzero exact branch may be standard-part invisible.

### Theorem 3 (Infinitesimal-weight collapse)

Let $|\psi\rangle$ be a nonzero finite state and suppose the exact Born weight $W_\psi(s)$ is a nonnegative infinitesimal. Then

$$
P_\psi(s)=0.
$$

**Proof sketch.** By definition, $P_\psi(s)=\operatorname{st}(W_\psi(s))$. The standard part of every finite infinitesimal is zero. Nonnegativity ensures the result is interpreted as a probability rather than a signed residue. $\square$

### Theorem 4 (Two-branch epsilon test and observed normalization)

Let $\eta$ be a positive infinitesimal and consider a normalized two-branch state whose exact weights are

$$
W_\psi(0)=1-\eta,
\qquad
W_\psi(1)=\eta.
$$

Then

$$
P_\psi(0)=1,
\qquad
P_\psi(1)=0,
\qquad
P_\psi(0)+P_\psi(1)=1.
$$

**Proof sketch.** Since $\eta$ is infinitesimal, $\operatorname{st}(\eta)=0$. Also $1-\eta$ is infinitely close to $1$, so $\operatorname{st}(1-\eta)=1$. Their sum is therefore one. The exact normalization $(1-\eta)+\eta=1$ is retained after observation. $\square$

A state realizing these weights may be written with amplitudes $\sqrt{1-\eta}$ and $\sqrt\eta$ in a non-Archimedean field where the relevant square roots exist. Here the second amplitude, rather than its label, creates the infinitesimal probability.

### Proposition 2 (Finite observed normalization)

Suppose a normalized state has finitely many nonnegative finite exact weights $W_1,\ldots,W_m$ satisfying

$$
\sum_{i=1}^{m}W_i=1,
$$

and standard part is additive on these finite values. Then

$$
\sum_{i=1}^{m}\operatorname{st}(W_i)=1.
$$

**Proof sketch.** Finite additivity permits standard part to pass through the finite sum:

$$
\sum_i\operatorname{st}(W_i)
=\operatorname{st}\!\left(\sum_iW_i\right)
=\operatorname{st}(1)=1.
$$

The finiteness of the index set is essential to this argument. $\square$

## 5. A discrete standard-part model

A second model shows that infinitesimal collapse is not tied to Hilbert-space notation.

### Definition 2 (Lexicographic infinitesimal weight)

A lexicographic weight is a pair $(r,k)$ with ordinary component $r\in\mathbb R$ and infinitesimal component $k$ in an ordered additive system. Addition is componentwise:

$$
(r,k)+(r',k')=(r+r',k+k').
$$

Its standard part is

$$
\operatorname{st}(r,k)=r.
$$

The pair $(0,1)$ represents a positive purely infinitesimal atom, while $(1,k)$ has standard mass one for every finite infinitesimal component $k$.

Consider a finite sample space consisting of a distinguished residual atom together with finitely many visible infinitesimal atoms. Assign each visible atom a weight of the form $(0,k_i)$ and choose the residual atom so that the whole space has ordinary coordinate one.

### Theorem 5 (Finite discrete collapse)

In the finite lexicographic model just described, the standard part of the mass of the entire sample space is $1$, whereas the standard part of every individual purely infinitesimal atom is $0$.

**Proof sketch.** Componentwise addition makes the ordinary coordinate of the total mass equal to one by construction, so its standard part is one. Every purely infinitesimal atom has ordinary coordinate zero, so its standard part is zero. $\square$

### Corollary 3 (Continuous–discrete collapse bridge)

The two-branch epsilon state of Theorem 4 and the finite lexicographic model of Theorem 5 have the same standard-part signature: total observed mass equals one, while each designated purely infinitesimal component has observed mass zero.

**Proof sketch.** Theorem 4 supplies the signature for normalized amplitude weights; Theorem 5 supplies it for lexicographic atom weights. The scalar representations differ, but standard part retains the ordinary coordinate and erases the infinitesimal coordinate in both cases. $\square$

The bridge is an observational equivalence, not an assertion that the two scalar systems are identical. It identifies the algebraic behavior that a broader standard-part probability theory should preserve.

## 6. Algorithms

### 6.1 Finite quantum-surreal measurement

For a list of labelled amplitudes, the measurement algorithm proceeds as follows.

**Input:** pairs $(s_i,\alpha_i)$ with finitely many labels and scalar amplitudes.

**Output:** exact normalized weights and real observed probabilities.

1. Group equal labels and sum their amplitudes.
2. Remove labels whose combined amplitude is zero.
3. Compute $q_s=|\alpha_s|^2$ for each remaining label.
4. Compute $Z=\sum_sq_s$ and reject the zero state if $Z=0$.
5. Set $W_s=q_s/Z$.
6. Verify that each $W_s$ is finite and lies in the domain of standard part.
7. Return $P_s=\operatorname{st}(W_s)$.

For $m$ branches, grouping costs expected $O(m)$ time with hashing or $O(m\log m)$ with comparison-based sorting. The remaining arithmetic is $O(m)$. The algorithm uses $O(m)$ storage.

The grouping step is mathematically necessary. Treating duplicate labels as orthogonal would replace coherent addition by an incoherent sum and generally produce incorrect probabilities.

### 6.2 Visibility classification

Given already normalized finite exact weights, classify branch $s$ as visible precisely when $\operatorname{st}(W_s)>0$. In numerical work, exact infinitesimals can be represented symbolically as truncated series

$$
W_s=c_0+c_1\epsilon+\cdots+c_d\epsilon^d,
$$

where standard part returns $c_0$. The classification then takes $O(d)$ time per branch to inspect or normalize the representation, and $O(1)$ time if coefficients are stored canonically with direct access to $c_0$.

### 6.3 Scale sweep as a numerical diagnostic

Ordinary floating-point arithmetic has no genuine infinitesimals, but a parameter sweep illustrates the limiting standard-part behavior. For weights proportional to $1$ and $\delta^2$, compute

$$
P_1(\delta)=\frac{1}{1+\delta^2},
\qquad
P_2(\delta)=\frac{\delta^2}{1+\delta^2}.
$$

As $\delta\to0$, these approach $1$ and $0$. In contrast, for equal amplitudes $\delta$ and $\delta$ the normalized weights remain exactly $1/2$ for every nonzero $\delta$. Comparing these sweeps numerically separates relative suppression from a common global scale.

## 7. Applications and interpretation

### 7.1 Outcome labels versus spectral weights

In spectral language, eigenvalues label eigenspaces while projections and state amplitudes determine outcome probabilities. The infinitesimal size of an eigenvalue does not force its spectral projection to have infinitesimal expectation. The equal-amplitude theorem is the two-dimensional instance of this general separation.

This guides the formulation of a future non-Archimedean spectral theorem. Orthogonality, normalization, and projection weights should be governed by the scalar field and inner product. Surreal order on eigenvalue labels describes the spectrum but should not be inserted into the Born weight unless a different observable model explicitly demands it.

### 7.2 Resolution and coarse graining

Standard part acts as an idealized observation map. Exact weights distinguish $1$ from $1-\eta$ and $0$ from $\eta$; real observed probabilities do not. This resembles coarse graining, where sub-resolution structure survives in a microscopic model but is absent from recorded frequencies.

A zero standard probability should therefore not automatically be interpreted as logical impossibility. It can represent a nonzero exact event lying below the Archimedean resolution of the observed measure. The framework distinguishes three statements:

1. the branch is absent, meaning its exact amplitude is zero;
2. the branch is present with infinitesimal normalized weight;
3. the branch’s label is an infinitesimal number.

Only the second statement directly implies standard-part invisibility.

### 7.3 Relabelling tests for proposed models

Any proposed measurement rule can be tested by permuting labels while keeping coefficient data fixed. A Born-type rule must transport probabilities with the branches rather than alter them according to label magnitude. The equal-amplitude obstruction gives an especially sharp test: if two equal nonzero coefficients receive unequal probabilities solely because one label is infinitesimal, the rule is not the standard Born normalization defined here.

### 7.4 Finite probabilistic semantics

Proposition 2 and Theorem 5 suggest a general construction. Start with a finite probability measure valued in an ordered non-Archimedean field, require all event masses to be finite, and apply standard part to obtain a real measure. Finite additivity follows from additivity of standard part on finite sums. Determining the most general hypotheses under which this assignment respects maps of finite probability spaces is a natural categorical question.

## 8. Limitations and failure boundaries

The present theory concerns finite support and a standard-part map defined on all weights in use. Several limitations should be explicit.

First, it does not establish a spectral theorem for arbitrary operators. Such a theorem requires a developed non-Archimedean inner-product geometry, conditions ensuring eigenvalue splitting, and an appropriate notion of completeness.

Second, complex amplitudes require an involution and the positive quantity $\overline\alpha\alpha$ in place of $\alpha^2$. The equal-amplitude cancellation should persist, but positivity and standard-part compatibility must be stated for the chosen scalar field.

Third, standard part is generally partial: infinite elements have no finite real shadow. The observed-probability definition therefore requires normalized weights to be finite.

Fourth, finite additivity does not automatically extend to unlimited sums. Consider an internally normalized hyperfinite family $(W_i)$ in which every $W_i$ is infinitesimal but

$$
\sum_iW_i=1.
$$

Branchwise standard part gives $\operatorname{st}(W_i)=0$ for each $i$, while standard part of the exact total is one. Thus

$$
\sum_i\operatorname{st}(W_i)
e
\operatorname{st}\!\left(\sum_iW_i\right)
$$

if the left side is interpreted as an unrestricted termwise operation. A tightness, domination, or uniform summability hypothesis is needed before interchanging standard part with an infinite or hyperfinite sum.

Finally, the results do not claim that surreal numbers themselves provide the amplitude field used here. The established framework uses surreal values as labels and a standard-part-compatible non-Archimedean field for amplitudes. Constructing a unified scalar and spectral geometry remains a separate task.

## 9. Future research

Four directions emerge.

**Finite-dimensional spectral decomposition.** One may seek an orthogonal eigenbasis theorem for self-adjoint endomorphisms over a real-closed, standard-part-compatible non-Archimedean field when the characteristic polynomial splits. The key question is whether appreciable spectral projections pass under standard part to mutually orthogonal real projections.

**A standard-part functor.** For finite probability spaces valued in a non-Archimedean field, one may characterize exactly when standard part produces an ordinary real probability space and respects probability-preserving maps. The hyperreal-amplitude and lexicographic models provide independent test cases.

**A visibility criterion.** The finite results suggest that observed support should consist exactly of branches whose normalized squared amplitudes have positive standard part. One expects invariance under permutations of labels and multiplication of all amplitudes by a common nonzero finite scalar.

**The infinite-dimensional boundary.** Hyperfinite normalized states may carry unit total mass across individually invisible branches. Identifying the precise tightness condition that permits standard part to commute with summation is necessary before an infinite-dimensional measurement theory can be soundly formulated.

## 10. Methodological consequences

The finite results supply two diagnostic questions for any extension. First, does the proposed probability depend only on normalized coefficient mass and orthogonality data, or does it accidentally depend on the numerical spelling of an outcome? Second, does the observation map preserve finite normalization while distinguishing exact presence from real-valued visibility? The equal-amplitude state tests the first question, and the epsilon-weight state tests the second. Together they form a minimal benchmark: a satisfactory model must assign half probability to each equally weighted distinct branch, erase a purely infinitesimal normalized weight under standard part, and preserve total observed mass in finite systems.

## 11. Conclusion

Quantum-surreal measurement requires a disciplined separation between coordinates and coefficients. Surreal labels enlarge the outcome space; amplitudes allocate mass across that space; standard part converts finite non-Archimedean weights into ordinary real observations.

For two distinct labels with equal nonzero amplitude, exact normalization gives $1/2$ on each branch, and standard part preserves those values. An infinitesimal label is therefore not intrinsically unobservable. Genuine disappearance occurs when a branch’s normalized squared amplitude is infinitesimal. In finite systems this collapse is compatible with total observed mass one, and an analogous lexicographic model exhibits the same behavior.

These results replace a label-dependent intuition with an amplitude-based law. They also locate the next mathematical obstacle: not the finite two-branch calculation, but the interaction of standard part with spectral structure and unlimited summation.
