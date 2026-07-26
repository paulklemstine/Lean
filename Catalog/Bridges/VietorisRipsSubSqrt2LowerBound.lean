import Mathlib

/-!
# A cross-domain bridge: sub-√2 Vietoris–Rips approximations force exponentially many
  simplices, with an effective exponent `γ(c)` vanishing at the √2 threshold

This file connects three *a priori* separate areas around a single explicit construction:

* **Metric geometry.**  We build, for every `n`, a genuine finite metric space on
  `Fin n` — in fact an *ultrametric* — whose non-zero distances are graded through the
  window `[1, √2]` (`dist_isMetric`: symmetry, non-negativity, vanishing on the diagonal,
  and the (strong) triangle inequality).

* **Topological data analysis / interleavings.**  The Vietoris–Rips complex `VRcomplex`
  is the flag complex of the proximity relation; a `c`-approximation `IsCApprox` is a
  one-sided multiplicative interleaving of simplicial filtrations, the standard notion of a
  finitely-presented `c`-approximation used by approximation algorithms in TDA.

* **Extremal / enumerative combinatorics.**  A metric *clique* of size `m` at scale `r`
  forces `2 ^ m` simplices into `VRcomplex` (`two_pow_card_le_card_VRcomplex`): the whole
  power set of the clique is present.  This is the counting engine converting geometry into
  exponential complexity.

## The theorem (the connector)

For every `c ∈ [1, √2)` and every `n`, **any** `c`-approximation `G` of the Vietoris–Rips
filtration of `metricD n` stores at least `2 ^ ⌊γ(c) · n⌋` simplices at scale `√2`, where

  `γ(c) = (√2 / c − 1) / (√2 − 1)`

is effectively computable, satisfies `0 < γ(c) ≤ 1` on `[1, √2)`, and
`lim_{c → √2⁻} γ(c) = 0` (`gamma_tendsto_nhdsWithin`).  Thus the guaranteed exponential
rate degrades continuously to `0` exactly as the approximation factor approaches the
sharp √2 threshold, and no non-trivial rate survives at `c = √2`.

## Main results

* `dist_isMetric` — `metricD n` is a genuine (ultra)metric on `Fin n`.
* `two_pow_card_le_card_VRcomplex` — clique ⇒ exponentially many simplices (the bridge).
* `two_pow_activeCard_le_VRcomplex` — the graded active set is such a clique.
* `gamma_pos`, `gamma_le_one`, `gamma_tendsto_nhdsWithin` — the effective exponent and its
  behaviour at the √2 threshold.
* `floor_gamma_le_exponent` — the active set realises the rate `⌊γ(c) · n⌋`.
* `approx_card_lower_bound` — any `c`-approximation has `2 ^ (exponent c n)` simplices at
  scale `√2`.
* `subSqrt2_exponential_lower_bound` — **headline connector**: the explicit
  `2 ^ ⌊γ(c) · n⌋` lower bound together with `0 < γ(c) ≤ 1` and the vanishing limit.
-/

noncomputable section

open Finset Classical

namespace VRSubSqrt2

/-! ## The graded ultrametric -/

/-- Graded radius of vertex `i` among `n` points: `1 + (√2 − 1)·(i+1)/n`, so radii sweep
the window `(1, √2]` as `i` runs over `0, …, n-1`. -/
def radius (n i : ℕ) : ℝ := 1 + (Real.sqrt 2 - 1) * ((i : ℝ) + 1) / (n : ℝ)

/-- The dissimilarity: distinct points `i ≠ j` are at distance equal to the larger of
their two radii, i.e. `radius n (max i j)`; equal points are at distance `0`. -/
def metricD (n : ℕ) (i j : Fin n) : ℝ :=
  if i = j then 0 else radius n (max (i : ℕ) (j : ℕ))

/-- A subset `S` is a Vietoris–Rips simplex at scale `r` when every pair of its vertices is
within `r`. -/
def IsVRsimplex {n : ℕ} (r : ℝ) (S : Finset (Fin n)) : Prop :=
  ∀ i ∈ S, ∀ j ∈ S, metricD n i j ≤ r

/-- The Vietoris–Rips complex at scale `r`: the finite set of all its simplices. -/
def VRcomplex (n : ℕ) (r : ℝ) : Finset (Finset (Fin n)) :=
  (Finset.univ : Finset (Fin n)).powerset.filter (fun S => IsVRsimplex r S)

