# Cellular Automata as Algebraic Geometry: Polynomial Models, Fixed-Point Loci, and the Limits of Stationary Complexity

**Aristotle**  
**July 28, 2026**

## Abstract

Elementary cellular automata are the $256$ synchronous binary dynamical systems whose local update depends on a cell and its two nearest neighbors. This paper develops a self-contained algebraic description of these systems over the field $\mathbb F_2$. Every local rule is represented by a unique multilinear polynomial in three variables, and the global dynamics become a translation-invariant polynomial map on binary configurations. Fixed configurations are consequently solutions of polynomial equations.

Three representative rules clarify both the power and the limitation of this viewpoint. Rule 110 has algebraic normal form

$$
f_{110}(\ell,c,r)=r+c+cr+\ell cr.
$$

Rule 0 has exactly one fixed bi-infinite configuration, the constant-zero state. Rule 204 is the center projection and fixes every configuration. Rule 110 fixes the constant-zero state but does not fix the constant-one state, so its fixed-point locus is nonempty and nonmaximal. This last result disproves the strongest proposed identification of computational universality with a maximal fixed-point locus: Rule 204 has maximal stationary freedom but trivial dynamics, whereas Rule 110 supports universal computation without fixing all states.

We present algorithms for truth-table evaluation, algebraic-normal-form extraction, and exhaustive fixed-point enumeration on periodic rings. We then distinguish fixed-point count, Krull dimension, coordinate-algebra dimension, and asymptotic entropy, explaining why “dimension” cannot be used ambiguously for finite Boolean state spaces. The results motivate a broader algebraic geometry of spacetime histories rather than a theory based only on stationary configurations.

## 1. Introduction

An elementary cellular automaton acts on a one-dimensional array of binary cells. Time is discrete. At each time step every cell is updated simultaneously by the same function of its left neighbor, itself, and its right neighbor. Since there are $2^3=8$ possible neighborhoods and two possible outputs for each neighborhood, there are

$$
2^8=256
$$

distinct elementary rules.

Despite this tiny rule space, the resulting dynamics range from immediate collapse to uniform states, through periodic and chaotic-looking patterns, to persistent localized structures and universal computation. Rule 110 is the standard emblem of the last phenomenon: a fixed local table can sustain dynamics rich enough to simulate arbitrary computation.

A natural research program seeks static algebraic invariants that predict this dynamical complexity. The binary alphabet suggests the field $\mathbb F_2=\{0,1\}$, whose addition and multiplication are performed modulo $2$. A Boolean state then becomes a vector over $\mathbb F_2$, and every Boolean local function becomes a polynomial. For a finite periodic ring, the global update is a polynomial self-map of $\mathbb F_2^n$. Fixed configurations satisfy polynomial equations, so they can be treated as an algebraic set.

This program immediately raises a conjectural analogy: perhaps dynamically simple rules have small fixed-point loci, while computationally rich rules have large or high-dimensional ones. The analogy is attractive, but it needs precise definitions and decisive tests. The central conclusions of this paper are:

1. the polynomial representation is exact and particularly concise for Rule 110;
2. Rule 0 and Rule 204 realize the minimum and maximum possible fixed-point sets;
3. Rule 110 has at least one fixed configuration but not all configurations are fixed;
4. maximal stationary freedom is not a measure of computational power;
5. several inequivalent invariants have been conflated under the word “dimension,” and they must be separated before any complexity correlation can be meaningfully tested.

The treatment uses bi-infinite configurations for structural theorems and finite periodic rings for algorithms. All definitions and arguments are given below.

## 2. Elementary rules and global dynamics

### 2.1 Configurations

Let $B=\{0,1\}=\mathbb F_2$. A **bi-infinite binary configuration** is a function

$$
s:\mathbb Z\longrightarrow B.
$$

The value at site $i$ is denoted $s_i$. A **periodic configuration of period $n$** is a vector

$$
s=(s_0,\ldots,s_{n-1})\in B^n,
$$

with indices interpreted modulo $n$. Thus the left neighbor of site $0$ is site $n-1$ and the right neighbor of site $n-1$ is site $0$.

### 2.2 Wolfram encoding

For a neighborhood $(\ell,c,r)\in B^3$, define its index by

