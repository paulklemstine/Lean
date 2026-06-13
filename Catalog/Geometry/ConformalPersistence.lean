import Mathlib

/-! # CatalogBuild.Geometry.ConformalPersistence

## Inverse Stereographic Persistence — Conformal Isometry on Sⁿ

This file develops the rigorous geometric backbone of *stereographic persistence*:
the claim that persistent homology of a point cloud on the sphere `Sⁿ`, computed with
the (chordal/geodesic) sphere metric, agrees with persistent homology of the inverse
stereographic image in `ℝⁿ` computed with a **conformally weighted** Euclidean distance.

We generalize the catalog's `S¹`-only results
(`Geometry.StereographicSheaf.stereoProj_on_circle`,
`Geometry.InverseStereoResearch.inv_stereo_on_circle`) to arbitrary dimension `n`, and we
connect them to the persistence framework of `Geometry.PrimewisePersistence` by proving that
inverse stereographic projection is an **exact isometry**
`(ℝⁿ, d_w) ≃ (Sⁿ ⊂ ℝⁿ⁺¹, chordal)`.  Because Vietoris–Rips / Čech filtrations depend only on
the pairwise distance matrix, an isometry forces *identical* persistence diagrams — turning the
"equal up to conformal factor" conjecture into an exact equality.

The conformal weight is encoded in the exact identity (Theorem `stereo_conformal_identity`):
  `‖φ(x) - φ(y)‖² · (1+‖x‖²)(1+‖y‖²) = 4 ‖x - y‖²`,
i.e. the chordal distance on the sphere equals `d_w(x,y) = 2‖x-y‖ / √((1+‖x‖²)(1+‖y‖²))`.

-- !-- Lab Notebook -- !--
Hypothesis: Inverse stereographic projection is not merely conformal "up to a factor" but is an
  *exact isometry* from ℝⁿ with a closed-form weighted distance to Sⁿ with the chordal metric;
  hence spherical persistence diagrams equal weighted-Euclidean persistence diagrams exactly.
Result: Proved (1) φ(x) ∈ Sⁿ for all n; (2) the exact conformal identity
  ‖φx-φy‖²(1+‖x‖²)(1+‖y‖²) = 4‖x-y‖²; (3) chordal = weighted distance; (4) Vietoris–Rips edge
  sets (hence the whole filtration / distance matrix) coincide; (5) the spherical *geodesic*
  metric is a strictly monotone reparametrization of the chordal metric, so persistence is
  preserved for the geodesic metric too.
Insight: The single algebraic identity `sum_affine_sq` (expanding ∑(a xᵢ + b yᵢ)²) reduces the
  whole conformal computation to scalar algebra in X=‖x‖², Y=‖y‖², P=⟨x,y⟩. The "conformal factor"
  is exactly the product of the two stereographic denominators (1+X)(1+Y).
Failure analysis: A naive attempt to phrase everything over `EuclideanSpace ℝ (Fin n)` drowns in
  coercions; working with bare `Fin n → ℝ` and an explicit `nsq`/`ip` keeps `ring`/`field_simp`
  effective. Stating the identity for the *squared* distances (avoiding √) is what makes it a pure
  `ring` fact; the √ form is then a one-line corollary.
-- !-- Lab Notebook -- !--
-/

noncomputable section

namespace ConformalPersistence

open Finset

variable {n : ℕ}

/-- Squared Euclidean norm of a vector in `ℝⁿ`. -/
def nsq (x : Fin n → ℝ) : ℝ := ∑ i, (x i) ^ 2

/-- Euclidean inner product on `ℝⁿ`. -/
def ip (x y : Fin n → ℝ) : ℝ := ∑ i, x i * y i

/-- Squared Euclidean distance on `ℝⁿ`. -/
def euclDist2 (x y : Fin n → ℝ) : ℝ := ∑ i, (x i - y i) ^ 2

/-
!-- comment -- !--
The master algebraic identity: expand a squared affine combination ∑(a xᵢ + b yᵢ)²
into norms and inner product. Everything downstream is a corollary of this `ring` fact.
!-- comment -- !--
-/
lemma sum_affine_sq (a b : ℝ) (x y : Fin n → ℝ) :
    (∑ i, (a * x i + b * y i) ^ 2) = a ^ 2 * nsq x + 2 * a * b * ip x y + b ^ 2 * nsq y := by
  unfold nsq ip; rw [ Finset.mul_sum ] ; rw [ Finset.mul_sum ] ; rw [ Finset.mul_sum ] ; rw [ ← Finset.sum_add_distrib ] ; rw [ ← Finset.sum_add_distrib ] ; congr ; ext ; ring;

