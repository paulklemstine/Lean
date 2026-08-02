# Category-Theoretic Neural Architectures: Products, Natural Attention, and Finite Search

**Aristotle**  
**August 2, 2026**

## Abstract

We present a categorical framework for three recurring constructions in neural architecture design: residual connections, multi-stream attention, and finite architecture search. An architecture from an input object $X$ to an output object $Y$ is modeled as a morphism $X\to Y$ in a category, with sequential execution given by composition and parallel execution given by product maps. Within any category admitting the binary product $X\times X$, a residual skip connection associated with $r:X\to X$ is the unique product lift $\langle\operatorname{id}_X,r\rangle:X\to X\times X$. Its two projections recover exactly the identity and learned branches. In a seminormed additive commutative group, additive readout produces the usual block $B(x)=x+r(x)$, and a $K$-Lipschitz residual branch yields a $(1+K)$-Lipschitz block. For a representation functor $F:\mathcal C\to\mathbf{Set}$, we define the two-head feature functor $H(X)=F(X)\times F(X)$ and show that exchanging the heads defines a natural transformation $H\Rightarrow H$. Finally, semantic architectures from $F$ to $G$ are natural transformations in the functor category $[\mathcal C,\mathbf{Set}]$. Any real-valued loss on a nonempty finite set of such transformations attains a minimum, as does a loss on finite candidates carrying both feedforward topology and functorial semantics. We give constructive search algorithms, numerical examples, scope conditions, and applications to stability certification, equivariant design, and structured architecture search.

## 1. Introduction

Neural architectures are compositional objects. A layer consumes one representation and produces another; layers form sequences; branches run in parallel; skip paths preserve information; attention coordinates feature streams; and architecture search compares entire structured pipelines. Although these operations are often expressed through diagrams, their common mathematical grammar is not always made explicit.

Category theory provides such a grammar. A category consists of objects, morphisms between objects, identity morphisms, and associative composition. Its axioms encode the minimal laws required for wiring transformations together. Products encode parallel access to multiple outputs. Functors encode coherent changes of representation. Natural transformations encode operations that commute with those changes. Functor categories collect such transformations as morphisms in their own right.

The purpose of this paper is to state and prove four precise results.

1. A residual skip connection is the universal product pairing of an identity branch and a learned residual branch.
2. Additive readout of a $K$-Lipschitz residual branch is $(1+K)$-Lipschitz.
3. Exchanging two functorial feature heads is a natural transformation.
4. A real-valued loss attains a minimum on every nonempty finite family of functor-category architectures, including candidates augmented with feedforward topology.

These claims occupy different mathematical levels. The first is categorical, the second analytic, the third functorial, and the fourth finite-optimization theoretic. Keeping these levels distinct avoids overstatement. In particular, the attention result concerns an exact two-head exchange operator, not arbitrary softmax attention; and the search result establishes existence and a finite scan, not tractability of an infinite or continuously parameterized search space.

The framework is nevertheless useful because each theorem identifies a reusable interface. A residual module may be studied through its two projections and readout. An attention-like operator may be assessed by a naturality square. A search space may be built from transformations that already satisfy representation-compatibility constraints. The categorical language organizes these interfaces independently of a particular coordinate system or implementation.

## 2. Categorical and analytic preliminaries

### 2.1 Categories and architectures

A **category** $\mathcal C$ consists of a class of objects; for each pair $X,Y$, a collection $\operatorname{Hom}_{\mathcal C}(X,Y)$ of morphisms; an identity $\operatorname{id}_X:X\to X$ for each object; and an associative composition operation. We write composition in functional order as $g\circ f:X\to Z$ when $f:X\to Y$ and $g:Y\to Z$.

**Definition 2.1 (Neural architecture).** A neural architecture with input object $X$ and output object $Y$ is a morphism

$$
f:X\longrightarrow Y
$$

in an ambient category $\mathcal C$.

**Definition 2.2 (Sequential composition).** Given architectures $f:X\to Y$ and $g:Y\to Z$, their sequential composition is $g\circ f:X\to Z$.

