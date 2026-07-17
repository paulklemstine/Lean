# Quantum Surreal Observation: Standard-Part Collapse and Its Tropical Shadow

**Aristotle**  
**17 July 2026**

## Abstract

We develop a finite theory of quantum states indexed by surreal numbers and carrying amplitudes in a non-Archimedean ordered field with a standard-part map. Exact Born weights remain non-Archimedean and normalize to one, while observed probabilities are their real standard parts. We prove that an infinitesimal amplitude has observed probability zero whenever the total squared norm is appreciable. The two-branch state $|0\rangle+\varepsilon|1\rangle$ consequently has observed probabilities $1$ and $0$. We also identify a sharp obstruction: two distinct surreal-labelled branches with the same nonzero amplitude each have probability $1/2$, irrespective of whether one label is infinitesimal. Thus unobservability is controlled by amplitude rather than label.

A discrete lexicographic model supplies an additive classical counterpart. On a space of $n$ visible atoms and one reservoir, assigning infinitesimal mass $\varepsilon$ to each visible atom and mass $1-n\varepsilon$ to the reservoir yields an exactly normalized finitely additive measure. Its standard part is the Dirac probability at the reservoir. Finally, we compare this collapse with max-plus selection. Giving the reservoir tropical weight $0$ and every visible atom a penalty $M<0$ forces the max-plus integral of an observable $f$ to be attained at the reservoir whenever $f(v_i)+M\le f(r)$ for all visible atoms. Standard-part observation and tropicalization therefore share a support-selection law under a sharp stability condition, although their algebraic operations remain distinct.

## 1. Introduction

The surreal numbers form an ordered field containing the real numbers, infinite quantities, and infinitesimals. Their scale-rich geometry suggests a basis of states labelled not merely by ordinary numerical outcomes but by values extending across finite and transfinite orders of magnitude. Labels alone, however, do not determine quantum probabilities. To obtain genuinely infinitesimal Born weights, the scalar field of amplitudes must itself admit infinitesimals.

This paper studies a finite model in which basis kets are indexed by surreal numbers and amplitudes lie in a non-Archimedean ordered field $K$ extending $\mathbb{R}$. A standard-part map sends each finite element of $K$ to the unique real number infinitely close to it. The model separates two levels of probability. Exact Born weights belong to $K$ and preserve infinitesimal information; observed probabilities belong to $\mathbb{R}$ and are obtained by taking standard parts.

Three questions guide the development.

1. Do exact non-Archimedean Born weights retain ordinary normalization?
2. Under what hypotheses does an infinitesimal branch become observationally invisible?
3. How does standard-part collapse compare with tropical selection, which also discards subdominant scales?

The answers expose an important correction to a tempting but invalid intuition. The state

$$
\frac{1}{\sqrt2}|0\rangle+\frac{1}{\sqrt2}|\varepsilon\rangle
$$

has equal probabilities, not probabilities $1$ and $0$. The infinitesimal nature of the second **label** does not alter its appreciable amplitude. The correct test state is

$$
|0\rangle+\varepsilon|1\rangle,
$$

where the amplitude itself is infinitesimal.

The finite setting permits exact statements without assuming an infinite-dimensional non-Archimedean Hilbert-space theory. It also reveals the minimal hypothesis behind collapse: the total squared norm must be appreciable. We then translate the same mechanism into an elementary lexicographic probability space and prove that standard part produces a Dirac measure. Finally, a max-plus model shows when logarithmic dominance selects the same support.

## 2. Non-Archimedean preliminaries

### 2.1. Infinitesimals, finite elements, and appreciability

Let $K$ be an ordered non-Archimedean field extending $\mathbb{R}$. An element $x\in K$ is **infinitesimal** if

$$
|x|<r
$$

for every real $r>0$. It is **finite** if $|x|<r$ for some real $r>0$, and **infinite** otherwise. A finite element is **appreciable** when it is not infinitesimal.

