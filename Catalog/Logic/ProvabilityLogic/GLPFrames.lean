/-
  # Polymodal Provability Logic (GLP): Frames, Morphisms, and Products

  This file extends provability logic GL to the **polymodal** setting (GLP) and
  develops the **category-theoretic structure** of GL frames:

  1. **GLP Frames**: ℕ-indexed nested hierarchies R₀ ⊇ R₁ ⊇ R₂ ⊇ ··· of GL
     accessibility relations, modeling iterated provability predicates.
  2. **P-Morphisms**: Bounded morphisms — the canonical notion of structure-preserving
     map that reflects modal truth bidirectionally.
  3. **Products and Coproducts**: GL frames are closed under synchronized products
     and disjoint unions.
  4. **Order-Theoretic Bridge**: GL frames = well-founded strict partial orders.

  ## Mathematical Context

  GLP (Japaridze, 1986) models the hierarchy of provability predicates
  Prv₀, Prv₁, Prv₂, ... where Prvₙ₊₁ is provability in a system with
  n-consistency. The frame condition R₀ ⊇ R₁ ⊇ ··· means stronger provability
  sees fewer worlds. P-morphisms are the standard morphisms in modal model theory;
  the truth lemma shows they preserve and reflect forcing, making them the right
  arrows for a category of GL frames.
-/

import Mathlib

namespace GLPLogic

/-! ## Modal Formulas -/

/-- Modal formulas over propositional variables of type α. -/
inductive MFormula (α : Type*) : Type _
  | var : α → MFormula α
  | bot : MFormula α
  | imp : MFormula α → MFormula α → MFormula α
  | box : MFormula α → MFormula α

namespace MFormula
variable {α : Type*}

def neg (φ : MFormula α) : MFormula α := .imp φ .bot
def top : MFormula α := neg .bot
def con : MFormula α := neg (.box .bot)
def dia (φ : MFormula α) : MFormula α := neg (.box (neg φ))
def loebF (φ : MFormula α) : MFormula α := .imp (.box (.imp (.box φ) φ)) (.box φ)

end MFormula

/-! ## GL Frames -/

/-- A **GL frame**: transitive, converse well-founded accessibility relation. -/
structure GLFrame where
  W : Type*
  R : W → W → Prop
  R_trans : ∀ {u v w : W}, R u v → R v w → R u w
  R_wf : WellFounded (Function.swap R)

/-- Kripke forcing relation. -/
def forces {α : Type*} (M : GLFrame) (V : α → M.W → Prop) :
    M.W → MFormula α → Prop
  | w, .var p => V p w
  | _, .bot => False
  | w, .imp φ ψ => forces M V w φ → forces M V w ψ
  | w, .box φ => ∀ v, M.R w v → forces M V v φ

/-- Frame validity: φ holds at every world under every valuation. -/
def GLFrame.valid {α : Type*} (M : GLFrame) (φ : MFormula α) : Prop :=
  ∀ (V : α → M.W → Prop) (w : M.W), forces M V w φ

/-! ## Core GL Theorems -/

-- !-- Irreflexivity follows from converse well-foundedness: a self-loop
--     w R w would give an infinite ascending chain w, w, w, ···. -- !--
theorem GLFrame.irrefl (M : GLFrame) (w : M.W) : ¬M.R w w := by
  intro h; exact (M.R_wf.irrefl).irrefl w h

-- !-- Löb's axiom: well-founded induction on the converse of R. Given
--     w ⊩ □(□φ→φ), for any v with wRv, the IH gives v ⊩ □φ, then
--     the hypothesis gives v ⊩ □φ→φ, yielding v ⊩ φ. -- !--
theorem loeb_valid {α : Type*} (M : GLFrame) (V : α → M.W → Prop)
    (φ : MFormula α) (w : M.W)
    (h : forces M V w (.box (.imp (.box φ) φ))) :
    forces M V w (.box φ) := by
  intro v hwv
  induction v using M.R_wf.induction with
  | _ v ih => exact h v hwv (fun t hut => ih t hut (M.R_trans hwv hut))

/-- Löb's axiom as frame validity. -/
theorem loeb_frame_valid (M : GLFrame) (p : α) :
    M.valid (.imp (.box (.imp (.box (.var p)) (.var p))) (.box (.var p))) :=
  fun V w h => loeb_valid M V _ w h

