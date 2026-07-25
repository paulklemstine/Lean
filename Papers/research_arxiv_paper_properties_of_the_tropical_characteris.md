# Concavity Certificates for Principal Tropical Characteristic Coefficients

**Aristotle**
**25 July 2026**

## Abstract

We study coefficient sequences obtained by maximizing integer-valued principal weights over subsets of fixed cardinality, the motivating case being tropical permanents of principal submatrices in max-plus spectral theory. The matrix-specific hypothesis is a symmetric two-set exchange inequality: whenever principal index sets $S$ and $T$ have cardinalities differing by two, there exist two intermediate-cardinality sets $U$ and $V$ such that $w(S)+w(T)\leq w(U)+w(V)$. We prove that this single hypothesis forces discrete concavity of the cardinality-layer maxima $c_k$, namely $2c_k\geq c_{k-1}+c_{k+1}$ at every interior index. We show that midpoint concavity is equivalent to antitonicity of consecutive slopes and derive the global inequality $c_{j+1}-c_j\leq c_i-c_{i-1}$ whenever $1\leq i\leq j<n$. The hierarchy is invariant under affine changes $c_k\mapsto c_k+ak+b$. Conversely, one failed midpoint inequality is an explicit obstruction to realization by any system with the exchange property. We provide strict quadratic and nonrealizable spike examples, linear-time recognition algorithms, and a careful account of the boundary between the abstract exchange theorem and its intended symmetric-matrix application.

## 1. Introduction

In max-plus algebra, the operations are

$$
x\oplus y=\max(x,y),\qquad x\odot y=x+y.
$$

Matrix expressions formed with these operations encode optimization over weighted combinatorial structures. In particular, the tropical permanent of a square matrix is the maximum weight of a permutation, or equivalently of a directed cycle cover. Principal tropical permanents therefore attach an optimization value to every principal index set.

For an $n\times n$ matrix $A=(a_{ij})$ and an index set $S$, the principal submatrix $A[S]$ uses rows and columns in $S$. Its max-plus tropical permanent is

$$
\operatorname{tper}(A[S])
 =\max_{\sigma\in\operatorname{Sym}(S)}\sum_{i\in S}a_{i,\sigma(i)}.
$$

For each cardinality $k$, the corresponding leading principal coefficient is

$$
c_k=\max_{S\subseteq [n],\ |S|=k}\operatorname{tper}(A[S]).
$$

Depending on the convention used to order the tropical characteristic polynomial, $c_k$ may be described as the coefficient of complementary degree. The order convention is immaterial here; our object is the cardinality-indexed sequence $(c_k)_{k=0}^n$.

The key issue is not polynomial expansion but exchange between principal sets. We therefore separate the coefficient argument from the matrix-specific combinatorics. We consider an arbitrary integer-valued principal weight $w(S)$ on subsets of a finite ground set, require that each layer maximum is attained, and assume a two-set exchange inequality between layers whose cardinalities differ by two. This abstraction exposes a compact proof of coefficient concavity and clarifies the exact hypothesis needed.

Our main conclusions are as follows.

1. **Local concavity.** Every interior coefficient satisfies $2c_k\geq c_{k-1}+c_{k+1}$.
2. **Slope characterization.** Local concavity at $k$ is equivalent to $c_{k+1}-c_k\leq c_k-c_{k-1}$.
3. **Global slope order.** For $1\leq i\leq j<n$, one has $c_{j+1}-c_j\leq c_i-c_{i-1}$.
4. **Affine invariance.** Adding $ak+b$ to the $k$th coefficient preserves the complete concavity hierarchy.
5. **Obstruction.** Any strict reverse midpoint inequality rules out realization by a principal exchange system.

These are conditional recognition results: the exchange property is an explicit hypothesis. The results apply directly whenever symmetric tropical principal permanents are known to satisfy that property, but no unconditional cycle-exchange theorem for all symmetric matrices is asserted here. This distinction identifies a concrete target for further work.

## 2. Max-plus and principal-permanent background

