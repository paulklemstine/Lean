import Mathlib

/-!
# Hilbert's sixth problem: effect algebras

This file is the salvaged and completed version of a fragment of an axiomatisation
of quantum measurement in the spirit of Hilbert's sixth problem.  The fragment
consisted of statements about *effect algebras* (Foulis–Bennett) whose underlying
class declaration, notation and instances had been lost; they are reconstructed
here and every statement is given a complete proof.

An **effect algebra** is a set `E` with a partial binary operation `⊕ₑ`, two
distinguished elements `0` and `1`, and an orthosupplement `ortho`, subject to
commutativity, a partial associativity law, `a ⊕ₑ 0 = a`, `a ⊕ₑ ortho a = 1`,
uniqueness of the orthosupplement, and the "zero–one law" `a ⊕ₑ 1` defined
implies `a = 0`.  The unit interval `[0,1] ⊆ ℝ` and the two-element Boolean
algebra are the motivating examples.
-/

/-- An **effect algebra**: a partial commutative monoid with orthosupplements,
the standard algebraic model of a quantum measurement ("effect"). -/
class EffectAlgebra (E : Type*) where
  /-- The partial addition; `none` means "undefined". -/
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
  ortho_unique : ∀ a b, oplus a b = some eone → ortho a = b

namespace EffectAlgebra

@[inherit_doc] infixl:65 " ⊕ₑ " => EffectAlgebra.oplus

variable {E : Type*} [EffectAlgebra E]

/-- The natural order of an effect algebra: `a ≤ b` iff `b = a ⊕ₑ c` for some `c`. -/
def ele (a b : E) : Prop := ∃ c, a ⊕ₑ c = some b

/-! ## Theorem 1: Left cancellation

**PEGB**:
- **P**roof: pass to orthosupplements twice; the intermediate value `ortho d ⊕ₑ a`
  is determined by `a` and `d` alone, so `ortho b = ortho c`.
- **E**xample: in `[0,1]`, `a + b = a + c` forces `b = c`.
- **G**eneralization: every effect algebra is a cancellative partial monoid.
- **B**oundary: cancellation fails for partial monoids without orthosupplements.
-/

/-- The orthocomplement is an involution: `ortho (ortho a) = a`. -/
theorem ortho_involutive (a : E) : ortho (ortho a) = a := by
  refine ortho_unique (ortho a) a ?_
  rw [oplus_comm]
  exact oplus_ortho a

/-- Cancellation on the left. -/
theorem cancel_left (a b c d : E)
    (h1 : a ⊕ₑ b = some d) (h2 : a ⊕ₑ c = some d) : b = c := by
  -- `b ⊕ₑ ortho d` and `c ⊕ₑ ortho d` are both orthosupplements of `a`
  obtain ⟨f, hf1, hf2⟩ := oplus_assoc a b (ortho d) d eone h1 (oplus_ortho d)
  obtain ⟨g, hg1, hg2⟩ := oplus_assoc a c (ortho d) d eone h2 (oplus_ortho d)
  have hfa : ortho a = f := ortho_unique a f hf2
  have hga : ortho a = g := ortho_unique a g hg2
  have hfg : f = g := hfa ▸ hga
  -- now `b` and `c` are both orthosupplements of the *same* element `ortho d ⊕ₑ a`
  obtain ⟨u, hu1, hu2⟩ :=
    oplus_assoc b (ortho d) a f eone hf1 (by rw [oplus_comm]; exact hf2)
  obtain ⟨v, hv1, hv2⟩ :=
    oplus_assoc c (ortho d) a g eone hg1 (by rw [oplus_comm]; exact hg2)
  have huv : u = v := by
    have : some u = some v := hu1 ▸ hv1
    exact Option.some.inj this
  have hb : ortho b = u := ortho_unique b u hu2
  have hc : ortho c = v := ortho_unique c v hv2
  have : ortho b = ortho c := by rw [hb, hc, huv]
  calc b = ortho (ortho b) := (ortho_involutive b).symm
    _ = ortho (ortho c) := by rw [this]
    _ = c := ortho_involutive c

