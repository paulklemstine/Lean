# Exact Singleton Defect and the Asymptotic Capacity of Quantum Codes

**Aristotle**  
**22 July 2026**

## Abstract

For quantum-code parameters $[[n,k,d]]$ satisfying the quantum Singleton inequality $k+2(d-1)\le n$ and $d>0$, we isolate the exact finite-length capacity budget

$$
D=n+2-2d.
$$

We call $D$ the exact Singleton defect and distinguish it from the geometric defect $G=n-2d$. The Singleton inequality is equivalent to the sharp parameter-level estimate $0\le k\le D$, while $D=G+2$. Consequently, every protected entropy $S$ bounded above by $k$ also satisfies $S\le D$. After normalization, the logical rate $R=k/n$ is bounded by $D/n$, and the normalized exact defect differs from $G/n$ by precisely $2/n$. For any family with block lengths tending to infinity, this endpoint correction vanishes. If $G$ is uniformly bounded above, then both the logical rate and every nonnegative protected-entropy density $S/n$ tend to zero. Conversely, a finite code with rate at least $\varepsilon$ must have normalized exact defect at least $\varepsilon$. These conclusions require no locality or geometric hypothesis beyond the Singleton inequality. They establish a necessary capacity law, not a sufficient construction theorem: positive defect density need not imply positive logical rate. We give elementary algorithms and numerical examples, explain the exact/asymptotic distinction, and identify the additional geometric structure needed for stronger two-sided results.

## 1. Introduction

A quantum error-correcting code distributes logical quantum information over a larger physical system. Its basic parameters are conventionally written $[[n,k,d]]$: $n$ is the number of physical qubits, $k$ is the number of logical qubits, and $d$ is the code distance. These parameters express a competition. Increasing $k$ improves storage efficiency, while increasing $d$ improves resilience; both draw on the finite physical resource $n$.

The quantum Singleton inequality captures a universal form of this competition:

$$
k+2(d-1)\le n.
$$

The present study develops the consequences of viewing this inequality through a defect variable. Rearranging gives

$$
k\le n+2-2d.
$$

The right-hand side is the exact amount of parameter-level capacity not consumed by distance. We denote it by $D$. A second quantity, $G=n-2d$, is geometrically natural because it compares physical length directly with twice the distance. The difference between them is a universal constant:

$$
D=G+2.
$$

This distinction resolves a potential ambiguity. At finite length the exact nonnegative upper bound is $D$, not $G$. In particular, $G$ may be negative even though $k$ is nonnegative, whereas the Singleton hypotheses force $D\ge0$. At asymptotically large block length, however, their normalized versions differ only by $2/n$. Thus $D$ is the correct finite capacity budget and $G$ is an asymptotically equivalent geometric proxy.

Our main conclusions concern both individual codes and growing families. For a single code, $k\le D$ and any protected entropy $S\le k$ obeys $S\le D$. For a family with $G$ bounded above by a constant $B$, one has $k\le B+2$ uniformly. If block length diverges, the logical rate tends to zero. The same squeeze argument gives vanishing density for every nonnegative protected entropy bounded by $k$. Conversely, rate at least $\varepsilon$ forces $D/n\ge\varepsilon$.

These are parameter-level obstructions. They do not claim that defect can always be converted into logical information. Such a converse would need further assumptions concerning locality, geometry, expansion, stabilizer incidence, or decoding. This separation between universal arithmetic and construction-dependent structure is central: it identifies exactly what follows from Singleton alone and what remains for geometric coding theory.

## 2. Definitions and setting

### 2.1 Admissible code parameters

An **admissible parameter triple** is a triple of nonnegative integers $(n,k,d)$ such that $d>0$ and

$$
k+2(d-1)\le n.
$$

The positivity of $d$ ensures that subtraction by one has its ordinary integer meaning within the stated inequality and excludes a zero-distance degeneracy. The results below concern every admissible triple, whether or not additional locality or geometric data are specified.

For asymptotic statements, a **code family** is a sequence $(n_i,k_i,d_i)_{i\ge0}$ of admissible triples. We say its block length diverges if $n_i\to\infty$.

### 2.2 Exact and geometric defects

**Definition 2.1 (Exact Singleton defect).** For an admissible triple $(n,k,d)$, define

$$
D=n+2-2d.
$$

**Definition 2.2 (Geometric defect).** Define

$$
G=n-2d.
$$

The adjective “geometric” reflects the direct balance between length and twice the distance; no geometric realization is assumed in the results. The terminology is therefore interpretive rather than an extra hypothesis.

**Lemma 2.3 (Endpoint relation).** The defects satisfy

