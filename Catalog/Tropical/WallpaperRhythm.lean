/-
# Crystallographic Groups and Music: Symmetries of Periodic Rhythm Patterns

This module develops the mathematical theory connecting periodic rhythm patterns
to crystallographic (wallpaper) group symmetries. We formalize:

1. Periodic rhythms as functions ℤ → Bool with translational symmetry
2. The translational symmetry group of a rhythm
3. Palindromic (mirror-symmetric) rhythms and their characterization
4. 2D drum patterns with doubly-periodic structure
5. The wallpaper type classification and crystallographic restriction
6. The key theorem: double mirror symmetry implies rotational symmetry

The mathematical insight: the symmetry group of a periodic rhythm classifies its
structural type, connecting music theory to crystallography.
-/
import Mathlib

open Finset Function

/-! ## Periodic Rhythms -/

/-- A `PeriodicRhythm` is a binary function on ℤ that is periodic with period `p > 0`. -/
structure PeriodicRhythm where
  pattern : ℤ → Bool
  period : ℕ
  period_pos : 0 < period
  is_periodic : ∀ n : ℤ, pattern (n + period) = pattern n

namespace PeriodicRhythm

/-- The onset set of a rhythm. -/
def onsetSet (r : PeriodicRhythm) : Set ℤ :=
  {n | r.pattern n = true}

/-- Periodicity extends to all natural number multiples of the period. -/
theorem periodic_mul (r : PeriodicRhythm) (n : ℤ) (m : ℕ) :
    r.pattern (n + m * r.period) = r.pattern n := by
  induction m with
  | zero => simp
  | succ k ih =>
    have : (↑(k + 1) : ℤ) * ↑r.period = ↑k * ↑r.period + ↑r.period := by push_cast; ring
    rw [this, ← add_assoc, r.is_periodic, ih]

/-- The translational symmetry group: all integers `d` such that
    translating by `d` preserves the rhythm. -/
def symmGroup (r : PeriodicRhythm) : AddSubgroup ℤ where
  carrier := {d | ∀ n, r.pattern (n + d) = r.pattern n}
  add_mem' {a b} ha hb n := by
    rw [show n + (a + b) = (n + a) + b from by ring, hb, ha]
  zero_mem' := by simp
  neg_mem' {a} ha n := by
    have h := ha (n + (-a))
    rw [show n + (-a) + a = n from by ring] at h
    rw [← h]

/-- The period is in the symmetry group. -/
theorem period_mem_symmGroup (r : PeriodicRhythm) :
    (r.period : ℤ) ∈ r.symmGroup :=
  fun n => r.is_periodic n

/-
All integer multiples of the period are in the symmetry group.
-/
theorem mul_period_mem_symmGroup (r : PeriodicRhythm) (m : ℤ) :
    m * (r.period : ℤ) ∈ r.symmGroup := by
  rcases Int.eq_nat_or_neg m with ⟨ k, rfl | rfl ⟩;
  · exact fun n => by simpa [ mul_comm ] using r.periodic_mul n k;
  · have h_neg : (k * r.period : ℤ) ∈ r.symmGroup := by
      exact fun n => by simpa [ mul_comm ] using r.periodic_mul n k;
    simpa using r.symmGroup.neg_mem h_neg

end PeriodicRhythm

/-! ## Cyclic Equivalence of Rhythms -/

/-- Two rhythms are cyclically equivalent if one is a translate of the other. -/
def cyclicEquiv (r₁ r₂ : PeriodicRhythm) : Prop :=
  ∃ d : ℤ, ∀ n, r₁.pattern (n + d) = r₂.pattern n

theorem cyclicEquiv_refl (r : PeriodicRhythm) : cyclicEquiv r r :=
  ⟨0, by simp⟩

theorem cyclicEquiv_symm {r₁ r₂ : PeriodicRhythm} (h : cyclicEquiv r₁ r₂) :
    cyclicEquiv r₂ r₁ := by
  obtain ⟨d, hd⟩ := h
  exact ⟨-d, fun n => by rw [← hd]; ring_nf⟩

