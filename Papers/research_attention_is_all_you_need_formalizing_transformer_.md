# Exact Finite Universality of Bilinear-Attention Lookup Networks

**Aristotle**  
**July 28, 2026**

## Abstract

We study a finite mathematical model of attention-based sequence processing. The model isolates three components: a matrix-parametrized bilinear attention score, additive positional encoding, and the learned coordinatewise affine post-transformation associated with normalization layers. We prove the linearity laws of the attention score, exact composition formulas for positional and affine transformations, and an exact universality theorem on finite domains. The universality construction embeds each possible input as a one-hot vector, uses dot-product attention as an equality test, assigns one lookup head to each input, and sums the heads. For any function from a finite input set to a finite-dimensional real output space, the resulting multi-head model equals the target function at every input. Specializing the input set to fixed-length sequences over a finite alphabet yields exact sequence-to-sequence universality. The construction requires one head per possible sequence and is therefore exponential in sequence length; it is an expressivity theorem and an explicit lookup algorithm, not an efficiency result. We distinguish this theorem from continuous universal approximation and from standard softmax attention, discuss computational complexity and applications, and formulate directions toward quantitative softmax approximation and resource-efficient architectures.

## 1. Introduction

Attention mechanisms compare queries with keys and use the resulting scores to control the contribution of values. Their practical implementations include projections, score normalization, multiple heads, residual connections, normalization layers, and feed-forward blocks. Before analyzing that full system, it is useful to isolate a mathematically transparent core and ask exactly what it can represent.

This paper examines linear attention on finite input spaces. A query $q\in\mathbb{R}^d$ and a key $k\in\mathbb{R}^d$ receive the score $q^{\mathsf T}Wk$, where $W$ is a real matrix. Unlike scaled dot-product softmax attention, this score is not exponentiated or normalized. Its fundamental property is bilinearity: it is linear in the query for fixed key and linear in the key for fixed query.

We pair this score with two elementary feature transformations. Additive positional encoding maps $x$ to $x+p$. A coordinatewise affine transformation maps $x_i$ to $s_i x_i+b_i$. The latter is the learned scale-and-bias stage often applied after data-dependent normalization; it does not include centering by the mean or division by the standard deviation. This distinction is essential because the full normalization map is nonlinear, while the isolated learned stage is affine.

Our principal result concerns a finite input type $X$ and a finite set $Y$ of output coordinates. For an arbitrary target function

$$
f:X\longrightarrow\mathbb{R}^{Y},
$$

we construct a multi-head attention model that represents $f$ exactly. Each input $x$ is embedded as the one-hot vector $e_x$. The dot product $e_x\cdot e_a$ equals one precisely when $x=a$ and zero otherwise. A head indexed by $a$ emits $(e_x\cdot e_a)f(a)$; summing over all $a\in X$ leaves exactly $f(x)$. This yields exact finite universality.

For sequences, let $\Sigma$ be a finite alphabet, let $n$ be a fixed input length, and let the output be an $m\times r$ real array. Since $\Sigma^n$ is finite, every map

$$
f:\Sigma^n\longrightarrow\mathbb{R}^{m\times r}
$$

is represented exactly by the construction. The required number of heads is $|\Sigma|^n$.

This conclusion is deliberately narrow. It does not establish uniform approximation of continuous functions on compact subsets of Euclidean space. It does not analyze standard softmax attention. It does not claim an economical network. Rather, it provides an explicit and exact baseline: finite-domain expressivity follows from attention’s ability to perform equality selection.

The remainder of the paper defines the model, proves its algebraic laws, gives the universality construction and algorithm, and discusses scope, complexity, applications, and extensions.

## 2. Mathematical setting

Let $I$ be a finite coordinate set. We identify a vector indexed by $I$ with a function $q:I\to\mathbb{R}$. A matrix $W$ indexed by $I\times I$ acts on a key $k$ by

$$
(Wk)_i=\sum_{j\in I}W_{ij}k_j.
$$

### Definition 2.1 (Bilinear attention score)

For a real matrix $W$ and vectors $q,k\in\mathbb{R}^{I}$, define

$$
B_W(q,k)=\sum_{i\in I}q_i(Wk)_i
=\sum_{i,j\in I}q_iW_{ij}k_j.
$$

Equivalently, in matrix notation, $B_W(q,k)=q^{\mathsf T}Wk$. The ordinary dot-product score is the special case $W=I$.

### Definition 2.2 (Additive positional encoding)

For a position vector $p\in\mathbb{R}^{I}$, define the positional map $P_p:\mathbb{R}^{I}\to\mathbb{R}^{I}$ by