$$
D=G+2.
$$

**Proof sketch.** Substitute the two definitions:

$$
G+2=(n-2d)+2=n+2-2d=D.
$$

The constant $2$ is the endpoint correction inherited from the term $2(d-1)$ in the quantum Singleton inequality. $\square$

### 2.3 Rates and protected entropy

For $n>0$, define the **logical rate**

$$
R=\frac{k}{n},
$$

and the **normalized exact defect**

$$
\delta=\frac{D}{n}.
$$

The corresponding geometric defect density is $G/n$.

A **protected entropy** will mean any real quantity $S$ satisfying

$$
S\le k.
$$

For density results we additionally assume $S\ge0$. This deliberately broad definition abstracts any operational information quantity, measured in logical-qubit units, that cannot exceed the number of logical qubits. No particular noise model is required for the arithmetic conclusions.

## 3. Finite-length capacity laws

### 3.1 Exact defect-capacity theorem

**Theorem 3.1 (Exact finite-length defect-capacity law).** Every admissible parameter triple satisfies

$$
0\le k\le D.
$$

In particular, the exact Singleton defect is nonnegative.

**Proof sketch.** Since $d>0$, ordinary integer arithmetic gives

$$
k+2(d-1)\le n
$$

if and only if

$$
k+2d\le n+2.
$$

Subtracting $2d$ yields

$$
k\le n+2-2d=D.
$$

Because $k$ is a nonnegative integer, $0\le k\le D$, and hence $D\ge0$. $\square$

The theorem identifies $D$, rather than $G$, as the exact finite-size budget. For instance, if $n=2d$, then $G=0$ but $D=2$, so the inequality allows as many as two logical qubits. The exact statement is not that perfect length-distance balance eliminates logical information; it is that such balance limits logical information to a constant independent of scale.

**Corollary 3.2 (Protected-entropy bound).** Let $S$ be a protected entropy with $S\le k$. Then

$$
S\le D.
$$

**Proof sketch.** Chain the assumed inequality with Theorem 3.1:

$$
S\le k\le D.
$$

No nonnegativity assumption on $S$ is needed for this upper bound. $\square$

### 3.2 Uniform bounds from geometric defect

**Theorem 3.3 (Uniform protected-information bound).** Let $(n_i,k_i,d_i)$ be a code family, and let $S_i\le k_i$ for every $i$. If there is an integer $B$ such that

$$
G_i=n_i-2d_i\le B
$$

for every $i$, then

$$
k_i\le B+2
$$

and

$$
S_i\le B+2
$$

for every $i$.

**Proof sketch.** The endpoint identity gives $D_i=G_i+2\le B+2$. Theorem 3.1 yields $k_i\le D_i$, while Corollary 3.2 yields $S_i\le D_i$. Combining these inequalities proves both claims. $\square$

The upper bound on $G_i$ need not be tight, and no lower bound on $G_i$ is assumed. Admissibility itself implies $G_i\ge-2$, because $D_i=G_i+2\ge0$. The theorem is especially useful when $B$ is independent of block length.

### 3.3 Rate and normalized defect

**Theorem 3.4 (Rate-defect inequality).** For every admissible triple with $n>0$,

$$
R\le\delta.
$$

Equivalently,

$$
\frac{k}{n}\le\frac{n+2-2d}{n}.
$$

**Proof sketch.** Divide the inequality $k\le D$ by the positive number $n$. Division preserves the order. $\square$

**Theorem 3.5 (Normalized endpoint identity).** For every admissible triple with $n>0$,

$$
\delta=\frac{G}{n}+\frac{2}{n}.
$$

**Proof sketch.** Divide $D=G+2$ by $n$ and distribute division over addition. $\square$

Together these results produce the useful finite estimate

$$
0\le R\le\frac{G}{n}+\frac{2}{n}.
$$

Although $G/n$ alone can be negative for small examples, the sum on the right is nonnegative under admissibility.

## 4. Asymptotic consequences

### 4.1 Agreement of normalized defects

**Theorem 4.1 (Asymptotic equivalence of defects).** Let $(n_i,k_i,d_i)$ be a code family with $n_i\to\infty$. Then

$$
\frac{D_i}{n_i}-\frac{G_i}{n_i}\longrightarrow0.
$$

More precisely, the difference is exactly $2/n_i$ for every $i$.

**Proof sketch.** Theorem 3.5 gives

$$
\frac{D_i}{n_i}-\frac{G_i}{n_i}=\frac{2}{n_i}.
$$

Since $n_i\to\infty$, the reciprocal $1/n_i$ tends to zero, and so does $2/n_i$. $\square$

