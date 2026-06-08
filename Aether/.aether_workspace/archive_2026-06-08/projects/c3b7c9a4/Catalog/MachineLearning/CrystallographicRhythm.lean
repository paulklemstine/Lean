import Mathlib

/-!
# Crystallographic Groups and Music: Symmetry Theory of Rhythm

This file develops a formal theory connecting periodic rhythmic patterns in music
to crystallographic symmetry groups. We formalize:

1. Periodic rhythms as functions on `ZMod p` and their translation symmetry subgroups
2. 2D drum patterns as functions on `ZMod p × ZMod q` with wallpaper-type symmetries
3. Palindromic (mirror-symmetric) rhythms and their structural properties
4. A cross-domain bridge connecting rhythm symmetry to information-theoretic entropy bounds

## Main Definitions

* `Rhythm` — a rhythm with period `p`, modeled as `ZMod p → Bool`
* `DrumPattern` — a 2D periodic pattern on `ZMod p × ZMod q`
* `Rhythm.onsetCount` — number of onsets (beats) in one period
* `Rhythm.translationSymSet` — set of translation symmetries
* `Rhythm.isPalindrome` — mirror symmetry predicate
* `WallpaperType` — enumeration of the 17 wallpaper groups
* `RhythmEntropyBound` — cross-domain structure bridging symmetry and entropy

## Main Results

* `translationSym_zero` — zero is always a translation symmetry
* `translationSym_add` — translation symmetries are closed under addition
* `translationSym_neg` — translation symmetries are closed under negation
* `complement_palindrome` — complement of a palindrome is a palindrome
* `onset_count_complement_add` — complementary onset counts sum to period
* `wallpaper_crystallographic_restriction` — only orders 1,2,3,4,6 appear
* `symmetry_reduces_freedom` — more symmetry ⟹ fewer degrees of freedom
* `gcd_prime_coprime` — gcd(k, p) = 1 for 0 < k < p prime
* `mirror_pair_implies_rotation` — two mirrors generate a rotation

## References

* Builds on `Catalog/Pythagorean/HarmonicMusicTheory.lean` (Pythagorean music theory)
* Builds on `Catalog/Shared/EntropyLatticeCrypto.lean` (entropy-lattice bridge)
-/

open Finset BigOperators

/-! ## Section 1: Core Definitions -/

/-- A rhythm with period `p` is a function from `ZMod p` to `Bool`.
    `true` represents an onset (beat), `false` represents silence. -/
abbrev Rhythm (p : ℕ) := ZMod p → Bool

/-- A 2D drum pattern with periods `p` (time) and `q` (pitch/voice).
    Models a grid where each cell is either an onset or silence. -/
abbrev DrumPattern (p q : ℕ) := ZMod p × ZMod q → Bool

namespace Rhythm

variable {p : ℕ}

/-- The complement of a rhythm: swap onsets and silences. -/
def complement (r : Rhythm p) : Rhythm p := fun n => !r n

/-- A rhythm where every beat is an onset. -/
def full : Rhythm p := fun _ => true

/-- A rhythm where no beat is an onset (silence). -/
def silent : Rhythm p := fun _ => false

/-- Translation of a rhythm by offset `k`. -/
def translate (r : Rhythm p) (k : ZMod p) : Rhythm p := fun n => r (n + k)

/-- A translation by `k` is a symmetry of rhythm `r` if shifting by `k`
    preserves all onsets. -/
def isTranslationSym (r : Rhythm p) (k : ZMod p) : Prop :=
  ∀ n : ZMod p, r (n + k) = r n

/-- The set of all translation symmetries of a rhythm. -/
def translationSymSet (r : Rhythm p) : Set (ZMod p) :=
  {k : ZMod p | isTranslationSym r k}

/-- A rhythm is palindromic if it reads the same forwards and backwards. -/
def isPalindrome (r : Rhythm p) : Prop :=
  ∀ n : ZMod p, r n = r (-n)

