import Mathlib
import Catalog.Novelty.VietorisRipsCliqueBridge

/-!
# The canonical Euclidean √2 threshold: an all-or-nothing exponential jump

This file realises the "√2 phenomenon" of Vietoris–Rips complexes in genuine Euclidean
space, using the canonical configuration whose distances make the threshold famous: the
`n` standard basis vectors of `ℝ^n`, which are pairwise at distance exactly `√2`.

Where the graded ultrametric construction (companion development
`VietorisRipsSubSqrt2LowerBound`) was engineered so that its Vietoris–Rips complex grows
*gradually* as the scale approaches `√2`, the standard Euclidean simplex behaves in exactly
the opposite, sharpest possible way:

* **At scale `√2`** every subset of vertices is a Vietoris–Rips simplex, so the complex is
  the entire power set: `2 ^ n` simplices (`euclidean_VRcomplex_sqrt2_card`).
* **At every scale `r < √2`** the complex collapses completely to vertices: only the empty
  set and the `n` singletons survive, giving exactly `n + 1` simplices
  (`euclidean_VRcomplex_sub_sqrt2_card`).

Thus the canonical Euclidean configuration exhibits a genuine *exponential jump* precisely
at `√2` (`euclidean_sqrt2_sharp_threshold`): the simplex count leaps from the linear `n + 1`
to the exponential `2 ^ n` at the single scale `√2`, with nothing in between.

## Cross-domain connector

The construction ties together three areas around one object:

* **Metric geometry (Euclidean).**  `dist_pt_eq_sqrt2` : the standard basis vectors sit at
  the exact √2 geometry inside `EuclideanSpace ℝ (Fin n)`.
* **Enumerative combinatorics.**  Counting simplices reduces to counting subsets:
  `2 ^ n` above the threshold, `n + 1` below it.
* **Topological data analysis / interleavings.**  A one-sided multiplicative
  `c`-approximation `IsCApprox` is squeezed from both sides:
  `euclidean_approx_lower_bound` (exponentially many simplices survive at scale `c·√2`) and
  `euclidean_approx_upper_bound` (only `n + 1` simplices are possible below the interleaved
  threshold).  Together they localise the entire exponential blow-up to the √2 scale.

The contrast with the graded construction is the analytical point (see the Lab Notes): the
plain Euclidean simplex *cannot* furnish sub-√2 exponential lower bounds because its complex
collapses below `√2`; obtaining sub-√2 exponential rates genuinely requires a graded
geometry.
-/

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): the canonical √2 object — the standard basis of ℝ^n — should
--   make the Vietoris–Rips √2 threshold *sharp*: exponential at √2, trivial below it. This
--   is a bolder, cleaner claim than the graded lower bound of the previous cycle, which
--   only guaranteed a *rate* γ(c) degrading to 0.
-- Experiment (Experimenter): computed dist(e_i, e_j) = √2 for i ≠ j via the ℓ² distance
--   formula (sum of two unit squares). Verified that at scale √2 every subset is a simplex,
--   and that below √2 any 2-element subset is excluded, forcing card ≤ 1.
-- Analysis (Analyst): the jump is `n + 1  ⟶  2 ^ n`, an exponential discontinuity located
--   at exactly one scale. Crucially, the sub-√2 complex is *trivial*: this explains WHY the
--   previous cycle needed a graded ultrametric — the plain Euclidean simplex gives no sub-√2
--   exponential content. "True but different": Euclidean sharpness ≠ graded persistence.
-- Critique (Critic): guarded every count by `0 ≤ r` and `r < √2`; the exponential gap
--   `n + 1 < 2 ^ n` is asserted only for `n ≥ 2` (it is false for n = 0, 1). The
--   approximation bounds are two-sided (lower AND upper), ruling out a vacuous statement.
-- Synthesis (PI): packaged as `euclidean_sqrt2_sharp_threshold` (the counting jump) and the
--   pair `euclidean_approx_lower_bound` / `euclidean_approx_upper_bound` (the interleaving
--   localisation), a self-contained Euclidean companion to the graded lower bound.

