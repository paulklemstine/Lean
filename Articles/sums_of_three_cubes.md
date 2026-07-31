# The Two Locked Doors in the Hall of Three Cubes

## A simple equation with a hidden arithmetic map

Take an integer, any integer, and ask whether it can be assembled from three perfect cubes:

$$
x^3+y^3+z^3=k,
$$

where $x$, $y$, and $z$ may be positive, negative, or zero. The question looks like a close cousin of familiar school exercises. Yet allowing negative numbers turns it into a vast search through a three-dimensional lattice, and cubic growth makes that search deceptive. A small target can arise from enormous cubes that almost cancel. For example, there is no reason that a solution for a modest $k$ must use modest values of $x$, $y$, and $z$.

Before searching this infinite landscape, arithmetic offers a lantern: look at the equation through a finite clock. On a clock with nine positions, almost every integer cube collapses to one of only three marks. That small observation identifies two doors that no sum of three cubes can ever open, completely classifies the equation modulo nine, and separates what is known from the much deeper global question over the integers.

This is a story about local information: what an equation looks like after only remainders are retained. Local information cannot always construct an integer solution, but it can expose impossibility instantly. Here it does so with unusual sharpness.

## The nine-position clock

For an integer $m$, its residue modulo nine is the remainder in $\{0,1,2,3,4,5,6,7,8\}$. Two integers occupy the same position on the nine-position clock when their difference is divisible by $9$.

The key lemma is elementary but decisive.

**Cube-Residue Lemma.** For every integer $x$, the cube $x^3$ is congruent modulo nine to exactly one of $0$, $1$, or $-1$. In the standard nonnegative residue notation, these are $0$, $1$, and $8$.

To see why, it is enough to cube the nine possible remainders. The pattern is

$$
0^3\equiv 3^3\equiv 6^3\equiv 0\pmod 9,
$$

$$
1^3\equiv 4^3\equiv 7^3\equiv 1\pmod 9,
$$

and

$$
2^3\equiv 5^3\equiv 8^3\equiv -1\pmod 9.
$$

Thus each variable in the equation contributes only $-1$, $0$, or $1$ on this clock. Adding three such contributions gives an ordinary sum between $-3$ and $3$. Modulo nine, the possible target residues are therefore

$$
-3,-2,-1,0,1,2,3,
$$

or, written from $0$ to $8$,

$$
0,1,2,3,6,7,8.
$$

The missing residues are $4$ and $5$.

**Three-Cube Obstruction Theorem.** If an integer $k$ has a representation $k=x^3+y^3+z^3$ with integers $x,y,z$, then $k$ is not congruent to $4$ or $5$ modulo nine.

The proof simply reduces a claimed equality modulo nine and applies the Cube-Residue Lemma. Three entries chosen from $\{-1,0,1\}$ cannot total $4$ or $5$ on the nine-position clock.

This immediately rules out two infinite arithmetic progressions.

**Forbidden-Progressions Corollary.** For every integer $t$, neither $9t+4$ nor $9t+5$ is a sum of three integer cubes.

So $4,5,13,14,22,23$ and infinitely many others are impossible—not because a search has failed to find them, but because arithmetic proves no search can succeed.

## Exactness: all seven other doors open locally

An obstruction is especially satisfying when it is exact. Modulo nine, the two missing residues are the only missing residues.

Define a target $k$ to be **locally representable modulo $n$** when there exist residue classes $x,y,z$ modulo $n$ satisfying

$$
x^3+y^3+z^3\equiv k\pmod n.
$$

**Exact Modulo-Nine Theorem.** A target $k$ is locally representable modulo nine if and only if $k$ is not congruent to $4$ or $5$ modulo nine.

One direction is the obstruction already proved. The converse has explicit witnesses. For residues $0,1,2,3$, use respectively

$$
(0,0,0),\quad (1,0,0),\quad (1,1,0),\quad (1,1,1).
$$

For residues $6,7,8$, use

$$
(-1,-1,-1),\quad (-1,-1,0),\quad (-1,0,0).
$$

Cubing does not change $0$, $1$, or $-1$, so these triples deliver all seven admissible residues. This proof does more than certify existence: it supplies a tiny lookup table that constructs a modular solution at once.

Among the nine residue classes, exactly seven pass this test. In a long interval, therefore, the modulo-nine admissible targets occupy an asymptotic proportion of $7/9$. This is a local density, not a theorem that $7/9$ of all integers have integer representations. It is the baseline population left after the first unavoidable filter.

## Local shadows and global objects

Every genuine integer solution casts a shadow modulo every positive modulus.

**Global-to-Local Principle.** If $x^3+y^3+z^3=k$ holds in integers, then for every positive integer $n$, the residues of $x,y,z$ modulo $n$ solve the same equation modulo $n$.

The proof is reduction of the integer equality modulo $n$. Addition and multiplication respect congruence, so cubes and their sum do as well.

