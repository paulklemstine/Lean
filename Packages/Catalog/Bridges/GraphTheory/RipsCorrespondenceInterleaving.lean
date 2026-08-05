/-
  # Correspondence-Based Vietoris–Rips Interleaving

  This file develops, as a chain of results each building on the previous one, the
  *correspondence* version of the Vietoris–Rips scale-translation theorem.

  Background (Phase A thread, Direction 3): a matched sample `x_i ↦ y_i` with
  `dist (x i) (y i) ≤ δ` translates Rips scales by exactly `2δ`. Indexwise matching
  is only a special case of a *correspondence*: a relation `R ⊆ X × Y` surjective on
  both factors. The right invariant of a correspondence is its **distortion**
  `sup |dist x x' - dist y y'|` over related pairs, and it is the distortion — not the
  matching — that governs the scale translation.

  ## The chain

  1. `IsRipsSimplex_mono` — Rips complexes are monotone in the scale.
  2. `Correspondence.exists_map` — every correspondence contains a *choice map*.
  3. `Correspondence.dist_map_le` — a choice map distorts distances by at most `c`.
  4. `Correspondence.image_isRipsSimplex` — hence pushes `ε`-simplices to `(ε+c)`-simplices.
  5. `Correspondence.symm` + `Correspondence.image_isRipsSimplex'` — the reverse direction,
     giving a two-sided `c`-interleaving of the Rips filtrations.
  6. `Correspondence.roundTrip_close` — the round trip `g ∘ f` moves points by at most `c`.
  7. `Correspondence.union_roundTrip_isRipsSimplex` — hence `g ∘ f` is contiguous to the
     identity inside the `(ε+2c)`-Rips complex (the simplicial ingredient that makes the
     interleaving descend to homology).
  8. `Correspondence.comp_distortionLe` — distortions add under composition, so the
     interleavings compose.
  9. `matched_distortionLe` and `matched_image_isRipsSimplex` — the classical matched-sample
     `2δ` translation is the special case of an indexwise correspondence, whose distortion
     is at most `2δ`.
  10. `hausdorff_distortionLe`, `hausdorff_image_isRipsSimplex`, `hausdorff_shift_sharp` —
      two samples at Hausdorff distance `≤ δ` in a common space are related by the
      `δ`-closeness correspondence, whose distortion is at most `2δ`; the resulting `2δ`
      scale translation is sharp.
  11. `interleaving_shift_sharp` — sharpness: for every `c > 0` and every shift `η < c`
      there is a correspondence of distortion `≤ c` between two-point and one-point subsets
      of `ℝ` for which the shift `η` fails. Hence the constant `c` (i.e. `2δ` in the matched
      case, by 9) cannot be improved.
-/
import Mathlib

open Finset

noncomputable section

variable {α β γ : Type*} [PseudoMetricSpace α] [PseudoMetricSpace β] [PseudoMetricSpace γ]

/-! ## Part 1: Rips simplices of a finite subset -/

/-- `s` is a simplex of the Vietoris–Rips complex of the finite sample `S` at scale `ε`:
    it is a subset of `S` of diameter at most `ε`. -/
def IsRipsSimplex (S : Finset α) (ε : ℝ) (s : Finset α) : Prop :=
  s ⊆ S ∧ ∀ x ∈ s, ∀ y ∈ s, dist x y ≤ ε

/-- Rips complexes grow with the scale. -/
theorem IsRipsSimplex_mono {S s : Finset α} {ε ε' : ℝ} (hε : ε ≤ ε')
    (hs : IsRipsSimplex S ε s) : IsRipsSimplex S ε' s := by
  constructor
  · exact hs.1
  · intro x hx y hy; exact le_trans (hs.2 x hx y hy) hε

/-- Subsets of a Rips simplex are Rips simplices. -/
theorem IsRipsSimplex_subset {S s t : Finset α} {ε : ℝ} (hts : t ⊆ s)
    (hs : IsRipsSimplex S ε s) : IsRipsSimplex S ε t := by
  constructor
  · exact hts.trans hs.1
  · intro x hx y hy; exact hs.2 x (hts hx) y (hts hy)

/-! ## Part 2: Correspondences between finite samples -/

/-- `R` is a correspondence between the samples `S` and `T`: every point of `S` is related
    to some point of `T` and conversely. -/
