/-
# Hilbert's Sixth Problem: Effect Algebras

An axiomatization of the algebra of quantum "effects" (yes/no measurements).
An *effect algebra* is a set with a partially defined commutative, associative
addition `⊕ₑ`, a zero, a unit, and an orthocomplement.

This file was reconstructed: the original source was truncated and lost its
header (the `EffectAlgebra` class, the `⊕ₑ` notation, `ele`, `EffectHom`) and
its `end` markers were scrambled.  All statements are reconstructed here with
complete proofs, and the unit-interval effect algebra `[0,1] ⊂ ℝ` — previously
only a bare structure — is now equipped with a full `EffectAlgebra` instance.
-/
import Mathlib

namespace Hilbert6

/-- An **effect algebra**: a partial commutative monoid with an orthocomplement.
`oplus a b = some c` means "`a` and `b` are orthogonal and their sum is `c`". -/
class EffectAlgebra (E : Type*) where
  /-- The partially defined addition. -/
  oplus : E → E → Option E
  /-- The zero effect. -/
  ezero : E
  /-- The unit effect. -/
  eone : E
  /-- The orthocomplement. -/
  ortho : E → E
  /-- Addition is commutative (including its domain of definition). -/
  oplus_comm : ∀ a b, oplus a b = oplus b a
  /-- Addition is associative. -/
  oplus_assoc : ∀ a b c d e, oplus a b = some d → oplus d c = some e →
    ∃ f, oplus b c = some f ∧ oplus a f = some e
  /-- Zero is a unit for the addition. -/
  oplus_ezero : ∀ a, oplus a ezero = some a
  /-- Every element is orthogonal to its orthocomplement, summing to `eone`. -/
  oplus_ortho : ∀ a, oplus a (ortho a) = some eone
  /-- Zero-one law: only `ezero` is orthogonal to `eone`. -/
  oplus_eone_eq_ezero : ∀ a b, oplus a eone = some b → a = ezero
  /-- Orthocomplements are unique. -/
  ortho_unique : ∀ a b, oplus a b = some eone → ortho a = b

export EffectAlgebra (oplus ezero eone ortho)

@[inherit_doc EffectAlgebra.oplus]
infixl:65 " ⊕ₑ " => EffectAlgebra.oplus

variable {E : Type*} [EffectAlgebra E]

/-! ## Theorem 1: The orthocomplement is an involution

**PEGB**:
- **P**roof: From `a ⊕ ortho a = eone`, commutativity gives `ortho a ⊕ a = eone`,
  and uniqueness of orthocomplements gives `ortho (ortho a) = a`.
- **E**xample: In `Bool`, `not (not b) = b`.
- **G**eneralization: In any algebra with unique complements, complementation is
  an involution.
- **B**oundary: Fails without uniqueness — multiple complements break
  involutivity.
-/

/-- The orthocomplement is an involution. -/
theorem ortho_involutive (a : E) : ortho (ortho a) = a := by
  refine EffectAlgebra.ortho_unique _ _ ?_
  rw [EffectAlgebra.oplus_comm]
  exact EffectAlgebra.oplus_ortho a

/-! ## Theorem 2: Left cancellation

**PEGB**:
- **P**roof: `a ⊕ b = d` together with `d ⊕ ortho d = eone` gives, by
  associativity, an `f` with `b ⊕ ortho d = f` and `a ⊕ f = eone`, so
  `f = ortho a` is determined by `a` alone.  Running the same argument for `c`
  and then once more one level up shows `ortho b = ortho c`, whence `b = c`.
- **E**xample: In `[0,1]`, `a + b = a + c` forces `b = c`.
- **G**eneralization: Every effect algebra is a cancellative partial monoid.
- **B**oundary: Uses `ortho_unique` twice; cancellation genuinely fails for
  partial monoids without orthocomplements.
-/

/-- Effect algebras are cancellative. -/
theorem cancel_left (a b c d : E) (h1 : a ⊕ₑ b = some d) (h2 : a ⊕ₑ c = some d) :
    b = c := by
  obtain ⟨f, hf1, hf2⟩ := EffectAlgebra.oplus_assoc a b (ortho d) d eone h1
    (EffectAlgebra.oplus_ortho d)
  obtain ⟨g, hg1, hg2⟩ := EffectAlgebra.oplus_assoc a c (ortho d) d eone h2
    (EffectAlgebra.oplus_ortho d)
  have hfg : f = g := by
    have h3 := EffectAlgebra.ortho_unique a f hf2
    have h4 := EffectAlgebra.ortho_unique a g hg2
    rw [← h3, ← h4]
  subst hfg
  obtain ⟨u, hu1, hu2⟩ := EffectAlgebra.oplus_assoc b (ortho d) (ortho f) f eone hf1
    (EffectAlgebra.oplus_ortho f)
  obtain ⟨v, hv1, hv2⟩ := EffectAlgebra.oplus_assoc c (ortho d) (ortho f) f eone hg1
    (EffectAlgebra.oplus_ortho f)
  have huv : u = v := by rw [hu1] at hv1; exact Option.some.inj hv1
  subst huv
  have hb := EffectAlgebra.ortho_unique b u hu2
  have hc := EffectAlgebra.ortho_unique c u hv2
  have e1 := ortho_involutive (a := b)
  have e2 := ortho_involutive (a := c)
  rw [← e1, ← e2, hb, hc]

