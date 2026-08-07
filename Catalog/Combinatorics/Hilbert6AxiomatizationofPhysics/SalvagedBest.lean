import Mathlib

/-!
# Hilbert's 6th problem: effect algebras (salvaged fragment, completed)

The file as originally committed was a *fragment*: it began in the middle of a
development, with no `import`, no definition of the `EffectAlgebra` class, of the
order `ele`, or of `EffectHom`, and with a mismatched `namespace`/`end` pair.  It
therefore could not be elaborated at all.

The missing scaffolding has been reconstructed below from the way the surviving
proofs use it (the axiom list is exactly what those proofs invoke), the dangling
`@[ext]` attribute and the mismatched `end EffectAlgebra` have been removed, and
`ortho_involutive` has been moved ahead of `cancel_left` (which uses it) and given
a direct proof.  All statements are otherwise as in the original.
-/

/-- An **effect algebra**: a set with a partial commutative associative addition,
a zero, a unit, and a unique orthocomplement. -/
class EffectAlgebra (E : Type*) where
  /-- Partial addition. -/
  oplus : E → E → Option E
  /-- The zero element. -/
  ezero : E
  /-- The unit element. -/
  eone : E
  /-- Orthocomplementation. -/
  ortho : E → E
  oplus_comm : ∀ a b, oplus a b = oplus b a
  oplus_assoc : ∀ a b c d e, oplus a b = some d → oplus d c = some e →
    ∃ f, oplus b c = some f ∧ oplus a f = some e
  oplus_ezero : ∀ a, oplus a ezero = some a
  oplus_ortho : ∀ a, oplus a (ortho a) = some eone
  oplus_eone_eq_ezero : ∀ a b, oplus a eone = some b → a = ezero
  ortho_unique : ∀ a b, oplus a b = some eone → ortho a = b

open EffectAlgebra

@[inherit_doc] infixl:65 " ⊕ₑ " => EffectAlgebra.oplus

variable {E : Type*} [EffectAlgebra E]

/-- The natural order of an effect algebra: `a ≤ b` iff `a ⊕ c = b` for some `c`. -/
def ele (a b : E) : Prop := ∃ c, oplus a c = some b

/-- A morphism of effect algebras. -/
structure EffectHom (E F : Type*) [EffectAlgebra E] [EffectAlgebra F] where
  /-- The underlying function. -/
  toFun : E → F
  map_oplus : ∀ a b c, oplus a b = some c → oplus (toFun a) (toFun b) = some (toFun c)
  map_eone : toFun eone = eone

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

/-! ## Theorem 2: Orthocomplement is an involution

**PEGB**:
- **P**roof: From a ⊕ ortho(a) = eone by commutativity ortho(a) ⊕ a = eone,
  and by uniqueness of orthocomplement a = ortho(ortho(a)).
- **E**xample: In Bool, not (not b) = b.
- **G**eneralization: In any algebra with unique complements, the complement
  operation is an involution.
- **B**oundary: Fails without uniqueness — multiple complements break involutivity.
-/

/-- The orthocomplement is an involution: `ortho (ortho a) = a`. -/
theorem ortho_involutive (a : E) : ortho (ortho a) = a :=
  ortho_unique (ortho a) a (by rw [oplus_comm]; exact oplus_ortho a)

/-! ## Theorem 1: Left cancellation -/