Associativity ensures that a chain of compatible modules has an unambiguous composite, while identities represent no-op modules.

### 2.2 Binary products and parallel composition

A **binary product** of objects $X_1,X_2$ consists of an object $X_1\times X_2$ and projections

$$
\pi_1:X_1\times X_2\to X_1,
\qquad
\pi_2:X_1\times X_2\to X_2,
$$

such that for every object $A$ and maps $p:A\to X_1$, $q:A\to X_2$, there is a unique map $\langle p,q\rangle:A\to X_1\times X_2$ satisfying

$$
\pi_1\circ\langle p,q\rangle=p,
\qquad
\pi_2\circ\langle p,q\rangle=q.
$$

The phrase “unique” is crucial: a product is characterized by its interface, not by an assumed elementwise representation.

**Definition 2.3 (Parallel composition).** If products $X_1\times X_2$ and $Y_1\times Y_2$ exist and $f:X_1\to Y_1$, $g:X_2\to Y_2$, the parallel product map

$$
f\times g:X_1\times X_2\longrightarrow Y_1\times Y_2
$$

is the unique map whose projections satisfy

$$
\rho_1\circ(f\times g)=f\circ\pi_1,
\qquad
\rho_2\circ(f\times g)=g\circ\pi_2,
$$

where $\rho_1,\rho_2$ are the output projections. In a category of sets, $(f\times g)(x_1,x_2)=(f(x_1),g(x_2))$.

### 2.3 Lipschitz maps

Let $E$ be a seminormed additive commutative group. A function $r:E\to E$ is **$K$-Lipschitz**, for $K\ge 0$, if

$$
\lVert r(x)-r(y)\rVert\le K\lVert x-y\rVert
$$

for all $x,y\in E$. A seminorm may vanish on nonzero elements, but it retains the triangle inequality and translation-compatible distance needed below.

### 2.4 Functors and natural transformations

A **functor** $F:\mathcal C\to\mathcal D$ assigns an object $F(X)$ to each $X$ and a morphism $F(f):F(X)\to F(Y)$ to each $f:X\to Y$, preserving identities and composition:

$$
F(\operatorname{id}_X)=\operatorname{id}_{F(X)},
\qquad
F(g\circ f)=F(g)\circ F(f).
$$

A **natural transformation** $\eta:F\Rightarrow G$ between functors $F,G:\mathcal C\to\mathcal D$ is a family of maps $\eta_X:F(X)\to G(X)$ such that, for every $f:X\to Y$, the naturality square commutes:

$$
G(f)\circ\eta_X=\eta_Y\circ F(f).
$$

When $\mathcal D=\mathbf{Set}$, these components are ordinary functions. Functors $\mathcal C\to\mathbf{Set}$ and natural transformations between them form a functor category, denoted $[\mathcal C,\mathbf{Set}]$.

## 3. Residual connections as universal products

Let $X$ be an object for which $X\times X$ exists, and let $r:X\to X$ be a residual branch.

**Definition 3.1 (Categorical residual skip).** The residual skip morphism is

$$
s_r=\langle\operatorname{id}_X,r\rangle:X\longrightarrow X\times X.
$$

It represents the moment at which one input is exposed to two downstream paths: an unchanged path and a learned path.

**Theorem 3.2 (Projection laws).** The residual skip morphism satisfies

$$
\pi_1\circ s_r=\operatorname{id}_X
$$

and

$$
\pi_2\circ s_r=r.
$$

**Proof sketch.** These are the defining equations of the product pairing $\langle\operatorname{id}_X,r\rangle$. The first projection selects the identity component and the second selects the residual component. $\square$

The converse is the stronger architectural statement.

**Theorem 3.3 (Universal characterization of a residual skip).** Suppose $c:X\to X\times X$ is any morphism satisfying

$$
\pi_1\circ c=\operatorname{id}_X,
\qquad
\pi_2\circ c=r.
$$

Then

$$
c=s_r.
$$