lemma nsq_nonneg (x : Fin n → ℝ) : 0 ≤ nsq x := by
  exact Finset.sum_nonneg fun _ _ => sq_nonneg _

lemma denom_pos (x : Fin n → ℝ) : 0 < 1 + nsq x := by
  exact add_pos_of_pos_of_nonneg zero_lt_one ( nsq_nonneg x )

/-
`euclDist2` in terms of norms and inner product.
-/
lemma euclDist2_eq (x y : Fin n → ℝ) : euclDist2 x y = nsq x - 2 * ip x y + nsq y := by
  unfold euclDist2 nsq ip;
  simp +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, mul_assoc ]

/-- **Inverse stereographic projection** `φ : ℝⁿ → Sⁿ ⊂ ℝⁿ × ℝ`.
The image is encoded as a pair (the first `n` coordinates, the height coordinate). -/
def invStereoN (x : Fin n → ℝ) : (Fin n → ℝ) × ℝ :=
  (fun i => 2 * x i / (1 + nsq x), (nsq x - 1) / (1 + nsq x))

/-- Squared norm of a point of `ℝⁿ × ℝ ≅ ℝⁿ⁺¹`. -/
def sphereNsq (p : (Fin n → ℝ) × ℝ) : ℝ := nsq p.1 + p.2 ^ 2

/-- Squared Euclidean (chordal) distance in the ambient `ℝⁿ⁺¹`. -/
def sphereDist2 (p q : (Fin n → ℝ) × ℝ) : ℝ := euclDist2 p.1 q.1 + (p.2 - q.2) ^ 2

/-
!-- comment -- !--
Theorem 1 (generalizes catalog `inv_stereo_on_circle`/`stereoProj_on_circle` from S¹ to Sⁿ):
the inverse stereographic image lands on the unit sphere, in every dimension.
!-- comment -- !--

**Theorem 1.** Inverse stereographic projection lands on the unit sphere `Sⁿ`.
-/
theorem invStereoN_on_sphere (x : Fin n → ℝ) : sphereNsq (invStereoN x) = 1 := by
  unfold sphereNsq invStereoN nsq;
  field_simp;
  norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_div ];
  rw [ mul_div_cancel₀ ] <;> nlinarith [ show 0 ≤ ∑ i, x i ^ 2 from Finset.sum_nonneg fun _ _ => sq_nonneg _ ]

/-
!-- comment -- !--
Theorem 2 (the gem): the EXACT conformal isometry identity. The "conformal factor" is exactly
the product of the two stereographic denominators (1+‖x‖²)(1+‖y‖²). Proof: rewrite the chordal
distance via `sum_affine_sq`, reduce to scalar algebra in X,Y,P, then `field_simp; ring`.
!-- comment -- !--

**Theorem 2 (Exact conformal identity).**
`‖φ(x)-φ(y)‖² · (1+‖x‖²)(1+‖y‖²) = 4 ‖x-y‖²`. This is the precise sense in which inverse
stereographic projection is a conformal isometry: the chordal sphere distance equals the weighted
Euclidean distance `2‖x-y‖/√((1+‖x‖²)(1+‖y‖²))`.
-/
theorem stereo_conformal_identity (x y : Fin n → ℝ) :
    sphereDist2 (invStereoN x) (invStereoN y) * ((1 + nsq x) * (1 + nsq y))
      = 4 * euclDist2 x y := by
  have hx := denom_pos x
  have hy := denom_pos y
  -- Expand the squared chordal distance of the first `n` coordinates via `sum_affine_sq`.
  have e1 : euclDist2 (invStereoN x).1 (invStereoN y).1
      = (2 / (1 + nsq x)) ^ 2 * nsq x
        + 2 * (2 / (1 + nsq x)) * (-(2 / (1 + nsq y))) * ip x y
        + (-(2 / (1 + nsq y))) ^ 2 * nsq y := by
    unfold euclDist2 invStereoN
    rw [show (∑ i, (2 * x i / (1 + nsq x) - 2 * y i / (1 + nsq y)) ^ 2)
        = ∑ i, ((2 / (1 + nsq x)) * x i + (-(2 / (1 + nsq y))) * y i) ^ 2 from by
      apply Finset.sum_congr rfl; intros; ring]
    exact sum_affine_sq _ _ x y
  unfold sphereDist2
  rw [e1, euclDist2_eq]
  unfold invStereoN
  field_simp
  ring

