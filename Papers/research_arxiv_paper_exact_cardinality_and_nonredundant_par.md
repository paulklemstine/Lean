# Exact Cardinality and Nonredundant Parametrization of Character–Polynomial Codes

**Aristotle**  
**July 15, 2026**

## Abstract

Character–polynomial codes are obtained by evaluating polynomial data over finite fields and converting the resulting values into phases through additive characters. Over extension fields, distinct coefficient choices can yield identical words because additive characters see only trace-visible information. We give an abstract treatment of this redundancy that separates the trace-like additive map from the subsequent evaluation map. If the latter is injective, two parameters encode the same word exactly when their difference lies in the trace kernel. It follows that the code is canonically parametrized by the quotient of the original parameter group by this kernel. Any transversal of the kernel cosets provides an equivalent concrete, nonredundant polynomial family. For finite-dimensional vector spaces over a finite field $F$ of order $q$, the exact number of words is $q^r$, where $r$ is the dimension of the trace image, rather than the dimension of the original coefficient space. We extend the collision criterion to indexed coefficient families and explain algorithms for quotient counting, canonical representative selection, and collision testing. The results isolate the algebraic correction required in cardinality and dimension calculations and provide a general pipeline for removing trace-induced duplication.

## 1. Introduction

Let $K$ be a finite extension field and let $f$ range over a prescribed polynomial family. A character–polynomial construction evaluates $f$ at selected points and applies an additive character to each value, producing a vector of complex roots of unity. Such phase-valued words connect finite-field algebra with Fourier analysis, sequence design, sensing, and coding. Their apparent number is often estimated by counting admissible coefficient vectors.

That estimate is valid only if the parametrization is injective. Additive characters over extension fields are commonly built from a field trace. For characteristic $p$, a standard character has the form

$$
\chi(x)=\exp\!\left(\frac{2\pi i}{p}\operatorname{Tr}_{K/\mathbf F_p}(x)\right).
$$

Consequently, $x$ and $x+z$ have the same character value whenever $\operatorname{Tr}_{K/\mathbf F_p}(z)=0$. When coefficients enter an encoding only through trace-visible combinations, trace-zero changes can leave the entire word unchanged. The raw polynomial family then contains multiple names for the same codeword.

This paper identifies the exact equivalence relation on parameters and resolves the resulting counting problem. The essential setting is deliberately general. Let $A$ be an additive parameter group, let $B$ hold the visible data, let $\tau:A\to B$ be additive, and let $E:B\to W$ be an injective map into a word space. The encoder is the composite

$$
C=E\circ\tau.
$$

All loss of information occurs in $\tau$. The kernel $\ker\tau$ acts on $A$ by translation, and its orbits are exactly the fibers of $C$. Therefore the natural parameter space is the quotient $A/\ker\tau$. This observation yields exact image cardinality, canonical abstract parametrization, concrete transversals, and coordinatewise criteria for polynomial coefficient families.

The framework also clarifies the role of cyclotomic cosets. Frobenius symmetries among polynomial exponents determine how concrete coefficient systems feed into trace-visible data. Those arithmetic calculations are needed to compute the rank of $\tau$ for a particular exponent set. Once that rank and kernel are known, however, the quotient results apply without further assumptions about the polynomial presentation.

## 2. Algebraic setting

### 2.1 Additive parameters and visible data

Throughout, $A$ and $B$ are additive abelian groups, $W$ is an arbitrary set, and

$$
\tau:A\longrightarrow B
$$

is an additive homomorphism. The subgroup

$$
N=\ker\tau=\{a\in A:\tau(a)=0\}
$$

contains precisely the invisible parameter changes. Let $E:B\to W$ be injective. We call

$$
C(a)=E(\tau(a))
$$

the encoder and

$$
\mathcal C=\operatorname{im}C=\{C(a):a\in A\}
$$

the resulting code.

The injectivity assumption on $E$ is substantive and minimal for the stated conclusions. It says that the evaluation-and-character stage distinguishes all trace-visible data under consideration. If $E$ is not injective, its fibers introduce additional identifications; then the kernel of $\tau$ still gives collisions but need not describe all of them.

### 2.2 Quotients and transversals

Define an equivalence relation on $A$ by

$$
a\sim b \quad\Longleftrightarrow\quad a-b\in N.
$$

Its equivalence classes are the cosets $a+N$, and the set of classes is the quotient group $A/N$. We write $[a]$ for the class of $a$.

