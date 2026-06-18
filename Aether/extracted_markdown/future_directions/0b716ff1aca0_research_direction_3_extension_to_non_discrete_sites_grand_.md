# The Categorical Compression Number: Observational Complexity of Finite Categories

## Abstract

We introduce the **categorical compression number** κ(C) for a finite category C, defined as the minimum number of probe objects whose representable functors jointly separate all morphisms via postcomposition. This invariant measures the "observational complexity" of a category — the minimum number of vantage points needed to distinguish all internal processes. We prove that κ is invariant under equivalence of categories (Theorem 3), that it vanishes precisely on thin categories (Theorem 5, the cross-domain bridge), and that the full object set always suffices (Theorem 1, establishing well-definedness). We provide a brute-force algorithm for computing κ on small categories, verify it on multiple example families, and formalize all results in the Lean 4 proof assistant with machine-checked proofs. We propose several falsifiable conjectures including Morita invariance and product formulas.

## 1. Introduction

### 1.1 Motivation

The Yoneda lemma — one of the most fundamental results in category theory — asserts that a category can be faithfully embedded into its presheaf category via the Yoneda embedding. In particular, any object X is determined up to isomorphism by its representable functor Hom(−, X), and any morphism f : X → Y is determined by how it acts on all representables via postcomposition.

This raises a natural quantitative question: **how many representable functors are actually needed?** If a category has n objects, the full Yoneda embedding uses n representable functors. But often far fewer suffice to distinguish all morphisms.

We formalize this question through the notion of a *Yoneda-separating family* — a subset P of objects such that postcomposition with morphisms into P-objects distinguishes all parallel morphisms. The **compression number** κ(C) is then the minimum cardinality of such a family.

### 1.2 Relation to Prior Work

The concept of separating families of functors appears in categorical algebra (generators and cogenerators of categories) and in topos theory (where a site's objects serve as "probes" for presheaves). Our contribution is:

1. The specific focus on *minimum cardinality* as a numerical invariant
2. The proof that this invariant respects equivalence of categories
3. The connection to thin-category detection (cross-domain bridge to order theory)
4. The computational implementation enabling experimental investigation
5. Machine-verified proofs ensuring correctness

### 1.3 Summary of Results

| Theorem | Statement | Significance |
|---------|-----------|-------------|
| 1 | Full object set is separating | κ is well-defined |
| 2 | Monotonicity of separation | κ is a genuine minimum |
| 3 | Equivalence invariance | κ is a categorical invariant |
| 4 | Existence of minimal family | Minimizers exist |
| 5 | Thin categories have κ = 0 | Bridge to order theory |

## 2. Definitions and Notation

### 2.1 Setting

Throughout, C denotes a finite category: a category with finitely many objects, finitely many morphisms, and decidable equality on both. We write Ob(C) for the set of objects and Hom_C(X, Y) for the set of morphisms from X to Y.

### 2.2 Yoneda-Separating Families

**Definition 1** (Yoneda-Separating). A subset P ⊆ Ob(C) is *Yoneda-separating* if for all objects X, Y ∈ Ob(C) and all parallel morphisms f, g : X → Y,

∀ Q ∈ P, ∀ h : Y → Q, f ≫ h = g ≫ h ⟹ f = g.

Equivalently, the restricted Yoneda embedding Ob(C) → ∏_{Q ∈ P} Set given by X ↦ (Hom(X, Q))_{Q ∈ P} is faithful.

### 2.3 Compression Number

**Definition 2** (Compression Number). The compression number of C is

κ(C) := min { |P| : P ⊆ Ob(C), P is Yoneda-separating }.

The minimum exists because Ob(C) is finite and Ob(C) itself is always separating (Theorem 1).

### 2.4 Lean Formalization

In our formalization, the definitions take the following form:

```
def YonedaSeparating (C : Type u) [Category.{u} C] (P : Finset C) : Prop :=
  ∀ ⦃X Y : C⦄ (f g : X ⟶ Y),
    (∀ Q ∈ P, ∀ (h : Y ⟶ Q), f ≫ h = g ≫ h) → f = g

def CompressionNumber : ℕ :=
  Nat.find ⟨Finset.univ.card, Finset.univ, rfl, yonedaSeparating_univ C⟩
```

## 3. Main Results

### 3.1 Theorem 1: Full Object Family Separates

**Theorem.** For any finite category C, the full set Ob(C) is Yoneda-separating.

*Proof sketch.* Given f, g : X → Y with f ≫ h = g ≫ h for all Q and h : Y → Q, take Q = Y and h = id_Y. Then f = f ≫ id_Y = g ≫ id_Y = g. □

This is the foundational existence result: it ensures that the infimum defining κ(C) is a minimum over a nonempty set.

### 3.2 Theorem 2: Monotonicity

**Theorem.** If P ⊆ Q and P is Yoneda-separating, then Q is Yoneda-separating.

*Proof sketch.* If postcomposition into Q-probes agrees, then a fortiori postcomposition into P-probes agrees (since P ⊆ Q), so f = g by P being separating. □

This establishes that separating families form an upward-closed (monotone) family in the inclusion order on subsets of Ob(C). Consequently, κ(C) is the minimum of a well-defined optimization problem over an upward-closed feasible region.

### 3.3 Theorem 3: Equivalence Invariance

**Theorem.** If e : C ≌ D is an equivalence of finite categories, then κ(C) = κ(D).

This is the deepest result and the one that makes κ a genuine *categorical* invariant rather than a presentation-dependent quantity.

*Proof sketch.* We prove both inequalities κ(C) ≤ κ(D) and κ(D) ≤ κ(C).

For κ(C) ≤ κ(D): Let P' ⊆ Ob(D) be a separating family achieving κ(D). We claim that P := Image(e.inverse, P') ⊆ Ob(C) is separating in C.

