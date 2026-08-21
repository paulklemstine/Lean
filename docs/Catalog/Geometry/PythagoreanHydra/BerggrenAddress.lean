import Catalog.Geometry.PythagoreanHydra.BerggrenDescent

/-!
# The address function of the Berggren tree

The second front of the research mission asks whether the first-order theory of the
Berggren tree *with its address function* (word ↦ triple) can encode Diophantine
machines, producing a Matiyasevich-style undecidability phenomenon.

Here we prove the opposite, in the strongest form available: the address function

`addr : List BStep → ℤ × ℤ × ℤ`,  `addr [] = (3,4,5)`,  `addr (s :: w) = bergₛ (addr w)`

is a **computable bijection** from the free monoid on three letters onto the set of
primitive Pythagorean triples with odd first leg (`addr_bijective`), its inverse is
computed by the inverse Berggren moves (`parent_addr_cons`), and membership is decidable
(`decidableReach` in `BerggrenDescent.lean`).  The Berggren tree is therefore *free*: no
two addresses collide, and the word can be read off from the triple by descent.  In
particular the address relation is decidable, so no undecidable Diophantine phenomenon
can be encoded in it.

The key computation is that the coordinates `uu`, `vv` used by the parent map recover the
parent triple exactly:  `uu (bergA a b c) = a`, `vv (bergA a b c) = -b`, and similarly
`(a, b)` for `bergB` and `(-a, b)` for `bergC` — the *sign pattern* of `(uu, vv)` is
precisely the label of the last Berggren move.
-/

namespace PythHydra

/-! ### Recovering the last move from the sign pattern -/

