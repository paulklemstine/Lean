import Mathlib
import Catalog.Shared.Ispythquadruple.IsPythQuadruple
import Catalog.Shared.HigherPythagorean.LorentzCore
import Catalog.Shared.HigherPythagorean.QuadrupleTree

/-!
# The Pythagorean quadruple groupoid

This is the dimension-three analogue of the Berggren groupoid of the catalog
(`Catalog/Pythagorean/BerggrenGroupoid.lean`), together with the structural theorem that is
*not* available in dimension two by those methods: the groupoid acts **transitively** on the
primitive Pythagorean quadruples of the positive cone.

* `moveR`, `moveN`, `moveS12`, `moveS23` : the generating moves (all-ones Lorentz reflection,
  one sign change, two transpositions).  Each is an involution, hence a bijection.
* `QuadMove` / `QuadConnected` : the generated groupoid relation.
* `qLorentz_of_connected`, `qcontent_of_connected` : the Lorentz form and the content are
  groupoid invariants.
* `quadConnected_of_prim` : **transitivity on primitive quadruples** — any two primitive
  Pythagorean quadruples with non-negative space coordinates and positive height are connected.
* `not_connected_of_content_ne` : the invariants are effective — quadruples of different content
  are never connected (e.g. `(1,2,2,3)` and `(2,4,4,6)`).
-/

namespace HigherPythagorean

/-- A quadruple, viewed as a point of the integral Lorentz space of signature `(3,1)`. -/
abbrev Quad := ℤ × ℤ × ℤ × ℤ

/-- The Lorentz form of a quadruple. -/
def qLorentz (p : Quad) : ℤ := p.1 ^ 2 + p.2.1 ^ 2 + p.2.2.1 ^ 2 - p.2.2.2 ^ 2

/-- The content of a quadruple. -/
def qcontent (p : Quad) : ℕ := content p.1 p.2.1 p.2.2.1 p.2.2.2

lemma qLorentz_eq_zero_iff (p : Quad) :
    qLorentz p = 0 ↔ IsPythQuadruple p.1 p.2.1 p.2.2.1 p.2.2.2 := by
  unfold qLorentz IsPythQuadruple
  constructor <;> intro h <;> linarith

/-! ## The generating moves -/

/-- The all-ones Lorentz reflection. -/
def moveR (p : Quad) : Quad :=
  (p.1 - qk p.1 p.2.1 p.2.2.1 p.2.2.2, p.2.1 - qk p.1 p.2.1 p.2.2.1 p.2.2.2,
    p.2.2.1 - qk p.1 p.2.1 p.2.2.1 p.2.2.2, p.2.2.2 - qk p.1 p.2.1 p.2.2.1 p.2.2.2)

/-- The sign change of the first coordinate. -/
def moveN (p : Quad) : Quad := (-p.1, p.2.1, p.2.2.1, p.2.2.2)

/-- The transposition of the first two space coordinates. -/
def moveS12 (p : Quad) : Quad := (p.2.1, p.1, p.2.2.1, p.2.2.2)

/-- The transposition of the last two space coordinates. -/
def moveS23 (p : Quad) : Quad := (p.1, p.2.2.1, p.2.1, p.2.2.2)

theorem moveR_involutive (p : Quad) : moveR (moveR p) = p := by
  obtain ⟨a, b, c, d⟩ := p
  simp only [moveR, qk]
  refine Prod.ext ?_ (Prod.ext ?_ (Prod.ext ?_ ?_)) <;> simp <;> ring

theorem moveN_involutive (p : Quad) : moveN (moveN p) = p := by
  obtain ⟨a, b, c, d⟩ := p; simp [moveN]

theorem moveS12_involutive (p : Quad) : moveS12 (moveS12 p) = p := by
  obtain ⟨a, b, c, d⟩ := p; simp [moveS12]

theorem moveS23_involutive (p : Quad) : moveS23 (moveS23 p) = p := by
  obtain ⟨a, b, c, d⟩ := p; simp [moveS23]

theorem moveR_bijective : Function.Bijective moveR :=
  Function.bijective_iff_has_inverse.2 ⟨moveR, moveR_involutive, moveR_involutive⟩

theorem moveN_bijective : Function.Bijective moveN :=
  Function.bijective_iff_has_inverse.2 ⟨moveN, moveN_involutive, moveN_involutive⟩