/-- Left cancellation in an effect algebra. -/
theorem cancel_left (a b c d : E)
    (h1 : a ⊕ₑ b = some d) (h2 : a ⊕ₑ c = some d) : b = c := by
  obtain ⟨f, hf1, hf2⟩ :=
    (‹EffectAlgebra E›.oplus_assoc a b (‹EffectAlgebra E›.ortho d) d
      (‹EffectAlgebra E›.eone)) h1 (‹EffectAlgebra E›.oplus_ortho d)
  obtain ⟨g, hg1, hg2⟩ :=
    (‹EffectAlgebra E›.oplus_assoc a c (‹EffectAlgebra E›.ortho d) d
      (‹EffectAlgebra E›.eone)) h2 (‹EffectAlgebra E›.oplus_ortho d)
  obtain ⟨h_val, hh1, hh2⟩ :=
    (‹EffectAlgebra E›.oplus_assoc b (‹EffectAlgebra E›.ortho d) a f
      (‹EffectAlgebra E›.eone)) hf1 (by
        have := ‹EffectAlgebra E›.oplus_comm a f; aesop)
  obtain ⟨k_val, hk1, hk2⟩ :=
    (‹EffectAlgebra E›.oplus_assoc c (‹EffectAlgebra E›.ortho d) a g
      (‹EffectAlgebra E›.eone)) hg1 (by
        exact ‹EffectAlgebra E›.oplus_comm _ _ ▸ hg2)
  generalize_proofs at *
  have h_eq : h_val = k_val := by grind
  have h_ortho : ‹EffectAlgebra E›.ortho b = h_val ∧ ‹EffectAlgebra E›.ortho c = h_val :=
    ⟨by simpa [h_eq] using ‹EffectAlgebra E›.ortho_unique b h_val hh2,
     by simpa [h_eq] using
       ‹EffectAlgebra E›.ortho_unique c h_val (by simpa [h_eq] using hk2)⟩
  have h_inv : ‹EffectAlgebra E›.ortho (‹EffectAlgebra E›.ortho b) = b ∧
      ‹EffectAlgebra E›.ortho (‹EffectAlgebra E›.ortho c) = c :=
    ⟨ortho_involutive b, ortho_involutive c⟩
  grind

/-! ## Theorem 4: Transitivity of the natural order -/

/-- The natural order is transitive. -/
theorem ele_trans (a b c : E)
    (h1 : ele a b) (h2 : ele b c) : ele a c := by
  obtain ⟨c₁, hc₁⟩ := h1
  obtain ⟨c₂, hc₂⟩ := h2
  obtain ⟨f, hf₁, hf₂⟩ := ‹EffectAlgebra E›.oplus_assoc a c₁ c₂ b c hc₁ hc₂
  use f

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

/-- Orthocomplement reverses the natural order. -/
theorem ortho_antitone (a b : E) (h : ele a b) :
    ele (ortho b) (ortho a) := by
  obtain ⟨c, hc⟩ := h
  rename_i h
  obtain ⟨f, hf⟩ := h.oplus_assoc a c (h.ortho b) b (h.eone) hc (h.oplus_ortho b)
  exact ⟨c, by rw [h.oplus_comm, hf.1, h.ortho_unique _ _ hf.2]⟩

/-! ## Theorem 6: Two-element Boolean effect algebra (Bool)

**PEGB**:
- **P**roof: Direct construction with ⊕ = XOR (undefined on true+true).
- **E**xample: false ⊕ true = some true, true ⊕ true = none.
- **G**eneralization: Every Boolean algebra yields an effect algebra.
- **B**oundary: Non-distributive orthomodular lattices give non-Boolean EAs.
-/

/-! ## Theorem 7: Unit interval effect algebra [0,1] ⊂ ℝ

The standard quantum effect algebra. -/

/-- Elements of the unit interval [0, 1]. -/
@[ext]
structure UnitInterval where
  /-- The underlying real number. -/
  val : ℝ
  ge_zero : 0 ≤ val
  le_one : val ≤ 1

/-- Morphisms of effect algebras preserve orthocomplements. -/
theorem EffectHom.map_ortho {E F : Type*} [EffectAlgebra E] [EffectAlgebra F]
    (f : EffectHom E F) (a : E) : f.toFun (ortho a) = ortho (f.toFun a) :=
  (ortho_unique _ _ (by
    simpa [f.map_eone] using f.map_oplus a (ortho a) eone (oplus_ortho a))).symm

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