noncomputable section

open Finset Classical

namespace VREuclideanSqrt2

/-! ## The canonical Euclidean configuration -/

/-- The `i`-th point of the canonical configuration: the standard basis vector `e_i` of
`ℝ^n`, i.e. the unit vector along coordinate `i`. -/
def pt (n : ℕ) (i : Fin n) : EuclideanSpace ℝ (Fin n) := EuclideanSpace.single i (1 : ℝ)

/-- `√2 ≥ 0`. -/
theorem sqrt2_nonneg : (0 : ℝ) ≤ Real.sqrt 2 := Real.sqrt_nonneg 2

/-- **Euclidean √2 geometry.**  Two distinct standard basis vectors are at distance exactly
`√2`. -/
theorem dist_pt_eq_sqrt2 {n : ℕ} {i j : Fin n} (h : i ≠ j) :
    dist (pt n i) (pt n j) = Real.sqrt 2 := by
  unfold pt
  rw [EuclideanSpace.dist_eq]
  have hsum : ∑ k, dist ((EuclideanSpace.single i (1:ℝ)).ofLp k)
      ((EuclideanSpace.single j (1:ℝ)).ofLp k) ^ 2 = 2 := by
    simp only [EuclideanSpace.ofLp_single]
    rw [Finset.sum_eq_add_of_mem i j (Finset.mem_univ i) (Finset.mem_univ j) h]
    · rw [dist_eq_norm, dist_eq_norm,
          Pi.single_eq_same, Pi.single_eq_of_ne h, Pi.single_eq_same,
          Pi.single_eq_of_ne (Ne.symm h)]
      norm_num
    · intro k _ hk
      rw [dist_eq_norm, Pi.single_eq_of_ne hk.1, Pi.single_eq_of_ne hk.2]
      simp
  rw [hsum]

/-! ## The Euclidean Vietoris–Rips complex -/

/-- A subset `S` is a Vietoris–Rips simplex at scale `r` when every pair of its points is
within `r`. -/
def EIsVRsimplex (n : ℕ) (r : ℝ) (S : Finset (Fin n)) : Prop :=
  ∀ i ∈ S, ∀ j ∈ S, dist (pt n i) (pt n j) ≤ r

/-- The Euclidean Vietoris–Rips complex at scale `r`: the finite set of all its simplices. -/
def EVRcomplex (n : ℕ) (r : ℝ) : Finset (Finset (Fin n)) :=
  (Finset.univ : Finset (Fin n)).powerset.filter (fun S => EIsVRsimplex n r S)

/-! ## At scale √2: the full power set -/

/-- At scale `√2` every subset is a simplex. -/
theorem EIsVRsimplex_sqrt2 {n : ℕ} (S : Finset (Fin n)) : EIsVRsimplex n (Real.sqrt 2) S := by
  intro i _ j _
  by_cases h : i = j
  · subst h; simp
  · rw [dist_pt_eq_sqrt2 h]

/-- Hence the complex at scale `√2` is the entire power set. -/
theorem EVRcomplex_sqrt2_eq_powerset {n : ℕ} :
    EVRcomplex n (Real.sqrt 2) = (Finset.univ : Finset (Fin n)).powerset := by
  unfold EVRcomplex
  rw [Finset.filter_true_of_mem]
  intro S _
  exact EIsVRsimplex_sqrt2 S

/-- **Above the threshold: exponentially many simplices.**  The complex at scale `√2` has
exactly `2 ^ n` simplices. -/
theorem euclidean_VRcomplex_sqrt2_card {n : ℕ} : (EVRcomplex n (Real.sqrt 2)).card = 2 ^ n := by
  rw [EVRcomplex_sqrt2_eq_powerset, Finset.card_powerset]
  simp

/-! ## Below the threshold: the complex collapses to vertices -/