The reverse direction is where mystery lives. Passing every finite congruence test does not automatically provide one triple of integers. Local witnesses for different moduli may fail to assemble into a global witness, and even compatible local information may not control the size of integer coordinates. The exact modulo-nine theorem must therefore be read carefully: it completely settles solvability on the nine-position clock, but it does not claim that every admissible integer is globally representable.

This distinction echoes the **Hasse principle**, a guiding question in number theory: when does solvability over all relevant local worlds force solvability in the global one? For sums of three cubes, the easy implication runs from integer solutions to modular solutions. Any converse requires substantially more information and remains outside the results established here.

## Turning the equation into a surface

The equation has a geometric life. For a fixed target $k$, consider the affine cubic surface

$$
S_k=\{(x,y,z):x^3+y^3+z^3=k\}.
$$

The ambient number system can be the integers, rational numbers, real numbers, or a finite ring of residues. Over the integers, asking whether $k$ is a sum of three cubes is exactly asking whether $S_k$ contains an integral point.

**Surface Interpretation Theorem.** An integer $k$ is representable as a sum of three integer cubes if and only if the cubic surface $S_k$ has at least one integral point.

This equivalence follows directly from the definition of $S_k$: an integral point is precisely a triple of integers satisfying the equation. Although logically simple, the translation is conceptually powerful. A Diophantine equation becomes a family of geometric objects, one surface for every $k$. Reduction modulo nine asks whether the corresponding finite surface has a point. Searching over the integers asks for lattice points on the full surface.

Geometry also makes cancellation visible. Far from the origin, the three cubic terms may be huge while their sum remains fixed. The surface can thread through distant regions of the lattice, explaining why bounded searches may miss genuine solutions.

## Mirrors and families

Odd powers respect signs, giving the family a perfect mirror symmetry.

**Sign-Symmetry Theorem.** An integer $k$ is a sum of three integer cubes if and only if $-k$ is.

Indeed, if $x^3+y^3+z^3=k$, then

$$
(-x)^3+(-y)^3+(-z)^3=-k.
$$

Thus every solution generates a reflected solution, and investigations may often pair positive and negative targets.

There is also a broad, explicit source of global solutions. Set the third coordinate equal to the negative sum of the first two. Expanding gives the classical identity

$$
a^3+b^3+(-a-b)^3=-3ab(a+b).
$$

**Two-Parameter Family Theorem.** For every pair of integers $a,b$, the integer $-3ab(a+b)$ is a sum of three integer cubes, represented by the triple $(a,b,-a-b)$.

The proof is a direct expansion:

$$
(-a-b)^3=-a^3-3a^2b-3ab^2-b^3,
$$

so the pure cubes cancel and leave $-3ab(a+b)$.

A particularly clean specialization takes $a=2t$ and $b=-t$. Then the third coordinate is also $-t$, and

$$
(2t)^3+(-t)^3+(-t)^3=8t^3-t^3-t^3=6t^3.
$$

**Nonzero $6t^3$ Family Theorem.** For every nonzero integer $t$, the target $6t^3$ has a representation by three nonzero cubes, namely

$$
6t^3=(2t)^3+(-t)^3+(-t)^3.
$$

The nonzero condition matters: it excludes padded identities that use a zero cube and exhibits genuine three-term cancellation. As $t$ varies, this creates infinitely many integral points on infinitely many members of the cubic-surface family.

## What the map tells us—and what it does not

The modulo-nine map is complete at its own scale. Cubes occupy three residue classes; sums of three cubes occupy seven; residues $4$ and $5$ are impossible; and every other residue has an explicit modular witness. Globally, the consequences are rigorous and immediate: two full arithmetic progressions are excluded, every integral solution survives every modular reduction, sign reflection preserves representability, and polynomial identities generate infinite represented families.

But the great gap remains between an unlocked local door and an actual integer point. A modular triple is a shadow, not necessarily the object casting it. Closing that gap invites several kinds of work: classification and counting modulo prime powers, Chinese-remainder assembly, carefully certified bounded searches, quantitative study of represented targets, and geometric analysis of the surfaces $S_k$.

Numerical experiments can make this map tangible. One can enumerate all nine input residues, verify that their cubes collapse to $0$, $1$, and $8$, and then form all $27$ sums of three cube residues. Such a finite experiment reproduces the seven admissible targets exactly. A second experiment can sample parameters $a$ and $b$ in the polynomial identity, plotting the represented targets and the coordinate sizes. These computations illustrate the theorems, while the residue argument and algebraic expansion explain why the observed patterns persist beyond every finite sample.

The equation $x^3+y^3+z^3=k$ thus compresses a central theme of number theory into one line. Finite arithmetic can prove impossibility with striking economy. Algebraic identities can build infinite islands of certainty. Geometry explains why the global ocean between those islands is difficult to navigate. And on the nine-position clock, two doors remain locked forever while the other seven open onto a much larger world.