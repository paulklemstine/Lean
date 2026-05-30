import Mathlib

/-!
# Incongruity Resolution Theory: A Metric Framework

We formalize the mathematical structure of humor using metric spaces, tropical
algebra, and probability theory. A joke is modeled as a triple (setup, expectation,
punchline) in a pseudometric space. The "surprise" is the distance from expectation
to punchline, and the triangle inequality constrains the geometry of humor.

## Main Definitions

- `IncongruityTriple` — a triple (setup, expectation, punchline) in a pseudometric space
- `IncongruityTriple.surprise` — distance from expectation to punchline
- `IncongruityTriple.tension` — distance from setup to expectation
- `IncongruityTriple.arc` — distance from setup to punchline
- `IncongruityTriple.defect` — triangle inequality defect (≥ 0)
- `ComedyPolytope` — the set of achievable (tension, surprise, arc) triples

## Main Results

1. `defect_nonneg` — the triangle defect is always nonneg
2. `surprise_reverse_bound` — reverse triangle inequality bounds surprise from below
3. `defect_swap_eq` — defect is invariant under setup↔punchline swap
4. `lipschitz_surprise_bound` — K-Lipschitz maps scale surprise by at most K
5. `comedy_polytope_convex` — the comedy polytope is convex
6. `tropical_comedy_subadditive` — tropical max-plus aggregation is subadditive
7. `pythagorean_surprise` — Pythagorean theorem for right-angle joke triples in ℝ²
8. `mean_abs_dev_le_rms` — E[|X - μ|] ≤ √Var(X) (Jensen bound)
9. `comedy_chain_leverage` — chain of surprises bounds total arc
-/

noncomputable section

open Real Finset BigOperators

/-! ## Part I: Incongruity Triples in Metric Spaces -/

/-- An incongruity triple models (setup, expectation, punchline) in a pseudometric space.
    This captures the cognitive science model: a joke sets up an expectation, then
    delivers a punchline that deviates from it. The metric distance quantifies
    the degree of incongruity. -/
structure IncongruityTriple (X : Type*) [PseudoMetricSpace X] where
  setup : X
  expectation : X
  punchline : X

namespace IncongruityTriple

variable {X : Type*} [PseudoMetricSpace X]

/-- The surprise of a joke: distance from expectation to punchline. -/
def surprise (j : IncongruityTriple X) : ℝ := dist j.expectation j.punchline

/-- The setup tension: distance from setup to expectation. -/
def tension (j : IncongruityTriple X) : ℝ := dist j.setup j.expectation

/-- The resolution arc: distance from setup to punchline. -/
def arc (j : IncongruityTriple X) : ℝ := dist j.setup j.punchline

/-- The triangle defect measures how much the triple deviates from collinearity.
    By the triangle inequality, this is always ≥ 0. -/
def defect (j : IncongruityTriple X) : ℝ :=
  j.tension + j.surprise - j.arc

/-- Swap setup and punchline, keeping expectation fixed. -/
def swap (j : IncongruityTriple X) : IncongruityTriple X where
  setup := j.punchline
  expectation := j.expectation
  punchline := j.setup

/-! ### Core Metric Theorems -/

/-
**The Fundamental Inequality of Comedy**: The triangle defect is always nonneg.
    Proof uses the triangle inequality: dist(s,e) + dist(e,p) ≥ dist(s,p).
-/
theorem defect_nonneg (j : IncongruityTriple X) : 0 ≤ j.defect := by
  exact sub_nonneg_of_le ( dist_triangle _ _ _ )

/-
**Reverse triangle inequality**: surprise ≥ |tension - arc|.
-/
theorem surprise_reverse_bound (j : IncongruityTriple X) :
    |j.tension - j.arc| ≤ j.surprise := by
  rw [ abs_sub_le_iff ];
  constructor <;> simp +decide [ IncongruityTriple.tension, IncongruityTriple.arc, IncongruityTriple.surprise ];
  · simpa only [ add_comm, dist_comm ] using dist_triangle j.setup j.punchline j.expectation;
  · simpa only [ add_comm, dist_comm ] using dist_triangle j.setup j.expectation j.punchline

/-
**Defect is invariant under setup↔punchline swap** (uses dist symmetry).
-/
theorem defect_swap_eq (j : IncongruityTriple X) :
    j.swap.defect = j.defect := by
  unfold IncongruityTriple.defect;
  unfold IncongruityTriple.swap IncongruityTriple.tension IncongruityTriple.surprise IncongruityTriple.arc;
  simp +decide only [dist_comm] ; ring