This theorem justifies using geometric defect density in large-scale discussions, provided the finite correction is retained whenever exact estimates matter.

### 4.2 Bounded defect implies zero rate

**Theorem 4.2 (Bounded-defect zero-rate theorem).** Let $(n_i,k_i,d_i)$ be a code family such that $n_i\to\infty$. If an integer $B$ satisfies $G_i\le B$ for all $i$, then

$$
\frac{k_i}{n_i}\longrightarrow0.
$$

**Proof sketch.** The logical rate is nonnegative. By Theorem 3.3,

$$
0\le\frac{k_i}{n_i}\le\frac{B+2}{n_i}.
$$

The upper bound tends to zero because the numerator is constant and $n_i\to\infty$. The squeeze theorem gives the conclusion. $\square$

This includes exact length balance $n_i=2d_i$, for which $G_i=0$, and more generally every relation $n_i=2d_i+O(1)$. It also covers families where $G_i$ fluctuates or becomes negative, as long as it has a uniform upper bound.

**Corollary 4.3 (No extensive logical information at exact balance).** If $n_i=2d_i+C_i$, where the integers $C_i$ are uniformly bounded above and $n_i\to\infty$, then the logical rate tends to zero.

**Proof sketch.** Here $G_i=C_i$, so Theorem 4.2 applies. $\square$

### 4.3 Vanishing protected-entropy density

**Theorem 4.4 (Bounded-defect zero-entropy-density theorem).** Let $(n_i,k_i,d_i)$ be a code family with $n_i>0$ and $n_i\to\infty$. Let $S_i$ satisfy

$$
0\le S_i\le k_i.
$$

If $G_i\le B$ for all $i$, then

$$
\frac{S_i}{n_i}\longrightarrow0.
$$

**Proof sketch.** Theorem 3.3 gives $S_i\le B+2$. Therefore

$$
0\le\frac{S_i}{n_i}\le\frac{B+2}{n_i}.
$$

Again the upper bound tends to zero, so the squeeze theorem completes the argument. $\square$

The conclusion is intentionally operationally agnostic. Whenever an entropy or information quantity is nonnegative and no larger than the logical dimension, bounded geometric defect prevents it from becoming extensive.

### 4.4 Positive rate forces positive defect

**Theorem 4.5 (Quantitative necessary defect density).** For an admissible triple with $n>0$, if $\varepsilon$ is a real number satisfying

$$
\varepsilon\le R,
$$

then

$$
\varepsilon\le\delta.
$$

**Proof sketch.** Theorem 3.4 gives $R\le\delta$. Transitivity yields $\varepsilon\le R\le\delta$. $\square$

For a family with rates uniformly bounded below by a positive $\varepsilon$, every normalized exact defect is at least $\varepsilon$. Since $D_i/n_i-G_i/n_i\to0$ when $n_i\to\infty$, the geometric defect density cannot asymptotically remain below $\varepsilon$ by a fixed positive margin.

The theorem is only a necessary condition. The reverse implication $\delta\ge\varepsilon\Rightarrow R\ge c\varepsilon$ does not follow from Singleton arithmetic. A large budget does not ensure that a code construction uses it.

## 5. Algorithms and computational diagnostics

The results lead to simple exact procedures for checking finite parameter sets and exploring families.

### 5.1 Single-triple audit

Given integers $(n,k,d)$, first verify $n,k\ge0$, $d>0$, and $k+2(d-1)\le n$. Compute

$$
D=n+2-2d,\qquad G=n-2d.
$$

Then check $D=G+2$, $0\le k\le D$, and, when $n>0$, compute

$$
R=\frac{k}{n},\qquad\delta=\frac{D}{n}.
$$

The inequality $R\le\delta$ is guaranteed for admissible data but remains useful as an implementation check. This procedure uses a constant number of integer operations, so its arithmetic-operation complexity is $O(1)$ per triple. With binary integers of bit length $L$, its bit complexity is governed by $O(L)$ additions, comparisons, and multiplication by the constant $2$.

### 5.2 Family audit

For $m$ triples, compute the same quantities row by row. If a proposed uniform geometric bound $B$ is supplied, verify $G_i\le B$ and report the envelopes

$$
k_i\le B+2,
$$

$$
R_i\le\frac{B+2}{n_i},
$$

and, for supplied values $0\le S_i\le k_i$,

$$
\frac{S_i}{n_i}\le\frac{B+2}{n_i}.
$$

The scan takes $O(m)$ arithmetic operations and $O(1)$ auxiliary memory if results are streamed. Storing all rows requires $O(m)$ memory.

### 5.3 Synthetic examples

