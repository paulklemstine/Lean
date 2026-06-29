# Two Independent Derivations of the Law of Quadratic Reciprocity: Eisenstein's Lattice-Point Count and the Quadratic Gauss Sum

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Number Theory

## Abstract

The Law of Quadratic Reciprocity is the assertion that, for distinct odd primes
$p$ and $q$, the Legendre symbols $\left(\frac{q}{p}\right)$ and
$\left(\frac{p}{q}\right)$ satisfy
$$\left(\frac{q}{p}\right)\left(\frac{p}{q}\right) = (-1)^{\frac{p-1}{2}\cdot\frac{q-1}{2}}.$$
We present two derivations of this law that rest on **disjoint** mechanisms. The
first is Eisenstein's geometric proof: a Legendre symbol is rewritten as the parity
of a sum of floor functions counting lattice points beneath a line, and reciprocity
emerges from partitioning a rectangle into two triangles by its diagonal. The
second is the algebraic proof via the quadratic Gauss sum, whose defining identity
$g^2 = \chi(-1)\,|F|$ exhibits a square root of $\pm p$ inside a cyclotomic field
and converts reciprocity into the compatibility of two Frobenius computations. We
state both as the identity
$\left(\frac{q}{p}\right)\left(\frac{p}{q}\right) = (-1)^{\lfloor p/2\rfloor\lfloor q/2\rfloor}$
(equal to the displayed form because $\lfloor p/2\rfloor = \frac{p-1}{2}$ for odd
$p$), and we record the two supplementary laws governing $\left(\frac{-1}{p}\right)$
and $\left(\frac{2}{p}\right)$. The development is organized so that the two main
theorems share no common proof-theoretic core: the geometric proof bottoms out on
lattice-point identities, the algebraic proof on character theory and the Frobenius
power map.

## 1. Introduction

Quadratic reciprocity, Gauss's *theorema aureum*, is the prototype of all
reciprocity laws in number theory. Its statement concerns the **Legendre symbol**,
the most basic measure of whether an integer is a perfect square modulo a prime.

A striking feature of the law is the multiplicity of its proofs: hundreds are
known, drawing on lattice geometry, finite-field algebra, Gauss sums, the theory
of cyclotomic fields, permutation parity (Zolotarev), and class field theory. These
proofs are not merely cosmetic variations; they reveal genuinely different
structural reasons for the same arithmetic coincidence.

This paper isolates and contrasts two of these reasons. We give:

1. **A geometric proof** (Section 3), following Eisenstein, in which the Legendre
   symbol is realized as a lattice-point parity and reciprocity becomes a
   rectangle-splitting identity.
2. **An algebraic proof** (Section 4), via the quadratic Gauss sum, in which
   reciprocity becomes the compatibility of two Frobenius actions on a square root
   of $\pm p$.

We also record (Section 5) the two supplementary laws. Throughout, the emphasis is
on the *independence* of the two main arguments: they share definitions (the
Legendre symbol, the quadratic character) but no theorem that does the decisive
work.

## 2. Definitions and conventions

Throughout, $p$ and $q$ denote distinct odd primes.

**Definition 2.1 (Quadratic residue).** A nonzero residue $a$ modulo a prime $p$
is a *quadratic residue* if $a \equiv x^2 \pmod p$ for some integer $x$, and a
*quadratic non-residue* otherwise.

**Definition 2.2 (Legendre symbol).** For a prime $p$ and an integer $a$, the
Legendre symbol is
$$\left(\frac{a}{p}\right) = \begin{cases} 0 & \text{if } p \mid a,\\ +1 & \text{if } a \text{ is a quadratic residue mod } p,\\ -1 & \text{if } a \text{ is a quadratic non-residue mod } p.\end{cases}$$
Equivalently, by Euler's criterion, $\left(\frac{a}{p}\right) \equiv a^{(p-1)/2}
\pmod p$ as an element of $\{-1,0,1\}$. The Legendre symbol is completely
multiplicative in its top argument:
$\left(\frac{ab}{p}\right) = \left(\frac{a}{p}\right)\left(\frac{b}{p}\right)$.

