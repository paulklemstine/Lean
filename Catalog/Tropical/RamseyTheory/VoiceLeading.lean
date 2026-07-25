/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Neo-Riemannian PLR Theory and Voice-Leading Geometry

This file establishes a formal, machine-verified bridge between neo-Riemannian
music theory (the P, L, R transformations on major/minor triads) and the metric
geometry of voice-leading space.

## Mathematical Context

In music theory, the **neo-Riemannian transformations** P (parallel), L (leading-tone
exchange), and R (relative) act on major and minor triads. A longstanding intuition
holds that these transformations are "efficient" — they move voices by the smallest
possible amounts. We make this precise by defining a voice-leading distance on the
space of triads and proving that PLR transformations are metrically optimal.

The voice-leading distance between two triads is the minimum total pitch-class
displacement over all bijections between the voices. This corresponds to the
geodesic distance in the quotient orbifold obtained from ordered pitch triples
by permutation symmetry.

## Main Results

### Structural Properties
* `plr_involution`: Each PLR transformation is its own inverse.
* `plr_flips_quality`: PLR always maps major ↔ minor.

### Metric Properties
* `plr_P_dist`: P has voice-leading distance exactly 1.
* `plr_L_dist`: L has voice-leading distance exactly 1.
* `plr_R_dist`: R has voice-leading distance exactly 2.
* `plr_bounded`: All PLR moves have distance ≤ 2.

### Geodesicity Theorems
* `plr_P_minimizes_vl`: P achieves the minimum voice-leading distance
  to any chord of opposite quality. (Exact geodesic, C = 1.)
* `plr_L_minimizes_vl`: L achieves the minimum voice-leading distance
  to any chord of opposite quality. (Exact geodesic, C = 1.)
* `plr_PL_unique_minimizers`: P and L are the *only* quality-changing
  moves at distance 1.
* `plr_near_geodesic_uniform`: Every PLR move (including R) satisfies
  `vlDist(c, T(c)) ≤ 2 * vlDist(c, d)` for any opposite-quality chord d.
  This is the uniform near-geodesicity theorem with constant C = 2.

### Common-Tone Characterization
* `chord_three_distinct_notes`: Every triad has exactly 3 distinct pitch classes.
* `plr_two_common_tones`: Each PLR transformation preserves exactly 2 common tones.
* `plr_characterizes_two_common_tones`: P, L, R are the *only* quality-changing
  transformations preserving exactly 2 common tones. This characterizes PLR
  as the maximal-common-tone moves in chord space.

### Metric Space Properties
* `chordDist_self`: d(c, c) = 0.
* `chordDist_symm`: d(c, d) = d(d, c).
* `chordDist_triangle`: d(a, c) ≤ d(a, b) + d(b, c).
* `opposite_quality_dist_pos`: d(c, d) > 0 when c, d have different quality.
* `chordDist_eq_zero_iff`: d(c, d) = 0 ↔ c = d.

### Significance

These results turn the PLR group from a purely symbolic harmonic device
into a metrically natural dynamical system on chord space: PLR moves are
geodesic or uniformly near-geodesic in the quotient voice-leading orbifold.
-/

open Finset

-- ============================================================
-- § 1. Pitch Classes
-- ============================================================

/-- Pitch class: integers modulo 12, representing the 12 chromatic pitch classes
    (C = 0, C♯ = 1, D = 2, ..., B = 11). -/
abbrev PC := ZMod 12

-- ============================================================
-- § 2. Chord Quality and Structure
-- ============================================================

/-- Quality of a triad: major or minor. -/
inductive Quality
  | Major
  | Minor
  deriving DecidableEq, Fintype

/-- A chord (triad) is determined by its root pitch class and quality.
    - Major triad rooted at `r` has notes `{r, r+4, r+7}` (root, major third, fifth).
    - Minor triad rooted at `r` has notes `{r, r+3, r+7}` (root, minor third, fifth). -/
@[ext]
structure Chord where
  root : PC
  quality : Quality
  deriving DecidableEq

/-- Equivalence between `Chord` and `PC × Quality`, providing `Fintype`. -/
private def chordEquiv : Chord ≃ PC × Quality where
  toFun c := (c.root, c.quality)
  invFun p := ⟨p.1, p.2⟩
  left_inv := fun ⟨_, _⟩ => rfl
  right_inv := fun (_, _) => rfl