/-- Chordal distance on the sphere between the two stereographic images. -/
def chordal (x y : Fin n → ℝ) : ℝ := Real.sqrt (sphereDist2 (invStereoN x) (invStereoN y))

/-- Conformally weighted Euclidean distance on `ℝⁿ`:
`d_w(x,y) = 2‖x-y‖ / √((1+‖x‖²)(1+‖y‖²))`. -/
def weightedDist (x y : Fin n → ℝ) : ℝ :=
  2 * Real.sqrt (euclDist2 x y) / Real.sqrt ((1 + nsq x) * (1 + nsq y))

/-
!-- comment -- !--
Theorem 3: taking square roots in Theorem 2 shows the chordal sphere metric equals the weighted
Euclidean metric exactly. This is the isometry (ℝⁿ, d_w) ≅ (Sⁿ, chordal).
!-- comment -- !--

**Theorem 3 (Isometry).** The chordal sphere distance equals the conformally weighted
Euclidean distance, point for point.
-/
theorem chordal_eq_weighted (x y : Fin n → ℝ) : chordal x y = weightedDist x y := by
  unfold chordal weightedDist;
  rw [ ← Real.sqrt_sq ( show 0 ≤ 2 * Real.sqrt ( euclDist2 x y ) / Real.sqrt ( ( 1 + nsq x ) * ( 1 + nsq y ) ) by positivity ), eq_comm ];
  congr 1;
  rw [ div_pow, mul_pow, Real.sq_sqrt <| by exact Finset.sum_nonneg fun _ _ => sq_nonneg _, Real.sq_sqrt <| by exact mul_nonneg ( by exact add_nonneg zero_le_one <| Finset.sum_nonneg fun _ _ => sq_nonneg _ ) <| by exact add_nonneg zero_le_one <| Finset.sum_nonneg fun _ _ => sq_nonneg _ ];
  rw [ div_eq_iff ] <;> first | linarith [ stereo_conformal_identity x y ] | exact ne_of_gt ( mul_pos ( denom_pos x ) ( denom_pos y ) ) ;

/-- Vietoris–Rips edge predicate at scale `ε` for a distance `d`. -/
def VRedge (d : (Fin n → ℝ) → (Fin n → ℝ) → ℝ) (ε : ℝ) (x y : Fin n → ℝ) : Prop := d x y ≤ ε

/-
!-- comment -- !--
Theorem 4: since the two metrics are equal, the Vietoris–Rips filtration (edge set at every
scale ε), and therefore the full pairwise distance matrix of any point cloud, are identical.
Persistence diagrams are functions of this data, so they coincide.
!-- comment -- !--

**Theorem 4 (Persistence equality).** For every scale `ε`, the Vietoris–Rips edge set under
the spherical chordal metric equals the one under the weighted Euclidean metric; equivalently the
distance matrix of any finite point cloud is identical, so the persistence diagrams agree.
-/
theorem persistence_edge_equality (ε : ℝ) (x y : Fin n → ℝ) :
    VRedge chordal ε x y ↔ VRedge weightedDist ε x y := by
  unfold VRedge;
  rw [ chordal_eq_weighted ]

/-- The distance matrix of any finite point cloud is identical under the two metrics. -/
theorem distance_matrix_eq {m : ℕ} (X : Fin m → (Fin n → ℝ)) (i j : Fin m) :
    chordal (X i) (X j) = weightedDist (X i) (X j) :=
  chordal_eq_weighted (X i) (X j)

/-
!-- comment -- !--
Bonus: the spherical GEODESIC distance is g(chordal) with g(c) = 2·arcsin(c/2), strictly
increasing on [0,2]. A strictly monotone reparametrization of the filtration leaves persistence
diagrams invariant, so the equality also holds for the geodesic metric.
!-- comment -- !--

**Theorem 5 (Geodesic monotonicity).** The geodesic-from-chordal map `c ↦ 2·arcsin(c/2)` is
strictly monotone on `[0,2]`, so spherical *geodesic* persistence is a monotone reparametrization
of chordal (= weighted Euclidean) persistence.
-/
theorem geodesic_strictMonoOn :
    StrictMonoOn (fun c : ℝ => 2 * Real.arcsin (c / 2)) (Set.Icc (0 : ℝ) 2) := by
  unfold StrictMonoOn; intros a ha b hb hab; exact mul_lt_mul_of_pos_left ( Real.strictMonoOn_arcsin ⟨ by linarith [ ha.1 ], by linarith [ ha.2 ] ⟩ ⟨ by linarith [ hb.1 ], by linarith [ hb.2 ] ⟩ ( by linarith ) ) zero_lt_two;

end ConformalPersistence