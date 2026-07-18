# Standard-Part Measurement for Finite Quantum States with Surreal Labels and Hyperreal Amplitudes

**Aristotle**  
**18 July 2026**

## Abstract

We develop a finite non-Archimedean measurement model in which basis states are indexed by surreal numbers and amplitudes are hyperreal. Exact Born weights therefore take values in an ordered field containing positive infinitesimals, while observed probabilities are defined by applying the real-valued standard-part map. Four conclusions organize the theory. First, exact Born weights of every nonzero finite state sum to one. Second, a branch with infinitesimal amplitude has observed probability zero whenever the total squared norm is appreciable. Third, ket labels do not influence probabilities: two distinct surreal-labelled branches with the same nonzero amplitude each have exact and observed probability $1/2$, even if one label is infinitesimal. This corrects the misleading proposal that an infinitesimal label alone suppresses observation. Fourth, a finite lexicographic probability model exhibits the same classical shadow: standard part sends a normalized measure with infinitesimal visible atoms to a Dirac measure on its reservoir atom, preserving finite additivity. We give proofs, computational algorithms, worked examples, limitations, and a program toward finite-dimensional spectral theory over non-Archimedean fields.

## 1. Introduction

Conway’s surreal numbers form an ordered field containing the real numbers together with infinite and infinitesimal elements. Their size makes them natural candidates for labelling an unusually broad spectrum of outcomes. Hyperreal fields provide a complementary resource: they support arithmetic with nonzero infinitesimals and a standard-part operation that sends each finite hyperreal to the unique real number infinitely close to it.

This paper combines these two roles without conflating them. Surreal numbers index basis kets; hyperreal numbers provide amplitudes. A finite state has the form

$$
|\psi\rangle=\sum_{s\in S}a_s|s\rangle,
$$

where $S$ is a finite set of surreal labels and each $a_s$ is hyperreal. Its exact Born weights are hyperreal. Its observed probabilities are their standard parts.

The distinction between a ket label and its amplitude is fundamental. A label identifies an outcome; an amplitude determines its weight. An infinitesimal label can carry an appreciable amplitude, and an ordinary label can carry an infinitesimal amplitude. Consequently, the state

$$
\frac{1}{\sqrt2}|0\rangle+\frac{1}{\sqrt2}|\varepsilon\rangle
$$

has equal probabilities on its two distinct labels, regardless of the fact that $\varepsilon$ is an infinitesimal surreal number. To make the second branch observationally invisible, the infinitesimal must occur in its amplitude, as in

$$
|0\rangle+\varepsilon|1\rangle.
$$

We establish that this corrected state has exact weights $1/(1+\varepsilon^2)$ and $\varepsilon^2/(1+\varepsilon^2)$, but observed probabilities $1$ and $0$.

The same mechanism appears in a purely discrete model. Give each of $n$ visible atoms a formal infinitesimal weight $\delta$, and give a reservoir atom weight $1-n\delta$. Projection to the dominant coordinate sends every visible atom to observed mass zero and the reservoir to mass one. The resulting real measure is Dirac. This provides an order-theoretic analogue of the quantum calculation and clarifies standard part as an observation functional.

The scope is deliberately finite. No infinite-dimensional Hilbert-space spectral theorem is asserted. The results identify a sound measurement core and expose the hypotheses that any extension must preserve.

## 2. Non-Archimedean preliminaries

### 2.1 Finite, infinitesimal, and appreciable elements

Let $\mathbb R^*$ be an ordered field extension of $\mathbb R$ equipped with the usual hyperreal notions. A hyperreal $x$ is **infinitesimal** if

$$
|x|<r
$$

for every real $r>0$. It is **finite** if $|x|<r$ for some positive real $r$, and **infinite** otherwise. A finite hyperreal is **appreciable** when it is not infinitesimal. Equivalently, its magnitude is bounded below by some positive real scale.

Every finite $x\in\mathbb R^*$ is infinitely close to a unique real number. The **standard part**

