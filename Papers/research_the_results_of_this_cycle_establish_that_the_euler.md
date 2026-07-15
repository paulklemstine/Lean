# Dimensional Euler Signs as Fourier Characters of Parity

**Aristotle**  
**July 15, 2026**

## Abstract

We study finitely supported integer-valued cellular data graded by all integer dimensions, including negative degrees. Such data form the integral group algebra of the additive dimension group $\mathbb Z$, equivalently the ring of Laurent polynomials with integer coefficients. We classify all characters from integer dimensions to the unit group $\mathbb Z^\times=\{1,-1\}$: every such character is either trivial or the parity character $d\mapsto(-1)^d$, and parity is uniquely determined by taking the value $-1$ in dimension $1$. Evaluation against these characters produces exactly two invariants, total cell mass and dimensional Euler characteristic. Splitting the data into even- and odd-dimensional sectors gives $M=E+O$ and $\chi=E-O$, hence the denominator-free Fourier inversion formulas $M+\chi=2E$ and $M-\chi=2O$. We also prove that reflection of dimensions, $d\mapsto-d$, preserves the Euler characteristic. These results identify the alternating Euler sum as the nontrivial Fourier coefficient of the parity grading and provide an elementary bridge among virtual cellular topology, integer character theory, Laurent-polynomial evaluation, and the two-point discrete Fourier transform. Algorithms and numerical examples make the reconstruction explicit and expose applications to convolution, parity checks, degree shifts, and higher cyclic gradings.

## 1. Introduction

Euler characteristic is traditionally written as an alternating sum. For a finite cellular object with $c_d$ cells in nonnegative dimension $d$, one forms

$$
\chi=\sum_{d\ge 0}(-1)^d c_d.
$$

The same algebraic expression remains meaningful when the degree set is enlarged from the nonnegative integers to all integers and when multiplicities are allowed to be signed. This enlargement is natural whenever degree shifts, formal differences, Laurent polynomials, or stable constructions are present. The central question is then not whether the alternating formula can be written, but why its sign law is canonical and what information it carries.

The answer comes from character theory. Integer dimensions form the additive group $\mathbb Z$. A coherent assignment of integer-unit signs to dimensions must be a character from $\mathbb Z$ to $\mathbb Z^\times=\{1,-1\}$. There are exactly two such characters: the constant character and parity. Thus there are exactly two character evaluations of integer-graded cellular data: the unweighted total and the Euler alternating sum.

The pair is not redundant. It is the two-point Fourier transform of the even- and odd-dimensional masses. If $E$ denotes total coefficient in even degrees and $O$ denotes total coefficient in odd degrees, then

$$
\begin{pmatrix}M\\ \chi\end{pmatrix}
=
\begin{pmatrix}1&1\\1&-1\end{pmatrix}
\begin{pmatrix}E\\O\end{pmatrix}.
$$

Because the character-table matrix squares to twice the identity, it follows integrally that

$$
M+\chi=2E,
\qquad
M-\chi=2O.
$$

These identities recover the parity sectors without introducing fractions into the theorem statement. They also imply an image constraint: total mass and Euler characteristic always have matching parity.

A second theme is reflection. Negating all dimensions exchanges positive and negative degrees but does not exchange even and odd degrees. Since $(-1)^{-d}=(-1)^d$, the Euler characteristic is invariant under reflection. This captures a precise self-duality of the character evaluation and shows that negative dimensions enter on equal terms.

The paper is organized as follows. Section 2 defines virtual cellular spaces, characters, evaluations, and parity sectors. Section 3 classifies all integral dimension characters. Section 4 identifies the two resulting evaluations. Section 5 proves Fourier reconstruction. Section 6 establishes reflection invariance. Section 7 presents Laurent-polynomial and convolution interpretations. Sections 8 and 9 give algorithms and examples. Sections 10–12 discuss applications, limitations, and future directions.

## 2. Integer-graded virtual cellular data

### 2.1. Virtual cellular spaces

**Definition 2.1 (Virtual cellular space).** A virtual cellular space is a finitely supported function

$$
x:\mathbb Z\to\mathbb Z.
$$

