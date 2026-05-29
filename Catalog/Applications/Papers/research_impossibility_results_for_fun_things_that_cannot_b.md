# A Unified Calculus of Impossibility via Group Actions, Equivariant Tasks, and Orbit Obstructions

## Abstract

We introduce the notion of an *equivariant task* — a formalization of the demand for a symmetry-respecting canonical choice — and prove a family of impossibility theorems showing that nontrivial free group actions obstruct the existence of equivariant solutions to natural tasks. Our main results include: (A) no equivariant constant map exists on a free nontrivial action; (B) a free nontrivial action always admits an unsolvable equivariant task; (C) equivariant self-maps on free transitive actions are necessarily injective; (D) finite counting obstructions for equivariant retractions; and (E) a social choice impossibility theorem as a cross-domain application. We also exhibit a counterexample showing that the naive conjecture "free action implies universal impossibility" is false, thereby sharpening the obstruction to its correct form. All results are formally verified in Lean 4 with the Mathlib library, and supplemented by computational experiments on finite group actions.

**Keywords:** group actions, equivariance, impossibility theorems, symmetry breaking, torsors, orbit-stabilizer, social choice, no-go theorems, invariant selection, formal verification

---

## 1. Introduction

### 1.1 Motivation

Impossibility theorems pervade mathematics: the impossibility of trisecting a general angle, solving the general quintic by radicals, designing a fair voting system satisfying certain axioms, or simultaneously measuring non-commuting observables. Despite their diverse origins, these results share a common structural feature: each asks for a *canonical choice* in a situation with *too much symmetry*.

This paper formalizes this observation by introducing a general framework — **equivariant tasks on group actions** — and proving that nontrivial symmetry systematically obstructs canonical solvability.

### 1.2 Prior Work

The connection between symmetry and impossibility is implicit in much of classical mathematics:
- **Galois theory** (1830s): The unsolvability of the quintic by radicals is equivalent to the non-solvability of the Galois group S₅.
- **Arrow's impossibility theorem** (1950): No social welfare function satisfies unanimity, independence of irrelevant alternatives, and non-dictatorship.
- **Topological fixed-point theorems** (Borsuk-Ulam, 1933): Continuous equivariant maps from S^n to R^n must have a zero.

Our contribution is to identify the common algebraic skeleton and formalize it as a reusable theory.

### 1.3 Contributions

1. A new mathematical structure: `EquivariantTask G X Y`, formalizing symmetry-constrained tasks.
2. Five formally verified theorems (A–E) providing both impossibility results and sharpening counterexamples.
3. A computational framework for testing equivariant task solvability on finite groups.
4. Cross-domain applications to social choice theory.
5. A falsifiable conjecture (the stabilizer criterion) with computational evidence.

---

## 2. Definitions and Notation

### 2.1 Group Actions

Let G be a group and X a set. A *(left) action* of G on X is a map · : G × X → X satisfying:
- 1 · x = x for all x ∈ X
- (gh) · x = g · (h · x) for all g, h ∈ G and x ∈ X

The action is **free** if g · x = x implies g = 1 for all g ∈ G, x ∈ X.
The action is **transitive** if for all x, y ∈ X there exists g ∈ G with g · x = y.

### 2.2 Equivariant Tasks

**Definition 2.1.** An *equivariant task* for a group G acting on types X and Y is a triple T = (G, X, Y, A) where A : X → 𝒫(Y) is an *admissibility function* satisfying the equivariance condition:

∀ g ∈ G, x ∈ X, y ∈ Y : y ∈ A(x) ⟺ g · y ∈ A(g · x)

**Definition 2.2.** A task T is *solvable* if there exists f : X → Y such that:
1. f(x) ∈ A(x) for all x ∈ X *(admissibility)*
2. f(g · x) = g · f(x) for all g ∈ G, x ∈ X *(equivariance)*

### 2.3 Canonical Task Instances

