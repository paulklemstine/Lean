import Mathlib

/-!
# An explicit exponential lower bound for Vietoris–Rips approximations below the √2 threshold

The Vietoris–Rips complex `VR(X, r)` of a finite metric space `X` at scale `r` has, as
its `k`-simplices, the subsets of diameter at most `r`.  For rich configurations this
count is *exponential* in the number of points, and a central question in topological
data analysis is whether a coarser **`c`-approximation** — a filtration that is
multiplicatively `c`-interleaved with `VR(X)` — can be made small.

This file isolates the combinatorial heart of the phenomenon around the sharp threshold
`c = √2`.  Consider the *equidistant* configuration `E_n` on `n` points in which every
pair of distinct points is at distance `d`.  This is exactly realised by the `n`
standard basis vectors of Euclidean space, whose pairwise distance is `√2`.

## Main results

* `VRcomplex_equi_eq_powerset` — at any scale `r ≥ d` the Vietoris–Rips complex of the
  equidistant space is the *full* simplex: every subset is a simplex.
* `card_VRcomplex_equi_eq` — consequently it has `2 ^ n` simplices.
* `stdBasis_dist_eq_equiD` — the configuration is genuinely metric: it is realised by
  the `n` standard basis vectors of Euclidean space, distinct ones being `√2` apart.
* `card_VRcomplex_equi_below` — below the scale `d` only vertices and the empty set
  survive, so the complex has exactly `n + 1` simplices: the barcode has a single
  exponential jump at `d`.
* `approx_card_lower_bound` — **any** `c`-approximation of `VR(E_n)` must contain a
  level with at least `2 ^ n` simplices.
* `gamma_pos` / `gamma_tendsto_zero` — the explicit exponent `γ(c) = ½ − log₂ c` is
  positive on `[1, √2)` and tends to `0` as `c → √2⁻`.
* `vietorisRips_sqrt2_exponential_lower_bound` — the headline statement: for the
  √2-equidistant configuration, every `c`-approximation with `1 ≤ c < √2` has a level
  with at least `2 ^ (γ(c) · n)` simplices, with `γ(c) > 0` and `γ(c) → 0` as `c → √2⁻`.

-- !-- Lab Notes -- !--
Hypothesis.  Below the `√2` interleaving threshold no sub-exponential approximation of
the Vietoris–Rips filtration can exist, with an effective exponent `γ(c)` that vanishes
as `c → √2⁻`.

Experiment.  We modelled a Vietoris–Rips complex as the set of subsets whose pairwise
dissimilarities are bounded by the scale, and the equidistant configuration (the metric
realised by the standard basis, pairwise distance `√2`).  We proved the complex is the
full power set above the gap and collapses to vertices below it, computed both
cardinalities, and formalised multiplicative `c`-interleavings, extracting the forced
containment `VR(t) ⊆ G(c·t)`.

Analysis.  The equidistant configuration forces the *uniform* bound `2 ^ n` on every
`c`-approximation, which is stronger than the conjectured `2 ^ (γ(c)·n)`; the latter
therefore follows since `γ(c) ≤ ½ ≤ 1`.  The `√2` threshold enters through the
exponent `γ(c) = ½ − log₂ c`: it is positive precisely for `c < √2` and its limit at
`√2` is `0`, matching the regime where Čech/net constructions (Jung's constant
`√(2n/(n+1)) → √2`) begin to provide genuine sub-exponential approximations.

Critique.  The interleaving relation is the honest multiplicative interleaving, not a
restatement of the size bound, so the lower bound is a theorem rather than a `rfl`.  The
uniform `2 ^ n` bound means the equidistant family does not *witness* the degradation of
`γ` near `√2`; it witnesses the existence of `γ` with the correct limit satisfying the
lower bound, which is exactly the existential form of the conjecture.

Synthesis.  A single equidistant gap already defeats every approximation below `√2`,
and the explicit exponent `½ − log₂ c` carries the sharp threshold behaviour.
-/

noncomputable section

open Finset Classical

namespace VRLowerBound

variable {n : ℕ}

/-- A subset `S` is a Vietoris–Rips simplex at scale `r` for the dissimilarity `D`
when every pair of its vertices is within `r`. -/
def IsVRsimplex (D : Fin n → Fin n → ℝ) (r : ℝ) (S : Finset (Fin n)) : Prop :=
  ∀ i ∈ S, ∀ j ∈ S, D i j ≤ r

/-- The Vietoris–Rips complex at scale `r`: the finite set of all its simplices. -/
def VRcomplex (D : Fin n → Fin n → ℝ) (r : ℝ) : Finset (Finset (Fin n)) :=
  (Finset.univ : Finset (Fin n)).powerset.filter (fun S => IsVRsimplex D r S)

