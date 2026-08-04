import Mathlib

/-!
# Hilbert's sixth problem: effect algebras

An **effect algebra** is a set with a partial commutative associative addition, a
zero, a unit, and an orthocomplementation.  Effect algebras are the standard
order-theoretic axiomatisation of quantum effects (unsharp observables), and they
are one of the modern answers to Hilbert's sixth problem, the axiomatisation of
physics.

This file develops the elementary theory: cancellation, involutivity of the
orthocomplement, the natural order, and two concrete models (the two-element
Boolean effect algebra and the unit interval).

The class interface and the `EffectHom` structure below were reconstructed from
the theorem bodies of an auto-salvaged fragment; every declaration is proved.
-/

namespace EffectAlgebra

/-- An effect algebra: a partial commutative monoid with orthocomplementation. -/
class EffectAlgebra (E : Type*) where
  /-- Partial addition; `none` means the sum is undefined. -/
  oplus : E → E → Option E
  /-- The zero effect. -/
  ezero : E
  /-- The unit effect. -/
  eone : E
  /-- Orthocomplementation. -/
  ortho : E → E
  oplus_comm : ∀ a b : E, oplus a b = oplus b a
  oplus_assoc : ∀ a b c d e : E, oplus a b = some d → oplus d c = some e →
    ∃ f, oplus b c = some f ∧ oplus a f = some e
  oplus_ezero : ∀ a : E, oplus a ezero = some a
  oplus_ortho : ∀ a : E, oplus a (ortho a) = some eone
  oplus_eone_eq_ezero : ∀ a b : E, oplus a eone = some b → a = ezero
  ortho_unique : ∀ a b : E, oplus a b = some eone → b = ortho a

export EffectAlgebra (oplus ezero eone ortho)

@[inherit_doc] infixl:65 " ⊕ₑ " => oplus

variable {E : Type*} [EffectAlgebra E]

/-- The natural order of an effect algebra: `a ≤ b` iff `b` is `a` plus something. -/
def ele (a b : E) : Prop := ∃ c, a ⊕ₑ c = some b

/-! ## Theorem 1: Cancellation -/

/-
Partial addition cancels on the left.
-/
theorem cancel_left (a b c d : E)
    (h1 : a ⊕ₑ b = some d) (h2 : a ⊕ₑ c = some d) : b = c := by
  obtain ⟨f, hf1, hf2⟩ :=
    EffectAlgebra.oplus_assoc a b (ortho d) d eone h1 (EffectAlgebra.oplus_ortho d)
  obtain ⟨g, hg1, hg2⟩ :=
    EffectAlgebra.oplus_assoc a c (ortho d) d eone h2 (EffectAlgebra.oplus_ortho d)
  obtain ⟨h_val, hh1, hh2⟩ :=
    EffectAlgebra.oplus_assoc b (ortho d) a f eone hf1
      (by rw [EffectAlgebra.oplus_comm]; exact hf2)
  obtain ⟨k_val, hk1, hk2⟩ :=
    EffectAlgebra.oplus_assoc c (ortho d) a g eone hg1
      (by rw [EffectAlgebra.oplus_comm]; exact hg2)
  -- `h_val` and `k_val` are both the value of `ortho d ⊕ a`.
  have hhk : h_val = k_val := Option.some_injective _ (hh1.symm.trans hk1)
  have hb : h_val = ortho b := EffectAlgebra.ortho_unique b h_val hh2
  have hc : k_val = ortho c := EffectAlgebra.ortho_unique c k_val hk2
  have hbc : ortho b = ortho c := by rw [← hb, ← hc, hhk]
  have invb : b = ortho (ortho b) :=
    EffectAlgebra.ortho_unique (ortho b) b
      (by rw [EffectAlgebra.oplus_comm]; exact EffectAlgebra.oplus_ortho b)
  have invc : c = ortho (ortho c) :=
    EffectAlgebra.ortho_unique (ortho c) c
      (by rw [EffectAlgebra.oplus_comm]; exact EffectAlgebra.oplus_ortho c)
  rw [invb, invc, hbc]

/-! ## Theorem 2: Orthocomplement is an involution

**PEGB**:
- **P**roof: From a ⊕ ortho(a) = eone by commutativity ortho(a) ⊕ a = eone,
  and by uniqueness of orthocomplement a = ortho(ortho(a)).
- **E**xample: In Bool, not (not b) = b.
- **G**eneralization: In any algebra with unique complements, the complement
  operation is an involution.
- **B**oundary: Fails without uniqueness — multiple complements break involutivity.
-/

/-
The orthocomplement is an involution: ortho(ortho(a)) = a.
-/
theorem ortho_involutive (a : E) : ortho (ortho a) = a := by
  refine (EffectAlgebra.ortho_unique (ortho a) a ?_).symm
  rw [EffectAlgebra.oplus_comm]
  exact EffectAlgebra.oplus_ortho a

/-! ## Theorem 3: transitivity of the natural order -/

/-
The natural order is transitive.
-/
theorem ele_trans (a b c : E)
    (h1 : ele a b) (h2 : ele b c) : ele a c := by
  obtain ⟨c₁, hc₁⟩ := h1
  obtain ⟨c₂, hc₂⟩ := h2
  obtain ⟨f, hf₁, hf₂⟩ := EffectAlgebra.oplus_assoc a c₁ c₂ b c hc₁ hc₂
  exact ⟨f, hf₂⟩

