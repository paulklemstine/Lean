# Galois Insertion Closure Calculus for Expressive Model Logic

## A Formally Verified Framework for Semantic Closure, Fixed Points, and Lattice Transport

---

### Abstract

We develop the structural theory of the Galois insertion arising from the EML (Expressive Model Logic) closure operator on sets of real-valued functions. Starting from the inductive closure under constants, pointwise addition, multiplication, and function composition, we construct a Galois insertion between the complete lattice of generator sets and the type of EML-closed sets, then derive a comprehensive suite of consequences: the closure operator triple (extensivity, monotonicity, idempotence), fixed-point characterization of closed sets, binary and arbitrary lattice transport (preservation of sup/inf and sSup/sInf), minimality/universality theorems, intersection stability, and a concrete computation of the closure of the empty set. All results are machine-verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound). The framework creates reusable infrastructure for semantic compression, abstract interpretation, and thermodynamic closure principles in EML.

---

### 1. Introduction

#### 1.1 Motivation

The study of function algebras — collections of functions closed under algebraic and compositional operations — is central to approximation theory, computational complexity, and the foundations of machine learning. The classical Stone-Weierstrass theorem, for instance, characterizes when a subalgebra of continuous functions is dense, and its constructive variants have found applications in neural network expressivity.

The EML (Expressive Model Logic) framework generalizes these ideas by considering closure under a richer set of operations: constants, pointwise addition, pointwise multiplication, and function composition. The resulting closure operator on `Set (ℝ → ℝ)` defines a notion of "semantic completeness" for function classes.

A natural question arises: what is the *structure* of this closure? Is it merely a set-theoretic operation, or does it carry algebraic and order-theoretic content that can be systematically exploited?

#### 1.2 Contributions

We show that the EML closure gives rise to a **Galois insertion** between the lattice of generator sets and the type of EML-closed sets. From this single structure, we derive:

1. **Closure operator axioms** (Theorem 1): extensivity, monotonicity, and idempotence, packaged as a Mathlib `ClosureOperator`.
2. **Fixed-point characterization** (Theorem 2): a set is EML-closed iff it is a fixed point of the closure; the range of the upper adjoint equals the set of fixed points.
3. **Lattice transport** (Theorem 3): preservation of binary and arbitrary joins and meets through the adjunction.
4. **Minimality/universality** (Theorem 4): the closure is the least closed set above the input, and equals the infimum of all closed sets containing it.
5. **Cross-domain corollaries** (Theorem 5): intersection stability, bound transport, union distribution, and the concrete closure of ∅.

All results are formally verified in Lean 4.

#### 1.3 Related Work

Galois connections and insertions have been studied extensively in order theory (Ore, 1944; Birkhoff, 1967), abstract interpretation (Cousot & Cousot, 1977), and formal concept analysis (Ganter & Wille, 1999). The Mathlib library provides a comprehensive API for `GaloisConnection`, `GaloisInsertion`, and `ClosureOperator`.

Our contribution is to instantiate this abstract machinery for the concrete EML setting, proving that the inductive closure under the EML operations yields a genuine Galois insertion, and then extracting non-trivial structural consequences.

---

### 2. Definitions and Notation

#### 2.1 The EML Closure

**Definition 2.1** (EML Generation). Let `S ⊆ (ℝ → ℝ)`. We define the predicate `EMLGen S f` inductively by:
- **Base**: if `f ∈ S`, then `EMLGen S f`.
- **Constant**: for any `c : ℝ`, `EMLGen S (λ _ ⇒ c)`.
- **Addition**: if `EMLGen S f` and `EMLGen S g`, then `EMLGen S (λ x ⇒ f(x) + g(x))`.
- **Multiplication**: if `EMLGen S f` and `EMLGen S g`, then `EMLGen S (λ x ⇒ f(x) · g(x))`.
- **Composition**: if `EMLGen S f` and `EMLGen S g`, then `EMLGen S (λ x ⇒ f(g(x)))`.

**Definition 2.2** (EML Closure). `EMLCl(S) := {f : ℝ → ℝ | EMLGen S f}`.

#### 2.2 Order Structure