We assume that every finite $x\in K$ has a standard part $\operatorname{st}(x)\in\mathbb{R}$ such that $x-\operatorname{st}(x)$ is infinitesimal. Standard part fixes real numbers, annihilates infinitesimals, and respects addition and multiplication on finite inputs. In particular,

$$
\operatorname{st}(r+\delta)=r
$$

for real $r$ and infinitesimal $\delta$.

A distinguished positive infinitesimal will be denoted by $\varepsilon$. Its square $\varepsilon^2$ is again a positive infinitesimal.

### 2.2. Surreal-labelled finite states

Let $\mathbf{No}$ denote the class of surreal numbers. A **finite quantum surreal state** is a finitely supported function

$$
\psi:\mathbf{No}\to K.
$$

Equivalently, it is a finite formal sum

$$
|\psi\rangle=\sum_{s\in S}a_s|s\rangle,
$$

where $S\subset\mathbf{No}$ is finite and $a_s\in K$. Distinct labels represent orthogonal basis directions. Throughout the present real-amplitude model, define the squared norm by

$$
N(\psi)=\|\psi\|^2=\sum_{s\in S}a_s^2.
$$

For a state with $N(\psi)\ne0$, the **exact Born weight** of label $s$ is

$$
W_\psi(s)=\frac{a_s^2}{N(\psi)}\in K.
$$

Whenever this weight is finite, the **observed probability** is

$$
P_\psi(s)=\operatorname{st}\bigl(W_\psi(s)\bigr)\in\mathbb{R}.
$$

These definitions distinguish the arithmetic magnitude of a label $s$ from the magnitude of its coefficient $a_s$. Only the latter enters the Born rule.

## 3. Exact normalization and infinitesimal collapse

### Theorem 3.1 (Non-Archimedean Born normalization)

Let $|\psi\rangle=\sum_{s\in S}a_s|s\rangle$ be a finite quantum surreal state with $N(\psi)\ne0$. Then its exact Born weights satisfy

$$
\sum_{s\in S}W_\psi(s)=1.
$$

#### Proof sketch

By definition,

$$
\sum_{s\in S}W_\psi(s)
=\sum_{s\in S}\frac{a_s^2}{N(\psi)}
=\frac{\sum_{s\in S}a_s^2}{N(\psi)}
=\frac{N(\psi)}{N(\psi)}=1.
$$

The argument takes place entirely in $K$. Thus positive infinitesimal weights are retained in the exact sum rather than rounded away before normalization.

### Theorem 3.2 (Unobservability of an infinitesimal branch)

Let $\psi$ be a finite quantum surreal state, and let $s$ be a basis label. Suppose that the amplitude $a_s$ is infinitesimal and that $N(\psi)$ is appreciable. Then

$$
P_\psi(s)=0.
$$

#### Proof sketch

The square $a_s^2$ is infinitesimal. Since $N(\psi)$ is appreciable, its inverse is finite. The product

$$
W_\psi(s)=a_s^2N(\psi)^{-1}
$$

is therefore infinitesimal. Standard part annihilates infinitesimals, giving $P_\psi(s)=0$.

The appreciability hypothesis is mathematically necessary. If all amplitudes occur on an infinitesimal scale, normalization can divide by an equally small or smaller squared norm. For example, a one-branch state $\varepsilon|s\rangle$ has infinitesimal amplitude and infinitesimal squared norm $\varepsilon^2$, but its normalized Born weight is exactly $1$. Collapse is therefore relative to the scale of the total state, not a property of an amplitude in isolation.

### Corollary 3.3 (The epsilon test)

For distinct labels $0$ and $1$, consider

$$
|\psi_\varepsilon\rangle=|0\rangle+\varepsilon|1\rangle.
$$

Then

$$
P_{\psi_\varepsilon}(0)=1,
\qquad
P_{\psi_\varepsilon}(1)=0,
$$

and the two observed probabilities sum to one.

#### Proof sketch

Orthogonality of the two labels gives

$$
N(\psi_\varepsilon)=1+\varepsilon^2.
$$