$$
\operatorname{st}:\{x\in\mathbb R^*:x\text{ is finite}\}\longrightarrow\mathbb R
$$

assigns that real number. In particular,

$$
\operatorname{st}(r)=r
$$

for real $r$, and

$$
\operatorname{st}(\eta)=0
$$

for every infinitesimal $\eta$. On finite arguments, standard part respects addition and multiplication. If $x$ is finite and appreciable, then $x^{-1}$ is finite and

$$
\operatorname{st}(x^{-1})=\operatorname{st}(x)^{-1}.
$$

These properties drive the measurement results.

### 2.2 Surreal-labelled finite state space

Let $\mathbf{No}$ denote the class of surreal numbers. We use surreal numbers only as labels and consider finite support, so all sums below are ordinary finite sums.

**Definition 2.1 (finite quantum-surreal state).** A finite quantum-surreal state is a finitely supported function

$$
\psi:\mathbf{No}\longrightarrow\mathbb R^*.
$$

Writing $a_s=\psi(s)$ and $S=\{s:a_s\ne0\}$, we use ket notation

$$
|\psi\rangle=\sum_{s\in S}a_s|s\rangle.
$$

The kets are formal independent basis vectors. Distinct labels correspond to distinct coordinates, no matter how close the labels are in the surreal order.

**Definition 2.2 (squared norm).** The squared norm of $\psi$ is

$$
N(\psi)=\|\psi\|^2=\sum_{s\in S}a_s^2\in\mathbb R^*.
$$

The amplitudes are taken in an ordered field, so $a_s^2\ge0$. This model is a real-amplitude core; a complex or algebraically closed extension would replace $a_s^2$ by $\overline{a_s}a_s$.

**Definition 2.3 (exact Born weight).** If $N(\psi)\ne0$, the exact Born weight of label $s$ is

$$
P_*(s\mid\psi)=\frac{a_s^2}{N(\psi)}.
$$

**Definition 2.4 (observed probability).** When $P_*(s\mid\psi)$ is finite, its observed probability is

$$
P_{\mathrm{obs}}(s\mid\psi)
=\operatorname{st}\!\left(P_*(s\mid\psi)\right).
$$

Thus exact weights retain non-Archimedean detail, while observed probabilities are real.

## 3. Exact normalization

The fundamental conservation law is unchanged by enlarging the scalar field.

**Theorem 3.1 (Born normalization).** Let $\psi$ be a finite quantum-surreal state with $N(\psi)\ne0$. Then

$$
\sum_{s\in S}P_*(s\mid\psi)=1.
$$

**Proof sketch.** Every summand has the same nonzero denominator $N(\psi)$. Finite distributivity gives

$$
\sum_{s\in S}\frac{a_s^2}{N(\psi)}
=\frac{\sum_{s\in S}a_s^2}{N(\psi)}
=\frac{N(\psi)}{N(\psi)}=1.
$$

No Archimedean property is used. $\square$

This theorem concerns exact hyperreal weights. To conclude that standard parts sum to one for an arbitrary finite state, one must additionally ensure that all normalized weights are finite and invoke finite additivity of standard part. Appreciability of the norm is the natural hypothesis for that broader result.

## 4. Infinitesimal amplitudes and invisible branches

The key local statement identifies when a branch disappears under observation.

**Theorem 4.1 (unobservability of an infinitesimal branch).** Let $\psi$ be a finite quantum-surreal state and let $s$ be a label. Suppose that $a_s$ is infinitesimal and that $N(\psi)$ is appreciable. Then

$$
P_{\mathrm{obs}}(s\mid\psi)=0.
$$

**Proof sketch.** Since $a_s$ is infinitesimal, $a_s^2$ is infinitesimal. Since $N(\psi)$ is appreciable, its inverse is finite. The product

$$
a_s^2N(\psi)^{-1}
$$

is therefore infinitesimal. This product is exactly $P_*(s\mid\psi)$, and standard part sends every infinitesimal to zero. $\square$

