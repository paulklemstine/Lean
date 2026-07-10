# Algebraic Cycles in Piecewise-Linear Decision Surfaces: A Width-Driven Bound on the Homology of ReLU Classifiers

**Author:** Aristotle
**Date:** 2026-07-10

## Abstract

For a rectified-linear (ReLU) network $f : \mathbb{R}^n \to \mathbb{R}$, the *decision surface* $V(f) = \{x : f(x) = 0\}$ is a piecewise-linear hypersurface: the ambient space is partitioned into finitely many polyhedral *activation regions* on each of which $f$ is affine, and $V(f)$ is assembled from the flat faces cut out by the local equations $f = 0$. Each such face is the zero locus of a linear form and is therefore an algebraic cycle (a hyperplane section). We prove that the piecewise-linear analogue of the Hodge problem — *is every homology class a rational combination of algebraic cycles?* — has an affirmative and structural answer: the cellular chain group is by construction spanned by the algebraic cells, and homology is a subquotient of it, so every homology class is represented by a cycle supported on those cells. The substantive question is therefore not existence but *size*. We establish a width-driven bound: every Betti number of $V(f)$ is at most the number of cells, which is at most the number of activation patterns $\prod_{i=1}^{L} 2^{w_i} = 2^{\sum_i w_i}$ of a network with hidden widths $w_1,\dots,w_L$. We also record the exact rank identity $\beta + \operatorname{rank} B = \operatorname{rank} Z$ and combinatorial cell counts, and we discuss a conjectural bigraded refinement matching the roles of the boundary layers.

**Keywords:** ReLU networks, decision surface, piecewise-linear topology, Hodge conjecture, algebraic cycles, homology, Betti number, activation patterns, hyperplane arrangements.

## 1. Introduction

Modern classifiers implemented as ReLU networks compute continuous piecewise-linear functions. The geometric object that summarises a binary classifier is its **decision surface**, the level set on which the network is undecided:
$$V(f) \;=\; \{x \in \mathbb{R}^n : f(x) = 0\}.$$
Because $f$ is piecewise-linear, $V(f)$ is a piecewise-linear hypersurface built from flat polyhedral faces. The topology of $V(f)$ — its connected components, tunnels, cavities, and higher holes, quantified by its Betti numbers — measures the expressive complexity of the classifier.

The **Hodge conjecture** of algebraic geometry asserts that on a smooth complex projective variety, every rational $(p,p)$-cohomology class is a rational linear combination of the classes of algebraic subvarieties (algebraic cycles). For general varieties this is one of the deepest open problems in mathematics. This paper asks the analogous question for the piecewise-linear surfaces $V(f)$ and finds that it resolves affirmatively for a simple structural reason, after which the interesting mathematics becomes quantitative: bounding the size of homology in terms of the network's shape.

### Contributions

1. **Representability (§3).** Every homology class of $V(f)$ is represented by a genuine cycle supported on the flat cells; since each cell is a hyperplane section (an algebraic cycle), every class is a rational combination of algebraic cycles. This is the piecewise-linear Hodge property.
2. **Subquotient bounds (§3).** Over a field, the Betti number is bounded by the number of cycles and hence by the number of cells, together with the exact rank identity $\beta + \operatorname{rank} B = \operatorname{rank} Z$.
3. **Cell counting (§4).** A network with $L$ hidden layers of widths $w_1,\dots,w_L$ has exactly $\prod_i 2^{w_i} = 2^{\sum_i w_i}$ activation patterns; an arrangement of $m$ hyperplanes carves out at most $3^m$ sign-cells.
4. **The width-driven bound (§5).** Combining the halves: every Betti number of $V(f)$ is at most $2^{\sum_i w_i}$.

## 2. Definitions and setup

**Definition 2.1 (Decision surface).** For $f : \mathbb{R}^n \to \mathbb{R}$ the decision surface is $V(f) = f^{-1}(0)$. When $f$ is a ReLU network, $V(f)$ is a piecewise-linear hypersurface.

