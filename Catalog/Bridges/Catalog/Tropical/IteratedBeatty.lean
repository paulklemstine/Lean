import Mathlib
import «Catalog».Tropical.MinPlusAlgebra

/-!
# Iterated Beatty sequences

For a positive real modulus `α`, the Beatty map sends `k` to `⌊αk⌋`.  Its
iterates are the iterated Beatty sequences.  This chapter develops order,
membership, and almost-additivity properties which isolate the elementary
mechanism behind necessary-and-sufficient membership criteria.

The floor error is naturally min-plus: ordinary addition is preserved up to a
single unit.  Iteration turns this local error into a controlled hierarchy,
linking Beatty arithmetic with tropical scalar dynamics.
-/

namespace IteratedBeatty

/-- The Beatty map of real modulus `α`. -/
noncomputable def beatty (α : ℝ) (k : ℕ) : ℕ := ⌊α * k⌋₊

/-- The `n`th iterated Beatty map; iteration zero is the identity. -/
noncomputable def iteratedBeatty (α : ℝ) (n k : ℕ) : ℕ := (beatty α)^[n] k

/-- Membership in the positive-indexed `n`th iterated Beatty sequence. -/
def InIterate (α : ℝ) (n x : ℕ) : Prop :=
  ∃ k : ℕ, 0 < k ∧ iteratedBeatty α n k = x

/-
A Beatty value is characterized exactly by its defining half-open interval.
-/
theorem beatty_eq_iff {α : ℝ} (hα : 0 ≤ α) (k x : ℕ) :
    beatty α k = x ↔ (x : ℝ) ≤ α * k ∧ α * k < x + 1 := by
  convert Nat.floor_eq_iff ?_ using 1;
  positivity

/-
For modulus at least one, the Beatty map is monotone.
-/
theorem beatty_mono {α : ℝ} (hα : 1 ≤ α) : Monotone (beatty α) := by
  exact fun m n hmn => Nat.floor_mono <| mul_le_mul_of_nonneg_left ( Nat.cast_le.mpr hmn ) <| by positivity;

/-
For modulus at least one, distinct indices have distinct Beatty values.
-/
theorem beatty_strictMono {α : ℝ} (hα : 1 ≤ α) : StrictMono (beatty α) := by
  refine' strictMono_nat_of_lt_succ fun k => _;
  refine Nat.le_floor ?_;
  norm_num [ beatty ];
  linarith [ Nat.floor_le ( by positivity : 0 ≤ α * k ) ]

/-
Every iterate of a Beatty map of modulus at least one is strictly increasing.
-/
theorem iteratedBeatty_strictMono {α : ℝ} (hα : 1 ≤ α) (n : ℕ) :
    StrictMono (iteratedBeatty α n) := by
  induction' n with n ih;
  · exact strictMono_id;
  · convert ih.comp ( beatty_strictMono hα ) using 1