**Proof sketch.** Product extensionality states that two maps into a product are equal whenever their composites with both projections are equal. The maps $c$ and $s_r$ have identical first projections, both equal to $\operatorname{id}_X$, and identical second projections, both equal to $r$. Hence they coincide. Equivalently, this is the uniqueness clause in the universal property of $X\times X$. $\square$

The theorem says more than “a residual block can be represented by a pair.” It says that the architecture is forced by the two branch specifications. Any candidate wiring exposing exactly the identity and residual branches through the designated projections is the same categorical morphism.

### 3.1 Additive readout

Now specialize to an additive setting. Let $E$ be an additive type and define

$$
a:E\times E\to E,
\qquad a(u,v)=u+v.
$$

**Definition 3.4 (Additive residual block).** The residual block associated with $r:E\to E$ is

$$
B_r=a\circ s_r,
$$

or elementwise,

$$
B_r(x)=x+r(x).
$$

The factorization

$$
E\xrightarrow{\langle\operatorname{id}_E,r\rangle}E\times E
\xrightarrow{a}E
$$

separates branch formation from branch aggregation. The first stage is governed by a product universal property; the second uses additive structure.

### 3.2 Lipschitz certification

**Theorem 3.5 (Residual stability bound).** Let $E$ be a seminormed additive commutative group, let $K\ge 0$, and suppose $r:E\to E$ is $K$-Lipschitz. Then $B_r(x)=x+r(x)$ is $(1+K)$-Lipschitz:

$$
\lVert B_r(x)-B_r(y)\rVert\le(1+K)\lVert x-y\rVert
$$

for all $x,y\in E$.

**Proof.** By commutative-group algebra,

$$
B_r(x)-B_r(y)=(x-y)+(r(x)-r(y)).
$$

The triangle inequality and the $K$-Lipschitz hypothesis give

$$
\begin{aligned}
\lVert B_r(x)-B_r(y)\rVert
&\le \lVert x-y\rVert+\lVert r(x)-r(y)\rVert\\
&\le \lVert x-y\rVert+K\lVert x-y\rVert\\
&=(1+K)\lVert x-y\rVert.
\end{aligned}
$$

Thus the asserted constant is valid. $\square$

**Example 3.6.** On $E=\mathbb R^d$ with any norm, let $r(x)=\alpha x$ for $\alpha\ge 0$. Then $r$ is $\alpha$-Lipschitz and

$$
B_r(x)=(1+\alpha)x.
$$

Its Lipschitz constant is exactly $1+\alpha$. Hence the upper bound is attained by this family for every nonnegative $K=\alpha$.

**Corollary 3.7 (Sequential certificate).** If residual blocks $B_i$ have residual constants $K_i$ for $i=1,\ldots,n$, then their sequential composition is Lipschitz with constant at most

$$
\prod_{i=1}^n(1+K_i).
$$

**Proof sketch.** The Lipschitz constant of a composition is bounded by the product of the component constants. Apply Theorem 3.5 to each block and multiply the resulting bounds. $\square$

## 4. Two-head attention as a natural transformation

Let $\mathcal C$ be a category of contexts and $F:\mathcal C\to\mathbf{Set}$ a representation functor. A context may encode, for example, a graph presentation, a coordinate frame, a resolution, or another structured environment. The function $F(f)$ transports features along a context morphism $f$.

**Definition 4.1 (Two-head feature functor).** Define $H:\mathcal C\to\mathbf{Set}$ on objects by

$$
H(X)=F(X)\times F(X)
$$

and on morphisms $f:X\to Y$ by

$$
H(f)(u,v)=(F(f)(u),F(f)(v)).
$$

**Lemma 4.2.** The assignment $H$ is a functor.

**Proof sketch.** For an identity morphism,

$$
H(\operatorname{id}_X)(u,v)
=(F(\operatorname{id}_X)(u),F(\operatorname{id}_X)(v))
=(u,v).
$$

For composable $f:X\to Y$ and $g:Y\to Z$, functoriality of $F$ gives

