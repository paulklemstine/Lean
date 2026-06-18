# Future Directions: Voice-Leading Geometry

## Overview

This document outlines 5 concrete next steps opened by the formally verified voice-leading cost framework. Each direction includes an exact theorem statement, formalization target, proof strategies, and cross-domain connections.

---

## Direction 1: N-Voice Sorted Matching Optimality

### Exact Theorem Statement

For all $n$ and monotone nondecreasing chords $x, y : \text{Fin}\, n \to \mathbb{Z}$:
$$\text{vlCostN}(x, y) = \sum_{i=0}^{n-1} |x(i) - y(i)|$$

### Formalization Target

```lean
theorem vlCostN_sorted_optimal {n : ℕ} [Nonempty (Fin n)]
    (x y : ChordN n) 
    (hx : Monotone x) (hy : Monotone y) :
    vlCostN x y = ∑ i : Fin n, Int.natAbs (x i - y i)
```

### Proof Strategy Ideas

1. **Induction on the number of inversions.** Define the inversion count of a permutation. Show that any transposition that uncrosses an inversion does not increase cost (using the uncrossing lemma). Since the identity has zero inversions, it is optimal among all permutations.

2. **Bubble sort argument.** Show that applying adjacent transpositions to reduce inversions in $\sigma$ produces a sequence of permutations with non-increasing cost. Since bubble sort terminates at the identity, the identity is optimal.

### Cross-Domain Connection

This is a formal verification of the one-dimensional optimal transport theorem (Monge property). It connects directly to the theory of Monge matrices in combinatorial optimization and the rearrangement inequality in analysis.

---

## Direction 2: Quotient Geometry of Chord Classes

### Exact Theorem Statement

Define the equivalence relation $x \sim y$ iff $\text{vlCostN}(x, y) = 0$ (i.e., $x$ and $y$ are rearrangements). The induced function on the quotient $\text{vlCostQ} : (\text{ChordN}\, n / {\sim}) \times (\text{ChordN}\, n / {\sim}) \to \mathbb{N}$ is well-defined and is a genuine metric (not just pseudometric).

### Formalization Target

```lean
def ChordClass (n : ℕ) := Quotient (vlCostN_setoid n)

noncomputable def vlCostQ {n : ℕ} [Nonempty (Fin n)] : 
    ChordClass n → ChordClass n → ℕ

theorem vlCostQ_well_defined {n : ℕ} [Nonempty (Fin n)] :
    ∀ x₁ x₂ y₁ y₂ : ChordN n, 
      x₁ ≈ x₂ → y₁ ≈ y₂ → vlCostN x₁ y₁ = vlCostN x₂ y₂

theorem vlCostQ_metric {n : ℕ} [Nonempty (Fin n)] :
    ∀ x y : ChordClass n, vlCostQ x y = 0 → x = y
```

### Proof Strategy Ideas

1. **Use permutation invariance.** If $x_1 \sim x_2$ then $x_2 = x_1 \circ \tau$ for some $\tau$. By `vlCostN_perm_invariant`, the cost is unchanged.

2. **Use the zero-cost characterization.** `vlCostN_eq_zero_iff` gives the exact condition for equivalence. The metric separation property follows from the definition.

### Cross-Domain Connection

The quotient is the multiset of pitches—an unordered chord. This connects to the theory of orbifolds in Tymoczko's geometric music theory, where chord classes are points in $\mathbb{R}^n / S_n$.

---

## Direction 3: Certified Optimal Matching Algorithm

### Exact Theorem Statement

Define a computable function `sortedVLCost` that sorts both input chords and computes the identity matching cost. Prove it equals `vlCostN`.

### Formalization Target

```lean
def sortedVLCost {n : ℕ} (x y : ChordN n) : ℕ :=
  let xs := (List.ofFn x).mergeSort (· ≤ ·)
  let ys := (List.ofFn y).mergeSort (· ≤ ·)
  (List.zipWith (fun a b => Int.natAbs (a - b)) xs ys).sum

theorem sortedVLCost_eq_vlCostN {n : ℕ} [Nonempty (Fin n)]
    (x y : ChordN n) : sortedVLCost x y = vlCostN x y
```

### Proof Strategy Ideas