### 2.1. Tropical translation

The elementary distributive identity relevant to coefficient shifts is

$$
a+\max(x,y)=\max(a+x,a+y).
$$

Thus translating every candidate score by a common amount translates their maximum by the same amount. Iterating this observation over finite maxima explains why uniform changes in tropical weights produce affine changes in cardinality-indexed coefficients.

### 2.2. Tropical permanent

Let $B=(b_{ij})$ be a square real matrix indexed by a finite set $S$. Its tropical permanent is

$$
\operatorname{tper}(B)=\max_{\sigma:S\to S\text{ bijective}}
\sum_{i\in S}b_{i,\sigma(i)}.
$$

A permutation decomposes into directed cycles, so each summand is the weight of a cycle cover of $S$. Unlike an ordinary determinant, no signs occur and no cancellation is possible.

When $A$ is symmetric, reversing a directed edge does not alter its weight because $a_{ij}=a_{ji}$. This makes cycle reversal a plausible source of exchange operations. Our theorem requires only the resulting inequality, not a particular construction of the intermediate sets.

### 2.3. Principal coefficient systems

Let $E$ be a finite set of cardinality $n$. A **principal coefficient system** consists of:

- a weight function $w:2^E\to\mathbb Z$;
- a sequence $c_0,c_1,\ldots,c_n$ of integers;
- the upper-bound property $w(S)\leq c_{|S|}$ for every $S\subseteq E$;
- attainment: for each $0\leq k\leq n$, some $S$ with $|S|=k$ satisfies $w(S)=c_k$; and
- the **two-set principal exchange property**: whenever $|T|=|S|+2$, there exist $U,V\subseteq E$ with

$$
|U|=|V|=|S|+1
$$

and

$$
w(S)+w(T)\leq w(U)+w(V).
$$

The first two bullet points identify $c_k$ with the maximum of $w$ on the $k$th cardinality layer. We state upper bounds and attainment separately because those are precisely the facts used in the proof. For principal tropical permanents, one takes $w(S)=\operatorname{tper}(A[S])$.

### 2.4. Discrete concavity

A finite integer sequence $(c_k)_{k=0}^n$ is **discretely concave at an interior index** $k$, where $1\leq k<n$, if

$$
2c_k\geq c_{k-1}+c_{k+1}.
$$

It is **discretely concave through order** $n$ if this holds at every interior index. Define the consecutive slopes

$$
d_k=c_k-c_{k-1}\qquad (1\leq k\leq n).
$$

Discrete concavity is the assertion that the marginal increments $d_k$ do not increase.

## 3. The exchange-to-concavity theorem

### Theorem 3.1 (Principal Exchange Implies Coefficient Concavity)

Let $E$ be a finite set of cardinality $n$, and let $(w,c)$ be a principal coefficient system on $E$ satisfying the two-set principal exchange property. Then for every $k$ with $1\leq k<n$,

$$
2c_k\geq c_{k-1}+c_{k+1}.
$$

#### Proof sketch

Fix an interior index $k$. By attainment, choose $S,T\subseteq E$ such that

$$
|S|=k-1,\qquad w(S)=c_{k-1},
$$

and

$$
|T|=k+1,\qquad w(T)=c_{k+1}.
$$

The cardinalities differ by two. Exchange supplies sets $U$ and $V$, each of cardinality $k$, for which

$$
w(S)+w(T)\leq w(U)+w(V).
$$

The layer upper bound gives $w(U)\leq c_k$ and $w(V)\leq c_k$. Consequently,

$$
c_{k-1}+c_{k+1}
=w(S)+w(T)
\leq w(U)+w(V)
\leq 2c_k,
$$

which is the desired inequality.

### Remark 3.2 (Minimal input)

The proof uses no positivity of weights, no inclusion relation between $S$ and $T$, and no matrix entries. It requires only finite-layer attainment, layerwise maximality, and exchange across a cardinality gap of two. In particular, negative tropical weights create no difficulty.

### Corollary 3.3 (Conditional symmetric-matrix consequence)

