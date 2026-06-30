# The Modular Obstruction for Sums of Three Cubes: A Complete Local Characterization and the Density Conjecture

## Abstract

We study the classical Diophantine problem of representing an integer $n$ as a sum of three integer cubes, $x^3 + y^3 + z^3 = n$, where $x, y, z \in \mathbb{Z}$ are unrestricted in sign. We give a complete and rigorous treatment of the only known local obstruction to such representations: an integer congruent to $4$ or $5$ modulo $9$ admits no representation as a sum of three cubes. We prove this from first principles by establishing that every integer cube lies in the set $\{0,1,8\}$ modulo $9$ and that no sum of three such residues equals $4$ or $5$ modulo $9$. We then situate this obstruction within the broader conjectural framework of Heath-Brown, which asserts that congruence to $4$ or $5$ modulo $9$ is the *only* obstruction — that every other integer is a sum of three cubes. We make explicit the logical structure of the resulting characterization, isolating precisely which direction is a theorem (the obstruction) and which remains an open conjecture (the density/sufficiency statement). We connect the problem to the geometry of cubic surfaces, the symmetry $n \mapsto -n$, the existence of one-parameter polynomial families of representations, and the Hasse principle. We supplement the theory with explicit witnesses for all small representable residue classes and with numerical demonstrations.

**Keywords.** sums of three cubes, Diophantine equations, local obstruction, modular arithmetic, cubic surfaces, Heath-Brown conjecture, Hasse principle, density of representations.

## 1. Introduction

The equation
$$
x^3 + y^3 + z^3 = n, \qquad x, y, z \in \mathbb{Z},
$$
asks for which integers $n$ there exists a representation as a sum of three (signed) integer cubes. Because cubes may be negative, the search space is unbounded in every direction: a single integer $n$ may require representations in which all three coordinates are enormous and nearly cancel. For example,
$$
30 = 2{,}220{,}422{,}932^3 + (-2{,}218{,}888{,}517)^3 + (-283{,}059{,}965)^3,
$$
and the resolution of $33$ and $42$ required distributed computations producing sixteen- and seventeen-digit coordinates respectively. This combination of an elementary statement with extreme computational depth makes the three-cube problem a touchstone of modern Diophantine number theory.

The problem decomposes naturally into two parts of completely different logical status:

1. **Obstruction (local non-representability).** Certain integers are provably *not* sums of three cubes for a simple congruence reason. This part is entirely settled.
2. **Sufficiency (density).** All remaining integers *are* sums of three cubes. This is the open conjecture of Heath-Brown.

This paper gives a self-contained, rigorous account of the obstruction, and a careful logical analysis of how it combines with the sufficiency conjecture into a clean (partly conjectural) characterization. Throughout, we are explicit about which statements are proven and which are conjectural.

### 1.1 Notation and definitions

We write $\mathbb{Z}$ for the integers and $\mathbb{Z}/9\mathbb{Z}$ for the ring of residues modulo $9$. For $a \in \mathbb{Z}$ we write $\bar a$ for its image in $\mathbb{Z}/9\mathbb{Z}$.

**Definition 1 (Sum of three cubes).** An integer $n$ is a *sum of three cubes* if there exist integers $x, y, z$ with
$$
x^3 + y^3 + z^3 = n.
$$
We denote this property by $S(n)$.

## 2. The cubic residues modulo nine

The entire obstruction rests on a single elementary fact.

**Lemma 1 (Cubic residues mod 9).** For every integer $x$,
$$
\overline{x^3} \in \{\,\bar 0, \bar 1, \bar 8\,\} \subseteq \mathbb{Z}/9\mathbb{Z}.
$$

*Proof.* The value of $\overline{x^3}$ depends only on $\bar x \in \mathbb{Z}/9\mathbb{Z}$, so it suffices to check the nine residues. Writing each residue as $x$ and computing $x \cdot (x \cdot x)$ in $\mathbb{Z}/9\mathbb{Z}$:
$$
\begin{aligned}
0^3 &\equiv 0, & 1^3 &\equiv 1, & 2^3 = 8 &\equiv 8,\\
3^3 = 27 &\equiv 0, & 4^3 = 64 &\equiv 1, & 5^3 = 125 &\equiv 8,\\
6^3 = 216 &\equiv 0, & 7^3 = 343 &\equiv 1, & 8^3 = 512 &\equiv 8.
\end{aligned}
$$
In every case the result lies in $\{0,1,8\}$. $\qquad\blacksquare$

Note the clean structure: residues $\equiv 0 \pmod 3$ cube to $0$, residues $\equiv 1 \pmod 3$ cube to $1$, and residues $\equiv 2 \pmod 3$ cube to $8 \equiv -1$. Thus modulo $9$ a cube records only the residue of its base modulo $3$, mapped to $\{0, 1, -1\}$.

## 3. The modular obstruction

**Lemma 2 (No triple sum hits 4 or 5).** For all $a, b, c \in \{\bar 0, \bar 1, \bar 8\} \subseteq \mathbb{Z}/9\mathbb{Z}$,
$$
a + b + c \neq \bar 4 \quad\text{and}\quad a + b + c \neq \bar 5.
$$