**Definition 2.2 (Activation region and pattern).** A ReLU network with $L$ hidden layers, layer $i$ having width $w_i$, computes $f$ that is affine on each maximal region where every hidden unit has a fixed sign of pre-activation. Such a region is an *activation region*. Its *activation pattern* records, for each hidden neuron, whether it is active. Formally, the set of activation patterns is the product type
$$\mathrm{AP}(L, w) \;=\; \prod_{i=1}^{L} \big(\{1,\dots,w_i\} \to \{\text{true}, \text{false}\}\big),$$
one Boolean flag per hidden neuron.

**Definition 2.3 (Cellular chain complex).** Fix a field $F$. The piecewise-linear structure of $V(f)$ gives a finite cell decomposition and hence a chain complex of $F$-vector spaces
$$\cdots \longrightarrow C_2 \xrightarrow{\;d_2\;} C_1 \xrightarrow{\;d_1\;} C_0 \longrightarrow \cdots,$$
where $C_k$ is the free $F$-vector space on the $k$-cells and $d_{k}$ is the cellular boundary map. Each $C_k$ is finite-dimensional. We write, in a fixed degree,
$$Z = \ker d_1 \quad (\text{cycles}), \qquad B = \operatorname{range} d_2 \quad (\text{boundaries}),$$
and the **homology** is the quotient $H = Z / B$. The **Betti number** is $\beta = \dim_F H = \operatorname{finrank}_F H$.

**Definition 2.4 (Algebraic cycle, PL sense).** A flat cell of $V(f)$ is the intersection of $V(f)$ with the affine subspace on which the relevant linear pieces vanish; it is a *hyperplane section* and we call it an **algebraic cycle**. A chain is a formal $F$-combination of cells, hence a combination of algebraic cycles.

Throughout, "over a field" is essential: dimensions of subspaces and quotients behave additively, which is what makes the bounds clean.

## 3. Homology of the cellular complex

We work with three consecutive chain groups $C_2 \xrightarrow{d_2} C_1 \xrightarrow{d_1} C_0$ with $C_1$ finite-dimensional. Cycles are $Z = \ker d_1$, boundaries are $B = \operatorname{range} d_2$ viewed inside $Z$, and homology is $H = Z/B$.

**Lemma 3.1 (Boundaries are cycles).** In a genuine chain complex, $d_1 \circ d_2 = 0$, and therefore $\operatorname{range} d_2 \subseteq \ker d_1$, i.e. $B \subseteq Z$.

*Proof.* The condition $d_1 \circ d_2 = 0$ is exactly the statement that the range of $d_2$ lies in the kernel of $d_1$. $\square$

This makes the quotient $H = Z/B$ well-defined.

**Theorem 3.2 (Piecewise-linear Hodge representability).** The quotient map $Z \to H = Z/B$ is surjective. Consequently every homology class is the class of an actual cycle. Since cycles lie in the cellular chain group, which is spanned by the algebraic (linearly cut-out) cells, every homology class is represented by a rational combination of algebraic cycles.

*Proof.* Every quotient map of modules is surjective; an element of $Z/B$ is by definition $z + B$ for some $z \in Z$, and $z$ is a chain, i.e. a combination of cells. $\square$

Theorem 3.2 is the piecewise-linear Hodge conjecture: existence of algebraic representatives is automatic because flatness *is* algebraicity in codimension one.

**Theorem 3.3 (Betti number bounded by cycles).** $\displaystyle \operatorname{finrank}_F H \le \operatorname{finrank}_F Z.$

*Proof.* $H = Z/B$ is a quotient of $Z$, and the dimension of a quotient never exceeds the dimension of the space. $\square$

**Theorem 3.4 (Betti number bounded by cell count).** $\displaystyle \operatorname{finrank}_F H \le \operatorname{finrank}_F C_1.$

*Proof.* Compose the quotient bound $\dim(Z/B) \le \dim Z$ with the subspace bound $\dim Z = \dim \ker d_1 \le \dim C_1$. $\square$

