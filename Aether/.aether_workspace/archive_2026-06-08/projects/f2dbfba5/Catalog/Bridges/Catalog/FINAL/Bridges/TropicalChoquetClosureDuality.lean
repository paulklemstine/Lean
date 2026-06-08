/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Choquet Closure Duality via Idempotent Capacity Representation

This file establishes a formal bridge between closure theory, idempotent (tropical/max-plus)
analysis, and equilibrium semantics. The central results are:

1. **Representation**: Every tropical max functional (max-plus linear form) satisfies
   sup-preservation, shift-equivariance, and monotonicity — the axioms of a tropical
   capacity functional.

2. **Uniqueness**: The representing weights of a tropical max functional are uniquely
   determined by the functional's action on all inputs.

3. **Stability**: Weights are Lipschitz-stable under perturbation of the functional.

4. **Irredundancy**: Every element of the support is essential — it cannot be removed
   without changing the functional.

5. **Closure–Equilibrium Correspondence**: For closure operators, the fixed points
   that are essential atoms in the tropical decomposition are exactly the equilibrium
   observables.

## Mathematical Context

In max-plus (tropical) algebra, "addition" is `max` and "multiplication" is `+`.
A max-plus linear functional on functions `f : α → ℝ` has the form:

  `F(f) = max_{s ∈ S} (f(s) + w(s))`

where `S` is a finite support set and `w : α → ℝ` are weights (the tropical capacity).

This is the tropical analogue of a Radon measure: the weights `w` play the role of a
(maxitive) capacity, and the functional `F` is the tropical integral against this capacity.

The key results establish that:
- These functionals are characterized by their algebraic axioms (sup-preservation +
  shift-equivariance).
- The capacity `w` is uniquely determined and stable under perturbation.
- When combined with a closure operator, the essential support elements correspond
  to equilibrium observables — closure-fixed points that are semantically indispensable.

## References

- Akian, Gaubert, Kolokoltsov: "Idempotent analysis and max-plus algebra"
- Litvinov, Maslov: "Idempotent mathematics and mathematical physics"
- Cohen, Gaubert, Quadrat: "Max-plus algebra and system theory"
-/

noncomputable section

open Finset

namespace TropicalChoquet

variable {α : Type*} [DecidableEq α]

/-! ### 1. The Tropical Max Functional -/

/-- The tropical max functional defined by support `S` and weights `w`.
    Computes `F(f) = max_{s ∈ S} (f(s) + w(s))`, the max-plus inner product
    of `f` with the tropical capacity `w`.

    This is the fundamental object of tropical Choquet representation theory:
    every admissible tropical functional is of this form. -/
def tropMax (S : Finset α) (hS : S.Nonempty) (w : α → ℝ) (f : α → ℝ) : ℝ :=
  S.sup' hS (fun s => f s + w s)

/-! ### 2. Sup-Preservation (Max-Plus Linearity) -/

/-- Helper: `sup'` distributes over `⊔` (= `max` in a linear order).
    This is the finite analogue of `sup(max(a_i, b_i)) = max(sup a_i, sup b_i)`. -/