$$
P_p(x)=x+p.
$$

### Definition 2.3 (Coordinatewise affine normalization stage)

For scale and bias vectors $s,b\in\mathbb{R}^{I}$, define $A_{s,b}:\mathbb{R}^{I}\to\mathbb{R}^{I}$ by

$$
A_{s,b}(x)_i=s_i x_i+b_i.
$$

This definition isolates the learned affine stage. Standard layer normalization first subtracts a data-dependent mean and divides by a data-dependent standard deviation; those operations are not included here.

For coordinatewise multiplication we use $\odot$, so $(u\odot v)_i=u_i v_i$.

## 3. Algebra of the architectural components

### Theorem 3.1 (Bilinearity of matrix attention)

For every real matrix $W$, vectors $q,q_1,q_2,k,k_1,k_2\in\mathbb{R}^{I}$, and scalar $c\in\mathbb{R}$, the score satisfies

$$
B_W(q_1+q_2,k)=B_W(q_1,k)+B_W(q_2,k),
$$

$$
B_W(cq,k)=cB_W(q,k),
$$

$$
B_W(q,k_1+k_2)=B_W(q,k_1)+B_W(q,k_2),
$$

and

$$
B_W(q,ck)=cB_W(q,k).
$$

#### Proof sketch

Expand the score as the finite double sum $\sum_{i,j}q_iW_{ij}k_j$. Addition in the query distributes through the factor $q_i$ and through the finite sum, giving the first identity; scalar multiplication factors out of the sum, giving the second. Matrix multiplication is linear in $k$, so the same distributive and scalar-factor arguments establish the final two identities. No convergence issue occurs because $I$ is finite.

### Corollary 3.2 (Mixed linear-combination expansion)

For scalars $a,b\in\mathbb{R}$,

$$
\begin{aligned}
B_W(aq_1+bq_2,k_1+k_2)
={}&a\bigl(B_W(q_1,k_1)+B_W(q_1,k_2)\bigr)\\
&+b\bigl(B_W(q_2,k_1)+B_W(q_2,k_2)\bigr).
\end{aligned}
$$

#### Proof sketch

Apply additivity in the key, then additivity and homogeneity in the query, and collect terms.

The corollary makes explicit all pairwise interactions between query components and key components. It can be used to reason modularly about decomposed representations.

### Theorem 3.3 (Composition of additive positional encodings)

For all $p_1,p_2,x\in\mathbb{R}^{I}$,

$$
P_{p_2}(P_{p_1}(x))=P_{p_1+p_2}(x).
$$

#### Proof sketch

At coordinate $i$, the left side equals $(x_i+p_{1,i})+p_{2,i}$, which by associativity and commutativity equals $x_i+(p_{1,i}+p_{2,i})$, the corresponding coordinate of the right side.

Thus repeated additive encodings remain additive. The position vectors form an additive action on the representation space.

### Theorem 3.4 (Composition of coordinatewise affine stages)

For all scale vectors $s_1,s_2$, bias vectors $b_1,b_2$, and inputs $x$,

$$
A_{s_2,b_2}(A_{s_1,b_1}(x))
=A_{s_2\odot s_1,\,s_2\odot b_1+b_2}(x).
$$

#### Proof sketch

At coordinate $i$, expand the left side:

$$
s_{2,i}(s_{1,i}x_i+b_{1,i})+b_{2,i}
=(s_{2,i}s_{1,i})x_i+(s_{2,i}b_{1,i}+b_{2,i}).
$$

This is exactly the $i$th coordinate of the right side.

This identity provides a fusion rule: two adjacent learned affine stages may be replaced by one without changing the represented function.

### Theorem 3.5 (Affine stage after positional encoding)

For all $s,b,p,x\in\mathbb{R}^{I}$,

$$
A_{s,b}(P_p(x))_i=s_i x_i+(s_i p_i+b_i)
$$

for every $i\in I$. Equivalently,

$$
A_{s,b}\circ P_p=A_{s,\,s\odot p+b}.
$$

#### Proof sketch

Substitute $P_p(x)_i=x_i+p_i$ into the affine definition and distribute $s_i$.

The result shows that, when followed immediately by a fixed coordinatewise affine stage, additive position contributes a predictable adjustment to the effective bias.

## 4. One-hot equality attention

Let $X$ be a finite set. The vector space $\mathbb{R}^{X}$ has one coordinate for each possible input.

### Definition 4.1 (One-hot embedding)

For $x\in X$, define $e_x\in\mathbb{R}^{X}$ by