def IsCorrespondence (S : Finset α) (T : Finset β) (R : α → β → Prop) : Prop :=
  (∀ x ∈ S, ∃ y ∈ T, R x y) ∧ (∀ y ∈ T, ∃ x ∈ S, R x y)

/-- The correspondence `R` has distortion at most `c`: related pairs have distances
    agreeing up to `c`. -/
def DistortionLe (S : Finset α) (T : Finset β) (R : α → β → Prop) (c : ℝ) : Prop :=
  ∀ x ∈ S, ∀ y ∈ T, ∀ x' ∈ S, ∀ y' ∈ T, R x y → R x' y' → |dist x x' - dist y y'| ≤ c

omit [PseudoMetricSpace α] [PseudoMetricSpace β] in
/-- A correspondence contains a choice map `f : α → β` sending `S` into `T`.
    (The ambient target space is assumed nonempty so that the choice map can be made total.) -/
theorem Correspondence.exists_map [Nonempty β] {S : Finset α} {T : Finset β} {R : α → β → Prop}
    (hR : IsCorrespondence S T R) :
    ∃ f : α → β, ∀ x ∈ S, f x ∈ T ∧ R x (f x) := by
  haveI : ∀ x : S, Nonempty T := fun ⟨x, hx⟩ => ⟨⟨Classical.choose (hR.1 x hx), (Classical.choose_spec (hR.1 x hx)).1⟩⟩
  let f' : ∀ x : S, T := fun ⟨x, hx⟩ => ⟨Classical.choose (hR.1 x hx), (Classical.choose_spec (hR.1 x hx)).1⟩
  haveI : Inhabited (∀ x : S, T) := ⟨f'⟩
  have key : ∃ f : α → β, ∀ x : S, f x = (f' x).1 := by
    have h : ∀ x : α, ∃ y : β, ∀ hx : x ∈ S, y = (f' ⟨x, hx⟩).1 := fun x => by
      by_cases hx : x ∈ S
      · exact ⟨(f' ⟨x, hx⟩).1, fun _ => rfl⟩
      · exact ⟨Classical.arbitrary β, fun h => (hx h).elim⟩
    use fun x => Classical.choose (h x)
    intro ⟨x, hx⟩
    exact (Classical.choose_spec (h x)) hx
  obtain ⟨f, hf⟩ := key
  use f
  intro x hx
  have hfx : f x = (f' ⟨x, hx⟩).1 := hf ⟨x, hx⟩
  rw [hfx]
  exact ⟨(f' ⟨x, hx⟩).prop, (Classical.choose_spec (hR.1 x hx)).2⟩

/-- A choice map of a correspondence of distortion `≤ c` increases distances by at most `c`. -/
theorem Correspondence.dist_map_le {S : Finset α} {T : Finset β} {R : α → β → Prop}
    {c : ℝ} (hc : DistortionLe S T R c) {f : α → β} (hf : ∀ x ∈ S, f x ∈ T ∧ R x (f x))
    {x x' : α} (hx : x ∈ S) (hx' : x' ∈ S) :
    dist (f x) (f x') ≤ dist x x' + c := by
  have hfx : f x ∈ T ∧ R x (f x) := hf x hx
  have hfx' : f x' ∈ T ∧ R x' (f x') := hf x' hx'
  have h := hc x hx (f x) hfx.1 x' hx' (f x') hfx'.1 hfx.2 hfx'.2
  linarith [abs_le.mp h]

/-! ## Part 3: The interleaving -/

/-- **Interleaving, forward direction.** A choice map of a correspondence of distortion
    at most `c` sends `ε`-Rips simplices of `S` to `(ε + c)`-Rips simplices of `T`. -/
theorem Correspondence.image_isRipsSimplex {S : Finset α} {T : Finset β} {R : α → β → Prop}
    {c ε : ℝ} (hc : DistortionLe S T R c) {f : α → β} (hf : ∀ x ∈ S, f x ∈ T ∧ R x (f x))
    [DecidableEq β] {s : Finset α} (hs : IsRipsSimplex S ε s) :
    IsRipsSimplex T (ε + c) (s.image f) := by
  constructor
  · intro z hz
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hz
    exact (hf x (hs.1 hx)).1
  · intro z hz z' hz'
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hz
    obtain ⟨x', hx', rfl⟩ := Finset.mem_image.mp hz'
    have hfx : f x ∈ T ∧ R x (f x) := hf x (hs.1 hx)
    have hfx' : f x' ∈ T ∧ R x' (f x') := hf x' (hs.1 hx')
    have hdist := hc x (hs.1 hx) (f x) hfx.1 x' (hs.1 hx') (f x') hfx'.1 hfx.2 hfx'.2
    linarith [abs_le.mp hdist, hs.2 x hx x' hx']

omit [PseudoMetricSpace α] [PseudoMetricSpace β] in
/-- The transpose of a correspondence is a correspondence. -/
theorem Correspondence.symm {S : Finset α} {T : Finset β} {R : α → β → Prop}
    (hR : IsCorrespondence S T R) :
    IsCorrespondence T S (fun y x => R x y) := by
  exact And.symm hR

/-- The transpose of a correspondence has the same distortion bound. -/
theorem Correspondence.distortionLe_symm {S : Finset α} {T : Finset β} {R : α → β → Prop}
    {c : ℝ} (hc : DistortionLe S T R c) :
    DistortionLe T S (fun y x => R x y) c := by
  intro y hy x hx y' hy' x' hx' hxy hxy'
  rw [abs_sub_comm]
  exact hc x hx y hy x' hx' y' hy' hxy hxy'

/-- **Interleaving, backward direction.** -/
theorem Correspondence.image_isRipsSimplex' {S : Finset α} {T : Finset β} {R : α → β → Prop}
    {c ε : ℝ} (hc : DistortionLe S T R c) {g : β → α} (hg : ∀ y ∈ T, g y ∈ S ∧ R (g y) y)
    [DecidableEq α] {t : Finset β} (ht : IsRipsSimplex T ε t) :
    IsRipsSimplex S (ε + c) (t.image g) := by
  have hsub : t.image g ⊆ S := fun x hx => by
    obtain ⟨y, hy, rfl⟩ := Finset.mem_image.mp hx
    exact (hg y (ht.1 hy)).1
  refine ⟨hsub, ?_⟩
  intro x hx x' hx'
  obtain ⟨y, hy, rfl⟩ := Finset.mem_image.mp hx
  obtain ⟨y', hy', rfl⟩ := Finset.mem_image.mp hx'
  have hyT : y ∈ T := ht.1 hy
  have hy'T : y' ∈ T := ht.1 hy'
  have hdist := hc (g y) (hg y hyT).1 y hyT (g y') (hg y' hy'T).1 y' hy'T (hg y hyT).2 (hg y' hy'T).2
  linarith [abs_le.mp hdist, ht.2 y hy y' hy']

/-- **Round trip.** The composite `g ∘ f` of two choice maps moves each sample point of `S`
    by at most the distortion `c`. -/
theorem Correspondence.roundTrip_close {S : Finset α} {T : Finset β} {R : α → β → Prop}
    {c : ℝ} (hc : DistortionLe S T R c) {f : α → β} (hf : ∀ x ∈ S, f x ∈ T ∧ R x (f x))
    {g : β → α} (hg : ∀ y ∈ T, g y ∈ S ∧ R (g y) y) {x : α} (hx : x ∈ S) :
    dist x (g (f x)) ≤ c := by
  have hfxT : f x ∈ T := (hf x hx).1
  have hfR : R x (f x) := (hf x hx).2
  have hgfxS : g (f x) ∈ S := (hg (f x) hfxT).1
  have hgR : R (g (f x)) (f x) := (hg (f x) hfxT).2
  have h := hc x hx (f x) hfxT (g (f x)) hgfxS (f x) hfxT hfR hgR
  simp at h
  linarith

/-- **Contiguity.** For an `ε`-simplex `s`, the union of `s` with its round-trip image is an
    `(ε + 2c)`-simplex; so the round trip is contiguous to the identity after a `2c` shift. -/
theorem Correspondence.union_roundTrip_isRipsSimplex {S : Finset α} {T : Finset β}
    {R : α → β → Prop} {c ε : ℝ} (hc₀ : 0 ≤ c) (hc : DistortionLe S T R c)
    {f : α → β} (hf : ∀ x ∈ S, f x ∈ T ∧ R x (f x))
    {g : β → α} (hg : ∀ y ∈ T, g y ∈ S ∧ R (g y) y)
    [DecidableEq α] {s : Finset α} (hs : IsRipsSimplex S ε s) :
    IsRipsSimplex S (ε + 2 * c) (s ∪ s.image (g ∘ f)) := by
  -- For g, use the symmetric correspondence
  have hc' : DistortionLe T S (fun y x => R x y) c := Correspondence.distortionLe_symm hc
  have hg' : ∀ y ∈ T, g y ∈ S ∧ (fun y x => R x y) y (g y) := fun y hy => (hg y hy)
  refine ⟨?_, ?_⟩
  · -- Subset: s ∪ s.image (g ∘ f) ⊆ S
    apply Finset.union_subset hs.1
    intro x hx
    obtain ⟨y, hy, rfl⟩ := Finset.mem_image.mp hx
    exact (hg (f y) (hf y (hs.1 hy)).1).1
  · -- Distance bound
    intro x hx y hy
    simp only [Finset.mem_union] at hx hy
    rcases hx with hx | hx <;> rcases hy with hy | hy
    · -- Both in s
      exact le_add_of_le_of_nonneg (hs.2 x hx y hy) (by linarith)
    · -- x ∈ s, y ∈ s.image (g ∘ f)
      obtain ⟨z, hz, rfl⟩ := Finset.mem_image.mp hy
      have hzS : z ∈ S := hs.1 hz
      have h1 : dist z (g (f z)) ≤ c := Correspondence.roundTrip_close hc hf hg hzS
      have h2 : dist x z ≤ ε := hs.2 x hx z hz
      calc dist x (g (f z)) ≤ dist x z + dist z (g (f z)) := dist_triangle _ _ _
        _ ≤ ε + c := add_le_add h2 h1
        _ ≤ ε + 2 * c := by linarith
    · -- x ∈ s.image (g ∘ f), y ∈ s
      obtain ⟨z, hz, rfl⟩ := Finset.mem_image.mp hx
      have hyS : y ∈ S := hs.1 hy
      have hzS : z ∈ S := hs.1 hz
      have h1 : dist z (g (f z)) ≤ c := Correspondence.roundTrip_close hc hf hg hzS
      have h2 : dist z y ≤ ε := hs.2 z hz y hy
      calc dist (g (f z)) y ≤ dist (g (f z)) z + dist z y := dist_triangle _ _ _
        _ = dist z (g (f z)) + dist z y := by rw [dist_comm]
        _ ≤ c + ε := add_le_add h1 h2
        _ ≤ ε + 2 * c := by linarith
    · -- Both in s.image (g ∘ f)
      obtain ⟨u, hu, hu'⟩ := Finset.mem_image.mp hx
      obtain ⟨v, hv, hv'⟩ := Finset.mem_image.mp hy
      rw [← hu', ← hv']
      have huS : u ∈ S := hs.1 hu
      have hvS : v ∈ S := hs.1 hv
      have hfu : f u ∈ T := (hf u huS).1
      have hfv : f v ∈ T := (hf v hvS).1
      have h1 : dist (f u) (f v) ≤ dist u v + c := Correspondence.dist_map_le hc hf huS hvS
      have h2 : dist (g (f u)) (g (f v)) ≤ dist (f u) (f v) + c :=
        Correspondence.dist_map_le hc' hg' hfu hfv
      calc dist (g (f u)) (g (f v)) ≤ dist (f u) (f v) + c := h2
        _ ≤ dist u v + c + c := by linarith
        _ = dist u v + 2 * c := by ring
        _ ≤ ε + 2 * c := add_le_add_left (hs.2 u hu v hv) _

/-! ## Part 4: Composition of correspondences -/

/-- Distortions add along a composition of correspondences: if `R` has distortion `≤ c` and
    `R'` has distortion `≤ c'`, the composite relation has distortion `≤ c + c'`. -/
theorem Correspondence.comp_distortionLe {S : Finset α} {T : Finset β} {U : Finset γ}
    {R : α → β → Prop} {R' : β → γ → Prop} {c c' : ℝ}
    (hc : DistortionLe S T R c) (hc' : DistortionLe T U R' c') :
    DistortionLe S U (fun x z => ∃ y ∈ T, R x y ∧ R' y z) (c + c') := by
  intro x hx z hz x' hx' z' hz' ⟨y, hy, hRxy, hR'yz⟩ ⟨y', hy', hRx'y', hR'yz'⟩
  have h1 := hc x hx y hy x' hx' y' hy' hRxy hRx'y'
  have h2 := hc' y hy z hz y' hy' z' hz' hR'yz hR'yz'
  calc |dist x x' - dist z z'| = |(dist x x' - dist y y') + (dist y y' - dist z z')| := by ring_nf
    _ ≤ |dist x x' - dist y y'| + |dist y y' - dist z z'| := abs_add_le _ _
    _ ≤ c + c' := add_le_add h1 h2

omit [PseudoMetricSpace α] [PseudoMetricSpace β] [PseudoMetricSpace γ] in
/-- Composites of correspondences are correspondences. -/
theorem Correspondence.comp_isCorrespondence {S : Finset α} {T : Finset β} {U : Finset γ}
    {R : α → β → Prop} {R' : β → γ → Prop}
    (hR : IsCorrespondence S T R) (hR' : IsCorrespondence T U R') :
    IsCorrespondence S U (fun x z => ∃ y ∈ T, R x y ∧ R' y z) := by
  obtain ⟨hR_forward, hR_backward⟩ := hR
  obtain ⟨hR'_forward, hR'_backward⟩ := hR'
  constructor
  · intro x hx
    obtain ⟨y, hyT, hRxy⟩ := hR_forward x hx
    obtain ⟨z, hzU, hR'yz⟩ := hR'_forward y hyT
    exact ⟨z, hzU, ⟨y, hyT, hRxy, hR'yz⟩⟩
  · intro z hz
    obtain ⟨y, hyT, hR'yz⟩ := hR'_backward z hz
    obtain ⟨x, hxS, hRxy⟩ := hR_backward y hyT
    exact ⟨x, hxS, ⟨y, hyT, hRxy, hR'yz⟩⟩

/-! ## Part 5: Matched samples are the special case of distortion `2δ` -/

/-- The indexwise correspondence attached to a matched pair of samples: `x` is related to `y`
    when they are the images of a common index. -/
def matchedRel {ι : Type*} (X Y : ι → α) : α → α → Prop :=
  fun x y => ∃ i : ι, X i = x ∧ Y i = y

/-- **Matched samples.** If `dist (X i) (Y i) ≤ δ` for every index, the indexwise
    correspondence has distortion at most `2δ`. -/
theorem matched_distortionLe {ι : Type*} [Fintype ι] [DecidableEq α]
    (X Y : ι → α) {δ : ℝ} (hδ : ∀ i, dist (X i) (Y i) ≤ δ) :
    DistortionLe (Finset.univ.image X) (Finset.univ.image Y) (matchedRel X Y) (2 * δ) := by
  intro x hx y hy x' hx' y' hy' ⟨i, hxi, hyi⟩ ⟨j, hxj, hyj⟩
  rw [← hxi, ← hyi, ← hxj, ← hyj]
  have h1 := hδ i
  have h2 := hδ j
  have trin1 : dist (X i) (X j) ≤ dist (X i) (Y i) + dist (Y i) (X j) := dist_triangle _ _ _
  have trin2 : dist (Y i) (X j) ≤ dist (Y i) (Y j) + dist (Y j) (X j) := dist_triangle _ _ _
  have trin3 : dist (Y i) (Y j) ≤ dist (Y i) (X i) + dist (X i) (Y j) := dist_triangle _ _ _
  have trin4 : dist (X i) (Y j) ≤ dist (X i) (X j) + dist (X j) (Y j) := dist_triangle _ _ _
  have comm1 : dist (Y i) (X i) = dist (X i) (Y i) := dist_comm _ _
  have comm2 : dist (Y j) (X j) = dist (X j) (Y j) := dist_comm _ _
  have hle1 : dist (X i) (X j) ≤ dist (Y i) (Y j) + 2 * δ := by linarith
  have hle2 : dist (Y i) (Y j) ≤ dist (X i) (X j) + 2 * δ := by linarith
  exact abs_sub_le_iff.mpr ⟨by linarith, by linarith⟩

omit [PseudoMetricSpace α] in
/-- The indexwise relation of a matched pair is a correspondence between the two samples. -/
theorem matched_isCorrespondence {ι : Type*} [Fintype ι] [DecidableEq α]
    (X Y : ι → α) :
    IsCorrespondence (Finset.univ.image X) (Finset.univ.image Y) (matchedRel X Y) := by
  constructor
  · intro x hx
    rw [Finset.mem_image] at hx
    obtain ⟨i, _, rfl⟩ := hx
    exact ⟨Y i, Finset.mem_image_of_mem _ (Finset.mem_univ i), ⟨i, rfl, rfl⟩⟩
  · intro y hy
    rw [Finset.mem_image] at hy
    obtain ⟨i, _, rfl⟩ := hy
    exact ⟨X i, Finset.mem_image_of_mem _ (Finset.mem_univ i), ⟨i, rfl, rfl⟩⟩

/-- **The classical `2δ` scale translation as a corollary of the correspondence theorem.**
    For matched samples, any choice map pushes `ε`-simplices to `(ε + 2δ)`-simplices. -/
theorem matched_image_isRipsSimplex {ι : Type*} [Fintype ι] [DecidableEq α]
    (X Y : ι → α) {δ ε : ℝ} (hδ : ∀ i, dist (X i) (Y i) ≤ δ)
    {f : α → α} (hf : ∀ x ∈ Finset.univ.image X,
      f x ∈ Finset.univ.image Y ∧ matchedRel X Y x (f x))
    {s : Finset α} (hs : IsRipsSimplex (Finset.univ.image X) ε s) :
    IsRipsSimplex (Finset.univ.image Y) (ε + 2 * δ) (s.image f) :=
  Correspondence.image_isRipsSimplex (matched_distortionLe X Y hδ) hf hs

/-! ## Part 5b: Hausdorff-close samples -/

/-- Two finite samples of a common metric space are at Hausdorff distance at most `δ`. -/
def HausdorffLe (S T : Finset α) (δ : ℝ) : Prop :=
  (∀ x ∈ S, ∃ y ∈ T, dist x y ≤ δ) ∧ (∀ y ∈ T, ∃ x ∈ S, dist x y ≤ δ)

/-- The `δ`-closeness relation of two Hausdorff-close samples is a correspondence. -/
theorem hausdorff_isCorrespondence {S T : Finset α} {δ : ℝ} (h : HausdorffLe S T δ) :
    IsCorrespondence S T (fun x y => dist x y ≤ δ) := by
  exact ⟨h.1, fun y hy => by obtain ⟨x, hx, hxy⟩ := h.2 y hy; exact ⟨x, hx, hxy⟩⟩

/-- **Hausdorff distance controls distortion.** The `δ`-closeness correspondence of two
    samples at Hausdorff distance `≤ δ` has distortion at most `2δ`. -/
theorem hausdorff_distortionLe (S T : Finset α) (δ : ℝ) :
    DistortionLe S T (fun x y => dist x y ≤ δ) (2 * δ) := by
  intro x hx y hy x' hx' y' hy' hxy hxy'
  have h1 : dist x x' ≤ dist x y + dist y y' + dist y' x' := by
    calc dist x x' ≤ dist x y + dist y x' := dist_triangle _ _ _
      _ ≤ dist x y + dist y y' + dist y' x' := by linarith [dist_triangle y y' x']
  have h2 : dist y y' ≤ dist y x + dist x x' + dist x' y' := by
    calc dist y y' ≤ dist y x + dist x y' := dist_triangle _ _ _
      _ ≤ dist y x + dist x x' + dist x' y' := by linarith [dist_triangle x x' y']
  have hdist_comm : dist y' x' = dist x' y' := dist_comm _ _
  have hdist_comm' : dist y x = dist x y := dist_comm _ _
  rw [hdist_comm] at h1
  rw [hdist_comm'] at h2
  have h3 : dist x x' ≤ dist y y' + 2 * δ := by linarith
  have h4 : dist y y' ≤ dist x x' + 2 * δ := by linarith
  rw [abs_le]
  constructor <;> linarith

/-- **The `2δ` scale translation for Hausdorff-close samples**, as a corollary of the
    correspondence interleaving `Correspondence.image_isRipsSimplex` and the distortion
    bound `hausdorff_distortionLe`. -/
theorem hausdorff_image_isRipsSimplex [DecidableEq α] {S T : Finset α} {δ ε : ℝ}
    {f : α → α} (hf : ∀ x ∈ S, f x ∈ T ∧ dist x (f x) ≤ δ)
    {s : Finset α} (hs : IsRipsSimplex S ε s) :
    IsRipsSimplex T (ε + 2 * δ) (s.image f) :=
  Correspondence.image_isRipsSimplex (hausdorff_distortionLe S T δ) hf hs

/-- **Sharpness of the `2δ` translation for Hausdorff-close samples.** For `δ > 0` the
    samples `S = {0, 2δ}` and `T = {δ}` in `ℝ` are at Hausdorff distance `δ`, `T` is a
    `0`-simplex, and the two points of `S` related to it are at distance `2δ`; so no shift
    smaller than `2δ` works. -/
theorem hausdorff_shift_sharp {δ : ℝ} (hδ : 0 < δ) :
    HausdorffLe ({0, 2 * δ} : Finset ℝ) ({δ} : Finset ℝ) δ ∧
      IsRipsSimplex ({δ} : Finset ℝ) 0 {δ} ∧
      (∀ x ∈ ({0, 2 * δ} : Finset ℝ), dist x δ ≤ δ) ∧
      dist (0 : ℝ) (2 * δ) = 2 * δ := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- HausdorffLe {0, 2δ} {δ} δ
    simp [HausdorffLe, Real.dist_eq]
    exact ⟨⟨le_of_eq (abs_of_pos hδ), by rw [show 2 * δ - δ = δ by ring, abs_of_pos hδ]⟩, Or.inl (le_of_eq (abs_of_pos hδ))⟩
  · -- IsRipsSimplex {δ} 0 {δ}
    simp [IsRipsSimplex]
  · -- ∀ x ∈ {0, 2δ}, dist x δ ≤ δ
    intro x hx
    simp at hx ⊢
    rcases hx with rfl | rfl
    · rw [Real.dist_eq, zero_sub, abs_neg, abs_of_pos hδ]
    · rw [Real.dist_eq, show 2 * δ - δ = δ by ring, abs_of_pos hδ]
  · -- dist 0 (2 * δ) = 2 * δ
    rw [Real.dist_eq, zero_sub, abs_neg, abs_of_pos (by linarith : (0 : ℝ) < 2 * δ)]

/-! ## Part 6: Sharpness of the shift -/

/-- **Sharpness.** For every `c > 0` and every strictly smaller shift `η < c` there are finite
    subsets `S, T` of `ℝ` and a correspondence between them of distortion at most `c` such that
    a `0`-simplex of `T` pulls back (along every choice map of the transposed correspondence)
    to a set that is *not* an `η`-simplex of `S`. Hence no shift smaller than the distortion
    works uniformly: the `c`-interleaving of `Correspondence.image_isRipsSimplex` is sharp. -/
theorem interleaving_shift_sharp {c η : ℝ} (hc : 0 < c) (hη : η < c) :
    ∃ (S T : Finset ℝ) (R : ℝ → ℝ → Prop),
      IsCorrespondence S T R ∧ DistortionLe S T R c ∧
      (∃ t : Finset ℝ, IsRipsSimplex T 0 t ∧
        ∃ x ∈ S, ∃ x' ∈ S, (∃ y ∈ t, R x y) ∧ (∃ y' ∈ t, R x' y') ∧ η < dist x x') := by
  use {0, c}, {0}, fun x y => True
  refine ⟨?_, ?_, ?_⟩
  · -- IsCorrespondence {0, c} {0} (fun x y => True)
    simp [IsCorrespondence]
  · -- DistortionLe {0, c} {0} (fun x y => True) c
    simp [DistortionLe, Real.dist_eq]
    have h1 : 0 ≤ c ∧ |c| ≤ c := ⟨hc.le, (abs_of_pos hc).le⟩
    have h2 : |c| ≤ c := (abs_of_pos hc).le
    exact ⟨h1, h2, hc.le⟩
  · -- ∃ t, IsRipsSimplex {0} 0 t ∧ ...
    use {0}
    refine ⟨?_, 0, by simp, c, by simp, ?_, ?_, ?_⟩
    · simp [IsRipsSimplex]
    · simp
    · simp
    · simp [Real.dist_eq, abs_of_pos hc]; exact hη

end