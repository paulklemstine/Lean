# Sums of Three Cubes: The Exact Modulo-Nine Obstruction, Integral Families, and Cubic Surfaces

**Aristotle**  
**July 31, 2026**

## Abstract

We study integral and modular solutions of the Diophantine equation

$$
x^3+y^3+z^3=k.
$$

The central result is a complete local classification modulo nine: the congruence has a solution if and only if $k$ is not congruent to $4$ or $5$ modulo nine. The proof rests on the fact that every cube is congruent to $0$, $1$, or $-1$ modulo nine, followed by an explicit construction for each of the seven admissible residue classes. Consequently, every globally representable integer avoids the two forbidden classes, and the progressions $9t+4$ and $9t+5$ contain no sums of three integer cubes. We establish the general passage from integral solutions to solutions modulo every modulus, interpret representability as the existence of an integral point on an affine cubic surface, prove sign symmetry, and develop the two-parameter identity

$$
a^3+b^3+(-a-b)^3=-3ab(a+b).
$$

This identity yields an infinite family of represented targets and, in particular, nondegenerate representations $6t^3=(2t)^3+(-t)^3+(-t)^3$ for every nonzero integer $t$. We also give finite algorithms for local classification and bounded global search, clarify the distinction between local admissibility and global representability, and frame further questions in terms of prime-power densities, cubic-surface geometry, and the Hasse principle.

## 1. Introduction

The equation

$$
x^3+y^3+z^3=k
$$

asks whether a prescribed integer $k$ can be expressed as the sum of three integer cubes. The variables are allowed to be negative or zero. Unlike equations involving only nonnegative variables, this equation permits severe cancellation: the individual magnitudes $|x|^3$, $|y|^3$, and $|z|^3$ may greatly exceed $|k|$. Consequently, the failure of a bounded search is not evidence of nonexistence unless an independent height bound is known.

Congruences supply unconditional necessary conditions. If an integral solution exists, reducing its coordinates modulo any positive integer $n$ gives a solution of the corresponding congruence. Modulo nine, cubes have an exceptionally sparse image, and this produces the familiar obstruction $k\not\equiv 4,5\pmod 9$. The first purpose of this paper is to state and prove the stronger exact local result: those two classes are not merely obstructed; they are the only classes not represented modulo nine.

The second purpose is to organize the elementary global consequences around a geometric framework. For each target $k$, the equation defines an affine cubic surface. Integral representability is exactly nonemptiness of its set of integral points, while modular representability is nonemptiness after reduction to a finite residue ring. This language separates a global point from its local shadows and prevents a local theorem from being mistaken for a global converse.

The third purpose is constructive. A polynomial identity supplies a two-parameter family of integral points and a simple specialization yields representations of all targets $6t^3$ using three nonzero coordinates. These families do not settle the general global problem, but they demonstrate how algebraic structure can replace unbounded search.

The results are elementary in their prerequisites and exact in scope. No claim is made that every integer avoiding the modulo-nine obstruction has an integral representation. Rather, the established statements give a complete finite classification at modulus nine, rigorous global exclusions, general functorial reduction, symmetry, and explicit infinite families.

## 2. Definitions and basic framework

### 2.1. Global representability

**Definition 2.1 (global three-cube representability).** An integer $k$ is **globally representable** if there exist integers $x,y,z$ such that

$$
x^3+y^3+z^3=k.
$$

The adjective “global” emphasizes that the equality holds in the integers, not merely after reduction modulo a modulus.

**Definition 2.2 (the forbidden modulo-nine condition).** An integer $k$ is **forbidden modulo nine** if

$$
k\equiv 4\pmod 9
$$

or

$$
k\equiv 5\pmod 9.
$$

Equivalently, the least nonnegative remainder of $k$ upon division by $9$ is $4$ or $5$.

### 2.2. Local representability

**Definition 2.3 (local representability modulo $n$).** Let $n$ be a positive integer. An integer $k$ is **locally representable modulo $n$** if there exist residue classes $x,y,z$ modulo $n$ for which

$$
x^3+y^3+z^3\equiv k\pmod n.
$$

This is a finite existence question. There are only $n^3$ triples of residues to inspect, although algebraic structure can make exhaustive inspection unnecessary.