**Definition 2.3 (Quadratic character of a finite field).** For a finite field $F$
with $|F|$ odd, the *quadratic character* $\chi$ is the multiplicative character
$\chi(a) = +1$ if $a$ is a nonzero square, $\chi(a) = -1$ if $a$ is a non-square,
and $\chi(0) = 0$. It is the unique multiplicative character of order $2$. For
$F = \mathbb{Z}/p$ it coincides with the Legendre symbol.

**Definition 2.4 (Additive character).** An *additive character* of a finite field
$F$ valued in a commutative ring $R$ is a homomorphism $\psi : (F,+) \to (R^\times,
\cdot)$. It is *primitive* if it is non-trivial; concretely, for $F = \mathbb{Z}/p$
and $\zeta$ a primitive $p$-th root of unity, $\psi(x) = \zeta^x$ is primitive.

**Definition 2.5 (Gauss sum).** For a multiplicative character $\chi$ and an
additive character $\psi$ of $F$, the *Gauss sum* is
$$g(\chi,\psi) = \sum_{x \in F} \chi(x)\,\psi(x).$$
When $\chi$ is the quadratic character we call $g$ the *quadratic Gauss sum*.

**Definition 2.6 (Floor sum).** For distinct odd primes $p,q$ we write
$$S_{q,p} = \sum_{x=1}^{(p-1)/2} \left\lfloor \frac{xq}{p} \right\rfloor.$$
In the formal development this is rendered over the half-open integer interval
$x \in [1, \lfloor q/2 \rfloor + 1)$ with summand $\lfloor xp/q\rfloor$ for the
companion sum; we use the classical notation here.

## 3. The geometric proof (Eisenstein)

The geometric proof has two ingredients: a translation of the Legendre symbol into
a lattice-point parity, and a counting identity for a rectangle.

### 3.1 The Eisenstein expansion

**Lemma 1 (Eisenstein lattice-point expansion).**
*For distinct odd primes $p$ and $q$,*
$$\left(\frac{q}{p}\right) = (-1)^{\,S_{q,p}}, \qquad S_{q,p} = \sum_{x=1}^{(p-1)/2}\left\lfloor \frac{xq}{p}\right\rfloor.$$

*(Formal name: `QuadraticReciprocity.Eisenstein.legendreSym_eq_neg_one_pow_sum`,
stated with the companion sum $\sum_{x=1}^{(q-1)/2}\lfloor xp/q\rfloor$ governing
$\left(\frac{q}{p}\right)$.)*

**Proof sketch.** This is Eisenstein's refinement of Gauss's lemma. Gauss's lemma
states that $\left(\frac{q}{p}\right) = (-1)^\mu$, where $\mu$ is the number of
elements of $\{q\cdot 1, q\cdot 2, \dots, q\cdot\frac{p-1}{2}\}$ whose least
positive residue modulo $p$ exceeds $p/2$. Writing $xq = p\lfloor xq/p\rfloor +
r_x$ with $0 < r_x < p$ and summing over $x = 1,\dots,\frac{p-1}{2}$, one compares
the parity of $\sum_x \lfloor xq/p\rfloor$ with $\mu$ modulo $2$, using that $q$ is
odd and that the residues $r_x$ pair up symmetrically about $p/2$. The floor sum
and the Gauss-lemma count have the same parity, yielding the claimed exponent.
$\square$

Geometrically, for fixed $x$ the integer $\lfloor xq/p\rfloor$ is the number of
lattice points $(x,y)$ with $1 \le y$ lying strictly below the line $y =
\frac{q}{p}x$. Hence $S_{q,p}$ counts the lattice points strictly below the
diagonal in the columns $1 \le x \le \frac{p-1}{2}$.

### 3.2 The rectangle identity and the main theorem