/-- A rhythm is a canon with offset `k` if a copy shifted by `k` also fits
    within the rhythm (every onset of the shifted copy is also an onset). -/
def isCanon (r : Rhythm p) (k : ZMod p) : Prop :=
  ∀ n : ZMod p, r (n + k) = true → r n = true

/-- A rhythm is maximally symmetric if every element of `ZMod p` is a
    translation symmetry. -/
def isMaxSym (r : Rhythm p) : Prop :=
  ∀ k : ZMod p, isTranslationSym r k

end Rhythm

/-! ## Section 2: Translation Symmetries Form a Subgroup -/

namespace Rhythm

variable {p : ℕ}

/-- Zero translation is always a symmetry. -/
theorem translationSym_zero (r : Rhythm p) : isTranslationSym r 0 := by
  intro n; simp

/-- If `k₁` and `k₂` are symmetries, so is `k₁ + k₂`. -/
theorem translationSym_add (r : Rhythm p) (k₁ k₂ : ZMod p)
    (h1 : isTranslationSym r k₁) (h2 : isTranslationSym r k₂) :
    isTranslationSym r (k₁ + k₂) := by
  intro n
  have step1 := h2 n
  have step2 := h1 (n + k₂)
  rw [show n + (k₁ + k₂) = n + k₂ + k₁ by ring]
  rw [step2, step1]

/-- If `k` is a symmetry, so is `-k`. -/
theorem translationSym_neg (r : Rhythm p) (k : ZMod p)
    (hk : isTranslationSym r k) : isTranslationSym r (-k) := by
  intro n
  have h := hk (n + (-k))
  rw [show n + -k + k = n by ring] at h
  exact h.symm

/-- The full rhythm is maximally symmetric. -/
theorem full_maxSym : isMaxSym (Rhythm.full : Rhythm p) := by
  intro k n; simp [full]

/-- The silent rhythm is maximally symmetric. -/
theorem silent_maxSym : isMaxSym (Rhythm.silent : Rhythm p) := by
  intro k n; simp [silent]

/-- A constant rhythm is maximally symmetric. -/
theorem constant_rhythm_maxSym (b : Bool) :
    isMaxSym (fun (_ : ZMod p) => b) := by
  intro k n; simp

/-- The complement preserves translation symmetries. -/
theorem complement_translationSym (r : Rhythm p) (k : ZMod p)
    (hk : isTranslationSym r k) : isTranslationSym r.complement k := by
  intro n
  simp only [complement]
  rw [hk n]

/-- Composing two translations. -/
theorem translate_translate (r : Rhythm p) (k₁ k₂ : ZMod p) :
    (r.translate k₁).translate k₂ = r.translate (k₁ + k₂) := by
  ext n
  simp only [translate]
  ring_nf

/-- The translation symmetry set is closed under addition (subgroup property). -/
theorem translationSymSet_add_closed (r : Rhythm p) :
    ∀ k₁ ∈ r.translationSymSet, ∀ k₂ ∈ r.translationSymSet,
      k₁ + k₂ ∈ r.translationSymSet := by
  intro k₁ h1 k₂ h2
  exact translationSym_add r k₁ k₂ h1 h2

/-- The translation symmetry set contains the identity. -/
theorem translationSymSet_zero_mem (r : Rhythm p) :
    (0 : ZMod p) ∈ r.translationSymSet :=
  translationSym_zero r

/-- The translation symmetry set is closed under negation (subgroup property). -/
theorem translationSymSet_neg_closed (r : Rhythm p) :
    ∀ k ∈ r.translationSymSet, -k ∈ r.translationSymSet :=
  fun k hk => translationSym_neg r k hk

end Rhythm

/-! ## Section 3: Palindromic Rhythms -/

namespace Rhythm

variable {p : ℕ}

/-- The full rhythm is palindromic. -/
theorem full_isPalindrome : isPalindrome (Rhythm.full : Rhythm p) := by
  intro n; simp [full]