/-
The interval criterion gives a necessary and sufficient membership test for
an arbitrary iterate: there is a unique positive predecessor in the preceding
iterate whose scalar interval contains `x`.
-/
theorem inIterate_succ_iff_interval {α : ℝ} (hα : 1 ≤ α) (n x : ℕ) :
    InIterate α (n + 1) x ↔
      ∃ y : ℕ, InIterate α n y ∧ (x : ℝ) ≤ α * y ∧ α * y < x + 1 := by
  constructor;
  · rintro ⟨ k, hk₀, hk ⟩;
    unfold iteratedBeatty at hk;
    refine' ⟨ _, ⟨ k, hk₀, rfl ⟩, _ ⟩;
    rw [ ← hk, Function.iterate_succ_apply' ];
    exact ⟨ Nat.floor_le ( by positivity ), Nat.lt_floor_add_one _ ⟩;
  · rintro ⟨ y, ⟨ k, hk₀, hk ⟩, hy₁, hy₂ ⟩;
    use k;
    unfold iteratedBeatty at *;
    simp_all +decide [ Function.iterate_succ_apply', beatty ];
    exact Nat.floor_eq_iff ( by positivity ) |>.2 ⟨ hy₁, hy₂ ⟩

/-
The witness of membership in an iterate is unique.  Thus the existential
membership criterion above is an effective reconstruction principle rather than
merely a representation.
-/
theorem inIterate_witness_unique {α : ℝ} (hα : 1 ≤ α) {n x k l : ℕ}
    (hek : iteratedBeatty α n k = x)
    (hel : iteratedBeatty α n l = x) : k = l := by
  exact StrictMono.injective ( iteratedBeatty_strictMono hα n ) ( hek.trans hel.symm )

/-
A Beatty map is additive up to one unit.  This is its basic tropical defect
bound and is independent of irrationality.
-/
theorem beatty_add_bounds {α : ℝ} (hα : 0 ≤ α) (m n : ℕ) :
    beatty α m + beatty α n ≤ beatty α (m + n) ∧
      beatty α (m + n) ≤ beatty α m + beatty α n + 1 := by
  constructor;
  · exact Nat.le_floor <| by push_cast [ beatty ] ; linarith [ Nat.floor_le ( show 0 ≤ α * m by positivity ), Nat.floor_le ( show 0 ≤ α * n by positivity ) ] ;
  · exact Nat.le_of_lt_succ <| Nat.floor_lt' ( by positivity ) |>.2 <| by push_cast [ beatty ] ; linarith [ Nat.lt_floor_add_one ( α * m ), Nat.lt_floor_add_one ( α * n ) ] ;

/-
For modulus at least two, each Beatty step advances a positive index by at
least one.
-/
theorem beatty_step_growth {α : ℝ} (hα : 2 ≤ α) {k : ℕ} (hk : 0 < k) :
    k + 1 ≤ beatty α k := by
  exact Nat.le_floor ( by norm_num; nlinarith [ show ( k : ℝ ) ≥ 1 by norm_cast ] )

/-
Iteration produces a linearly separated hierarchy: after `n` steps, every
positive index has advanced by at least `n`.
-/
theorem iteratedBeatty_growth {α : ℝ} (hα : 2 ≤ α) {k : ℕ} (hk : 0 < k) (n : ℕ) :
    k + n ≤ iteratedBeatty α n k := by
  induction' n with n ih;
  · rfl;
  · convert Nat.succ_le_of_lt ( lt_of_le_of_lt ih ( beatty_step_growth hα ( by linarith : 0 < iteratedBeatty α n k ) ) ) using 1;
    exact Function.iterate_succ_apply' _ _ _

/-
Specializing the hierarchy to the paper's threshold immediately gives the
same separation estimate, since `(3 + √5)/2 > 2`.
-/
theorem paper_threshold_growth {α : ℝ}
    (hα : (3 + Real.sqrt 5) / 2 < α) {k : ℕ} (hk : 0 < k) (n : ℕ) :
    k + n ≤ iteratedBeatty α n k := by
  convert iteratedBeatty_growth _ hk n using 1;
  nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ]

-- !-- Lab Notes -- !--
-- Hypotheses, ranked by expected impact:
-- (1) recursive predecessors can be eliminated into a closed fractional-part test;
-- (2) iterated floor defects form a bounded min-plus cocycle;
-- (3) the counting function has bounded discrepancy from `X / α^n`;
-- (4) the paper's threshold is a sharp transition for carry rigidity;
-- (5) quadratic moduli yield finite-state predecessor itineraries;
-- (6) iteration preserves strict order and gives unique interval predecessors.
-- Experiment: small irrational moduli showed one-unit additive defects and strict
-- growth; the unguarded growth claim failed at index zero and was corrected to the
-- conventional positive-indexed sequence.  The paper's threshold lies safely in
-- the resulting growth regime `α > 2`.
-- Analysis: hypothesis (6) survives in full, and the one-step case underlying (2)
-- survives sharply.  Irrationality is irrelevant to interval recursion but appears
-- essential for closed formulas and discrepancy statements.
-- Critique: no density, equidistribution, or threshold-sharpness claim is inferred
-- from finite evidence.  The current membership theorem is recursive rather than
-- the stronger predecessor-free criterion suggested in (1).
-- Synthesis: exact interval recursion, uniqueness, the tropical defect bound, and
-- the growth hierarchy provide the common foundation for hypotheses (1)--(5).
-- !-- End Lab Notes -- !--

end IteratedBeatty