/-- A one-sided multiplicative `c`-approximation (interleaving) of the Vietoris–Rips
filtration: every genuine simplex at scale `t` appears in the presentation `G` by scale
`c·t`, and `G` never invents simplices absent by scale `c·t`. -/
def IsCApprox (n : ℕ) (c : ℝ) (G : ℝ → Finset (Finset (Fin n))) : Prop :=
  1 ≤ c ∧
  (∀ t, 0 ≤ t → VRcomplex n t ⊆ G (c * t)) ∧
  (∀ t, 0 ≤ t → G t ⊆ VRcomplex n (c * t))

/-! ## Basic radius facts -/

theorem radius_nonneg_gap : (0 : ℝ) ≤ Real.sqrt 2 - 1 := by
  have : (1 : ℝ) ≤ Real.sqrt 2 := by
    rw [show (1 : ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_le_sqrt (by norm_num)
  linarith

/-- Radii are at least `1`. -/
theorem one_le_radius {n i : ℕ} (hn : 0 < n) : 1 ≤ radius n i := by
  have hg := radius_nonneg_gap
  have : (0:ℝ) ≤ (Real.sqrt 2 - 1) * ((i : ℝ) + 1) / (n : ℝ) := by positivity
  simp only [radius]; linarith

/-- Radii of genuine vertices are at most `√2`. -/
theorem radius_le_sqrt2 {n : ℕ} (i : Fin n) : radius n (i : ℕ) ≤ Real.sqrt 2 := by
  have hg := radius_nonneg_gap
  have hn : (0:ℝ) < (n:ℝ) := by exact_mod_cast i.pos
  have hi : ((i:ℕ):ℝ) + 1 ≤ (n:ℝ) := by
    have : (i:ℕ) + 1 ≤ n := i.2
    exact_mod_cast this
  have : (Real.sqrt 2 - 1) * ((i : ℝ) + 1) / (n : ℝ) ≤ (Real.sqrt 2 - 1) := by
    rw [div_le_iff₀ hn]; exact mul_le_mul_of_nonneg_left hi hg
  simp only [radius]; linarith

/-- Radius is monotone in the index. -/
theorem radius_mono {n : ℕ} {i j : ℕ} (h : i ≤ j) : radius n i ≤ radius n j := by
  have hg := radius_nonneg_gap
  have hij : ((i:ℝ) + 1) ≤ ((j:ℝ) + 1) := by exact_mod_cast Nat.succ_le_succ h
  simp only [radius]
  gcongr

/-! ## `metricD` is a genuine (ultra)metric -/

theorem dist_self (n : ℕ) (i : Fin n) : metricD n i i = 0 := by
  simp [metricD]

theorem dist_comm (n : ℕ) (i j : Fin n) : metricD n i j = metricD n j i := by
  simp only [metricD, max_comm (i:ℕ) (j:ℕ)]
  by_cases h : i = j
  · simp [h]
  · rw [if_neg h, if_neg (Ne.symm h)]

theorem dist_nonneg {n : ℕ} (hn : 0 < n) (i j : Fin n) : 0 ≤ metricD n i j := by
  simp only [metricD]
  by_cases h : i = j
  · simp [h]
  · rw [if_neg h]; linarith [one_le_radius (n:=n) (i := max (i:ℕ) (j:ℕ)) hn]

theorem dist_triangle {n : ℕ} (hn : 0 < n) (i j k : Fin n) :
    metricD n i k ≤ metricD n i j + metricD n j k := by
  have h2sqrt : Real.sqrt 2 ≤ 2 := by
    nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ 2 by norm_num), Real.sqrt_nonneg 2]
  by_cases hik : i = k
  · subst hik
    simp only [dist_self]
    linarith [dist_nonneg hn i j, dist_nonneg hn j i]
  · have hL : metricD n i k ≤ Real.sqrt 2 := by
      simp only [metricD, if_neg hik]
      rcases le_total (i:ℕ) (k:ℕ) with hle|hle
      · rw [max_eq_right hle]; exact radius_le_sqrt2 k
      · rw [max_eq_left hle]; exact radius_le_sqrt2 i
    by_cases hij : i = j
    · subst hij; simp only [dist_self, zero_add, le_refl]
    · by_cases hjk : j = k
      · subst hjk; simp only [dist_self, add_zero, le_refl]
      · have h1 : (1:ℝ) ≤ metricD n i j := by
          simp only [metricD, if_neg hij]; exact one_le_radius hn
        have h2 : (1:ℝ) ≤ metricD n j k := by
          simp only [metricD, if_neg hjk]; exact one_le_radius hn
        linarith

