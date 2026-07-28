# Hilbert Class Field Reciprocity and the Unramified $\mathrm{GL}_1$ Correspondence

**Author:** Aristotle  
**Date:** July 28, 2026

## Abstract

Let $K$ be a number field with ring of integers $\mathcal O_K$, and let $H/K$ be a finite Galois extension equipped with an Artin reciprocity isomorphism

$$
A:\operatorname{Gal}(H/K)\xrightarrow{\sim}\mathrm{Cl}(\mathcal O_K).
$$

This paper develops the structural consequences of this datum. First, the Galois group is abelian. Second, pullback along $A$ gives a canonical group isomorphism between complex characters of the ideal class group and one-dimensional complex representations of $\operatorname{Gal}(H/K)$; this is the finite-order unramified $\mathrm{GL}_1$ correspondence attached to the Hilbert class field. Third, using the Hilbert class field degree formula $[H:K]=h_K$, degree one is equivalent to class number one, to the principal ideal ring property of $\mathcal O_K$, and to principality of every nonzero ideal. We give complete proof sketches, finite cyclic algorithms illustrating character transport, and examples showing how ideal-theoretic obstruction, unramified Galois symmetry, and one-dimensional representation theory encode the same arithmetic information. We conclude by locating these results between Kronecker–Weber theory, explicit class field theory, and the one-dimensional Langlands correspondence.

## 1. Introduction

The Kronecker–Weber theorem describes finite abelian extensions of $\mathbb Q$ through cyclotomic fields. Hilbert's twelfth problem asks for comparably explicit descriptions of abelian extensions of more general number fields. Even before explicit generators are found, class field theory gives a canonical structural answer at the unramified level: the Hilbert class field converts the ideal class group into a Galois group.

This conversion unifies two phenomena. The first is ideal-theoretic. Although elements in $\mathcal O_K$ need not factor uniquely, nonzero ideals do, and the class group measures the failure of ideals to be principal. The second is field-theoretic. A finite Galois extension has a group of automorphisms, and in an abelian unramified extension Frobenius automorphisms organize the splitting of primes. Artin reciprocity identifies these groups.

Our starting hypothesis is deliberately precise. We assume a number field $K$, a finite Galois extension $H/K$, and a group isomorphism

$$
A:\operatorname{Gal}(H/K)\xrightarrow{\sim}\mathrm{Cl}(\mathcal O_K)
$$

having the role of Hilbert class field reciprocity. The results established here are consequences of that reciprocity datum; they do not by themselves construct $H$, prove its unramifiedness, or supply explicit generators. This distinction is essential when situating the work within Hilbert's twelfth problem.

The main conclusions are as follows.

1. The Galois group $\operatorname{Gal}(H/K)$ is abelian.
2. Ideal-class characters and one-dimensional complex Galois representations are canonically isomorphic as groups.
3. Assuming the degree formula $[H:K]=h_K$, the extension has degree one exactly when $\mathcal O_K$ is a principal ideal ring.
4. Equivalently, the extension has degree one exactly when every nonzero ideal of $\mathcal O_K$ is principal.

The second statement is an unramified finite-order instance of the $\mathrm{GL}_1$ Langlands correspondence. It is elementary once reciprocity is given, but it sharply displays the mechanism common to broader reciprocity laws: arithmetic characters and Galois characters are transported through a canonical group isomorphism.

## 2. Algebraic background

### 2.1. Number fields and rings of integers

A **number field** is a finite extension $K/\mathbb Q$. Its **ring of integers** $\mathcal O_K$ consists of the elements of $K$ satisfying a monic polynomial with coefficients in $\mathbb Z$. This ring is a Dedekind domain. Consequently every nonzero ideal factors uniquely as a finite product of nonzero prime ideals.

Element factorization can nevertheless fail to be unique. The class group packages this failure in a group that remains finite and computable.

### 2.2. Fractional ideals and the class group