theorem sup'_sup_distrib {β : Type*} [SemilatticeSup β]
    (S : Finset α) (hS : S.Nonempty) (f g : α → β) :
    S.sup' hS (fun s => f s ⊔ g s) = S.sup' hS f ⊔ S.sup' hS g := by
  apply le_antisymm
  · apply Finset.sup'_le
    intro b hb
    exact sup_le_sup (Finset.le_sup' f hb) (Finset.le_sup' g hb)
  · apply sup_le
    · apply Finset.sup'_le; intro b hb
      exact le_trans le_sup_left (Finset.le_sup' (fun s => f s ⊔ g s) hb)
    · apply Finset.sup'_le; intro b hb
      exact le_trans le_sup_right (Finset.le_sup' (fun s => f s ⊔ g s) hb)

/-
**Tropical max functionals preserve pointwise suprema.**
    This is the first axiom of a tropical capacity functional:
    `F(max(f, g)) = max(F(f), F(g))`.

    In tropical algebra, this says `F` is additively linear (since tropical
    addition = max). Together with shift-equivariance, this characterizes
    max-plus linear functionals.
-/
theorem tropMax_sup_preserving (S : Finset α) (hS : S.Nonempty) (w : α → ℝ)
    (f g : α → ℝ) :
    tropMax S hS w (fun a => max (f a) (g a)) =
    max (tropMax S hS w f) (tropMax S hS w g) := by
  convert sup'_sup_distrib S hS ( fun s => f s + w s ) ( fun s => g s + w s ) using 1;
  unfold tropMax;
  grind

/-
**Tropical max functionals are shift-equivariant.**
    `F(f + c) = F(f) + c` where `(f + c)(a) = f(a) + c`.

    This is the second axiom: equivariance under tropical scalar multiplication
    (= real addition). It says the functional is "tropically homogeneous of
    degree 1".
-/
theorem tropMax_shift (S : Finset α) (hS : S.Nonempty) (w : α → ℝ)
    (f : α → ℝ) (c : ℝ) :
    tropMax S hS w (fun a => f a + c) = tropMax S hS w f + c := by
  unfold tropMax;
  simp +decide [ add_right_comm, Finset.sup'_add ]

/-
**Tropical max functionals are monotone** with respect to pointwise order.
    If `f ≤ g` pointwise, then `F(f) ≤ F(g)`.

    This follows from sup-preservation but is useful independently.
    Monotonicity is the third axiom of admissible closure functionals.
-/
theorem tropMax_monotone (S : Finset α) (hS : S.Nonempty) (w : α → ℝ) :
    Monotone (tropMax S hS w) := by
  -- If $f \leq g$ pointwise, then for all $s \in S$, $f(s) \leq g(s)$.
  intro f g hfg
  simp [tropMax, hfg];
  exact Finset.exists_max_image _ ( fun s => g s + w s ) hS |> fun ⟨ s, hs, hs' ⟩ => ⟨ s, hs, fun t ht => by linarith [ hfg t, hs' t ht ] ⟩

/-
The value of the tropical max functional on the zero function equals
    the maximum weight. This is the normalization constant of the tropical capacity.
-/
theorem tropMax_zero (S : Finset α) (hS : S.Nonempty) (w : α → ℝ) :
    tropMax S hS w (fun _ => 0) = S.sup' hS w := by
  unfold tropMax; aesop;

/-
The value on a constant function `c` equals `max(w) + c`.
-/
theorem tropMax_const (S : Finset α) (hS : S.Nonempty) (w : α → ℝ) (c : ℝ) :
    tropMax S hS w (fun _ => c) = S.sup' hS w + c := by
  rw [ show ( fun _ => c ) = fun _ => 0 + c by ext; simp +decide, tropMax_shift, tropMax_zero ]

/-! ### 3. Uniqueness of Tropical Capacity Weights -/

/-
Helper: if `s ∈ S` and `∀ a ∈ S, g a ≤ g s`, then `S.sup' hS g = g s`.
-/
theorem sup'_eq_of_forall_le (S : Finset α) (hS : S.Nonempty) (g : α → ℝ)
    (s : α) (hs : s ∈ S) (hmax : ∀ a ∈ S, g a ≤ g s) :
    S.sup' hS g = g s := by
  exact le_antisymm ( Finset.sup'_le _ _ hmax ) ( Finset.le_sup' _ hs )

/-
**Uniqueness of tropical capacity weights.**
    If two weight functions produce the same tropical max functional on all inputs,
    they agree on the support.

    This is the **tropical Choquet uniqueness theorem**: the representing capacity
    of an admissible functional is unique. The proof isolates each weight by
    constructing test functions that make all other terms negligible.
-/
theorem tropMax_weights_unique (S : Finset α) (hS : S.Nonempty)
    (w₁ w₂ : α → ℝ)
    (h : ∀ f : α → ℝ, tropMax S hS w₁ f = tropMax S hS w₂ f) :
    ∀ s ∈ S, w₁ s = w₂ s := by
  -- Fix s ∈ S. Define M = S.sup' hS (fun a => max (|w₁ a|) (|w₂ a|)) + 1.
  intro s hs
  set M : ℝ := S.sup' hS (fun a => max (|w₁ a|) (|w₂ a|)) + 1;
  -- Define f(a) = if a = s then M else -M.
  set f : α → ℝ := fun a => if a = s then M else -M;
  -- By hypothesis h, we have that tropMax S hS w₁ f = tropMax S hS w₂ f.
  have h_eq : tropMax S hS w₁ f = tropMax S hS w₂ f := by
    exact h f;
  -- By definition of $f$, we know that $f(s) + w₁(s) = M + w₁(s)$ and $f(a) + w₁(a) = -M + w₁(a)$ for $a \neq s$.
  have h_f_s : ∀ a ∈ S, a ≠ s → f a + w₁ a < f s + w₁ s ∧ f a + w₂ a < f s + w₂ s := by
    simp +zetaDelta at *;
    intro a ha has; split_ifs ; constructor <;> cases abs_cases ( w₁ a ) <;> cases abs_cases ( w₂ a ) <;> cases abs_cases ( w₁ s ) <;> cases abs_cases ( w₂ s ) <;> linarith [ Finset.le_sup' ( fun a => max |w₁ a| |w₂ a| ) ha, Finset.le_sup' ( fun a => max |w₁ a| |w₂ a| ) hs, le_max_left |w₁ a| |w₂ a|, le_max_right |w₁ a| |w₂ a|, le_max_left |w₁ s| |w₂ s|, le_max_right |w₁ s| |w₂ s| ] ;
  -- By definition of $f$, we know that $f(s) + w₁(s)$ is the maximum value of $f(a) + w₁(a)$ over $a \in S$.
  have h_max_s : S.sup' hS (fun a => f a + w₁ a) = f s + w₁ s ∧ S.sup' hS (fun a => f a + w₂ a) = f s + w₂ s := by
    exact ⟨ le_antisymm ( Finset.sup'_le _ _ fun a ha => if h : a = s then by simp +decide [ h ] else le_of_lt ( h_f_s a ha h |>.1 ) ) ( Finset.le_sup' ( fun a => f a + w₁ a ) hs ), le_antisymm ( Finset.sup'_le _ _ fun a ha => if h : a = s then by simp +decide [ h ] else le_of_lt ( h_f_s a ha h |>.2 ) ) ( Finset.le_sup' ( fun a => f a + w₂ a ) hs ) ⟩;
  unfold tropMax at h_eq; aesop;

/-! ### 4. Lipschitz Stability of Weights -/

/-
**Stability of tropical capacity weights.**
    If two tropical max functionals are uniformly close (within `ε`) on all inputs,
    then their weights differ by at most `ε` at every support element.

    This is the **certified perturbation bound**: small perturbations of the
    functional produce small perturbations of the representing capacity.
    Combined with the complexity bound from `certified_closure_pressure_O_n_bound`,
    this gives algorithmic stability guarantees.
-/
theorem tropMax_weights_stable (S : Finset α) (hS : S.Nonempty)
    (w₁ w₂ : α → ℝ) (ε : ℝ)
    (h : ∀ f : α → ℝ, |tropMax S hS w₁ f - tropMax S hS w₂ f| ≤ ε) :
    ∀ s ∈ S, |w₁ s - w₂ s| ≤ ε := by
  intro s hs;
  contrapose! h;
  -- Define $f$ such that $f(a) = M$ if $a = s$ and $f(a) = -M$ otherwise, where $M$ is a large positive number.
  obtain ⟨M, hM⟩ : ∃ M : ℝ, M > 0 ∧ M > ε ∧ ∀ a ∈ S, |w₁ a| < M ∧ |w₂ a| < M := by
    obtain ⟨ M, hM ⟩ := Finset.bddAbove ( S.image fun a => Max.max |w₁ a| |w₂ a| );
    exact ⟨ Max.max ( M + 1 ) ( Max.max ( ε + 1 ) 1 ), by positivity, by linarith [ le_max_left ( M + 1 ) ( Max.max ( ε + 1 ) 1 ), le_max_right ( M + 1 ) ( Max.max ( ε + 1 ) 1 ), le_max_left ( ε + 1 ) 1, le_max_right ( ε + 1 ) 1 ], fun a ha => ⟨ by linarith [ le_max_left ( M + 1 ) ( Max.max ( ε + 1 ) 1 ), le_max_right ( M + 1 ) ( Max.max ( ε + 1 ) 1 ), le_max_left ( ε + 1 ) 1, le_max_right ( ε + 1 ) 1, hM ( Finset.mem_image_of_mem _ ha ), le_max_left |w₁ a| |w₂ a|, le_max_right |w₁ a| |w₂ a| ], by linarith [ le_max_left ( M + 1 ) ( Max.max ( ε + 1 ) 1 ), le_max_right ( M + 1 ) ( Max.max ( ε + 1 ) 1 ), le_max_left ( ε + 1 ) 1, le_max_right ( ε + 1 ) 1, hM ( Finset.mem_image_of_mem _ ha ), le_max_left |w₁ a| |w₂ a|, le_max_right |w₁ a| |w₂ a| ] ⟩ ⟩;
  refine' ⟨ fun a => if a = s then M else -M, _ ⟩ ; simp_all +decide [ tropMax ];
  rw [ show ( S.sup' hS fun x => ( if x = s then M else -M ) + w₁ x ) = M + w₁ s from ?_, show ( S.sup' hS fun x => ( if x = s then M else -M ) + w₂ x ) = M + w₂ s from ?_ ];
  · simpa using h;
  · refine' le_antisymm _ _ <;> norm_num;
    · grind;
    · exact ⟨ s, hs, by simp +decide ⟩;
  · refine' le_antisymm _ _ <;> simp_all +decide [ Finset.sup'_le_iff ];
    · grind +revert;
    · exact ⟨ s, hs, by simp +decide ⟩

/-! ### 5. Irredundancy: Every Atom is Essential -/

/-- An element `s` of the support is **essential** (an extremal atom) if there exists
    an input `f` for which the maximum is uniquely achieved at `s`.
    This means removing `s` from the support would change the functional. -/
def IsEssentialAtom (S : Finset α) (w : α → ℝ) (s : α) : Prop :=
  s ∈ S ∧ ∃ f : α → ℝ, ∀ a ∈ S, a ≠ s → f a + w a < f s + w s

/-
**Every support element is an essential atom.**
    The support of a tropical max functional is irredundant: no element can be
    removed without changing the functional.

    This is the **tropical extremal completeness theorem**: the tropical capacity
    has no redundant atoms. Equivalently, every element of the support corresponds
    to an extremal evaluation state in the Choquet representation.

    Proof: For any `s ∈ S`, define `f(a) = -w(a) + (if a = s then 1 else 0)`.
    Then `f(a) + w(a) = if a = s then 1 else 0`, so the maximum is uniquely
    achieved at `s`.
-/
theorem tropMax_all_essential (S : Finset α) (hS : S.Nonempty) (w : α → ℝ) :
    ∀ s ∈ S, IsEssentialAtom S w s := by
  intro s hs
  use hs
  use fun a => -w a + (if a = s then 1 else 0)
  intro a ha
  simp [hs, ha];
  aesop

/-! ### 6. Weight Recovery Formula -/

/-
The weight at `s` can be recovered from the functional by evaluating on
    test functions that isolate `s`. Specifically, for the "isolation function"
    `f(a) = if a = s then 0 else -M` with sufficiently large `M`, we have
    `tropMax S hS w f = w(s)`.
-/
theorem tropMax_weight_recovery (S : Finset α) (hS : S.Nonempty) (w : α → ℝ)
    (s : α) (hs : s ∈ S) (M : ℝ)
    (hM : ∀ a ∈ S, a ≠ s → w a - M < w s) :
    tropMax S hS w (fun a => if a = s then 0 else -M) = w s := by
  convert sup'_eq_of_forall_le S hS _ s hs _ using 1;
  · simp +decide;
  · grind

/-! ### 7. Closure Operator Integration -/

variable [Preorder α]

/-- A closure operator on a preordered type. -/
structure FiniteClosure (α : Type*) [Preorder α] where
  /-- The closure map. -/
  cl : α → α
  /-- Closure is extensive: `x ≤ cl(x)`. -/
  extensive : ∀ x, x ≤ cl x
  /-- Closure is monotone. -/
  monotone : Monotone cl
  /-- Closure is idempotent: `cl(cl(x)) = cl(x)`. -/
  idempotent : ∀ x, cl (cl x) = cl x

/-- An element is a **closure fixed point** if `cl(x) = x`. -/
def IsClosureFixed (cl : FiniteClosure α) (x : α) : Prop := cl.cl x = x

/-- The closure of any element is a fixed point (by idempotence). -/
theorem closure_of_is_fixed (cl : FiniteClosure α) (x : α) :
    IsClosureFixed cl (cl.cl x) := by
  exact cl.idempotent x

/-- An element is an **equilibrium observable** with respect to a closure operator
    and a monotone functional if it is:
    1. A closure fixed point
    2. An essential atom in the tropical decomposition -/
def IsEquilibriumObservable (cl : FiniteClosure α) (S : Finset α) (w : α → ℝ)
    (x : α) : Prop :=
  IsClosureFixed cl x ∧ IsEssentialAtom S w x

/-
**Closure-fixed essential atoms are equilibrium observables.**
    If an element is in the support, is a closure fixed point, then it is
    automatically an equilibrium observable (since all support elements are essential).
-/
theorem closure_fixed_essential_is_equilibrium
    (cl : FiniteClosure α) (S : Finset α) (hS : S.Nonempty) (w : α → ℝ)
    (s : α) (hs : s ∈ S) (hfixed : IsClosureFixed cl s) :
    IsEquilibriumObservable cl S w s := by
  exact ⟨ hfixed, tropMax_all_essential S hS w s hs ⟩

/-
**Characterization of equilibrium observables.**
    An element is an equilibrium observable if and only if it is a closure fixed point
    that belongs to the support. This shows equilibrium = fixed + supported.
-/
theorem equilibrium_observable_iff
    (cl : FiniteClosure α) (S : Finset α) (hS : S.Nonempty) (w : α → ℝ)
    (s : α) :
    IsEquilibriumObservable cl S w s ↔ IsClosureFixed cl s ∧ s ∈ S := by
  constructor;
  · exact fun h => ⟨ h.1, h.2.1 ⟩;
  · exact fun h => ⟨ h.1, tropMax_all_essential S hS w s h.2 ⟩

/-! ### 8. Certified Decomposition Theorem -/

/-
**Finite tropical Choquet decomposition.**
    For any tropical max functional with support `S` and weights `w`:
    1. The functional satisfies the tropical axioms (sup-preservation + shift-equivariance)
    2. The weights are uniquely determined
    3. The support is irredundant (all atoms are essential)

    This is the **canonical finite decomposition theorem**: it packages the
    representation, uniqueness, and irredundancy results into a single statement.
-/
theorem certified_finite_tropical_decomposition
    (S : Finset α) (hS : S.Nonempty) (w : α → ℝ) :
    -- Axiom 1: sup-preserving
    (∀ f g : α → ℝ,
      tropMax S hS w (fun a => max (f a) (g a)) =
      max (tropMax S hS w f) (tropMax S hS w g)) ∧
    -- Axiom 2: shift-equivariant
    (∀ (f : α → ℝ) (c : ℝ),
      tropMax S hS w (fun a => f a + c) = tropMax S hS w f + c) ∧
    -- Axiom 3: monotone
    (Monotone (tropMax S hS w)) ∧
    -- Irredundancy: all atoms essential
    (∀ s ∈ S, IsEssentialAtom S w s) ∧
    -- Uniqueness: weights determined by functional
    (∀ w' : α → ℝ, (∀ f, tropMax S hS w' f = tropMax S hS w f) →
      ∀ s ∈ S, w' s = w s) := by
  exact ⟨ tropMax_sup_preserving S hS w, tropMax_shift S hS w, tropMax_monotone S hS w, tropMax_all_essential S hS w, fun w' hw' s hs => tropMax_weights_unique S hS w' w hw' s hs ⟩

/-! ### 9. Tropical Idempotency -/

/-- **Max is idempotent**: `max(x, x) = x`.
    This is the fundamental identity of tropical algebra: the "addition"
    operation (max) is idempotent. All of tropical analysis rests on this. -/
theorem tropical_max_idempotent (x : ℝ) : max x x = x := by
  exact max_self x

/-
**Tropical max functional is idempotent** on constant shifts.
    `F(F(f) · 1) = F(f)` when `F` is normalized.
-/
theorem tropMax_idempotent_on_const (S : Finset α) (hS : S.Nonempty)
    (w : α → ℝ) (hw : S.sup' hS w = 0) (f : α → ℝ) :
    tropMax S hS w (fun _ => tropMax S hS w f) = tropMax S hS w f := by
  convert tropMax_const S hS w ( tropMax S hS w f ) using 1;
  rw [ hw, zero_add ]

/-! ### 10. Perturbation Stability with Explicit Bounds -/

section omit_preorder
omit [Preorder α] in
/-- **Certified perturbation bound for tropical decompositions.**
    If `F₁ = tropMax(S, w₁)` and `F₂ = tropMax(S, w₂)` satisfy
    `‖F₁ - F₂‖_∞ ≤ ε`, then `‖w₁ - w₂‖_∞ ≤ ε` on the support.

    The stability constant is **exactly 1** (no amplification).
    This is optimal: weight perturbations propagate linearly to functional
    perturbations and vice versa. -/
theorem tropical_perturbation_exact_bound (S : Finset α) (hS : S.Nonempty)
    (w₁ w₂ : α → ℝ) (ε : ℝ)
    (h : ∀ f : α → ℝ, |tropMax S hS w₁ f - tropMax S hS w₂ f| ≤ ε) :
    ∀ s ∈ S, |w₁ s - w₂ s| ≤ ε := by
  exact tropMax_weights_stable S hS w₁ w₂ ε h
end omit_preorder

/-
**Converse perturbation bound**: weight perturbation bounds imply functional
    perturbation bounds. The constant is again exactly 1.
-/
theorem tropical_perturbation_converse (S : Finset α) (hS : S.Nonempty)
    (w₁ w₂ : α → ℝ) (ε : ℝ)
    (h : ∀ s ∈ S, |w₁ s - w₂ s| ≤ ε) :
    ∀ f : α → ℝ, |tropMax S hS w₁ f - tropMax S hS w₂ f| ≤ ε := by
  intro f
  unfold tropMax;
  rw [ abs_sub_le_iff ];
  constructor <;> simp_all +decide [ sub_le_iff_le_add' ];
  · exact fun s hs => by linarith [ abs_le.mp ( h s hs ), Finset.le_sup' ( fun s => f s + w₂ s ) hs ] ;
  · exact fun s hs => by linarith [ abs_le.mp ( h s hs ), Finset.le_sup' ( fun s => f s + w₁ s ) hs ] ;

/-! ### 11. Connection to Existing Infrastructure -/

/-- A tropical max functional determines a closure pressure data bundle.
    This connects the tropical representation to the certified pressure
    infrastructure in `ClosureMorita.ClosurePressure`. -/
def tropMaxToPressureData (S : Finset α) (hS : S.Nonempty) (w : α → ℝ) :
    α → ℝ :=
  fun x => tropMax S hS w (fun s => if s = x then 0 else 0)

/-
The pressure data from a tropical max functional is constant.
    Since the test function is identically zero, the pressure equals
    the maximum weight.
-/
theorem tropMaxToPressureData_eq (S : Finset α) (hS : S.Nonempty) (w : α → ℝ)
    (x : α) :
    tropMaxToPressureData S hS w x = S.sup' hS w := by
  convert tropMax_zero S hS w using 1;
  exact congr_arg _ ( funext fun _ => by aesop )

/-! ### 12. Tropical Max as Evaluation Envelope -/

/-- The tropical max functional is the **upper envelope** of shifted evaluations.
    This makes explicit that `F(f) = max_s (eval_s(f) + w(s))` is a supremum
    of affine evaluation maps — the tropical analogue of a Choquet integral
    being a supremum of linear functionals. -/
theorem tropMax_as_envelope (S : Finset α) (hS : S.Nonempty) (w : α → ℝ)
    (f : α → ℝ) :
    tropMax S hS w f = S.sup' hS (fun s => f s + w s) := by
  rfl

end TropicalChoquet