$$
(e_x)_y=
\begin{cases}
1,&y=x,\\
0,&y\ne x.
\end{cases}
$$

Immediately, $(e_x)_x=1$, while $(e_x)_y=0$ whenever $y\ne x$.

### Lemma 4.2 (One-hot attention tests equality)

For all $x,a\in X$,

$$
\sum_{i\in X}(e_x)_i(e_a)_i
=
\begin{cases}
1,&x=a,\\
0,&x\ne a.
\end{cases}
$$

#### Proof sketch

If $x=a$, the two vectors coincide and have exactly one nonzero coordinate, whose squared value is one. If $x\ne a$, the support of $e_x$ is $\{x\}$ and the support of $e_a$ is $\{a\}$; the supports are disjoint, so every product in the sum is zero.

This lemma converts an ordinary dot product—a bilinear attention score with identity matrix—into an exact equality predicate.

Let $Y$ be a finite set of output coordinates. The desired output space is $\mathbb{R}^{Y}$. Let $f:X\to\mathbb{R}^{Y}$ be arbitrary.

### Definition 4.3 (Lookup head)

For a fixed address $a\in X$, define the head $H_a:X\to\mathbb{R}^{Y}$ by

$$
H_a(x)=\left(\sum_{i\in X}(e_x)_i(e_a)_i\right)f(a).
$$

The key of the head is $e_a$, the query is $e_x$, and the value is the vector $f(a)$.

### Lemma 4.4 (Exact firing law)

For all $a,x\in X$,

$$
H_a(x)=
\begin{cases}
f(a),&x=a,\\
0,&x\ne a,
\end{cases}
$$

where $0$ is the zero vector in $\mathbb{R}^{Y}$.

#### Proof sketch

Apply Lemma 4.2 to the scalar multiplier in Definition 4.3. Multiplication by one preserves $f(a)$, while multiplication by zero yields the zero vector.

### Definition 4.5 (Multi-head lookup model)

Define

$$
M_f(x)=\sum_{a\in X}H_a(x).
$$

There is one head for each possible input address.

### Theorem 4.6 (Exact lookup recovery)

For every function $f:X\to\mathbb{R}^{Y}$ and every $x\in X$,

$$
M_f(x)=f(x).
$$

#### Proof sketch

In the sum $\sum_{a\in X}H_a(x)$, Lemma 4.4 makes every term with $a\ne x$ equal to zero. The unique term with $a=x$ equals $f(x)$. Therefore the sum is $f(x)$.

### Theorem 4.7 (Finite bilinear-attention universality)

Let $X$ and $Y$ be finite sets. Every function $f:X\to\mathbb{R}^{Y}$ is represented exactly by a finite multi-head model whose scores are bilinear dot products between one-hot queries and one-hot keys. Specifically, the model $M_f$ of Definition 4.5 satisfies $M_f=f$ as functions.

#### Proof sketch

Construct $M_f$ from one lookup head per $a\in X$. Theorem 4.6 proves pointwise equality $M_f(x)=f(x)$ for every $x$, which is function equality.

No regularity assumption on $f$ is needed. It may be discontinuous under an externally supplied geometry, non-smooth, or combinatorial, because only its values on the finite set $X$ matter.

## 5. Exact universality for fixed-length sequences

Let $\Sigma$ be a finite alphabet and let $n,m,r$ be nonnegative integers. An input sequence is a function from the position set $\{0,\ldots,n-1\}$ to $\Sigma$; equivalently, it is an element of $\Sigma^n$. An output is an array indexed by an output position $i\in\{0,\ldots,m-1\}$ and a feature coordinate $j\in\{0,\ldots,r-1\}$.

### Theorem 5.1 (Exact finite sequence-to-sequence universality)

For every function

$$
f:\Sigma^n\longrightarrow\mathbb{R}^{m\times r},
$$

there exists a multi-head bilinear-attention lookup model $M_f$ such that, for every input sequence $x\in\Sigma^n$, output position $i$, and feature coordinate $j$,

$$
M_f(x)_{i,j}=f(x)_{i,j}.
$$

A construction is obtained by treating each whole sequence as one element of the finite set $X=\Sigma^n$, treating each pair $(i,j)$ as one output coordinate in $Y$, and applying Theorem 4.7.

#### Proof sketch

The set $\Sigma^n$ is finite because both the alphabet and the position set are finite. Define the vector-valued target $g:X\to\mathbb{R}^{Y}$ by $g(x)_{(i,j)}=f(x)_{i,j}$. Theorem 4.7 supplies $M_g(x)=g(x)$. Evaluating both sides at coordinate $(i,j)$ gives the stated equality.

