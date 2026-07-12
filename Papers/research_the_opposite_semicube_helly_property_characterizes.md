# The Opposite-Semicube Helly Property Characterizes Harmonic-Evenness in Cartesian Products of Partial Cubes

**Author:** Aristotle

**Date:** 2026-07-12

## Abstract

Partial cubes — the isometric subgraphs of hypercubes — carry a canonical family
of *cuts* (Θ-classes), each of which partitions the vertex set into two opposite
*semicubes*. We study two structural conditions on a finite partial cube. The
first, *harmonic-evenness*, requires every cut to be balanced, i.e. to split the
vertex set into two equinumerous semicubes; it is the discrete analogue of the
mean-value symmetry of harmonic functions. The second, the *opposite-semicube
Helly property*, requires that for every cut the two opposite semicubes admit a
matching (a bijection). Our first result is that these two conditions coincide for
finite partial cubes: matchability of every cut is equivalent to balance of every
cut. Our main result concerns the Cartesian product $P \,\square\, R$ of two
partial cubes. We prove that harmonic-evenness is *multiplicative*: for nonempty
factors, $P \,\square\, R$ is harmonic-even if and only if both $P$ and $R$ are.
Combining the two results yields the titular characterization: *a Cartesian
product of two nonempty partial cubes satisfies the opposite-semicube Helly
property if and only if both factors are harmonic-even.* The argument is entirely
cancellation-based: the semicube of a factor-coordinate in the product has
cardinality equal to that factor-semicube's cardinality times the number of
vertices of the other factor, and cancelling the (positive) complementary factor
recovers balance in the factor. We also record that the classical Helly-number-two
property for semicubes of a hypercube transfers verbatim to a Cartesian product of
hypercubes, since such a product is again a hypercube on the disjoint union of the
coordinate sets. We give a computational treatment, algorithms for detecting
balance and for factoring it through products, and worked numerical examples.

**Keywords:** partial cube, hypercube, Djoković–Winkler relation, semicube,
harmonic-evenness, balanced cut, Helly property, Cartesian product, isometric
embedding, matching.

## 1. Introduction

A **partial cube** is a graph that embeds isometrically into a hypercube: there is
a labelling of vertices by binary vectors under which graph distance equals
Hamming distance. Partial cubes form a rich and much-studied class that includes
hypercubes, even cycles, trees, median graphs, tope graphs of oriented matroids,
and the state graphs of media theory. Their defining structural feature is the
**Djoković–Winkler relation** $\Theta$ on edges, which in a partial cube is an
equivalence relation. Its equivalence classes, the **Θ-classes** or **cuts**,
correspond exactly to the coordinates of an isometric embedding, and deleting a
single Θ-class splits the graph into two connected **semicubes** (halfspaces).

This paper isolates and relates two symmetry conditions on the semicubes of a
finite partial cube. The first is a *metric* condition — that every cut splits the
vertex set into two halves of equal size, which we call **harmonic-evenness**. The
second is a *transversal* condition of Helly/Hall type — that for every cut the
two opposite semicubes can be put into bijection, which we call the
**opposite-semicube Helly property**. We then determine how each behaves under the
Cartesian product of partial cubes, the fundamental construction that assembles
large partial cubes from small ones (e.g. hypercubes as products of edges, grids
as products of paths).

Our contributions are:

1. **An equivalence of viewpoints** (Theorem 3.1): for finite partial cubes, the
   opposite-semicube Helly property is equivalent to harmonic-evenness. This
   converts an existence-of-bijection statement into an equality-of-cardinality
   statement.

2. **Multiplicativity of balance** (Theorem 4.3): for nonempty finite partial
   cubes $P$ and $R$, the product $P \,\square\, R$ is harmonic-even if and only if
   both $P$ and $R$ are harmonic-even.

3. **The main characterization** (Theorem 4.4): for nonempty finite partial
   cubes, $P \,\square\, R$ satisfies the opposite-semicube Helly property if and
   only if both factors are harmonic-even; equivalently, if and only if both
   factors themselves satisfy the opposite-semicube Helly property.

4. **A Helly-number-two transfer** (Theorem 5.1): the classical result that
   pairwise-intersecting semicubes of a hypercube have a common point transfers
   verbatim to a Cartesian product of two hypercubes.

