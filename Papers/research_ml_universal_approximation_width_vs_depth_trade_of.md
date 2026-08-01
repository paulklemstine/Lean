# Exact Width–Depth Trade-offs in a ReLU Region-Capacity Model

**Aristotle**  
**August 1, 2026**

## Abstract

We study width–depth trade-offs for rectified linear unit networks through the explicit region-capacity model $C(w,L)=(w+1)^L$, where $w$ is width and $L$ is depth. This model isolates the combinatorial resource underlying many piecewise-affine region-count arguments. We first establish elementary analytic facts for scalar shallow ReLU realizations, including continuity, an exact two-unit representation of the identity, and a three-unit tent map suitable for iterated composition. We then derive exact resource laws. A demand of $m^n$ cells is met at depth $n$ by width $m-1$, and no smaller width can meet it when $m,n>0$. Any finite demand $q$ is met at fixed positive width $w$ by depth $\lceil\log_{w+1}q\rceil$; hence width $n+4$ meets the demand $m^n$ at ceiling-logarithmic depth. Under the resolution encoding $\varepsilon=1/m^n$, these formulas contrast shallow width scaling of order $\varepsilon^{-1/n}$ with deep logarithmic scaling in $1/\varepsilon$. We also prove exact capacity-separation statements: adding one layer strictly increases capacity at positive width; matching a width-$w$, depth-$(L+1)$ architecture with a single layer requires exactly $(w+1)^{L+1}-1$ neurons; and any depth-$L$ competitor matching the deeper architecture must be strictly wider than $w$. We emphasize that these are exact combinatorial capacity results, not a function-independent approximation theorem for arbitrary continuous functions. We conclude with algorithms, numerical examples, applications, and the analytic steps needed to convert capacity bounds into approximation and oscillation lower bounds.

## 1. Introduction

Rectified linear unit networks combine an exceptionally simple activation with a highly nontrivial architecture. The activation is

$$
\rho(x)=\max\{x,0\}.
$$

A ReLU network is piecewise affine: its domain is divided into cells, and on each cell the network agrees with an affine map. This makes the number of available cells a natural combinatorial proxy for expressive capacity. The proxy does not determine where the cells occur, whether every potential cell is realized, or how accurately a given target is approximated. Nevertheless, it captures a basic architectural mechanism: width creates parallel affine alternatives, while depth repeatedly composes and refines them.

This paper analyzes that mechanism in the explicit model

$$
C(w,L)=(w+1)^L.
$$

The virtue of this formula is not that it resolves every analytic question about neural approximation. Its virtue is that it makes a useful part of the width–depth trade-off exact. For a prescribed cell demand, one can compute a sufficient depth, identify exact shallow widths in important parameter regimes, and quantify the cost of flattening a deep architecture.

The distinction between a capacity theorem and an approximation theorem is essential. A claim that every continuous function on $[-1,1]^n$ has a common approximation rate depending only on $n$ and the tolerance is generally too strong: continuity gives each function a modulus of continuity, but no single modulus works uniformly for all continuous functions. Quantitative rates require additional regularity, such as a Lipschitz bound, or must depend on the individual target. Accordingly, our error parameter enters through an explicitly defined cell demand. This yields a precise architectural scaling law while avoiding an unjustified analytic inference.

Our principal findings are as follows.

1. Scalar shallow ReLU networks are continuous; two ReLU units represent the identity exactly; and three shifted units form a tent map with values $0,1,0$ at $0,1,2$.
2. Capacity is monotone in width and depth.
3. For positive integers $m$ and $n$, width $m-1$ at depth $n$ has exactly $m^n$ cells of model capacity, and no smaller width reaches that demand.
4. Every finite demand $q$ is met at width $w>0$ by depth $\lceil\log_{w+1}q\rceil$. In particular, width $n+4$ meets demand $m^n$ at depth $\lceil\log_{n+5}(m^n)\rceil$.
5. At positive width, an additional layer strictly increases capacity. A one-layer architecture matching width $w$ and depth $L+1$ requires exactly $(w+1)^{L+1}-1$ neurons.
6. More generally, a depth-$L$ architecture matching a width-$w$, depth-$(L+1)$ architecture must have width strictly greater than $w$.

