# A Coefficientwise Character–Orbit Bridge for Graded Moonshine Series

**Aristotle**  
**28 July 2026**

## Abstract

Moonshine associates class-indexed formal series with graded symmetry data. This paper isolates an exact general mechanism underlying such series. Let a finite group $G$ act on finite sets $X_n$ indexed by nonnegative grades. For $g\in G$, define the fixed-point series $T_g(q)=\sum_{n\ge0}|X_n^g|q^n$, and define the orbit series $O(q)=\sum_{n\ge0}|X_n/G|q^n$. We prove the coefficientwise identity

$$
\sum_{g\in G}T_g(q)=|G|O(q),
$$

or equivalently $|G|^{-1}\sum_g|X_n^g|=|X_n/G|$ at each grade. We also prove that every coefficient, and therefore every fixed-point series, is invariant under conjugacy. These statements lift Burnside’s orbit-counting theorem to graded formal generating functions and explain how permutation-character data yield enumerative information without analytic assumptions. We give class-compressed algorithms, complexity bounds, and examples. Finally, we distinguish this valid additive bridge from a proposed product of McKay–Thompson series: standard normalization, modular weight, common-group, cusp, and information-loss issues prevent the product claim from following as stated.

## 1. Introduction

The Monster group $M$ is the largest sporadic finite simple group. Its order is

$$
|M|=2^{46}3^{20}5^9 7^6 11^2 13^3 17\cdot19\cdot23\cdot29\cdot31\cdot41\cdot47\cdot59\cdot71,
$$

approximately $8\times10^{53}$. Monstrous moonshine links representations of $M$ to modular functions. The classical opening observation concerns

$$
j(\tau)=q^{-1}+744+196884q+21493760q^2+\cdots,
\qquad q=e^{2\pi i\tau},
$$

whose positive-degree coefficients decompose into dimensions of Monster representations. More generally, a graded Monster module supplies trace series indexed by conjugacy classes, called McKay–Thompson series.

The grandeur of this correspondence encourages ambitious compression principles. One may ask whether a product of all class-indexed series is itself a single modular object encoding the entire group. Before such a claim can be meaningful, however, normalization, indexing, modular groups, multipliers, cusp orders, weights, and recoverability must all be specified. Standard McKay–Thompson series begin with $q^{-1}$ and generally have weight $0$. Their product therefore has a pole whose order depends dramatically on whether one multiplies over classes or elements, and no positive weight arises merely from multiplication.

This paper develops a different operation whose meaning is exact: coefficientwise summation and averaging. The construction applies to any finite group acting on finite graded sets. Its coefficients are permutation-character values, so it belongs naturally to character theory; their average counts orbits, so it simultaneously belongs to enumerative combinatorics. The resulting identity is algebraic and coefficientwise. It requires neither convergence nor modularity.

Three results form the core of the paper:

1. At each grade, the sum of all fixed-point counts is the group order times the number of orbits.
2. Summing the fixed-point series coefficientwise gives the group order times the orbit-generating series.
3. Fixed-point coefficients and series are constant on conjugacy classes.

The first is Burnside’s lemma. The second is its graded generating-function lift. The third justifies replacing element-indexed data by class-indexed data. Together they provide a rigorous model of how families of symmetry traces encode counts of inequivalent objects.

## 2. Definitions and setting

### 2.1 Graded finite actions

Let $G$ be a finite group. A **graded finite $G$-set** is a sequence

$$
X=(X_0,X_1,X_2,\ldots)
$$

of finite sets, each equipped with a left action of $G$. Thus, for each $n\ge0$, every $g\in G$ determines a permutation $x\mapsto g\cdot x$ of $X_n$, satisfying

$$
1\cdot x=x,
\qquad
(gh)\cdot x=g\cdot(h\cdot x).
$$

No compatibility between distinct grades is required. This flexibility permits the grade to encode degree, energy, cardinality, weight, or any discrete complexity statistic.

For $g\in G$, define its fixed-point set in grade $n$ by

$$
X_n^g=\{x\in X_n:g\cdot x=x\}.
$$

The **fixed-point coefficient** is

$$
a_n(g)=|X_n^g|.
$$

The function $g\mapsto a_n(g)$ is the permutation character of the action on $X_n$. Indeed, if the permutation representation on functions or formal basis vectors indexed by $X_n$ is considered, its trace at $g$ equals the number of basis elements fixed by $g$.

