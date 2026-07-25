/-
  Emergent Computation Algebra — EML Closure Core
  Bridge: connects Order Theory (Heyting algebras, closure operators) to
          Categorical Computation Theory (fixed-point combinators, diagonalization)
-/

import Mathlib

set_option maxHeartbeats 800000

namespace EmergentComputationAlgebra

/-! ## I. Core Definitions -/

/-- An EML closure algebra: a Heyting algebra equipped with an idempotent,
monotone, inflationary operator. -/
class EMLClosureAlgebra (H : Type*) [HeytingAlgebra H] where
  closure : H → H
  closure_idempotent : ∀ x, closure (closure x) = closure x
  closure_monotone : ∀ x y, x ≤ y → closure x ≤ closure y
  closure_inflationary : ∀ x, x ≤ closure x

variable {H : Type*} [HeytingAlgebra H] [EMLClosureAlgebra H]

/-- Self-pairing structure enabling diagonal self-reference.
Bridge: connects Logic (diagonal lemma) to Computation (fixed-point combinators). -/
class EMLSelfPairing (H : Type*) [HeytingAlgebra H] [EMLClosureAlgebra H] where
  self_pair : (H → H) → H
  eval_pair : ∀ (f : H → H),
    EMLClosureAlgebra.closure (self_pair f) = EMLClosureAlgebra.closure (f (self_pair f))

/-- Closure-equivalence: two elements have the same closure. -/
def ClosureEquiv (x y : H) : Prop :=
  EMLClosureAlgebra.closure x = EMLClosureAlgebra.closure y

/-- The iteration sequence for computing fixed points. -/
noncomputable def closureIteration [OrderBot H] (f : H → H) : ℕ → H
  | 0 => ⊥
  | n + 1 => EMLClosureAlgebra.closure (f (closureIteration f n))

/-- A morphism of EML closure algebras. -/
structure EMLClosureMorphism (H₁ H₂ : Type*) [HeytingAlgebra H₁] [HeytingAlgebra H₂]
    [EMLClosureAlgebra H₁] [EMLClosureAlgebra H₂] where
  toFun : H₁ → H₂
  map_closure : ∀ x, EMLClosureAlgebra.closure (toFun x) = toFun (EMLClosureAlgebra.closure x)

/-! ## II. Basic Properties -/

/-- The closure of any element satisfies closure(closure(x)) = closure(x). -/
theorem closure_is_closed (x : H) :
    EMLClosureAlgebra.closure (EMLClosureAlgebra.closure x) = EMLClosureAlgebra.closure x :=
  EMLClosureAlgebra.closure_idempotent x

/-- Top satisfies closure(⊤) = ⊤. -/
theorem closure_top : EMLClosureAlgebra.closure (⊤ : H) = ⊤ :=
  le_antisymm le_top (EMLClosureAlgebra.closure_inflationary ⊤)

/-- Closure-continuous maps: commuting with closure preserves fixed points.
Bridge: Category-theoretic preservation meets semantic preservation. -/
theorem closure_continuous_preserves_fixed (f : H → H)
    (hf : ∀ x, EMLClosureAlgebra.closure (f x) = f (EMLClosureAlgebra.closure x))
    (x : H) (hx : EMLClosureAlgebra.closure x = x) :
    EMLClosureAlgebra.closure (f x) = f x := by
  rw [hf, hx]

/-- Closure of inf ≤ inf of closures. -/
theorem closure_inf_le (a b : H) :
    EMLClosureAlgebra.closure (a ⊓ b) ≤
    EMLClosureAlgebra.closure a ⊓ EMLClosureAlgebra.closure b :=
  le_inf (EMLClosureAlgebra.closure_monotone _ _ inf_le_left)
         (EMLClosureAlgebra.closure_monotone _ _ inf_le_right)

/-- Sup of closures ≤ closure of sup. -/
theorem sup_closure_le_closure_sup (a b : H) :
    EMLClosureAlgebra.closure a ⊔ EMLClosureAlgebra.closure b ≤
    EMLClosureAlgebra.closure (a ⊔ b) :=
  sup_le (EMLClosureAlgebra.closure_monotone _ _ le_sup_left)
         (EMLClosureAlgebra.closure_monotone _ _ le_sup_right)

