import Mathlib

/-!
# Arithmetic on the Möbius band: testing the "Möbius integers" conjecture

The Möbius band is modelled as `M = ([0,1] × ℝ)/((0,y) ∼ (1,−y))`, realised here as
the quotient of `ℝ × ℝ` by the relation `MoebRel` that identifies `(0,y)` with
`(1,−y)` (points outside the seam are identified with nothing but themselves).

The proposed "Möbius integers" are the images of

  `emb n = (1/2 + 1/(2n), |n|)`.

We test every claim of the conjecture. The outcome is a mixture of one confirmation
and four refutations:

* **Confirmed.** The value map `val (x,y) = y(2x−1)` *is* well defined on `M`
  (`val_respects`, `valM`), and the seam point is genuinely twisted:
  `⟦(0,−1)⟧ = ⟦(1,1)⟧` (`twist_point`).
* **Refuted (no induced ring).** Neither coordinatewise addition nor coordinatewise
  multiplication descends to `M`: `no_induced_add`, `no_induced_mul`. Hence
  "`Z_M` is a ring under the induced operations from `ℝ × ℝ/∼`" is false at the
  level of the operations themselves.
* **Refuted (the value map collapses ℤ).** `val (emb n) = sign n`
  (`val_emb`), so the embedding does *not* represent `n`; it only records its sign,
  and e.g. `2` and `3` receive the same value (`val_collapse`).
* **Refuted (1 and −1 are not identified).** `⟦emb 1⟧ ≠ ⟦emb (−1)⟧`
  (`emb_one_ne_emb_neg_one`); in fact `emb` is injective into `M`
  (`emb_injective`), so `Z_M ≃ ℤ` as a set — no one-point compactification.
  Moreover `Z_M` is unbounded, hence not compact (`emb_range_not_compact`).
* **Refuted (the proposed zero divisors).** The alleged nonzero factor `(1,0)` is
  *equal to zero* in `M` (`one_zero_eq_zero`) and is not a Möbius integer at all
  (`one_zero_not_moebius_integer`).

The positive algebraic content that survives is developed in
`MachineLearning.MoebiusTwistRing`, where the twist is a unit of order two in
`ℤ[t]/(t²−1)`, a genuine commutative ring that is not a domain.
-/

namespace MoebiusBand

/-- The seam relation of the Möbius band: `(0,y) ∼ (1,−y)`. -/
def MoebRel (p q : ℝ × ℝ) : Prop :=
  p = q ∨ (p.1 = 0 ∧ q.1 = 1 ∧ q.2 = -p.2) ∨ (p.1 = 1 ∧ q.1 = 0 ∧ q.2 = -p.2)

theorem moebRel_refl (p : ℝ × ℝ) : MoebRel p p := Or.inl rfl

theorem moebRel_symm {p q : ℝ × ℝ} (h : MoebRel p q) : MoebRel q p := by
  rcases h with rfl | ⟨h0, h1, h2⟩ | ⟨h0, h1, h2⟩
  · exact Or.inl rfl
  · exact Or.inr (Or.inr ⟨h1, h0, by rw [h2]; ring⟩)
  · exact Or.inr (Or.inl ⟨h1, h0, by rw [h2]; ring⟩)

theorem moebRel_trans {p q r : ℝ × ℝ} (hpq : MoebRel p q) (hqr : MoebRel q r) :
    MoebRel p r := by
  rcases hpq with rfl | ⟨h0, h1, h2⟩ | ⟨h0, h1, h2⟩
  · exact hqr
  · rcases hqr with rfl | ⟨g0, g1, g2⟩ | ⟨g0, g1, g2⟩
    · exact Or.inr (Or.inl ⟨h0, h1, h2⟩)
    · exact absurd (h1 ▸ g0) (by norm_num)
    · left
      have hr1 : r.1 = p.1 := by rw [g1, h0]
      have hr2 : r.2 = p.2 := by rw [g2, h2]; ring
      exact Prod.ext hr1.symm hr2.symm
  · rcases hqr with rfl | ⟨g0, g1, g2⟩ | ⟨g0, g1, g2⟩
    · exact Or.inr (Or.inr ⟨h0, h1, h2⟩)
    · left
      have hr1 : r.1 = p.1 := by rw [g1, h0]
      have hr2 : r.2 = p.2 := by rw [g2, h2]; ring
      exact Prod.ext hr1.symm hr2.symm
    · exact absurd (h1 ▸ g0) (by norm_num)