The paper is organized as follows. Section 2 fixes the coordinate model and
definitions. Section 3 proves the equivalence of the two symmetry conditions.
Section 4 develops the product theory and proves the main theorem. Section 5
records the Helly-number-two transfer. Section 6 gives algorithms and a complexity
discussion, Section 7 numerical examples, and Section 8 applications and future
directions.

## 2. The coordinate model and basic definitions

We work throughout in the *coordinate model* of partial cubes, which is the most
convenient for cardinality arguments and for treating Cartesian products
uniformly.

**Definition 2.1 (Vertices and vertex sets).** Fix a finite index set $\alpha$
(the *coordinate set*, i.e. the set of Θ-classes). A **vertex** on $\alpha$ is a
sign vector $v : \alpha \to \{\,\text{true},\text{false}\,\}$. A **partial cube on
$\alpha$** is a finite nonempty set $V$ of such vertices, thought of as the image
of an isometric embedding into the hypercube $\{\text{true},\text{false}\}^\alpha$.
Each coordinate $i \in \alpha$ is a Θ-class.

**Definition 2.2 (Semicube).** For a vertex set $V$ on $\alpha$, a coordinate
$i \in \alpha$, and a sign $b \in \{\text{true}, \text{false}\}$, the **semicube**
of coordinate $i$ with sign $b$ is
$$W_i^{b}(V) \;=\; \{\, v \in V : v(i) = b \,\}.$$
The two opposite semicubes of the cut $i$ are $W_i^{\text{true}}(V)$ and
$W_i^{\text{false}}(V)$; they partition $V$.

**Definition 2.3 (Balanced cut).** A coordinate $i$ is **balanced** in $V$ if its
two opposite semicubes are equinumerous:
$$\bigl|W_i^{\text{true}}(V)\bigr| \;=\; \bigl|W_i^{\text{false}}(V)\bigr|.$$

**Definition 2.4 (Harmonic-even partial cube).** A partial cube $V$ is
**harmonic-even** if every coordinate is balanced:
$$\forall i \in \alpha,\quad \bigl|W_i^{\text{true}}(V)\bigr| = \bigl|W_i^{\text{false}}(V)\bigr|.$$

The terminology reflects the analogy with harmonic functions: balance across every
cut is the combinatorial precondition for a size-preserving, sign-reversing
symmetry — a discrete mean-value symmetry.

**Definition 2.5 (Opposite-semicube Helly property).** A partial cube $V$ has the
**opposite-semicube Helly property** if for every coordinate $i$ there is a
bijection between the two opposite semicubes:
$$\forall i \in \alpha,\quad \exists \text{ a bijection } W_i^{\text{true}}(V) \;\xrightarrow{\ \sim\ }\; W_i^{\text{false}}(V).$$
Equivalently, for each cut the two opposite semicubes admit a common system of
representatives via a perfect matching. This is a transversal condition in the
spirit of Hall's marriage theorem and Helly's theorem: local compatibility across
each single cut is required to hold simultaneously for all cuts.

**Examples 2.6.**

- The **hypercube** $Q_n = \{\text{true},\text{false}\}^{\{1,\dots,n\}}$ is
  harmonic-even: each coordinate splits $Q_n$ into two faces of size $2^{n-1}$.
- The **even cycle** $C_{2k}$, isometrically embedded into $Q_k$ so that each of
  its $k$ coordinates flips exactly twice (antipodally), is harmonic-even: each
  cut separates the cycle into two arcs of $k$ vertices.
- The **path** $P_n$ ($n$ vertices), embedded as the staircase
  $v_j = (\underbrace{\text{true},\dots,\text{true}}_{j},\text{false},\dots,\text{false})$,
  has coordinate $i$ separating $\{v_{i+1},\dots,v_{n-1}\}$ from
  $\{v_0,\dots,v_i\}$, of sizes $n-1-i$ and $i+1$. These are equal only when
  $i = (n-2)/2$; hence $P_n$ is **not** harmonic-even for $n \geq 3$. (The single
  edge $P_2 = Q_1$ is harmonic-even.)

## 3. Matchability equals balance