The proofs use only elementary continuity, order, and exponentiation arguments. Their simplicity is a feature: it reveals exactly which conclusions arise from the capacity law and which require further analytic or geometric input.

## 2. ReLU realizations and compositional primitives

### 2.1 The activation and a shallow scalar network

**Definition 2.1 (ReLU).** The rectified linear unit is the function $\rho:\mathbb{R}\to\mathbb{R}$ defined by

$$
\rho(x)=\max\{x,0\}.
$$

**Definition 2.2 (Scalar shallow realization).** Given a nonnegative integer $w$, an output bias $b_0\in\mathbb{R}$, output weights $a_i\in\mathbb{R}$, input weights $c_i\in\mathbb{R}$, and hidden biases $b_i\in\mathbb{R}$ for $1\le i\le w$, define

$$
F(x)=b_0+\sum_{i=1}^{w}a_i\rho(c_i x+b_i).
$$

This is a scalar network with one hidden layer of width $w$.

**Theorem 2.3 (Continuity of shallow ReLU realizations).** Every function $F$ of Definition 2.2 is continuous on $\mathbb{R}$.

**Proof sketch.** The functions $x\mapsto x$ and $x\mapsto 0$ are continuous, so their pointwise maximum $\rho$ is continuous. Each map $x\mapsto c_i x+b_i$ is affine and continuous. Composition with $\rho$, scalar multiplication, finite summation, and addition of $b_0$ preserve continuity. Therefore $F$ is continuous. $\square$

This theorem records an important structural constraint. ReLU networks may have corners, but finite networks do not create jump discontinuities.

### 2.2 Exact identity representation

**Theorem 2.4 (Two-ReLU identity).** For every $x\in\mathbb{R}$,

$$
\rho(x)-\rho(-x)=x.
$$

**Proof sketch.** If $x\ge 0$, then $\rho(x)=x$ and $\rho(-x)=0$. If $x\le 0$, then $\rho(x)=0$ and $\rho(-x)=-x$. Both cases yield the identity. $\square$

This representation shows how paired units can preserve signed linear information even though each individual ReLU clips one half-line.

### 2.3 The tent map and iteration

**Definition 2.5 (Three-ReLU tent map).** Define

$$
T(x)=\rho(x)-2\rho(x-1)+\rho(x-2).
$$

Expanding by intervals gives

$$
T(x)=
\begin{cases}
0, & x\le 0,\\
x, & 0\le x\le 1,\\
2-x, & 1\le x\le 2,\\
0, & x\ge 2.
\end{cases}
$$

**Theorem 2.6 (Tent interpolation).** The tent map satisfies

$$
T(0)=0,\qquad T(1)=1,\qquad T(2)=0.
$$

**Proof sketch.** Substitute $0$, $1$, and $2$ into Definition 2.5 and evaluate each ReLU term. Equivalently, read the values from the interval formula. $\square$

**Definition 2.7 (Iterated tent map).** Let $T^{\circ 0}$ be the identity map and recursively define

$$
T^{\circ(L+1)}=T\circ T^{\circ L}.
$$

**Lemma 2.8 (Successor iteration law).** For every $L\ge 0$ and $x\in\mathbb{R}$,

$$
T^{\circ(L+1)}(x)=T\bigl(T^{\circ L}(x)\bigr).
$$

**Proof sketch.** This is the defining recursion for the iterates. $\square$

The tent construction is included because it exhibits the qualitative mechanism of depth: composition feeds an already folded graph into another fold. Exact oscillation counts for a suitably normalized tent map would connect this mechanism to realizable region lower bounds; here our exact quantitative results concern the abstract capacity model introduced next.

## 3. The region-capacity model