The ambient type `Set (ℝ → ℝ)` carries a complete lattice structure under inclusion (`⊆`). We write `⊔` for union, `⊓` for intersection, `sSup` for arbitrary union, and `sInf` for arbitrary intersection.

#### 2.3 Closure Operator

**Definition 2.3**. The EML closure operator `emlClOp : ClosureOperator (Set (ℝ → ℝ))` is defined by:
```
emlClOp.toFun := EMLCl
emlClOp.monotone' := emlCl_monotone
emlClOp.le_closure' := subset_emlCl
emlClOp.idempotent' := ...
```

#### 2.4 Galois Insertion

**Definition 2.4**. The EML Galois insertion is:
```
emlGI : GaloisInsertion emlClOp.toCloseds (Subtype.val : emlClOp.Closeds → Set (ℝ → ℝ))
emlGI := emlClOp.gi
```

The lower adjoint `l = emlClOp.toCloseds` maps a set to its closure (as a closed set), and the upper adjoint `u = Subtype.val` is the forgetful inclusion.

---

### 3. Main Results

#### 3.1 Theorem 1: Closure Operator Structure

**Theorem 3.1** (Closure Operator Triple).
```
(∀ A, A ⊆ EMLCl A) ∧ Monotone EMLCl ∧ (∀ A, EMLCl (EMLCl A) = EMLCl A)
```

*Proof sketch.* Extensivity follows from the `base` constructor. Monotonicity is proved by structural induction: if `A ⊆ B` and `EMLGen A f`, then `EMLGen B f` by replacing `base` invocations. Idempotence combines both directions: `EMLCl(EMLCl A) ⊆ EMLCl A` by induction (the `base` case gives `f ∈ EMLCl A`, which is the hypothesis), and `EMLCl A ⊆ EMLCl(EMLCl A)` by extensivity and monotonicity. □

#### 3.2 Theorem 2: Fixed-Point Characterization

**Theorem 3.2** (Fixed-Point Iff Closed).
```
emlClOp.IsClosed A ↔ EMLCl A = A
```

This is immediate from the definition of `ClosureOperator.IsClosed`.

**Theorem 3.3** (Range = Fixed Points).
```
A ∈ range(Subtype.val : emlClOp.Closeds → Set (ℝ → ℝ)) ↔ EMLCl A = A
```

*Proof.* Forward: if `A = C.val` for some closed `C`, then `C.property` gives `EMLCl A = A`. Backward: if `EMLCl A = A`, construct `⟨A, h⟩ : emlClOp.Closeds` and observe `Subtype.val ⟨A, h⟩ = A`. □

#### 3.3 Theorem 3: Lattice Transport

**Theorem 3.4** (Binary Sup Preservation).
```
emlClOp.toCloseds (A ⊔ B) = emlClOp.toCloseds A ⊔ emlClOp.toCloseds B
```

This follows directly from `GaloisConnection.l_sup`.

**Theorem 3.5** (Binary Inf Preservation).
```
(X ⊓ Y : emlClOp.Closeds).val = X.val ⊓ Y.val
```

This follows from `GaloisConnection.u_inf`.

**Theorem 3.6** (Arbitrary Sup Preservation).
```
emlClOp.toCloseds (sSup S) = sSup (emlClOp.toCloseds '' S)
```

*Proof.* By `GaloisConnection.l_sSup`, which gives the result in indexed-supremum form, then converting between `⨆ a ∈ S, l a` and `sSup (l '' S)`. □

**Theorem 3.7** (Arbitrary Inf Preservation).
```
(sInf T : emlClOp.Closeds).val = sInf (Subtype.val '' T)
```

Analogous, using `GaloisConnection.u_sInf`. □

**Corollary 3.8** (Complete Lattice on Closeds).
```
instance : CompleteLattice emlClOp.Closeds := emlGI.liftCompleteLattice
```

#### 3.4 Theorem 4: Minimality and Universality

**Theorem 3.9** (Minimality).
```
A ⊆ C → EMLCl C = C → EMLCl A ⊆ C
```

*Proof.* `EMLCl A ⊆ EMLCl C = C` by monotonicity and the fixed-point hypothesis. □