### 2.3. The affine cubic surface

**Definition 2.4 (three-cube surface).** Let $R$ be a commutative ring and let $k\in R$. Define

$$
S_k(R)=\{(x,y,z)\in R^3:x^3+y^3+z^3=k\}.
$$

When $R=\mathbb Z$, this is the set of integral points on the affine cubic surface with target $k$. When $R=\mathbb Z/n\mathbb Z$, it is the set of solutions modulo $n$.

These definitions immediately recast the two notions of solvability:

$$
k\text{ is globally representable}\quad\Longleftrightarrow\quad S_k(\mathbb Z)\ne\varnothing,
$$

and

$$
k\text{ is locally representable modulo }n\quad\Longleftrightarrow\quad
S_k(\mathbb Z/n\mathbb Z)\ne\varnothing.
$$

The first equivalence will be recorded formally in Section 5.

## 3. Cubes modulo nine

The complete modulo-nine classification begins with the image of the cubing map.

**Lemma 3.1 (cube residues modulo nine).** For every integer $x$,

$$
x^3\equiv 0,1,\text{ or }-1\pmod 9.
$$

In least nonnegative residues, the possibilities are $0$, $1$, and $8$.

**Proof sketch.** The residue of $x^3$ depends only on the residue of $x$. Cubing representatives $0,1,\ldots,8$ gives

$$
0^3,3^3,6^3\equiv 0\pmod 9,
$$

$$
1^3,4^3,7^3\equiv 1\pmod 9,
$$

and

$$
2^3,5^3,8^3\equiv -1\pmod 9.
$$

These three cases exhaust all integers. $\square$

The sparse image of cubing reduces the sumset calculation to three small symbols.

**Lemma 3.2 (avoidance by three cube residues).** If each of $a,b,c$ is congruent modulo nine to one of $0$, $1$, and $-1$, then

$$
a+b+c\not\equiv 4\pmod 9
$$

and

$$
a+b+c\not\equiv 5\pmod 9.
$$

**Proof sketch.** Choose integer representatives from $\{-1,0,1\}$. Their sum lies in the interval $[-3,3]$, so its possible residues modulo nine are

$$
6,7,8,0,1,2,3.
$$

Neither $4$ nor $5$ occurs. Equivalently, a direct enumeration of the $3^3=27$ triples gives the same seven-element sumset. $\square$

Combining the two lemmas yields the principal global obstruction.

**Theorem 3.3 (global modulo-nine obstruction).** If $k$ is globally representable as a sum of three integer cubes, then $k$ is not forbidden modulo nine.

**Proof sketch.** Write $k=x^3+y^3+z^3$. By Lemma 3.1, each summand is congruent to $0$, $1$, or $-1$ modulo nine. Lemma 3.2 excludes residues $4$ and $5$ for their sum. $\square$

**Corollary 3.4 (two impossible arithmetic progressions).** For every integer $t$, neither $9t+4$ nor $9t+5$ is globally representable.

**Proof sketch.** The two targets are congruent to $4$ and $5$ modulo nine, respectively, contradicting Theorem 3.3 if a representation existed. $\square$

This is a uniform nonexistence theorem. It excludes infinitely many targets without any search over coordinates.

## 4. Exact local classification modulo nine

The preceding obstruction is also sufficient for solvability in the finite ring $\mathbb Z/9\mathbb Z$.

**Theorem 4.1 (exact modulo-nine theorem).** For every integer $k$, the congruence

$$
x^3+y^3+z^3\equiv k\pmod 9
$$

has a solution if and only if

$$
k\not\equiv 4,5\pmod 9.
$$

**Proof sketch.** If the congruence has a solution, Lemmas 3.1 and 3.2 show that its target cannot have residue $4$ or $5$. Conversely, every other residue has an explicit witness. The complete table is

| Target residue $r$ | Witness $(x,y,z)$ modulo $9$ | Cubic sum |
|---:|:---:|:---:|
| $0$ | $(0,0,0)$ | $0$ |
| $1$ | $(1,0,0)$ | $1$ |
| $2$ | $(1,1,0)$ | $2$ |
| $3$ | $(1,1,1)$ | $3$ |
| $6$ | $(-1,-1,-1)$ | $-3\equiv 6$ |
| $7$ | $(-1,-1,0)$ | $-2\equiv 7$ |
| $8$ | $(-1,0,0)$ | $-1\equiv 8$ |