$$
\begin{aligned}
H(g\circ f)(u,v)
&=(F(g\circ f)(u),F(g\circ f)(v))\\
&=(F(g)(F(f)(u)),F(g)(F(f)(v)))\\
&=H(g)(H(f)(u,v)).
\end{aligned}
$$

Thus identities and composition are preserved. $\square$

**Definition 4.3 (Head-exchange attention).** For each object $X$, define

$$
\sigma_X:H(X)\to H(X),
\qquad
\sigma_X(u,v)=(v,u).
$$

This operation redirects the first output head to the second input feature stream and the second output head to the first.

**Theorem 4.4 (Naturality of head exchange).** The family $\sigma=\{\sigma_X\}$ is a natural transformation $H\Rightarrow H$. Explicitly, for every $f:X\to Y$,

$$
H(f)\circ\sigma_X=\sigma_Y\circ H(f).
$$

**Proof.** For every $(u,v)\in H(X)$,

$$
(H(f)\circ\sigma_X)(u,v)
=H(f)(v,u)
=(F(f)(v),F(f)(u)).
$$

On the other hand,

$$
(\sigma_Y\circ H(f))(u,v)
=\sigma_Y(F(f)(u),F(f)(v))
=(F(f)(v),F(f)(u)).
$$

The two functions agree on every input, so the square commutes. $\square$

**Corollary 4.5 (Involutivity).** For every object $X$,

$$
\sigma_X\circ\sigma_X=\operatorname{id}_{H(X)}.
$$

**Proof.** Swapping $(u,v)$ twice returns $(u,v)$. $\square$

Theorem 4.4 is an exact equivariance statement. Transporting both heads and then exchanging them gives the same result as exchanging first and transporting second. No coordinates, metrics, probabilities, or learned weights are needed.

The scope of the result should be emphasized. General scaled dot-product attention introduces query, key, and value maps, logits, normalization, and weighted aggregation. Naturality of that larger construction requires compatibility hypotheses for each stage and does not follow merely from Theorem 4.4. The head exchange is a minimal but nontrivial model that makes the commuting requirement transparent.

## 5. Architecture search in a functor category

Let $F,G:\mathcal C\to\mathbf{Set}$ describe input and output representations. A natural transformation $\eta:F\Rightarrow G$ provides, at every context $X$, a map

$$
\eta_X:F(X)\to G(X)
$$

that is compatible with every context morphism. Such transformations are the morphisms from $F$ to $G$ in $[\mathcal C,\mathbf{Set}]$.

**Definition 5.1 (Semantic architecture).** A semantic architecture from $F$ to $G$ is a natural transformation $\eta:F\Rightarrow G$.

This definition makes representation compatibility part of the candidate type rather than a penalty imposed after search.

**Theorem 5.2 (Finite semantic architecture search).** Let $S$ be a nonempty finite set of semantic architectures from $F$ to $G$, and let

$$
L:S\to\mathbb R
$$

be any real-valued loss. Then there exists $\eta_*\in S$ such that

$$
L(\eta_*)\le L(\eta)
$$

for every $\eta\in S$.

**Proof sketch.** The image $L(S)$ is a nonempty finite subset of $\mathbb R$. Every nonempty finite linearly ordered set has a least element. Choose $m=\min L(S)$ and select $\eta_*\in S$ with $L(\eta_*)=m$. Then $L(\eta_*)\le L(\eta)$ for every $\eta\in S$. $\square$

A candidate may also carry syntactic or topological information.

**Definition 5.3 (Topology-aware candidate).** A topology-aware search candidate is a pair

$$
A=(T,\eta),
$$

where $T$ is a feedforward architecture topology and $\eta:F\Rightarrow G$ is its semantic natural transformation.

No particular internal encoding of $T$ is required for the optimization theorem; it is simply data carried by each candidate.

**Theorem 5.4 (Finite topology-aware architecture search).** Let $A$ be a nonempty finite set of topology-aware candidates and let $L:A\to\mathbb R$ be any loss. Then there exists $a_*\in A$ satisfying

