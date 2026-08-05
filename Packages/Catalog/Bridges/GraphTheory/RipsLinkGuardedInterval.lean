/-
  # Vertex Links of Rips Complexes and Stability of the Guarded Interval

  This file continues the Phase A thread on quantitative sphere detection from finite
  data.  The previous file
  (`Catalog/Bridges/GraphTheory/RipsCorrespondenceInterleaving.lean`) established the
  *global* correspondence interleaving: a correspondence of distortion `≤ c` translates
  Rips scales by `c`, and the matched / Hausdorff cases give the sharp `2δ` translation.

  Directions 4 and 5 of the mission ask for the *local* counterpart: link data of the
  Rips complex, and an interval-valued detector whose endpoints are Lipschitz stable
  under matched perturbations of the sample.  This file develops exactly that, again as
  a chain in which each result uses the previous ones.

  ## The chain

  1. `IsRipsSimplex`, `ripsBall`, `linkDeg` — the closed vertex star of a sample point
     and its cardinality (the *link degree*); `mem_ripsBall_iff_isRipsSimplex` identifies
     the ball with the set of vertices spanning an edge with `v`, so the link degree is a
     genuine invariant of the Rips complex.
  2. `ripsBall_mono`, `linkDeg_mono` — link degrees are monotone in the scale.
  3. `IsDeltaMatching`, `dist_map_le` — a `δ`-matching expands distances by at most `2δ`
     (the local shadow of the `2δ` distortion bound of the previous file).
  4. `Separated`, `map_injOn` — on an `η`-separated sample with `2δ < η` a `δ`-matching is
     injective, so it cannot collapse links.
  5. `ripsBall_image_subset`, `linkDeg_le_of_matching` — hence link degrees can only grow:
     `linkDeg S ε v ≤ linkDeg T (ε + 2δ) (f v)`.
  6. `GuardedAt`, `GuardedAt_mono`, `GuardedAt_perturb` — the local guard "every link has
     at least `k` vertices" is an up-set in the scale and is transported by a `δ`-matching
     with a `2δ` shift.
  7. `exists_diam_bound`, `guardedAt_diam` — the guard is eventually satisfied, so the
     *guarded interval* `guardSet S k` is a nonempty up-set bounded below by `0`.
  8. `guardThreshold_stability` — **the endpoint of the guarded interval is `2δ`-Lipschitz
     under matched perturbations**: `guardThreshold T k ≤ guardThreshold S k + 2δ`, and
     symmetrically, giving the two-sided bound `guardThreshold_stability_abs`.
  9. `GuardedAt_perturb_ray` — the perturbed sample is guarded on the whole ray
     `[ε + 2δ, ∞)`: once acquired, the guard is never lost.
  10. `guardSet_pair`, `guardThreshold_pair` — a worked example: the guarded interval of
     the two-point sample `{0, r} ⊆ ℝ` with `k = 2` is exactly `[r, ∞)`, so the guard is
     not vacuous and the endpoint is computed exactly.
  11. `linkDeg_shift_sharp` — the shift `2δ` in step 5 cannot be lowered.

  The file is self-contained: it only imports Mathlib.
-/
import Mathlib

open Finset

noncomputable section

namespace RipsGuard

variable {α : Type*} [PseudoMetricSpace α]

/-! ## Part 1: Rips simplices, balls and link degrees -/

/-- `s` is a simplex of the Vietoris–Rips complex of the finite sample `S` at scale `ε`:
    a subset of `S` of diameter at most `ε`. -/
def IsRipsSimplex (S : Finset α) (ε : ℝ) (s : Finset α) : Prop :=
  s ⊆ S ∧ ∀ x ∈ s, ∀ y ∈ s, dist x y ≤ ε

/-- Rips complexes grow with the scale. -/
theorem IsRipsSimplex_mono {S s : Finset α} {ε ε' : ℝ} (hε : ε ≤ ε')
    (hs : IsRipsSimplex S ε s) : IsRipsSimplex S ε' s := by
  exact ⟨hs.1, fun x hx y hy => (hs.2 x hx y hy).trans hε⟩

open Classical in
/-- The closed Rips ball (closed vertex star) of `v` in the sample `S` at scale `ε`. -/
def ripsBall (S : Finset α) (ε : ℝ) (v : α) : Finset α :=
  S.filter (fun x => dist v x ≤ ε)