**Identity Task.** A(x) = {x}. Always solvable by f = id.

**Fixed-Point Task.** A(x) = Fix(G) = {y ∈ X : g · y = y ∀g}. Impossible when the action is free and nontrivial.

**Constant Task.** A(x) = X, with the additional requirement that f be constant. Impossible on free nontrivial actions.

### 2.4 Lean 4 Formalization

```lean
structure EquivariantTask (G X Y : Type*) [Group G] [MulAction G X] [MulAction G Y] where
  admissible : X → Set Y
  equiv_admissible : ∀ (g : G) (x : X) (y : Y), y ∈ admissible x ↔ g • y ∈ admissible (g • x)

def TaskSolvable (G X Y : Type*) [Group G] [MulAction G X] [MulAction G Y]
    (T : EquivariantTask G X Y) : Prop :=
  ∃ f : X → Y, (∀ x, f x ∈ T.admissible x) ∧ (∀ (g : G) (x : X), f (g • x) = g • f x)
```

---

## 3. Main Results

### 3.1 Theorem A: No Equivariant Constant Map on Free Nontrivial Actions

**Theorem 3.1.** Let G act on X. If the action is free (∀ g ≠ 1, ∀ x, g · x ≠ x) and G is nontrivial (∃ g ≠ 1), then there is no equivariant constant map f : X → X.

*Proof sketch.* Suppose f is equivariant with f(x) = c for all x. Let g ≠ 1. Then:
- f(g · c) = g · f(c) = g · c (equivariance)
- f(g · c) = c (constancy)

So g · c = c, contradicting freeness. □

**Formal verification:** The Lean proof uses `push_neg` and `contrapose!`, reducing to a direct application of the freeness hypothesis.

### 3.2 Theorem B: Existence of Impossible Tasks

**Theorem 3.2.** If G acts freely on a nonempty X with a nontrivial element, then there exists an equivariant task T on (X, X) that is impossible.

*Proof.* Take T = FixedPointTask. Since the action is free and nontrivial, Fix(G) = ∅. Any solution f would need f(x) ∈ ∅ for some x (X is nonempty), a contradiction. □

### 3.3 Theorem C: Equivariant Self-Maps Are Injective

**Theorem 3.3.** Let G act freely and transitively on X. Then every equivariant self-map f : X → X is injective.

*Proof sketch.* Suppose f(x₁) = f(x₂). By transitivity, x₂ = g · x₁ for some g. Then:
f(x₂) = f(g · x₁) = g · f(x₁) = g · f(x₂)

So g · f(x₂) = f(x₂), and by freeness g = 1, hence x₁ = x₂. □

**Significance:** This shows that on a torsor, the only equivariant self-maps are translations (in the abelian case) or more generally, bijections. There is no "equivariant compression."

### 3.4 Theorem D: Finite Counting Obstruction

**Theorem 3.4.** For a finite group G with |G| > 1 acting freely on a nonempty finite set X, no equivariant retraction r : X → X can be constant-valued (r(x) = r(y) for all x, y).

*Proof.* This follows from Theorem A (or Theorem 3.1) after extracting a nontrivial element from the cardinality hypothesis. □

### 3.5 Theorem E: Counterexample — Identity Task Is Solvable

**Theorem 3.5.** The identity task is solvable on any group action.

*Proof.* f = id is equivariant (f(g · x) = g · x = g · f(x)) and admissible (f(x) = x ∈ {x}). □

**Significance:** This refutes the naive conjecture "free action implies all tasks impossible." The obstruction is not freeness per se, but freeness combined with demand for symmetry-breaking.

### 3.6 Cross-Domain: Social Choice Impossibility

**Theorem 3.6.** For a finite type C with |C| ≥ 2, there is no function f : C → C that is both:
1. Equivariant under all permutations of C: f(σ(x)) = σ(f(x)) for all σ ∈ Perm(C)
2. Constant: f(x) = c for all x