/-! ## Theorem 2: `ortho eone = ezero` and `ortho ezero = eone` -/

/-- The orthosupplement of `0` is `1`. -/
theorem ortho_ezero : ortho (ezero : E) = eone := by
  refine ortho_unique ezero eone ?_
  rw [oplus_comm]
  exact oplus_ezero eone

/-- The orthosupplement of `1` is `0`. -/
theorem ortho_eone : ortho (eone : E) = ezero := by
  have := ortho_involutive (ezero : E)
  rw [ortho_ezero] at this
  exact this

/-! ## Theorem 3: the natural order is transitive -/

/-- The natural order of an effect algebra is transitive. -/
theorem ele_trans (a b c : E)
    (h1 : ele a b) (h2 : ele b c) : ele a c := by
  obtain ⟨c₁, hc₁⟩ := h1
  obtain ⟨c₂, hc₂⟩ := h2
  obtain ⟨f, _, hf₂⟩ := oplus_assoc a c₁ c₂ b c hc₁ hc₂
  exact ⟨f, hf₂⟩

/-- The natural order is reflexive. -/
theorem ele_refl (a : E) : ele a a := ⟨ezero, oplus_ezero a⟩

/-! ## Theorem 4: orthocomplementation is order-reversing

**PEGB**:
- **P**roof: If `a ≤ b`, i.e. `a ⊕ₑ c = b` for some `c`, then `c ⊕ₑ ortho b` is
  defined and equals `ortho a`, giving `ortho b ≤ ortho a`.
- **E**xample: in `[0,1]`, `a ≤ b` implies `1 - b ≤ 1 - a`.
- **G**eneralization: orthocomplementation is an order-reversing involution
  (antitone involution) on any effect algebra.
- **B**oundary: requires the full effect algebra structure; it fails for partial
  commutative monoids without orthosupplements.
-/

/-- Orthocomplementation reverses the natural order. -/
theorem ortho_antitone (a b : E) (h : ele a b) :
    ele (ortho b) (ortho a) := by
  obtain ⟨c, hc⟩ := h
  obtain ⟨f, hf1, hf2⟩ := oplus_assoc a c (ortho b) b eone hc (oplus_ortho b)
  refine ⟨c, ?_⟩
  rw [oplus_comm, hf1, ortho_unique a f hf2]

/-! ## Theorem 5: the two-element Boolean effect algebra

**PEGB**:
- **P**roof: direct construction with `⊕ₑ = XOR` (undefined on `true ⊕ₑ true`).
- **E**xample: `false ⊕ₑ true = some true`, `true ⊕ₑ true = none`.
- **G**eneralization: every Boolean algebra yields an effect algebra.
- **B**oundary: non-distributive orthomodular lattices give non-Boolean effect
  algebras.
-/

/-- Partial addition on `Bool`: XOR with partiality. -/
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

/-! ## Theorem 6: morphisms preserve orthosupplements -/

/-- A morphism of effect algebras: it preserves the unit and defined sums. -/
structure EffectHom (E F : Type*) [EffectAlgebra E] [EffectAlgebra F] where
  /-- The underlying function. -/
  toFun : E → F
  /-- Morphisms preserve defined sums. -/
  map_oplus : ∀ a b c, a ⊕ₑ b = some c → toFun a ⊕ₑ toFun b = some (toFun c)
  /-- Morphisms preserve the unit. -/
  map_eone : toFun eone = eone

/-- A morphism of effect algebras commutes with orthocomplementation. -/
theorem EffectHom.map_ortho {E F : Type*} [EffectAlgebra E] [EffectAlgebra F]
    (f : EffectHom E F) (a : E) : f.toFun (ortho a) = ortho (f.toFun a) := by
  have h := f.map_oplus a (ortho a) eone (oplus_ortho a)
  rw [f.map_eone] at h
  exact (ortho_unique (f.toFun a) (f.toFun (ortho a)) h).symm