$$
\iota(\ell,c,r)=4\ell+2c+r.
$$

The indices $0,1,\ldots,7$ correspond respectively to

$$
000,001,010,011,100,101,110,111.
$$

For a rule number $R\in\{0,\ldots,255\}$, write

$$
R=\sum_{j=0}^7 b_j2^j,
$$

where each $b_j\in B$. The **local rule** $f_R:B^3\to B$ is

$$
f_R(\ell,c,r)=b_{\iota(\ell,c,r)}.
$$

This convention says that neighborhood $000$ reads the least significant bit and neighborhood $111$ reads the most significant bit.

### 2.3 Synchronous global update

The **global update** on bi-infinite configurations is the map $F_R:B^{\mathbb Z}\to B^{\mathbb Z}$ defined by

$$
(F_R(s))_i=f_R(s_{i-1},s_i,s_{i+1}).
$$

All sites use the old state $s$ and change simultaneously. For a periodic ring of length $n$, define $F_{R,n}:B^n\to B^n$ by the same formula with subscripts reduced modulo $n$.

A configuration $s$ is a **fixed point** if

$$
F_R(s)=s
$$

in the bi-infinite setting, or $F_{R,n}(s)=s$ on a ring. Equivalently, it satisfies the local equations

$$
f_R(s_{i-1},s_i,s_{i+1})=s_i
$$

at every site.

## 3. Boolean polynomial representation

### 3.1 Algebraic normal form

A function $g:B^3\to B$ can be represented by a polynomial over $\mathbb F_2$. Because $x^2=x$ for $x\in B$, all powers can be reduced, giving a multilinear expression

$$
g(\ell,c,r)=a_\varnothing+a_\ell\ell+a_cc+a_rr+a_{\ell c}\ell c+a_{\ell r}\ell r+a_{cr}cr+a_{\ell cr}\ell cr,
$$

where every coefficient lies in $\mathbb F_2$.

**Algebraic Normal Form Theorem.** Every Boolean function $g:B^3\to B$ has a unique representation in the multilinear form above.

**Proof sketch.** The eight square-free monomials are functions on the eight-element set $B^3$. Order subsets of $\{\ell,c,r\}$ by inclusion. Evaluating a monomial indexed by $A$ at the indicator vector of a subset $S$ gives $1$ exactly when $A\subseteq S$. The resulting $8\times8$ evaluation matrix is triangular with diagonal entries $1$ under any order refining inclusion. It is therefore invertible over $\mathbb F_2$. Existence and uniqueness follow. Equivalently, the coefficients are recovered from truth-table values by the Boolean Möbius transform

$$
a_A=\sum_{T\subseteq A}g(\mathbf 1_T),
$$

where the sum is in $\mathbb F_2$ and $\mathbf 1_T$ is the input whose coordinates in $T$ are $1$.

The maximal degree is $3$, not because every rule is genuinely cubic, but because three input variables suffice and square-free reduction removes higher powers.

### 3.2 Algebraic normal form of Rule 110

The binary expansion of $110$ is

$$
110=0\cdot2^7+1\cdot2^6+1\cdot2^5+0\cdot2^4+1\cdot2^3+1\cdot2^2+1\cdot2^1+0\cdot2^0.
$$

Under the ascending index convention, its outputs on $000,001,010,011,100,101,110,111$ are

$$
0,1,1,1,0,1,1,0.
$$

**Theorem 1 (Rule 110 Polynomial Theorem).** For every $(\ell,c,r)\in B^3$, the local function of Rule 110 is

$$
f_{110}(\ell,c,r)=r+c+cr+\ell cr
$$

over $\mathbb F_2$.

**Proof sketch.** There are eight inputs. Evaluating the polynomial gives:

| $(\ell,c,r)$ | $r+c+cr+\ell cr$ | Rule 110 output |
|---|---:|---:|
| $(0,0,0)$ | $0$ | $0$ |
| $(0,0,1)$ | $1$ | $1$ |
| $(0,1,0)$ | $1$ | $1$ |
| $(0,1,1)$ | $1+1+1=1$ | $1$ |
| $(1,0,0)$ | $0$ | $0$ |
| $(1,0,1)$ | $1$ | $1$ |
| $(1,1,0)$ | $1$ | $1$ |
| $(1,1,1)$ | $1+1+1+1=0$ | $0$ |

