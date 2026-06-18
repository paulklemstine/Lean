# The Explosion-Topology Correspondence: A Formal Bridge Between Paraconsistent Logic and Pre-Topological Geometry

## Abstract

We introduce the **Observation Dream Space**, a novel mathematical construction that establishes a precise formal correspondence between Belnap's four-valued paraconsistent logic and pre-topological spaces (dream spaces). Given a type α and a predicate selecting "observable" elements, we construct a pre-topological space whose open sets are the empty set, the universal set, and singletons of observable elements. We prove that this dream space is a genuine topology if and only if the observable set is subsingleton — establishing that the failure of logical explosion (contradictions entailing arbitrary conclusions) corresponds exactly to the failure of the union axiom in pre-topological spaces. We introduce quantitative measures of this correspondence: the dream defect counts failing union pairs and equals C(k,2) for k observable elements, while a graded spectrum of dream spaces interpolates between maximally non-topological and fully topological structures. All results are formalized and verified in Lean 4 with Mathlib.

**Keywords**: Paraconsistent logic, Belnap's four-valued logic, pre-topological spaces, dream spaces, explosion principle, bilattice, observation spaces

## 1. Introduction

### 1.1 Background

Classical logic satisfies the *principle of explosion* (ex falso quodlibet): from a contradiction, any statement can be derived. Paraconsistent logics weaken this principle, allowing contradictions to coexist without trivializing the entire theory. Belnap's four-valued logic (FDE) [1] is the paradigmatic example, introducing truth values `verum`, `falsum`, `both` (contradictory), and `neither` (unknown).

Pre-topological spaces, or *dream spaces*, generalize topological spaces by retaining closure under finite intersection but dropping the requirement of closure under arbitrary union. These structures arise naturally in the study of non-monotonic reasoning, where individual inferences are sound but cannot always be combined [2].

### 1.2 Main Contribution

We establish a precise formal correspondence between these two domains:

1. **Construction**: Given a set of "observable" elements O ⊆ α, we construct a dream space whose open sets are {∅, univ} ∪ {{a} : a ∈ O}.

2. **Characterization**: This dream space is topological if and only if |O| ≤ 1 (or α is subsingleton).

3. **Bridge**: Via a Belnap valuation v : α → BVal, elements with designated values (verum or both) become observable, and explosion failure corresponds to union failure.

4. **Quantitative**: The dream defect = C(k,2) where k = |O|, and a graded spectrum based on the information ordering interpolates between topological and non-topological.

5. **Dynamics**: Belief retraction (changing `both` to `neither`) monotonically reduces the dream defect.

### 1.3 Related Work

The connection between paraconsistent logic and topology has been explored informally by several authors. Priest [3] noted that paraconsistent set theories have natural topological interpretations. Mortensen [4] studied inconsistent mathematics including inconsistent topologies. Our contribution is the first *precise, formal* correspondence establishing that a specific construction (observation dream spaces) exhibits non-topologicity if and only if the underlying logic is paraconsistent in a quantifiable sense.

## 2. Definitions

### 2.1 Belnap's Four-Valued Logic

**Definition 2.1 (BVal).** The type BVal consists of four values:
- `verum`: definitely true
- `falsum`: definitely false
- `both`: both true and false (contradictory)
- `neither`: neither true nor false (gap)

**Definition 2.2 (Designated).** A value v is *designated* if v ∈ {verum, both}. Designated values are "accepted as true," even if contradictory.

**Definition 2.3 (De Morgan negation).** neg(verum) = falsum, neg(falsum) = verum, neg(both) = both, neg(neither) = neither.

**Definition 2.4 (Information ordering).** neither ≤ᵢ verum, falsum ≤ᵢ both. This measures the "amount of evidence" independent of its direction.

**Definition 2.5 (Information level).** infoLevel(neither) = 0, infoLevel(verum) = infoLevel(falsum) = 1, infoLevel(both) = 2.

### 2.2 Dream Spaces

**Definition 2.6 (Dream Space).** A dream space on a type α is a structure D = (isOpen, ∅ ∈ isOpen, univ ∈ isOpen, inter_mem) where isOpen : Set(Set α) is closed under finite intersection and contains ∅ and univ.

**Definition 2.7 (Topological).** A dream space D is *topological* if ∀ S ⊆ D.isOpen, ⋃₀ S ∈ D.isOpen.

### 2.3 The Observation Dream Space (Novel)

**Definition 2.8 (Observation Opens).** Given obs : α → Prop, define
  observationOpens(α, obs) = {S : Set α | S = ∅ ∨ S = univ ∨ ∃ a, obs(a) ∧ S = {a}}

**Definition 2.9 (Observation Dream Space).** observationDream(α, obs) is the dream space with isOpen = observationOpens(α, obs).

**Proposition 2.10.** observationDream(α, obs) is a well-defined dream space.

*Proof.* ∅ and univ are in observationOpens by definition. For finite intersection: if s, t ∈ observationOpens, then s ∩ t is either ∅ (if one factor is ∅ or the singletons are distinct), or t/s (if one is univ), or {a} (if both are {a}). In all cases, s ∩ t ∈ observationOpens. □