A subset $T\subseteq A$ is a **kernel transversal** if every coset of $N$ contains exactly one element of $T$. Thus, for every $q\in A/N$, there exists a unique $t\in T$ such that $[t]=q$. A quotient is canonical but abstract; a transversal is a concrete choice of one raw parameter per equivalence class.

### 2.3 Linear specialization

Let $F$ be a finite field of order $q$, and let $K$ and $R$ be finite-dimensional $F$-vector spaces. Suppose

$$
\tau:K\longrightarrow R
$$

is $F$-linear. Its rank is

$$
r=\dim_F(\operatorname{im}\tau).
$$

Rank–nullity gives

$$
\dim_F K=\dim_F(\ker\tau)+r.
$$

Because an $n$-dimensional vector space over $F$ has $q^n$ elements, the quotient $K/\ker\tau$ has $q^r$ elements.

## 3. The collision mechanism

### Theorem 3.1 (Exact collision criterion)

For all $a,b\in A$,

$$
C(a)=C(b)
\quad\Longleftrightarrow\quad
a-b\in\ker\tau.
$$

#### Proof sketch

By definition, $C(a)=E(\tau(a))$ and $C(b)=E(\tau(b))$. Since $E$ is injective, these values are equal if and only if $\tau(a)=\tau(b)$. Additivity gives

$$
\tau(a)-\tau(b)=\tau(a-b),
$$

so equality is equivalent to $\tau(a-b)=0$. This is exactly $a-b\in\ker\tau$. $\square$

The theorem completely describes the fibers:

$$
C^{-1}(C(a))=a+\ker\tau.
$$

Every word has one entire kernel coset as its set of descriptions. In the finite setting all fibers therefore have the same size $|\ker\tau|$.

### Corollary 3.2 (Injectivity criterion)

The original parametrization $C:A\to W$ is injective if and only if $\ker\tau=\{0\}$.

#### Proof sketch

If the kernel is trivial, Theorem 3.1 turns $C(a)=C(b)$ into $a-b=0$, hence $a=b$. Conversely, if $z\in\ker\tau$, then $C(z)=C(0)$; injectivity forces $z=0$. $\square$

### Corollary 3.3 (Uniform redundancy)

If $A$ is finite, every codeword has exactly $|\ker\tau|$ preimages under $C$.

#### Proof sketch

For any $a\in A$, Theorem 3.1 identifies the fiber over $C(a)$ with the coset $a+\ker\tau$. Translation by $a$ is a bijection from $\ker\tau$ to that coset. $\square$

## 4. Canonical quotient parametrization

Because $C$ is constant on kernel cosets, define

$$
\overline C:A/\ker\tau\longrightarrow W,
\qquad
\overline C([a])=C(a).
$$

This is well-defined: if $[a]=[b]$, then $a-b\in\ker\tau$, and Theorem 3.1 gives $C(a)=C(b)$.

### Theorem 4.1 (Nonredundant quotient encoder)

The induced map $\overline C$ is injective.

#### Proof sketch

Suppose $\overline C([a])=\overline C([b])$. Then $C(a)=C(b)$, so Theorem 3.1 yields $a-b\in\ker\tau$. Hence $[a]=[b]$. $\square$

### Theorem 4.2 (Preservation of the code image)

The quotient encoder produces exactly the original code:

$$
\operatorname{im}\overline C=\operatorname{im}C.
$$

#### Proof sketch

Every value of $\overline C$ has the form $\overline C([a])=C(a)$ and hence lies in $\operatorname{im}C$. Conversely, every $C(a)$ equals $\overline C([a])$ and hence lies in $\operatorname{im}\overline C$. $\square$

Together, Theorems 4.1 and 4.2 show that

$$
\overline C:A/\ker\tau\longrightarrow\mathcal C
$$

is a bijection. This is stronger than a numerical equality: it identifies each codeword with one and only one equivalence class of parameters.

### Theorem 4.3 (Exact cardinality)

If the relevant sets are finite, then

$$
|\mathcal C|=|A/\ker\tau|.
$$

If $A$ is finite, this is equivalently

$$
|\mathcal C|=\frac{|A|}{|\ker\tau|}.
$$

#### Proof sketch

The first formula follows from the bijection above. For the second, the cosets partition $A$, and every coset has $|\ker\tau|$ elements. $\square$

This formula gives both the corrected count and the overcount factor. Counting raw parameters exaggerates the code size by exactly $|\ker\tau|$.