All sums are modulo $2$. Equality on all elements of $B^3$ proves equality of the functions.

Consequently, the Rule 110 fixed-point equations are

$$
s_i=s_{i+1}+s_i+s_is_{i+1}+s_{i-1}s_is_{i+1}
$$

for all $i$. Moving $s_i$ to the right and using $s_i+s_i=0$ yields the equivalent equations

$$
s_{i+1}+s_is_{i+1}+s_{i-1}s_is_{i+1}=0.
$$

This simplification is specific to characteristic $2$.

## 4. Fixed-point loci as algebraic sets

For a periodic ring of length $n$, introduce the polynomial ring

$$
A_n=\mathbb F_2[x_0,\ldots,x_{n-1}].
$$

To encode Boolean values algebraically, include the field equations

$$
x_i^2-x_i=0
$$

for every $i$. Let $p_R(\ell,c,r)$ be the algebraic normal form of the local rule. The fixed-point ideal is

$$
I_{R,n}=\left\langle x_i^2-x_i,\;p_R(x_{i-1},x_i,x_{i+1})-x_i:0\le i<n\right\rangle,
$$

where indices are modulo $n$. The fixed-point set is

$$
\operatorname{Fix}(R,n)=\{x\in\mathbb F_2^n:F_{R,n}(x)=x\}=V(I_{R,n})(\mathbb F_2).
$$

This construction is exact: a binary vector belongs to the algebraic set precisely when it is a fixed configuration. It also exposes a subtlety. Because the Boolean equations make the coordinate algebra finite-dimensional over $\mathbb F_2$, the associated scheme is zero-dimensional whenever it is nonempty. Thus ordinary Krull dimension does not rank finite fixed-point sets by cardinality.

For bi-infinite configurations, one may analogously use infinitely many variables $x_i$ indexed by $\mathbb Z$ and a translation-invariant family of equations. The object is then better interpreted through symbolic dynamics, inverse limits of periodic models, or suitably chosen infinite-dimensional algebraic structures. The elementary theorems below avoid dependence on any one such framework by reasoning directly from the local update.

## 5. Extremal fixed-point theorems

### 5.1 Rule 0

Rule 0 has all eight output bits equal to zero, so

$$
f_0(\ell,c,r)=0
$$

for every neighborhood.

**Theorem 2 (Characterization of Rule 0 Fixed Points).** A bi-infinite configuration $s$ is fixed by Rule 0 if and only if $s_i=0$ for every $i\in\mathbb Z$.

**Proof.** If $F_0(s)=s$, then for every site $i$,

$$
s_i=(F_0(s))_i=f_0(s_{i-1},s_i,s_{i+1})=0.
$$

Thus $s$ is identically zero. Conversely, applying Rule 0 to the identically zero configuration produces zero at every site, so that configuration is fixed. $\square$

**Corollary 2.1 (Uniqueness for Rule 0).** Rule 0 has exactly one fixed bi-infinite configuration.

The same proof applies on every periodic ring. Hence

$$
|\operatorname{Fix}(0,n)|=1
$$

for every $n\ge1$.

### 5.2 Rule 204

The binary pattern of Rule 204 is chosen so that the output equals the center bit. Its local polynomial is simply

$$
f_{204}(\ell,c,r)=c.
$$

**Theorem 3 (Rule 204 Identity Theorem).** Every bi-infinite binary configuration is fixed by Rule 204.

**Proof.** For every configuration $s$ and every site $i$,

$$
(F_{204}(s))_i=f_{204}(s_{i-1},s_i,s_{i+1})=s_i.
$$

Equality at all sites gives $F_{204}(s)=s$. $\square$

**Corollary 3.1 (Maximal Periodic Fixed Set).** On a periodic ring of length $n$, Rule 204 has exactly $2^n$ fixed configurations:

$$
|\operatorname{Fix}(204,n)|=2^n.
$$

This is the largest possible fixed-point count for any map on $B^n$.

Rules 0 and 204 therefore realize opposite extremes: total erasure gives one fixed state, while the identity update fixes the whole state space.

## 6. Rule 110: nonempty but nonmaximal