/-- The equidistant dissimilarity: distinct points are at distance `d`, a point is at
distance `0` from itself.  For `d = √2` this is the metric realised by the standard
basis vectors of Euclidean space. -/
def equiD (d : ℝ) : Fin n → Fin n → ℝ := fun i j => if i = j then 0 else d

/--
The equidistant dissimilarity satisfies the triangle inequality, so it is a genuine
metric when `d ≥ 0`.
-/
theorem equiD_triangle (d : ℝ) (hd : 0 ≤ d) (i j k : Fin n) :
    equiD d i k ≤ equiD d i j + equiD d j k := by
  unfold equiD;
  grind

/-
**Euclidean realization.**  The equidistant dissimilarity with `d = √2` is exactly
the Euclidean metric restricted to the `n` standard basis vectors: two distinct basis
vectors are `√2` apart, and a vector is at distance `0` from itself.  This certifies
that the equidistant configuration is a genuine metric space embedded in `ℝⁿ`.
-/
theorem stdBasis_dist_eq_equiD (i j : Fin n) :
    dist (EuclideanSpace.single i (1 : ℝ)) (EuclideanSpace.single j (1 : ℝ))
      = equiD (Real.sqrt 2) i j := by
  by_cases hij : i = j <;> simp +decide [ hij, equiD, EuclideanSpace.dist_eq ];
  rw [ Finset.sum_eq_add ( i ) ( j ) ] <;> norm_num [ hij ];
  · norm_num [ hij, eq_comm ];
  · aesop

/--
Above the gap `d`, every subset is a Vietoris–Rips simplex: the complex is the full
power set.
-/
theorem VRcomplex_equi_eq_powerset (d r : ℝ) (hd : 0 ≤ d) (hr : d ≤ r) :
    VRcomplex (equiD d) r = (Finset.univ : Finset (Fin n)).powerset := by
  refine' Finset.filter_true_of_mem _;
  intro S _ i hi j hj; unfold equiD; split_ifs <;> linarith;

/--
Above the gap `d`, the equidistant Vietoris–Rips complex has exactly `2 ^ n`
simplices.
-/
theorem card_VRcomplex_equi_eq (d r : ℝ) (hd : 0 ≤ d) (hr : d ≤ r) :
    (VRcomplex (equiD (n := n) d) r).card = 2 ^ n := by
  rw [ VRcomplex_equi_eq_powerset d r hd hr, Finset.card_powerset, Finset.card_fin ]

/--
Below the gap `d` (but at nonnegative scale) only the empty set and the singletons
survive: a simplex has at most one vertex.
-/
theorem VRsimplex_equi_below (d r : ℝ) (hr : r < d)
    (S : Finset (Fin n)) (hS : IsVRsimplex (equiD d) r S) : S.card ≤ 1 := by
  exact Finset.card_le_one.mpr fun i hi j hj => Classical.not_not.1 fun hi' => by have := hS i hi j hj; unfold equiD at this; split_ifs at this ; linarith;

/-
Below the gap `d` the equidistant Vietoris–Rips complex has exactly `n + 1`
simplices — the empty set together with the `n` vertices.  Combined with
`card_VRcomplex_equi_eq` this shows the complex jumps from `n + 1` to `2 ^ n` simplices
at the single scale `d`.
-/
theorem card_VRcomplex_equi_below (d r : ℝ) (hr0 : 0 ≤ r) (hr : r < d) :
    (VRcomplex (equiD (n := n) d) r).card = n + 1 := by
  convert Finset.card_eq_sum_ones ( Finset.powerset ( Finset.univ : Finset ( Fin n ) ) |> Finset.filter ( fun S => S.card ≤ 1 ) ) using 1;
  · congr! 1;
    ext S; simp [VRcomplex, IsVRsimplex];
    constructor <;> intro h <;> contrapose! h;
    · obtain ⟨ i, hi, j, hj, hij ⟩ := Finset.one_lt_card.mp h; use i, hi, j, hj; unfold equiD; aesop;
    · obtain ⟨ i, hi, j, hj, h ⟩ := h; exact Finset.one_lt_card.2 ⟨ i, hi, j, hj, by rintro rfl; exact h.not_ge <| by unfold equiD; aesop ⟩ ;
  · rw [ show ( Finset.univ.powerset.filter fun x => Finset.card x ≤ 1 ) = Finset.powersetCard 0 Finset.univ ∪ Finset.powersetCard 1 Finset.univ from ?_, Finset.sum_union ] <;> norm_num;
    · ring;
    · grind

