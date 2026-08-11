/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Novelty.SupersingularLambdaMu

/-!
# The spine of the supersingular `2`-isogeny graph: metric structure of its path components

The **spine** of a supersingular `ℓ`-isogeny graph is the subgraph carried by the
`𝔽_p`-rational supersingular `j`-invariants.  For `ℓ = 2` and `p ≡ 71, 119 (mod 120)` the
connected components of the spine, once the single non-trivial edge that is not defined
over `𝔽_p` is removed, are **finite paths**.  The three functions that organise the
arithmetic of such a component — its *distance*, *eccentricity* and *diameter* — are
therefore governed entirely by the combinatorial geometry of the path graph `P_m`, and the
*mean diameter* of the whole spine, the invariant used to distinguish the possible
structures as `p` varies, is an average of these path diameters.

This file isolates and proves that combinatorial geometry from first principles.

## Main results

* `pathGraph_dist` : the graph distance in `P_n` between the vertices labelled `i` and `j`
  is the absolute difference `|i − j|`.  This is the *distance function* of a spine
  component.
* `pathGraph_eccent` : the eccentricity of the vertex `i` of `P_{n+1}` is
  `max i (n − i)`, its larger distance to the two endpoints.  This is the *eccentricity
  function*.
* `pathGraph_diam` : the diameter of `P_{n+1}` is `n`.  This is the *diameter function*.
* `pathGraph_wiener` : the total of all pairwise distances (the *Wiener index*) of
  `P_{n+1}` satisfies `3 · W + (n+1) = (n+1)³`, i.e. `W = ((n+1)³ − (n+1))/3`.  Dividing by
  the number of ordered pairs gives the **mean distance** inside a single component.
* `meanDiameter_eq` : for a spine modelled by the multiset of its component sizes, the mean
  diameter is exactly `(total vertex count) / (number of components) − 1`; hence, for a
  fixed supersingular vertex count, the mean diameter is a strictly decreasing function of
  the number of components, which is precisely why it distinguishes the different spine
  structures.
* `spine_component_diam_of_muWeight` : a bridge to the companion supersingular development
  `SupersingularLambdaMu` — a model component whose vertex count is the local `2`-adic
  weight `muWeight ℓ = 2^{n_ℓ}` has diameter `muWeight ℓ − 1`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): after deleting the one non-`𝔽_p` edge, a spine component of the
`2`-isogeny graph is a path, so its distance/eccentricity/diameter functions must coincide
with those of the abstract path graph `P_m`, and the spine's mean diameter must be an
average of the numbers `m − 1`.  Bold sub-claim: the mean diameter depends on the component
sizes only through the total vertex count and the number of components.

Experiment (Experimenter): we proved the distance function `dist i j = |i − j|` by a
two-sided argument — each isogeny step changes the label by exactly one (lower bound, by
induction on walks) and an explicit monotone walk realises the difference (upper bound, by
induction on `|i − j|` using the triangle inequality).  Eccentricity and diameter follow by
optimising `|i − j|` over the endpoints.  The Wiener index `3W + m = m³` was proved by
induction, the inductive step reducing to a Gauss sum `2·Σ(m−j) = m(m+1)`.  The
mean-diameter identity followed from `Σ(mᵢ − 1) = (Σ mᵢ) − k`.

Analysis (Analyst): the entire metric theory of a spine component is a consequence of a
single fact — adjacency changes the label by one — so the path is "isometrically linear".
The mean-diameter identity `mean = total/k − 1` is the structural punchline: two spines with
the same number of supersingular vertices are told apart by their mean diameter exactly when
they have a different number of components, matching the paper's use of the mean diameter as
a discriminator of spine structure as `p` varies.

Critique (Critic): none of the theorems is vacuous — the diameter formula needs `n+1 ≥ 1`
vertices (handled by working with `P_{n+1}`), the mean-diameter identity needs a non-empty
spine (`card ≠ 0`, a genuine hypothesis), and the Wiener identity is stated in the
subtraction-free form `3W + m = m³` so it is an honest `ℕ` equality.  The bridge lemma uses
the positivity `muWeight_pos` of the companion file, so it is a real cross-thread
dependency, not a restatement.

Synthesis (PI): the spine's distance, eccentricity, diameter and mean-diameter functions
are completely determined by path combinatorics; the mean diameter is `total/k − 1`, a clean
invariant whose variation with the number of components explains its power to distinguish
spine structures.
-/

open SimpleGraph Finset

namespace SupersingularSpinePath

/-! ### The distance function of a spine component -/