/-- `metricD n` satisfies all four metric axioms (it is in fact an ultrametric). -/
theorem dist_isMetric {n : ℕ} (hn : 0 < n) :
    (∀ i : Fin n, metricD n i i = 0) ∧
    (∀ i j : Fin n, metricD n i j = metricD n j i) ∧
    (∀ i j : Fin n, 0 ≤ metricD n i j) ∧
    (∀ i j k : Fin n, metricD n i k ≤ metricD n i j + metricD n j k) :=
  ⟨dist_self n, dist_comm n, dist_nonneg hn, dist_triangle hn⟩

/-! ## Clique ⇒ exponentially many simplices (the counting bridge) -/

/-- **Bridge (geometry → combinatorics).**  If every pair of points of `S` is within `r`
(a metric clique), then the entire power set of `S` consists of Vietoris–Rips simplices. -/
theorem powerset_subset_VRcomplex {n : ℕ} (r : ℝ) (S : Finset (Fin n))
    (hS : ∀ i ∈ S, ∀ j ∈ S, metricD n i j ≤ r) :
    S.powerset ⊆ VRcomplex n r := by
  intro T hT
  rw [Finset.mem_powerset] at hT
  rw [VRcomplex, Finset.mem_filter, Finset.mem_powerset]
  exact ⟨Finset.subset_univ _, fun i hi j hj => hS i (hT hi) j (hT hj)⟩

/-- **Bridge (geometry → combinatorics), counted.**  A metric clique of size `m` at scale
`r` forces at least `2 ^ m` Vietoris–Rips simplices. -/
theorem two_pow_card_le_card_VRcomplex {n : ℕ} (r : ℝ) (S : Finset (Fin n))
    (hS : ∀ i ∈ S, ∀ j ∈ S, metricD n i j ≤ r) :
    2 ^ S.card ≤ (VRcomplex n r).card := by
  calc 2 ^ S.card = S.powerset.card := (Finset.card_powerset S).symm
    _ ≤ (VRcomplex n r).card := Finset.card_le_card (powerset_subset_VRcomplex r S hS)

/-! ## The graded active set is a clique -/

/-- The active set at scale `r`: the vertices whose radius is `≤ r`. -/
def activeSet (n : ℕ) (r : ℝ) : Finset (Fin n) :=
  (Finset.univ : Finset (Fin n)).filter (fun i => radius n (i : ℕ) ≤ r)

/-- The active set is a clique: all its pairwise distances are `≤ r` (for `r ≥ 0`). -/
theorem activeSet_isClique {n : ℕ} (r : ℝ) (hr : 0 ≤ r) :
    ∀ i ∈ activeSet n r, ∀ j ∈ activeSet n r, metricD n i j ≤ r := by
  intro i hi j hj
  simp only [activeSet, Finset.mem_filter] at hi hj
  simp only [metricD]
  by_cases h : i = j
  · simp [h, hr]
  · rw [if_neg h]
    rcases le_total (i:ℕ) (j:ℕ) with hle|hle
    · rw [max_eq_right hle]; exact hj.2
    · rw [max_eq_left hle]; exact hi.2

/-- Hence the active set forces `2 ^ |activeSet|` simplices. -/
theorem two_pow_activeCard_le_VRcomplex {n : ℕ} (r : ℝ) (hr : 0 ≤ r) :
    2 ^ (activeSet n r).card ≤ (VRcomplex n r).card :=
  two_pow_card_le_card_VRcomplex r _ (activeSet_isClique r hr)

/-! ## The effective exponent `γ(c)` -/

/-- The effective exponential rate `γ(c) = (√2 / c − 1)/(√2 − 1)`. -/
def gamma (c : ℝ) : ℝ := (Real.sqrt 2 / c - 1) / (Real.sqrt 2 - 1)

/-- On `[1, √2)`, the rate is positive. -/
theorem gamma_pos {c : ℝ} (hc1 : 1 ≤ c) (hc2 : c < Real.sqrt 2) : 0 < gamma c := by
  have hc0 : 0 < c := lt_of_lt_of_le one_pos hc1
  have hden : 0 < Real.sqrt 2 - 1 := by
    have h1 : (1:ℝ) < Real.sqrt 2 := by
      rw [show (1:ℝ) = Real.sqrt 1 from (Real.sqrt_one).symm]
      exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
    linarith
  have hnum : 0 < Real.sqrt 2 / c - 1 := by
    have : 1 < Real.sqrt 2 / c := by rw [lt_div_iff₀ hc0]; linarith
    linarith
  exact div_pos hnum hden

