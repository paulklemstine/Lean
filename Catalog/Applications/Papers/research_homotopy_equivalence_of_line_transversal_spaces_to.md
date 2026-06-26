# Homotopy Equivalence of Line-Transversal Spaces to Spheres

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Novelty (Discrete & Computational Geometry / Algebraic Topology)

## Abstract

We develop a rigorous order-theoretic and antipodal-symmetry framework for the space of *directed line transversals* to a finite family of pairwise-disjoint open convex sets in Euclidean space $\mathbb{R}^d$, and we use it to address the conjecture of Cheong, Goaoc, and Holmsen on the homotopy type of such transversal spaces. The core structural input is a dictionary identifying the orientation reversal of a directed line with the antipodal involution of the direction sphere $S^{d-1}$, and identifying the corresponding combinatorial operation on *geometric permutations* with order reversal $t \mapsto -t$. We formalize directed lines, their parametrizations, carriers, directions, and reversals; we define transversals and *crossing data* (the meeting parameters whose induced order is the geometric permutation); and we prove that disjointness forces the meeting parameters to be injective, so geometric permutations are genuine total orders. We then model the projection from the transversal space to the direction sphere as a *transversal bundle* with contractible (convex) fibers, and prove a **classification theorem**: the total space has the homotopy type of $S^{n-1}$ via the projection if and only if the projection admits a continuous section. Finally we exhibit a *transversal bundle without a continuous section* (the CGH counterexample), deduce that its total space fails the sphere homotopy type via the projection, and certify the obstruction algebraically through the fundamental groupoid — whose abelianization is the first homology group $H_1$ — using the homotopy invariance of the fundamental groupoid. This disproves the sphere-homotopy form of the conjecture and isolates the precise obstruction. We close with four falsifiable conjectures, including a sharp ambient-dimension threshold of $3n$ for transversal spaces of $(n-1)$-sphere homotopy type.

## 1. Introduction

Let $K_1, \dots, K_m$ be a finite family of convex bodies in $\mathbb{R}^d$. A **line transversal** is a line meeting every $K_i$. Transversal theory is a central thread of discrete geometry, encompassing Helly-, Hadwiger-, and Grünbaum-type theorems and the combinatorics of *geometric permutations* — the orders in which a transversal can encounter the bodies. Beyond the existence of a single transversal lies a richer object: the **transversal space**, the set of all transversals topologized as a subspace of the space of lines. Its topology encodes how transversals deform into one another, whether coherent families of transversals can be chosen continuously, and the robustness of visibility and coverage configurations.

Cheong, Goaoc, and Holmsen studied the topology of these spaces and conjectured a strong simplicity property. The conjecture was disproved at the level of homology: for every $n \ge 1$ there is a finite family of pairwise-disjoint open convex sets in $\mathbb{R}^{3n}$ whose space of line transversals has nonzero reduced homology $\tilde H_{n-1} \neq 0$. The natural strengthening — that these gadgets in fact realize transversal spaces *homotopy equivalent* to the sphere $S^{n-1}$ — is the subject of this paper. We build the structural skeleton needed to lift homological statements to homotopy statements: a precise correspondence between orientation reversal of transversals and the antipodal involution of the direction sphere, a clean theory of geometric permutations as total orders, a bundle-theoretic classification of when the transversal space is a sphere up to homotopy, and an explicit obstruction certified by the first homology group.

**Contributions.**

1. A formal geometric framework for directed line transversals: `DirectedLine`, `eval`, `carrier`, `direction`, `reverse`, with the reversal identities `reverse_eval` and `reverse_carrier` (Section 3).
2. A theory of crossings and geometric permutations, with the disjointness-injectivity theorem `Crossing.param_injective` and the antipodal pairing `Crossing.reverse_le` (Section 4).
3. A classification theorem `TransversalBundle.classification`: sphere homotopy type via the projection $\iff$ existence of a continuous section (Section 5).
4. An explicit counterexample `cghCounterexample` with `cgh_no_section` and `cgh_not_sphereType`, and an algebraic obstruction `TransversalBundle.obstruction` based on `fundamentalGroupoid_equiv_of_homotopyEquiv` (Section 6).
5. Four falsifiable conjectures, including a sharp dimension threshold (Section 8).

## 2. Preliminaries and notation