**Theorem 1 (Quadratic reciprocity, geometric proof).**
*For distinct odd primes $p$ and $q$,*
$$\left(\frac{q}{p}\right)\left(\frac{p}{q}\right) = (-1)^{\lfloor p/2\rfloor\cdot\lfloor q/2\rfloor} = (-1)^{\frac{p-1}{2}\cdot\frac{q-1}{2}}.$$

*(Formal name: `QuadraticReciprocity.Eisenstein.quadratic_reciprocity`.)*

**Proof sketch.** Apply Lemma 1 to both symbols:
$$\left(\frac{q}{p}\right) = (-1)^{S_{q,p}}, \qquad \left(\frac{p}{q}\right) = (-1)^{S_{p,q}},$$
with $S_{p,q} = \sum_{y=1}^{(q-1)/2}\lfloor yp/q\rfloor$. Multiplying,
$$\left(\frac{q}{p}\right)\left(\frac{p}{q}\right) = (-1)^{S_{q,p}+S_{p,q}}.$$
It remains to evaluate the combined exponent. Consider the open rectangle
$R = \{(x,y) : 1 \le x \le \frac{p-1}{2},\ 1 \le y \le \frac{q-1}{2}\}$, which
contains exactly $\frac{p-1}{2}\cdot\frac{q-1}{2}$ lattice points. The diagonal
$y = \frac{q}{p}x$ contains no lattice point of $R$: equality $py = qx$ with
$1 \le x \le \frac{p-1}{2}$ would force $p \mid x$ (as $\gcd(p,q)=1$), impossible in
range. Thus every lattice point of $R$ lies strictly below or strictly above the
diagonal. The points below, counted column by column, number $S_{q,p}$; the points
above, counted row by row, number $S_{p,q}$. Therefore
$$S_{q,p} + S_{p,q} = \frac{p-1}{2}\cdot\frac{q-1}{2} = \left\lfloor\frac{p}{2}\right\rfloor\left\lfloor\frac{q}{2}\right\rfloor.$$
Substituting yields the claim. In the formal development this rectangle identity is
the lemma `ZMod.sum_mul_div_add_sum_mul_div_eq_mul`, and the two halves of the
Eisenstein expansion are `ZMod.eisenstein_lemma`; the proof combines them with
`pow_add` and never invokes the library's own reciprocity theorem. $\square$

**Remark.** The proof is genuinely elementary: it uses only properties of floor
functions, finite sums, and the partition of a rectangle by a generic diagonal.
The sign $(-1)^{\frac{p-1}{2}\cdot\frac{q-1}{2}}$ is *the area of the rectangle*
read modulo $2$.

## 4. The algebraic proof (quadratic Gauss sum)

The algebraic proof replaces lattice geometry with the algebra of characters. Its
fulcrum is a single identity about the square of a Gauss sum.

### 4.1 The Gauss-sum square identity

**Lemma 2 (Gauss-sum square).**
*Let $F$ be a finite field and $R$ a commutative integral domain. Let $\chi : F \to
R$ be a non-trivial quadratic multiplicative character and $\psi : F \to R$ a
primitive additive character. Then the Gauss sum satisfies*
$$g(\chi,\psi)^2 = \chi(-1)\,|F|,$$
*where $|F|$ is the cardinality of $F$ regarded as an element of $R$.*

*(Formal name: `QuadraticReciprocity.GaussSum.gauss_sum_sq_value`.)*

**Proof sketch.** Expand the square:
$$g(\chi,\psi)^2 = \sum_{x,y} \chi(x)\chi(y)\,\psi(x+y) = \sum_{x,y}\chi(xy)\,\psi(x+y).$$
For $x \neq 0$ substitute $y = xt$, so $xy = x^2 t$ and $\chi(xy) = \chi(t)$ (since
$\chi(x^2)=1$), while $x+y = x(1+t)$. Summing over $x$ for fixed $t$ and using that
$\psi$ is a non-trivial character (so $\sum_x \psi(x(1+t)) = -1$ unless $t=-1$, in
which case it equals $|F|-1$), the double sum collapses. The only surviving
contribution is from $t = -1$, giving $\chi(-1)(|F|-1) - \sum_{t\neq -1}\chi(t)$;
since $\sum_t \chi(t) = 0$ for a non-trivial character, this simplifies to
$\chi(-1)\,|F|$. $\square$

