# Finite Scaled Dot-Product Attention: Stochasticity, Permutation Equivariance, and Compositional Closure

## Abstract

Scaled dot-product attention transforms a finite collection of query, key, and value vectors by exponentiating pairwise query–key scores, normalizing each query row, and averaging the values. This paper develops the elementary but foundational mathematics of this operation in a finite-dimensional setting. We prove that every softmax denominator is positive, every attention weight is positive, and every attention row sums to one. We then establish an exact transport law for attention weights under arbitrary simultaneous relabeling of tokens and derive permutation equivariance of the complete attention output. Two structural consequences follow: attention preserves values that are constant over token positions, and compositions of equivariant token maps remain equivariant. We present direct algorithms and numerical diagnostics for these laws, discuss their relevance to set-valued and sequence-valued learning, and delineate the hypotheses needed for several stronger claims. In particular, equivariance alone does not establish universal approximation; unrelated query and key maps do not automatically yield a symmetric positive-definite kernel; and multiple attention heads do not automatically increase rank. The results isolate the exact, unconditional finite-dimensional guarantees of standard softmax attention and provide a rigorous base for masked, multi-head, stability, kernel, and approximation analyses.

## 1. Introduction

Attention maps a collection of representations to a new collection by data-dependent averaging. Its central operation is now standard: compute all query–key inner products, divide by a scale, apply row-wise softmax, and use the resulting weights to combine value vectors. Although the formula is compact, it encodes several distinct mathematical structures.

First, exponentiation and normalization make each row of the attention matrix a probability vector. Second, the use of all pairwise scores and a symmetric finite sum makes the operation insensitive to arbitrary names assigned to tokens. Third, because the output retains one vector per query token, this insensitivity takes the form of equivariance rather than invariance. Finally, equivariance is stable under composition, which permits local symmetry statements to propagate through layered architectures.

These statements are sometimes grouped informally under the claim that “self-attention is permutation equivariant.” Here we separate the claim into explicit lemmas and prove each one. The separation matters. Positivity justifies division and probabilistic interpretation. Row normalization yields preservation of constants. A transport identity for individual weights supplies the exact mechanism behind output equivariance. The composition theorem then explains which larger architectures inherit the symmetry.

We work over arbitrary finite index sets rather than assuming tokens are numbered consecutively. This emphasizes that token labels are purely representational. Query and key features share one finite coordinate set, while values may occupy another. The scale is allowed to be any real number in the algebraic definitions; positivity of softmax denominators does not depend on its sign, because the real exponential is always positive. In applications one normally chooses a positive scale, most often the square root of query–key dimension.

The contributions are:

1. a complete finite formulation of scaled dot-product softmax attention;
2. positivity of denominators and individual weights on nonempty token sets;
3. exact row-stochasticity;
4. transport of each attention weight under simultaneous token permutation;
5. permutation equivariance of the full attention output;
6. preservation of tokenwise constant values;
7. closure of equivariance under composition;
8. computational procedures for evaluating and testing these identities; and
9. a careful boundary between these established properties and stronger kernel, rank, and approximation claims that require additional assumptions.

## 2. Finite attention

### 2.1. Token and feature spaces

Let $I$ be a finite, nonempty token index set. Let $D$ be a finite query–key feature set and let $E$ be a value feature set. For each token $i\in I$, a query and key are functions

$$
q_i:D\to\mathbb{R},\qquad k_i:D\to\mathbb{R},
$$

and a value is a function

$$
v_i:E\to\mathbb{R}.
$$

After choosing enumerations, these are ordinary vectors. The function notation makes clear that the proofs rely only on finite sums and not on a particular ordering of coordinates.

Let $s\in\mathbb{R}$ be a nonzero scale whenever the score formula is evaluated in ordinary real arithmetic. The conventional choice is $s=\sqrt{|D|}$, which moderates score magnitudes as feature dimension grows. The symmetry arguments themselves depend only on using the same scale before and after relabeling.

