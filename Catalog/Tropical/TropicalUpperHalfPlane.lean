/-
  # Tropical Upper Half-Plane: Max-Plus Hyperbolic Geometry

  This file establishes the tropical upper half-plane H_trop as a metric space
  with max-plus hyperbolic structure, forming the "bulk" of a tropical holographic
  duality connecting tropical geometry to hyperbolic geometry (AdS physics).

  Key structures:
  - `TropicalUpperHalfPlane`: H_trop = {(x,y) : x ∈ ℝ, y > 0}
  - `tropRawDist`: the raw tropical distance max(|Δx|,|Δy|)/min(y₁,y₂)
  - `tropHoroMetric`: a corrected horocyclic metric that IS a true metric
  - Tropical balls, geodesics, convexity, and isometries

  Bridge: connects tropical geometry (piecewise-linear) to hyperbolic geometry (AdS bulk)
  and metric geometry (CAT(0) spaces).

  Applications:
  - Post-quantum lattice isometries
  - Certified ML robustness via Lipschitz bounds
  - Quantum gravity: tropical analog of the Poincaré upper half-plane
-/
import Mathlib

open Real Set

/-! ## Section 1: The Tropical Upper Half-Plane Structure -/

/-- The tropical upper half-plane: the bulk space of tropical holographic duality.
    This is ℝ × ℝ_{>0}, the tropical analog of the Poincaré upper half-plane.
    Bridge: connects tropical geometry to AdS physics (Anti-de Sitter spacetime). -/
structure TropicalUpperHalfPlane where
  x : ℝ
  y : ℝ
  y_pos : 0 < y

namespace TropicalUpperHalfPlane

instance : Inhabited TropicalUpperHalfPlane :=
  ⟨⟨0, 1, one_pos⟩⟩

@[ext]
theorem ext {P Q : TropicalUpperHalfPlane} (hx : P.x = Q.x) (hy : P.y = Q.y) :
    P = Q := by
  cases P; cases Q; simp at *; exact ⟨hx, hy⟩

theorem y_ne_zero (P : TropicalUpperHalfPlane) : P.y ≠ 0 := ne_of_gt P.y_pos

theorem y_nonneg (P : TropicalUpperHalfPlane) : 0 ≤ P.y := le_of_lt P.y_pos

/-- Construct a point at height 1. -/
def atHeight1 (x₀ : ℝ) : TropicalUpperHalfPlane := ⟨x₀, 1, one_pos⟩

/-- The base point (0, 1). -/
def basePoint : TropicalUpperHalfPlane := ⟨0, 1, one_pos⟩

/-! ## Section 2: The Raw Tropical Distance Function -/

/-- The raw tropical distance: max(|x₁-x₂|, |y₁-y₂|) / min(y₁, y₂).
    Bridge: connects ℓ∞ geometry to hyperbolic scaling. -/
noncomputable def tropRawDist (P Q : TropicalUpperHalfPlane) : ℝ :=
  max (|P.x - Q.x|) (|P.y - Q.y|) / min P.y Q.y

/-- Raw tropical distance is nonneg. -/
theorem tropRawDist_nonneg (P Q : TropicalUpperHalfPlane) :
    0 ≤ tropRawDist P Q :=
  div_nonneg (le_max_of_le_left (abs_nonneg _)) (le_min P.y_nonneg Q.y_nonneg)

/-- Raw tropical distance to self is zero. -/
theorem tropRawDist_self (P : TropicalUpperHalfPlane) :
    tropRawDist P P = 0 := by
  simp [tropRawDist]

/-- Raw tropical distance is symmetric. -/
theorem tropRawDist_comm (P Q : TropicalUpperHalfPlane) :
    tropRawDist P Q = tropRawDist Q P := by
  simp [tropRawDist, abs_sub_comm, min_comm]

/-- The min of two positive heights is positive. -/
theorem min_y_pos (P Q : TropicalUpperHalfPlane) : 0 < min P.y Q.y :=
  lt_min P.y_pos Q.y_pos

/-- Raw tropical distance is positive for distinct points. -/
theorem tropRawDist_pos {P Q : TropicalUpperHalfPlane} (h : P ≠ Q) :
    0 < tropRawDist P Q := by
  apply div_pos _ (lt_min P.y_pos Q.y_pos)
  rcases not_and_or.mp (fun ⟨hx, hy⟩ => h (ext hx hy)) with hx | hy
  · exact lt_max_of_lt_left (abs_pos.mpr (sub_ne_zero.mpr hx))
  · exact lt_max_of_lt_right (abs_pos.mpr (sub_ne_zero.mpr hy))