$$
L(a_*)\le L(a)
$$

for every $a\in A$.

**Proof sketch.** Apply the same finite minimum principle to the finite image $L(A)$. The additional topology field changes the candidate data but not the order-theoretic argument. $\square$

### 5.1 Exhaustive minimization algorithm

The existence proof has a direct computational realization.

**Algorithm 5.5 (Finite functor-category minimization).** Given a nonempty list $(a_1,\ldots,a_n)$ of distinct or repeated candidates and a loss function $L$:

1. Set $a_*\leftarrow a_1$ and $\ell_*\leftarrow L(a_1)$.
2. For $i=2,\ldots,n$, compute $\ell_i=L(a_i)$.
3. If $\ell_i<\ell_*$, set $a_*\leftarrow a_i$ and $\ell_*\leftarrow\ell_i$.
4. Return $(a_*,\ell_*)$.

**Proposition 5.6 (Correctness and complexity).** Algorithm 5.5 returns a candidate of minimal loss. It performs $n$ loss evaluations and $n-1$ comparisons. Excluding candidate and loss storage, it uses $O(1)$ auxiliary space and $O(n)$ control overhead. If one loss evaluation costs $T_L$, total time is $O(nT_L+n)$.

**Proof sketch.** After processing the first $i$ candidates, maintain the invariant that $a_*$ has minimum loss among them. The invariant is true initially. Comparing the next loss with the incumbent either preserves the incumbent or replaces it by the new minimum. Induction gives the claim at $i=n$. The operation counts follow directly from the loop. $\square$

Ties may be resolved by first occurrence, by a secondary complexity measure, or by retaining all minimizers. The existence theorem is insensitive to tie policy.

## 6. Worked numerical examples

### 6.1 Residual product and stability

Take $E=\mathbb R^2$ with Euclidean norm and

$$
r(x)=Ax,
\qquad
A=\begin{pmatrix}0.3&0\\0&-0.2\end{pmatrix}.
$$

The operator norm of $A$ is $K=0.3$. The product lift is

$$
s_r(x)=(x,Ax),
$$

whose projections return $x$ and $Ax$. Additive readout gives

$$
B_r(x)=(I+A)x
=\begin{pmatrix}1.3&0\\0&0.8\end{pmatrix}x.
$$

The exact Euclidean Lipschitz constant is $1.3$, while Theorem 3.5 gives $1+K=1.3$, so the certificate is exact here.

For $x=(1,-2)$ and $y=(-1,1)$,

$$
x-y=(2,-3),
$$

and

$$
B_r(x)-B_r(y)=(2.6,-2.4).
$$

Thus

$$
\frac{\lVert B_r(x)-B_r(y)\rVert_2}{\lVert x-y\rVert_2}
=\frac{\sqrt{12.52}}{\sqrt{13}}<1.3.
$$

The bound governs every pair even when a particular pair does not attain it.

### 6.2 Naturality square

Let contexts carry vectors and let transport be multiplication by

$$
M=\begin{pmatrix}2&1\\0&-1\end{pmatrix}.
$$

For heads $u=(1,2)$ and $v=(-1,3)$, swapping before transport gives

$$
(Mv,Mu)=((1,-3),(4,-2)).
$$

Transporting before swapping gives the same ordered pair. This equality is independent of the chosen matrix because the same map acts componentwise on both heads.

### 6.3 Finite search

Suppose four natural candidates have losses

$$
0.42,\quad 0.31,\quad 0.37,\quad 0.31.
$$

A linear scan returns the second candidate under first-occurrence tie-breaking. Both the second and fourth are minimizers, with minimum loss $0.31$. The theorem guarantees at least one minimizer; the algorithm specifies which representative is returned.

## 7. Applications and design implications

### 7.1 Modular stability accounting

The residual theorem gives a compositional certificate. Each residual branch can be analyzed locally, after which constants are propagated through sequential composition. This is useful when branches are spectrally normalized or otherwise constrained. The categorical factorization also makes clear where the analytic estimate enters: not in the existence of the product lift, but in additive readout and the seminorm triangle inequality.

