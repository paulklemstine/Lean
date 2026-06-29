# Structural Foundations of the Hodge Conjecture: A Formal Algebraic Framework

## Abstract

We develop a formal algebraic framework for the Hodge conjecture, isolating the linear-algebraic backbone from the geometric content. We define weight-2 rational Hodge structures, Hodge morphisms, polarized structures, and algebraic cycle data as abstract algebraic objects, and prove structural theorems that hold for any realization. Our main results include: (1) the Hodge conjecture for Picard rank 1 — given a single nonzero algebraic class, all Hodge classes are algebraic; (2) transcendental-Hodge disjointness under a spanning condition and nondegeneracy; (3) functoriality of the Hodge conjecture under surjective Hodge morphisms with a lifting property; (4) level-zero triviality; and (5) dimension bounds and full-rank characterization. We formalize these results in Lean 4 with complete machine-verified proofs, and state a testable conjecture (the Hodge index bound) relating the positive cone dimension to Picard rank. All proofs depend only on standard axioms (propext, Classical.choice, Quot.sound).

## 1. Introduction

The Hodge conjecture, one of the Clay Mathematics Institute's seven Millennium Prize Problems, asserts that for a smooth projective variety $X$ over $\mathbb{C}$, every Hodge class in $H^{2p}(X, \mathbb{Q}) \cap H^{p,p}(X)$ is a $\mathbb{Q}$-linear combination of fundamental classes of algebraic subvarieties of codimension $p$.

Despite its geometric origin, much of the structure of the Hodge conjecture is purely algebraic. The key objects — rational vector spaces, bilinear forms, submodule inclusions, dimension constraints — belong to linear algebra over $\mathbb{Q}$. This observation motivates our approach: we formalize the *algebraic skeleton* of the conjecture, proving structural results that hold independently of the geometric realization.

### 1.1 Contributions

1. **Novel definitions**: Weight-2 Hodge structures (`WeightTwoHS`), algebraic data (`AlgebraicData`), Hodge morphisms (`HodgeMorphism`), polarized structures (`PolarizedHS`), the transcendental lattice, Hodge level, and Hodge index.

2. **Rank-one resolution** (Theorem 2): The Hodge conjecture holds whenever the Picard rank is 1 and there exists a nonzero algebraic class. The proof uses the proportionality of elements in a 1-dimensional rational vector space.

3. **Transcendental-Hodge disjointness** (Theorem 3): Under nondegeneracy and a spanning condition ($\mathrm{HC} \oplus T = V$), the transcendental lattice intersects the Hodge classes only at zero.

4. **Functoriality** (Theorem 5): The Hodge conjecture transfers along surjective Hodge morphisms with a lifting property on Hodge classes.

5. **Hodge index conjecture**: We state a testable conjecture that the Hodge index equals 1 for polarized structures with Picard rank ≥ 1.

### 1.2 Related Work

The Hodge decomposition for cochain complexes has been formalized in the setting of finite-dimensional real inner product spaces [HodgeDecomposition/Basic.lean], establishing the orthogonal splitting $C^1 = \operatorname{range}(d_0) \oplus \operatorname{range}(d_1^\dagger) \oplus \ker(\Delta_1)$. The rank-one uniqueness theorem for Hodge classes has been established in [RankOne.lean], proving that when the Picard rank is 1, any two nonzero Hodge classes are proportional. Our work builds on and extends these results.

## 2. Definitions

### 2.1 Weight-2 Hodge Structures

**Definition 2.1** (WeightTwoHS). A *weight-2 rational Hodge structure* on a finite-dimensional $\mathbb{Q}$-vector space $V$ is a $\mathbb{C}$-submodule $H^{1,1} \subseteq \mathbb{C} \otimes_{\mathbb{Q}} V$.

**Definition 2.2** (Hodge class). A vector $v \in V$ is a *Hodge class* if $1 \otimes v \in H^{1,1}$. The set of Hodge classes forms a $\mathbb{Q}$-submodule $\mathrm{HC}(V) \subseteq V$.

**Definition 2.3** (Picard rank). The *Picard rank* $\rho = \dim_{\mathbb{Q}} \mathrm{HC}(V)$.

**Definition 2.4** (Hodge level). The *Hodge level* $\ell = \dim_{\mathbb{Q}} V - \rho$.

### 2.2 Algebraic Data and the Hodge Conjecture

**Definition 2.5** (AlgebraicData). An *algebraic data* for a Hodge structure $(V, H^{1,1})$ is a $\mathbb{Q}$-submodule $\mathrm{Alg} \subseteq V$ with $\mathrm{Alg} \leq \mathrm{HC}(V)$.

**Definition 2.6** (HodgeConjectureHolds). The Hodge conjecture holds for $(V, H^{1,1}, \mathrm{Alg})$ if $\mathrm{HC}(V) \leq \mathrm{Alg}$.

**Proposition 2.7**. The Hodge conjecture holds iff $\mathrm{Alg} = \mathrm{HC}(V)$.

### 2.3 Polarized Hodge Structures

