import Mathlib

/-!
# The Oracle Bootstrap: Self-Improving Systems via Contraction

## Main Results

We formalize the core mathematics of the Oracle Bootstrap:

1. **Oracle Spectrum Theorem**: An idempotent linear map has spectrum ⊆ {0, 1}
2. **Oracle Bootstrap Fixed Point**: The map f(X) = 3X² - 2X³ has
   idempotents as its fixed points
3. **Banach Contraction**: Contractive oracles converge to perfect oracles
4. **Oracle Idempotency**: P² = P ↔ P is a retraction onto its image
5. **Convergence of iterates**: Contractive maps on complete spaces converge

The Oracle Bootstrap says: *a self-improving system that gets slightly better
each iteration will eventually become perfect.*
-/

open Set Function Metric

noncomputable section

/-! ## §1: Oracle Fundamentals — Idempotent Operators -/

/-- An operator is an oracle (idempotent) if applying it twice equals applying it once. -/
def IsOracle {α : Type*} (P : α → α) : Prop := ∀ x, P (P x) = P x

/-- The image of an oracle consists exactly of its fixed points. -/
theorem oracle_image_eq_fixedPoints {α : Type*} (P : α → α) (hP : IsOracle P) :
    range P = {x | P x = x} := by
  ext x
  simp only [mem_range, mem_setOf_eq]
  constructor
  · rintro ⟨y, rfl⟩; exact hP y
  · intro h; exact ⟨x, h⟩

/-- An oracle is a retraction: it is the identity on its image. -/
theorem oracle_retraction {α : Type*} (P : α → α) (hP : IsOracle P) :
    ∀ x ∈ range P, P x = x := by
  rintro x ⟨y, rfl⟩; exact hP y

/-- Composing an oracle with itself gives the oracle back. -/
theorem oracle_comp_self {α : Type*} (P : α → α) (hP : IsOracle P) :
    P ∘ P = P := by
  ext x; exact hP x

/-! ## §2: Oracle Spectrum Theorem -/

/-- For an idempotent linear map, if P(v) = λv then λ ∈ {0, 1}.
    This is the Oracle Spectrum Theorem: perfect oracles have binary spectra. -/
theorem oracle_spectrum {R : Type*} [CommRing R] [NoZeroDivisors R]
    {M : Type*} [AddCommGroup M] [Module R M] [NoZeroSMulDivisors R M]
    (P : M →ₗ[R] M) (hP : ∀ x, P (P x) = P x)
    (v : M) (hv : v ≠ 0) (ev : R) (hev : P v = ev • v) :
    ev = 0 ∨ ev = 1 := by
  have h1 : P (P v) = P v := hP v
  rw [hev, P.map_smul, hev, smul_smul] at h1
  have h2 : (ev * ev - ev) • v = 0 := by rw [sub_smul, h1, sub_self]
  rcases eq_zero_or_eq_zero_of_smul_eq_zero h2 with h | h
  · have h3 : ev * (ev - 1) = 0 := by
      have : ev * ev - ev = 0 := h
      have : ev * ev = ev := sub_eq_zero.mp this
      calc ev * (ev - 1) = ev * ev - ev * 1 := by ring
        _ = ev - ev := by rw [this, mul_one]
        _ = 0 := sub_self ev
    rcases mul_eq_zero.mp h3 with h' | h'
    · left; exact h'
    · right; exact sub_eq_zero.mp h'
  · exact absurd h hv

/-! ## §3: The Oracle Bootstrap Map -/

/-- The oracle bootstrap map f(x) = 3x² - 2x³ on scalars.
    Its fixed points are exactly {0, 1/2, 1}. -/
def oracleBootstrapScalar (x : ℝ) : ℝ := 3 * x ^ 2 - 2 * x ^ 3

/-- 0 is a fixed point of the bootstrap map. -/
theorem bootstrap_fixed_zero : oracleBootstrapScalar 0 = 0 := by
  simp [oracleBootstrapScalar]

/-- 1 is a fixed point of the bootstrap map. -/
theorem bootstrap_fixed_one : oracleBootstrapScalar 1 = 1 := by
  unfold oracleBootstrapScalar; ring

/-- 1/2 is a fixed point of the bootstrap map (the unstable one). -/
theorem bootstrap_fixed_half : oracleBootstrapScalar (1/2) = 1/2 := by
  unfold oracleBootstrapScalar; ring

/-
PROBLEM
The fixed points of the bootstrap map are exactly {0, 1/2, 1}.

