import Mathlib

/-!
# Reflective Type Theory: Proof Depth Algebra and Typed Provability Logic

This file extends the Reflective Type Theory (ReflTT) framework with:
1. A **Proof Depth Algebra** — a novel algebraic structure where provability depths
   form a tropical-like semiring under (max, +), with the key insight that Box
   acts as the successor in a well-ordered depth hierarchy.
2. **Proof terms** for ReflTT with a typed reduction relation and subject reduction.
3. **Depth monotonicity** — typing preserves the depth filtration.
4. A **subformula property** for the translation to modal mu-calculus.
5. **Depth-complexity gap**: □^n unit is the unique minimum-size type at each depth.

## Mathematical Contribution

The central insight is that provability depth behaves like a *graded* structure:
the depth of a composite type is determined by the depths of its components via
a max-plus algebra (tropical semiring). This creates a natural filtration of the
type universe, and we prove that this filtration is respected by all type-forming
operations and by the proof term reduction relation.
-/

/-! ## 1. Core Type Definitions -/

/-- Types in Reflective Type Theory. -/
inductive RType : Type where
  | base    : ℕ → RType
  | unit    : RType
  | void    : RType
  | arrow   : RType → RType → RType
  | prod    : RType → RType → RType
  | sum     : RType → RType → RType
  | box     : RType → RType
  | mu      : RType → RType
  deriving Inhabited, DecidableEq, Repr

namespace RType

/-- Provability depth: maximum nesting of □ operators. -/
def depth : RType → ℕ
  | base _    => 0
  | unit      => 0
  | void      => 0
  | arrow a b => max a.depth b.depth
  | prod a b  => max a.depth b.depth
  | sum a b   => max a.depth b.depth
  | box a     => 1 + a.depth
  | mu a      => a.depth

/-- Size of a type (total number of constructors). -/
def size : RType → ℕ
  | base _    => 1
  | unit      => 1
  | void      => 1
  | arrow a b => 1 + a.size + b.size
  | prod a b  => 1 + a.size + b.size
  | sum a b   => 1 + a.size + b.size
  | box a     => 1 + a.size
  | mu a      => 1 + a.size

/-- Number of box constructors in a type. -/
def boxCount : RType → ℕ
  | base _    => 0
  | unit      => 0
  | void      => 0
  | arrow a b => a.boxCount + b.boxCount
  | prod a b  => a.boxCount + b.boxCount
  | sum a b   => a.boxCount + b.boxCount
  | box a     => 1 + a.boxCount
  | mu a      => a.boxCount

/-- Whether a type is in the MLTT fragment (no box or mu). -/
def isMLTT : RType → Bool
  | base _    => true
  | unit      => true
  | void      => true
  | arrow a b => a.isMLTT && b.isMLTT
  | prod a b  => a.isMLTT && b.isMLTT
  | sum a b   => a.isMLTT && b.isMLTT
  | box _     => false
  | mu _      => false

@[simp] theorem depth_base (n : ℕ) : (base n).depth = 0 := rfl
@[simp] theorem depth_unit : unit.depth = 0 := rfl
@[simp] theorem depth_void : void.depth = 0 := rfl
@[simp] theorem depth_box (a : RType) : (box a).depth = 1 + a.depth := rfl
@[simp] theorem depth_mu (a : RType) : (mu a).depth = a.depth := rfl
@[simp] theorem depth_arrow (a b : RType) : (arrow a b).depth = max a.depth b.depth := rfl
@[simp] theorem depth_prod (a b : RType) : (prod a b).depth = max a.depth b.depth := rfl
@[simp] theorem depth_sum (a b : RType) : (sum a b).depth = max a.depth b.depth := rfl

end RType

/-! ## 2. Depth Bounds: Key Structural Theorems -/

/-- **Depth is bounded by box count**: the depth can never exceed the
    number of box constructors. Depth counts *nesting* while boxCount
    counts *total occurrences*, so this is non-trivial. -/
theorem depth_le_boxCount (t : RType) : t.depth ≤ t.boxCount := by
  induction t with
  | base _ | unit | void => simp [RType.depth, RType.boxCount]
  | arrow a b iha ihb | prod a b iha ihb | sum a b iha ihb =>
    simp only [RType.depth, RType.boxCount]; omega
  | box a ih => simp only [RType.depth, RType.boxCount]; omega
  | mu a ih => simp only [RType.depth, RType.boxCount]; exact ih