instance moebSetoid : Setoid (ℝ × ℝ) where
  r := MoebRel
  iseqv := ⟨moebRel_refl, moebRel_symm, moebRel_trans⟩

/-- The Möbius band as a quotient. -/
def M : Type := Quotient moebSetoid

/-- The class of a point. -/
def pt (p : ℝ × ℝ) : M := Quotient.mk moebSetoid p

theorem pt_eq_iff {p q : ℝ × ℝ} : pt p = pt q ↔ MoebRel p q :=
  ⟨fun h => Quotient.exact h, fun h => Quotient.sound h⟩

/-! ### Confirmed: the value map descends -/

/-- The proposed value of a point: `val (x,y) = y (2x − 1)`. -/
def val (p : ℝ × ℝ) : ℝ := p.2 * (2 * p.1 - 1)

/-- The value map respects the Möbius identification — this part of the conjecture
is correct, and it is exactly the statement that `val` is a section of the twisted
line bundle. -/
theorem val_respects {p q : ℝ × ℝ} (h : MoebRel p q) : val p = val q := by
  rcases h with rfl | ⟨h0, h1, h2⟩ | ⟨h0, h1, h2⟩
  · rfl
  · simp [val, h0, h1, h2]; ring
  · simp [val, h0, h1, h2]; ring

/-- The induced value map on the Möbius band. -/
def valM : M → ℝ := Quotient.lift val fun _ _ h => val_respects h

@[simp] theorem valM_pt (p : ℝ × ℝ) : valM (pt p) = val p := rfl

/-- The twist point: `(0,−1)` and `(1,1)` are the same point of `M`. -/
theorem twist_point : pt (0, -1) = pt (1, 1) := by
  rw [pt_eq_iff]
  exact Or.inr (Or.inl ⟨rfl, rfl, by norm_num⟩)

/-! ### Refuted: no induced ring operations -/

/-- Coordinatewise addition does **not** descend to the Möbius band. -/
theorem no_induced_add : ¬ ∃ f : M → M → M, ∀ p q : ℝ × ℝ, f (pt p) (pt q) = pt (p + q) := by
  rintro ⟨f, hf⟩
  have hseam : pt ((0 : ℝ), (1 : ℝ)) = pt ((1 : ℝ), (-1 : ℝ)) := by
    rw [pt_eq_iff]
    exact Or.inr (Or.inl ⟨rfl, rfl, by norm_num⟩)
  have h1 : f (pt (0, 1)) (pt (0, 1)) = pt ((0, 1) + (0, 1)) := hf _ _
  have h2 : f (pt (1, -1)) (pt (1, -1)) = pt ((1, -1) + (1, -1)) := hf _ _
  rw [hseam] at h1
  rw [h2] at h1
  have hbad : MoebRel ((1, -1) + (1, -1) : ℝ × ℝ) ((0, 1) + (0, 1) : ℝ × ℝ) :=
    pt_eq_iff.mp h1
  rcases hbad with h | ⟨h0, -, -⟩ | ⟨h0, -, -⟩
  · rw [Prod.ext_iff] at h
    norm_num at h
  · norm_num at h0
  · norm_num at h0

/-- Coordinatewise multiplication does **not** descend to the Möbius band. -/
theorem no_induced_mul : ¬ ∃ f : M → M → M, ∀ p q : ℝ × ℝ, f (pt p) (pt q) = pt (p * q) := by
  rintro ⟨f, hf⟩
  have hseam : pt ((0 : ℝ), (1 : ℝ)) = pt ((1 : ℝ), (-1 : ℝ)) := by
    rw [pt_eq_iff]
    exact Or.inr (Or.inl ⟨rfl, rfl, by norm_num⟩)
  have h1 : f (pt (0, 1)) (pt (0, 1)) = pt ((0, 1) * (0, 1)) := hf _ _
  have h2 : f (pt (1, -1)) (pt (1, -1)) = pt ((1, -1) * (1, -1)) := hf _ _
  rw [hseam, h2] at h1
  have hbad : MoebRel ((1, -1) * (1, -1) : ℝ × ℝ) ((0, 1) * (0, 1) : ℝ × ℝ) :=
    pt_eq_iff.mp h1
  rcases hbad with h | ⟨h0, -, -⟩ | ⟨-, -, h2'⟩
  · rw [Prod.ext_iff] at h
    norm_num at h
  · norm_num at h0
  · norm_num at h2'

/-! ### The proposed embedding of ℤ -/