**Definition 3.1 (Region capacity).** For width $w\in\mathbb{N}$ and depth $L\in\mathbb{N}$, define

$$
C(w,L)=(w+1)^L.
$$

The offset by one ensures that width zero has base one, while every positive width has base at least two. The exponent models repeated layerwise refinement.

### 3.1 Monotonicity

**Theorem 3.2 (Width monotonicity).** If $w_1\le w_2$, then for every $L\in\mathbb{N}$,

$$
C(w_1,L)\le C(w_2,L).
$$

**Proof sketch.** From $w_1\le w_2$ we obtain $w_1+1\le w_2+1$. Raising nonnegative integers to the same natural power preserves order. $\square$

**Theorem 3.3 (Depth monotonicity).** If $L_1\le L_2$, then for every $w\in\mathbb{N}$,

$$
C(w,L_1)\le C(w,L_2).
$$

**Proof sketch.** The base $w+1$ is at least one. Powers of a natural number at least one are nondecreasing in their exponent. $\square$

These results formalize the minimum consistency expected of a capacity measure: adding neurons or layers cannot decrease the modeled number of available cells.

## 4. Exact capacity for grid-scale demands

A standard dimensional heuristic divides each of $n$ coordinate directions into $m$ pieces. The resulting Cartesian grid contains $m^n$ cells. We encode that quantity directly.

**Definition 4.1 (Approximation-cell demand).** For $n,m\in\mathbb{N}$, define

$$
Q(n,m)=m^n.
$$

The name indicates an intended approximation interpretation, but $Q$ itself is purely combinatorial. To infer an error estimate from it, one must separately prove that the target function is well approximated on a partition of this resolution.

**Theorem 4.2 (Exact width for a power demand).** If $m>0$, then

$$
C(m-1,n)=m^n=Q(n,m).
$$

**Proof sketch.** Positive $m$ implies $(m-1)+1=m$ in natural-number arithmetic. Substitution into the capacity definition gives $C(m-1,n)=m^n$. $\square$

**Theorem 4.3 (Shallow width lower bound).** Let $m,n,w\in\mathbb{N}$ with $m>0$ and $n>0$. If

$$
m^n\le C(w,n),
$$

then

$$
m-1\le w.
$$

**Proof sketch.** Suppose instead that $w<m-1$, equivalently $w+1<m$. Since $n>0$, strict order of the bases implies strict order of their powers:

$$
(w+1)^n<m^n.
$$

This contradicts $m^n\le C(w,n)=(w+1)^n$. Thus $m\le w+1$, which is equivalent to $m-1\le w$. $\square$

The positivity of $n$ is necessary for the lower-bound argument: when $n=0$, every positive base raised to the zeroth power equals one, so the base cannot be recovered from its power.

**Theorem 4.4 (Monotonicity of cell demand).** If $m_1\le m_2$, then for every $n\in\mathbb{N}$,

$$
Q(n,m_1)\le Q(n,m_2).
$$

**Proof sketch.** This is monotonicity of the map $m\mapsto m^n$ on the natural numbers. $\square$

### 4.1 Error-scale interpretation

Suppose a separate approximation argument associates the resolution parameter $m$ with the error scale

$$
\varepsilon=\frac{1}{m^n}.
$$

Then

$$
m=\varepsilon^{-1/n}.
$$

The exact width $m-1$ in Theorem 4.2 therefore behaves as

$$
w=\varepsilon^{-1/n}-1=O(\varepsilon^{-1/n}).
$$

This rate is conditional on the encoded demand $Q(n,m)$. It does not assert that every continuous target has this approximation rate. The role of the model is to answer the architectural question: once $m^n$ cells are required, what width and depth resources meet that requirement?

## 5. Logarithmic depth at fixed width

For integers $b\ge 2$ and $q\in\mathbb{N}$, define the ceiling logarithm $\lceil\log_b q\rceil$ as the least natural number $d$ satisfying $q\le b^d$. This definition also handles small demands without introducing real logarithms.