theorem mem_ripsBall {S : Finset α} {ε : ℝ} {v x : α} :
    x ∈ ripsBall S ε v ↔ x ∈ S ∧ dist v x ≤ ε := by
  classical
  simp [ripsBall, Finset.mem_filter]

theorem ripsBall_subset {S : Finset α} {ε : ℝ} {v : α} : ripsBall S ε v ⊆ S :=
  fun _ hx => (mem_ripsBall.mp hx).1

/-- The link degree of `v`: the number of sample points joined to `v` at scale `ε`
    (including `v` itself when `0 ≤ ε`). -/
def linkDeg (S : Finset α) (ε : ℝ) (v : α) : ℕ := (ripsBall S ε v).card

/-- The Rips ball is exactly the set of vertices spanning an edge with `v`: the link
    degree is an invariant of the Rips complex, not just of the metric. -/
theorem mem_ripsBall_iff_isRipsSimplex [DecidableEq α] {S : Finset α} {ε : ℝ} {v x : α}
    (hε : 0 ≤ ε) (hv : v ∈ S) :
    x ∈ ripsBall S ε v ↔ IsRipsSimplex S ε ({v, x} : Finset α) := by
  constructor
  · intro hx
    obtain ⟨hxS, hd⟩ := mem_ripsBall.mp hx
    refine ⟨?_, ?_⟩
    · intro z hz
      simp only [Finset.mem_insert, Finset.mem_singleton] at hz
      rcases hz with rfl | rfl
      · exact hv
      · exact hxS
    · intro a ha b hb
      simp only [Finset.mem_insert, Finset.mem_singleton] at ha hb
      rcases ha with rfl | rfl <;> rcases hb with rfl | rfl
      · simpa using hε
      · exact hd
      · rw [dist_comm]; exact hd
      · simpa using hε
  · intro h
    have hxS : x ∈ S := h.1 (by simp)
    exact mem_ripsBall.mpr ⟨hxS, h.2 v (by simp) x (by simp)⟩

/-! ## Part 2: Monotonicity in the scale -/

theorem ripsBall_mono {S : Finset α} {ε ε' : ℝ} {v : α} (h : ε ≤ ε') :
    ripsBall S ε v ⊆ ripsBall S ε' v := by
  intro x hx
  obtain ⟨hxS, hd⟩ := mem_ripsBall.mp hx
  exact mem_ripsBall.mpr ⟨hxS, hd.trans h⟩

theorem linkDeg_mono {S : Finset α} {ε ε' : ℝ} {v : α} (h : ε ≤ ε') :
    linkDeg S ε v ≤ linkDeg S ε' v :=
  Finset.card_le_card (ripsBall_mono h)

/-! ## Part 3: `δ`-matchings and injectivity on separated samples -/

/-- `f` is a `δ`-matching of the sample `S` onto the sample `T`: it moves every point of
    `S` by at most `δ` into `T`, and every point of `T` is hit. -/
def IsDeltaMatching (S T : Finset α) (f : α → α) (δ : ℝ) : Prop :=
  (∀ x ∈ S, f x ∈ T ∧ dist x (f x) ≤ δ) ∧ (∀ y ∈ T, ∃ x ∈ S, f x = y)

/-- A `δ`-matching expands distances by at most `2δ` — the local form of the `2δ`
    distortion bound for matched samples. -/