### 2.2. Scores, denominators, weights, and outputs

**Definition 2.1 (Scaled dot-product score).** For tokens $i,j\in I$, define

$$
S_{ij}=\frac{\langle q_i,k_j\rangle}{s}
=\frac{1}{s}\sum_{a\in D}q_i(a)k_j(a).
$$

**Definition 2.2 (Softmax denominator).** For each query token $i$, define

$$
Z_i=\sum_{j\in I}\exp(S_{ij}).
$$

**Definition 2.3 (Attention weight).** The weight assigned by query token $i$ to value token $j$ is

$$
W_{ij}=\frac{\exp(S_{ij})}{Z_i}.
$$

**Definition 2.4 (Scaled dot-product attention).** The output at token $i$ and value coordinate $b\in E$ is

$$
A(q,k,v)_i(b)=\sum_{j\in I}W_{ij}v_j(b).
$$

In matrix notation, if $Q$ and $K$ have rows $q_i$ and $k_i$, and $V$ has rows $v_i$, then

$$
A(Q,K,V)=\operatorname{softmax}_{\mathrm{row}}\!\left(\frac{QK^{\mathsf T}}{s}\right)V.
$$

The coordinate definition will be primary because it makes all reindexing steps explicit.

## 3. Probabilistic structure of the attention matrix

### 3.1. Positivity of normalization

**Theorem 3.1 (Positive softmax denominators).** For every token $i\in I$, the softmax denominator satisfies $Z_i>0$.

**Proof sketch.** For every $j\in I$, the exponential $\exp(S_{ij})$ is strictly positive. Since $I$ is nonempty, the finite sum defining $Z_i$ contains at least one strictly positive term. Therefore the sum is strictly positive. $\square$

The nonemptiness hypothesis is essential for strict positivity: an empty sum is zero. In practical attention, a row always ranges over at least one token, but stating the hypothesis isolates the exact mathematical dependency.

**Corollary 3.2 (Positive attention weights).** For every $i,j\in I$, one has $W_{ij}>0$.

**Proof sketch.** The numerator $\exp(S_{ij})$ is positive by positivity of the exponential, and the denominator $Z_i$ is positive by Theorem 3.1. A quotient of positive real numbers is positive. $\square$

Thus unmasked softmax attention gives nonzero mass to every token. Scores can make a weight arbitrarily small, but never exactly zero in exact real arithmetic. Exact sparsity requires masking or a different normalization.

### 3.2. Row-stochasticity

**Theorem 3.3 (Row normalization).** For every query token $i\in I$,

$$
\sum_{j\in I}W_{ij}=1.
$$

**Proof sketch.** Substitute the definition of $W_{ij}$ and factor out the common denominator:

$$
\sum_{j\in I}W_{ij}
=\sum_{j\in I}\frac{\exp(S_{ij})}{Z_i}
=\frac{\sum_{j\in I}\exp(S_{ij})}{Z_i}
=\frac{Z_i}{Z_i}=1.
$$

The final division is valid because $Z_i>0$ by Theorem 3.1. $\square$

Theorems 3.2 and 3.3 say that $W$ is a strictly positive row-stochastic matrix. For fixed $q$ and $k$, attention is therefore a Markov averaging operator acting on each value coordinate.

### 3.3. Convex-geometric consequences

Although the following consequences require no new machinery, they clarify what normalization means.

**Proposition 3.4 (Coordinatewise range bound).** For every output token $i$ and value coordinate $b$,

$$
\min_{j\in I}v_j(b)
\le A(q,k,v)_i(b)
\le \max_{j\in I}v_j(b).
$$

**Proof sketch.** Each output coordinate is a convex combination of the input coordinates because all $W_{ij}$ are nonnegative and sum to one. Multiplying the minimum and maximum inequalities by $W_{ij}$ and summing gives the result. $\square$

**Proposition 3.5 (Convex-hull containment).** For every $i\in I$, the output vector $A(q,k,v)_i$ belongs to the convex hull of $\{v_j:j\in I\}$.

