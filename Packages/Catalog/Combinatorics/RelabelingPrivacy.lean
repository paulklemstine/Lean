/-
# Privacy thresholds for distortion *modulo relabeling*

This file settles open direction **5** of
`Catalog/Applications/SurveillanceNetworks/PrivacyThreshold.lean`
("Distortion modulo relabeling": replace Hamming balls by orbit balls under a
vertex relabeling action, so that a reconstruction is judged only up to a
permutation of the participants).

For binary tensors indexed by a finite set `α` we take the full relabeling group
`Equiv.Perm α` acting by precomposition and define the *orbit distortion*
`orbDist x y = min_g hdist (x ∘ g) y`.  The results are:

* `orbDist_eq_dist_wt` — **exact orbit distance.**  `orbDist x y = |wt x − wt y|`:
  the relabeling-invariant distortion is exactly the gap between the Hamming
  weights.  (Both directions are genuine work: the lower bound is a support
  inclusion, the upper bound builds an explicit relabeling out of
  `Equiv.extendSubtype` together with a subset/superset of the support of the
  target.)
* `orbit_coveringRadius` — **sharp relabeled privacy threshold.**  The one-codeword
  covering radius for `orbDist` is exactly `⌈|α|/2⌉ = (|α| + 1) / 2`, versus the
  full ambient dimension `|α|` for plain Hamming distortion
  (`SurveillanceNetworks.Privacy.hamming_coveringRadius`).  So quotienting by the
  relabeling action buys back exactly a factor of two and no more
  (`orbit_coveringRadius_lt_hamming` for `|α| ≥ 2`).
* `orbit_privatelyAchievable_iff` — operationally: a perfectly private observer
  meets a relabeling-tolerant worst-case distortion budget `D` iff `D ≥ ⌈|α|/2⌉`.
* `card_wt_eq` and `orbit_ball_card_eq` — the exact orbit (Burnside) volume: the
  orbit of a weight-`m` tensor has exactly `C(|α|, m)` elements, and an orbit ball
  of radius `D` around a center of weight `k` has exactly
  `∑_{m ∈ [k−D, k+D]} C(|α|, m)` elements — the replacement, asked for by direction
  5, of `hamming_ball_card` by an orbit-counting volume.
* `orbit_ball_card_le` and `orbit_rate_bound` — the quantitative converse survives
  the quotient: any observer reconstructing every history within relabeled
  distortion `D` must emit at least `2^{|α|} / ((2D+1)·C(|α|, ⌊|α|/2⌋))` distinct
  records, which is still exponentially many for bounded `D`.
* `history_relabeled_private_distortion` — for `T`-step histories of a directed
  network on `n` participants (`|α| = T·n²`) the relabeled private worst-case
  distortion is `⌈T·n²/2⌉`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Quotienting the distortion by the relabeling action
must *strictly* lower the privacy threshold, because a fixed reconstruction can
now serve every tensor in an orbit.  Bold form: for the full symmetric group the
orbit distortion collapses to a one-dimensional statistic (the Hamming weight),
and the threshold becomes the covering radius of `{0,…,n}` under `|·|`, namely
`⌈n/2⌉`.

EXPERIMENT (Experimenter).  Brute force over all `2^n` binary vectors and all `n!`
relabelings for `n ≤ 5` (recorded in `ComputationalEvidence.md`) gave orbit
covering radii `0,1,1,2,2,3`, i.e. `⌈n/2⌉`, and confirmed
`orbDist x y = |wt x − wt y|` on all pairs for `n = 5`.  The formal proof of the
upper bound needed the explicit interpolation: for a target weight `k` pick a
subset of, or a superset of, the support of `y` of size `k`, then transport it by
`Equiv.extendSubtype`.

ANALYSIS (Analyst).  The reason a closed form exists is that the orbit invariant
of the `S_n`-action on the cube is a single number, so the covering problem for
orbit balls is a covering problem on a path `{0,…,n}`.  Two thresholds — the
average-case one of `Catalog/Combinatorics/PrivateAverageDistortion.lean` and the
relabeling-quotient one here — independently produce the same factor `1/2`, but
for different reasons (a coordinatewise coin flip versus a median of the weight
range); the coincidence is explained by the fact that both optimizations pick the
midpoint of an interval of length `|α|`.

