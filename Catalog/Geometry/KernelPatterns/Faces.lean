import Geometry.KernelPatterns.Chambers

/-!
# Cycle 2: ordered patterns and the faces of the braid arrangement

A kernel pattern remembers which coordinates of a tuple agree; an *ordered*
pattern also remembers how the resulting blocks are ordered.  Geometrically,
kernel patterns index the flats of the braid arrangement while ordered patterns
index its **faces** (relatively open cones): the face containing `v` is cut out
by the full system of comparisons `v i ≤ v j`.

* `rank v i` — the number of blocks of `v` whose value is `< v i`; this is the
  canonical form of an ordered pattern.
* `rank_lt_iff`, `rank_eq_iff` — `rank` records the weak order faithfully.
* `rank_congr`, `rank_comp_strictMono` — ordered patterns are invariant under
  strictly monotone reparametrisation of the values, i.e. they are the
  invariants of the action of the order-automorphisms of the value line.
* `face_eq_iff` — two tuples span the same face iff they have the same ordered
  pattern; `face_convex`; a chamber is the face of an injective tuple
  (`face_eq_chamber`).
* `card_ordPatterns_le_four` — the face counts `1, 1, 3, 13, 75`, the
  ordered Bell (Fubini) numbers OEIS A000670.
-/

namespace Geometry.KernelPatterns

open Finset

variable {n : ℕ} {X : Type*} [LinearOrder X]

/-! ### The ordered pattern (rank function) -/

/-- The rank of the coordinate `i`: the number of blocks of `v` carrying a
value strictly smaller than `v i`. -/
def rank (v : Fin n → X) (i : Fin n) : Fin n :=
  ⟨(univ.filter fun j => pat v j = j ∧ v j < v i).card, by
    have h1 : pat v i ∉ (univ.filter fun j => pat v j = j ∧ v j < v i) := by
      simp [apply_pat]
    have h2 : (univ.filter fun j => pat v j = j ∧ v j < v i) ⊂ univ :=
      ⟨Finset.subset_univ _, fun h => h1 (h (Finset.mem_univ _))⟩
    simpa using Finset.card_lt_card h2⟩

lemma rank_val (v : Fin n → X) (i : Fin n) :
    (rank v i : ℕ) = (univ.filter fun j => pat v j = j ∧ v j < v i).card := rfl

/-- The rank function is strictly monotone with respect to the values. -/
theorem rank_lt_iff {v : Fin n → X} {i j : Fin n} : rank v i < rank v j ↔ v i < v j := by
  constructor
  · intro h
    by_contra hle
    push_neg at hle
    have hsub : (univ.filter fun k => pat v k = k ∧ v k < v j) ⊆
        (univ.filter fun k => pat v k = k ∧ v k < v i) := by
      intro k hk
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hk ⊢
      exact ⟨hk.1, lt_of_lt_of_le hk.2 hle⟩
    have := Finset.card_le_card hsub
    rw [Fin.lt_def, rank_val, rank_val] at h
    omega
  · intro h
    have hsub : (univ.filter fun k => pat v k = k ∧ v k < v i) ⊂
        (univ.filter fun k => pat v k = k ∧ v k < v j) := by
      refine ⟨fun k hk => ?_, fun hcon => ?_⟩
      · simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hk ⊢
        exact ⟨hk.1, hk.2.trans h⟩
      · have hmem : pat v i ∈ (univ.filter fun k => pat v k = k ∧ v k < v j) := by
          simp [apply_pat, h]
        have := hcon hmem
        simp [apply_pat] at this
    rw [Fin.lt_def, rank_val, rank_val]
    exact Finset.card_lt_card hsub

/-- The rank function records the kernel. -/
theorem rank_eq_iff {v : Fin n → X} {i j : Fin n} : rank v i = rank v j ↔ v i = v j := by
  constructor
  · intro h
    rcases lt_trichotomy (v i) (v j) with hlt | heq | hgt
    · exact absurd (rank_lt_iff.2 hlt) (by rw [h]; exact lt_irrefl _)
    · exact heq
    · exact absurd (rank_lt_iff.2 hgt) (by rw [h]; exact lt_irrefl _)
  · intro h
    rcases lt_trichotomy (rank v i) (rank v j) with hlt | heq | hgt
    · exact absurd (rank_lt_iff.1 hlt) (by rw [h]; exact lt_irrefl _)
    · exact heq
    · exact absurd (rank_lt_iff.1 hgt) (by rw [h]; exact lt_irrefl _)

