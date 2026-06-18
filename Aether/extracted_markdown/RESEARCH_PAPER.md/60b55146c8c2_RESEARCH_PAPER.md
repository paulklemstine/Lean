# Phantom Topologies: Observer-Dependent Topological Spaces

## Abstract

We introduce *phantom topologies*, a framework for studying topological spaces where the topology depends on the observer. A phantom topology on a set $X$ assigns to each observer $o \in O$ a topology $T(o)$ on $X$. The *consensus topology* — the coarsest topology that all observers are finer than — captures "objective reality" as the intersection of all observers' open set families. We prove fundamental structural results: the discrete topology is phantom-irreducible (cannot be decomposed into strictly finer observers), the indiscrete topology on any nontrivial type admits a 2-observer strict decomposition, and every strict decomposition requires at least 2 observers. Our proofs are fully formalized in Lean 4 with Mathlib.

## 1. Introduction

The topology of a mathematical space is traditionally considered an intrinsic, observer-independent property. We propose a framework where different observers may perceive different topologies on the same underlying set, and the "real" topology emerges from their consensus.

**Motivation.** The idea draws from several sources:
- **Quantum mechanics**: The state of a system depends on measurement, and different observables may be incompatible.
- **Epistemology**: Objective knowledge is often defined as intersubjective agreement.
- **Lattice theory**: The lattice of topologies on a fixed set is a complete lattice with rich structure.

**Lattice conventions.** Throughout, we work with Mathlib's convention where $t_1 \leq t_2$ means $t_1$ is *finer* (has more open sets). Thus $\bot$ = discrete (finest) and $\top$ = indiscrete (coarsest). The consensus topology $\bigvee_o T(o)$ (supremum in this lattice) is the coarsest topology that all observers are finer than.

## 2. Definitions

**Definition 2.1 (Phantom Topology).** A *phantom topology* on a type $X$ indexed by observers $O$ is a function $T : O \to \text{TopologicalSpace}(X)$.

**Definition 2.2 (Consensus Topology).** The *consensus topology* of a phantom topology $T$ is $\text{consensus}(T) = \bigvee_{o \in O} T(o)$.

**Definition 2.3 (Phantom Agreement).** A set $U \subseteq X$ is in *phantom agreement* if $\forall o \in O, U \text{ is open in } T(o)$.

**Definition 2.4 (Strict Phantom Decomposition).** A *strict phantom decomposition* of a topology $\tau$ consists of:
- A nonempty type $\text{Obs}$
- A function $\text{topo} : \text{Obs} \to \text{TopologicalSpace}(X)$
- $\forall o, \text{topo}(o) < \tau$ (each observer is strictly finer)
- $\bigvee_o \text{topo}(o) = \tau$ (the consensus recovers $\tau$)

**Definition 2.5 (Phantom Irreducibility).** A topology $\tau$ is *phantom-irreducible* if no strict phantom decomposition of $\tau$ exists.

## 3. Main Results

### 3.1 The Agreement Characterization

**Theorem 3.1 (Phantom Intersection Principle).** A set $U$ is open in the consensus topology if and only if every observer agrees $U$ is open:
$$U \in \text{Opens}(\text{consensus}(T)) \iff \forall o \in O, U \in \text{Opens}(T(o))$$

*Proof.* This follows from `isOpen_iSup_iff` in Mathlib, which characterizes open sets of the supremum of topologies. $\square$

### 3.2 Structural Properties of Agreement

**Theorem 3.2.** Phantom agreement satisfies the topology axioms:
- $\emptyset$ and $X$ are in agreement.
- Agreement is closed under arbitrary unions.
- Agreement is closed under finite intersections.

*Proof.* Each property follows from the corresponding topology axiom applied to each observer's topology. $\square$

### 3.3 Monotonicity and Reparametrization

**Theorem 3.3 (Monotonicity).** If $T_1(o) \leq T_2(o)$ for all $o$ (observer-wise finer), then $\text{consensus}(T_1) \leq \text{consensus}(T_2)$.

**Theorem 3.4 (Surjective Reparametrization Invariance).** If $f : O' \twoheadrightarrow O$ is surjective, then $\text{consensus}(T) = \text{consensus}(T \circ f)$.

*Proof.* By antisymmetry. One direction uses `iSup_le` with surjectivity to match observers. The reverse uses `le_iSup` for each composed observer. $\square$

### 3.4 Phantom Irreducibility

**Theorem 3.5 (Discrete Irreducibility).** The discrete topology $\bot$ is phantom-irreducible.

*Proof.* If a strict decomposition existed, we would have some observer $o$ with $\text{topo}(o) < \bot$. But $\bot$ is the minimum of the lattice, so no element is strictly less. $\square$

**Theorem 3.6 (Minimum Observer Principle).** Every strict phantom decomposition has $|\text{Obs}| \geq 2$.

*Proof.* If $\text{Obs}$ were subsingleton with unique element $o_0$, then $\bigvee_o \text{topo}(o) = \text{topo}(o_0)$. But then $\text{topo}(o_0) = \tau$ (by `consensus_eq`) contradicts $\text{topo}(o_0) < \tau$ (by `strictly_finer`). $\square$

### 3.5 Characterization of Sierpiński-Type Topologies

**Theorem 3.7 (Open Sets of $\text{generateFrom}\{\{a\}\}$).** For any point $a \in X$:
$$U \in \text{Opens}(\text{generateFrom}\{\{a\}\}) \iff U = \emptyset \lor U = \{a\} \lor U = X$$

*Proof.* By induction on `GenerateOpen`:
- **Basic**: $U \in \{\{a\}\}$ implies $U = \{a\}$.
- **Univ**: $U = X$.
- **Inter**: If $U_1, U_2 \in \{\emptyset, \{a\}, X\}$, check all 9 cases to verify closure.
- **sUnion**: If all members of the family are in $\{\emptyset, \{a\}, X\}$, the union is also. $\square$