Specializing to $F = \mathbb{Z}/p$ and $\psi(x) = \zeta^x$ gives the classical
$g^2 = \left(\frac{-1}{p}\right)p = (-1)^{(p-1)/2}p$: the quadratic Gauss sum is a
square root of $\pm p$.

### 4.2 The Frobenius comparison and the main theorem

**Theorem 2 (Quadratic reciprocity, Gauss-sum proof).**
*For distinct odd primes $p$ and $q$,*
$$\left(\frac{q}{p}\right)\left(\frac{p}{q}\right) = (-1)^{\lfloor p/2\rfloor\cdot\lfloor q/2\rfloor} = (-1)^{\frac{p-1}{2}\cdot\frac{q-1}{2}}.$$

*(Formal name: `QuadraticReciprocity.GaussSum.quadratic_reciprocity`.)*

**Proof sketch.** Work in a finite field $F'$ of characteristic $q$ large enough to
contain a $p$-th root of unity, and let $g$ be the quadratic Gauss sum for
$\mathbb{Z}/p$ realized in $F'$. By Lemma 2, $g^2 = (-1)^{(p-1)/2}p =: p^\ast$ in
$F'$. We compute $g^q$ in two ways.

*First way (Frobenius/permutation of exponents).* In characteristic $q$ the map
$z \mapsto z^q$ is a ring homomorphism (the Frobenius), so it acts on
$g = \sum_x \left(\frac{x}{p}\right)\zeta^x$ termwise:
$$g^q = \sum_x \left(\frac{x}{p}\right)\zeta^{qx} = \left(\frac{q}{p}\right)\sum_x \left(\frac{q^{-1}\cdot qx}{p}\right)\zeta^{qx} = \left(\frac{q}{p}\right)g,$$
where reindexing $x \mapsto q^{-1}x$ and multiplicativity of the Legendre symbol
extract the factor $\left(\frac{q}{p}\right)$.