/-- Two tuples inducing the same weak order have the same ordered pattern. -/
theorem rank_congr {Y : Type*} [LinearOrder Y] {v : Fin n → X} {u : Fin n → Y}
    (h : ∀ i j, v i < v j ↔ u i < u j) : rank v = rank u := by
  have heq : ∀ i j, v i = v j ↔ u i = u j := by
    intro i j
    constructor
    · intro hij
      rcases lt_trichotomy (u i) (u j) with hlt | h' | hgt
      · exact absurd ((h i j).2 hlt) (by rw [hij]; exact lt_irrefl _)
      · exact h'
      · exact absurd ((h j i).2 hgt) (by rw [hij]; exact lt_irrefl _)
    · intro hij
      rcases lt_trichotomy (v i) (v j) with hlt | h' | hgt
      · exact absurd ((h i j).1 hlt) (by rw [hij]; exact lt_irrefl _)
      · exact h'
      · exact absurd ((h j i).1 hgt) (by rw [hij]; exact lt_irrefl _)
  have hpat : pat v = pat u := pat_congr heq
  funext i
  apply Fin.ext
  rw [rank_val, rank_val]
  refine congrArg Finset.card (Finset.filter_congr fun k _ => ?_)
  rw [hpat]
  exact and_congr Iff.rfl (h k i)

/-- Ordered patterns are invariant under strictly monotone reparametrisation of
the values. -/
theorem rank_comp_strictMono {Y : Type*} [LinearOrder Y] {f : X → Y} (hf : StrictMono f)
    (v : Fin n → X) : rank (f ∘ v) = rank v :=
  rank_congr fun i j => by simpa using hf.lt_iff_lt (a := v i) (b := v j)

@[simp] theorem rank_idem (v : Fin n → X) : rank (rank v) = rank v :=
  rank_congr fun _ _ => rank_lt_iff

/-- The ordered pattern refines the kernel pattern. -/
@[simp] theorem pat_rank (v : Fin n → X) : pat (rank v) = pat v :=
  pat_congr fun _ _ => rank_eq_iff

/-! ### Faces of the braid arrangement -/

/-- The face of the braid arrangement spanned by `v`: the tuples inducing the
same weak order. -/
def face (v : Fin n → ℝ) : Set (Fin n → ℝ) :=
  {w | ∀ i j, (v i < v j ↔ w i < w j)}