theorem dist_map_le {S T : Finset α} {f : α → α} {δ : ℝ}
    (hf : IsDeltaMatching S T f δ) {x x' : α} (hx : x ∈ S) (hx' : x' ∈ S) :
    dist (f x) (f x') ≤ dist x x' + 2 * δ := by
  have h1 : dist x (f x) ≤ δ := (hf.1 x hx).2
  have h2 : dist x' (f x') ≤ δ := (hf.1 x' hx').2
  calc dist (f x) (f x') ≤ dist (f x) x + dist x (f x') := dist_triangle _ _ _
    _ ≤ dist (f x) x + (dist x x' + dist x' (f x')) := by
        gcongr; exact dist_triangle _ _ _
    _ = dist x (f x) + dist x x' + dist x' (f x') := by rw [dist_comm (f x) x]; ring
    _ ≤ δ + dist x x' + δ := by gcongr
    _ = dist x x' + 2 * δ := by ring

/-- A `δ`-matching contracts distances by at most `2δ` as well. -/
theorem le_dist_map {S T : Finset α} {f : α → α} {δ : ℝ}
    (hf : IsDeltaMatching S T f δ) {x x' : α} (hx : x ∈ S) (hx' : x' ∈ S) :
    dist x x' ≤ dist (f x) (f x') + 2 * δ := by
  have h1 : dist x (f x) ≤ δ := (hf.1 x hx).2
  have h2 : dist x' (f x') ≤ δ := (hf.1 x' hx').2
  calc dist x x' ≤ dist x (f x) + dist (f x) x' := dist_triangle _ _ _
    _ ≤ dist x (f x) + (dist (f x) (f x') + dist (f x') x') := by
        gcongr; exact dist_triangle _ _ _
    _ = dist x (f x) + dist (f x) (f x') + dist x' (f x') := by
        rw [dist_comm (f x') x']; ring
    _ ≤ δ + dist (f x) (f x') + δ := by gcongr
    _ = dist (f x) (f x') + 2 * δ := by ring

/-- `S` is `η`-separated: distinct sample points are at distance at least `η`. -/
def Separated (S : Finset α) (η : ℝ) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, x ≠ y → η ≤ dist x y

/-- On an `η`-separated sample with `2δ < η`, a `δ`-matching is injective: it cannot
    collapse two sample points, hence cannot destroy link data. -/
theorem map_injOn {S T : Finset α} {f : α → α} {δ η : ℝ}
    (hf : IsDeltaMatching S T f δ) (hsep : Separated S η) (hη : 2 * δ < η) :
    Set.InjOn f S := by
  intro x hx x' hx' heq
  by_contra hne
  have hxS : x ∈ S := hx
  have hx'S : x' ∈ S := hx'
  have hsp : η ≤ dist x x' := hsep x hxS x' hx'S hne
  have hle : dist x x' ≤ dist (f x) (f x') + 2 * δ := le_dist_map hf hxS hx'S
  rw [heq, dist_self] at hle
  linarith

/-! ## Part 4: Link degrees are stable under matched perturbations -/

theorem ripsBall_image_subset [DecidableEq α] {S T : Finset α} {f : α → α}
    {δ ε : ℝ} (hf : IsDeltaMatching S T f δ) {v : α} (hv : v ∈ S) :
    (ripsBall S ε v).image f ⊆ ripsBall T (ε + 2 * δ) (f v) := by
  intro z hz
  obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hz
  obtain ⟨hxS, hd⟩ := mem_ripsBall.mp hx
  refine mem_ripsBall.mpr ⟨(hf.1 x hxS).1, ?_⟩
  calc dist (f v) (f x) ≤ dist v x + 2 * δ := dist_map_le hf hv hxS
    _ ≤ ε + 2 * δ := by gcongr

/-- **Local stability.** For a `δ`-matching of an `η`-separated sample with `2δ < η`, the
    link degree at `v` is dominated by the link degree at `f v` after a `2δ` shift. -/
theorem linkDeg_le_of_matching [DecidableEq α] {S T : Finset α} {f : α → α}
    {δ η ε : ℝ} (hf : IsDeltaMatching S T f δ) (hsep : Separated S η) (hη : 2 * δ < η)
    {v : α} (hv : v ∈ S) :
    linkDeg S ε v ≤ linkDeg T (ε + 2 * δ) (f v) := by
  have hinj : Set.InjOn f (ripsBall S ε v : Set α) :=
    (map_injOn hf hsep hη).mono (Finset.coe_subset.mpr ripsBall_subset)
  calc linkDeg S ε v = ((ripsBall S ε v).image f).card :=
        (Finset.card_image_of_injOn hinj).symm
    _ ≤ linkDeg T (ε + 2 * δ) (f v) :=
        Finset.card_le_card (ripsBall_image_subset hf hv)

/-! ## Part 5: The local guard and its transport -/

/-- The sample `S` is *`k`-guarded at scale `ε`*: every vertex link contains at least `k`
    vertices.  This is the local manifold-like condition of Direction 4, in its simplest
    quantitative form. -/
def GuardedAt (S : Finset α) (k : ℕ) (ε : ℝ) : Prop :=
  ∀ v ∈ S, k ≤ linkDeg S ε v

/-- The guard is an up-set in the scale. -/
theorem GuardedAt_mono {S : Finset α} {k : ℕ} {ε ε' : ℝ} (h : ε ≤ ε')
    (hG : GuardedAt S k ε) : GuardedAt S k ε' :=
  fun v hv => (hG v hv).trans (linkDeg_mono h)

/-- **Transport of the guard.**  A `δ`-matching of an `η`-separated sample with `2δ < η`
    carries a `k`-guard at scale `ε` to a `k`-guard at scale `ε + 2δ`. -/
theorem GuardedAt_perturb [DecidableEq α] {S T : Finset α} {f : α → α}
    {δ η ε : ℝ} {k : ℕ} (hf : IsDeltaMatching S T f δ) (hsep : Separated S η)
    (hη : 2 * δ < η) (hG : GuardedAt S k ε) : GuardedAt T k (ε + 2 * δ) := by
  intro w hw
  obtain ⟨v, hv, rfl⟩ := hf.2 w hw
  exact (hG v hv).trans (linkDeg_le_of_matching hf hsep hη hv)

/-! ## Part 6: The guarded interval and its endpoint -/

/-- Every finite sample has a finite diameter bound. -/
theorem exists_diam_bound (S : Finset α) : ∃ D : ℝ, 0 ≤ D ∧ ∀ x ∈ S, ∀ y ∈ S, dist x y ≤ D := by
  classical
  by_cases h : (S ×ˢ S).Nonempty
  · obtain ⟨p, _, hmax⟩ := Finset.exists_max_image (S ×ˢ S) (fun p => dist p.1 p.2) h
    exact ⟨dist p.1 p.2, dist_nonneg, fun x hx y hy => hmax (x, y) (Finset.mk_mem_product hx hy)⟩
  · exact ⟨0, le_refl 0, fun x hx y hy => absurd ⟨(x, y), Finset.mk_mem_product hx hy⟩ h⟩

/-- At a diameter scale the whole sample lies in every link, so the guard holds with
    `k = S.card`; in particular the guarded interval is nonempty for every `k ≤ S.card`. -/
theorem guardedAt_diam {S : Finset α} {D : ℝ} (hD : ∀ x ∈ S, ∀ y ∈ S, dist x y ≤ D) :
    GuardedAt S S.card D := by
  intro v hv
  refine Finset.card_le_card ?_
  intro x hx
  exact mem_ripsBall.mpr ⟨hx, hD v hv x hx⟩

/-- The set of scales at which the `k`-guard holds — the *guarded interval*. -/
def guardSet (S : Finset α) (k : ℕ) : Set ℝ := {ε : ℝ | GuardedAt S k ε}

theorem guardSet_nonempty {S : Finset α} {k : ℕ} (hk : k ≤ S.card) :
    (guardSet S k).Nonempty := by
  obtain ⟨D, _, hD⟩ := exists_diam_bound S
  exact ⟨D, fun v hv => hk.trans (guardedAt_diam hD v hv)⟩

theorem guardSet_bddBelow {S : Finset α} {k : ℕ} (hS : S.Nonempty) (hk : 1 ≤ k) :
    BddBelow (guardSet S k) := by
  obtain ⟨v, hv⟩ := hS
  refine ⟨0, fun ε hε => ?_⟩
  have hpos : 0 < linkDeg S ε v := lt_of_lt_of_le hk (hε v hv)
  obtain ⟨x, hx⟩ := Finset.card_pos.mp hpos
  exact le_trans dist_nonneg (mem_ripsBall.mp hx).2

/-- The left endpoint of the guarded interval: the smallest scale at which every link of
    the sample has at least `k` vertices. -/
def guardThreshold (S : Finset α) (k : ℕ) : ℝ := sInf (guardSet S k)

theorem guardThreshold_nonneg {S : Finset α} {k : ℕ} (hS : S.Nonempty) (hk : 1 ≤ k)
    (hkS : k ≤ S.card) : 0 ≤ guardThreshold S k := by
  refine le_csInf (guardSet_nonempty hkS) ?_
  intro ε hε
  obtain ⟨v, hv⟩ := hS
  have hpos : 0 < linkDeg S ε v := lt_of_lt_of_le hk (hε v hv)
  obtain ⟨x, hx⟩ := Finset.card_pos.mp hpos
  exact le_trans dist_nonneg (mem_ripsBall.mp hx).2

/-- **Endpoint stability (one-sided).**  Under a `δ`-matching of an `η`-separated sample
    with `2δ < η`, the endpoint of the guarded interval moves by at most `2δ`. -/
theorem guardThreshold_stability [DecidableEq α] {S T : Finset α} {f : α → α}
    {δ η : ℝ} {k : ℕ} (hf : IsDeltaMatching S T f δ) (hsep : Separated S η)
    (hη : 2 * δ < η) (hk : 1 ≤ k) (hkS : k ≤ S.card) :
    guardThreshold T k ≤ guardThreshold S k + 2 * δ := by
  have hScard : 0 < S.card := lt_of_lt_of_le hk hkS
  obtain ⟨v, hv⟩ := Finset.card_pos.mp hScard
  have hT : T.Nonempty := ⟨f v, (hf.1 v hv).1⟩
  have hAne : (guardSet S k).Nonempty := guardSet_nonempty hkS
  have hBbdd : BddBelow (guardSet T k) := guardSet_bddBelow hT hk
  have key : ∀ ε ∈ guardSet S k, guardThreshold T k ≤ ε + 2 * δ := by
    intro ε hε
    exact csInf_le hBbdd (GuardedAt_perturb hf hsep hη hε)
  have h : guardThreshold T k - 2 * δ ≤ guardThreshold S k :=
    le_csInf hAne (fun ε hε => by linarith [key ε hε])
  linarith

/-- **Endpoint stability (two-sided).**  If in addition the perturbation is symmetric —
    both samples are separated and matched to each other — the two endpoints differ by at
    most `2δ`, i.e. the endpoint of the guarded interval is a `2`-Lipschitz function of the
    matching parameter. -/
theorem guardThreshold_stability_abs [DecidableEq α] {S T : Finset α}
    {f g : α → α} {δ η : ℝ} {k : ℕ}
    (hf : IsDeltaMatching S T f δ) (hg : IsDeltaMatching T S g δ)
    (hsepS : Separated S η) (hsepT : Separated T η) (hη : 2 * δ < η)
    (hk : 1 ≤ k) (hkS : k ≤ S.card) (hkT : k ≤ T.card) :
    |guardThreshold T k - guardThreshold S k| ≤ 2 * δ := by
  have h1 : guardThreshold T k ≤ guardThreshold S k + 2 * δ :=
    guardThreshold_stability hf hsepS hη hk hkS
  have h2 : guardThreshold S k ≤ guardThreshold T k + 2 * δ :=
    guardThreshold_stability hg hsepT hη hk hkT
  rw [abs_le]
  constructor <;> linarith

/-! ## Part 7: The guarded interval is a ray, and a worked example -/

/-- **Robust detection.**  A `δ`-perturbation of an `η`-separated `k`-guarded sample is
    `k`-guarded on the whole ray `[ε + 2δ, ∞)`: the guard, once acquired, is never lost. -/
theorem GuardedAt_perturb_ray [DecidableEq α] {S T : Finset α} {f : α → α}
    {δ η ε ε' : ℝ} {k : ℕ} (hf : IsDeltaMatching S T f δ) (hsep : Separated S η)
    (hη : 2 * δ < η) (hG : GuardedAt S k ε) (hε' : ε + 2 * δ ≤ ε') : GuardedAt T k ε' :=
  GuardedAt_mono hε' (GuardedAt_perturb hf hsep hη hG)

/-- The guarded interval of the two-point sample `{0, r} ⊆ ℝ` with the guard `k = 2`
    is exactly the ray `[r, ∞)`; in particular the guard is not vacuous and its endpoint
    is the interpoint distance. -/
theorem guardSet_pair {r : ℝ} (hr : 0 < r) :
    guardSet ({0, r} : Finset ℝ) 2 = Set.Ici r := by
  have hne : (0 : ℝ) ≠ r := ne_of_lt hr
  have hcard : ({0, r} : Finset ℝ).card = 2 := Finset.card_pair hne
  ext ε
  simp only [Set.mem_Ici, guardSet, Set.mem_setOf_eq]
  constructor
  · intro hG
    have h2 : 2 ≤ (ripsBall ({0, r} : Finset ℝ) ε 0).card := by
      have := hG 0 (by simp); simpa [linkDeg] using this
    have heq : ripsBall ({0, r} : Finset ℝ) ε 0 = {0, r} :=
      Finset.eq_of_subset_of_card_le ripsBall_subset (by rw [hcard]; exact h2)
    have hr' : r ∈ ripsBall ({0, r} : Finset ℝ) ε 0 := by rw [heq]; simp
    have := (mem_ripsBall.mp hr').2
    rwa [Real.dist_eq, zero_sub, abs_neg, abs_of_pos hr] at this
  · intro hε v hv
    have hball : ripsBall ({0, r} : Finset ℝ) ε v = {0, r} := by
      refine Finset.Subset.antisymm ripsBall_subset ?_
      intro x hx
      refine mem_ripsBall.mpr ⟨hx, ?_⟩
      simp only [Finset.mem_insert, Finset.mem_singleton] at hv hx
      rcases hv with hv | hv <;> rcases hx with hx | hx <;> rw [hv, hx] <;>
        simp only [Real.dist_eq, sub_self, sub_zero, zero_sub, abs_zero, abs_neg,
          abs_of_pos hr] <;> linarith
    rw [linkDeg, hball, hcard]

/-- The endpoint of the guarded interval of `{0, r}` is `r`. -/
theorem guardThreshold_pair {r : ℝ} (hr : 0 < r) :
    guardThreshold ({0, r} : Finset ℝ) 2 = r := by
  rw [guardThreshold, guardSet_pair hr, csInf_Ici]

/-! ## Part 8: Sharpness of the `2δ` shift for link degrees -/

/-- **Sharpness.**  For `δ > 0`, `0 ≤ ε` and any shift `η < ε + 2δ`, there are samples
    `S, T ⊆ ℝ` and a `δ`-matching `f : S → T` with `linkDeg S ε 0 = 2` while
    `linkDeg T η (f 0) = 1`: the `2δ` shift in `linkDeg_le_of_matching` is optimal. -/
theorem linkDeg_shift_sharp {δ ε η : ℝ} (hδ : 0 < δ) (hε : 0 < ε) (hη : 0 ≤ η)
    (hlt : η < ε + 2 * δ) :
    ∃ (S T : Finset ℝ) (f : ℝ → ℝ),
      IsDeltaMatching S T f δ ∧ linkDeg S ε 0 = 2 ∧ linkDeg T η (f 0) = 1 := by
  classical
  set f : ℝ → ℝ := fun x => if x = 0 then -δ else ε + δ with hfdef
  have hf0 : f 0 = -δ := by simp [hfdef]
  have hfe : f ε = ε + δ := by simp [hfdef, ne_of_gt hε]
  have hne0 : (0 : ℝ) ≠ ε := ne_of_lt hε
  have hneT : (-δ : ℝ) ≠ ε + δ := by intro h; linarith
  refine ⟨{0, ε}, {-δ, ε + δ}, f, ⟨?_, ?_⟩, ?_, ?_⟩
  · -- `f` is a `δ`-matching
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with h | h
    · rw [h, hf0]
      refine ⟨by simp, ?_⟩
      rw [Real.dist_eq]
      simp [abs_of_pos hδ]
    · rw [h, hfe]
      refine ⟨by simp, ?_⟩
      rw [Real.dist_eq, show ε - (ε + δ) = -δ by ring, abs_neg, abs_of_pos hδ]
  · -- every point of `T` is hit
    intro y hy
    simp only [Finset.mem_insert, Finset.mem_singleton] at hy
    rcases hy with h | h
    · exact ⟨0, by simp, by rw [hf0, h]⟩
    · exact ⟨ε, by simp, by rw [hfe, h]⟩
  · -- the link of `0` in `S` at scale `ε` has two vertices
    have hball : ripsBall ({0, ε} : Finset ℝ) ε 0 = {0, ε} := by
      refine Finset.Subset.antisymm ripsBall_subset ?_
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with h | h
      · exact mem_ripsBall.mpr ⟨by simp [h], by simp [h, hε.le]⟩
      · refine mem_ripsBall.mpr ⟨by simp [h], ?_⟩
        rw [h, Real.dist_eq, zero_sub, abs_neg, abs_of_pos hε]
    rw [linkDeg, hball, Finset.card_pair hne0]
  · -- after the perturbation the link of `f 0` at any scale `η < ε + 2δ` has one vertex
    have hball : ripsBall ({-δ, ε + δ} : Finset ℝ) η (-δ) = {-δ} := by
      refine Finset.Subset.antisymm ?_ ?_
      · intro x hx
        obtain ⟨hxT, hd⟩ := mem_ripsBall.mp hx
        simp only [Finset.mem_insert, Finset.mem_singleton] at hxT
        rcases hxT with h | h
        · simp [h]
        · exfalso
          rw [h, Real.dist_eq, show -δ - (ε + δ) = -(ε + 2 * δ) by ring, abs_neg,
            abs_of_pos (by linarith : (0 : ℝ) < ε + 2 * δ)] at hd
          linarith
      · intro x hx
        simp only [Finset.mem_singleton] at hx
        refine mem_ripsBall.mpr ⟨by simp [hx], ?_⟩
        rw [hx, dist_self]
        exact hη
    rw [hf0, linkDeg, hball, Finset.card_singleton]

end RipsGuard

end