Its coefficient $x(d)$ is interpreted as the signed multiplicity in dimension $d$. Its support is

$$
\operatorname{supp}(x)=\{d\in\mathbb Z:x(d)\ne0\},
$$

which is required to be finite.

The adjective “virtual” has two roles. First, coefficients may be negative, permitting formal differences. Second, dimensions may be negative, permitting formal degree shifts and desuspensions. All sums in this paper are finite because support is finite.

Virtual cellular spaces add coefficientwise. They may also be multiplied by degree convolution:

$$
(x*y)(k)=\sum_{a+b=k}x(a)y(b).
$$

Only finitely many pairs contribute. Algebraically, this is the integral group algebra $\mathbb Z[\mathbb Z]$.

### 2.2. Laurent-polynomial representation

Associate to $x$ the Laurent polynomial

$$
X(t)=\sum_{d\in\mathbb Z}x(d)t^d\in\mathbb Z[t,t^{-1}].
$$

Addition is coefficientwise, and convolution becomes polynomial multiplication. Negative dimensions correspond exactly to negative powers of $t$. This representation will make character evaluation into ordinary substitution.

### 2.3. Four basic measurements

**Definition 2.2 (Total mass).** The total mass of $x$ is

$$
M(x)=\sum_{d\in\mathbb Z}x(d).
$$

**Definition 2.3 (Dimensional Euler characteristic).** The dimensional Euler characteristic of $x$ is

$$
\chi(x)=\sum_{d\in\mathbb Z}(-1)^d x(d).
$$

For every integer $d$, including negative $d$, the value $(-1)^d$ equals $1$ when $d$ is even and $-1$ when $d$ is odd.

**Definition 2.4 (Parity-sector masses).** The even and odd masses are

$$
E(x)=\sum_{\substack{d\in\mathbb Z\\ d\text{ even}}}x(d),
\qquad
O(x)=\sum_{\substack{d\in\mathbb Z\\ d\text{ odd}}}x(d).
$$

These are signed masses, not cardinalities. They may be negative when virtual coefficients are negative.

### 2.4. Dimension characters

**Definition 2.5 (Integral dimension character).** An integral dimension character is a function

$$
\psi:\mathbb Z\to\mathbb Z^\times=\{1,-1\}
$$

such that

$$
\psi(a+b)=\psi(a)\psi(b)
$$

for all integers $a,b$. In particular, $\psi(0)=1$ and $\psi(-d)=\psi(d)^{-1}$.

Two characters are immediately available. The **trivial character** is $\mathbf 1(d)=1$. The **Euler character** is

$$
\varepsilon(d)=(-1)^d.
$$

**Definition 2.6 (Character evaluation).** Given a dimension character $\psi$, define

$$
\mathcal E_\psi(x)=\sum_{d\in\mathbb Z}\psi(d)x(d),
$$

where the sign is viewed as an integer.

For a pure cell of coefficient $c$ in degree $d$, denoted by data supported only at $d$ with value $c$, character evaluation is

$$
\mathcal E_\psi(x)=\psi(d)c.
$$

This elementary identity shows that character evaluation is determined locally on pure degrees.

## 3. Classification of dimensional sign characters

We now establish the rigidity underlying the construction.

**Theorem 3.1 (Character Classification Theorem).** Every integral dimension character $\psi:\mathbb Z\to\{1,-1\}$ is either the trivial character $\mathbf 1$ or the Euler character $\varepsilon(d)=(-1)^d$.

**Proof sketch.** The additive group $\mathbb Z$ is generated by $1$, so a homomorphism out of it is determined by $u=\psi(1)$. The target contains only two elements. If $u=1$, then for $n\ge0$, $\psi(n)=u^n=1$, while $\psi(-n)=\psi(n)^{-1}=1$; hence $\psi=\mathbf 1$. If $u=-1$, the same argument gives $\psi(n)=(-1)^n$ for nonnegative $n$ and $\psi(-n)=((-1)^n)^{-1}=(-1)^n=(-1)^{-n}$, so $\psi=\varepsilon$. These cases exhaust the target. $\square$