### 2.4 The Belnap-Dream Functor

**Definition 2.11 (Designated Observation).** Given v : α → BVal, define designatedObs(v)(a) ⟺ v(a) = verum ∨ v(a) = both.

**Definition 2.12 (Belnap Dream Space).** belnapDream(v) = observationDream(α, designatedObs(v)).

## 3. Main Results

### 3.1 Topological Characterization

**Theorem 3.1 (Topological iff Subsingleton).** observationDream(α, obs) is topological if and only if obsSet(α, obs) is subsingleton or α is subsingleton.

*Proof sketch.*
(⇐) If obsSet is subsingleton, every family of open sets has a union that is ∅, a single {a₀}, or univ — all of which are open. If α is subsingleton, every subset of α is ∅ or univ, so all unions are open.

(⇒ contrapositive) If there exist a ≠ b with obs(a), obs(b), and c ≠ a, c ≠ b, then {{a}, {b}} ⊆ isOpen but {a,b} = ⋃₀{{a},{b}} is not in observationOpens (not ∅, not univ since c ∉ {a,b}, not a singleton since a ≠ b). □

### 3.2 Explosion-Topology Correspondence

**Theorem 3.2 (Explosion ↔ Union).** Let v : α → BVal.

(a) If there exist a ≠ b with designatedObs(v, a), designatedObs(v, b), and c ∉ {a,b}, then belnapDream(v) is not topological.

(b) If {a : designatedObs(v, a)} is subsingleton, then belnapDream(v) is topological.

*Proof.* Direct application of Theorem 3.1 to designatedObs(v). □

**Corollary 3.3 (Classical Safety).** If v assigns only verum and falsum values (classical logic), and at most one element is verum, then belnapDream(v) is topological. Classical reasoning with unique truth is geometrically safe.

### 3.3 Dream Defect

**Definition 3.4 (Failing Pairs).** failingPairs(n, obs) = |{(a,b) : Fin n × Fin n | obs(a) ∧ obs(b) ∧ a < b}|.

**Theorem 3.5 (Defect Formula).** failingPairs(n, obs) = k(k-1)/2 where k = |{a : obs(a)}|.

*Proof.* The set of ordered pairs (a,b) with a < b from a set of size k is in bijection with 2-element subsets of that set, of which there are C(k,2) = k(k-1)/2. □

### 3.4 Graded Spectrum

**Definition 3.6 (Graded Observation).** gradedObs(v, k)(a) ⟺ k ≤ infoLevel(v(a)).

**Theorem 3.7 (Monotonicity).** If k₁ ≤ k₂, then observationDream(α, gradedObs(v, k₂)).isOpen ⊆ observationDream(α, gradedObs(v, k₁)).isOpen.

*Proof.* Higher thresholds yield fewer observable elements, hence fewer singleton opens. □

**Corollary 3.8 (Spectrum Extremes).**
- At threshold 0: all elements are observable (maximally non-topological for |α| ≥ 3).
- At threshold 3: no elements are observable (indiscrete = topological).
- At threshold 2: only `both`-valued elements are observable (measures pure paraconsistency).

### 3.5 Retraction Dynamics

**Definition 3.9 (Retraction).** retractAt(v, i)(a) = `neither` if a = i and v(i) = `both`, else v(a).

**Theorem 3.10 (Retraction Reduces Designated Count).**
If v(i) = `both`, then |{a : designatedObs(retractAt(v,i), a)}| < |{a : designatedObs(v, a)}|.

*Proof.* Position i was designated (both is designated) and becomes non-designated (neither is not). All other positions retain their designation status. □

**Corollary 3.11 (Convergence).** Iterating retraction on all `both`-valued positions eventually yields a classical valuation (no `both` values), whose Belnap dream space has at most as many designated elements as the original. If the result has ≤ 1 designated element, the dream space becomes topological.

### 3.6 Openness Classification

**Theorem 3.12 (Verum/Both Open).** If v(a) = verum or v(a) = both, then {a} ∈ belnapDream(v).isOpen.

**Theorem 3.13 (Falsum/Neither Closed).** If v(a) = falsum or v(a) = neither, and |α| ≥ 2, then {a} ∉ belnapDream(v).isOpen.

*Proof.* {a} ∈ observationOpens requires designatedObs(v,a), which requires v(a) ∈ {verum, both}. If v(a) = falsum or neither, this fails. The {a} = univ case is excluded by |α| ≥ 2. □

### 3.7 Algebraic Properties

**Theorem 3.14 (De Morgan).** neg(conj(a,b)) = disj(neg(a), neg(b)).

**Theorem 3.15 (Idempotence).** conj(v,v) = v and disj(v,v) = v for all v : BVal.

**Theorem 3.16 (Involution).** neg(neg(v)) = v.

## 4. PEGB Analysis

### 4.1 Theorem 3.1 (Topological Characterization)

**P (Proof)**: Complete formal proof in `observationDream_topological_of_subsingleton` and `observationDream_not_topological`.