Three parameter families illustrate distinct regimes.

**Exact balance.** Set

$$
n_i=2i,
\qquad d_i=i,
\qquad k_i=2
$$

for $i\ge1$. Then $G_i=0$, $D_i=2$, and the Singleton inequality is saturated. The rate is

$$
R_i=\frac{1}{i}\longrightarrow0.
$$

**Constant positive geometric defect.** Set

$$
n_i=2i+4,
\qquad d_i=i,
\qquad k_i=6.
$$

Then $G_i=4$, $D_i=6$, and the Singleton inequality is again saturated. Nevertheless,

$$
R_i=\frac{6}{2i+4}\longrightarrow0.
$$

**Positive defect density.** Let

$$
n_i=4i,
\qquad d_i=i,
\qquad k_i=2i+2.
$$

Then $G_i=2i$, $D_i=2i+2$, and the parameters saturate Singleton. Here

$$
R_i=\frac{2i+2}{4i}\longrightarrow\frac12,
$$

while

$$
\frac{D_i}{n_i}=\frac{2i+2}{4i}\longrightarrow\frac12.
$$

This final example shows that positive rate is compatible with positive defect density. It does not establish that every admissible parameter triple is realized by a quantum code; the examples demonstrate the parameter laws themselves.

## 6. Interpretation and applications

### 6.1 Capacity budget versus realizable capacity

The exact defect $D$ is best understood as a ceiling. The inequality $k\le D$ says that distance leaves at most $D$ logical qubits available. Equality corresponds to saturation of the quantum Singleton inequality, but saturation is an additional property, not a universal outcome.

This one-sidedness prevents overinterpretation. If $D/n$ is small, the rate must be small. If $D/n$ is large, the rate may be large or small. Further lower bounds require information not contained in $(n,k,d)$ alone.

### 6.2 Geometrically local code families

In local stabilizer and subsystem codes, $n$ and $d$ may be tied to a lattice, graph, cell complex, or manifold. The geometric defect $G=n-2d$ then offers a natural global observable. Theorems 4.2 and 4.4 apply without using that geometry: if $G$ remains bounded, extensive protected information is impossible.

Geometry becomes relevant when seeking a converse. Expansion, bounded degree, local testability, dimensional constraints, or special homological structure might force some fraction of available defect to support logical degrees of freedom. Establishing such a result would turn the universal upper law into a class-dependent two-sided estimate.

### 6.3 Tensor networks and cut-dependent quantities

A global Singleton defect cannot by itself describe entanglement across every boundary region. Tensor-network models suggest introducing a family of cut-indexed defects, each associated with a region and an erasure threshold or minimal cut. An entropy-area identity would then correspond to saturation of region-specific coding inequalities, not merely the global inequality.

The present results clarify the logical order. One must first establish the cut-wise inequality, then separately prove saturation if an equality with entropy is claimed. Validity of an upper bound does not imply an entropy formula.

### 6.4 Parameter equivalence does not imply geometric equivalence

Two codes can share $[[n,k,d]]$ and therefore share $D$, $G$, $R$, and $\delta$, while differing in stabilizer generators, syndrome adjacency, decoder moves, or locality. Consequently, the defect laws constrain information capacity but cannot reconstruct a bulk metric or incidence geometry.

This suggests comparing parameter-matched codes through syndrome graphs. Nonisomorphic or non-quasi-isometric syndrome geometries would demonstrate concretely that global parameter saturation is insufficient for geometric interpretation.

## 7. Further deductions and design principles

The defect viewpoint supports several deductions that are useful when evaluating proposed code families.

### 7.1 A finite-size threshold for target rate

Suppose a designer requests a rate of at least $r>0$ at block length $n$. Theorem 4.5 requires

$$
D\ge rn.
$$

Using $D=G+2$, this is equivalent to

$$
G\ge rn-2.
$$

Thus a fixed positive target rate demands geometric defect growing linearly with block length, up to the universal endpoint correction. This statement is stronger than saying merely that $G$ must be unbounded. Growth such as $\sqrt n$ or $\log n$ is still insufficient to support a rate bounded below by a positive constant under the Singleton constraint.

For finite engineering estimates, the correction can be visible. A target rate $r=1/4$ at length $n=20$ requires $D\ge5$ and hence $G\ge3$. At length $n=2000$, it requires $D\ge500$ and $G\ge498$. The relative importance of the two-unit correction decreases, but exact feasibility tests must retain it.

### 7.2 A distance ceiling at fixed logical dimension

The same arithmetic may be solved for distance. From

$$
k+2(d-1)\le n
$$

we obtain

