# Escher Staircases: Transfer Laws for the Failure of the Ascending Chain Condition

## Abstract

We introduce the *Escher staircase*, an order-theoretic gadget in a commutative ring:
an infinite strictly ascending chain of ideals $I_0 \subsetneq I_1 \subsetneq \cdots$
whose infimum returns to its bottom rung. We prove that a commutative ring admits an
Escher staircase if and only if it is not Noetherian, so that "admits an Escher
staircase" is a ring invariant coinciding exactly with the failure of the ascending
chain condition. We exhibit two explicit staircases — one in the countable product
ring $\prod_{\mathbb{N}} \mathbb{Z}$ and one in the polynomial ring
$k[x_0, x_1, \dots]$ in countably many variables — each of which "loops back" in the
sense that the meet of the whole ascending tower is the zero ideal, the very floor
the ascent begins from. We then determine how the invariant transfers under the three
basic ring constructions. For a finite product, $R \times S$ admits a staircase iff
some factor does (a local-to-global obstruction). Adjoining a single variable is
neutral: $R[x]$ admits a staircase iff $R$ does. Most strikingly, the invariant is
*not* monotone under subrings: there is an injective ring homomorphism from a ring
with a staircase into a ring with none, realized concretely by the inclusion of the
non-Noetherian domain $\mathbb{Q}[x_0, x_1, \dots]$ into its field of fractions. This
"collapse" is the precise algebraic form of Escher's impossible architecture: a
staircase present downstairs vanishes upon passing to an overring. We accompany the
theory with a numerical toolkit that constructs, verifies, and visualizes explicit
staircases and their collapse.

## 1. Introduction

Emmy Noether's ascending chain condition (ACC) — every ascending chain of ideals
eventually stabilizes — is the dividing line between the tame and the wild in
commutative algebra. Noetherian rings support the finiteness theorems on which
algebraic geometry and number theory rest; non-Noetherian rings are their unruly
complement. This paper adopts a deliberately geometric, even pictorial, view of that
complement.

An *Escher staircase* is an infinite strictly ascending chain of ideals. The name
recalls M. C. Escher's *Ascending and Descending*, in which a staircase rises through
four flights only to return to its origin. Our flagship staircases have exactly this
property at the level of the ideal lattice: they climb strictly forever, yet the meet
of all their rungs is the zero ideal, the bottom rung from which the ascent starts.
The failure of ACC is thus literalized as an impossible architecture.

Our contributions are:

1. A clean characterization: a commutative ring admits an Escher staircase iff it is
   not Noetherian (Theorem 3.1).
2. Two explicit, verified staircases with the loop-back property, in
   $\prod_{\mathbb{N}} \mathbb{Z}$ (Theorem 4.1) and in $k[x_0, x_1, \dots]$
   (Theorem 4.4), together with a sharp finite/infinite dichotomy for polynomial
   rings (Theorem 4.6).
3. A negative instance: the $p$-adic integers admit no staircase (Theorem 4.7).
4. Three transfer laws describing how the invariant behaves under products
   (Theorem 5.1), single-variable adjunction (Theorem 5.3), and subring inclusion
   (Theorem 5.5). The last is the "collapse" phenomenon and shows the invariant is
   emphatically not monotone under subrings.

## 2. Definitions and preliminaries

Throughout, $R$ and $S$ denote commutative rings with unit. An **ideal** of $R$ is an
additive subgroup $I \subseteq R$ with $rI \subseteq I$ for all $r \in R$. The ideals
of $R$ form a complete lattice $(\mathrm{Ideal}(R), \subseteq)$ with bottom element
$\bot = \{0\}$, top element $R$, meets given by intersection, and joins given by ideal
sum. For a family $\{I_n\}$ the meet is $\bigwedge_n I_n = \bigcap_n I_n$.

**Definition 2.1 (Escher staircase).** An *Escher staircase* in $R$ is a strictly
monotone map $I : \mathbb{N} \to \mathrm{Ideal}(R)$; equivalently, an infinite chain
$I_0 \subsetneq I_1 \subsetneq I_2 \subsetneq \cdots$ of ideals. We write
$\mathrm{Esc}(R)$ for the proposition "$R$ admits an Escher staircase."