**E (Example)**: On Fin 3 with obs = {0, 1}, the dream space has open sets {∅, Fin 3, {0}, {1}}. The set {0,1} is NOT open (proved as `obs01_pair_not_open`), demonstrating union failure.

**G (Generalization)**: The graded spectrum `gradedObs` generalizes the binary observable/non-observable distinction to a continuum parameterized by the information ordering.

**B (Boundary)**: On Fin 1, the theorem fails — every observation dream space is topological (`observationDream_trivial_fin1`). The three-point condition (a, b, c distinct) is necessary.

### 4.2 Theorem 3.2 (Explosion-Topology Correspondence)

**P**: Direct application of Theorem 3.1, proved as `explosion_implies_union_failure`.

**E**: With exVal : Fin 3 → BVal mapping 0↦verum, 1↦both, 2↦falsum, we get explosion failure at element 1 (`exVal_explosion`) and non-topological dream space (`exVal_not_topological`).

**G**: The graded spectrum provides a family of dream spaces parameterized by the information threshold, generalizing the binary correspondence.

**B**: If only one element is designated (e.g., classical logic with unique truth), the dream space IS topological (`classical_implies_topological`).

### 4.3 Theorem 3.5 (Defect Formula)

**P**: Bijection with 2-element subsets, proved as `failing_pairs_formula`.

**E**: For k=2 observable elements: defect = 1 (one failing pair). For k=3: defect = 3.

**G**: For higher-dimensional defects (triples, quadruples of opens whose union fails), similar combinatorial formulas should hold.

**B**: The formula requires n ≥ 3. For n ≤ 2, the boundary behavior changes (all observable sets are either subsingleton or equal to univ).

## 5. Algorithms

### 5.1 Dream Space Construction

```
Algorithm: ConstructObservationDream(α, obs)
Input: Type α, predicate obs : α → Bool
Output: Dream space (list of open sets)

1. Initialize opens = {∅, α}
2. For each a ∈ α:
   a. If obs(a): add {a} to opens
3. Return DreamSpace(opens)

Time: O(|α|)
Space: O(|α|)
```

### 5.2 Topological Test

```
Algorithm: IsTopological(α, obs)
Input: Type α (finite), predicate obs
Output: Boolean

1. Count k = |{a ∈ α : obs(a)}|
2. If k ≤ 1 or k = |α|: return True
   (Note: k = |α| case is topological only if |α| ≤ 1)
3. If |α| ≤ 1: return True
4. Return (k ≤ 1)

Time: O(|α|)
```

### 5.3 Dream Defect Computation

```
Algorithm: ComputeDreamDefect(α, obs)
Input: Type α (finite), predicate obs
Output: Natural number

1. Count k = |{a ∈ α : obs(a)}|
2. Return k * (k - 1) / 2

Time: O(|α|)
```

## 6. Discussion

### 6.1 Philosophical Implications

The Explosion-Topology Correspondence suggests that the choice between classical and paraconsistent logic is not merely a philosophical preference but has geometric content. A logical system that tolerates contradictions corresponds to a geometric space where local observations cannot be freely combined — a space with a fundamentally different character from the familiar topological spaces of classical mathematics.

### 6.2 Connection to Tropical Algebra

Both Belnap's bilattice and the tropical semiring share the property of idempotent operations that respect finite structure but can fail under infinite limits. In Belnap's logic, conjunction and disjunction are idempotent (v ∧ v = v, v ∨ v = v). In the tropical semiring, min is idempotent (min(a,a) = a). Both respect finite operations but the analog of "arbitrary union" (infinite min, arbitrary logical disjunction) can fail to preserve structure. This suggests a deeper algebraic framework — a "tropical bilattice" — unifying both structures.

### 6.3 Limitations

Our construction uses singletons as the non-trivial open sets. More general observation dream spaces (where opens include larger sets) would yield richer topological characterizations. The current construction is the "atomic" case — the simplest non-trivial bridge between logic and geometry.

## 7. Future Work

1. **Tropical Dream Bilattice**: Extend the correspondence to include tropical semiring operations, creating a three-way bridge between logic, geometry, and optimization.

2. **Categorical Framework**: Formalize the category of dream spaces and dream morphisms, and establish adjunctions with the categories of topological spaces and Belnap valuations.

3. **Infinite Types**: Extend the dream defect analysis to countable and uncountable types, where the defect becomes a cardinal invariant.

4. **Quantum Connections**: Investigate whether the observation dream space framework captures aspects of quantum contextuality (the failure to assign consistent classical values to all observables simultaneously).

## References

[1] Belnap, N.D. (1977). "A useful four-valued logic." In *Modern Uses of Multiple-Valued Logic*, pp. 5-37, Reidel.

[2] Čech, E. (1966). *Topological Spaces*. Wiley (revised by Frolík and Katětov).

[3] Priest, G. (2006). *In Contradiction: A Study of the Transconsistent*. Oxford University Press.

[4] Mortensen, C. (1995). *Inconsistent Mathematics*. Kluwer Academic Publishers.

[5] Fitting, M. (2002). "Bilattices are nice things." In *Self-Reference*, CSLI Publications.