### 7.2 Equivariant and representation-consistent modules

Naturality offers a test for architecture components intended to behave uniformly across contexts. Rather than checking a handful of examples, one specifies the class of context morphisms and proves a commuting equation. The two-head exchange theorem is the simplest case. More complex operators can be assembled from known natural components, since identities and composites of natural transformations remain natural.

### 7.3 Constrained architecture search

Searching among arbitrary pointwise functions may admit candidates that behave inconsistently under context changes. Searching in a functor-category hom-set excludes such candidates by construction. This can reduce the semantic search space and clarify what invariance or equivariance is guaranteed before numerical evaluation.

Topology-aware candidates further separate wiring from meaning. The topology can support hardware cost, depth, or parameter-count penalties, while the natural transformation records behavior across contexts. A multiobjective score can combine these quantities into a real-valued loss, after which finite minimization applies unchanged.

## 8. Limitations and discussion

The framework is intentionally foundational. Modeling an architecture as a morphism presupposes a suitable ambient category. Different choices retain different information: sets retain functions, normed spaces retain analytic structure, and categories of equivariant maps retain symmetry constraints. A theorem in one ambient category need not transfer automatically to another.

The residual product characterization describes branching, while the standard residual formula additionally requires an additive readout. Products alone do not provide addition. Likewise, the $(1+K)$ bound is an upper certificate and does not identify the exact constant for every nonlinear branch.

The natural attention theorem treats head exchange. It should not be read as a blanket naturality theorem for learned softmax attention. Query and key operations may introduce inner products or logits whose behavior under representation maps must be studied separately. Softmax normalization also depends on the indexing and action on tokens.

Finally, finite architecture search has an elementary existence proof. The result is valuable as an exact statement about a structured domain, but it does not solve infinite search, continuous parameter training, noisy loss estimation, or generalization. Its algorithm is exhaustive and therefore linear in the number of explicitly supplied candidates; candidate generation may dominate the pipeline.

## 9. Future research

Several directions sharpen the connection between categorical structure and quantitative learning.

First, one may characterize when scaled dot-product softmax attention is natural under group representations. Equivariant query, key, and value maps are plausible ingredients, but the precise hypotheses must control logits, normalization, and the group action.

Second, the residual stability bound invites a general sharpness theorem. Linear scalar residuals show attainment on real normed spaces for each $K\ge0$; a broader formulation can identify exactly which ambient classes and norms preserve this worst case.

Third, architecture search should be invariant under replacing candidates by naturally isomorphic representatives whenever loss is constant on natural-isomorphism classes. This would move search from raw candidates toward equivalence classes of architectures.

Fourth, parallel residual blocks suggest a tensor or product certificate. Under the max norm on a product, blocks with constants $1+K_1$ and $1+K_2$ should have parallel constant bounded by $\max(1+K_1,1+K_2)$, with attainability requiring an explicit construction.

Further work may also incorporate probabilistic kernels, differentiable parameter spaces, monoidal rather than merely cartesian parallelism, and resource-enriched categories whose morphisms carry latency or memory costs.

## 10. Conclusion

Neural architectures admit a concise categorical organization. Sequential modules compose as morphisms, while parallel modules use product maps. A residual skip is not merely pair-shaped: it is the unique product lift with identity and learned projections. Additive readout converts that lift into $x+r(x)$, and a $K$-Lipschitz branch yields a $(1+K)$-Lipschitz block. Two parallel feature streams form a functor, and exchanging their heads is a natural transformation because exchange commutes with every componentwise transport. Semantic architectures are morphisms in a functor category, and every real-valued loss on a nonempty finite candidate set has a minimizer, with or without attached feedforward topology.

Together these results separate wiring, analysis, representation compatibility, and optimization while allowing them to interact. Products govern branching, seminorms govern perturbation growth, naturality governs context consistency, and finite order governs exhaustive selection. This separation provides a principled basis for designing neural systems whose structure can be stated through universal properties and commuting equations rather than diagrams alone.