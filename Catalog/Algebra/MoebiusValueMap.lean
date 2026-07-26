import Mathlib

/-!
# The Möbius band value map and the collapse of the "Möbius integers"

We model the Möbius band as the quotient of `ℝ × ℝ` by the gluing relation
`(0, y) ~ (1, -y)` (the two boundary fibres `{0} × ℝ` and `{1} × ℝ` are
identified with a flip).  On this space the *value* function
`φ(x, y) = y * (2*x - 1)` descends to a well-defined map `MoebiusValue : Moebius → ℝ`.

The main negative result is a **counterexample**: the naive attempt to embed `ℤ`
into the Möbius band and read off an integer via the value map *collapses* —
distinct integers land on the same value, so the "Möbius integers" do **not**
form an injective copy of `ℤ` (and hence carry no faithful ring structure).

The positive results are:

* `MoebiusValue` is a well-defined surjection onto `ℝ`;
* the `twist` involution acts as negation on values, giving a `ℤ/2ℤ`-grading;
* the zero fibre of `MoebiusValue` is exactly the set of points with `y = 0`
  or `x = 1/2`.
-/

namespace MoebiusValueMap

/-- The gluing relation defining the Möbius band as a quotient of `ℝ × ℝ`:
the boundary fibre `{0} × ℝ` is glued to `{1} × ℝ` with a flip, `(0, y) ~ (1, -y)`. -/
def moebRel (p q : ℝ × ℝ) : Prop :=
  p = q ∨ (p.1 = 0 ∧ q.1 = 1 ∧ p.2 = -q.2) ∨ (p.1 = 1 ∧ q.1 = 0 ∧ p.2 = -q.2)

theorem moebRel_refl (p : ℝ × ℝ) : moebRel p p := Or.inl rfl

theorem moebRel_symm {p q : ℝ × ℝ} (h : moebRel p q) : moebRel q p := by
  rcases h with h | ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩
  · exact Or.inl h.symm
  · exact Or.inr (Or.inr ⟨h2, h1, by rw [h3]; ring⟩)
  · exact Or.inr (Or.inl ⟨h2, h1, by rw [h3]; ring⟩)

theorem moebRel_trans {p q r : ℝ × ℝ} (hpq : moebRel p q) (hqr : moebRel q r) :
    moebRel p r := by
  simp only [moebRel] at *
  grind

/-- The setoid underlying the Möbius band. -/
def moebSetoid : Setoid (ℝ × ℝ) :=
  ⟨moebRel, moebRel_refl, fun {_ _} => moebRel_symm, fun {_ _ _} => moebRel_trans⟩

/-- The Möbius band as a quotient of `ℝ × ℝ`. -/
abbrev Moebius := Quotient moebSetoid

/-- The class of a point of `ℝ × ℝ` in the Möbius band. -/
def mk (p : ℝ × ℝ) : Moebius := Quotient.mk moebSetoid p

/-- The value function on representatives: `φ(x, y) = y * (2*x - 1)`. -/
noncomputable def value (x y : ℝ) : ℝ := y * (2 * x - 1)

/-- The value function is constant on gluing classes. -/
theorem value_respects {p q : ℝ × ℝ} (h : moebRel p q) :
    value p.1 p.2 = value q.1 q.2 := by
  rcases h with h | ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩
  · rw [h]
  · simp only [value, h1, h2, h3]; ring
  · simp only [value, h1, h2, h3]; ring

/-- The value map descends to the Möbius band. -/
noncomputable def MoebiusValue : Moebius → ℝ :=
  Quotient.lift (fun p => value p.1 p.2) (fun _ _ h => value_respects h)

@[simp] theorem MoebiusValue_mk (p : ℝ × ℝ) :
    MoebiusValue (mk p) = value p.1 p.2 := rfl

/-- The value map is surjective onto `ℝ`. -/
theorem MoebiusValue_surjective : Function.Surjective MoebiusValue := by
  intro r
  by_cases hr : 0 ≤ r
  · exact ⟨mk (1, r), by simp only [MoebiusValue_mk, value]; ring⟩
  · exact ⟨mk (0, -r), by simp only [MoebiusValue_mk, value]; ring⟩

/-! ## The collapse of the "Möbius integers" -/

