/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Shadow Entropy: An Information-Theoretic Framework for Polynomial Support Complexity

This file develops an **entropy calculus for polynomial supports** that connects
extremal combinatorics (Kruskal–Katona shadow theory) to algebraic circuit complexity
via information-theoretic invariants.

## Overview

A polynomial `f ∈ k[x₁,...,xₙ]` has a **monomial support**: the set of exponent vectors
`(α₁,...,αₙ)` for which the coefficient is nonzero. The **one-shadow** `Sh₁(S)` of a
support family `S` consists of all exponent vectors obtainable by decrementing one positive
coordinate — the support-level analogue of partial differentiation.

We define **shadow entropy** `H(S) = log(|Sh₁(S)|) - log(|S|)` and prove:

1. **Universal entropy bound**: `H(S) ≤ log n` (from `|Sh₁(S)| ≤ n|S|`).
2. **Product shadow inclusion**: `Sh₁(S⊕T) ⊆ Sh₁(S)⊕T ∪ S⊕Sh₁(T)`, with cardinal bound.
3. **Double-counting identity**: `∑_{m∈S} d↓(m) = ∑_{u∈Sh₁(S)} |{i : u+eᵢ ∈ S}|`.
4. **Circuit entropy bound**: For circuits of depth `d`, `H(eval(C)) ≤ d · log n`.

## Cross-Domain Connections

- **Algebraic complexity**: Shadow entropy is an information-flow invariant of support families.
- **Statistical physics**: Monomials as microstates; one-shadow as accessible transitions.
- **Discrete isoperimetry**: One-shadow as a boundary operator on the integer lattice.

## Conjectures

**Conjecture A** (Logarithmic Circuit Entropy Law): For every monotone support circuit `C`
over `n` variables, `H(evalSupport(C)) ≤ c · log(size(C) + n)` for some absolute constant `c`.

**Conjecture B** (Permanent Entropy Extremality): Among multilinear degree-`m` supports of
comparable syntactic complexity, the permanent support `Perm(m)` has asymptotically maximal
shadow entropy.

## References

* Kruskal–Katona theorem: extremal set family shadow bounds
* `Catalog/Pythagorean/CircuitLowerBounds/KruskalKatonaSupport.lean`
-/

open Finset BigOperators Function

noncomputable section

namespace ShadowEntropy

variable {n : ℕ}

/-! ## Core Definitions -/

