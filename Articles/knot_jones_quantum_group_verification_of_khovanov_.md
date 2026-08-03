# From Circles to Polynomials: The State-Sum Heart of Khovanov Categorification

## A knot’s two mathematical lives

A knot diagram looks like a picture, but its crossings conceal a vast combinatorial machine. At each crossing one may make either of two local replacements, called the $A$-smoothing and the $B$-smoothing. Once every crossing has been smoothed, the tangled picture dissolves into a collection of disjoint circles. A diagram with $n$ crossings therefore opens into a cube of $2^n$ smoothing states.

This cube is the meeting place of two theories. The Jones polynomial packages the smoothing states into a Laurent polynomial, an expression involving positive and negative powers of a variable $q$. Khovanov’s construction enriches each state into a collection of graded generators and ultimately organizes those generators into homological algebra. The crucial bridge between the two is a finite counting identity: when the enriched generators are counted with the correct signs and powers of $q$, all their extra structure collapses exactly to the Jones state sum.

That bridge is the subject of this article. The result applies to every finite combinatorial link diagram, and after a writhe shift it applies to every oriented diagram in the corresponding normalization. Its proof rests on a deceptively simple observation: every circle has two labels, of degrees $+1$ and $-1$, so one circle contributes $q+q^{-1}$ and $m$ independent circles contribute $(q+q^{-1})^m$.

The simplicity is the point. Categorification can appear mysterious because it replaces a polynomial by graded algebraic objects. Here one can see the mechanism in reverse, one circle at a time.

## The cube of smoothings

Fix a link diagram $D$ with $n$ ordered crossings. A **smoothing state** $s$ chooses $A$ or $B$ at every crossing. Write $a(s)$ for the number of $A$-choices, $b(s)$ for the number of $B$-choices, and $\ell(s)$ for the number of circles remaining after all crossings are smoothed. Since every crossing receives exactly one choice,

$$
a(s)+b(s)=n.
$$

The Jones state sum considered here is

$$
J_D(q)=\sum_s (-1)^{b(s)}q^{a(s)-b(s)}(q+q^{-1})^{\ell(s)},
$$

where the sum runs over all $2^n$ smoothing states. This is a Laurent polynomial with integer coefficients. It is the normalization naturally produced by the cube construction: the sign records the parity of the number of $B$-smoothings, the monomial $q^{a(s)-b(s)}$ records the smoothing shift, and each resulting circle contributes the factor $q+q^{-1}$.

Why should a circle contribute precisely that factor? The enriched picture supplies the answer.

## Giving every circle a binary label

For a smoothing state $s$, assign to each of its $\ell(s)$ circles one of two labels, which we call $+$ and $-$. An **enhanced state** is a pair $(s,e)$ consisting of a smoothing state and this complete labeling. If there are $m$ circles, there are $2^m$ enhancements.

Give the label $+$ quantum degree $+1$ and the label $-$ quantum degree $-1$. The enhancement degree is

$$
\delta(e)=\sum_{C\text{ a circle of }s}
\begin{cases}
1,&e(C)=+,\\
-1,&e(C)=-.
\end{cases}
$$

The enhanced state has homological degree

$$
i(s,e)=b(s)
$$

and quantum degree

$$
j(s,e)=a(s)-b(s)+\delta(e).
$$

These definitions lead to the **graded Euler sum of the cube generators**:

$$
\chi_q(D)=\sum_{(s,e)}(-1)^{i(s,e)}q^{j(s,e)}.
$$

The terminology “Euler” reflects the alternating sign $(-1)^i$, while “graded” reflects the weight $q^j$. This sum concerns the generators attached to the cube. It is the finite decategorification calculation that underlies the later passage to chain groups and homology.

## The two-label miracle

The central counting statement can be understood without knots.

**Binary Enhancement Theorem.** For $m\ge 0$ independent circles, each labeled either $+$ with degree $+1$ or $-$ with degree $-1$,

$$
\sum_e q^{\delta(e)}=(q+q^{-1})^m,
$$

where the sum runs over all $2^m$ labelings.

There are two complementary ways to see it. The direct way is the distributive law. Expanding $(q+q^{-1})^m$ asks us to choose one term from each of $m$ factors. Choosing $q$ labels that circle $+$; choosing $q^{-1}$ labels it $-$. The product of the choices is $q^{\delta(e)}$, and every labeling appears once.

The inductive way exposes the recursive structure. For no circles, the only empty labeling has degree $0$, so both sides equal $1$. For $m+1$ circles, separate the first circle from the remaining $m$. Its label contributes either $q$ or $q^{-1}$, hence

$$
\sum_e q^{\delta(e)}
=(q+q^{-1})\sum_{e'}q^{\delta(e')}
=(q+q^{-1})^{m+1}.
$$

A useful refinement is obtained by grouping labelings according to how many circles receive $+$. If exactly $r$ of the $m$ circles are positive, then the degree is $2r-m$, and there are $\binom mr$ such labelings. Thus

$$
(q+q^{-1})^m=\sum_{r=0}^m \binom mr q^{2r-m}.
$$

This formula turns the algebra into a visible histogram: the coefficients form a binomial distribution, while the exponents march from $-m$ to $m$ in steps of two.

## The main identity

We can now state the bridge in full.