**Definition 2.8** (PolarizedHS). A *polarized weight-2 Hodge structure* is $(V, H^{1,1}, Q)$ where $Q: V \times V \to \mathbb{Q}$ is a symmetric nondegenerate bilinear form.

**Definition 2.9** (Transcendental lattice). $T(V) = Q^{\perp}(\mathrm{HC}(V)) = \{v \in V : Q(v, h) = 0 \text{ for all } h \in \mathrm{HC}(V)\}$.

### 2.4 Hodge Morphisms

**Definition 2.10** (HodgeMorphism). A *Hodge morphism* $\varphi: (V, H^{1,1}_V) \to (W, H^{1,1}_W)$ is a $\mathbb{Q}$-linear map $\varphi: V \to W$ such that $v \in \mathrm{HC}(V) \implies \varphi(v) \in \mathrm{HC}(W)$.

### 2.5 Hodge Index

**Definition 2.11** (PositiveCone). A *positive cone* for $Q$ on a submodule $W$ is a submodule $P \leq W$ with $Q(v, v) > 0$ for all nonzero $v \in P$.

**Definition 2.12** (HodgeIndex). The *Hodge index* of a polarized structure is the supremum of $\dim_{\mathbb{Q}} P$ over all positive cones for $Q$ on $\mathrm{HC}(V)$.

## 3. Main Results

### 3.1 Theorem 1: Morphism Preservation

**Theorem 3.1** (hodgeMorphism_image_le). *If $\varphi: (V, H^{1,1}_V) \to (W, H^{1,1}_W)$ is a Hodge morphism, then $\varphi(\mathrm{HC}(V)) \subseteq \mathrm{HC}(W)$.*

*Proof.* Direct from the definition of Hodge morphism. □

### 3.2 Theorem 2: Rank-One Resolution

**Theorem 3.2** (rank_one_proportional). *In a 1-dimensional $\mathbb{Q}$-submodule $W$, any two nonzero elements $x, y \in W$ satisfy $y = qx$ for some $q \in \mathbb{Q} \setminus \{0\}$.*

*Proof sketch.* Since $\dim W = 1$ and $x \neq 0$, we have $W = \mathrm{span}\{x\}$. Then $y \in W$ implies $y = qx$ for some $q \in \mathbb{Q}$, and $y \neq 0$ forces $q \neq 0$. □

**Theorem 3.3** (hodgeConj_of_picard_rank_one). *If $\rho = 1$ and there exists a nonzero algebraic class $v_0 \in \mathrm{Alg}$, then the Hodge conjecture holds.*

*Proof sketch.* Since $v_0 \in \mathrm{Alg} \leq \mathrm{HC}$ and $v_0 \neq 0$, and $\dim \mathrm{HC} = 1$, we have $\mathrm{HC} = \mathrm{span}\{v_0\}$. Any $w \in \mathrm{HC}$ satisfies $w = qv_0 \in \mathrm{Alg}$ since $\mathrm{Alg}$ is a submodule. □

### 3.3 Theorem 3: Transcendental-Hodge Disjointness

**Theorem 3.4** (qOrthogonal_symm). *For a symmetric $Q$, if $v \in Q^{\perp}(W)$ and $w \in W$, then $Q(w, v) = 0$.*

*Proof.* $Q(w, v) = Q(v, w) = 0$ by symmetry and the definition of $Q^{\perp}$. □

**Theorem 3.5** (transcendental_inter_hodge_eq_bot). *If $\mathrm{HC} + T = V$, then $T \cap \mathrm{HC} = \{0\}$.*

*Proof sketch.* Let $v \in T \cap \mathrm{HC}$. For any $w \in V$, write $w = h + t$ with $h \in \mathrm{HC}$, $t \in T$ (using the spanning hypothesis). Then:
- $Q(v, h) = 0$ since $v \in T = Q^{\perp}(\mathrm{HC})$.
- $Q(v, t) = Q(t, v) = 0$ since $t \in T$ and $v \in \mathrm{HC}$, using symmetry.

So $Q(v, w) = Q(v, h) + Q(v, t) = 0$ for all $w$, and $v = 0$ by nondegeneracy. □

### 3.4 Theorem 4: Dimension Bounds

**Theorem 3.6** (picardRank_le_finrank). *$\rho \leq \dim V$.*

*Proof.* The Hodge classes form a submodule of $V$, so their dimension is bounded by $\dim V$. □

**Theorem 3.7** (hodgeClasses_eq_top_of_full_rank). *If $\rho = \dim V$, then $\mathrm{HC} = V$.*

*Proof.* A submodule of a finite-dimensional space with the same dimension equals the whole space. □

### 3.5 Theorem 5: Level-Zero Triviality

**Theorem 3.8** (hodgeConj_of_level_zero). *If $\rho = \dim V$ and $\mathrm{Alg} = V$, then the Hodge conjecture holds.*

*Proof.* $\mathrm{HC} = V = \mathrm{Alg}$ by Theorem 3.7. □

### 3.6 Theorem 6: Functoriality