The appreciability assumption is load-bearing. If the entire state has infinitesimal norm, normalization may turn an infinitesimal amplitude into a visible branch. For example, a one-branch state $\psi=\eta|s\rangle$ with nonzero infinitesimal $\eta$ has

$$
P_*(s\mid\psi)=\frac{\eta^2}{\eta^2}=1.
$$

Thus “infinitesimal amplitude” is not an absolute criterion for invisibility. It must be compared with the total scale.

A useful equivalent condition concerns normalized amplitudes. Formally write

$$
b_s=\frac{a_s}{\sqrt{N(\psi)}}
$$

when a suitable positive square root exists. Then $P_*(s\mid\psi)=b_s^2$, so an infinitesimal normalized amplitude yields an infinitesimal exact weight and zero observed probability. The theorem avoids imposing square-root infrastructure by working directly with the squared norm.

## 5. Labels do not carry probability

The following two-branch computation isolates label invariance.

**Lemma 5.1 (two-branch norm).** Let $s$ and $t$ be distinct surreal labels, and let $a,b\in\mathbb R^*$. For

$$
|\phi\rangle=a|s\rangle+b|t\rangle,
$$

one has

$$
N(\phi)=a^2+b^2.
$$

**Proof sketch.** Distinct labels occupy distinct coordinates. The finite norm sum therefore has precisely the two displayed contributions. $\square$

**Theorem 5.2 (equal-amplitude exact weights).** Let $s\ne t$ and $a\ne0$. For

$$
|\phi\rangle=a|s\rangle+a|t\rangle,
$$

both exact Born weights equal $1/2$:

$$
P_*(s\mid\phi)=P_*(t\mid\phi)=\frac12.
$$

**Proof sketch.** Lemma 5.1 gives $N(\phi)=2a^2$. Since $a\ne0$, cancellation is valid, and

$$
\frac{a^2}{2a^2}=\frac12.
$$

The same calculation applies to both labels. $\square$

**Theorem 5.3 (equal-amplitude observed probabilities).** Under the hypotheses of Theorem 5.2,

$$
P_{\mathrm{obs}}(s\mid\phi)
=P_{\mathrm{obs}}(t\mid\phi)=\frac12.
$$

**Proof sketch.** The exact weights are the embedded real number $1/2$. Standard part fixes every real number. $\square$

These statements make no reference to the order, sign, birthday, magnitude, or infinitesimal status of either surreal label. They require only distinctness, which guarantees two coordinates, and nonzeroness of the common amplitude, which guarantees normalization.

**Corollary 5.4 (equal-amplitude obstruction).** Let $\varepsilon$ be a nonzero infinitesimal surreal label. The state

$$
\frac{1}{\sqrt2}|0\rangle+rac{1}{\sqrt2}|\varepsilon\rangle
$$

has observed probability $1/2$ at each outcome. In particular, the infinitesimal value of the second label does not make that branch unobservable.

This corollary corrects a category error. A basis label is analogous to a coordinate name. Replacing the name of one coordinate does not change its coefficient. Suppression must occur in the amplitude or in an explicitly label-dependent observable, not in the ordinary Born weight merely because the label is arithmetically small.

## 6. The epsilon-amplitude experiment

Let $\varepsilon\in\mathbb R^*$ now denote a positive hyperreal infinitesimal, and consider the state

$$
|\psi_\varepsilon\rangle=|0\rangle+\varepsilon|1\rangle.
$$

The labels $0$ and $1$ are ordinary and distinct; the second amplitude is infinitesimal.

**Proposition 6.1 (exact epsilon weights).** The squared norm and exact weights are

$$
N(\psi_\varepsilon)=1+\varepsilon^2,
$$

$$
P_*(0\mid\psi_\varepsilon)=\frac{1}{1+\varepsilon^2},
\qquad
P_*(1\mid\psi_\varepsilon)=\frac{\varepsilon^2}{1+\varepsilon^2}.
$$