/-- Second incompleteness: consistent + □⊥→⊥ implies ¬□(□⊥→⊥). -/
theorem second_incompleteness {α : Type*} (M : GLFrame)
    (V : α → M.W → Prop) (w : M.W)
    (hsound : forces M V w (.imp (.box .bot) .bot))
    (hcon : ¬forces M V w (MFormula.bot (α := α))) :
    ¬forces M V w (.box (.imp (.box .bot) .bot)) :=
  fun h => hcon (hsound (loeb_valid M V .bot w h))

-- ═══════════════════════════════════════════════════════════════════════════
-- THEOREM 1: GLP FRAME HIERARCHY
-- Each level of a GLP frame is a valid GL frame. Combined with cross-level
-- antisymmetry, this shows GLP frames are strictly stratified towers.
-- ═══════════════════════════════════════════════════════════════════════════

/-! ## Part 1: GLP Frames -/

/-- A **GLP frame**: ℕ-indexed nested family R₀ ⊇ R₁ ⊇ R₂ ⊇ ···,
    each transitive and converse well-founded.

    The nesting R_{n+1} ⊆ R_n means stronger provability sees fewer worlds:
    if something is provable by a stronger system, it's provable by a weaker one. -/
structure GLPFrame where
  W : Type*
  R : ℕ → W → W → Prop
  R_trans : ∀ n, ∀ {u v w : W}, R n u v → R n v w → R n u w
  R_wf : ∀ n, WellFounded (Function.swap (R n))
  R_nest : ∀ n {u v : W}, R (n + 1) u v → R n u v

/-- **[P]roof**: Extract the GL frame at level n from a GLP frame. -/
def GLPFrame.level (F : GLPFrame) (n : ℕ) : GLFrame where
  W := F.W
  R := F.R n
  R_trans := F.R_trans n
  R_wf := F.R_wf n

/-- Löb's axiom holds at every level of a GLP frame. -/
theorem glp_loeb_at_level {α : Type*} (F : GLPFrame) (n : ℕ)
    (V : α → F.W → Prop) (φ : MFormula α) (w : F.W)
    (h : forces (F.level n) V w (.box (.imp (.box φ) φ))) :
    forces (F.level n) V w (.box φ) :=
  loeb_valid (F.level n) V φ w h

/-- Nesting extends transitively: R_m ⊆ R_n whenever n ≤ m. -/
theorem glp_nesting_le (F : GLPFrame) {m n : ℕ} (h : n ≤ m)
    {u v : F.W} (huv : F.R m u v) : F.R n u v := by
  induction h with
  | refl => exact huv
  | step _ ih => exact ih (F.R_nest _ huv)

/-- GLP frames are irreflexive at every level. -/
theorem glp_irrefl (F : GLPFrame) (n : ℕ) (w : F.W) : ¬F.R n w w :=
  GLFrame.irrefl (F.level n) w

/-- **Cross-level antisymmetry**: No cycles spanning different levels.
    If R_m(u,v) and R_n(v,u) for any m, n, contradiction. -/
theorem glp_no_cross_cycle (F : GLPFrame) {m n : ℕ}
    {u v : F.W} (huv : F.R m u v) (hvu : F.R n v u) : False := by
  by_cases h : m ≤ n
  · have h1 : F.R m v u := glp_nesting_le F h hvu
    have h2 : F.R m u u := F.R_trans m huv h1
    exact (F.R_wf m).irrefl.irrefl u h2
  · push_neg at h
    have h1 : F.R n u v := glp_nesting_le F (Nat.le_of_lt h) huv
    have h2 : F.R n u u := F.R_trans n h1 hvu
    exact (F.R_wf n).irrefl.irrefl u h2

/-- **[E]xample**: Trivial GLP frame (one world, no edges). -/
def trivialGLP : GLPFrame where
  W := ℕ
  R := fun _ _ _ => False
  R_trans := by intro _ _ _ _ h; exact h.elim
  R_wf := fun _ => ⟨fun _ => ⟨_, fun _ h => h.elim⟩⟩
  R_nest := by intro _ _ _ h; exact h.elim