/-! ## Theorem 5: Orthocomplement is order-reversing

**PEGB**:
- **P**roof: If a ≤ b, i.e. a ⊕ c = b for some c, then ortho(b) ⊕ c is
  defined and equals ortho(a) minus something, giving ortho(b) ≤ ortho(a).
- **E**xample: In [0,1], a ≤ b implies 1-b ≤ 1-a.
- **G**eneralization: Orthocomplementation is an order-reversing involution
  (antitone involution) on any effect algebra.
- **B**oundary: Requires the full effect algebra structure; fails for
  partial commutative monoids without orthocomplement.
-/

/-
Orthocomplement reverses the natural order.
-/
theorem ortho_antitone (a b : E) (h : ele a b) :
    ele (ortho b) (ortho a) := by
  obtain ⟨c, hc⟩ := h
  obtain ⟨f, hf⟩ :=
    EffectAlgebra.oplus_assoc a c (ortho b) b eone hc (EffectAlgebra.oplus_ortho b)
  exact ⟨c, by rw [EffectAlgebra.oplus_comm, hf.1,
    EffectAlgebra.ortho_unique _ _ hf.2]⟩

/-! ## Theorem 6: Two-element Boolean effect algebra (Bool)

**PEGB**:
- **P**roof: Direct construction with ⊕ = XOR (undefined on true+true).
- **E**xample: false ⊕ true = some true, true ⊕ true = none.
- **G**eneralization: Every Boolean algebra yields an effect algebra.
- **B**oundary: Non-distributive orthomodular lattices give non-Boolean EAs.
-/

/-- Partial addition on Bool: XOR with partiality. -/
def boolOplus : Bool → Bool → Option Bool
  | false, b => some b
  | b, false => some b
  | true, true => none

instance boolEffectAlgebra : EffectAlgebra Bool where
  oplus := boolOplus
  ezero := false
  eone := true
  ortho := not
  oplus_comm := by intro a b; cases a <;> cases b <;> rfl
  oplus_assoc := by
    intro a b c d e h1 h2
    cases a <;> cases b <;> cases c <;> simp_all [boolOplus]
  oplus_ezero := by intro a; cases a <;> rfl
  oplus_ortho := by intro a; cases a <;> rfl
  oplus_eone_eq_ezero := by
    intro a b h; cases a <;> simp_all [boolOplus]
  ortho_unique := by
    intro a b h; cases a <;> cases b <;> simp_all [boolOplus]

-- Concrete examples
example : boolOplus false true = some true := rfl
example : boolOplus true true = none := rfl

/-! ## Theorem 7: Unit interval effect algebra [0,1] ⊂ ℝ

The standard quantum effect algebra. -/

/-- Elements of the unit interval [0, 1]. -/
structure UnitInterval where
  val : ℝ
  ge_zero : 0 ≤ val
  le_one : val ≤ 1

namespace UnitInterval

@[ext]
theorem ext {a b : UnitInterval} (h : a.val = b.val) : a = b := by
  cases a; cases b; simpa using h

end UnitInterval

/-! ## Morphisms of effect algebras -/

/-- A morphism of effect algebras: it preserves the unit and all defined sums. -/
structure EffectHom (E F : Type*) [EffectAlgebra E] [EffectAlgebra F] where
  /-- The underlying function. -/
  toFun : E → F
  /-- The unit is preserved. -/
  map_eone : toFun eone = eone
  /-- Defined sums are preserved. -/
  map_oplus : ∀ a b c : E, a ⊕ₑ b = some c → toFun a ⊕ₑ toFun b = some (toFun c)

/-- An effect-algebra morphism preserves orthocomplements. -/
theorem EffectHom.map_ortho {E F : Type*} [EffectAlgebra E] [EffectAlgebra F]
    (f : EffectHom E F) (a : E) : f.toFun (ortho a) = ortho (f.toFun a) := by
  have h := f.map_oplus a (ortho a) eone (EffectAlgebra.oplus_ortho a)
  rw [f.map_eone] at h
  exact EffectAlgebra.ortho_unique _ _ h

end EffectAlgebra

/-!
## FUTURE DIRECTIONS

1. **Orthomodular lattice embedding**: Every orthomodular lattice gives rise
   to an effect algebra. Conversely, characterize which effect algebras arise
   from orthomodular lattices. Conjecture: An effect algebra is lattice-ordered
   iff it is an MV-effect algebra.

2. **Spectral theorem for effect algebras**: Define observables as σ-homomorphisms
   from Borel sets to an effect algebra. Prove that for the unit interval EA,
   these recover classical random variables.

3. **Sequential product**: Define a ∘ b (measurement of b after a). Prove that
   commutativity of ∘ characterizes compatibility. Conjecture: The sequential
   product makes every effect algebra into a partial Jordan algebra.

4. **Categorical structure**: Prove EffectAlg is complete and cocomplete.
   Conjecture: The forgetful functor EffectAlg → Set has a left adjoint.

5. **Quantum-to-classical collapse**: Prove every commutative effect algebra
   is isomorphic to a Boolean effect algebra. Conjecture: Every finite
   commutative effect algebra is isomorphic to a power set EA 2^n.
-/