The polynomial formula gives two immediate tests on uniform configurations.

**Theorem 4 (The Zero Configuration Is Fixed by Rule 110).** If $\mathbf 0$ denotes the configuration with $(\mathbf 0)_i=0$ for all $i$, then

$$
F_{110}(\mathbf 0)=\mathbf 0.
$$

**Proof.** Every neighborhood in $\mathbf 0$ is $(0,0,0)$, and

$$
f_{110}(0,0,0)=0+0+0+0=0.
$$

Thus every updated cell remains zero. $\square$

**Theorem 5 (The One Configuration Is Not Fixed by Rule 110).** If $\mathbf 1$ denotes the configuration with $(\mathbf 1)_i=1$ for all $i$, then

$$
F_{110}(\mathbf 1)\ne\mathbf 1.
$$

**Proof.** Every neighborhood in $\mathbf 1$ is $(1,1,1)$. In $\mathbb F_2$,

$$
f_{110}(1,1,1)=1+1+1+1=0.
$$

Therefore every cell becomes zero after one update. In particular the updated configuration differs from $\mathbf 1$. $\square$

**Corollary 5.1 (Rule 110 Has a Proper Fixed-Point Locus).** The fixed-point locus of Rule 110 is nonempty but is not the whole configuration space.

The conclusion holds both for bi-infinite configurations and for every nonempty periodic ring: the all-zero vector is fixed and the all-one vector is not.

This corollary is a direct counterexample to the strongest form of a proposed complexity principle asserting that a computationally universal elementary rule should have a maximal fixed-point locus. Rule 110 is computationally universal but does not fix every state. Conversely, Rule 204 fixes every state yet performs no change at all. Hence maximality of the fixed set is neither necessary for universal dynamics nor sufficient for nontrivial dynamics.

## 7. Algorithms

### 7.1 Local rule evaluation

Given $R$, $\ell$, $c$, and $r$, compute $j=4\ell+2c+r$, shift $R$ right by $j$, and retain the least significant bit. This takes constant time and constant auxiliary space under fixed-width arithmetic.

**Pseudocode.**

```text
LOCAL-OUTPUT(R, left, center, right)
    index ← 4·left + 2·center + right
    return (R shifted right by index) AND 1
```

### 7.2 Extraction of algebraic normal form

Let $v[0],\ldots,v[7]$ be the truth table in subset-mask order. The in-place Boolean Möbius transform returns the coefficients of the square-free monomials. For each variable bit $b$, and each mask containing $b$, replace the entry at that mask by its exclusive-or with the entry obtained by removing $b$.

```text
ALGEBRAIC-NORMAL-FORM(R)
    for mask from 0 to 7
        coeff[mask] ← bit mask of R
    for variableBit in {1, 2, 4}
        for mask from 0 to 7
            if mask AND variableBit is nonzero
                coeff[mask] ← coeff[mask] XOR coeff[mask XOR variableBit]
    return coeff
```

For three variables this is constant work. For a Boolean function of $k$ variables, it uses $O(k2^k)$ time and $O(2^k)$ storage.

### 7.3 Exhaustive fixed-point enumeration

For a ring of length $n$, enumerate all $2^n$ states, update each of the $n$ cells, and compare the result with the original state.

```text
FIXED-POINTS(R, n)
    fixed ← empty list
    for encodedState from 0 to 2^n − 1
        state ← n binary digits of encodedState
        next ← empty n-cell vector
        for i from 0 to n − 1
            left ← state[(i − 1) mod n]
            center ← state[i]
            right ← state[(i + 1) mod n]
            next[i] ← LOCAL-OUTPUT(R, left, center, right)
        if next = state
            append state to fixed
    return fixed
```

The running time is $O(n2^n)$ and the output storage is $O(nN_{R,n})$, where $N_{R,n}=|\operatorname{Fix}(R,n)|$; a counting-only variant uses $O(n)$ working space. Transfer-matrix methods can improve fixed-point counting because the constraint has finite range, but exhaustive enumeration is transparent and adequate for small $n$.

## 8. Numerical examples

The local table of Rule 110 in descending neighborhood order is