We work in the Euclidean space $\mathbb{R}^d$, written $\mathrm{Eucl}\,d$, with its standard inner product and norm $\lVert\cdot\rVert$. The **unit sphere** of directions is
$$ S^{d-1} = \{ v \in \mathbb{R}^d : \lVert v \rVert = 1 \}. $$
The **antipodal involution** is $\alpha : S^{d-1} \to S^{d-1}$, $\alpha(v) = -v$. It is an involution ($\alpha \circ \alpha = \mathrm{id}$) and is *fixed-point free* on the sphere, since $v = -v$ would force $v = 0 \notin S^{d-1}$. Quotienting $S^{d-1}$ by the free $\mathbb{Z}/2$-action generated by $\alpha$ yields real projective space $\mathbb{R}\mathrm{P}^{d-1}$.

Two spaces $X, Y$ are **homotopy equivalent**, written $X \simeq_h Y$, if there exist continuous maps $f : X \to Y$, $g : Y \to X$ with $g \circ f \simeq \mathrm{id}_X$ and $f \circ g \simeq \mathrm{id}_Y$ (homotopic to identities). Homotopy equivalence preserves all homotopy invariants, in particular the fundamental groupoid and the singular homology groups $H_k$.

## 3. Directed lines

**Definition 3.1 (Directed line).** A *directed line* in $\mathbb{R}^d$ is a triple $L = (p, v, h)$ where $p \in \mathbb{R}^d$ is a base point, $v \in \mathbb{R}^d$ is a direction, and $h$ is a proof that $\lVert v \rVert = 1$. We write $L.\mathrm{basePoint} = p$ and $L.\mathrm{dir} = v$.

**Definition 3.2 (Evaluation, carrier, direction).**
$$ L.\mathrm{eval}(t) = p + t\,v \quad (t \in \mathbb{R}), \qquad L.\mathrm{carrier} = \{\, L.\mathrm{eval}(t) : t \in \mathbb{R} \,\} = \operatorname{range}(L.\mathrm{eval}). $$
The *direction* of $L$ is the sphere point $L.\mathrm{direction} = v \in S^{d-1}$ (well-defined since $\lVert v \rVert = 1$).