*Proof.* This is a finite check over the $3^3 = 27$ ordered triples (equivalently, $9^3 = 729$ if one ranges over all residues and restricts). Identifying $\bar 8$ with $-\bar 1$, the achievable sums are exactly the values $i \cdot 1 + j\cdot(-1)$ with $i + j \le 3$ together with contributions of $0$, namely
$$
\{-3,-2,-1,0,1,2,3\} \pmod 9 = \{\bar 0,\bar 1,\bar 2,\bar 3,\bar 6,\bar 7,\bar 8\}.
$$
Neither $\bar 4$ nor $\bar 5$ appears. $\qquad\blacksquare$

**Theorem 3 (Modular obstruction).** If $\bar n = \bar 4$ or $\bar n = \bar 5$ in $\mathbb{Z}/9\mathbb{Z}$, then $n$ is not a sum of three cubes; that is, $\neg S(n)$.

*Proof.* Suppose, for contradiction, that $x^3 + y^3 + z^3 = n$. Reducing modulo $9$ gives $\overline{x^3} + \overline{y^3} + \overline{z^3} = \bar n$. By Lemma 1 each summand lies in $\{\bar 0, \bar 1, \bar 8\}$, so by Lemma 2 the sum cannot equal $\bar 4$ or $\bar 5$, contradicting $\bar n \in \{\bar 4, \bar 5\}$. $\qquad\blacksquare$

Theorem 3 eliminates the two arithmetic progressions
$$
\{\dots, 4, 13, 22, 31, \dots\} \quad\text{and}\quad \{\dots, 5, 14, 23, 32, \dots\},
$$
i.e. all $n \equiv \pm 4 \pmod 9$. These integers are unconditionally and forever excluded.

## 4. Symmetry

**Proposition 4 (Negation symmetry).** For every integer $n$, $S(n)$ holds if and only if $S(-n)$ holds.

*Proof.* If $x^3 + y^3 + z^3 = n$, then $(-x)^3 + (-y)^3 + (-z)^3 = -n$, and conversely. $\qquad\blacksquare$

This reflects the central symmetry of the cubic surface $x^3+y^3+z^3 = n$ under $(x,y,z) \mapsto (-x,-y,-z)$ and is consistent with the obstruction: the excluded classes $\bar 4$ and $\bar 5 = -\bar 4$ are themselves swapped by negation.

## 5. Explicit witnesses for representable residue classes

The residues modulo $9$ that are *not* excluded are $\{0,1,2,3,6,7,8\}$. Each is realized by a small explicit representation, demonstrating that the obstruction of Theorem 3 is the only one visible at the level of residues modulo $9$.

**Proposition 5 (Small witnesses).** The following representations hold:
$$
\begin{aligned}
0 &= 0^3 + 0^3 + 0^3, & 1 &= 1^3 + 0^3 + 0^3, & 2 &= 1^3 + 1^3 + 0^3,\\
3 &= 1^3 + 1^3 + 1^3, & 6 &= 2^3 + (-1)^3 + (-1)^3, & 7 &= 2^3 + 0^3 + (-1)^3,\\
8 &= 2^3 + 0^3 + 0^3. &&&&
\end{aligned}
$$

*Proof.* Direct computation. $\qquad\blacksquare$

These cover all seven admissible residue classes modulo $9$ (since $0,1,2,3,6,7,8$ are representatives of every class except $4,5$), confirming that no residue class outside $\{4,5\}$ is locally obstructed.

## 6. The characterization theorem and the Heath-Brown conjecture

We now combine the proven obstruction with the open sufficiency statement.

**Conjecture 6 (Heath-Brown sufficiency).** Every integer $n$ with $\bar n \notin \{\bar 4, \bar 5\}$ is a sum of three cubes.

This is one of the central open problems concerning the three-cube equation. It is *not* reducible to a finite computation: each admissible residue class modulo $9$ contains infinitely many integers (for example $0, 9, 18, 27, \dots$ all lie in the class of $\bar 0$), and these may require genuinely different and arbitrarily large representations. No finite list of witnesses can certify the entire conjecture.

**Theorem 7 (Complete characterization, one direction conjectural).** For every integer $n$,
$$
\neg S(n) \iff \bar n \in \{\bar 4, \bar 5\}.
$$
The implication $(\Leftarrow)$ — if $\bar n \in \{\bar 4, \bar 5\}$ then $n$ is not a sum of three cubes — is the proven Theorem 3. The implication $(\Rightarrow)$ — if $n$ is not a sum of three cubes then $\bar n \in \{\bar 4, \bar 5\}$ — is logically equivalent (by contraposition) to Conjecture 6 and is therefore open.

*Proof.* The $(\Leftarrow)$ direction is Theorem 3. For $(\Rightarrow)$, contraposition gives: $\bar n \notin \{\bar 4, \bar 5\} \implies S(n)$, which is exactly Conjecture 6. $\qquad\blacksquare$

The honest accounting in Theorem 7 is the central methodological point of this paper: the characterization is genuinely complete *as a statement*, but only one of its two directions is currently a theorem. The other is supported by overwhelming computational evidence — every integer below $100$ has been verified, including the famously difficult cases $33$ and $42$ resolved in $2019$ — yet remains unproven.