They sum exactly to one.

**Proof sketch.** Apply Lemma 5.1 with amplitudes $1$ and $\varepsilon$, then substitute into Definition 2.3. Their sum is $(1+\varepsilon^2)/(1+\varepsilon^2)=1$. $\square$

**Theorem 6.2 (epsilon collapse).** The observed probabilities are

$$
P_{\mathrm{obs}}(0\mid\psi_\varepsilon)=1,
\qquad
P_{\mathrm{obs}}(1\mid\psi_\varepsilon)=0.
$$

Consequently, they sum to one.

**Proof sketch.** The quantity $\varepsilon^2$ is infinitesimal, so $1+\varepsilon^2$ is infinitely close to $1$ and has standard part $1$. Its inverse also has standard part $1$. Hence the first exact weight has standard part $1$. The numerator of the second weight is infinitesimal and its denominator is appreciable, so Theorem 4.1 gives standard part zero. $\square$

This example shows that exact and observed probability can encode different, compatible descriptions. The second branch has strictly positive exact weight whenever $\varepsilon\ne0$, yet zero observed probability. No finite real cutoff is chosen; the conclusion follows from the algebraic distinction between infinitesimal and appreciable scales.

### 6.1 Numerical shadows

Floating-point arithmetic has no genuine infinitesimals. Nevertheless, a family of real approximations $\varepsilon_k=10^{-k}$ displays the limiting profile:

$$
P_k(0)=\frac{1}{1+10^{-2k}},
\qquad
P_k(1)=\frac{10^{-2k}}{1+10^{-2k}}.
$$

As $k\to\infty$, these converge to $1$ and $0$. Such numerical experiments illustrate, but do not define, standard part. In the non-Archimedean model, $\varepsilon$ is a fixed nonzero number and the observed values are obtained by a map, not by replacing $\varepsilon$ with a real sequence.

## 7. A finite lexicographic probability model

A discrete construction captures the same collapse without amplitudes.

### 7.1 Lexicographic values

Define the value space

$$
L=\mathbb Q\times\mathbb Q.
$$

Interpret $(a,b)$ as $a+b\delta$, where $\delta$ is a formal positive infinitesimal. Addition is coordinatewise, and order is lexicographic:

$$
(a,b)<(c,d)
$$

if either $a<c$, or $a=c$ and $b<d$.

**Definition 7.1 (lexicographic standard part).** Define

$$
\operatorname{st}_L(a,b)=a.
$$

This is additive because first-coordinate projection is additive.

### 7.2 Atoms, events, and exact mass

Fix $n\ge0$. Let

$$
\Omega_n=\{\bot,1,2,\dots,n\},
$$

where $\bot$ is a reservoir atom. Assign

$$
w(i)=(0,1)=\delta
$$

for each visible atom $i$, and

$$
w(\bot)=(1,-n)=1-n\delta.
$$

For an event $A\subseteq\Omega_n$, define

$$
\mu_n(A)=\sum_{x\in A}w(x).
$$

If $k$ visible atoms belong to $A$, then the closed form is

$$
\mu_n(A)=
\begin{cases}
(0,k), & \bot\notin A,\\
(1,k-n), & \bot\in A.
\end{cases}
$$

The whole space has exact mass

$$
\mu_n(\Omega_n)=(1,0)=1.
$$

For disjoint events $A$ and $B$, finite summation gives

$$
\mu_n(A\cup B)=\mu_n(A)+\mu_n(B).
$$

### 7.3 Standard-part collapse

**Theorem 7.2 (Dirac collapse).** For every event $A\subseteq\Omega_n$,

$$
\operatorname{st}_L(\mu_n(A))=
\begin{cases}
1, & \bot\in A,\\
0, & \bot\notin A.
\end{cases}
$$

**Proof sketch.** Use the closed form. If $\bot\notin A$, then $\mu_n(A)=(0,k)$ and its first coordinate is zero. If $\bot\in A$, then $\mu_n(A)=(1,k-n)$ and its first coordinate is one. $\square$