/-- Along any walk in the path graph, the label can move by at most one per step, so the
label difference of the endpoints is a lower bound for the walk length. -/
theorem walk_length_ge {n : ℕ} (i j : Fin n) (w : (pathGraph n).Walk i j) :
    Int.natAbs ((i.val : ℤ) - j.val) ≤ w.length := by
  induction w with
  | nil => simp
  | cons h p ih =>
      rw [pathGraph_adj] at h
      simp only [SimpleGraph.Walk.length_cons]; omega

/-- The distance between labels at difference `d` is at most `d`: a monotone walk realises
it. -/
theorem dist_le_labelDiff {n : ℕ} : ∀ (d : ℕ) (i j : Fin n),
    Int.natAbs ((i.val : ℤ) - j.val) = d → (pathGraph n).dist i j ≤ d := by
  intro d
  induction d with
  | zero =>
      intro i j h
      have : i = j := by apply Fin.ext; omega
      subst this; simp
  | succ d ih =>
      intro i j h
      have hconn : (pathGraph n).Connected := by
        cases n with
        | zero => exact absurd i.2 (by omega)
        | succ m => exact pathGraph_connected m
      rcases lt_or_gt_of_ne (a := i.val) (b := j.val) (by omega) with hlt | hgt
      · have hk : i.val + 1 < n := by omega
        set k : Fin n := ⟨i.val + 1, hk⟩ with hkdef
        have hadj : (pathGraph n).Adj i k := by rw [pathGraph_adj]; left; simp [hkdef]
        have h1 : (pathGraph n).dist i k = 1 := (dist_eq_one_iff_adj).2 hadj
        have h2 : (pathGraph n).dist k j ≤ d := ih k j (by simp [hkdef]; omega)
        calc (pathGraph n).dist i j
              ≤ (pathGraph n).dist i k + (pathGraph n).dist k j := hconn.dist_triangle
          _ ≤ d + 1 := by omega
      · have hk : i.val - 1 < n := by omega
        set k : Fin n := ⟨i.val - 1, hk⟩ with hkdef
        have hadj : (pathGraph n).Adj i k := by rw [pathGraph_adj]; right; simp [hkdef]; omega
        have h1 : (pathGraph n).dist i k = 1 := (dist_eq_one_iff_adj).2 hadj
        have h2 : (pathGraph n).dist k j ≤ d := ih k j (by simp [hkdef]; omega)
        calc (pathGraph n).dist i j
              ≤ (pathGraph n).dist i k + (pathGraph n).dist k j := hconn.dist_triangle
          _ ≤ d + 1 := by omega

/-- **The distance function of a spine component.**  In the path `P_n` the graph distance
between the vertices labelled `i` and `j` is the absolute difference `|i − j|`. -/
theorem pathGraph_dist {n : ℕ} (i j : Fin n) :
    (pathGraph n).dist i j = Int.natAbs ((i.val : ℤ) - j.val) := by
  refine le_antisymm (dist_le_labelDiff _ i j rfl) ?_
  have hconn : (pathGraph n).Connected := by
    cases n with
    | zero => exact absurd i.2 (by omega)
    | succ m => exact pathGraph_connected m
  obtain ⟨w, hw⟩ := (hconn i j).exists_walk_length_eq_dist
  rw [← hw]; exact walk_length_ge i j w

/-- The extended distance agrees with the natural-number distance in a spine component. -/
theorem pathGraph_edist {n : ℕ} (i j : Fin n) :
    (pathGraph n).edist i j = (Int.natAbs ((i.val : ℤ) - j.val) : ℕ) := by
  have hconn : (pathGraph n).Connected := by
    cases n with
    | zero => exact absurd i.2 (by omega)
    | succ m => exact pathGraph_connected m
  rw [← (hconn i j).coe_dist_eq_edist, pathGraph_dist]

/-! ### The eccentricity and diameter functions -/