/-- Below `√2`, a subset is a simplex iff it has at most one vertex. -/
theorem EIsVRsimplex_iff_card_le_one {n : ℕ} {r : ℝ} (hr0 : 0 ≤ r) (hr : r < Real.sqrt 2)
    (S : Finset (Fin n)) : EIsVRsimplex n r S ↔ S.card ≤ 1 := by
  constructor
  · intro hS
    rw [Finset.card_le_one]
    intro a ha b hb
    by_contra hab
    have := hS a ha b hb
    rw [dist_pt_eq_sqrt2 hab] at this
    linarith
  · intro hcard i hi j hj
    have : i = j := (Finset.card_le_one.mp hcard) i hi j hj
    subst this
    simpa [dist_self] using hr0

/-- Below `√2`, the complex is exactly the subsets of cardinality at most one. -/
theorem EVRcomplex_sub_sqrt2_eq {n : ℕ} {r : ℝ} (hr0 : 0 ≤ r) (hr : r < Real.sqrt 2) :
    EVRcomplex n r = (Finset.univ : Finset (Fin n)).powerset.filter (fun S => S.card ≤ 1) := by
  unfold EVRcomplex
  apply Finset.filter_congr
  intro S _
  exact EIsVRsimplex_iff_card_le_one hr0 hr S

/-- The number of subsets of `Fin n` of cardinality at most one is `n + 1`. -/
theorem card_powerset_filter_card_le_one {n : ℕ} :
    ((Finset.univ : Finset (Fin n)).powerset.filter (fun S => S.card ≤ 1)).card = n + 1 := by
  have hset : (Finset.univ : Finset (Fin n)).powerset.filter (fun S => S.card ≤ 1)
      = Finset.powersetCard 0 (Finset.univ : Finset (Fin n))
        ∪ Finset.powersetCard 1 Finset.univ := by
    ext S
    simp only [Finset.mem_filter, Finset.mem_powerset, Finset.mem_union,
      Finset.mem_powersetCard, Finset.subset_univ, true_and]
    omega
  rw [hset, Finset.card_union_of_disjoint]
  · rw [Finset.card_powersetCard, Finset.card_powersetCard]
    simp [Nat.add_comm]
  · rw [Finset.disjoint_left]
    intro S hS hS'
    simp only [Finset.mem_powersetCard] at hS hS'
    omega

/-- **Below the threshold: the complex collapses.**  At every scale `r < √2` the complex has
exactly `n + 1` simplices — the empty set and the `n` singletons. -/
theorem euclidean_VRcomplex_sub_sqrt2_card {n : ℕ} {r : ℝ} (hr0 : 0 ≤ r) (hr : r < Real.sqrt 2) :
    (EVRcomplex n r).card = n + 1 := by
  rw [EVRcomplex_sub_sqrt2_eq hr0 hr, card_powerset_filter_card_le_one]

/-! ## The sharp exponential jump -/

/-- For `n ≥ 2`, the linear count is strictly below the exponential count. -/
theorem succ_lt_two_pow {n : ℕ} (hn : 2 ≤ n) : n + 1 < 2 ^ n := by
  induction n with
  | zero => omega
  | succ m ih =>
    rcases Nat.lt_or_ge m 2 with hm | hm
    · interval_cases m <;> simp_all
    · have hih := ih hm
      calc m + 1 + 1 < 2 ^ m + 2 ^ m := by omega
        _ = 2 ^ (m + 1) := by ring

/-- **Headline: the canonical Euclidean √2 threshold is sharp.**

For the standard basis configuration in `ℝ^n`, the Vietoris–Rips simplex count jumps from
the linear value `n + 1` at every scale `r < √2` to the exponential value `2 ^ n` at scale
`√2`; for `n ≥ 2` this is a strict exponential increase concentrated at the single scale
`√2`. -/
theorem euclidean_sqrt2_sharp_threshold {n : ℕ} {r : ℝ} (hr0 : 0 ≤ r) (hr : r < Real.sqrt 2) :
    (EVRcomplex n r).card = n + 1 ∧
    (EVRcomplex n (Real.sqrt 2)).card = 2 ^ n ∧
    (2 ≤ n → (EVRcomplex n r).card < (EVRcomplex n (Real.sqrt 2)).card) := by
  refine ⟨euclidean_VRcomplex_sub_sqrt2_card hr0 hr, euclidean_VRcomplex_sqrt2_card, ?_⟩
  intro hn
  rw [euclidean_VRcomplex_sub_sqrt2_card hr0 hr, euclidean_VRcomplex_sqrt2_card]
  exact succ_lt_two_pow hn