**Definition 2.2 (Noetherian ring).** $R$ is *Noetherian* if it satisfies the
ascending chain condition: every ascending chain of ideals is eventually constant.
Equivalently, the order $(\mathrm{Ideal}(R), \subsetneq)$ is well-founded when read as
a descending relation — there is no strictly increasing $\mathbb{N}$-indexed chain.

**Definition 2.3 (loop-back).** An Escher staircase $\{I_n\}$ *loops back* if
$\bigwedge_n I_n = I_0$. Since the chain is ascending, $\bigwedge_n I_n = I_0$ always
holds; the loop-back terminology is reserved for the striking special case
$I_0 = \bot$, where the infimum of an infinite strict *ascent* is the zero ideal.

We recall two facts used repeatedly. First, **surjective inheritance**: if
$\varphi : A \to B$ is a surjective ring homomorphism and $A$ is Noetherian, then $B$
is Noetherian (ideals of $B$ pull back injectively and order-preservingly to ideals
of $A$). Second, the **Hilbert Basis Theorem**: if $R$ is Noetherian, so is the
polynomial ring $R[x]$.

## 3. The invariant theorem

**Theorem 3.1 (Escher staircase $=$ non-Noetherian).** For every commutative ring
$R$,
$$ \mathrm{Esc}(R) \iff R \text{ is not Noetherian.} $$

*Proof sketch.* Being Noetherian is, by definition, well-foundedness of the strict
inclusion order on ideals read as a descending relation; equivalently, the
nonexistence of a strictly increasing $\mathbb{N}$-chain of ideals. An Escher
staircase is by definition exactly such a strictly increasing chain. Thus $R$ is
non-Noetherian iff the "no strictly increasing chain" property fails iff a strictly
increasing chain — an Escher staircase — exists. In one direction, a strictly
monotone chain witnesses non-well-foundedness directly; in the other, non-well-
foundedness of an $\mathbb{N}$-indexed relation yields an order embedding of
$(\mathbb{N}, <)$, whose image is a strictly increasing chain. $\square$

Theorem 3.1 turns every subsequent question about staircases into a question about
Noetherianity, and vice versa. It is the load-bearing bridge of the paper: all
transfer laws below are proved by transporting the corresponding Noetherian transfer
law across this equivalence.

## 4. Explicit staircases and the negative instance

### 4.1 The tail-vanishing staircase in $\prod_{\mathbb{N}} \mathbb{Z}$

Let $R = \prod_{n \in \mathbb{N}} \mathbb{Z}$ be the ring of integer sequences
$f = (f_0, f_1, \dots)$ under coordinatewise operations. For $n \in \mathbb{N}$ define
$$ S_n = \{\, f \in R : f_k = 0 \text{ for all } k \ge n \,\}. $$

**Lemma 4.0.** Each $S_n$ is an ideal, and $n \mapsto S_n$ is monotone.

*Proof sketch.* Closure under addition and under multiplication by arbitrary
sequences is checked coordinatewise: if $f_k = 0$ for $k \ge n$, then $(f+g)_k = 0$
and $(cf)_k = 0$ for $k \ge n$ whenever $g$ shares the vanishing and $c$ is arbitrary.
Monotonicity holds because $m \le n$ and $f_k = 0$ for $k \ge m$ force $f_k = 0$ for
$k \ge n$. $\square$

**Theorem 4.1 (explicit staircase in $\prod_{\mathbb{N}}\mathbb{Z}$).** The chain
$S_0 \subsetneq S_1 \subsetneq S_2 \subsetneq \cdots$ is an Escher staircase, with
$S_0 = \bot$ and $\bigwedge_n S_n = \bot$; it loops back.

*Proof sketch.* Strictness: let $e_n \in R$ be the indicator sequence with a $1$ in
position $n$ and $0$ elsewhere. Then $e_n \in S_{n+1}$ since it vanishes for all
$k \ge n+1$, but $e_n \notin S_n$ since its value at $k = n$ is $1 \ne 0$. Hence
$S_n \subsetneq S_{n+1}$, and strict monotonicity of the whole chain follows because a
map on $\mathbb{N}$ that strictly increases at each successor is strictly monotone.
Bottom rung: $f \in S_0$ means $f_k = 0$ for all $k \ge 0$, i.e. $f = 0$; so
$S_0 = \bot$. Loop-back: $\bigwedge_n S_n \subseteq S_0 = \bot$, and $\bot$ is
contained in everything, so $\bigwedge_n S_n = \bot$. $\square$