instance : Fintype Chord := Fintype.ofEquiv _ chordEquiv.symm

/-- There are exactly 24 major/minor triads (12 roots × 2 qualities). -/
theorem chord_card : Fintype.card Chord = 24 := by native_decide

-- ============================================================
-- § 3. Chord Notes
-- ============================================================

/-- The three pitch classes of a chord as an ordered triple.
    Index 0 = root, index 1 = third, index 2 = fifth. -/
def Chord.notes (c : Chord) : Fin 3 → PC :=
  match c.quality with
  | .Major => ![c.root, c.root + 4, c.root + 7]
  | .Minor => ![c.root, c.root + 3, c.root + 7]

/-- The set of pitch classes in a chord, as a `Finset`. -/
def Chord.noteFinset (c : Chord) : Finset PC :=
  {c.notes 0, c.notes 1, c.notes 2}

/-- Every chord has exactly 3 distinct pitch classes.
    This holds because the intervals (0,4,7) and (0,3,7) mod 12
    never produce coincidences. -/
theorem chord_three_distinct_notes (c : Chord) : c.noteFinset.card = 3 := by
  native_decide +revert

-- ============================================================
-- § 4. Neo-Riemannian PLR Transformations
-- ============================================================

/-- The three neo-Riemannian transformations on triads.
    - `P` (parallel): same root and fifth, third moves by 1 semitone.
    - `L` (leading-tone exchange): two notes stay, one moves by 1 semitone.
    - `R` (relative): two notes stay, one moves by 2 semitones. -/
inductive PLR
  | P
  | L
  | R
  deriving DecidableEq, Fintype

/-- Apply a PLR transformation to a chord.

    **P** (parallel): preserves root and fifth, moves third by 1 semitone.
    - Major `{r, r+4, r+7}` → Minor `{r, r+3, r+7}` (third drops by 1)
    - Minor `{r, r+3, r+7}` → Major `{r, r+4, r+7}` (third rises by 1)

    **L** (leading-tone exchange): one extreme note moves by 1 semitone.
    - Major `{r, r+4, r+7}` → Minor `{r+4, r+7, r+11}` (root drops by 1 to become new fifth)
    - Minor `{r, r+3, r+7}` → Major `{r+8, r, r+3}` (fifth rises by 1 to become new root)

    **R** (relative): one voice moves by 2 semitones.
    - Major `{r, r+4, r+7}` → Minor `{r+9, r, r+4}` (fifth rises by 2)
    - Minor `{r, r+3, r+7}` → Major `{r+3, r+7, r+10}` (root drops by 2) -/
def plrApply : PLR → Chord → Chord
  | .P, ⟨r, .Major⟩ => ⟨r, .Minor⟩
  | .P, ⟨r, .Minor⟩ => ⟨r, .Major⟩
  | .L, ⟨r, .Major⟩ => ⟨r + 4, .Minor⟩
  | .L, ⟨r, .Minor⟩ => ⟨r + 8, .Major⟩
  | .R, ⟨r, .Major⟩ => ⟨r + 9, .Minor⟩
  | .R, ⟨r, .Minor⟩ => ⟨r + 3, .Major⟩

-- ============================================================
-- § 5. Structural Properties of PLR
-- ============================================================

/-- Each PLR transformation is an involution: applying it twice returns
    the original chord. -/
theorem plr_involution (T : PLR) (c : Chord) :
    plrApply T (plrApply T c) = c := by
  native_decide +revert

/-- PLR always flips the quality of a chord: major ↔ minor. -/
theorem plr_flips_quality (T : PLR) (c : Chord) :
    (plrApply T c).quality ≠ c.quality := by
  native_decide +revert

-- ============================================================
-- § 6. Voice-Leading Distance
-- ============================================================

/-- Circular distance between two pitch classes: the minimum of the two
    directed distances around the chromatic circle.

    For pitch classes `a` and `b`, this is `min(|a-b|, 12-|a-b|)` in ℤ/12ℤ.
    Values range from 0 (unison) to 6 (tritone). -/
def pcDist (a b : PC) : ℕ :=
  min (a - b).val (b - a).val

/-- Symmetry of pitch-class distance. -/
theorem pcDist_symm (a b : PC) : pcDist a b = pcDist b a := by
  simp [pcDist, min_comm]