/-- The proposed embedding `n ↦ (1/2 + 1/(2n), |n|)`. -/
noncomputable def emb (n : ℤ) : ℝ × ℝ := (1 / 2 + 1 / (2 * (n : ℝ)), |(n : ℝ)|)

/-- The value of a Möbius integer is only its **sign**: the embedding forgets the
magnitude entirely. -/
theorem val_emb (n : ℤ) : val (emb n) = (Int.sign n : ℝ) := by
  rcases eq_or_ne n 0 with rfl | hn
  · simp [val, emb]
  · have hnR : (n : ℝ) ≠ 0 := Int.cast_ne_zero.mpr hn
    have hval : val (emb n) = |(n : ℝ)| / (n : ℝ) := by
      simp only [val, emb]
      field_simp
      ring
    rw [hval]
    rcases lt_or_gt_of_ne hn with hneg | hpos
    · have h1 : (n : ℝ) < 0 := by exact_mod_cast hneg
      rw [abs_of_neg h1, Int.sign_eq_neg_one_of_neg hneg]
      push_cast
      field_simp
    · have h1 : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hpos
      rw [abs_of_pos h1, Int.sign_eq_one_of_pos hpos]
      push_cast
      field_simp

/-- Distinct Möbius integers can carry the same value: the "number system" cannot
distinguish `2` from `3`. -/
theorem val_collapse : valM (pt (emb 2)) = valM (pt (emb 3)) := by
  rw [valM_pt, valM_pt, val_emb, val_emb,
    show Int.sign 2 = 1 by decide, show Int.sign 3 = 1 by decide]

lemma emb_fst_eq_zero_iff (n : ℤ) : (emb n).1 = 0 ↔ n = -1 := by
  constructor
  · intro h
    rcases eq_or_ne n 0 with rfl | hn
    · norm_num [emb] at h
    · have hnR : (n : ℝ) ≠ 0 := Int.cast_ne_zero.mpr hn
      have : (n : ℝ) = -1 := by
        simp only [emb] at h
        field_simp at h
        linarith
      exact_mod_cast this
  · rintro rfl
    norm_num [emb]

lemma emb_fst_eq_one_iff (n : ℤ) : (emb n).1 = 1 ↔ n = 1 := by
  constructor
  · intro h
    rcases eq_or_ne n 0 with rfl | hn
    · norm_num [emb] at h
    · have hnR : (n : ℝ) ≠ 0 := Int.cast_ne_zero.mpr hn
      have : (n : ℝ) = 1 := by
        simp only [emb] at h
        field_simp at h
        linarith
      exact_mod_cast this
  · rintro rfl
    norm_num [emb]

lemma emb_eq_iff {m n : ℤ} : emb m = emb n ↔ m = n := by
  constructor
  · intro h
    have h2 : |(m : ℝ)| = |(n : ℝ)| := congrArg Prod.snd h
    have h1 : 1 / 2 + 1 / (2 * (m : ℝ)) = 1 / 2 + 1 / (2 * (n : ℝ)) := congrArg Prod.fst h
    have hinv : 1 / (2 * (m : ℝ)) = 1 / (2 * (n : ℝ)) := by linarith
    have habs : m.natAbs = n.natAbs := by
      have hm' : ((m.natAbs : ℕ) : ℝ) = |(m : ℝ)| := by
        rw [Nat.cast_natAbs]
        push_cast
        ring
      have hn' : ((n.natAbs : ℕ) : ℝ) = |(n : ℝ)| := by
        rw [Nat.cast_natAbs]
        push_cast
        ring
      have : ((m.natAbs : ℕ) : ℝ) = ((n.natAbs : ℕ) : ℝ) := by rw [hm', hn', h2]
      exact_mod_cast this
    rcases eq_or_ne m 0 with rfl | hm
    · omega
    · have hn : n ≠ 0 := by omega
      have hmR : (m : ℝ) ≠ 0 := Int.cast_ne_zero.mpr hm
      have hnR : (n : ℝ) ≠ 0 := Int.cast_ne_zero.mpr hn
      have : (m : ℝ) = (n : ℝ) := by
        field_simp at hinv
        linarith
      exact_mod_cast this
  · rintro rfl; rfl