### 3.6 The Indiscrete Decomposition

**Theorem 3.8.** For distinct $a \neq b$ in $X$:
$$\text{generateFrom}\{\{a\}\} \vee \text{generateFrom}\{\{b\}\} = \top$$

*Proof.* By antisymmetry. $\leq \top$ is trivial. For $\top \leq$: if $U$ is open in both topologies, then by Theorem 3.7, $U \in \{\emptyset, \{a\}, X\} \cap \{\emptyset, \{b\}, X\}$. Since $a \neq b$, $\{a\} \neq \{b\}$, so the intersection is $\{\emptyset, X\}$. Thus $U$ is open in $\top$. $\square$

**Theorem 3.9 (Indiscrete Decomposability).** On any nontrivial type $X$, the indiscrete topology $\top$ is not phantom-irreducible.

*Proof.* Choose $a \neq b$ from nontriviality. Apply the binary decomposition construction `sup_strict_decomp` with Theorem 3.8, using `generateFrom_singleton_lt_top` for strict fineness. $\square$

## 4. The Observer Stability Theorem

**Theorem 4.1.** If a new observer's topology $\tau_{\text{new}}$ is already finer than (or equal to) the consensus, then adjoining it does not change the consensus:
$$\text{consensus}(T) \vee \tau_{\text{new}} = \text{consensus}(T) \quad \text{when } \tau_{\text{new}} \leq \text{consensus}(T)$$

*Proof.* By `sup_eq_left` in the lattice. $\square$

**Interpretation.** Only observers who are *coarser* than the current consensus — who see *less* — can affect the consensus by removing phantom open sets. An observer who already agrees with or sees more than the consensus contributes nothing new.

## 5. Algorithms

### 5.1 Computing the Phantom Number

Given a finite topology $\tau$ on a finite set $X$ (represented as a set of open sets), the *phantom number* is the minimum $k$ such that $\tau = \bigvee_{i=1}^k \tau_i$ with each $\tau_i < \tau$.

**Algorithm**: Enumerate subtopologies of $\tau$ (topologies with strictly more open sets). For $k = 2, 3, \ldots$, check if any $k$-tuple has supremum equal to $\tau$. The first success gives the phantom number.

**Complexity**: The number of topologies on an $n$-element set grows super-exponentially, making brute force impractical for $n > 5$. Lattice-theoretic pruning can reduce the search space.

### 5.2 Verifying Phantom Decompositions

Given candidate observer topologies $\tau_1, \ldots, \tau_k$ and a target $\tau$:
1. Verify each $\tau_i < \tau$ (strict inclusion of open sets, plus existence of an open set in $\tau_i \setminus \tau$).
2. Compute $\bigcap_{i=1}^k \text{Opens}(\tau_i)$ and verify it equals $\text{Opens}(\tau)$.

## 6. Discussion

### 6.1 Relationship to Lattice Theory

Phantom decomposition is closely related to the concept of *irreducible elements* in lattice theory. A topology $\tau$ is phantom-irreducible iff it is *iSup-irreducible*: it cannot be written as $\bigvee S$ for any set $S$ with all elements strictly below $\tau$. The lattice of topologies on a set is not, in general, distributive, which makes the theory richer than in distributive lattice settings.

### 6.2 Connection to Quantum Foundations

The phantom topology framework resonates with operational approaches to quantum mechanics, where the "state" of a system is determined by the totality of measurements. In phantom topology, the "state" (topology) is determined by the totality of observer perspectives. The discrete topology's irreducibility corresponds to a "maximally determined" state; the indiscrete topology's decomposability corresponds to a "minimally determined" state that requires external observers to resolve.

### 6.3 Open Questions

1. **Characterize all phantom-irreducible topologies.** Beyond the discrete topology, which topologies are irreducible? Are all atomic topologies (those covering $\top$) irreducible?

2. **Phantom number of specific spaces.** What is the phantom number of the Euclidean topology on $\mathbb{R}^n$? Of the Zariski topology? Of the $p$-adic topology?

3. **Categorical structure.** Is there a natural category of phantom topologies? What are the morphisms?

4. **Infinite decompositions.** Can we characterize topologies that require infinitely many observers?

5. **Metrizable vs. non-metrizable.** The original conjecture suggests non-metrizable spaces require more observers. Can this be formalized?

## 7. Conjectures

**Conjecture 7.1 (Second-Countable Phantom Bound).** Every second-countable $T_0$ space admits a phantom decomposition with at most countably many observers.

**Conjecture 7.2 (Hausdorff Phantom Number).** The standard Euclidean topology on $\mathbb{R}$ has phantom number 2.

**Conjecture 7.3 (Phantom Irreducibility of Atoms).** An atomic topology (one that covers the indiscrete in the lattice) is phantom-irreducible if and only if it is generated by a single open set (i.e., it is a 3-element Sierpiński-type topology).

*Test for Conjecture 7.3*: Verify computationally on $X = \{1, 2, 3, 4\}$ that non-Sierpiński atoms admit decompositions.

## 8. References

1. Birkhoff, G. (1967). *Lattice Theory* (3rd ed.). AMS Colloquium Publications.
2. Engelking, R. (1989). *General Topology*. Heldermann Verlag.
3. Larson, R.E. & Andima, S.J. (1975). The lattice of topologies: A survey. *Rocky Mountain Journal of Mathematics*, 5(2), 177–198.
4. Steiner, A.K. (1966). The lattice of topologies: Structure and complementation. *Transactions of the AMS*, 122(2), 379–398.