Let $A$ be a finite symmetric max-plus matrix. Suppose its principal tropical-permanent weight function satisfies the two-set principal exchange property. Then the maxima of its principal tropical permanents by cardinality form a discretely concave sequence.

#### Proof sketch

Use $w(S)=\operatorname{tper}(A[S])$. Finiteness gives attainment of each cardinality-layer maximum, and the assumed matrix exchange property gives the remaining hypothesis of Theorem 3.1.

The conditional wording is essential. The abstract argument isolates exchange as the matrix-specific combinatorial burden rather than silently assuming it for every possible symmetric tropical model.

## 4. Slopes and global consequences

### Proposition 4.1 (Midpoint–Slope Equivalence)

For every integer sequence $(c_k)$ and every $k\geq 1$, discrete concavity at $k$ is equivalent to

$$
c_{k+1}-c_k\leq c_k-c_{k-1}.
$$

#### Proof sketch

Subtract $c_k+c_{k-1}$ from the midpoint inequality $2c_k\geq c_{k-1}+c_{k+1}$. Reversing this rearrangement proves the converse.

Thus Theorem 3.1 says exactly that

$$
d_{k+1}\leq d_k
$$

for all interior indices.

### Theorem 4.2 (Global Slope Ordering)

Let $(c_k)_{k=0}^n$ be discretely concave. If $1\leq i\leq j<n$, then

$$
c_{j+1}-c_j\leq c_i-c_{i-1}.
$$

#### Proof sketch

Proposition 4.1 supplies the adjacent chain

$$
d_{i}\geq d_{i+1}\geq\cdots\geq d_{j+1}.
$$

Transitivity yields $d_{j+1}\leq d_i$, which is the stated inequality. Equivalently, one may induct on $j-i$, applying one new local midpoint inequality at each step.

### Corollary 4.3 (Necessary Global Condition for Exchange Realizations)

If $(c_k)$ is the coefficient sequence of a principal coefficient system with exchange, then for every $1\leq i\leq j<n$,

$$
c_{j+1}-c_j\leq c_i-c_{i-1}.
$$

#### Proof sketch

Apply Theorem 3.1 and then Theorem 4.2.

### 4.1. Newton-diagram interpretation

A max-plus tropical polynomial may be written as

$$
p(x)=\max_k(c_k+kx).
$$

Its graph is the upper envelope of affine functions. Breakpoints occur where winning terms change. Pairwise intersections of adjacent terms are controlled by coefficient differences, since

$$
c_{k-1}+(k-1)x=c_k+kx
$$

implies

$$
x=c_{k-1}-c_k=-d_k.
$$

Therefore ordered slopes $d_k$ produce ordered candidate adjacent breakpoints $-d_k$. Strict decrease of $d_k$ yields strict increase of these candidates. Care is needed: a complete statement about which terms actually appear on the envelope may require additional essentiality assumptions. The proven coefficient inequalities nevertheless give the basic Newton-diagram order underlying such analyses.

## 5. Affine invariance

### Theorem 5.1 (Affine Invariance of Discrete Concavity)

Let $(c_k)_{k=0}^n$ be discretely concave, and let $a,b\in\mathbb Z$. Define

$$
c'_k=c_k+ak+b.
$$