**Corollary 4.2.** $\prod_{\mathbb{N}} \mathbb{Z}$ is not Noetherian.

*Proof.* Immediate from Theorem 4.1 and Theorem 3.1. $\square$

### 4.2 The variable staircase in $k[x_0, x_1, \dots]$

Let $k$ be a field and let $R = k[x_0, x_1, x_2, \dots]$ be the polynomial ring in
countably many variables. For $n \in \mathbb{N}$ put
$$ V_n = \langle x_0, x_1, \dots, x_{n-1} \rangle, $$
the ideal generated by the first $n$ variables (so $V_0 = \langle \varnothing\rangle
= \bot$).

**Lemma 4.3 (missing-variable non-membership).** For any finite set $s \subseteq
\mathbb{N}$ and any $j \notin s$, the variable $x_j$ does not lie in the ideal
$\langle \{x_i : i \in s\} \rangle$.

*Proof sketch.* Consider the $k$-algebra endomorphism $\varphi_s$ of $R$ sending
$x_i \mapsto 0$ for $i \in s$ and $x_i \mapsto x_i$ otherwise. It kills every
generator $x_i$, $i \in s$, hence annihilates the entire ideal
$\langle \{x_i : i \in s\}\rangle$. If $x_j$ lay in that ideal we would get
$x_j = \varphi_s(x_j) = 0$, contradicting $x_j \ne 0$ in a polynomial ring over a
field. $\square$

**Theorem 4.4 (variable staircase).** The chain
$V_0 \subsetneq V_1 \subsetneq V_2 \subsetneq \cdots$ is an Escher staircase with
$V_0 = \bot$ and $\bigwedge_n V_n = \bot$; it loops back.

*Proof sketch.* Applying Lemma 4.3 with $s = \{0, \dots, n-1\}$ and $j = n$ gives
$x_n \in V_{n+1} \setminus V_n$, so $V_n \subsetneq V_{n+1}$ and the chain is strictly
monotone. Since $V_0 = \bot$, loop-back follows as in Theorem 4.1. $\square$

**Corollary 4.5.** $k[x_0, x_1, \dots]$ is not Noetherian (its "Escher height" is
infinite).

### 4.3 The dichotomy and the negative instance

**Theorem 4.6 (polynomial dichotomy).** Over a field $k$: for every finite $n$, the
ring $k[x_1, \dots, x_n]$ admits no Escher staircase; the ring $k[x_0, x_1, \dots]$ in
countably many variables does. In particular the single-variable ring $k[x]$ admits no
staircase.

*Proof sketch.* By the Hilbert Basis Theorem and induction, $k[x_1, \dots, x_n]$ is
Noetherian for every finite $n$ (a field is Noetherian), so by Theorem 3.1 it admits
no staircase. The positive half is Theorem 4.4. $\square$

**Theorem 4.7 (no staircase in the $p$-adics).** For each prime $p$, the ring
$\mathbb{Z}_p$ of $p$-adic integers admits no Escher staircase.

*Proof sketch.* $\mathbb{Z}_p$ is a discrete valuation ring, hence a principal ideal
domain, hence Noetherian; apply Theorem 3.1. $\square$

Theorems 4.6 and 4.7 show the invariant has genuine content on both sides: it is
inhabited (with concrete witnesses) exactly for the non-Noetherian rings and refuted
for the Noetherian ones.

## 5. Transfer laws

We now describe how $\mathrm{Esc}(-)$ transfers under the three basic constructions.
Each proof runs through Theorem 3.1 to the corresponding statement about
Noetherianity.

### 5.1 Finite products: a local-to-global obstruction

**Theorem 5.1 (product law).**
$$ \mathrm{Esc}(R \times S) \iff \mathrm{Esc}(R) \ \lor\ \mathrm{Esc}(S). $$