### 2.2 Formal fixed-point series

The **fixed-point series** associated with $g$ is

$$
T_g(q)=\sum_{n\ge0}a_n(g)q^n
      =\sum_{n\ge0}|X_n^g|q^n.
$$

Throughout this paper, these are formal power series with nonnegative integer coefficients. A formal identity

$$
\sum_{n\ge0}u_nq^n=\sum_{n\ge0}v_nq^n
$$

means precisely that $u_n=v_n$ for all $n\ge0$. Questions of numerical convergence are therefore irrelevant to the principal theorem.

### 2.3 Orbits and the orbit series

For $x\in X_n$, its orbit and stabilizer are

$$
G\cdot x=\{g\cdot x:g\in G\},
\qquad
G_x=\{g\in G:g\cdot x=x\}.
$$

The set $X_n/G$ consists of all orbits in $X_n$. Its cardinality counts objects of grade $n$ up to the symmetry group $G$. Define the **orbit coefficient**

$$
b_n=|X_n/G|
$$

and the **orbit-counting series**

$$
O(q)=\sum_{n\ge0}b_nq^n
    =\sum_{n\ge0}|X_n/G|q^n.
$$

The orbit–stabilizer theorem gives

$$
|G\cdot x|=\frac{|G|}{|G_x|}.
$$

This elementary relation drives the main counting identity.

## 3. Main results

### 3.1 The coefficient identity

**Theorem 1 (Coefficientwise Character–Orbit Theorem).** Let $G$ be a finite group acting on a finite set $X_n$. Then

$$
\sum_{g\in G}|X_n^g|=|G|\,|X_n/G|.
$$

Consequently,

$$
\frac{1}{|G|}\sum_{g\in G}|X_n^g|=|X_n/G|.
$$

**Proof sketch.** Consider the incidence set

$$
I_n=\{(g,x)\in G\times X_n:g\cdot x=x\}.
$$

Counting first by group element gives

$$
|I_n|=\sum_{g\in G}|X_n^g|.
$$

Now partition $X_n$ into orbits. For an orbit represented by $x$, every point $y$ in that orbit has a stabilizer conjugate to $G_x$, hence of the same size. The number of incident pairs whose second coordinate lies in this orbit is

$$
|G\cdot x|\,|G_x|
=\frac{|G|}{|G_x|}|G_x|
=|G|.
$$

Every orbit contributes exactly $|G|$. There are $|X_n/G|$ orbits, giving $|I_n|=|G|\,|X_n/G|$. Dividing by $|G|>0$ proves the average formula. $\square$

A notable consequence is integrality. The average of the fixed-point counts is visibly rational a priori, but the theorem shows that it is a nonnegative integer because it counts orbits.

### 3.2 The formal-series identity

**Theorem 2 (Graded Fixed-Point Series Theorem).** Let a finite group $G$ act on every finite grade $X_n$. Then the fixed-point and orbit series satisfy

$$
\sum_{g\in G}T_g(q)=|G|\,O(q)
$$

as formal power series.

**Proof sketch.** The coefficient of $q^n$ on the left is

$$
\sum_{g\in G}|X_n^g|,
$$

while the coefficient on the right is $|G|\,|X_n/G|$. These are equal by Theorem 1 for every $n$. Equality at all coefficients is exactly equality of formal series. $\square$

The theorem is additive rather than multiplicative. It preserves a transparent semantic interpretation: the coefficientwise group average is the orbit count. It is also independent of analytic structure. If the series later turn out to converge or satisfy modular transformation laws, those are additional properties rather than prerequisites.

### 3.3 Conjugacy invariance

**Theorem 3 (Conjugacy Invariance of Fixed-Point Coefficients).** For $g,h\in G$ and every grade $n$,

$$
|X_n^{hgh^{-1}}|=|X_n^g|.
$$

**Proof sketch.** Define

$$
\Phi_h:X_n^g\longrightarrow X_n^{hgh^{-1}},
\qquad
\Phi_h(x)=h\cdot x.
$$

If $g\cdot x=x$, then

$$
(hgh^{-1})\cdot(h\cdot x)
=h\cdot(g\cdot x)
=h\cdot x,
$$

so the map is well defined. Its inverse sends $y$ to $h^{-1}\cdot y$. Thus $\Phi_h$ is a bijection, and the fixed-point sets have equal cardinality. $\square$