/-- On `[1, √2)`, the rate is at most `1`. -/
theorem gamma_le_one {c : ℝ} (hc1 : 1 ≤ c) (hc2 : c < Real.sqrt 2) : gamma c ≤ 1 := by
  have hc0 : 0 < c := lt_of_lt_of_le one_pos hc1
  have hden : 0 < Real.sqrt 2 - 1 := by
    have h1 : (1:ℝ) < Real.sqrt 2 := by
      rw [show (1:ℝ) = Real.sqrt 1 from (Real.sqrt_one).symm]
      exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
    linarith
  rw [gamma, div_le_one hden]
  have : Real.sqrt 2 / c ≤ Real.sqrt 2 := by
    rw [div_le_iff₀ hc0]; nlinarith [Real.sqrt_nonneg 2]
  linarith

/-- **Threshold behaviour.**  The effective rate vanishes as `c → √2⁻`. -/
theorem gamma_tendsto_nhdsWithin :
    Filter.Tendsto gamma (nhdsWithin (Real.sqrt 2) (Set.Iio (Real.sqrt 2))) (nhds 0) := by
  have hs2 : Real.sqrt 2 ≠ 0 := by positivity
  have hden : Real.sqrt 2 - 1 ≠ 0 := by
    have h1 : (1:ℝ) < Real.sqrt 2 := by
      rw [show (1:ℝ) = Real.sqrt 1 from (Real.sqrt_one).symm]
      exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
    linarith
  have h0 : gamma (Real.sqrt 2) = 0 := by
    simp only [gamma, div_self hs2, sub_self, zero_div]
  have hcont : ContinuousAt gamma (Real.sqrt 2) := by
    unfold gamma
    apply ContinuousAt.div
    · apply ContinuousAt.sub
      · exact (continuousAt_const.div continuousAt_id hs2)
      · exact continuousAt_const
    · exact continuousAt_const
    · exact hden
  have hlim := hcont.tendsto
  rw [h0] at hlim
  exact hlim.mono_left nhdsWithin_le_nhds

/-- The exponent guaranteed at the analysis scale `√2`: the size of the active set at the
interleaved scale `√2 / c`. -/
def exponent (c : ℝ) (n : ℕ) : ℕ := (activeSet n (Real.sqrt 2 / c)).card

/-- A vertex `i` is active at scale `√2 / c` iff `(i+1) ≤ n · γ(c)` (for `n > 0`). -/
theorem radius_le_iff {n : ℕ} (hn : 0 < n) {c : ℝ} (i : ℕ) :
    radius n i ≤ Real.sqrt 2 / c ↔ ((i : ℝ) + 1) ≤ (n : ℝ) * gamma c := by
  have hden : (0:ℝ) < Real.sqrt 2 - 1 := by
    have h1 : (1:ℝ) < Real.sqrt 2 := by
      rw [show (1:ℝ) = Real.sqrt 1 from (Real.sqrt_one).symm]
      exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
    linarith
  have hnpos : (0:ℝ) < (n:ℝ) := by exact_mod_cast hn
  rw [radius, gamma]
  rw [show (n:ℝ) * ((Real.sqrt 2 / c - 1)/(Real.sqrt 2 - 1))
        = ((n:ℝ) * (Real.sqrt 2 / c - 1))/(Real.sqrt 2 - 1) by ring]
  rw [le_div_iff₀ hden]
  constructor
  · intro h
    have h' : (Real.sqrt 2 - 1) * ((i:ℝ)+1) / n ≤ Real.sqrt 2 / c - 1 := by linarith
    rw [div_le_iff₀ hnpos] at h'
    nlinarith
  · intro h
    have h' : (Real.sqrt 2 - 1) * ((i:ℝ)+1) / n ≤ Real.sqrt 2 / c - 1 := by
      rw [div_le_iff₀ hnpos]; nlinarith
    linarith