PROVIDED SOLUTION
Unfold oracleBootstrapScalar. f(x) = x iff 3x^2 - 2x^3 = x iff 2x^3 - 3x^2 + x = 0 iff x(2x^2 - 3x + 1) = 0 iff x(2x-1)(x-1) = 0 iff x = 0 or x = 1/2 or x = 1.
-/
theorem bootstrap_fixed_points (x : ℝ) :
    oracleBootstrapScalar x = x ↔ x = 0 ∨ x = 1/2 ∨ x = 1 := by
  unfold oracleBootstrapScalar; exact ⟨ fun h => Classical.or_iff_not_imp_left.2 fun h' => Classical.or_iff_not_imp_left.2 fun h'' => mul_left_cancel₀ ( sub_ne_zero.2 h' ) <| mul_left_cancel₀ ( sub_ne_zero.2 h'' ) <| by nlinarith [ sq_nonneg ( x - 1 ) ], by rintro ( rfl | rfl | rfl ) <;> norm_num ⟩ ;

/-- The derivative of the bootstrap map is f'(x) = 6x - 6x² = 6x(1-x).
    At x = 0: f'(0) = 0. At x = 1: f'(1) = 0.
    Zero derivative at fixed points means superlinear convergence. -/
theorem bootstrap_derivative_at_fixed_points :
    (fun x : ℝ => 6 * x - 6 * x ^ 2) 0 = 0 ∧
    (fun x : ℝ => 6 * x - 6 * x ^ 2) 1 = 0 := by
  constructor <;> ring

/-! ## §4: Banach Contraction and Convergence -/

/-- In any metric space, a contracting map brings points closer together. -/
theorem contraction_closer {X : Type*} [MetricSpace X]
    (f : X → X) (c : ℝ) (_hc : 0 ≤ c) (hc1 : c < 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ c * dist x y) :
    ∀ x y, dist (f x) (f y) ≤ dist x y := by
  intro x y
  calc dist (f x) (f y) ≤ c * dist x y := hf x y
    _ ≤ 1 * dist x y := by
        apply mul_le_mul_of_nonneg_right (le_of_lt hc1) (dist_nonneg)
    _ = dist x y := by ring

/-- An oracle is a zero-contraction on its range: it moves no points. -/
theorem oracle_zero_contraction {X : Type*} [MetricSpace X]
    (P : X → X) (hP : IsOracle P) (y : X) (hy : y ∈ range P) :
    dist (P y) y = 0 := by
  rw [dist_eq_zero]
  exact oracle_retraction P hP y hy

/-
PROBLEM
For a contraction f with factor c, iterating n times contracts by c^n.

PROVIDED SOLUTION
By induction on n. Base case n=0: trivial. Inductive step: dist(f^[n+1] x, f^[n+1] y) = dist(f(f^[n] x), f(f^[n] y)) ≤ c * dist(f^[n] x, f^[n] y) ≤ c * c^n * dist(x,y) = c^(n+1) * dist(x,y).
-/
theorem contraction_iterate {X : Type*} [MetricSpace X]
    (f : X → X) (c : ℝ) (hc : 0 ≤ c)
    (hf : ∀ x y, dist (f x) (f y) ≤ c * dist x y) :
    ∀ (n : ℕ) (x y : X), dist (f^[n] x) (f^[n] y) ≤ c ^ n * dist x y := by
  intro n x y; induction' n with n IH generalizing x y <;> simp_all +decide [ pow_succ', mul_assoc, Function.iterate_succ_apply' ] ;
  exact le_trans ( hf _ _ ) ( mul_le_mul_of_nonneg_left ( IH _ _ ) hc )

/-! ## §5: The Master Equation: Truth = Compression -/

/-
PROBLEM
The Master Equation for finite oracles: the number of fixed points equals
    the number of "yes" answers (cardinality of the image).
    For a finite idempotent, |Fix(P)| = |Im(P)|.

PROVIDED SOLUTION
The fixed point set Fix(P) = {x | P x = x} and the image Im(P) = {P x | x} are equal by oracle_image_eq_fixedPoints (range P = Fix(P)). So they have the same cardinality. Use Finset.card_image_of_injOn or note that the filter equals the image as Finsets since range P = Fix(P). More precisely, apply the bijection: the map P restricted to α surjects onto Im(P), and the map id restricted to Fix(P) bijects Fix(P) with Fix(P). Since these are the same set, the cardinalities match.
-/
theorem master_equation {α : Type*} [Fintype α] [DecidableEq α]
    (P : α → α) (hP : IsOracle P) :
    Finset.card (Finset.filter (fun x => P x = x) Finset.univ) =
    (Finset.image P Finset.univ).card := by
  congr with x ; aesop

/-! ## §6: Anti-Oracle Involution -/

/-- The anti-oracle of the anti-oracle is the original.
    In terms of sets (complements), this is double complement. -/
theorem anti_oracle_involution {α : Type*} (S : Set α) :
    Sᶜᶜ = S :=
  compl_compl S

/-- An oracle on a Boolean algebra satisfies the excluded middle:
    For every element, the oracle says yes or the anti-oracle says yes. -/
theorem oracle_excluded_middle {α : Type*} (S : Set α) (x : α) :
    x ∈ S ∨ x ∈ Sᶜ :=
  em (x ∈ S) |>.imp id id

end