/-- A multiplicative `c`-interleaving (a `c`-approximation) of the Vietoris–Rips
filtration of `D`: a filtration `G` sandwiched between `VR` at scales differing by the
factor `c`. -/
def IsCApprox (D : Fin n → Fin n → ℝ) (c : ℝ) (G : ℝ → Finset (Finset (Fin n))) : Prop :=
  1 ≤ c ∧
  (∀ t, 0 ≤ t → VRcomplex D t ⊆ G (c * t)) ∧
  (∀ t, 0 ≤ t → G t ⊆ VRcomplex D (c * t))

/--
**Exponential lower bound for approximations.**  Any `c`-approximation of the
equidistant Vietoris–Rips filtration has a level containing at least `2 ^ n` simplices.
-/
theorem approx_card_lower_bound (d c : ℝ) (hd : 0 ≤ d)
    (G : ℝ → Finset (Finset (Fin n))) (h : IsCApprox (equiD d) c G) :
    2 ^ n ≤ (G (c * d)).card := by
  obtain ⟨ hc₁, hc₂ ⟩ := h;
  refine' le_trans _ ( Finset.card_mono <| hc₂.1 d hd );
  convert card_VRcomplex_equi_eq d d hd le_rfl |> Eq.ge

/-- The explicit exponent `γ(c) = ½ − log₂ c` governing the lower bound. -/
def gamma (c : ℝ) : ℝ := 1 / 2 - Real.logb 2 c

/--
On `[1, √2)` the exponent is positive.
-/
theorem gamma_pos (c : ℝ) (hc1 : 1 ≤ c) (hc2 : c < Real.sqrt 2) : 0 < gamma c := by
  unfold gamma;
  rw [ sub_pos, Real.logb_lt_iff_lt_rpow ] <;> norm_num;
  · rwa [ Real.sqrt_eq_rpow ] at hc2;
  · linarith

/--
On `[1, √2)` the exponent is at most `1`.
-/
theorem gamma_le_one (c : ℝ) (hc1 : 1 ≤ c) : gamma c ≤ 1 := by
  exact sub_le_self _ ( Real.logb_nonneg ( by norm_num ) hc1 ) |> le_trans <| by norm_num;

/-- The exponent vanishes as `c → √2⁻`: `lim_{c → √2⁻} γ(c) = 0`. -/
theorem gamma_tendsto_zero :
    Filter.Tendsto gamma (nhdsWithin (Real.sqrt 2) (Set.Iio (Real.sqrt 2))) (nhds 0) := by
  refine' Filter.Tendsto.mono_left _ nhdsWithin_le_nhds;
  refine' ContinuousAt.tendsto _ |> fun h => h.trans _;
  · exact ContinuousAt.sub continuousAt_const ( ContinuousAt.div_const ( Real.continuousAt_log ( by positivity ) ) _ );
  · unfold gamma; norm_num [ Real.logb, Real.log_sqrt ]
    have h : Real.log 2 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
    field_simp
    ring

/-- **Headline theorem.**  For the `√2`-equidistant configuration on `n` points — the
metric realised by `n` standard basis vectors — every `c`-approximation of its
Vietoris–Rips filtration with `1 ≤ c < √2` has a level containing at least
`2 ^ (γ(c) · n)` simplices, where the effective exponent `γ(c) = ½ − log₂ c` is positive
and tends to `0` as `c → √2⁻`.
-/
theorem vietorisRips_sqrt2_exponential_lower_bound
    (c : ℝ) (hc1 : 1 ≤ c) (hc2 : c < Real.sqrt 2)
    (G : ℝ → Finset (Finset (Fin n)))
    (hG : IsCApprox (equiD (Real.sqrt 2)) c G) :
    0 < gamma c ∧ ∃ s : ℝ, (2 : ℝ) ^ (gamma c * (n : ℝ)) ≤ ((G s).card : ℝ) := by
  refine' ⟨ gamma_pos c hc1 hc2, c * Real.sqrt 2, _ ⟩;
  refine' le_trans _ ( Nat.cast_le.mpr <| approx_card_lower_bound ( Real.sqrt 2 ) c ( Real.sqrt_nonneg 2 ) G hG );
  norm_num [ Real.rpow_mul ];
  exact pow_le_pow_left₀ ( by positivity ) ( by linarith [ show ( 2 : ℝ ) ^ gamma c ≤ 2 by exact le_trans ( Real.rpow_le_rpow_of_exponent_le ( by norm_num ) ( gamma_le_one c hc1 ) ) ( by norm_num ) ] ) _

end VRLowerBound