/-- The naive embedding of `ℤ` into the Möbius band, using the point
`(1/2 + 1/(2n), |n|)` for `n ≠ 0`. -/
noncomputable def embed (n : ℤ) : Moebius :=
  mk (1 / 2 + 1 / (2 * (n : ℝ)), |(n : ℝ)|)

/-- The value of the embedded integer `n ≠ 0` is exactly its sign:
`value (1/2 + 1/(2n)) |n| = |n| · (1/n) = |n|/n = sign n`. -/
theorem MoebiusValue_embed {n : ℤ} (hn : n ≠ 0) :
    MoebiusValue (embed n) = (Int.sign n : ℝ) := by
  have h_val : MoebiusValue (embed n)
      = |(n : ℝ)| * (2 * (1 / 2 + 1 / (2 * (n : ℝ))) - 1) := rfl
  rcases lt_or_gt_of_ne hn with hneg | hpos
  · have hR : (n : ℝ) < 0 := by exact_mod_cast hneg
    rw [h_val, abs_of_neg hR, Int.sign_eq_neg_one_of_neg hneg]
    push_cast; field_simp; ring
  · have hR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hpos
    rw [h_val, abs_of_pos hR, Int.sign_eq_one_of_pos hpos]
    push_cast; field_simp; ring

/-- **Collapse**: distinct integers `1` and `2` are sent to the same value. -/
theorem embed_collapse : MoebiusValue (embed 1) = MoebiusValue (embed 2) := by
  rw [MoebiusValue_embed (by norm_num), MoebiusValue_embed (by norm_num)]
  norm_num [Int.sign]

/-- **Non-injectivity**: the map `n ↦ MoebiusValue (embed n)` is not injective, so the
proposed "Möbius integers" are not a faithful copy of `ℤ`. -/
theorem MoebiusValue_embed_not_injective :
    ¬ Function.Injective (fun n : ℤ => MoebiusValue (embed n)) := by
  intro h
  have : (1 : ℤ) = 2 := h embed_collapse
  norm_num at this

/-! ## The twist involution acts as negation -/

/-- The twist relation is respected by the gluing. -/
theorem twist_respects {p q : ℝ × ℝ} (h : moebRel p q) :
    moebRel (1 - p.1, p.2) (1 - q.1, q.2) := by
  rcases h with h | ⟨h1, h2, h3⟩ | ⟨h1, h2, h3⟩
  · rw [h]; exact Or.inl rfl
  · exact Or.inr (Or.inr ⟨by rw [h1]; ring, by rw [h2]; ring, h3⟩)
  · exact Or.inr (Or.inl ⟨by rw [h1]; ring, by rw [h2]; ring, h3⟩)

/-- The twist map `⟦(x, y)⟧ ↦ ⟦(1 - x, y)⟧` on the Möbius band. -/
noncomputable def twist : Moebius → Moebius :=
  Quotient.map (fun p => (1 - p.1, p.2)) (fun _ _ h => twist_respects h)

@[simp] theorem twist_mk (p : ℝ × ℝ) :
    twist (mk p) = mk (1 - p.1, p.2) := rfl

/-- The twist acts as negation on the value map, exhibiting a `ℤ/2ℤ`-grading. -/
theorem MoebiusValue_twist (p : Moebius) :
    MoebiusValue (twist p) = - MoebiusValue p := by
  refine Quotient.inductionOn p (fun a => ?_)
  show value (1 - a.1) a.2 = - value a.1 a.2
  simp only [value]; ring

/-! ## The zero fibre -/

/-- The zero fibre of the value map on representatives: `φ(x, y) = 0` iff
`y = 0` or `x = 1/2`.  In the quotient this is the zero section together with the
central circle, the endpoints of the zero section being identified by the twist. -/
theorem MoebiusValue_eq_zero_iff (x y : ℝ) :
    MoebiusValue (mk (x, y)) = 0 ↔ (y = 0 ∨ x = 1 / 2) := by
  simp only [MoebiusValue_mk, value]
  constructor
  · intro h
    rcases mul_eq_zero.mp h with hy | hx
    · exact Or.inl hy
    · right; linarith
  · rintro (hy | hx)
    · simp [hy]
    · rw [hx]; ring

end MoebiusValueMap