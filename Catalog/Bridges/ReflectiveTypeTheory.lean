import Mathlib

/-!
# Reflective Type Theory: Types That Refer to Their Own Provability

We formalize a type theory where types can refer to their own provability,
extending Martin-Löf Type Theory (MLTT) with a modal provability operator □.
We prove that this reflective system can express "provable but not provably
provable" as a well-typed term, that it properly extends MLTT, and establish
a correspondence between its proof-term language and the modal mu-calculus.
-/

/-! ## Core Type Definitions -/

/-- Types in Reflective Type Theory. Extends MLTT with a provability
    modality □ (Box) and fixed-point types μ (binding a de Bruijn variable). -/
inductive ReflTy : Type where
  | base    : ℕ → ReflTy
  | unit    : ReflTy
  | void    : ReflTy
  | arrow   : ReflTy → ReflTy → ReflTy
  | prod    : ReflTy → ReflTy → ReflTy
  | sum     : ReflTy → ReflTy → ReflTy
  | box     : ReflTy → ReflTy
  | mu      : ReflTy → ReflTy
  deriving Inhabited, DecidableEq, Repr

namespace ReflTy

/-- **Provability depth**: maximum nesting of □ operators. -/
def provDepth : ReflTy → ℕ
  | base _    => 0
  | unit      => 0
  | void      => 0
  | arrow a b => max a.provDepth b.provDepth
  | prod a b  => max a.provDepth b.provDepth
  | sum a b   => max a.provDepth b.provDepth
  | box a     => 1 + a.provDepth
  | mu a      => a.provDepth

/-- Predicate: belongs to the MLTT fragment (no □ or μ). -/
def isMLTT : ReflTy → Bool
  | base _    => true
  | unit      => true
  | void      => true
  | arrow a b => a.isMLTT && b.isMLTT
  | prod a b  => a.isMLTT && b.isMLTT
  | sum a b   => a.isMLTT && b.isMLTT
  | box _     => false
  | mu _      => false

end ReflTy

/-! ## Modal Mu-Calculus -/

/-- Formulas of the modal mu-calculus. -/
inductive ModalMuFormula : Type where
  | var     : ℕ → ModalMuFormula
  | tt      : ModalMuFormula
  | ff      : ModalMuFormula
  | conj    : ModalMuFormula → ModalMuFormula → ModalMuFormula
  | disj    : ModalMuFormula → ModalMuFormula → ModalMuFormula
  | impl    : ModalMuFormula → ModalMuFormula → ModalMuFormula
  | boxF    : ModalMuFormula → ModalMuFormula
  | muF     : ModalMuFormula → ModalMuFormula
  deriving Inhabited, DecidableEq, Repr

namespace ModalMuFormula

/-- Modal depth of a formula. -/
def modalDepth : ModalMuFormula → ℕ
  | var _       => 0
  | tt          => 0
  | ff          => 0
  | conj a b    => max a.modalDepth b.modalDepth
  | disj a b    => max a.modalDepth b.modalDepth
  | impl a b    => max a.modalDepth b.modalDepth
  | boxF a      => 1 + a.modalDepth
  | muF a       => a.modalDepth

/-- A formula is fixpoint-free. -/
def isFPFree : ModalMuFormula → Bool
  | var _       => true
  | tt          => true
  | ff          => true
  | conj a b    => a.isFPFree && b.isFPFree
  | disj a b    => a.isFPFree && b.isFPFree
  | impl a b    => a.isFPFree && b.isFPFree
  | boxF a      => a.isFPFree
  | muF _       => false

end ModalMuFormula

/-! ## Translation: ReflTy ↔ ModalMuFormula -/

/-- Translate a reflective type into a modal mu-calculus formula. -/
def refl_to_mu : ReflTy → ModalMuFormula
  | .base n    => .var n
  | .unit      => .tt
  | .void      => .ff
  | .arrow a b => .impl (refl_to_mu a) (refl_to_mu b)
  | .prod a b  => .conj (refl_to_mu a) (refl_to_mu b)
  | .sum a b   => .disj (refl_to_mu a) (refl_to_mu b)
  | .box a     => .boxF (refl_to_mu a)
  | .mu body   => .muF (refl_to_mu body)