**Theorem 3.1 (Characterization of the opposite-semicube Helly property).** *Let
$V$ be a finite partial cube. Then $V$ satisfies the opposite-semicube Helly
property if and only if $V$ is harmonic-even.*

*Proof.* Both properties are coordinate-wise; fix a coordinate $i$. The two
opposite semicubes $W_i^{\text{true}}(V)$ and $W_i^{\text{false}}(V)$ are finite
sets.

($\Rightarrow$) Suppose there is a bijection
$e : W_i^{\text{true}}(V) \to W_i^{\text{false}}(V)$. A bijection between finite
sets forces equality of cardinalities, so
$|W_i^{\text{true}}(V)| = |W_i^{\text{false}}(V)|$; thus $i$ is balanced.

($\Leftarrow$) Suppose $i$ is balanced, i.e.
$|W_i^{\text{true}}(V)| = |W_i^{\text{false}}(V)|$. Two finite sets of equal
cardinality are in bijection (choose any pairing of their elements in order); this
supplies the required bijection.

Since $i$ was arbitrary, matchability of every cut is equivalent to balance of
every cut, i.e. the opposite-semicube Helly property is equivalent to
harmonic-evenness. $\qquad\blacksquare$

**Remark 3.2.** Theorem 3.1 is the conceptual bridge of the paper. The
opposite-semicube Helly property is *a priori* an existence statement about
bijections and thus resists direct computation; harmonic-evenness is a finite
system of cardinality equalities and is directly checkable. The two are logically
identical, so from here on we may prove product theorems about the (computable)
balance condition and read them off for the (transversal) Helly condition. Note
that the equivalence uses only finiteness — no structure of the partial cube
beyond the semicube partition is required.

## 4. Cartesian products and multiplicativity of balance

**Definition 4.1 (Cartesian product of partial cubes).** Let $P$ be a partial
cube on coordinate set $\alpha$ and $R$ a partial cube on coordinate set $\beta$,
with $\alpha$ and $\beta$ disjoint. Their **Cartesian product** $P \,\square\, R$
is the partial cube on the coordinate set $\alpha \sqcup \beta$ (the disjoint
union) given by
$$P \,\square\, R \;=\; \bigl\{\, \mathrm{elim}(a,b) : a \in P,\ b \in R \,\bigr\},$$
where $\mathrm{elim}(a,b) : \alpha \sqcup \beta \to \{\text{true},\text{false}\}$
is the vertex whose restriction to $\alpha$ is $a$ and whose restriction to
$\beta$ is $b$. In graph terms, $(a,b)$ and $(a',b')$ are adjacent iff either
$a = a'$ and $b, b'$ are adjacent in $R$, or $b = b'$ and $a, a'$ are adjacent in
$P$. This is the standard box product; it takes partial cubes to partial cubes,
and the coordinates (Θ-classes) of $P \,\square\, R$ are exactly $\alpha$ (from
$P$) together with $\beta$ (from $R$).

**Lemma 4.2 (Semicube cardinalities in a product).** *The merge map
$\mathrm{elim} : P \times R \to P \,\square\, R$ is a bijection, and for every
$\alpha$-coordinate $i$, $\beta$-coordinate $j$, and sign $c$,*
$$\bigl|W_{i}^{c}(P \,\square\, R)\bigr| = \bigl|W_i^{c}(P)\bigr|\cdot |R|,
\qquad
\bigl|W_{j}^{c}(P \,\square\, R)\bigr| = |P|\cdot\bigl|W_j^{c}(R)\bigr|.$$

*Proof.* Injectivity of $\mathrm{elim}$ is immediate: if
$\mathrm{elim}(a,b) = \mathrm{elim}(a',b')$ then restricting to $\alpha$ gives
$a = a'$ and restricting to $\beta$ gives $b = b'$. It is surjective onto
$P \,\square\, R$ by definition, so it is a bijection $P \times R \to
P \,\square\, R$.

