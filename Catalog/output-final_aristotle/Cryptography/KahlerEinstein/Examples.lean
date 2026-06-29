import Cryptography.KahlerEinstein.Core

/-!
# Kähler–Einstein Examples: ℙⁿ is K-stable, the one-point blow-up of ℙ² is not

Using the toric Futaki / barycenter core, we verify the criterion on concrete Fano
varieties:

* `projectiveSpaceDatum n` — the moment-polytope datum of complex projective space
  `ℙⁿ` (the reflexive simplex with vertices `e₁,…,eₙ, -(e₁+⋯+eₙ)`).  Its moment vector
  vanishes, so `ℙⁿ` admits a Kähler–Einstein metric (the Fubini–Study metric) and is
  K-polystable.

* `projTwo_admitsKE_via_symmetry` — a second, conceptual proof for `ℙ²`: the order-3
  linear symmetry cyclically permuting the three vertices has no nonzero fixed vector,
  so the Matsushima-type theorem forces the moment vector to vanish.

* `hirzebruchF1Datum` — the Fano polygon of the Hirzebruch surface `F₁` (the blow-up of
  `ℙ²` at one point), with ray generators `(1,0), (0,1), (-1,1), (0,-1)`.  Its moment
  vector is `(0,1) ≠ 0`, so `F₁` is **not** K-polystable and admits **no** Kähler–Einstein
  metric — the classical Futaki / Matsushima obstruction.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): The barycenter criterion should certify the textbook
dichotomy: ℙⁿ (and symmetric toric Fanos) admit KE, while the one-point blow-up of ℙ²
does not.

Experiment (Stage 2): Encode both polytopes over ℚ and compute the moment vector.  For
ℙⁿ the sum telescopes to 0 for every coordinate; for F₁ the four ray generators sum to
(0,1).

Analysis (Stage 3): The vanishing for ℙⁿ is *forced* — the cyclic symmetry argument
recovers it with no coordinate computation, isolating the structural reason (a rotation
with no real fixed direction).  The F₁ obstruction is genuinely a single nonzero
coordinate, matching the rank-one Futaki character of that surface.

Critique (Stage 4): The F₁ non-existence statements are stated as negations
(`¬ AdmitsKE`, `¬ KPolystable`) proved from a concrete nonzero coordinate, so they are
not vacuous.  The two ℙ² proofs are logically independent (computation vs. symmetry).

Synthesis (Stage 5): These examples instantiate the general toric YTD bridge from
`Core.lean` on the smallest interesting Fano varieties.
-/

open scoped BigOperators

namespace KahlerEinstein

/-! ## Complex projective space `ℙⁿ` -/

/-- The moment-polytope datum of `ℙⁿ`: the reflexive simplex with vertices
`e₁, …, eₙ` and `-(e₁ + ⋯ + eₙ)`, all with weight `1`. -/
def projectiveSpaceDatum (n : ℕ) : ToricFanoDatum n (n + 1) where
  pt i := fun j => if (i : ℕ) = (j : ℕ) then 1 else (if (i : ℕ) < n then 0 else -1)
  wt _ := 1

/-
The total weight of the `ℙⁿ` datum is `n + 1`.
-/
theorem projectiveSpaceDatum_totalWeight (n : ℕ) :
    (projectiveSpaceDatum n).totalWeight = (n + 1 : ℚ) := by
  unfold ToricFanoDatum.totalWeight;
  unfold projectiveSpaceDatum; norm_num;

/-
The moment vector of `ℙⁿ` vanishes: the symmetric simplex is balanced.
-/
theorem projectiveSpaceDatum_weightedSum (n : ℕ) :
    (projectiveSpaceDatum n).weightedSum = 0 := by
  unfold projectiveSpaceDatum ToricFanoDatum.weightedSum;
  simp +decide [ Fin.sum_univ_castSucc ];
  ext j; simp +decide [ Finset.sum_apply, Fin.val_inj ] ;
  rw [ if_neg ( by linarith [ Fin.is_lt j ] ) ] ; ring

/-
`ℙⁿ` is toric K-polystable.
-/
theorem projectiveSpaceDatum_kPolystable (n : ℕ) :
    (projectiveSpaceDatum n).KPolystable := by
  convert ToricFanoDatum.kpolystable_iff_weightedSum_zero _ |>.2 ( projectiveSpaceDatum_weightedSum n ) using 1