/-
**Lipschitz Translation Theorem**: A K-Lipschitz map scales surprise by at most K.
-/
theorem lipschitz_surprise_bound {Y : Type*} [PseudoMetricSpace Y]
    (f : X → Y) (K : ℝ) (hK : 0 ≤ K) (hf : LipschitzWith ⟨K, hK⟩ f)
    (j : IncongruityTriple X) :
    (⟨f j.setup, f j.expectation, f j.punchline⟩ : IncongruityTriple Y).surprise
      ≤ K * j.surprise := by
  exact hf.dist_le_mul _ _

/-
When defect = 0, surprise = arc - tension (maximum surprise for given geometry).
-/
theorem surprise_eq_of_defect_zero (j : IncongruityTriple X)
    (h : j.defect = 0) : j.surprise = j.arc - j.tension := by
  exact eq_sub_of_add_eq' ( by rw [ IncongruityTriple.defect ] at h; linarith )

/-
Surprise ≤ tension + arc (direct triangle inequality on the other side).
-/
theorem surprise_le_tension_add_arc (j : IncongruityTriple X) :
    j.surprise ≤ j.tension + j.arc := by
  convert dist_triangle_left _ _ _ using 1

end IncongruityTriple

/-! ## Part II: The Comedy Polytope -/

/-- The comedy polytope is the set of nonneg triples (a, b, c) satisfying all
    three triangle inequalities. This is exactly the set of achievable
    (tension, surprise, arc) triples in some metric space. -/
def ComedyPolytope : Set (ℝ × ℝ × ℝ) :=
  {v | 0 ≤ v.1 ∧ 0 ≤ v.2.1 ∧ 0 ≤ v.2.2 ∧
       v.1 + v.2.1 ≥ v.2.2 ∧
       v.1 + v.2.2 ≥ v.2.1 ∧
       v.2.1 + v.2.2 ≥ v.1}

/-
The comedy polytope is convex.
-/
theorem comedy_polytope_convex : Convex ℝ ComedyPolytope := by
  intro v hv w hw a b ha hb hab;
  constructor <;> norm_num;
  · exact add_nonneg ( mul_nonneg ha hv.1 ) ( mul_nonneg hb hw.1 );
  · exact ⟨ by nlinarith [ hv.2.1, hw.2.1 ], by nlinarith [ hv.2.2.1, hw.2.2.1 ], by nlinarith [ hv.2.2.2, hw.2.2.2 ], by nlinarith [ hv.2.2.2, hw.2.2.2 ], by nlinarith [ hv.2.2.2, hw.2.2.2 ] ⟩

/-
The comedy polytope is a cone: scaling a valid triple by t ≥ 0 stays valid.
    This means "amplifying" a joke preserves its geometric feasibility.
-/
theorem comedy_polytope_cone (v : ℝ × ℝ × ℝ) (hv : v ∈ ComedyPolytope)
    (t : ℝ) (ht : 0 ≤ t) :
    (t * v.1, t * v.2.1, t * v.2.2) ∈ ComedyPolytope := by
  exact ⟨ mul_nonneg ht hv.1, mul_nonneg ht hv.2.1, mul_nonneg ht hv.2.2.1, by nlinarith [ hv.2.2.2.1 ], by nlinarith [ hv.2.2.2.2.1 ], by nlinarith [ hv.2.2.2.2.2 ] ⟩

/-! ## Part III: Tropical Comedy Aggregation -/

/-
**Tropical Cauchy-Schwarz**: max(a₁+b₁, a₂+b₂) ≤ max(a₁,a₂) + max(b₁,b₂).
    This is a fundamental inequality for max-plus algebra, applied to comedy aggregation.
-/
theorem tropical_comedy_subadditive (a₁ a₂ b₁ b₂ : ℝ) :
    max (a₁ + b₁) (a₂ + b₂) ≤ max a₁ a₂ + max b₁ b₂ := by
  grind +qlia