*Proof sketch.* It suffices to prove $R \times S$ Noetherian iff both $R$ and $S$ are;
negating and applying Theorem 3.1 gives the claim. The projections
$\pi_R : R \times S \to R$ and $\pi_S : R \times S \to S$ are surjective ring
homomorphisms, so if $R \times S$ is Noetherian then, by surjective inheritance, so
are $R$ and $S$. Conversely, a finite product of Noetherian rings is Noetherian (its
ideals decompose as products of ideals of the factors). Thus $R \times S$ is
Noetherian iff $R$ and $S$ both are, and $R \times S$ is non-Noetherian iff at least
one factor is. $\square$

The content of Theorem 5.1 is that the impossible staircase of a finite product is
always witnessed inside a single coordinate: it is a local-to-global obstruction,
detected factorwise.

**Example 5.2.** Take $R = \mathbb{Q}[x_0, x_1, \dots]$ (a staircase, by Theorem 4.4)
and $S = \mathbb{Q}$ (no staircase). Then $R \times S$ admits an Escher staircase,
lifted from the first coordinate.

### 5.2 Single-variable adjunction is neutral

**Theorem 5.3 (single variable is neutral).**
$$ \mathrm{Esc}(R[x]) \iff \mathrm{Esc}(R). $$

*Proof sketch.* Again reduce to Noetherianity. The evaluation homomorphism
$\mathrm{ev}_0 : R[x] \to R$, $x \mapsto 0$, is surjective (it has the constant-
polynomial inclusion $C : R \to R[x]$ as a right inverse), so if $R[x]$ is Noetherian
then $R$ is. Conversely, if $R$ is Noetherian then $R[x]$ is by the Hilbert Basis
Theorem. Hence $R[x]$ is non-Noetherian iff $R$ is. $\square$

**Remark 5.4.** Theorems 4.6 and 5.3 together locate the polynomial phenomenon
precisely. No single variable ever creates or destroys the staircase; only the passage
from finitely many to *infinitely* many variables can. The staircase is a property of
the *cardinality* of the generating set of indeterminates, not of any individual one.

### 5.3 The collapse: non-monotonicity under subrings