## 5. Concrete nonredundant families

Abstract quotient classes are mathematically natural, but an encoder usually expects actual coefficient vectors. A kernel transversal supplies them.

### Theorem 5.1 (Injectivity on a transversal)

Let $T\subseteq A$ contain exactly one representative of each coset of $\ker\tau$. Then the restriction $C|_T$ is injective.

#### Proof sketch

If $a,b\in T$ and $C(a)=C(b)$, Theorem 3.1 gives $[a]=[b]$. Since $T$ contains a unique representative of that class, $a=b$. $\square$

### Theorem 5.2 (Completeness of a transversal)

Under the same assumptions,

$$
\{C(t):t\in T\}=\mathcal C.
$$

#### Proof sketch

The left side is contained in $\mathcal C$ because $T\subseteq A$. For the reverse containment, take $C(a)\in\mathcal C$. The coset $[a]$ has a unique representative $t\in T$. Since $a-t\in\ker\tau$, Theorem 3.1 gives $C(a)=C(t)$. $\square$

### Corollary 5.3 (Transversal–code bijection)

The map $t\mapsto C(t)$ is a bijection from $T$ to $\mathcal C$. In particular, for finite sets,

$$
|T|=|\mathcal C|.
$$

This gives a practical specification for a refined polynomial family: it must contain exactly one element from every kernel coset. No special normal form is required for correctness. Row-reduced coordinates, lexicographically least vectors, and orbit-adapted polynomial representatives are all valid if they satisfy existence and uniqueness per coset.

## 6. Indexed coefficient families

Let $I$ be an index set of allowed monomials. A coefficient family is a function $c:I\to K$, where $K$ and $R$ are additive abelian groups and $\tau:K\to R$ is additive. Define the coefficientwise map

$$
\tau_I:K^I\longrightarrow R^I,
\qquad
(\tau_I(c))(i)=\tau(c(i)).
$$

Suppose an injective post-processing map $E:R^I\to W$ defines the family encoder

$$
C_I(c)=E(\tau_I(c)).
$$

### Lemma 6.1 (Coordinatewise kernel)

For every coefficient family $c:I\to K$,

$$
c\in\ker\tau_I
\quad\Longleftrightarrow\quad
\text{for every }i\in I,\ c(i)\in\ker\tau.
$$

#### Proof sketch

The family $\tau_I(c)$ is zero precisely when each of its coordinates is zero. Its $i$th coordinate is $\tau(c(i))$, which vanishes precisely when $c(i)\in\ker\tau$. $\square$

### Theorem 6.2 (Coordinatewise collision criterion)

For coefficient families $c,d:I\to K$,

$$
C_I(c)=C_I(d)
\quad\Longleftrightarrow\quad
\text{for every }i\in I,\ c(i)-d(i)\in\ker\tau.
$$

#### Proof sketch

Apply Theorem 3.1 to the additive map $\tau_I$. The difference $c-d$ belongs to $\ker\tau_I$ exactly when all coordinate differences belong to $\ker\tau$, by Lemma 6.1. $\square$

When $I$ is finite and each coordinate uses the same map independently, the image rank multiplies by $|I|$. If $\tau$ has rank $r$ over $F$, then $\tau_I$ has rank $|I|r$, and the family code has $q^{|I|r}$ words, provided the post-processing map is injective. Concrete polynomial evaluations may couple coordinates through Frobenius or exponent identities; in that case one must compute the rank of the actual combined visible-data map rather than assume independence.

## 7. Rank form of the cardinality formula

### Theorem 7.1 (Rank cardinality theorem)

Let $F$ be a finite field with $q$ elements, let $K$ and $R$ be finite-dimensional $F$-vector spaces, and let $\tau:K\to R$ be linear. If $E:R\to W$ is injective and $C=E\circ\tau$, then

$$
|\mathcal C|=q^{\dim_F(\operatorname{im}\tau)}.
$$

#### Proof sketch

By Theorem 4.3,

$$
|\mathcal C|=|K/\ker\tau|.
$$

The first isomorphism theorem gives a vector-space isomorphism

$$
K/\ker\tau\cong\operatorname{im}\tau.
$$

If $r=\dim_F(\operatorname{im}\tau)$, then the image has $q^r$ elements. $\square$

### Corollary 7.2 (Effective dimension and redundancy factor)

If $n=\dim_F K$ and $r=\operatorname{rank}\tau$, then the effective code dimension is $r$, the number of words is $q^r$, and every word has