A **nonzero fractional ideal** of $\mathcal O_K$ is a nonzero $\mathcal O_K$-submodule $I\subset K$ for which there exists $d\in\mathcal O_K\setminus\{0\}$ such that $dI\subseteq\mathcal O_K$. Nonzero fractional ideals form an abelian group under ideal multiplication. A fractional ideal is **principal** if it has the form

$$
(\alpha)=\alpha\mathcal O_K
$$

for some $\alpha\in K^\times$. Principal fractional ideals form a subgroup.

**Definition 2.1 (Ideal class group).** The ideal class group of $K$ is

$$
\mathrm{Cl}(\mathcal O_K)
=
\{\text{nonzero fractional ideals of }\mathcal O_K\}
/
\{\text{principal fractional ideals}\}.
$$

The class of $I$ is denoted $[I]$. Multiplication is $[I][J]=[IJ]$. Since fractional ideal multiplication is commutative, $\mathrm{Cl}(\mathcal O_K)$ is abelian.

**Definition 2.2 (Class number).** The class number is

$$
h_K=\lvert\mathrm{Cl}(\mathcal O_K)\rvert.
$$

For number fields, this number is finite.

**Lemma 2.3 (Class-number-one criterion).** The following conditions are equivalent:

1. $h_K=1$;
2. $\mathrm{Cl}(\mathcal O_K)$ is trivial;
3. every nonzero fractional ideal of $\mathcal O_K$ is principal;
4. every nonzero integral ideal of $\mathcal O_K$ is principal;
5. $\mathcal O_K$ is a principal ideal ring.

**Proof sketch.** A finite group has cardinality one exactly when it is trivial. By construction, an ideal has trivial class exactly when it is principal, proving the equivalence of the first three conditions. Integral ideals are fractional ideals, so the third condition implies the fourth. Conversely, multiplying a fractional ideal by a suitable nonzero denominator produces an integral ideal; if that integral ideal is principal, then dividing its generator by the denominator shows that the original fractional ideal is principal. The fourth and fifth conditions are the defining principal-ideal property for the nonzero ideals of the domain $\mathcal O_K$; the zero ideal is itself principal.

### 2.3. Galois extensions and Artin reciprocity

For a finite Galois extension $H/K$, let

$$
G=\operatorname{Gal}(H/K)
$$

be the group of field automorphisms of $H$ fixing $K$. A Hilbert class field is characterized as the maximal abelian extension of $K$ unramified at all finite primes. The Artin map associates Frobenius elements to unramified prime ideals and extends multiplicatively.

For the present development, the central datum is the following.

**Definition 2.4 (Hilbert reciprocity datum).** A Hilbert reciprocity datum for $H/K$ is a group isomorphism

$$
A:G\xrightarrow{\sim}\mathrm{Cl}(\mathcal O_K).
$$

When $H$ is the Hilbert class field, class field theory supplies this isomorphism and the degree identity

$$
[H:K]=\lvert G\rvert=h_K.
$$

The proofs below clearly separate consequences of the group isomorphism from consequences that additionally use the degree identity.

### 2.4. Characters

Write $\mathbb C^\times$ for the multiplicative group of nonzero complex numbers.

**Definition 2.5 (Ideal-class character).** An ideal-class character is a group homomorphism

$$
\chi:\mathrm{Cl}(\mathcal O_K)\to\mathbb C^\times.
$$

**Definition 2.6 (One-dimensional Galois representation).** A one-dimensional complex representation of $G$ is a group homomorphism

$$
\rho:G\to\mathbb C^\times.
$$

Since both source groups are finite, the images of these characters are finite subgroups of $\mathbb C^\times$ and hence consist of roots of unity. Thus the correspondence below concerns finite-order characters.

The character sets are themselves abelian groups under pointwise multiplication:

$$
(\chi_1\chi_2)(c)=\chi_1(c)\chi_2(c),
\qquad
(\rho_1\rho_2)(\sigma)=\rho_1(\sigma)\rho_2(\sigma).
$$

## 3. Structural results

### 3.1. Reciprocity forces commutativity

**Theorem 3.1 (Abelian Galois Group Theorem).** Let $K$ be a number field, let $H/K$ be a finite Galois extension, and suppose that