theorem uu_bergA (a b c : ℤ) : uu (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 = a := by
  simp only [uu, bergA_fst, bergA_snd_fst, bergA_snd_snd]; ring

theorem vv_bergA (a b c : ℤ) : vv (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 = -b := by
  simp only [vv, bergA_fst, bergA_snd_fst, bergA_snd_snd]; ring

theorem hh_bergA (a b c : ℤ) : hh (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 = c := by
  simp only [hh, bergA_fst, bergA_snd_fst, bergA_snd_snd]; ring

theorem uu_bergB (a b c : ℤ) : uu (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 = a := by
  simp only [uu, bergB_fst, bergB_snd_fst, bergB_snd_snd]; ring

theorem vv_bergB (a b c : ℤ) : vv (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 = b := by
  simp only [vv, bergB_fst, bergB_snd_fst, bergB_snd_snd]; ring

theorem hh_bergB (a b c : ℤ) : hh (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 = c := by
  simp only [hh, bergB_fst, bergB_snd_fst, bergB_snd_snd]; ring

theorem uu_bergC (a b c : ℤ) : uu (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 = -a := by
  simp only [uu, bergC_fst, bergC_snd_fst, bergC_snd_snd]; ring

theorem vv_bergC (a b c : ℤ) : vv (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 = b := by
  simp only [vv, bergC_fst, bergC_snd_fst, bergC_snd_snd]; ring

theorem hh_bergC (a b c : ℤ) : hh (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 = c := by
  simp only [hh, bergC_fst, bergC_snd_fst, bergC_snd_snd]; ring

/-- The parent map undoes a Berggren `A`-move. -/
theorem parent_bergA {a b c : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b) :
    parent (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 = (a, b, c) := by
  simp only [parent, uu_bergA, vv_bergA, hh_bergA, abs_of_nonneg ha, abs_neg,
    abs_of_nonneg hb]

/-- The parent map undoes a Berggren `B`-move. -/
theorem parent_bergB {a b c : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b) :
    parent (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 = (a, b, c) := by
  simp only [parent, uu_bergB, vv_bergB, hh_bergB, abs_of_nonneg ha, abs_of_nonneg hb]

/-- The parent map undoes a Berggren `C`-move. -/
theorem parent_bergC {a b c : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b) :
    parent (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 = (a, b, c) := by
  simp only [parent, uu_bergC, vv_bergC, hh_bergC, abs_neg, abs_of_nonneg ha,
    abs_of_nonneg hb]

/-! ### Hypotenuse estimates -/

/-- Every Berggren triple has hypotenuse at least `5`. -/
theorem IsPPT.five_le {a b c : ℤ} (h : IsPPT a b c) : 5 ≤ c := by
  by_contra hcon
  push_neg at hcon
  have := small_isPPT h (by omega)
  have : c = 5 := congrArg (fun t => t.2.2) this
  omega

theorem bergA_hyp_gt {a b c : ℤ} (h : IsPPT a b c) : c < (bergA a b c).2.2 := by
  obtain ⟨_, hbc⟩ := h.legs_lt
  simp only [bergA_snd_snd]
  linarith [h.ha]

theorem bergB_hyp_gt {a b c : ℤ} (h : IsPPT a b c) : c < (bergB a b c).2.2 := by
  simp only [bergB_snd_snd]
  linarith [h.ha, h.hb, h.hc]

theorem bergC_hyp_gt {a b c : ℤ} (h : IsPPT a b c) : c < (bergC a b c).2.2 := by
  obtain ⟨hac, _⟩ := h.legs_lt
  simp only [bergC_snd_snd]
  linarith [h.hb]

/-! ### The address function -/

/-- A letter of the Berggren alphabet. -/
inductive BStep where
  | A : BStep
  | B : BStep
  | C : BStep
  deriving DecidableEq, Repr

/-- Applying one Berggren move. -/
def applyStep : BStep → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | .A, t => bergA t.1 t.2.1 t.2.2
  | .B, t => bergB t.1 t.2.1 t.2.2
  | .C, t => bergC t.1 t.2.1 t.2.2

@[simp] theorem applyStep_A (t : ℤ × ℤ × ℤ) : applyStep .A t = bergA t.1 t.2.1 t.2.2 := rfl
@[simp] theorem applyStep_B (t : ℤ × ℤ × ℤ) : applyStep .B t = bergB t.1 t.2.1 t.2.2 := rfl
@[simp] theorem applyStep_C (t : ℤ × ℤ × ℤ) : applyStep .C t = bergC t.1 t.2.1 t.2.2 := rfl

/-- The three children of a Berggren node are pairwise distinct. -/
theorem children_distinct {a b c : ℤ} (h : IsPPT a b c) :
    bergA a b c ≠ bergB a b c ∧ bergA a b c ≠ bergC a b c ∧ bergB a b c ≠ bergC a b c := by
  have ha := h.ha
  have hb := h.hb
  have hodd := h.odd
  rw [Int.odd_iff] at hodd
  refine ⟨?_, ?_, ?_⟩ <;> intro hcon <;>
    simp only [bergA, bergB, bergC, Prod.mk.injEq] at hcon <;> omega

/-- The address function: a word (read right to left) names a node of the Berggren tree. -/
def addr : List BStep → ℤ × ℤ × ℤ
  | [] => (3, 4, 5)
  | s :: w => applyStep s (addr w)

theorem addr_isPPT (w : List BStep) : IsPPT (addr w).1 (addr w).2.1 (addr w).2.2 := by
  induction w with
  | nil => exact root_isPPT
  | cons s w ih =>
    cases s <;> simp only [addr, applyStep]
    · exact bergA_isPPT ih
    · exact bergB_isPPT ih
    · exact bergC_isPPT ih

theorem addr_hyp_gt_five (s : BStep) (w : List BStep) : 5 < (addr (s :: w)).2.2 := by
  have h5 := (addr_isPPT w).five_le
  cases s <;> simp only [addr, applyStep]
  · linarith [bergA_hyp_gt (addr_isPPT w)]
  · linarith [bergB_hyp_gt (addr_isPPT w)]
  · linarith [bergC_hyp_gt (addr_isPPT w)]

/-- **Reading off the last letter**: the parent map deletes the head of the address. -/
theorem parent_addr_cons (s : BStep) (w : List BStep) :
    parent (addr (s :: w)).1 (addr (s :: w)).2.1 (addr (s :: w)).2.2 = addr w := by
  have h := addr_isPPT w
  have ha : (0 : ℤ) ≤ (addr w).1 := le_of_lt h.ha
  have hb : (0 : ℤ) ≤ (addr w).2.1 := le_of_lt h.hb
  cases s <;> simp only [addr, applyStep]
  · rw [parent_bergA ha hb]
  · rw [parent_bergB ha hb]
  · rw [parent_bergC ha hb]

/-- **The Berggren tree is free**: distinct addresses name distinct triples. -/
theorem addr_injective : Function.Injective addr := by
  intro w₁
  induction w₁ with
  | nil =>
    intro w₂ h
    cases w₂ with
    | nil => rfl
    | cons s w =>
      exfalso
      have h1 := addr_hyp_gt_five s w
      rw [← h] at h1
      simp only [addr] at h1
      omega
  | cons s w ih =>
    intro w₂ h
    cases w₂ with
    | nil =>
      exfalso
      have h1 := addr_hyp_gt_five s w
      rw [h] at h1
      simp only [addr] at h1
      omega
    | cons t w' =>
      have hp : addr w = addr w' := by
        rw [← parent_addr_cons s w, ← parent_addr_cons t w', h]
      have hww : w = w' := ih hp
      subst hww
      have hppt := addr_isPPT w
      obtain ⟨hAB, hAC, hBC⟩ := children_distinct hppt
      cases s <;> cases t <;>
        simp only [addr, applyStep_A, applyStep_B, applyStep_C] at h ⊢ <;>
        first
          | exact absurd h hAB
          | exact absurd h hAC
          | exact absurd h hBC
          | exact absurd h.symm hAB
          | exact absurd h.symm hAC
          | exact absurd h.symm hBC

/-- Every Berggren triple has an address. -/
theorem exists_addr_of_reach {t : ℤ × ℤ × ℤ} (h : Reach t) : ∃ w : List BStep, addr w = t := by
  induction h with
  | root => exact ⟨[], rfl⟩
  | stepA _ ih =>
    obtain ⟨w, hw⟩ := ih
    exact ⟨BStep.A :: w, by simp only [addr, applyStep_A, hw]⟩
  | stepB _ ih =>
    obtain ⟨w, hw⟩ := ih
    exact ⟨BStep.B :: w, by simp only [addr, applyStep_B, hw]⟩
  | stepC _ ih =>
    obtain ⟨w, hw⟩ := ih
    exact ⟨BStep.C :: w, by simp only [addr, applyStep_C, hw]⟩

theorem exists_addr {a b c : ℤ} (h : IsPPT a b c) : ∃ w : List BStep, addr w = (a, b, c) :=
  exists_addr_of_reach ((reach_iff_isPPT a b c).mpr h)

/-- **The address function is a bijection** from words onto the primitive Pythagorean
triples with odd first leg.  Together with the decision procedure `decidableReach`, this
settles the "address" front: the correspondence word ↔ triple is computable in both
directions, so it carries no undecidable Diophantine content. -/
theorem addr_bijective :
    Function.Injective addr ∧
      ∀ t : ℤ × ℤ × ℤ, (IsPPT t.1 t.2.1 t.2.2 ↔ ∃ w, addr w = t) := by
  refine ⟨addr_injective, fun t => ⟨fun h => ?_, fun ⟨w, hw⟩ => ?_⟩⟩
  · obtain ⟨a, b, c⟩ := t
    exact exists_addr h
  · rw [← hw]
    exact addr_isPPT w

/-- The unique-address form of the previous theorem. -/
theorem exists_unique_addr {a b c : ℤ} (h : IsPPT a b c) :
    ∃! w : List BStep, addr w = (a, b, c) := by
  obtain ⟨w, hw⟩ := exists_addr h
  exact ⟨w, hw, fun w' hw' => addr_injective (by rw [hw, hw'])⟩

example : addr [BStep.B, BStep.B] = (119, 120, 169) := by decide

end PythHydra