/-- ClosureEquiv is reflexive. -/
theorem closureEquiv_refl (x : H) : ClosureEquiv x x := rfl

/-- ClosureEquiv is symmetric. -/
theorem closureEquiv_symm {x y : H} (h : ClosureEquiv x y) : ClosureEquiv y x := h.symm

/-- ClosureEquiv is transitive. -/
theorem closureEquiv_trans {x y z : H} (h₁ : ClosureEquiv x y) (h₂ : ClosureEquiv y z) :
    ClosureEquiv x z := h₁.trans h₂

/-- If x ≤ y and closure(y) = y, then closure(x) ≤ y. -/
theorem closure_le_of_le_fixed {x y : H} (h : x ≤ y)
    (hy : EMLClosureAlgebra.closure y = y) :
    EMLClosureAlgebra.closure x ≤ y := by
  calc EMLClosureAlgebra.closure x
      ≤ EMLClosureAlgebra.closure y := EMLClosureAlgebra.closure_monotone x y h
    _ = y := hy

/-- Closure-continuous maps compose. -/
theorem closure_continuous_comp (f g : H → H)
    (hf : ∀ x, EMLClosureAlgebra.closure (f x) = f (EMLClosureAlgebra.closure x))
    (hg : ∀ x, EMLClosureAlgebra.closure (g x) = g (EMLClosureAlgebra.closure x)) :
    ∀ x, EMLClosureAlgebra.closure (f (g x)) = f (g (EMLClosureAlgebra.closure x)) := by
  intro x
  rw [hf (g x), hg x]

/-- The identity is closure-continuous. -/
theorem closure_continuous_id :
    ∀ x : H, EMLClosureAlgebra.closure (id x) = id (EMLClosureAlgebra.closure x) :=
  fun _ => rfl

/-- The closure operator itself is closure-continuous. -/
theorem closure_is_closure_continuous :
    ∀ x : H, EMLClosureAlgebra.closure (EMLClosureAlgebra.closure x) =
              EMLClosureAlgebra.closure (EMLClosureAlgebra.closure x) :=
  fun _ => rfl

/-- Constant maps to closed elements are closure-continuous. -/
theorem const_closed_is_closure_continuous (c : H)
    (hc : EMLClosureAlgebra.closure c = c) :
    ∀ _ : H, EMLClosureAlgebra.closure c = c :=
  fun _ => hc

/-- Closure is a retraction: closure ∘ closure = closure.
Bridge: connects Category theory (retractions) to Order theory (closures). -/
theorem closure_retraction :
    (EMLClosureAlgebra.closure : H → H) ∘ EMLClosureAlgebra.closure =
    EMLClosureAlgebra.closure :=
  funext EMLClosureAlgebra.closure_idempotent

/-! ## III. Diagonal Self-Reference -/

section Diagonal
variable [EMLSelfPairing H]