**Corollary 3.2 (Uniqueness of the nontrivial character).** If an integral dimension character satisfies $\psi(1)=-1$, then $\psi(d)=(-1)^d$ for every integer $d$.

**Proof sketch.** The trivial character takes value $1$ at the generator. The classification theorem leaves only the Euler character. $\square$

**Corollary 3.3 (Reflection symmetry of every integral sign character).** For every integral dimension character and every $d\in\mathbb Z$,

$$
\psi(-d)=\psi(d).
$$

**Proof sketch.** A sign is its own inverse, so $\psi(-d)=\psi(d)^{-1}=\psi(d)$. Equivalently, check the two classified characters separately. $\square$

The result depends crucially on the chosen target. If characters took values in the nonzero complex numbers, then the image of $1$ could be any nonzero complex number, and many more homomorphisms would exist. Restricting to the units of $\mathbb Z$ is precisely what makes the character set equal to parity’s two Fourier modes.

## 4. Classification of character evaluations

**Proposition 4.1 (Trivial evaluation equals total mass).** For every virtual cellular space $x$,

$$
\mathcal E_{\mathbf 1}(x)=M(x).
$$

**Proof sketch.** Every coefficient is multiplied by $\mathbf 1(d)=1$, so the defining sums are identical. $\square$

**Proposition 4.2 (Euler evaluation equals the alternating sum).** For every virtual cellular space $x$,

$$
\mathcal E_\varepsilon(x)=\chi(x).
$$

**Proof sketch.** Substitute $\varepsilon(d)=(-1)^d$ into the definition of character evaluation. $\square$

**Theorem 4.3 (Evaluation Classification Theorem).** For every integral dimension character $\psi$ and every virtual cellular space $x$,

$$
\mathcal E_\psi(x)=M(x)
\quad\text{or}\quad
\mathcal E_\psi(x)=\chi(x).
$$

**Proof sketch.** By Theorem 3.1, $\psi$ is either $\mathbf 1$ or $\varepsilon$. Apply Propositions 4.1 and 4.2. $\square$

This theorem says that no additional unit-valued character measurement exists. The conclusion concerns a structural family of evaluations, not all possible integer-valued functions of the coefficients. Many other statistics can be defined, but none arise from a homomorphic sign assignment to dimension.

Character evaluations are additive:

$$
\mathcal E_\psi(x+y)=\mathcal E_\psi(x)+\mathcal E_\psi(y),
$$

and multiplicative under convolution:

$$
\mathcal E_\psi(x*y)=\mathcal E_\psi(x)\mathcal E_\psi(y).
$$

For multiplicativity, expand the convolution sum and use $\psi(a+b)=\psi(a)\psi(b)$. Thus $M$ and $\chi$ are ring evaluations, not merely linear statistics.

## 5. Parity decomposition and Fourier inversion

**Lemma 5.1 (Total-sector decomposition).** For every virtual cellular space $x$,

$$
M(x)=E(x)+O(x).
$$

**Proof sketch.** The support is the disjoint union of its even and odd elements. Splitting the finite total sum over this partition yields the identity. $\square$

**Lemma 5.2 (Euler-sector decomposition).** For every virtual cellular space $x$,

$$
\chi(x)=E(x)-O(x).
$$

**Proof sketch.** The Euler sign is $1$ in every even degree and $-1$ in every odd degree. Splitting the finite alternating sum into the two parity classes therefore gives the difference. $\square$

The two equations form a character transform:

$$
\begin{pmatrix}M(x)\\ \chi(x)\end{pmatrix}
=H
\begin{pmatrix}E(x)\\O(x)\end{pmatrix},
\qquad
H=
\begin{pmatrix}1&1\\1&-1\end{pmatrix}.
$$

The rows of $H$ are the values of the trivial and parity characters on the two parity classes. They are orthogonal, and

$$
H^2=2I.
$$

**Theorem 5.3 (Parity Fourier Reconstruction Theorem).** For every virtual cellular space $x$,

$$
M(x)+\chi(x)=2E(x),
$$

and

$$
M(x)-\chi(x)=2O(x).
$$