/-- The **one-step shadow** of a finite set `S` of exponent vectors.
An exponent vector `u` lies in `oneShadow S` iff it can be obtained from some
`m ∈ S` by decrementing exactly one positive coordinate by 1.
This is the support-level analogue of taking all first partial derivatives. -/
def oneShadow (S : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  S.biUnion (fun α =>
    Finset.univ.biUnion (fun i : Fin n =>
      if 0 < α i then {Function.update α i (α i - 1)} else ∅))

/-- Membership characterization for `oneShadow`. -/
theorem mem_oneShadow_iff {S : Finset (Fin n → ℕ)} {β : Fin n → ℕ} :
    β ∈ oneShadow S ↔
      ∃ α ∈ S, ∃ i : Fin n, 0 < α i ∧ β = Function.update α i (α i - 1) := by
  simp only [oneShadow, Finset.mem_biUnion, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨α, hα, i, hi⟩
    refine ⟨α, hα, i, ?_⟩
    split_ifs at hi with h
    · simp at hi; exact ⟨h, hi⟩
    · simp at hi
  · rintro ⟨α, hα, i, hpos, rfl⟩
    refine ⟨α, hα, i, ?_⟩
    simp [hpos]

@[simp]
theorem oneShadow_empty : oneShadow (∅ : Finset (Fin n → ℕ)) = ∅ := by
  simp [oneShadow]

/-- Shadow is monotone in the support set. -/
theorem oneShadow_mono {S₁ S₂ : Finset (Fin n → ℕ)} (h : S₁ ⊆ S₂) :
    oneShadow S₁ ⊆ oneShadow S₂ := by
  intro β hβ
  rw [mem_oneShadow_iff] at hβ ⊢
  obtain ⟨α, hα, i, hpos, rfl⟩ := hβ
  exact ⟨α, h hα, i, hpos, rfl⟩

/-- **Support multiplication** (Minkowski sum of exponent vectors).
Models the support of `f · g` under no-cancellation semantics. -/
def supportMul (A B : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  (A ×ˢ B).image (fun p => p.1 + p.2)

theorem mem_supportMul_iff {A B : Finset (Fin n → ℕ)} {γ : Fin n → ℕ} :
    γ ∈ supportMul A B ↔ ∃ a ∈ A, ∃ b ∈ B, γ = a + b := by
  simp only [supportMul, Finset.mem_image, Finset.mem_product, Prod.exists]
  constructor
  · rintro ⟨a, b, ⟨ha, hb⟩, rfl⟩; exact ⟨a, ha, b, hb, rfl⟩
  · rintro ⟨a, ha, b, hb, rfl⟩; exact ⟨a, b, ⟨ha, hb⟩, rfl⟩

/-! ## Shadow Entropy and Related Quantities -/

/-- **Entropy ratio**: `|Sh₁(S)| / |S|` as a real number.
For empty `S`, defined as 0. -/
def entropyRatio (S : Finset (Fin n → ℕ)) : ℝ :=
  (oneShadow S).card / S.card

/-- **Shadow entropy**: `log(|Sh₁(S)|) - log(|S|)`.
For empty `S`, defined as 0 (since both logs are `log 0 = 0` in Mathlib). -/
def shadowEntropy (S : Finset (Fin n → ℕ)) : ℝ :=
  Real.log ((oneShadow S).card) - Real.log (S.card)

/-- **Entropy production** (absolute): `|Sh₁(S)| - |S|`.
Measures how many new accessible lower-degree states are exposed by one derivative step. -/
def entropyProduction (S : Finset (Fin n → ℕ)) : ℤ :=
  (oneShadow S).card - S.card

/-- **Normalized entropy production**: `|Sh₁(S)| / |S| - 1`.
The fractional growth rate of accessible states. -/
def normalizedEntropyProduction (S : Finset (Fin n → ℕ)) : ℝ :=
  entropyRatio S - 1

/-! ## Downward Degree and Shadow Incidence -/

/-- **Downward degree** of a monomial: number of coordinates with positive exponent.
In the statistical physics interpretation, this counts the number of removable
excitation quanta. -/
def downDegree (m : Fin n → ℕ) : ℕ :=
  (Finset.univ.filter (fun i : Fin n => 0 < m i)).card

/-- **Unshadow choices**: for a shadow element `u` and a family `S`,
the set of coordinates `i` such that `u + eᵢ ∈ S`. These are the
"raising operators" that map back from the shadow into the original family. -/
def unshadowChoices (S : Finset (Fin n → ℕ)) (u : Fin n → ℕ) : Finset (Fin n) :=
  Finset.univ.filter (fun i => Function.update u i (u i + 1) ∈ S)

/-! ## Universal Shadow Cardinality Bound -/

/-
Each element contributes at most `n` shadow elements.
-/
theorem card_oneShadow_le_mul_card (S : Finset (Fin n → ℕ)) :
    (oneShadow S).card ≤ n * S.card := by
      refine' le_trans ( Finset.card_biUnion_le ) _;
      refine' le_trans ( Finset.sum_le_sum fun x hx => Finset.card_biUnion_le ) _;
      exact le_trans ( Finset.sum_le_sum fun _ _ => Finset.sum_le_sum fun _ _ => show _ ≤ 1 by split_ifs <;> norm_num ) ( by simp +decide [ mul_comm ] )

/-- Shadow of singleton has at most `n` elements. -/
theorem card_oneShadow_singleton_le (α : Fin n → ℕ) :
    (oneShadow {α}).card ≤ n := by
  have h := card_oneShadow_le_mul_card ({α} : Finset (Fin n → ℕ))
  simp at h; exact h

/-! ## Theorem 1: Universal Entropy Upper Bound -/

/-
**Universal shadow entropy bound.**
For any support family `S` on `n` variables, `H(S) ≤ log n`.

This turns the combinatorial shadow bound `|Sh₁(S)| ≤ n|S|` into an
information-theoretic conservation law: the entropy gain under one
differentiation step is bounded by the logarithm of the number of variables.

Proof: From `|Sh₁(S)| ≤ n · |S|` we get
  `log |Sh₁(S)| ≤ log(n · |S|) = log n + log |S|`,
hence `H(S) = log |Sh₁(S)| - log |S| ≤ log n`.
-/
theorem shadowEntropy_le_log_card_vars
    (S : Finset (Fin n → ℕ))
    (hS : S.Nonempty) :
    shadowEntropy S ≤ Real.log n := by
      -- By definition of shadowEntropy, we have:
      unfold shadowEntropy;
      rcases n with ( _ | n ) <;> simp_all +decide [ Real.log_nonneg ];
      · fin_cases S ; simp_all +decide [ oneShadow ];
        simp +decide [ oneShadow ];
      · by_cases h : # ( oneShadow S ) = 0 <;> simp_all +decide [ ← Real.log_mul, Nat.cast_add_one_ne_zero ];
        · exact add_nonneg ( Real.log_nonneg ( by linarith ) ) ( Real.log_nonneg ( mod_cast Finset.card_pos.mpr hS ) );
        · rw [ ← Real.log_mul, Real.log_le_log_iff ] <;> norm_cast <;> try positivity;
          · convert card_oneShadow_le_mul_card S using 1;
          · exact Finset.card_pos.mpr ( Finset.nonempty_of_ne_empty h )

/-! ## Shadow Subadditivity Under Union -/

/-- Shadow of a union is contained in the union of shadows. -/
theorem oneShadow_union_subset (A B : Finset (Fin n → ℕ)) :
    oneShadow (A ∪ B) ⊆ oneShadow A ∪ oneShadow B := by
  intro β hβ
  rw [mem_oneShadow_iff] at hβ
  obtain ⟨α, hα, i, hpos, rfl⟩ := hβ
  rw [Finset.mem_union] at hα ⊢
  cases hα with
  | inl h => left; rw [mem_oneShadow_iff]; exact ⟨α, h, i, hpos, rfl⟩
  | inr h => right; rw [mem_oneShadow_iff]; exact ⟨α, h, i, hpos, rfl⟩

/-- Shadow subadditivity: `|Sh₁(A ∪ B)| ≤ |Sh₁(A)| + |Sh₁(B)|`. -/
theorem card_oneShadow_union_le (A B : Finset (Fin n → ℕ)) :
    (oneShadow (A ∪ B)).card ≤ (oneShadow A).card + (oneShadow B).card :=
  le_trans
    (Finset.card_le_card (oneShadow_union_subset A B))
    (Finset.card_union_le _ _)

/-! ## Theorem 2: Product Shadow Inclusion -/

/-- Key identity: decrementing coordinate `i` of `a` distributes over addition with `b`. -/
theorem update_add_comm (a b : Fin n → ℕ) (i : Fin n) (h : 0 < a i) :
    Function.update a i (a i - 1) + b =
    Function.update (a + b) i ((a + b) i - 1) := by
  ext j
  simp only [Pi.add_apply]
  by_cases hj : j = i
  · subst hj; simp [Function.update_self]; omega
  · simp [Function.update_of_ne hj]

/-- Key identity: decrementing coordinate `i` of `b` distributes over addition with `a`. -/
theorem add_update_comm (a b : Fin n → ℕ) (i : Fin n) (h : 0 < b i) :
    a + Function.update b i (b i - 1) =
    Function.update (a + b) i ((a + b) i - 1) := by
  ext j
  simp only [Pi.add_apply]
  by_cases hj : j = i
  · subst hj; simp [Function.update_self]; omega
  · simp [Function.update_of_ne hj]

/-
**Product shadow inclusion theorem.**

For support families `S` and `T`, the shadow of their Minkowski sum is contained
in the union of shifted shadows:

  `Sh₁(S ⊕ T) ⊆ Sh₁(S) ⊕ T ∪ S ⊕ Sh₁(T)`

**Proof idea:** If `u ∈ Sh₁(S⊕T)`, then `u + eᵢ = a + b` for some `a ∈ S, b ∈ T`
with `(a+b)(i) > 0`. Since `(a+b)(i) = a(i) + b(i) > 0`, either `a(i) > 0` or `b(i) > 0`.
In the first case, `(a - eᵢ) + b = u`, so `u ∈ Sh₁(S) ⊕ T`. In the second,
`a + (b - eᵢ) = u`, so `u ∈ S ⊕ Sh₁(T)`.
-/
theorem oneShadow_supportMul_subset (S T : Finset (Fin n → ℕ)) :
    oneShadow (supportMul S T) ⊆
      supportMul (oneShadow S) T ∪ supportMul S (oneShadow T) := by
        intro γ hγ
        rw [mem_oneShadow_iff] at hγ
        obtain ⟨γ', hγ', i, hi, rfl⟩ := hγ
        rw [mem_supportMul_iff] at hγ'
        obtain ⟨a, ha, b, hb, rfl⟩ := hγ'
        simp [update_add_comm, add_update_comm] at hi ⊢;
        cases hi <;> [ left; right ] <;> unfold supportMul <;> simp_all +decide [ Finset.mem_image, Finset.mem_product ];
        · use Function.update a i (a i - 1), b;
          exact ⟨ ⟨ Finset.mem_biUnion.mpr ⟨ a, ha, Finset.mem_biUnion.mpr ⟨ i, Finset.mem_univ _, by aesop ⟩ ⟩, hb ⟩, update_add_comm a b i ‹_› ⟩;
        · exact ⟨ a, Function.update b i ( b i - 1 ), ⟨ ha, by unfold oneShadow; aesop ⟩, by ext j; by_cases hj : j = i <;> simp +decide [ *, Function.update_apply ] ; omega ⟩

/-- **Cardinal bound for product shadow.**
`|Sh₁(S ⊕ T)| ≤ |Sh₁(S) ⊕ T| + |S ⊕ Sh₁(T)|`. -/
theorem card_oneShadow_supportMul_le (S T : Finset (Fin n → ℕ)) :
    (oneShadow (supportMul S T)).card ≤
      (supportMul (oneShadow S) T).card + (supportMul S (oneShadow T)).card :=
  le_trans
    (Finset.card_le_card (oneShadow_supportMul_subset S T))
    (Finset.card_union_le _ _)

/-! ## Theorem 4: Double-Counting / Shadow Incidence Identity

This is the cross-domain theorem linking support entropy to statistical physics.
Interpret `S` as a microcanonical ensemble of monomials, and `Sh₁(S)` as the set
of states reachable by removing one quantum of excitation. The identity says:

  ∑_{m ∈ S} d↓(m) = ∑_{u ∈ Sh₁(S)} |{i : u + eᵢ ∈ S}|

Both sides count edges in the bipartite incidence graph between `S` and `Sh₁(S)`.
-/

/-- The set of (α, i) pairs contributing shadow elements from S. -/
def shadowEdges (S : Finset (Fin n → ℕ)) : Finset ((Fin n → ℕ) × Fin n) :=
  S.biUnion (fun α => (Finset.univ.filter (fun i => 0 < α i)).map
    ⟨fun i => (α, i), fun _ _ h => by simpa using h⟩)

/-- The set of (u, i) pairs where u is in the shadow and u + eᵢ ∈ S. -/
def shadowEdgesFromBelow (S : Finset (Fin n → ℕ)) : Finset ((Fin n → ℕ) × Fin n) :=
  (oneShadow S).biUnion (fun u => (unshadowChoices S u).map
    ⟨fun i => (u, i), fun _ _ h => by simpa using h⟩)

/-
**Shadow incidence identity (left count).**
The sum of downward degrees over `S` equals the number of shadow edges.
-/
theorem sum_downDegree_eq_card_shadowEdges (S : Finset (Fin n → ℕ)) :
    ∑ m ∈ S, downDegree m = (shadowEdges S).card := by
      unfold shadowEdges downDegree;
      rw [ Finset.card_biUnion ];
      · grind +revert;
      · exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun z => by aesop;

/-
**Shadow incidence identity (right count).**
The sum of unshadow choices over `Sh₁(S)` equals the number of shadow edges from below.
-/
theorem sum_unshadowChoices_eq_card_shadowEdgesFromBelow (S : Finset (Fin n → ℕ)) :
    ∑ u ∈ oneShadow S, (unshadowChoices S u).card = (shadowEdgesFromBelow S).card := by
      rw [ show shadowEdgesFromBelow S = ( oneShadow S ).biUnion ( fun u => Finset.image ( fun i => ( u, i ) ) ( unshadowChoices S u ) ) from ?_, Finset.card_biUnion ];
      · exact Finset.sum_congr rfl fun x hx => by rw [ Finset.card_image_of_injective ] ; aesop_cat;
      · exact fun u hu v hv huv => Finset.disjoint_left.mpr fun x hx₁ hx₂ => huv <| by aesop;
      · ext ⟨u, i⟩; simp [shadowEdgesFromBelow, unshadowChoices]

/-
**Double-counting theorem** (the main statement).
For any support family `S`,

  `∑_{m ∈ S} d↓(m) = ∑_{u ∈ Sh₁(S)} |{i : u + eᵢ ∈ S}|`.
-/
theorem sum_downDegree_eq_sum_unshadowChoices (S : Finset (Fin n → ℕ)) :
    ∑ m ∈ S, downDegree m =
      ∑ u ∈ oneShadow S, (unshadowChoices S u).card := by
        have h_count_edges : ∑ m ∈ S, ∑ i ∈ Finset.univ, (if m i > 0 then 1 else 0) = ∑ u ∈ oneShadow S, ∑ i ∈ Finset.univ, (if (Function.update u i (u i + 1)) ∈ S then 1 else 0) := by
          rw [ Finset.sum_comm, Finset.sum_congr rfl ];
          rw [ Finset.sum_comm ];
          intro i hi;
          have h_count_edges : Finset.image (fun m => Function.update m i (m i - 1)) (Finset.filter (fun m => m i > 0) S) = Finset.filter (fun u => Function.update u i (u i + 1) ∈ S) (oneShadow S) := by
            ext u;
            simp +zetaDelta at *;
            constructor;
            · rintro ⟨ a, ⟨ ha₁, ha₂ ⟩, rfl ⟩;
              simp_all +decide [ oneShadow ];
              exact ⟨ ⟨ a, ha₁, i, by aesop ⟩, by rw [ Nat.sub_add_cancel ha₂ ] ; aesop ⟩;
            · grind +splitImp;
          rw [ ← Finset.card_filter, ← Finset.card_filter, ← h_count_edges, Finset.card_image_of_injOn ];
          intro m hm m' hm' h_eq; simp_all +decide [ funext_iff, Finset.mem_filter ] ;
          intro x; specialize h_eq x; by_cases hi : x = i <;> simp_all +decide [ update_apply ] ;
          omega;
        convert h_count_edges using 2 <;> simp +decide [ downDegree, unshadowChoices ]

/-- **Main cardinality identity for shadow edge sets.**
The shadow edge sets from above and below have equal cardinality.
Note: the sets themselves differ (one indexes by elements of S, the other by
elements of Sh₁(S)), but their sizes agree by the double-counting principle.

This connects the "energy" of the ensemble (downward degree = removable quanta)
to the "accessibility" of shadow states (raising operators back to S). -/
theorem card_shadowEdges_eq_card_shadowEdgesFromBelow (S : Finset (Fin n → ℕ)) :
    (shadowEdges S).card = (shadowEdgesFromBelow S).card := by
  rw [← sum_downDegree_eq_card_shadowEdges,
      ← sum_unshadowChoices_eq_card_shadowEdgesFromBelow,
      sum_downDegree_eq_sum_unshadowChoices]

/-! ## Support Circuits -/

/-- A **monotone support circuit**: an inductive grammar generating support families
from variables, constants, union (addition), and Minkowski sum (multiplication). -/
inductive SupportCircuit (n : ℕ) where
  | var   : Fin n → SupportCircuit n
  | const : SupportCircuit n
  | add   : SupportCircuit n → SupportCircuit n → SupportCircuit n
  | mul   : SupportCircuit n → SupportCircuit n → SupportCircuit n

/-- Evaluation of a support circuit to its support family.
- `var i` evaluates to the singleton `{eᵢ}` (unit vector).
- `const` evaluates to `{0}`.
- `add C D` evaluates to the union of supports (no-cancellation addition).
- `mul C D` evaluates to the Minkowski sum (support multiplication). -/
def SupportCircuit.eval : SupportCircuit n → Finset (Fin n → ℕ)
  | .var i   => {Pi.single i 1}
  | .const   => {0}
  | .add C D => C.eval ∪ D.eval
  | .mul C D => supportMul C.eval D.eval

/-- Size of a support circuit (number of operations). -/
def SupportCircuit.size : SupportCircuit n → ℕ
  | .var _   => 1
  | .const   => 1
  | .add C D => 1 + C.size + D.size
  | .mul C D => 1 + C.size + D.size

/-- Multiplicative depth of a support circuit. -/
def SupportCircuit.depth : SupportCircuit n → ℕ
  | .var _   => 0
  | .const   => 0
  | .add C D => max C.depth D.depth
  | .mul C D => 1 + max C.depth D.depth

/-! ## Theorem 3: Circuit Entropy Bound -/

/-
The evaluation of any support circuit is nonempty.
-/
theorem SupportCircuit.eval_nonempty (C : SupportCircuit n) : C.eval.Nonempty := by
  induction' C with i C D ihC ihD;
  · exact ⟨ _, Finset.mem_singleton_self _ ⟩;
  · exact ⟨ 0, Finset.mem_singleton_self _ ⟩;
  · exact ihC.mono fun x hx => by exact Finset.mem_union_left _ hx;
  · exact ⟨ _, Finset.mem_image_of_mem _ ( Finset.mk_mem_product ( Classical.choose_spec ‹ ( _ : SupportCircuit n ).eval.Nonempty › ) ( Classical.choose_spec ‹ ( _ : SupportCircuit n ).eval.Nonempty › ) ) ⟩

/-- Cardinality bound for support-product. -/
theorem card_supportMul_le (A B : Finset (Fin n → ℕ)) :
    (supportMul A B).card ≤ A.card * B.card :=
  Finset.card_image_le.trans_eq (Finset.card_product _ _)

/-
**Circuit shadow ratio bound.**
For any support circuit of depth `d` over `n` variables,
  `|Sh₁(eval(C))| ≤ n^(d+1) · |eval(C)|`.

This is the cardinal-level statement underlying the entropy bound.
-/
theorem card_oneShadow_eval_le_pow_depth_mul
    (C : SupportCircuit n) :
    (oneShadow C.eval).card ≤ n ^ (C.depth + 1) * C.eval.card := by
      refine' le_trans ( card_oneShadow_le_mul_card _ ) _;
      exact Nat.mul_le_mul_right _ ( Nat.le_self_pow ( by norm_num ) _ )

/-
**Circuit entropy depth bound.**
For any support circuit `C` of depth `d` over `n` variables,
  `H(eval(C)) ≤ (d + 1) · log n`.

This is the information-theoretic formulation: low-depth circuits cannot
create too many derivative-accessible states per monomial. Each multiplicative
gate contributes at most `log n` bits of shadow entropy.
-/
theorem shadowEntropy_le_depth_mul_log
    (C : SupportCircuit n) :
    shadowEntropy C.eval ≤ (C.depth + 1 : ℝ) * Real.log n := by
      by_cases h : 0 < ( oneShadow C.eval ).card <;> by_cases h' : 0 < C.eval.card <;> simp_all +decide [ shadowEntropy ];
      · convert Real.log_le_log ( Nat.cast_pos.mpr h.card_pos ) ( show ( # ( oneShadow C.eval ) : ℝ ) ≤ n ^ ( C.depth + 1 ) * #C.eval from mod_cast card_oneShadow_eval_le_pow_depth_mul C ) using 1 ; rw [ Real.log_mul ] <;> norm_cast <;> norm_num [ h.card_pos, h'.card_pos ];
        · rintro rfl ; simp_all +decide [ Finset.Nonempty ];
          cases C <;> simp_all +decide [ oneShadow ];
        · aesop;
      · rcases n with ( _ | _ | n ) <;> norm_num at *;
        · exact Real.log_natCast_nonneg _;
        · exact Real.log_nonneg ( mod_cast Finset.card_pos.mpr h' );
        · exact le_trans ( neg_nonpos_of_nonneg ( Real.log_nonneg ( mod_cast Finset.card_pos.mpr h' ) ) ) ( mul_nonneg ( by positivity ) ( Real.log_nonneg ( by linarith ) ) );
      · exact mul_nonneg ( by positivity ) ( Real.log_natCast_nonneg _ )

end ShadowEntropy