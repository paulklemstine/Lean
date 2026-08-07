import Algebra.PGLQuotient.VertexVolumeGeneral
import Algebra.PGLQuotient.HeightZetaRankTwo
import Algebra.PGLQuotient.VertexVolumeRankThree

/-!
# Consistency of the general-rank vertex volume with the low-rank computations

`Algebra.PGLQuotient.VertexVolumeGeneral` proves the closed product form

`∑_λ 1/|Aut λ| = d / (P(d) · P(d-1))`,  `P(m) = ∏_{k=1}^m (q^k - 1)`

in arbitrary rank, by a cut-set recursion on a two-parameter twisted mass.  The ranks `d = 2`
and `d = 3` had previously been computed by completely different routes: rank two through the
explicit height zeta function (`heightZeta_rank_two`, a one-variable geometric series) and rank
three through a two-variable geometric summation (`vertexMass_rank_three`).

This file checks that the three computations agree, and pushes the general formula one rank
further than the ad hoc summations could reach (`vertexMass_rank_four`).
-/

namespace PGLQuotient

variable {q : ℝ}

/-- `P(1) = q - 1`. -/
lemma Pfac_one (q : ℝ) : Pfac q 1 = q - 1 := by
  unfold Pfac
  simp

/-- `P(2) = (q-1)(q^2-1)`. -/
lemma Pfac_two (q : ℝ) : Pfac q 2 = (q - 1) * (q ^ 2 - 1) := by
  unfold Pfac
  rw [Finset.prod_range_succ, Finset.prod_range_one]
  norm_num

/-- `P(3) = (q-1)(q^2-1)(q^3-1)`. -/
lemma Pfac_three (q : ℝ) : Pfac q 3 = (q - 1) * (q ^ 2 - 1) * (q ^ 3 - 1) := by
  unfold Pfac
  rw [Finset.prod_range_succ, Finset.prod_range_succ, Finset.prod_range_one]
  norm_num

/-- `P(4) = (q-1)(q^2-1)(q^3-1)(q^4-1)`. -/
lemma Pfac_four (q : ℝ) : Pfac q 4 = (q - 1) * (q ^ 2 - 1) * (q ^ 3 - 1) * (q ^ 4 - 1) := by
  unfold Pfac
  rw [Finset.prod_range_succ, Finset.prod_range_succ, Finset.prod_range_succ,
    Finset.prod_range_one]
  norm_num

/-- The general-rank formula, specialised to `d = 2`, reproduces the rank-two vertex mass
`2/((q-1)^2 (q^2-1))`. -/
theorem vertexMass_rank_two_of_general (hq : 1 < q) :
    ∑' g : Vertex 2, vertexWeight q g = 2 / ((q - 1) ^ 2 * (q ^ 2 - 1)) := by
  have h : ∑' g : Vertex 2, vertexWeight q g = ((1 : ℕ) + 1) / (Pfac q 2 * Pfac q 1) :=
    vertexVolume_general (q := q) hq 1
  rw [h, Pfac_two, Pfac_one]
  norm_num
  ring_nf

/-- The general-rank formula, specialised to `d = 3`, reproduces the rank-three vertex mass
`3/((q-1)^2 (q^2-1)^2 (q^3-1))`. -/
theorem vertexMass_rank_three_of_general (hq : 1 < q) :
    ∑' g : Vertex 3, vertexWeight q g
      = 3 / ((q - 1) ^ 2 * (q ^ 2 - 1) ^ 2 * (q ^ 3 - 1)) := by
  have h : ∑' g : Vertex 3, vertexWeight q g = ((2 : ℕ) + 1) / (Pfac q 3 * Pfac q 2) :=
    vertexVolume_general (q := q) hq 2
  rw [h, Pfac_three, Pfac_two]
  norm_num
  ring_nf

/-- **Cross-validation in rank two.**  The cut-set recursion and the explicit rank-two height
zeta function, two entirely independent computations, give the same vertex mass. -/
theorem vertexVolume_general_agrees_rank_two (hq : 1 < q) :
    ((1 : ℕ) + 1 : ℝ) / (Pfac q 2 * Pfac q 1) = 2 / ((q - 1) ^ 2 * (q ^ 2 - 1)) :=
  (vertexVolume_general (q := q) hq 1).symm.trans (vertexMass_rank_two hq)

/-- **Cross-validation in rank three.**  The cut-set recursion and the two-variable geometric
summation of `vertexMass_rank_three` give the same vertex mass. -/
theorem vertexVolume_general_agrees_rank_three (hq : 1 < q) :
    ((2 : ℕ) + 1 : ℝ) / (Pfac q 3 * Pfac q 2)
      = 3 / ((q - 1) ^ 2 * (q ^ 2 - 1) ^ 2 * (q ^ 3 - 1)) :=
  (vertexVolume_general (q := q) hq 2).symm.trans (vertexMass_rank_three hq)

/-- **A new closed form: the rank-four vertex mass.**  This value is out of reach of the
rank-by-rank geometric summations; it is the first genuinely new instance produced by the
general cut-set recursion. -/
theorem vertexMass_rank_four (hq : 1 < q) :
    ∑' g : Vertex 4, vertexWeight q g
      = 4 / ((q - 1) ^ 2 * (q ^ 2 - 1) ^ 2 * (q ^ 3 - 1) ^ 2 * (q ^ 4 - 1)) := by
  have h : ∑' g : Vertex 4, vertexWeight q g = ((3 : ℕ) + 1) / (Pfac q 4 * Pfac q 3) :=
    vertexVolume_general (q := q) hq 3
  rw [h, Pfac_four, Pfac_three]
  norm_num
  ring_nf

/-- The `PGL`-normalised rank-four vertex volume. -/
theorem vertexVolume_rank_four (hq : 1 < q) :
    (q - 1) * ∑' g : Vertex 4, vertexWeight q g
      = 4 / ((q - 1) * (q ^ 2 - 1) ^ 2 * (q ^ 3 - 1) ^ 2 * (q ^ 4 - 1)) := by
  have hq1 : (0:ℝ) < q - 1 := by linarith
  have hq2 : (1:ℝ) < q ^ 2 := by nlinarith
  have hq3 : (1:ℝ) < q ^ 3 := by nlinarith
  have hq4 : (1:ℝ) < q ^ 4 := by nlinarith
  rw [vertexMass_rank_four hq]
  have h1 : q - 1 ≠ 0 := ne_of_gt hq1
  have h2 : q ^ 2 - 1 ≠ 0 := by linarith
  have h3 : q ^ 3 - 1 ≠ 0 := by linarith
  have h4 : q ^ 4 - 1 ≠ 0 := by linarith
  field_simp

end PGLQuotient