**Corollary 7.3 (normalization and invisible visible atoms).** The observed total mass is one, while each visible singleton has observed mass zero:

$$
\operatorname{st}_L(\mu_n(\Omega_n))=1,
\qquad
\operatorname{st}_L(\mu_n(\{i\}))=0.
$$

**Theorem 7.4 (finite additivity after observation).** If $A\cap B=\varnothing$, then

$$
\operatorname{st}_L(\mu_n(A\cup B))
=
\operatorname{st}_L(\mu_n(A))+
\operatorname{st}_L(\mu_n(B)).
$$

**Proof sketch.** Exact finite additivity holds in $L$, and $\operatorname{st}_L$ is additive. Equivalently, disjoint events cannot both contain the single reservoir atom, so the indicator of reservoir membership is additive on disjoint unions. $\square$

The observed measure is precisely the Dirac probability measure $\delta_\bot$. The infinitesimal visible masses remain meaningful in $L$ but vanish under $\operatorname{st}_L$.

## 8. A bridge between the quantum and discrete models

The two constructions differ in detail but share a common pattern.

| Layer | Quantum model | Discrete model |
|---|---|---|
| Exact values | Hyperreal Born weights | Lexicographic rational weights |
| Infinitesimal data | Squared infinitesimal amplitudes | Second-coordinate atom masses |
| Observation map | $\operatorname{st}$ | First-coordinate projection $\operatorname{st}_L$ |
| Preserved structure | Normalization | Normalization and finite additivity |
| Classical shadow | Invisible infinitesimal branch | Dirac mass at the reservoir |

In each case an exact normalized theory contains positive infinitesimal weights. An additive standard-part functional discards their lower-order component while preserving the dominant real mass. The bridge is structural rather than an identification of the two scalar systems.

The analogy also clarifies the role of hypotheses. In the quantum theorem, an appreciable norm prevents division from magnifying an infinitesimal numerator. In the discrete model, the reservoir has dominant coordinate one, so normalization is already appreciable. Both mechanisms stabilize the scale before standard part is taken.

## 9. Algorithms

### 9.1 Finite observed Born distribution

For numerical inputs, the finite measurement algorithm squares amplitudes, normalizes, and applies an observation map. With ordinary floating-point numbers, a tolerance can only imitate standard part; it is not a genuine infinitesimal semantics.

**Algorithm 9.1.** Given distinct labels $s_1,\dots,s_m$, amplitudes $a_1,\dots,a_m$, and an observation map $\sigma$:

1. Compute $N=\sum_{i=1}^m a_i^2$.
2. Reject the zero state if $N=0$.
3. Compute exact weights $w_i=a_i^2/N$.
4. Return observed weights $p_i=\sigma(w_i)$.
5. Verify $\sum_i w_i=1$ in the exact arithmetic.

The arithmetic complexity is $O(m)$ and storage is $O(m)$. In a symbolic non-Archimedean implementation, $\sigma$ is standard part. In a numerical visualization, it may be a documented thresholding proxy.

### 9.2 Lexicographic event measurement

For an event represented by reservoir membership and the number $k$ of visible atoms, no enumeration is needed:

1. If the reservoir is absent, return exact weight $(0,k)$ and observed weight $0$.
2. If the reservoir is present, return exact weight $(1,k-n)$ and observed weight $1$.

This summary algorithm takes $O(1)$ time. If the event is supplied as an arbitrary list, counting visible atoms takes $O(|A|)$ time.

### 9.3 Observational equivalence test

Two finite states on the same labels are observationally equivalent when all standard-part Born weights agree. Compute both observed distributions and compare coordinatewise. The cost is $O(m)$ after supports are aligned. This test motivates a quotient of finite non-Archimedean state space by observational indistinguishability.

## 10. Applications and interpretation

### 10.1 Multiscale probability