## 7. Geometry of cubic surfaces and the Hasse principle

The set of real solutions of $x^3 + y^3 + z^3 = n$ is a smooth cubic surface in $\mathbb{R}^3$ (for $n \neq 0$). The representability question asks whether this surface contains an integer point.

**Local versus global.** The *Hasse principle* (local–global principle) asks whether solvability in all completions of $\mathbb{Q}$ (the reals and all $p$-adic fields) implies solvability over $\mathbb{Q}$ — or, in the integral setting, whether the absence of congruence obstructions implies the existence of an integer solution. For three cubes:

- Over $\mathbb{R}$ the surface is unbounded and always contains real points, so there is no real obstruction.
- The only $p$-adic / congruence obstruction is the one modulo $9$ identified in Theorem 3 (the prime $3$ being the relevant one).

Conjecture 6 is precisely the assertion that for the three-cube equation, local solvability is sufficient for global (integral) solvability: nine is the *whole story*. The extreme size of minimal solutions (e.g. for $30$, $33$, $42$) is consistent with heuristic lattice-point counts predicting that solutions exist but are sparse and remote.

## 8. Polynomial families of representations

Some values admit infinitely many representations via one-parameter polynomial identities, in contrast to the deep isolated witnesses required for hard targets. Classical examples include identities producing representations of $1$ and of $2$ for every value of a parameter; for instance, the identity
$$
(9t^4)^3 + (3t - 9t^4)^3 + (1 - 9t^3)^3 = 1
$$
yields infinitely many representations of $1$. The existence of such families motivates the conjecture that any value representable in more than one essentially distinct way lies on an algebraic curve within the cubic surface, producing an unbounded supply of integral representations. This phenomenon, together with the negation symmetry of Proposition 4, structures the search for representations and the study of their density.

## 9. Algorithms

We describe the two basic computational procedures associated with the results above.

**Algorithm A — Local obstruction test.** Given $n$, compute $r = n \bmod 9$. If $r \in \{4, 5\}$ output "not representable" (certified by Theorem 3). Otherwise output "no local obstruction" (representability is then conjectural but expected). Complexity $O(1)$ after a single modular reduction.

**Algorithm B — Bounded search for witnesses.** Given $n$ and a bound $B$, search for integers $x, y, z$ with $|x|,|y|,|z| \le B$ and $x^3+y^3+z^3 = n$. A standard refinement fixes $z$ and $x$ and tests whether $n - x^3 - z^3$ is a perfect cube; the negation symmetry of Proposition 4 halves the work by treating $n$ and $-n$ together. Naive complexity $O(B^2 \log B)$ per target with the cube-test refinement. This procedure finds the small witnesses of Proposition 5 immediately but is hopeless for hard targets like $33$, whose minimal solution lies far beyond any feasible $B$ — motivating the sophisticated sieves used in record computations.

## 10. Discussion

The three-cube problem exhibits a sharp dichotomy. The *negative* side — impossibility — is completely understood and elementary: a remainder computation modulo $9$ settles it once and for all. The *positive* side — possibility — is conjectural, computationally savage, and tied to the deepest principles of Diophantine geometry. The clean separation of these two halves, and the precise identification of which is proven, is the contribution of this paper.

It is worth emphasizing why the positive side cannot be reduced to computation. Verifying any finite set of integers leaves infinitely many untested in each residue class, and there is no known effective bound on the size of a minimal representation as a function of $n$. Indeed the absence of such a bound is what makes individual cases like $33$ historically intractable until massive computational resources were applied.

## 11. Future directions

We highlight several directions, growing directly from the separation of the local and global halves of the problem.

**Nine is the whole story.** Prove that every integer not congruent to $4$ or $5$ modulo $9$ is a sum of three cubes (Conjecture 6). The proportion of admissible residues modulo $9$ is exactly $7/9$, and no second obstruction has ever been observed; with all targets below $100$ now settled, the goal is to explain why no further barrier appears.

**Infinitely many essentially different families.** For each value representable in more than one way, exhibit a one-parameter polynomial family producing infinitely many representations, generalizing the classical identities for $1$ and $2$ and exploiting the central symmetry of the surface.

**Unbounded growth of representation counts.** Show that for every admissible $n$, the number of representations with coordinates bounded by $T$ tends to infinity as $T \to \infty$, in accordance with lattice-point heuristics mirroring the $7/9$ residue density.

**Balanced minimal witnesses.** For values requiring very large coordinates, establish that minimal witnesses are asymptotically balanced — two large terms of opposite sign with a controlled remainder — as forced by the symmetry of the surface.

## 12. Conclusion

We have given a complete, elementary, and rigorous proof that no integer congruent to $4$ or $5$ modulo $9$ is a sum of three cubes, established explicit witnesses for every admissible residue class, recorded the negation symmetry, and assembled these into a precise characterization whose sole open direction is exactly Heath-Brown's density conjecture. The result delineates the boundary between what is known and what is believed in one of number theory's most enduring elementary problems.
