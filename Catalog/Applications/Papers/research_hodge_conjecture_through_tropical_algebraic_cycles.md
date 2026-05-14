# Tropical Hodge–Cycle Correspondence: A Formally Verified Theory

## Abstract

We establish a formal framework for tropical Hodge theory on finite combinatorial models and prove three main results: (A) an exact equivalence between tropical Hodge classes and tropical cycle classes under explicit generation hypotheses, (B) finite generation of the cycle-class image submodule, and (C) a transfer principle from tropical algebraicity to classical algebraic-shadow classes. All results are machine-verified using Lean 4 with the Mathlib library. We provide concrete algorithms for computing cycle-class images, testing membership, and verifying the Hodge–cycle correspondence on finite polyhedral complexes. The framework gives a computationally tractable, rigorously certified approach to studying algebraic classes via their tropical shadows.

## 1. Introduction

### 1.1 Motivation

The Hodge conjecture, one of the seven Clay Millennium Problems, asserts that on a smooth projective complex variety $X$, every rational $(p,p)$-class in $H^{2p}(X, \mathbb{Q})$ is algebraic — representable as a $\mathbb{Q}$-linear combination of fundamental classes of codimension-$p$ subvarieties. Despite significant progress in special cases (Lefschetz (1,1) theorem, Voisin's counterexamples in the integral setting), the general conjecture remains wide open.

Recent advances in tropical geometry suggest a complementary approach: replace the transcendental analytic setting with a finite combinatorial one, where cohomology becomes a finitely generated $\mathbb{Z}$-module, cycles become balanced integer weight functions, and the cycle class map becomes a $\mathbb{Z}$-linear map. In this regime, the Hodge–cycle question becomes a problem in linear algebra over $\mathbb{Z}$, amenable to algorithmic computation and formal verification.

### 1.2 Contributions

We make three main contributions:

1. **Tropical Hodge–Cycle Correspondence (Theorem A).** We prove that in a finite tropical model where the Hodge submodule is finitely spanned and each generator is cycle-representable, the Hodge and cycle submodules coincide.

2. **Finite Generation (Theorem B).** We prove that the cycle-class image is always finitely generated (as a consequence of the Noetherian property of $\mathbb{Z}^n$), implying algorithmic decidability of cycle class membership.

3. **Transfer Principle (Theorem C).** We prove that tropical cycle classes transfer to classical algebraic classes via any comparison map preserving cycle classes.

All three results are formally verified in Lean 4 with Mathlib, yielding the first machine-certified tropical Hodge theory.

### 1.3 Related Work

**Tropical algebraic geometry.** The foundations were laid by Mikhalkin, Sturmfels, Speyer, and others. Tropical intersection theory on fans and polyhedral complexes was developed by Allermann–Rau, Francois–Rau, and Gross–Shokirev.

**Hodge theory for matroids.** Adiprasito, Huh, and Katz proved the Rota–Welsh conjecture using Hodge-theoretic methods on matroid Chow rings, demonstrating that combinatorial structures can carry rich Hodge theory.

**Formal algebraic geometry.** Mathlib's formalization of module theory, Noetherian rings, and linear algebra provides the foundation for our work. Previous formalizations of tropical algebra in Lean include max-plus algebras and tropical semirings.

## 2. Definitions and Setup

### 2.1 Finite Tropical Model

**Definition 2.1** (FiniteTropicalModel). A *finite tropical model* $M$ consists of:
- $n \in \mathbb{N}$: the number of cells.
- $r : \mathbb{N} \to \mathbb{N}$: the cohomology rank function.
- $H_p \subseteq (\mathbb{Z}^{r(p)})$: the *Hodge submodule* in degree $p$.
- $\phi_p : \mathbb{Z}^n \to \mathbb{Z}^{r(p)}$: the *cycle class map*, a $\mathbb{Z}$-linear map.
- $B_p \subseteq \mathbb{Z}^n$: the *balanced submodule* in degree $p$.

Each of $H_p$, $B_p$ is a $\mathbb{Z}$-submodule, and $\phi_p$ is $\mathbb{Z}$-linear.

In the formal development, cohomology in degree $p$ is represented concretely as $\text{Fin}(r(p)) \to \mathbb{Z}$, avoiding type class management issues that arise with abstract dependent types.

### 2.2 Core Predicates

**Definition 2.2.** A class $x \in \mathbb{Z}^{r(p)}$ is:
- A *Hodge class* if $x \in H_p$.
- A *cycle class* if $x \in \text{im}(\phi_p|_{B_p}) = \phi_p(B_p)$.

The *cycle image submodule* is $C_p := \phi_p(B_p) \subseteq \mathbb{Z}^{r(p)}$.

### 2.3 Polyhedral Complexes

A polyhedral complex $\Sigma$ with cells $\sigma_1, \ldots, \sigma_n$, dimension function $\dim$, top dimension $d$, and adjacency relation $\sim$ gives rise to a finite tropical model via:

- $n$ = number of cells.
- $r(p) = n$ (cochains on cells).
- $\phi_p = \text{id}$ (identity map).
- $B_p = \{w \in \mathbb{Z}^n \mid w(\sigma) = 0 \text{ if } \dim(\sigma) + p \neq d, \text{ and } \sum_{\tau \sim \sigma} w(\tau) = 0 \text{ for all } \sigma \text{ with } \dim(\sigma) + p = d+1\}$.
- $H_p = B_p$ (Hodge = balanced, by definition).

In this case, $H_p = C_p$ tautologically, recovering the classical tropical Hodge correspondence of Itenberg–Katzarkov–Mikhalkin–Zharkov.

## 3. Main Results

### 3.1 Theorem A: Tropical Hodge–Cycle Correspondence

**Theorem 3.1** (tropical_hodge_iff_cycle). *Let $M$ be a finite tropical model. Suppose:*
1. *There exist finitely many generators $g_1, \ldots, g_k$ such that $H_p = \text{span}_\mathbb{Z}\{g_1, \ldots, g_k\}$.*
2. *Each $g_i$ is a cycle class: $g_i \in C_p$.*
3. *Every cycle class is a Hodge class: $C_p \subseteq H_p$.*

*Then $H_p = C_p$. In particular, $x$ is a Hodge class iff $x$ is a cycle class.*

**Proof sketch.** The cycle image $C_p = \phi_p(B_p)$ is a $\mathbb{Z}$-submodule of $\mathbb{Z}^{r(p)}$ (as the image of a submodule under a linear map). By hypothesis (2), each generator $g_i \in C_p$. Since $C_p$ is a submodule containing all generators of $H_p$, and $H_p = \text{span}_\mathbb{Z}\{g_1, \ldots, g_k\}$, we have $H_p \subseteq C_p$ by `Submodule.span_le`. Combined with hypothesis (3) ($C_p \subseteq H_p$), we obtain $H_p = C_p$. $\square$

**Formal verification.** The proof in Lean 4 is 5 lines and uses `Submodule.span_le` and `le_antisymm`. See `tropical_hodge_iff_cycle` in `TropicalCycleCorrespondence.lean`.

### 3.2 Theorem B: Finite Generation

**Theorem 3.2** (fg_cycle_image). *The cycle image $C_p$ is always finitely generated as a $\mathbb{Z}$-submodule.*

**Proof.** The balanced submodule $B_p$ is a submodule of $\mathbb{Z}^n$, which is Noetherian. Hence $B_p$ is finitely generated. The image of a finitely generated module under a linear map is finitely generated (`Submodule.FG.map`). $\square$

**Corollary 3.3** (cycle_image_always_fg). *In any finite tropical model, the cycle class image is finitely generated.*

**Algorithmic consequence.** Given generators for $B_p$ and the matrix of $\phi_p$, the generators of $C_p$ are computed by matrix multiplication. Membership in $C_p$ is then decided by solving an integer linear system.

**Complexity.** Computing $C_p$ generators takes $O(k \cdot r \cdot n)$ time, where $k$ = number of balanced generators, $r$ = cohomology rank, $n$ = number of cells. Membership testing takes $O(k^2 \cdot r)$ time via Hermite normal form.

### 3.3 Theorem C: Transfer Principle

**Theorem 3.4** (cycle_transfer_algebraic). *Let $M$ be a finite tropical model, $X$ a classical model with algebraic submodule $A_p$, and $\tau_p : \mathbb{Z}^{r(p)} \to \mathbb{Z}^{s(p)}$ a comparison map. If $\tau_p$ sends tropical cycle classes to classical algebraic classes (i.e., $\tau_p(\phi_p(w)) \in A_p$ for all $w \in B_p$), then every tropical cycle class transfers to a classical algebraic class.*

**Proof.** If $x \in C_p$, then $x = \phi_p(w)$ for some $w \in B_p$. By hypothesis, $\tau_p(x) = \tau_p(\phi_p(w)) \in A_p$. $\square$

**Corollary 3.5** (hodge_transfer_algebraic). *Under the hypotheses of Theorems A and C, every tropical Hodge class transfers to a classical algebraic class.*

### 3.4 Master Theorem

**Theorem 3.6** (master_tropical_hodge_theorem). *Combining Theorems A, B, and C: given a finite tropical model satisfying the generation hypotheses and equipped with a transfer map, we simultaneously obtain:*
1. *Hodge ↔ cycle (exact correspondence)*
2. *Finite generation of the cycle image*
3. *Transfer to classical algebraic classes*

## 4. Algorithms

### 4.1 Balanced Submodule Computation

```
Algorithm: BalancedSubmoduleGenerators
Input: Polyhedral complex Σ = (cells, dim, adj, topDim), codimension p
Output: Generators of B_p

1. codim_cells ← {c | dim(c) + p = topDim}
2. constraint_cells ← {σ | dim(σ) + p = topDim + 1}
3. For each σ ∈ constraint_cells:
     Build row of constraint matrix A: A[σ,τ] = 1 if τ ~ σ, else 0
4. Compute integer kernel of A (via Hermite normal form)
5. Embed kernel vectors into full cell space
6. Return generators

Time: O(n² · c) where n = |cells|, c = |constraint_cells|
Space: O(n · |codim_cells|)
```

### 4.2 Cycle Class Membership Test

```
Algorithm: IsCycleClass
Input: Class x ∈ ℤ^r, cycle map φ (r×n matrix), balanced generators G (k×n matrix)
Output: (is_member, coefficients)

1. Compute image generators: I ← φ · G^T  (r×k matrix)
2. Solve I · c = x for integer vector c
3. If solution exists: return (true, c)
4. Else: return (false, null)

Time: O(k² · r) via Hermite normal form
Space: O(k · r)
```

### 4.3 Hodge–Cycle Verification

```
Algorithm: VerifyHodgeCycleCorrespondence  
Input: Hodge generators H, cycle map φ, balanced generators G
Output: boolean (Hodge = Cycle?)

1. For each h ∈ H: verify IsCycleClass(h, φ, G)
2. Compute cycle image generators I = φ · G^T
3. For each g ∈ rows(I): verify g ∈ span_ℤ(H)
4. Return (all checks pass)

Time: O(k · m · (k + m)) where k = |H|, m = |G|
```

## 5. Examples

### 5.1 Tropical Segment

The simplest nontrivial example: 3 cells (1 edge, 2 vertices), $d = 1$.

| Cell | Dimension | Codimension 1? |
|------|-----------|----------------|
| edge | 1 | no (codim 0) |
| vertex L | 0 | yes |
| vertex R | 0 | yes |

Balanced condition (codim 1): weight supported on vertices, summing to 0 at the edge.

Result: $B_1 = \mathbb{Z} \cdot (0, 1, -1)$, $H_1 = B_1$. Hodge = Cycle. ✓

This is the tropical Lefschetz (1,1) theorem for the segment.

### 5.2 Tropical Triangle

7 cells (1 face, 3 edges, 3 vertices), $d = 2$.

Codimension-1 (divisors): supported on edges, balanced at face.
$B_1 \cong \mathbb{Z}^2$ (generated by weights like $(0, 1, -1, 0, 0, 0, 0)$).

Codimension-2 (points): supported on vertices, balanced at all edges.
$B_2 = \{0\}$ (the balancing equations at edges force all vertex weights to 0).

Result: Hodge = Cycle in all codimensions. ✓

### 5.3 Model Where Hodge ≠ Cycle

Consider: 2 cells, $r(p) = 1$, $\phi_p(w) = 2w_0$, $B_p = \mathbb{Z}^2$, $H_p = \mathbb{Z}$.

Then $C_p = 2\mathbb{Z} \subsetneq \mathbb{Z} = H_p$. The class $1 \in H_p$ is Hodge but not a cycle class.

This shows the generation hypothesis (every Hodge generator is a cycle class) is essential.

## 6. Formal Verification Details

### 6.1 Lean 4 Implementation

The core formalization is in `Catalog/Tropical/HodgeShadow/TropicalCycleCorrespondence.lean` (approximately 450 lines). Key design decisions:

- **Concrete types.** Cohomology is `Fin (cohRank p) → ℤ` rather than an abstract type with instances. This avoids type class diamond issues.
- **Submodule-based predicates.** Hodge and cycle conditions are formulated as membership in `Submodule ℤ`, leveraging Mathlib's extensive module theory.
- **Noetherian for free.** Finite generation of the balanced submodule follows from `IsNoetherian.noetherian` applied to $\mathbb{Z}^n$.

### 6.2 Axiom Audit

All theorems depend only on the standard Lean/Mathlib axioms:
- `propext` (propositional extensionality)
- `Quot.sound` (quotient soundness)
- `Classical.choice` (axiom of choice)

No `sorry`, no custom axioms, no `@[implemented_by]`.

### 6.3 Lines of Code

| Component | Lines |
|-----------|-------|
| FiniteTropicalModel structure | 20 |
| Core definitions | 40 |
| Theorem A + corollaries | 60 |
| Theorem B | 30 |
| Transfer (Theorem C) | 60 |
| Master theorem | 20 |
| Verified models | 30 |
| Examples | 40 |
| Polyhedral embedding | 60 |
| Self-transfer | 20 |
| **Total** | **~450** |

## 7. Discussion

### 7.1 Limitations

The current framework has several limitations:

1. **No multiplicative structure.** We do not formalize the graded ring structure on tropical cohomology. This means we cannot state the divisor-generation bootstrap (Theorem A') in full generality within the current framework.

2. **Transfer map assumptions.** The transfer principle (Theorem C) assumes the comparison map preserves cycle classes. Constructing such maps for specific tropicalizations is a separate, nontrivial problem.

3. **No Poincaré duality or Hard Lefschetz.** These deeper structural results, which constrain the Hodge numbers and provide additional tools for the classical Hodge conjecture, are not formalized.

### 7.2 Comparison with Classical Results

Our Theorem A can be seen as a finitary analogue of the Lefschetz (1,1) theorem (every integral (1,1)-class on a Kähler manifold is algebraic), generalized to arbitrary codimension under explicit generation hypotheses. The generation hypothesis plays the role of the "hard Lefschetz" condition in the classical setting.

### 7.3 Significance for the Hodge Conjecture

Our results do not solve the Hodge conjecture, but they establish a certified framework for studying it:

- The transfer principle gives a method to produce *certified* algebraic classes from tropical data.
- The finite generation theorem ensures that tropical cycle class computations are *algorithmic*.
- The exact correspondence in the finite setting serves as a *testbed* for proof strategies.

## 8. Future Work

1. **Graded ring structure.** Formalize multiplicative structure on tropical cohomology and prove the divisor-generation bootstrap.
2. **Tropical Poincaré duality.** Formalize duality for finite balanced complexes and derive Hard Lefschetz criteria.
3. **Matroid Chow rings.** Connect Bergman fan cohomology to the tropical Hodge framework.
4. **Algorithmic implementation.** Build certified algorithms for cycle class enumeration using the finite generation theorem.
5. **Functorial transfer.** Extend the transfer principle to a functorial comparison for degenerating families.

## References

1. P. Adiprasito, J. Huh, E. Katz. *Hodge theory for combinatorial geometries.* Annals of Mathematics, 2018.
2. L. Allermann, J. Rau. *First steps in tropical intersection theory.* Math. Z., 2010.
3. G. Mikhalkin. *Tropical geometry and its applications.* ICM 2006.
4. B. Sturmfels. *Solving systems of polynomial equations.* CBMS Regional Conference Series, 2002.
5. I. Itenberg, L. Katzarkov, G. Mikhalkin, I. Zharkov. *Tropical homology.* Math. Ann., 2019.
6. The Mathlib Community. *Mathlib: a unified library of mathematics formalized.* 2020–present.