| Neighborhood | $111$ | $110$ | $101$ | $100$ | $011$ | $010$ | $001$ | $000$ |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Output | $0$ | $1$ | $1$ | $0$ | $1$ | $1$ | $1$ | $0$ |

The polynomial $r+c+cr+\ell cr$ produces the same row. Three immediate ring experiments follow for every $n\ge1$:

$$
|\operatorname{Fix}(0,n)|=1,
$$

$$
|\operatorname{Fix}(204,n)|=2^n,
$$

and

$$
1\le |\operatorname{Fix}(110,n)|<2^n.
$$

The lower bound for Rule 110 comes from $\mathbf 0$; the strict upper bound comes from excluding $\mathbf 1$. These inequalities do not claim a complete formula for the number of Rule 110 fixed points. Rather, they are uniform, exact consequences that hold at every period.

A second numerical diagnostic is one-step evolution. Starting from an arbitrary state, Rule 0 reaches $\mathbf 0$ in one step. Rule 204 leaves the state unchanged. Rule 110 sends $\mathbf 1$ to $\mathbf 0$, while more varied initial states may generate structured, propagating behavior. This contrast shows why a fixed-point census alone loses the transient and transport phenomena central to computation.

## 9. Which dimension?

A claim that the “dimension” of a fixed-point variety measures complexity is incomplete until the invariant is specified. At least four candidates must be distinguished.

### 9.1 Fixed-point cardinality

The simplest invariant is

$$
N_{R,n}=|\operatorname{Fix}(R,n)|.
$$

It distinguishes Rule 0 from Rule 204 maximally. It is not a geometric dimension, and it grows with the chosen period.

### 9.2 Krull dimension

The quotient

$$
A_n/I_{R,n}
$$

contains the Boolean equations $x_i^2-x_i$. It is a finite-dimensional algebra over $\mathbb F_2$, and its spectrum is zero-dimensional when nonempty. Consequently, Krull dimension does not record whether the fixed set has one point or $2^n$ points. Calling the latter “dimension $n$” confuses the dimension of the ambient vector space $\mathbb F_2^n$ with the Krull dimension of the finite algebraic set.

### 9.3 Coordinate-algebra vector-space dimension

The finite number

$$
\dim_{\mathbb F_2}(A_n/I_{R,n})
$$

can encode multiplicity and, for reduced Boolean solution sets, agrees with the number of points after suitable decomposition. It is algebraically meaningful but is not Krull dimension.

### 9.4 Asymptotic fixed-point entropy

One can study the exponential growth rate

$$
h_{\mathrm{fix}}(R)=\limsup_{n\to\infty}\frac{1}{n}\log_2 N_{R,n}.
$$

For Rule 0 this value is $0$, while for Rule 204 it is $1$. This invariant is closer to an effective dimension per cell, but it measures stationary combinatorial freedom, not temporal computational power.

Any empirical comparison with dynamical classes should report these quantities separately. A correlation involving one should not be presented as a theorem about another.

## 10. Applications and broader connections

### 10.1 Constraint solving

Fixed points of a periodic cellular automaton form a Boolean constraint-satisfaction problem. The polynomial equations can be handled by exhaustive search, binary decision diagrams, satisfiability solvers, Gröbner-basis techniques, or transfer matrices. Locality makes the constraint graph sparse and cyclic.

### 10.2 Symbolic dynamics

A fixed configuration is a bi-infinite word whose every length-three window obeys a local compatibility condition. The allowed windows define a shift of finite type. Fixed-point counting on rings can therefore be related to closed walks in a finite directed graph, enabling traces of transfer-matrix powers to replace exhaustive enumeration.

### 10.3 Digital circuits

The algebraic normal form expresses a rule as an exclusive-or of conjunctions. For Rule 110,

$$
r+c+cr+\ell cr
$$

translates directly into an XOR-AND circuit. Polynomial degree records the maximum interaction order in this representation, while monomial count gives a simple implementation cost proxy.

### 10.4 Spacetime algebra

Introduce variables $x_{i,t}$ for site $i$ and time $t$. The evolution equations become

$$
x_{i,t+1}=p_R(x_{i-1,t},x_{i,t},x_{i+1,t}).
$$