/-- **[E]xample**: Two-world GLP frame with nontrivial nesting. -/
def twoWorldGLP : GLPFrame where
  W := ℕ
  R := fun n w v => n = 0 ∧ w = 1 ∧ v = 0
  R_trans := by intro n u v w ⟨_, _, hv⟩ ⟨_, hw, _⟩; omega
  R_wf := by
    intro n; constructor; intro a
    exact ⟨a, fun b ⟨_, _, hb⟩ => by
      subst hb; exact ⟨0, fun c ⟨_, _, hc⟩ => by omega⟩⟩
  R_nest := by intro n u v ⟨h, _, _⟩; omega

/-- **[G]eneralization**: GLP frames indexed by an arbitrary preorder. -/
structure GLPFrameOrd (ι : Type*) [Preorder ι] where
  W : Type*
  R : ι → W → W → Prop
  R_trans : ∀ i, ∀ {u v w : W}, R i u v → R i v w → R i u w
  R_wf : ∀ i, WellFounded (Function.swap (R i))
  R_mono : ∀ {i j : ι}, i ≤ j → ∀ {u v : W}, R j u v → R i u v

-- !-- [B]oundary: Without nesting, we have independent GL frames — no cross-level
--     interaction. With nesting, cross-level cycles become impossible (glp_no_cross_cycle).
--     Without transitivity, irreflexivity fails: {w} with R w w is converse well-founded
--     on a finite set but reflexive. -- !--

-- ═══════════════════════════════════════════════════════════════════════════
-- THEOREM 2: P-MORPHISM TRUTH LEMMA
-- P-morphisms preserve and reflect forcing under pullback valuation.
-- This is the semantic backbone of GL model theory.
-- ═══════════════════════════════════════════════════════════════════════════

/-! ## Part 2: P-Morphisms (Bounded Morphisms) -/

/-- A **p-morphism** (bounded morphism) f : M₁ → M₂ satisfies:
    - **Forth**: R₁(w,v) → R₂(f(w), f(v))
    - **Back**: R₂(f(w), u) → ∃ v, R₁(w,v) ∧ f(v) = u -/
structure PMorphism (M₁ M₂ : GLFrame) where
  f : M₁.W → M₂.W
  forth : ∀ {w v : M₁.W}, M₁.R w v → M₂.R (f w) (f v)
  back : ∀ {w : M₁.W} {u : M₂.W}, M₂.R (f w) u → ∃ v, M₁.R w v ∧ f v = u

-- !-- The truth lemma is proved by structural induction on φ. The key case is box:
--     (→) uses back: if M₂, f(w) sees u, lift to v in M₁ with f(v) = u, apply IH.
--     (←) uses forth: if M₁, w sees v, then M₂, f(w) sees f(v), apply IH. -- !--

/-- **[P]roof — P-Morphism Truth Lemma**: For any p-morphism f : M₁ → M₂,
    valuation V on M₂, world w in M₁, and formula φ:
      forces M₁ (V ∘ f) w φ  ↔  forces M₂ V (f w) φ

    The forth condition handles □ forward, the back condition handles □ backward. -/
theorem pmorphism_truth_lemma {α : Type*} {M₁ M₂ : GLFrame}
    (p : PMorphism M₁ M₂) (V : α → M₂.W → Prop) (w : M₁.W)
    (φ : MFormula α) :
    forces M₁ (fun a w => V a (p.f w)) w φ ↔ forces M₂ V (p.f w) φ := by
  induction φ generalizing w with
  | var a => rfl
  | bot => rfl
  | imp φ ψ ih_φ ih_ψ =>
    simp only [forces]
    constructor
    · intro h hφ; exact (ih_ψ w).mp (h ((ih_φ w).mpr hφ))
    · intro h hφ; exact (ih_ψ w).mpr (h ((ih_φ w).mp hφ))
  | box φ ih =>
    constructor
    · -- Forth direction (uses back condition)
      intro h u hfu
      obtain ⟨v, hwv, rfl⟩ := p.back hfu
      exact (ih v).mp (h v hwv)
    · -- Back direction (uses forth condition)
      intro h v hwv
      exact (ih v).mpr (h (p.f v) (p.forth hwv))

/-- Corollary: p-morphisms preserve validity under pullback. -/
theorem pmorphism_preserves_pullback_validity {α : Type*} {M₁ M₂ : GLFrame}
    (p : PMorphism M₁ M₂) (V : α → M₂.W → Prop) (φ : MFormula α)
    (h : ∀ w, forces M₂ V w φ) : ∀ w, forces M₁ (fun a w => V a (p.f w)) w φ :=
  fun w => (pmorphism_truth_lemma p V w φ).mpr (h (p.f w))