$$
q^{n-r}
$$

raw parameter descriptions.

#### Proof sketch

Rank–nullity gives $\dim_F\ker\tau=n-r$. Corollary 3.3 then gives $|\ker\tau|=q^{n-r}$ descriptions per word. $\square$

### Example 7.3

Consider the map over $\mathbf F_5$

$$
\tau(x_1,x_2,x_3,x_4)=(x_1+x_3,\ x_2+x_4).
$$

Its matrix is

$$
M=
\begin{pmatrix}
1&0&1&0\\
0&1&0&1
\end{pmatrix},
$$

which has rank $2$. The raw space contains $5^4=625$ vectors, while the code contains exactly

$$
5^2=25
$$

words. The kernel consists of vectors $(-s,-t,s,t)$ and has $5^2=25$ elements. Every word therefore has $25$ descriptions. A simple transversal is

$$
T=\{(u,v,0,0):u,v\in\mathbf F_5\}.
$$

It has $25$ elements and maps bijectively to the code.

## 8. Algorithms

### 8.1 Rank-based cardinality computation

For a linear trace-like map represented by an $m\times n$ matrix $M$ over $\mathbf F_q$, perform Gaussian elimination modulo $q$ to compute its rank $r$. The exact code cardinality is $q^r$, the kernel dimension is $n-r$, and the redundancy factor is $q^{n-r}$.

For prime $q$, straightforward elimination uses $O(mn\min\{m,n\})$ field operations and $O(mn)$ storage. More advanced matrix multiplication can improve asymptotic complexity, but ordinary elimination is preferable for moderate code parameters and transparent auditing.

### 8.2 Collision testing

Given parameters $a,b\in F^n$, calculate $d=a-b$ and test whether $Md=0$. By Theorem 3.1, the words collide exactly when this residual vanishes. A dense matrix implementation costs $O(mn)$ field operations and requires no construction of the potentially long codewords.

### 8.3 Canonical transversal construction

Row reduction also constructs representatives. Choose a direct complement $U$ of $\ker M$ in $F^n$, so

$$
F^n=\ker M\oplus U.
$$

Then $U$ contains exactly one representative of every kernel coset and is therefore a transversal. A canonical representative of $a$ is its $U$-component. Equivalently, after identifying pivot and free variables in a row-reduced system, one may normalize the free kernel coordinates to zero while preserving the visible output.

The preprocessing cost is that of elimination. Once a projection onto $U$ is available, canonicalization is a matrix–vector multiplication, typically $O(n^2)$ field operations, or less when the projection is sparse.

### 8.4 Coordinatewise families

If the visible map is genuinely coefficientwise, canonicalize every coefficient independently modulo $\ker\tau$. For $s=|I|$ coefficients and a fixed $d$-dimensional coefficient representation, the cost is $s$ projection operations. If exponent or Frobenius relations couple coefficients, first assemble the global linear map and canonicalize with respect to its full kernel; independent normalization would otherwise risk retaining redundancy or deleting valid distinctions.

## 9. Cyclotomic cosets and character–polynomial structure

For a finite field extension of degree $m$ over $\mathbf F_q$, Frobenius acts by $x\mapsto x^q$. On polynomial exponents modulo an evaluation period $N$, the corresponding action sends

$$
e\longmapsto qe\pmod N.
$$

The orbit

$$
\{e,qe,q^2e,\ldots\}\pmod N
$$

is a $q$-cyclotomic coset. Terms whose exponents lie in the same orbit can become related after applying field trace, because trace is Frobenius-invariant:

$$
\operatorname{Tr}(x^q)=\operatorname{Tr}(x).
$$

Therefore a concrete character–polynomial family should not infer its dimension merely from the number of displayed monomials and coefficient choices. One must determine the linear map from those choices to the trace-visible evaluation data. Cyclotomic cosets organize this map into orbit contributions; kernel relations record redundant combinations; the sum of orbit ranks gives the exponent in the exact cardinality formula.

The abstract results proved above do not assert a particular rank for an unspecified exponent set. Rather, they establish the rigorous endpoint of every such computation: if the resulting map has rank $r$, then there are exactly $q^r$ words, its kernel cosets are exactly the collision classes, and any transversal yields a complete nonredundant family.

## 10. Applications

### 10.1 Corrected code parameters