Together with Boolean equations, these define finite spacetime windows as algebraic sets. Unlike a fixed-point equation, this construction retains propagation, collisions, temporal periods, and transient computation. It is therefore a more promising foundation for connecting algebraic invariants to computational behavior.

## 11. Discussion

The algebraic translation succeeds completely at the local level. There is no approximation: every elementary rule is exactly a degree-at-most-three multilinear polynomial over $\mathbb F_2$. Rule 110’s four-term expression gives a compact symbolic account of its truth table. On finite rings, fixed configurations are exactly the rational points satisfying a natural polynomial ideal.

The extremal examples also behave as intuition suggests. Rule 0 destroys all information and has one fixed point. Rule 204 preserves all information by doing nothing and fixes every point. If the goal were merely to measure stationary freedom, fixed-point count or entropy would be sensible invariants.

The difficulty appears when stationary freedom is identified with dynamical complexity. Computation requires state changes. Signals must move and interact. Memory may be stored in persistent but nonstationary structures. A fixed-point locus deletes all of that information by imposing $x_{i,t+1}=x_{i,t}$. Rule 204 then appears maximally rich precisely because the imposed equation is automatic, even though its trajectories contain no events. Rule 110 appears less than maximal because some configurations evolve, which is part of the source of its dynamical interest.

Thus the counterexample is constructive rather than destructive. It does not reject algebraic geometry; it redirects the object of study. A useful geometry of cellular computation should encode trajectories, periodic orbits, preimage trees, or spacetime diagrams. It may then ask how families of solutions grow with spatial and temporal size, how components compose under concatenation, and which algebraic signatures correspond to mobile information carriers.

The proposed language of sheaves also requires precision. One may assign local admissible patterns to intervals and use restriction maps between overlapping intervals; compatible local data then glue into global configurations or histories. Such a construction can organize local-to-global constraints. However, richness of global sections must be defined by a concrete invariant before it can be compared with computational universality. The present fixed-point theorems provide boundary conditions that any such theory must respect: the identity rule has all stationary sections, while a universal rule need not.

## 12. Future work

Several directions follow naturally.

1. **Periodic enumeration for all rules.** Count fixed points for all $256$ rules and small periods $n$, then use transfer matrices to extend the range. Exact counts should be reported alongside period and boundary convention.

2. **Uniform algebraic-normal-form theory.** Compute and classify the unique multilinear polynomial of every elementary rule. Degree, monomial support, affine equivalence, and left-right or color symmetries may provide useful structural coordinates.

3. **Separation of invariants.** Maintain a strict distinction among Krull dimension, coordinate-ring dimension, fixed-point cardinality, and asymptotic entropy. This is necessary before testing correlations against any dynamical classification.

4. **Explicit complexity data.** Compare algebraic invariants with a clearly defined and sourced classification of rule behavior. The Rule 110 nonmaximality result shows that the original maximal-fixed-locus prediction must first be revised.

5. **Spacetime rather than stillness.** Analyze algebraic sets of finite spacetime diagrams, temporal cycles, and admissible histories. Turing completeness concerns unbounded evolution, whereas a fixed-point locus discards transient and propagating behavior.

6. **Local-to-global structures.** Develop presheaves or sheaves of admissible patterns on spatial and spacetime regions, specify their restriction maps, and investigate extension and gluing obstructions. Quantitative invariants of these structures may capture organization absent from raw point counts.

## 13. Conclusion

Elementary cellular automata admit a direct algebraic-geometric formulation. Their local functions are multilinear polynomials over $\mathbb F_2$, their global updates are polynomial maps, and their periodic fixed states are zeros of explicit Boolean polynomial ideals. Rule 110 is represented by

$$
r+c+cr+\ell cr.
$$

Rule 0 has exactly one fixed configuration. Rule 204 fixes every configuration. Rule 110 fixes the all-zero configuration but not the all-one configuration, and therefore has a proper, nonempty fixed-point locus.

These facts settle the strongest proposed connection between universality and maximal fixed-point geometry: it is false. The identity rule is maximal in stationary states but dynamically inert; Rule 110 is computationally universal but not stationary on every input. Fixed-point geometry remains an exact and useful description of stability, yet stability is only one slice of dynamics. The appropriate next object is a geometry of spacetime histories, where algebra can study not merely which patterns stand still, but how information moves.