**Corollary 4 (Conjugacy Invariance of Fixed-Point Series).** Under the same assumptions,

$$
T_{hgh^{-1}}(q)=T_g(q).
$$

**Proof sketch.** Theorem 3 gives equality of the coefficient of $q^n$ for every $n$. $\square$

Thus fixed-point series are naturally indexed by conjugacy classes. If $\mathcal C(G)$ is the set of conjugacy classes, $g_C$ is a representative of $C$, and $|C|$ is its size, then Theorem 2 can be compressed as

$$
\sum_{C\in\mathcal C(G)}|C|T_{g_C}(q)=|G|O(q).
$$

This formula is crucial for very large groups: one needs one series per conjugacy class, together with class sizes, rather than one separate series per element.

## 4. Relation to character theory

For a finite $G$-set $X_n$, let $\mathbb C[X_n]$ be the complex vector space with basis $X_n$. The action of $G$ permutes this basis. The character $\chi_n$ of this permutation representation satisfies

$$
\chi_n(g)=|X_n^g|.
$$

The multiplicity of the trivial representation in $\mathbb C[X_n]$ is the inner product

$$
\langle\chi_n,1\rangle
=\frac{1}{|G|}\sum_{g\in G}\chi_n(g).
$$

The invariant vectors are exactly the functions constant on each orbit, so their dimension is $|X_n/G|$. Therefore Theorem 1 can be restated as

$$
\langle\chi_n,1\rangle=|X_n/G|.
$$

The graded theorem then says that the generating function for trivial-isotypic multiplicities is the orbit series:

$$
\sum_{n\ge0}\langle\chi_n,1\rangle q^n=O(q).
$$

This interpretation extends beyond literal permutation actions. For a graded finite-dimensional complex representation $V=\bigoplus_{n\ge0}V_n$, the trace series

$$
T_g^V(q)=\sum_{n\ge0}\operatorname{tr}(g\mid V_n)q^n
$$

satisfies

$$
\frac{1}{|G|}\sum_{g\in G}T_g^V(q)
=\sum_{n\ge0}\dim(V_n^G)q^n.
$$

The proof uses the averaging projector $|G|^{-1}\sum_g g$ onto the invariant subspace. The set-theoretic theorem studied here is the nonnegative-integer permutation-character case, where invariant dimensions become literal orbit counts.

## 5. Algorithms

### 5.1 Direct grade-by-grade averaging

Suppose the actions are given explicitly as permutations. For grades $0$ through $N$, compute the number of fixed points of every group element and average.

**Algorithm 1 (Direct Fixed-Point Averaging).** For each grade $n$, initialize $S_n=0$. For each $g\in G$, scan $X_n$ and increment $S_n$ whenever $g\cdot x=x$. Return $S_n/|G|$.

If $m_n=|X_n|$, the running time is

$$
O\!\left(|G|\sum_{n=0}^{N}m_n\right),
$$

assuming each action evaluation and equality test costs constant time. The additional memory can be $O(N)$ beyond storage of the action.

The theorem guarantees exact divisibility of $S_n$ by $|G|$. A failed divisibility check therefore diagnoses inconsistent input or an implementation error.

### 5.2 Conjugacy-class compression

When fixed-point counts are supplied by class rather than by element, conjugacy invariance yields a faster method.

**Algorithm 2 (Class-Weighted Orbit Reconstruction).** For each conjugacy class $C$, obtain its size $|C|$ and representative coefficient vector $(a_0(g_C),\ldots,a_N(g_C))$. Compute

$$
S_n=\sum_C|C|a_n(g_C),
\qquad
b_n=S_n/|G|.
$$

If $k$ is the number of conjugacy classes, the arithmetic complexity is $O(kN)$ once representative coefficients are known, with $O(N)$ working memory. For the Monster, $k=194$, dramatically smaller than $|M|$.

### 5.3 Computing class invariance

Given explicit permutations for $g$ and $hgh^{-1}$, one can compare their fixed-point counts directly. More structurally, one may transport fixed points by $x\mapsto h\cdot x$. This produces not merely equal counts but an explicit bijection. For a finite list of grades, the cost of count comparison is $O(\sum_n m_n)$; constructing the transported list has the same order.

## 6. Numerical examples

### 6.1 Rotations of a square

Let $G=C_4$ act on four vertices. In grade $1$, take single vertices. Fixed-point counts for rotations by $0$, $90$, $180$, and $270$ degrees are

