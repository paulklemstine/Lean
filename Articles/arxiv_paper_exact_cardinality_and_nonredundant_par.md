# When Different Polynomials Whisper the Same Codeword

## The hidden quotient inside character–polynomial codes

A code is supposed to turn a message into a signal. Ideally, different messages produce different signals: if two inputs collapse to the same output, information has already been lost before transmission begins. Yet in algebraic coding theory, a parameter list can be deceptively large. A family may contain many distinct-looking polynomials while producing far fewer distinct codewords.

Character–polynomial codes offer a clean example of this phenomenon. Their ingredients come from finite fields, polynomial evaluation, and additive characters—functions that convert field elements into complex roots of unity. These constructions are attractive because they translate algebra into highly structured phase patterns, much as a Fourier transform translates data into oscillations. But over extension fields, the translation can erase distinctions among coefficients. The eraser is the trace map.

The central lesson is simple and far-reaching: **the true parameter space is not the original coefficient space, but its quotient by the trace kernel**. Once this quotient is recognized, equality of codewords, exact cardinality, and a nonredundant parametrization all follow from one structural idea.

## From field elements to phases

Let $K$ be a finite extension of a finite field $F$. A typical additive character on $K$ has the form

$$
\chi(x)=\exp\!\left(\frac{2\pi i}{p}\operatorname{Tr}_{K/\mathbf F_p}(x)\right),
$$

where $p$ is the characteristic and $\operatorname{Tr}_{K/\mathbf F_p}$ is the field trace. A polynomial $f$ can be evaluated at a collection of field points, and the character can then be applied to those values. The result is a vector of roots of unity: a codeword.

At first glance, counting the available polynomials appears to count the codewords. That conclusion can fail. The character does not inspect $x$ directly; it inspects only its trace. If $z$ has trace zero, then $x$ and $x+z$ generate the same phase. Thus every trace-zero direction is invisible.

The same mechanism can be isolated without committing to a particular field or evaluation set. Let $A$ and $B$ be additive abelian groups. Think of $A$ as the raw parameter space and $B$ as the trace-visible data. Let

$$
\tau:A\longrightarrow B
$$

be an additive map, and let

$$
E:B\longrightarrow W
$$

be an injective evaluation-and-character map into a word space $W$. Define the encoder by

$$
C(a)=E(\tau(a)).
$$

The injectivity of $E$ says that after the visible data have been formed, the evaluation stage loses nothing further. All redundancy must therefore occur in $\tau$.

## The collision theorem

The first result identifies codeword collisions exactly.

**Collision Theorem.** For any $a,b\in A$,

$$
C(a)=C(b)
\quad\Longleftrightarrow\quad
a-b\in\ker\tau.
$$

The proof is almost a one-line diagnosis. Since $E$ is injective, equality $E(\tau(a))=E(\tau(b))$ is equivalent to $\tau(a)=\tau(b)$. Additivity turns this into $\tau(a-b)=0$, which is precisely the statement that $a-b$ lies in the kernel.

This theorem says more than “the encoder may not be injective.” It describes every collision and no others. Parameters collide exactly along cosets of $\ker\tau$. If one parameter produces a particular word, then every point obtained by adding a trace-zero parameter produces that same word; conversely, no parameter outside that coset can do so.

Imagine a stack of transparent sheets, each carrying the same drawing. The original space $A$ contains the whole stack. The encoder looks straight through it, seeing only one drawing per vertical stack. The kernel gives the vertical direction, and a coset is one stack of indistinguishable sheets.

## Quotienting away the redundancy

The natural repair is to declare two parameters equivalent when their difference is invisible:

$$
a\sim b
\quad\Longleftrightarrow\quad
a-b\in\ker\tau.
$$

The set of equivalence classes is the quotient group

$$
A/\ker\tau.
$$

The encoder is constant on each class, so it induces a new map

$$
\overline C:A/\ker\tau\longrightarrow W,
\qquad
\overline C([a])=C(a).
$$

Two fundamental facts now hold.

**Quotient Parametrization Theorem.** The induced map $\overline C$ is injective, and its image is exactly the image of the original encoder $C$.

To see injectivity, suppose $\overline C([a])=\overline C([b])$. The Collision Theorem gives $a-b\in\ker\tau$, so $[a]=[b]$. To compare images, observe that every quotient class has a representative in $A$, while every original parameter determines a quotient class. No word is added and no word is lost.

This is the algebraic heart of nonredundant parametrization. The quotient does not merely provide the right number of labels. It gives exactly one abstract label for each word.

## Exact cardinality

When the spaces are finite, the quotient immediately yields the corrected code size.

**Exact Cardinality Theorem.** If the code is finite, then

$$
|\operatorname{im} C|=|A/\ker\tau|.
$$

For finite groups, this can also be written as

$$
|\operatorname{im} C|=\frac{|A|}{|\ker\tau|}.
$$

Thus the naive parameter count $|A|$ overcounts by the factor $|\ker\tau|$. The larger the invisible trace-zero subspace, the more severe the redundancy.