**Theorem 3.10** (Biconditional Minimality).
```
(EMLCl C = C) → (A ⊆ C ↔ EMLCl A ⊆ C)
```

*Proof.* Forward by Theorem 3.9. Backward by transitivity with extensivity: `A ⊆ EMLCl A ⊆ C`. □

**Theorem 3.11** (Variational Characterization).
```
EMLCl A = sInf {C | A ⊆ C ∧ EMLCl C = C}
```

*Proof.* By antisymmetry. (≤): `EMLCl A` is a lower bound of the set by Theorem 3.9, hence `≤ sInf`. (≥): `EMLCl A` is an element of the set (by extensivity and idempotence), hence `sInf ≤ EMLCl A`. □

#### 3.5 Theorem 5: Cross-Domain Corollaries

**Theorem 3.12** (Intersection Stability).
```
EMLCl A = A → EMLCl B = B → EMLCl (A ∩ B) = A ∩ B
```

*Proof.* (≤): `A ∩ B ⊆ A` gives `EMLCl(A ∩ B) ⊆ EMLCl A = A`; similarly for `B`. (≥): extensivity. □

**Theorem 3.13** (Union Distribution).
```
EMLCl (A ∪ B) = EMLCl (EMLCl A ∪ EMLCl B)
```

*Proof.* (≤): By monotonicity from `A ∪ B ⊆ EMLCl A ∪ EMLCl B`. (≥): By monotonicity from `EMLCl A ∪ EMLCl B ⊆ EMLCl(A ∪ B)`, then idempotence. □

**Theorem 3.14** (Closure of Empty Set).
```
EMLCl ∅ = {f | ∃ c : ℝ, f = λ _ ⇒ c}
```

*Proof.* (⊆): By induction on `EMLGen ∅ f`. The base case is vacuously true. Constants give `∃ c, f = λ _ ⇒ c` directly. Addition of constants gives a constant (c₁ + c₂). Multiplication gives c₁ · c₂. Composition of constants gives c₁. (⊇): By the `const` constructor. □

**Theorem 3.15** (Arbitrary Intersection of Closed Sets).
```
(∀ C ∈ S, EMLCl C = C) → S.Nonempty → EMLCl (⋂₀ S) = ⋂₀ S
```

*Proof.* (≤): For each `C ∈ S`, `⋂₀ S ⊆ C` gives `EMLCl(⋂₀ S) ⊆ EMLCl C = C`. (≥): extensivity. □

**Theorem 3.16** (Le-Closure-Iff Principle).
```
A ⊆ EMLCl B ↔ EMLCl A ⊆ EMLCl B
```

This is `ClosureOperator.le_closure_iff`, a direct consequence of the closure operator axioms. □

---

### 4. Applications

#### 4.1 Abstract Interpretation

The Galois insertion `emlGI` provides a sound abstraction framework: the generator side is the "concrete" domain, the closed side is the "abstract" domain, and the adjunction guarantees soundness. Theorem 3.10 (biconditional minimality) is the abstraction-concretization round-trip law. Theorem 3.12 (intersection stability) ensures that the abstract domain is closed under meets, enabling greatest-fixed-point computations.

#### 4.2 Semantic Compression

The minimality theorem (3.9) says that `EMLCl A` is the *tightest* closed approximation of `A`. This makes closure a canonical semantic compression: given an arbitrary collection of functions, the closure produces the minimal self-sufficient extension. The bound-transport corollary (Theorem 3.9 applied with a "complexity bound" `C`) says that complexity bounds propagate through closure.

#### 4.3 Function Class Expressivity

The closure-of-empty-set result (Theorem 3.14) gives a ground truth: with no generators, the only expressible functions are constants. This baseline, combined with the lattice transport theorems, enables systematic analysis of what additional generators "buy" in terms of expressivity. For instance, adding a single non-constant generator can dramatically enlarge the closure.

#### 4.4 Thermodynamic Analogy

The three closure laws mirror thermodynamic principles:
- **Extensivity** ↔ entropy never decreases spontaneously.
- **Idempotence** ↔ equilibrium states are stable.
- **Minimality** ↔ free energy is minimized at equilibrium.