**Graded Euler–Jones State-Sum Theorem.** For every finite combinatorial link diagram $D$,

$$
\chi_q(D)=J_D(q).
$$

**Proof sketch.** Begin with the sum over all enhanced states and group it by the underlying smoothing state $s$:

$$
\chi_q(D)
=\sum_s\sum_e (-1)^{b(s)}q^{a(s)-b(s)+\delta(e)}.
$$

For fixed $s$, the sign and smoothing shift do not depend on the labels, so they factor out:

$$
\chi_q(D)
=\sum_s(-1)^{b(s)}q^{a(s)-b(s)}
\left(\sum_e q^{\delta(e)}\right).
$$

The state $s$ has $\ell(s)$ circles. Applying the Binary Enhancement Theorem gives

$$
\chi_q(D)
=\sum_s(-1)^{b(s)}q^{a(s)-b(s)}
(q+q^{-1})^{\ell(s)}
=J_D(q).
$$

Nothing is discarded and no cancellation is hidden: the equality follows state by state. Each block of $2^{\ell(s)}$ enhanced generators is compressed into one factor $(q+q^{-1})^{\ell(s)}$.

## Orientation and writhe

An oriented crossing is positive or negative according to the usual right-hand convention. The **writhe** $w(D)$ is the number of positive crossings minus the number of negative crossings. In the normalization used here, orientation contributes a global shift by $q^{-3w(D)}$.

Define

$$
\widetilde{\chi}_q(D)=q^{-3w(D)}\chi_q(D)
$$

and

$$
\widetilde J_D(q)=q^{-3w(D)}J_D(q).
$$

**Oriented Graded Euler–Jones Theorem.** For every oriented combinatorial link diagram $D$,

$$
\widetilde{\chi}_q(D)=\widetilde J_D(q).
$$

The proof is immediate but meaningful: multiply the unoriented identity by the same writhe monomial on both sides. The theorem isolates two roles that are often mixed together. Binary enhancements explain the quantum factor within each smoothing, while writhe controls the overall orientation-dependent grading shift.

## The unknot as the atomic example

Consider the crossingless unknot. It has one smoothing state, no $B$-smoothings, no smoothing shift, and one circle. Its two enhancements have quantum degrees $+1$ and $-1$. Therefore

$$
\chi_q(\bigcirc)=q+q^{-1}.
$$

The same result follows from the state sum: the single circle contributes $q+q^{-1}$. This is more than a consistency check. The unknot displays the local “quantum dimension” from which every higher-circle contribution is built.

For two circles, the four labels have degrees $2,0,0,-2$, producing

$$
q^2+2+q^{-2}=(q+q^{-1})^2.
$$

For three circles, the eight labels produce

$$
q^3+3q+3q^{-1}+q^{-3}=(q+q^{-1})^3.
$$

The coefficients count generators of equal quantum degree. In this way a Laurent polynomial becomes a compressed census of a graded population.

## Why this bridge matters

The Jones polynomial is a shadow: it records signed graded counts but forgets the internal maps between generators. Khovanov’s idea is to retain enough structure to form chain groups and a differential, then take homology. The state-sum identity explains why the shadow has exactly the Jones shape. If the differential preserves quantum grading and raises homological degree by one, paired generators cancel in the alternating Euler count, leaving the same Laurent polynomial at the level of homology.

That later homological step requires additional ingredients: signed edge maps in the smoothing cube, a proof that the differential squares to zero, and an argument that homology preserves the graded Euler characteristic. Invariance under changes of diagram further requires chain maps and homotopies associated with the three Reidemeister moves. The finite theorem proved here is the combinatorial core on which those developments rest; it should not be confused with all of them at once.

The identity also suggests an algorithm. Enumerate each smoothing state, determine $a(s)$, $b(s)$, and $\ell(s)$, then add

$$
(-1)^{b(s)}q^{a(s)-b(s)}(q+q^{-1})^{\ell(s)}.
$$

This compressed method avoids enumerating every enhancement separately. If a state has many circles, the saving can be dramatic: one symbolic binomial expansion replaces $2^{\ell(s)}$ labelings. Both procedures compute the same polynomial, so comparing them offers a direct numerical demonstration of the theorem.

## A small identity with a large view

At first sight, the formula $(q+q^{-1})^m$ is elementary. Yet it performs the essential act of decategorification: it turns a family of graded generators into a polynomial weight. The smoothing cube contributes the signs and shifts; the circles contribute a rank-two graded choice; distributivity assembles the Jones state sum.

The resulting picture is unusually clear. A crossing becomes a binary smoothing decision. A smoothing becomes circles. A circle becomes two degrees. Degrees become Laurent monomials. Their signed sum becomes the Jones state sum. Orientation adds a writhe shift. Each stage has its own role, and the full identity follows by composing them.

That is the enduring lesson of the construction: a knot polynomial need not be treated as an isolated formula. It can be read as the visible trace of a richer graded world, with every coefficient counting something and every exponent carrying geometric information.
The same principle reaches beyond knot theory. Whenever independent local choices carry additive degrees, their generating functions multiply. Statistical mechanics calls this a partition-function calculation; representation theory interprets $q+q^{-1}$ as a graded dimension; topology uses the result to pass from structured objects to invariants. Here these viewpoints meet in one exact identity, showing how local binary data can encode global geometry.