**Proof sketch.** Substitute $M=E+O$ and $\chi=E-O$. Addition cancels the odd sector and gives $2E$; subtraction cancels the even sector and gives $2O$. Equivalently, apply $H$ a second time and use $H^2=2I$. $\square$

This is the integral, denominator-free Fourier inversion formula. Over $\mathbb Q$ it becomes

$$
E(x)=\frac{M(x)+\chi(x)}2,
\qquad
O(x)=\frac{M(x)-\chi(x)}2.
$$

**Corollary 5.4 (Parity constraint).** For every virtual cellular space $x$,

$$
M(x)\equiv\chi(x)\pmod 2.
$$

**Proof sketch.** Their difference equals $2O(x)$ and hence is even. $\square$

**Corollary 5.5 (Integral image characterization).** A pair $(m,c)\in\mathbb Z^2$ occurs as $(M(x),\chi(x))$ for some virtual cellular space if and only if $m\equiv c\pmod2$.

**Proof sketch.** Necessity is Corollary 5.4. Conversely, if the parity matches, then $e=(m+c)/2$ and $o=(m-c)/2$ are integers. Place coefficient $e$ in degree $0$ and coefficient $o$ in degree $1$. The resulting virtual cellular space has total mass $e+o=m$ and Euler characteristic $e-o=c$. $\square$

The use of virtual integer coefficients makes sufficiency immediate. If coefficients were required to be nonnegative, one would additionally require $e\ge0$ and $o\ge0$, equivalently $m\ge |c|$.

## 6. Reflection and negative-dimensional self-duality

**Definition 6.1 (Dimension reflection).** The reflection $Rx$ of a virtual cellular space $x$ is defined by

$$
(Rx)(d)=x(-d).
$$

Finite support is preserved, and reflection is an involution: $R(Rx)=x$.

**Theorem 6.2 (Euler Reflection Invariance).** For every virtual cellular space $x$,

$$
\chi(Rx)=\chi(x).
$$

**Proof sketch.** Compute

$$
\chi(Rx)=\sum_d(-1)^d x(-d).
$$

Make the bijective change of variable $k=-d$. Then

$$
\chi(Rx)=\sum_k(-1)^{-k}x(k).
$$

Since $-k$ has the same parity as $k$, $(-1)^{-k}=(-1)^k$. The sum is therefore $\chi(x)$. $\square$

**Proposition 6.3 (Full parity data are reflection invariant).** Reflection preserves $M(x)$, $E(x)$, and $O(x)$ as well as $\chi(x)$.

**Proof sketch.** Negation is a bijection on $\mathbb Z$ and preserves parity. Reindex each finite sum. $\square$

Reflection is particularly relevant to negative degrees. It can exchange data supported in positive dimensions with data supported in negative dimensions without changing either Fourier coordinate. At the level of characters, reflection replaces $\psi(d)$ by $\psi(-d)=\psi(d)^{-1}$. For signs, inversion is trivial, so both characters are fixed. In higher cyclic or complex character theories, the analogous operation becomes character inversion or conjugation rather than literal invariance.

## 7. Laurent polynomials, products, and convolution

The Laurent polynomial $X(t)=\sum_d x(d)t^d$ packages all coefficients. The two character evaluations are

$$
M(x)=X(1),
\qquad
\chi(x)=X(-1).
$$

Negative exponents cause no difficulty because both $1$ and $-1$ are units. Reflection sends $X(t)$ to $X(t^{-1})$. Evaluation at $t=-1$ is unchanged because $(-1)^{-1}=-1$.

Suppose $z=x*y$ is the convolution product. Then $Z(t)=X(t)Y(t)$, and hence

$$
M(z)=M(x)M(y),
\qquad
\chi(z)=\chi(x)\chi(y).
$$

The parity sectors themselves combine by the two-class convolution law

$$
E(z)=E(x)E(y)+O(x)O(y),
$$

$$
O(z)=E(x)O(y)+O(x)E(y).
$$

Indeed, sums of two even or two odd degrees are even, while sums of opposite parity are odd. Applying the character transform diagonalizes this convolution: the coordinates $(M,\chi)$ multiply componentwise. This is the basic Fourier principle that convolution in the original domain becomes multiplication in the character domain.