$$
(4,0,0,0).
$$

Their sum is $4$, and division by $|C_4|=4$ gives one orbit.

In grade $2$, take unordered pairs of distinct vertices. The fixed-point counts are

$$
(6,0,2,0).
$$

The average is $8/4=2$, corresponding to the edge orbit and the diagonal orbit. For these two grades,

$$
\sum_{g\in C_4}T_g(q)=4q+8q^2,
\qquad
4O(q)=4q+8q^2.
$$

### 6.2 Colorings and Pólya-style enumeration

Let $C_4$ rotate colorings of the square’s vertices with two colors. There are $2^4=16$ colorings. The identity fixes $16$; each quarter-turn fixes $2$ monochromatic colorings; the half-turn fixes $2^2=4$ colorings. Hence the orbit count is

$$
\frac{16+2+4+2}{4}=6.
$$

The same computation with $c$ colors gives

$$
\frac{c^4+2c+c^2}{4}
$$

rotation classes. This demonstrates the bridge’s role in classical enumeration: fixed points under each symmetry become counts modulo all symmetries.

### 6.3 The symmetric group on three letters

Let $S_3$ act on the three-element set $\{1,2,3\}$. The identity fixes $3$ points, each of the three transpositions fixes $1$, and each of the two $3$-cycles fixes $0$. Class weighting gives

$$
\frac{1\cdot3+3\cdot1+2\cdot0}{6}=1.
$$

The action is transitive, so one orbit is correct. This example also makes conjugacy compression explicit: only the three symmetry types need to be evaluated.

## 7. Why a universal product theorem does not follow

A proposed product over all McKay–Thompson series raises several independent obstacles.

First, standard McKay–Thompson normalization has leading term $q^{-1}$. A product over one representative of each of the Monster’s $194$ conjugacy classes begins with

$$
q^{-194}.
$$

A literal product over every $g\in M$ begins instead with

$$
q^{-|M|}.
$$

These products are not interchangeable, and both are meromorphic at the infinite cusp under the standard normalization.

Second, McKay–Thompson series are modular functions, usually of weight $0$. The product of weight-zero functions remains weight $0$ when a common transformation law exists. A weight such as $|M|/24$ is not created by multiplication alone.

Third, different series can be invariant under different genus-zero groups, often involving Atkin–Lehner extensions. To prove that their product is modular, one must identify a common subgroup, reconcile any multipliers, and analyze behavior at all cusps. Formal multiplication of Fourier expansions does not establish these analytic and transformation properties.

Fourth, a product generally loses factorwise data. If $A(q)B(q)=P(q)$ is known, neither $A$ nor $B$ is determined without additional constraints. Consequently, recovering an entire character table, element orders, or maximal-subgroup data from one product requires an explicit injective reconstruction theorem. Standard character recovery instead uses the full family of class traces grade by grade and the linear algebra of the character table.

These observations do not rule out every carefully normalized product identity. They show that the broad product claim is neither a consequence of the additive bridge nor well posed without substantial extra structure. Theorems 1–3 capture the unconditional relationship supplied by finite-group actions.

## 8. Applications

### 8.1 Enumeration modulo symmetry

The orbit series $O(q)$ counts inequivalent graded objects. Applicable settings include necklaces by length, graphs by number of edges, colorings by weight, molecular configurations by composition, and lattice states by energy. When fixed points are easier to compute than orbits, the average formula converts local symmetry constraints into global enumeration.

### 8.2 Invariant state counting

In physics, a finite symmetry may identify states or restrict attention to invariant states. For permutation bases, orbit counts equal invariant dimensions. The graded identity then computes a partition function for invariant states by averaging twisted traces. This finite-group mechanism is a discrete prototype of projection onto gauge-invariant sectors.

### 8.3 Integrity checks for trace data

Suppose candidate coefficient vectors $a_n(g_C)$ are available for conjugacy classes. A necessary condition for permutation-character data is

$$
\sum_C|C|a_n(g_C)\equiv0\pmod{|G|}
$$

for every $n$, with nonnegative quotient. Conjugate elements must also have identical vectors. These tests do not establish modularity or identify a moonshine module, but they are strong consistency checks.

### 8.4 Compression of large symmetry systems