theorem face_convex (v : Fin n → ℝ) : Convex ℝ (face v) := by
  intro w hw w' hw' a b ha hb hab i j
  constructor
  · intro hij
    have h1 : w i < w j := (hw i j).1 hij
    have h2 : w' i < w' j := (hw' i j).1 hij
    have key : a * w i + b * w' i < a * w j + b * w' j := by
      rcases eq_or_lt_of_le ha with ha0 | hapos
      · have hb1 : b = 1 := by linarith
        have ha1 : a = 0 := ha0.symm
        rw [ha1, hb1]; linarith
      · nlinarith [mul_lt_mul_of_pos_left h1 hapos, mul_le_mul_of_nonneg_left h2.le hb]
    simpa using key
  · intro hij
    by_contra hcon
    push_neg at hcon
    rcases eq_or_lt_of_le hcon with heq | hlt
    · have h1 : w i = w j := by
        by_contra hne
        rcases lt_or_gt_of_ne hne with h | h
        · have hv : v i < v j := (hw i j).2 h
          rw [heq] at hv; exact absurd hv (lt_irrefl _)
        · have hv : v j < v i := (hw j i).2 h
          rw [heq] at hv; exact absurd hv (lt_irrefl _)
      have h2 : w' i = w' j := by
        by_contra hne
        rcases lt_or_gt_of_ne hne with h | h
        · have hv : v i < v j := (hw' i j).2 h
          rw [heq] at hv; exact absurd hv (lt_irrefl _)
        · have hv : v j < v i := (hw' j i).2 h
          rw [heq] at hv; exact absurd hv (lt_irrefl _)
      have : (a • w + b • w') i = (a • w + b • w') j := by
        simp [h1, h2]
      exact absurd hij (by rw [this]; exact lt_irrefl _)
    · have h1 : w j < w i := (hw j i).1 hlt
      have h2 : w' j < w' i := (hw' j i).1 hlt
      have key : a * w j + b * w' j < a * w i + b * w' i := by
        rcases eq_or_lt_of_le ha with ha0 | hapos
        · have hb1 : b = 1 := by linarith
          have ha1 : a = 0 := ha0.symm
          rw [ha1, hb1]; linarith
        · nlinarith [mul_lt_mul_of_pos_left h1 hapos, mul_le_mul_of_nonneg_left h2.le hb]
      have hlt' : (a • w + b • w') j < (a • w + b • w') i := by simpa using key
      exact absurd hij (not_lt.2 hlt'.le)

theorem mem_face_self (v : Fin n → ℝ) : v ∈ face v := fun _ _ => Iff.rfl

/-- **The ordered pattern is a complete invariant of the face.** -/
theorem face_eq_iff (v w : Fin n → ℝ) : face v = face w ↔ rank v = rank w := by
  constructor
  · intro h
    have hw : w ∈ face v := by rw [h]; exact mem_face_self w
    exact rank_congr fun i j => hw i j
  · intro h
    have hiff : ∀ i j, v i < v j ↔ w i < w j := by
      intro i j
      rw [← rank_lt_iff (v := v), ← rank_lt_iff (v := w), h]
    ext u
    exact ⟨fun hu i j => (hiff i j).symm.trans (hu i j),
      fun hu i j => (hiff i j).trans (hu i j)⟩

/-- Chambers are the faces of injective tuples. -/
theorem face_eq_chamber {σ : Equiv.Perm (Fin n)} {v : Fin n → ℝ} (hv : v ∈ chamber n σ) :
    face v = chamber n σ := by
  ext w
  constructor
  · intro hw i j hij
    exact (hw (σ i) (σ j)).1 (hv i j hij)
  · intro hw i j
    constructor
    · intro hij
      have hlt : σ.symm i < σ.symm j := by
        by_contra hle
        push_neg at hle
        rcases eq_or_lt_of_le hle with heq | hlt'
        · have : i = j := by
            have := congrArg σ heq
            simpa using this.symm
          exact absurd hij (by rw [this]; exact lt_irrefl _)
        · have := hv _ _ hlt'
          simp only [Equiv.apply_symm_apply] at this
          exact absurd hij (not_lt.2 this.le)
      have := hw _ _ hlt
      simpa using this
    · intro hij
      have hlt : σ.symm i < σ.symm j := by
        by_contra hle
        push_neg at hle
        rcases eq_or_lt_of_le hle with heq | hlt'
        · have : i = j := by
            have := congrArg σ heq
            simpa using this.symm
          exact absurd hij (by rw [this]; exact lt_irrefl _)
        · have := hw _ _ hlt'
          simp only [Equiv.apply_symm_apply] at this
          exact absurd hij (not_lt.2 this.le)
      have := hv _ _ hlt
      simpa using this

/-! ### Counting ordered patterns: the Fubini numbers -/

/-- The finset of ordered patterns of length `n`. -/
def ordPatterns (n : ℕ) : Finset (Fin n → Fin n) :=
  univ.image fun v : Fin n → Fin n => rank v

theorem mem_ordPatterns {n : ℕ} (r : Fin n → Fin n) :
    r ∈ ordPatterns n ↔ rank r = r := by
  constructor
  · rintro hr
    obtain ⟨v, -, rfl⟩ := Finset.mem_image.1 hr
    exact rank_idem v
  · intro hr
    exact Finset.mem_image.2 ⟨r, Finset.mem_univ _, hr⟩

theorem ordPatterns_eq_filter (n : ℕ) :
    ordPatterns n = univ.filter fun r : Fin n → Fin n => rank r = r := by
  ext r
  simp [mem_ordPatterns]

theorem card_ordPatterns_zero : (ordPatterns 0).card = 1 := by
  rw [ordPatterns_eq_filter]; decide

theorem card_ordPatterns_one : (ordPatterns 1).card = 1 := by
  rw [ordPatterns_eq_filter]; decide

theorem card_ordPatterns_two : (ordPatterns 2).card = 3 := by
  rw [ordPatterns_eq_filter]; decide

set_option maxRecDepth 8000 in
theorem card_ordPatterns_three : (ordPatterns 3).card = 13 := by
  rw [ordPatterns_eq_filter]; decide

set_option maxRecDepth 100000 in
theorem card_ordPatterns_four : (ordPatterns 4).card = 75 := by
  rw [ordPatterns_eq_filter]; decide

/-- **The face counts are the ordered Bell (Fubini) numbers** `1, 1, 3, 13, 75`
(OEIS A000670), in contrast with the Bell numbers counting the flats. -/
theorem card_ordPatterns_le_four :
    (ordPatterns 0).card = 1 ∧ (ordPatterns 1).card = 1 ∧ (ordPatterns 2).card = 3 ∧
      (ordPatterns 3).card = 13 ∧ (ordPatterns 4).card = 75 :=
  ⟨card_ordPatterns_zero, card_ordPatterns_one, card_ordPatterns_two,
    card_ordPatterns_three, card_ordPatterns_four⟩

end Geometry.KernelPatterns