The naive expectation is that enlarging a ring can only enrich its ideal structure, so
that a staircase should persist under injective ring maps ("Escher height is monotone
under subrings"). This is false.

**Theorem 5.5 (subring collapse).** There exists an injective ring homomorphism
$\iota : A \hookrightarrow B$ with $\mathrm{Esc}(A)$ true and $\mathrm{Esc}(B)$ false.
Concretely, $A = \mathbb{Q}[x_0, x_1, \dots]$ and
$B = \mathbb{Q}(x_0, x_1, \dots) = \mathrm{Frac}(A)$ is its field of fractions, with
$\iota$ the canonical inclusion.

*Proof sketch.* $A$ is an integral domain, so the localization map into its field of
fractions $B = \mathrm{Frac}(A)$ is an injective ring homomorphism. By Theorem 4.4,
$\mathrm{Esc}(A)$ holds. But $B$ is a field, whose only ideals are $\bot$ and $B$
itself; a two-element ideal lattice cannot contain an infinite strict chain, so $B$ is
Noetherian and $\mathrm{Esc}(B)$ is false by Theorem 3.1. $\square$

**Corollary 5.6 (non-monotonicity).** The property $\mathrm{Esc}(-)$ is not preserved
by injective ring homomorphisms; equivalently, a subring can be strictly *further*
from Noetherian than a ring containing it.

Theorem 5.5 is the crispest algebraic form of Escher's illusion. Downstairs, in
$A = \mathbb{Q}[x_0, x_1, \dots]$, the tower
$\langle x_0\rangle \subsetneq \langle x_0, x_1\rangle \subsetneq \cdots$ climbs
forever. Upstairs, in $B = \mathrm{Frac}(A)$, every nonzero element is invertible, so
each rung $V_n$ generates the unit ideal and the entire tower collapses to a single
level. Passing to the overring erases the staircase: it was a feature of the sub-
architecture, invisible from above.

### 5.4 The shape of the transfer laws

Reading the three laws together reveals a pattern. Surjections transport the invariant
*covariantly*: if $B$ surjects onto $A$ and $A$ has a staircase, then so does $B$
(this powers both the product projections and the polynomial evaluation). Injections,
by contrast, transport it the wrong way: a staircase can be *created* by passing to a
subring. The invariant measures how far a ring is from Noetherian, and along
inclusions that distance can only stay the same or grow as we shrink.

## 6. Algorithms and numerical illustration

While the objects are infinite, every finite window of a staircase is fully effective,
and we provide a computational toolkit (see the accompanying demonstrations) that:

1. **Constructs and certifies** the tail-vanishing staircase $\{S_n\}$ in
   $\prod_{\mathbb{N}} \mathbb{Z}$ up to any depth $N$, producing for each step the
   indicator witness $e_n \in S_{n+1} \setminus S_n$ and verifying the loop-back
   $\bigcap_{n \le N} S_n = \bot$.
2. **Builds monomial variable ideals** $V_n = \langle x_0, \dots, x_{n-1}\rangle$ and
   tests membership by divisibility, certifying $x_n \in V_{n+1} \setminus V_n$ via the
   missing-variable homomorphism of Lemma 4.3.
3. **Evaluates the product law** on user-supplied factors, reporting the coordinate
   that witnesses a product staircase.
4. **Simulates the collapse** by tracking each rung $V_n$ as an ideal of the polynomial
   ring and as an ideal of the fraction field, exhibiting the swelling
   $V_n \mapsto (1)$ upstairs.

The algorithms are polynomial-time in the truncation depth and the number of
generators, because membership in a monomial ideal reduces to divisibility of
exponent vectors, and each staircase witness is produced in closed form.

## 7. Discussion

The Escher staircase repackages the ascending chain condition as a concrete, climbable
object and, through the transfer laws, exposes an asymmetry that is easy to overlook
when ACC is stated abstractly. Good behavior under quotients and products is expected;
*failure* of monotonicity under subrings is the surprise, and it is exactly what makes
non-Noetherian rings feel "impossible." A ring may be more tangled than every ring
containing it, and that excess tangle is a genuine, exhibitable staircase.

The results also sharpen intuition about *where* non-Noetherianity comes from. The
polynomial dichotomy plus single-variable neutrality show that, for polynomial rings
over a field, the phenomenon is purely a matter of having infinitely many generators;
no finite amount of variable-adjoining can produce it. The collapse theorem shows,
dually, that inverting elements (passing to a localization, in the extreme to the
fraction field) can destroy it entirely.

## 8. Future directions

Three programs suggest themselves.

**A numerical height.** One would like to refine mere existence of a staircase into a
numerical *Escher height*: the longest chain of prime ideals threadable strictly
between consecutive rungs of a grounded ascending chain (one whose infimum is its
bottom rung). The conjecture is that a polynomial ring in finitely many variables has
height zero, in infinitely many variables has infinite height, and the ring of
integer-valued polynomials has height equal to its Krull dimension, two. The transfer
laws motivate the refinement: bare existence is too coarse to separate rings, since
products, single variables, and some subrings all preserve or manufacture a staircase.

**The algebraic integers.** The ring of all algebraic integers is the canonical
one-dimensional non-Noetherian ring. We conjecture it admits an explicit staircase
built from successive dyadic radicals of $2$ (the square root, fourth root, eighth
root, …), whose infimum is the zero ideal and whose Escher height is exactly one — the
first genuinely intermediate, arithmetically meaningful value of the invariant. The
engine is infinite divisibility of the value group.

**Where the staircase collapses.** For the polynomial ring in countably many
variables, we conjecture that the variable staircase survives every enlargement
obtained by inverting finitely many nonzero elements, but disappears the moment
infinitely many are inverted, delineating precisely the family of overrings in which
the collapse of Theorem 5.5 occurs.

## 9. Conclusion

An Escher staircase — an infinite strictly ascending chain of ideals that loops back
to its zero-ideal floor — is a faithful, pictorial name for the failure of the
ascending chain condition. It exists in a commutative ring exactly when the ring is
non-Noetherian; it can be built by hand in the countable integer product and in
polynomial rings with infinitely many variables; and it is forbidden in Noetherian
rings such as the $p$-adics and finite-variable polynomial rings. Its transfer laws
are covariant along surjections (products, single-variable adjunction) but broken along
inclusions: a subring can carry a staircase that collapses the instant one steps up to
an overring. That final asymmetry is Escher's impossible staircase, rendered exactly in
the lattice of ideals.