**Theorem 5.1 (Logarithmic depth suffices).** Let $w,q\in\mathbb{N}$ with $w>0$. Then

$$
q\le C\bigl(w,\lceil\log_{w+1}q\rceil\bigr).
$$

**Proof sketch.** Since $w>0$, the base $w+1$ is at least two. By the defining property of the ceiling logarithm,

$$
q\le (w+1)^{\lceil\log_{w+1}q\rceil}.
$$

The right-hand side is precisely the stated capacity. $\square$

**Corollary 5.2 (Fixed width $n+4$).** For all $n,m\in\mathbb{N}$,

$$
Q(n,m)\le C\left(n+4,\left\lceil\log_{n+5}Q(n,m)\right\rceil\right).
$$

**Proof sketch.** Apply Theorem 5.1 with $w=n+4$ and $q=Q(n,m)$. The chosen width is always positive, and $w+1=n+5$. $\square$

Because $Q(n,m)=m^n$, the depth in this corollary is

$$
D=\left\lceil\log_{n+5}(m^n)\right\rceil.
$$

Under $\varepsilon=1/m^n$, this becomes

$$
D=\left\lceil\log_{n+5}(1/\varepsilon)\right\rceil=O(\log(1/\varepsilon)).
$$

The comparison with Section 4 is now exact within the model. Meeting demand $m^n$ at depth $n$ uses the exact width $m-1$, while meeting it at fixed width $n+4$ uses ceiling-logarithmic depth. Width changes the base of $C(w,L)$; depth occupies its exponent.

## 6. Exact depth separation in capacity

### 6.1 Strict gain from one layer

**Theorem 6.1 (Strict depth growth).** For $w>0$ and every $L\in\mathbb{N}$,

$$
C(w,L)<C(w,L+1).
$$

**Proof sketch.** By the power recursion,

$$
C(w,L+1)=(w+1)^{L+1}=(w+1)^L(w+1).
$$

The first factor is at least one, and $w+1\ge 2$. Multiplication by $w+1$ therefore strictly increases the positive value $(w+1)^L$. $\square$

At width zero the strict statement would fail, since $C(0,L)=1$ for every $L$. This explains the positive-width hypothesis.

### 6.2 Flattening to one layer

**Theorem 6.2 (Exponential shallow-size lower bound).** Suppose a one-layer architecture of width $v$ matches or exceeds the capacity of a width-$w$, depth-$(L+1)$ architecture:

$$
C(w,L+1)\le C(v,1).
$$

Then

$$
v\ge (w+1)^{L+1}-1.
$$

**Proof sketch.** Since $C(v,1)=v+1$, the matching condition is

$$
(w+1)^{L+1}\le v+1.
$$

Subtracting one in natural-number order yields the result. $\square$

**Theorem 6.3 (Sharpness of the shallow bound).** For every $w,L\in\mathbb{N}$,

$$
C\bigl((w+1)^{L+1}-1,1\bigr)=C(w,L+1).
$$

**Proof sketch.** The quantity $(w+1)^{L+1}$ is at least one, so adding one after subtracting one restores it. Therefore

$$
C\bigl((w+1)^{L+1}-1,1\bigr)
=\bigl((w+1)^{L+1}-1\bigr)+1
=(w+1)^{L+1}.
$$

The final expression equals $C(w,L+1)$. $\square$

Together, Theorems 6.2 and 6.3 identify the exact one-layer width needed to match the deeper capacity. For fixed positive $w$, this width grows exponentially in $L$.

### 6.3 Losing one layer forces extra width

**Theorem 6.4 (Power lower bound for neighboring depths).** Let $w>0$. If a depth-$L$ architecture of width $v$ matches the capacity of a width-$w$, depth-$(L+1)$ architecture, so that

$$
C(w,L+1)\le C(v,L),
$$

then

$$
w<v.
$$

**Proof sketch.** Assume for contradiction that $v\le w$. Width monotonicity gives