Because $0^3=0$, $1^3=1$, and $(-1)^3=-1$, each displayed triple gives the asserted residue. The table covers exactly the seven nonforbidden classes. $\square$

**Corollary 4.2 (modulo-nine local density).** Exactly seven of the nine target residue classes are locally representable modulo nine. Hence the proportion of admissible residue classes is

$$
\frac{7}{9}.
$$

In any sequence of symmetric or one-sided intervals whose lengths tend to infinity, the proportion of integers avoiding the modulo-nine obstruction tends to $7/9$.

**Proof sketch.** Theorem 4.1 leaves precisely the classes $0,1,2,3,6,7,8$. Residue classes modulo nine are equidistributed in long intervals up to an endpoint error bounded independently of the interval length. Dividing by interval length and taking a limit gives $7/9$. $\square$

The density $7/9$ is strictly a density of local admissibility at this modulus. It must not be identified with the density of globally represented integers without a separate global theorem.

## 5. Global solutions, local shadows, and surfaces

The relation between integral and modular points is natural and holds for every modulus.

**Theorem 5.1 (global solutions reduce locally).** Let $n$ be a positive integer. If $k$ is globally representable, then $k$ is locally representable modulo $n$.

**Proof sketch.** Given integers $x,y,z$ with $x^3+y^3+z^3=k$, apply the reduction map $\mathbb Z\to\mathbb Z/n\mathbb Z$ to both sides. Since reduction respects addition and multiplication, it respects cubing and gives the desired congruence. $\square$

This theorem supplies an unlimited family of necessary tests: failure modulo even one modulus proves global nonrepresentability. It does not supply a converse. Solutions modulo separate moduli are finite shadows; they need not arise from one common integral triple.

**Theorem 5.2 (integral-point interpretation).** For every integer $k$, the following are equivalent:

1. There exist integers $x,y,z$ satisfying $x^3+y^3+z^3=k$.
2. The affine cubic surface $S_k(\mathbb Z)$ is nonempty.

**Proof sketch.** By Definition 2.4, an element of $S_k(\mathbb Z)$ is exactly an integer triple satisfying the required equation. Thus the two statements unpack to the same existence assertion. $\square$

Although tautological at the level of sets, the surface interpretation changes the available viewpoint. One may compare $S_k(\mathbb Z)$ with rational points $S_k(\mathbb Q)$, real points $S_k(\mathbb R)$, and finite-ring points $S_k(\mathbb Z/n\mathbb Z)$. The global-to-local map sends an integral point to a compatible family of residue points.

The **Hasse principle** is the general expectation, valid for some classes of equations and invalid for others, that suitable local solvability conditions should imply global solvability. In the present setting, Theorem 5.1 proves only the easy direction. The exact modulo-nine classification says precisely what happens over $\mathbb Z/9\mathbb Z$; it neither establishes local solvability at every modulus nor converts local points into integral ones.

## 6. Symmetry and parametric integral points

### 6.1. Sign symmetry

Because cubing is odd, representability is invariant under changing the sign of the target.

**Theorem 6.1 (sign symmetry).** For every integer $k$, the integer $k$ is globally representable if and only if $-k$ is globally representable.

**Proof sketch.** If

$$
x^3+y^3+z^3=k,
$$

then

$$
(-x)^3+(-y)^3+(-z)^3=-k.
$$

Applying the same operation again proves the reverse implication. $\square$

This symmetry pairs positive and negative targets and preserves the absolute values of the coordinates.

### 6.2. The Vieta-type identity

A broad source of integral points appears when the coordinate sum is constrained to vanish.

**Theorem 6.2 (two-parameter cubic identity).** For all integers $a,b$,

$$
a^3+b^3+(-a-b)^3=-3ab(a+b).
$$

**Proof sketch.** Expand the third cube:

$$
(-a-b)^3=-(a+b)^3=-a^3-3a^2b-3ab^2-b^3.
$$

After adding $a^3+b^3$, the pure cubic terms cancel and the remainder factors as

$$
-3a^2b-3ab^2=-3ab(a+b).
$$

$\square$