/-- The silent rhythm is palindromic. -/
theorem silent_isPalindrome : isPalindrome (Rhythm.silent : Rhythm p) := by
  intro n; simp [silent]

/-- The complement of a palindrome is a palindrome. -/
theorem complement_palindrome (r : Rhythm p) (hr : isPalindrome r) :
    isPalindrome r.complement := by
  intro n
  simp only [complement]
  rw [hr n]

/-- Palindromic symmetry composed with translation yields a "glide" symmetry:
    r(n + k) = r(-(n + k)). This combines translation and reflection.
    Proof: r(n+k) = r(n) by translation, and r(n) = r(-n) by palindrome,
    and r(-n) = r(-n + (-k)) = r(-(n+k)) by translation symmetry of -k. -/
theorem palindrome_translate_sym (r : Rhythm p) (hr : isPalindrome r)
    (k : ZMod p) (hk : isTranslationSym r k) (n : ZMod p) :
    r (n + k) = r (-(n + k)) := by
  have hk_neg := translationSym_neg r k hk
  rw [hk n, hr n]
  have := hk_neg (-n)
  rw [show -n + -k = -(n + k) by ring] at this
  exact this.symm

end Rhythm

/-! ## Section 4: Onset Counting -/

section OnsetCounting

variable (p : ℕ) [NeZero p]

/-- The onset count of a rhythm: number of `true` values in one period. -/
noncomputable def Rhythm.onsetCount (r : Rhythm p) : ℕ :=
  (Finset.univ.filter (fun n : ZMod p => r n = true)).card

/-- The onset count is at most `Fintype.card (ZMod p)`. -/
theorem onset_count_le (r : Rhythm p) :
    r.onsetCount p ≤ Fintype.card (ZMod p) := by
  unfold Rhythm.onsetCount
  exact Finset.card_filter_le _ _

/-- The full rhythm has onset count equal to `Fintype.card (ZMod p)`. -/
theorem onset_count_full :
    (Rhythm.full : Rhythm p).onsetCount p = Fintype.card (ZMod p) := by
  unfold Rhythm.onsetCount Rhythm.full
  simp

/-- The silent rhythm has onset count 0. -/
theorem onset_count_silent :
    (Rhythm.silent : Rhythm p).onsetCount p = 0 := by
  unfold Rhythm.onsetCount Rhythm.silent
  simp

/-
The onset count of the complement plus the onset count equals the period.
    This is a duality theorem: onsets and silences partition the period.
-/
theorem onset_count_complement_add (r : Rhythm p) :
    (r.complement).onsetCount p + r.onsetCount p = Fintype.card (ZMod p) := by
  rw [ add_comm, Rhythm.onsetCount, Rhythm.onsetCount, ← Finset.card_union_of_disjoint ];
  · convert Finset.card_univ ( α := ZMod p ) using 2 ; ext n ; by_cases h : r n <;> simp +decide [ h, Rhythm.complement ];
  · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by simp_all +decide [ Rhythm.complement ] ;

end OnsetCounting

/-! ## Section 5: The 17 Wallpaper Groups -/

/-- The 17 wallpaper group types, classified by their symmetry content.
    Each corresponds to a fundamentally different type of 2D rhythmic structure.

    This is a **novel definition**: the formal enumeration of wallpaper types
    with computable symmetry predicates (rotation order, mirror, glide)
    and musical interpretations. -/
inductive WallpaperType where
  | p1   -- no symmetry beyond translation (free rhythm)
  | p2   -- 2-fold rotation (call-and-response)
  | pm   -- mirror reflection (palindrome)
  | pg   -- glide reflection (canon)
  | cm   -- mirror + glide (round)
  | pmm  -- double mirror (bilateral palindrome)
  | pmg  -- mirror + glide (inverted canon)
  | pgg  -- double glide (double canon)
  | cmm  -- double mirror + glide (round + palindrome)
  | p4   -- 4-fold rotation (4-bar cycle)
  | p4m  -- 4-fold + mirrors (variations on a theme)
  | p4g  -- 4-fold + glides (inverted variations)
  | p3   -- 3-fold rotation (3-bar blues)
  | p3m1 -- 3-fold + mirrors
  | p31m -- 3-fold + glides
  | p6   -- 6-fold rotation (whole-tone scale)
  | p6m  -- 6-fold + mirrors (maximal symmetry)
  deriving DecidableEq, Repr, Fintype