1. **Reduce to sorted matching optimality.** Show that `sortedVLCost` computes the identity matching cost on sorted chords, then invoke the sorted optimality theorem.

2. **Prove via the assignment problem.** Show that the cost matrix $C_{ij} = |x_{\text{sort}(i)} - y_{\text{sort}(j)}|$ satisfies the Monge property $C_{ij} + C_{kl} \leq C_{il} + C_{kj}$ for $i < k, j < l$, which implies identity optimality.

### Cross-Domain Connection

This is a certified algorithm in the sense of CompCert or seL4: a program with a machine-checked correctness proof. It connects to verified software engineering and the theory of proof-carrying code.

---

## Direction 4: Finite Harmonic Graph Diameter

### Exact Theorem Statement

For the corpus of all seventh chords in one key (7 roots × 4 types = 28 chords), compute the exact diameter of the weighted chord graph and prove it formally.

### Formalization Target

```lean
def seventhChordCorpus : Finset (ChordN 4) := ...

theorem seventh_chord_diameter :
    ∀ x y ∈ seventhChordCorpus, vlCost4 x y ≤ D ∧ 
    ∃ x y ∈ seventhChordCorpus, vlCost4 x y = D
```

### Proof Strategy Ideas

1. **Computational proof.** Use `native_decide` or `decide` to verify all $28^2 = 784$ pairwise costs and extract the maximum. This requires defining the corpus as a concrete `Finset`.

2. **Structural bound.** Prove an upper bound on the diameter using the maximum pitch range and number of voices, then find a tight example computationally.

### Cross-Domain Connection

This connects to graph theory (diameter of weighted graphs), network analysis (navigability of harmonic spaces), and computational music theory (complexity of modulation).

---

## Direction 5: Tropical Harmonic Semiring

### Exact Theorem Statement

Define a tropical semiring structure on chord progressions where:
- Addition = minimum cost path selection
- Multiplication = path concatenation (cost addition)

Prove that this satisfies the tropical semiring axioms.

### Formalization Target

```lean
structure TropicalProgression (n : ℕ) where
  source : ChordN n
  target : ChordN n
  cost : ℕ

def tropAdd (p q : TropicalProgression n) : TropicalProgression n :=
  if p.cost ≤ q.cost then p else q

def tropMul (p q : TropicalProgression n) 
    (h : p.target = q.source) : TropicalProgression n :=
  ⟨p.source, q.target, p.cost + q.cost⟩

theorem tropMul_assoc : ... 
theorem tropAdd_comm : ...
theorem tropMul_distributes_over_tropAdd : ...
```

### Proof Strategy Ideas

1. **Direct algebraic verification.** The tropical semiring axioms for $(\min, +)$ are straightforward once the objects are defined correctly.

2. **Embed into existing tropical algebra.** Mathlib has `Tropical` type with min-plus structure. Define a homomorphism from progression costs into `Tropical ℕ`.

### Cross-Domain Connection

This connects to tropical geometry (Maclagan-Sturmfels), the Floyd-Warshall algorithm (all-pairs shortest paths via tropical matrix multiplication), and algebraic approaches to network optimization.

---

## Research Team Recommendations

### Immediate (Next 1-2 weeks)
- Direction 1 (sorted optimality for n voices): highest mathematical value
- Direction 4 (diameter computation): most accessible, computational

### Medium-term (1-2 months)
- Direction 2 (quotient geometry): foundational for the theory
- Direction 3 (certified algorithm): bridges theory and practice

### Long-term (3-6 months)
- Direction 5 (tropical semiring): deepest mathematical structure
- Extensions to continuous pitch, microtonal systems, and multi-dimensional chord spaces

### Hypotheses to Test
1. The diameter of the seventh-chord graph in one key is exactly the maximum transposition distance (12 semitones × 4 voices = 48).
2. The sorted matching optimality theorem extends to higher-dimensional pitch spaces with the Monge property.
3. The tropical harmonic semiring is isomorphic to a sub-semiring of tropical matrix algebra.
4. A small basis of 3-4 primitive voice-leading moves generates all transitions of cost ≤ 4 in the seventh-chord graph.
5. The voice-leading pseudometric on chord classes is a genuine metric (no distinct chord classes have zero distance).