A degree shift by $n$ sends $X(t)$ to $t^nX(t)$. Therefore

$$
M(t^nX)=M(X),
\qquad
\chi(t^nX)=(-1)^n\chi(X).
$$

Even shifts preserve the Euler characteristic, and odd shifts reverse its sign. Reflection, by contrast, preserves it because negation leaves parity unchanged.

## 8. Algorithms

### 8.1. Direct invariant computation

Given a sparse dictionary of degree–coefficient pairs, scan each pair once. Accumulate its coefficient into total mass and into the appropriate parity sector. Add it to the Euler accumulator for even degree and subtract it for odd degree. If $s$ degrees are stored, this takes $O(s)$ time and $O(1)$ auxiliary space beyond the input.

**Algorithm 8.1 (Sparse parity-character evaluation).**

1. Initialize $E,O,M,\chi$ to zero.
2. For each stored pair $(d,c)$:
   1. Set $M\leftarrow M+c$.
   2. If $d$ is even, set $E\leftarrow E+c$ and $\chi\leftarrow\chi+c$.
   3. If $d$ is odd, set $O\leftarrow O+c$ and $\chi\leftarrow\chi-c$.
3. Return $(E,O,M,\chi)$.
4. Check $M+\chi=2E$ and $M-\chi=2O$.

### 8.2. Fourier reconstruction

If only $M$ and $\chi$ are given, first verify matching parity. Then compute

$$
E=(M+\chi)/2,
\qquad
O=(M-\chi)/2.
$$

This is $O(1)$ arithmetic time. Failure of matching parity proves that no integer virtual cellular space realizes the proposed pair.

### 8.3. Reflection audit

To reflect sparse data, replace each key $d$ by $-d$ and combine coefficients if necessary. This takes expected $O(s)$ time with a hash map and $O(s)$ output storage. Compute $\chi$ before and after as an audit; invariance requires equality.

## 9. Numerical examples

### 9.1. Mixed positive and negative dimensions

Consider

$$
x(-2)=3,\quad x(-1)=5,\quad x(0)=7,\quad x(3)=11,
$$

with all other coefficients zero. Even degrees contribute

$$
E(x)=3+7=10,
$$

and odd degrees contribute

$$
O(x)=5+11=16.
$$

Thus

$$
M(x)=26,
\qquad
\chi(x)=-6.
$$

Fourier reconstruction gives

$$
M+\chi=20=2E,
\qquad
M-\chi=32=2O.
$$

Reflection places coefficients $11,7,5,3$ in degrees $-3,0,1,2$, respectively. The even and odd masses remain $10$ and $16$, so the Euler characteristic remains $-6$.

### 9.2. Virtual cancellation

Let $y(-4)=9$, $y(2)=-4$, and $y(5)=6$. Then

$$
E(y)=9-4=5,
\qquad
O(y)=6,
$$

so

$$
M(y)=11,
\qquad
\chi(y)=-1.
$$

Again $M$ and $\chi$ have the same parity, and reconstruction yields $E=5$ and $O=6$. Negative coefficients therefore introduce no change to the theory; they merely make sector masses signed.

### 9.3. Product behavior

Suppose one virtual space has parity vector $(E,O)=(2,3)$ and another has $(5,-1)$. Their convolution product has

$$
E'=2\cdot5+3\cdot(-1)=7,
$$

$$
O'=2\cdot(-1)+3\cdot5=13.
$$

The corresponding Fourier coordinates are $(M,\chi)=(5,-1)$ and $(4,6)$. Componentwise multiplication gives $(20,-6)$. From the product parity vector, $M'=7+13=20$ and $\chi'=7-13=-6$, confirming diagonalization.

## 10. Applications and interpretation

### 10.1. Euler characteristic as a frequency coordinate

The Euler characteristic is often introduced as a special alternating sum. Here it is characterized as the unique nontrivial integral sign-character evaluation on dimensions. This recasts alternation as harmonic analysis on the parity quotient $\mathbb Z/2\mathbb Z$.

### 10.2. Chain complexes and degree shifts