$$
C(v,L)\le C(w,L).
$$

Strict depth growth gives

$$
C(w,L)<C(w,L+1).
$$

Combining these inequalities contradicts $C(w,L+1)\le C(v,L)$. Hence $v>w$. $\square$

This theorem is weaker numerically than solving the power inequality for $v$, but stronger conceptually than mere nondecrease: an additional layer cannot be offset while retaining the same or a smaller width.

## 7. Algorithms

### 7.1 Minimal depth for a prescribed demand

Given positive width $w$ and demand $q$, the minimal model depth is the least $d$ such that $(w+1)^d\ge q$. It can be computed without floating-point logarithms.

**Algorithm 7.1 (Integer ceiling-logarithmic depth).** Initialize $d=0$ and $p=1$. While $p<q$, replace $p$ by $p(w+1)$ and increment $d$. Return $d$.

**Correctness.** After $d$ iterations, the invariant is $p=(w+1)^d$. The loop stops exactly when $q\le (w+1)^d$. Because all earlier powers were below $q$, the returned $d$ is minimal.

**Complexity.** The loop performs $\lceil\log_{w+1}q\rceil$ iterations. With unit-cost integer arithmetic its time complexity is $O(\log_{w+1}q)$ and auxiliary storage is $O(1)$. With bit complexity included, multiplication costs grow with the bit length of $q$.

### 7.2 Exact shallow equivalent

**Algorithm 7.2 (Capacity-preserving one-layer flattening).** Given $w,L\in\mathbb{N}$, compute $q=(w+1)^{L+1}$ and return $v=q-1$.

**Correctness.** Theorem 6.3 gives $C(v,1)=C(w,L+1)$.

**Complexity.** Exponentiation by repeated squaring uses $O(\log L)$ integer multiplications, with output bit length $\Theta((L+1)\log(w+1))$. The result may be exponentially large as an integer value even though its binary representation is only linear in $L$ for fixed $w$.

## 8. Numerical illustrations

Consider dimension $n=2$ and resolution $m=8$. The demand is

$$
Q(2,8)=8^2=64.
$$

At depth $n=2$, the exact width is $m-1=7$, and indeed

$$
C(7,2)=8^2=64.
$$

At fixed width $n+4=6$, the base is $7$. The least depth satisfying $7^D\ge 64$ is $D=3$, since $7^2=49<64\le343=7^3$.

For $n=3$ and $m=10$, the demand is $1000$. The exact depth-$3$ width is $9$:

$$
C(9,3)=10^3=1000.
$$

At width $n+4=7$, the base is $8$, and depth $4$ suffices because

$$
8^3=512<1000\le4096=8^4.
$$

For depth separation, take $w=3$ and $L+1=5$. The deep capacity is

$$
C(3,5)=4^5=1024.
$$

A one-layer network has capacity $v+1$, so the exact matching width is

$$
v=1024-1=1023.
$$

This example makes the flattening cost visible: five layers of model width three correspond, in capacity alone, to a single layer with more than one thousand neurons.

## 9. Applications and interpretation

### 9.1 Architectural budgeting

The formulas can guide preliminary architecture budgets whenever a problem supplies an estimated number of required piecewise-affine cells. If memory or parallel hardware favors width, Theorem 4.2 gives an exact construction for power demands at depth $n$. If width is constrained, Theorem 5.1 converts the same demand into a minimal ceiling-logarithmic depth in the capacity model.

### 9.2 Hierarchical spatial models

Many data sets have multiscale organization: images contain edges, motifs, parts, and objects; control policies divide state space into regimes; physical surrogates refine behavior near interfaces. A cell-demand model does not prove that a network discovers the correct hierarchy, but it explains why depth is a plausible resource for representing hierarchical refinement. Each layer compounds the existing capacity rather than merely adding a fixed number of alternatives.

### 9.3 Interpreting exponential separation

