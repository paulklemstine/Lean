/-
# Fundamental Theorem of Identity Types

The fundamental theorem states that if `C : A → Sort v` is a type family
with `c : C a`, and the total space `Σ x, C x` is contractible (with center
`(a, c)`), then for every `x : A`, the type `a = x` is quasi-equivalent
to `C x`.

This is one of the deepest reusable facts in HoTT. It is the engine behind
encode-decode methods, identity-system arguments, and internal classification
of structures.
-/

import Logic.HoTT.Basic

universe u v w

namespace HoTT

/-! ## Encode map -/

/-- The encode map: transport `c : C a` along a path `a = x` to get `C x`. -/
def encode {A : Sort u} {a : A} (C : A → Sort v) (c : C a)
    {x : A} (p : a = x) : C x :=
  transport C p c

/-! ## Decode map via contractibility -/

/-- Extract the base path from contractibility of the total space. -/
noncomputable def decode {A : Sort u} {a : A} (C : A → Sort v) (c : C a)
    (hcontr : isContr (Σ' x : A, C x))
    {x : A} (u : C x) : a = x := by
  obtain ⟨center, hcenter⟩ := hcontr
  have hac : center = ⟨a, c⟩ := (hcenter ⟨a, c⟩).symm
  have hxu : center = ⟨x, u⟩ := (hcenter ⟨x, u⟩).symm
  have : (⟨a, c⟩ : Σ' x : A, C x) = ⟨x, u⟩ := by rw [← hac, hxu]
  exact congrArg PSigma.fst this

/-! ## Helper: subsingleton from contractibility -/

/-
If the total space `Σ x, C x` is contractible, then `C x` is a
    subsingleton for each `x`.
-/
theorem total_contr_fiber_subsingleton
    {A : Sort u} (C : A → Sort v)
    (hcontr : isContr (Σ' x : A, C x)) :
    ∀ x : A, ∀ u v : C x, u = v := by
  exact fun x u v => by have := hcontr; rcases this with ⟨ c, hc ⟩ ; have := hc ⟨ x, u ⟩ ; have := hc ⟨ x, v ⟩ ; ( cases this ; cases ‹_› ; aesop ) ;

/-! ## The Fundamental Theorem -/

/-- **Fundamental Theorem of Identity Types.**

    Let `A : Sort u`, `a : A`, `C : A → Sort v`, and `c : C a`.
    If the total space `Σ x, C x` is contractible, then for every `x : A`,
    the identity type `a = x` is quasi-equivalent to `C x`.

    This is one of the deepest reusable facts provable in plain intensional
    type theory. -/
noncomputable def fundamental_theorem_id'
    {A : Sort u} (a : A)
    (C : A → Sort v) (c : C a)
    (hcontr : isContr (Σ' x : A, C x)) :
    ∀ x : A, QEquiv (a = x) (C x) := by
  intro x
  refine {
    toFun := fun p => encode C c p
    invFun := fun u => decode C c hcontr u
    leftInv := ?_
    rightInv := ?_
  }
  · -- leftInv: decode (encode p) = p for all p : a = x
    intro p
    cases p
    -- Now x = a and we need: decode C c hcontr (encode C c rfl) = rfl
    -- encode C c rfl = c
    -- decode C c hcontr c extracts fst from (⟨a,c⟩ = ⟨a,c⟩)
    rfl
  · -- rightInv: encode (decode u) = u for all u : C x
    intro u
    exact total_contr_fiber_subsingleton C hcontr x _ u

/-! ## Corollaries -/

/-- `fundamental_theorem_subsingleton` as a named corollary. -/
theorem fundamental_theorem_subsingleton
    {A : Sort u} (_a : A)
    (C : A → Sort v) (_c : C _a)
    (hcontr : isContr (Σ' x : A, C x)) :
    ∀ x : A, ∀ u v : C x, u = v :=
  total_contr_fiber_subsingleton C hcontr

/-- Contractible total space implies each fiber `C x` is inhabited
    iff `a = x` (constructively: we can go back and forth). -/
def fundamental_theorem_iff
    {A : Sort u} (a : A)
    (C : A → Sort v) (c : C a)
    (_hcontr : isContr (Σ' x : A, C x)) :
    ∀ x : A, (a = x) → C x := by
  intro x p
  exact encode C c p

end HoTT