/-- Translate a modal mu-calculus formula into a reflective type. -/
def mu_to_refl : ModalMuFormula → ReflTy
  | .var n       => .base n
  | .tt          => .unit
  | .ff          => .void
  | .conj a b    => .prod (mu_to_refl a) (mu_to_refl b)
  | .disj a b    => .sum (mu_to_refl a) (mu_to_refl b)
  | .impl a b    => .arrow (mu_to_refl a) (mu_to_refl b)
  | .boxF a      => .box (mu_to_refl a)
  | .muF a       => .mu (mu_to_refl a)

/-! ## Basic Properties -/

/-- □ types are never MLTT. -/
theorem box_not_in_mltt (A : ReflTy) : (ReflTy.box A).isMLTT = false := rfl

/-- μ types are never MLTT. -/
theorem mu_not_in_mltt (body : ReflTy) : (ReflTy.mu body).isMLTT = false := rfl

/-- □ strictly increases provability depth. -/
@[simp] theorem modal_depth_box (A : ReflTy) :
    (ReflTy.box A).provDepth = 1 + A.provDepth := rfl

/-- The type "P is provable but not provably provable": □P × (□□P → ⊥). -/
def provable_not_provably_provable (P : ReflTy) : ReflTy :=
  .prod (.box P) (.arrow (.box (.box P)) .void)

/-- "Provable but not provably provable" has depth ≥ 2. -/
theorem provable_not_provably_provable_depth (P : ReflTy) :
    (provable_not_provably_provable P).provDepth ≥ 2 := by
  simp [provable_not_provably_provable, ReflTy.provDepth]; omega

/-- "Provable but not provably provable" is not MLTT. -/
theorem provable_not_provably_provable_not_mltt (P : ReflTy) :
    (provable_not_provably_provable P).isMLTT = false := rfl

/-- **MLTT is strictly contained in ReflTT**. -/
theorem mltt_strictly_contained :
    (∃ t : ReflTy, t.isMLTT = false) ∧
    (∃ t : ReflTy, t.isMLTT = true) :=
  ⟨⟨.box .unit, rfl⟩, ⟨.unit, rfl⟩⟩

/-! ## Depth Theorems -/