The fixed-point characterization (Theorem 3.2) identifies equilibrium states as exactly the fixed points of the closure dynamics. The variational characterization (Theorem 3.11) is a formal analogue of the variational principle in statistical mechanics.

---

### 5. Computational Aspects

#### 5.1 Decidability

The EML closure is not decidable in general: determining whether a function `f` belongs to `EMLCl(S)` requires searching over all finite compositions of the EML operations. However, for finite sets of polynomial or rational generators, the closure is recursively enumerable.

#### 5.2 Algorithms

**Algorithm 1: Closure Membership Test (Semi-Decision)**
```
Input: Generator set S (finite), target function f, depth bound d
Output: True if f ∈ EMLCl(S) witnessed at depth ≤ d

1. Initialize candidates := S ∪ {λ _ ⇒ c | c ∈ relevant constants}
2. For k = 1 to d:
   a. For each (g, h) ∈ candidates²:
      - Add (λ x ⇒ g(x) + h(x)) to candidates
      - Add (λ x ⇒ g(x) · h(x)) to candidates
      - Add (λ x ⇒ g(h(x))) to candidates
   b. If f ∈ candidates: return True
3. Return Unknown
```

Time complexity: O(|candidates|² · d) per iteration, with |candidates| growing cubically per level.

#### 5.3 Approximation

For numerical applications, one can approximate closure membership by evaluating functions at a finite grid of points and checking if the target function can be approximated to within ε by a depth-d composition from the generators.

---

### 6. Discussion

#### 6.1 Generality

The results in this paper are stated for `Set (ℝ → ℝ)` with the specific EML operations (constants, +, ×, ∘), but the proof techniques are largely general. Any inductive closure operation on a complete lattice will yield a Galois insertion, and the lattice transport, minimality, and fixed-point theorems will follow. The key EML-specific content is the concrete computation of `EMLCl ∅` and the intersection stability result.

#### 6.2 Limitations

The current formalization treats functions extensionally (as elements of `ℝ → ℝ`), which means two functions are equal iff they agree on all inputs. This is mathematically natural but computationally intractable. A future direction is to work with syntactic representations (expression trees) and relate them to the semantic closure.

#### 6.3 Relationship to Other Catalog Theorems

The EML closure calculus connects to several existing results in the catalog:
- **`sheffer_add_closed`**: additive closure in Sheffer algebras is an instance of the general intersection-stability principle (Theorem 3.12).
- **`uc_crystal_add_closed`**: crystalline additive closure can be analyzed through the lattice transport machinery.
- **`derivable_deficiency_implies_semantic_bound`**: the bound-transport corollary shows that semantic deficiency bounds are stable under closure.
- **`logSumExp_convex_and_second_derivative_eq_variance`**: the variational characterization (Theorem 3.11) is a discrete analogue of the convex-analytic variational principles underlying log-sum-exp.

---

### 7. Future Work

See `FUTURE_DIRECTIONS.md` for detailed next steps. Key targets include:
1. Fixed-point lattice completeness via order isomorphism.
2. Algebraic compatibility (closure commutes with pointwise operations).
3. Deficiency monotonicity under closure.
4. Abstract interpretation monad structure.
5. Convex-thermodynamic representation theorems.

---

### 8. References

1. Birkhoff, G. (1967). *Lattice Theory*, 3rd edition. AMS.
2. Cousot, P. and Cousot, R. (1977). Abstract interpretation: a unified lattice model for static analysis of programs by construction or approximation of fixpoints. *POPL*.
3. Davey, B.A. and Priestley, H.A. (2002). *Introduction to Lattices and Order*, 2nd edition. Cambridge University Press.
4. Ganter, B. and Wille, R. (1999). *Formal Concept Analysis: Mathematical Foundations*. Springer.
5. Ore, O. (1944). Galois connexions. *Transactions of the AMS*, 55(3), 493–513.
6. The Mathlib Community (2024). Mathlib4: The Lean 4 Mathematical Library. https://github.com/leanprover-community/mathlib4

---

### Appendix: Axiom Audit

All theorems depend only on the standard Lean 4 axioms:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)

No `sorry`, `axiom`, or `@[implemented_by]` declarations are used.