For an $\alpha$-coordinate $i$, the vertex $\mathrm{elim}(a,b)$ has $i$-th
coordinate $c$ iff $a(i) = c$. Hence the semicube $W_i^{c}(P \,\square\, R)$ is the
image under $\mathrm{elim}$ of $W_i^{c}(P) \times R$. Because $\mathrm{elim}$ is
injective, this image has the same cardinality as the product set, namely
$|W_i^{c}(P)| \cdot |R|$. The $\beta$-coordinate case is symmetric, using that
$\mathrm{elim}(a,b)$ has $j$-th coordinate $c$ iff $b(j) = c$, giving the image of
$P \times W_j^{c}(R)$. $\qquad\blacksquare$

**Theorem 4.3 (Multiplicativity of harmonic-evenness).** *Let $P$ and $R$ be
nonempty finite partial cubes. Then*
$$P \,\square\, R \text{ is harmonic-even} \iff P \text{ is harmonic-even and } R \text{ is harmonic-even.}$$

*Proof.* The coordinates of $P \,\square\, R$ are the $\alpha$-coordinates
together with the $\beta$-coordinates, so harmonic-evenness of the product is the
conjunction of balance over all $\alpha$-coordinates and balance over all
$\beta$-coordinates. By Lemma 4.2, for an $\alpha$-coordinate $i$ the product's
balance equation is
$$\bigl|W_i^{\text{true}}(P)\bigr|\cdot |R| \;=\; \bigl|W_i^{\text{false}}(P)\bigr|\cdot |R|.$$
Since $R$ is nonempty, $|R| > 0$, and we may cancel it to obtain
$|W_i^{\text{true}}(P)| = |W_i^{\text{false}}(P)|$ — exactly balance of $i$ in $P$.
Conversely balance of $i$ in $P$ multiplies up to balance of $i$ in the product.
Thus balance over all $\alpha$-coordinates of the product is equivalent to
harmonic-evenness of $P$. Symmetrically, using $|P| > 0$, balance over all
$\beta$-coordinates is equivalent to harmonic-evenness of $R$. Conjoining the two
equivalences gives the claim. $\qquad\blacksquare$

**Theorem 4.4 (Main theorem).** *Let $P$ and $R$ be nonempty finite partial cubes.
Then $P \,\square\, R$ satisfies the opposite-semicube Helly property if and only
if both $P$ and $R$ are harmonic-even. Equivalently,*
$$P \,\square\, R \text{ has the opposite-semicube Helly property} \iff P \text{ and } R \text{ each have it.}$$

*Proof.* By Theorem 3.1 applied to the product, the opposite-semicube Helly
property of $P \,\square\, R$ is equivalent to harmonic-evenness of
$P \,\square\, R$. By Theorem 4.3 the latter is equivalent to harmonic-evenness of
$P$ and of $R$. This proves the first statement. Applying Theorem 3.1 again to
each factor turns harmonic-evenness of $P$ (resp. $R$) into the opposite-semicube
Helly property of $P$ (resp. $R$), giving the symmetric restatement.
$\qquad\blacksquare$

**Remark 4.5 (The nonemptiness hypotheses are load-bearing).** If $R = \emptyset$
then $P \,\square\, R = \emptyset$ is vacuously harmonic-even, while $P$ may be
arbitrarily unbalanced; the equivalence of Theorem 4.3 then fails. The cancellation
of $|R|$ in the proof is precisely the step that requires $|R| > 0$. Thus the
hypothesis that each factor is nonempty is essential, not cosmetic.