theorem cyclicEquiv_trans {r₁ r₂ r₃ : PeriodicRhythm}
    (h₁₂ : cyclicEquiv r₁ r₂) (h₂₃ : cyclicEquiv r₂ r₃) :
    cyclicEquiv r₁ r₃ := by
  obtain ⟨d₁, hd₁⟩ := h₁₂
  obtain ⟨d₂, hd₂⟩ := h₂₃
  exact ⟨d₁ + d₂, fun n => by
    rw [show n + (d₁ + d₂) = (n + d₂) + d₁ from by ring, hd₁, hd₂]⟩

/-! ## 2D Drum Patterns -/

/-- A `DrumPattern` is a doubly-periodic binary function on ℤ × ℤ. -/
structure DrumPattern where
  pattern : ℤ × ℤ → Bool
  period_time : ℕ
  period_pitch : ℕ
  period_time_pos : 0 < period_time
  period_pitch_pos : 0 < period_pitch
  periodic_time : ∀ p : ℤ × ℤ, pattern (p.1 + period_time, p.2) = pattern p
  periodic_pitch : ∀ p : ℤ × ℤ, pattern (p.1, p.2 + period_pitch) = pattern p

namespace DrumPattern

/-- The translational symmetry group of a drum pattern. -/
def transSymmGroup (g : DrumPattern) : AddSubgroup (ℤ × ℤ) where
  carrier := {v | ∀ p : ℤ × ℤ, g.pattern (p.1 + v.1, p.2 + v.2) = g.pattern p}
  add_mem' {a b} ha hb p := by
    simp only [Set.mem_setOf_eq] at *
    have h1 := ha (p.1 + b.1, p.2 + b.2)
    simp only [Prod.fst, Prod.snd] at h1
    rw [show p.1 + (a + b).1 = p.1 + b.1 + a.1 from by simp [Prod.fst_add]; ring,
        show p.2 + (a + b).2 = p.2 + b.2 + a.2 from by simp [Prod.snd_add]; ring]
    rw [h1, hb]
  zero_mem' := by simp
  neg_mem' {a} ha p := by
    simp only [Set.mem_setOf_eq] at *
    have h := ha (p.1 + (-a).1, p.2 + (-a).2)
    simp only [Prod.fst, Prod.snd] at h
    rw [show p.1 + (-a).1 + a.1 = p.1 from by rw [Prod.fst_neg]; ring,
        show p.2 + (-a).2 + a.2 = p.2 from by rw [Prod.snd_neg]; ring] at h
    rw [← h]

/-- A drum pattern has time-mirror symmetry (pm in time direction). -/
def hasTimeMirror (g : DrumPattern) : Prop :=
  ∀ p : ℤ × ℤ, g.pattern (g.period_time - 1 - p.1, p.2) = g.pattern p

/-- A drum pattern has pitch-mirror symmetry (pm in pitch direction). -/
def hasPitchMirror (g : DrumPattern) : Prop :=
  ∀ p : ℤ × ℤ, g.pattern (p.1, g.period_pitch - 1 - p.2) = g.pattern p

/-- A drum pattern has 2-fold rotational symmetry (p2 type). -/
def hasRotation2 (g : DrumPattern) : Prop :=
  ∀ p : ℤ × ℤ, g.pattern (g.period_time - 1 - p.1, g.period_pitch - 1 - p.2) = g.pattern p

end DrumPattern

/-! ## Key Theorem: Double Mirror implies Rotation

The composition of two perpendicular reflections is a 180° rotation.
This is the crystallographic fact that pmm ⊇ p2. -/

/-
**Theorem (pmm ⊇ p2)**: If a drum pattern has both time-mirror and
    pitch-mirror symmetry, then it has 2-fold rotational symmetry.
-/
theorem double_mirror_implies_rotation (g : DrumPattern)
    (hm_t : g.hasTimeMirror) (hm_p : g.hasPitchMirror) :
    g.hasRotation2 := by
  intro p; have := hm_t p; have := hm_p p; simp_all +decide [ DrumPattern.hasTimeMirror, DrumPattern.hasPitchMirror ] ;

/-! ## Finite Rhythms and Reflection -/

/-- A finite rhythm on ℤ/nℤ. -/
abbrev FiniteRhythm (n : ℕ) := Fin n → Bool

