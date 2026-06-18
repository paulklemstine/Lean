# Future Directions: Dynamical Proof Complexity

## Overview

The formalization of idempotent oracle collapse and its connection to adaptive hardness opens several concrete research directions. Each direction below includes specific theorem targets and proof strategies.

---

## 1. Quantitative Stabilization Hierarchy with Strict Separations

**Goal:** Construct explicit function families with *exact* stabilization depth $k$ for each $k \in \{1, 2, 3, \ldots\}$, proving strict separations between stabilization levels.

**Key Theorem Target:**
```lean
theorem exact_stabilization_depth_k (k : ℕ) (hk : 1 ≤ k) :
    ∃ f : (Fin (k + 1) → Bool) → (Fin (k + 1) → Bool),
      StabilizesIn f k ∧ ¬ StabilizesIn f (k - 1) := by ...
```

**Construction:** For depth $k$, define a "shift register" function on $\text{Fin}(k+1) \to \text{Bool}$ that shifts entries by one position:
$$f(\sigma)(i) = \begin{cases} \sigma(i+1) & \text{if } i < k \\ \sigma(0) & \text{if } i = k \end{cases}$$
This function stabilizes at depth $k$ (when the register becomes uniform) but not at depth $k-1$.

**Impact:** Provides a complete classification of Boolean oracle dynamics by stabilization depth, analogous to the polynomial hierarchy in classical complexity.

---

## 2. Closure-Operator Proof Systems and Monotone Collapse

**Goal:** Formalize monotone/extensive/idempotent (closure) operators as proof systems and prove that *all* closure-generated proof systems collapse to one-step proofs.

**Key Theorem Target:**
```lean
structure ClosureOperator (α : Type*) [PartialOrder α] where
  cl : α → α
  extensive : ∀ x, x ≤ cl x
  monotone : ∀ x y, x ≤ y → cl x ≤ cl y
  idempotent : ∀ x, cl (cl x) = cl x

theorem closure_proof_collapse {α : Type*} [PartialOrder α]
    (C : ClosureOperator α) :
    StabilizesIn C.cl 1 := by ...
```

**Extensions:**
- Prove that Galois connections between proof systems preserve stabilization depth.
- Show that non-closure proof operators (e.g., Heyting negation iteration) can witness arbitrary depth.
- Connect to abstract interpretation in program analysis: widening operators that are not idempotent require multiple fixed-point iterations.

**Impact:** Gives a semantic characterization of when proof search terminates in one step, directly applicable to automated theorem proving and static analysis.

---

## 3. Regret-Complexity Equivalence

**Goal:** Prove that nonzero asymptotic regret in online learning is *equivalent* to non-idempotent adaptive depth in the underlying update dynamics.

**Key Theorem Target:**
```lean
def AsymptoticRegretPositive (update : α → α) (loss : α → ℝ) : Prop :=
  ∃ ε > 0, ∀ T, ∃ x, (∑ t in range T, loss (update^[t] x)) -
    T * (⨅ y, loss y) ≥ ε * Real.sqrt T

theorem positive_regret_iff_nonidempotent
    (update : α → α) (loss : α → ℝ) :
    AsymptoticRegretPositive update loss ↔
    ¬ ∀ x, update (update x) = update x := by ...
```

**Proof Strategy:**
- Forward direction: if update is idempotent, the learner converges in one step, so regret is $O(1)$, not $\Omega(\sqrt{T})$.
- Backward direction: construct an adversarial loss sequence that exploits non-stabilization to force $\Omega(\sqrt{T})$ regret.

**Impact:** Provides a dynamical characterization of the multiplicative weights lower bound, connecting proof complexity to online learning theory.

---

## 4. Categorical Collapse via Splitting of Idempotents

**Goal:** Formalize the categorical perspective: in a category where all idempotents split, proof-system collapse factors through retract semantics.

**Key Theorem Target:**
```lean
structure SplitIdempotent (C : Type*) [Category C] (X : C) (e : X ⟶ X) where
  img : C
  section_ : img ⟶ X
  retraction : X ⟶ img
  split : section_ ≫ retraction = 𝟙 img
  idem : retraction ≫ section_ = e

theorem idempotent_factors_through_retract
    {C : Type*} [Category C] {X : C} {e : X ⟶ X}
    (he : e ≫ e = e) (s : SplitIdempotent C X e) :
    ∀ n ≥ 1, e ^ n = e := by ...
```

**Impact:** Shows that proof complexity collapse is a *categorical* phenomenon: any category with splitting of idempotents (which includes Set, Vect, and most algebraic categories) automatically admits the collapse theorem.

---

## 5. Finite-Model Hierarchy Separation on Boolean Cubes

**Goal:** On the Boolean cube $\{0,1\}^n$, construct explicit function families witnessing 1-step, 2-step, and 3-step stabilization gaps, and prove that these families are *complete* for their stabilization class.

**Key Theorem Targets:**
```lean
-- Projection (depth 1): always stabilizes immediately
theorem projection_stabilizes_one (n : ℕ) (S : Finset (Fin n)) :
    StabilizesIn (fun σ : Fin n → Bool => fun i =>
      if i ∈ S then σ i else false) 1 := by ...

-- Shift (depth n): requires n steps to stabilize
theorem shift_stabilizes_n (n : ℕ) (hn : 2 ≤ n) :
    StabilizesIn (fun σ : Fin n → Bool => fun i =>
      σ ⟨(i.val + 1) % n, Nat.mod_lt _ (by omega)⟩) n ∧
    ¬ StabilizesIn (fun σ : Fin n → Bool => fun i =>
      σ ⟨(i.val + 1) % n, Nat.mod_lt _ (by omega)⟩) (n - 1) := by ...

-- Completeness: every Boolean function has stabilization depth ≤ 2^(2^n)
theorem boolean_stabilization_bounded (n : ℕ)
    (f : (Fin n → Bool) → (Fin n → Bool)) :
    StabilizesIn f (2 ^ (2 ^ n)) := by ...
```

**Proof Strategy for Completeness:** The state space has $2^n$ elements, so the sequence $x, f(x), f^2(x), \ldots$ must eventually cycle within $2^{2^n}$ steps. If it cycles, repeated application within the cycle gives stabilization.

**Impact:** Gives concrete, computable complexity classes on finite domains with exact separation results.

---

## Cross-Domain Connection Map

| Direction | Logic | Complexity | Learning | Category Theory | Physics |
|-----------|-------|------------|----------|-----------------|---------|
| 1. Hierarchy | ✓ | ✓ | | | |
| 2. Closure | ✓ | ✓ | | | |
| 3. Regret | | ✓ | ✓ | | |
| 4. Categorical | ✓ | | | ✓ | |
| 5. Boolean | ✓ | ✓ | | | ✓ |

## Guiding Principle

**Hardness is the failure of stabilization.** Every future direction should be evaluated by whether it deepens our understanding of *why* certain proof/computation processes resist convergence, and whether the stabilization depth can serve as a new complexity measure competitive with circuit depth, proof length, or communication complexity.