Hence

$$
W_{\psi_\varepsilon}(0)=\frac{1}{1+\varepsilon^2},
\qquad
W_{\psi_\varepsilon}(1)=\frac{\varepsilon^2}{1+\varepsilon^2}.
$$

The denominator has standard part $1$. The first weight is infinitely close to $1$, while the second is infinitesimal. Taking standard parts yields $1$ and $0$. Their observed sum is consequently $1$.

This example realizes exact positivity together with observational disappearance. The second branch has a strictly positive exact Born weight, yet no real-valued observed mass.

## 4. Label invariance and the equal-amplitude obstruction

The surreal labels can themselves be infinitesimal or infinite. It is therefore essential to determine whether their arithmetic size influences probability.

### Lemma 4.1 (Norm of a distinct two-branch state)

If $s\ne t$, then for amplitudes $a,b\in K$,

$$
N\bigl(a|s\rangle+b|t\rangle\bigr)=a^2+b^2.
$$

#### Proof sketch

Finite support and the distinctness of $s$ and $t$ imply that the coefficient function has value $a$ at $s$, value $b$ at $t$, and zero elsewhere. Summing squared coefficients gives $a^2+b^2$.

### Theorem 4.2 (Equal-Amplitude Obstruction)

Let $s\ne t$ be any two surreal labels, and let $a\in K$ be nonzero. For the state

$$
|\phi\rangle=a|s\rangle+a|t\rangle,
$$

the exact Born weights and observed probabilities are

$$
W_\phi(s)=W_\phi(t)=\frac12,
\qquad
P_\phi(s)=P_\phi(t)=\frac12.
$$

#### Proof sketch

By Lemma 4.1, $N(\phi)=2a^2$. Since $a\ne0$, cancellation gives

$$
W_\phi(s)=\frac{a^2}{2a^2}=\frac12,
$$

and identically for $t$. The value $1/2$ is an ordinary real embedded in $K$, so its standard part is $1/2$.

The theorem is invariant under swapping the two labels. It applies even when one label is a positive infinitesimal surreal number and the other is zero. Thus

$$
\frac{1}{\sqrt2}|0\rangle+\frac{1}{\sqrt2}|\varepsilon\rangle
$$

has observed probabilities $1/2$ and $1/2$. The label $\varepsilon$ specifies an outcome; it does not multiply the branch amplitude. The invalid inference “infinitesimal outcome implies infinitesimal probability” confuses coordinates with coefficients.

Two hypotheses deserve emphasis. If $s=t$, the two amplitudes combine before squaring, so there are not two orthogonal outcomes. If $a=0$, the squared norm vanishes and normalized weights are undefined. These are structural, not technical, restrictions.

## 5. A finite lexicographic probability model

We now isolate standard-part collapse in a discrete additive setting.

### 5.1. Lexicographic values

Define

$$
L=\mathbb{Q}\times\mathbb{Q},
$$

and interpret $(a,b)$ as $a+b\varepsilon$. Addition is coordinatewise. Order is lexicographic:

$$
(a,b)<(c,d)
$$

if either $a<c$, or $a=c$ and $b<d$. Define

$$
1=(1,0),\qquad \varepsilon=(0,1),
$$

and define the standard-part functional by

$$
\operatorname{st}_L(a,b)=a.
$$

This elementary ring records an appreciable rational component and a first-order infinitesimal component.

### 5.2. Reservoir probabilities

Fix $n\ge0$. Let the outcome space be

$$
\Omega_n=\{r,v_1,\ldots,v_n\},
$$

where $r$ is the reservoir and the $v_i$ are visible atoms. Assign atom weights

$$
\omega(r)=1-n\varepsilon=(1,-n),
\qquad
\omega(v_i)=\varepsilon=(0,1).
$$

For an event $A\subseteq\Omega_n$, define

$$
\mu_n(A)=\sum_{x\in A}\omega(x).
$$

Let $k(A)$ be the number of visible atoms in $A$, and let $\chi_r(A)$ be $1$ if $r\in A$ and $0$ otherwise.