/-- A finite rhythm is palindromic. -/
def isPalindromicFinite {n : ℕ} (f : FiniteRhythm n) : Prop :=
  ∀ k : Fin n, f ⟨n - 1 - k.val, by omega⟩ = f k

/-- The reflection of a finite rhythm. -/
def reflectRhythm {n : ℕ} (f : FiniteRhythm n) : FiniteRhythm n :=
  fun k => f ⟨n - 1 - k.val, by omega⟩

/-
Reflecting twice gives back the original rhythm.
-/
theorem reflect_involutive {n : ℕ} (f : FiniteRhythm n) :
    reflectRhythm (reflectRhythm f) = f := by
  ext k;
  exact congr_arg f ( Fin.ext <| by norm_num; omega )

/-
A rhythm is palindromic iff it equals its reflection.
-/
theorem palindromic_iff_eq_reflect {n : ℕ} (f : FiniteRhythm n) :
    isPalindromicFinite f ↔ reflectRhythm f = f := by
  exact ⟨ fun h => funext fun k => h k, fun h k => congr_fun h k ⟩

/-! ## Wallpaper Group Classification -/

/-- The 17 wallpaper group types, classified by their point group symmetries. -/
inductive WallpaperType where
  | p1 | p2 | pm | pg | cm | pmm | pmg | pgg | cmm
  | p4 | p4m | p4g | p3 | p3m1 | p31m | p6 | p6m
  deriving DecidableEq, Repr

deriving instance Fintype for WallpaperType

/-
There are exactly 17 wallpaper types.
-/
theorem wallpaper_type_card : Fintype.card WallpaperType = 17 := by
  decide +revert

/-- Musical interpretation of each wallpaper type. -/
def WallpaperType.musicalName : WallpaperType → String
  | .p1   => "Free rhythm (no symmetry)"
  | .p2   => "Call-and-response (2-fold rotation)"
  | .pm   => "Palindrome (mirror)"
  | .pg   => "Canon (glide reflection)"
  | .cm   => "Round (mirror + glide)"
  | .pmm  => "Bilateral palindrome (double mirror)"
  | .pmg  => "Inverted canon (mirror + glide)"
  | .pgg  => "Double canon (double glide)"
  | .cmm  => "Round + palindrome (double mirror + glide)"
  | .p4   => "4-bar cycle (4-fold rotation)"
  | .p4m  => "Variations on a theme (4-fold + mirrors)"
  | .p4g  => "Inverted variations (4-fold + glides)"
  | .p3   => "3-bar blues (3-fold rotation)"
  | .p3m1 => "3-fold + mirrors"
  | .p31m => "3-fold + glides"
  | .p6   => "Whole-tone scale symmetry (6-fold rotation)"
  | .p6m  => "Maximal symmetry (6-fold + mirrors)"

/-- The maximal rotation order of each wallpaper type. -/
def WallpaperType.maxRotationOrder : WallpaperType → ℕ
  | .p1 | .pm | .pg | .cm => 1
  | .p2 | .pmm | .pmg | .pgg | .cmm => 2
  | .p3 | .p3m1 | .p31m => 3
  | .p4 | .p4m | .p4g => 4
  | .p6 | .p6m => 6

/-
The crystallographic restriction: rotation orders in wallpaper groups
    can only be 1, 2, 3, 4, or 6. This is fundamental to crystallography.
-/
theorem crystallographic_restriction (w : WallpaperType) :
    w.maxRotationOrder ∈ ({1, 2, 3, 4, 6} : Set ℕ) := by
  cases w <;> simp +decide [ WallpaperType.maxRotationOrder ]

/-- Whether a wallpaper type has mirror symmetry. -/
def WallpaperType.hasMirror : WallpaperType → Bool
  | .pm | .cm | .pmm | .pmg | .cmm | .p4m | .p4g | .p3m1 | .p31m | .p6m => true
  | _ => false

/-- Whether a wallpaper type has glide reflection symmetry. -/
def WallpaperType.hasGlide : WallpaperType → Bool
  | .pg | .cm | .pmg | .pgg | .cmm | .p4g | .p31m | .p6m => true
  | _ => false