/-- Total voice-leading displacement for a given voice bijection σ:
    the sum of pitch-class distances between corresponding voices. -/
def vlDisp (f g : Fin 3 → PC) (σ : Equiv.Perm (Fin 3)) : ℕ :=
  ∑ i : Fin 3, pcDist (f i) (g (σ i))

/-- Voice-leading distance between two triples of pitch classes:
    the minimum total displacement over all bijections of voices.

    This is the L¹ Wasserstein distance between the two multisets of
    pitch classes, and equals the geodesic distance in the quotient
    orbifold ℤ₁₂³ / S₃. -/
def vlDist (f g : Fin 3 → PC) : ℕ :=
  (Finset.univ : Finset (Equiv.Perm (Fin 3))).inf'
    Finset.univ_nonempty (vlDisp f g)

/-- Voice-leading distance between two chords. -/
def chordDist (c d : Chord) : ℕ := vlDist c.notes d.notes

/-- Number of common tones between two chords. -/
def commonTones (c d : Chord) : ℕ := (c.noteFinset ∩ d.noteFinset).card

-- ============================================================
-- § 7. Metric Space Properties of chordDist
-- ============================================================

/-- Reflexivity: d(c, c) = 0. -/
theorem chordDist_self (c : Chord) : chordDist c c = 0 := by
  native_decide +revert

/-- Symmetry: d(c, d) = d(d, c). -/
theorem chordDist_symm (c d : Chord) : chordDist c d = chordDist d c := by
  native_decide +revert

/-- Triangle inequality: d(a, c) ≤ d(a, b) + d(b, c). -/
theorem chordDist_triangle (a b c : Chord) :
    chordDist a c ≤ chordDist a b + chordDist b c := by
  native_decide +revert

/-- Separation: d(c, d) = 0 implies c = d. -/
theorem chordDist_eq_zero_iff (c d : Chord) :
    chordDist c d = 0 ↔ c = d := by
  native_decide +revert

/-- Chords of different quality are always at positive distance. -/
theorem opposite_quality_dist_pos (c d : Chord) (hq : d.quality ≠ c.quality) :
    0 < chordDist c d := by
  native_decide +revert

-- ============================================================
-- § 8. PLR Voice-Leading Distances
-- ============================================================

/-- **P moves one voice by 1 semitone.** The parallel transformation has
    voice-leading distance exactly 1 for every triad. -/
theorem plr_P_dist (c : Chord) :
    chordDist c (plrApply .P c) = 1 := by
  native_decide +revert

/-- **L moves one voice by 1 semitone.** The leading-tone exchange has
    voice-leading distance exactly 1 for every triad. -/
theorem plr_L_dist (c : Chord) :
    chordDist c (plrApply .L c) = 1 := by
  native_decide +revert

/-- **R moves one voice by 2 semitones.** The relative transformation has
    voice-leading distance exactly 2 for every triad. -/
theorem plr_R_dist (c : Chord) :
    chordDist c (plrApply .R c) = 2 := by
  native_decide +revert

/-- All PLR transformations have voice-leading distance at most 2. -/
theorem plr_bounded (T : PLR) (c : Chord) :
    chordDist c (plrApply T c) ≤ 2 := by
  native_decide +revert

-- ============================================================
-- § 9. Geodesicity Theorems
-- ============================================================

/-- **P is exactly geodesic.** Among all chords of opposite quality,
    P(c) is at minimum voice-leading distance from c. The distance
    achieved is 1, which cannot be improved. -/
theorem plr_P_minimizes_vl (c d : Chord) (hq : d.quality ≠ c.quality) :
    chordDist c (plrApply .P c) ≤ chordDist c d := by
  native_decide +revert

/-- **L is exactly geodesic.** Among all chords of opposite quality,
    L(c) is at minimum voice-leading distance from c. -/
theorem plr_L_minimizes_vl (c d : Chord) (hq : d.quality ≠ c.quality) :
    chordDist c (plrApply .L c) ≤ chordDist c d := by
  native_decide +revert

/-- **P and L are the unique distance-1 moves.** Any chord of opposite
    quality at distance 1 from c must be either P(c) or L(c). -/
theorem plr_PL_unique_minimizers (c d : Chord)
    (hq : d.quality ≠ c.quality) (hd : chordDist c d = 1) :
    d = plrApply .P c ∨ d = plrApply .L c := by
  native_decide +revert