/-- **The eccentricity function of a spine component.**  The eccentricity of the vertex `i`
of `P_{n+1}` is the larger of its two distances to the endpoints, `max i (n − i)`. -/
theorem pathGraph_eccent {n : ℕ} (i : Fin (n + 1)) :
    (pathGraph (n + 1)).eccent i = (max i.val (n - i.val) : ℕ) := by
  apply le_antisymm
  · rw [eccent_le_iff]
    intro v
    rw [pathGraph_edist]
    have hv := v.2; have hi := i.2
    have : Int.natAbs ((i.val : ℤ) - v.val) ≤ max i.val (n - i.val) := by omega
    exact_mod_cast this
  · by_cases h : n - i.val ≤ i.val
    · have hle : (max i.val (n - i.val) : ℕ) = i.val := by omega
      rw [hle]
      have hkey := @edist_le_eccent _ (pathGraph (n + 1)) i (0 : Fin (n + 1))
      rw [pathGraph_edist] at hkey
      have heq : (Int.natAbs ((i.val : ℤ) - (0 : Fin (n + 1)).val) : ℕ) = i.val := by simp
      rw [heq] at hkey; exact_mod_cast hkey
    · have hle : (max i.val (n - i.val) : ℕ) = n - i.val := by omega
      rw [hle]
      have hkey := @edist_le_eccent _ (pathGraph (n + 1)) i (Fin.last n)
      rw [pathGraph_edist] at hkey
      have heq : (Int.natAbs ((i.val : ℤ) - (Fin.last n).val) : ℕ) = n - i.val := by
        simp only [Fin.val_last]; have := i.2; omega
      rw [heq] at hkey; exact_mod_cast hkey

/-- The extended diameter of a spine component `P_{n+1}` is `n`. -/
theorem pathGraph_ediam {n : ℕ} : (pathGraph (n + 1)).ediam = (n : ℕ∞) := by
  apply le_antisymm
  · rw [ediam_le_iff]
    intro u v
    rw [pathGraph_edist]
    have : Int.natAbs ((u.val : ℤ) - v.val) ≤ n := by
      have := u.2; have := v.2; omega
    exact_mod_cast this
  · have h := @edist_le_ediam _ (pathGraph (n + 1)) (0 : Fin (n + 1)) (Fin.last n)
    rw [pathGraph_edist] at h
    simpa using h

/-- **The diameter function of a spine component.**  The diameter of the path `P_{n+1}` is
`n`, attained between its two endpoints. -/
theorem pathGraph_diam {n : ℕ} : (pathGraph (n + 1)).diam = n := by
  rw [diam, pathGraph_ediam]; simp

/-! ### The Wiener index (total pairwise distance) of a spine component -/

/-- The triangular Gauss sum: `2·Σ_{j<m}(j+1) = m(m+1)`. -/
theorem tri_sum (m : ℕ) : 2 * ∑ j ∈ range m, (j + 1) = m * (m + 1) := by
  induction m with
  | zero => simp
  | succ m ih => rw [Finset.sum_range_succ, Nat.mul_add, ih]; ring

/-- A descending Gauss sum: `2·Σ_{j<m}(m − j) = m(m+1)`. -/
theorem gauss_descending (m : ℕ) : 2 * ∑ j ∈ range m, (m - j) = m * (m + 1) := by
  have h1 : ∑ j ∈ range m, (m - j) = ∑ j ∈ range m, (j + 1) := by
    rw [← Finset.sum_range_reflect]
    exact Finset.sum_congr rfl (fun x hx => by simp only [mem_range] at hx; omega)
  rw [h1]; exact tri_sum m

/-- The Wiener index of the interval `{0, …, m−1}` under the absolute-difference metric,
in subtraction-free form: `3·W + m = m³`. -/
theorem wiener_interval (m : ℕ) :
    3 * (∑ i ∈ range m, ∑ j ∈ range m, (max i j - min i j)) + m = m ^ 3 := by
  induction m with
  | zero => simp
  | succ m ih =>
      have inner : ∀ i, ∑ j ∈ range (m + 1), (max i j - min i j)
          = (∑ j ∈ range m, (max i j - min i j)) + (max i m - min i m) := by
        intro i; rw [Finset.sum_range_succ]
      rw [Finset.sum_congr rfl (fun i _ => inner i)]
      rw [Finset.sum_add_distrib, Finset.sum_range_succ
          (f := fun i => ∑ j ∈ range m, (max i j - min i j))]
      have hcol : ∑ i ∈ range (m + 1), (max i m - min i m) = ∑ i ∈ range m, (m - i) := by
        rw [Finset.sum_range_succ]
        simp only [max_self, min_self, Nat.sub_self, add_zero]
        exact Finset.sum_congr rfl (fun i hi => by
          simp only [mem_range] at hi; rw [max_eq_right (by omega), min_eq_left (by omega)])
      have hrow : ∑ j ∈ range m, (max m j - min m j) = ∑ j ∈ range m, (m - j) := by
        exact Finset.sum_congr rfl (fun j hj => by
          simp only [mem_range] at hj; rw [max_eq_left (by omega), min_eq_right (by omega)])
      rw [hrow, hcol]
      have hg := gauss_descending m
      nlinarith [ih, hg]