The exponential one-layer lower bound is an exact theorem about matching $C(w,L+1)$. It should not be misread as saying that every function represented by every deep network requires exponentially many shallow neurons. A genuine functional separation needs an explicit family of functions, an upper construction by deep networks, and a lower bound showing that shallow networks cannot approximate those functions within a stated norm and tolerance. Oscillation counts of iterated tent maps are a natural route to such a result.

## 10. Scope and limitations

Three distinctions delimit the present results.

First, capacity is not realization. The value $(w+1)^L$ is the model’s assigned cell budget. It does not claim that every architecture and parameter choice realizes exactly that many nonempty affine regions.

Second, cell sufficiency is not approximation sufficiency. To approximate a target $f$, cells must be positioned and assigned affine values appropriately. A constructive approximation theorem must produce weights and biases and bound the resulting error.

Third, continuity does not imply a universal quantitative rate. On a compact cube, every individual continuous function is uniformly continuous, but different functions can have arbitrarily slow moduli of continuity. Thus a rate depending only on $n$ and $\varepsilon$ cannot be inferred from continuity alone. Lipschitz or Hölder classes provide the regularity needed for common rates.

These limitations are not defects in the capacity analysis; they identify the exact interface between combinatorics and analysis. The present theorems settle the combinatorial side for the chosen model. Further work must prove that a target class generates a given demand and that networks can realize the corresponding approximation.

## 11. Future directions

A first objective is a constructive bounded-width theorem: for $n>0$, a continuous function on $[-1,1]^n$, and $\varepsilon>0$, explicitly build a ReLU network whose hidden widths do not exceed $n+4$ and whose uniform error is below $\varepsilon$. Such a result would connect the fixed-width capacity law to universal approximation, with depth depending on the target’s modulus of continuity.

A second objective is a quantitative theorem for Lipschitz targets. For a $K$-Lipschitz function, a grid argument suggests a shallow width of order $(K/\varepsilon)^n$, up to a dimension-dependent constant. Proving this requires a concrete piecewise-affine interpolant and a network realization with controlled width.

A third objective is a no-uniform-rate theorem for unrestricted continuous functions. One seeks to show that every proposed shallow width schedule can be defeated by a continuous one-dimensional target at some resolution. This would make precise why the cell-demand encoding cannot be promoted to a function-independent approximation rate.

A fourth objective is an exact oscillation theorem for a normalized tent map. The intended statement is that its $L$-fold iterate has exactly $2^L$ maximal affine intervals, while a scalar depth-$D$ network with widths $w_1,\ldots,w_D$ has at most

$$
\prod_{i=1}^{D}(w_i+1)
$$

maximal affine intervals. This would connect a realizable compositional witness to the product structure of region capacity.

Finally, one seeks a functional depth-separation theorem: explicit functions represented by depth $L+1$ networks of polynomial size for which every depth-$L$ approximation within a fixed uniform tolerance has exponential size. Such a theorem requires stability under approximation, not merely exact region counting.

## 12. Conclusion

The region-capacity law

$$
C(w,L)=(w+1)^L
$$

supports a complete and exact arithmetic theory of width–depth trade-offs. Width and depth are both monotone resources, but they act differently: width changes the base, whereas depth changes the exponent. For a power demand $m^n$, width $m-1$ at depth $n$ is exact and minimal. At fixed positive width, ceiling-logarithmic depth reaches every finite demand. Width $n+4$ therefore meets $m^n$ cells at depth $\lceil\log_{n+5}(m^n)\rceil$, yielding a logarithmic dependence on $1/\varepsilon$ under the encoding $\varepsilon=1/m^n$. One extra layer strictly raises capacity, and flattening width $w$, depth $L+1$ into one layer costs exactly $(w+1)^{L+1}-1$ neurons.

These statements isolate the combinatorial core of depth efficiency while preserving the boundary between capacity and approximation. The next step is to cross that boundary with constructive realizations, regularity-sensitive error bounds, and explicit oscillatory witnesses.