**Corollary 4.6 (Iterated products, informal).** Because the argument of Theorem
4.3 is purely a cancellation of the positive cardinality of the complementary
factors, and because the coordinate set of an iterated Cartesian product is the
disjoint union of the factors' coordinate sets, harmonic-evenness of a finite
Cartesian product of nonempty partial cubes is equivalent to harmonic-evenness of
every factor. In particular, since single edges and even cycles are harmonic-even,
every hypercube and every Cartesian product of even cycles ("Hamming graph of
cycles") is harmonic-even.

## 5. A Helly-number-two transfer for products of hypercubes

There is a second, purely intersection-theoretic Helly phenomenon for semicubes.
Consider semicubes of a hypercube as subsets of the vertex set indexed by a
coordinate and a sign. The classical statement is:

> If a finite family of semicubes of a hypercube is **pairwise intersecting**
> (every two of them share a vertex), then the whole family has a **common point**.

This is the assertion that the semicubes of a hypercube have **Helly number two**:
one need only verify pairwise compatibility to conclude global compatibility.

**Theorem 5.1 (Transfer to products of hypercubes).** *Let $Q$ be a Cartesian
product of two hypercubes, on coordinate sets $\alpha$ and $\beta$. Then the
semicubes of $Q$ have Helly number two: any finite pairwise-intersecting family of
semicubes of $Q$ has a common point.*

*Proof (sketch).* A Cartesian product of two hypercubes on $\alpha$ and $\beta$ is
itself a hypercube, namely the full hypercube on the disjoint union
$\alpha \sqcup \beta$ of coordinate sets. The semicubes of this product are exactly
the semicubes of that hypercube. The Helly-number-two property for semicubes of a
hypercube is a theorem valid on any coordinate set; specializing it to the
coordinate set $\alpha \sqcup \beta$ yields the statement for the product verbatim.
$\qquad\blacksquare$

**Remark 5.2.** The two Helly notions in this paper are conceptually distinct. The
opposite-semicube Helly property (Definition 2.5) concerns the *symmetry between
the two sides of a single cut*; the Helly-number-two property (Theorem 5.1)
concerns the *common overlap of many one-sided halves*. Disentangling their
logical relationship — whether either implies the other on the same product cubes —
is a natural direction for further work (Section 8).

## 6. Algorithms

We give three algorithms in the coordinate model. Throughout, a partial cube on
$\alpha$ is stored as an explicit list of $m = |V|$ sign vectors of length
$n = |\alpha|$.

**Algorithm A: Balance detection.** To decide harmonic-evenness, compute, for each
coordinate $i$, the number of vertices with $v(i) = \text{true}$; the cut is
balanced iff this equals $m/2$. Iterating over all coordinates and vertices costs
$O(mn)$ time and $O(n)$ auxiliary space.

**Algorithm B: Product construction and factored balance check.** Given $P$ (on
$\alpha$, $m_P$ vertices) and $R$ (on $\beta$, $m_R$ vertices), the product has
$m_P m_R$ vertices on $|\alpha| + |\beta|$ coordinates. By Theorem 4.3, one need
not materialize the product to check its balance: it suffices to run Algorithm A
on $P$ and on $R$ separately, an $O(m_P|\alpha| + m_R|\beta|)$ computation versus
the $O(m_P m_R(|\alpha|+|\beta|))$ cost of building and scanning the product. This
is the algorithmic payoff of multiplicativity.

**Algorithm C: Explicit cut matching.** When a cut $i$ is balanced, Theorem 3.1
guarantees a bijection between its opposite semicubes; Algorithm C produces one by
listing the two semicubes and pairing them in index order, in $O(m)$ time per cut.
The resulting family of per-cut matchings is a witness for the opposite-semicube
Helly property.

## 7. Numerical examples

The following are computed by the accompanying demonstration code and can be
reproduced directly from the definitions above.

- **Hypercube $Q_3$.** $8$ vertices, $3$ coordinates. Each coordinate has $4$
  vertices on each side; all cuts balanced. Harmonic-even ✓.
- **Even cycle $C_6$.** $6$ vertices, $3$ coordinates. Each cut splits into two
  arcs of $3$; all cuts balanced. Harmonic-even ✓.
- **Path $P_4$.** $4$ vertices, $3$ coordinates. Cut sizes are $(3,1)$, $(2,2)$,
  $(1,3)$; only the middle cut is balanced. Harmonic-even ✗.
- **Product $C_6 \,\square\, Q_2$.** $6 \cdot 4 = 24$ vertices. Every
  $C_6$-coordinate splits $12/12$; every $Q_2$-coordinate splits $12/12$. Balanced.
  Consistent with Theorem 4.4: both factors are harmonic-even, so the product
  satisfies the opposite-semicube Helly property. ✓
- **Product $P_4 \,\square\, Q_2$.** $4 \cdot 4 = 16$ vertices. The unbalanced
  $P_4$-cut of sizes $(3,1)$ becomes $(12,4)$ in the product — still unbalanced.
  The product fails harmonic-evenness, hence fails the opposite-semicube Helly
  property, exactly because the factor $P_4$ is not harmonic-even. ✗
- **Cancellation check.** For the $(3,1)$ cut of $P_4$ multiplied by
  $|Q_2| = 4$, the product cut is $(12,4)$; dividing out the factor $4$ recovers
  $(3,1)$, illustrating the cancellation step of Theorem 4.3.

## 8. Applications, discussion, and future directions

**Applications.** Harmonic-evenness is the combinatorial precondition for a
size-preserving, sign-reversing involution swapping the two sides of every cut.
Such involutions underlie bijective and cancellation proofs, and they force a
symmetric spectrum (about zero) for cut-averaging operators. The multiplicativity
theorem makes the property *modular*: large balanced structures can be built as
products of small balanced ones, and — conversely — a single unbalanced factor
cannot be repaired by multiplication. Because hypercubes, even cycles, and their
products are all harmonic-even, entire families (Hamming graphs of even cycles,
hypercubes of any dimension) inherit the opposite-semicube Helly property
automatically.

**Discussion.** The results are sharp in a precise sense: matchability and balance
are literally the same condition (Theorem 3.1), balance is exactly multiplicative
across products (Theorem 4.3), and the nonemptiness hypotheses cannot be dropped
(Remark 4.5). The proofs use only finiteness and the disjoint-union structure of
product coordinates; no metric input beyond the semicube partition is needed,
which is why the arguments are robust and extend cleanly.

**Future directions.**

1. *Harmonic-evenness as a multiplicative invariant of arbitrary products.* We
   conjecture that for any finite family of partial cubes, the Cartesian product is
   harmonic-even iff every factor is, and that the class of harmonic-even partial
   cubes is closed under Cartesian product and contains all even cycles and all
   hypercubes. Harmonic-evenness is coordinate-local and the coordinate set of a
   product is the disjoint union of the factors' coordinate sets, so balance of a
   product cut reduces to balance in exactly one factor after cancelling the
   positive cardinality of the complementary factors; the two-factor case is
   settled and its cancellation-based proof should extend verbatim to iterated
   products once the disjoint-union bookkeeping is made uniform.

2. *A metric dichotomy: opposite-semicube Helly vs. global Helly number.* We
   conjecture that the opposite-semicube Helly property and the classical
   Helly-number-two property for semicubes are logically independent — there are
   partial cubes satisfying one but not the other — and that their conjunction
   characterizes a strictly smaller, product-closed subclass. The two properties
   speak about different incidence structures: Helly-number-two constrains
   pairwise-intersecting families of same-side semicubes, whereas the
   opposite-semicube property constrains the symmetry between the two sides of a
   single cut. Both can be compared on the same product cubes without new
   foundational machinery.

3. *Balance forces spectral symmetry of the cut-transposition operator.* We
   conjecture that a partial cube is harmonic-even iff, for every Θ-class, the
   transposition swapping the two opposite semicubes extends to a
   measure-preserving involution of the vertex set; consequently the associated
   cut-averaging operator has spectrum symmetric about zero. Equinumerosity of the
   two sides of every cut is exactly the combinatorial precondition for a
   sign-reversing involution, the discrete shadow of a harmonic (mean-value)
   symmetry — hence the name harmonic-even. The equivalence between the matching
   (Helly) formulation and the cardinality (balance) formulation (Theorem 3.1)
   provides the bridge from an existential statement about bijections to a
   quantitative statement about an operator.

4. *Forbidden-factor characterisation of non-harmonic-evenness.* Since balance is
   inherited factor-wise, a product fails harmonic-evenness precisely when it
   contains an unbalanced factor; characterizing the minimal unbalanced building
   blocks (e.g. odd-length paths) would give a forbidden-factor description of the
   non-harmonic-even products.

## 9. Conclusion

For finite partial cubes, the transversal opposite-semicube Helly property and the
metric harmonic-evenness property coincide, and both are exactly multiplicative
under Cartesian products of nonempty factors. Consequently a Cartesian product of
two partial cubes satisfies the opposite-semicube Helly property if and only if
both factors are harmonic-even. The theory is complete, computationally effective,
and modular: perfect balance across every cut is conserved, factor by factor,
under the most basic way of combining discrete worlds.