Then $(c'_k)_{k=0}^n$ is discretely concave.

#### Proof sketch

At an interior index $k$, calculate

$$
\begin{aligned}
2c'_k-c'_{k-1}-c'_{k+1}
&=2(c_k+ak+b)\\
&\quad-[c_{k-1}+a(k-1)+b]\\
&\quad-[c_{k+1}+a(k+1)+b]\\
&=2c_k-c_{k-1}-c_{k+1}.
\end{aligned}
$$

The affine contribution cancels exactly, so every midpoint deficit is preserved.

### Corollary 5.2 (Uniform Shift of Slopes)

Under the same transformation,

$$
d'_k=d_k+a.
$$

In particular, all pairwise slope-order inequalities are invariant.

#### Proof sketch

Subtract consecutive transformed coefficients:

$$
c'_k-c'_{k-1}=c_k-c_{k-1}+a.
$$

### Discussion

The constant $b$ moves the entire coefficient graph vertically. The linear term $ak$ tilts it. Neither changes discrete curvature. This permits normalization, for example by imposing $c'_0=0$ or setting one selected slope to zero, without altering the concavity certificate.

## 6. Obstructions and examples

### Theorem 6.1 (Single Midpoint Obstruction)

Let $(c_k)_{k=0}^n$ be an integer sequence. If some interior index $k$ satisfies

$$
2c_k<c_{k-1}+c_{k+1},
$$

then $(c_k)$ is not the coefficient sequence of any principal coefficient system satisfying the two-set exchange property.

#### Proof sketch

Every such realization would satisfy Theorem 3.1 at $k$, contradicting the strict reverse inequality.

This is a necessary-condition test, not a sufficiency theorem: passing every midpoint test does not by itself construct a weight system or a symmetric tropical matrix.

### Example 6.2 (Strict quadratic profile)

Define

$$
c_k=-k^2.
$$

Then for every $k\geq 1$,

$$
\begin{aligned}
2c_k-c_{k-1}-c_{k+1}
&=-2k^2+(k-1)^2+(k+1)^2\\
&=2.
\end{aligned}
$$

Hence every interior inequality is strict. The consecutive slopes are

$$
d_k=-k^2+(k-1)^2=1-2k,
$$

namely $-1,-3,-5,\ldots$, and are strictly decreasing.

### Example 6.3 (A spike obstruction)

Consider

$$
(c_0,c_1,c_2,c_3,c_4)=(0,0,10,0,0).
$$

At $k=1$,

$$
2c_1=0<10=c_0+c_2.
$$

Thus the sequence cannot be realized by a principal coefficient system with exchange. It also fails at $k=3$, while the central inequality at $k=2$ holds strongly. This illustrates why every interior index must be checked: a high peak is not itself incompatible with concavity, but the approaches to and departures from the peak may be.

### Example 6.4 (Affine normalization of the quadratic profile)

For integers $a,b$, let

$$
q_k=-k^2+ak+b.
$$

The midpoint deficit remains $2$, and the slopes become

$$
q_k-q_{k-1}=1-2k+a.
$$

The graph is tilted and translated, but its strict curvature is unchanged.

## 7. Algorithms

### 7.1. Midpoint-deficit recognition

Given $m+1$ coefficients $c_0,\ldots,c_m$, compute

$$
\Delta_k=2c_k-c_{k-1}-c_{k+1}
$$

for $1\leq k<m$. The sequence is discretely concave exactly when every $\Delta_k\geq 0$.

**Pseudocode**

```text
MIDPOINT-CERTIFICATE(c[0..m])
    deficits ← empty list
    violations ← empty list
    for k ← 1 to m - 1
        Δ ← 2*c[k] - c[k-1] - c[k+1]
        append (k, Δ) to deficits
        if Δ < 0
            append k to violations
    return deficits, violations
```

The running time is $O(m)$ and the auxiliary space is $O(m)$ if all deficits are retained, or $O(1)$ if only acceptance and the first violation are required.

### 7.2. Global slope audit

Compute $d_k=c_k-c_{k-1}$ for $1\leq k\leq m$, then verify $d_{k+1}\leq d_k$ for every adjacent pair.

```text
SLOPE-AUDIT(c[0..m])
    for k ← 1 to m
        d[k] ← c[k] - c[k-1]
    ordered ← true
    for k ← 1 to m - 1
        if d[k+1] > d[k]
            ordered ← false
    return d, ordered
```

This is also $O(m)$ time. Materializing the slope list uses $O(m)$ space. By Proposition 4.1, it accepts exactly the same sequences as the midpoint algorithm.

### 7.3. Affine-invariance audit

To test or demonstrate normalization, form $c'_k=c_k+ak+b$ and compare the two deficit lists. Exact equality of the lists is guaranteed by Theorem 5.1.

```text
AFFINE-INVARIANCE-AUDIT(c[0..m], a, b)
    for k ← 0 to m
        transformed[k] ← c[k] + a*k + b
    original_deficits ← MIDPOINT-CERTIFICATE(c).deficits
    new_deficits ← MIDPOINT-CERTIFICATE(transformed).deficits
    return transformed, original_deficits = new_deficits
```

The running time and storage are both $O(m)$ in this reporting version.

### 7.4. Exact principal-permanent exploration

For a small matrix, one can compute each $c_k$ directly. Enumerate all $k$-subsets $S$ and all permutations of each $S$, maximize the selected-entry sum, and then maximize over subsets. For an $n\times n$ matrix, the total number of evaluated permutation terms is

$$
\sum_{k=0}^n\binom{n}{k}k!=\sum_{k=0}^n\frac{n!}{(n-k)!},
$$

which is $O(n!)$ up to a constant factor. This exhaustive method is intended for numerical examples and conjecture testing, not large-scale computation.

## 8. Structural consequences beyond adjacent inequalities

The midpoint inequalities admit several useful reformulations that require no new hypotheses. First, summing consecutive slopes gives a secant comparison. If $0\leq r<s\leq n$, then

$$
c_s-c_r=\sum_{k=r+1}^{s}d_k.
$$

Because the $d_k$ are nonincreasing, the average slope over a later interval cannot exceed the average slope over an earlier disjoint interval. More precisely, if $0\leq p<q\leq r<s\leq n$, then every slope occurring between $r$ and $s$ is no larger than every slope occurring between $p$ and $q$. Consequently,

$$
\frac{c_s-c_r}{s-r}\leq\frac{c_q-c_p}{q-p}.
$$

This statement is interpreted over the rational numbers. It follows simply by bounding each average between the largest and smallest terms in its interval and applying global slope order. It expresses concavity at the scale of separated secants rather than adjacent points.

Second, the deficits

$$
\Delta_k=2c_k-c_{k-1}-c_{k+1}=d_k-d_{k+1}
$$

measure the exact drops in marginal value. Telescoping yields, for $1\leq i\leq j<n$,

$$
d_i-d_{j+1}=\sum_{k=i}^{j}\Delta_k.
$$

Thus the global slope inequality is not merely qualitative: the distance between an early slope and a later slope is the accumulated discrete curvature between them. If all deficits vanish on an interval, the coefficients are affine there. If all are positive, the slopes decrease strictly throughout that interval.

Third, the coefficient sequence lies above every chord joining two of its sampled points. For $0\leq r<k<s\leq n$, discrete concavity implies

$$
(s-r)c_k\geq(s-k)c_r+(k-r)c_s.
$$

One proof compares the average of the first $k-r$ slopes after $r$ with the average of all $s-r$ slopes between $r$ and $s$. Since slopes decrease, the earlier average is at least the total average; clearing positive denominators gives the displayed inequality. This chord property offers another geometric certificate and shows that the local midpoint conditions control interpolation over arbitrary index gaps.

These consequences clarify why a one-pass local test is enough. Nonnegative deficits encode all accumulated slope comparisons and all rational chord inequalities. The local certificate is therefore a compressed representation of the sequence’s complete one-dimensional concavity geometry.

## 9. Applications

### 9.1. Screening candidate coefficient data

Suppose a coefficient vector is proposed as arising from a symmetric tropical model whose principal weights are expected to satisfy exchange. Before matrix reconstruction, a linear scan finds every violated midpoint inequality. A violation is a rigorous obstruction within that model class and remains an obstruction after every affine normalization.

### 9.2. Discrete diminishing returns

The quantity $d_k=c_k-c_{k-1}$ measures the marginal improvement obtained by allowing one more index. Global slope ordering says these marginal improvements diminish with cardinality. This places the coefficient sequence within the one-dimensional framework of discrete concavity and suggests connections to richer exchange geometries such as valuated delta-matroids.

### 9.3. Tropical spectral geometry

Coefficient differences determine adjacent intersection parameters for the affine terms $c_k+kx$ of a tropical polynomial. Their monotonicity constrains the order of candidate breakpoints. Strict inequalities rule out equal adjacent candidate breakpoints and motivate spectral-rigidity questions under perturbation.

### 9.4. Model diagnosis

Failure of concavity can reveal not merely noisy data but a structural mismatch: perhaps symmetry is absent, perhaps the intended cycle-cover exchange fails, or perhaps the proposed coefficients do not come from principal permanent maxima at all. The deficit profile $\Delta_k$ localizes the problematic cardinalities.

## 10. Scope, limitations, and interpretation

The theorem proved here is an exchange theorem about coefficient systems, not an unconditional theorem that every symmetric tropical matrix satisfies the required exchange axiom. Symmetry supplies compelling combinatorial motivation: reversing cycles preserves weights, potentially enabling alternating-cycle surgery on two optimal covers. Turning that idea into a general two-set exchange construction remains a separate task.

Similarly, discrete concavity is necessary for exchange realizability but has not been shown sufficient for realization by a symmetric tropical matrix. A complete characterization would require constructing a matrix from an arbitrary normalized integral concave vector or finding further hidden inequalities.

Endpoints are excluded from midpoint statements because $c_{-1}$ and $c_{n+1}$ are not part of the finite coefficient vector. The valid range is exactly $1\leq k<n$.

The integer codomain is convenient and matches the stated coefficient system, but the proofs use only ordered additive arithmetic. Analogous statements should extend to suitable ordered abelian groups, provided finite maxima and the relevant inequalities are available.

Finally, the tropical characteristic polynomial has several indexing conventions. Our $c_k$ records the maximum principal permanent at cardinality $k$. Reversing polynomial degree reverses the displayed coefficient order and changes how one phrases slope monotonicity, but not the underlying three-term inequality.

## 11. Future work

A first objective is a cycle-exchange theorem for symmetric tropical permanents. One seeks to prove that two optimal principal cycle covers on sets whose sizes differ by two can always be transformed, using alternating paths or cycles and reversal symmetry, into two intermediate covers whose total weight is no smaller.

A second objective is realization. The affine-invariance theorem permits normalization, while diagonal and paired off-diagonal blocks may encode prescribed slope drops. This suggests asking whether every normalized integral concave vector is realizable.

A third direction is a valuated delta-matroid interpretation. Variable-cardinality symmetric exchange is closer to delta-matroid geometry than to fixed-rank matroid exchange, and a parity-correcting extension may reveal the appropriate structure.

A fourth direction concerns Newton-diagram rigidity. If every midpoint inequality is strict, adjacent slopes are distinct. One may ask when this forces every adjacent term to contribute a distinct breakpoint and how those breakpoints vary under entrywise perturbations.

A fifth direction is to classify small nonsymmetric failures. Symmetry makes reversal weight-preserving; without symmetry, the obstruction should be visible in directed cycle covers that cannot be paired with reversals. Exhaustive study in low dimensions could identify a minimal forbidden family.

## 12. Conclusion

The cardinality-layer maxima of principal tropical weights inherit a strong shape from a simple exchange operation. Attained maxima on layers $k-1$ and $k+1$ exchange into two candidates on layer $k$, forcing the midpoint inequality

$$
2c_k\geq c_{k-1}+c_{k+1}.
$$

That local inequality is exactly the decrease of consecutive slopes, and transitivity orders slopes across arbitrary gaps. Affine changes preserve every curvature deficit, while one negative deficit rules out all realizations possessing the exchange mechanism.

The resulting hierarchy is compact but useful: local exchange implies global coefficient geometry. It supplies immediate recognition algorithms, transparent examples, and a precise interface between tropical matrix combinatorics and discrete convex analysis. Most importantly, it isolates the matrix-specific challenge. Once principal cycle-cover exchange is established for a class of symmetric tropical matrices, the full concavity and slope theory follows.