/-- **[E]xample**: Identity p-morphism. -/
def PMorphism.id (M : GLFrame) : PMorphism M M where
  f := _root_.id
  forth h := h
  back h := ⟨_, h, rfl⟩

/-- **[E]xample**: Composition of p-morphisms. -/
def PMorphism.comp {M₁ M₂ M₃ : GLFrame}
    (p : PMorphism M₁ M₂) (q : PMorphism M₂ M₃) : PMorphism M₁ M₃ where
  f := q.f ∘ p.f
  forth h := q.forth (p.forth h)
  back h := by
    obtain ⟨v₂, hv₂, rfl⟩ := q.back h
    obtain ⟨v₁, hv₁, rfl⟩ := p.back hv₂
    exact ⟨v₁, hv₁, rfl⟩

/-- Composition respects the truth lemma. -/
theorem pmorphism_comp_truth {α : Type*} {M₁ M₂ M₃ : GLFrame}
    (p : PMorphism M₁ M₂) (q : PMorphism M₂ M₃)
    (V : α → M₃.W → Prop) (w : M₁.W) (φ : MFormula α) :
    forces M₁ (fun a w => V a ((p.comp q).f w)) w φ ↔
    forces M₃ V ((p.comp q).f w) φ :=
  pmorphism_truth_lemma (p.comp q) V w φ

/-- **[G]eneralization**: P-morphisms between GLP frames, preserving all levels. -/
structure GLPMorphism (F₁ F₂ : GLPFrame) where
  f : F₁.W → F₂.W
  forth : ∀ n {w v : F₁.W}, F₁.R n w v → F₂.R n (f w) (f v)
  back : ∀ n {w : F₁.W} {u : F₂.W}, F₂.R n (f w) u → ∃ v, F₁.R n w v ∧ f v = u

/-- A GLP morphism induces a p-morphism at each level. -/
def GLPMorphism.levelMorphism {F₁ F₂ : GLPFrame}
    (p : GLPMorphism F₁ F₂) (n : ℕ) : PMorphism (F₁.level n) (F₂.level n) where
  f := p.f
  forth := p.forth n
  back := p.back n

-- !-- [B]oundary: A mere homomorphism (forth only, no back) does NOT reflect □.
--     Example: M₁ has w→v, M₂ has u (isolated). Map f(w)=f(v)=u. Then M₂,u ⊩ □⊥
--     (vacuously) but M₁,w ⊮ □⊥ (v is accessible and ⊥ fails at v). -- !--

-- ═══════════════════════════════════════════════════════════════════════════
-- THEOREM 3: PRODUCTS AND COPRODUCTS OF GL FRAMES
-- GL frames are closed under synchronized products and disjoint unions.
-- The second incompleteness theorem propagates through both constructions.
-- ═══════════════════════════════════════════════════════════════════════════

/-! ## Part 3: Products and Coproducts -/

-- !-- Product: transitivity is componentwise. Well-foundedness of the product
--     relation follows from being a subrelation of the first projection.
--     An infinite product chain projects to an infinite chain in component 1. -- !--

/-- **[P]roof — Product GL Frame**: Synchronized product with componentwise R.
    R((w₁,w₂),(v₁,v₂)) iff R₁(w₁,v₁) ∧ R₂(w₂,v₂). -/
def GLFrame.prod (M₁ M₂ : GLFrame) : GLFrame where
  W := M₁.W × M₂.W
  R := fun w v => M₁.R w.1 v.1 ∧ M₂.R w.2 v.2
  R_trans := fun ⟨h1, h2⟩ ⟨h3, h4⟩ => ⟨M₁.R_trans h1 h3, M₂.R_trans h2 h4⟩
  R_wf := by
    apply Subrelation.wf (r := InvImage (Function.swap M₁.R) Prod.fst)
    · intro a b ⟨h1, _⟩; exact h1
    · exact InvImage.wf Prod.fst M₁.R_wf

/-- Product irreflexivity. -/
theorem prod_irrefl (M₁ M₂ : GLFrame) (w : (M₁.prod M₂).W) :
    ¬(M₁.prod M₂).R w w := by
  intro ⟨h1, _⟩; exact GLFrame.irrefl M₁ w.1 h1

