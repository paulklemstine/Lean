import Mathlib

/-!
# Hilbert's Sixth Problem: effect algebras

Auto-generated salvage file.

Repaired: the generated text was a fragment — it opened in the middle of a proof,
the `EffectAlgebra` class, the order relation `ele`, the `EffectHom` structure and
all of the `import`/`namespace` scaffolding were missing, and the surviving proof
scripts referred to anonymous instance binders that no longer existed.  The
statements of the salvaged theorems are kept verbatim; the missing scaffolding is
supplied here and every proof is given in full, together with the two promised
models (the Boolean effect algebra on `Bool` and the unit-interval effect algebra).

An *effect algebra* is a partial commutative monoid with an orthosupplement: it is
the standard order-theoretic axiomatisation of the "yes/no measurements" of a
physical theory, and it is the setting in which Hilbert's sixth problem is usually
attacked today.
-/

/-- An effect algebra: a set with a partial, commutative, associative addition,
a zero, a unit, and a unique orthosupplement. -/
class EffectAlgebra (E : Type*) where
  /-- The partial sum; `none` means the sum is undefined. -/
  oplus : E → E → Option E
  /-- The zero effect. -/
  ezero : E
  /-- The unit effect. -/
  eone : E
  /-- The orthosupplement. -/
  ortho : E → E
  oplus_comm : ∀ a b, oplus a b = oplus b a
  oplus_assoc : ∀ a b c d e, oplus a b = some d → oplus d c = some e →
    ∃ f, oplus b c = some f ∧ oplus a f = some e
  oplus_ezero : ∀ a, oplus a ezero = some a
  oplus_ortho : ∀ a, oplus a (ortho a) = some eone
  oplus_eone_eq_ezero : ∀ a b, oplus a eone = some b → a = ezero
  ortho_unique : ∀ a b, oplus a b = some eone → b = ortho a

namespace EffectAlgebra

@[inherit_doc] infixl:65 " ⊕ₑ " => EffectAlgebra.oplus

variable {E : Type*} [EffectAlgebra E]

/-- The natural order of an effect algebra: `a ≤ b` when `b` is `a` plus something. -/
def ele (a b : E) : Prop := ∃ c, a ⊕ₑ c = some b

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
theorem ortho_involutive (a : E) : ortho (ortho a) = a :=
  (ortho_unique (ortho a) a (by rw [oplus_comm]; exact oplus_ortho a)).symm

/-- The orthosupplement is injective. -/
theorem ortho_injective : Function.Injective (ortho : E → E) := by
  intro a b h
  rw [← ortho_involutive a, ← ortho_involutive b, h]

/-! ## Theorem 1: Cancellation -/

/-
Cancellation: a summand is determined by the sum.
-/
theorem cancel_left (a b c d : E)
    (h1 : a ⊕ₑ b = some d) (h2 : a ⊕ₑ c = some d) : b = c := by
  -- `b ⊕ ortho d = ortho a` and likewise for `c`.
  obtain ⟨f, hf1, hf2⟩ := oplus_assoc a b (ortho d) d eone h1 (oplus_ortho d)
  obtain ⟨g, hg1, hg2⟩ := oplus_assoc a c (ortho d) d eone h2 (oplus_ortho d)
  have hf : f = ortho a := ortho_unique a f hf2
  have hg : g = ortho a := ortho_unique a g hg2
  subst hf; subst hg
  -- Now feed these back through associativity to identify `ortho b` and `ortho c`.
  have ha : ortho a ⊕ₑ a = some eone := by rw [oplus_comm]; exact oplus_ortho a
  obtain ⟨h, hh1, hh2⟩ := oplus_assoc b (ortho d) a (ortho a) eone hf1 ha
  obtain ⟨k, hk1, hk2⟩ := oplus_assoc c (ortho d) a (ortho a) eone hg1 ha
  have hhk : h = k := by
    have := hh1.symm.trans hk1
    exact Option.some.inj this
  have hb : ortho b = h := (ortho_unique b h hh2).symm
  have hc : ortho c = k := (ortho_unique c k hk2).symm
  exact ortho_injective (by rw [hb, hc, hhk])

/-! ## Theorem 3: ortho(eone) = ezero and ortho(ezero) = eone -/

/-
ortho(eone) = ezero.
-/
theorem ortho_eone : ortho (eone : E) = ezero := by
  have h : (eone : E) ⊕ₑ ezero = some eone := oplus_ezero eone
  exact (ortho_unique eone ezero h).symm

theorem ortho_ezero : ortho (ezero : E) = eone := by
  rw [← ortho_eone (E := E), ortho_involutive]

/-! ## Theorem 4: transitivity of the natural order -/

theorem ele_trans (a b c : E)
    (h1 : ele a b) (h2 : ele b c) : ele a c := by
  obtain ⟨c₁, hc₁⟩ := h1
  obtain ⟨c₂, hc₂⟩ := h2
  obtain ⟨f, _, hf₂⟩ := oplus_assoc a c₁ c₂ b c hc₁ hc₂
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
  obtain ⟨f, hf1, hf2⟩ := oplus_assoc a c (ortho b) b eone hc (oplus_ortho b)
  refine ⟨c, ?_⟩
  rw [oplus_comm, hf1, ortho_unique a f hf2]

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