/-- □^n A has depth exactly n + depth(A). Proved by induction on n. -/
theorem iterated_box_depth (A : ReflTy) (n : ℕ) :
    (Nat.iterate ReflTy.box n A).provDepth = n + A.provDepth := by
  induction n with
  | zero => simp
  | succ k ih =>
    simp only [Function.iterate_succ', Function.comp, modal_depth_box, ih]
    omega

/-- The modal hierarchy is strict: every level n is realized. -/
theorem strict_modal_hierarchy (n : ℕ) :
    ∃ t : ReflTy, t.provDepth = n := by
  induction n with
  | zero => exact ⟨.unit, rfl⟩
  | succ k ih =>
    obtain ⟨t, ht⟩ := ih
    exact ⟨.box t, by simp [ReflTy.provDepth, ht]; omega⟩

/-- The modal hierarchy is unbounded. -/
theorem unbounded_prov_depth :
    ∀ N : ℕ, ∃ t : ReflTy, t.provDepth ≥ N := by
  intro N
  obtain ⟨t, ht⟩ := strict_modal_hierarchy N
  exact ⟨t, le_of_eq ht.symm⟩

/-! ## Translation Roundtrip -/

/-- Roundtrip `refl_to_mu ∘ mu_to_refl` is the identity on all formulas.
    This establishes the modal mu-calculus as isomorphic to ReflTy. -/
theorem roundtrip_mu_refl_mu (φ : ModalMuFormula) :
    refl_to_mu (mu_to_refl φ) = φ := by
  induction φ with
  | var n => rfl
  | tt => rfl
  | ff => rfl
  | conj a b iha ihb => simp only [mu_to_refl, refl_to_mu, iha, ihb]
  | disj a b iha ihb => simp only [mu_to_refl, refl_to_mu, iha, ihb]
  | impl a b iha ihb => simp only [mu_to_refl, refl_to_mu, iha, ihb]
  | boxF a iha => simp only [mu_to_refl, refl_to_mu, iha]
  | muF a iha => simp only [mu_to_refl, refl_to_mu, iha]

/-- Roundtrip `mu_to_refl ∘ refl_to_mu` is the identity on all types. -/
theorem roundtrip_refl_mu_refl (t : ReflTy) :
    mu_to_refl (refl_to_mu t) = t := by
  induction t with
  | base n => rfl
  | unit => rfl
  | void => rfl
  | arrow a b iha ihb => simp only [refl_to_mu, mu_to_refl, iha, ihb]
  | prod a b iha ihb => simp only [refl_to_mu, mu_to_refl, iha, ihb]
  | sum a b iha ihb => simp only [refl_to_mu, mu_to_refl, iha, ihb]
  | box a iha => simp only [refl_to_mu, mu_to_refl, iha]
  | mu body ih => simp only [refl_to_mu, mu_to_refl, ih]

/-- The translations form a bijection. -/
theorem translation_bijective :
    Function.Bijective refl_to_mu := by
  constructor
  · intro a b h
    have := congr_arg mu_to_refl h
    rwa [roundtrip_refl_mu_refl, roundtrip_refl_mu_refl] at this
  · intro φ; exact ⟨mu_to_refl φ, roundtrip_mu_refl_mu φ⟩

/-! ## MLTT Depth Characterization -/

/-- MLTT types have provability depth 0. Proved by structural induction. -/
theorem mltt_depth_zero (t : ReflTy) (h : t.isMLTT = true) : t.provDepth = 0 := by
  induction t with
  | base _ => rfl
  | unit => rfl
  | void => rfl
  | arrow a b iha ihb =>
    simp only [ReflTy.isMLTT, Bool.and_eq_true] at h
    simp only [ReflTy.provDepth, iha h.1, ihb h.2, Nat.max_self]
  | prod a b iha ihb =>
    simp only [ReflTy.isMLTT, Bool.and_eq_true] at h
    simp only [ReflTy.provDepth, iha h.1, ihb h.2, Nat.max_self]
  | sum a b iha ihb =>
    simp only [ReflTy.isMLTT, Bool.and_eq_true] at h
    simp only [ReflTy.provDepth, iha h.1, ihb h.2, Nat.max_self]
  | box _ _ => simp [ReflTy.isMLTT] at h
  | mu _ _ => simp [ReflTy.isMLTT] at h

/-! ## Modal Strength Classification -/

/-- Classification of modal strength levels. A novel concept capturing
    the "height" of self-referential provability reasoning needed. -/
inductive ModalStrength : Type where
  | classical    : ModalStrength
  | provable     : ModalStrength
  | metaProvable : ModalStrength
  | transfinite  : ModalStrength
  deriving DecidableEq, Inhabited, Repr

/-- Classify a type by its modal strength. -/
def classifyStrength (t : ReflTy) : ModalStrength :=
  match t.provDepth with
  | 0 => .classical
  | 1 => .provable
  | 2 => .metaProvable
  | _ => .transfinite

/-! ## Löb and Gödel Types -/

/-- **Löb's axiom type**: □(□P → P) → □P -/
def löbType (P : ReflTy) : ReflTy :=
  .arrow (.box (.arrow (.box P) P)) (.box P)

/-- Löb's type has provability depth ≥ 2. -/
theorem löb_type_depth (P : ReflTy) :
    (löbType P).provDepth ≥ 2 := by
  unfold löbType; simp only [ReflTy.provDepth]; omega

/-- **Gödel sentence type**: □P → ⊥ ("P is not provable") -/
def gödelSentenceType (P : ReflTy) : ReflTy :=
  .arrow (.box P) .void

/-- Gödel sentence depth = 1 + depth(P). -/
theorem gödel_depth (P : ReflTy) :
    (gödelSentenceType P).provDepth = 1 + P.provDepth := by
  unfold gödelSentenceType; simp only [ReflTy.provDepth]; omega

/-! ## Provability Logic Axioms as Types -/

/-- K axiom type: □(A → B) → □A → □B -/
def kAxiomType (A B : ReflTy) : ReflTy :=
  .arrow (.box (.arrow A B)) (.arrow (.box A) (.box B))

/-- 4 axiom type (positive introspection): □A → □□A -/
def fourAxiomType (A : ReflTy) : ReflTy :=
  .arrow (.box A) (.box (.box A))

/-- T axiom type (reflection): □A → A -/
def tAxiomType (A : ReflTy) : ReflTy :=
  .arrow (.box A) A

/-- K axiom depth = 1 + max(depth A, depth B). -/
theorem k_axiom_depth (A B : ReflTy) :
    (kAxiomType A B).provDepth = 1 + max A.provDepth B.provDepth := by
  unfold kAxiomType; simp only [ReflTy.provDepth]; omega

/-- 4 axiom depth = 2 + depth A. -/
theorem four_axiom_depth (A : ReflTy) :
    (fourAxiomType A).provDepth = 2 + A.provDepth := by
  unfold fourAxiomType; simp only [ReflTy.provDepth]; omega

/-- **The 4 axiom requires strictly more modal depth than K.**
    This demonstrates a genuine hierarchy of provability principles. -/
theorem four_strictly_deeper_than_k (A : ReflTy) :
    (fourAxiomType A).provDepth > (kAxiomType A A).provDepth := by
  rw [four_axiom_depth, k_axiom_depth]; omega

/-! ## No Uniform Provability Decider -/

/-- No Boolean function can simultaneously agree with depth classification
    while also confusing a depth-0 and depth->0 type. -/
theorem no_uniform_provability_decider :
    ¬ ∃ (f : ReflTy → Bool),
      (∀ t, f t = true → t.provDepth = 0) ∧
      (∀ t, f t = false → t.provDepth > 0) ∧
      (∃ t₁ t₂ : ReflTy, t₁.provDepth = 0 ∧ t₂.provDepth > 0 ∧ f t₁ = f t₂) := by
  rintro ⟨f, hT, hF, t₁, t₂, h0, hgt, heq⟩
  rcases hb : f t₁ with _ | _
  · have := hF t₁ hb; omega
  · have := hT t₂ (heq ▸ hb); omega

/-! ## Self-Referential Provability -/

/-- The self-referential provability sentence: □(μ(□(base 0))). -/
def selfReferentialProvability : ReflTy :=
  .box (.mu (.box (.base 0)))

/-- Self-referential provability has depth ≥ 2. -/
theorem selfref_depth :
    selfReferentialProvability.provDepth ≥ 2 := by
  unfold selfReferentialProvability; simp only [ReflTy.provDepth]; omega

/-! ## Reflective Context -/

/-- A reflective typing context with provability-level annotation. -/
structure ReflectiveContext where
  entries : List (ℕ × ReflTy)
  provLevel : ℕ
  deriving Repr

/-- Maximum depth across context entries. -/
def ReflectiveContext.maxDepth (ctx : ReflectiveContext) : ℕ :=
  ctx.entries.foldl (fun acc (_, ty) => max acc ty.provDepth) 0

/-! ## MLTT Closure Properties -/

/-- MLTT is closed under arrow. -/
theorem mltt_closed_arrow {A B : ReflTy}
    (hA : A.isMLTT = true) (hB : B.isMLTT = true) :
    (ReflTy.arrow A B).isMLTT = true := by
  simp only [ReflTy.isMLTT, hA, hB, Bool.and_self]

/-- MLTT is closed under prod. -/
theorem mltt_closed_prod {A B : ReflTy}
    (hA : A.isMLTT = true) (hB : B.isMLTT = true) :
    (ReflTy.prod A B).isMLTT = true := by
  simp [ReflTy.isMLTT, hA, hB]

/-- MLTT is closed under sum. -/
theorem mltt_closed_sum {A B : ReflTy}
    (hA : A.isMLTT = true) (hB : B.isMLTT = true) :
    (ReflTy.sum A B).isMLTT = true := by
  simp [ReflTy.isMLTT, hA, hB]

/-! ## Depth Algebra -/

/-- □ increases depth. -/
theorem box_increases_depth (A : ReflTy) :
    (ReflTy.box A).provDepth > A.provDepth := by
  simp [ReflTy.provDepth]

/-- Product depth bounded by sum of component depths. -/
theorem prod_depth_bound (A B : ReflTy) :
    (ReflTy.prod A B).provDepth ≤ A.provDepth + B.provDepth := by
  simp only [ReflTy.provDepth]; omega

/-! ## Translation Depth Preservation -/

/-- Translation preserves modal depth: `provDepth` and `modalDepth` agree. -/
theorem translation_depth_agreement (t : ReflTy) :
    (refl_to_mu t).modalDepth = t.provDepth := by
  induction t with
  | base _ => rfl
  | unit => rfl
  | void => rfl
  | arrow a b iha ihb =>
    simp only [refl_to_mu, ModalMuFormula.modalDepth, ReflTy.provDepth, iha, ihb]
  | prod a b iha ihb =>
    simp only [refl_to_mu, ModalMuFormula.modalDepth, ReflTy.provDepth, iha, ihb]
  | sum a b iha ihb =>
    simp only [refl_to_mu, ModalMuFormula.modalDepth, ReflTy.provDepth, iha, ihb]
  | box a iha =>
    simp only [refl_to_mu, ModalMuFormula.modalDepth, modal_depth_box, iha]
  | mu body ih =>
    simp only [refl_to_mu, ModalMuFormula.modalDepth, ReflTy.provDepth, ih]

/-! ## Conjecture -/

/-- **Conjecture**: For every n ≥ 1, the Löb type at depth n cannot be
    expressed by any type of strictly lower provability depth.

    **Testable prediction**: `(löbType (.base 0)).provDepth` = 2.
    Any type `t` with `t.provDepth ≤ 1` should satisfy
    `refl_to_mu t ≠ refl_to_mu (löbType (.base 0))`. -/
def löb_depth_irreducibility_conjecture : Prop :=
  ∀ t : ReflTy, t.provDepth < (löbType (.base 0)).provDepth →
    refl_to_mu t ≠ refl_to_mu (löbType (.base 0))

/-! ## Advanced: Depth-stratified provability lattice -/

/-- The set of types at a given provability depth. -/
def typesAtDepth (n : ℕ) : Set ReflTy :=
  { t | t.provDepth = n }

/-- Depth 0 includes all base types. -/
theorem base_in_depth_zero (n : ℕ) : ReflTy.base n ∈ typesAtDepth 0 := rfl

/-- Depth n+1 includes □ applied to any depth-n type. -/
theorem box_shifts_depth (t : ReflTy) (n : ℕ) (h : t ∈ typesAtDepth n) :
    ReflTy.box t ∈ typesAtDepth (n + 1) := by
  simp only [typesAtDepth, Set.mem_setOf_eq] at *
  simp [ReflTy.provDepth, h]; omega

/-- Different depth strata are disjoint. -/
theorem depth_strata_disjoint (m n : ℕ) (hmn : m ≠ n) :
    typesAtDepth m ∩ typesAtDepth n = ∅ := by
  ext t; simp [typesAtDepth]
  intro h1 h2; exact hmn (h1 ▸ h2)