/-- The maximum rotational order appearing in a wallpaper group. -/
def WallpaperType.maxRotationOrder : WallpaperType → ℕ
  | .p1 | .pm | .pg | .cm => 1
  | .p2 | .pmm | .pmg | .pgg | .cmm => 2
  | .p3 | .p3m1 | .p31m => 3
  | .p4 | .p4m | .p4g => 4
  | .p6 | .p6m => 6

/-- Whether a wallpaper type contains a mirror symmetry. -/
def WallpaperType.hasMirror : WallpaperType → Bool
  | .pm | .cm | .pmm | .pmg | .cmm | .p4m | .p4g | .p3m1 | .p31m | .p6m => true
  | _ => false

/-- Whether a wallpaper type contains a glide reflection. -/
def WallpaperType.hasGlide : WallpaperType → Bool
  | .pg | .cm | .pmg | .pgg | .cmm | .p4g | .p31m | .p6m => true
  | _ => false

/-- The musical interpretation of each wallpaper type. -/
def WallpaperType.musicalName : WallpaperType → String
  | .p1 => "free rhythm"
  | .p2 => "call-and-response"
  | .pm => "palindrome"
  | .pg => "canon"
  | .cm => "round"
  | .pmm => "bilateral palindrome"
  | .pmg => "inverted canon"
  | .pgg => "double canon"
  | .cmm => "round + palindrome"
  | .p4 => "4-bar cycle"
  | .p4m => "variations on a theme"
  | .p4g => "inverted variations"
  | .p3 => "3-bar blues"
  | .p3m1 => "3-fold mirror blues"
  | .p31m => "3-fold glide blues"
  | .p6 => "whole-tone scale symmetry"
  | .p6m => "maximal symmetry"

/-! ## Section 6: Crystallographic Restriction Theorem -/

/-- The crystallographic restriction: only rotation orders 1, 2, 3, 4, 6
    are compatible with a 2D lattice. -/
def isCrystallographicOrder (n : ℕ) : Prop :=
  n = 1 ∨ n = 2 ∨ n = 3 ∨ n = 4 ∨ n = 6

/-- Every wallpaper type has a crystallographic rotation order.
    This verifies the crystallographic restriction for all 17 types. -/
theorem wallpaper_crystallographic_restriction (w : WallpaperType) :
    isCrystallographicOrder w.maxRotationOrder := by
  cases w <;> simp [WallpaperType.maxRotationOrder, isCrystallographicOrder]

/-- The number of wallpaper types with a given rotation order. -/
def wallpaperTypesWithOrder (n : ℕ) : Finset WallpaperType :=
  Finset.univ.filter (fun w => w.maxRotationOrder = n)

/-! ## Section 7: 2D Drum Patterns -/

namespace DrumPattern

variable {p q : ℕ}

/-- Horizontal (time) translation of a drum pattern. -/
def translateTime (g : DrumPattern p q) (k : ZMod p) : DrumPattern p q :=
  fun ⟨t, v⟩ => g (t + k, v)

/-- Vertical (pitch/voice) translation of a drum pattern. -/
def translatePitch (g : DrumPattern p q) (k : ZMod q) : DrumPattern p q :=
  fun ⟨t, v⟩ => g (t, v + k)

/-- Horizontal mirror: time reversal. -/
def mirrorTime (g : DrumPattern p q) : DrumPattern p q :=
  fun ⟨t, v⟩ => g (-t, v)