$$
A:\operatorname{Gal}(H/K)\xrightarrow{\sim}\mathrm{Cl}(\mathcal O_K)
$$

is a group isomorphism. Then $\operatorname{Gal}(H/K)$ is abelian.

**Proof.** Let $\sigma,\tau\in G$. Since $A$ is a homomorphism and the class group is abelian,

$$
A(\sigma\tau)
=A(\sigma)A(\tau)
=A(\tau)A(\sigma)
=A(\tau\sigma).
$$

The map $A$ is injective, so $\sigma\tau=\tau\sigma$. This holds for every pair $\sigma,\tau$, proving that $G$ is abelian. $\square$

This theorem is formally a transport-of-structure statement. Its arithmetic force comes from the fact that $A$ is the Artin map, not an arbitrary labeling.

### 3.2. Character transport

Define pullback along reciprocity by

$$
A^*(\chi)=\chi\circ A.
$$

Thus $A^*(\chi)$ is a Galois character and

$$
A^*(\chi)(\sigma)=\chi(A(\sigma)).
$$

Define transport in the opposite direction by

$$
(A^{-1})^*(\rho)=\rho\circ A^{-1},
$$

so that

$$
(A^{-1})^*(\rho)(c)=\rho(A^{-1}(c)).
$$

**Lemma 3.2 (Round trip from the Galois side).** For every one-dimensional Galois representation $\rho:G\to\mathbb C^\times$,

$$
A^*((A^{-1})^*(\rho))=\rho.
$$

**Proof.** For every $\sigma\in G$,

$$
A^*((A^{-1})^*(\rho))(\sigma)
=\rho(A^{-1}(A(\sigma)))
=\rho(\sigma).
$$

Equality at every group element gives equality of homomorphisms. $\square$

**Lemma 3.3 (Round trip from the ideal-class side).** For every ideal-class character $\chi:\mathrm{Cl}(\mathcal O_K)\to\mathbb C^\times$,

$$
(A^{-1})^*(A^*(\chi))=\chi.
$$

**Proof.** For every $c\in\mathrm{Cl}(\mathcal O_K)$,

$$
(A^{-1})^*(A^*(\chi))(c)
=\chi(A(A^{-1}(c)))
=\chi(c).
$$

Hence the two characters are equal. $\square$

**Lemma 3.4 (Compatibility with character multiplication).** For ideal-class characters $\chi$ and $\psi$,

$$
A^*(\chi\psi)=A^*(\chi)A^*(\psi).
$$

**Proof.** For $\sigma\in G$,

$$
A^*(\chi\psi)(\sigma)
=(\chi\psi)(A(\sigma))
=\chi(A(\sigma))\psi(A(\sigma))
=A^*(\chi)(\sigma)A^*(\psi)(\sigma).
$$

Thus equality holds pointwise. $\square$

The preceding lemmas assemble into the main representation-theoretic result.

**Theorem 3.5 (Unramified $\mathrm{GL}_1$ Correspondence).** Under the hypotheses of Theorem 3.1, pullback along Artin reciprocity is an isomorphism of abelian groups

$$
A^*:
\operatorname{Hom}(\mathrm{Cl}(\mathcal O_K),\mathbb C^\times)
\xrightarrow{\sim}
\operatorname{Hom}(G,\mathbb C^\times).
$$

Its inverse is pullback along $A^{-1}$.

**Proof.** Lemmas 3.2 and 3.3 show that the two pullback maps are mutually inverse bijections. Lemma 3.4 shows that $A^*$ preserves multiplication; the corresponding statement for its inverse follows similarly. Therefore $A^*$ is a group isomorphism. $\square$

The term $\mathrm{GL}_1$ is justified by the canonical identification $\mathrm{GL}_1(\mathbb C)=\mathbb C^\times$. The ideal-class characters are unramified finite-order automorphic parameters in this algebraic model, while the right-hand side consists of one-dimensional Galois representations.

### 3.3. Degree one and principality

We now use the Hilbert class field degree identity.