end EffectAlgebra

/-! ## Theorem 7: the unit interval `[0,1] ⊆ ℝ`

The standard quantum effect algebra. -/

/-- Elements of the unit interval `[0, 1]`. -/
structure UnitInterval where
  /-- The underlying real number. -/
  val : ℝ
  ge_zero : 0 ≤ val
  le_one : val ≤ 1

namespace UnitInterval

@[ext]
theorem ext {x y : UnitInterval} (h : x.val = y.val) : x = y := by
  cases x; cases y; simpa using h

open EffectAlgebra in
/-- The unit interval, with truncated addition, is an effect algebra. -/
noncomputable instance : EffectAlgebra UnitInterval where
  oplus x y :=
    if h : x.val + y.val ≤ 1 then
      some ⟨x.val + y.val, by have := x.ge_zero; have := y.ge_zero; linarith, h⟩
    else none
  ezero := ⟨0, le_refl 0, by norm_num⟩
  eone := ⟨1, by norm_num, le_refl 1⟩
  ortho x := ⟨1 - x.val, by have := x.le_one; linarith, by have := x.ge_zero; linarith⟩
  oplus_comm a b := by
    by_cases h : a.val + b.val ≤ 1
    · rw [dif_pos h, dif_pos (show b.val + a.val ≤ 1 by linarith)]
      exact congrArg some (UnitInterval.ext (by ring))
    · rw [dif_neg h, dif_neg (show ¬ b.val + a.val ≤ 1 from fun hc => h (by linarith))]
  oplus_assoc a b c d e h1 h2 := by
    by_cases hab : a.val + b.val ≤ 1
    · rw [dif_pos hab] at h1
      have hd : d.val = a.val + b.val := (congrArg UnitInterval.val (Option.some.inj h1)).symm
      by_cases hdc : d.val + c.val ≤ 1
      · rw [dif_pos hdc] at h2
        have he : e.val = d.val + c.val := (congrArg UnitInterval.val (Option.some.inj h2)).symm
        rw [hd] at hdc he
        have hb0 := b.ge_zero
        have hc0 := c.ge_zero
        have ha0 := a.ge_zero
        have hbc : b.val + c.val ≤ 1 := by linarith
        refine ⟨⟨b.val + c.val, by linarith, hbc⟩, ?_, ?_⟩
        · rw [dif_pos hbc]
        · rw [dif_pos (show a.val + (b.val + c.val) ≤ 1 by linarith)]
          exact congrArg some (UnitInterval.ext (by simp only; rw [he]; ring))
      · rw [dif_neg hdc] at h2; exact absurd h2 (by simp)
    · rw [dif_neg hab] at h1; exact absurd h1 (by simp)
  oplus_ezero a := by
    have ha := a.le_one
    rw [dif_pos (show a.val + (0 : ℝ) ≤ 1 by linarith)]
    exact congrArg some (UnitInterval.ext (by simp))
  oplus_ortho a := by
    rw [dif_pos (show a.val + (1 - a.val) ≤ 1 by linarith)]
    exact congrArg some (UnitInterval.ext (by simp))
  oplus_eone_eq_ezero a b h := by
    by_cases hle : a.val + (1 : ℝ) ≤ 1
    · have := a.ge_zero
      exact UnitInterval.ext (by simp; linarith)
    · rw [dif_neg hle] at h; exact absurd h (by simp)
  ortho_unique a b h := by
    by_cases hle : a.val + b.val ≤ 1
    · rw [dif_pos hle] at h
      have hv : a.val + b.val = 1 := congrArg UnitInterval.val (Option.some.inj h)
      exact UnitInterval.ext (by simp; linarith)
    · rw [dif_neg hle] at h; exact absurd h (by simp)

end UnitInterval

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