/-- **Refutation of the identification claim.** The images of `1` and `−1` are
*different* points of the Möbius band; nothing is glued at the seam. -/
theorem emb_one_ne_emb_neg_one : pt (emb 1) ≠ pt (emb (-1)) := by
  rw [Ne, pt_eq_iff]
  intro h
  rcases h with h | ⟨h0, h1, h2⟩ | ⟨h0, h1, h2⟩
  · have := emb_eq_iff.mp h
    norm_num at this
  · rw [emb_fst_eq_zero_iff] at h0
    norm_num at h0
  · -- here `emb 1 = (1, 1)` and `emb (-1) = (0, 1)`, so the seam would force `1 = −1`
    have hone : |((1 : ℤ) : ℝ)| = 1 := by norm_num
    have hneg : |(((-1 : ℤ)) : ℝ)| = 1 := by norm_num
    simp only [emb] at h2
    rw [hone, hneg] at h2
    norm_num at h2

/-- The Möbius integers are just a copy of `ℤ`: the embedding is injective into `M`,
so there is no "single infinity" and no one-point compactification. -/
theorem emb_injective : Function.Injective (fun n : ℤ => pt (emb n)) := by
  intro m n h
  rcases pt_eq_iff.mp h with h | ⟨h0, h1, h2⟩ | ⟨h0, h1, h2⟩
  · exact emb_eq_iff.mp h
  · exfalso
    rw [emb_fst_eq_zero_iff] at h0
    rw [emb_fst_eq_one_iff] at h1
    subst h0; subst h1
    simp only [emb] at h2
    norm_num at h2
  · exfalso
    rw [emb_fst_eq_one_iff] at h0
    rw [emb_fst_eq_zero_iff] at h1
    subst h0; subst h1
    simp only [emb] at h2
    norm_num at h2

/-- The set of Möbius integers is unbounded in `ℝ × ℝ`. -/
theorem emb_range_unbounded (C : ℝ) : ∃ n : ℤ, C < ‖emb n‖ := by
  obtain ⟨k, hk⟩ := exists_nat_gt (max C 0)
  refine ⟨(k : ℤ), ?_⟩
  have h1 : C < |((k : ℤ) : ℝ)| := by
    have h0 : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
    have : ((k : ℤ) : ℝ) = (k : ℝ) := by push_cast; ring
    rw [this, abs_of_nonneg h0]
    exact lt_of_le_of_lt (le_max_left C 0) hk
  have h2 : ‖emb (k : ℤ)‖ = max ‖(emb (k : ℤ)).1‖ ‖(emb (k : ℤ)).2‖ := Prod.norm_def _
  rw [h2]
  refine lt_of_lt_of_le h1 (le_trans ?_ (le_max_right _ _))
  simp [emb]

/-- Hence the set of Möbius integers is **not compact**: it is not a one-point
compactification of anything. -/
theorem emb_range_not_compact : ¬ IsCompact (Set.range emb) := by
  intro hc
  obtain ⟨C, hC⟩ := hc.isBounded.exists_norm_le
  obtain ⟨n, hn⟩ := emb_range_unbounded C
  exact absurd (hC (emb n) ⟨n, rfl⟩) (not_le.mpr hn)

/-! ### Refuted: the proposed zero divisors -/

/-- The alleged nonzero factor `(1,0)` **is** the zero point of the Möbius band:
the seam identifies `(1,0)` with `(0,0)`. -/
theorem one_zero_eq_zero : pt ((1 : ℝ), (0 : ℝ)) = pt ((0 : ℝ), (0 : ℝ)) := by
  rw [pt_eq_iff]
  exact Or.inr (Or.inr ⟨rfl, rfl, by norm_num⟩)

/-- Moreover `(1,0)` is not a Möbius integer. -/
theorem one_zero_not_moebius_integer : ((1 : ℝ), (0 : ℝ)) ∉ Set.range emb := by
  rintro ⟨n, hn⟩
  have h2 : |(n : ℝ)| = 0 := congrArg Prod.snd hn
  have hn0 : n = 0 := by
    have : (n : ℝ) = 0 := abs_eq_zero.mp h2
    exact_mod_cast this
  subst hn0
  have h1 : (emb 0).1 = 1 := by rw [hn]
  norm_num [emb] at h1

/-- Summary of the zero-divisor test: the witness `(1,0) · (0,1) = (0,0)` has a
factor equal to zero in `M`, so it exhibits no zero divisor. -/
theorem zero_divisor_witness_fails :
    ((1 : ℝ), (0 : ℝ)) * ((0 : ℝ), (1 : ℝ)) = ((0 : ℝ), (0 : ℝ)) ∧
      pt ((1 : ℝ), (0 : ℝ)) = pt ((0 : ℝ), (0 : ℝ)) := by
  refine ⟨?_, one_zero_eq_zero⟩
  simp

end MoebiusBand