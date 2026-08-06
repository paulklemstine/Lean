/-
# Chebotarev geodesic theorem, non-split case — cycle 6: the log-sharp theory

Research thread on the paper *"Chebotarev geodesic theorem: non-split case"*
(prime geodesic theorem for congruence subgroups of indefinite quaternion orders,
exponent `25/36 + ε`, proved by reduction to the split case).

Earlier cycles produced:

* `Shared.ChebotarevGeodesic` — the `ε`-exponent calculus, the invertible-transform
  reduction, class densities, `prime_geodesic_of_chebotarev`;
* `Shared.ChebotarevGeodesicSharpness` — log absorption, little-o form, sharpness;
* `Shared.ChebotarevGeodesicOptimal` — `exponentSet = Ici (optimalExponent)`;
* `Shared.ChebotarevGeodesicDensity` — the density form;
* `Shared.ChebotarevGeodesicTransfer` — the transfer principle and its determinantal
  boundary, the converse Chebotarev principle, effective equidistribution;
* `Shared.ChebotarevGeodesicStaircase` — the `ε`-free two-parameter predicate
  `HasLogErrorExponent` and the exactly computed staircase of a model error term.

This file closes the conjectures **D5**, **D4** and **D1** of `FUTURE_DIRECTIONS.md`.

## Main results

* `HasLogErrorExponent.add`, `.const_mul`, `.sum`, `.linear_comb` — the `ε`-free calculus.
* `prime_geodesic_of_chebotarev_log` and `chebotarev_converse_log` — both directions of the
  Chebotarev ⇄ prime geodesic deduction hold verbatim in the two-parameter setting, with the
  *same* log power `k`; hence `chebotarev_log_iff` and its `ε`-free `25/36` instance
  `chebotarev_log_iff_25_36`.  **(D5)**
* `logExponentRegion_total_eq_iInter` — the whole admissible region `(θ, k)`, corner included,
  is an invariant of the cover: it is the intersection of the class-wise regions.
* `exponentSet_total_eq_jointExponentSet`, `jointOptimalExponent_eq_optimalExponent_total`,
  `optimalExponent_class_le_optimalExponent_total` — the total optimal exponent is exactly the
  joint (i.e. worst-class) one, and dominates each class-wise exponent.  **(D4, corrected
  form: equality with the *joint* exponent, not class-by-class equality.)**
* `transform_kernel_perturb`, `kernel_direction_optimalExponent`,
  `det_zero_optimalExponent_arbitrary`, `transfer_dichotomy` — the graded form of the rank
  obstruction: along a kernel vector of the transform the counting data can be moved with the
  transform *literally unchanged*, and the optimal exponent in that direction can be set to
  any prescribed real number.  **(D1)**

All proofs are complete; no `sorry`.
-/
import Mathlib
import Shared.ChebotarevGeodesic
import Shared.ChebotarevGeodesicSharpness
import Shared.ChebotarevGeodesicOptimal
import Shared.ChebotarevGeodesicTransfer
import Shared.ChebotarevGeodesicStaircase

open Finset Filter
open scoped Topology

namespace ChebotarevGeodesic