**Proof sketch.** The coefficients in the defining sum for $A(q,k,v)_i$ are positive and sum to one. This is precisely a convex combination. $\square$

These propositions are direct mathematical consequences of positivity and row normalization. They do not imply that an entire transformer is range-preserving, because surrounding linear and nonlinear layers can move vectors outside this hull.

## 4. Permutations and equivariance

### 4.1. Relabeling token-indexed data

Let $\sigma:I\to I$ be a permutation, that is, a bijection from the token set to itself. If $x=(x_i)_{i\in I}$ is any token-indexed family, define its relabeling $\sigma x$ by

$$
(\sigma x)_r=x_{\sigma^{-1}(r)}.
$$

This convention means that the content formerly at $i$ moves to $\sigma(i)$, since

$$
(\sigma x)_{\sigma(i)}=x_i.
$$

The inverse in the definition is not cosmetic: it ensures that permutations act compositionally on data.

**Definition 4.1 (Permutation-equivariant map).** A token-to-token map $F$ is equivariant under $\sigma$ if

$$
F(\sigma x)=\sigma F(x)
$$

for every input $x$. It is fully permutation equivariant if this identity holds for every permutation of $I$.

Equivariance differs from invariance. An invariant map obeys $F(\sigma x)=F(x)$ and typically returns a global summary. An equivariant map retains token-indexed outputs and transports them with the inputs.

### 4.2. Score and denominator transport

Let $q'=\sigma q$ and $k'=\sigma k$. At transported indices,

$$
S'_{\sigma(i),\sigma(j)}
=\frac{\langle q'_{\sigma(i)},k'_{\sigma(j)}\rangle}{s}
=\frac{\langle q_i,k_j\rangle}{s}
=S_{ij}.
$$

For the denominator at the transported query,