/-- tropRawDist = 0 iff P = Q. -/
theorem tropRawDist_eq_zero_iff (P Q : TropicalUpperHalfPlane) :
    tropRawDist P Q = 0 ↔ P = Q := by
  constructor
  · intro h; by_contra hne; exact ne_of_gt (tropRawDist_pos hne) h
  · intro h; rw [h]; exact tropRawDist_self Q

/-- The raw tropical distance does NOT satisfy the triangle inequality.
    Counterexample: P=(0,1), Q=(0,2), R=(0,3): d(P,R)=2 > 1.5=d(P,Q)+d(Q,R). -/
theorem tropRawDist_triangle_fails :
    ∃ P Q R : TropicalUpperHalfPlane,
      tropRawDist P R > tropRawDist P Q + tropRawDist Q R := by
  refine ⟨⟨0, 1, one_pos⟩, ⟨0, 2, by positivity⟩, ⟨0, 3, by positivity⟩, ?_⟩
  simp [tropRawDist]
  norm_num

/-! ## Section 3: The Horocyclic Metric (True Metric) -/

/-- The horocyclic metric on H_trop:
    d(P,Q) = max(|x_P/y_P - x_Q/y_Q|, |log(y_P) - log(y_Q)|).
    Embeds H_trop into (ℝ², ‖·‖_∞) via (x,y) ↦ (x/y, log y).
    Bridge: connects horocyclic foliation to tropical logarithmic coordinates. -/
noncomputable def tropHoroMetric (P Q : TropicalUpperHalfPlane) : ℝ :=
  max (|P.x / P.y - Q.x / Q.y|) (|Real.log P.y - Real.log Q.y|)

/-- Horocyclic self-distance is zero. -/
theorem tropHoroMetric_self (P : TropicalUpperHalfPlane) :
    tropHoroMetric P P = 0 := by simp [tropHoroMetric]

/-- Horocyclic symmetry. -/
theorem tropHoroMetric_comm (P Q : TropicalUpperHalfPlane) :
    tropHoroMetric P Q = tropHoroMetric Q P := by
  simp [tropHoroMetric, abs_sub_comm]

/-- Horocyclic nonnegativity. -/
theorem tropHoroMetric_nonneg (P Q : TropicalUpperHalfPlane) :
    0 ≤ tropHoroMetric P Q :=
  le_max_of_le_left (abs_nonneg _)

/-- ℓ∞ triangle inequality: key structural lemma. -/
theorem sup_abs_sub_triangle (a₁ a₂ b₁ b₂ c₁ c₂ : ℝ) :
    max (|a₁ - c₁|) (|a₂ - c₂|) ≤
      max (|a₁ - b₁|) (|a₂ - b₂|) + max (|b₁ - c₁|) (|b₂ - c₂|) := by
  apply max_le
  · calc |a₁ - c₁| = |(a₁ - b₁) + (b₁ - c₁)| := by ring_nf
      _ ≤ |a₁ - b₁| + |b₁ - c₁| := abs_add_le _ _
      _ ≤ max (|a₁ - b₁|) (|a₂ - b₂|) + max (|b₁ - c₁|) (|b₂ - c₂|) := by
          gcongr <;> simp [le_max_left, le_max_right]
  · calc |a₂ - c₂| = |(a₂ - b₂) + (b₂ - c₂)| := by ring_nf
      _ ≤ |a₂ - b₂| + |b₂ - c₂| := abs_add_le _ _
      _ ≤ max (|a₁ - b₁|) (|a₂ - b₂|) + max (|b₁ - c₁|) (|b₂ - c₂|) := by
          gcongr <;> simp [le_max_left, le_max_right]

/-- Horocyclic triangle inequality. -/
theorem tropHoroMetric_triangle (P Q R : TropicalUpperHalfPlane) :
    tropHoroMetric P R ≤ tropHoroMetric P Q + tropHoroMetric Q R :=
  sup_abs_sub_triangle _ _ _ _ _ _