/-
The number of wallpaper types with mirror symmetry is 10.
-/
theorem mirror_types_count :
    (Finset.univ.filter (fun w : WallpaperType => w.hasMirror = true)).card = 10 := by
  rfl

/-
The number of wallpaper types with glide reflection is 8.
-/
theorem glide_types_count :
    (Finset.univ.filter (fun w : WallpaperType => w.hasGlide = true)).card = 8 := by
  decide +kernel

/-! ## Symmetry Lattice -/

/-- The symmetry level of each wallpaper type, encoding the containment lattice. -/
def WallpaperType.symmetryLevel : WallpaperType → ℕ
  | .p1 => 0
  | .p2 | .pm | .pg => 1
  | .cm | .pmm | .pmg | .pgg => 2
  | .cmm | .p4 | .p3 => 3
  | .p4m | .p4g | .p3m1 | .p31m => 4
  | .p6 => 5
  | .p6m => 6

/-
p6m has the highest symmetry level (maximal wallpaper group).
-/
theorem p6m_maximal_symmetry (w : WallpaperType) :
    w.symmetryLevel ≤ WallpaperType.p6m.symmetryLevel := by
  rcases w with ( _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ ) <;> decide

/-! ## Palindromic Rhythm Weight Parity

A palindromic rhythm of odd length 2k+1 has the property that its total weight
(number of onsets) has the same parity as the center beat. This is because each
non-center pair contributes an even number to the weight. -/

/-
For a palindromic rhythm of odd length, the weight parity equals the center value.
-/
theorem palindrome_center_determines_parity {k : ℕ} (f : FiniteRhythm (2 * k + 1))
    (hpal : isPalindromicFinite f) :
    (Finset.univ.filter (fun i : Fin (2 * k + 1) => f i = true)).card % 2 =
    if f ⟨k, by omega⟩ then 1 else 0 := by
  have h_symm : (Finset.univ.filter (fun i : Fin (2 * k + 1) => f i = true)).card = (Finset.univ.filter (fun i : Fin (2 * k + 1) => f i = true ∧ i.val < k)).card + (Finset.univ.filter (fun i : Fin (2 * k + 1) => f i = true ∧ i.val > k)).card + (if f ⟨k, by
    bv_omega⟩ = true then 1 else 0) := by
    rw [ ← Finset.card_union_of_disjoint, Finset.filter_union_right ];
    · rw [ show ( Finset.univ.filter fun i : Fin ( 2 * k + 1 ) => f i = true ) = Finset.univ.filter ( fun i : Fin ( 2 * k + 1 ) => f i = true ∧ ( i : ℕ ) < k ∨ f i = true ∧ ( i : ℕ ) > k ) ∪ ( if f ⟨ k, by linarith ⟩ = true then { ⟨ k, by linarith ⟩ } else ∅ ) from ?_, Finset.card_union_of_disjoint ];
      · split_ifs <;> simp +decide [ * ];
      · split_ifs <;> aesop;
      · grind +splitImp;
    · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith;
  have h_symm : (Finset.univ.filter (fun i : Fin (2 * k + 1) => f i = true ∧ i.val < k)).card = (Finset.univ.filter (fun i : Fin (2 * k + 1) => f i = true ∧ i.val > k)).card := by
    refine' Finset.card_bij ( fun i hi => Fin.mk ( 2 * k - i ) ( by
      exact Nat.lt_succ_of_le ( Nat.sub_le _ _ ) ) ) _ _ _ <;> simp_all +decide [ Fin.ext_iff ];
    · intro a ha hk; have := hpal a; simp_all +decide [ Fin.ext_iff ] ;
      omega;
    · intros; omega;
    · intro b hb hb'; use ⟨ 2 * k - b, by omega ⟩ ; simp_all +decide [ Nat.sub_sub_self ( show b.val ≤ 2 * k from by linarith [ Fin.is_lt b ] ) ] ;
      exact ⟨ by simpa [ hb, Nat.sub_sub_self ( show ( b : ℕ ) ≤ 2 * k from by linarith [ Fin.is_lt b ] ) ] using hpal b, by omega ⟩;
  split_ifs at * <;> omega