/-
`ℙⁿ` admits a Kähler–Einstein metric (the Fubini–Study metric).
-/
theorem projectiveSpaceDatum_admitsKE (n : ℕ) :
    (projectiveSpaceDatum n).AdmitsKE := by
  grind +suggestions

/-! ## A symmetry proof for `ℙ²` -/

/-- The order-3 linear symmetry of `ℙ²` that cyclically permutes the three vertices
`e₁ ↦ e₂ ↦ -(e₁+e₂) ↦ e₁`, given by the matrix `[[0,-1],[1,-1]]`. -/
def projTwoRot : (Fin 2 → ℚ) →ₗ[ℚ] (Fin 2 → ℚ) :=
  Matrix.mulVecLin !![(0 : ℚ), -1; 1, -1]

/-- The cyclic reindexing `0 ↦ 1 ↦ 2 ↦ 0` of the three vertices of `ℙ²`. -/
def projTwoCycle : Fin 3 ≃ Fin 3 := finRotate 3

/-
The rotation has no nonzero fixed vector.
-/
theorem projTwoRot_no_fixed (x : Fin 2 → ℚ) (hx : projTwoRot x = x) : x = 0 := by
  ext i; fin_cases i <;> have := congr_fun hx 0 <;> have := congr_fun hx 1 <;> simp_all +decide [projTwoRot] ;
  · linarith!;
  · linarith!

/-
**Symmetry proof that `ℙ²` admits a Kähler–Einstein metric.**  The order-3
rotation cyclically permutes the vertices and has no nonzero fixed vector, so the
Matsushima-type theorem forces the moment vector — hence the Futaki obstruction — to
vanish.
-/
theorem projTwo_admitsKE_via_symmetry :
    (projectiveSpaceDatum 2).weightedSum = 0 := by
  refine ToricFanoDatum.weightedSum_zero_of_no_fixed_vector
    (projectiveSpaceDatum 2) projTwoRot projTwoCycle (fun i => rfl) ?_ projTwoRot_no_fixed
  intro i
  fin_cases i <;>
    · funext k
      fin_cases k <;>
        simp [projTwoRot, projTwoCycle, projectiveSpaceDatum,
          Matrix.mulVec, dotProduct, Fin.sum_univ_two, finRotate_succ_apply]

/-! ## The Hirzebruch surface `F₁` (one-point blow-up of `ℙ²`) -/

/-- The Fano-polygon datum of the Hirzebruch surface `F₁`, with primitive ray
generators `(1,0), (0,1), (-1,1), (0,-1)`, all with weight `1`. -/
def hirzebruchF1Datum : ToricFanoDatum 2 4 where
  pt := ![![1, 0], ![0, 1], ![-1, 1], ![0, -1]]
  wt _ := 1

/-
The moment vector of `F₁` is `(0, 1)`, which is nonzero.
-/
theorem hirzebruchF1Datum_weightedSum :
    hirzebruchF1Datum.weightedSum = ![0, 1] := by
  funext j
  rw [ToricFanoDatum.weightedSum_apply]
  fin_cases j <;>
    simp [hirzebruchF1Datum, Fin.sum_univ_four]

/-
`F₁` is **not** toric K-polystable: it has a nonzero Futaki invariant.
-/
theorem hirzebruchF1Datum_not_kPolystable :
    ¬ hirzebruchF1Datum.KPolystable := by
  rw [ToricFanoDatum.kpolystable_iff_weightedSum_zero, hirzebruchF1Datum_weightedSum]
  intro h
  have h1 := congrFun h 1
  norm_num at h1

/-
`F₁` admits **no** Kähler–Einstein metric — the Futaki / Matsushima obstruction.
-/
theorem hirzebruchF1Datum_not_admitsKE :
    ¬ hirzebruchF1Datum.AdmitsKE := by
  have htw : hirzebruchF1Datum.totalWeight ≠ 0 := by
    simp [ToricFanoDatum.totalWeight, hirzebruchF1Datum]
  rw [ToricFanoDatum.AdmitsKE,
    ToricFanoDatum.barycenter_zero_iff_weightedSum_zero _ htw, hirzebruchF1Datum_weightedSum]
  intro h
  have h1 := congrFun h 1
  norm_num at h1

end KahlerEinstein