/-
Horocyclic metric zero iff equal.
-/
theorem tropHoroMetric_eq_zero_iff (P Q : TropicalUpperHalfPlane) :
    tropHoroMetric P Q = 0 ↔ P = Q := by
  unfold TropicalUpperHalfPlane.tropHoroMetric;
  constructor <;> intro h;
  · -- From |log P.y - log Q.y| = 0, we get log P.y = log Q.y, hence P.y = Q.y.
    have h_y : P.y = Q.y := by
      exact Real.log_injOn_pos ( show 0 < P.y from P.y_pos ) ( show 0 < Q.y from Q.y_pos ) ( by cases max_eq_iff.mp h <;> cases abs_cases ( P.x / P.y - Q.x / Q.y ) <;> cases abs_cases ( Real.log P.y - Real.log Q.y ) <;> linarith );
    cases max_eq_iff.mp h <;> simp_all +decide [ sub_eq_iff_eq_add ];
    · exact TropicalUpperHalfPlane.ext ( by rw [ div_eq_div_iff ] at h <;> nlinarith [ Q.y_pos ] ) h_y;
    · exact TropicalUpperHalfPlane.ext ( by rw [ div_eq_div_iff ] at h <;> nlinarith [ Q.y_pos ] ) h_y;
  · aesop

/-- Horocyclic metric positive for distinct points. -/
theorem tropHoroMetric_pos {P Q : TropicalUpperHalfPlane} (h : P ≠ Q) :
    0 < tropHoroMetric P Q := by
  rw [lt_iff_le_and_ne]
  exact ⟨tropHoroMetric_nonneg P Q,
    fun h' => h ((tropHoroMetric_eq_zero_iff P Q).mp h'.symm)⟩

/-! ## Section 4: Horocyclic Embedding -/

/-- The horocyclic embedding: (x,y) ↦ (x/y, log y).
    Bridge: connects tropical geometry to Euclidean geometry. -/
noncomputable def horoEmbed (P : TropicalUpperHalfPlane) : ℝ × ℝ :=
  (P.x / P.y, Real.log P.y)

/-
The horocyclic embedding is injective.
-/
theorem horoEmbed_injective : Function.Injective horoEmbed := by
  intro P Q h_eq
  have h1 : P.x / P.y = Q.x / Q.y := by
    exact congr_arg Prod.fst h_eq
  have h2 : Real.log P.y = Real.log Q.y := by
    injection h_eq
  have h3 : P.y = Q.y := by
    rw [ ← Real.exp_log ( TropicalUpperHalfPlane.y_pos P ), ← Real.exp_log ( TropicalUpperHalfPlane.y_pos Q ), h2 ]
  have h4 : P.x = Q.x := by
    simp_all +decide [ div_eq_mul_inv ];
    exact h1.resolve_right Q.y_pos.ne'
  exact TropicalUpperHalfPlane.ext h4 h3

/-- The horocyclic metric equals ℓ∞ distance of embedded points. -/
theorem tropHoroMetric_eq_sup_dist (P Q : TropicalUpperHalfPlane) :
    tropHoroMetric P Q =
      max (|(horoEmbed P).1 - (horoEmbed Q).1|)
          (|(horoEmbed P).2 - (horoEmbed Q).2|) := rfl

/-! ## Section 5: Tropical Balls -/

/-- Tropical ball in horocyclic metric.
    Bridge: connects metric balls to tropical polytopes for ML optimization. -/
def tropBall (P : TropicalUpperHalfPlane) (r : ℝ) : Set TropicalUpperHalfPlane :=
  {Q | tropHoroMetric P Q ≤ r}

/-- Center is in its own ball. -/
theorem mem_tropBall_self (P : TropicalUpperHalfPlane) {r : ℝ} (hr : 0 ≤ r) :
    P ∈ tropBall P r := by
  simp [tropBall, tropHoroMetric_self, hr]

/-- Ball membership as rectangular constraint. -/
theorem mem_tropBall_iff (P Q : TropicalUpperHalfPlane) (r : ℝ) :
    Q ∈ tropBall P r ↔
      |P.x / P.y - Q.x / Q.y| ≤ r ∧ |Real.log P.y - Real.log Q.y| ≤ r := by
  simp only [tropBall, Set.mem_setOf_eq, tropHoroMetric, max_le_iff]

/-- Ball monotonicity. -/
theorem tropBall_mono {P : TropicalUpperHalfPlane} {r s : ℝ} (hrs : r ≤ s) :
    tropBall P r ⊆ tropBall P s :=
  fun _ hQ => le_trans hQ hrs

/-! ## Section 6: Isometries of H_trop -/

/-- Horizontal translation. -/
def horizTranslate (t : ℝ) (P : TropicalUpperHalfPlane) : TropicalUpperHalfPlane :=
  ⟨P.x + t, P.y, P.y_pos⟩