### Boundary cases

The theorem includes zero-length or zero-width index sets in the standard set-theoretic sense. If the output index set is empty, there are no output coordinates to check. If $n=0$, there is exactly one empty input sequence, provided the usual function-space convention is used. These cases do not alter the construction.

## 6. Constructive algorithm

The proof yields a direct compilation procedure from a finite table of target values to an attention lookup network.

### Algorithm 6.1 (Compilation of a finite function into lookup heads)

**Input:** A finite list of distinct inputs $X=\{a_1,\ldots,a_N\}$ and target vectors $f(a_t)\in\mathbb{R}^{M}$.

**Construction:**

1. Assign coordinate $t$ to input $a_t$.
2. Embed $a_t$ as the standard basis vector $e_t\in\mathbb{R}^{N}$.
3. Create head $t$ with key $e_t$ and value $f(a_t)$.
4. On input $x=a_s$, use query $e_s$.
5. Compute every score $e_s\cdot e_t$.
6. Return the sum $\sum_{t=1}^{N}(e_s\cdot e_t)f(a_t)$.

By orthogonality of the standard basis, the return value is $f(a_s)$.

### Complexity

If one literally stores dense one-hot vectors and computes all dot products, inference costs $O(N^2+NM)$ arithmetic operations: $N$ heads each perform a length-$N$ dot product and scale an $M$-vector. Exploiting one-hot sparsity reduces score evaluation to $O(N)$ equality or coordinate checks, followed by $O(NM)$ naive weighted accumulation. Exploiting the theorem’s unique active head reduces actual lookup to $O(M)$ after an address has been identified, although that optimized implementation bypasses the explicit parallel-attention calculation.

Storage for the values is $O(NM)$. The conceptual keys require $O(N^2)$ dense storage but only $O(N)$ symbolic storage because each key is determined by its index.

For sequences over an alphabet of size $v=|\Sigma|$, the input count is

$$
N=v^n.
$$

Hence the head count and value-table storage grow exponentially with sequence length. The theorem establishes representational completeness, not parameter efficiency.

## 7. Numerical illustrations

Consider $X=\{0,1,2\}$. The one-hot vectors are

$$
e_0=(1,0,0),\qquad e_1=(0,1,0),\qquad e_2=(0,0,1).
$$

Their Gram matrix is the identity:

$$
\begin{pmatrix}
e_0\cdot e_0&e_0\cdot e_1&e_0\cdot e_2\\
e_1\cdot e_0&e_1\cdot e_1&e_1\cdot e_2\\
e_2\cdot e_0&e_2\cdot e_1&e_2\cdot e_2
\end{pmatrix}
=
\begin{pmatrix}
1&0&0\\
0&1&0\\
0&0&1
\end{pmatrix}.
$$

Let

$$
f(0)=(2,-1),\quad f(1)=(0,3),\quad f(2)=(4,5).
$$

For query $e_1$, the three heads emit $0$, $f(1)$, and $0$, respectively, so the sum is $(0,3)$. The same argument holds for the other two inputs.

For a sequence example, take $\Sigma=\{0,1\}$ and $n=3$. There are $2^3=8$ sequences. Define an output with two coordinates: parity and the number of ones,

$$
f(x)=\left(\left(\sum_{t=0}^{2}x_t\right)\bmod 2,\ \sum_{t=0}^{2}x_t\right).
$$

The lookup construction uses eight heads and reproduces this table exactly. Although parity and counting admit far more efficient algorithms, this example emphasizes that the construction requires no knowledge of their structure.

For affine fusion, choose

$$
s_1=(2,-1),\quad b_1=(1,3),\quad s_2=(4,5),\quad b_2=(-2,1).
$$

The fused parameters are

$$
s_2\odot s_1=(8,-5),
$$

and

$$
s_2\odot b_1+b_2=(2,16).
$$

Thus two stages reduce to $x\mapsto(8x_1+2,-5x_2+16)$.

## 8. Applications and interpretation

### 8.1 Finite classification and structured output

A classifier with a finite input domain is a special case with output coordinates representing class scores. More generally, $Y$ may index positions, labels, control signals, or physical quantities. The construction handles them uniformly as coordinates of a real vector.

### 8.2 Bounded symbolic transduction

Fixed-length strings over finite alphabets include bounded translation tables, finite protocol messages, and local symbolic rewriting systems. Every such transduction has an exact lookup representation. The theorem therefore gives a universal finite baseline against which compressed symbolic or neural mechanisms may be compared.