The key step is the **transport lemma**: if P is separating in C and e : C ≌ D, then Image(e.functor, P) is separating in D.

*Proof of transport lemma.* Take f, g : X → Y in D with f ≫ h = g ≫ h for all Q ∈ Image(e.functor, P) and h : Y → Q. We show f = g.

1. **Faithfulness reduction:** Since e.inverse is faithful (equivalences are), it suffices to show e.inverse(f) = e.inverse(g).

2. **Apply separation in C:** By P separating in C, it suffices to show that for all Q₀ ∈ P and k : e.inverse(Y) → Q₀, we have e.inverse(f) ≫ k = e.inverse(g) ≫ k.

3. **Construct a D-morphism:** Given Q₀ ∈ P and k, define h' := ε_Y⁻¹ ≫ e.functor(k) : Y → e.functor(Q₀), where ε is the counit of the equivalence.

4. **Apply hypothesis:** Since e.functor(Q₀) ∈ Image(e.functor, P), the hypothesis gives f ≫ h' = g ≫ h'.

5. **Transport back:** Applying e.inverse and using the triangle identities of the equivalence, we obtain e.inverse(f) ≫ k ≫ η_{Q₀} = e.inverse(g) ≫ k ≫ η_{Q₀}, where η is the unit.

6. **Cancel the isomorphism:** Since η_{Q₀} is an isomorphism (in particular, a monomorphism), we cancel it to obtain e.inverse(f) ≫ k = e.inverse(g) ≫ k. □

By symmetry (applying the transport lemma to e.symm), we also get κ(D) ≤ κ(C), completing the proof by antisymmetry.

### 3.4 Theorem 4: Existence of Minimal Family

**Theorem.** There exists a Yoneda-separating family P with |P| = κ(C) that is minimal: for every separating Q, |P| ≤ |Q|.

*Proof sketch.* The definition of κ(C) via `Nat.find` immediately yields a witness with the correct cardinality, and `Nat.find_min'` gives the minimality property. □

### 3.5 Theorem 5: Thin Category Collapse (Cross-Domain Bridge)

**Theorem.** If C is a thin category (every hom-set has at most one element), then κ(C) = 0.

*Proof sketch.* In a thin category, any two parallel morphisms f, g : X → Y must be equal since Hom(X, Y) is a subsingleton. Therefore, the empty family ∅ is Yoneda-separating (the hypothesis is vacuously sufficient), and κ(C) ≤ |∅| = 0. □

**Significance.** This theorem bridges category theory to order theory: finite preorders and finite T₀ spaces, when viewed as thin categories, all have κ = 0. The compression number therefore detects genuinely non-thin categorical structure — the presence of distinct parallel morphisms — which is invisible to the underlying order/topology.

## 4. Algorithms

### 4.1 Brute-Force Algorithm

```
Algorithm CompressionNumber(C):
  Input: Finite category C
  Output: κ(C) and a witnessing separating family

  for k = 0, 1, ..., |Ob(C)|:
    for each P ⊆ Ob(C) with |P| = k:
      if IsYonedaSeparating(C, P):
        return (k, P)

Algorithm IsYonedaSeparating(C, P):
  for each (X, Y) ∈ Ob(C) × Ob(C):
    for each distinct pair f, g ∈ Hom(X, Y):
      separated := false
      for each Q ∈ P:
        for each h ∈ Hom(Y, Q):
          if f ≫ h ≠ g ≫ h:
            separated := true; break
      if not separated: return false
  return true
```

**Complexity.** Let n = |Ob(C)|, m = max |Hom(X,Y)|, and p = number of parallel pairs. The brute-force algorithm has time complexity O(C(n,k) · p · n · m) for each candidate size k, and total complexity O(2^n · p · n · m). This is exponential in n but practical for n ≤ 15.

### 4.2 Greedy Approximation