**Theorem 3.6 (Degree-One Principal-Ideal Criterion).** Suppose $H/K$ carries Hilbert class field reciprocity and satisfies

$$
[H:K]=h_K.
$$

Then

$$
[H:K]=1
\quad\Longleftrightarrow\quad
\mathcal O_K\text{ is a principal ideal ring}.
$$

**Proof.** By the degree formula,

$$
[H:K]=1\quad\Longleftrightarrow\quad h_K=1.
$$

By Lemma 2.3, $h_K=1$ is equivalent to the principal ideal ring property of $\mathcal O_K$. Chaining the equivalences proves the theorem. $\square$

**Corollary 3.7 (Principality implies degree one).** If every nonzero ideal of $\mathcal O_K$ is principal, then $[H:K]=1$.

**Proof.** The hypothesis makes $\mathcal O_K$ a principal ideal ring. The forward implication in Theorem 3.6 then yields $[H:K]=1$. $\square$

**Corollary 3.8 (Degree one implies principality).** If $[H:K]=1$, then every nonzero ideal of $\mathcal O_K$ is principal.

**Proof.** The reverse implication in Theorem 3.6 makes $\mathcal O_K$ a principal ideal ring, and therefore every ideal is principal. $\square$

Together, these results identify three equivalent forms of triviality:

$$
H=K,
\qquad
\mathrm{Cl}(\mathcal O_K)=\{1\},
\qquad
\text{every nonzero ideal of }\mathcal O_K\text{ is principal}.
$$

The equality $H=K$ is understood up to the canonical identification associated with a degree-one field extension.

## 4. Finite cyclic model and algorithms

The abstract correspondence becomes completely explicit when the class group is cyclic. Suppose

$$
\mathrm{Cl}(\mathcal O_K)\cong C_n=\mathbb Z/n\mathbb Z.
$$

Let $g$ be the class corresponding to $1$. Every complex character is indexed by $k\in\{0,\ldots,n-1\}$ and has the form

$$
\chi_k(g^j)=\exp\!\left(\frac{2\pi i k j}{n}\right).
$$

These $n$ characters exhaust the character group. Pointwise multiplication satisfies

$$
\chi_k\chi_\ell=\chi_{k+\ell\bmod n}.
$$

If the Artin isomorphism labels a Galois automorphism $\sigma_j$ by $g^j$, then

$$
\rho_k(\sigma_j)
=\chi_k(A(\sigma_j))
=\exp\!\left(\frac{2\pi i k j}{n}\right).
$$

Thus the same discrete Fourier matrix is simultaneously the ideal-class character table and the one-dimensional Galois character table.

### Algorithm 4.1: cyclic character-table construction

**Input:** a positive integer $n$.  
**Output:** the matrix $T$ with entries $T_{k,j}=\exp(2\pi i k j/n)$.

1. For each $k$ from $0$ to $n-1$, create one row.
2. For each class exponent $j$ from $0$ to $n-1$, compute $\exp(2\pi i k j/n)$.
3. Store this value in row $k$, column $j$.
4. Return the $n\times n$ matrix.

The algorithm uses $n^2$ complex exponential evaluations, so its arithmetic time complexity is $O(n^2)$ and its output storage is $O(n^2)$. The orthogonality relation

$$
\sum_{j=0}^{n-1}\chi_k(g^j)\overline{\chi_\ell(g^j)}
=
\begin{cases}
n,&k=\ell,\\
0,&k\ne\ell
\end{cases}
$$

provides a numerical consistency check.

### Algorithm 4.2: transport through a finite Artin labeling

Represent the Artin isomorphism on finite enumerations by a permutation $p$, where the Galois element in position $j$ maps to the ideal class in position $p(j)$. Given a character vector $v$, transport is composition:

$$
w_j=v_{p(j)}.
$$

The inverse uses $p^{-1}$. Constructing the inverse permutation costs $O(n)$ time and storage; each transport costs $O(n)$. The round-trip identities are checked by verifying that inverse permutation followed by permutation restores every entry.

### Algorithm 4.3: degree/principality diagnostic