/-! ## Theorem 3: The natural order -/

/-- The natural order on an effect algebra: `a ≤ b` iff `b = a ⊕ c` for some `c`. -/
def ele (a b : E) : Prop := ∃ c, a ⊕ₑ c = some b

/-- The natural order is reflexive. -/
theorem ele_refl (a : E) : ele a a := ⟨ezero, EffectAlgebra.oplus_ezero a⟩

/-- The natural order is transitive. -/
theorem ele_trans (a b c : E) (h1 : ele a b) (h2 : ele b c) : ele a c := by
  obtain ⟨c₁, hc₁⟩ := h1
  obtain ⟨c₂, hc₂⟩ := h2
  obtain ⟨f, _, hf₂⟩ := EffectAlgebra.oplus_assoc a c₁ c₂ b c hc₁ hc₂
  exact ⟨f, hf₂⟩

/-- The orthocomplement of `ezero` is `eone`. -/
theorem ortho_ezero : ortho (ezero : E) = eone := by
  refine EffectAlgebra.ortho_unique _ _ ?_
  rw [EffectAlgebra.oplus_comm]
  exact EffectAlgebra.oplus_ezero eone

/-- If a sum is `ezero`, both summands are `ezero`. -/
theorem eq_ezero_of_oplus_eq_ezero (a b : E) (h : a ⊕ₑ b = some ezero) :
    a = ezero ∧ b = ezero := by
  obtain ⟨f, hf₁, _⟩ := EffectAlgebra.oplus_assoc a b (ortho ezero) ezero eone h
    (EffectAlgebra.oplus_ortho ezero)
  rw [ortho_ezero] at hf₁
  have hb : b = ezero := EffectAlgebra.oplus_eone_eq_ezero b f hf₁
  subst hb
  rw [EffectAlgebra.oplus_ezero] at h
  exact ⟨Option.some.inj h, rfl⟩

/-- The natural order is antisymmetric (via cancellation). -/
theorem ele_antisymm (a b : E) (h1 : ele a b) (h2 : ele b a) : a = b := by
  obtain ⟨c₁, hc₁⟩ := h1
  obtain ⟨c₂, hc₂⟩ := h2
  obtain ⟨f, hf₁, hf₂⟩ := EffectAlgebra.oplus_assoc a c₁ c₂ b a hc₁ hc₂
  have hz : f = ezero := cancel_left a f ezero a hf₂ (EffectAlgebra.oplus_ezero a)
  subst hz
  have hc1z : c₁ = ezero := (eq_ezero_of_oplus_eq_ezero c₁ c₂ hf₁).1
  subst hc1z
  rw [EffectAlgebra.oplus_ezero] at hc₁
  exact Option.some.inj hc₁

/-! ## Theorem 4: Orthocomplementation is order-reversing

**PEGB**:
- **P**roof: If `a ⊕ c = b`, associativity against `b ⊕ ortho b = eone` produces
  `f` with `c ⊕ ortho b = f` and `a ⊕ f = eone`, i.e. `f = ortho a`.  Hence
  `ortho b ⊕ c = ortho a`.
- **E**xample: In `[0,1]`, `a ≤ b` implies `1 - b ≤ 1 - a`.
- **G**eneralization: Orthocomplementation is an antitone involution on every
  effect algebra.
- **B**oundary: Requires the full effect-algebra structure.
-/

/-- Orthocomplementation reverses the natural order. -/
theorem ortho_antitone (a b : E) (h : ele a b) : ele (ortho b) (ortho a) := by
  obtain ⟨c, hc⟩ := h
  obtain ⟨f, hf1, hf2⟩ := EffectAlgebra.oplus_assoc a c (ortho b) b eone hc
    (EffectAlgebra.oplus_ortho b)
  refine ⟨c, ?_⟩
  rw [EffectAlgebra.oplus_comm, hf1, EffectAlgebra.ortho_unique a f hf2]

/-! ## Theorem 5: Morphisms preserve orthocomplements -/