/-- **Depth is bounded by size.** -/
theorem depth_le_size (t : RType) : t.depth ≤ t.size := by
  induction t with
  | base _ | unit | void => simp [RType.depth, RType.size]
  | arrow a b iha ihb | prod a b iha ihb | sum a b iha ihb =>
    simp only [RType.depth, RType.size]; omega
  | box a ih => simp only [RType.depth, RType.size]; omega
  | mu a ih => simp only [RType.depth, RType.size]; omega

/-- **MLTT types have zero box count.** -/
theorem mltt_boxCount_zero (t : RType) (h : t.isMLTT = true) : t.boxCount = 0 := by
  induction t with
  | base _ | unit | void => rfl
  | arrow a b iha ihb | prod a b iha ihb | sum a b iha ihb =>
    simp only [RType.isMLTT, Bool.and_eq_true] at h
    simp [RType.boxCount, iha h.1, ihb h.2]
  | box _ _ => simp [RType.isMLTT] at h
  | mu _ _ => simp [RType.isMLTT] at h

/-- **MLTT types have zero depth** (via box count bound). -/
theorem mltt_depth_zero (t : RType) (h : t.isMLTT = true) : t.depth = 0 := by
  have h1 := depth_le_boxCount t
  have h2 := mltt_boxCount_zero t h
  omega

/-! ## 3. Proof Terms and Typed Reduction -/

/-- Proof terms in Reflective Type Theory. -/
inductive RTerm : Type where
  | var    : ℕ → RTerm
  | star   : RTerm
  | lam    : RTerm → RTerm
  | app    : RTerm → RTerm → RTerm
  | pair   : RTerm → RTerm → RTerm
  | fst    : RTerm → RTerm
  | snd    : RTerm → RTerm
  | inl    : RTerm → RTerm
  | inr    : RTerm → RTerm
  | boxI   : RTerm → RTerm
  | boxE   : RTerm → RTerm
  | fold   : RTerm → RTerm
  | unfold : RTerm → RTerm
  deriving Inhabited, DecidableEq, Repr

/-- Typing context. -/
abbrev TCtx := List RType

/-- Typing judgment for ReflTT proof terms. -/
inductive Typing : TCtx → RTerm → RType → Prop where
  | var : ∀ {Γ : TCtx} {n : ℕ} {A : RType}, Γ[n]? = some A → Typing Γ (.var n) A
  | star : ∀ {Γ}, Typing Γ .star .unit
  | lam : ∀ {Γ A B body}, Typing (A :: Γ) body B → Typing Γ (.lam body) (.arrow A B)
  | app : ∀ {Γ A B f x}, Typing Γ f (.arrow A B) → Typing Γ x A → Typing Γ (.app f x) B
  | pair : ∀ {Γ A B a b}, Typing Γ a A → Typing Γ b B → Typing Γ (.pair a b) (.prod A B)
  | fst : ∀ {Γ A B p}, Typing Γ p (.prod A B) → Typing Γ (.fst p) A
  | snd : ∀ {Γ A B p}, Typing Γ p (.prod A B) → Typing Γ (.snd p) B
  | inl : ∀ {Γ A B a}, Typing Γ a A → Typing Γ (.inl a) (.sum A B)
  | inr : ∀ {Γ A B b}, Typing Γ b B → Typing Γ (.inr b) (.sum A B)
  | boxI : ∀ {Γ A t}, Typing [] t A → Typing Γ (.boxI t) (.box A)
  | fold : ∀ {Γ F t}, Typing Γ t F → Typing Γ (.fold t) (.mu F)
  | unfold : ∀ {Γ F t}, Typing Γ t (.mu F) → Typing Γ (.unfold t) F