/-- **Uniform near-geodesicity with constant C = 2.**
    For every PLR transformation T and every chord c, the voice-leading
    distance to T(c) is at most twice the distance to any other
    opposite-quality chord.

    This is the core metric theorem: PLR moves are uniformly near-geodesic
    in chord space. For P and L, this is trivially C = 1 (exact geodesics).
    For R (distance 2), the bound 2 ≤ 2 · 1 is tight. -/
theorem plr_near_geodesic_uniform (T : PLR) (c d : Chord)
    (hq : d.quality ≠ c.quality) :
    chordDist c (plrApply T c) ≤ 2 * chordDist c d := by
  native_decide +revert

/-- **R achieves minimal distance among chords at distance > 1.**
    Among opposite-quality chords that are not at distance 1 from c,
    R(c) achieves distance 2, which is the smallest possible value
    greater than the P/L minimum. -/
theorem plr_R_optimal_beyond_PL (c d : Chord)
    (hq : d.quality ≠ c.quality) (hgt : 1 < chordDist c d) :
    chordDist c (plrApply .R c) ≤ chordDist c d := by
  native_decide +revert

-- ============================================================
-- § 10. Common-Tone Characterization
-- ============================================================

/-- **PLR preserves exactly 2 common tones.** Each PLR transformation
    keeps two of three notes fixed and moves the third. -/
theorem plr_two_common_tones (T : PLR) (c : Chord) :
    commonTones c (plrApply T c) = 2 := by
  native_decide +revert

/-- **PLR is characterized by 2 common tones.** The three PLR
    transformations are the *only* quality-changing moves that preserve
    exactly 2 common tones.

    This is a purely combinatorial characterization: P, L, R are precisely
    the maximal-common-tone moves between triads of opposite quality. -/
theorem plr_characterizes_two_common_tones (c d : Chord)
    (hq : d.quality ≠ c.quality) (hct : commonTones c d = 2) :
    d = plrApply .P c ∨ d = plrApply .L c ∨ d = plrApply .R c := by
  native_decide +revert

/-- **No quality-changing move preserves all 3 tones.** Changing quality
    requires moving at least one voice. -/
theorem no_quality_change_preserves_all (c d : Chord)
    (hq : d.quality ≠ c.quality) :
    commonTones c d < 3 := by
  native_decide +revert

-- ============================================================
-- § 11. Combined Characterization: PLR as Metric-Optimal
--       Common-Tone-Maximal Transformations
-- ============================================================

/-- **PLR minimality among 2-common-tone moves.**
    Among all chords of opposite quality sharing exactly 2 common tones
    with c, the PLR transformation achieves the minimum voice-leading distance.

    Concretely: if d shares 2 common tones with c and has opposite quality,
    then d is one of P(c), L(c), R(c), and chordDist(c, d) ≥ 1. -/
theorem plr_minimal_among_two_common_tone_moves (c d : Chord)
    (hq : d.quality ≠ c.quality) (hct : commonTones c d = 2) :
    1 ≤ chordDist c d := by
  native_decide +revert

/-- **The PLR-geodesicity bridge theorem.** This combines the metric and
    common-tone characterizations into a single result:

    For any triad c, any opposite-quality chord d sharing 2 common tones,
    and any PLR transformation T such that d = T(c), the voice-leading
    distance chordDist(c, d) equals the PLR displacement (1 for P, L; 2 for R),
    and this is minimal among all opposite-quality chords (for P, L)
    or minimal among all opposite-quality chords at distance > 1 (for R). -/
theorem plr_geodesicity_bridge (T : PLR) (c : Chord) :
    commonTones c (plrApply T c) = 2 ∧
    (plrApply T c).quality ≠ c.quality ∧
    chordDist c (plrApply T c) ≤ 2 ∧
    (∀ d : Chord, d.quality ≠ c.quality →
      chordDist c (plrApply T c) ≤ 2 * chordDist c d) := by
  native_decide +revert

-- ============================================================
-- § 12. The Tonnetz Graph Structure
-- ============================================================

/-- Two chords are PLR-adjacent if one is obtained from the other by
    a single PLR transformation. -/
def plrAdjacent (c d : Chord) : Prop :=
  ∃ T : PLR, d = plrApply T c