Given a class number $h_K$ known to equal $[H:K]$, report:

- degree $[H:K]=h_K$;
- principal ideal ring status exactly when $h_K=1$;
- number of one-dimensional characters equal to $h_K$ when the class group is finite abelian.

The decision itself is constant time after $h_K$ is supplied. Computing $h_K$ from a defining polynomial is a separate and substantially deeper computational problem.

## 5. Examples

### 5.1. The Gaussian field

Let $K=\mathbb Q(i)$, whose ring of integers is $\mathbb Z[i]$. This ring is Euclidean and hence a principal ideal domain. Therefore $h_K=1$. The degree-one criterion gives

$$
[H:K]=1.
$$

There is one ideal-class character, the trivial character, and one corresponding one-dimensional character of the trivial Galois group.

### 5.2. The field $\mathbb Q(\sqrt{-5})$

The ring of integers of $K=\mathbb Q(\sqrt{-5})$ is $\mathbb Z[\sqrt{-5}]$, and its class number is $2$. Therefore its Hilbert class field has degree $2$ over $K$, and the class group is cyclic of order $2$. Its character table is

$$
\begin{pmatrix}
1&1\\
1&-1
\end{pmatrix}.
$$

Artin reciprocity identifies the nontrivial ideal class with the nonidentity Galois automorphism. The nontrivial ideal-class character sends that class to $-1$; the corresponding Galois representation sends the nonidentity automorphism to $-1$.

### 5.3. A cyclic class group of order three

For a cyclic class group $C_3$, put $\omega=\exp(2\pi i/3)$. The character table is

$$
\begin{pmatrix}
1&1&1\\
1&\omega&\omega^2\\
1&\omega^2&\omega
\end{pmatrix}.
$$

The Hilbert class field degree is $3$. There are three one-dimensional Galois representations. Once Artin reciprocity labels the three Galois elements by the three ideal classes, the displayed table serves both sides without alteration.

## 6. Relation to Kronecker–Weber and Langlands

Kronecker–Weber gives explicit generators for abelian extensions of $\mathbb Q$ through roots of unity. For a general number field, the Hilbert class field is the canonical maximal unramified abelian extension of finite degree. The reciprocity isomorphism determines its Galois group abstractly from ideals. This is a generalization in structural scope, but not yet a universal explicit-generation theorem: Hilbert's twelfth problem asks for analytic generators analogous to roots of unity.

The character isomorphism is the unramified finite-order $\mathrm{GL}_1$ correspondence. More complete formulations use the idèle class group $C_K$ and identify its continuous characters with one-dimensional characters of the abelianized absolute Galois group. Ideal-class characters arise as those idèle-class characters trivial on the archimedean factors and local unit subgroups relevant to the unramified quotient.

In higher rank, the Langlands program compares $n$-dimensional Galois representations with automorphic representations of $\mathrm{GL}_n$. The present setting avoids the analytic and nonabelian difficulties of higher rank. Nevertheless, it exhibits the defining pattern: a reciprocity mechanism transports arithmetic spectral data to Galois spectral data.

## 7. Applications and limitations

The results have several immediate uses.

First, class-group computations determine the degree of the Hilbert class field. A class number larger than one certifies that a nontrivial unramified abelian extension must occur; class number one certifies its collapse.

Second, a presentation of the class group determines all one-dimensional representations of the Hilbert Galois group. If

$$
\mathrm{Cl}(\mathcal O_K)\cong C_{n_1}\times\cdots\times C_{n_r},
$$

then a character is determined independently on each cyclic generator by choosing an $n_j$-th root of unity. Consequently the character group has $h_K=n_1\cdots n_r$ elements and is noncanonically isomorphic to the class group itself.

Third, the degree-one criterion provides a conceptual equivalence between ideal arithmetic and extension theory. Proving every ideal principal is enough to show that the Hilbert class field is trivial; proving the Hilbert extension has degree one is enough to recover principality.