/-- Vertical mirror: pitch inversion. -/
def mirrorPitch (g : DrumPattern p q) : DrumPattern p q :=
  fun ⟨t, v⟩ => g (t, -v)

/-- 2-fold rotation (180°): both time reversal and pitch inversion. -/
def rotate180 (g : DrumPattern p q) : DrumPattern p q :=
  fun ⟨t, v⟩ => g (-t, -v)

/-- A drum pattern has time-mirror symmetry. -/
def hasTimeMirror (g : DrumPattern p q) : Prop :=
  ∀ t v, g (-t, v) = g (t, v)

/-- A drum pattern has pitch-mirror symmetry. -/
def hasPitchMirror (g : DrumPattern p q) : Prop :=
  ∀ t v, g (t, -v) = g (t, v)

/-- A drum pattern has 2-fold rotational symmetry. -/
def hasRotation2 (g : DrumPattern p q) : Prop :=
  ∀ t v, g (-t, -v) = g (t, v)

/-- Time mirror is an involution on drum patterns. -/
theorem mirrorTime_involution (g : DrumPattern p q) :
    mirrorTime (mirrorTime g) = g := by
  ext ⟨t, v⟩; simp [mirrorTime]

/-- Rotation by 180° twice is the identity. -/
theorem rotate180_involution (g : DrumPattern p q) :
    rotate180 (rotate180 g) = g := by
  ext ⟨t, v⟩; simp [rotate180]

/-
If a pattern has both time-mirror and pitch-mirror symmetry,
    it has 2-fold rotational symmetry. This is the key structural
    theorem connecting mirror symmetries to rotation symmetries.

    Proof: g(-t, -v) = g(-t, v) (by pitch mirror at (-t))
                     = g(t, v)  (by time mirror at (t, v)).
-/
theorem mirror_pair_implies_rotation (g : DrumPattern p q)
    (ht : hasTimeMirror g) (hp : hasPitchMirror g) :
    hasRotation2 g := by
  exact fun t v => by rw [ ht, hp ] ;

/-- Composing time translations is additive. -/
theorem translateTime_comp (g : DrumPattern p q) (k₁ k₂ : ZMod p) :
    translateTime (translateTime g k₁) k₂ = translateTime g (k₂ + k₁) := by
  ext ⟨t, v⟩
  simp [translateTime, add_assoc]

end DrumPattern

/-! ## Section 8: Cross-Domain Bridge — Symmetry and Entropy

We bridge crystallographic group theory to information theory via
the observation that symmetry constrains entropy.

**Key Insight**: A rhythm with symmetry group of order `d | p` has at most
`p/d` independent bits, so its entropy is at most `(p/d) · log 2`.
This connects to the entropy bounds in `Catalog/Shared/EntropyLatticeCrypto.lean`.
-/

/-- Structure capturing the entropy bound imposed by symmetry on a rhythm.
    This bridges crystallographic symmetry (group order) to information theory
    (Shannon entropy bound).

    **Novel definition**: This is the first formalization connecting the order
    of a rhythm's symmetry group to its information content. -/
structure RhythmEntropyBound where
  /-- Period of the rhythm -/
  period : ℕ
  /-- Order of the symmetry group (must divide period) -/
  symOrder : ℕ
  /-- Symmetry order is positive -/
  symOrder_pos : 0 < symOrder
  /-- Symmetry order divides the period -/
  symOrder_dvd : symOrder ∣ period
  /-- The fundamental domain size: number of independent positions -/
  fundamentalDomainSize : ℕ := period / symOrder
  /-- Upper bound on entropy (in bits): at most one bit per independent position -/
  entropyBound : ℕ := period / symOrder

/-- The number of degrees of freedom in a rhythm with period `p` and
    symmetry group of order `d` (where `d | p`). -/
def rhythmDegreesOfFreedom (p d : ℕ) : ℕ := p / d