*Second way (Euler's criterion).* Since $g^2 = p^\ast$,
$$g^q = g\cdot g^{q-1} = g\cdot (p^\ast)^{(q-1)/2} = g\cdot\left(\frac{p^\ast}{q}\right),$$
by Euler's criterion applied in $F'$ (characteristic $q$).

Equating and cancelling $g$ (which is a unit, as $g^2 = p^\ast \neq 0$ in $F'$),
$$\left(\frac{q}{p}\right) = \left(\frac{p^\ast}{q}\right) = \left(\frac{(-1)^{(p-1)/2}p}{q}\right) = \left(\frac{-1}{q}\right)^{(p-1)/2}\left(\frac{p}{q}\right).$$
By the first supplementary law $\left(\frac{-1}{q}\right) = (-1)^{(q-1)/2}$, so
$$\left(\frac{q}{p}\right) = (-1)^{\frac{p-1}{2}\cdot\frac{q-1}{2}}\left(\frac{p}{q}\right),$$
which rearranges (using $\left(\frac{p}{q}\right)^2 = 1$) to the stated identity.
In the formal development this entire chain is packaged by the finite-field
character identity `quadraticChar_odd_prime`, which is the field-theoretic shadow of
Lemma 2 together with the Frobenius power law `Char.card_pow_card`; the
$\left(\frac{-1}{\cdot}\right)$ bookkeeping is handled by `ZMod.χ₄_eq_neg_one_pow`
and `quadraticChar_sq_one`, and the result is transported to Legendre symbols over
$\mathbb{Z}/p$ and $\mathbb{Z}/q$. $\square$

**Remark.** No lattice point, floor, or rectangle appears anywhere in Section 4.
The decisive object is the Gauss sum and the decisive fact is its square; the rest
is the algebra of the Frobenius endomorphism. This is the sense in which the two
proofs are *independent*: Theorem 1 rests on `eisenstein_lemma` and the rectangle
identity, Theorem 2 on `gaussSum_sq`/`quadraticChar_odd_prime` and
`card_pow_card`, with no shared decisive lemma.

## 5. The supplementary laws

The same circle of ideas yields the two "supplementary" laws, which determine the
Legendre symbols of $-1$ and $2$ purely from congruence conditions on $p$.

**Proposition 3 (First supplementary law).** *For an odd prime $p$,*
$$\left(\frac{-1}{p}\right) = (-1)^{(p-1)/2}, \qquad\text{i.e.}\qquad \left(\frac{-1}{p}\right) = +1 \iff p \equiv 1 \pmod 4.$$
**Proof sketch.** Immediate from Euler's criterion $\left(\frac{-1}{p}\right)
\equiv (-1)^{(p-1)/2}\pmod p$, both sides lying in $\{-1,1\}$. $\square$

**Proposition 4 (Second supplementary law).** *For an odd prime $p$,*
$$\left(\frac{2}{p}\right) = (-1)^{(p^2-1)/8}, \qquad\text{i.e.}\qquad \left(\frac{2}{p}\right) = +1 \iff p \equiv \pm 1 \pmod 8.$$
**Proof sketch.** Apply Gauss's lemma to $a = 2$: count the multiples $2\cdot
1,\dots,2\cdot\frac{p-1}{2}$ exceeding $p/2$. The count is
$\frac{p-1}{2}-\lfloor p/4\rfloor$, whose parity matches $(p^2-1)/8$, giving the
exponent. Alternatively, evaluate the relevant Gauss sum in a field of
characteristic $p$ containing a primitive $8$-th root of unity. $\square$

In the formal development the supplementary laws are stated in explicit congruence
form: $\left(\frac{-1}{p}\right)$ controlled by $p \bmod 4$ and
$\left(\frac{2}{p}\right)$ by $p \bmod 8$, in both the residue and non-residue
directions.

## 6. Algorithms

The proofs are constructive enough to drive direct computation. We summarize three
algorithms (full Python in the accompanying demonstration).

**Algorithm A — Lattice-point evaluation of the Eisenstein exponent.** Given
distinct odd primes $p,q$, compute $S_{q,p} = \sum_{x=1}^{(p-1)/2}\lfloor
xq/p\rfloor$ and $S_{p,q} = \sum_{y=1}^{(q-1)/2}\lfloor yp/q\rfloor$ by direct
summation, then verify $\left(\frac{q}{p}\right) = (-1)^{S_{q,p}}$ and the rectangle
identity $S_{q,p}+S_{p,q} = \frac{p-1}{2}\cdot\frac{q-1}{2}$. Complexity:
$O(p+q)$ additions and integer divisions.

**Algorithm B — Gauss-sum square verification over $\mathbb{C}$.** Given a prime
$p$, form $g = \sum_{x=0}^{p-1}\left(\frac{x}{p}\right)e^{2\pi i x/p}$ numerically
and check $g^2 \approx (-1)^{(p-1)/2}p$. Complexity: $O(p)$ complex operations.

**Algorithm C — Direct Legendre symbol via Euler's criterion.** Compute
$\left(\frac{a}{p}\right)$ as $a^{(p-1)/2} \bmod p$ normalized to $\{-1,0,1\}$, used
as the ground-truth oracle against which the two proof-driven computations are
checked. Complexity: $O(\log p)$ modular multiplications by fast exponentiation.

## 7. Applications

Quadratic reciprocity, with its supplementary laws and the Jacobi-symbol extension,
is the foundation of fast quadratic-residuosity testing. It underlies:

- **Primality and compositeness testing.** Solovay–Strassen primality testing
  compares $a^{(n-1)/2}\bmod n$ with the Jacobi symbol $\left(\frac{a}{n}\right)$;
  the reciprocity law makes the Jacobi symbol computable in $O(\log^2 n)$ time
  without factoring.
- **Cryptography.** The hardness of the quadratic residuosity problem (deciding
  residuosity modulo a composite without its factorization) underpins the
  Goldwasser–Micali cryptosystem and related protocols; reciprocity is what makes
  the symbol efficiently computable for the prime case while leaving the composite
  case hard.
- **Solving congruences.** Deciding whether $x^2 \equiv a \pmod p$ has a solution,
  a basic step in algorithms for square roots modulo primes and for representing
  integers by quadratic forms.

## 8. Discussion

The two proofs presented here are representatives of two grand traditions. The
Eisenstein proof belongs to the **geometric/combinatorial** tradition, where
arithmetic statements are recast as counting problems; its conceptual payload is
that the reciprocity sign is the parity of the area of an explicit rectangle. The
Gauss-sum proof belongs to the **algebraic/arithmetic-geometric** tradition, where
the same statement is read off the action of Frobenius on a distinguished algebraic
object; its conceptual payload is that the quadratic Gauss sum realizes a square
root of $\pm p$ inside the cyclotomic field $\mathbb{Q}(\zeta_p)$, and reciprocity
is the compatibility of two Frobenius computations on it.

This second viewpoint is not an endpoint but a doorway. The Gauss sum exhibits the
unique quadratic subfield $\mathbb{Q}(\sqrt{p^\ast}) \subseteq \mathbb{Q}(\zeta_p)$,
and "$q$ is a square mod $p$" becomes "$q$ splits in $\mathbb{Q}(\sqrt{p^\ast})$".
That reformulation is precisely the degree-two case of Artin reciprocity in class
field theory; quadratic reciprocity is its smallest, most visible instance.

The value of carrying *both* proofs to completion is methodological. A single proof
establishes truth; two independent proofs establish *robustness* and isolate which
features of the integers are responsible. Here the geometric proof shows the law
needs nothing beyond elementary counting, while the algebraic proof shows the law
is the shadow of a much larger structure.

## 9. Future directions

Three concrete continuations are natural.

1. **A permutation-sign (Zolotarev) proof.** The Legendre symbol
   $\left(\frac{a}{p}\right)$ equals the sign of the permutation $x \mapsto ax$ of
   $\mathbb{Z}/p$; reciprocity then follows by comparing two such signs on
   $\mathbb{Z}/(pq)$ through the Chinese Remainder isomorphism $\mathbb{Z}/(pq)
   \cong \mathbb{Z}/p \times \mathbb{Z}/q$. This recasts the law as the sign of a
   single linear map under a change of basis.

2. **Reciprocity as a special case of Artin reciprocity.** The Gauss-sum proof is
   the degree-two shadow of Artin reciprocity for the quadratic subfield
   $\mathbb{Q}(\sqrt{p^\ast}) \subseteq \mathbb{Q}(\zeta_p)$; a development based on
   cyclotomic extensions would reproduce Theorem 2 as the splitting law of $q$ in
   that subfield, since "$p^\ast$ is a square mod $q$" is exactly the condition for
   $q$ to split.

3. **Jacobi-symbol reciprocity, proved independently of the prime case.** Extending
   the law to the Jacobi symbol $\left(\frac{a}{n}\right)$ for odd $n$ directly,
   rather than by reduction to primes, gives the algorithmically useful form and
   clarifies which parts of the argument are intrinsically about primality.

## 10. Conclusion

We have presented the Law of Quadratic Reciprocity through two independent lenses.
Theorem 1 derives it from Eisenstein's lattice-point count and a rectangle-splitting
identity; Theorem 2 derives it from the square of the quadratic Gauss sum and the
Frobenius map. Both arrive at
$\left(\frac{q}{p}\right)\left(\frac{p}{q}\right) = (-1)^{\frac{p-1}{2}\cdot\frac{q-1}{2}}$,
and together with the two supplementary laws for $\left(\frac{-1}{p}\right)$ and
$\left(\frac{2}{p}\right)$ they give a complete, self-contained account of the
quadratic reciprocity of odd primes from two genuinely different starting points.