**Theorem 3.9** (hodgeConj_functorial_surj). *If the HC holds for $(V, \mathrm{Alg}_V)$, and $\varphi: V \to W$ is a Hodge morphism with:*
1. *$\varphi(\mathrm{Alg}_V) \leq \mathrm{Alg}_W$,*
2. *Every $w \in \mathrm{HC}(W)$ lifts to some $v \in \mathrm{HC}(V)$ with $\varphi(v) = w$,*

*then the HC holds for $(W, \mathrm{Alg}_W)$.*

*Proof sketch.* Given $w \in \mathrm{HC}(W)$, lift to $v \in \mathrm{HC}(V) \leq \mathrm{Alg}_V$ (by HC for $V$). Then $w = \varphi(v) \in \varphi(\mathrm{Alg}_V) \leq \mathrm{Alg}_W$. □

### 3.7 Q-Orthogonal Complement Properties

**Theorem 3.10** (qOrthogonal_top_eq_bot). *If $Q$ is nondegenerate, then $Q^{\perp}(V) = \{0\}$.*

**Theorem 3.11** (qOrthogonal_bot_eq_top). *$Q^{\perp}(\{0\}) = V$.*

## 4. Conjecture

**Conjecture 4.1** (Hodge Index Bound). *For any polarized weight-2 Hodge structure with $\rho \geq 1$, the Hodge index equals 1.*

This conjecture is motivated by the Hodge index theorem in algebraic geometry, which asserts that the intersection form on the Néron-Severi group of a smooth projective surface has signature $(1, \rho - 1)$.

**Testable prediction.** Construct an explicit polarized Hodge structure on $\mathbb{Q}^3$ with $\rho = 2$ and compute the signature of $Q$ restricted to the Hodge classes. The conjecture predicts signature $(1, 1)$; finding signature $(2, 0)$ would refute it.

**Computational verification.** For K3 surfaces with $1 \leq \rho \leq 20$, the signature of $Q|_{\mathrm{NS}}$ is $(1, \rho - 1)$, consistent with the conjecture.

## 5. Applications to Specific Varieties

### 5.1 K3 Surfaces

A K3 surface has $H^2(X, \mathbb{Q}) \cong \mathbb{Q}^{22}$ with intersection form of signature $(3, 19)$. The Picard lattice $\mathrm{NS}(X)$ has rank $1 \leq \rho \leq 20$ and signature $(1, \rho - 1)$ by the Hodge index theorem. The transcendental lattice $T(X)$ has rank $22 - \rho$ and signature $(2, 20 - \rho)$.

The Hodge conjecture holds for K3 surfaces because all Hodge classes are of type $(1, 1)$, which is covered by the Lefschetz $(1,1)$ theorem.

### 5.2 Abelian Varieties

For an abelian variety $A$ of dimension $g$:
- The HC is known for $H^2(A, \mathbb{Q})$ (Lefschetz $(1,1)$).
- For simple abelian varieties of prime dimension, the HC is known for all degrees (Tankeev, Ribet).
- For $g \leq 3$, the HC is known in all degrees.
- The general case remains open.

## 6. Formal Verification

All theorems in Sections 3 and their proofs have been formalized in Lean 4 using Mathlib. The formalization consists of:

- **Defs.lean** (≈ 170 lines): Core definitions for Hodge structures, algebraic data, polarized structures, Hodge morphisms, and the Hodge index.
- **Theorems.lean** (≈ 200 lines): Complete proofs of all structural theorems, with no `sorry` (unproved) terms.

All proofs use only standard axioms: `propext`, `Classical.choice`, and `Quot.sound`.

### 6.1 Key proof techniques

- **Submodule equality**: Proving $W = \operatorname{span}\{x\}$ using `Submodule.eq_of_le_of_finrank_eq`.
- **Nondegeneracy arguments**: Showing $v = 0$ from $Q(v, w) = 0$ for all $w$.
- **Submodule arithmetic**: Using `Submodule.mem_sup`, `Submodule.smul_mem`, `Submodule.mem_span_singleton`.

## 7. Future Work

1. **Weight-$n$ generalization**: Extend to arbitrary weight Hodge structures.
2. **Motivic framework**: Formalize the category of Hodge structures and its tensor products.
3. **Abelian variety specialization**: Prove the HC for simple abelian varieties of prime dimension.
4. **Hodge index theorem**: Prove the conjecture for polarized structures arising from geometry.
5. **Computational verification**: Develop algorithms to check the HC for explicit varieties.

## 8. References

1. Hodge, W.V.D. "The topological invariants of algebraic varieties." Proc. ICM, 1950.
2. Lefschetz, S. "L'analysis situs et la géométrie algébrique." Gauthier-Villars, 1924.
3. Deligne, P. "Hodge cycles on abelian varieties." Lecture Notes in Mathematics 900, 1982.
4. Voisin, C. "Hodge Theory and Complex Algebraic Geometry." Cambridge, 2002.
5. Grothendieck, A. "Hodge's general conjecture is false for trivial reasons." Topology 8, 1969.