$$
d\le\frac{n-k+2}{2}.
$$

Because $d$ is integral, this gives

$$
d\le\left\lfloor\frac{n-k+2}{2}\right\rfloor.
$$

This is the dual design interpretation of the defect law: once $n$ and $k$ are chosen, distance cannot exceed the displayed ceiling. Increasing logical payload by one unit reduces the remaining distance budget, with parity determining when the integer ceiling drops.

### 7.3 Saturation and slack

Define the **Singleton slack** by

$$
\sigma=D-k.
$$

Theorem 3.1 implies $\sigma\ge0$. The case $\sigma=0$ is exactly Singleton saturation, while $\sigma>0$ measures available defect not realized as logical dimension. In normalized form,

$$
\delta-R=\frac{\sigma}{n}.
$$

This identity cleanly separates two possible reasons for low rate: the total defect density $\delta$ may itself be small, or the construction may leave a large fraction of its defect unused. Geometry and code architecture can influence the second mechanism even though the universal inequality controls only the first.

For a family, if $\delta_i$ approaches a positive limit but $R_i$ tends to zero, then the normalized slack $\sigma_i/n_i$ approaches the same positive limit. Such a family demonstrates directly why positive defect density is not sufficient for positive rate. Conversely, asymptotic saturation means $\sigma_i/n_i\to0$, in which case rate and exact-defect density have the same limit whenever either limit exists.

These deductions turn the defect into a practical diagnostic with three components: the total budget $D$, the used portion $k$, and the unused slack $\sigma$. The universal theory constrains their order,

$$
0\le k\le D,
$$

while structural coding theory must explain how much slack a given geometric architecture necessarily retains.

## 8. Scope and limitations

The assumptions used are minimal: nonnegative integer parameters, positive distance, and the quantum Singleton inequality. No claim is made about the existence of a code for every admissible triple. The statements are conditional parameter theorems: every realized code whose parameters satisfy the inequality obeys the conclusions.

The protected entropy $S$ is abstract. The finite upper bound needs only $S\le k$; the density theorem additionally needs $S\ge0$. Applications must justify these inequalities for their chosen operational entropy.

Uniform boundedness of $G$ is sufficient for the stated zero-density results. A natural extension replaces boundedness by sublinearity, $G_i=o(n_i)$. Since

$$
0\le\frac{k_i}{n_i}\le\frac{G_i}{n_i}+\frac{2}{n_i},
$$

sublinear geometric defect should likewise force zero rate whenever the asymptotic assumptions are formulated appropriately. The same reasoning applies to protected entropy density.

Most importantly, no lower rate bound is obtained from defect density. Singleton gives the upper direction only. Any matching lower bound must arise from additional coding or geometric hypotheses.

## 9. Future research directions

First, one can define a concrete class of local CSS codes on bounded-degree cell complexes and ask whether expansion or local testability converts defect density into a logical-rate lower bound. Such a theorem would be genuinely structural rather than purely arithmetic.

Second, finite tensor networks invite cut-indexed defects. The immediate target is a cut-wise Singleton inequality relating erasure distance, minimal-cut size, and regional encoded entropy. Equality would require a separate saturation criterion.

Third, syndrome adjacency graphs can test the limits of parameter data. Constructing codes with identical saturated $[[n,k,d]]$ parameters but nonisomorphic syndrome graphs would isolate the missing geometric invariant.

Fourth, subsystem codes may support a local defect field only after a canonical allocation of checks and logical degrees of freedom is fixed. Comparing different allocations can reveal whether proposed curvature identities are well-defined.

Finally, the bounded-defect results should be generalized explicitly to $G_i=o(n_i)$. The normalized Singleton estimate already displays the mechanism: both $G_i/n_i$ and $2/n_i$ vanish, squeezing logical and protected-entropy rates to zero.

## 10. Conclusion

The quantum Singleton inequality contains an exact capacity budget:

$$
D=n+2-2d.
$$

For every admissible $[[n,k,d]]$ parameter triple,

$$
0\le k\le D,
$$

and every protected entropy bounded by $k$ is also bounded by $D$. The geometrically suggestive quantity $G=n-2d$ differs from $D$ by the universal endpoint correction $2$. Their normalized versions therefore become asymptotically identical as block length grows.

This yields a sharp obstruction. If $G$ is uniformly bounded while $n$ tends to infinity, logical rate and every nonnegative protected-entropy density bounded by the logical dimension tend to zero. Conversely, positive rate requires at least the same normalized exact defect. These statements identify what parameter arithmetic can establish on its own: defect is necessary capacity. Whether geometry can make that capacity sufficient remains the central structural question.