*Proof sketch.* If f is constant at c and equivariant, then σ(c) = c for all σ. Take σ = swap(c, d) where d ≠ c (exists since |C| ≥ 2). Then σ(c) = d ≠ c, contradiction. □

**Interpretation.** This captures the core of social choice impossibility: a "fair" winner-selection rule (equivariant under candidate relabeling) cannot deterministically pick the same winner for all labelings when there are at least 2 candidates.

---

## 4. Algorithms

### 4.1 Equivariant Map Enumeration (Orbit Reduction)

**Input:** Group action (G, X), target action (G, Y), admissibility function A
**Output:** All equivariant maps f : X → Y with f(x) ∈ A(x)

```
Algorithm EnumerateEquivariantMaps(G, X, Y, A):
  1. Compute orbit decomposition X = O₁ ∪ ... ∪ Oₖ
  2. For each orbit Oᵢ, choose representative xᵢ
  3. For each xᵢ, compute stabilizer Stab(xᵢ)
  4. For each xᵢ, compute candidates:
     Cᵢ = {y ∈ A(xᵢ) : h · y = y for all h ∈ Stab(xᵢ)}
  5. For each (y₁,...,yₖ) ∈ C₁ × ... × Cₖ:
     a. Define f(g · xᵢ) = g · yᵢ for all g, i
     b. Verify well-definedness and admissibility
     c. If valid, add f to output
  6. Return all valid maps
```

**Complexity:** O(|Y|^k · |G| · |X|) where k = number of orbits. Compared to brute-force O(|Y|^|X|), this gives exponential speedup when orbits are large.

### 4.2 Impossibility Detection

**Input:** Group action (G, X, Y), admissibility A
**Output:** Is the task impossible? With reason.

```
Algorithm DetectImpossibility(G, X, Y, A):
  1. Quick check: if A(x) = ∅ for any x, return IMPOSSIBLE
  2. For each orbit representative xᵢ:
     If no y ∈ A(xᵢ) satisfies Stab(xᵢ) ⊆ Stab(y):
       return IMPOSSIBLE (stabilizer obstruction)
  3. Run EnumerateEquivariantMaps
  4. If no maps found: return IMPOSSIBLE (exhaustive)
  5. Else: return POSSIBLE with witness
```

---

## 5. Computational Experiments

### 5.1 Cyclic Groups

For C_n acting on Z/nZ by translation (n = 2, 3, 4, 5, 6):

| n | |Equivariant self-maps| | All injective? | Any constant? | Impossible tasks |
|---|---|---|---|---|
| 2 | 2 | Yes | No | 3 |
| 3 | 3 | Yes | No | 4 |
| 4 | 4 | Yes | No | 5 |
| 5 | 5 | Yes | No | 6 |
| 6 | 6 | Yes | No | 7 |

**Pattern:** C_n has exactly n equivariant self-maps (the n translations), all bijections, none constant. The number of impossible tasks (fixed-point + constant-value tasks) equals n + 1.

### 5.2 Symmetric Groups

For S_n acting on {1,...,n} by permutation:

| n | |S_n| | |Equivariant self-maps| | Orbit reduction factor |
|---|---|---|---|
| 3 | 6 | 1 | 27 → 3 (9x) |
| 4 | 24 | 1 | 256 → 4 (64x) |
| 5 | 120 | 1 | 3125 → 5 (625x) |

**Observation:** S_n acting transitively on n points has exactly one equivariant self-map (the identity). The orbit reduction algorithm provides dramatic speedup.

### 5.3 Stabilizer Criterion Testing

The conjecture "task solvable iff stabilizer-compatible section exists" was tested on all tasks constructed for C₂, C₃, S₃:

| Test case | Solvable? | Criterion? | Match? |
|---|---|---|---|
| C₂ identity | True | True | ✓ |
| C₂ fixed-point | False | False | ✓ |
| C₃ identity | True | True | ✓ |
| C₃ fixed-point | False | False | ✓ |
| S₃ identity | True | True | ✓ |
| S₃ fixed-point | False | False | ✓ |