-- Cancellation, instantiated at the Boolean effect algebra.
example (b c : Bool) (h1 : (false : Bool) ⊕ₑ b = some true)
    (h2 : (false : Bool) ⊕ₑ c = some true) : b = c :=
  cancel_left false b c true h1 h2

/-! ## Theorem 7: Unit interval effect algebra [0,1] ⊂ ℝ

The standard quantum effect algebra. -/

/-- Elements of the unit interval [0, 1]. -/
structure UnitInterval where
  val : ℝ
  ge_zero : 0 ≤ val
  le_one : val ≤ 1

namespace UnitInterval

@[ext]
theorem ext {x y : UnitInterval} (h : x.val = y.val) : x = y := by
  cases x; cases y; simpa using h

/-- The partial sum on `[0,1]`: defined exactly when the sum stays below `1`. -/
noncomputable def add (x y : UnitInterval) : Option UnitInterval :=
  if h : x.val + y.val ≤ 1 then
    some ⟨x.val + y.val, by linarith [x.ge_zero, y.ge_zero], h⟩
  else none

/-- The orthosupplement `x ↦ 1 - x` on `[0,1]`. -/
def compl (x : UnitInterval) : UnitInterval :=
  ⟨1 - x.val, by linarith [x.le_one], by linarith [x.ge_zero]⟩

theorem add_eq_some_iff {x y z : UnitInterval} :
    add x y = some z ↔ x.val + y.val ≤ 1 ∧ z.val = x.val + y.val := by
  unfold add
  by_cases h : x.val + y.val ≤ 1
  · simp only [h, dif_pos, Option.some.injEq, true_and]
    constructor
    · rintro rfl; rfl
    · intro hz; ext; simpa using hz.symm
  · simp [h]

noncomputable instance : EffectAlgebra UnitInterval where
  oplus := add
  ezero := ⟨0, le_refl 0, by norm_num⟩
  eone := ⟨1, by norm_num, le_refl 1⟩
  ortho := compl
  oplus_comm := by
    intro a b
    unfold add
    by_cases h : a.val + b.val ≤ 1
    · have h' : b.val + a.val ≤ 1 := by linarith
      simp only [h, h', dif_pos]
      congr 1
      ext
      simpa using add_comm a.val b.val
    · have h' : ¬ b.val + a.val ≤ 1 := by intro hc; exact h (by linarith)
      simp [h, h']
  oplus_assoc := by
    intro a b c d e h1 h2
    rw [add_eq_some_iff] at h1 h2
    obtain ⟨hab, hd⟩ := h1
    obtain ⟨hdc, he⟩ := h2
    have hbc : b.val + c.val ≤ 1 := by
      have := a.ge_zero; rw [hd] at hdc; linarith
    refine ⟨⟨b.val + c.val, by linarith [b.ge_zero, c.ge_zero], hbc⟩, ?_, ?_⟩
    · rw [add_eq_some_iff]; exact ⟨hbc, rfl⟩
    · rw [add_eq_some_iff]
      constructor
      · rw [hd] at hdc; linarith
      · rw [he, hd]; ring
  oplus_ezero := by
    intro a
    rw [add_eq_some_iff]
    exact ⟨by simpa using a.le_one, by simp⟩
  oplus_ortho := by
    intro a
    rw [add_eq_some_iff]
    constructor
    · show a.val + (1 - a.val) ≤ 1; linarith
    · show (1 : ℝ) = a.val + (1 - a.val); ring
  oplus_eone_eq_ezero := by
    intro a b h
    rw [add_eq_some_iff] at h
    have : a.val + 1 ≤ 1 := h.1
    ext
    have := a.ge_zero
    show a.val = 0
    linarith
  ortho_unique := by
    intro a b h
    rw [add_eq_some_iff] at h
    ext
    show b.val = 1 - a.val
    have : (1 : ℝ) = a.val + b.val := h.2
    linarith

end UnitInterval

/-! ## Morphisms of effect algebras -/

/-- A morphism of effect algebras: it preserves the unit and all defined sums. -/
structure EffectHom (E F : Type*) [EffectAlgebra E] [EffectAlgebra F] where
  /-- The underlying function. -/
  toFun : E → F
  /-- The unit is preserved. -/
  map_eone : toFun eone = eone
  /-- Defined sums are preserved. -/
  map_oplus : ∀ a b c, a ⊕ₑ b = some c → toFun a ⊕ₑ toFun b = some (toFun c)

theorem EffectHom.map_ortho {E F : Type*} [EffectAlgebra E] [EffectAlgebra F]
    (f : EffectHom E F) (a : E) : f.toFun (ortho a) = ortho (f.toFun a) := by
  have h := f.map_oplus a (ortho a) eone (oplus_ortho a)
  rw [f.map_eone] at h
  exact ortho_unique _ _ h

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