The limitations are equally important. The reciprocity isomorphism is assumed as input to the structural arguments. The existence of the Hilbert class field, its maximality and unramifiedness, the principal ideal theorem in the extension, and explicit defining equations require additional work. Moreover, finite ideal-class characters cover only the unramified finite-order sector of global $\mathrm{GL}_1$ reciprocity.

## 8. Future directions

Five developments would extend this structural core.

1. **Existence of Hilbert class fields.** For every number field $K$, construct a finite Galois extension $H/K$, unramified at every finite prime, together with an Artin reciprocity isomorphism $\operatorname{Gal}(H/K)\cong\mathrm{Cl}(\mathcal O_K)$.

2. **Principal ideal theorem.** Prove that extension to $H$ sends every nonzero fractional ideal of $\mathcal O_K$ to a principal fractional ideal of $\mathcal O_H$, or equivalently that the induced map $\mathrm{Cl}(\mathcal O_K)\to\mathrm{Cl}(\mathcal O_H)$ is zero.

3. **Idèlic realization.** Construct the quotient from the idèle class group onto $\mathrm{Cl}(\mathcal O_K)$, identify its kernel, and characterize ideal-class characters as precisely the idèle-class characters trivial on that kernel.

4. **Cyclotomic compatibility over $\mathbb Q$.** Show that general Artin reciprocity specializes in cyclotomic extensions to the rule taking a prime $p$ coprime to the conductor to the automorphism $\zeta\mapsto\zeta^p$.

5. **Explicit imaginary-quadratic generators.** For imaginary quadratic fields of small class number, construct singular moduli generating the Hilbert class field and prove the expected degree and unramifiedness properties.

### 8.1. From cyclic groups to finite abelian groups

The cyclic algorithm extends componentwise. If the class group has invariant-factor decomposition

$$
C_{n_1}\times\cdots\times C_{n_r},
$$

then index a group element by $j=(j_1,\ldots,j_r)$ and a character by $k=(k_1,\ldots,k_r)$. The complete family is

$$
\chi_k(j)=\exp\!\left(2\pi i\sum_{a=1}^r\frac{k_a j_a}{n_a}\right).
$$

There are $\prod_a n_a=h_K$ group elements and equally many characters. A direct character-table construction takes $O(h_K^2 r)$ elementary arithmetic operations if each entry is computed from all $r$ coordinates. Tensoring the cyclic Fourier matrices gives the same table and exposes product structure that can be exploited by multidimensional fast Fourier methods. Artin transport remains a column relabeling, so it adds only linear work once the reciprocity table is known.

### 8.2. Splitting information encoded by characters

For a finite prime $\mathfrak p$ unramified in $H$, its Frobenius element $\operatorname{Frob}_{\mathfrak p}$ is sent by reciprocity to the ideal class of $\mathfrak p$ (up to the chosen arithmetic or geometric Frobenius convention). Consequently a transported character satisfies

$$
\rho_\chi(\operatorname{Frob}_{\mathfrak p})=\chi([\mathfrak p]).
$$

Thus values of ideal-class characters on prime classes are exactly values of the corresponding Galois representations on Frobenius symmetries. In particular, a prime splitting completely has trivial Frobenius and every transported character takes value $1$ there. Conversely, because characters of a finite abelian group separate points, if every character takes value $1$ on a Frobenius element, that element is the identity. This connects the character correspondence directly to observable splitting behavior.

## 9. Conclusion

An Artin reciprocity isomorphism

$$
\operatorname{Gal}(H/K)\cong\mathrm{Cl}(\mathcal O_K)
$$

has three immediate but far-reaching consequences. It transfers commutativity from ideals to automorphisms, transports every ideal-class character to a unique one-dimensional Galois representation, and—together with the degree formula—equates the triviality of the Hilbert class field with principality of all ideals.

These consequences form a coherent unramified $\mathrm{GL}_1$ picture. The class group measures the obstruction to principality, the Hilbert class field realizes that obstruction as Galois symmetry, and character duality records the same symmetry as complex phases. This is the first canonical layer beyond the cyclotomic world and a precise point of entry into explicit class field theory and the Langlands program.