### 8.3 Control and decision tables

A finite state observation can serve as $x$, while $f(x)$ contains action scores or real control outputs. Exact recovery ensures that no approximation error is introduced relative to the supplied decision table. The exponential scaling remains the limiting factor when observations are factored into many components.

### 8.4 Architectural simplification

The positional and affine composition theorems justify exact graph rewrites. Consecutive additive position shifts can be merged. Consecutive coordinatewise affine stages can be fused. A positional shift immediately followed by an affine stage can be absorbed into its bias. Such transformations may aid interpretation or implementation, provided no intervening nonlinear operation changes the composition.

### 8.5 Memory as attention

The universality theorem identifies an elementary mechanism: address, compare, gate, and sum. One-hot keys are addresses, dot products are exact comparators, scalar multiplication gates stored values, and summation aggregates the unique selected value. In this model, attention is content-addressed memory with collision-free addresses.

## 9. Scope and limitations

Several qualifications prevent overinterpretation.

First, the score is bilinear linear attention. Standard transformer attention usually computes scaled scores, applies softmax across keys, and forms a convex combination of values. Softmax weights are strictly positive for finite scores, so exact zero-one selection generally requires a limiting argument or special masking. The exact selector used here does not directly establish an exact theorem for ordinary finite-temperature softmax.

Second, the input universe is finite. Continuous universal-approximation theorems ask whether a model class approximates every continuous map on a compact domain to arbitrary tolerance. Those theorems require topology, continuity, an error norm, and a parameterized approximation argument. None of those ingredients is needed for finite lookup, and none follows automatically from it.

Third, the entire sequence is treated as one atomic input to the one-hot embedding. The construction does not derive sequence-level behavior from token-level attention with shared projections. It shows that attention heads can act as a perfect lookup bank once whole-sequence addresses are available.

Fourth, the affine normalization stage is not full layer normalization. Mean subtraction and variance normalization depend on the input and are nonlinear. The affine fusion formulas apply only to fixed learned scales and biases.

Fifth, the resource count is exponential: $|\Sigma|^n$ heads for length-$n$ sequences over $\Sigma$. Practical architectures seek shared representations that exploit compositional, statistical, or algorithmic structure. The theorem says every table can be stored, not that every table can be stored compactly.

These limitations sharpen rather than diminish the result. They identify exactly what has been established and what further hypotheses and techniques are needed for broader claims.

## 10. Future work

A first extension is quantitative softmax selection. If correct and incorrect keys have a positive score margin, scaling the logits makes the softmax weight of the correct key approach one. Explicit bounds could translate the exact lookup proof into an $\varepsilon$-approximation theorem with a required temperature or score scale.

A second direction is continuous universality. One would specify compact sequence domains, continuous target maps, and a uniform norm, then combine finite discretization or function-algebra methods with an architecture capable of interpolation. The result would be conceptually distinct from finite lookup.

A third direction is full normalization. Introducing empirical mean and variance would permit proofs of shift invariance and positive-scale invariance, together with careful treatment of zero variance and stabilizing constants.

A fourth direction is standard multi-head plumbing: learned query, key, and value projections; head concatenation; output projection; residual connections; and feed-forward blocks. Dimension-safe formulations would make composition properties explicit.

A fifth direction concerns permutation structure. Without positional information, tokenwise shared attention often exhibits permutation equivariance. Additive positional encodings break or modify that symmetry. A precise characterization would connect the elementary positional composition law to architectural invariance.

Finally, the central complexity question is compression. Which classes of sequence functions can be represented with substantially fewer than $|\Sigma|^n$ heads? Upper bounds could exploit factorization, depth, and shared features; lower bounds could identify functions that inherently require large width or depth under specified architectural restrictions.

## 11. Conclusion

Bilinear attention has a simple algebra: it obeys superposition in both queries and keys. Additive positional encodings compose by vector addition. Learned coordinatewise affine stages compose by multiplying scales and transforming biases, and positional shifts can be absorbed into effective affine biases.

On a finite domain, one-hot embeddings turn dot-product attention into exact equality testing. One lookup head per possible input stores the corresponding target output; summing the heads recovers the target because exactly one head fires. Consequently, every function from a finite input set to a finite-dimensional real output space has an exact bilinear-attention representation. Fixed-length sequences over a finite alphabet are a direct specialization.

The construction is transparent and exhaustive, but exponential. It should be read as a precise expressivity baseline: attention can implement perfect finite memory. The next mathematical challenge is to replace exhaustive memory with structured, quantitatively controlled, and resource-efficient computation.