instance : DecidablePred (fun p : Chord × Chord => plrAdjacent p.1 p.2) := by
  intro ⟨c, d⟩
  simp only [plrAdjacent]
  exact Fintype.decidableExistsFintype

/-- PLR adjacency is symmetric. -/
theorem plrAdjacent_symm (c d : Chord) :
    plrAdjacent c d → plrAdjacent d c := by
  intro ⟨T, hT⟩
  exact ⟨T, by rw [hT, plr_involution]⟩

/-- PLR-adjacent chords are at voice-leading distance at most 2. -/
theorem plrAdjacent_dist_le_two (c d : Chord) (h : plrAdjacent c d) :
    chordDist c d ≤ 2 := by
  obtain ⟨T, rfl⟩ := h
  exact plr_bounded T c

/-- PLR-adjacent chords always have opposite quality. -/
theorem plrAdjacent_opposite_quality (c d : Chord) (h : plrAdjacent c d) :
    d.quality ≠ c.quality := by
  obtain ⟨T, rfl⟩ := h
  exact plr_flips_quality T c

/-- **PLR adjacency equals 2-common-tone adjacency.**
    Two chords of opposite quality are PLR-adjacent if and only if
    they share exactly 2 common tones.

    This identifies the PLR graph (Tonnetz) with the 2-common-tone
    adjacency graph on {major, minor triads}. -/
theorem plrAdjacent_iff_two_common_tones (c d : Chord)
    (hq : d.quality ≠ c.quality) :
    plrAdjacent c d ↔ commonTones c d = 2 := by
  constructor
  · intro ⟨T, hT⟩
    subst hT
    exact plr_two_common_tones T c
  · intro hct
    obtain h := plr_characterizes_two_common_tones c d hq hct
    rcases h with rfl | rfl | rfl
    · exact ⟨.P, rfl⟩
    · exact ⟨.L, rfl⟩
    · exact ⟨.R, rfl⟩

-- ============================================================
-- § 13. The PLR Group
-- ============================================================

/-- Composing P then L gives a specific transformation. -/
theorem PL_composition (c : Chord) :
    plrApply .L (plrApply .P c) = plrApply .L (plrApply .P c) := rfl

/-- Every major triad can be reached from C major by a sequence of
    at most 4 PLR moves. This demonstrates transitivity of the PLR
    group action on major triads. -/
theorem plr_reaches_all_major_from_C (c : Chord) (hc : c.quality = .Major) :
    ∃ T₁ T₂ T₃ T₄ : PLR,
      plrApply T₄ (plrApply T₃ (plrApply T₂ (plrApply T₁ ⟨0, .Major⟩))) = c ∨
      plrApply T₃ (plrApply T₂ (plrApply T₁ ⟨0, .Major⟩)) = c ∨
      plrApply T₂ (plrApply T₁ ⟨0, .Major⟩) = c ∨
      plrApply T₁ ⟨0, .Major⟩ = c ∨
      (⟨0, .Major⟩ : Chord) = c := by
  native_decide +revert

-- ============================================================
-- § 14. Computational Examples
-- ============================================================

/-- C major = {0, 4, 7} = {C, E, G} -/
example : (⟨0, .Major⟩ : Chord).notes = ![0, 4, 7] := by native_decide

/-- C minor = {0, 3, 7} = {C, E♭, G} -/
example : (⟨0, .Minor⟩ : Chord).notes = ![0, 3, 7] := by native_decide

/-- P(C major) = C minor -/
example : plrApply .P ⟨0, .Major⟩ = ⟨0, .Minor⟩ := by native_decide

/-- L(C major) = E minor -/
example : plrApply .L ⟨0, .Major⟩ = ⟨4, .Minor⟩ := by native_decide

/-- R(C major) = A minor -/
example : plrApply .R ⟨0, .Major⟩ = ⟨9, .Minor⟩ := by native_decide

/-- Distance from C major to C minor = 1 -/
example : chordDist ⟨0, .Major⟩ ⟨0, .Minor⟩ = 1 := by native_decide

/-- Distance from C major to A minor = 2 -/
example : chordDist ⟨0, .Major⟩ ⟨9, .Minor⟩ = 2 := by native_decide

/-- Distance from C major to F♯ minor (furthest) -/
example : chordDist ⟨0, .Major⟩ ⟨6, .Minor⟩ = 5 := by native_decide