CRITIQUE (Critic).  `orbit_coveringRadius` is stated as an exact equality, so it
cannot be vacuous; its strictness corollary carries the hypothesis `2 ≤ |α|`,
which is necessary: for `|α| = 1` both radii equal `1`.  The quantitative
converse `orbit_rate_bound` is not implied by the Hamming one, since orbit balls
are strictly larger than Hamming balls; the extra factor `(2D+1)·C(n,⌊n/2⌋)` is the
honest cost, and no theorem here is `True`, `rfl`-only or `decide`-only.
-/
import Applications.SurveillanceNetworks.PrivacyThreshold

open Finset SurveillanceNetworks.Privacy

namespace SurveillanceNetworks.Relabeling

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## Weights, supports and the relabeling action -/

/-- The support of a binary tensor. -/
def supp (x : α → Bool) : Finset α := univ.filter fun i => x i = true

/-- The Hamming weight of a binary tensor. -/
def wt (x : α → Bool) : ℕ := (supp x).card

/-- The indicator tensor of a finite set of coordinates. -/
def ind (T : Finset α) : α → Bool := fun i => decide (i ∈ T)

theorem supp_ind (T : Finset α) : supp (ind T) = T := by ext i; simp [supp, ind]

theorem wt_ind (T : Finset α) : wt (ind T) = T.card := by rw [wt, supp_ind]

omit [DecidableEq α] in
theorem wt_le_card (x : α → Bool) : wt x ≤ Fintype.card α :=
  le_trans (card_filter_le _ _) (le_of_eq Finset.card_univ)

omit [DecidableEq α] in
/-- Relabeling the coordinates does not change the Hamming weight. -/
theorem wt_comp_perm (x : α → Bool) (g : Equiv.Perm α) : wt (x ∘ g) = wt x := by
  unfold wt supp
  apply Finset.card_bij (fun i _ => g i)
  · intro i hi; simpa using hi
  · intro a _ b _ h; exact g.injective h
  · intro b hb; exact ⟨g.symm b, by simpa using hb, by simp⟩