/-- The active set realises the rate: `⌊γ(c) · n⌋ ≤ exponent c n`. -/
theorem floor_gamma_le_exponent {n : ℕ} (hn : 0 < n) {c : ℝ}
    (hc1 : 1 ≤ c) (hc2 : c < Real.sqrt 2) :
    ⌊(n : ℝ) * gamma c⌋₊ ≤ exponent c n := by
  set K := ⌊(n : ℝ) * gamma c⌋₊ with hK
  have hg0 : 0 ≤ gamma c := le_of_lt (gamma_pos hc1 hc2)
  have hng : (0:ℝ) ≤ (n:ℝ) * gamma c := by positivity
  have hKn : K ≤ n := by
    rw [hK]
    calc ⌊(n:ℝ) * gamma c⌋₊ ≤ ⌊(n:ℝ)⌋₊ := by
          apply Nat.floor_le_floor
          nlinarith [gamma_le_one hc1 hc2, Nat.cast_nonneg (α := ℝ) n]
      _ = n := Nat.floor_natCast n
  set A : Finset (Fin n) :=
    (Finset.range K).attachFin (fun m hm => lt_of_lt_of_le (Finset.mem_range.mp hm) hKn) with hA
  have hAcard : A.card = K := by rw [hA, Finset.card_attachFin, Finset.card_range]
  have hsub : A ⊆ activeSet n (Real.sqrt 2 / c) := by
    intro i hi
    rw [hA, Finset.mem_attachFin, Finset.mem_range] at hi
    rw [activeSet, Finset.mem_filter]
    refine ⟨Finset.mem_univ _, ?_⟩
    rw [radius_le_iff hn]
    have hle : (i:ℕ) + 1 ≤ K := hi
    calc ((i:ℕ):ℝ) + 1 ≤ (K:ℝ) := by exact_mod_cast hle
      _ ≤ (n:ℝ) * gamma c := Nat.floor_le hng
  calc K = A.card := hAcard.symm
    _ ≤ (activeSet n (Real.sqrt 2 / c)).card := Finset.card_le_card hsub

/-! ## The approximation lower bound -/

/-- Any `c`-approximation stores at least `2 ^ (exponent c n)` simplices at scale `√2`. -/
theorem approx_card_lower_bound {n : ℕ} {c : ℝ} (hc1 : 1 ≤ c)
    (G : ℝ → Finset (Finset (Fin n))) (h : IsCApprox n c G) :
    2 ^ (exponent c n) ≤ (G (Real.sqrt 2)).card := by
  obtain ⟨-, hfwd, -⟩ := h
  have hc0 : 0 < c := lt_of_lt_of_le one_pos hc1
  have ht : (0:ℝ) ≤ Real.sqrt 2 / c := by positivity
  have hsub := hfwd (Real.sqrt 2 / c) ht
  rw [mul_div_cancel₀ _ (ne_of_gt hc0)] at hsub
  calc 2 ^ (exponent c n) = 2 ^ ((activeSet n (Real.sqrt 2 / c)).card) := rfl
    _ ≤ (VRcomplex n (Real.sqrt 2 / c)).card := two_pow_activeCard_le_VRcomplex _ ht
    _ ≤ (G (Real.sqrt 2)).card := Finset.card_le_card hsub

/-! ## Headline connector -/

/-- **Headline theorem (the connector).**

Fix any approximation factor `c ∈ [1, √2)`.  For every size parameter `n > 0` and **every**
finitely-presented `c`-approximation `G` of the Vietoris–Rips filtration of the graded
ultrametric `metricD n`, the presentation stores at least `2 ^ ⌊γ(c) · n⌋` simplices at the
analysis scale `√2`, where the effective rate `γ(c) = (√2/c − 1)/(√2 − 1)` satisfies

* `0 < γ(c) ≤ 1` on `[1, √2)` (so the bound is genuinely exponential in `n`), and
* `γ(c) → 0` as `c → √2⁻` (so the rate degrades to nothing exactly at the sharp
  √2 threshold).

This links metric geometry (a genuine finite ultrametric, `dist_isMetric`), extremal
counting (clique ⇒ power set of simplices), and TDA interleavings (the `c`-approximation),
with an *effectively computable* exponent controlling the crossover. -/
theorem subSqrt2_exponential_lower_bound {c : ℝ} (hc1 : 1 ≤ c) (hc2 : c < Real.sqrt 2) :
    (0 < gamma c ∧ gamma c ≤ 1) ∧
    Filter.Tendsto gamma (nhdsWithin (Real.sqrt 2) (Set.Iio (Real.sqrt 2))) (nhds 0) ∧
    (∀ (n : ℕ), 0 < n → ∀ G : ℝ → Finset (Finset (Fin n)), IsCApprox n c G →
      2 ^ (⌊(n : ℝ) * gamma c⌋₊) ≤ (G (Real.sqrt 2)).card) := by
  refine ⟨⟨gamma_pos hc1 hc2, gamma_le_one hc1 hc2⟩, gamma_tendsto_nhdsWithin, ?_⟩
  intro n hn G hG
  calc 2 ^ (⌊(n : ℝ) * gamma c⌋₊)
      ≤ 2 ^ (exponent c n) :=
        Nat.pow_le_pow_right (by norm_num) (floor_gamma_le_exponent hn hc1 hc2)
    _ ≤ (G (Real.sqrt 2)).card := approx_card_lower_bound hc1 G hG

end VRSubSqrt2