/-- Vertical scaling by a positive factor. -/
def vertScale (c : ℝ) (hc : 0 < c) (P : TropicalUpperHalfPlane) :
    TropicalUpperHalfPlane :=
  ⟨P.x, c * P.y, mul_pos hc P.y_pos⟩

/-- Vertical scaling preserves the log-height component of the horocyclic metric.
    The log-coordinate absorbs multiplicative scaling: log(cy) = log c + log y.
    Bridge: connects scale invariance to renormalization group flow in physics. -/
theorem vertScale_log_component (c : ℝ) (hc : 0 < c)
    (P Q : TropicalUpperHalfPlane) :
    |Real.log (vertScale c hc P).y - Real.log (vertScale c hc Q).y|
    = |Real.log P.y - Real.log Q.y| := by
  simp only [vertScale]
  rw [Real.log_mul (ne_of_gt hc) (ne_of_gt P.y_pos),
      Real.log_mul (ne_of_gt hc) (ne_of_gt Q.y_pos)]
  ring_nf

/-- Horocyclic translation: (x,y) ↦ (x + t*y, y) shifts the first horocyclic
    coordinate by t while preserving height, hence is an isometry.
    Bridge: connects translation symmetry to momentum conservation in physics. -/
def horoTranslate (t : ℝ) (P : TropicalUpperHalfPlane) : TropicalUpperHalfPlane :=
  ⟨P.x + t * P.y, P.y, P.y_pos⟩

/-
Horocyclic translation is an isometry.
-/
theorem horoTranslate_isometry (t : ℝ) (P Q : TropicalUpperHalfPlane) :
    tropHoroMetric (horoTranslate t P) (horoTranslate t Q)
    = tropHoroMetric P Q := by
  unfold TropicalUpperHalfPlane.tropHoroMetric;
  unfold horoTranslate; norm_num [ abs_sub_comm ] ;
  rw [ add_div, add_div, mul_div_cancel_right₀ _ ( ne_of_gt P.y_pos ), mul_div_cancel_right₀ _ ( ne_of_gt Q.y_pos ) ] ; ring

/-! ## Section 7: Tropical Geodesic Segments -/

/-- The straight line in horocyclic coordinates connecting P to Q.
    This is a geodesic: its length equals the horocyclic distance. -/
noncomputable def horoGeodesic (P Q : TropicalUpperHalfPlane) (t : ℝ) :
    TropicalUpperHalfPlane where
  x := ((1 - t) * (P.x / P.y) + t * (Q.x / Q.y)) *
       Real.exp ((1 - t) * Real.log P.y + t * Real.log Q.y)
  y := Real.exp ((1 - t) * Real.log P.y + t * Real.log Q.y)
  y_pos := Real.exp_pos _

/-
The geodesic starts at P (parameter t=0).
-/
theorem horoGeodesic_zero (P Q : TropicalUpperHalfPlane) :
    horoGeodesic P Q 0 = P := by
  refine' TropicalUpperHalfPlane.ext _ _ <;> simp [TropicalUpperHalfPlane.horoGeodesic];
  · rw [ Real.exp_log P.y_pos, div_mul_cancel₀ _ ( ne_of_gt P.y_pos ) ];
  · rw [ Real.exp_log P.y_pos ]