All cases match. The conjecture remains open for general tasks.

---

## 6. Applications

### 6.1 Social Choice Theory

The framework captures a core aspect of Arrow-style impossibility. With n ≥ 2 candidates acted on by S_n, any equivariant winner-selection rule must track permutations faithfully — ruling out constant (labeling-independent) choices.

Computational verification: For n = 2, 3 candidates, exhaustive search confirms 0 constant equivariant maps exist among 2 and 1 total equivariant maps respectively.

### 6.2 Cryptography

Without a key, an encryption scheme must be equivariant under all message permutations. But equivariant maps on a free action are all bijections (Theorem C), never constant — they can shuffle messages but not hide them. The key provides the symmetry-breaking data needed for information hiding.

### 6.3 Fair Division

Allocating n indivisible identical goods among n agents with full symmetry (S_n acts by relabeling agents) yields 0 equivariant allocations when the allocation must distinguish agents. Tie-breaking (symmetry breaking) is mathematically necessary.

---

## 7. Discussion

### 7.1 The Corrected Principle

The naive conjecture "task is impossible iff the action is free" is **false**, as demonstrated by Theorem E. The correct principle is:

> **Impossibility arises when the task demands equivariant output from a structure whose symmetry group acts without fixed points on the output space, and the admissible set requires more collapse than equivariance permits.**

More precisely:
- The identity task shows that tasks aligned with the group structure are always solvable.
- The fixed-point task shows that tasks demanding fixed-point outputs are impossible when no fixed points exist.
- The constant-map obstruction shows that tasks demanding symmetry-breaking are impossible on free actions.

### 7.2 Limitations

1. Our framework currently handles discrete/algebraic groups. Extension to topological and Lie groups (needed for full Borsuk-Ulam-type theorems) requires additional structure.
2. The social choice application captures the symmetry obstruction but does not recover the full strength of Arrow's theorem, which involves multiple additional axioms.
3. The stabilizer criterion conjecture is only tested on small groups and may fail for more complex admissibility conditions.

### 7.3 Relationship to Existing Theory

The equivariant task framework can be seen as a formalization of the concept of a *section of a G-equivariant bundle*. In this language:
- X is the base space
- The admissible fibers A(x) form the total space
- Equivariance is the bundle structure
- Solvability is the existence of an equivariant section

This connects our framework to equivariant topology and the theory of principal bundles.

---

## 8. Future Work

1. **Topological extension:** Incorporate continuous group actions and prove equivariant Borsuk-Ulam-type obstructions within the framework.
2. **Galois theory connection:** Formalize the relationship between radical solvability and equivariant selectors under Galois group actions.
3. **Noncommutative obstruction:** Model uncertainty-type impossibilities via non-commuting group actions.
4. **Automated impossibility detection:** Develop decision procedures for equivariant task solvability on larger finite groups.
5. **Stabilizer criterion:** Prove or disprove the conjecture for general finite transitive actions.

---

## 9. References

1. K. Arrow, "Social Choice and Individual Values," Wiley, 1951.
2. E. Galois, "Mémoire sur les conditions de résolubilité des équations par radicaux," 1831.
3. K. Borsuk, "Drei Sätze über die n-dimensionale euklidische Sphäre," Fund. Math. 20, 1933.
4. S. Mac Lane, "Categories for the Working Mathematician," Springer, 1971.
5. T. tom Dieck, "Transformation Groups," de Gruyter, 1987.
6. Mathlib Community, "Mathlib: A Unified Library of Mathematics Formalized in Lean," 2020–present.

---

## Appendix: Complete Formal Statements

All theorems are formalized in Lean 4 with the Mathlib library. The complete source is in `Catalog/Speculative/EquivariantImpossibility/Core.lean`. Key axioms used: `propext`, `Classical.choice`, `Quot.sound` (all standard).