### Proposition 5.1 (Closed event formula)

For every event $A\subseteq\Omega_n$,

$$
\mu_n(A)=
\left(
\chi_r(A),
\;k(A)-n\chi_r(A)
\right).
$$

#### Proof sketch

Each included visible atom contributes $(0,1)$, producing $(0,k(A))$. If the reservoir is included, it contributes $(1,-n)$. Adding these contributions yields the formula. Equivalently, one may induct on the finite event by adjoining one atom at a time.

### Proposition 5.2 (Finite additivity and normalization)

If $A$ and $B$ are disjoint events, then

$$
\mu_n(A\cup B)=\mu_n(A)+\mu_n(B).
$$

Moreover,

$$
\mu_n(\Omega_n)=1.
$$

#### Proof sketch

For disjoint events, the atom sums concatenate with no repeated term. For the full space, the reservoir contributes $(1,-n)$ and the $n$ visible atoms contribute $(0,n)$, giving $(1,0)$.

### Theorem 5.3 (Standard-Part Dirac Collapse)

For every event $A\subseteq\Omega_n$,

$$
\operatorname{st}_L(\mu_n(A))=
\begin{cases}
1,&r\in A,\\
0,&r\notin A.
\end{cases}
$$

Consequently, the standard-part measure is the Dirac probability $\delta_r$ concentrated at the reservoir. In particular,

$$
\operatorname{st}_L(\mu_n(\Omega_n))=1,
\qquad
\operatorname{st}_L(\mu_n(\{v_i\}))=0
$$

for every visible atom $v_i$.

#### Proof sketch

By Proposition 5.1, the first coordinate of $\mu_n(A)$ is exactly $\chi_r(A)$. Standard part selects this coordinate and discards the infinitesimal coordinate. The displayed formula is therefore immediate. It is exactly the event formula for $\delta_r$.

### Corollary 5.4 (Additivity after observation)

For disjoint events $A$ and $B$,

$$
\operatorname{st}_L(\mu_n(A\cup B))
=
\operatorname{st}_L(\mu_n(A))+
\operatorname{st}_L(\mu_n(B)).
$$

#### Proof sketch

Apply finite additivity in $L$ and use the coordinatewise linearity of $\operatorname{st}_L$.

The discrete model and the quantum epsilon test have the same support signature: total observed mass one, one appreciable component surviving, and every designated infinitesimal component erased. Their exact value systems differ, but the observational mechanism is identical.

## 6. Tropical selection

### 6.1. Max-plus integration

The max-plus semiring replaces ordinary addition by maximum and multiplication by addition. Given a finite set $X$, a tropical weight function $W:X\to\mathbb{R}$, and an observable $f:X\to\mathbb{R}$, define the max-plus integral

$$
\mathcal{T}_W(f)=\max_{x\in X}\bigl(f(x)+W(x)\bigr).
$$

This operation records the dominant weighted value rather than an additive average.

On $\Omega_n$, fix a penalty $M<0$ and define the **reservoir tropical weight** by

$$
W_M(r)=0,
\qquad
W_M(v_i)=M.
$$

Thus

$$
\mathcal{T}_{W_M}(f)
=
\max\left(
f(r),
\max_{1\le i\le n}(f(v_i)+M)
\right).
$$

### Theorem 6.1 (Reservoir max-plus selection)

Suppose that

$$
f(v_i)+M\le f(r)
$$

for every visible atom $v_i$. Then

$$
\mathcal{T}_{W_M}(f)=f(r).
$$

#### Proof sketch

The reservoir contributes $f(r)+0=f(r)$ to the finite maximum. Every visible contribution is at most $f(r)$ by hypothesis. Hence the maximum equals $f(r)$ and is attained at the reservoir.

### Theorem 6.2 (Standard-Part/Tropical Support Bridge)

In the reservoir model, standard-part observation assigns total mass one to the full space and mass zero to each visible singleton. For every observable satisfying

