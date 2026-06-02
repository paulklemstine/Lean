/-
# Persistent Homology of Musical Harmony: The Topology of Bach

This module formalizes pitch class set theory and the circle of fifths,
providing algebraic infrastructure for studying the topology of harmonic spaces.
-/

import Mathlib

namespace PersistentHarmony

/-! ## Pitch Class Fundamentals -/

/-- A pitch class is an element of ℤ/12ℤ. -/
abbrev PitchClass := ZMod 12

/-- A pitch class set represents a chord. -/
abbrev PitchClassSet := Finset PitchClass

/-- The interval of a perfect fifth: 7 semitones. -/
def fifthStep : PitchClass := 7

/-- The tritone interval: 6 semitones. -/
def tritone : PitchClass := 6

/-- Transposition of a pitch class set by interval `t`. -/
def transpose (S : PitchClassSet) (t : PitchClass) : PitchClassSet :=
  S.image (· + t)

/-- Inversion of a pitch class set (reflection through 0). -/
def invert (S : PitchClassSet) : PitchClassSet :=
  S.image (fun x => -x)

/-- The circle of fifths: start + 7k (mod 12). -/
def circleOfFifths (start : PitchClass) (k : ℕ) : PitchClass :=
  start + fifthStep * (k : ZMod 12)

/-- The interval between two pitch classes. -/
def pitchInterval (a b : PitchClass) : PitchClass := b - a

/-! ## Circle of Fifths: Algebraic Properties -/

/-- 7 is coprime to 12. -/
theorem seven_coprime_twelve : Nat.Coprime 7 12 := by decide

/-- The tritone is its own inverse: 6 + 6 ≡ 0 (mod 12). -/
theorem tritone_self_inverse : tritone + tritone = (0 : PitchClass) := by decide

/-- Transposition preserves cardinality. -/
theorem transpose_card (S : PitchClassSet) (t : PitchClass) :
    (transpose S t).card = S.card := by
  apply Finset.card_image_of_injective
  intro a b hab
  simpa using hab

/-- Inversion preserves cardinality. -/
theorem invert_card (S : PitchClassSet) :
    (invert S).card = S.card := by
  apply Finset.card_image_of_injective
  exact neg_injective

/-! ## Hamming Distance on Chord Space -/

/-- Hamming distance between two pitch class sets. -/
def hammingDist (A B : PitchClassSet) : ℕ :=
  (A \ B).card + (B \ A).card

/-- Hamming distance is symmetric. -/
theorem hammingDist_comm (A B : PitchClassSet) :
    hammingDist A B = hammingDist B A := by
  simp [hammingDist, add_comm]

/-- Hamming distance from a set to itself is zero. -/
theorem hammingDist_self (A : PitchClassSet) :
    hammingDist A A = 0 := by
  simp [hammingDist]

/-- Hamming distance is zero iff the sets are equal. -/
theorem hammingDist_eq_zero_iff (A B : PitchClassSet) :
    hammingDist A B = 0 ↔ A = B := by
  constructor
  · intro h
    simp [hammingDist] at h
    obtain ⟨h1, h2⟩ := h
    exact h1.antisymm h2
  · rintro rfl
    exact hammingDist_self A