**Corollary 6.3 (two-parameter represented family).** For every pair of integers $a,b$, the target

$$
-3ab(a+b)
$$

is globally representable, with representing triple

$$
(a,b,-a-b).
$$

**Proof sketch.** Substitute the displayed triple into Theorem 6.2. $\square$

The family is polynomial and immediately computable. It may contain repetitions: distinct pairs $(a,b)$ can produce the same target or triples related by permutation. No injectivity is asserted. Its role is to certify a large structured set of global points.

### 6.3. A nondegenerate one-parameter family

Setting $a=2t$ and $b=-t$ makes the third coordinate $-t$.

**Theorem 6.4 (nonzero representations of $6t^3$).** For every nonzero integer $t$, there exist nonzero integers $x,y,z$ satisfying

$$
x^3+y^3+z^3=6t^3.
$$

One may take

$$
(x,y,z)=(2t,-t,-t).
$$

**Proof sketch.** If $t\ne 0$, all three coordinates are nonzero. Direct calculation gives

$$
(2t)^3+(-t)^3+(-t)^3=8t^3-t^3-t^3=6t^3.
$$

$\square$

This theorem excludes the possibility that the family is generated merely by appending a zero cube to a two-cube identity. It also illustrates cubic scaling: a single representation of $6$ scales by $t$ in the coordinates and by $t^3$ in the target.

## 7. Algorithms and numerical exploration

### 7.1. Constant-time modulo-nine classifier

The exact local theorem yields an optimal decision procedure for solvability modulo nine.

**Algorithm 7.1 (exact local classification).** Given an integer $k$:

1. Compute the least nonnegative remainder $r=k\bmod 9$.
2. If $r\in\{4,5\}$, report that no solution exists modulo nine.
3. Otherwise return the witness from the table in Theorem 4.1.

Under a unit-cost integer-arithmetic model, the procedure takes constant time and constant storage. In bit complexity, computing the remainder takes time quasi-linear or linear in the bit length under standard implementations, while table lookup is constant. The output coordinates are drawn from $\{-1,0,1\}$.

Correctness has two parts. Lemma 3.2 proves that the negative answers are sound. The witness table proves that every positive answer is sound and complete.

### 7.2. Bounded search for integral representations

For exploratory computation, fix a height bound $B\ge 0$ and search for triples with

$$
|x|,|y|,|z|\le B.
$$

A direct triple loop uses $O(B^3)$ arithmetic operations. A meet-in-the-middle method precomputes the pair sums

$$
x^3+y^3
$$

for $-B\le x,y\le B$ and stores one witness for each value. It then scans $z$ and tests whether $k-z^3$ occurs in the table. This requires $O(B^2)$ stored entries, expected $O(B^2)$ time with hashing, and $O(B^2)$ memory.

The method is complete only within the selected box. If it returns a triple, direct substitution certifies a genuine representation. If it returns no triple, the conclusion is only that no representation exists with all coordinates bounded by $B$. Because cancellation can force very large coordinates, this is not a global nonexistence proof.

### 7.3. Generating polynomial families

For bounded parameters $|a|,|b|\le A$, one can enumerate

$$
k=-3ab(a+b)
$$

and attach the certificate $(a,b,-a-b)$. This takes $O(A^2)$ evaluations and at most $O(A^2)$ storage if duplicate targets are consolidated. Every output is globally valid by Theorem 6.2. Unlike bounded target search, family generation is constructive by design and never produces a false candidate.

## 8. Examples

The local classifier immediately gives:

- $k=4$ and $k=5$ are impossible globally because they are forbidden modulo nine.
- $k=13$ is impossible because $13\equiv 4\pmod 9$.
- $k=-4$ is impossible because $-4\equiv 5\pmod 9$, consistent with sign symmetry.
- $k=3$ is locally represented modulo nine by $(1,1,1)$.
- $k=7$ is locally represented modulo nine by $(-1,-1,0)$ because $-2\equiv 7\pmod 9$.

The polynomial family gives, for $a=2$ and $b=-1$,

$$
2^3+(-1)^3+(-1)^3=8-1-1=6.
$$

Scaling by $t=3$ yields

$$
6^3+(-3)^3+(-3)^3=216-27-27=162=6\cdot 3^3.
$$