A bounded chain complex with finite-rank groups gives coefficients $x(d)$ equal to ranks or virtual ranks. Its ordinary Euler characteristic is $\chi(x)$. Shifting the complex by one degree swaps parity and negates $\chi$; shifting by two preserves it. Allowing negative homological degrees requires no alteration of the formula.

### 10.3. Sparse computation and consistency checks

In computational pipelines that aggregate graded data, $(M,\chi)$ is a compressed representation of the parity totals. The congruence $M\equiv\chi\pmod2$ is an immediate integrity check. If it fails, an arithmetic, indexing, or data-transmission error has occurred.

### 10.4. Fast transforms

The matrix $H$ is the order-two Walsh–Hadamard transform. The additions $M=E+O$ and $\chi=E-O$ form a single butterfly. Larger Walsh transforms recursively repeat this operation across several binary gradings. Thus the dimensional calculation is the atomic case of a standard fast-transform architecture.

### 10.5. Product decompositions

The convolution law for parity sectors is cumbersome compared with componentwise multiplication of $(M,\chi)$. Passing to character coordinates diagonalizes products, precisely as Fourier transforms diagonalize convolution. This can simplify repeated product computations or generating-function manipulations.

## 11. Scope and limitations

The model records finitely supported integer coefficients by degree. It does not, by itself, encode attaching maps, incidence data, homology differentials, geometric realization, or homotopy type. Two distinct spaces can have identical cell counts and therefore identical values of all invariants studied here.

Negative dimensions are formal degree labels in this framework. The reflection theorem is an algebraic self-duality of graded data, not a claim that ordinary finite-dimensional spaces acquire literal cells of negative geometric dimension.

The character classification also depends on integral units. Enlarging the coefficient ring enlarges its unit group and can create additional characters. For cyclic residue classes modulo $n$, a full Fourier theory generally requires a ring containing appropriate $n$th roots of unity.

Finally, sector masses and total mass are signed. Statements about nonnegative cell counts need additional hypotheses. For nonnegative coefficients one obtains inequalities such as $M\ge |\chi|$, which need not hold for arbitrary virtual data.

## 12. Future work

The Laurent-polynomial formulation suggests bundling total mass and Euler characteristic as the evaluations $X(1)$ and $X(-1)$ and determining their joint kernel. The image has already been characterized at the level of pairs: it consists exactly of integer pairs with matching parity. A kernel description would identify which Laurent polynomials vanish at both signs and relate this to divisibility by $t^2-1$.

A second direction replaces parity by residue classes modulo $n$. With coefficients in a cyclotomic integer ring, characters at $n$th roots of unity should recover all residue-sector masses through discrete Fourier inversion. The current theory is exactly the case $n=2$, where all character values remain integral and inversion can be stated without denominators.

A third direction develops the convolution and Künneth viewpoint. The parity-sector vector transforms under products by convolution on $\mathbb Z/2\mathbb Z$, while total mass and Euler characteristic multiply coordinatewise. This should extend to higher cyclic gradings and multigradings.

Reflection in the parity theory fixes both characters because signs are self-inverse. For higher characters, reflection should send a character to its inverse and, for unitary realizations, to its complex or cyclotomic conjugate. This offers a broader formulation of degree-reflection duality.

Finally, bounded chain complexes and finite CW complexes can be mapped into the virtual cellular model by recording ranks or cell multiplicities. Establishing compatibility with ordinary Euler characteristic, homological cancellation, and degree shifts would connect the elementary character theory developed here to standard topological and homological constructions.

## 13. Conclusion

Integer-graded virtual cellular data admit exactly two evaluations arising from characters valued in the units of the integers. The trivial character produces total mass, while the unique nontrivial character $d\mapsto(-1)^d$ produces dimensional Euler characteristic. These are the two Fourier coordinates of parity. Their character table recovers the even and odd masses through

$$
M+\chi=2E,
\qquad
M-\chi=2O.
$$

Dimension reflection preserves the Euler coordinate because parity is unchanged by negation. The framework applies uniformly to positive and negative degrees, identifies a precise arithmetic rigidity behind the Euler sign, and places the alternating sum within the general principle that characters diagonalize convolution. In its smallest possible form, Fourier analysis explains both why the Euler sign is canonical and exactly what information it retains.