/-
Hamming distance satisfies the triangle inequality.
-/
theorem hammingDist_triangle (A B C : PitchClassSet) :
    hammingDist A C ≤ hammingDist A B + hammingDist B C := by
  unfold hammingDist;
  rw [ ← Finset.card_union_of_disjoint, ← Finset.card_union_of_disjoint ];
  · rw [ ← Finset.card_union_of_disjoint ];
    · exact le_trans ( Finset.card_le_card fun x hx => by by_cases hx' : x ∈ B <;> aesop ) ( Finset.card_union_le _ _ );
    · exact disjoint_sdiff_sdiff;
  · exact disjoint_sdiff_sdiff;
  · exact Finset.disjoint_left.mpr fun x hx₁ hx₂ => by aesop;

/-! ## Transposition Preserves Interval Content -/

/-- Transposition preserves the interval between any two pitch classes. -/
theorem transposition_preserves_intervals (a b t : PitchClass) :
    pitchInterval (a + t) (b + t) = pitchInterval a b := by
  simp [pitchInterval]

/-! ## Vietoris-Rips Complex for Chord Clouds -/

/-- A chord cloud: a finite collection of pitch class sets. -/
structure ChordCloud where
  chords : Finset PitchClassSet

/-- Two chords are ε-close if their Hamming distance ≤ ε. -/
def chordClose (A B : PitchClassSet) (ε : ℕ) : Prop :=
  hammingDist A B ≤ ε

/-- The Rips edge relation at scale ε. -/
def ripsEdge (cloud : ChordCloud) (ε : ℕ) (A B : PitchClassSet) : Prop :=
  A ∈ cloud.chords ∧ B ∈ cloud.chords ∧ A ≠ B ∧ chordClose A B ε

/-- The Rips graph is symmetric. -/
theorem ripsEdge_symm (cloud : ChordCloud) (ε : ℕ) (A B : PitchClassSet) :
    ripsEdge cloud ε A B → ripsEdge cloud ε B A := by
  intro ⟨hA, hB, hne, hclose⟩
  exact ⟨hB, hA, hne.symm, by rwa [chordClose, hammingDist_comm]⟩

/-- At scale 0, the Rips graph has no edges. -/
theorem ripsEdge_zero_empty (cloud : ChordCloud) (A B : PitchClassSet) :
    ¬ripsEdge cloud 0 A B := by
  intro ⟨_, _, hne, hclose⟩
  apply hne
  rw [← hammingDist_eq_zero_iff]
  unfold chordClose at hclose
  linarith [hammingDist_eq_zero_iff A B]

/-- Edges are monotone in ε. -/
theorem ripsEdge_monotone (cloud : ChordCloud) {ε₁ ε₂ : ℕ} (h : ε₁ ≤ ε₂)
    (A B : PitchClassSet) :
    ripsEdge cloud ε₁ A B → ripsEdge cloud ε₂ A B := by
  intro ⟨hA, hB, hne, hclose⟩
  exact ⟨hA, hB, hne, le_trans hclose h⟩

/-! ## Persistence Bars -/

/-- A persistence bar with birth ≤ death. -/
structure PersistenceBar where
  birth : ℕ
  death : ℕ
  h_valid : birth ≤ death

/-- The persistence (lifetime) of a bar. -/
def PersistenceBar.persistence (bar : PersistenceBar) : ℕ :=
  bar.death - bar.birth

/-- Edge birth equals Hamming distance. -/
def edgeBirth (A B : PitchClassSet) : ℕ := hammingDist A B

/-- Edge birth is symmetric. -/
theorem edgeBirth_comm (A B : PitchClassSet) :
    edgeBirth A B = edgeBirth B A := hammingDist_comm A B

/-! ## Circle of Fifths Chord Progressions -/

/-- A major triad built on a root pitch class: {root, root+4, root+7}. -/
def majorTriad (root : PitchClass) : PitchClassSet :=
  {root, root + 4, root + 7}

/-- A minor triad: {root, root+3, root+7}. -/
def minorTriad (root : PitchClass) : PitchClassSet :=
  {root, root + 3, root + 7}

/-- A chord progression following the circle of fifths with major triads. -/
def fifthsProgression (r : PitchClass) (k : ℕ) : PitchClassSet :=
  majorTriad (circleOfFifths r k)

/-- Adjacent chords in the circle of fifths share a common tone:
    the fifth of chord k equals the root of chord k+1. -/
theorem common_tone_fifths (r : PitchClass) (k : ℕ) :
    ∃ p : PitchClass, p ∈ fifthsProgression r k ∧ p ∈ fifthsProgression r (k + 1) := by
  use circleOfFifths r k + 7
  refine ⟨?_, ?_⟩
  · simp [fifthsProgression, majorTriad]
  · simp only [fifthsProgression, majorTriad, circleOfFifths, fifthStep]
    simp only [Finset.mem_insert, Finset.mem_singleton]
    left
    push_cast
    ring

/-! ## Fourier Analysis on Pitch Classes -/

/-- The DFT magnitude squared of a PCS at frequency `freq`. -/
noncomputable def fourierMagnitudeSq (S : PitchClassSet) (freq : ℕ) : ℝ :=
  let cosSum := S.sum fun p => Real.cos (2 * Real.pi * (p.val * freq : ℕ) / 12)
  let sinSum := S.sum fun p => Real.sin (2 * Real.pi * (p.val * freq : ℕ) / 12)
  cosSum ^ 2 + sinSum ^ 2

/-
The 0-th Fourier coefficient squared equals the cardinality squared.
-/
theorem fourier_zero_eq_card_sq (S : PitchClassSet) :
    fourierMagnitudeSq S 0 = (S.card : ℝ) ^ 2 := by
  unfold fourierMagnitudeSq; aesop;

/-! ## The Circularization Theorem -/

/-- The circle of fifths has period 12. -/
theorem circleOfFifths_period (start : PitchClass) :
    circleOfFifths start 12 = start := by
  simp [circleOfFifths, fifthStep]
  decide

/-
The circle of fifths visits distinct pitch classes for steps 0..11.
-/
theorem circleOfFifths_injective_mod12 (start : PitchClass)
    {i j : ℕ} (hi : i < 12) (hj : j < 12) (hij : i ≠ j) :
    circleOfFifths start i ≠ circleOfFifths start j := by
  interval_cases i <;> interval_cases j <;> simp +decide [ circleOfFifths ] at hij ⊢

/-
The circle of fifths is surjective: every pitch class is visited.
-/
theorem circleOfFifths_surjective (start : PitchClass) (target : PitchClass) :
    ∃ k : ℕ, k < 12 ∧ circleOfFifths start k = target := by
  revert target start
  decide +revert

/-! ## Harmonic Complexity: Topological Invariants -/

/-- The number of distinct Hamming distances in a chord cloud. -/
noncomputable def distinctDistances (cloud : ChordCloud) : ℕ :=
  (Finset.image (fun p : PitchClassSet × PitchClassSet =>
    hammingDist p.1 p.2) (cloud.chords ×ˢ cloud.chords)).card

/-- The transposition of an entire chord cloud. -/
def transposeCloud (cloud : ChordCloud) (t : PitchClass) : ChordCloud where
  chords := cloud.chords.image (fun S => transpose S t)

/-
Transposition preserves Hamming distance: it is an isometry of chord space.
-/
theorem transpose_preserves_hammingDist (A B : PitchClassSet) (t : PitchClass) :
    hammingDist (transpose A t) (transpose B t) = hammingDist A B := by
  unfold hammingDist;
  rw [ show transpose A t \ transpose B t = Finset.image ( fun x : PitchClass => x + t ) ( A \ B ) from ?_, show transpose B t \ transpose A t = Finset.image ( fun x : PitchClass => x + t ) ( B \ A ) from ?_ ];
  · rw [ Finset.card_image_of_injective, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
  · ext; simp [transpose];
  · unfold transpose; aesop;

end PersistentHarmony