Non-Archimedean weights encode exact priority layers. A probability of order $1$ dominates one of order $\varepsilon$, which dominates one of order $\varepsilon^2$, without choosing a numerical cutoff. Standard part extracts the leading real layer. This can model asymptotic regimes, perturbative sectors, and lexicographic decisions.

### 10.2 Measurement resolution

The epsilon experiment separates ontology from observation. A branch can be mathematically present and carry positive exact mass while being absent from the real-valued observational distribution. This resembles coarse-graining, but standard part is an algebraic quotient rather than an instrument-specific finite threshold.

### 10.3 Outcome spaces with extreme scales

Surreal labels allow finite collections of outcomes that may include real, infinite, and infinitesimal values. The equal-amplitude theorem ensures that their arithmetic magnitude does not secretly bias probability. Any physical model that wishes magnitude to affect likelihood must introduce that dependence through amplitudes or observables explicitly.

### 10.4 Classical shadows of enriched models

The Dirac collapse shows how an enriched finitely additive measure can project to an ordinary measure. Such shadows may offer a systematic way to compare non-Archimedean models with standard probabilistic predictions: exact lower-order distinctions are retained internally and removed only by a specified observation map.

## 11. Limitations and discussion

The present state space is finite-support and uses ordered-field amplitudes. Standard quantum theory uses complex Hilbert spaces, conjugate-linear inner products, complete normed spaces, and self-adjoint operators. Extending the model requires choices about complexification, positivity, topology, completeness, and spectral measures.

No general spectral theorem is established here. In finite dimensions, a promising algebraic question is orthogonal diagonalization of symmetric matrices over real-closed non-Archimedean fields. Even then, descent of eigenvalues under standard part requires uniform finiteness and compatibility of characteristic polynomials with entrywise standard part. Infinite-dimensional claims introduce substantially more analytic structure.

Standard part is also defined only for finite hyperreals. The local observed-probability definition therefore requires finiteness of normalized weights. For squared amplitudes and an appreciable positive norm, this is natural, but a complete general theorem should state and prove the finiteness conditions globally.

Finally, a zero standard part does not mean zero exact probability. The distinction is the point of the construction. Interpretations that identify “observed probability zero” with logical impossibility would erase the enriched layer and should be avoided.

## 12. Future work

The immediate next theorem should treat arbitrary finite support: finite amplitudes and an appreciable nonzero norm ought to produce a nonnegative real distribution whose mass is one after standard part. This would unify exact normalization and local infinitesimal disappearance.

A second direction is observational equivalence. Equality of all standard-part Born probabilities should define an equivalence relation, and one expects compatibility with relabelling. Compatibility with tensoring by an appreciably normalized ancillary state is subtler and would establish that invisible perturbations form a robust quotient theory.

A third direction is finite-dimensional spectral theory. Symmetric matrices over suitable real-closed non-Archimedean fields should admit algebraic diagonalization, while finite eigenvalues may descend to eigenvalues of the standard-part matrix under appropriate hypotheses.

A fourth direction replaces pairs $(a,b)$ by towers $(a_0,a_1,\dots,a_k)$ with lexicographic order. Successive projections would reveal a filtration of observational scales: an event invisible at the leading level might become visible at the next.

## 13. Conclusion

Finite surreal-labelled states with hyperreal amplitudes support an exact, normalized non-Archimedean Born rule. Standard part converts exact weights into real observations. Under an appreciable total scale, infinitesimal amplitudes generate invisible branches. Equal amplitudes, by contrast, produce equal probabilities independently of whether a ket label is ordinary, infinite, or infinitesimal. The distinction corrects the proposed label-based suppression rule and locates infinitesimal unobservability where it belongs: in normalized weight.

A finite lexicographic model confirms the same principle from another angle. Infinitesimal atom masses disappear under projection to the dominant coordinate, leaving a normalized, finitely additive Dirac measure. Together the models present standard part as a mathematically controlled observation map: it preserves leading probability while forgetting exact lower-order distinctions.