variable {π M π₁ π₂ M₁ M₂ : ℝ → ℝ} {θ θ' : ℝ} {k j : ℕ}

/-! ## 1.  The `ε`-free calculus of `HasLogErrorExponent` -/

/-- The zero counting function has every log error exponent. -/
theorem hasLogErrorExponent_zero (θ : ℝ) (k : ℕ) :
    HasLogErrorExponent (fun _ => (0 : ℝ)) (fun _ => (0 : ℝ)) θ k := by
  refine ⟨1, one_pos, 1, le_rfl, fun x hx => ?_⟩
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx
  have hlog : (0 : ℝ) ≤ Real.log x := Real.log_nonneg hx
  have hxθ : (0 : ℝ) ≤ x ^ θ := (Real.rpow_pos_of_pos hx0 θ).le
  have : (0 : ℝ) ≤ 1 * x ^ θ * (Real.log x) ^ k :=
    mul_nonneg (mul_nonneg zero_le_one hxθ) (pow_nonneg hlog k)
  simpa using this

/-- Sums of two counting functions inherit a common `(θ, k)`. -/
theorem HasLogErrorExponent.add (h₁ : HasLogErrorExponent π₁ M₁ θ k)
    (h₂ : HasLogErrorExponent π₂ M₂ θ k) :
    HasLogErrorExponent (fun x => π₁ x + π₂ x) (fun x => M₁ x + M₂ x) θ k := by
  obtain ⟨C₁, hC₁, X₁, hX₁, hb₁⟩ := h₁
  obtain ⟨C₂, hC₂, X₂, hX₂, hb₂⟩ := h₂
  refine ⟨C₁ + C₂, by linarith, max X₁ X₂, le_trans hX₁ (le_max_left _ _), fun x hx => ?_⟩
  have hx1 : X₁ ≤ x := le_trans (le_max_left _ _) hx
  have hx2 : X₂ ≤ x := le_trans (le_max_right _ _) hx
  have e : π₁ x + π₂ x - (M₁ x + M₂ x) = (π₁ x - M₁ x) + (π₂ x - M₂ x) := by ring
  calc |π₁ x + π₂ x - (M₁ x + M₂ x)| ≤ |π₁ x - M₁ x| + |π₂ x - M₂ x| := by
        rw [e]; exact abs_add_le _ _
    _ ≤ C₁ * x ^ θ * (Real.log x) ^ k + C₂ * x ^ θ * (Real.log x) ^ k :=
        add_le_add (hb₁ x hx1) (hb₂ x hx2)
    _ = (C₁ + C₂) * x ^ θ * (Real.log x) ^ k := by ring

/-- Scalar multiples preserve `(θ, k)`. -/
theorem HasLogErrorExponent.const_mul (c : ℝ) (h : HasLogErrorExponent π M θ k) :
    HasLogErrorExponent (fun x => c * π x) (fun x => c * M x) θ k := by
  obtain ⟨C, hC, X, hX, hb⟩ := h
  refine ⟨(|c| + 1) * C, by positivity, X, hX, fun x hx => ?_⟩
  have hx1 : (1 : ℝ) ≤ x := le_trans hX hx
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx1
  have hlog : (0 : ℝ) ≤ Real.log x := Real.log_nonneg hx1
  have hxθ : (0 : ℝ) ≤ x ^ θ := (Real.rpow_pos_of_pos hx0 θ).le
  have hbase : (0 : ℝ) ≤ C * x ^ θ * (Real.log x) ^ k :=
    mul_nonneg (mul_nonneg hC.le hxθ) (pow_nonneg hlog k)
  have e : c * π x - c * M x = c * (π x - M x) := by ring
  calc |c * π x - c * M x| = |c| * |π x - M x| := by rw [e, abs_mul]
    _ ≤ |c| * (C * x ^ θ * (Real.log x) ^ k) :=
        mul_le_mul_of_nonneg_left (hb x hx) (abs_nonneg c)
    _ ≤ (|c| + 1) * (C * x ^ θ * (Real.log x) ^ k) := by nlinarith
    _ = (|c| + 1) * C * x ^ θ * (Real.log x) ^ k := by ring

/-- Finite sums preserve `(θ, k)`. -/
theorem HasLogErrorExponent.sum {ι : Type*} (s : Finset ι) (f g : ι → ℝ → ℝ) (θ : ℝ) (k : ℕ)
    (h : ∀ i ∈ s, HasLogErrorExponent (f i) (g i) θ k) :
    HasLogErrorExponent (fun x => ∑ i ∈ s, f i x) (fun x => ∑ i ∈ s, g i x) θ k := by
  classical
  induction s using Finset.induction with
  | empty => simpa using hasLogErrorExponent_zero θ k
  | insert a s ha ih =>
      have hmem : ∀ i ∈ s, HasLogErrorExponent (f i) (g i) θ k := fun i hi =>
        h i (Finset.mem_insert_of_mem hi)
      have := (h a (Finset.mem_insert_self a s)).add (ih hmem)
      simpa [Finset.sum_insert ha] using this

/-- Finite linear combinations preserve `(θ, k)`: the `ε`-free form of the analytic half of
the character-orthogonality reduction. -/
theorem HasLogErrorExponent.linear_comb {ι : Type*} (s : Finset ι) (c : ι → ℝ)
    (f g : ι → ℝ → ℝ) (θ : ℝ) (k : ℕ)
    (h : ∀ i ∈ s, HasLogErrorExponent (f i) (g i) θ k) :
    HasLogErrorExponent (fun x => ∑ i ∈ s, c i * f i x) (fun x => ∑ i ∈ s, c i * g i x) θ k :=
  HasLogErrorExponent.sum s (fun i x => c i * f i x) (fun i x => c i * g i x) θ k
    fun i hi => (h i hi).const_mul (c i)

/-- The `ε`-free transfer principle: an invertible transform moves `(θ, k)` data back to the
individual counting functions.  This is the paper's reduction of the non-split case to the
split case, carried out without losing the log power. -/
theorem logExponent_of_inverse_transform {ι : Type*} [Fintype ι] [DecidableEq ι]
    (A B : Matrix ι ι ℝ) (hBA : B * A = 1) (f M : ι → ℝ → ℝ) (θ : ℝ) (k : ℕ)
    (h : ∀ j, HasLogErrorExponent (fun x => ∑ i, A j i * f i x)
                                  (fun x => ∑ i, A j i * M i x) θ k) (i : ι) :
    HasLogErrorExponent (f i) (M i) θ k := by
  have hinv : ∀ m, (∑ j, B i j * A j m) = if i = m then 1 else 0 := by
    intro m
    have := congrFun (congrFun hBA i) m
    simpa [Matrix.mul_apply, Matrix.one_apply] using this
  have key : ∀ (F : ι → ℝ → ℝ) (x : ℝ), ∑ j, B i j * (∑ m, A j m * F m x) = F i x := by
    intro F x
    have hswap : ∑ j, B i j * (∑ m, A j m * F m x)
        = ∑ m, (∑ j, B i j * A j m) * F m x := by
      calc ∑ j, B i j * (∑ m, A j m * F m x)
          = ∑ j, ∑ m, B i j * (A j m * F m x) :=
            Finset.sum_congr rfl fun j _ => by rw [Finset.mul_sum]
        _ = ∑ m, ∑ j, B i j * (A j m * F m x) := Finset.sum_comm
        _ = ∑ m, (∑ j, B i j * A j m) * F m x := by
            refine Finset.sum_congr rfl fun m _ => ?_
            rw [Finset.sum_mul]
            exact Finset.sum_congr rfl fun j _ => by ring
    rw [hswap]
    simp [hinv]
  have hlin := HasLogErrorExponent.linear_comb Finset.univ (fun j => B i j)
      (fun j x => ∑ m, A j m * f m x) (fun j x => ∑ m, A j m * M m x) θ k
      (fun j _ => h j)
  have e₁ : (fun x => ∑ j, B i j * (∑ m, A j m * f m x)) = f i := funext (key f)
  have e₂ : (fun x => ∑ j, B i j * (∑ m, A j m * M m x)) = M i := funext (key M)
  rw [e₁, e₂] at hlin
  exact hlin

/-! ## 2.  D5: the log-sharp Chebotarev ⇄ prime geodesic equivalence -/

open scoped Classical in
/-- **Chebotarev ⟹ prime geodesic, log-sharp form.**  Class-wise estimates
`piC C = (|C|/|G|)·li + O(x^θ (log x)^k)` sum to `∑_C piC C = li + O(x^θ (log x)^k)` with the
*same* pair `(θ, k)`: no `ε` and no loss of log power. -/
theorem prime_geodesic_of_chebotarev_log (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    [Fintype (ConjClasses G)] (piC : ConjClasses G → ℝ → ℝ) (li : ℝ → ℝ) (θ : ℝ) (k : ℕ)
    (h : ∀ C, HasLogErrorExponent (piC C) (fun x => classDensity G C * li x) θ k) :
    HasLogErrorExponent (fun x => ∑ C : ConjClasses G, piC C x) li θ k := by
  classical
  have hsum := HasLogErrorExponent.sum (Finset.univ : Finset (ConjClasses G)) piC
      (fun C x => classDensity G C * li x) θ k (fun C _ => h C)
  have e : (fun x => ∑ _C : ConjClasses G, classDensity G _C * li x) = li := by
    funext x
    rw [← Finset.sum_mul, sum_classDensity G, one_mul]
  rwa [e] at hsum

/-- **The converse principle, log-sharp form.**  For a family with eventually non-negative
deviations, one aggregate bound `C x^θ (log x)^k` forces the same bound — same `θ`, same `k`,
same shape — for each summand.  The proof of the one-parameter version never used the shape of
the majorant, and indeed it goes through verbatim. -/
theorem hasLogErrorExponent_of_nonneg_summands {ι : Type*} (s : Finset ι) (f g : ι → ℝ → ℝ)
    (θ : ℝ) (k : ℕ) (hnn : ∀ i ∈ s, ∀ᶠ x in atTop, 0 ≤ f i x - g i x)
    (hsum : HasLogErrorExponent (fun x => ∑ i ∈ s, f i x) (fun x => ∑ i ∈ s, g i x) θ k)
    {i : ι} (hi : i ∈ s) : HasLogErrorExponent (f i) (g i) θ k := by
  obtain ⟨C, hC, X, hX, hb⟩ := hsum
  have hall : ∀ᶠ x in atTop, ∀ m ∈ s, 0 ≤ f m x - g m x :=
    (eventually_all_finset s).mpr hnn
  obtain ⟨X₀, hX₀⟩ := eventually_atTop.mp hall
  refine ⟨C, hC, max X (max X₀ 1), le_max_of_le_right (le_max_right _ _), fun x hx => ?_⟩
  have hxX : X ≤ x := le_trans (le_max_left _ _) hx
  have hxX₀ : X₀ ≤ x := le_trans (le_trans (le_max_left _ _) (le_max_right X _)) hx
  have hnn' : ∀ m ∈ s, 0 ≤ f m x - g m x := hX₀ x hxX₀
  have h1 : f i x - g i x ≤ ∑ m ∈ s, (f m x - g m x) := Finset.single_le_sum hnn' hi
  have h2 : ∑ m ∈ s, (f m x - g m x) = (∑ m ∈ s, f m x) - ∑ m ∈ s, g m x :=
    Finset.sum_sub_distrib (fun m => f m x) (fun m => g m x)
  have h3 : (∑ m ∈ s, f m x) - ∑ m ∈ s, g m x ≤ C * x ^ θ * (Real.log x) ^ k :=
    le_trans (le_abs_self _) (hb x hxX)
  rw [h2] at h1
  rw [abs_of_nonneg (hnn' i hi)]
  linarith

/-- **D5, geometric form.**  Under the positivity hypothesis of the converse Chebotarev
principle, the aggregate `ε`-free estimate with data `(θ, k)` implies the class-wise estimate
with the *same* data. -/
theorem chebotarev_converse_log (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    [Fintype (ConjClasses G)] (piC : ConjClasses G → ℝ → ℝ) (li : ℝ → ℝ) (θ : ℝ) (k : ℕ)
    (hnn : ∀ C, ∀ᶠ x in atTop, classDensity G C * li x ≤ piC C x)
    (hsum : HasLogErrorExponent (fun x => ∑ C : ConjClasses G, piC C x) li θ k)
    (C : ConjClasses G) :
    HasLogErrorExponent (piC C) (fun x => classDensity G C * li x) θ k := by
  classical
  have e : (fun x => ∑ _C : ConjClasses G, classDensity G _C * li x) = li := by
    funext x
    rw [← Finset.sum_mul, sum_classDensity G, one_mul]
  have hsum' : HasLogErrorExponent (fun x => ∑ C : ConjClasses G, piC C x)
      (fun x => ∑ C : ConjClasses G, classDensity G C * li x) θ k := by
    rw [e]; exact hsum
  refine hasLogErrorExponent_of_nonneg_summands Finset.univ piC
    (fun C x => classDensity G C * li x) θ k (fun D _ => ?_) hsum' (Finset.mem_univ C)
  filter_upwards [hnn D] with x hx
  linarith

/-- **D5, closed.**  Under positivity, the class-wise and the aggregate statements are
equivalent as `ε`-free two-parameter statements: the pair `(θ, k)` — exponent *and* log power
— is exactly the same on both sides. -/
theorem chebotarev_log_iff (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    [Fintype (ConjClasses G)] (piC : ConjClasses G → ℝ → ℝ) (li : ℝ → ℝ) (θ : ℝ) (k : ℕ)
    (hnn : ∀ C, ∀ᶠ x in atTop, classDensity G C * li x ≤ piC C x) :
    (∀ C, HasLogErrorExponent (piC C) (fun x => classDensity G C * li x) θ k) ↔
      HasLogErrorExponent (fun x => ∑ C : ConjClasses G, piC C x) li θ k :=
  ⟨fun h => prime_geodesic_of_chebotarev_log G piC li θ k h,
    fun h C => chebotarev_converse_log G piC li θ k hnn h C⟩

/-- The `ε`-free version of the paper's statement at the record exponent: with a log power
`k`, the Chebotarev geodesic theorem `piC C = (|C|/|G|)·li + O(x^{25/36} (log x)^k)` for every
class is *equivalent* to the prime geodesic theorem with the same error term. -/
theorem chebotarev_log_iff_25_36 (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    [Fintype (ConjClasses G)] (piC : ConjClasses G → ℝ → ℝ) (li : ℝ → ℝ) (k : ℕ)
    (hnn : ∀ C, ∀ᶠ x in atTop, classDensity G C * li x ≤ piC C x) :
    (∀ C, HasLogErrorExponent (piC C) (fun x => classDensity G C * li x) (25 / 36) k) ↔
      HasLogErrorExponent (fun x => ∑ C : ConjClasses G, piC C x) li (25 / 36) k :=
  chebotarev_log_iff G piC li (25 / 36) k hnn

/-! ## 3.  The admissible region as an invariant of the cover -/

/-- The two-parameter admissible region of a pair `(π, M)`. -/
def logExponentRegion (π M : ℝ → ℝ) : Set (ℝ × ℕ) :=
  {p | HasLogErrorExponent π M p.1 p.2}

theorem mem_logExponentRegion_iff {p : ℝ × ℕ} :
    p ∈ logExponentRegion π M ↔ HasLogErrorExponent π M p.1 p.2 := Iff.rfl

/-- The region is an upper set for the product order — the two monotonicity lemmas of the
staircase file, packaged. -/
theorem isUpperSet_logExponentRegion (π M : ℝ → ℝ) : IsUpperSet (logExponentRegion π M) := by
  rintro ⟨θ, k⟩ ⟨θ', j⟩ hle hmem
  exact (hmem.mono_exponent hle.1).mono_log hle.2

/-- **The corner is an invariant of the cover.**  Under positivity the admissible region of
the total counting function is exactly the intersection of the class-wise regions.  So not
only the exponent but the whole staircase — in particular its corner `(θ*, k*)`, when it has
one — is shared data: the record for the paper's setting should be quoted as a *pair*. -/
theorem logExponentRegion_total_eq_iInter (G : Type*) [Group G] [Fintype G] [DecidableEq G]
    [Fintype (ConjClasses G)] (piC : ConjClasses G → ℝ → ℝ) (li : ℝ → ℝ)
    (hnn : ∀ C, ∀ᶠ x in atTop, classDensity G C * li x ≤ piC C x) :
    logExponentRegion (fun x => ∑ C : ConjClasses G, piC C x) li =
      ⋂ C : ConjClasses G, logExponentRegion (piC C) (fun x => classDensity G C * li x) := by
  ext ⟨θ, k⟩
  simp only [logExponentRegion, Set.mem_setOf_eq, Set.mem_iInter]
  exact (chebotarev_log_iff G piC li θ k hnn).symm

/-! ## 4.  D4: the total optimal exponent is the joint (worst-class) one -/

section Optimal

variable (G : Type*) [Group G] [Fintype G] [DecidableEq G] [Fintype (ConjClasses G)]

/-- **D4, set form.**  Under positivity, the exponent set of the total counting function is
*exactly* the joint exponent set of the classes.  (The naive form of D4 — all classes have the
same optimal exponent — is not what the equivalence gives: the equivalence pairs the aggregate
with *all* classes simultaneously, so the correct statement is equality with the joint,
i.e. worst-class, data.) -/
theorem exponentSet_total_eq_jointExponentSet (piC : ConjClasses G → ℝ → ℝ) (li : ℝ → ℝ)
    (hnn : ∀ C, ∀ᶠ x in atTop, classDensity G C * li x ≤ piC C x) :
    exponentSet (fun x => ∑ C : ConjClasses G, piC C x) li =
      jointExponentSet piC (fun C x => classDensity G C * li x) := by
  ext θ
  constructor
  · intro h C
    exact chebotarev_converse G piC li θ hnn h C
  · intro h
    exact prime_geodesic_of_chebotarev G piC li θ h

/-- **D4, numerical form.**  The optimal exponent of the prime geodesic theorem equals the
joint optimal exponent of the Chebotarev data: an improvement for the total count is exactly
an improvement for every class at once. -/
theorem jointOptimalExponent_eq_optimalExponent_total (piC : ConjClasses G → ℝ → ℝ)
    (li : ℝ → ℝ) (hnn : ∀ C, ∀ᶠ x in atTop, classDensity G C * li x ≤ piC C x) :
    jointOptimalExponent piC (fun C x => classDensity G C * li x) =
      optimalExponent (fun x => ∑ C : ConjClasses G, piC C x) li := by
  unfold jointOptimalExponent optimalExponent
  rw [exponentSet_total_eq_jointExponentSet G piC li hnn]

/-- Each class is at least as well approximated as the total: the class-wise optimal exponents
are bounded by the total one.  Hence a lower bound for *one* class already lower-bounds the
prime geodesic exponent. -/
theorem optimalExponent_class_le_optimalExponent_total (piC : ConjClasses G → ℝ → ℝ)
    (li : ℝ → ℝ) (hnn : ∀ C, ∀ᶠ x in atTop, classDensity G C * li x ≤ piC C x)
    (C : ConjClasses G)
    (hbd : BddBelow (exponentSet (piC C) (fun x => classDensity G C * li x)))
    (hne : (exponentSet (fun x => ∑ D : ConjClasses G, piC D x) li).Nonempty) :
    optimalExponent (piC C) (fun x => classDensity G C * li x) ≤
      optimalExponent (fun x => ∑ D : ConjClasses G, piC D x) li := by
  refine csInf_le_csInf hbd hne ?_
  intro θ hθ
  exact chebotarev_converse G piC li θ hnn hθ C

/-- **D4, sharpest form.**  If every class-counting function has a non-empty, bounded-below
exponent set, then the optimal exponent of the prime geodesic theorem is exactly the *largest*
of the class-wise optimal exponents: the prime geodesic theorem is limited precisely by the
worst-behaved conjugacy class, and by nothing else. -/
theorem optimalExponent_total_eq_sup (piC : ConjClasses G → ℝ → ℝ) (li : ℝ → ℝ)
    (hnn : ∀ C, ∀ᶠ x in atTop, classDensity G C * li x ≤ piC C x)
    (hne : ∀ C, (exponentSet (piC C) (fun x => classDensity G C * li x)).Nonempty)
    (hbd : ∀ C, BddBelow (exponentSet (piC C) (fun x => classDensity G C * li x))) :
    optimalExponent (fun x => ∑ C : ConjClasses G, piC C x) li =
      (Finset.univ : Finset (ConjClasses G)).sup'
        ⟨ConjClasses.mk 1, Finset.mem_univ _⟩
        (fun C => optimalExponent (piC C) (fun x => classDensity G C * li x)) := by
  have hset : exponentSet (fun x => ∑ C : ConjClasses G, piC C x) li =
      Set.Ici ((Finset.univ : Finset (ConjClasses G)).sup'
        ⟨ConjClasses.mk 1, Finset.mem_univ _⟩
        (fun C => optimalExponent (piC C) (fun x => classDensity G C * li x))) := by
    rw [exponentSet_total_eq_jointExponentSet G piC li hnn]
    ext θ
    simp only [jointExponentSet, Set.mem_setOf_eq, Set.mem_Ici]
    constructor
    · intro h
      refine Finset.sup'_le _ _ (fun C _ => ?_)
      exact csInf_le (hbd C) (h C)
    · intro h C
      have hC : optimalExponent (piC C) (fun x => classDensity G C * li x) ≤ θ :=
        le_trans (Finset.le_sup'
          (fun C => optimalExponent (piC C) (fun x => classDensity G C * li x))
          (Finset.mem_univ C)) h
      exact (hasErrorExponent_optimalExponent _ _ (hne C)).mono hC
  show sInf (exponentSet (fun x => ∑ C : ConjClasses G, piC C x) li) = _
  rw [hset, csInf_Ici]

end Optimal

/-! ## 5.  D1: the graded rank obstruction -/

section Kernel

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

omit [DecidableEq ι] in
/-- **Kernel directions are invisible.**  Perturbing a family along a kernel vector of the
transform leaves the transformed family *literally unchanged* — not merely unchanged up to an
admissible error. -/
theorem transform_kernel_perturb (A : Matrix ι ι ℝ) (v : ι → ℝ) (hv : A.mulVec v = 0)
    (M : ι → ℝ → ℝ) (g : ℝ → ℝ) :
    transform A (fun i x => M i x + v i * g x) = transform A M := by
  funext j x
  have hz : ∑ i, A j i * v i = 0 := by
    have := congrFun hv j
    simpa [Matrix.mulVec, dotProduct] using this
  have hsplit : ∑ i, A j i * (M i x + v i * g x)
      = (∑ i, A j i * M i x) + (∑ i, A j i * v i) * g x := by
    rw [Finset.sum_mul, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  simp only [transform]
  rw [hsplit, hz, zero_mul, add_zero]

omit [DecidableEq ι] in
/-- **D1, graded form.**  Let `v` be a kernel vector of the transform `A` and `i` an index
with `v i ≠ 0`.  Then for *every* prescribed `β` there is a family `f` whose transform is
identical to that of `M`, while the optimal exponent of `f i` against `M i` is exactly `β`.
So along the kernel the exponent data is completely free: the transform records nothing about
it, and the yes/no obstruction of `transfer_iff_det_ne_zero` becomes a statement about a whole
`ker A`-indexed family of freely prescribable exponents. -/
theorem kernel_direction_optimalExponent (A : Matrix ι ι ℝ) (v : ι → ℝ)
    (hv : A.mulVec v = 0) (M : ι → ℝ → ℝ) (β : ℝ) {i : ι} (hvi : v i ≠ 0) :
    ∃ f : ι → ℝ → ℝ, transform A f = transform A M ∧
      optimalExponent (f i) (M i) = β := by
  classical
  refine ⟨fun m x => M m x + v m * x ^ β, transform_kernel_perturb A v hv M _, ?_⟩
  have hgrow : ∀ x ≥ (1 : ℝ), |v i| * x ^ β ≤ |M i x + v i * x ^ β - M i x| := by
    intro x hx
    have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx
    have hxβ : (0 : ℝ) ≤ x ^ β := (Real.rpow_pos_of_pos hx0 β).le
    have heq : M i x + v i * x ^ β - M i x = v i * x ^ β := by ring
    rw [heq, abs_mul, abs_of_nonneg hxβ]
  have hupper : HasErrorExponent (fun x => M i x + v i * x ^ β) (M i) β := by
    intro ε hε
    refine ⟨|v i| + 1, by positivity, 1, le_rfl, fun x hx => ?_⟩
    have hx0 : (0 : ℝ) < x := lt_of_lt_of_le one_pos hx
    have hxβ : (0 : ℝ) ≤ x ^ β := (Real.rpow_pos_of_pos hx0 β).le
    have hle : x ^ β ≤ x ^ (β + ε) := Real.rpow_le_rpow_of_exponent_le hx (by linarith)
    have heq : M i x + v i * x ^ β - M i x = v i * x ^ β := by ring
    rw [heq, abs_mul, abs_of_nonneg hxβ]
    have h1 : |v i| * x ^ β ≤ |v i| * x ^ (β + ε) :=
      mul_le_mul_of_nonneg_left hle (abs_nonneg _)
    have h2 : (0 : ℝ) ≤ x ^ (β + ε) := (Real.rpow_pos_of_pos hx0 (β + ε)).le
    nlinarith
  have hbd : BddBelow (exponentSet (fun x => M i x + v i * x ^ β) (M i)) := by
    refine ⟨β, fun θ hθ => ?_⟩
    by_contra hlt
    push_neg at hlt
    exact not_hasErrorExponent_of_growth (abs_pos.mpr hvi) hlt hgrow hθ
  exact optimalExponent_eq_of_growth (abs_pos.mpr hvi) hbd hgrow hupper

/-- For a singular transform, *any* real number is realizable as the optimal exponent of some
index while the transformed data stays exactly the same.  This is the quantitative failure of
the reduction mechanism at `det A = 0`. -/
theorem det_zero_optimalExponent_arbitrary (A : Matrix ι ι ℝ) (hdet : A.det = 0)
    (M : ι → ℝ → ℝ) (β : ℝ) :
    ∃ (i : ι) (f : ι → ℝ → ℝ), transform A f = transform A M ∧
      optimalExponent (f i) (M i) = β := by
  obtain ⟨v, hv0, hv⟩ := Matrix.exists_mulVec_eq_zero_iff.mpr hdet
  obtain ⟨i, hvi⟩ := Function.ne_iff.mp hv0
  obtain ⟨f, hf, hopt⟩ := kernel_direction_optimalExponent A v hv M β (i := i) hvi
  exact ⟨i, f, hf, hopt⟩

/-- **The dichotomy.**  For a transform `A` exactly one of the following holds:
either `A` is invertible, and then the whole joint exponent set (hence the joint optimal
exponent) of the transformed family determines that of the original family; or `A` is
singular, and then for every prescribed `β` there is a family with the *same* transform as `M`
but with optimal exponent `β` at some index — the transform then determines nothing at all
about the individual exponents. -/
theorem transfer_dichotomy (A : Matrix ι ι ℝ) (M : ι → ℝ → ℝ) (β : ℝ) :
    (A.det ≠ 0 → ∀ f : ι → ℝ → ℝ,
        jointExponentSet (transform A f) (transform A M) = jointExponentSet f M) ∧
    (A.det = 0 → ∃ (i : ι) (f : ι → ℝ → ℝ), transform A f = transform A M ∧
        optimalExponent (f i) (M i) = β) := by
  refine ⟨fun hdet f => ?_, fun hdet => det_zero_optimalExponent_arbitrary A hdet M β⟩
  have hunit : IsUnit A.det := isUnit_iff_ne_zero.mpr hdet
  exact jointExponentSet_transform (A := A) (B := A⁻¹) (Matrix.nonsing_inv_mul A hunit) f M

end Kernel

end ChebotarevGeodesic