/-- A morphism of effect algebras. -/
structure EffectHom (E F : Type*) [EffectAlgebra E] [EffectAlgebra F] where
  /-- The underlying map. -/
  toFun : E → F
  /-- Orthogonal sums are preserved. -/
  map_oplus : ∀ a b c, oplus a b = some c → oplus (toFun a) (toFun b) = some (toFun c)
  /-- The unit is preserved. -/
  map_one : toFun eone = eone

/-- Every effect-algebra morphism automatically preserves orthocomplements. -/
theorem EffectHom.map_ortho {F : Type*} [EffectAlgebra F]
    (f : EffectHom E F) (a : E) : f.toFun (ortho a) = ortho (f.toFun a) := by
  have h := f.map_oplus a (ortho a) eone (EffectAlgebra.oplus_ortho a)
  rw [f.map_one] at h
  exact (EffectAlgebra.ortho_unique _ _ h).symm

/-! ## Theorem 6: The two-element Boolean effect algebra

**PEGB**:
- **P**roof: Direct construction with `⊕` = XOR (undefined on `true + true`).
- **E**xample: `false ⊕ true = some true`, `true ⊕ true = none`.
- **G**eneralization: Every Boolean algebra yields an effect algebra.
- **B**oundary: Non-distributive orthomodular lattices give non-Boolean ones.
-/

/-- Partial addition on `Bool`: XOR, undefined on `true, true`. -/
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
  oplus_eone_eq_ezero := by intro a b h; cases a <;> simp_all [boolOplus]
  ortho_unique := by intro a b h; cases a <;> cases b <;> simp_all [boolOplus]

example : boolOplus false true = some true := rfl
example : boolOplus true true = none := rfl

/-! ## Theorem 7: The unit interval effect algebra `[0,1] ⊂ ℝ`

The standard quantum effect algebra: `x ⊕ y = x + y` when `x + y ≤ 1`. -/

/-- Elements of the unit interval `[0, 1]`. -/
@[ext]
structure UnitInterval where
  /-- The underlying real number. -/
  val : ℝ
  /-- Nonnegativity. -/
  ge_zero : 0 ≤ val
  /-- Bounded by one. -/
  le_one : val ≤ 1

namespace UnitInterval

/-- Truncated addition on `[0,1]`: defined exactly when the sum stays in range. -/
noncomputable def uiOplus (x y : UnitInterval) : Option UnitInterval :=
  if h : x.val + y.val ≤ 1 then
    some ⟨x.val + y.val, by have := x.ge_zero; have := y.ge_zero; linarith, h⟩
  else none

theorem uiOplus_eq_some {x y z : UnitInterval} :
    uiOplus x y = some z ↔ x.val + y.val ≤ 1 ∧ x.val + y.val = z.val := by
  unfold uiOplus
  split
  · rename_i h
    constructor
    · rintro h2; exact ⟨h, by rw [← Option.some.inj h2]⟩
    · rintro ⟨_, h3⟩; exact congrArg some (UnitInterval.ext h3)
  · rename_i h
    simp only [reduceCtorEq, false_iff, not_and]
    intro h2; exact absurd h2 h

noncomputable instance instEffectAlgebra : EffectAlgebra UnitInterval where
  oplus := uiOplus
  ezero := ⟨0, le_refl 0, zero_le_one⟩
  eone := ⟨1, zero_le_one, le_refl 1⟩
  ortho x := ⟨1 - x.val, by have := x.le_one; linarith, by have := x.ge_zero; linarith⟩
  oplus_comm a b := by
    ext z
    simp only [uiOplus_eq_some]
    rw [add_comm]
  oplus_assoc := by
    intro a b c d e h1 h2
    rw [uiOplus_eq_some] at h1 h2
    obtain ⟨h1a, h1b⟩ := h1
    obtain ⟨h2a, h2b⟩ := h2
    have hb := b.ge_zero
    have hc := c.ge_zero
    have ha := a.ge_zero
    refine ⟨⟨b.val + c.val, by linarith, by linarith⟩, ?_, ?_⟩
    · rw [uiOplus_eq_some]; exact ⟨by linarith, rfl⟩
    · rw [uiOplus_eq_some]; exact ⟨by simp; linarith, by simp; linarith⟩
  oplus_ezero a := by
    rw [uiOplus_eq_some]; exact ⟨by simpa using a.le_one, by simp⟩
  oplus_ortho a := by rw [uiOplus_eq_some]; constructor <;> simp
  oplus_eone_eq_ezero := by
    intro a b h
    rw [uiOplus_eq_some] at h
    have := a.ge_zero
    exact UnitInterval.ext (by simp only at h ⊢; linarith [h.1])
  ortho_unique := by
    intro a b h
    rw [uiOplus_eq_some] at h
    exact UnitInterval.ext (by simp only; linarith [h.2])

end UnitInterval

end Hilbert6

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