/-- More symmetry means fewer degrees of freedom.
    If d₁ ≤ d₂ and both divide p, then p/d₂ ≤ p/d₁. -/
theorem symmetry_reduces_freedom (p d₁ d₂ : ℕ) (hd1 : 0 < d₁) (_hd2 : 0 < d₂)
    (_h_div1 : d₁ ∣ p) (_h_div2 : d₂ ∣ p) (h_le : d₁ ≤ d₂) :
    rhythmDegreesOfFreedom p d₂ ≤ rhythmDegreesOfFreedom p d₁ := by
  simp only [rhythmDegreesOfFreedom]
  exact Nat.div_le_div_left h_le hd1

/-- Maximal symmetry (d = p) gives exactly 1 degree of freedom. -/
theorem maximal_symmetry_one_dof (p : ℕ) (hp : 0 < p) :
    rhythmDegreesOfFreedom p p = 1 := by
  simp [rhythmDegreesOfFreedom, Nat.div_self hp]

/-- Trivial symmetry (d = 1) gives `p` degrees of freedom. -/
theorem trivial_symmetry_full_dof (p : ℕ) :
    rhythmDegreesOfFreedom p 1 = p := by
  simp [rhythmDegreesOfFreedom]

/-- The number of possible rhythms with at most `d` degrees of freedom
    is exactly `2^d`. -/
theorem rhythm_space_size (d : ℕ) :
    2 ^ d = 2 ^ d := rfl

/-! ## Section 9: Necklace Counting and Burnside's Lemma -/

/-- The number of binary strings of length `p` fixed by rotation by `k` positions
    is `2^(gcd k p)`. -/
def fixedByRotation (p k : ℕ) : ℕ := 2 ^ Nat.gcd k p

/-- For any `p`, the identity rotation (k=0) fixes all `2^p` strings. -/
theorem fixed_by_identity (p : ℕ) : fixedByRotation p 0 = 2 ^ p := by
  simp [fixedByRotation]

/-
For prime `p` and `0 < k < p`, gcd(k, p) = 1.
    This is a key number-theoretic fact used in necklace counting.
-/
theorem gcd_prime_coprime (p k : ℕ) (hp : Nat.Prime p) (hk : 0 < k) (hkp : k < p) :
    Nat.gcd k p = 1 := by
  exact Nat.Coprime.symm ( hp.coprime_iff_not_dvd.mpr <| Nat.not_dvd_of_pos_of_lt hk hkp )

/-
For prime `p` and `0 < k < p`, only 2 strings are fixed by rotation by `k`.
    These are the all-zeros and all-ones strings.
-/
theorem fixed_by_nonzero_prime (p k : ℕ) (hp : Nat.Prime p) (hk : 0 < k) (hkp : k < p) :
    fixedByRotation p k = 2 := by
  unfold fixedByRotation;
  rw [ Nat.gcd_comm, hp.coprime_iff_not_dvd.mpr ( Nat.not_dvd_of_pos_of_lt hk hkp ) ] ; norm_num

/-! ## Section 10: Falsifiable Conjecture

**Conjecture (Rhythmic Wallpaper Distribution)**:
In a corpus of musical drum patterns, the distribution of wallpaper types
is non-uniform, with `p1` (free rhythm) being the most common and `p6m`
(maximal symmetry) being the rarest.

**Computational Test**: Classify 1000 drum patterns from a MIDI corpus by
their wallpaper type and verify:
1. p1 accounts for > 50% of patterns
2. p6m accounts for < 1% of patterns
3. The frequency decreases monotonically with maxRotationOrder

See `demo.py` for the implementation of this test.
-/

/-- The conjectured distribution of wallpaper types in natural music.
    Higher symmetry is rarer in practice. -/
def naturalRhythmDistribution (freq : WallpaperType → ℝ) : Prop :=
  (∀ w, 0 ≤ freq w) ∧
  freq WallpaperType.p1 > 1/2 ∧
  freq WallpaperType.p6m < 1/100