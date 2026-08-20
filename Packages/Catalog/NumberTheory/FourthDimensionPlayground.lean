import Mathlib
import Catalog.Novelty.HopfInnerProductWitness

/-!
# The fourth dimension as a geometric playground

Four-dimensional Euclidean geometry becomes especially transparent after identifying
`ℝ⁴` with `ℂ²`.  This chapter develops four compatible views: the Hopf map, its
circle action, the Clifford torus, and a fixed-point-free quarter-turn.  It also
records the exact Lebesgue volume of a four-ball.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer):
1. **Hopf geometry–complex algebra bridge.** The quadratic Hopf coordinates of a
   unit vector in `ℂ²` lie on the unit two-sphere.
2. **Hopf fibres–group actions bridge.** Multiplication by a unit complex phase
   preserves the Hopf coordinates, while the Hermitian witness reconstructs the
   phase when equality in Cauchy–Schwarz occurs.
3. **Measure–special-functions bridge.** A four-dimensional ball has volume
   `(π²/2)r⁴`.
4. **Cubical geometry–coding bridge.** Antipodal vertices of the tesseract are
   separated by squared distance `16`, and no pair of sign vertices is farther.
5. **Clifford torus–Hopf bridge.** Equal coordinate moduli force the third Hopf
   coordinate to vanish, identifying the Clifford torus with the equator's
   inverse image.
6. **Rotation–topology bridge (bold).** The complex quarter-turn on `S³` is an
   orthogonal motion without a fixed point.
7. **Grand challenge (open-problem category).** Characterize closed smooth
   three-manifolds that embed in `ℝ⁴`; the unrestricted embedding conjecture is
   not assumed here, since known obstructions make it false.

Experiment (Experimenter):
The Hopf norm identity was expanded into real and imaginary parts.  The circle
invariance reduces to multiplicativity of complex norm.  In four dimensions the
even-dimensional ball formula specializes at `k = 2`.  For sign vectors, each
coordinate difference is `0` or `±2`, so each squared contribution is at most
`4`.  The quarter-turn equation `(iz,iw)=(z,w)` forces both coordinates to vanish.

Analysis (Analyst):
A single `ℂ²` model unifies the claims.  The Hopf map is quadratic, the Clifford
torus is its equatorial level set, and scalar phases are precisely the visible
circle symmetry.  The quarter-turn is one distinguished phase and therefore
preserves every norm sphere while having no fixed point away from the origin.
The ball-volume calculation is independent but fixes the metric normalization.

Critique (Critic):
The results below are genuine identities or quantified geometric bounds; none has
conclusion `True`, none is merely a renamed definition, and the principal proofs
use algebraic normalization, inequalities, or witness reconstruction.  The fibre
reconstruction theorem deliberately states the sharp equality case supplied by
the imported Hermitian-witness result rather than claiming that phase invariance
alone proves a global bundle theorem.  The statement about all closed
three-manifolds embedding in four-space is excluded: it needs correction by
embedding obstructions and is not used as an assumption.

Synthesis (Principal Investigator):
Hopf coordinates, Clifford-torus level sets, and fixed-point-free rotations are
three facets of the same complex scalar action on `ℂ²`; exact four-ball volume and
tesseract diameter complement this continuous picture with measure and discrete
geometry.
-- !-- Lab Notes -- !--
-/

open ComplexConjugate MeasureTheory Metric

namespace FourthDimensionPlayground

/-- The three real quadratic coordinates of the classical Hopf map. -/
noncomputable def hopf (z w : ℂ) : Fin 3 → ℝ
  | 0 => 2 * (z * conj w).re
  | 1 => 2 * (z * conj w).im
  | 2 => Complex.normSq z - Complex.normSq w

/-
The Hopf quadratic identity: the squared norm of the image is the square of
that of the source.  In particular, the unit three-sphere maps to the unit
 two-sphere.
-/
theorem hopf_norm_sq (z w : ℂ) :
    ∑ i : Fin 3, hopf z w i ^ 2 = (Complex.normSq z + Complex.normSq w) ^ 2 := by
  unfold hopf;
  erw [ Fin.sum_univ_three ] ; norm_num [ Complex.normSq ] ; ring;

/-
The Hopf map sends the unit sphere in `ℂ²` to the unit sphere in `ℝ³`.
-/
theorem hopf_maps_unit_sphere (z w : ℂ)
    (h : ‖z‖ ^ 2 + ‖w‖ ^ 2 = 1) : ∑ i : Fin 3, hopf z w i ^ 2 = 1 := by
  convert hopf_norm_sq z w using 1;
  simp_all +decide [ Complex.normSq_eq_norm_sq ]

/-
A unit complex phase leaves all Hopf coordinates unchanged.
-/
theorem hopf_phase_invariant (u z w : ℂ) (hu : ‖u‖ = 1) :
    hopf (u * z) (u * w) = hopf z w := by
  ext i;
  fin_cases i <;> unfold hopf;
  · simp_all +decide [ Complex.normSq, Complex.norm_def ];
    grind;
  · simp_all +decide [ mul_assoc ];
    norm_num [ Complex.normSq, Complex.norm_def ] at hu;
    grind;
  · simp +decide [ hu, Complex.normSq_eq_norm_sq ]