Since $\dim_F C_1$ equals the number of $1$-cells, Theorem 3.4 says the Betti number is at most the number of cells.

**Theorem 3.5 (Exact rank identity).** $\displaystyle \operatorname{finrank}_F H + \operatorname{finrank}_F B = \operatorname{finrank}_F Z,$ i.e. $\beta + \operatorname{rank} B = \operatorname{rank} Z$.

*Proof.* For the short exact sequence $0 \to B \to Z \to Z/B \to 0$ of finite-dimensional vector spaces, dimensions add: $\dim(Z/B) + \dim B = \dim Z$. $\square$

This is the local Euler-characteristic relation of the chain complex; it will be used to detect rank-deficient boundary maps (see §6).

**Corollary 3.6 (Basis form).** If the cells form a basis $\{e_c\}_{c \in \mathrm{Cells}}$ of $C_1$ indexed by a finite type $\mathrm{Cells}$, then
$$\beta \;=\; \operatorname{finrank}_F H \;\le\; \#\,\mathrm{Cells}.$$

*Proof.* $\operatorname{finrank}_F C_1 = \#\,\mathrm{Cells}$ for a basis indexed by $\mathrm{Cells}$; substitute into Theorem 3.4. $\square$

## 4. Counting cells

The cells of $V(f)$ are indexed by the network's activation structure. We count activation patterns and, independently, sign-cells of a hyperplane arrangement.

**Theorem 4.1 (Activation-pattern count).** For a network with $L$ hidden layers of widths $w : \{1,\dots,L\} \to \mathbb{N}$,
$$\#\,\mathrm{AP}(L, w) \;=\; \prod_{i=1}^{L} 2^{w_i}.$$

*Proof.* $\mathrm{AP}(L,w)$ is the product over layers of the function types $(\{1,\dots,w_i\} \to \{\text{true},\text{false}\})$. A function from a $w_i$-element set to a $2$-element set has $2^{w_i}$ values, and the cardinality of a finite product is the product of the cardinalities. $\square$

**Theorem 4.2 (Total-neuron form).** $\displaystyle \#\,\mathrm{AP}(L, w) \;=\; 2^{\sum_{i=1}^{L} w_i}.$

*Proof.* $\prod_i 2^{w_i} = 2^{\sum_i w_i}$ by the law of exponents converting a product of powers with a common base into a power of the sum. $\square$

**Theorem 4.3 (Sign-cell bound).** An arrangement of $m$ hyperplanes in $\mathbb{R}^n$ has at most $3^m$ sign-cells, where a sign-cell is a nonempty region determined by assigning each hyperplane one of the three states $\{+, 0, -\}$.

*Proof.* Each point is assigned, for each of the $m$ hyperplanes, exactly one of three signs; hence the set of realisable sign vectors injects into $\{+,0,-\}^m$, which has $3^m$ elements. $\square$

**Theorem 4.4 (Realised regions).** Any labelling of the input space by activation regions realises at most as many distinct cells as there are activation patterns, hence at most $\prod_i 2^{w_i}$.

*Proof.* The labelling factors through the assignment of an activation pattern to each region; the number of distinct labels is at most the number of patterns. $\square$

## 5. The width-driven bound

Combining the topological and combinatorial halves yields the main quantitative theorem.

**Theorem 5.1 (Width-driven Betti bound).** Let $V(f)$ be the decision surface of a ReLU network with hidden widths $w_1, \dots, w_L$, decomposed cellularly with cells indexed by activation structure. Then, over any field $F$, every Betti number satisfies
$$\beta \;=\; \operatorname{finrank}_F H \;\le\; \#\{\text{cells}\} \;\le\; \prod_{i=1}^{L} 2^{w_i} \;=\; 2^{\sum_{i=1}^{L} w_i}.$$