/-
The geodesic ends at Q (parameter t=1).
-/
theorem horoGeodesic_one (P Q : TropicalUpperHalfPlane) :
    horoGeodesic P Q 1 = Q := by
  unfold TropicalUpperHalfPlane.horoGeodesic;
  -- Simplify the expressions for the x and y components.
  simp [Real.exp_log Q.y_pos];
  rw [ div_mul_cancel₀ _ Q.y_pos.ne' ]

/-! ## Section 8: Tropical Boundary -/

/-- The tropical boundary: ℝ ∪ {∞}, conformal boundary of H_trop.
    Bridge: connects boundary CFT to bulk gravity (AdS/CFT). -/
abbrev TropicalBoundary := WithTop ℝ

/-- Regularized boundary embedding at height ε > 0 (UV cutoff). -/
def boundaryLift (x₀ : ℝ) (ε : ℝ) (hε : 0 < ε) : TropicalUpperHalfPlane :=
  ⟨x₀, ε, hε⟩

/-! ## Section 9: Tropical Convexity -/

/-- A set is tropically convex if it contains horocyclic geodesics. -/
def TropConvex (S : Set TropicalUpperHalfPlane) : Prop :=
  ∀ P Q : TropicalUpperHalfPlane, P ∈ S → Q ∈ S →
    ∀ t : ℝ, 0 ≤ t → t ≤ 1 → horoGeodesic P Q t ∈ S

/-- The whole space is tropically convex. -/
theorem tropConvex_univ : TropConvex Set.univ :=
  fun _ _ _ _ _ _ _ => Set.mem_univ _

/-- The empty set is vacuously tropically convex. -/
theorem tropConvex_empty : TropConvex ∅ :=
  fun _ _ hP => absurd hP (Set.notMem_empty _)

/-! ## Section 10: Tropical Inversion and Duality -/

/-- Tropical inversion: (x,y) ↦ (-x, 1/y). -/
noncomputable def tropInversion (P : TropicalUpperHalfPlane) :
    TropicalUpperHalfPlane :=
  ⟨-P.x, 1 / P.y, div_pos one_pos P.y_pos⟩

/-- Tropical inversion is an involution. -/
theorem tropInversion_involution (P : TropicalUpperHalfPlane) :
    tropInversion (tropInversion P) = P := by
  ext <;> simp [tropInversion]

/-
Tropical inversion preserves the log-height component (with sign flip).
    Bridge: connects conformal inversion (physics) to tropical duality.
-/
theorem tropInversion_log_height (P Q : TropicalUpperHalfPlane) :
    |Real.log (tropInversion P).y - Real.log (tropInversion Q).y|
    = |Real.log P.y - Real.log Q.y| := by
  unfold TropicalUpperHalfPlane.tropInversion; norm_num;
  rw [ neg_add_eq_sub, abs_sub_comm ]

/-- Tropical reflection: (x,y) ↦ (-x, y) negates the boundary coordinate.
    This IS an isometry of the horocyclic metric. -/
def tropReflect (P : TropicalUpperHalfPlane) : TropicalUpperHalfPlane :=
  ⟨-P.x, P.y, P.y_pos⟩

/-
Tropical reflection is an isometry.
-/
theorem tropReflect_isometry (P Q : TropicalUpperHalfPlane) :
    tropHoroMetric (tropReflect P) (tropReflect Q) = tropHoroMetric P Q := by
  unfold TropicalUpperHalfPlane.tropHoroMetric TropicalUpperHalfPlane.tropReflect;
  grind

/-- Tropical reflection is an involution. -/
theorem tropReflect_involution (P : TropicalUpperHalfPlane) :
    tropReflect (tropReflect P) = P := by
  ext <;> simp [tropReflect]

/-- Basepoint is a fixed point of inversion. -/
theorem tropInversion_basePoint :
    tropInversion basePoint = ⟨0, 1, one_pos⟩ := by
  ext <;> simp [tropInversion, basePoint]

/-! ## Section 11: Diameter Bounds -/

/-- The diameter of a tropical ball is at most 2r.
    Bridge: connects metric geometry to certified_robustness bounds. -/
theorem tropBall_diameter_le (P : TropicalUpperHalfPlane) (r : ℝ)
    {Q₁ Q₂ : TropicalUpperHalfPlane}
    (h₁ : Q₁ ∈ tropBall P r) (h₂ : Q₂ ∈ tropBall P r) :
    tropHoroMetric Q₁ Q₂ ≤ 2 * r := by
  have tri := tropHoroMetric_triangle Q₁ P Q₂
  have sym : tropHoroMetric Q₁ P = tropHoroMetric P Q₁ := tropHoroMetric_comm Q₁ P
  have h1' : tropHoroMetric P Q₁ ≤ r := h₁
  have h2' : tropHoroMetric P Q₂ ≤ r := h₂
  linarith

/-
H_trop has infinite diameter: ∀ R, ∃ points at distance > R.
-/
theorem tropHoroMetric_unbounded (R : ℝ) :
    ∃ P Q : TropicalUpperHalfPlane, tropHoroMetric P Q > R := by
  by_contra h;
  -- Choose P = (0, 1) and Q = (0, exp(R+1)).
  set P : TropicalUpperHalfPlane := ⟨0, 1, one_pos⟩
  set Q : TropicalUpperHalfPlane := ⟨0, Real.exp (R + 1), Real.exp_pos (R + 1)⟩;
  refine' h ⟨ P, Q, _ ⟩ ; unfold TropicalUpperHalfPlane.tropHoroMetric ; norm_num;
  simp +zetaDelta at *;
  cases abs_cases ( R + 1 ) <;> linarith

end TropicalUpperHalfPlane