In a linear setting the formula becomes especially transparent. Let $F$ be a finite field with $q=|F|$, let $K$ and $R$ be finite-dimensional $F$-vector spaces, and let $\tau:K\to R$ be linear. If the post-trace map is injective, then

$$
|\operatorname{im} C|=q^{\dim_F(\operatorname{im}\tau)}.
$$

**Rank Cardinality Theorem.** The exponent governing the number of words is the rank of the trace-like map, not the dimension of the original parameter space.

Indeed, the first isomorphism theorem identifies $K/\ker\tau$ with $\operatorname{im}\tau$. A vector space of dimension $r$ over a $q$-element field has exactly $q^r$ elements.

For example, suppose raw coefficients form a $5$-dimensional vector space over $\mathbf F_3$, but the visible trace data have rank $3$. There are $3^5=243$ raw parameters but only

$$
3^3=27
$$

distinct codewords. Each word has $3^{5-3}=9$ raw descriptions.

## Concrete representatives: transversals

Quotients are canonical, but implementations often want actual polynomials rather than equivalence classes. A **kernel transversal** is a subset $T\subseteq A$ containing exactly one representative from each coset of $\ker\tau$.

**Transversal Theorem.** If $T$ is a kernel transversal, then the restricted encoder

$$
C|_T:T\longrightarrow W
$$

is injective, has the same image as $C$, and therefore gives a bijection

$$
T\cong\operatorname{im} C.
$$

Consequently,

$$
|T|=|\operatorname{im} C|
$$

whenever these sets are finite.

The proof follows the geometry of cosets. Two members of $T$ cannot differ by a kernel element unless they are the unique representative of the same coset, hence equal. Conversely, every raw parameter lies in some coset, and that coset has a representative in $T$ producing the same codeword.

This theorem turns structural understanding into a practical design rule: choose one coefficient vector from every invisible-equivalence class and discard the rest. Encoding becomes collision-free without changing the code itself.

## Families of coefficients

Polynomials bring many coefficients at once. Let $I$ index the permitted monomials, and let a coefficient family be a function $c:I\to K$. Apply the trace coordinate by coordinate:

$$
\tau_I(c)(i)=\tau(c(i)).
$$

Then the kernel has an exact coordinatewise description.

**Coordinatewise Kernel Theorem.** A family $c$ lies in $\ker\tau_I$ if and only if every coefficient lies in $\ker\tau$:

$$
c\in\ker\tau_I
\quad\Longleftrightarrow\quad
\forall i\in I,\ c(i)\in\ker\tau.
$$

Accordingly, two coefficient families $c$ and $d$ encode to the same word exactly when

$$
\forall i\in I,\ c(i)-d(i)\in\ker\tau.
$$

This localizes a global codeword collision: every coefficient difference must be trace-invisible. If the coordinates behave independently, one may choose a representative for each coefficient modulo the trace kernel and assemble those choices into a nonredundant polynomial family.

In concrete character–polynomial constructions, exponent symmetries can create further organization. Frobenius sends an exponent to another exponent in the same cyclotomic orbit, and traces identify contributions across such orbits. The quotient framework tells us what must ultimately be computed: the rank of the visible data and a transversal to its kernel. Determining orbit-by-orbit ranks is the next arithmetic layer, rather than a replacement for the quotient principle.

## Why the correction matters

Exact cardinality is not bookkeeping. A code’s logarithmic size determines its information rate. If $q^n$ apparent choices collapse to $q^r$ words, then the effective dimension is $r$, not $n$. Claims about rates, parameter efficiency, and comparisons with other code families must use the image size.

Nonredundant parametrization also matters computationally. Searching over duplicate polynomials repeats the same codeword many times. Quotient coordinates or a transversal reduce storage, accelerate exhaustive search, and make random sampling uniform over actual words rather than over descriptions. In decoding and optimization, eliminating flat kernel directions removes artificial ambiguity.

There is a conceptual payoff as well. The trace kernel is not a defect in the construction. It is a symmetry. Raw parameters related by a kernel element are gauge-equivalent descriptions of the same observable word. Passing to the quotient is the standard mathematical act of replacing descriptions by observables.

## A reusable blueprint

The argument extends beyond character–polynomial codes. Whenever an encoder factors as

$$
\text{parameters}\xrightarrow{\ \tau\ }
\text{visible data}\xrightarrow{\ E\ }
\text{words},
$$

with $\tau$ additive and $E$ injective, five conclusions follow:

1. two parameters collide exactly when their difference lies in $\ker\tau$;
2. the encoder descends to an injective map on $A/\ker\tau$;
3. the quotient and the original encoder produce the same set of words;
4. any kernel transversal gives a concrete, collision-free family;
5. over a finite field, the exact number of words is $q^{\operatorname{rank}\tau}$.

The apparent complexity of polynomial phases is therefore governed by a familiar piece of linear algebra: kernel, quotient, image, rank. Once the invisible directions are separated from the visible ones, the code reveals its true size and its natural coordinates. Different polynomials may whisper the same codeword—but the quotient tells us exactly when they do, exactly how many distinct whispers remain, and exactly how to choose one unambiguous voice for each.