/-
Equality in the Hermitian Cauchy–Schwarz bound reconstructs the circle phase,
so the corresponding unit vectors lie on one Hopf fibre.
-/
theorem hopf_fibre_phase_reconstruction (z w z' w' : ℂ)
    (ha : ‖z‖ ^ 2 + ‖w‖ ^ 2 = 1)
    (hb : ‖z'‖ ^ 2 + ‖w'‖ ^ 2 = 1)
    (heq : ‖HopfWitness.witness z w z' w'‖ = 1) :
    ∃ u : ℂ, ‖u‖ = 1 ∧ z' = u * z ∧ w' = u * w := by
  exact ⟨ _, heq, HopfWitness.reconstruct_fibre z w z' w' ha hb heq ⟩

/-
Equal Hopf coordinates force equality in the Hermitian Cauchy–Schwarz
bound. This is the algebraic step turning a quadratic level set into a circle
orbit.
-/
theorem witness_norm_one_of_hopf_eq (z w z' w' : ℂ)
    (ha : ‖z‖ ^ 2 + ‖w‖ ^ 2 = 1)
    (hb : ‖z'‖ ^ 2 + ‖w'‖ ^ 2 = 1)
    (hh : hopf z w = hopf z' w') :
    ‖HopfWitness.witness z w z' w'‖ = 1 := by
  simp_all +decide [ funext_iff, Fin.forall_fin_succ ];
  simp_all +decide [ Complex.normSq, Complex.sq_norm, HopfWitness.witness, hopf ];
  norm_num [ Complex.normSq, Complex.norm_def ];
  grind

/-
**The fibres of the Hopf map are circles.** Two points of the unit
three-sphere have equal Hopf coordinates exactly when one is obtained from the
other by a unit complex phase.
-/
theorem hopf_eq_iff_phase (z w z' w' : ℂ)
    (ha : ‖z‖ ^ 2 + ‖w‖ ^ 2 = 1)
    (hb : ‖z'‖ ^ 2 + ‖w'‖ ^ 2 = 1) :
    hopf z w = hopf z' w' ↔
      ∃ u : ℂ, ‖u‖ = 1 ∧ z' = u * z ∧ w' = u * w := by
  constructor
  · intro hh
    exact hopf_fibre_phase_reconstruction z w z' w' ha hb
      (witness_norm_one_of_hopf_eq z w z' w' ha hb hh)
  · rintro ⟨u, hu, rfl, rfl⟩
    exact (hopf_phase_invariant u z w hu).symm

/-
Exact volume of an open four-dimensional Euclidean ball.
-/
theorem four_ball_volume (x : EuclideanSpace ℝ (Fin 4)) (r : ℝ) :
    volume (ball x r) = ENNReal.ofReal r ^ 4 * ENNReal.ofReal (Real.pi ^ 2 / 2) := by
  convert InnerProductSpace.volume_ball_of_dim_even _ _ _ using 2;
  · norm_num;
  · infer_instance;
  · norm_num

/-- A tesseract vertex is a sign vector. -/
def IsTesseractVertex (x : Fin 4 → ℝ) : Prop := ∀ i, x i = 1 ∨ x i = -1

/-
Any two vertices of the standard tesseract have squared separation at most
`16`; equality is attained by antipodal vertices.
-/
theorem tesseract_squared_distance_le (x y : Fin 4 → ℝ)
    (hx : IsTesseractVertex x) (hy : IsTesseractVertex y) :
    ∑ i, (x i - y i) ^ 2 ≤ 16 := by
  exact le_trans ( Finset.sum_le_sum fun i _ => show ( x i - y i ) ^ 2 ≤ 4 by rcases hx i with ha | ha <;> rcases hy i with hb | hb <;> rw [ ha, hb ] <;> norm_num ) ( by norm_num )

/-
Antipodal tesseract vertices attain squared separation `16`.
-/
theorem tesseract_antipodal_squared_distance (x : Fin 4 → ℝ)
    (hx : IsTesseractVertex x) : ∑ i, (x i - (-x i)) ^ 2 = 16 := by
  exact Eq.symm ( by obtain hi | hi := hx 0 <;> obtain hj | hj := hx 1 <;> obtain hk | hk := hx 2 <;> obtain hl | hl := hx 3 <;> norm_num [ Fin.sum_univ_four, hi, hj, hk, hl ] )

/-
On the Clifford torus, equality of the two coordinate norms is exactly the
vanishing of the third Hopf coordinate.
-/
theorem clifford_torus_equator (z w : ℂ) :
    ‖z‖ = ‖w‖ ↔ hopf z w 2 = 0 := by
  unfold hopf;
  simp +decide [ sub_eq_zero, Complex.normSq_eq_norm_sq ]

/-- Simultaneous multiplication by `i` is a four-dimensional quarter-turn. -/
def quarterTurn (p : ℂ × ℂ) : ℂ × ℂ := (Complex.I * p.1, Complex.I * p.2)

/-
The quarter-turn preserves the squared Euclidean norm.
-/
theorem quarterTurn_norm_sq (p : ℂ × ℂ) :
    ‖(quarterTurn p).1‖ ^ 2 + ‖(quarterTurn p).2‖ ^ 2 = ‖p.1‖ ^ 2 + ‖p.2‖ ^ 2 := by
  unfold quarterTurn; norm_num;

/-
The quarter-turn has no fixed point except the origin; hence its restriction
to every positive-radius three-sphere is fixed-point-free.
-/
theorem quarterTurn_fixed_iff (p : ℂ × ℂ) : quarterTurn p = p ↔ p = 0 := by
  constructor <;> intro h <;> have := congr_arg Prod.fst h <;> have := congr_arg Prod.snd h <;> simp_all +decide [ Prod.ext_iff, Complex.ext_iff, quarterTurn ] ;
  grind

end FourthDimensionPlayground