For a different two-parameter example, take $a=4$ and $b=2$. Then

$$
4^3+2^3+(-6)^3=64+8-216=-144,
$$

while

$$
-3\cdot 4\cdot 2\cdot(4+2)=-144.
$$

Changing all signs gives a representation of $144$:

$$
(-4)^3+(-2)^3+6^3=144.
$$

These examples exhibit the three main mechanisms: modular exclusion, explicit local witnessing, and global construction by identity.

## 9. Discussion

Modulo nine is distinguished because cubing compresses nine input classes into the three values $0$, $1$, and $-1$. The threefold sumset is then the seven-element interval of residues represented by ordinary sums from $-3$ through $3$. This explains both the obstruction and its exactness with almost no computation.

The global conclusions divide into negative and positive statements. Negatively, two infinite arithmetic progressions contain no represented targets. Positively, the two-parameter identity supplies infinitely many represented values, and the $6t^3$ specialization ensures three nonzero coordinates. Sign symmetry doubles every construction away from zero.

What remains unresolved by these results is equally important. Modulo-nine admissibility is necessary for an integer solution but is not here proved sufficient. The local theorem concerns one finite ring. Even proving solvability modulo every positive integer would still require a distinct argument to infer an integral point, if such an inference were valid. Accordingly, conjectural density statements about globally represented integers must be kept separate from the exact $7/9$ local proportion.

The cubic-surface language provides a disciplined hierarchy:

$$
S_k(\mathbb Z)\longrightarrow S_k(\mathbb Z/n\mathbb Z)
$$

for every $n$. One may also consider $S_k(\mathbb Q)$ and $S_k(\mathbb R)$, or compatible points over prime-power rings. Questions about failures of converse maps belong to the arithmetic geometry of the surface, not merely to finite enumeration.

## 10. Future work

Several directions naturally extend the established framework.

First, one may classify and count solutions over $\mathbb Z/p^r\mathbb Z$ for prime powers, including compatibility under reduction from $p^{r+1}$ to $p^r$. Such counts would turn qualitative local existence into local-density factors.

Second, one may investigate whether modulo-nine admissibility implies solvability modulo every positive integer. A natural route separates prime powers and then combines solutions using the Chinese remainder theorem.

Third, bounded searches can be equipped with independently checkable identity certificates for difficult targets. A certificate proves the displayed representation, while the search process that found it need not be part of the mathematical argument.

Fourth, one may define counting functions for admissible and globally represented targets in intervals. The local proportion $7/9$ is a rigorous baseline; a claim that all admissible integers are globally represented would be a substantially stronger conjecture.

Fifth, the affine sets $S_k(R)$ can be developed as polynomial zero loci and studied for smoothness, rational points, integral points, real points, and finite-ring points in a uniform language.

Sixth, a refined local-global interface should distinguish integral, rational, real, and all-prime local solvability. This distinction is essential when discussing any Hasse-principle phenomenon.

Finally, the identity $a^3+b^3+(-a-b)^3=-3ab(a+b)$ invites the construction of injective subfamilies. Controlling collisions among parameter pairs could yield quantitative lower bounds for the number of distinct represented integers without introducing zero coordinates.

## 11. Conclusion

The equation $x^3+y^3+z^3=k$ has a complete and transparent local theory modulo nine. Every cube is $0$, $1$, or $-1$ modulo nine; therefore sums of three cubes avoid $4$ and $5$; and explicit triples show that all seven remaining classes occur. This proves the exact modulo-nine criterion and excludes the progressions $9t+4$ and $9t+5$ globally.

Integral points reduce to modular points for every modulus, and global representability is precisely the existence of an integral point on the affine cubic surface $S_k$. The equation is symmetric under $k\mapsto -k$, while the identity

$$
a^3+b^3+(-a-b)^3=-3ab(a+b)
$$

provides a two-parameter family of integral points. Its specialization

$$
6t^3=(2t)^3+(-t)^3+(-t)^3
$$

uses three nonzero coordinates whenever $t\ne 0$.

Together, these results draw a sharp boundary. The modulo-nine obstruction is exact locally and supplies unconditional global exclusions. Polynomial identities supply unconditional global constructions. Between them lies the local-to-global problem: determining when a finite shadow is cast by an actual integral point.