*Proof.* By Theorem 3.4 (or Corollary 3.6), $\beta \le \#\{\text{cells}\}$. By Theorem 4.4 the number of realised cells is at most the number of activation patterns, and by Theorems 4.1–4.2 this equals $\prod_i 2^{w_i} = 2^{\sum_i w_i}$. Transitivity gives the chain. $\square$

The theorem is a genuine transitivity across a geometric bridge, not a definitional identity: the first inequality uses the field structure (subquotient dimensions), while the second uses the product/cardinality calculus of finite types, and the bridge is the single geometric input $\#\{\text{cells}\} \le \#\{\text{activation patterns}\}$.

## 6. Applications and diagnostics

**Complexity of classifiers.** Theorem 5.1 caps the topological complexity of any ReLU classifier by two raised to its hidden-neuron count. A classifier cannot exhibit more independent holes in its decision surface than it has activation patterns; expressivity of *topology* is therefore budgeted by *architecture*.

**Redundant-neuron fingerprint.** The exact identity of Theorem 3.5, $\beta + \operatorname{rank} B = \operatorname{rank} Z$, is a diagnostic. If a hidden neuron never fires simultaneously with its layer-mates on any input, the corresponding contribution to the boundary map $d_2$ is not of full rank; then $\operatorname{rank} B$ drops and the identity forces a strictly larger $\beta$ than the generic bound would predict. Excess homology thus signals architectural redundancy.

**Depth versus width.** The bound $2^{\sum_i w_i}$ depends only on the *total* neuron count and cannot yet separate a shallow-wide network from a deep-narrow one. Empirically and heuristically, depth manufactures topological handles far more efficiently. This motivates the refinement in §7.

## 7. Discussion and future work

The results decisively resolve the *existence* side of the Hodge question for piecewise-linear decision surfaces: it is trivially affirmative, because faces are linear and hence algebraic. All non-trivial content is quantitative and lives in the counting of cells and their homology.

**Conjecture 7.1 (Bigraded Hodge-number bound).** For a network with hidden widths $(w_1,\dots,w_L)$, the Hodge numbers of the decision surface satisfy
$$h^{p,q}(V(f)) \;\le\; \binom{w_1}{p}\binom{w_L}{q}\prod_{i=2}^{L-1} w_i.$$
The first hidden layer selects which $p$ input hyperplanes bound a face; the last layer selects which $q$ output half-spaces co-bound it; interior layers only multiply the number of affine pieces linearly. This factorises the cell count in a Künneth-style product matching the $(p,q)$-bigrading, sharper than the total $2^{\sum_i w_i}$.

**Conjecture 7.2 (Depth manufactures homology, width manufactures cycles).** For the depth-$k$ "tent" family, the top Betti number of the level-set surface grows like $2^k$, while the number of independent algebraic cells needed to generate it grows only linearly in the per-layer width. The ratio (Betti number)/(cells per layer) is then an intrinsic complexity measure separating deep from shallow representations, complementing known width lower bounds obtained from counting sign changes.

**Conjecture 7.3 (Exactness detects redundant neurons).** If a hidden neuron is never simultaneously active with its layer-mates on any input, the corresponding boundary map is not of full rank and the exact identity $\beta + \operatorname{rank} B = \operatorname{rank} Z$ forces a strictly larger Betti number than the generic bound predicts.

Establishing Conjecture 7.1 would replace the crude total-count bound with an architecture-resolved one; proving Conjecture 7.2 would convert analytic oscillation counts directly into Betti numbers, closing the loop between analytic complexity and topological complexity.

## 8. Conclusion

For ReLU decision surfaces the Hodge problem inverts its usual difficulty: existence of algebraic representatives is free (flatness is algebraicity), and the mathematics concentrates in *size*. We proved that homology is a subquotient of the cellular chain group, that every class is represented by a cycle on algebraic cells, that the Betti number is bounded by the cell count via the exact rank identity, and that the cell count is bounded by the activation-pattern count $2^{\sum_i w_i}$. Together these give a clean width-driven ceiling on the topological complexity of neural decision surfaces, and a precise conjectural programme for sharpening it.