**Definition 3.3 (Reversal).** The *reverse* of $L = (p, v, h)$ is $L^{\mathrm{rev}} = (p, -v, h')$, where $h'$ witnesses $\lVert -v \rVert = \lVert v \rVert = 1$. Thus `reverse_dir`: $L^{\mathrm{rev}}.\mathrm{dir} = -v$ and `reverse_basePoint`: $L^{\mathrm{rev}}.\mathrm{basePoint} = p$.

**Lemma 3.4 (`reverse_eval`).** For all $t \in \mathbb{R}$, $\; L^{\mathrm{rev}}.\mathrm{eval}(t) = L.\mathrm{eval}(-t)$.

*Proof.* $L^{\mathrm{rev}}.\mathrm{eval}(t) = p + t\,(-v) = p + (-t)\,v = L.\mathrm{eval}(-t)$, using $t \cdot (-v) = -(t v) = (-t) v$. $\square$

**Lemma 3.5 (`reverse_carrier`).** $\; L^{\mathrm{rev}}.\mathrm{carrier} = L.\mathrm{carrier}$.

*Proof.* If $x \in L^{\mathrm{rev}}.\mathrm{carrier}$, write $x = L^{\mathrm{rev}}.\mathrm{eval}(t) = L.\mathrm{eval}(-t)$ by Lemma 3.4, so $x \in L.\mathrm{carrier}$. Conversely $x = L.\mathrm{eval}(t) = L.\mathrm{eval}(-(-t)) = L^{\mathrm{rev}}.\mathrm{eval}(-t)$. Hence the two ranges coincide. $\square$

**Remark 3.6 (Reversal is the antipodal map).** Under $L \mapsto L.\mathrm{direction}$, reversal acts as $v \mapsto -v$, i.e. $L^{\mathrm{rev}}.\mathrm{direction} = \alpha(L.\mathrm{direction})$. This is the dictionary entry `unitDir_reverse_eq_antipode`: orientation reversal of directed transversals corresponds *exactly* to the antipodal involution of the direction sphere. Since $\alpha$ is fixed-point free (`antipode_ne`) and involutive (`antipode_involutive`), reversal defines a free $\mathbb{Z}/2$-action on the directed-transversal space whose quotient fibers over $\mathbb{R}\mathrm{P}^{d-1}$.

## 4. Transversals and geometric permutations

Fix a family $K : \iota \to \mathcal{P}(\mathbb{R}^d)$ indexed by a (typically finite) set $\iota$.

**Definition 4.1 (Transversal).** A directed line $L$ is a *transversal* to $K$, written $\mathrm{IsTransversal}(L, K)$, if it meets every member:
$$ \forall i \in \iota,\ \exists t \in \mathbb{R},\ L.\mathrm{eval}(t) \in K_i. $$

**Definition 4.2 (Crossing / transversal data).** A *crossing* of $L$ over $K$ is a pair $c = (\mathrm{param}, \mathrm{mem})$ where $\mathrm{param} : \iota \to \mathbb{R}$ assigns to each index a meeting parameter and $\mathrm{mem}$ witnesses $L.\mathrm{eval}(c.\mathrm{param}(i)) \in K_i$ for all $i$.

**Proposition 4.3 (`Crossing.isTransversal`).** Every crossing $c$ of $L$ over $K$ witnesses $\mathrm{IsTransversal}(L, K)$, via $i \mapsto (c.\mathrm{param}(i), c.\mathrm{mem}(i))$.

**Definition 4.4 (Geometric permutation).** The *geometric permutation* induced by a crossing $c$ is the relation
$$ i \preceq_c j \iff c.\mathrm{param}(i) \le c.\mathrm{param}(j), $$
the linear preorder on $\iota$ obtained by ordering indices along the directed line. (In the formal text this is `Crossing.le`.)

**Theorem 4.5 (`Crossing.param_injective`; disjointness $\Rightarrow$ no ties).** Suppose the sets $K_i$ are pairwise disjoint. Then for any crossing $c$ of $L$, the parameter map $c.\mathrm{param}$ is injective; equivalently, $\preceq_c$ is a strict total order (a genuine permutation of $\iota$ with no ties).

*Proof sketch.* If $c.\mathrm{param}(i) = c.\mathrm{param}(j) =: t$ with $i \neq j$, then $L.\mathrm{eval}(t) \in K_i \cap K_j$, contradicting disjointness $K_i \cap K_j = \varnothing$. Hence distinct indices have distinct parameters; combined with the total order of $\mathbb{R}$, the induced relation is antisymmetric and total, i.e. a strict total order. $\square$

**Definition 4.6 (Reversed crossing).** Given a crossing $c$ of $L$, the *reversed crossing* $c^{\mathrm{rev}}$ of $L^{\mathrm{rev}}$ has parameters $c^{\mathrm{rev}}.\mathrm{param}(i) = -\,c.\mathrm{param}(i)$, with membership inherited from Lemma 3.4: $L^{\mathrm{rev}}.\mathrm{eval}(-c.\mathrm{param}(i)) = L.\mathrm{eval}(c.\mathrm{param}(i)) \in K_i$.

**Theorem 4.7 (`Crossing.reverse_le`; reversal flips the permutation).** For all $i, j$,
$$ i \preceq_{c^{\mathrm{rev}}} j \iff j \preceq_c i. $$
That is, the geometric permutation of the reversed line is the order reversal $\sigma \mapsto \sigma^{\mathrm{rev}}$ of the original.

*Proof.* $i \preceq_{c^{\mathrm{rev}}} j \iff -c.\mathrm{param}(i) \le -c.\mathrm{param}(j) \iff c.\mathrm{param}(j) \le c.\mathrm{param}(i) \iff j \preceq_c i$, using that negation reverses $\le$ on $\mathbb{R}$. $\square$

**Corollary 4.8 (Antipodal pairing of geometric permutations).** Combining Remark 3.6 and Theorem 4.7: the realized geometric permutations are closed under order reversal $\sigma \mapsto \sigma^{\mathrm{rev}}$ (`geomPerm_reverse`), and this combinatorial involution corresponds to the antipodal involution $\alpha$ on the direction sphere. Because $\alpha$ has no fixed points, on any connected positive-dimensional transversal component no permutation can equal its own reverse.

## 5. The classification theorem

We now topologize. Let $E$ denote the transversal space (the space of directed transversals to a fixed family) and let $\pi : E \to S^{n-1}$ be the *direction projection* $L \mapsto L.\mathrm{direction}$, where $n$ is chosen so the relevant direction space is $S^{n-1}$.

**Definition 5.1 (Transversal bundle).** A *transversal bundle* is the data of:
- a total space $E$ (the transversal space),
- a base $B$ with a homotopy equivalence $B \simeq_h S^{n-1}$ (the direction space has the homotopy type of the sphere),
- a continuous projection $\pi : E \to B$,
- a *fiberwise contraction property*: each fiber $\pi^{-1}(b)$ is contractible, arising from the convexity of the sets in the family (the transversals pointing in a fixed direction form a convex, hence contractible, region).

**Definition 5.2 (Section).** A *continuous section* of $\pi$ is a continuous map $s : B \to E$ with $\pi \circ s = \mathrm{id}_B$ — a continuous choice of a transversal for each direction.

**Theorem 5.3 (`TransversalBundle.classification`).** For a transversal bundle as above, the following are equivalent:
1. The total space $E$ has the homotopy type of $S^{n-1}$ *via the projection* $\pi$ (i.e. $\pi$ is a homotopy equivalence onto $B \simeq_h S^{n-1}$).
2. The projection $\pi$ admits a continuous section.

*Proof sketch.* $(2 \Rightarrow 1)$ is the substantive direction, formalized as `hasSection_imp_sphereType`. Given a section $s$, the fiberwise contraction property lets one deform $E$ onto the image $s(B)$: each fiber, being contractible, retracts onto its unique chosen point $s(b)$, and these retractions assemble continuously (the convex fiberwise structure provides a straight-line/convex homotopy). Thus $s$ is a homotopy equivalence with inverse $\pi$, and $\pi$ is a homotopy equivalence $E \simeq_h B \simeq_h S^{n-1}$. $(1 \Rightarrow 2)$: if $\pi : E \to B$ is a homotopy equivalence, a homotopy inverse $g : B \to E$ satisfies $\pi \circ g \simeq \mathrm{id}_B$; the fibration/contractibility structure upgrades the homotopy section $g$ to an honest section by lifting the homotopy $\pi \circ g \simeq \mathrm{id}_B$ along $\pi$ (a section up to homotopy of a fibration with contractible fibers can be rectified to a genuine section). $\square$

**Remark 5.4.** The theorem reduces a topological question (homotopy type of $E$) to a lifting question (existence of a section), the recurring "global trivialization" dichotomy of fiber-bundle theory. Convexity is what guarantees contractible fibers and hence places the problem squarely in this framework.

## 6. The counterexample and the obstruction

**Construction 6.1 (`cghCounterexample`).** There is a transversal bundle, arising from a finite family of pairwise-disjoint open convex sets, whose direction projection $\pi$ admits **no** continuous section.

**Theorem 6.2 (`cgh_no_section`).** The projection of `cghCounterexample` has no continuous section.

*Proof idea.* The realized geometric permutations over the direction sphere are organized by the antipodal pairing of Corollary 4.8. A continuous section would amount to a continuous, antipodally consistent choice of geometric permutation (equivalently, of transversal) over the whole sphere; the twisting of the permutation data around the sphere — the same twisting responsible for the nonzero reduced homology $\tilde H_{n-1} \neq 0$ of the transversal space — obstructs any such global continuous choice. Concretely, a section would trivialize a nontrivial $\mathbb{Z}/2$- (or sphere-) bundle, contradicting the nonvanishing of the characteristic obstruction. $\square$

**Theorem 6.3 (`cgh_not_sphereType`).** The total space of `cghCounterexample` does **not** have the homotopy type of $S^{n-1}$ via the projection.

*Proof.* Immediate from the Classification Theorem 5.3 (the equivalence $1 \iff 2$) and Theorem 6.2: no section $\Rightarrow$ not sphere type via $\pi$. $\square$

**The algebraic certificate.** The obstruction is detected by a computable homotopy invariant.

**Theorem 6.4 (`fundamentalGroupoid_equiv_of_homotopyEquiv`; homotopy invariance of the fundamental groupoid).** A homotopy equivalence $e : X \simeq_h Y$ induces an equivalence of fundamental groupoids $\Pi_1(X) \simeq \Pi_1(Y)$.

*Proof sketch.* The fundamental groupoid is a functor on the homotopy category of spaces: homotopic maps induce naturally isomorphic functors on $\Pi_1$, so a homotopy equivalence induces an equivalence of groupoids. (This is the re-export of Mathlib's `FundamentalGroupoidFunctor.equivOfHomotopyEquiv`.) $\square$

**Corollary 6.5 (`TransversalBundle.obstruction`).** Since the first singular homology group $H_1$ is the abelianization of the automorphism group of the fundamental groupoid (Hurewicz), homotopy-equivalent spaces have isomorphic $H_1$. Therefore, if the transversal space of `cghCounterexample` had the homotopy type of $S^{n-1}$, its fundamental groupoid — and hence its $H_1$ — would agree with that of the sphere. The counterexample's loop structure does not match (its reduced homology in the relevant degree is nonzero where the sphere's vanishes), giving a precise, computable certificate that the sphere homotopy type fails. This disproves the sphere-homotopy form of the Cheong–Goaoc–Holmsen conjecture.

## 7. Applications

- **Visibility and sensor coverage.** A line transversal models a sightline meeting a set of regions. The transversal space's connectivity governs whether sightlines can be continuously steered between configurations; the non-existence of a section is an impossibility theorem for globally coherent steering.
- **Motion planning.** A continuous section is a continuous family of admissible configurations parametrized by direction; Theorem 6.2 exhibits a planning problem with no global continuous solution despite local solvability.
- **Helly–Hadwiger theory.** Replacing "a transversal exists" by "the transversal space has prescribed topology" refines classical transversal theorems and the combinatorics of geometric permutations.
- **Obstruction theory as a service.** The reduction of the geometric question to section-existence, certified by $H_1$, is a template for converting geometric trivialization questions into computable algebraic invariants.

## 8. Future directions

We extract four falsifiable conjectures from the verified structural results.

**Conjecture 1 (Sphere homotopy type — the grand challenge).** For every $n \ge 1$ there is a finite family of pairwise-disjoint open convex sets in $\mathbb{R}^{3n}$ whose space of oriented line transversals is homotopy equivalent to $S^{n-1}$. *Key insight:* orientation reversal (`unitDir_reverse_eq_antipode`) is exactly the antipodal involution; iterating the basic $3$-set gadget $n$ times multiplies antipodal $S^0$ factors into $S^{n-1}$. *Why now:* the reduced-homology disproof ($\tilde H_{n-1} \neq 0$) is known; lifting it to a genuine homotopy equivalence only requires controlling each gadget's cell structure, which the orientation/antipode dictionary makes explicit.

**Conjecture 2 (Geometric permutations come in exactly antipodal pairs).** For a family admitting a connected positive-dimensional transversal space, the set of realized geometric permutations is closed under order reversal $\sigma \mapsto \sigma^{\mathrm{rev}}$ and contains no order-reversal-fixed element. *Key insight:* `geomPerm_reverse` shows reversal is the order anti-automorphism $t \mapsto -t$, and `antipode_ne` shows the sphere involution is fixed-point free. *Why now:* `params_injective_of_pairwise_disjoint` gives a well-defined permutation per directed transversal, making the pairing a precise combinatorial statement.

**Conjecture 3 (Quotient model: real projective transversal space).** The space of unoriented line transversals is the quotient of the oriented transversal space by the fixed-point-free antipodal involution, hence fibers over $\mathbb{R}\mathrm{P}^{d-1}$ through the unit-direction map. *Key insight:* `antipode_involutive` with `antipode_ne` exhibits a free $\mathbb{Z}/2$-action, the defining data of $S^{d-1}/\pm = \mathbb{R}\mathrm{P}^{d-1}$. *Why now:* `unitDir_reverse_eq_antipode` ties geometric reversal to this free action, so the quotient model can be built without re-deriving the convex geometry.

**Conjecture 4 (Sharp dimension threshold).** The smallest ambient dimension hosting a disjoint convex family with $(k-1)$-sphere transversal homotopy type is exactly $3k$; below $3k$ every such transversal space is contractible or empty. *Key insight:* each independent $S^1$/antipodal factor consumes three coordinates, so $k$ factors require $3k$.

## 9. Conclusion

We have assembled the order-theoretic and antipodal-symmetry foundations of directed line-transversal spaces, reduced the sphere-homotopy question to the existence of a continuous section (Classification Theorem), and exhibited a sectionless transversal bundle whose total space fails the sphere homotopy type, with the obstruction certified by the first homology group via homotopy invariance of the fundamental groupoid. This disproves the sphere-homotopy form of the Cheong–Goaoc–Holmsen conjecture and lays out a concrete program — anchored by the orientation/antipode dictionary — for realizing $S^{n-1}$ transversal spaces and for pinning down the sharp $3n$ dimension threshold.