/-! ## Interleaving: localising the blow-up -/

/-- A one-sided multiplicative `c`-approximation (interleaving) of the Euclidean
Vietoris–Rips filtration: every genuine simplex at scale `t` appears in the presentation `G`
by scale `c·t`, and `G` never invents simplices absent by scale `c·t`. -/
def IsCApprox (n : ℕ) (c : ℝ) (G : ℝ → Finset (Finset (Fin n))) : Prop :=
  1 ≤ c ∧
  (∀ t, 0 ≤ t → EVRcomplex n t ⊆ G (c * t)) ∧
  (∀ t, 0 ≤ t → G t ⊆ EVRcomplex n (c * t))

/-- **Exponential survival at the threshold.**  Any `c`-approximation stores at least
`2 ^ n` simplices at scale `c·√2`. -/
theorem euclidean_approx_lower_bound {n : ℕ} {c : ℝ}
    (G : ℝ → Finset (Finset (Fin n))) (h : IsCApprox n c G) :
    2 ^ n ≤ (G (c * Real.sqrt 2)).card := by
  obtain ⟨-, hfwd, -⟩ := h
  have hsub := hfwd (Real.sqrt 2) sqrt2_nonneg
  calc 2 ^ n = (EVRcomplex n (Real.sqrt 2)).card := euclidean_VRcomplex_sqrt2_card.symm
    _ ≤ (G (c * Real.sqrt 2)).card := Finset.card_le_card hsub

/-- **Polynomial ceiling below the threshold.**  For any scale `t` whose interleaved image
`c·t` is still below `√2`, the `c`-approximation stores at most `n + 1` simplices. -/
theorem euclidean_approx_upper_bound {n : ℕ} {c : ℝ}
    (G : ℝ → Finset (Finset (Fin n))) (h : IsCApprox n c G)
    {t : ℝ} (ht0 : 0 ≤ t) (hlt : c * t < Real.sqrt 2) :
    (G t).card ≤ n + 1 := by
  obtain ⟨hc1, -, hbwd⟩ := h
  have hc0 : (0:ℝ) ≤ c := le_trans zero_le_one hc1
  have hct0 : 0 ≤ c * t := mul_nonneg hc0 ht0
  have hsub := hbwd t ht0
  calc (G t).card ≤ (EVRcomplex n (c * t)).card := Finset.card_le_card hsub
    _ = n + 1 := euclidean_VRcomplex_sub_sqrt2_card hct0 hlt

/-! ## Cross-reference: the canonical simplex is globally extremal

The companion clique-complex development proves that the clique complex of *any* proximity
graph on `n` vertices has at most `2 ^ n` cliques (`VRCliqueBridge.allCliques_card_le`).
The Euclidean standard simplex realises this global maximum exactly at scale `√2`: its
Vietoris–Rips complex has `2 ^ n` simplices, so no configuration on `n` points can carry a
larger clique complex.  This ties the present Euclidean sharpness result to the extremal
graph-theoretic bound of the companion file. -/

/-- **Global extremality.**  At scale `√2` the canonical Euclidean simplex carries at least
as many simplices as the clique complex of any graph on `n` vertices — it attains the
extremal `2 ^ n` maximum. -/
theorem euclidean_sqrt2_is_extremal {n : ℕ} (H : SimpleGraph (Fin n)) :
    (VRCliqueBridge.allCliques H).card ≤ (EVRcomplex n (Real.sqrt 2)).card := by
  rw [euclidean_VRcomplex_sqrt2_card]
  exact VRCliqueBridge.allCliques_card_le H

end VREuclideanSqrt2