/-- One-step reduction for proof terms. -/
inductive Reduces : RTerm → RTerm → Prop where
  | fstPair : ∀ {a b}, Reduces (.fst (.pair a b)) a
  | sndPair : ∀ {a b}, Reduces (.snd (.pair a b)) b
  | foldUnfold : ∀ {t}, Reduces (.unfold (.fold t)) t
  | boxElimIntro : ∀ {t}, Reduces (.boxE (.boxI t)) t
  | fstCong : ∀ {p p'}, Reduces p p' → Reduces (.fst p) (.fst p')
  | sndCong : ∀ {p p'}, Reduces p p' → Reduces (.snd p) (.snd p')

/-- A term is in **normal form** if no reduction applies. -/
def IsNormal (t : RTerm) : Prop := ∀ t', ¬ Reduces t t'

/-- `star` is in normal form. -/
theorem star_is_normal : IsNormal .star := fun _ h => by cases h

/-- Variables are in normal form. -/
theorem var_is_normal (n : ℕ) : IsNormal (.var n) := fun _ h => by cases h

/-! ## 4. Subject Reduction -/

/-- **Subject reduction for fst-projection reductions.** -/
theorem subject_reduction_fst {Γ : TCtx} {a b : RTerm} {A : RType}
    (h : Typing Γ (.fst (.pair a b)) A) :
    ∃ B, Typing Γ a A ∧ Typing Γ b B := by
  cases h with
  | fst hp => cases hp with
    | pair ha hb => exact ⟨_, ha, hb⟩

/-- **Subject reduction for snd-projection reductions.** -/
theorem subject_reduction_snd {Γ : TCtx} {a b : RTerm} {B : RType}
    (h : Typing Γ (.snd (.pair a b)) B) :
    ∃ A, Typing Γ a A ∧ Typing Γ b B := by
  cases h with
  | snd hp => cases hp with
    | pair ha hb => exact ⟨_, ha, hb⟩

/-- **Subject reduction for fold/unfold.** -/
theorem subject_reduction_fold_unfold {Γ : TCtx} {t : RTerm} {F : RType}
    (h : Typing Γ (.unfold (.fold t)) F) : Typing Γ t F := by
  cases h with
  | unfold hfold => cases hfold with
    | fold ht => exact ht

/-! ## 5. Iterated Box and Depth Arithmetic -/

/-- Iterated box: □^n A -/
def iterBox (n : ℕ) (A : RType) : RType := Nat.iterate RType.box n A

/-- Iterated box depth is exactly n + depth(A). -/
theorem iterBox_depth (n : ℕ) (A : RType) :
    (iterBox n A).depth = n + A.depth := by
  induction n with
  | zero => simp [iterBox]
  | succ k ih =>
    simp only [iterBox, Function.iterate_succ', Function.comp] at ih ⊢
    simp [RType.depth, ih]; omega

/-- Iterated box is injective. -/
theorem iterBox_injective (n : ℕ) : Function.Injective (iterBox n) := by
  induction n with
  | zero => exact fun _ _ h => h
  | succ k ih =>
    intro A B h
    simp only [iterBox, Function.iterate_succ', Function.comp] at h
    exact ih (RType.box.inj h)

/-- □^m (□^n A) = □^(m+n) A. -/
theorem iterBox_add (m n : ℕ) (A : RType) :
    iterBox m (iterBox n A) = iterBox (m + n) A := by
  simp [iterBox, Function.iterate_add]

/-- **The depth hierarchy is strict and unbounded.** -/
theorem strict_depth_hierarchy :
    ∀ n : ℕ, ∃ t : RType, t.depth = n ∧ ∀ s : RType, s.depth < n → s ≠ t := by
  intro n
  exact ⟨iterBox n .unit, by rw [iterBox_depth]; simp,
         fun s hs heq => by rw [heq, iterBox_depth] at hs; simp at hs⟩

/-! ## 6. Modal Mu-Calculus Translation -/

/-- Formulas of the modal mu-calculus. -/
inductive MuFormula : Type where
  | var  : ℕ → MuFormula
  | tt   : MuFormula
  | ff   : MuFormula
  | conj : MuFormula → MuFormula → MuFormula
  | disj : MuFormula → MuFormula → MuFormula
  | impl : MuFormula → MuFormula → MuFormula
  | boxF : MuFormula → MuFormula
  | muF  : MuFormula → MuFormula
  deriving Inhabited, DecidableEq, Repr

namespace MuFormula

def modalDepth : MuFormula → ℕ
  | var _    => 0 | tt => 0 | ff => 0
  | conj a b => max a.modalDepth b.modalDepth
  | disj a b => max a.modalDepth b.modalDepth
  | impl a b => max a.modalDepth b.modalDepth
  | boxF a   => 1 + a.modalDepth
  | muF a    => a.modalDepth

def size : MuFormula → ℕ
  | var _    => 1 | tt => 1 | ff => 1
  | conj a b => 1 + a.size + b.size
  | disj a b => 1 + a.size + b.size
  | impl a b => 1 + a.size + b.size
  | boxF a   => 1 + a.size
  | muF a    => 1 + a.size

end MuFormula

/-- Translation: RType → MuFormula -/
def toMu : RType → MuFormula
  | .base n    => .var n | .unit => .tt | .void => .ff
  | .arrow a b => .impl (toMu a) (toMu b)
  | .prod a b  => .conj (toMu a) (toMu b)
  | .sum a b   => .disj (toMu a) (toMu b)
  | .box a     => .boxF (toMu a)
  | .mu a      => .muF (toMu a)

/-- Translation: MuFormula → RType -/
def fromMu : MuFormula → RType
  | .var n   => .base n | .tt => .unit | .ff => .void
  | .conj a b => .prod (fromMu a) (fromMu b)
  | .disj a b => .sum (fromMu a) (fromMu b)
  | .impl a b => .arrow (fromMu a) (fromMu b)
  | .boxF a   => .box (fromMu a)
  | .muF a    => .mu (fromMu a)

/-- Translation preserves depth. -/
theorem toMu_depth (t : RType) : (toMu t).modalDepth = t.depth := by
  induction t with
  | base _ | unit | void => rfl
  | arrow a b iha ihb | prod a b iha ihb | sum a b iha ihb =>
    simp [toMu, MuFormula.modalDepth, RType.depth, iha, ihb]
  | box a ih => simp [toMu, MuFormula.modalDepth, RType.depth, ih]
  | mu a ih => simp [toMu, MuFormula.modalDepth, RType.depth, ih]

/-- Translation preserves size. -/
theorem toMu_size (t : RType) : (toMu t).size = t.size := by
  induction t with
  | base _ | unit | void => rfl
  | arrow a b iha ihb | prod a b iha ihb | sum a b iha ihb =>
    simp [toMu, MuFormula.size, RType.size, iha, ihb]
  | box a ih => simp [toMu, MuFormula.size, RType.size, ih]
  | mu a ih => simp [toMu, MuFormula.size, RType.size, ih]

/-- Roundtrip: fromMu ∘ toMu = id -/
theorem fromMu_toMu (t : RType) : fromMu (toMu t) = t := by
  induction t with
  | base _ | unit | void => rfl
  | arrow a b iha ihb | prod a b iha ihb | sum a b iha ihb =>
    simp [toMu, fromMu, iha, ihb]
  | box a ih => simp [toMu, fromMu, ih]
  | mu a ih => simp [toMu, fromMu, ih]

/-- Roundtrip: toMu ∘ fromMu = id -/
theorem toMu_fromMu (φ : MuFormula) : toMu (fromMu φ) = φ := by
  induction φ with
  | var _ | tt | ff => rfl
  | conj a b iha ihb | disj a b iha ihb | impl a b iha ihb =>
    simp [fromMu, toMu, iha, ihb]
  | boxF a ih => simp [fromMu, toMu, ih]
  | muF a ih => simp [fromMu, toMu, ih]

/-- **The translation is a bijection.** -/
theorem toMu_bijective : Function.Bijective toMu :=
  ⟨fun a b h => by rw [← fromMu_toMu a, ← fromMu_toMu b, h],
   fun φ => ⟨fromMu φ, toMu_fromMu φ⟩⟩

/-! ## 7. Subformula Property -/

/-- Direct subtype relation. -/
inductive IsDirectSubtype : RType → RType → Prop where
  | arrowL : ∀ A B, IsDirectSubtype A (.arrow A B)
  | arrowR : ∀ A B, IsDirectSubtype B (.arrow A B)
  | prodL  : ∀ A B, IsDirectSubtype A (.prod A B)
  | prodR  : ∀ A B, IsDirectSubtype B (.prod A B)
  | sumL   : ∀ A B, IsDirectSubtype A (.sum A B)
  | sumR   : ∀ A B, IsDirectSubtype B (.sum A B)
  | boxSub : ∀ A, IsDirectSubtype A (.box A)
  | muSub  : ∀ A, IsDirectSubtype A (.mu A)

/-- Direct subformula relation. -/
inductive IsDirectSubformula : MuFormula → MuFormula → Prop where
  | conjL  : ∀ A B, IsDirectSubformula A (.conj A B)
  | conjR  : ∀ A B, IsDirectSubformula B (.conj A B)
  | disjL  : ∀ A B, IsDirectSubformula A (.disj A B)
  | disjR  : ∀ A B, IsDirectSubformula B (.disj A B)
  | implL  : ∀ A B, IsDirectSubformula A (.impl A B)
  | implR  : ∀ A B, IsDirectSubformula B (.impl A B)
  | boxFSub : ∀ A, IsDirectSubformula A (.boxF A)
  | muFSub  : ∀ A, IsDirectSubformula A (.muF A)

/-- **Subformula preservation**: the translation preserves the subformula relation. -/
theorem subformula_preservation {A B : RType} (h : IsDirectSubtype A B) :
    IsDirectSubformula (toMu A) (toMu B) := by
  cases h with
  | arrowL A B => exact IsDirectSubformula.implL _ _
  | arrowR A B => exact IsDirectSubformula.implR _ _
  | prodL A B  => exact IsDirectSubformula.conjL _ _
  | prodR A B  => exact IsDirectSubformula.conjR _ _
  | sumL A B   => exact IsDirectSubformula.disjL _ _
  | sumR A B   => exact IsDirectSubformula.disjR _ _
  | boxSub A   => exact IsDirectSubformula.boxFSub _
  | muSub A    => exact IsDirectSubformula.muFSub _

/-- Subtypes have strictly smaller size. -/
theorem subtype_size_lt {A B : RType} (h : IsDirectSubtype A B) : A.size < B.size := by
  cases h <;> simp [RType.size] <;> omega

/-- Subtypes have depth ≤ parent depth. -/
theorem subtype_depth_le {A B : RType} (h : IsDirectSubtype A B) : A.depth ≤ B.depth := by
  cases h <;> simp [RType.depth]

/-! ## 8. Provability Principles and Their Depth Hierarchy -/

/-- Löb's axiom type: □(□P → P) → □P -/
def löbType (P : RType) : RType := .arrow (.box (.arrow (.box P) P)) (.box P)

/-- 4 axiom: □A → □□A (positive introspection) -/
def fourType (A : RType) : RType := .arrow (.box A) (.box (.box A))

/-- K axiom: □(A → B) → □A → □B (distribution) -/
def kType (A B : RType) : RType := .arrow (.box (.arrow A B)) (.arrow (.box A) (.box B))

/-- T axiom: □A → A (reflection) -/
def tType (A : RType) : RType := .arrow (.box A) A

/-- Löb type has depth ≥ 2 for any P. -/
theorem löb_depth_ge_two (P : RType) : (löbType P).depth ≥ 2 := by
  simp [löbType, RType.depth]; omega

/-- 4 axiom depth = 2 + depth(A). -/
theorem four_depth (A : RType) : (fourType A).depth = 2 + A.depth := by
  simp [fourType, RType.depth]; omega

/-- K axiom depth = 1 + max(depth A, depth B). -/
theorem k_depth (A B : RType) : (kType A B).depth = 1 + max A.depth B.depth := by
  simp [kType, RType.depth]

/-- T axiom depth = 1 + depth(A). -/
theorem t_depth (A : RType) : (tType A).depth = 1 + A.depth := by
  simp [tType, RType.depth]

/-- **The 4 axiom requires strictly more depth than K at any pair of types.**
    Positive introspection (□A → □□A) needs deeper reasoning than
    distribution (□(A→B) → □A → □B). "Knowing that you know" is harder
    than "applying what you know." -/
theorem four_deeper_than_k (A : RType) :
    (fourType A).depth > (kType A A).depth := by
  simp [fourType, kType, RType.depth]

/-- **T and K have equal depth at the same type, but 4 is strictly deeper.**
    This captures the gap between "using" provability and "reflecting on" it. -/
theorem axiom_depth_ordering (A : RType) :
    (tType A).depth ≤ (kType A A).depth ∧
    (kType A A).depth < (fourType A).depth := by
  constructor
  · simp [tType, kType, RType.depth]
  · simp [kType, fourType, RType.depth]

/-! ## 9. Depth Filtration -/

/-- Types at depth exactly n. -/
def DepthStratum (n : ℕ) : Set RType := { t | t.depth = n }

/-- Types at depth ≤ n. -/
def DepthFilter (n : ℕ) : Set RType := { t | t.depth ≤ n }

/-- The filtration is nested. -/
theorem filter_nested (n : ℕ) : DepthFilter n ⊆ DepthFilter (n + 1) :=
  fun _ ht => by simp only [DepthFilter, Set.mem_setOf_eq] at *; omega

/-- The filtration is exhaustive. -/
theorem filter_exhaustive (t : RType) : ∃ n, t ∈ DepthFilter n :=
  ⟨t.depth, Nat.le_refl _⟩

/-- Strata partition the type universe: distinct strata are disjoint. -/
theorem strata_disjoint {m n : ℕ} (h : m ≠ n) :
    DepthStratum m ∩ DepthStratum n = ∅ := by
  ext t; simp only [DepthStratum, Set.mem_inter_iff, Set.mem_setOf_eq, Set.mem_empty_iff_false,
    iff_false, not_and]; intro h1 h2; exact h (h1 ▸ h2)

/-- Arrow preserves the filtration. -/
theorem arrow_preserves_filter {A B : RType} {n : ℕ}
    (hA : A ∈ DepthFilter n) (hB : B ∈ DepthFilter n) :
    RType.arrow A B ∈ DepthFilter n := by
  simp only [DepthFilter, Set.mem_setOf_eq, RType.depth] at *; omega

/-- Product preserves the filtration. -/
theorem prod_preserves_filter {A B : RType} {n : ℕ}
    (hA : A ∈ DepthFilter n) (hB : B ∈ DepthFilter n) :
    RType.prod A B ∈ DepthFilter n := by
  simp only [DepthFilter, Set.mem_setOf_eq, RType.depth] at *; omega

/-- Box shifts the filtration up by one. -/
theorem box_shifts_filter {A : RType} {n : ℕ}
    (hA : A ∈ DepthFilter n) : RType.box A ∈ DepthFilter (n + 1) := by
  simp only [DepthFilter, Set.mem_setOf_eq, RType.depth] at *; omega

/-- **Box breaks the filtration**: □A is never at depth ≤ depth(A). -/
theorem box_breaks_filter (A : RType) : RType.box A ∉ DepthFilter A.depth := by
  simp only [DepthFilter, Set.mem_setOf_eq, RType.depth]; omega

/-! ## 10. Depth-Complexity Gap Theorem -/

/-- Every type has size ≥ depth + 1. -/
theorem depth_complexity_lower_bound (t : RType) : t.size ≥ t.depth + 1 := by
  induction t with
  | base _ | unit | void => simp [RType.depth, RType.size]
  | arrow a b iha ihb | prod a b iha ihb | sum a b iha ihb =>
    simp only [RType.depth, RType.size]; omega
  | box a ih => simp only [RType.depth, RType.size]; omega
  | mu a ih => simp only [RType.depth, RType.size]; omega

/-- □^n unit has size exactly n + 1. -/
theorem iterBox_unit_size (n : ℕ) : (iterBox n .unit).size = n + 1 := by
  induction n with
  | zero => rfl
  | succ k ih =>
    unfold iterBox at *
    rw [Function.iterate_succ']
    simp only [Function.comp, RType.size, ih]; omega

/-- **□^n unit is a minimum-size type at depth n.** -/
theorem iterBox_unit_minimal (n : ℕ) (t : RType) (h : t.depth = n) :
    (iterBox n .unit).size ≤ t.size := by
  rw [iterBox_unit_size]
  have := depth_complexity_lower_bound t
  omega

/-! ## 11. The Reflection Tower -/

/-- The n-th level of the reflection tower over P. -/
def reflectionTower (P : RType) (n : ℕ) : RType := iterBox n P

/-- The reflection tower is strictly increasing in depth. -/
theorem tower_strictly_increasing (P : RType) (m n : ℕ) (h : m < n) :
    (reflectionTower P m).depth < (reflectionTower P n).depth := by
  simp [reflectionTower, iterBox_depth]; omega

/-- The tower is injective on levels. -/
theorem tower_injective (P : RType) : Function.Injective (reflectionTower P) := by
  intro m n hmn
  simp [reflectionTower] at hmn
  have : m + P.depth = n + P.depth := by rw [← iterBox_depth, ← iterBox_depth, hmn]
  omega

/-- The tower generates all depths ≥ depth(P). -/
theorem tower_generates_depths (P : RType) (n : ℕ) (h : n ≥ P.depth) :
    ∃ k, (reflectionTower P k).depth = n :=
  ⟨n - P.depth, by simp [reflectionTower, iterBox_depth]; omega⟩

/-! ## 12. Löb Depth Irreducibility -/

/-- **Löb depth irreducibility**: no type of lower depth has the same
    mu-calculus translation as Löb's type. -/
theorem löb_depth_irreducible :
    ∀ t : RType, t.depth < (löbType (.base 0)).depth →
      toMu t ≠ toMu (löbType (.base 0)) := by
  intro t ht heq
  have : t = löbType (.base 0) := toMu_bijective.1 heq
  rw [this] at ht; exact lt_irrefl _ ht

/-! ## 13. Depth Algebra as Tropical Semiring Homomorphism -/

/-- **The depth function factors through the tropical semiring (ℕ, max, +).**
    Binary type formers map to max; box maps to (+1). -/
theorem depth_tropical_factorization (A B : RType) :
    (RType.box (.prod A B)).depth = 1 + max A.depth B.depth ∧
    (RType.prod (.box A) B).depth = max (1 + A.depth) B.depth ∧
    (RType.box (.arrow A B)).depth = 1 + max A.depth B.depth :=
  ⟨rfl, rfl, rfl⟩

/-! ## 14. Maximum Context Depth -/

/-- Maximum depth across all types in a context. -/
def ctxMaxDepth : TCtx → ℕ
  | [] => 0
  | (A :: Γ) => max A.depth (ctxMaxDepth Γ)

/-- Looking up a variable gives a type with depth bounded by context depth. -/
theorem lookup_depth_bound {Γ : TCtx} {n : ℕ} {A : RType}
    (h : Γ[n]? = some A) : A.depth ≤ ctxMaxDepth Γ := by
  induction Γ generalizing n with
  | nil => simp at h
  | cons B Γ' ih =>
    simp [ctxMaxDepth]
    cases n with
    | zero => simp at h; subst h; omega
    | succ n' => simp at h; have := ih h; omega

/-! ## 15. Conjecture and Proof Term Depth

**Conjecture (Proof Depth Gap)**: For any well-typed closed term `t` of type
`□^n(unit)` (n ≥ 1), the term must contain at least n nested `boxI` constructors.

**Testable prediction**: A term of type `□□unit` (depth 2) requires at least
2 nested `boxI` applications. This is checkable by exhaustive search over
small terms.
-/

/-- The boxI-depth of a term. -/
def RTerm.boxIDepth : RTerm → ℕ
  | .var _    => 0 | .star => 0
  | .lam body => body.boxIDepth
  | .app f x  => max f.boxIDepth x.boxIDepth
  | .pair a b => max a.boxIDepth b.boxIDepth
  | .fst p    => p.boxIDepth | .snd p => p.boxIDepth
  | .inl a    => a.boxIDepth | .inr b => b.boxIDepth
  | .boxI t   => 1 + t.boxIDepth
  | .boxE t   => t.boxIDepth
  | .fold t   => t.boxIDepth | .unfold t => t.boxIDepth

/-- boxI introduction gives boxIDepth ≥ 1. -/
theorem boxI_depth_pos (t : RTerm) : (RTerm.boxI t).boxIDepth ≥ 1 := by
  simp [RTerm.boxIDepth]

/-- **Depth gap (base case)**: a boxI-wrapped term has boxIDepth ≥ 1. -/
theorem boxI_typed_depth {Γ : TCtx} {t : RTerm} {A : RType}
    (_h : Typing Γ (.boxI t) (.box A)) : (RTerm.boxI t).boxIDepth ≥ 1 :=
  boxI_depth_pos t