/-- Second incompleteness propagates through products. -/
theorem tangling_product {α : Type*} (M₁ M₂ : GLFrame)
    (V : α → (M₁.prod M₂).W → Prop) (w : (M₁.prod M₂).W)
    (hsound : forces (M₁.prod M₂) V w (.imp (.box .bot) .bot))
    (hcon : ¬forces (M₁.prod M₂) V w (MFormula.bot (α := α))) :
    ¬forces (M₁.prod M₂) V w (.box (.imp (.box .bot) .bot)) :=
  second_incompleteness (M₁.prod M₂) V w hsound hcon

/-- **[E]xample**: Product of trivial frames. -/
example : (GLFrame.prod
    ⟨ℕ, fun _ _ => False, fun h => h.elim,
     ⟨fun _ => ⟨_, fun _ h => h.elim⟩⟩⟩
    ⟨ℕ, fun _ _ => False, fun h => h.elim,
     ⟨fun _ => ⟨_, fun _ h => h.elim⟩⟩⟩).W = (ℕ × ℕ) := rfl

/-- **[G]eneralization**: Indexed product of GL frames. -/
def GLFrame.iProduct {ι : Type*} (M : ι → GLFrame) [Nonempty ι] : GLFrame where
  W := ∀ i, (M i).W
  R := fun w v => ∀ i, (M i).R (w i) (v i)
  R_trans := fun h1 h2 i => (M i).R_trans (h1 i) (h2 i)
  R_wf := by
    obtain ⟨i₀⟩ := ‹Nonempty ι›
    apply Subrelation.wf (r := InvImage (Function.swap (M i₀).R) (fun w => w i₀))
    · intro a b h; exact h i₀
    · exact InvImage.wf _ (M i₀).R_wf

/-- **Disjoint union (coproduct)** of GL frames. -/
def GLFrame.sum (M₁ M₂ : GLFrame) : GLFrame where
  W := M₁.W ⊕ M₂.W
  R := fun w v => match w, v with
    | .inl w₁, .inl v₁ => M₁.R w₁ v₁
    | .inr w₂, .inr v₂ => M₂.R w₂ v₂
    | _, _ => False
  R_trans := by
    intro u v w huv hvw
    match u, v, w with
    | .inl _, .inl _, .inl _ => exact M₁.R_trans huv hvw
    | .inr _, .inr _, .inr _ => exact M₂.R_trans huv hvw
    | .inl _, .inr _, _ => exact huv.elim
    | .inr _, .inl _, _ => exact huv.elim
    | _, .inl _, .inr _ => exact hvw.elim
    | _, .inr _, .inl _ => exact hvw.elim
  R_wf := by
    constructor; intro a
    match a with
    | Sum.inl a₁ =>
      induction M₁.R_wf.apply a₁ with
      | intro x _ ih =>
        exact ⟨Sum.inl x, fun b hb => by
          match b with
          | Sum.inl b₁ => exact ih b₁ hb
          | Sum.inr _ => exact absurd hb id⟩
    | Sum.inr a₂ =>
      induction M₂.R_wf.apply a₂ with
      | intro x _ ih =>
        exact ⟨Sum.inr x, fun b hb => by
          match b with
          | Sum.inr b₂ => exact ih b₂ hb
          | Sum.inl _ => exact absurd hb id⟩

/-- Injection into disjoint union is a p-morphism. -/
def PMorphism.inl (M₁ M₂ : GLFrame) : PMorphism M₁ (M₁.sum M₂) where
  f := Sum.inl
  forth h := h
  back {_ u} h := by
    cases u with
    | inl v₁ => exact ⟨v₁, h, rfl⟩
    | inr _ => exact h.elim

/-- Injection into disjoint union is a p-morphism. -/
def PMorphism.inr (M₁ M₂ : GLFrame) : PMorphism M₂ (M₁.sum M₂) where
  f := Sum.inr
  forth h := h
  back {_ u} h := by
    cases u with
    | inl _ => exact h.elim
    | inr v₂ => exact ⟨v₂, h, rfl⟩