/-- The label difference equals `max − min` of the two labels. -/
theorem labelDiff_eq {a b : ℕ} : Int.natAbs ((a : ℤ) - b) = max a b - min a b := by omega

/-- **The Wiener index of a spine component.**  The total of all ordered pairwise distances
of `P_{n+1}` satisfies `3·W + (n+1) = (n+1)³`; equivalently `W = ((n+1)³ − (n+1))/3`.  The
mean distance inside the component is this total divided by `(n+1)²`. -/
theorem pathGraph_wiener (n : ℕ) :
    3 * (∑ i : Fin (n + 1), ∑ j : Fin (n + 1), (pathGraph (n + 1)).dist i j) + (n + 1)
      = (n + 1) ^ 3 := by
  have hstep : (∑ i : Fin (n + 1), ∑ j : Fin (n + 1), (pathGraph (n + 1)).dist i j)
      = ∑ i ∈ range (n + 1), ∑ j ∈ range (n + 1), (max i j - min i j) := by
    rw [← Fin.sum_univ_eq_sum_range (fun i => ∑ j ∈ range (n + 1), (max i j - min i j))]
    apply Finset.sum_congr rfl
    intro i _
    rw [← Fin.sum_univ_eq_sum_range (fun j => (max i.val j - min i.val j))]
    apply Finset.sum_congr rfl
    intro j _
    rw [pathGraph_dist, labelDiff_eq]
  rw [hstep]; exact wiener_interval (n + 1)

/-! ### The mean diameter of the spine -/

/-- A spine is modelled by the multiset of the vertex counts of its path components.  The
mean diameter is the average of the component diameters `mᵢ − 1`. -/
noncomputable def meanDiameter (sizes : Multiset ℕ) : ℚ :=
  (sizes.map (fun m : ℕ => (m : ℚ) - 1)).sum / sizes.card

/-- The sum of the component diameters `mᵢ − 1` equals the total size minus the count. -/
theorem sum_map_sub_one (sizes : Multiset ℕ) :
    (sizes.map (fun m : ℕ => (m : ℚ) - 1)).sum = (sizes.sum : ℚ) - sizes.card := by
  induction sizes using Multiset.induction with
  | empty => simp
  | cons a s ih =>
      simp only [Multiset.map_cons, Multiset.sum_cons, Multiset.card_cons, ih]
      push_cast; ring

/-- **The mean diameter identity.**  For a non-empty spine, the mean diameter is exactly the
mean component size minus one, `total / (number of components) − 1`.  In particular it
depends on the component sizes only through the total vertex count and the number of
components: for a fixed supersingular vertex count it is a strictly decreasing function of
the number of components, which is why it discriminates between spine structures. -/
theorem meanDiameter_eq (sizes : Multiset ℕ) (h : sizes.card ≠ 0) :
    meanDiameter sizes = (sizes.sum : ℚ) / sizes.card - 1 := by
  unfold meanDiameter
  rw [sum_map_sub_one]
  have hc : (sizes.card : ℚ) ≠ 0 := by exact_mod_cast h
  field_simp

/-- A uniform spine of `k` path components each on `m` vertices has mean diameter `m − 1`. -/
theorem meanDiameter_replicate (k m : ℕ) (hk : k ≠ 0) :
    meanDiameter (Multiset.replicate k m) = (m : ℚ) - 1 := by
  rw [meanDiameter_eq _ (by simpa using hk)]
  rw [Multiset.sum_replicate, Multiset.card_replicate, smul_eq_mul]
  have hc : (k : ℚ) ≠ 0 := by exact_mod_cast hk
  push_cast; field_simp

/-! ### Bridge to the companion supersingular development -/

open SupersingularLambdaMu in
/-- **Bridge to `SupersingularLambdaMu`.**  A model spine component whose vertex count is the
local `2`-adic weight `muWeight ℓ = 2^{n_ℓ}` of the companion development has diameter
`muWeight ℓ − 1`.  This ties the metric geometry of the spine to the local weights that
control the supersingular `λ`-difference. -/
theorem spine_component_diam_of_muWeight (ℓ : ℕ) :
    (pathGraph (muWeight ℓ)).diam = muWeight ℓ - 1 := by
  have hk : 0 < muWeight ℓ := muWeight_pos ℓ
  obtain ⟨m, hm⟩ : ∃ m, muWeight ℓ = m + 1 := ⟨muWeight ℓ - 1, by omega⟩
  rw [hm, pathGraph_diam, Nat.add_sub_cancel]

end SupersingularSpinePath