A greedy algorithm iteratively adds the object that separates the most remaining unseparated pairs. This runs in O(n² · p · m) time and provides an O(log p)-approximation to the optimal (by the standard set cover analysis). In practice, for the categories we tested, the greedy algorithm always found the optimal solution.

### 4.3 Correctness Theorem

The brute-force algorithm is correct by construction: it checks the mathematical definition directly. The connection between the executable algorithm and the mathematical definition is validated by testing agreement with the Lean-formalized `CompressionNumber` on all examples.

## 5. Computational Experiments

### 5.1 Computed Values

| Category | |Ob| | |Mor| | κ | Witness |
|----------|------|-------|---|---------|
| Discrete(n) | n | n | 0 | ∅ |
| TotalOrder(n) | n | n(n+1)/2 | 0 | ∅ |
| ParallelArrows(k), k≥2 | 2 | k+2 | 1 | {B} |
| Z/nZ (cyclic group) | 1 | n | 1 | {*} |
| S₃ (symmetric group) | 1 | 6 | 1 | {*} |
| ParallelArrows(2) × Discrete(2) | 4 | 8 | 2 | {(B,0), (B,1)} |
| ParallelArrows(2) × ParallelArrows(2) | 4 | 16 | 1 | {(B,B)} |

### 5.2 Key Observations

1. **Thin categories always have κ = 0**, confirming Theorem 5 computationally.

2. **One-object categories always have κ ≤ 1**, since the single object's representable either separates everything (if the monoid has right-cancellation detection) or the monoid is trivial (κ = 0).

3. **The product formula is subtle:** κ(C × D) is not simply max(κ(C), κ(D)) or κ(C) + κ(D). The example ParallelArrows(2) × Discrete(2) has κ = 2, exceeding both max(1,0) = 1 and 1 + 0 = 1.

4. **Monotonicity is confirmed** on all tested examples (as required by Theorem 2).

### 5.3 Separation Profiles

The separation profile — the count of separating families at each cardinality — reveals interesting structure. For Discrete(3): profile = {0:1, 1:3, 2:3, 3:1}, which follows the binomial coefficients (every subset separates). For ParallelArrows(2): profile = {0:0, 1:1, 2:1}, showing that only {B} and {A,B} separate, while {A} does not.

## 6. Applications

### 6.1 Sensor Placement

In a network modeled as a category (nodes = objects, processes = morphisms), κ gives the minimum number of observation points needed to distinguish all internal processes by monitoring outgoing traffic. This connects to the sensor placement problem in control theory and network monitoring.

### 6.2 Monoid Observability

For a monoid M viewed as a one-object category BM, Yoneda-separation reduces to right-cancellation detection: for all a ≠ b in M, there exists c with ac ≠ bc. This connects categorical observability to algebraic properties of monoids, providing a bridge between category theory and semigroup theory.

### 6.3 Process Distinguishability

In a state machine modeled as a category, κ measures the minimum number of output observation points needed to distinguish all internal transitions. This relates to the theory of observational equivalence and bisimulation in process algebra.

## 7. Discussion

### 7.1 What κ Detects

The compression number κ(C) detects the "thickness" of a category's morphism structure. Specifically:
- κ = 0 iff C is thin (all hom-sets are subsingletons) — the category is essentially an order
- κ > 0 signals the presence of non-trivially parallel morphisms
- Large κ indicates that multiple independent vantage points are needed to resolve the category's morphism structure

### 7.2 Limitations

Our current results are restricted to finite categories. The extension to locally finite or infinite categories requires careful treatment of the supremum over finite full subcategories. The brute-force algorithm is exponential in the number of objects, limiting practical computation to small categories. The Morita invariance conjecture remains open.

### 7.3 Relationship to Yoneda Philosophy

The compression number quantifies a key aspect of the Yoneda philosophy: "an object is determined by its relationships." Here we ask: "how many relationships suffice?" The answer — κ(C) — measures the informational redundancy in the full Yoneda embedding.

## 8. Future Work

1. **Morita invariance:** Prove or disprove that κ is invariant under Morita equivalence (equivalence of presheaf categories).
2. **Product formulas:** Determine the exact relationship between κ(C × D), κ(C), κ(D), |Ob(C)|, and |Ob(D)|.
3. **Monoid characterization:** Prove that κ(BM) = 1 for all finite monoids M with |M| > 1.
4. **Spectral bounds:** Develop linear-algebraic lower bounds on κ using morphism separation matrices.
5. **Infinite categories:** Extend κ to locally finite categories and connect to site presentation complexity in topos theory.

## 9. References

1. S. Mac Lane, *Categories for the Working Mathematician*, Springer, 1998.
2. F. Borceux, *Handbook of Categorical Algebra*, Cambridge University Press, 1994.
3. The mathlib Community, *mathlib4: Lean 4 Mathematics Library*, https://github.com/leanprover-community/mathlib4.
4. P. Johnstone, *Sketches of an Elephant: A Topos Theory Compendium*, Oxford University Press, 2002.