$$
f(v_i)+M\le f(r)
$$

for all $i$, the corresponding max-plus integral is also selected by the reservoir:

$$
\operatorname{st}_L(\mu_n(\Omega_n))=1,
\qquad
\operatorname{st}_L(\mu_n(\{v_i\}))=0,
\qquad
\mathcal{T}_{W_M}(f)=f(r).
$$

#### Proof sketch

The first two conclusions are instances of Theorem 5.3. The final conclusion is Theorem 6.1. Together they identify the same surviving support under additive standard-part observation and idempotent tropical selection.

### Corollary 6.3 (Three-model collapse signature)

For the quantum state $|0\rangle+\varepsilon|1\rangle$, the discrete reservoir measure, and the reservoir tropical weight applied to the constant observable $f\equiv0$, the three descriptions agree on a one-survivor, one-erased signature:

$$
P(0)=1,
\qquad
P(1)=0,
$$

$$
\operatorname{st}_L(\mu_n(\Omega_n))=1,
\qquad
\operatorname{st}_L(\mu_n(\{v_i\}))=0,
$$

and

$$
\mathcal{T}_{W_M}(0)=0,
$$

with the tropical maximum attained at the reservoir.

#### Proof sketch

The quantum equalities are Corollary 3.3, the discrete equalities are Theorem 5.3, and the tropical equality follows because $M<0$ implies $0+M\le0$.

## 7. Algorithms and computational interpretation

The finite results lead to direct algorithms.

### 7.1. Born-weight observation

Given real approximations to amplitudes $a_1,\ldots,a_m$ and a declared observational tolerance $\tau>0$, compute

$$
N=\sum_i a_i^2,
\qquad
w_i=\frac{a_i^2}{N}.
$$

A numerical shadow of standard part reports $w_i$ as zero when it lies below $\tau$. This is an approximation only: no floating-point tolerance is literally an infinitesimal. Still, varying a small parameter $\varepsilon$ in the state $(1,\varepsilon)$ displays convergence of the exact real weights

$$
\left(\frac{1}{1+\varepsilon^2},
\frac{\varepsilon^2}{1+\varepsilon^2}
\right)
$$

toward $(1,0)$.

The algorithm takes $O(m)$ time and $O(m)$ output space. It should reject zero norm. Its central diagnostic is to compare the epsilon-amplitude state $(1,\varepsilon)$ with the equal-amplitude state $(1,1)$: only the former collapses in the small-$\varepsilon$ limit.

### 7.2. Lexicographic event probability

Represent an event by a reservoir flag $b\in\{0,1\}$ and a visible count $k$. Its exact lexicographic mass is

$$
(b,k-nb),
$$

and its standard part is $b$. If the event is supplied as a list of atoms, counting takes $O(n)$ time; if $b$ and $k$ are already known, evaluation takes $O(1)$ time.

### 7.3. Tropical reservoir test

Given $f(r)$, visible values $f(v_i)$, and $M<0$, compute all scores $f(v_i)+M$ and compare their maximum with $f(r)$. The bridge regime holds precisely when

$$
\max_i f(v_i)+M\le f(r).
$$

This requires $O(n)$ time and $O(1)$ auxiliary space. The margin

$$
\Delta=f(r)-\max_i(f(v_i)+M)
$$

quantifies stability: $\Delta\ge0$ means reservoir selection; $\Delta<0$ identifies visible escape.

## 8. Applications and interpretation

### 8.1. Rare-event idealization

Infinitesimal weights distinguish “exactly impossible” from “smaller than every ordinary scale.” This is useful when a model must preserve algebraic traces of rare events while presenting ordinary probabilities to an observer. Standard part performs the final observational coarse-graining.

### 8.2. Perturbative states

The epsilon test is a minimal perturbative model. The branch $\varepsilon|1\rangle$ affects exact normalization through $\varepsilon^2$ but disappears from real-valued measurement. Higher-order perturbative corrections can therefore remain algebraically present without being promoted to leading-order observations.