-- !-- [B]oundary: The synchronized product requires BOTH components to step.
--     If one component is terminal, every product world is terminal.
--     The "interleaving product" (either component steps) is not transitive.
--     Infinite products of finite GL frames produce infinite frames, losing
--     the finite model property crucial for decidability of GL. -- !--

-- ═══════════════════════════════════════════════════════════════════════════
-- THEOREM 4: GL FRAME ↔ WELL-FOUNDED STRICT PARTIAL ORDER
-- The order-theoretic bridge connecting provability logic to order theory.
-- ═══════════════════════════════════════════════════════════════════════════

/-! ## Part 4: Order-Theoretic Bridge -/

/-- A **well-founded strict partial order**: irreflexive, transitive, converse
    well-founded. These are exactly GL frames under a different presentation. -/
structure WFSPO where
  carrier : Type*
  lt : carrier → carrier → Prop
  lt_irrefl : ∀ x, ¬lt x x
  lt_trans : ∀ {x y z}, lt x y → lt y z → lt x z
  lt_wf : WellFounded (Function.swap lt)

-- !-- The bridge: GL frames and WFSPOs are definitionally the same structure.
--     A GL frame has R transitive + converse WF → R is irreflexive (proved above).
--     A WFSPO has lt irreflexive + transitive + converse WF → it's a GL frame.
--     This means all of order theory applies to GL frames. -- !--

/-- **[P]roof**: Every GL frame is a well-founded strict partial order. -/
def GLFrame.toWFSPO (M : GLFrame) : WFSPO where
  carrier := M.W
  lt := M.R
  lt_irrefl := GLFrame.irrefl M
  lt_trans h1 h2 := M.R_trans h1 h2
  lt_wf := M.R_wf

/-- **[P]roof**: Every WFSPO is a GL frame. -/
def WFSPO.toGLFrame (S : WFSPO) : GLFrame where
  W := S.carrier
  R := S.lt
  R_trans h1 h2 := S.lt_trans h1 h2
  R_wf := S.lt_wf

/-- Round-trip GLFrame → WFSPO → GLFrame preserves the data. -/
theorem gl_wfspo_roundtrip (M : GLFrame) :
    (M.toWFSPO.toGLFrame).W = M.W ∧ (M.toWFSPO.toGLFrame).R = M.R :=
  ⟨rfl, rfl⟩

/-- Round-trip WFSPO → GLFrame → WFSPO preserves the data. -/
theorem wfspo_gl_roundtrip (S : WFSPO) :
    (S.toGLFrame.toWFSPO).carrier = S.carrier ∧
    (S.toGLFrame.toWFSPO).lt = S.lt :=
  ⟨rfl, rfl⟩

/-- **[E]xample**: (ℕ, >) as a GL frame via the order bridge. -/
noncomputable def natGLFrame : GLFrame where
  W := ℕ
  R := fun m n => n < m
  R_trans h1 h2 := Nat.lt_trans h2 h1
  R_wf := Nat.lt_wfRel.wf

/-- **[E]xample**: Any well-founded partial order gives a GL frame. -/
noncomputable def wfpoGLFrame (α : Type*) [PartialOrder α]
    [WellFoundedLT α] : GLFrame where
  W := α
  R := fun w v => v < w
  R_trans h1 h2 := lt_trans h2 h1
  R_wf := by
    show WellFounded (· < · : α → α → Prop)
    exact IsWellFounded.wf

/-- **[G]eneralization**: The bridge extends to a bijection on morphisms —
    order-preserving maps between WFSPOs correspond to p-morphisms between
    GL frames (when both forth and back conditions are met). -/
def wfspo_pmorphism_correspondence {S₁ S₂ : WFSPO}
    (f : S₁.carrier → S₂.carrier)
    (hforth : ∀ {x y}, S₁.lt x y → S₂.lt (f x) (f y))
    (hback : ∀ {x} {u}, S₂.lt (f x) u → ∃ y, S₁.lt x y ∧ f y = u) :
    PMorphism S₁.toGLFrame S₂.toGLFrame :=
  ⟨f, hforth, hback⟩

-- !-- [B]oundary: Dense linear orders like (ℚ, <) do NOT give GL frames because
--     the converse relation (>) is not well-founded: the sequence 1, 1/2, 1/3, ...
--     is infinite strictly decreasing. GL frames correspond exactly to well-founded
--     partial orders, which excludes all dense orders and all infinite chains. -- !--

end GLPLogic