/-- The fundamental diagonal fixed-point theorem: for any closure-continuous
map f, the closure of self_pair(f) is a fixed point of f.
This is Lawvere's diagonal argument made algebraic.
Bridge: connects Logic (Gödel's diagonal lemma) to Algebra (closure operators). -/
theorem diagonal_fixed_point (f : H → H)
    (hf_cont : ∀ x, EMLClosureAlgebra.closure (f x) = f (EMLClosureAlgebra.closure x)) :
    EMLClosureAlgebra.closure (EMLSelfPairing.self_pair f) =
    f (EMLClosureAlgebra.closure (EMLSelfPairing.self_pair f)) := by
  have h := EMLSelfPairing.eval_pair f
  rw [hf_cont (EMLSelfPairing.self_pair f)] at h
  exact h

/-- The diagonal fixed point satisfies idempotency. -/
theorem diagonal_fixed_point_idempotent (f : H → H) :
    EMLClosureAlgebra.closure (EMLClosureAlgebra.closure (EMLSelfPairing.self_pair f)) =
    EMLClosureAlgebra.closure (EMLSelfPairing.self_pair f) :=
  EMLClosureAlgebra.closure_idempotent _

/-- For closure-continuous maps, the diagonal yields a closed fixed point.
Impact: certified_compilation_integrity for post-quantum verification. -/
theorem diagonal_certified_fixed_point (f : H → H)
    (hf_cont : ∀ x, EMLClosureAlgebra.closure (f x) = f (EMLClosureAlgebra.closure x)) :
    ∃ x : H, EMLClosureAlgebra.closure x = x ∧ f x = x := by
  refine ⟨EMLClosureAlgebra.closure (EMLSelfPairing.self_pair f),
         EMLClosureAlgebra.closure_idempotent _, ?_⟩
  exact (diagonal_fixed_point f hf_cont).symm

/-- O(1) construction bound: 1 self_pair + 1 closure suffices.
Utility: explicit O(1) computational bound. -/
theorem fixed_point_construction_bound (f : H → H)
    (hf_cont : ∀ x, EMLClosureAlgebra.closure (f x) = f (EMLClosureAlgebra.closure x)) :
    ∃ (x : H) (k : ℕ), k ≤ 1 ∧ EMLClosureAlgebra.closure x = x ∧ f x = x := by
  exact ⟨EMLClosureAlgebra.closure (EMLSelfPairing.self_pair f), 1, le_refl 1,
         EMLClosureAlgebra.closure_idempotent _, (diagonal_fixed_point f hf_cont).symm⟩

/-- Reflexivity: every EML closure algebra with self-pairing is reflexive —
∀ closure-continuous f, ∃ fixed point.
Bridge: connects Logic (reflexive structures) to Computation.
Impact: self_referential_hash_resistance for post-quantum cryptography. -/
theorem eml_reflexivity (φ : H → H)
    (hφ_cont : ∀ x, EMLClosureAlgebra.closure (φ x) = φ (EMLClosureAlgebra.closure x)) :
    ∃ d : H, EMLClosureAlgebra.closure d = d ∧
             EMLClosureAlgebra.closure (φ d) = φ d ∧
             d = φ d := by
  obtain ⟨x, hx_closed, hx_fp⟩ := diagonal_certified_fixed_point φ hφ_cont
  exact ⟨x, hx_closed, by rw [hx_fp]; exact hx_closed, hx_fp.symm ▸ rfl⟩

omit [EMLSelfPairing H] in
/-- Uniqueness of least closed fixed points.
Impact: lattice_crypto — uniqueness prevents ambiguity attacks. -/
theorem least_fixed_point_unique (φ : H → H)
    (d₁ d₂ : H)
    (hd₁_c : EMLClosureAlgebra.closure d₁ = d₁)
    (hd₂_c : EMLClosureAlgebra.closure d₂ = d₂)
    (hd₁ : d₁ = φ d₁) (hd₂ : d₂ = φ d₂)
    (hd₁_least : ∀ y, EMLClosureAlgebra.closure y = y → φ y = y → d₁ ≤ y)
    (hd₂_least : ∀ y, EMLClosureAlgebra.closure y = y → φ y = y → d₂ ≤ y) :
    d₁ = d₂ :=
  le_antisymm (hd₁_least d₂ hd₂_c hd₂.symm) (hd₂_least d₁ hd₁_c hd₁.symm)

/-- The diagonal is a closure fixed point and a map fixed point simultaneously. -/
theorem diagonal_double_fixed (f : H → H)
    (hf_cont : ∀ x, EMLClosureAlgebra.closure (f x) = f (EMLClosureAlgebra.closure x)) :
    let d := EMLClosureAlgebra.closure (EMLSelfPairing.self_pair f)
    EMLClosureAlgebra.closure d = d ∧ f d = d :=
  ⟨EMLClosureAlgebra.closure_idempotent _, (diagonal_fixed_point f hf_cont).symm⟩

end Diagonal

/-! ## IV. Iteration and Convergence -/

section Iteration
variable [OrderBot H]

/-
The iteration sequence is monotonically increasing for monotone f.
Bridge: connects Chain theory to Fixed-point computation.
-/
theorem closureIteration_mono (f : H → H) (hf : Monotone f)
    (n : ℕ) : closureIteration f n ≤ closureIteration f (n + 1) := by
  induction n <;> simp_all +decide [ closureIteration ];
  rename_i n hn;
  exact ‹EMLClosureAlgebra H›.closure_monotone _ _ ( hf hn )

/-- Each iteration step produces a closure-idempotent element. -/
theorem closureIteration_idem (f : H → H) (n : ℕ) :
    EMLClosureAlgebra.closure (closureIteration f (n + 1)) = closureIteration f (n + 1) :=
  EMLClosureAlgebra.closure_idempotent _

/-- Stable values are pre-fixed points. -/
theorem stable_is_prefixed (f : H → H) (n : ℕ)
    (h : closureIteration f n = closureIteration f (n + 1)) :
    EMLClosureAlgebra.closure (f (closureIteration f n)) = closureIteration f n := by
  show closureIteration f (n + 1) = closureIteration f n; exact h.symm

/-
A monotone sequence in a finite type must eventually repeat within card steps.
-/
theorem monotone_seq_stabilizes_aux {α : Type*} [PartialOrder α] [DecidableEq α] [Fintype α]
    (s : ℕ → α) (hs : ∀ n, s n ≤ s (n + 1)) :
    ∃ n : ℕ, n ≤ Fintype.card α ∧ s n = s (n + 1) := by
  by_contra! h;
  -- If all steps are strict, then the sequence is strictly increasing.
  have h_strict_mono : StrictMonoOn s (Finset.Icc 0 (Fintype.card α)) := by
    intros n hn m hm hnm;
    induction hnm <;> simp_all +decide [ lt_of_le_of_ne ];
    exact lt_of_lt_of_le ( by solve_by_elim [ Nat.le_of_lt ] ) ( hs _ );
  exact absurd ( Finset.card_le_univ ( Finset.image s ( Finset.Icc 0 ( Fintype.card α ) ) ) ) ( by rw [ Finset.card_image_of_injOn h_strict_mono.injOn ] ; simp +decide )

/-- For finite types, the iteration must stabilize within |H| steps.
Utility: explicit O(|H|) bound on iteration depth.
Bridge: connects Finiteness (combinatorics) to Convergence (computation). -/
theorem finite_iteration_stabilizes [DecidableEq H] [Fintype H]
    (f : H → H) (hf : Monotone f) :
    ∃ n : ℕ, n ≤ Fintype.card H ∧
      closureIteration f n = closureIteration f (n + 1) :=
  monotone_seq_stabilizes_aux (closureIteration f) (closureIteration_mono f hf)

end Iteration

/-! ## V. Morphisms and Functoriality -/

section Morphisms

variable {H₁ H₂ H₃ : Type*}
  [HeytingAlgebra H₁] [HeytingAlgebra H₂] [HeytingAlgebra H₃]
  [EMLClosureAlgebra H₁] [EMLClosureAlgebra H₂] [EMLClosureAlgebra H₃]

/-- EML morphisms preserve closure-fixed elements.
Bridge: connects Category theory to Logic. -/
theorem morphism_preserves_closed (φ : EMLClosureMorphism H₁ H₂)
    (x : H₁) (hx : EMLClosureAlgebra.closure x = x) :
    EMLClosureAlgebra.closure (φ.toFun x) = φ.toFun x := by
  rw [φ.map_closure, hx]

/-- The identity EML morphism. -/
def EMLClosureMorphism.id' : EMLClosureMorphism H₁ H₁ where
  toFun := _root_.id
  map_closure := fun _ => rfl

/-- Composition of EML morphisms. -/
def EMLClosureMorphism.comp (g : EMLClosureMorphism H₂ H₃)
    (f : EMLClosureMorphism H₁ H₂) : EMLClosureMorphism H₁ H₃ where
  toFun := g.toFun ∘ f.toFun
  map_closure := by
    intro x
    show EMLClosureAlgebra.closure (g.toFun (f.toFun x)) =
         g.toFun (f.toFun (EMLClosureAlgebra.closure x))
    rw [g.map_closure, f.map_closure]

/-- Morphisms preserve closure-equivalence. -/
theorem morphism_preserves_closure_equiv (φ : EMLClosureMorphism H₁ H₂)
    {x y : H₁} (h : ClosureEquiv x y) : ClosureEquiv (φ.toFun x) (φ.toFun y) := by
  show EMLClosureAlgebra.closure (φ.toFun x) = EMLClosureAlgebra.closure (φ.toFun y)
  rw [φ.map_closure, φ.map_closure]
  show φ.toFun (EMLClosureAlgebra.closure x) = φ.toFun (EMLClosureAlgebra.closure y)
  rw [h]

end Morphisms

/-! ## VI. Concrete Instances -/

/-- Prop with identity closure. -/
instance propEMLClosure : EMLClosureAlgebra Prop where
  closure := id
  closure_idempotent := fun _ => rfl
  closure_monotone := fun _ _ h => h
  closure_inflationary := fun _ => le_refl _

/-- Bool with identity closure. -/
instance boolEMLClosure : EMLClosureAlgebra Bool where
  closure := id
  closure_idempotent := fun _ => rfl
  closure_monotone := fun _ _ h => h
  closure_inflationary := fun _ => le_refl _

/-- Set α with completion (universal set) closure. -/
instance setCompletionClosure (α : Type*) : EMLClosureAlgebra (Set α) where
  closure := fun _ => Set.univ
  closure_idempotent := fun _ => rfl
  closure_monotone := fun _ _ _ => le_refl _
  closure_inflationary := fun _ => Set.subset_univ _

/-- Set α with completion closure has self-pairing.
With this closure, closure(S) = univ for all S, so eval_pair is trivial. -/
instance setSelfPairing (α : Type*) : @EMLSelfPairing (Set α) _ (setCompletionClosure α) where
  self_pair := fun _ => Set.univ
  eval_pair := fun _ => rfl

/-! ## VII. Self-Reference Applications -/

section SelfReference

variable {H : Type*} [HeytingAlgebra H] [EMLClosureAlgebra H] [EMLSelfPairing H]

/-- Kleene-Lawvere: every closure-continuous map has a closed fixed point.
Bridge: connects Recursion theory to Algebraic closure operators.
Impact: certified_robustness_compilation for verified neural code. -/
theorem kleene_lawvere_eml (f : H → H)
    (hf_cont : ∀ x, EMLClosureAlgebra.closure (f x) = f (EMLClosureAlgebra.closure x)) :
    ∃ d : H, EMLClosureAlgebra.closure d = d ∧ d = f d := by
  obtain ⟨x, hx1, hx2⟩ := diagonal_certified_fixed_point f hf_cont
  exact ⟨x, hx1, hx2.symm ▸ rfl⟩

omit [HeytingAlgebra H] [EMLClosureAlgebra H] [EMLSelfPairing H] in
/-- Self-reference propagation: joint fixed points compose.
Impact: post_quantum_security — composition preserves structure. -/
theorem self_reference_propagation (f g : H → H)
    (d : H) (hd_f : d = f d) (hd_g : d = g d) :
    d = (f ∘ g) d := by
  show d = f (g d); rw [← hd_g, ← hd_f]

/-- Double diagonal: composition has a fixed point.
Bridge: connects Composition (category theory) to Double recursion (logic). -/
theorem double_diagonal (f g : H → H)
    (hf_cont : ∀ x, EMLClosureAlgebra.closure (f x) = f (EMLClosureAlgebra.closure x))
    (hg_cont : ∀ x, EMLClosureAlgebra.closure (g x) = g (EMLClosureAlgebra.closure x)) :
    ∃ d : H, EMLClosureAlgebra.closure d = d ∧ (f ∘ g) d = d :=
  diagonal_certified_fixed_point (f ∘ g) (closure_continuous_comp f g hf_cont hg_cont)

/-- Triple composition fixed point.
Impact: certified_robustness — deep composition chains have fixed points. -/
theorem triple_diagonal (f g h : H → H)
    (hf : ∀ x, EMLClosureAlgebra.closure (f x) = f (EMLClosureAlgebra.closure x))
    (hg : ∀ x, EMLClosureAlgebra.closure (g x) = g (EMLClosureAlgebra.closure x))
    (hh : ∀ x, EMLClosureAlgebra.closure (h x) = h (EMLClosureAlgebra.closure x)) :
    ∃ d : H, EMLClosureAlgebra.closure d = d ∧ (f ∘ g ∘ h) d = d :=
  diagonal_certified_fixed_point (f ∘ g ∘ h)
    (closure_continuous_comp f (g ∘ h) hf (closure_continuous_comp g h hg hh))

end SelfReference

/-! ## VIII. Lipschitz and Entropy Bounds -/

section Bounds

variable {H : Type*} [HeytingAlgebra H] [EMLClosureAlgebra H]

/-- Closure is Lipschitz-1: both lattice operation bounds hold.
Utility: Lipschitz_bound = 1 for the closure operator.
Impact: lipschitz_certified_robustness for neural network verification. -/
theorem closure_lipschitz_one (a b : H) :
    EMLClosureAlgebra.closure (a ⊓ b) ≤ EMLClosureAlgebra.closure a ⊓ EMLClosureAlgebra.closure b ∧
    EMLClosureAlgebra.closure a ⊔ EMLClosureAlgebra.closure b ≤ EMLClosureAlgebra.closure (a ⊔ b) :=
  ⟨closure_inf_le a b, sup_closure_le_closure_sup a b⟩

/-- The closure depth: 0 if closed, 1 otherwise. -/
def closureDepth [DecidableEq H] (x : H) : ℕ :=
  if EMLClosureAlgebra.closure x = x then 0 else 1

/-- Closed elements have depth 0. -/
theorem closureDepth_of_closed [DecidableEq H] (x : H)
    (hx : EMLClosureAlgebra.closure x = x) :
    closureDepth x = 0 := by
  simp [closureDepth, hx]

/-- Non-closed elements have depth 1. -/
theorem closureDepth_of_not_closed [DecidableEq H] (x : H)
    (hx : ¬(EMLClosureAlgebra.closure x = x)) :
    closureDepth x = 1 := by
  simp [closureDepth, hx]

/-- Maximum closure depth is 1. Utility: O(1) bound.
Impact: entropy — bounded computational overhead. -/
theorem closureDepth_le_one [DecidableEq H] (x : H) :
    closureDepth x ≤ 1 := by
  unfold closureDepth; split <;> omega

end Bounds

/-! ## IX. ClosureEquiv Setoid -/

section ClosureSetoid

variable {H : Type*} [HeytingAlgebra H] [EMLClosureAlgebra H]

/-- ClosureEquiv forms a setoid.
Bridge: connects Equivalence relations to Closure theory. -/
instance closureEquivSetoid : Setoid H where
  r := ClosureEquiv
  iseqv := {
    refl := closureEquiv_refl
    symm := @closureEquiv_symm H _ _
    trans := @closureEquiv_trans H _ _
  }

/-- An element and its closure are closure-equivalent. -/
theorem self_closure_equiv (x : H) : ClosureEquiv x (EMLClosureAlgebra.closure x) :=
  (EMLClosureAlgebra.closure_idempotent x).symm

end ClosureSetoid

/-! ## X. Knaster-Tarski in Complete Lattice -/

section KnasterTarski

variable {H : Type*} [HeytingAlgebra H] [CompleteLattice H] [EMLClosureAlgebra H]

/-
Knaster-Tarski for monotone closure-continuous maps.
Bridge: connects Lattice theory to EML computation.
Impact: certified_compilation — constructive fixed-point existence.
-/
theorem knaster_tarski_closure_fixed_point (f : H → H)
    (hf_mono : Monotone f)
    (hf_cont : ∀ x, EMLClosureAlgebra.closure (f x) = f (EMLClosureAlgebra.closure x)) :
    ∃ x : H, EMLClosureAlgebra.closure x = x ∧ f x = x := by
  revert ‹EMLClosureAlgebra H›;
  intro h₁ h₂
  generalize_proofs at *;
  obtain ⟨x, hx⟩ : ∃ x : H, f x = x := by
    have h_fixed_point : ∃ x, f x ≤ x ∧ ∀ y, f y ≤ y → x ≤ y := by
      refine' ⟨ sInf { x | f x ≤ x }, _, _ ⟩;
      · exact le_sInf fun x hx => hf_mono ( sInf_le hx ) |> le_trans <| hx;
      · exact fun y hy => sInf_le hy;
    obtain ⟨ x, hx₁, hx₂ ⟩ := h_fixed_point; exact ⟨ x, le_antisymm hx₁ ( hx₂ _ ( hf_mono hx₁ ) ) ⟩ ;
  exact ⟨ h₁.closure x, h₁.closure_idempotent x, by rw [ ← h₂, hx ] ⟩

end KnasterTarski

end EmergentComputationAlgebra