### 8.3. Dominant-scale optimization

The tropical bridge is relevant when probabilities or costs are encoded through exponential rates. Standard part asks whether mass remains appreciable; tropicalization asks which logarithmic score dominates. Under the dominance inequality, both identify the reservoir. The inequality describes a stability cone for observables rather than a universal identity between the two theories.

### 8.4. Conceptual boundary conditions

The results rule out three overstatements.

First, infinitesimal labels are not automatically unobservable. The Equal-Amplitude Obstruction shows that label magnitude is irrelevant to Born mass.

Second, an infinitesimal amplitude is not automatically invisible after normalization. Appreciability of the total squared norm is required.

Third, standard-part expectation and max-plus integration are not numerically interchangeable. One is additive; the other is max-plus linear. Their proven relationship concerns selected support under a quantitative condition.

## 9. Discussion

The theory organizes three forms of scale reduction.

At the exact level, non-Archimedean Born weights form a normalized probability vector that can retain strictly positive infinitesimals. At the observational level, standard part yields ordinary real probabilities and removes infinitesimal components. At the tropical level, logarithmic penalties select dominant outcomes through a maximum.

The reservoir model makes their relationship transparent. Exact additive mass is spread across one appreciable reservoir and $n$ positive infinitesimal atoms. Standard part collapses this measure to $\delta_r$. Tropical weighting chooses the same reservoir for observables whose visible advantage does not overcome the penalty. The bridge is robust but conditional.

The observable-dependent inequality is close to optimal. If for some $i$,

$$
f(v_i)+M>f(r),
$$

then that visible outcome defeats the reservoir in the max-plus integral, even though its standard-part probability remains zero. Every fixed finite penalty can be overcome by a sufficiently large observable value. This explains why unconditional equality would be false and identifies the boundary where support agreement breaks.

The present finite theory does not assert a general spectral theorem over a completed non-Archimedean Hilbert space. Such a theorem requires additional structure: a suitable complexification, positivity, completeness, control of finite elements, and compatibility between spectral projections and standard part. The finite measurement results instead establish the algebraic and boundedness conditions that any broader theory must respect.

## 10. Future work

A first direction is finite-dimensional non-Archimedean spectral calculus. For self-adjoint matrices with finite entries and appreciably separated eigenvalue clusters, one expects orthogonal spectral decomposition to descend under standard part to the ordinary real or complex decomposition. Two-by-two matrices provide the natural first test.

A second direction is support equivalence under Maslov dequantization. For a finite non-Archimedean probability vector with finite logarithmic rates, the coordinates surviving standard part should correspond to the zero-level argmax set of normalized tropical weights. The reservoir theorem proves this in a Dirac-shaped penalty model.

A third direction is a sharp quantitative stability theory. The inequalities $f(v_i)+M_i\le f(r)$ define a polyhedral cone in observable space. Its boundary should belong to the normal fan separating agreement of additive and tropical support from visible-outcome escape.

A fourth direction is standard-part descent for finite projection-valued measures. Polynomial identities for projections and orthogonality are natural candidates to survive standard part, while infinitesimal operator-norm errors may provide the correct approximate hypotheses.

## 11. Conclusion

Finite quantum surreal states support a coherent two-level probability theory. Exact non-Archimedean Born weights normalize to one. Standard part turns them into ordinary probabilities and erases a branch precisely when its normalized weight is infinitesimal. The state $|0\rangle+\varepsilon|1\rangle$ exhibits complete observed collapse to the first branch, while equal amplitudes on distinct labels always produce equal half probabilities. The distinction proves that unobservability is an amplitude phenomenon, not a label phenomenon.

The lexicographic reservoir model translates the same mechanism into finite additive probability: standard part is exactly a Dirac measure. Tropical max-plus selection supplies a complementary dominant-scale shadow and chooses the same reservoir under an explicit stability condition. Together these results separate exact infinitesimal mass, ordinary observation, and asymptotic dominance while showing how all three can agree on the support that remains visible.