omit [DecidableEq α] in
/-- **Transitivity of the relabeling action on weight classes.**  Two tensors of the
same weight differ by a relabeling of the coordinates. -/
theorem exists_perm_comp_eq {x z : α → Bool} (h : wt z = wt x) :
    ∃ g : Equiv.Perm α, x ∘ g = z := by
  have hcard : Fintype.card {i // z i = true} = Fintype.card {i // x i = true} := by
    simp only [Fintype.card_subtype]
    exact h
  obtain e := Fintype.equivOfCardEq hcard
  refine ⟨Equiv.extendSubtype e, ?_⟩
  funext i
  by_cases hi : z i = true
  · have := Equiv.extendSubtype_mem e i hi
    simp [Function.comp, this, hi]
  · have := Equiv.extendSubtype_not_mem e i hi
    simp only [Bool.not_eq_true] at hi this ⊢
    simp [Function.comp, this, hi]

/-! ## Hamming distance versus weights -/

/-- The Hamming distance from an indicator tensor is the size of the symmetric
difference of the two supports. -/
theorem hdist_ind_eq (T : Finset α) (y : α → Bool) :
    hdist (ind T) y = (T \ supp y).card + (supp y \ T).card := by
  unfold hdist
  have hset : (univ.filter fun i => ind T i ≠ y i) = (T \ supp y) ∪ (supp y \ T) := by
    ext i
    simp only [mem_filter, mem_univ, true_and, mem_union, mem_sdiff, supp, ind]
    cases hy : y i <;> simp
  rw [hset, Finset.card_union_of_disjoint disjoint_sdiff_sdiff]

/-- The weight can only change by at most the Hamming distance. -/
theorem wt_le_wt_add_hdist (x y : α → Bool) : wt x ≤ wt y + hdist x y := by
  unfold wt hdist
  have hsub : supp x ⊆ supp y ∪ (univ.filter fun i => x i ≠ y i) := by
    intro i hi
    simp only [supp, mem_filter, mem_univ, true_and] at hi
    simp only [mem_union, supp, mem_filter, mem_univ, true_and]
    by_cases h : y i = true
    · exact Or.inl h
    · exact Or.inr (by simp [hi, h])
  exact le_trans (Finset.card_le_card hsub) (Finset.card_union_le _ _)

/-- Every weight in range is realized. -/
theorem exists_wt_eq {k : ℕ} (hk : k ≤ Fintype.card α) : ∃ x : α → Bool, wt x = k := by
  obtain ⟨T, -, hT⟩ := Finset.exists_subset_card_eq
    (s := (univ : Finset α)) (n := k) (by simpa [Finset.card_univ] using hk)
  exact ⟨ind T, by rw [wt_ind, hT]⟩

/-- **Interpolation lemma.**  For every admissible target weight `k` there is a
tensor of weight `k` whose Hamming distance to `y` is exactly `|k − wt y|`. -/
theorem exists_ind_hdist (y : α → Bool) {k : ℕ} (hk : k ≤ Fintype.card α) :
    ∃ T : Finset α, T.card = k ∧ hdist (ind T) y = Nat.dist k (wt y) := by
  rcases le_or_gt k (wt y) with h | h
  · obtain ⟨T, hTsub, hTcard⟩ := Finset.exists_subset_card_eq (s := supp y) (n := k) h
    refine ⟨T, hTcard, ?_⟩
    rw [hdist_ind_eq]
    have h1 : (T \ supp y).card = 0 := by
      rw [Finset.card_eq_zero, Finset.sdiff_eq_empty_iff_subset]; exact hTsub
    have h2 : (supp y \ T).card = wt y - k := by
      rw [Finset.card_sdiff_of_subset hTsub, hTcard]; rfl
    rw [h1, h2]
    unfold Nat.dist
    omega
  · obtain ⟨T, hTsup, hTcard⟩ :=
      Finset.exists_superset_card_eq (s := supp y) (n := k) (le_of_lt h) hk
    refine ⟨T, hTcard, ?_⟩
    rw [hdist_ind_eq]
    have h1 : (T \ supp y).card = k - wt y := by
      rw [Finset.card_sdiff_of_subset hTsup, hTcard]; rfl
    have h2 : (supp y \ T).card = 0 := by
      rw [Finset.card_eq_zero, Finset.sdiff_eq_empty_iff_subset]; exact hTsup
    rw [h1, h2]
    unfold Nat.dist
    omega

/-! ## The orbit distortion -/

/-- **Distortion modulo relabeling**: the least Hamming distance between `y` and a
relabeling of `x`. -/
noncomputable def orbDist (x y : α → Bool) : ℕ :=
  (univ : Finset (Equiv.Perm α)).inf' univ_nonempty (fun g => hdist (x ∘ g) y)

theorem orbDist_le_hdist (x y : α → Bool) : orbDist x y ≤ hdist x y := by
  have := Finset.inf'_le (s := (univ : Finset (Equiv.Perm α)))
    (fun g : Equiv.Perm α => hdist (x ∘ g) y) (mem_univ 1)
  simpa [orbDist, Function.comp] using this

/-- **Exact orbit distance.**  Under the full relabeling group the distortion
between two binary tensors is exactly the gap between their Hamming weights. -/
theorem orbDist_eq_dist_wt (x y : α → Bool) : orbDist x y = Nat.dist (wt x) (wt y) := by
  apply le_antisymm
  · obtain ⟨T, hTcard, hTd⟩ := exists_ind_hdist y (wt_le_card x)
    obtain ⟨g, hg⟩ := exists_perm_comp_eq (x := x) (z := ind T) (by rw [wt_ind, hTcard])
    calc orbDist x y ≤ hdist (x ∘ g) y := Finset.inf'_le _ (mem_univ g)
      _ = hdist (ind T) y := by rw [hg]
      _ = Nat.dist (wt x) (wt y) := hTd
  · refine Finset.le_inf' _ _ ?_
    intro g _
    have h1 := wt_le_wt_add_hdist (x ∘ g) y
    have h2 := wt_le_wt_add_hdist y (x ∘ g)
    rw [wt_comp_perm] at h1 h2
    rw [hdist_comm y (x ∘ g)] at h2
    unfold Nat.dist
    omega

/-! ## The sharp relabeled privacy threshold -/

/-- **Sharp threshold modulo relabeling.**  The one-codeword covering radius of the
orbit distortion is exactly `⌈|α|/2⌉`. -/
theorem orbit_coveringRadius :
    coveringRadius (orbDist : (α → Bool) → (α → Bool) → ℕ) = (Fintype.card α + 1) / 2 := by
  apply le_antisymm
  · obtain ⟨c, hc⟩ := exists_wt_eq (α := α) (k := Fintype.card α / 2) (Nat.div_le_self _ 2)
    refine (coveringRadius_le_iff _ _).mpr ⟨c, fun s => ?_⟩
    rw [orbDist_eq_dist_wt, hc]
    have hs := wt_le_card s
    unfold Nat.dist
    omega
  · obtain ⟨c, hc⟩ := exists_center_coveringRadius (orbDist : (α → Bool) → (α → Bool) → ℕ)
    have h0 := hc (ind (∅ : Finset α))
    have h1 := hc (ind (univ : Finset α))
    rw [orbDist_eq_dist_wt, wt_ind] at h0 h1
    have hcle := wt_le_card c
    simp only [Finset.card_empty, Finset.card_univ] at h0 h1
    unfold Nat.dist at h0 h1
    omega

/-- **Operational form.**  A perfectly private observer meets a relabeling-tolerant
worst-case distortion budget `D` precisely when `D ≥ ⌈|α|/2⌉`. -/
theorem orbit_privatelyAchievable_iff {M : Type*} [Nonempty M] (D : ℕ) :
    PrivatelyAchievable M (orbDist : (α → Bool) → (α → Bool) → ℕ) D
      ↔ (Fintype.card α + 1) / 2 ≤ D := by
  rw [privatelyAchievable_iff_exists_center, ← coveringRadius_le_iff, orbit_coveringRadius]

/-- **Relabeling buys exactly a factor of two.**  For at least two coordinates the
relabeled private distortion is strictly smaller than the plain Hamming one. -/
theorem orbit_coveringRadius_lt_hamming (h : 2 ≤ Fintype.card α) :
    coveringRadius (orbDist : (α → Bool) → (α → Bool) → ℕ)
      < coveringRadius (hdist : (α → Bool) → (α → Bool) → ℕ) := by
  rw [orbit_coveringRadius, hamming_coveringRadius]
  omega

/-- **Network histories, modulo participant relabeling.** -/
theorem history_relabeled_private_distortion (T n : ℕ) :
    coveringRadius (orbDist : ((Fin T × Fin n × Fin n) → Bool) →
      ((Fin T × Fin n × Fin n) → Bool) → ℕ) = (T * n * n + 1) / 2 := by
  rw [orbit_coveringRadius]
  congr 2
  simp [Fintype.card_prod]
  ring

/-! ## Exact orbit volumes and the quantitative converse -/

/-- **Exact orbit volume.**  The set of binary tensors of weight `m` — a single
orbit of the relabeling action — has exactly `C(|α|, m)` elements. -/
theorem card_wt_eq (m : ℕ) :
    (univ.filter fun s : α → Bool => wt s = m).card = (Fintype.card α).choose m := by
  have hbij : (univ.filter fun s : α → Bool => wt s = m).card
      = (Finset.powersetCard m (univ : Finset α)).card := by
    apply Finset.card_bij (fun s _ => supp s)
    · intro s hs
      simp only [mem_filter, mem_univ, true_and] at hs
      exact Finset.mem_powersetCard.mpr ⟨Finset.subset_univ _, hs⟩
    · intro s₁ _ s₂ _ h
      funext i
      have : i ∈ supp s₁ ↔ i ∈ supp s₂ := by rw [h]
      simp only [supp, mem_filter, mem_univ, true_and] at this
      cases h1 : s₁ i <;> cases h2 : s₂ i <;> simp_all
    · intro T hT
      rw [Finset.mem_powersetCard] at hT
      exact ⟨ind T, by simp [mem_filter, wt_ind, hT.2], supp_ind T⟩
  rw [hbij, Finset.card_powersetCard, Finset.card_univ]

/-- **Exact orbit ball volume (Burnside volume).**  An orbit ball of radius `D`
around a center of weight `k` is exactly the union of the binomial layers with
weights in `[k − D, k + D]`. -/
theorem orbit_ball_card_eq (c : α → Bool) (D : ℕ) :
    (univ.filter fun s : α → Bool => orbDist c s ≤ D).card
      = ∑ m ∈ Finset.Icc (wt c - D) (wt c + D), (Fintype.card α).choose m := by
  classical
  have hset : (univ.filter fun s : α → Bool => orbDist c s ≤ D)
      = (Finset.Icc (wt c - D) (wt c + D)).biUnion
          (fun m => univ.filter fun s : α → Bool => wt s = m) := by
    ext s
    simp only [mem_filter, mem_univ, true_and, Finset.mem_biUnion, Finset.mem_Icc]
    rw [orbDist_eq_dist_wt]
    unfold Nat.dist
    constructor
    · intro hs; exact ⟨wt s, by omega, rfl⟩
    · rintro ⟨m, hm, hs⟩
      omega
  rw [hset, Finset.card_biUnion]
  · exact Finset.sum_congr rfl fun m _ => card_wt_eq m
  · intro m₁ _ m₂ _ hne
    refine Finset.disjoint_left.mpr fun s hs₁ hs₂ => ?_
    simp only [mem_filter, mem_univ, true_and] at hs₁ hs₂
    exact hne (hs₁.symm.trans hs₂)

/-- **Orbit ball volume bound.**  An orbit ball of radius `D` is a union of at most
`2D + 1` binomial layers, hence has at most `(2D+1)·C(|α|, ⌊|α|/2⌋)` elements. -/
theorem orbit_ball_card_le (c : α → Bool) (D : ℕ) :
    (univ.filter fun s : α → Bool => orbDist c s ≤ D).card
      ≤ (2 * D + 1) * (Fintype.card α).choose (Fintype.card α / 2) := by
  classical
  set n := Fintype.card α
  set k := wt c with hk
  rw [orbit_ball_card_eq c D]
  have hterm : ∀ m ∈ Finset.Icc (k - D) (k + D), n.choose m ≤ n.choose (n / 2) := by
    intro m _
    exact Nat.choose_le_middle m n
  refine le_trans (Finset.sum_le_card_nsmul _ _ _ hterm) ?_
  rw [smul_eq_mul, Nat.card_Icc]
  exact Nat.mul_le_mul_right _ (by omega)

/-- **Quantitative converse modulo relabeling.**  Even when reconstruction is judged
only up to a relabeling of the participants, an observer meeting worst-case
distortion `D` must emit at least `2^{|α|} / ((2D+1)·C(|α|, ⌊|α|/2⌋))` distinct
records. -/
theorem orbit_rate_bound {M : Type*} [Fintype M] [DecidableEq M]
    (obs : (α → Bool) → M) (dec : M → (α → Bool)) (D : ℕ)
    (hrec : ∀ s, orbDist (dec (obs s)) s ≤ D) :
    2 ^ Fintype.card α
      ≤ rate obs * ((2 * D + 1) * (Fintype.card α).choose (Fintype.card α / 2)) := by
  have hcard : Fintype.card (α → Bool) = 2 ^ Fintype.card α := by simp
  rw [← hcard]
  exact card_le_rate_mul_ball obs dec orbDist D _ (fun c => orbit_ball_card_le c D) hrec

end SurveillanceNetworks.Relabeling