theorem moveS12_bijective : Function.Bijective moveS12 :=
  Function.bijective_iff_has_inverse.2 ⟨moveS12, moveS12_involutive, moveS12_involutive⟩

theorem moveS23_bijective : Function.Bijective moveS23 :=
  Function.bijective_iff_has_inverse.2 ⟨moveS23, moveS23_involutive, moveS23_involutive⟩

/-! ## Invariance -/

theorem qLorentz_moveR (p : Quad) : qLorentz (moveR p) = qLorentz p := by
  obtain ⟨a, b, c, d⟩ := p
  simp only [qLorentz, moveR, qk]
  ring

theorem qLorentz_moveN (p : Quad) : qLorentz (moveN p) = qLorentz p := by
  obtain ⟨a, b, c, d⟩ := p; simp only [qLorentz, moveN]; ring

theorem qLorentz_moveS12 (p : Quad) : qLorentz (moveS12 p) = qLorentz p := by
  obtain ⟨a, b, c, d⟩ := p; simp only [qLorentz, moveS12]; ring

theorem qLorentz_moveS23 (p : Quad) : qLorentz (moveS23 p) = qLorentz p := by
  obtain ⟨a, b, c, d⟩ := p; simp only [qLorentz, moveS23]; ring

theorem qcontent_moveR (p : Quad) : qcontent (moveR p) = qcontent p := by
  obtain ⟨a, b, c, d⟩ := p
  simpa [qcontent, moveR] using content_move a b c d

theorem qcontent_moveN (p : Quad) : qcontent (moveN p) = qcontent p := by
  obtain ⟨a, b, c, d⟩ := p
  simpa [qcontent, moveN] using content_neg a b c d

theorem qcontent_moveS12 (p : Quad) : qcontent (moveS12 p) = qcontent p := by
  obtain ⟨a, b, c, d⟩ := p
  simpa [qcontent, moveS12] using content_swap12 a b c d

theorem qcontent_moveS23 (p : Quad) : qcontent (moveS23 p) = qcontent p := by
  obtain ⟨a, b, c, d⟩ := p
  simpa [qcontent, moveS23] using content_swap23 a b c d

/-! ## The groupoid -/

/-- One generating move of the quadruple groupoid. -/
inductive QuadMove : Quad → Quad → Prop
  | r (p : Quad) : QuadMove p (moveR p)
  | n (p : Quad) : QuadMove p (moveN p)
  | s12 (p : Quad) : QuadMove p (moveS12 p)
  | s23 (p : Quad) : QuadMove p (moveS23 p)

/-- Two quadruples are connected when one is carried to the other by a finite sequence of
generating moves and their inverses: the morphism relation of the generated groupoid. -/
def QuadConnected : Quad → Quad → Prop := Relation.EqvGen QuadMove

theorem quadConnected_refl (p : Quad) : QuadConnected p p := Relation.EqvGen.refl p

theorem quadConnected_symm {p q : Quad} (h : QuadConnected p q) : QuadConnected q p :=
  Relation.EqvGen.symm _ _ h

theorem quadConnected_trans {p q r : Quad} (h₁ : QuadConnected p q) (h₂ : QuadConnected q r) :
    QuadConnected p r := Relation.EqvGen.trans _ _ _ h₁ h₂

theorem quadConnected_equivalence : Equivalence QuadConnected :=
  ⟨quadConnected_refl, fun h => quadConnected_symm h, fun h₁ h₂ => quadConnected_trans h₁ h₂⟩

theorem qLorentz_of_quadMove {p q : Quad} (h : QuadMove p q) : qLorentz q = qLorentz p := by
  cases h with
  | r => exact qLorentz_moveR p
  | n => exact qLorentz_moveN p
  | s12 => exact qLorentz_moveS12 p
  | s23 => exact qLorentz_moveS23 p

theorem qcontent_of_quadMove {p q : Quad} (h : QuadMove p q) : qcontent q = qcontent p := by
  cases h with
  | r => exact qcontent_moveR p
  | n => exact qcontent_moveN p
  | s12 => exact qcontent_moveS12 p
  | s23 => exact qcontent_moveS23 p