$$
\begin{aligned}
Z'_{\sigma(i)}
&=\sum_{r\in I}\exp(S'_{\sigma(i),r})\\
&=\sum_{j\in I}\exp(S'_{\sigma(i),\sigma(j)})\\
&=\sum_{j\in I}\exp(S_{ij})\\
&=Z_i.
\end{aligned}
$$

The second equality is a change of variable $r=\sigma(j)$. Because $\sigma$ is a bijection, this reorders the terms without adding or removing any.

### 4.3. Weight transport

**Theorem 4.2 (Attention-weight transport).** Under simultaneous permutation of queries and keys, every attention weight moves with both token indices:

$$
W'_{\sigma(i),\sigma(j)}=W_{ij}
$$

for all $i,j\in I$.

**Proof sketch.** The score identity gives equality of the exponential numerators, and reindexing the finite denominator sum gives $Z'_{\sigma(i)}=Z_i$. Dividing these equal quantities yields the claim. $\square$

In matrix notation, let $P$ be the permutation matrix corresponding to $\sigma$. Then the theorem says

$$
W'=PWP^{\mathsf T}.
$$

Thus simultaneous relabeling conjugates the attention matrix by the same permutation matrix.

### 4.4. Output equivariance

**Theorem 4.3 (Permutation Equivariance of Scaled Dot-Product Attention).** Let $I$ be a finite token set, and let $\sigma$ be any permutation of $I$. If queries, keys, and values are relabeled simultaneously, then the attention output is relabeled by the same permutation:

$$
A(\sigma q,\sigma k,\sigma v)=\sigma A(q,k,v).
$$

Equivalently, for every $i\in I$ and $b\in E$,

$$
A(\sigma q,\sigma k,\sigma v)_{\sigma(i)}(b)
=A(q,k,v)_i(b).
$$

**Proof sketch.** Write $q'=\sigma q$, $k'=\sigma k$, and $v'=\sigma v$. Reindex the output sum at token $\sigma(i)$ using $r=\sigma(j)$:

$$
\begin{aligned}
A(q',k',v')_{\sigma(i)}(b)
&=\sum_{r\in I}W'_{\sigma(i),r}v'_r(b)\\
&=\sum_{j\in I}W'_{\sigma(i),\sigma(j)}v'_{\sigma(j)}(b)\\
&=\sum_{j\in I}W_{ij}v_j(b)\\
&=A(q,k,v)_i(b).
\end{aligned}
$$

The third line uses Theorem 4.2 and the identity $v'_{\sigma(j)}=v_j$. $\square$

No genericity, distinctness, or probabilistic assumption on the vectors is needed. Repeated tokens, equal scores, negative scores, and arbitrary finite dimensions are all covered. The theorem is exact over real arithmetic.

## 5. Preservation and composition

### 5.1. Constant values

**Theorem 5.1 (Preservation of tokenwise constants).** Suppose $v_j=c$ for every token $j\in I$, where $c:E\to\mathbb{R}$ is a fixed value vector. Then

$$
A(q,k,v)_i=c
$$

for every output token $i$, independently of the queries and keys.

**Proof sketch.** For each coordinate $b$,

$$
A(q,k,v)_i(b)
=\sum_jW_{ij}c(b)
=c(b)\sum_jW_{ij}
=c(b),
$$

where Theorem 3.3 supplies the row sum. Equality in every coordinate gives equality of vectors. $\square$

This theorem can be read as a conservation law for uniform signals. The attention weights may vary dramatically from row to row, but all convex combinations of a single repeated point equal that point.

### 5.2. Closure under stacking

**Theorem 5.2 (Equivariant composition).** Let $F$ and $G$ be token-to-token maps on the same token set. If both are equivariant under a permutation $\sigma$, then their composition $F\circ G$ is equivariant under $\sigma$.

**Proof sketch.** For every input $x$,

$$
(F\circ G)(\sigma x)
=F(G(\sigma x))
=F(\sigma G(x))
=\sigma F(G(x))
=\sigma(F\circ G)(x).
$$

The first equivariance substitution uses $G$ and the second uses $F$. $\square$

By induction, any finite composition of maps equivariant under the same group of permutations remains equivariant. This supplies the basic architectural closure principle for stacks of attention layers and other compatible tokenwise operations.

Residual addition also preserves equivariance: if $F(\sigma x)=\sigma F(x)$, then

$$
\sigma x+F(\sigma x)=\sigma x+\sigma F(x)=\sigma(x+F(x)).
$$

Similarly, a pointwise map applying the same function to every token is equivariant. A complete transformer block remains equivariant only when every included operation—including positional information, masks, and normalization—respects the relevant permutations.

## 6. Algorithms and numerical diagnostics

### 6.1. Stable evaluation

Directly exponentiating large scores can overflow. The standard stable softmax subtracts the maximum score in each row. For row $i$, let

$$
m_i=\max_j S_{ij}.
$$

Then compute

$$
\widetilde W_{ij}
=\frac{\exp(S_{ij}-m_i)}{\sum_\ell\exp(S_{i\ell}-m_i)}.
$$

This equals $W_{ij}$ because the factor $\exp(-m_i)$ cancels between numerator and denominator.

**Algorithm 6.1 (Stable scaled dot-product attention).**

1. Validate that $Q$ and $K$ have the same token count and feature dimension, and that $V$ has the same token count.
2. Compute $S=QK^{\mathsf T}/s$.
3. For each row, subtract its maximum entry.
4. Exponentiate the shifted scores.
5. Divide each exponential row by its row sum to obtain $W$.
6. Return $WV$, optionally together with $W$.

For $n$ tokens, query–key dimension $d$, and value dimension $p$, score construction costs $O(n^2d)$ arithmetic operations, normalization costs $O(n^2)$, and value aggregation costs $O(n^2p)$. Dense storage of the score or weight matrix costs $O(n^2)$.

### 6.2. Equivariance diagnostic

A numerical test can distinguish the exact theorem from floating-point implementation error.

**Algorithm 6.2 (Permutation-equivariance residual).**

1. Compute $Y=A(Q,K,V)$.
2. Choose a permutation represented by an index array $p$ and form $Q'=Q[p]$, $K'=K[p]$, and $V'=V[p]$.
3. Compute $Y'=A(Q',K',V')$.
4. Compare $Y'$ with $Y[p]$ using the maximum absolute entrywise difference.
5. Report

$$
r_{\mathrm{eq}}=\|Y'-Y[p]\|_{\max}.
$$

In exact arithmetic, $r_{\mathrm{eq}}=0$. In floating-point arithmetic, it should be near rounding precision.

Additional diagnostics include

$$
r_{\mathrm{row}}=\max_i\left|\sum_jW_{ij}-1\right|
$$

for row-stochasticity and

$$
r_{\mathrm{const}}=\|A(Q,K,\mathbf{1}c^{\mathsf T})-\mathbf{1}c^{\mathsf T}\|_{\max}
$$

for constant preservation.

### 6.3. Interpretation of numerical tests

Numerical experiments illustrate rather than replace the proofs. Floating-point exponentiation, summation order, and matrix multiplication may produce tiny nonzero residuals. The permutation identity remains an exact real-number statement. The stable implementation also preserves the same mathematical weights, so stabilization does not alter any theorem.

## 7. Applications

### 7.1. Set-valued data

When input objects have no canonical ordering, permutation equivariance prevents arbitrary enumeration from becoming a spurious feature. Point clouds, collections of detected objects, particle systems, and many graph neighborhoods have this character. If the output remains associated with each object, equivariance is appropriate; if a single global prediction is desired, an invariant pooling operation can follow an equivariant stack.

### 7.2. Molecular and physical systems

Atom indices in a molecular data structure are labels rather than observables. Relabeling atoms while carrying all atom features along should relabel atomwise outputs and leave global observables unchanged. Attention’s token symmetry addresses index permutations, though realistic physical models often need additional equivariance under rotations, translations, or reflections.

### 7.3. Language and positional structure

Natural language is ordered. Bare attention without positional signals is fully permutation equivariant and therefore cannot distinguish two inputs that differ only by a simultaneous reordering of token representations. Positional encodings intentionally augment token content so that reordering words without correspondingly reordering their positions changes the input. Causal masks further restrict which keys each query may access. Thus the theorem identifies the baseline symmetry and clarifies how sequence order enters through additional structure.

### 7.4. Distributed sensing

Sensor identifiers may be arbitrary, while sensor features encode meaningful location or modality information. Equivariance ensures that database reindexing alone does not affect the computation. If physical coordinates are included among features and travel with each sensor, the system can still respond to geometry while ignoring arbitrary row order.

## 8. Scope and limitations

### 8.1. Equivariance is not universality

Theorem 4.3 establishes that a single attention operation belongs to the class of permutation-equivariant maps. It does not establish that attention networks are dense in all continuous permutation-equivariant maps. A valid universal approximation theorem must specify at least:

- a compact permutation-invariant input domain;
- the precise architecture class, including widths and number of layers or heads;
- allowable activations and pointwise networks;
- the output representation;
- the topology and approximation norm; and
- a constructive or density argument.

Equivariance is a necessary symmetry-preservation component of such a theorem, not the density argument itself.

### 8.2. Exponential similarities and reproducing kernels

Consider

$$
K(x,y)=\exp\!\left(\frac{q(x)^{\mathsf T}k(y)}{s}\right).
$$

If $q$ and $k$ are unrelated, then generally $K(x,y)\ne K(y,x)$. A real reproducing kernel is expected to be symmetric and positive semidefinite, so no unconditional reproducing-kernel conclusion follows in this generality.

For the symmetric specialization $q=k=\phi$, the kernel

$$
K(x,y)=\exp\!\left(\frac{\langle\phi(x),\phi(y)\rangle}{s}\right)
$$

with $s>0$ is a natural positive-definite candidate. Its power series

$$
K(x,y)=\sum_{m=0}^{\infty}\frac{1}{m!s^m}
\langle\phi(x),\phi(y)\rangle^m
$$

suggests a feature map built from symmetric tensor powers. Establishing the associated Hilbert space requires that additional construction; it is separate from finite permutation equivariance.

### 8.3. Multi-head rank

Adding heads does not automatically increase rank. If two heads have identical attention outputs, concatenation repeats the same columns and contributes no new independent direction. A correct additive rank statement needs an independence condition, such as requiring the column space contributed by a new head to intersect the existing concatenated column space only at zero. Under a direct-sum hypothesis, dimensions—and hence ranks—add. Without it, rank can remain unchanged.

### 8.4. Masks

A mask changes the set of keys available to each query. Full permutation equivariance survives only for permutations preserving the mask relation. For a causal mask on a linearly ordered sequence, arbitrary permutations generally do not preserve which positions precede which others. The relevant symmetry group is therefore much smaller.

## 9. Discussion

The proofs expose a short dependency chain. Positivity of the exponential gives positivity of denominators. Positive denominators justify the normalized weights. The denominator definition gives row sums of one. Reindexing under a bijection gives weight transport. Weight transport and a second reindexing give output equivariance. Row normalization gives constant preservation. Functional substitution gives compositional closure.

This chain is useful for design. If the exponential is replaced by another positive scoring function, most conclusions persist provided normalization remains well-defined. If exact zeros are introduced by a mask, positivity becomes nonnegativity, and symmetry must be restricted to mask-preserving permutations. If normalization is removed, constant preservation and convex-hull containment generally fail. If token-dependent operations do not share parameters or compatible metadata, compositional equivariance can fail even when attention itself remains equivariant.

The finite setting also reveals that equivariance is fundamentally algebraic. No limiting argument, training distribution, or learned parameter assumption is involved. The theorem holds for every finite collection of real vectors. Statistical learning determines which equivariant function is learned; the architecture determines that relabeling symmetry is respected before training begins.

## 10. Future work

Several extensions follow naturally.

First, multi-head attention should be defined as parallel heads followed by concatenation and an output projection. Equivariance should extend headwise and through tokenwise projection. Rank growth, however, should be stated only with explicit direct-sum or independence assumptions.

Second, masking calls for a relation-based formulation. One should prove equivariance under the automorphism group of the mask and characterize the restricted symmetry of causal attention.

Third, the row-stochastic structure supports norm and Lipschitz bounds. Coordinatewise convex-hull containment is immediate, while perturbation bounds require controlling the sensitivity of scores and softmax to changes in queries and keys.

Fourth, the symmetric exponential dot-product kernel can be developed through its power-series feature map and an associated reproducing kernel Hilbert space. The asymmetric query–key case may instead require two feature spaces or a nonsymmetric operator interpretation.

Fifth, approximation theory should combine the established symmetry preservation with a precise constructive density theorem on compact permutation-invariant domains.

Finally, full encoder blocks should incorporate pointwise feed-forward maps, residual connections, and permutation-compatible normalization. The composition theorem then provides the organizing principle for proving symmetry of the complete stack.

## 11. Conclusion

Finite scaled dot-product softmax attention has four exact structural properties. Its weights are strictly positive, each row sums to one, simultaneous token relabeling transports weights and outputs exactly, and constant values are preserved. Equivariant maps remain equivariant when composed, allowing this symmetry to survive through compatible stacks.

These results explain both the power and the limits of the basic mechanism. Attention is intrinsically suited to token collections with arbitrary labels, but positional encodings and masks can deliberately refine its symmetry. Its normalized outputs are convex averages, but richer surrounding layers expand expressivity. Its equivariance is exact, but universality, reproducing-kernel structure, and multi-head rank growth require additional hypotheses and separate arguments. Isolating these boundaries yields a clear mathematical foundation for the next stages of transformer analysis.