The logarithm base $q$ of the code size is its effective $q$-ary dimension. Theorem 7.1 replaces the raw coefficient count by $\operatorname{rank}\tau$. This correction affects rate calculations and comparisons among constructions. Length and distance depend on evaluation geometry, but dimension cannot be inferred correctly until trace redundancy is removed.

### 10.2 Search and enumeration

Enumerating raw coefficients wastes a factor of $|\ker\tau|$. Enumerating a transversal visits every word exactly once. This improves exhaustive distance searches, correlation calculations, and codebook generation. It also prevents frequency bias: sampling raw parameters uniformly induces a uniform distribution on words only because all fibers here have equal size; a transversal makes that uniformity explicit and avoids repeated outputs.

### 10.3 Storage and communication

A raw $n$-coordinate parameter over $F_q$ stores $n\log_2 q$ bits of description, while only $r\log_2 q$ bits are observable. Quotient coordinates remove the $(n-r)\log_2 q$ bits spent specifying an invisible kernel component. In systems that repeatedly transmit or archive code descriptors, this is a direct compression gain.

### 10.4 Optimization and decoding

An objective depending only on the encoded word is constant along kernel cosets. Optimization in raw coordinates therefore contains flat directions and duplicate optima. Passing to a complement of the kernel removes these directions. Likewise, a decoder that returns raw parameters without a normalization rule is intrinsically ambiguous; returning a canonical transversal representative resolves that ambiguity without changing the recovered word.

## 11. Scope, limitations, and discussion

The theory rests on a factorization $C=E\circ\tau$ with additive $\tau$ and injective $E$. It intentionally separates two questions. The first is structural: given the factorization, what causes redundancy and how should it be removed? The answer is the kernel quotient. The second is construction-specific: for a chosen polynomial support, evaluation set, trace, and character, what is the actual rank, and is the post-trace evaluation map injective? Those questions require finite-field and cyclotomic analysis tailored to the family.

If $E$ fails to be injective, quotienting only by $\ker\tau$ is insufficient. One must instead analyze the equivalence relation $a\approx b$ defined by $E(\tau(a))=E(\tau(b))$. When $E$ is also a homomorphism, this may again be a kernel quotient, now by $\ker(E\circ\tau)$. For a general nonlinear $E$, fibers need not be cosets. Thus injectivity is exactly what permits the clean attribution of every collision to the trace-like map.

The linear rank formula also assumes finite-dimensional spaces over a finite field. The collision and quotient theorems themselves require only additive abelian groups and remain valid for infinite parameters, though cardinal arithmetic must then replace the finite formulas.

## 12. Future work

Several concrete developments follow naturally. First, for the finite-field trace, one can compute the rank contributed by each cyclotomic coset of exponents. Second, Frobenius-orbit representatives can be turned into explicit polynomial transversals and checked for existence and uniqueness in every kernel coset. Third, the injectivity of the evaluation stage should be established directly for additive characters valued in complex roots of unity on complete evaluation sets. Fourth, orbit sizes can yield closed cardinality formulas for prescribed degree sets. Finally, corrected length, dimension, and distance parameters can be derived for specific character–polynomial families.

### 12.1 Experimental agenda

A useful experimental program should compare three quantities for each proposed family: the raw coefficient count, the rank-predicted image count, and the number of words obtained by exhaustive enumeration in small fields. Agreement between the latter two diagnoses the predicted kernel, while disagreement exposes either a missed relation in the visible map or a failure of post-trace injectivity. Orbit-adapted bases should also be compared with generic row-reduced complements. Both produce valid transversals, but the former may preserve sparse polynomial structure and reduce evaluation cost. Such experiments do not replace the structural theorems; they help identify the correct concrete map to which those theorems apply.

## 13. Conclusion

Character–polynomial parametrizations over extension fields can be redundant because trace-zero coefficient changes are invisible to additive characters. In the abstract factorization $C=E\circ\tau$ with injective $E$, this phenomenon is exact: two parameters produce the same word if and only if their difference lies in $\ker\tau$. The quotient $A/\ker\tau$ is therefore the canonical nonredundant parameter space, and every kernel transversal is a concrete family in bijection with the code. For a linear map over a $q$-element field, the number of distinct words is $q^{\operatorname{rank}\tau}$, while each word has $q^{\dim A-\operatorname{rank}\tau}$ raw descriptions. Coordinatewise coefficient families obey the same criterion coefficient by coefficient. These results reduce the correction of code cardinality to a precise program: compute the visible map, determine its kernel and rank, and choose one representative from each kernel coset.