/-- **The Lorentz form is a groupoid invariant.** -/
theorem qLorentz_of_connected {p q : Quad} (h : QuadConnected p q) : qLorentz q = qLorentz p := by
  induction h with
  | rel x y hxy => exact qLorentz_of_quadMove hxy
  | refl x => rfl
  | symm x y _ ih => exact ih.symm
  | trans x y z _ _ ih₁ ih₂ => exact ih₂.trans ih₁

/-- **The content is a groupoid invariant.** -/
theorem qcontent_of_connected {p q : Quad} (h : QuadConnected p q) : qcontent q = qcontent p := by
  induction h with
  | rel x y hxy => exact qcontent_of_quadMove hxy
  | refl x => rfl
  | symm x y _ ih => exact ih.symm
  | trans x y z _ _ ih₁ ih₂ => exact ih₂.trans ih₁

/-- The groupoid acts on the null cone. -/
theorem isPythQuadruple_of_connected {p q : Quad} (h : QuadConnected p q)
    (hp : IsPythQuadruple p.1 p.2.1 p.2.2.1 p.2.2.2) :
    IsPythQuadruple q.1 q.2.1 q.2.2.1 q.2.2.2 := by
  rw [← qLorentz_eq_zero_iff] at hp ⊢
  rw [qLorentz_of_connected h]
  exact hp

/-! ## Transitivity on primitive quadruples -/

/-- Everything reachable from the root is connected to it in the groupoid. -/
theorem quadConnected_root_of_reach {a b c d : ℤ} (h : Reach a b c d) :
    QuadConnected (1, 0, 0, 1) (a, b, c, d) := by
  induction h with
  | root => exact quadConnected_refl _
  | @neg a b c d _ ih =>
      exact quadConnected_trans ih (Relation.EqvGen.rel _ _ (QuadMove.n (a, b, c, d)))
  | @swap12 a b c d _ ih =>
      exact quadConnected_trans ih (Relation.EqvGen.rel _ _ (QuadMove.s12 (a, b, c, d)))
  | @swap23 a b c d _ ih =>
      exact quadConnected_trans ih (Relation.EqvGen.rel _ _ (QuadMove.s23 (a, b, c, d)))
  | @refl a b c d _ ih =>
      exact quadConnected_trans ih (Relation.EqvGen.rel _ _ (QuadMove.r (a, b, c, d)))

/-- **Transitivity on primitive quadruples.**  Any two primitive Pythagorean quadruples with
non-negative space coordinates and positive height lie in a single groupoid orbit.  In
particular the whole set of primitive Pythagorean quadruples is one connected component. -/
theorem quadConnected_of_prim {a b c d a' b' c' d' : ℤ}
    (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c) (hd : 0 < d)
    (h : IsPythQuadruple a b c d) (hcont : content a b c d = 1)
    (ha' : 0 ≤ a') (hb' : 0 ≤ b') (hc' : 0 ≤ c') (hd' : 0 < d')
    (h' : IsPythQuadruple a' b' c' d') (hcont' : content a' b' c' d' = 1) :
    QuadConnected (a, b, c, d) (a', b', c', d') := by
  have h1 := quadConnected_root_of_reach (reach_of_prim d.toNat a b c d le_rfl ha hb hc hd h hcont)
  have h2 := quadConnected_root_of_reach
    (reach_of_prim d'.toNat a' b' c' d' le_rfl ha' hb' hc' hd' h' hcont')
  exact quadConnected_trans (quadConnected_symm h1) h2

/-- The invariants are effective: quadruples of different content are never connected. -/
theorem not_connected_of_content_ne {p q : Quad} (h : qcontent p ≠ qcontent q) :
    ¬ QuadConnected p q := fun hc => h (qcontent_of_connected hc).symm

/-- Concretely, the imprimitive quadruple `(2,4,4,6)` is not connected to `(1,2,2,3)`, although
both are Pythagorean: primitivity really is needed in `quadConnected_of_prim`. -/
theorem imprimitive_not_connected :
    ¬ QuadConnected ((1 : ℤ), (2 : ℤ), (2 : ℤ), (3 : ℤ)) (2, 4, 4, 6) := by
  refine not_connected_of_content_ne ?_
  have h1 : qcontent ((1 : ℤ), (2 : ℤ), (2 : ℤ), (3 : ℤ)) = 1 := by decide
  have h2 : qcontent ((2 : ℤ), (4 : ℤ), (4 : ℤ), (6 : ℤ)) = 2 := by decide
  omega

end HigherPythagorean