For enormous groups, elementwise computation is impossible. Conjugacy invariance compresses every class function from $|G|$ values to $k$ values, where $k$ is the number of conjugacy classes. The class-weighted theorem preserves the exact group average under this compression. This is the practical reason class-indexed series, rather than element-indexed tables, are central in character theory.

## 9. Discussion

The main identity is elementary in origin but conceptually useful in the moonshine setting. It separates three layers often conflated in ambitious narratives:

1. **Finite symmetry:** fixed points, conjugacy, orbits, and characters.
2. **Grading:** packaging one character per grade into a formal series.
3. **Analytic modularity:** transformation laws, levels, multipliers, and cusp behavior.

The first two layers alone prove the coefficientwise additive theorem. The third demands additional information and cannot be inferred merely from the existence of a formal trace series.

This separation clarifies what it means for graded character data to “encode” enumeration. Encoding here has an explicit decoding operation: take the group average at each coefficient. The decoder is linear, exact, and integral. By contrast, the assertion that one product encodes all group structure lacks a specified inverse and is vulnerable to information loss.

The theorem also explains the privileged role of the trivial character. Averaging over the group extracts precisely the trivial-isotypic component. Other irreducible multiplicities can be recovered by weighted character inner products. If $\psi$ is an irreducible character, then the multiplicity of $\psi$ in a graded representation with character $\chi_n$ is

$$
m_{n,\psi}=\frac{1}{|G|}\sum_{g\in G}\chi_n(g)\overline{\psi(g)}.
$$

Thus the orbit theorem is one member of a larger Fourier analysis on finite groups. In the permutation case, the trivial component enjoys the direct combinatorial interpretation as orbits.

## 10. Future work

Several directions extend the present bridge.

First, the permutation-character setting can be generalized systematically to graded complex representations, supertraces, and virtual characters. The average then computes invariant dimensions or signed invariant indices rather than orbit counts.

Second, class-weighted coefficient data can be combined with the full irreducible character table to reconstruct multiplicity generating functions. This provides a precise, linear meaning for the claim that trace series encode graded representation content.

Third, any proposed product of moonshine functions should be reformulated with explicit choices: whether the index set consists of elements or conjugacy classes, how poles are normalized, which common modular subgroup is used, what multipliers occur, and what divisor appears at every cusp. Only after these data are fixed can modularity and weight be investigated.

Fourth, reconstruction claims should be expressed as injectivity problems. One must define the map from class-indexed trace data to the proposed compressed object and prove which invariants can be recovered. Counterexamples in smaller groups may reveal what information multiplication discards.

Finally, computational studies can evaluate initial fixed-point or trace coefficients by conjugacy class, test class invariance and divisibility, and compare orbit coefficients with independent enumeration. Such experiments provide evidence for candidate graded models while keeping algebraic consistency distinct from modularity.

### 10.1 Structural questions for moonshine data

A useful intermediate objective is to determine exactly which features of a graded action are visible from its class-indexed fixed-point series. The orbit series is visible by averaging, and multiplicities of irreducible constituents are visible after pairing with irreducible characters. By contrast, nonisomorphic actions can share a permutation character, so the series need not recover the underlying sets or their equivariant incidence structure. Establishing the boundary between recoverable and lost information is essential before making stronger encoding claims.

There is also an analytic program separate from this algebraic one. If a class-indexed series is known to be a modular function, one can ask how linear averaging interacts with modular transformation laws. A sum of functions modular for different groups is modular for a suitable common subgroup when transformation laws are compatible, but determining a useful maximal common group and controlling poles remain substantive tasks. This route preserves the transparent additive decoder while allowing genuine moonshine structure to enter explicitly.

## 11. Conclusion

For a finite group acting on finite graded sets, fixed-point data and orbit enumeration are connected by an exact coefficientwise law:

$$
\sum_{g\in G}T_g(q)=|G|O(q).
$$

Each coefficient is Burnside’s lemma, and the entire identity is its formal-series lift. The associated series are constant on conjugacy classes, permitting exact class-level compression. The result gives a rigorous and computationally useful interpretation of averaged character-like series: they count inequivalent graded objects.

This additive bridge does not establish a universal product formula for McKay–Thompson series. Standard product claims face normalization, cusp, modular-group, weight, and recoverability obstacles. Precision therefore changes the slogan. A finite group is not automatically encoded by one product; rather, its family of graded symmetry traces carries structured information, and coefficientwise averaging extracts the orbit-generating series exactly.