/-
Finset version of tropical subadditivity.
-/
theorem tropical_sup_add_le {ι : Type*} (s : Finset ι) (hs : s.Nonempty)
    (f g : ι → ℝ) :
    s.sup' hs (fun i => f i + g i) ≤ s.sup' hs f + s.sup' hs g := by
  simp +decide [ Finset.sup'_le_iff ];
  exact fun i hi => add_le_add ( Finset.le_sup' f hi ) ( Finset.le_sup' g hi )

/-! ## Part IV: The Surprise-Entropy Duality (Cross-Domain Bridge) -/

/-
Cauchy-Schwarz for finite sums: (∑|f i|)² ≤ n · ∑ f i².
-/
theorem sum_abs_sq_le (n : ℕ) (f : Fin n → ℝ) :
    (∑ i, |f i|) ^ 2 ≤ n * ∑ i, (f i) ^ 2 := by
  have := ( Finset.univ.sum_le_sum fun i _ => mul_self_nonneg ( |f i| - ( ∑ i : Fin n, |f i| ) / n ) );
  by_cases hn : n = 0 <;> simp_all +decide [ sub_mul, mul_sub ];
  · aesop;
  · case _ => simp_all +decide [ ← sq, ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] ; nlinarith [ mul_div_cancel₀ ( ∑ i, |f i| ) ( Nat.cast_ne_zero.mpr hn ) ] ;

/-
**Mean Absolute Deviation ≤ RMS Deviation** (discrete Jensen).
    Average surprise (MAD) ≤ uncertainty (standard deviation).
    Uses Cauchy-Schwarz: (∑|xᵢ|)² ≤ n · ∑xᵢ².
-/
theorem mean_abs_dev_le_rms (n : ℕ) (hn : 0 < n) (x : Fin n → ℝ) :
    let μ := (∑ i, x i) / n
    (∑ i, |x i - μ|) / n ≤ Real.sqrt ((∑ i, (x i - μ) ^ 2) / n) := by
  refine Real.le_sqrt_of_sq_le ?_;
  -- Apply the Cauchy-Schwarz inequality in the form $(\sum |a_i|)^2 \leq n \sum a_i^2$.
  have h_cauchy_schwarz : (∑ i, |(x i - (∑ i, x i) / n)|) ^ 2 ≤ n * ∑ i, (x i - (∑ i, x i) / n) ^ 2 := by
    convert sum_abs_sq_le n ( fun i => x i - ( ∑ i, x i ) / n ) using 1;
  rw [ div_pow, div_le_div_iff₀ ] <;> first | positivity | nlinarith;

/-! ## Part V: Pythagorean Comedy — Cross-Domain Connection -/

/-
**The Pythagorean Comedy Theorem**: In ℝ², if a joke triple forms a right angle
    at the expectation, then surprise² + tension² = arc². This is the bridge
    between humor geometry and the Pythagorean theorem.
-/
theorem pythagorean_surprise (s e p : EuclideanSpace ℝ (Fin 2))
    (h_perp : @inner ℝ (EuclideanSpace ℝ (Fin 2)) _ (s - e) (p - e) = (0 : ℝ)) :
    dist s e ^ 2 + dist e p ^ 2 = dist s p ^ 2 := by
  norm_num [ dist_eq_norm, EuclideanSpace.norm_eq ] at *;
  norm_num [ Real.sq_sqrt ( add_nonneg ( sq_nonneg _ ) ( sq_nonneg _ ) ) ] at *;
  norm_num [ Fin.sum_univ_two, inner ] at * ; linarith!

/-! ## Part VI: Comedy Chain Leverage -/

/-
**Comedy Chain Leverage**: For a chain of n+1 points (modeling n consecutive
    jokes where each punchline is the next setup), the sum of surprises
    (path length) is at least the total arc (endpoint distance).
-/
theorem comedy_chain_leverage {X : Type*} [PseudoMetricSpace X]
    (n : ℕ) (pts : Fin (n + 1) → X) :
    dist (pts 0) (pts (Fin.last n)) ≤
    ∑ i : Fin n, dist (pts i.castSucc) (pts i.succ) := by
  induction' n with n ih;
  · simp +decide [ Fin.eq_zero ];
  · rw [ Fin.sum_univ_castSucc ];
    exact le_trans ( dist_triangle _ _ _ ) ( add_le_add ( ih fun i => pts i.castSucc ) le_rfl )

/-! ## Part VII: Conjectures -/

/-
**Conjecture (Half-Surprise Lower Bound)**: In any metric space with 3 distinct
    points, there exists a triple with comedy ratio ≥ 1/2.

    Testable: For any finite metric space, compute max(surprise/arc) over triples.
    The conjecture predicts this maximum is always ≥ 1/2.
-/
theorem comedy_ratio_half_exists
    {X : Type*} [PseudoMetricSpace X]
    (a b c : X) (hab : dist a b ≠ 0) (_hbc : dist b c ≠ 0) (_hac : dist a c ≠ 0) :
    ∃ (j : IncongruityTriple X),
      0 < j.arc ∧ 1 / 2 ≤ j.surprise / j.arc := by
  -- Consider the triple ⟨a, a, b⟩ �.� The surprise is dist �(a�, b), and the arc is dist(a, b). The ratio is 1. Or consider ⟨b, a, c⟩.
  use ⟨a, a, b⟩
  simp [IncongruityTriple.surprise, IncongruityTriple.arc];
  exact ⟨ lt_of_le_of_ne dist_nonneg hab.symm, by rw [ div_self hab ] ; norm_num ⟩

end